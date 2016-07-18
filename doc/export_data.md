
## Data save/export functions

<a name="Dataframe.to_csv">
### Dataframe.to_csv(self, path[, separator][, verbose])

Saves a Dataframe into a CSV using csvigo as backend

_Return value_: self (Dataframe)

```
({
   self      = Dataframe  -- 
   path      = string     -- path to file
  [separator = string]    -- separator (one character) [default=,]
  [verbose   = boolean]   -- verbose load [default=false]
})
```

<a name="Dataframe.to_tensor">
### Dataframe.to_tensor(self)

Convert the numeric section or specified columns of the dataset to a tensor

```
({
   self = Dataframe  -- 
})
```

_Return value_: (1) torch.tensor with self.n_rows rows and #columns, (2) exported column names


You can export selected columns using the columns argument:

```
({
   self    = Dataframe  -- 
   columns = Df_Array   -- The columns to export to labels
})
```

If a filename is provided the tensor will be saved (`torch.save`) to that file:

```
({
   self     = Dataframe  -- 
   filename = string     -- Filename for tensor.save()
  [columns  = Df_Array]  -- The columns to export to labels [default=false]
})
```
<a name="Dataframe.get">
### Dataframe.get(self, idx)

A funtion for *torchnet* compliance. It subsets a single index and returns the
`to_tensor` on that example.

```
({
   self = Dataframe  -- 
   idx  = number     -- 
})
```

_Return value_: (1) torch.tensor with 1 row and #numerical columns

