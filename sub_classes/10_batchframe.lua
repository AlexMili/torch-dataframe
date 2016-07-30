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
	{name="label_shape", type="string", default="MxN",
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call=function(self, data, label, label_shape)
	parent_class.__init(self)

	self.batchframe_defaults = {
		data = data,
		label = label,
		label_shape = label_shape
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

Sets the self.batchframe_defaults.label to either a function for loading labels or
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

Batchframe._reshape_label = argcheck{
	{name="self", type="Dataframe"},
	{name="label", type="torch.*Tensor"},
	{name="label_shape", type="string", opt=true,
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call = function(self, label, label_shape)
	label_shape = label_shape or self.batchframe_defaults.label_shape
	label_shape = label_shape:lower():gsub(" ", "")
	if (label_shape == "mxn") then
		return label
	end

	if (label_shape:match("^nxm")) then
		label = label:transpose(2,1)
	end

	if (label_shape:match("x1$")) then
		local new_shape = label:size():totable()
		new_shape[#new_shape +  1] = 1
		label = label:reshape(table.unpack(new_shape))
	end

	return label
end}


Batchframe.set_label_shape = argcheck{
	doc =  [[
<a name="Batchframe.set_label_shape">
### Batchframe.set_label_shape(@ARGP)

Sets the self.batchframe_defaults.label_shape for transforming the data into
requested format

@ARGT

_Return value_: self
]],
	{name="self", type="Batchframe"},
	{name="label_shape", type="string", opt=true,
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call=function(self, label_shape)

	self.batchframe_defaults.label_shape = label_shape

	return self
end}

Batchframe.to_tensor  = argcheck{
	doc =  [[
<a name="Batchframe.to_tensor">
### Batchframe.to_tensor(@ARGP)

Converts the data into tensors that can easily be used for input. Prepares one
data tensor and one label tensor. The funtion is intended for use together
with the `get_batch()`. The function allows for:

- Both data and labels reside within the dataframe
- The data is located outside and will be loaded using a helper function
- The labels are located outside and will be loaded using a helper function
- Both data and labels are located outside and will be loaded using helper functions

Note that the `label_shape` may be of interest if you are using multiple labels.
The `nn.ParallelCriterion` expects a table but a tensor that has the columns as
at the first position works just as well. There is some difference in how the
individual criterions wants their data, some want a Mx1 matrix, for instance
`nn.MSECriterion`, while other require a 1D input, `nn.ClassNLLCriterion`. In order
allow for this flexibility you can specify a combinaiton of `MxN` with and without
a trailing `x1`:

1. `MxN`: First dimension is the row and the second dimension the column
2. `NxM`: First dimension is the column and the second dimension the row
3. `MxNx1`: Same as 1. but with the addition of a trailing dimension
3. `NxMx1`: Same as 2. but with the addition of a trailing dimension

_Return value_: data (tensor), label (tensor), column names (lua table)

@ARGT

]],
	{name="self", type="Dataframe"},
	{name='data_columns', type='Df_Array',
	 doc='The columns that are to be the data'},
	{name='label_columns', type='Df_Array',
	 doc='The columns that are to be the label'},
	{name="label_shape", type="string", opt=true,
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call = function(self, data_columns, label_columns, label_shape)

	data_columns = data_columns.data
	for _,column_name in ipairs(data_columns) do
		self:assert_has_column(column_name)
	end

	label_columns = label_columns.data
	for _,column_name in ipairs(label_columns) do
		self:assert_has_column(column_name)
	end

	local tensor_data = Dataframe.to_tensor(self, Df_Array(data_columns))
	local tensor_label, tensor_col_names = Dataframe.to_tensor(self, Df_Array(label_columns))
	tensor_label = self:_reshape_label(tensor_label, label_shape)

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
	{name="label_shape", type="string", opt=true,
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call = function(self, load_data_fn, label_columns, label_shape)

	label_columns = label_columns.data
	for _,column_name in ipairs(label_columns) do
		self:assert_has_column(column_name)
	end

	local tensor_label, tensor_col_names = Dataframe.to_tensor(self, Df_Array(label_columns))
	tensor_label = self:_reshape_label(tensor_label, label_shape)

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
	{name="label_shape", type="string", opt=true,
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call = function(self, data_columns, load_label_fn, label_shape)
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
	tensor_label = self:_reshape_label(tensor_label, label_shape)


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
	{name="label_shape", type="string", opt=true,
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call = function(self, load_data_fn, load_label_fn, label_shape)

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
	tensor_label = self:_reshape_label(tensor_label, label_shape)

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
	{name="label_shape", type="string", opt=true,
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call = function(self, retriever, label_shape)

	if (not retriever) then
		assert(self:get_data_retriever(), "You must call the set_data_retriever function before omitting the arguments")
		if (not self:get_label_retriever()) then
			self:set_label_retriever(Df_Array(self:get_numerical_colnames()))
		end

		return self:to_tensor(self:get_data_retriever(),
		                      self:get_label_retriever(),
		                      label_shape)
	end

	-- Assume that the retriever is for the data column
	if (not self:get_data_retriever() and
	    not self:get_label_retriever()) then
		return self:to_tensor(retriever,
		                      Df_Array(self:get_numerical_colnames()),
		                      label_shape)
	end

	if (self:get_data_retriever()) then
		return self:to_tensor(self:get_data_retriever(),
		                      retriever,
		                      label_shape)
	elseif(self:get_label_retriever()) then
		return self:to_tensor(retriever,
		                      self:get_label_retriever(),
		                      label_shape)
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
