# API documentation for [Df_Dict](#__Df_Dict__)
- [Df_Dict.`__init`](#Df_Dict.__init)
- [Df_Dict.check_lengths()](#Df_Dict.check_lengths)
- [Df_Dict.set_keys](#Df_Dict.set_keys)
- [Df_Dict.[]](#Df_Dict.[])
- [Df_Dict.#](#Df_Dict.#)

<a name="__Df_Dict__">
## Df_Dict

The Df_Dict is a class that is used to wrap a dictionary table. A dictionary table
has a string name corresponding to each key and an array as values, i.e. it may
not contain any tables.

The following properties are available :
It is possible to access the Df_Dict's keys with the property `keys`.
- `Df_Dict.keys`: list of the key
- `Df_Dict.length`: content size for each key
<a name="Df_Dict.__init">
### Df_Dict.__init(table_data)

Create a Df_Dict object given a table

<a name="Df_Dict.check_lengths">
### Df_Dict.check_lengths()

Ensure every columns has the same size

_Return value_: boolean
<a name="Df_Dict.set_keys">
### Df_Dict.set_keys(table_data)

Replace all the keys by the given values

`table_data` must be a table and have the same item length as the keys

<a name="Df_Dict.[]">
### Df_Dict.[]

Returns the value with the given key
- _Single integer_: it returns the value corresponding
- _"$column_name"_: get a column by prepending the name with `$`, e.g. `"$a column name"`

_Return value_: Table or single value

<a name="Df_Dict.#">
### Df_Dict.#

Returns the number of elements