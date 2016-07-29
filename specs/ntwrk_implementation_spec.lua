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
	See if we can get a #network to play nicely with a the Batchframe generated tensors
]], function()
	it("A single input and a single target", function()
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

		assert.is_true(math.abs(seq_err - total_err) < 10^-6)
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

		assert.is_true(math.abs(seq_err - total_err) < 10^-6)
	end)

	it("Multiple input and #multiple regression targets", function()
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

		assert.is_true(math.abs(seq_err - total_err) < 10^-6)
	end)

	it("Multiple input and #multiple classification targets #mclss", function()
		a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()
		a:as_categorical("Gender")
		a:add_column("Overweight")
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

		local data, label =
			batch:to_tensor()

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

		assert.is_true(math.abs(seq_err - total_err) < 10^-6)
	end)

end)
