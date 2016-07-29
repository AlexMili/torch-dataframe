
## Core functions

<a name="Dataframe.__init">
### Dataframe.__init(self)

Creates and initializes a Dataframe class. Envoked through `local my_dataframe = Dataframe()`

```
({
   self = Dataframe  -- 
})
```

Read in an csv-filef

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
  [column_order = Df_Array]  -- The order of the column (has to be array and _not_ a dictionary) [default=false]
})
```

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
### Dataframe.upgrade_frame(self)

Upgrades a dataframe using the old batch loading framework to the new framework
by instantiating the subsets argument, copying the indexes and setting the
samplers to either:

- linear for test/validate or shuffle = false
- permutation if shuffle = true and none of above names

```
({
   self = Dataframe  -- 
})
```

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
