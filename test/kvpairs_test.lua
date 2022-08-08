require('luacov')
local assert = require('assert')
local new_kvpairs = require('kvpairs').new

local testcase = {}

function testcase.new()
    -- test that create new values
    local kvp = new_kvpairs({})
    assert.match(kvp, '^kvpairs: ', false)

    -- test that create new header with initial header
    kvp = new_kvpairs({
        hello = 'world',
        foo = {
            'bar',
            'baz',
        },
    })
    assert.equal(kvp.dict, {
        hello = {
            'world',
        },
        foo = {
            'bar',
            'baz',
        },
    })

    -- test that throws an error if value argument is invald
    local err = assert.throws(new_kvpairs, 'hello')
    assert.match(err, 'vals must be table')

    -- test that throws an error if value argument contains an invalid key
    err = assert.throws(new_kvpairs, {
        [{}] = 'bar',
    })
    assert.match(err, 'key must be string')

    -- test that throws an error if value argument contains an invalid value
    err = assert.throws(new_kvpairs, {
        foo = {
            'bar',
            {},
            'baz',
        },
    })
    assert.match(err, 'val#2 is not valid value')
end

function testcase.set()
    local kvp = new_kvpairs()

    -- test that set value
    assert(kvp:set('foo', 'bar'))
    assert.equal(kvp:get('foo', true), {
        'bar',
    })

    -- test that set multiple values
    assert(kvp:set('foo', {
        'baz',
        'qux',
    }))
    -- confirm it replaces the existing value
    assert.equal(kvp:get('foo', true), {
        'baz',
        'qux',
    })

    -- test that return false if value is empty list
    assert.is_false(kvp:set('foo', {}))

    -- test that delete key if value is nil
    assert.is_true(kvp:set('foo'))
    assert.is_nil(kvp:get('foo', true))

    -- test that return false if key does not exist
    assert.is_false(kvp:set('foo'))

    -- test that throws an error if key is invalid
    local err = assert.throws(kvp.set, kvp, true)
    assert.match(err, 'key must be string')

    -- test that throws an error if val is invalid
    err = assert.throws(kvp.set, kvp, 'foo', true)
    assert.match(err, 'value must be string')
end

function testcase.add()
    local kvp = new_kvpairs()

    -- test that add key-value pairs
    assert(kvp:add('foo', 'bar'))
    assert.equal(kvp:get('foo', true), {
        'bar',
    })

    -- test that append value to existing key
    assert(kvp:add('foo', 'baz'))
    assert.equal(kvp:get('foo', true), {
        'bar',
        'baz',
    })
    assert(kvp:add('foo', {
        'qux',
        'quux',
    }))
    assert.equal(kvp:get('foo', true), {
        'bar',
        'baz',
        'qux',
        'quux',
    })

    -- test that no added any values if value is nil
    assert.is_false(kvp:add('foo'))
    assert.equal(kvp:get('foo', true), {
        'bar',
        'baz',
        'qux',
        'quux',
    })

    -- test that throws an error if key is invalid
    local err = assert.throws(kvp.add, kvp, true)
    assert.match(err, 'key must be string')

    -- test that throws an error if val is invalid
    err = assert.throws(kvp.add, kvp, 'foo', true)
    assert.match(err, 'value must be string')
end

function testcase.get()
    local kvp = new_kvpairs()
    assert(kvp:set('foo', {
        'bar',
        'baz',
    }))

    -- test that return first value
    assert.equal(kvp:get('foo'), 'bar')

    -- test that return all values if all argument is true
    assert.equal(kvp:get('foo', true), {
        'bar',
        'baz',
    })

    -- test that throws an error if key is invalid
    local err = assert.throws(kvp.get, kvp, true)
    assert.match(err, 'key must be string')

    -- test that throws an error if all is invalid
    err = assert.throws(kvp.get, kvp, 'foo', {})
    assert.match(err, 'all must be boolean')
end

function testcase.pairs()
    local kvp = new_kvpairs()
    assert(kvp:set('foo', {
        'bar',
        'baz',
    }))
    assert(kvp:set('hello', 'world'))

    -- test that iterate all pairs
    local cmp = {
        foo = {
            'bar',
            'baz',
        },
        hello = {
            'world',
        },
    }
    for key, val, vidx in kvp:pairs() do
        assert.equal(val, cmp[key][vidx])
        cmp[key][vidx] = nil
        if not next(cmp[key]) then
            cmp[key] = nil
        end
    end
    assert.is_nil(next(cmp))
end

for name, f in pairs(testcase) do
    local elapsed = os.clock()
    local ok, err = pcall(f)
    elapsed = os.clock() - elapsed
    if ok then
        print(string.format('%s .. ok (%f sec)', name, elapsed))
    else
        print(string.format('%s .. failed', name))
        print(err)
    end
end
