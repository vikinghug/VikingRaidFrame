require "Window"

local VikingRaidFrameMasterLoot = {}

function VikingRaidFrameMasterLoot:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function VikingRaidFrameMasterLoot:Init()
    Apollo.RegisterAddon(self)
end

function VikingRaidFrameMasterLoot:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("VikingRaidFrameMasterLoot.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self) 
end

function VikingRaidFrameMasterLoot:OnDocumentReady()
	if  self.xmlDoc == nil then
		return
	end
	Apollo.RegisterEventHandler("GenericEvent_Raid_ToggleMasterLoot", "Initialize", self)
end

function VikingRaidFrameMasterLoot:Initialize(bShow)
	if self.wndMain and self.wndMain:IsValid() then
		self.wndMain:Destroy()
	end

	if not bShow then
		return
	end

	self.wndMain = Apollo.LoadForm(self.xmlDoc, "VikingRaidFrameMasterLootForm", nil, self)
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = Apollo.GetString("Group_MasterLoot")})
	
	self.wndMain:SetSizingMinimum(self.wndMain:GetWidth(), self.wndMain:GetHeight())
	self.wndMain:SetSizingMaximum(self.wndMain:GetWidth(), 1000)
	
	self:InitializeGroupSettings()
end

-----------------------------------------------------------------------------------------------
-- Group Options
-----------------------------------------------------------------------------------------------

function VikingRaidFrameMasterLoot:InitializeGroupSettings()
	local tLootRules = GroupLib.GetLootRules()

	local tUnderMapping =
	{
		[GroupLib.LootRule.Master] 				= "UnderThresMasterBtn",
		[GroupLib.LootRule.RoundRobin] 			= "UnderThresRRBtn",
		[GroupLib.LootRule.FreeForAll] 			= "UnderThresFFABtn",
		[GroupLib.LootRule.NeedBeforeGreed] 	= "UnderThresNvGBtn",
	}

	local tOverMapping =
	{
		[GroupLib.LootRule.Master] 				= "OverThresMasterBtn",
		[GroupLib.LootRule.RoundRobin] 			= "OverThresRRBtn",
		[GroupLib.LootRule.FreeForAll] 			= "OverThresFFABtn",
		[GroupLib.LootRule.NeedBeforeGreed] 	= "OverThresNvGBtn",
	}

	local tHarvestMapping =
	{
		[GroupLib.HarvestLootRule.RoundRobin]  	= "HarvestThresRRBtn",
		[GroupLib.HarvestLootRule.FirstTagger] 	= "HarvestThresFFABtn",
	}

	local tItemMapping =
	{
		[Item.CodeEnumItemQuality.Inferior] 	= 1,
		[Item.CodeEnumItemQuality.Average] 		= 1,
		[Item.CodeEnumItemQuality.Good] 		= 2,
		[Item.CodeEnumItemQuality.Excellent] 	= 3,
		[Item.CodeEnumItemQuality.Superb] 		= 4,
		[Item.CodeEnumItemQuality.Legendary] 	= 5,
		[Item.CodeEnumItemQuality.Artifact] 	= 6
	}

	if tUnderMapping[tLootRules.eNormalRule] then
		self.wndMain:FindChild(tUnderMapping[tLootRules.eNormalRule]):SetCheck(true)
	end

	if tOverMapping[tLootRules.eThresholdRule] then
		self.wndMain:FindChild(tOverMapping[tLootRules.eThresholdRule]):SetCheck(true)
	end

	if tHarvestMapping[tLootRules.eHarvestRule] then
		self.wndMain:FindChild(tHarvestMapping[tLootRules.eHarvestRule]):SetCheck(true)
	end

	for eValue, nIdx in pairs(tItemMapping) do
		if eValue == tLootRules.eThresholdQuality then
			self.wndMain:FindChild("ItemThresBtn"..nIdx):SetCheck(true)
		end
	end
end

