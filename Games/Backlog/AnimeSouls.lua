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
getgenv().TempoHoodSubtitle = "ANIME SOULS"
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
local h4
local bodyVelocity
local hM
local hS
local ie
local hY
local h0
local hI
local h6
local h9
local hO
local ic
local LocalPlayer
local hU
local hX
local Library
local h_
local hH
local VirtualUser
local h5
local hN
local hQ
local hT
local EnemySelectDropdown
local hW
local ij
local h1
local hG
local function fn5(at, au)
    return at.id < au.id
end
local function fn12(ba)
    h4[#h4 + 1] = ba
    return ba
end
local function fn24()
    local jt_1
    local js_1
    if not h_ then
        return nil
    end
    js_1, jt_1 = pcall(h_.GetGamePlayer)
    if js_1 then
        return jt_1
    end
    return nil
end
local function onAutoFarm(dn)
    h6.autoFarm = dn
end
local function worker3()
    while task.wait(0.5) do
        if Library.Unloaded then
            break
        end
        if h6.autoRebirth and hG then
            local mb_1 = hM()
            if mb_1 then
                if h6.autoSkipRebirth and hG.ClientSkipRebirth then
                    pcall(hG.ClientSkipRebirth)
                end
                local mc_1 = hG._CheckDoRebirth and hG._CheckDoRebirth(mb_1)
                if mc_1 then
                    pcall(hG.ClientDoRebirth)
                end
            end
        end
        if h6.autoRankUp and ie and ie.ClientCraftAll then
            pcall(ie.ClientCraftAll)
        end
        if h6.autoEquipWeapon and ie and ie.ClientEquipBest then
            pcall(ie.ClientEquipBest)
        end
        if h6.autoEquipPet and h9 and h9.ClientEquipBest then
            pcall(h9.ClientEquipBest)
        end
    end
end
local function onAutoHatch(dG)
    h6.autoHatch = dG
end
local function onHitsPerTarget(dk)
    h6.hitsPerTarget = dk
end
local function onFlySpeed(eb)
    h6.flySpeed = eb
end
local function fn173()
    local jv = ij()
    local jw = jv and jv:FindFirstChildOfClass("Humanoid")
    return jw
end
local function worker()
    while task.wait(0.1) do
        if Library.Unloaded then
            break
        end
        if h6.autoAttack then
            pcall(hO)
        end
    end
end
local function onInfJump(ef)
    h6.infJumpOn = ef
end
local function onFlyOn(d9)
    h6.flyOn = d9
end
local function fn265()
    local j8_1
    local j7_1
    j8_1, j7_1 = {}, false
    for k, v in pairs(h6.selectedEnemies) do
        if v then
            j7_1 = true
            for k2, v in pairs(h5) do
                for i, v in ipairs(v) do
                    if v.name == k then
                        j8_1[v.tmpl] = true
                    end
                end
            end
        end
    end
    if not j7_1 then
        return nil
    end
    return j8_1
end
local function fn270()
    local jL = {}
    for i, v in ipairs(hT) do
        jL[#jL + 1] = v.name
    end
    return jL
end
local function onTeleportFarm(dq)
    h6.teleportFarm = dq
end
local function onUnload()
    Library:Unload()
end
local function onAntiAfk(d1)
    h6.antiAfk = d1
end
local function onJumpRequest()
    if h6.infJumpOn then
        local mf = ic()
        if mf then
            mf:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onAutoSkipRebirth(dT)
    h6.autoSkipRebirth = dT
end
local function fn357(ag)
    local jE = hH[ag]
    local jF = jE
    if jF then
        local jG = jE.Name
        local jK = if jG then 1 else 0
        local jI = 3555 * jK + 2901 * (1 - jK)
        local jJ = 674 * jK + 2218 * (1 - jK)
        if not ((jI * 2437 + jJ * 937 + jI * jJ) % 16777213 == 11691143) then
            jG = jE.NameKey
        end
        jF = jG
    end
    local jE_1 = jF or tostring(ag)
    return jE_1
end
local function onAutoCollect(ds)
    h6.autoCollect = ds
end
local function onEnemySelect(dD)
    h6.selectedEnemies = dD
end
local function onWalkSpeedOn(d3)
    h6.walkSpeedOn = d3
    local lP = ic()
    if lP and not d3 then
        lP.WalkSpeed = 16
    end
end
local function onHatchCount(dO)
    h6.hatchCount = dO
end
local function onGambleSelect(dK)
    h6.selectedGamble = dK
end
local function onHatchMax(dM)
    h6.hatchMax = dM
end
local function fn465(a0, a1)
    return tostring(a0.id) < tostring(a1.id)
end
local function onIdled()
    if h6.antiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end
local function onWorldSelect(dv)
    h6.selectedWorld = dv
    h6.selectedEnemies = {}
    local lJ = hN[dv]
    if EnemySelectDropdown and lJ then
        EnemySelectDropdown:SetValues(hU(lJ))
    end
    hY(dv)
end
local function onNoclip(ed)
    h6.noclipOn = ed
end
local function onInputEnded(e4)
    if e4.KeyCode == Enum.KeyCode.Space then
        hX = false
    end
    if e4.KeyCode == Enum.KeyCode.LeftControl then
        hS = false
    end
end
local function onAutoAttack(di)
    h6.autoAttack = di
end
local function onInputBegan(e0, e1)
    if e1 then
        return
    end
    if e0.KeyCode == Enum.KeyCode.Space then
        hX = true
    end
    if e0.KeyCode == Enum.KeyCode.LeftControl then
        hS = true
    end
end
local function worker2()
    while task.wait(0.15) do
        if Library.Unloaded then
            break
        end
        if h6.autoFarm then
            if h6.teleportFarm then
                pcall(h1)
            else
                pcall(hQ)
            end
        end
        if h6.autoCollect then
            pcall(hI)
        end
    end
end
local function onAutoEquipWeapon(dX)
    h6.autoEquipWeapon = dX
end
local function onHideEggAnim(dI)
    h6.hideEggAnim = dI
end
local function onAutoEquipPet(dZ)
    h6.autoEquipPet = dZ
end
local function onHeartbeat()
    if h6.noclipOn then
        local mn_1 = ij()
        if mn_1 then
            for i, descendant in ipairs(mn_1:GetDescendants()) do
                local mn_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if mn_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
    if h6.walkSpeedOn then
        local mn_3 = ic()
        if mn_3 then
            mn_3.WalkSpeed = h6.walkSpeed
        end
    end
    local mn_4 = h0()
    local mo = ic()
    if h6.flyOn and mn_4 and mo then
        local mp_1 = not bodyVelocity
        local mB = if mp_1 then 1 else 0
        local mz = 650 * mB + 2874 * (1 - mB)
        local mA = 618 * mB + 2677 * (1 - mB)
        if not ((mz * 450 + mA * 121 + mz * mA) % 16777213 == 768978) then
            mp_1 = bodyVelocity.Parent ~= mn_4
        end
        if mp_1 then
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1000000000, 1000000000, 1000000000)
            bodyVelocity.Velocity = Vector3.zero
            bodyVelocity.Parent = mn_4
        end
        local mn_5 = mo.MoveDirection * h6.flySpeed
        local mo_1 = 0
        if hX then
            mo_1 += h6.flySpeed
        end
        if hS then
            mo_1 -= h6.flySpeed
        end
        bodyVelocity.Velocity = Vector3.new(mn_5.X, mo_1, mn_5.Z)
    elseif bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end
local function onWalkSpeed(d7)
    h6.walkSpeed = d7
end
local function fn685(aN)
    local jT = {}
    local jU = h5[aN]
    if jU then
        for i, v in ipairs(jU) do
            jT[#jT + 1] = v.name
        end
    end
    return jT
end
local function onAutoRankUp(dV)
    h6.autoRankUp = dV
end
local function onAutoRebirth(dR)
    h6.autoRebirth = dR
end
local function fn745()
    local jy = ij()
    local jz = jy and jy:FindFirstChild("HumanoidRootPart")
    return jz
end
local function fn749()
    return LocalPlayer.Character
end
hG = nil
hH = nil
hI = nil
hM = nil
hN = nil
hO = nil
hQ = nil
LocalPlayer = nil
hS = nil
hT = nil
hU = nil
hW = nil
hX = nil
hY = nil
h_ = nil
h0 = nil
h1 = nil
VirtualUser = nil
h4 = nil
h5 = nil
h6 = nil
bodyVelocity = nil
h9 = nil
ic = nil
ie = nil
EnemySelectDropdown = nil
ij = nil
Library = nil
local hJ, hK, hL, hP, hV, ReplicatedStorage, h3, h8, ia, ih, ii, il
local io_1, io_6
local ir_1, ir_3
local iq_1
Library, VirtualUser, ReplicatedStorage, LocalPlayer, h_, hV, hP, hK, hJ, hG, il, ii, ie, h9, ir_1, io_1, hM, ij, ic, h0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local ip = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
ReplicatedStorage = game:GetService("ReplicatedStorage")
LocalPlayer = ip.LocalPlayer
if (ij or ij or not SaveManager and ir_1) and (not hM or not ij or not hM and SaveManager) or not ((ij or ij or not SaveManager and ir_1) and (not hM or not ij or not hM and SaveManager)) then
    io_1 = function(s)
        local jq_2
        local jp_2
        jp_2, jq_2 = pcall(function()
            local jh = ReplicatedStorage
            for i, v in ipairs(s) do
                jh = jh[v]
            end
            return require(jh)
        end)
        if jp_2 then
            return jq_2
        end
        return nil
    end
else
    hM = function(s)
        local jq_1
        local jp_1
        jp_1, jq_1 = pcall(function()
            local jh = ReplicatedStorage
            for i, v in ipairs(s) do
                jh = jh[v]
            end
            return require(jh)
        end)
        if jp_1 then
            return jq_1
        end
        return nil
    end
end
h_ = io_1({ "CommonLibrary", "Player", "ClientPlayerManager" })
hV = io_1({ "ClientLogic", "Monster", "MgrMonsterClient" })
hP = io_1({ "CommonLogic", "PlayerDamage", "ClickSystem" })
hK = io_1({ "CommonLogic", "Gamble", "GambleSystem" })
hJ = io_1({ "ClientLogic", "Gamble", "GambleShower" })
hG = io_1({ "CommonLogic", "Rebirth", "RebirthSystem" })
il = io_1({ "CommonLogic", "Area", "AreaSystem" })
ii = io_1({ "CommonLogic", "Area", "AreaPickUpSystem" })
ie = io_1({ "CommonLogic", "Weapon", "WeaponSystem" })
h9 = io_1({ "CommonLogic", "Pet", "PetSystem" })
local iw = io_1({ "CommonConfig", "CfgGlobal" })
local it = io_1({ "CommonConfig", "Area", "CfgAreaRegion" })
local iu = io_1({ "CommonConfig", "Area", "CfgAreaMonster" })
local ir_2 = io_1({ "CommonConfig", "Monster", "CfgMonster" })
local iv = io_1({ "CommonConfig", "Gamble", "CfgGamble" })
hM = fn24
ij = fn749
ic = fn173
h0 = fn745
local is = ir_2
if is then
    is = ir_2.Tmpls or ir_2
end
local im_2 = {}
local io_2 = is
local iJ = if io_2 then 1 else 0
local iH = 784 * iJ + 3011 * (1 - iJ)
local iI = 1415 * iJ + 2764 * (1 - iJ)
if not ((iH * 911 + iI * 870 + iH * iI) % 16777213 == 3054634) then
    io_2 = im_2
end
hH, hT, hN, iq_1, ir_3 = nil, nil, nil, nil, nil
ip = 33
repeat
    local im_3 = (ip * 1 + 4) % 5 + 1
    if im_3 <= 3 then
        if im_3 <= 2 then
            if im_3 <= 1 then
                if (ip * 2 + 9) * 13 % 3 == ((ip * 2 + 9) * 13 + 7) % 3 then
                    iq_1 = {}
                else
                    hN = {}
                end
                ip = (ip + 36) % 40
            else
                local is_1 = {
                    "wiz",
                    "zuhfuv",
                    "xlri",
                    "srxyjftll",
                    "ydobj",
                    "lxnroji",
                    "jhzboqbkvp",
                    "dqttgcw",
                    "qiz",
                    "hwpzbsljzkdm",
                    "ghty",
                    "jbrjvdnvfv",
                    "bbchdk",
                    "sldkbyvsb",
                    "xovukvavv"
                }
                if is_1[(ip * 75 + 103) % 15 + 1] < is_1[(ip * 75 + 103) % 15 + 1] then
                    it = iq_1
                else
                    iq_1 = it
                end
                ip = (ip + 21) % 40
            end
        else
            if ip * 91004135 + 12 + 4 >= ip * 91004135 + 12 + 4 + 2 then
                io_2 = hH
            else
                hH = io_2
            end
            ip = (ip + 26) % 40
        end
    elseif im_3 <= 4 then
        local im_4 = (vector.create((ip * 5 + 8) % 11 + 1, (ip * 1 + 11) % 13 + 1, (ip * 7 + 3) % 17 + 1))
        local is_2 = (vector.create((ip * 5 + 7) % 11 + 1, (ip * 4 + 7) % 13 + 1, (ip * 5 + 5) % 17 + 1))
        local mW = vector.dot(im_4, is_2)
        if mW * mW <= vector.dot(im_4, im_4) * vector.dot(is_2, is_2) then
            ir_3 = fn357
        else
            hH = fn357
        end
        ip = (ip + 1) % 40
    else
        local im_5 = (vector.create((ip * 4 + 8) % 11 + 1, (ip * 9 + 10) % 13 + 1, (ip * 11 + 7) % 17 + 1))
        local is_3 = (vector.create((ip * 6 + 7) % 11 + 1, (ip * 9 + 10) % 13 + 1, (ip * 13 + 2) % 17 + 1))
        local iB_1 = (vector.create((ip * 2 + 9) % 11 + 1, (ip * 1 + 11) % 13 + 1, (ip * 9 + 2) % 17 + 1))
        local iC = (vector.create((ip * 4 + 1) % 5 + 1, (ip * 1 + 6) % 7 + 1, (ip * 4 + 4) % 9 + 1))
        if vector.dot(vector.cross(im_5, (vector.cross(is_3, iB_1))), iC) == vector.dot(is_3 * vector.dot(im_5, iB_1) - iB_1 * vector.dot(im_5, is_3), iC) then
            hT = {}
        else
            hH = {}
        end
        ip = (ip + 31) % 40
    end
until (ip * 23 + 17) % 40 == 21
if iq_1 then
    iq_1 = it.Tmpls
end
if iq_1 then
    for k, v in pairs(it.Tmpls) do
        if type(v) == "table" then
            local im_6 = v.Name
            ip = im_6 == nil or im_6 == ""
            if ip then
                im_6 = "World " .. tostring(k)
            end
            hT[#hT + 1] = { id = k, name = im_6 }
        end
    end
    local io_4 = 3
    repeat
        local im_7 = { "ykybzvmorwq", "billtcu", "hqyvox", "warxr", "uxasitdsxa", "cwfmkct", "lrc", "lbyulqulh", "unn" }
        local mZ = io_4
        ip = im_7[mZ % 9 + 1]
        if ip:len() <= ip:reverse():rep(mZ % 3 + 2):len() then
            table.sort(hT, fn5)
        else
            table.sort(hT, fn5)
        end
        io_4 = (io_4 + 0) % 4
    until (io_4 * 3 + 3) % 4 == 0
    for i, v in ipairs(hT) do
        hN[v.name] = v.id
    end
end
local im_8 = iu
h5 = {}
if im_8 then
    im_8 = iu.Tmpls
end
if im_8 then
    for k, v in pairs(iu.Tmpls) do
        local im_9 = type(v) == "table" and v.AreaId and v.Monster and v.Monster[1]
        if im_9 then
            local TmplId = v.Monster[1].TmplId
            if TmplId then
                local AreaId = v.AreaId
                ip = {}
                local iq_2 = h5[v.AreaId] or ip
                h5[AreaId] = iq_2
                table.insert(h5[v.AreaId], { tmpl = TmplId, name = ir_3(TmplId) })
            end
        end
    end
    for k, v in pairs(h5) do
        table.sort(v, function(aF, aG)
            return aF.tmpl < aG.tmpl
        end)
    end
end
ip, h8, io_6, hU = nil, nil, nil, nil
local im_11 = 5
repeat
    local iq_3 = (im_11 * 2 + 0) % 3 + 1
    if iq_3 <= 2 then
        if iq_3 <= 1 then
            local iq_4 = (vector.create((im_11 * 7 + 2) % 11 + 1, (im_11 * 9 + 4) % 13 + 1, (im_11 * 15 + 5) % 17 + 1))
            local ir_4 = (vector.create((im_11 * 6 + 7) % 11 + 1, (im_11 * 4 + 11) % 13 + 1, (im_11 * 14 + 16) % 17 + 1))
            local is_4 = (vector.create((im_11 * 5 + 8) % 11 + 1, (im_11 * 7 + 11) % 13 + 1, (im_11 * 8 + 5) % 17 + 1))
            it = (vector.create((im_11 * 3 + 5) % 11 + 1, (im_11 * 7 + 12) % 13 + 1, (im_11 * 3 + 8) % 17 + 1))
            if vector.dot(vector.cross(iq_4, ir_4), (vector.cross(is_4, it))) == vector.dot(iq_4, is_4) * vector.dot(ir_4, it) - vector.dot(iq_4, it) * vector.dot(ir_4, is_4) then
                h8 = {}
            else
                io_6 = {}
            end
            im_11 = (im_11 + 8) % 12
        else
            local iq_5 = { "lflq", "qmzgsmpvrn", "setqz", "rzjomsmoq", "rynnjwa", "szojrxylre", "vvhh" }
            local m1 = im_11
            local ir_5 = iq_5[m1 % 7 + 1]
            if ir_5:len() <= ir_5:reverse():rep(m1 % 3 + 2):len() then
                io_6 = fn270
                hU = fn685
            else
                hU = fn270
                io_6 = fn685
            end
            im_11 = (im_11 + 2) % 12
        end
    else
        local iq_6 = { "dgdpxoi", "yhqqrylzjc", "wrajwpbgrvf", "endgkiuxskck", "lsllcjnwzm", "dbj", "vno", "ubnyxiylk" }
        if iq_6[(im_11 * 82 + 104) % 8 + 1] <= iq_6[(im_11 * 82 + 104) % 8 + 1] then
            ip = {}
        else
            hU = {}
        end
        im_11 = (im_11 + 2) % 12
    end
until (im_11 * 11 + 9) % 12 == 4
if iv then
    local im_12 = {}
    for k, v in pairs(iv) do
        local iq_7 = type(v) == "table" and v.Cost
        if iq_7 then
            local iq_8 = ""
            local ir_6 = v.Cost[1]
            if type(ir_6) == "table" then
                local format = string.format
                it = ir_6.ValueType or "?"
                local iu_1 = tostring(it)
                iv = ir_6.Count
                iJ = if iv then 1 else 0
                iH = 319 * iJ + 1437 * (1 - iJ)
                iI = 1989 * iJ + 586 * (1 - iJ)
                if not ((iH * 2778 + iI * 3539 + iH * iI) % 16777213 == 8559744) then
                    iv = "?"
                end
                iq_8 = format(" [%s x%s]", iu_1, tostring(iv))
            end
            local ir_7 = #im_12 + 1
            local format = string.format
            it = v.Name or k
            im_12[ir_7] = { id = k, label = format("%s (%s)%s", tostring(it), tostring(k), iq_8) }
        end
    end
    local is_7 = 1
    repeat
        if is_7 * 39785587 + 12 + 6 >= is_7 * 39785587 + 12 + 6 + 1 then
            table.sort(im_12, fn465)
        else
            table.sort(im_12, fn465)
        end
        is_7 = (is_7 + 1) % 4
    until (is_7 * 3 + 0) % 4 == 2
    for i, v in ipairs(im_12) do
        ip[#ip + 1] = v.label
        h8[v.label] = v.id
    end
end
local ib = iw and iw.AttackRange or 10
local im_14 = hT[1]
if im_14 then
    local iq_10 = 3
    repeat
        local ir_8 = (vector.create((iq_10 * 1 + 6) % 11 + 1, (iq_10 * 6 + 1) % 13 + 1, (iq_10 * 9 + 2) % 17 + 1))
        local m5 = vector.floor(ir_8) + vector.ceil(ir_8 * -1)
        if vector.dot(m5, m5) == 3 then
            hT = im_14[1].name
        else
            im_14 = hT[1].name
        end
        iq_10 = (iq_10 + 0) % 4
    until (iq_10 * 3 + 1) % 4 == 2
end
local iq_11 = im_14 or nil
local im_15 = {}
local ir_9 = ip[1] or nil
h6, h4, h3, hL, ia, ih, hQ, hO, h1, hI, hY = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
h6 = {
    autoAttack = false,
    hitsPerTarget = 1,
    autoFarm = false,
    teleportFarm = true,
    selectedWorld = iq_11,
    selectedEnemies = im_15,
    autoCollect = false,
    autoHatch = false,
    selectedGamble = ir_9,
    hatchMax = true,
    hatchCount = 1,
    hideEggAnim = false,
    autoRebirth = false,
    autoSkipRebirth = false,
    autoRankUp = false,
    autoEquipWeapon = false,
    autoEquipPet = false,
    antiAfk = false,
    walkSpeedOn = false,
    walkSpeed = 16,
    flyOn = false,
    flySpeed = 60,
    noclipOn = false,
    infJumpOn = false
}
h4 = {}
if ((not h6 or h6) and 35 and (hQ and not h6 or (h6 or 35)) or (hQ or h6 or not hL and not hQ) and ((hL or not hL) and h6)) and ((not hQ and not h6 or hL and 35 or (h6 or not hL) and (not hL and not hL)) and (h6 or h6 or (not hQ))) or not (((not h6 or h6) and 35 and (hQ and not h6 or (h6 or 35)) or (hQ or h6 or not hL and not hQ) and ((hL or not hL) and h6)) and ((not hQ and not h6 or hL and 35 or (h6 or not hL) and (not hL and not hL)) and (h6 or h6 or (not hQ)))) then
    hL = function(bd)
        if not hV then
            return
        end
        hV.IterMonster(function(bf)
            local j1 = bf and bf.IsAlive and bf:IsAlive()
            if j1 then
                bd(bf)
            end
        end)
    end
    ia = fn265
    ih = function(bu)
        if #bu == 0 or not hP then
            return
        end
        local ks_2 = math.max(1, h6.hitsPerTarget)
        local ky = 1
        while ky <= ks_2 do
            pcall(function()
                hP.ClientAttackMonster(bu)
                hP.ClientAddPlayerDamage(true)
            end)
            ky += 1
        end
    end
    hQ = function()
        local Position, kE
        local kF = h0()
        if not kF then
            return
        end
        Position = kF.Position
        kE = {}
        hL(function(bG)
            if bG.CurrentCFrame and (bG.CurrentCFrame.Position - Position).Magnitude <= ib then
                kE[#kE + 1] = bG.MonsterId
            end
        end)
        ih(kE)
    end
    hO = function()
        local Position, MonsterId, kO
        if not hP then
            return
        end
        local kP = h0()
        MonsterId, kO = nil, nil
        if kP then
            Position = kP.Position
            hL(function(bV)
                if bV.CurrentCFrame then
                    local Magnitude = (bV.CurrentCFrame.Position - Position).Magnitude
                    if Magnitude <= ib and (not kO or Magnitude < kO) then
                        kO = Magnitude
                        MonsterId = bV.MonsterId
                    end
                end
            end)
        end
        local kP_2 = math.max(1, h6.hitsPerTarget)
        local kT = 1
        while kT <= kP_2 do
            pcall(function()
                if MonsterId then
                    hP.ClientAttackMonster({ MonsterId })
                end
                hP.ClientAddPlayerDamage(true)
            end)
            kT += 1
        end
    end
else
    ia = function(bd)
        if not hV then
            return
        end
        hV.IterMonster(function(bf)
            local j1 = bf and bf.IsAlive and bf:IsAlive()
            if j1 then
                bd(bf)
            end
        end)
    end
    ih = fn265
    hQ = function(bu)
        if #bu == 0 or not hP then
            return
        end
        local ks_1 = math.max(1, h6.hitsPerTarget)
        local ky = 1
        while ky <= ks_1 do
            pcall(function()
                hP.ClientAttackMonster(bu)
                hP.ClientAddPlayerDamage(true)
            end)
            ky += 1
        end
    end
    hO = function()
        local Position, kE
        local kF = h0()
        if not kF then
            return
        end
        Position = kF.Position
        kE = {}
        hL(function(bG)
            if bG.CurrentCFrame and (bG.CurrentCFrame.Position - Position).Magnitude <= ib then
                kE[#kE + 1] = bG.MonsterId
            end
        end)
        ih(kE)
    end
    hL = function()
        local Position, MonsterId, kO
        if not hP then
            return
        end
        local kP = h0()
        MonsterId, kO = nil, nil
        if kP then
            Position = kP.Position
            hL(function(bV)
                if bV.CurrentCFrame then
                    local Magnitude = (bV.CurrentCFrame.Position - Position).Magnitude
                    if Magnitude <= ib and (not kO or Magnitude < kO) then
                        kO = Magnitude
                        MonsterId = bV.MonsterId
                    end
                end
            end)
        end
        local kP_1 = math.max(1, h6.hitsPerTarget)
        local kT = 1
        while kT <= kP_1 do
            pcall(function()
                if MonsterId then
                    hP.ClientAttackMonster({ MonsterId })
                end
                hP.ClientAddPlayerDamage(true)
            end)
            kT += 1
        end
    end
end
h3 = {}
h1 = function()
    local Position
    Position = nil
    local k2, k3, k4
    local k5 = h0()
    if not k5 then
        return
    end
    k3 = ia()
    local CFrame2 = k5.CFrame
    k2 = tick()
    k4 = {}
    hL(function(ci)
        if not k3 or ci.TmplId and k3[ci.TmplId] then
            if not h3[ci.MonsterId] or h3[ci.MonsterId] < k2 then
                k4[#k4 + 1] = ci
            end
        end
    end)
    Position = CFrame2.Position
    table.sort(k4, function(ct, cu)
        return (ct.CurrentCFrame.Position - Position).Magnitude < (cu.CurrentCFrame.Position - Position).Magnitude
    end)
    for i, v in ipairs(k4) do
        if not h6.autoFarm or Library.Unloaded then
            break
        end
        local k5_2 = v.IsAlive and v:IsAlive() and v.CurrentCFrame
        if k5_2 then
            local k5_3 = h0()
            if k5_3 then
                k5_3.CFrame = CFrame.new(v.CurrentCFrame.Position + Vector3.new(0, 4, 0))
                task.wait(0.04)
                local k5_4 = true
                local lm = 1
                while lm <= 8 do
                    if not h6.autoFarm or Library.Unloaded then
                        break
                    end
                    local k7_1 = hV.GetMonsterInfo(v.MonsterId)
                    local k8 = not k7_1
                    if not k8 then
                        local k9_1 = k7_1.IsAlive and k7_1:IsAlive()
                        k8 = not k9_1
                    end
                    if k8 then
                        k5_4 = false
                        break
                    end
                    local k8_1 = h0()
                    if k8_1 and k7_1.CurrentCFrame then
                        k8_1.CFrame = CFrame.new(k7_1.CurrentCFrame.Position + Vector3.new(0, 4, 0))
                    end
                    ih({ v.MonsterId })
                    task.wait(0.04)
                    lm += 1
                end
                if k5_4 then
                    h3[v.MonsterId] = tick() + 4
                end
            end
        end
    end
    local k5_5 = h0()
    if k5_5 then
        k5_5.CFrame = CFrame2
    end
end
hI = function()
    if not ii then
        return
    end
    local PickUpRewards = workspace:FindFirstChild("PickUpRewards")
    if not PickUpRewards then
        return
    end
    for i, child in ipairs(PickUpRewards:GetChildren()) do
        local lq_1 = child:GetAttribute("PickUpId") or child:GetAttribute("Id") or tonumber(child.Name)
        local lp = lq_1
        if lp then
            pcall(function()
                ii.ClientPickUp(lp)
            end)
        end
    end
end
hY = function(cZ)
    local lB
    if not il then
        return
    end
    lB = hN[cZ]
    if not lB then
        return
    end
    local lC = hM()
    local lD = lC and lC.area and not lC.area:IsAreaUnlocked(lB)
    if lD then
        pcall(function()
            il.ClientUnlock(lB)
        end)
    end
    pcall(function()
        il.ClientTeleportToAreaRegion(lB)
    end)
end
it = hJ and hJ.OnGambleResult
hW = it
if hJ and hW then
    hJ.OnGambleResult = function(db, dc)
        if h6.hideEggAnim then
            if dc then
                pcall(dc)
            end
            return
        end
        return hW(db, dc)
    end
end
EnemySelectDropdown = nil
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = "Anime Souls",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = true
})
it = {
    Main = Window:AddTab("Main", "sword"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}
local CombatGroup = it.Main:AddLeftGroupbox("Combat")
CombatGroup:AddToggle("AutoAttack", { Text = "Auto Attack", Default = false, Callback = onAutoAttack })
CombatGroup:AddSlider("HitsPerTarget", {
    Text = "Hits Per Target",
    Default = 1,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = onHitsPerTarget
})
local AutoFarmGroup = it.Main:AddLeftGroupbox("Auto Farm")
AutoFarmGroup:AddToggle("AutoFarm", { Text = "Enable Auto Farm", Default = false, Callback = onAutoFarm })
AutoFarmGroup:AddToggle("TeleportFarm", { Text = "Teleport To Mobs (Infinite Range)", Default = true, Callback = onTeleportFarm })
AutoFarmGroup:AddToggle("AutoCollect", { Text = "Auto Collect Drops", Default = false, Callback = onAutoCollect })
AutoFarmGroup:AddDropdown("WorldSelect", {
    Values = io_6(),
    Default = h6.selectedWorld,
    Multi = false,
    Text = "World",
    Callback = onWorldSelect
})
local im_17 = h6.selectedWorld
if im_17 then
    local io_7 = 2
    repeat
        local iq_13 = {
            "gykxnwlkt",
            "utwxacy",
            "jufj",
            "yzbng",
            "hfyjokesh",
            "yssqq",
            "puwtrjcbqeal",
            "rbgfllobgmwn",
            "uphdrxnss"
        }
        if iq_13[(io_7 * 8 + 40) % 9 + 1] < iq_13[(io_7 * 8 + 40) % 9 + 1] then
            h6 = hN(hU[im_17.selectedWorld])
        else
            im_17 = hU(hN[h6.selectedWorld])
        end
        io_7 = (io_7 + 2) % 8
    until (io_7 * 7 + 3) % 8 == 7
end
local iq_14 = {}
local io_8 = im_17
iJ = if io_8 then 1 else 0
iH = 3383 * iJ + 1058 * (1 - iJ)
iI = 547 * iJ + 3812 * (1 - iJ)
if not ((iH * 2034 + iI * 799 + iH * iI) % 16777213 == 9168576) then
    io_8 = iq_14
end
hX, hS, bodyVelocity = nil, nil, nil
EnemySelectDropdown = AutoFarmGroup:AddDropdown("EnemySelect", { Values = io_8, Multi = true, Text = "Enemies (none = all)", Callback = onEnemySelect })
local AutoHatchGroup = it.Main:AddLeftGroupbox("Auto Hatch")
AutoHatchGroup:AddToggle("AutoHatch", { Text = "Enable Auto Hatch", Default = false, Callback = onAutoHatch })
AutoHatchGroup:AddToggle("HideEggAnim", { Text = "Auto Hide Egg Animation", Default = false, Callback = onHideEggAnim })
AutoHatchGroup:AddDropdown("GambleSelect", {
    Values = ip,
    Default = h6.selectedGamble,
    Multi = false,
    Text = "Summon",
    Callback = onGambleSelect
})
AutoHatchGroup:AddToggle("HatchMax", { Text = "Hatch Max Amount", Default = true, Callback = onHatchMax })
AutoHatchGroup:AddSlider("HatchCount", { Text = "Hatch Amount", Default = 1, Min = 1, Max = 20, Rounding = 0, Callback = onHatchCount })
local ProgressionGroup = it.Main:AddRightGroupbox("Progression")
ProgressionGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false, Callback = onAutoRebirth })
ProgressionGroup:AddToggle("AutoSkipRebirth", { Text = "Also Use Skip-Rebirth", Default = false, Callback = onAutoSkipRebirth })
ProgressionGroup:AddToggle("AutoRankUp", { Text = "Auto Rank Up All Weapons", Default = false, Callback = onAutoRankUp })
ProgressionGroup:AddToggle("AutoEquipWeapon", { Text = "Auto Equip Best Sword", Default = false, Callback = onAutoEquipWeapon })
ProgressionGroup:AddToggle("AutoEquipPet", { Text = "Auto Equip Best Pet", Default = false, Callback = onAutoEquipPet })
local PlayerGroup = it.Main:AddRightGroupbox("Player")
PlayerGroup:AddToggle("AntiAfk", { Text = "Anti-AFK (PC + Mobile)", Default = false, Callback = onAntiAfk })
PlayerGroup:AddToggle("WalkSpeedOn", { Text = "Walk Speed", Default = false, Callback = onWalkSpeedOn })
PlayerGroup:AddSlider("WalkSpeed", {
    Text = "Walk Speed Amount",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = onWalkSpeed
})
PlayerGroup:AddToggle("FlyOn", { Text = "Fly", Default = false, Callback = onFlyOn })
PlayerGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0, Callback = onFlySpeed })
PlayerGroup:AddToggle("Noclip", { Text = "Noclip", Default = false, Callback = onNoclip })
PlayerGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false, Callback = onInfJump })
iv = it["UI Settings"]:AddLeftGroupbox("Menu")
iv:AddButton("Unload", onUnload)
iv:AddLabel("UI Toggle"):AddKeyPicker("MenuKeybind", { Default = "RightShift", Text = "UI Toggle", Mode = "Toggle", NoUI = true })
task.spawn(worker)
task.spawn(worker2)
task.spawn(function()
    local l4_1
    local l3_1
    local l7 = false
    repeat
        local l0
        if task.wait(0.4) then
            if Library.Unloaded then
                l7 = true
            else
                if h6.autoHatch and hK and h6.selectedGamble then
                    local l1 = h8[h6.selectedGamble]
                    if l1 then
                        l0 = h6.hatchCount
                        if h6.hatchMax and hK.GetGambleMaxTime then
                            local l2_2 = hM()
                            if l2_2 then
                                l3_1, l4_1 = pcall(hK.GetGambleMaxTime, l2_2, l1)
                                local l2_3 = l3_1 and type(l4_1) == "number" and l4_1 > 0
                                if l2_3 then
                                    l0 = l4_1
                                end
                            end
                        end
                        pcall(function()
                            hK.ClientDoGamble(l1, l0)
                        end)
                    end
                end
            end
        else
            l7 = true
        end
    until l7
end)
task.spawn(worker3)
fn12(LocalPlayer.Idled:Connect(onIdled))
fn12(UserInputService.JumpRequest:Connect(onJumpRequest))
hX, hS = false, false
fn12(UserInputService.InputBegan:Connect(onInputBegan))
fn12(UserInputService.InputEnded:Connect(onInputEnded))
fn12(RunService.Heartbeat:Connect(onHeartbeat))
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
SaveManager:SetFolder("TempoHub/anime-souls")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SaveDefault("Mint")
ThemeManager:ApplyToTab(it["UI Settings"])
ThemeManager:LoadDefault()
SaveManager:BuildConfigSection(it["UI Settings"])
SaveManager:LoadAutoloadConfig()
Library:OnUnload(function()
    h6.autoAttack = false
    h6.autoFarm = false
    h6.autoHatch = false
    h6.autoRebirth = false
    h6.autoCollect = false
    h6.autoRankUp = false
    h6.autoEquipWeapon = false
    h6.autoEquipPet = false
    h6.flyOn = false
    h6.noclipOn = false
    h6.walkSpeedOn = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if hJ and hW then
        hJ.OnGambleResult = hW
    end
    local mC_1 = ic()
    if mC_1 then
        mC_1.WalkSpeed = 16
    end
    for i, v in ipairs(h4) do
        local mJ = v
        pcall(function()
            mJ:Disconnect()
        end)
    end
end)
Library:Notify({
    Title = "Anime Souls",
    Description = "Loaded. Set your world and enemies in the Main tab.",
    Time = 5
})
end)(...)
