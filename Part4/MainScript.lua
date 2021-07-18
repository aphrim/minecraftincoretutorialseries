local WorldGenerator = require(script:GetCustomProperty('WorldGenerator'))

_G.Blocks = {}


for x = 0, 5 do
    for y = 0, 5 do
        WorldGenerator.Generate(x * 10,x * 10 + 10,y * 10,y * 10 + 10)
    end
end
