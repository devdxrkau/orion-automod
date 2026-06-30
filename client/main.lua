-- ============================================================
--  Orion AutoMod - Client main.lua
-- ============================================================

RegisterNetEvent("orion-automod:notify")
AddEventHandler("orion-automod:notify", function(data)
    lib.notify({
        title       = data.title or "Orion-AutoMod",
        description = data.message,
        type        = "error",
        duration    = 6000,
        icon        = "ban",
        iconColor   = "#e03c3c",
        position    = "top-right",
    })
end)
