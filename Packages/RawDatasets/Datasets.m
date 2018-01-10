(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



$ChemCustomAtoms::usage="";
$ChemIsotopicMasses::usage="";
$ChemAtomColors::usage="";
$ChemElements::usage="";
$ChemSpaceGroups::usage="";
$ChemBondDistances::usage="";
$ChemElementValences::usage="";
$ChemCharacterTables::usage="";
$ChemCorrelationTables::usage="";
$ChemTanabeSuganoData::usage="";
$ChemMMMFF94AtomTypes::usage="";
$ChemMMMFF94BondData::usage="";
$ChemMMFF94BondAngleData::usage="";
$ChemMMFF94StretchBendData::usage="";
$ChemMMFF94TorsionAngleData::usage="";


Begin["`Private`"];


If[!MatchQ[OwnValues[$ChemCustomAtoms],{_:>_Association?AssociationQ}],
	$ChemCustomAtoms:=
		$ChemCustomAtoms=
			Import@PackageFilePath["Resources","Datasets","ChemCustomAtoms.wl"]
	];


If[!MatchQ[OwnValues[$ChemIsotopicMasses],{_:>_Association?AssociationQ}],
	$ChemIsotopicMasses:=
		$ChemIsotopicMasses=
			Import@PackageFilePath["Resources","Datasets","ChemIsotopicMasses.wl"]
	];


If[!MatchQ[OwnValues[$ChemAtomColors],{_:>_Association?AssociationQ}],
	$ChemAtomColors:=
		$ChemAtomColors=
			Import@PackageFilePath["Resources","Datasets","ChemAtomColors.wl"]
	];


If[!MatchQ[OwnValues[$ChemElements],{_:>_Association?AssociationQ}],
	$ChemElements:=
		$ChemElements=
			Import@PackageFilePath["Resources","Datasets","ChemElements.wl"]
	];


If[!MatchQ[OwnValues[$ChemSpaceGroups],{_:>_Association?AssociationQ}],
	$ChemSpaceGroups:=
		$ChemSpaceGroups=
			Import@PackageFilePath["Resources","Datasets","ChemSpaceGroups.wl"];
	]


If[!MatchQ[OwnValues[$ChemBondDistances],{_:>_Association?AssociationQ}],
	$ChemBondDistances:=
		$ChemBondDistances=
			Import@PackageFilePath["Resources","Datasets","ChemBondDistances.wl"];
	];


If[!MatchQ[OwnValues[$ChemElementValences],{_:>_Association?AssociationQ}],
	$ChemElementValences:=
		$ChemElementValences=
			Import@PackageFilePath["Resources","Datasets","ChemElementValences.wl"];
	];


If[!MatchQ[OwnValues[$ChemCharacterTables],{_:>_Association?AssociationQ}],
	$ChemCharacterTables:=
		$ChemCharacterTables=
			Import@PackageFilePath["Resources","Datasets","ChemCharacterTables.wl"];
	];


If[!MatchQ[OwnValues[$ChemCorrelationTables],{_:>_Association?AssociationQ}],
	$ChemCorrelationTables:=
		$ChemCorrelationTables=
			Import@PackageFilePath["Resources","Datasets","ChemCorrelationTables.wl"];
	];


If[!MatchQ[OwnValues[$ChemTanabeSuganoData],{_:>_Association?AssociationQ}],
	$ChemTanabeSuganoData:=
		$ChemTanabeSuganoData=
			Import@PackageFilePath["Resources","Datasets","ChemTanabeSuganoDiagrams.wl"];
	];


If[!MatchQ[OwnValues[$ChemMMMFF94AtomTypes],{_:>_Association?AssociationQ}],
	$ChemMMMFF94AtomTypes:=
		$ChemMMMFF94AtomTypes=
			Import@PackageFilePath["Resources","Datasets","MMMFF94AtomTypes.wl"];
	];


If[!MatchQ[OwnValues[$ChemMMMFF94BondData],{_:>_Association?AssociationQ}],
	$ChemMMMFF94BondData:=
		$ChemMMMFF94BondData=
			Import@PackageFilePath["Resources","Datasets","MMFF94BondData.wl"];
	];


If[!MatchQ[OwnValues[$ChemMMFF94BondAngleData],{_:>_Association?AssociationQ}],
	$ChemMMFF94BondAngleData:=
		$ChemMMFF94BondAngleData=
			Import@PackageFilePath["Resources","Datasets","MMFF94BondAngleData.wl"];
	];


If[!MatchQ[OwnValues[$ChemMMFF94StretchBendData],{_:>_Association?AssociationQ}],
	$ChemMMFF94StretchBendData:=
		$ChemMMFF94StretchBendData=
			Import@PackageFilePath["Resources","Datasets","MMFF94StretchBendData.wl"];
	];


If[!MatchQ[OwnValues[$ChemMMFF94TorsionAngleData],{_:>_Association?AssociationQ}],
	$ChemMMFF94TorsionAngleData:=
		$ChemMMFF94TorsionAngleData=
			Import@PackageFilePath["Resources","Datasets","MMFF94TorsionAngleData.wl"];
	];


End[];


