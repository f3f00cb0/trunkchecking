-- Function to calculate distance between two vectors
function GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

-- Function to get the closest vehicle to a player
function GetClosestVehicle(player)
    local playerPed = GetPlayerPed(player)
    local playerCoords = GetEntityCoords(playerPed)
    -- local vehicles = GetGamePool('CVehicle')
    -- local closestVehicle = nil
    -- local closestDistance = -1

    -- for _, vehicle in ipairs(vehicles) do
    --     local vehicleCoords = GetEntityCoords(vehicle)
    --     local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
        
    --     if closestVehicle == nil or distance < closestDistance then
    --         closestVehicle = vehicle
    --         closestDistance = distance
    --     end
    -- end

    -- return closestVehicle, closestDistance
end

-- Example usage
RegisterServerEvent('getClosestVehicle')
AddEventHandler('getClosestVehicle', function()
    print("Getting closest vehicle")
    local player = source
    local closestVehicle, distance = GetClosestVehicle(player)
    
    if closestVehicle ~= nil then
        -- Trigger client event to handle closest vehicle
        TriggerClientEvent('closestVehicleFound', player, closestVehicle, distance)
    end
end)
