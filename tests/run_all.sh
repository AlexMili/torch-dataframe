#!/bin/bash

for f in *_tests.lua; do 
    echo "";
    echo "********************************************";
    echo "Running tests in $f";
    th $f;
    echo "End $f";
    echo "********************************************";
done
