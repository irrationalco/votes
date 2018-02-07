# How to create the topojson map:

```
curl -o estados.zip http://mapserver.inegi.org.mx/MGN/mge2010v5_0.zip
curl -o  municipios.zip http://mapserver.inegi.org.mx/MGN/mgm2010v5_0.zip
unzip estados.zip 
unzip municipios.zip
ogr2ogr states.shp Entidades_2010_5.shp -t_srs "+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"
ogr2ogr municipalities.shp Municipios_2010_5.shp -t_srs "+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"
topojson -o mx_tj.json -s 1e-7 -q 1e5 states.shp municipalities.shp -p state_code=+CVE_ENT,state_name=NOM_ENT,mun_code=+CVE_MUN,mun_name=NOM_MUN
```

Related: [Projected Topojson of Mexican Municipalities](https://gist.github.com/diegovalle/10487038)

# Variables
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