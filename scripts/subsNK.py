#!/usr/bin/env python3

import os

def main():
    Nmax, Kmax = 3, 4
    NumStates = 2

    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            print(f'N = {N}, K = {K}:')

            with open('./src/GenStates.cpp', 'r') as file :
                filedata = file.read()

            filedata = filedata.replace('N = 2', f'N = {N}')
            filedata = filedata.replace('K = 2', f'K = {K}')

            with open(f'./cache/GenStates-Corrected-N{N}K{K}.cpp', 'w') as file:
                file.write(filedata)

            runcmd = f'(g++ -o ./bin/GenStates-N{N}K{K} ./cache/GenStates-Corrected-N{N}K{K}.cpp -Iinclude -Wall && ' + " && ".join([f"./bin/GenStates-N{N}K{K}" for x in range(NumStates)]) + ") &"

            print(runcmd)

            os.system(runcmd)
                
    

if __name__ == "__main__":
    main()