import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"
import "CoreLibs/timer"

function move_player_with_collisions(player, dt)
    local goalX = player.sprite.x + player.velocity.x * dt
    local goalY = player.sprite.y + player.velocity.y * dt

	local actualX, actualY, collisions, length = player.sprite:moveWithCollisions(goalX, goalY)

    player.grounded = false
    player.attached_left = false
    player.attached_right = false
    for index, value in ipairs(collisions) do
        -- Normal vector values:
        --  (-1, 0) => Wall on the right
        --  (1, 0)  => Wall on the left
        --  (0, -1) => Touching floor
        --  (0, 1)  => Touching ceiling

        if value.other:getTag() == EXIT_TAG then
            player.reached_exit = true
            goto continue
        end

        if value.normal.x ~= 0 then
            player.velocity.x = 0
            player.velocity.y = 0
            player.attached_left = value.normal.x > 0
            player.attached_right = value.normal.x < 0
        end

        if value.normal.y ~= 0 then
            player.velocity.y = 0
            player.grounded = value.normal.y < 0
        end

        ::continue::
    end
end