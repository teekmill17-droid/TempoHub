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
getgenv().TempoHoodSubtitle = "ROLL A GNOME"
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
local fns = {}
local yo_5, yo_7, yo_10, yo_12, yo_14, yo_17, yo_18, yo_19, yo_21, yo_23, UserInputService, yo_26
local on
local o6
local oO
local pv
local pc
local oU
local pB
local oB
local pi
local oH
local po
local onBuyRollNow
local connection2
local oN
local pu
local pb
local oT
local pA
local oA
local ph
local oZ
local oG
local pn
local Toggles
local Replication
local pt
local pa
local onBuyUpgradesNow
local Options
local pg
local oY
local oF
local pm
local oj
local ps
local oq
local py
local oy
local oX
local oE
local pl
local o2
local pr
local o8
local onBuyShopNow
local px
local Library
local onSellAllGnomesNow
local oW
local oD
local pk
local onCollectNow
local onExpandNow
local onPlaceNow
local o7
local onReplaceNow
local pw
local ow
local pd
local oV
local oC
local o0
local oI
local connection
function fns.fn20(f9)
    local vv = {}
    local vw = { pn:FindFirstChild("Backpack"), pn.Character }
    for i, v in ipairs(vw) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local vw_1 = child:IsA("Tool") and child:GetAttribute("type") == f9
                if vw_1 then
                    table.insert(vv, child)
                end
            end
        end
    end
    return vv
end
function fns.fn23(an, ao)
    return string.format('<font color="%s">%s</font>', ao, an)
end
function fns.worker6()
    while not Library.Unloaded do
        if oB("AutoPlace") then
            onPlaceNow()
        end
        task.wait(pA("PlaceDelay", 0.35))
    end
end
function fns.fn85(be, bf)
    local rm = not be or not next(be)
    if rm then
        return true
    end
    return be[bf] == true
end
function fns.fn93(bi, bj)
    local ro = not bi or not next(bi)
    if ro then
        return true
    end
    return bi[bj] == true
end
function fns.onSellAllNow()
    pcall(function()
        o0:InvokeServer("SellAll")
    end)
end
function fns.fn117(fm)
    for i, v in ipairs(pi()) do
        if v == fm then
            return true
        end
    end
    return false
end
function fns.fn118()
    local va = pl()
    local vb = va and va:FindFirstChild("ExpandPlot")
    if not vb then
        return {}
    end
    local vb_1 = {}
    for i, descendant in ipairs(vb:GetDescendants()) do
        local va_2 = descendant:IsA("Model") and oA[descendant.Name] and descendant:FindFirstChild("BoundaryPart", true)
        if va_2 then
            local insert = table.insert
            local vc = tonumber(oA[descendant.Name]) or 0
            insert(vb_1, { model = descendant, price = vc })
        end
    end
    table.sort(vb_1, function(fU, fV)
        return fU.price < fV.price
    end)
    return vb_1
end
function fns.fn150(iW)
    local DiscordGroup = iW:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ph })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ph })
end
function fns.onCopyJoinScript_JobID()
    local jc = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, po)
    px(jc, "Copied join script to clipboard")
end
function fns.fn191(bz)
    local rv = not bz or not bz:IsA("Model")
    if rv then
        return false
    end
    local rv_1 = (bz:GetAttribute("FarmerName"))
    local rB = if rv_1 then 1 else 0
    local rz = 1592 * rB + 1456 * (1 - rB)
    local rA = 1262 * rB + 3602 * (1 - rB)
    if not ((rz * 1832 + rA * 2018 + rz * rA) % 16777213 == 7472364) then
        rv_1 = bz.Name
    end
    local rw = rv_1
    local rv_2 = o6(rw)
    if not rv_2 then
        return false
    end
    local rB_1 = if not oW(pg("BuyRollRarities"), rv_2.real_rarity) then 1 else 0
    if rB_1 == 1 then
        return false
    end
    local rB_2 = if not oN(pg("BuyRollGnomes"), rw) then 1 else 0
    if rB_2 == 1 then
        return false
    end
    local rw_1 = tonumber(rv_2.price) or 0
    local rw_2 = pA("BuyRollMaxPrice", 0)
    if rw_2 > 0 and rw_1 > rw_2 then
        return false
    end
    local rw_3 = pA("BuyRollMoneyBuffer", 0)
    if oT() - rw_1 < rw_3 then
        return false
    end
    return true
end
function fns.onInputBegan()
    oH = tick()
end
function fns.fn223()
    if oB("AutoSprinkler") then
        pc("Sprinkler", pg("SprinklerItems"), pA("SprinklerMax", 1))
    end
    if oB("AutoFertilizer") then
        pc("Fertilizer", pg("FertilizerItems"), pA("FertilizerMax", 1))
    end
end
function fns.onUnload()
    Library:Unload()
end
local function fn250(c7)
    local s6 = c7:GetAttribute("FarmerName") or c7.Name
    local s6_1 = o6(s6)
    local s6_2 = s6_1 and s6_1.real_rarity
    local tc = if s6_2 then 1 else 0
    local ta = 3515 * tc + 2138 * (1 - tc)
    local tb = 753 * tc + 1869 * (1 - tc)
    if not ((ta * 3396 + tb * 3296 + ta * tb) % 16777213 == 288410) then
        s6_2 = "Common"
    end
    local s8_1 = s6_2
    if not oW(pg("PlaceRarities"), s8_1) then
        return false
    elseif not oN(pg("PlaceGnomes"), s6) then
        return false
    else
        return true
    end
end
local function worker10()
    while not Library.Unloaded do
        if oB("AutoSellGnomes") then
            onSellAllGnomesNow()
        end
        task.wait(math.max(pA("SellGnomesDelay", 0.35), 1))
    end
end
local function fn258()
    local xc = pl()
    if not xc then
        return nil
    end
    local GardenPivot = xc:FindFirstChild("GardenPivot")
    local xc_1 = GardenPivot and GardenPivot:IsA("BasePart")
    if xc_1 then
        return GardenPivot.CFrame
    end
    local xc_2 = oO(pA("BoostSpacing", 6))
    local xd_1 = xc_2[1] and CFrame.new(xc_2[1])
    return xd_1 or nil
end
local function fn273(cv)
    local sw_1
    local sv_1
    local sq_1
    local sp_1
    local su_1
    local so_2
    local ss_2
    local sm = pl()
    local sm_2
    if not sm then
        return {}
    end
    local Ground = sm:FindFirstChild("Ground")
    local sm_1 = Ground
    if sm_1 then
        local so_1 = Ground:FindFirstChild("Floor1") or Ground
        sm_1 = so_1
    end
    local sn_1 = sm_1
    if not sn_1 then
        return {}
    end
    so_2, sm_2, sp_1, sq_1 = nil, nil, nil, nil
    local sr
    for i, descendant in ipairs(sn_1:GetDescendants()) do
        local sn_2 = descendant:IsA("BasePart") and descendant.Size.X >= 4 and descendant.Size.Z >= 4
        if sn_2 then
            local Position = descendant.Position
            local ss_1 = descendant.Size.X * 0.5
            local st_1 = descendant.Size.Z * 0.5
            su_1, sv_1 = Position.X - ss_1 + 2, Position.X + ss_1 - 2
            ss_2, sw_1 = Position.Z - st_1 + 2, Position.Z + st_1 - 2
            local st_2 = so_2 and math.min(so_2, su_1)
            so_2 = st_2 or su_1
            local st_3 = sm_2 and math.max(sm_2, sv_1)
            sm_2 = st_3 or sv_1
            local st_4 = sp_1 and math.min(sp_1, ss_2)
            sp_1 = st_4 or ss_2
            local ss_3 = sq_1 and math.max(sq_1, sw_1)
            sq_1 = ss_3 or sw_1
            sr = sr or Position.Y + descendant.Size.Y * 0.5
        end
    end
    if not so_2 then
        return {}
    end
    local sn_4 = {}
    local ss_5 = math.max(cv, 2)
    local sK = so_2
    local sI = sm_2
    while ss_5 > 0 and sK <= sI or ss_5 <= 0 and sK >= sI do
        local sL = sK
        local sP = sp_1
        local sN = sq_1
        while ss_5 > 0 and sP <= sN or ss_5 <= 0 and sP >= sN do
            local sQ = sP
            local insert = table.insert
            local new = Vector3.new
            local st_6 = sr or 2
            insert(sn_4, new(sL, st_6, sQ))
            sP += ss_5
        end
        sK += ss_5
    end
    return sn_4
end
local function fn326()
    local uD = pu()
    local uE = uD and uD.requirements
    local uD_1 = uE
    if uE then
        uE = uD_1.gnomes
    end
    return uE or {}
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if oB("AntiAfk") then
            local xX = tick() - oH
            local xY = tick() - oF
            if xX >= 300 and xY >= 60 then
                pcall(on)
            else
                if xX < 300 and xY >= 300 then
                    pcall(on)
                end
            end
        end
    end
end
local function fn334()
    local q6 = oZ()
    local q7 = q6 and q6.inventory
    if not q7 then
        return 0
    end
    local q7_1 = 0
    for k in pairs(q7) do
        q7_1 += 1
    end
    return q7_1
end
local function fn350()
    return Replication.Data
end
local function fn369(az)
    local qR = Toggles[az]
    return qR ~= nil and qR.Value == true
end
local function fn372(bb)
    return oV[bb]
