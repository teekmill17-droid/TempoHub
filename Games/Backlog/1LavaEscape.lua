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
getgenv().TempoHoodSubtitle = "+1 LAVA ESCAPE"
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
local kC
local ki
local k0
local j_
local kI
local ko
local k6
local j5
local LocalPlayer
local kv
local lc
local RebirthFormula
local kB
local SaveManager
local k_
local jZ
local kH
local kn
local UserInputService
local j4
local kN
local RequestRebirth
local lb
local ka
local kT
local kA
local kg
local HttpService
local jY
local kG
local km
local k4
local j3
local kM
local ks
local la
local j9
local kS
local kz
local kf
local connection
local jX
local kl
local VirtualUser
local j2
local k9
local Options
local ScreamClicked
local ke
local kE
local kk
local k2
local j1
local kK
local kq
local k8
local j7
local Workspace
local kx
local Toggles
local kW
local kj
local k1
local connection2
local Library
local Label
local LevelFormula
local kP
local kw
local kc
local kV
function fns.fn6()
    connection:Disconnect()
    connection2:Disconnect()
    kj(false)
end
function fns.worker7()
    while not Library.Unloaded do
        if k1("AutoBuyBestScream") then
            pcall(kn)
        end
        task.wait(kw("ScreamBuyDelay", 1))
    end
end
function fns.onCopyVenmoLink()
    j3(j4, "Copied Venmo link")
end
function fns.fn69()
    kj(Toggles.AntiGameplayPause.Value)
end
function fns.fn80(aQ, aR)
    local mj = Options[aQ]
    local mk = mj and tonumber(mj.Value)
    if mk then
        return mk
    end
    return aR
end
function fns.onCopyJoinScript_JobID()
    local eE = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, k6)
    j3(eE, "Copied join script to clipboard")
end
local function fn92(bH)
    local mO_1
    local mP_1
    if type(bH) ~= "string" then
        return nil
    end
    mP_1, mO_1 = bH:match("([%d%.]+)%s*([KkMm]?)")
    local mP_2 = tonumber(mP_1)
    if not mP_2 then
        return nil
    end
    if mO_1 == "K" or mO_1 == "k" then
        mP_2 *= 1000
    else
        local mQ_1 = mO_1 == "m"
        local mR_1 = mO_1 == "M"
        local mV = if mR_1 then 1 else 0
        local mT = 3158 * mV + 3518 * (1 - mV)
        local mU = 534 * mV + 1063 * (1 - mV)
        if not ((mT * 2240 + mU * 2876 + mT * mU) % 16777213 == 10296076) then
            mR_1 = mQ_1
        end
        if mR_1 then
            mP_2 *= 1000000
        end
    end
    return mP_2
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local pf_1 = j5()
        if pf_1 then
            pf_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn117(I, J)
    if I.Multiplier == J.Multiplier then
        return I.RequiredRebirths < J.RequiredRebirths
    end
    return I.Multiplier < J.Multiplier
end
local function onExportConfigToClipboard()
    local qf_1
    local qe_1
    qe_1, qf_1 = pcall(HttpService.JSONEncode, HttpService, jZ())
    if not qe_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local qe_2 = setclipboard or toclipboard
    local qe_3 = type(qe_2) ~= "function" or not pcall(qe_2, qf_1)
    if qe_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn135(en)
    local DiscordGroup = en:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = k9 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = k9 })
end
local function fn149(cH)
    local nz = k0()
    local nA = nz and nz:FindFirstChild("TrainingZones")
    local nz_1 = nA
    if nA then
        nA = nz_1:FindFirstChild(cH)
    end
    local nz_2 = nA
    if not nz_2 then
        return nil
    end
    local Hitbox = nz_2:FindFirstChild("Hitbox")
    local nB = Hitbox and Hitbox:IsA("BasePart")
    if nB then
        return Hitbox
    end
    local Main = nz_2:FindFirstChild("Main")
    local nB_1 = Main and Main:IsA("BasePart")
    if nB_1 then
        return Main
    end
    return nz_2:FindFirstChildWhichIsA("BasePart", true)
end
local function fn150()
    local no = kG()
    local np = -1
    local nq
    for i, v in ipairs(k8) do
        if v.RequiredRebirths <= no and v.Multiplier >= np then
            nq = v
            np = v.Multiplier
        end
    end
    return nq
end
local function fn156()
    local nG = j_()
    if not nG then
        return
    end
    local nH = kS(nG.Name)
    if not nH then
        if Workspace.StreamingEnabled then
            local nI_1 = k0() and k0():FindFirstChild("Spawn")
            local nJ = nI_1
            if nI_1 then
                nI_1 = nJ:IsA("BasePart")
            end
            if nI_1 then
                kM(nJ.Position, 3)
            end
            nH = kS(nG.Name)
        end
        if not nH then
            return
        end
    end
    local nG_1 = la()
    if not nG_1 or (nG_1.Position - nH.Position).Magnitude > 6 then
        k2(nH.CFrame + Vector3.new(0, 3, 0))
    end
