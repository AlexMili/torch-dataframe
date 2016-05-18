
## Core functions

<a name="Dataframe.__init">
### Dataframe.__init(self)

Creates and initializes a Dataframe class. Envoked through `local my_dataframe = Dataframe()`

```
({
   self = Dataframe  -- 
})
```

_Return value_: Dataframe
Read in an csv-file

```
({
   self     = Dataframe  -- 
   csv_file = string     -- The file path to the CSV
})
```

_Return value_: Dataframe
Directly input a table

```
({
   self = Dataframe  -- 
   data = Df_Dict    -- The data to read in
})
```

_Return value_: Dataframe
<a name="Dataframe.shape">
### Dataframe.shape(self)

Returns the number of rows and columns in a table

```
({
   self = Dataframe  -- 
})
```

_Return value_: table
<a name="Dataframe.size">
### Dataframe.size(self)

Returns the number of rows and columns in a tensor

```
({
   self = Dataframe  -- 
})
```

_Return value_: tensor (rows, columns)
By providing dimension you can get only that dimension, row == 1, col == 2

```
({
   self = Dataframe  -- 
   dim  = number     -- The dimension of interest
})
```

_Return value_: integer
<a name="Dataframe.insert">
### Dataframe.insert(self, rows)

Inserts a row or multiple rows into database. Automatically appends to the Dataframe.

```
({
   self = Dataframe  -- 
   rows = Df_Dict    -- Insert values to the dataset
})
```

_Return value_: void
<a name="Dataframe.remove_index">
### Dataframe.remove_index(self, index)

Deletes a given row

```
({
   self  = Dataframe  -- 
   index = number     -- The row index to remove
})
```

_Return value_: void
<a name="Dataframe.unique">
### Dataframe.unique(self, column_name[, as_keys][, as_raw])

Get unique elements given a column name

```
({
   self        = Dataframe  -- 
   column_name = string     -- column to inspect
  [as_keys     = boolean]   -- return table with unique as keys and a count for frequency [default=false]
  [as_raw      = boolean]   -- return table with raw data without categorical transformation [default=false]
})
```

_Return value_:  table with unique values or if as_keys == true then the unique
	value as key with an incremental integer value => {'unique1':1, 'unique2':2, 'unique6':3}
<a name="Dataframe.get_row">
### Dataframe.get_row(self, index)

Gets a single row from the Dataframe

```
({
   self  = Dataframe  -- 
   index = number     -- The row index to retrieve
})
```

_Return value_: A table with the row content

## Column functions

<a name="Dataframe.is_numerical">
### Dataframe.is_numerical(self, column_name)

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column name to check
})
```

Checks if column is numerical

_Return value_: boolean
<a name="Dataframe.has_column">
### Dataframe.has_column(self, column_name)

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column to check
})
```

Checks if column is present in the dataset

_Return value_: boolean
<a name="Dataframe.drop">
### Dataframe.drop(self, column_name)

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column to drop
})
```

Delete column from dataset

_Return value_: void
You can also delete multiple columns by supplying a Df_Array

```
({
   self    = Dataframe  -- 
   columns = Df_Array   -- The columns to drop
})
```
<a name="Dataframe.add_column">
### Dataframe.add_column(self, column_name[, default_value])

```
({
   self          = Dataframe               -- 
   column_name   = string                  -- The column to add
  [default_value = number|string|boolean]  -- The default_value [default=nan]
})
```

Add new column to Dataframe

_Return value_: void
If you have a column with values to add then use the Df_Array

```
({
   self           = Dataframe  -- 
   column_name    = string     -- The column to add
   default_values = Df_Array   -- The default values
})
```

Add new column to Dataframe

_Return value_: void
<a name="Dataframe.get_column">
### Dataframe.get_column(self, column_name[, as_raw][, as_tensor])

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column requested
  [as_raw      = boolean]   -- Convert categorical values to original [default=false]
  [as_tensor   = boolean]   -- Convert to tensor [default=false]
})
```

Gets the column from the `self.dataset`

_Return value_: table or tensor
<a name="Dataframe.reset_column">
### Dataframe.reset_column(self, columns[, new_value])

Change value of a whole column or columns

```
({
   self      = Dataframe               -- 
   columns   = Df_Array                -- The columns to reset
  [new_value = number|string|boolean]  -- New value to set [default=nan]
})
```

_Return value_: void

```
({
   self        = Dataframe                   -- 
   column_name = string                      -- The column requested
  [new_value   = number|string|boolean|nan]  -- New value to set [default=nan]
})
```

<a name="Dataframe.rename_column">
### Dataframe.rename_column(self, old_column_name, new_column_name)

