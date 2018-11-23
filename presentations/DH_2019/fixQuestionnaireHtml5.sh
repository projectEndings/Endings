#!/bin/bash

sed -i 's|></meta>|/>|g' questionnaire.htm

sed -i 's/schema.DC/schema.dc/g' questionnaire.htm
sed -i 's/name="DC:/name="dc:/g' questionnaire.htm
sed -i 's/dc:([A-Z])/dc:\L&/g' questionnaire.htm
sed -i 's/&nbsp;/ /g' questionnaire.htm

scp questionnaire.htm hcmc@nfs.hcmc.uvic.ca:/home1t/hcmc/www/endings/

