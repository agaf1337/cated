local mat_Filmgrain = Material( "effects/shaders/merc_filmgrain" )

local pp_filmgrain = CreateClientConVar( "pp_mercfilmgrain", "0", false, false, "Enable film grain", 0, 1 )

-- 0: Addition, 1: Screen, 2: Overlay, 3: Soft Light, 4: Lighten-Only
local pp_filmgrain_blendmode = CreateClientConVar( "pp_mercfilmgrain_blendmode", "0", false, false, "Blend mode", 0, 4 )
local pp_filmgrain_speed = CreateClientConVar( "pp_mercfilmgrain_speed", "2", false, false, "Film grain speed", 0, 10 )
local pp_filmgrain_intensity = CreateClientConVar( "pp_mercfilmgrain_intensity", "0.075", false, false, "Film grain intensity", 0, 10 )
local pp_filmgrain_mean = CreateClientConVar("pp_mercfilmgrain_mean", "0", false, false, "Film grain mean", 0, 1)
local pp_filmgrain_variance = CreateClientConVar("pp_mercfilmgrain_variance", "0.5", false, false, "Film grain variance", 0, 1)

function render.DrawMercFilmGrain(blendmode, speed, intensity, mean, variance)
    render.UpdateScreenEffectTexture()
    mat_Filmgrain:SetInt("$c0_y", blendmode )
    mat_Filmgrain:SetFloat("$c0_z", speed )
    mat_Filmgrain:SetFloat("$c0_w", intensity )
    mat_Filmgrain:SetFloat("$c1_x", mean )
    mat_Filmgrain:SetFloat("$c1_y", variance )
    render.SetMaterial(mat_Filmgrain)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercfilmgrain", function(cvar, old, new)
    if pp_filmgrain:GetBool() then

        hook.Add("RenderScreenspaceEffects", "merc_filmgrain_hook", function()
            render.DrawMercFilmGrain(pp_filmgrain_blendmode:GetInt(),
                pp_filmgrain_speed:GetFloat(),
                pp_filmgrain_intensity:GetFloat(),
                pp_filmgrain_mean:GetFloat(),
                pp_filmgrain_variance:GetFloat()
            )
        end)

    else
        hook.Remove("RenderScreenspaceEffects", "merc_filmgrain_hook")
    end
end, "merc_filmgrain_callback")

list.Set( "PostProcess", "Film Grain", {

	icon = "gui/postprocess/mercfilmgrain.png",
	convar = "pp_mercfilmgrain",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Adds a film grain effect." )
		CPanel:CheckBox( "Enable", "pp_mercfilmgrain" )

        CPanel:ToolPresets( "pp_mercfilgrain", {pp_mercfilmgrain_blendmode = "0", pp_mercfilmgrain_speed = "2",
            pp_mercfilmgrain_intensity = "0.075", pp_mercfilmgrain_mean = "0", pp_mercfilmgrain_variance = "0.5"
        } )

        CPanel:Help( "0: Addition, 1: Screen, 2: Overlay, 3: Soft Light, 4: Lighten-Only" )
        CPanel:NumSlider( "Blend Mode", "pp_mercfilmgrain_blendmode", 0, 4, 0 )
        CPanel:NumSlider( "Speed", "pp_mercfilmgrain_speed", 0, 10, 4 )
        CPanel:NumSlider( "Intensity", "pp_mercfilmgrain_intensity", 0, 10, 4 )
        CPanel:NumSlider( "Mean", "pp_mercfilmgrain_mean", 0, 1, 4 )
        CPanel:NumSlider( "Variance", "pp_mercfilmgrain_variance", 0, 1, 4 )

	end

} )