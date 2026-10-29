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
getgenv().TempoHoodSubtitle = "STREAM A CHEESE PULL!"
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
local m6
local mO
local nc
local mi
local SetupConfig
local mH
local EndStream
local CrateConfig
local PlacementUtil
local mu
local nb
local FoodConfig
local mA
local mZ
local PlotUtil
local nn
local mn
local mM
local mt
local Options
local mz
local mg
local mm
local m3
local mL
local ClaimIndex
local StartStreamAt
local mR
local PlaceSetup
local Toggles
local mX
local nl
local DoRebirth
local m2
local mK
local nr
local mr
local m8
local mQ
local mx
local ne
local mW
local nk
local mk
local m1
local mJ
local nq
local mq
local m7
local mP
local mw
local MysteryBoxLose
local mC
local MysteryBoxBuy
local mj
local m0
local np
local function fn14(fe)
    local rG = fe
    local rH = {}
    if rG then
        rG = fe:FindFirstChild("PlacedSetups")
    end
    local rI = rG
    if not rI then
        return rH
    end
    for i, child in rI:GetChildren() do
        local rG_1 = child:FindFirstChild(PlacementUtil.FOOD_FOLDER)
        if rG_1 then
            for i, child in rG_1:GetChildren() do
                if child:GetAttribute("MysteryBox") == true then
                    rH[#rH + 1] = child
                end
            end
        end
    end
    return rH
end
local function fn51()
    local oH = mq:GetAttribute("Cash") or 0
    return oH
end
local function fn76()
    return mL
end
local function fn168(az, aA, aB)
    return string.format("<b>%s</b> %s %s", az, m0("-", "#5a6070"), m0(aA, aB))
end
local function fn177(aL)
    local oa = Toggles[aL]
    return oa ~= nil and oa.Value == true
end
local function fn181()
    return PlotUtil.FindPlotByOwner(mq.UserId)
end
local function fn185()
    nr(mQ, "Copied Discord invite to clipboard")
end
local function fn196(ek)
    local q6 = ek and ek:FindFirstChild("PlacedSetups")
    if not q6 then
        return nil
    end
    local q6_1 = {}
    for i, child in q6:GetChildren() do
        if child:IsA("Model") then
            local GetById = SetupConfig.GetById
            local q8 = child:GetAttribute("Setup") or child.Name
            local q9 = GetById(q8)
            local q7_2 = #q6_1 + 1
            local q9_1 = q9 and q9.Stretch or 0
            q6_1[q7_2] = { model = child, stretch = q9_1 }
        end
    end
    if #q6_1 == 0 then
        return nil
    end
    local q7_3 = mg("StreamDesk", "Best Placed Desk")
    if q7_3 == "Random Desk" then
        return q6_1[math.random(1, #q6_1)].model
    end
    table.sort(q6_1, function(ew, ex)
        return ew.stretch > ex.stretch
    end)
    return q6_1[1].model
end
local function worker3()
    while not mR.Unloaded do
        if mH("AutoBuyNextCrate") then
            pcall(ne)
        end
        task.wait(0.8)
    end
end
local function fn204(b_)
    local pi = b_ and b_:FindFirstChild("Rolling")
    local pj = pi
    if pi then
        pi = pj:FindFirstChild("Crates")
    end
    local pk = pi
    if pi then
        pi = pk:FindFirstChild("Point")
    end
    local pk_1 = pi
    if pi then
        pi = pk_1:FindFirstChild("Buy")
    end
    local pl = pi
    if pi then
        pi = pl:IsA("ProximityPrompt")
    end
    if pi then
        return pl, pk_1, pj
    end
    return nil
end
local function fn223()
    local Character = mq.Character
    local qi = { mq:FindFirstChild("Backpack"), Character }
    local qj
    local qh_1 = -1
    for k, v in qi do
        if v then
            for i, child in v:GetChildren() do
                if child:IsA("Tool") then
                    local qi_1 = PlacementUtil.PlaceableName(child)
                    local qk = child:GetAttribute("Setup") or qi_1
                    local qk_1 = type(qk) == "string" and SetupConfig.GetById(qk)
                    if qk_1 then
                        local qk_2 = SetupConfig.GetById(qk)
                        local qk_3 = qk_2 and qk_2.Stretch or 0
                        if qk_3 >= qh_1 then
                            qh_1 = qk_3
                            qj = qk
                        end
                    end
                end
            end
        end
    end
    return qj
end
local function worker2()
    while not mR.Unloaded do
        if mH("AutoBuyCrate") then
            pcall(mC)
        end
        task.wait(0.35)
    end
end
local function fn257()
    if os.clock() - m3.LastOpen < 0.55 then
        return
    end
    local qH = mu()
    local qI = qH and qH:FindFirstChild(PlacementUtil.CRATE_FOLDER)
    if not qI then
        return
    end
    for i, child in qI:GetChildren() do
        if child:GetAttribute("Ready") == true then
            local CratePrompt = child:FindFirstChild("CratePrompt", true)
            local qI_1 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
            local qJ = CratePrompt
            if qJ then
                qJ = CratePrompt.Enabled
            end
            if qJ and qI_1 then
                m3.LastOpen = os.clock()
                m6(CratePrompt, qI_1)
                return
            end
        end
    end
end
local function onOnClientEvent()
    m3.Streaming = true
    m3.StreamStartedAt = os.clock()
    m3.StreamFns = nil
    m3.StreamState = nil
end
local function fn372()
    local oV_1
    local oU_1
    local oX_1
    local oT_2
    local oW_1
    local oS = m3.StreamFns and m3.StreamState and typeof(m3.StreamState.Setup) == "Instance"
    if oS then
        return m3.StreamFns, m3.StreamState
    end
    if not getgc or not debug or not debug.getupvalue then
        return nil, nil
    end
    local oS_2 = nil
    for k, v in getgc(true) do
        local oT_1 = type(v) == "table" and rawget(v, "Pulling") ~= nil and typeof(rawget(v, "Setup")) == "Instance"
        if oT_1 then
            oS_2 = v
            break
        end
    end
    if not oS_2 then
        return nil, nil
    end
    oU_1, oV_1, oT_2 = nil, nil, nil
    for k, v in getgc(true) do
        if not (type(v) ~= "function") then
            oW_1, oX_1 = pcall(debug.info, v, "n")
            local oY = oX_1 == "startPulling"
            local oY_3
            local oZ = oX_1 == "pickUp" or oY
            local oZ_1
            if not not (oW_1 and (oZ or oX_1 == "finishPull")) then
                local oW_2 = false
                local pf = 1
                while pf <= 30 do
                    local pg = pf
                    oY_3, oZ_1 = pcall(debug.getupvalue, v, pg)
                    if not oY_3 then
                        break
                    end
                    if oZ_1 == nil and pg > 8 then
                        break
                    elseif oZ_1 == oS_2 then
                        oW_2 = true
                        break
                    else
                        pf += 1
                    end
                end
                if oW_2 then
                    if oX_1 == "pickUp" then
                        oU_1 = v
                    elseif oX_1 == "startPulling" then
                        oV_1 = v
                    elseif oX_1 == "finishPull" then
                        oT_2 = v
                    end
                end
            end
        end
    end
    if not (oU_1 and oV_1 and oT_2) then
        return nil, nil
    end
    m3.StreamFns = { pickUp = oU_1, startPulling = oV_1, finishPull = oT_2 }
    m3.StreamState = oS_2
    return m3.StreamFns, oS_2
end
local function fn381(aE, aF)
    if setclipboard then
        setclipboard(aE)
    elseif toclipboard then
        toclipboard(aE)
    end
    mR:Notify(aF)
end
local function worker7()
    while not mR.Unloaded do
        if mH("AutoMysteryBox") then
            pcall(nq)
        end
        task.wait(0.45)
    end
end
local function fn408()
    local qG = if os.clock() - m3.LastPlaceDesk < 0.45 then 1 else 0
    if qG == 1 then
        return
    end
    local qz = mj()
    if not qz then
        return
    end
    local qA = mu()
    if not qA then
        return
    end
    local qB = mg("PlaceMode", "Random Spot")
    local qC = mA(qA, qz, qB == "Near Desk")
    if not qC then
        return
    end
    m3.LastPlaceDesk = os.clock()
    PlaceSetup:FireServer(qz, qC.area, qC.x, qC.z, qC.rotation, 0)
end
local function fn412()
    local r7 = hookfunction ~= nil
    local r8 = hookmetamethod ~= nil
    local r9 = getrawmetatable ~= nil
    local sa = setrawmetatable ~= nil
    local sb = getgc ~= nil
    local sc = getgenv ~= nil
    local sd = getreg ~= nil
    local se = getconnections ~= nil
    local sf = firesignal ~= nil
    local sg = getcallbackvalue ~= nil
    local sh = setclipboard ~= nil
    local si = getcustomasset ~= nil
    local sj = getnamecallmethod ~= nil
    local sk = isexecutorclosure ~= nil
    local sl = fireproximityprompt ~= nil
    local sm = firetouchinterest ~= nil
    local sn = WebSocket ~= nil
    local so = readfile ~= nil
    local sp = writefile ~= nil
    local sq = request
    local sB = if sq then 1 else 0
    local sz = 4077 * sB + 1921 * (1 - sB)
    local sA = 164 * sB + 3315 * (1 - sB)
    if not ((sz * 1177 + sA * 2665 + sz * sA) % 16777213 == 5904317) then
        sq = http_request
    end
    local sr = sq ~= nil
    local st = (debug and debug.getupvalues) ~= nil
    local sv = (debug and debug.setupvalue) ~= nil
    local sw = 0
    local sx = { r7, r8, r9, sa, sb, sc, sd, se, sf, sg, sh, si, sj, sk, sl, sm, sn, so, sp, sr, st, sv }
    for i, v in ipairs(sx) do
        if v then
            sw += 1
        end
    end
    local r7_1 = sw / #sx
    if r7_1 >= 0.9 then
        return m0("Full Support", mt)
    elseif r7_1 >= 0.6 then
        return m0("Half Support", mm)
    else
        return m0("Low Support", np)
    end
end
local function fn423(aX, aY)
    local ol = Options[aX]
    local ol_1 = ol and ol.Value
    if type(ol_1) == "number" then
        return ol_1
    end
    return aY
end
local function fn431(bi, bj)
    local oC = not bi or not bi:IsA("ProximityPrompt")
    if oC then
        return false
    end
    if bj then
        mi(bj.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.12)
    end
    if fireproximityprompt then
        fireproximityprompt(bi)
        return true
    end
    return false
end
local function fn438()
    if os.clock() - m3.LastIndex < 1.5 then
        return
    end
    m3.LastIndex = os.clock()
    for k, v in FoodConfig.GetAll() do
        local qZ = FoodConfig.AttributeName("Index_", v.Name)
        if mq:GetAttribute(qZ) == "Found" then
            ClaimIndex:FireServer(v.Name)
            task.wait(0.05)
        end
    end
end
local function worker()
    while mR and not mR.Unloaded do
        mJ()
        task.wait(1)
    end
end
local function fn487(cI, cJ, cK)
    local pK_2
    local pE_1
    local pL_3
    local pJ_3
    local pD_1
    local pB = cJ == ""
    local pC = type(cJ) ~= "string" or pB
    local pC_2
    if pC then
        return nil
    end
    local pB_1 = PlacementUtil.GetAreas(cI)
    local pC_1 = type(pB_1) ~= "table" or #pB_1 == 0
    if pC_1 then
        return nil
    end
    pE_1, pC_2, pD_1 = PlacementUtil.Resolve(cJ)
    if not pD_1 then
        return nil
    end
    local pC_3 = PlacementUtil.GetFootprint(pD_1)
    local pF = PlacementUtil.HeightOf(pD_1)
    local GridFor = PlacementUtil.GridFor
    local pG = pE_1 or "Crate"
    local pE_2 = GridFor(pG)
    local pD_3 = math.clamp(math.floor(mM("PlaceRotation", 0) + 0.5), 0, 3)
    local pG_1 = {}
    local pH
    if cK then
        local PlacedSetups = cI:FindFirstChild("PlacedSetups")
        local pJ_1 = nil
        local pK_1 = -1
        if PlacedSetups then
            for i, child in PlacedSetups:GetChildren() do
                local GetById = SetupConfig.GetById
                local pL_1 = child:GetAttribute("Setup") or child.Name
                local pM = GetById(pL_1)
                local pL_2 = pM and pM.Stretch or 0
                if pL_2 >= pK_1 then
                    pK_1 = pL_2
                    pJ_1 = child
                end
            end
        end
        if pJ_1 then
            local pI_5 = pJ_1.PrimaryPart or pJ_1:FindFirstChildWhichIsA("BasePart")
            local pJ_2 = pI_5
            if pI_5 then
                pI_5 = pJ_2.Position
            end
            pH = pI_5
        end
    end
    for i, v in ipairs(pB_1) do
        if v:IsA("BasePart") then
            local CFrame2 = v.CFrame
            local p4 = -6
            while p4 <= 6 do
                local p5 = p4
                local p9 = -6
                while p9 <= 6 do
                    local qa = p9
                    local Position = (CFrame2 * CFrame.new(p5 * pE_2, v.Size.Y / 2, qa * pE_2)).Position
                    pK_2, pJ_3 = PlacementUtil.SnapToGrid(v, pC_3, pD_3, Position, pE_2)
                    local pI_7 = pK_2 and PlacementUtil.IsValidCell(v, pC_3, pD_3, pK_2, pJ_3, pE_2)
                    if pI_7 then
                        local pI_8 = PlacementUtil.ComputeCFrame(v, pK_2, pJ_3, pD_3)
                        if not PlacementUtil.BlockedBy(cI, pC_3, pD_3, pI_8, 0, pF, nil, false) then
                            if pH then
                                pL_3 = -(pI_8.Position - pH).Magnitude
                            else
                                pL_3 = math.random()
                            end
                            pG_1[#pG_1 + 1] = { area = v, x = pK_2, z = pJ_3, rotation = pD_3, score = pL_3 }
                        end
                    end
                    p9 += 1
                end
                p4 += 1
            end
        end
    end
    if #pG_1 == 0 then
        return nil
    end
    table.sort(pG_1, function(di, dj)
        return di.score > dj.score
    end)
    return pG_1[1]
end
local function fn490()
    if os.clock() - m3.LastExpand < 1.4 then
        return
    end
    local ru = mu()
    local rv = ru and ru:FindFirstChild("Expansions")
    if not rv then
        return
    end
    local rv_1 = nil
    local rw = math.huge
    for i, child in rv:GetChildren() do
        local attr = child:GetAttribute("ExpansionPrice")
        local Buy = child:FindFirstChild("Buy")
        local ry = type(attr) == "number" and attr > 0 and attr <= nl() and Buy and Buy:IsA("ProximityPrompt")
        if ry then
            if attr < rw then
                rw = attr
                rv_1 = Buy
            end
        end
    end
    if not rv_1 then
        return
    end
    m3.LastExpand = os.clock()
    local ru_3 = rv_1.Parent
    if ru_3 then
        local rw_1 = rv_1.Parent:IsA("BasePart") and rv_1.Parent
        local rx_2 = rw_1 or rv_1.Parent:FindFirstChildWhichIsA("BasePart")
        ru_3 = rx_2
    end
    local rw_2 = ru_3
    m6(rv_1, rw_2)
end
local function worker4()
    while not mR.Unloaded do
        if mH("AutoPlaceCrate") then
            pcall(nn)
        end
        if mH("AutoPlaceDesk") then
            pcall(mX)
        end
        task.wait(0.3)
    end
end
local function fn495()
    local oL = mq:GetAttribute("CrateLevel") or 1
    return oL
end
local function fn505()
    local rl_2
    local rk_2
    if mK() then
        local rk_1 = mM("AutoFinishMinutes", 5)
        local rl_1 = rk_1 > 0 and m3.StreamStartedAt > 0 and os.clock() - m3.StreamStartedAt >= rk_1 * 60
        if rl_1 then
            EndStream:FireServer()
            m3.Streaming = false
            m3.StreamStartedAt = 0
            m3.StreamFns = nil
            m3.StreamState = nil
            return
        end
        local rq = if os.clock() - m3.LastPull < 0.35 then 1 else 0
        if rq == 1 then
            return
        end
        rl_2, rk_2 = nb()
        if not (rl_2 and rk_2) then
            return
        end
        m3.LastPull = os.clock()
        if rk_2.Held then
            if rk_2.Held.Max and rk_2.Held.Distance and rk_2.Held.Distance >= rk_2.Held.Max * 0.98 then
                pcall(rl_2.finishPull)
            elseif not rk_2.Pulling then
                pcall(rl_2.startPulling)
            end
            return
        end
        local Setup = rk_2.Setup
        local rk_3 = Setup and Setup:FindFirstChild(PlacementUtil.FOOD_FOLDER)
        if not rk_3 then
            return
        end
        local children = rk_3:GetChildren()
        if #children == 0 then
            return
        end
        local rm_5 = children[math.random(1, #children)]
        pcall(rl_2.pickUp, rm_5)
        task.wait(0.15)
        pcall(rl_2.startPulling)
        return
    end
    if os.clock() - m3.LastStreamStart < 2 then
        return
    end
    local rk_5 = mu()
    local rl_3 = m2(rk_5)
    if not rl_3 then
        return
    end
    m3.LastStreamStart = os.clock()
    local rk_6 = rl_3.PrimaryPart or rl_3:FindFirstChildWhichIsA("BasePart")
    if rk_6 then
        mi(rk_6.CFrame + Vector3.new(0, 4, 0))
        task.wait(0.15)
    end
    StartStreamAt:FireServer(rl_3)
end
local function fn516()
    local Character = mq.Character
    local op = Character and Character:FindFirstChild("HumanoidRootPart")
    return op
end
local function fn539()
    local attr = mq:GetAttribute("HeldCrate")
    local qd = attr == ""
    local qe = type(attr) ~= "string" or qd
    if qe then
        return
    end
    if os.clock() - m3.LastPlace < 0.45 then
        return
    end
    local qd_1 = mu()
    if not qd_1 then
        return
    end
    local qe_1 = mg("PlaceMode", "Random Spot")
    local qf = mA(qd_1, attr, qe_1 == "Near Desk")
    if not qf then
        return
    end
    m3.LastPlace = os.clock()
    PlaceSetup:FireServer(attr, qf.area, qf.x, qf.z, qf.rotation, 0)
end
local function fn540(aQ, aR)
    local od = Options[aQ]
    local oe = od and od.Value
    local oe_1 = oe ~= ""
    local of = type(oe) == "string" and oe_1
    if of then
        return oe
    end
    return aR
end
local function fn579(be)
    local ow = nk()
    if ow and be then
        ow.CFrame = be
    end
end
local function fn596()
    local pq_1
    local pp_1
    local po_1
    if mq:GetAttribute("HeldCrate") ~= nil then
        return
    end
    if os.clock() - m3.LastBuy < 0.85 then
        return
    end
    local pn = mu()
    pq_1, pp_1, po_1 = mr(pn)
    if not (pq_1 and pp_1 and po_1) then
        return
    end
    local pn_2 = po_1:GetAttribute("TakeReadyAt") or 0
    if pn_2 > mw:GetServerTimeNow() then
        return
    end
    local attr = po_1:GetAttribute("StandCrate")
    local po_2 = attr and CrateConfig.GetById(attr)
    if not po_2 then
        return
    end
    local po_3 = mq:GetAttribute("NeedsTutorial") == true and 0
    local pr_2 = po_3 or CrateConfig.GetPrice(po_2)
    if nl() < pr_2 then
        return
    end
    if not pq_1.Enabled then
        return
    end
    m3.LastBuy = os.clock()
    m6(pq_1, pp_1)
end
local function worker5()
    while not mR.Unloaded do
        if mH("AutoOpenReadyCrate") then
            pcall(m7)
        end
        task.wait(0.4)
    end
end
local function worker10()
    while not mR.Unloaded do
        if mH("AutoExpandPlot") then
            pcall(mP)
        end
        task.wait(1)
    end
end
local function fn630(aw, ax)
    return string.format('<font color="%s">%s</font>', ax, aw)
end
local function worker9()
    while not mR.Unloaded do
        if mH("AutoClaimIndex") then
            pcall(mx)
        end
        task.wait(1.25)
    end
end
local function fn643()
    if os.clock() - m3.LastNext < 1.2 then
        return
    end
    local pt = CrateConfig.NextLevel(mW())
    if not pt then
        return
    end
    local UnlockSubsFor = CrateConfig.UnlockSubsFor
    local pv = mq:GetAttribute("Rebirths") or 0
    local pw = UnlockSubsFor(pt, pv)
    if m8() < pw then
        return
    end
    local pu_1 = pt.UnlockPrice or 0
    if nl() < pu_1 then
        return
    end
    local pt_2 = mu()
    local pu_2 = pt_2 and pt_2:FindFirstChild("Upgrades")
    local pt_3 = pu_2
    if pu_2 then
        pu_2 = pt_3:FindFirstChild("UpgradeCrate")
    end
    local pt_4 = pu_2
    if pu_2 then
        pu_2 = pt_4:FindFirstChild("ButtonPart")
    end
    local pt_5 = pu_2
    if not pt_5 then
        return
    end
    m3.LastNext = os.clock()
    mz(pt_5)
end
local function onOnClientEvent2()
    m3.Streaming = false
    m3.StreamStartedAt = 0
    m3.StreamFns = nil
    m3.StreamState = nil
end
local function fn660()
    local qY = if os.clock() - m3.LastRebirth < 2 then 1 else 0
    if qY == 1 then
        return
    end
    if mq:GetAttribute("RebirthEligible") ~= true then
        return
    end
    m3.LastRebirth = os.clock()
    DoRebirth:FireServer()
end
local function worker6()
    while not mR.Unloaded do
        if mH("AutoStream") then
            pcall(mO)
            task.wait(0.25)
        else
            task.wait(0.4)
        end
    end
end
local function fn689()
    local oO_1
    local oN_1
    if m3.Streaming then
        return true
    end
    oN_1, oO_1 = pcall(function()
        return mn.UI.Pages.Streaming.Visible
    end)
    return oN_1 and oO_1 == true
end
local function fn730(fD)
    local DiscordGroup = fD:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = m1 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = m1 })
end
local function fn783()
    local oJ = mq:GetAttribute("Subscribers") or 0
    return oJ
end
local function worker8()
    while not mR.Unloaded do
        if mH("AutoRebirth") then
            pcall(mZ)
        end
        task.wait(1)
    end
end
local function fn815()
    local r0 = if os.clock() - m3.LastMysteryBox < 0.6 then 1 else 0
    if r0 == 1 then
        return
    end
    local rW = mu()
    local rX = nc(rW)
    if #rX == 0 then
        return
    end
    m3.LastMysteryBox = os.clock()
    for k, v in rX do
        if v.Parent then
            local rW_1 = v:GetAttribute("BoxPrice") or 0
            if nl() >= rW_1 then
                MysteryBoxBuy:FireServer(v)
            else
                MysteryBoxLose:FireServer(v)
            end
            task.wait(0.15)
        end
    end
end
local function fn889(bn)
    local oE = nk()
    if not (oE and bn) then
        return false
    end
    mi(bn.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.1)
    if firetouchinterest then
        firetouchinterest(oE, bn, 0)
        task.wait(0.08)
        firetouchinterest(oE, bn, 1)
        return true
    end
    return false
end
local function fn910()
    local Character = mq.Character
    local ou = Character and Character:FindFirstChildOfClass("Humanoid")
    return ou
end
mg = nil
mi = nil
mj = nil
mk = nil
DoRebirth = nil
mm = nil
mn = nil
EndStream = nil
mq = nil
mr = nil
StartStreamAt = nil
mt = nil
mu = nil
mw = nil
mx = nil
PlaceSetup = nil
mz = nil
mA = nil
mC = nil
PlotUtil = nil
mH = nil
mJ = nil
mK = nil
mL = nil
mM = nil
PlacementUtil = nil
mO = nil
mP = nil
mQ = nil
mR = nil
FoodConfig = nil
mW = nil
mX = nil
mZ = nil
SetupConfig = nil
m0 = nil
m1 = nil
local mf, mh, mp, mv, mB, mD, mE, TeleportService, mI, GuiService, mU, mV, HttpService
m2 = nil
m3 = nil
CrateConfig = nil
m6 = nil
m7 = nil
m8 = nil
Options = nil
nb = nil
nc = nil
MysteryBoxLose = nil
ne = nil
Toggles = nil
local ni
MysteryBoxBuy = nil
nk = nil
nl = nil
nn = nil
np = nil
nq = nil
nr = nil
ClaimIndex = nil
local m4, m9, ng, nh, nm, no
local nA_1
local nB_1
local nv_3
local ReplicatedStorage, nu_2, nu_4
local nw_7
mf, ReplicatedStorage, ng, m9, m4, HttpService, GuiService, mL, TeleportService, mw, mq, mn, mk = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local nt = 17
repeat
    local nv_1 = (nt * 3 + 0) % 7 + 1
    if nv_1 <= 4 then
        if nv_1 <= 2 then
            if nv_1 <= 1 then
                local wd = bit32.rrotate(bit32.bxor(bit32.lrotate(nt, 15), string.byte(tostring(m9))), 29)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(wd, 1622873017), 2672700876), (bit32.bxor(bit32.band(wd, 2672094278), 174653083))), 2672700876), 174653083) == wd then
                    mL = game:GetService("CoreGui")
                    TeleportService = game:GetService("TeleportService")
                    mw = game:GetService("Workspace")
                    mq = mf.LocalPlayer
                    mn = mq:WaitForChild("PlayerGui")
                else
                    mf = game:GetService("CoreGui")
                    mw = game:GetService("TeleportService")
                    mn = game:GetService("Workspace")
                    mL = TeleportService.LocalPlayer
                    mq = mL:WaitForChild("PlayerGui")
                end
                nt = (nt + 26) % 28
            else
                local nw_1 = {
                    "riwc",
                    "xuqhgf",
                    "ztrqcr",
                    "vwb",
                    "zywjiqb",
                    "kinqvtubny",
                    "etipeessnuh",
                    "nrqnieuijnil",
                    "tavyhbsfot",
                    "djuezkvvvzbk",
                    "sbqahkyfm",
                    "qxvfguvnp",
                    "obg",
                    "knpoaazyu"
                }
                if nw_1[(nt * 74 + 48) % 14 + 1] <= nw_1[(nt * 74 + 48) % 14 + 1] then
                    mk = fn76
                else
                    mf = fn76
                end
                nt = (nt + 5) % 28
            end
        elseif nv_1 <= 3 then
            if nt * 116330215 + 12 + 3 <= nt * 116330215 + 12 + 3 + 5 then
                mf = game:GetService("Players")
            else
                mk = game:GetService("Players")
            end
            nt = (nt + 19) % 28
        else
            local nw_2 = (vector.create((nt * 5 + 9) % 11 + 1, (nt * 3 + 9) % 13 + 1, (nt * 14 + 12) % 17 + 1))
            local nx_1 = (vector.create((nt * 4 + 5) % 11 + 1, (nt * 7 + 7) % 13 + 1, (nt * 5 + 5) % 17 + 1))
            local ny_1 = (vector.create((nt * 4 + 7) % 5 + 1, (nt * 2 + 4) % 7 + 1, (nt * 3 + 3) % 9 + 1))
            if math.abs((vector.angle(nw_2, nx_1, ny_1))) - math.abs((vector.angle(nx_1, nw_2, ny_1))) == 2 then
                m9 = game:GetService("ReplicatedStorage")
            else
                ReplicatedStorage = game:GetService("ReplicatedStorage")
            end
            nt = (nt + 5) % 28
        end
    elseif nv_1 <= 6 then
        if nv_1 <= 5 then
            if nt * 63709955 + 12 + 4 >= nt * 63709955 + 12 + 4 + 1 then
                m9 = game:GetService("RunService")
                m4 = game:GetService("UserInputService")
                ng = game:GetService("VirtualUser")
            else
                ng = game:GetService("RunService")
                m9 = game:GetService("UserInputService")
                m4 = game:GetService("VirtualUser")
            end
            nt = (nt + 5) % 28
        else
            local nv_2 = (vector.create((nt * 4 + 4) % 11 + 1, (nt * 6 + 7) % 13 + 1, (nt * 6 + 11) % 17 + 1))
            local nw_3 = (vector.create((nt * 4 + 8) % 11 + 1, (nt * 5 + 11) % 13 + 1, (nt * 13 + 1) % 17 + 1))
            local vG = vector.cross(nv_2, nw_3)
            local vH = vector.dot(nv_2, nw_3)
            if vector.dot(vG, vG) + vH * vH == vector.dot(nv_2, nv_2) * vector.dot(nw_3, nw_3) + 1 then
                mf = game:GetService("HttpService")
            else
                HttpService = game:GetService("HttpService")
            end
            nt = (nt + 5) % 28
        end
    else
        local wo = bit32.rrotate(bit32.bxor(bit32.lrotate(nt, 10), string.byte(tostring(HttpService))), 3)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(wo, 692205099), 2600386023), (bit32.bxor(bit32.band(wo, 3602762196), 1607412448))), 2600386023), 1607412448) == wo then
            GuiService = game:GetService("GuiService")
        else
            m9 = game:GetService("GuiService")
        end
        nt = (nt + 19) % 28
    end
