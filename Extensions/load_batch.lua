require 'dok'
local params = {...}
local Dataframe = params[1]

table.exact_length = function(tbl)
  i = 0
  for k,v in pairs(tbl) do
    i = i + 1
  end
  return i
end

--
-- load_batch('no_files', 'offset', 'load_row_fn',
--            'label_columns', 'type') : Loads a batch of data from the table. Note that you have to call init_batch before load_batch
--
-- ARGS: see dok.unpack
--
-- RETURNS: data, label tensors, table with tensor column names
--
function Dataframe:load_batch(...)
  assert(self.batch ~= nil and
         self.batch.datasets ~= nil,
         "You must call init_batch before calling load_batch")
  local args = dok.unpack(
    {...},
    'Dataframe.load_batch',
    [[
    Loads a batch of data from the table. Note that you have to call init_batch before load_batch
    in order to split the dataset into train/test/validations.
    ]],
    {arg='no_files', type='integer', help='The number of lines to include (-1 for all)', req=true},
    {arg='offset', type='integer', help='The number of files to skip before starting load', default=0},
    {arg='load_row_fn', type='function', help='Receives a row and returns a tensor assumed to be the data', req=true},
    {arg='type', type='function', help='Type of data to load', default="train"},
    {arg='label_columns', type='table', help='The columns that are to be the label. If omitted defaults to all numerical.'})
  -- Check argument integrity
  assert(self.batch.datasets[args.type] ~= nil, "There is no batch dataset group corresponding to '".. args.type .."'")
  assert(isint(args.no_files) and
         (args.no_files > 0 or
          args.no_files == -1) and
          args.no_files <= self:batch_size(args.type),
         "The number of files to load has to be either -1 for all files or " ..
         " a positive integer less or equeal to the number of observations in that category " ..
         self:batch_size(args.type) .. "." ..
         " You provided " .. tostring(args.no_files))
  if (args.no_files == -1) then args.no_files = self:batch_size(args.type) end
  assert(isint(args.offset) and
         args.offset >= 0,
         "The offset has to be a positive integer, you provided " .. tostring(args.offset))
  assert(type(args.load_row_fn) == 'function',
         "You haven't provided a function that will load the data")
  if (args.label_columns == nil) then
    args.label_columns = {}
  	for k,_ in pairs(self.dataset) do
  		if (self:is_numerical(k)) then
  			table.insert(args.label_columns, k)
  		end
  	end
  else
    if (type(args.label_columns) ~= 'table') then
      args.label_columns = {args.label_columns}
    end
    for _,k in pairs(args.label_columns) do
      assert(args.dataset[k] ~= nil, "Could not find column " .. tostring(k))
      assert(self:is_numerical(k), "Column " .. tostring(k) .. " is not numerical")
    end
  end

  local rows = {}
  local start_position = (args.offset + 1) % self:batch_size(args.type)
  local stop_position = (args.no_files + args.offset) % self:batch_size(args.type)
  if (stop_position == 0) then
    stop_position = self:batch_size(args.type)
  end
  assert(stop_position ~= start_position and
         args.no_files ~= 1,
         [[
         It seems that the start and stop positions are identical. This is most
         likely due to an unintentional loop where the batch is the size of the
         self:batch_size(args.type) + 1
         ]])
  -- If we loop and restart the loading then we need to load the last examples
  --  and then restart from 1
  if (start_position > stop_position) then
    for i=start_position,self:batch_size(args.type) do
      table.insert(rows, self.batch.datasets[args.type][i])
    end
    start_position = 1
  end
  for i=start_position,stop_position do
    table.insert(rows, self.batch.datasets[args.type][i])
  end
  local dataset_2_load = self:_create_subset(rows)
  tensor_label, tensor_col_names = dataset_2_load:to_tensor{columns = args.label_columns}
  single_data = args.load_row_fn(dataset_2_load:get_row(1))
  single_data = _add_single_first_dim(single_data)
  tensor_data = single_data
  if (#rows > 1) then
    for i = 2,#rows do
      single_data = args.load_row_fn(dataset_2_load:get_row(i))
      single_data = _add_single_first_dim(single_data)
      tensor_data = torch.cat(tensor_data, single_data, 1)
    end
  end

  return tensor_data, tensor_label, tensor_col_names
end

--
-- batch_size('type') : gets the size of the current batch type
--
-- ARGS: -type (required) [string] : the type of batch data
--
-- RETURNS: integer
--
function Dataframe:batch_size(type)
  return #self.batch.datasets[type]
end

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

--
-- init_batch('data_types') : a function for initializing metadata needed for batch loading
--
-- ARGS: -data_types (table) [optional] : The data types to instantiate and their corresponding proportions
--
-- RETURNS: void
--
function Dataframe:init_batch(...)
  local args = dok.unpack(
    {...},
    'Dataframe.init_batch',
    'Initalizes batch meta data. This function must be called prior to load_batch' ..
      ' as it needs the information for loading correct rows.',
    {arg='data_types', type='table',
     help='Types of data with corresponding proportions to to split to.',
     default={['train'] = 0.7,
              ['validate'] = 0.2,
              ['test'] = 0.1}},
    {arg='shuffle', type='boolean', help="Whether the rows should be shuffled before laoding", default=true})
  assert(type(args.data_types) == 'table', "The data types should be a table")

  local total = 0
  for v,p in pairs(args.data_types) do
    assert(type(v) == 'string', "The data types keys should be strings")
    assert(type(p) == 'number', "The data types values should be numbers")
    total = total + p
  end

  -- Adjust to proportions
  if (total ~= 1) then
    for v,p in pairs(args.data_types) do
      args.data_types[v] = args.data_types[v]/total
    end
  end

  -- Set base batch data
  local reset_batch = false
  if (self.batch == nil or
      self.batch.shuffle ~= args.shuffle) then
    self.batch = {
      data_types = args.data_types
    }
    reset_batch = true
  else
    local new_types = false
    for k,p in pairs(args.data_types) do
      if (self.batch.data_types[k] == nil or
          self.batch.data_types[k] ~= p) then
        new_types = true
        break
      end
    end
    if (not new_types) then
      for k,p in pairs(self.batch.data_types) do
        if (args.data_types[k] == nil or
            args.data_types[k] ~= p) then
          new_types = true
          break
        end
      end
    end
    if (new_types) then
      print("Warning: you have changed the data_type argument since last time causing a reset of all parameters")
      self.batch = {
        data_types = args.data_types
      }
      reset_batch = true
    end
  end

  if (reset_batch) then
    self.batch.shuffle = args.shuffle
    self.batch.datasets = {}
    self:_add_2_batch_datasets{number = self.n_rows,
                               shuffle = args.shuffle}
  else
    local n_permutated = 0
    for _,v in pairs(self.batch.datasets) do
      n_permutated = n_permutated + #v
    end
    if (n_permutated < self.n_rows) then
      self:_add_2_batch_datasets{number = self.n_rows - n_permutated,
                                 shuffle = args.shuffle,
                                 offset = n_permutated}
    elseif (n_permutated > self.n_rows) then
      print("Warning resetting the batches due to reduced number of rows")
      self.batch.datasets = {}
      self:_add_2_batch_datasets{number = self.n_rows,
                                 shuffle = args.shuffle}
    end
  end
end

-- Internal function for adding rows 2 batch datasets
function Dataframe:_add_2_batch_datasets(...)
  local args = dok.unpack(
    {...},
    'Dataframe._add_2_batch_datasets',
    'Adds data 2 batch sets.',
    {arg='number', type='integer', help='The number of rows to add', req=true},
    {arg='shuffle', type='boolean', help="Whether the rows should be shuffled before laoding", default=true},
    {arg='offset', type='integer', help='Set this if you are adding to previous permutations', default=0})
  assert(self.batch.data_types ~= nil, "You must have basic batch sizes set")

  if (args.shuffle) then
    row_indexes = torch.randperm(args.number)
  else
    row_indexes = torch.linspace(1, args.number, args.number)
  end
  local count = 0
  local last_key = -1
  for k,prop in pairs(self.batch.data_types) do
    last_key = k
    num_observations = math.max(math.ceil(prop * args.number), 1)
    if (count + num_observations > args.number) then
      num_observations = args.number - count
    end
    self.batch.datasets[k] = {}
    for i = 1,num_observations do
      table.insert(self.batch.datasets[k], args.offset + row_indexes[count + i])
    end
    count = count + num_observations
  end
  -- Add any observatinos that weren't included in thre previous loop
  assert(args.number + args.offset - count < 2 * table.exact_length(self.batch.datasets),
         "An error must have occurred during recruitment into the batch datasets" ..
         " as the difference was larger than expected: " .. args.number + args.offset - count)
  if (count < args.number) then
    for i = (count + 1),args.number do
      table.insert(self.batch.datasets[last_key], args.offset + row_indexes[i])
    end
  end
end
