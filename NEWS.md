News file for torch-dataframe
=============================

Version: development
--------------------
* Added metatable functionality (issue #18)
* Changed insert to insert with an index
* Added append that does the same as index previously did
* Added rbind as an append alias
* Added cbind
* Fixed bug with outputting categorical columns
* Added a version function
* The statistics can now return dataframe that is also the default (allows nicer printing)
* The add_column can now take a position argument
* The init with a table can now also accept column_order argument
* Added has_batch and get_batch
* Added wide2long for converting wide datasets to long

Version: 1.1
-----------
* Converted all functions to use argcheck
* API-changes due to above

Version_ 1.0
-----------
* Full test suite
* Load batch support
* Categorical data support
