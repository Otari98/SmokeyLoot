local _G = _G or getfenv(0)
local concat = table.concat
local format = string.format
local strfind = string.find
local strsub = string.sub
local gsub = string.gsub
local getn = table.getn
local tinsert = table.insert
local tremove = table.remove

SmokeyLoot = {}
SmokeyItem = {}
SmokeyLoot.Item = SmokeyItem

function SmokeyItem:Reset()
	self.id = nil
	self.link = nil
	self.slot = nil
	self.winner = nil
	self.winType = nil
	self.winRoll = 0
	self.tmogWinner = nil
	self.tmogWinRoll = 0
	self.tmogIgnored = nil
	self.lowestPlus = 420
	self.lowestHR = 420
	self.lootSource = nil
	self.recieved = nil
	self.givenTo = nil
	self.candidates = ""
	self.candidatesSR = ""
end
SmokeyItem:Reset()

SmokeyLoot.Bosses = {
	-- Molten Core
	["Incindis"] = true,
	["Lucifron"] = true,
	["Magmadar"] = true,
	["Garr"] = true,
	["Shazzrah"] = true,
	["Baron Geddon"] = true,
	["Golemagg the Incinerator"] = true,
	["Basalthar"] = true,
	["Smoldaris"] = true,
	["Sorcerer-Thane Thaurissan"] = true,
	["Sulfuron Harbinger"] = true,
	["Majordomo Executus"] = true,
	["Ragnaros"] = true,
	-- Onyxia's Lair
	["Onyxia"] = true,
	["Broodcommander Axelus"] = true,
	-- Lower Karazhan Halls
	["Master Blacksmith Rolfen"] = true,
	["Brood Queen Araxxna"] = true,
	["Grizikil"] = true,
	["Clawlord Howlfang"] = true,
	["Lord Blackwald II"] = true,
	["Moroes"] = true,
	-- Zul'Gurub
	["High Priestess Jeklik"] = true,
	["High Priest Venoxis"] = true,
	["Witherbark Speaker"] = true,
	["High Priestess Mar'li"] = true,
	["Vilebranch Speaker"] = true,
	["Broodlord Mandokir"] = true,
	["Ohgan"] = true,
	["Gri'lek"] = true,
	["Hazza'rah"] = true,
	["Renataki"] = true,
	["Wushoolay"] = true,
	["Gahz'ranka"] = true,
	["High Priest Thekal"] = true,
	["Zealot Zath"] = true,
	["Zealot Lor'Khan"] = true,
	["High Priestess Arlokk"] = true,
	["Jin'do the Hexxer"] = true,
	["Hakkar"] = true,
	-- Ruins of Ahn'Qiraj
	["Kurinnaxx"] = true,
	["General Rajaxx"] = true,
	["Moam"] = true,
	["Buru the Gorger"] = true,
	["Ayamiss the Hunter"] = true,
	["Ossirian the Unscarred"] = true,
	-- Blackwing Lair
	["Razorgore the Untamed"] = true,
	["Vaelastrasz the Corrupt"] = true,
	["Broodlord Lashlayer"] = true,
	["Firemaw"] = true,
	["Ebonroc"] = true,
	["Flamegor"] = true,
	["Chromaggus"] = true,
	["Nefarian"] = true,
	["Ezzel Darkbrewer"] = true,
	-- Emerald Sanctum
	["Erennius"] = true,
	["Solnius the Awakener"] = true,
	-- Temple of Ahn'Qiraj
	["The Prophet Skeram"] = true,
	["Vem"] = true,
	["Lord Kri"] = true,
	["Princess Yauj"] = true,
	["Battle Guard Sartura"] = true,
	["Fankriss the Unyielding"] = true,
	["Viscidus"] = true,
	["Princess Huhuran"] = true,
	["Emperor Vek'lor"] = true,
	["Emperor Vek'nilash"] = true,
	["Ouro"] = true,
	["C'Thun"] = true,
	-- Naxxramas
	["Patchwerk"] = true,
	["Grobbulus"] = true,
	["Gluth"] = true,
	["Thaddius"] = true,
	["Anub'Rekhan"] = true,
	["Grand Widow Faerlina"] = true,
	["Maexxna"] = true,
	["Noth the Plaguebringer"] = true,
	["Heigan the Unclean"] = true,
	["Loatheb"] = true,
	["Instructor Razuvious"] = true,
	["Gothik the Harvester"] = true,
	["Thane Korth'azz"] = true,
	["Lady Blaumeux"] = true,
	["Highlord Mograine"] = true,
	["Sir Zeliek"] = true,
	["Sapphiron"] = true,
	["Kel'Thuzad"] = true,
	-- Upper karazhan Halls
	["Keeper Gnarlmoon"] = true,
	["Ley-Watcher Incantagos"] = true,
	["Anomalus"] = true,
	["Echo of Medivh"] = true,
	["King"] = true,
	["Sanv Tas'dal"] = true,
	["Rupturan the Broken"] = true,
	["Kruul"] = true,
	["Mephistroth"] = true,
	-- Timbermaw Hold
	["Karrsh the Sentinel"] = true,
	["Rotgowl"] = true,
	["Loktanag the Vile"] = true,
	["Ormanos the Cracked"] = true,
	["Chieftain Partath"] = true,
	["Archdruid Kronn"] = true,
	["Selenaxx Foulheart"] = true,
	["Trioch the Devourer"] = true,
	["Ursol"] = true,
	["Peroth'arn"] = true,
}

local fmt = {
	trade = "|cffffffff|Hplayer:%s|h[%s]|h|r (%d %s) trade %s to |cffffffff|Hplayer:%s|h[%s]|h|r (%d %s)",
	tradeWhisper = "Please, trade %s to |cffffffff|Hplayer:%s|h[%s]|h|r after collecting transmog appearance. <3",
	win = "|cffffffff|Hplayer:%s|h[%s]|h|r wins %s (%d %s)",
}

local Patterns = {
	newMaster = gsub(ERR_NEW_LOOT_MASTER_S, "%%s", "(.+)"), -- "(.+) is now the loot master."
	rollResult = gsub(gsub(RANDOM_ROLL_RESULT, "%%s", "(.+)"), "%%d %(%%d%-%%d%)", "(%%d+) %%(%%d%%-(%%d+)%%)"), -- "(.+) rolls (%d+) %((%d+)%-(%d+)%)"
	memberJoined = gsub(ERR_RAID_MEMBER_ADDED_S, "%%s", "(.+)"), -- "(.+) has joined the raid group"
	memberLeft = gsub(ERR_RAID_MEMBER_REMOVED_S, "%%s", "(.+)"), -- "(.+) has left the raid group"
	resist = gsub(gsub(ITEM_RESIST_SINGLE, "%%c%%d", "+(%%d+)"), "%%s", ".+"), -- "+(%d+) .+ Resistance"
	classes = gsub(ITEM_CLASSES_ALLOWED, "%%s", "(.*)"), -- "Classes: (.*)"
	minLevel = gsub(ITEM_MIN_LEVEL, "%%d", "(.*)"), -- "Requires Level (.*)"
}

local CurrentTab = "DATABASE"

local CurrentLootSource = nil
local Master = nil
local Pusher = nil

local debugMessages = false
local Pulling = false
local Pushing = false
local PushAfter = false
local TargetChangeRegistered = false

local LootButtonsMax = 6
local MaxEntries = 32
-- rerollsMessage = 0
-- tmogRerollsMessage = 0

local SearchResult = {}
local AlreadyRolled = {}
local MyHRItemIDs = {}

local OfficerRanks = {}
OfficerRanks["Dank Sparrow"] = 0
OfficerRanks["Lieutenant Kush"] = 1
OfficerRanks["Hemp Corsair"] = 2

local BongRank = 3

local AltRanks = {}
AltRanks["Swab Toker"] = 7
AltRanks["Hemp Corsair"] = OfficerRanks["Hemp Corsair"]

local ClassColors = {}
for class, color in pairs(RAID_CLASS_COLORS) do
	ClassColors[class] = format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end

local BlacklistItems = {}
BlacklistItems[20739] = true -- Mechanical Horse
BlacklistItems[36550] = true -- Spotted Qiraji Battle Tank
BlacklistItems[36551] = true -- Black Drake
BlacklistItems[92080] = true -- Molten Corehound
BlacklistItems[36666] = true -- Plagued Riding Spider
BlacklistItems[19902] = true -- Swift Zulian Tiger
BlacklistItems[19872] = true -- Armored Razzashi Raptor
BlacklistItems[92082] = true -- Felforged Dreadhound
BlacklistItems[30018] = true -- Emerald Drake
BlacklistItems[30017] = true -- Onyxian Drake

local RankPrioItems = {}
RankPrioItems[61184] = true -- The Scythe of Elune

local Rolls = {}
Rolls.HR = {}
Rolls.SR = {}
Rolls.MS = {}
Rolls.OS = {}
Rolls.TMOG = {}

-- local Rerolls = {}
-- local RerollsTmog = {}

local SmokeyAddonVersions = {}

