(* ::Package:: *)

BeginPackage["BFSS2`"];


<<VariationalMethods`;
Needs["DifferentialEquations`NDSolveProblems`"];
Needs["DifferentialEquations`NDSolveUtilities`"];


restylePlot::usage = "";

c::usage = "";

basisSU::usage = "";

fSU::usage = "";

indexSU::usage = "";

updateSU::usage = "";

changeNK::usage = "";

equateX::usage = "";

replaceX::usage = "";

randomInit::usage = "";

progress::usage = "";

randomInitZeroAM::usage = "";

FRadius::usage = "";

FEnergy::usage = "";

FEnergyOld::usage = "";

FAngularMomentum::usage = "";

FGauss::usage = "";

Lag::usage = "";

eqns1::usage = "";

FEOM::usage = "";

PleaseSolve::usage = "";

$N::usage = "";

$K::usage = "";

$WorkingPrecision::usage = "";

$basisSU::usage = "";

$fSU::usage = "";

$soln::usage = "";

ExportSolution::usage = "";

ImportRandomSolution::usage = "";


Begin["`Private`"];


$N = 2;

$K = 2;

$WorkingPrecision = 15;


$basisSU = Null;

$fSU = Null;

$soln = Null;


indexSU[t_]:=Module[{n, m}, (
	If[DiagonalMatrixQ[t], n=(FirstPosition[Diagonal[t], 0]//First)-1; Return[n^2-1, Module]];

	If[SymmetricMatrixQ[t], {n, m}=FirstPosition[t, _?(#!=0&)]//Sort[#, #1>#2&]&; Return[n^2-2(n-m)-1, Module]];

	If[AntisymmetricMatrixQ[t], {n, m}=FirstPosition[t, _?(#!=0&)]//Sort[#, #1>#2&]&;Return[n^2-2(n-m), Module]];
)];


updateSU[] :=
    Module[{n, A, B, C},
        (
            n = $N;
            A = I / 2 Flatten[Table[SparseArray[{{i, j} -> I, {j, i} 
                -> I}, {n, n}], {i, 1, n}, {j, i + 1, n}], 1];
            B = I / 2 Flatten[Table[SparseArray[{{i, j} -> -1, {j, i}
                 -> 1}, {n, n}], {i, 1, n}, {j, i + 1, n}], 1];
            C = I / Sqrt[2] DiagonalMatrix @* SparseArray /@ Orthogonalize[
                Table[SparseArray[{{i} -> I, {i + 1} -> -I}, {n}], {i, 1, n - 1}]];
            $basisSU = Join[A, B, C];
            $fSU = Table[-2 I Tr[$basisSU[[c]] . ($basisSU[[a]] . $basisSU
                [[b]] - $basisSU[[b]] . $basisSU[[a]])], {a, 1, $N^2 - 1}, {b, 1, $N^
                2 - 1}, {c, 1, $N^2 - 1}];
        )
    ];


updateSU[];


changeNK[$Nnew_, $Knew_] :=
    Module[{},
        (
            $N = $Nnew;
            $K = $Knew;
            updateSU[];
        )
    ];


basisSU[] :=
    $basisSU;


fSU[a_, b_, c_] :=
    $fSU[[a, b, c]];


equateX[x0_, xdot0_, x_, t_] :=
    Table[{x[k, a][t] == x0[[k, a]], x[k, a]'[t] == xdot0[[k, a]]}, {
        a, 1, $N^2}, {k, 1, $K}] // Flatten;


replaceX[x0_, xdot0_, x_, t_] :=
    Table[{x[k, a][t] -> x0[[k, a]], x[k, a]'[t] -> xdot0[[k, a]]}, {
        a, 1, $N^2}, {k, 1, $K}] // Flatten;


progress[P_] := Module[{size}, (
	size = Dimensions[P];
	
	If[Length[size]==1, Return[P[[1]]/P[[2]], Module]];
	
	If[Length[size]==2 && size[[2]]==2, 
		Return[
			(1 + Sum[(P[[\[Alpha], 1]]-1)Product[P[[\[Beta], 2]], {\[Beta], \[Alpha]+1, Length[P]}], {\[Alpha], 1, Length[P]}])
			/
			Product[P[[\[Beta], 2]], {\[Beta], 1, Length[P]}]
		, Module]
	, Return[Null]];
)];


restylePlot[plot_Graphics, styles_List, op : OptionsPattern[Graphics]
    ] :=
    Module[{x = styles},
        Show[MapAt[# /. {__, ln__Line} :> {Directive @ Last[x = RotateLeft
             @ x], ln}&, plot, 1], op]
    ];


c[A_, B_] :=
    A . B - B . A;

               (*varsToMatrix[x_, t_] :=
    Table[Table[X[k, a, b][t], {a, 1, $N}, {b, 1, $N}], {k, 1, $K}];*)

Options[randomInit] = {"Traceless" -> True};

randomInit[OptionsPattern[]] :=
    Module[{xx, f = OptionValue["Traceless"]},
        (
            xx = RandomReal[{-1, 1}, {2, $K, $N^2}, WorkingPrecision 
                -> $WorkingPrecision + 5];
            If[f,
                Map[ReplacePart[#, $N^2 -> 0]&, xx, {2}]
                ,
                xx
            ]
        )
    ];


randomInitZeroAM[] :=
    Module[{x, xd, xd1, j, g, y, t, eqns, soln},
        (
            x = Table[If[a == $N^2, 0, RandomReal[{-1, 1}, WorkingPrecision -> $WorkingPrecision
                 + 5]], {k, 1, $K}, {a, 1, $N^2}];
            xd =
                Table[
                    If[a == $N^2,
                        0
                        ,
                        xd1[k, a]
                    ]
                    ,
                    {k, 1, $K}
                    ,
                    {a, 1, $N^2}
                ];
            j = FAngularMomentum[y, t] /. replaceX[x, xd, y, t];
            g = FGauss[y, t] /. replaceX[x, xd, y, t];
            eqns = Join[Table[j[[k, l]] == 0, {l, 1, $K}, {k, 1, l - 
                1}] // Flatten, # == 0& /@ g];
            soln =
                NSolve[
                        eqns
                        ,
                        xd //
                        Flatten //
                        DeleteElements[#, {0}]&
                    ] // First;
            xd = Evaluate[(xd /. soln)] /. (Table[xd1[k, a] -> RandomReal[
                {-1, 1}, WorkingPrecision -> $WorkingPrecision + 5], {k, 1, $K}, {a, 
                1, $N^2 - 1}] // Flatten);
            {x, xd}
        )
    ];


    (*randomInitConstantEnergy[energy_] :=
    Module[{X, XH, e, r, p, soln},
        (
            X = Table[Table[RandomComplex[WorkingPrecision -> 20], {a,
                 1, $N}, {b, 1, $N}], {k, 1, 2 $K}];
            XH = Table[(X[[k]] + X[[k]]\[ConjugateTranspose]) / 2 - 1 / $N Tr[(X[[k]] + X
                [[k]]\[ConjugateTranspose]) / 2] * IdentityMatrix[$N], {k, 1, 2 $K}];
            r =
                Flatten[
                    Table[
                        {
                            X[k, a, b][t] -> XH[[k]][[a, b]]
                            ,
                            If[k != 1 && a != 1 && b != 1,
                                X[k, a, b]'[t] -> XH[[k + $K]][[a, b]]
                                    
                                ,
                                X[k, a, b]'[t] -> p
                            ]
                        }
                        ,
                        {k, 1, $K}
                        ,
                        {a, 1, $N}
                        ,
                        {b, 1, $N}
                    ]
                ];
            e = Evaluate[FEnergy[X, t] /. r];
            soln = Solve[e == energy, p] // First;
            soln
        )
    ];*) 


FRadius[x_, t_] :=
    Module[{},
        1 / 2 Sum[x[k, a][t] ^ 2, {k, 1, $K}, {a, 1, $N^2}]
    ];


FEnergyOld[x_, t_] :=
    Module[{p, preplace},
            (
                preplace = Table[p[k, a][t] -> D[Lag[x, t], x[k, a]'[
                    t]], {k, 1, $K}, {a, 1, $N^2}] // Flatten;
                (Sum[p[k, a][t] * x[k, a]'[t], {k, 1, $K}, {a, 1, $N^
                    2}] - Lag[x, t]) /. preplace
            )
        ] // Simplify;


FEnergy[x_, t_] :=
    Module[{},
            1 / 4 Sum[x[k, a]'[t] ^ 2, {k, 1, $K}, {a, 1, $N^2}] + 1 / 8 
            Sum[x[i, a][t] x[j, b][t] x[i, c][t] x[j, d][t] fSU[a, b, e] fSU[c, d,
             e], {i, 1, $K}, {j, 1, $K}, {a, 1, $N^2 - 1}, {b, 1, $N^2 - 1}, {c, 
            1, $N^2 - 1}, {d, 1, $N^2 - 1}, {e, 1, $N^2 - 1}]
        ];


FAngularMomentum[x_, t_] :=
                Table[Sum[x[k, a]'[t] * x[j, a][t] - x[j, a]'[t] * x[k,
                     a][t], {a, 1, $N^2}], {k, 1, $K}, {j, 1, $K}];


FGauss[x_, t_] :=
    Module[{},
            Table[Sum[x[i, a][t] x[i, b]'[t] fSU[a, b, c], {i, 1, $K},
                 {a, 1, $N^2 - 1}, {b, 1, $N^2 - 1}], {c, 1, $N^2 - 1}]
        ] // Simplify;


Lag[x_, t_] :=
    Module[{a, b, c, d, e, i, j, count = 0, l},(
        l = 1 / 4 Sum[x[k, a]'[t] ^ 2, {k, 1, $K}, {a, 1, $N^2}] - 1 / 8 
            (*Monitor[*)Sum[(*count++;*)x[i, a][t] x[j, b][t] x[i, c][t] x[j, d][t] fSU[a, b, e] fSU[c, d,
             e], {i, 1, $K}, {j, 1, $K}, {a, 1, $N^2 - 1}, {b, 1, $N^2 - 1}, {c, 
            1, $N^2 - 1}, {d, 1, $N^2 - 1}, {e, 1, $N^2 - 1}];(*,
            ProgressIndicator[count/($K^2($N^2-1)^5)]
            (*progress[{{i, $K}, {j, $K}, {a, $N^2-1}, {b, $N^2-1}, {c, $N^2-1}, {d, $N^2-1}, {e, $N^2-1}}]*)
            ];*)
        l
    )];


eqns1[x_, t_] :=
    EulerEquations[Lag[x, t], Table[x[i, a][t], {i, 1, $K}, {a, 1, $N
        ^2}] // Flatten, t] // Simplify;


FEOM[x_, t_] :=
    eqns1[x, t];


Options[PleaseSolve] = {"tStart" -> 0};
PleaseSolve[x0_, xdot0_, x_, {t_, T_}, OptionsPattern[]] :=
    Module[{time = 0, tStart = OptionValue["tStart"], sol = {}, c = 1},
        Monitor[
            NDSolve[
                    {eqns1[x, t], equateX[x0, xdot0, x, 0]} // Flatten
                        
                    ,
                    Table[x[k, a], {k, 1, $K}, {a, 1, $N^2}] // Flatten
                        
                    ,
                    {t, tStart, T}
                    ,
                        (*PrecisionGoal\[Rule]10,WorkingPrecision\[Rule]15,AccuracyGoal
                        
                       
                        
                        \[Rule]10,MaxSteps\[Rule]10^6,*)
                    Method -> {"SymplecticPartitionedRungeKutta", "DifferenceOrder"->2, "PositionVariables"-> Evaluate[Flatten@Array[x[#1, #2]&, {$K, $N^2}]]},
                    StartingStepSize -> 1/1000,
                    PrecisionGoal -> $WorkingPrecision - 5
                    ,
                    WorkingPrecision -> $WorkingPrecision
                    ,
                    AccuracyGoal -> $WorkingPrecision - 5
                    ,
                    MaxSteps -> Infinity
                    ,
                    StepMonitor :> (time = t)(*If[Mod[c, 10]==0, (c=c+1; AppendTo[sol, {t, SetPrecision[FRadius[x, t], 12]}]), c=c+1]*)
                ] // First
            ,
            (*ListPlot[sol, PlotRange->{{0, 100}, {0, 1000}}, Joined->True, ImageSize->Large]*)
            ProgressIndicator[time / T]
        ]
    ];


ExportSolution[solnt_] :=
    Module[{dir, filename},
        (
            dir = "./dumpsave/N" <> ToString[$N] <> "K" <> ToString[$K
                ];
            If[!DirectoryQ[dir],
                CreateDirectory[dir]
            ];
            $soln = solnt;
            filename = "n" <> ToString[$N] <> "k" <> ToString[$K] <> 
                "-" <> CreateUUID[] <> ".mx";
            DumpSave[dir <> "/" <> filename, $soln];
        )
    ];


ImportRandomSolution::nosol = "No solutions exist for these values of N and K";

ImportRandomSolution[x_] :=
    Module[{dir, files, file, varname},
        (
            dir = "./dumpsave/N" <> ToString[$N] <> "K" <> ToString[$K
                ];
            files = FileNames["*.mx", dir];
            If[Length[files] < 1,
                Message[ImportRandomSolution::nosol];
                Return[Null]
            ];
            file = files[[RandomInteger[{1, Length[files]}]]];
            Get[file];
            varname = (List @@ $soln)[[1, 1]] // Head;
            $soln = $soln /. {varname -> x};
            $soln
        )
    ];


End[];


EndPackage[];
