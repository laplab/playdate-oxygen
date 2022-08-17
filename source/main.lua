import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

import "external/roomy"
import "scenes/gameplay"

import "balance"

local gfx <const> = playdate.graphics

local manager = Manager()

function init()
    manager:hook()
    manager:push(Gameplay())
end

init()

function playdate.update()
    manager:emit('update')

    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.sprite.update()
    playdate.timer.updateTimers()

    if DEBUG then
        playdate.drawFPS(370, 10)
    end
end