end
local function fn161(a4)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(a4)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = a4
        end
    end
end
local function fn162(c7)
    local Upgrades = LocalPlayer:FindFirstChild("Upgrades")
    local nM = Upgrades and Upgrades:FindFirstChild(tostring(c7)) ~= nil
    return nM
end
local function fn164()
    local Character = LocalPlayer.Character
    local mq = Character and Character:FindFirstChildOfClass("Humanoid")
    return mq
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local o4_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if o4_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        task.wait(1)
        if k1("AntiGameplayPause") then
            kj(true)
        end
    end
end
local function fn233(b8, b9)
    local m4 = os.clock()
    local m6 = m4 + (b9 or 5)
    local m4_1 = kV(b8)
    if m4_1 then
        return m4_1
    end
    local m5_1 = kv[b8]
    if m5_1 then
        local min = math.min
        local m8_1 = b9 or 5
        kM(m5_1, min(m8_1, 5))
    else
        local m5_2 = k0() and k0():FindFirstChild("Spawn")
        local m7_2 = m5_2
        if m5_2 then
            m5_2 = m7_2:IsA("BasePart")
        end
        if m5_2 then
            local m5_3 = m7_2.Position + Vector3.new(0, 0, 40 * b8)
            local min = math.min
            local m9 = b9
            local ng = if m9 then 1 else 0
            local ne = 3673 * ng + 2006 * (1 - ng)
            local nf = 1122 * ng + 916 * (1 - ng)
            if not ((ne * 2915 + nf * 3916 + ne * nf) % 16777213 == 2444440) then
                m9 = 5
            end
            kM(m5_3, min(m9, 5))
        end
    end
    while true do
        local m5_4 = os.clock() < m6 and not Library.Unloaded
        if m5_4 then
            local m4_2 = kV(b8)
            if m4_2 then
                return m4_2
            end
            task.wait(0.1)
            continue
        end
        break
    end
    return kV(b8)
end
local function worker()
    local oP_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local oO = math.floor(os.clock() - kP)
        if oO < 60 then
            oP_1 = oO .. "s"
        elseif oO < 3600 then
            oP_1 = string.format("%dm %ds", math.floor((oO) / (60)), oO % 60)
        else
            oP_1 = string.format("%dh %dm", math.floor((oO) / (3600)), math.floor((oO % 3600) / (60)))
        end
        Label:SetText(kW("Session time", oP_1, kA))
    end
end
local function onInputBegan()
    kk = tick()
end
local function onUnload()
    Library:Unload()
end
local function onCopyUSDTAddress()
    j3(ki, "Copied USDT address")
end
local function fn313()
    pcall(function()
        ScreamClicked:FireServer()
    end)
end
local function fn322()
    local oK_1
    local oJ_1
    if identifyexecutor then
        oK_1, oJ_1 = identifyexecutor()
        local oL = oK_1 ~= ""
        local oM = type(oK_1) == "string" and oL
        if oM then
            local oL_1 = type(oJ_1) == "string" and oJ_1 ~= "" and oK_1 .. " " .. oJ_1
            kc = oL_1 or oK_1
        end
    end
end
local function fn323(bV)
    local mZ = k0()
    local m_ = mZ and mZ:FindFirstChild("Stages")
    local mZ_1 = m_
    if m_ then
        m_ = mZ_1:FindFirstChild("Stage" .. bV)
    end
    local mZ_2 = m_
    if m_ then
        m_ = mZ_2:FindFirstChild("Wins")
    end
    local mZ_3 = m_
    if m_ then
        m_ = mZ_3:FindFirstChild("Main")
    end
    local mZ_4 = m_
    if m_ then
        m_ = mZ_4:IsA("BasePart")
    end
    if m_ then
        kv[bV] = mZ_4.Position
        return mZ_4
    end
    return nil
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if k1("AntiAfk") then
            local qs = tick() - kk
            local qt = tick() - kg
            if qs >= 300 and qt >= 60 then
                pcall(jY)
            else
                if qs < 300 and qt >= 300 then
                    pcall(jY)
                end
            end
        end
    end
end
local function onCopyLitecoinAddress()
    j3(ks, "Copied Litecoin address")
end
local function onCopyEthereumAddress()
    j3(km, "Copied Ethereum address")
