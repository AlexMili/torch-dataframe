#!/bin/bash
echo -e "\e[32m+++++++++++++++++++++++++++++++\e[0m";
echo -e "\e[32m+\e[0m Start torch-dataframe specs \e[32m+\e[0m";
echo -e "\e[32m+++++++++++++++++++++++++++++++\e[0m";
echo "";

var=0
count=0
for f in *_spec.lua; do
    echo "";
    echo "********************************************";
    echo "Running specs in $f";
    busted $f;
    var=$(($var+$?))
    count=$(($count+1))
    echo "End $f";
    echo "********************************************";
done

echo ""
echo -e "\e[93m==============================================\e[0m"
if [ $var -gt 0 ]
then
	echo -e "Number of scripts failed: \e[31m$var\e[0m (total scripts: $count)"
else
	echo "Number of scripts failed: $var (total scripts: $count)"
fi
echo -e "\e[93m==============================================\e[0m"
exit $var
