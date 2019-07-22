
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local lain = require("lain")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable VIM help for hotkeys widget when client with matching name is opened:
require("awful.hotkeys_popup.keys.vim")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "hyper" -- "xterm -g 80x50"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    lain.layout.centerwork,
    lain.layout.termfair.center,

    --awful.layout.suit.floating,
    awful.layout.suit.tile
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                      menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a widget and update its content using the output of a shell
-- command every 10 seconds:
local mybatterybar = wibox.widget {
    {
        min_value    = 0,
        max_value    = 100,
        value        = 50,
        paddings     = 0,
        border_width = 0,
        forced_width = 50,
        border_color = "#0000ff",
        bar_shape    = gears.shape.rounded_bar,
        id           = "mypb",
        widget       = wibox.widget.progressbar,
    },
    {
        id           = "mytb",
        -- text         = "100%",
        widget       = wibox.widget.textbox,
    },
    layout      = wibox.layout.stack,
    set_battery = function(self, val)
        val = tonumber(val)
        -- self.mytb.text  = tonumber(val).."%"
        self.mypb.value = val
        if (val < 21) then
          self.mypb.color = "#ffD008"
        end
        -- self.mypb.color = string.format("#%04x00", 65535/100*(100-val))
    end,
}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock('time %r ', 3)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                 client.focus:move_to_tag(t)
                                              end
                                 end)
)



-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)

    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    s.batterybox = awful.wibar({ position = "bottom", screen = s, ontop = true,
        height = beautiful.useless_gap, bg = beautiful.bg_normal .. '00' })
    s.batterybox:setup { layout = wibox.layout.flex.horizontal, mybatterybar }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, ontop = true,
        height = 16, width = s.geometry.width * 0.8, visible = false })
    gears.surface.apply_shape_bounding(s.mywibox,
      gears.shape.partially_rounded_rect, false, false, true, true, 3)

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- s.mytaglist,
        },
        {  -- Middle widgets container
          layout = wibox.container.place,
          {
            layout = wibox.layout.fixed.horizontal,
            s.mypromptbox,
            -- s.mytasklist,
          },
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- mykeyboardlayout,
            -- wibox.widget.systray(),
            -- mytextclock,
            -- s.mylayoutbox,
        },
    }
end)
-- }}}

