Scriptname Adv_SleepUtils_PlayerAlias extends ReferenceAlias  

event OnPlayerLoadGame()
    Adv_Util.LogInfo("Sleep - OnPlayerLoadGame")
    (GetOwningQuest() as Adv_SleepUtils).Maintenance()
endEvent