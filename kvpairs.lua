--
-- Copyright (C) 2022 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
local format = string.format
local next = next
local pairs = pairs
local type = type

--- copy_values
--- @param self kvpairs
--- @param list any[]
--- @param vals string|string[]|nil
--- @return boolean ok
--- @return any err
local function copy_values(self, list, vals)
    if vals == nil then
        return false
    elseif type(vals) == 'table' then
        local n = #list
        for i = 1, #vals do
            local v = vals[i]
            local ok, err = self:is_valid_value(v)
            if err then
                return false, format('val#%d is not valid value: %s', i, err)
            elseif ok then
                list[n + i] = v
            end
        end
        return #list > n
    end

    local ok, err = self:is_valid_value(vals)
    if ok then
        list[#list + 1] = vals
        return true
    end

    return false, err
end

--- @class kvpairs
--- @field dict table
local KVPairs = {}

--- init
--- @param vals table|nil
--- @return kvpairs
function KVPairs:init(vals)
    local dict = {}

    -- set initial values
    if vals ~= nil then
        if type(vals) ~= 'table' then
            error('vals must be table', 2)
        end

        for key, val in pairs(vals) do
            -- use only string keys
            local ok, err = self:is_valid_key(key)
            if err then
                error(err, 2)
            elseif ok then
                local list = {}
                ok, err = copy_values(self, list, val)
                if err then
                    error(format('invalid value for key: %s', err), 2)
                elseif ok then
                    dict[key] = list
                end
            end
        end
    end

    self.dict = dict
    return self
end

--- is_valid_key
--- @param k any
--- @return boolean ok
--- @return any err
function KVPairs:is_valid_key(k)
    if type(k) == 'string' then
        return true
    end
    return false, 'key must be string'
end

--- is_valid_value
--- @param v any
--- @return boolean ok
--- @return any err
function KVPairs:is_valid_value(v)
    if type(v) == 'string' then
        return true
    end
    return false, 'value must be string'
end

--- set
--- @param key string
--- @param val string
--- @return boolean ok
function KVPairs:set(key, val)
    local ok, err = self:is_valid_key(key)
    if err then
        error(err, 2)
    elseif not ok then
        return false
    elseif val == nil then
        -- remove key
        if self.dict[key] then
            self.dict[key] = nil
            return true
        end
        return false
    end

    local list = {}
    ok, err = copy_values(self, list, val)
    if err then
        error(format('invalid value for key: %s', err), 2)
    elseif ok then
        self.dict[key] = list
        return true
    end
    return false
end

--- add
--- @param key string
--- @param val string|string[]|nil
--- @return boolean ok
function KVPairs:add(key, val)
    local ok, err = self:is_valid_key(key)
    if err then
        error(err, 2)
    elseif not ok then
        return false
    end

    local list = self.dict[key] or {}
    ok, err = copy_values(self, list, val)
    if err then
        error(format('invalid value for key: %s', err), 2)
    elseif ok then
        self.dict[key] = list
        return true
    end
    return false
end

--- get
--- @param key string
--- @param all boolean|nil
--- @return string|nil val
function KVPairs:get(key, all)
    local ok, err = self:is_valid_key(key)
    if err then
        error(err, 2)
    elseif all ~= nil and type(all) ~= 'boolean' then
        error('all must be boolean', 2)
    elseif ok then
        if all then
            return self.dict[key]
        end
        local list = self.dict[key]
        return list and list[1] or nil
    end
end

--- pairs
--- @return function next
function KVPairs:pairs()
    local dict = self.dict
    local key, list = next(dict)
    local idx = 0

    return function()
        repeat
            if list then
                idx = idx + 1
                local val = list[idx]
                if val then
                    return key, val, idx
                end
                idx = 0
            end
            key, list = next(dict, key)
        until key == nil
    end
end

return {
    new = require('metamodule').new(KVPairs),
}

