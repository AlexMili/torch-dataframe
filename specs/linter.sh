#!/bin/bash
echo -e "**********";
echo -e "* Linter *";
echo -e "**********";
echo "";

luacheck ../ --no-global --no-self --exclude-files ../specs/*