#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];

Get["../lib/lib2.m"];

Get["../lib/util.m"];


hasNan[data_] :=
    Module[{},
        (
            Do[
                If[AnyTrue[Head /@ data[[Length[data] - i + 1]], # ===
                     String&],
                    Return[True, Module];
                    Break[];
                ]
                ,
                {i, 1, Length[data]}
            ];
            Return[False, Module];
        )
    ];


If[!DirectoryQ["../../runs/Stats-SymmTraceSD"],
    CreateDirectory["../../runs/Stats-SymmTraceSD"]
];


Do[
    Print["N = " <> ToString @ $N <> ", K = " <> ToString @ $K];
    changeNK[$N, $K];
    
    dirname = "../../runs/Trials/N" <> ToString @ $N <> "K" <> ToString
         @ $K;
    files = FileBaseName /@ FileNames[All, dirname];
    
    Do[
        Print["Working on " <> files[[k]]];
        
        Print["Importing data"];
        data = Import[dirname <> "/" <> files[[k]] <> ".dat"];
        If[hasNan[data],
            Print["Detected nan, skipping"];
            Continue[]
        ];
        
        Print["Generating trX2 and trXiXj"];
        dataMat = cMat[data];
        trX2data = TrX2 /@ dataMat;
        trX2data = trX2data[[1001 ;; ]];
        raddata = radius /@ data;
        raddata = raddata[[1001 ;; ]];
        
        Print["Computing statistics"];
        meanRad = Mean[raddata[[All, 2]]];
        sdRad = StandardDeviation[raddata[[All, 2]]];
        meanTrX2 = Table[Mean @ trX2data[[All, 2, i, j]], {i, 1, $K},
             {j, 1, $K}];
        sdTrX2 = Table[StandardDeviation @ trX2data[[All, 2, i, j]], 
            {i, 1, $K}, {j, 1, $K}];
            
        Print["Writing to " <> "runs/Stats-SymmTraceSD/N" <> ToString[
            $N] <> "K" <> ToString[$K] <> ".dat"];
        out = Join[{files[[k]], meanRad, sdRad}, Flatten @ Table[{meanTrX2
            [[i, j]], sdTrX2[[i, j]]}, {i, 1, $K - 1}, {j, i, $K}]];
        statFile = OpenAppend["../../runs/Stats-SymmTraceSD/N" <> ToString[
            $N] <> "K" <> ToString[$K] <> ".dat"];
        WriteString[statFile, StringRiffle[ToString /@ out, "    "] <>
             "\n"];
        Close[statFile];
        ,
        {k, 1, Length[files]}
    ]
    ,
    {$N, 2, 9}
    ,
    {$K, 2, 10}
];
