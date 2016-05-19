
## Data save/export functions

<a name="Dataframe.to_csv">
### Dataframe.to_csv(self, path[, separator][, verbose])

```
({
   self      = Dataframe  -- 
   path      = string     -- path to file
  [separator = string]    -- separator (one character) [default=,]
  [verbose   = boolean]   -- verbose load [default=false]
})
```

Saves a Dataframe into a CSV using csvigo as backend

_Return value_: void
<a name="Dataframe.to_tensor">
### Dataframe.to_tensor(self)

```
({
   self = Dataframe  -- 
})
```

Convert the numeric section or specified columns of the dataset to a tensor

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