end
local function fn362(gt, gu)
    local Type = gu.Type
    if Type == "Toggle" then
        return { idx = gt, type = "Toggle", value = gu.Value == true }
    elseif Type == "Slider" then
        return { idx = gt, type = "Slider", value = tostring(gu.Value) }
    elseif Type == "Dropdown" then
        return { idx = gt, type = "Dropdown", multi = gu.Multi == true, value = gu.Value }
    elseif Type == "Input" then
        local pM = gu.Value or ""
        return { idx = gt, type = "Input", text = tostring(pM) }
    elseif Type == "ColorPicker" then
        return { idx = gt, type = "ColorPicker", value = gu.Value:ToHex(), transparency = gu.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = gt,
            type = "KeyPicker",
            mode = gu.Mode,
            key = gu.Value,
            modifiers = gu.Modifiers,
            toggled = gu.Toggled
        }
    else
        return nil
    end
end
local function fn370(aG)
    local ma = Toggles[aG]
    return ma ~= nil and ma.Value == true
end
local function fn379(aL)
    local md = Options[aL]
    local md_1 = md and md.Value
    local mi = if md_1 then 1 else 0
    local mg = 720 * mi + 922 * (1 - mi)
    local mh = 1555 * mi + 2909 * (1 - mi)
    if not ((mg * 1345 + mh * 3065 + mg * mh) % 16777213 == 6854075) then
        md_1 = nil
    end
    return md_1
end
local function fn386(Z, aa)
    if setclipboard then
        setclipboard(Z)
    elseif toclipboard then
        toclipboard(Z)
    end
    Library:Notify(aa)
end
local function fn394()
    return lc("Wins")
end
local function fn415(aj, ak, al)
    return string.format("<b>%s</b> %s %s", aj, k4("-", "#5a6070"), k4(ak, al))
end
local function fn452()
    return lc("Rebirths")
end
local function fn453()
    local oE = RebirthFormula.RequiredLevel(kG())
    local oI = if kB() >= oE then 1 else 0
    if oI == 1 then
        pcall(function()
            RequestRebirth:FireServer()
        end)
    end
end
local function onCopyBitcoinAddress()
    j3(kq, "Copied Bitcoin address")
end
local function onInputChanged(ge)
    local UserInputType = ge.UserInputType
    local pC = UserInputType == Enum.UserInputType.MouseMovement
    local pG = if pC then 1 else 0
    local pE = 1342 * pG + 2910 * (1 - pG)
    local pF = 1761 * pG + 867 * (1 - pG)
    if not ((pE * 3650 + pF * 2845 + pE * pF) % 16777213 == 12271607) then
        pC = UserInputType == Enum.UserInputType.Gamepad1
    end
    if pC then
        kk = tick()
    end
end
local function fn500(gl, gm)
    local pI_1 = (gl == "Toggle" and Toggles or Options)[gm]
    local pH_2 = type(pI_1) == "table" and pI_1.Type == gl
    return pH_2 and pI_1 or nil
end
local function fn502()
    if not Toggles.WalkSpeedEnabled.Value then
        local o2 = j5()
        if o2 then
            o2.WalkSpeed = 16
        end
    end
