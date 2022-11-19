local enabled = Config.Enabled
local speedlimits = GetSpeedLimits()
local currentStreet = "street"
local speedlimit = 0
local overwriteSpeed = 0
local advisorySpeed = 0
local cacheId = -1
local lastNode = 0
local eventHandler = nil
local pauseMenu = false


-- Functions --
local function DisplayNotification(msg)
	-- Native way of displaying notifications (comment out if you wish to use custom ones)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostTicker(false, false)

	-- Here is a QBCore version for those who use that.
	-- TriggerEvent('QBCore:Notify', msg, 'primary', 5000)
end

local function OverrideSpeedLimit(newSpeed)
	if newSpeed ~= overwriteSpeed then
		overwriteSpeed = newSpeed
		if speedlimit ~= newSpeed then
			speedlimit = newSpeed
			SendNUIMessage({
				action = 'changeLimit',
				fade = true,
				fadeOut = Config.DisplayOnlyOnChange,
				numeral = newSpeed
			})
		end
	end
end

local function SetAdvisorySpeed(limit, label)
	if limit ~= advisorySpeed then
		if advisorySpeed == 0 then
			SendNUIMessage({
				action = 'changeAdvisory',
				fade = false,
				label = label,
				numeral = limit
			})
			SendNUIMessage({ action = 'showAdvisory' })
		else
			SendNUIMessage({
				action = 'changeAdvisory',
				fade = true,
				label = label,
				numeral = limit
			})
		end
		advisorySpeed = limit
	end
end

local function RefreshBaseSpeedLimit()
	local streetData = speedlimits[currentStreet]
	if streetData then
		local newSpeed = streetData.limit
		if newSpeed ~= speedlimit then
			speedlimit = newSpeed
			SendNUIMessage({
				action = 'changeLimit',
				fade = true,
				numeral = newSpeed
			})
		end
	end
end

-- Functions for cheking if we are on a side of a point
local sideOfPointFunctions = {
	west = function(x, _y, point)
		return x < point
	end,
	east = function(x, _y, point)
		return x > point
	end,
	north = function(_x, y, point)
		return y > point
	end,
	south = function(_x, y, point)
		return y < point
	end
}

-- Checks for overwrite speeds
local function CheckOverwriteSpeeds(nodeId, position)
	local streetData = speedlimits[currentStreet]
	if streetData and streetData.overwrite then

		-- Checks if the current node has is overwriten
		if streetData.overwrite.nodes then
			for _name, data in pairs(streetData.overwrite.nodes) do
				if data.nodes[nodeId] then
					OverrideSpeedLimit(data.limit)
					return
				end
			end
		end
		
		-- Checks if we are inside a radius
		local insideRadiusData = speedlimits[currentStreet].overwrite.inside_radius
		if insideRadiusData then
			for _name, data in pairs(insideRadiusData) do
				local dist = #(position.xy-data.center)
				if dist < data.radius then
					if data.limit ~= overwriteSpeed then
						OverrideSpeedLimit(data.limit)
					end
					return
				end
			end
		end

		-- Checks if we are on one side of point
		local sideOfPointData = speedlimits[currentStreet].overwrite.side_of_point
		if sideOfPointData then
			for side, data in pairs(sideOfPointData) do
				if sideOfPointFunctions[side](position.x, position.y, data.point) then
					if data.limit ~= overwriteSpeed then
						OverrideSpeedLimit(data.limit)
					end
					return
				end
			end
		end
	end

	if overwriteSpeed ~= 0 then
		overwriteSpeed = 0
		RefreshBaseSpeedLimit()
	end
end

-- Checks streetData if we should show any advisory signs
local function CheckAdvisorySpeeds(nodeId, position)
	local streetData = speedlimits[currentStreet]
	if streetData and streetData.advisory then

		-- Checks if the current node has any advisory signs
		if streetData.advisory.nodes then
			for name, data in pairs(streetData.advisory.nodes) do
				if data.nodes[nodeId] then
					SetAdvisorySpeed(data.limit, data.label)
					return
				end
			end
		end

		-- Checks if we are inside a radius
		local insideRadiusData = speedlimits[currentStreet].advisory.inside_radius
		if insideRadiusData then
			for name, data in pairs(insideRadiusData) do
				local dist = #(position.xy-data.center)
				if dist < data.radius then
					SetAdvisorySpeed(data.limit, data.label)
					return
				end
			end
		end

		-- Checks if we are on one side of point
		local sideOfPointData = speedlimits[currentStreet].advisory.side_of_point
		if sideOfPointData then
			for side, data in pairs(sideOfPointData) do
				if sideOfPointFunctions[side](position.x, position.y, data.point) then
					SetAdvisorySpeed(data.limit, data.label)
					return
				end
			end
		end
	end

	-- Hide advisory UI if we could't find any advisories
	if advisorySpeed ~= 0 then
		advisorySpeed = 0
		SendNUIMessage({ action = 'hideAdvisory' })
	end
end

