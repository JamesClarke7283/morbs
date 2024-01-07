-- Register the empty Morb item
minetest.register_craftitem("morbs:morb_empty", {
    description = "Empty Morb",
    inventory_image = "morb_empty.png",
    on_secondary_use = function(itemstack, user, pointed_thing)
        -- Only proceed if pointing at an object/entity
        if pointed_thing.type == "object" then
            local entity = pointed_thing.ref:get_luaentity()
            
            -- Make sure it's not a player or an already captured entity
            if entity and not entity.is_player and not entity.captured then
                return capture_entity(user, pointed_thing.ref)
            end
        end
        return itemstack
    end,
})

-- Register the occupied Morb item
minetest.register_craftitem("morbs:morb_occupied", {
    description = "Occupied Morb",
    inventory_image = "morb_occupied.png",
    on_secondary_use = function(itemstack, placer, pointed_thing)
        -- Only proceed if pointing at a node and the position is valid
        if pointed_thing.type == "node" then
            local pos = minetest.get_pointed_thing_position(pointed_thing, true)
            if pos then -- Check if the position is valid
                return release_entity(pos, itemstack, placer)
            end
        end
        return itemstack
    end,
})



-- Override the on_rightclick method for all entities
for _, entity in pairs(minetest.registered_entities) do
    local original_on_rightclick = entity.on_rightclick
    entity.on_rightclick = function(self, clicker, itemstack, pointed_thing)
        -- Attempt to capture the entity if the user is wielding an empty Morb
        local wielded = clicker:get_wielded_item()
        if wielded:get_name() == "morbs:morb_empty" then
            local captured = capture_entity(clicker, self.object)
            if captured then
                return wielded  -- Return the modified wielded item (either empty or occupied Morb)
            end
        end
        
        -- If the entity was not captured, call the original on_rightclick function
        if original_on_rightclick then
            return original_on_rightclick(self, clicker, itemstack, pointed_thing)
        end
    end
end