end
local function fn378()
    local r2 = {}
    local r3 = pl()
    local r4 = r3 and r3:FindFirstChild("ClientFarmers")
    if r4 then
        for i, child in ipairs(r4:GetChildren()) do
            if child:IsA("Model") then
                local Position = child:GetPivot().Position
                table.insert(r2, Position)
            end
        end
    end
    return r2
end
local function worker5()
    while not Library.Unloaded do
        if oB("AutoCollect") then
            onCollectNow()
        end
        task.wait(pA("CollectDelay", 0.5))
    end
end
local function worker3()
    while not Library.Unloaded do
        if oB("AutoRoll") then
            if oB("RollWaitNotRolling") then
                while true do
                    local x0 = not Library.Unloaded and oB("AutoRoll") and pn:GetAttribute("Rolling")
                    if x0 then
                        task.wait(0.1)
                        continue
                    end
                    break
                end
            end
            if oB("AutoRoll") then
                pB()
            end
        end
        task.wait(pA("RollDelay", 0.35))
    end
end
local function fn408()
    local xy_1
    local xx_1
    if identifyexecutor then
        xy_1, xx_1 = identifyexecutor()
        local xz = xy_1 ~= ""
        local xA = type(xy_1) == "string" and xz
        if xA then
            local xz_1 = type(xx_1) == "string" and xx_1 ~= "" and xy_1 .. " " .. xx_1
            ow = xz_1 or xy_1
        end
    end
end
local function fn452()
    local uz = oZ()
    local uz_2 = uz and uz.stats or {}
    local uA_1 = tonumber(uz_2.rebirth) or tonumber(uz_2.rebirths)
    return uA_1 or 0
end
local function worker7()
    while not Library.Unloaded do
        if oB("AutoSell") then
            pm()
        end
        task.wait(pA("SellDelay", 5))
    end
end
local function fn533(ag, ah)
    if setclipboard then
        setclipboard(ag)
    elseif toclipboard then
        toclipboard(ag)
    end
    Library:Notify(ah)
end
local function onInputChanged(jX)
    local UserInputType = jX.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        oH = tick()
    end
end
local function fn564(gj)
    local vK = o6(gj)
    if not vK then
        return 0
    end
    local vL = vK.real_rarity
    local vQ = if vL then 1 else 0
    local vO = 1927 * vQ + 1529 * (1 - vQ)
    local vP = 2517 * vQ + 2130 * (1 - vQ)
    if not ((vO * 3557 + vP * 3008 + vO * vP) % 16777213 == 2498521) then
        vL = "Common"
    end
    local vL_1 = pw[vL] or 0
    local vL_2 = tonumber(vK.price) or 0
    return vL_1 * 1000000000 + vL_2
end
local function fn571()
    local uX = pu()
    if not uX then
        return false
    end
    local uY = {}
    local uZ = uX.requirements
    local u2 = if uZ then 1 else 0
    local u0 = 3946 * u2 + 636 * (1 - u2)
    local u1 = 3458 * u2 + 2729 * (1 - u2)
    if not ((u0 * 2894 + u1 * 1217 + u0 * u1) % 16777213 == 12496165) then
        uZ = uY
    end
    local uX_1 = uZ
    local uY_1 = oT()
    local uZ_1 = tonumber(uX_1.money) or 0
    if uY_1 < uZ_1 then
        return false
    end
    local uZ_2 = uX_1.gnomes or {}
    for i, v in ipairs(uZ_2) do
        if not oY(v) then
            return false
        end
    end
    return true
end
local function fn572()
    local rd = oZ()
    local re = rd and tonumber(rd.max_inventory)
    return re or 100
end
local function worker11()
    while not Library.Unloaded do
        if oB("AutoReplace") then
            onReplaceNow()
        end
        task.wait(math.max(pA("ReplaceDelay", 0.4), 0.5))
    end
end
local function fn598()
    local td = oZ()
    local te = td and td.farmers
    if not te then
        return 0
    end
    local te_1 = 0
    for k in pairs(te) do
        te_1 += 1
    end
    return te_1
end
local function fn603()
    px(pd, "Copied Discord invite to clipboard")
end
local function fn611()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn617(d3, d4)
    local tL = not d3 or not next(d3)
    if tL then
        return true
    end
    return d3[d4] == true
end
local function worker15()
    while not Library.Unloaded do
        if oB("AutoDailyDeal") then
            o7()
        end
        task.wait(pA("DailyDealDelay", 5))
    end
end
local function fn631()
    local wv_1
    local wu_1
    wu_1, wv_1 = pcall(function()
        return o0:InvokeServer("GetDailyDeal")
    end)
    local ww = wu_1 and type(wv_1) == "table" and wv_1.ready == true
    if not ww then
        return
    end
    pcall(function()
        o0:InvokeServer("DailyDeal")
    end)
end
local function worker8()
    while not Library.Unloaded do
        if oB("AutoShop") then
            onBuyShopNow()
        end
        task.wait(pA("ShopDelay", 3))
    end
end
local function onRscripts()
    px(pb, "Copied Rscripts profile to clipboard")
end
local function fn658()
    local sS = {}
    local sT = { pn:FindFirstChild("Backpack"), pn.Character }
    for i, v in ipairs(sT) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local sT_1 = child:IsA("Tool") and child:GetAttribute("type") == "Farmer"
                if sT_1 then
                    table.insert(sS, child)
                end
            end
        end
    end
    return sS
end
local function fn659(O, P)
    return O.order < P.order
end
local function fn693()
    local q3 = oZ()
    local q4 = q3 and q3.stats
    local q3_1 = q4
    if q4 then
        q4 = tonumber(q3_1.money)
    end
    return q4 or 0
end
local function fn709()
    local vR = oZ()
    local vS = vR and vR.farmers
    if not vS then
        return {}
    end
    local vS_1 = pl()
    local vT = vS_1 and vS_1:FindFirstChild("ClientFarmers")
    local vS_2 = {}
    for k, v in pairs(vS) do
        local vR_2 = type(v) == "table" and type(v.name) == "string"
        if vR_2 then
            local vR_3 = tostring(k)
            local vT_1 = vT and vT:FindFirstChild(vR_3)
            local vV = vT_1
            local vW
            if vT_1 then
                vT_1 = vV:IsA("Model")
            end
            if vT_1 then
                vW = vV:GetPivot()
            else
                local position = v.position
                if type(position) == "table" then
                    local new = CFrame.new
                    local vX_1 = tonumber(position.x) or 0
                    local vY = tonumber(position.y) or 0
                    local vZ = tonumber(position.z) or 0
                    vW = new(vX_1, vY, vZ)
                end
            end
            if vW then
                local insert = table.insert
                local name = v.name
                local vX_2 = v.floor or "1"
                insert(vS_2, { id = vR_3, name = name, floor = tostring(vX_2), score = pv(v.name), cframe = vW })
            end
        end
    end
    table.sort(vS_2, function(gJ, gK)
        return gJ.score < gK.score
    end)
    return vS_2
end
local function worker9()
    while not Library.Unloaded do
        if oB("AutoUpgrade") then
            onBuyUpgradesNow()
        end
        task.wait(math.max(pA("UpgradeDelay", 0.35), 0.5))
    end
end
local function fn715()
    local tG = pA("SellThreshold", 1)
    local tK = if oD() < tG then 1 else 0
    if tK == 1 then
        return
    end
    pcall(function()
        o0:InvokeServer("SellAll")
    end)
end
local function fn723(aE, aF)
    local qU = Options[aE]
    local qV = qU and tonumber(qU.Value)
    return qV or aF
end
local function worker13()
    while not Library.Unloaded do
        if oB("AutoRebirth") then
            oU()
        end
        task.wait(pA("RebirthDelay", 2))
    end
end
local function worker12()
    while not Library.Unloaded do
        local yf = oB("AutoSprinkler") or oB("AutoFertilizer")
        if yf then
            pa()
        end
        task.wait(math.max(pA("BoostDelay", 0.4), 1))
    end
end
local function fn807(hP)
    local wW = oZ()
    local wX = hP == "Sprinkler"
    if wX then
        wX = wW and wW.sprinklers
    end
    local wY_2 = wX
    local w1 = if wY_2 then 1 else 0
    local w_ = 2844 * w1 + 2413 * (1 - w1)
    local w0 = 406 * w1 + 3558 * (1 - w1)
    if not ((w_ * 109 + w0 * 4093 + w_ * w0) % 16777213 == 3126418) then
        wY_2 = wW and wW.fertilizer
    end
    local wW_1 = wY_2
    local wX_2 = type(wW_1) == "table" and next(wW_1)
    if wX_2 then
        local wX_3 = 0
        for k in pairs(wW_1) do
            wX_3 += 1
        end
        return wX_3
    end
    local wW_2 = pl()
    if not wW_2 then
        return 0
    end
    local wX_4 = 0
    for i, descendant in ipairs(wW_2:GetDescendants()) do
        local wW_3 = descendant:IsA("Model") and descendant:GetAttribute("TimeRemaining") ~= nil
        if wW_3 then
            local wW_4 = descendant:GetAttribute("ItemName") or descendant.Name
            if hP == "Sprinkler" and oq[wW_4] then
                wX_4 += 1
            else
                if hP == "Fertilizer" and oj[wW_4] then
                    wX_4 += 1
                end
            end
        end
    end
    return wX_4
end
local function fn818()
    if not pk() then
        return
    end
    pcall(function()
        o0:InvokeServer("Rebirth")
    end)
end
local function fn833(fg)
    local uH = oZ()
    local uH_1 = uH and uH.discovered
    if not uH_1 then
        return false
    elseif uH_1[fg] == true then
        return true
    else
        return table.find(uH_1, fg) ~= nil
    end
