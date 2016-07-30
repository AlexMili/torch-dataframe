#!/bin/bash
echo -e "\e[32m+++++++++++++++++++++++++++++++\e[0m";
echo -e "\e[32m+\e[0m Start torch-dataframe specs \e[32m+\e[0m";
echo -e "\e[32m+++++++++++++++++++++++++++++++\e[0m";
echo "";

VERSION="any"
COVERAGE=false
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
		-v|--version)
			VERSION="$2"
			shift # past argument
			;;
		-c|--coverage)
			COVERAGE=true
			;;
		*)
			# unknown option
			;;
	esac
	shift # past argument or value
done

var=0
count=0
failed_scripts=()
exclude_tags="skip_version_$VERSION"
for f in *_spec.lua; do
	echo "";
	echo "********************************************";
	echo "Running specs in $f";

	if [ "$COVERAGE" = true ]; then
		busted -v --coverage --exclude-tags=$exclude_tags,skip_all $f;
	else
		busted -v --exclude-tags=$exclude_tags,skip_all $f;
	fi

	fail=$?
	var=$(($var+$fail))
	count=$(($count+1))
	if [ $fail -ne 0 ] ; then
		failed_scripts+=($f)
	fi
	echo "End $f";
	echo "********************************************";
done

echo ""
echo -e "\e[93m==============================================\e[0m"
if [ $var -gt 0 ]
then
	echo -e "Number of scripts failed: \e[31m$var\e[0m (total scripts: $count)"
	echo "Script(s) that failed:"
	for i in "${failed_scripts[@]}"; do echo " -!- $i"; done
else
	echo "Number of scripts failed: $var (total scripts: $count)"
fi
echo " - exclude-tags used: $exclude_tags"
echo -e "\e[93m==============================================\e[0m"

exit $var
