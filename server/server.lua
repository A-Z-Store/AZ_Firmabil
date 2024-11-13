ESX = nil

ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    ESX.RegisterServerCallback('nightclub:getDemoVehicles', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        
        if xPlayer.job.name ~= Config.RequiredJob then
            cb({})
            return
        end
        
        cb(Config.DemoVehicles)
    end)
end)

RegisterCommand('spawnFirmaBil', function(source)
    local xPlayer = source
    local model = Config.FirmaBilModel
    
    
    TriggerClientEvent('nightclub:spawnFirmaBil', xPlayer, model)
end)

ESX.RegisterServerCallback('nightclub:getCompanyVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name ~= Config.RequiredJob then
        cb({})
        return
    end
    
   -- Ændre ui
    cb({
        Config.CompanyVehicles
    })
end)
