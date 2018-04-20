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



ImportGaussianJob::usage=
	"Imports data from a Gaussian job";
ImportFormattedCheckpointFile::usage=
	"Imports results from an FChk file";
ImportGaussianLog::usage=
	"Imports data from a log file";


Begin["`Private`"];


(* ::Subsection:: *)
(*GaussianJob*)



iGaussianReadLink0[link0Block_]:=
	Map[
		If[StringContainsQ[#, "="],
			Rule@@StringSplit[#, "=", 2],
			#
			]&,
		Select[
			StringSplit[StringTrim@link0Block, "%"|Whitespace],
			Not@*StringMatchQ[""|Whitespace]
			]
		];


iGaussianReadDirectives[directives_]:=
	Map[
		If[StringContainsQ[#, "="],
			Rule@@StringSplit[#, "=", 2],
			#
			]&,
		Select[
			StringSplit[StringTrim@directives, "#"|Whitespace],
			Not@*StringMatchQ[""|Whitespace]
			]
		];


iGaussianJobReadChargeAndMultiplicity[mult_]:=
	Map[
		Which[
			StringMatchQ[#, NumberString], 
				ToExpression[#], 
			StringMatchQ[#, Whitespace|""],
				Nothing,
			True,
				#
			]&,
		StringTrim@StringSplit[mult, ","|" "]
		];
iGaussianJobReadAtoms[atoms_]:=
	ImportString[atoms, "Table"];
iGaussianJobReadVariables[vars_]:=
	Map[
		Map[
			Which[
				StringMatchQ[#, NumberString], 
					ToExpression[#], 
				StringMatchQ[#, Whitespace|""],
					Nothing,
				True,
					#
				]&,
			StringSplit[StringTrim@#]
			]&, 
		StringSplit[vars, "\n"]
		];
iGaussianJobReadBonds[bonds_]:=
	ImportString[bonds, "Table"];


iGaussianJobReadSystem[systemSpec_]:=
	Module[
		{
			specText,
			mults,
			atoms,
			vars,
			consts,
			bonds
			},
		{mults, specText}=StringSplit[systemSpec, "\n", 2];
		atoms=
			First@
				StringCases[specText,
					Repeated[
						(Whitespace|"")~~LetterCharacter~~Except["\n"|":"]..~~("\n"|EndOfString)
						]
					];
		specText=StringTrim[specText, atoms];
		vars=
			StringCases[specText,
				StartOfLine~~Except["\n"]..~~":"~~(Whitespace|"")~~"\n"~~
					varBlock:
						Repeated[
							(Whitespace|"")~~LetterCharacter~~Except["\n"|":"]..~~("\n"|EndOfString)
							]:>varBlock
				];
		Which[
			Length@vars>1, 
				consts=vars[[2]];
				vars=vars[[1]],
			Length@vars==1,
				vars=vars[[1]];
				consts="",
			True,
				vars="";
				consts="";
			];
		bonds=
			Replace[
				StringCases[
					specText,
					Repeated[
						(Whitespace|"")~~DigitCharacter~~Except["\n"|":"]..~~("\n"|EndOfString)
						]
					],
				{
					{}->"",
					{e_, ___}:>e
					}
				];
		<|
			"MultiplicityAndCharge"->
				iGaussianJobReadChargeAndMultiplicity@mults,
			"Atoms"->
				iGaussianJobReadAtoms@atoms,
			"Variables"->
				iGaussianJobReadVariables@vars,
			"Constants"->
				iGaussianJobReadVariables@consts,
			"Bonds"->
				iGaussianJobReadBonds@bonds
			|>
		]


iGaussianJobRead[cleanText_]:=
	With[{baseSplit=StringTrim@StringSplit[cleanText, Repeated["\n", {2, \[Infinity]}], 4]},
		<|
			"Header"->
				<|
					"Link0"->iGaussianReadLink0@baseSplit[[1]],
					"Directives"->iGaussianReadDirectives@baseSplit[[2]],
					"Description"->StringTrim@baseSplit[[3]]
					|>,
			"System"->
				iGaussianJobReadSystem@baseSplit[[4]]
			|>
		];
iGaussianJobRead1[fullText_]:=
	iGaussianJobRead@
		StringTrim@
			StringReplace[Repeated["\n", {3, \[Infinity]}]->"\n\n"]@
				Fold[
					StringDelete,
					fullText,
					{
						(StartOfLine~~"!"~~Except["\n"]...~~"\n"),
						"!"~~Except["\n"]..
						}
					];


ImportGaussianJob[file:_String?FileExistsQ|_InputStream]:=
	ImportGaussianJob[ReadString@file];
ImportGaussianJob[str_String?(Not@*FileExistsQ)]:=
	iGaussianJobRead1[str];
ImportGaussianJob[file:_String|_InputStream, "MolTable"]:=
	With[{dats=ImportGaussianJob[file]},
		Join[
			{{Length@dats["Atoms"], Length@dats["Bonds"]}},
			Lookup[dats, "Atoms", {}],
			Lookup[dats, "Bonds", {}]
			]
		]


(* ::Subsection:: *)
(*GaussianLogRead*)



(* ::Subsubsection::Closed:: *)
(*iGaussianLogRead*)



iGaussianLogRead[log_InputStream, recSeps_, postProcess_]/;!TrueQ[$GaussianLogReadEOF]:=
	With[
		{
			sp=
				Quiet@StreamPosition@log,
			res=
				Read[log, Record, 
					RecordSeparators->recSeps
					]
			},
		If[res===EndOfFile,
			$GaussianLogReadEOF=
				Quiet@Check[SetStreamPosition[log, sp], True];
			Missing["NotFound"],
			postProcess@res
			]
		];
iGaussianLogRead[log_InputStream, recSeps_, postProcess_]/;TrueQ[$GaussianLogReadEOF]=
	Missing["EndOfFile"]


(* ::Subsubsection::Closed:: *)
(*GaussianLogRead*)



(* ::Subsubsubsection::Closed:: *)
(*Main*)



GaussianLogRead[logFile:_String?FileExistsQ, key_]:=
	With[{or=OpenRead[logFile]},
		Replace[$Failed:>(Close[or];$Failed)]@
			CheckAbort[
				With[{res=GaussianLogRead[or, key]},
					Close[or];
					res
					],
				$Failed
				]
		];
GaussianLogRead[logString_String, key_]:=
	With[{or=StringToStream[logString]},
		Replace[$Failed:>(Close[or];$Failed)]@
			CheckAbort[
				With[{res=GaussianLogRead[or, key]},
					Close[or];
					res
					],
				$Failed
				]
		];


(* ::Subsubsubsection::Closed:: *)
(*ZMatrix*)



gaussianLogReadZMatrixBlock[zmat_]:=
	Map[
		Which[
			Length@#>5,
				MapAt[
					Quantity[#, "Angstroms"]&, 
					MapAt[Quantity[#, "AngularDegrees"]&, #, {{5}, {7}}],
					{3}
					],
			Length@#>3,
				MapAt[
					Quantity[#, "Angstroms"]&, 
					MapAt[Quantity[#, "AngularDegrees"]&, #, {5}], 
					{3}
					],
			Length@#>1,
					MapAt[Quantity[#, "Angstroms"]&, #, {3}],
			True,
				#
			]&,
		ImportString[
			StringTrim@
				First@StringSplit[
					StringSplit[StringTrim@zmat, "\n", 2][[2]],
					"Variables:"
					],
			"Table"
			]
		];


GaussianLogRead[log_InputStream, "ZMatrix"]:=
	iGaussianLogRead[
		log,
		{{"Z-matrix:"}, {"NAtoms="}},
		gaussianLogReadZMatrixBlock
		]


(* ::Subsubsubsection::Closed:: *)
(*Scan*)



gaussianLogReadScanBlock[scan_]:=
	Module[
		{
			splits=
				StringTrim[
					StringSplit[scan, Repeated[Repeated["-"]|"  "]~~Repeated["-"], 2],
					Repeated[Repeated["-"]|"  "]~~Repeated["-"]
					],
			headers,
			vars,
			energyPos,
			tab
			},
		headers=StringSplit[splits[[1]]];
		energyPos=First@FirstPosition[headers, "SCF"];
		vars=Append[Take[headers, {2, energyPos-1}], "V"];
		tab=
			MapAt[
				#&,
				Partition[
					ReadList[StringToStream@splits[[2]], Number], 
					Length@headers
					][[All, Append[Range[2, energyPos-1], -1]]],
				{All, -1}
				];
		Map[Thread[vars->#]&, tab]
		];


GaussianLogRead[log_InputStream, "Scan"]:=
	iGaussianLogRead[
		log,
		{{"scan:"}, {"\n  \n"}},
		gaussianLogReadScanBlock
		];


(* ::Subsubsubsection::Closed:: *)
(*ComputerTimeElapsed*)



gaussianLogReadTimeElapsedBlock[elapsed_]:=
	With[
		{
			times=ToExpression@StringCases[elapsed, NumberString],
			units={"Days", "Hours", "Minutes", "Seconds"}
			},
		With[{mlen=Min[Length/@{times, units}]},
			Quantity[
				MixedMagnitude[Take[times, mlen]],
				MixedUnit[Take[units, mlen]]
				]
			]
		];


GaussianLogRead[log_InputStream, "ComputerTimeElapsed"]:=
	iGaussianLogRead[
		log,
		{{"cpu time:"}, {"\n"}},
		gaussianLogReadTimeElapsedBlock
		];


(* ::Subsubsubsection::Closed:: *)
(*Blurb*)



GaussianLogRead[log_InputStream, "Blurb"]:=
	iGaussianLogRead[
		log,
		{{"\n\n\n"}, {"\n Job "}},
		StringTrim
		]


(* ::Subsubsubsection::Closed:: *)
(*StartDateTime*)



gaussianLogReadParseStartDateTime[s_String]:=
	DateObject@
		First@
			StringSplit[
				Last@
					StringSplit[
						s,
						" at "
						],
				","
				]


GaussianLogRead[log_InputStream, "StartDateTime"]:=
	iGaussianLogRead[log,
		{{"Leave Link"}, {"\n (Enter"}},
		gaussianLogReadParseStartDateTime
		]


(* ::Subsubsubsection::Closed:: *)
(*EndDateTime*)



gaussianLogReadParseEndDateTime[s_String]:=
	DateObject@Last@
		StringSplit[s, " at "]


GaussianLogRead[log_InputStream, "EndDateTime"]:=
	iGaussianLogRead[
		log,
		{{"Normal termination of Gaussian"}, {"\n"}},
		gaussianLogReadParseEndDateTime
		]


(* ::Subsubsection::Closed:: *)
(*ImportGaussianLog*)



$GaussianLogKeywords=
	{
		"StartDateTime",
		"ZMatrix",
		"Scan",
		"Blurb",
		"ComputerTimeElapsed",
		"EndDateTime"
		};


ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	k_String
	]:=
	Block[{$GaussianLogReadEOF},
		Replace[
			GaussianLogRead[file, k],
			_GaussianLogRead->Missing["UnknownKey", k]
			]
		];
ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	k:{__String}
	]:=
	Block[{$GaussianLogReadEOF},
		AssociationMap[
			Replace[
				GaussianLogRead[file, #],
				_GaussianLogRead->Missing["UnknownKey", #]
				]&,
			SortBy[
				k, 
				Position[$GaussianLogKeywords, #]&
				]
			]
		];
ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	Optional[All, All]
	]:=
	ImportGaussianLog[file, $GaussianLogKeywords]


ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	"ScanQuantityArray"
	]:=
	With[{bits=ImportGaussianLog[file, {"ZMatrix", "Scan"}]},
		If[MissingQ@bits[[2]],
			bits[[2]],
			With[{
				keys=Keys@First@bits[[2]], 
				vals=Values@bits[[2]], 
				zm=bits[[1]],
				uc=
					QuantityMagnitude@
						UnitConvert[
							Quantity[1, "Hartrees"], 
							"Wavenumbers"*"PlanckConstant"*"SpeedOfLight"
							]
				},
				With[
					{
						types=
							Map[
								Switch[FirstPosition[zm, #], 
									{_, 3, ___}, "Angstroms",
									_, "AngularDegrees"
									]&,
								Most@keys
								]
						},
				Map[QuantityVariable, keys]->
					QuantityArray[
						MapAt[uc*#&, vals, {All, -1}], 
						Append[types, "Wavenumbers"]
						]
					]
				]
			]
		]


(* ::Subsection:: *)
(*FormattedCheckPoint Files*)



(* ::Subsubsection::Closed:: *)
(*iFormattedCheckpointRead*)



Clear[iFormattedCheckpointRead];
ImportFormattedCheckpointFile::misfmt=
	"Misformatted fchk file or failed to extract from block appropriately. \
`` isn't an appropriate line specification.";
iFormattedCheckpointRead[
	stream_InputStream, 
	keys:_?StringPattern`StringPatternQ|{__?StringPattern`StringPatternQ}|All
	]:=
	Module[
		{
			validKeys=
				Replace[keys, 
					{
						"*"|Verbatim[__]->All,
						{p__}:>Alternatives[p]
						}
					],
			header,
			line,
			lineParts,
			keyRaw,
			key,
			subspec,
			type,
			results=<||>
			},
			header=Internal`Bag[];
			Do[
				line=ReadList[stream, String, 1];
				(* If we've hit the end of the file we just return *)
				If[line==={}, Return[EndOfFile], line=line[[1]] ];
				(* test to see if we've read the header yet *)
				If[header=!=None,
					(* while in the header *)
					If[StringFreeQ[line, "Number of atoms"~~__~~" I "],
						(* stuff the bag *)
						Internal`StuffBag[header, line];
						Continue[],
						(* exit the header *)
						results["Header"]=
							StringRiffle[Internal`BagPart[header, All], "\n"];
						header=None;
						]
					];
				(* if the line is malformatted we fail out *)
				If[StringStartsQ[line, " "],
					Message[ImportFormattedCheckpointFile::misfmt, line];
					results=Return[$Failed]
					];
				(* All lines are whitespace separated by multiple spaces *)
				lineParts=StringSplit[line, Repeated[" ", {2, \[Infinity]}]];
				(* The key is the first element *)
				keyRaw=lineParts[[1]];
				(* We'll reformat it to be more Mathematica appropriate *)
				key=
					StringJoin@
						Map[
							With[{base=Last@StringSplit[StringTrim[#, "/"],"/"]},
								ToUpperCase@StringTake[base, 1]<>StringDrop[base, 1]
								]&,
							 StringSplit[lineParts[[1]], " "]
							];
				If[MatchQ[lineParts[[2]], "I"|"R"|"C"|"L"],
					subspec=None,
					(* subspec is the second *)
					subspec=
						StringJoin@
							Map[
								With[{base=Last@StringSplit[StringTrim[#, "/"],"/"]},
									ToUpperCase@StringTake[base, 1]<>StringDrop[base, 1]
									]&,
								 StringSplit[lineParts[[2]], " "]
								];
					(* Shift so that the type is the second *)
					lineParts=Delete[lineParts, 2]
					];
				(* The type is the second *)
				type=lineParts[[2]];
				(* If we've specified a subset of keys we make sure we're taking one of those *)
				If[validKeys===All||StringMatchQ[key, validKeys],
					(* Check if we're starting a block *)
					With[{res=
						If[lineParts[[3]]=="N=",
							With[{n=ToExpression[lineParts[[4]]]},
								Switch[type,
									"R"|"I",
									If[n>50,
										RawArray[
											If[type=="R", "Real64", "Integer32"],
											ReadList[stream, Number, n]
											],
										ReadList[stream, Number, n]
										],
									"C",
										ReadList[stream, Word, n],
									"H",
										(* Gaussian encodes this without whitespace padding so it requires lower-level tricks *)
										Replace[
											With[{lines=Quotient[n, 72], extras=Mod[n, 72]},
												Flatten[{
													ReadList[stream,
														ConstantArray[Character, 75],
														Quotient[n, 72]
														][[All, 3;;74]],
													ReadList[stream, 
														ConstantArray[Character, 3+extras], 
														1][[All, 3;;2+extras]]
													}]
												],
											{
												"1"->True,
												"0"->False,
												" "->Nothing,
												_->Indeterminate
												},
											1
											]
									]
								],
							Which[
								type=="R"&&
									StringLength[lineParts[[3]]]>4&&
									StringTake[lineParts[[3]], {-4}]=="E",
									ToExpression@
										StringReplacePart[lineParts[[3]], "*10^", {-4, -4}],
								MatchQ[type, "I"|"R"],
									ToExpression@lineParts[[3]],
								MatchQ[type, "L"],
									Switch[lineParts[[3]], "0", False, "1", True, _, Indeterminate],
								MatchQ[type, "C"],
									lineParts[[3]]
								]
							]
						},
						If[subspec===None,
							results[key]=res,
							If[!KeyExistsQ[results, key],
								results[key]=<|subspec->res|>,
								results[key, subspec]=res
								]
							]
						];,
					(* we place the break here so subspec keys aren't missed *)
					If[ListQ@keys&&Sort[keys]==Sort[Keys[results]],
						Break[]
						];
					(* skip if necessary *)
					If[lineParts[[3]]=="N=",
						Skip[stream, 
							Number, 
							ToExpression[lineParts[[4]]]
							]
						]
					],
				{i, \[Infinity]}
				];
			results
			];
iFormattedCheckpointRead[
	file_String?FileExistsQ, 
	keys:_?StringPattern`StringPatternQ|All
	]:=
	With[
		{
			strm=OpenRead@file
			},
		With[
			{
				 res=
				CheckAbort[iFormattedCheckpointRead[strm, keys], $Aborted]
				},
			Close[strm];
			res
			]
		];


(* ::Subsubsection::Closed:: *)
(*iFormattedCheckpointCleanResults*)



Clear[iFormattedCheckpointCleanResults];
iFormattedCheckpointCleanResults[results_Association?AssociationQ]:=
	Association@
		KeyValueMap[
			#->
				If[AssociationQ@#2,
					iFormattedCheckpointCleanResults[#2],
					Which[
						StringEndsQ[#, "Density"],
							With[{sq=Sqrt[Length[#2]]},
								If[IntegerQ@sq&&Positive[sq], 
									RawArray[
										Developer`RawArrayType@#2,
										Partition[Normal@#2, sq]
										], 
									#2
									]
								],
						StringContainsQ[#, "Coordinates"],
							QuantityArray[
								Partition[Normal@#2, 3], 
								"BohrRadius"
								],
						StringEndsQ[#, "Energy"|"Energies"],
							If[NumericQ@#2,
								Quantity[#2, "Hartrees"],
								QuantityArray[Normal@#2, "Hartrees"]
								],
						True,
							#2
						]
					]&,
			results
			];
iFormattedCheckpointCleanResults[_]:=$Failed


(* ::Subsubsection::Closed:: *)
(*ImportFormattedCheckpointFile*)



Options[ImportFormattedCheckpointFile]=
	{
		"KeyPattern"->All
		};
ImportFormattedCheckpointFile[
	file:_String?FileExistsQ|_InputStream, 
	ops:OptionsPattern[]
	]:=
	With[{res1=iFormattedCheckpointRead[file, OptionValue["KeyPattern"]]},
		If[AssociationQ@res1,
			iFormattedCheckpointCleanResults[res1],
			$Failed
			]
		];
ImportFormattedCheckpointFile[
	file:_String?FileExistsQ|_InputStream,
	"MolTable",
	ops:OptionsPattern[]
	]:=
	With[
		{
			dats=
				ImportFormattedCheckpointFile[file, 
					"KeyPattern"->
						{
							"CurrentCartesianCoordinates", 
							"AtomicNumbers", 
							"IBond"
							}, 
					ops
					]
			},
			With[
				{
					bonds=
						DeleteDuplicates@
							Flatten[
								MapIndexed[
									Map[Sort]@Thread[{#2[[1]],DeleteCases[#, 0]}]&,
									Partition[dats["IBond"], Length@dats["AtomicNumbers"]-1]
									],
								1
								]
					},
				Join[
					{{Length@dats["AtomicNumbers"], Length@bonds}},
					Thread[
						{
							ChemDataLookup[dats["AtomicNumbers"], "Symbol"],
							QuantityMagnitude@
								UnitConvert[dats["CurrentCartesianCoordinates"], "Angstroms"]
							}
						],
					bonds
					]
				]
		];
ImportFormattedCheckpointFile[
	str:_String,
	keys___String,
	ops:OptionsPattern[]
	]:=
	ImportFormattedCheckpointFile[StringToStream[str], keys, ops];


End[];



