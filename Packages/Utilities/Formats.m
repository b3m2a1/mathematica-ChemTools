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



(* ::Subsubsection::Closed:: *)
(*Formats*)



ChemUtilsDetectMolFormat::usage=
	"Detects a molecule format";
ChemUtilsGenerateZMatrix::usage=
	"Turns a list of atom-coordinate pairs into a ZMatrix";
ChemUtilsEnumerateZMatrixStrings::usage=
	"Enumerates and cleans ZMatrix strings";
ChemUtilsGenerateMolTable::usage=
	"Turns a ZMatrix into a list of atoms-coordinate pairs";
ChemUtilsGenerateMolRules::usage="Generates rules for a MOL file";
ChemUtilsGenerateMolString::usage="Converts atom list into MOL or SDF string";


Begin["`Private`"];


(* ::Subsection:: *)
(*Conversion Utils*)



(* ::Subsubsection::Closed:: *)
(*DetectMolFormat*)



ChemUtilsDetectMolFormat[s_String]:=
	Which[
		StringStartsQ[s,"InChI"],
			"InChI",
		Length@StringCases[s,"\n"]===0,
			"SMILES",
		Length@StringCases[s,"M  END"]===1,
			"MOL",
		Length@StringCases[s,"M  END"]>1,
			"SDF",
		StringStartsQ[StringTrim[s], LetterQ..~~(Whitespace|"")~~"\n"],
			"ZMatrix",
		True,
			$Failed
		];
ChemUtilsDetectMolFormat[l_List]:=
	Switch[l,
		{
			Optional[{_Integer,_Integer},{0,0}],
			{_String,_List,___}..,
			{_Integer,_Integer,___}...
			},
			"MOL",
		{
			{_String},
			{_String, _Integer, __?NumericQ}...
			},
			"ZMatrix",
		{
			Repeated[{
				Optional[{_Integer,_Integer},{0,0}],
				{_String,_List,___}..,
				{_Integer,_Integer,___}...
				}]
			},
			"SDF",
		{
			Repeated[_->{__List}]
			},
			"SDFRules",
		{
			Repeated[_->_List]
			},
			"MOLRules",
		_,
			$Failed
		]


(* ::Subsubsection::Closed:: *)
(*GenerateZMatrix*)



zmNorm=
	Function[{crd1,crd2},
		Norm[crd2-crd1]
		];
zmVAngle=
	Function[{crd1,crd2,crd3},
		VectorAngle[
			crd2-crd3,
			crd2-crd1
			](**180/\[Pi]*)
		];
zmDAngle=
	Function[{crd1,crd2,crd3,crd4},
		With[{caxis=crd3-crd2},
			VectorAngle[
				Cross[crd4-crd3,caxis],
				Cross[crd2-crd1,-caxis]
				](**180/\[Pi]*)
			]
		];


zmatrixEntry[atom_,previousAtoms_]:=
	Switch[Length@previousAtoms,
		0,
			{First@atom},
		1,
			{First@atom,
				1,zmNorm[
						Last@atom,
						Last@previousAtoms[[-1]]
						]
				},
		2,
			{First@atom,
				2,zmNorm[
						Last@atom,
						Last@previousAtoms[[-1]]
						],
				1,zmVAngle[
						Last@atom,
						Last@previousAtoms[[-1]],
						Last@previousAtoms[[-2]]
						]
				},
		_,
			{First@atom,
				Length@previousAtoms,
					zmNorm[
						Last@atom,
						Last@previousAtoms[[-1]]
						],
				Length@previousAtoms-1,
					zmVAngle[
						Last@atom,
						Last@previousAtoms[[-1]],
						Last@previousAtoms[[-2]]
						],
				Length@previousAtoms-2,
					zmDAngle[
						Last@atom,
						Last@previousAtoms[[-1]],
						Last@previousAtoms[[-2]],
						Last@previousAtoms[[-3]]
						]
				}
		];


