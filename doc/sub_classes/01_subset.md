# API documentation for [Df_Subset](#__Df_Subset__)
- [Df_Subset.`__init`](#Df_Subset.__init)
- [Df_Subset.`_clean`](#Df_Subset._clean)
- [Df_Subset.set_idxs](#Df_Subset.set_idxs)
- [Df_Subset.get_idx](#Df_Subset.get_idx)
- [Df_Subset.set_labels](#Df_Subset.set_labels)
- [Df_Subset.set_sampler](#Df_Subset.set_sampler)
- [Df_Subset.get_sampler](#Df_Subset.get_sampler)
- [Sampler: linear - Df_Subset.get_sampler_linear](#Df_Subset.get_sampler_linear)
- [Sampler: ordered - Df_Subset.get_sampler_ordered](#Df_Subset.get_sampler_ordered)
- [Sampler: uniform - Df_Subset.get_sampler_uniform](#Df_Subset.get_sampler_uniform)
- [Sampler: permutation - Df_Subset.get_sampler_permutation](#Df_Subset.get_sampler_permutation)
- [Sampler: label-uniform - Df_Subset.get_sampler_label_uniform](#Df_Subset.get_sampler_label_uniform)
- [Sampler: label-distribution - Df_Subset.get_sampler_label_distribution](#Df_Subset.get_sampler_label_distribution)
- [Sampler: label-permutation - Df_Subset.get_sampler_label_permutation](#Df_Subset.get_sampler_label_permutation)
- [Df_Subset.get_batch](#Df_Subset.get_batch)
- [Df_Subset.reset_sampler](#Df_Subset.reset_sampler)
- [Df_Subset.get_iterator](#Df_Subset.get_iterator)
- [Df_Subset.get_parallel_iterator](#Df_Subset.get_parallel_iterator)
- [Df_Subset.`__tostring__`](#Df_Subset.__tostring__)
- [Df_Subset.set_data_retriever](#Df_Subset.set_data_retriever)
- [Df_Subset.set_label_retriever](#Df_Subset.set_label_retriever)
- [Df_Subset.set_label_shape](#Df_Subset.set_label_shape)

<a name="__Df_Subset__">
## Df_Subset

The subset class contains all the information for a specific subset of an
associated Dataframe. It is generally owned by a dataframe and simply initiates
values/functions associated with subsetting, e.g. samplers, which indexes are
in a particular subset.

<a name="Df_Subset.__init">
### Df_Subset.__init(self, parent, indexes[, sampler][, label_column][, sampler_args][, batch_args])

Creates and initializes a Df_Subset class.

```
({
   self         = Df_Subset  -- 
   parent       = Dataframe  -- The parent Dataframe that will be stored by reference
   indexes      = Df_Array   -- The indexes in the original dataset to use for sampling
  [sampler      = string]    -- The sampler to use with this data
  [label_column = string]    -- The column with all the labels (a local copy will be generated)
  [sampler_args = Df_Dict]   -- Optional arguments for the sampler function, currently only used for
		the label-distribution sampler.
  [batch_args   = Df_Tbl]    -- Arguments to be passed to the Batchframe class initializer
})
```

<a name="Df_Subset._clean">
### Df_Subset._clean(self)

Reset the internal data

```
({
   self = Df_Subset  -- 
})
```

_Return value_: self
<a name="Df_Subset.set_idxs">
### Df_Subset.set_idxs(self, indexes)

Set the indexes

```
({
   self    = Df_Subset  -- 
   indexes = Df_Array   -- The indexes in the original dataset to use for sampling
})
```

_Return value_: self
<a name="Df_Subset.get_idx">
### Df_Subset.get_idx(self, index)

Get the index fromm the parent Dataframe that a local index corresponds to

```
({
   self  = Df_Subset  -- 
   index = number     -- The subset's index that you want the original index for
})
```

_Return value_: integer
<a name="Df_Subset.set_labels">
### Df_Subset.set_labels(self, label_column)

Set the labels needed for certain samplers

```
({
   self         = Df_Subset  -- 
   label_column = string     -- The column with all the labels
})
```

_Return value_: self
<a name="Df_Subset.set_sampler">
### Df_Subset.set_sampler(self, sampler[, sampler_args])

Set the sampler function that is associated with this subset

```
({
   self         = Df_Subset  -- 
   sampler      = string     -- The indexes in the original dataset to use for sampling
  [sampler_args = Df_Dict]   -- Optional arguments for the sampler function, currently only used for
	 the label-distribution sampler. [default=false]
})
```

_Return value_: self

## Sampler functions

The sampler functions come from the [torch-dataset](https://github.com/twitter/torch-dataset/blob/master/lua/Sampler.lua)
and have been adapted for the torch-dataframe package. In the original samplers
you had the option of sampling one label at the time. As this may be confusing together
with the data split subsets you should in this package start with subsetting the data first
using the `where` function for attaining the same functionality.

<a name="Df_Subset.get_sampler">
### Df_Subset.get_sampler(self, sampler[, args])

Retrieves a sampler function used in `get_batch`. Depending on the chosed sampler
some will return `nil` as you have reached the end, usually 1 epoch. In order to
restart the sampler you will then have to call the reset function. The samplers
with reset functions are:

- linear
- permutation

```
({
   self    = Df_Subset  -- 
   sampler = string     -- The sampler function name. Hyphens are replaced with underscore
  [args    = Df_Dict]   -- Arguments that should be passed to function [default=false]
})
```

_Return value_: (1) a sampler function (2) a reset sampler function
<a name="Df_Subset.get_sampler_linear">
### Sampler: linear - Df_Subset.get_sampler_linear(self)

A linear sampler, i.e. walk the records from start to end, after the end the
function returns nil until the reset is called that loops back to the start.
*Note*: Due to the permutation in `create_subsets` the samples will appear permuted
when walking through them unless you've only created a single subset with all the
data (a special case that does not permute the order).

```
({
   self = Df_Subset  -- 
})
```

_Return value_: (1) a sampler function (2) a reset sampler function
<a name="Df_Subset.get_sampler_ordered">
### Sampler: ordered - Df_Subset.get_sampler_ordered(self)

A sampler that orders all the samples before walking the records from start to end.
After the end the function returns nil until the reset is called that loops back to the start.

```
({
   self = Df_Subset  -- 
})
```

_Return value_: (1) a sampler function (2) a reset sampler function
<a name="Df_Subset.get_sampler_uniform">
### Sampler: uniform - Df_Subset.get_sampler_uniform(self)

A uniform neverending sampling.

```
({
   self = Df_Subset  -- 
})
```

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
<a name="Df_Subset.get_sampler_permutation">
### Sampler: permutation - Df_Subset.get_sampler_permutation(self)

Permutations with shuffling after each epoch. Needs reset or the function only returns nil after 1 epoch

```
({
   self = Df_Subset  -- 
})
```

_Return value_: (1) a sampler function (2) a reset sampler function
<a name="Df_Subset.get_sampler_label_uniform">
### Sampler: label-uniform - Df_Subset.get_sampler_label_uniform(self)

Uniform sampling from each label.

```
({
   self = Df_Subset  -- 
})
```

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
<a name="Df_Subset.get_sampler_label_distribution">
### Sampler: label-distribution - Df_Subset.get_sampler_label_distribution(self, distribution)

Sample according to a distribution for each label. If a label is missing and `distribution.autoFill`
is set then the weights are assigned either `distribution.defaultWeight` or 1 is missing.

```
({
   self         = Df_Subset  -- 
   distribution = Df_Dict    -- The distribution for the labels from which to sample
})
```

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
<a name="Df_Subset.get_sampler_label_permutation">
### Sampler: label-permutation - Df_Subset.get_sampler_label_permutation(self)

Sample according to per label permutation. Once a labels permutations have been passed
it's reinitialized with a new permutation. The function permutes each class and then
also permutes the cases within each group.

Note that one epoch may be multiple passes for a class with few cases while the
larger classes will not have passed through the examples even once. All samples will
have passed at iteration: `no_cases_in_larges_class * no_classes`

```
({
   self = Df_Subset  -- 
})
```

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
<a name="Df_Subset.get_batch">
### Df_Subset.get_batch(self, no_lines[, class_args])

Retrieves a batch of given size using the set sampler. If sampler needs resetting
then the second return statement will be `true`. Note that the last batch may be
smaller than the requested number when using samplers that require resetting. Once
you ave retrieved all available examples using one of the resetting samplers the
returned batch will be `nil`.

```
({
   self       = Df_Subset  -- 
   no_lines   = number     -- The number of lines/rows to include (-1 for all)
  [class_args = Df_Tbl]    -- Arguments to be passed to the class initializer
})
```

_Return value_: Batchframe, boolean (if reset_sampler() should be called)
<a name="Df_Subset.reset_sampler">
### Df_Subset.reset_sampler(self)

Resets the sampler. This is needed for a few samplers and is easily checked for
in the 2nd return value from `get_batch`

```
({
   self = Df_Subset  -- 
})
```

_Return value_: self
<a name="Df_Subset.get_iterator">
### Df_Subset.get_iterator(self, batch_size[, filter][, transform][, input_transform][, target_transform])

**Important**: See the docs for Df_Iterator

```
({
   self             = Df_Subset  -- 
   batch_size       = number     -- The size of the batches
  [filter           = function]  -- See `tnt.DatasetIterator` definition [has default value]
  [transform        = function]  -- See `tnt.DatasetIterator` definition. Runs immediately after the `get_batch` call [has default value]
  [input_transform  = function]  -- Allows transforming the input (data) values after the `Batchframe:to_tensor` call [has default value]
  [target_transform = function]  -- Allows transforming the target (label) values after the `Batchframe:to_tensor` call [has default value]
})
```

_Return value_: `Df_Iterator`
	<a name="Df_Subset.get_parallel_iterator">
### Df_Subset.get_parallel_iterator(self, batch_size[, init], nthread[, filter][, transform][, input_transform][, target_transform][, ordered])

**Important**: See the docs for Df_Iterator and Df_ParallelIterator

```
({
   self             = Df_Subset  -- 
   batch_size       = number     -- The size of the batches
  [init             = function]  -- `init(threadid)` (where threadid=1..nthread) is a closure which may
	 initialize the specified thread as needed, if needed. It is loading
	 the libraries 'torch' and 'Dataframe' by default. [has default value]
   nthread          = number     -- The number of threads used to parallelize is specified by `nthread`.
  [filter           = function]  -- is a closure which returns `true` if the given sample
	 should be considered or `false` if not. Note that filter is called _after_
	 fetching the data in a threaded manner and _before_ the `to_tensor` is called. [has default value]
  [transform        = function]  -- a function which maps the given sample to a new value. This transformation occurs before filtering. [has default value]
  [input_transform  = function]  -- Allows transforming the input (data) values after the `Batchframe:to_tensor` call [has default value]
  [target_transform = function]  -- Allows transforming the target (label) values after the `Batchframe:to_tensor` call [has default value]
  [ordered          = boolean]   -- This option is particularly useful for repeatable experiments.
	 By default `ordered` is false, which means that order is not guaranteed by
	 `run()` (though often the ordering is similar in practice).
})
```

_Return value_: `Df_ParallelIterator`
		<a name="Df_Subset.__tostring__">
### Df_Subset.__tostring__(self)

```
({
   self = Dataframe  -- 
})
```

_Return value_: string
<a name="Df_Subset.set_data_retriever">
### Df_Subset.set_data_retriever(self[, data])

Sets the self.batch_args.data to either a function for loading data or
a set of columns that should be used in the to_tensor functions.

```
({
   self = Df_Subset           -- 
  [data = function|Df_Array]  -- The data loading procedure/columns. If omitted the retriever will be erased
})
```

_Return value_: self
<a name="Df_Subset.set_label_retriever">
### Df_Subset.set_label_retriever(self[, label])

Sets the self.batch_args.data to either a function for loading data or
a set of columns that should be used in the to_tensor functions.

```
({
   self  = Df_Subset           -- 
  [label = function|Df_Array]  -- The label loading procedure/columns. If omitted the retriever will be erased
})
```

_Return value_: self
<a name="Df_Subset.set_label_shape">
### Df_Subset.set_label_shape(self[, label_shape])

Sets the self.batch_args.label_shape for transforming the data into
requested format

```
({
   self        = Df_Subset  -- 
  [label_shape = string]    -- The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.
})
```

_Return value_: self