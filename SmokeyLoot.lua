_G = _G or getfenv(0)
local Sauce = PizzaSauce

SmokeyLoot = {}
SmokeyItem = {}
SmokeyLoot.Item = SmokeyItem

local RollWeights = { ["HR"] = 4, ["SR"] = 3, ["MS"] = 2, ["OS"] = 1, ["TMOG"] = 1 }

local Sounds = {
	dropped = { "choir", "alert", "rizz", "drumroll", "zelda-item", "soad-wake-up" },
	won = { "jackpot", "mission-complete", "confetti", "duck", "congrats", "epicsaxguy", "gigachad-phonk", "money", "livesey" },
	lost = { "sad", "wasted", "not-fine", "spongebob", "pacman", "loser-tune", "loser-horn", "mario", "bo-womp", "titanic", "meow", "guts", "sad-trumpet" },
	outrolled = { "faaah", "fart", "bruh", "shocked", "hell-nah", "oof", "bo-womp", "wth", "oh-no", "oh-nou", "nope" },
	rolled69 = { "noice", "nice" },
	rolled1 = { "faaah", "bruh", "shocked", "hell-nah", "oof", "haha", "wasted", "omg", "sad-trumpet", "bo-womp", "wth" },
	rolled100 = { "drop", "mlg-ohhh", "mlg-legolas", "headshot", "mlg", "turn-down-for-what", "damn-son", "gigachad" },
	unwinnable = { "stupid-boy", "are-you-stupid", "freeman-you-fool", "bruh", "bo-womp", "huh", "confused-song", "nope", "crazy" },
}

SmokeyLoot.NonTradeableBosses = {
	["Lord Kazzak"] = true,
	["Azuregos"] = true,
	["Cla'ckora"] = true,
	["Emeriss"] = true,
	["Lethon"] = true,
	["Taerar"] = true,
	["Ysondre"] = true,
	["Nerubian Overseer"] = true,
	["Dark Reaver of Karazhan"] = true,
	["Ostarius"] = true,
	["Concavius"] = true,
	["Moo"] = true,
	["High Marshal Whirlaxis"] = true,
	["Prince Skaldrenox"] = true,
	["Baron Kazum"] = true,
	["Lord Skwol"] = true,
}

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
	newMaster = string.gsub(ERR_NEW_LOOT_MASTER_S, "%%s", "(.+)"), -- "(.+) is now the loot master."
	rollResult = string.gsub(string.gsub(RANDOM_ROLL_RESULT, "%%s", "(.+)"), "%%d %(%%d%-%%d%)", "(%%d+) %%((%%d+)%%-(%%d+)%%)"), -- "(.+) rolls (%d+) %((%d+)%-(%d+)%)"
	memberJoined = string.gsub(ERR_RAID_MEMBER_ADDED_S, "%%s", "(.+)"), -- "(.+) has joined the raid group"
	memberLeft = string.gsub(ERR_RAID_MEMBER_REMOVED_S, "%%s", "(.+)"), -- "(.+) has left the raid group"
	resist = string.gsub(string.gsub(ITEM_RESIST_SINGLE, "%%c%%d", "+(%%d+)"), "%%s", ".+"), -- "+(%d+) .+ Resistance"
	classes = string.gsub(ITEM_CLASSES_ALLOWED, "%%s", "(.*)"), -- "Classes: (.*)"
	minLevel = string.gsub(ITEM_MIN_LEVEL, "%%d", "(.*)"), -- "Requires Level (.*)"
}

local CurrentTab = "DATABASE"

local CurrentLootSource = nil
local Master = nil
local PullingFrom = nil
local DBSyncInProgress = false
local InitiatedDBSync = false
local DBSyncInitiator = nil
local Pushing = false

local TargetChangeRegistered = false

local LootButtonsMax = 6
local MaxEntries = 32

local SearchResult = {}
local AlreadyRolled = {}
local MyHRItemIDs = {}

local OfficerRanks = {
	["Dank Sparrow"] = 0,
	["Lieutenant Kush"] = 1,
	["Hemp Corsair"] = 2,
}

local BongRank = 3

local AltRanks = {
	["Swab Toker"] = 7,
	["Hemp Corsair"] = OfficerRanks["Hemp Corsair"],
}

local ClassColors = {}
for class, color in pairs(RAID_CLASS_COLORS) do
	ClassColors[class] = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end

local BlacklistItems = {
	[20739] = true, -- Mechanical Horse
	[36550] = true, -- Spotted Qiraji Battle Tank
	[36551] = true, -- Black Drake
	[92080] = true, -- Molten Corehound
	[36666] = true, -- Plagued Riding Spider
	[19902] = true, -- Swift Zulian Tiger
	[19872] = true, -- Armored Razzashi Raptor
	[92082] = true, -- Felforged Dreadhound
	[30018] = true, -- Emerald Drake
	[30017] = true, -- Onyxian Drake
	[17966] = true, -- Onyxia Hide Backpack
}

local RankPrioItems = {
	[61184] = true, -- The Scythe of Elune
}

local Rolls = {
	HR = {},
	SR = {},
	MS = {},
	OS = {},
	TMOG = {},
}

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

local function printf(f, ...)
	DEFAULT_CHAT_FRAME:AddMessage("|cffabd473[SmokeyLoot]|r "..string.format(tostring(f), unpack(arg)))
end

local function debugprint(...)
	if not SmokeyLootConfig.debugMessages then return end
	for i = 1, table.getn(arg) do arg[i] = tostring(arg[i]) end
	DEFAULT_CHAT_FRAME:AddMessage("["..string.format("%.3f", GetTime()).."] "..table.concat(arg, " "))
end

local function debugprintf(fmt, ...)
	if not SmokeyLootConfig.debugMessages then return end
	DEFAULT_CHAT_FRAME:AddMessage("["..string.format("%.3f", GetTime()).."] "..string.format(tostring(fmt), unpack(arg)))
end

local function strsplit(str, delimiter)
	if not str then return {} end
	local splitresult = {}
	local from = 1
	local delim_from, delim_to = string.find(str, delimiter, from, true)
	while delim_from do
		table.insert(splitresult, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from, true)
	end
	table.insert(splitresult, string.sub(str, from))
	return splitresult
end

local function strtrim(s)
	return (string.gsub(s or "", "^%s*(.-)%s*$", "%1"))
end

local function arraywipe(arr)
	if type(arr) ~= "table" then return end
	for i = table.getn(arr), 1, -1 do table.remove(arr, i) end
end

local function listwipe(list)
	for k in pairs(list) do
		if type(list[k]) == "table" then
			for k2 in pairs(list[k]) do list[k][k2] = nil end
		else
			list[k] = nil
		end
	end
end

function SmokeyItem:Reset()
	self.id = nil
	self.link = nil
	self.slot = nil
	self.winner = nil
	self.winType = nil
	self.winRoll = 0
	self.tmogWinner = nil
	self.tmogWinRoll = 0
	self.tmogIgnored = false
	self.lowestPlus = 420
	self.lowestHR = 420
	self.lootSource = nil
	-- self.recieved = nil
	self.givenTo = nil
	self.candidates = ""
	self.candidatesSR = ""
	self.choise = nil
	listwipe(Rolls)
end
SmokeyItem:Reset()

local temp = {}
local function SortRaidByDisabled()
	arraywipe(temp)
	for i = 1, table.getn(SMOKEYLOOT.RAID) do
		if SMOKEYLOOT.RAID[i].enabled == false then
			table.insert(temp, SMOKEYLOOT.RAID[i])
			SMOKEYLOOT.RAID[i].delete = true
		end
	end
	for i = table.getn(SMOKEYLOOT.RAID), 1, -1 do
		if SMOKEYLOOT.RAID[i].delete then
			SMOKEYLOOT.RAID[i].delete = nil
			table.remove(SMOKEYLOOT.RAID, i)
		end
	end
	for i = 1, table.getn(temp) do
		table.insert(SMOKEYLOOT.RAID, temp[i])
	end
end

local function sortfunc(a, b)
	local nameA, nameB = GetItemInfo(a.itemID or 0), (GetItemInfo(b.itemID or 0))
	if a.itemID and b.itemID and a.itemID == b.itemID then
		return a.bonus > b.bonus
	elseif nameA and nameB then
		return nameA < nameB
	else
		return a.char < b.char
	end
end

local function arrcontains(array, value)
	if type(array) ~= "table" then return end
	for i = 1, table.getn(array) do
		if type(array[i]) == "table" then
			for k in pairs(array[i]) do
				if array[i][k] == value then return i end
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
	if not tonumber(id) or tonumber(id) == 0 then return nil end
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
	local _, race = UnitRace(unit)

	-- check itemSubTypes for our class
	if not SubTypesForClass[enClass][itemSubType] and not (enClass == "PRIEST" and race == "NightElf" and itemSubType == L["Bows"]) then return false end

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
			local _, _, classesAllowed = string.find(text or "", Patterns.classes)
			if classesAllowed and not string.find(classesAllowed, class, 1, true) then return false end
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
		local _, _, classesAllowed = string.find(text, Patterns.classes)
		local minLevel = string.find(text, Patterns.minLevel)
		if classesAllowed then
			if not string.find(classesAllowed, class, 1, true) then return false end
		end
		if string.find(text, L["Adds a mount"]) or string.find(text, L["Adds a companion"]) then return false end
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

