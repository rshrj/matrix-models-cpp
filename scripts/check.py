#!/usr/bin/env python3

import os

def main():
    N, K = 5, 5

    print(f'N = {N}, K = {K}:')

    with open('./src/TrialRun.cpp', 'r') as file :
        filedata = file.read()

    filedata = filedata.replace('N = 2', f'N = {N}')
    filedata = filedata.replace('K = 2', f'K = {K}')

    with open(f'./cache/TrialRun-Corrected-N{N}K{K}.cpp', 'w') as file:
        file.write(filedata)

    file = f"92225358.dat";
    states = [file];

    runcmd = f"(g++ -o ./bin/TrialRun-N{N}K{K} ./cache/TrialRun-Corrected-N{N}K{K}.cpp -Iinclude -Wall && " + " && ".join([f"./bin/TrialRun-N{N}K{K} " + x for x in states]) + ") &"

    print(runcmd)

    os.system(runcmd)
                
    

if __name__ == "__main__":
    main()