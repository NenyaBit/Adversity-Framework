Scriptname Adv_OutfitManager_PlayerAlias extends ReferenceAlias  

event OnPlayerLoadGame()
    (GetOwningQuest() as Adv_OutfitManager).ValidateAll()
endEvent

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    (GetOwningQuest() as Adv_OutfitManager).ValidateAll()
endEvent

event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    Utility.Wait(0.1)
    UnregisterForUpdate()
    RegisterForSingleUpdate(1.0)
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    UnregisterForUpdate()
    RegisterForSingleUpdate(1.0)
endEvent

event OnUpdate()
    Utility.Wait(0.1)
    (GetOwningQuest() as Adv_OutfitManager).ValidateAll()
endEvent