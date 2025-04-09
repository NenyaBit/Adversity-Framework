Scriptname Adv_MovementUtils extends Quest  

Actor property PlayerRef auto
Faction property MovementFaction auto

Adv_MovementUtils function Get() global
    return Quest.GetQuest("Adv_MovementUtils") as Adv_MovementUtils
endFunction

function SetCrawling(bool abEnable = true, Actor akTarget = none)
    SetMovementRank(0, abEnable, akTarget)
endFunction

function SetKneeling(bool abEnable = true, bool abHandleControls = true, Actor akTarget = none)
    if abHandleControls
        Game.SetPlayerAIDriven(abEnable)
    endIf
    
    SetMovementRank(1, abEnable, akTarget)
endFunction

function SetMovementRank(int aiRank, bool abEnable, Actor akTarget)
    if !akTarget
        akTarget = PlayerRef
    endIf

    if abEnable
        PlayerRef.SetFactionRank(MovementFaction, aiRank)
    else
        PlayerRef.RemoveFromFaction(MovementFaction)
    endIf
endFunction