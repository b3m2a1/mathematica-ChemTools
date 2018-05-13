(* ::Package:: *)



ChemDVRClass::usage="Template interface for a ChemDVR";
ChemDVRClasses::usage="Lists the available classes";
ChemDVRNewClass::usage="Opens up a template notebook for a new class";


ChemDVRBegin::usage="Wrapper for all BeginPackage stuff";
ChemDVREnd::usage="Wrapper for all EndPackage stuff";
$ChemDVRLoaded::usage="The set of packages loaded already";
ChemDVRNeeds::usage="Needs type loader for stuff";
ChemDVRReload::usage="Reloads a ChemDVR file";


Begin["`Private`"];


(* ::Subsection:: *)
(*ChemDVRClass*)



(* ::Subsubsection::Closed:: *)
(*ChemDVRClass*)



ChemDVRClasses[pat_:"*"]:=
	Map[
		FileBaseName,
		Join@@
			Map[
				FileNames[
					If[StringQ@pat,StringTrim[pat,".m"],pat]~~".m",
					#
					]&,
				ChemDVRDirectory["Classes", True]
				]
		];


(*PackageAddAutocompletions[
	"ChemDVRClass",
	List@ChemDVRClasses[]
	];*)


(* ::Subsubsection::Closed:: *)
(*Loading*)



ChemDVRClass::noclass="No class template found at ``";
ChemDVRClass[f_String?(FileExistsQ)]:=
	With[{a=
		If[ExpandFileName[f]==
				ExpandFileName@ChemDVRFile["Classes",FileNameTake@f],
			ChemDVRNeeds@FileBaseName@f,
			ChemDVRNeeds@f
			]},
		If[AssociationQ@a,
			If[ExpandFileName[f]==
					ExpandFileName@ChemDVRFile["Classes",FileNameTake@f],
				ChemDVRClass[Append[a,"Class"->FileBaseName@f]],
				ChemDVRClass[a]
				],
			Message[ChemDVRClass::noclass,f];$Failed
			]
		];
