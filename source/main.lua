import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

import "entities/world"
import "entities/player"
import "entities/exit"
import "entities/oxygen"

import "physics/camera"
import "physics/player_movement"
import "physics/player_collisions"

import "balance"

local gfx <const> = playdate.graphics

-- Global components
local world = World()
local player = Player()
local exit = Exit()
local oxygen = Oxygen(player)

-- One time init
function init()
    world:load_level("Level_1", player, exit)
end

init()

function playdate.update()
    local dt = 1 / playdate.display.getRefreshRate()

    -- Update player position
    update_player_velocity(player, dt)
    move_player_with_collisions(player, dt)

    -- Update entities
    if not player.reached_exit then
        oxygen:tick(dt)
    end

    -- Update display state
    update_follow_camera(player)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.sprite.update()
    playdate.timer.updateTimers()

    if DEBUG then
        playdate.drawFPS(370, 10)
    end
end