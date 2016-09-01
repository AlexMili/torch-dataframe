# API documentation for [utility functions](#__Utility functions__)
- [trim](#trim)
- [trim_table_strings](#trim_table_strings)
- [table.array2hash](#table.array2hash)
- [get_variable_type](#get_variable_type)
- [warning](#warning)
- [convert_table_2_dataframe](#convert_table_2_dataframe)

<a name="__Utility functions__">
## Utility functions

Here are utility functions that are not specific to the dataframe but add a general
Lua functionality.

<a name="trim">
### trim(s[, ignore])

Trims a string fro whitespace chars

```
({
   s      = string   -- The string to trim
  [ignore = number]  -- As gsub returns a number this needs to be ignored [default=false]
})
```

_Return value_: string
<a name="trim_table_strings">
### trim_table_strings(t)

Trims a table with strings fro whitespace chars

```
({
   t = table  -- The table with strings to trim
})
```

_Return value_: string
<a name="table.array2hash">
### table.array2hash(array)

Converts an array to hash table with numbers corresponding to the index of the
original elements position in the array. Intended for use with arrays where all
values are unique.

```
({
   array = table  -- An array of elements
})
```

_Return value_: table with string keys
<a name="get_variable_type">
### get_variable_type(value[, prev_type])

Checks the variable type for a string/numeric/boolean variable. Missing values
`nan` or "" are ignored. If a previous value is provided then the new variable
type will be in relation to the previous. I.e. if you provide an integer after
previously seen a double then the type will still be double.

```
({
   value     = !table   -- The value to type-check
  [prev_type = string]  -- The previous value type
})
```

_Return value_: string of type: 'boolean', 'integer', 'long', 'double', or 'string'
<a name="warning">
### warning(ARGP)

A function for printing warnings, i.e. events that souldn't occur but are not
serious anough to throw an error. If you want to supress the warning then set
the `no_warnings = true` in the global environement.

@ARPT
<a name="convert_table_2_dataframe">
### convert_table_2_dataframe(tbl[, value_name][, key_name])

Converts a table to a Dataframe

```
({
   tbl        = Df_Tbl   -- 
  [value_name = string]  -- The name of the value column [default=value]
  [key_name   = string]  -- The name of the key column [default=key]
})
```

_Return value_: Dataframe