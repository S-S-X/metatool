
--local S = metatool.S

metatool.form = {}

-- container for form handler callback methods
metatool.form.handlers = {}

local getformname = function(formname)
	return string.format("metatool:%s", formname)
end

local hasform = function(name)
	return type(metatool.form.handlers[name]) == 'table'
end

local global_form_handler_registered
metatool.form.register_global_handler = function()
	if not global_form_handler_registered then
		global_form_handler_registered = true
		minetest.register_on_player_receive_fields(metatool.form.on_receive)
	end
end

metatool.form.on_receive = function(player, formname, fields)
	if metatool.form.handlers[formname] == nil then
		-- form handler does not exist
		return
	end
	if not fields then
		-- No input received, do nothing
		return
	end
	if metatool.form.handlers[formname].on_receive then
		-- call actual form handler
		metatool.form.handlers[formname].on_receive(player, fields)
	end
end

metatool.form.on_create = function(player, formname, data)
	local name = getformname(formname)
	if not hasform(name) then
		return
	end
	-- call actual form handler
	if metatool.form.handlers[name].on_create then
		return metatool.form.handlers[name].on_create(player, data)
	end
	return metatool.form.handlers[name].formspec
end

-- Either on_create for dynamic formspecs or formspec for static formspecs.
-- on_create will be priorized if both defined
metatool.form.register_form = function(formname, on_create, on_receive, formspec)
	metatool.form.register_global_handler()
	local name = getformname(formname)
	metatool.form.handlers[name] = {
		formspec = formspec,
		on_create = on_create,
		on_receive = on_receive,
	}
end

metatool.form.show = function(player, formname, data)
	local name = getformname(formname)
	if not hasform(name) then
		return
	end
	local formspec = metatool.form.on_create(player, formname, data)
	minetest.show_formspec(player:get_player_name(), formname, formspec)
end
