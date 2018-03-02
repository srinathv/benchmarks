#! /usr/bin/env bash

armclang -O0 -g basic_flop.c -o basic_flop.noopt.exe
armclang -O3 -g basic_flop.c -o basic_flop.O3.exe
armclang -O2 -fno-vectorize basic_flop.c -o basic_flop.novecO2.exe
