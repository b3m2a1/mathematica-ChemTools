(* ::Package:: *)



SwigBuild::usage="Gets and compiles the Swig system";


Begin["`Private`"];


(* ::Subsection:: *)
(*Swig*)



(* ::Subsubsection::Closed:: *)
(*$swigsrc*)



$swigsrc=
	"http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz";


(* ::Subsubsection::Closed:: *)
(*$swigpcresrc*)



$swigpcresrc="https://ftp.pcre.org/pub/pcre/pcre-8.41.tar.gz";


(* ::Subsubsection::Closed:: *)
(*swigDownload*)



swigDownload[dir_String?DirectoryQ]:=
	With[{
		tmpDir=
			CreateDirectory@
				FileNameJoin@{
					$TemporaryDirectory,
					StringJoin@RandomSample[Alphabet[],10]
					}
		},
		With[{
			f=URLDownload[$swigsrc,FileNameJoin@{tmpDir,"swig_tmp.tar.gz"}],
			out=FileNameJoin@{dir,"swig"}
			},
			ExtractArchive[f,tmpDir];
			DeleteFile[f];
			If[DirectoryQ@out,DeleteDirectory[out,DeleteContents->True]];
			CopyDirectory[First@FileNames["*",tmpDir],out];
			Quiet@DeleteDirectory[tmpDir,DeleteContents->True];
			swigpcreDownload[out];
			Replace[
				out,
				Except[_String?FileExistsQ]->$Failed
				]
		]
	];


swigpcreDownload[dir_]:=
	URLDownload[
		$swigpcresrc,
		FileNameJoin@{
			dir,
			FileNameTake[$swigpcresrc]
			}
		]


(* ::Subsubsection::Closed:: *)
(*swigBuild*)



swigBuild[dir_]:=
	With[{swigdir=ExpandFileName@FileNameJoin@{dir,"swig"}},
		terminalRun[{FileNameJoin@{"Tools","pcre-build.sh"}},
			ProcessDirectory->swigdir
			];
		terminalRun[
			{
				FileNameJoin@{swigdir,"configure"},
				"--prefix="<>
					FileNameJoin@
						Map[
							If[StringContainsQ[#,Whitespace],"\""<>#<>"\"",#]&,
							FileNameSplit[swigdir]
							]
				},
			ProcessDirectory->swigdir
			];
		terminalRun[{"make"},
			ProcessDirectory->swigdir
			];
		terminalRun[{"make","install"},
			ProcessDirectory->swigdir
			];
		If[FileExistsQ@FileNameJoin@{swigdir,"bin","swig"},
			FileNameJoin@{swigdir,"bin","swig"},
			$Failed
			]
		]


(* ::Subsubsection::Closed:: *)
(*swigCheck*)



swigCheck[dir_?DirectoryQ]:=
	FileExistsQ@FileNameJoin@{dir,"swig","bin","swig"};


(* ::Subsubsection::Closed:: *)
(*$swigExt*)



$swigExt:=ChemExtensionDir["swig"];


(* ::Subsubsection::Closed:: *)
(*SwigBuild*)



SwigBuild[dir:_String?DirectoryQ|Automatic:Automatic]:=
	With[{d=Replace[dir,Automatic:>DirectoryName@$swigExt]},
		If[!swigCheck[d],
			If[!DirectoryQ@FileNameJoin@{d,"swig"}||
				Length[
					Select[DirectoryQ]@
						FileNames["*",FileNameJoin@{d,"swig"}]
					]===0,
				swigDownload[d]
				];
			swigBuild[d]
			]
		]


End[];



