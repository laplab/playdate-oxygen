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