until (nt * 11 + 17) % 28 == 8
if getgenv then
    ni, nv_3 = nil, nil
    local nt_1 = 14
    repeat
        if (nt_1 * 1 + 0) % 2 + 1 <= 1 then
            local nw_5 = (vector.create((nt_1 * 5 + 3) % 11 + 1, (nt_1 * 7 + 8) % 13 + 1, (nt_1 * 4 + 6) % 17 + 1))
            local nx_2 = (vector.create((nt_1 * 7 + 3) % 11 + 1, (nt_1 * 10 + 11) % 13 + 1, (nt_1 * 7 + 6) % 17 + 1))
            local vI = vector.cross(nw_5, nx_2)
            local vJ = vector.dot(nw_5, nx_2)
            if vector.dot(vI, vI) + vJ * vJ == vector.dot(nw_5, nw_5) * vector.dot(nx_2, nx_2) then
                getgenv().gethui = mk
                ni = getgenv().__TempoCheesePullLib
            else
                getgenv().gethui = ni
                mk = getgenv().__TempoCheesePullLib
            end
            nt_1 = (nt_1 + 3) % 16
        else
            if (nt_1 * 1 + 3) * 13 % 4 == ((nt_1 * 1 + 3) * 13 + 14) % 4 then
                ni = nv_3
            else
                nv_3 = ni
            end
            nt_1 = (nt_1 + 3) % 16
        end
    until (nt_1 * 5 + 9) % 16 == 13
    if nv_3 then
        nv_3 = ni.Unload
    end
    if nv_3 then
        pcall(function()
            ni:Unload()
        end)
    end