local TransmogInvTypes = {
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

local axes, axes2H, bows, guns, maces, maces2H, polearms, swords, swords2H, staves, fists, miscellaneous, daggers, thrown, crossbows, wands, fishingPole = GetAuctionItemSubClasses(1)
local miscellaneous, cloth, leather, mail, plate, shields, librams, idols, totems = GetAuctionItemSubClasses(2)
local weapon, armor, container, consumable, tradeGoods, projectile, quiver, recipe, reagent, miscellaneous =  GetAuctionItemClasses(1)
local book, leatherworking, tailoring, engineering, blacksmithing, cooking, alchemy, firstaid, enchanting, fishing, jewelcrafting = GetAuctionItemSubClasses(8)

local L = {
	["Book"] = book,
	["Cloth"] = cloth,
	["Leather"] = leather,
	["Mail"] = mail,
	["Plate"] = plate,
	["Miscellaneous"] = miscellaneous,
	["Daggers"] = daggers,
	["One-Handed Axes"] = axes,
	["One-Handed Swords"] = swords,
	["One-Handed Maces"] = maces,
	["Fist Weapons"] = fists,
	["Polearms"] = polearms,
	["Staves"] = staves,
	["Two-Handed Axes"] = axes2H,
	["Two-Handed Swords"] = swords2H,
	["Two-Handed Maces"] = maces2H,
	["Shields"] = shields,
	["Bows"] = bows,
	["Guns"] = guns,
	["Crossbows"] = crossbows,
	["Wands"] = wands,
	["Weapon"] = weapon,
	["Armor"] = armor,
	["Fishing Pole"] = fishingPole,
	["Librams"] = librams,
	["Idols"] = idols,
	["Totems"] = totems,
	["Thrown"] = thrown,
	["Container"] = container,
	["Consumable"] = consumable,
	["Trade Goods"] = tradeGoods,
	["Recipe"] = recipe,
	["Projectile"] = projectile,
	["Quiver"] = quiver,
	["Reagent"] = reagent,
	["Adds a mount"] = "Adds a mount",
	["Adds a companion"] = "Adds a companion",
}

if GetLocale() == "deDe" then
	L["Adds a mount"] = "Fügt der Reittiersammlung"
	L["Adds a companion"] = "Fügt der Begleitersammlung"

elseif GetLocale() == "esES" then
	L["Adds a mount"] = "Agrega una montura"
	L["Adds a companion"] = "Agrega una mascota"

elseif GetLocale() == "ptBR" then
	L["Adds a mount"] = "Adiciona uma montaria"
	L["Adds a companion"] = "Adiciona um companheiro"

elseif GetLocale() == "zhCN" then
	L["Adds a mount"] = "在玩家的坐骑"
	L["Adds a companion"] = "在玩家的同伴"
end

local SubTypesForClass = {
	DRUID = {
		[L["Cloth"]] = true,
		[L["Leather"]] = true,
		[L["Daggers"]] = true,
		[L["One-Handed Maces"]] = true,
		[L["Fist Weapons"]] = true,
		[L["Two-Handed Maces"]] = true,
		[L["Polearms"]] = true,
		[L["Staves"]] = true,
		[L["Idols"]] = true,
		[L["Miscellaneous"]] = true,
	},
	SHAMAN = {
		[L["Cloth"]] = true,
		[L["Leather"]] = true,
		[L["Mail"]] = true,
		[L["Daggers"]] = true,
		[L["One-Handed Axes"]] = true,
		[L["One-Handed Maces"]] = true,
		[L["Fist Weapons"]] = true,
		[L["Two-Handed Axes"]] = true,
		[L["Two-Handed Maces"]] = true,
		[L["Staves"]] = true,
		[L["Shields"]] = true,
		[L["Totems"]] = true,
		[L["Miscellaneous"]] = true,
	},
	PALADIN = {
		[L["Cloth"]] = true,
		[L["Leather"]] = true,
		[L["Mail"]] = true,
		[L["Plate"]] = true,
		[L["One-Handed Axes"]] = true,
		[L["One-Handed Swords"]] = true,
		[L["One-Handed Maces"]] = true,
		[L["Two-Handed Axes"]] = true,
		[L["Two-Handed Swords"]] = true,
		[L["Two-Handed Maces"]] = true,
		[L["Polearms"]] = true,
		[L["Shields"]] = true,
		[L["Librams"]] = true,
		[L["Miscellaneous"]] = true,
	},
	MAGE = {
		[L["Cloth"]] = true,
		[L["Staves"]] = true,
		[L["Daggers"]] = true,
		[L["One-Handed Swords"]] = true,
		[L["Wands"]] = true,
		[L["Miscellaneous"]] = true,
	},
	WARLOCK = {
		[L["Cloth"]] = true,
		[L["Staves"]] = true,
		[L["Daggers"]] = true,
		[L["One-Handed Swords"]] = true,
		[L["Wands"]] = true,
		[L["Miscellaneous"]] = true,
	},
	PRIEST = {
		[L["Cloth"]] = true,
		[L["Staves"]] = true,
		[L["Daggers"]] = true,
		[L["One-Handed Maces"]] = true,
		[L["Wands"]] = true,
		[L["Miscellaneous"]] = true,
	},
	WARRIOR = {
		[L["Cloth"]] = true,
		[L["Leather"]] = true,
		[L["Mail"]] = true,
		[L["Plate"]] = true,
		[L["Daggers"]] = true,
		[L["Fist Weapons"]] = true,
		[L["Staves"]] = true,
		[L["One-Handed Axes"]] = true,
		[L["One-Handed Swords"]] = true,
		[L["One-Handed Maces"]] = true,
		[L["Two-Handed Axes"]] = true,
		[L["Two-Handed Swords"]] = true,
		[L["Two-Handed Maces"]] = true,
		[L["Polearms"]] = true,
		[L["Shields"]] = true,
		[L["Bows"]] = true,
		[L["Guns"]] = true,
		[L["Crossbows"]] = true,
		[L["Thrown"]] = true,
		[L["Miscellaneous"]] = true,
	},
	ROGUE = {
		[L["Cloth"]] = true,
		[L["Leather"]] = true,
		[L["Daggers"]] = true,
		[L["Fist Weapons"]] = true,
		[L["One-Handed Axes"]] = true,
		[L["One-Handed Swords"]] = true,
		[L["One-Handed Maces"]] = true,
		[L["Bows"]] = true,
		[L["Guns"]] = true,
		[L["Crossbows"]] = true,
		[L["Thrown"]] = true,
		[L["Miscellaneous"]] = true,
	},
	HUNTER = {
		[L["Cloth"]] = true,
		[L["Leather"]] = true,
		[L["Mail"]] = true,
		[L["Daggers"]] = true,
		[L["Fist Weapons"]] = true,
		[L["Staves"]] = true,
		[L["One-Handed Axes"]] = true,
		[L["One-Handed Swords"]] = true,
		[L["Two-Handed Axes"]] = true,
		[L["Two-Handed Swords"]] = true,
		[L["Polearms"]] = true,
		[L["Bows"]] = true,
		[L["Guns"]] = true,
		[L["Crossbows"]] = true,
		[L["Thrown"]] = true,
		[L["Miscellaneous"]] = true,
	}
}

print = print or function(...)
	for i = 1, getn(arg) do arg[i] = tostring(arg[i]) end
	local msg = concat(arg, " ")
	DEFAULT_CHAT_FRAME:AddMessage(msg)
	return msg
end

local function slmsg(message)
	DEFAULT_CHAT_FRAME:AddMessage("|cffabd473[SmokeyLoot]|r "..tostring(message))
end

local function debugprint(...)
	if not debugMessages then return end
	local size = getn(arg)
	for i = 1, size do arg[i] = tostring(arg[i]) end
	local msg = size > 1 and concat(arg, " ") or tostring(arg[1])
	local time = GetTime()
	DEFAULT_CHAT_FRAME:AddMessage("["..format("%.3f", time).."] "..msg)
	return msg, time
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

local temp = {}
local function SortRaidByDisabled()
	arraywipe(temp)
	for i = 1, getn(SMOKEYLOOT.RAID) do
		if SMOKEYLOOT.RAID[i].enabled == false then
			tinsert(temp, SMOKEYLOOT.RAID[i])
			SMOKEYLOOT.RAID[i].delete = true
		end
	end
	for i = getn(SMOKEYLOOT.RAID), 1, -1 do
		if SMOKEYLOOT.RAID[i].delete then
			SMOKEYLOOT.RAID[i].delete = nil
			tremove(SMOKEYLOOT.RAID, i)
		end
	end
	for i = 1, getn(temp) do
		tinsert(SMOKEYLOOT.RAID, temp[i])
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

local ScanTooltip = CreateFrame("GameTooltip", "SmokeyLootScanTooltip", nil, "GameTooltipTemplate")
ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function CacheItem(id)
	if not tonumber(id) or tonumber(id) == 0 then
		return nil
	end
	if not GetItemInfo(id) then
		ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
		ScanTooltip:SetHyperlink("item:"..id)
		return false
	end
	return true
end

local function IsRed(r, g, b)
	if not (r and g and b) then return false end
	return r > 0.9 and g < 0.2 and b < 0.2
end

function CanRollTransmog(itemID, unit)
	itemID = tonumber(itemID)
	if not itemID then return false end

	if not unit then unit = "player" end

	local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)

	-- not equippable
	if not itemEquipLoc or not TransmogInvTypes[itemEquipLoc] then return false end

	-- check collection status if Tmog installed
	if TMOG_CACHE and unit == "player" then
		for slot, collected in pairs(TMOG_CACHE) do
			if collected[itemID] then return false end
		end
	end

	-- every class can equip off hand frills
	if itemEquipLoc == "INVTYPE_HOLDABLE" then return true end

	local class, enClass = UnitClass(unit)

	-- check itemSubTypes for our class
	if not SubTypesForClass[enClass][itemSubType] then return false end

	-- some bullshit combination
	if itemType == L["Weapon"] and itemSubType == L["Miscellaneous"] then return false end

	-- check if it is off-hand weapon
	local canDualWeild = enClass == "WARRIOR" or enClass == "ROGUE" or enClass == "HUNTER"
	if not canDualWeild and itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then return false end

	-- check if its class restricted
	ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	ScanTooltip:ClearLines()
	ScanTooltip:SetHyperlink("item:"..itemID)
	local numLines = ScanTooltip:NumLines()
	numLines = (numLines < 15) and numLines or 15

	for i = 1, numLines do
		local textLeft = _G[ScanTooltip:GetName().."TextLeft"..i]
		if textLeft then
			local text = textLeft:GetText()
			local _, _, classesAllowed = strfind(text or "", (gsub(ITEM_CLASSES_ALLOWED, "%%s", "(.*)")))
			if classesAllowed then
				if not strfind(classesAllowed, class, 1, true) then return false end
			end
		end
	end

	-- all checks passed
	return true
end

function CanRollMS(itemID, unit)
	itemID = tonumber(itemID)
	if not itemID then return nil end
	
	-- Fashion Coin
	if itemID == 51217 then return false end

	if not unit then unit = "player" end

	local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)
	
	if itemType == L["Recipe"] or itemType == L["Container"] or itemType == L["Trade Goods"] then
		return false
	end

	local class, enClass = UnitClass(unit)
	
	if (itemType == L["Armor"] or itemType == L["Weapon"]) and itemEquipLoc ~= "" then
		if not SubTypesForClass[enClass][itemSubType] then return false end
	end

	local tooltipName = ScanTooltip:GetName()
	
	for i = 2, 15 do
		_G[tooltipName.."TextLeft"..i]:SetTextColor(0, 0, 0)
		_G[tooltipName.."TextRight"..i]:SetTextColor(0, 0, 0)
	end
	
	ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	ScanTooltip:ClearLines()
	ScanTooltip:SetHyperlink("item:"..itemID)
	local numLines = ScanTooltip:NumLines()
	numLines = (numLines < 15) and numLines or 15
	for i = 2, numLines do
		local textLeft = _G[tooltipName.."TextLeft"..i]
		local textRight = _G[tooltipName.."TextRight"..i]
		local rL, gL, bL = textLeft:GetTextColor()
		local rR, gR, bR = textRight:GetTextColor()
		local text = textLeft:GetText() or ""
		local _, _, classesAllowed = strfind(text, Patterns.classes)
		local minLevel = strfind(text, Patterns.minLevel)
		if classesAllowed then
			if not strfind(classesAllowed, class, 1, true) then return false end
		end
		if strfind(text, L["Adds a mount"]) or strfind(text, L["Adds a companion"]) then return false end
		if unit == "player" and (IsRed(rL, gL, bL) or IsRed(rR, gR, bR)) and not minLevel then return false end
	end

	return true
end

function IsBongoAlt(name)
	-- if not SMOKEYLOOT.GUILD[name] then return false end
	-- if not SMOKEYLOOT.GUILD[name].main then return false end
	-- if not SMOKEYLOOT.GUILD[name].rankName then return false end
	-- if not AltRanks[SMOKEYLOOT.GUILD[name].rankName] then return false end

	-- local mainInfo = SMOKEYLOOT.GUILD[SMOKEYLOOT.GUILD[name].main]
	-- if not mainInfo then return false end

	-- if tonumber(mainInfo.rankIndex) then
	-- 	return tonumber(mainInfo.rankIndex) <= BongRank
	-- end

	-- return false
end

function IsOfficer(name)
	if name == UnitName("player") then
		local _, myRank = GetGuildInfo("player")
		return OfficerRanks[myRank]
	else
		if SMOKEYLOOT.GUILD[name] and SMOKEYLOOT.GUILD[name].rankName then
			return OfficerRanks[SMOKEYLOOT.GUILD[name].rankName]
		end
	end
end

function IsMasterLooter()
	local method, partyIndex = GetLootMethod()
	return method == "master" and partyIndex == 0
end

local DelayFrame = CreateFrame("Frame")
local FuncQueue = {}

local function Delay(time, func)
	tinsert(FuncQueue, { executeTime = GetTime() + time, func = func })
end

DelayFrame:SetScript("OnUpdate", function()
	if not FuncQueue[1] then return end
	if GetTime() >= FuncQueue[1].executeTime then
		FuncQueue[1].func()
		tremove(FuncQueue, 1)
	end
end)

local function LootPopupOnUpdate()
	if not GetItemInfo(SmokeyItem.id) then
		SmokeyLootPopupFrameMS:EnableMouse(false)
		SmokeyLootPopupFrameMS:SetAlpha(0.5)
		SmokeyLootPopupFrameTmog:EnableMouse(false)
		SmokeyLootPopupFrameTmog:SetAlpha(0.5)
		return
	end

	if CanRollTransmog(SmokeyItem.id) then
		SmokeyLootPopupFrameTmog:EnableMouse(true)
		SmokeyLootPopupFrameTmog:SetAlpha(1)
	else
		SmokeyLootPopupFrameTmog:EnableMouse(false)
		SmokeyLootPopupFrameTmog:SetAlpha(0.5)
	end

	if CanRollMS(SmokeyItem.id) then
		SmokeyLootPopupFrameMS:EnableMouse(true)
		SmokeyLootPopupFrameMS:SetAlpha(1)
	else
		SmokeyLootPopupFrameMS:EnableMouse(false)
		SmokeyLootPopupFrameMS:SetAlpha(0.5)
	end

	SmokeyLootPopupFrame:SetScript("OnUpdate", nil)