end
local function worker()
    local xG_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local xF = math.floor(os.clock() - o2)
        if xF < 60 then
            xG_1 = xF .. "s"
        elseif xF < 3600 then
            xG_1 = string.format("%dm %ds", math.floor((xF) / (60)), xF % 60)
        else
            xG_1 = string.format("%dh %dm", math.floor((xF) / (3600)), math.floor((xF % 3600) / (60)))
        end
        ps:SetText(oX("Session time", xG_1, oG))
    end
end
local function fn850(aK)
    local qX = Options[aK]
    local qY = qX and qX.Value
    local qX_1 = {}
    local qZ = qY
    local q2 = if qZ then 1 else 0
    local q0 = 3726 * q2 + 1638 * (1 - q2)
    local q1 = 165 * q2 + 713 * (1 - q2)
    if not ((q0 * 2446 + q1 * 1939 + q0 * q1) % 16777213 == 10048521) then
        qZ = qX_1
    end
    return qZ
end
local function worker4()
    while not Library.Unloaded do
        if oB("AutoBuyRoll") then
            onBuyRollNow()
        end
        task.wait(pA("BuyRollDelay", 0.2))
    end
end
local function fn876()
    return oE[("Rebirth%d"):format(oy() + 1)]
end
local function fn901(aq, ar, as)
    return string.format("<b>%s</b> %s %s", aq, o8("-", "#5a6070"), o8(ar, as))
end
local function fn903(fr)
    local uR = oB("KeepRequiredRebirthGnomes") and oI(fr)
    if uR then
        return true
    end
    local uR_1 = pg("KeepGnomes")
    return uR_1 ~= nil and uR_1[fr] == true
end
local function fn904()
    local CurrentCamera = pr.CurrentCamera
    if not CurrentCamera then
        return
    end
    pt:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    pt:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    oF = tick()
end
local function fn922(bm)
    local rq = bm or 0
    return oD() < math.max(py() - rq, 0)
end
local function fn950(cm, cn, co)
    local sc = cn * cn
    for i, v in ipairs(co) do
        local sd = cm.X - v.X
        local se = cm.Z - v.Z
        if sd * sd + se * se < sc then
            return false
        end
    end
    return true
end
local function worker14()
    while not Library.Unloaded do
        if oB("AutoExpand") then
            onExpandNow()
        end
        task.wait(math.max(pA("ExpandDelay", 0.5), 0.5))
    end
end
local function fn982()
    local Plot = pn:FindFirstChild("Plot")
    return Plot and Plot.Value
end
local function fn993()
    if pn:GetAttribute("Rolling") then
        return
    end
    local rt = oB("RollRequireRoom") and not oC(pA("RollLeaveSlots", 2))
    if rt then
        return
    end
    pcall(function()
        o0:InvokeServer("Roll")
    end)
end
oj = nil
Toggles = nil
onBuyRollNow = nil
on = nil
onPlaceNow = nil
oq = nil
ow = nil
Library = nil
oy = nil
oA = nil
oB = nil
oC = nil
oD = nil
oE = nil
oF = nil
oG = nil
oH = nil
oI = nil
oN = nil
oO = nil
onReplaceNow = nil
onBuyShopNow = nil
onBuyUpgradesNow = nil
oT = nil
oU = nil
oV = nil
oW = nil
oX = nil
oY = nil
oZ = nil
o0 = nil
onCollectNow = nil
o2 = nil
Replication = nil
connection2 = nil
o6 = nil
o7 = nil
o8 = nil
local op, ot, ou, ov, oz, oJ, oK, oL, oM, oR, o_, o3
pa = nil
pb = nil
pc = nil
pd = nil
onSellAllGnomesNow = nil
pg = nil
ph = nil
pi = nil
pk = nil
pl = nil
pm = nil
pn = nil
po = nil
connection = nil
onExpandNow = nil
pr = nil
ps = nil
pt = nil
pu = nil
pv = nil
pw = nil
px = nil
py = nil
Options = nil
pA = nil
pB = nil
local o9, pf, pj, pU
o9 = nil
pf = nil
pj = nil
local ItemShopGroup, AutoReplaceGroup, AutoPlaceGroup
yo_18, yo_5, UserInputService, pt, pr, pn, yo_14, pd, pb, yo_21, Replication, o0, yo_12 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local yo_2 = 4
repeat
    yo_7 = (yo_2 * 1 + 5) % 8 + 1
    if yo_7 <= 4 then
        if yo_7 <= 2 then
            if yo_7 <= 1 then
                if (pt or not pr or (not yo_5 or not pr) or (not yo_5 and not pb or not UserInputService and not yo_5)) and ((pt or not yo_5) and (pb or pr) and (not pb and not pb or pb and yo_18)) or not ((pt or not pr or (not yo_5 or not pr) or (not yo_5 and not pb or not UserInputService and not yo_5)) and ((pt or not yo_5) and (pb or pr) and (not pb and not pb or pb and yo_18))) then
                    yo_12 = (yo_21.get("Farmers"))
                else
                    yo_21 = (yo_12.get("Farmers"))
                end
                yo_2 = (yo_2 + 41) % 64
            else
                if yo_2 * 108330051 + 8 + 1 <= yo_2 * 108330051 + 8 + 1 + 1 then
                    yo_18 = game:GetService("Players")
                else
                    pr = game:GetService("Players")
                end
                yo_2 = (yo_2 + 1) % 64
            end
        elseif yo_7 <= 3 then
            yo_17 = (vector.create((yo_2 * 7 + 2) % 11 + 1, (yo_2 * 8 + 4) % 13 + 1, (yo_2 * 2 + 10) % 17 + 1))
            yo_26 = (vector.create((yo_2 * 4 + 1) % 11 + 1, (yo_2 * 8 + 1) % 13 + 1, (yo_2 * 4 + 6) % 17 + 1))
            yo_10 = (vector.create((yo_2 * 4 + 5) % 11 + 1, (yo_2 * 7 + 13) % 13 + 1, (yo_2 * 1 + 11) % 17 + 1))
            yo_19 = (vector.create((yo_2 * 4 + 6) % 11 + 1, (yo_2 * 9 + 10) % 13 + 1, (yo_2 * 3 + 6) % 17 + 1))
            if vector.dot(vector.cross(yo_17, yo_26), (vector.cross(yo_10, yo_19))) == vector.dot(yo_17, yo_10) * vector.dot(yo_26, yo_19) - vector.dot(yo_17, yo_19) * vector.dot(yo_26, yo_10) then
                yo_5 = game:GetService("ReplicatedStorage")
            else
                pt = game:GetService("ReplicatedStorage")
            end
            yo_2 = (yo_2 + 49) % 64
        else
            if (yo_18 or not o0 or yo_18 and not yo_18) and ((not yo_18 or yo_18) and (yo_2 and UserInputService)) and not ((yo_18 or not o0 or yo_18 and not yo_18) and ((not yo_18 or yo_18) and (yo_2 and UserInputService))) then
                pr = game:GetService("UserInputService")
            else
                UserInputService = game:GetService("UserInputService")
            end
            yo_2 = (yo_2 + 57) % 64
        end
    elseif yo_7 <= 6 then
        if yo_7 <= 5 then
            if ((not pr or not yo_5) and (not pr or not yo_2) and ((yo_2 or not pr) and (not yo_5 or not pr)) or (not yo_5 or not yo_5 or yo_2 and yo_2 or not pr and not pr and (yo_5 and not yo_2))) and (pr and pr and (yo_5 and yo_5) and (not yo_2 or yo_2 or (yo_5 or pr)) or (not yo_2 and yo_5 or pr and not yo_2) and (not pr and yo_5 and (not pr and pr))) and not (((not pr or not yo_5) and (not pr or not yo_2) and ((yo_2 or not pr) and (not yo_5 or not pr)) or (not yo_5 or not yo_5 or yo_2 and yo_2 or not pr and not pr and (yo_5 and not yo_2))) and (pr and pr and (yo_5 and yo_5) and (not yo_2 or yo_2 or (yo_5 or pr)) or (not yo_2 and yo_5 or pr and not yo_2) and (not pr and yo_5 and (not pr and pr)))) then
                pr = game:GetService("VirtualUser")
                pt = game:GetService("Workspace")
            else
                pt = game:GetService("VirtualUser")
                pr = game:GetService("Workspace")
            end
            yo_2 = (yo_2 + 17) % 64
        else
            yo_17 = (vector.create((yo_2 * 5 + 8) % 11 + 1, (yo_2 * 8 + 7) % 13 + 1, (yo_2 * 9 + 6) % 17 + 1))
            yo_26 = (vector.create((yo_2 * 2 + 3) % 11 + 1, (yo_2 * 1 + 11) % 13 + 1, (yo_2 * 12 + 5) % 17 + 1))
            local zH = vector.dot(yo_17, yo_26)
            if zH * zH >= vector.dot(yo_17, yo_17) * vector.dot(yo_26, yo_26) + 1 then
                yo_18 = nil
                pb = "Roll A Gnome"
                pn = "https://discord.gg/K7Qxnxkk46"
                pd = "https://discord.gg/K7Qxnxkk46"
            else
                pn = yo_18.LocalPlayer
                yo_14 = "Roll A Gnome"
                pd = "https://discord.gg/K7Qxnxkk46"
                pb = "https://discord.gg/K7Qxnxkk46"
            end
            yo_2 = (yo_2 + 1) % 64
        end
    elseif yo_7 <= 7 then
        yo_7 = (vector.create((yo_2 * 7 + 7) % 11 + 1, (yo_2 * 7 + 13) % 13 + 1, (yo_2 * 6 + 3) % 17 + 1))
        yo_17 = (vector.create((yo_2 * 1 + 8) % 11 + 1, (yo_2 * 9 + 11) % 13 + 1, (yo_2 * 2 + 7) % 17 + 1))
        yo_26 = (vector.create((yo_2 * 4 + 9) % 11 + 1, (yo_2 * 6 + 10) % 13 + 1, (yo_2 * 10 + 15) % 17 + 1))
        yo_10 = (vector.create((yo_2 * 2 + 6) % 11 + 1, (yo_2 * 4 + 13) % 13 + 1, (yo_2 * 11 + 9) % 17 + 1))
        if vector.dot(vector.cross(yo_7, yo_17), (vector.cross(yo_26, yo_10))) == vector.dot(yo_7, yo_26) * vector.dot(yo_17, yo_10) - vector.dot(yo_7, yo_10) * vector.dot(yo_17, yo_26) then
            yo_21 = require(yo_5:WaitForChild("Library"))
        else
            yo_5 = require(yo_21:WaitForChild("Library"))
        end
        yo_2 = (yo_2 + 17) % 64
    else
        local yZ = bit32.rrotate(bit32.bxor(bit32.lrotate(yo_2, 10), string.byte(tostring(pb))), 11)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(yZ, 3443460745), 2498941847), (bit32.bxor(bit32.band(yZ, 851506550), 2524904637))), 2498941847), 2524904637) ~= yZ then
            yo_5 = require(Replication:WaitForChild("Replication"))
            yo_21 = o0.get("Network")
        else
            Replication = require(yo_5:WaitForChild("Replication"))
            o0 = yo_21.get("Network")
        end
        yo_2 = (yo_2 + 49) % 64
    end
