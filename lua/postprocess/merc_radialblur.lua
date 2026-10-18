local mat_Radialblur = Material( "effects/shaders/merc_radialblur" )

local pp_radblur = CreateClientConVar( "pp_mercradblur", "0", false, false, "Enable radial blur", 0, 1 )
local pp_radblur_width = CreateClientConVar( "pp_mercradblur_width", "0.1", false, false, "Radial Blur width", 0, 10 )

function render.DrawMercRadialBlur(x, y, width)
    render.UpdateScreenEffectTexture()
    mat_Radialblur:SetFloat("$c0_x", x)
    mat_Radialblur:SetFloat("$c0_y", y)
    mat_Radialblur:SetFloat("$c0_z", width)
    render.SetMaterial(mat_Radialblur)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercradblur", function(cvar, old, new)
    if pp_radblur:GetBool() then
        hook.Add("RenderScreenspaceEffects", "merc_radblur_hook", function()
            render.DrawMercRadialBlur( 0.5, 0.5, pp_radblur_width:GetFloat() )
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "merc_radblur_hook")
    end
end, "merc_radblur_callback")

list.Set( "PostProcess", "Radial Blur", {

	icon = "gui/postprocess/mercradialblur.png",
	convar = "pp_mercradblur",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Blurs the screen around the edges." )
		CPanel:CheckBox( "Enable", "pp_mercradblur" )

        CPanel:ToolPresets( "pp_mercradblur", {pp_mercradblur_width = "0.1"} )

		CPanel:NumSlider( "Blur Width", "pp_mercradblur_width", 0, 10, 3 )

	end

} )