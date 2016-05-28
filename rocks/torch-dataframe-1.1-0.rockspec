package = "torch-dataframe"
 version = "1.1-0"
 source = {
		url = "https://github.com/alexmili/torch-dataframe/archive/v1.1-0.tar.gz",
		dir = "torch-dataframe-1.1-0"
 }
 description = {
		summary = "A Dataframe class for Torch",
		detailed = [[
			 Dataframe is a Torch7 class to load and manipulate
			 Kaggle-style CSVs inspired from R's and pandas' Dataframes.
		]],
		homepage = "https://github.com/alexmili/torch-dataframe",
		license = "MIT/X11",
		maintainer = "AlexMili"
 }
 dependencies = {
		"lua ~> 5.1",
		"torch >= 7.0",
		"argcheck >= 2.0",
		"luafilesystem >= 1.6.3"
 }
 build = {
	type = 'builtin',
	modules = {
			["Dataframe.init"] = 'init.lua',
			["Dataframe.utils"] = 'utils.lua',
			["Dataframe.argcheck"] = 'argcheck.lua',
			["Dataframe.main"] = 'main.lua',
			["Dataframe.Extensions.categorical"] = 'Extensions/categorical.lua',
			["Dataframe.Extensions.column"] = 'Extensions/column.lua',
			["Dataframe.Extensions.load_batch"] = 'Extensions/load_batch.lua',
			["Dataframe.Extensions.load_data"] = 'Extensions/load_data.lua',
			["Dataframe.Extensions.missing_data"] = 'Extensions/missing_data.lua',
			["Dataframe.Extensions.output"] = 'Extensions/output.lua',
			["Dataframe.Extensions.export_data"] = 'Extensions/export_data.lua',
			["Dataframe.Extensions.select_set_update"] = 'Extensions/select_set_update.lua',
			["Dataframe.Extensions.statistics"] = 'Extensions/statistics.lua',
			["Dataframe.helper_classes.array"] = 'helper_classes/array.lua',
			["Dataframe.helper_classes.dict"] = 'helper_classes/dict.lua',
			["Dataframe.helper_classes.tbl"] = 'helper_classes/tbl.lua'
	}
 }
