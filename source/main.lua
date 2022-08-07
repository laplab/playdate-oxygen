import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "external/ldtk.lua"

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
	self.sprite:setCollideRect(0, 0, self.active_loop:image():getSize())
    self.sprite.collisionResponse = gfx.sprite.kCollisionTypeSlide
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

    self:switch_loop(self.idle_loop)
end

local player = Player()

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

local exit = Exit()

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

        if entity.name == "Exit" then
			-- if entity.fields.EntranceDirection == direction then
				exit:reset(entity)
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

    setup_level("Level_1")
end

init()

local conf = {
    player_max_h_speed = 150, -- m/s
    player_ground_friction = 1500, -- m/s^2

    gravity = 1000, -- m/s^2

    oxygen_max = 120,
    oxygen_usage = 5,
}

conf.jumpSpeed = math.sqrt(2 * conf.gravity * 96)

class('Oxygen').extends()

function Oxygen:init()
    self.value = conf.oxygen_max
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
        local width, height = conf.oxygen_max, 16

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
    self.value = math.max(self.value - time_diff * conf.oxygen_usage, 0)
end

local oxygen = Oxygen()

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

-- Variable jump
local jump_timer = nil

function playdate.update()
    local dt = 1 / playdate.display.getRefreshRate()

    -- Horizontal movement
    if not playdate.buttonIsPressed(playdate.kButtonLeft | playdate.kButtonRight) then
        player.velocity.x = approach(player.velocity.x, 0, conf.player_ground_friction, dt)
    end

    if playdate.buttonIsPressed(playdate.kButtonLeft) then
		player.velocity.x = -conf.player_max_h_speed
		player.flip = true
	end
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		player.velocity.x = conf.player_max_h_speed
		player.flip = false
	end

    -- Vertical movement
    -- TODO: It is possible that jump will not be registered if the button was pressed
    --       on the first frame, when the 'player.grounded == false'
    if player.grounded and playdate.buttonJustPressed(playdate.kButtonA) then
        player.velocity.y -= conf.jumpSpeed

        if jump_timer then
            jump_timer:remove()
        end
        jump_timer = playdate.timer.new(500)
    end

    if jump_timer and jump_timer.timeLeft ~= 0 and not playdate.buttonIsPressed(playdate.kButtonA) then
        if player.velocity.y < 0 then
            player.velocity.y /= 2
        end

        jump_timer:remove()
        jump_timer = nil
    end

    local gravityMultiplier = 1
    if player.velocity.y > 0 then
        gravityMultiplier = 2
    end

    player.velocity.y += conf.gravity * gravityMultiplier * dt
    -- player.velocity.y = math.min(math.max(player.velocity.y, -conf.player_max_v_speed), conf.player_max_v_speed)

    local goalX = player.sprite.x + player.velocity.x * dt
    local goalY = player.sprite.y + player.velocity.y * dt

	local actualX, actualY, collisions, length = player.sprite:moveWithCollisions(goalX, goalY)

    player.grounded = false
    for index, value in ipairs(collisions) do
        -- Normal vector values:
        --  (-1, 0) => Wall on the right
        --  (1, 0)  => Wall on the left
        --  (0, -1) => Touching floor
        --  (0, 1)  => Touching ceiling

        if value.normal.x ~= 0 then
            player.velocity.x = 0
        end

        if value.normal.y ~= 0 then
            player.velocity.y = 0
            player.grounded = value.normal.y < 0
        end
    end

    -- Follow camera
    local screen_width, screen_height = playdate.display.getSize()
    local player_width, player_height = player.sprite:getSize()
    local camera_x = screen_width / 2 - player.sprite.x - player_width / 2
    local camera_y = screen_height * 3 / 4 - player.sprite.y - player_height / 2
    gfx.setDrawOffset(camera_x, camera_y)

    -- Oxygen
    oxygen:tick(dt)

    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.sprite.update()

    playdate.timer.updateTimers()
    playdate.drawFPS(370, 10)
end