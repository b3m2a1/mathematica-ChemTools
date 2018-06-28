(* ::Package:: *)



$ChemExtensions::usage=
	"Directory for all extensions";


ChemExtensionFile::usage="Picks a file matching a pattern";
ChemExtensionDir::usage="Directory for an extension";
ChemExtensionBin::usage="Binary executable for an extension";
$ChemExtensionsApp::usage="";
$ChemExtensionsDev::usage="";


PyToolsLoad::usage=
	"Ensures PyTools is loaded";


terminalRead::usage=
	"Little reader terminal";
terminalRunNoBlocking::usage=
	"Non-blocking reader";


Begin["`Private`"];


(* ::Subsection:: *)
(*Directories*)



$ChemExtensionsDev=
	FileNameJoin@{
		$UserBaseDirectory,
		"ApplicationData",
		"ChemTools",
		"Extensions"
		};


$ChemExtensionsApp=
	With[{baseD=
		Replace[
			$InputFileName,
			{
				"":>ParentDirectory@NotebookDirectory[],
				e_:>$PackageDirectory
				}
			]
		},
		If[DirectoryQ@FileNameJoin@{baseD, "Resources", "Extensions"},
			FileNameJoin@{baseD, "Resources", "Extensions"},
			baseD
			]
		];


$ChemExtensions=
	If[DirectoryQ@$ChemExtensionsDev,
		$ChemExtensionsDev,
		$ChemExtensionsApp
		];


ChemExtensionDir[thing_]:=
	FileNameJoin@{
		SelectFirst[{
			"/usr/local/bin",
			"/usr/bin",
			$ChemExtensionsDev,
			$ChemExtensionsApp
			},
			DirectoryQ@FileNameJoin@{#,thing}&,
			$ChemExtensions
			],
		thing
		};
ChemExtensionFile[thing_]:=
	FileNameJoin@{
		SelectFirst[{
			"/usr/local/bin",
			"/usr/bin",
			$ChemExtensionsDev,
			$ChemExtensionsApp
			},
			FileExistsQ@FileNameJoin@{#,thing}&,
			$ChemExtensions
			],
		thing
		};
ChemExtensionBin[thing_]:=
	With[{d=ChemExtensionDir[thing]},
		If[FileNameTake[d,{-2}]==="bin",
			d,
			FileNameJoin@{d,"bin",FileBaseName[d]}
			]
		]


(* ::Subsection:: *)
(*PythonSessions*)



(* ::Text:: *)
(*
	Delegated to my PyTools package:
		https://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer/main.html#pytools
*)



PyToolsLoad[]:=
	(
		PackageLoadPacletDependency["PyTools`",
			"Site"->"http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
			];
		<<PyTools`Symbolic`;
		PyTools`Symbolic`ToPython
		)


(* ::Subsection:: *)
(*terminalRead*)



terminalRead[p_,readVar_]:=
	Block[{$terminalProcessKillFlag=False},
		Replace[
			ReadString[ProcessConnection[p,"StandardOutput"],EndOfBuffer],{
				s_String?(StringLength@#>0&):>AppendTo[readVar,s],
				EndOfFile:>($terminalProcessKillFlag=True)
				}];
		Replace[
			ReadString[ProcessConnection[p,"StandardError"],EndOfBuffer],{
				s_String?(StringLength@#>0&):>AppendTo[readVar,s],
				EndOfFile:>($terminalProcessKillFlag=True)
				}];
		If[$terminalProcessKillFlag,KillProcess@p]
		];
terminalRead~SetAttributes~HoldRest;


terminalRun[cmd_,o___]:=
	With[{p=StartProcess[cmd,o]},
		Block[{
			$terminalDownloadStrings={StringJoin@{Riffle[cmd," "],"\n"}}
			},
			terminalRead[p,$terminalDownloadStrings];
			Monitor[
				While[ProcessStatus@p==="Running",
					terminalRead[p,$terminalDownloadStrings];
					Pause[.1];
					],
				Dynamic[
				Framed[
					Column@{
						Style[StringJoin@Riffle[cmd," "],
							GrayLevel[.2]],
						Framed[
							Pane[Dynamic@StringJoin@$terminalDownloadStrings,
								{{250,500},100},
								Scrollbars->Automatic,
								ScrollPosition->{0,Dynamic@25*Length@$terminalDownloadStrings}
								],
							Background->White
							]
						},
					Background->GrayLevel[.95],
					RoundingRadius->5
					],
				TrackedSymbols:>{}
				]
				];
			StringJoin@$terminalDownloadStrings
			]
		];


terminalRunNoBlocking[cmd_,o___]:=
	With[{p=StartProcess[cmd,o],s=Unique@"$terminalDownloadStrings$"},
		s={StringJoin@Riffle[cmd," "],"\n"};
		Interpretation[
			Dynamic[
				terminalRead[p,s];
				Framed[
					Column@{
						StringJoin@Riffle[cmd," "],
						Framed@
							Pane[StringJoin@s,
								{{250,500},100},
								Scrollbars->Automatic,
								ScrollPosition->{0,22*Length@s}
								]
						},
					RoundingRadius->5
					]
				],
			StringJoin@s
			]
		];


End[];



