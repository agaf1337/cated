local mat_Depthblur = Material( "effects/shaders/merc_depthblur" )

local pp_depthblur = CreateClientConVar( "pp_mercdepthblur", "0", false, false, "Enable depth blur", 0, 1 )
local pp_depthblur_depthstart = CreateClientConVar( "pp_mercdepthblur_depthstart", "0", false, false, "Depth start range", 0, 1 )
local pp_depthblur_depthend = CreateClientConVar( "pp_mercdepthblur_depthend", "1", false, false, "Depth start range", 0, 1 )
local pp_depthblur_strength = CreateClientConVar( "pp_mercdepthblur_strength", "0.1", false, false, "Blur Strength", 0, 5 )

cvars.AddChangeCallback("pp_mercdepthblur", function(cvar, old, new)
    if pp_depthblur:GetBool() then

        hook.Add("RenderScreenspaceEffects", "merc_depthblur_hook", function()
            render.UpdateScreenEffectTexture()
            mat_Depthblur:SetFloat("$c0_x", pp_depthblur_depthstart:GetFloat() )
            mat_Depthblur:SetFloat("$c0_y", pp_depthblur_depthend:GetFloat() )
            mat_Depthblur:SetFloat("$c0_z", pp_depthblur_strength:GetFloat() )
            render.SetMaterial(mat_Depthblur)
            render.DrawScreenQuad()
        end)

        hook.Add("NeedsDepthPass", "merc_depthblur_depth", function()
            return true
        end)

    else
        hook.Remove("RenderScreenspaceEffects", "merc_depthblur_hook")
        hook.Remove("NeedsDepthPass", "merc_depthblur_depth")
    end
end, "merc_depthblur_callback")

list.Set( "PostProcess", "Depth Blur", {

	icon = "gui/postprocess/mercdepthblur.png",
	convar = "pp_mercdepthblur",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "(Badly) Blurs the world the farther it is from you." )
		CPanel:CheckBox( "Enable", "pp_mercdepthblur" )

        CPanel:ToolPresets( "pp_mercdepthblur", {pp_mercdepthblur_depthstart = "0", pp_mercdepthblur_depthend = "1", pp_mercdepthblur_strength = "0.1"} )

        CPanel:NumSlider( "Depth Start", "pp_mercdepthblur_depthstart", 0, 1, 4 )
        CPanel:NumSlider( "Depth End", "pp_mercdepthblur_depthend", 0, 1, 4 )
        CPanel:NumSlider( "Strength", "pp_mercdepthblur_strength", 0, 5, 4 )

	end

} )