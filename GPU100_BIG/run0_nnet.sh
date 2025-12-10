#!/bin/bash

# path setup
bin=/data/local/tmp/JY/bin/tf_benchmark_tool
model=/data/local/tmp/JY/models/fp32
eembc=/data/local/tmp/JY/tools/EEMBC
logger=/data/local/tmp/JY/log/logger_100ms_pixel9
dnn_output=dnn_out.txt
eembc_output=eembc_out.txt

# cores
BIG1=80
BIG1MID1=C0
BIG1MID2=E0
BIG1MID3=F0
MID1=40
MID2=60
MID3=70
LIT1=08
LIT2=0C
LIT3=0E
LIT4=0F

MIDA=40
MIDB=20
MIDC=10

LITA=08
LITB=04
LITC=02
LITD=01

# DNN parameters
iter=100000000
min_sec=1800
max_sec=1800
warmup_run=10
warmup_min_sec=1
cooldown_sec=600
gpu_warmup_sec=12

# functions
device_init() {
    echo "Initializing device settings..."

    # airplane mode on
    settings put global airplane_mode_on 1
    am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true >/dev/null

    # brightness min
    settings put system screen_brightness 20

    # low power mode off
    settings put global low_power 0

    # fixed performance mode on
    # cmd power set-fixed-performance-mode-enabled true 2>/dev/null || true

    echo "Initialization complete."
}

device_cleanup() {
    echo "Cleaning up device environment..."

    # background app clear
    am kill-all

    # kernel cache clear
    sync
    echo 3 > /proc/sys/vm/drop_caches

    # memory compaction
    echo 1 > /proc/sys/vm/compact_memory

    echo "Cleanup complete."
}

gpu_50() {
    echo "Running GPU 50% load test..."

    taskset ${LITD} ${bin} --graph=${model}/MobileNet_V1.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITD} ${bin} --graph=${model}/MobileNet_V1.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITC} ${bin} --graph=${model}/MobileNet_V1.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITC} ${bin} --graph=${model}/MobileNet_V1.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITB} ${bin} --graph=${model}/MobileNet_V1.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITB} ${bin} --graph=${model}/MobileNet_V1.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITA} ${bin} --graph=${model}/MobileNet_V1.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &

    echo "GPU 50% load test initiated."

    echo "Waiting for ${gpu_warmup_sec} seconds to stabilize GPU load..."

    sleep ${gpu_warmup_sec}

    echo "GPU load stabilized."
}

gpu_100() {
    echo "Running GPU 100% load test..."

    taskset ${LITD} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITD} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITD} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITD} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITC} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITC} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITC} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITC} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITB} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITB} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITB} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &
    taskset ${LITB} ${bin} --graph=${model}/DeepLabV3_MobileNet.tflite --num_threads=1 --num_runs=${iter} --min_secs=${min_sec} --max_secs=${max_sec} --use_gpu=true &

    echo "GPU 100% load test initiated."

    echo "Waiting for ${gpu_warmup_sec} seconds to stabilize GPU load..."

    sleep ${gpu_warmup_sec}

    echo "GPU load stabilized."
}

# governor setup
# echo "Setting CPU governor to performance mode..."

# num_cpus=$(nproc)

# for i in $(seq 0 $((num_cpus-1))); do
#     echo "performance" > /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor
# done

# echo "Governor set to performance mode."

# skin temperature DTM disable
echo "Disabling DTM for skin temperature sensors..."

tz_start=7
tz_end=12
emul_skin_temp=5000         # millicelsius

for i in $(seq ${tz_start} ${tz_end}); do
    echo ${emul_skin_temp} > /sys/class/thermal/thermal_zone${i}/emul_temp
done

echo "DTM disabled for skin temperature sensors."

sleep 1

# test start
echo "Starting benchmark tests..."

# device_init
sleep 1

exe=nnet

# nnet
echo "$exe (1 BIG w/ DTM 1 thread)" >> ${eembc_output}
taskset ${LITA} ${logger} ./outputs/${exe}_1BIG_DTM_1T_log.txt &
gpu_100
taskset ${BIG1} ${eembc}/${exe} -v0 -c1 -w1 -i2610 | grep "time(secs)" >> ${eembc_output}
kill -9 $(pgrep benchmark)
kill -9 $(pgrep logger)
device_cleanup
sleep ${cooldown_sec}

# echo "$exe (1 MID w/ DTM 1 thread)" >> ${eembc_output}
# taskset ${LITA} ${logger} ./outputs/${exe}_1MID_DTM_1T_log.txt &
# gpu_100
# taskset ${MIDC} ${eembc}/${exe} -v0 -c1 -w1 -i2610 | grep "time(secs)" >> ${eembc_output}
# kill -9 $(pgrep benchmark)
# kill -9 $(pgrep logger)
# device_cleanup
# sleep ${cooldown_sec}

echo "Benchmark tests completed."