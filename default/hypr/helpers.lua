-- Shared helpers for Hyprland Lua configuration.

a = a or {}

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function command_from(value, description)
  if type(value) ~= "table" then
    return value
  end

  if value.archer then
    return "launch-" .. value.archer
  elseif value.focus and value.launch then
    return a.launch_sole(value.focus, value.launch)
  elseif value.launch then
    return a.launch(value.launch)
  elseif value.webapp then
    if value.focus then
      return a.launch_webapp_sole(description, value.webapp)
    else
      return a.launch_webapp(value.webapp)
    end
  elseif value.tui then
    if value.focus then
      return "launch-or-focus-tui " .. shell_quote(value.tui)
    else
      return "launch-tui " .. shell_quote(value.tui)
    end
  end

  return value
end

function a.bind(keys, description, dispatcher, options)
  local opts = options or {}

  if description then
    opts.description = description
  end

  dispatcher = command_from(dispatcher, description)

  if type(dispatcher) == "string" then
    dispatcher = hl.dsp.exec_cmd(dispatcher)
  end

  hl.bind(keys, dispatcher, opts)
end

function a.launch(command)
  return "uwsm-app -- " .. command
end

function a.exec_on_start(command)
  hl.on("hyprland.start", function()
    hl.exec_cmd(command)
  end)
end

function a.launch_on_start(command)
  a.exec_on_start(a.launch(command))
end

function a.launch_webapp(url)
  return "launch-webapp " .. shell_quote(url)
end

function a.launch_webapp_sole(name, url)
  return "launch-or-focus-webapp " .. shell_quote(name) .. " " .. shell_quote(url)
end

function a.launch_sole(match, command)
  return "launch-or-focus " .. shell_quote(match) .. " " .. shell_quote(a.launch(command))
end

function a.bind_menu(keys, description, menu, options)
  a.bind(keys, description, menu and ("menu " .. menu) or "menu", options)
end

function a.bind_toggle(keys, description, toggle, options)
  a.bind(keys, description, "hyprland-" .. toggle .. "-toggle", options)
end

function a.notify(message)
  return "notify-send -u low " .. shell_quote(message)
end

function a.window(match, rules)
  rules.match = rules.match or {}

  if type(match) == "string" then
    rules.match.class = match
  else
    for key, value in pairs(match) do
      rules.match[key] = value
    end
  end

  hl.window_rule(rules)
end
