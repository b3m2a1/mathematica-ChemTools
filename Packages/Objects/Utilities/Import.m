(* ::Package:: *)



ChemImportObjectString::usage=
	"Imports a chemical structure or structures from a string";
ChemImportObject::usage=
	"Routes imports to ChemImportObjectString";
$ChemImportableObjectTypes::usage=
	"Support import types";


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*Gaussian*)



gaussianImportObjectData[file:_String?FileExistsQ|_InputStream, "GaussianJob"]:=
	List@ImportGaussianJob[file, "MolTable"];
gaussianImportObjectData[file:_String?FileExistsQ|_InputStream, "FormattedCheckpoint"]:=
	List@ImportFormattedCheckpointFile[file, "MolTable"];


(* ::Subsubsection::Closed:: *)
(*generalizedImport*)



chemObjectImport[
	system:_String|ChemObject[_]|Automatic:Automatic,
	atomSets_List
	]:=
	With[{sys=Replace[system, Automatic:>$ChemDefaultSystem]},
		Replace[
			CreateAtomset[sys,#]&/@atomSets//Flatten,{
			{}->None,
			{a_}:>a
			}]
		];


(* ::Subsection:: *)
(*ImportString*)



(* ::Subsubsection::Closed:: *)
(*ImportString*)



ChemImportObjectString//Clear


ChemImportObject::noobj=
	"Unable to construct ChemObject. Check input file,";
ChemImportObject::nofmt=
	"Unable to autodetect format for ``";
ChemImportObjectString[
	system:ChemSysPattern|Automatic:Automatic,
	string_String?(Not@*FileExistsQ),
	format:"MolTable"|"ZMatrix"|"GaussianJob"|"FormattedCheckpoint"|Automatic
	]:=
	Switch[format,
		"MolTable",
			chemObjectImport[system,
				ChemImportMolTable@string],
		"ZMatrix",
			chemObjectImport[system,
				ChemImportZMatrix@string],
		"GaussianJob"|"FormattedCheckpoint",
			chemObjectImport[system,
				gaussianImportObjectData[
					StringToStream@string,
					format
					]
				],
		Automatic,
			Which[
				StringStartsQ[StringTrim@string, 
					LetterCharacter..~~(Whitespace|"")~~"\n"
					],
				chemObjectImport[system,
						ChemImportZMatrix@string],
				StringContainsQ[string, "V2000"|"V3000"],
					chemObjectImport[system,
						ChemImportMolTable@string],
				True,
					Message[ChemImportObject::nofmt, string];
					$Failed
				]
		];
ChemImportObjectString[
	system:ChemSysPattern|Automatic:Automatic,
	string_String?(Not@*FileExistsQ),
	Optional[Automatic,Automatic]]:=
	With[{attempts=
		If[StringContainsQ[string,"V2000"|"V3000"],
			{"MolTable","ZMatrix"},
			{"ZMatrix","MolTable"}
			]
		},
		Replace[
			ChemImportObjectString[system,string,First@attempts],{
			Except[_ChemObject|{__ChemObject}]:>
				Replace[
					Quiet@
						ChemImportObjectString[system,string,Last@attempts],
					e:Except[_ChemObject|{__ChemObject}]:>(
						Message[ChemImportObject::noobj];
						$Failed
						)
					]
			}]
		]


(* ::Subsection:: *)
(*Import*)



(* ::Subsubsection::Closed:: *)
(*Import From File*)



ChemImportObject[
	system:ChemSysPattern|Automatic:Automatic,
	file:_File|_String?FileExistsQ,
	format:"MolTable"|"ZMatrix"|"GaussianJob"|"FormattedCheckpoint"|Automatic:Automatic
	]:=
	With[{form=
		Replace[format,
			Automatic:>
				Switch[FileExtension@file,
					"mol"|"sdf",
						"MolTable",
					"zmat",
						"ZMatrix",
					"gjf",
						"GaussianJob",
					"fchk",
						"FormattedCheckpoint",
					_,
						Automatic
					]
				]
			},
		Switch[form,	
			"MolTable"|"ZMatrix",
				ChemImportObjectString[system, Import[file,"Text"], form],
			"GaussianJob"|"FormattedCheckpoint",
				chemObjectImport[system,
					gaussianImportObjectData[
						file,
						form
						]
					],
			Automatic,
				ChemImportObject[system, Import[file,"Text"]]
			]
		];


