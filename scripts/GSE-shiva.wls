#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];


Get["../lib/lib2.m"];
Get["../lib/util.m"];


plotsDir= "../../plots/plots-104";
If[!DirectoryQ[plotsDir], CreateDirectory[plotsDir]];


data = Import["../../runs/Trials/N9K9/44406078.dat"];


changeNK[9, 9];


matdata = cMat[data];


unitMats = RandomVariate[GaussianUnitaryMatrixDistribution[1, 9], 100000];


plts = Monitor[Table[Module[{}, ( 
obsSim[n] = Tr[MatrixPower[#, n]]&/@matdata[[All, 2]]//Chop//Re;
obsUnitary[n] = Tr[MatrixPower[#, n]]&/@unitMats//Chop//Re;

Histogram[{Standardize[obsSim[n]], Standardize[obsUnitary[n]]}, 3000, PDF, ImageSize->500]
)], {n, 2, 13}], ProgressIndicator[(n-2)/(13-2)]];


Framed[Column[{Style["Title",Darker@Blue,Bold,16],GraphicsGrid[ArrayReshape[plts,{4,4}],Frame->All,ImageSize->2000]},
Alignment->Center],FrameMargins->10]


Export[plotsDir<>"/eigDist-Symplectic.pdf", Rasterize[plt, ImageResolution->300, ImageSize->500]]
