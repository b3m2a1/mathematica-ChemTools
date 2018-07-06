(* ::Package:: *)

(* Autogenerated Package *)

ChemDVRBegin[];


DiskDVRK::usage="Returns the disk DVR kinetic energy matrix";


ChemDVRNeeds/@{"RadialDVR", "RingDVR"};


Begin["`Private`"];


(* ::Text:: *)
(*
	Need a rep for d/dr...
*)



Options[DiskDVRK]=
	{
		"HBar"->1,
		"Mass"->1,
		"ScalingFactor"->1
		};
DiskDVRK[grid_, ops:OptionsPattern[]]:=
	Module[
		{
			rgrid=grid[[All, 1, 1]],
			qgrid=grid[[1, All, 2]],
			rops=Replace[Flatten@{ops}, (k_->{r_, ___}):>(k->r), 1],
			qops=Replace[Flatten@{ops}, (k_->{_, q_, ___}):>(k->q), 1],
			rke,
			qke,
			ke
			},
		rke=ChemDVRDefaultKineticEnergy[rgrid, rops];
		qke=ChemDVRDefaultKineticEnergy[qgrid, rops];
		ke=KroneckerProduct[rke, IdentityMatrix[Length@qke, SparseArray]];
		ke+=KroneckerProduct[
		]


End[];


$DiskDVR=
	<|
		"Name"->"Disk 2D",
		"Range"->
			{{1, 10}, {0., 2.\[Pi]}},
		"Points"->
			{30, 30},
		"Defaults"->
			{
				"GridType"->
					{"RegularSubdivision", "AzimuthalSubdivision"},
				"KineticEnergyElementFunction"->
					{"ColbertMillerRadial", "MeyerAzimuthal"},
				"PotentialFunction"->
					{
						{"MorseOscillator", "EquilibriumBondLength"->3},
						Function[0]
						},
				"PlotMode"->"Polar"
				}
		|>


ChemDVREnd[];


$DiskDVR



