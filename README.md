# trld.nvim

Plugin to display neovim line diagnostics on top right conrner with new line

## Demo


https://user-images.githubusercontent.com/23612580/164959572-4ab5adad-eed4-46ed-b011-c75700688dfa.mp4


## Installation

```lua
-- Packer:
use ({
    'Mofiqul/trld.nvim',
    config = function()
        require('trld').setup({position = 'top'}) -- position: 'top' | 'bottom', default 'top'
    end
})
```




