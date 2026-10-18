local mat_Caber = Material( "effects/shaders/merc_chromaticaberration" )

local pp_caber = CreateClientConVar( "pp_merccaber", "0", false, false, "Enable Chromatic Aberration", 0, 1 )
local pp_caber_amount = CreateClientConVar( "pp_merccaber_amount", "0.5", false, false, "Chromatic Aberration Amount", -1, 1 )
local pp_caber_center = CreateClientConVar( "pp_merccaber_center", "0", false, false, "Chromatic Aberration fade in center", 0, 1 )

function render.DrawMercChromaticAberration(amount, centerfalloff)
    render.UpdateScreenEffectTexture()
    mat_Caber:SetFloat("$c0_x", amount)
    mat_Caber:SetInt("$c0_y", centerfalloff and 1 or 0)
    render.SetMaterial(mat_Caber)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_merccaber", function(cvar, old, new)
    if pp_caber:GetBool() then
        hook.Add("RenderScreenspaceEffects", "merc_caber_hook", function()
            render.DrawMercChromaticAberration(pp_caber_amount:GetFloat(), pp_caber_center:GetBool())
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "merc_caber_hook")
    end
end, "merc_caber_callback")

list.Set( "PostProcess", "Chromatic Aberration", {

	icon = "gui/postprocess/mercchromaticaberration.png",
	convar = "pp_merccaber",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Chromatic Aberration effect" )
		CPanel:CheckBox( "Enable", "pp_merccaber" )
        CPanel:CheckBox( "Center falloff", "pp_merccaber_center" )

        CPanel:ToolPresets( "pp_merccaber", { pp_merccaber_center = "0", pp_merccaber_amount = "0.5" } )

		CPanel:NumSlider( "Strength", "pp_merccaber_amount", -1, 1, 4 )

	end

} )