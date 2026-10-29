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
getgenv().TempoHoodSubtitle = "+1 HEAT PER CLICK"
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
local uV_7, uV_12
local n5
local m5
local nN
local mN
local nu
local TrailsConfig
local nb
local HttpService
local connection4
local nA
local mA
local nh
local nZ
local mZ
local nG
local mG
local nn
local OvenConfig
local m4
local nM
local mM
local nt
local oa
local na
local CurrentCamera
local mS
local connection6
local PepperConfig
local connection
local VirtualUser
local mY
local nF
local Config
local Toggles
local UserInputService
local m3
local mL
local ns
local n9
local m9
local mR
local ny
local of
local nf
local nX
local mX
local Library
local mE
local nl
local n2
local TrailEquip
local nK
local mK
local nr
local n8
local m8
local UnlockWorld3AfterStage
local WorldTeleport
local nx
local oe
local ne
local connection3
local mW
local nD
local mD
local ClickHeat
local n1
local m1
local Workspace
local mJ
local SaveManager
local AurasConfig
local TrailBuy
local mP
local nw
local od
local Options
local nV
local AuraEquip
local nC
local connection2
local nj
local n0
local m0
local nI
local mI
local np
local n6
local m6
local connection5
local mO
local nv
local oc
local RebirthRequest
local UnlockAfterStage
local mU
local nB
local mB
local ni
local n_
local AuraBuy
local nH
local mH
local no
function fns.fn6()
    m0(m8, "Copied Discord invite to clipboard")
end
function fns.fn7()
    local si
    for i, v in ipairs(AurasConfig.Auras) do
        if of.auras[v.id] then
            if not si or v.heatMultiplier > si.heatMultiplier then
                si = v
            end
        end
    end
    return si
end
function fns.onCopySolanaAddress()
    m0(m9, "Copied Solana address")
end
function fns.fn21()
    local sr = mS()
    if sr and of.equippedTrail ~= sr.id then
        nI(TrailEquip, sr.id)
        of.equippedTrail = sr.id
    end
end
function fns.worker4()
    while not Library.Unloaded do
        if n8("AutoBuyPeppers") then
            pcall(nF)
        else
            nu = false
        end
        task.wait(0.25)
    end
end
function fns.fn28()
    Library.ScreenGui.Parent = nH:WaitForChild("PlayerGui")
end
function fns.fn31(b_)
    if b_ > UnlockWorld3AfterStage then
        return 3
    elseif b_ > UnlockAfterStage then
        return 2
    else
        return 1
    end
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local s9_1 = mX()
        if s9_1 then
            for i, descendant in s9_1:GetDescendants() do
                local s9_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if s9_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn84(iP, iQ)
    local t5_1 = (iP == "Toggle" and Toggles or Options)[iQ]
    local t4_2 = type(t5_1) == "table" and t5_1.Type == iP
    return t4_2 and t5_1 or nil
end
function fns.fn94(ea)
    local Base = Workspace:FindFirstChild("Base")
    local rd = Base and Base:FindFirstChild("ButtonPad")
    local rc_1 = rd
    if rd then
        rd = rc_1:FindFirstChild("Buttons")
    end
    local rc_2 = rd
    if rc_2 then
        local rd_1 = PepperConfig.indexForId(ea)
        local re = rd_1 and rc_2:FindFirstChild("Button" .. rd_1)
        if re then
            return re
        end
        for i, child in rc_2:GetChildren() do
            if child:FindFirstChild(ea) then
                return child
            end
        end
        local Mono = Workspace:FindFirstChild("Mono")
        if not Mono then
            return nil
        end
        for i, child in Mono:GetChildren() do
            if child:FindFirstChild(ea) then
                return child
            end
        end
        return nil
    end
    local Mono = Workspace:FindFirstChild("Mono")
    if not Mono then
        return nil
    end
    for i, child in Mono:GetChildren() do
        if child:FindFirstChild(ea) then
            return child
        end
    end
    return nil
end
function fns.onRscripts()
    m0(m3, "Copied Rscripts profile to clipboard")
end
function fns.antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local t0 = tick() - mU
            local t1 = tick() - mO
            if t0 >= 300 and t1 >= 60 then
                pcall(oa)
            else
                if t0 < 300 and t1 >= 300 then
                    pcall(oa)
                end
            end
        end
    end
end
function fns.fn123()
    local sA = ni()
    local sB
    for i, v in ipairs(TrailsConfig.Trails) do
        if not of.trails[v.id] and v.winCost <= sA then
            if not sB or v.heatMultiplier > sB.heatMultiplier then
                sB = v
            end
        end
    end
    if not sB then
        return
    end
    nI(TrailBuy, sB.id)
    nI(TrailEquip, sB.id)
end
function fns.worker6()
    while not Library.Unloaded do
        if n8("AutoRebirth") then
            pcall(mB)
        end
        task.wait(0.1)
    end
end
function fns.fn138()
    local rS = ni()
    local rT
    for i, v in ipairs(PepperConfig.Order) do
        local rU_1 = not PepperConfig.isDevil(v) and not mG(v)
        if rU_1 then
            local rU_2 = PepperConfig.winCost(v)
            if rU_2 <= rS then
                local rU_3 = PepperConfig.get(v)
                local rU_4 = rU_3 and rU_3.heatPerClick or 0
                local rV_2 = not rT
                if not rV_2 then
                    rV_2 = rU_4 > rT.Heat
                end
                if rV_2 then
                    rT = { Id = v, Heat = rU_4 }
                end
            end
        end
    end
    if not rT then
        nu = false
        return
    end
    local rS_1 = mP(rT.Id)
    if not rS_1 then
        nu = false
        return
    end
    local Touch = rS_1:FindFirstChild("Touch")
    local rV_3 = Touch and Touch:FindFirstChildWhichIsA("ProximityPrompt")
    local rW_2 = rV_3 or rS_1:FindFirstChildWhichIsA("ProximityPrompt", true)
    local rV_4 = Touch
    if not rV_4 then
        rV_4 = rS_1:FindFirstChildWhichIsA("BasePart", true)
    end
    local rS_2 = rV_4
    if not rS_2 then
        nu = false
        return
    end
    nu = true
    if not nV(rS_2, 10) then
        m6(rS_2.CFrame + Vector3.new(0, 3, 0))
        local rV_5 = os.clock() + 1.25
        while true do
            local rW_3 = os.clock() < rV_5 and not Library.Unloaded and n8("AutoBuyPeppers")
            if rW_3 then
                if nV(rS_2, 10) then
                    break
                end
                task.wait(0.05)
                continue
            end
            break
        end
    else
        m6(rS_2.CFrame + Vector3.new(0, 3, 0))
    end
    local r5 = if mW(rW_2) then 1 else 0
    if r5 == 1 then
        of.ownedPeppers[rT.Id] = true
        nu = false
        return
    end
    if os.clock() - np >= 1.4 then
        np = os.clock()
        nn(rW_2)
    end
    local rS_3 = os.clock() + 1.6
    while true do
        local rV_6 = os.clock() < rS_3 and not Library.Unloaded and n8("AutoBuyPeppers")
        if rV_6 then
            local rV_7 = mG(rT.Id) or mW(rW_2)
            if rV_7 then
                of.ownedPeppers[rT.Id] = true
                break
            end
            task.wait(0.1)
            continue
        end
        break
    end
    nu = false
