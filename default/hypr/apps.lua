-- App-specific tweaks loader.
-- This is called from windows.lua via require_all; individual app files live in apps/.

local paths     = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

require_all.files(paths.archer_path .. "/default/hypr/apps", "default.hypr.apps")
