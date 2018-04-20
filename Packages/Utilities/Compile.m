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



ChemEvaluate::usage=
	"An evaluation tag for ChemCompile";
ChemCompile::usage=
	"Compiles a function replacing the ChemTools` scope";
$ChemCompilePoint::usage=
	"The point used in ChemPointCompile";
$ChemCompileObject::usage=
	"The object using in ChemPointCompile";
ChemPointCompile::usage=
	"Compiles a function using a coordinate as the default argument";


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*Evaluate*)



ChemEvaluate[expr_]:=
	Evaluate[expr];


(* ::Subsubsection::Closed:: *)
(*Compile*)



ChemCompile[spec:{{_,_Blank,___}...},
	code_,
	ops___
	]:=
	With[{expr=
		Hold[code]/.{
			HoldPattern@Map[
				s:(_Symbol?ChemToolsSym)|(_Symbol?ChemToolsSym[___]),
				a__]:>
				RuleCondition[Map[s,a],
					True
					],
			s_Symbol?ChemToolsSym[
				args___
				]:>
				RuleCondition[
					s[args],
					True
					],
			s_Symbol?ChemToolsSym[
				op___
				][args___]:>
				RuleCondition[
					s[op][args],
					True
					]
			}//.{
				c:ChemObject[_,_]?ChemObjectQ:>
					RuleCondition[
						Replace[ChemAssociation[c],
							Except[_Association]:><||>
							],
						True],
				s:(_Symbol?ChemSymObjectQ):>
					RuleCondition[
						Replace[ChemAssociation[c],
							Except[_Association]:><||>
							],
						True]
				}
			},
			Replace[expr,
				Hold@e_:>
					Compile[spec,e,ops]
				]
		];
ChemCompile~SetAttributes~HoldAll;


(* ::Subsubsection::Closed:: *)
(*PointCompile*)



ChemPointCompile[
	expr_?(Function[Null,FreeQ[Hold[#],$ChemCompileObject],HoldFirst]),
	ops___]:=
	ChemCompile[
		{{$ChemCompilePoint,_Real,1}},
		expr,
		ops
		];
HoldPattern[ChemPointCompile[expr_,ops___][obj_]]:=
	Replace[Hold[expr]/.($ChemCompileObject->obj),
		Hold[e_]:>
			ChemPointCompile[e,ops]
		];
ChemPointCompile~SetAttributes~HoldFirst;


End[];



