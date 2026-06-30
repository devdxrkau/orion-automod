-- ============================================================
--  Orion AutoMod - Configuration
-- ============================================================

Config = {}

-- Message shown to a player when they are kicked
Config.KickMessage = "You were kicked by AutoMod for inappropriate language."

-- Message shown to a player when they are banned (%s = ban ID, %s = duration remaining)
Config.BanMessage = "You have been banned by AutoMod for inappropriate language.\nBan ID: %s\nExpires in: %s"

-- How many hours a ban lasts (e.g. 24 = 1 day, 168 = 1 week)
Config.BanDurationHours = 3

-- Broadcast message shown to all players when a slur kick/ban happens
Config.BroadcastKick = "%s has been kicked for inappropriate language."
Config.BroadcastBan  = "%s has been banned for %d hours for inappropriate language."

-- Whether to broadcast to all players when a slur triggers a kick/ban
Config.NotifyAll = true

-- Whether to print automod actions to the server console
Config.LogToConsole = false

Config.Debug = false

Config.Words = {

    -- -------------------------------------------------------
    --  TIER 1 - Profanity — silent kick, no broadcast
    -- -------------------------------------------------------
    { pattern = "bitch",   tier = "profanity", action = "kick" },
    { pattern = "asshole", tier = "profanity", action = "kick" },
    { pattern = "cunt",    tier = "profanity", action = "kick" },
    { pattern = "dick",    tier = "profanity", action = "kick" },

    -- -------------------------------------------------------
    --  TIER 2 - Slurs — instant ban + server-wide notification
    -- -------------------------------------------------------
    { pattern = "n+i+g+g+[ae]r*",  tier = "slur", action = "ban" },
    { pattern = "n+i+g+",           tier = "slur", action = "ban" },
    { pattern = "f+[a4]+g+[o0]*t*", tier = "slur", action = "ban" },
    { pattern = "f+[a4]+g+",        tier = "slur", action = "ban" },
    { pattern = "ch[i1]+nk",        tier = "slur", action = "ban" },
    { pattern = "sp[i1]+c+",        tier = "slur", action = "ban" },
    { pattern = "k[i1]+k[e3]+",     tier = "slur", action = "ban" },
    { pattern = "tr[a4]+nn[yi]",    tier = "slur", action = "ban" },
    { pattern = "r[e3]+t[a4]+rd",   tier = "slur", action = "ban" },
    { pattern = "w[e3]+tb[a4]+ck",  tier = "slur", action = "ban" },
    { pattern = "cracker",          tier = "slur", action = "ban" },
    { pattern = "h[a4]+j[i1]+",     tier = "slur", action = "ban" },
    { pattern = "g[o0]+ok",         tier = "slur", action = "ban" },

    -- -------------------------------------------------------
    --  TIER 3 - Zero tolerance — instant ban + broadcast
    -- -------------------------------------------------------
    -- { pattern = "example", tier = "zerotolerance", action = "ban" },
}
