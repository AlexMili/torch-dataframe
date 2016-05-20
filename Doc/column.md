
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
