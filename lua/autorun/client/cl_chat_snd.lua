
local function PlayChatSound()
    surface.PlaySound("common/talk.wav")
end

hook.Add("OnPlayerChat", "chatchatchatplayer", function()
    PlayChatSound()
end)


hook.Add("ChatText", "chatchatchat", function()
    PlayChatSound()
end)
