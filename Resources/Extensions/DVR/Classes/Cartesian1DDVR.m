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



ChemDVRBegin[];


$Cartesian1DDVR::usage=
	"A one dimensional DVR by Colbert and Miller for the (-\[Infinity],\[Infinity]) range"


$Cartesian1DDVR=
	<|
		"Name"->"Cartesian 1D",
		"Range"->{{-10,10}},
		"Points"->{101},
		"Defaults"->
			{
				"GridType"->
					"RegularSubdivision",
				"KineticEnergyElementFunction"->
					"ColbertMillerCartesian",
				"PotentialFunction"->
					"HarmonicOscillator",
				"PlotMode"->
					{"Cartesian", 1}
				}
		|>


ChemDVREnd[];


$Cartesian1DDVR



