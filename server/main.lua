ESX = exports['es_extended']:getSharedObject()
local ox_inventory = exports.ox_inventory

Discord_url = ""  --Server side for security!

RegisterNetEvent('SickEvidence:createInventory')
AddEventHandler('SickEvidence:createInventory', function(inventoryID)
  local xPlayer = ESX.GetPlayerFromId(source)
  local name = xPlayer.getName()
  local id = inventoryID
  local label = inventoryID  
  local slots = 25 
  local maxWeight = 5000 
  
  ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
  sendCreateDiscord(source, name, "Created Evidence", inventoryID)
end)

ESX.RegisterServerCallback('SickEvidence:getInventory', function(source, cb, inventoryID)
    local inv = exports.ox_inventory:GetInventory(inventoryID, false)
    if inv then
      cb(true)
    else
      cb(false)
    end
end)

RegisterNetEvent('SickEvidence:createLocker')
AddEventHandler('SickEvidence:createLocker', function(lockerID)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.getName()
    local id = lockerID
    local label = "Case :#" ..lockerID  
    local slots = 25 
    local weight = 5000 
    
    ox_inventory:RegisterStash(id, label, slots, weight,nil)
    sendCreateDiscord(source, name, "Created Locker",lockerID)
end)

ESX.RegisterServerCallback('SickEvidence:getInventory', function(source, cb, lockerID)
    local inv = exports.ox_inventory:GetInventory(lockerID, false)
    if inv then
      cb(true)
    else
      cb(false)
    end
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