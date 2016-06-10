
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
