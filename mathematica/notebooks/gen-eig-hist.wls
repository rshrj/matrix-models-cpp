#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["../lib/lib2.m"];
Get["../lib/util.m"];

<<MaTeX`;

SetOptions[MaTeX,"Preamble"->{"\\usepackage{physics,mathtools}"}];
texStyle={FontFamily->"Latin Modern Roman",FontSize->12};
plotsDir = "../../plots/plots-103-hist";
If[!DirectoryQ[plotsDir], CreateDirectory[plotsDir]];

Print["importing data."];
data = Import["../../runs/Trials/N9K9/24788149.dat"];

changeNK[9, 9];

Print["converting to matrices."];
matdata = cMat @ data;

Print["computing eigenvalues of X1."];
eiglist = Flatten @ Table[Eigenvalues @ MatrixPower[matdata[[k, 2]], 
    2], {k, 1, Length[matdata]}];

Print["Generating the histogram and exporting it to "<>plotsDir<>"/hist-X2.pdf."];
plt1 =
    Histogram[
        eiglist2
        ,
        400
        ,
        "PDF"
        ,
        PlotRange -> All
        ,
        Frame -> True
        ,
        FrameStyle -> Black
        ,
        FrameLabel -> MaTeX[{"\\lambda", "\\rho"}]
        ,
        BaseStyle -> texStyle
        ,
        FrameTicks ->
            {
                {
                    With[{ticks = Range[0, 200, 50]},
                        Thread[{ticks, MaTeX[ticks, "DisplayStyle" ->
                             False]}]
                    ]
                    ,
                    None
                }
                ,
                {
                    With[{ticks = Range[0.0, 0.25, 0.05]},
                        Thread[{ticks, MaTeX[ticks, "DisplayStyle" ->
                             False]}]
                    ]
                    ,
                    None
                }
            }
        ,
        Axes -> False
        ,
        ImageSize -> 500
    ];

Export[plotsDir <> "/hist-X2.pdf", plt1];
