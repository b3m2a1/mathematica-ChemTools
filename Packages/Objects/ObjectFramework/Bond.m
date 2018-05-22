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



(* ::Subsection:: *)
(*Bond Methods*)



CreateBond::usage=
	"Creates a bond";


BondCanFormQ::usage="";
BondFormedQ::usage="";
BondForm::usage="Creates a bond";
BondBreak::usage="Breaks a bond";


BondCenter::usage=
	"Gets the raw bond center";
BondCenterOfMass::usage=
	"Gets the bond COM";
BondMove::usage=
	"Moves a bond";
BondRotate::usage=
	"Rotates a bond";
BondNormal::usage=
	"Comuptes the normal to a bond-point plane";
BondTransform::usage=
	"Applies a transform to a bond";
BondRotationTransform::usage=
	"Returns a RotationTransform on the bond axis";


BondPolarization::usage="Gets bond polarization";
BondVector::usage="Gets a bond vector";
BondDeviation::usage="Gets a bond's deviation from its standard distance";


BondColors::usage=
	"Returns the colors for a bond";
BondGraphic::usage="Gets a 2D bond graphics object";
BondGraphic3D::usage="Gets a 3D bond graphics object";


Begin["`Private`"];


(* ::Subsection:: *)
(*Bond Class*)



(*$ChemObjectDefaults["Bond"]=.*)