end

function SmokeyLoot.OnLoad()
	tinsert(UISpecialFrames, "SmokeyLootFrame")
	this:RegisterForDrag("LeftButton")
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("GUILD_ROSTER_UPDATE")
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterEvent("CHAT_MSG_SYSTEM")
	this:RegisterEvent("CHAT_MSG_LOOT")
	this:RegisterEvent("UI_ERROR_MESSAGE")
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

function SmokeyLoot.RegisterTargetChange()
	local method, partyIndex, raidIndex = GetLootMethod()
	local inInstance, instanceType = IsInInstance()
	if method ~= "master" and GetNumRaidMembers() > 0 and inInstance and instanceType == "raid" and getn(SMOKEYLOOT.RAID) > 0 and IsRaidLeader() then
		if not TargetChangeRegistered then
			SmokeyLootFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
			debugprint("registered PLAYER_TARGET_CHANGED")
			TargetChangeRegistered = true
		end
	else
		if TargetChangeRegistered then
			SmokeyLootFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
			debugprint("unregistered PLAYER_TARGET_CHANGED")
			TargetChangeRegistered = false
		end
	end
end

local lookup = {}
function SmokeyLoot.OnEvent(event, arg1, arg2, arg3, arg4)
	if event == "ADDON_LOADED" and arg1 == "SmokeyLoot" then
		debugprint(event)
		this:UnregisterEvent("ADDON_LOADED")

		if not SMOKEYLOOT then SMOKEYLOOT = {} end
		if not SMOKEYLOOT.DATABASE then SMOKEYLOOT.DATABASE = { date = 0 } end
		if not SMOKEYLOOT.HR then SMOKEYLOOT.HR = {} end
		if not SMOKEYLOOT.GUILD then SMOKEYLOOT.GUILD = {} end
		if not SMOKEYLOOT.RAID then SMOKEYLOOT.RAID = {} end

		SmokeyLootMinimapButton:ClearAllPoints()
		SmokeyLootMinimapButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", unpack(SMOKEYLOOT.POSITION or {SmokeyLootMinimapButton:GetCenter()}))

		SmokeyLoot.EnableRaidControls()
		SmokeyLoot.UpdateHR()

		for _, data in ipairs(SMOKEYLOOT.DATABASE) do
			CacheItem(data.itemID)
		end
		GuildRoster()

	elseif event == "GUILD_ROSTER_UPDATE" then
		debugprint(event)
		if not SMOKEYLOOT then SMOKEYLOOT = {} end
		if not SMOKEYLOOT.GUILD then SMOKEYLOOT.GUILD = {} end

		listwipe(lookup)
		for i = 1, GetNumGuildMembers(true) do
			local name, rank, rankIndex, level, class, zone, note, officerNote, online, status = GetGuildRosterInfo(i)
			if name then
				lookup[name] = true
				if not SMOKEYLOOT.GUILD[name] then SMOKEYLOOT.GUILD[name] = {} end
				SMOKEYLOOT.GUILD[name].rankName = rank
				SMOKEYLOOT.GUILD[name].rankIndex = rankIndex
				SMOKEYLOOT.GUILD[name].class = strupper(class)
				SMOKEYLOOT.GUILD[name].main = AltRanks[rank] and strtrim(strlower(officerNote)) ~= "guild bank" and strtrim(gsub(officerNote, "%..*", "")) or nil
			end
		end

		for name in pairs(SMOKEYLOOT.GUILD) do
			if not lookup[name] then SMOKEYLOOT.GUILD[name] = nil end
		end

		if SmokeyLootFrame:IsShown() then
			SmokeyLoot.UpdateFrame()
		end

	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		Master = SmokeyLoot.GetLootMasterName()
		debugprint(event, "master:", Master)
		SmokeyLoot.EnableRaidControls()
		SmokeyLoot.RegisterTargetChange()

	elseif event == "RAID_ROSTER_UPDATE" then
		debugprint(event)
		SmokeyLoot.UpdateRollers()
		SmokeyLoot.RegisterTargetChange()
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		local isMLmethod
		Master, isMLmethod = SmokeyLoot.GetLootMasterName()
		if isMLmethod and (not Master or Master == UNKNOWN) then
			SendAddonMessage("SmokeyLoot", "GET_ML", "RAID")
		end
		SmokeyLoot.RegisterTargetChange()
		debugprint(event, "master:", Master, "isMLmethod:", isMLmethod)
		
	elseif event == "CHAT_MSG_SYSTEM" then
		local isMaster = IsMasterLooter()
		local _, _, m = strfind(arg1, Patterns.newMaster)

		if m then
			Master = m
			debugprint(event, arg1, "master:", Master)
			SmokeyLoot.EnableRaidControls()
			return
		end

		local _, _, joined = strfind(arg1, Patterns.memberJoined)
		-- local _, _, left = strfind(arg1, Patterns.memberLeft)
		if joined then
			if not isMaster then return end

			for k, v in ipairs(SMOKEYLOOT.RAID) do
				if v.char == joined then
					v.enabled = true
					sort(SMOKEYLOOT.RAID, sortfunc)
					SortRaidByDisabled()
					SmokeyLoot.PushRaid()
					if SmokeyLootFrame:IsShown() then
						SmokeyLoot.UpdateFrame()
					end
					return
				end
			end

			tinsert(SMOKEYLOOT.RAID, {
				item = "",
				bonus = 0,
				itemID = 0,
				char = joined,
				pluses = 0,
				enabled = true,
			})
			sort(SMOKEYLOOT.RAID, sortfunc)
			SortRaidByDisabled()
			SmokeyLoot.PushRaid()

			slmsg(format("%s was not in the raid list, fill their SR info ASAP!", joined))

			if SmokeyLootFrame:IsShown() then
				SmokeyLoot.UpdateFrame()
			end

			return
		end

		-- Reading rolls from chat
		if not SmokeyItem.id then return end

		local _, _, player, roll, max = strfind(arg1, Patterns.rollResult)
		roll, max = tonumber(roll), tonumber(max)
		debugprint(event, "player:", player, "roll:", roll, "max:", max, "AlreadyRolled:", AlreadyRolled[player])

		if isMaster and AlreadyRolled[player] then
			slmsg(format("%s already rolled on %s.", player, SmokeyItem.link))
		end

		if player and roll and max and not AlreadyRolled[player] then
			if not strfind(SmokeyItem.candidates, player, 1, true) then
				if isMaster then
					slmsg(format("%s is not a candidate for %s.", player, SmokeyItem.link))
				end
				return
			end
			local index
			for k, v in ipairs(SMOKEYLOOT.RAID) do
				if v.char == player then
					index = k
				end
			end
			-- try to find player in raid roster in case we cant find in RAID table and add them
			if not index then
				local found = false
				for i = 1, 40 do
					if UnitName("raid"..i) == player then
						found = true
						break
					end
				end

				if not found then
					return
				end

				tinsert(SMOKEYLOOT.RAID, {
					item = "",
					bonus = 0,
					itemID = 0,
					char = player,
					pluses = 0,
					enabled = true,
				})
				sort(SMOKEYLOOT.RAID, sortfunc)
				SortRaidByDisabled()

				SmokeyLoot.PushRaid()

				for k, v in ipairs(SMOKEYLOOT.RAID) do
					if v.char == player then
						index = k
					end
				end
				if isMaster then
					slmsg(format("%s was not in the raid list, fill their SR info ASAP!", player))
				end
				if SmokeyLootFrame:IsShown() then
					SmokeyLoot.UpdateFrame()
				end
			end

			if not index then
				return
			end

			if max > 100 then
				-- this is HR roll
				local isAllowed = false
				for k, v in ipairs(SMOKEYLOOT.DATABASE) do
					if v.itemID == SmokeyItem.id and v.char == player and v.bonus == max then
						isAllowed = true
						break
					end
				end

				if isAllowed then
					if max < SmokeyItem.lowestHR then
						SmokeyItem.lowestHR = max
						listwipe(Rolls.HR)
					end
					if max == SmokeyItem.lowestHR then
						Rolls.HR[player] = roll
					end
				elseif isMaster then
					slmsg(format("%s is not allowed to roll HR on %s.", player, SmokeyItem.link))
				end

			elseif max == 100 then
				-- this is SR roll
				-- if not strfind(SmokeyItem.candidatesSR, player, 1, true) then
				-- 	if isMaster then
				-- 		slmsg(format("%s is not a candidate for %s.", player, SmokeyItem.link))
				-- 	end
				-- 	return
				-- end
				local isAllowed = false
				for k, v in ipairs(SMOKEYLOOT.RAID) do
					if v.itemID == SmokeyItem.id and v.char == player then
						Rolls.SR[player] = roll + (v.bonus ~= -1 and v.bonus or 0)
						isAllowed = true
						break
					end
				end

				if not isAllowed and isMaster then
					slmsg(format("%s is not allowed to roll SR on %s.", player, SmokeyItem.link))
				end

			elseif max == 99 then
				-- this is MS roll
				local isAllowed = false
				for i = 1, 40 do
					if UnitName("raid"..i) == player then
						isAllowed = CanRollMS(SmokeyItem.id, "raid"..i)
						break
					end
				end

				if isAllowed then
					if not SMOKEYLOOT.RAID.isPlusOneRaid or SMOKEYLOOT.RAID[index].pluses == SmokeyItem.lowestPlus then
						Rolls.MS[player] = roll
					elseif SMOKEYLOOT.RAID[index].pluses < SmokeyItem.lowestPlus then
						SmokeyItem.lowestPlus = SMOKEYLOOT.RAID[index].pluses
						Rolls.MS[player] = roll
						-- discard rolls with higher pluses than new lowest plus
						for k, v in pairs(Rolls.MS) do
							for k2, v2 in ipairs(SMOKEYLOOT.RAID) do
								if v2.char == k and v2.pluses > SmokeyItem.lowestPlus then
									Rolls.MS[k] = nil
								end
							end
						end
					end
				elseif isMaster then
					slmsg(format("%s is not allowed to roll MS on %s.", player, SmokeyItem.link))
				end

			elseif max == 98 then
				-- this is OS roll
				Rolls.OS[player] = roll

			elseif max == 97 then
				-- this is Transmog roll
				local isAllowed
				for i = 1, 40 do
					if UnitName("raid"..i) == player then
						isAllowed = CanRollTransmog(SmokeyItem.id, "raid"..i)
						break
					end
				end

				if isAllowed then
					Rolls.TMOG[player] = roll
				elseif isMaster then
					slmsg(format("%s is not allowed to roll Transmog on %s.", player, SmokeyItem.link))
				end
			end

			AlreadyRolled[player] = true
		end

		SmokeyLoot.GetWinner()

		if SmokeyLootMLFrame:IsShown() then
			SmokeyLoot.UpdateMLFrame()
		end

	elseif event == "OPEN_MASTER_LOOT_LIST" or event == "LOOT_OPENED" then
		if event == "LOOT_OPENED" then
			if UnitExists("target") and UnitIsDead("target") and not UnitIsPlayer("target") then
				_, CurrentLootSource = UnitExists("target")
			end
			if not CurrentLootSource then
				CurrentLootSource = "chest"
			end
		end

		local isMLmethod
		Master, isMLmethod = SmokeyLoot.GetLootMasterName()

		if isMLmethod and (not Master or Master == UNKNOWN) then
			SendAddonMessage("SmokeyLoot", "GET_ML", "RAID")
		end

		debugprint(event, "master:", Master, "isMLmethod:", isMLmethod, "CurrentLootSource:", CurrentLootSource)

		if IsMasterLooter() and getn(SMOKEYLOOT.RAID) > 0 then
			if not (GetNumLootItems() == 1 and LootSlotIsCoin(1)) then
				SmokeyLootMLFrame:Show()
			end
			SmokeyLoot.UpdateMLFrame()
		end

	elseif event == "LOOT_CLOSED" then
		if SmokeyItem.id and SmokeyItem.lootSource == CurrentLootSource and CurrentLootSource ~= "chest" and not UnitIsDead(CurrentLootSource) then
			SmokeyLoot.CancelRoll()
		end
		CurrentLootSource = nil
		SmokeyLootMLFrame:Hide()

	elseif event == "LOOT_SLOT_CLEARED" then
		if arg1 == SmokeyItem.slot and SmokeyItem.lootSource == CurrentLootSource and IsMasterLooter() then
			for i = 1, getn(SMOKEYLOOT.RAID) do
				if SMOKEYLOOT.RAID[i].char == SmokeyItem.winner then
					if SmokeyItem.winType == "MS" then
						if SMOKEYLOOT.RAID.isPlusOneRaid then
							SMOKEYLOOT.RAID[i].pluses = SMOKEYLOOT.RAID[i].pluses + 1
						end
					elseif SmokeyItem.winType == "SR" then
						SMOKEYLOOT.RAID[i].bonus = -1
					elseif SmokeyItem.winType == "HR" then
						if not SMOKEYLOOT.RAID[i].gotHR then
							SMOKEYLOOT.RAID[i].gotHR = {}
						end
						tinsert(SMOKEYLOOT.RAID[i].gotHR, SmokeyItem.id)
					end
					break
				end
			end

			local channel = IsRaidOfficer() and "RAID_WARNING" or "RAID"
			if SmokeyItem.recieved and SmokeyItem.givenTo then
				if SmokeyItem.givenTo == SmokeyItem.tmogWinner then
					SendChatMessage(format(fmt.trade, SmokeyItem.tmogWinner, SmokeyItem.tmogWinner, SmokeyItem.tmogWinRoll, "TMOG", SmokeyItem.link, SmokeyItem.winner, SmokeyItem.winner, SmokeyItem.winRoll, SmokeyItem.winType), channel)
					if SmokeyItem.tmogWinner ~= UnitName("player") then
						SendChatMessage(format(fmt.tradeWhisper, SmokeyItem.link, SmokeyItem.winner, SmokeyItem.winner), "WHISPER", nil, SmokeyItem.tmogWinner)
					end
				elseif SmokeyItem.givenTo == SmokeyItem.winner then
					SendChatMessage(format(fmt.win, SmokeyItem.winner, SmokeyItem.winner, SmokeyItem.link, SmokeyItem.winRoll, SmokeyItem.winType), channel)
				end
			end

			SmokeyLoot.CancelRoll()
			SmokeyLoot.PushRaid()
		end

		SmokeyLoot.UpdateRollers()

		if SmokeyLootMLFrame:IsShown() then
			SmokeyLoot.UpdateMLFrame()
		end

		SmokeyLoot.UpdateFrame()

	elseif event == "CHAT_MSG_LOOT" then
		local givenTo = SmokeyItem.givenTo
		if givenTo == UnitName("player") then givenTo = YOU end
		if not SmokeyItem.recieved and givenTo and string.find(arg1, SmokeyItem.link, 1, true) and string.find(arg1, givenTo, 1, true) then
			SmokeyItem.recieved = true
		end

	elseif event == "UI_ERROR_MESSAGE" then
		if SmokeyItem.givenTo then
			if arg1 == ERR_LOOT_GONE
				or arg1 == ERR_LOOT_MASTER_INV_FULL
				or arg1 == ERR_LOOT_MASTER_OTHER
				or arg1 == ERR_LOOT_MASTER_UNIQUE_ITEM
				or arg1 == ERR_LOOT_PLAYER_NOT_FOUND
			then
				SmokeyItem.givenTo = nil
				SmokeyItem.recieved = nil
			end
		end

	elseif event == "CHAT_MSG_ADDON" and arg1 == "SmokeyLoot" then
		local message = arg2
		local channel = arg3
		local sender = arg4

		if channel == "RAID" then
			if strfind(message, "^StartRoll") and sender == SmokeyLoot.GetLootMasterName() then
				-- starting roll, show popup
				local _, _, id, name, texture, candidatesSR, candidates, count, quality, link = strfind(message, "StartRoll:(%d*);(.*);(.*);(.*);(.*);(%d*);(%d*);(.*)")

				if not strfind(candidates or "", UnitName("player")) then
					return
				end

				debugprint(message)
				SmokeyLootPopupFrameIconFrameIcon:SetTexture(texture)
				SmokeyLootPopupFrameIconFrameCount:SetText(tonumber(count) > 1 and count or "")
				SmokeyLootPopupFrameIconFrame.itemString = gsub(link, ".*|H(.-)|h.*", "%1", 1)
				SmokeyLootPopupFrameIconFrame.link = link
				local r, g, b = GetItemQualityColor(tonumber(quality))
				SmokeyLootPopupFrameName:SetText(name)
				SmokeyLootPopupFrameName:SetTextColor(r, g, b)
				SmokeyLootPopupFrame:Show()
				SmokeyItem.id = tonumber(id)
				SmokeyItem.link = link
				SmokeyItem.candidatesSR = candidatesSR
				SmokeyItem.candidates = candidates
				CacheItem(SmokeyItem.id)

				if MyHRItemIDs[SmokeyItem.id] then
					SmokeyLootPopupFrameHR:EnableMouse(true)
					SmokeyLootPopupFrameHR:SetAlpha(1)
				else
					SmokeyLootPopupFrameHR:EnableMouse(false)
					SmokeyLootPopupFrameHR:SetAlpha(0.5)
				end

				if strfind(candidatesSR or "", UnitName("player"), 1, true) then
					SmokeyLootPopupFrameSR:EnableMouse(true)
					SmokeyLootPopupFrameSR:SetAlpha(1)
				else
					SmokeyLootPopupFrameSR:EnableMouse(false)
					SmokeyLootPopupFrameSR:SetAlpha(0.5)
				end

				SmokeyLootPopupFrame:SetScript("OnUpdate", LootPopupOnUpdate)

			elseif sender ~= UnitName("player") then
				if strfind(message, "^EndRoll") and sender == SmokeyLoot.GetLootMasterName() then
					-- ending roll, hide popup
					SmokeyLootPopupFrame:Hide()
					SmokeyItem:Reset()
					SmokeyLoot.UpdateRollers()

				elseif message == "REPORT_ADDON_VERSION" then
					debugprint(message, sender)
					SendAddonMessage("SmokeyLoot", "V_"..GetAddOnMetadata("SmokeyLoot", "Version"), "RAID")

				elseif strfind(message, "^V_") then
					local v = tonumber(strsub(message, 3))
					SmokeyAddonVersions[sender] = v or 0
					debugprint(message, sender)

				elseif message == "GET_ML" then
					-- share loot master name
					local name = SmokeyLoot.GetLootMasterName()
					if name then
						SendAddonMessage("SmokeyLoot", "ML_"..name, "RAID")
					end
					debugprint(message, sender)

				elseif strfind(message, "ML_", 1, true) then
					local m = strsub(message, 4)
					for i = 1, GetNumRaidMembers() do
						if m == GetRaidRosterInfo(i) then
							Master = m
							break
						end
					end
					debugprint(message, sender, "master:", Master)
					SmokeyLoot.EnableRaidControls()

				-- raid update
				elseif strfind(message, "R_start", 1, true) then
					local usingPlus = strsub(message, 9, 9)
					local isBongoAlt = strsub(message, 11, 11)
					debugprint(message, "usingPlus:", usingPlus, "bongoAlt:", isBongoAlt)
					arraywipe(SMOKEYLOOT.RAID)
					SMOKEYLOOT.RAID.isPlusOneRaid = usingPlus == "1"
					SMOKEYLOOT.RAID.isBongoAltRaid = isBongoAlt == "1"

				elseif message == "R_end" then
					SmokeyLoot.UpdateFrame()
					debugprint(message, sender)

				elseif message == "R_clear" then
					debugprint(message, sender)
					arraywipe(SMOKEYLOOT.RAID)
					SmokeyLoot.UpdateFrame()

				else
					local _, _, key, itemID, item, char, bonus, pluses, enabled, gotHR = strfind(message, "^(%d+);(%d+);(.*);(.*);(%-?%d+);(%d+);(%d);(.*)")
					if key then
						tinsert(SMOKEYLOOT.RAID, tonumber(key), {
							itemID = tonumber(itemID),
							item = item,
							char = char,
							bonus = tonumber(bonus),
							pluses = tonumber(pluses),
							enabled = enabled == "1",
							gotHR = (gotHR ~= "" and strsplit(gotHR, ",")) or nil
						})
					end
				end
			end

		elseif channel == "GUILD" and sender ~= UnitName("player") then
			-- sync stuff here
			if message == "GET_DB_LATEST" and IsOfficer(UnitName("player")) then
				debugprint("DB requested by", sender)
				SendAddonMessage("SmokeyLoot", "VDB_"..SMOKEYLOOT.DATABASE.date, "GUILD")
				return
			end
			if strfind(message, "^VDB_%d+") then
				local _, _, date = strfind(message, "^VDB_(%d+)")
				if tonumber(date) > tonumber(SMOKEYLOOT.DATABASE.date) and IsOfficer(sender) then
					SendAddonMessage("SmokeyLoot", "PULL_FROM_"..sender, "GUILD")
				end
				return
			end
			if message == "PULL_FROM_"..UnitName("player") and IsOfficer(UnitName("player")) then
				SmokeyLoot.Push(sender)
				return
			end
			if not Pusher and strfind(message, "^start;%d+;%d+") then
				debugprint(message, sender)

				local _, _, date, max = strfind(message, "start;(%d+);(%d+)")
				if tonumber(date) > tonumber(SMOKEYLOOT.DATABASE.date) and IsOfficer(sender) then
					arraywipe(SMOKEYLOOT.DATABASE)
					arraywipe(SMOKEYLOOT.HR)
					
					Pusher = sender
					SMOKEYLOOT.DATABASE.date = tonumber(date)

					SmokeyLootFrameProgressBar:Show()
					SmokeyLootFrameProgressBar:SetMinMaxValues(0, tonumber(max))
					SmokeyLootFrameProgressBar:SetValue(0)
					SmokeyLootFrameProgressBarText:SetText("0%")
					SmokeyLootFrameDBDate:SetText("Database version: updating...")
					SmokeyLootPullButton:Hide()
					slmsg("Updating database, provided by "..Pusher..", please, stay online until its done.")
				end

			elseif sender and sender == Pusher then
				if strfind(message, "^end;%d+") then
					debugprint(message, sender)

					Pusher = nil
					Pulling = false

					SmokeyLootFrameProgressBar:Hide()
					if CurrentTab ~= "RAID" then
						SmokeyLootPullButton:Show()
					end
					SmokeyLootPullButton:Enable()

					if PushAfter then
						PushAfter = false
						SmokeyLoot.FinishRaidRoutine()
						SmokeyLoot.Push()
					end

					SmokeyLoot.UpdateHR()
					SmokeyLoot.UpdateFrame()
					slmsg("Database is updated.")
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

						local min, max = SmokeyLootFrameProgressBar:GetMinMaxValues()

						SmokeyLootFrameProgressBar:SetValue(index)
						SmokeyLootFrameProgressBarText:SetText(format("%.0f%%", index / max * 100))
					end
				end
			end
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		local targetName = UnitName("target")
		if not targetName then return end
		debugprint(event, targetName)
		if SmokeyLoot.Bosses[targetName] then
			SetLootMethod("master", (UnitName("player")))
		end
	end
