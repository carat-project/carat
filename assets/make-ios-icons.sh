#!/bin/bash
# Make iOS icons.

if [ ! -d icons ]; then mkdir icons; fi

names="Icon100.png
Icon1024.png
Icon114.png
icon120.png
Icon128.png
Icon144.png
Icon152.png
Icon167.png
Icon16.png
Icon172.png
Icon180.png
Icon196.png
Icon256.png
Icon29.png
Icon32.png
Icon40.png
Icon48.png
Icon50.png
Icon512.png
Icon55.png
Icon57.png
Icon58.png
Icon64.png
Icon72.png
Icon76.png
Icon80.png
Icon87.png
Icon88.png"


for name in $names
do
  size=${name:4:-4}
  echo $name $size
  convert carat-material.svg -scale ${size}x${size} icons/${name}
done
