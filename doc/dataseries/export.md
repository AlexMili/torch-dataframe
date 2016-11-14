# API documentation for [export functions](#__Export functions__)
- [Dataseries.to_tensor](#Dataseries.to_tensor)
- [Dataseries.to_table](#Dataseries.to_table)

<a name="__Export functions__">
## Export functions

Here are functions are used for exporting to a different format. Generally `to_`
functions should reside here. Only exception is the `tostring`.

<a name="Dataseries.to_tensor">
### Dataseries.to_tensor(self[, missing_value][, copy])

Returns the values in tensor format. Note that if you don't provide a replacement
for missing values and there are missing values the function will throw an error.

*Note*: boolean columns are not tensors and need to be manually converted to a
tensor. This since 0 would be a natural value for false but can cause issues as
neurons are labeled 1 to n for classification tasks. See the `Dataframe.update`
function for details or run the `boolean2tensor`.

```
({
   self          = Dataseries  -- 
  [missing_value = number]     -- Set a value for the missing data
  [copy          = boolean]    -- Set to false if you want the original data to be returned. [default=true]
})
```

_Return value_: `torch.*Tensor` of the current type
<a name="Dataseries.to_table">
### Dataseries.to_table(self[, boolean2string])

Returns the values in table format

```
({
   self           = Dataseries  -- 
  [boolean2string = boolean]    -- Convert boolean values to strings since they cause havoc with csvigo
})
```

_Return value_: table