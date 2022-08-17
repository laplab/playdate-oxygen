import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

import "external/roomy"

class("Win").extends(Room)

local gfx <const> = playdate.graphics

function Win:init(oxygen_left, oxygen_max)
    Win.super.init(self)
    self.oxygen_left = math.floor(oxygen_left)
    self.oxygen_max = oxygen_max
end

function Win:enter(previous, ...)
    background = gfx.sprite.new(gfx.image.new("images/win-background.png"))
    background:setSize(400, 240)
    background:setCenter(0, 0)
    background:moveTo(0, 0)
    background:setZIndex(1)
    background:add()

    local oxygen_font = gfx.font.new("fonts/Moonwalker")
    assert(oxygen_font)
    local score = gfx.sprite.new()
    -- TODO use actual size
    score:setSize(400, 240)
    score:setCenter(0, 0)
    score:moveTo(0, 0)
    score:setZIndex(2)
    score.draw = function (spriteSelf)
        gfx.setFont(oxygen_font)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

        local message = tostring(self.oxygen_left)
        local width, _ = gfx.getTextSize(message)
        gfx.drawText(tostring(self.oxygen_left), 122 - width / 2, 147)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
    score:add()
end

function Win:update()
	local dt = 1 / playdate.display.getRefreshRate()
end

function Win:leave(next, ...)
    -- TODO: You cannot leave win screen at the moment.
    Win.super.leave(self)
end