end
pcall(function()
    gethui = mk
end)
if setthreadidentity then
    setthreadidentity(8)
end
mU, mQ, mI, mB, mt, mp, mm, mh, np, CrateConfig, SetupConfig, FoodConfig, PlacementUtil, PlotUtil, PlaceSetup, StartStreamAt, EndStream, DoRebirth, ClaimIndex, MysteryBoxBuy, MysteryBoxLose, mR, nm, mJ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
mU = "Stream A Cheese Pull!"
mQ = "https://discord.gg/K7Qxnxkk46"
mI = "https://discord.gg/K7Qxnxkk46"
mB = "https://tempohub.shop"
mt = "#7fd47f"
mp = "#6ec1ff"
mm = "#e8a34d"
mh = "#8b93a3"
np = "#e05a5a"
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local nw_6 = ReplicatedStorage:WaitForChild("Modules")
CrateConfig = require(nw_6:WaitForChild("CrateConfig"))
if 63 and (false and nm or (nm or not mR)) or not (63 and (false and nm or (nm or not mR))) then
    SetupConfig = require(nw_6:WaitForChild("SetupConfig"))
else
    nw_6 = require(SetupConfig:WaitForChild("SetupConfig"))
end
FoodConfig = require(nw_6:WaitForChild("FoodConfig"))
PlacementUtil = require(nw_6:WaitForChild("PlacementUtil"))
PlotUtil = require(nw_6:WaitForChild("PlotUtil"))
PlaceSetup = Remotes:WaitForChild("PlaceSetup")
StartStreamAt = Remotes:WaitForChild("StartStreamAt")
EndStream = Remotes:WaitForChild("EndStream")
DoRebirth = Remotes:WaitForChild("DoRebirth")
ClaimIndex = Remotes:WaitForChild("ClaimIndex")
MysteryBoxBuy = Remotes:WaitForChild("MysteryBoxBuy")
MysteryBoxLose = Remotes:WaitForChild("MysteryBoxLose")
local StreamStarted = Remotes:WaitForChild("StreamStarted")
local StreamEnded = Remotes:WaitForChild("StreamEnded")
if ((StreamEnded or not StreamEnded) and (false or StreamEnded) or (not StreamEnded or false) and (StreamEnded and not StreamEnded)) and not ((StreamEnded or not StreamEnded) and (false or StreamEnded) or (not StreamEnded or false) and (StreamEnded and not StreamEnded)) then
    mJ = ""
    local _ = getgenv().Library
    mR = function()
        local function nY(aa)
            local nT = not aa
            local nX = if nT then 1 else 0
            local nV = 3671 * nX + 851 * (1 - nX)
            local nW = 484 * nX + 1029 * (1 - nX)
            if not ((nV * 471 + nW * 2600 + nV * nW) % 16777213 == 4764205) then
                nT = not aa:IsA("ScreenGui")
            end
            if nT then
                return
            end
            aa.ResetOnSpawn = false
            aa.IgnoreGuiInset = true
            aa.DisplayOrder = math.max(aa.DisplayOrder, 1000)
            pcall(function()
                aa.ClipToDeviceSafeArea = false
            end)
            pcall(function()
                aa.ScreenInsets = Enum.ScreenInsets.None
            end)
            if aa.Parent ~= mL then
                aa.Parent = mL
            end
        end
        nY(mR.ScreenGui)
        if mR.ActiveLoading and mR.ActiveLoading.ScreenGui then
            nY(mR.ActiveLoading.ScreenGui)
        end
        for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
            local nZ_2 = mL:FindFirstChild(v) or mn:FindFirstChild(v)
            if nZ_2 then
                nY(nZ_2)
            end
        end
    end
    mR()
    task.spawn(worker)
    nm = getgenv().ThemeManager
    nA_1 = getgenv().SaveManager
