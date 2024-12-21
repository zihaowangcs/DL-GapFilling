import heapq
import numpy as np
from preprocess.KmerLabelEncoder import KmerLabelEncoder
from collections import Counter

def calculateEntropy(sequence):
    if isinstance(sequence, np.ndarray):
        sequence = sequence.flatten().tolist()
    count = Counter(sequence)
    total = len(sequence)
    entropy_value = -sum((count[base] / total) * np.log2(count[base] / total) for base in count)
    return entropy_value

class BeamSearchPredictor:
    def __init__(self, model, seed=None, maxNodes=64):
        self.model = model
        self.seed = seed
        self.maxNodes = maxNodes
        self.atProb = 0.0
        self.cgProb = 0.0
        self.calculateAtCgProb()

    def calculateAtCgProb(self):
        if self.seed is None:
            return
        baseCounts = {'A': 0, 'T': 0, 'C': 0, 'G': 0}
        totalLength = len(self.seed)
        for base in self.seed:
            if base in baseCounts:
                baseCounts[base] += 1
        self.atProb = (baseCounts['A'] + baseCounts['T']) / totalLength
        self.cgProb = (baseCounts['C'] + baseCounts['G']) / totalLength

    def predict_next_n_bases(self, seed, predictionLength, beamLength):
        labelEncoder = KmerLabelEncoder()
        seedLength = len(seed)
        totalPredictionLength = seedLength + predictionLength

        encodedSeed = labelEncoder.encode_kmers([seed], [], with_shifted_output=False)[0]
        openList = [(0, self.heuristicFunc(encodedSeed, totalPredictionLength), encodedSeed)]
        closedList = []

        beamWidth = beamLength

        while len(openList) > 0:
            currentNodes = heapq.nsmallest(beamWidth, openList)
            nextLevelOpenList = []
            print(f"Current Beam Width: {beamWidth}, Open List Size: {len(openList)}")

            for currentG, _, currentNode in currentNodes:
                if len(currentNode) == totalPredictionLength:
                    print("Prediction complete.")
                    return currentNode, currentG

                predictions = self.model.predict(np.array([currentNode]))
                print(f"Predictions shape: {predictions.shape}, Node: {currentNode}")

                for j in range(predictions.shape[1]):
                    probability = predictions[0, j]
                    if probability > 1e-6:
                        newSeed = np.append(currentNode, j)
                        newG = currentG + np.abs(np.log(probability))
                        newH = self.heuristicFunc(newSeed, totalPredictionLength)
                        nextLevelOpenList.append((newG + newH, newH, newSeed))
                        print(f"Expanding node: {newSeed}, G: {newG}, H: {newH}")

            nextLevelOpenList.sort(key=lambda x: x[0])
            openList = nextLevelOpenList[:beamWidth]
            closedList.clear()
            
        if len(openList) > 0:
            bestNode = min(openList, key=lambda x: x[0])
            return bestNode[2], bestNode[0]
        else:
            print("No valid path found.")
            return None, None

    def heuristicFunc(self, sequence, totalLength, nextSeed=None, k1=1.0, k2=1.0, k3=1.0, k4=1.0):
        currentLength = len(sequence)
        remainingLength = totalLength - currentLength
        sequence_list = sequence.tolist() if isinstance(sequence, np.ndarray) else sequence
        currentEntropy = calculateEntropy(sequence_list)

        if self.atProb is None or self.cgProb is None:
            averageLogProb = -np.log(0.25)
        else:
            averageLogProb = -np.log(np.array([self.atProb, self.cgProb]).mean())
        
        maxEntropy = 2
        normalizedEntropy = currentEntropy / maxEntropy
        normalizedRemainingLengthLogProb = remainingLength * averageLogProb / (totalLength * averageLogProb)

        heuristicValue = normalizedEntropy * k1 + normalizedRemainingLengthLogProb * k2
        return heuristicValue * k4
