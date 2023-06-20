#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ::Code::Initialization:: *)
Get["../../lib/lib2.m"];
Get["../../lib/util.m"];


(* ::Code::Initialization:: *)
$K = 9;
nMax = 12;
$TrialsFolder = "/data1/rishi/bfss-cpp/feb-27/runs/Trials";
$statsDir = "../../../runs/Stats-Moments-2";
If[!DirectoryQ[$statsDir], CreateDirectory[$statsDir]];


(* ::Code::Initialization:: *)
Do[Module[{dir, files}, (
Print["N = "<>ToString@$N<>", K = "<>ToString@$K];dir = $TrialsFolder<>"/N"<>ToString@$N<>"K"<>ToString@$K;

files = FileNames[All, dir];
Print[ToString@Length[files]<>" found."];

Do[Module[{data, rad, \[Sigma] , out, $statFile}, (
Print["Importing "<>ToString[files[[kk]]]];
data = Import[files[[kk]]];

Print["Computing TrXiXi"];
rad = (radius/@data)[[All, 2]];

Print["Computing stats"];
\[Sigma] = StandardDeviation[rad];
out = {FileBaseName[files[[kk]]], Mean[rad], \[Sigma]};
Do[(
Print["n = "<>ToString@n];
AppendTo[out, CentralMoment[rad, n]/\[Sigma]^n];
), {n, 3, nMax}];

Print["Exporting"];$statFile = OpenAppend[$statsDir<>"/N"<>ToString[$N]<>"K"<>ToString[$K]<>".dat"];
WriteString[$statFile, StringRiffle[ToString[#, InputForm]&/@out, "    "]<>"\n"];
Close[$statFile];
)], {kk, 1, Length[files]}]
)], {$N, 3, 9}];
