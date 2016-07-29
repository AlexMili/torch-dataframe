-- Skip if the Df_Iterator has already been loaded via paralleliterator
if (Df_Iterator) then
	return true
end

local torchnet = require 'torchnet'
local argcheck = require 'argcheck'
local doc = require 'argcheck.doc'

doc[[
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

]]

local Df_Iterator, parent_class = torch.class('Df_Iterator', 'tnt.DatasetIterator')

-- iterate over a dataset
Df_Iterator.__init = argcheck{
	doc = [[
<a name="Df_Iterator">
##### Df_Iterator(@ARGP)

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

@ARGT

]],
	{name='self', type='Df_Iterator'},
	{name='dataset', type='Df_Subset'},
	{name="batch_size", type="number", doc="The size of the batches"},
	{name='filter', type='function', default=function(sample) return true end,
	 doc=[[is a closure which returns `true` if the given sample
	 should be considered or `false` if not. Note that filter is called _after_
	 fetching the data in a threaded manner and _before_ the `to_tensor` is called.]]},
	{name='transform', type='function', default=function(sample) return sample end,
	 doc='a function which maps the given sample to a new value. This transformation occurs before filtering.'},
	{name='input_transform', type='function', default=function(val) return val end,
	 doc="Allows transforming the input (data) values after the `Batchframe:to_tensor` call"},
	{name='target_transform', type='function', default=function(val) return val end,
	 doc="Allows transforming the target (label) values after the `Batchframe:to_tensor` call"},
	call = function(self, dataset, batch_size, filter, transform, input_transform, target_transform)
	assert(dataset.batch_args,
	      "If you want to use the iterator you must prespecify the batch data/label loaders")
	assert(isint(batch_size) and batch_size > 0, "The batch size must be a positive integer")

	self.dataset = dataset

	function self.run()
		local size = math.ceil(self:exec("size")/batch_size)
		local idx = 1 -- TODO: Should the idx be skipped since the Dataframe implementation doesn require it?
		return function()
			while idx <= size do
				local sample, reset = self:exec("get_batch", batch_size)

				if (reset) then
					idx = size + 1
				else
					idx = idx + 1
				end

				-- The samplers may return nil value if a reset is needed
				if (sample) then
					sample = transform(sample)

					-- Only return non-nil values
					if (filter(sample)) then
						local input, target = sample:to_tensor()
						return {
							input = input_transform(input),
							target = target_transform(target)
						}
					end
				end
			end -- End while

		end
	end
end}
