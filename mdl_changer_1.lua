
--[[

        ~ model changer - arctic tech.
      ~~ internetenemy x zxkilla.


	~~~ tutkach i love u ~^^

--]]


--@region: ffi
ffi.cdef [[
    typedef struct{
        void*   handle;
        char    name[260];
        int     load_flags;
        int     server_count;
        int     type;
        int     flags;
        float   mins[3];
        float   maxs[3];
        float   radius;
        char    pad[0x1C];
    } model_t;

    typedef struct {void** this;}aclass;
    typedef void*(__thiscall* get_client_entity_t)(void*, int);
    typedef void(__thiscall* find_or_load_model_fn_t)(void*, const char*);
    typedef const int(__thiscall* get_model_index_fn_t)(void*, const char*);
    typedef const int(__thiscall* add_string_fn_t)(void*, bool, const char*, int, const void*);
    typedef void*(__thiscall* find_table_t)(void*, const char*);
    typedef void(__thiscall* full_update_t)();
    typedef int(__thiscall* get_player_idx_t)();
    typedef void*(__thiscall* get_client_networkable_t)(void*, int);
    typedef void(__thiscall* pre_data_update_t)(void*, int);
    typedef int(__thiscall* get_model_index_t)(void*, const char*);
    typedef const model_t(__thiscall* find_or_load_model_t)(void*, const char*);
    typedef int(__thiscall* add_string_t)(void*, bool, const char*, int, const void*);
    typedef void(__thiscall* set_model_index_t)(void*, int);
    typedef int(__thiscall* precache_model_t)(void*, const char*, bool);
]]
--@endregion

local customplayers = {
	-- @hint: {"putin", "models/player/custom_player/night_fighter/putin/putin.mdl", true},
	--           ^ here u place ur model name |  ^ here u place pass to model    |    ^ true = model for t, false = model for ct
	{"Local T Agent", "models/player/custom_player/legacy/tm_phoenix.mdl", true},
	{"Local CT Agent", "models/player/custom_player/legacy/ctm_sas.mdl", false},
	{"Blackwolf | Sabre", "models/player/custom_player/legacy/tm_balkan_variantj.mdl", true},
	{"Rezan The Ready | Sabre", "models/player/custom_player/legacy/tm_balkan_variantg.mdl", true},
	{"Lt. Commander Ricksaw | NSWC SEAL", "models/player/custom_player/legacy/ctm_st6_varianti.mdl", false},
	{"'Two Times' McCoy | USAF TACP", "models/player/custom_player/legacy/ctm_st6_variantm.mdl", false}
}

local override_knife_reference = ui.find("Skins", "Models", "Override knife")

local teams = {
	{"Counter-Terrorist", false},
	{"Terrorist", true}
}

local team_references, team_model_paths = {}, {}
local model_index_prev

for i=1, #teams do
	local teamname, is_t = unpack(teams[i])

	team_model_paths[is_t] = {}
	local model_names = {}
	local l_i = 0
	for i=1, #customplayers do
		local model_name, model_path, model_is_t = unpack(customplayers[i])

		if model_is_t == nil or model_is_t == is_t then
			table.insert(model_names, model_name)
			l_i = l_i + 1
			team_model_paths[is_t][l_i] = model_path
		end
	end

	team_references[is_t] = {
		enabled_reference = ui.find("Skins", "Skins"):checkbox("Override player model\n" .. teamname),
		model_reference = ui.find("Skins", "Skins"):combo("Selected player model\n" .. teamname, "-", unpack(model_names)) 
	}
	for key, value in pairs(team_references[is_t]) do
		value:visible(false)
	end
end

local rawivmodelinfo = ffi.cast(ffi.typeof("void***"), utils.create_interface("client.dll", "VClientEntityList003")) or error("[*] -> rawientitylist is nil", 2)
local get_client_entity = ffi.cast("get_client_entity_t", rawivmodelinfo[0][3]) or error("[*] -> get_client_entity is nil", 2)
local modelinfo = ffi.cast(ffi.typeof("void***"), utils.create_interface("engine.dll", "VModelInfoClient004")) or error("[*] -> model info is nil", 2)
local get_model_index = ffi.cast("get_model_index_fn_t", modelinfo[0][2]) or error("[*] -> Getmodelindex is nil", 2)
local find_or_load_t = ffi.cast("find_or_load_model_fn_t", modelinfo[0][43]) or error("[*] -> findmodel is nil", 2)
local rawnetworkstringtablecontainer = ffi.cast(ffi.typeof("void***"), utils.create_interface("engine.dll", "VEngineClientStringTable001")) or error("[*] -> clientstring is nil", 2)
local find_table = ffi.cast("find_table_t", rawnetworkstringtablecontainer[0][3]) or error("[*] -> find table is nil", 2)

function precache_model(modelname)
    local rawprecache_table = ffi.cast(ffi.typeof("void***"), find_table(rawnetworkstringtablecontainer, "modelprecache"))
    if rawprecache_table ~= nil then
        find_or_load_t(modelinfo, modelname)
        local add_string = ffi.cast("add_string_fn_t", rawprecache_table[0][8]) or error("[*] -> add string is nil", 2)
        local idx = add_string(rawprecache_table, false, modelname, -1, nil)
        if idx == -1 then print("failed")
            return false
        end
    end
    return true
end

function set_model_index(entity_index, index)
	local raw_info = get_client_entity(rawivmodelinfo, entity_index)
    if raw_info then
        local something = ffi.cast(ffi.typeof("void***"), raw_info)
        local set_index = ffi.cast("set_model_index_t", something[0][75])
        if set_index == nil then
            error("set_model_index is nil")
        end
        set_index(something, index)
    end
end

function safe_precache(entity, model)
    if model:len() > 5 then
        if precache_model(model) == false then
            error("invalid model", 2)
        end
        local index = get_model_index(modelinfo, model)
        if index == -1 then
            return
        end
        set_model_index(entity, index)
    end
end

client.add_callback('frame_stage', function(stage)
    if stage ~= 1 then return end

	local local_player = entity.get_local_player()

	if local_player == nil then
		return
	end

	local model_path
	local teamnum = entity.get_local_player()['m_iTeamNum']
	local is_t
	if teamnum == 2 then
		is_t = true
	elseif teamnum == 3 then
		is_t = false
	end

	for references_is_t, references in pairs(team_references) do
        references.enabled_reference:visible(references_is_t == is_t)

		if references_is_t == is_t and references.enabled_reference:get() then
            references.model_reference:visible(true)
			model_path = team_model_paths[is_t][references.model_reference:get()]
		else
            references.model_reference:visible(false)
		end
	end

	if not local_player:is_alive() or model_path == nil then return end
    safe_precache(local_player:ent_index(), model_path)
end)