function setup_as_primary_screen (s)

  w_energy_fmt = " energy %.3f Ah "
  w_energy = wibox.widget.textbox (w_energy_fmt)
  w_thermal_fmt = "thermal %d°%s rpm "
  w_thermal = wibox.widget.textbox (w_thermal_fmt)
  w_thermal:buttons (gears.table.join (awful.button ({}, 1,
    function () awful.spawn('xsensors') end
  )))
  w_freq_fmt = 'freq %.3f GHz '
  w_freq = wibox.widget.textbox (w_freq_fmt)
  w_redshift_fmt = "colour %d K "
  w_redshift = wibox.widget.textbox (w_redshift_fmt)
  w_backlight_fmt = "backlight %s"
  w_backlight = wibox.widget.textbox (w_backlight_fmt)
  function w_backlight_change(op)
    factor = 72 -- max: 937
    awful.spawn.easy_async_with_shell('echo $((`cat /sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/brightness` '..op..factor..')) | sudo tee /sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/brightness; cat /sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/brightness',
      function (stdout, stderr, exitreason, exitcode)
        w_backlight:set_text (string.format (w_backlight_fmt, stdout))
      end)
  end

  w_mpc_fmt = "%s, "
  w_mpc = wibox.widget.textbox (w_mpc_fmt)
  w_vol_fmt = "amplitute %d dB "
  w_vol = wibox.widget.textbox (w_vol_fmt)
  w_vol:buttons (gears.table.join (awful.button ({}, 1,
     function () awful.spawn('pavucontrol') end
  )))
  w_memory_fmt = "memory %d M "
  w_memory = wibox.widget.textbox (w_memory_fmt)

  gears.timer {
    timeout   = 5,
    autostart = true,
    callback  = function()
      awful.spawn.easy_async ('cat /sys/bus/acpi/drivers/battery/PNP0C0A\:00/power_supply/BAT0/charge_now',
        function (stdout, stderr, exitreason, exitcode)
          local charge = string.match (stdout, "%d+") / 100000
          w_energy:set_text (string.format (w_energy_fmt, charge))
        end
      )
      awful.spawn.easy_async ('cat /sys/bus/acpi/drivers/battery/PNP0C0A\:00/power_supply/BAT0/capacity',
        function (stdout, stderr, exitreason, exitcode)
          mybatterybar.set_battery(mybatterybar, stdout)
        end
      )
      awful.spawn.easy_async ('cat /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input',
        function (stdout, stderr, exitreason, exitcode)
          local temp = stdout / 1000 -- string.match (stdout, '%d+')
          local fan_speed_line = "" -- string.match (stdout, 'speed:%s+%d+')
          local fan_speed = "-" -- string.match (fan_speed_line, '%d+')
          w_thermal:set_text (string.format (w_thermal_fmt, temp, fan_speed))
        end
      )
      awful.spawn.easy_async (
        'sh -c "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq"',
        function (stdout, stderr, exitreason, exitcode)
          local freq_avg = 0
          for freq in string.gmatch (stdout, '%d+') do
            freq_avg = freq_avg + freq
          end
          w_freq:set_text (string.format (w_freq_fmt, freq_avg / 4 / 1000000))
        end
      )
      awful.spawn.easy_async ('cat /proc/meminfo',
      function (stdout, stderr, exitreason, exitcode)
          local line = string.match (stdout, 'MemFree:%s+%d+')
          local free = string.match (line, '%d+') / 1000
          w_memory:set_text (string.format (w_memory_fmt, free))
        end
      )
      awful.spawn.easy_async ('mpc -f %title% current',
        function (stdout, stderr, exitreason, exitcode)
          if string.len (stdout) > 0 then
            local track = string.sub (stdout, 1, -2)
            w_mpc:set_text (string.format (w_mpc_fmt, track))
          else
            w_mpc:set_text (w_mpc_fmt)
          end
        end
      )
    end
  }
  local w_redshift_running = false
  local function w_redshift_toggle()
    if w_redshift_running then
      awful.spawn('killall redshift')
      w_redshift_running = false
    else
      --awful.spawn.with_line_callback('redshift -v', {
      --  stdout = function(line)
      --    local temp = string.match(line, "%d+")
      --    w_redshift:set_text(string.format (w_redshift_fmt, temp))
      --  end
      --})
      w_redshift_running = true
    end
  end
  w_redshift:buttons(gears.table.join(
    awful.button({ }, 1, function () w_redshift_toggle() end)
  ))
  awful.spawn('killall -9 redshift')
  -- w_redshift_toggle()

  local w_vol = wibox.widget.textbox('amplitute nil ')
  function w_vol_change(param)
    awful.spawn.easy_async('amixer -c 0 set Master 3dB'..param,
      function(stdout, stderr, reason, exit_code)
        local gain = string.match(stdout, '-%d+')
        w_vol:set_text (string.format (w_vol_fmt, gain))
        naughty.notify({ preset = naughty.config.presets.normal,
                         title = "Volume",
                         text = string.format (w_vol_fmt, gain) })
      end
    )
  end
  w_vol_change('-')

  w_kblayout_cur = "us"
  w_kblayout_fmt = "layout %s "
  w_kblayout = wibox.widget.textbox (w_kblayout_fmt)
  w_kblayout:buttons (gears.table.join (awful.button ({}, 1,
    function ()
      if w_kblayout_cur == "us" then
        w_kblayout_cur = "mn"
      else
        w_kblayout_cur = "us"
      end
      awful.spawn('setxkbmap ' .. w_kblayout_cur)
      w_kblayout:set_text (string.format (w_kblayout_fmt, w_kblayout_cur))
    end
  )))

  -- Add widgets to the wibox
  s.mywibox.visible = false
  s.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
          layout = wibox.layout.fixed.horizontal,
          w_energy,
          w_thermal,
          w_freq,
          w_backlight,
          --w_redshift,
          --s.mytaglist,
      },
      {  -- Middle widgets container
        layout = wibox.container.place,
        {
          layout = wibox.layout.fixed.horizontal,
          s.mypromptbox,
          s.mytasklist,
        },
      },
      { -- Right widgets
          layout = wibox.layout.fixed.horizontal,
          -- mykeyboardlayout,
          wibox.widget.systray(),
          w_mpc,
          w_vol,
          w_kblayout,
          -- w_load,
          w_memory,
          mytextclock,
          -- s.mylayoutbox,
      },
  }
end

setup_as_primary_screen (screen.primary)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(

      awful.key({}, "XF86AudioLowerVolume", function () w_vol_change('-') end),
      awful.key({}, "XF86AudioRaiseVolume", function () w_vol_change('+') end),
      awful.key({}, "XF86AudioPlay", function () awful.spawn('mpc play') end),
      awful.key({}, "XF86AudioStop", function () awful.spawn('mpc stop') end),
      awful.key({}, "XF86MonBrightnessDown", function() w_backlight_change('-') end),
      awful.key({}, "XF86MonBrightnessUp", function () w_backlight_change('+') end),

    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { size_hints_honor = false,
                     border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.centered,
                     floating = true
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    { rule_any = {type = { "normal", "dialog" }
    -- Add titlebars to normal clients and dialogs
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- gears.surface.apply_shape_bounding(c, gears.shape.rounded_rect, 3)
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)


-- }}}
