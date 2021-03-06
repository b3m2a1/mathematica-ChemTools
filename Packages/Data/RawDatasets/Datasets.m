(* ::Package:: *)

(* Autogenerated Package *)

(* ::Text:: *)
(*A collection of datasets used as ChemData sources*)



$ChemCustomAtoms::usage="";
$ChemIsotopicMasses::usage="";
$ChemAtomColors::usage="";
$ChemElements::usage="";
$ChemSpaceGroups::usage="";
$ChemBondDistances::usage="";
$ChemElementValences::usage="";
$ChemCharacterTables::usage="";
$ChemCorrelationTables::usage="";
$ChemTanabeSuganoData::usage="";
$ChemUnitConversions::usage="";
$ChemConstants::usage="";
$ChemMMMFF94AtomTypes::usage="";
$ChemMMMFF94BondData::usage="";
$ChemMMFF94BondAngleData::usage="";
$ChemMMFF94StretchBendData::usage="";
$ChemMMFF94TorsionAngleData::usage="";


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*Load*)



ChemDataLookup::nolod="Couldn't load resource ``, got ``";


$ChemDatasetsCachePermanent=False;


(* ::Subsubsubsection::Closed:: *)
(*ChemDatasetPacletFile*)



ChemDatasetPacletFile[name_]:=
  PackageFilePath["Resources", "Datasets", name<>".wl"];


(* ::Subsubsubsection::Closed:: *)
(*ChemDatasetTempFile*)



ChemDatasetTempFile[name_]:=
  FileNameJoin[
    {
      $TemporaryDirectory, 
      "ChemTools_Datasets",
      name<>".wl"
      }
    ];


(* ::Subsubsubsection::Closed:: *)
(*ChemDatasetAppDataFile*)



ChemDatasetAppDataFile[name_]:=
  FileNameJoin[
    {$UserBaseDirectory, "ApplicationData", "ChemTools", 
      "Datasets", name<>".wl"
      }
    ];


(* ::Subsubsubsection::Closed:: *)
(*ChemDatasetWebResourceFile*)



ChemDatasetWebResourceFile[name_]:=
  First@CloudObject@
    URLBuild[
      <|
        "Scheme"->"user", 
        "Path"->
          {
            "b3m2a1.paclets", 
            "PacletServer", 
            "Resources",
            "ChemTools", 
            "Datasets", 
            name<>".wl"
            }
        |>
      ];


(* ::Subsubsubsection::Closed:: *)
(*ChemDatasetDownload*)



ChemDatasetDownload[name_, "File"]:=
  With[
    {
      target=
        If[$ChemDatasetsCachePermanent,
          ChemDatasetAppDataFile[name], 
          ChemDatasetTempFile[name]
          ],
      source=ChemDatasetWebResourceFile[name]
      },
    If[!DirectoryQ@DirectoryName@target,
      CreateDirectory[DirectoryName@target, CreateIntermediateDirectories->True]
      ];
    Monitor[
      If[TrueQ[URLDownload[source, target, "StatusCode"]<400],
        target,
        Failure["ChemDatasetDownload", 
          "MessageTemplate"->
            TemplateApply["Couldn't download `` from ``",
             {name, source}
             ]
          ]
        ],
      Internal`LoadingPanel@
        TemplateApply["Downloading dataset `` from ``", {name, source}]
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*ChemDatasetLoad*)



ChemDatasetLoad//Clear


ChemDatasetLoad[name_, mode:"File"]:=
  Replace[
    SelectFirst[
      {
        ChemDatasetPacletFile[name],
        ChemDatasetAppDataFile[name],
        ChemDatasetTempFile[name]
        },
      FileExistsQ,
      ChemDatasetDownload[name, mode]
      ],
  {
    res:(_String|_File)?FileExistsQ:>
      Import[res],
    fail_:>
      (
        PackageThrowMessage[
          "NoDataset",
          "Couldn't load resource ``, got ``", 
          "MessageParameters"->{name, fail}
          ];
        SetDelayed[
          ChemDatasetLoad[name, mode], 
          PackageThrowMessage[
            "NoDataset",
            "Couldn't load resource ``, got ``", 
            "MessageParameters"->{name, fail}
            ]
          ];
        fail
        )
    }
  ];
ChemDatasetLoad[name_, Optional[Automatic, Automatic]]:=
  ChemDatasetLoad[name, "File"]


(* ::Subsubsection::Closed:: *)
(*Register*)



With[{ctx=$Context},
  ChemDatasetRegister[base:Hold[_Symbol]|Automatic:Automatic, name_, pat_]:=
    Replace[
      If[base===Automatic,
        ToExpression[
          StringTrim[$Context, "Private`"]<>"$"<>name, StandardForm, Hold],
        base
        ],
      Hold[sym_]:>
        If[!MatchQ[OwnValues[sym],{_:>pat}],
          sym:=
            sym=ChemDatasetLoad[name]
          ]
      ]
  ];


