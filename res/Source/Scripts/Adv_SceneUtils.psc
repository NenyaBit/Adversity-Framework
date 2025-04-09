Scriptname Adv_SceneUtils extends Quest conditional

int Property Timer = 30 Auto Hidden
int Property ExpectedProgress = 1000 Auto Hidden
GlobalVariable property SceneTimeout auto

Function Begin(ReferenceAlias akActorAlias, ObjectReference akTarget = none) global
    ObjectReference currActor = akActorAlias.GetRef()

    if !akTarget
        akTarget = Game.GetPlayer()
    endIf

    ResetTimer()

    Adv_SceneUtils TimeoutQuest = Quest.GetQuest("Adv_SceneUtils") as Adv_SceneUtils

    StorageUtil.SetFormValue(TimeoutQuest, "CurrActor", currActor)
    StorageUtil.SetFormValue(TimeoutQuest, "CurrTarget", akTarget)
       
    TimeoutQuest.RegisterForSingleUpdate(TimeoutQuest.Timer)
EndFunction

Function Cancel() global
    ResetTimer()
EndFunction

Function ResetTimer() global
    Adv_SceneUtils TimeoutQuest = Quest.GetQuest("Adv_SceneUtils") as Adv_SceneUtils

    TimeoutQuest.SceneTimeout.SetValue(0)
    TimeoutQuest.UnregisterForUpdate()
EndFunction

Event OnUpdate()     
    Actor currActor = StorageUtil.GetFormValue(self, "CurrActor") as Actor
    ObjectReference currTarget = StorageUtil.GetFormValue(self, "CurrTarget") as ObjectReference

    if currActor && currTarget
        currActor.MoveTo(currTarget)
    endIf
    
    SceneTimeout.SetValue(1)
EndEvent

function WaitForScene(Actor akTarget, float afDelay = 1.0) global
    while akTarget.GetCurrentScene()
        Utility.Wait(afDelay)
    endWhile
endFunction

function FillAliases(ReferenceAlias[] akAliases, Actor[] akActors) global
    int i = 0
    while i < akAliases.length
        if i < akActors.length && akActors[i]
            akAliases[i].ForceRefTo(akActors[i])
        else
            akAliases[i].Clear()
        endIf
        i += 1
    endWhile
endFunction

function ClearAliases(ReferenceAlias[] akAliases) global
    int i = 0
    while i < akAliases.length
        akAliases[i].Clear()
        i += 1
    endWhile
endFunction 

function Blackfade(bool abEnable = true) global
    if abEnable
        Game.FadeOutGame(false, true, 60.0, 1.0)
    else
        Game.FadeOutGame(false, true, 0.2, 3.0)
    endIf
endFunction
