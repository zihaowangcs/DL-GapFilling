
# DL-GapFilling Overview

DL-GapFilling is a sequence prediction method based on BiLSTM, currently using five self-constructed plant datasets. It also performs well on bacteria and plants. The main data processed by DL-GapFilling is second-generation sequencing data. It aims to identify gaps that other software tools have failed to fill, predict the possible sequences for the gaps using the flank data on both sides of the gaps, and then insert the predicted sequences into the original data. This can significantly improve the filling efficiency of other software.

## Prerequisites

Ensure that your Python version is at least Python 3.6.10.

### Download Genome Assembly, Reference Genome, and Homologous Genomes

For this project, we use Illumina sequencing data (DNA, paired-end sequencing).

Preprocessing:
```bash
pip install sra-tools
```
Run `fastq-dump`:
```bash
fastq-dump SRR14462380 --split-3 --gzip -O ./
parallel-fastq-dump -s ERR11837138 --split-3 --gzip -O ./
parallel-fastq-dump -t 12 -s ERR11837138 --split-3 --gzip -O ./
```
Then rename the files as `NA12878_S1_L001_R1_001.fastq.gz`, `NA12878_S1_L001_R2_001.fastq.gz`.

Alternatively, you can run:
```bash
chmod +x data_reprocess.sh
./data_reprocess.sh  dataset
```

### fastq-dump Converts SRA Data to FastQ Format
```bash
fastq-dump --split-e SRR1036346.sra
```

### fasterq-dump Supports Multithreading
```bash
fasterq-dump --split-3 SRR1036346.sra -e 10 -o SRR1036346
```
For paired-end data, two files are produced: `SRR1036346_1.fastq` and `SRR1036346_2.fastq`. For single-end data, only `SRR1036346.fastq` is generated.

## 1. Abyss Assembly for Scaffolds
Abyss (Assembly By Short Sequences) is a tool for assembling genomes from short sequence data. It converts high-throughput sequencing data (such as Illumina data) into contiguous DNA sequences to reconstruct the original DNA sequence. Abyss can assemble short sequence data into longer contiguous sequences (contigs), which can be further assembled into scaffolds to reconstruct the original DNA sequence.

```bash
$(basename $0) <kmer size> <num threads> <output prefix> <NA12878 directory> <output dir>
```

We focus on `human-scaffolds.fa`, which contains the actual draft assembly sequences.

## 2. Sealer Gap Filling for Scaffolds
Use Sealer to fill as many gaps as possible in the draft assembly from step 1.

### 1) Use ABySS-bloom to create Bloom filters for all reads in NA12878.
We start from a k-mer length of 45 and go up to 105, with a gap of 10 between each k-mer (i.e., 45, 55, ..., 105).

```bash
./runme_ABySS-bloom.sh <read directory> <outpath>
```

### 2) Use Sealer to fill gaps based on the Bloom filter:
```bash
./run-sealerAllReads.sh <Draft scaffolds FASTA> <Bloom filter directory>
```

Sealer's output will be in the Bloom filter directory. We focus on the `.sealer_merged` file.

[Warning] The gap filling process by Sealer is completed through steps 1 and 2.

## 3. Extract Gaps and Flanks

### 1) Without Homologous Genomes
This script will traverse the `scaffold.fa` file, identify gaps, and mark their positions. It will then index the coordinates of the flanks on either side of the gaps, extracting data using tools like `samtools`, `bedtools`, etc., for the next sampling step.

The principle: This step uses the previously assembled Abyss draft to identify gaps, extract their flanks, and find reads that map to these flanks.

First, we convert the scaffolds file to an AGP file (to search for gaps marked by "N"). The data from these gaps will be stored in a BED file. Then, we index the scaffold using SAMtools and use this index along with the BED file to extract flank coordinates of approximately 500 bp.