end
function fns.fn139(bw)
    if type(bw) ~= "table" then
        return
    end
    if bw.wins ~= nil then
        of.wins = nX(bw.wins)
    end
    if bw.heat ~= nil then
        of.heat = nX(bw.heat)
    elseif bw.wins ~= nil then
        of.heat = nX(bw.wins)
    end
    if bw.rebirths ~= nil then
        local pM_1 = tonumber(bw.rebirths) or of.rebirths
        of.rebirths = pM_1
    end
    if bw.level ~= nil then
        local pM_2 = tonumber(bw.level) or of.level
        of.level = pM_2
    end
    if bw.nextRebirthLevel ~= nil then
        local pM_3 = tonumber(bw.nextRebirthLevel) or of.nextRebirthLevel
        of.nextRebirthLevel = pM_3
    end
    if type(bw.ownedPeppers) == "table" then
        of.ownedPeppers = n9(bw.ownedPeppers)
        of.ownedPeppers[PepperConfig.DEFAULT_ID] = true
    end
    if type(bw.trails) == "table" then
        of.trails = n9(bw.trails)
    end
    if type(bw.auras) == "table" then
        of.auras = n9(bw.auras)
    end
    if type(bw.ownedOvens) == "table" then
        of.ownedOvens = n9(bw.ownedOvens)
    end
    if bw.equippedPepper ~= nil then
        of.equippedPepper = tostring(bw.equippedPepper)
    end
    if bw.equippedTrail ~= nil then
        of.equippedTrail = tostring(bw.equippedTrail)
    end
    if bw.equippedAura ~= nil then
        of.equippedAura = tostring(bw.equippedAura)
    end
    if bw.paidWins ~= nil then
        of.paidWins = bw.paidWins == true
    elseif bw.ownsPaidWins ~= nil then
        of.paidWins = bw.ownsPaidWins == true
    elseif bw.winsPaid ~= nil then
        of.paidWins = bw.winsPaid == true
    end
end
function fns.fn155()
    local leaderstats = nH:FindFirstChild("leaderstats")
    local pY = leaderstats and leaderstats:FindFirstChild("Rebirths")
    if pY then
        return nX(pY.Value)
    end
    return of.rebirths
end
function fns.fn177()
    if not Toggles.Fly.Value then
        local tt = mN()
        if tt then
            tt.PlatformStand = false
        end
    end
end
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            n6(true)
        end
    end
end
function fns.fn218()
    nC = nil
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    connection4:Disconnect()
    connection5:Disconnect()
    connection6:Disconnect()
    n6(false)
    select("#", "Unloaded!")
end
function fns.fn223(gd)
    local DiscordGroup = gd:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mH })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mH })
end
function fns.onCopyVenmoLink()
    m0(m1, "Copied Venmo link")
end
function fns.fn247(aK)
    local pd = Options[aK]
    return pd and pd.Value or nil
end
function fns.worker5()
    while not Library.Unloaded do
        if n8("AutoBuyTrails") then
            pcall(mD)
        end
        if n8("AutoBuyAuras") then
            pcall(ny)
        end
        if n8("AutoEquipBestTrail") then
            pcall(nG)
        end
        if n8("AutoEquipBestAura") then
            pcall(nb)
        end
        task.wait(1)
    end
end
function fns.onCopyJoinScript_JobID()
    local gu = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mE)
    m0(gu, "Copied join script to clipboard")
end
function fns.fn262(ch)
    local Map = Workspace:FindFirstChild("Map")
    local qa = Map and Map:FindFirstChild("Walls")
    local p9_1 = qa
    if qa then
        qa = p9_1:FindFirstChild("Zone" .. ch)
    end
    local p9_2 = qa
    if qa then
        qa = p9_2:IsA("BasePart")
    end
    if qa then
        return p9_2
    end
    return nil
end
function fns.fn274()
    local pm = mX()
    local pn = pm and pm:FindFirstChild("HumanoidRootPart")
    return pn
end
function fns.fn281()
    if not Toggles.WalkSpeedEnabled.Value then
        local tv = mN()
        if tv then
            tv.WalkSpeed = 16
        end
    end
end
function fns.fn289(cq)
    if not cq then
        return true
    end
    return cq.CanCollide == false or cq.Transparency >= 0.9
end
function fns.fn297()
    local sx = n5()
    if sx and of.equippedAura ~= sx.id then
        nI(AuraEquip, sx.id)
        of.equippedAura = sx.id
    end
end
function fns.fn344()
    local pj = mX()
    local pk = pj and pj:FindFirstChildOfClass("Humanoid")
    return pk
end
function fns.onImportConfigFromClipboardTex()
    local uL_1
    local uJ = Options.SaveManager_ImportSource.Value or ""
    local uJ_1
    local uK = tostring(uJ):match("^%s*(.-)%s*$")
    if uK == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    uJ_1, uL_1 = pcall(HttpService.JSONDecode, HttpService, uK)
    local uK_1 = not uJ_1 or type(uL_1) ~= "table" or type(uL_1.objects) ~= "table"
    if uK_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local uJ_2 = 0
    for i, v in ipairs(uL_1.objects) do
        if nM(v) then
            uJ_2 += 1
        end
    end
    if uJ_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local uL_2 = uJ_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(uJ_2, uL_2), 6)
