import "CoreLibs/object"

class("Reactor").extends()

function Reactor:init()
end

function Reactor:get_sequence()
    return self.sequence
end

function Reactor:set_sequence(sequence)
    assert(not self.sequence)
    self.sequence = coroutine.create(sequence)
end

function Reactor:progress()
    if not self.sequence then
        return
    end

    if coroutine.status(self.sequence) == "dead" then
        self.sequence = nil
        return
    end

    coroutine.resume(self.sequence)
end