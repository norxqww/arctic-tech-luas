-- cringe clock syncing thing
-- credits: @estk - ping spike (datagram ind.) calculations

local ffi_cast = ffi.cast
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

print_raw('\n\n - \a808080Custom net_graph \n\aFFFFFF - \a808080Sponsored by \a111111dsc.gg/crxsedtears | internetenemy\n')


--@ menu stuff
ui.tab("net_graph");
local menu_tab = ui.groupbox('net_graph', 'summerlove')

local menu = {
    enable = menu_tab:checkbox(' enable alpha on scope'),
    value = menu_tab:slider_int("alpha value", 0, 255, 0),
}

local function visiblity()
    menu.value:visible(menu.enable:get(0))
end

--@ convars stuff
local cl_interp = cvar.cl_interp -- 0.015625
local cl_interp_ratio = cvar.cl_interp_ratio -- 1
local cl_updaterate = cvar.cl_updaterate

--@ ffi ^^
local pflFrameTime = ffi.new("float[1]")
local pflFrameTimeStdDeviation = ffi.new("float[1]")
local pflFrameStartTimeStdDeviation = ffi.new("float[1]")
local interface_ptr = ffi.typeof('void***')
local netc_bool = ffi.typeof("bool(__thiscall*)(void*)")
local netc_bool2 = ffi.typeof("bool(__thiscall*)(void*, int, int)")
local netc_float = ffi.typeof("float(__thiscall*)(void*, int)")
local netc_int = ffi.typeof("int(__thiscall*)(void*, int)")
local net_fr_to = ffi.typeof("void(__thiscall*)(void*, float*, float*, float*)")

local rawivengineclient = utils_create_interface("engine.dll", "VEngineClient014") or error("[-] ~ VEngineClient014 wasnt found", 2)
local ivengineclient = ffi_cast(interface_ptr, rawivengineclient) or error("[-] ~ Rawivengineclient is nil", 2)
local get_net_channel_info = ffi_cast("void*(__thiscall*)(void*)", ivengineclient[0][78]) or error("[-] ~ Ivengineclient is nil")
local slv_is_ingame_t = ffi_cast("bool(__thiscall*)(void*)", ivengineclient[0][26]) or error("[-] ~ Is_in_game is nil")

--@ main
local ping_spike = {ui.find("Misc", "Miscellaneous", "Amount"):get()}
local LC_ALPHA = 1


local verdana = render.load_font("Verdana", 12, "a")
local bigger_verdana = render.load_font("Verdana", 20, "a")


local ping_color = function(ping_value)
    if ping_value < 40 then return { 255, 255, 255 } end
    if ping_value < 100 then return { 255, 125, 95 } end

    return { 255, 60, 80 }
end

local ifinscope = function(value)
if menu.enable:get(0) then
    local isinscope = entity_get_local_player()['m_bIsScoped']
        if isinscope then 
             value = value - menu.value:get()
        end
    end
    return value

end


local GetNetChannel = function(INetChannelInfo)
    if INetChannelInfo == nil then
        return
    end

    local seqNr_out = ffi_cast(netc_int, INetChannelInfo[0][17])(INetChannelInfo, 1)

    return {
        seqNr_out = seqNr_out,

        is_loopback = ffi_cast(netc_bool, INetChannelInfo[0][6])(INetChannelInfo),
        is_timing_out = ffi_cast(netc_bool, INetChannelInfo[0][7])(INetChannelInfo),

        latency = {
            crn = function(flow) return ffi_cast(netc_float, INetChannelInfo[0][9])(INetChannelInfo, flow) end,
            average = function(flow) return ffi_cast(netc_float, INetChannelInfo[0][10])(INetChannelInfo, flow) end,
        },

        loss = ffi_cast(netc_float, INetChannelInfo[0][11])(INetChannelInfo, 1),
        choke = ffi_cast(netc_float, INetChannelInfo[0][12])(INetChannelInfo, 1),
        got_bytes = ffi_cast(netc_float, INetChannelInfo[0][13])(INetChannelInfo, 1),
        sent_bytes = ffi_cast(netc_float, INetChannelInfo[0][13])(INetChannelInfo, 0),

        is_valid_packet = ffi_cast(netc_bool2, INetChannelInfo[0][18])(INetChannelInfo, 1, seqNr_out-1),
    }
end

local GetNetFramerate = function(INetChannelInfo)
    if INetChannelInfo == nil then
        return 0, 0
    end

    local server_var = 0
    local server_framerate = 0

    ffi_cast(net_fr_to, INetChannelInfo[0][25])(INetChannelInfo, pflFrameTime, pflFrameTimeStdDeviation, pflFrameStartTimeStdDeviation)

    if pflFrameTime ~= nil and pflFrameTimeStdDeviation ~= nil and pflFrameStartTimeStdDeviation ~= nil then
        if pflFrameTime[0] > 0 then
            server_var = pflFrameStartTimeStdDeviation[0] * 1000
            server_framerate = pflFrameTime[0] * 1000
        end
    end

    return server_framerate, server_var
end

