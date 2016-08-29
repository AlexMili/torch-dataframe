# API documentation

- [Dataseries](#__Dataseries__)
- [Dataseries.__init(self, size[, type])](#Dataseries.__init)
- [Dataseries.copy(self)](#Dataseries.copy)
- [Dataseries.size(self)](#Dataseries.size)
- [Dataseries.resize(self, new_size)](#Dataseries.resize)
- [Dataseries.assert_is_index(self, index[, plus_one])](#Dataseries.assert_is_index)
- [Dataseries.is_numerical(self)](#Dataseries.is_numerical)
- [Dataseries.is_boolean(self)](#Dataseries.is_boolean)
- [Dataseries.is_string(self)](#Dataseries.is_string)
- [Dataseries.type(self)](#Dataseries.type)
- [Dataseries.get_variable_type(self)](#Dataseries.get_variable_type)
- [Dataseries.boolean2tensor(self, false_value, true_value)](#Dataseries.boolean2tensor)
- [Dataseries.fill(self, default_value)](#Dataseries.fill)
- [Dataseries.fill_na(self[, default_value])](#Dataseries.fill_na)
- [Dataseries.tostring(self[, max_elmnts])](#Dataseries.tostring)
- [Dataseries.sub(self[, start][, stop])](#Dataseries.sub)
- [Dataseries.eq(self, other)](#Dataseries.eq)
- [Dataseries.as_categorical(self[, levels][, labels][, exclude])](#Dataseries.as_categorical)
- [Dataseries.add_cat_key(self, key[, key_index])](#Dataseries.add_cat_key)
- [Dataseries.as_string(self)](#	Dataseries.as_string)
- [Dataseries.clean_categorical(self[, reset_keys])](#Dataseries.clean_categorical)
- [Dataseries.is_categorical(self)](#Dataseries.is_categorical)
- [Dataseries.get_cat_keys(self)](#Dataseries.get_cat_keys)
- [Dataseries.to_categorical(self, key_index)](#Dataseries.to_categorical)
- [Dataseries.from_categorical(self, data)](#Dataseries.from_categorical)
- [Dataseries.to_tensor(self[, missing_value][, copy])](#Dataseries.to_tensor)
- [Dataseries.to_table(self)](#Dataseries.to_table)
- [Dataseries.#](#Dataseries.#)
- [Dataseries.__tostring__(self)](#	Dataseries.__tostring__)
- [Dataseries.get(self, index[, as_raw])](#Dataseries.get)
- [Dataseries.set(self, index, value)](#Dataseries.set)
- [Dataseries.append(self, value)](#Dataseries.append)
- [Dataseries.remove(self, index)](#Dataseries.remove)
- [Dataseries.insert(self, index, value)](#Dataseries.insert)
- [Dataseries.count_na(self)](#Dataseries.count_na)
- [Dataseries.unique(self[, as_keys][, as_raw])](#Dataseries.unique)
- [Dataseries.value_counts(self[, normalize][, dropna][, as_raw][, as_dataframe])](#Dataseries.value_counts)
- [Dataseries.which_max(self)](#Dataseries.which_max)
- [Dataseries.which_min(self)](#Dataseries.which_min)
- [Dataseries.get_mode(self[, normalize][, dropna][, as_dataframe])](#Dataseries.get_mode)
- [Dataseries.get_max_value(self)](#Dataseries.get_max_value)
- [Dataseries.get_min_value(self)](#Dataseries.get_min_value)

<a name="__Dataseries__">
## Dataseries

The Dataseries is an array of data with an additional layer
of missing data info. The class contains two main elements:

* A data container
* A hash with the missing data positions

The missing data are presented as `nan` values. A `nan` has the
behavior that `nan ~= nan` evaluates to `true`. There is a helper
function in the package, `isnan()`, that can be used to identify
`nan` values.

The class has the following metatable functions available:

* `__index__`: You can access any element by `[]`
* `__newindex__`: You can set the value of an element via `[]`
* `__len__`: The `#` returns the length of the series
<a name="Dataseries.__init">
### Dataseries.__init(self, size[, type])

Creates and initializes a Dataseries class. Envoked through `local my_series = Dataseries()`.
The type can be:
- boolean
- integer
- double
- string
- torch tensor or tds.Vec

```
({
   self = Dataseries  -- 
   size = number      -- The size of the new series
  [type = string]     -- The type of data storage to init.
})
```


```
({
   self = Dataseries             -- 
   data = torch.*Tensor|tds.Vec  -- 
})
```

<a name="Dataseries.copy">
### Dataseries.copy(self)

Creates a new Dataseries and with a copy/clone of the current data

```
({
   self = Dataseries  -- 
})
```

_Return value_: Dataseries
<a name="Dataseries.size">
### Dataseries.size(self)

Returns the number of elements in the Dataseries

```
({
   self = Dataseries  -- 
})
```

_Return value_: number
<a name="Dataseries.resize">
### Dataseries.resize(self, new_size)

Resizes the underlying storage to the new size. If the size is shrunk
then it also clears any missing values in the hash. If the size is increased
the new values are automatically set to missing.

```
({
   self     = Dataseries  -- 
   new_size = number      -- The new size for the series
})
```

_Return value_: self
<a name="Dataseries.assert_is_index">
### Dataseries.assert_is_index(self, index[, plus_one])

Assertion that checks if index is an integer and within the span of the series

```
({
   self     = Dataseries  -- 
   index    = number      -- The index to check
  [plus_one = boolean]    -- When adding rows, an index of size(1) + 1 is OK [default=false]
})
```

_Return value_: self
<a name="Dataseries.is_numerical">
### Dataseries.is_numerical(self)

Checks if numerical

```
({
   self = Dataseries  -- 
})
```

_Return value_: boolean
<a name="Dataseries.is_boolean">
### Dataseries.is_boolean(self)

Checks if boolean

```
({
   self = Dataseries  -- 
})
```

_Return value_: boolean
<a name="Dataseries.is_string">
### Dataseries.is_string(self)

Checks if boolean

```
({
   self = Dataseries  -- 
})
```

_Return value_: boolean
<a name="Dataseries.type">
### Dataseries.type(self)

Gets the torch.typename of the storage

```
({
   self = Dataseries  -- 
})
```

_Return value_: string
<a name="Dataseries.get_variable_type">
### Dataseries.get_variable_type(self)

Gets the variable type that was used to initiate the Dataseries

```
({
   self = Dataseries  -- 
})
```

_Return value_: string
<a name="Dataseries.boolean2tensor">
### Dataseries.boolean2tensor(self, false_value, true_value)

Converts a boolean Dataseries into a torch.ByteTensor

```
({
   self        = Dataseries  -- 
   false_value = number      -- The numeric value for false
   true_value  = number      -- The numeric value for true
})
```

_Return value_: self, boolean indicating successful conversion
<a name="Dataseries.fill">
### Dataseries.fill(self, default_value)

Fills all values with a default value

```
({
   self          = Dataseries             -- 
   default_value = number|string|boolean  -- The default value
})
```

_Return value_: self
<a name="Dataseries.fill_na">
### Dataseries.fill_na(self[, default_value])

Replace missing values with a specific value

```
({
   self          = Dataseries              -- 
  [default_value = number|string|boolean]  -- The default missing value [default=0]
})
```

_Return value_: self
<a name="Dataseries.tostring">
### Dataseries.tostring(self[, max_elmnts])

Converts the series into a string output

```
({
   self       = Dataseries  -- 
  [max_elmnts = number]     --  [default=20]
})
```

_Return value_: string
<a name="Dataseries.sub">
### Dataseries.sub(self[, start][, stop])

Subsets the Dataseries to the element span

```
({
   self  = Dataseries  -- 
  [start = number]     --  [default=1]
  [stop  = number]     -- 
})
```

_Return value_: Dataseries
<a name="Dataseries.eq">
### Dataseries.eq(self, other)

Compares to Dataseries or table in order to see if they are identical

```
({
   self  = Dataseries        -- 
   other = Dataseries|table  -- 
})
```

_Return value_: string

## Categorical functions

Here are functions are used for converting to and from categorical type. The
categorical series type is a hash table around a torch.IntTensor that maps
numerical values between integer and string values. The standard numbering is
from 1 to n unique values.

<a name="Dataseries.as_categorical">
### Dataseries.as_categorical(self[, levels][, labels][, exclude])

Set a series to categorical type. The keys retrieved from Dataseries.unique.

```
({
   self    = Dataseries         -- 
  [levels  = Df_Array|boolean]  -- An optional array of the values that series might have taken.
	 The default is the unique set of values taken by Dataseries.unique,
	 sorted into increasing order. If you provide values that aren't present
	 within the current series the value will still be saved and may be envoked in
	 the future.
  [labels  = Df_Array|boolean]  -- An optional character vector of labels for the levels
	 (in the same order as levels after removing those in exclude)
  [exclude = Df_Array|boolean]  -- Values to be excluded when forming the set of levels. This should be
	 of the same type as the series, and will be coerced if necessary.
})
```

_Return value_: self
<a name="Dataseries.add_cat_key">
### Dataseries.add_cat_key(self, key[, key_index])

Adds a key to the keyset of a categorical series. Mostly intended for internal use.

```
({
   self      = Dataseries     -- 
   key       = number|string  -- The new key to insert
  [key_index = number]        -- The key index to use
})
```

_Return value_: index value for key (integer)
	<a name="Dataseries.as_string">
### Dataseries.as_string(self)

Converts a categorical Dataseries to a string Dataseries. This can be used to revert
the Dataseries.as_categorical or as a way to convert numericals into strings.

```
({
   self = Dataseries  -- 
})
```

_Return value_: self
<a name="Dataseries.clean_categorical">
### Dataseries.clean_categorical(self[, reset_keys])

```
({
   self       = Dataseries  -- 
  [reset_keys = boolean]    -- if all the keys should be reinitialized [default=false]
})
```

Removes any categories no longer present from the keys

_Return value_: self
<a name="Dataseries.is_categorical">
### Dataseries.is_categorical(self)

Check if a Dataseries is categorical

```
({
   self = Dataseries  -- 
})
```

_Return value_: boolean
<a name="Dataseries.get_cat_keys">
### Dataseries.get_cat_keys(self)

Get keys

```
({
   self = Dataseries  -- 
})
```

_Return value_: table with `["key"] = number` structure
<a name="Dataseries.to_categorical">
### Dataseries.to_categorical(self, key_index)

Converts values to categorical according to a series's keys

```
({
   self      = Dataseries  -- 
   key_index = number      -- The integer to be converted
})
```

_Return value_: string with the value. If provided `nan` it will also
 return a `nan`. It returns `nil` if no key is found
You can also provide a tensor

```
({
   self = Dataseries     -- 
   data = torch.*Tensor  -- The integers to be converted
})
```

_Return value_: table with values
You can also provide an array

```
({
   self = Dataseries  -- 
   data = Df_Array    -- The integers to be converted
})
```

_Return value_: table with values
<a name="Dataseries.from_categorical">
### Dataseries.from_categorical(self, data)

Converts categorical to numerical according to a Dataseries's keys

```
({
   self = Dataseries     -- 
   data = number|string  -- The data to be converted
})
```

_Return value_: table or tensor
You can also provide an array with values

```
({
   self      = Dataseries  -- 
   data      = Df_Array    -- The data to be converted
  [as_tensor = boolean]    -- If the returned value should be a tensor [default=false]
})
```

_Return value_: table or tensor
Checks if categorical key exists

```
({
   self  = Dataseries     -- 
   value = number|string  -- The value that should be present in the categorical hash
})
```

_Return value_: boolean
Checks if categorical value exists

```
({
   self  = Dataseries     -- 
   value = number|string  -- The value that should be present in the categorical hash
})
```

_Return value_: boolean

## Export functions

Here are functions are used for exporting to a different format. Generally `to_`
functions should reside here. Only exception is the `tostring`.

<a name="Dataseries.to_tensor">
### Dataseries.to_tensor(self[, missing_value][, copy])

Returns the values in tensor format. Note that if you don't provide a replacement
for missing values and there are missing values the function will throw an error.

*Note*: boolean columns are not tensors and need to be manually converted to a
tensor. This since 0 would be a natural value for false but can cause issues as
neurons are labeled 1 to n for classification tasks. See the `Dataframe.update`
function for details or run the `boolean2tensor`.

```
({
   self          = Dataseries  -- 
  [missing_value = number]     -- Set a value for the missing data
  [copy          = boolean]    -- Set to false if you want the original data to be returned. [default=true]
})
```

_Return value_: torch.*Tensor of the current type
<a name="Dataseries.to_table">
### Dataseries.to_table(self)

Returns the values in table format

```
({
   self = Dataseries  -- 
})
```

_Return value_: table

## Metatable functions

<a name="Dataseries.#">
### Dataseries.#

Returns the number of elements

_Return value_: integer
	<a name="Dataseries.__tostring__">
### Dataseries.__tostring__(self)

A wrapper for `tostring()`

```
({
   self = Dataseries  -- 
})
```

_Return value_: string

## Single element functions

Here are functions are mainly used for manipulating a single element.

<a name="Dataseries.get">
### Dataseries.get(self, index[, as_raw])

Gets a single or a set of elements.

```
({
   self   = Dataseries  -- 
   index  = number      -- The index to set the value to
  [as_raw = boolean]    -- Set to true if you want categorical values to be returned as their raw numeric representation [default=false]
})
```

_Return value_: number|string|boolean
If you provde a Df_Array you get back a Dataseries of elements

```
({
   self  = Dataseries  -- 
   index = Df_Array    -- 
})
```

_Return value_:  Dataseries
<a name="Dataseries.set">
### Dataseries.set(self, index, value)

Sets a single element

```
({
   self  = Dataseries  -- 
   index = number      -- The index to set the value to
   value = *           -- The data to set
})
```

_Return value_: self
<a name="Dataseries.append">
### Dataseries.append(self, value)

Appends a single element to series. This function resizes the tensor to +1
and then calls the `set` function so if possible try to directly size the
series to apropriate length before setting elements as this alternative is
slow and should only be used with a few values at the time.

```
({
   self  = Dataseries  -- 
   value = *           -- The data to set
})
```

_Return value_: self
<a name="Dataseries.remove">
### Dataseries.remove(self, index)

Removes a single element

```
({
   self  = Dataseries  -- 
   index = number      -- The index to remove
})
```

_Return value_: self
<a name="Dataseries.insert">
### Dataseries.insert(self, index, value)

Inserts a single element

```
({
   self  = Dataseries  -- 
   index = number      -- The index to insert at
   value = !table      -- The value to insert
})
```

_Return value_: self

## Statistics

Here are functions gather commmonly used descriptive statistics

<a name="Dataseries.count_na">
### Dataseries.count_na(self)

Count missing values

```
({
   self = Dataseries  -- 
})
```

_Return value_: number
<a name="Dataseries.unique">
### Dataseries.unique(self[, as_keys][, as_raw])

Get unique elements

```
({
   self    = Dataseries  -- 
  [as_keys = boolean]    -- return table with unique as keys and a count for frequency [default=false]
  [as_raw  = boolean]    -- return table with raw data without categorical transformation [default=false]
})
```

_Return value_: tds.Vec with unique values or
	tds.Hash if as_keys == true then the unique
	value as key with an incremental integer
	value => {'unique1':1, 'unique2':2, 'unique6':3}
<a name="Dataseries.value_counts">
### Dataseries.value_counts(self[, normalize][, dropna][, as_raw][, as_dataframe])

Counts number of occurences for each unique element (frequency/histogram).

```
({
   self         = Dataseries  -- 
  [normalize    = boolean]    -- 		If True then the object returned will contain the relative frequencies of
		the unique values. [default=false]
  [dropna       = boolean]    -- Don’t include counts of NaN (missing values). [default=true]
  [as_raw       = boolean]    -- Use raw numerical values instead of category label for categoricals [default=false]
  [as_dataframe = boolean]    -- Return a Dataframe with `value` and `count` columns [default=true]
})
```

_Return value_: Dataframe|table
<a name="Dataseries.which_max">
### Dataseries.which_max(self)

Retrieves the index for the rows with the highest value. Can be > 1 rows that
share the highest value.

```
({
   self = Dataseries  -- 
})
```

_Return value_: table with the highest indexes, max value
<a name="Dataseries.which_min">
### Dataseries.which_min(self)

Retrieves the index for the rows with the lowest value. Can be > 1 rows that
share the lowest value.

```
({
   self = Dataseries  -- 
})
```

_Return value_: table with the lowest indexes, lowest value
<a name="Dataseries.get_mode">
### Dataseries.get_mode(self[, normalize][, dropna][, as_dataframe])

Gets the mode for a Dataseries. A mode is defined as the most frequent value.
Note that if two or more values are equally common then there are several modes.
The mode is useful as it can be viewed as any algorithms most naive guess where
it always guesses the same value.

```
({
   self         = Dataseries  -- 
  [normalize    = boolean]    -- 	 	If True then the object returned will contain the relative frequencies of
		the unique values. [default=false]
  [dropna       = boolean]    -- Don’t include counts of NaN (missing values). [default=true]
  [as_dataframe = boolean]    -- Return a dataframe [default=true]
})
```

_Return value_: Table or Dataframe
<a name="Dataseries.get_max_value">
### Dataseries.get_max_value(self)

Gets the maximum value. Similar in function to which_max but it will also return
the maximum integer value for the categorical values. This can be useful when
deciding on the number of neurons in the final layer.

```
({
   self = Dataseries  -- 
})
```

_Return value_: number
<a name="Dataseries.get_min_value">
### Dataseries.get_min_value(self)

Gets the minimum value for a given column. Returns minimum values for all
numerical columns if none is provided.

```
({
   self = Dataseries  -- 
})
```

_Return value_: number