import "CoreLibs/timer"

import "physics/util"
import "balance"

local jump_timer = nil
local wall_jump_timer = nil

function update_player_velocity(player, dt)
    if (player.grounded or player.attached_left or player.attached_right) and wall_jump_timer then
        wall_jump_timer:remove()
        wall_jump_timer = nil
    end

    if (player.grounded or player.attached_left or player.attached_right) and jump_timer then
        jump_timer:remove()
        jump_timer = nil
    end

    -- Horizontal movement
    if not wall_jump_timer or wall_jump_timer.timeLeft == 0 then
        if not playdate.buttonIsPressed(playdate.kButtonLeft | playdate.kButtonRight) then
            player.velocity.x = approach(player.velocity.x, 0, PLAYER_GROUND_FRICTION, dt)
        end

        if playdate.buttonIsPressed(playdate.kButtonLeft) then
            player.velocity.x = -PLAYER_MAX_H_SPEED
            player.flip = true
        end
        if playdate.buttonIsPressed(playdate.kButtonRight) then
            player.velocity.x = PLAYER_MAX_H_SPEED
            player.flip = false
        end
    end

    -- Vertical movement
    -- TODO: It is possible that jump will not be registered if the button was pressed
    --       on the first frame, when the 'player.grounded == false'
    if player.grounded and playdate.buttonJustPressed(playdate.kButtonA) then
        player.velocity.y -= JUMP_SPEED

        if jump_timer then
            jump_timer:remove()
        end
        jump_timer = playdate.timer.new(500)
    end

    if jump_timer and (player.attached_left or player.attached_right) then
        jump_timer:remove()
        jump_timer = nil
    end

    if jump_timer and jump_timer.timeLeft ~= 0 and not playdate.buttonIsPressed(playdate.kButtonA) then
        if player.velocity.y < 0 then
            player.velocity.y /= 2
        end

        jump_timer:remove()
        jump_timer = nil
    end

    if (player.attached_left or player.attached_right) and playdate.buttonJustPressed(playdate.kButtonA) then
        local attach_sign = 1
        if player.attached_right then
            attach_sign = -1
        end

        player.velocity.y -= JUMP_SPEED
        player.velocity.x = attach_sign * PLAYER_MAX_H_SPEED
        wall_jump_timer = playdate.timer.new(500)
    end

    local gravityMultiplier = 1
    if player.attached_left or player.attached_right then
        gravityMultiplier = 0.25
    elseif player.velocity.y > 0 then
        gravityMultiplier = 2
    end

    player.velocity.y += GRAVITY * gravityMultiplier * dt
    -- player.velocity.y = math.min(math.max(player.velocity.y, -conf.player_max_v_speed), conf.player_max_v_speed)
end