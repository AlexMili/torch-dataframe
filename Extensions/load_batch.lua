local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Batch loading functions

]]

Dataframe.load_batch = argcheck{
	doc = [[
<a name="Dataframe.load_batch">
### Dataframe.load_batch(@ARGP)

@ARGT

Loads a batch of data from the table. Note that you have to call init_batch before load_batch
in order to split the dataset into train/test/validations.

_Return value_: data, label tensors, table with tensor column names
]],
	{name="self", type="Dataframe"},
	{name='no_lines', type='number', doc='The number of lines/rows to include (-1 for all)'},
	{name='offset', type='number', doc='The number of lines/rows to skip before starting load', default=0},
	{name='load_row_fn', type='function',
	 doc='Receives a row and returns a tensor assumed to be the data'},
	{name='type', type='string', doc='Type of data to load', default="train"},
	{name='label_columns', type='table',
	 doc='The columns that are to be the label. If omitted defaults to all numerical.',
	 default=false},
	call = function(self, no_lines, offset, load_row_fn, type, label_columns)
	assert(self.batch ~= nil and
	       self.batch.datasets ~= nil,
	       "You must call init_batch before calling load_batch")
	-- Check argument integrity
	assert(self.batch.datasets[type] ~= nil, "There is no batch dataset group corresponding to '".. type .."'")
	assert(isint(no_lines) and
	       (no_lines > 0 or
	        no_lines == -1) and
	        no_lines <= self:batch_size(type),
	       "The number of files to load has to be either -1 for all files or " ..
	       " a positive integer less or equeal to the number of observations in that category " ..
	       self:batch_size(type) .. "." ..
	       " You provided " .. tostring(no_lines))

	if (no_lines == -1) then no_lines = self:batch_size(type) end

	assert(isint(offset) and
	       offset >= 0,
	       "The offset has to be a positive integer, you provided " .. tostring(offset))
	assert(torch.type(load_row_fn) == 'function',
	       "You haven't provided a function that will load the data")

	if (not label_columns) then
	  label_columns = {}
		for i=1,#self.columns do
			if (self:is_numerical(self.columns[i])) then
				table.insert(label_columns, self.columns[i])
			end
		end
	else
		if (type(label_columns) ~= 'table') then
			label_columns = {label_columns}
		end

		for i=1,#label_columns do
			assert(args.dataset[label_columns[i]] ~= nil, "Could not find column " .. tostring(k))
			assert(self:is_numerical(label_columns[i]), "Column " .. tostring(label_columns[i]) .. " is not numerical")
		end
	end

  local rows = {}
  local start_position = (offset + 1) % self:batch_size(type)
  local stop_position = (no_lines + offset) % self:batch_size(type)

	if (stop_position == 0) then
		stop_position = self:batch_size(type)
	end

	assert(stop_position ~= start_position and
	       no_lines ~= 1,
	       [[
	       It seems that the start and stop positions are identical. This is most
	       likely due to an unintentional loop where the batch is the size of the
	       self:batch_size(type) + 1
	       ]])

	-- If we loop and restart the loading then we need to load the last examples
	--  and then restart from 1
	if (start_position > stop_position) then

		for i=start_position,self:batch_size(type) do
			table.insert(rows, self.batch.datasets[type][i])
		end

		start_position = 1
	end

	for i=start_position,stop_position do
		table.insert(rows, self.batch.datasets[type][i])
	end
	local dataset_2_load = self:_create_subset(Df_Array(rows))
	tensor_label, tensor_col_names = dataset_2_load:to_tensor{columns = Df_Array(label_columns)}
	single_data = load_row_fn(dataset_2_load:get_row(1))
	single_data = _add_single_first_dim(single_data)
	tensor_data = single_data
	if (#rows > 1) then
		for i = 2,#rows do
			single_data = load_row_fn(dataset_2_load:get_row(i))
			single_data = _add_single_first_dim(single_data)
			tensor_data = torch.cat(tensor_data, single_data, 1)
		end
	end

	return tensor_data, tensor_label, tensor_col_names
end}

Dataframe.batch_size = argcheck{
	doc = [[
<a name="Dataframe.batch_size">
### Dataframe.batch_size(@ARGP)

@ARGT

Gets the size of the current batch type.

_Return value_: number of rows/lines (integer)
]],
	{name="self", type="Dataframe"},
	{name="type", type="string", doc="the type of batch data"},
	call=function(self, type)
	data = self.batch.datasets[type]
	assert(data ~= nil, "Could not find the batch of type " .. type)
	return #data
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

Dataframe.init_batch = argcheck{
	doc = [[
<a name="Dataframe.init_batch">
### Dataframe.init_batch(@ARGP)

@ARGT

Initializes the metadata needed for batch loading. This creates the different
sub-datasets that will be used for training, validating and testing. While these
three are generally the most common choices you are free to define your own data split.

_Note_: This function must be called prior to load_batch as it needs the
information for loading correct rows.

The default data split is:
{['train'] = 0.7,
 ['validate'] = 0.2,
 ['test'] = 0.1}

_Return value_: void
]],
  {name='self', type='Dataframe'},
	{name='data_types', type='Df_Dict',
	 doc='Types of data with corresponding proportions to to split to.',
	 default=false},
	{name='shuffle', type='boolean',
	 doc="Whether the rows should be shuffled before laoding", default=true},
	call=function(self, data_types, shuffle)
	if (not data_types) then
		data_types = {['train'] = 0.7,
		              ['validate'] = 0.2,
 		              ['test'] = 0.1}
	else
		data_types = data_types.data
	end

	-- Check data_type for inconcistencies
	local total = 0
	for v,p in pairs(data_types) do
		assert(type(v) == 'string', "The data types keys should be strings")
		assert(type(p) == 'number', "The data types values should be numbers")
		total = total + p
	end

	-- Adjust to proportions
	if (math.abs(total - 1) > 1e-4) then
		print("Warning: You have provided a total ~= 1 (".. total .. ")")
		for v,p in pairs(data_types) do
			data_types[v] = data_types[v]/total
		end
	end

	-- Set base batch data
	local reset_batch = false
	if (self.batch == nil or
	    self.batch.shuffle ~= shuffle) then
		self.batch = {
			data_types = data_types
		}
		reset_batch = true
	else
		local new_types = false
		for k,p in pairs(data_types) do
			if (self.batch.data_types[k] == nil or
			    self.batch.data_types[k] ~= p) then
				new_types = true
				break
			end
		end

		if (not new_types) then
			for k,p in pairs(self.batch.data_types) do
				if (data_types[k] == nil or
				    data_types[k] ~= p) then
					new_types = true
					break
				end
			end
		end
		if (new_types) then
			print("Warning: you have changed the data_type argument since last time causing a reset of all parameters")
			self.batch = {
				data_types = data_types
			}
			reset_batch = true
		end
	end

	if (reset_batch) then
		self.batch.shuffle = shuffle
		self.batch.datasets = {}
		self:_add_2_batch_datasets{number = self.n_rows,
		                           shuffle = shuffle}
	else
		local n_permutated = 0
		for _,v in pairs(self.batch.datasets) do
			n_permutated = n_permutated + #v
		end
		if (n_permutated < self.n_rows) then
			self:_add_2_batch_datasets{number = self.n_rows - n_permutated,
			                           shuffle = shuffle,
			                           offset = n_permutated}
		elseif (n_permutated > self.n_rows) then
			print("Warning resetting the batches due to reduced number of rows")
			self.batch.datasets = {}
			self:_add_2_batch_datasets{number = self.n_rows,
			                           shuffle = shuffle}
		end
	end
end}

Dataframe._add_2_batch_datasets = argcheck{
	doc = [[
<a name="Dataframe._add_2_batch_datasets">
### Dataframe._add_2_batch_datasets(@ARGP)

@ARGT

Internal function for adding rows 2 batch datasets

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name='number', type='number', doc='The number of rows to add'},
	{name='shuffle', type='boolean', doc="Whether the rows should be shuffled before laoding", default=true},
	{name='offset', type='number', doc='Set this if you are adding to previous permutations', default=0},
	call=function(self, number, shuffle, offset)
	assert(self.batch.data_types ~= nil, "You must have basic batch sizes set")

	if (shuffle) then
		row_indexes = torch.randperm(number)
	else
		row_indexes = torch.linspace(1, number, number)
	end
	local count = 0
	local last_key = -1
	for k,prop in pairs(self.batch.data_types) do
		last_key = k
		num_observations = math.max(math.ceil(prop * number), 1)
		if (count + num_observations > number) then
			num_observations = number - count
		end
		self.batch.datasets[k] = {}
		for i = 1,num_observations do
			table.insert(self.batch.datasets[k], offset + row_indexes[count + i])
		end
		count = count + num_observations
	end

	-- Add any observatinos that weren't included in thre previous loop
	assert(number + offset - count < 2 * table.exact_length(self.batch.datasets),
	       "An error must have occurred during recruitment into the batch datasets" ..
	       " as the difference was larger than expected: " .. number + offset - count)
	if (count < number) then
		for i = (count + 1),number do
			table.insert(self.batch.datasets[last_key], offset + row_indexes[i])
		end
	end
end}