end
function fns.fn371(eI, eJ)
    local rL = oe()
    if not (rL and eI) then
        return false
    end
    local Magnitude = (rL.Position - eI.Position).Magnitude
    local rN = eJ
    local rR = if rN then 1 else 0
    local rP = 2340 * rR + 1657 * (1 - rR)
    local rQ = 807 * rR + 3314 * (1 - rR)
    if not ((rP * 1212 + rQ * 1170 + rP * rQ) % 16777213 == 5668650) then
        rN = 12
    end
    return Magnitude <= rN
end
function fns.onCopyUSDTAddress()
    m0(nf, "Copied USDT address")
end
function fns.fn385()
    local sK = ni()
    local sL
    for i, v in ipairs(AurasConfig.Auras) do
        if not of.auras[v.id] and v.winCost <= sK then
            if not sL or v.heatMultiplier > sL.heatMultiplier then
                sL = v
            end
        end
    end
    if not sL then
        return
    end
    nI(AuraBuy, sL.id)
    nI(AuraEquip, sL.id)
end
function fns.fn389()
    local r9
    for i, v in ipairs(TrailsConfig.Trails) do
        if of.trails[v.id] then
            if not r9 or v.heatMultiplier > r9.heatMultiplier then
                r9 = v
            end
        end
    end
    return r9
