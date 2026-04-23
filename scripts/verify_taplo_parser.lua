local cwd = vim.fn.getcwd()
package.path = table.concat({
	cwd .. "/dot_config/nvim/lua/?.lua",
	cwd .. "/dot_config/nvim/lua/?/init.lua",
	package.path,
}, ";")

local taplo_lint = require("core.taplo_lint")
local taplo_config = require("core.taplo_config")

local function assert_eq(actual, expected, message)
	if actual ~= expected then
		error(("%s: expected %s, got %s"):format(message, vim.inspect(expected), vim.inspect(actual)))
	end
end

local function assert_diagnostic(diagnostic, expected)
	assert_eq(diagnostic.message, expected.message, "message mismatch")
	assert_eq(diagnostic.lnum, expected.lnum, "lnum mismatch")
	assert_eq(diagnostic.col, expected.col, "col mismatch")
	assert_eq(diagnostic.end_lnum, expected.lnum, "end_lnum mismatch")
	assert_eq(diagnostic.end_col, expected.col, "end_col mismatch")
	assert_eq(diagnostic.severity, vim.diagnostic.severity.ERROR, "severity mismatch")
	assert_eq(diagnostic.source, "taplo", "source mismatch")
end

local syntax_error_output = table.concat({
	"error: invalid TOML",
	"  ┌─ /repo/pyproject.toml:1:3",
	"  │  ",
	"1 │   [a",
	"  │ ╭──^",
	"2 │ │ b=1",
	'  │ ╰^ expected "]"',
	"",
	'ERROR invalid file error=syntax errors found path="/repo/pyproject.toml"',
	"ERROR operation failed error=some files were not valid",
}, "\n")

local duplicate_key_output = table.concat({
	"error: conflicting keys",
	"  ┌─ /repo/pyproject.toml:2:1",
	"  │",
	"1 │ a=1",
	"  │ - duplicate found here",
	"2 │ a=2",
	"  │ ^ duplicate key",
	"",
	'ERROR invalid file error=semantic errors found path="/repo/pyproject.toml"',
	"ERROR operation failed error=some files were not valid",
}, "\n")

local multi_error_output = table.concat({
	"error: invalid TOML",
	"  ┌─ /repo/pyproject.toml:1:3",
	"error: conflicting keys",
	"  ┌─ /repo/pyproject.toml:4:1",
}, "\n")

local relative_path_output = table.concat({
	"error: invalid TOML",
	"  ┌─ pyproject.toml:1:3",
}, "\n")

local syntax_diagnostics = taplo_lint.parse_taplo_stderr(syntax_error_output, "/repo/pyproject.toml", "/repo")
assert_eq(#syntax_diagnostics, 1, "syntax diagnostics count mismatch")
assert_diagnostic(syntax_diagnostics[1], {
	message = "invalid TOML",
	lnum = 0,
	col = 2,
})

local duplicate_diagnostics = taplo_lint.parse_taplo_stderr(duplicate_key_output, "/repo/pyproject.toml", "/repo")
assert_eq(#duplicate_diagnostics, 1, "duplicate diagnostics count mismatch")
assert_diagnostic(duplicate_diagnostics[1], {
	message = "conflicting keys",
	lnum = 1,
	col = 0,
})

local multi_diagnostics = taplo_lint.parse_taplo_stderr(multi_error_output, "/repo/pyproject.toml", "/repo")
assert_eq(#multi_diagnostics, 2, "multi diagnostics count mismatch")
assert_diagnostic(multi_diagnostics[1], {
	message = "invalid TOML",
	lnum = 0,
	col = 2,
})
assert_diagnostic(multi_diagnostics[2], {
	message = "conflicting keys",
	lnum = 3,
	col = 0,
})

local filtered_diagnostics = taplo_lint.parse_taplo_stderr(syntax_error_output, "/repo/other.toml", "/repo")
assert_eq(#filtered_diagnostics, 0, "path filtering mismatch")

local relative_diagnostics = taplo_lint.parse_taplo_stderr(relative_path_output, "/repo/pyproject.toml", "/repo")
assert_eq(#relative_diagnostics, 1, "relative path diagnostics count mismatch")
assert_diagnostic(relative_diagnostics[1], {
	message = "invalid TOML",
	lnum = 0,
	col = 2,
})

local taplo_root = cwd
assert_eq(taplo_config.find_root(cwd .. "/dot_config/starship.toml"), taplo_root, "taplo root detection mismatch")
assert_eq(taplo_config.is_excluded(cwd .. "/dot_config/starship.toml"), true, "starship exclusion mismatch")
assert_eq(taplo_config.is_excluded(cwd .. "/pyproject.toml"), false, "pyproject exclusion mismatch")
assert_eq(
	taplo_config.relative_to_root(cwd .. "/dot_config/starship.toml", taplo_root),
	"dot_config/starship.toml",
	"relative path conversion mismatch"
)

print("Taplo parser verification passed.")
