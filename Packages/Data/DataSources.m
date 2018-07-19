(* ::Package:: *)

(* Autogenerated Package *)

$ChemDataSources::usage=
  "A list of ChemData expressions used by ChemDataLookup";


ChemDataSource::usage=
  "Converts a string into a datasource from which to pull relevant properties";


Begin["`Private`"];


(* ::Subsection:: *)
(*Setup*)



(* ::Subsubsection::Closed:: *)
(*$ChemDataSourcesDontCacheFlag*)



$ChemDataSourcesDontCacheFlag=False;


(* ::Subsubsection::Closed:: *)
(*$ChemDataSources*)



If[!AssociationQ@$ChemDataSources,
  $ChemDataSources=<||>
  ];


$ChemDataSources/:
  HoldPattern[
    Set[
      $ChemDataSources[key_],
      val:Except[_ChemData]]
      ]:=(
        Message[ChemData::badsrc];
        $Failed
        );


(* ::Subsubsection::Closed:: *)
(*chemDataSourceAdd*)



chemDataSourceAdd[key_,val_]:=
  If[!KeyMemberQ[$ChemDataSources, key],
    $ChemDataSources[key]=Prepend[val, key]
    ];
chemDataSourceAdd[key_->val_]:=
  chemDataSourceAdd[key,val]


(* ::Subsubsection::Closed:: *)
(*chemDataCAQ*)



chemDataCAQ[q_]:=
  KeyExistsQ[$ChemCustomAtoms, q]


(* ::Subsubsection::Closed:: *)
(*chemDataSourceGetQueryString*)



chemDataSourceGetQueryString[q_String]:=
  If[!chemDataCAQ[q]||StringLength[q]<3,
    q,
    ChemDataLookup[q, "Symbol"]
    ];
chemDataSourceGetQueryString[q_]:=
  q;


(* ::Subsubsection::Closed:: *)
(*chemDataCARouter*)



chemDataCARouter[q_, f1_, prop_]:=
  With[{ca=ChemDataLookup[q, "CustomAtoms"]},
    If[AssociationQ@ca, 
      ca[prop],
      f1[q]
      ]
    ];
chemDataCARouter[f_, prop_][q_]:=
  chemDataCARouter[q, f, prop];


(* ::Subsubsection::Closed:: *)
(*chemDataIsoElRouter*)



chemDataIsoElRouter[q_, prop_]:=
  If[ChemDataIsotopeQ@q,
    ElementData[ChemDataLookup[q, "Symbol"], prop],
    ElementData[q, prop]
    ]


(* ::Subsection:: *)
(*CustomAtoms*)



(* ::Subsubsection::Closed:: *)
(*CDCustomAtoms*)



CDCustomAtoms[All]:=
  $ChemCustomAtoms;
CDCustomAtoms[q_]:=
  $ChemCustomAtoms[q];


(* ::Subsubsection::Closed:: *)
(*chemDataSourceAdd*)



