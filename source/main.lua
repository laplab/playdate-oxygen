import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "external/ldtk.lua"

local gfx <const> = playdate.graphics

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

function playdate.update()
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.sprite.update()
    playdate.timer.updateTimers()
end