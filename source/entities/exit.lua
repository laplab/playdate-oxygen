import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

class('Exit').extends()

function Exit:init()
    self.sprite = gfx.sprite.new(gfx.image.new("images/exit"))
end

function Exit:reset(entity)
    local sprite = self.sprite
    sprite:setZIndex(entity.fields.z_index)
	sprite:moveTo(entity.position.x, entity.position.y)
	sprite:setCenter(entity.center.x, entity.center.y)
    sprite:add()
end