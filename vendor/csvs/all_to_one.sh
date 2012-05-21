#!/bin/bash

# put all the csv data into one file
for f in *csv; do
    tail -$((`wc $f | awk '{ print $1 }'`-1)) $f >> all_relics.csv;
done
