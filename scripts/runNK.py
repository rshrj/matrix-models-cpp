#!/usr/bin/env python3

import os

def main():
    Nmax, Kmax = 10, 10

    for N in range(2, Nmax + 1):
        for K in range(2, Kmax + 1):
            print(f'N = {N}, K = {K}:')

            with open('./src/TrialRun.cpp', 'r') as file :
                filedata = file.read()

            filedata = filedata.replace('N = 2', f'N = {N}')
            filedata = filedata.replace('K = 2', f'K = {K}')

            with open(f'./src/TrialRun-Corrected-N{N}K{K}.cpp', 'w') as file:
                file.write(filedata)

            states = os.listdir(f"./runs/States/N{N}K{K}")

            runcmd = f"(g++ -o ./bin/TrialRun-N{N}K{K} ./src/TrialRun-Corrected-N{N}K{K}.cpp -Iinclude -Wall && " + " && ".join([f"./bin/TrialRun-N{N}K{K} " + x for x in states]) + ") &"

            print(runcmd)

            os.system(runcmd)
                
    

if __name__ == "__main__":
    main()