Rename a column

```
({
   self            = Dataframe  -- 
   old_column_name = string     -- The old column name
   new_column_name = string     -- The new column name
})
```

_Return value_: void
<a name="Dataframe.get_numerical_colnames">
### Dataframe.get_numerical_colnames(self)

Gets the names of all the columns that are numerical

```
({
   self = Dataframe  -- 
})
```

_Return value_: table
<a name="Dataframe.get_column_order">
### Dataframe.get_column_order(self, column_name[, as_tensor])

Gets the column order index

```
({
   self        = Dataframe  -- 
   column_name = string     -- The name of the column
  [as_tensor   = boolean]   -- If return index position in tensor [default=false]
})
```

_Return value_: integer
<a name="Dataframe.reset_column">
### Dataframe.reset_column(self, columns[, new_value])

Change value of a whole column or columns

```
({
   self      = Dataframe               -- 
   columns   = Df_Array                -- The columns to reset
  [new_value = number|string|boolean]  -- New value to set [default=nan]
})
```

_Return value_: void

```
({
   self        = Dataframe                   -- 
   column_name = string                      -- The column requested
  [new_value   = number|string|boolean|nan]  -- New value to set [default=nan]
})
```

<a name="Dataframe.rename_column">
### Dataframe.rename_column(self, old_column_name, new_column_name)

Rename a column

```
({
   self            = Dataframe  -- 
   old_column_name = string     -- The old column name
   new_column_name = string     -- The new column name
})
```

_Return value_: void
<a name="Dataframe.get_numerical_colnames">
### Dataframe.get_numerical_colnames(self)

Gets the names of all the columns that are numerical

```
({
   self = Dataframe  -- 
})
```

_Return value_: table
<a name="Dataframe.get_column_order">
### Dataframe.get_column_order(self, column_name[, as_tensor])

Gets the column order index

```
({
   self        = Dataframe  -- 
   column_name = string     -- The name of the column
  [as_tensor   = boolean]   -- If return index position in tensor [default=false]
})
```

_Return value_: integer

## Data save/export functions

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

## Categorical functions

<a name="Dataframe.as_categorical">
### Dataframe.as_categorical(self, column_name)

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column name to convert
})
```

Set a column to categorical type. Adds the column to self.categorical table with
the keuys retrieved from Dataframe.unique.

_Return value_: void

```
({
   self         = Dataframe  -- 
   column_array = Df_Array   -- An array with column names
})
```

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
   self        = Dataframe  -- 
   data        = number     -- The integer to be converted
   column_name = string     -- The name of the column  which keys to use
})
```

Converts values to categorical according to a column's keys

_Return value_: string with the value
You can also provide a tensor

```
({
   self        = Dataframe      -- 
   data        = torch.*Tensor  -- The integers to be converted
   column_name = string         -- The name of the column  which keys to use
})
```

_Return value_: table with values
You can also provide an array

```
({
   self        = Dataframe  -- 
   data        = Df_Array   -- The integers to be converted
   column_name = string     -- The name of the column  which keys to use
})
```

_Return value_: table with values
<a name="Dataframe.from_categorical">
### Dataframe.from_categorical(self, data, column_name[, as_tensor])

```
({
   self        = Dataframe      -- 
   data        = number|string  -- The data to be converted
   column_name = string         -- The name of the column
  [as_tensor   = boolean]       -- If the returned value should be a tensor [default=false]
})
```

Converts categorical to numerical according to a column's keys

_Return value_: table or tensor
You can also provide an array with values

```
({
   self        = Dataframe  -- 
   data        = Df_Array   -- The data to be converted
   column_name = string     -- The name of the column
  [as_tensor   = boolean]   -- If the returned value should be a tensor [default=false]
})
```

_Return value_: table or tensor

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

## Subsetting and manipulation functions

<a name="Dataframe.sub">
### Dataframe.sub(self[, start][, stop])

```
({
   self  = Dataframe  -- 
  [start = number]    -- Row to start at [default=1]
  [stop  = number]    -- Last row to include [default=false]
})
```

Selects a subset of rows and returns those

_Return value_: Dataframe
<a name="Dataframe.get_random">
### Dataframe.get_random(self[, n_items])

```
({
   self    = Dataframe  -- 
  [n_items = number]    -- Number of rows to retrieve [default=1]
})
```

Retrieves a random number of rows for exploring

_Return value_: Dataframe
<a name="Dataframe.head">
### Dataframe.head(self[, n_items])

```
({
   self    = Dataframe  -- 
  [n_items = number]    -- Number of rows to retrieve [default=10]
})
```

Retrieves the first elements of a table

