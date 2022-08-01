local QBCore = exports['qb-core']:GetCoreObject()

isLoggedIn = true

local menuOpen = false
local wasOpen = false
local spawnedPervitin = 0
local pervitinPlants = {}

local isPickingUp, isProcessing, isProcessing2 = false, false, false

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
	CheckCoords()
	Wait(1000)
	local coords = GetEntityCoords(PlayerPedId())
	if GetDistanceBetweenCoords(coords, Config.CircleZones.PervitinField.coords, true) < 1000 then
		SpawnPervitinPlants()
	end
end)

function CheckCoords()
	CreateThread(function()
		while true do
			local coords = GetEntityCoords(PlayerPedId())
			if GetDistanceBetweenCoords(coords, Config.CircleZones.PervitinField.coords, true) < 1000 then
				SpawnPervitinPlants()
			end
			Wait(1 * 60000)
		end
	end)
end

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		CheckCoords()
	end
end)

CreateThread(function()--Pervitin
	while true do
		Wait(10)

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID


		for i=1, #pervitinPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(pervitinPlants[i]), false) < 1 then
				nearbyObject, nearbyID = pervitinPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then

			if not isPickingUp then
				QBCore.Functions.Draw2DText(0.5, 0.88, 'Press ~g~[E]~w~ to pickup Pills', 0.4)
			end

			if IsControlJustReleased(0, 38) and not isPickingUp then
				isPickingUp = true
				TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, false)
				QBCore.Functions.Progressbar("search_register", "Picking up Pills..", 3000, false, true, {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
					disableInventory = true,
				}, {}, {}, {}, function() -- Done
					ClearPedTasks(PlayerPedId())
					QBCore.Functions.DeleteObject(nearbyObject)

					table.remove(pervitinPlants, nearbyID)
					spawnedPervitin = spawnedPervitin - 1

					TriggerServerEvent('qb-pervitinpicking:pickedUpPervitin')
				end, function()
					ClearPedTasks(PlayerPedId())
				end)

				isPickingUp = false
			end
		else
			Wait(500)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(pervitinPlants) do
			QBCore.Functions.DeleteObject(nearbyObject)
		end
	end
end)
function SpawnPervitinPlants()
	while spawnedPervitin < 20 do
		Wait(1)
		local pervitinCoords = GeneratePervitinCoords()

		QBCore.Functions.SpawnLocalObject('prop_drop_crate_01', pervitinCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)


			table.insert(pervitinPlants, obj)
			spawnedPervitin = spawnedPervitin + 1
		end)
	end
	Wait(45 * 60000)
end

function ValidatePervitinCoord(plantCoord)
	if spawnedPervitin > 0 then
		local validate = true

		for k, v in pairs(pervitinPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.PervitinField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GeneratePervitinCoords()
	while true do
		Wait(1)

		local pervitinCoordX, pervitinCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-10, 10)

		Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-10, 10)

		pervitinCoordX = Config.CircleZones.PervitinField.coords.x + modX
		pervitinCoordY = Config.CircleZones.PervitinField.coords.y + modY

		local coordZ = GetCoordZPervitin(pervitinCoordX, pervitinCoordY)
		local coord = vector3(pervitinCoordX, pervitinCoordY, coordZ)

		if ValidatePervitinCoord(coord) then
			return coord
		end
	end
end

function GetCoordZPervitin(x, y)
	local groundCheckHeights = { 31.0, 32.0, 33.0, 34.0, 35.0, 36.0, 37.0, 38.0, 39.0, 40.0, 50.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 31.85
end

CreateThread(function()
	while QBCore == nil do
		Wait(200)
	end
	while true do
		Wait(10)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.PervitinProcessing.coords, true) < 5 then
			DrawMarker(2, Config.CircleZones.PervitinProcessing.coords.x, Config.CircleZones.PervitinProcessing.coords.y, Config.CircleZones.PervitinProcessing.coords.z - 0.2 , 0, 0, 0, 0, 0, 0, 0.3, 0.2, 0.15, 255, 0, 0, 100, 0, 0, 0, true, 0, 0, 0)


			if not isProcessing and GetDistanceBetweenCoords(coords, Config.CircleZones.PervitinProcessing.coords, true) <1 then
				QBCore.Functions.DrawText3D(Config.CircleZones.PervitinProcessing.coords.x, Config.CircleZones.PervitinProcessing.coords.y, Config.CircleZones.PervitinProcessing.coords.z, 'Press ~g~[E]~w~ to Process')
			end

			if IsControlJustReleased(0, 38) and not isProcessing then
				local hasBag = false
				local s1 = false
				local hasPervitin = false
				local s2 = false

				QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
					hasPervitin = result
					s1 = true
				end, 'pseudoefedrin')

				while(not s1) do
					Wait(100)
				end
				Wait(100)
				QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
					hasBag = result
					s2 = true
				end, 'plastic_baggie')

				while(not s2) do
					Wait(100)
				end

				if (hasPervitin and hasBag) then
					Processpervitin()
				elseif (hasPervitin) then
					QBCore.Functions.Notify('You dont have enough plastic bags.', 'error')
				elseif (hasBag) then
					QBCore.Functions.Notify('You dont have enough pills.', 'error')
				else
					QBCore.Functions.Notify('You dont have enough pills and plastic bags.', 'error')
				end
			end
		else
			Wait(500)
		end
	end
