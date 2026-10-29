-- Work-specific config (DB connections, work commands) lives in the gitignored
-- lua/private/ since this repo is public. Returns {} when it isn't there.
return #vim.api.nvim_get_runtime_file('lua/private/init.lua', false) > 0 and require 'private' or {}