else
    mR = getgenv().Library
    mJ = function()
        local function nY(aa)
            local nT = not aa
            local nX = if nT then 1 else 0
            local nV = 3671 * nX + 851 * (1 - nX)
            local nW = 484 * nX + 1029 * (1 - nX)
            if not ((nV * 471 + nW * 2600 + nV * nW) % 16777213 == 4764205) then
                nT = not aa:IsA("ScreenGui")
            end
            if nT then
                return
            end
            aa.ResetOnSpawn = false
            aa.IgnoreGuiInset = true
            aa.DisplayOrder = math.max(aa.DisplayOrder, 1000)
            pcall(function()
                aa.ClipToDeviceSafeArea = false
            end)
            pcall(function()
                aa.ScreenInsets = Enum.ScreenInsets.None
            end)
            if aa.Parent ~= mL then
                aa.Parent = mL
            end
        end
        nY(mR.ScreenGui)
        if mR.ActiveLoading and mR.ActiveLoading.ScreenGui then
            nY(mR.ActiveLoading.ScreenGui)
        end
        for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
            local nZ_1 = mL:FindFirstChild(v) or mn:FindFirstChild(v)
            if nZ_1 then
                nY(nZ_1)
            end
        end
    end
    mJ()
    task.spawn(worker)
    nA_1 = getgenv().ThemeManager
    nm = getgenv().SaveManager
