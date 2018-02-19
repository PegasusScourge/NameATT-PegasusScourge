local GetAllUnits = import('/mods/NameATT-PegasusScourge/modules/allunits.lua').GetAllUnits
local randomOffset = math.floor(Random(0,10))

local acuNames = {
	'Commander Pegasus',
	'Peggy',
	'PegaSaltScourge',
	'[ONI] PegasusScourge',
  'Komrade Pegasus'
}

local expNames = {
	'Special Little Item',
	'Base Crasher',
	'T4, Obviously',
	'T4, Don\'t ya know?',
	'Mass Donation',
	'ROFL Stomper',
	'Desperation',
	'Kevin'
}

local floatyArtyNames = {
	'Devil-Child',
	'Dastardly Plan',
	'Pain In The Mex',
	'So Not A Tank',
	'Nothing To See Here',
	'Kevin'
}

local sacuNames = {
	'[ONI] BRNKoSALTY',
	'[ONI] FailedJaguar8',
	'[ONI] D_Craft',
	'[ONI] TridentBowman',
	'[ONI] Lorax',
	'[ONI] Twink3l',
	'[ONI] Row3y',
	'Armd\'n\'Dangerous',
	'Johnrude227',
	'[ONI] Picolo',
	'Ionised_Dog',
	'Misthaups',
	'CREHH',
	'hirschy\'s kisses',
	'A Vibraxis Pun',
	'*cough* BJ *cough*',
	'A Lape Pun',
	'[ONI] Greunerzorn',
	'[ONI] SmurfedJaguar8'
	
}

local genericNames = {
	'Pop-culture Reference',
	'Kevin',
	'Xavier',
	'Ted',
	'Richard',
	'"What Am I?"'
}

local stunnedPrefixes = {
	"Confused",
	'Shocked',
	'Unconscious'
}

local topHealthOpener = 'Shiny'
local mostHealthOpener = 'Damaged'
local lessHealthOpener = 'Broken'
local minimalHealthOpener = 'Terminal'
local defaultHealthOpener = '%&*(£$%&'

-- These are lower boundaries
local topHealthThreshold = 0.8
local mostHealthThreshold = 0.6
local lessHealthThreshold = 0.4
local minimalHealthThreshold = 0.2

local numExpNames = table.getn(expNames)
local numSacuNames = table.getn(sacuNames)
local numAcuNames = table.getn(acuNames)
local numStunned = table.getn(stunnedPrefixes)
local numFloatyArtyNames = table.getn(floatyArtyNames)
local numGenericNames = table.getn(genericNames)

-- A time that we last updated the ACU name
local lastACUNameUpdateT = 0
local currentACUNameIndex = 0
-- Mean time to rename, in seconds
local MTTRN = 80
-- Maximum random fluctuation time in seconds added/subtracted from MTTRN. Magnitude is randomised up to this value
local TTRNfLC = 10
-- Time to next update the ACU name. Determined at the time of the last rename
local nextACUNameUpdateT = 10

-- INIT VARIABLES
local initACUName = false
-- END

function NameUnits()
	while true do
		WaitSeconds(1)
		NameUnitsNow()
	end
end

function NameUnitsNow()
	for _,u in GetAllUnits() do
		if not u:IsInCategory("STRUCTURE") and isAcceptedCatagory(u) then
			NameUnit(u)
		end
	end
end

function NameUnit(u)
	local name = MakeUnitName(u)

	if u:GetCustomName(nil) != name then
		u:SetCustomName(name)
	end
end

