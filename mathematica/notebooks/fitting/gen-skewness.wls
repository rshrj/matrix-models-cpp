#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["../../lib/lib2.m"];
Get["../../lib/util.m"];

Print["importing data"];
data = Import["../../../runs/Trials/N9K9/21385198.dat"];
data2 = Import["../../../runs/Trials/N9K9/15650383.dat"];

changeNK[9, 9];

Print["matricizing data 1"];
cmatdata = cMatOne/@data;
Print["matricizing data 2"];
cmatdata2 = cMatOne/@data2;

eig = Flatten[Map[Eigenvalues, cmatdata[[All, 2;;]], {2}]];
eig2 = Flatten[Map[Eigenvalues, cmatdata2[[All, 2;;]], {2}]];
randmat = Partition[(# - 1/$N Tr[#]IdentityMatrix[$N])&/@RandomVariate[GaussianUnitaryMatrixDistribution[\[Sigma]/Sqrt[$N], $N], Length[data]*$K], $K];

trXsq = Sum[Tr[#[[\[Alpha]]] . #[[\[Alpha]]]]&/@cmatdata[[All, 2;;]]//Chop, {\[Alpha], 1, $K}];
trXsq2 = Sum[Tr[#[[\[Alpha]]] . #[[\[Alpha]]]]&/@cmatdata2[[All, 2;;]]//Chop, {\[Alpha], 1, $K}];
trXsqrand = Sum[Tr[#[[\[Alpha]]] . #[[\[Alpha]]]]&/@randmat//Chop, {\[Alpha], 1, $K}];

Export["../../../runs/skewness.dat", {Skewness[trXsq], Skewness[trXsq2], Skewness[trXsqrand]}];
