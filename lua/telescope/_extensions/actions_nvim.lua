local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local utils = require("actions_nvim.utils")

local populate = function(commands)
  -- print(vim.inspect(commands))
  local Terminal = require("toggleterm.terminal").Terminal
  local result = {}
  for _, val in ipairs(commands) do
    -- print(vim.inspect(val))
    if type(val[2]) == "string" then
      table.insert(result, {
        val[1],
        function()
          -- print("Called function")
          local win = vim.api.nvim_get_current_win()
          local term = Terminal:new({
            cmd = utils.expand_cmd(val[2], win, { env = false }),
            close_on_exit = false,
          })
          -- print(vim.inspect(term))
          term:toggle()
        end,
      })
    else
      table.insert(result, val)
    end
  end

  return result
end

-- our picker function: colors
local picker = function(opts, commands)
  opts = opts or {}
  pickers
      .new(opts, {
        prompt_title = "actions_nvim",
        finder = finders.new_table({
          results = commands,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry[1],
              ordinal = entry[1],
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            -- print(vim.inspect(selection))
            -- These curly braces are required.
            -- vim.api.nvim_put({ selection.value[1] }, "", false, true)
            selection.value[2]()
          end)
          return true
        end,
      })
      :find(require("telescope.themes").get_dropdown({}))
end

local function run(opts)
  -- print("Inspect Opts, in run")
  -- print(vim.inspect(opts))
  -- print("Inspect get_actions, in run")
  -- print(vim.inspect(get_actions))
  local config_actions = get_actions()
  -- print("Inspect get_actions return, in run")
  -- print(vim.inspect(config_actions))
  picker(opts, populate(config_actions))
end

return require("telescope").register_extension({
  setup = function(config)
    -- print("Inspect Config")
    -- print(vim.inspect(config))
    get_actions = config.get_actions
  end,
  exports = {
    actions_nvim = run,
  },
})
