#!/usr/local/bin/bash
mkdir "Cartografia"
cd "Cartografia"
mkdir "2017"
cd "2017"
types=("federal" "local")
for type in ${types[@]}; do
    echo -e "\nWorking on $type districts\n"
    mkdir "$type"
    cd "$type"
    for i in {01..32}; do
        echo "Downloading...  | $i/32"
        wget -q --no-check-certificate "https://cartografia.ife.org.mx//descargas/distritacion2017/$type/$i/$i.zip";
    done

    echo -e "\nDone downloading\n"

    for i in {01..32}; do
        echo "Extracting...  | $i/32"
        mkdir "$i"
        unzip -qq "$i.zip" -d "$i"
        rm "$i.zip"
        if [ -d "$i/$i" ]; then
            mv "$i/$i/*" "$i"
            rm "$i/$i"
        fi
    done

    echo -e "\nDone extracting\n"
    cd ".."
done