end
if getgenv then
    getgenv().__TempoCheesePullLib = mR
end
Toggles, Options, m3, nu_2, no, m0, mE, nr, m1, mH, mg, mM, nk, mV, mu, mi, m6, mz, nl, m8, mW, mK, nb, mr, mC, ne, mA, nn, mj, mX, m7, mZ, mx, m2, mO, mP, nc, nq = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = mR.Toggles
Options = mR.Options
m3 = {
    Streaming = false,
    StreamStartedAt = 0,
    LastBuy = 0,
    LastNext = 0,
    LastPlace = 0,
    LastPlaceDesk = 0,
    LastOpen = 0,
    LastExpand = 0,
    LastRebirth = 0,
    LastIndex = 0,
    LastStreamStart = 0,
    LastPull = 0,
    LastMysteryBox = 0,
    StreamFns = nil,
    StreamState = nil
}
m0 = fn630
mE = fn168
nr = fn381
m1 = fn185
mH = fn177
mg = fn540
mM = fn423
nk = fn516
mV = fn910
mu = fn181
mi = fn579
m6 = fn431
mz = fn889
nl = fn51
m8 = fn783
mW = fn495
mK = fn689
StreamStarted.OnClientEvent:Connect(onOnClientEvent)
StreamEnded.OnClientEvent:Connect(onOnClientEvent2)
nb = fn372
mr = fn204
mC = fn596
ne = fn643
mA = fn487
nn = fn539
mj = fn223
mX = fn408
m7 = fn257
mZ = fn660
mx = fn438
if nu_2 and not mj or (not Toggles or mi) or (not mi and mg or (mj or false)) or not (nu_2 and not mj or (not Toggles or mi) or (not mi and mg or (mj or false))) then
    m2 = fn196
    mO = fn505
