-- loglizzy#3431 (skids gonna paste it soon lol)

local repl = game:GetService('ReplicatedStorage')
local players = game:GetService('Players')

local player = players.LocalPlayer

local data = player.PlayerData_Client
local pets = data.Monsters
local equipped = data.EquippedMonsters

local monsters = require(repl.SharedModules.Game.Lib.Items.Monsters)
local equip = repl.Remotes.Events.MoveMonsterEvent

local function getTotal(sts)
    local a1 = sts.BaseHealth + sts.BaseDamage
    return a1 + sts.BaseCollect*math.min(sts.BaseHealth - sts.BaseDamage, 1)
end

local function checkAval(sts, name)
    local a1 = sts.BaseDamage and sts.BaseHealth and sts.BaseCollect
    
    for i,v in pairs(equipped:GetChildren()) do
        if v:IsA('StringValue') and v.Value == name then
            return false
        end
    end
    return a1
end

local function isInLimit()
    local a1 = 3
    
    for i,v in pairs(equipped:GetChildren()) do
        if v.Value == '' then a1 = a1 - 1 end
    end
    return a1
end

local function getBest()
    local last
    local lname
    
    for i,v in pairs(pets:GetChildren()) do
        local sts
        local id = v.MonsterId.Value
        
        for i,v in pairs(monsters) do
            if v.Id == id then
                sts = v
                break
            end
        end
        
        if sts and checkAval(sts, v.Name) then
            if last then
                local total = getTotal(sts)
                if total > getTotal(last) then
                    last = sts
                    lname = v.Name
                end
            else
                last = sts
                lname = v.Name
            end
        end
    end
    
    return last, lname
end

local function getWorst()
    local last
    local lname
    
    for i,v in pairs(equipped:GetChildren()) do
        if v.Value ~= '' then
            local sts
            local in_f = pets:FindFirstChild(v.Value)
            local id = in_f.MonsterId.Value
            
            for i,v in pairs(monsters) do
                if v.Id == id then
                    sts = v
                    break
                end
            end
            
            if sts and checkAval(sts, v.Name) then
                if last then
                    local total = getTotal(sts)
                    if total < getTotal(last) then
                        last = sts
                        lname = v.Value
                    end
                else
                    last = sts
                    lname = v.Value
                end
            end
        end
    end
    
    return last, lname
end

local function equipBest()
    local best, bname = getBest()
    local worst, wname = getWorst()
    
    if isInLimit() == 3 then
        if getTotal(best) > getTotal(worst) then
            equip:FireServer(wname, nil, true)
            print('Unequipped to switch by a better one:', worst.Name)
        end
    else
        equip:FireServer(bname)
        print('Equipped:', best.Name)
    end
end

while wait(.2) do pcall(equipBest) end
