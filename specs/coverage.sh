#!/bin/bash
echo -e "=================";
echo -e "= Code coverage =";
echo -e "=================";
echo "";

./run_all.sh --coverage

mv luacov.stats.out ../luacov.stats.out

cd ..

luacov -c specs/luacov_config.lua

mv luacov.stats.out specs/luacov.stats.out
mv luacov.report.out specs/luacov.report.out

cd specs

cat luacov.report.out