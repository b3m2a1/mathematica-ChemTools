(* ::Package:: *)

$packageHeader

PackageScopeBlock[
	$ChemCustomAtoms::usage="";
	$ChemAtomColors::usage="";
	$ChemElements::usage="";
	$ChemSpaceGroups::usage="";
	$ChemBondDistances::usage="";
	$ChemElementValences::usage="";
	$ChemCharacterTables::usage="";
	$ChemTanabeSuganoData::usage="";
	$ChemMMMFF94AtomTypes::usage="";
	$ChemMMMFF94BondData::usage="";
	$ChemMMFF94BondAngleData::usage="";
	$ChemMMFF94StretchBendData::usage="";
	$ChemMMFF94TorsionAngleData::usage="";
	]


Begin["`Private`"];


If[!MatchQ[OwnValues[$ChemCustomAtoms],{_:>_Association?AssociationQ}],
	$ChemCustomAtoms:=
		$ChemCustomAtoms=
			Import@PackageFilePath["Resources","Datasets","ChemCustomAtoms.wl"]
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


$ChemTanabeSuganoData=.


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



