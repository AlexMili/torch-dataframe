require 'torch'

-- Make sure that directory structure is always the same
require('lfs')
if (string.match(lfs.currentdir(), "/tests$")) then
  lfs.chdir("..")
end
paths.dofile('init.lua')

-- Go into tests so that the loading of CSV:s is the same as always
lfs.chdir("tests")

-- A quick way to get a feeling for how the __tostring method works
local a = Dataframe()
a:load_csv{path = "simple_short.csv",
           verbose = false}
print("-- Simple table --")
print(a)

print("-- Advanced table --")
a:load_csv{path = "advanced_short.csv",
           verbose = false}
print(a)

print(" - check digits")

a:output{digits = 2}

print("-- Long table --")
a:load_csv{path = "realistic_29_row_data.csv",
           verbose = false}
a.print.no_rows = 5
print(a)

a.print.no_rows = 20
print(a)

a:as_categorical('Gender')
a.print.no_rows = 5
print(a)

females = a:where('Gender', 'Female')
print(females)

math.randomseed(10)
left_right = {}
for i = 1,a:shape()["rows"] do
  if (math.random() > 0.5) then
    table.insert(left_right, "left")
  else
    table.insert(left_right, "right")
  end
end
a:add_column("Side", left_right)
print(a:head(4))

a:as_categorical("Side")
print(a:head(4))