until (yo_2 * 13 + 10) % 64 == 6
if not yo_12 then
    yo_18 = 1
    repeat
        yo_2 = (vector.create((yo_18 * 5 + 6) % 11 + 1, (yo_18 * 9 + 4) % 13 + 1, (yo_18 * 14 + 8) % 17 + 1))
        local zZ = vector.floor(yo_2) + vector.ceil(yo_2 * -1)
        if vector.dot(zZ, zZ) == 2 then
            yo_5 = require(yo_12.Library.Configs.Farmers)
        else
            yo_12 = require(yo_5.Library.Configs.Farmers)
        end
        yo_18 = (yo_18 + 1) % 8
    until (yo_18 * 3 + 7) % 8 == 5
end
oV = nil
oV = yo_12
yo_7 = (yo_21.get("ItemShop"))
if not yo_7 then
    yo_18 = 0
    repeat
        local zf = bit32.rrotate(bit32.bxor(bit32.lrotate(yo_18, 25), string.byte(tostring(yo_18))), 19)
        if bit32.bxor(bit32.lrotate(bit32.bxor(zf, 1869988182), 0), 1869988182) == bit32.lrotate(zf, 0) then
            yo_7 = require(yo_5.Library.Configs.ItemShop)
        else
            yo_5 = require(yo_7.Library.Configs.ItemShop)
        end
        yo_18 = (yo_18 + 3) % 8
    until (yo_18 * 3 + 5) % 8 == 6
end
oR, yo_12 = nil, nil
yo_2 = 7
repeat
    yo_18 = (yo_2 * 1 + 0) % 2 + 1
    if yo_18 <= 1 then
        local y9 = bit32.rrotate(bit32.bxor(bit32.lrotate(yo_2, 11), string.byte(tostring(yo_12))), 4)
        if bit32.bxor(bit32.lrotate(bit32.bxor(y9, 1701502620), 0), 1701502620) ~= bit32.lrotate(y9, 0) then
            yo_21 = (yo_12.get("Upgrade Tree"))
        else
            yo_12 = (yo_21.get("Upgrade Tree"))
        end
        yo_2 = (yo_2 + 5) % 8
    else
        local zI = bit32.rrotate(bit32.bxor(bit32.lrotate(yo_2, 28), string.byte(tostring(yo_12))), 1)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(zI, 190148333), 3426983127), (bit32.bxor(bit32.band(zI, 4104818962), 2164909945))), 3426983127), 2164909945) == zI then
            oR = yo_7
        else
            yo_7 = oR
        end
        yo_2 = (yo_2 + 5) % 8
    end
until (yo_2 * 7 + 1) % 8 == 0
if not yo_12 then
    yo_18 = 0
    repeat
        yo_2 = {
            "ozj",
            "fehti",
            "ajwsl",
            "takytqvmum",
            "dblxbjit",
            "scecjetp",
            "mkwsk",
            "scei",
            "hzwnnyddned",
            "smtgsx",
            "gdbj"
        }
        local zi = yo_18
        yo_7 = yo_2[zi % 11 + 1]
        if yo_7:len() <= yo_7:gsub("(.)", "%1%1", zi % 3 % 2 + 1):len() then
            yo_12 = require(yo_5.Library.Configs["Upgrade Tree"])
        else
            yo_5 = require(yo_12.Library.Configs["Upgrade Tree"])
        end
        yo_18 = (yo_18 + 3) % 4
    until (yo_18 * 3 + 3) % 4 == 0
end
oL, yo_7 = nil, nil
yo_2 = 11
repeat
    yo_18 = (yo_2 * 1 + 1) % 2 + 1
    if yo_18 <= 1 then
        yo_18 = {
            "ayibvqivrr",
            "vjfxrfycytem",
            "fijrsunvqtu",
            "zqzbgjkdyq",
            "urwtyiwq",
            "bkdbdt",
            "manaimtpk",
            "erqo",
            "pviaij",
            "eetdnedmk",
            "pouyetwh",
            "ycpuefxrx",
            "gisupqc",
            "aseoaoedjtan"
        }
        if yo_18[(yo_2 * 93 + 70) % 14 + 1] <= yo_18[(yo_2 * 93 + 70) % 14 + 1] then
            oL = yo_12
        else
            yo_12 = oL
        end
        yo_2 = (yo_2 + 7) % 16
    else
        yo_18 = { "lfj", "qxgmvgdi", "qqxkkte", "ohmynisq", "bhddbk", "spj", "blf" }
        local zs = yo_2
        yo_17 = yo_18[zs % 7 + 1]
        if yo_17:len() >= yo_17:reverse():rep(zs % 3 + 2):len() then
            yo_21 = (yo_7.get("Rebirths"))
        else
            yo_7 = (yo_21.get("Rebirths"))
        end
        yo_2 = (yo_2 + 13) % 16
    end
until (yo_2 * 13 + 5) % 16 == 8
if not yo_7 then
    yo_18 = 2
    repeat
        yo_2 = (vector.create((yo_18 * 5 + 8) % 11 + 1, (yo_18 * 5 + 3) % 13 + 1, (yo_18 * 15 + 8) % 17 + 1))
        yo_12 = (vector.create((yo_18 * 3 + 7) % 11 + 1, (yo_18 * 6 + 10) % 13 + 1, (yo_18 * 1 + 15) % 17 + 1))
        yo_17 = (vector.create((yo_18 * 1 + 2) % 5 + 1, (yo_18 * 1 + 7) % 7 + 1, (yo_18 * 4 + 1) % 9 + 1))
        if math.abs((vector.angle(yo_2, yo_12, yo_17))) - math.abs((vector.angle(yo_12, yo_2, yo_17))) == 0 then
            yo_7 = require(yo_5.Library.Configs.Rebirths)
        else
            yo_5 = require(yo_7.Library.Configs.Rebirths)
        end
        yo_18 = (yo_18 + 1) % 8
    until (yo_18 * 1 + 0) % 8 == 3
end
oE = nil
oE = yo_7
yo_12 = (yo_21.get("Expand"))
if not yo_12 then
    yo_18 = 3
    repeat
        if (yo_18 * 3 + 7) * 13 % 4 == ((yo_18 * 3 + 7) * 13 + 15) % 4 then
            yo_5 = require(yo_12.Library.Configs.Expand)
        else
            yo_12 = require(yo_5.Library.Configs.Expand)
        end
        yo_18 = (yo_18 + 7) % 8
    until (yo_18 * 3 + 2) % 8 == 0
end
oA, yo_7 = nil, nil
yo_2 = 5
repeat
    yo_18 = (yo_2 * 1 + 0) % 2 + 1
    if yo_18 <= 1 then
        yo_18 = (vector.create((yo_2 * 2 + 2) % 11 + 1, (yo_2 * 7 + 10) % 13 + 1, (yo_2 * 9 + 13) % 17 + 1))
        yo_17 = (vector.create((yo_2 * 5 + 3) % 11 + 1, (yo_2 * 11 + 3) % 13 + 1, (yo_2 * 15 + 7) % 17 + 1))
        local y3 = vector.cross(yo_18, yo_17)
        local y4 = vector.dot(yo_18, yo_17)
        if vector.dot(y3, y3) + y4 * y4 == vector.dot(yo_18, yo_18) * vector.dot(yo_17, yo_17) then
            yo_7 = (yo_21.get("Sprinklers"))
        else
            yo_21 = (yo_7.get("Sprinklers"))
        end
        yo_2 = (yo_2 + 1) % 8
    else
        yo_18 = (vector.create((yo_2 * 2 + 5) % 11 + 1, (yo_2 * 11 + 8) % 13 + 1, (yo_2 * 9 + 10) % 17 + 1))
        local zV = vector.floor(yo_18) + vector.ceil(yo_18 * -1)
        if vector.dot(zV, zV) == 1 then
            yo_12 = oA
        else
            oA = yo_12
        end
        yo_2 = (yo_2 + 7) % 8
    end
