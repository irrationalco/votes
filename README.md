# Votes

Create predictive model for election results w/db of historical vote records, polls and other significant predictors.

## Getting Started

### Prerequisites

* Have R or RStudio installed

### Data

* Mine for local (ie Diputado Federal, Alcalde & Governador) for 2009 records-onwards. Note states may hold elections at different periods.
* Each state is responsible for keeping track of its own local-election records. Eg, for Coahuila one would have to consult http://www.iec.org.mx/v1/index.php/estadisticas
* Data is mostly crap - inconsisntent municipal codes/names, party names, etc. Open Refine is a good alternative software to R or Python text mining tools. But mostly: use intuition, criteria and keep your happy pills handy.
* Redistristaciones/reseccionaciones (altering the region associated with each electoral levels) happen every so often. So it's ok (actually expected) if codes differ each year for secciones/distritos.

### Coding style

* All column names in caps

### Coalitions

Eg with a coalition made up of PRI, PAN & PRD

When non-aggregated to the propietary party
```
COA_PRI_PAN_PRD = Coalition between PRI, PAN & PRD
```

When aggregated to PRI as the propietary party
```
PRI = Sum of the votes of PRI, PAN & PRD
```

Important: The above aggregations **should** be documented in-code to keep track of these transformations.

### Independent candidates

Note these are most relevant in the 2018 elections. Should not be modelled the same as pre-2017 elections.
```
eg. IND2_GOB_17 = Independent candidate for 2017 governor elections
```
### Non-registered candidates
```
eg. NREG_GOB_17 = Non registered votes for 2017 governor elections
```

### Copyright

This information serves as the prediction module database sub-module that will be part of the Irrational Co Smart Policy Advisor product. All information in this document is confidential and should not be propagated without the written consent of the company.

Copyright © 2015-2018, Irrational Co. All rights reserved.