end

function SmokeyLoot.Toggle()
	if SmokeyLootFrame:IsShown() then
		HideUIPanel(SmokeyLootFrame)
	else
		ShowUIPanel(SmokeyLootFrame)
	end
end

function SmokeyLoot.Autocomplete()
	-- local text = SmokeyLootFrameSearchBox:GetText()
	-- local name
	-- for i = 1, GetNumGuildMembers(true) do
	-- 	name = GetGuildRosterInfo(i)
	-- 	if strfind(strlower(name), strlower(text), 1, true) == 1 then
	-- 		SmokeyLootFrameSearchBox:SetText(name)
	-- 		SmokeyLootFrameSearchBox:HighlightText(strlen(text), -1)
	-- 		return
	-- 	end
	-- end
	-- for i = 1, getn(SMOKEYLOOT.DATABASE) do
	-- 	name = SMOKEYLOOT.DATABASE[i].item
	-- 	if strfind(strupper(name), strupper(text), 1, true) == 1 then
	-- 		SmokeyLootFrameSearchBox:SetText(name)
	-- 		SmokeyLootFrameSearchBox:HighlightText(strlen(text), -1)
	-- 		return
	-- 	end
	-- end
end

function SmokeyLoot.UpdateFrame()
	arraywipe(SearchResult)

	local tableToUpdate = SMOKEYLOOT[CurrentTab]
	local query = strtrim(SmokeyLootFrameSearchBox:GetText())

	if query ~= "" then
		if SmokeyLootFrameSearchBoxExact:GetChecked() then
			for i = 1, getn(tableToUpdate) do
				local item = tableToUpdate[i].item or ""
				local char = tableToUpdate[i].char or ""
				if char == query or item == query then tinsert(SearchResult, i) end
			end
		else
			query = strlower(query)
			for i = 1, getn(tableToUpdate) do
				local item = tableToUpdate[i].item or ""
				local char = tableToUpdate[i].char or ""
				if strfind(strlower(item), query, 1, true) or strfind(strlower(char), query, 1, true) then tinsert(SearchResult, i) end
			end
		end
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

		if tableToUpdate[entryIndex] and entryIndex > 0 and entryIndex <= numEntries then
			local icon = _G["SmokeyLootEntry"..i.."Icon"]
			local itemColumn = _G["SmokeyLootEntry"..i.."Text"]
			local charColumn = _G["SmokeyLootEntry"..i.."Column1"]
			local rankColumn = _G["SmokeyLootEntry"..i.."Column2"]
			local bonusColumn = _G["SmokeyLootEntry"..i.."Column3"]
			local itemID = tableToUpdate[entryIndex].itemID
			local item = tableToUpdate[entryIndex].item
			local char = tableToUpdate[entryIndex].char
			local bonus = tableToUpdate[entryIndex].bonus
			local class = SMOKEYLOOT.GUILD[char] and SMOKEYLOOT.GUILD[char].class
			local rankName = SMOKEYLOOT.GUILD[char] and SMOKEYLOOT.GUILD[char].rankName

			CacheItem(itemID)

			local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)
			local r, g, b = 1, 0.2, 0.2

			if itemQuality then
				r, g, b = GetItemQualityColor(itemQuality)
			end

			itemColumn:SetText(itemName or item or "")
			itemColumn:SetTextColor(r, g, b)
			itemColumn:SetWidth(char and 200 or 0)
			charColumn:SetText(char)
			icon:SetTexture(itemTexture or "")
			icon:Show()

			if class and rankName and RAID_CLASS_COLORS[class] then
				charColumn:SetTextColor(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b)
				if IsBongoAlt(char) then
					rankColumn:SetText(rankName.."*")
				else
					rankColumn:SetText(rankName)
				end
			else
				charColumn:SetTextColor(1, 0.2, 0.2)
				rankColumn:SetText()
			end

			bonusColumn:SetText(bonus)

			if bonus and bonus <= 0 then
				bonusColumn:SetText()
				if bonus == -1 then
					icon:SetTexture("Interface\\AddOns\\SmokeyLoot\\Textures\\Check")
					icon:Show()
				end
			end

			entry.data = tableToUpdate[entryIndex]
			entry.data.class = class
			entry:SetID(entryIndex)
			entry:Show()

			if GetMouseFocus() == entry then
				entry:Hide()
				entry:Show()
			end

			if tableToUpdate == SMOKEYLOOT.RAID then
				local enabled = tableToUpdate[entryIndex].enabled
				entry:SetAlpha(enabled and 1 or 0.5)
			else
				entry:SetAlpha(1)
			end
		else
			entry:Hide()
		end
	end

	SmokeyLootFrameDBDate:SetText(date("Database version: %d/%m/%y %H:%M:%S", SMOKEYLOOT.DATABASE.date))

	-- check version only when we are not scrolling
	if type(arg1) ~= "number" then
		if SMOKEYLOOT.DATABASE.date >= SmokeyLoot.GetRemoteVersion() then
			SmokeyLootFrameStatus:SetText("Latest")
			SmokeyLootFrameStatus:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
			SmokeyLootPullButton:Disable()
		else
			SmokeyLootFrameStatus:SetText("Outdated")
			SmokeyLootFrameStatus:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			SmokeyLootPullButton:Enable()
		end
	end
