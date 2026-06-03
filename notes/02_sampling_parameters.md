# Sampling Parameters: Temperature, Top P, Frequency Penalty

## Temperature
**What it does**: Controls randomness in token selection.

| Value | Behavior |
|-------|----------|
| 0.1-0.3 | Deterministic, conservative |
| 0.7-1.0 | Balanced |
| 1.2-1.5 | Creative, random |

**Origin**: From thermodynamics. Higher temperature = more random particle motion.

## Top P (Nucleus Sampling)
**What it does**: Limits sampling to the smallest set of tokens whose cumulative probability >= P.

| Value | Effect |
|-------|--------|
| 0.5 | Only obvious choices |
| 0.9-1.0 | Standard (default = 1.0) |

## Frequency Penalty
**What it does**: Penalizes tokens that have already appeared to reduce repetition.

| Value | Effect |
|-------|--------|
| 0 | No penalty (default) |
| >0 | Discourages repetition |

## Quick Reference

TEMPERATURE: How "crazy" the model gets
TOP P: How wide the model looks
FREQUENCY PENALTY: How much it hates repeating

