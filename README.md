# Dataframe
Dataframe is a Torch7 class to load and manipulate Kaggle-style CSVs inspired from R and pandas Dataframes.

## Requirements
- torch
- csvigo

## Usage
First you need to copy `Dataframe.lua` in your current working directory.

Initiate the object :
```lua
require 'Dataframe'
df = Dataframe()
```

Load CSV file :
```lua
df:load_csv{path='./data/training.csv', header=true}
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
df:drop('image') -- delete column
df:rename_column('x', 'y')
df:add_column('z', 0)
df:get_column('x')
df:fill_na('x', 0) -- replace missing values in 'x' column with 0
df:fill_all_na(0) -- replace all missing values with the value 0
```

Finally, you can save your dataset to tensor (only numerical columns will be taken):
```lua
df:to_tensor('./data/train.th7')
```