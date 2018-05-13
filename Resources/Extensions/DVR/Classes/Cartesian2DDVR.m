(* ::Package:: *)



ChemDVRBegin[];


$Cartesian2DDVR::usage=
	"A two dimensional DVR based on a Colbert and Miller 1D direct product"


$Cartesian2DDVR=
	<|
		"Name"->"Cartesian 2D",
		"Range"->{{-10,10}, {-10, 10}},
		"Points"->{11, 11},
		"Defaults"->
			{
				"GridType"->
					"RegularSubdivision",
				"KineticEnergyElementFunction"->
					{"ColbertMillerCartesian", 2},
				"PotentialFunction"->
					{"HarmonicOscillator", 2},
				"PlotMode"->
					{"Cartesian", 2}
				}
		|>


ChemDVREnd[];


$Cartesian2DDVR



