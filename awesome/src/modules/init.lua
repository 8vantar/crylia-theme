--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")

awful.screen.connect_for_each_screen(
-- For each screen this function is called once
-- If you want to change the modules per screen use the indices
-- e.g. 1 would be the primary screen and 2 the secondary screen.
  function(s)
    -- Create 9 tags
    awful.layout.layouts = user_vars.layouts
    awful.tag(
      { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
      s,
      user_vars.layouts[1]
    )

    require("src.modules.powermenu")(s)
    require("src.modules.volume_osd")(s)
    require("src.modules.brightness_osd")(s)
    require("src.modules.titlebar")
    require("src.modules.volume_controller")(s)
    require("src.modules.crylia_bar.init")(s)
    require("src.modules.notification-center.init")(s)
  end
)