end
local function fn545()
    local pP = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local pQ = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if pQ then
                local pQ_1 = ka(k, v)
                if pQ_1 then
                    pP[#pP + 1] = pQ_1
                end
            end
        end
    end
    table.sort(pP, function(gH, gI)
        if gH.type ~= gI.type then
            return gH.type < gI.type
        end
        return gH.idx < gI.idx
    end)
    return { objects = pP }
end
local function onRscripts()
    j3(kE, "Copied Rscripts profile to clipboard")
end
local function onCopyPayPalLink()
    j3(j9, "Copied PayPal link")
end
local function worker9()
    while not Library.Unloaded do
        if k1("AutoRebirth") then
            pcall(k_)
        end
        task.wait(kw("RebirthDelay", 1))
    end
end
local function fn578(O, P)
    if O.Boost == P.Boost then
        return O.Cost < P.Cost
    end
    return O.Boost < P.Boost
end
local function fn610()
    if not Toggles.Fly.Value then
        local oY = j5()
        if oY then
            oY.PlatformStand = false
        end
    end
end
local function onRenderStepped(fL)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local pk_1 = j5()
        if pk_1 then
            pk_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local pk_3 = la()
        local pl = j5()
        lb = Workspace.CurrentCamera or lb
        if pk_3 and pl and lb then
            pl.PlatformStand = true
            local pl_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                pl_1 = pl_1 + lb.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                pl_1 = pl_1 - lb.CFrame.LookVector
            end
            local pr = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
            if pr == 1 then
                pl_1 = pl_1 - lb.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                pl_1 = pl_1 + lb.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                pl_1 = pl_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                pl_1 = pl_1 - Vector3.new(0, 1, 0)
            end
            pk_3.Velocity = Vector3.zero
            if pl_1.Magnitude > 0 then
                pk_3.CFrame = pk_3.CFrame + pl_1.Unit * Options.FlySpeed.Value * fL
            end
        end
    end
end
local function fn653()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    kg = tick()
end
local function fn655()
    return Workspace:FindFirstChild("Game")
end
local function worker8()
    while not Library.Unloaded do
        if k1("AutoBuyAuras") then
            pcall(ko)
        end
        task.wait(kw("AuraDelay", 1))
    end
end
local function onCopySolanaAddress()
    j3(ke, "Copied Solana address")
end
local function fn673()
    local mW = kK("WinPlate")
    if type(mW) == "string" then
        local mX = tonumber(mW:match("%d+"))
        if mX then
            return math.clamp(mX, 1, j1)
        end
        return 1
    end
    return 1
end
local function fn679(ag, ah)
    return string.format('<font color="%s">%s</font>', ah, ag)
end
local function fn682()
    local nh = jX()
    local ni = j7(nh, 5)
    if not ni then
        return
    end
    local nh_1 = kT()
    k2(ni.CFrame + Vector3.new(0, 3, 0))
    local ni_1 = os.clock() + math.max(kw("WinDelay", 0.35), 0.2)
    while true do
        if os.clock() < ni_1 then
            local nj = Library.Unloaded or not k1("AutoWin")
            if nj then
                break
            end
            local nn = if kT() > nh_1 then 1 else 0
            if nn == 1 then
                return
            end
            task.wait(0.05)
            continue
        end
        return
    end
    return
end
local function fn712(bp)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local mI = leaderstats and leaderstats:FindFirstChild(bp)
    local mH_1 = mI
    if mI then
        local mJ = tonumber(mH_1.Value) or 0
        mI = mJ
    end
    return mI or 0
end
local function fn742()
    local Character = LocalPlayer.Character
    local mt = Character and Character:FindFirstChild("HumanoidRootPart")
    return mt
end
local function worker4()
    while not Library.Unloaded do
        if k1("AutoWin") then
            pcall(kI)
        else
            task.wait(0.25)
        end
    end
end
local function fn782(dc)
    local nR = k0()
    local nS = nR and nR:FindFirstChild("UpgradeShop")
    local nR_1 = nS
    if nS then
        nS = nR_1:FindFirstChild("Purchase")
    end
    local nR_2 = nS
    if nS then
        nS = nR_2:FindFirstChild(tostring(dc))
    end
    return nS
end
local function worker5()
    while not Library.Unloaded do
        if k1("AutoClick") then
            j2()
        end
        task.wait(kw("ClickDelay", 0.17))
    end
end
local function fn794()
    j3(kH, "Copied Discord invite to clipboard")
end
local function fn797()
    return lc("Screams")
end
local function fn810(dX)
    local Auras = LocalPlayer:FindFirstChild("Auras")
    local oq = Auras and Auras:FindFirstChild(dX) ~= nil
    return oq
end
local function fn831(dl)
    local nX = kz[dl]
    local nZ = nX and nX.Wins or math.huge
    local nY_1 = nX
    local n_ = nZ
    if nY_1 then
        nY_1 = nX.Mult
    end
    local nY_2 = nY_1 or 0
    local nX_2 = kx(dl)
    if nX_2 then
        local ShopGui = nX_2:FindFirstChild("ShopGui", true)
        local n0 = ShopGui and ShopGui:FindFirstChild("Wins_Label", true)
        local n1 = ShopGui
        if n1 then
            n1 = ShopGui:FindFirstChild("Multiplier_Label", true)
        end
        local nZ_2 = n1
        if n0 then
            local n0_1 = kl(n0.Text)
            if n0_1 then
                n_ = n0_1
            end
        end
        if nZ_2 then
            local n0_2 = nZ_2.Text or ""
            local nZ_3 = kl(n0_2:gsub("^%+", ""):gsub("/Scream", ""))
            if nZ_3 then
                nY_2 = nZ_3
            end
        end
    end
    return n_, nY_2, nX_2
end
local function worker6()
    while not Library.Unloaded do
        if k1("AutoTrain") then
            pcall(kf)
        end
        task.wait(kw("TrainDelay", 0.25))
    end
end
local function onImportConfigFromClipboardTex()
    local qk_1
    local qi = Options.SaveManager_ImportSource.Value or ""
    local qi_1
    local qj = tostring(qi):match("^%s*(.-)%s*$")
    if qj == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    qi_1, qk_1 = pcall(HttpService.JSONDecode, HttpService, qj)
    local qj_1 = not qi_1 or type(qk_1) ~= "table" or type(qk_1.objects) ~= "table"
    if qj_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local qi_2 = 0
    for i, v in ipairs(qk_1.objects) do
        if kC(v) then
            qi_2 += 1
        end
    end
    if qi_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local qk_2 = qi_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(qi_2, qk_2), 6)
end
local function fn883()
    local mL = LevelFormula.GetLevelInfo(kN())
    local mM = mL and tonumber(mL.Level)
    return mM or 0
