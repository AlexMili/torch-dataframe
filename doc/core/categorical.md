# API documentation for [categorical functions](#__Categorical functions__)
- [Dataframe.as_categorical](#Dataframe.as_categorical)
- [Dataframe.add_cat_key](#Dataframe.add_cat_key)
- [Dataframe.as_string](#Dataframe.as_string)
- [Dataframe.clean_categorical](#Dataframe.clean_categorical)
- [Dataframe.is_categorical](#Dataframe.is_categorical)
- [Dataframe.get_cat_keys](#Dataframe.get_cat_keys)
- [Dataframe.to_categorical](#Dataframe.to_categorical)
- [Dataframe.from_categorical](#Dataframe.from_categorical)
- [Dataframe.boolean2categorical](#Dataframe.boolean2categorical)

<a name="__Categorical functions__">
## Categorical functions

<a name="Dataframe.as_categorical">
### Dataframe.as_categorical(self, column_name[, levels][, labels][, exclude])

Set a column to categorical type.

```
({
   self        = Dataframe          -- 
   column_name = string             -- The column name to convert
  [levels      = Df_Array|boolean]  -- An optional array of the values that column might have taken.
	 The default is the unique set of values taken by Dataframe.unique,
	 sorted into increasing order. If you provide values that aren't present
	 within the current column the value will still be saved and may be envoked in
	 the future. [default=false]
  [labels      = Df_Array|boolean]  -- An optional character vector of labels for the levels
	 (in the same order as levels after removing those in exclude) [default=false]
  [exclude     = Df_Array|boolean]  -- Values to be excluded when forming the set of levels. This should be
	 of the same type as column, and will be coerced if necessary. [default=false]
})
```

_Return value_: self

```
({
   self         = Dataframe          -- 
   column_array = Df_Array           -- An array with column names
  [levels       = Df_Array|boolean]  -- An optional array of the values that column might have taken.
	 The default is the unique set of values taken by Dataframe.unique,
	 sorted into increasing order. If you provide values that aren't present
	 within the current column the value will still be saved and may be envoked in
	 the future. [default=false]
  [labels       = Df_Array|boolean]  -- An optional character vector of labels for the levels
	 (in the same order as levels after removing those in exclude) [default=false]
  [exclude      = Df_Array|boolean]  -- Values to be excluded when forming the set of levels. This should be
	 of the same type as column, and will be coerced if necessary. [default=false]
})
```

<a name="Dataframe.add_cat_key">
### Dataframe.add_cat_key(self, column_name, key)

Adds a key to the keyset of a categorical column. Mostly intended for internal use.

```
({
   self        = Dataframe      -- 
   column_name = string         -- The column name
   key         = number|string  -- The new key to insert
})
```

_Return value_: index value for key (integer)
	<a name="Dataframe.as_string">
### Dataframe.as_string(self, column_name)

Converts a categorical column to a string column. This can be used to revert
the Dataframe.as_categorical or as a way to convert numericals into strings.

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column name
})
```

_Return value_: self
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

_Return value_: self
<a name="Dataframe.is_categorical">
### Dataframe.is_categorical(self, column_name)

Check if a column is categorical

```
({
   self        = Dataframe  -- 
   column_name = string     -- the name of the column
})
```

_Return value_: boolean
<a name="Dataframe.get_cat_keys">
### Dataframe.get_cat_keys(self, column_name)

Get keys from a categorical column.

```
({
   self        = Dataframe  -- 
   column_name = string     -- the name of the column
})
```

_Return value_: table with `["key"] = number` structure
<a name="Dataframe.to_categorical">
### Dataframe.to_categorical(self, data, column_name)

Converts values to categorical according to a column's keys

```
({
   self        = Dataframe                      -- 
   data        = number|torch.*Tensor|Df_Array  -- The integer to be converted
   column_name = string                         -- The name of the column  which keys to use
})
```

_Return value_: string with the value
<a name="Dataframe.from_categorical">
### Dataframe.from_categorical(self, data, column_name[, as_tensor])

```
({
   self        = Dataframe  -- 
   data        = Df_Array   -- The data to be converted
   column_name = string     -- The name of the column
  [as_tensor   = boolean]   -- If the returned value should be a tensor [default=false]
})
```

Converts categorical to numerical according to a column's keys

_Return value_: table or tensor

```
({
   self        = Dataframe      -- 
   data        = number|string  -- The data to be converted
   column_name = string         -- The name of the column
})
```

<a name="Dataframe.boolean2categorical">
### Dataframe.boolean2categorical(self, column_name[, false_str][, true_str])

Converts a boolean column into a torch.ByteTensor of type integer

```
({
   self        = Dataframe  -- 
   column_name = string     -- The boolean column that you want to convert
  [false_str   = string]    -- The string value for false [default=false]
  [true_str    = string]    -- The string value for true [default=true]
})
```

_Return value_: self