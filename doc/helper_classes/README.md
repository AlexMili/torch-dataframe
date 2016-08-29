# Documentation for helper classes\n

This documentation ha been auto-generated from code using the `argcheck` system.

## Table of contents (file-level)

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.


- [Dataseries](01_dataseries.md)
- [Df_Iterator and general about Dataframe's iterators](10_iterator.md)
- [Df_ParallelIterator](11_paralleliterator.md)
- [Df_Tbl](20_tbl.md)
- [Df_Dict](21_dict.md)
- [Df_Array](22_array.md)

## Detailed table of contents (file-level + anchors)<a name=\"detailed\">


- **[Dataseries](01_dataseries.md)**
  - [Dataseries.__init(self, size[, type])](01_dataseries.md#Dataseries.__init)
  - [Dataseries.copy(self)](01_dataseries.md#Dataseries.copy)
  - [Dataseries.size(self)](01_dataseries.md#Dataseries.size)
  - [Dataseries.resize(self, new_size)](01_dataseries.md#Dataseries.resize)
  - [Dataseries.assert_is_index(self, index[, plus_one])](01_dataseries.md#Dataseries.assert_is_index)
  - [Dataseries.is_numerical(self)](01_dataseries.md#Dataseries.is_numerical)
  - [Dataseries.is_boolean(self)](01_dataseries.md#Dataseries.is_boolean)
  - [Dataseries.is_string(self)](01_dataseries.md#Dataseries.is_string)
  - [Dataseries.type(self)](01_dataseries.md#Dataseries.type)
  - [Dataseries.get_variable_type(self)](01_dataseries.md#Dataseries.get_variable_type)
  - [Dataseries.boolean2tensor(self, false_value, true_value)](01_dataseries.md#Dataseries.boolean2tensor)
  - [Dataseries.fill(self, default_value)](01_dataseries.md#Dataseries.fill)
  - [Dataseries.fill_na(self[, default_value])](01_dataseries.md#Dataseries.fill_na)
  - [Dataseries.tostring(self[, max_elmnts])](01_dataseries.md#Dataseries.tostring)
  - [Dataseries.sub(self[, start][, stop])](01_dataseries.md#Dataseries.sub)
  - [Dataseries.eq(self, other)](01_dataseries.md#Dataseries.eq)
  - [Dataseries.as_categorical(self[, levels][, labels][, exclude])](01_dataseries.md#Dataseries.as_categorical)
  - [Dataseries.add_cat_key(self, key[, key_index])](01_dataseries.md#Dataseries.add_cat_key)
  - [Dataseries.as_string(self)](01_dataseries.md#	Dataseries.as_string)
  - [Dataseries.clean_categorical(self[, reset_keys])](01_dataseries.md#Dataseries.clean_categorical)
  - [Dataseries.is_categorical(self)](01_dataseries.md#Dataseries.is_categorical)
  - [Dataseries.get_cat_keys(self)](01_dataseries.md#Dataseries.get_cat_keys)
  - [Dataseries.to_categorical(self, key_index)](01_dataseries.md#Dataseries.to_categorical)
  - [Dataseries.from_categorical(self, data)](01_dataseries.md#Dataseries.from_categorical)
  - [Dataseries.to_tensor(self[, missing_value][, copy])](01_dataseries.md#Dataseries.to_tensor)
  - [Dataseries.to_table(self)](01_dataseries.md#Dataseries.to_table)
  - [Dataseries.#](01_dataseries.md#Dataseries.#)
  - [Dataseries.__tostring__(self)](01_dataseries.md#	Dataseries.__tostring__)
  - [Dataseries.get(self, index[, as_raw])](01_dataseries.md#Dataseries.get)
  - [Dataseries.set(self, index, value)](01_dataseries.md#Dataseries.set)
  - [Dataseries.append(self, value)](01_dataseries.md#Dataseries.append)
  - [Dataseries.remove(self, index)](01_dataseries.md#Dataseries.remove)
  - [Dataseries.insert(self, index, value)](01_dataseries.md#Dataseries.insert)
  - [Dataseries.count_na(self)](01_dataseries.md#Dataseries.count_na)
  - [Dataseries.unique(self[, as_keys][, as_raw])](01_dataseries.md#Dataseries.unique)
  - [Dataseries.value_counts(self[, normalize][, dropna][, as_raw][, as_dataframe])](01_dataseries.md#Dataseries.value_counts)
  - [Dataseries.which_max(self)](01_dataseries.md#Dataseries.which_max)
  - [Dataseries.which_min(self)](01_dataseries.md#Dataseries.which_min)
  - [Dataseries.get_mode(self[, normalize][, dropna][, as_dataframe])](01_dataseries.md#Dataseries.get_mode)
  - [Dataseries.get_max_value(self)](01_dataseries.md#Dataseries.get_max_value)
  - [Dataseries.get_min_value(self)](01_dataseries.md#Dataseries.get_min_value)
- **[Df_Iterator and general about Dataframe's iterators](10_iterator.md)**
  - [Df_Iterator(self, dataset, batch_size[, filter][, transform][, input_transform][, target_transform])](10_iterator.md#Df_Iterator)
- **[Df_ParallelIterator](11_paralleliterator.md)**
  - [Df_ParallelIterator(self, dataset, batch_size[, init], nthread[, filter][, transform][, input_transform][, target_transform][, ordered])](11_paralleliterator.md#Df_ParallelIterator)
- **[Df_Tbl](20_tbl.md)**
- **[Df_Dict](21_dict.md)**
- **[Df_Array](22_array.md)**