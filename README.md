# hygeo

[![Build Status](https://travis-ci.org/dblodgett-usgs/hygeo.svg?branch=master)](https://travis-ci.org/dblodgett-usgs/hygeo) [![Coverage Status](https://coveralls.io/repos/github/dblodgett-usgs/hygeo/badge.svg?branch=master)](https://coveralls.io/github/dblodgett-usgs/hygeo?branch=master)

installation: `remotes::install_github("dblodgett-usgs/hygeo")`

This R package is part of the Next Generation Water Modeling Engine and Framework Prototype project taking place here: https://github.com/NOAA-OWP/ngen

## Hydrologic and Hydrodynamic Graphs:

![Example Image](https://github.com/NOAA-OWP/ngen/blob/master/data/demo.png?raw=true)  

At the top level we have a hydrologic graph of catchments and nexuses and a hydrodynamic graph of waterbodies that “pins” to the catchment graph at nexuses. 

Both catchments and nexuses are labeled nodes with unlabeled directed edges between. 

Any catchment node of degree 1 with an outward edge is a headwater and degree 1 with an inward edge is an outlet. 

Any catchment node of degree 2 is a typical catchment that has a coincident set of (one or more) waterbodies in the waterbody graph.

Using this graph scheme, headwater catchments contribute either to the upstream end of a river (flowpath) or to the shore of a waterbody that breaks up the coverage of catchment areas.

**Data**  
Two edge lists describing the graphs.

## Catchment:
Every catchment has a catchment area realization. The catchment area would be implemented as a local water budget model which takes inputs from the atmosphere and non-surficial hydro geologic systems and contributes outputs to an outlet nexus.

Every catchment of degree 2 will have a flowpath realization. The flowpath would be used to linearly reference hydrologic locations and could be used for hydrologic routing. Using a flowpath realization, waterbodies relate to a catchment at hydrologic locations.

**Data**  
Single valued catchment properties and geometry that correspond to catchment area and flowpath. Modeled as two simple features tables -- one for catchment area and one for flowpath.

## Nexus:  
All nexuses must be of degree 2 or more. A nexus can receive flow from one or more catchment and contribute it to one or more catchments.

**Data**  
An edge list between nexuses in the catchment graph. A hydrologic location simple features table represents the nexuses and can be used to associate nexuses to waterbodies and flowpaths.

## Waterbodies 
Waterbodies either reside over (rivers and floodplains) or break apart the catchment area coverage (large lakes). Flow can be passed from catchments to waterbodies at nexuses. Waterbodies and catchments can also be associated through hydrologic locations along flowpaths.

**Data**  
Parameters of hydrodynamic model and/or storage discharge or reservoir operations.

## Disclaimer

This information is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The information has not received final approval by the U.S. Geological Survey (USGS) and is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the information.

This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey  (USGS), an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at [https://www.usgs.gov/visual-id/credit_usgs.html#copyright](https://www.usgs.gov/visual-id/credit_usgs.html#copyright)

Although this software program has been used by the USGS, no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."

 [
    ![CC0](https://i.creativecommons.org/p/zero/1.0/88x31.png)
  ](https://creativecommons.org/publicdomain/zero/1.0/)
