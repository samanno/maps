#!/bin/sh

set -o errexit
set -o nounset

IFS='
	 '

CDPATH= cd -- "$(dirname -- "$0")"

mapshaper \
    -i comuni.geojson -clean encoding=utf8 \
    -simplify 20% weighted \
    -o topojson/limits_IT_municipalities.topo.json bbox format=topojson

mapshaper \
    -i topojson/limits_IT_municipalities.topo.json -clean encoding=utf8 \
    -rename-layers municipalities \
    -dissolve prov_istat_code + \
      copy-fields=prov_name,prov_istat_code_num,prov_acr,reg_name,reg_istat_code,reg_istat_code_num name=provinces \
    -target 1 \
    -dissolve reg_istat_code + \
      copy-fields=reg_name,reg_istat_code_num name=regions \
    -target 1  \
    -o topojson/limits_IT_all.topo.json bbox format=topojson target=regions,provinces,municipalities \
    -o topojson/limits_IT_regions.topo.json bbox format=topojson target=regions \
    -o topojson/limits_IT_provinces.topo.json bbox format=topojson target=provinces

for REG in $(seq 1 20); do
    mapshaper \
        -i topojson/limits_IT_municipalities.topo.json \
        -filter reg_istat_code_num==$REG \
        -o topojson/limits_R_${REG}_municipalities.topo.json bbox format=topojson
done

for PROV in $(seq 1 111); do
    mapshaper \
        -i topojson/limits_IT_municipalities.topo.json \
        -filter prov_istat_code_num==$PROV \
        -rename-layers municipalities target=1 \
        -o topojson/limits_P_${PROV}_municipalities.topo.json bbox format=topojson
done
