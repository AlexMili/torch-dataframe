News file for torch-dataframe
=============================

Version: development
--------------------
* Nothing for the moment

Version: 1.7
--------------------
* Added faster torch.Tensor functions to fill/stat functions for speed
* Added mutate function to Dataseries
* `__index__` access for Df_Array
* More complete documentation for Df_Array and specs
* Df_Dict elements can be accessed using `myDict[index]` or `myDict["$colname"]`
* Df_Dict `key` property available. It list the Df_Dict's keys
* Df_Dict `length` property available. It list by key, the length of its content
* Df_Dict `check_length()` checks if all elements have the same length
* Df_Dict `set_keys(table)` replaces every keys by the given table (must be the same size)
* More complete documentation for Df_Dict and specs
* More complete documentation for Df_Tbl and specs
* Internal methods `_infer_csvigo_schema()` and `_infer_data_schema()` renamed to `_infer_schema()`
* Type inference is now based on type frequences but if it encounter a single double/float in a integer column it will consider the column as double/float
* it is now possible to directly set a schema for a Dataframe without any checks with `set_schema()`. Use it wisely
* Possibility to init a Dataframe with a schema, a column order and a number of rows with internal method `_init_with_schema()`
* Added `bulk_load_csv()` method wich loads large CSVs files using threads but without checking missing values or data integrity. To use with caution. See #28
* Added `load_threadcsv()`
* Added the possiblity to create empty Dataseries
* Added Dataseries `load()` method to directly load a tensor or tds.Vec in memory without any check
* Added iris dataset in `/specs/data`
* New specs structure
* Fixed csv loading when no header and test case according to it
* Changed `assert_is_index` return value to `true` on success instead of `self`

Version: 1.6.1
--------------------
* The get_max_value/get_min_value use torch.max/min when no missing data is present in the column
* Fixed upgrade_frame bug
* Fixed bug with saving CSV-files when they contain boolean values

Version: 1.6
--------------------
* The data is now stored in Dataseries that handles all the manipulations, statistics, categoricals, etc internally. The data backend is either a tensor or a tds.Vec in order to better accomodate large datasets.
* The self.columns has been dropped and there is now only self.column_order that keeps track of column order.
* Most functions now use either tds.Hash or tds.Vec for returning values instead of regular tables.
* The data types are now more sophisticate with boolean, integer, long, double, and string. The first and the last are internally stored as `tds.Vec` while the remaining are in the form of torch tensors.
* Since conversions are more restricted with the new column types the is a boolean2tensor and boolean2categorical that help converting boolean columns into numerical.
* The `Dataframe.schema` property has been removed as it now resides in the series. The same information can be retrieved using `get_schema()`.
* There is now a custom busted assertion that can compare tensors, tds, and Dataseries.
* The csv data is entered using csvigo's `large` mode thus circumventing the memory limit for large csv's.
* The to_/from_categorical now always return a single value when a single value is entered.
* Add column now takes a Dataseries instead of a Df_Array
* Generalized the argcheck by adding string.split for `|` separated arguments
* Multiple minor bug-fixes with non-local variables

Version: 1.5
--------------------
* Added new subset and batch loading functionality (issue #22)
* Added metatable functionality (issue #18)
* The as_categorical can now receive levels, labels and exclusions (issue #23)
* The unique sorts the results before returning, thereby preventing the order to
  depend on any irrelevant changes in the original table order. _IMPORTANT_: This
  will affect the numbers corresponding to categoricals (part of issue #23)
* Added compatibility with the *torchnet* infrastructure via inheritance and a custom
  iterator that allows utilizing the internal permutation logistic (issue #24)
* The Batchframe can now have default data/load options allowing a simpler `to_tensor` call
* The Batchframe now supports common transformations that may be required for the label
  via the `label_shape`. See the ntwrk_implementation_spec file that contains basic examples.
* Added so that `__init` parameters can be passed along the subset line primary for
  allowing default Batchframe load/data arguments
* Insert now takes an index argument allowing insertion of rows. Backward compatibility retained.
* Added append that does the same as index previously did, i.e. adding a row at the bottom of the table
* Added rbind (row-bind) as an append alias
* Added cbind (column-bind)
* Added wide2long for converting wide datasets to long
* Added a version function
* Added upgrade_frame that handles upgrades from previous Dataframe versions
* The statistics can now return dataframe that is also the default (allows nicer printing)
* The add_column can now take a position argument and updates the schema + columns
* The init-constructor for with a table argument now also accepts column_order argument
* The column order can now be specified using the `pos_column_order` and manipulated
  using `swap_column_order`.
* The tostring now has a more advanced printing that aims at total table width
  instead of just making sure that certain columns didn't end up too wide.
  The previous Dataframe.print default arguments for printing have been moved to
  Dataframe.tostring_defaults
* The helper classes Df_Array, Df_Dict and Df_Tbl now have a metatable `__len__` option
* The as_batchframe has been renamed to frame_type that defaults to current frame type
* The set now changes all matching values instead of only the first occurrence
* Fixed bug with outputting categorical columns
* Fixed bug related to boolean columns. *Note*: columns that are created using the
  csv-option are currently not being converted to boolean columns but will remain
  as strings with 'true' and 'false'

Version: 1.1
-----------
* Converted all functions to use argcheck
* API-changes due to above

Version_ 1.0
-----------
* Full test suite
* Load batch support
* Categorical data support