until (yo_2 * 1 + 4) % 8 == 1
if not yo_7 then
    yo_18 = 5
    repeat
        yo_2 = (vector.create((yo_18 * 7 + 9) % 11 + 1, (yo_18 * 7 + 2) % 13 + 1, (yo_18 * 7 + 16) % 17 + 1))
        yo_12 = (vector.create((yo_18 * 6 + 2) % 11 + 1, (yo_18 * 7 + 11) % 13 + 1, (yo_18 * 14 + 1) % 17 + 1))
        yo_17 = (vector.create((yo_18 * 1 + 9) % 11 + 1, (yo_18 * 4 + 12) % 13 + 1, (yo_18 * 9 + 13) % 17 + 1))
        yo_26 = (vector.create((yo_18 * 1 + 4) % 11 + 1, (yo_18 * 7 + 1) % 13 + 1, (yo_18 * 14 + 11) % 17 + 1))
        if vector.dot(vector.cross(yo_2, yo_12), (vector.cross(yo_17, yo_26))) == vector.dot(yo_2, yo_17) * vector.dot(yo_12, yo_26) - vector.dot(yo_2, yo_26) * vector.dot(yo_12, yo_17) + 2 then
            yo_5 = require(yo_7.Library.Configs.Sprinklers)
        else
            yo_7 = require(yo_5.Library.Configs.Sprinklers)
        end
        yo_18 = (yo_18 + 3) % 8
    until (yo_18 * 7 + 4) % 8 == 4
end
oq, yo_12 = nil, nil
yo_2 = 1
repeat
    yo_18 = (yo_2 * 1 + 1) % 2 + 1
    if yo_18 <= 1 then
        yo_18 = { "qgild", "can", "frpckwzhn", "ctqzyoohsq", "kdqqjxhv", "kuambaxe", "ytt", "ukbhqljvfhk" }
        local zP = yo_2
        yo_17 = yo_18[zP % 8 + 1]
        if yo_17:len() >= yo_17:gsub("(.)", "%1%1", zP % 3 % 2 + 1):len() then
            yo_7 = oq
        else
            oq = yo_7
        end
        yo_2 = (yo_2 + 9) % 16
    else
        local z0 = bit32.rrotate(bit32.bxor(bit32.lrotate(yo_2, 5), string.byte(tostring(oq))), 13)
        if bit32.bxor(bit32.lrotate(bit32.bxor(z0, 2821798646), 20), 2942993171) == bit32.lrotate(z0, 20) then
            yo_12 = (yo_21.get("Fertilizer"))
        else
            yo_21 = (yo_12.get("Fertilizer"))
        end
        yo_2 = (yo_2 + 1) % 16
    end
until (yo_2 * 1 + 6) % 16 == 1
if not yo_12 then
    yo_18 = 2
    repeat
        yo_2 = (vector.create((yo_18 * 1 + 5) % 11 + 1, (yo_18 * 6 + 5) % 13 + 1, (yo_18 * 13 + 13) % 17 + 1))
        local zj = vector.floor(yo_2) + vector.ceil(yo_2 * -1)
        if vector.dot(zj, zj) == 5 then
            yo_5 = require(yo_12.Library.Configs.Fertilizer)
        else
            yo_12 = require(yo_5.Library.Configs.Fertilizer)
        end
        yo_18 = (yo_18 + 5) % 8
    until (yo_18 * 3 + 3) % 8 == 0
end
oj, pw = nil, nil
oj = yo_12
yo_21 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Godly", "IMPOSSIBLE" }
pw = {}
for i, v in ipairs(yo_21) do
    pw[v] = i
end
yo_18 = {}
yo_2 = {}
for k, v in pairs(oV) do
    yo_12 = type(v) == "table" and v.real_rarity
    if yo_12 then
        yo_12 = table.insert
        yo_5 = v.order or 0
        yo_12(yo_2, { name = k, order = yo_5 })
    end
end
yo_7 = 3
repeat
    local zG = bit32.rrotate(bit32.bxor(bit32.lrotate(yo_7, 27), string.byte(tostring(yo_7))), 9)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(zG, 4112926037), 327903069), (bit32.bxor(bit32.band(zG, 182041258), 2066992110))), 327903069), 2066992110) == zG then
        table.sort(yo_2, fn659)
    else
        table.sort(yo_2, fn659)
    end
    yo_7 = (yo_7 + 1) % 4
until (yo_7 * 3 + 1) % 4 == 1
for i, v in ipairs(yo_2) do
    table.insert(yo_18, v.name)
end
yo_2 = {}
yo_12 = oR.Items or oR
yo_5 = yo_12
for k in pairs(yo_5) do
    if type(k) == "string" then
        table.insert(yo_2, k)
    end
end
table.sort(yo_2)
yo_12 = {}
yo_5 = {}
yo_7 = oq or yo_5
for k in pairs(yo_7) do
    if type(k) == "string" then
        table.insert(yo_12, k)
    end
end
table.sort(yo_12)
yo_5 = {}
yo_7 = {}
yo_17 = oj or yo_7
for k in pairs(yo_17) do
    if type(k) == "string" then
        table.insert(yo_5, k)
    end
end
table.sort(yo_5)
Library, Toggles, Options, oG, px, ph, o8, oX, oB, pA, pg, oZ, oT, oD, py, pl, o6, oW, oN, oC, pB, o9, onBuyRollNow, onCollectNow, ot, pf, oO, oz, pj, oM, onPlaceNow, pm, o_, onBuyShopNow, onBuyUpgradesNow, oy, pu, pi, oY, oI, ou, pk, oU, oJ, onExpandNow, oK, pv, o3, onSellAllGnomesNow, o7, onReplaceNow, ov, op, pc, pa, yo_19 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
px = fn533
ph = fn603
o8 = fns.fn23
oX = fn901
local pS = "#7fd47f"
local pR = "#6ec1ff"
if (not Options or yo_19 or (not Options or not pj) or (not oZ or yo_19) and (Options and ph) or (not ph and oZ or (oZ or ph)) and (not ph or yo_19 or (not ph or yo_19))) and ((pj and pj or not Options and pj) and (ph and not Options and (not Options or not oZ)) or ((yo_19 or not yo_19) and (not yo_19 and not yo_19) or (oZ or not Options) and (not pj or not oZ))) or not ((not Options or yo_19 or (not Options or not pj) or (not oZ or yo_19) and (Options and ph) or (not ph and oZ or (oZ or ph)) and (not ph or yo_19 or (not ph or yo_19))) and ((pj and pj or not Options and pj) and (ph and not Options and (not Options or not oZ)) or ((yo_19 or not yo_19) and (not yo_19 and not yo_19) or (oZ or not Options) and (not pj or not oZ)))) then
    oG = "#e8a34d"
    yo_23 = "#8b93a3"
    oB = fn369
else
    oB = "#e8a34d"
    oG = "#8b93a3"
    yo_23 = fn369
end
pA = fn723
pg = fn850
oZ = fn350
oT = fn693
oD = fn334
py = fn572
pl = fn982
o6 = fn372
oW = fns.fn85
oN = fns.fn93
oC = fn922
pB = fn993
o9 = fns.fn191
onBuyRollNow = function()
    local rC = pl()
    local rD = rC and rC:FindFirstChild("RNG") and rC.RNG:FindFirstChild("Preview")
    if not rD then
        return
    end
    for i, child in ipairs(rD:GetChildren()) do
        local rN = child
        if o9(rN) then
            pcall(function()
                o0:FireServer("BuyFarmer", rN)
            end)
            task.wait(pA("BuyRollDelay", 0.2))
        end
    end
end
onCollectNow = function()
    local rO = pl()
    if not rO then
        return
    end
    local rP = { rO:FindFirstChild("ReadyToCollect"), rO:FindFirstChild("Plants") }
    for i, v in ipairs(rP) do
        if v then
            for i, descendant in ipairs(v:GetDescendants()) do
                local r1 = descendant
                local rO_1 = r1:IsA("Model") and r1:GetAttribute("READY") == true and r1:GetAttribute("FruitReady") ~= false
                if rO_1 then
                    pcall(function()
                        o0:InvokeServer("CollectPlant", r1)
                    end)
                    task.wait(0.05)
                end
            end
        end
    end
end
ot = fn378
pf = fn950
oO = fn273
if (not pg and not pg and (pu or not pk) and (not pk or pg or (pg or pk)) or not pg and not pu and (pu and not pg) and (not pk and not pk and (not pk and pk))) and not (not pg and not pg and (pu or not pk) and (not pk or pg or (pg or pk)) or not pg and not pu and (pu and not pg) and (not pk and not pk and (not pk and pk))) then
    oN = fn658
else
    oz = fn658
