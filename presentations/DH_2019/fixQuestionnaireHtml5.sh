#!/bin/bash

sed -i 's|></meta>|/>|g' questionnaire.htm
sed -i 's/&nbsp;/ /g' questionnaire.htm

java -jar ../../../diagnostics/utilities/saxon9he.jar -s:questionnaire.htm -xsl:quandary_source/quandaryFixes.xsl -o:questionnaire_fixed.htm

scp questionnaire_fixed.htm hcmc@nfs.hcmc.uvic.ca:/home1t/hcmc/www/endings/questionnaire.htm

