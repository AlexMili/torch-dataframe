require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

a = Dataframe()
a:load_csv{
  path = "/media/max/Ext_Enc_Rack/Extracted/dataset_4_torch_lda.csv",
  verbose = true,
  rows2explore = 1e4
}
