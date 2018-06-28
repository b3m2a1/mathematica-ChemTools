(* ::Package:: *)



CreateGeometricAtomset::usage=
	"Makes a new atomset with specified geometry";


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*$CreateGeometricAtomsetGeometries*)



$CreateGeometricAtomsetGeometries=
	<|
		"FromCoordinates"->
			CreateCoordinatesAtomset,
		"Linear"->
			CreateLinearAtomset,
		"Bent"->
			CreateBentAtomset,
		"Square"->
			CreateSquareAtomset,
		"CisSquare"->
			CreateCisSquareAtomset,
		"TransSquare"->
			CreateTransSquareAtomset,
		"Diamond"->
			CreateDiamondAtomset,
		"CisDiamond"->
			CreateCisDiamondAtomset,
		"TransDiamond"->
			CreateTransDiamondAtomset,
		"Hexagonal"->
			CreateHexagonalAtomset,
		"TrigonalPlanar"->
			CreateTrigonalPlanarAtomset,
		"TrigonalPyramidal"->
			CreateTrigonalPyramidalAtomset,
		"Tetrahedral"->
			CreateTetrahedralAtomset,
		"CisTrigonalBipyramidal"->
			CreateCisTrigonalBipyramidalAtomset,
		"TransTrigonalBipyramidal"->
			CreateTransTrigonalBipyramidalAtomset,
		"TrigonalBipyramidal"->
			CreateTrigonalBipyramidalAtomset,
		"SquarePlanar"->
			CreateSquarePlanarAtomset,
		"CisSquarePlanar"->
			CreateCisSquarePlanarAtomset,
		"TransSquarePlanar"->
			CreateTransSquarePlanarAtomset,
		"SquarePyramidal"->
			CreateSquarePyramidalAtomset,
		"Octahedral"->
			CreateOctahedralAtomset,
		"FacialOctahedral"->
			CreateFacialOctahedralAtomset,
		"MeridionalOctahedral"->
			CreateMeridionalOctahedralAtomset
		|>;


(* ::Subsubsection::Closed:: *)
(*CreateGeometricAtomset*)



CreateGeometricAtomset//Clear


CreateGeometricAtomset::numats="Atomset geometry `` expects `` atoms, `` provided";


CreateGeometricAtomset[
	geom_String,
	check:True|False:False,
	args:Except[_?OptionQ]...,
	ops:OptionsPattern[]
	]:=
	Block[{$CurrentGeometricAtomsetGeom=geom},
		With[{res=
			Which[
				KeyExistsQ[$CreateGeometricAtomsetGeometries, geom],
					$CreateGeometricAtomsetGeometries[geom][check,args],
				KeyExistsQ[$GeometicAtomsetCoordinates, geom],
					With[{ve=$GeometicAtomsetCoordinates[geom]},
						CreateCoordinatesAtomset[
							check,
							Lookup[ve, "Vertices"],
							Flatten[{args}, 1],
							Lookup[ve, "Edges", {}]
							]
						],
				True,
					CreatePolyhedronAtomset[
						geom, 
						Flatten[{args}, 1],
						check,
						ops
						]
				]
				},
			res/;ChemObjectQ@res
			]	
		];


(* ::Subsubsubsection::Closed:: *)
(*Coords*)



$GeometicAtomsetCoordinates=<||>;


(* ::Text:: *)
(*Specify vertices and edges here*)



$GeometicAtomsetCoordinates["Bowtie"]=
	<|
		"Vertices"->
			{
				{0, 0, 0},
				{3/2, -(Sqrt[3]/2), 0}, {3/2, Sqrt[3]/2, 0},
				{-(3/2), -(Sqrt[3]/2), 0}, {-(3/2), Sqrt[3]/2, 0}
				},
		"Edges"->
			{
				{1, 2}, {1, 3}, {2, 3},
				{1, 4}, {1, 5}, {4, 5}
				}
		|>;