ChemUtilsGenerateZMatrix[atoms_List]:=
	MapIndexed[zmatrixEntry[#,Take[atoms,First@#2-1]]&,atoms]


(* ::Subsubsection::Closed:: *)
(*EnumerateZMatrixStrings*)



ChemZMatrixStringVarRules[s_String]:=
	With[{
		main=
			Map[
				#[[1]]->
					Replace[Rest[#],
						{
							{main_, step_, inc_}:>
								Map[ToString,
									ToExpression[main]+Range[0, ToExpression[step]]*ToExpression[inc]
									]
							}
						]&,
				Map[StringSplit]@StringSplit[s, "\n"]
				]
		},
		Map[Thread[Keys@main->#]&, Tuples[Values@main]]
		]


ChemUtilsPreCleanZMatrixString[s_String]:=
	Fold[
		#2[#]&,
		s,
		{
			StringTrim, 
			StringDelete[StartOfString~~"!"~~(Except["\n"]...)~~"\n"],
			StringDelete[Longest["!"~~(Except["\n"]...)]],
			StringDelete[StartOfLine~~(Except["\n", Whitespace])],
			StringDelete[(Except["\n", Whitespace])~~EndOfLine],
			StringReplace[Repeated["\n", {2, \[Infinity]}]->"\n\n"]
			}
		];


ChemUtilsEnumerateZMatrixStrings[s_String]:=
	Module[
		{
			main=
					ChemUtilsPreCleanZMatrixString[s],
			bits,
			bonds=""
			},
		bits=
			StringTrim/@
				ReplaceAll[
					StringSplit[
						StringSplit[
							main, 
							"\n\n"|("\n"~~Except[WhitespaceCharacter]..~~":")
							],
						"\n"~~n:NumberString:>"JoinMe!"->n,
						2
						],
					{
						{
							{m_String}, {vars___String, "JoinMe!"->n_, bonds_String}
							}|
						{
							{m_String}, {vars___String},{b1___String, "JoinMe!"->n_, b2_String}
							}:>
								{
									m,
									vars,
									b1<>"\n"<>n<>b2
									},
						{{m_String}, {vars__String}}:>
							{m, vars}
						}
					];
		If[Length@bits>1&&StringStartsQ[Last@bits, NumberString],
			bonds=Last@bits;
			bits=Most@bits
			];
		StringTrim@
			Switch[Length@bits,
				1,
					bits<>"\n\n"<>bonds,
				2,
					Map[
						StringReplace[
							bits[[1]], 
							#
							]<>"\n\n"<>bonds&,
						ChemZMatrixStringVarRules@bits[[2]]
						],
				_,
					MapThread[
						StringReplace[
							bits[[1]], 
							Join[##]
							]<>"\n\n"<>bonds&,
						Map[ChemZMatrixStringVarRules, Rest@bits]
						]
				]
		]


(* ::Subsubsection::Closed:: *)
(*GenerateMolTable*)



Clear[molTableNormed, molTableVAngled, molTableDAngled]


(* ::Text:: *)
(*Should extend this to generate ZMatrices that aren\[CloseCurlyQuote]t centered at (0, 0, 0) but will do that another day*)



(* ::Subsubsubsection::Closed:: *)
(*molTableNormed*)



(* ::Text:: *)
(*
	First type:
		Simply place it at a normed distance away from a point
*)



molTableNormed[crd1_, norm_]:=
	crd1+{norm, 0, 0}


(* ::Subsubsubsection::Closed:: *)
(*molTableVAngled*)



(* ::Text:: *)
(*
	Second type:
		Place the normed version at an angle
*)



molTableVAngled[crd1_, crd2_, norm_, angle_]:=
		crd1+
			RotationMatrix[
				angle,
				With[{c=Cross[crd2-crd1, {1, 0, 0}]},
					If[c=={0, 0, 0}, 
						Cross[crd2-crd1, {0, 1, 0}],
						c
						]
					]
				].(norm*Normalize[crd2-crd1])


(* ::Subsubsubsection::Closed:: *)
(*molTableDAngled*)



(* ::Text:: *)
(*
	Third type:
		Place the normed version at an angle and then do the dihedral transform preserving these
*)



ChemUtilsGenerateMolTable::colin=
	"Coordinates ``, ``, and `` are collinear. \
Z axis will be used for dihedral";


molTableDAngled[crd1_, crd2_, crd3_, norm_, angle_, dangle_]:=
	Module[
		{
			ax21=crd2-crd1, 
			ax31=crd3-crd1,
			normalVec,
			baseVec,
			dihedAxis
			},
		normalVec=Cross[ax21, ax31];
		If[normalVec=={0, 0, 0},
			Message[ChemUtilsGenerateMolTable::colin, crd1, crd2, crd2];
			normalVec=Cross[ax21, {0, 0, 1}]
			];
		If[normalVec=={0, 0, 0}, normalVec=Cross[ax21, {0, 1, 0}]];
		baseVec=
			RotationMatrix[angle, normalVec].(norm*Normalize[ax21]);
		crd1+
			RotationMatrix[dangle, ax21].baseVec
		];


(* ::Subsubsubsection::Closed:: *)
(*molTableEntry*)



molTableEntry[line_, previousAtoms_]:=
	Switch[{line, Length@previousAtoms},
		{{_String, _?NumericQ, _?NumericQ, _?NumericQ}, _},
			{line[[1]], line[[2;;4]]},
		{_, 0}|{{_String}, _},
			{line[[1]], {0.,0.,0.}},
		{{_String, 1, __}, 1}|
			{{_String, _Integer, _?NumericQ}, _Integer?(#>=line[[2]]>0&)},
			{
				line[[1]],
				With[{crd1=previousAtoms[[line[[2]], 2]], n=line[[3]]},
					molTableNormed[crd1, n]
					]
				},
		{{_String, 1|2, _, 1|2, __}, 2}|
			{
				{_String, _Integer, _?NumericQ, _Integer, _?NumericQ}, 
				_Integer?(#>=Max@{line[[2]], line[[4]], 0}&)
				},
			{line[[1]],
				With[
					{
						crd1=previousAtoms[[line[[2]],2]],n=line[[3]],
						crd2=previousAtoms[[line[[4]],2]],a=line[[5]]
						},
					molTableVAngled[
						crd1, crd2,
						n, a
						]
					]
				},
		{
			{_String, _Integer, _?NumericQ, _Integer, _?NumericQ, _Integer, _?NumericQ}, 
			_Integer?(#>=Max@{line[[2]], line[[4]], line[[6]], 0}&)
			},
			{line[[1]],
				With[
					{
						crd1=previousAtoms[[line[[2]], 2]],n=line[[3]],
						crd2=previousAtoms[[line[[4]], 2]],a=line[[5]],
						crd3=previousAtoms[[line[[6]], 2]],d=line[[7]]
						},
					molTableDAngled[
						crd1, crd2, crd3,
						n, a, d
						]
					]
				},
		_,
			$Failed
		];


ChemUtilsGenerateMolTable[zmMatrix:{{_String},___List}]:=
	Fold[
		Append[#, molTableEntry[Take[#2, UpTo[7]], #]]&,
		{},
	 zmMatrix
	 ]


(* ::Subsubsection::Closed:: *)
(*GenerateMolRules*)



ChemUtilsGenerateMolRules[
	molTable:{
		Optional[{_Integer,_Integer},{0,0}],
		atoms:{_String,_List,___}..,
		bonds:{_Integer,_Integer,___}...
		}
	]:=
	{
		"VertexTypes"->{atoms}[[All,1]],
		"VertexCoordinates"->{atoms}[[All,2]],
		"EdgeRules"->
			Rule@@@{bonds}[[All,;;2]],
		"EdgeTypes"->
			Replace[{bonds}[[All,-1]],
				{
					1->"Single",
					2->"Double",
					3->"Triple",
					_->"Single"
					},
				1
				],
		"FormalCharges"->
			Replace[{atoms},{{_,_,_,c_}:>c,_->0},1]
		}


ChemUtilsGenerateMolRules[
	molTables:{
		Repeated@
			{
				Optional[{_Integer,_Integer},{0,0}],
				{_String,_List,___}..,
				{_Integer,_Integer,___}...
				}
		}
	]:=
	Thread[
		{"VertexTypes","VertexCoordinates",
			"EdgeTypes","EdgeRules","FormalCharges"}->
		Lookup[
			ChemUtilsGenerateMolRules/@molTables,
			{"VertexTypes","VertexCoordinates",
				"EdgeTypes","EdgeRules","FormalCharges"}
			]
		]


ChemUtilsGenerateMolRules[
	zm_List?(ChemUtilsDetectMolFormat[#]==="ZMatrix"&)
	]:=
	ChemUtilsGenerateMolRules@
		ChemUtilsGenerateMolTable[zm]


(* ::Subsubsection::Closed:: *)
(*GenerateMolString*)



ChemUtilsGenerateMolString[
	molTable:
		{
			Optional[{_Integer,_Integer},{0,0}],
			{_String,_List,___}..,
			{_Integer,_Integer,___}...
			}
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[
			ChemUtilsGenerateMolRules[molTable],
			{"MOL","Rules"}
			];
ChemUtilsGenerateMolString[
	molTables:{
		Repeated@
			{
				Optional[{_Integer,_Integer},{0,0}],
				{_String,_List,___}..,
				{_Integer,_Integer,___}...
				}
		}
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[
			ChemUtilsGenerateMolRules[molTables],
			{"SDF","Rules"}
			]
ChemUtilsGenerateMolString[
	zm_List?(ChemUtilsDetectMolFormat[#]==="ZMatrix"&)
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[
			ChemUtilsGenerateMolRules@zm,
			{"MOL","Rules"}
			];
ChemUtilsGenerateMolString[
	mol_List?(OptionQ[#]&&ChemUtilsDetectMolFormat[#]==="MOLRules"&)
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[mol,{"MOL","Rules"}];
ChemUtilsGenerateMolString[
	mol_List?(OptionQ[#]&&ChemUtilsDetectMolFormat[#]==="SDFRules"&)
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[mol,{"SDF","Rules"}];


End[];



