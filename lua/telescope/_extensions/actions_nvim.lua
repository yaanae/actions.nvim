local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local utils = require("actions_nvim.utils")
local actions_nvim = require("actions_nvim")


local populate = function(commands)
  local Terminal = require("toggleterm.terminal").Terminal
  local result = {}
  for _, val in ipairs(commands) do
    if type(val.cmd) == "string" then
      table.insert(result, {
        name = val.name,
        cmd = function()
          local win = vim.api.nvim_get_current_win()
          local expanded_cmd = utils.expand_cmd(val.cmd, win, { env = false })
          local term = Terminal:new({
            cmd = expanded_cmd,
            display_name = val.name,
            close_on_exit = false,
          })
          local terminal_name = val.terminal or "actions_nvim"

          actions_nvim.terminals[terminal_name] = term

          term:toggle()
        end,
      })
    else
      table.insert(result, { name = val.name, cmd = val.cmd })
    end
  end

  return result
end


local picker = function(opts, commands)
  opts = opts or {}
  pickers
      .new(opts, {
        prompt_title = "actions.nvim",
        finder = finders.new_table({
          results = commands,
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
      })
      :find(require("telescope.themes").get_dropdown({}))
end


local function run(opts)
  local config_actions = get_actions()
  picker(opts, populate(config_actions))
end


return require("telescope").register_extension({
  setup = function(config)
    get_actions = config.get_actions
  end,
  exports = {
    actions_nvim = run,
  },
})