end
jX = nil
jY = nil
jZ = nil
j_ = nil
j1 = nil
j2 = nil
j3 = nil
j4 = nil
j5 = nil
LevelFormula = nil
j7 = nil
Options = nil
j9 = nil
ka = nil
RebirthFormula = nil
kc = nil
Toggles = nil
ke = nil
kf = nil
kg = nil
SaveManager = nil
ki = nil
kj = nil
kk = nil
kl = nil
km = nil
kn = nil
ko = nil
Library = nil
kq = nil
ks = nil
RequestRebirth = nil
kv = nil
kw = nil
kx = nil
ScreamClicked = nil
kz = nil
kA = nil
kB = nil
kC = nil
kE = nil
kG = nil
kH = nil
kI = nil
connection2 = nil
kK = nil
local j0, RequestAura, kD, kF
kM = nil
kN = nil
LocalPlayer = nil
kP = nil
Workspace = nil
kS = nil
kT = nil
kV = nil
kW = nil
connection = nil
HttpService = nil
k_ = nil
k0 = nil
k1 = nil
k2 = nil
VirtualUser = nil
k4 = nil
UserInputService = nil
k6 = nil
Label = nil
k8 = nil
k9 = nil
la = nil
lb = nil
lc = nil
local kL, kR, CoreGui, GuiService, lt
kL = nil
kR = nil
CoreGui = nil
GuiService = nil
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, kH, kE, ScreamClicked, RequestRebirth, RequestAura, RebirthFormula, LevelFormula = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local qJ_10 = game:GetService("Players")
local lh = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = qJ_10.LocalPlayer
local ll = "+1 Scream Per Click"
kH = "https://discord.gg/K7Qxnxkk46"
kE = "https://discord.gg/K7Qxnxkk46"
local qJ_3 = lh:WaitForChild("Remotes")
ScreamClicked = qJ_3:WaitForChild("ScreamClicked")
RequestRebirth = qJ_3:WaitForChild("RequestRebirth")
RequestAura = qJ_3:WaitForChild("RequestAura")
local qJ_4 = lh:WaitForChild("Modules")
local lj = require(qJ_4:WaitForChild("TrainingZoneConfig"))
local lk = require(qJ_4:WaitForChild("AuraConfig"))
RebirthFormula = require(qJ_4:WaitForChild("RebirthFormula"))
LevelFormula = require(qJ_4:WaitForChild("LevelFormula"))
local li = require(qJ_4:WaitForChild("StageWallFormula"))
qJ_10 = tonumber(li.MAX_STAGE) or 12
local qJ_9 = {}
j1 = qJ_10
local lJ = 1
local lH = j1
while lJ <= lH do
    local lK = lJ
    qJ_9[lK] = "Stage " .. lK
    lJ += 1
end
k8, qJ_4 = nil, nil
qJ_10 = 7
repeat
    qJ_3 = (qJ_10 * 1 + 1) % 2 + 1
    if qJ_3 <= 1 then
        if (not k8 and qJ_10 or not qJ_10 and not k8) and (not qJ_4 and qJ_10 or not qJ_4 and not k8) and not ((not k8 and qJ_10 or not qJ_10 and not k8) and (not qJ_4 and qJ_10 or not qJ_4 and not k8)) then
            qJ_4 = {}
        else
            k8 = {}
        end
        qJ_10 = (qJ_10 + 1) % 8
    else
        if (qJ_10 * 2 + 8) * 10 % 3 == ((qJ_10 * 2 + 8) * 10 + 8) % 3 then
            lj = qJ_4.Build()
        else
            qJ_4 = lj.Build()
        end
        qJ_10 = (qJ_10 + 5) % 8
    end
until (qJ_10 * 3 + 7) % 8 == 6
for k, v in pairs(qJ_4) do
    qJ_10 = type(v) == "table" and v.robuxOnly ~= true
    if qJ_10 then
        qJ_10 = #k8 + 1
        qJ_4 = tonumber(v.requiredRebirths) or 0
        qJ_3 = (tonumber(v.multiplier))
        local lU = if qJ_3 then 1 else 0
        local lS = 2709 * lU + 3606 * (1 - lU)
        local lT = 3307 * lU + 1307 * (1 - lU)
        if not ((lS * 3787 + lT * 2260 + lS * lT) % 16777213 == 9914253) then
            qJ_3 = 0
        end
        k8[qJ_10] = { Name = k, RequiredRebirths = qJ_4, Multiplier = qJ_3 }
    end
end
kR, li = nil, nil
lh = 2
repeat
    qJ_10 = (lh * 1 + 1) % 2 + 1
    if qJ_10 <= 1 then
        if (lh * 2 + 6) * 10 % 3 == ((lh * 2 + 6) * 10 + 0) % 3 then
            li = lk.Build()
        else
            lk = li.Build()
        end
        lh = (lh + 5) % 16
    else
        if (lh * 3 + 9) * 21 % 4 == ((lh * 3 + 9) * 21 + 4) % 4 then
            table.sort(k8, fn117)
            kR = {}
        else
            table.sort(kR, fn117)
            k8 = {}
        end
        lh = (lh + 5) % 16
    end
