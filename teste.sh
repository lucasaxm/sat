#!/bin/bash

for file in $(ls teste) ; do
    echo $file
    # echo "./sat.rb $(cat teste/$file)"
    input=$(cat teste/$file)
    # echo teste
    # echo $input
    # ./sat.rb "$input"
    ruby sat.rb "$input"
    echo
done
