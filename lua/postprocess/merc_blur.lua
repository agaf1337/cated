local mat_blur = Material( "effects/shaders/merc_blur" )

local pp_blur = CreateClientConVar( "pp_mercblur", "0", false, false, "Enable blur", 0, 1 )
local pp_blur_strength = CreateClientConVar( "pp_mercblur_strength", "0.3", false, false, "Blur Strength", 0, 1 )

function render.DrawMercBlur(strength)
    render.UpdateScreenEffectTexture()
    mat_blur:SetFloat("$c0_x", strength)
    render.SetMaterial(mat_blur)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercblur", function(cvar, old, new)
    if pp_blur:GetBool() then
        hook.Add("RenderScreenspaceEffects", "merc_blur_hook", function()
            render.DrawMercBlur(pp_blur_strength:GetFloat())
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "merc_blur_hook")
    end
end, "merc_blur_callback")

list.Set( "PostProcess", "Blur", {

	icon = "gui/postprocess/mercvideoglitch.png",
	convar = "pp_mercblur",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "A simple blur effect." )
		CPanel:CheckBox( "Enable", "pp_mercblur" )

        CPanel:ToolPresets( "pp_mercblur", { pp_mercblur_strength = "0.3" } )

        CPanel:NumSlider("Strength", "pp_mercblur_strength", 0, 1, 4)

	end

} )