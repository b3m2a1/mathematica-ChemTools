(* ::Package:: *)

$packageHeader

CharacterTable::usage="Storage class for character table data";
CharacterTableData::usage="Looks up char table data";
CharacterTableSymmetryFunctions::usage=
	"Determines the functions that describe the symmetry classes";
CharacterTableSymmetryFunctionsFormatted::usage="";


CharacterTableRepresentationMatrices::uages=
	"Builds representation matrices for a given basis set";


CharacterTableReducibleRepresentationsList::usage=
	"";
CharacterTableReducibleRepresentationsGrid::usage=
	"Formats a grid for the reducible reps";


CharacterTableTotalRepresentation::usage=
	"Computes the total of a representation list";
CharacterTableReduceRepresentation::usage=
	"Reduces a reducible representation in a character table's irreps";


CharacterTableFormatReducedRepresentation::usage=
	"Displays an association of irreps as a sum";


CharacterTableModeRepresentations::usage=
	"Represents the translational, vibrational, and rotational irreps";


CharacterTableFindIrreducibleRepresentation::usage="";


CharacterTableSymmetryAdaptedProjection::usage=
	"Applies a SALC-type projection"
CharacterTableSALCs::usage=
	"Generates the symmetry adapted linear combinations of whatever coordinates are supplied";
CharacterTableFormatSALCs::usage=
	"Formats SALCs for readbility";


CharacterTableActiveIrreducibleRepresentations::usage=
	"Extracts the active irreps for a type of spectroscopy";


ChemUtilsVibrationalCoordinates::usage=
	"Determines bend-stretch-wag coordinates for a collection of atoms";
AtomsetVibrationalCoordinates::usage=
	"Determines bend-stretch-wag coordinates for an atomset";
ChemUtilsVibrationalCoordinateGraphics::usage=
	"Generates graphics for the vibrational coordinates";


AtomsetVibrationalAnalysis::usage=
	"A kitchen sink function for vibrational analyses";


ElectronConfiguration::usage=
	"Symbolic wrapper for an electron configuration";
(*ElectronOrbitalConfiguration::usage=
	"Symbolic wrapper for an orbital inside an electron configuration";*)
ElectronConfigurationData::usage=
	"Returns a collection of properties for a configuration";
ElectronConfigurationOctahedralField::usage=
	"A wrapper representing an octahedral field, changing how the configuration is read";
ElectronConfigurationGraphics::usage=
	"Plots an electron configuration";


TanabeSuganoData::usage="Extracts the Tanabe-Sugano data for a d-electron count";
TanabeSuganoDiagram::usage="A Tanabe-Sugano diagram for the given d-electron count";
TanabeSuganoDiagramInteractive::usage="An interactive Tanabe-Sugano Diagram";


Begin["`Private`"];


(* ::Subsection:: *)
(*Character Table Data*)



(* ::Subsubsection::Closed:: *)
(*URL Import*)



(*normalizeCTName[ct_]:=
	Replace[
		Capitalize@ToLowerCase@
			StringDelete[
				StringJoin@ReplaceAll[ct,Subscript|SubscriptBox\[Rule]List],
				Whitespace
				],
		HoldPattern[Capitalize[s_]]:>
			ToUpperCase[StringTake[s,1]]<>StringDrop[s,1]
		]*)


(*CharacterTableURL[ct_]:=
	Switch[ct,
		"T",
			"http://symmetry.jacobs-university.de/cgi-bin/group.cgi?group=900&option=4",
		"Th",
			"http://symmetry.jacobs-university.de/cgi-bin/group.cgi?group=901&option=4",
		"O",
			"http://symmetry.jacobs-university.de/cgi-bin/group.cgi?group=903&option=4",
		_,
			TemplateApply[
				"http://www.webqc.org/printable-symmetrypointgroup-ct-``.html",
				ToLowerCase@ct
				]
		]*)


(*CharacterTableRawData[ct_String?(StringContainsQ["/"])]:=
	If[StringStartsQ[ct, "http://www.webqc.org/"(*|"http://symmetry.jacobs-university.de"*)], 
		CharacterTableCleanRawData, 
		Identity
		]@
		Map[
			If[StringStartsQ[ct, "http://www.webqc.org/"|"http://symmetry.jacobs-university.de"],
				Map[
					StringDelete[
						StringJoin@
							System`Convert`HTMLImportDump`SymbolicXML2Text@#,
						Except["\n", Whitespace]
						]&,
					ReplaceAll[#[[3]],
						{
							XMLElement["img",{"src"\[Rule]"/pics/epsilon.gif"},{}]\[Rule]"\[CurlyEpsilon]",
							XMLElement["img",{"src"\[Rule]"/pics/sigma.gif"},{}]\[Rule]"\[Sigma]"
							}
						]
					]&,
				Identity
				],
			Cases[
						Import[ct,{"HTML","XMLObject"}],
						XMLElement["table", __],
						\[Infinity]
						][[
				Which[
					StringStartsQ[ct, "http://www.webqc.org/"],
						Sequence@@{2, 3},
					StringStartsQ[ct, "http://symmetry.jacobs-university.de"],
						Sequence@@{2, 3},
					True,
						All
					]
				]]
			];
CharacterTableRawData[ct_]:=
		CharacterTableRawData@CharacterTableURL@ct*)


(*CharacterTableCleanRawData[tdata_]:=
	Module[{
		trueTab=
			ConstantArray[None,
				Length@tdata+
					Length@Select[Rest@tdata, StringContainsQ["\n"][#[[2]]]&]
				],
		rowFillCounter=2,
		splitRow,
		boxLen=Length@tdata[[1]]
		},
		trueTab[[1]]=tdata[[1]];
		Map[
			If[StringContainsQ["\n"][#[[2]]],
				splitRow=StringSplit[#,"\n"]&/@#;
				With[{maxLen=Max@Append[Map[Length,splitRow],0]},
					Do[
						(* populate the final row *)
						trueTab[[rowFillCounter++]]=
							Map[
								(* check how many elements it has *)
								Switch[Length[#],
									maxLen,
										#[[i]],
									1,
										#[[1]]<>ToString[i],
									_,
										Null
									]&,
							Take[PadRight[splitRow, boxLen, ""], boxLen]
							],
						{i, maxLen}
						]
					],
				trueTab[[rowFillCounter++]]=
					PadRight[#, boxLen, ""]
				]&,
			Rest@tdata
			];
		trueTab
		]*)


(*If[!AssociationQ@$CharacterTables, $CharacterTables=<||>];
CharacterTableImport[ct_]:=
	With[{nm=normalizeCTName@ct},
		Lookup[$CharacterTables,nm,
			$CharacterTables[nm]=
				<|
					"PointGroup"\[Rule]nm,
					"SymmetryClasses"\[Rule]#[[1, 2;;Length[#] ]],
					"IrreducibleRepresentations"\[Rule]
						#[[2;;, 1 ]],
					"CharacterTable"->
						Map[Quiet[Check[ToExpression[#],#]]&, #[[2;;, 2;;Length[#] ]]],
					"Others"->
						AssociationThread[
							#[[1, 1+Length[#];; ]],
							Transpose@#[[2;;, 1+Length[#];; ]]
							]
					|>&@CharacterTableRawData@nm
			]
		]*)


(* ::Subsubsection::Closed:: *)
(*PG Ent*)



CharacterTablePointGroupEnt[ct_]:=
	Entity["FiniteGroup",
		{
			"CrystallographicPointGroup", 
			$pointGroupMap@
				normalizeCTName@ct
			}
		]


$CharacterTableKeys=
	{
		"PointGroup",
		"SymmetryClasses",
		"IrreducibleRepresentations",
		"CharacterTable",
		"LinearFunctions",
		"NonLinearFunctions"
		};


$pointGroupEntityMap=
	<|
		"C1"->1,"Ci"->2,"C2"->3,"Cs"->4,"C2h"->5,"D2"->6,"C2v"->7,
		"D2h"->8,"C4"->9,"S4"->10,"C4h"->11,"D4"->12,"C4v"->13,
		"D2d"->14,"D4h"->15,"C3"->16,"S6"->17,"D3"->18,"C3v"->19,
	 "D3d"->20,"C6"->21,"C3h"->22,"C6h"->23,"D6"->24,"C6v"->25,
		"D3h"->26,"D6h"->27,"T"->28,"Th"->29,"O"->30,
		"Td"->31,"Oh"->32,"Ih"->"Icosahedral"
		|>;


(* ::Subsubsection::Closed:: *)
(*CharacterTable Object*)



$charTables=
	{
		"Cs","Ci","C1","C2","C3","C4","C5","C6","C7","C8",
		"D2","D3","D4","D5","D6",
		"C2h","C3h","C4h","C5h","C6h",
		"C2v","C3v","C4v","C5v","C6v","Civ",
		"D2d","D3d","D4d","D5d","D6d",
		"D2h","D3h","D4h","D5h","D6h","D8h","Dih",
		"S4","S6","S8",
		"T","Th","Td",
		"O","Oh",
		"I","Ih",
		"K","Kh"
		};


CharacterTableGrid[data_]:=
	Grid[
		Prepend[
			Prepend[
				data["SymmetryClasses"][[All, "Formatted"]],
				data["PointGroup", "Formatted"]
				]
			]@
		MapThread[
			Prepend,
			{
				data["CharacterTable"],
				data["IrreducibleRepresentations"][[All, "Formatted"]]
				}
			],
		Alignment->Right,
		Dividers->{{2->Black},{2->Black}}
		];


CharacterTable[data_Association][k__]:=
	data[k]
CharacterTable[pg_String]:=
	CharacterTable@$ChemCharacterTables[pg];
CharacterTable/:Normal[CharacterTable[data_Association]]:=
	data;
CharacterTable/:Part[CharacterTable[data_Association], i__]:=
	Replace[{i},{
		{s_String}:>
			CharacterTableData[CharacterTable@data,
				{"IrreducibleRepresentation", s},
				"Vector"
				],
		{s_String, e__}:>
			CharacterTableData[CharacterTable@data,
				{"IrreducibleRepresentation", s},
				"Vector"
				][[e]],
		_:>
			data["CharacterTable"][[i]]
		}];
CharacterTable/:Dataset[CharacterTable[data_Association]]:=
	Dataset@data;


Format[CharacterTable[data_Association]]:=
	RawBoxes@TemplateBox[
		ToBoxes/@{data, CharacterTableGrid[data]},
		"CharacterTable",
		InterpretationFunction:>
			Function[
				RowBox@{"CharacterTable","[",#,"]"}
				],
		DisplayFunction:>
			Function[
				StyleBox[
					RowBox@{
						"CharacterTable",
						"[",
						PanelBox[
							#2,
							Appearance->{
								"Default"->
									FrontEnd`FileName[{"Typeset", "SummaryBox"}, "Panel.9.png"]
								}
							],
						"]"
						},
					ShowStringCharacters->False
					]
				],
		Editable->False,
		Selectable->False
		];


(* ::Subsubsection::Closed:: *)
(*Char Tab Data Import*)



