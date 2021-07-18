local perlinNoise = require(script:GetCustomProperty('PerlinLIB'))
local blockTable = require(script:GetCustomProperty('BlockTable'))

local WorldGenerator = {}

local xStart = 0
local xEnd = 0
local yStart = 0
local yEnd = 0

local maxHeight = 32
local maxDown = -16

local caveScale = 0.08
local caveSpawnRate = -0.3
local entranceSpawnRate = -0.5

function WorldGenerator.Generate(xStartP, xEndP, yStartP, yEndP)

    xStart = xStartP
    xEnd = xEndP
    yStart = yStartP
    yEnd = yEndP

    for x = xStart - 1, xEnd + 1 do
        _G.Blocks[x] = {}
        for y = yStart - 1, yEnd + 1 do
            _G.Blocks[x][y] = {}
            if x < xStart or x > xEnd or y < yStart or y > yEnd then
                for z = maxDown - 1, maxHeight + 1 do
                    if not _G.Blocks[x][y][z] then
                        _G.Blocks[x][y][z] = {blockInfo = blockTable['Air'], isSpawned = true}
                    end
                end
            else
                local height = math.floor(perlinNoise:noise(x,y,0,0.1) * 10)


                for z = maxDown, height do
                    local shouldSpawn = (perlinNoise:noise((x + 999) / 2, (y + 999) / 4, z, caveScale) > caveSpawnRate) and (perlinNoise:noise((x + 999) / 4, (y + 999) / 2, z, caveScale) > caveSpawnRate) and  (perlinNoise:noise((x + 999) / 2, (y + 999) / 2, z / 4, caveScale) > caveSpawnRate)                
                    local shouldSpawnEntrance = (perlinNoise:noise((x + 999) / 2, (y + 999) / 4, z, caveScale) > entranceSpawnRate) and (perlinNoise:noise((x + 999) / 4, (y + 999) / 2, z, caveScale) > entranceSpawnRate) and  (perlinNoise:noise((x + 999) / 2, (y + 999) / 2, z / 4, caveScale) > entranceSpawnRate)

                    if z == height - 1 then
                        if shouldSpawnEntrance then
                            _G.Blocks[x][y][z] = {blockInfo = blockTable['Grass'], isSpawned = false}
                        else
                            _G.Blocks[x][y][z] = {blockInfo = blockTable['Air'], isSpawned = true}
                        end
                    elseif z >= height - 3 then 
                        if shouldSpawnEntrance then
                            _G.Blocks[x][y][z] = {blockInfo = blockTable['Dirt'], isSpawned = false}
                        else
                            _G.Blocks[x][y][z] = {blockInfo = blockTable['Air'], isSpawned = true}
                        end
                
                    elseif z == maxDown then
                        _G.Blocks[x][y][z] = {blockInfo = blockTable['Stone'], isSpawned = false}
                    else
                        if shouldSpawn then
                            _G.Blocks[x][y][z] = {blockInfo = blockTable['Stone'], isSpawned = false}
                        else
                            _G.Blocks[x][y][z] = {blockInfo = blockTable['Air'], isSpawned = true}
                        end
                    end
                end

                for z = height, maxHeight do
                    _G.Blocks[x][y][z] = {blockInfo = blockTable['Air'], isSpawned = true}
                end
            end
            if math.random(1,3) == 1 then
                Task.Wait()
            end
        end
        Task.Wait()
    end
    WorldGenerator.SpawnBlocks()
end



function WorldGenerator.isBlockSurrounded(x,y,z)
    if x == xStart or y == yStart or x == xEnd or y == yEnd or z == maxHeight or z == maxDown then
        return false
    end
    if _G.Blocks[x+1][y][z].blockInfo.template == nil then
        return false
    elseif _G.Blocks[x-1][y][z].blockInfo.template == nil then
        return false
    elseif _G.Blocks[x][y+1][z].blockInfo.template == nil then
        return false
    elseif _G.Blocks[x][y-1][z].blockInfo.template == nil then
        return false
    elseif _G.Blocks[x][y][z+1].blockInfo.template == nil then
        return false
    elseif _G.Blocks[x][y][z-1].blockInfo.template == nil then
        return false
    end
    return true
end

function WorldGenerator.SpawnSurroundingBlocks(x,y,z)
    if _G.Blocks[x+1][y][z].blockInfo.template ~= nil and not _G.Blocks[x+1][y][z].isSpawned then
        WorldGenerator.SpawnBlock(x+1,y,z,_G.Blocks[x+1][y][z].blockInfo.template)
    end
    if _G.Blocks[x-1][y][z].blockInfo.template ~= nil and not _G.Blocks[x-1][y][z].isSpawned then
        WorldGenerator.SpawnBlock(x-1,y,z,_G.Blocks[x-1][y][z].blockInfo.template)
    end
    if _G.Blocks[x][y+1][z].blockInfo.template ~= nil and not _G.Blocks[x][y+1][z].isSpawned then
        WorldGenerator.SpawnBlock(x,y+1,z,_G.Blocks[x][y+1][z].blockInfo.template)
    end
    if _G.Blocks[x][y-1][z].blockInfo.template ~= nil and not _G.Blocks[x][y-1][z].isSpawned then
        WorldGenerator.SpawnBlock(x,y-1,z,_G.Blocks[x][y-1][z].blockInfo.template)
    end
    if _G.Blocks[x][y][z+1].blockInfo.template ~= nil and not _G.Blocks[x][y][z+1].isSpawned then
        WorldGenerator.SpawnBlock(x,y,z+1,_G.Blocks[x][y][z+1].blockInfo.template)
    end
    if _G.Blocks[x][y][z-1].blockInfo.template ~= nil and not _G.Blocks[x][y][z-1].isSpawned then
        WorldGenerator.SpawnBlock(x,y,z-1,_G.Blocks[x][y][z-1].blockInfo.template)
    end
end


function WorldGenerator.SpawnBlocks()
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            for z = maxDown, maxHeight do
                if not WorldGenerator.isBlockSurrounded(x,y,z) then
                    if _G.Blocks[x][y][z].blockInfo.template ~= nil then
                        WorldGenerator.SpawnBlock(x,y,z,_G.Blocks[x][y][z].blockInfo.template)
                    end
                end
            end
        end
        Task.Wait()
    end
end

function WorldGenerator.SpawnBlock(x,y,z,block)
    local block = World.SpawnAsset(block, {position = Vector3.New(x,y,z) * 100})
    _G.Blocks[x][y][z].isSpawned = true
end

return WorldGenerator