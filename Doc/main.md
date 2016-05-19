
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
