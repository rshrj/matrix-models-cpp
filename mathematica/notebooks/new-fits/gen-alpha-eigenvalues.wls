#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["../../lib/lib2.m"];
Get["../../lib/util.m"];

hasNan[data_] := Module[{}, (
Do[
If[AnyTrue[Head/@data[[Length[data]-i+1]], #===String&], Return[True, Module];Break[];]
, {i, 1, Length[data]}];
Return[False, Module];
)];

$K = 9;
$Nmin = 3;
$Nmax = 9;
$statsDir = "../../../runs/Stats-202";

computeStats[cmatdata_] := Module[{eig}, (
eig = Flatten@Map[Eigenvalues, cmatdata[[All, 2;;]], {2}];
{StandardDeviation[eig]}
)];


If[!DirectoryQ[$statsDir], CreateDirectory[$statsDir]];

Do[Module[{$dirname, $files, $data, $cmatdata, $stats, $out, $statFile}, (
Print["N = "<>ToString@$N<>", K = "<>ToString@$K];
changeNK[$N, $K];
$dirname = "../../../runs/Trials/N"<>ToString@$N<>"K"<>ToString@$K;
$files = FileBaseName/@FileNames[All, $dirname];
Do[(
Print["k = "<>ToString@k<>": "<>ToString@$files[[k]]];
$data = Import[$dirname<>"/"<>$files[[k]]<>".dat"];

Print["converting to matrices"];
$cmatdata = cMatOne/@$data;

If[hasNan[$data], Print["Detected nan, skipping"];Continue[]];

Print["computing eigenvalue stats"];
$stats = computeStats[$cmatdata];

$out = Join[{$files[[k]]}, Flatten@$stats];

$statFile = OpenAppend[$statsDir<>"/N"<>ToString[$N]<>"K"<>ToString[$K]<>".dat"];
WriteString[$statFile, StringRiffle[ToString/@$out, "    "]<>"\n"];
Close[$statFile];
), {k, 1, Length[$files]}]
)], {$N, $Nmin, $Nmax}]//AbsoluteTiming




