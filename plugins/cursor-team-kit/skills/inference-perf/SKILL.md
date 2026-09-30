---
name: inference-perf
description: Operational checks for LLM inference serving performance. Use when optimizing TTFT, TPOT, inter-token latency, KV cache, batching, tensor/pipeline parallelism, quantization, or GPU/TPU serving bottlenecks. Specialized skill, not a Day-1 default.
---

# Inference perf

Specialized skill for LLM inference serving performance work. Not a Day-1
default. Use when optimizing TTFT, TPOT, inter-token latency, KV cache
sizing, batching strategy, tensor or pipeline parallelism, quantization,
or GPU/TPU serving bottlenecks.

Provenance: distilled from the Wafer AI GPU performance engineering
curriculum (https://github.com/wafer-ai/gpu-perf-engineering-resources).

## Operational checks

### Prefill vs decode bottleneck

Prefill and decode have different arithmetic intensity. Sweep batch size
against context length. Profile linear layers and attention kernels
separately to find whether the bottleneck is memory bandwidth or compute.

Reference: "Efficiently Scaling Transformer Inference" (Pope et al., 2023);
"Transformer Inference Arithmetic" (Kipply, 2022).

### Tensor parallelism and collectives

Tensor parallelism can move the bottleneck from compute to collective
communication. Check 1D vs 2D partitioning against the interconnect
bandwidth and matrix dimensions before adding shards.

Reference: "How to Scale Your Model Inference" (Wafer AI curriculum);
"Efficiently Scaling Transformer Inference" (Pope et al., 2023).

### Weight-stationary vs weight-gathered

Whether to keep weights stationary or gather them depends on the token
batch size and prefill length. Weight-stationary wins at small batches;
weight-gathered can win at large prefill when communication overlaps
with compute.

### MQA/GQA and KV-head replication

Under multi-query or grouped-query attention, tensor parallelism beyond
the KV-head count can replicate the KV cache across shards. Check for
this before capacity estimates; the effective memory cost may exceed naive
per-head math.

### KV capacity vs attention intermediates

KV cache memory and temporary attention score tensors are different
memory problems. FlashAttention or microbatching the score computation
addresses the intermediate memory without changing KV capacity.

Reference: "FlashAttention: Fast and Memory-Efficient Exact Attention
with IO-Awareness" (Dao et al., 2022).

### Overlap collectives with compute

Overlap communication with compute only if a timeline profile proves the
overlap is real. Launching async collectives alone is not proof. Inspect
the GPU timeline for actual concurrency.

### Quantize against the measured bottleneck

Quantization targets differ by bottleneck. Int8 weights reduce memory
traffic and help bandwidth-bound layers but do not always speed up
compute-bound arithmetic. Match quantization (weights, activations, or
KV cache) to the bottleneck the profile shows.

### Measure the operating point

Measure the operating point the application needs: TTFT (time to first
token), inter-token latency (TPOT/ITL), and throughput under the target
load. Keep queueing delay separate from prefill latency in measurements.

Reference: "Etalon: Holistic Performance Evaluation Framework for LLM
Inference Systems" (Agrawal et al., 2024).

### Practical loop

1. Estimate compute, HBM bandwidth, and collective cost for the workload.
2. Inspect the profile to find the actual bottleneck.
3. Change layout, precision, or parallelism to address that bottleneck.
4. Remeasure at the same latency target.

## Start-here reading order

Follow the Wafer AI curriculum reading order as the source of truth:

1. "How to Scale Your Model Inference" (overview)
2. "Attention Is All You Need" (Vaswani et al., 2017)
3. CUDA C++ Programming Guide (basics)
4. *Programming Massively Parallel Processors* (PMPP, Hwu et al.)
5. Roofline model (Williams et al., 2009)
6. "Transformer Inference Arithmetic" (Kipply, 2022)
7. "Efficiently Scaling Transformer Inference" (Pope et al., 2023)
8. "Etalon" (Agrawal et al., 2024)

Curriculum repo: https://github.com/wafer-ai/gpu-perf-engineering-resources

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.
