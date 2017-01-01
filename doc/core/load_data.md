# API documentation for [Data loader functions](#__Data loader functions__)
- [Dataframe.load_csv](#Dataframe.load_csv)
- [Dataframe.bulk_load_csv](#Dataframe.bulk_load_csv)
- [Dataframe.load_table](#Dataframe.load_table)
- [Dataframe.`_clean_columns`](#Dataframe._clean_columns)

<a name="__Data loader functions__">
## Data loader functions

<a name="Dataframe.load_csv">
### Dataframe.load_csv(self, path[, header][, schema][, separator][, skip][, verbose][, rows2explore])

Loads a CSV file into Dataframe using csvigo as backend

```
({
   self         = Dataframe  -- 
   path         = string     -- path to file
  [header       = boolean]   -- if has header on first line [default=true]
  [schema       = Df_Dict]   -- The column schema types with column names as keys
  [separator    = string]    -- separator (one character) [default=,]
  [skip         = number]    -- skip this many lines at start of file [default=0]
  [verbose      = boolean]   -- verbose load [default=false]
  [rows2explore = number]    -- The maximum number of rows to traverse when trying to identify schema
})
```

_Return value_: self
	<a name="Dataframe.bulk_load_csv">
### Dataframe.bulk_load_csv(self, path[, header][, schema][, separator][, skip][, verbose][, nthreads])

Loads a CSV file into Dataframe using multithreading.
Warning : this method does not do the same checks as load_csv would do. It doesn't handle other format than torch.*Tensor and tds.Vec.

```
({
   self      = Dataframe  -- 
   path      = string     -- path to file
  [header    = boolean]   -- if has header on first line (not used at the moment) [default=true]
  [schema    = Df_Dict]   -- The column schema types with column names as keys
  [separator = string]    -- separator (one character) [default=,]
  [skip      = number]    -- skip this many lines at start of file (not used at the moment) [default=0]
  [verbose   = boolean]   -- verbose load [default=false]
  [nthreads  = number]    -- Number of threads to use to read the csv file [default=1]
})
```

_Return value_: self
	<a name="Dataframe.load_table">
### Dataframe.load_table(self, data[, schema][, column_order])

```
({
   self         = Dataframe  -- 
   data         = Df_Dict    -- Table (dictionary) to import. Max depth 2.
  [schema       = Df_Dict]   -- Provide if you want to force column types
  [column_order = Df_Array]  -- The order of the column (has to be array and _not_ a dictionary)
})
```

Imports a table data directly into Dataframe. The table should all be of equal length
or just single values. If a table contains one column with 10 rows and then has
another column with a single element that element is duplicated 10 times, i.e.
filling the entire column with that single value.


_Return value_: self
	<a name="Dataframe._clean_columns">
### Dataframe._clean_columns(self, data[, column_order][, schema])

```
{
   self         = Dataframe  -- 
   data         = table      -- 
  [column_order = table]     -- 
  [schema       = table]     -- 
}
```

Internal function to clean columns names

_Return value_: self