#!/bin/bash

for f in ./runs/States/*.dat; do
    a=$(basename -- "$f" ".dat")
    for n in {1..20}; do
        bin/TrialRun $a &
    done
done
