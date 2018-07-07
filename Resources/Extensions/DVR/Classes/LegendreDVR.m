(* ::Package:: *)

(* Autogenerated Package *)

ChemDVRBegin[];


$LegendreDVR=
	<|
		"Name"->"Legendre 1D",
		"Dimension"->1,
		"PointLabels"->{("\[Theta]"|"theta"|"Theta"|"Azimuthal"|"azimuthal")},
		"Points"->{251},
		"Range"->{{0,\[Pi]}},
		"FormatGrid"->
			(MapAt[ArcCos, #, 1]&),
		"Defaults"->
			{
				"PlotMode"->
					"Ring",
				"GridType"->
					{"BasisSet", "Legendre", "GridRange"->{-1., 1.}},
				"KineticEnergyElementFunction"->
					{"BasisSet", "Legendre"},
				"PotentialFunction"->
					{"HinderedHalfRotor", "WellNumber"->3, "WellDepth"->.5},
				"HamiltonianRounding"->10^-9
				}
		|>


ChemDVREnd[];


$LegendreDVR



