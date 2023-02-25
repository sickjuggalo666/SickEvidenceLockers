ESX = exports['es_extended']:getSharedObject()
local ox_inventory = exports.ox_inventory
local pedspawned = false
local playerState = LocalPlayer.state
local evidenceNpc = nil

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k, v in pairs(Config.location) do
			local pedcoords = GetEntityCoords(PlayerPedId())	
			local dist = #(v.coords - pedcoords)
			
			if dist < 11 and pedspawned == false then
				TriggerEvent('SickEvidence:npclocker',v.coords,v.h)
				pedspawned = true
			end
			if dist >= 10  then
				pedspawned = false
                SetEntityAlpha(evidenceNpc, 1, false)
				DeletePed(evidenceNpc)
			end
		end
	end
end)

RegisterNetEvent('SickEvidence:npclocker')
AddEventHandler('SickEvidence:npclocker',function(coords,heading)
	if Config.UsePed == true then
		local hash = GetHashKey(Config.npc)
		if not HasModelLoaded(hash) then
			lib.requestModel(hash, timeout)
			Wait(10)
		end

		pedspawned = true
		evidenceNpc = CreatePed(5, hash, coords, heading, false, false)
		FreezeEntityPosition(evidenceNpc, true)
		SetBlockingOfNonTemporaryEvents(evidenceNpc, true)
		lib.requestAnimDict("amb@world_human_cop_idles@male@idle_b", 100)
	end
end)

Citizen.CreateThread(function()
	for k,v in pairs(Config.location) do
		exports.ox_target:addBoxZone({
			coords = vector3(v.coords.x,v.coords.y,v.coords.z+1.5),
			size = vec3(3, 2, 3),
			rotation = 90,
			debug = false,
			options = {
				{
					name = 'evidence_Lockers',
					icon = 'fa-solid fa-cube',
					groups = 'police',
					label = 'Open Evidence Locker',
					canInteract = function(entity, distance, coords, name)
						return true
					end,
					onSelect = function()
						openInventory()
					end
				}
			}
		})
	end
end)

lib.registerContext({
	id = 'chiefmenu',
	title = 'Big Chief Shit!',
	options = {
		{
			title = 'Chief Options',
			description = 'Chief Options',
			arrow = true,
			event = 'SickEvidence:ChiefMenu',
		},
		{
			title = 'Open Locker Room',
			description = 'Open Locker Room',
			arrow = true,
			event = 'SickEvidence:lockerCallbackEvent',
		},
		{
			title = 'Open Evidence',
			description = 'Open Evidence Locker',
			arrow = true,
			event = 'SickEvidence:triggerEvidenceMenu',
		}
	},
})

lib.registerContext({
	id = 'openInventory',
	title = 'Evidence Lockers!',
	options = {
		{
			title = 'Open Locker Room',
			description = 'Open Locker Room',
			arrow = true,
			event = 'SickEvidence:lockerCallbackEvent',
		},
		{
			title = 'Open Evidence',
			description = 'Open Evidence Locker',
			arrow = true,
			event = 'SickEvidence:triggerEvidenceMenu',
		}
	},
})

function openInventory()
	refreshjob()
	if Config.Rank[playerState.job.grade_name] then
		lib.showContext('chiefmenu')
	elseif Config.Jobs[playerState.job.name] then 
		lib.showContext('openInventory')
	else
		Notiy("Wrong Job Dude!")
	end
end

function confirmCreate(inventoryID)
	lib.registerContext({
		id = 'confirmCreate',
		title = 'Confirm or Cancel',
		options = {
			{
				title = 'Create New Evidence Inventory?',
				description = 'Evidence Inventory System'
			},
			{
				title = 'Confirm Creation?',
				description = 'Create an Evidence Storage?',
				arrow = true,
				event = 'SickEvidence:confirmorcancel',
				args = {selection = 'confirm', inventory = inventoryID}
			},
			{
				title = 'Cancel Creation?',
				description = 'Cancel The Creation of this Evidence Storage?',
				arrow = true,
				event = 'SickEvidence:confirmorcancel',
				args = {selection = 'cancel'}
			}
		},
	})

	lib.showContext('confirmCreate')
end

RegisterNetEvent('SickEvidence:confirmorcancel')
AddEventHandler('SickEvidence:confirmorcancel', function(args)
	if args.selection == "confirm" then
		local inventoryID = args.inventory
		TriggerServerEvent("SickEvidence:createInventory", inventoryID)
		Wait(1000)
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', inventoryID)
	end
end)

