# API documentation for [single element functions](#__Single element functions__)
- [Dataseries.get](#Dataseries.get)
- [Dataseries.set](#Dataseries.set)
- [Dataseries.append](#Dataseries.append)
- [Dataseries.remove](#Dataseries.remove)
- [Dataseries.insert](#Dataseries.insert)

<a name="__Single element functions__">
## Single element functions

Here are functions are mainly used for manipulating a single element.

<a name="Dataseries.get">
### Dataseries.get(self, index[, as_raw])

Gets a single or a set of elements.

```
({
   self   = Dataseries  -- 
   index  = number      -- The index to set the value to
  [as_raw = boolean]    -- Set to true if you want categorical values to be returned as their raw numeric representation [default=false]
})
```

_Return value_: number|string|boolean
If you provde a Df_Array you get back a Dataseries of elements

```
({
   self  = Dataseries  -- 
   index = Df_Array    -- 
})
```

_Return value_:  Dataseries
<a name="Dataseries.set">
### Dataseries.set(self, index, value)

Sets a single element

```
({
   self  = Dataseries  -- 
   index = number      -- The index to set the value to
   value = *           -- The data to set
})
```

_Return value_: self
<a name="Dataseries.append">
### Dataseries.append(self, value)

Appends a single element to series. This function resizes the tensor to +1
and then calls the `set` function so if possible try to directly size the
series to apropriate length before setting elements as this alternative is
slow and should only be used with a few values at the time.

```
({
   self  = Dataseries  -- 
   value = *           -- The data to set
})
```

_Return value_: self
<a name="Dataseries.remove">
### Dataseries.remove(self, index)

Removes a single element

```
({
   self  = Dataseries  -- 
   index = number      -- The index to remove
})
```

_Return value_: self
<a name="Dataseries.insert">
### Dataseries.insert(self, index, value)

Inserts a single element

```
({
   self  = Dataseries  -- 
   index = number      -- The index to insert at
   value = !table      -- The value to insert
})
```

_Return value_: self