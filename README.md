[![Licence MIT](https://img.shields.io/badge/Licence-MIT-green.svg)](https://github.com/AlexMili/torch-dataframe/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/AlexMili/torch-dataframe.svg?branch=master)](https://travis-ci.org/AlexMili/torch-dataframe)

# Dataframe
Dataframe is a [Torch7][torch] class to load and manipulate tabular
data (e.g. Kaggle-style CSVs) inspired from [R's][R] and
[pandas'][pandas] [data frames][df].

[torch]: http://torch.ch/
[R]: https://cran.r-project.org/
[pandas]: http://pandas.pydata.org/
[df]: https://github.com/mobileink/data.frame/wiki/What-is-a-Data-Frame%3F

As of release 1.5 it fully supports the [torchnet][thnet] data structure. It also has custom iterators to convenient integration with torchnet's engines, see the [mnist example][thnet_mnist]. As of release 1.6 it has changed the internal storage to tensor

[thnet]: https://github.com/torchnet/torchnet
[thnet_mnist]: https://github.com/AlexMili/torch-dataframe/blob/master/examples/mnist_example.lua
[NEWS]: https://github.com/AlexMili/torch-dataframe/blob/master/NEWS.md

For a more detailed look at the changes between the versions have a look at the  [NEWS][NEWS] file.

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Requirements](#requirements)
- [Installation](#installation)
- [Changelog](#changelog)
- [Usage](#usage)
	- [Named arguments](#named-arguments)
	- [Load data](#load-data)
	- [Data inspection](#data-inspection)
	- [Manipulate](#manipulate)
	- [Categorical variables](#categorical-variables)
	- [Subsetting](#subsetting)
	- [Exporting](#exporting)
	- [Batch loading](#batch-loading)
- [Tests](#tests)
- [Documentation](#documentation)
- [Contributing](#contributing)

<!-- /TOC -->

## Requirements
- [torch][torch]
- [torchnet][thnet]
- [csvigo][csvigo]
- [luafilesystem][lfs]
- [paths][paths]
- [tds][tds]
- [threads][threads]
- [argcheck][argcheck]

[csvigo]: https://github.com/clementfarabet/lua---csv
[lfs]: https://keplerproject.github.io/luafilesystem/
[paths]: https://github.com/torch/paths
[tds]: https://github.com/torch/tds
[threads]: https://github.com/torch/threads
[argcheck]: https://github.com/torch/argcheck

## Installation
You can clone this repository or directly install it through `luarocks`:

```bash
git clone https://github.com/AlexMili/torch-dataframe
cd torch-dataframe
luarocks make rocks/torch-dataframe-scm-1.rockspec
```

the same in one line :

```bash
luarocks install torch-dataframe scm-1
```

or

```bash
luarocks install torch-dataframe
```

## Changelog

Version: 1.6.1
--------------------
* The get_max_value/get_min_value use torch.max/min when no missing data is present in the column
* Fixed upgrade_frame bug
* Fixed bug with saving CSV-files when they contain boolean values

See `NEWS.md` file for previous changes.

## Usage

### Named arguments

The Dataframe relies on [argcheck][argcheck] for parsing arguments. This means that you can used named parameters using the `function{arg_name=value}` syntax. Named arguments are supported by all functions except the constructor and is in certain functions mandatory in order to avoid ambiguity.

The argcheck package also works as the API documentation. It checks arguments and if you happen to provide the function with invalid arguments it will automatically output the function documentation.

__Important__: Due to limitations in the Lua language the package uses helper classes for separating regular table arguments from tables passed into as arguments. The three classes are:

- *Df_Array* - contains only values and no keys
- *Df_Dict* - a dictionary table that has named keys that map to all values
- *Df_Tbl* - a raw table wrapper that does a shallow argument copy

### Load data

Initiate the object:

```lua
require 'Dataframe'
df = Dataframe()
```

Load CSV file:

```lua
df:load_csv{path='./data/training.csv', header=true}
```

Load from table:

```lua
df:load_table{data=Df_Dict{firstColumn={1,2,3},
                           secondColumn={4,5,6}}}
```

You can also instantiate the object with a csv-filename or a table by passing
the table or filename as an argument:

```lua
require 'Dataframe'
df = Dataframe('./data/training.csv')
```

### Data inspection

You can discover your dataset with the following functions:

```lua
-- you can either view the data as a plain text output or itorch html table
df:output() -- prints html if in itorch otherwise prints plain table
df:output{html=true} -- forces html output

df:show() -- prints the head + tail of the table

-- You can also directly call print() on the object
-- and it will print the ascii-table
print(df)
```

General dataset information can be found using:

```lua
df:shape() -- print {rows=3, cols=3}
#df -- gets the number of rows
df:size() -- returns a tensor with the size rows, columns
df.column_order -- table of columns names
df:count_na() -- print all the missing values by column name
```

If you want to inspect random elements you can use the `get_random()`:

```lua
df:get_random(10):output()
```

### Manipulate

You can manipulate it:

```lua
df:insert(Df_Dict({['first_column']={7,8,9},['second_column']={10,11,12}}))
df:remove_index(3) -- remove line 3 of the entire dataset

df:has_column('x') -- return true if the column exist
df:get_column('y') -- return column x as table
df["$y"] -- alias for get_column

df:add_column('z', 0) -- Add column with default value 0 at the end (right side of the table)
df:add_column('first_column', 1, 2) -- Add column with default value 2 at the beginning (left side of the table)
df:drop('x') -- delete column
df:rename_column('x', 'y') -- rename column 'x' in 'y'

df:reset_column('my_col', 0) -- reset the given column with 0
df:fill_na('x', 0) -- replace missing values in 'x' column with 0
df:fill_all_na(0) -- replace all missing values with the value 0

df:unique('col_name') -- return table with unique values of the given column
df:unique('col_name', true) -- return table with unique values of the given column as keys

df:where('column_name','my_value') -- find the first row where the column has the given value

-- Customly update all rows filling the condition defined in first lambda
df:update(function(row) row['column'] == 'test' end,
          function(row) row['other_column'] = 'new_value' return row end)
```

### Categorical variables

You can define [categorical variables][catvar] that will be treated internally as numbers ranging from 1 to n levels while displayed as strings. The numeric representation is retained when exporting `to_tensor` allowing a simpler understanding of a classifier's output:

[catvar]: https://en.wikipedia.org/wiki/Categorical_variable

```lua
df:as_categorical('my string column') -- converts a column to categorical
df:get_cat_keys('my string column') -- retreives the keys used to converts
df:to_categorical(Df_Array({1,2,1}), 'my string column') -- converts numbers to the categories
```

### Subsetting

You can subset your data using:

```lua
df:head(20) -- print 20 first elements (10 by default)
df:tail(5) -- print 5 last elements (10 by default)
df:show() -- print 10 first and 10 last elements

df[13] -- returns a table with the row values
df["13:17"] -- returns a Dataframe with values in that span
df["13:"] -- returns a Dataframe with values starting from index 13
df[Df_Array(1,3,4)] -- returns a Dataframe with values index 1,3 and 4
```

### Exporting

Finally, you can save your dataset to tensor (only numerical/categorical columns will be taken):

```lua
df:to_tensor{filename = './data/train.th7'} -- saves data
data = df:to_tensor{columns = Df_Array('first_column', 'my string column')} -- Converts the two columns into tensor
```

or to CSV:

```lua
df:to_csv('data.csv')
```

### Batch loading

The Dataframe provides a built-in system for handling batch loading. It also has an extensive set of samplers that you can use. See API docs for more on which that are available.

The gist of it is:
- The main Dataframe is initialized for batch loading via calling the `create_subsets`. This creates random subsets that have their own samplers. The default is a train 70%, validate 20%, and a test 10% split in the data but you can choose any split and any names.
- Each subset is a separate dataframe subclass that has two columns, (1) indexes with the corresponding index in the main dataframe, (2) labels that some of the samplers require.
- When you want to retrieve a batch from a subset you call the subset using `my_dataframe:get_subset('train'):get_batch(30)` or `my_dataframe['/train']:get_batch(30)`.
- The batch returned is also a subclass that has a custom `to_tensor` function that returns the data and corresponding label tensors. You can provide custom functions that will get the full row as an argument allowing you to use e.g. a filename that permits load an external resource.

A simple example:

```lua
local df = Dataframe('my_csv'):
	create_subsets()

local batch = df["/train"]:get_batch(10)
local data, label = batch:to_tensor{
	load_data_fn = my_image_loader
}
```

As of version 1.5 you may also want to consider using th iterators that integrate with the torchnet infrastructure. Take a look at the iterator API and the mnist example for how an implementation may look.

## Tests

The package contains an extensive test suite and tries to apply a [behavior driven development][bhdrv] approach. All features should be accompanied by a test-case.

[bhdrv]: https://en.wikipedia.org/wiki/Behavior-driven_development

To launch the tests you need to install ```busted``` (See:
[Olivine-Labs/busted][busted]) via `luarocks`:

[busted]: http://olivinelabs.com/busted/

```bash
luarocks install busted
```

then you can run all tests via command line:

```bash
cd specs/
./run_all.sh
```

## Documentation

The package relies on self-documenting functions via the [argcheck][argcheck] package that reside in the [doc][df_doc] folder. The [GitHub Wiki][df_wiki] is intended for more extensive in detail documentation.

[df_doc]: https://github.com/AlexMili/torch-dataframe/tree/master/doc
[df_wiki]: https://github.com/AlexMili/torch-dataframe/wiki

To generate the documentation please run:

```bash
th doc.lua > /dev/null
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for further details.

[df_issues]: https://github.com/AlexMili/torch-dataframe/issues
[df_pr]: https://github.com/AlexMili/torch-dataframe/pulls
[df_specs]: https://github.com/AlexMili/torch-dataframe/tree/readme/specs
