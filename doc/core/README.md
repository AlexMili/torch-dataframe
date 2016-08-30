# Documentation for core\n

This documentation ha been auto-generated from code using the `argcheck` system.

## Table of contents (file-level)

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.


- [Core functions](main.md)
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


- **[Core functions](main.md)**
  - [Dataframe.__init(self)](main.md#Dataframe.__init)
  - [Dataframe.get_schema(self, column_name)](main.md#Dataframe.get_schema)
  - [Dataframe.shape(self)](main.md#Dataframe.shape)
  - [Dataframe.version(self)](main.md#Dataframe.version)
  - [Dataframe.set_version(self)](main.md#Dataframe.set_version)
  - [Dataframe.upgrade_frame(self)](main.md#Dataframe.upgrade_frame)
  - [Dataframe.assert_is_index(self, index[, plus_one])](main.md#Dataframe.assert_is_index)
- **[Categorical functions](categorical.md)**
  - [Dataframe.as_categorical(self, column_name[, levels][, labels][, exclude])](categorical.md#Dataframe.as_categorical)
  - [Dataframe.add_cat_key(self, column_name, key)](categorical.md#Dataframe.add_cat_key)
  - [Dataframe.as_string(self, column_name)](categorical.md#	Dataframe.as_string)
  - [Dataframe.clean_categorical(self, column_name[, reset_keys])](categorical.md#Dataframe.clean_categorical)
  - [Dataframe.is_categorical(self, column_name)](categorical.md#Dataframe.is_categorical)
  - [Dataframe.get_cat_keys(self, column_name)](categorical.md#Dataframe.get_cat_keys)
  - [Dataframe.to_categorical(self, data, column_name)](categorical.md#Dataframe.to_categorical)
  - [Dataframe.from_categorical(self, data, column_name[, as_tensor])](categorical.md#Dataframe.from_categorical)
- **[Column functions](column.md)**
  - [Dataframe.is_numerical(self, column_name)](column.md#Dataframe.is_numerical)
  - [Dataframe.is_string(self, column_name)](column.md#Dataframe.is_string)
  - [Dataframe.is_boolean(self, column_name)](column.md#Dataframe.is_boolean)
  - [Dataframe.has_column(self, column_name)](column.md#Dataframe.has_column)
  - [Dataframe.assert_has_column(self, column_name[, comment])](column.md#Dataframe.assert_has_column)
  - [Dataframe.assert_has_not_column(self, column_name[, comment])](column.md#Dataframe.assert_has_not_column)
  - [Dataframe.drop(self, column_name)](column.md#Dataframe.drop)
  - [Dataframe.add_column(self, column_name[, pos][, default_value][, type])](column.md#Dataframe.add_column)
  - [Dataframe.get_column(self, column_name[, as_raw][, as_tensor])](column.md#Dataframe.get_column)
  - [Dataframe.reset_column(self, columns[, new_value])](column.md#Dataframe.reset_column)
  - [Dataframe.rename_column(self, old_column_name, new_column_name)](column.md#Dataframe.rename_column)
  - [Dataframe.get_numerical_colnames(self)](column.md#Dataframe.get_numerical_colnames)
  - [Dataframe.get_column_order(self, column_name[, as_tensor])](column.md#Dataframe.get_column_order)
  - [Dataframe.swap_column_order(self, first, second)](column.md#Dataframe.swap_column_order)
  - [Dataframe.pos_column_order(self, column_name, position)](column.md#Dataframe.pos_column_order)
  - [Dataframe.boolean2tensor(self, column_name, false_value, true_value)](column.md#Dataframe.boolean2tensor)
- **[Data save/export functions](export_data.md)**
  - [Dataframe.to_csv(self, path[, separator][, verbose])](export_data.md#Dataframe.to_csv)
  - [Dataframe.to_tensor(self)](export_data.md#Dataframe.to_tensor)
  - [Dataframe.get(self, idx)](export_data.md#Dataframe.get)
- **[Data loader functions](load_data.md)**
  - [Dataframe.load_csv(self, path[, header][, schema][, separator][, skip][, verbose])](load_data.md#Dataframe.load_csv)
  - [Dataframe.load_table(self, data[, schema][, column_order])](load_data.md#	Dataframe.load_table)
  - [Dataframe._clean_columns(self, data[, column_order][, schema])](load_data.md#	Dataframe._clean_columns)
- **[Metatable functions](metatable.md)**
  - [Dataframe.size(self[, dim])](metatable.md#Dataframe.size)
  - [Dataframe.__tostring__(self)](metatable.md#	Dataframe.__tostring__)
  - [Dataframe.copy(self)](metatable.md#Dataframe.copy)
  - [Dataframe.#](metatable.md#Dataframe.#)
  - [Dataframe.==](metatable.md#Dataframe.==)
- **[Missing data functions](missing_data.md)**
  - [Dataframe.count_na(self[, columns][, as_dataframe])](missing_data.md#Dataframe.count_na)
  - [Dataframe.fill_na(self, column_name[, default_value])](missing_data.md#	Dataframe.fill_na)
  - [Dataframe.fill_na(self[, default_value])](missing_data.md#Dataframe.fill_na)
- **[Output functions](output.md)**
  - [Dataframe.output(self[, html][, max_rows][, digits])](output.md#Dataframe.output)
  - [Dataframe.show(self[, digits])](output.md#Dataframe.show)
  - [Dataframe.tostring(self[, digits][, columns2skip][, no_rows][, min_col_width][, max_table_width])](output.md#Dataframe.tostring)
  - [Dataframe._to_html(self[, split_table][, offset][, digits])](output.md#Dataframe._to_html)
- **[Row functions](row.md)**
  - [Dataframe.get_row(self, index)](row.md#Dataframe.get_row)
  - [Dataframe.insert(self, index, rows)](row.md#Dataframe.insert)
  - [Dataframe.append(self, rows[, column_order][, schema])](row.md#Dataframe.append)
  - [Dataframe.rbind(self, rows)](row.md#Dataframe.rbind)
  - [Dataframe.remove_index(self, index)](row.md#Dataframe.remove_index)
- **[Subsetting and manipulation functions](select_set_update.md)**
  - [Dataframe.sub(self[, start][, stop])](select_set_update.md#Dataframe.sub)
  - [Dataframe.get_random(self[, n_items])](select_set_update.md#Dataframe.get_random)
  - [Dataframe.head(self[, n_items])](select_set_update.md#Dataframe.head)
  - [Dataframe.tail(self[, n_items])](select_set_update.md#Dataframe.tail)
  - [Dataframe._create_subset(self, index_items[, frame_type][, class_args])](select_set_update.md#Dataframe._create_subset)
  - [Dataframe.where(self, column_name, item_to_find)](select_set_update.md#Dataframe.where)
  - [Dataframe.which(self, condition_function)](select_set_update.md#Dataframe.which)
  - [Dataframe.update(self, condition_function, update_function)](select_set_update.md#Dataframe.update)
  - [Dataframe.set(self, item_to_find, column_name, new_value)](select_set_update.md#Dataframe.set)
  - [Dataframe.wide2long(self, columns, id_name, value_name)](select_set_update.md#Dataframe.wide2long)
- **[Statistical functions](statistics.md)**
  - [Dataframe.unique(self, column_name[, as_keys][, as_raw])](statistics.md#Dataframe.unique)
  - [Dataframe.value_counts(self, column_name[, normalize][, dropna][, as_dataframe])](statistics.md#Dataframe.value_counts)
  - [Dataframe.which_max(self, column_name)](statistics.md#Dataframe.which_max)
  - [Dataframe.which_min(self, column_name)](statistics.md#Dataframe.which_min)
  - [Dataframe.get_mode(self, column_name[, normalize][, dropna][, as_dataframe])](statistics.md#Dataframe.get_mode)
  - [Dataframe.get_max_value(self, column_name)](statistics.md#Dataframe.get_max_value)
  - [Dataframe.get_min_value(self, column_name)](statistics.md#Dataframe.get_min_value)
- **[Subsets and batches](subsets_and_batches.md)**
  - [Dataframe.create_subsets(self[, subsets][, data_retriever][, label_retriever][, class_args])](subsets_and_batches.md#Dataframe.create_subsets)
  - [Dataframe.reset_subsets(self)](subsets_and_batches.md#Dataframe.reset_subsets)
  - [Dataframe.has_subset(self, subset)](subsets_and_batches.md#Dataframe.has_subset)
  - [Dataframe.get_subset(self, subset[, frame_type][, class_args])](subsets_and_batches.md#Dataframe.get_subset)