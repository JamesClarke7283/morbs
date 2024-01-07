-- utils.lua
-- Recursive serialization function
function morbs.recursive_serialize(value, seen)
    if type(value) == "table" then
        if seen[value] then
            return "\"[Circular]\""  -- Handle circular references
        end
        seen[value] = true

        local result = {}
        for k, v in pairs(value) do
            table.insert(result, "[" .. morbs.recursive_serialize(k, seen) .. "]=" .. morbs.recursive_serialize(v, seen))
        end
        return "{" .. table.concat(result, ", ") .. "}"
    elseif type(value) == "string" then
        return minetest.formspec_escape(value)  -- Escape strings for Minetest
    else
        return tostring(value)
    end
end

-- Helper function to clean mob staticdata
local function clean_staticdata(self)
    local tmp = {}
    for key, value in pairs(self) do
        if type(value) ~= "function" and type(value) ~= "nil" and type(value) ~= "userdata" and key ~= "object" and key ~= "_cmi_components" then
            tmp[key] = value
        end
    end
    return tmp
end

-- Function to serialize the entity's data with improved handling and logging
-- Function to serialize the entity's data with improved handling and logging
-- Function to serialize the entity's data with improved handling and logging
function morbs.serialize_entity(entity)
    local entity_data = entity:get_luaentity()

    if not entity_data then
        minetest.log("error", "[Morbs] Error in serializing entity: entity data is nil")
        return nil
    end

    -- Log the raw entity data
    minetest.log("action", "[Morbs] Raw Entity Data: " .. dump(entity_data))

    -- Clean the entity data before serialization
    local cleaned_data = clean_staticdata(entity_data)

    -- Log the cleaned entity data
    minetest.log("action", "[Morbs] Cleaned Entity Data: " .. dump(cleaned_data))

    -- Ensure essential fields are present
    if not cleaned_data.textures then
        minetest.log("error", "[Morbs] Textures missing in entity data for serialization")
        return nil
    end

    -- Add the name field from the original entity data if it's not present in cleaned data
    if not cleaned_data.name then
        if entity_data.name then
            cleaned_data.name = entity_data.name
        else
            minetest.log("error", "[Morbs] Name field missing in entity data for serialization")
            return nil
        end
    end

    -- Serialize and return the cleaned data
    local serialized_data = minetest.serialize(cleaned_data)
    minetest.log("action", "[Morbs] Serialized Entity Data: " .. serialized_data)
    return serialized_data
end







-- Function to capture an entity
function morbs.capture_entity(user, object)
    if not object or not user then
        return nil  -- No changes made to the wielded item if error conditions are met
    end

    local itemstack = user:get_wielded_item()

    -- Check if the wielded item is an empty Morb
    if itemstack:get_name() ~= "morbs:morb_empty" then
        return nil  -- No changes made if not wielding an empty Morb
    end

    -- Serialize the entity's data
    local serialized_data = morbs.serialize_entity(object)

    -- Create a new ItemStack for the occupied Morb
    local new_stack = ItemStack("morbs:morb_occupied")
    new_stack:get_meta():set_string("entity", serialized_data)

    -- Remove the captured entity
    object:remove()

    -- Replace the empty Morb with the occupied one
    if itemstack:get_count() > 1 then
        itemstack:take_item()  -- Decrease the stack of empty Morbs by one
        if user:get_inventory():room_for_item("main", new_stack) then
            user:get_inventory():add_item("main", new_stack)
        else
            minetest.add_item(user:get_pos(), new_stack)  -- Drop the occupied Morb if inventory is full
        end
    else
        itemstack:replace(new_stack)  -- Replace the stack with a single occupied Morb
    end

    return itemstack  -- Return the modified wielded item
end


-- Function to release an entity
function morbs.release_entity(pos, itemstack, user)
    local meta = itemstack:get_meta()
    local serialized_data = meta:get_string("entity")

    minetest.log("action", "[Morbs] Serialized Data: " .. serialized_data)

    if serialized_data and serialized_data ~= "" then
        local entity_properties = minetest.deserialize(serialized_data)

        if entity_properties and entity_properties.name then
            minetest.chat_send_player(user:get_player_name(), "Deserialized data: " .. dump(entity_properties))

            -- Corrected part: Pass only the name and serialized_data (as string) to add_entity
            local spawned_entity = minetest.add_entity(pos, entity_properties.name, serialized_data)
            if spawned_entity then
                minetest.chat_send_player(user:get_player_name(), "Entity released successfully.")
                return ItemStack("morbs:morb_empty")
            else
                minetest.chat_send_player(user:get_player_name(), "Failed to spawn entity.")
            end
        else
            minetest.chat_send_player(user:get_player_name(), "Invalid or missing entity data.")
        end
    else
        minetest.chat_send_player(user:get_player_name(), "No serialized data found.")
    end

    return ItemStack("morbs:morb_occupied") -- Return the original item if release fails
end
