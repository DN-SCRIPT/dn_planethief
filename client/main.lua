ESX = exports["es_extended"]:getSharedObject()
local PlayerData              	= {}
local currentZone               = ''
local LastZone                  = ''
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

local alldeliveries             = {}
local randomdelivery            = 1
local isTaken                   = 0
local isDelivered               = 0
local plain						= 0
local copblip
local deliveryblip




RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

--Add all deliveries to the table
Citizen.CreateThread(function()
	local deliveryids = 1
	for k,v in pairs(Config.Delivery) do
		table.insert(alldeliveries, {
				id = deliveryids,
				posx = v.Pos.x,
				posy = v.Pos.y,
				posz = v.Pos.z,
				payment = v.Payment,
				plain = v.plain,
		})
		deliveryids = deliveryids + 1  
	end
end)

function Spawnplain()
	ESX.TriggerServerCallback('esx_plainthief:isActive', function(isActive, cooldown)
		if cooldown <= 0 then
			if isActive == 0 then
				ESX.TriggerServerCallback('esx_plainthief:anycops', function(anycops)
					if anycops >= Config.CopsRequired then

						--Get a random delivery point
						randomdelivery = math.random(1,#alldeliveries)
						
						--Delete vehicles around the area (not sure if it works)
						ClearAreaOfVehicles(Config.VehicleSpawnPoint.Pos.x, Config.VehicleSpawnPoint.Pos.y, Config.VehicleSpawnPoint.Pos.z, 10.0, false, false, false, false, false)
						
						--Delete old vehicle and remove the old blip (or nothing if there's no old delivery)
						SetEntityAsNoLongerNeeded(plain)
						DeleteVehicle(plain)
						RemoveBlip(deliveryblip)
						

						--Get random plain
						randomplain = math.random(1,#alldeliveries[randomdelivery].plain)

						--Spawn plain
						local vehiclehash = GetHashKey(alldeliveries[randomdelivery].plain[randomplain])
						RequestModel(vehiclehash)
						while not HasModelLoaded(vehiclehash) do
							RequestModel(vehiclehash)
							Citizen.Wait(1)
						end
						plain = CreateVehicle(vehiclehash, Config.VehicleSpawnPoint.Pos.x, Config.VehicleSpawnPoint.Pos.y, Config.VehicleSpawnPoint.Pos.z, Config.VehicleSpawnPoint.Pos.alpha, true, false)
						SetEntityAsMissionEntity(plain, true, true)
						
						--Teleport player in plain
						TaskWarpPedIntoVehicle(GetPlayerPed(-1), plain, -1)
						
						--Set delivery blip
						deliveryblip = AddBlipForCoord(alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz)
						SetBlipSprite(deliveryblip, 1)
						SetBlipDisplay(deliveryblip, 4)
						SetBlipScale(deliveryblip, 1.0)
						SetBlipColour(deliveryblip, 1)
						SetBlipAsShortRange(deliveryblip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString("Delivery")
						EndTextCommandSetBlipName(deliveryblip)
						
						SetBlipRoute(deliveryblip, true)

						--Register acitivity for server
						TriggerServerEvent('esx_plainthief:registerActivity', 1)
						
						--For delivery blip
						isTaken = 1
						
						--For delivery blip
						isDelivered = 0
					else
						exports["dn_notify"]:notify('PLAIN THEIF', 'not enough cops are available!', 'error', 10000)
					end
				end)
			else
				exports["dn_notify"]:notify('PLAIN THEIF', 'already robbery!', 'warn', 10000)
			end
		else
			ESX.ShowNotification(_U('cooldown', math.ceil(cooldown/1000)))
		end
	end)
end

function FinishDelivery()
  if(GetVehiclePedIsIn(GetPlayerPed(-1), false) == plain) and GetEntitySpeed(plain) < 3 then
		
		--Delete plain
		SetEntityAsNoLongerNeeded(plain)
		DeleteEntity(plain)
		
    --Remove delivery zone
    RemoveBlip(deliveryblip)

    --Pay the poor fella
		local finalpayment = alldeliveries[randomdelivery].payment
		TriggerServerEvent('esx_plainthief:pay', finalpayment)

		--Register Activity
		TriggerServerEvent('esx_plainthief:registerActivity', 0)

    --For delivery blip
    isTaken = 0

    --For delivery blip
    isDelivered = 1
		
		--Remove Last Cop Blips
    TriggerServerEvent('esx_plainthief:stopalertcops')
		
  else
		TriggerEvent('esx:showNotification', _U('plain_provided_rule'))
  end
end

function AbortDelivery()
	--Delete plain
	SetEntityAsNoLongerNeeded(plain)
	DeleteEntity(plain)

	--Remove delivery zone
	RemoveBlip(deliveryblip)

	--Register Activity
	TriggerServerEvent('esx_plainthief:registerActivity', 0)

	--For delivery blip
	isTaken = 0

	--For delivery blip
	isDelivered = 1

	--Remove Last Cop Blips
	TriggerServerEvent('esx_plainthief:stopalertcops')
end

--Check if player left plain
Citizen.CreateThread(function()
  while true do
    Wait(1000)
		if isTaken == 1 and isDelivered == 0 and not (GetVehiclePedIsIn(GetPlayerPed(-1), false) == plain) then
			TriggerEvent('esx:showNotification', _U('get_back_plain_1m'))
			Wait(50000)
			if isTaken == 1 and isDelivered == 0 and not (GetVehiclePedIsIn(GetPlayerPed(-1), false) == plain) then
				TriggerEvent('esx:showNotification', _U('get_back_plain_10s'))
				Wait(10000)
				TriggerEvent('esx:showNotification', _U('mission_failed'))
				AbortDelivery()
			end
		end
	end
end)

-- Send location
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(Config.BlipUpdateTime)
    if isTaken == 1 and IsPedInAnyVehicle(GetPlayerPed(-1)) then
			local coords = GetEntityCoords(GetPlayerPed(-1))
      TriggerServerEvent('esx_plainthief:alertcops', coords.x, coords.y, coords.z)
		elseif isTaken == 1 and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
			TriggerServerEvent('esx_plainthief:stopalertcops')
    end
  end
end)

RegisterNetEvent('esx_plainthief:removecopblip')
AddEventHandler('esx_plainthief:removecopblip', function()
		RemoveBlip(copblip)
end)

RegisterNetEvent('esx_plainthief:setcopblip')
AddEventHandler('esx_plainthief:setcopblip', function(cx,cy,cz)
		RemoveBlip(copblip)
    copblip = AddBlipForCoord(cx,cy,cz)
    SetBlipSprite(copblip , 161)
    SetBlipScale(copblipy , 2.0)
		SetBlipColour(copblip, 8)
		PulseBlip(copblip)
end)

RegisterNetEvent('esx_plainthief:setcopnotification')
AddEventHandler('esx_plainthief:setcopnotification', function()
	ESX.ShowNotification(_U('plain_stealing_in_progress'))
end)

AddEventHandler('esx_plainthief:hasEnteredMarker', function(zone)
  if LastZone == 'menuplainthief' then
    CurrentAction     = 'plainthief_menu'
    CurrentActionMsg  = _U('steal_a_plain')
    CurrentActionData = {zone = zone}
  elseif LastZone == 'plaindelivered' then
    CurrentAction     = 'plaindelivered_menu'
    CurrentActionMsg  = _U('drop_plain_off')
    CurrentActionData = {zone = zone}
  end
end)

AddEventHandler('esx_plainthief:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
  while true do
		Wait(0)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil
    
      
		if(GetDistanceBetweenCoords(coords, Config.Zones.VehicleSpawner.Pos.x, Config.Zones.VehicleSpawner.Pos.y, Config.Zones.VehicleSpawner.Pos.z, true) < 3) then
			isInMarker  = true
			currentZone = 'menuplainthief'
			LastZone    = 'menuplainthief'
		end
      
		if isTaken == 1 and (GetDistanceBetweenCoords(coords, alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz, true) < 3) then
			isInMarker  = true
			currentZone = 'plaindelivered'
			LastZone    = 'plaindelivered'
		end
        
      
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('esx_plainthief:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_plainthief:hasExitedMarker', LastZone)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if CurrentAction ~= nil then
      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
      if IsControlJustReleased(0, 38) then
        if CurrentAction == 'plainthief_menu' then
          Spawnplain()
        elseif CurrentAction == 'plaindelivered_menu' then
          FinishDelivery()
        end
        CurrentAction = nil
      end
    end
  end
end)

-- Display markers
Citizen.CreateThread(function()
  while true do
    Wait(0)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    
    for k,v in pairs(Config.Zones) do
			if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end
    
  end
end)

-- Display markers for delivery place
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if isTaken == 1 and isDelivered == 0 then
    local coords = GetEntityCoords(GetPlayerPed(-1))
      v = alldeliveries[randomdelivery]
			if (GetDistanceBetweenCoords(coords, v.posx, v.posy, v.posz, true) < Config.DrawDistance) then
				DrawMarker(1, v.posx, v.posy, v.posz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 204, 204, 0, 100, false, false, 2, false, false, false, false)
			end
    end
  end
end)

-- Create Blips for plain Spawner
Citizen.CreateThread(function()
    info = Config.Zones.VehicleSpawner
    info.blip = AddBlipForCoord(info.Pos.x, info.Pos.y, info.Pos.z)
    SetBlipSprite(info.blip, info.Id)
    SetBlipDisplay(info.blip, 4)
    SetBlipScale(info.blip, 1.0)
    SetBlipColour(info.blip, info.Colour)
    SetBlipAsShortRange(info.blip, true)
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('Plain Robbery'))
    EndTextCommandSetBlipName(info.blip)
end)
