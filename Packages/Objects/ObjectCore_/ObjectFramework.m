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



(* ::Subsection:: *)
(*Useful Tests*)



(* ::Subsubsection::Closed:: *)
(*ObjectQ*)



ChemObjectQ[ChemObject[s_String]]:=
	KeyMemberQ[$ChemicalSystems,s];
ChemObjectQ[ChemObject[s_String,i_String]]:=
	KeyMemberQ[$ChemicalSystems,s]&&
		KeyMemberQ[$ChemicalSystems[s],i];
ChemObjectQ[obs:{__ChemObject}]:=
	ChemObjectQ/@obs;
ChemObjectQ[_]:=
	False;


(* ::Subsubsection::Closed:: *)
(*SymObjectQ*)



ChemSymObjectQ[s_]:=
	MatchQ[OwnValues[s],{_:>_ChemObject?ChemObjectQ,___}];
ChemSymObjectQ~SetAttributes~HoldAllComplete;


(* ::Subsubsection::Closed:: *)
(*ChemToolsSym*)



With[{cont=StringJoin@Take[StringSplit[$Context,"`"->"`"],2]},
	ChemToolsSym[s_Symbol]:=
		Context[s]===cont;
	];
ChemToolsSym~SetAttributes~HoldAllComplete;
ChemToolsSym[e:Except[_Symbol]?(MatchQ[_Symbol])]:=
	With[{s=Evaluate@e},
		ChemToolsSym[s]
		];


(* ::Subsection:: *)
(*Systems*)



(* ::Subsubsection::Closed:: *)
(*Create*)



If[MatchQ[$ChemicalSystems,_Symbol],$ChemicalSystems=<||>];


CreateChemicalSystem[
	key:_String|Automatic:Automatic,
	props:_Association:<||>,
	makeUUID:True|False:True]:=
	With[{uuid=
		If[makeUUID,
			CreateUUID@Replace[key,Automatic->"System-"],
			Replace[key,Automatic:>CreateUUID["System-"]]
			]},
		$ChemicalSystems[uuid]=
			Join[props,
				<|
					
					"ObjectType"->"System",
					"ObjectKey"->uuid,
					"NewID"->1,
					"View"->Function[self,HoldForm[self]]
					|>
				];
		ChemObject[uuid]
		];


CreateChemicalSystem[
	keys:{(_String|Automatic)..}|Automatic:Automatic,
	props:{__Association}:{<||>}]:=
	With[{uuids=
		CreateUUID/@
			Replace[
				Replace[keys,Automatic:>ConstantArray[Automatic,Length@props]],
				Automatic->"System-",
				1]},
		AssociateTo[
			$ChemicalSystems,
			MapThread[
				#->Join[#2,
					<|
						"ObjectType"->"System",
						"ObjectKey"->#,
						"NewID"->1,
						"View"->Function[self,HoldForm[self]]
						|>
					]&,
				{
					keys,
					Take[Flatten@ConstantArray[props,Length@keys],Length@keys]
					}
				]
			];
		ChemObject/@uuids
		];


$ChemDefaultSystem=
	CreateChemicalSystem["System-default-"];


(* ::Subsubsection::Closed:: *)
(*Add*)



(* ::Subsubsubsection::Closed:: *)
(*MultiAddition*)



