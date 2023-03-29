#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["../lib/lib2.m"];
Get["../lib/util.m"];

hasNan[data_] := Module[{}, (
Do[
If[AnyTrue[Head/@data[[Length[data]-i+1]], #===String&], Return[True, Module];Break[];]
, {i, 1, Length[data]}];
Return[False, Module];
)];

$K = 9;
$Nmin = 8;
$Nmax = 8;
$tStart = 100;
$statsDir = "../../runs/Stats-101";

SymTr[line_] := Module[{t, x}, (
Do[
t = First@line;
x[i] = line[[2+(i-1)($N^2-1);; 1+i($N^2-1)]];
, {i, 1, $K}];
{t, Table[x[i] . x[j] - KroneckerDelta[i, j]/$K Sum[x[k] . x[k], {k, 1, $K}], {i, 1, $K}, {j, 1, $K}]}
)];

computeStats[data_] := Module[{rad, symTr, fns, t0}, (
rad = radius/@data;
symTr = SymTr/@data;

fns = {Mean, StandardDeviation};

t0 = Round[$tStart*10 + 1];

Join[{#[rad[[t0;;, 2]]]&/@fns},
Flatten[#, 1]&@Table[#[symTr[[t0;;, 2]][[i, j]]]&/@fns, {i, 1, $K-1}, {j, i, $K}]]
)];


If[!DirectoryQ[$statsDir], CreateDirectory[$statsDir]];

Do[Module[{$dirname, $files, $data, $stats, $out, $statFile}, (
Print["N = "<>ToString@$N<>", K = "<>ToString@$K];
changeNK[$N, $K];
$dirname = "../../runs/Trials/N"<>ToString@$N<>"K"<>ToString@$K;
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
), {k, 1, Length[$files]}]
)], {$N, $Nmin, $Nmax}];
