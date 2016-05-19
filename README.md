[![Licence MIT](https://img.shields.io/badge/Licence-MIT-green.svg)](https://github.com/AlexMili/torch-dataframe/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/AlexMili/torch-dataframe.svg?branch=master)](https://travis-ci.org/AlexMili/torch-dataframe)

# Dataframe
Dataframe is a [Torch7]((http://torch.ch/)) class to load and manipulate tabular data (e.g. Kaggle-style CSVs)
inspired from [R's](https://cran.r-project.org/) and [pandas'](http://pandas.pydata.org/)
[data frames](https://github.com/mobileink/data.frame/wiki/What-is-a-Data-Frame%3F).

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
	- [Named arguments](#named-arguments)
	- [Load data](#load-data)
	- [Data inspection](#data-inspection)
	- [Manipulate](#manipulate)
	- [Categorical variables](#categorical-variables)
	- [Subsetting](#subsetting)
	- [Exporting](#exporting)
- [Tests](#tests)
- [Documentation](#documentation)
- [Contributing](#contributing)

<!-- /TOC -->

## Requirements
- [torch](http://torch.ch/)
- [csvigo](https://github.com/clementfarabet/lua---csv)
- [luafilesystem](https://keplerproject.github.io/luafilesystem/)

## Installation
You can clone this repository or directly install it through luarocks:

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

## Usage

### Named arguments

The Dataframe relies on [argcheck](https://github.com/torch/argcheck) for parsing
arguments. This means that you can used named parameters using the `function{arg_name=value}`
syntax. Named arguments are supported by all functions except the constructor and
is in certain functions mandatory in order to avoid ambiguity.

The argcheck package also works as the API documentation. It checks arguments
and if you happen to provide the function with invalid arguments it will automatically
output the function documentation.

__Important__: Due to limitations in the Lua language the package uses helper classes
for separating regular table arguments from tables passed into as arguments. The
three classes are:

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
df:load_table{data={['firstColumn']={1,2,3},['secondColumn']={4,5,6}}}
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
df:to_html() -- forces html output
print(df) -- prints a plain table using the tostring() output

df:show() -- prints the head + tail of the table
```

General dataset information can be found using:

```lua
df:shape() -- print {rows=3, cols=3}
df.columns -- table of columns names
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

df:drop('image') -- delete column
df:rename_column('x', 'y') -- rename column 'x' in 'y'
df:add_column('z', 0) -- Add column with default value 0
df:get_column('x') -- return column x as table
df:has_column('x') -- return true if the column exist
df:remove_index(3) -- remove line 3 of the entire dataset

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

You can define [categorical variables](https://en.wikipedia.org/wiki/Categorical_variable)
that will be treated internally as numbers ranging from 1 to n levels
while displayed as strings. The numeric representation is retained when exporting
`to_tensor` allowing a simpler understanding of a classifier's output:

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

## Tests

The package contains an extensive test suite and tries to apply a [behavior driven
development](https://en.wikipedia.org/wiki/Behavior-driven_development) approach.
All features should be accompanied by a test-case.

To launch the tests you need to install ```busted``` (See: [Olivine-Labs/busted](http://olivinelabs.com/busted/)) via luarocks:

```bash
luarocks install busted
```

then you can run all tests via command line:

```bash
cd specs/
./run_all.sh
```

## Documentation

The package relies on self-documenting functions via the [argcheck](https://github.com/torch/argcheck) package and [GitHub Wiki](https://github.com/AlexMili/torch-dataframe/wiki) for more extensive documentation.

To generate the documentation please run :
```bash
th doc.lua > /dev/null
```

## Contributing

Feel free to report a bug, suggest enhancements or submit new cool features using [Issues](https://github.com/AlexMili/torch-dataframe/issues) or directly send us a [Pull Request](https://github.com/AlexMili/torch-dataframe/pulls) :).
Don't forget to test your code and generate the doc before submitting. You can find how we implemented our tests in the [specs directory](https://github.com/AlexMili/torch-dataframe/tree/readme/specs). See "Behavior Driven Development" for more details on this technique.
