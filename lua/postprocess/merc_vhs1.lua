local mat_vhs1 = Material( "effects/shaders/merc_vhs1" )

local pp_vhs1 = CreateClientConVar( "pp_mercvhs1", "0", false, false, "Enable VHS1", 0, 1 )
local pp_vhs1_xo = CreateClientConVar( "pp_mercvhs1_xoffset", "0.008", false, false, "VHS1 X Offset", 0, 10 )
local pp_vhs1_yo = CreateClientConVar( "pp_mercvhs1_yoffset", "0.008", false, false, "VHS1 Y Offset", 0, 10 )

function render.DrawMercVHS1(xoff, yoff)
    mat_vhs1:SetFloat("$c0_y", xoff)
    mat_vhs1:SetFloat("$c0_z", yoff)
    render.SetMaterial(mat_vhs1)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback("pp_mercvhs1", function(cvar, old, new)
    if pp_vhs1:GetBool() then
        hook.Add("RenderScreenspaceEffects", "merc_vhs1_hook", function()
            render.DrawMercVHS1(pp_vhs1_xo:GetFloat(), pp_vhs1_yo:GetFloat())
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "merc_vhs1_hook")
    end
end, "merc_vhs1_callback")

list.Set( "PostProcess", "VHS1", {

	icon = "gui/postprocess/mercvhs1.png",
	convar = "pp_mercvhs1",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Mimics a VHS tape." )
		CPanel:CheckBox( "Enable", "pp_mercvhs1" )

        CPanel:ToolPresets( "pp_mercvhs1", {pp_mercvhs1_xoffset = "0.008", pp_mercvhs1_yoffset = "0.008"} )

        CPanel:NumSlider("X Offset", "pp_mercvhs1_xoffset", 0, 10, 4)
        CPanel:NumSlider("Y Offset", "pp_mercvhs1_yoffset", 0, 10, 4)

	end

} )