function SmokeyLoot.IsOfficer(name)
	if not name or name == UnitName("player") then
		local _, myRank = GetGuildInfo("player")
		return IsInGuild() and OfficerRanks[myRank] ~= nil
	else
		local member = SMOKEYLOOT.GUILD[name]
		if member and member.rankName then
			return OfficerRanks[member.rankName] ~= nil
		end
	end
end

function IsMasterLooter()
	local method, partyIndex = GetLootMethod()
	return method == "master" and partyIndex == 0
end

local DelayFrame = CreateFrame("Frame")
local FuncQueue = {}
DelayFrame.dbElapsed = nil
DelayFrame.dbTimeout = 5

local function QueueFunction(delay, func)
	table.insert(FuncQueue, { executeTime = GetTime() + delay, func = func })
end

DelayFrame:SetScript("OnUpdate", function()
	if DelayFrame.dbElapsed and PullingFrom then
		DelayFrame.dbElapsed = DelayFrame.dbElapsed + arg1
		if DelayFrame.dbElapsed >= DelayFrame.dbTimeout then
			DelayFrame.dbElapsed = nil
			PullingFrom = nil
			InitiatedDBSync = false
			DBSyncInProgress = false
			SmokeyLootFrameProgressBar:Hide()
			SmokeyLootPullButton:Show()
			SmokeyLootPullButton:Enable()
			SmokeyLoot.UpdateFrame()
			printf("Database transfer aborted - timed out.")
		end
	end
	if not FuncQueue[1] then return end
	if GetTime() >= FuncQueue[1].executeTime then
		FuncQueue[1].func()
		table.remove(FuncQueue, 1)
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

local LootSourceFrame = CreateFrame("Frame", "SmokeyLootLootSourceFrame", WorldFrame)
LootSourceFrame:Hide()
LootSourceFrame.elapsed = 0
LootSourceFrame:SetScript("OnUpdate", function(self, elapsed)
	if not self then self = this end
	if not elapsed then elapsed = arg1 end
	self.elapsed = self.elapsed + elapsed
	if self.elapsed < 0.2 then return end
	self.elapsed = 0
	local guid = SmokeyItem.lootSource
	if guid and guid ~= "chest" then
		if not UnitExists(guid) or not UnitIsDead(guid) then
			SmokeyLoot.CancelRoll()
		end
	end
end)

function SmokeyLoot.OnLoad()
	table.insert(UISpecialFrames, "SmokeyLootFrame")
	this:RegisterForDrag("LeftButton")
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("GUILD_ROSTER_UPDATE")
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterEvent("CHAT_MSG_SYSTEM")
	-- this:RegisterEvent("CHAT_MSG_LOOT")
	-- this:RegisterEvent("UI_ERROR_MESSAGE")
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
	if method ~= "master" and GetNumRaidMembers() > 0 and inInstance and instanceType == "raid" and table.getn(SMOKEYLOOT.RAID) > 0 and IsRaidLeader() then
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
local incomingDB = {}
function SmokeyLoot.OnEvent(event, arg1, arg2, arg3, arg4)
	if event == "ADDON_LOADED" then
		if arg1 ~= "SmokeyLoot" then return end
		this:UnregisterEvent(event)

		if not SMOKEYLOOT then SMOKEYLOOT = {} end
		if not SMOKEYLOOT.DATABASE then SMOKEYLOOT.DATABASE = { date = 0 } end
		if not SMOKEYLOOT.HR then SMOKEYLOOT.HR = {} end
		if not SMOKEYLOOT.GUILD then SMOKEYLOOT.GUILD = {} end
		if not SMOKEYLOOT.RAID then SMOKEYLOOT.RAID = {} end
		if not SmokeyLootConfig then SmokeyLootConfig = {} end
		SmokeyLootConfig.sounds = SmokeyLootConfig.sounds == nil and true or SmokeyLootConfig.sounds
		SmokeyLootConfig.debugMessages = SmokeyLootConfig.debugMessages == nil and false or SmokeyLootConfig.debugMessages
		SmokeyLootConfig.alerts = SmokeyLootConfig.alerts == nil and true or SmokeyLootConfig.alerts

		SmokeyLootMinimapButton:ClearAllPoints()
		SmokeyLootMinimapButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", unpack(SMOKEYLOOT.POSITION or {SmokeyLootMinimapButton:GetCenter()}))

		SmokeyLoot.EnableRaidControls()
		SmokeyLoot.UpdateHR()

		for _, data in ipairs(SMOKEYLOOT.DATABASE) do
			CacheItem(data.itemID)
		end
		GuildRoster()

	elseif event == "GUILD_ROSTER_UPDATE" then
		-- debugprint(event, arg1)
		if arg1 then return end

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
				SMOKEYLOOT.GUILD[name].main = AltRanks[rank] and strtrim(string.lower(officerNote)) ~= "guild bank" and strtrim(string.gsub(officerNote, "%..*", "")) or nil
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
		-- debugprint(event)
		SmokeyLoot.UpdateRollers()
		SmokeyLoot.EnableRaidControls()
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
		local _, _, m = string.find(arg1, Patterns.newMaster)

		if m then
			Master = m
			debugprint(event, arg1, "master:", Master)
			SmokeyLoot.EnableRaidControls()
			return
		end

		local _, _, joined = string.find(arg1, Patterns.memberJoined)
		-- local _, _, left = strfind(arg1, Patterns.memberLeft)
		if joined then
			if not isMaster then return end

			for k, v in ipairs(SMOKEYLOOT.RAID) do
				if v.char == joined then
					v.enabled = true
					table.sort(SMOKEYLOOT.RAID, sortfunc)
					SortRaidByDisabled()
					SmokeyLoot.PushRaid()
					if SmokeyLootFrame:IsShown() then
						SmokeyLoot.UpdateFrame()
					end
					return
				end
			end

			table.insert(SMOKEYLOOT.RAID, {
				bonus = 0,
				itemID = 0,
				char = joined,
				pluses = 0,
				enabled = true,
			})
			table.sort(SMOKEYLOOT.RAID, sortfunc)
			SortRaidByDisabled()
			SmokeyLoot.PushRaid()

			printf("%s was not in the raid list, fill their SR info ASAP!", joined)

			if SmokeyLootFrame:IsShown() then
				SmokeyLoot.UpdateFrame()
			end

			return
		end

		-- Reading rolls from chat
		if not SmokeyItem.id then return end

		local _, _, player, roll, min, max = string.find(arg1, Patterns.rollResult)
		roll, min, max = tonumber(roll), tonumber(min), tonumber(max)
		debugprint(event, "player:", player, "roll:", roll, "max:", max, "AlreadyRolled:", AlreadyRolled[player])

		if isMaster and AlreadyRolled[player] then
			printf("%s already rolled on %s.", player, SmokeyItem.link)
		end

		if player and roll and max and not AlreadyRolled[player] then
			if not string.find(SmokeyItem.candidates, player, 1, true) then
				if isMaster then
					printf("%s is not a candidate for %s.", player, SmokeyItem.link)
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

				table.insert(SMOKEYLOOT.RAID, {
					bonus = 0,
					itemID = 0,
					char = player,
					pluses = 0,
					enabled = true,
				})
				table.sort(SMOKEYLOOT.RAID, sortfunc)
				SortRaidByDisabled()

				SmokeyLoot.PushRaid()

				for k, v in ipairs(SMOKEYLOOT.RAID) do
					if v.char == player then
						index = k
					end
				end
				if isMaster then
					printf("%s was not in the raid list, fill their SR info ASAP!", player)
				end
				if SmokeyLootFrame:IsShown() then
					SmokeyLoot.UpdateFrame()
				end
			end

			if not index then
				return
			end

			local rollType
			if max > 100 then rollType = "HR"
			elseif max == 100 then rollType = "SR"
			elseif max == 99 then rollType = "MS"
			elseif max == 98 then rollType = "OS"
			elseif max == 97 then rollType = "TMOG"
			else return end

			if rollType == "HR" then
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
					printf("%s is not allowed to roll HR on %s.", player, SmokeyItem.link)
				end

			elseif rollType == "SR" then
				local isAllowed = false
				for k, v in ipairs(SMOKEYLOOT.RAID) do
					if v.itemID == SmokeyItem.id and v.char == player then
						Rolls.SR[player] = roll + (v.bonus ~= -1 and v.bonus or 0)
						isAllowed = true
						break
					end
				end

				if not isAllowed and isMaster then
					printf("%s is not allowed to roll SR on %s.", player, SmokeyItem.link)
				end

			elseif rollType == "MS" then
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
					printf("%s is not allowed to roll MS on %s.", player, SmokeyItem.link)
				end

			elseif rollType == "OS" then
				Rolls.OS[player] = roll

			elseif rollType == "TMOG" then
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
					printf("%s is not allowed to roll Transmog on %s.", player, SmokeyItem.link)
				end
			end

			AlreadyRolled[player] = true

			local name = UnitName("player")
			local wasWinner = SmokeyItem.winner == name
			local wasTmogWinner = SmokeyItem.tmogWinner == name

			SmokeyLoot.GetWinner()

			if SmokeyLootConfig.sounds and SmokeyItem.winner ~= name and SmokeyItem.tmogWinner ~= name and (wasWinner or wasTmogWinner or (player == name)) then
				local soundFile
				if RollWeights[SmokeyItem.winType] and RollWeights[rollType] and RollWeights[rollType] < RollWeights[SmokeyItem.winType] then
					soundFile = Sounds.unwinnable[math.random(table.getn(Sounds.unwinnable))]
					debugprint("playing unwinnable sound ["..soundFile.."] for ["..name.."]")
				else
					soundFile = Sounds.outrolled[math.random(table.getn(Sounds.outrolled))]
					debugprint("playing outrolled sound ["..soundFile.."] for ["..name.."]")
				end
				if soundFile then
					PlaySoundFile("Interface\\AddOns\\SmokeyLoot\\Sounds\\"..soundFile..".mp3")
				end
			end
			if roll == 1 or roll == 69 or roll == max and min == 1 then
				if player == name then
					local key = "rolled"..(roll ~= max and roll or "100")
					local soundFile = Sounds[key][math.random(table.getn(Sounds[key]))]
					if soundFile then
						SendAddonMessage("SmokeyLoot", "playsound;"..soundFile..";", "RAID")
					end
				end
				SmokeyLoot.AlertAnimation(player, roll)
			end
		end

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

		if IsMasterLooter() and table.getn(SMOKEYLOOT.RAID) > 0 then
			if not (GetNumLootItems() == 1 and LootSlotIsCoin(1)) then
				SmokeyLootMLFrame:Show()
			end
			SmokeyLoot.UpdateMLFrame()
		end

	elseif event == "LOOT_CLOSED" then
		CurrentLootSource = nil
		SmokeyLootMLFrame:Hide()

	elseif event == "LOOT_SLOT_CLEARED" then
		if arg1 == SmokeyItem.slot and SmokeyItem.lootSource == CurrentLootSource and IsMasterLooter() then
			for i = 1, table.getn(SMOKEYLOOT.RAID) do
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
						table.insert(SMOKEYLOOT.RAID[i].gotHR, SmokeyItem.id)
					end
					break
				end
			end

			local channel = IsRaidOfficer() and "RAID_WARNING" or "RAID"
			if --[[SmokeyItem.recieved and]] SmokeyItem.givenTo then
				if SmokeyItem.givenTo == SmokeyItem.tmogWinner then
					SendChatMessage(string.format(fmt.trade, SmokeyItem.tmogWinner, SmokeyItem.tmogWinner, SmokeyItem.tmogWinRoll, "TMOG", SmokeyItem.link, SmokeyItem.winner, SmokeyItem.winner, SmokeyItem.winRoll, SmokeyItem.winType), channel)
					if SmokeyItem.tmogWinner ~= UnitName("player") then
						SendChatMessage(string.format(fmt.tradeWhisper, SmokeyItem.link, SmokeyItem.winner, SmokeyItem.winner), "WHISPER", nil, SmokeyItem.tmogWinner)
					end
				elseif SmokeyItem.givenTo == SmokeyItem.winner then
					SendChatMessage(string.format(fmt.win, SmokeyItem.winner, SmokeyItem.winner, SmokeyItem.link, SmokeyItem.winRoll, SmokeyItem.winType), channel)
				end
				SmokeyLoot.PlayRollResultSound()
				SmokeyLoot.CancelRoll(true)
			else
				SmokeyLoot.CancelRoll()
			end

			SmokeyLoot.PushRaid()
		end

		SmokeyLoot.UpdateRollers()

		if SmokeyLootMLFrame:IsShown() then
			SmokeyLoot.UpdateMLFrame()
		end

		SmokeyLoot.UpdateFrame()

	-- elseif event == "CHAT_MSG_LOOT" then
	-- 	local givenTo = SmokeyItem.givenTo
	-- 	if givenTo == UnitName("player") then givenTo = YOU end
	-- 	if not SmokeyItem.recieved and givenTo and string.find(arg1, SmokeyItem.link, 1, true) and string.find(arg1, givenTo, 1, true) then
	-- 		SmokeyItem.recieved = true
	-- 	end

	-- elseif event == "UI_ERROR_MESSAGE" then
	-- 	if SmokeyItem.givenTo then
	-- 		if arg1 == ERR_LOOT_GONE
	-- 			or arg1 == ERR_LOOT_MASTER_INV_FULL
	-- 			or arg1 == ERR_LOOT_MASTER_OTHER
	-- 			or arg1 == ERR_LOOT_MASTER_UNIQUE_ITEM
	-- 			or arg1 == ERR_LOOT_PLAYER_NOT_FOUND
	-- 		then
	-- 			SmokeyItem.givenTo = nil
	-- 			SmokeyItem.recieved = nil
	-- 		end
	-- 	end

	elseif event == "CHAT_MSG_ADDON" then
		if arg1 ~= "SmokeyLoot" then return end

		local message = arg2
		local channel = arg3
		local sender = arg4

		if channel == "RAID" then
			if string.find(message, "^StartRoll") and sender == SmokeyLoot.GetLootMasterName() then
				-- starting roll, show popup
				local _, _, id, name, texture, candidatesSR, candidates, count, quality, link = string.find(message, "StartRoll:(%d*);(.*);(.*);(.*);(.*);(%d*);(%d*);(.*)")

				if not string.find(candidates or "", UnitName("player")) then
					return
				end

				debugprintf("[%s] %s", sender, message)
				SmokeyLootPopupFrameIconFrameIcon:SetTexture(texture)
				SmokeyLootPopupFrameIconFrameCount:SetText(tonumber(count) > 1 and count or "")
				SmokeyLootPopupFrameIconFrame.itemString = string.gsub(link, ".*|H(.-)|h.*", "%1", 1)
				SmokeyLootPopupFrameIconFrame.link = link
				local r, g, b = GetItemQualityColor(tonumber(quality))
				SmokeyLootPopupFrameName:SetText(name)
				SmokeyLootPopupFrameName:SetTextColor(r, g, b)
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

				if string.find(candidatesSR or "", UnitName("player"), 1, true) then
					SmokeyLootPopupFrameSR:EnableMouse(true)
					SmokeyLootPopupFrameSR:SetAlpha(1)
				else
					SmokeyLootPopupFrameSR:EnableMouse(false)
					SmokeyLootPopupFrameSR:SetAlpha(0.5)
				end

				SmokeyLootPopupFrame:Show()
				SmokeyLootPopupFrame:SetScript("OnUpdate", LootPopupOnUpdate)

			elseif string.find(message, "playsound;") then
				debugprintf("[%s] %s", sender, message)
				if SmokeyLootConfig.sounds then
					local soundFile = string.gsub(message, "playsound;(.*);", "%1", 1)
					PlaySoundFile("Interface\\AddOns\\SmokeyLoot\\Sounds\\"..soundFile..".mp3")
				end

			elseif sender ~= UnitName("player") then
				if message == "REPORT_ADDON_VERSION" then
					debugprintf("[%s] %s", sender, message)
					SendAddonMessage("SmokeyLoot", "V_"..GetAddOnMetadata("SmokeyLoot", "Version"), "RAID")

				elseif string.find(message, "^V_") then
					local v = tonumber(string.sub(message, 3))
					SmokeyAddonVersions[sender] = v or 0
					debugprintf("[%s] %s", sender, message)

				elseif message == "GET_ML" then
					-- share loot master name
					local name = SmokeyLoot.GetLootMasterName()
					if name then
						SendAddonMessage("SmokeyLoot", "ML_"..name, "RAID")
					end
					debugprintf("[%s] %s", sender, message)

				elseif string.find(message, "ML_", 1, true) then
					local m = string.sub(message, 4)
					for i = 1, GetNumRaidMembers() do
						if m == GetRaidRosterInfo(i) then Master = m; break end
					end
					debugprintf("[%s] %s master: %s", sender, message, tostring(Master))
					SmokeyLoot.EnableRaidControls()
				end

				if sender == SmokeyLoot.GetLootMasterName() then
					if string.find(message, "tmogIgnored", 1, true) then
						debugprintf("[%s] %s", sender, message)
						SmokeyItem.tmogIgnored = string.sub(message, -1, -1) == "1" and true or false
						SmokeyLoot.GetWinner()
				
					elseif string.find(message, "^EndRoll") then
						-- ending roll, hide popup
						debugprintf("[%s] %s", sender, message)
						if string.sub(message, -1, -1) == "0" then -- success
							SmokeyLoot.PlayRollResultSound()
						end
						SmokeyLootPopupFrame:Hide()
						SmokeyItem:Reset()
						SmokeyLoot.UpdateRollers()

					-- raid update
					elseif string.find(message, "R_start", 1, true) then
						local usingPlus = string.sub(message, 9, 9)
						local isBongoAlt = string.sub(message, 11, 11)
						debugprintf("[%s] %s", sender, message)
						arraywipe(SMOKEYLOOT.RAID)
						SMOKEYLOOT.RAID.isPlusOneRaid = usingPlus == "1"
						SMOKEYLOOT.RAID.isBongoAltRaid = isBongoAlt == "1"

					elseif message == "R_end" then
						SmokeyLoot.UpdateFrame()
						debugprintf("[%s] %s", sender, message)

					elseif message == "R_clear" then
						debugprintf("[%s] %s", sender, message)
						arraywipe(SMOKEYLOOT.RAID)
						SmokeyLoot.UpdateFrame()

					else
						local _, _, key, itemID, char, bonus, pluses, enabled, gotHR = string.find(message, "^(%d+);(%d+);(.*);(%-?%d+);(%d+);(%d);(.*)")
						if key then
							table.insert(SMOKEYLOOT.RAID, tonumber(key), {
								itemID = tonumber(itemID),
								char = char,
								bonus = tonumber(bonus),
								pluses = tonumber(pluses),
								enabled = enabled == "1",
								gotHR = (gotHR ~= "" and strsplit(gotHR, ",")) or nil
							})
						end
					end
				end
			end

		elseif channel == "GUILD" and sender ~= UnitName("player") then
			-- DB sync stuff here
			if message == "GET_DB_LATEST" and SmokeyLoot.IsOfficer() and not DBSyncInProgress then
				debugprintf("[%s] %s", sender, message)
				local date = SMOKEYLOOT.DATABASE.date
				if date == SmokeyLoot.GetRemoteVersion() then
					DBSyncInitiator = sender
					SendAddonMessage("SmokeyLoot", "VDB_"..date, "GUILD")
				end
				return
			end
			if string.find(message, "^VDB_%d+") and SmokeyLoot.IsOfficer(sender) and InitiatedDBSync then
				debugprintf("[%s] %s", sender, message)
				local _, _, date = string.find(message, "^VDB_(%d+)")
				local remote = SmokeyLoot.GetRemoteVersion()
				if tonumber(date) == remote and SMOKEYLOOT.DATABASE.date < remote and not DBSyncInProgress then
					SendAddonMessage("SmokeyLoot", "PULL_FROM_"..sender, "GUILD")
				end
				return
			end
			if message == "PULL_FROM_"..UnitName("player") and sender == DBSyncInitiator then
				debugprintf("[%s] %s", sender, message)
				SmokeyLoot.PushDB()
				return
			end
			if string.find(message, "^start;%d+;%d+") and SmokeyLoot.IsOfficer(sender) then
				debugprintf("[%s] %s", sender, message)
				DBSyncInProgress = true

				local _, _, date, max = string.find(message, "start;(%d+);(%d+)")
				-- local remote = SmokeyLoot.GetRemoteVersion()

				if tonumber(max) > 0 and SMOKEYLOOT.DATABASE.date < tonumber(date) then
					arraywipe(incomingDB)
					incomingDB.totalEntries = tonumber(max)
					incomingDB.date = tonumber(date)

					PullingFrom = sender
					DelayFrame.dbElapsed = 0

					SmokeyLootFinishRaidButton:Disable()
					SmokeyLootFrameProgressBar:Show()
					SmokeyLootFrameProgressBar:SetMinMaxValues(0, tonumber(max))
					SmokeyLootFrameProgressBar:SetValue(0)
					SmokeyLootFrameProgressBarText:SetText("0%")
					SmokeyLootFrameDBDate:SetText("Database version: updating...")
					SmokeyLootPullButton:Hide()
					printf("Updating database, provided by "..PullingFrom..", please, stay online until it's done.")
				end

			elseif string.find(message, "^end;%d+") and SmokeyLoot.IsOfficer(sender) then
				debugprintf("[%s] %s", sender, message)
				DBSyncInProgress = false

				if PullingFrom and PullingFrom == sender then
					PullingFrom = nil
					InitiatedDBSync = false
					DelayFrame.dbElapsed = nil

					SmokeyLootFrameProgressBar:Hide()
					SmokeyLootPullButton:Show()
					SmokeyLootPullButton:Enable()

					local newSize = table.getn(incomingDB)
					local targetSize = incomingDB.totalEntries
					if newSize ~= targetSize then
						printf("Database transfer aborted - recieved %d entries but needed %d.", newSize, targetSize)
					else
						arraywipe(SMOKEYLOOT.DATABASE)
						for i = 1, newSize do
							local value = incomingDB[i]
							table.insert(SMOKEYLOOT.DATABASE, i, {
								itemID = value.itemID,
								char = value.char,
								bonus = value.bonus,
							})
						end
						SMOKEYLOOT.DATABASE.date = incomingDB.date
						SmokeyLoot.UpdateHR()
						printf("Database is updated.")
					end
					SmokeyLoot.UpdateFrame()
				end

			elseif string.find(message, "(%d+)=(%d+)=") and SmokeyLoot.IsOfficer(sender) then
				DBSyncInProgress = true

				local _, _, index, itemID = string.find(message, "(%d+)=(%d+)=")
				if PullingFrom and PullingFrom == sender then
					index, itemID = tonumber(index), tonumber(itemID)

					if index and itemID then
						DelayFrame.dbElapsed = 0
						message = string.gsub(message, "%d+=%d+=", "")

						local info = strsplit(message, ";")

						for i = 1, table.getn(info), 2 do
							if info[i] and tonumber(info[i + 1]) then
								table.insert(incomingDB, {
									itemID = itemID,
									char = info[i],
									bonus = tonumber(info[i + 1]),
								})
								local n = table.getn(incomingDB)
								local min, max = SmokeyLootFrameProgressBar:GetMinMaxValues()
								SmokeyLootFrameProgressBar:SetValue(n)
								SmokeyLootFrameProgressBarText:SetText(string.format("%.0f%%", n / max * 100))
							end
						end
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
			for i = 1, table.getn(tableToUpdate) do
				local itemName = GetItemInfo(tableToUpdate[i].itemID or 0) or ""
				local char = tableToUpdate[i].char or ""
				if char == query or itemName == query then table.insert(SearchResult, i) end
			end
		else
			query = string.lower(query)
			for i = 1, table.getn(tableToUpdate) do
				local itemName = GetItemInfo(tableToUpdate[i].itemID or 0) or ""
				local char = tableToUpdate[i].char or ""
				if string.find(string.lower(itemName), query, 1, true) or string.find(string.lower(char), query, 1, true) then table.insert(SearchResult, i) end
			end
		end
	end

	local offset = FauxScrollFrame_GetOffset(SmokeyLootScrollFrame) or 0
	local results = table.getn(SearchResult)
	local numEntries = table.getn(tableToUpdate)
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

		local data = tableToUpdate[entryIndex]
		if data and entryIndex > 0 and entryIndex <= numEntries then
			local icon = entry.Icon
			local itemColumn = entry.Text
			local charColumn = entry.Column1
			local rankColumn = entry.Column2
			local bonusColumn = entry.Column3
			local itemID = data.itemID
			local char = data.char
			local bonus = data.bonus
			local member = SMOKEYLOOT.GUILD[char]
			local class = member and member.class
			local rankName = member and member.rankName

			CacheItem(itemID)

			local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)
			local r, g, b = RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b

			if itemQuality then
				r, g, b = GetItemQualityColor(itemQuality)
			end

			itemColumn:SetText(itemID == 0 and "" or itemName or "???")
			itemColumn:SetTextColor(r, g, b)
			itemColumn:SetWidth(char and 200 or 0)
			charColumn:SetText(char)
			icon:SetTexture(itemID == 0 and "" or itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
			icon:Show()

			if class and rankName then
				local color = RAID_CLASS_COLORS[class]
				if color then
					charColumn:SetTextColor(color.r, color.g, color.b)
				end
				if IsBongoAlt(char) then
					rankColumn:SetText(rankName.."*")
				else
					rankColumn:SetText(rankName)
				end
			else
				charColumn:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
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

			entry.data = data
			entry.data.class = class
			entry:SetID(entryIndex)
			entry:Show()

			if GetMouseFocus() == entry then
				entry:Hide()
				entry:Show()
			end

			if tableToUpdate == SMOKEYLOOT.RAID then
				entry:SetAlpha(data.enabled and 1 or 0.5)
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

	SmokeyLoot.EnableRaidControls()
end

function SmokeyLoot.GetColoredGuildMemberName(member)
	if not member then return "" end
	local gInfo = SMOKEYLOOT.GUILD[member]
	if gInfo and gInfo.class then
		return ClassColors[gInfo.class]..member.."|r"
	end
	return RED_FONT_COLOR_CODE..member.."|r"
end

function SmokeyLoot.Entry_OnLoad(self)
	local name = self:GetName()
	self.Icon = _G[name.."Icon"]
	self.Text = _G[name.."Text"]
	self.Column1 = _G[name.."Column1"]
	self.Column2 = _G[name.."Column2"]
	self.Column3 = _G[name.."Column3"]
end

local EntryTooltip = CreateFrame("GameTooltip", "SmokeyLootEntryTooltip", UIParent, "GameTooltipTemplate")

function SmokeyLoot.Entry_OnEnter(self)
	self:SetBackdropColor(1, 1, 1, 0.5)

	local data = self.data
	if not data then return end

	local itemID = data.itemID

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	EntryTooltip:SetOwner(self, "ANCHOR_NONE")

	if CurrentTab == "HR" then
		if itemID > 0 then
			GameTooltip:SetHyperlink("item:"..itemID)
		end

		EntryTooltip:SetText("Hard reserve queue:")
		for i, players in ipairs(data) do
			local names = ""
			for j, member in ipairs(players) do
				names = names..SmokeyLoot.GetColoredGuildMemberName(member)
				if players[j + 1] then names = names..", " end
			end
			EntryTooltip:AddLine(i..". "..names)
		end

	elseif CurrentTab == "RAID" then
		if itemID > 0 then
			GameTooltip:SetHyperlink("item:"..itemID)
			local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)
			self.Text:SetText(itemName or "???")
			self.Icon:SetTexture(itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
			local r, g, b = 1, 0.2, 0.2
			if itemQuality then r, g, b = GetItemQualityColor(itemQuality) end
			self.Text:SetTextColor(r, g, b)
		end

		local color = data.class and ClassColors[data.class] or RED_FONT_COLOR_CODE
		local char = color..data.char.." |r"..GRAY_FONT_COLOR_CODE.."(Not in the raid)|r"

		for i = 1, 40 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
			if name and name == data.char then
				color = ClassColors[fileName]
				if not online then
					char = color..data.char.." |r"..GRAY_FONT_COLOR_CODE.."("..zone..")|r"
				else
					char = color..data.char.."|r"
				end
				break
			end
		end

		EntryTooltip:AddLine(char)
		EntryTooltip:AddLine("ItemID: "..itemID)
		EntryTooltip:AddLine("Pluses: "..(SMOKEYLOOT.RAID.isPlusOneRaid and data.pluses or NOT_APPLICABLE))
		if data.gotHR then
			EntryTooltip:AddLine("Got HR: "..table.concat(data.gotHR, ", "))
		end
	
	elseif CurrentTab == "DATABASE" then
		if itemID > 0 then
			GameTooltip:SetHyperlink("item:"..itemID)
			EntryTooltip:AddLine("ItemID: "..itemID)
			local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)
			self.Text:SetText(itemName or "???")
			self.Icon:SetTexture(itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
			local r, g, b = 1, 0.2, 0.2
			if itemQuality then r, g, b = GetItemQualityColor(itemQuality) end
			self.Text:SetTextColor(r, g, b)
		end
	end

	EntryTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", -14, 0)
	GameTooltip:SetPoint("TOPRIGHT", EntryTooltip, "BOTTOMRIGHT", 0, 0)
	GameTooltip:Show()
	EntryTooltip:Show()

	local top = GameTooltip:GetTop()
	local bottom = EntryTooltip:GetBottom()

	if (top and bottom) and (top > bottom) then
		EntryTooltip:ClearAllPoints()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", -14, 0)
		EntryTooltip:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", 0, 0)
	end
end

function SmokeyLoot.Entry_OnLeave(self)
	self:SetBackdropColor(1, 1, 1, 0.2)
	GameTooltip:Hide()
	EntryTooltip:Hide()
end

function SmokeyLoot.Entry_OnClick(self)
	if IsShiftKeyDown() then
		local data = self.data
		if not data then return end
		local itemID = data.itemID
		-- copy paste values
		if SmokeyLootEditEntryFrame:IsShown() then
			if itemID then
				SmokeyLootEditEntryFrameEditBox2:SetNumber(itemID)
				SmokeyLootEditEntryFrameItemName:SetText(GetItemInfo(itemID) or "")
			end
			SmokeyLootEditEntryFrameEditBox3:SetText(data.char)
			SmokeyLootEditEntryFrameEditBox4:SetText(data.bonus)
		else
			SmokeyLoot.ChatInsertItemLink(itemID)
		end
	elseif CurrentTab == "DATABASE" or CurrentTab == "RAID" then
		SmokeyLoot.ToggleEditEntryFrame(self:GetID())
	end
end

function SmokeyLoot.ChatInsertItemLink(itemID)
	local editBox
	if WIM_EditBoxInFocus then
		editBox = WIM_EditBoxInFocus
	elseif MessageBox and MessageBox.whisperInput and MessageBox.whisperInput:IsVisible() then
		editBox = MessageBox.whisperInput
	elseif ChatFrameEditBox:IsVisible() then
		editBox = ChatFrameEditBox
	end
	local itemName, itemString, quality = GetItemInfo(itemID or 0)
	if itemName and editBox then
		local r, g, b, color = GetItemQualityColor(quality)
		editBox:Insert(string.format("%s|H%s|h[%s]|h|r", color, itemString, itemName))
	end
end

function SmokeyLoot.GetBonus(itemID, char)
	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if v.itemID == tonumber(itemID) and v.char == char then return v.bonus or 0 end
	end
	return nil
end

local __ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
ChatFrame_OnHyperlinkShow = function(link, text, button)
	if not (IsShiftKeyDown() and SmokeyLootEditEntryFrame:IsShown()) then
		return __ChatFrame_OnHyperlinkShow(link, text, button)
	end
	local name = string.sub(link, 8)
	if name and strlen(name) > 0 then
		name = string.gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3")
		name = string.gsub(name, "([^%s]*)%s+([^%s]*)", "%2")
	end
	local _, _, itemID = string.find(link or "", "item:(%d+)")
	itemID = tonumber(itemID) or 0
	local itemName = GetItemInfo(itemID)
	if not itemName and text then
		text = string.gsub(text, "|cff%x%x%x%x%x%x", "")
		text = string.gsub(text, "|r", "")
		_, _, itemName = string.find(text, "%[(.-)%]")
	end
	if itemName and itemID then
		SmokeyLootEditEntryFrameItemName:SetText(strtrim(itemName))
		SmokeyLootEditEntryFrameEditBox2:SetNumber(itemID)
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
	if not SmokeyItem.id then
		SmokeyLootPopupFrame:Hide()
		return
	end

	SmokeyItem.choise = choise

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

	if max then RandomRoll(1, max) end

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
			table.insert(ranks, rank)
		end
	end

	local highestRank = min(unpack(ranks))

	for name, roll in pairs(Rolls[rollType]) do
		if SMOKEYLOOT.GUILD[name] and tonumber(SMOKEYLOOT.GUILD[name].rankIndex) > highestRank then
			if IsMasterLooter() then
				printf("Low rank roll discarded: %s %d (%s). Highest rank: %s", name, roll, SMOKEYLOOT.GUILD[name].rankName, GuildControlGetRankName(highestRank + 1))
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
			end
		end
	elseif next(Rolls.SR) then
		for k, v in pairs(Rolls.SR) do
			if v > SmokeyItem.winRoll then
				SmokeyItem.winRoll = v
				SmokeyItem.winner = k
				SmokeyItem.winType = "SR"
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
			end
		end
	elseif next(Rolls.TMOG) then
		ApplyBongoAltRule("TMOG")
		for k, v in pairs(Rolls.TMOG) do
			if v > SmokeyItem.winRoll then
				SmokeyItem.winRoll = v
				SmokeyItem.winner = k
				SmokeyItem.winType = "TMOG"
			end
		end
	end

	if SmokeyItem.winner and next(Rolls.TMOG) and not SmokeyItem.tmogIgnored then
		for k, v in pairs(Rolls.TMOG) do
			if v > SmokeyItem.tmogWinRoll and k ~= SmokeyItem.winner then
				SmokeyItem.tmogWinRoll = v
				SmokeyItem.tmogWinner = k
			end
		end
	end
	debugprint("winner:", SmokeyItem.winner, "tmogWinner:", SmokeyItem.tmogWinner)
end

local Candidates = {}
local SRCandidates = {}

function SmokeyLoot.StartOrEndRoll(slot)
	if not slot then return end

	local link = GetLootSlotLink(slot)
	local _, _, itemID = string.find(link or "", "item:(%d+)")
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
					table.insert(Candidates, candidate)
					for k, v in ipairs(SMOKEYLOOT.RAID) do
						if v.itemID == itemID and v.bonus ~= -1 and v.char == candidate then
							table.insert(SRCandidates, candidate)
							break
						end
					end
					break
				end
			end
		end

		SmokeyItem.candidatesSR = table.concat(SRCandidates, ",")
		SmokeyItem.candidates = table.concat(Candidates, ",")
		if table.getn(SRCandidates) > 0 then
			SendChatMessage("Starting roll on "..link.." (SR by "..table.concat(SRCandidates, ", ")..")", IsRaidOfficer() and "RAID_WARNING" or "RAID")
		else
			SendChatMessage("Starting roll on "..link, IsRaidOfficer() and "RAID_WARNING" or "RAID")
		end
		SendAddonMessage("SmokeyLoot", string.format("StartRoll:%d;%s;%s;%s;%s;%d;%d;%s", itemID, itemName, itemTexture, SmokeyItem.candidatesSR, SmokeyItem.candidates, itemCount, itemQuality, link), "RAID")
		LootSourceFrame:Show()

	else
		-- End Roll
		if not SmokeyItem.winner and not SmokeyItem.tmogWinner then
			SmokeyLoot.CancelRoll()
			return
		end

		if itemID == SmokeyItem.id then
			if GetNumRaidMembers() > 0 then
				local name
				SmokeyItem.tmogIgnored = SmokeyLootMLFrameIgnoreTmog:GetChecked() and true or false
				if SmokeyItem.tmogWinner and not SmokeyItem.tmogIgnored then
					name = SmokeyItem.tmogWinner
				else
					name = SmokeyItem.winner
				end
				for i = 1, 40 do
					if name == GetMasterLootCandidate(i) then
						-- if SmokeyItem.lootSource ~= "chest" then
							SmokeyItem.givenTo = name
							-- SmokeyItem.recieved = nil
							GiveMasterLoot(SmokeyItem.slot, i)
						-- else
						-- 	SmokeyLoot.OnEvent("LOOT_SLOT_CLEARED", SmokeyItem.slot)
						-- end
						break
					end
				end
			end
			if not SmokeyItem.givenTo then
				printf("Roll cancelled - winner was not found in candidates list.")
				SmokeyLoot.CancelRoll()
			end
			SmokeyLootPopupFrame:Hide()
		end
	end

	SmokeyLoot.UpdateMLFrame()
end

function SmokeyLoot.CancelRoll(success)
	SmokeyLootPopupFrame:Hide()
	if IsMasterLooter() then
		SendAddonMessage("SmokeyLoot", "EndRoll"..(not success and "1" or "0"), "RAID")
	end
	SmokeyItem:Reset()
	SmokeyLoot.UpdateMLFrame()
	SmokeyLoot.UpdateRollers()
	LootSourceFrame:Hide()
	debugprint("CancelRoll", success)
end

function SmokeyLoot.MLFrameOnShow()
	if CurrentLootSource == "chest" or SmokeyLoot.NonTradeableBosses[UnitName("target")] then
		SmokeyLootMLFrameIgnoreTmog:SetChecked(true)
		debugprint("Non-tradeable loot")
	end
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
			local _, _, id = string.find(GetLootSlotLink(i) or "", "item:(%d+)")
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
	-- text = string.gsub(text, ',"', ",")
	-- text = string.gsub(text, '",', ",")

	local split = strsplit(text, "\n")

	SMOKEYLOOT.RAID.isPlusOneRaid = SmokeyLootImportFrameEnablePlusOne:GetChecked() and true or false
	SMOKEYLOOT.RAID.isBongoAltRaid = SmokeyLootImportFrameEnableBongoAltRule:GetChecked() and true or false

	for i = 1, table.getn(split) do
		local _, _, id, char = string.find(split[i], "^(%d+),(.+)$")
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
				if name and name == char then enabled = true; break end
			end
			local index = arrcontains(SMOKEYLOOT.RAID, char)
			if index then
				-- if player found in the list, just refresh item
				SMOKEYLOOT.RAID[index].itemID = tonumber(id)
				SMOKEYLOOT.RAID[index].bonus = bonus
			else
				table.insert(SMOKEYLOOT.RAID, { char = char, itemID = tonumber(id), bonus = bonus, pluses = 0, enabled = enabled })
			end
		end
	end

	-- add raid members without SR
	for i = 1, 40 do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
		if name and not arrcontains(SMOKEYLOOT.RAID, name) then
			table.insert(SMOKEYLOOT.RAID, { char = name, itemID = 0, bonus = 0, pluses = 0, enabled = true })
		end
	end

	table.sort(SMOKEYLOOT.RAID, sortfunc)
	SortRaidByDisabled()

	SmokeyLootImportFrame:Hide()
	SmokeyLoot.UpdateFrame()
	SmokeyLoot.EnableRaidControls()
	SmokeyLoot.PushRaid()
	SmokeyLoot.RegisterTargetChange()
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
		-- SmokeyLootPullButton:Hide()

	elseif switchTo == "DATABASE" then
		SmokeyLootImportButton:Hide()
		SmokeyLootFinishRaidButton:Hide()
		SmokeyLootClearButton:Hide()
		SmokeyLootAddButton:Show()

		if SmokeyLoot.IsOfficer() and table.getn(SMOKEYLOOT.RAID) == 0 then
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
	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() or DBSyncInProgress then
		return
	end
	printf("Finishing raid.")
	for i = table.getn(SMOKEYLOOT.RAID), 1, -1 do
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
						table.remove(SMOKEYLOOT.DATABASE, k)
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
		-- remove if had nothing reserved or reserved something from Blacklist or when already hr or disabled
		if enabled == false or id == 0 or BlacklistItems[id] or bonus > 90 then
			table.remove(SMOKEYLOOT.RAID, i)
		elseif bonus == -1 then -- check if got their sr
			for k, v in ipairs(SMOKEYLOOT.DATABASE) do
				if v.itemID == id and v.char == char then
					-- remove them from DATABASE
					table.remove(SMOKEYLOOT.DATABASE, k)
					break
				end
			end
			-- remove from RAID
			table.remove(SMOKEYLOOT.RAID, i)
		end
	end

	-- RAID now should only contain people who need to get +10 bonus (or get on HR list)
	local size = table.getn(SMOKEYLOOT.RAID)
	if size > 0 then printf("Following players got +10:") end

	for k, v in ipairs(SMOKEYLOOT.RAID) do
		local newBonus = v.bonus + 10
		if newBonus == 100 then
			-- this is new hr
			local newHRPlayers = { v.char }
			-- check if someone else got hr in the same raid, we have to add them to DATABASE together
			for k2, v2 in ipairs(SMOKEYLOOT.RAID) do
				if v2.itemID == v.itemID and v2.bonus + 10 == newBonus and v2.char ~= v.char then
					table.insert(newHRPlayers, v2.char)
					v2.bonus = -1
				end
			end
			newBonus = 101
			local oldBonuses = nil
			for k2, v2 in ipairs(SMOKEYLOOT.DATABASE) do
				if v2.itemID == v.itemID and v2.bonus > 100 then
					oldBonuses = oldBonuses or {}
					table.insert(oldBonuses, v2.bonus)
				end
			end
			if oldBonuses then
				newBonus = max(unpack(oldBonuses)) + 1
			end
			for i = 1, table.getn(newHRPlayers) do
				for k2, v2 in ipairs(SMOKEYLOOT.DATABASE) do
					if v2.char == newHRPlayers[i] and v2.itemID == v.itemID then
						v2.bonus = newBonus
						break
					end
				end
			end
		else
			if not SmokeyLoot.GetBonus(v.itemID, v.char) then
				-- this is new regular entry
				table.insert(SMOKEYLOOT.DATABASE, { char = v.char, itemID = v.itemID, bonus = newBonus })
			else
				-- this is old regular entry
				for k2, v2 in ipairs(SMOKEYLOOT.DATABASE) do
					if v2.char == v.char and v2.itemID == v.itemID then
						v2.bonus = newBonus
						break
					end
				end
			end
		end

		printf("%s %s %d -> %d", GetItemInfo(v.itemID) or "<?>", v.char, v.bonus, newBonus)
	end

	arraywipe(SMOKEYLOOT.RAID)
	listwipe(SMOKEYLOOT.RAID)

	SmokeyLoot.PushRaid(true)
	if size > 0 then
		-- QueueFunction(2, function()
			SmokeyLoot.SetRemoteVersion()
			SmokeyLoot.PushDB()
			printf("New date has been set: %s", date("%d/%m/%y %H:%M:%S", SMOKEYLOOT.DATABASE.date))
		-- end)
	end
	SmokeyLoot.UpdateHR()
	SmokeyLoot.UpdateFrame()
end

function SmokeyLoot.FinishRaidButton_OnClick()
	if not IsMasterLooter() or DBSyncInProgress then return end
	SmokeyLoot.PullDB()
	SmokeyLootFinishRaidButton:Disable()
	QueueFunction(3, function()
		if SMOKEYLOOT.DATABASE.date == SmokeyLoot.GetRemoteVersion() and not DBSyncInProgress then
			SmokeyLoot.FinishRaidRoutine()
		end
	end)
end

function SmokeyLoot.PullDB()
	GuildRoster()

	if PullingFrom or Pushing or InitiatedDBSync or DBSyncInProgress then return end

	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		InitiatedDBSync = true
		PullingFrom = nil
		SmokeyLootPullButton:Disable()
		printf("Requesting database...")
		SendAddonMessage("SmokeyLoot", "GET_DB_LATEST", "GUILD")
	end

	QueueFunction(3, function()
		if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() and not PullingFrom then
			InitiatedDBSync = false
			SmokeyLootPullButton:Enable()
			printf("Looks like there is no one online who can share the latest database. :(")
		end
	end)
end

function SmokeyLoot.PushDB()
	if not SmokeyLoot.IsOfficer() or Pushing or PullingFrom or DBSyncInProgress or SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		return
	end

	local items = {}
	local uniqueItems = {}

	table.sort(SMOKEYLOOT.DATABASE, sortfunc)

	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if type(v) == "table" then
			if not items[v.itemID] then
				items[v.itemID] = true
				table.insert(uniqueItems, v.itemID.."=")
			end
			uniqueItems[table.getn(uniqueItems)] = uniqueItems[table.getn(uniqueItems)]..v.char..";"..v.bonus..";"
		end
	end

	if table.getn(uniqueItems) == 0 then return end

	SendAddonMessage("SmokeyLoot", "start;"..SMOKEYLOOT.DATABASE.date..";"..table.getn(SMOKEYLOOT.DATABASE), "GUILD")
	Pushing = true

	if DBSyncInitiator then
		printf("Sharing database, requested by "..DBSyncInitiator..", please, stay online until it's done.")
	end

	local i = 1
	local dbPushFrame = SmokeyLootDBPushFrame or CreateFrame("Frame", "SmokeyLootDBPushFrame")
	dbPushFrame:SetScript("OnUpdate", function()
		if uniqueItems[i] then
			SendAddonMessage("SmokeyLoot", i.."="..uniqueItems[i], "GUILD")
		end
		i = i + 1

		if i > table.getn(uniqueItems) then
			dbPushFrame:SetScript("OnUpdate", nil)
			SendAddonMessage("SmokeyLoot", "end;"..SMOKEYLOOT.DATABASE.date, "GUILD")
			Pushing = false
			DBSyncInitiator = nil
			printf("Database is shared.")
		end
	end)
end

local messages = {}
function SmokeyLoot.PushRaid(clear)
	if not IsMasterLooter() then return end

	if clear then
		SendAddonMessage("SmokeyLoot", "R_clear", "RAID")
		return
	end

	arraywipe(messages)

	table.sort(SMOKEYLOOT.RAID, sortfunc)
	SortRaidByDisabled()

	for i, v in ipairs(SMOKEYLOOT.RAID) do
		if type(v) == "table" then
			table.insert(messages, string.format("%d;%d;%s;%d;%d;%d;%s", i, v.itemID, v.char, v.bonus, v.pluses, v.enabled and "1" or "0", v.gotHR and table.concat(v.gotHR, ",") or ""))
		end
	end

	if table.getn(messages) == 0 then return end

	SendAddonMessage("SmokeyLoot", "R_start;"..(SMOKEYLOOT.RAID.isPlusOneRaid and 1 or 0)..";"..(SMOKEYLOOT.RAID.isBongoAltRaid and 1 or 0), "RAID")

	local i = 1
	local raidPushFrame = SmokeyLootRaidPushFrame or CreateFrame("Frame", "SmokeyLootRaidPushFrame")
	raidPushFrame:SetScript("OnUpdate", function()
		if messages[i] then
			SendAddonMessage("SmokeyLoot", messages[i], "RAID")
		end
		i = i + 1
		if i > table.getn(messages) then
			raidPushFrame:SetScript("OnUpdate", nil)
			SendAddonMessage("SmokeyLoot", "R_end", "RAID")
		end
	end)
end

function SmokeyLoot.CheckDBSanity()
	if not SmokeyLoot.IsOfficer() then
		return
	end

	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		printf("You need to get latest database first.")
		return
	end

	local nonmembers, duplicates = 0, 0

	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if not SMOKEYLOOT.GUILD[v.char] then
			printf("Non guild member entry: %s itemID: %d bonus: %d", v.char, v.itemID, v.bonus)
			nonmembers = nonmembers + 1
		end
	end
	local seen = {}
	local dup = {}
	for k, v in ipairs(SMOKEYLOOT.DATABASE) do
		if not seen[v.itemID..v.char] then
			seen[v.itemID..v.char] = true
		else
			table.insert(dup, v)
		end
	end
	for k, v in ipairs(dup) do
		printf("duplicated entry %d %s",v.itemID, v.char)
	end
	duplicates = table.getn(dup)

	printf("Non guild member entries (potentially): %d, duplicated entries: %d", nonmembers, duplicates)
end

function SmokeyLoot.GetRemoteVersion()
	GuildRoster()
	local _, _, name, time = string.find(GetGuildInfoText(), "\n(%a*)(%d+)$")
	time = tonumber(time) or 0
	name = name or ""
	return time, date("%d/%m/%y %H:%M:%S", time), name
end

function SmokeyLoot.SetRemoteVersion()
	if not SmokeyLoot.IsOfficer() then
		return
	end

	GuildRoster()
	SMOKEYLOOT.DATABASE.date = time()
	local stamp = UnitName("player")..SMOKEYLOOT.DATABASE.date
	local guildInfo = GetGuildInfoText()
	guildInfo = string.gsub(GetGuildInfoText(), "\n%a*%d+$", "")
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
				table.insert(SMOKEYLOOT.HR, { itemID = v.itemID })
				hrIndex = table.getn(SMOKEYLOOT.HR)
			end

			if not SMOKEYLOOT.HR[hrIndex][pos] then
				SMOKEYLOOT.HR[hrIndex][pos] = {}
			end

			table.insert(SMOKEYLOOT.HR[hrIndex][pos], v.char)

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

	local isOfficer = SmokeyLoot.IsOfficer()
	local isMaster = IsMasterLooter()

	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		if isOfficer or isMaster then printf("You need to get latest database first.") end
		return
	end
	
	SmokeyLootEditEntryFrame:Show()
	SmokeyLootEditEntryFrame.id = id
	SmokeyLootEditEntryFrame.add = add
	SmokeyLootEditEntryFrame.tab = CurrentTab

	if CurrentTab == "DATABASE" then
		if not isOfficer then
			SmokeyLootEditEntryFrame:Hide()
			return
		end
		SmokeyLootEditEntryFrameEntryIndex:SetText("Database Entry " .. id)
		SmokeyLootEditEntryFrameItemName:SetText(add and "" or GetItemInfo(SMOKEYLOOT.DATABASE[id].itemID))
		SmokeyLootEditEntryFrameEditBox2:SetNumber(add and 0 or SMOKEYLOOT.DATABASE[id].itemID)
		SmokeyLootEditEntryFrameEditBox3:SetText(add and "" or SMOKEYLOOT.DATABASE[id].char)
		SmokeyLootEditEntryFrameEditBox4:SetText(add and 0 or SMOKEYLOOT.DATABASE[id].bonus)
		SmokeyLootEditEntryFrameEditBox5:Hide()
		SmokeyLootEditEntryFramePluses:Hide()
		SmokeyLootEditEntryFrameEnabled:Hide()
		SmokeyLootEditEntryFrameEnabledCheckBox:Hide()
		SmokeyLootEditEntryFrameHint:SetText("Shift-click entries or chat links to copy paste values")

	elseif CurrentTab == "RAID" then
		if not isMaster then
			SmokeyLootEditEntryFrame:Hide()
			return
		end
		SmokeyLootEditEntryFrameEntryIndex:SetText("Raid Entry # " .. id)
		SmokeyLootEditEntryFrameItemName:SetText(add and "" or GetItemInfo(SMOKEYLOOT.RAID[id].itemID))
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
	local isOfficer = SmokeyLoot.IsOfficer()
	local isMaster = IsMasterLooter()
	if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
		if isOfficer or isMaster then printf("You need to get latest database first.") end
		return
	end
	local tab = SmokeyLootEditEntryFrame.tab
	local id = SmokeyLootEditEntryFrame.id
	local newItemID = SmokeyLootEditEntryFrameEditBox2:GetNumber()
	local newChar = strtrim(SmokeyLootEditEntryFrameEditBox3:GetText())
	local newBonus = tonumber(strtrim(SmokeyLootEditEntryFrameEditBox4:GetText()))
	local newEnabled = SmokeyLootEditEntryFrameEnabledCheckBox:GetChecked() and true or false
	
	if tab == "DATABASE" then
		if DBSyncInProgress then return end
		if not isOfficer then
			SmokeyLootEditEntryFrame:Hide()
			return
		end
		if SmokeyLootEditEntryFrame.add then
			for k, v in ipairs(SMOKEYLOOT.DATABASE) do
				if v.char == newChar and v.itemID == newItemID then
					printf("Such entry already exists.")
					return
				end
			end
			table.insert(SMOKEYLOOT.DATABASE, id, {})
		end

		SMOKEYLOOT.DATABASE[id].itemID = newItemID
		SMOKEYLOOT.DATABASE[id].char = newChar
		SMOKEYLOOT.DATABASE[id].bonus = newBonus

		table.sort(SMOKEYLOOT.DATABASE, sortfunc)

		SmokeyLoot.SetRemoteVersion()
		SmokeyLoot.UpdateHR()

	elseif tab == "RAID" then
		if not isMaster then
			SmokeyLootEditEntryFrame:Hide()
			return
		end
		local newPluses = SmokeyLootEditEntryFrameEditBox5:GetNumber()

		if SmokeyLootEditEntryFrame.add then
			for k, v in ipairs(SMOKEYLOOT.RAID) do
				if v.char == newChar and v.itemID == newItemID then
					printf("Such entry already exists.")
					return
				end
			end

			table.insert(SMOKEYLOOT.RAID, id, {})

			-- check if this item char combo exists in database, add pluses if it does
			for k, v in ipairs(SMOKEYLOOT.DATABASE) do
				if v.itemID == newItemID and v.char == newChar then
					SMOKEYLOOT.RAID[id].bonus = v.bonus
					break
				end
			end

			SMOKEYLOOT.RAID[id].bonus = SMOKEYLOOT.RAID[id].bonus or newBonus
		else
			for k, v in ipairs(SMOKEYLOOT.RAID) do
				if v.char == newChar and k ~= id then
					printf("%s entry already exists.", newChar)
					return
				end
			end
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
	if CurrentTab == "DATABASE" and SmokeyLoot.IsOfficer() then
		if DBSyncInProgress then return end
		if SMOKEYLOOT.DATABASE.date < SmokeyLoot.GetRemoteVersion() then
			printf("You need to get latest database first.")
			return
		end
		table.remove(SMOKEYLOOT.DATABASE, SmokeyLootEditEntryFrame.id)
		SmokeyLoot.UpdateHR()
		SmokeyLoot.SetRemoteVersion()

	elseif CurrentTab == "RAID" and IsMasterLooter() then
		table.remove(SMOKEYLOOT.RAID, SmokeyLootEditEntryFrame.id)
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
	SmokeyLoot.ToggleEditEntryFrame(table.getn(SMOKEYLOOT[CurrentTab]) + 1, true)
end

function SmokeyLoot.AddButton_OnShow()
	if (CurrentTab == "DATABASE" and not SmokeyLoot.IsOfficer()) or (CurrentTab == "RAID" and not IsMasterLooter()) then
		SmokeyLootAddButton:Disable()
		return
	end

	if (CurrentTab == "RAID" and table.getn(SMOKEYLOOT.RAID) > 0) or (CurrentTab == "DATABASE" and table.getn(SMOKEYLOOT.RAID) == 0) then
		SmokeyLootAddButton:Enable()
	else
		SmokeyLootAddButton:Disable()
	end
end

function SmokeyLoot.EnableRaidControls()
	if table.getn(SMOKEYLOOT.RAID) > 0 and IsMasterLooter() then
		if not DBSyncInProgress then
			SmokeyLootFinishRaidButton:Enable()
		else
			SmokeyLootFinishRaidButton:Disable()
		end
		if CurrentTab == "RAID" then
			SmokeyLootAddButton:Enable()
			SmokeyLootClearButton:Enable()
		end
	else
		SmokeyLootFinishRaidButton:Disable()
		if CurrentTab == "RAID" then
			SmokeyLootAddButton:Disable()
			if GetNumRaidMembers() == 0 and table.getn(SMOKEYLOOT.RAID) > 0 then
				SmokeyLootClearButton:Enable()
			else
				SmokeyLootClearButton:Disable()
			end
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
				table.insert(LootLinks, link.."x"..count)
			else
				table.insert(LootLinks, link)
			end
		end
	end

	local channel = IsRaidOfficer() and "RAID_WARNING" or "RAID"
	local firstSent = false

	for i = 1, table.getn(LootLinks) do
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

SLASH_SMOKEYLOOT1 = "/smokeyloot"
SLASH_SMOKEYLOOT2 = "/sloot"

SlashCmdList.SMOKEYLOOT = function(cmd)
	cmd = string.lower(cmd)
	if cmd == "versions" then
		if GetNumRaidMembers() == 0 then
			printf("You need to be in a raid group to query addon version.")
			return
		end

		listwipe(SmokeyAddonVersions)

		for i = 1, GetNumRaidMembers() do
			SmokeyAddonVersions[GetRaidRosterInfo(i)] = -1
		end

		printf("Starting addon version check.")

		SendAddonMessage("SmokeyLoot", "REPORT_ADDON_VERSION", "RAID")

		QueueFunction(3, function()
			local outdated = ""
			local noAddon = ""
			local same = ""
			local higher = ""
			local myVersion = tonumber(GetAddOnMetadata("SmokeyLoot", "Version"))

			for k, v in pairs(SmokeyAddonVersions) do
				if k ~= UnitName("player") then
					if v > myVersion then
						higher = higher..k.."("..v.."), "
					elseif v == myVersion then
						same = same..k..", "
					elseif v < myVersion and v ~= -1 then
						outdated = outdated..k.."("..v.."), "
					elseif v == -1 then
						noAddon = noAddon..k..", "
					end
				end
			end
			if noAddon ~= "" then printf("Did not report: %s", noAddon) end
			if outdated ~= "" then printf("Outdated: %s", outdated) end
			if same ~= "" then printf("Same version: %s", same) end
			if higher ~= "" then printf("Higher version: %s", higher) end
		end)

	elseif cmd == "debug" then
		SmokeyLootConfig.debugMessages = not SmokeyLootConfig.debugMessages
		printf("debug messages %s", SmokeyLootConfig.debugMessages and "on" or "off")

	elseif cmd == "sounds" then
		SmokeyLootConfig.sounds = not SmokeyLootConfig.sounds
		printf("sounds %s", SmokeyLootConfig.sounds and "on" or "off")

	elseif cmd == "alerts" then
		SmokeyLootConfig.alerts = not SmokeyLootConfig.alerts
		printf("alerts %s", SmokeyLootConfig.alerts and "on" or "off")

	else
		printf("/sloot versions - query raid members addon version")
		printf("/sloot sounds - toggle sounds")
		printf("/sloot alerts - toggle roll alerts")
		printf("/sloot debug - toggle debug messages")
	end
end

function SmokeyLoot.PopupFrame_OnShow()
	if not SmokeyItem.id then return end
	if not SmokeyLootConfig.sounds then return end
	local soundFile
	if MyHRItemIDs[SmokeyItem.id] or string.find(SmokeyItem.candidatesSR, UnitName("player"), 1, true) then
		soundFile = Sounds.dropped[math.random(table.getn(Sounds.dropped))]
	end
	if soundFile then
		debugprint("playing on show ["..soundFile.."] for ["..UnitName("player").."]")
		PlaySoundFile("Interface\\AddOns\\SmokeyLoot\\Sounds\\"..soundFile..".mp3")
	end
end

function SmokeyLoot.PlayRollResultSound()
	if not SmokeyLootConfig.sounds then return end
	local choise = SmokeyItem.choise
	local winner = SmokeyItem.winner
	local tmogWinner = SmokeyItem.tmogWinner
	if choise and choise ~= "PASS" and (winner or tmogWinner) then
		local name = UnitName("player")
		local sounds = (winner == name or tmogWinner == name) and Sounds.won or Sounds.lost
		local soundFile = sounds[math.random(table.getn(sounds))]
		if soundFile then
			debugprint("playing ["..soundFile.."] for ["..name.."]")
			PlaySoundFile("Interface\\AddOns\\SmokeyLoot\\Sounds\\"..soundFile..".mp3")
		end
	end
end

Sauce:RegisterType("customScale", {
	init = function(target, from)
		return from or target:GetScale()
	end,
	apply = function(target, from, to, t)
		local size = from + (to - from) * t
		target:SetScale(math.max(1, size))
	end,
})

function SmokeyLoot.AlertAnimation(name, roll)
	if not SmokeyLootConfig.alerts then return end
	Sauce:Stop(SmokeyLootAlert)
	SmokeyLootAlert:Show()
	if roll > 69 then
		SmokeyLootAlertText:SetText(name.." rolls "..roll.."!")
		Sauce:Sequence({
			Sauce:Group({
				Sauce:SlideIn(SmokeyLootAlert, "DOWN", 40, 4),
				Sauce:FadeIn(SmokeyLootAlert, 4),
			}),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Shake(SmokeyLootAlert, 5, 1),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Shake(SmokeyLootAlert, 5, 1),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:Shake(SmokeyLootAlert, 5, 1),
			Sauce:FadeOut(SmokeyLootAlert, 0.4),
		})
	elseif roll == 69 then
		SmokeyLootAlertText:SetText(name.." rolls 69! Nice!")
		SmokeyLootAlert:Show()
		Sauce:Sequence({
			Sauce:SlideIn(SmokeyLootAlert, "DOWN", 40, 0.3),
			Sauce:FadeOut(SmokeyLootAlert, 0.4, nil, { delay = 5 }),
		})
	elseif roll == 1 then
		SmokeyLootAlertText:SetText(name.." rolls 1! ROFL")
		SmokeyLootAlert:Show()
		Sauce:Sequence({
			Sauce:SlideIn(SmokeyLootAlert, "DOWN", 40, 0.3),
			Sauce:Group({
				Sauce:Shake(SmokeyLootAlert, 5, 0.2),
				Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1, to = 1.1, duration = 0.2 }),
			}),
			Sauce:Tween(SmokeyLootAlert, { type = "customScale", from = 1.1, to = 1, duration = 0.2 }),
			Sauce:FadeOut(SmokeyLootAlert, 0.4, nil, { delay = 5 }),
		})
	end
end

