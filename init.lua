-- beerchat_roles/init.lua
-- Role indicator in chatroom
-- Copyright (C) 2024  1F616EMO
-- SPDX-License-Identifier: LGPL-3.0-or-later

local S = minetest.get_translator("beerchat_roles")

beerchat_roles = {}

beerchat_roles.registered_roles = {}
function beerchat_roles.register_role(def)
    beerchat_roles.registered_roles[#beerchat_roles.registered_roles+1] = def
end

minetest.register_on_mods_loaded(function()
    table.sort(beerchat_roles.registered_roles, function(a, b)
        return (a.sort or 0) > (b.sort or 0)
    end)
end)

beerchat.register_callback("before_send", function(target, message, data)
    if not data then return end
	local player_name = data.name
    for _, def in ipairs(beerchat_roles.registered_roles) do
        if def.func(player_name) then
            local role_string = def.name
            if data.name == target then
                role_string = minetest.colorize("grey", role_string)
            elseif def.color then
                role_string = minetest.colorize("grey", def.color)
            end

            data.message = beerchat.format_message(
                beerchat.main_channel_message_string, {
                    channel_name = data.channel,
                    to_player = target,
                    from_player = role_string .. " " .. data.name,
                    message = message,
                })
            return
        end
    end
end)

local check_privs_func = function(privs)
    return function(name)
        return minetest.check_player_privs(name, privs)
    end
end

beerchat_roles.register_role({
    name = S("Admin"),
    color = "#1EFA17",
    func = check_privs_func({ server = true }),
    sort = 9900,
})

beerchat_roles.register_role({
    name = S("Mod"),
    color = "#5353D2",
    func = check_privs_func({ ban = true }),
    sort = 9800,
})