_Return value_: Dataframe
<a name="Dataframe.tail">
### Dataframe.tail(self[, n_items])

```
({
   self    = Dataframe  -- 
  [n_items = number]    -- Number of rows to retrieve [default=10]
})
```

Retrieves the last elements of a table

_Return value_: Dataframe
<a name="Dataframe._create_subset">
### Dataframe._create_subset(self, index_items)

```
({
   self        = Dataframe  -- 
   index_items = Df_Array   -- The indexes to retrieve
})
```

Creates a class and returns a subset based on the index items. Intended for internal
use.

_Return value_: Dataframe
<a name="Dataframe.where">
### Dataframe.where(self, column, item_to_find)

```
({
   self         = Dataframe              -- 
   column       = string                 -- column to browse or findin the item argument
   item_to_find = number|string|boolean  -- The value to find
})
```

Find the rows where the column has the given value

_Return value_: Dataframe
You can also provide a function for more advanced matching

```
({
   self     = Dataframe  -- 
   match_fn = function   -- Function that takes a row as an argument and returns boolean
})
```

<a name="Dataframe.update">
### Dataframe.update(self, condition_function, update_function)

```
({
   self               = Dataframe  -- 
   condition_function = function   -- Function that tests if the row should be updated. It should accept a row table as an argument and return boolean
   update_function    = function   -- Function that updates the row. Takes the entire row as an argument, modifies it and returns the same.
})
```

_Return value_: void
<a name="Dataframe.set">
### Dataframe.set(self, item_to_find, column_name, new_value)

```
({
   self         = Dataframe              -- 
   item_to_find = number|string|boolean  -- Value to search
   column_name  = string                 -- The name of the column
   new_value    = Df_Dict                -- Value to replace with
})
```

Change value for a line where a column has a certain value

_Return value_: void

## Statistical functions

<a name="Dataframe.value_counts">
### Dataframe.value_counts(self, column_name[, normalize][, dropna])

Counts number of occurences for each unique element (frequency/histogram) in
a single column or set of columns. If a single column is requested then it returns
a simple table with element names as keys and counts/proportions as values.
If multiple keys have been requested it returns a table wrapping the single
column counts with column name as key.

```
({
   self        = Dataframe  -- 
   column_name = string     -- column to inspect
  [normalize   = boolean]   -- 	 	If True then the object returned will contain the relative frequencies of
		the unique values. [default=false]
  [dropna      = boolean]   -- Don’t include counts of NaN (missing values). [default=true]
})
```

_Return value_: Table
If columns is left out then all numerical columns are used

```
({
   self      = Dataframe  -- 
  [normalize = boolean]   -- 	 	If True then the object returned will contain the relative frequencies of
		the unique values. [default=false]
  [dropna    = boolean]   -- Don’t include counts of NaN (missing values). [default=true]
})
```

Use the columns argument together with a Df_Array for specifying columns

```
({
   self      = Dataframe  -- 
   columns   = Df_Array   -- The columns to inspect
  [normalize = boolean]   -- 	 	If True then the object returned will contain the relative frequencies of
		the unique values. [default=false]
  [dropna    = boolean]   -- Don’t include counts of NaN (missing values). [default=true]
})
```

_Return value_: Table
<a name="Dataframe.get_mode">
### Dataframe.get_mode(self, column_name[, normalize][, dropna])

```
({
   self        = Dataframe  -- 
   column_name = string     -- column to inspect
  [normalize   = boolean]   -- 	 	If True then the object returned will contain the relative frequencies of
		the unique values. [default=false]
  [dropna      = boolean]   -- Don’t include counts of NaN (missing values). [default=true]
})
```

_Return value_: Table
If you provide no column name then all numerical columns will be used

```
({
   self      = Dataframe  -- 
  [normalize = boolean]   -- 	 	If True then the object returned will contain the relative frequencies of
		the unique values. [default=false]
  [dropna    = boolean]   -- Don’t include counts of NaN (missing values). [default=true]
})
```

_Return value_: Table

```
({
   self      = Dataframe  -- 
   columns   = Df_Array   -- The columns of interest
  [normalize = boolean]   -- 	 	If True then the object returned will contain the relative frequencies of
		the unique values. [default=false]
  [dropna    = boolean]   -- Don’t include counts of NaN (missing values). [default=true]
})
```

<a name="Dataframe.get_max_value">
### Dataframe.get_max_value(self, column_name)

Gets the maximum value for a given column. Returns maximum values for all
numerical columns if none is provided. Keeps the order although not if
with_named_keys == true as the keys will be sorted in alphabetic order.

```
({
   self        = Dataframe  -- 
   column_name = string     -- The name of the column
})
```

