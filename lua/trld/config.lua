local M = {}

-- default config
M.default_config = {
    position = "top",
    auto_cmds = true,
    highlights = {
        error = "DiagnosticFloatingError",
        warn =  "DiagnosticFloatingWarn",
        info =  "DiagnosticFloatingInfo",
        hint =  "DiagnosticFloatingHint",
    },
    formatter = function(diag)
        local u = require 'trld.utils'
        local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
        local msg = string.sub(diag.message, 1, wininfo.width)
        local src = diag.source
        local code = diag.user_data and diag.user_data.lsp and diag.user_data.lsp.code or nil

        -- remove dots
        --msg = msg:gsub('%.', '')
        src = src:gsub('%.', '')
        code = code and code:gsub('%.', '')

        -- remove starting and trailing spaces
        msg = msg:gsub('[ \t]+%f[\r\n%z]', '')
        src = src:gsub('[ \t]+%f[\r\n%z]', '')
        code = code and code:gsub('[ \t]+%f[\r\n%z]', '')

        return {
            {msg..' ', u.get_hl_by_serverity(diag.severity)},
            {code and code..' ' or '', "Comment"},
            {src..' ', "Folded"},
        }
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
