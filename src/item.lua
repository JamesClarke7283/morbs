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
                return morbs.capture_entity(user, pointed_thing.ref)
            end
        end
        return itemstack
    end,
})

-- Register the occupied Morb item
minetest.register_craftitem("morbs:morb_occupied", {
    description = "Occupied Morb",
    inventory_image = "morb_occupied.png",
    on_place = function(itemstack, user, pointed_thing)
        -- Debugging log
        minetest.log("action", "[Morbs] on_place called with morbs:morb_occupied")

        -- Only proceed if pointing at a node and the position is valid
        if pointed_thing.type == "node" then
            local pos = minetest.get_pointed_thing_position(pointed_thing, true)
            if pos then
                -- Additional debugging log
                minetest.log("action", "[Morbs] Pointing at a valid node position: " .. minetest.pos_to_string(pos))
                local released = morbs.release_entity(pos, itemstack, user)
                if released then
                    return released
                else
                    minetest.chat_send_player(user:get_player_name(), "Failed to release the entity.")
                end
            else
                minetest.chat_send_player(user:get_player_name(), "Invalid position to release the entity.")
            end
        else
            -- Log when pointed_thing is not a node
            minetest.log("action", "[Morbs] Pointed thing is not a node")
        end
        return itemstack
    end,
})



function get_registered_entity_keys()
    local entity_keys = {}
    for key, _ in pairs(minetest.registered_entities) do
        table.insert(entity_keys, key)
    end
    return entity_keys
end

-- Override the on_rightclick method for all entities except for those with '__builtin' in their key
for key, entity in pairs(minetest.registered_entities) do
    if not string.find(key, "__builtin") then
        local original_on_rightclick = entity.on_rightclick
        minetest.log("action","Overriding on_rightclick for entity: ",key)
        entity.on_rightclick = function(self, clicker, itemstack, pointed_thing)
            -- Attempt to capture the entity if the user is wielding an empty Morb
            local wielded = clicker:get_wielded_item()
            if wielded:get_name() == "morbs:morb_empty" then
                local captured = morbs.capture_entity(clicker, self.object)
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
end