function MakeUnitName(u)
	local entityId = tonumber(u:GetEntityId()) + randomOffset
  
	-- Make sure we exit if the unit isn't nameable
	if not isAcceptedCatagory(u) then
		return "Um this shouldn't be named...."
	end
  
	if u:IsInCategory("COMMAND") then
	
		local n = acuNames[currentACUNameIndex]
	
		if not initACUName then
			-- ACU name init
			currentACUNameIndex = math.floor(Random(0,(numAcuNames-1))) + 1
			
			if currentACUNameIndex > numAcuNames or currentACUNameIndex <= 0 then
				currentACUNameIndex = 1
			end
			
			n = acuNames[currentACUNameIndex]
		
			ACUNameChanged()
		
			initACUName = true
		elseif nextACUNameUpdateT <= GetGameTimeSeconds() then
		
			-- Name Normally
			local acuNameIncrement = currentACUNameIndex + math.floor(Random(0,2))
			currentACUNameIndex = modulo((entityId + acuNameIncrement), numAcuNames) + 1
			
			if currentACUNameIndex > numAcuNames or currentACUNameIndex <= 0 then
				currentACUNameIndex = 1
			end
			
			n = acuNames[currentACUNameIndex]
		
			ACUNameChanged()
	
		end
	
		-- OLD CODE
		--acuNameIncrementActivate = acuNameIncrementActivate + 1
	
		--if selectedAcuName == "0" or (acuNameIncrementActivate == 80) then
		--  acuNameIncrement = acuNameIncrement + math.floor(Random(0,4))
		--  selectedAcuName = acuNames[modulo((entityId + acuNameIncrement), numAcuNames) + 1]
		--  acuNameIncrementActivate = 0
		--end
		
		--local n = selectedAcuName
	
		if u:IsStunned() then
			n = n .. " Is " .. stunnedPrefixes[modulo(entityId, numStunned) + 1]
		end
	
		return n
	end
  
	local name = GetHealthPrefix((u:GetMaxHealth() == 0) and 1 or (u:GetHealth() / u:GetMaxHealth()))

	-- UEF Fat Boy detection
	--if u:IsInCategory('UEF') and u:IsInCategory('LAND') and u:IsInCategory('EXPERIMENTAL') then
	--	name = name .. " Flightless Soul Ripper, "
	--end
  
	if isSeraphimT1FloatyArty(u) then
		name = name .. " Floaty"
	end
  
	if u:IsStunned() and u:IsInCategory('EXPERIMENTAL') then
		name = name .. " " .. stunnedPrefixes[modulo(entityId, numStunned) + 1]
	end

	if u:IsIdle() and u:IsInCategory('SUBCOMMANDER') then
		name = name .. " Distracted"
	end
  
	if u:IsInCategory('EXPERIMENTAL') then
		name = name .. " " .. expNames[modulo(entityId, numExpNames) + 1]
	elseif u:IsInCategory('SUBCOMMANDER') then
		name = name .. " " .. sacuNames[modulo(entityId, numSacuNames) + 1]
	elseif isSeraphimT1FloatyArty(u) then
		name = name .. " " .. floatyArtyNames[modulo(entityId, numFloatyArtyNames) + 1]
	else
		name = name .. " " .. genericNames[modulo(entityId, numGenericNames) + 1]
	end

	return name
end

function isAcceptedCatagory(u)
	if u:IsInCategory('EXPERIMENTAL') or u:IsInCategory("COMMAND") or u:IsInCategory('SUBCOMMANDER') or isSeraphimT1FloatyArty(u) then
		return true
	end
	return false
end

function isSeraphimT1FloatyArty(u)
	if u:IsInCategory('SERAPHIM') and u:IsInCategory('TECH1') and  u:IsInCategory('LAND') and u:IsInCategory('HOVER') and not u:IsInCategory('ENGINEER') then
		return true;
	end
	return false;
end

function modulo(a,b)
	return a - math.floor(a/b)*b
end

function GetHealthPrefix(percent)
	
	-- When health above this percent
	if percent > topHealthThreshold then
		return topHealthOpener
	end
	
	if percent > mostHealthThreshold then
		return mostHealthOpener
	end
	
	if percent > lessHealthThreshold then
		return lessHealthOpener
	end
	
	if percent > minimalHealthThreshold then
		return minimalHealthOpener
	end
	
	return defaultHealthOpener
	
	--if percent > 0.8 then
	--	return highHealthOpener
	--end
	--if percent > 0.6 then
	--	return minorDamageOpener
	--end
	--if percent > 0.3 then
	--	return lowDamageOpener
	--end
	--return highDamageOpener
end

function ACUNameChanged()

	lastACUNameUpdateT = GetGameTimeSeconds()
	-- This creates a +/- TTRNfLC by using twice the value then removing the TTRNfLC value
	local randomAjust = math.floor(Random(0, (TTRNfLC*2))) - TTRNfLC
	nextACUNameUpdateT = lastACUNameUpdateT + MTTRN + randomAjust

end

-- NO IMPORT NECESSARY
-- GetGameTimeSeconds() (number, in seconds)
-- GetGameTime()		(string)