until (lh * 7 + 13) % 16 == 1
for k, v in pairs(li) do
    if type(v) == "table" then
        qJ_10 = #kR + 1
        qJ_4 = v.key or k
        qJ_3 = tostring(qJ_4)
        lh = tonumber(v.cost) or 0
        li = tonumber(v.boost) or 0
        kR[qJ_10] = { Key = qJ_3, Cost = lh, Boost = li }
    end
end
kz, kv, Library, SaveManager, Toggles, Options, lt, kA, ks, kq, km, ki, ke, j9, j4, j3, k9, k4, kW, k1, kK, kw, j5, la, k2, kM, lc, kT, kN, kG, kB, kl, j2, jX, k0, kV, j7, kI, j_, kS, kf, kL, kx, j0, kn, kD, ko, k_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(kR, fn578)
kz = {
    [1] = { Wins = 3, Mult = 2 },
    [2] = { Wins = 10, Mult = 5 },
    [3] = { Wins = 50, Mult = 25 },
    [4] = { Wins = 250, Mult = 50 },
    [5] = { Wins = 1000, Mult = 100 },
    [6] = { Wins = 2500, Mult = 250 },
    [7] = { Wins = 5000, Mult = 500 },
    [8] = { Wins = 10000, Mult = 750 },
    [9] = { Wins = 25000, Mult = 1000 },
    [10] = { Wins = 100000, Mult = 2500 },
    [11] = { Wins = 250000, Mult = 5000 },
    [12] = { Wins = 500000, Mult = 10000 }
}
kv = {}
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
j3 = fn386
k9 = fn794
k4 = fn679
kW = fn415
if "#6ec1ff" and ((false or kz) and (not kz and ki)) and not ("#6ec1ff" and ((false or kz) and (not kz and ki))) then
    kv = "#7fd47f"
else
    lt = "#7fd47f"
end
local ls = "#6ec1ff"
kA = "#e8a34d"
local lr = "#8b93a3"
ks = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
kq = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
km = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ki = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ke = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
j9 = ""
j4 = ""
local lq = "#345d9d"
local lp = "#f7931a"
local lo = "#627eea"
local lx = "#26a17b"
local lw = "#14f195"
local lv = "#0070ba"
local lu = "#008cff"
k1 = fn370
kK = fn379
kw = fns.fn80
j5 = fn164
la = fn742
k2 = fn161
kM = function(a9, ba)
    local mD
    if typeof(a9) ~= "Vector3" then
        return
    end
    if not Workspace.StreamingEnabled then
        return
    end
    mD = false
    task.spawn(function()
        pcall(function()
            local my = ba
            local mC = if my then 1 else 0
            local mA = 4077 * mC + 912 * (1 - mC)
            local mB = 979 * mC + 2905 * (1 - mC)
            if not ((mA * 2788 + mB * 3544 + mA * mB) % 16777213 == 2050422) then
                my = 5
            end
            LocalPlayer:RequestStreamAroundAsync(a9, my)
        end)
        mD = true
    end)
    local mE = os.clock()
    local mE_1 = mE + (ba or 5) + 0.25
    while true do
        local mF_1 = not mD and os.clock() < mE_1 and not Library.Unloaded
        if mF_1 then
            task.wait()
            continue
        end
        break
    end
end
lc = fn712
kT = fn394
kN = fn797
kG = fn452
kB = fn883
kl = fn92
j2 = fn313
jX = fn673
k0 = fn655
kV = fn323
j7 = fn233
kI = fn682
j_ = fn150
kS = fn149
kf = fn156
kL = fn162
kx = fn782
j0 = fn831
kn = function()
    local oe_1
    local od_1
    local oc_1
    local n8 = kT()
    local n9
    local ob = -1
    local oj = 1
    while oj <= 12 do
        local ok = oj
        if not kL(ok) then
            oc_1, od_1, oe_1 = j0(ok)
            if oe_1 and oc_1 <= n8 and od_1 > ob then
                ob = od_1
                n9 = oe_1
            end
        end
        oj += 1
    end
    if not n9 then
        return
    end
    local n8_1 = n9:FindFirstChild("Interaction") or n9:FindFirstChild("Main")
    local oa = n8_1
    if n8_1 then
        n8_1 = oa:IsA("BasePart")
    end
    if n8_1 then
        k2(oa.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.15)
    end
    local ProximityPrompt = n9:FindFirstChildWhichIsA("ProximityPrompt", true)
    if ProximityPrompt and fireproximityprompt then
        pcall(function()
            fireproximityprompt(ProximityPrompt)
        end)
    end
end
kD = fn810
ko = function()
    local ou
    local ov = kT()
    ou = nil
    for i, v in ipairs(kR) do
        local ow = not kD(v.Key) and v.Cost <= ov
        if ow then
            if not ou or v.Boost > ou.Boost then
                ou = v
            end
        end
    end
    if not ou then
        return
    end
    pcall(function()
        RequestAura:FireServer(ou.Key)
    end)
