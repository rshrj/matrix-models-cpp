#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["../../lib/lib2.m"];
Get["../../lib/util.m"];


data = Import["../../../runs/Trials/N7K9/"];


changeNK[7, 9];


Print["computing T"];
T = kin[data[[100]]];
Print["computing V"];
V = pot[data[[100]]];
Print["computing E"];
ee = energy[data[[100]]];


Print["T = "<>ToString@T];
Print["V = "<>ToString@V];
Print["E = "<>ToString@ee];
