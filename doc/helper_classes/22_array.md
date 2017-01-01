# API documentation for [Df_Array](#__Df_Array__)
- [Df_Array.`__init`](#Df_Array.__init)
- [Df_Array.[]](#Df_Array.[])
- [Df_Array.#](#Df_Array.#)

<a name="__Df_Array__">
## Df_Array

The Df_Array is a class that is used to wrap an array table. An array table
has no key names, it only uses numbers for indexing and each element has to be
an atomic element, i.e. it may not contain any tables.

<a name="Df_Array.__init">
### Df_Array.__init(...)

Df_Array accepts 5 type of init values :
- single value (string, integer, float, etc)
- table
- torch.*Tensor
- Dataseries
- arguments list (e.g. Df_Array(1,2,3,4,5) )

<a name="Df_Array.[]">
### Df_Array.[]

Returns the value at the given index

<a name="Df_Array.#">
### Df_Array.#

Returns the number of elements