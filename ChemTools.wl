(* ::Subsection::Closed:: *)
(*Temp Loading Flag Code*)


Temp`PackageScope`ChemToolsLoading`Private`$PackageLoadData=
  If[#===None, <||>, Replace[Quiet@Get@#, Except[_?OptionQ]-><||>]]&@
    Append[
      FileNames[
        "LoadInfo."~~"m"|"wl",
        FileNameJoin@{DirectoryName@$InputFileName, "Config"}
        ],
      None
      ][[1]];
Temp`PackageScope`ChemToolsLoading`Private`$PackageLoadMode=
  Lookup[Temp`PackageScope`ChemToolsLoading`Private`$PackageLoadData, "Mode", "Primary"];
Temp`PackageScope`ChemToolsLoading`Private`$DependencyLoad=
  TrueQ[Temp`PackageScope`ChemToolsLoading`Private`$PackageLoadMode==="Dependency"];


(* ::Subsection:: *)
(*Main*)


If[Temp`PackageScope`ChemToolsLoading`Private`$DependencyLoad,
  If[!TrueQ[Evaluate[Symbol["`ChemTools`PackageScope`Private`$LoadCompleted"]]],
    Get@FileNameJoin@{DirectoryName@$InputFileName, "ChemToolsLoader.wl"}
    ],
  If[!TrueQ[Evaluate[Symbol["ChemTools`PackageScope`Private`$LoadCompleted"]]],
    <<ChemTools`ChemToolsLoader`,
   BeginPackage["ChemTools`"];
   EndPackage[];
   ]
  ]