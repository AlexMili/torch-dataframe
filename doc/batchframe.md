
## Batchframe

The Batchframe is returned by the `Dataframe.get_batch` and contains only a subset
of the original Dataframe's rows. It's main function is to override the `to_tensor`
in order to provie a function that can split the tensor into data and labels, i.e.
the classical set-up used by machine learning algorithms. As the Batchframe is
a completely separate entity you can easily serialize it and send it to a separate
process that then will

<a name="Batchframe.__init">
### Batchframe.__init(self[, data][, label])

Calls the parent init and then adds `batchframe_defaults` table. Se the
set_load and set_data methods

```
({
   self  = Batchframe          -- 
  [data  = function|Df_Array]  -- The data loading procedure/columns
  [label = function|Df_Array]  -- The label loading procedure/columns
})
```

<a name="Batchframe.set_data_retriever">
### Batchframe.set_data_retriever(self[, data])

Sets the self.batchframe_defaults.data to either a function for loading data or
a set of columns that should be used in the to_tensor functions.

```
({
   self = Batchframe          -- 
  [data = function|Df_Array]  -- The data loading procedure/columns. If omitted the retriever will be erased
})
```

_Return value_: self
<a name="Batchframe.get_data_retriever">
### Batchframe.get_data_retriever(self)

Returns the self.batchframe_defaults.data for loading data or
a set of columns that should be used in the to_tensor functions.

```
({
   self = Batchframe  -- 
})
```

_Return value_: function
<a name="Batchframe.set_label_retriever">
### Batchframe.set_label_retriever(self[, label])

Sets the self.batchframe_defaults.data to either a function for loading data or
a set of columns that should be used in the to_tensor functions.

```
({
   self  = Batchframe          -- 
  [label = function|Df_Array]  -- The label loading procedure/columns. If omitted the retriever will be erased
})
```

_Return value_: self
<a name="Batchframe.get_label_retriever">
### Batchframe.get_label_retriever(self)

Returns the self.batchframe_defaults.label for loading label or
a set of columns that should be used in the to_tensor functions.

```
({
   self = Batchframe  -- 
})
```

_Return value_: function
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
   label_columns = Df_Array   -- The columns that are to be the label. If omitted defaults to all numerical.
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

*Note*: you can use the defaults if you want to avoid providing the loader
each time. If there is only a retriever function provided and no label default
is present then the we will assume that the labels are the default numerical
columns while the retriever is for the data.

```
({
   self      = Dataframe           -- 
  [retriever = function|Df_Array]  -- If you have only provided one of the defaults you can add the other retriever here
})
```

