import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "physics/player_collisions"

function move_player(player, dt)
    local goalX = player.sprite.x + player.velocity.x * dt
    local goalY = player.sprite.y + player.velocity.y * dt

	local _, _, collisions, _ = player.sprite:moveWithCollisions(goalX, goalY)
    handle_player_bumps(player, collisions)

    handle_player_touches(player)
end