# tip_of_my_buffer.nvim

`tip_of_my_buffer.nvim` is a Neovim plugin designed to automatically save your files when leaving your `tmux` pane or alt-tabbing.


## Features

- Automatically saves your buffers when certain events occur (e.g., `FocusLost`)
- Option to enable/disable saving for specific file types, filenames, modes, etc.

## Installation

### Using `lazy.nvim`

To install this plugin with `lazy.nvim`, add the following to your configuration:

```lua
{
    "claydugo/tip_of_my_buffer.nvim",
    event = "VeryLazy",
}
```

You can also customize the default (below) settings by specifying them to the setup function

```lua
{
    "claydugo/tip_of_my_buffer.nvim",
    event = "VeryLazy",
    config = function()
        require("tip_of_my_buffer").setup({
            enabled = true,
            events = { "FocusLost" },
            execution_message = "",
            conditions = {
                exclude_filename = {},
                exclude_filetype = {},
                exclude_mode = { "i", "c" },
            },
            debounce_delay_ms = 150,
        })
    end
```
