(* ::Package:: *)

<|
	"JoulesToWavenumbersUnits":>
		Quantity[1, "Joules"/("PlanckConstant"*"SpeedOfLight")],
	"JoulesToWavenumbers":>
		UnitConvert[
			Quantity[1, "Joules"/("PlanckConstant"*"SpeedOfLight")],
			"Wavenumbers"
			],
	"MegahertzToWavenumbersUnits":>
		Quantity[1, "Megahertz"/"SpeedOfLight"],
	"MegahertzToWavenumbers":>
		UnitConvert[
			Quantity[1, "Megahertz"/"SpeedOfLight"],
			"Wavenumbers"
			],
	"JoulesToMegahertz":>
		UnitConvert[
			Quantity[1, "Joules"/"PlanckConstant"],
			"Megahertz"
			],
	"InertialConstant":>
		UnitConvert[
			Quantity[1/(8\[Pi]^2),
				"PlanckConstant"/
				("AtomicMassUnit"*"Angstroms"^2)],
			"Megahertz"
			]
		|>
