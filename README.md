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
          { name = "Call command in Toggleterm", cmd = "echo Hi!" },
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

