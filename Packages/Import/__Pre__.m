(* ::Package:: *)



(* ::Text:: *)
(*
	A preloaded file before any of the other files are imported.
	Get is run on it rather than the standard declaration scraping procedure.
*)



(* ::Subsubsection::Closed:: *)
(*MolTable*)



If[!TrueQ[`Private`$ImportRegistered["MolTable"]],
	ImportExport`RegisterImport[
		"MolTable",
		ChemImportMolTable,
		{ 
			"Graphics" :> 
				Function@
					With[{`Private`paramList={##}}, 
						ChemGraphics[Rest@#, Rest@`Private`paramList]&/@#
						],
			"Graphics3D" :> 
				Function@
					With[{`Private`paramList={##}}, 
						ChemGraphics3D[Rest@#, Rest@`Private`paramList]&/@#
						]
			},
		"FunctionChannels"->{"Streams"}
		];
	`Private`$ImportRegistered["MolTable"]=True
	]


(* ::Subsubsection::Closed:: *)
(*Chemical Structure*)



If[!TrueQ[`Private`$ImportRegistered["ChemicalStructure"]],
	ImportExport`RegisterImport[
		"ChemicalStructure",
		ChemImportChemicalStructure,
		{ }
		];
	`Private`$ImportRegistered["ChemImportChemicalStructure"]=True
	]


(* ::Subsubsection::Closed:: *)
(*ZMatrix*)



If[!TrueQ[`Private`$ImportRegistered["ZMatrix"]],
	ImportExport`RegisterImport[
		"ZMatrix",
		ChemImportZMatrix,
		{ 
			"Graphics" :> 
				Function@
					With[{`Private`paramList={##}}, 
						ChemGraphics[Rest@#, Rest@`Private`paramList]&/@#
						],
			"Graphics3D" :> 
				Function@
					With[{`Private`paramList={##}}, 
						ChemGraphics3D[Rest@#, Rest@`Private`paramList]&/@#
						]
			},
		"FunctionChannels"->{"Streams"}
		];
	`Private`$ImportRegistered["ZMatrix"]=True
	]


(* ::Subsubsection::Closed:: *)
(*XYZTable*)



If[!TrueQ[`Private`$ImportRegistered["XYZTable"]],
	ImportExport`RegisterImport[
		"XYZTable",
		ChemImportXYZ,
		{ 
			"Graphics" :> 
				Function@
					With[{`Private`paramList={##}}, 
						ChemGraphics[Rest@#, Rest@`Private`paramList]&/@#
						],
			"Graphics3D" :> 
				Function@
					With[{`Private`paramList={##}}, 
						ChemGraphics3D[Rest@#, Rest@`Private`paramList]&/@#
						]
			},
		"FunctionChannels"->{"Streams"}
		];
	`Private`$ImportRegistered["XYZTable"]=True
	]


(* ::Subsubsection::Closed:: *)
(*CubeFile*)



If[!TrueQ[`Private`$ImportRegistered["CubeFile"]],
	Map[
		ImportExport`RegisterImport[
			"CubeFile",
			{
				"Association":>
					Function[
						{"Association"->CubeFileGrid@CubeFileRead[##]}
						],
				"Grid":>
					Function[
						{"Grid"->CubeFileGrid@CubeFileRead[##]}
						],
				"InterpolatingFunction":>
					Function[
						{"InterpolatingFunction"->CubeFileFunction@CubeFileRead[##]}
						],
				"Elements":>
					Function[{"Elements"->{"Association", "Grid", "InterpolatingFunction"}}],
				CubeFileRead
				},
			"FunctionChannels"->{"Streams"}
			]&,
		{"cube", "CubeFile"}
		];
	`Private`$ImportRegistered["CubeFile"]=True
	];


(* ::Subsubsection::Closed:: *)
(*GJF*)



If[!TrueQ[`Private`$ImportRegistered["GaussianJob"]],
	Map[
		ImportExport`RegisterImport[
			#,
			{
				"MolTable":>
					Function[{"MolTable"->ImportGaussianJob[#, "MolTable"]}],
				"Graphics3D":>
					Function[{"Graphics3D"->ImportGaussianJob[#, "Graphics3D", Rest@{##}]}],
				"Elements":>
					Function[{"Elements"->{"MolTable", "Graphics3D"}}],
				ImportGaussianJob
				}
			]&,
		{"GJF", "GaussianJob"}
		];
	`Private`$ImportRegistered["GaussianJob"]=True
	];


(* ::Subsubsection::Closed:: *)
(*FChk*)



If[!TrueQ[`Private`$ImportRegistered["FormattedCheckpoint"]],
	Map[
		ImportExport`RegisterImport[
			#,
			{
				"MolTable":>
					Function[{"MolTable"->ImportFormattedCheckpointFile[#, "MolTable"]}],
				"Elements":>
					Function[{"Elements"->{"MolTable"}}],
				ImportFormattedCheckpointFile
				},
			"FunctionChannels"->{"Streams"}
			]&,
		{"FCHK", "FormattedCheckpoint"}
		];
	`Private`$ImportRegistered["FormattedCheckpoint"]=True
	];


(* ::Subsubsection::Closed:: *)
(*GaussianLog*)



`Private`$GLKS=
	Join[
		{
			"StartDateTime",
			"CartesianCoordinates",
			"MullikenCharges",
			"MP2Energies",
			"HartreeFockEnergies",
			"MultipoleMoments",
			"InputZMatrix",
			"InputZMatrixVariables",
			"ZMatrices",
			"ScanTable",
			"OptimizationScan",
			"Blurb",
			"ComputerTimeElapsed",
			"EndDateTime"
			},
		{
			"ScanQuantityArray",
			"OptimizationScanQuantityArray",
			"OptimizationScanZMatrices"
			}
		]


If[!TrueQ[`Private`$ImportRegistered["GaussianLog"]],
	Map[
		ImportExport`RegisterImport[
			#,
			Join[
				Map[
					Function[
						With[{`Private`elname=#},
							`Private`elname:>
								Function[{`Private`elname->ImportGaussianLog[#, `Private`elname]}]
							]
						],
						`Private`$GLKS
					],
				{
					"Elements":>
						Function[
							{
								"Elements"->
									`Private`$GLKS
								}
							],
					ImportGaussianLog
					}
				],
			"FunctionChannels"->{"Streams"}
			]&,
		{"GaussianLog"}
		];
	`Private`$ImportRegistered["GaussianLog"]=True
	];



