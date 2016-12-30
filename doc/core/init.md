# API documentation for [core functions](#__Core functions__)
- [Dataframe.`__init`](#Dataframe.__init)
- [Dataframe.get_schema](#Dataframe.get_schema)
- [Dataframe.shape](#Dataframe.shape)
- [Dataframe.version](#Dataframe.version)
- [Dataframe.set_version](#Dataframe.set_version)
- [Dataframe.upgrade_frame](#Dataframe.upgrade_frame)
- [Dataframe.assert_is_index](#Dataframe.assert_is_index)

<a name="__Core functions__">
## Core functions

<a name="Dataframe.__init">
### Dataframe.__init(self)

Creates and initializes a Dataframe class. Envoked through `local my_dataframe = Dataframe()`

```
({
   self = Dataframe  -- 
})
```

Read in an csv-file

```
({
   self     = Dataframe  -- 
   csv_file = string     -- The file path to the CSV
})
```

Directly input a table

```
({
   self         = Dataframe  -- 
   data         = Df_Dict    -- The data to read in
  [column_order = Df_Array]  -- The order of the column (has to be array and _not_ a dictionary)
})
```

If you enter column schema* and number of rows a table will be initialized. Note
that you can optionally set all non-set values to `nan` values but this may be
time-consuming for big datasets.

* A schema is a hash table with the column names as keys and the column types
as values. The column types are:
- `boolean`
- `integer`
- `long`
- `double`
- `string` (this is stored as a `tds.Vec` and can be any value)

```
({
   self         = Dataframe  -- 
   schema       = Df_Dict    -- The schema to use for initializaiton
   no_rows      = number     -- The number of rows
  [column_order = Df_Array]  -- The column order
  [set_missing  = boolean]   -- Whether all elements should be set to missing from start [default=false]
})
```

<a name="Dataframe.get_schema">
### Dataframe.get_schema(self, column_name)

Returns the schema, i.e. column types

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column to get schema for
})
```

_Return value_: string
```
({
   self    = Dataframe  -- 
  [columns = Df_Array]  -- The columns to get schema for
})
```

_Return value_: table
<a name="Dataframe.shape">
### Dataframe.shape(self)

Returns the number of rows and columns in a table

```
({
   self = Dataframe  -- 
})
```

_Return value_: table
<a name="Dataframe.version">
### Dataframe.version(self)

Returns the current data-frame version

```
({
   self = Dataframe  -- 
})
```

_Return value_: string
<a name="Dataframe.set_version">
### Dataframe.set_version(self)

Sets the data-frame version

```
({
   self = Dataframe  -- 
})
```

_Return value_: self
<a name="Dataframe.upgrade_frame">
### Dataframe.upgrade_frame(self[, skip_version][, current_version])

Upgrades a dataframe using the old batch loading framework to the new framework
by instantiating the subsets argument, copying the indexes and setting the
samplers to either:

- linear for test/validate or shuffle = false
- permutation if shuffle = true and none of above names

```
({
   self            = Dataframe  -- 
  [skip_version    = boolean]   -- Set to true if you want to upgrade your dataframe regardless of the version check
  [current_version = number]    -- The current version of the dataframe
})
```

*Note:* Sometimes the version check fails to identify that the Dataframe is of
an old version and you can therefore skip the version check.

_Return value_: Dataframe
<a name="Dataframe.assert_is_index">
### Dataframe.assert_is_index(self, index[, plus_one])

Asserts that the number is a valid index.

```
({
   self     = Dataframe  -- 
   index    = number     -- The index to investigate
  [plus_one = boolean]   -- When adding rows, an index of size(1) + 1 is OK [default=false]
})
```

_Return value_: Dataframe