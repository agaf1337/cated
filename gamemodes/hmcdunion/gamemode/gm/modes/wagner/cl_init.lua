local mode = GM:GetMode("wagner")

mode.StartSound = "hohols.mp3"

mode.EndTitles = {
	[3] = { text = "Draw!", color = Color(223, 223, 223) },
	[9] = { text = "Wagner PMC wins!", color = Color(140, 25, 25) },
	[10] = { text = "Azov wins!", color = Color(25, 70, 180) },
}
