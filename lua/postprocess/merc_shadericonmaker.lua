local mat_shadericonmaker = Material( "effects/shaders/merc_iconshadermaker" )

local pp_shadericonmaker = CreateClientConVar( "pp_mercshadericonmaker", "0", false, false, "Enable Shader Icon Maker", 0, 1 )
local pp_shadericonmaker_shader = CreateClientConVar( "pp_mercshadericonmaker_shader", "merc_fisheye_ps20", false, false, "Shader Icon Maker Shader" )

concommand.Add( "pp_shadericonmaker_save", function()

    hook.Add( "PostRender", "mercshadericonmaker_screenshot", function()
    
        timer.Simple(1, function()
            local data = render.Capture( {
                format = "png",
                x = 0,
                y = 0,
                w = 128,
                h = 128,
                alpha = false
            } )
        
            file.Write( "image.png", data )
            hook.Remove("PostRender", "mercshadericonmaker_screenshot")
        end)

    end )

end, nil, "Save the created icon for the custom shader to the data folder.")

local iconmakercvars = {}

for i = 0, 1 do
    local translate = {
        [1] = "x",
        [2] = "y",
        [3] = "z",
        [4] = "w"
    }

    for j = 1, 4 do
        iconmakercvars["$c"..i.."_"..translate[j]] = CreateClientConVar( "pp_mercshadericonmaker_c"..i.."_"..translate[j], "0", false, false, "Shader Icon Maker Variable", -10, 10 )
    end
end

cvars.AddChangeCallback("pp_mercshadericonmaker_shader", function(cvar, old, new)
    print("we tried chief...")
    mat_shadericonmaker:SetString("$pixshader", new)
    mat_shadericonmaker:Recompute()
end)

cvars.AddChangeCallback("pp_mercshadericonmaker", function(cvar, old, new)
    if pp_shadericonmaker:GetBool() then
        hook.Add("HUDPaint", "merc_shadericonmaker_hook", function()  
            for id, cvar in pairs(iconmakercvars) do
                mat_shadericonmaker:SetFloat( id, cvar:GetFloat() )
            end
        
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat_shadericonmaker)
            surface.DrawTexturedRect(0, 0, 128, 128)
        end)
    else
        hook.Remove("HUDPaint", "merc_shadericonmaker_hook")
    end
end, "merc_shadericonmaker_callback")