_Return value_: number
You can in addition choose or supplying a Df_Array with the columns of interest

```
({
   self            = Dataframe  -- 
   columns         = Df_Array   -- The names of the columns of interest
  [with_named_keys = boolean]   -- If the index should be named keys [default=false]
})
```

_Return value_: Table
You can in addition choose all numerical columns by skipping the column name

```
({
   self            = Dataframe  -- 
  [with_named_keys = boolean]   -- If the index should be named keys [default=false]
})
```

_Return value_: Table
<a name="Dataframe.get_min_value">
### Dataframe.get_min_value(self, column_name)

Gets the minimum value for a given column. Returns minimum values for all
numerical columns if none is provided. Keeps the order although not if
with_named_keys == true as the keys will be sorted according to Lua's hash table
algorithm.

```
({
   self        = Dataframe  -- 
   column_name = string     -- The name of the column
})
```

_Return value_: number
You can in addition choose or supplying a Df_Array with the columns of interest

```
({
   self            = Dataframe  -- 
   columns         = Df_Array   -- The names of the columns of interest
  [with_named_keys = boolean]   -- If the index should be named keys [default=false]
})
```

_Return value_: Table
You can in addition choose all numerical columns by skipping the column name

```
({
   self            = Dataframe  -- 
  [with_named_keys = boolean]   -- If the index should be named keys [default=false]
})
```

_Return value_: Table

## Data loader functions

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
({
   self         = Dataframe  -- 
   data         = Df_Dict    -- Table (dictionary) to import. Max depth 2.
  [infer_schema = boolean]   -- automatically detect columns' type [default=true]
  [column_order = Df_Array]  -- The order of the column (has to be array and _not_ a dictionary) [default=false]
})
```

Imports a table data directly into Dataframe. The table should all be of equal length
or just single values. If a table contains one column with 10 rows and then has
another column with a single element that element is duplicated 10 times, i.e.
filling the entire column with that single value.
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
	
## Output functions

<a name="Dataframe.output">
### Dataframe.output(self[, html][, max_rows][, digits])

```
({
   self     = Dataframe        -- 
  [html     = boolean]         -- If the output should be in html format [default=false]
  [max_rows = number]          -- Limit the maximum number of printed rows [default=20]
  [digits   = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Prints the table into itorch.html if in itorch and html == true, otherwise prints a table string

_Return value_: void
<a name="Dataframe.show">
### Dataframe.show(self[, digits])

```
({
   self   = Dataframe        -- 
  [digits = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Prints the top  and bottom section of the table for better overview. Uses itorch if available

_Return value_: void
<a name="Dataframe.tostring">
### Dataframe.tostring(self)

```
({
   self = Dataframe  -- 
})
```

A convenience wrapper for __tostring

_Return value_: string
<a name="Dataframe.__tostring__">
### Dataframe.__tostring__(self[, digits])

```
({
   self   = Dataframe        -- 
  [digits = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Converts table to a string representation that follows standard markdown syntax

_Return value_: string
<a name="Dataframe._to_html">
### Dataframe._to_html(self[, split_table][, offset][, digits])

```
({
   self        = Dataframe        -- 
  [split_table = string]          -- 		Where the table is split. Valid input is 'none', 'top', 'bottom', 'all'.
		Note that the 'bottom' removes the trailing </table> while the 'top' removes
		the initial '<table>'. The 'all' removes both but retains the header while
		the 'top' has no header.
	 [default=none]
  [offset      = number]          -- The line index offset [default=0]
  [digits      = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Internal function to convert a table to html (only works for 1D table)

_Return value_: string

## Missing data functions

<a name="Dataframe.count_na">
### Dataframe.count_na(self)

```
({
   self = Dataframe  -- 
})
```

Count missing values in dataset

_Return value_: table containing missing values per column
You can manually choose the columns by providing a Df_Array

```
({
   self    = Dataframe  -- 
   columns = Df_Array   -- The columns to count
})
```

If you only want to count a single column

```
({
   self   = Dataframe  -- 
   column = string     -- The column to count
})
```

_Return value_: single integer
	<a name="Dataframe.fill_na">
### Dataframe.fill_na(self, column_name[, default_value])

Replace missing value in a specific column

```
({
   self          = Dataframe               -- 
   column_name   = string                  -- The column to fill
  [default_value = number|string|boolean]  -- The default missing value [default=0]
})
```

_Return value_: void
<a name="Dataframe.fill_na">
### Dataframe.fill_na(self[, default_value])

Replace missing value in all columns

```
({
   self          = Dataframe               -- 
  [default_value = number|string|boolean]  -- The default missing value [default=0]
})
```

_Return value_: void
	
