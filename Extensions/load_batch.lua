require "dok"
local params = {...}
local Dataframe = params[1]

table.exact_length = function(tbl)
  i = 0
  for k,v in pairs(tbl) do
    i = i + 1
  end
  return i
end

function Dataframe:load_batch(...)
  local args = dok.unpack(
    {...},
    'Dataframe.load_batch',
    'Loads a batch of data from the table',
    {arg='no_files', type='integer', help='The number of lines to include (-1 for all)', req=true},
    {arg='offset', type='integer', help='The number of files to skip before starting load', default=0},
    {arg='load_row_fn', type='function', help='Receives a row and returns a tensor assumed to be the data', req=true},
    {arg='label_columns', type='table', help='The columns that are to be the label. If omitted defaults to all.'},
    {arg='type', type='function', help='Type of data to load', default="train"},
    {arg='data_types', type='table',
     help='Types of data with corresponding proportions to to split to.',
     default={['train'] = 0.7,
              ['validate'] = 0.2,
              ['test'] = 0.1}})
  -- Check argument integrity
  assert(isint(args.no_files) and
         (args.no_files > 0 or
          args.no_files == -1),
         "The number of files to load has to be either -1 for all files or a positive integer." ..
         " You provided " .. tostring(args.offset))
  assert(isint(args.offset) and
         args.offset >= 0,
         "The offset has to be a positive integer, you provided " .. tostring(args.offset))
  assert(type(args.load_row_fn) == 'function',
         "You haven't provided a function that will load the data")
  assert(type(args.data_types) == 'table', "The data types should be a table")
  local total = 0
  for v,p in pairs(args.data_types) do
    assert(type(v) == 'string', "The data types keys should be strings")
    assert(type(p) == 'number', "The data types values should be numbers")
    total = total + p
  end
  if (args.label_columns == nil) then
    args.label_columns = self:_get_numerics()
  else
    if (type(args.label_columns) ~= 'table') then
      args.label_columns = {args.label_columns}
    end
    for _,k in pairs(args.label_columns) do
      assert(args.dataset[k] ~= nil, "Could not find column " .. tostring(k))
    end
  end

  -- Adjust to proportions
  if (total ~= 1) then
    for v,p in pairs(args.data_types) do
      args.data_types[v] = args.data_types[v]/total
    end
  end

  -- initiate base data


  print("Not yet implemented")
end

function Dataframe:_batch_init(...)
  local args = dok.unpack(
    {...},
    'Dataframe._batch_init',
    'Initalizes batch meta data',
    {arg='data_types', type='table',
     help='Types of data with corresponding proportions to to split to.',
     default={['train'] = 0.7,
              ['validate'] = 0.2,
              ['test'] = 0.1}})
  -- Set base batch data
  local reset_batch = false
  if (self.batch == nil) then
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
    permutations = torch.randperm(self.n_rows)
    self.batch_datasets = {}
    local count = 0
    local last_key = -1
    for k,prop in pairs(self.batch) do
      last_key = k
      num_observations = math.max(math.ceil(prop * self.n_rows), 1)
      if (count + num_observations > self.n_rows) then
        num_observations = self.n_rows - count
      end
      self.batch_datasets[k] = {}
      for i = 1,num_observations do
        table.insert(self.batch_datasets[k], permutations[count + i])
        count = count + 1
      end
    end
    -- Add any observatinos that weren't included in thre previous loop
    assert(self.n_rows - count < 2 * table.exact_length(self.batch_datasets),
           "An error must have occurred during recruitment into the batch datasets" ..
           " as the difference was larger than expected: " .. self.n_rows - count)
    if (count < self.n_rows) then
      for i = (count + 1),self.n_rows do
        table.insert(self.batch_datasets[last_key], permutations[i])
      end
    end
  end


  local n_permutated = 0
  for _,v in pairs(self.batch_datasets) do
    n_permutated = n_permutated + #v
  end
  if (n_permutated < self.n_rows) then
    -- TODO: handle if n_rows increases
  elseif (n_permutated > self.n_rows) then
    print("Warning resetting the batches due to reduced number of rows")
    -- TODO: handle if n_rows increases
  end
end
