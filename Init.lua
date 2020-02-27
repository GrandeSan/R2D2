-- name : The name of your addon as set in the TOC and folder name
-- name : The shared addon table between the Lua files of an addon
local _G = _G
local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')

local AddOnName, AddOn = ...
R2D2 = AceAddon:NewAddon(AddOn, AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
R2D2:SetDefaultModuleState(false)
-- Basic options container for augmentation by other modules
R2D2.Options = {
    name = AddOnName,
    type = 'group',
    childGroups = 'tab',
    handler = self,
    args = {}
}
R2D2.version = GetAddOnMetadata(AddOnName, "Version")

-- Shim for determining locale for localization
do
    local locale = GetLocale()
    local convert = {enGB = 'enUS'}
    local gameLocale = convert[locale] or locale or 'enUS'

    function R2D2:GetLocale()
        return gameLocale
    end
end

do
    R2D2.Libs = {}
    R2D2.LibsMinor = {}

    function R2D2:AddLib(name, major, minor)
        if not name then return end

        -- in this case: `major` is the lib table and `minor` is the minor version
        if type(major) == 'table' and type(minor) == 'number' then
            self.Libs[name], self.LibsMinor[name] = major, minor
        else -- in this case: `major` is the lib name and `minor` is the silent switch
            self.Libs[name], self.LibsMinor[name] = LibStub(major, minor)
        end
    end

    R2D2:AddLib('AceAddon', AceAddon, AceAddonMinor)
    R2D2:AddLib('AceDB', 'AceDB-3.0')
    R2D2:AddLib('AceLocale', 'AceLocale-3.0')
    R2D2:AddLib('AceGUI', 'AceGUI-3.0')
    R2D2:AddLib('AceConfig', 'AceConfig-3.0')
    R2D2:AddLib('AceConfigDialog', 'AceConfigDialog-3.0')
    R2D2:AddLib('AceConfigRegistry', 'AceConfigRegistry-3.0')
    R2D2:AddLib('Logging', 'LibLogging-1.0')
    R2D2:AddLib('GearPoints', 'LibGearPoints-1.2')
    R2D2:AddLib('ItemUtil', 'LibItemUtil-1.0')
end

AddOn.components            = {}
AddOn.components.Locale     = R2D2.Libs.AceLocale:GetLocale("R2D2")
AddOn.components.Logging    = R2D2.Libs.Logging

local Logging = AddOn.components.Logging

-- Establish a prototype for mixing into any add-on modules
-- These are used for the configuration UI
local ModulePrototype = {
    IsDisabled = function (self, i)
        Logging:Trace("Module:IsDisabled(%s) : %s", self:GetName(), tostring(not self:IsEnabled()))
        return not self:IsEnabled()
    end,
    SetEnabled = function (self, i, v)
        if v then
            Logging:Trace("Module:SetEnabled(%s) : Enabling module", self:GetName())
            self:Enable()
        else
            Logging:Trace("Module:SetEnabled(%s) : Disabling module ", self:GetName())
            self:Disable()
        end
        self.db.profile.enabled = v
        Logging:Trace("Module:SetEnabled(%s) : %s", self:GetName(), tostring(self.db.profile.enabled))
    end,
    GetDbValue = function (self, i)
        Logging:Trace("Module:GetDbValue(%s, %s)", self:GetName(), tostring(i[#i]))
        return self.db.profile[i[#i]]
    end,
    SetDbValue = function (self, i, v)
        Logging:Trace("Module:SetDbValue(%s, %s, %s)", self:GetName(), tostring(i[#i]), tostring(v or 'nil'))
        self.db.profile[i[#i]] = v
    end,
}
R2D2:SetDefaultModulePrototype(ModulePrototype)