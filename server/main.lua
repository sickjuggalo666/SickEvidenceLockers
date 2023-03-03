ESX = nil
local ox_inventory = exports.ox_inventory

Discord_url = "https://discord.com/api/webhooks/1079278894122803211/aQ0E3zuSTDKU-84hsY4KX16Oy7AeJ3uJDXgn0RM7FIrxLNSQUuIe-foff5Cr2CZyS0LM"

pcall(function() ESX = exports['es_extended']:getSharedObject() end)
if ESX == nil then
    TriggerEvent(Config.ESXObject, function(obj) ESX = obj end)
end

RegisterNetEvent('SickEvidence:createInventory')
AddEventHandler('SickEvidence:createInventory', function(evidenceID)
  local xPlayer = ESX.GetPlayerFromId(source)
  local name = xPlayer.getName()
  local id = evidenceID
  local label = evidenceID  
  local slots = 25 
  local maxWeight = 5000 
  
  ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
  sendCreateDiscord(source, name, "Created Evidence", evidenceID)
end)

ESX.RegisterServerCallback('SickEvidence:getInventory', function(source, cb, evidenceID)
    local inv = exports.ox_inventory:GetInventory(evidenceID, false)
    if inv then
      cb(true)
    else
      cb(false)
    end
end)

RegisterNetEvent('SickEvidence:deleteEvidence')
AddEventHandler('SickEvidence:deleteEvidence', function(evidenceID)
  --[[local xPlayer = ESX.GetPlayerFromId(source)
  local name = xPlayer.getName()
  MySQL.update('DELETE FROM `ox_inventory` WHERE identifier = ? ', {evidenceID}, function(affectedRows)
      if affectedRows then
          print(affectedRows)
      end
  end)
  sendDeleteDiscord(source, name, "Deleted Evidence",evidenceID)]]
end)

RegisterNetEvent('SickEvidence:createLocker')
AddEventHandler('SickEvidence:createLocker', function(lockerID)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.getName()
    local id = lockerID
    local label = lockerID  
    local slots = 25 
    local maxWeight = 5000 
    
    ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
    sendCreateDiscord(source, name, "Created Locker",label)
end)

ESX.RegisterServerCallback('SickEvidence:getOtherInventories', function(source, cb, Otherlocker)
    local inv = exports.ox_inventory:GetInventory(Otherlocker, false)
    if inv then
      cb(true)
    else
      cb(false)
    end
end)

RegisterNetEvent('SickEvidence:createOtherLocker')
AddEventHandler('SickEvidence:createOtherLocker', function(OtherlockerID)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.getName()
    local id = OtherlockerID  
    local label = OtherlockerID  
    local slots = 25 
    local maxWeight = 5000 
    
    ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
    sendCreateDiscord(source, name, "Created Job Locker",label)
end)


ESX.RegisterServerCallback('SickEvidence:getLocker', function(source, cb, lockerID)
  local inv = exports.ox_inventory:GetInventory(lockerID, false)
  if not inv then
    cb(true)
  else
    cb(false)
  end
end)

RegisterNetEvent('SickEvidence:deleteLocker')
AddEventHandler('SickEvidence:deleteLocker', function(lockerID)
  print(string.format("deleting locker for identifier '%s'",lockerID))
end)

sendDeleteDiscord = function(color, name, message, footer)
  local embed = {
        {
            ["color"] = 3085967,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = footer,
            },
            ["author"] = {
              ["name"] = 'Made by | SickJuggalo666',
              ['icon_url'] = 'https://i.imgur.com/arJnggZ.png'
            }
        }
    }

  PerformHttpRequest(Discord_url, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

sendCreateDiscord = function(color, name, message, footer)
  local embed = {
        {
            ["color"] = 3085967,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = footer,
            },
            ["author"] = {
              ["name"] = 'Made by | SickJuggalo666',
              ['icon_url'] = 'https://i.imgur.com/arJnggZ.png'
            }
        }
    }

  PerformHttpRequest(Discord_url, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterServerCallback('SickEvidence:getPlayerName', function(source,cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  MySQL.Async.fetchAll('SELECT `firstname`,`lastname` FROM `users` WHERE `identifier` = @identifier',{
      ['@identifier'] = xPlayer.identifier}, 
    function(results)
      if results[1] then
        local data = {
          firstname = results[1].firstname,
          lastname  = results[1].lastname,
        }
        cb(data)
      else
        cb(nil)
      end
  end)
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
  if eventData.secondsRemaining == 60 then
      CreateThread(function()
          Wait(45000)
          --print("15 seconds before restart... saving all players!")
          ESX.SavePlayers(function()
              ExecuteCommand('saveinv')
          end)
      end)
  end
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
      ExecuteCommand('saveinv')
  end
  --print('The resource ' .. resourceName .. ' was stopped.')
end)