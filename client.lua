--exports['qb-inventory']:OpenInventory()
local QBCore = exports['qb-core']:GetCoreObject()
-- Example usage
RegisterNetEvent('closestVehicleFound')
AddEventHandler('closestVehicleFound', function(vehicle, distance)
    print("Closest vehicle found at distance: " .. distance)
    -- Do something with the closest vehicle on the client-side
end)

-- Example command to trigger the closest vehicle search
RegisterCommand('findvehicle', function()
    local vehiclePool  = GetGamePool('CVehicle')
    for i = 1, #vehiclePool do -- loop through each vehicle (entity)
        --print("Vehicle found ", vehiclePool[i])
        if DoesEntityExist(vehiclePool[i]) then
            -- Check the trunk status
            local trunkOpen = GetVehicleDoorAngleRatio(vehiclePool[i], 5) > 0.1
            local pos = GetEntityCoords(vehiclePool[i], false)
            local trunkpos = GetWorldPositionOfEntityBone(vehiclePool[i], GetEntityBoneIndexByName(vehiclePool[i], "boot"))
            if trunkOpen then
                print("Vehicle position: ", pos)
                print("Trunk position: ", trunkpos)
                print("Vehicle's trunk is open!")
            else
                --DrawText3D(trunkpos.x, trunkpos.y, trunkpos.z + 1.0, "[E]", 0.4) -- Changed to a simpler text display
                Draw3DText2(trunkpos, "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEESs")
            end
        end
        if GetPedInVehicleSeat(vehiclePool[i], -1) == 0 then
            --print("Vehicle found ", vehiclePool[i])
        end
    end
    TriggerServerEvent('getClosestVehicle')
end)


Citizen.CreateThread(function()
    local trunkThreshold = 1.5 -- Ajustez ce seuil si nécessaire
    local isTrunkOpen = false

    while true do
        Citizen.Wait(1)

        local vehiclePool = GetGamePool('CVehicle')
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i = 1, #vehiclePool do
            if DoesEntityExist(vehiclePool[i]) then
                local trunkOpen = GetVehicleDoorAngleRatio(vehiclePool[i], 5) > 0.1
                local speed = GetEntitySpeed(vehiclePool[i])
                local isLocked = GetVehicleDoorLockStatus(vehiclePool[i]) ~= 1
                local pos = GetEntityCoords(vehiclePool[i], false)
                local trunkpos = GetWorldPositionOfEntityBone(vehiclePool[i], GetEntityBoneIndexByName(vehiclePool[i], "boot"))
                vehicle = QBCore.Functions.GetClosestVehicle()
                CurrentVehicle = QBCore.Functions.GetPlate(vehicle)

                -- if trunkOpen then
                --     if isTrunkOpen then
                --         Draw3DText2(trunkpos, "Appuyez sur [E] pour fermer le coffre")
                --         if IsControlJustReleased(0, 38) then
                --             isProcessingTrunk = true
                --             print("Fermeture du coffre")
                --             CloseTrunk(CurrentVehicle)
                --             TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
                --             isTrunkOpen = false
                --             isProcessingTrunk = false
                --             CurrentVehicle = nil
                --         end
                --     end
                -- elseif GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, trunkpos.x, trunkpos.y, trunkpos.z, true) < trunkThreshold and speed < 0.1 and not isLocked then
                --     if not isTrunkOpen then
                --         Draw3DText2(trunkpos, "Appuyez sur [E] pour ouvrir le coffre")
                --         if IsControlJustReleased(0, 38) then
                --             isProcessingTrunk = true
                --             print("Ouverture du coffre")
                --             OpensTrunk(CurrentVehicle)
                --             TriggerServerEvent('inventory:server:OpenInventory', 'trunk', CurrentVehicle, {maxweight = 1000, slots = 15})
                --             isTrunkOpen = true
                --             isProcessingTrunk = false
                --         end
                --     end
                -- end
                if not isTrunkOpen then
                    if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, trunkpos.x, trunkpos.y, trunkpos.z, true) < trunkThreshold and speed < 0.1 and not isLocked then
                        Draw3DText2(trunkpos, "Appuyez sur [E] pour ouvrir le coffre")
                        if IsControlJustReleased(0, 38) then
                            print("Ouverture du coffre")
                            OpensTrunk(CurrentVehicle)
                            TriggerServerEvent('inventory:server:OpenInventory', 'trunk', CurrentVehicle, {maxweight = 1000, slots = 15})
                            isTrunkOpen = true
                            isProcessingTrunk = false
                        end
                    end
                elseif trunkOpen then
                    if isTrunkOpen then
                        Draw3DText2(trunkpos, "Appuyez sur [E] pour fermer le coffre")
                        if IsControlJustReleased(0, 38) then
                            print("Fermeture du coffre")
                            CloseTrunk(CurrentVehicle)
                            TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
                            isTrunkOpen = false
                            isProcessingTrunk = false
                            CurrentVehicle = nil
                        end
                    end
                end                
            end
        end
    end
end)

function DrawText3D(x, y, z, text, scale)
    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(x, y, z)
    if onScreen then
        SetTextScale(scale, scale)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(sx, sy)
    end
end

function Draw3DText2(coords, str)
    --print("Drawing text1")
    local onScreen, worldX, worldY = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoord()
    local scale = 200 / (GetGameplayCamFov() * #(camCoords - coords))
    if onScreen then
        --print("Drawing text")
        SetTextScale(1.0, 0.9)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextProportional(1)
        SetTextOutline()
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandDisplayText(worldX, worldY)
    end
end

function GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

function OpensTrunk(vehicle)
    vehicle = QBCore.Functions.GetClosestVehicle()
    print("Opening trunk")
    print("Vehicle: ", vehicle)
    --LoadAnimDict('amb@prop_human_bum_bin@idle_b')
    --askPlayAnim(PlayerPedId(), 'amb@prop_human_bum_bin@idle_b', 'idle_d', 4.0, 4.0, -1, 50, 0, false, false, false)
    print("Vehicle model: ", GetEntityModel(vehicle))
    SetVehicleDoorOpen(vehicle, 5, false, false)
    -- if IsBackEngine(QBCore.Functions.GetEntityModel(vehicle)) then
    --     SetVehicleDoorOpen(vehicle, 4, false, false)
    -- else
    --     SetVehicleDoorOpen(vehicle, 5, false, false)
    -- end
end

function CloseTrunk(vehicle)
    vehicle = QBCore.Functions.GetClosestVehicle()
--     --local vehicle = QBCore.Functions.GetClosestVehicle()
--     --LoadAnimDict("amb@prop_human_bum_bin@idle_b")
--     --TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    SetVehicleDoorShut(vehicle, 5, false)
end

function IsBackEngine(vehModel)
    print("Checking if vehicle is back engine")
    return BackEngineVehicles[vehModel]
end

RegisterNUICallback("CloseInventory", function(_, cb)
    vehicle = QBCore.Functions.GetClosestVehicle()
    print("Vehicle found ", vehicle)
    CurrentVehicle = QBCore.Functions.GetPlate(vehicle)
    CloseTrunk()
    TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
    CurrentVehicle = nil
    
end)