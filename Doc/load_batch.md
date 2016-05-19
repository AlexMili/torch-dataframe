
## Batch loading functions

<a name="Dataframe.load_batch">
### Dataframe.load_batch(self, no_lines[, offset], load_row_fn[, type][, label_columns])

```
({
   self          = Dataframe  -- 
   no_lines      = number     -- The number of lines/rows to include (-1 for all)
  [offset        = number]    -- The number of lines/rows to skip before starting load [default=0]
   load_row_fn   = function   -- Receives a row and returns a tensor assumed to be the data
  [type          = string]    -- Type of data to load [default=train]
  [label_columns = table]     -- The columns that are to be the label. If omitted defaults to all numerical. [default=false]
})
```

Loads a batch of data from the table. Note that you have to call init_batch before load_batch
in order to split the dataset into train/test/validations.

_Return value_: data, label tensors, table with tensor column names
<a name="Dataframe.batch_size">
### Dataframe.batch_size(self, type)

```
({
   self = Dataframe  -- 
   type = string     -- the type of batch data
})
```

Gets the size of the current batch type.

_Return value_: number of rows/lines (integer)
<a name="Dataframe.init_batch">
### Dataframe.init_batch(self[, data_types][, shuffle])

```
({
   self       = Dataframe  -- 
  [data_types = Df_Dict]   -- Types of data with corresponding proportions to to split to. [default=false]
  [shuffle    = boolean]   -- Whether the rows should be shuffled before laoding [default=true]
})
```

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
<a name="Dataframe._add_2_batch_datasets">
### Dataframe._add_2_batch_datasets(self, number[, shuffle][, offset])

```
({
   self    = Dataframe  -- 
   number  = number     -- The number of rows to add
  [shuffle = boolean]   -- Whether the rows should be shuffled before laoding [default=true]
  [offset  = number]    -- Set this if you are adding to previous permutations [default=0]
})
```

Internal function for adding rows 2 batch datasets

_Return value_: void
