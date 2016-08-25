-- Main Dataseries file
require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

-- Since torchnet also uses docs we need to escape them when recording the documentation
local torchnet
if (doc.__record) then
	doc.stop()
	torchnet = require "torchnet"
	doc.record()
else
	torchnet = require "torchnet"
end

doc[[

## Dataseries

The Dataseries is an array of data with an additional layer
of missing data info. The class contains two main elements:

* A data container
* A hash with the missing data positions

The missing data are presented as `nan` values. A `nan` has the
behavior that `nan ~= nan` evaluates to `true`. There is a helper
function in the package, `isnan()`, that can be used to identify
`nan` values.

The class has the following metatable functions available:

* `__index__`: You can access any element by `[]`
* `__newindex__`: You can set the value of an element via `[]`
* `__len__`: The `#` returns the length of the series
]]

-- create class object
local Dataseries, parent_class = torch.class('Dataseries', 'tnt.Dataset')

Dataseries.__init = argcheck{
	doc =  [[
<a name="Dataseries.__init">
### Dataseries.__init(@ARGP)

Creates and initializes a Dataseries class. Envoked through `local my_series = Dataseries()`

@ARGT

]],
	{name="self", type="Dataseries"},
	{name="size", type="number", doc="The size of the new series", opt=true},
	{name="data", type="torch.*Tensor|Df_Array|tds.Vec"},
	call=function(self)
	parent_class.__init(self)

end}
