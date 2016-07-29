## Df_Iterator and general about Dataframe's iterators

The `torchnet` iterators allow a simple iteration over a dataset. If combined
with a list function you can create so that the iterators returns a table with
the two key elements `input` and `target` that `tnt.SGDEngine` and
`tnt.OptimEngine` require.

The Dataframe approach is to combine everything into a single iterator that does
returns the training tensors. This is a complement to the subset `get_batch`
function and relies on the same core functions.

Iterators implement two methods:

- `run()` which returns a Lua iterator usable in a for loop.
- `exec(funcname, ...)` which execute a given funcname on the underlying dataset.

Typical usage is achieved with a for loop:
```lua
for sample in iterator:run() do
  <do something with sample>
end
```

Iterators implement the `__call` event, so one might also use the `()` operator:
```lua
for sample in iterator() do
  <do something with sample>
end
```

**Important:** The `tnt.DatasetIterator` does not reset the iterator after running
to the end. In order to do this you must add a `reset_sampler` call in the endEpoch
hook for the engine:

```lua
engine.hooks.onEndEpoch = function(state)
	state.iterator.dataset:reset_sampler()
end
```

As torchnet is epoch-centered all samplers will be behave as if there was an underlying
epoch mechanism. E.g. the uniform sampler will never trigger a reset but the epoch
hook will still be called as there is a "fake epoch" calculated by
`math.ceil(dataset:size()/batch_size)`.

**Note**: An important note is that the transform and filters are ran before the
`to_tensor` as they are assumed to be more valuable with the raw data. As transformations
can be useful after the tensors have been generated the `target_transform` and `input_transform`
have been added that allow transforming the two tensor elements in the return table.

<a name="Df_Iterator">
##### Df_Iterator(self, dataset, batch_size[, filter][, transform][, input_transform][, target_transform])

After creating your data split (`create_subsets`) you call the `get_subset` and
get the subset that you need to feed to this method. Remember that you must define
the data and label retrievers that the `Batchframe` will use when calling the
`to_tensor`. The default retrievers can be set through the `class_args` argument:

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

```
({
   self             = Df_Iterator  -- 
   dataset          = Df_Subset    -- 
   batch_size       = number       -- The size of the batches
  [filter           = function]    -- is a closure which returns `true` if the given sample
	 should be considered or `false` if not. Note that filter is called _after_
	 fetching the data in a threaded manner and _before_ the `to_tensor` is called. [has default value]
  [transform        = function]    -- a function which maps the given sample to a new value. This transformation occurs before filtering. [has default value]
  [input_transform  = function]    -- Allows transforming the input (data) values after the `Batchframe:to_tensor` call [has default value]
  [target_transform = function]    -- Allows transforming the target (label) values after the `Batchframe:to_tensor` call [has default value]
})
```

