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
or you can copy ```Dataframe.lua``` into your project directory and include it locally.

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
df.dataset -- the entire dataset
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

You can print it :
```lua
-- The following three functions supports itorch html display
df:head(20) -- print 20 first elements (10 by default)
df:tail(5) -- print 5 last elements (10 by default)
df:show() -- print 10 first and 10 last elements
```

Finally, you can save your dataset to tensor (only numerical columns will be taken):
```lua
df:to_tensor('./data/train.th7')
```

or to CSV :
```lua
df:to_csv('data.csv')
```