end
k_ = fn453
lk = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kH, Copyable = true }, "|", ll },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local lz = {
    Info = lk:AddTab("Info", "info"),
    Main = lk:AddTab("Main", "mouse-pointer-click"),
    Shop = lk:AddTab("Shop", "shopping-bag"),
    Player = lk:AddTab("Player", "person-standing"),
    Settings = lk:AddTab("Settings", "settings")
}
local ln = fn135
for k, v in lz do
    ln(v)
end
kc, Label, k6 = nil, nil, nil
kc = "Unknown"
pcall(fn322)
qJ_10 = lz.Info:AddLeftGroupbox("Account", "circle-user")
qJ_10:AddLabel(kW("User", LocalPlayer.Name, lt), true)
qJ_10:AddLabel(kW("Status", "Keyless", lt), true)
qJ_10:AddLabel(kW("Executor", kc, lt), true)
lh = lz.Info:AddLeftGroupbox("Game Info", "gamepad-2")
lh:AddLabel(k4(ll .. " [" .. tostring(game.PlaceId) .. "]", ls), true)
lh:AddLabel(kW("Place ID", tostring(game.PlaceId), ls), true)
Label = lh:AddLabel(kW("Session time", "0s", kA), true)
k6 = tostring(game.JobId)
qJ_3 = #k6 > 18
if qJ_3 then
    qJ_10 = 3
    repeat
        local rD = bit32.rrotate(bit32.bxor(bit32.lrotate(qJ_10, 12), string.byte(tostring(qJ_10))), 9)
        if bit32.bxor(bit32.lrotate(bit32.bxor(rD, 929507538), 0), 929507538) == bit32.lrotate(rD, 0) then
            qJ_3 = string.sub(k6, 1, 18) .. "..."
        else
            k6 = string.sub(qJ_3, 1, 18) .. "..."
        end
        qJ_10 = (qJ_10 + 0) % 8
    until (qJ_10 * 5 + 3) % 8 == 2
