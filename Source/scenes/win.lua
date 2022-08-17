import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"
import "CoreLibs/qrcode"

import "external/roomy"

class("Win").extends(Room)

local gfx <const> = playdate.graphics

function Win:init(oxygen_left, oxygen_max)
    Win.super.init(self)
    self.oxygen_left = math.floor(oxygen_left)
    self.oxygen_max = oxygen_max
end

function Win:enter(previous, ...)
    local background = gfx.sprite.new(gfx.image.new("images/win-background.png"))
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

    self.qr_code = gfx.sprite.new()
    -- TODO use actual size
    self.qr_code:setSize(128, 128)
    self.qr_code:setCenter(0, 0)
    self.qr_code:moveTo(240, 100)
    self.qr_code:setZIndex(2)
    self.qr_code:add()

    local url = "https://laplab.me/oxygen/#Nikita-"..tostring(self.oxygen_left).."-secretHash"
    gfx.generateQRCode(url, 128, function (image, errorMessage)
        if not image then
            print("Error generating QR code: "..errorMessage)
            return
        end

        self.qr_code:setImage(image)
    end)
end

function Win:update()
	local dt = 1 / playdate.display.getRefreshRate()
end

function Win:leave(next, ...)
    -- TODO: You cannot leave win screen at the moment.
    Win.super.leave(self)
end