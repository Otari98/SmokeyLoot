-- TODO:
-- announce loot when opening
-- add popup confirmation
-- rework loot popup buttons (?)
-- list of your srs/hrs on login (?)
-- timer (?)

local _G = _G or getfenv(0)

local Me = UnitName("player")
local MLSearchPattern = gsub(ERR_NEW_LOOT_MASTER_S, "%%s", "(%a+)")
local RollSearchPattern = gsub(gsub(RANDOM_ROLL_RESULT, "%%s", "(.+)"), "%%d %(%%d%-%%d%)", "(%%d+) %%(%%d%%-(%%d+)%%)")
local CurrentTab = "database"

local SmokeyItemID
local SmokeySlot
local Master
local WinType
local Winner
local TmogWinner
local Pusher

local Pulling = false
local Pushing = false
local PushAfter = false

local RemoteVer = 0
local MaxEntries = 32
local WinRoll = 0
local TmogWinRoll = 0
local LowestPlus = 420
local LowestHR = 420
local LootButtonsMax = 6

local SearchResult = {}
local AlreadyRolled = {}
local MyHRItemIDs = {}

local OfficerRanks = {}
OfficerRanks["Dank Sparrow"] = true
OfficerRanks["Lieutenant Kush"] = true
OfficerRanks["Hemp Corsair"] = true

local AltRanks = {}
AltRanks["Swab Toker"] = true
AltRanks["Hemp Corsair"] = true

local ClassColors = {}
ClassColors["WARRIOR"] = "|cffc79c6e"
ClassColors["DRUID"]   = "|cffff7d0a"
ClassColors["PALADIN"] = "|cfff58cba"
ClassColors["WARLOCK"] = "|cff9482c9"
ClassColors["MAGE"]    = "|cff69ccf0"
ClassColors["PRIEST"]  = "|cffffffff"
ClassColors["ROGUE"]   = "|cfffff569"
ClassColors["HUNTER"]  = "|cffabd473"
ClassColors["SHAMAN"]  = "|cff0070de"

local BlacklistItems = {}
BlacklistItems[36551] = "Black Drake"
BlacklistItems[92080] = "Molten Corehound"
BlacklistItems[36666] = "Plagued Riding Spider"
BlacklistItems[19902] = "Swift Zulian Tiger"
BlacklistItems[19872] = "Armored Razzashi Raptor"
BlacklistItems[92082] = "Felforged Dreadhound"

local Rolls = {}
Rolls.HR = {}
Rolls.SR = {}
Rolls.MS = {}
Rolls.OS = {}
Rolls.TMOG = {}

local SmokeyAddonVersions = {}

local TmogInvTypes = {
	["INVTYPE_HEAD"] = 1,
	["INVTYPE_SHOULDER"] = 3,
	["INVTYPE_CHEST"] = 5,
	["INVTYPE_ROBE"] = 5,
	["INVTYPE_WAIST"] = 6,
	["INVTYPE_LEGS"] = 7,
	["INVTYPE_FEET"] = 8,
	["INVTYPE_WRIST"] = 9,
	["INVTYPE_HAND"] = 10,
	["INVTYPE_CLOAK"] = 15,
	["INVTYPE_WEAPONMAINHAND"] = 16,
	["INVTYPE_2HWEAPON"] = 16,
	["INVTYPE_WEAPON"] = 16,
	["INVTYPE_WEAPONOFFHAND"] = 17,
	["INVTYPE_HOLDABLE"] = 17,
	["INVTYPE_SHIELD"] = 17,
	["INVTYPE_RANGED"] = 18,
	["INVTYPE_RANGEDRIGHT"] = 18,
	["INVTYPE_TABARD"] = 19,
	["INVTYPE_BODY"] = 4,
}

