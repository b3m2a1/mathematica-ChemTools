(* ::Package:: *)

(* ::Section:: *)
(*SymbolObjects*)


(* ::Subsection:: *)
(*Declarations*)


SObj::usage="SObj[name, templates, a] builds a new SObj
SObj[s][props...] gets properties
";


(* ::Subsection:: *)
(*Implementation*)


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*Object constructor*)


SObj//Clear


(*
	SObj[_]:
		construct a new SObj
*)
SObj[
	name : _String | Automatic : Automatic,
	templates : {___String} : {},
	a : _Association : <||>
	] :=
	SObjNew[name, templates, a];
o:SObj[s_Symbol]/;(
	System`Private`EntryQ[Unevaluated@o]&&
		SObjSymbolQ[s]
	):=
	(System`Private`SetNoEntry[Unevaluated@o];o)


(* ::Subsubsection::Closed:: *)
(*Property access*)


(*
	SObj[_][___]:
		access properties
*)
(o : SObj[s_Symbol]?SObjQ)[
	i__
	] :=
	(SObjAccess[o, i]);
SObj/:Lookup[SObj[s_Symbol]?SObjQ, i__] :=
	(SObjLookup[s, i]);
SObj/:Part[o:SObj[s_], p___]:=
	(SObjPart[o, p]/;SObjQ@o);
SObj/:Extract[o:SObj[s_], e___]:=
	(SObjExtract[o, e]/;SObjQ@o);


(* ::Subsubsection::Closed:: *)
(*Property setting*)


(* ::Text:: *)
(*Note all MutationHandler definitions are in other package*)


SObj /: Set[o_SObj?SObjQ[prop_], newvalue_] :=
	SObjSet[o, prop, newvalue];
SObj /: SetDelayed[o_SObj?SObjQ[prop_], newvalue_] :=
	SObjSetDelayed[o, prop, newvalue];
SObj /: Unset[o_SObj?SObjQ[prop_]] :=
	SObjUnset[o, prop];


Language`SetMutationHandler[SObj, SObjMutationHandler];


(* ::Subsubsection::Closed:: *)
(*UpValues interface*)


(*
	Various UpValues
*)
SObj /: Keys[o_SObj?SObjQ] := SObjKeys@o;
SObj /: Values[o_SObj?SObjQ] := SObjValues@o;
SObj /: Normal[o_SObj?SObjQ] := SObjSymbol@o;
SObj /: Dataset[o_SObj?SObjQ] := SObjSymbol[o, Dataset];


(* ::Subsubsubsection:: *)
(*Single Argument No New Obj*)


Map[
	Function[
		SObj /: #[o_SObj?SObjQ] :=
			Block[{$SObjGetNew=False}, SObjAccessWrapper[o, #]];
		],
	{
		First, Last, Length
		}
	];


(* ::Subsubsubsection:: *)
(*Multi Argument No New Obj*)


Map[
	Function[
		SObj /: #[o_SObj?SObjQ, a__] :=
			Block[{$SObjGetNew=False}, SObjAccessWrapper[o, #, a]];
		],
	{
		KeyExistsQ, KeyMemberQ, KeyFreeQ
		}
	];


(* ::Subsubsubsection:: *)
(*Single Argument New Obj*)


Map[
	Function[
		SObj /: #[o_SObj?SObjQ] :=
			Block[{$SObjGetNew=$SObjGetNew=!=False},
				SObjAccessWrapper[o, #]
				];
		],
	{
		Most, Rest
		}
	];


(* ::Subsubsubsection:: *)
(*New  Accessors*)


Map[
	Function[
		SObj /: #[o_SObj?SObjQ, a__] :=
			Block[{$SObjGetNew=$SObjGetNew=!=False},
				SObjAccessWrapper[o, #, a]
				];
		],
	{
		Take, Drop, Delete, 
		Insert, Append, Prepend,
		Select, Cases, Pick, DeleteCases,
		KeyTake, KeySelect, KeyDrop,
		KeyValueMap, KeyMap,
		KeyComplement, KeyIntersection, KeyUnion
		}
	];


(* ::Subsubsection::Closed:: *)
(*Format*)


(* 
	Format
*)


Format[o_SObj?SObjQ, StandardForm] :=
 SObjFormat[o] /; TrueQ@$SObjFormat


(* ::Subsubsection::Closed:: *)
(*Attributes*)


(* 
	Handle the necessary HoldFirst
*)
SObj~SetAttributes~HoldFirst


(* ::Subsection:: *)
(*End*)


End[];
