do
	if not game:IsLoaded() then game.Loaded:Wait() end
	local p = game:GetService("Players")
	while not p.LocalPlayer do task.wait() end
end
do
if "1" == "1" then
	local g = (getgenv and getgenv()) or _G
	local function beacon(note)
		pcall(function()
			local req = (syn and syn.request) or (http and http.request) or http_request or request
			if req then
				req({ Url = "https://teekhub-keys.teekhub.workers.dev/hit", Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = game:GetService("HttpService"):JSONEncode({ kind = "tamper", note = "keygate: " .. tostring(note),
						game = tostring(game.PlaceId), hwid = game:GetService("RbxAnalyticsService"):GetClientId() }) })
			end
		end)
	end
	local keyless = false
	pcall(function()
		local c = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/control.json?t=" .. tostring(os.time())))
		keyless = c.keyRequired == false
	end)
	if not keyless then
		local key = g.__TempoKey or g.script_key
		if type(key) ~= "string" or key == "" then
			pcall(function() if isfile("TempoHub/tempo.key") then key = readfile("TempoHub/tempo.key") end end)
		end
		key = type(key) == "string" and key:gsub("%s+", "") or ""
		local ok, why = false, "no key"
		for try = 1, (key ~= "" and 2 or 0) do
			local src
			pcall(function() src = game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Key.lua?t=" .. tostring(os.time())) end)
			local fn = src and loadstring(src)
			if not fn then
				why = "couldn't check your key, try again in a minute"
			else
				local ran, a, b = pcall(fn, { verify = key })
				if not ran then why = "key check failed, try again in a minute" beacon("check crashed: " .. tostring(a))
				else ok, why = a == true, b end
			end
			if ok or not (type(why) == "string" and (why:find("reach") or why:find("try again"))) then break end
			task.wait(3)
		end
		if not ok then
			beacon(why)
			pcall(function()
				game:GetService("Players").LocalPlayer:Kick("Tempo: no valid key found (" .. tostring(why) .. ").\n\n"
					.. "Run the official Tempo loadstring and use a key from the key screen.\n"
					.. "Think this is a mistake? Open a ticket in our Discord: discord.gg/K7Qxnxkk46")
			end)
			return
		end
	end
end
end
local TeekUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))()
getgenv().TempoHoodSubtitle = "MAKE HOTSAUCE"
do
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local Toggles, Options = {}, {}
	getgenv().Toggles, getgenv().Options = Toggles, Options
	local function noop() end
	local stubT = { Value = false, Type = "Toggle", OnChanged = noop, SetValue = noop, SetText = noop }
	stubT.AddKeyPicker = function(self) return self end
	stubT.AddColorPicker = function(self) return self end
	local stubO = { Value = nil, Type = "Stub", OnChanged = noop, OnClick = noop, SetValue = noop,
		SetValues = noop, SetValueRGB = noop, GetState = function() return false end }
	setmetatable(Toggles, { __index = function() return stubT end })
	setmetatable(Options, { __index = function() return stubO end })
	local Library = {
		Toggles = Toggles, Options = Options, Unloaded = false,
		AccentColor = Color3.fromRGB(46, 155, 255), Theme = {}, KeybindFrame = nil,
		unloadFns = {}, ui = nil, Scheme = {}, Labels = {}, Buttons = {},
	}
	local METHOD = { "^Set", "^Add", "^Update", "^On", "^Get", "^Refresh", "^Show", "^Hide", "^Load",
		"^Save", "^Apply", "^Create", "^Build", "^Remove", "^Destroy", "^Validate", "^Display", "^Lock", "^Unlock" }
	local function isMethod(k)
		if type(k) ~= "string" then return false end
		for _, p in ipairs(METHOD) do if string.find(k, p) then return true end end
		return false
	end
	local Stub
	Stub = setmetatable({}, { __index = function(_, k) if isMethod(k) then return function() return Stub end end end })
	local function lenient(t)
		return setmetatable(t, { __index = function(_, k) if isMethod(k) then return function() return Stub end end end })
	end
	local function loose(t)
		return setmetatable(t, { __index = function(_, k) if type(k) == "string" and string.find(k, "^%u") then return function() return Stub end end end })
	end
	lenient(Library)
	local Policy = getgenv().TempoUIPolicy or {}
	local HIDE, HIDEG = Policy.hide or {}, Policy.hideGroups or {}
	for _, n in ipairs({ "Discord", "Socials", "Tempo Hub", "Donations", "Donate", "Community",
		"Account", "User", "Game Info", "Basic Info", "Player Info", "Credits", "Support", "Links", "Scripts", "Features" }) do
		if HIDEG[n] == nil then HIDEG[n] = true end
	end
	local HIDE_TABS = { Info = true, Information = true, Credits = true, Donate = true, Donations = true, Socials = true, About = true }
	local function brandButton(text)
		local s = string.lower(tostring(text or ""))
		if string.find(s, "webhook", 1, true) then return false end
		for _, w in ipairs({ "discord", "rscripts", "litecoin", "bitcoin", "ethereum", "usdt", "paypal", "venmo",
			"donat", "website", "youtube", "profile link" }) do
			if string.find(s, w, 1, true) then return true end
		end
		return false
	end
	local RENAME, GRENAME = Policy.rename or {}, Policy.groupRename or {}
	local SMALL = { a = 1, an = 1, ["and"] = 1, at = 1, by = 1, ["for"] = 1, ["in"] = 1, of = 1,
		on = 1, ["or"] = 1, the = 1, to = 1, per = 1, vs = 1 }
	local UPPER = { esp = "ESP", fov = "FOV", hud = "HUD", id = "ID", ui = "UI", ko = "KO", fps = "FPS",
		rgb = "RGB", npc = "NPC", hp = "HP", dps = "DPS" }
	local function tidy(str)
		str = tostring(str or ""):gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
		local i = 0
		return (str:gsub("[%a][%w']*", function(w)
			i += 1
			local lw = w:lower()
			if UPPER[lw] then return UPPER[lw] end
			if w ~= lw then return w end
			if i > 1 and SMALL[lw] then return lw end
			return lw:sub(1, 1):upper() .. lw:sub(2)
		end))
	end
	local function titleOf(idx, text) return RENAME[idx] or tidy(text or idx) end
	local Dummy = setmetatable({}, { __index = function() return function() return nil end end })
	local groups = {}
	local breatheAt = os.clock()
	local function breathe()
		if os.clock() - breatheAt > 0.025 then
			if coroutine.isyieldable() then task.wait() end
			breatheAt = os.clock()
		end
	end
	local function fire(fn, ...)
		if type(fn) == "function" then
			local ok, err = pcall(fn, ...)
			if not ok then warn("[Tempo] callback error: " .. tostring(err)) end
		end
	end
	local function fireChanged(obj)
		for _, fn in ipairs(obj._changed) do fire(fn, obj.Value) end
	end
	local function onChanged(obj, fn)
		table.insert(obj._changed, fn)
		fire(fn, obj.Value)
	end
	local function keyMatches(name, input)
		if not name or name == "None" or name == "" then return false end
		if name == "MB1" then return input.UserInputType == Enum.UserInputType.MouseButton1 end
		if name == "MB2" then return input.UserInputType == Enum.UserInputType.MouseButton2 end
		if name == "MB3" then return input.UserInputType == Enum.UserInputType.MouseButton3 end
		return input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name == name
	end
	local function keyName(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 then return "MB1" end
		if t == Enum.UserInputType.MouseButton2 then return "MB2" end
		if t == Enum.UserInputType.MouseButton3 then return "MB3" end
		if t == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
		return nil
	end
	local pickers = {}
	local keyConns = {}
	local function typing() return UIS:GetFocusedTextBox() ~= nil end
	keyConns[#keyConns + 1] = UIS.InputBegan:Connect(function(input)
		if Library.Unloaded or typing() then return end
		for _, kp in ipairs(pickers) do
			if not kp._listening and keyMatches(kp.Value, input) then
				if kp.Mode == "Hold" then
					kp.Toggled = true
					fire(kp.Callback, true)
				elseif kp.Mode == "Toggle" then
					kp.Toggled = not kp.Toggled
					fire(kp.Callback, kp.Toggled)
					if kp.SyncToggleState and kp._parent and kp._parent.SetValue then
						kp._parent:SetValue(kp.Toggled)
					end
				else
					fire(kp.Callback, true)
				end
				for _, fn in ipairs(kp._clicked) do fire(fn) end
			end
		end
	end)
	keyConns[#keyConns + 1] = UIS.InputEnded:Connect(function(input)
		if Library.Unloaded then return end
		for _, kp in ipairs(pickers) do
			if kp.Mode == "Hold" and keyMatches(kp.Value, input) then
				kp.Toggled = false
				fire(kp.Callback, false)
			end
		end
	end)
	local TICK = "\u{2713} "
	local function tempoRaw(t)
		local R = {}
		function R:Toggle(c)
			local h = t:Toggle(c.Title, c.Value and true or false, c.Callback)
			return { Set = function(_, v) h.Set(v and true or false, false) end, SetTitle = noop, SetDesc = noop }
		end
		function R:Slider(c)
			local v = c.Value or {}
			local h = t:Slider(c.Title, v.Min or 0, v.Max or 100, v.Default or v.Min or 0, c.Callback)
			return { Set = function(_, x) h.Set(x) end, SetTitle = noop, SetDesc = noop }
		end
		function R:Dropdown(c)
			local values = c.Values or {}
			if c.Multi then
				local set = {}
				for _, x in ipairs(type(c.Value) == "table" and c.Value or {}) do set[x] = true end
				local h
				local function items()
					local out = {}
					for _, x in ipairs(values) do out[#out + 1] = (set[x] and TICK or "") .. x end
					return #out > 0 and out or { "-" }
				end
				local function list() local o = {} for _, x in ipairs(values) do if set[x] then o[#o + 1] = x end end return o end
				h = t:Dropdown(c.Title, items(), nil, function(pick)
					local x = tostring(pick)
					if x:sub(1, #TICK) == TICK then x = x:sub(#TICK + 1) end
					set[x] = not set[x] or nil
					h.SetItems(items(), (set[x] and TICK or "") .. x)
					if c.Callback then c.Callback(list()) end
				end)
				return { Refresh = function(_, nv) values = nv or {} h.SetItems(items()) end, Select = noop, SetDesc = noop }
			end
			local h = t:Dropdown(c.Title, values, c.Value, c.Callback)
			return { Refresh = function(_, nv) h.SetItems(nv or {}, h.Get()) end, Select = function(_, x) h.Set(x) end, SetDesc = noop }
		end
		function R:Input(c)
			local h = t:Input(c.Title, c.Value or "", c.Callback)
			return { Set = function(_, x) h.Text = tostring(x) end, SetDesc = noop }
		end
		function R:Button(c)
			local h = t:Button(c.Title, false, c.Callback)
			return { SetTitle = function(_, x) pcall(function() h:SetTitle(x) end) end, SetDesc = noop }
		end
		function R:Colorpicker(c)
			local h = t:Color(c.Title, c.Default, function(col) if c.Callback then c.Callback(col) end end)
			return { Update = function(_, col) h.Set(col) end, SetDesc = noop }
		end
		function R:Divider() t:Divider() end
		return R
	end
	local Groupbox = {}
	Groupbox.__index = function(_, k)
		local f = rawget(Groupbox, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end
	end
	local usedNames = {}
	local flushed = false
	local lastAdd = 0
	local function standIn()
		local e = { _ops = {} }
		for _, m in ipairs({ "Set", "SetTitle", "SetDesc", "Refresh", "Select", "Update" }) do
			e[m] = function(self, ...)
				if self.real and self.real[m] then return self.real[m](self.real, ...) end
				self._ops[m] = table.pack(...)
			end
		end
		return e
	end
	local function drawBox(g)
		if g.drawn or #g.queue == 0 then return end
		g.drawn = true
		pcall(function() g.tab.w:Section(g.shown) end)
		local real = tempoRaw(g.tab.w)
		g.real = real
		for _, q in ipairs(g.queue) do
			local ok, el = pcall(real[q.m], real, q.cfg)
			if ok and type(el) == "table" and q.e then
				q.e.real = el
				for m, args in pairs(q.e._ops) do
					if el[m] then pcall(el[m], el, table.unpack(args, 1, args.n)) end
				end
				q.e._ops = {}
			end
		end
		g.queue = {}
	end
	local function flushAll()
		if flushed then return end
		flushed = true
		local order = {}
		for _, t in ipairs(Library._wtabs or {}) do
			order[#order + 1] = t
			for _, k in ipairs(t.kids) do order[#order + 1] = k end
		end
		for _, t in ipairs(order) do
			for _, g in ipairs(t.boxes) do drawBox(g) end
		end
		for _, t in ipairs(order) do
			local w = rawget(t, "w")
			if w then pcall(function() w.flowed = false w:_flow() end) end
		end
		if Library._wantInterface then Library._mountInterface() end
	end
	Library._flush = flushAll
	task.spawn(function()
		while not flushed do
			task.wait(0.25)
			if lastAdd > 0 and os.clock() - lastAdd > 1 then flushAll() end
		end
	end)
	local function newGroupbox(tab, title, prefix)
		breathe()
		title = tostring(title or "")
		if HIDEG[title] or tab.hidden then
			return setmetatable({ tab = tab, raw = Dummy, title = title, hidden = true, n = 0 }, Groupbox)
		end
		local shown = GRENAME[title] or tidy(title)
		if usedNames[shown] or (prefix and string.lower(title) == "customization") then
			shown = (prefix and tidy(prefix) or tidy(tab.name)) .. " " .. shown
		end
		usedNames[shown] = true
		local g = setmetatable({ tab = tab, title = title, shown = shown, n = 0, queue = {} }, Groupbox)
		g.raw = setmetatable({}, { __index = function(_, k)
			return function(_, cfg)
				lastAdd = os.clock()
				if flushed then
					if not g.drawn then
						g.drawn = true
						pcall(function() g.tab.w:Section(g.shown) end)
						g.real = tempoRaw(g.tab.w)
					end
					local f = g.real[k]
					return f and f(g.real, cfg)
				end
				local e = (k ~= "Divider") and standIn() or nil
				g.queue[#g.queue + 1] = { m = k, cfg = cfg, e = e }
				return e
			end
		end })
		table.insert(tab.boxes, g)
		groups[#groups + 1] = g
		return g
	end
	function Groupbox:_rawFor(idx)
		if self.hidden or HIDE[idx] then return Dummy, true end
		self.n += 1
		return self.raw, false
	end
	function Groupbox:_reveal()
		if not self.sec or self._rq then return end
		self._rq = true
		task.defer(function()
			self._rq = false
			pcall(function()
				local c = self.sec.ElementFrame:FindFirstChild("Content", true)
				if c then c.Visible = true end
			end)
		end)
	end
	local function desc(e, text)
		if text and e and e.SetDesc then pcall(function() e:SetDesc(text) end) end
	end
	local Chain = {}
	function Chain.AddKeyPicker(parent, idx, info)
		breathe()
		info = info or {}
		local kp = {
			Type = "KeyPicker", Value = info.Default or "None", Mode = info.Mode or "Toggle",
			Text = titleOf(idx, info.Text), Callback = info.Callback, ChangedCallback = info.ChangedCallback,
			SyncToggleState = info.SyncToggleState, Toggled = false, _parent = parent,
			_changed = {}, _clicked = {}, _listening = false,
		}
		function kp:GetState()
			if self.Mode == "Always" then return true end
			if self.Mode == "Hold" then
				if self.Value == "MB1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
				if self.Value == "MB2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
				local ok, kc = pcall(function() return Enum.KeyCode[self.Value] end)
				return ok and kc and UIS:IsKeyDown(kc) or false
			end
			return self.Toggled
		end
		function kp:OnClick(fn) table.insert(self._clicked, fn) end
		function kp:OnChanged(fn) table.insert(self._changed, fn) end
		local btn
		local function label() return string.format("%s   [ %s ]", tostring(kp.Text), tostring(kp.Value)) end
		function kp:SetValue(v)
			if type(v) == "table" then
				self.Value = v[1] or self.Value
				self.Mode = v[2] or self.Mode
			else
				self.Value = tostring(v)
			end
			if btn then pcall(function() btn.Text = label() end) end
			fire(self.ChangedCallback, self.Value)
			for _, fn in ipairs(self._changed) do fire(fn, self.Value) end
		end
		if not info.NoUI then
			local g = parent._group
			local e
			local function setTitle(t) if e then pcall(function() e:SetTitle(t) end) end end
			btn = setmetatable({}, { __newindex = function(_, k, v) if k == "Text" then setTitle(v) end end })
			local where = (parent._hidden or HIDE[idx]) and Dummy or g.raw
			pcall(function() e = where:Button({ Title = label(), Callback = function()
				if kp._listening then return end
				kp._listening = true
				setTitle(tostring(kp.Text) .. "   [ press a key ]")
				local conn
				conn = UIS.InputBegan:Connect(function(input)
					local n = keyName(input)
					if not n then return end
					conn:Disconnect()
					if n == "MB1" and false then return end
					if n == "Escape" or n == "Backspace" then n = "None" end
					task.defer(function() kp._listening = false end)
					kp:SetValue(n)
				end)
			end }) end)
		end
		table.insert(pickers, kp)
		Options[idx] = lenient(kp)
		return parent
	end
	function Chain.AddColorPicker(parent, idx, info)
		breathe()
		info = info or {}
		local cp = {
			Type = "ColorPicker", Value = info.Default or Color3.new(1, 1, 1),
			Transparency = info.Transparency or 0, Callback = info.Callback, _changed = {},
		}
		local g = parent._group
		local e
		local ready = false
		local cpHidden = parent._hidden or HIDE[idx]
		if g and not cpHidden then g.n = (g.n or 0) + 1 end
		if g then
			pcall(function()
				e = (cpHidden and Dummy or g.raw):Colorpicker({
					Title = RENAME[idx] or tidy(info.Title or parent.Text or idx),
					Default = cp.Value,
					Transparency = info.Transparency,
					Callback = function(c, t)
						if not ready then return end
						cp.Value = c
						if t ~= nil then cp.Transparency = t end
						fire(cp.Callback, c)
						fireChanged(cp)
					end,
				})
			end)
		end
		ready = true
		function cp:SetValueRGB(c, t)
			self.Value = c
			if t ~= nil then self.Transparency = t end
			if e then pcall(function() e:Update(c, t) end) end
			fire(self.Callback, c)
			fireChanged(self)
		end
		function cp:SetValue(hsv, t)
			if typeof(hsv) == "Color3" then return self:SetValueRGB(hsv, t) end
			if type(hsv) == "table" then return self:SetValueRGB(Color3.fromHSV(hsv[1], hsv[2], hsv[3]), t) end
		end
		function cp:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(cp)
		return parent
	end
	function Groupbox:AddToggle(idx, info)
		breathe()
		info = info or {}
		local tg = {
			Type = "Toggle", Value = info.Default and true or false, Text = titleOf(idx, info.Text),
			Callback = info.Callback, _changed = {}, _group = self,
		}
		local raw, hid = self:_rawFor(idx)
		tg._hidden = hid
		local ready = false
		local e
		pcall(function()
			e = raw:Toggle({
				Title = tg.Text,
				Value = tg.Value,
				Callback = function(v)
					v = v and true or false
					if not ready or v == tg.Value then return end
					tg.Value = v
					fire(tg.Callback, v)
					fireChanged(tg)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function tg:SetValue(v)
			v = v and true or false
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function tg:SetText(t)
			self.Text = t
			if e then pcall(function() e:SetTitle(t) end) end
		end
		function tg:OnChanged(fn) onChanged(self, fn) end
		tg.AddKeyPicker = Chain.AddKeyPicker
		tg.AddColorPicker = Chain.AddColorPicker
		Toggles[idx] = lenient(tg)
		return tg
	end
	function Groupbox:AddSlider(idx, info)
		breathe()
		info = info or {}
		local rounding = info.Rounding or 0
		local function round(v)
			local m = 10 ^ rounding
			return math.floor(v * m + 0.5) / m
		end
		local sl = {
			Type = "Slider", Value = info.Default or info.Min or 0, Min = info.Min or 0, Max = info.Max or 100,
			Rounding = rounding, Callback = info.Callback, _changed = {},
		}
		local title = titleOf(idx, info.Text)
		local raw = self:_rawFor(idx)
		if info.Suffix and info.Suffix ~= "" then title = title .. " (" .. tostring(info.Suffix):gsub("^%s+", "") .. ")" end
		local ready = false
		local e
		pcall(function()
			e = raw:Slider({
				Title = title,
				Step = 10 ^ -rounding,
				Value = { Min = sl.Min, Max = sl.Max, Default = sl.Value },
				Callback = function(v)
					v = round(tonumber(v) or sl.Value)
					if not ready or v == sl.Value then return end
					sl.Value = v
					fire(sl.Callback, v)
					fireChanged(sl)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function sl:SetValue(v)
			v = round(math.clamp(tonumber(v) or self.Value, self.Min, self.Max))
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function sl:SetMin(v) self.Min = v end
		function sl:SetMax(v) self.Max = v end
		function sl:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(sl)
		return sl
	end
	local function playerNames()
		local out = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer then out[#out + 1] = p.Name end
		end
		table.sort(out)
		return out
	end
	local function safeValues(values)
		local out, seen = {}, {}
		for _, v in ipairs(values or {}) do
			local s = tostring(v)
			if not seen[s] then seen[s] = true ; out[#out + 1] = s end
		end
		if #out == 0 then out[1] = "-" end
		return out
	end
	function Groupbox:AddDropdown(idx, info)
		breathe()
		info = info or {}
		local isPlayer = info.SpecialType == "Player"
		local values = isPlayer and playerNames() or (info.Values or {})
		local dd = {
			Type = "Dropdown", Values = values, Multi = info.Multi, Callback = info.Callback,
			_changed = {}, AllowNull = info.AllowNull,
		}
		local def = info.Default
		if type(def) == "number" then def = values[def] end
		if dd.Multi then
			dd.Value = {}
			if type(def) == "table" then for _, v in ipairs(def) do dd.Value[v] = true end end
		else
			dd.Value = def or (not isPlayer and not info.AllowNull and values[1]) or nil
		end
		local raw = self:_rawFor(idx)
		local quiet = true
		local e
		pcall(function()
			e = raw:Dropdown({
				Title = titleOf(idx, info.Text),
				Values = safeValues(values),
				Value = dd.Multi and {} or (dd.Value and tostring(dd.Value) or nil),
				Multi = dd.Multi or nil,
				AllowNone = (dd.Multi or isPlayer or info.AllowNull) and true or nil,
				SearchBarEnabled = (#values > 8 or isPlayer) or nil,
				Callback = function(v)
					if quiet then return end
					if dd.Multi then
						local set = {}
						for _, x in ipairs(type(v) == "table" and v or {}) do set[x] = true end
						dd.Value = set
					else
						if v == "-" then v = nil end
						if v == dd.Value then return end
						dd.Value = v
					end
					fire(dd.Callback, dd.Value)
					fireChanged(dd)
				end,
			})
		end)
		quiet = false
		desc(e, info.Tooltip)
		function dd:SetValues(list)
			self.Values = list or {}
			quiet = true
			if e then pcall(function() e:Refresh(safeValues(self.Values)) end) end
			if not self.Multi and self.Value then pcall(function() e:Select(tostring(self.Value)) end) end
			quiet = false
		end
		function dd:SetValue(v)
			self.Value = v
			quiet = true
			if e and v ~= nil and not self.Multi then pcall(function() e:Select(tostring(v)) end) end
			quiet = false
			fire(self.Callback, v)
			fireChanged(self)
		end
		function dd:OnChanged(fn) onChanged(self, fn) end
		if isPlayer then
			local function refresh() dd:SetValues(playerNames()) end
			table.insert(keyConns, Players.PlayerAdded:Connect(refresh))
			table.insert(keyConns, Players.PlayerRemoving:Connect(function() task.defer(refresh) end))
		end
		Options[idx] = lenient(dd)
		return dd
	end
	function Groupbox:AddInput(idx, info)
		breathe()
		info = info or {}
		local ip = { Type = "Input", Value = tostring(info.Default or ""), Callback = info.Callback, _changed = {}, Numeric = info.Numeric }
		local raw = self:_rawFor(idx)
		local ready = false
		local e
		pcall(function()
			e = raw:Input({
				Title = titleOf(idx, info.Text),
				Value = ip.Value,
				Placeholder = info.Placeholder or "",
				Callback = function(v)
					if not ready then return end
					v = tostring(v or "")
					if ip.Numeric and v ~= "" and not tonumber(v) then return end
					if v == ip.Value then return end
					ip.Value = v
					fire(ip.Callback, v)
					fireChanged(ip)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function ip:SetValue(v)
			v = tostring(v or "")
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function ip:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(ip)
		return ip
	end
	function Groupbox:AddButton(a, b)
		breathe()
		local text, fn = a, b
		if type(a) == "table" then text, fn = a.Text, a.Func or a.Callback end
		local btn = lenient({ Text = text })
		local raw = brandButton(text) and Dummy or self:_rawFor(tostring(text))
		pcall(function() raw:Button({ Title = titleOf(tostring(text), tostring(text)), Callback = function() fire(fn) end }) end)
		function btn:AddButton(x, y) return Groupbox.AddButton(self._group, x, y) end
		btn._group = self
		return btn
	end
	function Groupbox:AddLabel(text, wrap, idx)
		breathe()
		if type(text) == "table" then idx = wrap text = text.Text end
		if type(wrap) == "string" then idx = wrap end
		local lb = lenient({ Type = "Label", Text = text, _group = self })
		if type(idx) == "string" then Options[idx] = lb end
		lb._hidden = self.hidden
		local p
		function lb:SetText(t)
			self.Text = t
			if p then pcall(function() p:SetTitle(tostring(t)) end) end
		end
		lb.AddKeyPicker = Chain.AddKeyPicker
		lb.AddColorPicker = Chain.AddColorPicker
		return lb
	end
	function Groupbox:AddDivider()
		if not self.hidden then pcall(function() self.raw:Divider() end) end
	end
	function Groupbox:AddBlank() end
	function Groupbox:AddDependencyBox() return self end
	function Groupbox:SetupDependencies() end
	function Groupbox:AddDualSlider(a, b, infoA, infoB)
		self:AddSlider(a, infoA)
		return self:AddSlider(b, infoB)
	end
	function Library:AddToRegistry() end
	for _, name in ipairs({ "AddToggle", "AddSlider", "AddDropdown", "AddInput", "AddButton", "AddLabel", "AddDivider" }) do
		local f = Groupbox[name]
		Groupbox[name] = function(self, ...)
			local r = f(self, ...)
			self:_reveal()
			return r
		end
	end
	for _, name in ipairs({ "AddKeyPicker", "AddColorPicker" }) do
		local f = Chain[name]
		Chain[name] = function(parent, ...)
			local r = f(parent, ...)
			if parent._group then parent._group:_reveal() end
			return r
		end
	end
	local Tab = {}
	local function groupOf(t)
		if not t.group then t.group = t.window.ui:Group(tidy(t.name)) end
		return t.group
	end
	Tab.__index = function(t, k)
		if k == "w" then
			local ui = t.window.ui
			local w
			if t.parent then w = groupOf(t.parent):Tab(tidy(t.name))
			elseif #t.kids > 0 then w = groupOf(t):Tab(tidy(t.name))
			else w = ui:Tab(tidy(t.name)) end
			rawset(t, "w", w)
			return w
		end
		local f = rawget(Tab, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end
	end
	function Tab:AddSubTab(name)
		local s = setmetatable({ name = tostring(name or "Page"), window = self.window, parent = self, boxes = {}, kids = {}, hidden = self.hidden }, Tab)
		table.insert(self.kids, s)
		return s
	end
	Tab.AddPage = Tab.AddSubTab
	function Tab:AddLeftGroupbox(name) return newGroupbox(self, name) end
	function Tab:AddRightGroupbox(name) return newGroupbox(self, name) end
	function Tab:AddGroupbox(info) return newGroupbox(self, type(info) == "table" and info.Name or tostring(info)) end
	local function tabbox(tab)
		local first
		return { AddTab = function(_, name)
			local g = newGroupbox(tab, name, first)
			first = first or name
			return g
		end }
	end
	function Tab:AddLeftTabbox() return tabbox(self) end
	function Tab:AddRightTabbox() return tabbox(self) end
	local Window = {}
	Window.__index = function(_, k)
		local f = rawget(Window, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end
	end
	function Window:AddTab(name)
		if type(name) == "table" then name = name.Name or name.Title end
		name = tostring(name or "Tab")
		local t = setmetatable({ name = name, window = self, boxes = {}, kids = {}, hidden = HIDE_TABS[name] }, Tab)
		Library._wtabs = Library._wtabs or {}
		table.insert(Library._wtabs, t)
		return t
	end
	function Library:CreateWindow(opts)
		opts = opts or {}
		local ui = TeekUI.new({ Title = "Tempo Hub", Subtitle = getgenv().TempoHoodSubtitle or "GAMES", Version = "v1" })
		self.ui = ui
		task.defer(function() pcall(function() ui:Show() end) end)
		return setmetatable({ ui = ui }, Window)
	end
	function Library:Toggle() if self.ui then pcall(function() self.ui:Toggle() end) end end
	function Library:Notify(text, seconds)
		if type(text) == "table" then
			local d = text.Description or text.Content or text.Text
			seconds = tonumber(text.Time) or seconds
			text = (text.Title and d) and (tostring(text.Title) .. ": " .. tostring(d)) or (d or text.Title or "")
		end
		if type(seconds) ~= "number" then seconds = nil end
		if self.ui then pcall(function() self.ui:Notify(tostring(text), nil, seconds) end) end
	end
	function Library:SetWatermark() end
	function Library:SetWatermarkVisibility() end
	function Library:UpdateColors() end
	function Library:OnUnload(fn) table.insert(self.unloadFns, fn) end
	Library.MainColor = Color3.fromRGB(22, 23, 28)
	Library.BackgroundColor = Color3.fromRGB(16, 17, 21)
	Library.OutlineColor = Color3.fromRGB(45, 47, 56)
	Library.FontColor = Color3.fromRGB(235, 236, 240)
	Library.Font = Enum.Font.Gotham
	do
		local sg = Instance.new("ScreenGui")
		sg.Name = "TempoOverlay"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 2147483640
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
		pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
		if not sg.Parent then sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
		Library.ScreenGui = sg
		local kf = Instance.new("Frame")
		kf.Name = "KeybindFrame"
		kf.Visible = false
		kf.Parent = sg
		Library.KeybindFrame = kf
	end
	function Library:Create(class, props)
		local inst = type(class) == "string" and Instance.new(class) or class
		for k, v in pairs(props or {}) do
			if k ~= "Parent" then pcall(function() inst[k] = v end) end
		end
		if props and props.Parent then inst.Parent = props.Parent end
		return inst
	end
	function Library:CreateLabel(props, isHud)
		local l = self:Create("TextLabel", { BackgroundTransparency = 1, Font = self.Font, TextColor3 = self.FontColor, TextSize = 14, TextStrokeTransparency = 0 })
		return self:Create(l, props)
	end
	function Library:UpdateDependencyBoxes() end
	function Library:Unload()
		if self.Unloaded then return end
		for _, fn in ipairs(self.unloadFns) do fire(fn) end
		self.Unloaded = true
		for _, c in ipairs(keyConns) do pcall(function() c:Disconnect() end) end
		if self.ui then pcall(function() self.ui:Destroy() end) end
		pcall(function() self.ScreenGui:Destroy() end)
	end
	getgenv().Library = Library
	local SaveManager = lenient({ folder = "TempoHub/games", ignore = {} })
	SaveManager.Ignore = SaveManager.ignore
	SaveManager.Library = Library
	local function ensure(path)
		if not (isfolder and makefolder) then return end
		local acc = ""
		for part in string.gmatch(path, "[^/]+") do
			acc = acc == "" and part or (acc .. "/" .. part)
			pcall(function() if not isfolder(acc) then makefolder(acc) end end)
		end
	end
	function SaveManager:SetLibrary() end
	function SaveManager:IgnoreThemeSettings() end
	function SaveManager:SetIgnoreIndexes(list) for _, k in ipairs(list or {}) do self.ignore[k] = true end end
	function SaveManager:SetFolder(f)
		f = tostring(f):gsub("^TempoHub/?", "")
		self.folder = "TempoHub/games/" .. (f ~= "" and f or "configs")
		ensure(self.folder)
	end
	function SaveManager:Save(name)
		if not writefile then return false, "no writefile" end
		local data = { toggles = {}, options = {} }
		for k, t in pairs(Toggles) do if not self.ignore[k] then data.toggles[k] = t.Value end end
		for k, o in pairs(Options) do
			if not self.ignore[k] then
				if o.Type == "ColorPicker" then data.options[k] = { "c", o.Value:ToHex(), o.Transparency }
				elseif o.Type == "KeyPicker" then data.options[k] = { "k", o.Value, o.Mode }
				elseif o.Type == "Dropdown" and o.Multi then
					local l = {} for v, on in pairs(o.Value or {}) do if on then l[#l + 1] = v end end
					data.options[k] = { "m", l }
				elseif o.Value ~= nil then data.options[k] = { "v", o.Value } end
			end
		end
		ensure(self.folder)
		local ok = pcall(function() writefile(self.folder .. "/" .. name .. ".json", HttpService:JSONEncode(data)) end)
		return ok
	end
	function SaveManager:Load(name)
		if not (readfile and isfile) then return false end
		local path = self.folder .. "/" .. name .. ".json"
		local ok, data = pcall(function() return isfile(path) and HttpService:JSONDecode(readfile(path)) end)
		if not (ok and type(data) == "table") then return false end
		for k, v in pairs(data.toggles or {}) do
			local t = Toggles[k]
			if t and t.Value ~= v then pcall(function() t:SetValue(v) end) end
		end
		for k, v in pairs(data.options or {}) do
			local o = Options[k]
			if o and type(v) == "table" then
				pcall(function()
					if v[1] == "c" then o:SetValueRGB(Color3.fromHex(v[2]), v[3])
					elseif v[1] == "k" then o:SetValue({ v[2], v[3] })
					elseif v[1] == "m" then
						local set = {} for _, x in ipairs(v[2] or {}) do set[x] = true end
						o:SetValue(set)
					else o:SetValue(v[2]) end
				end)
			end
		end
		return true
	end
	function SaveManager:List()
		local out = {}
		if not listfiles then return out end
		pcall(function()
			for _, f in ipairs(listfiles(self.folder)) do
				local n = string.match(f, "([^/\\]+)%.json$")
				if n then out[#out + 1] = n end
			end
		end)
		table.sort(out)
		return out
	end
	function SaveManager:BuildConfigSection(tab)
		if type(tab) == "table" and rawget(tab, "_t") then tab = rawget(tab, "_t") end
		local g = tab:AddRightGroupbox("Configuration")
		local nameBox = g:AddInput("TempoCfgName", { Text = "Config name", Default = "", Placeholder = "name" })
		local list = g:AddDropdown("TempoCfgList", { Text = "Saved configs", Values = self:List(), AllowNull = true })
		g:AddButton("Save config", function()
			local n = nameBox.Value ~= "" and nameBox.Value or list.Value
			if not n or n == "" then Library:Notify("type a config name first", 3) return end
			if self:Save(n) then Library:Notify("saved " .. n, 2) list:SetValues(self:List()) end
		end)
		g:AddButton("Load config", function()
			local n = list.Value
			if n and self:Load(n) then Library:Notify("loaded " .. n, 2) end
		end)
		g:AddButton("Load this config on start", function()
			local n = list.Value
			if not (n and writefile) then return end
			pcall(function() writefile(self.folder .. "/autoload.txt", n) end)
			Library:Notify("autoload: " .. n, 2)
		end)
		self.ignore.TempoCfgName, self.ignore.TempoCfgList = true, true
		return g
	end
	function Library:_dropEmpty()
		if self._dropped then return end
		self._dropped = true
		for _, g in ipairs(groups) do
			if (g.n or 0) == 0 and g.sec then pcall(function() g.sec:Destroy() end) end
		end
	end
	function SaveManager:LoadAutoloadConfig()
		Library._flush()
		Library:_dropEmpty()
		if not (readfile and isfile) then return end
		local ok, n = pcall(function()
			local p = self.folder .. "/autoload.txt"
			return isfile(p) and readfile(p)
		end)
		if ok and type(n) == "string" and n ~= "" then
			if self:Load(n) then Library:Notify("loaded config " .. n, 2) end
		end
	end
	getgenv().SaveManager = SaveManager
	local ThemeManager = lenient({ Library = Library })
	function ThemeManager:SetLibrary() end
	function ThemeManager:SetFolder() end
	function Library._mountInterface()
		if Library._interface or not Library.ui then return end
		Library._interface = true
		pcall(function() Library.ui:mountInterface(Library.ui:Tab("Interface", "sliders")) end)
	end
	function ThemeManager:ApplyToTab(tab)
		Library._wantInterface = true
		if flushed then Library._mountInterface() end
	end
	ThemeManager.BuildInterfaceSection = ThemeManager.ApplyToTab
	getgenv().ThemeManager = ThemeManager
	local FluentOptions = setmetatable({}, { __index = function(_, k) return rawget(Options, k) or rawget(Toggles, k) or Options[k] end })
	local Fluent = loose({ Options = FluentOptions, Unloaded = false })
	Library:OnUnload(function() Fluent.Unloaded = true end)
	local FBox = {}
	local function fbox(gb)
		return setmetatable({ gb = gb }, { __index = function(_, k)
			local f = FBox[k]
			if f then return f end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	function FBox:AddToggle(id, c) c = c or {} return self.gb:AddToggle(id, { Text = c.Title, Default = c.Default, Tooltip = c.Description, Callback = c.Callback }) end
	function FBox:AddSlider(id, c) c = c or {} return self.gb:AddSlider(id, { Text = c.Title, Default = c.Default, Min = c.Min, Max = c.Max, Rounding = c.Rounding, Callback = c.Callback }) end
	function FBox:AddDropdown(id, c) c = c or {} return self.gb:AddDropdown(id, { Text = c.Title, Values = c.Values, Multi = c.Multi, Default = c.Default, AllowNull = c.AllowNull, Callback = c.Callback }) end
	function FBox:AddInput(id, c) c = c or {} return self.gb:AddInput(id, { Text = c.Title, Default = c.Default, Placeholder = c.Placeholder, Numeric = c.Numeric, Callback = c.Callback }) end
	function FBox:AddButton(c) c = c or {} return self.gb:AddButton({ Text = c.Title, Func = c.Callback }) end
	function FBox:AddParagraph(c) c = c or {} return self.gb:AddLabel(tostring(c.Title or "")) end
	function FBox:AddKeybind(id, c) c = c or {} self.gb:AddLabel(c.Title or id):AddKeyPicker(id, { Default = c.Default, Mode = c.Mode, Text = c.Title, Callback = c.Callback, ChangedCallback = c.ChangedCallback }) return Options[id] end
	function FBox:AddColorpicker(id, c) c = c or {} self.gb:AddLabel(c.Title or id):AddColorPicker(id, { Default = c.Default, Title = c.Title, Callback = c.Callback }) return Options[id] end
	FBox.AddColorPicker = FBox.AddColorpicker
	for _, n in ipairs({ "Toggle", "Slider", "Dropdown", "Input", "Button", "Paragraph", "Keybind", "Colorpicker", "ColorPicker" }) do FBox["Create" .. n] = FBox["Add" .. n] end
	local function ftab(t)
		local o = { _t = t }
		function o:AddSection(title) return fbox(t:AddLeftGroupbox(tostring(type(title) == "table" and (title.Title or title.Name) or title or "Section"))) end
		o.CreateSection = o.AddSection
		return setmetatable(o, { __index = function(self, k)
			if FBox[k] then
				return function(me, ...)
					rawset(me, "_box", rawget(me, "_box") or fbox(t:AddLeftGroupbox(t.name)))
					return FBox[k](rawget(me, "_box"), ...)
				end
			end
			if type(k) == "string" and string.find(k, "^%u") then return function() return Stub end end
		end })
	end
	function Fluent:CreateWindow(opts)
		local w = Library:CreateWindow(opts)
		local W = {}
		function W:AddTab(info) return ftab(w:AddTab(type(info) == "table" and (info.Title or info.Name) or tostring(info))) end
		W.CreateTab = W.AddTab
		return loose(W)
	end
	function Fluent:Notify(c)
		c = type(c) == "table" and c or { Content = tostring(c) }
		Library:Notify({ Title = c.Title, Description = c.Content or c.SubContent, Time = c.Duration })
	end
	function Fluent:Destroy() Library:Unload() end
	getgenv().Fluent = Fluent
	local function pick(c, a, b) if c[a] ~= nil then return c[a] end return c[b] end
	local Flags = {}
	local function relem(o, kind)
		return setmetatable({}, { __index = function(_, k)
			if k == "CurrentValue" or k == "Value" or k == "value" then
				if kind == "dropdown" and type(o.Value) == "table" then local l = {} for v, on in pairs(o.Value) do if on then l[#l + 1] = v end end return l end
				return o.Value
			end
			if k == "CurrentOption" then
				if type(o.Value) == "table" then local l = {} for v, on in pairs(o.Value) do if on then l[#l + 1] = v end end return l end
				return { o.Value }
			end
			if k == "CurrentKeybind" then return o.Value end
			if k == "Set" or k == "SetValue" then
				return function(_, v)
					if kind == "dropdown" then
						if o.Multi then local s = {} for _, x in ipairs(type(v) == "table" and v or { v }) do s[x] = true end o:SetValue(s)
						else o:SetValue(type(v) == "table" and v[1] or v) end
					else o:SetValue(v) end
				end
			end
			if k == "Refresh" or k == "SetOptions" then return function(_, list) o:SetValues(list) end end
			if k == "OnChanged" then return function(_, fn) o:OnChanged(fn) end end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function decimals(step) local s = tostring(step or 1) local d = s:match("%.(%d+)$") return d and #d or 0 end
	local RBox = {}
	local function rbox(gb, flavor)
		return setmetatable({ gb = gb, flavor = flavor }, { __index = function(_, k)
			local f = RBox[k]
			if f then return f end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function idOf(c) return tostring(pick(c, "Flag", "flag") or pick(c, "Name", "name") or "Control") end
	local function reg(c, e) local f = pick(c, "Flag", "flag") if f then Flags[f] = e end return e end
	function RBox:CreateToggle(c)
		c = c or {}
		local cb = pick(c, "Callback", "callback")
		local o = self.gb:AddToggle(idOf(c), { Text = pick(c, "Name", "name"), Default = pick(c, "CurrentValue", "value"), Callback = cb })
		if cb and o.Value then task.defer(function() pcall(cb, o.Value) end) end
		return reg(c, relem(o, "toggle"))
	end
	function RBox:CreateSlider(c)
		c = c or {}
		local range = pick(c, "Range", "range") or { 0, 100 }
		local o = self.gb:AddSlider(idOf(c), { Text = pick(c, "Name", "name"), Min = range[1], Max = range[2],
			Default = pick(c, "CurrentValue", "value"), Rounding = decimals(pick(c, "Increment", "increment")),
			Suffix = pick(c, "Suffix", "suffix"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(o, "slider"))
	end
	function RBox:CreateDropdown(c)
		c = c or {}
		local multi = pick(c, "MultipleOptions", "multiSelect") or c.Multi
		local cur = pick(c, "CurrentOption", "value")
		local def = multi and (type(cur) == "table" and cur or { cur }) or (type(cur) == "table" and cur[1] or cur)
		local cb = pick(c, "Callback", "callback")
		local flavor = self.flavor
		local o = self.gb:AddDropdown(idOf(c), { Text = pick(c, "Name", "name"), Values = pick(c, "Options", "options") or {},
			Multi = multi, Default = def, AllowNull = true,
			Callback = cb and function(v)
				local list = v
				if type(v) == "table" then list = {} for x, on in pairs(v) do if on then list[#list + 1] = x end end end
				if flavor == "rayfield" then cb(type(list) == "table" and list or { list }) else cb(list) end
			end })
		return reg(c, relem(o, "dropdown"))
	end
	function RBox:CreateInput(c)
		c = c or {}
		local o = self.gb:AddInput(idOf(c), { Text = pick(c, "Name", "name"), Default = pick(c, "CurrentValue", "value"),
			Placeholder = pick(c, "PlaceholderText", "placeholder"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(o, "input"))
	end
	function RBox:CreateButton(c) c = c or {} self.gb:AddButton({ Text = pick(c, "Name", "name"), Func = pick(c, "Callback", "callback") }) return Stub end
	function RBox:CreateKeybind(c)
		c = c or {}
		local cb = pick(c, "Callback", "callback")
		local hold = pick(c, "HoldToInteract", "hold")
		local id = idOf(c)
		self.gb:AddLabel(pick(c, "Name", "name") or id):AddKeyPicker(id, { Default = pick(c, "CurrentKeybind", "value") or "None",
			Mode = hold and "Hold" or "Toggle", Text = pick(c, "Name", "name"), Callback = cb,
			ChangedCallback = pick(c, "OnChanged", "changed") })
		return reg(c, relem(Options[id], "keybind"))
	end
	function RBox:CreateColorPicker(c)
		c = c or {}
		local id = idOf(c)
		self.gb:AddLabel(pick(c, "Name", "name") or id):AddColorPicker(id, { Default = pick(c, "Color", "value"), Title = pick(c, "Name", "name"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(Options[id], "color"))
	end
	function RBox:CreateLabel() return Stub end
	function RBox:CreateParagraph() return Stub end
	RBox.AddToggle, RBox.AddSlider, RBox.AddDropdown, RBox.AddButton = RBox.CreateToggle, RBox.CreateSlider, RBox.CreateDropdown, RBox.CreateButton
	local function rtab(t, flavor)
		local o = { _t = t }
		function o:CreateSection(name)
			if type(name) == "table" then name = pick(name, "Name", "name") end
			rawset(self, "_box", rbox(t:AddLeftGroupbox(tostring(name or t.name)), flavor))
			return Stub
		end
		function o:AddLeftGroupbox(info) return rbox(t:AddLeftGroupbox(type(info) == "table" and pick(info, "Name", "name") or tostring(info)), flavor) end
		o.AddRightGroupbox = o.AddLeftGroupbox
		function o:CreateConfigManager() SaveManager:BuildConfigSection(t) return Stub end
		function o:CreateThemeManager() ThemeManager:ApplyToTab(t) return Stub end
		return setmetatable(o, { __index = function(self, k)
			if RBox[k] then
				return function(me, ...)
					rawset(me, "_box", rawget(me, "_box") or rbox(t:AddLeftGroupbox(t.name), flavor))
					return RBox[k](rawget(me, "_box"), ...)
				end
			end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function rayLib(flavor)
		local R = loose({ Flags = Flags, Unloaded = false })
		Library:OnUnload(function() R.Unloaded = true end)
		function R:CreateWindow(opts)
			local w = Library:CreateWindow(opts)
			local W = loose({})
			function W:CreateTab(name)
				if type(name) == "table" then name = pick(name, "Name", "name") or name.Title end
				return rtab(w:AddTab(tostring(name or "Tab")), flavor)
			end
			W.AddTab = W.CreateTab
			function W:Notify(c) R:Notify(c) end
			function W:LoadAutoload() SaveManager:LoadAutoloadConfig() end
			R.Window = W
			return W
		end
		function R:Notify(c)
			c = type(c) == "table" and c or { Content = tostring(c) }
			Library:Notify({ Title = pick(c, "Title", "title"), Description = pick(c, "Content", "content"), Time = pick(c, "Duration", "duration") })
		end
		function R:LoadConfiguration() SaveManager:LoadAutoloadConfig() end
		R.LoadAutoload = R.LoadConfiguration
		function R:Destroy() Library:Unload() end
		R.Unload = R.Destroy
		return R
	end
	getgenv().Rayfield = rayLib("rayfield")
	getgenv().RayfieldGen2 = rayLib("gen2")
	getgenv().OuroFlow = rayLib("ouroflow")
	task.spawn(function()
		for _ = 1, 600 do
			local kp = rawget(Options, "MenuKeybind")
			if kp and Library.ui then
				local function apply()
					local n = kp.Value
					if n and n ~= "None" and not string.find(n, "^MB") then pcall(function() Library.ui:SetToggleKey(n) end) end
				end
				apply()
				kp:OnChanged(apply)
				return
			end
			task.wait(0.1)
		end
	end)
end
return (function(...)
local f6
local connection
local f9
local Peppers
local gf
local fX
local Options
local f_
local Toggles
local f2
local fN
local LocalPlayer
local fQ
local VirtualUser
local fT
local PickupSeed
local gh
local fD
local fZ
local f1
local f4
local fJ
local f7
local fM
local ga
local fP
local gd
local Library
local fF
local f0
local fI
local function fn30()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    select("#", "Make Hotsauce unloaded")
end
local function fn50()
    local PlayerLots = workspace:FindFirstChild("PlayerLots")
    local g6 = PlayerLots and PlayerLots:FindFirstChild(LocalPlayer.Name)
    return g6
end
local function autoPickLoop()
    while not Library.Unloaded do
        if Toggles.AutoPick.Value then
            fM()
        end
        task.wait(0.3)
    end
end
local function fn75(aI)
    local attr = aI:GetAttribute("SeedPrice")
    local hU = typeof(attr) ~= "number"
    local hZ = if hU then 1 else 0
    local hX = 1186 * hZ + 2506 * (1 - hZ)
    local hY = 1168 * hZ + 3040 * (1 - hZ)
    if not ((hX * 2210 + hY * 1249 + hX * hY) % 16777213 == 5465140) then
        hU = attr <= 0
    end
    if hU then
        return true
    end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local hV = leaderstats and leaderstats:FindFirstChild("Money")
    return hV ~= nil and attr <= hV.Value
end
local function fn110(aa)
    return (aa:gsub("^%s*%[[^%]]*%]%s*", ""))
end
local function fn182()
    local iS = fQ()
    local iT = iS and gd(iS)
    if iT then
        pcall(function()
            PickupSeed:FireServer()
        end)
    end
end
local function fn186(N, O)
    return N.heat > O.heat
end
local function autoPickupSeedsLoop()
    while not Library.Unloaded do
        if Toggles.AutoPickupSeeds.Value then
            fJ()
            local kx = Options.PickupDelay.Value or 0.3
            task.wait(kx)
        else
            task.wait(0.3)
        end
    end
end
local function fn223()
    local ib = gf()
    if not ib then
        return
    end
    for i, descendant in ipairs(ib:GetDescendants()) do
        if Library.Unloaded or not Toggles.AutoPick.Value then
            break
        end
        local ib_2 = descendant:IsA("ProximityPrompt") and descendant.Name == "PickPepperPrompt" and descendant.Enabled
        if ib_2 then
            pcall(fireproximityprompt, descendant)
        end
    end
end
local function onUpgrades(dI)
    local kd = {}
    for k, v in dI do
        if v then
            kd[k] = true
        end
    end
    fD = kd
end
local function fn297()
    if setclipboard then
        setclipboard(f9)
    elseif toclipboard then
        toclipboard(f9)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local function autoSpinLoop()
    while not Library.Unloaded do
        if Toggles.AutoSpin.Value then
            gh()
            local kt = Options.SpinDelay.Value or 1.5
            task.wait(kt)
        else
            task.wait(0.3)
        end
    end
end
local function fn356()
    local h_ = gf()
    if not h_ then
        return {}
    end
    local Important = h_:FindFirstChild("Important")
    local h__1 = Important and Important:FindFirstChild("Selling")
    local h0_1 = h__1
    if h__1 then
        h__1 = h0_1:FindFirstChild("Placements")
    end
    local h0_2 = h__1
    if not h0_2 then
        return {}
    end
    local h__2 = {}
    for i, child in ipairs(h0_2:GetChildren()) do
        local h0_3 = child:IsA("BasePart") and not child:FindFirstChild("PlacedHotsauce")
        if h0_3 then
            h__2[#h__2 + 1] = child
        end
    end
    return h__2
end
local function fn359(du)
    local DiscordGroup = du:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord For Dupe", Func = fI })
    return DiscordGroup
end
local function fn396()
    local jC = fP()
    local jC_1
    local jD = (tonumber(Options.BrewMinHeat.Value))
    local jD_1
    local jI = if jD then 1 else 0
    local jG = 701 * jI + 1093 * (1 - jI)
    local jH = 1736 * jI + 1054 * (1 - jI)
    if not ((jG * 3586 + jH * 3930 + jG * jH) % 16777213 == 10553202) then
        jD = 0
    end
    if jC < jD then
        return
    end
    jC_1, jD_1 = pcall(function()
        return ga:InvokeServer()
    end)
    local jE = jC_1 and typeof(jD_1) == "table" and jD_1.ok
    if jE then
        pcall(function()
            f6:FireServer()
        end)
    end
end
local function fn399()
    local hI = f4()
    if not hI then
        return nil
    end
    for i, child in ipairs(hI:GetChildren()) do
        local hS = if child:IsA("Model") then 1 else 0
        if hS == 1 then
            return child
        end
    end
    return nil
end
local function fn401()
    if Toggles.SpinWaitForPickup.Value then
        local iM = fQ()
        local iN = iM and gd(iM)
        if iN then
            if Toggles.AutoPickupSeeds.Value then
                pcall(function()
                    PickupSeed:FireServer()
                end)
            end
            return
        end
    end
    pcall(function()
        f_:FireServer()
    end)
end
local function fn408(ap)
    local hn = {}
    for i, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if ap(child) then
            hn[#hn + 1] = child
        end
    end
    local Character = LocalPlayer.Character
    if Character then
        for i, child in ipairs(Character:GetChildren()) do
            local hE = if ap(child) then 1 else 0
            if hE == 1 then
                hn[#hn + 1] = child
            end
        end
    end
    return hn
end
local function autoUpgradeLoop()
    while not Library.Unloaded do
        if Toggles.AutoUpgrade.Value then
            f2()
        end
        task.wait(0.4)
    end
end
local function fn447(ac)
    local g8 = ac and ac:IsA("Tool")
    if not g8 then
        return false
    end
    local hc = if ac:GetAttribute("Hotsauce") == true then 1 else 0
    if hc == 1 then
        return false
    end
    local g8_1 = ac:GetAttribute("PepperUid") ~= nil or ac:GetAttribute("PepperName") ~= nil or ac:GetAttribute("Heat") ~= nil
    local hf = if g8_1 then 1 else 0
    local hd = 1256 * hf + 1088 * (1 - hf)
    local he = 1036 * hf + 2887 * (1 - hf)
    if not ((hd * 286 + he * 1283 + hd * he) % 16777213 == 2989620) then
        g8_1 = Peppers:FindFirstChild(ac.Name) ~= nil
    end
    if not g8_1 then
        g8_1 = Peppers:FindFirstChild(f0(ac.Name)) ~= nil
    end
    return g8_1
end
local function onAntiAfk(dQ)
    if dQ then
        if not connection then
            connection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    elseif connection then
        connection:Disconnect()
        connection = nil
    end
end
local function fn474()
    local hF = gf()
    if not hF then
        return nil
    end
    local Important = hF:FindFirstChild("Important")
    local hF_1 = Important and Important:FindFirstChild("SeedMachine")
    return hF_1
end
local function fn477()
end
local function onUnload()
    Library:Unload()
end
local function fn543(al)
    local hl = al:GetAttribute("PepperName") or f0(al.Name)
    return hl
end
local function autoUnlockLoop()
    while not Library.Unloaded do
        if Toggles.AutoUnlock.Value then
            fZ()
        end
        task.wait(0.4)
    end
end
local function fn551(ai)
    local hg = ai ~= nil and ai:IsA("Tool") and ai:GetAttribute("Hotsauce") == true
    return hg
end
local function onAddPeppers(dA)
    local j5 = {}
    for k, v in dA do
        if v then
            j5[k] = true
        end
    end
    fN = j5
end
local function fn582(cw)
    local jn_1
    local jm_1
    if typeof(cw) ~= "string" then
        return 0
    end
    jm_1, jn_1 = cw:match("([%d%.]+)%s*(%a*)")
    local jo = tonumber(jm_1)
    if not jo then
        return 0
    end
    return jo * (fF[jn_1] or 1)
end
local function fn588()
    local jq = gf()
    if not jq then
        return 0
    end
    local Important = jq:FindFirstChild("Important")
    local jq_1 = Important and Important:FindFirstChild("Brewing")
    local jr_1 = jq_1
    if jq_1 then
        jq_1 = jr_1:FindFirstChild("HeatSum")
    end
    local jr_2 = jq_1
    if not jr_2 then
        return 0
    end
    for i, descendant in ipairs(jr_2:GetDescendants()) do
        local jB = if descendant:IsA("TextLabel") then 1 else 0
        if jB == 1 then
            return f7(descendant.Text)
        end
    end
    return 0
end
local function fn602()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function autoAddLoop()
    while not Library.Unloaded do
        if Toggles.AutoAdd.Value then
            fX()
        end
        task.wait(0.3)
    end
end
local function autoBrewLoop()
    while not Library.Unloaded do
        if Toggles.AutoBrew.Value then
            fT()
            local kB = Options.BrewDelay.Value or 1
            task.wait(kB)
        else
            task.wait(0.3)
        end
    end
end
local function autoPlaceLoop()
    while not Library.Unloaded do
        if Toggles.AutoPlace.Value then
            f1()
        end
        task.wait(0.4)
    end
end
fD = nil
Options = nil
fF = nil
Toggles = nil
fI = nil
fJ = nil
fM = nil
fN = nil
connection = nil
fP = nil
fQ = nil
fT = nil
PickupSeed = nil
fX = nil
Library = nil
fZ = nil
f_ = nil
f0 = nil
f1 = nil
f2 = nil
f4 = nil
f6 = nil
f7 = nil
LocalPlayer = nil
f9 = nil
ga = nil
VirtualUser = nil
Peppers = nil
gd = nil
gf = nil
gh = nil
local fG, fK, fL, BuyRow2Dirt, fS, UnlockDirt, fV, PlaceHotsauce, f5, ge, gg
local gl_1
local gj_1
local gt_3
VirtualUser, LocalPlayer = nil, nil
local Players = game:GetService("Players")
local gi_4
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gk_1
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
Library, Toggles, Options, ge, ga, f6, PlaceHotsauce, f_, PickupSeed, UnlockDirt, BuyRow2Dirt, fL, fG, fD, Peppers, f9 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
pcall(fn602)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
local gm = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteEvents"))
local gm_1
if not gm and Peppers or not ge and not ge or (ge or Peppers) and (not Peppers and not fL) or not (not gm and Peppers or not ge and not ge or (ge or Peppers) and (not Peppers and not fL)) then
    ge = gm.Brewing.AddPepper
    ga = gm.Brewing.Brew
    f6 = gm.Brewing.ClaimHotsauce
    PlaceHotsauce = gm.Selling.PlaceHotsauce
    f_ = gm.SeedMachine.SpawnSeed
else
    f_ = PlaceHotsauce.Brewing.AddPepper
    ge = PlaceHotsauce.Brewing.Brew
    gm = PlaceHotsauce.Brewing.ClaimHotsauce
    f6 = PlaceHotsauce.Selling.PlaceHotsauce
    ga = PlaceHotsauce.SeedMachine.SpawnSeed
end
PickupSeed = gm.SeedMachine.PickupSeed
UnlockDirt = gm.Plot.UnlockDirt
BuyRow2Dirt = gm.Plot.BuyRow2Dirt
local Upgrades = gm.Upgrades
fL = { "Spicier Sauce", "Seed Anim Time", "Breed Time", "Breed Multiplier Chance", "Customer Chance" }
fG = {
    ["Spicier Sauce"] = Upgrades.BuySpicierSauce,
    ["Seed Anim Time"] = Upgrades.BuySeedAnimTime,
    ["Breed Time"] = Upgrades.BuyBreedTime,
    ["Breed Multiplier Chance"] = Upgrades.BuyBreedMultiplierChance,
    ["Customer Chance"] = Upgrades.BuyCustomerChance
}
fD = {}
local gn = require(ReplicatedStorage.Modules:WaitForChild("PepperPool"))
Peppers = ReplicatedStorage:WaitForChild("Peppers")
f9 = "https://discord.gg/K7Qxnxkk46"
local gq = {}
local gs
local gs_6
local gr = 8
repeat
    if (gr * 1 + 0) % 2 + 1 <= 1 then
        local ld = bit32.rrotate(bit32.bxor(bit32.lrotate(gr, 11), string.byte(tostring(gs))), 26)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(ld, 3480668837), 1330862137), (bit32.bxor(bit32.band(ld, 814298458), 4106905461))), 1330862137), 4106905461) == ld then
            gs = gn.All()
        else
            gn = gs.All()
        end
        gr = (gr + 5) % 16
    else
        if (gr * 1 + 3) * 5 % 4 == ((gr * 1 + 3) * 5 + 9) % 4 then
            table.sort(gs, fn186)
        else
            table.sort(gs, fn186)
        end
        gr = (gr + 1) % 16
    end
until (gr * 11 + 4) % 16 == 14
for i, v in ipairs(gs) do
    gq[#gq + 1] = v.name
end
fN, gm_1, gl_1, gk_1, gj_1, fF, fI, gf, f0, fV, gg, f5, fS, f4, fQ, gd, fK, fM, fX, gh, fJ, f1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local gi_3 = 64
repeat
    local gn_1 = (gi_3 * 4 + 5) % 9 + 1
    if gn_1 <= 5 then
        if gn_1 <= 3 then
            if gn_1 <= 2 then
                if gn_1 <= 1 then
                    local gr_1 = {
                        "wiktl",
                        "leec",
                        "ksikm",
                        "tzmjk",
                        "iamk",
                        "htkzxicyme",
                        "zvn",
                        "hlqb",
                        "auxuvy",
                        "dgzaui",
                        "ixqmapbr"
                    }
                    local lf = gi_3
                    local gs_1 = gr_1[lf % 11 + 1]
                    if gs_1:len() <= gs_1:gsub("(.)", "%1%1", lf % 3 % 2 + 1):len() then
                        fN = {}
                    else
                        gk_1 = {}
                    end
                    gi_3 = (gi_3 + 34) % 72
                else
                    local gr_2 = {
                        "jhpumep",
                        "zygrh",
                        "segftlvc",
                        "aorjvsdjcr",
                        "kqnhyl",
                        "ehdmmc",
                        "fgcpqxjbzk",
                        "vjxwo",
                        "tpllif",
                        "jqosihddij"
                    }
                    if gr_2[(gi_3 * 71 + 76) % 10 + 1] < gr_2[(gi_3 * 71 + 76) % 10 + 1] then
                        gd = fn297
                    else
                        fI = fn297
                    end
                    gi_3 = (gi_3 + 34) % 72
                end
            else
                local gr_3 = (vector.create((gi_3 * 3 + 9) % 11 + 1, (gi_3 * 8 + 3) % 13 + 1, (gi_3 * 5 + 14) % 17 + 1))
                local lc = vector.floor(gr_3) + vector.ceil(gr_3 * -1)
                if vector.dot(lc, lc) == 3 then
                    f0 = fn50
                    gf = fn110
                else
                    gf = fn50
                    f0 = fn110
                end
                gi_3 = (gi_3 + 61) % 72
            end
        elseif gn_1 <= 4 then
            if gi_3 * 40723085 + 1 + 7 >= gi_3 * 40723085 + 1 + 7 + 1 then
                gg = fn447
                fS = fn551
                fV = fn543
                f4 = fn408
                f5 = fn474
            else
                fV = fn447
                gg = fn551
                f5 = fn543
                fS = fn408
                f4 = fn474
            end
            gi_3 = (gi_3 + 7) % 72
        else
            local gr_4 = (vector.create((gi_3 * 1 + 5) % 11 + 1, (gi_3 * 2 + 11) % 13 + 1, (gi_3 * 9 + 5) % 17 + 1))
            local gs_2 = (vector.create((gi_3 * 6 + 5) % 11 + 1, (gi_3 * 6 + 4) % 13 + 1, (gi_3 * 14 + 10) % 17 + 1))
            local gt_1 = (vector.create((gi_3 * 4 + 6) % 11 + 1, (gi_3 * 10 + 10) % 13 + 1, (gi_3 * 14 + 13) % 17 + 1))
            local gu = (vector.create((gi_3 * 2 + 1) % 5 + 1, (gi_3 * 1 + 7) % 7 + 1, (gi_3 * 4 + 3) % 9 + 1))
            if vector.dot(vector.cross(gr_4, (vector.cross(gs_2, gt_1))), gu) == vector.dot(gs_2 * vector.dot(gr_4, gt_1) - gt_1 * vector.dot(gr_4, gs_2), gu) + 5 then
                gd = fn399
                fQ = fn75
                fM = fn356
                fK = fn223
            else
                fQ = fn399
                gd = fn75
                fK = fn356
                fM = fn223
            end
            gi_3 = (gi_3 + 70) % 72
        end
    elseif gn_1 <= 7 then
        if gn_1 <= 6 then
            local gr_5 = (vector.create((gi_3 * 1 + 3) % 11 + 1, (gi_3 * 6 + 9) % 13 + 1, (gi_3 * 12 + 14) % 17 + 1))
            local gs_3 = (vector.create((gi_3 * 5 + 9) % 11 + 1, (gi_3 * 4 + 2) % 13 + 1, (gi_3 * 9 + 3) % 17 + 1))
            local lv = vector.cross(gr_5, gs_3)
            local lw = vector.dot(gr_5, gs_3)
            if vector.dot(lv, lv) + lw * lw == vector.dot(gr_5, gr_5) * vector.dot(gs_3, gs_3) + 3 then
                gh = function()
                    local iu = fS(fV)
                    if #iu == 0 then
                        return
                    end
                    if Toggles.KeepBestPepper.Value then
                        table.sort(iu, function(bf, bg)
                            local ip = bf:GetAttribute("Heat") or 0
                            local iq = bg:GetAttribute("Heat") or 0
                            return ip > iq
                        end)
                        table.remove(iu, 1)
                    end
                    local iv = (tonumber(Options.AddMinHeat.Value))
                    local iC = if iv then 1 else 0
                    local iA = 1954 * iC + 4054 * (1 - iC)
                    local iB = 2961 * iC + 2484 * (1 - iC)
                    if not ((iA * 459 + iB * 2768 + iA * iB) % 16777213 == 14878728) then
                        iv = 0
                    end
                    local iw = iv
                    local iv_2 = next(fN) ~= nil
                    local ix = Options.AddDelay.Value or 0.2
                    for i, v in ipairs(iu) do
                        local is, it
                        if Library.Unloaded or not Toggles.AutoAdd.Value then
                            break
                        end
                        local iu_7 = v:GetAttribute("Heat") or 0
                        local iu_8 = iu_7 >= iw
                        if iu_8 then
                            local ix_6 = not iv_2
                            local iL_3 = if ix_6 then 1 else 0
                            local iJ_3 = 3301 * iL_3 + 737 * (1 - iL_3)
                            local iK_3 = 2961 * iL_3 + 2956 * (1 - iL_3)
                            if not ((iJ_3 * 1877 + iK_3 * 1857 + iJ_3 * iK_3) % 16777213 == 4691602) then
                                ix_6 = fN[f5(v)]
                            end
                            iu_8 = ix_6
                        end
                        if iu_8 then
                            local attr = v:GetAttribute("PepperUid")
                            is = typeof(attr) == "string"
                            local iu_10 = is and attr
                            if not iu_10 then
                                local ix_8 = (v:GetAttribute("PepperName"))
                                local iL_4 = if ix_8 then 1 else 0
                                local iJ_4 = 1601 * iL_4 + 3282 * (1 - iL_4)
                                local iK_4 = 3972 * iL_4 + 1519 * (1 - iL_4)
                                if not ((iJ_4 * 2502 + iK_4 * 622 + iJ_4 * iK_4) % 16777213 == 12835458) then
                                    ix_8 = f0(v.Name)
                                end
                                iu_10 = ix_8
                            end
                            it = iu_10
                            pcall(function()
                                ge:InvokeServer(is, it)
                            end)
                            task.wait(ix)
                        end
                    end
                end
                fJ = fn401
                fX = fn182
            else
                fX = function()
                    local iu = fS(fV)
                    if #iu == 0 then
                        return
                    end
                    if Toggles.KeepBestPepper.Value then
                        table.sort(iu, function(bf, bg)
                            local ip = bf:GetAttribute("Heat") or 0
                            local iq = bg:GetAttribute("Heat") or 0
                            return ip > iq
                        end)
                        table.remove(iu, 1)
                    end
                    local iv = (tonumber(Options.AddMinHeat.Value))
                    local iC = if iv then 1 else 0
                    local iA = 1954 * iC + 4054 * (1 - iC)
                    local iB = 2961 * iC + 2484 * (1 - iC)
                    if not ((iA * 459 + iB * 2768 + iA * iB) % 16777213 == 14878728) then
                        iv = 0
                    end
                    local iw = iv
                    local iv_1 = next(fN) ~= nil
                    local ix = Options.AddDelay.Value or 0.2
                    for i, v in ipairs(iu) do
                        local is, it
                        if Library.Unloaded or not Toggles.AutoAdd.Value then
                            break
                        end
                        local iu_2 = v:GetAttribute("Heat") or 0
                        local iu_3 = iu_2 >= iw
                        if iu_3 then
                            local ix_2 = not iv_1
                            local iL_1 = if ix_2 then 1 else 0
                            local iJ_1 = 3301 * iL_1 + 737 * (1 - iL_1)
                            local iK_1 = 2961 * iL_1 + 2956 * (1 - iL_1)
                            if not ((iJ_1 * 1877 + iK_1 * 1857 + iJ_1 * iK_1) % 16777213 == 4691602) then
                                ix_2 = fN[f5(v)]
                            end
                            iu_3 = ix_2
                        end
                        if iu_3 then
                            local attr = v:GetAttribute("PepperUid")
                            is = typeof(attr) == "string"
                            local iu_5 = is and attr
                            if not iu_5 then
                                local ix_4 = (v:GetAttribute("PepperName"))
                                local iL_2 = if ix_4 then 1 else 0
                                local iJ_2 = 1601 * iL_2 + 3282 * (1 - iL_2)
                                local iK_2 = 3972 * iL_2 + 1519 * (1 - iL_2)
                                if not ((iJ_2 * 2502 + iK_2 * 622 + iJ_2 * iK_2) % 16777213 == 12835458) then
                                    ix_4 = f0(v.Name)
                                end
                                iu_5 = ix_4
                            end
                            it = iu_5
                            pcall(function()
                                ge:InvokeServer(is, it)
                            end)
                            task.wait(ix)
                        end
                    end
                end
                gh = fn401
                fJ = fn182
            end
            gi_3 = (gi_3 + 43) % 72
        else
            local gr_6 = (vector.create((gi_3 * 1 + 2) % 11 + 1, (gi_3 * 8 + 12) % 13 + 1, (gi_3 * 15 + 4) % 17 + 1))
            local gs_4 = (vector.create((gi_3 * 6 + 3) % 11 + 1, (gi_3 * 6 + 11) % 13 + 1, (gi_3 * 8 + 15) % 17 + 1))
            local gt_2 = (vector.create((gi_3 * 2 + 4) % 5 + 1, (gi_3 * 3 + 7) % 7 + 1, (gi_3 * 1 + 3) % 9 + 1))
            if math.abs((vector.angle(gr_6, gs_4, gt_2))) - math.abs((vector.angle(gs_4, gr_6, gt_2))) == 4 then
                gm_1 = function()
                    local i1 = fK()
                    if #i1 == 0 then
                        return
                    end
                    local i2 = tonumber(Options.PlaceMinHeat.Value) or 0
                    local i3 = {}
                    for i, v in ipairs(fS(gg)) do
                        local i2_4 = (v:GetAttribute("Heat"))
                        local jf = if i2_4 then 1 else 0
                        local jd = 1562 * jf + 2540 * (1 - jf)
                        local je = 2278 * jf + 3023 * (1 - jf)
                        if not ((jd * 2269 + je * 1990 + jd * je) % 16777213 == 11635634) then
                            i2_4 = 0
                        end
                        local i5_3 = i2_4 >= i2 and typeof(v:GetAttribute("HotsauceId")) == "string"
                        if i5_3 then
                            i3[#i3 + 1] = v
                        end
                    end
                    local Value = Options.PlaceSort.Value
                    if Value == "Highest Heat" then
                        table.sort(i3, function(ca, cb)
                            local iY = ca:GetAttribute("Heat") or 0
                            local iZ = cb:GetAttribute("Heat") or 0
                            return iY > iZ
                        end)
                    elseif Value == "Lowest Heat" then
                        table.sort(i3, function(b8, b9)
                            local iV = b8:GetAttribute("Heat") or 0
                            local iW = b9:GetAttribute("Heat") or 0
                            return iV < iW
                        end)
                    end
                    local i2_6 = Options.PlaceDelay.Value or 0.2
                    local i4_2 = 1
                    for i, v in ipairs(i1) do
                        local jl = v
                        if Library.Unloaded or not Toggles.AutoPlace.Value then
                            break
                        else
                            local i0 = i3[i4_2]
                            if not i0 then
                                break
                            end
                            i4_2 = i4_2 + 1
                            pcall(function()
                                PlaceHotsauce:InvokeServer(jl, i0:GetAttribute("HotsauceId"))
                            end)
                            task.wait(i2_6)
                        end
                    end
                end
                gl_1 = { "No", "Sp", "D", "Qi", "", "Oc", "U", "T", "Sx", "Qa" }
                f1 = { "Tg", "Su", "Og", "Vg", "Sg", "", "Qq", "Qd", "Nv", "Dc" }
            else
                f1 = function()
                    local i1 = fK()
                    if #i1 == 0 then
                        return
                    end
                    local i2 = tonumber(Options.PlaceMinHeat.Value) or 0
                    local i3 = {}
                    for i, v in ipairs(fS(gg)) do
                        local i2_1 = (v:GetAttribute("Heat"))
                        local jf = if i2_1 then 1 else 0
                        local jd = 1562 * jf + 2540 * (1 - jf)
                        local je = 2278 * jf + 3023 * (1 - jf)
                        if not ((jd * 2269 + je * 1990 + jd * je) % 16777213 == 11635634) then
                            i2_1 = 0
                        end
                        local i5_1 = i2_1 >= i2 and typeof(v:GetAttribute("HotsauceId")) == "string"
                        if i5_1 then
                            i3[#i3 + 1] = v
                        end
                    end
                    local Value = Options.PlaceSort.Value
                    if Value == "Highest Heat" then
                        table.sort(i3, function(ca, cb)
                            local iY = ca:GetAttribute("Heat") or 0
                            local iZ = cb:GetAttribute("Heat") or 0
                            return iY > iZ
                        end)
                    elseif Value == "Lowest Heat" then
                        table.sort(i3, function(b8, b9)
                            local iV = b8:GetAttribute("Heat") or 0
                            local iW = b9:GetAttribute("Heat") or 0
                            return iV < iW
                        end)
                    end
                    local i2_3 = Options.PlaceDelay.Value or 0.2
                    local i4_1 = 1
                    for i, v in ipairs(i1) do
                        local jl = v
                        if Library.Unloaded or not Toggles.AutoPlace.Value then
                            break
                        else
                            local i0 = i3[i4_1]
                            if not i0 then
                                break
                            end
                            i4_1 = i4_1 + 1
                            pcall(function()
                                PlaceHotsauce:InvokeServer(jl, i0:GetAttribute("HotsauceId"))
                            end)
                            task.wait(i2_3)
                        end
                    end
                end
                gm_1 = { "", "U", "D", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No" }
                gl_1 = { "", "Dc", "Vg", "Tg", "Qd", "Qq", "Sg", "Su", "Og", "Nv" }
            end
            gi_3 = (gi_3 + 52) % 72
        end
    elseif gn_1 <= 8 then
        local gn_2 = (vector.create((gi_3 * 3 + 4) % 11 + 1, (gi_3 * 9 + 11) % 13 + 1, (gi_3 * 8 + 11) % 17 + 1))
        local gr_7 = (vector.create((gi_3 * 3 + 4) % 11 + 1, (gi_3 * 9 + 11) % 13 + 1, (gi_3 * 14 + 12) % 17 + 1))
        local gs_5 = (vector.create((gi_3 * 1 + 5) % 5 + 1, (gi_3 * 4 + 1) % 7 + 1, (gi_3 * 4 + 2) % 9 + 1))
        if math.abs((vector.angle(gn_2, gr_7, gs_5))) - math.abs((vector.angle(gr_7, gn_2, gs_5))) == 1 then
            gj_1 = { "", "Ne", "Ce", "Sc", "Si", "Qe", "Tc", "Dn", "Qu", "Oe" }
            gk_1 = { "T", "K", "B", "M" }
        else
            gk_1 = { "", "Ce", "Dn", "Tc", "Qe", "Qu", "Sc", "Si", "Oe", "Ne" }
            gj_1 = { "K", "M", "B", "T" }
        end
        gi_3 = (gi_3 + 52) % 72
    else
        local gn_3 = { "sli", "brwrue", "zusih", "vedsffwzhfl", "irvrewle", "rfd", "ngkmtdv" }
        local ln = gi_3
        local gr_8 = gn_3[ln % 7 + 1]
        if gr_8:len() >= gr_8:reverse():rep(ln % 3 + 2):len() then
            fS = { [""] = 1 }
        else
            fF = { [""] = 1 }
        end
        gi_3 = (gi_3 + 52) % 72
    end
until (gi_3 * 43 + 55) % 72 == 62
local gQ = 1
while gQ <= 100 do
    local gR = gQ
    if gR <= 4 then
        gi_4 = gj_1[gR]
    else
        local gn_4 = gR - 1
        gi_4 = gm_1[gn_4 % 10 + 1] .. gl_1[math.floor(gn_4 / 10) % 10 + 1] .. gk_1[math.floor(gn_4 / 100) % 10 + 1]
    end
    fF[gi_4] = 1000 ^ gR
    gQ += 1
end
gt_3, f7, fP, fT, f2, fZ, gs_6 = nil, nil, nil, nil, nil, nil, nil
if (gs_6 or gt_3) and (not gs_6 and gt_3) or (not gt_3) and false or not ((gs_6 or gt_3) and (not gs_6 and gt_3) or (not gt_3) and false) then
    f7 = fn582
    fP = fn588
    fT = fn396
    f2 = function()
        local jK = Options.UpgradeDelay.Value or 0.3
        for i, v in ipairs(fL) do
            if Library.Unloaded or not Toggles.AutoUpgrade.Value then
                break
            elseif fD[v] then
                local jJ = fG[v]
                if jJ then
                    pcall(function()
                        jJ:FireServer()
                    end)
                    task.wait(jK)
                end
            end
        end
    end
else
    f2 = fn582
    fT = fn588
    fP = fn396
    f7 = function()
        local jK = Options.UpgradeDelay.Value or 0.3
        for i, v in ipairs(fL) do
            if Library.Unloaded or not Toggles.AutoUpgrade.Value then
                break
            elseif fD[v] then
                local jJ = fG[v]
                if jJ then
                    pcall(function()
                        jJ:FireServer()
                    end)
                    task.wait(jK)
                end
            end
        end
    end
end
fZ = function()
    local jW = gf()
    if not jW then
        return
    end
    local Dirt = jW:FindFirstChild("Dirt")
    if not Dirt then
        return
    end
    local jW_1 = Options.UnlockDelay.Value or 0.3
    for i, child in ipairs(Dirt:GetChildren()) do
        local j4 = child
        if Library.Unloaded or not Toggles.AutoUnlock.Value then
            break
        end
        local jW_3 = j4:IsA("BasePart") and j4:GetAttribute("Locked") == true
        if jW_3 then
            if j4:GetAttribute("Row2Price") ~= nil then
                pcall(function()
                    BuyRow2Dirt:InvokeServer(j4)
                end)
            else
                pcall(function()
                    UnlockDirt:InvokeServer(j4)
                end)
            end
            task.wait(jW_1)
        end
    end
end
Library.SetNotifySide = fn477
local Window = Library:CreateWindow({
    Title = "Make Hotsauce",
    Footer = "Tempo Hub",
    Size = UDim2.fromOffset(900, 640),
    ShowCustomCursor = false
})
Library.ShowCustomCursor = false
local gt_4 = { Main = Window:AddTab("Main", "flame"), Settings = Window:AddTab("Settings", "settings") }
for k, v in gt_4 do
    fn359(v)
end
connection = nil
local PeppersGroup = gt_4.Main:AddLeftGroupbox("Peppers", "leaf")
PeppersGroup:AddToggle("AutoPick", { Text = "Auto Pick Peppers", Default = false })
PeppersGroup:AddDivider()
PeppersGroup:AddToggle("AutoAdd", { Text = "Auto Add Peppers To Brew", Default = false })
PeppersGroup:AddToggle("KeepBestPepper", { Text = "Keep Highest Heat Pepper", Default = false })
PeppersGroup:AddInput("AddMinHeat", { Text = "Min Heat", Default = "0", Numeric = true, Finished = true })
PeppersGroup:AddSlider("AddDelay", { Text = "Add Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
PeppersGroup:AddDropdown("AddPeppers", {
    Text = "Only Add These (empty = all)",
    Values = gq,
    Default = {},
    Multi = true,
    Callback = onAddPeppers
})
local SeedMachineGroup = gt_4.Main:AddRightGroupbox("Seed Machine", "sprout")
SeedMachineGroup:AddToggle("AutoSpin", { Text = "Auto Spin Seeds", Default = false })
SeedMachineGroup:AddToggle("SpinWaitForPickup", { Text = "Don't Spin While Seed Waiting", Default = true })
SeedMachineGroup:AddSlider("SpinDelay", { Text = "Spin Delay", Default = 1.5, Min = 0.5, Max = 15, Rounding = 1 })
SeedMachineGroup:AddDivider()
SeedMachineGroup:AddToggle("AutoPickupSeeds", { Text = "Auto Pickup Seeds", Default = false })
SeedMachineGroup:AddSlider("PickupDelay", { Text = "Pickup Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 1 })
local SellingGroup = gt_4.Main:AddLeftGroupbox("Selling", "utensils")
SellingGroup:AddToggle("AutoPlace", { Text = "Auto Place Hot Sauce", Default = false })
SellingGroup:AddInput("PlaceMinHeat", { Text = "Min Heat", Default = "0", Numeric = true, Finished = true })
SellingGroup:AddDropdown("PlaceSort", {
    Text = "Place Order",
    Values = { "Any", "Highest Heat", "Lowest Heat" },
    Default = "Highest Heat",
    Multi = false
})
SellingGroup:AddSlider("PlaceDelay", { Text = "Place Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
SellingGroup:AddDivider()
SellingGroup:AddToggle("AutoBrew", { Text = "Auto Pickup Ready Brew", Default = false })
SellingGroup:AddInput("BrewMinHeat", { Text = "Min Brew Heat", Default = "0", Numeric = true, Finished = true })
SellingGroup:AddSlider("BrewDelay", { Text = "Brew Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
local UpgradesGroup = gt_4.Main:AddRightGroupbox("Upgrades", "trending-up")
UpgradesGroup:AddToggle("AutoUpgrade", { Text = "Auto Buy Upgrades", Default = false })
UpgradesGroup:AddDropdown("Upgrades", { Text = "Upgrades", Values = fL, Default = {}, Multi = true, Callback = onUpgrades })
UpgradesGroup:AddSlider("UpgradeDelay", { Text = "Upgrade Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 2 })
local UnlockGroup = gt_4.Main:AddRightGroupbox("Unlock", "lock-open")
UnlockGroup:AddToggle("AutoUnlock", { Text = "Auto Unlock Dirt", Default = false })
UnlockGroup:AddSlider("UnlockDelay", { Text = "Unlock Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 2 })
local MenuGroup = gt_4.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "UI Keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true, Callback = onAntiAfk })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(fn30)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/MakeHotsauce")
SaveManager:BuildConfigSection(gt_4.Settings)
ThemeManager:ApplyToTab(gt_4.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(autoPickLoop)
task.spawn(autoAddLoop)
task.spawn(autoSpinLoop)
task.spawn(autoPickupSeedsLoop)
task.spawn(autoPlaceLoop)
task.spawn(autoBrewLoop)
task.spawn(autoUpgradeLoop)
task.spawn(autoUnlockLoop)
Library:Notify("Make Hotsauce loaded")
end)(...)
