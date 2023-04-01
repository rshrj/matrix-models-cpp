#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["./mathematica/lib/lib2.m"];
Get["./mathematica/lib/util.m"];


plotsDir= "./plots";
If[!DirectoryQ[plotsDir], CreateDirectory[plotsDir]];


MeanData ={};
VarData ={};
Table[Module[{fn ,data,mns,vars,Kval},
Kval =9;
fn = FileNames[All,"../runs/Trials/N"<>ToString[Nval]<>"K"<>ToString[Kval]];

Print["Computing for N="<>ToString[Nval]];
data =Import[#]&/@fn;

Print["Changing N and K"];
changeNK[Nval,Kval];

matdata = cMat[#]&/@ data;

mnsraw = Table[ Mean[Tr[MatrixPower[#, n]]&/@matdata[[d]][[All, 2]]]//Chop//Re,{n,6,8},{d,1,Length[matdata]}];
mns = Around[#]&/@mnsraw;

varsraw =Table[ Variance[Tr[MatrixPower[#, n]]&/@matdata[[d]][[All, 2]]]//Chop//Re,{n,6,8},{d,1,Length[matdata]}];
vars=  Around[#]&/@varsraw;

AppendTo[MeanData,mnsraw];
AppendTo[VarData,varsraw];

Export["MeanData.mx",MeanData];
Export["VarData.mx",VarData];
Print["Computing COMPLETE for N="<>ToString[Nval]];]
,{Nval,2,4}];

Print["Exporting data"];
Export["MeanData.mx",MeanData];
Export["VarData.mx",VarData];


Print["Plotting"];
Print["Length of Mean data is MeanData"<>ToString[Length[MeanData]]];
xval = Range[2,Length[MeanData]];
pltmns = ListPlot[ Thread[{xval,#}]&/@MeanData,PlotLabel->"Plot of Mean as function on N",PlotLegends->SwatchLegend[Automatic,xval,LegendLabel->Placed["Tr[\!\(\*SuperscriptBox[\(X\),n]\)]; n = ",Above],LegendFunction->"Frame"],AxesLabel->{"N","Mean"}]
pltvars =ListPlot[ Thread[{xval,#}]&/@MeanData,PlotLabel->"Plot of Variance as function on N",PlotLegends->SwatchLegend[Automatic,xval,LegendLabel->Placed["Tr[\!\(\*SuperscriptBox[\(X\),n]\)]; n = ",Above],LegendFunction->"Frame"],AxesLabel->{"N","Variance"}];


Print["Exporting Plots"];
Export[plotsDir<>"/Plot_of_Means.pdf",pltmns,ImageResolution->300,ImageSize->500]
Export[plotsDir<>"/Plot_of_Vars.pdf",pltvars,ImageResolution->300,ImageSize->500]


Print["Program Completed"];
