-- First, let's define a utility function to serialize the entity's data
function serialize_entity(entity)
    local entity_data = entity:get_luaentity()
    local data = {
        name = entity_data.name,
        hp = entity_data.hp,
        metadata = entity_data.metadata -- Assuming your entity stores custom data in a 'metadata' field
    }
    return minetest.serialize(data)
end

function capture_entity(user, object)
    if not object or not user then
        return user:get_wielded_item()  -- Return the itemstack to avoid nil value errors
    end

    local itemstack = user:get_wielded_item()

    -- Check if the wielded item is an empty Morb
    if itemstack:get_name() ~= "morbs:morb_empty" then
        return itemstack  -- If not wielding an empty Morb, return the itemstack
    end

    -- Serialize the entity's data
    local serialized_data = serialize_entity(object)

    -- Create a new ItemStack for the occupied Morb
    local new_stack = ItemStack("morbs:morb_occupied")
    new_stack:get_meta():set_string("entity", serialized_data)

    -- Remove the captured entity
    object:remove()

    -- Handle inventory changes
    if itemstack:get_count() == 1 then
        user:set_wielded_item(new_stack)  -- Replace the empty Morb with the occupied one
    else
        itemstack:take_item()
        user:get_inventory():add_item("main", new_stack)
        user:set_wielded_item(itemstack)  -- Set the decreased itemstack
    end

    return itemstack  -- Return the updated itemstack
end


-- Function to release an entity
function release_entity(pos, itemstack, user)
    local meta = itemstack:get_meta()
    local entity_data = meta:get_string("entity_data")

    if entity_data and entity_data ~= "" then
        local entity = minetest.deserialize(entity_data)
        if entity then
            entity.initial_properties = nil  -- Clear initial properties if any
            minetest.add_entity(pos, entity.name, entity)
        end
    end

    -- Replace the item with an empty Morb
    return ItemStack("morbs:morb_empty")
end


