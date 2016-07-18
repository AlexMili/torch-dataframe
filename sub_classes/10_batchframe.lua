-- Main Dataframe file
require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Batchframe

The Batchframe is returned by the `Dataframe.get_batch` and contains only a subset
of the original Dataframe's rows. It's main function is to override the `to_tensor`
in order to provie a function that can split the tensor into data and labels, i.e.
the classical set-up used by machine learning algorithms. As the Batchframe is
a completely separate entity you can easily serialize it and send it to a separate
process that then will

]]

-- create class object
local Batchframe, parent_class = torch.class('Batchframe', 'Dataframe')

Batchframe.__init = argcheck{
	doc =  [[
<a name="Batchframe.__init">
### Batchframe.__init(@ARGP)

Calls the parent init and then adds `batchframe_defaults` table. Se the
set_load and set_data methods

@ARGT

]],
	{name="self", type="Batchframe"},
	{name="data", type="function|Df_Array", opt=true,
	 doc="The data loading procedure/columns"},
	{name="label", type="function|Df_Array", opt=true,
	 doc="The label loading procedure/columns"},
	call=function(self, data, label)
	parent_class.__init(self)

	self.batchframe_defaults = {
		data = data,
		label = label
	}
end}

Batchframe.set_data_retriever = argcheck{
	doc =  [[
<a name="Batchframe.set_data_retriever">
### Batchframe.set_data_retriever(@ARGP)

Sets the self.batchframe_defaults.data to either a function for loading data or
a set of columns that should be used in the to_tensor functions.

@ARGT

_Return value_: self
]],
	{name="self", type="Batchframe"},
	{name="data", type="function|Df_Array", opt=true,
	 doc="The data loading procedure/columns. If omitted the retriever will be erased"},
	call=function(self, data)

	self.batchframe_defaults.data = data

	return self
end}


Batchframe.get_data_retriever = argcheck{
	doc = [[
<a name="Batchframe.get_data_retriever">
### Batchframe.get_data_retriever(@ARGP)

Returns the self.batchframe_defaults.data for loading data or
a set of columns that should be used in the to_tensor functions.

@ARGT

_Return value_: function
]],
	{name="self", type="Batchframe"},
	call=function(self)
	return self.batchframe_defaults.data
end}

Batchframe.set_label_retriever = argcheck{
	doc =  [[
<a name="Batchframe.set_label_retriever">
### Batchframe.set_label_retriever(@ARGP)

Sets the self.batchframe_defaults.data to either a function for loading data or
a set of columns that should be used in the to_tensor functions.

@ARGT

_Return value_: self
]],
	{name="self", type="Batchframe"},
	{name="label", type="function|Df_Array", opt=true,
	 doc="The label loading procedure/columns. If omitted the retriever will be erased"},
	call=function(self, label)

	self.batchframe_defaults.label = label

	return self
end}

Batchframe.get_label_retriever = argcheck{
	doc = [[
<a name="Batchframe.get_label_retriever">
### Batchframe.get_label_retriever(@ARGP)

Returns the self.batchframe_defaults.label for loading label or
a set of columns that should be used in the to_tensor functions.

@ARGT

_Return value_: function
]],
	{name="self", type="Batchframe"},
	call=function(self)
	return self.batchframe_defaults.label
end}

Batchframe.to_tensor  = argcheck{
	doc =  [[
<a name="Batchframe.to_tensor">
### Batchframe.to_tensor(@ARGP)

Converts the data into tensors that can easily be used for input. Prepares one
data tensor and one label tensor. The funtion is intended for use together
with the `get_batch()`. The function allows for:

_ Both data and labels reside within the dataframe

_ The data is located outside and will be loaded using a helper function

_ The labels are located outside and will be loaded using a helper function

_ Both data and labels are located outside and will be loaded using helper functions

_Return value_: data (tensor), label (tensor), column names (lua table)

@ARGT

]],
	{name="self", type="Dataframe"},
	{name='data_columns', type='Df_Array',
	 doc='The columns that are to be the data'},
	{name='label_columns', type='Df_Array',
	 doc='The columns that are to be the label'},
	call = function(self, data_columns, label_columns)

	data_columns = data_columns.data
	for _,column_name in ipairs(data_columns) do
		self:assert_has_column(column_name)
	end

	label_columns = label_columns.data
	for _,column_name in ipairs(label_columns) do
		self:assert_has_column(column_name)
	end

	tensor_label, tensor_col_names = Dataframe.to_tensor(self, Df_Array(label_columns))
	tensor_data = Dataframe.to_tensor(self, Df_Array(data_columns))

	return tensor_data, tensor_label, tensor_col_names
end}

