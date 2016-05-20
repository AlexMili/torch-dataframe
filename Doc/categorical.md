
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
