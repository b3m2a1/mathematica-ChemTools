(* This is a convenience file to load all of the packages in this app *)
Map[
  Function[
    BeginPackage[
      StringSplit[
        FileBaseName[DirectoryName@$InputFileName],
        "-"
        ][[1]]<>"`"<>#<>"`",
      StringSplit[
        FileBaseName[DirectoryName@$InputFileName],
        "-"
        ][[1]]<>"`"
      ];
    EndPackage[]
    ],
  {
    "Data",
    "DVR",
    "Experimental",
    "Objects",
    "OpenBabel",
    "Psi4",
    "SP",
    "Utilities"
    }
  ]

FrontEnd`Private`GetUpdatedSymbolContexts[]