ChemAdd[
	sys:ChemSysPattern,
	type:_String|{__String},
	params:({__?OptionQ}..)
	]:=
		With[{
			system=
				First@sys,
			props=
				With[{
					properties=
						MapThread[
							Join[
								<|"ObjectType"->#2,"ObjectReferences"->{}|>,
								Lookup[$ChemObjectDefaults, "Common" ,<||>],
								Lookup[$ChemObjectDefaults, #2 ,<||>],
								Association@Flatten@{#}
								]&,
							{
								{params},
								Flatten@
									Take[ConstantArray[{type},Length@{params}],Length@{params}]
								}
							]
					},
					Table[assoc/.Key[p_]:>RuleCondition[assoc[p],True],
						{assoc,properties}
						]
					]
				},
			With[{obs=
				Prepend[#,
					"ObjectKey"->
						CreateUUID[
							TemplateApply["`type`-`id`-",
								<|
									"type"->#ObjectType,
									"id"->($ChemicalSystems[system]["NewID"]++)
									|>]
							]
					]&/@props},
				AssociateTo[
					$ChemicalSystems[system], 
					Map[#ObjectKey->#&,obs]
					];
				If[Length@#==1,
					First@#,
					#]&[
					ChemObject[system,#ObjectKey]&/@obs
					]
				]
			];


(* ::Subsubsubsection::Closed:: *)
(*Single Addition*)



ChemAdd[
	sys:ChemSysPattern,
	type_String,
	params__?OptionQ
	]:=
	ChemAdd[sys,{type},{params}];


(* ::Subsubsubsection::Closed:: *)
(*Copy Addition*)



ChemAdd[
	sys:ChemSysPattern,
	type_String,
	n_Integer
	]:=
	ChemAdd[sys,type,Sequence@@ConstantArray[{},n]];


(* ::Subsubsection::Closed:: *)
(*Remove*)



ChemRemove[s:ChemSysPattern]:=
	KeyDropFrom[$ChemicalSystems,First@s];
ChemRemove[s:ChemSysVectorPattern]:=
	KeyDropFrom[$ChemicalSystems,First/@s];


ChemRemove[s:ChemObjPattern]:=
	With[{system=First@s},
		KeyDropFrom[$ChemicalSystems[system],Last@s]
		];
ChemRemove[s:ChemObjVectorPattern]:=
	With[{objSets=GroupBy[s,First]},
		KeyValueMap[
			KeyDropFrom[$ChemicalSystems[#],Last/@#2]&,
			objSets
			]
		];


(* ::Subsubsection::Closed:: *)
(*Copy*)



ChemCopy[obj:ChemObjPattern,
	replacements:_List|_Rule|_Association:{},
	n:_Integer?Positive:1]:=
	With[{system=First@obj,id=Last@obj},
		With[{uuids=
			Table[
				CreateUUID@
					TemplateApply["`type`-`id`-",<|
						"type"->ChemGet[system,id,"ObjectType"],
						"id"->($ChemicalSystems[system]["NewID"]++)
						|>],
					n
					]},
			AssociateTo[
				$ChemicalSystems[system],
				Map[
					With[{a=$ChemicalSystems[system][id]/.replacements},
						#->ReplacePart[a,
							"ObjectKey"->#
							]&
						],
					uuids
					]
				];
			If[n==1,
				First,
				Identity
				]@
				Map[ChemObject[system,#]&,uuids]
			]
		];


ChemCopy[objV:ChemObjVectorPattern,
	replacements:_List|_Rule|_Association:{}]:=
	With[{systemGroups=GroupBy[objV,First]},
		KeyValueMap[
			With[{system=#,types=ChemGet[#2,"ObjectType"]},
				With[{uuids=
					Table[
						CreateUUID@
							TemplateApply["`type`-`id`-",<|
								"type"->t,
								"id"->($ChemicalSystems[system]["NewID"]++)
								|>],
						{t,types}
						]
					},
					AssociateTo[
						$ChemicalSystems[system],
						MapThread[
							With[{a=$ChemicalSystems[system][#2]/.replacements},
								#->
									ReplacePart[a,
										"ObjectKey"->#
										]
								]&,
							{
								uuids,
								Last/@#2
								}
							]
						];
					ChemObject[system,#]&/@uuids
					]
				]&,
			systemGroups
			]//Flatten
		]


(* ::Subsubsection::Closed:: *)
(*DeepCopy*)



ChemDeepCopy[obj:ChemObjPattern]:=
	With[{
		refList=
			DeleteDuplicates@Flatten@Prepend[ChemRecursiveReferences@obj,obj]
		},
		With[{copies=ChemCopy[refList,{}]},
			Global`blech=Thread[refList->copies];
			ChemReplaceAll[copies,
				Thread[refList->copies]
				];
			Lookup[Thread[refList->copies],obj]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Clear*)



ChemClear[pat_:"*"]:=
	If[pat==="*",
		$ChemicalSystems[First@$ChemDefaultSystem]=	
			Append[
				KeySelect[$ChemicalSystems[First@$ChemDefaultSystem],
					MatchQ["ObjectType"|"ObjectKey"|"View"]
					],
				"NewID"->1
				];
		$ChemicalSystems=
			KeySelect[$ChemicalSystems,MatchQ[First@$ChemDefaultSystem]];,
		$ChemicalSystems=
			KeySelect[$ChemicalSystems,Not@*StringMatchQ[pat]];
		If[!KeyMemberQ[$ChemicalSystems,First@$ChemDefaultSystem],
				$ChemDefaultSystem=
					CreateChemicalSystem["System-default-"]
			]
		];


(* ::Subsection:: *)
(*Classes*)



(* ::Subsubsection::Closed:: *)
(*Defaults*)



(*$ChemObjectDefaults//Clear*)


If[MatchQ[$ChemObjectDefaults,_Symbol],
	$ChemObjectDefaults=
		<| 
			(* Each of the individual classes will populate the list in turn *)
			"Common"->
				<|
					"View"->ChemMethod[ChemView],
					"Copy"->ChemMethod[ChemCopy],
					"References"->ChemProperty[ChemReferences],
					"InstanceQ"->ChemMethod[ChemInstanceQ],
					"Association"->ChemProperty[ChemAssociation],
					"AddReference"->ChemMethod[ChemAddReference],
					"Save"->ChemMethod[ChemSave],
					"Remove"->ChemMethod[ChemRemove]
					|>
			|>
		];


(* ::Subsection:: *)
(*Persistence*)



(* ::Subsubsection::Closed:: *)
(*ChemStore*)



(* ::Subsubsubsection::Closed:: *)
(*Config*)



If[!ValueQ@$ChemLocalStore,
	$ChemLocalStore:=
		FileNameJoin@{
			`Package`$PackageDirectory,
			"Objects"
			};
	];
If[!ValueQ@$ChemCloudStore,
	$ChemCloudStore:=
		CloudObject@".ChemObjects";
	];
If[!ValueQ@$ChemStoreBase,
	$ChemStoreBase=
		LocalObject
	];


(*$ChemStoreAliases//Clear*)


If[!ValueQ@$ChemStoreAliases,
	$ChemStoreAliases=
		<|
			"Google Drive"->
				FileNameJoin@{$HomeDirectory,
					"Google Drive","ChemObjects"},
			"Dropbox"->
				FileNameJoin@{$HomeDirectory,
					"Dropbox","ChemObjects"},
			"OneDrive"->
				FileNameJoin@{$HomeDirectory,
					"OneDrive","ChemObjects"},
			"tmp"->
				FileNameJoin@{$TemporaryDirectory,"ChemObjects"}
			|>
	];


(* ::Subsubsubsection::Closed:: *)
(*$ChemStores*)



chemStoreBasePattern=
	Automatic|LocalObject|CloudObject|_CloudObject|
		_String?DirectoryQ|
		_String?(URLParse[#]["Scheme"]=!=None&)|
		_String?(KeyMemberQ[$ChemStoreAliases,#]&);


$ChemStores:=
	ReplacePart[2->Automatic]/@
		ChemStores[Replace[$ChemStoreBase,Automatic->$ChemLocalStore]]


ChemStores[base_]:=
	Replace[base,{
		LocalObject:>
			ChemStore/@
				LocalObjects[$ChemLocalStore],
		CloudObject:>
			ChemStore/@
				CloudObjects[$ChemLocalStore],
		d_String?DirectoryQ:>
			ChemStore/@
				LocalObjects[d],
		c:_CloudObject|_String?(URLParse[#]["Scheme"]=!=None&):>
			ChemStore/@
				CloudObjects[c],
		s_String?(KeyMemberQ[$ChemStoreAliases,#]&):>
			ChemStore/@
				LocalObjects[$ChemStoreAliases[s]]
		}];


(* ::Subsubsubsection::Closed:: *)
(*DownValues*)



chemStorePath[ChemObject[p__]]:=
	StringJoin@Riffle[Reverse@{p},"@"];


ChemStore[c_ChemObject]:=
	ChemStore[c,Automatic];
ChemStore[
	ChemStore[c_ChemObject,_],
	base:chemStoreBasePattern]:=
	ChemStore[c,base];
HoldPattern@ChemStore[LocalObject[urlpath_]]:=
	With[{path=
		FileNameJoin@Lookup[urlpath//URLDecode//URLParse,"Path"]},
		ChemStore[
			ChemObject@@Reverse@StringSplit[FileBaseName@path,"@"],
			With[{trimmedPath=
				StringTrim[DirectoryName@path,
					$PathnameSeparator~~EndOfString]
				},
				If[trimmedPath==$ChemLocalStore,
					LocalObject,
					Lookup[Reverse/@Normal@$ChemStoreAliases,
						trimmedPath,
						trimmedPath
						]
					]
				]
			]
		];
HoldPattern@ChemStore[CloudObject[path_]]:=
	ChemStore[
		ChemObject@@Reverse@StringSplit[FileNameTake@First@path,"@"],
		With[{cloudParent=
			CloudObject@
				URLBuild@ReplacePart[#,
						"Path"->Delete[#Path,-1]
						]&[URLParse[path]]
			},
			If[cloudParent==$ChemCloudStore,
				CloudObject,
				cloudParent
				]
			]
		];


(* ::Subsubsubsection::Closed:: *)
(*UpValues*)



ChemStore/:
	HoldPattern[LocalObject[
		ChemStore[c_ChemObject,
			d:Automatic|LocalObject|
			_String?DirectoryQ|_String?(KeyMemberQ[$ChemStoreAliases,#]&)]
		]]:=
	LocalObject[chemStorePath[c],
		Replace[d,{
			Automatic|LocalObject:>$ChemLocalStore,
			_String?(KeyMemberQ[$ChemStoreAliases,#]&):>
				$ChemStoreAliases[d]
			}]
		];
ChemStore/:
	HoldPattern[CloudObject[
		ChemStore[c_ChemObject,
			d:Automatic|CloudObject|_CloudObject|
				_String?(URLParse[#]["Scheme"]=!=None&)]
		]]:=
	CloudObject@
		URLBuild@{
			Replace[d,Automatic|CloudObject:>$ChemCloudStore],
			chemStorePath[c]
			};
ChemStore/:
	HoldPattern[ChemObject[
		ChemStore[c_ChemObject,_]
		]]:=c;


ChemStoreObject[s:ChemStore[_ChemObject,base:chemStoreBasePattern]]:=
	Replace[
		Replace[base,
			Automatic:>
				Replace[$ChemStoreBase,
					Automatic:>LocalObject
					]
			],{
		LocalObject|_String?DirectoryQ|
			_String?(KeyMemberQ[$ChemStoreAliases,#]&):>
			LocalObject[s],
		CloudObject|_CloudObject|
			_String?(URLParse[#]["Scheme"]=!=None&):>
			CloudObject[s]
		}];


With[{chemStore=ChemStore[_ChemObject,chemStoreBasePattern]},
	ChemStore/:
		HoldPattern[
			Import[s:chemStore]
			]:=
			Replace[ChemStoreObject[s],{
				c:CloudObject:>
					CloudImport@c,
				e_:>
					Import[e]
				}];
	ChemStore/:
		HoldPattern[
			DeleteFile[s:chemStore]
			]:=
			DeleteFile@ChemStoreObject[s];
	ChemStore/:
		HoldPattern[File[s:chemStore]]:=
			ChemStoreObject[s];
	ChemStore/:
		HoldPattern[SetOptions[s:chemStore,o_]]:=
			SetPermissions[ChemStoreObject[s],o];
	ChemStore/:
		HoldPattern[SetPermissions[s:chemStore,p_]]:=
			SetPermissions[ChemStoreObject[s],p];
	];


(* ::Subsubsection::Closed:: *)
(*Save*)



chemSave[s:ChemStore[obj:ChemSinglePattern,base:chemStoreBasePattern]]:=
	With[{store=ChemStoreObject@s},
		Put[ChemAssociation[obj],
			store
			];
		s
		];
chemSave[obj:ChemSinglePattern,	
	base:chemStoreBasePattern:Automatic]:=
	chemSave@
		ChemStore[obj,base];


chemSaveRecursive[
	s:ChemStore[obj:ChemSinglePattern,base:chemStoreBasePattern]
	]:=
	With[{refs=ChemRecursiveReferences[obj]},
		chemSave[#,base]&/@refs;
		chemSave[s]
		];


ChemSave[
	spec:ChemStore[ChemSinglePattern,chemStoreBasePattern],
	recurse:True|False:True
	]:=
	If[recurse,
		chemSaveRecursive@spec,
		chemSave@spec
		];
ChemSave[obj:ChemSinglePattern,	
	base:chemStoreBasePattern:Automatic,
	recurse:True|False:True]:=
	ChemSave[ChemStore[obj,base],recurse];


(* ::Subsubsection::Closed:: *)
(*Load*)



chemLoad[s:ChemStore[ChemObject[sys_],base:chemStoreBasePattern]]:=
	Replace[Quiet@Import@s,{
		a_Association:>
			(
				$ChemicalSystems[sys]=a;
				ChemObject[sys]),
		_->$Failed
		}];
chemLoad[s:ChemStore[ChemObject[sys_,obj_],base:chemStoreBasePattern]]:=
	Replace[Import@s,{
		a_Association:>
				(
				If[!KeyMemberQ[$ChemicalSystems,sys],
					Replace[chemLoad[ChemStore[ChemObject[sys],base]],
						$Failed:>
							CreateChemicalSystem[sys,False]
						]
					];
				$ChemicalSystems[sys,obj]=a;
				ChemObject[sys,obj]
				),
		_->$Failed
		}];
chemLoad[obj_ChemObject,	
	base:chemStoreBasePattern:Automatic]:=
	ChemLoad@
		ChemStore[obj,base];
chemLoadRecursive[
	s:ChemStore[_ChemObject,base:chemStoreBasePattern]
	]:=
	With[{obj=chemLoad[s]},
		First@FixedPoint[
			If[Length@#[[2]]>0,
				With[{loads=
					chemLoad[ChemStore[#,base]]&/@#[[2]]
					},
					With[{new=Flatten@ChemGet[#[[2]],"ObjectReferences"]},
						{
							Union[#[[1]],loads],
							Complement[new,
								Union[#[[1]],loads]
								]
							}
						]
					],
				#
				]&,
			{{obj},Flatten@{ChemGet[obj,"ObjectReferences"]}},
			15
			];
		obj
		];


ChemLoad[
	spec:ChemStore[_ChemObject,chemStoreBasePattern],
	recurse:True|False:True
	]:=
	If[recurse,
		chemLoadRecursive@spec,
		chemLoad@spec
		];
ChemLoad[obj:_ChemObject,	
	base:chemStoreBasePattern:Automatic,
	recurse:True|False:True]:=
	ChemLoad[ChemStore[obj,base],recurse];


(* ::Subsection:: *)
(*Properties*)



(* ::Subsubsection::Closed:: *)
(*Association*)



ChemAssociation[ob:ChemObjPattern|ChemSysPattern]:=
	$ChemicalSystems@@ob;
ChemAssociation[v:ChemObjVectorPattern|ChemSysVectorPattern]:=
	$ChemicalSystems@@@v;


(* ::Subsubsection::Closed:: *)
(*Apply*)



ChemApply[sys:ChemSysPattern,f_]:=
	With[{system=First@sys},
		Replace[f@$ChemicalSystems[system],
			new_Association:>
				($ChemicalSystems[system]=new)
			]
		];
ChemApply[sys:ChemSysVectorPattern,f_]:=
	With[{systems=First/@sys},
		Replace[Thread[systems->Map[f,Lookup[$ChemicalSystems,systems]]],
			(k_->new_Association):>
				($ChemicalSystems[k]=new),
			1]
		];


ChemApply[obj:ChemObjPattern,f_]:=
	With[{system=First@obj,id=Last@obj},
		Replace[f@$ChemicalSystems[system][id],
			new_Association:>
				($ChemicalSystems[system,id]=new)
			];
		];
ChemApply[objV:ChemObjVectorPattern,f_]:=
	With[{groups=
		Map[Last]/@GroupBy[objV,First]
		},
		With[{assocs=Lookup[$ChemicalSystems,Keys@groups]},
			MapThread[
				With[{rs=
					MapThread[
						With[{r=f@#2},
							If[AssociationQ@r,
								#->r,
								Nothing
								]
							]&,{
							#2,
							#3
						}]
					},
					If[Length@rs>0,
						AssociateTo[
							$ChemicalSystems[#],
							rs
							]
						]
					]&,{
					Keys@groups,
					Values@groups,
					MapThread[Lookup,{
						assocs,
						Values@groups
						}]
					}]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Get*)



ChemGet[{},__]:=
	{};


$ChemFormatMethods=True;
$ChemGetDefault;


chemGetLookup[obs_,props_,default_]:=
	If[MatchQ[default,$ChemGetDefault]&&!ValueQ@$ChemGetDefault,
		Lookup[obs,props],
		Lookup[obs,props,default]
		];


ChemGet[sys:ChemSysPattern,prop:Except[_List],default_:$ChemGetDefault]:=
	With[{p=
		chemGetLookup[$ChemicalSystems[First@sys],prop,default]
			},
		If[$ChemFormatMethods//TrueQ,
			Replace[p,{
				ChemMethod[f_]:>(f[sys,##]&),
				ChemProperty[f_]:>f[sys]
				}],
			p	
			]
		];
ChemGet[sys:ChemSysPattern,prop:{__},default_:$ChemGetDefault]:=
	With[{p=
		chemGetLookup[$ChemicalSystems[First@sys],prop,default]
		},
		If[$ChemFormatMethods//TrueQ,
			Replace[p,{
				ChemMethod[f_]:>(f[sys,##]&),
				ChemProperty[f_]:>f[sys]
				},
				1],
			p	
			]
		];


ChemGet[sysV:ChemSysVectorPattern,prop:Except[_List],default_:$ChemGetDefault]:=
	With[{p=
		Thread[
			sysV->
				chemGetLookup[Lookup[$ChemicalSystems,First/@sysV],prop,default]
			]},
		If[$ChemFormatMethods//TrueQ,
			Replace[p,{
				(sys_->ChemMethod[f_]):>(f[sys,##]&),
				(sys_->ChemProperty[f_]):>f[sys]
				},
				1],
			p	
			]
		];
ChemGet[sysV:ChemSysVectorPattern,prop:{__},default_:$ChemGetDefault]:=
	MapThread[
		If[$ChemFormatMethods//TrueQ,
			Replace[#2,{
				ChemMethod[f_]:>
					With[{sys=#},f[sys,##]&],
				ChemProperty[f_]:>
					With[{sys=#},f[sys]]
				},
				1],
			#2]&,{
				sysV,
				chemGetLookup[Lookup[$ChemicalSystems,First/@sysV],prop,default]
			}];


ChemGet[obj:ChemObjPattern,prop:Except[_List],default_:$ChemGetDefault]:=
	With[{
		system=First@obj,
		id=Last@obj
		},
		With[{
			p=
				chemGetLookup[$ChemicalSystems[system,id],prop,default]
			},
			If[$ChemFormatMethods//TrueQ,
				Replace[p,{
					ChemMethod[f_]:>(f[ChemObject[system,id],##]&),
					ChemProperty[f_]:>f[ChemObject[system,id]]
					}],
				p	
				]
			]
		];
ChemGet[obj:ChemObjPattern,props:{__},default_:$ChemGetDefault]:=
		With[{
		system=First@obj,
		id=Last@obj
		},
		With[{
			p=
				chemGetLookup[$ChemicalSystems[system,id],props,default]
			},
			If[$ChemFormatMethods//TrueQ,
				Replace[p,{
					ChemMethod[f_]:>(f[ChemObject[system,id],##]&),
					ChemProperty[f_]:>f[ChemObject[system,id]]
					},
					1],
				p	
				]
			]
		];


ChemGet[objV:ChemObjVectorPattern,prop:Except[_List],default_:$ChemGetDefault]:=
	With[{p=
		Join@@Map[
			chemGetLookup[
				Lookup[$ChemicalSystems[First@First@#],
					Last/@#],
				prop,
				default]&,
			SplitBy[objV,First]
			]},
		If[$ChemFormatMethods//TrueQ,
			MapThread[
				Replace[#2,{
					ChemMethod[f_]:>
						With[{obj=#},f[obj,##]&],
					ChemProperty[f_]:>
						With[{obj=#},f[obj]]
					}]&,{
				objV,
				p
				}],
			p	
			]
		];
ChemGet[objV:ChemObjVectorPattern,prop:{__},default_:$ChemGetDefault]:=
	MapThread[
		If[$ChemFormatMethods//TrueQ,
			Replace[#2,{
				ChemMethod[f_]:>
					With[{obj=#},f[obj,##]&],
				ChemProperty[f_]:>
					With[{obj=#},f[obj]]
				},
				1],
			#2]&,{
				objV,
				Join@@Map[
					chemGetLookup[
						Lookup[$ChemicalSystems[First@First@#],
							Last/@#],
						prop,
						default]&,
					SplitBy[objV,First]
					]
			}];


ChemGet[obs:{ChemObjAllPattern..},props_,default_:$ChemGetDefault]:=
	With[{objV=Flatten@obs},
		With[{a=AssociationThread[objV,ChemGet[objV,props,default]]},
			obs/.a
			]
		];


ChemGet[prop_][o:(ChemObjPattern|ChemObjVectorPattern|ChemSysPattern|ChemSysVectorPattern)]:=
	ChemGet[o,prop];


(* ::Subsubsection::Closed:: *)
(*Set*)



ChemSet[sys:ChemSysPattern,prop:Except[_List],val_]:=
	With[{s=First@sys},
		($ChemicalSystems[s][prop]=val;)
		];
ChemSet[sys:ChemSysPattern,prop:{__},val_]:=
	With[{s=First@sys},
		AssociateTo[$ChemicalSystems[s],
			#->val&/@prop
			];
		];


ChemSet[sysV:ChemSysVectorPattern,prop_,val_]:=
	(Map[ChemSet[#,prop,val]&,sysV];);


ChemSet[obj:ChemObjPattern,prop:Except[_List],val_]:=
	With[{s=First@obj,i=Last@obj},
		$ChemicalSystems[s][i][prop]=val;
		];
ChemSet[obj:ChemObjPattern,prop:{__},val_]:=
	With[{s=First@obj,i=Last@obj},
		AssociateTo[$ChemicalSystems[s,i],
			#->val&/@prop
			];
		];


ChemSet[objV:ChemObjVectorPattern,prop_,val_]:=
	With[{
		groups=Map[Last]/@GroupBy[objV,First],
		p=AssociationMap[val&,Flatten[{prop},1]]},
		KeyValueMap[
			With[{s=#,ids=#2},
				AssociateTo[$ChemicalSystems[s],
					Thread[ids->
						Map[Join[#,p]&,
							Lookup[$ChemicalSystems[s],ids]]
						]
					];
				]&,
				groups
			];
		];


ChemSet[objV:{ChemObjAllPattern..},prop_,val_]:=
	(Map[ChemSet[#,prop,val]&,Flatten[objV,1]];);


ChemSet[prop_,val_][o:(ChemObjPattern|ChemObjVectorPattern|ChemSysPattern|ChemSysVectorPattern)]:=
	ChemSet[o,prop,val];


(* ::Subsubsection::Closed:: *)
(*SetDelayed*)



SetAttributes[ChemSetDelayed,HoldRest];


ChemSetDelayed[sys:ChemSysPattern,prop_?(MatchQ[Except[_List]]),val_]:=
	With[{s=First@sys},
		$ChemicalSystems[s][prop]:=val
		];
ChemSetDelayed[sys:ChemSysPattern,id_,prop_?(MatchQ[{__}]),val_]:=
	With[{s=First@sys},
		AssociateTo[$ChemicalSystems[s],
			#:>val&/@prop
			]
		];


ChemSetDelayed[sysV:ChemSysVectorPattern,prop_,val_]:=
	Map[ChemSetDelayed[#,prop,val]&,sysV]


ChemSetDelayed[obj:ChemObjPattern,prop_?(MatchQ[Except[_List]]),val_]:=
	With[{s=First@obj,i=Last@obj},
		$ChemicalSystems[s][i][prop]:=val
		];
ChemSetDelayed[obj:ChemObjPattern,prop_?(MatchQ[{__}]),val_]:=
	With[{s=First@obj,i=Last@obj},
		AssociateTo[$ChemicalSystems[s,i],
			#:>val&/@prop
			]
		];


ChemSetDelayed[objV:ChemObjVectorPattern,prop_,val_]:=
	With[{
		groups=Map[Last]/@GroupBy[objV,First],
		p=Association@Map[#:>val&,Flatten[{prop},1]]},
		KeyValueMap[
			With[{s=#,ids=#2},
				AssociateTo[$ChemicalSystems[s],
					Thread[ids->
						Map[Join[#,p]&,
							Lookup[$ChemicalSystems[s],ids]]
						]
					];
				]&,
				groups
			];
		];


ChemSetDelayed[objV:{ChemObjAllPattern..},prop_,val_]:=
	Map[ChemSetDelayed[#,prop,val]&,Flatten[objV,1]]


ChemSetDelayed[prop_,val_][o:(ChemObjPattern|ChemObjVectorPattern|ChemSysPattern|ChemSysVectorPattern)]:=
	ChemSetDelayed[o,prop,val];


(* ::Subsubsection::Closed:: *)
(*ThreadSet*)



ChemThreadSet[sys:ChemSysPattern,prop:{__},val:{__}]:=
	With[{s=First@sys},
		AssociateTo[$ChemicalSystems[s],
			Thread[prop->val]
			];
		];


ChemThreadSet[sysV:ChemSysVectorPattern,prop:Except[_List],val:{__}]:=
	(MapThread[AssociateTo[$ChemicalSystems[#],prop->#2];&,{
		First/@sysV,
		val
		}];);
ChemThreadSet[sysV:ChemSysVectorPattern,prop:{__},val:{__}]:=
	(Map[ChemThreadSet[#,prop,val]&,sysV];);


ChemThreadSet[obj:ChemObjPattern,prop:{__},val:{__}]:=
	With[{s=First@obj,i=Last@obj},
		AssociateTo[$ChemicalSystems[s,i],
			Thread[prop->val]
			];
		];


ChemThreadSet[objV:ChemObjVectorPattern,prop:Except[_List],val:{__}]:=
	(MapThread[AssociateTo[$ChemicalSystems[#,#2],prop->#3];&,{
		First/@objV,
		Last/@objV,
		val
		}];);
ChemThreadSet[objV:ChemObjVectorPattern,prop:{__},val:{__}]:=
	(Map[ChemThreadSet[#,prop,val]&,objV];);


ChemThreadSet[objV:{ChemObjAllPattern..},prop_,val:{__}]:=
	ChemThreadSet[Flatten[objV,1],prop,Flatten[val,1]];


ChemThreadSet[prop:{__},val:{__}][o:(ChemObjPattern|ChemObjVectorPattern|ChemSysPattern|ChemSysVectorPattern)]:=
	ChemThreadSet[o,prop,val];


(* ::Subsubsection::Closed:: *)
(*ThreadSetDelayed*)



SetAttributes[ChemThreadSetDelayed,HoldRest];


ChemThreadSetDelayed[sys:ChemSysPattern,prop:{__},val:{__}]:=
	With[{s=First@sys},
		AssociateTo[$ChemicalSystems[s],
			Thread[prop:>val]
			];
		];


ChemThreadSetDelayed[sysV:ChemSysVectorPattern,prop:Except[_List],val:{__}]:=
	(MapThread[AssociateTo[$ChemicalSystems[#],prop:>#2]&,{
		First/@sysV,
		val
		}];);
ChemThreadSetDelayed[sysV:ChemSysVectorPattern,prop:{__},val:{__}]:=
	(Map[ChemThreadSetDelayed[#,prop,val];&,sysV];)


ChemThreadSetDelayed[obj:ChemObjPattern,prop:{__},val:{__}]:=
	With[{s=First@obj,i=Last@obj},
		AssociateTo[$ChemicalSystems[s,i],
			Thread[prop:>val]
			];
		];


ChemThreadSetDelayed[objV:ChemObjVectorPattern,prop:Except[_List],val:{__}]:=
	(MapThread[
		AssociateTo[$ChemicalSystems[#,#2],
			Replace[#3,Hold[v_]:>(prop:>v)]];&,{
		First/@objV,
		Last/@objV,
		Thread@Hold[val]
		}];);
ChemThreadSetDelayed[objV:ChemObjVectorPattern,prop:{__},val:{__}]:=
	(Map[ChemThreadSetDelayed[#,prop,val];&,objV];);


ChemThreadSetDelayed[objV:{ChemObjAllPattern..},prop_,val:{__}]:=
	ChemThreadSetDelayed[Flatten[objV,1],prop,
		Evaluate@Flatten[Thread@Hold[val],1]];


ChemThreadSetDelayed[objV:{ChemObjAllPattern..},prop_,val:{__}]:=
	ChemThreadSetDelayed[Flatten[objV,1],prop,Flatten[val,1]];


ChemThreadSetDelayed[prop:{__},val:{__}][o:(ChemObjPattern|ChemObjVectorPattern|ChemSysPattern|ChemSysVectorPattern)]:=
	ChemThreadSetDelayed[o,prop,val];


(* ::Subsubsection::Closed:: *)
(*Unset*)



ChemUnset[sys:ChemSysPattern]:=
	With[{s=First@sys},
		$ChemicalSystems[s][prop]=.
		];
ChemUnset[sys:ChemSysPattern,prop:{__}]:=
	With[{s=First@sys},
		KeyDropFrom[$ChemicalSystems[s],
			prop
			]
		];


ChemUnset[sysV:ChemSysVectorPattern,prop_]:=
	Map[ChemUnset[#,prop]&,sysV]


ChemUnset[obj:ChemObjPattern,prop:Except[_List]]:=
	With[{s=First@obj,i=Last@obj},
		$ChemicalSystems[s][i][prop]=.
		];
ChemUnset[obj:ChemObjPattern,prop:{__}]:=
	With[{s=First@obj,i=Last@obj},
		KeyDropFrom[$ChemicalSystems[s,i],
			prop
			]
		];


ChemUnset[objV:ChemObjVectorPattern,prop_]:=
	Map[ChemUnset[#,prop]&,objV]


ChemUnset[prop_][o:(ChemObjPattern|ChemObjVectorPattern|ChemSysPattern|ChemSysVectorPattern)]:=
	ChemUnset[o,prop];


(* ::Subsection:: *)
(*Overrides*)



(* ::Subsubsection::Closed:: *)
(*ChemTestObjectQ*)



Clear@ChemTestObjectQ;
ChemTestObjectQ[o_ChemObject]:=
	ChemObjectQ[o];
ChemTestObjectQ[s_Symbol]:=
	MatchQ[
		OwnValues[s],
		{Verbatim[HoldPattern][HoldPattern[s]]:>_ChemObject?ChemObjectQ}
		];
ChemTestObjectQ[_]:=
	False;
ChemTestObjectQ~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*Lookup*)



eChemObjectConstructor[obj_]:=
	!TrueQ[$eChemObjectConstructor]&&System`Private`EntryQ[Unevaluated@obj];
eChemObjectConstructor~SetAttributes~HoldAllComplete;


(*obj:ChemObject[_,_]?eChemObjectConstructor:=
	Block[{$eChemObjectConstructor=True},
		System`Private`SetNoEntry[obj]
		]*)


(obj:ChemObject[_,_]?ChemObjectQ)["Properties"]:=
	Keys@ChemAssociation@obj;
(obj:ChemObject[_,_]?ChemObjectQ)["Association"]:=
	ChemAssociation@obj;


ChemObject/:(obj:ChemObject[_,_]?ChemObjectQ)[[bits___]]:=
	With[{
		res=
			Check[
				Fold[
					If[!ListQ[#]&&ChemObjectQ[#]//TrueQ,
						If[IntegerQ[#2],
							ChemGet[#][[#2]],
							ChemGet[#,#2]
							],
						#[[#2]]
						]&,
					obj,
					{bits}
					],
				$ChemObjectLookupFailure,
				{
					Part::partd,General::partd,
					Part::pspec1,General::pspec1
					}
				]
		},
		res/;res=!=$ChemObjectLookupFailure
		];
(obj:ChemObject[_,_]?ChemObjectQ)[bits__]:=
	With[{
		res=
			Catch[
				Fold[
					If[Head[#]===ChemObject,
						ChemGet[#,#2],
						Replace[#[#2],Unevaluated[#[#2]]:>
							(
								Message[ChemObject::pspec1,#2];
								Throw[$ChemObjectLookupFailure]
								)
							]
						]&,
					obj,
					{bits}
					]
				]
		},
		res/;res=!=$ChemObjectLookupFailure&&Head[res]=!=ChemGet
		];


(* ::Subsubsection::Closed:: *)
(*Normal*)



ChemObject/:HoldPattern[Normal@ChemObject[s_]]:=
	$ChemicalSystems[s];
ChemObject/:HoldPattern[Normal@ChemObject[s_,i_]]:=
	$ChemicalSystems[s][i];


(* ::Subsubsection::Closed:: *)
(*Equal*)



ChemObject/:HoldPattern[Equal[a:ChemObject[__],b:ChemObject[__]]]:=
	(Normal@a===Normal@b);


(* ::Subsubsection::Closed:: *)
(*Join*)



(* ::Text:: *)
(*Not Implemented*)



(* ::Subsubsection::Closed:: *)
(*Merge*)



(* ::Text:: *)
(*Not implemented yet*)



(* ::Subsubsection::Closed:: *)
(*MessageName*)



(*Unprotect@MessageName;
$ChemMessageNameOverride=True;
$ChemInMessageName;*)


(* ::Subsubsubsection::Closed:: *)
(*Clear UpValues*)



(*MessageName[a__]/;(!TrueQ@$ChemMessageNameOverride):=Quiet@(
	Unprotect@MessageName;
	(MessageName[s_,props:Except["usage"]..]/;!TrueQ@$ChemInMessageName)=.;
	MessageName/:
		HoldPattern[
			Set[MessageName[s_,props:Except["usage"]..],v_]/;!TrueQ@$ChemInMessageName
			]=.;
	MessageName/:
		HoldPattern[
			SetDelayed[MessageName[s_,props:Except["usage"]..],v_]/;!TrueQ@$ChemInMessageName
			]=.;
	MessageName/:
		HoldPattern[
			Unset[MessageName[s_,props:Except["usage"]..]]/;!TrueQ@$ChemInMessageName
			]=.;
	Protect@MessageName;
	);*)


(* ::Subsubsubsection::Closed:: *)
(*Get*)



(*MessageName[s_,props:Except["usage"]..]/;!TrueQ@$ChemInMessageName:=
	If[ChemTestObjectQ@s,
		Fold[ChemGet[#,#2]&,s,{props}],
		Block[{$ChemInMessageName=True},MessageName[s,props]]
		];*)


(* ::Subsubsubsection::Closed:: *)
(*Set*)



(*MessageName/:
	HoldPattern[
		Set[MessageName[s_,props:Except["usage"]..],v_]/;!TrueQ@$ChemInMessageName
		]:=
		If[ChemTestObjectQ@s,
			With[{obj=Fold[ChemGet[#,#2]&,s,Most@{props}]},
				ChemSet[obj,Last@{props},v]
				],
			Block[{$ChemInMessageName=True},MessageName[s,props]=v]
			];*)


(* ::Subsubsubsection::Closed:: *)
(*SetDelayed*)



(*MessageName/:
	HoldPattern[
		SetDelayed[MessageName[s_,props:Except["usage"]..],v_]/;!TrueQ@$ChemInMessageName
		]:=
		If[ChemTestObjectQ@s,
			With[{obj=Fold[ChemGet[#,#2]&,s,Most@{props}]},
				ChemSetDelayed[obj,Last@{props},v]
				],
			Block[{$ChemInMessageName=True},MessageName[s,props]:=v]
			];*)


(* ::Subsubsubsection::Closed:: *)
(*Unset*)



(*MessageName/:
	HoldPattern[
		Unset[MessageName[s_,props:Except["usage"]..]]/;!TrueQ@$ChemInMessageName
		]:=
		If[ChemTestObjectQ@s,
			With[{obj=Fold[ChemGet[#,#2]&,s,Most@{props}]},
				ChemUnset[obj,Last@{props}]
				],
			Block[{$ChemInMessageName=True},MessageName[s,props]=.]
			];*)


(*Protect@MessageName;*)


(* ::Subsubsection::Closed:: *)
(*MutationHandler*)



Language`SetMutationHandler[ChemObject, ChemObjectMutationHandler];


ChemObjectMutationHandler~SetAttributes~HoldAllComplete;


ChemObject::noobj="`` isn't a valid object"


(* ::Subsubsubsection::Closed:: *)
(*Basic*)



ChemObjectMutationHandler[
	Set[sym_Symbol?ChemTestObjectQ[base___,prop:Except[_List]], newvalue_]
	]:=
	With[{obj=If[Length[Hold[base]]>0,sym[base],sym]},
		If[ChemObjectQ[obj],
			ChemSet[obj,prop,newvalue],
			Message[ChemObject::noobj,obj];
			$Failed
			]
		];
ChemObjectMutationHandler[
	SetDelayed[sym_Symbol?ChemTestObjectQ[base___,prop:Except[_List]], newvalue_]
	]:=
	With[{obj=If[Length[Hold[base]]>0,sym[base],sym]},
		If[ChemObjectQ[obj],
			ChemSet[obj,prop,newvalue],
			Message[ChemObject::noobj,obj];
			$Failed
			]
		];


(* ::Subsubsubsection::Closed:: *)
(*Part*)



ChemObjectMutationHandler[
	Set[sym_Symbol?ChemTestObjectQ[[base___,prop:Except[_List|_Integer],parts__Integer]],
		newvalue_
		]
	]:=
	With[{obj=If[Length[Hold[base]]>0,sym[base],sym]},
		If[ChemObjectQ[obj],
			ChemSetPart[obj,prop,parts,newvalue],
			Message[ChemObject::noobj,obj];
			$Failed
			]
		];
ChemObjectMutationHandler[
	SetDelayed[sym_Symbol?ChemTestObjectQ[[
		base___,
		prop:Except[_List|_Integer],
		parts__Integer
		]],
		newvalue_
		]
	]:=
	With[{obj=If[Length[Hold[base]]>0,sym[base],sym]},
		If[ChemObjectQ[obj],
			ChemSetPartDelayed[obj,prop,parts,newvalue],
			Message[ChemObject::noobj,obj];
			$Failed
			]
		];


(* ::Subsubsubsection::Closed:: *)
(*Thread*)



ChemObjectMutationHandler[
	Set[sym_Symbol?ChemTestObjectQ[base___,prop_List], newvalue_]
	]:=
	With[{obj=If[Length[Hold[base]]>0,sym[base],sym]},
		If[ChemObjectQ[obj],
			ChemThreadSet[obj,prop,newvalue],
			Message[ChemObject::noobj,obj];
			$Failed
			]
		];
ChemObjectMutationHandler[
	SetDelayed[sym_Symbol?ChemTestObjectQ[base___,prop_List], newvalue_]
	]:=
	With[{obj=If[Length[Hold[base]]>0,sym[base],sym]},
		If[ChemObjectQ[obj],
			ChemThreadSetDelayed[obj,prop,newvalue],
			Message[ChemObject::noobj,obj];
			$Failed
			]
		];


(* ::Subsubsubsection::Closed:: *)
(*AddTo*)



(* ::Subsubsubsection::Closed:: *)
(*SubtractFrom*)



(* ::Subsubsubsection::Closed:: *)
(*DivideBy*)



(* ::Subsubsubsection::Closed:: *)
(*TimesBy*)



(* ::Subsubsubsection::Closed:: *)
(*AppendTo*)



(* ::Subsubsubsection::Closed:: *)
(*AssociateTo*)



(* ::Subsection:: *)
(*General methods*)



(* ::Subsubsection::Closed:: *)
(*InstanceQ*)



ChemInstanceQ[o:ChemObjPattern,types:_String|{__String}]:=
	MemberQ[Flatten@{types},ChemGet[o,"ObjectType"]];
ChemInstanceQ[obs:{ChemObjPattern..},types:_String|{__String}]:=
	MemberQ[Flatten@{types},#]&/@ChemGet[obs,"ObjectType"];
ChemInstanceQ[types_][obj_]:=
	ChemInstanceQ[obj,types];


(* ::Subsubsection::Closed:: *)
(*Merge*)



ChemMerge[
	obj:ChemObjAllPattern,
	a:_Association|{__Association}|{__Rule}|_Rule,
	mergeFunction_:Join
	]:=
	ChemApply[obj,
		Prepend[
			Merge[{#,a},mergeFunction],
			"ObjectKey"->#ObjectKey
			]&
		];
ChemMerge[obj:ChemObjAllPattern,obj2:ChemObjAllPattern,mergeFunction_:Join]:=
	ChemMerge[obj,ChemAssociation@obj2,mergeFunction];


(* ::Subsubsection::Closed:: *)
(*Join*)



ChemJoin[{a__Association}]:=
	ChemAdd[Join[a]];
ChemJoin[a:{{__Association}..}]:=
	ChemAdd@Apply[Join,a,{1}];
ChemJoin[obj:ChemObjAllPattern]:=
	ChemAdd[Flatten@{ChemAssociation@obj}];
ChemJoin[obj:{ChemObjAllPattern}]:=
	ChemAdd@Map[Flatten@{ChemAssociation@#}&,obj];


(* ::Subsubsection::Closed:: *)
(*ReplaceAll*)



ChemReplaceAll[o:chemThingsAll,replacements_]:=
	ChemApply[o,ReplaceAll[replacements]];
ChemReplaceAll[replacements_][o:chemThingsAll]:=
	ChemReplaceAll[o,replacements];


(* ::Subsubsection::Closed:: *)
(*Mutate*)



ChemMutate[obj:ChemObjPattern,prop:Except[_List],function_]:=
	ChemSet[obj,prop,
		function@ChemGet[obj,prop]];
ChemMutate[obj:ChemObjPattern,prop_List,function:Except[_List]]:=
	ChemThreadSet[obj,prop,
		function/@ChemGet[obj,prop]];
ChemMutate[obj:ChemObjPattern,prop_List,functions_List]:=
	ChemThreadSet[obj,prop,
		MapThread[#[#2]&,
			{functions,ChemGet[obj,prop]}]];


ChemMutate[objV:ChemObjVectorPattern,prop:Except[_List],function:Except[_List]]:=
	ChemThreadSet[objV,prop,
		function/@ChemGet[objV,prop]];
ChemMutate[objV:ChemObjVectorPattern,prop_List,function:Except[_List]]:=
	ChemThreadSet[objV,prop,
		Map[function,
			ChemGet[objV,prop],
			{2}]
		];
ChemMutate[objV:ChemObjVectorPattern,prop_,functions_List]:=
	ChemThreadSet[objV,prop,
		MapThread[#[#2]&,
		{
			functions,
			ChemGet[objV,prop]
			}
			]
		];


ChemMutate[prop_,function_][obj:ChemObjPattern|ChemObjVectorPattern]:=
	ChemMutate[obj,prop,function];


(* ::Subsubsection::Closed:: *)
(*Increment*)



chemGeneralIncrement[obj_,val_]:=
	Switch[{obj,val},
		{_?NumericQ,_?NumericQ},
			obj+val,
		{_List,_List},
			If[Length@obj==Length@val,
				obj+val,
				Join[obj,val]
				],
		{_String,_String},
			StringJoin@{obj,val},
		{_?(Not@*AtomQ),_?(Not@*AtomQ)},
			If[Head@obj===Head@val,
				Join[obj,val],
				Append[obj,val]
				],
		_,
			{obj,val}
		];


ChemIncrement[obj:ChemObjAllPattern,prop_,val_,function_]:=
	ChemMutate[obj,prop,(function[#,val])&];
ChemIncrement[obj:ChemObjAllPattern,prop_,val_]:=
	ChemMutate[obj,prop,(chemGeneralIncrement[#,val])&];
ChemIncrement[prop_,val_,f_][obj:ChemObjAllPattern]:=
	ChemIncrement[obj,prop,val,f]
ChemIncrement[prop_,val_][obj:ChemObjAllPattern]:=
	ChemIncrement[obj,prop,val]


(* ::Subsubsection::Closed:: *)
(*Decrement*)



chemGeneralDecrement[obj_,val_]:=
	Switch[{obj,val},
		{_String,_Integer},
			StringDrop[obj,val],
		{_String,_String|_StringExpression|_PatternTest|_Alternatives},
			StringTrim[obj, val~~EndOfString],
		{_?NumericQ,_?NumericQ},
			obj-val,
		{_?Not@*AtomQ,_},
			Replace[Position[obj,val],{___,p_}:>Delete[obj,p]],
		_,
			obj
		];


ChemDecrement[obj:ChemObjAllPattern,prop_,val_,function_]:=
	ChemMutate[obj,prop,(function[#,val])&];
ChemDecrement[obj:ChemObjAllPattern,prop_,val_]:=
	ChemMutate[obj,prop,(chemGeneralDecrement[#,val])&];
ChemDecrement[prop_,val_,f_][obj:ChemObjAllPattern]:=
	ChemDecrement[obj,prop,val,f]
ChemDecrement[prop_,val_][obj:ChemObjAllPattern]:=
	ChemDecrement[obj,prop,val]


(* ::Subsubsection::Closed:: *)
(*AppendTo*)



ChemAppendTo[obj:ChemObjAllPattern,prop_,val_]:=
	ChemIncrement[obj,prop,val,Append];


(* ::Subsubsection::Closed:: *)
(*DeleteFrom*)



ChemDeleteFrom[obj:ChemObjAllPattern,prop_,val_]:=
	ChemDecrement[obj,prop,val,DeleteCases];


(* ::Subsubsection::Closed:: *)
(*GetRecursive*)



ChemGetRecursive[obj:ChemObjAllPattern,props_]:=
	First@FixedPoint[
		If[Length@#[[2]]>0,
			With[{new=ChemGet[#[[2]],props,Nothing]},
				{
					Union[#[[1]],
						Replace[new,
							v:ChemObjVectorPattern:>
								Sequence@@v,
							1]
						],
					Complement[
						Flatten@Cases[new,ChemObjAllPattern],
						Flatten@Cases[#[[1]],ChemObjAllPattern]
						]
					}
				],
			#
			]&,
		{
			{},
			Flatten@{obj}
			},
		15
		];


(* ::Subsubsection::Closed:: *)
(*AddReference*)



ChemAddReference[ob:ChemObjAllPattern,ref:ChemObjAllPattern]:=
	ChemIncrement[ob,"ObjectReferences",ref,Flatten@*List];


(* ::Subsubsection::Closed:: *)
(*RemoveReference*)



ChemRemoveReference[ob:ChemObjAllPattern,ref:ChemObjAllPattern]:=
	ChemMutate[ob,"ObjectReferences",DeleteCases[Alternatives@@{ref}]];


(* ::Subsubsection::Closed:: *)
(*References*)



ChemReferences[obj:ChemObjAllPattern]:=
	ChemGet[obj,"ObjectReferences"]


(* ::Subsubsection::Closed:: *)
(*RecursiveReferences*)



ChemRecursiveReferences[obj:ChemObjAllPattern]:=
	First@FixedPoint[
		If[Length@#[[2]]>0,
			With[{new=Flatten@ChemGet[#[[2]],"ObjectReferences"]},
				{
					Union[#[[1]],new],
					Complement[new,
						#[[1]]
						]
					}
				],
			#
			]&,
		{{},Flatten@{ChemGet[obj,"ObjectReferences"],obj}},
		15
		];


(* ::Subsubsection::Closed:: *)
(*RemoveRecursive*)



ChemRemoveRecursive[obj:ChemObjAllPattern]:=
	With[{rs=Flatten@{obj,ChemRecursiveReferences[obj]}},
		ChemRemove@rs
		];


(* ::Subsubsection::Closed:: *)
(*Select*)



ChemSelect[obj:ChemObjAllPattern,test_]:=
	Select[obj,test];
ChemSelect[obj:ChemObjAllPattern,props_,test_]:=
	Pick[obj,test/@ChemGet[obj,props]];



