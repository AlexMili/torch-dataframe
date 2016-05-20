
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
