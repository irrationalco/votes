# Shapefiles

General description of the files used to generate maps, keys, censal data and stuff.

* INE 2017
* IFE 2013
* IFE 2012
* INEGI 2010

INE 2017
--------

### Distritación Federal (2016 - 2017)

Contains thematic and descriptive maps of electoral sections by entity, results of agreement No. INE / CG59 / 2017 dated March 15, 2017 through which the General Council of the INE approves the formation of the 300 federal electoral districts of the country and their respective headers.

* Download with useful script by [aLagoG](https://github.com/aLagoG) `download.sh`
* Or manual download [https://cartografia.ife.org.mx/sige7/?distritacion=federal](https://cartografia.ife.org.mx/sige7/?distritacion=federal)

| Variable | Info |
| --- | --- |
| `id` | NA |
| `long` | NA |
| `lat` | NA |
| `order` | NA |
| `hole` | NA |
| `piece` | NA |
| `group` | NA |
| `gid` | NA |  
| `id.1` | NA |
| `entidad` | NA |
| `distrito` | NA |
| `municipio` | NA |
| `seccion` | NA |
| `tipo` | NA |
| `control` | NA |
| `geometry1_` | NA |

#### Distritación Local (2017)

Thematic and descriptive maps of sections resulting from the local district agreements for each entity, approved by the general council of the INE.

[https://cartografia.ife.org.mx/sige7/?distritacion=local](https://cartografia.ife.org.mx/sige7/?distritacion=local)

| Variable | Info |
| --- | --- |
| NA | NA |

IFE 2013
--------

Rob Hidalgo’s repository of public information (from freedom of information requests) which includes a shapefile of the municipios of Mexico according to the IFE.

*** I'm assuming it's data from 2013 🙃

[https://github.com/unrob/informacion-publica/tree/master/ife/marco-geografico-nacional](https://github.com/unrob/informacion-publica/tree/master/ife/marco-geografico-nacional)

IFE 2012
--------

Contains information about the country's geographic framework at the electoral section level.

*** Not actualy sure it's 2012 🙄

[http://geonode.ciesas.edu.mx/layers/geonode:seccion](http://geonode.ciesas.edu.mx/layers/geonode:seccion)

| Variable | Info |
| --- | --- |
| `The_Geom` | NA |
| `Id` | NA |
| `Entidad` | NA |
| `Distrito` | NA |
| `Municipio` | NA |
| `Seccion` | NA |
| `Tipo` | NA |
| `Geometry1_` | NA |  
| `Oid` | NA |

CENSO INEGI 2010
----------------

Diego Valle-Jones has created a set of scripts to download and recode shapefiles from the IFE and INEGI. Once you run the scripts you’ll find in the map-out directory: 

* **distritos**: Shapefile of the electoral distritos (districts) 
* **secciones-inegi**: Shapefile of electoral secciones (precincts) with both the ife and inegi codes for the municipalities each seccion belongs to 
* **estados**: Shapefile of the Mexican states according to the INEGI
* **localidades**: Shapefiles of the rural localities and the polygons of the urban ones 
* **municipios**: Shapefile of the municipalities of Mexico according to the INEGI
* **rdata-secciones**: serialized secciones (precincts) map as an R object 
Electoral shapefiles of Mexico

*** The codebook for the the census data that comes with the distrito and sección shapefiles is in the `FD_SECC_IFE.pdf` file.

#### How to create the topojson map

```
curl -o estados.zip http://mapserver.inegi.org.mx/MGN/mge2010v5_0.zip
curl -o  municipios.zip http://mapserver.inegi.org.mx/MGN/mgm2010v5_0.zip
unzip estados.zip 
unzip municipios.zip
ogr2ogr states.shp Entidades_2010_5.shp -t_srs "+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"
ogr2ogr municipalities.shp Municipios_2010_5.shp -t_srs "+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"
topojson -o mx_tj.json -s 1e-7 -q 1e5 states.shp municipalities.shp -p state_code=+CVE_ENT,state_name=NOM_ENT,mun_code=+CVE_MUN,mun_name=NOM_MUN

[https://blog.diegovalle.net/2013/02/download-shapefiles-of-mexico.html](https://blog.diegovalle.net/2013/02/download-shapefiles-of-mexico.html)
```

#### Variable transformation, formulas and description
```
TOTAL           POBTOT
Total población

HOMBRES         (POBMAS/POBTOT)*100
% Hombres

MUJERES         (POBFEM/POBTOT)*100
% Mujeres

HIJOS           PROM_HNV
Promedio de hijos nacidos vivos

ENTIDAD_NAC     (PNACENT/POBTOT)*100
% Población nacida en la entidad

ENTIDAD_INM     (PRES2005/P_5YMAS)*100
% Población de 5 años y más residente en la entidad en junio de 2005

ENTIDAD_MIG     (PRESOE05/P_5YMAS)*100
% Población de 5 años y más residente en otra entidad en junio de 2005

LIMITACION      (PCON_LIM/POBTOT)*100
% Población con limitación en la actividad

ANALFABETISMO   (P15YM_AN/P_15YMAS)*100
% Población de 15 años y más analfabeta

EDUCACION_AV    (P18YM_PB/P_18YMAS)*100
% Población de 18 años y más con educación posbásica

PEA             (PEA/POBTOT)*100
Población económicamente activa

NO_SERV_SALUD   (PSINDER/POBTOT)*100
Población sin derechohabiencia a servicios de salud

MATRIMONIOS     (P12YM_CASA/P_12YMAS)*100
Población casada o unida de 12 años y más 

HOGARES         TOTHOG
Total de hogares censales

HOGARES_JEFA    (HOGJEF_F/TOTHOG)*100
Hogares censales con jefatura femenina

HOGARES_POB     (POBHOG/TOTHOG)*100
Población en hogares censales

AUTO            (VPH_AUTOM/VIVPAR_HAB)*100
Viviendas particulares habitadas que disponen de automóvil o camioneta
```