local pl = require('pl.path')
local this = pl.abspath(pl.abspath('.') .. '/' .. debug.getinfo(1).source:match("@(.*)$"))

local itemUtil
describe("LibItemUtil", function()
    setup(function()
        loadfile('LibItemUtilTestData.lua')()
        _G.LibItemUtil_Testing = true
        loadfile(pl.abspath(pl.abspath('.') .. '/../../../Test/TestSetup.lua'))(this, {})
        itemUtil, _ = LibStub('LibItemUtil-1.0')
    end)
    teardown(function()
        _G.LibItemUtil_Testing = nil
    end)
    describe("item ids", function()
        it("resolved from item links", function()
            id = itemUtil:ItemLinkToId("|cff9d9d9d|Hitem:7073::::::::::::|h[Broken Fang]|h|r")
            assert.equals(id, 7073)
        end)
        it("resolve whether a class can use", function()
            assert.is.True(itemUtil:ClassCanUse("ROGUE", 18832))
            assert.is.Not.True(itemUtil:ClassCanUse("DRUID", 18832))
        end)
        it("resolve to item info", function()
            id = itemUtil:QueryItemInfo(18832, function() assert.is_true(true) end)
        end)
    end)
    describe("custom items", function()
        it("is empty upon loading", function()
            assert.equal(0, GetSize(itemUtil:GetCustomItems()))
        end)
        it("can be supplied", function()
            itemUtil:SetCustomItems(TestCustomItems)
            assert.equal(4, GetSize(itemUtil:GetCustomItems()))
        end)
        it("can be added", function()
            itemUtil:SetCustomItems({})
            assert.equal(0, GetSize(itemUtil:GetCustomItems()))
            itemUtil:AddCustomItem(18422, 4, 74, "INVTYPE_NECK", "Horde")
            assert.equal(1, GetSize(itemUtil:GetCustomItems()))
            itemUtil:AddCustomItem(20928, 4, 78, "INVTYPE_SHOULDER")
            assert.equal(2, GetSize(itemUtil:GetCustomItems()))
        end)
        it("can be removed", function()
            itemUtil:SetCustomItems({})
            itemUtil:AddCustomItem(18422, 4, 74, "INVTYPE_NECK", "Horde")
            itemUtil:AddCustomItem(20928, 4, 78, "INVTYPE_SHOULDER")
            assert.equal(2, GetSize(itemUtil:GetCustomItems()),
                    "Expected custom item count incorrect"
            )
            itemUtil:RemoveCustomItem(18422)
            assert.equal(1, GetSize(itemUtil:GetCustomItems()),
                    "Expected custom item count incorrect"
            )
        end)
    end)
end)
