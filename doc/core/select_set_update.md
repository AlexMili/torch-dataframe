# API documentation for [subsetting and manipulation functions](#__Subsetting and manipulation functions__)
- [Dataframe.sub](#Dataframe.sub)
- [Dataframe.get_random](#Dataframe.get_random)
- [Dataframe.head](#Dataframe.head)
- [Dataframe.tail](#Dataframe.tail)
- [Dataframe.`_create_subset`](#Dataframe._create_subset)
- [Dataframe.where](#Dataframe.where)
- [Dataframe.which](#Dataframe.which)
- [Dataframe.update](#Dataframe.update)
- [Dataframe.set](#Dataframe.set)
- [Dataframe.wide2long](#Dataframe.wide2long)

<a name="__Subsetting and manipulation functions__">
## Subsetting and manipulation functions

<a name="Dataframe.sub">
### Dataframe.sub(self[, start][, stop])

Selects a subset of rows and returns those

```
({
   self  = Dataframe  -- 
  [start = number]    -- Row to start at [default=1]
  [stop  = number]    -- Last row to include [default=false]
})
```

_Return value_: Dataframe
<a name="Dataframe.get_random">
### Dataframe.get_random(self[, n_items])

```
({
   self    = Dataframe  -- 
  [n_items = number]    -- Number of rows to retrieve [default=1]
})
```

Retrieves a random number of rows for exploring

_Return value_: Dataframe
<a name="Dataframe.head">
### Dataframe.head(self[, n_items])

```
({
   self    = Dataframe  -- 
  [n_items = number]    -- Number of rows to retrieve [default=10]
})
```

Retrieves the first elements of a table

_Return value_: Dataframe
<a name="Dataframe.tail">
### Dataframe.tail(self[, n_items])

```
({
   self    = Dataframe  -- 
  [n_items = number]    -- Number of rows to retrieve [default=10]
})
```

Retrieves the last elements of a table

_Return value_: Dataframe
<a name="Dataframe._create_subset">
### Dataframe._create_subset(self, index_items[, frame_type][, class_args])

Creates a class and returns a subset based on the index items. Intended for internal
use. The method is primarily intended for internal use.

```
({
   self        = Dataframe            -- 
   index_items = Df_Array|Dataseries  -- The indexes to retrieve
  [frame_type  = string]              -- Choose any of the avaiable frame Dataframe classes to be returned as:
	 - Dataframe
	 - Batchframe
	 - Df_Subset
	 If left empty it will default to the given torch.type(self)
	 
  [class_args  = Df_Tbl]              -- Arguments to be passed to the class initializer
})
```

_Return value_: Dataframe or Batchframe
<a name="Dataframe.where">
### Dataframe.where(self, column_name, item_to_find)

```
({
   self         = Dataframe              -- 
   column_name  = string                 -- column to browse or findin the item argument
   item_to_find = number|string|boolean  -- The value to find
})
```

Find the rows where the column has the given value

_Return value_: Dataframe
You can also provide a function for more advanced matching

```
({
   self     = Dataframe  -- 
   match_fn = function   -- Function that takes a row as an argument and returns boolean
})
```

<a name="Dataframe.which">
### Dataframe.which(self, condition_function)

```
({
   self               = Dataframe  -- 
   condition_function = function   -- Function that returns true if a condition is met. Received the entire row as a table argument.
})
```

Finds the rows that match the arguments

_Return value_: table
If you provide a value and a column it will look for identical matches

```
({
   self        = Dataframe           -- 
   column_name = string              -- The column with the value
   value       = number|boolean|nan  -- 
})
```

_Return value_: table
If that column is a string you also have the option of supplying a regular expression

```
({
   self        = Dataframe  -- 
   column_name = string     -- The column with the value
   value       = string     -- 
  [regex       = boolean]   -- If the string is aregular expression [default=false]
})
```

_Return value_: table
<a name="Dataframe.update">
### Dataframe.update(self, condition_function, update_function)

```
({
   self               = Dataframe  -- 
   condition_function = function   -- Function that tests if the row should be updated. It should accept a row table as an argument and return boolean
   update_function    = function   -- Function that updates the row. Takes the entire row as an argument, modifies it and returns the same.
})
```

_Return value_: Dataframe
<a name="Dataframe.set">
### Dataframe.set(self, item_to_find, column_name, new_value)

```
({
   self         = Dataframe              -- 
   item_to_find = number|string|boolean  -- Value to search
   column_name  = string                 -- The name of the column
   new_value    = Df_Dict                -- Value to replace with
})
```

Change value for a line where a column has a certain value

_Return value_: Dataframe
You can also provide the index that you want to set

```
({
   self       = Dataframe  -- 
   index      = number     -- Row index number
   new_values = Df_Dict    -- Value to replace with
})
```

_Return value_: Dataframe
<a name="Dataframe.wide2long">
### Dataframe.wide2long(self, columns, id_name, value_name)

Change table from wide format, i.e. where a labels are split over multiple columns
into a case where all the values are in one column and adjacent is a column with
the column names.

```
({
   self       = Dataframe  -- 
   columns    = Df_Array   -- The columns that are to be merged
   id_name    = string     -- The column name for where to store the old column names
   value_name = string     -- The column name for where to store the values
})
```

_Return value_: Dataframe
You can also provide a regular expression for column names

```
({
   self         = Dataframe  -- 
   column_regex = string     -- Regular expression for the columns that are to be merged
   id_name      = string     -- The column name for where to store the old column names
   value_name   = string     -- The column name for where to store the values
})
```