```bash
./extract_flanks_and_reads.sh /home/chenyu/wangzihao/schizosaccharomyces_pombe/scripts/1_abyss_assembly/k50/kc3/human-scaffolds.fa /home/chenyu/wangzihao/schizosaccharomyces_pombe/scripts/3_flank_extraction /home/chenyu/wangzihao/schizosaccharomyces_pombe/data
```
```bash
./extract_flanks_and_reads.sh <scaffold path> <output directory> <NA12878 reads directory>
```

Key outputs:
- `human-scaffolds_gaps_flanks.fa`: Contains all flank sequences for each gap in the draft assembly.
- `NA12878_mappedSubset.fastq.gz`: Contains reads mapped to any of these flanks.

### 2) With Homologous Genomes

```bash
./extract_flanks_and_reads.sh <scaffold path> <output directory> <NA12878 reads directory> <homo path>
```

## 4. Random Sampling of Gap Data

This step samples all gap-related information found in the previous step, categorizing gaps into those that Sealer can or cannot fill.

### 1) Without Homologous Genomes
### 2) With Homologous Genomes

```bash
./sample_random_gaps.sh <gaps file> <sealer merged file> <output path> <sample size> <reads file> <draft fasta path>
```

- `<gaps file>`: `human-scaffolds_gaps_flanks.fa` from step 3.
- `<sealer merged file>`: One of the outputs from step 2.
- `<sample size>`: The number of gaps to sample (e.g., 900).
- `<draft fasta path>`: The compressed FASTQ file containing all reads mapped to the flanks.

Key outputs: Directories `fixed` and `unfixed` for gaps successfully filled or not filled by Sealer, and the `dirty` directory for gaps that were filtered out due to specific criteria.

## 5. GAPFULL

### 1. Neural Network Model Training

Dependencies:
- TensorFlow 2.11.0
- CUDA 11.2
- Conda 4.10.1
- Python 3.7

```bash
./train_gaps.sh <lib directory> <fixed path> <unfixed path> 5_model_training
```

Train a neural network to predict gaps based on flanks.

### 2. Sealer Gap Filling
Reassemble the data using Sealer.

```bash
./evaluate.sh <predicted dir> <read directory> <Draft scaffolds FASTA> <mark>
```

If the second step doesn't execute correctly after the first step, run the following commands separately:

```bash
./run-sealerAllReads.sh <Draft scaffolds FASTA> <Bloom filter directory>
mv human-scaffolds* <previous output>
mv log/ <previous output>
python ./sort_evaluate_file.py <previous output>
```

### 6. Evaluation Standards

#### 1) Traditional Software Assembly Evaluation
```bash
./validate_gap_flank_prediction.sh human-scaffolds.fa human-scaffolds.sealer_scaffold.fa data human-scaffolds.sealer_merged.fa reference_genome sealer
```

#### 2) Deep Learning Assembly Evaluation
```bash
./validate_gap_flank_prediction.sh human-scaffolds.fa human-scaffolds.sealer_scaffold.fa data human-scaffolds.sealer_merged.fa reference_genome DL
```

```bash
validate_gap_flank_prediction.sh <1_abyss_assembly scaffold.fa> <5_sealer_gap_filling sealer_scaffold.fa> <origin data> <5_sealer_gap_filling sealer_merged.fa> <origin reference data> <suffix name>
```

#### 3) Results Storage
```bash
chmod +x aggregate_exonerate.py
python ./aggregate_exonerate.py /home/chenyu/wangzihao/Thalictrum_thalictroides/scripts/validateion_gaps_flanks/validation_2024-10-08_21:55_gappredict
```
This generates a CSV file containing matched ID, fixed status, identity percentage, query and target positions, lengths, and alignment lengths.

#### 4) QUAST

QUAST evaluates the assembly quality of genome A against reference genome B and saves the results to location C:

```bash
python ./quast.py -r B -o C A
```

```bash
./compare_percent_identity.sh [predict_csv] [sealer_csv] out
```
This compares the predictions and outputs the sections where the predicted results are worse than Sealer's results.

```bash
quast -r <path_to_reference> -o <output_dir> <path_to_assembly_file>
```
```
