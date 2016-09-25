SLASH_BPF_RELOAD1 = "/rl"
SlashCmdList.BPF_RELOAD = function() ReloadUI() end

local addon, ns = ...
--local rotations = ns.rotations
--local speciesid = ns.speciesid
local unlocked = false

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
        return not petStrategy.change()     -- return unchanged
    else
        return true
    end
end

function oneTurnCheck()
    local petIndex = C_PetBattles.GetActivePet(1)
    local petStrategy = ns.strategy[petIndex]
    if petStrategy and petStrategy.oneTurn then
        petStrategy.oneTurn()
    end
end

function oneTurn()
    if C_PetBattles.IsInBattle() then
        local unchanged = changeCheck()     -- check if need change pet.
        if unchanged then
            local petIndex = C_PetBattles.GetActivePet(1)
            local sid = C_PetBattles.GetPetSpeciesID(1, petIndex)
            local rotations = getRotations(sid)
            for i, ability in ipairs(rotations) do
                if ability.flag(petIndex) then
                    C_PetBattles.UseAbility(ability.id)
                    oneTurnCheck()          -- update some states every turn
                    break
                end
            end
        else                                -- change pet
            local petIndex = C_PetBattles.GetActivePet(1)
            C_PetBattles.ChangePet(petIndex+1)
        end
    end
end

function initStrategy()
    for i, petStrategy in ipairs(ns.strategy) do
        if petStrategy.init then
            petStrategy.init()
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage("bPetFighter: INIT STRATEGY!", 255, 255, 255)
end

function checkDead()
    for petIndex = 1, 3 do
        local guid = C_PetJournal.GetPetLoadOutInfo(petIndex)
        local health = C_PetJournal.GetPetStats(guid)
        if health < 1 then
            if unlocked then
                CastSpellByID(125439)  -- revive pets
            end
            DEFAULT_CHAT_FRAME:AddMessage("bPetFighter: REVIVE!", 255, 255, 255)
            break
        end
    end
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
SlashCmdList.BPF_ONETURN = function() oneTurn() end

--SLASH_BPF_ONETURNPROTECTED1 = "/bpfp"
--SlashCmdList.BPF_ONETURNPROTECTED = function() oneTurnProtected() end

SLASH_BPF_TOGGLE1 = "/bpft"
SlashCmdList.BPF_TOGGLE = function() frame:toggleEvent() end

