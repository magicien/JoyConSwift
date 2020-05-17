#!/bin/bash

rm -r ./docs
swift doc generate Source/ --module-name JoyConSwift --output ./docs --format html

FILES=`find ./docs -name *.html`
for FILE in ${FILES}; do
  sed -i "" -e "s/href=\"\//href=\"\/JoyConSwift\//g" ${FILE}
done
