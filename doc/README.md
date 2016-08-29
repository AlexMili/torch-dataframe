# Documentation
# Documentation for torch-dataframe

This documentation ha been auto-generated from code using the `argcheck` system.

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.

## Dataframe core components


- [Core functions](core/main.md)
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


- [Categorical functions](dataseries/categorical.md)
- [Export functions](dataseries/export.md)
- [Metatable functions](dataseries/metatable.md)
- [Single element functions](dataseries/sngl_elmnt_ops.md)
- [Statistics](dataseries/statistics.md)

## Dataframe sub-classes


- [Df_Subset](sub_classes/01_subset.md)
- [Batchframe](sub_classes/10_batchframe.md)

## Helper classes


- [torchnet](helper_classes/10_iterator.md)
- [Df_ParallelIterator](helper_classes/11_paralleliterator.md)
- [Df_Tbl](helper_classes/20_tbl.md)
- [Df_Dict](helper_classes/21_dict.md)
- [Df_Array](helper_classes/22_array.md)
## Utils


- [Utility functions](utils/utils.md)

# Detailed table of contents (file-level + anchors)<a name=\"detailed\">

## Dataframe core components


- **[Core functions](core/main.md)**
  - [Dataframe.__init(self)](core/main.md#Dataframe.__init)
  - [Dataframe.shape(self)](core/main.md#Dataframe.shape)
  - [Dataframe.version(self)](core/main.md#Dataframe.version)
  - [Dataframe.set_version(self)](core/main.md#Dataframe.set_version)
  - [Dataframe.upgrade_frame(self)](core/main.md#Dataframe.upgrade_frame)
  - [Dataframe.assert_is_index(self, index[, plus_one])](core/main.md#Dataframe.assert_is_index)
- **[Categorical functions](core/categorical.md)**
  - [Dataframe.as_categorical(self, column_name[, levels][, labels][, exclude])](core/categorical.md#Dataframe.as_categorical)
  - [Dataframe.add_cat_key(self, column_name, key)](core/categorical.md#Dataframe.add_cat_key)
  - [Dataframe.as_string(self, column_name)](core/categorical.md#	Dataframe.as_string)
  - [Dataframe.clean_categorical(self, column_name[, reset_keys])](core/categorical.md#Dataframe.clean_categorical)
  - [Dataframe.is_categorical(self, column_name)](core/categorical.md#Dataframe.is_categorical)
  - [Dataframe.get_cat_keys(self, column_name)](core/categorical.md#Dataframe.get_cat_keys)
  - [Dataframe.to_categorical(self, data, column_name)](core/categorical.md#Dataframe.to_categorical)
  - [Dataframe.from_categorical(self, data, column_name[, as_tensor])](core/categorical.md#Dataframe.from_categorical)
- **[Column functions](core/column.md)**
  - [Dataframe.is_numerical(self, column_name)](core/column.md#Dataframe.is_numerical)
  - [Dataframe.is_string(self, column_name)](core/column.md#Dataframe.is_string)
  - [Dataframe.is_boolean(self, column_name)](core/column.md#Dataframe.is_boolean)
  - [Dataframe.has_column(self, column_name)](core/column.md#Dataframe.has_column)
  - [Dataframe.assert_has_column(self, column_name[, comment])](core/column.md#Dataframe.assert_has_column)
  - [Dataframe.assert_has_not_column(self, column_name[, comment])](core/column.md#Dataframe.assert_has_not_column)
  - [Dataframe.drop(self, column_name)](core/column.md#Dataframe.drop)
  - [Dataframe.add_column(self, column_name[, pos][, default_value][, type])](core/column.md#Dataframe.add_column)
  - [Dataframe.get_column(self, column_name[, as_raw][, as_tensor])](core/column.md#Dataframe.get_column)
  - [Dataframe.reset_column(self, columns[, new_value])](core/column.md#Dataframe.reset_column)
  - [Dataframe.rename_column(self, old_column_name, new_column_name)](core/column.md#Dataframe.rename_column)
  - [Dataframe.get_numerical_colnames(self)](core/column.md#Dataframe.get_numerical_colnames)
  - [Dataframe.get_column_order(self, column_name[, as_tensor])](core/column.md#Dataframe.get_column_order)
  - [Dataframe.swap_column_order(self, first, second)](core/column.md#Dataframe.swap_column_order)
  - [Dataframe.pos_column_order(self, column_name, position)](core/column.md#Dataframe.pos_column_order)
  - [Dataframe.boolean2tensor(self, column_name, false_value, true_value)](core/column.md#Dataframe.boolean2tensor)
- **[Data save/export functions](core/export_data.md)**
  - [Dataframe.to_csv(self, path[, separator][, verbose])](core/export_data.md#Dataframe.to_csv)
  - [Dataframe.to_tensor(self)](core/export_data.md#Dataframe.to_tensor)
  - [Dataframe.get(self, idx)](core/export_data.md#Dataframe.get)
- **[Data loader functions](core/load_data.md)**
  - [Dataframe.load_csv(self, path[, header][, schema][, separator][, skip][, verbose])](core/load_data.md#Dataframe.load_csv)
  - [Dataframe.load_table(self, data[, schema][, column_order])](core/load_data.md#	Dataframe.load_table)
  - [Dataframe._clean_columns(self, data[, column_order][, schema])](core/load_data.md#	Dataframe._clean_columns)
- **[Metatable functions](core/metatable.md)**
  - [Dataframe.size(self[, dim])](core/metatable.md#Dataframe.size)
  - [Dataframe.__tostring__(self)](core/metatable.md#	Dataframe.__tostring__)
  - [Dataframe.copy(self)](core/metatable.md#Dataframe.copy)
  - [Dataframe.#](core/metatable.md#Dataframe.#)
  - [Dataframe.==](core/metatable.md#Dataframe.==)
- **[Missing data functions](core/missing_data.md)**
  - [Dataframe.count_na(self[, columns][, as_dataframe])](core/missing_data.md#Dataframe.count_na)
  - [Dataframe.fill_na(self, column_name[, default_value])](core/missing_data.md#	Dataframe.fill_na)
  - [Dataframe.fill_na(self[, default_value])](core/missing_data.md#Dataframe.fill_na)
- **[Output functions](core/output.md)**
  - [Dataframe.output(self[, html][, max_rows][, digits])](core/output.md#Dataframe.output)
  - [Dataframe.show(self[, digits])](core/output.md#Dataframe.show)
  - [Dataframe.tostring(self[, digits][, columns2skip][, no_rows][, min_col_width][, max_table_width])](core/output.md#Dataframe.tostring)
  - [Dataframe._to_html(self[, split_table][, offset][, digits])](core/output.md#Dataframe._to_html)
- **[Row functions](core/row.md)**
  - [Dataframe.get_row(self, index)](core/row.md#Dataframe.get_row)
  - [Dataframe.insert(self, index, rows)](core/row.md#Dataframe.insert)
  - [Dataframe.append(self, rows[, column_order][, schema])](core/row.md#Dataframe.append)
  - [Dataframe.rbind(self, rows)](core/row.md#Dataframe.rbind)
  - [Dataframe.remove_index(self, index)](core/row.md#Dataframe.remove_index)
- **[Subsetting and manipulation functions](core/select_set_update.md)**
  - [Dataframe.sub(self[, start][, stop])](core/select_set_update.md#Dataframe.sub)
  - [Dataframe.get_random(self[, n_items])](core/select_set_update.md#Dataframe.get_random)
  - [Dataframe.head(self[, n_items])](core/select_set_update.md#Dataframe.head)
  - [Dataframe.tail(self[, n_items])](core/select_set_update.md#Dataframe.tail)
  - [Dataframe._create_subset(self, index_items[, frame_type][, class_args])](core/select_set_update.md#Dataframe._create_subset)
  - [Dataframe.where(self, column_name, item_to_find)](core/select_set_update.md#Dataframe.where)
  - [Dataframe.which(self, condition_function)](core/select_set_update.md#Dataframe.which)
  - [Dataframe.update(self, condition_function, update_function)](core/select_set_update.md#Dataframe.update)
  - [Dataframe.set(self, item_to_find, column_name, new_value)](core/select_set_update.md#Dataframe.set)
  - [Dataframe.wide2long(self, columns, id_name, value_name)](core/select_set_update.md#Dataframe.wide2long)
- **[Statistical functions](core/statistics.md)**
  - [Dataframe.unique(self, column_name[, as_keys][, as_raw])](core/statistics.md#Dataframe.unique)
  - [Dataframe.value_counts(self, column_name[, normalize][, dropna][, as_dataframe])](core/statistics.md#Dataframe.value_counts)
  - [Dataframe.which_max(self, column_name)](core/statistics.md#Dataframe.which_max)
  - [Dataframe.which_min(self, column_name)](core/statistics.md#Dataframe.which_min)
  - [Dataframe.get_mode(self, column_name[, normalize][, dropna][, as_dataframe])](core/statistics.md#Dataframe.get_mode)
  - [Dataframe.get_max_value(self, column_name)](core/statistics.md#Dataframe.get_max_value)
  - [Dataframe.get_min_value(self, column_name)](core/statistics.md#Dataframe.get_min_value)
- **[Subsets and batches](core/subsets_and_batches.md)**
  - [Dataframe.create_subsets(self[, subsets][, data_retriever][, label_retriever][, class_args])](core/subsets_and_batches.md#Dataframe.create_subsets)
  - [Dataframe.reset_subsets(self)](core/subsets_and_batches.md#Dataframe.reset_subsets)
  - [Dataframe.has_subset(self, subset)](core/subsets_and_batches.md#Dataframe.has_subset)
  - [Dataframe.get_subset(self, subset[, frame_type][, class_args])](core/subsets_and_batches.md#Dataframe.get_subset)

## Dataseries - Dataframe's data storage


- **[Categorical functions](dataseries/categorical.md)**
  - [Dataseries.as_categorical(self[, levels][, labels][, exclude])](dataseries/categorical.md#Dataseries.as_categorical)
  - [Dataseries.add_cat_key(self, key[, key_index])](dataseries/categorical.md#Dataseries.add_cat_key)
  - [Dataseries.as_string(self)](dataseries/categorical.md#	Dataseries.as_string)
  - [Dataseries.clean_categorical(self[, reset_keys])](dataseries/categorical.md#Dataseries.clean_categorical)
  - [Dataseries.is_categorical(self)](dataseries/categorical.md#Dataseries.is_categorical)
  - [Dataseries.get_cat_keys(self)](dataseries/categorical.md#Dataseries.get_cat_keys)
  - [Dataseries.to_categorical(self, key_index)](dataseries/categorical.md#Dataseries.to_categorical)
  - [Dataseries.from_categorical(self, data)](dataseries/categorical.md#Dataseries.from_categorical)
- **[Export functions](dataseries/export.md)**
  - [Dataseries.to_tensor(self[, missing_value][, copy])](dataseries/export.md#Dataseries.to_tensor)
  - [Dataseries.to_table(self)](dataseries/export.md#Dataseries.to_table)
- **[Metatable functions](dataseries/metatable.md)**
  - [Dataseries.#](dataseries/metatable.md#Dataseries.#)
  - [Dataseries.__tostring__(self)](dataseries/metatable.md#	Dataseries.__tostring__)
- **[Single element functions](dataseries/sngl_elmnt_ops.md)**
  - [Dataseries.get(self, index[, as_raw])](dataseries/sngl_elmnt_ops.md#Dataseries.get)
  - [Dataseries.set(self, index, value)](dataseries/sngl_elmnt_ops.md#Dataseries.set)
  - [Dataseries.append(self, value)](dataseries/sngl_elmnt_ops.md#Dataseries.append)
  - [Dataseries.remove(self, index)](dataseries/sngl_elmnt_ops.md#Dataseries.remove)
  - [Dataseries.insert(self, index, value)](dataseries/sngl_elmnt_ops.md#Dataseries.insert)
- **[Statistics](dataseries/statistics.md)**
  - [Dataseries.count_na(self)](dataseries/statistics.md#Dataseries.count_na)
  - [Dataseries.unique(self[, as_keys][, as_raw])](dataseries/statistics.md#Dataseries.unique)
  - [Dataseries.value_counts(self[, normalize][, dropna][, as_raw][, as_dataframe])](dataseries/statistics.md#Dataseries.value_counts)
  - [Dataseries.which_max(self)](dataseries/statistics.md#Dataseries.which_max)
  - [Dataseries.which_min(self)](dataseries/statistics.md#Dataseries.which_min)
  - [Dataseries.get_mode(self[, normalize][, dropna][, as_dataframe])](dataseries/statistics.md#Dataseries.get_mode)
  - [Dataseries.get_max_value(self)](dataseries/statistics.md#Dataseries.get_max_value)
  - [Dataseries.get_min_value(self)](dataseries/statistics.md#Dataseries.get_min_value)

## Dataframe sub-classes


- **[Df_Subset](sub_classes/01_subset.md)**
  - [Df_Subset.__init(self, parent, indexes[, sampler][, label_column][, sampler_args][, batch_args])](sub_classes/01_subset.md#Df_Subset.__init)
  - [Df_Subset._clean(self)](sub_classes/01_subset.md#Df_Subset._clean)
  - [Df_Subset.set_idxs(self, indexes)](sub_classes/01_subset.md#Df_Subset.set_idxs)
  - [Df_Subset.get_idx(self, index)](sub_classes/01_subset.md#Df_Subset.get_idx)
  - [Df_Subset.set_labels(self, label_column)](sub_classes/01_subset.md#Df_Subset.set_labels)
  - [Df_Subset.set_sampler(self, sampler[, sampler_args])](sub_classes/01_subset.md#Df_Subset.set_sampler)
  - [Df_Subset.get_sampler(self, sampler[, args])](sub_classes/01_subset.md#Df_Subset.get_sampler)
  - [Sampler: linear - Df_Subset.get_sampler_linear(self)](sub_classes/01_subset.md#Df_Subset.get_sampler_linear)
  - [Sampler: ordered - Df_Subset.get_sampler_ordered(self)](sub_classes/01_subset.md#Df_Subset.get_sampler_ordered)
  - [Sampler: uniform - Df_Subset.get_sampler_uniform(self)](sub_classes/01_subset.md#Df_Subset.get_sampler_uniform)
  - [Sampler: permutation - Df_Subset.get_sampler_permutation(self)](sub_classes/01_subset.md#Df_Subset.get_sampler_permutation)
  - [Sampler: label-uniform - Df_Subset.get_sampler_label_uniform(self)](sub_classes/01_subset.md#Df_Subset.get_sampler_label_uniform)
  - [Sampler: label-distribution - Df_Subset.get_sampler_label_distribution(self, distribution)](sub_classes/01_subset.md#Df_Subset.get_sampler_label_distribution)
  - [Sampler: label-permutation - Df_Subset.get_sampler_label_permutation(self)](sub_classes/01_subset.md#Df_Subset.get_sampler_label_permutation)
  - [Df_Subset.get_batch(self, no_lines[, class_args])](sub_classes/01_subset.md#Df_Subset.get_batch)
  - [Df_Subset.reset_sampler(self)](sub_classes/01_subset.md#Df_Subset.reset_sampler)
  - [Df_Subset.get_iterator(self, batch_size[, filter][, transform][, input_transform][, target_transform])](sub_classes/01_subset.md#Df_Subset.get_iterator)
  - [Df_Subset.get_parallel_iterator(self, batch_size[, init], nthread[, filter][, transform][, input_transform][, target_transform][, ordered])](sub_classes/01_subset.md#	Df_Subset.get_parallel_iterator)
  - [Df_Subset.size(self[, dim])](sub_classes/01_subset.md#	Df_Subset.size)
  - [Df_Subset.shape(self)](sub_classes/01_subset.md#Df_Subset.shape)
  - [Df_Subset.__tostring__(self)](sub_classes/01_subset.md#	Df_Subset.__tostring__)
  - [Df_Subset.set_data_retriever(self[, data])](sub_classes/01_subset.md#Df_Subset.set_data_retriever)
  - [Df_Subset.set_label_retriever(self[, label])](sub_classes/01_subset.md#Df_Subset.set_label_retriever)
  - [Df_Subset.set_label_shape(self[, label_shape])](sub_classes/01_subset.md#Df_Subset.set_label_shape)
- **[Batchframe](sub_classes/10_batchframe.md)**
  - [Batchframe.__init(self[, data][, label][, label_shape])](sub_classes/10_batchframe.md#Batchframe.__init)
  - [Batchframe.set_data_retriever(self[, data])](sub_classes/10_batchframe.md#Batchframe.set_data_retriever)
  - [Batchframe.get_data_retriever(self)](sub_classes/10_batchframe.md#Batchframe.get_data_retriever)
  - [Batchframe.set_label_retriever(self[, label])](sub_classes/10_batchframe.md#Batchframe.set_label_retriever)
  - [Batchframe.get_label_retriever(self)](sub_classes/10_batchframe.md#Batchframe.get_label_retriever)
  - [Batchframe.set_label_shape(self[, label_shape])](sub_classes/10_batchframe.md#Batchframe.set_label_shape)
  - [Batchframe.to_tensor(self, data_columns, label_columns[, label_shape])](sub_classes/10_batchframe.md#Batchframe.to_tensor)

## Helper classes


- **[torchnet](helper_classes/10_iterator.md)**
  - [tnt.utils.table.clone(table)](helper_classes/10_iterator.md#utils.table.clone)
  - [tnt.utils.table.merge(dst, src)](helper_classes/10_iterator.md#utils.table.merge)
  - [tnt.utils.table.foreach(tbl, closure[, recursive])](helper_classes/10_iterator.md#utils.table.foreach)
  - [tnt.utils.table.canmergetensor(tbl)](helper_classes/10_iterator.md#utils.table.canmergetensor)
  - [tnt.utils.table.mergetensor(tbl)](helper_classes/10_iterator.md#utils.table.mergetensor)
  - [transform.identity(...)](helper_classes/10_iterator.md#transform.identity)
  - [tnt.ListDataset(self, list, load[, path])](helper_classes/10_iterator.md#ListDataset)
  - [tnt.IndexedDataset(self, fields[, path][, maxload][, mmap][, mmapidx])](helper_classes/10_iterator.md#IndexedDataset)
  - [tnt.IndexedDatasetWriter(self, indexfilename, datafilename, type)](helper_classes/10_iterator.md#IndexedDatasetWriter)
  - [tnt.IndexedDatasetWriter.add(self, tensor)](helper_classes/10_iterator.md#IndexedDatasetWriter.add)
  - [tnt.IndexedDatasetReader(self, indexfilename, datafilename[, mmap][, mmapidx])](helper_classes/10_iterator.md#IndexedDatasetReader)
  - [tnt.IndexedDatasetReader.size(self)](helper_classes/10_iterator.md#IndexedDatasetReader.size)
  - [tnt.IndexedDatasetReader.get(self, index)](helper_classes/10_iterator.md#IndexedDatasetReader.get)
  - [tnt.TransformDataset(self, dataset, transform[, key])](helper_classes/10_iterator.md#TransformDataset)
  - [tnt.TransformDataset(self, dataset, transforms)](helper_classes/10_iterator.md#TransformDataset)
  - [tnt.BatchDataset(self, dataset, batchsize[, perm][, merge][, policy])](helper_classes/10_iterator.md#BatchDataset)
  - [tnt.CoroutineBatchDataset(self, dataset, batchsize[, perm][, merge][, policy])](helper_classes/10_iterator.md#CoroutineBatchDataset)
  - [tnt.ConcatDataset(self, datasets)](helper_classes/10_iterator.md#ConcatDataset)
  - [tnt.ResampleDataset(self, dataset[, sampler][, size])](helper_classes/10_iterator.md#ResampleDataset)
  - [tnt.ShuffleDataset(self, dataset[, size][, replacement])](helper_classes/10_iterator.md#ShuffleDataset)
  - [tnt.ShuffleDataset.resample(self)](helper_classes/10_iterator.md#ShuffleDataset.resample)
  - [tnt.SplitDataset(self, dataset, partitions)](helper_classes/10_iterator.md#SplitDataset)
  - [tnt.SplitDataset.select(self, partition)](helper_classes/10_iterator.md#SplitDataset.select)
  - [tnt.DatasetIterator(self, dataset[, perm][, filter][, transform])](helper_classes/10_iterator.md#DatasetIterator)
  - [tnt.DatasetIterator.exec(tnt.DatasetIterator, name, ...)](helper_classes/10_iterator.md#DatasetIterator.exec)
  - [tnt.ParallelDatasetIterator(self[, init], closure, nthread[, perm][, filter][, transform][, ordered])](helper_classes/10_iterator.md#ParallelDatasetIterator)
  - [tnt.ParallelDatasetIterator.execSingle(tnt.DatasetIterator, name, ...)](helper_classes/10_iterator.md#ParallelDatasetIterator.execSingle)
  - [tnt.ParallelDatasetIterator.exec(tnt.DatasetIterator, name, ...)](helper_classes/10_iterator.md#ParallelDatasetIterator.exec)
  - [tnt.APMeter(self)](helper_classes/10_iterator.md#APMeter)
  - [tnt.AverageValueMeter(self)](helper_classes/10_iterator.md#AverageValueMeter)
  - [tnt.AUCMeter(self)](helper_classes/10_iterator.md#AUCMeter)
  - [tnt.ConfusionMeter(self, k[, normalized])](helper_classes/10_iterator.md#ConfusionMeter)
  - [tnt.mAPMeter(self)](helper_classes/10_iterator.md#mAPMeter)
  - [tnt.MultiLabelConfusionMeter(self, k[, normalized])](helper_classes/10_iterator.md#MultiLabelConfusionMeter)
  - [tnt.ClassErrorMeter(self[, topk][, accuracy])](helper_classes/10_iterator.md#ClassErrorMeter)
  - [tnt.TimeMeter(self[, unit])](helper_classes/10_iterator.md#TimeMeter)
  - [tnt.PrecisionAtKMeter(self[, topk][, dim][, online])](helper_classes/10_iterator.md#PrecisionAtKMeter)
  - [tnt.RecallMeter(self[, threshold][, perclass])](helper_classes/10_iterator.md#RecallMeter)
  - [tnt.PrecisionMeter(self[, threshold][, perclass])](helper_classes/10_iterator.md#PrecisionMeter)
  - [tnt.NDCGMeter(self[, K])](helper_classes/10_iterator.md#NDCGMeter)
  - [tnt.Log(self, keys[, onClose][, onFlush][, onGet][, onSet])](helper_classes/10_iterator.md#Log)
  - [tnt.Log:status(self[, message][, time])](helper_classes/10_iterator.md#Log.status)
  - [tnt.Log:set(self, keys)](helper_classes/10_iterator.md#Log.set)
  - [tnt.Log:get(self, key)](helper_classes/10_iterator.md#Log.get)
  - [tnt.Log:flush(self)](helper_classes/10_iterator.md#Log.flush)
  - [tnt.Log:close(self)](helper_classes/10_iterator.md#Log.close)
  - [tnt.Log:attach(self, event, closures)](helper_classes/10_iterator.md#Log.attach)
  - [tnt.RemoteLog(self, keys[, server][, name][, onClose][, onFlush][, onGet][, onSet])](helper_classes/10_iterator.md#RemoteLog)
  - [Df_Iterator(self, dataset, batch_size[, filter][, transform][, input_transform][, target_transform])](helper_classes/10_iterator.md#Df_Iterator)
- **[Df_ParallelIterator](helper_classes/11_paralleliterator.md)**
  - [Df_ParallelIterator(self, dataset, batch_size[, init], nthread[, filter][, transform][, input_transform][, target_transform][, ordered])](helper_classes/11_paralleliterator.md#Df_ParallelIterator)
- **[Df_Tbl](helper_classes/20_tbl.md)**
- **[Df_Dict](helper_classes/21_dict.md)**
- **[Df_Array](helper_classes/22_array.md)**

## Utils


- **[Utility functions](utils/utils.md)**
  - [trim(s[, ignore])](utils/utils.md#trim)
  - [trim_table_strings(t)](utils/utils.md#trim_table_strings)
  - [table.array2hash(array)](utils/utils.md#table.array2hash)
  - [get_variable_type(value[, prev_type])](utils/utils.md#get_variable_type)
  - [warning(ARGP)](utils/utils.md#warning)
  - [convert_table_2_dataframe(tbl[, value_name][, key_name])](utils/utils.md#convert_table_2_dataframe)
