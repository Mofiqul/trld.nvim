# trld.nvim

Plugin to display neovim line diagnostics on top right conrner with new line

## Demo


https://user-images.githubusercontent.com/23612580/164959572-4ab5adad-eed4-46ed-b011-c75700688dfa.mp4


## Installation

```lua
-- Packer:
use {'Mofiqul/trld.nvim'}
```


## Configuration
```lua
  require('trld').setup {
    -- where to render the diagnostics. 'top' | 'bottom'
    position = 'top',

    -- if this plugin should execute it's builtin auto commands
    auto_cmds = true,

    -- diagnostics highlight group names
    highlights = {
        error = "DiagnosticFloatingError",
        warn =  "DiagnosticFloatingWarn",
        info =  "DiagnosticFloatingInfo",
        hint =  "DiagnosticFloatingHint",
    },

    -- diagnostics formatter. must return
    -- {
    --   {{ "String", "Highlight Group Name"}},
    --   {{ "String", "Highlight Group Name"}},
    --   {{ "String", "Highlight Group Name"}},
    --   ...
    -- }
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
```

### You should also disable the neovim default diagnostics virtual text in your config

```lua
vim.diagnostic.config({ virtual_text = false })
``` 
