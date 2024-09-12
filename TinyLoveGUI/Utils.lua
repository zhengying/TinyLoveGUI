local Utils = {}

function Utils.makeObservable(instance, options)
    options = options or {}
    local proxy = {}
    local mt = {
        __index = function(_, key)
            return instance[key]
        end,
        
        __newindex = function(_, key, value)
            local oldValue = instance[key]
            instance[key] = value
            if options.onChange then
                if options.logAccess then
                    print(string.format("TreeView changed: %s from %s to %s", key, tostring(oldValue), tostring(value)))
                end
                options.onChange(key, value, oldValue)
            end
        end
    }
    
    -- Preserve metamethods and make functions callable
    local instanceMT = getmetatable(instance)
    if instanceMT then
        for k, v in pairs(instanceMT) do
            if k ~= "__index" and k ~= "__newindex" then
                mt[k] = v
            end
        end
    end
    
    setmetatable(proxy, mt)
    
    -- Make functions callable through the proxy
    return setmetatable({}, {
        __index = proxy,
        __newindex = mt.__newindex,
        __call = function(_, ...)
            if type(instance) == "function" then
                return instance(...)
            elseif instanceMT and instanceMT.__call then
                return instanceMT.__call(instance, ...)
            end
        end
    })
end


function Utils.observable(t, listenkey, callback)
    local t = Utils.makeObservable(t, {
        onChange = function(key, newValue, oldValue)
            if listenkey == key  then
                callback(key, oldValue, newValue)
            end
        end,
        logAccess = true
    })
    return t
end



return Utils