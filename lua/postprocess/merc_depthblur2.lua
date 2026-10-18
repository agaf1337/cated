local mat_Depthblur = Material( "effects/shaders/merc_depthblur2" )

local pp_depthblur = CreateClientConVar( "pp_mercdepthblur2", "0", false, false, "Enable depth blur 2", 0, 1 )
local pp_depthblur_depthstart = CreateClientConVar( "pp_mercdepthblur2_depthstart", "0", false, false, "Depth start range", 0, 1 )
local pp_depthblur_depthend = CreateClientConVar( "pp_mercdepthblur2_depthend", "1", false, false, "Depth start range", 0, 1 )
local pp_depthblur_strength = CreateClientConVar( "pp_mercdepthblur2_strength", "0.5", false, false, "Blur Strength", 0, 5 )

function render.DrawMercDepthBlur2(depthstart, depthend, strength)
    render.UpdateScreenEffectTexture()
    mat_Depthblur:SetFloat("$c0_y", depthstart )
    mat_Depthblur:SetFloat("$c0_z", depthend )
    mat_Depthblur:SetFloat("$c0_x", strength )
    render.SetMaterial(mat_Depthblur)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercdepthblur2", function(cvar, old, new)
    if pp_depthblur:GetBool() then

        hook.Add("RenderScreenspaceEffects", "merc_depthblur2_hook", function()
            render.DrawMercDepthBlur2(pp_depthblur_depthstart:GetFloat(), pp_depthblur_depthend:GetFloat(), pp_depthblur_strength:GetFloat())
        end)

        hook.Add("NeedsDepthPass", "merc_depthblur2_depth", function()
            return true
        end)

    else
        hook.Remove("RenderScreenspaceEffects", "merc_depthblur2_hook")
        hook.Remove("NeedsDepthPass", "merc_depthblur2_depth")
    end
end, "merc_depthblur2_callback")

list.Set( "PostProcess", "Depth Blur 2", {

	icon = "gui/postprocess/dof.png",
	convar = "pp_mercdepthblur2",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Blurs the world the farther it is from you." )
		CPanel:CheckBox( "Enable", "pp_mercdepthblur2" )

        CPanel:ToolPresets( "pp_mercdepthblur2", {pp_mercdepthblur2_depthstart = "0", pp_mercdepthblur2_depthend = "1", pp_mercdepthblur2_strength = "0.1"} )

        CPanel:NumSlider( "Depth Start", "pp_mercdepthblur2_depthstart", 0, 1, 4 )
        CPanel:NumSlider( "Depth End", "pp_mercdepthblur2_depthend", 0, 1, 4 )
        CPanel:NumSlider( "Strength", "pp_mercdepthblur2_strength", 0, 1, 4 )

	end

} )