end
function fns.fn391()
    local uf = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local ug = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if ug then
                local ug_1 = ns(k, v)
                if ug_1 then
                    uf[#uf + 1] = ug_1
                end
            end
        end
    end
    table.sort(uf, function(i8, i9)
        if i8.type ~= i9.type then
            return i8.type < i9.type
        end
        return i8.idx < i9.idx
    end)
    return { objects = uf }
end
function fns.fn402()
    local Stats = nH:FindFirstChild("Stats")
    local p0 = Stats and Stats:FindFirstChild("Level")
    if p0 then
        return nX(p0.Value)
    end
    return of.level
end
function fns.onCharacterAdded()
    nC = nil
end
function fns.fn460()
    local qk = oe()
    if not qk then
        return 1
    end
    local ql = qk.Position.Z
    if ql >= 949 then
        return 3
    elseif ql >= 410 then
        return 2
    else
        return 1
    end
end
function fns.fn467(cU)
    local qx = oe()
    if not qx then
        return
    end
    qx.AssemblyLinearVelocity = Vector3.zero
    qx.AssemblyAngularVelocity = Vector3.zero
    qx.CFrame = cU
    nC = cU
end
function fns.onCopyPayPalLink()
    m0(m5, "Copied PayPal link")
end
function fns.fn471()
    if nv(n1(UnlockWorld3AfterStage)) then
        return 3
    elseif nv(n1(UnlockAfterStage)) then
        return 2
    else
        return 1
    end
end
function fns.fn527()
    if not na() then
        return
    end
    nI(ClickHeat)
end
function fns.fn542(aP, aQ)
    local pg = Options[aP]
    local ph = pg and tonumber(pg.Value)
    if ph then
        return ph
    end
    return aQ
end
function fns.fn544(cJ)
    local qo = oe()
    if not (qo and cJ) then
        return
    end
    if firetouchinterest then
        pcall(firetouchinterest, cJ, qo, 0)
        pcall(firetouchinterest, cJ, qo, 1)
    end
end
function fns.fn590()
    return nH.Character
end
function fns.fn593(iX, iY)
    local Type = iY.Type
    if Type == "Toggle" then
        return { idx = iX, type = "Toggle", value = iY.Value == true }
    elseif Type == "Slider" then
        return { idx = iX, type = "Slider", value = tostring(iY.Value) }
    elseif Type == "Dropdown" then
        return { idx = iX, type = "Dropdown", multi = iY.Multi == true, value = iY.Value }
    elseif Type == "Input" then
        local t9 = iY.Value
        local ud = if t9 then 1 else 0
        local ub = 3838 * ud + 1852 * (1 - ud)
        local uc = 1299 * ud + 711 * (1 - ud)
        if not ((ub * 3093 + uc * 1103 + ub * uc) % 16777213 == 1512080) then
            t9 = ""
        end
        return { idx = iX, type = "Input", text = tostring(t9) }
    elseif Type == "ColorPicker" then
        return { idx = iX, type = "ColorPicker", value = iY.Value:ToHex(), transparency = iY.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = iX,
            type = "KeyPicker",
            mode = iY.Mode,
            key = iY.Value,
            modifiers = iY.Modifiers,
            toggled = iY.Toggled
        }
    else
        return nil
    end
end
function fns.fn601(dP)
    local q2 = OvenConfig.zoneNameForId(dP)
    if not q2 then
        return nil
    end
    local Map = Workspace:FindFirstChild("Map")
    local q4 = Map and Map:FindFirstChild("OvensZones")
    local q3_1 = q4
    if q4 then
        q4 = q3_1:FindFirstChild(q2)
    end
    local q2_1 = q4
    local q3_2 = q2_1 and q2_1:IsA("BasePart")
    if q3_2 then
        return q2_1
    end
    return nil
end
function fns.fn612(X, Y)
    if setclipboard then
        setclipboard(X)
    elseif toclipboard then
        toclipboard(X)
    end
    Library:Notify(Y)
end
function fns.worker3()
    while not Library.Unloaded do
        if n8("AutoClick") then
            nh()
        end
        task.wait(0.05)
    end
end
function fns.fn683(br)
    local pE = {}
    if type(br) ~= "table" then
        return pE
    end
    for k, v in br do
        if v then
            pE[tostring(k)] = true
        end
    end
    return pE
end
function fns.fn687()
    local Map = Workspace:FindFirstChild("Map")
    local p4 = Map and Map:FindFirstChild("WinPads")
    if not p4 then
        return nil
    elseif of.paidWins then
        local PaidWins = p4:FindFirstChild("PaidWins")
        if PaidWins then
            return PaidWins
        end
        return p4:FindFirstChild("DefaultWins")
    else
        return p4:FindFirstChild("DefaultWins")
    end
end
function fns.fn688(eB)
    if of.ownedPeppers[eB] then
        return true
    end
    local rI = mP(eB)
    if not rI then
        return false
    end
    local ProximityPrompt = rI:FindFirstChildWhichIsA("ProximityPrompt", true)
    if mW(ProximityPrompt) then
        of.ownedPeppers[eB] = true
        return true
    end
    return false
end
function fns.fn690(be)
    local py = mX()
    if not py then
        return
    end
    if py.PrimaryPart then
        py:PivotTo(be)
    else
        local py_1 = oe()
        if py_1 then
            py_1.CFrame = be
        end
    end
end
function fns.fn715()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    mO = tick()
end
function fns.onRenderStepped(hl)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local tp_1 = mN()
        if tp_1 then
            tp_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local tp_3 = oe()
        local tq = mN()
        if tp_3 and tq then
            tq.PlatformStand = true
            local tq_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                tq_1 = tq_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                tq_1 = tq_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                tq_1 = tq_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                tq_1 = tq_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                tq_1 = tq_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                tq_1 = tq_1 - Vector3.new(0, 1, 0)
            end
            tp_3.Velocity = Vector3.zero
            if tq_1.Magnitude > 0 then
                tp_3.CFrame = tp_3.CFrame + tq_1.Unit * Options.FlySpeed.Value * hl
            end
        end
    end
end
local function fn735()
    local sX_1
    local sW_1
    if identifyexecutor then
        sX_1, sW_1 = identifyexecutor()
        local sY = sX_1 ~= ""
        local sZ = type(sX_1) == "string" and sY
        if sZ then
            local sY_1 = type(sW_1) == "string" and sW_1 ~= "" and sX_1 .. " " .. sW_1
            nj = sY_1 or sX_1
        end
    end
end
local function onCopyBitcoinAddress()
    m0(nr, "Copied Bitcoin address")
end
local function fn783()
    n6(Toggles.AntiGameplayPause.Value)
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local tk_1 = mN()
        if tk_1 then
            tk_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn830()
    if not Toggles.AutoTrain.Value then
        nC = nil
    end
end
local function fn839()
    local qz = ne()
    od(nA(qz))
    local qA = mL(qz)
    if not qA then
        local Map = Workspace:FindFirstChild("Map")
        local qC = Map and Map:FindFirstChild("WorldsSpawns")
        local qB_1 = qC
        if qC then
            qC = qB_1:FindFirstChild("World" .. nA(qz))
        end
        local qz_1 = qC
        local qB_2 = qz_1 and qz_1:IsA("BasePart")
        if qB_2 then
            mY(qz_1.Position)
        end
        task.wait(0.25)
        return
    end
    mY(qA.Position)
    nC = nil
    nt(qA.CFrame + Vector3.new(0, 3, 0))
    nN(qA)
    task.wait(math.max(nx("WinDelay", 0.55), 0.2))
end
local function fn840(ca)
    local p6 = nl()
    local p7 = p6 and p6:FindFirstChild("Zone" .. ca)
    local p6_1 = p7
    if p7 then
        p7 = p6_1:IsA("BasePart")
    end
    if p7 then
        return p6_1
    end
    return nil
end
local function worker2()
    while not Library.Unloaded do
        if nu then
            task.wait(0.1)
        elseif n8("AutoWin") then
            pcall(mI)
        elseif n8("AutoTrain") then
            pcall(nD)
            task.wait(0.35)
        else
            if not n8("AutoBuyPeppers") then
                nC = nil
            end
            task.wait(0.25)
        end
    end
end
local function fn847(ah, ai, aj)
    return string.format("<b>%s</b> %s %s", ah, oc("-", "#5a6070"), oc(ai, aj))
end
local function onExportConfigToClipboard()
    local uD_1
    local uC_1
    uC_1, uD_1 = pcall(HttpService.JSONEncode, HttpService, m4())
    if not uC_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local uC_2 = setclipboard or toclipboard
    local uC_3 = type(uC_2) ~= "function" or not pcall(uC_2, uD_1)
    if uC_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn893(ey)
    if not ey then
        return false
    end
    local rE = ey.ActionText or ""
    return rE == "Equip" or rE == "Equipped"
end
local function onInputChanged(iq)
    local UserInputType = iq.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        mU = tick()
    end
end
local function fn937()
    if not Toggles.AutoWin.Value then
        nC = nil
    end
end
local function onInputBegan()
    mU = tick()
end
local function onCopyLitecoinAddress()
    m0(nw, "Copied Litecoin address")
end
local function fn953()
    local sU = of.nextRebirthLevel
    if sU <= 0 then
        sU = Config.maxLevel(mJ())
    end
    if nZ() >= sU then
        nI(RebirthRequest)
    end
end
local function fn960(a5)
    if typeof(a5) == "number" then
        return a5
    end
    local ps = (Config.parse(a5))
    local px = if ps then 1 else 0
    local pv = 1049 * px + 2266 * (1 - px)
    local pw = 2882 * px + 2199 * (1 - px)
    if not ((pv * 2268 + pw * 268 + pv * pw) % 16777213 == 6174726) then
        ps = tonumber(a5)
    end
    return ps or 0
end
local function fn971(cD)
    if mM() == cD then
        return
    end
    if os.clock() - mR < 1.25 then
        return
    end
    mR = os.clock()
    nI(WorldTeleport, cD)
    task.wait(0.6)
end
local function worker()
    local s4_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local s3 = math.floor(os.clock() - n_)
        if s3 < 60 then
            s4_1 = s3 .. "s"
        elseif s3 < 3600 then
            s4_1 = string.format("%dm %ds", math.floor((s3) / (60)), s3 % 60)
        else
            s4_1 = string.format("%dh %dm", math.floor((s3) / (3600)), math.floor((s3 % 3600) / (60)))
        end
        mK:SetText(n2("Session time", s4_1, nB))
    end
end
local function onUnload()
    Library:Unload()
end
local function onHeartbeat()
    if Library.Unloaded or not nC then
        return
    end
    local qu_1 = oe()
    if not qu_1 then
        return
    end
    qu_1.AssemblyLinearVelocity = Vector3.zero
    qu_1.AssemblyAngularVelocity = Vector3.zero
    qu_1.CFrame = nC
end
local function onCopyEthereumAddress()
    m0(no, "Copied Ethereum address")
end
local function fn1035()
    local qe = nK("WinPlate")
    if qe == "Random" then
        return math.random(1, n0)
    elseif type(qe) == "string" then
        local qf = tonumber(qe:match("%d+"))
        if qf then
            return math.clamp(qf, 1, n0)
        end
        return n0
    else
        return n0
    end
end
local function fn1047(aE)
    if Library.Unloaded then
        return false
    end
    local pa = Toggles[aE]
    return pa ~= nil and pa.Value == true
end
local function fn1059()
    local q9 = OvenConfig.bestOwnedId(mJ(), of.ownedOvens, mZ()) or OvenConfig.DEFAULT_ID
    od(OvenConfig.worldId(q9))
    local ra = mA(q9)
    if not ra then
        return
    end
    mY(ra.Position)
    m6(ra.CFrame + Vector3.new(0, 3, 0))
end
local function fn1079()
    local leaderstats = nH:FindFirstChild("leaderstats")
    local pV = leaderstats and leaderstats:FindFirstChild("Wins")
    if pV then
        return nX(pV.Value)
    end
    return of.wins
end
local function fn1090(ae, af)
    return string.format('<font color="%s">%s</font>', af, ae)
end
PepperConfig = nil
mA = nil
mB = nil
connection2 = nil
mD = nil
mE = nil
Config = nil
mG = nil
mH = nil
mI = nil
mJ = nil
mK = nil
mL = nil
mM = nil
mN = nil
mO = nil
mP = nil
WorldTeleport = nil
mR = nil
mS = nil
connection4 = nil
mU = nil
AuraEquip = nil
mW = nil
mX = nil
mY = nil
mZ = nil
AuraBuy = nil
m0 = nil
m1 = nil
TrailEquip = nil
m3 = nil
m4 = nil
m5 = nil
m6 = nil
TrailBuy = nil
m8 = nil
m9 = nil
na = nil
nb = nil
RebirthRequest = nil
Options = nil
ne = nil
nf = nil
connection = nil
nh = nil
ni = nil
nj = nil
ClickHeat = nil
nl = nil
Toggles = nil
nn = nil
no = nil
np = nil
SaveManager = nil
nr = nil
ns = nil
nt = nil
nu = nil
nv = nil
nw = nil
nx = nil
ny = nil
connection6 = nil
nA = nil
nB = nil
nC = nil
nD = nil
Library = nil
nF = nil
nG = nil
nH = nil
nI = nil
Workspace = nil
nK = nil
nM = nil
nN = nil
connection5 = nil
UnlockWorld3AfterStage = nil
CurrentCamera = nil
HttpService = nil
UnlockAfterStage = nil
nV = nil
connection3 = nil
nX = nil
VirtualUser = nil
nZ = nil
n_ = nil
n0 = nil
n1 = nil
n2 = nil
UserInputService = nil
OvenConfig = nil
n5 = nil
n6 = nil
AurasConfig = nil
n8 = nil
local CoreGui, GuiService, nR
n9 = nil
oa = nil
TrailsConfig = nil
oc = nil
od = nil
oe = nil
of = nil
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, nH = nil, nil, nil, nil, nil, nil, nil
local uV_22 = game:GetService("Players")
local uV_38 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
nH = uV_22.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return nH:WaitForChild("PlayerGui")
    end
end
if setthreadidentity then
    setthreadidentity(8)
end
uV_7, ClickHeat, RebirthRequest, TrailBuy, TrailEquip, AuraBuy, AuraEquip, WorldTeleport, uV_12, Config, PepperConfig, TrailsConfig, AurasConfig, OvenConfig, n0, UnlockAfterStage, UnlockWorld3AfterStage = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local uV_42 = "+1 Heat Per Click"
local uV_40 = uV_38:WaitForChild("TreeGame")
local uV_9 = uV_40:WaitForChild("Remotes")
if uV_7 and not uV_7 and (not uV_40 and uV_12) or (uV_40 or not uV_12 or uV_40 and false) or (not uV_40 or uV_12 or (not uV_7 or not uV_12)) and (not uV_12 and uV_40 and (not uV_12 or uV_40)) or not (uV_7 and not uV_7 and (not uV_40 and uV_12) or (uV_40 or not uV_12 or uV_40 and false) or (not uV_40 or uV_12 or (not uV_7 or not uV_12)) and (not uV_12 and uV_40 and (not uV_12 or uV_40))) then
    uV_7 = uV_38:WaitForChild("Configs")
else
    uV_7:WaitForChild("Configs")
end
ClickHeat = uV_9:WaitForChild("ClickHeat")
RebirthRequest = uV_9:WaitForChild("RebirthRequest")
TrailBuy = uV_9:WaitForChild("TrailBuy")
TrailEquip = uV_9:WaitForChild("TrailEquip")
AuraBuy = uV_9:WaitForChild("AuraBuy")
AuraEquip = uV_9:WaitForChild("AuraEquip")
WorldTeleport = uV_9:WaitForChild("WorldTeleport")
uV_12 = uV_9:WaitForChild("StateSync")
Config = require(uV_40:WaitForChild("Config"))
uV_22 = require(uV_7:WaitForChild("GameConfig"))
PepperConfig = require(uV_7:WaitForChild("PepperConfig"))
TrailsConfig = require(uV_7:WaitForChild("TrailsConfig"))
AurasConfig = require(uV_7:WaitForChild("AurasConfig"))
OvenConfig = require(uV_7:WaitForChild("OvenConfig"))
n0 = #uV_22.ZoneWins
UnlockAfterStage = uV_22.Worlds.UnlockAfterStage
UnlockWorld3AfterStage = uV_22.Worlds.UnlockWorld3AfterStage
local uV_29 = { "Best", "Random" }
local oY = 1
local uV_36 = n0
while oY <= uV_36 do
    local oZ = oY
    uV_29[#uV_29 + 1] = "Zone " .. oZ
    oY += 1
end
Library, SaveManager, Toggles, Options, m8, m3, nB, nw, nr, no, nf, m9, m5, m1, of, mR, nC, connection, nu, np, m0, mH, oc, n2, n8, nK, nx, mX, mN, oe, nX, nI, nt, mY, n9, ni, mJ, nZ, nA, nl, mL, n1, nv, ne, mM, od, nN, m6, mI, na, nh, mZ, mA, nD, mP, nn, mW, mG, nV, nF, mS, n5, nG, nb, mD, ny, mB = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
pcall(fns.fn28)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
m8 = "https://discord.gg/K7Qxnxkk46"
m3 = "https://discord.gg/K7Qxnxkk46"
m0 = fns.fn612
mH = fns.fn6
oc = fn1090
n2 = fn847
local uV_35 = "#7fd47f"
local uV_5 = "#6ec1ff"
nB = "#e8a34d"
local uV_18 = "#8b93a3"
nw = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
nr = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
no = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
nf = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
m9 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
m5 = ""
m1 = ""
local uV_3 = "#345d9d"
local uV_16 = "#f7931a"
local uV_31 = "#627eea"
local uV_1 = "#26a17b"
local uV_14 = "#14f195"
local uV_26 = "#0070ba"
local uV_6 = "#008cff"
n8 = fn1047
nK = fns.fn247
nx = fns.fn542
mX = fns.fn590
mN = fns.fn344
oe = fns.fn274
nX = fn960
nI = function(a9, ...)
    local ba
    ba = { ... }
    pcall(function()
        a9:FireServer(table.unpack(ba))
    end)
end
nt = fns.fn690
mY = function(bk)
    if typeof(bk) ~= "Vector3" then
        return
    end
    if not Workspace.StreamingEnabled then
        return
    end
    pcall(function()
        nH:RequestStreamAroundAsync(bk)
    end)
end
of = {
    wins = 0,
    heat = 0,
    rebirths = 0,
    level = 1,
    ownedPeppers = { [PepperConfig.DEFAULT_ID] = true },
    trails = {},
    auras = {},
    equippedPepper = PepperConfig.DEFAULT_ID,
    equippedTrail = "",
    equippedAura = "",
    ownedOvens = {},
    paidWins = false,
    nextRebirthLevel = Config.maxLevel(0)
}
n9 = fns.fn683
uV_38 = fns.fn139
uV_12.OnClientEvent:Connect(uV_38)
ni = fn1079
mJ = fns.fn155
nZ = fns.fn402
nA = fns.fn31
nl = fns.fn687
mL = fn840
n1 = fns.fn262
nv = fns.fn289
ne = fn1035
mR = 0
mM = fns.fn460
od = fn971
nN = fns.fn544
nC = nil
connection = RunService.Heartbeat:Connect(onHeartbeat)
if (false and (nZ and nN) or (nZ or not nN) and (nZ or nZ)) and (false and nZ and (not nZ or not nN) or (false or nZ or nr and not nZ)) and not ((false and (nZ and nN) or (nZ or not nN) and (nZ or nZ)) and (false and nZ and (not nZ or not nN) or (false or nZ or nr and not nZ))) then
    na.CharacterAdded:Connect(fns.onCharacterAdded)
    mI = fns.fn467
    nH = fn839
    mZ = function()
        local qJ = mX()
        if not qJ then
            return false
        end
        for i, child in qJ:GetChildren() do
            local qK_4 = child:IsA("Tool") and PepperConfig.isValid(child.Name)
            if qK_4 then
                return true
            end
        end
        local qK_5 = of.equippedPepper
        local Stats = nH:FindFirstChild("Stats")
        local qM = Stats and Stats:FindFirstChild("EquippedPepper")
        local qL_3 = qM
        if qM then
            qM = type(qL_3.Value) == "string"
        end
        if qM then
            qM = qL_3.Value ~= ""
        end
        if qM then
            qK_5 = qL_3.Value
        end
        local Backpack = nH:FindFirstChild("Backpack")
        local qM_2 = (qJ:FindFirstChild(qK_5))
        local q_ = if qM_2 then 1 else 0
        local qY = 1608 * q_ + 910 * (1 - q_)
        local qZ = 1267 * q_ + 3596 * (1 - q_)
        if not ((qY * 220 + qZ * 1589 + qY * qZ) % 16777213 == 4404359) then
            local qN = Backpack and Backpack:FindFirstChild(qK_5)
            qM_2 = qN
        end
        local qH = qM_2
        local qK_6 = qH and qH:IsA("Tool")
        if not qK_6 then
            return false
        end
        local qI = mN()
        if qI then
            pcall(function()
                qI:EquipTool(qH)
            end)
        end
        return qJ:FindFirstChildOfClass("Tool") ~= nil
    end
    m6 = fns.fn527
    nh = fns.fn471
else
    nH.CharacterAdded:Connect(fns.onCharacterAdded)
    m6 = fns.fn467
    mI = fn839
    na = function()
        local qJ = mX()
        if not qJ then
            return false
        end
        for i, child in qJ:GetChildren() do
            local qK_1 = child:IsA("Tool") and PepperConfig.isValid(child.Name)
            if qK_1 then
                return true
            end
        end
        local qK_2 = of.equippedPepper
        local Stats = nH:FindFirstChild("Stats")
        local qM = Stats and Stats:FindFirstChild("EquippedPepper")
        local qL_1 = qM
        if qM then
            qM = type(qL_1.Value) == "string"
        end
        if qM then
            qM = qL_1.Value ~= ""
        end
        if qM then
            qK_2 = qL_1.Value
        end
        local Backpack = nH:FindFirstChild("Backpack")
        local qM_1 = (qJ:FindFirstChild(qK_2))
        local q_ = if qM_1 then 1 else 0
        local qY = 1608 * q_ + 910 * (1 - q_)
        local qZ = 1267 * q_ + 3596 * (1 - q_)
        if not ((qY * 220 + qZ * 1589 + qY * qZ) % 16777213 == 4404359) then
            local qN = Backpack and Backpack:FindFirstChild(qK_2)
            qM_1 = qN
        end
        local qH = qM_1
        local qK_3 = qH and qH:IsA("Tool")
        if not qK_3 then
            return false
        end
        local qI = mN()
        if qI then
            pcall(function()
                qI:EquipTool(qH)
            end)
        end
        return qJ:FindFirstChildOfClass("Tool") ~= nil
    end
    nh = fns.fn527
    mZ = fns.fn471
end
mA = fns.fn601
nD = fn1059
mP = fns.fn94
nu = false
np = 0
nn = function(et)
    if not et then
        return
    end
    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(et)
        end)
        return
    end
    pcall(function()
        et:InputHoldBegin()
    end)
    local rw = et.HoldDuration
    local rD = if rw then 1 else 0
    local rB = 278 * rD + 2704 * (1 - rD)
    local rC = 1129 * rD + 696 * (1 - rD)
    if not ((rB * 1376 + rC * 1112 + rB * rC) % 16777213 == 1951838) then
        rw = 0
    end
    task.wait(rw)
    pcall(function()
        et:InputHoldEnd()
    end)
end
mW = fn893
mG = fns.fn688
nV = fns.fn371
nF = fns.fn138
mS = fns.fn389
n5 = fns.fn7
nG = fns.fn21
nb = fns.fn297
mD = fns.fn123
ny = fns.fn385
mB = fn953
uV_7 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = m8, Copyable = true }, "|", uV_42 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local uV_20 = {
    Info = uV_7:AddTab("Info", "info"),
    Main = uV_7:AddTab("Main", "flame"),
    Shop = uV_7:AddTab("Shop", "shopping-bag"),
    Player = uV_7:AddTab("Player", "person-standing"),
    Settings = uV_7:AddTab("Settings", "settings")
}
uV_40 = fns.fn223
for k, v in uV_20 do
    uV_40(v)