$GeometicAtomsetCoordinates["BowtieD2D"]=
	<|
		"Vertices"->
			{
				{0, 0, 0},
				{3/2, -(Sqrt[3]/2), 0}, {3/2, Sqrt[3]/2, 0},
				{-(3/2), 0, -(Sqrt[3]/2)}, {-(3/2), 0, Sqrt[3]/2}
				},
		"Edges"->
			$GeometicAtomsetCoordinates["Bowtie", "Edges"]
		|>;


(* ::Subsubsubsection::Closed:: *)
(*Polyhedron*)



Options[CreatePolyhedronAtomset]=
	{
		"DefaultRadius"->1
		};
CreatePolyhedronAtomset[geom_, ats_, check:True|False:True, ops:OptionsPattern[]]:=
	With[{defrad=OptionValue["DefaultRadius"]},
		With[
			{
				coords=
					Replace[
						PolyhedronData[geom, "Vertices"],
						{
							f2_Function:>f2[defrad]
							},
						1
						],
				atlen=
					Length@ats
				},
			If[ListQ@coords&&atlen==Length@coords,
				Quiet[
					CreateCoordinatesAtomset[check,
						coords,
						ats,
						PolyhedronData[geom, "Edges"]
						],
					N::meprec
					],
				If[ListQ@coords&&atlen!=Length@coords,
					Message[CreateGeometricAtomset::numats, 
						geom,
						Length@coords,
						atlen
						];
					$Failed
					]
				]
			]
		]


(* ::Subsubsubsection::Closed:: *)
(*Coordinates*)



CreateCoordinatesAtomset//Clear


CreateCoordinatesAtomset[
	check:True|False:True,
	coords:{{_,_,_}..},
	els:{Repeated[_String|{_String,___}|ChemSinglePattern]},
	bonds:{{_,_,___}...}:{}
	]/;Length[coords]===Length[els]:=
	Module[{
		ats=
			CreateAtom@
				MapThread[List,
					{
						els,
						coords
						}
					],
		atomset
		},
		Do[
			AtomCreateBond[
				ats[[b[[1]]]],
				ats[[b[[2]]]],
				b[[3]],
				check
				],
			{b, PadRight[#,3,1]&/@bonds}
			];
		atomset=CreateAtomset[ats];
		AtomsetNormalizeBonds[atomset];
		atomset
		];
CreateCoordinatesAtomset[
	check:True|False:True,
	coords:{{_,_,_}..},
	els:{Repeated[_String|{_String,___}|ChemSinglePattern]},
	bonds:{{_,_,___}...}:{}
	]/;Length[coords]=!=Length[els]:=
	(
		Message[CreateGeometricAtomset::numats,
				Replace[$CurrentGeometricAtomsetGeom,
					Except[_String]->"Coordinate Set"
					],
				Length[coords],
				Length[els]
				];
		$Failed
		);


(* ::Subsubsubsection::Closed:: *)
(*Linear*)



CreateLinearAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{2,\[Infinity]}]}
	]:=
	Module[
		{
			atoms=
				CreateAtom@
					MapIndexed[
						{#, {#2[[1]]-1, 0, 0}}&, 
						elements
						],
			atomset
			},
		Do[
			AtomCreateBond[atoms[[n]], atoms[[n+1]], 1, check],
			{n, Length[atoms]-1}
			];
		atomset=CreateAtomset[atoms];
		AtomsetNormalizeBonds[atomset];
		atomset
		];


(* ::Subsubsubsection::Closed:: *)
(*Square*)



CreateSquareAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	Module[
		{
			atoms=
				{
					CreateAtom@
						MapThread[List,
							{
								els1[[;;2]],
								{
									1/Sqrt[2.] { 1, 1, 0},
									1/Sqrt[2.] {-1, -1, 0}
									}
								}
							],
					CreateAtom@
						MapThread[List,
							{
								els1[[3;;]],
								{
									1/Sqrt[2.] {-1, 1, 0},
									1/Sqrt[2.] {1,-1, 0}
									}
								}
							]
					},
			oldBonds,
			atomset
			},
			Do[AtomCreateBond[a, b, 1, check], {a, atoms[[1]]}, {b, atoms[[2]]}];
			atomset=CreateAtomset[Join@@atoms];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateSquareAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"Square",
			4,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*CisSquare*)



CreateCisSquareAtomset[
	check:True|False:False,
	els1:
		{
			Repeated[_String|{_String,___}|ChemSinglePattern,{4}]
			}
	]:=
	CreateSquareAtomset[
		check,
		RotateRight@els1
		];
CreateCisSquareAtomset[
	check:True|False:False,
	els1:
		{
			{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
			{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}
			}
	]:=
	CreateCisSquareAtomset[
		check,
		Flatten@els1
		];
CreateCisSquareAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"CisSquare",
			4,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*TransSquare*)



CreateTransSquareAtomset[
	check:True|False:False,
	els1:
		{
			Repeated[_String|{_String,___}|ChemSinglePattern,{4}]
			}
	]:=
	CreateSquareAtomset[
		check,
		els1
		];
CreateTransSquareAtomset[
	check:True|False:False,
	els1:
		{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}
		}
	]:=
	CreateTransSquareAtomset[
		check,
		Flatten[els1]
		];
CreateTransSquareAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"TransSquare",
			4,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*Diamond*)



CreateDiamondAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	Module[
		{
			atoms=
				{
					CreateAtom@
						MapThread[List,
							{
								els1[[;;2]],
								{
									{ 1, 0, 0},
									{-1, 0, 0}
									}
								}
							],
					CreateAtom@
						MapThread[List,
							{
								els1[[3;;]],
								{
									{0, 1, 0},
									{0,-1, 0}
									}
								}
							]
					},
			oldBonds,
			atomset
			},
			Do[AtomCreateBond[a, b, 1, check], {a, atoms[[1]]}, {b, atoms[[2]]}];
			atomset=CreateAtomset[Join@@atoms];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateDiamondAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"Diamond",
			4,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*CisDiamond*)



CreateCisDiamondAtomset[
	check:True|False:False,
	els1:
		{
			Repeated[_String|{_String,___}|ChemSinglePattern, {4}]
			}
	]:=
	CreateDiamondAtomset[
		check,
		RotateRight@els1
		];
CreateCisDiamondAtomset[
	check:True|False:False,
	els1:
		{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}
		}
	]:=
	CreateCisDiamondAtomset[
		check,
		Flatten[els1]
		];
CreateCisDiamondAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"CisDiamond",
			4,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*TransDiamond*)



CreateTransDiamondAtomset[
	check:True|False:False,
	els1:
		{
			Repeated[_String|{_String,___}|ChemSinglePattern,{4}]
			}
	]:=
	CreateDiamondAtomset[
		check,
		els1
		];
CreateTransDiamondAtomset[
	check:True|False:False,
	els1:
		{
			{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
			{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}
			}
	]:=
	CreateTransDiamondAtomset[
		check,
		Flatten@els1
		];
CreateTransDiamondAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"TransDiamond",
			4,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*Hexagonal*)



CreateHexagonalAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern,{6}]}
	]:=
	Module[
		{
			atoms=
				CreateAtom@
					MapThread[List,
						{
							els1,
							Append[0]/@
								CirclePoints[6]//N
							}
						],
			oldBonds,
			atomset
			},
			Do[
				AtomCreateBond[
					atoms[[n]], 
					atoms[[Mod[n+1, Length@atoms, 1]]],
					1, 
					check
					], 
				{n, Length@atoms}
				];
			atomset=CreateAtomset[atoms];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateHexagonalAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"TransSquare",
			6,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*TrigonalPlanar*)



CreateTrigonalPlanarAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}, 2]}
	]:=
	Module[
		{
			atoms=
				CreateAtom@
						MapThread[List,
							elements[[1]],
							CirclePoints[3]
							],
			core=CreateAtom[coreEl, {0, 0, 0}],
			atomset
			},
			Do[AtomCreateBond[core, b, 1, check], {b, atoms}];
			atomset=CreateAtomset[Join[{core},atoms]];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateTrigonalPlanarAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"TrigonalPlanar",
			3,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*Tetrahedral*)



CreateTetrahedralAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						{
							{0,0,Sqrt[2/3]-1/(2 Sqrt[6])},
							{-(1/(2 Sqrt[3])),-(1/2),-(1/(2 Sqrt[6]))},
							{-(1/(2 Sqrt[3])),1/2,-(1/(2 Sqrt[6]))},
							{1/Sqrt[3],0,-(1/(2 Sqrt[6]))}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateTetrahedralAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{5}]}
	]:=
	CreateTetrahedralAtomset[check,
		elements[[1]],
		Rest@elements
		];
CreateTetrahedralAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"Tetrahedral",
			5,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*TrigonalPyramidal*)



CreateTrigonalPyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	With[{core=ChemImport["methane"]},
		With[{
			cCore=First@AtomsetGetAtoms[core,"C"],
			hs=AtomsetGetAtoms[core,"H"],
			newCore=CreateAtom@coreEl,
			newOuter=CreateAtom/@elements,
			oldBonds=ChemGet[core["Atoms"],"Bonds"]
			},
			AtomsetSubstituteAtom[
				core,
				Prepend[cCore->newCore]@
					Thread[hs->newOuter],
				check
				];
			ChemRemove/@Flatten@{hs,cCore,oldBonds};
			AtomsetNormalizeBonds[core];
			core
			]
		];
CreateTrigonalPyramidalAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{5}]}
	]:=
	CreateTrigonalPyramidalAtomset[check,
		elements[[1]],
		Rest@elements
		];
CreateTrigonalPyramidalAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"TrigonalPyramidal",
			5,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*Bent*)



(*CreateBentAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	With[{core=ChemImport["methane"]},
		With[{
			cCore=First@AtomsetGetAtoms[core,"C"],
			hs=AtomsetGetAtoms[core,"H"],
			newCore=CreateAtom@coreEl,
			newOuter=CreateAtom/@elements,
			oldBonds=ChemGet[core["Atoms"],"Bonds"]
			},
			AtomsetSubstituteAtom[
				core,
				Prepend[cCore->newCore]@
					Thread[hs\[Rule]newOuter],
				check
				];
			ChemRemove/@Flatten@{hs,cCore,oldBonds};
			AtomsetNormalizeBonds[core];
			core
			]
		]*)


(* ::Subsubsubsection::Closed:: *)
(*TrigonalBipyramidal*)



CreateTrigonalBipyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{5}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						N@{
							{0,0,1},{0,0,-1},
							{Sqrt[3]/2,-(1/2),0},{0,1,0},{-(Sqrt[3]/2),-(1/2),0}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateTrigonalBipyramidalAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern, {6}]}
	]:=
	CreateTrigonalBipyramidalAtomset[check,
		elements[[1]],
		Rest@elements
		];
CreateTrigonalBipyramidalAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"TrigonalBipyramidal",
			6,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*CisTrigonalBipyramidal*)



CreateCisTrigonalBipyramidalAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern, {6}]}
	]:=
	CreateTrigonalBipyramidalAtomset[check,
		elements[[1]],
		Rest@elements
		];
CreateCisTrigonalBipyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]}
		}
	]:=
CreateTrigonalBipyramidalAtomset[check,
	Prepend[
		RotateRight@Flatten[elements],
		coreEl
		]
	];
CreateTrigonalBipyramidalAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"CisTrigonalBipyramidal",
			6,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*TransTrigonalBipyramidal*)



CreateTransTrigonalBipyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]}
		}
	]:=
CreateTrigonalBipyramidalAtomset[check,
	coreEl,
	Flatten[elements]
	]


(* ::Subsubsubsection::Closed:: *)
(*SquarePlanar*)



CreateSquarePlanarAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						{
							{1`,0.`,0},
							{-1,0,0},
							{0,1,0},
							{0,-1,0}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateSquarePlanarAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{5}]}
	]:=
	CreateSquarePlanarAtomset[
		check,
		elements[[1]],
		Rest@elements
		];
CreateSquarePlanarAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"SquarePlanar",
			5,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*CisSquarePlanar*)



CreateCisSquarePlanarAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}, {2}]}
	]:=
	CreateSquarePlanarAtomset[check, coreEl,
		RotateRight@Flatten[elements]
		]


(* ::Subsubsubsection::Closed:: *)
(*TransSquarePlanar*)



CreateTransSquarePlanarAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}, {2}]}
	]:=
	CreateSquarePlanarAtomset[check, coreEl, Flatten[elements]];


(* ::Subsubsubsection::Closed:: *)
(*SquarePyramidal*)



CreateSquarePyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"S",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{5}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						{
							{0.`,0.`,1.},
							{-1., 0.`,0.`},{0.`,1.,0.`},
							{0.`,-1., 0.`},{1.,0.`,0.`}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateSquarePyramidalAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{6}]}
	]:=
	CreateSquarePyramidalAtomset[
		check,
		elements[[1]],
		Rest@elements
		];
CreateSquarePyramidalAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"SquarePyramidal",
			6,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*Octahedral*)



CreateOctahedralAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"S",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{6}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						{
							{0.`,0.`,-1.},{0.`,0.`,1.},
							{-1., 0.`,0.`},{0.`,1.,0.`},
							{0.`,-1., 0.`},{1.,0.`,0.`}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		];
CreateOctahedralAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{7}]}
	]:=
	CreateOctahedralAtomset[check,
		elements[[1]],
		Rest@elements
		];
CreateOctahedralAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"Octahedral",
			7,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*FacialOctahedral*)



CreateFacialOctahedralAtomset[
	check:True|False:False,
	elements:{
		Repeated[_String|{_String,___}|ChemSinglePattern, {7}]
		}
	]:=
	CreateOctahedralAtomset[
		check,
		Prepend[
			RotateRight[Rest@elements],
			elements[[1]]
			]
		];
CreateFacialOctahedralAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"S",
	faces:{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]}
		}
	]:=
	CreateOctahedralAtomset[
		check,
		coreEl,
		RotateRight@Flatten[faces]
		];
CreateFacialOctahedralAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"FacialOctahedral",
			7,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsubsection::Closed:: *)
(*MeridionalOctahedral*)



CreateMeridionalOctahedralAtomset[
	check:True|False:False,
	elements:{
		Repeated[_String|{_String,___}|ChemSinglePattern, {7}]
		}
	]:=
	CreateOctahedralAtomset[
		check,
		elements
		];
CreateMeridionalOctahedralAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"S",
	faces:{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]}
		}
	]:=
	CreateOctahedralAtomset[
		check,
		coreEl,
		Flatten[faces]
		];
CreateMeridonialOctahedralAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern]}
	]:=
	(
		Message[
			CreateGeometricAtomset::numats,
			"MeridonialOctahedral",
			7,
			Length@els1
			];
		$Failed
		)


(* ::Subsubsection::Closed:: *)
(*Autocompletions*)



PackageAddAutocompletions[
	CreateGeometricAtomset,
	{
		Join[
			Keys@$CreateGeometricAtomsetGeometries,
			Keys@$GeometicAtomsetCoordinates,
			Replace[PolyhedronData[], l_List:>ToString[l, InputForm], 1]	
			]
		}
	]


End[];



