(* ::Package:: *)

(* ::Input::Initialization:: *)
$K=3;$N=8;


(* ::Input::Initialization:: *)
radiusSimple[qpData_]:=1/2 Total@(#^2&/@qpData[[;;Length[qpData]/2]]);


(* ::Input::Initialization:: *)
radius[tqpData_]:={tqpData//First,1/2 Total@(#^2&/@tqpData[[2;;(Length[tqpData]-1)/2]])};


actQP[f_, tqpData_] := Module[{res}, (
	res = f[tqpData[[2;;]]];
	If[Length[res] > 1,
		Return[Join[{tqpData//First}, f[tqpData[[2;;]]]], Module],
		Return[{tqpData//First, f[tqpData[[2;;]]]}, Module]
	]
)];


(* ::Input::Initialization:: *)
angMom[tqpData_]:=Module[{q, p}, (
q = tqpData[[2;;(Length[tqpData]+1)/2]];
p =tqpData[[1+(Length[tqpData]+1)/2;;]];
q =ArrayReshape[q, {$K, $N^2-1}];
p =ArrayReshape[p, {$K, $N^2-1}];

{tqpData//First, Table[1/2 Sum[q[[i, a]]p[[j, a]]- p[[i, a]]q[[j, a]], {a, 1, $N^2-1}], {i, 1, $K}, {j, 1, $K}]}
)];


(* ::Input::Initialization:: *)
comm[x1_, x2_, $f_]:=Table[Sum[$f[[a, b, c]]*(x1[[b]]x2[[c]]-x1[[c]]x2[[b]]), {b, 1, $N^2-1}, {c, b+1, $N^2-1}], {a, 1, $N^2-1}];


(* ::Input::Initialization:: *)
energy[tqpData_]:=Module[{q, p, cc}, (
q = tqpData[[2;;(Length[tqpData]+1)/2]];
p =tqpData[[1+(Length[tqpData]+1)/2;;]];

q =ArrayReshape[q, {$K, $N^2-1}];

{tqpData//First, 1/4 Total@(#^2&/@p) + 1/4 Sum[Total@(#^2&/@comm[q[[i]], q[[j]], $f]), {i, 1, $K}, {j, i+1, $K}]}
)];


(* ::Input::Initialization:: *)
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