RegisterNetEvent('SickEvidence:triggerEvidenceMenu')
AddEventHandler('SickEvidence:triggerEvidenceMenu', function()
	local input = lib.inputDialog('LSPD Evidence', {'Incident Number (#...)'})

	if not input then 
		lib.hideContext(false)
		return 
	end
	local inventoryID = ("Case :#"..input[1])
	TriggerEvent('SickEvidence:callbackEvent',inventoryID)
end)

RegisterNetEvent('SickEvidence:callbackEvent')
AddEventHandler('SickEvidence:callbackEvent', function(inventoryID)
	ESX.TriggerServerCallback('SickEvidence:getInventory', function(exists)
		if not exists then
			confirmCreate(inventoryID)
		else
			evidenceOption(inventoryID)
		end
	end, inventoryID)
end)

function evidenceOption(inventoryID)
	lib.registerContext({
		id = 'evidenceOption',
		title = 'Evidence Options',
		options = {
			{
				title = 'Evidence Delete/Open'
			},
			{
				title = 'Open Evidence?',
				description = 'Open Evidence Storage?',
				arrow = true,
				event = 'SickEvidence:evidenceOptions',
				args = {
					selection = "open",
					inventory = inventoryID
				}
			},
			{
				title = 'Delete Inventory?',
				description = 'Delete this Evidence Storage?',
				arrow = true,
				event = 'SickEvidence:evidenceOptions',
				args = {
					selection = "delete",
					inventory = inventoryID
				}
			}
		},
	})
	lib.showContext('evidenceOption')
end

RegisterNetEvent('SickEvidence:evidenceOptions')
AddEventHandler('SickEvidence:evidenceOptions', function(args)
	if args.selection == "delete" then
		local inventoryID = args.inventory
		TriggerServerEvent("SickEvidence:deleteEvidence", inventoryID)
		Notiy("Deleted Evidence!")
	elseif args.selection == "open" then
		local inventoryID = args.inventory
		Wait(1000)
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', inventoryID)
	end
end)

function lockerCreate(lockerID)
	lib.registerContext({
		id = 'lockerCreate',
		title = 'Confirm or Cancel',
		options = {
			{
				title = 'Create New Locker?',
				description = 'Locker Inventory System'
			},
			{
				title = 'Confirm Creation?',
				description = 'Create a Personal Locker?',
				arrow = true,
				event = 'SickEvidence:confirmorcancel',
				args = {selection = 'confirm', inventory = lockerID}
			},
			{
				title = 'Cancel Creation?',
				description = 'Cancel The Creation of this Personal Locker?',
				arrow = true,
				event = 'SickEvidence:confirmorcancel',
				args = {selection = 'cancel'}
			}
		},
	})

	lib.showContext('lockerCreate')
end

RegisterNetEvent('SickEvidence:confirmLocker')
AddEventHandler('SickEvidence:confirmLocker', function(args)
	if args.selection == "confirm" then
		local lockerID = args.inventory
		TriggerServerEvent("SickEvidence:createLocker", lockerID)
		Wait(1000)
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', lockerID)
	end
end)

function lockerOption(lockerID)
	lib.registerContext({
		id = 'lockerOption',
		title = 'Confirm or Cancel',
		options = {
			{
				title = 'Locker Options',
				description = 'Locker Delete/Open'
			},
			{
				title = 'Open Locker?',
				description = 'Open a Personal Locker?',
				arrow = true,
				event = 'SickEvidence:lockerOptions',
				args = {selection = 'open', inventory = lockerID}
			},
			{
				title = 'Delete Locker?',
				description = 'Delete Your Personal Locker?',
				arrow = true,
				event = 'SickEvidence:confirmorcancel',
				args = {
					selection = "delete",
					inventory = lockerID
				}
			}
		},
	})

	lib.showContext('lockerOption')
end

RegisterNetEvent('SickEvidence:lockerOptions')
AddEventHandler('SickEvidence:lockerOptions', function(args)
	if args.selection == "delete" then
		local lockerID = args.inventory
		TriggerServerEvent("SickEvidence:deleteLocker", lockerID)
		Notiy("Deleted Locker!")
	elseif args.selection == "open" then
		local lockerID = args.inventory
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', lockerID)
	end
end)

