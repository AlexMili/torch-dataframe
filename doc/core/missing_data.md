# API documentation for [missing data functions](#__Missing data functions__)
- [Dataframe.count_na](#Dataframe.count_na)
- [Dataframe.fill_na](#	Dataframe.fill_na)
- [Dataframe.fill_na](#Dataframe.fill_na)

<a name="__Missing data functions__">
## Missing data functions

<a name="Dataframe.count_na">
### Dataframe.count_na(self[, columns][, as_dataframe])

Count missing values in dataset

```
({
   self         = Dataframe  -- 
  [columns      = Df_Array]  -- The columns to count
  [as_dataframe = boolean]   -- Return a dataframe [default=true]
})
```

_Return value_: Dataframe or table containing missing values per column, total na
If you only want to count a single column

```
({
   self   = Dataframe  -- 
   column = string     -- The column to count
})
```

_Return value_: single integer
	<a name="Dataframe.fill_na">
### Dataframe.fill_na(self, column_name[, default_value])

Replace missing value in a specific column

```
({
   self          = Dataframe               -- 
   column_name   = string                  -- The column to fill
  [default_value = number|string|boolean]  -- The default missing value [default=0]
})
```

_Return value_: self
<a name="Dataframe.fill_na">
### Dataframe.fill_na(self[, default_value])

Replace missing value in all columns

```
({
   self          = Dataframe               -- 
  [default_value = number|string|boolean]  -- The default missing value [default=0]
})
```

_Return value_: self