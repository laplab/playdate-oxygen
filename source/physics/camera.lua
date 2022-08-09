import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

function update_follow_camera(player)
    local screen_width, screen_height = playdate.display.getSize()
    local player_width, player_height = player.sprite:getSize()
    local camera_x = screen_width / 2 - player.sprite.x - player_width / 2
    local camera_y = screen_height / 2 - player.sprite.y - player_height / 2
    gfx.setDrawOffset(camera_x, camera_y)
end