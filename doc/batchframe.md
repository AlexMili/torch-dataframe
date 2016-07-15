
## Batchframe

The Batchframe is returned by the `Dataframe.get_batch` and contains only a subset
of the original Dataframe's rows. It's main function is to override the `to_tensor`
in order to provie a function that can split the tensor into data and labels, i.e.
the classical set-up used by machine learning algorithms. As the Batchframe is
a completely separate entity you can easily serialize it and send it to a separate
process that then will

<a name="Batchframe.to_tensor">
### Batchframe.to_tensor(self, data_columns, label_columns)

Converts the data into tensors that can easily be used for input. Prepares one
data tensor and one label tensor. The funtion is intended for use together
with the `get_batch()`. The function allows for:

- Both data and labels reside within the dataframe
- The data is located outside and will be loaded using a helper function
- The labels are located outside and will be loaded using a helper function
- Both data and labels are located outside and will be loaded using helper functions

_Return value_: data (tensor), label (tensor), column names (lua table)

```
({
   self          = Dataframe  -- 
   data_columns  = Df_Array   -- The columns that are to be the data
   label_columns = Df_Array   -- The columns that are to be the label
})
```


```
({
   self          = Dataframe  -- 
   load_data_fn  = function   -- Receives a row and returns a tensor assumed to be the data
  [label_columns = Df_Array]  -- The columns that are to be the label. If omitted defaults to all numerical. [default=false]
})
```

*Note*: the label function setup does not return any label names

```
({
   self          = Dataframe  -- 
   data_columns  = Df_Array   -- Receives a row and returns a tensor assumed to be the data
   load_label_fn = function   -- The columns that are to be the label.
})
```

*Note*: the two function setup does not return any label names

```
({
   self          = Dataframe  -- 
   load_data_fn  = function   -- Receives a row and returns a tensor assumed to be the data
   load_label_fn = function   -- Receives a row and returns a tensor assumed to be the labels
})
```

