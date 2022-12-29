#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["../lib/util.m"];

$f =Import["../../external/F/N"<>ToString[$N]<>".dat", "Table"]//Flatten//ArrayReshape[#, {$N^2-1, $N^2-1, $N^2-1}]&;

stateFiles = FileNames[All, "../../runs/Trials"];

msg = "";
Monitor[Do[Module[{stStr, pertStates, data, meanSize, \[Delta]S, \[Delta]SSD, tS, linearGrowth, lm, slope, linearFit, res, mainPlot, op}, (
msg = "";
If[$FrontEnd==Null, Print["A = "<>ToString[A]]];
stStr = FileNameTake@stateFiles[[A]];
pertStates = FileNames[All, stateFiles[[A]]];

msg = "Importing data";
If[$FrontEnd==Null, Print[msg]];
data  =Monitor[Table[Import[pertStates[[k]], "Table"], {k, 1, Length[pertStates]}], ProgressIndicator[(k-1)/(Length[pertStates]-1)]];

msg = "Computing mean size";
If[$FrontEnd==Null, Print[msg]];
meanSize = Module[{m, steps, xav, t, tSteps}, (
m = Dimensions[data][[1]];
tSteps = Dimensions[data][[2]];
steps = Dimensions[data][[3]];

t = data[[1, All, 1]];

xav = Monitor[Table[1/m Sum[data[[A, k, 2;;(steps-1)/2]], {A, 1, m}], {k, 1, tSteps}], ProgressIndicator[(k-1)/(tSteps-1)]];

Monitor[Table[{t[[k]],1/m Sum[1/2 Total@(#^2&/@(data[[A, k, 2;;(steps-1)/2]]-xav[[k]])), {A, 1, m}]}, {k, 1, tSteps}], ProgressIndicator[(k-1)/(tSteps-1)]]
)];

msg = "Computing characteristics";
If[$FrontEnd==Null, Print[msg]];
\[Delta]S=Mean@Log@(Select[meanSize, #[[1]]>100&][[All, 2]]);
\[Delta]SSD=StandardDeviation@Log@(Select[meanSize, #[[1]]>100&][[All, 2]]);
tS = First@SelectFirst[meanSize, Abs[Log[#[[2]]]-\[Delta]S]<\[Delta]SSD&];
linearGrowth={#[[1]], Log@#[[2]]}&/@Select[meanSize, -6<Log@#[[2]]<\[Delta]S-2&];
lm = LinearModelFit[linearGrowth, t, t];
slope = D[Normal[lm], t];

msg = "Plotting graphs";
If[$FrontEnd==Null, Print[msg]];
linearFit=Plot[lm[t], {t, -10, 500}, PlotStyle->{Dashed, Gray}];

res = SetPrecision[{tS, \[Delta]S, \[Delta]SSD, slope}, 3];

mainPlot=Show[{
ListLogPlot[meanSize,
PlotRange->{{0, 200}, All},
GridLines->{{tS}, None},
GridLinesStyle->Directive[Gray, Dashed, Thick],
PlotStyle->{Black},
Frame->True,
FrameLabel->{"t", "Mean Size (Log)"},
Epilog->{Text["\!\(\*SubscriptBox[\(t\), \(S\)]\) = "<>ToString@res[[1]]<>"\n\!\(\*OverscriptBox[SubscriptBox[\(\[Delta]\), \(S\)], \(_\)]\) = "<>ToString@res[[2]]<>"\n\!\(\*SubscriptBox[\(\[Sigma]\), \(\[Delta]\)]\) = "<>ToString@res[[3]]<>"\nslope = "<>ToString@res[[4]], {150, -10}]},
FrameTicks->{{Automatic, None}, {Join[{tS}, 50*Range[0, 4]], None}},
PlotLabel->stStr
],
linearFit
}];

msg = "Exporting graph";
If[$FrontEnd==Null, Print[msg]];
Export["../plots/"<>stStr<>".pdf", mainPlot, ImageResolution->300];

msg = "Exporting result";
If[$FrontEnd==Null, Print[msg]];
op=OpenAppend["../stats.dat"];
WriteString[op, StringRiffle[Join[{stStr}, ToString/@res], "    "]<>"\n"];
Close[op];

msg = "";
)], {A, 1, Length[stateFiles]}],
"A = "<>ToString@A<>"\n"<>msg];
