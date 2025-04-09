Scriptname Adv_Main_Player extends ReferenceAlias  

event OnPlayerLoadGame()
    (GetOwningQuest() as Adv_Main).Maintenance()
endEvent

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    (GetOwningQuest() as Adv_Main).OnLocationChange(akOldLocation, akNewLocation)
endEvent