end)

function Processpervitin()
	isProcessing = true
	local playerPed = PlayerPedId()

	TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_PARKING_METER", 0, true)
	SetEntityHeading(PlayerPedId(), 108.06254)

	QBCore.Functions.Progressbar("search_register", "Trying to Process..", 30000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
		disableInventory = true,
	}, {}, {}, {}, function()
	 TriggerServerEvent('qb-pervitinpicking:processpervitin')

		local timeLeft = Config.Delays.PervitinProcessing / 1000

		while timeLeft > 0 do
			Wait(1000)
			timeLeft = timeLeft - 1

			if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.PervitinProcessing.coords, false) > 4 then
				TriggerServerEvent('qb-pervitinpicking:cancelProcessing')
				break
			end
		end
		ClearPedTasks(PlayerPedId())
	end, function()
		ClearPedTasks(PlayerPedId())
	end) -- Cancel

	isProcessing = false
end

CreateThread(function()
	while QBCore == nil do
		Wait(200)
	end
	while true do
		Wait(10)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.DrugDealer.coords, true) < 5 then
			DrawMarker(2, Config.CircleZones.DrugDealer.coords.x, Config.CircleZones.DrugDealer.coords.y, Config.CircleZones.DrugDealer.coords.z - 0.2 , 0, 0, 0, 0, 0, 0, 0.3, 0.2, 0.15, 255, 0, 0, 100, 0, 0, 0, true, 0, 0, 0)


			if not isProcessing2 and GetDistanceBetweenCoords(coords, Config.CircleZones.DrugDealer.coords, true) <1 then
				QBCore.Functions.DrawText3D(Config.CircleZones.DrugDealer.coords.x, Config.CircleZones.DrugDealer.coords.y, Config.CircleZones.DrugDealer.coords.z, 'Press ~g~[E]~w~ to Sell')
			end

			if IsControlJustReleased(0, 38) and not isProcessing2 then
				local hasPervitin2 = false
				local hasBag2 = false
				local s3 = false

				QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
					hasPervitin2 = result
					hasBag2 = result
					s3 = true

				end, 'pervitin')

				while(not s3) do
					Wait(100)
				end


				if (hasPervitin2) then
					SellDrug()
				elseif (hasPervitin2) then
					QBCore.Functions.Notify('You dont have enough plastic bags.', 'error')
				elseif (hasBag2) then
					QBCore.Functions.Notify('You dont have enough Pills.', 'error')
				else
					QBCore.Functions.Notify('You dont have enough pervitin bags to sell.', 'error')
				end
			end
		else
			Wait(500)
		end
	end
end)

function SellDrug()
	isProcessing2 = true
	local playerPed = PlayerPedId()

	--
	TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_PARKING_METER", 0, true)
	SetEntityHeading(PlayerPedId(), 108.06254)

	QBCore.Functions.Progressbar("search_register", "Trying to Sell..", 1500, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
		disableInventory = true,
	}, {}, {}, {}, function()
	 TriggerServerEvent('qb-pervitinpicking:selld')

		local timeLeft = Config.Delays.PervitinProcessing / 1000

		while timeLeft > 0 do
			Wait(500)
			timeLeft = timeLeft - 1

			if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.PervitinProcessing.coords, false) > 4 then
				break
			end
		end
		ClearPedTasks(PlayerPedId())
	end, function()
		ClearPedTasks(PlayerPedId())
	end) -- Cancel

	isProcessing2 = false
end
