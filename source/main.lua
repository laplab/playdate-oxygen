import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "external/ldtk.lua"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

class('Player').extends()

function Player:init()
    self.imagetable = gfx.imagetable.new("images/player")
    self.sprite = gfx.sprite.new(self.imagetable:getImage(1, 1))
	self.sprite:setCollideRect(0, 0, self.sprite:getSize())
end

function Player:reset(entity)
    local sprite = self.sprite
    sprite:setZIndex(entity.zIndex)
	sprite:moveTo(entity.position.x, entity.position.y)
	sprite:setCenter(entity.center.x, entity.center.y)
    sprite:setImageFlip(gfx.kImageUnflipped)
    sprite:add()

	self.velocity = geom.vector2D.new(0, 0)
end

local player = Player()

local game = {}

local layerSprites = {}

function world_shutdown()
    for layer_name in pairs(LDtk.get_layers(game.level_name)) do
        layerSprites[layer_name]:remove()
        layerSprites[layer_name] = nil
    end

	LDtk.release_level( game.level_name )
end

function setup_level(level_name)
    local previous_level = game.level_name
	game.level_name = level_name

	LDtk.load_level(level_name)
	LDtk.release_level(previous_level)

	playdate.graphics.sprite.removeAll()

	layerSprites = {}
	for layer_name, layer in pairs(LDtk.get_layers(level_name)) do
		if not layer.tiles then
			goto continue
		end

		local tilemap = LDtk.create_tilemap(level_name, layer_name)

		local layerSprite = playdate.graphics.sprite.new()
		layerSprite:setTilemap(tilemap)
		layerSprite:moveTo(0, 0)
		layerSprite:setCenter(0, 0)
		layerSprite:setZIndex(layer.zIndex)
		layerSprite:add()
		layerSprites[layer_name] = layerSprite

		local emptyTiles = LDtk.get_empty_tileIDs(level_name, "Solid", layer_name)

		if emptyTiles then
			playdate.graphics.sprite.addWallSprites(tilemap, emptyTiles)
		end

		::continue::
	end

    for index, entity in ipairs( LDtk.get_entities( level_name ) ) do
		if entity.name == "Player" then
			-- if entity.fields.EntranceDirection == direction then
				player:reset(entity)
			-- end
		end
	end

    playdate.graphics.sprite.setAlwaysRedraw(true)
end

function init()
    local use_ldtk_precomputed_levels = not playdate.isSimulator
    LDtk.load("levels/world.ldtk", use_ldtk_precomputed_levels)

    if playdate.isSimulator then
        -- TODO: Use exported Lua level files in the production build.
        LDtk.export_to_lua_files()
    end

    setup_level("Level_0")
end

init()

local conf = {
    player_max_speed = 4, -- m/s
    player_ground_friction = 50 -- m/s^2
}

function approach(current, target, step, dt)
    step *= dt
    assert(step > 0)
    if current > target then
        return math.max(current - step, target)
    elseif current < target then
        return math.min(current + step, target)
    else
        return current
    end
end

function playdate.update()
    local dt = 1 / playdate.display.getRefreshRate()

    if not playdate.buttonIsPressed( playdate.kButtonLeft | playdate.kButtonRight ) then
        player.velocity.x = approach(player.velocity.x, 0, conf.player_ground_friction, dt)
    end

    if playdate.buttonIsPressed( playdate.kButtonLeft ) then
		player.velocity.x = -conf.player_max_speed
		player.sprite:setImageFlip(playdate.graphics.kImageFlippedX)
	end
	if playdate.buttonIsPressed( playdate.kButtonRight ) then
		player.velocity.x = conf.player_max_speed
		player.sprite:setImageFlip(playdate.graphics.kImageUnflipped)
	end

    local goalX = player.sprite.x + player.velocity.x

	local actualX, _ = player.sprite:moveWithCollisions(goalX, player.sprite.y)

    if actualX ~= goalX then
        player.velocity.x = 0
    end

    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.sprite.update()
    playdate.timer.updateTimers()
    playdate.drawFPS(10, 10)
end