If[!KeyMemberQ[$ChemObjectDefaults, "Bond"],
	$ChemObjectDefaults["Bond"]=
			<|
				"Atoms"->{},
				"Type"->1,
				"Strength"->Automatic,
				"Color"->{Automatic,Automatic},
				
				"Form"->ChemMethod[BondForm],
				"Break"->ChemMethod[BondBreak],
				"CanForm"->ChemProperty[BondCanFormQ],
				"Formed"->ChemProperty[BondFormedQ],
				
				"Rotate"->ChemMethod[BondRotate],
				"Move"->ChemMethod[BondMove],
				"Transform"->ChemMethod[BondTransform],
				
				"Center"->ChemProperty[BondCenter],
				"CenterOfMass"->ChemProperty[BondCenterOfMass],
				"Vector"->ChemProperty[BondVector],
				"Normal"->ChemProperty[BondNormal],
				
				"Graphic"->ChemMethod[
					With[{o={##}},
						BondGraphic[First@o,
							Sequence@@FilterRules[Rest@o,Options@BondGraphic]]
							]&
					],
				"Graphic3D"->ChemMethod[
					With[{o={##}},
						BondGraphic3D[First@o,
							Sequence@@FilterRules[Rest@o,Options@BondGraphic3D]]
						]&
					]
			|>
  ];


(* ::Subsection:: *)
(*Bond Props*)



(* ::Subsubsection::Closed:: *)
(*Create*)



CreateBond[sys:ChemSysPattern|Automatic:Automatic,
	atom1:ChemObjPattern,atom2:ChemObjPattern,
	btype_:Automatic,
	others___]:=
	With[{bops=If[btype=!=Automatic,Prepend[{others},"Type"->btype],{others}]},
		ChemAdd[Replace[sys,Automatic:>$ChemDefaultSystem],
			"Bond",
			"Atoms"->{atom1,atom2},
			Sequence@@bops
			]
		];


(* ::Subsubsection::Closed:: *)
(*CanFormQ*)



BondCanFormQ[obj:ChemObjPattern]:=
	With[{a=ChemGet[obj,"Atoms"]},
		!MemberQ[Flatten@ChemGet[a,"Bonds"],obj]&&
			AtomCanBondQ[First@a,Last@a,ChemGet[obj,"Type"]]
		];


(* ::Subsubsection::Closed:: *)
(*FormedQ*)



BondFormedQ[obj:ChemObjPattern]:=
	MemberQ[Flatten@ChemGet[ChemGet[obj,"Atoms"],"Bonds"],obj]


(* ::Subsubsection::Closed:: *)
(*Form*)



BondForm[obj:ChemObjPattern,check:True|False:True]:=
	If[(!check)||BondCanFormQ[obj],
		With[{a=ChemGet[obj,"Atoms"]},
			AtomAddBond[a,obj];
			ChemAddReference[obj,a];
			],
		$Failed
		];


(* ::Subsubsection::Closed:: *)
(*Break*)



BondBreak[obj:ChemObjPattern]:=
	If[BondFormedQ[obj],
		AtomRemoveBond[ChemGet[obj,"Atoms"],obj];
		obj,
		$Failed
		];


(* ::Subsubsection::Closed:: *)
(*Vector*)



BondVector[obj:ChemObjPattern]:=
	Subtract@@
		ChemGet[
			ChemGet[obj,"Atoms"],
			"Position"
			];
BondVector[objV:ChemObjVectorPattern]:=
	Subtract@@@ChemGet[ChemGet[objV,"Atoms"],"Position"];


(* ::Subsubsection::Closed:: *)
(*CenterOfMass*)



BondCenterOfMass[obj:ChemObjPattern]:=
	With[{
		a=ChemGet[obj,"Atoms"]
		},
		With[{
			p=ChemGet[a,"Position"],
			m=ChemGet[a,"Mass"]
			},
			Mean@WeightedData[p,m]
			]
		]
BondCenterOfMass[objV:ChemObjVectorPattern]:=
	With[{
		a=ChemGet[objV,"Atoms"]
		},
		With[{
			p=ChemGet[a,"Position"],
			m=ChemGet[a,"Mass"]
			},
			Mean/@MapThread[WeightedData,{p,m}]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Center*)



BondCenter[obj:ChemObjPattern]:=
	Mean@ChemGet["Position"]@ChemGet[obj,"Atoms"];
BondCenter[objV:ChemObjVectorPattern]:=
	Mean/@ChemGet[ChemGet[objV,"Atoms"],  "Position"];


(* ::Subsubsection::Closed:: *)
(*Move*)



BondMove[obj:ChemObjPattern,
	pt_,
	mode:"Set"|"Add":"Add"]:=
	With[{atoms=ChemGet[obj,"Atoms"]},
		Switch[mode,
			"Set",
				AtomMove[atoms,pt-BondCenter@obj,"Add"],
			"Add",
				AtomMove[atoms,pt,"Add"]
			]
		];
BondMove[objV:ChemObjVectorPattern,
	pt_,
	mode:"Set"|"Add":"Add"]:=
	With[{atoms=ChemGet[objV,"Atoms"]},
		Switch[mode,
			"Set",
				MapThread[AtomMove[#,pt-#2,"Add"]&,{
					atoms,
					BondCenter@objV
					}],
			"Add",
				AtomMove[Flatten@atoms,
					pt,
					"Add"
					]
			]
		];


(* ::Subsubsection::Closed:: *)
(*StandardDistance*)



BondStandardDistance[obj:ChemObjPattern]:=
	With[
		{
			els=ChemGet[ChemGet[obj,"Atoms"],"Element"],
			typ=ChemGet[obj,"Type"]
			},
		ChemDataLookup[
			ChemDataQuery@@Append[els,typ],
			"BondDistances"
			]
		];
BondStandardDistance[obj:ChemObjVectorPattern]:=
	With[
		{
			els=ChemGet[ChemGet[obj,"Atoms"],"Element"],
			typ=ChemGet[obj,"Type"]
			},
		ChemDataLookup[
			MapThread[
				ChemDataQuery@@Append[#,#2]&,
				{
					els,
					typ
					}],
			"BondDistances"
			]
		];


(* ::Subsubsection::Closed:: *)
(*Deviation*)



BondDeviation[obj:ChemObjPattern]:=
	With[
		{
			std=BondStandardDistance[obj],
			dis=Norm@BondVector[obj]
			},
		If[std>0,
			Subtract[dis,std],
			0
			]
		];
BondDeviation[objV:ChemObjVectorPattern]:=
	With[
		{
			std=BondStandardDistance[objV],
			dis=Norm/@BondVector[objV]
			},
		MapThread[
			If[#2>0,
				#,
				0
				]&,
			{
				Subtract[dis,std],
				std
				}
			]
		];


(* ::Subsubsection::Closed:: *)
(*Normal*)



BondNormal[obj:ChemObjPattern,pt:{_?NumericQ,_,_}]:=
	With[{ps=ChemGet["Position"]@ChemGet[obj,"Atoms"]},
		Cross[Subtract@@ps,pt-First@ps]
		];
BondNormal[objV:ChemObjVectorPattern,pt:{_?NumericQ,_,_}]:=
	With[{ps=ChemGet["Position"]@ChemGet[objV,"Atoms"]},
		Cross[Subtract@@#,pt-First@#]&/@ps
		];
BondNormal[objV:ChemObjVectorPattern,pts:{{_?NumericQ,_,_},___}]:=
	MapThread[Cross[Subtract@@#,#2-First@#]&,{
		ChemGet["Position"]@ChemGet[objV,"Atoms"],
		pts
		}];


(* ::Subsubsection::Closed:: *)
(*Rotate*)



BondRotate[obj:ChemObjPattern,
	theta_?NumericQ,axis_:{0,0,1},center_:"Center"]:=
	With[{atoms=ChemGet["Atoms"]@obj},
		AtomRotate[atoms,theta,axis,
			Switch[center,
				First|"Atom1",
					First@ChemGet[atoms,"Position"],
				Last|"Atom2",
					Last@ChemGet[atoms,"Position"],
				"Center",
					BondCenter@obj,
				"COM"|"CenterOfMass",
					BondCenterOfMass@obj,
				_?NumericQ,
					With[{positions=ChemGet[atoms,"Position"]},
						If[center>=0,
							First@positions+center*(Subtract@@positions),
							Last@positions+center*(Subtract@@positions)
							]
						],
				_,
					center
				]
		]	
	];
BondRotate[objV:ChemObjVectorPattern,
	theta_?NumericQ,axis_:{0,0,1},center_:"Center"]:=
	With[{atoms=ChemGet["Atoms"]@objV},
		With[{centers=
			Switch[center,
				First|"Atom1",
					First@ChemGet[atoms,"Position"],
				Last|"Atom2",
					Last@ChemGet[atoms,"Position"],
				"Center",
					BondCenter@objV,
				"COM"|"CenterOfMass",
					BondCenterOfMass@objV,
				_?NumericQ,
					With[{positions=ChemGet[atoms,"Position"]},
						If[center>=0,
							MapThread[First@#+center*#2&,
								{positions,Subtract@@@positions}],
							MapThread[Last@#+center*#2&,
								{positions,Subtract@@@positions}]
							]
						],
				_,
					center
				]
			},
				If[ListQ@First@centers,
					MapThread[AtomRotate[#,theta,axis,#2]&,{
						atoms,
						centers
						}],
					AtomRotate[Flatten@atoms,theta,axis,center]
					]
			]
		];


(* ::Subsubsection::Closed:: *)
(*RotationTransform*)



BondRotationTransform[obj:ChemObjPattern,
	theta_?NumericQ,axis_:"Bond",center_:"Center"]:=
	With[{atoms=ChemGet["Atoms"]@obj},
		RotationTransform[
			theta,
			Replace[axis,{
				"Bond":>
					BondVector@obj,
				_String->{0.,0.,1.}
				}],
			Switch[center,
				First|"Atom1",
					First@ChemGet[atoms,"Position"],
				Last|"Atom2",
					Last@ChemGet[atoms,"Position"],
				"Center",
					BondCenter@obj,
				"COM"|"CenterOfMass",
					BondCenterOfMass@obj,
				_?NumericQ,
					With[{positions=ChemGet[atoms,"Position"]},
						If[center>=0,
							First@positions+center*(Subtract@@positions),
							Last@positions+center*(Subtract@@positions)
							]
						],
				_,
					center
				]
			]
		];
BondRotationTransform[objV:ChemObjVectorPattern,
	theta_?NumericQ,axis_:"Bond",center_:"Center"]:=
	With[{atoms=ChemGet["Atoms"]@objV},
		With[{centers=
			Switch[center,
				First|"Atom1",
					First@ChemGet[atoms,"Position"],
				Last|"Atom2",
					Last@ChemGet[atoms,"Position"],
				"Center",
					BondCenter@objV,
				"COM"|"CenterOfMass",
					BondCenterOfMass@objV,
				_?NumericQ,
					With[{positions=ChemGet[atoms,"Position"]},
						If[center>=0,
							MapThread[First@#+center*#2&,
								{positions,Subtract@@@positions}],
							MapThread[Last@#+center*#2&,
								{positions,Subtract@@@positions}]
							]
						],
				_,
					Which[
						Length@center==0,
							ConstantArray[{0,0,0},Length@objV],
						Not@ListQ@First@center,
							ConstantArray[center,Length@objV],
						True,
							Take[Flatten[ConstantArray[center,Length@objV],1],Length@objV]
						]
				],
			axes=
				Replace[axis,{
					"Bond":>
						BondVector@objV,
					_String:>
						ConstantArray[{0.,0.,1.},Length@objV],
					_:>
						Which[
							Length@axis==0,
								ConstantArray[{0,0,1.},Length@objV],
							Not@ListQ@First@axis,
								ConstantArray[axis,Length@objV],
							True,
								Take[Flatten[ConstantArray[axis,Length@objV],1],Length@objV]
							]
					}]
			},
				MapThread[RotationTransform[theta,#2,#1]&,{
					centers,
					axes
					}]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Transform*)



BondTransform[objV:ChemObjAllPattern,transf_]:=
	With[{a=Flatten@DeleteDuplicates@ChemGet[objV,"Atoms"]},	
		AtomTransform[a,transf]
		];


(* ::Subsubsection::Closed:: *)
(*Polarization*)



BondPolarization[obj:ChemObjPattern]:=
	With[{a=ChemGet[obj,"Atoms"]},
		With[{
			en=Subtract@@ChemGet[a,"Electronegativity"],
			vec=Subtract@@ChemGet[a,"Position"]
			},
			en*Normalize@vec
			]
		];


(* ::Subsubsection::Closed:: *)
(*Colors*)



BondColors[obj:ChemObjPattern]:=
	With[{
		c=
			Replace[ChemGet[obj,"Color"],c:Except[_List]:>{c,c}]
			},
		With[{p=Flatten@Position[c,Except[_?ColorQ],1]},
			If[Length@p>0,
				With[{colors=
					ChemDataLookup[
						ChemGet[ChemGet[obj,"Atoms"],"Element"],
						"AtomColors"]},
					ReplacePart[c,
						Map[#->colors[[#]]&,p]
						]
					],
				c
				]
			]
		];
BondColors[objV:ChemObjVectorPattern]:=
	With[{
		colorSpecs=
			Replace[ChemGet[objV,"Color"],c:Except[_List]:>{c,c},1],
		colors=
			ChemDataLookup[
					ChemGet[#,"Element"],
					"AtomColors"]&/@ChemGet[objV,"Atoms"]
			},
		MapThread[
			With[{
				p=Flatten@Position[#,Except[_?ColorQ],1],
				cs=#2},
				If[Length@p>0,
					ReplacePart[#,
						Map[#->cs[[#]]&,p]
						],
					#
					]
				]&,{
			colorSpecs,
			colors
			}]
		];


With[{co=ChemObjPattern,cv=ChemObjVectorPattern,ca=ChemObjAllPattern},
	BondColors/:
		HoldPattern[Set[BondColors[obj_?(MatchQ[co])],color_]]:=(
			ChemSet[obj,"Color",color]
			);
	BondColors/:
		HoldPattern[SetDelayed[BondColors[obj_?(MatchQ[co])],color_]]:=
			ChemSetDelayed[obj,"Color",color];
	BondColors/:
		HoldPattern[Set[BondColors[obj:_?(MatchQ[cv])],color:Except[_List]]]:=
			ChemSet[obj,"Color",color];
	BondColors/:
		HoldPattern[SetDelayed[BondColors[objV_?(MatchQ[cv])],color:Except[_List]]]:=
			ChemSetDelayed[objV,"Color",color];
	BondColors/:
		HoldPattern[Set[BondColors[objV_?(MatchQ[cv])],color_List]]:=
			ChemThreadSet[objV,"Color",color];
	BondColors/:
		HoldPattern[SetDelayed[BondColors[objV_?(MatchQ[cv])],color_List]]:=
			ChemThreadSetDelayed[objV,"Color",color];
	BondColors/:
		HoldPattern[Unset[BondColors[obj_?(MatchQ[ca])]]]:=(
			ChemSet[obj,"Color",Automatic]
			);
		
	];


(* ::Subsubsection::Closed:: *)
(*Graphic*)



BondGraphicShapeFunction2D[
	colors_,
	positions_,
	radii_,
	label_,
	style_
	]:=
	{
		{
			Replace[style,
				None->Nothing
				],
			{
				First@colors,
				AbsoluteThickness[radii[[1]]],
				#[[;;2]]&/@positions[[;;2]]//Line
				},
			{
				Last@colors,
				AbsoluteThickness[radii[[2]]],
				#[[;;2]]&/@positions[[2;;]]//Line
				}
			},
			Replace[label,{
				None->Nothing,
				e_:>
					Text[
						Style[
							e,
							If[ColorDistance[colors[[1]], Black]>.7, Black, White]
							],
						Mean@positions[[All, ;;2]]
						]
				}]
			}


Options[BondGraphic]={
	"DoubleBondSeparation"->.0075,
	"TripleBondSeparation"->.0075,
	"BondThickness"->.05,
	"BondDashing"->.025,
	"RadiusScaling"->.125,
	"AtomicRadius"->Automatic,
	"BondColor"->Automatic,
	"BondShapeFunction"->Automatic,
	"BondLabel"->Automatic,
	"BondStyle"->Automatic
	};
BondGraphic[obj:ChemObjAllPattern,ops:OptionsPattern[]]:=
	With[{
		atoms=ChemGet[Flatten@{obj},"Atoms"],
		fn=
			Replace[
				OptionValue["BondShapeFunction"], 
				Automatic->BondGraphicShapeFunction2D
				],
		lab=
			Replace[
				OptionValue["BondLabel"],{
				Automatic:>
					ChemGet[Flatten@{obj}, "Label", None],
				"Numbered":>
					Range[Length@Flatten@{obj}]
				}],
		style=
			Replace[OptionValue["BondStyle"],
				Automatic:>None
				]
		},
		Join@@MapThread[
			Block[{
				bondGraphicsPositions=#,
				bondGraphicsColors=#2,
				bondGraphicsRadii=#3,
				bondGraphicsAtoms=#4,
				bondGraphicsLabel=#5,
				bondGraphicsStyle=#6,
				bondGraphicsVector
				},
				bondGraphicsRadii=
					Replace[OptionValue@"AtomicRadius",{
						Automatic:>(
							OptionValue@"RadiusScaling"*
								QuantityMagnitude@bondGraphicsRadii
							),
						n_?NumericQ:>
							ConstantArray[n,Length@bondGraphicsAtoms]
						}];
				bondGraphicsVector=
					Subtract@@bondGraphicsPositions//Normalize;
				bondGraphicsPositions=
					Insert[bondGraphicsPositions,
						Mean@{
							First@bondGraphicsPositions-
								bondGraphicsVector*First@bondGraphicsRadii,
							Last@bondGraphicsPositions+
								bondGraphicsVector*Last@bondGraphicsRadii
							},
						2];
				fn[
					bondGraphicsColors,
					bondGraphicsPositions,
					ConstantArray[
						Replace[OptionValue@"BondThickness",
							r_Real:>10*r
							],
						2
						],
					bondGraphicsLabel,
					bondGraphicsStyle
					]
				]&,
				With[{
					p=
						AssociationThread[
							DeleteDuplicates@Flatten@atoms,
							ChemGet[DeleteDuplicates@Flatten@atoms,"Position"]
							],
					c=
						Replace[OptionValue["BondColor"],
							Automatic:>BondColors@Flatten@{obj}
							],
					r=
						AssociationThread[
							DeleteDuplicates@Flatten@atoms,
							ChemGet[DeleteDuplicates@Flatten@atoms,"Radius"]
							]
					},
					{
						Lookup[p,#]&/@atoms,
						Take[
							Flatten[
								ConstantArray[
									c,
									Length@atoms
									],
								1
								],
							Length@atoms
							],
						Lookup[r,#]&/@atoms,
						atoms,
						Take[
							Flatten[
								ConstantArray[
									lab,
									Length@atoms
									],
								1
								],
							Length@atoms
							],
						Take[
							Flatten[
								ConstantArray[
									style,
									Length@atoms
									],
								1
								],
							Length@atoms
							]
						}
					]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Graphic3D*)



(* ::Subsubsubsection::Closed:: *)
(*SingleBonds*)



bondGraphics3D1[
	bondGraphicsColors_,
	bondGraphicsPositions_,
	bondGraphicsLabel_,
	style_,
	bondGraphicThickness_]:=
	{
		{
			EdgeForm[None],
			Replace[None->Nothing]@style,
			{
				First@bondGraphicsColors,
				Cylinder[bondGraphicsPositions[[;;2]],bondGraphicThickness],
				Last@bondGraphicsColors,
				Cylinder[bondGraphicsPositions[[2;;]],bondGraphicThickness]
				}
			},
		Replace[bondGraphicsLabel,{
			None->Nothing,
			e_:>
				Map[
					Text[
						Style[
							e,
							If[ColorDistance[bondGraphicsColors[[1]], Black]>.7, Black, White]
							],
						Mean@bondGraphicsPositions+#
						]&,
					(.25+bondGraphicThickness)*
					If[bondGraphicThickness>.5,
							Join[IdentityMatrix[3], -IdentityMatrix[3]],
							{{0,0,1}}
							]
					]
			}]
		};


bondGraphics3D1Dashed[
	bondGraphicsColors_,bondGraphicsPositions_,
	bondGraphicsLabel_,style_,
	bondGraphicThickness_,dashing_]:=
	{
		{
			EdgeForm[None],
			Replace[None->Nothing]@style,
			{
				First@bondGraphicsColors,
				Cylinder[#,bondGraphicThickness]&/@
					Partition[
						With[{v=Subtract@@bondGraphicsPositions[[;;2]]},
							With[{u=Normalize@v,n=Norm@v,p=bondGraphicsPositions[[2]]},
								p+#*u&/@Range[0,n,Min@{dashing,n/2.}]
								]
							],
						2],
				Last@bondGraphicsColors,
				Cylinder[#,bondGraphicThickness]&/@
					Partition[
						With[{v=Subtract@@bondGraphicsPositions[[2;;]]},
							With[{u=Normalize@v,n=Norm@v,p=bondGraphicsPositions[[3]]},
								p+#*u&/@Range[0,n,Min@{dashing,n/2.}]
								]
							],
						2]
				}
			},
		Replace[bondGraphicsLabel,
			{
				None->Nothing,
				e_:>
					Map[
						Text[
							Style[
								e,
								If[ColorDistance[bondGraphicsColors[[1]], Black]>.7, Black, White]
								],
							Mean@bondGraphicsPositions+#
							]&,
						(.25+bondGraphicThickness)*
							If[bondGraphicThickness>.5,
								Join[IdentityMatrix[3], -IdentityMatrix[3]],
								{{0,0,1}}
								]
						]
				}]
		};


(* ::Subsubsubsection::Closed:: *)
(*DoubleBonds*)



bondGraphics3D2[
	bondGraphicsColors_,bondGraphicsPositions_,
	bondGraphicsLabel_,style_,
	bondGraphicsVector_,bondGraphicSeparation_,
	bondGraphicThickness_]:=
	With[{perp=
			ConstantArray[
				(bondGraphicSeparation+bondGraphicThickness)*
					If[With[{g=Normalize@bondGraphicsVector},g!={0,0,1}&&g!={0,0,-1}],
						Cross[bondGraphicsVector,{0,0,1}],
						{1,0,0}
						],
				2]},
		{
			{
				EdgeForm[None],
				Replace[None->Nothing]@style,
				{
					First@bondGraphicsColors,
					Cylinder[bondGraphicsPositions[[;;2]]-perp,
						bondGraphicThickness],
					Cylinder[bondGraphicsPositions[[;;2]]+perp,
						bondGraphicThickness]
					},
				{
					Last@bondGraphicsColors,
					Cylinder[bondGraphicsPositions[[2;;]]-perp,
						bondGraphicThickness],
					Cylinder[bondGraphicsPositions[[2;;]]+perp,
						bondGraphicThickness]
					}
				},
			Replace[bondGraphicsLabel,{
				None->Nothing,
				e_:>
					Map[
						Text[
							Style[
								e,
								If[ColorDistance[bondGraphicsColors[[1]], Black]>.7, Black, White]
								],
							Mean@bondGraphicsPositions+#
							]&,
						(.25+bondGraphicThickness)*
						If[bondGraphicThickness>.5,
							Join[IdentityMatrix[3], -IdentityMatrix[3]],
							{{0,0,1}}
							]
						]
				}]
			}
		];


bondGraphics3D2Dashed[
	bondGraphicsColors_,bondGraphicsPositions_,
	bondGraphicsLabel_,style_,
	bondGraphicsVector_,bondGraphicSeparation_,
	bondGraphicThickness_,dashing_]:=
	With[{perp=
			ConstantArray[
				(bondGraphicSeparation+bondGraphicThickness)*
					If[With[{g=Normalize@bondGraphicsVector},g!={0,0,1}&&g!={0,0,-1}],
						Cross[bondGraphicsVector,{0,0,1}],
						{1,0,0}
						],
				2]},
		{
			{
				EdgeForm[None],
				Replace[None->Nothing]@style,
				{
					First@bondGraphicsColors,
					Cylinder[#,bondGraphicThickness]&/@
						Partition[
							With[{v=Subtract@@bondGraphicsPositions[[;;2]]},
								With[{
										u=Normalize@v,n=Norm@v,
										p=bondGraphicsPositions[[2]]},
										p+#*u-First@perp&/@Range[0,n,Min@{dashing,n/2.}]
									]
								],
							2],
					Cylinder[bondGraphicsPositions[[;;2]]+perp,
						bondGraphicThickness]
					},
				{
					Last@bondGraphicsColors,
					Cylinder[#,bondGraphicThickness]&/@
						Partition[
							With[{v=Subtract@@bondGraphicsPositions[[2;;]]},
								With[{
										u=Normalize@v,n=Norm@v,
										p=bondGraphicsPositions[[3]]},
										p+#*u-First@perp&/@Range[0,n,Min@{dashing,n/2.}]
									]
								],
							2],
					Cylinder[bondGraphicsPositions[[2;;]]+perp,
						bondGraphicThickness]
					}
				},
			Replace[bondGraphicsLabel,{
				None->Nothing,
				e_:>
					Map[
						Text[
							Style[
								e,
								If[ColorDistance[bondGraphicsColors[[1]], Black]>.7, Black, White]
								],
							Mean@bondGraphicsPositions+#
							]&,
						(.25+bondGraphicThickness)*
						If[bondGraphicThickness>.5,
							Join[IdentityMatrix[3], -IdentityMatrix[3]],
							{{0,0,1}}
							]
						]
				}]
			}
		];


(* ::Subsubsubsection::Closed:: *)
(*TripleBonds*)



bondGraphics3D3[
	bondGraphicsColors_,bondGraphicsPositions_,
	bondGraphicsLabel_, style_,
	bondGraphicsVector_,bondGraphicSeparation_,
	bondGraphicThickness_]:=
	With[{perps=
			NestList[
				RotationMatrix[2.\[Pi]/3,bondGraphicsVector].#&,
				(bondGraphicSeparation+bondGraphicThickness)*
					If[With[{g=Normalize@bondGraphicsVector},g!={0,0,1}&&g!={0,0,-1}],
						Cross[bondGraphicsVector,{0,0,1}],
						{1,0,0}
						],
				2
				]},
		{
			{
				EdgeForm[None],
				Replace[None->Nothing]@style,
				{
					First@bondGraphicsColors,
					Cylinder[bondGraphicsPositions[[;;2]]+ConstantArray[#,2],
						bondGraphicThickness]&/@perps
					},
				{
					Last@bondGraphicsColors,
					Cylinder[bondGraphicsPositions[[2;;]]+ConstantArray[#,2],
						bondGraphicThickness]&/@perps
					}
				},
			Replace[bondGraphicsLabel,{
				None->Nothing,
				e_:>
					Map[
						Text[
							Style[
								e,
								If[ColorDistance[bondGraphicsColors[[1]], Black]>.7, Black, White]
								],
							Mean@bondGraphicsPositions+#
							]&,
						(.25+bondGraphicThickness)*
						If[bondGraphicThickness>.5,
							Join[IdentityMatrix[3], -IdentityMatrix[3]],
							{{0,0,1}}
							]
						]
				}]
			}
		];


bondGraphics3D3Dashed[
	bondGraphicsColors_,bondGraphicsPositions_,
	bondGraphicsLabel_, style_,
	bondGraphicsVector_,bondGraphicSeparation_,
	bondGraphicThickness_,dashing_]:=
		With[{perps=
			NestList[
				RotationMatrix[2.\[Pi]/3,bondGraphicsVector].#&,
				(bondGraphicSeparation+bondGraphicThickness)*
					If[With[{g=Normalize@bondGraphicsVector},g!={0,0,1}&&g!={0,0,-1}],
						Cross[bondGraphicsVector,{0,0,1}],
						{1,0,0}
						],
				2
				]},
		{
			{
				EdgeForm[None],
				Replace[None->Nothing]@style,
				{
					First@bondGraphicsColors,
					Cylinder[#,bondGraphicThickness]&/@
						Partition[
							With[{v=Subtract@@bondGraphicsPositions[[;;2]]},
								With[{
										u=Normalize@v,n=Norm@v,
										p=bondGraphicsPositions[[2]]},
										p+#*u+First@perps&/@Range[0,n,Min@{dashing,n/2.}]
									]
								],
							2],
					Cylinder[bondGraphicsPositions[[;;2]]+ConstantArray[#,2],
							bondGraphicThickness]&/@perps[[2;;]]
					},
				{
					Last@bondGraphicsColors,
					Cylinder[#,bondGraphicThickness]&/@
						Partition[
							With[{v=Subtract@@bondGraphicsPositions[[2;;]]},
								With[{
										u=Normalize@v,n=Norm@v,
										p=bondGraphicsPositions[[3]]},
										p+#*u+First@perps&/@Range[0,n,Min@{dashing,n/2.}]
									]
								],
							2],
					Cylinder[bondGraphicsPositions[[2;;]]+ConstantArray[#,2],
						bondGraphicThickness]&/@perps[[2;;]]
					}
				},
			Replace[bondGraphicsLabel,{
				None->Nothing,
				e_:>
					Map[
						Text[
							Style[
								e,
								If[ColorDistance[bondGraphicsColors[[1]], Black]>.7, Black, White]
								],
							Mean@bondGraphicsPositions+#
							]&,
						bondGraphicThickness*Join[IdentityMatrix[3], -IdentityMatrix[3]]
						]
				}]
			}
		];


(* ::Subsubsubsection::Closed:: *)
(*BondGraphicShapeFunction3D*)



BondGraphicShapeFunction3D[
	type_,
	colors_,
	positions_,
	label_,
	style_,
	vector_,
	tbSep_,
	dbSep_,
	thick_,
	dashing_
	]:=
	Which[
		tbSep=!=None&&type==3//TrueQ,
			bondGraphics3D3[
				colors, positions,
				label, style,
				vector, tbSep,
				thick
				],
		dbSep=!=None&&type==2//TrueQ,
			bondGraphics3D2[
				colors,positions, 
				label, style,
				vector, dbSep,
				thick
				],
		(type==3&&tbSep===None)||
			(type==2&&dbSep===None)||
				type==1//TrueQ,
			bondGraphics3D1[
				colors, positions, 
				label, style,
				thick],
		tbSep=!=None&&type>2//TrueQ,
			bondGraphics3D3Dashed[
				colors, positions, 
				label, style,
				vector, tbSep,
				thick, dashing],
		dbSep=!=None&&type>1//TrueQ,
			bondGraphics3D2Dashed[
				colors, positions, 
				label, style,
				vector, dbSep,
				thick, dashing
				],
		True,
			bondGraphics3D1Dashed[
				colors, positions, 
				label, style,
				thick, dashing
				]
		]


(* ::Subsubsubsection::Closed:: *)
(*BondGraphic3D*)



Options[BondGraphic3D]=Options[BondGraphic];
BondGraphic3D[obj:ChemObjAllPattern,ops:OptionsPattern[]]:=
	With[{
		atoms=ChemGet[Flatten@{obj},"Atoms"],
		type=ChemGet[Flatten@{obj},"Type"],
		fn=
			Replace[
				OptionValue["BondShapeFunction"],
					Automatic->BondGraphicShapeFunction3D
				],
		lab=
			Replace[
				OptionValue["BondLabel"],{
				Automatic:>
					ChemGet[Flatten@{obj}, "Label", None],
				"Numbered"->
					Range[Length@Flatten@{obj}]
				}],
		style=
			Replace[OptionValue["BondStyle"],
				Automatic:>None
				]
		},
		Join@@MapThread[
			Block[{
				bondGraphicsAtoms=#4,
				bondGraphicsType=#5,
				bondGraphicsPositions=#,
				bondGraphicsColors=#2,
				bondGraphicsRadii=#3,
				bondGraphicsLab=#6,
				bondGraphicsStyle=#7,
				bondGraphicsVector,
				bondGraphicsDBSep=OptionValue@"DoubleBondSeparation",
				bondGraphicsTBSep=OptionValue@"TripleBondSeparation"
				},
				bondGraphicsRadii=
					Replace[OptionValue@"AtomicRadius",{
						Automatic:>(
							OptionValue@"RadiusScaling"*
								QuantityMagnitude@*ChemGet["Radius"]/@bondGraphicsAtoms
							),
						n_?NumericQ:>
							ConstantArray[n,Length@bondGraphicsAtoms]
						}];
				bondGraphicsVector=Subtract@@bondGraphicsPositions//Normalize;
				bondGraphicsPositions=
					Insert[bondGraphicsPositions,
						Mean@{
							First@bondGraphicsPositions-
								bondGraphicsVector*First@bondGraphicsRadii,
							Last@bondGraphicsPositions+
								bondGraphicsVector*Last@bondGraphicsRadii
							},
						2];
				fn[
					bondGraphicsType,
					bondGraphicsColors,
					bondGraphicsPositions,
					bondGraphicsLab,
					bondGraphicsStyle,
					bondGraphicsVector,
					OptionValue["TripleBondSeparation"],
					OptionValue["DoubleBondSeparation"],
					OptionValue["BondThickness"],
					OptionValue["BondDashing"]
					]
				]&,
				With[{
					p=
						AssociationThread[
							DeleteDuplicates@Flatten@atoms,
							ChemGet[DeleteDuplicates@Flatten@atoms,"Position"]
							],
					c=
						Replace[OptionValue["BondColor"],
							Automatic:>BondColors@Flatten@{obj}
							],
					r=
						AssociationThread[
							DeleteDuplicates@Flatten@atoms,
							ChemGet[DeleteDuplicates@Flatten@atoms,"Radius"]
							]
					},{
					Lookup[p,#]&/@atoms,
					Take[
						If[ColorQ@#[[1]], 
							Partition[#, 2],
							#
							]&@
						Flatten[
							ConstantArray[
								c,
								2*Length@atoms
								],
							1
							],
						Length@atoms
						],
					Lookup[r,#]&/@atoms,
					atoms,
					type,
					Take[
						Flatten[
							ConstantArray[
								lab,
								Length@atoms
								],
							1
							],
						Length@atoms
						],
					Take[
						Flatten[
							ConstantArray[
								style,
								Length@atoms
								],
							1
							],
						Length@atoms
						]
					}
					]
			]
		];


End[];



