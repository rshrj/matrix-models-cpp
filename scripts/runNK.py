#!/usr/bin/env python3

import os
import time

def notAvail(Nmax, Kmax):
    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            if not os.path.exists(f'./bin/TrialRun-N{N}K{K}'):
                return True
    return False

def main():
    Nmax, Kmax = 3, 3

    runcmd = f'make clean'
    print(runcmd)
    os.system(runcmd)

    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            print(f'N = {N}, K = {K}:')

            with open('./src/TrialRun.cpp', 'r') as file :
                filedata = file.read()

            filedata = filedata.replace('N = 2', f'N = {N}')
            filedata = filedata.replace('K = 2', f'K = {K}')

            with open(f'./cache/TrialRun-Corrected-N{N}K{K}.cpp', 'w') as file:
                file.write(filedata)

            runcmd = f'g++ -o ./bin/TrialRun-N{N}K{K} ./cache/TrialRun-Corrected-N{N}K{K}.cpp -Iinclude -Wall &'
            print(runcmd)
            os.system(runcmd)

    while (notAvail(Nmax, Kmax)):
        time.sleep(1)

    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            print(f'N = {N}, K = {K}:')

            states = os.listdir(f"./runs/States/N{N}K{K}")

            for x in states:
                runcmd = f"./bin/TrialRun-N{N}K{K} " + x + " &"
                print(runcmd)
                os.system(runcmd)
                
    

if __name__ == "__main__":
    main()
