# API documentation

- [Metatable functions](#__Metatable functions__)
- [Dataframe.size(self[, dim])](#Dataframe.size)
- [Dataframe.__tostring__(self)](#	Dataframe.__tostring__)
- [Dataframe.copy(self)](#Dataframe.copy)
- [Dataframe.#](#Dataframe.#)
- [Dataframe.==](#Dataframe.==)

<a name="__Metatable functions__">
## Metatable functions

<a name="Dataframe.size">
### Dataframe.size(self[, dim])

By providing dimension you can get only that dimension, row == 1, col == 2. If
value omitted it will  return the number of rows in order to comply with torchnet
standard.

```
({
   self = Dataframe  -- 
  [dim  = number]    -- The dimension of interest [default=1]
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