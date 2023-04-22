#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["./mathematica/lib/lib2.m"];
Get["./mathematica/lib/util.m"];


plotsDir= "./plots";
If[!DirectoryQ[plotsDir], CreateDirectory[plotsDir]];


liststd ={};
ReImstd = {};


Table[Module[{fn,data,matdata,mns,vars,Kval},Kval=9;
fn=FileNames[All,"./runs/Trials/N"<>ToString[Nval]<>"K"<>ToString[Kval]];
Print["Computing for N="<>ToString[Nval]];
data=Import[#]&/@fn;
Print["Changing N and K"];
(*data = {Import["../../runs/Trials/N3K5/37797394.dat"],Import["../../runs/Trials/N3K5/37797394.dat"]};*)
changeNK[Nval,Kval];
Print["cMat"];
matdata=(cMatOne/@#)&/@data;
Print["Computing Std"];
(*stdN =Around[Table[(1/StandardDeviation[$N/Sqrt[$N-1] Map[Diagonal,matdata[[d]][[All,2;;$K+1]],{2}]//Flatten])^2,{d,1,Length[matdata]}]];*)
reimlist =Table[Join[Flatten@Table[$N/Sqrt[$N-1] matdata[[d]][[All, 2;;, a, a]], {a, 1, $N}],Flatten@Table[Sqrt[2$N]ReIm@matdata[[d]][[All, 2;;, a, b]], {a, 1, $N}, {b, a+1, $N}];]//Chop,{d,1,Length[matdata]}];
(*reimlist =Table[Table[Table[Table[matdata[[d]][[m,k+1]][[i,j]],{i,1,3},{j,1,i-1}]//Flatten,{k,1,$K}]//Flatten,{m,1,Length[matdata[[1]]]}]//Flatten,{d,1,Length[matdata]}];*)
ristd  =Around[(1/(StandardDeviation/@reimlist))^2];
(*re =Around@ ((1/(StandardDeviation/@Re[reimlist]))^2);
im= Around@((1/(StandardDeviation/@Im[reimlist]))^2);
AppendTo[Restd,{Nval,re}];
AppendTo[Imstd,{Nval,im}];*)

(*Export["listStd.mx",liststd];*)


(*AppendTo[liststd,{Nval,stdN}];*)
AppendTo[ReImstd,{Nval,ristd}];

(*Export["listStd.mx",liststd];*)
Export["reImStd.mx",ReImstd];
Print["Computing COMPLETE for N="<>ToString[Nval]];],{Nval,3,9}];


pltmns=ListLinePlot[liststd,PlotLabel->"Std",PlotRange->All,AxesLabel->{"N","Standard Deviation"}]


Export[plotsDir<>"/Plot_of_Std_alpha.pdf",pltmns,ImageResolution->300,ImageSize->500];
