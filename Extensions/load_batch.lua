require "dok"
local params = {...}
local Dataframe = params[1]

function Dataframe:load_batch(...)
  local args = dok.unpack(
    {...},
    'Dataframe.load_batch',
    'Loads a batch of data from the table',
    {arg='no_files', type='integer', help='The number of lines to include (-1 for all)', req=true},
    {arg='offset', type='integer', help='The number of files to skip before starting load', default=0},
    {arg='load_row_fn', type='function', help='Receives a row and returns a tensor', req=true},
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

  -- Adjust to proportions
  if (total ~= 1) then
    for v,p in pairs(args.data_types) do
      args.data_types[v] = args.data_types[v]/total
    end
  end

  -- initiate base data
  if (self.batch == nil) then
    self.batch = {
      data_types = args.data_types
    }
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
    end
  end

  if (self.datasets ~= nil) then

  end


  print("Not yet implemented")
end
