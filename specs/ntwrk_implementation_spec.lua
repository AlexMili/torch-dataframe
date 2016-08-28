require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
	lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe([[
	See if we can get #network and other tensor implementations
	#skip_version_LUA51
]], function()
	describe([[
		Single target with a the Batchframe generated tensors
	]], function()
		it("A single input and classifier", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets()
			a:as_categorical("Gender")

			local batch = a["/train"]:get_batch(5,
			Df_Tbl({
				data = Df_Array("Weight"),
				label = Df_Array("Gender")
			}))

			local data, label =
			batch:to_tensor()

			require 'nn'
			local net = nn.Sequential():add(nn.Linear(1,2))
			local criterion = nn.CrossEntropyCriterion()

			net:forward(data)
			local total_err = criterion:forward(net.output, label)

			local seq_err = {}
			for i=1,#batch do
				net:forward(data[i])
				seq_err[#seq_err + 1] = criterion:forward(net.output, label[i])
			end
			seq_err = torch.Tensor(seq_err):mean()

			assert.near(seq_err, total_err, 10^-6, "Errors are not identical when running alone or in batch")
		end)

		it("A a tensor input and a #linear_regression", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets()
			torch.manualSeed(2313)

			local batch = a["/train"]:get_batch(5,
			Df_Tbl({
				data = function(row)
					return torch.rand(10)
				end,
				label = Df_Array("Weight")
			}))

			local data, label =
			batch:to_tensor()

			require 'nn'
			local net = nn.Sequential():
			add(nn.Linear(10,1))
			local criterion = nn.MSECriterion()

			net:forward(data)
			local total_err = criterion:forward(net.output, label)

			local seq_err = {}
			for i=1,#batch do
				net:forward(data[i])
				seq_err[#seq_err + 1] = criterion:forward(net.output, label[i])
			end
			seq_err = torch.Tensor(seq_err):mean()

			assert.near(seq_err, total_err, 10^-6, "Errors are not identical when running alone or in batch")
		end)
	end)


	describe([[
		Multiple targets with a the Batchframe generated tensors
		#multiple
	]], function()
		it("Regression targets #multreg", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets()
			torch.manualSeed(9823719)

			local batch = a["/train"]:get_batch(5,
			Df_Tbl({
				data = function(row)
					return torch.rand(10)
				end,
				label = function(row)
					return torch.rand(2)
				end,
				label_shape = "NxMx1"
			}))

			local data, label =
			batch:to_tensor()

			require 'nn'
			local net = nn.Sequential()
			net:add(nn.Linear(10,50))

			local prl = nn.ConcatTable()
			local criterion = nn.ParallelCriterion()

			for i=1,2 do
				subnet = nn.Sequential():
				add(nn.Linear(50,1))
				criterion:add(nn.MSECriterion())

				prl:add(subnet)
			end

			net:add(prl)

			net:forward(data)

			local total_err = criterion:forward(net.output, label)

			local seq_err = {}
			for i=1,#batch do
				local _row_ = {
					label[1][i],
					label[2][i]
				}
				net:forward(data[i])
				seq_err[#seq_err + 1] = criterion:forward(net.output, _row_)
			end
			seq_err = torch.Tensor(seq_err):mean()

			assert.near(seq_err, total_err, 10^-6, "Errors are not identical when running alone or in batch")
		end)

		it("Classification targets #multclss", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets()
			a:as_categorical("Gender")
			a:add_column{
				column_name = "Overweight",
				type = "integer"
			}
			a:update(
			function(row) return true end,
			function(row)
				if (row["Weight"] >= 25) then
					row["Overweight"] = 1
				else
					row["Overweight"] = 0
				end

				return row
			end)
			torch.manualSeed(823609)

			local batch = a["/train"]:get_batch(5,
			Df_Tbl({
				data = function(row)
					return torch.rand(10)
				end,
				label = Df_Array("Gender", "Overweight"),
				label_shape = "NxM"
			}))

			local data, label = batch:to_tensor()

			require 'nn'
			local net = nn.Sequential()
			net:add(nn.Linear(10,50))

			local prl = nn.ConcatTable()
			local criterion = nn.ParallelCriterion()

			for i=1,2 do
				subnet = nn.Sequential():
				add(nn.Linear(50,2)):
				add(nn.LogSoftMax())
				criterion:add(nn.ClassNLLCriterion())

				prl:add(subnet)
			end

			net:add(prl)

			net:forward(data)

			local total_err = criterion:forward(net.output, label)

			local seq_err = {}
			for i=1,#batch do
				local _row_ = {
					label[1][i],
					label[2][i]
				}
				net:forward(data[i])
				seq_err[#seq_err + 1] = criterion:forward(net.output, _row_)
			end
			seq_err = torch.Tensor(seq_err):mean()

			assert.near(seq_err, total_err, 10^-6, "Errors are not identical when running alone or in batch")
		end)
	end)

	local init_fn = function(idx)
		-- Load the libraries needed
		require 'torch'
		require 'lfs'
		if (string.match(lfs.currentdir(), "/specs$")) then
			lfs.chdir("..")
		end

		-- Include Dataframe lib
		dofile('init.lua')

		-- Go into specs so that the loading of CSV:s is the same as always
		lfs.chdir("specs")
	end
	describe([[
		Multiple targets with a the parallel_iterator for generating tensors
		#parallel_iterator
		Unfortunately these tests has issues when running via ./run_all:
		FATAL THREAD PANIC: (addjob) torch.ByteStorage has been already assigned a destructor
		We therefore need to run these tests separately
		#skip_all
	]], function()
		it("Regression targets #multreg", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets{
				class_args = Df_Tbl{
					batch_args = Df_Tbl{
						label_shape = "NxMx1"
					}
				}
			}
			torch.manualSeed(9823719)

			local iterator = a["/train"]:
				set_data_retriever(function(row)
					return torch.rand(10)
				end):
				set_label_retriever(function(row)
					return torch.rand(2)
				end):
				get_parallel_iterator{
					batch_size = 5,
					nthread = 2,
					init = init_fn}

			local sample = iterator()()
			local data = sample.input
			local label = sample.target

			require 'nn'
			local net = nn.Sequential()
			net:add(nn.Linear(10,50))

			local prl = nn.ConcatTable()
			local criterion = nn.ParallelCriterion()

			for i=1,2 do
				subnet = nn.Sequential():
				add(nn.Linear(50,1))
				criterion:add(nn.MSECriterion())

				prl:add(subnet)
			end

			net:add(prl)

			net:forward(data)

			local total_err = criterion:forward(net.output, label)

			local seq_err = {}
			for i=1,data:size(1) do
				local _row_ = {
					label[1][i],
					label[2][i]
				}
				net:forward(data[i])
				seq_err[#seq_err + 1] = criterion:forward(net.output, _row_)
			end
			seq_err = torch.Tensor(seq_err):mean()

			assert.near(seq_err, total_err, 10^-6, "Errors are not identical when running alone or in batch")
		end)

		it("Classification targets #multclss #1", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets{
				class_args = Df_Tbl{
					batch_args = Df_Tbl{
						label_shape = "NxM"
					}
				}
			}
			a:as_categorical("Gender")
			a:add_column{
				column_name = "Overweight",
				type = "integer"
			}
			a:update(
			function(row) return true end,
			function(row)
				if (row["Weight"] >= 25) then
					row["Overweight"] = 1
				else
					row["Overweight"] = 0
				end

				return row
			end)
			torch.manualSeed(823609)

			local iterator = a["/train"]:
				set_data_retriever(function(row)
					return torch.rand(10)
				end):
				set_label_retriever(Df_Array("Gender", "Overweight")):
				get_parallel_iterator{
					batch_size = 5,
					nthread = 2,
					init = init_fn}

			local sample = iterator()()
			local data = sample.input
			local label = sample.target

			require 'nn'
			local net = nn.Sequential()
			net:add(nn.Linear(10,50))

			local prl = nn.ConcatTable()
			local criterion = nn.ParallelCriterion()

			for i=1,2 do
				subnet = nn.Sequential():
				add(nn.Linear(50,2)):
				add(nn.LogSoftMax())
				criterion:add(nn.ClassNLLCriterion())

				prl:add(subnet)
			end

			net:add(prl)

			net:forward(data)

			local total_err = criterion:forward(net.output, label)

			local seq_err = {}
			for i=1,data:size(1) do
				local _row_ = {
					label[1][i],
					label[2][i]
				}
				net:forward(data[i])
				seq_err[#seq_err + 1] = criterion:forward(net.output, _row_)
			end
			seq_err = torch.Tensor(seq_err):mean()

			assert.near(seq_err, total_err, 10^-6, "Errors are not identical when running alone or in batch")
		end)
	end)

	describe([[
		Multiple targets with a the iterator for generating tensors
		#iterator
	]], function()
		it("Regression targets #multreg", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets{
				class_args = Df_Tbl{
					batch_args = Df_Tbl{
						label_shape = "NxMx1"
					}
				}
			}
			torch.manualSeed(9823719)

			local iterator = a["/train"]:
				set_data_retriever(function(row)
					return torch.rand(10)
				end):
				set_label_retriever(function(row)
					return torch.rand(2)
				end):
				get_iterator{
					batch_size = 5
				}

			local sample = iterator()()
			local data = sample.input
			local label = sample.target

			require 'nn'
			local net = nn.Sequential()
			net:add(nn.Linear(10,50))

			local prl = nn.ConcatTable()
			local criterion = nn.ParallelCriterion()

			for i=1,2 do
				subnet = nn.Sequential():
				add(nn.Linear(50,1))
				criterion:add(nn.MSECriterion())

				prl:add(subnet)
			end

			net:add(prl)

			net:forward(data)

			local total_err = criterion:forward(net.output, label)

			local seq_err = {}
			for i=1,data:size(1) do
				local _row_ = {
					label[1][i],
					label[2][i]
				}
				net:forward(data[i])
				seq_err[#seq_err + 1] = criterion:forward(net.output, _row_)
			end
			seq_err = torch.Tensor(seq_err):mean()

			assert.near(seq_err, total_err, 10^-6, "Errors are not identical when running alone or in batch")
		end)

		it("Classification targets #multclss", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets{
				class_args = Df_Tbl{
					batch_args = Df_Tbl{
						label_shape = "NxM"
					}
				}
			}
			a:as_categorical("Gender")
			a:add_column{
				column_name = "Overweight",
				type = "integer"
			}
			a:update(
			function(row) return true end,
			function(row)
				if (row["Weight"] >= 25) then
					row["Overweight"] = 1
				else
					row["Overweight"] = 0
				end

				return row
			end)
			torch.manualSeed(823609)

			local iterator = a["/train"]:
				set_data_retriever(function(row)
					return torch.rand(10)
				end):
				set_label_retriever(Df_Array("Gender", "Overweight")):
				get_iterator{
					batch_size = 5
				}

			local sample = iterator()()
			local data = sample.input
			local label = sample.target

			require 'nn'
			local net = nn.Sequential()
			net:add(nn.Linear(10,50))

			local prl = nn.ConcatTable()
			local criterion = nn.ParallelCriterion()

			for i=1,2 do
				subnet = nn.Sequential():
				add(nn.Linear(50,2)):
				add(nn.LogSoftMax())
				criterion:add(nn.ClassNLLCriterion())

				prl:add(subnet)
			end

			net:add(prl)

			net:forward(data)

			local total_err = criterion:forward(net.output, label)

			local seq_err = {}
			for i=1,data:size(1) do
				local _row_ = {
					label[1][i],
					label[2][i]
				}
				net:forward(data[i])
				seq_err[#seq_err + 1] = criterion:forward(net.output, _row_)
			end
			seq_err = torch.Tensor(seq_err):mean()

			assert.near(seq_err, total_err, 10^-6, "Errors are not identical when running alone or in batch")
		end)
	end)
end)