end
pj = fn250
oM = fn598
onPlaceNow = function()
    local tn = pA("PlaceMaxGnomes", 0)
    local to = tn > 0 and oM() >= tn
    if to then
        return
    end
    local to_1 = oz()
    if #to_1 == 0 then
        return
    end
    local tp = pA("PlaceSpacing", 4)
    local tq = oO(tp)
    if #tq == 0 then
        return
    end
    local tr = ot()
    local ts = pn.Character and pn.Character:FindFirstChildOfClass("Humanoid")
    local tl = ts
    if not tl then
        return
    end
    for i, v in ipairs(to_1) do
        local tk, tm
        local tz = v
        local to_2 = tn > 0 and oM() >= tn
        if to_2 then
            break
        elseif pj(tz) then
            local to_3 = nil
            for i, v in ipairs(tq) do
                if pf(v, tp, tr) then
                    to_3 = v
                    break
                end
            end
            if to_3 then
                pcall(function()
                    tl:EquipTool(tz)
                end)
                task.wait(0.15)
                local ts_1 = tz:GetAttribute("FarmerName") or tz.Name
                tk = ts_1
                tm = CFrame.new(to_3)
                pcall(function()
                    o0:FireServer("Place", "Farmer", tk, tm, "1")
                end)
                table.insert(tr, to_3)
                task.wait(pA("PlaceDelay", 0.35))
            end
        end
    end
end
pm = fn715
o_ = fn617
onBuyShopNow = function()
    local tN_1
    local tO_1
    tN_1, tO_1 = pcall(function()
        return o0:InvokeServer("GetStock")
    end)
    local tP = tN_1 and type(tO_1) == "table"
    if not tP then
        return
    end
    local tN_2 = {}
    local tP_1 = oR.Items
    local tX = if tP_1 then 1 else 0
    local tV = 3054 * tX + 1477 * (1 - tX)
    local tW = 711 * tX + 3931 * (1 - tX)
    if not ((tV * 2391 + tW * 2864 + tV * tW) % 16777213 == 11509812) then
        tP_1 = tN_2
    end
    local tN_3 = tP_1
    local tP_2 = pA("ShopMoneyBuffer", 0)
    local tQ = pA("ShopMaxPrice", 0)
    local tR = pg("ShopItems")
    for k, v in pairs(tO_1) do
        local t0 = k
        local tO_2 = tonumber(v) or 0
        local tS = tO_2 > 0 and o_(tR, t0)
        if tS then
            local tO_3 = tN_3[t0]
            local tS_1 = tO_3 and tonumber(tO_3.price)
            local tS_2 = tS_1 or 0
            local tO_5 = tQ <= 0 or tS_2 <= tQ
            local tT = tO_5 and oT() - tS_2 >= tP_2
            if tT then
                pcall(function()
                    o0:InvokeServer("Purchase", t0)
                end)
                task.wait(pA("ShopBuyDelay", 0.25))
            end
        end
    end
end
onBuyUpgradesNow = function()
    local t4 = oZ()
    if not t4 then
        return
    end
    local t6 = t4.upgrade_tree or {}
    local t5_1 = pA("UpgradeMoneyBuffer", 0)
    local t6_1 = pA("UpgradeMaxPrice", 0)
    local t7 = oT()
    for k, v in pairs(oL) do
        if type(v) == "table" then
            local t8 = {}
            for k2, v in pairs(v) do
                local t9 = type(v) == "table" and v.Price ~= nil and not v.OpensPage and not v.BackButton and t6[k2] ~= true
                if t9 then
                    local t9_1 = true
                    local ub = v.Requires or {}
                    for i, v in ipairs(ub) do
                        if t6[v] ~= true then
                            t9_1 = false
                            break
                        end
                    end
                    local ua_1 = tonumber(v.Price) or 0
                    local ub_1 = t9_1
                    if ub_1 then
                        ub_1 = ua_1 > 0
                    end
                    if ub_1 then
                        ub_1 = t7 - ua_1 >= t5_1
                    end
                    if ub_1 then
                        ub_1 = t6_1 <= 0 or ua_1 <= t6_1
                    end
                    if ub_1 then
                        table.insert(t8, { page = k, id = k2, price = ua_1 })
                    end
                end
            end
            table.sort(t8, function(eS, eT)
                return eS.price < eT.price
            end)
            for i, v in ipairs(t8) do
                local t3
                local uy = v
                if oT() - uy.price < t5_1 then
                    break
                end
                t3 = false
                pcall(function()
                    t3 = o0:InvokeServer("Upgrade", uy.page, uy.id) == true
                end)
                if t3 then
                    t6[uy.id] = true
                    task.wait(pA("UpgradeDelay", 0.35))
                end
            end
        end
    end
end
oy = fn452
pu = fn876
pi = fn326
oY = fn833
oI = fns.fn117
ou = fn903
pk = fn571
oU = fn818
oJ = fns.fn118
onExpandNow = function()
    local vk = pA("ExpandMoneyBuffer", 0)
    local vl = pA("ExpandMaxPrice", 0)
    for i, v in ipairs(oJ()) do
        local vu = v
        local vm = vu.price > 0 and (vl <= 0 or vu.price <= vl) and oT() - vu.price >= vk
        if vm then
            pcall(function()
                o0:FireServer("ExpandPlot", vu.model)
            end)
            task.wait(pA("ExpandDelay", 0.5))
            break
        end
    end
end
oK = fns.fn20
pv = fn564
o3 = fn709
onSellAllGnomesNow = function()
    local wa = oB("KeepRequiredRebirthGnomes")
    local wb = pg("KeepGnomes")
    local wc = wb and next(wb) ~= nil
    local wc_1 = not wc
    local wd = not wa
    if wd ~= false then
        wd = wc_1
    end
    if wd then
        pcall(function()
            o0:InvokeServer("SellAllGnomes")
        end)
        return
    end
    local wa_1 = pn.Character and pn.Character:FindFirstChildOfClass("Humanoid")
    local v9 = wa_1
    if not v9 then
        return
    end
    for i, v in ipairs(o3()) do
        local wn = v
        if not ou(wn.name) then
            pcall(function()
                o0:FireServer("PickupFarmer", wn.id)
            end)
            task.wait(0.2)
        end
    end
    for i, v in ipairs(oK("Farmer")) do
        local wt = v
        local wa_2 = wt:GetAttribute("FarmerName") or wt.Name
        if not ou(wa_2) then
            pcall(function()
                v9:EquipTool(wt)
            end)
            task.wait(0.1)
            pcall(function()
                o0:InvokeServer("SellGnome")
            end)
            task.wait(pA("SellGnomesDelay", 0.35))
        end
    end
end
o7 = fn631
onReplaceNow = function()
    local wA = pn.Character and pn.Character:FindFirstChildOfClass("Humanoid")
    local wy = wA
    if not wy then
        return
    end
    local wA_1 = oK("Farmer")
    if #wA_1 == 0 then
        return
    end
    local wB = {}
    for i, v in ipairs(wA_1) do
        local wA_2 = v:GetAttribute("FarmerName") or v.Name
        table.insert(wB, { tool = v, name = wA_2, score = pv(wA_2) })
    end
    table.sort(wB, function(hu, hv)
        return hu.score > hv.score
    end)
    if #wB == 0 then
        return
    end
    local wA_3 = {}
    for i, v in ipairs(o3()) do
        local wP = v
        if not ou(wP.name) then
            local wz
            for i, v in ipairs(wB) do
                local wC_2 = not wA_3[v.tool]
                if wC_2 ~= false then
                    wC_2 = v.score > wP.score
                end
                if wC_2 then
                    wz = v
                    break
                end
            end
            if wz then
                wA_3[wz.tool] = true
                pcall(function()
                    o0:FireServer("PickupFarmer", wP.id)
                end)
                task.wait(0.2)
                pcall(function()
                    wy:EquipTool(wz.tool)
                end)
                task.wait(0.15)
                pcall(function()
                    o0:FireServer("Place", "Farmer", wz.name, wP.cframe, wP.floor)
                end)
                task.wait(pA("ReplaceDelay", 0.4))
            end
        end
    end
end
ov = fn807
op = fn258
pc = function(io, ip, iq)
    local xl = iq > 0 and ov(io) >= iq
    if xl then
        return
    end
    local xl_1 = pn.Character and pn.Character:FindFirstChildOfClass("Humanoid")
    local xk = xl_1
    local xi = op()
    if not (xk and xi) then
        return
    end
    for i, v in ipairs(oK(io)) do
        local xv = v
        local xl_3 = iq > 0 and ov(io) >= iq
        if xl_3 then
            break
        else
            local xl_4 = xv:GetAttribute("ItemName") or xv.Name
            local xj = xl_4
            if oN(ip, xj) then
                pcall(function()
                    xk:EquipTool(xv)
                end)
                task.wait(0.15)
                pcall(function()
                    o0:FireServer("Place", io, xj, xi, "1")
                end)
                task.wait(pA("BoostDelay", 0.4))
            end
        end
    end
end
pa = fns.fn223
yo_26 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = pd, Copyable = true }, "|", yo_14 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local pT = {}
pT.Info = yo_26:AddTab("Info", "info")
yo_17 = yo_26:AddTab("Main", "gamepad-2")
pT.Settings = yo_26:AddTab("Settings", "settings")
yo_17:SetSubTabAlignment("Center")
pT.Roll = yo_17:AddSubTab("Roll", "dices")
pT.Garden = yo_17:AddSubTab("Garden", "sprout")
pT.Shop = yo_17:AddSubTab("Shop", "shopping-cart")
pT.Progress = yo_17:AddSubTab("Progress", "trophy")
yo_19 = fns.fn150
for k, v in pT do
    yo_19(v)
