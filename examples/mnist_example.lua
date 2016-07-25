--[[
Copyright (c) 2016-present, Facebook, Inc.
All rights reserved.
This source code is licensed under the BSD-style license found in the
LICENSE file in the Facebook license in the same directory as this file. An
additional grant of patent rights can be found in the PATENTS file in the
same directory.
]]--
-- load torchnet:
local tnt = require 'torchnet'

require 'Dataframe'

-- use GPU or not:
local cmd = torch.CmdLine()
cmd:option('-usegpu', false, 'use gpu for training')
cmd:option('-parallel', false, 'use multithreaded loading for training')

local config = cmd:parse(arg)
print(string.format('running on %s', config.usegpu and 'GPU' or 'CPU'))
print(string.format('using %s execution', config.parallel and 'parallel' or 'single thread'))

-- function that sets of dataset iterator:
local function getIterator(mode)
	-- load MNIST dataset:
	local mnist = require 'mnist'
	local mnist_dataset = mnist[mode .. 'dataset']()

	-- Create a Dataframe with the label. The actual images will be loaded
	--  as an external resource
	local df = Dataframe(
		Df_Dict{
			label = mnist_dataset.label:totable(),
			row_id = torch.range(1, mnist_dataset.data:size(1)):totable()
		})

	-- Since the mnist package already has taken care of the data
	--  splitting we create a single subsetter
	df:create_subsets{
		subsets = Df_Dict{core = 1},
		data_retriever = function(row)
			return ext_resource[row.row_id]
		end,
		label_retriever = Df_Array("label")
	}

	local subset = df["/core"]
	if (config.parallel) then
		return Df_ParallelIterator{
			dataset = subset,
			batch_size = 128,
			init = function(idx)
				-- Load the libraries needed
				require 'torch'
				require 'Dataframe'

				-- Load the datasets external resource
				local mnist = require 'mnist'
				local mnist_dataset = mnist[mode .. 'dataset']()
				ext_resource = mnist_dataset.data:reshape(mnist_dataset.data:size(1),
					mnist_dataset.data:size(2) * mnist_dataset.data:size(3)):double()
			end,
			nthread = 2,
			target_transform =  function(val)
				return val + 1
			end
		}
	else
		ext_resource = mnist_dataset.data:reshape(mnist_dataset.data:size(1),
			mnist_dataset.data:size(2) * mnist_dataset.data:size(3)):double()

		return Df_Iterator{
			dataset = subset,
			batch_size = 128,
			target_transform = function(val)
				return val + 1
			end
		}
	end
end

-- set up logistic regressor:
local net = nn.Sequential():add(nn.Linear(784,10))
local criterion = nn.CrossEntropyCriterion()

-- set up training engine:
local engine = tnt.SGDEngine()
local meter  = tnt.AverageValueMeter()
local clerr  = tnt.ClassErrorMeter{topk = {1}}
engine.hooks.onStartEpoch = function(state)
	meter:reset()
	clerr:reset()
end
engine.hooks.onForwardCriterion = function(state)
	meter:add(state.criterion.output)
	clerr:add(state.network.output, state.sample.target)
	if state.training then
		print(string.format('avg. loss: %2.2f; avg. error: %2.2f',
			meter:value(), clerr:value{k = 1}))
	end
end
-- After each epoch we need to envoke the sampler reset (only needed for some samples)
engine.hooks.onEndEpoch = function(state)
	print("End epoch no " .. state.epoch)
	state.iterator.dataset:reset_sampler()
end

-- set up GPU training:
if config.usegpu then

	-- copy model to GPU:
	require 'cunn'
	net       = net:cuda()
	criterion = criterion:cuda()

	-- copy sample to GPU buffer:
	local igpu, tgpu = torch.CudaTensor(), torch.CudaTensor()
	engine.hooks.onSample = function(state)
		igpu:resize(state.sample.input:size() ):copy(state.sample.input)
		tgpu:resize(state.sample.target:size()):copy(state.sample.target)
		state.sample.input  = igpu
		state.sample.target = tgpu
	end  -- alternatively, this logic can be implemented via a TransformDataset
end

-- train the model:
engine:train{
	network   = net,
	iterator  = getIterator('train'),
	criterion = criterion,
	lr        = 0.2,
	maxepoch  = 3,
}

-- measure test loss and error:
meter:reset()
clerr:reset()
engine:test{
	network   = net,
	iterator  = getIterator('test'),
	criterion = criterion,
}
print("\n ***** Done *****")
print(string.format('test loss: %2.2f; test error: %2.2f',
	meter:value(), clerr:value{k = 1}))
