# actions.nvim

## What is actions.nvim
Actions is a basic wrapper around telescope.nvim and toggleterm.nvim,
allowing for powerful control over all functions.

Actions mostly exists for myself, so do not expect
that it will be actively maintained.

A lot of inspiration (and code) is taken from
[toggletasks.nvim](https://github.com/jedrzejboczar/toggletasks.nvim),
so do consider that one as well.

## Basic configuration
### For packer
```lua
use {
  "yaanae/actions.nvim",
  requires = ["nvim-telescope/telescope.nvim", "akinsho/toggleterm.nvim"]
  after = "telescope.nvim",
  config = function() require("telescope").load_extension "actions_nvim" end,
}
```

### Configuration
Configuration is done with a single function. It can do anything, such as
determine what language your current buffer is.

It should then return a list of actions, which must have a `name`
(which will be displayed in telescope) and a `cmd` (which can
be a lua function or a shell command). Optionally, it can
also have the `terminal` key, which will determine it's
toggleterm instance.

```lua
require("telescope").setup {
  extensions = {
    actions_nvim = {
      get_actions = function()
        local win = vim.api.nvim_get_current_win()
        local filetype = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype")
        local actions = {
          {
            name = "Call function",
            cmd = function() vim.api.nvim_put({ "text" }, "", false, true) end,
          },
          { 
            name = "Call command in Toggleterm",
            cmd = "echo Hi!",
            terminal = 
          },
          { name = "Expand commands", cmd = "echo ${file}" },
          { name = "with filename modifiers", cmd = "echo ${file:h}"}, -- Echoes directory
          { name = "or without expansion", cmd = "echo $${file}"}, -- Echoes "${file}"
          { name = "More lua", cmd = string.format("echo %s", filetype) }
        }
        if filetype == "lua" then
          table.insert(actions, { name = "Show actions conditionally", cmd = "echo filetype==lua" }) 
        end
        return actions
      end,
    },
  },
}
```

Available options for command expansions are:

* `${win_cwd}` - Vim's window-local CWD
* `${tab_cwd}` - Vim's tab-local CWD
* `${global_cwd}` - Vim's global CWD
* `${file}` - absolute path to the current buffer's file
* `${cursor_line}` - cursor line of the current window
* `${cursor_column}` - cursor column of the current window

### Usage
The plugin provides two telescope extensions. `actions_nvim` is used to
see and run the actions.

If you use the `terminal` key in the configuration, then you can use
the telescope extension `actions_nvim_terminals`. It allows you to see
all the terminals which are currently running (or are finished running).

To access the terminals programmatically, you can do the following:
```lua
local terminals = require("actions_nvim").terminals
-- { "terminal_name" = <toggleterm terminal>, ... }
terminals["terminal_name"]:toggle()
```
