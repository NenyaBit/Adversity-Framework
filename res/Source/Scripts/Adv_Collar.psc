Scriptname Adv_Collar extends Quest conditional

; refs
Actor property PlayerRef auto
Spell property ZapSpell auto

GlobalVariable property ViolationReason auto

; enums
int property VIOLATION_TYPE_SLOW = 0 auto hidden conditional
int property VIOLATION_TYPE_WRONG_DIRECTION = 1 auto hidden conditional
int property VIOLATION_TYPE_LOCATION = 2 auto hidden conditional
int property VIOLATION_TYPE_LEASH = 3 auto hidden conditional

int property COLLAR_MODE_LEASH = 0 autoreadonly hidden
int property COLLAR_MODE_LEAD = 1 autoreadonly hidden
int property COLLAR_MODE_LOCATION = 2 autoreadonly hidden

; user defined
int property HealthThresh = 10 auto hidden
int property HealthReduce = 25 auto hidden
int property MagickaReduce = 25 auto hidden
int property CheckInterval = 10 auto hidden

; runtime data
ObjectReference property TargetRef auto hidden
Scene ViolationScene
bool ZapAfter
int property CurrMode = -1 auto hidden
int ExpectedDist
int ExpectedRadius
float LastDist
ObjectReference LastTarget
Location TargetLocation
string[] Blockers
bool Paused
int SkipTimes

function Maintenance()
    CheckInterval = 10

    if CurrMode >= 0
        RegisterForSingleUpdate(CheckInterval)
    endIf
endFunction

Adv_Collar function Get() global
    return Quest.GetQuest("Adv_Collar") as Adv_Collar
endFunction

bool function CheckCollar()
    return PlayerRef.WornHasKeyword(Keyword.GetKeyword("zad_DeviousCollar"))
endFunction

bool function Zap(bool abCheckCollar = true)
    Adv_Util.LogInfo("Zapping player")
   
    if abCheckCollar && !CheckCollar()
        return false
    endIf

    int pain = HealthReduce
	int minHealth = HealthThresh

    if PlayerRef.IsInCombat()
		pain = (pain / 2) as int
		minHealth = 100
	endif
	
	;DamagePlayerHealth(pain, minHealth)
	PlayerRef.DamageActorValue("Magicka", MagickaReduce)
	ZapSpell.Cast(PlayerRef, PlayerRef)

	if Game.UsingGamepad()
		Game.ShakeController(0.5, 0.5, 1.0)
	endif

    return true
endFunction

function DamagePlayerHealth(int aiAmount, int aiMin = 50)	
    int pain = aiAmount
	int health = Math.Floor(PlayerRef.GetActorValue("Health"))
	if health <= aiMin
		pain = 0
	elseif (health - pain) < aiMin
		pain = health - aiMin
	endif

	ActorBase PlayerBase = PlayerRef.GetBaseObject() as ActorBase
	bool wasEssential = PlayerRef.IsEssential()
	PlayerBase.SetEssential(true)
	PlayerRef.DamageActorValue("Health", pain)
	PlayerBase.SetEssential(wasEssential)
endFunction

function ZapTimes(int aiTimes = 2, bool abCheckCollar = true)
    aiTimes = PapyrusUtil.ClampInt(aiTimes, 0, aiTimes)

    int i = 0
    while i < aiTimes
        if !Zap(abCheckCollar)
            return
        endIf

        Utility.Wait(2.0)
        i += 1
    endWhile
endFunction

function SetLeash(ObjectReference akTarget, int aiRadius = 300, Scene akViolation = none, bool abZapAfter = false)
    TargetRef = akTarget
    CurrMode = COLLAR_MODE_LEASH
    ExpectedRadius = aiRadius
    ViolationScene = akViolation
    ZapAfter = abZapAfter
    TargetLocation = none
   
    Adv_Util.LogInfo("Collar - SetLeash - " + akTarget + " - " + aiRadius)
   
    RegisterForSingleUpdate(CheckInterval)
endFunction

; aiMode = 0 -> walk, aiMode = 1 -> run, aiMode = 2 -> sprint
function SetTargetRef(ObjectReference akTarget, int aiRadius = 300, int aiSpeed = 1, Scene akViolation = none, bool abZapAfter = false)
    TargetRef = akTarget as ObjectReference
    LastDist = PyramidUtils.GetTravelDistance(PlayerRef, akTarget)
    ExpectedRadius = aiRadius
    CurrMode = COLLAR_MODE_LEAD
    ViolationScene = akViolation
    ZapAfter = abZapAfter
    TargetLocation = none

    ; TODO: adjust later depending on speed mult
    if aiSpeed == 0
        ExpectedDist = 100
    elseIf aiSpeed == 1
        ExpectedDist = 200
    elseIf aiSpeed == 2
        ExpectedDist = 300
    endIf

    Adv_Util.LogInfo("Collar - SetTarget - " + akTarget + " - " + aiRadius + " - " + aiSpeed + " - " + ExpectedDist)

    RegisterForSingleUpdate(CheckInterval)
