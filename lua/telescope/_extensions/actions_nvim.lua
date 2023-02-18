return require("telescope").register_extension({
  setup = function(opts)
    return opts
  end,
  exports = {
    actions_nvim = require("actions_nvim").run,
  },
})
