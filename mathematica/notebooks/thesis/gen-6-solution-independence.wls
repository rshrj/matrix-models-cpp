#!/usr/bin/env wolframscript
(* ::Package:: *)

<<MaTeX`;


Get["../../lib/lib2.m"];
Get["../../lib/util.m"];


SetOptions[MaTeX,"Preamble"->{"\\usepackage{physics,mathtools,newtxtext,newtxmath}"}, FontSize->12];
SetOptions[$FrontEndSession,PrintingStyleEnvironment->"Working"];
texStyle={FontFamily->"Times",FontSize->12};


cm = 72/2.54;


plotsDir = "../../../plots/plots-thesis";
If[!DirectoryQ[plotsDir], CreateDirectory[plotsDir]];


Print["importing data 1"];


data[1] = Import["../../../runs/Trials/N9K9/12279703.dat"];
Print["importing data 2"];
data[2] = Import["../../../runs/Trials/N9K9/12279703.dat"];


changeNK[9, 9];


Print["computing matrices 1"];
cmatdata[1] = cMatOne/@data[1];


Print["computing matrices 2"];


cmatdata[2] = cMatOne/@data[2];


Print["computing eigenvalues 1"];
eig[1] = Flatten[Map[Eigenvalues, cmatdata[1][[All, 2;;]], {2}]];


Print["computing eigenvalues 2"];
eig[2] = Flatten[Map[Eigenvalues, cmatdata[2][[All, 2;;]], {2}]];


Print["drawing the histogram"];


fig[1] = Histogram[{eig[1], eig[2]}, 350, PDF,
Frame->True,
FrameStyle->Black,
BaseStyle->texStyle,
PlotTheme->"Scientific",
FrameLabel->MaTeX/@{"\\lambda", "\\rho"},
FrameTicks->{{With[{ticks=0.0+0.5Range[0,6]//Chop},Thread[{ticks,MaTeX[ticks,"DisplayStyle"->False]}]],None},{With[{ticks=-0.4+0.2Range[0,8]//Chop},Thread[{ticks,MaTeX[ticks,"DisplayStyle"->False]}]],None}},
ChartLegends->Placed[MaTeX/@{"\\text{a}", "\\text{b}"}, {Bottom, Bottom}],
PlotRange->All,
ImageSize->14cm
];


Export[plotsDir<>"/6-eig-sol-indep.pdf", fig[1]];