local SubTypesForClass = {
	DRUID = {
		["Cloth"] = true,
		["Leather"] = true,
		["Daggers"] = true,
		["One-Handed Maces"] = true,
		["Fist Weapons"] = true,
		["Two-Handed Maces"] = true,
		["Polearms"] = true,
		["Staves"] = true,
		["Miscellaneous"] = true,
	},
	SHAMAN = {
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Daggers"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["Fist Weapons"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
		["Staves"] = true,
		["Shields"] = true,
		["Miscellaneous"] = true,
	},
	PALADIN = {
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Plate"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Swords"] = true,
		["One-Handed Maces"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Swords"] = true,
		["Two-Handed Maces"] = true,
		["Polearms"] = true,
		["Shields"] = true,
		["Miscellaneous"] = true,
	},
	MAGE = {
		["Cloth"] = true,
		["Staves"] = true,
		["Daggers"] = true,
		["One-Handed Swords"] = true,
		["Wands"] = true,
		["Miscellaneous"] = true,
	},
	WARLOCK = {
		["Cloth"] = true,
		["Staves"] = true,
		["Daggers"] = true,
		["One-Handed Swords"] = true,
		["Wands"] = true,
		["Miscellaneous"] = true,
	},
	PRIEST = {
		["Cloth"] = true,
		["Staves"] = true,
		["Daggers"] = true,
		["One-Handed Maces"] = true,
		["Wands"] = true,
		["Miscellaneous"] = true,
	},
	WARRIOR = {
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Plate"] = true,
		["Daggers"] = true,
		["Fist Weapons"] = true,
		["Staves"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Swords"] = true,
		["One-Handed Maces"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Swords"] = true,
		["Two-Handed Maces"] = true,
		["Polearms"] = true,
		["Shields"] = true,
		["Bows"] = true,
		["Guns"] = true,
		["Crossbows"] = true,
		["Miscellaneous"] = true,
	},
	ROGUE = {
		["Cloth"] = true,
		["Leather"] = true,
		["Daggers"] = true,
		["Fist Weapons"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Swords"] = true,
		["One-Handed Maces"] = true,
		["Bows"] = true,
		["Guns"] = true,
		["Crossbows"] = true,
		["Miscellaneous"] = true,
	},
	HUNTER = {
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Daggers"] = true,
		["Fist Weapons"] = true,
		["Staves"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Swords"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Swords"] = true,
		["Polearms"] = true,
		["Bows"] = true,
		["Guns"] = true,
		["Crossbows"] = true,
		["Miscellaneous"] = true,
	}
}

print = print or function(...)
	local size = getn(arg)
	for i = 1, size do
		 arg[i] = tostring(arg[i])
	end
	local msg = size > 1 and table.concat(arg, ", ") or tostring(arg[1])
	DEFAULT_CHAT_FRAME:AddMessage(msg)
	return msg
end

local function strsplit(str, delimiter)
	if not str then return {} end
	local splitresult = {}
	local from = 1
	local delim_from, delim_to = strfind(str, delimiter, from, true)
	while delim_from do
		tinsert(splitresult, strsub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = strfind(str, delimiter, from, true)
	end
	tinsert(splitresult, strsub(str, from))
	return splitresult
end

local function strtrim(s)
	return (gsub(s or "", "^%s*(.-)%s*$", "%1"))
end

local function arraywipe(arr)
	if type(arr) ~= "table" then
		return
	end
	for i = getn(arr), 1, -1 do
		tremove(arr, i)
	end
end

local function listwipe(list)
	for k in pairs(list) do
		if type(list[k]) == "table" then
			for k2 in pairs(list[k]) do
				list[k][k2] = nil
			end
		else
			list[k] = nil
		end
	end
end

local function sortfunc(a, b)
	if a.itemID and b.itemID and a.itemID == b.itemID then
		return a.bonus > b.bonus
	elseif a.item and b.item then
		return a.item < b.item
	else
		return a.char < b.char
	end
end

local function arrcontains(array, value)
	if type(array) ~= "table" then
		return
	end
	for i = 1, getn(array) do
		if type(array[i]) == "table" then
			for k in pairs(array[i]) do
				if array[i][k] == value then
					return i
				end
			end
		elseif array[i] == value then
			return i
		end
	end
	return nil
end

local IDCache = {}
function GetItemIDByName(name)
	if not name then
		return -1, UNKNOWN
	end
	if type(IDCache[name]) == "table" then
		return IDCache[name][1], IDCache[name][2]
	end
	if pfDB then
		for id, itemName in pairs(pfDB.items["enUS-turtle"]) do
			if gsub(name, "'", "") == gsub(itemName, "'", "") then
				IDCache[name] = {}
				IDCache[name][1] = id
				IDCache[name][2] = itemName
				IDCache[itemName] = IDCache[name]
				return id, itemName
			end
		end
		for id, itemName in pairs(pfDB.items.enUS) do
			if gsub(name, "'", "") == gsub(itemName, "'", "") then
				IDCache[name] = {}
				IDCache[name][1] = id
				IDCache[name][2] = itemName
				IDCache[itemName] = IDCache[name]
				return id, itemName
			end
		end
		IDCache[name] = {}
		IDCache[name][1] = -1
		IDCache[name][2] = name
		return -1, name
	end
	for itemID = 1, 99999 do
		local itemName = GetItemInfo(itemID)
		if itemName and gsub(itemName, "'", "") == gsub(name, "'", "") then
			IDCache[name] = {}
			IDCache[name][1] = itemID
			IDCache[name][2] = itemName
			IDCache[itemName] = IDCache[name]
			return itemID, itemName
		end
	end
	IDCache[name] = {}
	IDCache[name][1] = -1
	IDCache[name][2] = name
	return -1, name
end

local Tooltip = CreateFrame("GameTooltip", "SmokeyLootTooltip", nil, "GameTooltipTemplate")
Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function CacheItem(id)
	if not id then
		return
	end
	if not GetItemInfo(id) then
		GameTooltip:SetHyperlink("item:"..id)
	end
end

local TooltipRows = {}

function CanRollForTransmog(itemID)
	if not tonumber(itemID) then
		return false
	end
	local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)
	if not itemEquipLoc or not TmogInvTypes[itemEquipLoc] then
		return false
	end
	if TMOG_CACHE then
		for slot, collected in pairs(TMOG_CACHE) do
			if collected[itemID] then
				return false
			end
		end
	end
	if itemEquipLoc == "INVTYPE_HOLDABLE" then
		return true
	end
	local class, enClass = UnitClass("player")
	if not SubTypesForClass[enClass][itemSubType] then
		return false
	end
	if itemType == "Weapon" and itemSubType == "Miscellaneous" then
		return false
	end
	local canDualWeild = enClass == "WARRIOR" or enClass == "ROGUE" or enClass == "HUNTER"
	if not canDualWeild and itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then
		return false
	end
	arraywipe(TooltipRows)
	Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	Tooltip:ClearLines()
	Tooltip:SetHyperlink("item:"..itemID)
	for row = 1, 15 do
		local tooltipRowLeft = _G[Tooltip:GetName().."TextLeft" .. row]
		if tooltipRowLeft then
			local rowtext = tooltipRowLeft:GetText()
			if rowtext then
				tinsert(TooltipRows, rowtext)
			end
		end
	end
	for row = 1, getn(TooltipRows) do
		if TooltipRows[row] then
			local _, _, classesRow = strfind(TooltipRows[row], (gsub(ITEM_CLASSES_ALLOWED, "%%s", "(.*)")))
			if classesRow then
				if not strfind(classesRow, class, 1, true) then
					return false
				end
			end
		end
	end
	return true
end

local DelayFrame = CreateFrame("Frame")
local FuncQueue = {}

local function Delay(time, func)
	tinsert(FuncQueue, { executeTime = GetTime() + time, func = func })
end

DelayFrame:SetScript("OnUpdate", function()
	if not FuncQueue[1] then
		return
	end
	if GetTime() >= FuncQueue[1].executeTime then
		FuncQueue[1].func()
		tremove(FuncQueue, 1)
	end
end)

local function IsOfficer(name)
	if name == UnitName("player") then
		local _, myRank = GetGuildInfo("player")
		return OfficerRanks[myRank]
	else
		if SMOKEYLOOT.GUILD[k] and SMOKEYLOOT.GUILD[k].rankName then
			return OfficerRanks[SMOKEYLOOT.GUILD[k].rankName]
		end
	end
end

function SmokeyLootFrame_OnLoad()
	tinsert(UISpecialFrames, "SmokeyLootFrame")
	this:SetBackdropColor(0, 0, 0)
	this:RegisterForDrag("LeftButton")
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("GUILD_ROSTER_UPDATE")
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterEvent("CHAT_MSG_SYSTEM")
	this:RegisterEvent("PARTY_MEMBERS_CHANGED")
	this:RegisterEvent("PARTY_LEADER_CHANGED")
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	this:RegisterEvent("PLAYER_ENTERING_WORLD")
	this:RegisterEvent("OPEN_MASTER_LOOT_LIST")
	this:RegisterEvent("RAID_ROSTER_UPDATE")
	this:RegisterEvent("LOOT_SLOT_CLEARED")
	this:RegisterEvent("LOOT_OPENED")
	this:RegisterEvent("LOOT_CLOSED")
	PanelTemplates_SetNumTabs(this, 3)
	PanelTemplates_SetTab(this, 1)
end

function SmokeyLootFrame_OnEvent()
	if event == "ADDON_LOADED" and arg1 == "SmokeyLoot" then
		this:UnregisterEvent("ADDON_LOADED")
		GuildRoster()
		SMOKEYLOOT = SMOKEYLOOT or {}
		if not SMOKEYLOOT.DATABASE then
			-- database
			SMOKEYLOOT.DATABASE = { date = 0, HR = {}}
		end
		if not SMOKEYLOOT.GUILD then
			-- guild info
			SMOKEYLOOT.GUILD = {}
		end
		if not SMOKEYLOOT.RAID then
			-- current raid data
			SMOKEYLOOT.RAID = {}
		end

		SmokeyLootMinimapButton:ClearAllPoints()
		SmokeyLootMinimapButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", unpack(SMOKEYLOOT.POSITION or {SmokeyLootMinimapButton:GetCenter()}))

		SmokeyLoot_EnableRaidControls()
		SmokeyLoot_UpdateHR()

	elseif event == "GUILD_ROSTER_UPDATE" then
		-- print(event)
		-- local _, myRank = GetGuildInfo("player")
		-- if not OfficerRanks[myRank] then
		-- 	return
		-- end
		for k, v in pairs(SMOKEYLOOT.GUILD) do
			SMOKEYLOOT.GUILD[k] = nil
		end
		for i = 1, GetNumGuildMembers(true) do
			local name, rank, rankIndex, level, class, zone, note, officerNote, online, status = GetGuildRosterInfo(i)
			if name then
				SMOKEYLOOT.GUILD[name] = SMOKEYLOOT.GUILD[name] or {}
				SMOKEYLOOT.GUILD[name].rankName = rank
				SMOKEYLOOT.GUILD[name].rankIndex = rankIndex
				SMOKEYLOOT.GUILD[name].class = strupper(class)
				SMOKEYLOOT.GUILD[name].main = AltRanks[rank] and strtrim(strlower(officerNote)) ~= "guild bank" and strtrim(gsub(officerNote, "%..*", "")) or nil
			end
		end
		if SmokeyLootFrame:IsShown() then
			SmokeyLootFrame_Update()
		end

	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		Master = SmokeyLoot_GetLootMasterName()
		-- print(event, Master)
		SmokeyLoot_EnableRaidControls()

	elseif event == "RAID_ROSTER_UPDATE" then
		-- print(event, Master)

		SmokeyLoot_UpdateRollers()
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		local isMLmethod
		Master, isMLmethod = SmokeyLoot_GetLootMasterName()
		if isMLmethod and (not Master or Master == UNKNOWN) then
			SendAddonMessage("SmokeyLoot", "GET_ML", "RAID")
		end
		-- print(event, Master, isMLmethod)

		RemoteVer = SmokeyLoot_GetRemoteVersion()
		
	elseif event == "CHAT_MSG_SYSTEM" then
		-- Reading rolls from chat
		if not SmokeyItemID then
			return
		end
		local _, _, m = strfind(arg1, MLSearchPattern)
		if m then
			Master = m
			-- print(event, Master)
			SmokeyLoot_EnableRaidControls()
		end
		local _, _, player, roll, max = strfind(arg1, RollSearchPattern)
		-- print(player, roll, max, AlreadyRolled[player])
		roll, max = tonumber(roll), tonumber(max)
		if player and roll and max and not AlreadyRolled[player] then
			local index
			for k, v in ipairs(SMOKEYLOOT.RAID) do
				if v.char == player then
					index = k
				end
			end
			if not index then
				return
			end
			-- print(index)
			if max > 100 then
				if max > LowestHR then
					return
				end
				if max < LowestHR then
					LowestHR = max
					listwipe(Rolls.HR)
				end
				for k, v in ipairs(SMOKEYLOOT.DATABASE) do
					if v.itemID == SmokeyItemID and v.char == player and v.bonus == max then
						Rolls.HR[player] = roll
						break
					end
				end
			elseif max == 100 then
				for k, v in ipairs(SMOKEYLOOT.RAID) do
					if v.itemID == SmokeyItemID and v.char == player then
						Rolls.SR[player] = roll + (v.bonus ~= -1 and v.bonus or 0)
						break
					end
				end
			elseif max == 99 then
				if not SMOKEYLOOT.RAID.isPlusOneRaid or SMOKEYLOOT.RAID[index].pluses == LowestPlus then
					Rolls.MS[player] = roll
				elseif SMOKEYLOOT.RAID[index].pluses < LowestPlus then
					LowestPlus = SMOKEYLOOT.RAID[index].pluses
					Rolls.MS[player] = roll
					-- discard rolls with higher pluses than new lowest plus
					for k, v in pairs(Rolls.MS) do
						for k2, v2 in ipairs(SMOKEYLOOT.RAID) do
							if v2.char == k and v2.pluses > LowestPlus then
								Rolls.MS[k] = nil
							end
						end
					end
				end
			elseif max == 98 then
				Rolls.OS[player] = roll
			elseif max == 97 then
				Rolls.TMOG[player] = roll
			end
			AlreadyRolled[player] = true
		end
		SmokeyLoot_GetWinner()
		if SmokeyLootMLFrame:IsShown() then
			SmokeyLootMLFrame_Update()
		end

	elseif event == "OPEN_MASTER_LOOT_LIST" or event == "LOOT_OPENED" then
		if Master == Me and getn(SMOKEYLOOT.RAID) > 0 then
			SmokeyLootMLFrame:Show()
			SmokeyLootMLFrame_Update()
		end

	elseif event == "LOOT_CLOSED" then
		SmokeyLootMLFrame:Hide()

	elseif event == "LOOT_SLOT_CLEARED" then
		-- print(SmokeyItemLink)
		if arg1 == SmokeySlot then
			-- print(event, arg1, BeingRolledSlot, BeingRolledItemID, WinType, Winner)
			for i = 1, getn(SMOKEYLOOT.RAID) do
				if SMOKEYLOOT.RAID[i].char == Winner then
					if WinType == "MS" then
						if SMOKEYLOOT.RAID.isPlusOneRaid then
							SMOKEYLOOT.RAID[i].pluses = SMOKEYLOOT.RAID[i].pluses + 1
						end
					elseif WinType == "SR" then
						SMOKEYLOOT.RAID[i].bonus = -1
					elseif WinType == "HR" then
						if not SMOKEYLOOT.RAID[i].gotHR then
							SMOKEYLOOT.RAID[i].gotHR = {}
						end
						tinsert(SMOKEYLOOT.RAID[i].gotHR, SmokeyItemID)
					end
					break
				end
			end
			if Master == Me then
				if TmogWinner and Winner and TmogWinner ~= Winner then
					SendChatMessage(format("%s wins %s (%d %s), trade to %s (%d %s)", TmogWinner, SmokeyItemLink, TmogWinRoll, "TMOG", Winner, WinRoll, WinType), IsRaidOfficer() and "RAID_WARNING" or "RAID")
					if TmogWinner ~= Me then
						SendChatMessage("Please, trade "..SmokeyItemLink.." to "..Winner.." after collecting transmog appearance. <3", "WHISPER", nil, TmogWinner)
					end
				elseif Winner then
					SendChatMessage(format("%s wins %s (%d %s)", Winner, SmokeyItemLink, WinRoll, WinType), IsRaidOfficer() and "RAID_WARNING" or "RAID")
				end
			end
			WinType = nil
			Winner = nil
			TmogWinner = nil
			SmokeySlot = nil
			SmokeyItemID = nil
			SmokeyItemLink = nil
			WinRoll = 0
			TmogWinRoll = 0
			LowestPlus = 420
			LowestHR = 420
			SmokeyLoot_UpdateRollers()
			SmokeyLoot_PushRaid()
		end
		if SmokeyLootMLFrame:IsShown() then
			SmokeyLootMLFrame_Update()
		end
		SmokeyLootFrame_Update()
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 ~= "SmokeyLoot" then
			return
		end
		local message = arg2
		local channel = arg3
		local player = arg4
		if channel == "RAID" then
			-- starting roll
			if strfind(message, "^StartRoll") then
				local _, _, id, name, texture, srBy, candidates = strfind(message, "StartRoll:(%d*);(.*);(.*);(.*);(.*)")
				if not strfind(candidates or "", Me) then
					return
				end
				-- print(SmokeyItemID)
				SmokeyLootPopupFrameIconFrameIcon:SetTexture(texture)
				SmokeyLootPopupFrameIconFrame.itemID = tonumber(id)
				SmokeyItemID = tonumber(id)
				CacheItem(SmokeyItemID)
				SmokeyLootPopupFrameName:SetText(name)
				SmokeyLootPopupFrame:Show()
				-- print(srBy)
				if arrcontains(MyHRItemIDs, SmokeyItemID) then
					SmokeyLootPopupFrameHR:EnableMouse(true)
					SmokeyLootPopupFrameHR:SetAlpha(1)
				else
					SmokeyLootPopupFrameHR:EnableMouse(false)
					SmokeyLootPopupFrameHR:SetAlpha(0.5)
				end
				if strfind(srBy or "", Me, 1, true) then
					SmokeyLootPopupFrameSR:EnableMouse(true)
					SmokeyLootPopupFrameSR:SetAlpha(1)
				else
					SmokeyLootPopupFrameSR:EnableMouse(false)
					SmokeyLootPopupFrameSR:SetAlpha(0.5)
				end
				if CanRollForTransmog(SmokeyItemID) then
					SmokeyLootPopupFrameTmog:EnableMouse(true)
					SmokeyLootPopupFrameTmog:SetAlpha(1)
				else
					SmokeyLootPopupFrameTmog:EnableMouse(false)
					SmokeyLootPopupFrameTmog:SetAlpha(0.5)
				end
			-- ending roll
			elseif strfind(message, "^EndRoll") then
				if player ~= Me then
					SmokeyItemID = nil
					SmokeyItemLink = nil
				end
				SmokeyLootPopupFrame:Hide()
				SmokeyLoot_UpdateRollers()
			elseif player ~= Me then
				if message == "REPORT_ADDON_VERSION" then
					-- print(message, player)
					SendAddonMessage("SmokeyLoot", "V_"..GetAddOnMetadata("SmokeyLoot", "Version"), "RAID")
				elseif strfind(message, "^V_") then
					local v = tonumber(strsub(message, 3))
					SmokeyAddonVersions[player] = v or 0
					-- print(message, player)
				elseif message == "GET_ML" then
					-- ml named
					local name = SmokeyLoot_GetLootMasterName()
					if name then
						SendAddonMessage("SmokeyLoot", "ML_"..name, "RAID")
					end
					-- print(message, player, name)
				elseif strfind(message, "ML_", 1, true) then
					Master = strsub(message, 4)
					-- print(message, player, Master)
					SmokeyLoot_EnableRaidControls()
				-- raid update
				elseif strfind(message, "R_start", 1, true) then
					local usingPlus = strsub(message, 9)
					-- print(message, usingPlus)
					SMOKEYLOOT.RAID = {}
					SMOKEYLOOT.RAID.isPlusOneRaid = usingPlus == "1"
				elseif message == "R_end" then
					-- if CurrentTab == "raid" and SmokeyLootFrame:IsShown() then
						SmokeyLootFrame_Update()
					-- end
					-- print(message)
				elseif message == "R_clear" then
					-- print(message)
					arraywipe(SMOKEYLOOT.RAID)
					SmokeyLootFrame_Update()
				else
					-- print(message)
					local _, _, key, itemID, item, char, bonus, pluses, gotHR = strfind(message, "^(%d+);(%d+);(.*);(.*);(%-?%d+);(%d+);(.*)")
					-- print(key, itemID, item, char, bonus, pluses, gotHR)
					if key then
						tinsert(SMOKEYLOOT.RAID, tonumber(key), {
							itemID = tonumber(itemID),
							item = item,
							char = char,
							bonus = tonumber(bonus),
							pluses = tonumber(pluses),
							gotHR = (gotHR ~= "" and strsplit(gotHR, ",")) or nil
						})
					end
				end
			end
		elseif channel == "GUILD" then
			-- sync stuff here
			if player == Me then
				return
			end
			-- if strfind(message, "V_", 1, true) then
			-- 	local _, _, v = strfind(message, "V_(%d+)")
			-- 	v = tonumber(v)
			-- 	if v then
			-- 		RemoteVer = v
			-- 	end
			-- end
			-- if strfind(message, "^NEW_DB_", 1, true) then
			-- 	local _, _, ver = strfind(message, "NEW_DB_(%d+)")
			-- 	ver = tonumber(ver)
			-- 	if ver and ver > SMOKEYLOOT.DATABASE.date then
			-- 		RemoteVer = ver
			-- 	end
			-- end
			if message == "GET_DB_LATEST" then
				-- print("DB requested by "..player)
				SmokeyLoot_Push()
				return
			end
			if not Pusher and strfind(message, "^start;%d+;%d+") then
				-- print(message, player)

				local _, _, date, max = strfind(message, "start;(%d+);(%d+)")
				if tonumber(date) > tonumber(SMOKEYLOOT.DATABASE.date) and IsOfficer(player) then
					Pusher = player
					arraywipe(SMOKEYLOOT.DATABASE)
					arraywipe(SMOKEYLOOT.DATABASE.HR)
					SMOKEYLOOT.DATABASE.date = tonumber(date)
					SmokeyLootFrameProgressBar:Show()
					SmokeyLootFrameProgressBar:SetMinMaxValues(0, tonumber(max))
					SmokeyLootFrameProgressBar:SetValue(0)
					SmokeyLootFrameProgressBarText:SetText("0%")
					SmokeyLootFrameDBDate:SetText("Database version: updating...")
					SmokeyLootVersionCheckButton:Hide()
				end
			elseif player and player == Pusher then
				if strfind(message, "^end;%d+") then
					-- print(message, player)

					Pusher = nil
					SmokeyLootFrameProgressBar:Hide()
					SmokeyLootVersionCheckButton:Show()
					SmokeyLootVersionCheckButton:Enable()
					Pulling = false
					RemoteVer = 0
					if PushAfter then
						PushAfter = false
						SmokeyLoot_FinishRaidRoutine()
						SmokeyLoot_Push()
					end
					SmokeyLoot_UpdateHR()
					SmokeyLootFrame_Update()
				else
					local _, _, index, itemID, itemName = strfind(message, "(%d+)=(%d+)=(.+)=")
					index, itemID = tonumber(index), tonumber(itemID)
					if index and itemID and itemName then
						message = gsub(message, "%d+=%d+=.+=", "")
						local info = strsplit(message, ";")
						for i = 1, getn(info), 2 do
							if info[i] and tonumber(info[i + 1]) then
								tinsert(SMOKEYLOOT.DATABASE, {
									itemID = itemID,
									item = itemName,
									char = info[i],
									bonus = tonumber(info[i + 1]),
								})
							end
						end
						SmokeyLootFrameProgressBar:SetValue(index)
						local min, max = SmokeyLootFrameProgressBar:GetMinMaxValues()
						SmokeyLootFrameProgressBarText:SetText(format("%.0f%%", index / max * 100))
					end
				end
			end
		end
	end
end

function SmokeyLoot_Toggle()
	if SmokeyLootFrame:IsShown() then
		HideUIPanel(SmokeyLootFrame)
	else
		ShowUIPanel(SmokeyLootFrame)
	end
end

function SmokeyLoot_Search()
	arraywipe(SearchResult)
	local query = strtrim(strlower(SmokeyLootFrameSearchBox:GetText()))
	if query == "" then
		SmokeyLootFrame_Update()
		return
	end
	local tableToSearch
	if CurrentTab == "raid" then
		tableToSearch = SMOKEYLOOT.RAID
	elseif CurrentTab == "database" then
		tableToSearch = SMOKEYLOOT.DATABASE
	elseif CurrentTab == "hr" then
		tableToSearch = SMOKEYLOOT.DATABASE.HR
	end
	if CurrentTab == "raid" or CurrentTab == "database" then
		for i = 1, getn(tableToSearch) do
			local item = strlower(tableToSearch[i].item)
			local name = strlower(tableToSearch[i].char)
			if strfind(item, query, 1, true) or strfind(name, query, 1, true) then
				tinsert(SearchResult, i)
			end
		end
	else
		for i = 1, getn(tableToSearch) do
			local item = strlower(tableToSearch[i].itemName)
			if strfind(item, query, 1, true) then
				tinsert(SearchResult, i)
			end
		end
	end
	SmokeyLootScrollFrame:SetVerticalScroll(0)
	SmokeyLootFrame_Update()
end

function SmokeyLootFrame_Update()
	local tableToUpdate
	if CurrentTab == "raid" then
		tableToUpdate = SMOKEYLOOT.RAID
	elseif CurrentTab == "database" then
		tableToUpdate = SMOKEYLOOT.DATABASE
	elseif CurrentTab == "hr" then
		tableToUpdate = SMOKEYLOOT.DATABASE.HR
	end
	local offset = FauxScrollFrame_GetOffset(SmokeyLootScrollFrame) or 0
	local results = getn(SearchResult)
	local numEntries = getn(tableToUpdate)
	local entriesToUpdate = results == 0 and numEntries or results
	FauxScrollFrame_Update(SmokeyLootScrollFrame, entriesToUpdate, MaxEntries, 16)
	for i = 1, MaxEntries do
		local entry = _G["SmokeyLootEntry"..i]
		if not entry then
			entry = CreateFrame("Button", "SmokeyLootEntry"..i, SmokeyLootFrame, "SmokeyLootEntryTemplate")
			entry:SetPoint("TOPLEFT", SmokeyLootScrollFrame, 0 , 0 - ((i - 1) * 16))
		end
		local entryIndex = 0
		if SmokeyLootFrameSearchBox:GetText() ~= "" then
			if results > 0 then
				if SearchResult[i + offset] then
					entryIndex = SearchResult[i + offset]
				end
			else
				entryIndex = -1
			end
		else
			entryIndex = i + offset
		end
		if entryIndex > 0 and entryIndex <= numEntries then
			local icon = _G["SmokeyLootEntry"..i.."Icon"]
			local itemName = _G["SmokeyLootEntry"..i.."Text"]
			local charName = _G["SmokeyLootEntry"..i.."Column1"]
			local rank = _G["SmokeyLootEntry"..i.."Column2"]
			local bonus = _G["SmokeyLootEntry"..i.."Column3"]
			icon:SetTexture("")
			icon:Hide()
			if CurrentTab ~= "hr" then
				itemName:SetText(tableToUpdate[entryIndex].item)
				charName:SetText(tableToUpdate[entryIndex].char)
				if SMOKEYLOOT.GUILD[tableToUpdate[entryIndex].char] then
					charName:SetTextColor(
						RAID_CLASS_COLORS[SMOKEYLOOT.GUILD[tableToUpdate[entryIndex].char].class].r,
						RAID_CLASS_COLORS[SMOKEYLOOT.GUILD[tableToUpdate[entryIndex].char].class].g,
						RAID_CLASS_COLORS[SMOKEYLOOT.GUILD[tableToUpdate[entryIndex].char].class].b
					)
					rank:SetText(SMOKEYLOOT.GUILD[tableToUpdate[entryIndex].char].rankName)
				else
					charName:SetTextColor(1,0.2,0.2)
					rank:SetText("")
				end
				bonus:SetText(tableToUpdate[entryIndex].bonus)
				if tableToUpdate[entryIndex].bonus <= 0 then
					bonus:SetText("")
					if tableToUpdate[entryIndex].bonus == -1 then
						icon:SetTexture("Interface\\AddOns\\SmokeyLoot\\Textures\\Check")
						icon:Show()
					end
				end
			else
				itemName:SetText(tableToUpdate[entryIndex].itemName)
				charName:SetText()
				rank:SetText()
				bonus:SetText()
			end
			entry.data = tableToUpdate[entryIndex]
			entry:SetID(entryIndex)
			entry:Show()
			if GetMouseFocus() == entry then
				entry:Hide()
				entry:Show()
			end
		else
			entry:Hide()
		end
	end
	SmokeyLootFrameDBDate:SetText(date("Database version: %d/%m/%y %H:%M:%S", SMOKEYLOOT.DATABASE.date))
	if SMOKEYLOOT.DATABASE.date >= SmokeyLoot_GetRemoteVersion() then
		SmokeyLootFrameStatus:SetText("Latest")
		SmokeyLootFrameStatus:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	else
		SmokeyLootFrameStatus:SetText("Outdated")
		SmokeyLootFrameStatus:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	end
end

function SmokeyLootEntry_OnEnter()
	this:SetBackdropColor(1, 1, 1, 0.5)
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT", -14, 16)
	if CurrentTab == "hr" then
		if this.data.itemID > 0 then
			GameTooltip:SetHyperlink("item:"..this.data.itemID)
		end
		local str = "Hard reserve queue:\n"
		for k, v in ipairs(this.data) do
			str = str..k..". "
			for k2, v2 in ipairs(v) do
				if SMOKEYLOOT.GUILD[v2] then
					str = str..ClassColors[SMOKEYLOOT.GUILD[v2].class]..v2.."|r"
					str = v[k2 + 1] and str..", " or str
				end
			end
			str = str.."\n"
		end
		GameTooltip:AddLine(str)
	elseif CurrentTab == "raid" then
		if this.data.itemID > 0 then
			GameTooltip:SetHyperlink("item:"..this.data.itemID)
		end
		GameTooltip:AddLine(format("%d. itemID: %d pluses: %d gotHR: %s", this:GetID(), this.data.itemID, this.data.pluses, this.data.gotHR and table.concat(this.data.gotHR, ", ") or "no"))
	elseif CurrentTab == "database" then
		if this.data.itemID > 0 then
			GameTooltip:SetHyperlink("item:"..this.data.itemID)
			GameTooltip:AddLine("ItemID: "..this.data.itemID)
		end
	end
	GameTooltip:Show()
end

function SmokeyLootEntry_OnLeave()
	this:SetBackdropColor(1, 1, 1, 0.2)
	GameTooltip:Hide()
end

function SmokeyLootEntry_OnClick()
	if not IsOfficer(Me) then
		return
	end
	if CurrentTab == "database" or CurrentTab == "raid" then
		SmokeyLoot_ToggleEditEntryFrame(this:GetID())
	end
end

function SmokeyLoot_Roll(choise)
	-- SendAddonMessage("SmokeyLoot", choise, "RAID")
	if choise == "PASS" or not SmokeyItemID then
		SmokeyLootPopupFrame:Hide()
		return
	end
	local min = 1
	local max
	if choise == "HR" then
		for k, v in ipairs(SMOKEYLOOT.DATABASE) do
			if v.itemID == SmokeyItemID and v.char == Me and v.bonus > 100 then
				max = v.bonus
				break
			end
		end
	elseif choise == "SR" then
		max = 100
	elseif choise == "MS" then
		max = 99
	elseif choise == "OS" then
		max = 98
	elseif choise == "TMOG" then
		max = 97
	end
	if max then
		RandomRoll(min, max)
	end
	SmokeyLootPopupFrame:Hide()
end

function SmokeyLoot_GetWinner()
	Winner = nil
	WinRoll = 0
	WinType = nil
	TmogWinner = nil
	if next(Rolls.HR) then
		for k, v in pairs(Rolls.HR) do
			if v >= WinRoll then
				WinRoll = v
				Winner = k
				WinType = "HR"
			end
		end
	elseif next(Rolls.SR) then
		for k, v in pairs(Rolls.SR) do
			if v >= WinRoll then
				WinRoll = v
				Winner = k
				WinType = "SR"
			end
		end
	elseif next(Rolls.MS) then
		for k, v in pairs(Rolls.MS) do
			if v >= WinRoll then
				WinRoll = v
				Winner = k
				WinType = "MS"
			end
		end
	elseif next(Rolls.OS) then
		for k, v in pairs(Rolls.OS) do
			if v >= WinRoll then
				WinRoll = v
				Winner = k
				WinType = "OS"
			end
		end
	elseif next(Rolls.TMOG) then
		for k, v in pairs(Rolls.TMOG) do
			if v >= WinRoll then
				WinRoll = v
				Winner = k
				WinType = "TMOG"
			end
		end
	end
	if WinType and WinType ~= "TMOG" and next(Rolls.TMOG) then
		TmogWinRoll = 0
		for k, v in pairs(Rolls.TMOG) do
			if v >= TmogWinRoll then
				TmogWinRoll = v
				TmogWinner = k
			end
		end
	end
end

function SmokeyLoot_StartOrEndRoll()
	local slot = this:GetParent().lootSlot
	local link = GetLootSlotLink(slot)
	local _, _, itemID = strfind(link or "", "item:(%d+)")
	itemID = tonumber(itemID)
	if not itemID then
		return
	end
	if not SmokeyItemID then
		-- Start Roll
		listwipe(Rolls)
		SmokeyItemID = itemID
		SmokeySlot = slot
		SmokeyItemLink = link
		LowestPlus = 420
		LowestHR = 420
		local srBy = ""
		local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)
		local r, g, b, color = GetItemQualityColor(itemQuality)
		for k, v in ipairs(SMOKEYLOOT.RAID) do
			if v.itemID == itemID then
				srBy = srBy..v.char..","
			end
		end
		local candidates = ""
		for i = 1, 40 do
			for j = 1, GetNumRaidMembers() do
				if GetRaidRosterInfo(j) == GetMasterLootCandidate(i) then
					candidates = candidates..GetRaidRosterInfo(j)..","
				end
			end
		end
		SendAddonMessage("SmokeyLoot", "StartRoll:"..itemID..";"..color..itemName.."|r;"..itemTexture..";"..srBy..";"..candidates, "RAID")
		-- print(candidates)
		this:SetText("End Roll")
	else
		-- End Roll
		SendAddonMessage("SmokeyLoot", "EndRoll", "RAID")
		this:SetText("Start Roll")
		SmokeyLoot_GetWinner()
		if not Winner and not TmogWinner then
			return
		end
		if itemID == SmokeyItemID then
			if GetNumRaidMembers() > 0 then
				local name = TmogWinner and not _G[this:GetParent():GetName().."IgnoreTmog"]:GetChecked() and TmogWinner or Winner
				for i = 1, 40 do
					if name == GetMasterLootCandidate(i) then
						GiveMasterLoot(SmokeySlot, i)
						break
					end
				end
			end
			Delay(0.5, function()
				SmokeyItemID = nil
				SmokeyItemLink = nil
				WinRoll = 0
				WinType = nil
				Winner = nil
				TmogWinner = nil
				LowestPlus = 420
				LowestHR = 420
			end)
		end
	end
	SmokeyLootMLFrame_Update()
end

function SmokeyLoot_CancelRoll()
	SendAddonMessage("SmokeyLoot", "EndRoll", "RAID")
	SmokeyItemID = nil
	SmokeyItemLink = nil
	SmokeySlot = nil
	WinType = nil
	Winner = nil
	TmogWinner = nil
	WinRoll = 0
	LowestPlus = 420
	LowestHR = 420
	SmokeyLootMLFrame_Update()
end

function SmokeyLootMLFrame_Update()
	local buttonIndex = 1
	for i = 1, LootButtonsMax do
		_G["SmokeyLootMLFrameLoot"..i]:Hide()
	end
	for i = 1, GetNumLootItems() do
		if LootSlotIsItem(i) then
			local _, _, id = strfind(GetLootSlotLink(i) or "", "item:(%d+)")
			id = tonumber(id)
			if id then
				local itemIcon, itemName, itemCount, quality = GetLootSlotInfo(i)
				local button = _G["SmokeyLootMLFrameLoot"..buttonIndex]
				if not button then
					button = CreateFrame("Button", "$parentLoot"..buttonIndex, SmokeyLootMLFrame, "SmokeyLootButtonTemplate")
					button:SetPoint("TOPLEFT", "SmokeyLootMLFrameLoot"..(buttonIndex-1), "BOTTOMLEFT", 0, -5)
					button:SetID(buttonIndex)
					LootButtonsMax = buttonIndex
				end
				local icon = _G["SmokeyLootMLFrameLoot"..buttonIndex.."Icon"]
				local name = _G["SmokeyLootMLFrameLoot"..buttonIndex.."Text"]
				local count = _G["SmokeyLootMLFrameLoot"..buttonIndex.."Count"]
				local srText = _G["SmokeyLootMLFrameLoot"..buttonIndex.."SR"]
				local winnerText = _G["SmokeyLootMLFrameLoot"..buttonIndex.."Winner"]
				local toggleButton = _G["SmokeyLootMLFrameLoot"..buttonIndex.."StartOrEndRoll"]
				local cancelButton = _G["SmokeyLootMLFrameLoot"..buttonIndex.."CancelRoll"]
				local ignoreTmogButton = _G["SmokeyLootMLFrameLoot"..buttonIndex.."IgnoreTmog"]:GetChecked()
				icon:SetTexture(itemIcon)
				name:SetText(itemName)
				local r, g, b = GetItemQualityColor(quality)
				name:SetTextColor(r, g, b)
				count:SetText(itemCount)
				button.lootSlot = i
				winnerText:SetText("...")
				if arrcontains(SMOKEYLOOT.RAID, id) then
					srText:Show()
				else
					srText:Hide()
				end
				if SmokeyItemID then
					if SmokeyItemID == id then
						SmokeySlot = i
						if Winner then
							winnerText:SetText(Winner.." ("..WinType..")")
							if TmogWinner and not ignoreTmogButton then
								winnerText:SetText(TmogWinner.." (Tmog)->"..winnerText:GetText())
							end
						end
						toggleButton:SetText("End Roll")
						toggleButton:Enable()
						cancelButton:Enable()
					else
						toggleButton:SetText("Start Roll")
						toggleButton:Disable()
						cancelButton:Disable()
					end
				else
					toggleButton:SetText("Start Roll")
					toggleButton:Enable()
					cancelButton:Disable()
				end
				button:Show()
				buttonIndex = buttonIndex + 1
			end
		end
	end
	SmokeyLootMLFrame:SetHeight(floor(15 + (buttonIndex - 1) * (SmokeyLootMLFrameLoot1:GetHeight() + 5)))
end

function SmokeyLoot_UpdateRollers()
	if not SmokeyItemID then
		listwipe(AlreadyRolled)
		for i = 1, 40 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
			if name and online then
				AlreadyRolled[name] = false
			end
		end
	end
end

function SmokeyLoot_Import(tsv)
	if tsv and ImportFile then
		local file = "Smokey Tokers SR Sheet - Database"
		local text = ImportFile(file)
		if not text then
			return
		end
		arraywipe(SMOKEYLOOT.DATABASE)
		local split = strsplit(text, "\n")
		for i = 1, getn(split) do
			local _, _, itemName, char, bonus = strfind(split[i], "(.+)\t(%a+)\t(%d+)")
			local itemID
			if itemName then
				itemID, itemName = GetItemIDByName(itemName)
				bonus = tonumber(bonus)
			end
			tinsert(SMOKEYLOOT.DATABASE, {
				itemID = itemID,
				item = itemName,
				char = char,
				bonus = bonus,
			})
		end
		SmokeyLoot_SetRemoteVersion()
		SmokeyLoot_UpdateHR()
		SmokeyLootFrame_Update()
		return
	end
	local text = strtrim(SmokeyImportText:GetText())
	text = gsub(text, "^ID,Item,Attendee\n", "")
	text = gsub(text, ',"', ";")
	text = gsub(text, '",', ";")
	text = gsub(text, "'", "")
	text = gsub(text, ",", "")
	local split = strsplit(text, "\n")
	arraywipe(SMOKEYLOOT.RAID)
	SMOKEYLOOT.RAID.isPlusOneRaid = SmokeyLootImportFrameEnablePlusOne:GetChecked() and true or false
	for i = 1, getn(split) do
		local _, _, id, itemName, char = strfind(split[i], "(%d+);(.+);(.+)")
		local bonus = 0
		if id then
			for k, v in ipairs(SMOKEYLOOT.DATABASE) do
				if v.itemID == tonumber(id) and v.char == char then
					bonus = v.bonus
					break
				end
			end
			tinsert(SMOKEYLOOT.RAID, { char = char, itemID = tonumber(id), item = itemName, bonus = bonus, pluses = 0 })
		end
	end
	for i = 1, 40 do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
		if name then
			if not arrcontains(SMOKEYLOOT.RAID, name) then
				tinsert(SMOKEYLOOT.RAID, { char = name, itemID = 0, item = "", bonus = 0, pluses = 0 })
			end
		end
	end
	-- for i = 1, getn(SMOKEYLOOT.RAID) do
		-- print(SMOKEYLOOT.RAID[i].itemID, SMOKEYLOOT.RAID[i].item, SMOKEYLOOT.RAID[i].char, SMOKEYLOOT.RAID[i].bonus)
	-- end
	table.sort(SMOKEYLOOT.RAID, sortfunc)
	SmokeyLootFrame_Update()
	SmokeyLootImportFrame:Hide()
	SmokeyLoot_EnableRaidControls()
	SmokeyLoot_PushRaid()
end

function SmokeyLoot_SwitchTab(switchTo)
	SmokeyLootEditEntryFrame:Hide()
	SmokeyLootFrameSearchBox:SetText("")
	SmokeyLootFrameSearchBox:ClearFocus()
	arraywipe(SearchResult)
	if switchTo == "raid" then
		SmokeyLootImportButton:Show()
		SmokeyLootFinishRaidButton:Show()
		SmokeyLootClearButton:Show()
		SmokeyLootAddButton:Show()
		SmokeyLoot_EnableRaidControls()
		SmokeyLootVersionCheckButton:Hide()
	elseif switchTo == "database" then
		SmokeyLootImportButton:Hide()
		SmokeyLootFinishRaidButton:Hide()
		SmokeyLootClearButton:Hide()
		SmokeyLootAddButton:Show()
		if IsOfficer(Me) and getn(SMOKEYLOOT.RAID) == 0 then
			SmokeyLootAddButton:Enable()
		else
			SmokeyLootAddButton:Disable()
		end
		SmokeyLootVersionCheckButton:Show()
	elseif switchTo == "hr" then
		SmokeyLootImportButton:Hide()
		SmokeyLootFinishRaidButton:Hide()
		SmokeyLootClearButton:Hide()
		SmokeyLootAddButton:Hide()
		SmokeyLootVersionCheckButton:Show()
	end
	CurrentTab = switchTo
	SmokeyLootScrollFrame:SetVerticalScroll(0)
	SmokeyLootFrame_Update()
end

function SmokeyLoot_FinishRaidRoutine()
	-- print("SmokeyLoot_FinishRaidRoutine")
	for i = getn(SMOKEYLOOT.RAID), 1, -1 do
		local id = SMOKEYLOOT.RAID[i].itemID
		local bonus = SMOKEYLOOT.RAID[i].bonus
		local char = SMOKEYLOOT.RAID[i].char
		local gotHR = SMOKEYLOOT.RAID[i].gotHR
		-- first check if player got any of their HR items
		if gotHR then
			-- find that item and character in DATABASE and remove
			for _, itemID in ipairs(gotHR) do
				local removedBonus
				for k, v in ipairs(SMOKEYLOOT.DATABASE) do
					if v.itemID == itemID and v.char == char and v.bonus > 100 then
						-- store removed "position"
						removedBonus = v.bonus
						tremove(SMOKEYLOOT.DATABASE, k)
						break
					end
				end
				if removedBonus then
					-- decrement bonus of people that come after deleted position in HR list for that item
					for k, v in ipairs(SMOKEYLOOT.DATABASE) do
						if v.itemID == itemID and v.bonus > removedBonus then
							v.bonus = v.bonus - 1
						end
					end
				end
			end
		end
		-- remove if had nothing reserved or mount or reserved when already hr
		if id == 0 or BlacklistItems[id] or bonus > 90 then
			tremove(SMOKEYLOOT.RAID, i)
		end
		-- check if got their sr
		if bonus == -1 then
			for k, v in ipairs(SMOKEYLOOT.DATABASE) do
				if v.itemID == id and v.char == char then
					-- remove them from DATABASE
					tremove(SMOKEYLOOT.DATABASE, k)
					break
				end
			end
			-- remove from RAID
			tremove(SMOKEYLOOT.RAID, i)
		end
	end
	-- RAID now should only contain people who need to get +10 bonus (or get on HR list)
	for k, v in ipairs(SMOKEYLOOT.RAID) do
		local newBonus = v.bonus + 10
		if newBonus == 100 then
			-- this is new hr
			local newHRPlayers = { v.char }
			-- check if someone else got hr in the same raid, we have to add them to DATABASE together
			for k2, v2 in ipairs(SMOKEYLOOT.RAID) do
				if v2.itemID == v.itemID and v2.bonus + 10 == newBonus and v2.char ~= v.char then
					tinsert(newHRPlayers, v2.char)
					v2.bonus = -1
				end
			end
			newBonus = 101
			local oldBonuses = nil
			for k2, v2 in ipairs(SMOKEYLOOT.DATABASE) do
				if v2.itemID == v.itemID and v2.bonus > 100 then
					oldBonuses = oldBonuses or {}
					tinsert(oldBonuses, v2.bonus)
				end
			end
			if oldBonuses then
				newBonus = max(unpack(oldBonuses)) + 1
			end
			for i = 1, getn(newHRPlayers) do
				for k2, v2 in ipairs(SMOKEYLOOT.DATABASE) do
					if v2.char == newHRPlayers[i] and v2.itemID == v.itemID then
						v2.bonus = newBonus
						break
					end
				end
			end
		else
			-- this is regular new entry
			if newBonus == 10 then
				tinsert(SMOKEYLOOT.DATABASE, { char = v.char, itemID = v.itemID, bonus = newBonus, item = v.item })
			elseif newBonus > 10 then
				-- this is old regular entry
				for k2, v2 in ipairs(SMOKEYLOOT.DATABASE) do
					if v2.char == v.char and v2.itemID == v.itemID then
						v2.bonus = newBonus
						break
					end
				end
			end
		end
	end
	arraywipe(SMOKEYLOOT.RAID)
	listwipe(SMOKEYLOOT.RAID)
	SmokeyLoot_PushRaid(1)
	SmokeyLoot_SetRemoteVersion()
	SmokeyLoot_UpdateHR()
	SmokeyLootFrame_Update()
	-- print("SmokeyLoot_FinishRaidRoutine end new date "..date("%d/%m/%y %H:%M:%S", SMOKEYLOOT.DATABASE.date))
end

function SmokeyLootFinishRaidButton_OnClick()
	SmokeyLootFinishRaidButton:Disable()
	SmokeyLoot_Pull()
	PushAfter = true
	Delay(3, function()
		-- print(RemoteVer, SMOKEYLOOT.DATABASE.date, SMOKEYLOOT.DATABASE.date)
		if RemoteVer <= SMOKEYLOOT.DATABASE.date then
			PushAfter = false
			SmokeyLoot_FinishRaidRoutine()
			SmokeyLoot_Push()
		end
	end)
end

function SmokeyLoot_Pull()
	GuildRoster()
	if Pulling then
		return
	end
	if SMOKEYLOOT.DATABASE.date < SmokeyLoot_GetRemoteVersion() then
		Pulling = true
		SmokeyLootVersionCheckButton:Disable()
		-- print("Requesting database")
		SendAddonMessage("SmokeyLoot", "GET_DB_LATEST", "GUILD")
	end
	Delay(5, function()
		if SMOKEYLOOT.DATABASE.date < SmokeyLoot_GetRemoteVersion() then
			Pulling = false
			SmokeyLootVersionCheckButton:Enable()
		end
	end)
end

function SmokeyLoot_Push()
	local dbPushFrame = SmokeyLootDBPushFrame or CreateFrame("Frame", "SmokeyLootDBPushFrame")
	if not IsOfficer(Me) or Pushing or Pusher or SMOKEYLOOT.DATABASE.date < SmokeyLoot_GetRemoteVersion() then
		return
	end
	local items = {}
	local messages = {}
	sort(SMOKEYLOOT.DATABASE, sortfunc)
	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if type(v) == "table" then
			if not items[v.itemID] then
				items[v.itemID] = true
				tinsert(messages, v.itemID.."="..v.item.."=")
			end
			messages[getn(messages)] = messages[getn(messages)]..v.char..";"..v.bonus..";"
		end
	end
	local count = 1
	SendAddonMessage("SmokeyLoot", "start;"..SMOKEYLOOT.DATABASE.date..";"..getn(messages), "GUILD")
	Pushing = true
	-- print("Pushing database")
	dbPushFrame:SetScript("OnUpdate", function()
		SendAddonMessage("SmokeyLoot", count.."="..messages[count], "GUILD")
		count = count + 1
		if count > getn(messages) then
			dbPushFrame:SetScript("OnUpdate", nil)
			SendAddonMessage("SmokeyLoot", "end;"..SMOKEYLOOT.DATABASE.date, "GUILD")
			Pushing = false
			-- print("Database push finished")
		end
	end)
end

function SmokeyLoot_PushRaid(clear)
	local raidPushFrame = SmokeyLootRaidPushFrame or CreateFrame("Frame", "SmokeyLootRaidPushFrame")
	if not IsOfficer(Me) or not Master or Master ~= Me then
		return
	end
	if clear then
		SendAddonMessage("SmokeyLoot", "R_clear", "RAID")
		return
	end
	local messages = {}
	local str
	sort(SMOKEYLOOT.RAID, sortfunc)
	for k, v in ipairs(SMOKEYLOOT.RAID) do
		if type(v) == "table" then
			str = k..";"..v.itemID..";"..v.item..";"..v.char..";"..v.bonus..";"..v.pluses..";"..(v.gotHR and table.concat(v.gotHR, ",") or "")
			tinsert(messages, str)
			-- print(str)
		end
	end
	if not str then
		return
	end
	SendAddonMessage("SmokeyLoot", "R_start;"..(SMOKEYLOOT.RAID.isPlusOneRaid and 1 or 0), "RAID")
	-- print("Pushing raid")
	local count = 1
	raidPushFrame:SetScript("OnUpdate", function()
		-- print(messages[count])
		SendAddonMessage("SmokeyLoot", messages[count], "RAID")
		count = count + 1
		if count > getn(messages) then
			raidPushFrame:SetScript("OnUpdate", nil)
			SendAddonMessage("SmokeyLoot", "R_end", "RAID")
			-- print("Raid push finished")
		end
	end)
end

function SmokeyLoot_Cleanup()
	if not IsOfficer(Me) then
		return
	end
	if SMOKEYLOOT.DATABASE.date < SmokeyLoot_GetRemoteVersion() then
		print("You need to get latest database first.")
		return
	end
	-- print("Cleanup")
	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if not SMOKEYLOOT.GUILD[v.char] then
			-- print(format("Removed: %s %s itemID: %d bonus: %d", v.char, v.item, v.itemID, v.bonus))
			tremove(SMOKEYLOOT.DATABASE, k)
			SmokeyLoot_SetRemoteVersion()
		end
	end
	-- print("Cleanup done")
end

function SmokeyLoot_GetRemoteVersion()
	GuildRoster()
	local _, _, v = strfind(GetGuildInfoText(), "\n%a*(%d+)$")
	return tonumber(v)
end

function SmokeyLoot_SetRemoteVersion()
	if not IsOfficer(Me) then
		return
	end
	GuildRoster()
	SMOKEYLOOT.DATABASE.date = time()
	local guildInfo = gsub(GetGuildInfoText(), "\n%a*%d+$", "\n"..Me..SMOKEYLOOT.DATABASE.date)
	SetGuildInfoText(guildInfo)
	-- SendAddonMessage("SmokeyLoot", "NEW_DB_"..SMOKEYLOOT.DATABASE.date, "GUILD")
end

function SmokeyLoot_GetLootMasterName()
	local method, partyIndex = GetLootMethod()
	if method ~= "master" then
		return nil, false
	elseif partyIndex == 0 then
		return Me, true
	elseif partyIndex then
		return UnitName("party"..partyIndex), true
	elseif Master then
		return Master, true
	end
	return nil, true
end

function SmokeyLoot_UpdateHR()
	arraywipe(SMOKEYLOOT.DATABASE.HR)
	arraywipe(MyHRItemIDs)
	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if v.bonus > 100 then
			local pos = v.bonus - 100
			local hrIndex = arrcontains(SMOKEYLOOT.DATABASE.HR, v.itemID)
			if not hrIndex then
				tinsert(SMOKEYLOOT.DATABASE.HR, { itemName = v.item, itemID = v.itemID })
				hrIndex = getn(SMOKEYLOOT.DATABASE.HR)
			end
			if not SMOKEYLOOT.DATABASE.HR[hrIndex][pos] then
				SMOKEYLOOT.DATABASE.HR[hrIndex][pos] = {}
			end
			tinsert(SMOKEYLOOT.DATABASE.HR[hrIndex][pos], v.char)
			if pos == 1 and v.char == Me then
				tinsert(MyHRItemIDs, v.itemID)
			end
		end
	end
	-- print("HR list updated")
end

function SmokeyLoot_ToggleEditEntryFrame(id, add)
	if not IsOfficer(Me) then
		SmokeyLootEditEntryFrame:Hide()
		return
	end
	if SmokeyLootEditEntryFrame:IsShown() then
		SmokeyLootEditEntryFrame:Hide()
	else
		if SMOKEYLOOT.DATABASE.date < SmokeyLoot_GetRemoteVersion() then
			print("You need to get latest database first.")
			return
		end
		SmokeyLootEditEntryFrame:Show()
		SmokeyLootEditEntryFrame.id = id
		SmokeyLootEditEntryFrame.add = add
		if CurrentTab == "database" then
			SmokeyLootEditEntryFrameEntryIndex:SetText("Database Entry # " .. id)
			SmokeyLootEditEntryFrameEditBox1:SetText(add and "" or SMOKEYLOOT.DATABASE[id].item)
			SmokeyLootEditEntryFrameEditBox2:SetNumber(add and 0 or SMOKEYLOOT.DATABASE[id].itemID)
			SmokeyLootEditEntryFrameEditBox3:SetText(add and "" or SMOKEYLOOT.DATABASE[id].char)
			SmokeyLootEditEntryFrameEditBox4:SetNumber(add and 0 or SMOKEYLOOT.DATABASE[id].bonus)
			SmokeyLootEditEntryFrameEditBox5:Hide()
			SmokeyLootEditEntryFramePluses:Hide()
		elseif CurrentTab == "raid" then
			SmokeyLootEditEntryFrameEntryIndex:SetText("Raid Entry # " .. id)
			SmokeyLootEditEntryFrameEditBox1:SetText(add and "" or SMOKEYLOOT.RAID[id].item)
			SmokeyLootEditEntryFrameEditBox2:SetNumber(add and 0 or SMOKEYLOOT.RAID[id].itemID)
			SmokeyLootEditEntryFrameEditBox3:SetText(add and "" or SMOKEYLOOT.RAID[id].char)
			SmokeyLootEditEntryFrameEditBox4:SetNumber(add and 0 or SMOKEYLOOT.RAID[id].bonus)
			if SMOKEYLOOT.RAID.isPlusOneRaid then
				SmokeyLootEditEntryFrameEditBox5:SetNumber(add and 0 or SMOKEYLOOT.RAID[id].pluses)
				SmokeyLootEditEntryFrameEditBox5:Show()
				SmokeyLootEditEntryFramePluses:Show()
			else
				SmokeyLootEditEntryFrameEditBox5:SetNumber(0)
				SmokeyLootEditEntryFrameEditBox5:Hide()
				SmokeyLootEditEntryFramePluses:Hide()
			end
		end
		if add then
			SmokeyLootEditEntryFrameDeleteButton:Hide()
		else
			SmokeyLootEditEntryFrameDeleteButton:Show()
		end
	end
end

function SmokeyLootEditEntryFrame_OnHide()
	SmokeyLootEditEntryFrame.id = nil
	SmokeyLootEditEntryFrame.add = nil
	SmokeyLootFrame_Update()
end

function SmokeyLootEditEntryFrameCancelButton_OnClick()
	SmokeyLootEditEntryFrame:Hide()
end

function SmokeyLootEditEntryFrameAcceptButton_OnClick()
	if IsOfficer(Me) then
		if SMOKEYLOOT.DATABASE.date < SmokeyLoot_GetRemoteVersion() then
			print("You need to get latest database first.")
			return
		end
		local id = SmokeyLootEditEntryFrame.id
		if CurrentTab == "database" then
			if SmokeyLootEditEntryFrame.add then
				tinsert(SMOKEYLOOT.DATABASE, id, {})
			end
			SMOKEYLOOT.DATABASE[id].item = SmokeyLootEditEntryFrameEditBox1:GetText()
			SMOKEYLOOT.DATABASE[id].itemID = SmokeyLootEditEntryFrameEditBox2:GetNumber()
			SMOKEYLOOT.DATABASE[id].char = SmokeyLootEditEntryFrameEditBox3:GetText()
			SMOKEYLOOT.DATABASE[id].bonus = SmokeyLootEditEntryFrameEditBox4:GetNumber()
			sort(SMOKEYLOOT.DATABASE, sortfunc)
			SmokeyLoot_SetRemoteVersion()
			SmokeyLoot_UpdateHR()
		elseif CurrentTab == "raid" then
			if SmokeyLootEditEntryFrame.add then
				tinsert(SMOKEYLOOT.RAID, id, {})
			end
			SMOKEYLOOT.RAID[id].item = SmokeyLootEditEntryFrameEditBox1:GetText()
			SMOKEYLOOT.RAID[id].itemID = SmokeyLootEditEntryFrameEditBox2:GetNumber()
			SMOKEYLOOT.RAID[id].char = SmokeyLootEditEntryFrameEditBox3:GetText()
			SMOKEYLOOT.RAID[id].bonus = SmokeyLootEditEntryFrameEditBox4:GetNumber()
			SMOKEYLOOT.RAID[id].pluses = SmokeyLootEditEntryFrameEditBox5:GetNumber()
			SmokeyLoot_PushRaid()
		end
	end
	SmokeyLootEditEntryFrame:Hide()
end

function SmokeyLootEditEntryFrameDeleteButton_OnClick()
	if CurrentTab == "database" and IsOfficer(Me) and Master == Me then
		if SMOKEYLOOT.DATABASE.date < SmokeyLoot_GetRemoteVersion() then
			print("You need to get latest database first.")
			return
		end
		tremove(SMOKEYLOOT.DATABASE, SmokeyLootEditEntryFrame.id)
		SmokeyLoot_UpdateHR()
		SmokeyLoot_SetRemoteVersion()
	elseif CurrentTab == "raid" and Master == Me then
		tremove(SMOKEYLOOT.RAID, SmokeyLootEditEntryFrame.id)
		SmokeyLoot_PushRaid()
	end
	SmokeyLootEditEntryFrame:Hide()
end

function SmokeyLootButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetLootItem(this.lootSlot)
	GameTooltip:Show()
end

function SmokeyLootAddButton_OnClick()
	if CurrentTab == "raid" then
		SmokeyLoot_ToggleEditEntryFrame(getn(SMOKEYLOOT.RAID) + 1, true)
	elseif CurrentTab == "database" then
		SmokeyLoot_ToggleEditEntryFrame(getn(SMOKEYLOOT.DATABASE) + 1, true)
	end
end

function SmokeyLootAddButton_OnShow()
	if IsOfficer(Me) and getn(SMOKEYLOOT.RAID) == 0 then
		SmokeyLootAddButton:Enable()
	else
		SmokeyLootAddButton:Disable()
	end
end

function SmokeyLoot_EnableRaidControls()
	if getn(SMOKEYLOOT.RAID) > 0 and Master == Me then
		SmokeyLootFinishRaidButton:Enable()
		SmokeyLootAddButton:Enable()
		SmokeyLootClearButton:Enable()
	else
		SmokeyLootFinishRaidButton:Disable()
		SmokeyLootAddButton:Disable()
		SmokeyLootClearButton:Disable()
	end
end

function SmokeyLootClearButton_OnClick()
	arraywipe(SMOKEYLOOT.RAID)
	SmokeyLoot_PushRaid(1)
	SmokeyLootFrame_Update()
end

SLASH_SMOKEYLOOT1 = "/sloot"
SlashCmdList.SMOKEYLOOT = function()
	if GetNumRaidMembers() == 0 then
		print("You need to be in a raid group to query addon version.")
		return
	end
	listwipe(SmokeyAddonVersions)
	for i = 1, GetNumRaidMembers() do
		SmokeyAddonVersions[GetRaidRosterInfo(i)] = -1
	end
	print("Starting addon version check.")
	SendAddonMessage("SmokeyLoot", "REPORT_ADDON_VERSION", "RAID")
	Delay(3, function()
		local outdated = ""
		local noAddon = ""
		local same = ""
		local higher = ""
		local myVersion = tonumber(GetAddOnMetadata("SmokeyLoot", "Version"))
		for k, v in pairs(SmokeyAddonVersions) do
			if k ~= Me then
				if v > myVersion then
					higher = higher..k..", "
				elseif v == myVersion then
					same = same..k..", "
				elseif v < myVersion and v ~= -1 then
					outdated = outdated..k..", "
				elseif v == -1 then
					noAddon = noAddon..k..", "
				end
			end
		end
		print(format("Did not report: %s\nOutdated: %s\nSame version: %s\nHigher version: %s", noAddon, outdated, same, higher))
	end)
end