end
nj, uV_7, uV_9, mK, mE, uV_38 = nil, nil, nil, nil, nil, nil
uV_22 = 4
repeat
    uV_40 = (uV_22 * 1 + 2) % 3 + 1
    if uV_40 <= 2 then
        if uV_40 <= 1 then
            if (uV_22 or not uV_7) and (uV_7 or not uV_22) and (not uV_22 and uV_7 or (uV_7 or not uV_22)) or not ((uV_22 or not uV_7) and (uV_7 or not uV_22) and (not uV_22 and uV_7 or (uV_7 or not uV_22))) then
                nj = "Unknown"
                pcall(fn735)
                uV_7 = uV_20.Info:AddLeftGroupbox("Account", "circle-user")
                uV_7:AddLabel(n2("User", nH.Name, uV_35), true)
                uV_7:AddLabel(n2("Status", "Keyless", uV_35), true)
                uV_7:AddLabel(n2("Executor", nj, uV_35), true)
                uV_9 = uV_20.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                uV_9:AddLabel(oc(uV_42 .. " [" .. tostring(game.PlaceId) .. "]", uV_5), true)
                uV_9:AddLabel(n2("Place ID", tostring(game.PlaceId), uV_5), true)
                mK = uV_9:AddLabel(n2("Session time", "0s", nB), true)
            else
                n2 = "Unknown"
                pcall(fn735)
                uV_9 = nH.Info:AddLeftGroupbox("Account", "circle-user")
                uV_9:AddLabel(nj("User", mK.Name, uV_7), true)
                uV_9:AddLabel(nj("Status", "Keyless", uV_7), true)
                uV_9:AddLabel(nj("Executor", n2, uV_7), true)
                oc = nH.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                oc:AddLabel(uV_35(nB .. " [" .. tostring(game.PlaceId) .. "]", uV_20), true)
                oc:AddLabel(nj("Place ID", tostring(game.PlaceId), uV_20), true)
                uV_42 = oc:AddLabel(nj("Session time", "0s", uV_5), true)
            end
            uV_22 = (uV_22 + 10) % 12
        else
            uV_40 = (vector.create((uV_22 * 4 + 1) % 11 + 1, (uV_22 * 7 + 2) % 13 + 1, (uV_22 * 8 + 2) % 17 + 1))
            uV_12 = (vector.create((uV_22 * 5 + 6) % 11 + 1, (uV_22 * 8 + 4) % 13 + 1, (uV_22 * 1 + 15) % 17 + 1))
            local v7 = vector.cross(uV_40, uV_12)
            local v8 = vector.dot(uV_40, uV_12)
            if vector.dot(v7, v7) + v8 * v8 == vector.dot(uV_40, uV_40) * vector.dot(uV_12, uV_12) + 2 then
                mK = tostring(game.JobId)
            else
                mE = tostring(game.JobId)
            end
            uV_22 = (uV_22 + 4) % 12
        end
    else
        uV_40 = {
            "yntivceswe",
            "erptmrty",
            "aomlbxd",
            "fayuiocnizk",
            "lzacglgcjcb",
            "ouhuwl",
            "gqcwexv",
            "zhaqtz",
            "wfcktufixn",
            "pliscahih",
            "pdwuhimof"
        }
        if uV_40[(uV_22 * 50 + 84) % 11 + 1] < uV_40[(uV_22 * 50 + 84) % 11 + 1] then
            mE = #uV_38 > 18
        else
            uV_38 = #mE > 18
        end
        uV_22 = (uV_22 + 10) % 12
    end
