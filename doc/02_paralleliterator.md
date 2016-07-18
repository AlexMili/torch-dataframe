## Df_ParallelIterator

The Df_ParallelIterator allows parallel loading when callin the `to_tensor`
function. For details see `Df_Iterator` docs.

<a name="Df_ParallelIterator">
##### Df_ParallelIterator(self, dataset, batch_size[, init], nthread[, filter][, transform][, input_transform][, target_transform][, ordered])
```
({
   self             = Df_ParallelIterator  -- 
   dataset          = Df_Subset            -- The Dataframe subset to use for the iterator
   batch_size       = number               -- The size of the batches
  [init             = function]            -- `init(threadid)` (where threadid=1..nthread) is a closure which may
	 initialize the specified thread as needed, if needed. It is loading
	 the libraries 'torch' and 'Dataframe' by default. [has default value]
   nthread          = number               -- The number of threads used to parallelize is specified by `nthread`.
  [filter           = function]            -- is a closure which returns `true` if the given sample
	 should be considered or `false` if not. Note that filter is called _after_
	 fetching the data in a threaded manner and _before_ the `to_tensor` is called. [has default value]
  [transform        = function]            -- a function which maps the given sample to a new value. This transformation occurs before filtering. [has default value]
  [input_transform  = function]            -- Allows transforming the input (data) values after the `Batchframe:to_tensor` call [has default value]
  [target_transform = function]            -- Allows transforming the target (label) values after the `Batchframe:to_tensor` call [has default value]
  [ordered          = boolean]             -- This option is particularly useful for repeatable experiments.
	 By default `ordered` is false, which means that order is not guaranteed by
	 `run()` (though often the ordering is similar in practice).
})
```

Allows to iterate over a dataset in a thread
manner. `Df_ParallelIterator:run()` guarantees that all samples
will be seen, but does not guarantee the order unless `ordered` is set to true.

The purpose of this class is to have a minimal pre-processing cost.
The current implementation calls the `get_batch` inside the scope of the
main process while all the loaders, transformers etc are moved into the threads.
When reading datasets on the fly from
disk (not loading them fully in memory), or performing complex
pre-processing this can be of interest.

A common error raised by this dataset is when `closure()` is not
serializable. Make sure that all [upvalues](http://www.lua.org/pil/27.3.3.html) of `closure()` are
serializable. It is recommended to avoid [upvalues](http://www.lua.org/pil/27.3.3.html) at all cost,
and to make sure you require all the appropriate torch packages needed to (de-)serialize
`closure()` in the `init()` function.

For more information, check out the [threads package](https://github.com/torch/threads),
on which `Df_ParallelIterator` relies.
