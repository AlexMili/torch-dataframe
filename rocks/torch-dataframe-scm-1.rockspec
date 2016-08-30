package = "torch-dataframe"
version = "scm-1"
source = {
		url = "https://github.com/alexmili/torch-dataframe/archive/develop.tar.gz",
		dir = "torch-dataframe-develop"
}
description = {
		summary = "A Dataframe class for Torch",
		detailed = [[
			 Dataframe is a Torch7 class to load and manipulate
			 Kaggle-style CSVs inspired from R's and pandas' Dataframes.
			 Compatible with torchnet.
		]],
		homepage = "https://github.com/alexmili/torch-dataframe",
		license = "MIT/X11",
		maintainer = "AlexMili"
}
dependencies = {
		"lua >= 5.1",
		"torch >= 7.0",
		"argcheck >= 2.0",
		"luafilesystem >= 1.6.3",
		"paths",
		"torchnet >= 1.0",
		"threads >= 1.0",
		"tds",
		"nn"
}
build = {
	type = 'builtin',
	modules = {
			["Dataframe.init"] = 'init.lua',

			["Dataframe.utils.loader"] = 'utils/loader.lua',
			["Dataframe.utils.utils"] = 'utils/utils.lua',
			["Dataframe.argcheck"] = 'argcheck.lua',

			["Dataframe.main"] = 'main.lua',
			["Dataframe.extensions.metatable"] = 'extensions/metatable.lua',
			["Dataframe.extensions.categorical"] = 'extensions/categorical.lua',
			["Dataframe.extensions.column"] = 'extensions/column.lua',
			["Dataframe.extensions.row"] = 'extensions/row.lua',
			["Dataframe.extensions.subsets_and_batches"] = 'extensions/subsets_and_batches.lua',
			["Dataframe.extensions.load_data"] = 'extensions/load_data.lua',
			["Dataframe.extensions.missing_data"] = 'extensions/missing_data.lua',
			["Dataframe.extensions.output"] = 'extensions/output.lua',
			["Dataframe.extensions.export_data"] = 'extensions/export_data.lua',
			["Dataframe.extensions.select_set_update"] = 'extensions/select_set_update.lua',
			["Dataframe.extensions.statistics"] = 'extensions/statistics.lua',

			["Dataframe.sub_classes.01_subset"] = 'sub_classes/01_subset.lua',
			["Dataframe.sub_classes.10_batchframe"] = 'sub_classes/10_batchframe.lua',
			["Dataframe.sub_classes.subset_extensions.samplers"] = 'sub_classes/subset_extensions/samplers.lua',

			["Dataframe.dataseries.init"] = 'dataseries/init.lua',
			["Dataframe.dataseries.categorical"] = 'dataseries/categorical.lua',
			["Dataframe.dataseries.export"] = 'dataseries/export.lua',
			["Dataframe.dataseries.metatable"] = 'dataseries/metatable.lua',
			["Dataframe.dataseries.sngl_elmnt_ops"] = 'dataseries/sngl_elmnt_ops.lua',
			["Dataframe.dataseries.statistics"] = 'dataseries/statistics.lua',

			["Dataframe.helper_classes.10_iterator"] = 'helper_classes/10_iterator.lua',
			["Dataframe.helper_classes.11_paralleliterator"] = 'helper_classes/11_paralleliterator.lua',
			["Dataframe.helper_classes.20_tbl"] = 'helper_classes/20_tbl.lua',
			["Dataframe.helper_classes.21_dict"] = 'helper_classes/21_dict.lua',
			["Dataframe.helper_classes.22_array"] = 'helper_classes/22_array.lua'
	}
}