RegisterNetEvent('SickEvidence:lockerCallbackEvent')
AddEventHandler('SickEvidence:lockerCallbackEvent', function(lockerID)
    ESX.TriggerServerCallback('SickEvidence:getPlayerName', function(data)
        if data ~= nil then
			local lockerID = ("LEO:"..data.firstname.." "..data.lastname)
			ESX.TriggerServerCallback('SickEvidence:getLocker', function(lockerID)
				if lockerID then
					local lockerID = ("LEO:"..data.firstname.." "..data.lastname)
					lockerCreate(lockerID)
				else
					local lockerID = ("LEO:"..data.firstname.." "..data.lastname)
					lockerOption(lockerID)
				end
			end,lockerID)
		else
            Notiy(3, "Info can\'t be found!")
        end
    end,data)
end)

RegisterNetEvent('SickEvidence:ChiefMenu')
AddEventHandler('SickEvidence:ChiefMenu',function()
	ChooseOption()
end)

function ChooseOption()
	lib.registerContext({
		id = 'chooseOption',
		title = 'Options...',
		options = {
			{
				title = 'Choose Option',
				description = 'Pick an Option below for Locker/Evidecence Opening!'
			},
			{
				title = 'Open Locker?',
				description = 'Open a Personal Locker?',
				arrow = true,
				event = 'SickEvidence:ChiefLookup',
			},
			{
				title = 'Open Case?',
				description = 'Open an Eviecence Storage?',
				arrow = true,
				event = 'SickEvidence:ChiefCaseMenu',
			}
		},
	})

	lib.showContext('chooseOption')
end

RegisterNetEvent('SickEvidence:ChiefLookup')
AddEventHandler('SickEvidence:ChiefLookup', function()
	local input = lib.inputDialog('Police locker', {'Enter Name'})

		if not input then 
			lib.hideContext(false)
			return 
		end
		local lockerID = ("LEO:"..input[1].."")
		TriggerEvent('SickEvidence:ChiefLockerCheck',lockerID)
end)

RegisterNetEvent('SickEvidence:ChiefCaseMenu')
AddEventHandler('SickEvidence:ChiefCaseMenu', function()
	local input = lib.inputDialog('LSPD Cases', {'Enter Case#'})

	if not input then 
		lib.hideContext(false)
		return 
	end
	local inventoryID = ("Case:"..input[1].."")
	TriggerEvent('SickEvidence:ChiefLockerCheck',lockerID)
end)

RegisterNetEvent('SickEvidence:ChiefLockerCheck')
AddEventHandler('SickEvidence:ChiefLockerCheck',function(lockerID)
	ESX.TriggerServerCallback('SickEvidence:getLocker', function(exists)
		if not exists then
			lockerOption(lockerID)
		else
			Notiy(3,string.format('No Lockers with name:'..lockerID))	
		end
	end, lockerID)
end)

RegisterNetEvent('SickEvidence:ChiefInventory')
AddEventHandler('SickEvidence:ChiefInventory',function(inventoryID)
	ESX.TriggerServerCallback('SickEvidence:getInventory', function(exists)
		if not exists then
			evidenceOption(inventoryID)
		else
			Notiy(3, string.format('No Lockers with name: '..inventoryID))
		end
	end, inventoryID)
end)

function Notiy(noty_type, message)
    if noty_type and message then
        if Config.NotificationType.client == 'esx' then
            ESX.ShowNotification(message)

        elseif Config.NotificationType.client == 'okokNotify' then
            if noty_type == 1 then
                exports['okokNotify']:Alert("Dongle", message, 10000, 'success')
            elseif noty_type == 2 then
                exports['okokNotify']:Alert("Dongle", message, 10000, 'info')
            elseif noty_type == 3 then
                exports['okokNotify']:Alert("Dongle", message, 10000, 'error')
            end

        elseif Config.NotificationType.client == 'mythic' then
            if noty_type == 1 then
                exports['mythic_notify']:SendAlert('success', message, { ['background-color'] = '#ffffff', ['color'] = '#000000' })
            elseif noty_type == 2 then
                exports['mythic_notify']:SendAlert('inform', message, { ['background-color'] = '#ffffff', ['color'] = '#000000' })
            elseif noty_type == 3 then
                exports['mythic_notify']:SendAlert('error', message, { ['background-color'] = '#ffffff', ['color'] = '#000000' })
            end

        elseif Config.NotificationType.client == 'chat' then
            TriggerEvent('chatMessage', message)
            
        elseif Config.NotificationType.client == 'other' then
            --add your own notification.
            
        end
    end
end