# API documentation for [Dataseries](#__Dataseries__)
- [Dataseries.`__init`](#Dataseries.__init)
- [Dataseries.copy](#Dataseries.copy)
- [Dataseries.size](#Dataseries.size)
- [Dataseries.resize](#Dataseries.resize)
- [Dataseries.assert_is_index](#Dataseries.assert_is_index)
- [Dataseries.is_numerical](#Dataseries.is_numerical)
- [Dataseries.is_boolean](#Dataseries.is_boolean)
- [Dataseries.is_string](#Dataseries.is_string)
- [Dataseries.type](#Dataseries.type)
- [Dataseries.get_variable_type](#Dataseries.get_variable_type)
- [Dataseries.boolean2tensor](#Dataseries.boolean2tensor)
- [Dataseries.fill](#Dataseries.fill)
- [Dataseries.fill_na](#Dataseries.fill_na)
- [Dataseries.tostring](#Dataseries.tostring)
- [Dataseries.sub](#Dataseries.sub)
- [Dataseries.eq](#Dataseries.eq)

<a name="__Dataseries__">
## Dataseries

The Dataseries is an array of data with an additional layer
of missing data info. The class contains two main elements:

* A data container
* A hash with the missing data positions

The missing data are presented as `nan` values. A `nan` has the
behavior that `nan ~= nan` evaluates to `true`. There is a helper
function in the package, `isnan()`, that can be used to identify
`nan` values.

The class has the following metatable functions available:

* `__index__`: You can access any element by `[]`
* `__newindex__`: You can set the value of an element via `[]`
* `__len__`: The `#` returns the length of the series


<a name="Dataseries.__init">
### Dataseries.__init(self, size[, type])

Creates and initializes a Dataseries class. Envoked through `local my_series = Dataseries()`.
The type can be:
- boolean
- integer
- double
- string
- torch tensor or tds.Vec

```
({
   self = Dataseries  -- 
   size = number      -- The size of the new series
  [type = string]     -- The type of data storage to init.
})
```


```
({
   self = Dataseries             -- 
   data = torch.*Tensor|tds.Vec  -- 
})
```

<a name="Dataseries.copy">
### Dataseries.copy(self[, type])

Creates a new Dataseries and with a copy/clone of the current data

```
({
   self = Dataseries  -- 
  [type = string]     -- Specify type if you  want other type than the current
})
```

_Return value_: Dataseries
<a name="Dataseries.size">
### Dataseries.size(self)

Returns the number of elements in the Dataseries

```
({
   self = Dataseries  -- 
})
```

_Return value_: number
<a name="Dataseries.resize">
### Dataseries.resize(self, new_size)

Resizes the underlying storage to the new size. If the size is shrunk
then it also clears any missing values in the hash. If the size is increased
the new values are automatically set to missing.

```
({
   self     = Dataseries  -- 
   new_size = number      -- The new size for the series
})
```

_Return value_: self
<a name="Dataseries.assert_is_index">
### Dataseries.assert_is_index(self, index[, plus_one])

Assertion that checks if index is an integer and within the span of the series

```
({
   self     = Dataseries  -- 
   index    = number      -- The index to check
  [plus_one = boolean]    -- When adding rows, an index of size(1) + 1 is OK [default=false]
})
```

_Return value_: self
<a name="Dataseries.is_numerical">
### Dataseries.is_numerical(self)

Checks if numerical

```
({
   self = Dataseries  -- 
})
```

_Return value_: boolean
<a name="Dataseries.is_boolean">
### Dataseries.is_boolean(self)

Checks if boolean

```
({
   self = Dataseries  -- 
})
```

_Return value_: boolean
<a name="Dataseries.is_string">
### Dataseries.is_string(self)

Checks if boolean

```
({
   self = Dataseries  -- 
})
```

_Return value_: boolean
<a name="Dataseries.type">
### Dataseries.type(self)

Gets the torch.typename of the storage

```
({
   self = Dataseries  -- 
})
```

_Return value_: string

You can also set the type by calling type with a type argument

```
({
   self = Dataseries  -- 
   type = string      -- The type of column that you want to convert to
})
```

_Return value_: self
<a name="Dataseries.get_variable_type">
### Dataseries.get_variable_type(self)

Gets the variable type that was used to initiate the Dataseries

```
({
   self = Dataseries  -- 
})
```

_Return value_: string
<a name="Dataseries.boolean2tensor">
### Dataseries.boolean2tensor(self, false_value, true_value)

Converts a boolean Dataseries into a torch.ByteTensor

```
({
   self        = Dataseries  -- 
   false_value = number      -- The numeric value for false
   true_value  = number      -- The numeric value for true
})
```

_Return value_: self, boolean indicating successful conversion
<a name="Dataseries.fill">
### Dataseries.fill(self, default_value)

Fills all values with a default value

```
({
   self          = Dataseries             -- 
   default_value = number|string|boolean  -- The default value
})
```

_Return value_: self
<a name="Dataseries.fill_na">
### Dataseries.fill_na(self[, default_value])

Replace missing values with a specific value

```
({
   self          = Dataseries              -- 
  [default_value = number|string|boolean]  -- The default missing value [default=0]
})
```

_Return value_: self
<a name="Dataseries.tostring">
### Dataseries.tostring(self[, max_elmnts])

Converts the series into a string output

```
({
   self       = Dataseries  -- 
  [max_elmnts = number]     --  [default=20]
})
```

_Return value_: string
<a name="Dataseries.sub">
### Dataseries.sub(self[, start][, stop])

Subsets the Dataseries to the element span

```
({
   self  = Dataseries  -- 
  [start = number]     --  [default=1]
  [stop  = number]     -- 
})
```

_Return value_: Dataseries
<a name="Dataseries.eq">
### Dataseries.eq(self, other)

Compares to Dataseries or table in order to see if they are identical

```
({
   self  = Dataseries        -- 
   other = Dataseries|table  -- 
})
```

_Return value_: string