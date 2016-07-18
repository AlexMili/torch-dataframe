
## Row functions

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
<a name="Dataframe.insert">
### Dataframe.insert(self, index, rows)

Inserts a row or multiple rows into database at the position of the provided index.

```
({
   self  = Dataframe  -- 
   index = number     -- The row number where to insert the row(s)
   rows  = Df_Dict    -- Insert values to the dataset
})
```

_Return value_: self
Note, if you provide a Dataframe the primary dataframes meta-information will
be the ones that are kept

```
({
   self  = Dataframe  -- 
   index = number     -- The row number where to insert the row(s)
   rows  = Dataframe  -- A Dataframe that you want to insert
})
```

<a name="Dataframe.append">
### Dataframe.append(self, rows[, column_order])

Appends the row(s) to the Dataframe.

```
({
   self         = Dataframe  -- 
   rows         = Df_Dict    -- Values to append to the Dataframe
  [column_order = Df_Array]  -- The order of the column (has to be array and _not_ a dictionary). Only used when the Dataframe is empty [default=false]
})
```

_Return value_: self
Note, if you provide a Dataframe the primary dataframes meta-information will
be the ones that are kept

```
({
   self = Dataframe  -- 
   rows = Dataframe  -- A Dataframe that you want to append
})
```

<a name="Dataframe.rbind">
### Dataframe.rbind(self, rows)

Alias to Dataframe.append

```
({
   self = Dataframe  -- 
   rows = Df_Dict    -- Values to append to the Dataframe
})
```

_Return value_: self
Note, if you provide a Dataframe the primary dataframes meta-information will
be the ones that are kept

```
({
   self = Dataframe  -- 
   rows = Dataframe  -- A Dataframe that you want to append
})
```

<a name="Dataframe.remove_index">
### Dataframe.remove_index(self, index)

Deletes a given row

```
({
   self  = Dataframe  -- 
   index = number     -- The row index to remove
})
```

_Return value_: self
