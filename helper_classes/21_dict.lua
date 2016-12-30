require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Df_Dict

The Df_Dict is a class that is used to wrap a dictionary table. A dictionary table
has a string name corresponding to each key and an array as values, i.e. it may
not contain any tables.

]]

-- create class object
local dict = torch.class('Df_Dict')

function dict:__init(table_data)
	local dict_data = {}
	local dict_lengths = {}
	local dict_keys = {}
	local max_length_key = ""

	for k,v in pairs(table_data) do
		dict_lengths[k] = 0

		-- Check dimension
		if (torch.type(v) == "table") then
			for i=1,#v do
				assert(type(v[i]) ~= "table",
				      ("For key '%s' in the position %d the value is a table, this isn't allowed"):format(k, i))
				dict_lengths[k] = dict_lengths[k] + 1
			end
		else
			dict_lengths[k] = 1
		end

		if (dict_lengths[max_length_key] == nil or
			dict_lengths[k] > dict_lengths[max_length_key]) then
			max_length_key = k
		end


		table.insert(dict_keys,k)
		dict_data[k] = v
	end

	self.max_length_key = max_length_key
	self.keys = dict_keys
	self.length = dict_lengths
	self.data = dict_data
end

function dict:check_lengths()
	local previous_length = self.length[self.keys[1]]

	for key,value in pairs(self.length) do
		if previous_length ~= value then
			return false
		end

		previous_length = self.length[key]
	end

	return true
end

function dict:set_keys(table_data)
	assert(torch.type(table_data) == "table", "You must provide a table as argument")
	assert(#table_data == #self.keys, 
		("The keys you provided (%d items) has not the same number of current elements (%d items)")
		:format(#table_data,#self.keys))

	local temp_data = {}

	for i=1,#self.keys do
		local old_key = self.keys[i]
		local new_key = table_data[i]

		temp_data[new_key] = self.data[old_key]
	end

	self.keys = table_data
	self.data = temp_data
end

dict.__len__ = argcheck{
	{name="self", type="Df_Dict"},
	call=function(self)
	return table.exact_length(self.data)
end}

return dict
