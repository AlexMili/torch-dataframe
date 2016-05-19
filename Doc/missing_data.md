
## Missing data functions

<a name="Dataframe.count_na">
### Dataframe.count_na(self)

```
({
   self = Dataframe  -- 
})
```

Count missing values in dataset

_Return value_: table containing missing values per column
You can manually choose the columns by providing a Df_Array

```
({
   self    = Dataframe  -- 
   columns = Df_Array   -- The columns to count
})
```

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

_Return value_: void
<a name="Dataframe.fill_na">
### Dataframe.fill_na(self[, default_value])

Replace missing value in all columns

```
({
   self          = Dataframe               -- 
  [default_value = number|string|boolean]  -- The default missing value [default=0]
})
```

_Return value_: void
