<a name="Dataframe.load_csv">
### Dataframe.load_csv(self, path[, header][, infer_schema][, separator][, skip][, verbose])

```
({
   self         = Dataframe  -- 
   path         = string     -- path to file
  [header       = boolean]   -- if has header on first line [default=true]
  [infer_schema = boolean]   -- automatically detect column's type [default=true]
  [separator    = string]    -- separator (one character) [default=,]
  [skip         = number]    -- skip this many lines at start of file [default=0]
  [verbose      = boolean]   -- verbose load [default=false]
})
```

Loads a CSV file into Dataframe using csvigo as backend

_Return value_: void
	<a name="Dataframe.load_table">
### Dataframe.load_table(self, data[, infer_schema][, column_order])

```
{
   self         = Dataframe  -- 
   data         = table      -- Table (dictionary) to import. Max depth 2.
  [infer_schema = boolean]   -- automatically detect columns' type [default=true]
  [column_order = table]     -- The order of the column (has to be array and _not_ a dictionary) [default=false]
}
```

Imports a table data directly into Dataframe. The table should all be of equal length
or just single values. If a table contains one column with 10 rows and then has
another column with a single element that element is duplicated 10 times, i.e.
filling the entire column with that single value.

_Note_: due to inability to separate table input from ordered arguments
this function _forces names_.

Example:
```lua
a = Dataframe()
a:load_table{data={
	['first_column']={3,4,5},
	['second_column']={10,11,12}
}}
```

_Return value_: void
	<a name="Dataframe._clean_columns">
### Dataframe._clean_columns(self)

```
({
   self = Dataframe  -- 
})
```

Internal function to clean columns names

_Return value_: void
	<a name="Dataframe._count_missing">
### Dataframe._count_missing(self)

```
({
   self = Dataframe  -- 
})
```

Internal function for counting all missing values. _Note_: internally Dataframe
uses nan (0/0) and this function only identifies missing values within an array.
This is used within the test cases.

_Return value_: number of missing values (integer)
	<a name="Dataframe._fill_missing">
### Dataframe._fill_missing(self)

```
({
   self = Dataframe  -- 
})
```

Internal function for changing missing values to NaN values.

_Return value_: void
	<a name="Dataframe.as_categorical">
### Dataframe.as_categorical(self, column_name)

```
({
   self        = Dataframe     -- 
   column_name = string|table  -- Either a single column name or a table with column names
})
```

Set a column to categorical type. Adds the column to self.categorical table with
the keuys retrieved from Dataframe.unique.

_Return value_: void
	<a name="Dataframe.add_cat_key">
### Dataframe.add_cat_key(self, column_name, key)

```
({
   self        = Dataframe      -- 
   column_name = string         -- The column name
   key         = number|string  -- The new key to insert
})
```

Adds a key to the keyset of a categorical column. Mostly intended for internal use.

_Return value_: index value for key (integer)
	<a name="Dataframe.as_string">
### Dataframe.as_string(self, column_name)

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column name
})
```

Converts a categorical column to a string column. This can be used to revert
the Dataframe.as_categorical or as a way to convert numericals into strings.

_Return value_: void
<a name="Dataframe.clean_categorical">
### Dataframe.clean_categorical(self, column_name[, reset_keys])

```
({
   self        = Dataframe  -- 
   column_name = string     -- the name of the column
  [reset_keys  = boolean]   -- if all the keys should be reinitialized [default=false]
})
```

Removes any categories no longer present from the keys

_Return value_: void
<a name="Dataframe.is_categorical">
### Dataframe.is_categorical(self, column_name)

```
({
   self        = Dataframe  -- 
   column_name = string     -- the name of the column
})
```

Check if a column is categorical

_Return value_: boolean
<a name="Dataframe.get_cat_keys">
### Dataframe.get_cat_keys(self, column_name)

```
({
   self        = Dataframe  -- 
   column_name = string     -- the name of the column
})
```

Get keys from a categorical column.

_Return value_: table with `["key"] = number` structure
<a name="Dataframe.to_categorical">
### Dataframe.to_categorical(self, data, column_name)

```
({
   self        = Dataframe     -- 
   data        = number|table  -- The integers to be converted
   column_name = string        -- The name of the column  which keys to use
})
```

Converts values to categorical according to a column's keys

_Return value_: string if single value entered or table if multiple values
<a name="Dataframe.from_categorical">
### Dataframe.from_categorical(self, data, column_name[, as_tensor])

```
({
   self        = Dataframe            -- 
   data        = number|string|table  -- The data to be converted
   column_name = string               -- The name of the column
  [as_tensor   = boolean]             -- If the returned value should be a tensor [default=false]
})
```

Converts categorical to numerical according to a column's keys

_Return value_: table or tensor
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
### Dataframe.init_batch([data_types][, shuffle])

```
{
  [data_types = table]    -- Types of data with corresponding proportions to to split to. [has default value]
  [shuffle    = boolean]  -- Whether the rows should be shuffled before laoding [default=true]
}
```

Initializes the metadata needed for batch loading. This creates the different
sub-datasets that will be used for training, validating and testing. While these
three are generally the most common choices you are free to define your own data split.

_Note_: This function must be called prior to load_batch as it needs the
information for loading correct rows.

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
<a name="Dataframe.to_csv">
### Dataframe.to_csv(self, path[, separator][, verbose])

```
({
   self      = Dataframe  -- 
   path      = string     -- path to file
  [separator = string]    -- separator (one character) [default=,]
  [verbose   = boolean]   -- verbose load [default=false]
})
```

Saves a Dataframe into a CSV using csvigo as backend

_Return value_: void
<a name="Dataframe.to_tensor">
### Dataframe.to_tensor(self)

```
({
   self = Dataframe  -- 
})
```

Convert the numeric section or specified columns of the dataset to a tensor

_Return value_: (1) torch.tensor with self.n_rows rows and #columns, (2) exported column names

You can export selected columns using the columns argument:

```
({
   self    = Dataframe  -- 
   columns = Df_Array   -- The columns to export to labels
})
```

If a filename is provided the tensor will be saved (`torch.save`) to that file:

```
({
   self     = Dataframe  -- 
   filename = string     -- Filename for tensor.save()
  [columns  = Df_Array]  -- The columns to export to labels [default=false]
})
```
	