end

local EntryTooltip = CreateFrame("GameTooltip", "SmokeyLootEntryTooltip", UIParent, "GameTooltipTemplate")

function SmokeyLoot.Entry_OnEnter()
	this:SetBackdropColor(1, 1, 1, 0.5)

	if not this.data then
		return
	end

	GameTooltip:SetOwner(this, "ANCHOR_NONE")
	EntryTooltip:SetOwner(this, "ANCHOR_NONE")

	if CurrentTab == "HR" then
		if this.data.itemID > 0 then
			GameTooltip:SetHyperlink("item:"..this.data.itemID)
		end

		local str = "Hard reserve queue:\n"

		for k, v in ipairs(this.data) do
			str = str..k..". "
			for k2, v2 in ipairs(v) do
				if SMOKEYLOOT.GUILD[v2] and SMOKEYLOOT.GUILD[v2].class then
					str = str..ClassColors[SMOKEYLOOT.GUILD[v2].class]..v2.."|r"
				else
					str = str..RED_FONT_COLOR_CODE..v2.."|r"
				end
				str = v[k2 + 1] and str..", " or str
			end
			str = str.."\n"
		end
		EntryTooltip:AddLine(str)

	elseif CurrentTab == "RAID" then

		if this.data.itemID > 0 then
			GameTooltip:SetHyperlink("item:"..this.data.itemID)
		end

		local color = this.data.class and ClassColors[this.data.class] or RED_FONT_COLOR_CODE
		local char = color..this.data.char.." |r"..GRAY_FONT_COLOR_CODE.."(Not in the raid)|r"

		for i = 1, 40 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
			if name and name == this.data.char then
				color = ClassColors[fileName]
				if not online then
					char = color..this.data.char.." |r"..GRAY_FONT_COLOR_CODE.."("..zone..")|r"
				else
					char = color..this.data.char.."|r"
				end
				break
			end
		end

		EntryTooltip:AddLine(format("%s\nitemID:%d\npluses:%d\ngotHR: %s", char, this.data.itemID, this.data.pluses, this.data.gotHR and concat(this.data.gotHR, ", ") or "no"))
	
	elseif CurrentTab == "DATABASE" then
		if this.data.itemID > 0 then
			GameTooltip:SetHyperlink("item:"..this.data.itemID)
			EntryTooltip:AddLine("itemID: "..this.data.itemID)
		end
	end

	EntryTooltip:SetPoint("BOTTOMRIGHT", this, "TOPLEFT", -14, 0)
	GameTooltip:SetPoint("TOPRIGHT", EntryTooltip, "BOTTOMRIGHT", 0, 0)
	GameTooltip:Show()
	EntryTooltip:Show()

	local top = GameTooltip:GetTop()
	local bottom = EntryTooltip:GetBottom()

	if (top and bottom) and (top > bottom) then
		EntryTooltip:ClearAllPoints()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPRIGHT", this, "BOTTOMLEFT", -14, 0)
		EntryTooltip:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", 0, 0)
	end
end

function SmokeyLoot.Entry_OnLeave()
	this:SetBackdropColor(1, 1, 1, 0.2)
	GameTooltip:Hide()
	EntryTooltip:Hide()
end

function SmokeyLoot.Entry_OnClick()
	if IsShiftKeyDown() then
		if not (this.data and SmokeyLootEditEntryFrame:IsShown()) then
			return
		end
		-- copy paste values
		-- local editBoxID = SmokeyLootEditEntryFrame.editBoxInFocus
		-- if editBoxID == 1 or editBoxID == 2 then
			if this.data.item then
				SmokeyLootEditEntryFrameEditBox1:SetText(this.data.item)
			end
			if this.data.itemID then
				SmokeyLootEditEntryFrameEditBox2:SetNumber(this.data.itemID)
			end
		-- end
		-- if this.data.char and editBoxID == 3 then
			SmokeyLootEditEntryFrameEditBox3:SetText(this.data.char)
		-- end
		-- if this.data.bonus and editBoxID == 4 then
			SmokeyLootEditEntryFrameEditBox4:SetText(this.data.bonus)
		-- end
	elseif CurrentTab == "DATABASE" or CurrentTab == "RAID" then
		SmokeyLoot.ToggleEditEntryFrame(this:GetID())
	end
end

function SmokeyLoot.GetBonus(itemID, char)
	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if v.itemID == tonumber(itemID) and v.char == char then
			return v.bonus or 0
		end
	end
	return nil
end

local __ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
ChatFrame_OnHyperlinkShow = function(link, text, button)
	if not (IsShiftKeyDown() and SmokeyLootEditEntryFrame:IsShown()) then
		return __ChatFrame_OnHyperlinkShow(link, text, button)
	end
	local name = strsub(link, 8)
	if name and strlen(name) > 0 then
		name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3")
		name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2")
	end
	local _, _, itemID = strfind(link or "", "item:(%d+)")
	itemID = tonumber(itemID) or 0
	local itemName = GetItemInfo(itemID)
	if not itemName and text then
		text = gsub(text, "|cff%x%x%x%x%x%x", "")
		text = gsub(text, "|r", "")
		_, _, itemName = strfind(text, "%[(.-)%]")
	end
	-- local editBoxID = SmokeyLootEditEntryFrame.editBoxInFocus
	if itemName and itemID then
		-- if editBoxID == 1 or editBoxID == 2 then
			SmokeyLootEditEntryFrameEditBox1:SetText(strtrim(itemName))
			SmokeyLootEditEntryFrameEditBox2:SetNumber(itemID)
		-- end
	elseif name and strlen(name) > 0 then
		SmokeyLootEditEntryFrameEditBox3:SetText(name)
		local id = SmokeyLootEditEntryFrameEditBox2:GetNumber()
		if id then
			local bonus = SmokeyLoot.GetBonus(id, name) or 0
			SmokeyLootEditEntryFrameEditBox4:SetText(bonus)
		end
	else
		__ChatFrame_OnHyperlinkShow(link, text, button)
	end
end

function SmokeyLoot.Roll(choise)
	if choise == "PASS" or not SmokeyItem.id then
		SmokeyLootPopupFrame:Hide()
		return
	end

	local min = 1
	local max

	if choise == "HR" then
		for k, v in ipairs(SMOKEYLOOT.DATABASE) do
			if v.itemID == SmokeyItem.id and v.char == UnitName("player") and v.bonus > 100 then
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

local function ApplyBongoAltRule(rollType)
	-- if not tonumber(SmokeyItem.id) then
	-- 	return
	-- end

	-- if not SMOKEYLOOT.RAID.isBongoAltRaid then
	-- 	return
	-- end

	-- -- check if any "main" rolled
	-- for k, v in pairs(Rolls[rollType]) do
	-- 	if SMOKEYLOOT.GUILD[k].rankIndex ~= AltRanks["Swab Toker"] then
	-- 		-- found some non Swab Toker
	-- 		for k2, v2 in pairs(Rolls[rollType]) do
	-- 			-- discard Swab Toker roll if not a bongo alt
	-- 			if not IsBongoAlt(k2) and SMOKEYLOOT.GUILD[k2].rankIndex == AltRanks["Swab Toker"] then
	-- 				if IsMasterLooter() then
	-- 					slmsg(format("Non-bongo alt roll discarded: %s %d", k2, v2))
	-- 				end
	-- 				Rolls[rollType][k2] = nil
	-- 			end
	-- 		end
	-- 		break
	-- 	end
	-- end
