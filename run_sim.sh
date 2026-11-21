#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
mkdir -p sim

if [[ ${1:-} == --final || ${1:-} == --rv64i ]]; then
    suite=final_processor
    xlen=32
    if [[ $1 == --rv64i ]]; then
        suite=final_processor_rv64i
        xlen=64
    fi
    iverilog -g2012 -s tb_pipelined_processor \
        -P "tb_pipelined_processor.rl_var=$xlen" -o "sim/$suite.vvp" \
        rtl/*.v tb/tb_pipelined_processor.v
    failed=0
    for image in "programs/$suite"/"${suite}_tb"*.mem; do
        name=$(basename "$image" .mem)
        test_id=${name#${suite}_tb}
        workdir="sim/$suite/$name"
        mkdir -p "$workdir"
        cp "$image" "$workdir/program.mem"
        if ! (cd "$workdir" && vvp "../../$suite.vvp" "+test=$test_id" "+expect_width=$xlen") \
                > "$workdir/simulation.log" 2>&1; then
            tail -n 40 "$workdir/simulation.log"
            failed=1
        elif ! grep -Fx "PASS: $name" "$workdir/simulation.log"; then
            echo "Missing PASS for $name. See $workdir/simulation.log"
            failed=1
        fi
    done
    exit "$failed"
fi

for tb in tb/*.v; do
    name=$(basename "$tb" .v)
    iverilog -g2012 -o "sim/${name}.vvp" rtl/*.v "$tb"
    vvp "sim/${name}.vvp" +dump=reg_dump.txt
done
