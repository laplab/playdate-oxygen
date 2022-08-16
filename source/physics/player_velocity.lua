import "CoreLibs/timer"

import "physics/util"
import "balance"

local jump_timer = nil
local wall_jump_cooldown_timer = nil

function compute_horizontal_velocity(player, current_vx, dt)
    -- Player horizontal movement is disabled for a split second
    -- after the wall jump to make some distance from the wall.
    local can_move = not wall_jump_cooldown_timer or wall_jump_cooldown_timer.timeLeft == 0

    -- INPUT LEFT
    if can_move and playdate.buttonIsPressed(playdate.kButtonLeft) then
        player.flip = true

        if player.attached_left then
            -- If the player is attached to a wall, they cannot move.
            return 0
        else
            -- Otherwise, apply max horizontal speed.
            return -PLAYER_MAX_H_SPEED
        end

    -- INPUT RIGHT
    elseif can_move and playdate.buttonIsPressed(playdate.kButtonRight) then
        player.flip = false

        if player.attached_right then
            -- If the player is attached to a wall, they cannot move.
            return 0
        else
            -- Otherwise, apply max horizontal speed.
            return PLAYER_MAX_H_SPEED
        end

    -- NO HORIZONTAL INPUT
    -- Apply ground friction.
    else
        return approach(current_vx, 0, PLAYER_GROUND_FRICTION, dt)
    end
end

function compute_vertical_velocity(player, current_vy, dt)
    -- GROUND JUMP START
    -- TODO: It is possible that jump will not be registered if the button was pressed
    --       on the first frame, when the 'player.grounded == false'
    if player.grounded and playdate.buttonJustPressed(playdate.kButtonA) then
        jump_timer = playdate.timer.new(GROUND_JUMP_MAX_TIME)

        return nil, current_vy - JUMP_SPEED

    -- GROUND JUMP INTERRUPTED
    elseif jump_timer and jump_timer.timeLeft ~= 0 and not playdate.buttonIsPressed(playdate.kButtonA) then
        jump_timer:remove()
        jump_timer = nil

        if current_vy < 0 then
            current_vy /= 2
        end

        return nil, current_vy

    -- WALL JUMP
    elseif (player.attached_left or player.attached_right) and playdate.buttonJustPressed(playdate.kButtonA) then
        local attach_sign = 1
        if player.attached_right then
            attach_sign = -1
        end

        wall_jump_cooldown_timer = playdate.timer.new(WALL_JUMP_COOLDOWN_TIME)

        return 3 * attach_sign * PLAYER_MAX_H_SPEED, current_vy - JUMP_SPEED

    -- APPLY GRAVITY
    elseif not player.grounded then
        if player.attached_left or player.attached_right then
            -- Player attached to the wall freezes.
            return nil, 0
        else
            local gravityMultiplier = 1
            if current_vy > 0 then
                gravityMultiplier = 2
            end

            return nil, current_vy + GRAVITY * gravityMultiplier * dt
        end

    -- NO CHANGE TO VERTICAL SPEED
    else
        return nil, current_vy
    end
end

function compute_velocity_vector(player, current_vx, current_vy, dt)
    local vx = compute_horizontal_velocity(player, current_vx, dt)
    local optional_vx, vy = compute_vertical_velocity(player, current_vy, dt)
    if optional_vx then
        vx = optional_vx
    end
    return vx, vy
end

function update_player_velocity(player, dt)
    -- If player touches any surface, current jump is immediately finished.
    if player.grounded or player.attached_left or player.attached_right then
        if jump_timer then
            jump_timer:remove()
            jump_timer = nil
        end

        if wall_jump_cooldown_timer then
            wall_jump_cooldown_timer:remove()
            wall_jump_cooldown_timer = nil
        end
    end

    player.velocity.x, player.velocity.y = compute_velocity_vector(player, player.velocity.x, player.velocity.y, dt)
end