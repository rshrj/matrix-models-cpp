(* ::Package:: *)

radiusSimple[qpData_]:=1/2 Total@(#^2&/@qpData[[;;Length[qpData]/2]]);


radius[tqpData_]:={tqpData//First,1/2 Total@(#^2&/@tqpData[[2;;(Length[tqpData]-1)/2]])};


actQP[f_, tqpData_] := Module[{res}, (
	res = f[tqpData[[2;;]]];
	If[Length[res] > 1,
		Return[Join[{tqpData//First}, f[tqpData[[2;;]]]], Module],
		Return[{tqpData//First, f[tqpData[[2;;]]]}, Module]
	]
)];


angMom[tqpData_]:=Module[{q, p}, (
q = tqpData[[2;;(Length[tqpData]+1)/2]];
p =tqpData[[1+(Length[tqpData]+1)/2;;]];
q =ArrayReshape[q, {$K, $N^2-1}];
p =ArrayReshape[p, {$K, $N^2-1}];

{tqpData//First, Table[1/2 Sum[q[[i, a]]p[[j, a]]- p[[i, a]]q[[j, a]], {a, 1, $N^2-1}], {i, 1, $K}, {j, 1, $K}]}
)];


comm[x1_, x2_, $f_]:=Table[Sum[$f[[a, b, c]]*(x1[[b]]x2[[c]]-x1[[c]]x2[[b]]), {b, 1, $N^2-1}, {c, b+1, $N^2-1}], {a, 1, $N^2-1}];


energy[tqpData_]:=Module[{q, p, cc}, (
q = tqpData[[2;;(Length[tqpData]+1)/2]];
p =tqpData[[1+(Length[tqpData]+1)/2;;]];

q =ArrayReshape[q, {$K, $N^2-1}];

{tqpData//First, 1/4 Total@(#^2&/@p) + 1/4 Sum[Total@(#^2&/@comm[q[[i]], q[[j]], $fSU]), {i, 1, $K}, {j, i+1, $K}]}
)];


process[filename_]:=Module[{data, d, e, \[ScriptCapitalD], msg}, Monitor[(
msg = "Importing time series";
data = Import[filename, "Table"];

msg = "Evaluating energy";
e = energy[data//First]//Last;

msg = "Generating the table of log \!\(\*SuperscriptBox[\(TrX\), \(2\)]\)";
d = Log@(radius/@data)[[All, 2]];

\[ScriptCapitalD] = SmoothKernelDistribution[d];

Prepend[#[\[ScriptCapitalD]]&/@{Mean, StandardDeviation, Skewness}, e]
), msg<>"..."]];



convertToMatrix[suNvec_] := suNvec . (basisSU[]);


cMat[tData_] := Module[{}, (
Table[Join[{tData[[k, 1]]}, convertToMatrix/@Partition[tData[[k,2;;]], $N^2-1]], {k, 1, Length[tData]}]
)];


TrX2[tpqData_] := Module[{t, Xs}, (
t = tpqData[[1]];
Xs = tpqData[[2;;($K+1)]];

{t, Table[(Tr[Xs[[i]] . Xs[[j]]] - 1/$K Sum[Tr[Xs[[k]] . Xs[[k]]], {k, 1, $K}]KroneckerDelta[i, j])//Chop, {i, 1, $K}, {j, 1, $K}]}
)];


TrX3[tpqData_] := Module[{t, Xs}, (
t = tpqData[[1]];
Xs = tpqData[[2;;($K+1)]];

{t, Table[Tr[Xs[[i]] . Xs[[j]] . Xs[[k]]]//Chop, {i, 1, $K}, {j, 1, $K}, {k, 1, $K}]}
)];


TrX4[tpqData_] := Module[{t, Xs}, (
t = tpqData[[1]];
Xs = tpqData[[2;;($K+1)]];

{t, Tr[MatrixPower[Sum[Xs[[i]] . Xs[[i]], {i, 1, $K}], 2]]//Chop}
)];