end
ow, yo_17, yo_10, ps, po, yo_26 = nil, nil, nil, nil, nil, nil
yo_7 = 3
repeat
    yo_19 = (yo_7 * 1 + 0) % 3 + 1
    if yo_19 <= 2 then
        if yo_19 <= 1 then
            yo_19 = {
                "smggrlfvzwhb",
                "azgvynjs",
                "ouyrqmpyfdwy",
                "xoa",
                "fkzzfokdysnu",
                "joyhf",
                "gprp",
                "qawskx",
                "utulp",
                "bincabcjo",
                "zjnfvecyt"
            }
            if yo_19[(yo_7 * 41 + 87) % 11 + 1] < yo_19[(yo_7 * 41 + 87) % 11 + 1] then
                ps = "Unknown"
                pcall(fn408)
                pT = oG.Info:AddLeftGroupbox("Account", "circle-user")
                pT:AddLabel(ow("User", nil, oX), true)
                pT:AddLabel(ow("Status", "Keyless", oX), true)
                pT:AddLabel(ow("Executor", ps, oX), true)
                pn = oG.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                pn:AddLabel(pR(o8 .. " [" .. tostring(game.PlaceId) .. "]", yo_14), true)
                pn:AddLabel(ow("Place ID", tostring(game.PlaceId), yo_14), true)
                yo_10 = pn:AddLabel(ow("Session time", "0s", yo_17), true)
            else
                ow = "Unknown"
                pcall(fn408)
                yo_17 = pT.Info:AddLeftGroupbox("Account", "circle-user")
                yo_17:AddLabel(oX("User", pn.Name, pS), true)
                yo_17:AddLabel(oX("Status", "Keyless", pS), true)
                yo_17:AddLabel(oX("Executor", ow, pS), true)
                yo_10 = pT.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                yo_10:AddLabel(o8(yo_14 .. " [" .. tostring(game.PlaceId) .. "]", pR), true)
                yo_10:AddLabel(oX("Place ID", tostring(game.PlaceId), pR), true)
                ps = yo_10:AddLabel(oX("Session time", "0s", oG), true)
            end
            yo_7 = (yo_7 + 7) % 12
        else
            if (not yo_10 or not yo_10 or (not yo_10 or not ps)) and (yo_17 or ps or not ps and ps) or (not yo_10 or not yo_26) and (ps or not yo_17) and (not yo_10 and yo_10 and (yo_10 or not yo_17)) or not ((not yo_10 or not yo_10 or (not yo_10 or not ps)) and (yo_17 or ps or not ps and ps) or (not yo_10 or not yo_26) and (ps or not yo_17) and (not yo_10 and yo_10 and (yo_10 or not yo_17))) then
                po = tostring(game.JobId)
            else
                yo_10 = tostring(game.JobId)
            end
            yo_7 = (yo_7 + 7) % 12
        end
    else
        yo_19 = {
            "txpwpnabe",
            "rmpngljmawp",
            "ojgfzijoux",
            "kkqjthytmfy",
            "iqndqgakp",
            "qikgarqiilr",
            "lmd",
            "pfouudawl",
            "idy"
        }
        local yY = yo_7
        pU = yo_19[yY % 9 + 1]
        if pU:len() <= pU:reverse():rep(yY % 3 + 2):len() then
            yo_26 = #po > 18
        else
            po = #yo_26 > 18
        end
        yo_7 = (yo_7 + 4) % 12
    end
until (yo_7 * 11 + 8) % 12 == 11
if yo_26 then
    yo_7 = 1
    repeat
        if (yo_7 * 3 + 1) * 17 % 4 == ((yo_7 * 3 + 1) * 17 + 6) % 4 then
            po = string.sub(yo_26, 1, 18) .. "..."
        else
            yo_26 = string.sub(po, 1, 18) .. "..."
        end
        yo_7 = (yo_7 + 3) % 4
    until (yo_7 * 3 + 3) % 4 == 3
