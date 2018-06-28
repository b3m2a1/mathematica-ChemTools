<a id="chemtools" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# ChemTools

ChemTools implements a suite of chemistry-oriented functionality, including a simple data framework, an object-oriented chemical modeling system, and a number of computational utilities on raw sets of atom and bonded systems

---

<a id="installation" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

## Installation

The easiest way to install  ```ChemTools```  is using a paclet server installation:

```mathematica
PacletInstall[
  "ChemTools",
  "Site"->
    "http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
  ]
```

If you've already installed it you can update using:

```mathematica
PacletUpdate[
  "ChemTools",
  "Site"->
    "http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
  ]
```

Alternately you can download this repo as a ZIP file and put extract it in  ```$UserBaseDirectory/Applications```

---

<a id="packages" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

## Packages

ChemTools supports a large number of packages. At present it has a few core packages:

* Compute —
 a package for computing molecular properties, such as symmetry elements and point groups

* Data —
 a data framework for accessing custom data sources and the like

* DVR —
 a package for creating discrete variable representations

* Extensions —
 a package of hook-ins to other pieces of software that extend on the basic ChemTools functionality

* Formats —
 a package for converting between molecule representations

* Graphics —
 a package for displaying molecules in a flexible fashion

* Import —
 a collection of importers for various file formats

* Objects  —
 an object oriented chemical modeling package that interfaces with the other parts of the system

* Utilities —
 a set of utilities for doing specialized operations

* WSim —
 a package of compiled walker (or timestep) based simulators

More info can be found on the  [Wiki](https://github.com/b3m2a1/mathematica-ChemTools/wiki)