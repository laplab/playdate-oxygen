import "CoreLibs/timer"

import "physics/util"
import "balance"

local jump_timer = nil

function update_player_velocity(player, dt)
    -- Horizontal movement
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

    player.velocity.y += GRAVITY * gravityMultiplier * dt
    -- player.velocity.y = math.min(math.max(player.velocity.y, -conf.player_max_v_speed), conf.player_max_v_speed)
end