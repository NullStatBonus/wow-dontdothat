local addonName, ns = ...

-- Common alert sounds the game itself names. Each is a SOUNDKIT constant, checked against Blizzard's own
-- list for this client (Blizzard_SharedXML/Vanilla/SoundKitConstants.lua, Classic Era branch); the game
-- supplies the real ID when the sound is played. An entry whose constant a client lacks is left out of the picker.
-- Every other sound the game names, and any sounds registered with LibSharedMedia-3.0 by other addons or
-- sound packs, are added to the picker when it opens (see Model/SoundList.lua).
ns.Sounds = {
  default = "raidwarning",
  list = {
    { key = "raidwarning", label = "Raid warning", kind = "soundkit", constName = "RAID_WARNING" },
    { key = "readycheck", label = "Ready check", kind = "soundkit", constName = "READY_CHECK" },
    { key = "alarm1", label = "Alarm clock 1", kind = "soundkit", constName = "ALARM_CLOCK_WARNING_1" },
    { key = "alarm2", label = "Alarm clock 2", kind = "soundkit", constName = "ALARM_CLOCK_WARNING_2" },
    { key = "alarm3", label = "Alarm clock 3", kind = "soundkit", constName = "ALARM_CLOCK_WARNING_3" },
    { key = "bossemote", label = "Raid boss emote", kind = "soundkit", constName = "RAID_BOSS_EMOTE_WARNING" },
    { key = "bosswhisper", label = "Raid boss whisper", kind = "soundkit", constName = "UI_RAID_BOSS_WHISPER_WARNING" },
    { key = "murloc", label = "Murloc aggro (Mrglglgl)", kind = "soundkit", constName = "MURLOC_AGGRO" },
    { key = "pvpqueue", label = "PvP queue ready", kind = "soundkit", constName = "PVP_THROUGH_QUEUE" },
    { key = "questcomplete", label = "Quest complete", kind = "soundkit", constName = "UI_AUTO_QUEST_COMPLETE" },
    { key = "gmwarning", label = "GM chat warning", kind = "soundkit", constName = "GM_CHAT_WARNING" },
    { key = "mapping", label = "Map ping", kind = "soundkit", constName = "MAP_PING" },
  },
}
