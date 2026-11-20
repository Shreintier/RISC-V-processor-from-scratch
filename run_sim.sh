#!/usr/bin/env bash
set -e
mkdir -p sim
for tb in tb/*.v; do
    name=$(basename "$tb" .v)
    iverilog -g2012 -o "sim/${name}.vvp" rtl/*.v "$tb"
    vvp "sim/${name}.vvp" +hex=program.hex +dump=reg_dump.txt
done
