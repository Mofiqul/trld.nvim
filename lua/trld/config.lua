local M = {}

-- default config
M.default_config = {
    position = "top",
    auto_cmds = true,
    highlights = {
        error = "DiagnosticFloatingError",
        warn = "DiagnosticFloatingWarn",
        info = "DiagnosticFloatingInfo",
        hint = "DiagnosticFloatingHint",
    },
    formatter = function(diag)
        local u = require 'trld.utils'
        local diag_lines = {}

        for line in diag.message:gmatch("[^\n]+") do
            line = line:gsub('[ \t]+%f[\r\n%z]', '')
            table.insert(diag_lines, line)
        end

        local lines = {}
        for _, diag_line in ipairs(diag_lines) do
            table.insert(lines, { { diag_line .. ' ', u.get_hl_by_serverity(diag.severity) } })
        end

        return lines
    end,

}

-- config
M.config = {}

-- return bool indicating in config is valid
M.validate_config = function(cfg)
    -- TODO: implement config validation with vim.notify() logging
    return true
end

-- override the default config with user configs
M.override_config = function(cfg)
    M.config = vim.tbl_deep_extend("force", M.default_config, cfg or {})
end

return M