(* ::Subsubsection::Closed:: *)
(*String*)



ChemImportObject[
	system:ChemSysPattern|Automatic:Automatic,
	string:_String?(StringContainsQ["\n"]),
	fmt:"ZMatrix"|"MolTable"|Automatic:Automatic
	]:=
	ChemImportObjectString[system, string, fmt]


(* ::Subsubsection::Closed:: *)
(*URL*)



ChemImportObject[
	system:ChemSysPattern|Automatic:Automatic,
	file:_URL|_String?(URLParse[#]["Scheme"]=!=None&),
	format:"MolTable"|"ZMatrix"|Automatic:Automatic]:=
	With[{f=URLDownload@file},
		If[FileExistsQ@f,
			ChemImportObject[system,f,format],
			$Failed
			]
		];	


(* ::Subsubsection::Closed:: *)
(*PubChem*)



ChemImportObject::no3d=
	"No 3D structure found for identifier ``. Attempting to use a 2D structure instead";
ChemImportObject::nostr=
	"No structure found for identifier ``";
ChemImportObject[
	system:ChemSysPattern|Automatic:Automatic,
	structure:
		_PubChemCompound|
		_PubChemSubstance|
		_Integer|
		Entity["Chemical",_]|
		_String?(
			Not@FileExistsQ@#&&
			Not@StringContainsQ[#,"\n"|$PathnameSeparator]
			&),
	format:"MolTable"|"ZMatrix"|Automatic:Automatic]:=
	Replace[
		Replace[
			Quiet[ChemDataLookup[structure,"SDFFiles"],ServiceExecute::serrormsg],
			$Failed:>(
				Message[ChemImportObject::no3d, structure];
				ChemDataLookup[structure,"2DStructures",
					"Overwrite"->True]
				)
			],
		{
			mol_String:>
				ChemImportObjectString[system, mol, "MolTable"],
			mols:{__String}:>
				Map[ChemImportObjectString[system,#,"MolTable"]&,mols],
			_:>(Message[ChemImportObject::nostr,structure];$Failed)
			}
		];


(* ::Subsubsection::Closed:: *)
(*Graphics3D*)



ChemImportObject[
	system:ChemSysPattern|Automatic:Automatic,
	data_Graphics3D
	]:=
	chemObjectImport[system,chemImportGraphics3D@data];


(*ChemImportObject[
	system:ChemSysPattern|Automatic:Automatic,
	data_Graph
	]:=
	chemObjectImport[system,chemImportGraph@data];*)


(* ::Subsubsection::Closed:: *)
(*Importable Types*)



$ChemImportableObjectTypes=
	(
		_Graphics3D|_String|_Integer|Entity["Chemical",_]|
		_File|_URL|
		_PubChemCompound|_PubChemSubstance
		);


ChemImportObject[system:ChemSysPattern|Automatic:Automatic,
	data:{$ChemImportableTypes..}
	]:=
	ChemImportObject[system,#]&/@data;


(*ChemImportObject[
	system:ChemSysPattern|Automatic:Automatic,
	s_Symbol?(Not@*MatchQ[$ChemImportableTypes|{$ChemImportableTypes..}])
	]:=
	(s=ChemImportObject[system,SymbolName[Unevaluated[s]]]);*)


ChemImportObject[system:ChemSysPattern|Automatic:Automatic,
	s_?(MatchQ[$ChemImportableTypes|{$ChemImportableTypes..}]),
	o___
	]:=
	ChemImportObject[system,s,o];


ChemImportObject[
	a___
	]/;!TrueQ[$ChemImportInImport]:=
	Block[{$ChemImportInImport=True},
		With[{l={a}},
			ChemImportObject@@l
			]
		]


(*ChemImportObject~SetAttributes~HoldFirst;*)


End[];



