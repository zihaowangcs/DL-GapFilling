
## 1. Single-Gap Metrics

Each prediction record has the following fields:

| Field | Description |
|-------|-------------|
| `matches` | Number of correctly predicted bases (True Positives, TP) |
| `mismatches` | Number of incorrectly predicted bases (False Positives, FP) |
| `target_alignment_length` | Length of the reference region that should be filled (aligned portion) |
| `is_fixed` | `1` if the gap was filled, `0` if not |
| `percent_identity` | Identity between predicted and reference sequence (if aligned) |
| `query_bases` *(optional)* | Number of bases inserted in prediction (may differ from target) |

> **Note**: `total_bases_compared = matches + mismatches`

### Accuracy (Per-Base Accuracy)


$$
\text{Accuracy} = \frac{\text{matches}}{\text{total\_bases\_compared}}
$$

- If `percent_identity == 0` and `is_fixed == 1` → **Accuracy = 0**
- If `is_fixed == 0` → **Accuracy = 0**

---

### Precision (Positive Predictive Value)

$$
\text{Precision} = \frac{\text{matches}}{\text{matches} + \text{mismatches}}
$$

- If `percent_identity == 0` and `is_fixed == 1` → **Precision = 0**
- If `percent_identity == 0` and `is_fixed == 0` → **Not computed** (no prediction made)

---

### Recall (Sensitivity)

$$
\text{Recall} = \frac{\text{matches}}{\text{target\_alignment\_length}}
$$

- If `percent_identity == 0` and `is_fixed == 1` → **Recall = 0**
- If `is_fixed == 0` → **Recall = 0**  
  > (Implies FN = `target_alignment_length`)

---

### F1-Score

$$
F1 = 2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}}
$$

- If **Precision = 0** or **Recall = 0** → **F1 = 0**

---

## 2. Aggregated Metrics

### Macro-Averaging

Compute metric for each gap, then take the arithmetic mean:

$$
\text{Macro-Accuracy} = \frac{1}{N} \sum_{i=1}^{N} \text{Accuracy}_i
$$

Similarly for:
- Macro-Precision
- Macro-Recall
- Macro-F1

> Sensitive to per-gap performance, regardless of gap size.

---

### Micro-Averaging

Aggregate TP, FP, FN across all gaps first, then compute global metrics.

#### Total Counts

| Term | Definition |
|------|------------|
| **TP** | `sum(matches)` for all gaps where `is_fixed == 1` |
| **FP** | `sum(mismatches)` for `is_fixed == 1`<br> + `sum(query_bases)` for `is_fixed == 0` *(if any insertions were attempted)* |
| **FN** | `sum(target_alignment_length - matches)` for `is_fixed == 1`<br> + `sum(target_length)` for `is_fixed == 0` |

> `target_length`: expected length of the gap to be filled (from reference).

#### Final Metrics

$$
\text{Micro-Precision} = \frac{\sum \text{TP}}{\sum \text{TP} + \sum \text{FP}}
$$

$$
\text{Micro-Recall} = \frac{\sum \text{TP}}{\sum \text{TP} + \sum \text{FN}}
$$

$$
\text{Micro-F1} = 2 \cdot \frac{\text{Micro-Precision} \times \text{Micro-Recall}}{\text{Micro-Precision} + \text{Micro-Recall}}
$$

> Reflects overall performance weighted by gap size and frequency.

---

## 📝 Notes

- These metrics are suitable for evaluating deep learning-based gap-filling models (e.g., DL-GapFilling).
- When `is_fixed == 0`, no sequence is generated → FP = 0 (unless dummy bases are inserted), but FN = full gap length.
- For failed predictions (`is_fixed=0`), consider logging `query_bases=0` unless partial insertion occurred.
- Use **micro-F1** for overall system performance; use **macro-F1** to detect bias against small gaps.

---