else
    mO = fn196
    m2 = fn505
end
mP = fn490
nc = fn14
nq = fn815
local Window = mR:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mQ, Copyable = true }, "|", mU },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
no = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in no do
    if k ~= "Info" then
        fn730(v)
    end
end
nB_1, mv, nh, mD, nw_7, nu_4 = nil, nil, nil, nil, nil, nil
mD = fn412
if (not nB_1 and nu_4 or not nB_1 and nB_1) and (nu_4 and not nB_1 and (not nu_4 or nw_7)) or (not nw_7 or nw_7 or (nw_7 or not nw_7)) and (nw_7 or nu_4 or nu_4 and not nB_1) or (not nB_1 or nw_7 or not nB_1 and nB_1 or nu_4 and not nw_7 and (nw_7 and not nu_4)) and ((not nu_4 and nw_7 or (nB_1 or nw_7)) and ((not nB_1 or not nw_7) and (not nu_4 and not nw_7))) or not ((not nB_1 and nu_4 or not nB_1 and nB_1) and (nu_4 and not nB_1 and (not nu_4 or nw_7)) or (not nw_7 or nw_7 or (nw_7 or not nw_7)) and (nw_7 or nu_4 or nu_4 and not nB_1) or (not nB_1 or nw_7 or not nB_1 and nB_1 or nu_4 and not nw_7 and (nw_7 and not nu_4)) and ((not nu_4 and nw_7 or (nB_1 or nw_7)) and ((not nB_1 or not nw_7) and (not nu_4 and not nw_7)))) then
    nw_7 = function()
        local s4
        local s0
        s0 = nil
        s4 = nil
        local Label, Label2, Label3, s2, s3
        s4 = "Unknown"
        pcall(function()
            local sJ_2
            local sI_3
            if identifyexecutor then
                sJ_2, sI_3 = identifyexecutor()
                local sK = sJ_2 ~= ""
                local sL = type(sJ_2) == "string" and sK
                if sL then
                    local sK_2 = type(sI_3) == "string" and sI_3 ~= "" and sJ_2 .. " " .. sI_3
                    s4 = sK_2 or sJ_2
                end
            end
        end)
        local s5 = mD()
        s0 = os.clock()
        s3 = function()
            local sQ = math.floor(os.clock() - s0)
            if sQ < 60 then
                return sQ .. "s"
            elseif sQ < 3600 then
                return string.format("%dm %ds", math.floor((sQ) / (60)), sQ % 60)
            else
                return string.format("%dh %dm", math.floor((sQ) / (3600)), math.floor((sQ % 3600) / (60)))
            end
        end
        local UserGroup = no.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = mq, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(mE("User", mq.DisplayName .. " @" .. mq.Name, mt), true)
        UserGroup:AddLabel(mE("UserId", tostring(mq.UserId), mp), true)
        UserGroup:AddLabel(mE("Executor", s4 .. "  " .. s5, mt), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(mE("Session", s3(), mm), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                nr(mq.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                nr("https://www.roblox.com/users/" .. tostring(mq.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = no.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddDivider("Server")
        SessionGroup:AddLabel(mE("Game", mU, mp), true)
        Label2 = SessionGroup:AddLabel(mE("Players", "0/0", mt), true)
        s2 = tostring(game.JobId)
        local s6_3 = #s2 > 18 and string.sub(s2, 1, 18) .. "..."
        local s6_4 = s6_3 or s2
        SessionGroup:AddLabel(mE("Job", s6_4, mh), true)
        Label = SessionGroup:AddLabel(mE("Ping", "0 ms", mm), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Server",
            Func = function()
                TeleportService:Teleport(game.PlaceId, mq)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                nr(s2, "Copied Job ID")
            end
        })
        task.spawn(function()
            local sW_2
            local sV_3
            while true do
                task.wait(1)
                if mR.Unloaded then
                    break
                end
                Label3:SetText(mE("Session", s3(), mm))
                Label2:SetText(mE("Players", #mf:GetPlayers() .. "/" .. tostring(mf.MaxPlayers), mt))
                sV_3, sW_2 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local sV_4 = sV_3 and sW_2 .. " ms" or "n/a"
                Label:SetText(mE("Ping", sV_4, mm))
            end
        end)
        local SocialsGroup = no.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = m1 })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                nr(mI, "Copied Rscripts profile to clipboard")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                nr(mB, "Copied website link")
            end
        })
    end
else
    mv = function()
        local s4
        local s0
        s0 = nil
        s4 = nil
        local Label, Label2, Label3, s2, s3
        s4 = "Unknown"
        pcall(function()
            local sJ_1
            local sI_1
            if identifyexecutor then
                sJ_1, sI_1 = identifyexecutor()
                local sK = sJ_1 ~= ""
                local sL = type(sJ_1) == "string" and sK
                if sL then
                    local sK_1 = type(sI_1) == "string" and sI_1 ~= "" and sJ_1 .. " " .. sI_1
                    s4 = sK_1 or sJ_1
                end
            end
        end)
        local s5 = mD()
        s0 = os.clock()
        s3 = function()
            local sQ = math.floor(os.clock() - s0)
            if sQ < 60 then
                return sQ .. "s"
            elseif sQ < 3600 then
                return string.format("%dm %ds", math.floor((sQ) / (60)), sQ % 60)
            else
                return string.format("%dh %dm", math.floor((sQ) / (3600)), math.floor((sQ % 3600) / (60)))
            end
        end
        local UserGroup = no.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = mq, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(mE("User", mq.DisplayName .. " @" .. mq.Name, mt), true)
        UserGroup:AddLabel(mE("UserId", tostring(mq.UserId), mp), true)
        UserGroup:AddLabel(mE("Executor", s4 .. "  " .. s5, mt), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(mE("Session", s3(), mm), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                nr(mq.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                nr("https://www.roblox.com/users/" .. tostring(mq.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = no.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddDivider("Server")
        SessionGroup:AddLabel(mE("Game", mU, mp), true)
        Label2 = SessionGroup:AddLabel(mE("Players", "0/0", mt), true)
        s2 = tostring(game.JobId)
        local s6_1 = #s2 > 18 and string.sub(s2, 1, 18) .. "..."
        local s6_2 = s6_1 or s2
        SessionGroup:AddLabel(mE("Job", s6_2, mh), true)
        Label = SessionGroup:AddLabel(mE("Ping", "0 ms", mm), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Server",
            Func = function()
                TeleportService:Teleport(game.PlaceId, mq)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                nr(s2, "Copied Job ID")
            end
        })
        task.spawn(function()
            local sW_1
            local sV_1
            while true do
                task.wait(1)
                if mR.Unloaded then
                    break
                end
                Label3:SetText(mE("Session", s3(), mm))
                Label2:SetText(mE("Players", #mf:GetPlayers() .. "/" .. tostring(mf.MaxPlayers), mt))
                sV_1, sW_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local sV_2 = sV_1 and sW_1 .. " ms" or "n/a"
                Label:SetText(mE("Ping", sV_2, mm))
            end
        end)
        local SocialsGroup = no.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = m1 })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                nr(mI, "Copied Rscripts profile to clipboard")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                nr(mB, "Copied website link")
            end
        })
    end
end
nw_7()
local CratesGroup = no.Main:AddLeftGroupbox("Crates", "package")
CratesGroup:AddToggle("AutoBuyCrate", { Text = "Auto Buy Crate", Default = false })
CratesGroup:AddToggle("AutoBuyNextCrate", { Text = "Auto Buy Next Crate", Default = false })
CratesGroup:AddToggle("AutoOpenReadyCrate", { Text = "Auto Open Ready Crate", Default = false })
CratesGroup:AddDivider("Place")
CratesGroup:AddToggle("AutoPlaceCrate", { Text = "Auto Place Crate", Default = false })
CratesGroup:AddToggle("AutoPlaceDesk", { Text = "Auto Place Desk", Default = false })
CratesGroup:AddDropdown("PlaceMode", { Text = "Place Mode", Values = { "Random Spot", "Near Desk" }, Default = "Random Spot" })
CratesGroup:AddSlider("PlaceRotation", { Text = "Place Rotation", Default = 0, Min = 0, Max = 3, Rounding = 0 })
local StreamGroup = no.Main:AddRightGroupbox("Stream", "radio")
StreamGroup:AddToggle("AutoStream", { Text = "Auto Stream", Default = false })
StreamGroup:AddDropdown("StreamDesk", { Text = "Desk", Values = { "Best Placed Desk", "Random Desk" }, Default = "Best Placed Desk" })
StreamGroup:AddSlider("AutoFinishMinutes", { Text = "Auto Finish After Minutes", Default = 5, Min = 1, Max = 60, Rounding = 0 })
StreamGroup:AddToggle("AutoMysteryBox", { Text = "Auto Mystery Box", Default = false })
local ProgressGroup = no.Main:AddLeftGroupbox("Progress", "trending-up")
ProgressGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ProgressGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
ProgressGroup:AddToggle("AutoExpandPlot", { Text = "Auto Expand Plot", Default = false })
local function nu_5()
    local MovementGroup = no.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = no.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    m9.JumpRequest:Connect(function()
        if mR.Unloaded then
            return
        end
        if not mH("InfJump") then
            return
        end
        local s9 = mV()
        if s9 then
            s9:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    ng.Stepped:Connect(function()
        if mR.Unloaded then
            return
        end
        if mH("NoClip") then
            local Character = mq.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local tb_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if tb_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    ng.RenderStepped:Connect(function(hf)
        if mR.Unloaded then
            return
        end
        if mH("WalkSpeedEnabled") then
            local tm_1 = mV()
            if tm_1 then
                tm_1.WalkSpeed = mM("WalkSpeed", 32)
            end
        end
        if mH("Fly") then
            local tm_2 = nk()
            local tn = mV()
            local CurrentCamera = mw.CurrentCamera
            if tm_2 and tn and CurrentCamera then
                tn.PlatformStand = true
                local tn_1 = Vector3.zero
                local tu = if m9:IsKeyDown(Enum.KeyCode.W) then 1 else 0
                if tu == 1 then
                    tn_1 += CurrentCamera.CFrame.LookVector
                end
                if m9:IsKeyDown(Enum.KeyCode.S) then
                    tn_1 -= CurrentCamera.CFrame.LookVector
                end
                if m9:IsKeyDown(Enum.KeyCode.A) then
                    tn_1 -= CurrentCamera.CFrame.RightVector
                end
                local tu_1 = if m9:IsKeyDown(Enum.KeyCode.D) then 1 else 0
                if tu_1 == 1 then
                    tn_1 += CurrentCamera.CFrame.RightVector
                end
                if m9:IsKeyDown(Enum.KeyCode.Space) then
                    tn_1 += Vector3.yAxis
                end
                if m9:IsKeyDown(Enum.KeyCode.LeftControl) then
                    tn_1 -= Vector3.yAxis
                end
                if tn_1.Magnitude > 0 then
                    tm_2.CFrame = tm_2.CFrame + tn_1.Unit * mM("FlySpeed", 60) * hf
                end
                tm_2.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local tv = mV()
            if tv then
                tv.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local tA = mV()
            if tA then
                tA.WalkSpeed = 16
            end
        end
    end)
    local function hC(hD)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not hD)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = mL:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not hD
            end
        end)
        if not hD then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(mq, "GameplayPaused", false)
            else
                mq.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        hC(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not mR.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                hC(true)
            end
        end
    end)
    local function hU(hV)
        if not hV:IsA("ProximityPrompt") then
            return
        end
        hV.HoldDuration = 0
        hV.MaxActivationDistance = 50
        hV.RequiresLineOfSight = false
    end
    local connection
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in mw:GetDescendants() do
                pcall(hU, descendant)
            end
            connection = mw.DescendantAdded:Connect(function(h2)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(hU, h2)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    mR:OnUnload(function()
        hC(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
nu_5()
mv = no.Settings:AddLeftGroupbox("Menu")
mv:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
mR.ToggleKeybind = Options.MenuKeybind
local function nt_2()
    local connection
    local h9 = 0
    local ia = tick()
    mv:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = mv:AddLabel("AFK triggers: 0")
    local function id()
        local CurrentCamera = mw.CurrentCamera
        if not CurrentCamera then
            return
        end
        m4:CaptureController()
        m4:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        h9 += 1
        ia = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. h9)
        end)
    end
    connection = mq.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(id)
        end
    end)
    task.spawn(function()
        while not mR.Unloaded do
            task.wait(2)
            local tX = Toggles.AntiAfk.Value and tick() - ia >= 60
            if tX then
                pcall(id)
            end
        end
    end)
    mv:AddButton({
        Text = "Unload UI",
        Func = function()
            mR:Unload()
        end
    })
    mR:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
nt_2()
nA_1:SetLibrary(mR)
nA_1:SetFolder("TempoHub")
nA_1:SaveDefault("Evil Hello Kitty")
nm:SetLibrary(mR)
nm:IgnoreThemeSettings()
nm:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
nm:SetFolder("TempoHub/StreamACheesePull")
nh = nm:BuildConfigSection(no.Settings)
local function nC()
    local function iH(iI, iJ)
        local t0 = iI == "Toggle" and Toggles
        local t5 = if t0 then 1 else 0
        local t3 = 1317 * t5 + 2196 * (1 - t5)
        local t4 = 3124 * t5 + 776 * (1 - t5)
        if not ((t3 * 2651 + t4 * 304 + t3 * t4) % 16777213 == 8555371) then
            t0 = Options
        end
        local t0_1 = t0[iJ]
        local t__2 = type(t0_1) == "table" and t0_1.Type == iI
        return t__2 and t0_1 or nil
    end
    local function iR(iS, iT)
        local Type = iT.Type
        if Type == "Toggle" then
            return { idx = iS, type = "Toggle", value = iT.Value == true }
        elseif Type == "Slider" then
            return { idx = iS, type = "Slider", value = tostring(iT.Value) }
        elseif Type == "Dropdown" then
            return { idx = iS, type = "Dropdown", multi = iT.Multi == true, value = iT.Value }
        elseif Type == "Input" then
            local t7 = iT.Value or ""
            return { idx = iS, type = "Input", text = tostring(t7) }
        elseif Type == "ColorPicker" then
            return { idx = iS, type = "ColorPicker", value = iT.Value:ToHex(), transparency = iT.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = iS,
                type = "KeyPicker",
                mode = iT.Mode,
                key = iT.Value,
                modifiers = iT.Modifiers,
                toggled = iT.Toggled
            }
        else
            return nil
        end
    end
    local function iV()
        local ua = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local ub = type(v) == "table" and type(v.Type) == "string" and not nm.Ignore[k]
                if ub then
                    local ub_1 = iR(k, v)
                    if ub_1 then
                        ua[#ua + 1] = ub_1
                    end
                end
            end
        end
        table.sort(ua, function(i4, i5)
            if i4.type ~= i5.type then
                return i4.type < i5.type
            end
            return i4.idx < i5.idx
        end)
        return { objects = ua }
    end
    local function i6(i7)
        local uu
        uu = nil
        local uw = type(i7) ~= "table" or type(i7.idx) ~= "string" or type(i7.type) ~= "string"
        local uA = if uw then 1 else 0
        local uy = 784 * uA + 335 * (1 - uA)
        local uz = 3851 * uA + 253 * (1 - uA)
        if not ((uy * 3444 + uz * 3944 + uy * uz) % 16777213 == 4130411) then
            uw = nm.Ignore[i7.idx]
        end
        if uw then
            return false
        end
        uu = iH(i7.type, i7.idx)
        if not uu then
            return false
        end
        local uw_1 = pcall(function()
            if i7.type == "Input" then
                if type(i7.text) ~= "string" then
                    return
                end
                uu:SetValue(i7.text)
            elseif i7.type == "ColorPicker" then
                uu:SetValueRGB(Color3.fromHex(i7.value), i7.transparency)
            elseif i7.type == "KeyPicker" then
                uu:SetValue({ i7.key, i7.mode, i7.modifiers })
                if i7.mode == "Toggle" and i7.toggled ~= nil then
                    uu.Toggled = i7.toggled
                    uu:Update()
                end
            else
                uu:SetValue(i7.value)
            end
        end)
        return uw_1
    end
    nh:AddDivider()
    nh:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    nh:AddButton("Export Config to Clipboard", function()
        local uC_1
        local uB_1
        uB_1, uC_1 = pcall(HttpService.JSONEncode, HttpService, iV())
        if not uB_1 then
            mR:Notify("Failed to encode the config")
            return
        end
        local uB_2 = setclipboard or toclipboard
        local uB_3 = type(uB_2) ~= "function" or not pcall(uB_2, uC_1)
        if uB_3 then
            mR:Notify("Your executor does not support copying to the clipboard")
            return
        end
        mR:Notify("Config copied to clipboard", 6)
    end)
    nh:AddButton("Import Config from Clipboard Text", function()
        local uK_1
        local uI = Options.SaveManager_ImportSource.Value or ""
        local uI_1
        local uJ = tostring(uI):match("^%s*(.-)%s*$")
        if uJ == "" then
            mR:Notify("Paste an exported config into the box first")
            return
        end
        uI_1, uK_1 = pcall(HttpService.JSONDecode, HttpService, uJ)
        local uJ_1 = not uI_1 or type(uK_1) ~= "table"
        local uR = if uJ_1 then 1 else 0
        local uP = 132 * uR + 2536 * (1 - uR)
        local uQ = 1727 * uR + 649 * (1 - uR)
        if not ((uP * 1018 + uQ * 786 + uP * uQ) % 16777213 == 1719762) then
            uJ_1 = type(uK_1.objects) ~= "table"
        end
        if uJ_1 then
            mR:Notify("That is not a valid exported config")
            return
        end
        local uI_2 = 0
        for i, v in ipairs(uK_1.objects) do
            if i6(v) then
                uI_2 += 1
            end
        end
        if uI_2 == 0 then
            mR:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local uK_2 = uI_2 == 1 and "" or "s"
        mR:Notify(("Imported %d setting%s"):format(uI_2, uK_2), 6)
    end)
end
nC()
nA_1:ApplyToTab(no.Settings)
nA_1:LoadDefault()
nm:LoadAutoloadConfig()
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
task.spawn(worker10)
end)(...)
