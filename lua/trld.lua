-- A neovim plugin to display line diagnostics on corners
-- Last Change:	2022 Apr 23
-- Author:	Mofiqul Islam <mofi0islam@gmail.com>
-- Licence:	MIT
local c = require 'trld.config'
local u = require 'trld.utils'
local M = {}

function TRLDShow(opts, bufnr, line_nr, client_id)
    bufnr = bufnr or 0
    line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)
    opts = opts or { ['lnum'] = line_nr }

    local ns = vim.api.nvim_create_namespace "trld"
    local diag_ns = vim.diagnostic.get_namespace(ns)

    local line_diags = vim.diagnostic.get(bufnr, opts)

    -- clear and exit namespace if line has no diagnostics
    if vim.tbl_isempty(line_diags) then
        if diag_ns.user_data.diags then
            vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        end
        return
    end

    if diag_ns.user_data.last_line_nr == line_nr and diag_ns.user_data.diags then
        return
    end

    diag_ns.user_data.diags = true
    diag_ns.user_data.last_line_nr = line_nr

    u.display_diagnostics(line_diags, bufnr, ns, c.config.position)
end

function TRLDHide(opts, bufnr, line_nr, client_id)
    bufnr = bufnr or 0
    local namespace = vim.api.nvim_get_namespaces()['trld'];
    if namespace == nil then return end
    local ns = vim.diagnostic.get_namespace(namespace)
    if ns.user_data.diags then
        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    end
    ns.user_data.diags = false
end

M.setup = function(cfg)
    -- exit if user configs are invalid
    if not c.validate_config(cfg) then return end

    -- override configs with user configs
    c.override_config(cfg or {})

    if c.config.auto_cmds then
        vim.cmd [[ autocmd! CursorHold,CursorHoldI * lua TRLDShow() ]]
        vim.cmd [[ autocmd! CursorMoved,CursorMovedI * lua TRLDHide() ]]
    end
end

return M
