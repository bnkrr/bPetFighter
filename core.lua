SLASH_BPF_RELOAD1 = "/rl"
SlashCmdList.BPF_RELOAD = function() ReloadUI() end

local addon, ns = ...
--local rotations = ns.rotations
--local speciesid = ns.speciesid
local unlocked = false

local changeTeam = function(team)
    for i=1,3 do
        C_PetJournal.SetPetLoadOutInfo(i, team[i])
    end
end

local team_zandalar = {
    "BattlePet-0-000002045475",
    "BattlePet-0-00000320E206",
    "BattlePet-0-00000320E209",
}

local team_crab = {
    "BattlePet-0-000001C8F08A",
    "BattlePet-0-000001C8F04B",
    "BattlePet-0-000001C8F093",
}


function getActivePetSpecies()
    local petIndex = C_PetBattles.GetActivePet(1)
    return C_PetBattles.GetPetSpeciesID(1, petIndex)
end

function getRotations(sid)  -- sid: speciesid
    local species = ns.speciesid[sid] or 'default'
    return ns.rotations[species]
end

function changeCheck()
    local petIndex = C_PetBattles.GetActivePet(1)
    local petStrategy = ns.strategy[petIndex]
    if petStrategy and petStrategy.change then
        return not petStrategy:change()     -- return unchanged
    else
        return true
    end
end

function oneTurnCheck()
    local petIndex = C_PetBattles.GetActivePet(1)
    local petStrategy = ns.strategy[petIndex]
    if petStrategy and petStrategy.oneTurn then
        petStrategy:oneTurn()
    end
end

function oneTurn()
    if C_PetBattles.IsInBattle() then
        local unchanged = changeCheck()     -- check if need change pet.
        --print(unchanged)
        if unchanged then
            local petIndex = C_PetBattles.GetActivePet(1)
            local sid = C_PetBattles.GetPetSpeciesID(1, petIndex)
            local rotations = getRotations(sid)
            for i, ability in ipairs(rotations) do
                if ability:flag(petIndex) then
                    if ability.id then
                        C_PetBattles.UseAbility(ability.id)
                        oneTurnCheck()          -- update some states every turn
                        break
                    end
                end
            end
        else                                -- change pet
            local petIndex = C_PetBattles.GetActivePet(1)
            if petIndex <  C_PetBattles.GetNumPets(1) then
                C_PetBattles.ChangePet(petIndex+1)
            else
                C_PetBattles.ForfeitGame()   -- forfeit the game
            end
        end
    end
end

function initStrategy()
    for i, petStrategy in ipairs(ns.strategy) do
        if petStrategy.init then
            petStrategy:init()
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage("bPetFighter: INIT STRATEGY!", 255, 255, 255)
end

function checkDead()
    --[[if unlocked then
        DEFAULT_CHAT_FRAME:AddMessage("bPetFighter: REVIVE!", 255, 255, 255)
        CastSpellByID(125439)  -- always check
    end
    return nil]]
    
    for petIndex = 1, 3 do
        local guid = team_zandalar[petIndex]
        local health = C_PetJournal.GetPetStats(guid)
        --print (health)
        if health > 0 then
            changeTeam(team_zandalar)
            return nil
        end
    end
    changeTeam(team_crab)
end

function handlerPetCombat(event)
    oneTurn()
end

function handlerPetCombatBegin(event)
    initStrategy()
end

function handlerPetCombatOver(event)
    checkDead()
end
--event handler
local frame = CreateFrame("Frame")
frame.flag = false

function frame:onEvent(event, ...)
    if event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" then
        handlerPetCombat(...)
    elseif event == "PET_BATTLE_OPENING_START" then
        handlerPetCombatBegin(...)
    elseif event == "PET_BATTLE_OVER" then
        handlerPetCombatOver(...)
    end
end

function frame:toggleEvent()
    unlocked = not unlocked
    self.flag = not self.flag
    if self.flag then
        self:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
        oneTurn()                                                        --- do first time
        DEFAULT_CHAT_FRAME:AddMessage("bPetFighter: AUTOFIGHTER: ON", 255, 255, 255)
    else
        self:UnregisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
        DEFAULT_CHAT_FRAME:AddMessage("bPetFighter: AUTOFIGHTER: OFF", 255, 255, 255)
    end
end

frame:RegisterEvent("PET_BATTLE_OPENING_START")
frame:RegisterEvent("PET_BATTLE_OVER")
frame:SetScript("OnEvent", frame.onEvent)


SLASH_BPF_ONETURN1 = "/bpf"
SlashCmdList.BPF_ONETURN = function()
    oneTurn()
    --[[if true then
        oneTurn()
    elseif unlocked then
        TargetUnit("超能浣熊")
        if UnitCanPetBattle("player","target") then
            InteractUnit("target")
        end
    end
    ]]
end



--SLASH_BPF_ONETURNPROTECTED1 = "/bpfp"
--SlashCmdList.BPF_ONETURNPROTECTED = function() oneTurnProtected() end

SLASH_BPF_TOGGLE1 = "/bpft"
SlashCmdList.BPF_TOGGLE = function() frame:toggleEvent() end

local runmacro = function()
    if not C_PetBattles.IsInBattle() then
        if not select(2,GetSpellCooldown(125439)) then  -- cd
            RunMacro("tarr")
            checkDead()
        else
            checkDead()
            RunMacro("tar00")
        end
    end
end

local ticker
local startTicker = function()
    ticker = C_Timer.NewTicker(0.9, runmacro)
end

local cancelTicker = function()
    ticker:Cancel()
end

SLASH_BPF_MACRO1 = "/bpfms"
SlashCmdList.BPF_MACRO = function() startTicker() end
SLASH_BPF_MACRO_CANCEL1 = "/bpfmc"
SlashCmdList.BPF_MACRO_CANCEL = function() cancelTicker() end

