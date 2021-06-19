local BlockTable = require(script:GetCustomProperty('Blocks'))
local WorldGenerator = require(script:GetCustomProperty('WorldGenerator'))

local abilityObject = script.parent

function ConnectAbilityEvents_BreakBlock(ability)
	ability.executeEvent:Connect(OnExecute_BreakBlock)
						
end


function OnExecute_BreakBlock(ability)
	print("OnExecute " .. ability.name)
	local player = ability.owner
	local foward = (player:GetLookWorldRotation() * Vector3.New(300,0,0) + player:GetWorldPosition())
	local hit = World.Raycast(player:GetWorldPosition(), foward, {ignorePlayers = true})
	if hit then
		local hitObject = hit.other
		local blockPos = hitObject:GetWorldPosition() / 100
		local blockTableEntry = _G.Blocks[blockPos.x][blockPos.y][blockPos.z]
		_G.Blocks[blockPos.x][blockPos.y][blockPos.z] = {blockInfo = BlockTable['Air'], isSpawned = true}
		hitObject:Destroy()

		WorldGenerator.SpawnSurroundingBlocks(blockPos.x, blockPos.y, blockPos.z)
	end
	local targetData = ability:GetTargetData()
end



ConnectAbilityEvents_BreakBlock(abilityObject)

--------------------------------------------------------------------------------