end
qJ_10 = qJ_3 or k6
kP = nil
local lB = qJ_10
lh:AddLabel(kW("Server", lB, lr), true)
lh:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
kP = os.clock()
task.spawn(worker)
ln = lz.Info:AddRightGroupbox("Scripts", "package")
ln:AddLabel(k4("Included in this hub", lr), true)
ln:AddLabel(k4(ll, ls), true)
lk = lz.Info:AddRightGroupbox("Features", "list")
lk:AddLabel(k4("Auto Farm", ls), true)
lk:AddLabel(k4("Auto Shop", lt), true)
lk:AddLabel(k4("Auto Progress", kA), true)
lk:AddLabel(k4("Misc Utilities", lr), true)
lj = lz.Info:AddRightGroupbox("Socials", "link")
lj:AddButton({ Text = "Discord", Func = k9 })
lj:AddButton({ Text = "Rscripts", Func = onRscripts })
li = lz.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
li:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
li:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
li:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
li:AddButton({ Text = "Copy Discord Invite", Func = k9 })
qJ_3 = lz.Info:AddRightGroupbox("Donations", "heart")
qJ_3:AddLabel(k4("All donations are optional but appreciated.", kA), true)
qJ_3:AddLabel(k4("If you donate you get a special role, just PING after you donate.", lt), true)
qJ_3:AddDivider()
qJ_3:AddLabel(k4("LTC / Litecoin", lq), true)
qJ_3:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
qJ_3:AddLabel(k4("BTC / Bitcoin", lp), true)
qJ_3:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
qJ_3:AddLabel(k4("ETH / Ethereum", lo), true)
qJ_3:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
qJ_3:AddLabel(k4("USDT", lx), true)
qJ_3:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
qJ_3:AddLabel(k4("Solana", lw), true)
qJ_3:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
qJ_3:AddLabel(k4("PayPal", lv), true)
qJ_3:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
qJ_3:AddLabel(k4("Venmo", lu), true)
qJ_3:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
qJ_3:AddDivider()
qJ_3:AddLabel(k4("Don't have any of the listed currencies but still wanna donate?", lr), true)
qJ_3:AddLabel(k4("DM me and we'll work something out.", ls), true)
local FaqGroup = lz.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = lz.Main:AddLeftGroupbox("Farm", "mouse-pointer-click")
FarmGroup:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
qJ_10 = qJ_9[1] or "Stage 1"
lb, kk, kg, connection, connection2, kj, jY, kF, ka, jZ, kC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
FarmGroup:AddDropdown("WinPlate", { Text = "Win stage", Values = qJ_9, Default = qJ_10 })
FarmGroup:AddSlider("WinDelay", { Text = "Win delay", Default = 0.35, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
FarmGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
FarmGroup:AddSlider("ClickDelay", { Text = "Click delay", Default = 0.17, Min = 0.17, Max = 1, Rounding = 2, Suffix = "s" })
FarmGroup:AddToggle("AutoTrain", { Text = "Auto Train based on Rebirth Amount", Default = false })
FarmGroup:AddSlider("TrainDelay", { Text = "Train delay", Default = 0.25, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
lj = lz.Main:AddRightGroupbox("Progress", "rotate-ccw")
lj:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
lj:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 1, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
li = lz.Shop:AddLeftGroupbox("Shop", "shopping-bag")
li:AddToggle("AutoBuyBestScream", { Text = "Auto Buy Best Scream", Default = false })
li:AddSlider("ScreamBuyDelay", { Text = "Scream buy delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2, Suffix = "s" })
li:AddToggle("AutoBuyAuras", { Text = "Auto Buy Auras", Default = false })
li:AddSlider("AuraDelay", { Text = "Aura delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2, Suffix = "s" })
qJ_3 = lz.Player:AddLeftGroupbox("Movement", "footprints")
qJ_3:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
qJ_3:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
qJ_3:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
qJ_3:AddToggle("NoClip", { Text = "NoClip", Default = false })
qJ_3:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
qJ_4 = lz.Player:AddRightGroupbox("Fly", "feather")
qJ_4:AddToggle("Fly", { Text = "Fly", Default = false })
qJ_4:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
kj = function(ff)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not ff)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not ff
        end
    end)
    if not ff then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "GameplayPaused", false)
        else
            LocalPlayer.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fns.fn69)
Toggles.Fly:OnChanged(fn610)
Toggles.WalkSpeedEnabled:OnChanged(fn502)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
lb = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
lh = lz.Settings:AddLeftGroupbox("Menu")
lh:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
lh:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lh:AddButton("Unload", onUnload)
kk = tick()
kg = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local py = v
        pcall(function()
            py:Disable()
        end)
    end
end)
jY = fn653
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(lz.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/plus1-scream-per-click")
ll = SaveManager:BuildConfigSection(lz.Settings)
if kk and qJ_4 or qJ_4 and not connection or (lb or qJ_4) and (not qJ_4 and not connection) or (connection or lb) and (connection or qJ_4) and (not ka and not ka and (not connection or not kk)) or not (kk and qJ_4 or qJ_4 and not connection or (lb or qJ_4) and (not qJ_4 and not connection) or (connection or lb) and (connection or qJ_4) and (not ka and not ka and (not connection or not kk))) then
    kF = fn500
    ka = fn362
    jZ = fn545
    kC = function(gK)
        local qb
        qb = nil
        local qc = type(gK) ~= "table" or type(gK.idx) ~= "string" or type(gK.type) ~= "string" or SaveManager.Ignore[gK.idx]
        if qc then
            return false
        end
        qb = kF(gK.type, gK.idx)
        if not qb then
            return false
        end
        local qc_2 = pcall(function()
            if gK.type == "Input" then
                if type(gK.text) ~= "string" then
                    return
                end
                qb:SetValue(gK.text)
            elseif gK.type == "ColorPicker" then
                qb:SetValueRGB(Color3.fromHex(gK.value), gK.transparency)
            elseif gK.type == "KeyPicker" then
                qb:SetValue({ gK.key, gK.mode, gK.modifiers })
                if gK.mode == "Toggle" and gK.toggled ~= nil then
                    qb.Toggled = gK.toggled
                    qb:Update()
                end
            else
                qb:SetValue(gK.value)
            end
        end)
        return qc_2
    end
else
    kC = fn500
    kF = fn362
    ka = fn545
    jZ = function(gK)
        local qb
        qb = nil
        local qc = type(gK) ~= "table" or type(gK.idx) ~= "string" or type(gK.type) ~= "string" or SaveManager.Ignore[gK.idx]
        if qc then
            return false
        end
        qb = kF(gK.type, gK.idx)
        if not qb then
            return false
        end
        local qc_1 = pcall(function()
            if gK.type == "Input" then
                if type(gK.text) ~= "string" then
                    return
                end
                qb:SetValue(gK.text)
            elseif gK.type == "ColorPicker" then
                qb:SetValueRGB(Color3.fromHex(gK.value), gK.transparency)
            elseif gK.type == "KeyPicker" then
                qb:SetValue({ gK.key, gK.mode, gK.modifiers })
                if gK.mode == "Toggle" and gK.toggled ~= nil then
                    qb.Toggled = gK.toggled
                    qb:Update()
                end
            else
                qb:SetValue(gK.value)
            end
        end)
        return qc_1
    end
end
ll:AddDivider()
ll:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
ll:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
ll:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(fns.worker7)
task.spawn(worker8)
task.spawn(worker9)
Library:OnUnload(fns.fn6)
Library:Notify("+1 Scream Per Click loaded")
end)(...)
