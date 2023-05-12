#!/usr/bin/env wolframscript
(* ::Package:: *)

<<MaTeX`;


Get["../../lib/lib2.m"];
Get["../../lib/util.m"];


SetOptions[MaTeX,"Preamble"->{"\\usepackage{physics,mathtools,newtxtext,newtxmath}"}, FontSize->12];
SetOptions[$FrontEndSession,PrintingStyleEnvironment->"Working"];
texStyle={FontFamily->"Times",FontSize->12};


cm = 72/2.54;


plotsDir = "../../../plots/plots-thesis";
If[!DirectoryQ[plotsDir], CreateDirectory[plotsDir]];


changeNK[9, 9];


\[Alpha] = 29.13336434822746`;


Print["importing data 1"];
data[1] = Import["../../../runs/Trials/N9K9/12279703-1.dat"];
Print["importing data 2"];
data[2] = Import["../../../runs/Trials/N9K9/15650383-1.dat"];
Print["importing data 3"];
data[3] = Import["../../../runs/Trials/N9K9/15650383-1.dat"];
Print["making gue samples"];
randmat = Partition[(# - 1/$N Tr[#]*IdentityMatrix[$N])&/@RandomVariate[GaussianUnitaryMatrixDistribution[1/Sqrt[\[Alpha] $N], $N], 100000*$K], $K];


Print["computing radii"];
rad[1] = radius/@data[1];
rad[2] = radius/@data[2];
rad[3] = radius/@data[3];
radrand = Sum[Tr[#[[a]] . #[[a]]], {a, 1, $K}]&/@randmat//Chop;


fns = {Mean, StandardDeviation, Skewness, Kurtosis};
objs = {rad[1][[All, 2]], rad[2][[All, 2]], rad[3][[All, 2]], radrand};
tab = Table[f[o], {o, objs}, {f, fns}];


Export[plotsDir<>"/7-discrepencies.dat", tab];
