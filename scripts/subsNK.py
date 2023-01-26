#!/usr/bin/env python3

import os

def main():
    Nmax, Kmax = 10, 10

    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            print(f'N = {N}, K = {K}:')

            with open('./src/GenStates.cpp', 'r') as file :
                filedata = file.read()

            filedata = filedata.replace('N = 2', f'N = {N}')
            filedata = filedata.replace('K = 2', f'K = {K}')

            with open(f'./src/GenStates-Corrected-N{N}K{K}.cpp', 'w') as file:
                file.write(filedata)

            os.system(f'(g++ -o ./bin/GenStates-N{N}K{K} ./src/GenStates-Corrected-N{N}K{K}.cpp -Iinclude -Wall && ./bin/GenStates-N{N}K{K} && ./bin/GenStates-N{N}K{K} && ./bin/GenStates-N{N}K{K} && ./bin/GenStates-N{N}K{K} && ./bin/GenStates-N{N}K{K}) &')
                
    

if __name__ == "__main__":
    main()