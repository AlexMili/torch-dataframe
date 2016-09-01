# Documentation for core

This documentation ha been auto-generated from code using the `argcheck` system.

## Table of contents (file-level)

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.


- [Core functions](init.md)
- [Categorical functions](categorical.md)
- [Column functions](column.md)
- [Data save/export functions](export_data.md)
- [Data loader functions](load_data.md)
- [Metatable functions](metatable.md)
- [Missing data functions](missing_data.md)
- [Output functions](output.md)
- [Row functions](row.md)
- [Subsetting and manipulation functions](select_set_update.md)
- [Statistical functions](statistics.md)
- [Subsets and batches](subsets_and_batches.md)

## Detailed table of contents (file-level + anchors)<a name=\"detailed\">


- **[Core functions](init.md)**
  - [Dataframe.`__init`](init.md#Dataframe.__init)
  - [Dataframe.get_schema](init.md#Dataframe.get_schema)
  - [Dataframe.shape](init.md#Dataframe.shape)
  - [Dataframe.version](init.md#Dataframe.version)
  - [Dataframe.set_version](init.md#Dataframe.set_version)
  - [Dataframe.upgrade_frame](init.md#Dataframe.upgrade_frame)
  - [Dataframe.assert_is_index](init.md#Dataframe.assert_is_index)
- **[Categorical functions](categorical.md)**
  - [Dataframe.as_categorical](categorical.md#Dataframe.as_categorical)
  - [Dataframe.add_cat_key](categorical.md#Dataframe.add_cat_key)
  - [Dataframe.as_string](categorical.md#Dataframe.as_string)
  - [Dataframe.clean_categorical](categorical.md#Dataframe.clean_categorical)
  - [Dataframe.is_categorical](categorical.md#Dataframe.is_categorical)
  - [Dataframe.get_cat_keys](categorical.md#Dataframe.get_cat_keys)
  - [Dataframe.to_categorical](categorical.md#Dataframe.to_categorical)
  - [Dataframe.from_categorical](categorical.md#Dataframe.from_categorical)
  - [Dataframe.boolean2categorical](categorical.md#Dataframe.boolean2categorical)
- **[Column functions](column.md)**
  - [Dataframe.is_numerical](column.md#Dataframe.is_numerical)
  - [Dataframe.is_string](column.md#Dataframe.is_string)
  - [Dataframe.is_boolean](column.md#Dataframe.is_boolean)
  - [Dataframe.has_column](column.md#Dataframe.has_column)
  - [Dataframe.assert_has_column](column.md#Dataframe.assert_has_column)
  - [Dataframe.assert_has_not_column](column.md#Dataframe.assert_has_not_column)
  - [Dataframe.drop](column.md#Dataframe.drop)
  - [Dataframe.add_column](column.md#Dataframe.add_column)
  - [Dataframe.get_column](column.md#Dataframe.get_column)
  - [Dataframe.reset_column](column.md#Dataframe.reset_column)
  - [Dataframe.rename_column](column.md#Dataframe.rename_column)
  - [Dataframe.get_numerical_colnames](column.md#Dataframe.get_numerical_colnames)
  - [Dataframe.get_column_order](column.md#Dataframe.get_column_order)
  - [Dataframe.swap_column_order](column.md#Dataframe.swap_column_order)
  - [Dataframe.pos_column_order](column.md#Dataframe.pos_column_order)
  - [Dataframe.boolean2tensor](column.md#Dataframe.boolean2tensor)
- **[Data save/export functions](export_data.md)**
  - [Dataframe.to_csv](export_data.md#Dataframe.to_csv)
  - [Dataframe.to_tensor](export_data.md#Dataframe.to_tensor)
  - [Dataframe.get](export_data.md#Dataframe.get)
- **[Data loader functions](load_data.md)**
  - [Dataframe.load_csv](load_data.md#Dataframe.load_csv)
  - [Dataframe.load_table](load_data.md#Dataframe.load_table)
  - [Dataframe.`_clean_columns`](load_data.md#Dataframe._clean_columns)
- **[Metatable functions](metatable.md)**
  - [Dataframe.size](metatable.md#Dataframe.size)
  - [Dataframe.`__tostring__`](metatable.md#Dataframe.__tostring__)
  - [Dataframe.copy](metatable.md#Dataframe.copy)
  - [Dataframe.#](metatable.md#Dataframe.#)
  - [Dataframe.==](metatable.md#Dataframe.==)
- **[Missing data functions](missing_data.md)**
  - [Dataframe.count_na](missing_data.md#Dataframe.count_na)
  - [Dataframe.fill_na](missing_data.md#Dataframe.fill_na)
  - [Dataframe.fill_na](missing_data.md#Dataframe.fill_na)
- **[Output functions](output.md)**
  - [Dataframe.output](output.md#Dataframe.output)
  - [Dataframe.show](output.md#Dataframe.show)
  - [Dataframe.tostring](output.md#Dataframe.tostring)
  - [Dataframe.`_to_html`](output.md#Dataframe._to_html)
- **[Row functions](row.md)**
  - [Dataframe.get_row](row.md#Dataframe.get_row)
  - [Dataframe.insert](row.md#Dataframe.insert)
  - [Dataframe.append](row.md#Dataframe.append)
  - [Dataframe.rbind](row.md#Dataframe.rbind)
  - [Dataframe.remove_index](row.md#Dataframe.remove_index)
- **[Subsetting and manipulation functions](select_set_update.md)**
  - [Dataframe.sub](select_set_update.md#Dataframe.sub)
  - [Dataframe.get_random](select_set_update.md#Dataframe.get_random)
  - [Dataframe.head](select_set_update.md#Dataframe.head)
  - [Dataframe.tail](select_set_update.md#Dataframe.tail)
  - [Dataframe.`_create_subset`](select_set_update.md#Dataframe._create_subset)
  - [Dataframe.where](select_set_update.md#Dataframe.where)
  - [Dataframe.which](select_set_update.md#Dataframe.which)
  - [Dataframe.update](select_set_update.md#Dataframe.update)
  - [Dataframe.set](select_set_update.md#Dataframe.set)
  - [Dataframe.wide2long](select_set_update.md#Dataframe.wide2long)
- **[Statistical functions](statistics.md)**
  - [Dataframe.unique](statistics.md#Dataframe.unique)
  - [Dataframe.value_counts](statistics.md#Dataframe.value_counts)
  - [Dataframe.which_max](statistics.md#Dataframe.which_max)
  - [Dataframe.which_min](statistics.md#Dataframe.which_min)
  - [Dataframe.get_mode](statistics.md#Dataframe.get_mode)
  - [Dataframe.get_max_value](statistics.md#Dataframe.get_max_value)
  - [Dataframe.get_min_value](statistics.md#Dataframe.get_min_value)
- **[Subsets and batches](subsets_and_batches.md)**
  - [Dataframe.create_subsets](subsets_and_batches.md#Dataframe.create_subsets)
  - [Dataframe.reset_subsets](subsets_and_batches.md#Dataframe.reset_subsets)
  - [Dataframe.has_subset](subsets_and_batches.md#Dataframe.has_subset)
  - [Dataframe.get_subset](subsets_and_batches.md#Dataframe.get_subset)