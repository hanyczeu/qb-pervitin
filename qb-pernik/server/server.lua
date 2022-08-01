local QBCore = exports['qb-core']:GetCoreObject()

local itemcraft = 'markedbills'

RegisterServerEvent('qb-pervitinpicking:pickedUpPills', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	    if 	TriggerClientEvent("QBCore:Notify", src, "Picked up some Pills!!", "Success", 1000) then
		  Player.Functions.AddItem('pseudoefedrin', 1) ---- change this shit 
		  TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['pseudoefedrin'], "add")
	    end
end)

RegisterServerEvent('qb-pervitinpicking:processpervitin', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local pseudoefedrin = Player.Functions.GetItemByName("pseudoefedrin")
      local plastic_baggie = Player.Functions.GetItemByName("plastic_baggie")

    if pseudoefedrin ~= nil and plastic_baggie ~= nil then
        if Player.Functions.RemoveItem('pseudoefedrin', 3) and Player.Functions.RemoveItem('plastic_baggie', 1) then
            Player.Functions.AddItem('pervitin', 1)-----change this
            TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['pseudoefedrin'], "remove")
            TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['plastic_baggie'], "remove")
            TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['pervitin'], "add")
            TriggerClientEvent('QBCore:Notify', src, 'Pills Processed successfully', "success")  
        else
            TriggerClientEvent('QBCore:Notify', src, 'You don\'t have the right items', "error") 
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have the right items', "error") 
    end
end)

--selldrug ok

RegisterServerEvent('qb-pervitinpicking:selld', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Item = Player.Functions.GetItemByName('pervitin')
   
	if Item ~= nil and Item.amount >= 1 then
		local chance2 = math.random(1, 12)
		if chance2 == 1 or chance2 == 2 or chance2 == 9 or chance2 == 4 or chance2 == 10 or chance2 == 6 or chance2 == 7 or chance2 == 8 then
			Player.Functions.RemoveItem('pervitin', 1)----change this
			TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['pervitin'], "remove")
			Player.Functions.AddMoney("cash", Config.Pricesell, "sold-pawn-items")
			TriggerClientEvent('QBCore:Notify', src, 'you sold to the pusher', "success")  
		else
			Player.Functions.RemoveItem('pervitin', 1)----change this
			TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['pervitin'], "remove")
			Player.Functions.AddMoney("cash", Config.Pricesell-100, "sold-pawn-items")
			TriggerClientEvent('QBCore:Notify', src, 'you sold to the pusher', "success")
		end
else
	TriggerClientEvent('QBCore:Notify', src, 'You don\'t have the right items', "error") 
	
end
end)

function CancelProcessing(playerId)
	if playersProcessingPseudoefedrin[playerId] then
		ClearTimeout(playersProcessingPseudoefedrin[playerId])
		playersProcessingPseudoefedrin[playerId] = nil
	end
end

RegisterServerEvent('qb-pervitinpicking:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('QBCore_:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('qb-pervitinpicking:onPlayerDeath', function(data)
	local src = source
	CancelProcessing(src)
end)

QBCore.Functions.CreateCallback('poppy:process', function(source, cb)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	 
	if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then
		for k, v in pairs(Player.PlayerData.items) do
		    if Player.Playerdata.items[k] ~= nil then
				if Player.Playerdata.items[k].name == "pseudoefedrin" then
					cb(true)
			    else
					TriggerClientEvent("QBCore:Notify", src, "You do not have any Pills", "error", 10000)
					cb(false)
				end
	        end
		end	
	end
end)
