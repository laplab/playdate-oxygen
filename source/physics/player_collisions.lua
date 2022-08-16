-- Normal vector values:
--  (-1, 0) => Wall on the right
--  (1, 0)  => Wall on the left
--  (0, -1) => Touching floor
--  (0, 1)  => Touching ceiling
function collides_x(collision) return collision.normal.x ~= 0 end
function collides_right(collision) return collision.normal.x < 0 end
function collides_left(collision) return collision.normal.x > 0 end

function collides_y(collision) return collision.normal.y ~= 0 end
function collides_top(collision) return collision.normal.y > 0 end
function collides_bottom(collision) return collision.normal.y < 0 end

-- Must be called only once
function handle_player_bumps(player, collisions)
    for _, c in ipairs(collisions) do
        if c.other:getTag() == EXIT_TAG then
            player.reached_exit = true
            -- Exit should not be registered as a wall collision.
            goto continue
        end

        if collides_x(c) then
            player.velocity.x = 0
            player.velocity.y = 0
        end

        if collides_y(c) then
            player.velocity.y = 0
        end

        if playdate.buttonIsPressed(playdate.kButtonLeft) and collides_left(c) then
            player.attached_left = true
        end

        if playdate.buttonIsPressed(playdate.kButtonRight) and collides_right(c) then
            player.attached_right = true
        end

        ::continue::
    end
end

function handle_player_touches(player)
    local touches_bottom = false
    local touches_top = false
    local touches_left = false
    local touches_right = false

    local directions = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
    for _, direction in ipairs(directions) do
        local touchX = player.sprite.x + direction[1]
        local touchY = player.sprite.y + direction[2]

        local _, _, touches, _ = player.sprite:checkCollisions(touchX, touchY)
        for _, c in ipairs(touches) do
            if collides_left(c) then
                touches_left = true
            end

            if collides_right(c) then
                touches_right = true
            end

            if collides_bottom(c) then
                touches_bottom = true
            end

            if collides_top(c) then
                touches_top = true
            end
        end
    end

    player.grounded = false
    if touches_bottom then
        player.grounded = true
        player.attached_left = false
        player.attached_right = false
    end

    if not touches_left then
        player.attached_left = false
    end

    if not touches_right then
        player.attached_right = false
    end
end