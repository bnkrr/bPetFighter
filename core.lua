SLASH_BPF_RELOAD1 = "/rl"
SlashCmdList.BPF_RELOAD = function() ReloadUI() end

local addon, ns = ...
local rotations = ns.rotations
local speciesid = ns.speciesid

function getRotations()
    return rotaions["crab"]  --default
end

function oneTurn()
    if C_PetBattles.IsInBattle() then
        rotations = getRotations()
        for i, ability in ipairs(crab) do
            if ability.flag() then
                C_PetBattles.UseAbility(ability.id)
            end
        end
    end
end

function handlerPetCombat(event)
    oneTurn()
end

--event handler
local frame = CreateFrame("Frame")
frame.flag = false

function frame:onEvent(event, ...)
    if event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" then
        handlerPetCombat(...)
    end
end

function frame:toggleEvent()
    self:UnregisterAllEvents()
    if self.flag then
        self:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
        self:SetScript("OnEvent", frame.onEvent)
        oneTurn() ---
        DEFAULT_CHAT_FRAME:AddMessage("AUTOFIGHTER: ON", 255, 255, 255)
    else
        DEFAULT_CHAT_FRAME:AddMessage("AUTOFIGHTER: OFF", 255, 255, 255)
    end
    self.flag = not self.flag
end




SLASH_BPF_ONETURN1 = "/bpf"
SlashCmdList.BPF_ONETURN = function() oneTurn() end

--SLASH_BPF_ONETURNPROTECTED1 = "/bpfp"
--SlashCmdList.BPF_ONETURNPROTECTED = function() oneTurnProtected() end

SLASH_BPF_TOGGLE1 = "/bpft"
SlashCmdList.BPF_TOGGLE = function() frame:toggleEvent() end

