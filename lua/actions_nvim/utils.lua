-- This file was taken from jedrzejboczar/toggletasks.nvim. Luckily, it's MIT,
-- so it's allowed to be here.
-- Some modifications have been done of course.

-- From toggletasks.nvim's utils
local function get_work_dirs(win)
    win = win or vim.api.nvim_get_current_win()
    return {
        win = vim.fn.getcwd(win),
        tab = vim.fn.getcwd( -1, vim.api.nvim_tabpage_get_number(vim.api.nvim_win_get_tabpage(win))),
        global = vim.fn.getcwd( -1, -1),
        -- lsp = M.get_lsp_roots(vim.api.nvim_win_get_buf(win)),
    }
end

local function get_win_cursor(win)
    local l, c = unpack(vim.api.nvim_win_get_cursor(win))
    return {
        line = l,
        column = c,
    }
end

-- From toggletasks.nvim's task
-- Expand "${something}" but not "$${something}"
local function expand_vars(s, handler)
    local parts = {}
    local start = 0
    while true do
        local left = s:find("%${", start + 1)
        -- No next expansion - add remaining string and break
        if left == nil then
            table.insert(parts, s:sub(start + 1))
            break
        end

        local prev_char = s:sub(left - 1, left - 1)
        -- If user escaped the expansion ("$${...}") than replace $$ with $
        if prev_char == "$" then
            -- "string $${escaped}"
            -- +-------+ +--------
            --  insert   start
            table.insert(parts, s:sub(start + 1, left - 1))
            start = left
        else
            -- Unescaped expansion, first insert text before
            table.insert(parts, s:sub(start + 1, left - 1))

            -- Find expansion end
            local right = s:find("}", left + 2)
            if not right then
                -- Avoid assertion by returning unescaped value
                -- utils.error('Missing closing bracket when expanding: "%s"', s)
                return s
            end

            -- Expand
            local inner = s:sub(left + 2, right - 1)
            local expansion = handler(inner)
            if not expansion then
                expansion = ""
                -- utils.warn('Unknown expansion variable "%s"', inner)
            end
            table.insert(parts, expansion)
            start = right
        end
    end
    -- utils.debug('expand_vars: "%s" -> %s', s, vim.inspect(parts))
    return table.concat(parts, "")
end

-- Expand environmental variables and special task-related variables in a string.
-- Requires explicit syntax with curly braces, e.g. "${VAR}".
-- Can be escaped via "$$", e.g. "$${VAR}" will be expanded to "${VAR}".
-- Supports fnamemodify modifiers e.g. "${VAR:t:r}" (see |filename-modifiers|).
local function expand_cmd(str, win, opts)
    opts = vim.tbl_extend("force", {
        env = true,
    }, opts or {})

    win = win or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local filename = vim.api.nvim_buf_get_name(buf)

    local dirs = get_work_dirs(win)
    local line = get_win_cursor(win)

    local vars = {
        -- Expands to directory of config file if exists
        -- config_dir = self.config_file and Path:new(self.config_file):parent():absolute(),
        -- Expands to root directory of LSP client with highest priority
        -- lsp_root = dirs.lsp and dirs.lsp[1],
        -- Expand vim cwd types
        win_cwd = dirs.win,
        tab_cwd = dirs.tab,
        global_cwd = dirs.global,
        -- Expand line info
        cursor_line = line.line,
        cursor_column = line.column,
        -- Expand current file
        file = vim.fn.fnamemodify(filename, ":p"),
        -- Leave for backwards compatibility, though these can be achieved by e.g. "${file:p:t}"
        file_ext = vim.fn.fnamemodify(filename, ":e"),
        file_tail = vim.fn.fnamemodify(filename, ":p:t"),
        file_head = vim.fn.fnamemodify(filename, ":p:h"),
    }

    local expand = function(var)
        -- Check filename modifiers
        local colon = var:find(":")
        local mods
        if colon then
            mods = var:sub(colon)
            var = var:sub(1, colon - 1)
        end

        -- Expand special variables
        local s = vars[var]
        -- Expand environmental variables
        if not s and opts.env then
            s = vim.fn.environ()[var]
        end

        -- Apply modifiers
        if mods then
            s = vim.fn.fnamemodify(s, mods)
        end

        return s
    end

    return expand_vars(str, expand)
end

M = {}
M.expand_cmd = expand_cmd
return M

-- local win = vim.api.nvim_get_current_win()
-- local result = expand_cmd("echo ${file}", win, { env = false })
-- print(result)
