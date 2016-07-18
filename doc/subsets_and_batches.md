
## Subsets and batches

The core idea behind loading batches and is that you split your dataset using the
`create_subsets` function where you can also choose the sampler that you want. The
sampler will decide how `get_batch` retrieves a Batchframe object. The Batchframe
is a sub_class to Dataframe with the major difference being the `to_tensor` functionality
that has here been extended so that you can load data and labels from the same dataset.

If you want to run the batch loader in parallel you need to keep the sampling in
the main thread and do the `to_tensor` conversion in the threads. This as the offset
for the sampler is hidden inside the samplers local environement and the main thread
has no way of knowing that you've sampled the next 30 cases in the data in a subthread.

<a name="Dataframe.create_subsets">
### Dataframe.create_subsets(self[, class_args])

Initializes the metadata needed for batch loading:

_ Subsets e.g. for training, validating, and testing

_ Samplers associated with the above

The default data subsets and propotions are:
```
{['train'] = 0.7,
 ['validate'] = 0.2,
 ['test'] = 0.1}
```

The samplers defaults to permutation for the train set while the validate and
test have a linear. If you provide a string identifying the sampler it will be
used by all the subsets.

You can specify the data and label loaders used in the `Batchframe` by passing
the class argument. This is passed to the `Df_Subset` that then in turn passes
the information forward to the batches themself. As this is cascading through
the objects you must wrap the argument in multiple `Df_Tbl` for it to work, here
is a basic example:

```lua
my_data:create_subsets{
	class_args = Df_Tbl({
		batch_args = Df_Tbl({
			data = function(row) image_loader(row.filename) end,
			label = Df_Array("Gender")
		})
	})
}
```

The metadata is stored under `self.subsets.*`.

_Note_: This function must be called prior to load_batch as it needs the
information for loading correct rows.

_Return value_: self

```
({
   self       = Dataframe  -- 
  [class_args = Df_Tbl]    -- Arguments to be passed to the class initializer
})
```


```
({
   self       = Dataframe  -- 
   subsets    = Df_Dict    -- The default data subsets
  [class_args = Df_Tbl]    -- Arguments to be passed to the class initializer
})
```


```
({
   self         = Dataframe  -- 
   subsets      = Df_Dict    -- The default data subsets
   sampler      = string     -- The sampler to use together with all subsets.
  [label_column = string]    -- The label based samplers need a column with labels [default=false]
  [sampler_args = Df_Tbl]    -- Arguments needed for some of the samplers - currently only used by
	 the label-distribution sampler that needs the distribution. Note that
	 you need to have a somewhat complex table:
	 `Df_Tbl({train = Df_Dict({distribution = Df_Dict({A = 2, B=10})})})`. [default=false]
  [class_args   = Df_Tbl]    -- Arguments to be passed to the class initializer
})
```


```
({
   self         = Dataframe  -- 
   subsets      = Df_Dict    -- The default data subsets
   samplers     = Df_Dict    -- The samplers to use together with the subsets.
  [label_column = string]    -- The label based samplers need a column with labels
  [sampler_args = Df_Tbl]    -- Arguments needed for some of the samplers - currently only used by
	 the label-distribution sampler that needs the distribution. Note that
	 you need to have a somewhat complex table:
	 `Df_Tbl({train = Df_Dict({distribution = Df_Dict({A = 2, B=10})})})`.
  [class_args   = Df_Tbl]    -- Arguments to be passed to the class initializer
})
```

<a name="Dataframe.reset_subsets">
### Dataframe.reset_subsets(self)

Clears the previous subsets and creates new ones according to saved information
in the `self.subsets.subset_splits` and `subsets.subsets.samplers` created by
the `create_subsets` function.

```
({
   self = Dataframe  -- 
})
```

_Return value_: self
<a name="Dataframe.has_subset">
### Dataframe.has_subset(self, subset)

Checks if subset used in batch loading is available

```
({
   self   = Dataframe  -- 
   subset = string     -- Type of subset to check for
})
```

_Return value_: boolean
<a name="Dataframe.get_subset">
### Dataframe.get_subset(self, subset[, frame_type][, class_args])

Returns the entire subset as either a Df_Subset, Dataframe or Batchframe

```
({
   self       = Dataframe  -- 
   subset     = string     -- Type of data to load
  [frame_type = string]    -- Choose the type of return object that you're interested in.
	 Return a Batchframe with a different `to_tensor` functionality that allows
	 loading data, label tensors simultaneously [default=Df_Subset]
  [class_args = Df_Tbl]    -- 	 Arguments to be passed to the class initializer - overrides the arguments within the
	 self.subsets that is stored after the `create_subsets` call.
	 
})
```

_Return value_: Df_Subset, Dataframe or Batchframe
