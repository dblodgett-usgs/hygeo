# hygeo

![R-CMD-check](https://github.com/dblodgett-usgs/hygeo/workflows/R-CMD-check/badge.svg) [![codecov](https://codecov.io/gh/dblodgett-usgs/hygeo/branch/master/graph/badge.svg?token=obf9f7dtrw)](https://codecov.io/gh/dblodgett-usgs/hygeo)

installation: `remotes::install_github("dblodgett-usgs/hygeo")`

This R package is part of the Next Generation Water Modeling Engine and Framework Prototype project taking place here: https://github.com/NOAA-OWP/ngen

![Example Image](https://github.com/dblodgett-usgs/hygeo/raw/master/docs/img/map.png)  

## Hydrologic and Hydrodynamic Graphs:
At the top level we have a hydrologic graph of catchments and nexuses and a hydrodynamic graph of waterbodies that “pins” to the catchment graph at nexuses and hydrologic locations along flowpaths. 

Both catchments and nexuses should be thought of as labeled nodes with unlabeled directed edges between. 

Any catchment node of degree 1 with an outward edge is a headwater and degree 1 with an inward edge is an outlet. 

Any catchment node of degree 2 is a typical catchment that may have a coincident set of (one or more) waterbodies in the waterbody graph.

Using this graph scheme, headwater catchments contribute either to the upstream end of a flowpath or to the shore of a waterbody that breaks up the coverage of catchments.

In the relatively common case where one waterbody is modeled per catchment, the waterbody edge list and catchment edge list are identical and there is one flowpath per waterbody. This is not a requirement of the data model but is a common hydrologic-model implementation scheme.

**Data**  
Two topology edge lists describing the graphs.

## Catchment:
Every catchment has a catchment area realization. The catchment area would be implemented as a local water budget model which takes inputs from the atmosphere and non-surficial hydro geologic systems and contributes outputs to an outlet nexus.

Every catchment of degree 2 will have a flowpath realization. The flowpath would be used to linearly reference hydrologic locations and could be used for hydrologic routing. Using a flowpath realization, waterbodies relate to a catchment at hydrologic locations.

**Data**  
Single valued catchment properties and geometry that correspond to catchment area and flowpath. Modeled as two simple features tables -- one for catchment area and one for flowpath.

## Nexus:  
All nexuses must be of degree 2 or more. A nexus can receive flow from one or more catchment and contribute it to one or more catchments.

**Data**  
An edge list between nexuses in the catchment graph. A simple-features table of hydrologic locations represents the nexuses and can be used to associate nexuses to waterbodies and flowpaths.

## Waterbodies 
Waterbodies either reside over (rivers and floodplains) or break apart the catchment area coverage (large lakes). Flow can be passed from catchments to waterbodies at nexuses. Waterbodies and catchments can also be associated through hydrologic locations along flowpaths.

**Data**  
Parameters of hydrodynamic model and/or storage discharge or reservoir operations.

## Class Diagram of relevant HY_Features classes.
![uml of ngen feature classes](https://github.com/dblodgett-usgs/hygeo/raw/master/docs/uml/summary.png)

- In order to be complete, a catchment realization must be able to perform the functions of a flowpath and a catchment area.
- To support multiple scale models and data, any catchment realization may be composed of a network of other catchment realizations.
- Catchment and nexus provide identity and topology. They do not have attributes or geometry.
- Hydrolocation provides a spatial feature that can be referenced along a flowpath.
- An indirect position provides the distance between a point referent and a a hydrologic location measured along a given flowpath.
- Models of waterbodies are referenced to flowpaths using hydrolocations and indirect positioning.

## Disclaimer

This information is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The information has not received final approval by the U.S. Geological Survey (USGS) and is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the information.

This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey  (USGS), an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at [https://www.usgs.gov/visual-id/credit_usgs.html#copyright](https://www.usgs.gov/visual-id/credit_usgs.html#copyright)

Although this software program has been used by the USGS, no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."

 [
    ![CC0](https://i.creativecommons.org/p/zero/1.0/88x31.png)
  ](https://creativecommons.org/publicdomain/zero/1.0/)
