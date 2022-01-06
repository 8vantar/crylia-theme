local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local color = require('theme.crylia.colors')

local list_update = function (widget, buttons, label, data, objects)
	widget:reset()
	for i, object in ipairs(objects) do
		local task_widget = wibox.widget{
			{
				{
					{
						{
							nil,
							{
								id = "icon",
								resize = true,
								widget = wibox.widget.imagebox
							},
							nil,
							layout = wibox.layout.align.horizontal,
							id = "layout_icon"
						},
						forced_width = dpi(33),
						margins = dpi(3),
						widget = wibox.container.margin,
						id = "margin"
					},
					{
						text = "",
						align = "center",
						valign = "center",
						visible = true,
						widget = wibox.widget.textbox,
						id = "title"
					},
					layout = wibox.layout.fixed.horizontal,
					id = "layout_it"
				},
				right = dpi(5),
				left = dpi(5),
				widget = wibox.container.margin,
				id = "container"
			},
			bg = color.color["White"],
			fg = color.color["Grey900"],
			shape = function (cr, width, height)
				gears.shape.rounded_rect(cr, width, height, 5)
			end,
			widget = wibox.widget.background
		}

		local task_tool_tip = awful.tooltip{
			objects = {task_widget},
			mode = "inside",
			align = "right",
			delay_show = 1
		}

		local function create_buttons(buttons, object)
			if buttons then
				local btns = {}
				for _, b in ipairs(buttons) do
					-- Create a proxy button object: it will receive the real
					-- press and release events, and will propagate them to the
					-- button object the user provided, but with the object as
					-- argument.
					local btn = awful.button {
						modifiers = b.modifiers,
						button = b.button,
						on_press = function()
							b:emit_signal('press', object)
						end,
						on_release = function()
							b:emit_signal('release', object)
						end
					}
					btns[#btns + 1] = btn
				end
				return btns
			end
		end

		task_widget:buttons(create_buttons(buttons, object))

		local text, bg, bg_image, icon, args = label(object, task_widget.container.layout_it.title)

		if object == client.focus then
			if text == nil or text == '' then
				task_widget.container.layout_it.title:set_margins(0)
			else
				local text_full = text:match('>(.-)<')
				if text_full then
					text = object.class:sub(1,20)
					task_tool_tip:set_text(text_full)
					task_tool_tip:add_to_object(task_widget)
				else
					task_tool_tip:remove_from_object(task_widget)
				end
			end
			task_widget:set_bg(color.color["White"])
			task_widget:set_fg(color.color["Grey900"])
			task_widget.container.layout_it.title:set_text(text)
		else
			task_widget:set_bg("#3A475C")
			task_widget.container.layout_it.title:set_text('')
		end
		task_widget.container.layout_it.margin.layout_icon.icon:set_image(Get_icon("Papirus-Dark", object))
		widget:add(task_widget)
		widget:set_spacing(dpi(6))

		local old_wibox, old_cursor, old_bg
    	task_widget:connect_signal(
    	    "mouse::enter",
    	    function ()
    	        old_bg = task_widget.bg
				if object == client.focus then
                    task_widget.bg = '#dddddddd'
				else
					task_widget.bg = '#3A475Cdd'
				end
    	        local w = mouse.current_wibox
    	        if w then
    	            old_cursor, old_wibox = w.cursor, w
    	            w.cursor = "hand1"
    	        end
    	    end
    	)

    	task_widget:connect_signal(
    	    "button::press",
    	    function ()
    	        if object == client.focus then
					task_widget.bg = "#ffffffaa"
				else
					task_widget.bg = '#3A475Caa'
				end
    	    end
    	)

    	task_widget:connect_signal(
    	    "button::release",
    	    function ()
    	        if object == client.focus then
					task_widget.bg = "#ffffffdd"
				else
					task_widget.bg = '#3A475Cdd'
				end
    	    end
    	)

    	task_widget:connect_signal(
    	    "mouse::leave",
    	    function ()
    	        task_widget.bg = old_bg
    	        if old_wibox then
    	            old_wibox.cursor = old_cursor
    	            old_wibox = nil
    	        end
    	    end
    	)
	end

	if (widget.children and #widget.children or 0) == 0 then
		awesome.emit_signal("hide_centerbar", false)
	else
		awesome.emit_signal("hide_centerbar", true)
	end
	return widget
end

return function(s)
	return awful.widget.tasklist(
		s,
		awful.widget.tasklist.filter.currenttags,
		awful.util.table.join(
			awful.button(
				{},
				1,
				function(c)
					if c == client.focus then
						c.minimized = true
					else
						c.minimized = false
						if not c:isvisible() and c.first_tag then
							c.first_tag:view_only()
						end
						c:emit_signal('request::activate')
						c:raise()
					end
				end
			),
			awful.button(
				{},
				3,
				function(c)
					c:kill()
				end
			)
		),
		{},
		list_update,
		wibox.layout.fixed.horizontal()
	)
end