(* ::Package:: *)

(* Autogenerated Package *)

ChemDVRDefaultPotentialOptimize::usage=
  "Prepares a PO DVR";


Begin["`Private`"];


(* ::Subsection:: *)
(*ChemDVRDefaultPotentialOptimize*)



(* ::Text:: *)
(*
	Iterate over the grids, optimizing each degree of freedom
	Return the transformed versions of:
		\[FilledSmallCircle] the grids
		\[FilledSmallCircle] the potentials
		\[FilledSmallCircle] the kinetic energies
		\[FilledSmallCircle] the Hamiltonians
	Let the returned elements be requested explicitly so as to minimize the overhead in this
	Also should support optimization of 1D grid from the wavefunctions
*)



(* ::Subsubsection::Closed:: *)
(*iChemDVRGetPOGrids*)



iChemDVRGetPOGrids//Clear
iChemDVRGetPOGrids[grid_, ops:OptionsPattern[]]:=
  Module[{dim, subgrids},
    dim=
      If[CoordinateGridObjectQ@grid, 
        Append[Dimensions[grid], GridDimension[grid]],
        grid
        ];
    subgrids=
      Replace[
        If[CoordinateGridObjectQ@grid,
          grid["Points"],
          ChemDVRDefaultGridPointList[
            grid, 
            FilterRules[{ops}, Options[ChemDVRDefaultGridPointList]]
            ]
          ],
        {
          l:{{Repeated[_?NumericQ, {dim[[-1]]}]}, ___List}:>
            Map[
              DeleteDuplicates@l[[All, #]]&,
              Range[dim[[-1]]]
              ],
          l_List:>{l}
          }
        ];
    If[!MatchQ[subgrids, {Repeated[_?NumericQ, {#}]}&/@Most@dim],
      PackageRaiseException[
        Automatic,
        "Potential optimizer couldn't decompose grid.\
 Found subgrids of dimension ``. Expected subgrids of dimension ``.",
        Length/@subgrids,
        Most@dim
        ]
      ];
    subgrids
    ]


(* ::Subsubsection::Closed:: *)
(*iChemDVRDefault1DPOGrid*)



iChemDVRDefault1DPOGrid//Clear


iChemDVRDefault1DPOGrid[
  grid_,
  wfs:{{_?NumericQ, ___}, {_List, ___}},
  bs_
  ]:=
  Module[
    {
      xmat,
      gps,
      gporder,
      chob
      },
    xmat=
      ChemDVRDefaultOperatorMatrix[
        grid,
        wfs,
        {#&},
        {{1, 1}, {0, 0}}(* This is just a dud potential we feed in because it won't be used *),
        "WavefunctionSelection"->bs
        ];
    If[!SquareMatrixQ[xmat],
      xmat=xmat[[1]]
      ];
    {gps, chob}=Eigensystem[xmat];
    gporder=Ordering[gps];
    gps=gps[[gporder]];
    chob=chob[[gporder]];
    {gps, chob, wfs[[2]], wfs[[1, Replace[bs, i_Integer:>;;i]]]}
    ];
iChemDVRDefault1DPOGrid[
  grid_,
  ke_,
  pe_,
  bs_
  ]:=
  iChemDVRDefault1DPOGrid[
    grid,
    ChemDVRDefaultWavefunctions[
      ke, 
      pe, 
      "NumberOfWavefunctions"->All
      ],
    bs
    ]


(* ::Subsubsection::Closed:: *)
(*iChemDVRGetValidPOKeys*)



(* ::Subsubsubsection::Closed:: *)
(*Keys*)



$iChemDVRPOKeys=
  {
    "Grid",
    "Coordinates",
    "Ordering",
    "Transformation",
    "KineticEnergy",
    "PotentialEnergy",
    "Hamiltonian",
    "Wavefunctions"
    };


(* ::Subsubsubsection::Closed:: *)
(*GetValidPOKeys*)



iChemDVRGetValidPOKeys[spec_]:=
  Module[
    {
      poKeys=$iChemDVRPOKeys,
      optSpec=spec
      },
    optSpec=
      Replace[optSpec,
        {
          Automatic->{"Grid", "PotentialEnergy", "KineticEnergy"},
          All->poKeys
          }
        ];
    Replace[
      Cases[Flatten@List@optSpec,
        Except[(Alternatives@@poKeys)]
        ],
      l:{__}:>
        PackageThrowMessage[
          "pokey",
          "`` is not a valid spec for potential optimization. Valid ones are ``",
          l,
          poKeys
          ]
      ];
    optSpec=
      If[MemberQ[poKeys, optSpec],
        optSpec,
        Cases[Flatten@List@optSpec,
          Alternatives@@poKeys
          ]
        ];
    If[!MemberQ[poKeys, optSpec]&&Length@optSpec==0,
      PackageRaiseException[
        Automatic,
        "No valid specs for potential optimization requested."
        ]
      ];
    optSpec
    ]


(* ::Subsubsection::Closed:: *)
(*iChemDVRGetPOKineticEnergy*)



iChemDVRGetPOKineticEnergy[subgrids_, fullDim_, ops:OptionsPattern[]]:=
  Module[
    {
      keels,
      kins
      },
    keels=
      ChemDVRDefaultKineticEnergyElementFunction@
        FilterRules[
          {ops},
          Options@ChemDVRDefaultKineticEnergyElementFunction
          ];
    If[Length@keels!=fullDim,
      keels=
        Take[Flatten[ConstantArray[keels, fullDim], 1], fullDim]
      ];
    ChemDVRDefaultKineticEnergyLists[
      subgrids,
      keels,
      FilterRules[{ops}, Options@ChemDVRDefaultKineticEnergyLists]
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*iChemDVRGetPOPotentialEnergy*)



iChemDVRGetPOPotentialEnergy//Clear


iChemDVRGetPOPotentialEnergy[pf_, subgrids_, fullDim_, ops:OptionsPattern[]]:=
  Module[
    {
      potFuns,
      p
      },
    potFuns=
      Map[
        If[#=!=None,
          ChemDVRDefaultPotentialEnergyElementFunction["PotentialFunction"->#],
          #
          ]&,
        Take[
          Flatten[
            ConstantArray[
              Replace[
                pf,
                {
                  a:{_String, ___?OptionQ}:>
                    ConstantArray[a, fullDim],
                  a:Except[_List]:>
                    ConstantArray[a, fullDim]
                  }
                ],
              fullDim
              ],
            1
            ],
          UpTo[fullDim]
          ]
        ];
    If[Length@potFuns!=fullDim,
      potFuns=
        Take[
          Flatten[ConstantArray[potFuns, fullDim], 1], 
          fullDim
          ]
      ];
    MapThread[
      If[#2=!=None,
        iChemDVRPotentialEnergy[##],
        None
        ]&,
      {
        subgrids,
        potFuns
        }
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*iChemDVRGetPOBasisSize*)



iChemDVRGetPOBasisSize[grids_, fullDim_, coordSpec_, optSize_]:=
  Module[
    {
      size
      },
    size=
      Flatten[
        ConstantArray[optSize, fullDim],
        1
        ][[coordSpec]];
    MapThread[
      Replace[#,
        {
          i_Integer?Positive:>i,
          Scaled[i_?(0<#<1&)]:>
            Ceiling[Rescale[i, {0, 1}, {1, Length@#2}]],
          Span[bits___]:>
            Apply[
              Span,
              Replace[{bits}, 
                Scaled[i_]:>
                  Ceiling[Rescale[i, {0, 1}, {1, Length@#2}]],
                1
                ]
              ],
          Except[{__Integer?Positive}]->All
          }
        ]&,
      {
        size,
        grids
        }
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultPotentialOptimize*)



Options[ChemDVRDefaultPotentialOptimize]=
  DeleteDuplicatesBy[First]@
    Join[
      Options[ChemDVRDefaultKineticEnergy],
      Options[ChemDVRDefaultPotentialEnergy],
      {
        "OptimizedComponents"->Automatic,
        "OptimizedCoordinates"->All,
        "OptimizedBasisSize"->Scaled[.25]
        }
      ];
ChemDVRDefaultPotentialOptimize[
  grid_,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      subgrids,
      coordSpec,
      grids,
      fullDim,
      coordDim,
      curCrds,
      loCrds,
      orderCrds,
      kins,
      loKe,
      pots,
      loPe,
      size,
      newGrid,
      engs,
      wfs,
      invwfs,
      trans,
      invs,
      optSpec,
      optParts=<||>
      },
    optSpec=iChemDVRGetValidPOKeys@OptionValue["OptimizedComponents"];
    (** ----------------------------------- GRIDS ----------------------------------- **)
    subgrids=iChemDVRGetPOGrids[grid, ops];
    fullDim=Length@subgrids;
    (** -------------------------------- COORDINATES ------------------------------- **)
    (* Get coordinates for optimization / order them *)
    coordSpec=OptionValue["OptimizedCoordinates"];
    curCrds=Range[fullDim][[coordSpec]];
    (** ----------------------------------- GRIDS ----------------------------------- **)
    grids=subgrids[[coordSpec]];
    coordDim=Length@grids;
    (** -------------------------------- COORDINATES ------------------------------- **)
    loCrds=
      If[Length@grids<fullDim,
        Complement[Range[coordDim], curCrds],
        {}
        ];
    orderCrds=Ordering[Join[loCrds, curCrds]];
    (** ------------------------------ KINETIC ENERGY------------------------------ **)
    kins=iChemDVRGetPOKineticEnergy[subgrids, fullDim, ops];
    If[!MatchQ[kins, {__?SquareMatrixQ}],
      PackageRaiseException@
        "Couldn't generate kinetic energy matrices for potential optimization"
      ];
    loKe=kins[[loCrds]];
    kins=kins[[curCrds]];
    (** ----------------------------- POTENTIAL ENERGY----------------------------- **)
    pots=
    iChemDVRGetPOPotentialEnergy[
      OptionValue["PotentialFunction"],
      subgrids, 
      fullDim, 
      ops
      ];
    If[!MatchQ[kins, {__?SquareMatrixQ}],
      PackageRaiseException@
        "Couldn't generate potential energy matrices for potential optimization"
      ];
    loPe=pots[[loCrds]];
    pots=pots[[curCrds]];
    (** -------------------------------- BASIS SIZE -------------------------------- **)
    size=
      iChemDVRGetPOBasisSize[
        grids, fullDim, 
        coordSpec, OptionValue["OptimizedBasisSize"]
        ];
    (** ---------------------------- TRANSFORMED SYSTEM ---------------------------- **)
    trans=
      MapThread[
        Replace[
          Except[
            {
              _List?VectorQ, 
              _List?SquareMatrixQ, 
              _List?SquareMatrixQ,
              _
              }]:>
            PackageRaiseException[
              Automatic,
              "Couldn't generate potential optimization of coordinate ``",
              #
              ]
          ]@iChemDVRDefault1DPOGrid[##2]&,
        {
          curCrds,
          grids,
          kins,
          pots,
          size
          }
        ];
    {newGrid, trans, wfs, engs}=Transpose@trans;
    invwfs=Transpose/@wfs;
    invs=Transpose/@trans;
    (** ------------------------------ CREATE OUTPUT ------------------------------ **)
    size=Replace[size, i_Integer:>;;i, 1];
    Do[
      If[MemberQ[
          {
            "Ordering", "Coordinates",
            "Grid", "Transformation", 
            "KineticEnergy", "PotentialEnergy",
            "Hamiltonian"
            }, 
          bit
          ],
        optParts[bit]=
          Switch[bit,
            "Grid",
              If[Length@loCrds>0,
                Join[subgrids[[loCrds]], newGrid],
                newGrid
                ][[orderCrds]],
            "Transformation",
              If[Length@loCrds>0,
                Join[Map[IdentityMatrix[#, SparseArray]&, Length/@grids], trans],
                trans
                ][[orderCrds]],
            "KineticEnergy",
              Join[
                loKe,
                MapThread[
                  With[{pretrans=(#5.#.#6)[[#4, #4]]},
                    (*(Length[#]/Length[pretrans])**)(#2.pretrans.#3)
                    ]&,
                  {
                    kins,
                    trans,
                    invs,
                    size,
                    wfs,
                    invwfs
                    }
                  ]
                ][[orderCrds]],
            "PotentialEnergy",
              MapThread[
                With[{pretrans=(#5.#.#6)[[#4, #4]]},
                  (*(Length[#]/Length[pretrans])**)(#2.pretrans.#3)
                  ]&,
                {
                  pots,
                  trans,
                  invs,
                  size,
                  wfs,
                  invwfs
                  }
                ],
            "Hamiltonian",
              MapThread[
                With[{preshrink=#[[#4, #4]]},
                  (*(Length[#]/Length[preshrink])**)(#2.preshrink.#3)
                  ]&,
                {
                  SparseArray[Band[{1, 1}]->#]&/@engs,
                  trans,
                  invs,
                  size
                  }
                ]
            ]
          ],
      {bit, DeleteDuplicates@Flatten@List@optSpec}
      ];
    If[!ListQ@optSpec&&KeyExistsQ[optParts, optSpec],
      optParts[[optSpec]],
      optParts
      ]
    ]


End[];



