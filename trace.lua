require './init.lua'
luatrace = require 'luatrace'

df = Dataframe('./specs/data/full.csv')

luatrace.tron()

whatever = #df

luatrace.troff()