chemDataSourceAdd[
  "CustomAtoms"->
    ChemData[
      CDCustomAtoms,
      Missing["NoAtom", #]&
      ]
  ]


(* ::Subsection:: *)
(*AtomColors*)



(* ::Subsubsection::Closed:: *)
(*CDAtomColor*)



CDAtomColor[All]:=
  Join[
    EntityValue["Element", "IconColor", "Association"],
    $ChemAtomColors
    ];
CDAtomColor[q_]:=
  chemDataIsoElRouter[q, "IconColor"];


(* ::Subsubsection::Closed:: *)
(*AtomColors*)



chemDataSourceAdd[
  "AtomColors"->
    ChemData[
      chemDataCARouter[CDAtomColor, "Color"],
      GrayLevel[.5, .5]&
      ]
  ];


(* ::Subsection:: *)
(*BondDistances*)



(* ::Subsubsection::Closed:: *)
(*CDSBondListPre*)



CDSBondListPre[q_String]:=
  Which[
    StringContainsQ[q, "=_"|"_="|"-="|"=-"],
      Append[StringSplit[q, "=_"|"_="|"-="|"=-", 2], 3],
    StringContainsQ[q, "="], 
      Append[StringSplit[q, "=", 2], 2], 
    StringContainsQ[q, "-"], 
      Append[StringSplit[q, "-", 2], 2], 
    True,
      With[
        {
          splitties=
            StringJoin/@
              Partition[
                Rest@StringSplit[q, cap:LetterCharacter?(Not@*LowerCaseQ):>cap, 3],
                UpTo[2]
                ]
          },
        Append[splitties, 1]
        ]
    ];
CDSBondListPre[q_]:=q


(* ::Subsubsection::Closed:: *)
(*CDSBondDistance*)



CDSBondDistance[query_,___]:=
  With[{q=If[AtomQ@query,query,List@@query]},
    $ChemDataSourcesDontCacheFlag=True;
    With[{prepped=CDSBondListPre[q]},
      (*If[AnyTrue[prepped, chemDataCAQ],
				prepped,*)
        $ChemBondDistances@
          Append[
            Sort@prepped[[;;2]],
            prepped[[3]]
            ]
        (*]*)
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*BondDistances*)



chemDataSourceAdd[
  "BondDistances"->
    ChemData[
      CDSBondDistance, 
      -1.&
      ]
  ]


(* ::Subsection:: *)
(*UnitConversions*)



(* ::Subsubsection::Closed:: *)
(*CDUnitConversion*)



CDUnitConversion[q_]:=
  Switch[q, 
    Keys,
      Keys@$ChemUnitConversions,
    All,
      $ChemUnitConversions,
    _,
      $ChemUnitConversions[Echo@q]
    ]


(* ::Subsubsection::Closed:: *)
(*UnitConversions*)



chemDataSourceAdd[
  "UnitConversions"->
    ChemData[
      CDUnitConversion,
      $Failed&
      ]
  ];


(* ::Subsection:: *)
(*Constants*)



(* ::Subsubsection::Closed:: *)
(*CDConstant*)



CDConstant[q_]:=
  Switch[q, 
    Keys,
      Keys@$ChemConstants,
    All,
      $ChemConstants,
    _,
      $ChemConstants[q]
    ]


(* ::Subsubsection::Closed:: *)
(*Constants*)



chemDataSourceAdd[
  "Constants"->
    ChemData[
      CDConstant,
      $Failed&
      ]
  ];


(* ::Subsection:: *)
(*CharacterTables*)



(* ::Subsubsection::Closed:: *)
(*CDSCharacterTable*)



CDSCharacterTable[query_,___]:=(
  $ChemDataSourcesDontCacheFlag=True;
  Replace[CharacterTable[query],
    Except[HoldPattern[CharacterTable[_Association]]]:>
      $Failed
    ]
  );


(* ::Subsubsection::Closed:: *)
(*CharacterTables*)



chemDataSourceAdd[
  "CharacterTables"->
    ChemData[
      CDSCharacterTable,
      Missing["NoCharacterTable", #]&
      ]
  ];


(* ::Subsection:: *)
(*SpaceGroups*)



(* ::Subsubsection::Closed:: *)
(*CDSSpaceGroup*)



CDSSpaceGroup[query_,___]:=(
  $ChemDataSourcesDontCacheFlag=True;
  With[{r=
    Replace[{
      i_Integer:>$ChemSpaceGroups[[i]],
      s_String:>$ChemSpaceGroups[s],
      Keys:>Keys@$ChemSpaceGroups,
      Values:>Values@$ChemSpaceGroups,
      Dataset:>Dataset@$ChemSpaceGroups
      }]
    },
    Replace[r@query,
      _Missing:>
    Replace[r@StringReplace[query," "->""],
      _Missing:>
    Replace[
      r@StringReplace[query,
        {" "~~d:DigitCharacter:>"-"<>d," "->""}],
      _Missing:>
        Missing["NoSpaceGroup"]
      ]]]
    ]
  );


(* ::Subsubsection::Closed:: *)
(*SpaceGroups*)



chemDataSourceAdd[
  "SpaceGroups"->
    ChemData[
      CDSSpaceGroup,
      Missing["NoSpaceGroup",#]&
      ]
  ];


(* ::Subsection:: *)
(*ElementValences*)



(* ::Subsubsection::Closed:: *)
(*CSDElementValences*)



CSDElementValences[query_,___]:=
  With[
    {
      qReal=ChemDataLookup[query, "Symbol"]
      },
    $ChemDataSourcesDontCacheFlag=True;
    Replace[
      Lookup[
        $ChemElementValences, 
        qReal, 
        ElementData[qReal, "Valence"]
        ],
      i_Integer:>{i}
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*ElementValences*)



chemDataSourceAdd[
  "ElementValences"->
    ChemData[
      chemDataCARouter[CSDElementValences, "Valences"],
      Missing["NoValences", #]&
      ]
  ]


(* ::Subsection:: *)
(*PubChemIDs*)



(* ::Subsubsection::Closed:: *)
(*CDSPubChemID*)



CDSPubChemID[query_,___]:=
  Replace[query,
    {
      PubChemCompound[id_]|Entity["PubChemCompound", id_]:>
        PubChemID[id],
      PubChemSubstance[id_]|Entity["PubChemSubstance", id_]:>
        PubChemSubstanceIDs[id],
      ChemDataQuery[e___]:>
        PubChemID[e],
      e_:>
        PubChemID[e]
      }
    ]


(* ::Subsubsection::Closed:: *)
(*PubChemIDs*)



chemDataSourceAdd[
  "PubChemIDs"->
    ChemData[CDSPubChemID, $Failed&]
  ];


(* ::Subsection:: *)
(*PubChemNames*)



(* ::Subsubsection::Closed:: *)
(*CDSPubChemNames*)



CDSPubChemNames[query_,___]:=
  With[{inf=
    Replace[query,{
      ChemDataQuery[ids_,pars___]:>
        PubChemInfo[ids,pars],
      ids_:>
        PubChemInfo[ids]
      }]
    },
    With[{names=Lookup[inf,"IUPACName"]},
      Replace[query,{
        ChemDataQuery[k_]:>
          (ChemData[k,"PubChemNames"]=names;names),
        _->names
        }]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*PubChemNames*)



chemDataSourceAdd[
  "PubChemNames"->
    ChemData[CDSPubChemNames,$Failed&]
    ]


(* ::Subsection:: *)
(*PubChemComponentIDs*)



chemDataSourceAdd[
  "PubChemComponentIDs"->
    ChemData[PubChemComponentIDs@#&,$Failed&]
  ]


(* ::Subsection:: *)
(*ParentIDs*)



chemDataSourceAdd[
  "PubChemParentIDs"->
    ChemData[PubChemParentIDs@#&,$Failed&]
  ]


(* ::Subsection:: *)
(*SimilarIDs*)



(* ::Subsubsection::Closed:: *)
(*CDSSimilarIDs*)



CDSSimilarIDs[query_,___]:=
  With[{keyParameters=
    Replace[query,{
      ChemDataQuery[k_]:>
        {k,"Similar3D"},
      ChemDataQuery[k_,p_]:>
        {k,p},
      k_:>
        {k,"Similar3D"}
      }]},
    PubChemRelatedIDs[
      ChemDataLookup[First@keyParameters,"PubChemIDs"],
      Last@keyParameters
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*PubChemSimilarIDs*)



chemDataSourceAdd[
  "PubChemSimilarIDs"->
    ChemData[CDSSimilarIDs,$Failed&]
  ]


(* ::Subsection:: *)
(*2DStructures*)



chemDataSourceAdd[
  "2DStructures"->
      ChemData[PubChemStructure@#&,$Failed&]
  ]


(* ::Subsection:: *)
(*SDFFiles*)



(* ::Subsubsection::Closed:: *)
(*CDFSDFFile*)



CDFSDFFile[sdf_]:=
  Replace[
    $ChemSDFFiles[sdf],
    Except[_String]:>
      PubChemSDF@sdf
      (*Replace[PubChemSDF@sdf,
				_Missing|$Failed\[RuleDelayed]
					Replace[PubChemParentSDF@sdf,
						_Missing|$Failed\[RuleDelayed]PubChemComponentSDF@sdf
						]
				]*)
    ]


(* ::Subsubsection::Closed:: *)
(*SDFFiles*)



chemDataSourceAdd[
  "SDFFiles"->
    ChemData[CDFSDFFile, $Failed&]
  ]


(* ::Subsection:: *)
(*MolTable*)



(* ::Subsubsection::Closed:: *)
(*CDSMolTable*)



CDSMolTable[sdf_]:=
  Replace[
    ChemDataLookup[sdf, "SDFFiles"],
    s_String:>
      ImportString[s, "MolTable"]
    ]


(* ::Subsubsection::Closed:: *)
(*MolTable*)



chemDataSourceAdd[
  "MolTable"->
    ChemData[CDSMolTable, $Failed&]
  ]


(* ::Subsection:: *)
(*PrimaryIsotope*)



(* ::Subsubsection::Closed:: *)
(*CDFPrimaryIsotope*)



CDFPrimaryIsotope[q_]:=
  Replace[
    If[ChemDataIsotopeQ@q,
      IsotopeData[IsotopeData[q, "AtomicNumber"]],
      IsotopeData[q]
      ],
    {
      {{___, e_}, ___}:>e
      }
    ];


(* ::Subsubsection::Closed:: *)
(*PrimaryIsotope*)



chemDataSourceAdd[
  "PrimaryIsotope"->
    ChemData[
      CDFPrimaryIsotope,
      $Failed&
      ]
    ];


(* ::Subsection:: *)
(*StandardName*)



(* ::Subsubsection::Closed:: *)
(*CDSStandardName*)



CDSStandardName[q_]:=
  With[{s=Replace[q, {"D"->"H2","T"->"H3"}]},
    If[ChemDataIsotopeQ@s,
      IsotopeData[s,"StandardName"],
      ElementData[s,"StandardName"]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*StandardName*)



chemDataSourceAdd[
  "StandardName"->
    ChemData[
      chemDataCARouter[CDSStandardName, "StandardName"],
      $Failed&(*,
			<|
				"X"\[Rule]"X",
				"Invisible"->
					"Invisible",
				"Black"->
					"Black",
				"White"->
					"White"
				|>*)
      ]
  ]


(* ::Subsection:: *)
(*Symbol*)



(* ::Subsubsection::Closed:: *)
(*CDSSymbol*)



CDSSymbol[s_]:=
  Which[
    IntegerQ@s&&Positive@s,
      $ChemDataSourcesDontCacheFlag=True;
      $ChemElements[s],
    StringQ@s&&StringMatchQ[s, DigitCharacter..],
      $ChemDataSourcesDontCacheFlag=True;
      $ChemElements[Floor@Internal`StringToDouble@s],
    KeyExistsQ[$ChemElements, s]&&
      StringLength[s]<3,
      s,
    KeyExistsQ[$ChemElements, s],
      $ChemElements[s],
    ChemDataIsotopeQ@s,
      ElementData[
        ChemDataLookup[s, "AtomicNumber", IsotopeData],
        "Symbol"
        ],
    True,
      ElementData[s, "Symbol"]
    ]


(* ::Subsubsection::Closed:: *)
(*Symbol*)



chemDataSourceAdd[
  "Symbol"->
    ChemData[
      chemDataCARouter[CDSSymbol, "Symbol"],
      $Failed&,
      <|
        -1->"X",
        -2->"Invisible"
        |>
      ]
  ]


(* ::Subsection:: *)
(*Radius*)



(* ::Subsubsection::Closed:: *)
(*CDSourceRadius*)



CDSourceRadius[query_,___]:=
  With[{n=
    If[ChemDataIsotopeQ@query,
      ChemDataLookup[query,
        "AtomicNumber",IsotopeData],
      query]},
    Replace[
      ElementData[n,"VanDerWaalsRadius"],
      Except[_?NumericQ|_Quantity]:>
          Replace[ElementData[n,"AtomicRadius"],
            Except[_?NumericQ|_Quantity]:>$Failed
            ]
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*Radius*)



chemDataSourceAdd[
  "Radius"->
    ChemData[
      chemDataCARouter[CDSourceRadius, "Radius"],
      Quantity[25., "Picometers"]&
      ]
  ];


(* ::Subsection:: *)
(*Mass*)



(* ::Subsubsection::Closed:: *)
(*CDSourceMass*)



CDSourceMass[query_,___]:=
  If[ChemDataIsotopeQ@query,
    Quantity[
      ChemDataLookup[query,"AtomicNumber",IsotopeData]+
        ChemDataLookup[query,"NeutronNumber",IsotopeData],
      "AtomicMassUnit"
      ],
    ElementData[query,"AtomicMass"]
    ]


(* ::Subsubsection::Closed:: *)
(*Mass*)



chemDataSourceAdd[
  "Mass"->
    ChemData[
      chemDataCARouter[CDSourceMass, "Mass"],
      Missing["NoMass", #]&
      ]
  ]


(* ::Subsection:: *)
(*NISTMass*)



(* ::Subsubsection::Closed:: *)
(*CDNISTMass*)



CDNISTMass[query_,___]:=
  If[ChemDataIsotopeQ@query,
    With[{n=ChemDataLookup[query, "AtomicNumber", IsotopeData]},
      Quantity[
        $ChemIsotopicMasses[n, 
          ChemDataLookup[query, "MassNumber", IsotopeData],
          "Mass"
          ],
        "AtomicMassUnit"
        ]
      ],
    With[
      {
        n = 
          ChemDataLookup[query, "AtomicNumber", ElementData],
        m =
          Replace[
            Thread[
                {
                  ChemDataLookup[query, "MassNumber", IsotopeData],
                  ChemDataLookup[query, "IsotopeAbundance", IsotopeData]
                  }
                ],
            {
              l:{__List}:>
                MaximalBy[l, Last][[1, 1]]
              }
            ]
        },
      Replace[
        $ChemIsotopicMasses[n, m, "Mass"],
        {
          u_?NumericQ:>
            Quantity[u, "AtomicMassUnit"],
          _->$Failed
          }
        ]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*NISTMass*)



chemDataSourceAdd[
  "NISTMass"->
    ChemData[
      CDNISTMass,
      Missing["NoNISTMass", #]&
      ]
  ]


(* ::Subsection:: *)
(*AtomicNumber*)



(* ::Subsubsection::Closed:: *)
(*CDSAtomicNumber*)



CDSAtomicNumber[q_]:=
  ChemDataLookup[q,"AtomicNumber",IsotopeData]


(* ::Subsubsection::Closed:: *)
(*AtomicNumber*)



chemDataSourceAdd[
  "AtomicNumber"->
    ChemData[
      chemDataCARouter[CDSAtomicNumber, "AtomicNumber"],
      Missing["NoAtomicNumber", #]&
      ]
  ]


(* ::Subsection:: *)
(*Electronegativity*)



(* ::Subsubsection::Closed:: *)
(*CDElectronegativity*)



CDElectronegativity[query_,___]:=
  If[ChemDataIsotopeQ@query,
    ChemDataLookup[
      ChemDataLookup[query, "AtomicNumber", IsotopeData],
      "Electronegativity"
      ],
    ElementData[query, "Electronegativity"]
    ]


(* ::Subsubsection::Closed:: *)
(*Electronegativity*)



chemDataSourceAdd[
  "Electronegativity"->
    ChemData[
      chemDataCARouter[CDElectronegativity, "Electronegativity"],
      Missing["NoElectronegativity", #]&
      ]
  ]


(* ::Subsection:: *)
(*ChemDataSource*)



ChemDataSource[s_String]:=
  Which[
    s==="ElementData",
      ElementData,
    s==="ChemicalData",
      ChemicalData,
    s==="IsotopeData",
      IsotopeData,
    KeyMemberQ[$ChemCustomAtoms, s],
      "CustomAtoms",
    KeyMemberQ[$ChemDataSources,s],
      $ChemDataSources[s],
    KeyMemberQ[$ChemElements, s]||
      KeyMemberQ[$ChemElements, ToLowerCase@s],
      ElementData,
    StringStartsQ[s, "A"|"C"|"F"|"I"|"P"|"R"]&&
    StringEndsQ["1"|"2"|"3"|"4"|"5"|"6"|"a"|"c"|"d"|"m"|"n"]
    &&KeyMemberQ[$ChemSpaceGroups, s],
      "SpaceGroups",
    StringMatchQ[ToLowerCase@s,"d"|"t"|"deuterium"|"tritium"]||
      With[{t=StringTrim[s, NumberString]},
        KeyMemberQ[$ChemElements, t]||
          KeyMemberQ[$ChemElements, ToLowerCase@t]
        ],
      IsotopeData,
    True,
      ChemicalData
    ]


End[];