function VikingRaidFrameMasterLoot:OnSetLootUnderThresCheck(wndHandler, wndControl)
	local tLootRules =
	{
		["UnderThresMasterBtn"] = GroupLib.LootRule.Master,
		["UnderThresNvGBtn"] 	= GroupLib.LootRule.NeedBeforeGreed,
		["UnderThresRRBtn"] 	= GroupLib.LootRule.RoundRobin,
		["UnderThresFFABtn"] 	= GroupLib.LootRule.FreeForAll,
	}

	if tLootRules[wndHandler:GetName()] then
		local tCurrRules = GroupLib.GetLootRules()
		GroupLib.SetLootRules(tLootRules[wndHandler:GetName()], tCurrRules.eThresholdRule, tCurrRules.eThresholdQuality, tCurrRules.eHarvestRule)
	end
end

function VikingRaidFrameMasterLoot:OnSetLootOverThresCheck(wndHandler, wndControl)
	local tLootRules =
	{
		["OverThresMasterBtn"] 	= GroupLib.LootRule.Master,
		["OverThresNvGBtn"] 	= GroupLib.LootRule.NeedBeforeGreed,
		["OverThresRRBtn"] 		= GroupLib.LootRule.RoundRobin,
		["OverThresFFABtn"] 	= GroupLib.LootRule.FreeForAll,
	}

	if tLootRules[wndHandler:GetName()] then
		local tCurrRules = GroupLib.GetLootRules()
		GroupLib.SetLootRules(tCurrRules.eNormalRule, tLootRules[wndHandler:GetName()], tCurrRules.eThresholdQuality, tCurrRules.eHarvestRule)
	end
end

function VikingRaidFrameMasterLoot:OnSetHarvestRulesCheck(wndHandler, wndControl)
	local tLootRules =
	{
		["HarvestThresRRBtn"] 	= GroupLib.HarvestLootRule.RoundRobin,
		["HarvestThresFFABtn"] 	= GroupLib.HarvestLootRule.FirstTagger,
	}

	if tLootRules[wndHandler:GetName()] then
		local tCurrRules = GroupLib.GetLootRules()
		GroupLib.SetLootRules(tCurrRules.eNormalRule, tCurrRules.eThresholdRule, tCurrRules.eThresholdQuality, tLootRules[wndHandler:GetName()])
	end
end

function VikingRaidFrameMasterLoot:OnSetLootItemThresCheck(wndHandler, wndControl)
	local tItemMapping =
	{
		["ItemThresBtn1"] = Item.CodeEnumItemQuality.Average,
		["ItemThresBtn2"] = Item.CodeEnumItemQuality.Good,
		["ItemThresBtn3"] = Item.CodeEnumItemQuality.Excellent,
		["ItemThresBtn4"] = Item.CodeEnumItemQuality.Superb,
		["ItemThresBtn5"] = Item.CodeEnumItemQuality.Legendary,
		["ItemThresBtn6"] = Item.CodeEnumItemQuality.Artifact
	}

	if tItemMapping[wndHandler:GetName()] then
		local tCurrRules = GroupLib.GetLootRules()
		GroupLib.SetLootRules(tCurrRules.eNormalRule, tCurrRules.eThresholdRule, tItemMapping[wndHandler:GetName()], tCurrRules.eHarvestRule)
	end
end

-----------------------------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------------------------

function VikingRaidFrameMasterLoot:OnOptionsCloseBtn()
	if self.wndMain and self.wndMain:IsValid() then
		self.wndMain:Destroy()
		Event_FireGenericEvent("GenericEvent_Raid_UncheckMasterLoot")
	end
end

function VikingRaidFrameMasterLoot:FactoryProduce(wndParent, strFormName, tObject)
	local wndNew = wndParent:FindChildByUserData(tObject)
	if not wndNew then
		wndNew = Apollo.LoadForm(self.xmlDoc, strFormName, wndParent, self)
		wndNew:SetData(tObject)
	end
	return wndNew
end

local VikingRaidFrameMasterLootInst = VikingRaidFrameMasterLoot:new()
VikingRaidFrameMasterLootInst:Init()
