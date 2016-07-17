--[[
	Copyright (c) 2016-present, Facebook, Inc.
	All rights reserved.

	This source code is licensed under the BSD-style license found in the
	LICENSE file in the Facebook license in the same directory as this file. An
	additional grant of patent rights can be found in the PATENTS file in the
	same directory.
]]--

require 'torchnet'
local Threads = require 'threads'
local argcheck = require 'argcheck'
local doc = require 'argcheck.doc'

local Df_ParallelIterator = torch.class('Df_ParallelIterator', 'tnt.DatasetIterator')

Df_ParallelIterator.__init = argcheck{
	doc = [[
<a name="Df_ParallelIterator">
##### Df_ParallelIterator(@ARGP)
@ARGT

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
]],
	{name='self', type='Df_ParallelIterator'},
	{name='data', type='Df_Subset', doc='The Dataframe subset to use for the iterator'},
	{name="batch_size", type="number", doc="The size of the batches"},
	{name='init', type='function', default=function(idx)
		-- Load the libraries needed
		require 'torch'
		require 'Dataframe'
	end,
	 doc=[[`init(threadid)` (where threadid=1..nthread) is a closure which may
	 initialize the specified thread as needed, if needed. It is loading
	 the libraries 'torch' and 'Dataframe' by default.]]},
	{name='nthread', type='number',
	 doc='The number of threads used to parallelize is specified by `nthread`.'},
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
	{name='ordered', type='boolean', default=false,
	 doc=[[When `ordered` is set to true the ordering of samples returned by the iterator
	 is guaranteed. This option is particularly useful for repeatable experiments.
	 By default `ordered` is false, which means that order is not guaranteed by
	 `run()` (though often the ordering is similar in practice).]]},
	call =
	function(self, data, batch_size, init, nthread, filter, transform, input_transform, target_transform, ordered)
		assert(isint(batch_size) and batch_size > 0, "The batch size must be a positive integer")
		assert(data.batch_args,
		       "If you want to use the iterator you must prespecify the batch data/label loaders")

		-- The sharing allows shared access to tds/tensors
		Threads.serialization('threads.sharedserialize')

		-- Initialize the threads and the environement
		local threads = Threads(nthread, init)
		self.__threads = threads
		self.__nthread = nthread

		self.dataset = data


		-- The size should be the number of batches that will be performed
		local size = math.ceil(data:size()/batch_size)

		local sample -- beware: do not put this line in loop()
		local sampleOrigIdx

		function self.run()
			-- loading size of the dataset each time run() is called
			threads:addjob(
				function(argList)
					-- make the mod/filter functions global
					filter, transform, input_transform, target_transform = unpack(argList)
				end,
				function()
				end,
				{filter, transform, input_transform, target_transform}
			)
			threads:dojob()

			-- `samplePlaceholder` stands in for samples which have been
			-- filtered out by the `filter` function
			local samplePlaceholder = {}

			-- The enque does the main loop
			local idx = 1
			local function enqueue()
				while idx <= size and threads:acceptsjob() do
					local batch, reset = self.dataset:get_batch(batch_size)

					if (reset) then
						idx = size + 1
					else
						idx = idx + 1
					end

					if (batch) then

						-- In the parallel section only the to_tensor is run in parallel
						--  this should though be the computationally expensive operation
						threads:addjob(
							function(argList)
								local origIdx, serialized_batch, samplePlaceholder = unpack(argList)
								local batch = torch.deserialize(serialized_batch)
								batch = transform(batch)

								local sample = samplePlaceholder
								if (filter(batch)) then
									sample = {}
									sample.input, sample.target = batch:to_tensor()
								end

								collectgarbage()
								collectgarbage()

								return {
									sample,
									origIdx
								}
							end,
							function(argList)
								sample, sampleOrigIdx = unpack(argList)
							end,
							{idx, torch.serialize(batch), samplePlaceholder}
						)
					end
				end
			end

			enqueue()

			local iterFunction
			if ordered then
				local curSampleIdx = 1
				local storedSamples = {}

				-- Move past placeholders (filtered out samples) in
				-- `storedSamples`
				local function advancePastPlaceholders()
					while table.exact_length(storedSamples[curSampleIdx]) == 0 do
						storedSamples[curSampleIdx] = nil
						curSampleIdx = curSampleIdx + 1
					end
				end

				iterFunction = function()
					advancePastPlaceholders()

					-- Load into storedSamples until we find the next sample in
					-- the sequence or we run out of samples
					while storedSamples[curSampleIdx] == nil and threads:hasjob() do
						enqueue()
						threads:dojob()
						if threads:haserror() then
							threads:synchronize()
						end
						enqueue()

						storedSamples[sampleOrigIdx] = sample

						advancePastPlaceholders()
					end

					enqueue()

					local curSample = storedSamples[curSampleIdx]
					storedSamples[curSampleIdx] = nil

					curSampleIdx = curSampleIdx + 1

					return curSample
				end
			else
				iterFunction = function()
					while threads:hasjob() do
						enqueue()
						threads:dojob()
						if threads:haserror() then
							threads:synchronize()
						end
						enqueue()

						if table.exact_length(sample) > 0 then
							return sample
						end
					end
				end
			end

			return iterFunction
		end
	end
}