until (uV_22 * 11 + 9) % 12 == 5
if uV_38 then
    uV_22 = 0
    repeat
        if (uV_22 * 1 + 6) * 9 % 4 == ((uV_22 * 1 + 6) * 9 + 7) % 4 then
            mE = string.sub(uV_38, 1, 18) .. "..."
        else
            uV_38 = string.sub(mE, 1, 18) .. "..."
        end
        uV_22 = (uV_22 + 1) % 4
    until (uV_22 * 1 + 3) % 4 == 0
end
uV_22 = uV_38 or mE
n_, uV_12, connection2, connection3, CurrentCamera, connection4, uV_38, mU, mO, connection5, connection6, n6, oa, nR, ns, m4, nM = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
uV_7 = uV_22
uV_9:AddLabel(n2("Server", uV_7, uV_18), true)
uV_9:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
n_ = os.clock()
task.spawn(worker)
local ScriptsGroup = uV_20.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(oc("Included in this hub", uV_18), true)
ScriptsGroup:AddLabel(oc(uV_42, uV_5), true)
local FeaturesGroup = uV_20.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(oc("Auto Farm", uV_5), true)
FeaturesGroup:AddLabel(oc("Auto Shop", uV_35), true)
FeaturesGroup:AddLabel(oc("Misc Utilities", uV_18), true)
local SocialsGroup = uV_20.Info:AddRightGroupbox("Socials", "link")
if (not connection6 or not connection6) and (not connection6 and not uV_38) and (uV_38 and uV_38 or not uV_38 and not ns) or not ((not connection6 or not connection6) and (not connection6 and not uV_38) and (uV_38 and uV_38 or not uV_38 and not ns)) then
    SocialsGroup:AddButton({ Text = "Discord", Func = mH })
    SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
    uV_12 = uV_20.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
