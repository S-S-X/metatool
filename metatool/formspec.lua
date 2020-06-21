
local S = metatool.S

metatool.form = {}

-- container for form handler callback methods
metatool.form.handlers = {}

local get_formname = function(name)
	if not name then
		return
	end
	local parts = name:gsub('\\s',''):split(':')
	if #parts < 2 then
		return
	elseif parts[1] == "metatool" then
		if #parts < 3 then
			return
		end
		return name
	end
	return string.format("metatool:%s", name)
end

local has_form = function(name)
	return type(metatool.form.handlers[name]) == 'table'
end

-- Temporary storage for form data references
-- Links are created after(!) form is constructed
-- Links are destroyed after receiving fields
local formdata = {}

local global_form_handler_registered
metatool.form.register_global_handler = function()
	if not global_form_handler_registered then
		global_form_handler_registered = true
		print("metatool.form.register_global_handler Registering global formspec handler for Metatool")
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
		local playername = player:get_player_name()
		local data = formdata[playername] and formdata[playername][formname]
		-- call actual form handler
		metatool.form.handlers[formname].on_receive(player, fields, data)
		if fields.quit and formdata[playername] then
			formdata[playername][formname] = nil
		end
	end
end

metatool.form.on_create = function(player, formname, data)
	if has_form(formname) then
		-- call actual form handler
		if metatool.form.handlers[formname].on_create then
			return metatool.form.handlers[formname].on_create(player, data)
		end
		return metatool.form.handlers[formname].formspec
	end
end

-- Either on_create for dynamic formspecs or formspec for static formspecs.
-- on_create will be priorized if both defined
metatool.form.register_form = function(formname, on_create, on_receive, formspec)
	local name = get_formname(formname)
	if not name then
		print(S("metatool.form.register_form Registration failed, invalid formname: %s", formname))
		return
	end
	metatool.form.register_global_handler()
	print(S("metatool.form.register_form Registering form: %s", name))
	metatool.form.handlers[name] = {
		formspec = formspec,
		on_create = on_create,
		on_receive = on_receive,
	}
end

metatool.form.show = function(player, formname, data)
	local name = get_formname(formname)
	if has_form(name) then
		-- Construct form
		local formspec = metatool.form.on_create(player, name, data)
		if metatool.form.handlers[name].on_receive then
			-- Store temporary data ref if form input is processed somehow
			local playername = player:get_player_name()
			if not formdata[playername] then
				formdata[playername] = {}
			end
			formdata[playername][name] = data
		end
		-- Show form to player
		minetest.show_formspec(player:get_player_name(), name, formspec)
	end
end