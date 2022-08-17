import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

import "external/roomy"

import "entities/world"
import "entities/player"
import "entities/exit"
import "entities/oxygen"

import "physics/camera"
import "physics/player_velocity"
import "physics/player_movement"

import "balance"

class("Gameplay").extends(Room)

function Gameplay:enter(previous, ...)
	self.world = World()
    self.player = Player()
    self.exit = Exit()
    self.oxygen = Oxygen(self.player)

    self.world:load_level("Level_0", self.player, self.exit)
end

function Gameplay:update()
	local dt = 1 / playdate.display.getRefreshRate()

    -- Update player position
    update_player_velocity(self.player, dt)
    move_player(self.player, dt)

    -- Update entities
    if not self.player.reached_exit then
        self.oxygen:tick(dt)
    end

    -- Update display state
    update_follow_camera(self.player)
end

function Gameplay:leave(next, ...)
	self.world:destroy()
end