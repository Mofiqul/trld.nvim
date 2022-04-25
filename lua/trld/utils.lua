local M = {}

local c = require 'trld.config'

-- return higlight group name from lsp diagnostic severity
M.get_hl_by_serverity = function(severity)
    local severity_names = {
        [vim.diagnostic.severity.ERROR] = "error",
        [vim.diagnostic.severity.WARN] = "warn",
        [vim.diagnostic.severity.INFO] = "info",
        [vim.diagnostic.severity.HINT] = "hint",
    }
    local severity_name = severity_names[severity]
    return c.config.highlights[severity_name]
end

-- reverse a table
M.reverse_table = function(tbl)
    for i = 1, math.floor(#tbl / 2) do
        local j = #tbl - i + 1
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- display diagnostics
M.display_diagnostics = function(diags, bufnr, ns, pos)
    local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]

    -- reverse diag order if rendering on the bottom
    if (pos == 'bottom') then diags = M.reverse_table(diags) end

    -- render each diag
    for i, diag in ipairs(diags) do
        local x = nil
        if (pos == 'top') then
            x = (win_info.topline - 3) + (i + 1)
            if win_info.botline < x then return end
        elseif (pos == 'bottom') then
            x = (win_info.botline) - (i + 1)
            if win_info.topline > x then return end
        end

        vim.api.nvim_buf_set_extmark(bufnr, ns, x, 0, {
            virt_text = c.config.formatter(diag),
            virt_text_pos = "right_align",
            virt_lines_above = true,
        })
    end
end

return M
