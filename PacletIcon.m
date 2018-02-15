If[!ImageQ@ChemTools`Private`$PacletImage,
 ChemTools`Private`$PacletImage=
  Import[FileNameJoin@{DirectoryName[$InputFileName], "PacletIconBig.png"}]
 ];
Pane[ChemTools`Private`$PacletImage, 32]
