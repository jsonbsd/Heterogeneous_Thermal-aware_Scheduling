# Heterogeneous Thermal-aware Scheduling

## Motivation
Modern mobile SoCs integrate BIG, MID, and LITTLE CPUs alongside high-power GPUs and NPUs.  
When GPU/NPU utilization is low, CPU cores remain cool and **BIG cores typically deliver the best performance**.  
However, when the GPU/NPU is fully utilized, the GPU/NPU becomes a major heat source, and heat conduction raises CPU temperatures (especially BIG cores). This causes:
- DVFS thermal throttling
- Reduced IPC
- Lower stable operating clock frequency

As a result, **BIG cores become the worst option when GPU/NPU is fully utilized**, while MID cores maintain more stable performance.

---

## Purpose
This work evaluates how CPU performance changes under GPU/NPU-induced thermal stress and introduces a **thermal-aware scheduling technique** that:
- Starts workloads on BIG cores when thermals are favorable
- Detects when BIG cores throttle due to GPU/NPU thermal stress
- Migrates workloads to MID cores to maintain performance

The goal is to show that **static BIG core assignment is not optimal** under real thermal conditions, and dynamic scheduling yields better results.

---

## Proposed Scheduling Technique
The scheduling method monitors the BIG core frequency in real time (Google Pixel 9):

```Shell
freq_line="$(cat /sys/devices/platform/exynos-acme/fw_freq | grep 'cpu7')"
freq=$(echo "$freq_line" | awk '{print $3}' | tr -cd '0-9')

if [ "$freq" -lt "$BIG_freq_threshold" ]; then
taskset -ap "$MIDC" "$pid"
echo "Migration completed."
break
fi
```

**Key behavior:**
1. Benchmark begins on a BIG core.  
2. If BIG core clock frequency drops below a threshold (due to heat propagation induced thermal throttling), the script performs **migration** to a MID core.  
3. Execution continues on MID, avoiding further thermal penalties.

This simple heuristic successfully adapts to GPU/NPU-induced thermal degradation and achieves the best performance when GPU/NPU is fully utilized.

---

## How to Use

### Run a scheduling-enabled benchmark under GPU 100% utilization

```Shell
cd GPU100_Scheduling
sh ./run11_linear_alg_migration.sh
```

### Run a static MID core benchmark

```Shell
cd GPU100_MID
sh ./run10_linear_alg.sh
```

### Run a static BIG core benchmark

```Shell
cd GPU0_BIG
sh ./run10_linear_alg.sh
```

### Expected behavior
- **GPU 0% utilization**: Scheduling = BIG > MID
- **GPU 100% utilization**: Scheduling > MID > BIG

The scheduling script will automatically migrate from BIG → MID once it detects thermal throttling condition.

# Notice
This work is part of an ongoing paper. Unauthorized use and distribution are prohibited.