#!/bin/bash

RUN_TESTS=true
VERBOSE=false
while [[ $# -gt 0 ]]
	do
	key="$1"

	case $key in
		-v|--verbose)
			VERBOSE=true
			;;
		-g|--generate)
			RUN_TESTS=false
			;;
		*)
			# unknown option
			;;
	esac
	shift # past argument or value
done

echo -e "=================";
echo -e "= Code coverage =";
echo -e "=================";
echo "";

if [ "$RUN_TESTS" = true ]; then
	./run_all.sh --coverage
fi

mv luacov.stats.out ../luacov.stats.out

cd ..

luacov -c .luacov

if [ "$RUN_TESTS" = true ]; then

	mv -f luacov.stats.out specs/luacov.stats.out
	mv -f luacov.report.out specs/luacov.report.out

	cd specs

	if [ "$VERBOSE" = true ]; then
		cat luacov.report.out
	fi
fi
