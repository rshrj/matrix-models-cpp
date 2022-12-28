#!/bin/bash

for n in {1..10};
do
  bin/GenStates &
done
wait