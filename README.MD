# Orion AutoMod – FiveM Anti-Cheat Moderation System

Orion Studios presents Orion AutoMod, a lightweight and highly configurable moderation system designed for FiveM servers. It automatically detects inappropriate language, enforces punishments, and helps maintain a professional roleplay environment with minimal staff workload.

---

## Features

- Real-time chat filtering using pattern detection
- Tier-based punishment system (profanity / slurs / zero tolerance)
- Automatic kicks and temporary bans
- Optional server-wide broadcast notifications
- Console logging support
- Fully configurable Lua system
- Lightweight and optimized for performance

---

## How It Works

The system scans player chat messages and compares them against patterns defined in:

Config.Words

Each match triggers an action based on its assigned tier:

- profanity → kick
- slur → ban
- zerotolerance → instant ban + broadcast

---

## Installation

1. Download the resource
2. Place it into your FiveM resources folder
3. Add the following to your server.cfg:
   ensure orion-automod
4. Configure the system inside config.lua
5. Restart your server

---

## Configuration

Config = {}

Config.KickMessage = "You were kicked by AutoMod for inappropriate language."
Config.BanMessage = "You have been banned by AutoMod for inappropriate language.\nBan ID: %s\nExpires in: %s"

Config.BanDurationHours = 3

Config.BroadcastKick = "%s has been kicked for inappropriate language."
Config.BroadcastBan  = "%s has been banned for %d hours for inappropriate language."

Config.NotifyAll = true
Config.LogToConsole = false
Config.Debug = false

---

## Word Filtering System

Config.Words = {

    -- TIER 1 - Profanity (Kick)
    { pattern = "bitch",   tier = "profanity", action = "kick" },
    { pattern = "asshole", tier = "profanity", action = "kick" },
    { pattern = "cunt",    tier = "profanity", action = "kick" },
    { pattern = "dick",    tier = "profanity", action = "kick" },

    -- TIER 2 - Slurs (Ban)
    { pattern = "n+i+g+g+[ae]r*", tier = "slur", action = "ban" },
    { pattern = "f+[a4]+g+[o0]*t*", tier = "slur", action = "ban" },
    { pattern = "ch[i1]+nk", tier = "slur", action = "ban" },
    { pattern = "sp[i1]+c+", tier = "slur", action = "ban" },

    -- TIER 3 - Zero Tolerance (Instant Ban)
    -- { pattern = "example", tier = "zerotolerance", action = "ban" },
}

---

## Tier System

Tier 1 – Profanity: Kick  
Tier 2 – Slurs: Temporary ban  
Tier 3 – Zero tolerance: Instant ban + broadcast  

---

## Performance

- Lightweight Lua-based design
- Minimal server impact
- No heavy database dependency required
- Optimized for RP servers

---

## Support

Discord: https://discord.gg/NWBU7RUPqc

---

## License

Developed by Orion Studios.
This resource may be used on private servers. Redistribution without permission is not allowed.