Batchframe.to_tensor  = argcheck{
	doc =  [[

@ARGT

]],
	overload=Batchframe.to_tensor,
	{name="self", type="Dataframe"},
	{name='load_data_fn', type='function',
	 doc='Receives a row and returns a tensor assumed to be the data'},
	{name='label_columns', type='Df_Array',
	 doc='The columns that are to be the label. If omitted defaults to all numerical.'},
	call = function(self, load_data_fn, label_columns)

	label_columns = label_columns.data
	for _,column_name in ipairs(label_columns) do
		self:assert_has_column(column_name)
	end

	tensor_label, tensor_col_names = Dataframe.to_tensor(self, Df_Array(label_columns))
	single_data = load_data_fn(self:get_row(1))
	single_data = _add_single_first_dim(single_data)
	tensor_data = single_data

	if (self:size(1) > 1) then
		for i = 2,self:size(1) do
			single_data = load_data_fn(self:get_row(i))
			single_data = _add_single_first_dim(single_data)
			tensor_data = torch.cat(tensor_data, single_data, 1)
		end
	end

	return tensor_data, tensor_label, tensor_col_names
end}

Batchframe.to_tensor  = argcheck{
	doc =  [[
*Note*: the label function setup does not return any label names

@ARGT

]],
	overload=Batchframe.to_tensor,
	{name="self", type="Dataframe"},
	{name='data_columns', type='Df_Array',
	 doc='Receives a row and returns a tensor assumed to be the data'},
	{name='load_label_fn', type='function',
	 doc='The columns that are to be the label.'},
	call = function(self, data_columns, load_label_fn)
	data_columns = data_columns.data
	for _,column_name in ipairs(data_columns) do
		self:assert_has_column(column_name)
	end

	local tensor_data = Dataframe.to_tensor(self, Df_Array(data_columns))
	local single_label = load_label_fn(self:get_row(1))
	single_label = _add_single_first_dim(single_label)
	local tensor_label = single_label

	if (self:size(1) > 1) then
		for i = 2,self:size(1) do
			single_label = load_label_fn(self:get_row(i))
			single_label = _add_single_first_dim(single_label)
			tensor_label = torch.cat(tensor_label, single_label, 1)
		end
	end

	return tensor_data, tensor_label
end}

Batchframe.to_tensor  = argcheck{
	doc =  [[
*Note*: the two function setup does not return any label names

@ARGT

]],
	overload=Batchframe.to_tensor,
	{name="self", type="Dataframe"},
	{name='load_data_fn', type='function',
	 doc='Receives a row and returns a tensor assumed to be the data'},
	{name='load_label_fn', type='function',
	 doc='Receives a row and returns a tensor assumed to be the labels'},
	call = function(self, load_data_fn, load_label_fn)

	local single_data = load_data_fn(self:get_row(1))
	single_data = _add_single_first_dim(single_data)
	local tensor_data = single_data

	if (self:size(1) > 1) then
		for i = 2,self:size(1) do
			single_data = load_data_fn(self:get_row(i))
			single_data = _add_single_first_dim(single_data)
			tensor_data = torch.cat(tensor_data, single_data, 1)
		end
	end

	local single_label = load_label_fn(self:get_row(1))
	single_label = _add_single_first_dim(single_label)
	local tensor_label = single_label

	if (self:size(1) > 1) then
		for i = 2,self:size(1) do
			single_label = load_label_fn(self:get_row(i))
			single_label = _add_single_first_dim(single_label)
			tensor_label = torch.cat(tensor_label, single_label, 1)
		end
	end

	return tensor_data, tensor_label
end}


Batchframe.to_tensor  = argcheck{
	doc =  [[
*Note*: you can use the defaults if you want to avoid providing the loader
each time. If there is only a retriever function provided and no label default
is present then the we will assume that the labels are the default numerical
columns while the retriever is for the data.

@ARGT

]],
	overload=Batchframe.to_tensor,
	{name="self", type="Dataframe"},
	{name="retriever", type="function|Df_Array", opt=true,
		doc="If you have only provided one of the defaults you can add the other retriever here"},
	call = function(self, retriever)

	if (not retriever) then
		assert(self:get_data_retriever(), "You must call the set_data_retriever function before omitting the arguments")
		assert(self:get_label_retriever(), "You must call the set_label_retriever function before omitting the arguments")

		return self:to_tensor(self:get_data_retriever(),
		                      self:get_label_retriever())
	end

	-- Assume that the retriever is for the data column
	if (not self:get_data_retriever() and
	    not self:get_label_retriever()) then
		return self:to_tensor(retriever,
		                      Df_Array(self:get_numerical_colnames()))
	end

	if (self:get_data_retriever()) then
		return self:to_tensor(self:get_data_retriever(),
		                      retriever)
	elseif(self:get_label_retriever()) then
		return self:to_tensor(retriever,
		                      self:get_label_retriever())
	end

	error("Invalid parameter specified - could not find a useful combination (should be impossible to end up here)")
end}

-- Helper for adding a single first dimension to help with torch.cat
function _add_single_first_dim(data)
  if (data:size(1) ~= 1) then
    local current_size = data:size()
    local new_size = {1}
    for i = 1,#current_size do
      table.insert(new_size, current_size[i])
    end
    new_size = torch.LongStorage(new_size)
    data = data:reshape(new_size)
  end
  return data
end