end
yo_7 = yo_26 or po
o2, AutoPlaceGroup, AutoReplaceGroup, ItemShopGroup, oH, oF, connection, connection2, on = nil, nil, nil, nil, nil, nil, nil, nil, nil
local p5 = yo_7
yo_10:AddLabel(oX("Server", p5, yo_23), true)
yo_10:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
o2 = os.clock()
task.spawn(worker)
local ScriptsGroup = pT.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(o8("Included in this hub", yo_23), true)
ScriptsGroup:AddLabel(o8(yo_14, pR), true)
local FeaturesGroup = pT.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(o8("Auto Roll", pR), true)
FeaturesGroup:AddLabel(o8("Auto Buy Roll", pS), true)
FeaturesGroup:AddLabel(o8("Auto Collect / Place / Sell", oG), true)
FeaturesGroup:AddLabel(o8("Auto Replace / Boosters", pR), true)
FeaturesGroup:AddLabel(o8("Auto Rebirth / Expand / Daily Deal", pS), true)
FeaturesGroup:AddLabel(o8("Auto Shop / Upgrades", pR), true)
FeaturesGroup:AddLabel(o8("Misc Utilities", yo_23), true)
pU = pT.Info:AddRightGroupbox("Socials", "link")
pU:AddButton({ Text = "Discord", Func = ph })
pU:AddButton({ Text = "Rscripts", Func = onRscripts })
yo_19 = pT.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
yo_19:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
yo_19:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
yo_19:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
yo_19:AddButton({ Text = "Copy Discord Invite", Func = ph })
yo_17 = pT.Info:AddRightGroupbox("FAQ", "circle-help")
yo_17:AddLabel("Where do I get a good config?", true)
yo_17:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
yo_17:AddLabel("How do I import / export configs?", true)
yo_17:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
yo_17:AddLabel("How do I report bugs?", true)
yo_17:AddLabel("Join the Discord and post it in the bugs channel.", true)
yo_17:AddLabel("How do I make suggestions?", true)
yo_17:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
yo_17:AddLabel("How do I get help or updates?", true)
yo_17:AddLabel("Join the Discord, updates and support are posted there first.", true)
local AutoRollGroup = pT.Roll:AddLeftGroupbox("Auto Roll", "dices")
AutoRollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
AutoRollGroup:AddSlider("RollDelay", { Text = "Roll delay", Default = 0.35, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
AutoRollGroup:AddToggle("RollRequireRoom", { Text = "Require inventory room", Default = true })
AutoRollGroup:AddSlider("RollLeaveSlots", { Text = "Leave inventory slots", Default = 2, Min = 0, Max = 50, Rounding = 0 })
AutoRollGroup:AddToggle("RollWaitNotRolling", { Text = "Wait until not rolling", Default = true })
AutoRollGroup:AddButton({ Text = "Roll Now", Func = pB })
local AutoBuyRollGroup = pT.Roll:AddRightGroupbox("Auto Buy Roll", "shopping-bag")
AutoBuyRollGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
AutoBuyRollGroup:AddSlider("BuyRollDelay", { Text = "Buy delay", Default = 0.2, Min = 0.05, Max = 5, Rounding = 2, Suffix = "s" })
AutoBuyRollGroup:AddSlider("BuyRollMaxPrice", { Text = "Max price", Default = 0, Min = 0, Max = 500000000, Rounding = 0, Suffix = "$" })
AutoBuyRollGroup:AddSlider("BuyRollMoneyBuffer", { Text = "Keep money", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Suffix = "$" })
AutoBuyRollGroup:AddDropdown("BuyRollRarities", { Text = "Rarities", Values = yo_21, Multi = true, AllowNull = true, Default = {} })
AutoBuyRollGroup:AddDropdown("BuyRollGnomes", {
    Text = "Gnomes",
    Values = yo_18,
    Multi = true,
    AllowNull = true,
    Default = {},
    Expandable = true,
    ExpandColumns = 2
})
AutoBuyRollGroup:AddButton({ Text = "Buy Roll Now", Func = onBuyRollNow })
local AutoCollectGroup = pT.Garden:AddLeftGroupbox("Auto Collect", "hand")
if (AutoBuyRollGroup or not AutoBuyRollGroup or ItemShopGroup and not yo_17) and (not yo_17 and not yo_17 or yo_19 and AutoBuyRollGroup) and not ((AutoBuyRollGroup or not AutoBuyRollGroup or ItemShopGroup and not yo_17) and (not yo_17 and not yo_17 or yo_19 and AutoBuyRollGroup)) then
    onCollectNow:AddToggle("AutoCollect", { Text = "Auto Collect Plants", Default = false })
    onCollectNow:AddSlider("CollectDelay", { Max = 30, Min = 0.1, Suffix = "s", Default = 0.5, Rounding = 1, Text = "Collect delay" })
    onCollectNow:AddButton({ Text = "Collect Now", Func = AutoCollectGroup })
    pT = AutoPlaceGroup.Garden:AddLeftGroupbox("Auto Place", "map-pin")
else
    AutoCollectGroup:AddToggle("AutoCollect", { Text = "Auto Collect Plants", Default = false })
    AutoCollectGroup:AddSlider("CollectDelay", { Text = "Collect delay", Default = 0.5, Min = 0.1, Max = 30, Rounding = 1, Suffix = "s" })
    AutoCollectGroup:AddButton({ Text = "Collect Now", Func = onCollectNow })
    AutoPlaceGroup = pT.Garden:AddLeftGroupbox("Auto Place", "map-pin")
end
AutoPlaceGroup:AddToggle("AutoPlace", { Text = "Auto Place Gnomes", Default = false })
AutoPlaceGroup:AddSlider("PlaceDelay", { Text = "Place delay", Default = 0.35, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
AutoPlaceGroup:AddSlider("PlaceSpacing", { Text = "Spacing", Default = 4, Min = 2, Max = 20, Rounding = 1 })
AutoPlaceGroup:AddSlider("PlaceMaxGnomes", { Text = "Max placed gnomes", Default = 0, Min = 0, Max = 200, Rounding = 0 })
AutoPlaceGroup:AddDropdown("PlaceRarities", { Text = "Rarities", Values = yo_21, Multi = true, AllowNull = true, Default = {} })
AutoPlaceGroup:AddDropdown("PlaceGnomes", {
    Text = "Gnomes",
    Values = yo_18,
    Multi = true,
    AllowNull = true,
    Default = {},
    Expandable = true,
    ExpandColumns = 2
})
AutoPlaceGroup:AddButton({ Text = "Place Now", Func = onPlaceNow })
local AutoSellGroup = pT.Garden:AddRightGroupbox("Auto Sell", "badge-dollar-sign")
AutoSellGroup:AddToggle("AutoSell", { Text = "Auto Sell All", Default = false })
AutoSellGroup:AddSlider("SellDelay", { Text = "Sell delay", Default = 5, Min = 0.5, Max = 120, Rounding = 1, Suffix = "s" })
AutoSellGroup:AddSlider("SellThreshold", { Text = "Sell at inventory", Default = 10, Min = 1, Max = 200, Rounding = 0 })
AutoSellGroup:AddButton({ Text = "Sell All Now", Func = fns.onSellAllNow })
local AutoSellGnomesGroup = pT.Garden:AddRightGroupbox("Auto Sell Gnomes", "user-round-x")
if (ScriptsGroup or oF or oF and oF or (oF or oF or ScriptsGroup and not ScriptsGroup) or (ScriptsGroup and oF or oF and not oF or ScriptsGroup and ScriptsGroup and (oF or not oF))) and not (ScriptsGroup or oF or oF and oF or (oF or oF or ScriptsGroup and not ScriptsGroup) or (ScriptsGroup and oF or oF and not oF or ScriptsGroup and ScriptsGroup and (oF or not oF))) then
    onSellAllGnomesNow:AddToggle("AutoSellGnomes", { Text = "Auto Sell All Gnomes", Default = false })
    onSellAllGnomesNow:AddToggle("KeepRequiredRebirthGnomes", { Text = "Keep Required Rebirth Gnomes", Default = true })
    onSellAllGnomesNow:AddSlider("SellGnomesDelay", { Suffix = "s", Text = "Sell delay", Max = 10, Default = 0.35, Rounding = 2, Min = 0.1 })
    onSellAllGnomesNow:AddDropdown("KeepGnomes", {
        ExpandColumns = 2,
        Multi = true,
        Default = {},
        Expandable = true,
        AllowNull = true,
        Values = AutoReplaceGroup,
        Text = "Keep gnomes"
    })
    onSellAllGnomesNow:AddButton({ Text = "Sell All Gnomes Now", Func = AutoSellGnomesGroup })
    pT = yo_18.Garden:AddLeftGroupbox("Auto Replace", "replace")
else
    AutoSellGnomesGroup:AddToggle("AutoSellGnomes", { Text = "Auto Sell All Gnomes", Default = false })
    AutoSellGnomesGroup:AddToggle("KeepRequiredRebirthGnomes", { Text = "Keep Required Rebirth Gnomes", Default = true })
    AutoSellGnomesGroup:AddSlider("SellGnomesDelay", { Text = "Sell delay", Default = 0.35, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
    AutoSellGnomesGroup:AddDropdown("KeepGnomes", {
        Text = "Keep gnomes",
        Values = yo_18,
        Multi = true,
        AllowNull = true,
        Default = {},
        Expandable = true,
        ExpandColumns = 2
    })
    AutoSellGnomesGroup:AddButton({ Text = "Sell All Gnomes Now", Func = onSellAllGnomesNow })
    AutoReplaceGroup = pT.Garden:AddLeftGroupbox("Auto Replace", "replace")
end
AutoReplaceGroup:AddToggle("AutoReplace", { Text = "Auto Replace Gnomes", Default = false })
AutoReplaceGroup:AddSlider("ReplaceDelay", { Text = "Replace delay", Default = 0.4, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
AutoReplaceGroup:AddButton({ Text = "Replace Now", Func = onReplaceNow })
local AutoBoostersGroup = pT.Garden:AddRightGroupbox("Auto Boosters", "droplets")
AutoBoostersGroup:AddToggle("AutoSprinkler", { Text = "Auto Sprinkler", Default = false })
AutoBoostersGroup:AddToggle("AutoFertilizer", { Text = "Auto Fertilizer", Default = false })
AutoBoostersGroup:AddSlider("BoostDelay", { Text = "Place delay", Default = 0.4, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
AutoBoostersGroup:AddSlider("BoostSpacing", { Text = "Spacing", Default = 6, Min = 2, Max = 30, Rounding = 1 })
AutoBoostersGroup:AddSlider("SprinklerMax", { Text = "Max sprinklers", Default = 1, Min = 0, Max = 20, Rounding = 0 })
AutoBoostersGroup:AddSlider("FertilizerMax", { Text = "Max fertilizer", Default = 1, Min = 0, Max = 20, Rounding = 0 })
AutoBoostersGroup:AddDropdown("SprinklerItems", { Text = "Sprinklers", Values = yo_12, Multi = true, AllowNull = true, Default = {} })
AutoBoostersGroup:AddDropdown("FertilizerItems", { Text = "Fertilizers", Values = yo_5, Multi = true, AllowNull = true, Default = {} })
AutoBoostersGroup:AddButton({ Text = "Place Boosters Now", Func = pa })
ItemShopGroup = pT.Shop:AddLeftGroupbox("Item Shop", "store")
ItemShopGroup:AddToggle("AutoShop", { Text = "Auto Buy Item Shop", Default = false })
ItemShopGroup:AddSlider("ShopDelay", { Text = "Shop delay", Default = 3, Min = 0.5, Max = 120, Rounding = 1, Suffix = "s" })
ItemShopGroup:AddSlider("ShopBuyDelay", { Text = "Buy delay", Default = 0.25, Min = 0.05, Max = 5, Rounding = 2, Suffix = "s" })
ItemShopGroup:AddSlider("ShopMaxPrice", { Text = "Max price", Default = 0, Min = 0, Max = 1000000, Rounding = 0, Suffix = "$" })
ItemShopGroup:AddSlider("ShopMoneyBuffer", { Text = "Keep money", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Suffix = "$" })
ItemShopGroup:AddDropdown("ShopItems", { Text = "Items", Values = yo_2, Multi = true, AllowNull = true, Default = {} })
ItemShopGroup:AddButton({ Text = "Buy Shop Now", Func = onBuyShopNow })
local UpgradesGroup = pT.Shop:AddRightGroupbox("Upgrades", "arrow-big-up-dash")
UpgradesGroup:AddToggle("AutoUpgrade", { Text = "Auto Buy Affordable Upgrades", Default = false })
UpgradesGroup:AddSlider("UpgradeDelay", { Text = "Upgrade delay", Default = 0.35, Min = 0.1, Max = 30, Rounding = 2, Suffix = "s" })
UpgradesGroup:AddSlider("UpgradeMaxPrice", { Text = "Max price", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Suffix = "$" })
UpgradesGroup:AddSlider("UpgradeMoneyBuffer", { Text = "Keep money", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Suffix = "$" })
UpgradesGroup:AddButton({ Text = "Buy Upgrades Now", Func = onBuyUpgradesNow })
local AutoRebirthGroup = pT.Progress:AddLeftGroupbox("Auto Rebirth", "refresh-cw")
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutoRebirthGroup:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 2, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
AutoRebirthGroup:AddButton({ Text = "Rebirth Now", Func = oU })
local AutoExpandGroup = pT.Progress:AddLeftGroupbox("Auto Expand", "expand")
AutoExpandGroup:AddToggle("AutoExpand", { Text = "Auto Plot Expansion", Default = false })
AutoExpandGroup:AddSlider("ExpandDelay", { Text = "Expand delay", Default = 0.5, Min = 0.2, Max = 30, Rounding = 2, Suffix = "s" })
AutoExpandGroup:AddSlider("ExpandMaxPrice", { Text = "Max price", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Suffix = "$" })
AutoExpandGroup:AddSlider("ExpandMoneyBuffer", { Text = "Keep money", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Suffix = "$" })
AutoExpandGroup:AddButton({ Text = "Expand Now", Func = onExpandNow })
local AutoDailyDealGroup = pT.Progress:AddRightGroupbox("Auto Daily Deal", "calendar-check")
AutoDailyDealGroup:AddToggle("AutoDailyDeal", { Text = "Auto Daily Deal", Default = false })
AutoDailyDealGroup:AddSlider("DailyDealDelay", { Text = "Check delay", Default = 5, Min = 1, Max = 120, Rounding = 1, Suffix = "s" })
AutoDailyDealGroup:AddButton({ Text = "Claim Daily Deal Now", Func = o7 })
local MenuGroup = pT.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = fns.onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(pT.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/roll-a-gnome")
SaveManager:BuildConfigSection(pT.Settings)
SaveManager:LoadAutoloadConfig()
oH = tick()
oF = tick()
pcall(function()
    for i, v in ipairs(getconnections(pn.Idled)) do
        local xO = v
        pcall(function()
            xO:Disable()
        end)
    end
end)
on = fn904
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
Library:OnUnload(fn611)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(fns.worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
task.spawn(worker10)
task.spawn(worker11)
task.spawn(worker12)
task.spawn(worker13)
task.spawn(worker14)
task.spawn(worker15)
Library:Notify("Roll A Gnome loaded")
end)(...)
