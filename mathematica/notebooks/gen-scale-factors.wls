#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["../lib/lib2.m"];
Get["../lib/util.m"];

$K = 9;
$TrialsFolder = "../../runs/Trials";
$statsDir = "../../runs/Stats-106";
If[!DirectoryQ[$statsDir], CreateDirectory[$statsDir]];

Do[Module[{dir, files}, (
Print["N = "<>ToString@$N<>", K = "<>ToString@$K];
dir = $TrialsFolder<>"/N"<>ToString@$N<>"K"<>ToString@$K;
files = FileNames[dir, All];
Print[ToString@Length[files]<>" found. Computing fs."];
changeNK[$N, $K];
Do[Module[{data, cmatdata, simEig, randEig, out, $statFile}, (
Print["Importing "<>ToString[files[[kk]]]];
data = Import[files[[kk]]];
Print["Computing cmatdata"];
cmatdata = Table[(
With[{p = (vv-1)/(Length[data]-1)}, If[Mod[10p, 1]==0, Print[ToString[100p]<>"% done."]]];
cMatOne[data[[vv]]]
), {vv, 1, Length[data]}];

Print["Computing eigenvalues"];
simEig = Flatten[Eigenvalues/@cmatdata[[All, 2]]];
randEig = With[{randMats = (# - 1/$N Tr[#]*IdentityMatrix[$N])&/@RandomVariate[GaussianUnitaryMatrixDistribution[$N], Length[data]]}, Flatten[Eigenvalues/@randMats]];

Print["Computing stats"];
out = {FileBaseName[files[[kk]]], StandardDeviation[simEig], StandardDeviation[randEig], StandardDeviation[simEig]/StandardDeviation[randEig]};

Print["Exporting"];
$statFile = OpenAppend[$statsDir<>"/N"<>ToString[$N]<>"K"<>ToString[$K]<>".dat"];
WriteString[$statFile, StringRiffle[ToString/@out, "    "]<>"\n"];
Close[$statFile];
)], {kk, 1, Length[files]}]
)], {$N, 3, 9}];
