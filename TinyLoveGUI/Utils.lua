local Utils = {}


--- usage:
---     local popup = PopupMessage({x=x, y=y, width=width, height=height, message=message, duration=duration})
---     popup = Utils.observable(popup, "timeLeft", function(key, oldValue, newValue)
---         print("width changed to", newValue)
---     end)
---     context:addChild(popup)

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
                    print(string.format("changed: %s from %s to %s", key, tostring(oldValue), tostring(value)))
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

function Utils.print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end



return Utils