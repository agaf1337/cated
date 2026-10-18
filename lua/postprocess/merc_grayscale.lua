local mat_Grayscale = Material( "effects/shaders/merc_grayscale" )

local pp_grayscale = CreateClientConVar( "pp_mercgrayscale", "0", false, false, "Enable depth grayscale", 0, 1 )
local pp_grayscale_depthstart = CreateClientConVar( "pp_mercgrayscale_depthstart", "0", false, false, "Depth start range", -1, 1 )
local pp_grayscale_depthend = CreateClientConVar( "pp_mercgrayscale_depthend", "1", false, false, "Depth start range", 0, 1 )


cvars.AddChangeCallback("pp_mercgrayscale", function(cvar, old, new)
    if pp_grayscale:GetBool() then
        local needsDepth = false

        hook.Add("RenderScreenspaceEffects", "merc_grayscale_hook", function()
            needsDepth = true
            render.UpdateScreenEffectTexture()
            mat_Grayscale:SetFloat("$c0_x", pp_grayscale_depthstart:GetFloat() )
            mat_Grayscale:SetFloat("$c0_y", pp_grayscale_depthend:GetFloat() )
            render.SetMaterial(mat_Grayscale)
            render.DrawScreenQuad()
            needsDepth = false
        end)

        hook.Add("NeedsDepthPass", "merc_grayscale_depth", function()
            DOFModeHack(true)
            return true
        end)

    else
        hook.Remove("RenderScreenspaceEffects", "merc_grayscale_hook")
        hook.Remove("NeedsDepthPass", "merc_grayscale_depth")
    end
end, "merc_grayscale_callback")

list.Set( "PostProcess", "Depth Grayscale", {

	icon = "gui/postprocess/mercdepthgrayscale.png",
	convar = "pp_mercgrayscale",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Grayscales the world the farther it is from you." )
		CPanel:CheckBox( "Enable", "pp_mercgrayscale" )

        CPanel:ToolPresets( "pp_mercgrayscale", {pp_mercgrayscale_depthstart = "0", pp_mercgrayscale_depthend = "1"} )

        CPanel:NumSlider( "Depth Start", "pp_mercgrayscale_depthstart", -1, 1, 4 )
        CPanel:NumSlider( "Depth End", "pp_mercgrayscale_depthend", 0, 1, 4 )
	end

} )