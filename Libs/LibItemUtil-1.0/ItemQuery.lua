local lib = LibStub("LibItemUtil-1.0", true)
local Logging = LibStub("LibLogging-1.0", true)
local Util = LibStub("LibUtil-1.1", true)
local unpack = table.unpack

-- Make a frame for our repeating calls to GetItemInfo.
lib.query_frame = lib.query_frame or CreateFrame("Frame", "LibItemUtil-1.0_ItemQueryFrame")
local query_frame = lib.query_frame
query_frame:Hide()
query_frame:SetScript('OnUpdate', nil)
query_frame:UnregisterAllEvents()

local itemQueue = { }

function lib:OnEvent(event, ...)
    Logging:Trace("OnEvent(%s) - %s", event, type(self[event]))
    if type(self[event]) == 'function' then
        self[event](self, event, ...)
    end
end

function OnError(err)
    Logging:Error("%s", err)
end

function lib:GET_ITEM_INFO_RECEIVED(event, item, success)
    Logging:Trace("GET_ITEM_INFO_RECEIVED(%s) : success=%s", tostring(item), tostring(success))
    if success then
        item_id = tonumber(item)
        callback_fn = itemQueue[item_id]

        if callback_fn then
            Logging:Trace("GET_ITEM_INFO_RECEIVED(%s) : invoking callback", tostring(item))
            local result = xpcall(callback_fn, OnError)
            Logging:Trace("GET_ITEM_INFO_RECEIVED(%s) : callback result %s", tostring(item), tostring(result))
            itemQueue[item_id] = nil
        end
    end

    Logging:Trace("GET_ITEM_INFO_RECEIVED() - Awaiting %s results", tostring(Util.Tables.Count(itemQueue)))

    if Util.Tables.Count(itemQueue) == 0 then
        Logging:Trace("GetItemInfo : UnregisterEvent GET_ITEM_INFO_RECEIVED")
        query_frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
    end
end

query_frame:SetScript("OnEvent", function(frame, ...) lib:OnEvent(...) end)


function lib:GetItemInfo(id, callback)
    if type(id) == 'string' and strmatch(id, 'item:(%d+)')  then
        id = lib:ItemLinkToId(id)
    end

    if type(callback) ~= "function" then
        error("Usage: GetItemInfo(id, callback, [...]): 'callback' - function", 2)
    end

    id = tonumber(id)

    itemQueue[id] = callback
    if Util.Tables.Count(itemQueue) > 0 and not query_frame:IsEventRegistered("GET_ITEM_INFO_RECEIVED") then
        Logging:Trace("GetItemInfo : Registering GET_ITEM_INFO_RECEIVED")
        query_frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    end
end
