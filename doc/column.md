
## Column functions

<a name="Dataframe.is_numerical">
### Dataframe.is_numerical(self, column_name)

Checks if column is numerical

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column name to check
})
```

_Return value_: boolean
<a name="Dataframe.is_string">
### Dataframe.is_string(self, column_name)

Checks if column is of string type

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column name to check
})
```

_Return value_: boolean
<a name="Dataframe.is_boolean">
### Dataframe.is_boolean(self, column_name)

Checks if column is of boolean type

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column name to check
})
```

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
<a name="Dataframe.assert_has_column">
### Dataframe.assert_has_column(self, column_name[, comment])

Asserts that column is in the dataset

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column to check
  [comment     = string]    -- Comments that are to be displayed with the error [default=]
})
```


_Return value_: boolean
<a name="Dataframe.assert_has_not_column">
### Dataframe.assert_has_not_column(self, column_name[, comment])

Asserts that column is not in the dataset

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column to check
  [comment     = string]    -- Comments that are to be displayed with the error [default=]
})
```


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

_Return value_: self
You can also delete multiple columns by supplying a Df_Array

```
({
   self    = Dataframe  -- 
   columns = Df_Array   -- The columns to drop
})
```
<a name="Dataframe.add_column">
### Dataframe.add_column(self, column_name)

Add new column to Dataframe. Automatically orders the column last, i.e. furthest to
the right.

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column to add
})
```

_Return value_: self
The default_value argument will fill the new column. If omitted will be 0/0

```
({
   self          = Dataframe              -- 
   column_name   = string                 -- The column to add
   default_value = number|string|boolean  -- The default_value
})
```
You can also specify the position of the new column by using the pos argument. When
specifying the position you also must provide the default_value.

```
({
   self          = Dataframe              -- 
   column_name   = string                 -- The column to add
   pos           = number                 -- The position to input the column at, 1 == furthest to the left
   default_value = number|string|boolean  -- The default_value
})
```
If you have a column with values to add then use the Df_Array together with
default_value

```
({
   self           = Dataframe  -- 
   column_name    = string     -- The column to add
  [pos            = number]    -- The position to input the column at, 1 == furthest to the left [default=-1]
   default_values = Df_Array   -- The default values
})
```

Bind data columnwise together

```
({
   self = Dataframe  -- 
   data = Dataframe  -- The other dataframe to bind
})
```

_Return value_: self

```
({
   self = Dataframe  -- 
   data = Df_Dict    -- The other data to bind
})
```

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

_Return value_: self

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

_Return value_: self
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
<a name="Dataframe.swap_column_order">
### Dataframe.swap_column_order(self, first, second)

Swaps the column order for two columns

```
({
   self   = Dataframe  -- 
   first  = string     -- The name of the first column
   second = string     -- The name of the second column
})
```

_Return value_: self
<a name="Dataframe.pos_column_order">
### Dataframe.pos_column_order(self, column_name, position)

Set a position in the column order

```
({
   self        = Dataframe  -- 
   column_name = string     -- The name of the column
   position    = number     -- An integer that indicates the position to insert at
})
```

_Return value_: self
