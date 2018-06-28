(* ::Package:: *)



$CMakeDirectory::usage="The directory CMake is built into";
CMakeCheck::usage="Checks that CMake is installed";
cmakeBuild::usage="Dunno why Psi4Connection uses this but it does?";
CMakeBuild::usage="Gets and compiles the CMake system";


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*cmakeCheck*)



cmakeCheck[dir_]:=
	Quiet@Check[RunProcess[{"cmake"}],$Failed]=!=$Failed||
	FileExistsQ@FileNameJoin@{dir,"cmake","bin","cmake"};


(* ::Subsubsection::Closed:: *)
(*CMakeCheck*)



CMakeCheck//Clear


CMakeCheck[dir_:Automatic]:=
	cmakeCheck@
		Replace[dir, Automatic:>ParentDirectory@$CMakeDirectory]


(* ::Subsubsection::Closed:: *)
(*cmakeRemove*)



cmakeRemove[s_String?DirectoryQ]:=
	DeleteDirectory[
		FileNameJoin@{s,"cmake"},
		DeleteContents->True
		];


(* ::Subsubsection::Closed:: *)
(*$cmakeRoot*)



$cmakeRoot="https://cmake.org/files/v3.7";


(* ::Subsubsection::Closed:: *)
(*$cmakeInstallation*)



$cmakeInstallation="cmake-3.7.1.tar.gz";


(* ::Subsubsection::Closed:: *)
(*cmakeDownload*)



cmakeDownload[]:=
	URLDownload[
		URLBuild@{$cmakeRoot,$cmakeInstallation},
		FileNameJoin@{$TemporaryDirectory,$cmakeInstallation}
		];


(* ::Subsubsection::Closed:: *)
(*cmakeBuild*)



cmakeBuild[dir_,interactive:(True|False):True]:=
	With[{flag=
		If[interactive,
			FileExistsQ@FileNameJoin@{dir,"cmake"}||
			DialogInput[Column@{
			"This extension requires the cmake source code compiler (~250 MB)
This will install it on your system in the extension directory.
If you have root permissions it will also be installed and usable via
	'cmake /path/to/source/CMakeLists.txt'.

Would you like to continue?",
			Grid@{
				{
					Button["Yes",DialogReturn@True],
					Button["Cancel",DialogReturn@False]
					},
				{
				Button[
					Mouseover[
						Style["I'll install myself","Hyperlink"],
						Annotation[
							Style["I'll install myself","HyperlinkActive"],
							"https://cmake.org/download/"
							]
						],
					MessageDialog@"
Go to the binary distributions and choose the one that's right for you
";
					SystemOpen@$cmakeRoot;
					DialogReturn@False,
					Method->"Queued",
					Appearance->"Frameless"
					],
					SpanFromLeft
					}
				}
			}
			],
			True
			]},
		If[TrueQ@flag,
			If[!FileExistsQ@FileNameJoin@{dir,"cmake","bootstrap"},
				CurrentValue[EvaluationNotebook[],WindowStatusArea]=
					"Downloading from "<>URLBuild@{$cmakeRoot,$cmakeInstallation};
				Monitor[cmakeDownload[],
					Internal`LoadingPanel@"Downloading CMake"
					];
				CurrentValue[EvaluationNotebook[],WindowStatusArea]=
					"Extracting source...";
				Monitor[
					With[{d=CreateDirectory[]},
						ExtractArchive[
							FileNameJoin@{$TemporaryDirectory,$cmakeInstallation},
							d
							];
						DeleteFile@FileNameJoin@{$TemporaryDirectory,$cmakeInstallation};
						If[DirectoryQ@FileNameJoin@{dir,"cmake"},
							DeleteDirectory[FileNameJoin@{dir,"cmake"},DeleteContents->True]
							];
						CopyDirectory[
							FileNameJoin@{
								d,
								StringTrim[$cmakeInstallation,".tar.gz"]
								},
							FileNameJoin@{dir,"cmake"}
							];
						DeleteDirectory[d,DeleteContents->True]
						],
					Internal`LoadingPanel@"Extracting CMake source"
					];
				];
			CurrentValue[EvaluationNotebook[],WindowStatusArea]=
				"Installing cmake...";
			With[{cmakeDir=ExpandFileName@FileNameJoin@{dir,"cmake"}},
				If[!cmakeCheck@dir,
					Monitor[
						terminalRun[
							{
								"./configure",
								"--prefix=\""<>StringReplace[cmakeDir," "->"\\ "]<>"\""
								},
								ProcessDirectory->cmakeDir
							],
						Internal`LoadingPanel@"Configuring CMake"
						]
					];
				Monitor[
					terminalRun[{"make"},
						ProcessDirectory->
							cmakeDir
						];
					terminalRun[{"make","install"},
						ProcessDirectory->cmakeDir
						],
					Internal`LoadingPanel@"Building CMake"
					];
				CurrentValue[EvaluationNotebook[],WindowStatusArea]=None;
				If[FileExistsQ@FileNameJoin@{cmakeDir,"bin","cmake"},
					FileNameJoin@{cmakeDir,"bin","cmake"},
					$Failed
					]
				],
			$Failed
			]
		];


(* ::Subsubsection::Closed:: *)
(*$CMakeDirectory*)



$CMakeDirectory:=
	ChemExtensionDir["cmake"]


(* ::Subsubsection::Closed:: *)
(*CMakeBuild*)



CMakeBuild[d:_String?DirectoryQ|Automatic:Automatic]:=
	cmakeBuild[Replace[d,Automatic:>DirectoryName@$CMakeDirectory]];


End[];



