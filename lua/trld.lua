-- A neivim plugin to display line diagnostics on top right corner
-- Last Change:	2022 Apr 23
-- Author:	Mofiqul Islam <mofi0islam@gmail.com>
-- Licence:	MIT

local M = {}

local _config = {}

local highlight_groups = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticError",
    [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticHint",
}

local function reverse_table(table)
    for i = 1, math.floor(#table / 2) do
        local j = #table - i + 1
        table[i], table[j] = table[j], table[i]
    end

    return table
end

local function show_on_top(diags, bufnr, ns)
    local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]

    for i, diag in ipairs(diags) do
        local diag_lines = {}

        for line in diag.message:gmatch("[^\n]+") do
            table.insert(diag_lines, line)
        end
        for j, dline in ipairs(diag_lines) do
            local x = (win_info.topline - 3) + (i + j)
            if win_info.botline < x then
                return
            end
            vim.api.nvim_buf_set_extmark(bufnr, ns, x, 0, {
                virt_text = { { dline, highlight_groups[diag.severity] } },
                virt_text_pos = "right_align",
                virt_lines_above = true,
            })
        end
    end

end

local function show_on_bottom(diags, bufnr, ns)
    local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]
    diags = reverse_table(diags)

    for i, diag in ipairs(diags) do
        local diag_lines = {}

        for line in diag.message:gmatch("[^\n]+") do
            table.insert(diag_lines, line)
        end
        for j, dline in ipairs(diag_lines) do
            local x = (win_info.botline) - (i + j)
            if win_info.topline > x then
                return
            end
            vim.api.nvim_buf_set_extmark(bufnr, ns, x, 0, {
                virt_text = { { dline, highlight_groups[diag.severity] } },
                virt_text_pos = "right_align",
                virt_lines_above = true,
            })
        end
    end

end

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

    if _config.position == "top" then
        show_on_top(line_diagnostics, bufnr, namespace)
    elseif _config.position == "bottom" then
        show_on_bottom(line_diagnostics, bufnr, namespace)
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

M.setup = function(conf)
    conf = conf or {}
    if conf.position then
        if conf.position ~= 'top' and conf.position ~= 'bottom' then
            error(string.format("trld.nvim: Expected position to be 'top' or 'bottom', got '%s'", conf.position))
        end

        _config.position = conf.position
    else
        _config.position = 'top'
    end

    vim.diagnostic.config({
        virtual_text = false,
    })

    vim.cmd [[ autocmd! CursorHold,CursorHoldI * lua PrintDiagnostics() ]]
    vim.cmd [[ autocmd! CursorMoved,CursorMovedI * lua HideDiagnostics() ]]
end

return M
