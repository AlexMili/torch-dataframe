
## Core functions

<a name="Dataframe.__init">
### Dataframe.__init(self)

Creates and initializes a Dataframe class. Envoked through `local my_dataframe = Dataframe()`

```
({
   self = Dataframe  -- 
})
```

_Return value_: Dataframe
Read in an csv-file

```
({
   self     = Dataframe  -- 
   csv_file = string     -- The file path to the CSV
})
```

_Return value_: Dataframe
Directly input a table

```
({
   self         = Dataframe  -- 
   data         = Df_Dict    -- The data to read in
  [column_order = Df_Array]  -- The order of the column (has to be array and _not_ a dictionary) [default=false]
})
```

_Return value_: Dataframe
<a name="Dataframe.shape">
### Dataframe.shape(self)

Returns the number of rows and columns in a table

```
({
   self = Dataframe  -- 
})
```

_Return value_: table
<a name="Dataframe.size">
### Dataframe.size(self)

Returns the number of rows and columns in a tensor

```
({
   self = Dataframe  -- 
})
```

_Return value_: tensor (rows, columns)
By providing dimension you can get only that dimension, row == 1, col == 2

```
({
   self = Dataframe  -- 
   dim  = number     -- The dimension of interest
})
```

_Return value_: integer
<a name="Dataframe.version">
### Dataframe.version(self)

Returns the current data-frame version

```
({
   self = Dataframe  -- 
})
```

_Return value_: string
