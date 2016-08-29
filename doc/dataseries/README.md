# Documentation for dataseries\n

This documentation ha been auto-generated from code using the `argcheck` system.

## Table of contents (file-level)

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.


- [Categorical functions](categorical.md)
- [Export functions](export.md)
- [Metatable functions](metatable.md)
- [Single element functions](sngl_elmnt_ops.md)
- [Statistics](statistics.md)

## Detailed table of contents (file-level + anchors)<a name=\"detailed\">


- **[Categorical functions](categorical.md)**
  - [Dataseries.as_categorical(self[, levels][, labels][, exclude])](categorical.md#Dataseries.as_categorical)
  - [Dataseries.add_cat_key(self, key[, key_index])](categorical.md#Dataseries.add_cat_key)
  - [Dataseries.as_string(self)](categorical.md#	Dataseries.as_string)
  - [Dataseries.clean_categorical(self[, reset_keys])](categorical.md#Dataseries.clean_categorical)
  - [Dataseries.is_categorical(self)](categorical.md#Dataseries.is_categorical)
  - [Dataseries.get_cat_keys(self)](categorical.md#Dataseries.get_cat_keys)
  - [Dataseries.to_categorical(self, key_index)](categorical.md#Dataseries.to_categorical)
  - [Dataseries.from_categorical(self, data)](categorical.md#Dataseries.from_categorical)
- **[Export functions](export.md)**
  - [Dataseries.to_tensor(self[, missing_value][, copy])](export.md#Dataseries.to_tensor)
  - [Dataseries.to_table(self)](export.md#Dataseries.to_table)
- **[Metatable functions](metatable.md)**
  - [Dataseries.#](metatable.md#Dataseries.#)
  - [Dataseries.__tostring__(self)](metatable.md#	Dataseries.__tostring__)
- **[Single element functions](sngl_elmnt_ops.md)**
  - [Dataseries.get(self, index[, as_raw])](sngl_elmnt_ops.md#Dataseries.get)
  - [Dataseries.set(self, index, value)](sngl_elmnt_ops.md#Dataseries.set)
  - [Dataseries.append(self, value)](sngl_elmnt_ops.md#Dataseries.append)
  - [Dataseries.remove(self, index)](sngl_elmnt_ops.md#Dataseries.remove)
  - [Dataseries.insert(self, index, value)](sngl_elmnt_ops.md#Dataseries.insert)
- **[Statistics](statistics.md)**
  - [Dataseries.count_na(self)](statistics.md#Dataseries.count_na)
  - [Dataseries.unique(self[, as_keys][, as_raw])](statistics.md#Dataseries.unique)
  - [Dataseries.value_counts(self[, normalize][, dropna][, as_raw][, as_dataframe])](statistics.md#Dataseries.value_counts)
  - [Dataseries.which_max(self)](statistics.md#Dataseries.which_max)
  - [Dataseries.which_min(self)](statistics.md#Dataseries.which_min)
  - [Dataseries.get_mode(self[, normalize][, dropna][, as_dataframe])](statistics.md#Dataseries.get_mode)
  - [Dataseries.get_max_value(self)](statistics.md#Dataseries.get_max_value)
  - [Dataseries.get_min_value(self)](statistics.md#Dataseries.get_min_value)