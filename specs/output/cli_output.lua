require 'torch'

-- Make sure that directory structure is always the same
require('lfs')
if (string.match(lfs.currentdir(), "/specs/output$")) then
  lfs.chdir("../..")
end
paths.dofile('init.lua')

-- Go into tests so that the loading of CSV:s is the same as always
lfs.chdir("specs/output")

-- A quick way to get a feeling for how the __tostring method works
local a = Dataframe()
a:load_csv{path = "../data/simple_short.csv",
           verbose = false}
a:add_column('boolean', true)
a:set(2, Df_Dict{boolean = false})
a:set(3, Df_Dict{boolean = 0/0})

print("-- Simple table with boolean column --")
print(a)

a:output()

print("-- Advanced table --")
a:load_csv{path = "../data/advanced_short.csv",
           verbose = false}
print(a)

print(" - check digits")

a:output{digits = 2}

print("-- Long table --")
a:load_csv{path = "../data/realistic_29_row_data.csv",
           verbose = false}
a.tostring_defaults.no_rows = 5
print(a)

a.tostring_defaults.no_rows = 20
print(a)

a:as_categorical('Gender')
a.tostring_defaults.no_rows = 5
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
a:add_column("Side", Df_Array(left_right))
print(a:head(4):tostring(Df_Array("Weight")))

a:as_categorical("Side")
print(a:head(4):tostring("Comm"))

tbl = {
	no = {},
	one = {},
	two = {},
	three = {},
	four = {},
	five = {},
	six = {},
	seven = {},
	eight = {},
	nine = {}
}

local long_txt = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud ex"
for k,v in pairs(tbl)	do
	for i=1,4 do
		if (k == "no") then
			v[#v + 1] = i
		else
			v[#v + 1] = long_txt
		end
	end
end

a = Dataframe{data=Df_Dict(tbl),
	            column_order=Df_Array("no", "one", "two", "three", "four", "five",
	                                  "six", "seven", "eight", "nine")}
a:output()

a = Dataframe(Df_Dict{
	Filename = 11,
	fracture = 11,
	Side = 11,
	Exam_view = 11,
	osteoarthritis = 11,
	styloid = 11,
	prev_fracture = 11,
	Exam_body_part = 11
})

print(a)
