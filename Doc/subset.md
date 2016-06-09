
## Df_Subset class

The subset class contains all the information for a specific subset of an
associated Dataframe. It is generally owned by a dataframe and simply initiates
values/functions associated with subsetting, e.g. samplers, which indexes are
in a particular subset.

<a name="Df_Subset.__init">
### Df_Subset.__init(self, indexes, sampler, parent)

Creates and initializes a Df_Subset class.

```
({
   self    = Df_Subset  -- 
   indexes = Df_Array   -- The indexes in the original dataset to use for sampling
   sampler = string     -- The sampler to use with this data
   parent  = Dataframe  -- The parent Dataframe that will be stored by reference
})
```

Some of the samplers require a label column to which the samples will be balanced.
The label-distribution furthermore also requires a distribution,
e.g. `{train = {distribution = Df_Dict({A = 2, B=10})}}`

```
({
   self         = Df_Subset  -- 
   indexes      = Df_Array   -- The indexes in the original dataset to use for sampling
   sampler      = string     -- The sampler to use with this data
   labels       = Df_Array   -- The column with all the labels (note this is passed by reference)
  [sampler_args = Df_Dict]   -- Optional arguments for the sampler function, currently only used for
	 the label-distribution sampler. [default=false]
   parent       = Dataframe  -- The parent Dataframe that will be stored by reference
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
### Df_Subset.set_labels(self, labels)

Set the labels needed for certain samplers

```
({
   self   = Df_Subset  -- 
   labels = Df_Array   -- The column with all the labels (note this is passed by reference)
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
### Df_Subset.get_batch(self, no_lines)

Retrieves a batch of given size using the set sampler. If sampler needs resetting
then the batch will be either smaller than the requested number or nil.

```
({
   self     = Df_Subset  -- 
   no_lines = number     -- The number of lines/rows to include (-1 for all)
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
