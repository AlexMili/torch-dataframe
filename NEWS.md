News file for torch-dataframe
=============================

Version: development
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
* The tostring now has a more advanced printing that aims at total table width
  instead of just making sure that certain columns didn't end up too wide.
  The previous Dataframe.print default arguments for printing have been moved to
  Dataframe.tostring_defaults
* The helper classes Df_Array, Df_Dict and Df_Tbl now have a metatable `__len__` option
* The as_batchframe has been renamed to frame_type that defaults to current frame type
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
