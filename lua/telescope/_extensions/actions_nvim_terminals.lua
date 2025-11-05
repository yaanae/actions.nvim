
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local utils = require("actions_nvim.utils")
local actions_nvim = require("actions_nvim")



local populate_terminals = function ()
  local result = {}
  for terminal, val in pairs(actions_nvim.terminals) do
    table.insert(result, {
      name = terminal,
      cmd = function ()
        val:toggle()
      end,
    })
  end
  return result
end



local picker_terminals = function(opts, terminals)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "actions.nvim terminals",
    finder = finders.new_table({
      results = terminals,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          selection.value.cmd()
        end
      end)
      return true
    end,
  }):find(require("telescope.themes").get_dropdown({}))
end



local function run_terminals(opts)
  picker_terminals(opts, populate_terminals())
end


return require("telescope").register_extension({
  setup = function(config) end,
  exports = {
    actions_nvim_terminals = run_terminals,
  },
})
