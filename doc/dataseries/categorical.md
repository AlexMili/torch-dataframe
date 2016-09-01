# API documentation for [categorical functions](#__Categorical functions__)
- [Dataseries.as_categorical](#Dataseries.as_categorical)
- [Dataseries.add_cat_key](#Dataseries.add_cat_key)
- [Dataseries.as_string](#Dataseries.as_string)
- [Dataseries.clean_categorical](#Dataseries.clean_categorical)
- [Dataseries.is_categorical](#Dataseries.is_categorical)
- [Dataseries.get_cat_keys](#Dataseries.get_cat_keys)
- [Dataseries.to_categorical](#Dataseries.to_categorical)
- [Dataseries.from_categorical](#Dataseries.from_categorical)
- [Dataseries.boolean2categorical](#Dataseries.boolean2categorical)

<a name="__Categorical functions__">
## Categorical functions

Here are functions are used for converting to and from categorical type. The
categorical series type is a hash table around a torch.IntTensor that maps
numerical values between integer and string values. The standard numbering is
from 1 to n unique values.

<a name="Dataseries.as_categorical">
### Dataseries.as_categorical(self[, levels][, labels][, exclude])

Set a series to categorical type. The keys retrieved from Dataseries.unique.

```
({
   self    = Dataseries         -- 
  [levels  = Df_Array|boolean]  -- An optional array of the values that series might have taken.
	 The default is the unique set of values taken by Dataseries.unique,
	 sorted into increasing order. If you provide values that aren't present
	 within the current series the value will still be saved and may be envoked in
	 the future.
  [labels  = Df_Array|boolean]  -- An optional character vector of labels for the levels
	 (in the same order as levels after removing those in exclude)
  [exclude = Df_Array|boolean]  -- Values to be excluded when forming the set of levels. This should be
	 of the same type as the series, and will be coerced if necessary.
})
```

_Return value_: self
<a name="Dataseries.add_cat_key">
### Dataseries.add_cat_key(self, key[, key_index])

Adds a key to the keyset of a categorical series. Mostly intended for internal use.

```
({
   self      = Dataseries     -- 
   key       = number|string  -- The new key to insert
  [key_index = number]        -- The key index to use
})
```

_Return value_: index value for key (integer)
	<a name="Dataseries.as_string">
### Dataseries.as_string(self)

Converts a categorical Dataseries to a string Dataseries. This can be used to revert
the Dataseries.as_categorical or as a way to convert numericals into strings.

```
({
   self = Dataseries  -- 
})
```

_Return value_: self
<a name="Dataseries.clean_categorical">
### Dataseries.clean_categorical(self[, reset_keys])

```
({
   self       = Dataseries  -- 
  [reset_keys = boolean]    -- if all the keys should be reinitialized [default=false]
})
```

Removes any categories no longer present from the keys

_Return value_: self
<a name="Dataseries.is_categorical">
### Dataseries.is_categorical(self)

Check if a Dataseries is categorical

```
({
   self = Dataseries  -- 
})
```

_Return value_: boolean
<a name="Dataseries.get_cat_keys">
### Dataseries.get_cat_keys(self)

Get keys

```
({
   self = Dataseries  -- 
})
```

_Return value_: table with `["key"] = number` structure
<a name="Dataseries.to_categorical">
### Dataseries.to_categorical(self, key_index)

Converts values to categorical according to a series's keys

```
({
   self      = Dataseries  -- 
   key_index = number      -- The integer to be converted
})
```

_Return value_: string with the value. If provided `nan` it will also
 return a `nan`. It returns `nil` if no key is found
You can also provide a tensor

```
({
   self = Dataseries     -- 
   data = torch.*Tensor  -- The integers to be converted
})
```

_Return value_: table with values
You can also provide an array

```
({
   self = Dataseries  -- 
   data = Df_Array    -- The integers to be converted
})
```

_Return value_: table with values
<a name="Dataseries.from_categorical">
### Dataseries.from_categorical(self, data)

Converts categorical to numerical according to a Dataseries's keys

```
({
   self = Dataseries     -- 
   data = number|string  -- The data to be converted
})
```

_Return value_: table or tensor
You can also provide an array with values

```
({
   self      = Dataseries  -- 
   data      = Df_Array    -- The data to be converted
  [as_tensor = boolean]    -- If the returned value should be a tensor [default=false]
})
```

_Return value_: table or tensor
Checks if categorical key exists

```
({
   self  = Dataseries     -- 
   value = number|string  -- The value that should be present in the categorical hash
})
```

_Return value_: boolean
Checks if categorical value exists

```
({
   self  = Dataseries     -- 
   value = number|string  -- The value that should be present in the categorical hash
})
```

_Return value_: boolean
<a name="Dataseries.boolean2categorical">
### Dataseries.boolean2categorical(self[, false_str][, true_str])

Converts a boolean Dataseries into a categorical tensor

```
({
   self      = Dataseries  -- 
  [false_str = string]     -- The string value for false [default=false]
  [true_str  = string]     -- The string value for true [default=true]
})
```

_Return value_: self, boolean indicating successful conversion