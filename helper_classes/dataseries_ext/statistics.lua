local params = {...}
local Dataseries = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Statistics

Here are functions gather commmonly used descriptive statistics

]]

Dataseries.count_na = argcheck{
	doc = [[
<a name="Dataseries.count_na">
### Dataseries.count_na(@ARGP)

Count missing values

@ARGT

_Return value_: number
]],
	{name="self", type="Dataseries"},
	call=function(self)
	-- Thanks to the tds.Hash this is a valid
	return #self.missing
end}
