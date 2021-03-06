(* ::Package:: *)

(* Autogenerated Package *)

(* ::Section:: *)
(*Interacting Particle MCMC*)



(* ::Text:: *)
(*
	An MCMC that will propagate with interactions
*)



$IPWalkerMCMC::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*Propagator*)



(* ::Subsubsection::Closed:: *)
(*IPWalkerPropC*)



(* ::Text:: *)
(*
	Compiled propagator to be used by the MCMC
*)



SetAttributes[compileHold, HoldAllComplete]
SetAttributes[moduleHold, HoldAllComplete]


IPWalkerPropC[pot_, dists_, prob_]:=
	With[
		{
			distMap=
				Quiet@
					MapThread[
						RandomVariate[
							#, 
							{#2, walkerDim}
							]&, 
						Transpose@dists
						]
			},
		Compile@@
			ReplaceAll[
				compileHold[
					{
						{initCoords, _Real, 2},
						{tInit, _Real},  
						{dt, _Real},
						{tSteps, _Integer},
						{storeTraj, _Integer}
						},
					moduleHold[
						{
							totalCoords,
							realTraj,
							storedSteps,
							storedStepPointer=1,
							coordVec=initCoords,
							walkerDim=Dimensions[initCoords][[2]],
							walkerNum=Length@initCoords,
							proposedSteps,
							coordVec1,
							peVec,
							potEl,
							peVec1,
							condProbs,
							totT=tInit,
							totE
							},
						realTraj=Min@{Max@{storeTraj, 1}, tSteps};
						storedSteps=
							Table[
								Ceiling[tSteps*i/realTraj], 
								{i, Min@{Max@{realTraj, 1}, tSteps}}
								];
						totalCoords=Table[initCoords, {i, realTraj}];
						Do[
							peVec=
								Table[
									potEl=0;
									Do[
										potEl+=pot[coordVec[[i]], coordVec[[j]], totT],
										{j, walkerNum}
										];
									potEl,
									{i, walkerNum}
									];
							proposedSteps=Flatten[distMap, 1];
							coordVec1=coordVec+proposedSteps;
							condProbs=RandomReal[{0, 1}, Length@coordVec];
							Do[
								potEl=0;
								Do[
									If[i!=j,
										potEl+=pot[coordVec[[i]], coordVec[[j]], totT]
										],
									{j, walkerNum}
									];
								If[condProbs[[i]]<(prob[potEl, totT]/prob[peVec[[i]], totT]),
									coordVec[[i]]=potEl
									],
								{i, walkerNum}
								];
							totT+=dt;
							If[n==storedSteps[[storedStepPointer]],
								totalCoords[[storedStepPointer]]=coordVec;
								storedStepPointer++
								];,
							{n, tSteps}
							];
						totalCoords
						],
					CompilationOptions->
						{
							"InlineExternalDefinitions"->True
							},
					RuntimeOptions->
						{
							"CatchMachineOverflow"->False,
							"CatchMachineIntegerOverflow"->False,
							"CompareWithTolerance"->False,
							"EvaluateSymbolically"->False,
							"WarningMessages"->False
							},
					CompilationTarget->"C",
					Parallelization->True
					],
			moduleHold->Module
			]
		]


(* ::Subsubsection::Closed:: *)
(*IPWalkerPropFunc*)



IPWalkerPropFunc[obj_]:=
	Module[
		{
			pot=obj["InteractionFunction"],
			distGen=obj["DistributionGenerator"],
			prob=obj["ProbabilityFunction"],
			walkers=obj["Walkers"],
			masses=Replace[obj["StandardDeviations"], Except[_?NumericQ|{__?NumericQ}]:>1],
			dists
			},
		dists=
			distGen[
				walkers, 
				Take[
					Flatten[ConstantArray[masses, Length@walkers], 1],
					Length@walkers
					]
				];
		IPWalkerPropC[
			pot, 
			Map[{#[[1]], Length@#}&, SplitBy[dists, Identity]], 
			prob
			]
		]


(* ::Subsection:: *)
(*Defaults*)



(* ::Subsubsection::Closed:: *)
(*DistGen*)



IPWalkerDistGen[walkers_, devs_]:=
		Thread@NormalDistribution[0, devs];


(* ::Subsubsection::Closed:: *)
(*ProbFunc*)



IPWalkerProbFunc=
	Exp[-#]&


(* ::Subsubsection::Closed:: *)
(*WalkerValidate*)



IPWalkerWalkerValidate[walks_]:=
	MatchQ[walks, {{__?NumericQ}, ___List}]


(* ::Subsubsection::Closed:: *)
(*Plot*)



(* ::Subsubsubsection::Closed:: *)
(*readjustPointPlot*)



readjustPointPlot[plot_]:=
ReplacePart[plot,
	1->
		With[
			{
				pts=
				Cases[
					plot[[1]],
					 {d___, Point[p_], ___}:>{Flatten[Directive[d],1,  Directive], p[[1]]}, 
					Infinity
					]
				},
			{
				pts[[1, 1]],
				Point[pts[[All, -1]], 
					VertexColors->pts[[All, 1]]]
				}
			]
	]


(* ::Subsubsubsection::Closed:: *)
(*plotCostFunction*)



plotCostFunction//Clear


plotCostFunction[dim_, cbs_, cf_, t_, ops:OptionsPattern[]]:=
	Switch[dim,
		1,
			Plot[cf[{x}, t], {x, cbs[[1, 1]], cbs[[1, 2]]}, 
				Evaluate@FilterRules[
					Flatten@{
						Lookup[{ops}, "CostFunctionStyle", {}],
						PlotStyle->Directive[Dashed, Gray],
						ops
						},
					Options@Plot
					]
				],
		2,
			ContourPlot[
				cf[{x, y}, t], 
				{x, cbs[[1, 1]], cbs[[1, 2]]}, 
				{y, cbs[[2, 1]], cbs[[2, 2]]},
				Evaluate@
					FilterRules[
						Flatten@{
							Lookup[{ops}, "CostFunctionStyle", {}],
							ColorFunction->
								With[{cd=ColorData["M10DefaultGradient"]},
									Directive[Opacity[.25], cd[#]]&
									],
							ops
							},
						Options@ContourPlot
						]
				],
		3,
			ContourPlot3D[
				cf[{x, y, z}, t], 
				{x, cbs[[1, 1]], cbs[[1, 2]]}, 
				{y, cbs[[2, 1]], cbs[[2, 2]]},
				{z, cbs[[2, 1]], cbs[[2, 2]]},
				Evaluate[
					FilterRules[
						Flatten@{
							Lookup[{ops}, "CostFunctionStyle", {}],
							ColorFunction->
								With[{cd=ColorData["M10DefaultGradient"]},
									Directive[Opacity[.25], cd[#]]&
									],
							ops
							},
						Options@ContourPlot3D
						]
					]
				],
		_,
			$Failed
		]


(* ::Subsubsubsection::Closed:: *)
(*plotState*)



IPWalkerPlotState//Clear


IPWalkerPlotState[walkers_, cbs_, t_, obj_, ops:OptionsPattern[]]:=
	With[{dim=Length@walkers[[1]](*, cf=obj["CostFunction"]*)},
		Show[(*
			plotCostFunction[dim, cbs, cf, t, ops],*)
			Switch[dim,
				1,
				readjustPointPlot@
					ListPlot[
						{{#[[1]], 1}}&/@walkers, 
						FilterRules[
							{
								ops,
								PlotRange->{1.01*cbs[[1]], {.8, 1.2}},
								Frame->True,
								Axes->False
								},
							Options@ListPlot
							]
						],
				2,
				readjustPointPlot@
					ListPlot[
						List/@walkers, 
						FilterRules[
							{
								ops,
								PlotRange->1.01*cbs,
								Frame->True,
								Axes->False
								},
							Options@ListPlot
							]
						],
				3,
					ListPointPlot3D[
						List/@walkers, 
						FilterRules[
							{
								ops,
								PlotRange->1.01*cbs
								},
							Options@ListPointPlot3D
							]
						],
				_,
					Throw[$Failed]
				]
			]
		]


(* ::Subsection:: *)
(*Specification*)



$IPWalkerMCMC=
	<|
		"RequiredProperties"->
			{
				"InteractionFunction",
				"DistributionGenerator",
				"ProbabilityFunction"
				},
		"PropagatorGenerator"->
			IPWalkerPropFunc,
		"WalkerValidationFunction"->
			IPWalkerWalkerValidate,
		"ProbabilityFunction"->
			IPWalkerProbFunc,
		"DistributionGenerator"->
			IPWalkerDistGen
		|>


End[];


$IPWalkerMCMC



