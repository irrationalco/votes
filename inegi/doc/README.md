How to create the topojson map:

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