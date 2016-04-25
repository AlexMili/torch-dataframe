require "../Dataframe"

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

print("-- Long table --")
a:load_csv{path = "realistic_29_row_data.csv",
           verbose = false}
print(a)

a.print.no_rows = 5
print(a)

a.print.no_rows = 20
print(a)

a:as_categorical('Gender')
a.print.no_rows = 5
print(a)

females = a:where('Gender', 'Female')
print(females)
