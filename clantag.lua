-- gamesense clantag
-- credits: @sapphyrus - clantag animations

local client_add_callback, client_reload_script, client_unload_script = client.add_callback, client.reload_script, client.unload_script 
local entity_get_player_resource, entity_get_local_player, entity_from_handle, entity_get = entity.get_player_resource, entity.get_local_player, entity.from_handle, entity.get 
local ui_tab, ui_get_binds, ui_is_open, ui_groupbox, ui_find = ui.tab, ui.get_binds, ui.is_open, ui.groupbox, ui.find 
local utils_precache_model, utils_send_voice_message, utils_pattern_scan, utils_get_model_index, utils_trace_bullet, utils_random_float, utils_trace_hull, utils_console_exec, utils_get_net_channel, utils_set_clantag, utils_get_mouse_position, utils_is_key_pressed, utils_create_interface, utils_trace_line, utils_random_int, utils_random_seed = utils.precache_model, utils.send_voice_message, utils.pattern_scan, utils.get_model_index, utils.trace_bullet, utils.random_float, utils.trace_hull, utils.console_exec, utils.get_net_channel, utils.set_clantag, utils.get_mouse_position, utils.is_key_pressed, utils.create_interface, utils.trace_line, utils.random_int, utils.random_seed 
local render_rect_outline, render_add_font, render_circle_outline, render_world_to_screen, render_circle_3d, render_line, render_get_weapon_icon, render_vertex, render_screen_size, render_poly_line, render_pop_clip_rect, render_poly, render_push_clip_rect, render_text, render_gradient, render_circle, render_circle_3d_outline, render_texture, render_circle_gradient, render_rect, render_camera_position, render_camera_angles, render_measure_text, render_load_image, render_load_font = render.rect_outline, render.add_font, render.circle_outline, render.world_to_screen, render.circle_3d, render.line, render.get_weapon_icon, render.vertex, render.screen_size, render.poly_line, render.pop_clip_rect, render.poly, render.push_clip_rect, render.text, render.gradient, render.circle, render.circle_3d_outline, render.texture, render.circle_gradient, render.rect, render.camera_position, render.camera_angles, render.measure_text, render.load_image, render.load_font 
local math_random, math_ceil, math_tan, math_angle_diff, math_cos, math_sinh, math_mod, math_pi, math_max, math_atan2, math_floor, math_sqrt, math_deg, math_atan, math_fmod, math_acos, math_pow, math_abs, math_min, math_log, math_sin, math_exp, math_cosh, math_asin, math_rad = math.random, math.ceil, math.tan, math.angle_diff, math.cos, math.sinh, math.mod, math.pi, math.max, math.atan2, math.floor, math.sqrt, math.deg, math.atan, math.fmod, math.acos, math.pow, math.abs, math.min, math.log, math.sin, math.exp, math.cosh, math.asin, math.rad 
local table_sort, table_remove, table_concat, table_insert = table.sort, table.remove, table.concat, table.insert 
local string_find, string_lower, string_format, string_gsub, string_len, string_gmatch, string_match, string_reverse, string_upper, string_gfind, string_sub = string.find, string.lower, string.format, string.gsub, string.len, string.gmatch, string.match, string.reverse, string.upper, string.gfind, string.sub 
local rage_is_defensive_active, rage_get_exploit_charge, rage_get_antiaim_target, rage_force_charge, rage_is_shifting, rage_get_antiaim_yaw, rage_override_tickbase_shift, rage_force_teleport, rage_get_defensive_ticks = rage.is_defensive_active, rage.get_exploit_charge, rage.get_antiaim_target, rage.force_charge, rage.is_shifting, rage.get_antiaim_yaw, rage.override_tickbase_shift, rage.force_teleport, rage.get_defensive_ticks 
local network_get = network.get 
local json_parse, json_stringify = json.parse, json.stringify 
local files_read, files_create_folder, files_write, files_exists = files.read, files.create_folder, files.write, files.exists 
local materials_find, materials_create, materials_draw_chams = materials.find, materials.create, materials.draw_chams 
local ipairs, assert, pairs, next, tostring, tonumber, setmetatable, unpack, type, getmetatable, pcall, error = ipairs, assert, pairs, next, tostring, tonumber, setmetatable, unpack, type, getmetatable, pcall, error

local function time_to_ticks(time)
	return math_floor(time / globals.tickinterval + .5)
end

local skeet_tag_name = "skeet.cc (Old)"
local enabled_reference = ui.find("Misc", "Miscellaneous"):combo(' Clan tag spammer', 'disable', skeet_tag_name)
local default_reference = ui.find("Misc", "Miscellaneous", "Clantag"):get()
local clan_tag_prev = ""
local enabled_prev = "Off"

local function gamesense_anim(text, indices)
	local text_anim = "               " .. text .. "                      " 
	local tickinterval = globals.tickinterval
	local tickcount = globals.tickcount + time_to_ticks(utils.get_net_channel():get_avg_latency(1)*1000)
	local i = tickcount / time_to_ticks(0.3)
	i = math_floor(i % #indices)
	i = indices[i+1]+1

	return string_sub(text_anim, i, i+15)
end

local function run_tag_animation()
	if enabled_reference:get() == 1 then
		-- code10 - summerlove
		local clan_tag = gamesense_anim("skeet.cc", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22})
		if clan_tag ~= clan_tag_prev then
            utils.set_clantag(clan_tag)
		end
		clan_tag_prev = clan_tag
	end
end

client.add_callback("render", function()
	if enabled_reference:get() == 1 then
		local local_player = entity_get_local_player()
		if local_player ~= nil and (not local_player:is_alive()) and globals.tickcount % 2 == 0 then --missing noclip check
			run_tag_animation()
		end
    elseif enabled_prev == skeet_tag_name then
		utils.set_clantag("\0")
	end
	if enabled_reference:get() == 1 then
		if globals.choked_commands == 0 then
			run_tag_animation()
		end
	end
end)
