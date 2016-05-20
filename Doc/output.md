
## Output functions

<a name="Dataframe.output">
### Dataframe.output(self[, html][, max_rows][, digits])

```
({
   self     = Dataframe        -- 
  [html     = boolean]         -- If the output should be in html format [default=false]
  [max_rows = number]          -- Limit the maximum number of printed rows [default=20]
  [digits   = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Prints the table into itorch.html if in itorch and html == true, otherwise prints a table string

_Return value_: void
<a name="Dataframe.show">
### Dataframe.show(self[, digits])

```
({
   self   = Dataframe        -- 
  [digits = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Prints the top  and bottom section of the table for better overview. Uses itorch if available

_Return value_: void
<a name="Dataframe.tostring">
### Dataframe.tostring(self)

```
({
   self = Dataframe  -- 
})
```

A convenience wrapper for __tostring

_Return value_: string
<a name="Dataframe.__tostring__">
### Dataframe.__tostring__(self[, digits])

```
({
   self   = Dataframe        -- 
  [digits = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Converts table to a string representation that follows standard markdown syntax

_Return value_: string
<a name="Dataframe._to_html">
### Dataframe._to_html(self[, split_table][, offset][, digits])

```
({
   self        = Dataframe        -- 
  [split_table = string]          -- 		Where the table is split. Valid input is 'none', 'top', 'bottom', 'all'.
		Note that the 'bottom' removes the trailing </table> while the 'top' removes
		the initial '<table>'. The 'all' removes both but retains the header while
		the 'top' has no header.
	 [default=none]
  [offset      = number]          -- The line index offset [default=0]
  [digits      = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Internal function to convert a table to html (only works for 1D table)

_Return value_: string
