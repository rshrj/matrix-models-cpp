#!/usr/bin/env wolframscript
(* ::Package:: *)

LaunchKernels[];

Get["../lib/lib2.m"];
Get["../lib/util.m"];

ParallelDo[(
files = FileNames[All, "../../runs/Trials/N"<>ToString[$N]<>"K"<>ToString[$K]];

changeNK[$N, $K];

Do[
Print["N = "<>ToString@$N<>", K = "<>ToString@$K<>": Working on "<>FileBaseName@files[[k]]];

radTab = {};
trX2Tab = {};
trX3Tab = {};
trX4Tab = {};

str = OpenRead[files[[k]]];
Do[
line = ReadLine[str];
If[line === EndOfFile, Continue[]];
If[Mod[k, 500]==0, Print["t = "<>ToString[k/10]]];
tqp = First@ImportString[line, "Table"];
tmat = First@cMat[{tqp}];
AppendTo[radTab, radius[tqp]];
AppendTo[trX2Tab, TrX2[tmat]];
AppendTo[trX3Tab, TrX3[tmat]];
AppendTo[trX4Tab, TrX4[tmat]];
, {k, 1, 10000}];
Close[str];

Print["Computing stats and exporting"];
stats = {FileBaseName[files[[k]]],Mean[radTab[[All, 2]]], StandardDeviation[radTab[[All, 2]]],
Mean[trX2Tab[[All, 2]][[All, 1, 2]]], StandardDeviation[trX2Tab[[All, 2]][[All, 1, 2]]],
If[$K>=3, Mean[trX3Tab[[All, 2]][[All, 1, 2, 3]]], Mean[trX3Tab[[All, 2]][[All, 1, 2, 1]]]], If[$K>=3, StandardDeviation[trX3Tab[[All, 2]][[All, 1, 2, 3]]], StandardDeviation[trX3Tab[[All, 2]][[All, 1, 2, 1]]]],
Mean[trX4Tab[[All, 2]]], StandardDeviation[trX4Tab[[All, 2]]]};

statFile = OpenAppend["../../runs/Stats/N"<>ToString[$N]<>"K"<>ToString[$K]<>".dat"];
WriteString[statFile, StringRiffle[ToString/@stats, "    "]<>"\n"];
Close[statFile];

, {k, 1, Length[files]}];

), {$N, 2, 9}, {$K, 2, 10}];