endFunction

function SetLocation(Location akLocation, Scene akViolation = none, bool abZapAfter = false)
    TargetLocation = akLocation
    TargetRef = none
    CurrMode = COLLAR_MODE_LOCATION
    ExpectedRadius = 0
    ViolationScene = akViolation
    ZapAfter = abZapAfter
    RegisterForSingleUpdate(CheckInterval)
endFunction

event OnUpdate()
    if !Paused
        bool valid = IsCheckValid()
        if CurrMode == COLLAR_MODE_LOCATION && valid
            if !PlayerRef.IsInLocation(TargetLocation)
                Violation(VIOLATION_TYPE_LOCATION)
            endIf
        else
            float dist = PyramidUtils.GetTravelDistance(PlayerRef, TargetRef)
       
            Adv_Util.LogInfo("Collar - Check - CurrMode = " + CurrMode + " - Dist = " + dist + " - LastDist = " + LastDist + " valid = " + valid + " Diff = " + (dist - LastDist) + " - SkipTimes = " + SkipTimes)
            ProgressUpdate(dist)

            bool canPunish = valid && SkipTimes < 1

            if CurrMode == COLLAR_MODE_LEASH
                if canPunish && dist > ExpectedRadius
                    Violation(VIOLATION_TYPE_LEASH)
                    Zap()
                    Utility.Wait(1.0)
                endIf
            else
                if dist <= ExpectedRadius && PlayerRef.GetParentCell() == TargetRef.GetParentCell() && PlayerRef.HasLOS(TargetRef)
                    Adv_Util.LogInfo("Collar - Reached final destination")
                    SendModEvent("Adv_Collar_ReachedDest")
                    SetLeash(TargetRef, ExpectedRadius)
                    return
                elseIf canPunish && LastDist >= 0 && (LastDist - dist) < ExpectedDist
                    Adv_Util.LogInfo("Collar - Check Target - Failed - Shocking - LastDist = " + LastDist + " Dist = " + dist)

                    float diff = dist - LastDist
                    if diff > 500
                        Violation(VIOLATION_TYPE_WRONG_DIRECTION)
                    else
                        Violation(VIOLATION_TYPE_SLOW)
                    endIf
                endIf
            endIf

            LastDist = dist

            if valid && SkipTimes >= 1
                SkipTimes -= 1
            elseIf !valid
                SkipTimes = 1 ; skip the next one
            endIf
        endIf
    endIf

    if CurrMode >= 0
        RegisterForSingleUpdate(CheckInterval)
    endIf
endEvent

function Violation(int aiReason)
    int handle = ModEvent.Create("Adv_Collar_Violation")
    if handle
        ModEvent.PushInt(handle, CurrMode)

        if TargetRef
            ModEvent.PushForm(handle, TargetRef)
        elseIf TargetLocation
            ModEvent.PushForm(handle, TargetLocation)
        endIf

        ModEvent.Send(handle)
    endIf

    ViolationReason.SetValue(aiReason)
    
    if ViolationScene
        ViolationScene.Start()
        if ZapAfter
            Adv_SceneUtils.WaitForScene(PlayerRef)
        endIf
    endIf

    Zap()
    Utility.Wait(1.0)
endFunction

function ProgressUpdate(float akCurrent)
    int handle = ModEvent.Create("Adv_Collar_Update")
    if handle
        ModEvent.PushFloat(handle, LastDist)
        ModEvent.PushFloat(handle, akCurrent)
        ModEvent.Send(handle)
    endIf
endFunction

bool function IsCheckValid()
    bool inCombat = PlayerRef.IsInCombat()
    bool isTalking = PyramidUtils.GetPlayerSpeechTarget()
    bool inSex = SexlabUtil.GetAPI().IsActorActive(PlayerRef)
    bool isDefeated = Game.IsPluginInstalled("Acheron.esm") && (Acheron.IsDefeated(PlayerRef) || Acheron.IsPacified(PlayerRef))
    bool inScene = PlayerRef.GetCurrentScene()

    Adv_Util.LogInfo("Check Valid: combat = " + inCombat + " - talking = " + isTalking + " - sex = " + inSex + " - defeated = " + isDefeated + " - scene = " + inScene)

    return !inCombat && !isTalking && !inSex && !isDefeated && !inScene
endFunction

function StopPassive()
    CurrMode = -1
    UnregisterForUpdate()
endFunction

function Pause(string asKey)
    Adv_Util.LogInfo("Collar - Pausing")
    Paused = true
    Blockers = PapyrusUtil.PushString(Blockers, asKey)
endFunction

function Resume(string asKey)
    Blockers = PapyrusUtil.RemoveString(Blockers, asKey)

    if !Blockers.Length && CurrMode >= 0
        Adv_Util.LogInfo("Collar - Resuming")
        Paused = false
        SkipTimes = 1
        UnregisterForUpdate()
        RegisterForSingleUpdate(CheckInterval * 2)
    endIf
endFunction