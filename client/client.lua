
local ox_lib = exports.ox_lib
local barZone, musicZone, carSpawnZone
local isInfirmabil = false

Citizen.CreateThread(function()
    carSpawnZone = BoxZone:Create(
        Config.CarSpawnZone.center,
        Config.CarSpawnZone.length,
        Config.CarSpawnZone.width,
        {
            name = Config.CarSpawnZone.name,
            heading = Config.CarSpawnZone.heading,
            debugPoly = Config.CarSpawnZone.debugPoly
        }
    )

    
    local firmabilZone = BoxZone:Create(
        vector3(-1390.0, -590.0, 30.0), 
        50.0, 50.0, {
            name = "firmabil_area",
            heading = 0,
            debugPoly = false
        }
    )

    firmabilZone:onPlayerInOut(function(isPointInside)
        isInfirmabil = isPointInside
        SetupfirmabilRadial()
    end)


    carSpawnZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            exports.ox_lib:showTextUI('[F1] - Åbn firmabil Menu', {
                position = "top-center",
                icon = 'fas fa-car'
            })
        else
            exports.ox_lib:hideTextUI()
        end
    end)
end)

SetupfirmabilRadial = function()
    if not isInfirmabil then
        lib.removeRadialItem('firmabil_menu')
        return
    end

    lib.addRadialItem({
        id = "firmabil_menu",
        icon = "fa-solid fa-music",
        label = "firmabil Menu",
        menu = 'firmabil_submenu'
    })


        {
            id = "firmabil_car",
            icon = "fa-solid fa-car",
            label = "Spawn Firma Bil",
            onSelect = function()
                if carSpawnZone:isPointInside(GetEntityCoords(PlayerPedId())) then
                    spawnFirmaBil()
                else
                    lib.notify({
                        title = 'firmabil',
                        description = 'Du er ikke i bil spawn zonen!',
                        type = 'error'
                    })
                end
            end
        }
    

    lib.registerRadial({
        id = 'firmabil_submenu',
        items = radialItems
    })
end


RegisterKeyMapping('openfirmabilRadial', 'Åbn firmabil Menu', 'keyboard', 'F1')
RegisterCommand('openfirmabilRadial', function()
    if isInfirmabil then
        lib.showRadial('firmabil_menu')
    end
end, false)

function spawnFirmaBil()
    local model = Config.FirmaBilModel
    local playerPed = PlayerPedId()

    local vehicleModel = GetHashKey(model)
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Citizen.Wait(500)
    end

    local spawnPoint = Config.CarSpawnZone.center
    local vehicle = CreateVehicle(vehicleModel, spawnPoint.x, spawnPoint.y, spawnPoint.z, GetEntityHeading(playerPed), true, false)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

    lib.notify({
        title = 'firmabil',
        description = 'Firma bilen er nu spawnet!',
        type = 'success'
    })
end


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local distance = #(camCoords - vector3(x, y, z))
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


exports.ox_target:addGlobalVehicle(
	{
		icon = "fas fa-trash-alt",
		label = "Fjern køretøj",
		onSelect = function(data)
			ESX.Game.DeleteVehicle(data.entity)
		end,
		canInteract = function(entity)
			return EnteredCompany and EnteredCompanyKey and ESX.PlayerData.job.name == EnteredCompany
		end,
	},
end)
