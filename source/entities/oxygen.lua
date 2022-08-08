import "CoreLibs/object"
import "CoreLibs/graphics"

import "balance"

local gfx <const> = playdate.graphics

class('Oxygen').extends()

function Oxygen:init()
    self.value = OXYGEN_MAX
    self.sprite = gfx.sprite.new()
    -- TODO use actual size
    self.sprite:setSize(400, 240)
    self.sprite:setCenter(0, 0)
    self.sprite:moveTo(0, 0)
    self.sprite:setZIndex(1000)
    self.sprite:setIgnoresDrawOffset(true)
    self.sprite.draw = function(spriteSelf)
        local padding = 3
        local x, y = 10, 10
        local width, height = OXYGEN_MAX, 16

        -- Vessel
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(x - padding, y - padding, width + 2 * padding, height + 2 * padding)

        -- Border
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRect(x - padding, y - padding, width + 2 * padding, height + 2 * padding)

        -- Filling
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(x, y, self.value, height)
    end
    self.sprite:add()
end

function Oxygen:tick(time_diff)
    self.value = math.max(self.value - time_diff * OXYGEN_USAGE, 0)
end