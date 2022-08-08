# lua-kvpairs

[![test](https://github.com/mah0x211/lua-kvpairs/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-kvpairs/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-kvpairs/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-kvpairs)


helper module for treating tables as Key-Value pairs.


```sh
luarocks install kvpairs
```

## Usage

```lua
local print = require('print')

local kvpairs = require('kvpairs')

-- create key-value pairs
local kvp = kvpairs.new({
    foo = 'bar',
    qux = {
        'baa',
        'quux',
    },
})
-- get values
print(kvp:get('foo')) -- bar
print(kvp:get('qux')) -- baa
print(kvp:get('qux', true)) -- { [1] = "baa", [2] = "quux"}

-- set values
kvp:set('foo', 'replace value')
kvp:set('qux', {
    'foo',
    'bar',
})
kvp:set('hello', 'world')
print(kvp:get('foo', true)) -- { [1] = "replace value" }
print(kvp:get('qux', true)) -- { [1] = "foo", [2] = "bar" }
print(kvp:get('hello', true)) -- { [1] = "world" }

-- set nil to remove values
kvp:set('qux')
print(kvp:get('qux', true)) -- nil

-- add values
kvp:add('foo', 'add1')
kvp:add('foo', {
    'add2',
    'add3',
})
print(kvp:get('foo', true)) -- { [1] = "replace value", [2] = "add1", [3] = "add2", [4] = "add3" }

-- iterate all key-value pairs
for key, val, vidx in kvp:pairs() do
    print(key, val, vidx)
    -- hello world 1
    -- foo replace value 1
    -- foo add1 2
    -- foo add2 3
    -- foo add3 4
end
```

KVPairs can only set string keys and values.  
You can override the `is_valid_key` and `is_valid_value` methods to modify this restriction.

```lua
local print = require('print')

--- custom kvpairs
local MyKVPairs = {}

--- override is_valid_value method
--- is_valid_value
--- @param v any
--- @return boolean ok
--- @return any err
function MyKVPairs:is_valid_value(v)
    -- allow any value
    return true
end

local newMyKVPairs = require('metamodule').new.MyKVPairs(MyKVPairs, 'kvpairs')

-- create custom key-value pairs
local kvp = newMyKVPairs({
    foo = 'bar',
    qux = {
        true,
        'quux',
        123,
    },
})
-- get values
print(kvp:get('foo', true)) -- { [1] = "bar" }
print(kvp:get('qux', true)) -- { [1] = true, [2] = "quux", [3] = 123 }
```