(* ::Subsubsection::Closed:: *)
(*$ChemCustomAtoms*)



(* ::Text:: *)
(*A set of non-standard atoms used internally sometimes*)



ChemDatasetRegister["ChemCustomAtoms", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemIsotopicMasses*)



ChemDatasetRegister["ChemIsotopicMasses", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemAtomColors*)



ChemDatasetRegister["ChemAtomColors", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemElements*)



ChemDatasetRegister["ChemElements", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemSpaceGroups*)



ChemDatasetRegister["ChemSpaceGroups", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemBondDistances*)



ChemDatasetRegister["ChemBondDistances", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemElementValences*)



ChemDatasetRegister["ChemElementValences", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemCharacterTables*)



ChemDatasetRegister["ChemCharacterTables", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemCorrelationTables*)



ChemDatasetRegister["ChemCorrelationTables", _Association?AssociationQ]


(* ::Subsubsection::Closed:: *)
(*$ChemTanabeSuganoData*)



ChemDatasetRegister[
  Hold[$ChemTanabeSuganoData], 
  "ChemTanabeSuganoDiagrams", 
  _Association?AssociationQ
  ]


(* ::Subsubsection::Closed:: *)
(*$ChemUnitConversions*)



ChemDatasetRegister[
  Hold[$ChemUnitConversions], 
  "ChemUnitConversions", 
  _Association?AssociationQ
  ]


(* ::Subsubsection::Closed:: *)
(*$ChemConstants*)



ChemDatasetRegister[
  Hold[$ChemConstants], 
  "ChemConstants", 
  _Association?AssociationQ
  ]


(* ::Subsubsection::Closed:: *)
(*$ChemMMMFF94AtomTypes*)



ChemDatasetRegister[
  Hold[$ChemMMFF94AtomTypes], 
  "MMFF94AtomTypes", 
  _Association?AssociationQ
  ]


(* ::Subsubsection::Closed:: *)
(*$ChemMMMFF94BondData*)



ChemDatasetRegister[
  Hold@$ChemMMMFF94BondData, 
  "MMFF94BondData", 
  _Association?AssociationQ
  ]


(* ::Subsubsection::Closed:: *)
(*$ChemMMFF94BondAngleData*)



ChemDatasetRegister[
  Hold@$ChemMMFF94BondAngleData, 
  "MMFF94BondAngleData", 
  _Association?AssociationQ
  ]


(* ::Subsubsection::Closed:: *)
(*$ChemMMFF94StretchBendData*)



ChemDatasetRegister[
  Hold@$ChemMMFF94StretchBendData, 
  "MMFF94StretchBendData", 
  _Association?AssociationQ
  ]


(* ::Subsubsection::Closed:: *)
(*$ChemMMFF94TorsionAngleData*)



ChemDatasetRegister[
  Hold@$ChemMMFF94TorsionAngleData, 
  "MMFF94TorsionAngleData", 
  _Association?AssociationQ
  ]


End[];



