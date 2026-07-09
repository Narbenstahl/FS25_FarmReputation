FRDebug = {}

FRDebug.enabled = false

function FRDebug.log(text)

    if FRDebug.enabled then
        print("[FarmReputation] " .. tostring(text))
    end

end