local function g_paint()
    local me = entity_get_local_player()
    if not me or not slv_is_ingame_t(ivengineclient) then return end

    local INetChannelInfo = ffi_cast("void***", get_net_channel_info(ivengineclient)) or error("[-] ~ Netchaninfo is nil")
    local net_channel = GetNetChannel(INetChannelInfo)
    local server_framerate, server_var = GetNetFramerate(INetChannelInfo)
    local alpha = math_min(math_floor(math_sin((globals.realtime%3) * 4) * 125 + 200), ifinscope(255))

    local clr = {255, 200, 95, 255}
    local x, y = render.screen_size().x, render.screen_size().y
    x,y = x / 2 + 1, y - 155

    local net_state = 0
    local net_data_text = {
        [0] = 'clock syncing',
        [1] = 'packet choke',
        [2] = 'packet loss',
        [3] = 'lost connection'
    }

    if net_channel.choke > 0.00 then net_state = 1 end
    if net_channel.loss > 0.00 then net_state = 2 end

    if net_channel.is_timing_out then 
        net_state = 3
        net_channel.loss = 1

        LC_ALPHA = LC_ALPHA-globals.frametime
        LC_ALPHA = LC_ALPHA < 0.05 and 0.05 or LC_ALPHA 
    else
        LC_ALPHA = LC_ALPHA+(globals.frametime*2)
        LC_ALPHA = LC_ALPHA > 1 and 1 or LC_ALPHA 
    end

    local right_text = net_state ~= 0 and string_format('%.1f%% (%.1f%%)', net_channel.loss*100, net_channel.choke*100) or string_format('%.1fms', server_var/2)

    if net_state ~= 0 then
        clr = { 255, 50, 50, alpha }
    end

    local ccor_text = net_data_text[net_state]
    local ccor_width = render.measure_text(verdana, ccor_text)

    local sp_x = x - ccor_width.x - 25
    local sp_y = y

    local cn = 1
    
    render.text(verdana, vector(sp_x + 5, sp_y), color(255, 255, 255, net_state ~= 0 and 255 or alpha), "o", ccor_text)
    render.text(bigger_verdana, vector(x - 11, sp_y - 8), color(clr[1], clr[2], clr[3], ifinscope(clr[4])), "d", "⚠")
    render.text(verdana, vector(x + 20, sp_y), color(255, 255, 255, ifinscope(255)), "o", string_format('+- %s', right_text))

    local bytes_in_text = string_format('in: %.2fk/s    ', net_channel.got_bytes/1024)
    local bi_width = render.measure_text(verdana, bytes_in_text)

    local tickrate = 1/globals.tickinterval
    local lerp_time = cl_interp_ratio:float() * (1000 / tickrate)
    local lerp_clr = { 255, 255, 255 }

    if lerp_time/1000 < 2/cl_updaterate:int() then
        lerp_clr = { 255, 125, 95 }
    end

    render.text(verdana, vector(sp_x + 5, sp_y + 20*cn), color(255, 255, 255, ifinscope(LC_ALPHA*255)), "o", bytes_in_text)
    render.text(verdana, vector(sp_x + 10 + bi_width.x, sp_y + 20*cn), color(lerp_clr[1], lerp_clr[2], lerp_clr[3], ifinscope(LC_ALPHA*255)), "o", string_format('lerp: %.1fms', lerp_time)); cn=cn+1
    render.text(verdana, vector(sp_x + 5, sp_y + 20*cn), color(255, 255, 255, ifinscope(LC_ALPHA*255)), "o", string_format('out: %.2fk/s', net_channel.sent_bytes/1024)); cn=cn+1
    render.text(verdana, vector(sp_x + 5, sp_y + 20*cn), color(255, 255, 255, ifinscope(LC_ALPHA*255)), "o", string_format('sv: %.2f +- %.2fms    var: %.3f ms', server_framerate, server_var, server_var)); cn=cn+1

    
    local outgoing, incoming = net_channel.latency.crn(0), net_channel.latency.crn(1)
    local ping, avg_ping = outgoing*1000, net_channel.latency.average(0)*1000
    
    local ping_spike_val = ping_spike[1]

    local latency_interval = (outgoing + incoming) / (ping_spike_val - globals.tickinterval)
    local additional_latency = math_min(latency_interval*1000, 1) * 100

    local pc = ping_color(avg_ping)
    local tr_text = string_format('tick: %dp/s    ', tickrate)
    local tr_width = render.measure_text(verdana, tr_text).x

    local nd_text = string_format('delay: %dms (+- %dms)    ', avg_ping, math_abs(avg_ping-ping))
    local nd_width = render.measure_text(verdana, nd_text).x

    local incoming_latency = math_max(0, (incoming-outgoing)*1000)
    
    local fl_pre_text = (ping_spike_val ~= 1 and incoming_latency > 1) and string_format(': %dms', incoming_latency) or ''
    local fl_text = string_format('datagram%s', fl_pre_text)

    render.text(verdana, vector(sp_x + 5, sp_y + 20*cn), color(pc[1], pc[2], pc[3], ifinscope(LC_ALPHA*255)), "o", nd_text);

    render.text(verdana, vector(sp_x + 10+ nd_width, sp_y + 20*cn), color(255, 255 / 100 * additional_latency, 255 / 100 * additional_latency, ifinscope(LC_ALPHA*255)), "o", fl_text); cn=cn+1
end

client.add_callback("render", function()
    g_paint()
    visiblity()
end)
