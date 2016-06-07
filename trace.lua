require 'Dataframe'
luatrace = require 'luatrace'

df = Dataframe()

df:load_table{data=Df_Dict({
	['first_column']={3,4,5},
	['second_column']={10,11,12}
})}

luatrace.tron()

whatever = #df

luatrace.troff()