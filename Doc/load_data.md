
## Data loader functions

<a name="Dataframe.load_csv">
### Dataframe.load_csv(self, path[, header][, infer_schema][, separator][, skip][, verbose])

```
({
   self         = Dataframe  -- 
   path         = string     -- path to file
  [header       = boolean]   -- if has header on first line [default=true]
  [infer_schema = boolean]   -- automatically detect column's type [default=true]
  [separator    = string]    -- separator (one character) [default=,]
  [skip         = number]    -- skip this many lines at start of file [default=0]
  [verbose      = boolean]   -- verbose load [default=false]
})
```

Loads a CSV file into Dataframe using csvigo as backend

_Return value_: self
	<a name="Dataframe.load_table">
### Dataframe.load_table(self, data[, infer_schema][, column_order])

```
({
   self         = Dataframe         -- 
   data         = Df_Dict           -- Table (dictionary) to import. Max depth 2.
  [infer_schema = Df_Dict|boolean]  -- automatically detect columns' type or use previous schema [default=true]
  [column_order = Df_Array]         -- The order of the column (has to be array and _not_ a dictionary) [default=false]
})
```

Imports a table data directly into Dataframe. The table should all be of equal length
or just single values. If a table contains one column with 10 rows and then has
another column with a single element that element is duplicated 10 times, i.e.
filling the entire column with that single value.


_Return value_: self
	<a name="Dataframe._clean_columns">
### Dataframe._clean_columns(self)

```
({
   self = Dataframe  -- 
})
```

Internal function to clean columns names

_Return value_: self
	<a name="Dataframe._count_missing">
### Dataframe._count_missing(self)

```
({
   self = Dataframe  -- 
})
```

Internal function for counting all missing values. _Note_: internally Dataframe
uses nan (0/0) and this function only identifies missing values within an array.
This is used within the test cases.

_Return value_: number of missing values (integer)
	<a name="Dataframe._fill_missing">
### Dataframe._fill_missing(self)

```
({
   self = Dataframe  -- 
})
```

Internal function for changing missing values to NaN values.

_Return value_: self
	