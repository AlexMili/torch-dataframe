package = "torch-dataframe"
version = "1.7-0"
source = {
	url = "https://github.com/alexmili/torch-dataframe/archive/v1.7-0.tar.gz",
	dir = "torch-dataframe-1.7-0"
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
   type = "cmake",
   variables = {
      CMAKE_BUILD_TYPE="Release",
      LUA_PATH="$(LUADIR)",
      LUA_CPATH="$(LIBDIR)"
   }
}
