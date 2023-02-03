#!/usr/bin/env python3

import os
import time

def notAvail(Nmax, Kmax):
    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            if not os.path.exists(f'./bin/GenStates-N{N}K{K}'):
                return True
    return False

def main():
    Nmax, Kmax = 9, 10
    NumStates = 10

    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            print(f'N = {N}, K = {K}:')

            with open('./src/GenStates.cpp', 'r') as file :
                filedata = file.read()

            filedata = filedata.replace('N = 2', f'N = {N}')
            filedata = filedata.replace('K = 2', f'K = {K}')

            with open(f'./cache/GenStates-Corrected-N{N}K{K}.cpp', 'w') as file:
                file.write(filedata)

            runcmd = f'g++ -o ./bin/GenStates-N{N}K{K} ./cache/GenStates-Corrected-N{N}K{K}.cpp -Iinclude -Wall &'

            print(runcmd)

            os.system(runcmd)

    while (notAvail(Nmax, Kmax)):
        time.sleep(1)

    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            print(f'N = {N}, K = {K}:')

            runcmd = f'./bin/GenStates-N{N}K{K} &'

            print(f'{NumStates} x {runcmd}')

            for _ in range(NumStates):
                os.system(runcmd)
                
    

if __name__ == "__main__":
    main()