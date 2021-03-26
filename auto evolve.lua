-- loglizzy#3431 (skids gonna paste it soon lol)

local repl = game:GetService('ReplicatedStorage')
local players = game:GetService('Players')

local player = players.LocalPlayer

local data = player.PlayerData_Client
local pets = data.Monsters

local evolve = repl.Remotes.Functions.UpgradeMonsterFunction
local monsters = require(repl.SharedModules.Game.Lib.Items.Monsters)

local function check(v)
    if not v:FindFirstChild('MonsterId') then
        return
    end
end

local function getPets()
    local tbl = {}
    for i,v in pairs(pets:GetChildren()) do
        check(v)
        
        local id = v.MonsterId.Value
        local recs = tbl[id..' Tier?>LP:./LOP:{P{: '..v.Tier.Value]
        
        if recs then
            table.insert(recs, {v})
        else
            tbl[id..' Tier?>LP:./LOP:{P{: '..v.Tier.Value] = {}
            table.insert(tbl[id..' Tier?>LP:./LOP:{P{: '..v.Tier.Value], v)
        end
    end
    return tbl
end

local function evolvePets()
    local tbl = getPets()
    
    for i,v in pairs(tbl) do
        local sts
        local amt
        local args = i:split(' Tier?>LP:./LOP:{P{: ')
        
        local id = args[1]
        local tier = tonumber(args[2])
        
        for i,v in pairs(monsters) do
            if v.Id == id then
                sts = v
                amt = v.MergesPerTier[tier]
                break
            end
        end
        
        if sts and amt then
            if #v >= amt then
                evolve:InvokeServer(v[#v])
                print('Evolved:', id)
            end
        end
    end
end

while wait(.2) do pcall(evolvePets) end
