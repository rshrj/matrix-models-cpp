#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["../lib/lib2.m"];
Get["../lib/util.m"];

$K = 9;
$TrialsFolder = "../../runs/Trials";
$statsDir = "../../runs/Stats-109";
If[!DirectoryQ[$statsDir], CreateDirectory[$statsDir]];

Do[Module[{d, dir, files}, (
Print["N = "<>ToString@$N<>", K = "<>ToString@$K];
dir = $TrialsFolder<>"/N"<>ToString@$N<>"K"<>ToString@$K;
files = FileNames[dir, All];
Print["Computing fs."];
changeNK[$N, $K];
Do[Module[{data, cmatdata, simEig, randEig, out, $statFile}, (
Print["Importing "<>ToString[files[[kk]]]];
data = Import[files[[kk]]];
Print["Computing cmatdata"];
cmatdata = Table[(
With[{p = (vv-1)/(Length[data]-1)}, If[Mod[10p, 1]==0, Print[ToString[100p]<>"% done."]]];
cMatOne[data[[vv]]]
), {vv, 1, Length[data]}];

Do[(
Print["Computing words, n = "<>ToString@n];
d = (Tr[Dot@@Table[#[[A+1]], {A, n}]])&/@cmatdata;
hRe = HistogramList[Re@d, 450, PDF];
hIm = HistogramList[Im@d, 450, PDF];
Print["Exporting real part"];
If[!DirectorQ[$statsDir<>"/"<>ToString@$N<>ToString@$K], CreateDirectory[$statsDir<>"/"<>ToString@$N<>ToString@$K]];
Export[$statsDir<>"/"<>ToString@$N<>ToString@$K<>"/"<>ToString@n<>"-Re.dat", hRe];
Print["Exporting imaginary part"];
Export[$statsDir<>"/"<>ToString@$N<>ToString@$K<>"/"<>ToString@n<>"-Im.dat", hIm];
), {n, 2, $K}];
)], {kk, 1, 1}]
)], {$N, 3, 9}];