-- Gets executed when we change streets
local function OnStreetChange(newStreet, nodeId, position)
	currentStreet = newStreet
	local newSpeedlimit = speedlimits['default'].limit
	local streetData = speedlimits[newStreet]
	
	if streetData then
		newSpeedlimit = streetData.limit
	else
		print("OnStreetChange: streetData not found! Street: "..GetStreetNameFromHashKey(newStreet).." ("..newStreet..")")
	end

	CheckOverwriteSpeeds(nodeId, position)
	if Config.AdvisoryType then
		CheckAdvisorySpeeds(nodeId, position)
	end

	if newSpeedlimit ~= speedlimit and overwriteSpeed == 0 then
		local fade = true
		if speedlimit == 0 then
			fade = false
		end

		speedlimit = newSpeedlimit
		SendNUIMessage({
			action = 'changeLimit',
			fade = fade,
			numeral = speedlimit
		})
	end
end

local function ShowNUISpeedLimit()
	Citizen.CreateThread(function()
		Citizen.Wait(600)
		SendNUIMessage({ action = 'show' })
	end)
end

-- Main Thread --
local function StartStreetThread()
	Citizen.CreateThread(function()

		ShowNUISpeedLimit()

		while true do
			local playerPed = PlayerPedId()

			-- Stop the loop if we left the vehicle or disabled the speed signs
			if not IsPedInAnyVehicle(playerPed, false) or not enabled then
				break
			end

			-- Collect data about position and closest vehicle node
			local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
			local nodeId = GetNthClosestVehicleNodeId(coords.x, coords.y, coords.z, 0.0, 1, 7.0, 2.5)
			local position = GetVehicleNodePosition(nodeId)
			local newStreet, _newCrossing = GetStreetNameAtCoord(position.x, position.y, position.z)

			-- Checks if the street has changed
			if newStreet ~= currentStreet then
				if cacheId == 0 then
					cacheId = nodeId
				elseif cacheId ~= nodeId then
					OnStreetChange(newStreet, nodeId, position)
				end
			else
				cacheId = 0

				-- Only check if the node has changed if we haven't changed street this loop (and if so check for overwrite speeds)
				if nodeId ~= lastNode then
					CheckOverwriteSpeeds(nodeId, position)
					if Config.AdvisoryType then
						CheckAdvisorySpeeds(nodeId, position)
					end
					lastNode = nodeId
				end
			end

			-- Hides NUI if you are in the pause menu (except if you use Config.DisplayOnlyOnChange)
			if not Config.DisplayOnlyOnChange then
				if IsPauseMenuActive() then
					if not pauseMenu then
						pauseMenu = true
						SendNUIMessage({ action = 'hide' })
					end
				elseif pauseMenu then
					pauseMenu = false
					SendNUIMessage({ action = 'show' })
				end
			end

			Citizen.Wait(500)
		end

		-- Hide NUI and reset variables
		SendNUIMessage({ action = 'hide' })
		currentStreet = "street"
		speedlimit = 0
		advisorySpeed = 0
		cacheId = -1
		lastNode = 0
		pauseMenu = false
	end)
end


-- Events --
local function RegisterPlyEnterVehEvent()
	eventHandler = AddEventHandler('gameEventTriggered', function(event, args)
		if event == "CEventNetworkPlayerEnteredVehicle" then
			if args[1] == PlayerId() then
				local playerPed = PlayerPedId()
				local vehicle = GetVehiclePedIsIn(playerPed, false)
				if Config.DriverOnly then
					if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
						return
					end
				end

				local class = GetVehicleClass(vehicle)
				if Config.BlacklistedClasses[class] then
					return
				end

				StartStreetThread()
			end
		end
	end)
end


-- Init --
-- Sets up the node tables to allow for lookups instead of having to loop through them
local function SetUpNodeArrays()
	for hash, info in pairs(speedlimits) do
		if info.advisory and info.advisory.nodes then
			for name, data in pairs(info.advisory.nodes) do
				local nodeArray = {}
				for index, id in pairs(data.nodes) do
					nodeArray[id] = index
				end
				speedlimits[hash].advisory.nodes[name].nodes = {}
				speedlimits[hash].advisory.nodes[name].nodes = nodeArray
			end
		end
		if info.overwrite and info.overwrite.nodes then
			for name, data in pairs(info.overwrite.nodes) do
				local nodeArray = {}
				for index, id in pairs(data.nodes) do
					nodeArray[id] = index
				end
				speedlimits[hash].overwrite.nodes[name].nodes = {}
				speedlimits[hash].overwrite.nodes[name].nodes = nodeArray
			end
		end
	end
end

Citizen.CreateThread(function()
	SetUpNodeArrays()
	Citizen.Wait(1000)
	SendNUIMessage({
		action = 'setConfig',
		type = Config.SignType,
		advisory = Config.AdvisoryType,
		displayOnlyOnChange = Config.DisplayOnlyOnChange,
		displayWait = Config.ChangeDisplayTime
	})

	if enabled then
		RegisterPlyEnterVehEvent()
	end
end)


-- Commads --
RegisterCommand("speedlimit", function(source, args, rawCommand)
	enabled = not enabled

	if enabled then
		RegisterPlyEnterVehEvent() -- Register Event
		DisplayNotification(Config.Localization.ShowSpeedlimit)

		-- Check if allready in vehicle etc.
		local playerPed = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		if vehicle == 0 or vehicle == nil then
			return
		end

		local class = GetVehicleClass(vehicle)
		if Config.BlacklistedClasses[class] then
			return
		end

		StartStreetThread()
	else
		RemoveEventHandler(eventHandler)
		eventHandler = nil

		DisplayNotification(Config.Localization.HideSpeedlimit)
	end
end, false)
