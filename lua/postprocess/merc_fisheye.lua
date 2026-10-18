local mat_Fisheye = Material( "effects/shaders/merc_fisheye" )

local pp_fisheye = CreateClientConVar( "pp_mercfisheye", "0", false, false, "Enable fisheye", 0, 1 )
local pp_fisheye_strength = CreateClientConVar( "pp_mercfisheye_strength", "0.2", false, false, "Fisheye Strength", -10, 10 )

function render.DrawMercFisheye(strength)
    render.UpdateScreenEffectTexture()
    mat_Fisheye:SetFloat("$c0_x", strength)
    render.SetMaterial(mat_Fisheye)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercfisheye", function(cvar, old, new)
    if pp_fisheye:GetBool() then
        hook.Add("RenderScreenspaceEffects", "merc_fisheye_hook", function()
            render.DrawMercFisheye(pp_fisheye_strength:GetFloat())
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "merc_fisheye_hook")
    end
end, "merc_fisheye_callback")

list.Set( "PostProcess", "Fisheye", {

	icon = "gui/postprocess/mercfisheye.png",
	convar = "pp_mercfisheye",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Distorts the screen to mimic a fisheye effect." )
		CPanel:CheckBox( "Enable", "pp_mercfisheye" )

        CPanel:ToolPresets( "pp_mercfisheye", {pp_mercfisheye_strength = "0.2"} )

		CPanel:NumSlider( "Strength", "pp_mercfisheye_strength", -10, 10, 3 )

	end

} )