end

local ranks = {}

local function ApplyRankPrioRule(rollType)
	if not tonumber(SmokeyItem.id) then
		return
	end

	local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(SmokeyItem.id)

	if itemType ~= L["Recipe"] and not RankPrioItems[SmokeyItem.id] then
		return
	end

	if itemSubType == L["Book"] then
		return
	end

	-- ranks go in reverse, lower number - higher rank
	arraywipe(ranks)

	for name in pairs(Rolls[rollType]) do
		local rank = tonumber(SMOKEYLOOT.GUILD[name].rankIndex)
		if SMOKEYLOOT.GUILD[name] and rank then
			if rank == AltRanks["Hemp Corsair"] then
				rank = AltRanks["Swab Toker"]
			elseif rank == OfficerRanks["Dank Sparrow"] or rank == OfficerRanks["Lieutenant Kush"] then
				rank = BongRank
			end
			tinsert(ranks, rank)
		end
	end

	local highestRank = min(unpack(ranks))

	for name, roll in pairs(Rolls[rollType]) do
		if SMOKEYLOOT.GUILD[name] and tonumber(SMOKEYLOOT.GUILD[name].rankIndex) > highestRank then
			if IsMasterLooter() then
				slmsg(format("Low rank roll discarded: %s %d (%s). Highest rank: %s", name, roll, SMOKEYLOOT.GUILD[name].rankName, GuildControlGetRankName(highestRank + 1)))
			end
			Rolls[rollType][name] = nil
		end
	end
end

function SmokeyLoot.GetWinner()
	SmokeyItem.winner = nil
	SmokeyItem.winRoll = 0
	SmokeyItem.winType = nil
	SmokeyItem.tmogWinner = nil
	SmokeyItem.tmogWinRoll = 0

	if next(Rolls.HR) then
		for k, v in pairs(Rolls.HR) do
			if v > SmokeyItem.winRoll then
				SmokeyItem.winRoll = v
				SmokeyItem.winner = k
				SmokeyItem.winType = "HR"
				-- arraywipe(Rerolls)
			end
		end
	elseif next(Rolls.SR) then
		for k, v in pairs(Rolls.SR) do
			if v > SmokeyItem.winRoll then
				SmokeyItem.winRoll = v
				SmokeyItem.winner = k
				SmokeyItem.winType = "SR"
				-- arraywipe(Rerolls)
			end
		end
	elseif next(Rolls.MS) then
		ApplyBongoAltRule("MS")
		ApplyRankPrioRule("MS")
		for k, v in pairs(Rolls.MS) do
			if v > SmokeyItem.winRoll then
				SmokeyItem.winRoll = v
				SmokeyItem.winner = k
				SmokeyItem.winType = "MS"
				-- arraywipe(Rerolls)
			end
		end
	elseif next(Rolls.OS) then
		ApplyBongoAltRule("OS")
		ApplyRankPrioRule("OS")
		for k, v in pairs(Rolls.OS) do
			if v > SmokeyItem.winRoll then
				SmokeyItem.winRoll = v
				SmokeyItem.winner = k
				SmokeyItem.winType = "OS"
				-- arraywipe(Rerolls)
			end
		end
	elseif next(Rolls.TMOG) then
		ApplyBongoAltRule("TMOG")
		for k, v in pairs(Rolls.TMOG) do
			if v > SmokeyItem.winRoll then
				SmokeyItem.winRoll = v
				SmokeyItem.winner = k
				SmokeyItem.winType = "TMOG"
				-- arraywipe(Rerolls)
			end
		end
	end

	if SmokeyItem.winner and next(Rolls.TMOG) then
		for k, v in pairs(Rolls.TMOG) do
			if v > SmokeyItem.tmogWinRoll and k ~= SmokeyItem.winner then
				SmokeyItem.tmogWinRoll = v
				SmokeyItem.tmogWinner = k
				-- arraywipe(RerollsTmog)
			end
		end
	end
	-- if not IsMasterLooter() then
	-- 	return
	-- end
	-- -- check if someone else had the same roll
	-- if SmokeyItem.winner then
	-- 	for k, v in pairs(Rolls[SmokeyItem.winType]) do
	-- 		if v ~= SmokeyItem.winRoll then
	-- 			debug("Rerolls", k, v)
	-- 			tinsert(Rerolls, k)
	-- 		end
	-- 	end
	-- 	if getn(Rerolls) > 1 and getn(Rerolls) > rerollsMessage then
	-- 		SmokeyItem.winner = Rerolls[random(1, getn(Rerolls))]
	-- 		slmsg(format("Auto rerolling for %s . . .", concat(Rerolls, ", ")))
	-- 		slmsg(format("Winner: %s (%s)", SmokeyItem.winner, SmokeyItem.winType))
	-- 		rerollsMessage = getn(Rerolls)
	-- 	end
	-- end
	-- if SmokeyItem.tmogWinner then
	-- 	for k, v in pairs(Rolls.TMOG) do
	-- 		if v == SmokeyItem.tmogWinRoll and k ~= SmokeyItem.winner then
	-- 			debug("RerollsTmog",k,v)
	-- 			tinsert(RerollsTmog, k)
	-- 		end
	-- 	end
	-- 	if getn(RerollsTmog) > 1 and getn(RerollsTmog) > tmogRerollsMessage then
	-- 		SmokeyItem.tmogWinner = RerollsTmog[random(1, getn(RerollsTmog))]
	-- 		slmsg(format("Auto rerolling for %s . . .", concat(RerollsTmog, ", ")))
	-- 		slmsg(format("Transmog winner: %s", SmokeyItem.tmogWinner))
	-- 		tmogRerollsMessage = getn(RerollsTmog)
	-- 	end
	-- end
	debugprint("winner:", SmokeyItem.winner, "tmogWinner:", SmokeyItem.tmogWinner)
end

local Candidates = {}
local SRCandidates = {}

function SmokeyLoot.StartOrEndRoll(slot)
	if not slot then return end

	local link = GetLootSlotLink(slot)
	local _, _, itemID = strfind(link or "", "item:(%d+)")
	itemID = tonumber(itemID)
	if not itemID then return end

	local itemTexture, itemName, itemCount, itemQuality = GetLootSlotInfo(slot)

	if not SmokeyItem.id and CurrentLootSource then
		-- Start Roll
		SmokeyItem.id = itemID
		SmokeyItem.slot = slot
		SmokeyItem.link = link
		SmokeyItem.lowestPlus = 420
		SmokeyItem.lowestHR = 420
		SmokeyItem.lootSource = CurrentLootSource
		
		listwipe(Rolls)
		arraywipe(SRCandidates)
		arraywipe(Candidates)

		local numRaidMembers = GetNumRaidMembers()
		local _, _, _, _, _, _, myZone = GetRaidRosterInfo(numRaidMembers)
		for i = 1, 40 do
			local candidate = GetMasterLootCandidate(i)
			for j = 1, numRaidMembers do
				local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(j)
				if name == candidate and zone == myZone and online then
					tinsert(Candidates, candidate)
					for k, v in ipairs(SMOKEYLOOT.RAID) do
						if v.itemID == itemID and v.bonus ~= -1 and v.char == candidate then
							tinsert(SRCandidates, candidate)
							break
						end
					end
					break
				end
			end
		end

		SmokeyItem.candidatesSR = concat(SRCandidates, ",")
		SmokeyItem.candidates = concat(Candidates, ",")

		SendChatMessage("Starting roll on "..link, IsRaidOfficer() and "RAID_WARNING" or "RAID")
		SendAddonMessage("SmokeyLoot", format("StartRoll:%d;%s;%s;%s;%s;%d;%d;%s", itemID, itemName, itemTexture, SmokeyItem.candidatesSR, SmokeyItem.candidates, itemCount, itemQuality, link), "RAID")

	else
		-- End Roll
		if not SmokeyItem.winner and not SmokeyItem.tmogWinner then
			SmokeyLoot.CancelRoll()
			return
		end

		if itemID == SmokeyItem.id then
			local winnerFound = false
			if GetNumRaidMembers() > 0 then
				local name
				SmokeyItem.tmogIgnored = SmokeyLootMLFrameIgnoreTmog:GetChecked()
				if SmokeyItem.tmogWinner and not SmokeyItem.tmogIgnored then
					name = SmokeyItem.tmogWinner
				else
					name = SmokeyItem.winner
				end
				for i = 1, 40 do
					if name == GetMasterLootCandidate(i) then
						-- if SmokeyItem.lootSource ~= "chest" then
							SmokeyItem.givenTo = name
							SmokeyItem.recieved = nil
							GiveMasterLoot(SmokeyItem.slot, i)
							winnerFound = true
						-- else
						-- 	SmokeyLoot.OnEvent("LOOT_SLOT_CLEARED", SmokeyItem.slot)
						-- end
						break
					end
				end
			end
			if not winnerFound then
				slmsg("Roll cancelled - winner was not found in candidates list.")
				SmokeyLoot.CancelRoll()
			end
			SmokeyLootPopupFrame:Hide()
		end
	end

	SmokeyLoot.UpdateMLFrame()
end

function SmokeyLoot.CancelRoll()
	SmokeyLootPopupFrame:Hide()
	if IsMasterLooter() then
		SendAddonMessage("SmokeyLoot", "EndRoll", "RAID")
	end
	SmokeyItem:Reset()
	SmokeyLoot.UpdateMLFrame()
	SmokeyLoot.UpdateRollers()
end

function SmokeyLoot.UpdateMLFrame()
	local numItems = GetNumLootItems()
	
	if numItems == 1 and LootSlotIsCoin(1) or numItems < 1 then
		SmokeyLootMLFrame:Hide()
		return
	end

	for i = 1, LootButtonsMax do
		_G["SmokeyLootMLFrameLoot"..i]:Hide()
	end

	local buttonIndex = 1

	for i = 1, numItems do
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
				icon:SetTexture(itemIcon)
				name:SetText(itemName)
				local r, g, b = GetItemQualityColor(quality)
				name:SetTextColor(r, g, b)
				count:SetText(itemCount > 1 and itemCount or "")
				button.lootSlot = i
				winnerText:SetText("...")

				local showSRText = false
				for k, v in ipairs(SMOKEYLOOT.RAID) do
					if v.itemID == id and v.enabled then showSRText = true break end
				end
				if showSRText then
					srText:Show()
				else
					srText:Hide()
				end
				
				if SmokeyItem.id then
					if SmokeyItem.id == id and SmokeyItem.lootSource == CurrentLootSource then
						SmokeyItem.slot = i
						if SmokeyItem.winner then
							local text = SmokeyItem.winner.." ("..SmokeyItem.winType..")"
							if SmokeyItem.tmogWinner and not SmokeyLootMLFrameIgnoreTmog:GetChecked() then
								text = SmokeyItem.tmogWinner.." (TMOG)->"..text
							end
							winnerText:SetText(text)
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

function SmokeyLoot.UpdateRollers()
	if not SmokeyItem.id then
		listwipe(AlreadyRolled)
		for i = 1, 40 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
			if name and online then
				AlreadyRolled[name] = false
			end
		end
	end
end

