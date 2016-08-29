# Documentation for sub classes\n

This documentation ha been auto-generated from code using the `argcheck` system.

## Table of contents (file-level)

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.


- [Df_Subset](01_subset.md)
- [Batchframe](10_batchframe.md)

## Detailed table of contents (file-level + anchors)<a name=\"detailed\">


- **[Df_Subset](01_subset.md)**
  - [Df_Subset.__init(self, parent, indexes[, sampler][, label_column][, sampler_args][, batch_args])](01_subset.md#Df_Subset.__init)
  - [Df_Subset._clean(self)](01_subset.md#Df_Subset._clean)
  - [Df_Subset.set_idxs(self, indexes)](01_subset.md#Df_Subset.set_idxs)
  - [Df_Subset.get_idx(self, index)](01_subset.md#Df_Subset.get_idx)
  - [Df_Subset.set_labels(self, label_column)](01_subset.md#Df_Subset.set_labels)
  - [Df_Subset.set_sampler(self, sampler[, sampler_args])](01_subset.md#Df_Subset.set_sampler)
  - [Df_Subset.get_sampler(self, sampler[, args])](01_subset.md#Df_Subset.get_sampler)
  - [Sampler: linear - Df_Subset.get_sampler_linear(self)](01_subset.md#Df_Subset.get_sampler_linear)
  - [Sampler: ordered - Df_Subset.get_sampler_ordered(self)](01_subset.md#Df_Subset.get_sampler_ordered)
  - [Sampler: uniform - Df_Subset.get_sampler_uniform(self)](01_subset.md#Df_Subset.get_sampler_uniform)
  - [Sampler: permutation - Df_Subset.get_sampler_permutation(self)](01_subset.md#Df_Subset.get_sampler_permutation)
  - [Sampler: label-uniform - Df_Subset.get_sampler_label_uniform(self)](01_subset.md#Df_Subset.get_sampler_label_uniform)
  - [Sampler: label-distribution - Df_Subset.get_sampler_label_distribution(self, distribution)](01_subset.md#Df_Subset.get_sampler_label_distribution)
  - [Sampler: label-permutation - Df_Subset.get_sampler_label_permutation(self)](01_subset.md#Df_Subset.get_sampler_label_permutation)
  - [Df_Subset.get_batch(self, no_lines[, class_args])](01_subset.md#Df_Subset.get_batch)
  - [Df_Subset.reset_sampler(self)](01_subset.md#Df_Subset.reset_sampler)
  - [Df_Subset.get_iterator(self, batch_size[, filter][, transform][, input_transform][, target_transform])](01_subset.md#Df_Subset.get_iterator)
  - [Df_Subset.get_parallel_iterator(self, batch_size[, init], nthread[, filter][, transform][, input_transform][, target_transform][, ordered])](01_subset.md#	Df_Subset.get_parallel_iterator)
  - [Df_Subset.size(self[, dim])](01_subset.md#	Df_Subset.size)
  - [Df_Subset.shape(self)](01_subset.md#Df_Subset.shape)
  - [Df_Subset.__tostring__(self)](01_subset.md#	Df_Subset.__tostring__)
  - [Df_Subset.set_data_retriever(self[, data])](01_subset.md#Df_Subset.set_data_retriever)
  - [Df_Subset.set_label_retriever(self[, label])](01_subset.md#Df_Subset.set_label_retriever)
  - [Df_Subset.set_label_shape(self[, label_shape])](01_subset.md#Df_Subset.set_label_shape)
- **[Batchframe](10_batchframe.md)**
  - [Batchframe.__init(self[, data][, label][, label_shape])](10_batchframe.md#Batchframe.__init)
  - [Batchframe.set_data_retriever(self[, data])](10_batchframe.md#Batchframe.set_data_retriever)
  - [Batchframe.get_data_retriever(self)](10_batchframe.md#Batchframe.get_data_retriever)
  - [Batchframe.set_label_retriever(self[, label])](10_batchframe.md#Batchframe.set_label_retriever)
  - [Batchframe.get_label_retriever(self)](10_batchframe.md#Batchframe.get_label_retriever)
  - [Batchframe.set_label_shape(self[, label_shape])](10_batchframe.md#Batchframe.set_label_shape)
  - [Batchframe.to_tensor(self, data_columns, label_columns[, label_shape])](10_batchframe.md#Batchframe.to_tensor)