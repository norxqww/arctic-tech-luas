--[[

        ~ custom hitsound - arctic tech.
      ~~ zxkilla x internetenemy.

--]]

local sounds = {
	[1] = {
		name = "» warning",
		path = "resource/warning.wav"
	},
	[2] = {
		name = "» wood stop",
		path = "doors/wood_stop1.wav"
	},
	[3] = {
		name = "» wood strain",
		path = "physics/wood/wood_strain7.wav"
	},
	[4] = {
		name = "» wood plank impact",
		path = "physics/wood/wood_plank_impact_hard4.wav"
	}
}
local ui_sounds = {}
for i = 1, #sounds do
	table.insert(ui_sounds, sounds[i].name)
end

local menu = {
	gr = ui.groupbox("Scripts", "« custom hitsound »"),
	elements = function(self)
		self.master_switch = self.gr:checkbox("custom hitsound")
		self.head_sound = self.gr:combo("» head shot sound", unpack(ui_sounds))
		self.body_sound = self.gr:combo("» body shot sound", unpack(ui_sounds))
		self.volume = self.gr:slider_int("» volume", 1, 100, 1, "%d%%")
		local vis = function()
			self.head_sound:visible(self.master_switch:get())
			self.body_sound:visible(self.master_switch:get())
			self.volume:visible(self.master_switch:get())
		end; vis()
		self.master_switch:set_callback(vis)
	end
}; menu:elements()
client.add_callback("game_events", function(event)
	if event:get_name() ~= "player_hurt" or entity.get(event.attacker, true) ~= entity.get_local_player() then return end
	local sound_file = sounds[event.hitgroup == 1 and menu.head_sound:get()+1 or menu.body_sound:get()+1].path
	utils.console_exec(string.format("playvol %s %s", sound_file, tostring(menu.volume:get()/100):gsub(',', '.')))
end)