ChemDVRClass[f_String?(Not@*FileExistsQ)]:=
	(If[FileExistsQ@#,
			ChemDVRClass@#,
			Message[ChemDVRClass::noclass,#];$Failed])&@
		ChemDVRFile["Classes",StringTrim[f,".m"]<>".m"];


(* ::Subsubsection::Closed:: *)
(*Instantiation*)



ChemDVRClass[a_Association][ops___Rule]:=
	ChemDVRCreate[Join[a,<|ops|>]];
ChemDVRClass[a_Association][range:{{_?NumericQ,_?NumericQ}..}]:=
	ChemDVRClass[a]["Range"->range];
ChemDVRClass[a_Association][points:{__Integer?Positive}]:=
	ChemDVRClass[a]["Points"->points];
ChemDVRClass[a_Association][
	points:{__Integer?Positive},
	range:{{_?NumericQ,_?NumericQ}..}]:=
	ChemDVRClass[a]["Points"->points,"Range"->range];
ChemDVRClass[a_Association][
	range:{{_?NumericQ,_?NumericQ}..},
	points:{__Integer?Positive}
	]:=
	ChemDVRClass[a][points,range]


(* ::Subsubsection::Closed:: *)
(*Template*)



$ChemDVRClassTemplate=
	With[{sn=ToBoxes@Placeholder["Name"]},
	Notebook[{
		Cell[
			TextData@{Cell[BoxData@ToBoxes@Placeholder["LongName"]]," ","DVR"}, 
			"CodeSection"],
		Cell[TextData@{Cell[BoxData@ToBoxes@Placeholder["Description"]]},"Text"],
		Cell[BoxData@"ChemDVRBegin[];","InputSection"];
		Cell[
			BoxData@{
				RowBox[{
					RowBox[{RowBox[{sn,"FormatGrid"}],"::","usage"}],"=","\"\""}],"\n",
				RowBox[{
					RowBox[{RowBox[{sn,$dvrgr}],"::","usage"}],"=","\"\""}],"\n",
				RowBox[{
					RowBox[{RowBox[{sn,$dvrke}],"::","usage"}],"=","\"\""}],"\n",
				RowBox[{
					RowBox[{RowBox[{sn,"PotentialEnegy"}],"::","usage"}],"=","\"\""}],"\n",
				RowBox[{
					RowBox[{RowBox[{sn,$dvrwf}],"::","usage"}],"=","\"\""}],"\n",
				RowBox[{
					RowBox[{RowBox[{sn,"View"}],"::","usage"}],"=","\"\""}]
				},
				"CodeInput"],
		Cell[BoxData@RowBox[{RowBox[{"Begin","[","\"`Private`\"","]"}],";"}],
			"InputSection"],
		Cell["Grid Formatting Function", "CodeSubsubsection"],
		Cell[
			"This function should take a grid and the grid points used to generate the grid.",
			 "Text"],
		Cell[BoxData@
			RowBox[{
				RowBox[{RowBox[{sn,"FormatGrid"}],"[",RowBox[{"grid_",",","points_"}],"]"}],
				":=","\n\t",
				ToBoxes@Placeholder["FormatGrid Function"]}],
			"CodeInput"
			],
		Cell["Grid Function", "CodeSubsubsection"],
		Cell[
			"This function should take the number of grid points for each coordinate",
			 "Text"],
		Cell[BoxData@
			RowBox[{
				RowBox[{RowBox[{sn,$dvrgr}],"[",RowBox[{"points_",",","range_"}],"]"}],
				":=","\n\t",
				ToBoxes@Placeholder["Grid Function"]}],
			"CodeInput"
			],
		Cell["Kinetic Energy Function", "CodeSubsubsection"],
		Cell[
			"This should take the grid generated previously",
			 "Text"],
		Cell[BoxData@
			RowBox[{
				RowBox[{RowBox[{sn,$dvrke}],"[",RowBox[{"grid_"}],"]"}],
				":=","\n\t",
				ToBoxes@Placeholder["KineticEnergy Function"]}],
			"CodeInput"
			],
		Cell["Potential Energy Function", "CodeSubsubsection"],
		Cell[
			"This should take the grid generated previously",
			 "Text"],
		Cell[BoxData@
			RowBox[{
				RowBox[{RowBox[{sn,$dvrpe}],"[",RowBox[{"grid_"}],"]"}],
				":=","\n\t",
				ToBoxes@Placeholder["PotentialEnergy Function"]}],
			"CodeInput"
			],
		Cell["Wavefunctions Function", "CodeSubsubsection"],
		Cell[
			"This should take the kinetic and potential energies generated previously",
			 "Text"],
		Cell[BoxData@
			RowBox[{
				RowBox[{RowBox[{sn,$dvrwf}],"[",RowBox[{"T_","V_"}],"]"}],
				":=","\n\t",
				ToBoxes@Placeholder["Wavefunctions Function"]}],
			"CodeInput"
			],
		Cell["View Function", "CodeSubsubsection"],
		Cell[
			"This should take the wavefunctions, grid and potential energies",
			 "Text"],
		Cell[BoxData@
			RowBox[{
				RowBox[{RowBox[{sn,"View"}],"[",RowBox[{"wfs_","grid_","V_"}],"]"}],
				":=","\n\t",
				ToBoxes@Placeholder["View Function"]}],
			"CodeInput"
			],
		Cell[BoxData@RowBox[{RowBox[{"End","[","]"}],";"}],
			"InputSection"],
		Cell[
			BoxData@RowBox[{"<|","\n","\t",
				RowBox[{
					RowBox[{"\"Name\"","\[Rule]",RowBox@{"\"",ToBoxes@Placeholder["Name"],"\""}}],
						",","\n","\t",
					RowBox[{"\"Dimension\"","\[Rule]",ToBoxes@Placeholder["Dimension"]}],
						",","\n","\t",
					RowBox[{"\"FormatGrid\"","->",RowBox[{sn,"FormatGrid"}]}],
						",","\n","\t",
					RowBox[{"\"Grid\"","->",RowBox[{sn,$dvrgr}]}],
						",","\n","\t",
					RowBox[{"\"KineticEnergy\"","->",RowBox[{sn,$dvrke}]}],
						",","\n","\t",
					RowBox[{"\"PotentialEnergy\"","->",RowBox[{sn,$dvrpe}]}],
						",","\n","\t",
					RowBox[{"\"Wavefunctions\"","->",RowBox[{sn,$dvrwf}]}],
						",","\n","\t",
					RowBox[{"\"View\"","->",RowBox[{sn,"View"}]}]}],
					"\n","\t","|>"}],
			"CodeInput"
			],
		Cell[BoxData@"ChemDVREnd[];","InputSection"],
		Cell["","SectionSeparator"]
		},
		StyleDefinitions->
			FrontEnd`FileName[{"ChemTools","Private"},"NewDVRClass.nb"]
		]
		];


(* ::Subsubsection::Closed:: *)
(*New*)



Options[ChemDVRNewClass]={
	"LongName"->None,
	"Description"->None,
	"Name"->None,
	"Dimension"->None
	};
ChemDVRNewClass[ops:OptionsPattern[]]:=
	With[{
		name=
			Replace[OptionValue["Name"],
				s_String:>StringTrim[StringReplace[s,Except[WordCharacter]->""],"DVR"]<>
					"DVR"
				],
		ln=Replace[OptionValue["LongName"],None->OptionValue["Name"]],
		desc=OptionValue["Description"],
		dim=OptionValue["Dimension"]
		},
		With[{reps=
			{
				If[name===None,
					Nothing,
					Sequence@@{
						RowBox@{ToBoxes@Placeholder["Name"],s_}:>
							(name<>s),
						RowBox@{s1_,ToBoxes@Placeholder["Name"],s2_}:>
							s1<>name<>s2
						}
					],
				If[ln===None,
					Nothing,
					ToBoxes@Placeholder["LongName"]->ln
					],
				If[desc===None,
					Nothing,
					ToBoxes@Placeholder["Description"]->desc
					],
				If[dim===None,
					Nothing,
					ToBoxes@Placeholder["Dimension"]->dim
					]
				}
			},
			CreateDocument@
				If[Length@reps===0,
					$ChemDVRClassTemplate,
					If[name===None,
						ReplaceAll[$ChemDVRClassTemplate,reps],
						Append[ReplaceAll[$ChemDVRClassTemplate,reps],
							"WindowTitle"->name
							]
						]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Begin*)



ChemDVRBegin[context_:""]:=
	If[$Context=!=Context[ChemDVRBegin],
		BeginPackage[Context[ChemDVRBegin]];
		$ContextPath=
			Join[$ContextPath, $PackageContexts]
		];


(* ::Subsubsection::Closed:: *)
(*End*)



ChemDVREnd[]:=
	If[$Context===Context[ChemDVRBegin],
		EndPackage[]
		];


(* ::Subsubsection::Closed:: *)
(*Needs*)



If[Not@AssociationQ@$ChemDVRLoaded,
	$ChemDVRLoaded=<|
		
		|>
	];


chemDVRGet[f_String?(FileExistsQ)]:=
	Block[
		{
			$ContextPath=Prepend[$PackageContexts, "System`"],
			CircleTimes
			},
		Replace[Get@f/.CircleTimes->Inactive[CircleTimes],
			{
				c_Association:>
					Set[$ChemDVRLoaded[f],
						Append[c,"File"->f]
						],
				_->$Failed
				}]
		];


ChemDVRNeeds[f_String?(FileExistsQ)]:=
	Lookup[$ChemDVRLoaded,f,
		chemDVRGet[f]
		];
ChemDVRNeeds[f_String?(Not@*FileExistsQ)]:=
	Lookup[$ChemDVRLoaded,f,
		Lookup[$ChemDVRLoaded,ChemDVRFile["Classes",StringTrim[f,".m"]<>".m"],
			chemDVRGet@ChemDVRFile["Classes",StringTrim[f,".m"]<>".m"]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Reload*)



ChemDVRReload[s_String]:=(
	If[KeyMemberQ[$ChemDVRLoaded,s],
		$ChemDVRLoaded[s]=.,
		$ChemDVRLoaded[ChemDVRFile["Classes",StringTrim[s,".m"]<>".m"]]=.
		];
	ChemDVRNeeds@s
	);


PackageAddAutocompletions[
	"ChemDVRReload",
	List@ChemDVRClasses[]
	];


(* ::Subsubsection::Closed:: *)
(*Formatting*)



$dvrclassimg=
	Graphics[
		{
			Inset[
				Graphics[
					First@#/._Opacity->Opacity[.1],
					{
						ImageSize->{28,28},
						AspectRatio->Full,
						Method->{"ShrinkWrap"->True},
						PlotRange->{{-3,3},{-0,20}}
						}
					]
				],
			Inset[
				Graphics[
					{
						GrayLevel[.2],
						First@#2
						},
					{
						ImageSize->{28,28},
						AspectRatio->Full,
						Method->{"ShrinkWrap"->True}
						}
					]
				]
			},
		Background->GrayLevel[.95],
		FrameStyle->GrayLevel[.8],
		Frame->True,
		FrameTicks->False,
		ImageSize->{32,32}
		]&[$dvrimg,Graphics[{FilledCurve[Line[CompressedData["
1:eJxN2HmUjlUYAPCPKESLZA2p7Eu2SNkqRFkiZUnJUimyRCkqS7utVWTLvu+M
GWPGNjPGjNlnrNG+bySihN73zM85/XG/3/ne8533ufd7nvfe994q/Yd1G1ow
Eom0Dz5Co4J2qEAksoXRjOFWxnIb4xjP7dzBndzF3UxgIpO4h8ncyxSmch/T
mM4MZjKL2cxhLvO4P/AgD3A/85jLHGYzi5nMYDrTuI+pTOFeJnNP4IHAJCYy
gbu5izu5g9sZzzhuYyy3MobR3MIobuYmbuQGruc6ruUaruYqrgw8GLiCy7mM
S7mEi7mIC7mA8/kp53Eu53A2Z/ETzuQMfszp/Igf8gO+z/f4buChwGmcyimc
zEl8h2/zLb7JN/g6X+NETuB4juOrfIUvcyzH8CW+yNF8gc9zVODhwJF8jiM4
nMM4lM9yCAfzGT7NQXyKT/IJDuQA9mc/Ps6+fIyPsg8fYW/2CjwS2JM9+DAf
Ync+yG7sygfYhZ3ZiR15P+9jB7bnvWzHtmzDe3g372JrtmLLwM8CW7A57+Qd
bMbb2ZRNeBsbsxEbsgHr81bWY13WYW3WYk3WYHVWY1Xewpt5U+DRwCq8kZVZ
iRV5AyuwPMuxLMuwNK9nKV7HkryW1/BqXsUSLM4rWYxFWYRXBB4LvJyFWYiX
sSALMMKLkXwv8Dz/5Tn+w795lmf4F0/zFP/kSf7BEzzO3/kbfw3a50H7hT/z
J/7IH/g9v+O3/IZf8yt+yS94qR3jUX7GIzzMQzzIA9zPPOaKkeN7thhZYmSJ
kS1Gthg5YuSIkStGrhh5/2uXruUw22+zmOkeGUx37zTuEzNVH1K4V9+SuUef
k5hoLAncbYy7uNPYd3C7/z2ecfKxjbHytFXeYhgtn1sYJc+buSmSn/+N3BDJ
r4v1XBfJr5e1XBPJr6PVXBXJr6+Vkfx6Cw3rb0Ukvx5Df3f9OE/wD57knzzF
0/yLZ3iWf/MfnuO/PM8LvMjw+Q0twIK8jIVYmJcznC/C8RZhURbjlSzOEryK
V/MaXsuSvI6leD1LswzLshzLswJvYEVWYmWG83eYvyq8iTfzFlZlNVZnDdZk
LdZmHdZlPd7K+mzAhmzExryNTdiUt7MZw/U1rMs72Zwt2JKt2Jp38W7ewzZs
y3a8l+3ZgffxfnZkJ3ZmFz7AruzG8H0nfM668yE+zB7syV7szUfYh4/yMfbl
4+zH/hzAgXyCT/IpDuLTfIaDOYTh+2g4fwzlMA7nCD7HkRzF5/kCR/NFvsQx
HMuX+Qpf5TiO5wRO5Gt8nW8w3B+E8+FbfJvvcBIncwqnchrf5Xt8nx/wQ37E
6fyYMziTn3AWZ3MO53Iew/1aOL/P5wIu5CIu5hIu5TIu5wqu5Cqu5hqu5Tqu
5wZu5CZuZhS3MJoxDPfT4boVy22MYzy3cwd3chd3M4GJTOIeJnMvU5jKfUxj
OjOYySxmMzzfCNfhXOZxP8PzkXC9Ds9LLp0b/QdyegDz
"]]], FilledCurve[Line[CompressedData["
1:eJxN12W3VVUUBuAFUhICUoL0Renu7hYR2PvQ3SghZdChNAapoDTSgv4Ru7u7
W1H3Gvth6Ic5ng933BNrve88YzeYsXj0ouIhhKvFQoi2yHw2m+bZPJNNs2yu
8DKf5iVe5AWe5zme5ZlsmmbzFE/zFE/yBI/zGI/yCJ/kEzzMQ3ycj/EgD3A/
93Ev9/DRbJpk8wgf5kPczV3cyR3czm3cyi18kA9wMzdxIzdwPddxLddk0zib
1VzF+3kf7+U9XMkVXM5lXMq7uYSLuYgLeRfv5ALO57xsbs1mLudwNmdxJmdw
OqdxKqdwMidxIidwPMdxLAtMmXAMR2dzSzajeAdH8naO4G0czmEcyiEczEEc
yAHsz37syz7szV7smU2jbHqwO7uxK7uwMzuxIzuwPduxLduwNVuxJVuwOZux
KZswZqHIGRf5DkX+VvS/acgGrM96rMs6rM2bWYs1eRNrsDqrsSqr8EafoTIr
sSJvYAWWZzmW5fUsw9IsxZIswetYnMUY+E/I/ZtX+VfIz+pP/sHf+Rt/5S/8
mT/xR/7A7/kdv+U3/Nr7f8UvQ35+X4T8Tj8P+R1/FvI7j8YMfBryTERjRj4J
eWaiMUMf+z2Kxox9FPLMRWMGPwx5JqMxox+EPLPRmOH3Q57paMz4eyHPfDR2
4N2Qd+KdkHckGjvzdsg7FI2deivkHYvGzr0Z8g5GYyffCHlHo7Gzr4e8w9HY
6ddC3vFo7PyrId8B0bgTXgn5jojGnfFyyHfISyHfKdG4Y14M+c6Jxh30Qsh3
UjTuqOdDvrOicYc9F/KdFk1Z8PeC/yt4vYL3KXj/gs9T8DkLPn/qe6W+b+oc
UueTOrfUeabOOXXuqftI3VPq/lL3mrrvVA5S+UjlJpWnVL5SeUvlL5XHVD4T
eU3kN5HnRL4TeU/kP9GHRD8SfUn0J9GnRL8SfUv0L9HHRD8TfU30N9HnaHHG
vsf7KsGSLMXSLMPrWZblWJ4VeAMrshIr80ZWYVVWY3XWYNyfMV81WYs3szbr
sC7rsT4bsCGL2KjYf7+50Wu/wY3ZhE3ZjM3Zgi0Zd0XsRWu2YVu2Y3t2YEd2
Ymd2YVd2Y3f2YE/2Ym/2YV/2Y9wVsccDOJCDOJhDOJTDOJy3cQRv50hem1Ec
zTFMmLLAsRzH8V5zAidyEidzCqdyGqdzBmdyFmdzDudyHudzAe/kXVzIRc5g
MZfwbi7lMi7nCq7kPbyX9/F+ruJqruFaruN6buBGbuJmd/cAH+QWbuU2bucO
7uQu7uZDfJiP8FHu4V7u434e4EHG56mYtcd5iIf5BJ/kER7lMR7nCZ7kKZ7m
UzzDszzH87zAi7zE+LwaO3KZVxifb2OH4vPuUA7hYA7iQA5gf/ZjX/Zhb/Zi
T/Zgd3ZjV3ZhZ3ZiR3Zge7ZjW7Zha7ZiS157vv8X4eR7WA==
"]]], FilledCurve[Line[CompressedData["
1:eJxV3HV8VVe2AODTTmemU5lO3acydXekAgR3J7i7JPhNCCE4F3d3h1JKKS3u
rnVXqLuN63us5ru/ee+P+/vITXLvOXuvtfbOWYd7Q9vcejlnJkly3jlJEl50
+vHT6ceFpx8/8gd+z+/4Lb/h1/yKX/ILfs7P+Ck/4cf8iKd4kh/yA77P9/gu
3+HbfItv8g2+ztf4Kl/hy3yJL/IFnuBxHuNRHuFhHuJBHuB+7uNe7uFu7uJO
7uB2buNWbuFmbuJGPs/nuIHPcj2f4To+zbV8imv4JFdzFVdyBZdzGZdyCRdz
ERdyAedzHudyDmdzFmdyBqdzGqdyCidzEidyAsdzHMdyDEczzVEcyREczmEc
yiEczCIOYiEHsoADmM88ptif/diXfdibvdiTucxhD3ZnN3ZlF3ZmJ3ZkB7Zn
O7ZlG7ZmK7ZkCzZnMzZlEzZmNhuxIRuwPuuxLuuwNmuxJmuwOquxKquwMiux
IiuwPLNYjmVZhk/wcT7GR1mapViSJfgIH+ZDfJAP8H7ex3t5D+/mXbwzKV4/
7jj9uPj04/bTj0tOP247/biUl/FyXsEreRWv5jW8lr/ndbyeN/BG/oE38Wbe
wluZedzOO3gn7+LdvIf38j7ezwf4IEuYz5IsxdJ8lI/xcT7BMizLcsw8yrMC
K7ISK7MKq7Iaq7MGa7IWa7MO67Ie67MBG7IRs9mYTdiUzdicLdiSrdiabdiW
7dieHdiRndiZXdiV3didPZjDXPZkL/ZmH/ZlP/ZninnM5wAWcCALOYhFHMwh
HMphHM4RHMlRTHM0x3Asx3E8J3AiJ3Eyp3Aqp3E6Z3AmZ3E253Au53E+F3Ah
F3Exl3Apl3E5VzD2HJEjqxh7kgqsyEqszCqsymqszhqsyVqszTqsy3qszwZs
yEbMZmM2YVM2Y3O2YEu2Ymu2YVu2Y3t2YEd2Ymd2YVd2Y3f2YA5z2ZO92Jt9
2Jf92J8p5jGfA1jAgSzkIBZxMIdwKIdxOEdwJCNXIk4iV1ZyBZdzGZdyCRdz
ERdyAedzHudyDmdzFmdyBqdzGqdyCidzEidyAsdzHMdyDEcz8xjFkRzB4RzG
oRzCwSziIBZyIAs4gPnMY4r92Y992Ye92Ys9mcsc9mB3dmNXdmFndmJHdmB7
tmNbtmFrtmJLtmBzNmNTNmFjZrMRG7IB67Me67IOa7MWa7IGq7Maq7IKK7MS
K7ICyyf/XVPCcizLMnyCj/MxPsrSLMWSLMFH+DBjrxqxGfurkRzB4RzGoRzC
wSziIBZyIAs4gPnMY4r92Y992Ye92Ys9mcsc9mB3dmNXdmFndmJHdmB7tmNb
tmFrtmJLtmBzNmNTNmFjZrMRG7IB67Me67IOa7MWa7IGq7Maq7IKK7MSIzYj
LiI2I04iNiNusjx/m+dv83xYgiVZiqX5KB/j43yCZViW5ZjF8qzAiqzEyqzC
qqzG6qzBmqzF2qzDuqzH+mzAhmzEbDZmEzZlMzZnC7ZkK7ZmG7ZlO7ZnB3Zk
J3ZmF3ZlN3ZnD+Ywlz3Zi73Zh33Zj/2ZYh7zOYAFHMhCDmIRB3MIh3IYh3ME
R3IU0xzNMRzLcRzPCZzISZzMKZzKaZzOGZzJWZzNOZzLeZzPBVzIRVzMJVzK
ZVzOFVzJVVzNJ7mGT3Etn+Y6PsP1fJYb+Byf50Zu4mZu4VZu43bu4E7u4m7u
4V7u434e4EEe4mEe4VEe43Ge4At8kS/xZb7CV/kaX+cbfJNv8W2+w3f5Ht/n
B/yQJ3mKH/FjfsJP+Rk/5xf8kl/xa37Db/kdv+cP/JE/8Y/8E//Mv/Cv/Bv/
zn/wn/wX/83/8H+YnFHsGTyTv+BZ/CV/xV/zbP6G5/Bcnsfz+VtewN/xQl7E
i3kJL+VlvJxX8Epexat5Da/l73kdr+cNvJF/4E28mbfwVt7G23kH7+RdvJv3
8F7ex/v5AB/kQ3yYj7AES7IUS/NRPsbH+QTLsCzLMYvlWYEVWYmVWYVVWY3V
WYM1WYu1WYd1WY/12YAN2YjZbMwmbMpmbM4WbMlWbM02bMt2bM8O7MhO7Mwu
7Mpu7M4ezGEue7IXe7MP+7If+zPFPOZzAAs4kIUcxCIO5hAO5TAO5wiO5Cim
OZpjOJbjOJ4TOJGTOJlTOJXTOJ0zOJOzOJtzOJfzOJ8LuJCLuJhLuJTLuJwr
uJKruJpPcg2f4lo+zXV8huv5LDfwOT7PjdzEzdzCrdzG7dzBndzF3dzDvdzH
/TzAgzzEwzzCozzG4zzBF/giX+LLfIWv8jW+zjf4Jt/i23yH7/I9vs8P+CFP
8hQ/4sf8hJ/yM37OL/glv+LX/IbfnlHco/mO359R3KsJ7+RdvJv38F7ex/v5
AB/kQ3yYj7AES7IUS/NRPsbH+QTLsCzLMYvlWYEVWYmVWYVVWY3VWYM1WYu1
WYd1WY/12YAN2YjZbMwmbMpmbM4WbMlWbM02bMt2bM8O7MhO7Mwu7Mpu7M4e
zGEue7KXfOrD3sw835O5zGEPdmc3dmUXdmYndmQHtmc7tmUbtmYrtmQLNmcz
NmUTNmY2G7EhG7A+67Eu67A2a7Ema7A6q7Eqq7AyK7EiI86Pi/tjPCofjvAw
D/EgD3A/93Ev93A3d3End3A7t3Ert3AzN3Ejn+dz3MBnuZ7PcB2f5lo+xTV8
kqu5iiu5gsu5jEu5hIu5iAu5gPM5j3M5h7M5izM5g9M5jVM5hZM5iRM5geM5
jmM5hqOZ5iiO5AgO5zAO5RAOZhEHsZADWcABzGceU+zPfuzLPuzNXuzJXOaw
B7uzG7uyCzuzEzuyA9uzHduyDVuzFVuyBZuzGZuyiXxsLE+z5W22PM6W19ny
PFveh9VYnTVYk7VYm3VYl/VYnw3YkI2YzcZswqZsxuZswZZsxdZsw7Zsx/bs
wI7sxM7swq7sxu7swRzmsid7sTf7sC/7sT9TzGM+B7CAA1nIQSziYA7hUA7j
cI7gSHExSpykxU1aHKXFVVqcpcVdWhymxWVanKbFbVocp8V1WpynxX1aHqTl
RVqepOVNWh6l5VVanqXlXVoepuVlWp6m5W1aHqfldVqeh/2ZYh7zOYAFHMhC
DmIRB3MIh3IYh3MER3IU0xzNMRzLcRzPCZzISZzMKZzKaZzOGZzJWZzNOZzL
eZzPBVzIRVzMJVzKZVzOFVzJVVzNJ7mGT3Etn+Y6PsP1fJYb+Byf50Zu4mZu
4VZu43bu4E7u4m7u4V7u434e4EEe4mEe4VEe43GekKcn5O0JeXxCXp+Q5yfk
fTiEg1nEQSzkQBZwAPOZxxT7sx+jrsU+vDf7MPN8P/ZninnM5wAWcCALOYhF
HMwhHMphHM4RHMlRTHM0x3Asx3E8J3AiJ3Eyp3Aqp3E6Z3AmZ3E253Au53E+
F3AhF3Exl3Apl3E5V3AlV3E1n+QaPsW1fJrr+AzX81lu4HOMXk38nR+9mm8Z
1wGiZ/M14zpB9G6+ZFxHiB7O54zrDNHL+ZRxHSJ6Oh8zrlNEb+cU4zpG9Hg+
ZFzniF7P+4zrINHzeZdxnWR3UnzdJIzrKHuS4usqYVxniV5QXHeJXtBrjOsy
0RN6hXHdJnpDL/HFM4p7RC8w8uWQvA4jzw8nxXkfRh2I3tFhRp2IHtJBRh2J
XtJ+Rp2JntJeRh2K3tJuRp2KHtNORh2LXlPUteg1bWPUveg5bWHUxeg9bWLU
zehBPc+oq9GL2sCou9GTWs+oy9GbWseo29GjWsuo69GrWsOo+9GzWs1YF6J3
tZKxbkQPazljXYle1lLGuhM9rViHoqe1iLFORW9rAWMdO5kUr2thrHOnkuJ1
L4x1MHpesxjrZPS+ZjDW0eiBTWOss9ELm8JYh6MnNomxTkdvbAJjHf8iKV7X
w1jno1c2hrEPiJ5Z7AuiZzaKsW+I3tkIxr4iemjDGPuO6KUNYexLoqdWxNi3
RG+tkLGviR5bAWPfE722fOYx5fspv5fyeinvk/L+KceVcrwp55FyXinnmzIO
KeOTMm4p45kyzinjnzIvKfOVMo8p85sy7ylxkBIfKXGTEk8pcZYSfylxmRKv
KXGcEt8pcZ+SDyl5kpI/KfmUkmcp+ZeSlyn5mpLHKfkdHuJBHuB+7uNe7uFu
7uJO7uB2buNWbjGfm30d9Tb2wVGH+7Gv5/uwt5/vxZ5eJ9fr5rCH9+vObo6j
K7s4vs7s5Lg7soPzac92zrMt2zj/1mxlXFqyhfFqzmbGsSmbGN/GzDbujdjQ
fDQwP/VZz7zVZR3zWZu1zHNN1jD/1VlNXFRlFfFSmZXEUUVWEF/lmSXuyrGs
eCzDJ8Tp43xM/D4qnkuzlDgvyRLi/xE+LC8e4oPy5QHeL4/u473y6x7eLe/u
4p3y8Q7eLk9v463y9xbeLK9vYvSZTyXFfefI/xsYfemoC9cx+tZRL65l9LWj
jlzN6HtHfbmS0RePunM5o28e9ehSRl896tTFjL77z//vkdGXj7p2AaNvH/Xu
fEZfP+rguYy+f9THuA8g6uXZjPsEoo7+inEfQdTXsxj3GUTdPZNnMPH9xO8l
Xi/xPon3TRxP4jgTx584r8T5JsYhMT6JcUuMZ2KcE+OfmJfEPCXmLzGviflO
xEEiPhJxk4inRJwl4i8Rl4l4TcRxIq4T8Z7Ig0R+JPImkU+JPEvkXyIvE/ma
yONEfoeHeJAHuJ/7uJd7uJu7uJM7uJ3buJVbzOdmX0edjftONjLt+bSfS4uD
8Bc8i7/kr/hrns3f8Byey/N4Pn/LC/g7XsiLeDEv4aW8jJfzCl7Jq3g1r+G1
/D2v4/W8gTfyD7yJN/MW3srbeDvv4J28i3fzHt7L+3g/H+CDfIgP8xGWYEmW
YmlGXR7FkRzB4RzGoRzCwSziIBZyIAs4gPnMY4r92Y992Ye92Ys9mcsc9mB3
dmNXdmFndmJHdmB7tmNbtmFrtmJLtmBzNmNTNmFjZrMRG7IB67Me67IOa7MW
a7IGq7Maq7IKK7MSK7KCOCkvbsqLoyxxlSXOssRdljjMEpdZ4jRL3GaJ4yxx
nSXOs8R9ljzIkhdZ8iRL3mTJoyx5lSXPsuRdljzMkpdZ8jRL3mbJ4yx5nSXP
w2t5Da/mVbySV/ByXsZLeQkv5kW8kL/jBfwtz+d5PJfn8Dc8m7/mr/hLnsVf
8EyewYRR18P/8N/8F//Jf/Dv/Bv/yr/wz/wT/8if+CN/4Pf8jt/yG37Nr/gl
v+Dn/Iyf8hN+zI94iif5IT/g+3yP7/Idvs23+Cbf4Ot8ja/yFb7Ml/giX+AJ
HucxHuURHmbsESIfY48QeRp7hIqsxMqswqqsxuqswZqsxdqsw7qsx/pswIZs
xGw2ZhM2ZTM2Zwu2ZCu2Zhu2ZTu2Zwd2ZCd2Zhd2ZTd2Zw/mMJc92Yu92Yd9
2Y/9mWIe8zmABRzIQg5iEQdzCIdyGIdzBGMdj7iIdT3i5Ofr+TzCozzG4zzB
F/giX+LLfIWv8jW+zjf4Jt/i23yH7/I9vs8P+CFP8hQ/4sf8hJ/yM37OL/gl
v+LX/Ibf8jt+zx/4I3/iH/kn/pl/4V/5N/6d/+A/+S/+m//5P270/CY/t8nv
bfY6m73uFu+zxftudRxbHdc2x7nNcW93Htud1w7nucN57zQOu4zLLuO027jt
No57jOse47zXuO81D/vMyz7ztN+87TePB8zrAfMcsfshIw4iht9nxEnE8ruM
OIqYfpsRZxHbbzLiMGI84jJi/DVG3Easv8KI64j5l/iiR+bfJ3zvOI/5naM8
4rUO85D3OMgD3ns/9zmmvdzjWHdzl3PYyR3Obbtz3catxmALNxubTdxozJ7n
c8ZyA581xuv5jLFfx6fNyVo+Za7W8ElzuJqrzO1KRm8n5nw5o/cTsbCUS5Li
GFmcFMfMIkYvKWJpAaPXFDE2j9GLitibw+hVRUzOYvSyIlZnMHpdEcPTGL2w
iO0p/LlXluidJcW9tMiFCYxeW+TIOEYvLnJnDEcn/60JmRqRqRmZGpKpKZka
k6k5mRqUqUmZGpWpWZkalqlpmRqXqXmZGpipiZkaeTL5/zU0U1MzNTZTczM1
OFOTMzU6U7MzNTxT0zM1PlPzM2tAZk3IrBGZNSOzhmTWlMwak1lzMmtQZk3K
rFGZNSuzhh3kAe7nPu7lHu7mLu7kDm7nNm7lFvO52deRS7GWRi6N9PUIDvdz
wzjU7w/hYK9bxEHer5ADHUcBBzi+fOY57hT7O59+7Os8+7C38+/FnsYl1zjl
sIfx687MXiizN+pivDuzk3noyA7mpz3bmbe2bGM+W7OVeW7J2OvF/Dfnz/eY
Ju4xTYr3ihEvjRl7yYijRoy9ZsRX7D0j3uoz9qYRh3UZe9eIz9qMvW3EbU3G
3jfiuTpjbxxxXpVVkuL4r8zYW0deVGTsvSNfyif//Rsh8qgcyybF+VWGca92
5N3jjHu5Ix/j3u7Iz9KMe78jb0sy7g0/mRTfKx7GveOR5w8x7i2P/H+Ace95
1IX7GPemR724h3HvetSRuxj3tkd9uYNx73vm/86F8TlGUY9u4c1JcZ26ifE5
SFG/bkyK69kNvD4prnPXMT5XKerftYzPXYq6eDXjc5miXl7J+NymqKOXMz7X
KerrpYzPfYq6ezEznyv4v0iNm28=
"]]]}, ImageSize -> {52.1640625, Automatic}]];


Format[ChemDVRClass[a_Association]]:=
	RawBoxes@
		BoxForm`ArrangeSummaryBox[
			"ChemDVRClass",
			Lookup[a,"Icon",ChemDVRClass@a],
			$dvrclassimg,
				{
					BoxForm`MakeSummaryItem[{"Name: ",Lookup[a,"Name"]},StandardForm]
					},
			KeyValueMap[
				BoxForm`MakeSummaryItem[{Row@{#,": "},#2},StandardForm]&,
					KeySelect[a,MatchQ[Except["Name"]]]
				],
			StandardForm
			];


End[];



