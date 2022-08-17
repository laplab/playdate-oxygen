import "CoreLibs/object"
import "CoreLibs/graphics"

import "balance"

local gfx <const> = playdate.graphics

class('Exit').extends()

function Exit:init()
    self.sprite = gfx.sprite.new(gfx.image.new("images/exit"))
    self.sprite:setCollideRect(0, 0, self.sprite:getSize())
    self.sprite:setTag(EXIT_TAG)
end

function Exit:reset(entity)
    local sprite = self.sprite
    sprite:setZIndex(entity.fields.z_index)
	sprite:moveTo(entity.position.x, entity.position.y)
	sprite:setCenter(entity.center.x, entity.center.y)
    sprite:add()
end