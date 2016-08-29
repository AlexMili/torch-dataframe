# Documentation for helper_classes\n

This documentation ha been auto-generated from code using the `argcheck` system.

## Table of contents (file-level)

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.


- [Dataseries](doc/helper_classes/01_dataseries.md)
- [Df_Iterator and general about Dataframe's iterators](doc/helper_classes/10_iterator.md)
- [Df_ParallelIterator](doc/helper_classes/11_paralleliterator.md)
- [Df_Tbl](doc/helper_classes/20_tbl.md)
- [Df_Dict](doc/helper_classes/21_dict.md)
- [Df_Array](doc/helper_classes/22_array.md)

## Detailed table of contents (file-level + anchors)<a name=\"detailed\">


- [Dataseries](doc/helper_classes/01_dataseries.md)
  - [Dataseries.__init(self, size[, type])](doc/helper_classes/01_dataseries.md#Dataseries.__init)
  - [Dataseries.copy(self)](doc/helper_classes/01_dataseries.md#Dataseries.copy)
  - [Dataseries.size(self)](doc/helper_classes/01_dataseries.md#Dataseries.size)
  - [Dataseries.resize(self, new_size)](doc/helper_classes/01_dataseries.md#Dataseries.resize)
  - [Dataseries.assert_is_index(self, index[, plus_one])](doc/helper_classes/01_dataseries.md#Dataseries.assert_is_index)
  - [Dataseries.is_numerical(self)](doc/helper_classes/01_dataseries.md#Dataseries.is_numerical)
  - [Dataseries.is_boolean(self)](doc/helper_classes/01_dataseries.md#Dataseries.is_boolean)
  - [Dataseries.is_string(self)](doc/helper_classes/01_dataseries.md#Dataseries.is_string)
  - [Dataseries.type(self)](doc/helper_classes/01_dataseries.md#Dataseries.type)
  - [Dataseries.get_variable_type(self)](doc/helper_classes/01_dataseries.md#Dataseries.get_variable_type)
  - [Dataseries.boolean2tensor(self, false_value, true_value)](doc/helper_classes/01_dataseries.md#Dataseries.boolean2tensor)
  - [Dataseries.fill(self, default_value)](doc/helper_classes/01_dataseries.md#Dataseries.fill)
  - [Dataseries.fill_na(self[, default_value])](doc/helper_classes/01_dataseries.md#Dataseries.fill_na)
  - [Dataseries.tostring(self[, max_elmnts])](doc/helper_classes/01_dataseries.md#Dataseries.tostring)
  - [Dataseries.sub(self[, start][, stop])](doc/helper_classes/01_dataseries.md#Dataseries.sub)
  - [Dataseries.eq(self, other)](doc/helper_classes/01_dataseries.md#Dataseries.eq)
  - [Dataseries.as_categorical(self[, levels][, labels][, exclude])](doc/helper_classes/01_dataseries.md#Dataseries.as_categorical)
  - [Dataseries.add_cat_key(self, key[, key_index])](doc/helper_classes/01_dataseries.md#Dataseries.add_cat_key)
  - [Dataseries.as_string(self)](doc/helper_classes/01_dataseries.md#	Dataseries.as_string)
  - [Dataseries.clean_categorical(self[, reset_keys])](doc/helper_classes/01_dataseries.md#Dataseries.clean_categorical)
  - [Dataseries.is_categorical(self)](doc/helper_classes/01_dataseries.md#Dataseries.is_categorical)
  - [Dataseries.get_cat_keys(self)](doc/helper_classes/01_dataseries.md#Dataseries.get_cat_keys)
  - [Dataseries.to_categorical(self, key_index)](doc/helper_classes/01_dataseries.md#Dataseries.to_categorical)
  - [Dataseries.from_categorical(self, data)](doc/helper_classes/01_dataseries.md#Dataseries.from_categorical)
  - [Dataseries.to_tensor(self[, missing_value][, copy])](doc/helper_classes/01_dataseries.md#Dataseries.to_tensor)
  - [Dataseries.to_table(self)](doc/helper_classes/01_dataseries.md#Dataseries.to_table)
  - [Dataseries.#](doc/helper_classes/01_dataseries.md#Dataseries.#)
  - [Dataseries.__tostring__(self)](doc/helper_classes/01_dataseries.md#	Dataseries.__tostring__)
  - [Dataseries.get(self, index[, as_raw])](doc/helper_classes/01_dataseries.md#Dataseries.get)
  - [Dataseries.set(self, index, value)](doc/helper_classes/01_dataseries.md#Dataseries.set)
  - [Dataseries.append(self, value)](doc/helper_classes/01_dataseries.md#Dataseries.append)
  - [Dataseries.remove(self, index)](doc/helper_classes/01_dataseries.md#Dataseries.remove)
  - [Dataseries.insert(self, index, value)](doc/helper_classes/01_dataseries.md#Dataseries.insert)
  - [Dataseries.count_na(self)](doc/helper_classes/01_dataseries.md#Dataseries.count_na)
  - [Dataseries.unique(self[, as_keys][, as_raw])](doc/helper_classes/01_dataseries.md#Dataseries.unique)
  - [Dataseries.value_counts(self[, normalize][, dropna][, as_raw][, as_dataframe])](doc/helper_classes/01_dataseries.md#Dataseries.value_counts)
  - [Dataseries.which_max(self)](doc/helper_classes/01_dataseries.md#Dataseries.which_max)
  - [Dataseries.which_min(self)](doc/helper_classes/01_dataseries.md#Dataseries.which_min)
  - [Dataseries.get_mode(self[, normalize][, dropna][, as_dataframe])](doc/helper_classes/01_dataseries.md#Dataseries.get_mode)
  - [Dataseries.get_max_value(self)](doc/helper_classes/01_dataseries.md#Dataseries.get_max_value)
  - [Dataseries.get_min_value(self)](doc/helper_classes/01_dataseries.md#Dataseries.get_min_value)
- [Df_Iterator and general about Dataframe's iterators](doc/helper_classes/10_iterator.md)
  - [Df_Iterator(self, dataset, batch_size[, filter][, transform][, input_transform][, target_transform])](doc/helper_classes/10_iterator.md#Df_Iterator)
- [Df_ParallelIterator](doc/helper_classes/11_paralleliterator.md)
  - [Df_ParallelIterator(self, dataset, batch_size[, init], nthread[, filter][, transform][, input_transform][, target_transform][, ordered])](doc/helper_classes/11_paralleliterator.md#Df_ParallelIterator)
- [Df_Tbl](doc/helper_classes/20_tbl.md)
- [Df_Dict](doc/helper_classes/21_dict.md)
- [Df_Array](doc/helper_classes/22_array.md)