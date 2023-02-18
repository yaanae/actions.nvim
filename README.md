# actions.nvim

## What is actions.nvim
Actions is a basic wrapper around telescope.nvim and toggleterm.nvim,
allowing for powerful control over all functions.

Actions mostly exists for myself, so do not expect
that it will be actively maintained.

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
        local result = {
          {
            "Call function",
            function() vim.api.nvim_put({ "text" }, "", false, true) end,
          },
          { "Call command in Toggleterm", "echo Hi!" },
        }
        if "lua" == "lua" then table.insert(result, { "Exists conditionally", "echo lua==lua" }) end
        return result
      end,
    },
  },
}
```
