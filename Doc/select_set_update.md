
## Subsetting and manipulation functions

<a name="Dataframe.sub">
### Dataframe.sub(self[, start][, stop])

```
({
   self  = Dataframe  -- 
  [start = number]    -- Row to start at [default=1]
  [stop  = number]    -- Last row to include [default=false]
})
```

Selects a subset of rows and returns those

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
### Dataframe._create_subset(self, index_items)

```
({
   self        = Dataframe  -- 
   index_items = Df_Array   -- The indexes to retrieve
})
```

Creates a class and returns a subset based on the index items. Intended for internal
use.

_Return value_: Dataframe
<a name="Dataframe.where">
### Dataframe.where(self, column, item_to_find)

```
({
   self         = Dataframe              -- 
   column       = string                 -- column to browse or findin the item argument
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

<a name="Dataframe.update">
### Dataframe.update(self, condition_function, update_function)

```
({
   self               = Dataframe  -- 
   condition_function = function   -- Function that tests if the row should be updated. It should accept a row table as an argument and return boolean
   update_function    = function   -- Function that updates the row. Takes the entire row as an argument, modifies it and returns the same.
})
```

_Return value_: void
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

_Return value_: void
