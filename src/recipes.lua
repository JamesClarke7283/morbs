-- Define the crafting recipe for the empty Morb
if minetest.get_modpath("mcl_end") and minetest.get_modpath("mcl_core") then
    minetest.register_craft({
        output = "morbs:morb_empty",
        recipe = {
            {"", "mcl_core:glass", ""},
            {"mcl_core:glass", "mcl_end:ender_eye", "mcl_core:glass"},
            {"", "mcl_core:glass", ""}
        }
    })
elseif minetest.get_modpath("default") then
    minetest.register_craft({
        output = "morbs:morb_empty",
        recipe = {
            {"", "default:glass", ""},
            {"default:glass", "default:mese", "default:glass"},
            {"", "default:glass", ""}
        }
    })
else
    error("[MORBS] Need either default or mcl_end and mcl_core to work! (MTG or MCL, AKA Minetest Game or MineClone2)")
end