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
$statsDir = "../../../runs/Stats-201";

trX1sqandX1X2[line_] := Module[{t, x}, (
t = First@line;
Do[
x[i] = line[[2+(i-1)($N^2-1);; 1+i($N^2-1)]];
, {i, 1, 2}];
{t, 1/2 x[1] . x[1], 1/2 x[1] . x[2]}
)];

computeStats[data_] := Module[{aa, yy, bb, cc, dd}, (
aa = StandardDeviation[Flatten@data[[All, 2;;$K($N^2-1)+1]]];

yy = trX1sqandX1X2/@data;

bb = Mean[yy[[All, 2]]];
cc = StandardDeviation[yy[[All, 2]]];
dd = StandardDeviation[yy[[All, 3]]];

{aa, bb, cc, dd}
)];


If[!DirectoryQ[$statsDir], CreateDirectory[$statsDir]];

Do[Module[{$dirname, $files, $data, $stats, $out, $statFile}, (
Print["N = "<>ToString@$N<>", K = "<>ToString@$K];
changeNK[$N, $K];
$dirname = "/data1/rishi/bfss-cpp/mar-14/runs/Trials/N"<>ToString@$N<>"K"<>ToString@$K;
$files = FileBaseName/@FileNames[All, $dirname];
Do[(
Print["k = "<>ToString@k<>": "<>ToString@$files[[k]]];
$data = Import[$dirname<>"/"<>$files[[k]]<>".dat"];

If[hasNan[$data], Print["Detected nan, skipping"];Continue[]];

$stats = computeStats[$data];

$out = Join[{$files[[k]]}, Flatten@$stats];

$statFile = OpenAppend[$statsDir<>"/N"<>ToString[$N]<>"K"<>ToString[$K]<>".dat"];
WriteString[$statFile, StringRiffle[ToString/@$out, "    "]<>"\n"];
Close[$statFile];
), {k, 1, Length[$files]}];

$statFile = OpenAppend[$statsDir<>"/N"<>ToString[$N]<>"K"<>ToString[$K]<>".dat"];
WriteString[$statFile, "\n"];
Close[$statFile];

)], {$N, $Nmin, $Nmax}];



