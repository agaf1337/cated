local mat_videoglitch = Material( "effects/shaders/merc_videoglitch" )

local pp_videoglitch = CreateClientConVar( "pp_mercvideoglitch", "0", false, false, "Enable videoglitch", 0, 1 )
local pp_videoglitch_strength = CreateClientConVar( "pp_mercvideoglitch_strength", "1", false, false, "Videoglitch strength", 0, 1 )

function render.DrawMercVideoGlitch(strength)
    render.UpdateScreenEffectTexture()
    mat_videoglitch:SetFloat("$c0_y", strength)
    render.SetMaterial(mat_videoglitch)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercvideoglitch", function(cvar, old, new)
    if pp_videoglitch:GetBool() then
        hook.Add("RenderScreenspaceEffects", "merc_videoglitch_hook", function()
            render.DrawMercVideoGlitch(pp_videoglitch_strength:GetFloat())
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "merc_videoglitch_hook")
    end
end, "merc_videoglitch_callback")

list.Set( "PostProcess", "Video Glitch", {

	icon = "gui/postprocess/mercvideoglitch.png",
	convar = "pp_mercvideoglitch",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Mimicks a video glitch effect." )
		CPanel:CheckBox( "Enable", "pp_mercvideoglitch" )

        CPanel:ToolPresets( "pp_mercvideoglitch", {pp_mercvideoglitch_strength = "1"} )

        CPanel:NumSlider("Strength", "pp_mercvideoglitch_strength", 0, 1, 3)

	end

} )