# API documentation for [statistics](#__Statistics__)
- [Dataseries.count_na](#Dataseries.count_na)
- [Dataseries.unique](#Dataseries.unique)
- [Dataseries.value_counts](#Dataseries.value_counts)
- [Dataseries.which_max](#Dataseries.which_max)
- [Dataseries.which_min](#Dataseries.which_min)
- [Dataseries.get_mode](#Dataseries.get_mode)
- [Dataseries.get_max_value](#Dataseries.get_max_value)
- [Dataseries.get_min_value](#Dataseries.get_min_value)

<a name="__Statistics__">
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