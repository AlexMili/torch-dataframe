
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

_Return value_: self
<a name="Dataframe.show">
### Dataframe.show(self[, digits])

```
({
   self   = Dataframe        -- 
  [digits = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
})
```

Prints the top  and bottom section of the table for better overview. Uses itorch if available

_Return value_: self
<a name="Dataframe.tostring">
### Dataframe.tostring(self[, digits][, columns2skip][, no_rows][, min_col_width][, max_table_width])

Converts table to a string representation that follows standard markdown syntax.
The table tries to follow a maximum table width inspired by the `dplyr` table print.
The core concept is that wide columns are clipped when the table risks of being larger
than a certain max width. The columns convey though no information if they need to
be clipped to just a few characters why there is a minimum number of characters.
The columns that then don't fit are noted below the table as skipped columns.

You can also specify columns that you wish to skip by providing the columns2skip
skip argumnt. If columns are skipped by user demand there won't be a ... column to
the right but if the table is still too wide then the software may choose to skip
additional columns and thereby add a ... column.

```
({
   self            = Dataframe        -- 
  [digits          = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
  [columns2skip    = Df_Array]        -- Columns to skip from the output [default=false]
  [no_rows         = number|boolean]  -- The number of rows to display. If -1 then shows all. Defaults to setting in Dataframe.tostring_defaults [default=false]
  [min_col_width   = number|boolean]  -- The minimum column width in characters. Defaults to setting in Dataframe.tostring_defaults [default=false]
  [max_table_width = number|boolean]  -- The maximum table width in characters. Defaults to setting in Dataframe.tostring_defaults [default=false]
})
```

_Return value_: string

```
({
   self            = Dataframe        -- 
  [digits          = number|boolean]  -- Set this to an integer >= 0 in order to reduce the number of integers shown [default=false]
   columns2skip    = string           -- Columns to skip from the output as regular expression
  [no_rows         = number]          -- The number of rows to display. If -1 then shows all. Defaults to setting in Dataframe.tostring_defaults [default=false]
  [min_col_width   = number]          -- The minimum column width in characters. Defaults to setting in Dataframe.tostring_defaults [default=false]
  [max_table_width = number]          -- The maximum table width in characters. Defaults to setting in Dataframe.tostring_defaults [default=false]
})
```

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
