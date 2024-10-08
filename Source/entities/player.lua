import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"

import "balance"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

class('Player').extends()

function Player:init()
    self.idle_loop = gfx.animation.loop.new(
        500, -- 2 FPS
        gfx.imagetable.new("images/player-idle"),
        true
    )
    self.walk_loop = gfx.animation.loop.new(
        250, -- 4 FPS
        gfx.imagetable.new("images/player-walk"),
        true
    )
    self.jump_up_image = gfx.image.new("images/player-jump-up")
    self.active_loop = self.idle_loop

    self.sprite = gfx.sprite.new()
	self.sprite:setCollideRect(2, 0, 30, 32)
    self.sprite.collisionResponse = function(spriteSelf, other)
        if other:getTag() == EXIT_TAG then
            return gfx.sprite.kCollisionTypeOverlap
        end
        return gfx.sprite.kCollisionTypeSlide
    end
    self.sprite.update = function(spriteSelf)
        local image = nil

        if self.grounded then
            if self.velocity.x == 0 then
                self:switch_loop(self.idle_loop)
            else
                self:switch_loop(self.walk_loop)
            end
            image = self.active_loop:image()
        else
            image = self.jump_up_image
        end

        spriteSelf:setImage(image)
        if self.flip then
            spriteSelf:setImageFlip(gfx.kImageFlippedX)
        else
            spriteSelf:setImageFlip(gfx.kImageUnflipped)
        end
    end
end

function Player:switch_loop(to)
    if to == self.active_loop then
        return
    end

    self.active_loop.paused = true
    self.active_loop.frame = 1

    self.active_loop = to
    self.active_loop.paused = false
end

function Player:reset(entity)
    local sprite = self.sprite
    sprite:setZIndex(entity.zIndex)
	sprite:moveTo(entity.position.x, entity.position.y)
	sprite:setCenter(entity.center.x, entity.center.y)
    sprite:add()

	self.velocity = geom.vector2D.new(0, 0)
    self.flip = false
    self.grounded = false
    self.reached_exit = false
    self.attached_left = false
    self.attached_right = false

    self:switch_loop(self.idle_loop)
end