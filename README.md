# actions.nvim

## What is actions.nvim
Actions is a basic wrapper around telescope.nvim and toggleterm.nvim,
allowing for powerful control over all functions.

Actions mostly exists for myself, so do not expect
that it will be actively maintained.

## Simple configuration
```lua
require("actions_nvim").setup({
  get_values = function()
    local result = {
      {
        "Call function",
        function()
          vim.api.nvim_put({"text"}, "", false, true)
         end,
      },
      {"Call command in Toggleterm", "echo Hi!"},
    }
    if "lua" == "lua" do
      table.insert(result, {"Exists conditionally", "echo lua==lua"})
    end
    return result
  end
})
```
