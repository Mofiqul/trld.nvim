-- A neivim plugin to display line diagnostics on top right corner
-- Last Change:	2022 Apr 23
-- Author:	Mofiqul Islam <mofi0islam@gmail.com>
-- Licence:	MIT

local highlight_groups = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticError",
    [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticHint",
}

function PrintDiagnostics(opts, bufnr, line_nr, client_id)
    bufnr = bufnr or 0
    line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)
    opts = opts or { ['lnum'] = line_nr }

    local namespace = vim.api.nvim_create_namespace "trld"
    local ns = vim.diagnostic.get_namespace(namespace)

    local line_diagnostics = vim.diagnostic.get(bufnr, opts)



    if vim.tbl_isempty(line_diagnostics) then

        if ns.user_data.diags then
            vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
        end
        return
    end

    if ns.user_data.last_line_nr == line_nr and ns.user_data.diags then
        return
    end

    ns.user_data.diags = true
    ns.user_data.last_line_nr = line_nr

    local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]

    for i, diagnostic in ipairs(line_diagnostics) do
        local diag_lines = {}

        for line in diagnostic.message:gmatch("[^\n]+") do
            table.insert(diag_lines, line)
        end
        for j, dline in ipairs(diag_lines) do
            local x = (win_info.topline - 3) + (i + j)
            if win_info.botline <= x - 1 then
                return
            end
            vim.api.nvim_buf_set_extmark(bufnr, namespace, x, 0, {
                virt_text = { { dline, highlight_groups[diagnostic.severity] } },
                virt_text_pos = "right_align",
                virt_lines_above = true,
            })
        end
    end
end

function HideDiagnostics(opts, bufnr, line_nr, client_id)
    bufnr = bufnr or 0
    local namespace = vim.api.nvim_get_namespaces()['trld'];
    if namespace == nil then return end
    local ns = vim.diagnostic.get_namespace(namespace)
    if ns.user_data.diags then
        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    end
    ns.user_data.diags = false
end

local M = {}

M.setup = function()
    vim.diagnostic.config({
        virtual_text = false,
    })

    vim.cmd [[ autocmd! CursorHold,CursorHoldI * lua PrintDiagnostics() ]]
    vim.cmd [[ autocmd! CursorMoved,CursorMovedI * lua HideDiagnostics() ]]
end

return M
