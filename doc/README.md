# Documentation for torch-dataframe

This documentation ha been auto-generated from code using the `argcheck` system.

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.

## Dataframe core components


- [Core functions](core/init.md)
- [Categorical functions](core/categorical.md)
- [Column functions](core/column.md)
- [Data save/export functions](core/export_data.md)
- [Data loader functions](core/load_data.md)
- [Metatable functions](core/metatable.md)
- [Missing data functions](core/missing_data.md)
- [Output functions](core/output.md)
- [Row functions](core/row.md)
- [Subsetting and manipulation functions](core/select_set_update.md)
- [Statistical functions](core/statistics.md)
- [Subsets and batches](core/subsets_and_batches.md)

## Dataseries - Dataframe's data storage


- [Dataseries](dataseries/init.md)
- [Categorical functions](dataseries/categorical.md)
- [Export functions](dataseries/export.md)
- [Metatable functions](dataseries/metatable.md)
- [Single element functions](dataseries/sngl_elmnt_ops.md)
- [Statistics](dataseries/statistics.md)

## Dataframe sub-classes


- [Df_Subset](sub_classes/01_subset.md)
- [Batchframe](sub_classes/10_batchframe.md)

## Helper classes


- [Df_Iterator and general about Dataframe's iterators](helper_classes/10_iterator.md)
- [Df_ParallelIterator](helper_classes/11_paralleliterator.md)
- [Df_Tbl](helper_classes/20_tbl.md)
- [Df_Dict](helper_classes/21_dict.md)
- [Df_Array](helper_classes/22_array.md)
## Utils


- [Utility functions](utils/utils.md)

# Detailed table of contents (file-level + anchors)<a name=\"detailed\">

## Dataframe core components


- **[Core functions](core/init.md)**
  - [Dataframe.`__init`](core/init.md#Dataframe.__init)
  - [Dataframe.get_schema](core/init.md#Dataframe.get_schema)
  - [Dataframe.shape](core/init.md#Dataframe.shape)
  - [Dataframe.version](core/init.md#Dataframe.version)
  - [Dataframe.set_version](core/init.md#Dataframe.set_version)
  - [Dataframe.upgrade_frame](core/init.md#Dataframe.upgrade_frame)
  - [Dataframe.assert_is_index](core/init.md#Dataframe.assert_is_index)
- **[Categorical functions](core/categorical.md)**
  - [Dataframe.as_categorical](core/categorical.md#Dataframe.as_categorical)
  - [Dataframe.add_cat_key](core/categorical.md#Dataframe.add_cat_key)
  - [Dataframe.as_string](core/categorical.md#Dataframe.as_string)
  - [Dataframe.clean_categorical](core/categorical.md#Dataframe.clean_categorical)
  - [Dataframe.is_categorical](core/categorical.md#Dataframe.is_categorical)
  - [Dataframe.get_cat_keys](core/categorical.md#Dataframe.get_cat_keys)
  - [Dataframe.to_categorical](core/categorical.md#Dataframe.to_categorical)
  - [Dataframe.from_categorical](core/categorical.md#Dataframe.from_categorical)
  - [Dataframe.boolean2categorical](core/categorical.md#Dataframe.boolean2categorical)
- **[Column functions](core/column.md)**
  - [Dataframe.is_numerical](core/column.md#Dataframe.is_numerical)
  - [Dataframe.is_string](core/column.md#Dataframe.is_string)
  - [Dataframe.is_boolean](core/column.md#Dataframe.is_boolean)
  - [Dataframe.has_column](core/column.md#Dataframe.has_column)
  - [Dataframe.assert_has_column](core/column.md#Dataframe.assert_has_column)
  - [Dataframe.assert_has_not_column](core/column.md#Dataframe.assert_has_not_column)
  - [Dataframe.drop](core/column.md#Dataframe.drop)
  - [Dataframe.add_column](core/column.md#Dataframe.add_column)
  - [Dataframe.get_column](core/column.md#Dataframe.get_column)
  - [Dataframe.reset_column](core/column.md#Dataframe.reset_column)
  - [Dataframe.rename_column](core/column.md#Dataframe.rename_column)
  - [Dataframe.get_numerical_colnames](core/column.md#Dataframe.get_numerical_colnames)
  - [Dataframe.get_column_order](core/column.md#Dataframe.get_column_order)
  - [Dataframe.swap_column_order](core/column.md#Dataframe.swap_column_order)
  - [Dataframe.pos_column_order](core/column.md#Dataframe.pos_column_order)
  - [Dataframe.boolean2tensor](core/column.md#Dataframe.boolean2tensor)
- **[Data save/export functions](core/export_data.md)**
  - [Dataframe.to_csv](core/export_data.md#Dataframe.to_csv)
  - [Dataframe.to_tensor](core/export_data.md#Dataframe.to_tensor)
  - [Dataframe.get](core/export_data.md#Dataframe.get)
- **[Data loader functions](core/load_data.md)**
  - [Dataframe.load_csv](core/load_data.md#Dataframe.load_csv)
  - [Dataframe.load_table](core/load_data.md#Dataframe.load_table)
  - [Dataframe.`_clean_columns`](core/load_data.md#Dataframe._clean_columns)
- **[Metatable functions](core/metatable.md)**
  - [Dataframe.size](core/metatable.md#Dataframe.size)
  - [Dataframe.`__tostring__`](core/metatable.md#Dataframe.__tostring__)
  - [Dataframe.copy](core/metatable.md#Dataframe.copy)
  - [Dataframe.#](core/metatable.md#Dataframe.#)
  - [Dataframe.==](core/metatable.md#Dataframe.==)
- **[Missing data functions](core/missing_data.md)**
  - [Dataframe.count_na](core/missing_data.md#Dataframe.count_na)
  - [Dataframe.fill_na](core/missing_data.md#Dataframe.fill_na)
  - [Dataframe.fill_na](core/missing_data.md#Dataframe.fill_na)
- **[Output functions](core/output.md)**
  - [Dataframe.output](core/output.md#Dataframe.output)
  - [Dataframe.show](core/output.md#Dataframe.show)
  - [Dataframe.tostring](core/output.md#Dataframe.tostring)
  - [Dataframe.`_to_html`](core/output.md#Dataframe._to_html)
- **[Row functions](core/row.md)**
  - [Dataframe.get_row](core/row.md#Dataframe.get_row)
  - [Dataframe.insert](core/row.md#Dataframe.insert)
  - [Dataframe.append](core/row.md#Dataframe.append)
  - [Dataframe.rbind](core/row.md#Dataframe.rbind)
  - [Dataframe.remove_index](core/row.md#Dataframe.remove_index)
- **[Subsetting and manipulation functions](core/select_set_update.md)**
  - [Dataframe.sub](core/select_set_update.md#Dataframe.sub)
  - [Dataframe.get_random](core/select_set_update.md#Dataframe.get_random)
  - [Dataframe.head](core/select_set_update.md#Dataframe.head)
  - [Dataframe.tail](core/select_set_update.md#Dataframe.tail)
  - [Dataframe.`_create_subset`](core/select_set_update.md#Dataframe._create_subset)
  - [Dataframe.where](core/select_set_update.md#Dataframe.where)
  - [Dataframe.which](core/select_set_update.md#Dataframe.which)
  - [Dataframe.update](core/select_set_update.md#Dataframe.update)
  - [Dataframe.set](core/select_set_update.md#Dataframe.set)
  - [Dataframe.wide2long](core/select_set_update.md#Dataframe.wide2long)
- **[Statistical functions](core/statistics.md)**
  - [Dataframe.unique](core/statistics.md#Dataframe.unique)
  - [Dataframe.value_counts](core/statistics.md#Dataframe.value_counts)
  - [Dataframe.which_max](core/statistics.md#Dataframe.which_max)
  - [Dataframe.which_min](core/statistics.md#Dataframe.which_min)
  - [Dataframe.get_mode](core/statistics.md#Dataframe.get_mode)
  - [Dataframe.get_max_value](core/statistics.md#Dataframe.get_max_value)
  - [Dataframe.get_min_value](core/statistics.md#Dataframe.get_min_value)
- **[Subsets and batches](core/subsets_and_batches.md)**
  - [Dataframe.create_subsets](core/subsets_and_batches.md#Dataframe.create_subsets)
  - [Dataframe.reset_subsets](core/subsets_and_batches.md#Dataframe.reset_subsets)
  - [Dataframe.has_subset](core/subsets_and_batches.md#Dataframe.has_subset)
  - [Dataframe.get_subset](core/subsets_and_batches.md#Dataframe.get_subset)

## Dataseries - Dataframe's data storage


- **[Dataseries](dataseries/init.md)**
  - [Dataseries.`__init`](dataseries/init.md#Dataseries.__init)
  - [Dataseries.copy](dataseries/init.md#Dataseries.copy)
  - [Dataseries.size](dataseries/init.md#Dataseries.size)
  - [Dataseries.resize](dataseries/init.md#Dataseries.resize)
  - [Dataseries.assert_is_index](dataseries/init.md#Dataseries.assert_is_index)
  - [Dataseries.is_numerical](dataseries/init.md#Dataseries.is_numerical)
  - [Dataseries.is_boolean](dataseries/init.md#Dataseries.is_boolean)
  - [Dataseries.is_string](dataseries/init.md#Dataseries.is_string)
  - [Dataseries.type](dataseries/init.md#Dataseries.type)
  - [Dataseries.get_variable_type](dataseries/init.md#Dataseries.get_variable_type)
  - [Dataseries.boolean2tensor](dataseries/init.md#Dataseries.boolean2tensor)
  - [Dataseries.fill](dataseries/init.md#Dataseries.fill)
  - [Dataseries.fill_na](dataseries/init.md#Dataseries.fill_na)
  - [Dataseries.tostring](dataseries/init.md#Dataseries.tostring)
  - [Dataseries.sub](dataseries/init.md#Dataseries.sub)
  - [Dataseries.eq](dataseries/init.md#Dataseries.eq)
- **[Categorical functions](dataseries/categorical.md)**
  - [Dataseries.as_categorical](dataseries/categorical.md#Dataseries.as_categorical)
  - [Dataseries.add_cat_key](dataseries/categorical.md#Dataseries.add_cat_key)
  - [Dataseries.as_string](dataseries/categorical.md#Dataseries.as_string)
  - [Dataseries.clean_categorical](dataseries/categorical.md#Dataseries.clean_categorical)
  - [Dataseries.is_categorical](dataseries/categorical.md#Dataseries.is_categorical)
  - [Dataseries.get_cat_keys](dataseries/categorical.md#Dataseries.get_cat_keys)
  - [Dataseries.to_categorical](dataseries/categorical.md#Dataseries.to_categorical)
  - [Dataseries.from_categorical](dataseries/categorical.md#Dataseries.from_categorical)
  - [Dataseries.boolean2categorical](dataseries/categorical.md#Dataseries.boolean2categorical)
- **[Export functions](dataseries/export.md)**
  - [Dataseries.to_tensor](dataseries/export.md#Dataseries.to_tensor)
  - [Dataseries.to_table](dataseries/export.md#Dataseries.to_table)
- **[Metatable functions](dataseries/metatable.md)**
  - [Dataseries.#](dataseries/metatable.md#Dataseries.#)
  - [Dataseries.`__tostring__`](dataseries/metatable.md#Dataseries.__tostring__)
- **[Single element functions](dataseries/sngl_elmnt_ops.md)**
  - [Dataseries.get](dataseries/sngl_elmnt_ops.md#Dataseries.get)
  - [Dataseries.set](dataseries/sngl_elmnt_ops.md#Dataseries.set)
  - [Dataseries.append](dataseries/sngl_elmnt_ops.md#Dataseries.append)
  - [Dataseries.remove](dataseries/sngl_elmnt_ops.md#Dataseries.remove)
  - [Dataseries.insert](dataseries/sngl_elmnt_ops.md#Dataseries.insert)
- **[Statistics](dataseries/statistics.md)**
  - [Dataseries.count_na](dataseries/statistics.md#Dataseries.count_na)
  - [Dataseries.unique](dataseries/statistics.md#Dataseries.unique)
  - [Dataseries.value_counts](dataseries/statistics.md#Dataseries.value_counts)
  - [Dataseries.which_max](dataseries/statistics.md#Dataseries.which_max)
  - [Dataseries.which_min](dataseries/statistics.md#Dataseries.which_min)
  - [Dataseries.get_mode](dataseries/statistics.md#Dataseries.get_mode)
  - [Dataseries.get_max_value](dataseries/statistics.md#Dataseries.get_max_value)
  - [Dataseries.get_min_value](dataseries/statistics.md#Dataseries.get_min_value)

## Dataframe sub-classes


- **[Df_Subset](sub_classes/01_subset.md)**
  - [Df_Subset.`__init`](sub_classes/01_subset.md#Df_Subset.__init)
  - [Df_Subset.`_clean`](sub_classes/01_subset.md#Df_Subset._clean)
  - [Df_Subset.set_idxs](sub_classes/01_subset.md#Df_Subset.set_idxs)
  - [Df_Subset.get_idx](sub_classes/01_subset.md#Df_Subset.get_idx)
  - [Df_Subset.set_labels](sub_classes/01_subset.md#Df_Subset.set_labels)
  - [Df_Subset.set_sampler](sub_classes/01_subset.md#Df_Subset.set_sampler)
  - [Df_Subset.get_sampler](sub_classes/01_subset.md#Df_Subset.get_sampler)
  - [Sampler: linear - Df_Subset.get_sampler_linear](sub_classes/01_subset.md#Df_Subset.get_sampler_linear)
  - [Sampler: ordered - Df_Subset.get_sampler_ordered](sub_classes/01_subset.md#Df_Subset.get_sampler_ordered)
  - [Sampler: uniform - Df_Subset.get_sampler_uniform](sub_classes/01_subset.md#Df_Subset.get_sampler_uniform)
  - [Sampler: permutation - Df_Subset.get_sampler_permutation](sub_classes/01_subset.md#Df_Subset.get_sampler_permutation)
  - [Sampler: label-uniform - Df_Subset.get_sampler_label_uniform](sub_classes/01_subset.md#Df_Subset.get_sampler_label_uniform)
  - [Sampler: label-distribution - Df_Subset.get_sampler_label_distribution](sub_classes/01_subset.md#Df_Subset.get_sampler_label_distribution)
  - [Sampler: label-permutation - Df_Subset.get_sampler_label_permutation](sub_classes/01_subset.md#Df_Subset.get_sampler_label_permutation)
  - [Df_Subset.get_batch](sub_classes/01_subset.md#Df_Subset.get_batch)
  - [Df_Subset.reset_sampler](sub_classes/01_subset.md#Df_Subset.reset_sampler)
  - [Df_Subset.get_iterator](sub_classes/01_subset.md#Df_Subset.get_iterator)
  - [Df_Subset.get_parallel_iterator](sub_classes/01_subset.md#Df_Subset.get_parallel_iterator)
  - [Df_Subset.size](sub_classes/01_subset.md#Df_Subset.size)
  - [Df_Subset.shape](sub_classes/01_subset.md#Df_Subset.shape)
  - [Df_Subset.`__tostring__`](sub_classes/01_subset.md#Df_Subset.__tostring__)
  - [Df_Subset.set_data_retriever](sub_classes/01_subset.md#Df_Subset.set_data_retriever)
  - [Df_Subset.set_label_retriever](sub_classes/01_subset.md#Df_Subset.set_label_retriever)
  - [Df_Subset.set_label_shape](sub_classes/01_subset.md#Df_Subset.set_label_shape)
- **[Batchframe](sub_classes/10_batchframe.md)**
  - [Batchframe.`__init`](sub_classes/10_batchframe.md#Batchframe.__init)
  - [Batchframe.set_data_retriever](sub_classes/10_batchframe.md#Batchframe.set_data_retriever)
  - [Batchframe.get_data_retriever](sub_classes/10_batchframe.md#Batchframe.get_data_retriever)
  - [Batchframe.set_label_retriever](sub_classes/10_batchframe.md#Batchframe.set_label_retriever)
  - [Batchframe.get_label_retriever](sub_classes/10_batchframe.md#Batchframe.get_label_retriever)
  - [Batchframe.set_label_shape](sub_classes/10_batchframe.md#Batchframe.set_label_shape)
  - [Batchframe.to_tensor](sub_classes/10_batchframe.md#Batchframe.to_tensor)

## Helper classes


- **[Df_Iterator and general about Dataframe's iterators](helper_classes/10_iterator.md)**
  - [Df_Iterator](helper_classes/10_iterator.md#Df_Iterator)
- **[Df_ParallelIterator](helper_classes/11_paralleliterator.md)**
  - [Df_ParallelIterator](helper_classes/11_paralleliterator.md#Df_ParallelIterator)
- **[Df_Tbl](helper_classes/20_tbl.md)**
- **[Df_Dict](helper_classes/21_dict.md)**
- **[Df_Array](helper_classes/22_array.md)**

## Utils


- **[Utility functions](utils/utils.md)**
  - [trim](utils/utils.md#trim)
  - [trim_table_strings](utils/utils.md#trim_table_strings)
  - [table.array2hash](utils/utils.md#table.array2hash)
  - [get_variable_type](utils/utils.md#get_variable_type)
  - [warning](utils/utils.md#warning)
  - [convert_table_2_dataframe](utils/utils.md#convert_table_2_dataframe)
