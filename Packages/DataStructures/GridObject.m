(* ::Package:: *)



CoordinateGridObject::usage=
  "An object-oriented interface into coordinate grid stuff";


Begin["`Private`"];


RegisterInterface[
  CoordinateGridObject,
  {"Grid"},
  "Validator"->
    CoordinateGridObjectQ,
  "Constructor"->
    ConstructCoordinateGrid,
  "MutationFunctions"->{"Keys"},
  "AccessorFunctions"->
    <|
      "Keys"->GridKeyPart, 
      "Parts"->GridPart
      |>,
  "NormalFunction"->(#["Grid"]&),
  "Protect"->True
  ]


(* ::Subsection:: *)
(*Properties*)



(* ::Subsubsection::Closed:: *)
(*Properties*)



InterfaceAttribute;


InterfaceAttribute[CoordinateGridObject]@
  g_CoordinateGridObject["Dimensions"]:=
    GridDimensions[g];


InterfaceAttribute[CoordinateGridObject]@
  g_CoordinateGridObject["Dimension"]:=
    GridDimension[g];


InterfaceAttribute[CoordinateGridObject]@
  g_CoordinateGridObject["MeshSpacings"]:=
    GridMeshSpacings[g];


InterfaceAttribute[CoordinateGridObject]@
  g_CoordinateGridObject["Points"]:=
    GridPoints[g];


(* ::Subsubsection::Closed:: *)
(*Methods*)



InterfaceMethod[CoordinateGridObject]@
  g_CoordinateGridObject["BuildFunction"][f_]:=
    GridCreateMapFunction[f, g];
InterfaceMethod[CoordinateGridObject]@
  g_CoordinateGridObject["Slice"][n__Integer]:=
    GridSlice[g, n];


(* ::Subsubsection::Closed:: *)
(*Overloads*)



InterfaceOverride[CoordinateGridObject]@
  Dimensions[g_CoordinateGridObject]:=
    GridDimensions[g];
InterfaceOverride[CoordinateGridObject]@
  Depth[g_CoordinateGridObject]:=
    GridDepth[g];
InterfaceOverride[CoordinateGridObject]@
  Map[f_, g_CoordinateGridObject]:=
    (*g["Grid"]=*)GridMap[f, g];
InterfaceOverride[CoordinateGridObject]@
  CoordinateBounds[g_CoordinateGridObject]:=
    GridBounds[g];
InterfaceOverride[CoordinateGridObject]@
  CoordinateBoundingBox[g_CoordinateGridObject]:=
    GridBoundingBox[g];
InterfaceOverride[CoordinateGridObject]@
  Permute[g_CoordinateGridObject, inds_]:=
    GridPermute[g, inds];
InterfaceOverride[CoordinateGridObject]@
  Transpose[g_CoordinateGridObject, inds___]:=
    GridTranspose[g, inds]


End[];



