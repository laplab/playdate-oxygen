import "CoreLibs/object"
import "CoreLibs/graphics"

import "external/ldtk.lua"

local gfx <const> = playdate.graphics

class('World').extends()

function World:init()
    local use_ldtk_precomputed_levels = not playdate.isSimulator
    LDtk.load("levels/world.ldtk", use_ldtk_precomputed_levels)

    if playdate.isSimulator then
        -- TODO: Use exported Lua level files in the production build.
        LDtk.export_to_lua_files()
    end

    self.layers = {}
end

function World:destroy()
    for layer_name in pairs(LDtk.get_layers(self.level_name)) do
        self.layers[layer_name]:remove()
        self.layers[layer_name] = nil
    end

	LDtk.release_level(self.level_name)
end

function World:load_level(level_name, player, exit)
    local previous_level = self.level_name
	self.level_name = level_name

	LDtk.load_level(level_name)
	LDtk.release_level(previous_level)

	self.layers = {}
	for layer_name, layer in pairs(LDtk.get_layers(level_name)) do
		if not layer.tiles then
			goto continue
		end

		local tilemap = LDtk.create_tilemap(level_name, layer_name)

		local layerSprite = gfx.sprite.new()
		layerSprite:setTilemap(tilemap)
		layerSprite:moveTo(0, 0)
		layerSprite:setCenter(0, 0)
		layerSprite:setZIndex(layer.zIndex)
		layerSprite:add()
		self.layers[layer_name] = layerSprite

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

        if entity.name == "Exit" then
			-- if entity.fields.EntranceDirection == direction then
				exit:reset(entity)
			-- end
		end
	end

    gfx.sprite.setAlwaysRedraw(true)
end