import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"
import "CoreLibs/qrcode"

import "external/roomy"
import "external/base64"

import "log"

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

    -- TODO: Allow user to choose username.
    local username = "Nikita"
    local salt1 = "salty"
    local salt2 = "salster"

    local data = username..'-'..tostring(self.oxygen_left)
    local signature = string.sub(oxygen_sha256(salt1..data..salt2), 0, 16)
    local payload = data..'-'..signature
    local payload_b64 = base64.encode(payload)

    local url = "https://laplab.me/oxygen/#"..payload_b64
    playdate.resetElapsedTime()
    gfx.generateQRCode(url, 128, function (image, errorMessage)
        if not image then
            logError("Error generating QR code:", errorMessage)
            return
        end
        logDebug("QR code generated in", playdate.getElapsedTime(), "seconds")
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