charTabImportExcel[f_]:=
MapThread[
#->
Check[
DeleteCases[{"","",__,__Real?(FractionalPart[#]>0&),___}]@
Rest@SplitBy[#2,MatchQ[{""..}]][[3]],
$Failed
]&,
Rest/@
Import[f,
{"XLS",{"Sheets","Data"}}
]
]//Association;


(*Global`map=charTabImportExcel["~/Downloads/ed300281d_si_001.xls"];*)


charTabParsePG[pg_]:=
	With[{
		pgMain=
			First@
				StringReplace[StringReplace[pg,"i"->"\[Infinity]"],
					t:LetterCharacter~~
					n:(DigitCharacter...|"\[Infinity]")~~
					modifiers___:>
					<|
						"ID"->pg,
						"Type"->t,
						"Order"->
							If[StringLength[n]>0,
								ToExpression[n],
								None
								],
						"Modifier"->modifiers
						|>
					]
			},
		Append[pgMain,
			"Formatted"->
			Style[
				With[{
						t=pgMain["Type"],
						o=pgMain["Order"],
						m=pgMain["Modifier"]
						},
					If[o=!=None||StringLength[m]>0,
						Subscript[t,
							Row@{Replace[o,None:>Sequence@@{}],m}
							],
						t
						]
					],
				ShowStringCharacters->False
				]
			]
		]


charTabParseCl[cl_]:=
	Map[
		With[{
				coreData=
					First@
						StringReplace[#,
							{
								StartOfString~~(counts:DigitCharacter...)~~t:Except[DigitCharacter]~~
									n:(DigitCharacter...|"\[Infinity]")~~
										modifiers___~~EndOfString:>
								<|
								"Type"->t,
								"ID"->#,
								"Order"->
									If[StringLength@n>0,
										ToExpression@
											If[StringLength@n>1&&StringTake[n, {-1}]=!="0",
												StringTake[n,{1, -2}],
												n
												],
										1
										],
								"Degree"->
									If[StringLength@n>1&&StringTake[n, {-1}]=!="0",
										ToExpression@StringTake[n,{-1}],
										1
										],
								"Count"->
									If[StringLength@counts>0,
										ToExpression[counts],
										1
										],
								"Orientation"->
									If[StringStartsQ[modifiers, ("h"|"v"|"d")],
										StringTake[modifiers, {1}],
										""
										],
								"Modifier"->
									If[StringMatchQ[modifiers,"(=*"],
										"",
										If[StringStartsQ[modifiers, ("h"|"v"|"d")],
											StringTake[modifiers, {2,-1}],
											modifiers
											]
										]
								|>
								}
							]
				},
			Append[coreData,
				"Formatted"->
					Style[
						Row@{
							coreData["Count"]*
							Replace[
								{
									Replace[coreData["Orientation"],
										""->coreData["Order"]
										],
									coreData["Degree"]
									},
								{
									{1,1}:>coreData["Type"],
									{1,n_}:>Superscript[coreData["Type"],n],
									{n_,1}:>Subscript[coreData["Type"],n],
									{n_,m_}:>Superscript[Subscript[coreData["Type"],n],m]
									}
								],
							coreData["Modifier"]
							},
						ShowStringCharacters->False
						]
				]
			]&,
		cl
		]


charTabParseIR[ir_]:=
	Map[
		With[{
				coreData=
					First@
						StringReplace[#,
							{
								t:Except[DigitCharacter]~~
								index:(DigitCharacter...|"\[Infinity]")~~
								parity:"g"|"u"|""~~
								modifiers___:>
								<|
									"ID"->#,
									"Type"->t,
									"Index"->
									If[StringLength@index>0,
										ToExpression@index,
										0
										],
									"Parity"->parity,
									"Modifier"->modifiers
									|>
								}
							]
				},
			Append[coreData,
				"Formatted"->
					Style[
						Row@{
							Replace[
								{
									coreData["Index"],
									coreData["Parity"]
									},
								{
									{0,""}:>coreData["Type"],
									{0,n_}:>Subscript[coreData["Type"],n],
									{n_,0}:>Subscript[coreData["Type"],n],
									{n_,m_}:>Subscript[coreData["Type"],Row@{n,m}]
									}
								],
							coreData["Modifier"]
							},
						ShowStringCharacters->False
						]
				]
			]&,
		ir
		]


charTabParseCT[pgData_, ct_, cl_]:=
	Quiet@
		Map[
			Map[
				If[StringQ@#,
					Replace[
						With[{clean=
							FixedPoint[
								StringReplace[{
										"\.bd"->"(1/2)",
										"\[CurlyEpsilon]":>TemplateApply["Exp[2*Pi*I/``]",pgData["Order"]],
										"*"->"\[Conjugate]",
										"cos"~~arg:Except["+"]..:>
											"Cos["<>arg<>"]",
										"\[CapitalPhi]"->"\[FormalCapitalPhi]"
										}],
								#
								]
							},
							Check[
								ToExpression@clean,
								Echo[clean]
								]
							],
						r_?NumberQ:>IntegerPart[r]
						],
					If[NumberQ[#],
						IntegerPart@#,
						#
						]
					]&
				],
			 ct[[2;;, 4;;UpTo[3+Length@ cl]]]
			]


charTabParseLFs[ct_, cl_]:=
	Map[
		DeleteCases[Null]@
		Map[
			Replace[{
				l:{__String}:>
					Quiet[Check[ToExpression[If[Length@l>1,l,l[[1]]]],Print[l]]]
				}]
			]@
		StringSplit[
			StringTrim[
				StringReplace[
					StringReplace[#,{
						"Rx"->"\[FormalCapitalR][\[FormalX]]",
						"Ry"->"\[FormalCapitalR][\[FormalY]]",
						"Rz"->"\[FormalCapitalR][\[FormalZ]]",
						"x"->" \[FormalX]",
						"y"->" \[FormalY]",
						"z"->" \[FormalZ]"
						}],{
					e:Except[WhitespaceCharacter|"+"|"("]~~"2":>e<>"^2"
					}],
				((Whitespace|"")~~("("|")")~~(Whitespace|""))
				],
			","
			]&
		]@
	StringCases[
		Map[
			If[Length[#]>3+Length@ cl,
				#[[3+Length@ cl+1]],
				""
				]&,
			Rest@ct
			],
		s:Shortest[("("~~__~~")")|(__~~(","|EndOfString))]:>
			StringTrim[s,","]
		]


charTabParseNLFs[ct_, cl_]:=
	Map[
		DeleteCases[Null]@
		Map[
			Replace[{
				l:{__}:>
					Quiet[Check[ToExpression[If[Length@l>1,l,l[[1]]]],Print[l]]]
				}]
			]@
		StringSplit[
			StringTrim[
				StringReplace[
					StringReplace[#,{
						"Rx"->"\[FormalCapitalR][\[FormalX]]",
						"Ry"->"\[FormalCapitalR][\[FormalY]]",
						"Rz"->"\[FormalCapitalR][\[FormalZ]]",
						"x"->" \[FormalX]",
						"y"->" \[FormalY]",
						"z"->" \[FormalZ]"
						}],{
					e:Except[WhitespaceCharacter|"+"|"("]~~"2":>e<>"^2"
					}],
				((Whitespace|"")~~("("|")")~~(Whitespace|""))
				],
			","
			]&
		]@
	StringCases[
		Map[
			If[Length[#]>3+Length@cl+1,
				#[[3+Length@cl+2]],
				""
				]&,
			Rest@ct
			],
		s:Shortest[("("~~__~~")")|(__~~(","|EndOfString))]:>
			StringTrim[s,","]
		]


charTabExcelClean[ds_]:=
	Map[
		Check[
			With[{
				ct=#,
				pg=#[[1,3]],
				pgData=charTabParsePG[#[[1,3]]],
				cl=
					TakeWhile[#[[1,4;;]],
						#=!=""&
						],
				ir=
					With[{i=#[[2;;, 3 ]]},
						ReplacePart[i,
							Map[
								#[[1]]->i[[#[[1]]-1]]&,
								Position[i,""]
								]
							]
						]
				},
				<|
				"PointGroup"->
					pgData,
				"SymmetryClasses"->
					charTabParseCl[cl],
				"IrreducibleRepresentations"->
					charTabParseIR[ir],
				"CharacterTable"->
					charTabParseCT[pgData, ct, cl],
				"LinearFunctions"->
					charTabParseLFs[ct, cl],
				"NonLinearFunctions"->
					charTabParseNLFs[ct, cl]
					|>
				],
			<||>
			]&,
		ds
		];


(*Global`ctabs=charTabExcelClean[Global`map];*)


(* ::Subsubsection::Closed:: *)
(*CharacterTableData*)



CharacterTableData[ct_String]:=
	CharacterTable[ct];
CharacterTableData[ct_CharacterTable]:=
	ct;
CharacterTableData[ct:_String|_CharacterTable,
	prop:Alternatives@@$CharacterTableKeys
	]:=
	CharacterTableData[ct][prop];
CharacterTableData[ct:_String|_CharacterTable,
	{"IrreducibleRepresentation"|"IR", irrep:_String|_Integer}
	]:=
	With[{coredata=CharacterTableData[ct]},
		With[{irpos=
			Switch[irrep,
				_Integer,
					irrep,
				_String,
					FirstPosition[
						coredata["IrreducibleRepresentations"][[All, "ID"]], 
						irrep,
						$Failed
						][[1]],
				_,
					$Failed
				]
			},
			<|
				"PointGroup"->coredata["PointGroup"],
				"Data"->
					coredata["IrreducibleRepresentations"][[irpos]],
				"Vector"->
					coredata["CharacterTable"][[irpos]],
				"LinearFunctions"->
					coredata["LinearFunctions"][[irpos]],
				"NonLinearFunctions"->
					coredata["NonLinearFunctions"][[irpos]]
				|>/;Length[coredata["IrreducibleRepresentations"]]>=irpos
			]
		];
CharacterTableData[ct:_String|_CharacterTable,
	{"SymmetryClass"|"SC", sc:_String|_Integer}
	]:=
	With[{coredata=CharacterTableData[ct]},
		With[{scpos=
			Switch[sc,
				_Integer,
					sc,
				_String,
					FirstPosition[
						coredata["SymmetryClasses"][[All, "ID"]], 
						sc,
						$Failed
						][[1]],
				_,
					$Failed
				]
			},
			<|
				"PointGroup"->
					coredata["PointGroup"],
				"Data"->
					coredata["SymmetryClasses"][[scpos]],
				"Vector"->
					coredata["CharacterTable"][[scpos]]
				|>/;Length[coredata["SymmetryClasses"]]>=scpos
			]
		];


$CharacterTableThingProps=
	{
		"PointGroup",
		"Vector",
		"SymmetryClass",
		"IrreducibleRepresentation",
		"Data",
		"LinearFunctions",
		"NonLinearFunctions"
		};
CharacterTableData[ct:_String|_CharacterTable,
	{p:"IrreducibleRepresentation"|"IR"|"SymmetryClass"|"SC", thing:_String|_Integer},
	prop:Alternatives@@$CharacterTableThingProps|
		{Alternatives@@$CharacterTableThingProps,__String}
	]:=
	With[{base=CharacterTableData[ct, {p, thing}]},
		base@@Flatten[{prop}]/;AssociationQ@base
		]


PackageAddAutocompletions["CharacterTableData",
	{
		$charTables, 
		Join[$CharacterTableKeys, 
			{"SymmetryClass", "IrreducibleRepresentation"}
			],
		$CharacterTableThingProps
		}
	]


(* ::Subsubsection::Closed:: *)
(*CharacterTableFindIrreducibleRepresentation*)



CharacterTableFindIrreducibleRepresentation[
	ct_,
	key_->crit_
	]:=
	Pick[
		CharacterTableData[ct,"IrreducibleRepresentations"],
		crit/@
			CharacterTableData[ct, key]
		]


(* ::Subsubsection::Closed:: *)
(*CharacterTableActiveIrreducibleRepresentations*)



CharacterTableActiveIrreducibleRepresentations[ct_, "Infrared"]:=
	CharacterTableFindIrreducibleRepresentation[
		ct,
		"LinearFunctions"->Function@MemberQ[#,\[FormalX]|\[FormalY]|\[FormalZ],2]
		]


CharacterTableActiveIrreducibleRepresentations[ct_, "Raman"]:=
	CharacterTableFindIrreducibleRepresentation[
		ct,
		"NonLinearFunctions"->Function[Length[Flatten[#]]>0]
		]


CharacterTableActiveIrreducibleRepresentations[ct_, "Microwave"]:=
	CharacterTableFindIrreducibleRepresentation[
		ct,
		"LinearFunctions"->Function@MemberQ[#, \[FormalCapitalR][\[FormalX]]|\[FormalCapitalR][\[FormalY]]|\[FormalCapitalR][\[FormalZ]], 2]
		]


PackageAddAutocompletions[
	CharacterTableActiveIrreducibleRepresentations,
	{None, {"Infrared", "Raman", "Microwave"}}
	]


(* ::Subsection:: *)
(*Vibrational Coordinates*)



(* ::Subsubsection::Closed:: *)
(*Determining Coordinates*)



(* ::Text:: *)
(*The idea here is to take a number of atoms, index them, and rewrite the positions as either 2-tuples (stretch), 3-tuples (bend), or 4-tuples (wag)

These are simply a vector, angle, and dihedral angle, similar to what may be supplied to a z-matrix

The primary thing that needs to be determined is what the stretches should be.  Angles and dihedrals will be determined relative to the components of the stretches.

There should be one fewer stretch, bend, and wag coordinate, than atoms, as there will always be an implicitly fixed atom. This leads to 3n-3 coordinates. Degeneracy of coordinates should then be checked.*)



ravelUnwraveledIndex[n_, len_]:=
	{ Floor[(n-1)/len], Mod[n, len] };


(*deleteDegenerateStretches[str_]:=
	;*)


(* ::Text:: *)
(*To delete degenerate bends, we take our collection of bends, b = {{a11, a12, a13}, {a21, a22, a23}, ...} and remove any {ai1, ai2, ai3} such that  there is some {aj1, aj2, aj3} where aj2 = ai2 and either aj1 = ai1 or an3 = ai3 and {ai1, ai2, aj3} or {aj1, ai2, ai3} is in b*)



deleteDegenerateBends[bends_]:=
	DeleteDuplicates[bends,
		MatchQ[#, {#2[[1]], #2[[2]], _}|{_, #2[[2]], #2[[3]]}]&&
			MemberQ[bends, {#2[[1]], #2[[2]], #[[3]]}|{#[[1]], #2[[2]], #2[[3]]}]&
		];


(* ::Text:: *)
(*To delete degenerate wags, we simply delete by the wagging coordinate*)



deleteDegenerateWags[wags_]:=
	DeleteDuplicatesBy[wags, First];


ChemUtilsVibrationalCoordinates//Clear


ChemUtilsVibrationalCoordinates[
	atoms:{__},
	bonds:{{_,_}...}:{}
	]:=
	Module[
		{
			requiredCoordinates=
				3*Length[atoms]-3,
			atomNum=Length[atoms],
			stretches=
				Take[
					Sort@DeleteDuplicates[Sort/@bonds],
					UpTo[Length[atoms]]
					],
			stretchGraph,
			center,
			bends,
			wags
			},
		(* The stretching coordinates should always be provided by the bonds *)
		(*If[Length@stretches<atomNum,
			stretches=
				Take[
					Join[
						stretches,
						DeleteCases[
							Subsets[atoms,{2}]
							(*Inefficient, sure, but this whole system isn't built for anything big enough to crush this*), 
							Alternatives@@stretches
							]
						],
					atomNum
					]
			];*)
		stretchGraph=Graph[UndirectedEdge@@@stretches];
		center=VertexList[stretchGraph][[Last@Ordering@VertexDegree@stretchGraph]];
		bends=
			Join@@
				Map[
					Insert[#,2]/@
						Subsets[
							Rest@
								VertexOutComponent[stretchGraph, #, 1],
							{2}
							]&,
					VertexList[stretchGraph]
					];
		bends=
			deleteDegenerateBends@
				If[Length[bends]>0&&ListQ@bends[[1, 1]],
					SortBy[bends, #[[1]]-#[[2]]==-(#[[3]]-#[[2]])&],
					bends
					];
		(*wags=
			Join@@
				Map[
					Prepend[#]/@
						Subsets[
							Rest@
								VertexOutComponent[stretchGraph, #, 1],
							{3}
							]&,
					VertexList[stretchGraph]
					];
		wags=deleteDegenerateWags@wags;*)
		<|
			"Center"->center,
			"Stretches"->stretches,
			"Bends"->bends(*,
			"Wags"->wags*)
			|>
		];


vibrationalCoordinateKeys=
	"Coordinates"|"CoordinatesIndexed"|"Values";


ChemUtilsVibrationalCoordinates[
	atoms:{{_,_,_}..},
	bonds:{{_,_}...}:{},
	return:vibrationalCoordinateKeys|All|{vibrationalCoordinateKeys..}:All
	]:=
	Module[
		{
			order=
				Ordering@
					With[{center=Mean[atoms]},
						Norm[#-center]&/@atoms
						],
			sortedAts,
			orderMap,
			coords,
			coordsTrue,
			doKeys=
				Replace[Flatten@List@return, 
					{All}->
						 {"Coordinates", "CoordinatesIndexed", "Values"}
					 ]
			},
		sortedAts=
			atoms[[order]];
		orderMap=
			MapIndexed[
				#2[[1]]->#&,
				order
				];
		coordsTrue=
			ChemUtilsVibrationalCoordinates[
				sortedAts,
				Map[atoms[[#]]&,
					SortBy[bonds, Map[Position[order, #]&]]
					]
				];
		coords=
			coordsTrue/.
				MapThread[
					Rule,
					{
						sortedAts,
						order
						}
					];
			<|
				If[MemberQ[doKeys, "CoordinatesIndexed"],
					"CoordinatesIndexed"->
						coords,
					Sequence@@{}
					],
				If[MemberQ[doKeys, "Coordinates"],
					"Coordinates"->
						(coords/.MapIndexed[#2[[1]]->#&, atoms]),
					Sequence@@{}
					],
				If[MemberQ[doKeys, "Values"],
					"Values"->
						<|
							"Stretches"->
								Map[
									ChemUtilsVibrationalCoordinateFunction["Stretches"]@
										atoms[[#]]&,
									coords["Stretches"]
									],
							"Bends"->
								Map[
									ChemUtilsVibrationalCoordinateFunction["Bends"]@
										atoms[[#]]&,
									coords["Bends"]
									](*,
							"Wags"->
								Map[
									ChemUtilsVibrationalCoordinateFunction["Wags"]@
										atoms[[#]]&,
									coords["Wags"]
									]*)
							|>,
					Sequence@@{}
					]
				|>
			]


AtomsetVibrationalCoordinates//Clear


AtomsetVibrationalCoordinates[
	as:ChemObjPattern,
	return:vibrationalCoordinateKeys|All|"Functions"|
		{(vibrationalCoordinateKeys|"Functions")..}:All
	]:=
	With[{ats=ChemGet[as, "Atoms"]},
		ChemUtilsVibrationalCoordinates[
				ChemGet[ChemGet[as, "Atoms"], "Position"],
				AtomsetBondsIndexed[as][[All,;;2]],
				return
				]
		]


(* ::Subsubsection::Closed:: *)
(*Coordinate Functions*)



ChemUtilsVibrationalCoordinateFunction["Stretches", {pt1_, pt2_}]:=
	pt2-pt1;
ChemUtilsVibrationalCoordinateFunction["Stretches"][{pt1_, pt2_}]:=
	ChemUtilsVibrationalCoordinateFunction["Stretches", {pt1, pt2}];
ChemUtilsVibrationalCoordinateFunction["Bends", {pt1_, pt2_, pt3_}]:=
	VectorAngle[pt1-pt2, pt3-pt2];
ChemUtilsVibrationalCoordinateFunction["Bends"][{pt1_, pt2_, pt3_}]:=
	ChemUtilsVibrationalCoordinateFunction["Bends", {pt1, pt2, pt3}];
ChemUtilsVibrationalCoordinateFunction["Wags", {pt1_, pt2_, pt3_, pt4_}]:=
	Projection[
		pt1,
		Cross[pt3-pt2, pt4-pt2]
		];
ChemUtilsVibrationalCoordinateFunction["Wags"][{pt1_, pt2_, pt3_, pt4_}]:=
	ChemUtilsVibrationalCoordinateFunction["Wags", {pt1, pt2, pt3, pt4}];


(* ::Subsubsection::Closed:: *)
(*Coordinate Visualizations*)



(* ::Text:: *)
(*Pulled from here: https://mathematica.stackexchange.com/a/10958/38205*)



ClearAll[sjoerdSplineCircle];
sjoerdSplineCircle[m_List,r_,angles_List: {0,2 \[Pi]}]:=
	Module[{seg,\[Phi],start,end,pts,w,k},
		{start,end}=Mod[angles//N,2 \[Pi]];
If[end<=start,end+=2 \[Pi]];
seg=Quotient[end-start//N,\[Pi]/2];
\[Phi]=Mod[end-start//N,\[Pi]/2];
If[seg==4,seg=3;\[Phi]=\[Pi]/2];
pts=
			r RotationMatrix[start].#&/@
				Join[
					Take[{{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1}}, 2 seg+1],
					RotationMatrix[seg \[Pi]/2].#&/@{{1,Tan[\[Phi]/2]},{Cos[\[Phi]],Sin[\[Phi]]}}];
If[Length[m]==2,
			pts=m+#&/@pts,
			pts=m+#&/@Transpose[Append[Transpose[pts],ConstantArray[0,Length[pts]]]]
			];
w=Join[Take[{1,1/Sqrt[2],1,1/Sqrt[2],1,1/Sqrt[2],1},2 seg+1],{Cos[\[Phi]/2],1}];
k=Join[{0,0,0},Riffle[#,#]&@Range[seg+1],{seg+1}];
BSplineCurve[pts,SplineDegree->2,SplineKnots->k,SplineWeights->w]
		]/;Length[m]==2||Length[m]==3


Options[sjoerdCircleFromPoints] = {arc -> False};

sjoerdCircleFromPoints[m : {q1_, q2_, q3_}, OptionsPattern[]] :=
Module[{
		c, r, \[Phi]1, \[Phi]2, p1, p2, p3, h, 
    rot =
    	With[{crs=Normalize[Cross[#1 - #2, #3 - #2]]},
	    	Which[
	    		Abs[crs]=={0,0,1},
		    		IdentityMatrix[3],
	    		crs=={0,0,-1},
	    			-IdentityMatrix[3],
	    		True,
	    			RotationMatrix[{{0, 0, 1}, crs}]
	    		]
				] &},
  {p1, p2, p3} = {q1, q2, q3}.rot[q1, q2, q3];
  h = p1[[3]];
  {p1, p2, p3} = {p1, p2, p3}[[All, ;; 2]];
  {c, r} = List @@ Circumsphere[{p1, p2, p3}];
  \[Phi]1 = ArcTan @@ (p3 - c);
  \[Phi]2 = ArcTan @@ (p1 - c);
  c = Append[c, h];
  If[OptionValue[arc] // TrueQ,
    MapAt[Function[{p}, rot[q1, q2, q3].p] /@ # &, sjoerdSplineCircle[c, r, {\[Phi]1, \[Phi]2}], {1}],
    MapAt[Function[{p}, rot[q1, q2, q3].p] /@ # &, sjoerdSplineCircle[c, r], {1}]
  ]
] /; MatrixQ[m, NumericQ] && Dimensions[m] == {3, 3}


ChemUtilsVibrationalCoordinateGraphicsObject//Clear


ChemUtilsVibrationalCoordinateGraphicsObject[
	"Stretches",
	i_Integer,
	{p1_List, p2_List}
	]:=
	{
		Red,
		Text[
			Subscript["r", i], 
			Mean@{p1, p2}
			],
		Black,
		Arrow[{p1, p2}]
		};
ChemUtilsVibrationalCoordinateGraphicsObject[
	"Bends",
	i_Integer,
	{p1:{Repeated[_?NumericQ,{3}]}, p2_, p3_}
	]:=
	{
		Text[Subscript["\[Theta]", i], 
			Mean@{.5*Normalize[p1-p2], .5*Normalize[p3-p2]}+p2
			],
		Red,
		Line[{p2, .5*Normalize[p1-p2]+p2}],
		Line[{p2, .5*Normalize[p3-p2]+p2}],
		sjoerdCircleFromPoints[
			{
				.25*Normalize[p1-p2]+p2, 
				.25*Normalize[Mean[{p1-p2, p3-p2}]]+p2,
				.25*Normalize[p3-p2]+p2
				},
			arc->True
			]
		};
ChemUtilsVibrationalCoordinateGraphicsObject[
	k_,
	l:{{__List}..}
	]:=
	MapIndexed[
		ChemUtilsVibrationalCoordinateGraphicsObject[k, #2[[1]], #]&, 
		l
		]


ChemUtilsVibrationalCoordinateGraphics//Clear


ChemUtilsVibrationalCoordinateGraphics[
	crds_Association,
	show_:"Stretches"|"Bends"
	]:=
	{
		Arrowheads[
			{{-.02,0},{.02,1}},
			Appearance->"Projected"
			],
		KeyValueMap[
			Switch[#,
				show,
					ChemUtilsVibrationalCoordinateGraphicsObject[#,
						#2
						],
				_,
					Sequence@@{}
				]&,
			crds["Coordinates"]
			]
		}


(* ::Subsection:: *)
(*Representations*)



(* ::Subsubsection::Closed:: *)
(*CharacterTableSymmetryFunctions*)



CharacterTableSymmetryFunctions[ct_, sops_]:=
	Module[{
		rots=sops["Elements","RotationAxes"],
		rotClassOrder=
			Apply[Join,
				Association@
					Thread[
						sops["Elements","RotationAxes"][[#]]->Length[#]
						]&/@
					sops["Classes", "RotationAxes"]
				],
		rotClasses=
			Apply[Join,
				Association@
					With[{
						fns=Lookup[sops["Functions","RotationAxes"],#],
						idx=sops["Elements","RotationAxes"][[#]]
						},
						Map[#->fns&,idx]
					]&/@
					sops["Classes", "RotationAxes"]
				],
		rotClassesElements=
			Apply[Join,
				Association@
					With[{
						idx=sops["Elements","RotationAxes"][[#]]
						},
						Map[#->idx&,idx]
					]&/@
					sops["Classes", "RotationAxes"]
				],
		planes=sops["Elements", "SymmetryPlanes"],
		planeClassOrder=
			Apply[Join,
				Association@
					Thread[
						sops["Elements","SymmetryPlanes"][[#]]->Length[#]
						]&/@
					sops["Classes", "SymmetryPlanes"]
				],
		planeClasses=
			Apply[Join,
				Association@
					With[{
						fns=Lookup[sops["Functions","SymmetryPlanes"],#],
						idx=sops["Elements","SymmetryPlanes"][[#]]
						},
						Map[#->fns&,idx]
					]&/@
					sops["Classes", "SymmetryPlanes"]
				],
		planeClassesElements=
			Apply[Join,
				Association@
					With[{
						idx=sops["Elements","SymmetryPlanes"][[#]]
						},
						Map[#->idx&,idx]
					]&/@
					sops["Classes", "SymmetryPlanes"]
				],
		screws=sops["Elements", "ScrewAxes"],
		screwClassOrder=
			Apply[Join,
				Association@
					Thread[
						sops["Elements","ScrewAxes"][[#]]->Length[#]
						]&/@
					sops["Classes", "ScrewAxes"]
				],
		screwClasses=
			Apply[Join,
				Association@
					With[{
						fns=Lookup[sops["Functions","ScrewAxes"],#],
						idx=sops["Elements","ScrewAxes"][[#]]
						},
						Map[#->fns&,idx]
					]&/@
				sops["Classes", "ScrewAxes"]
				],
		screwClassesElements=
			Apply[Join,
				Association@
					With[{
						idx=sops["Elements","ScrewAxes"][[#]]
						},
						Map[#->idx&,idx]
					]&/@
					sops["Classes", "ScrewAxes"]
				],
		center=sops["Elements", "Center"],
		elemListing=
			<|
				"RotationAxes"->{},
				"SymmetryPlanes"->{},
				"ScrewAxes"->{}
				|>,
		primaryAxis,
		secondaryAxis,
		ind,
		cur
		},
		rots=
			First/@SortBy[MapIndexed[#->First@#2&, rots],
				Last@FirstPosition[sops["Classes", "RotationAxes"], #[[2]]]&
				];
		planes=
			First/@SortBy[MapIndexed[#->First@#2&, planes],
				Last@FirstPosition[sops["Classes", "SymmetryPlanes"], #[[2]]]&
				];
		screws=
			First/@SortBy[MapIndexed[#->First@#2&, screws],
				Last@FirstPosition[sops["Classes", "ScrewAxes"], #[[2]]]&
				];
		primaryAxis=
			Normalize[
				MaximalBy[
					MaximalBy[rots, First][[All, 2]],
					#[[3]]&
					][[1]]-center
				];
		secondaryAxis=
			SelectFirst[
				Map[#-center&, SortBy[rots, First][[All,2]]],
				.4<(Mod[VectorAngle[#, primaryAxis], \[Pi]]/\[Pi])<.6&
				];
		If[!ListQ@secondaryAxis,
			secondaryAxis=
				SelectFirst[
					Map[
						Cross[#[[1]]-center, #[[2]]-center]&,
						planes
						],
					.1<(Mod[VectorAngle[#, primaryAxis], \[Pi]]/\[Pi])<.9&
					];
			If[!ListQ@secondaryAxis,
				secondaryAxis=
					SelectFirst[
						Map[#-center&, SortBy[rots, First][[All,2]]],
						.1<(Mod[VectorAngle[#, primaryAxis], \[Pi]]/\[Pi])<.9&
						];
				If[!ListQ@secondaryAxis,
					secondaryAxis=
						Cross[primaryAxis, {1, 0, 0}];
					If[Norm[secondaryAxis]<.1, 
						secondaryAxis=
							Cross[primaryAxis, {0, 1, 0}]
						]
					],
				secondaryAxis-=Projection[secondaryAxis, primaryAxis]
				]
			];
		secondaryAxis=Normalize[secondaryAxis];
		AssociationMap[
			Switch[#["Type"],
				"E",
					<|
						"Functions"->{ScalingTransform[{1, 1, 1}, center]},
						"Element"->None
						|>,
				"i",
					<|
						"Functions"->{ScalingTransform[{-1, -1, -1}, center]},
						"Element"->center
						|>,
				"C",
						ind=
							With[{c=#["Count"]},
								FirstPosition[
									rots,
									{
										#["Order"]*#["Degree"], 
										Which[
											StringContainsQ[#["Modifier"],"x"],
												{_?(Abs[#]>.001&), __?(Abs[#]<.001&)},
											StringContainsQ[#["Modifier"],"y"],
												{_?(Abs[#]<.001&),_?(Abs[#]>.001&),_?(Abs[#]<.001&)},
											StringContainsQ[#["Modifier"],"z"],
												{__?(Abs[#]<.001&),_?(Abs[#]>.001&)},
											True,
												_
											]
										}?(rotClassOrder[#]===c&), 
									{$Failed}
									][[1]]
								];
						If[ind===$Failed,
							Replace[
								FirstCase[
									With[{c=#["Count"]},
										Reverse@
											SortBy[sops["Elements", "RotationAxes"], 
												Abs[#["Order"]-c]&
												]
										],
									{
										o_/;Mod[o, #["Order"]*#["Degree"] ]==0,
										Which[
											StringContainsQ[#["Modifier"],"x"],
												{_?(Abs[#]>.001&), __?(Abs[#]<.001&)},
											StringContainsQ[#["Modifier"],"y"],
												{_?(Abs[#]<.001&),_?(Abs[#]>.001&),_?(Abs[#]<.001&)},
											StringContainsQ[#["Modifier"],"z"],
												{__?(Abs[#]<.001&),_?(Abs[#]>.001&)},
											True,
												_
											]
										}, 
									$Failed
									],
								r:{_,_}:>
									With[{els=rotClassesElements@r},
										If[els[[1,1]]==#["Order"]*#["Degree"],
											<|
												"Functions"->rotClasses[els[[1]]],
												"Element"->els
												|>,
											With[{o=#["Order"], d=#["Degree"]},
												<|
													"Functions"->
														Map[
																RotationTransform[
																	2.\[Pi]/(o*d),
																	#[[2]],
																	center
																	]&, 
																els
																],
													"Element"->
														Map[{o, #[[2]]}&, els]
													|>
												]
											]
										]
								],
							cur=
								<|
									"Functions"->rotClasses[rots[[ind]]],
									"Element"->First@rotClassesElements@rots[[ind]]
									|>;
							rots=DeleteCases[rots,Alternatives@@rotClassesElements@rots[[ind]]];
							cur
							],
				"\[Sigma]",
						Switch[{#["Orientation"], #["Modifier"]},
							{_, _?(StringContainsQ["xy"])},
								ind=
									With[{c=#["Count"]},
										FirstPosition[
											planes,
											{Repeated[{_,_,_?(Abs[#]<.0001&)}, {2}]}?(planeClassOrder[#]===c&),
											{1}
											][[1]]
										],
							{_, _?(StringContainsQ["xz"])},
								ind=
									With[{c=#["Count"]},
										FirstPosition[
											planes,	
											{Repeated[{_,_?(Abs[#]<.0001&),_}, {2}]}?(planeClassOrder[#]===c&),
											{1}
											][[1]]
										],
							{_, _?(StringContainsQ["yz"])},
								ind=
									With[{c=#["Count"]},
										FirstPosition[
											planes,
											{Repeated[{_?(Abs[#]<.0001&),_,_}, {2}]}?(planeClassOrder[#]===c&),
											{1}
											][[1]]
										],
							{"h", _},
								ind=
									With[{c=#["Count"]},
										FirstPosition[
											planes,
											{pt1:{_,_,_}, pt2_}/;(
												planeClassOrder[{pt1, pt2}]===c&&
												With[{
													n=Norm[primaryAxis],
													v=Cross[pt1-center, pt2-center]
													},
													Abs[primaryAxis.v/(n*Norm[v])]
													]/2.\[Pi]
												)>.8,
											{1}
											][[1]]
										],
							_,
								ind=
									FirstPosition[
										With[{c=#["Count"]},
											Select[planes, planeClassOrder[#]===c&]
											],	
										{{_,_,_}, _},
										{1}
										][[1]]
							];
						cur=
							<|
								"Functions"->planeClasses[planes[[ind]]],
								"Element"->First@planeClassesElements@planes[[ind]]
								|>;
						planes=DeleteCases[planes,Alternatives@@planeClassesElements@planes[[ind]]];
						cur,
				"S",
					ind=
						With[{c=#["Count"]},
							FirstPosition[
								screws,
								{
									#["Order"]*#["Degree"], 
									Which[
										StringContainsQ[#["Modifier"],"x"],
											{_?(Abs[#]>.001&), __?(Abs[#]<.001&)},
										StringContainsQ[#["Modifier"],"y"],
											{_?(Abs[#]<.001&),_?(Abs[#]>.001&),_?(Abs[#]<.001&)},
										StringContainsQ[#["Modifier"],"z"],
											{__?(Abs[#]<.001&),_?(Abs[#]>.001&)},
										True,
											_
										]
									}?(screwClassOrder[#]===c&), 
								{$Failed}
								][[1]]
							];
						If[ind===$Failed,
							Replace[
								FirstCase[Reverse@SortBy[sops["Elements", "ScrewAxes"], #["Order"]],
									{
										o_/;Mod[o, #["Order"]*#["Degree"] ]==0,
										Which[
											StringContainsQ[#["Modifier"],"x"],
												{_?(Abs[#]>.001&), __?(Abs[#]<.001&)},
											StringContainsQ[#["Modifier"],"y"],
												{_?(Abs[#]<.001&),_?(Abs[#]>.001&),_?(Abs[#]<.001&)},
											StringContainsQ[#["Modifier"],"z"],
												{__?(Abs[#]<.001&),_?(Abs[#]>.001&)},
											True,
												_
											]
										}, 
									$Failed
									],
								r:{_,_}:>
									With[{els=screwClassesElements@r},
										If[els[[1,1]]==#["Order"]*#["Degree"],
											<|
												"Functions"->screwClasses[els[[1]]],
												"Element"->els
												|>,
											With[{o=#["Order"], d=#["Degree"]},
												<|
													"Functions"->
														Map[
															Simplify@Composition[
																RotationTransform[
																	2.\[Pi]/(o*d),
																	#[[2]],
																	center
																	],
																ReflectionTransform[
																	#[[2]],
																	center
																	]
																]&, els],
													"Element"->
														Map[{o, #[[2]]}&, els]
													|>
												]
											]
										]
								],
							cur=
								<|
									"Functions"->screwClasses[screws[[ind]]],
									"Element"->First@screwClassesElements@screws[[ind]]
									|>;
							screws=DeleteCases[screws, Alternatives@@screwClassesElements@screws[[ind]]];
							cur
							]
				]&,
			ct["SymmetryClasses"]
			]//Prepend[
						#,
						"SourceElements"->
							<|
								"Center"->sops["Elements", "Center"], 
								"PrincipalAxes"->
									{
										secondaryAxis,
										Normalize@Cross[primaryAxis, secondaryAxis],
										primaryAxis
										}
								|>
						]& 
		]


(* ::Subsubsection::Closed:: *)
(*CharacterTableSymmetryFunctionsFormatted*)



CharacterTableSymmetryFunctionsFormatted[symFs_]:=
	Dataset@
		Map[Replace[{{l_}:>l, l_List:>MatrixForm[l]}]]@
		KeyMap[Key["Formatted"]]@
		KeyDrop[symFs, {"SourceElements"}]


(* ::Subsubsection::Closed:: *)
(*charTabRepLinearSolve*)



charTabRepLinearSolve[mx_,
	b_,
	pick_,
	i_
	]:=
	Which[
		b==mx[[i]],
			ReplacePart[ConstantArray[0,Length[mx]], i->1],
		AnyTrue[mx, Norm[b-#]<.05&],
			Normalize[Boole[Norm[b-#]<.05]&/@mx],
		AnyTrue[mx, Norm[b+#]<.05&],
			Normalize[-Boole[Norm[b+#]<.05]&/@mx],
		True,
			ReplacePart[
				ConstantArray[0, Length[mx]],
				Thread[
					Position[pick, True][[All, 1]]->
						Quiet@
							Check[
								LinearSolve[Transpose@Echo@Pick[mx, pick], b],
								LeastSquares[Transpose@Pick[mx, pick], b]
								]
					]
				]
		]


(* ::Subsubsection::Closed:: *)
(*CharacterTableRepresentationMatrices*)



CharacterTableRepresentationMatrix[
	fn_,
	coords_
	]:=
	With[
		{
			oldDirs=
				#["Direction"]@#["Points"]&/@coords,
			newDirs=
				#["Direction"]@Map[fn, #["Points"]]&/@coords,
			dimensions=
				Length@#["Points"]&/@coords
			},
		MapIndexed[
			With[{d=dimensions[[ #2[[1]] ]], i=#2[[1]]},
				charTabRepLinearSolve[
					oldDirs,
					#,
					MatchQ[d]/@dimensions,
					i
					]
				]&,
			newDirs
			]
		]


CharacterTableRepresentationMatrices[
	mapping_Association?(Not@*KeyMemberQ["Elements"]),
	coords:charTableRepListCoordVecPat
	]:=
	Map[
		CharacterTableRepresentationMatrix[
			#["Functions"][[1]],
			coords
			]&,
		KeyDrop[mapping, {"SourceElements"}]
		]


(* ::Subsubsection::Closed:: *)
(*CharacterTableReducibleRepresentationsList*)



(* ::Text:: *)
(*
Need a method to handle the problem of building a representation for a collection of coordinates, P,
with a collection of symmetry elements, S

We just need a matrix that represents S... 
i.e. find some A such that A.P = S(P) where S(P) = ( S(p1), S(p2), S(p3), ...), where S(p1) is represented as a coefficient vector in P
*)



CharacterTableReducibleRepresentationsList//Clear


charTableRepListCoordVecPat=
	{KeyValuePattern[{"Points"->_List, "Direction"|"Axes"->_}]..};
charTableRepListCoordPat=
	{{_?NumericQ,_,_}..}|Automatic;


charTableAxisSysToElementTransform//Clear


charTableAxisSysToElementTransform[
	center_,
	ax_,
	{n_Integer, l_List},
	i_Integer
	]:=
	With[{v1=l-center, a=ax[[3]]},
		If[Abs[Normalize[v1].a]>.9,
			Identity,
			RotationTransform[{v1, a}]
			]
		];
charTableAxisSysToElementTransform[
	center_,
	ax_,
	{pt1_List, pt2_List},
	i_Integer
	]:=
	With[{v1=Cross[pt1-center, pt2-center], a=ax[[3]]},
		If[Abs[Normalize[v1].a]>.9,
			Identity,
			RotationTransform[{v1, a}]
			]
		];
charTableAxisSysToElementTransform[___]:=Identity


charTableRepCharacter[
	center_,
	corePt_, 
	testPts_,
	dirF_,
	op_
	]:=
	With[
		{
			oldpt=corePt,
			olddir=dirF@testPts,
			newpt=op[corePt],
			newdir=dirF[op/@testPts],
			cutOff=.1*Norm[corePt-center]
			},
			Which[
				(* Point moved *)
				Not[
					And@@
						MapThread[
							#2-cutOff<=#<=#2+cutOff&,
							{newpt,oldpt}
							]
					],
					0,
				(* Norm is 0 so we can't project *)
				Norm[newdir]*Norm[olddir]==0,
					If[Norm[newdir]+Norm[olddir]<.1,
						1,
						0
						],
				True,
					newdir.olddir/(Norm[newdir]*Norm[olddir])
				]
		]


CharacterTableReducibleRepresentationsList[
	mapping_Association?(Not@*KeyMemberQ["Elements"]),
	coordsAndVecs:charTableRepListCoordVecPat
	]:=
	GroupBy[First->Last]@Flatten@
		MapIndexed[
			With[
				{
					pt=#["Points"], 
					i=#2[[1]],
					dir=#["Direction"],
					ax=#["Axes"],
					center=mapping["SourceElements", "Center"]
					},
					If[ListQ@ax,
						MapIndexed[
							pt->
								Table[
									With[
										{
											aTrue=
												charTableAxisSysToElementTransform[
													center, 
													ax, 
													m["Element"],
													#2[[1]]
													][#]
											},
										charTableRepCharacter[
											center,
											pt[[1]],
											{aTrue},
											Total,
											m["Functions"][[1]]
											]
										],
									{m, Values@KeyDrop[mapping, {"SourceElements"}]}
									]&,
							ax
							],
					pt->
						Table[
							charTableRepCharacter[
								center,
								Mean[pt],
								pt,
								dir,
								m["Functions"][[1]]
								],
							{m, Values@KeyDrop[mapping, {"SourceElements"}]}
							]
						]
				]&,
			coordsAndVecs
			];


charTableCoordPat={({_?NumericQ, _, _}|{{_?NumericQ, _, _}..})..};


CharacterTableReducibleRepresentationsList[
	mapping_Association?(Not@*KeyMemberQ["Elements"]),
	coords:{{_,_,_}..}
	]:=
	CharacterTableReducibleRepresentationsList[
		mapping,
		(*Join@@*)
		Table[
			<|
				"Points"->{c},
				"Axes"->IdentityMatrix[3]
				|>,
			{c, coords}
			]
		];
CharacterTableReducibleRepresentationsList[
	ct_, 
	sops_Association?(KeyMemberQ["Elements"]),
	coords:{{_,_,_}..}
	]:=
	CharacterTableReducibleRepresentationsList[
		CharacterTableSymmetryFunctions[ct, sops],
		coords
		];
CharacterTableReducibleRepresentationsList[
	ct_, 
	sops_Association?(KeyMemberQ["Elements"]),
	coordsAndVecs:charTableRepListCoordVecPat
	]:=
	CharacterTableReducibleRepresentationsList[
		CharacterTableSymmetryFunctions[ct, sops],
		coordsAndVecs
		];
CharacterTableReducibleRepresentationsList[
	args__,
	coords_Association?(KeyMemberQ["Coordinates"]),
	which:("Stretches"|"Bends"|{("Stretches"|"Bends")..}):
		{"Stretches", "Bends"}
	]:=
	With[{
		bleh=
			Join@@
				MapThread[
					With[{type=#2},
						Map[
							<|
								"Points"->#,
								"Direction"->ChemUtilsVibrationalCoordinateFunction[type]
								|>&,
							#
							]
						]&,
					{
						Lookup[coords["Coordinates"], Flatten@List@which],
						Flatten@List@which
						}
					]
			},
		If[Length@bleh>0,
			CharacterTableReducibleRepresentationsList[args,bleh],
			{}
			]
		];


(* ::Subsubsection::Closed:: *)
(*CharacterTableReducibleRepresentationsGrid*)



CharacterTableReducibleRepresentationsGrid//Clear


charTableLabListPat=
	{(Except[_List|_Association]|{Except[_?NumericQ]..})..}


charTableDefaultLabels={{"x","y","z"}};


CharacterTableReducibleRepresentationsGrid[
	ct_,
	gamma_Association?(AllTrue[ListQ]@*Keys),
	labels:charTableLabListPat:charTableDefaultLabels
	]:=
	With[{grid=
		Panel@
			With[{
				core=
					MapIndexed[
						With[
							{
								l=#, 
								num=ToString@First@#2,
								labs=labels[[Mod[#2[[1]], Length[labels], 1]]]
								},
							MapThread[
								Prepend[#,
									If[StringQ@#2, Subscript[#2,num], #2]
									]&,
								{
									l,
									Take[
										Flatten@ConstantArray[labs, Length@l],
										Length@l
										]
									}]
							]&,
						Values@KeyDrop[gamma, Key@{"Grid"}]
						]
				},
				Style[
					Grid[
						Prepend[
							Flatten[core,1],
							Prepend[ct["SymmetryClasses"][[All,"Formatted"]], ""]
							]
						],
					ShowStringCharacters->False
					]
				]
		},
	Interpretation[
		grid,
		Append[gamma, {"Grid"}->grid]
		]
	];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	fmapping_Association?(Not@*KeyMemberQ["Elements"]),
	coordAndVecs:charTableRepListCoordVecPat,
	labels:charTableLabListPat:charTableDefaultLabels
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableReducibleRepresentationsList[
			fmapping,
			coordAndVecs
			],
		labels
		];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	fmapping_Association?(Not@*KeyMemberQ["Elements"]),
	coords:{{Repeated[_?NumericQ, {3}]}..},
	labels:charTableLabListPat:charTableDefaultLabels
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableReducibleRepresentationsList[
			fmapping,
			coords
			],
		labels
		];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	symOps_Association?(KeyMemberQ["Elements"]),
	coordAndVecs:charTableRepListCoordVecPat,
	labels:charTableLabListPat:charTableDefaultLabels
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableReducibleRepresentationsList[
			CharacterTableSymmetryFunctions[ct, symOps],
			coordAndVecs
			],
		labels
		];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	symOps_Association?(KeyMemberQ["Elements"]),
	coords:{{___?NumericQ}..},
	labels:charTableLabListPat:charTableDefaultLabels
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableReducibleRepresentationsList[
			CharacterTableSymmetryFunctions[ct, symOps],
			coords
			],
		labels
		];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	a___,
	coords_Association?(KeyMemberQ["Coordinates"]),
	which:("Stretches"|"Bends"|{("Stretches"|"Bends")..}):
		{"Stretches", "Bends"},
	labels:charTableLabListPat:{{"r","\[Theta]","\[CurlyPhi]"}}
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableReducibleRepresentationsList[
			a,
			coords,
			which
			],
		labels
		];


(* ::Subsubsection::Closed:: *)
(*CharacterTableTotalRepresentation*)



CharacterTableTotalRepresentation//Clear


CharacterTableTotalRepresentation[
	gamma_Association
	]:=
	Round[Transpose[Join@@Values[gamma]]//Map[Total]];
CharacterTableTotalRepresentation[
	fmapping_Association?(Not@*KeyMemberQ["Elements"]),
	coordVecs:charTableRepListCoordVecPat
	]:=
	With[{r=CharacterTableReducibleRepresentationsList[fmapping, coordVecs]},
		If[Length@r>0,
			CharacterTableTotalRepresentation@r,
			{}
			]
		];
CharacterTableTotalRepresentation[
	fmapping_Association?(Not@*KeyMemberQ["Elements"]),
	coords_List
	]:=
	CharacterTableTotalRepresentation@
		CharacterTableReducibleRepresentationsList[fmapping, coords];
CharacterTableTotalRepresentation[
	a__,
	coords_Association?(KeyMemberQ["Coordinates"]),
	which:("Stretches"|"Bends"|{("Stretches"|"Bends")..}):
		{"Stretches", "Bends"}
	]:=
	CharacterTableTotalRepresentation@
		CharacterTableReducibleRepresentationsList[a, coords, which];
CharacterTableTotalRepresentation[
	ct_,
	symOps_Association?(KeyMemberQ["Elements"]),
	b__
	]:=
	CharacterTableTotalRepresentation[
		CharacterTableSymmetryFunctions[ct, symOps],
		b
		];


(* ::Subsubsection::Closed:: *)
(*CharacterTableReduceRepresentation*)



CharacterTableReduceRepresentation//Clear


CharacterTableReduceRepresentationCoefficients[
	ctRows_List,
	symmClassCounts_,
	red_
	]:=
	(1/Total[symmClassCounts])*
		Map[
			Total@
				MapThread[
					Times,
					{
						symmClassCounts,
						red,
						#
						}
					]&,
			ctRows
			];


CharacterTableReduceRepresentation[
	characterRows_List,
	symmClassCounts_List,
	rep:{__Integer}
	]:=
	CharacterTableReduceRepresentationCoefficients[
		characterRows,
		symmClassCounts,
		rep
		];
CharacterTableReduceRepresentation[ct_CharacterTable, rep:{__Integer}]:=
	With[
		{
			characterRows=
				CharacterTableData[ct, "CharacterTable"],
			symmClassCounts=
				Lookup[CharacterTableData[ct, "SymmetryClasses"], "Count"],
			irreps=
				CharacterTableData[ct,"IrreducibleRepresentations"]
			},
		AssociationThread[
			irreps,
			CharacterTableReduceRepresentationCoefficients[
				characterRows,
				symmClassCounts,
				rep
				]
			]
		];
CharacterTableReduceRepresentation[ct_CharacterTable, {}]:={}


(* ::Subsubsection::Closed:: *)
(*CharacterTableModeRepresentations*)



CharacterTableModeRepresentations[
	ct_,
	totalNuclearRep_Association
	]:=
	Module[
		{
			translations,
			rotations,
			vibrations
			},
		translations=
			Counts[
				Join@@
					Map[
						Pick[
							Keys@totalNuclearRep, 
							MemberQ[#]/@
								CharacterTableData[ct,"LinearFunctions"]
							]&,
						Join[
							{\[FormalX], \[FormalY], \[FormalZ]},
							Subsets[{\[FormalX], \[FormalY], \[FormalZ]}, {2, 3}]
							]
					]
				];
		rotations=
			Counts[
				Join@@
					Map[
						Pick[
							Keys@totalNuclearRep, 
							MemberQ[#]/@
								CharacterTableData[ct,"LinearFunctions"]
							]&,
						Join[
							{\[FormalCapitalR][\[FormalX]], \[FormalCapitalR][\[FormalY]], \[FormalCapitalR][\[FormalZ]]},
							Subsets[{\[FormalCapitalR][\[FormalX]], \[FormalCapitalR][\[FormalY]], \[FormalCapitalR][\[FormalZ]]}, {2,3}]
							]
					]
				];
		vibrations=
			Association@
				KeyValueMap[
					#->
						(#2 - ( Lookup[translations, #, 0] + Lookup[rotations, #, 0] ))&,
					totalNuclearRep
					];
		<|
			"Translations"->	
				translations,
			"Rotations"->
				rotations,
			"Vibrations"->
				vibrations
			|>
		];
CharacterTableModeRepresentations[
	ct_,
	redRep:{__Integer}
	]:=
	CharacterTableModeRepresentations[ct,
		CharacterTableReduceRepresentation[
			ct,
			redRep
			]
		];
CharacterTableModeRepresentations[
	ct_,
	fmapping_Association?(Not@*KeyMemberQ["Elements"]),
	coords_List
	]:=
	CharacterTableModeRepresentations[ct,
		CharacterTableReduceRepresentation[
			ct,
			CharacterTableTotalRepresentation[
				fmapping,
				coords
				]
			]
		];
CharacterTableModeRepresentations[
	ct_,
	fmapping_Association?(Not@*KeyMemberQ["Elements"]),
	coordVecs:charTableRepListCoordVecPat
	]:=
	CharacterTableModeRepresentations[ct,
		CharacterTableReduceRepresentation[
			ct,
			CharacterTableTotalRepresentation[
				fmapping,
				coordVecs
				]
			]
		];


(* ::Subsection:: *)
(*Formatting*)



CharacterTableFormatReducedRepresentation[irrepAssoc_]:=
	Interpretation[
		Total@KeyValueMap[#["Formatted"]*#2&, irrepAssoc],
		irrepAssoc
		]


CharacterTableFormatSALCs[salcs_, irrepSelection_:All]:=
	Map[
		If[ListQ@irrepSelection,
			AssociationThread[
				Lookup[irrepSelection,"Formatted"],
				Map[MatrixForm]@Lookup[#,irrepSelection]
				],
			Map[Map[MatrixForm]@*KeyMap[Key@"Formatted"]]@salcs
			]&,
		salcs
		]//Dataset


(* ::Subsection:: *)
(*SALCs*)



(* ::Subsubsection::Closed:: *)
(*SymmetryAdaptedProjection*)



charTabIrrepDims=
	<|
		"A"->1,
		"B"->1,
		"E"->2,
		"T"->3
		|>;


CharacterTableSymmetryAdaptedProjection//Clear


$CharacterTableSALCRounding=.1


CharacterTableSymmetryAdaptedProjection[
	center_,
	symmetryFunctions_List,
	irrepRow_List,
	irrepDim_Integer,
	vec:{Repeated[_?NumericQ,{3}]},
	coords:{Repeated[{Repeated[_?NumericQ,{3}]},{1,\[Infinity]}]}
	]:=
	Total[
		MapThread[
			If[ListQ@#,
				Sequence@@(#2*Map[#-center&, Through[#@(vec+center)]]),
				#2*(#[vec+center]-center)
				]&,
			{
				Take[symmetryFunctions, UpTo[Length[irrepRow]]],
				irrepRow
				}
			](*//Last@Echo@{vec, #, coords}&*)
		];


CharacterTableSymmetryAdaptedProjection[
	ct_CharacterTable,
	repsToTry:_String|{__String}|All,
	sMapping_Association,
	vec:{Repeated[_?NumericQ,{3}]},
	coords:{Repeated[{Repeated[_?NumericQ,{3}]},{1,\[Infinity]}]}
	]:=
	With[
		{
			irrepPos=
				If[repsToTry===All,
					All,
					Position[
						CharacterTableData[ct, "IrreducibleRepresentations"],
						_Association?(StringMatchQ[Alternatives@@Flatten@{repsToTry}]@*Key["ID"]),
						{1}
						][[All,1]]
					],
			irreps=
				CharacterTableData[ct, "IrreducibleRepresentations"],
			cTab=
				CharacterTableData[ct, "CharacterTable"],
			symmetryFunctions=
				Flatten@Lookup[
					Lookup[
						sMapping,
						CharacterTableData[ct, "SymmetryClasses"]
						],
					"Functions"
					]
			},
		MapThread[
			CharacterTableSymmetryAdaptedProjection[
				sMapping["SourceElements", "Center"],
				symmetryFunctions,
				#2,
				charTabIrrepDims[#["Type"]],
				vec,
				coords
				]&,
			{
				irreps[[irrepPos]],
				cTab[[irrepPos]]
				}
			]
		];
CharacterTableSymmetryAdaptedProjection[
	ct_CharacterTable,
	repsToTry:_String|{__String}|All,
	sMapping_Association,
	coords:{
		Repeated[{Repeated[_?NumericQ,{3}]},{1,\[Infinity]}]
		}
	]:=
	Map[
		CharacterTableSymmetryAdaptedProjection[
			ct,
			repsToTry,
			sMapping,
			#,
			coords
			]&,
		coords
		]


(* ::Subsubsection::Closed:: *)
(*SALCs*)



charTableSalcCoordsPat=
	{(_->{_,_,_})..};


CharacterTableSALCs//Clear


CharacterTableSALCs[
	ct_CharacterTable,
	repsToTry:_String|{__String}|All:All,
	sMapping_Association,
	testCoords:({{_,_,_}..}|Automatic):Automatic,
	coords:charTableSalcCoordsPat
	]:=
	With[
		{
			irreps=
				Map[
					CharacterTableSymmetryAdaptedProjection[
						ct,
						repsToTry,
						sMapping,
						#,
						coords[[All,2]]
						]&,
					Replace[testCoords, Automatic:>coords[[All,2]]]
					]//Transpose,
			coordSys=	
				Transpose@coords[[All,2]],
			coordVars=
				coords[[All,1]]
			},
		Association@
			MapThread[
				#2->
					Replace[{i_}:>i]@
					Map[
						Dot[coordVars, #]&,
						DeleteDuplicates[
							Function[
								Normalize@
									Round[
										Quiet@
											Check[
												LinearSolve[coordSys, #],
												LeastSquares[coordSys, #]
												],
										1
										]
								]/@#,
							#==-#2||#==#2&
							]
						]&,
				{
					irreps,
					If[repsToTry===All,
						CharacterTableData[ct, "IrreducibleRepresentations"],
						Select[
							CharacterTableData[ct, "IrreducibleRepresentations"],
							StringMatchQ[Alternatives@@Flatten@{repsToTry}]@*Key["ID"]
							]
						]
					}
				]
		];
CharacterTableSALCs[
	ct_CharacterTable,
	repsToTry:_String|{__String}|All:All,
	sMapping_Association,
	coords_Association?(KeyMemberQ["Coordinates"]),
	which:("Stretches"|"Bends"|{("Stretches"|"Bends")..}):
		{"Stretches", "Bends"}
	]:=
	DeleteCases[None]@
		AssociationMap[
			With[{crds=
				With[{type=Switch[#, "Stretches", \[FormalR], "Bends", \[FormalTheta], "Wags", \[FormalCurlyPhi]]},
						MapIndexed[
							type[#2[[1]]]->#&,
							Mean/@coords["Coordinates", #]
							]
						]
				},
				If[Length@crds>0,
					CharacterTableSALCs[
						ct,
						repsToTry,
						sMapping,
						crds
						],
					None
					]
				]&,
			DeleteDuplicates@Flatten@{which}
			]


(* ::Subsection:: *)
(*VMA*)



AtomsetVibrationalAnalysis//Clear


Options[AtomsetVibrationalAnalysis]=
	{
		"VibrationalCoordinates"->Automatic,
		"ModeBreakdown"->True,
		"VibrationalBreakdown"->True,
		"SALCs"->True
		};
AtomsetVibrationalAnalysis[as_,
	axes:{{_?NumericQ, _, _}, {_?NumericQ, _, _}, {_?NumericQ, _, _}}|Automatic:
		Automatic
	]:=
	Module[
		{
			symEls=AtomsetSymmetryElements[as],
			pg,
			ct,
			symFs,
			vibCrds,
			cartRepList,
			totalRep,
			totalRepModes,
			vibRepList,
			vibRep,
			salcs
			},
		pg=ChemUtilsPointGroup[symEls];
		ct=CharacterTableData[pg];
		symFs=
			CharacterTableSymmetryFunctions[ct, symEls];
		vibCrds=
			AtomsetVibrationalCoordinates[as, {"Coordinates"}];
		cartRepList=
			CharacterTableReducibleRepresentationsList[
					symFs, 
					ChemGet[ChemGet[as,"Atoms"], "Position"]
					];
		totalRep=
			CharacterTableTotalRepresentation[cartRepList];
		totalRepModes=
			CharacterTableModeRepresentations[ct,
				CharacterTableReduceRepresentation[ct, totalRep]
				];
		vibRepList=
			AssociationMap[
				CharacterTableReducibleRepresentationsList[
					symFs, vibCrds, #
					]&,
				{"Stretches", "Bends"}
				];
		vibRep=
			AssociationMap[
				CharacterTableReduceRepresentation[ct,
					CharacterTableTotalRepresentation[vibRepList[#]]
					]&,
				{"Stretches", "Bends"}
				];
		If[AnyTrue[vibRep["Bends"], Not@*IntegerQ],
			vibRep["Bends"]=
				Association@
					KeyValueMap[
						#->
							(#2-Lookup[vibRep["Stretches"], #, 0])&,
						totalRepModes["Vibrations"]
						]
			];
		vibRepList=
			AssociationMap[
				Map[
					CharacterTableReduceRepresentation[ct, Total[#]]&,
					vibRepList[#]
					]&,
				{"Stretches", "Bends"}
				];
		salcs=CharacterTableSALCs[ct, symFs, vibCrds];
		<|
			"PointGroup"->pg,
			"SymmetryElements"->symEls,
			"CharacterTable"->ct,
			"CharacterTableFunctions"->symFs,
			"VibrationalCoordinates"->vibCrds,
			"ReducibleRepresentations"->cartRepList,
			"TotalReducibleRepresentation"->totalRep,
			"ModeIrreducibleRepresentations"->totalRepModes,
			"VibrationalRepresentations"->vibRepList,
			"VibrationalIrreducibleRepresentations"->vibRep,
			"SALCs"->salcs
			|>
		]


(* ::Subsubsection::Closed:: *)
(*validOrbitalConfiguration*)



validOrbitalConfiguration//Clear


electronConfigOrbitalPat=
	(_ElectronOrbitalConfiguration|_ElectronOctahedralOrbitalConfiguration)?
		validOrbitalConfiguration


validOrbitalConfiguration[
	(
		ElectronOrbitalConfiguration|
		ElectronOctahedralOrbitalConfiguration
		)[a:KeyValuePattern[{"Type"->_, "Count"->_, "Level"->_}]]
	]:=True;
validOrbitalConfiguration[___]:=
	False


(* ::Subsubsection::Closed:: *)
(*parse*)



parseOrbitalConfigurationExplicit[s_]:=
	StringReplace[s,
		n:DigitCharacter..~~t:(LetterCharacter?LowerCaseQ)~~
			c:DigitCharacter..:>
			<|
				"Type"->t,
				"Level"->ToExpression[n],
				"Count"->ToExpression[c]
				|>
		];
parseOrbitalConfigurationImplicit[s_]:=
	parseInternalElectronConfiguration@
		ChemDataLookup[StringTrim[s, "["|"]"], "ElectronConfiguration"];
parseInternalElectronConfiguration[l_List]:=
	Flatten@MapIndexed[
		With[{n=#2[[1]]},
			MapThread[
				<|
					"Level"->n,
					"Type"->#2,
					"Count"->#
					|>&,
				{
					#,
					Take[{"s", "p", "d", "f", "g", "h", "i"},
						Length[#]
						]
					}
				]
			]&,
		l
		]


(* ::Subsubsection::Closed:: *)
(*OrbitalConfiguration*)



ElectronOrbitalConfiguration[s_String]:=
	Replace[
		parseOrbitalConfigurationExplicit[s],
		{
			StringExpression[a_Association]:>ElectronOrbitalConfiguration[a],
			e_String:>
				Replace[
					parseOrbitalConfigurationImplicit[e],
					{
						a:{__Association}:>
							Thread[ElectronOrbitalConfiguration[a]],
						_->$Failed
						}
					]
			}
		];
ElectronOrbitalConfiguration[a_Association, b_Association]:=
	ElectronOrbitalConfiguration[Join[b,a]];
ElectronOrbitalConfiguration[a_Association][k__]:=
	a[k];
ElectronOrbitalConfiguration/:
	Normal[ElectronOrbitalConfiguration[a_Association]]:=a;
Format[
	ElectronOrbitalConfiguration[a:KeyValuePattern[{"Type"->_, "Count"->_, "Level"->_}]]
	]:=
	RawBoxes@
		TemplateBox[
			ToBoxes/@Append[Lookup[a, {"Level","Type", "Count"}], a],
			"ElectronOrbitalConfiguration",
			DisplayFunction->
				Function[
					StyleBox[
						RowBox[{#,"\[InvisibleSpace]",SuperscriptBox[#2,#3]}],
						ShowStringCharacters->False
						]
					],
			InterpretationFunction->
				Function[
					RowBox[{
						"ElectronOrbitalConfiguration","[",
						ToBoxes@
							<|
								"Level"->RawBoxes@#,
								"Type"->RawBoxes@#2,
								"Count"->RawBoxes@#3
								|>,
						",",
						#4,
						"]"
						}]
					]
			]


(* ::Subsubsection::Closed:: *)
(*OctahedralOrbitalConfiguration*)



ElectronOctahedralOrbitalConfiguration[a_Association, b_Association]:=
	ElectronOctahedralOrbitalConfiguration[Join[b,a]];
ElectronOctahedralOrbitalConfiguration[a_Association][k__]:=
	a[k];
ElectronOctahedralOrbitalConfiguration/:
	Normal[ElectronOctahedralOrbitalConfiguration[a_Association]]:=a;
Format[
	ElectronOctahedralOrbitalConfiguration[
		a:KeyValuePattern[{"Type"->_, "Count"->_, "Level"->_, "FieldStrength"->_}]
		]
	]:=
	RawBoxes@
		TemplateBox[
			ToBoxes/@Append[Lookup[a, {"Level","Type", "Count"}], a],
			"ElectronOctahedralOrbitalConfiguration",
			DisplayFunction->
				Function[
					StyleBox[
						SubscriptBox[
							RowBox[{#,"\[InvisibleSpace]",SuperscriptBox[#2,#3]}],
							SubscriptBox["\"O\"", "\"h\""]
							],
						ShowStringCharacters->False
						]
					],
			InterpretationFunction->
				Function[
					RowBox[{
						"ElectronOctahedralOrbitalConfiguration","[",
						ToBoxes@
							<|
								"Level"->RawBoxes@#,
								"Type"->RawBoxes@#2,
								"Count"->RawBoxes@#3
								|>,
						",",
						#4,
						"]"
						}]
					]
			]


(* ::Subsubsection::Closed:: *)
(*ElectronConfiguration*)



electronConfigurationVectorPattern=
	{
		(
			_ElectronOrbitalConfiguration|
			_ElectronOctahedralOrbitalConfiguration
			)?validOrbitalConfiguration..
		};


sortElectronConfiguration[l_List]:=
	SortBy[
		l,
		#["Level"]+
			Switch[#["Type"],
				"s",
					0,
				"p",
					1,
				"d",
					2,
				"f",
					3,
				"g",
					4
				]&
		]


ElectronConfiguration//Clear


ElectronConfiguration[s_String]:=
	With[{
		eBase=ElectronOrbitalConfiguration/@StringSplit[s]//Flatten
		},
		ElectronConfiguration[
			sortElectronConfiguration[eBase]
			]/;AllTrue[eBase, validOrbitalConfiguration]
		];
ElectronConfiguration[l:electronConfigurationVectorPattern]/;(
	Length[DeleteDuplicates[#]]!=
		Length[#]&@Lookup[Normal/@l, {"Level", "Type"}]
	):=
	ElectronConfiguration@
	sortElectronConfiguration@
		Map[
			Head[#[[1]]]@
				ReplacePart[
					Normal[#[[1]]],
					"Count"->
						Total@Lookup[Normal/@#,"Count"]
					]&,
			GatherBy[
				l,
				Lookup[Normal@#, {"Level", "Type"}]&
				]
			];
ElectronConfiguration/:
	Part[
		ElectronConfiguration[l:electronConfigurationVectorPattern],
		i_,
		r___
		]:=
	If[Length@{r}>0,
		l[[i]][r],
		l[[i]]
		];
ElectronConfiguration/:
	Normal[ElectronConfiguration[l:electronConfigurationVectorPattern]]:=
		Normal/@l;
ElectronConfiguration/:
	Map[f_, ElectronConfiguration[a_]]:=
		Map[f, a];
Format[
	ElectronConfiguration[
		o:electronConfigurationVectorPattern
		]
	]:=
	RawBoxes@
		TemplateBox[
			ToBoxes/@o,
			"ElectronConfiguration",
			DisplayFunction->
				(StyleBox[RowBox[{"[", ##, "]"}], ShowStringCharacters->False]&),
			InterpretationFunction->
				Function[
					RowBox[
						Flatten@{
							"ElectronConfiguration","[","{",
							Riffle[
								Map[
									Lookup[Options[#, InterpretationFunction], InterpretationFunction]@@
										#[[1]]&,
									{##}
									],
								","
								],
							"}",
							"]"
							}
						]
					]
			]


(* ::Subsubsection::Closed:: *)
(*orbitalTypeIndexed*)



orbitalTypeIndexed[t_]:=
	Switch[ToLowerCase[t],
		"s",
			1,
		"p",
			2,
		"d",
			3,
		"f",
			4,
		_,
			With[{n=LetterNumber[t]},
				If[n>10,
					n-7,
					n-6
					]
				]
		];
orbitalTypeFromIndex[i_Integer]:=
	Switch[i,
		1,
			"s",
		2,
			"p",
		3,
			"d",
		4,
			"f",
		_,
			FromLetterNumber@
				If[i>10,
					i+4,
					i+3
					]
			]


(* ::Subsubsection::Closed:: *)
(*orbitalTypeDegOrbitalCount*)



orbitalTypeDegOrbitalCount//Clear


orbitalTypeDegOrbitalCount[t_]:=
	Replace[t,
		{
			Subscript["e", "g"]->2,
			Subscript["t", "2g"]->3,
			e_ElectronOctahedralOrbitalConfiguration:>
				orbitalTypeDegOrbitalCount[e["Type"]],
			i_Integer:>
				1+2*(i-1),
			s_String:>
				orbitalTypeDegOrbitalCount[orbitalTypeIndexed[s]],
			o_ElectronOrbitalConfiguration:>
				orbitalTypeDegOrbitalCount[orbitalTypeIndexed@o["Type"]]
			}
		]


(* ::Subsubsection::Closed:: *)
(*unfilledOrbitals*)



electronConfigUnfilledOrbitals[e_ElectronConfiguration]:=
	Select[
		AssociationMap[
			electronConfigUnfillillingCount,
			First@e
			],
		GreaterThan[0]
		];
electronConfigUnfillillingCount[e:electronConfigOrbitalPat]:=
	(2*orbitalTypeDegOrbitalCount[e["Type"]]-e["Count"]);
electronConfigElectronArrangements[e:electronConfigOrbitalPat]:=
	Binomial[
		2*orbitalTypeDegOrbitalCount[e["Type"]],
		e["Count"]
		];


(* ::Subsubsection::Closed:: *)
(*microstates*)



electronConfigOrbMicrostates[e:electronConfigOrbitalPat]:=
	With[
		{
			o=e["Count"],
			d=orbitalTypeDegOrbitalCount[e]
			},
		With[{keys=Range[-Floor[d/2], Floor[d/2]]},
			Subsets[
				Flatten@Table[{n->1/2, n->-1/2},{n, keys}],
				{o}
				]
			]
		];
electronConfigMicrostates[e_ElectronConfiguration]:=
	Tuples@Map[electronConfigOrbMicrostates, e]


(* ::Subsubsection::Closed:: *)
(*Angular Momenta and Term Symbols*)



electronConfigOrbAngMomenta[microstates_]:=
	With[
		{
			lSums=
				Total@*Keys@*Flatten/@microstates,
			sSums=
				Total@*Values@*Flatten/@microstates
			},
		<|
			"OrbitalAngularMomentum"->
				Max[lSums],
			"SpinAngularMomentum"->
				Max[sSums],
			"TotalAngularMomentum"->
				Max[lSums+sSums]
			|>
		];


electronConfigTermSymbols[config_, moms_]:=
	With[{
		base=
			<|
				"TermSymbol"->
					If[MatchQ[config, _ElectronOctahedralOrbitalConfiguration],
						Replace[config["Type"],{
							Subscript[t_, l_]:>
								Subscript[ToUpperCase[t], l],
							s_String:>ToUpperCase[s]
							}],
						ToUpperCase@
							orbitalTypeFromIndex[moms["OrbitalAngularMomentum"]+1]
						],
				"SpinState"->
					1+moms["SpinAngularMomentum"]*2
				|>
		},
		Append[base,
			"Formatted"->
				Style[
					Row@{
						Superscript["", base["SpinState"]], 
						base["TermSymbol"]
						},
					ShowStringCharacters->False,
					StripOnInput->False
					]
			]
		]


(* ::Subsubsection::Closed:: *)
(*ElectronConfigurationData*)



ElectronConfigurationData[e_ElectronConfiguration]:=
	Module[
		{
			unfilled=electronConfigUnfilledOrbitals[e],
			microstates=electronConfigMicrostates[e],
			freeDenegeracies,
			momenta,
			terms
			},
		freeDenegeracies=
			AssociationMap[electronConfigElectronArrangements, Keys[unfilled]];
		momenta=
			electronConfigOrbAngMomenta[microstates];
		terms=
			Map[
				electronConfigTermSymbols[#, momenta]&,
				e
				];
		<|
			"UnfilledOrbitals"->
				unfilled,
			"FreeIonDegeneracies"->
				freeDenegeracies,
			"Microstates"->
				microstates,
			"AngularMomenta"->
				momenta,
			"TermSymbols"->
				terms
			|>
		]


(* ::Subsubsection::Closed:: *)
(*ElectronConfigurationGraphics*)



ElectronConfigurationGraphicsObjects[
	"OrbitalLines",
	orb_ElectronOrbitalConfiguration,
	pos:{_, _}:{0, 0},
	lineSize_:.1, lineGap_:.025,
	arrowSize_. 1, arrowGap_:.025
	]:=
	Table[
		Line[
			Map[
				pos+{(n-1)*(lineSize+lineGap), 0}+#&,
				{{0,0},lineSize*{1, 0}}
				]
			],
		{n, orbitalTypeDegOrbitalCount[orb]}
		]


ElectronConfigurationGraphicsObjects[
	"ElectronArrows",
	orb_ElectronOrbitalConfiguration,
	pos:{_, _}:{0, 0},
	lineSize_:.1, lineGap_:.025,
	arrowSize_:.1, arrowGap_:.025
	]:=
	With[{
		ord=orbitalTypeDegOrbitalCount[orb]
		},
	Table[
		Arrow[
			If[n<0, Reverse, Identity]@
			Map[
				pos+{(Abs[n]-1)*(lineSize+lineGap), 0}+#&,
				{
					{If[n>0, .25, .75]*lineSize, arrowGap/4}, 
					{If[n>0, .25, .75]*lineSize, arrowSize+arrowGap/4}
					}
				]
			],
		{n, 
			Join[
				Range[Min@{orb["Count"], ord}],
				Range[
					-1,
					ord-orb["Count"],
					-1
					]
				]
			}
		]
		]


ElectronConfigurationGraphics//Clear


Options[ElectronConfigurationGraphics]=
	Join[
		{
			"ElectronArrowHeight"->.1,
			"ElectronArrowGap"->.05,
			"OrbitalLineWidth"->.1,
			"OrbitalLineGap"->.025,
			"LevelSpacingFunction"->Function[50*(1-1/(#)^.1)]
			},
		Options[Graphics]
		];
ElectronConfigurationGraphics[
	e_ElectronConfiguration,
	others:{}|Except[_?OptionQ]:{},
	ops:OptionsPattern[]
	]:=
	With[
		{
			lineSize = OptionValue["OrbitalLineWidth"],
			lineGap  = OptionValue["OrbitalLineGap"],
			arrowSize= OptionValue["ElectronArrowHeight"],
			arrowGap = OptionValue["ElectronArrowGap"],
			ef       = OptionValue["LevelSpacingFunction"]
			},
	Graphics[
		{
			Arrowheads[.03],
			others,
			Map[
				With[
					{
						cent=
							{
								(lineSize+2*lineGap)*
									Total@
										Map[
											orbitalTypeDegOrbitalCount,
											Range[orbitalTypeIndexed[#["Type"]]-1]
											],
								ef[#["Level"]]*(arrowSize+arrowGap)+
									orbitalTypeIndexed[#["Type"]]*arrowSize
								}
						},
					Prepend[
						Text[ReplacePart[#, {1, "Count"}->""],
							{lineGap, 0}+cent,
							Left
							]
						]@
					Table[
						ElectronConfigurationGraphicsObjects[t,
							#,
							{2.5*lineGap, 0}+cent,
							lineSize, lineGap,
							arrowSize, arrowGap
							],
						{t,
							{"OrbitalLines","ElectronArrows"}
							}
						]
					]&,
				e
				]
			},
		FilterRules[{ops},
			Options@Graphics
			]
		]
	]


(* ::Subsubsection::Closed:: *)
(*Octahedral Field*)



ElectronConfigurationOctahedralField[
	e_ElectronConfiguration,
	fieldType:"Weak"|"Strong":"Weak"
	]:=
	ElectronConfiguration@
		Map[
			ElectronConfigurationOctahedralField[#, fieldType]&,
			e
			];
ElectronConfigurationOctahedralField[
	e_ElectronOrbitalConfiguration,
	fieldType:"Weak"|"Strong"
	]:=
	If[e["Type"]==="d",
		Sequence@@Map[ElectronOctahedralOrbitalConfiguration]@
			If[fieldType==="Weak", Reverse, Identity]@
			{
				Join[
					Normal[e],
					<|
						"Type"->Subscript["e","g"],
						"Count"->
							If[fieldType==="Weak",
								Max@{e["Count"]-6,0},
								Min@{e["Count"], 4}
								],
						"FieldStrength"->fieldType
						|>
					],
				Join[
					Normal[e],
					<|
						"Type"->Subscript["t","2g"],
						"Count"->
							If[fieldType==="Weak",
								Min@{e["Count"], 6},
								Max@{e["Count"]-4, 0}
								],
						"FieldStrength"->fieldType
						|>
					]
				},
		ElectronOctahedralOrbitalConfiguration[
			Append[Normal[e], "FieldStrength"->fieldType]
			]
		]


TanabeSuganoData[dElectrons:Alternatives@@Range[2,8]]:=
	$ChemTanabeSuganoData[[dElectrons]];
TanabeSuganoData[ec_]:=
	With[{els=DElectronCount[ec]},
		TanabeSuganoData[ec]/;2<=els<=8
		]


Options[TanabeSuganoDiagram]=
	Options[ListLinePlot]
TanabeSuganoDiagram[
	rawData_:Association,
	selection:{__String}|All:All,
	ops:OptionsPattern[]
	]:=
	With[{data=
		Replace[
			Replace[selection,
				{
					{All}->All,
					{a___,All,b___}:>
						If[Length@{a,b}>0,
							Alternatives@@Flatten@{a,b},
							All
							],
					l_:>Alternatives@@l
					}
				],{
			All:>rawData,
			l_Alternatives:>
				KeySelect[rawData, MatchQ[#ID, l]&]
			}]
		},
	ListLinePlot[
		Values@data,
		ops,
		PlotLegends->
			Map[Key["Formatted"], Keys[data]],
		PlotRange->{0,All},
		GridLines->Automatic,
		GridLinesStyle->Directive@@{Thin,LightGray, Dashed},
		ImageSize->Medium,
		LabelStyle->{Background->White}
		]
	];
TanabeSuganoDiagram[ec_,
	selection:{__String}|All:All,
	ops:OptionsPattern[]
	]:=
	With[{dats=TanabeSuganoData[ec]},
		TanabeSuganoDiagram[dats,
			selection,
			ops
			]/;AssociationQ[dats]
		]


Options[TanabeSuganoDiagramInteractive]=
	Options[TanabeSuganoDiagram];
TanabeSuganoDiagramInteractive[
	rawData_:Association,
	ops:OptionsPattern[]
	]:=
DynamicModule[
	{
		selection,
		data,
		heads,
		sel1,max,
		yLinePoint,linePoint=0,
		maxX,repSym
		},
	selection={All};
	sel1=All;
	max=Max[Cases[Flatten@Values@data,_?NumberQ]];
	With[{L=Length@data},
		{
			{
			{
				Slider[Dynamic@yLinePoint,{0,max},Appearance->"Vertical"],
				Dynamic@
				Labeled[
					Show[
					TanabeSuganoDiagram[data, sel , ops],
					ListLinePlot[{
						{{linePoint,0},{linePoint,max}},
						{{0,yLinePoint},{maxX,yLinePoint}},
						{{linePoint,yLinePoint}}
						},
						PlotStyle->{{Thin,Black},{Thin,Black},{Black}},
						Joined->True
						]
						],
				{
					RawBoxes[FractionBox["\"E\"","\"B\"", "Beveled"->True]],
					RawBoxes[FractionBox["\"\[CapitalDelta]\"","\"B\"", "Beveled"->True]]
					},
				{Left,{Bottom,Center}}
				]},
			{Null,Slider[Dynamic@linePoint,{0,maxX},ImageSize->Large]},
			{Null,Row@{" Line Position: ",Dynamic@NumberForm[{linePoint,yLinePoint},3]}}
			}//Grid[#,Alignment->Left]&//Framed[Panel[#,Background->White]]&,
		Slider[Dynamic[If[sel1===All,1,sel1],((sel1=#;
				selection=
				If[selection[[1]]===sel1,selection,
					ReplacePart[DeleteCases[selection,sel1],1->sel1]
					])&)],{1,L,1}],
			{Control@{{selection,{All},""},{{All}->"  All  "},ControlType->SetterBar},
				Row[(Table[
						With[{rmin=1+5*(i-1),rmax=Min@{5*i,L}},
							Control@{
								{selection, {All}, ""},
								TogglerBar[#,
									Map[
										#["ID"]->#["Formatted"],
										Keys[data][[rmin;;rmax]]
										],
									Appearance->"Vertical"
									]&}
							],
						{i,Floor[L/5]}]~Append~
					If[Mod[L,5]=!=0,
						With[{rmin=1+L-Mod[L,5],rmax=L},
							Control@{{selection,{All},""},
								TogglerBar[#,
									Map[
										#["ID"]->#["Formatted"],
										Keys[data][[rmin;;rmax]]
										],
									Appearance->"Vertical"
									]&}
							],Null]
						),BaselinePosition->Top]
				}//Column[#,Alignment->Center]&
			}//Column[#,Dividers->{None,{2->{Black,Thick}}}]&//Panel//Deploy
			]
		];


End[];



