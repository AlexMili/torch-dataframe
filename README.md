[![Licence MIT](https://img.shields.io/badge/Licence-MIT-green.svg)](https://github.com/AlexMili/torch-dataframe/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/AlexMili/torch-dataframe.svg?branch=master)](https://travis-ci.org/AlexMili/torch-dataframe)
# Dataframe
Dataframe is a Torch7 class to load and manipulate Kaggle-style CSVs inspired from R and pandas Dataframes.

## Requirements
- torch
- csvigo

## Installation
You can clone this repository or directly install it throught luarocks:
```
git clone https://github.com/AlexMili/torch-dataframe
cd torch-dataframe
luarocks make
```
or
```
luarocks install torch-dataframe
```

## Tests
To launch the tests you need to install ```busted``` (See : [Olivine-Labs/busted](https://github.com/Olivine-Labs/busted)) via luarocks :
```bash
luarocks install busted
```
then you can run all tests via command line :
```bash
cd specs/
./run_all.sh
```

## Usage
Initiate the object :
```lua
require 'Dataframe'
df = Dataframe()
```

Load CSV file :
```lua
df:load_csv{path='./data/training.csv', header=true}
```

Load from table :
```lua
df:load_table{data={['firstColumn']={1,2,3},['secondColumn']={4,5,6}}}
```

You can discover your dataset with the following functions :
```lua
df:shape() -- print {rows=3, cols=3}
df:count_na() -- print all the missing values by column name

df.columns -- table of columns names
print(df) -- the entire datset
```

You can manipulate it :
```lua
df:insert({['first_column']={7,8,9},['second_column']={10,11,12}})

df:drop('image') -- delete column
df:rename_column('x', 'y') -- rename column 'x' in 'y'
df:add_column('z', 0) -- Add column with default value 0
df:get_column('x') -- return column x as table
df:has_column('x') -- return true if the column exist
df::remove_index(3) -- remove line 3 of the entire dataset

df:reset_column('my_col', 0) -- reset the given column with 0
df:fill_na('x', 0) -- replace missing values in 'x' column with 0
df:fill_all_na(0) -- replace all missing values with the value 0

df:unique('col_name') -- return table with unique values of the given column
df:unique('col_name', true) -- return table with unique values of the given column as keys

df:where('column_name','my_value') -- find the first row where the column has the given value

-- Customly update all rows filling the condition defined in first lambda
df:update(function(row) row['column'] == 'test' end, function(row) row['other_column'] = 'new_value' return row end)
```

You can define categorical variables that will be treated internally as numbers
while displayed as strings. This numeric representation is retained when exporting
`to_tensor` allowing a simpler understanding of a classifier's output:
```lua
df:as_categorical('my string column') -- converts a column to categorical
df:get_cat_keys('my string column') -- retreives the keys used to converts
df:to_categorical({1,2,1}, 'my string column') -- converts numbers to the categories
```

You can subset and inspect your data using:
```lua
df:head(20) -- print 20 first elements (10 by default)
df:tail(5) -- print 5 last elements (10 by default)
df:show() -- print 10 first and 10 last elements

-- you can either view the data as a plain text output or itorch html table
df:output() -- prints html if in itorch otherwise prints plain table
df:to_html() -- forces html output
print(df) -- prints a plain table using the tostring() output
```

If you want to view

Finally, you can save your dataset to tensor (only numerical/categorical columns will be taken):
```lua
df:to_tensor{filename = './data/train.th7'} -- saves data
data = df:to_tensor{columns = {'first_column', 'my string column'}} -- Converts the two columns into tensor
```

or to CSV :
```lua
df:to_csv('data.csv')
```
