local MAJOR_VERSION = "LibUtil-1.1"
local MINOR_VERSION = 11303

local lib, _ = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

-- Modules
local Modules = {
    tables = "Tables",
    strings = "Strings",
    numbers = "Numbers",
    objects = "Objects",
    ["functions"] = "Functions",
}

local Module = {
    __call = function (self, ...)
        return self.New(...)
    end
}

for _, mod in pairs(Modules) do
    lib[mod] = setmetatable({}, Module)
end

-- Chaining
local Resolve = function (self, ...)
    local obj, mod = rawget(self, "obj"), rawget(self, "mod")
    local key, val = rawget(self, "key"), rawget(self, "val")

    mod = mod or Modules[type(val)]
    obj = mod and obj[mod] or obj

    self.val = obj[key](val, ...)
    self.key, self.mod = nil, nil

    return self
end


local Chain = {
    __index = function (self, key)
        if rawget(self.obj, key) then
            self.mod = key
            return self
        else
            self.key = key
            return Resolve
        end
    end,
    __call = function (self, key)
        local val = rawget(self, "val")
        if key ~= nil then
            val = val[key]
        end
        self.obj.Tables.Release(self)
        return val
    end
}

-- Metatable
local Meta = {
    __index = lib.Objects,
    __call = function (self, val)
        local chain = setmetatable(self.Tables.New(), Chain)
        chain.obj, chain.key, chain.val = self, nil, val
        return chain
    end
}

setmetatable(lib, Meta)
lib.__index = lib
lib.__call = Meta.__call