#!/bin/bash

for n in {1..20};
do
  bin/GenStates &
done
wait
