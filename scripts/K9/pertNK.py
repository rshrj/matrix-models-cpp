#!/usr/bin/env python3

import os
import time

K = 9

def notAvail(Nmin, Nmax):
    for N in range(Nmin, Nmax + 1):
            if not os.path.exists(f'./bin/GenPert-N{N}K{K}'):
                return True
    return False

def main():
    Nmin = 9
    Nmax = 9
    NumStates = 47

    runcmd = f'make clean'
    print(runcmd)
    os.system(runcmd)

    for N in range(Nmin, Nmax + 1):
            print(f'N = {N}, K = {K}:')

            with open('./src/GenPert.cpp', 'r') as file :
                filedata = file.read()

            filedata = filedata.replace('N = 2', f'N = {N}')
            filedata = filedata.replace('K = 2', f'K = {K}')

            with open(f'./cache/GenPert-Corrected-N{N}K{K}.cpp', 'w') as file:
                file.write(filedata)

            runcmd = f'g++ -o ./bin/GenPert-N{N}K{K} ./cache/GenPert-Corrected-N{N}K{K}.cpp -Iinclude -Wall &'
            print(runcmd)
            os.system(runcmd)

    while (notAvail(Nmin, Nmax)):
        time.sleep(1)

    for N in range(Nmin, Nmax + 1):
            print(f'N = {N}, K = {K}:')

            states = os.listdir(f"./runs/States/N{N}K{K}")

            for x in states:
                for _ in range(NumStates):
                    runcmd = f"./bin/GenPert-N{N}K{K} " + x + " &"
                    print(runcmd)
                    os.system(runcmd)
                
    

if __name__ == "__main__":
    main()
