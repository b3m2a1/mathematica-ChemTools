(* ::Package:: *)

(* This is a conveniece file so Needs["App`Pkg`"] can be used *)
BeginPackage[
   StringRiffle[
     Flatten[{
        StringSplit[
          FileBaseName[Nest[DirectoryName, $InputFileName, 3]],
          "-"
          ][[1]],
        FileNameSplit[
          FileNameTake[
            StringTrim[$InputFileName, ".wl"],
            -3
            ]
          ],
        ""
      }],
    "`"
    ],
   StringSplit[
    FileBaseName[Nest[DirectoryName, $InputFileName, 3]],
    "-"
    ][[1]]<>"`"
  ];
EndPackage[]

FrontEnd`Private`GetUpdatedSymbolContexts[]