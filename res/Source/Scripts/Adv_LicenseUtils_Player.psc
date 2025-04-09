Scriptname Adv_LicenseUtils_Player extends ReferenceAlias  

event OnPlayerLoadGame()
    (GetOwningQuest() as Adv_LicenseUtils).Maintenance()
endEvent

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    (GetOwningQuest() as Adv_LicenseUtils).UpdateStatus()
endEvent