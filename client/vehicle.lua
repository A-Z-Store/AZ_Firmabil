local ox_lib = exports.ox_lib
local isInVehicleSpawnZone = false
local EnteredCompanyKey = nil
local ESX = nil
local ox_target = exports.ox_target


Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
end)


Citizen.CreateThread(function()
    local vehicleSpawnZone = BoxZone:Create(
        Config.VehicleSpawnZone.center,
        Config.VehicleSpawnZone.length,
        Config.VehicleSpawnZone.width,
        {
            name = Config.VehicleSpawnZone.name,
            heading = Config.VehicleSpawnZone.heading,
            debugPoly = Config.VehicleSpawnZone.debugPoly
        }
    )

    vehicleSpawnZone:onPlayerInOut(function(isPointInside)
        isInVehicleSpawnZone = isPointInside
        SetupVehicleSpawnRadial()
    end)
end)


SetupVehicleSpawnRadial = function()
    if not isInVehicleSpawnZone then
        lib.removeRadialItem('vehicle_spawn')
        return
    end

    lib.addRadialItem({
        id = "vehicle_spawn",
        icon = "fa-solid fa-car",
        label = "Firma Bil Menu",
        menu = 'vehicle_spawn_menu'
    })

    local radialItems = {
        {
            id = "spawn_company_car",
            icon = "fa-solid fa-car",
            label = "Spawn Firma Bil",
            onSelect = function()
                HandleCompanyCar()
            end
        },
        {
            id = "remove_company_car",
            icon = "fas fa-trash-alt",
            label = "Fjern Firma Bil",
            onSelect = function()
                RemoveCompanyCarByPlate()
            end
        },
    }

    lib.registerRadial({
        id = 'vehicle_spawn_menu',
        items = radialItems
    })
end


HandleCompanyCar = function()
    if not isInVehicleSpawnZone then
        return lib.notify({
            title = 'Fejl',
            description = "Du er ikke i bil spawn zonen!",
            type = 'error'
        })
    end

    local spawnPoint = Config.VehicleSpawnZone.center
    if not ESX.Game.IsSpawnPointClear(spawnPoint, 5.0) then
        return lib.notify({
            title = 'Fejl',
            description = "Der er ikke plads til at spawne en bil her.",
            type = 'error'
        })
    end

    if not hasRequiredJob() then
        return lib.notify({
            title = 'Fejl',
            description = "Du skal være ansat i Et firma for at spawne firma biler!",
            type = 'error'
        })
    end

    ESX.TriggerServerCallback('nightclub:getCompanyVehicles', function(vehicles)
        if #vehicles == 0 then
            return lib.notify({
                title = 'Fejl',
                description = "Der er ingen firma biler tilgængelige.",
                type = 'error'
            })
        end

        local elements = {}
        for i = 1, #vehicles do
            table.insert(elements, {
                label = vehicles[i].label,
                value = vehicles[i].model
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawn', {
            title = 'Vælg Firma Bil',
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()

            ESX.Game.SpawnVehicle(data.current.value, spawnPoint, Config.VehicleSpawnZone.heading, function(vehicle)
                SetVehicleNumberPlateText(vehicle, "FIRMA" .. GetPlayerServerId(PlayerId()))
                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                exports["ox_fuel"]:SetFuel(vehicle, 100)
                
                lib.notify({
                    title = 'Succes',
                    description = "Firma bilen er nu spawnet!",
                    type = 'success'
                })
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end




function hasRequiredJob()
    local playerData = ESX.GetPlayerData()
    return playerData.job and playerData.job.name == Config.RequiredJob
end


function RemoveCompanyCar(vehicle)
    if DoesEntityExist(vehicle) then
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
            Wait(1500)
        end
        ESX.Game.DeleteVehicle(vehicle)
        lib.notify({
            title = 'Succes',
            description = "Firma bilen er blevet fjernet!",
            type = 'success'
        })
    else
        lib.notify({
            title = 'Fejl',
            description = "Kunne ikke finde køretøjet.",
            type = 'error'
        })
    end
end


function IsCompanyCar(vehicle)
    local model = GetEntityModel(vehicle)
    for _, companyVehicle in ipairs(Config.CompanyVehicles) do
        if model == GetHashKey(companyVehicle.model) then
            return true
        end
    end
    return false
end




function RemoveCompanyCarByPlate()
    if not hasRequiredJob() then
        return lib.notify({
            title = 'Fejl',
            description = "Du har ikke tilladelse til at fjerne firma biler!",
            type = 'error'
        })
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
    local companyVehicle = nil

    for i = 1, #vehicles do
        if IsCompanyCar(vehicles[i]) then
            companyVehicle = vehicles[i]
            break
        end
    end

    if companyVehicle then
        RemoveCompanyCar(companyVehicle)
    else
        lib.notify({
            title = 'Fejl',
            description = "Ingen firma bil i nærheden.",
            type = 'error'
        })
    end
end