else
    mH:AddButton({ Text = "Discord", Func = uV_20 })
    mH:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
    uV_12.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
end
uV_12:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
uV_12:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
uV_12:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
uV_12:AddButton({ Text = "Copy Discord Invite", Func = mH })
uV_40 = uV_20.Info:AddRightGroupbox("Donations", "heart")
uV_40:AddLabel(oc("All donations are optional but appreciated.", nB), true)
uV_40:AddLabel(oc("If you donate you get a special role, just PING after you donate.", uV_35), true)
uV_40:AddDivider()
uV_40:AddLabel(oc("LTC / Litecoin", uV_3), true)
uV_40:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
uV_40:AddLabel(oc("BTC / Bitcoin", uV_16), true)
uV_40:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
uV_40:AddLabel(oc("ETH / Ethereum", uV_31), true)
uV_40:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
uV_40:AddLabel(oc("USDT", uV_1), true)
uV_40:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
uV_40:AddLabel(oc("Solana", uV_14), true)
uV_40:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
uV_40:AddLabel(oc("PayPal", uV_26), true)
uV_40:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
uV_40:AddLabel(oc("Venmo", uV_6), true)
uV_40:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
uV_40:AddDivider()
uV_40:AddLabel(oc("Don't have any of the listed currencies but still wanna donate?", uV_18), true)
uV_40:AddLabel(oc("DM me and we'll work something out.", uV_5), true)
local FaqGroup = uV_20.Info:AddRightGroupbox("FAQ", "circle-help")
FaqGroup:AddLabel("Where do I get a good config?", true)
FaqGroup:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
FaqGroup:AddLabel("How do I import / export configs?", true)
FaqGroup:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
FaqGroup:AddLabel("How do I report bugs?", true)
FaqGroup:AddLabel("Join the Discord and post it in the bugs channel.", true)
FaqGroup:AddLabel("How do I make suggestions?", true)
FaqGroup:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
FaqGroup:AddLabel("How do I get help or updates?", true)
FaqGroup:AddLabel("Join the Discord, updates and support are posted there first.", true)
local FarmGroup = uV_20.Main:AddLeftGroupbox("Farm", "flame")
FarmGroup:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
FarmGroup:AddDropdown("WinPlate", { Text = "Win Plate", Values = uV_29, Default = "Best" })
FarmGroup:AddSlider("WinDelay", { Text = "Win Delay", Default = 0.55, Min = 0.2, Max = 3, Rounding = 2 })
FarmGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
local TrainGroup = uV_20.Main:AddRightGroupbox("Train", "footprints")
TrainGroup:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
local RebirthGroup = uV_20.Main:AddRightGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local PeppersGroup = uV_20.Shop:AddLeftGroupbox("Peppers", "shopping-basket")
PeppersGroup:AddToggle("AutoBuyPeppers", { Text = "Auto Buy Peppers", Default = false })
local CosmeticsGroup = uV_20.Shop:AddRightGroupbox("Cosmetics", "sparkles")
CosmeticsGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
CosmeticsGroup:AddToggle("AutoBuyAuras", { Text = "Auto Buy Auras", Default = false })
CosmeticsGroup:AddToggle("AutoEquipBestTrail", { Text = "Auto Equip Best Trail", Default = false })
CosmeticsGroup:AddToggle("AutoEquipBestAura", { Text = "Auto Equip Best Aura", Default = false })
local MovementGroup = uV_20.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = uV_20.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
connection2 = RunService.Stepped:Connect(fns.onStepped)
connection3 = UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
connection4 = RunService.RenderStepped:Connect(fns.onRenderStepped)
Toggles.Fly:OnChanged(fns.fn177)
Toggles.WalkSpeedEnabled:OnChanged(fns.fn281)
n6 = function(hH)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not hH)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not hH
        end
    end)
    if not hH then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(nH, "GameplayPaused", false)
        else
            nH.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn783)
