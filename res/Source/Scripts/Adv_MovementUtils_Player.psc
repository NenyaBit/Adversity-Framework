Scriptname Adv_MovementUtils_Player extends ReferenceAlias  

Actor property PlayerRef auto

int property NIOVERRIDE_SCRIPT_VERSION = 6 AutoReadOnly
int property SMOOTHCAM_SCRIPT_VERSION = 17 AutoReadOnly
string property NINODE_ROOT = "NPC" AutoReadOnly
string property RACEMENUHH_KEY = "RaceMenuHH.esp" AutoReadOnly
string property INTERNAL_KEY = "internal" AutoReadOnly

string[] CrawlingKwdStrings
bool isProcessing = false
int PresetState

int RegularPresetIndex
int CrawlingPresetIndex

bool HasRacemenu = false
bool HasSmoothCam = false

event OnInit()
    Initialize()
endEvent

event OnPlayerLoadGame()
    Initialize()
endEvent

function Initialize()
    HasRacemenu = NiOverride.GetScriptVersion() >= NIOVERRIDE_SCRIPT_VERSION
    HasSmoothCam = Quest.GetQuest("SmoothCamMCM") != none

    PresetState = -1
    CrawlingKwdStrings = Utility.CreateStringArray(1, "Adv_CrawlingKwd")
    RegularPresetIndex = 5
    CrawlingPresetIndex = 0
    FixHeight()
endFunction

event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	FixHeight()
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	FixHeight()
endEvent

bool function IsCrawling()
    return PyramidUtils.WornHasKeywordstrings(PlayerRef, CrawlingKwdStrings)
endFunction

function RemoveFix()
	int isFemale = PlayerRef.GetLeveledActorBase().GetSex()
    NiOverride.RemoveNodeTransformPosition(PlayerRef, False, isFemale, NINODE_ROOT, RACEMENUHH_KEY)
    NiOverride.UpdateNodeTransform(PlayerRef, False, isFemale, NINODE_ROOT)
endFunction

function FixCamera(bool abCrawling)
    Debug.Trace("CFix: Player - FixCamera - " + abCrawling + " - " + PresetState)

    If abCrawling && PresetState != 0 && SmoothCamMCM.SmoothCam_LoadPreset(CrawlingPresetIndex)
        PresetState = 0
    ElseIf PresetState != 1 && SmoothCamMCM.SmoothCam_LoadPreset(RegularPresetIndex)
        PresetState = 1
    EndIf
endFunction

function FixHeight()
    bool crawling = IsCrawling()

	if HasRacemenu && !isProcessing
		isProcessing = True
		Int isFemale = PlayerRef.GetLeveledActorBase().GetSex()
        Debug.Trace("CFix: Player - " + crawling + " - " + NiOverride.HasNodeTransformPosition(PlayerRef, False, isFemale, NINODE_ROOT, INTERNAL_KEY))
        If NiOverride.HasNodeTransformPosition(PlayerRef, False, isFemale, NINODE_ROOT, INTERNAL_KEY)
			If crawling
				Float[] pos = NiOverride.GetNodeTransformPosition(PlayerRef, False, isFemale, NINODE_ROOT, INTERNAL_KEY)
				pos[0] = -pos[0]
				pos[1] = -pos[1]
				pos[2] = -pos[2]
				NiOverride.AddNodeTransformPosition(PlayerRef, False, isFemale, NINODE_ROOT, RACEMENUHH_KEY, pos)
				NiOverride.UpdateNodeTransform(PlayerRef, False, isFemale, NINODE_ROOT)
			Else
				RemoveFix()
			EndIf
		Else
			RemoveFix()
		EndIf
		isProcessing = False
	endIf

    if HasSmoothCam
        FixCamera(crawling)
    endIf
endFunction