function SmokeyLoot.Import()
	local text = strtrim(SmokeyImportText:GetText())
	text = gsub(text, ',"', ",")
	text = gsub(text, '",', ",")

	local split = strsplit(text, "\n")

	SMOKEYLOOT.RAID.isPlusOneRaid = SmokeyLootImportFrameEnablePlusOne:GetChecked() and true or false
	SMOKEYLOOT.RAID.isBongoAltRaid = SmokeyLootImportFrameEnableBongoAltRule:GetChecked() and true or false

	for i = 1, getn(split) do
		local _, _, id, itemName, char = strfind(split[i], "^(%d+),(.+),(.+)$")
		if id then
			-- get players bonus on this item
			local bonus = 0
			for k, v in ipairs(SMOKEYLOOT.DATABASE) do
				if v.itemID == tonumber(id) and v.char == char then
					bonus = v.bonus
					break
				end
			end
			-- disable if player is not in the raid
			local enabled = false
			for j = 1, 40 do
				local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(j)
				if name and name == char then
					enabled = true
					break
				end
			end
			local index = arrcontains(SMOKEYLOOT.RAID, char)
			if index then
				-- if player found in the list, just refresh item
				SMOKEYLOOT.RAID[index].itemID = tonumber(id)
				SMOKEYLOOT.RAID[index].item = itemName
				SMOKEYLOOT.RAID[index].bonus = bonus
			else
				tinsert(SMOKEYLOOT.RAID, { char = char, itemID = tonumber(id), item = itemName, bonus = bonus, pluses = 0, enabled = enabled })
			end
		end
	end

	-- add raid members without SR
	for i = 1, 40 do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
		if name and not arrcontains(SMOKEYLOOT.RAID, name) then
			tinsert(SMOKEYLOOT.RAID, { char = name, itemID = 0, item = "", bonus = 0, pluses = 0, enabled = true })
		end
	end

	sort(SMOKEYLOOT.RAID, sortfunc)
	SortRaidByDisabled()

	SmokeyLootImportFrame:Hide()
	SmokeyLoot.UpdateFrame()
	SmokeyLoot.EnableRaidControls()
	SmokeyLoot.PushRaid()
	SmokeyLoot.RegisterTargetChange()
end

function SmokeyLoot.Export()
	if not ExportFile then
		return
	end
	local output = ""
	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		output = output..v.itemID.."\t"..v.item.."\t"..v.char.."\t"..v.bonus.."\n"
	end
	ExportFile("sl_database_"..date("%d.%m.%y_%H.%M.%S", SMOKEYLOOT.DATABASE.date), output)
end

function SmokeyLoot.SwitchTab(switchTo)
	arraywipe(SearchResult)

	CurrentTab = switchTo

	if switchTo == "RAID" then
		SmokeyLootImportButton:Show()
		SmokeyLootFinishRaidButton:Show()
		SmokeyLootClearButton:Show()
		SmokeyLootAddButton:Show()
		SmokeyLoot.EnableRaidControls()
		SmokeyLootPullButton:Hide()

	elseif switchTo == "DATABASE" then
		SmokeyLootImportButton:Hide()
		SmokeyLootFinishRaidButton:Hide()
		SmokeyLootClearButton:Hide()
		SmokeyLootAddButton:Show()

		if IsOfficer(UnitName("player")) and getn(SMOKEYLOOT.RAID) == 0 then
			SmokeyLootAddButton:Enable()
		else
			SmokeyLootAddButton:Disable()
		end

		if not SmokeyLootFrameProgressBar:IsShown() then
			SmokeyLootPullButton:Show()
		end

	elseif switchTo == "HR" then
		SmokeyLootImportButton:Hide()
		SmokeyLootFinishRaidButton:Hide()
		SmokeyLootClearButton:Hide()
		SmokeyLootAddButton:Hide()

		if not SmokeyLootFrameProgressBar:IsShown() then
			SmokeyLootPullButton:Show()
		end
	end

	SmokeyLootScrollFrame:SetVerticalScroll(0)
	SmokeyLoot.UpdateFrame()
end

function SmokeyLoot.FinishRaidRoutine()
	for i = getn(SMOKEYLOOT.RAID), 1, -1 do
		local id = SMOKEYLOOT.RAID[i].itemID
		local bonus = SMOKEYLOOT.RAID[i].bonus
		local char = SMOKEYLOOT.RAID[i].char
		local gotHR = SMOKEYLOOT.RAID[i].gotHR
		local enabled = SMOKEYLOOT.RAID[i].enabled
		-- check if player got any of their HR items
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
		-- remove if had nothing reserved or mount or reserved when already hr, or disabled
		if enabled == false or id == 0 or BlacklistItems[id] or bonus > 90 then
			tremove(SMOKEYLOOT.RAID, i)
		elseif bonus == -1 then -- check if got their sr
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
	slmsg("Following players got +10:")

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

		slmsg(format("%s %d %s %d -> %d", v.item, v.itemID, v.char, v.bonus, newBonus))
	end

	arraywipe(SMOKEYLOOT.RAID)
	listwipe(SMOKEYLOOT.RAID)

	SmokeyLoot.PushRaid(true)
	SmokeyLoot.SetRemoteVersion()
	SmokeyLoot.UpdateHR()
	SmokeyLoot.UpdateFrame()

	slmsg("New date "..date("%d/%m/%y %H:%M:%S", SMOKEYLOOT.DATABASE.date))
end

function SmokeyLoot.FinishRaidButton_OnClick()
	slmsg("Finishing raid.")
	SmokeyLootFinishRaidButton:Disable()
	SmokeyLoot.Pull()

	PushAfter = true

	Delay(1, function()
		if SmokeyLoot.GetRemoteVersion() <= SMOKEYLOOT.DATABASE.date then
			PushAfter = false
			SmokeyLoot.FinishRaidRoutine()
			SmokeyLoot.Push()
		end
	end)
end

function SmokeyLoot.Pull()
	GuildRoster()

	if Pulling then
		return
	end

	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		Pulling = true
		SmokeyLootPullButton:Disable()
		debugprint("Requesting database")
		SendAddonMessage("SmokeyLoot", "GET_DB_LATEST", "GUILD")
	end

	Delay(5, function()
		if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
			Pulling = false
			SmokeyLootPullButton:Enable()
			slmsg("Looks like there is no one online who can share the latest database.")
		end
	end)
end

function SmokeyLoot.Push(player)
	if not IsOfficer(UnitName("player")) or Pushing or Pusher or SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		return
	end

	local dbPushFrame = SmokeyLootDBPushFrame or CreateFrame("Frame", "SmokeyLootDBPushFrame")
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

	debugprint("Pushing database")
	if player then
		slmsg("Sharing database, requested by "..player..", please, stay online until it's done.")
	end

	dbPushFrame:SetScript("OnUpdate", function()
		if messages[count] then
			SendAddonMessage("SmokeyLoot", count.."="..messages[count], "GUILD")
			count = count + 1
		end

		if count > getn(messages) then
			dbPushFrame:SetScript("OnUpdate", nil)
			SendAddonMessage("SmokeyLoot", "end;"..SMOKEYLOOT.DATABASE.date, "GUILD")
			Pushing = false
			debugprint("Database push finished")
			slmsg("Database is shared.")
		end
	end)
end

local messages = {}
function SmokeyLoot.PushRaid(clear)
	if not IsMasterLooter() then
		return
	end

	if clear then
		debugprint("Clearing raid")
		SendAddonMessage("SmokeyLoot", "R_clear", "RAID")
		return
	end

	local raidPushFrame = SmokeyLootRaidPushFrame or CreateFrame("Frame", "SmokeyLootRaidPushFrame")
	arraywipe(messages)
	local str

	sort(SMOKEYLOOT.RAID, sortfunc)
	SortRaidByDisabled()

	for k, v in ipairs(SMOKEYLOOT.RAID) do
		if type(v) == "table" then
			str = k..";"..v.itemID..";"..v.item..";"..v.char..";"..v.bonus..";"..v.pluses..";"..(v.enabled and "1" or "0")..";"..(v.gotHR and concat(v.gotHR, ",") or "")
			tinsert(messages, str)
		end
	end

	if not str then
		return
	end

	SendAddonMessage("SmokeyLoot", "R_start;"..(SMOKEYLOOT.RAID.isPlusOneRaid and 1 or 0)..";"..(SMOKEYLOOT.RAID.isBongoAltRaid and 1 or 0), "RAID")
	
	debugprint("Pushing raid")
	
	local count = 1

	raidPushFrame:SetScript("OnUpdate", function()
		SendAddonMessage("SmokeyLoot", messages[count], "RAID")
		count = count + 1

		if count > getn(messages) then
			raidPushFrame:SetScript("OnUpdate", nil)
			SendAddonMessage("SmokeyLoot", "R_end", "RAID")
			debugprint("Raid push finished")
		end
	end)
end

function SmokeyLoot.CheckDBSanity()
	if not IsOfficer(UnitName("player")) then
		return
	end

	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		slmsg("You need to get latest database first.")
		return
	end

	local nonmembers, duplicates = 0, 0

	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if not SMOKEYLOOT.GUILD[v.char] then
			slmsg(format("Non guild member entry: %s %s itemID: %d bonus: %d", v.char, v.item, v.itemID, v.bonus))
			nonmembers = nonmembers + 1
		end
	end
	local seen = {}
	local dup = {}
	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if not seen[v.itemID..v.char] then
			seen[v.itemID..v.char] = true
		else
			tinsert(dup, v)
		end
	end
	for k, v in ipairs(dup) do
		slmsg(format("duplicated entry %d %s %s",v.itemID, v.item, v.char))
	end
	duplicates = getn(dup)

	slmsg(format("Non guild member entries (potentially): %d, duplicated entries: %d", nonmembers, duplicates))
end

function SmokeyLoot.GetRemoteVersion()
	GuildRoster()
	local _, _, n, v = strfind(GetGuildInfoText(), "\n(%a*)(%d+)$")
	v = tonumber(v) or 0
	n = n or ""
	return v, date("%d/%m/%y %H:%M:%S", v), n
end

function SmokeyLoot.SetRemoteVersion()
	if not IsOfficer(UnitName("player")) then
		return
	end

	GuildRoster()
	SMOKEYLOOT.DATABASE.date = time()
	local stamp = UnitName("player")..SMOKEYLOOT.DATABASE.date
	local guildInfo = GetGuildInfoText()
	guildInfo = gsub(GetGuildInfoText(), "\n%a*%d+$", "")
	guildInfo = guildInfo.."\n"..stamp
	SetGuildInfoText(guildInfo)

	debugprint("new version set", stamp)
end

function SmokeyLoot.GetLootMasterName()
	local method, partyIndex, raidIndex = GetLootMethod()
	if method ~= "master" then return nil, false end
	if partyIndex == 0 then return UnitName("player"), true end
	if partyIndex then return UnitName("party"..partyIndex), true end
	if raidIndex then return UnitName("raid"..raidIndex), true end
	if Master then return Master, true end
	return nil, true
end

function SmokeyLoot.UpdateHR()
	arraywipe(SMOKEYLOOT.HR)
	listwipe(MyHRItemIDs)

	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if v.bonus > 100 then
			local pos = v.bonus - 100
			local hrIndex = arrcontains(SMOKEYLOOT.HR, v.itemID)

			if not hrIndex then
				tinsert(SMOKEYLOOT.HR, { item = v.item, itemID = v.itemID })
				hrIndex = getn(SMOKEYLOOT.HR)
			end

			if not SMOKEYLOOT.HR[hrIndex][pos] then
				SMOKEYLOOT.HR[hrIndex][pos] = {}
			end

			tinsert(SMOKEYLOOT.HR[hrIndex][pos], v.char)

			if v.char == UnitName("player") then
				MyHRItemIDs[v.itemID] = true
			end
		end
	end

	debugprint("HR list updated, my HR items:")

	for id in pairs(MyHRItemIDs) do
		debugprint(id, (GetItemInfo(id)))
	end
end

