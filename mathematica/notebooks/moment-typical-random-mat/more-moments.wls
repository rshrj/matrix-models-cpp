#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ::Code::Initialization:: *)
Get["../../lib/lib2.m"];
Get["../../lib/util.m"];


(* ::Code::Initialization:: *)
$K = 9;
nMax = 12;
$TrialsFolder = "../../../runs/Trials";
$statsDir = "../../../runs/Moments";
If[!DirectoryQ[$statsDir], CreateDirectory[$statsDir]];


printProgress[i_, iMax_, c_] := If[Floor[(100i)/iMax]!=c, WriteString["stdout", "\r...", Floor[(100i)/iMax], "%"]; Floor[(100i)/iMax], c];


trX1sq[line_] := 1/2 Total@(line[[2;;$N^2]]^2);


trX1X2[line_] := 1/2 line[[2;;$N^2]] . line[[($N^2+1);;2$N^2-1]];


trXsq[line_] := 1/2 Total@(line[[2;;$K($N^2-1)+1]]^2);


pot[line_] := Module[{x, count}, (
	Do[
		x[k] = line[[(k-1)($N^2-1)+2;;k($N^2-1)+1]]
	, {k, 1, $K}];
	count = 0;
	Sum[
		count = printProgress[j-1/2 i (1+i-2 $K)-$K, $K ($K-1)/2, count];
		$fSU[[e, a, b]]*$fSU[[e, c, d]]*x[i][[a]]*x[j][[b]]*x[i][[c]]*x[j][[d]]
	, {i, 1, $K}, {j, i+1, $K}, {a, 1, $N^2-1}, {b, a+1, $N^2-1}, {c, 1, $N^2-1}, {d, c+1, $N^2-1}, {e, 1, $N^2-1}]
)];


(* ::Code::Initialization:: *)
Do[Module[{dir, files}, (
Print["N = "<>ToString@$N<>", K = "<>ToString@$K];
dir = $TrialsFolder<>"/N"<>ToString@$N<>"K"<>ToString@$K;

files = FileNames[All, dir];
Print[ToString@Length[files]<>" found."];

Print["Refreshing fs"];
changeNK[$N, $K];

Do[Module[{data, res, \[Sigma] , out, $statFolder, $statFile}, (
Print["Importing "<>ToString[files[[kk]]]];
data = Import[files[[kk]]];

Print["Computing I. Tr(\!\(\*SuperscriptBox[\(X\), \(1\)]\)\!\(\*SuperscriptBox[\()\), \(2\)]\)"];
res[1] = trX1sq/@data;

Print["Computing II. Tr(\!\(\*SuperscriptBox[\(X\), \(1\)]\)\!\(\*SuperscriptBox[\(X\), \(2\)]\))"];
res[2] = trX1X2/@data;

Print["Computing III. Tr(\!\(\*SuperscriptBox[\(X\), \(i\)]\)\!\(\*SuperscriptBox[\(X\), \(i\)]\))"];
res[3] = trXsq/@data;

Print["Computing IV. V(X)"];
res[4] = pot/@data;

Do[
	Print["Computing stats "<>ToString@statIndex];
	\[Sigma] = StandardDeviation[res[statIndex]];
	out = {FileBaseName[files[[kk]]], Mean[res[statIndex]], \[Sigma]};
	Do[(
		Print["n = "<>ToString@n];
		AppendTo[out, CentralMoment[res[statIndex], n]/\[Sigma]^n];
	), {n, 3, nMax}];

	Print["Exporting"];
	$statFolder = $statsDir<>"/type-"<>ToString@statIndex;
	If[!DirectoryQ[$statFolder], CreateDirectory[$statFolder]];
	$statFile = OpenAppend[$statFolder<>"/N"<>ToString[$N]<>"K"<>ToString[$K]<>".dat"];
	WriteString[$statFile, StringRiffle[ToString[#, InputForm]&/@out, "    "]<>"\n"];
	Close[$statFile];
, {statIndex, 1, 4}];
)], {kk, 1, Length[files]}]
)], {$N, 4, 9}];