task.spawn(fns.antiGameplayPauseLoop)
Toggles.AutoWin:OnChanged(fn937)
Toggles.AutoTrain:OnChanged(fn830)
task.spawn(worker2)
task.spawn(fns.worker3)
task.spawn(fns.worker4)
task.spawn(fns.worker5)
task.spawn(fns.worker6)
uV_38 = uV_20.Settings:AddLeftGroupbox("Menu", "menu")
uV_38:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
mU = tick()
mO = tick()
pcall(function()
    for k, v in getconnections(nH.Idled) do
        local tS = v
        pcall(function()
            tS:Disable()
        end)
    end
end)
oa = fns.fn715
connection5 = UserInputService.InputBegan:Connect(onInputBegan)
connection6 = UserInputService.InputChanged:Connect(onInputChanged)
uV_38:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
uV_38:AddButton("Unload", onUnload)
task.spawn(fns.antiAfkLoop)
Library:OnUnload(fns.fn218)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(uV_20.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/Plus1HeatPerClick")
local uV_2 = SaveManager:BuildConfigSection(uV_20.Settings)
nR = fns.fn84
ns = fns.fn593
m4 = fns.fn391
if (false and not m4 or false and not m4 or (false or nM) and (false or m4)) and ((not m4 or false) and (nM and nM) or false and not m4 and (m4 or not m4)) and not ((false and not m4 or false and not m4 or (false or nM) and (false or m4)) and ((not m4 or false) and (nM and nM) or false and not m4 and (m4 or not m4))) then
    oa = function(jb)
        local uw
        uw = nil
        local ux = type(jb) ~= "table" or type(jb.idx) ~= "string" or type(jb.type) ~= "string" or SaveManager.Ignore[jb.idx]
        if ux then
            return false
        end
        uw = nR(jb.type, jb.idx)
        if not uw then
            return false
        end
        local ux_2 = pcall(function()
            if jb.type == "Input" then
                if type(jb.text) ~= "string" then
                    return
                end
                uw:SetValue(jb.text)
            elseif jb.type == "ColorPicker" then
                uw:SetValueRGB(Color3.fromHex(jb.value), jb.transparency)
            elseif jb.type == "KeyPicker" then
                uw:SetValue({ jb.key, jb.mode, jb.modifiers })
                if jb.mode == "Toggle" and jb.toggled ~= nil then
                    uw.Toggled = jb.toggled
                    uw:Update()
                end
            else
                uw:SetValue(jb.value)
            end
        end)
        return ux_2
    end
else
    nM = function(jb)
        local uw
        uw = nil
        local ux = type(jb) ~= "table" or type(jb.idx) ~= "string" or type(jb.type) ~= "string" or SaveManager.Ignore[jb.idx]
        if ux then
            return false
        end
        uw = nR(jb.type, jb.idx)
        if not uw then
            return false
        end
        local ux_1 = pcall(function()
            if jb.type == "Input" then
                if type(jb.text) ~= "string" then
                    return
                end
                uw:SetValue(jb.text)
            elseif jb.type == "ColorPicker" then
                uw:SetValueRGB(Color3.fromHex(jb.value), jb.transparency)
            elseif jb.type == "KeyPicker" then
                uw:SetValue({ jb.key, jb.mode, jb.modifiers })
                if jb.mode == "Toggle" and jb.toggled ~= nil then
                    uw.Toggled = jb.toggled
                    uw:Update()
                end
            else
                uw:SetValue(jb.value)
            end
        end)
        return ux_1
    end
end
uV_2:AddDivider()
uV_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
uV_2:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
uV_2:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
Library:Notify(uV_42 .. " loaded")
end)(...)
