return {
	"shortcuts/no-neck-pain.nvim",
	lazy = false,
	priority = 900,
	config = function()
		require("no-neck-pain").setup({
			width = 80,
			autocmds = {
				enableOnTabEnter = true,
				skipEnteringNoNeckPainBuffer = true,
			},
			buffers = {
				bo = {
					filetype = "no-neck-pain-side",
					modifiable = false,
					readonly = true,
				},
				wo = {
					fillchars = "eob: ",
				},
				left = { enabled = true },
				right = { enabled = true },
				scratchPad = {
					enabled = false,
				},
				colors = {
					bo = {
						filetype = "md",
					},
					blend = 0.8,
				},
			},
		})
		vim.cmd("NoNeckPain")
	end,
}