function SmokeyLoot.ToggleEditEntryFrame(id, add)
	if SmokeyLootEditEntryFrame:IsShown() then
		SmokeyLootEditEntryFrame:Hide()
		return
	end

	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		slmsg("You need to get latest database first.")
		return
	end
	
	SmokeyLootEditEntryFrame:Show()
	SmokeyLootEditEntryFrame.id = id
	SmokeyLootEditEntryFrame.add = add
	SmokeyLootEditEntryFrame.tab = CurrentTab

	if CurrentTab == "DATABASE" then
		if not IsOfficer(UnitName("player")) then
			SmokeyLootEditEntryFrame:Hide()
			return
		end
		SmokeyLootEditEntryFrameEntryIndex:SetText("Database Entry " .. id)
		SmokeyLootEditEntryFrameEditBox1:SetText(add and "" or SMOKEYLOOT.DATABASE[id].item)
		SmokeyLootEditEntryFrameEditBox2:SetNumber(add and 0 or SMOKEYLOOT.DATABASE[id].itemID)
		SmokeyLootEditEntryFrameEditBox3:SetText(add and "" or SMOKEYLOOT.DATABASE[id].char)
		SmokeyLootEditEntryFrameEditBox4:SetText(add and 0 or SMOKEYLOOT.DATABASE[id].bonus)
		SmokeyLootEditEntryFrameEditBox5:Hide()
		SmokeyLootEditEntryFramePluses:Hide()
		SmokeyLootEditEntryFrameEnabled:Hide()
		SmokeyLootEditEntryFrameEnabledCheckBox:Hide()
		SmokeyLootEditEntryFrameHint:SetText("Shift-click entries or chat links to copy paste values")

	elseif CurrentTab == "RAID" then
		if not IsMasterLooter() then
			SmokeyLootEditEntryFrame:Hide()
			return
		end
		SmokeyLootEditEntryFrameEntryIndex:SetText("Raid Entry # " .. id)
		SmokeyLootEditEntryFrameEditBox1:SetText(add and "" or SMOKEYLOOT.RAID[id].item)
		SmokeyLootEditEntryFrameEditBox2:SetNumber(add and 0 or SMOKEYLOOT.RAID[id].itemID)
		SmokeyLootEditEntryFrameEditBox3:SetText(add and "" or SMOKEYLOOT.RAID[id].char)
		SmokeyLootEditEntryFrameEditBox4:SetText(add and 0 or SMOKEYLOOT.RAID[id].bonus)
		SmokeyLootEditEntryFrameEnabled:Show()
		SmokeyLootEditEntryFrameEnabledCheckBox:Show()
		SmokeyLootEditEntryFrameEnabledCheckBox:SetChecked(SMOKEYLOOT.RAID[id].enabled)

		if SMOKEYLOOT.RAID.isPlusOneRaid then
			SmokeyLootEditEntryFrameEditBox5:SetNumber(add and 0 or SMOKEYLOOT.RAID[id].pluses)
			SmokeyLootEditEntryFrameEditBox5:Show()
			SmokeyLootEditEntryFramePluses:Show()
		else
			SmokeyLootEditEntryFrameEditBox5:SetNumber(0)
			SmokeyLootEditEntryFrameEditBox5:Hide()
			SmokeyLootEditEntryFramePluses:Hide()
		end

		SmokeyLootEditEntryFrameHint:SetText("Shift-click entries or chat links to copy paste values\nSet bonus to -1 for recieved SR")
	end

	if add then
		SmokeyLootEditEntryFrameDeleteButton:Hide()
	else
		SmokeyLootEditEntryFrameDeleteButton:Show()
	end
end

function SmokeyLoot.EditEntryFrame_OnHide()
	SmokeyLootEditEntryFrame.id = nil
	SmokeyLootEditEntryFrame.add = nil
	SmokeyLootEditEntryFrame.tab = nil
	SmokeyLoot.UpdateFrame()
end

function SmokeyLoot.EditEntryFrameAcceptButton_OnClick()
	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		slmsg("You need to get latest database first.")
		return
	end
	local tab = SmokeyLootEditEntryFrame.tab
	local id = SmokeyLootEditEntryFrame.id
	local newItem = strtrim(SmokeyLootEditEntryFrameEditBox1:GetText())
	local newItemID = SmokeyLootEditEntryFrameEditBox2:GetNumber()
	local newChar = strtrim(SmokeyLootEditEntryFrameEditBox3:GetText())
	local newBonus = tonumber(strtrim(SmokeyLootEditEntryFrameEditBox4:GetText()))
	local newEnabled = SmokeyLootEditEntryFrameEnabledCheckBox:GetChecked() and true or false
	
	if tab == "DATABASE" then
		if not IsOfficer(UnitName("player")) then
			SmokeyLootEditEntryFrame:Hide()
			return
		end
		if SmokeyLootEditEntryFrame.add then
			for k, v in ipairs(SMOKEYLOOT.DATABASE) do
				if v.char == newChar and v.itemID == newItemID then
					slmsg("Such entry already exists.")
					return
				end
			end
			tinsert(SMOKEYLOOT.DATABASE, id, {})
		end

		SMOKEYLOOT.DATABASE[id].item = newItem
		SMOKEYLOOT.DATABASE[id].itemID = newItemID
		SMOKEYLOOT.DATABASE[id].char = newChar
		SMOKEYLOOT.DATABASE[id].bonus = newBonus

		sort(SMOKEYLOOT.DATABASE, sortfunc)

		SmokeyLoot.SetRemoteVersion()
		SmokeyLoot.UpdateHR()

	elseif tab == "RAID" then
		if not IsMasterLooter() then
			SmokeyLootEditEntryFrame:Hide()
			return
		end
		local newPluses = SmokeyLootEditEntryFrameEditBox5:GetNumber()

		if SmokeyLootEditEntryFrame.add then
			for k, v in ipairs(SMOKEYLOOT.RAID) do
				if v.char == newChar and v.itemID == newItemID then
					slmsg("Such entry already exists.")
					return
				end
			end

			tinsert(SMOKEYLOOT.RAID, id, {})

			-- check if this item char combo exists in database, add pluses if it does
			for k, v in ipairs(SMOKEYLOOT.DATABASE) do
				if v.itemID == newItemID and v.char == newChar then
					-- use item name from database
					SMOKEYLOOT.RAID[id].item = v.item
					SMOKEYLOOT.RAID[id].bonus = v.bonus
					break
				end
			end

			SMOKEYLOOT.RAID[id].item = SMOKEYLOOT.RAID[id].item or newItem
			SMOKEYLOOT.RAID[id].bonus = SMOKEYLOOT.RAID[id].bonus or newBonus
		else
			SMOKEYLOOT.RAID[id].item = newItem
			SMOKEYLOOT.RAID[id].bonus = newBonus
		end

		SMOKEYLOOT.RAID[id].itemID = newItemID
		SMOKEYLOOT.RAID[id].char = newChar
		SMOKEYLOOT.RAID[id].pluses = newPluses
		SMOKEYLOOT.RAID[id].enabled = newEnabled

		SmokeyLoot.PushRaid()
	end

	SmokeyLootEditEntryFrame:Hide()
end

function SmokeyLoot.EditEntryFrameDeleteButton_OnClick()
	if CurrentTab == "DATABASE" and IsOfficer(UnitName("player")) then
		if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
			slmsg("You need to get latest database first.")
			return
		end
		tremove(SMOKEYLOOT.DATABASE, SmokeyLootEditEntryFrame.id)
		SmokeyLoot.UpdateHR()
		SmokeyLoot.SetRemoteVersion()

	elseif CurrentTab == "RAID" and IsMasterLooter() then
		tremove(SMOKEYLOOT.RAID, SmokeyLootEditEntryFrame.id)
		SmokeyLoot.PushRaid()
	end

	SmokeyLootEditEntryFrame:Hide()
end

function SmokeyLoot.Button_OnEnter()
	if not this.lootSlot then
		return
	end

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetLootItem(this.lootSlot)
	GameTooltip:Show()
end

function SmokeyLoot.Button_OnClick()
	if not this.lootSlot then
		return
	end

	if IsControlKeyDown() then
		DressUpItemLink(GetLootSlotLink(this.lootSlot))

	elseif IsShiftKeyDown() then
		if ChatFrameEditBox:IsVisible() then
			ChatFrameEditBox:Insert(GetLootSlotLink(this.lootSlot))
		end
	end
end

function SmokeyLoot.AddButton_OnClick()
	SmokeyLoot.ToggleEditEntryFrame(getn(SMOKEYLOOT[CurrentTab]) + 1, true)
end

function SmokeyLoot.AddButton_OnShow()
	if (CurrentTab == "DATABASE" and not IsOfficer(UnitName("player"))) or (CurrentTab == "RAID" and not IsMasterLooter()) then
		SmokeyLootAddButton:Disable()
		return
	end

	if (CurrentTab == "RAID" and getn(SMOKEYLOOT.RAID) > 0) or (CurrentTab == "DATABASE" and getn(SMOKEYLOOT.RAID) == 0) then
		SmokeyLootAddButton:Enable()
	else
		SmokeyLootAddButton:Disable()
	end
end

function SmokeyLoot.EnableRaidControls()
	if CurrentTab ~= "RAID" then
		return
	end

	if getn(SMOKEYLOOT.RAID) > 0 and IsMasterLooter() then
		SmokeyLootFinishRaidButton:Enable()
		SmokeyLootAddButton:Enable()
		SmokeyLootClearButton:Enable()
	else
		SmokeyLootFinishRaidButton:Disable()
		SmokeyLootAddButton:Disable()

		if GetNumRaidMembers() == 0 and getn(SMOKEYLOOT.RAID) > 0 then
			SmokeyLootClearButton:Enable()
		else
			SmokeyLootClearButton:Disable()
		end
	end
end

function SmokeyLoot.ClearButton_OnClick()
	arraywipe(SMOKEYLOOT.RAID)
	SmokeyLoot.EnableRaidControls()
	SmokeyLoot.PushRaid(true)
	SmokeyLoot.UpdateFrame()
end

local LootLinks = {}

function SmokeyLoot.AnnounceLoot()
	arraywipe(LootLinks)

	for index = 1, GetNumLootItems() do
		local link = GetLootSlotLink(index)
		local _, _, count = GetLootSlotInfo(index)

		if link then
			if count > 1 then
				tinsert(LootLinks, link.."x"..count)
			else
				tinsert(LootLinks, link)
			end
		end
	end

	local channel = IsRaidOfficer() and "RAID_WARNING" or "RAID"
	local firstSent = false

	for i = 1, getn(LootLinks) do
		local msg = ""

		if not firstSent then
			msg = "Loot: "
			firstSent = true
		end

		local length = strlen(msg)

		while LootLinks[i] and length + strlen(LootLinks[i]) <= ChatFrameEditBox:GetMaxLetters() do
			msg = msg..LootLinks[i]
			length = strlen(msg)
			i = i + 1
		end

		i = i - 1
		SendChatMessage(msg, channel)
	end
end

SLASH_SMOKEYLOOT1 = "/sloot"

SlashCmdList.SMOKEYLOOT = function(cmd)
	if cmd == "versions" then
		if GetNumRaidMembers() == 0 then
			slmsg("You need to be in a raid group to query addon version.")
			return
		end

		listwipe(SmokeyAddonVersions)

		for i = 1, GetNumRaidMembers() do
			SmokeyAddonVersions[GetRaidRosterInfo(i)] = -1
		end

		slmsg("Starting addon version check.")

		SendAddonMessage("SmokeyLoot", "REPORT_ADDON_VERSION", "RAID")

		Delay(3, function()
			local outdated = ""
			local noAddon = ""
			local same = ""
			local higher = ""
			local myVersion = tonumber(GetAddOnMetadata("SmokeyLoot", "Version"))

			for k, v in pairs(SmokeyAddonVersions) do
				if k ~= UnitName("player") then
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
			local fmt = ""
			if noAddon ~= "" then fmt = "Did not report: %s" end
			if outdated ~= "" then fmt = fmt.."\nOutdated: %s" end
			if same ~= "" then fmt = fmt.."\nSame version: %s" end
			if higher ~= "" then fmt = fmt.."\nHigher version: %s" end
			slmsg(format(fmt, noAddon, outdated, same, higher))
		end)

	elseif cmd == "debug" then
		debugMessages = not debugMessages
		slmsg("debug messages: "..tostring(debugMessages))

	else
		slmsg("/sloot versions - query raid members addon version\n/sloot debug - toggle debug messages")
	end
end
