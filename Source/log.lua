import "balance"

function logDebug(...)
    if DEBUG then
        print("[Debug]", ...)
    end
end

function logError(...)
    print("[Error]", ...)
end