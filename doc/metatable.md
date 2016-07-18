
## Metatable functions

<a name="Dataframe.size">
### Dataframe.size(self)

Returns the number of rows in order to comply with the torchnet dataset standard

```
({
   self = Dataframe  -- 
})
```

_Return value_: rows
By providing dimension you can get only that dimension, row == 1, col == 2

```
({
   self = Dataframe  -- 
   dim  = number     -- The dimension of interest
})
```

_Return value_: integer
	<a name="Dataframe.__tostring__">
### Dataframe.__tostring__(self)

A wrapper for `tostring()`

```
({
   self = Dataframe  -- 
})
```

_Return value_: string
<a name="Dataframe.copy">
### Dataframe.copy(self)

Copies the table together with all metadata

```
({
   self = Dataframe  -- 
})
```

_Return value_: Dataframe
<a name="Dataframe.#">
### Dataframe.#

Returns the number of rows

_Return value_: integer
<a name="Dataframe.==">
### Dataframe.==

Checks if Dataframe's contain the same values

_Return value_: boolean
