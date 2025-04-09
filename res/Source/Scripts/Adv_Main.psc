Scriptname Adv_Main extends Quest  

Adv_LicenseUtils property LicenseUtil auto
Adv_SleepUtils property SleepUtil auto
Adv_Sync property Sync auto

function Maintenance()
    Sync.Maintenance()
    LicenseUtil.Maintenance()
    SleepUtil.Maintenance()
endFunction

function OnLocationChange(Location akOldLocation, Location akNewLocation)
    LicenseUtil.UpdateStatus()
endFunction