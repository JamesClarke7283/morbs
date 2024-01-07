local modpath = minetest.get_modpath("morbs")
morbs = {}

local source_dir = modpath .. "/src/"

-- Load files
dofile(source_dir .. "utils.lua")
dofile(source_dir .. "item.lua")
dofile(source_dir .. "recipes.lua")