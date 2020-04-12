local pl = require('pl.path')
local this = pl.abspath(pl.abspath('.') .. '/' .. debug.getinfo(1).source:match("@(.*)$"))
local Loot, Util

describe("History - Loot Model", function()
    setup(function()
        loadfile(pl.abspath(pl.abspath('.') .. '/../../../Test/TestSetup.lua'))(this, {})
        R2D2:OnInitialize()
        R2D2:OnEnable()
        Loot = R2D2.components.Models.History.Loot
        Util = R2D2.Libs.Util
    end)
    
    teardown(function()
        After()
    end)
    
    describe("creation", function()
        it("from no args", function()
            local entry = Loot()
            assert(entry:FormattedTimestamp() ~= nil)
            assert(entry.id:match("(%d+)-(%d+)"))
        end)
        it("from instant", function()
            local entry = Loot(1585928063)
            assert(entry:FormattedTimestamp() == "04/03/2020 09:34:23")
            assert(entry.id:match("1585928063-(%d+)"))
        end)
    end)
    
    describe("marshalling", function()
        it("to table", function()
            local entry = Loot(1585928063)
            local asTable = entry:toTable()
            assert(asTable.timestamp == 1585928063)
            assert(asTable.version ~= nil)
            assert(asTable.version.major >= 1)
        end)
        it("from table", function()
            local entry1 = Loot(1585928063)
            local asTable = entry1:toTable()
            local entry2 = Loot():reconstitute(asTable)
            assert.equals(entry1.id, entry2.id)
            assert.equals(entry1.timestamp, entry2.timestamp)
            assert.equals(entry1.version.major, entry2.version.major)
            -- invoke to make sure class meta-data came back with reconstitute
            entry2.version:nextMajor()
            assert.equals(tostring(entry1.version), tostring(entry2.version))
        end)
    end)
end)