#!/usr/bin/env python3

import os
import time

K = 9

def notAvail(Nmin, Nmax):
    for N in range(Nmin, Nmax + 1):
            if not os.path.exists(f'./bin/TrialRun-N{N}K{K}'):
                return True
    return False

def main():
    Nmin = 9
    Nmax = 9
    T = 0.3
    dt = 0.1

    runcmd = f'make clean'
    print(runcmd)
    os.system(runcmd)

    for N in range(Nmin, Nmax + 1):
            print(f'N = {N}, K = {K}:')

            with open('./src/TrialRun.cpp', 'r') as file :
                filedata = file.read()

            filedata = filedata.replace('N = 2', f'N = {N}')
            filedata = filedata.replace('K = 2', f'K = {K}')
            filedata = filedata.replace('end_time = 1000.0', f'end_time = {T}')
            filedata = filedata.replace('dt = 0.1', f'dt = {dt}')

            with open(f'./cache/TrialRun-Corrected-N{N}K{K}.cpp', 'w') as file:
                file.write(filedata)

            runcmd = f'g++ -o ./bin/TrialRun-N{N}K{K} ./cache/TrialRun-Corrected-N{N}K{K}.cpp -Iinclude -Wall &'
            print(runcmd)
            os.system(runcmd)

    while (notAvail(Nmin, Nmax)):
        time.sleep(1)
    file = open('./scripts/K9/list_run.txt', 'w', encoding='utf-8')

    for N in range(Nmin, Nmax + 1):
            print(f'N = {N}, K = {K}:')

            states = os.listdir(f"./runs/States/N{N}K{K}")

            for x in states:
                runcmd = f"./bin/TrialRun-N{N}K{K} " + x + " "
                # print(runcmd)
                # os.system(runcmd)
                file.write(runcmd + '\n')
    file.close()

    os.system("parallel --jobs 2 < ./scripts/K9/list_run.txt")
    # for N in range(Nmin, Nmax + 1):
    #         print(f'N = {N}, K = {K}:')

    #         states = os.listdir(f"./runs/States/N{N}K{K}")
    #         os.system(f"parallel -j 2 -k --no-notice './bin/TrialRun-N{N}K{K}  "{}" ' ::: " + str(states)[1:-1])


if __name__ == "__main__":
    main()
