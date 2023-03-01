ESX = exports['es_extended']:getSharedObject()
local ox_inventory = exports.ox_inventory

Discord_url = ""

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