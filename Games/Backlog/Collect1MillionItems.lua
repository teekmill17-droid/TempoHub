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
getgenv().TempoHoodSubtitle = "COLLECT 1 MILLION ITEMS"
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
local ThemeManager
local lQ
local Library2
local TrailShop
local lD
local mk
local Gem
local mJ
local lJ
local l7
local RebirthPricing
local PlayerWalkspeedShop
local lV
local mC
local CashMultiplierShop
local mI
local lI
local mp
local SpawnSpeedShop
local mO
local mv
local mi
local Toggles
local PusherShop
local lH
local mo
local Prestige
local State
local TrailCurrent
local BuyEquipTrail
local Rebirth
local lT
local mA
local mh
local lZ
local mG
local PusherCurrent
local mn
local SaveManager
local mt
local ma
local Options
local EquipPusher
local Collected
local DropAmountShop
local BuyRebirth
local BuyUpgrade
local Cash
local CapacityLimitShop
local ms
local l9
local FriendBoostShop
local HiddenStats
local mf
local mE
local lE
local ml
local l2
local mK
local GemUpgradeShop
local function onCharacterAdded()
    task.wait(0.15)
    if mf() then
        mn()
    end
end
local function fn108(Q)
    local nz = typeof(cloneref) == "function" and typeof(Q) == "Instance"
    if nz then
        return cloneref(Q)
    end
    return Q
end
local function fn119()
    if lQ.WalkSpeedEnabled then
        lI.SetWalkSpeedEnabled(true)
    end
    if lQ.NoClip then
        lI.SetNoClip(true)
    end
    if lQ.Fly then
        lI.SetFly(true)
    end
end
local function fn163()
    if not State.AutoBuyUpgrades then
        return
    end
    for i, v in ipairs(mA) do
        if State.SelectedUpgrades[v] then
            l9(v)
        end
    end
end
local function fn192(dF)
    local p8 = dF and true or false
    lQ.WalkSpeedEnabled = p8
    local p7_1 = lJ()
    if not p7_1 then
        return
    end
    if lQ.WalkSpeedEnabled then
        if lQ.WalkSnapshots[p7_1] == nil then
            lQ.WalkSnapshots[p7_1] = p7_1.WalkSpeed
        end
        p7_1.WalkSpeed = lQ.WalkSpeed
    else
        local p8_1 = lQ.WalkSnapshots[p7_1]
        if p8_1 ~= nil then
            p7_1.WalkSpeed = p8_1
            lQ.WalkSnapshots[p7_1] = nil
        end
    end
end
local function fn250(c8)
    local pJ = c8 and true or false
    State.AutoClaimIndex = pJ
    if State.AutoClaimIndex then
        lZ("AutoClaimIndex", 0.5, lH)
    else
        ml("AutoClaimIndex")
    end
end
local function fn257()
    if not State.AutoBuyTrails then
        return
    end
    local Value2 = Cash.Value
    local Value = TrailCurrent.Value
    local o8 = TrailShop.GetMoneyBoost(Value) or 1
    local o9
    for i, v in ipairs(mk()) do
        if Value2 >= v.Price and v.Boost >= o8 then
            o9 = v
        end
    end
    if o9 and o9.Name ~= Value then
        BuyEquipTrail:FireServer(o9.Name)
        return
    end
    for k in pairs(TrailShop.Trails) do
        if TrailShop.GetPrice(k) == nil then
            local o6_1 = mI:GetAttribute("OwnsGamepass_" .. k) == true and TrailCurrent.Value ~= k
            if o6_1 then
                local o6_2 = TrailShop.GetMoneyBoost(k) or 1
                if o6_2 > o8 then
                    BuyEquipTrail:FireServer(k)
                    return
                end
            end
        end
    end
end
local function fn333()
    local oY = {}
    for k in pairs(TrailShop.Trails) do
        local oZ = TrailShop.GetPrice(k)
        if type(oZ) == "number" then
            local o_ = TrailShop.GetMoneyBoost(k) or 1
            table.insert(oY, { Name = k, Price = oZ, Boost = o_ })
        end
    end
    table.sort(oY, function(cE, cF)
        if cE.Boost == cF.Boost then
            return cE.Price < cF.Price
        end
        return cE.Boost < cF.Boost
    end)
    return oY
end
local function fn340()
    lI.SetWalkSpeedEnabled(false)
    lI.SetInfJump(false)
    lI.SetNoClip(false)
    lI.SetInstantProximityPrompt(false)
    lI.SetFly(false)
    if lQ.CharAddedConn then
        lQ.CharAddedConn:Disconnect()
        lQ.CharAddedConn = nil
    end
end
local function fn363()
    local ov = mv[Prestige.Value]
    return ov ~= nil and Rebirth.Value == ov
end
local function fn366(dK)
    local qa = tonumber(dK) or lQ.WalkSpeed
    lQ.WalkSpeed = qa
    if lQ.WalkSpeedEnabled then
        local qa_1 = lJ()
        if qa_1 then
            qa_1.WalkSpeed = lQ.WalkSpeed
        end
    end
end
local function fn369(c4)
    local pD = c4 and true
    local pH = if pD then 1 else 0
    local pF = 1839 * pH + 1928 * (1 - pH)
    local pG = 3433 * pH + 397 * (1 - pH)
    if not ((pF * 3549 + pG * 1292 + pF * pG) % 16777213 == 498121) then
        pD = false
    end
    State.AutoBuyUpgrades = pD
    if State.AutoBuyUpgrades then
        lZ("AutoBuyUpgrades", 0.35, mi)
    else
        ml("AutoBuyUpgrades")
    end
end
local function fn378()
    for k in pairs(State.Workers) do
        ml(k)
    end
end
local function fn419()
    mK(lE.Main)
    local AutomationGroup = lE.Main:AddLeftGroupbox("Automation", "bot")
    AutomationGroup:AddToggle("AutoCollectItems", { Text = "Auto Collect Items", Default = false })
    AutomationGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
    AutomationGroup:AddDropdown("UpgradeTarget", { Text = "Upgrades", Values = mA, Multi = true, AllowNull = true, Default = mA })
    AutomationGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
    AutomationGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    AutomationGroup:AddToggle("AutoBuyPusher", { Text = "Auto Buy Pusher", Default = false })
    AutomationGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
    Toggles.AutoCollectItems:OnChanged(function(gx)
        lI.SetAutoCollect(gx)
    end)
    Toggles.AutoBuyUpgrades:OnChanged(function(gA)
        lI.SetAutoBuyUpgrades(gA)
    end)
    Options.UpgradeTarget:OnChanged(function(gD)
        lI.SetSelectedUpgrades(gD)
    end)
    Toggles.AutoClaimIndex:OnChanged(function(gF)
        lI.SetAutoClaimIndex(gF)
    end)
    Toggles.AutoRebirth:OnChanged(function(gH)
        lI.SetAutoRebirth(gH)
    end)
    Toggles.AutoBuyPusher:OnChanged(function(gJ)
        lI.SetAutoBuyPusher(gJ)
    end)
    Toggles.AutoBuyTrails:OnChanged(function(gL)
        lI.SetAutoBuyTrails(gL)
    end)
    lI.SetSelectedUpgrades(Options.UpgradeTarget.Value)
end
local function fn469(e1)
    return (tostring(e1):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end
local function fn477()
    return lD.CoreGui
end
local function fn479(di)
    local pP = di and true or false
    State.AutoBuyPusher = pP
    if State.AutoBuyPusher then
        lZ("AutoBuyPusher", 0.5, ma)
    else
        ml("AutoBuyPusher")
    end
end
local function fn480(e7, e8, e9)
    return string.format("<b>%s</b> %s %s", e7, mh("-", "#5a6070"), mh(e8, e9))
end
local function fn492(dd)
    local pM = dd and true or false
    State.AutoRebirth = pM
    if State.AutoRebirth then
        lZ("AutoRebirth", 0.5, mt)
    else
        ml("AutoRebirth")
    end
end
local function fn501(dP)
    local qf = dP and true or false
    lQ.InfJump = qf
    if lQ.InfJumpConn then
        lQ.InfJumpConn:Disconnect()
        lQ.InfJumpConn = nil
    end
    if not lQ.InfJump then
        return
    end
    lQ.InfJumpConn = lD.UserInputService.JumpRequest:Connect(function()
        local qc = not mf() or not lQ.InfJump
        if qc then
            return
        end
        local qc_1 = lJ()
        if qc_1 then
            qc_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
local function fn507(fo)
    local DiscordGroup = fo:AddLeftGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = l2,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    return DiscordGroup
end
local function fn573(eM)
    local rc = tonumber(eM) or lQ.FlySpeed
    lQ.FlySpeed = rc
end
local function fn576(dn)
    local pS = dn and true
    local pW = if pS then 1 else 0
    local pU = 3000 * pW + 1478 * (1 - pW)
    local pV = 3351 * pW + 766 * (1 - pW)
    if not ((pU * 2327 + pV * 3378 + pU * pV) % 16777213 == 11576465) then
        pS = false
    end
    State.AutoBuyTrails = pS
    if State.AutoBuyTrails then
        lZ("AutoBuyTrails", 0.5, mJ)
    else
        ml("AutoBuyTrails")
    end
end
local function fn612()
    return not lI.Unloaded
end
local function fn623(c3)
    local px = c3 and true or false
    State.AutoCollect = px
    if State.AutoCollect then
        lZ("AutoCollect", 0.15, mp)
    else
        ml("AutoCollect")
    end
end
local function fn629(aW)
    local nJ = HiddenStats:FindFirstChild(aW)
    local nK = nJ and nJ:IsA("ValueBase")
    if nK then
        return nJ.Value
    end
    return 0
end
local function fn640()
    if not State.AutoBuyPusher then
        return
    end
    local Value2 = Collected.Value
    local Value = PusherCurrent.Value
    local Name
    for i, v in ipairs(mO()) do
        if Value2 >= v.Req then
            Name = v.Name
        end
    end
    if Name and Name ~= Value then
        EquipPusher:FireServer(Name)
    end
end
local function fn657(c_)
    local pm = {}
    if type(c_) == "table" then
        for k, v in pairs(c_) do
            if v == true then
                pm[tostring(k)] = true
            elseif type(v) == "string" then
                pm[v] = true
            end
        end
    else
        local pn = c_ ~= ""
        local po = type(c_) == "string" and pn
        if po then
            pm[c_] = true
        end
    end
    return pm
end
local function fn721(c5)
    State.SelectedUpgrades = l7(c5)
end
local function fn740()
    gethui = mE
end
local function fn741(a5)
    local nT = mo[a5] or a5
    local nU = lV(nT)
    if a5 == "CashMultiplier" then
        if CashMultiplierShop.GetMaxMultiplier() <= nU then
            return false
        end
        local nT_1 = CashMultiplierShop.GetPrice(nU)
        if not nT_1 or Cash.Value < nT_1 then
            return false
        end
        BuyUpgrade:FireServer("CashMultiplier")
        return true
    elseif a5 == "PlayerWalkspeed" then
        if PlayerWalkspeedShop.MAX_UPGRADES <= nU then
            return false
        end
        local nT_2 = PlayerWalkspeedShop.GetPrice(nU)
        if not nT_2 or Cash.Value < nT_2 then
            return false
        end
        BuyUpgrade:FireServer("PlayerWalkspeed")
        return true
    elseif a5 == "SpawnSpeed" then
        if SpawnSpeedShop.MAX_UPGRADES <= nU then
            return false
        end
        local nT_3 = SpawnSpeedShop.GetPrice(nU)
        if not nT_3 or Cash.Value < nT_3 then
            return false
        end
        BuyUpgrade:FireServer("SpawnSpeed")
        return true
    elseif a5 == "CapacityLimit" then
        if CapacityLimitShop.MAX_UPGRADES <= nU then
            return false
        end
        local nT_4 = CapacityLimitShop.GetPrice(nU)
        if not nT_4 or Cash.Value < nT_4 then
            return false
        end
        BuyUpgrade:FireServer("CapacityLimit")
        return true
    elseif a5 == "DropAmount" then
        if DropAmountShop.MAX_UPGRADES <= nU then
            return false
        end
        local nT_5 = DropAmountShop.GetPrice(nU)
        if not nT_5 or Cash.Value < nT_5 then
            return false
        end
        BuyUpgrade:FireServer("DropAmount")
        return true
    elseif a5 == "FriendBoost" then
        if FriendBoostShop.MAX_UPGRADES <= nU then
            return false
        end
        local nT_6 = FriendBoostShop.GetPrice(nU)
        if not nT_6 or Cash.Value < nT_6 then
            return false
        end
        BuyUpgrade:FireServer("FriendBoost")
        return true
    elseif mC(a5) then
        local nT_7 = GemUpgradeShop.Upgrades and GemUpgradeShop.Upgrades[a5]
        local nV_7 = nT_7
        if nT_7 then
            nT_7 = tonumber(nV_7.MaxUpgrades)
        end
        local nV_8 = nT_7 or nil
        local nT_8 = nV_8
        if nV_8 then
            nV_8 = nT_8 <= nU
        end
        if nV_8 then
            return false
        end
        local nT_9 = GemUpgradeShop.GetPrice(nU, a5)
        if not nT_9 or Gem.Value < nT_9 then
            return false
        end
        BuyUpgrade:FireServer(a5)
        return true
    else
        return false
    end
end
local function fn744(aG)
    local nE = State.Workers[aG]
    if nE then
        pcall(task.cancel, nE)
        State.Workers[aG] = nil
    end
end
local function fn749(e3, e4)
    return string.format('<font color="%s">%s</font>', e4, ms(e3))
end
local function fn755()
    local oF = {}
    for k in pairs(PusherShop.Pushers) do
        local oG = PusherShop.GetRequirement(k)
        if type(oG) == "number" then
            table.insert(oF, { Name = k, Req = oG })
        end
    end
    table.sort(oF, function(cl, cm)
        if cl.Req == cm.Req then
            return cl.Name < cm.Name
        end
        return cl.Req < cm.Req
    end)
    return oF
end
local function fn759(eX, eY)
    local rk = false
    if type(setclipboard) == "function" then
        rk = pcall(setclipboard, eX)
    elseif type(toclipboard) == "function" then
        rk = pcall(toclipboard, eX)
    end
    if rk and Library then
        local rk_1 = eY or "Copied"
        Library:Notify(rk_1, 2)
    end
end
local function fn796()
    local Character = mI.Character
    local p2 = Character and Character:FindFirstChildOfClass("Humanoid")
    return p2
end
local function fn807()
    local Character = mI.Character
    local p5 = Character and Character:FindFirstChild("HumanoidRootPart")
    return p5
end
local function fn824()
    mK(lE.Settings)
    local MenuGroup = lE.Settings:AddLeftGroupbox("Menu", "settings")
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    MenuGroup:AddToggle("NoGameplayPaused", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3DRendering", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FPSBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUIOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library2.ToggleKeybind = Options.MenuKeybind
    local ScriptGroup = lE.Settings:AddLeftGroupbox("Script", "scroll-text")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library2:Unload()
        end
    })
    Toggles.AntiAfk:OnChanged(function(iN)
        lI.SetAntiAfk(iN)
    end)
    Toggles.NoGameplayPaused:OnChanged(function(iQ)
        lI.SetNoGameplayPaused(iQ)
    end)
    Toggles.AutoReconnect:OnChanged(function(iS)
        lI.SetAutoReconnect(iS)
    end)
    Toggles.Disable3DRendering:OnChanged(function(iU)
        lI.SetDisable3D(iU)
    end)
    Toggles.FPSBoost:OnChanged(function(iW)
        lI.SetFpsBoost(iW)
    end)
    ThemeManager:SetLibrary(Library2)
    ThemeManager:SetFolder("MyScriptHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(lE.Settings)
    SaveManager:SetLibrary(Library2)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    SaveManager:SetFolder("TempoHub/Collect1MillionItems")
    SaveManager:BuildConfigSection(lE.Settings)
    pcall(function()
        ThemeManager:LoadDefault()
    end)
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
    lI.SetAntiAfk(Toggles.AntiAfk.Value)
    lI.SetNoGameplayPaused(Toggles.NoGameplayPaused.Value)
    lI.SetAutoReconnect(Toggles.AutoReconnect.Value)
    lI.SetDisable3D(Toggles.Disable3DRendering.Value)
    lI.SetFpsBoost(Toggles.FPSBoost.Value)
    lI.SetAutoCollect(Toggles.AutoCollectItems.Value)
    lI.SetAutoBuyUpgrades(Toggles.AutoBuyUpgrades.Value)
    lI.SetSelectedUpgrades(Options.UpgradeTarget.Value)
    lI.SetAutoClaimIndex(Toggles.AutoClaimIndex.Value)
    lI.SetAutoRebirth(Toggles.AutoRebirth.Value)
    lI.SetAutoBuyPusher(Toggles.AutoBuyPusher.Value)
    lI.SetAutoBuyTrails(Toggles.AutoBuyTrails.Value)
    if Toggles.HideUIOnStart.Value then
        pcall(function()
            Library2:Toggle(false)
        end)
    end
end
local function fn858()
    mK(lE.Player)
    local MovementGroup = lE.Player:AddLeftGroupbox("Movement", "person-standing")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "Noclip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = lE.Player:AddRightGroupbox("Fly", "plane")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    Toggles.WalkSpeedEnabled:OnChanged(function(gT)
        lI.SetWalkSpeedEnabled(gT)
    end)
    Options.WalkSpeed:OnChanged(function(gX)
        lI.SetWalkSpeedValue(gX)
    end)
    Toggles.InfJump:OnChanged(function(gZ)
        lI.SetInfJump(gZ)
    end)
    Toggles.NoClip:OnChanged(function(g0)
        lI.SetNoClip(g0)
    end)
    Toggles.InstantProximityPrompt:OnChanged(function(g2)
        lI.SetInstantProximityPrompt(g2)
    end)
    Toggles.Fly:OnChanged(function(g4)
        lI.SetFly(g4)
    end)
    Options.FlySpeed:OnChanged(function(g6)
        lI.SetFlySpeed(g6)
    end)
end
local function fn886()
    if not State.AutoRebirth then
        return
    end
    if lT() then
        return
    end
    local oy = RebirthPricing.GetPrice(Rebirth.Value)
    local oz = not oy
    local oD = if oz then 1 else 0
    local oB = 3766 * oD + 669 * (1 - oD)
    local oC = 3658 * oD + 577 * (1 - oD)
    if not ((oB * 194 + oC * 1901 + oB * oC) % 16777213 == 4683277) then
        oz = Cash.Value < oy
    end
    if oz then
        return
    end
    BuyRebirth:FireServer()
end
local function fn894(a0)
    for i, v in ipairs(mG) do
        if v == a0 then
            return true
        end
    end
    return false
end
local function fn901(T)
    return type(T) == "function"
end
lD = nil
lE = nil
BuyUpgrade = nil
PusherCurrent = nil
lH = nil
lI = nil
lJ = nil
GemUpgradeShop = nil
TrailCurrent = nil
lQ = nil
FriendBoostShop = nil
Options = nil
lT = nil
lV = nil
DropAmountShop = nil
lZ = nil
Toggles = nil
Gem = nil
l2 = nil
CapacityLimitShop = nil
SaveManager = nil
Prestige = nil
SpawnSpeedShop = nil
l7 = nil
ThemeManager = nil
l9 = nil
ma = nil
Rebirth = nil
PlayerWalkspeedShop = nil
Library2 = nil
mf = nil
Collected = nil
mh = nil
mi = nil
CashMultiplierShop = nil
mk = nil
ml = nil
Cash = nil
mn = nil
mo = nil
mp = nil
local lL, SellItem, lO, lP, Index, lW, lX, l0, mc
ms = nil
mt = nil
BuyEquipTrail = nil
mv = nil
HiddenStats = nil
EquipPusher = nil
mA = nil
mC = nil
TrailShop = nil
mE = nil
BuyRebirth = nil
mG = nil
PusherShop = nil
mI = nil
mJ = nil
mK = nil
State = nil
mO = nil
RebirthPricing = nil
local mq, mr, mw, mx, mB, ClaimIndexReward, LocalItems
local mX_1
if not game:IsLoaded() then
    game.Loaded:Wait()
end
lD, mI, mE = nil, nil, nil
local mQ = 6
repeat
    local mR_1 = { "ebnqjbj", "fovjziqfycq", "gkggrtr", "wyqy", "uclqoyfknnb", "coz", "ifcuup", "tknhxfcouj" }
    local tZ = mQ
    local mS_1 = mR_1[tZ % 8 + 1]
    if mS_1:len() <= mS_1:reverse():rep(tZ % 3 + 2):len() then
        lD = {}
        lD.Players = game:GetService("Players")
        lD.ReplicatedStorage = game:GetService("ReplicatedStorage")
        lD.RunService = game:GetService("RunService")
        lD.UserInputService = game:GetService("UserInputService")
        lD.VirtualUser = game:GetService("VirtualUser")
        lD.HttpService = game:GetService("HttpService")
        lD.TeleportService = game:GetService("TeleportService")
        lD.Workspace = game:GetService("Workspace")
        lD.Lighting = game:GetService("Lighting")
        lD.Stats = game:GetService("Stats")
        lD.CoreGui = game:GetService("CoreGui")
        mI = lD.Players.LocalPlayer
        mE = fn477
    else
        mE = {}
        mE.Players = game:GetService("Players")
        mE.ReplicatedStorage = game:GetService("ReplicatedStorage")
        mE.RunService = game:GetService("RunService")
        mE.UserInputService = game:GetService("UserInputService")
        mE.VirtualUser = game:GetService("VirtualUser")
        mE.HttpService = game:GetService("HttpService")
        mE.TeleportService = game:GetService("TeleportService")
        mE.Workspace = game:GetService("Workspace")
        mE.Lighting = game:GetService("Lighting")
        mE.Stats = game:GetService("Stats")
        mE.CoreGui = game:GetService("CoreGui")
        lD = mE.Players.LocalPlayer
        mI = fn477
    end
    mQ = (mQ + 0) % 8
until (mQ * 5 + 0) % 8 == 6
if getgenv then
    getgenv().gethui = mE
end
mc, l2, lX, lP, lI, State, l0, SellItem, BuyUpgrade, ClaimIndexReward, BuyRebirth, EquipPusher, BuyEquipTrail, CashMultiplierShop, PlayerWalkspeedShop, SpawnSpeedShop, CapacityLimitShop, DropAmountShop, FriendBoostShop, GemUpgradeShop, RebirthPricing, PusherShop, TrailShop, HiddenStats, Cash, Collected, Rebirth, Prestige, Gem, Index, TrailCurrent, PusherCurrent, LocalItems, mG, mA, mv, mo, lQ, mB, mw, mq, mX_1, Library2, ThemeManager, SaveManager, Toggles, Options, lE, lO, mr, mf, ml, lZ, lV, mC, l9, mp, mi, lH, lT, mt, mO, ma, mk, mJ, l7, lJ, mx, mn, lL, ms, mh, lW, mK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn740)
local function mY(i)
    local np
    local nn
    local no
    nn = nil
    no = nil
    np = nil
    local nq = i ~= ""
    local nr = type(i) == "string" and nq
    assert(nr, "Namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    nn = getgenv()
    assert(type(nn) == "table", "getgenv did not return a table")
    local nq_1 = nn[i]
    if nq_1 ~= nil then
        local nr_1 = type(nq_1) == "table" and type(nq_1.Unload) == "function"
        assert(nr_1, "Namespace is occupied")
        nq_1.Unload()
        assert(nn[i] == nil, "Previous instance did not release its namespace")
    end
    no = {}
    np = { State = {}, Unloaded = false }
    np.Track = function(o)
        assert(type(o) == "function", "Cleanup must be callable")
        if np.Unloaded then
            o()
        else
            table.insert(no, o)
        end
        return o
    end
    np.Unload = function()
        local ng_1
        local nf_1
        if np.Unloaded then
            return
        end
        np.Unloaded = true
        local nd = {}
        local nk = #no
        local nj = -1
        while false and nk <= 1 or true and nk >= 1 do
            local nl = nk
            local ne_1 = table.remove(no, nl)
            nf_1, ng_1 = pcall(ne_1)
            if not nf_1 then
                table.insert(nd, tostring(ng_1))
            end
            nk += nj
        end
        table.clear(np.State)
        if #nd > 0 then
            error("Cleanup incomplete: " .. table.concat(nd, "; "), 0)
        end
        if nn[i] == np then
            nn[i] = nil
        end
    end
    nn[i] = np
    return np
end
local function mS_2(B, C)
    local nx = type(B) == "table" and type(B.Track) == "function"
    assert(nx, "FeatureAPI required")
    local nx_1 = type(C) == "table" and type(C.OnUnload) == "function"
    assert(nx_1, "UI library required")
    assert(type(C.Unload) == "function", "UI unload required")
    B.Track(function()
        if not C.Unloaded then
            C:Unload()
        end
    end)
    C:OnUnload(function()
        B.Unload()
    end)
end
local mW = "TempoCollect1MillionItems"
mc = "Collect 1 Million Items"
local mV = "v0.3"
l2 = "https://discord.gg/K7Qxnxkk46"
lX = "https://discord.gg/K7Qxnxkk46"
lP = "https://tempohub.shop"
lI = mY(mW)
State = lI.State
mr = fn901
mf = fn612
local mU = fn108(lD.ReplicatedStorage)
l0 = fn108(lD.Workspace)
local Remotes = mU:WaitForChild("Remotes")
SellItem = Remotes:WaitForChild("SellItem")
BuyUpgrade = Remotes:WaitForChild("BuyUpgrade")
ClaimIndexReward = Remotes:WaitForChild("ClaimIndexReward")
BuyRebirth = Remotes:WaitForChild("BuyRebirth")
EquipPusher = Remotes:WaitForChild("EquipPusher")
if (TrailShop or not mt or false) and "#6ec1ff" and (not SaveManager or false or (SaveManager or not TrailShop) or (TrailShop and mX_1 or false and not SaveManager)) or ((false or SaveManager) and (not SaveManager and not SaveManager) and ((not SaveManager or not TrailShop) and (mt and not mt)) or (TrailShop or mt or mX_1 and BuyEquipTrail or (TrailShop or mt or not SaveManager and not BuyEquipTrail))) or not ((TrailShop or not mt or false) and "#6ec1ff" and (not SaveManager or false or (SaveManager or not TrailShop) or (TrailShop and mX_1 or false and not SaveManager)) or ((false or SaveManager) and (not SaveManager and not SaveManager) and ((not SaveManager or not TrailShop) and (mt and not mt)) or (TrailShop or mt or mX_1 and BuyEquipTrail or (TrailShop or mt or not SaveManager and not BuyEquipTrail)))) then
    BuyEquipTrail = Remotes:WaitForChild("BuyEquipTrail")
else
    BuyEquipTrail:WaitForChild("BuyEquipTrail")
end
local Others = mU:WaitForChild("Others")
CashMultiplierShop = require(Others:WaitForChild("CashMultiplierShop"))
PlayerWalkspeedShop = require(Others:WaitForChild("PlayerWalkspeedShop"))
SpawnSpeedShop = require(Others:WaitForChild("SpawnSpeedShop"))
CapacityLimitShop = require(Others:WaitForChild("CapacityLimitShop"))
DropAmountShop = require(Others:WaitForChild("DropAmountShop"))
FriendBoostShop = require(Others:WaitForChild("FriendBoostShop"))
GemUpgradeShop = require(Others:WaitForChild("GemUpgradeShop"))
RebirthPricing = require(Others:WaitForChild("RebirthPricing"))
PusherShop = require(Others:WaitForChild("PusherShop"))
TrailShop = require(Others:WaitForChild("TrailShop"))
HiddenStats = mI:WaitForChild("HiddenStats")
local leaderstats = mI:WaitForChild("leaderstats")
Cash = leaderstats:WaitForChild("Cash")
Collected = leaderstats:WaitForChild("Collected")
Rebirth = leaderstats:WaitForChild("Rebirth")
Prestige = leaderstats:WaitForChild("Prestige")
Gem = HiddenStats:WaitForChild("Gem")
Index = HiddenStats:WaitForChild("Index")
TrailCurrent = mI:WaitForChild("TrailCurrent")
PusherCurrent = mI:WaitForChild("PusherCurrent")
LocalItems = l0:WaitForChild("LocalItems")
mG = {
    "GoldenUpgrade",
    "DarkMatterUpgrade",
    "PrismaticUpgrade",
    "GiantUpgrade",
    "GemDropUpgrade",
    "GemMultiplierUpgrade"
}
mA = {
    "CashMultiplier",
    "PlayerWalkspeed",
    "SpawnSpeed",
    "CapacityLimit",
    "DropAmount",
    "FriendBoost",
    "GoldenUpgrade",
    "DarkMatterUpgrade",
    "PrismaticUpgrade",
    "GiantUpgrade",
    "GemDropUpgrade",
    "GemMultiplierUpgrade"
}
mv = { [0] = 10, [1] = 15, [2] = 20, [3] = 25, [4] = 30, [5] = 35, [6] = 40, [7] = 45 }
mo = {
    CashMultiplier = "CashMultiplier",
    PlayerWalkspeed = "PlayerSpeedX",
    SpawnSpeed = "SpawnSpeedX",
    CapacityLimit = "CapacityLimitX",
    DropAmount = "DropAmountX",
    FriendBoost = "FriendBoostX",
    GoldenUpgrade = "GoldenUpgradeX",
    DarkMatterUpgrade = "DarkMatterUpgradeX",
    PrismaticUpgrade = "PrismaticUpgradeX",
    GiantUpgrade = "GiantUpgradeX",
    GemDropUpgrade = "GemDropUpgradeX",
    GemMultiplierUpgrade = "GemMultiplierX"
}
State.AutoCollect = false
State.AutoBuyUpgrades = false
State.SelectedUpgrades = {}
State.AutoClaimIndex = false
State.AutoRebirth = false
State.AutoBuyPusher = false
State.AutoBuyTrails = false
State.Workers = {}
ml = fn744
lZ = function(aJ, aK, aL)
    ml(aJ)
    State.Workers[aJ] = task.spawn(function()
        local nH_1
        local nG_1
        while mf() do
            nG_1, nH_1 = pcall(aL)
            if not nG_1 then
                warn("[Tempo]", aJ, nH_1)
            end
            task.wait(aK)
            if not mf() then
                break
            end
        end
    end)
end
lV = fn629
mC = fn894
l9 = fn741
mp = function()
    if not State.AutoCollect then
        return
    end
    local children = LocalItems:GetChildren()
    for i, v in ipairs(children) do
        local n8 = v
        local n0_1 = not mf() or not State.AutoCollect
        if n0_1 then
            return
        end
        local attr = n8:GetAttribute("SellToken")
        local n0_2 = attr ~= ""
        local n1 = type(attr) == "string" and n0_2
        if n1 then
            pcall(function()
                SellItem:FireServer(n8.Name, attr)
            end)
            pcall(function()
                n8:Destroy()
            end)
        end
    end
end
mi = fn163
lH = function()
    if not State.AutoClaimIndex then
        return
    end
    for i, child in ipairs(Index:GetChildren()) do
        local ou = child
        local og = not mf() or not State.AutoClaimIndex
        if og then
            return
        end
        local og_1 = ou:IsA("BoolValue") and ou.Value == false
        if og_1 then
            pcall(function()
                ClaimIndexReward:FireServer(ou.Name)
            end)
        end
    end
end
lT = fn363
mt = fn886
mO = fn755
ma = fn640
mk = fn333
mJ = fn257
l7 = fn657
lI.SetAutoCollect = fn623
lI.SetAutoBuyUpgrades = fn369
lI.SetSelectedUpgrades = fn721
lI.SetAutoClaimIndex = fn250
lI.SetAutoRebirth = fn492
lI.SetAutoBuyPusher = fn479
lI.SetAutoBuyTrails = fn576
lI.Track(fn378)
lQ = {
    WalkSpeedEnabled = false,
    WalkSpeed = 32,
    InfJump = false,
    NoClip = false,
    InstantPrompt = false,
    Fly = false,
    FlySpeed = 60,
    WalkSnapshots = {},
    NoClipSnapshots = {},
    PromptSnapshots = {},
    InfJumpConn = nil,
    NoClipConn = nil,
    PromptConn = nil,
    FlyConn = nil,
    CharAddedConn = nil,
    FlyBody = nil,
    FlyPriorPlatformStand = nil
}
lJ = fn796
mx = fn807
lI.SetWalkSpeedEnabled = fn192
lI.SetWalkSpeedValue = fn366
lI.SetInfJump = fn501
lI.SetNoClip = function(dZ)
    local ql = dZ and true or false
    lQ.NoClip = ql
    if lQ.NoClipConn then
        lQ.NoClipConn:Disconnect()
        lQ.NoClipConn = nil
    end
    local Character = mI.Character
    if not lQ.NoClip then
        for k, v in pairs(lQ.NoClipSnapshots) do
            if k and k.Parent then
                k.CanCollide = v
            end
        end
        table.clear(lQ.NoClipSnapshots)
        return
    end
    local function qj(d6)
        if not d6:IsA("BasePart") then
            return
        end
        if lQ.NoClipSnapshots[d6] == nil then
            lQ.NoClipSnapshots[d6] = d6.CanCollide
        end
        d6.CanCollide = false
    end
    if Character then
        for i, descendant in ipairs(Character:GetDescendants()) do
            qj(descendant)
        end
        lQ.NoClipConn = Character.DescendantAdded:Connect(function(ea)
            if lQ.NoClip then
                qj(ea)
            end
        end)
    end
end
lI.SetInstantProximityPrompt = function(ed)
    local qP
    local qR = ed and true or false
    lQ.InstantPrompt = qR
    if lQ.PromptConn then
        lQ.PromptConn:Disconnect()
        lQ.PromptConn = nil
    end
    local function qQ_1()
        for k, v in pairs(lQ.PromptSnapshots) do
            if k and k.Parent then
                k.HoldDuration = v.HoldDuration
                k.MaxActivationDistance = v.MaxActivationDistance
                k.RequiresLineOfSight = v.RequiresLineOfSight
            end
        end
        table.clear(lQ.PromptSnapshots)
    end
    if not lQ.InstantPrompt then
        qQ_1()
        return
    end
    qP = function(el)
        if not el:IsA("ProximityPrompt") then
            return
        end
        if lQ.PromptSnapshots[el] then
            return
        end
        lQ.PromptSnapshots[el] = {
            HoldDuration = el.HoldDuration,
            MaxActivationDistance = el.MaxActivationDistance,
            RequiresLineOfSight = el.RequiresLineOfSight
        }
        el.HoldDuration = 0
        el.MaxActivationDistance = 50
        el.RequiresLineOfSight = false
    end
    for i, descendant in ipairs(l0:GetDescendants()) do
        qP(descendant)
    end
    lQ.PromptConn = l0.DescendantAdded:Connect(function(eq)
        if lQ.InstantPrompt then
            qP(eq)
        end
    end)
end
lI.SetFly = function(et)
    local bodyVelocity
    local q9 = et and true or false
    lQ.Fly = q9
    if lQ.FlyConn then
        lQ.FlyConn:Disconnect()
        lQ.FlyConn = nil
    end
    local q8_1 = lJ()
    local q9_1 = mx()
    if lQ.FlyBody then
        lQ.FlyBody:Destroy()
        lQ.FlyBody = nil
    end
    if not lQ.Fly then
        if q8_1 and lQ.FlyPriorPlatformStand ~= nil then
            q8_1.PlatformStand = lQ.FlyPriorPlatformStand
            lQ.FlyPriorPlatformStand = nil
        end
        return
    end
    if not (q8_1 and q9_1) then
        return
    end
    lQ.FlyPriorPlatformStand = q8_1.PlatformStand
    q8_1.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = q9_1
    lQ.FlyBody = bodyVelocity
    lQ.FlyConn = lD.RunService.RenderStepped:Connect(function()
        local q4 = not mf() or not lQ.Fly or not bodyVelocity.Parent
        if q4 then
            return
        end
        if lD.UserInputService:GetFocusedTextBox() then
            bodyVelocity.Velocity = Vector3.zero
            return
        end
        local CurrentCamera = l0.CurrentCamera
        if not CurrentCamera then
            bodyVelocity.Velocity = Vector3.zero
            return
        end
        local q5 = Vector3.zero
        if lD.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            q5 += CurrentCamera.CFrame.LookVector
        end
        if lD.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            q5 -= CurrentCamera.CFrame.LookVector
        end
        if lD.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            q5 -= CurrentCamera.CFrame.RightVector
        end
        if lD.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            q5 += CurrentCamera.CFrame.RightVector
        end
        if lD.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            q5 += Vector3.new(0, 1, 0)
        end
        if lD.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            q5 -= Vector3.new(0, 1, 0)
        end
        if q5.Magnitude > 0 then
            bodyVelocity.Velocity = q5.Unit * lQ.FlySpeed
        else
            bodyVelocity.Velocity = Vector3.zero
        end
    end)
end
lI.SetFlySpeed = fn573
mn = fn119
lQ.CharAddedConn = mI.CharacterAdded:Connect(onCharacterAdded)
lI.Track(fn340)
lL = fn759
ms = fn469
mh = fn749
lW = fn480
mB = "#7fd47f"
mw = "#6ec1ff"
mq = "#e8a34d"
Library2 = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles, Options = Library2.Toggles, Library2.Options
mS_2(lI, Library2)
local Window = Library2:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = l2, Copyable = true }, "|", mc, "|", mV },
    Icon = 132608042600488,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
lE = {}
lE.Info = Window:AddTab("Info", "info")
lE.Main = Window:AddTab("Main", "gamepad-2")
lE.Player = Window:AddTab("Player", "person-standing")
lE.Settings = Window:AddTab("Settings", "settings")
mK = fn507
local function m_()
    local fs
    local fx
    fs = "Unknown"
    pcall(function()
        local rr_1
        local rq_1
        if type(identifyexecutor) == "function" then
            rr_1, rq_1 = identifyexecutor()
            local rs = rr_1 ~= ""
            local rt = type(rr_1) == "string" and rs
            if rt then
                local rs_1 = type(rq_1) == "string" and rq_1 ~= "" and rr_1 .. " " .. rq_1
                fs = rs_1 or rr_1
            end
        end
    end)
    fx = os.clock()
    local function fy()
        local rB = math.floor(os.clock() - fx)
        if rB < 60 then
            return rB .. "s"
        elseif rB < 3600 then
            return string.format("%dm %ds", math.floor((rB) / (60)), rB % 60)
        else
            return string.format("%dh %dm", math.floor((rB) / (3600)), math.floor((rB % 3600) / (60)))
        end
    end
    local UserGroup = lE.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = mI, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(lW("User", mI.DisplayName .. " @" .. mI.Name, mB), true)
    UserGroup:AddLabel(lW("UserId", tostring(mI.UserId), mw), true)
    UserGroup:AddLabel(lW("Executor", fs, mB), true)
    UserGroup:AddDivider()
    local Label5 = UserGroup:AddLabel(lW("Session", fy(), mq), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            lL(mI.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            lL("https://www.roblox.com/users/" .. tostring(mI.UserId) .. "/profile", "Copied profile link")
        end
    })
    local DiscordGroup = lE.Info:AddRightGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = l2,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    local SessionGroup = lE.Info:AddRightGroupbox("Session", "signal")
    local Label4 = SessionGroup:AddLabel(lW("Game", mc, mB), true)
    local Label3 = SessionGroup:AddLabel(lW("Players", tostring(#lD.Players:GetPlayers()), mw), true)
    local Label2 = SessionGroup:AddLabel(lW("Job", string.sub(game.JobId, 1, 8) .. "...", mq), true)
    local Label = SessionGroup:AddLabel(lW("Ping", "0 ms", mB), true)
    SessionGroup:AddButton({
        Text = "Rejoin Place",
        Func = function()
            pcall(function()
                lD.TeleportService:Teleport(game.PlaceId, mI)
            end)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            lL(game.JobId, "Copied Job ID")
        end
    })
    local SocialsGroup = lE.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({
        Text = "Copy Discord",
        Func = function()
            lL(l2, "Copied Discord")
        end
    })
    SocialsGroup:AddButton({
        Text = "Copy Rscripts",
        Func = function()
            lL(lX, "Copied Rscripts")
        end
    })
    SocialsGroup:AddButton({
        Text = "Copy Website",
        Func = function()
            lL(lP, "Copied Website")
        end
    })
    task.spawn(function()
        local rG = false
        repeat
            local rD
            if mf() then
                Label5:SetText(lW("Session", fy(), mq))
                Label3:SetText(lW("Players", tostring(#lD.Players:GetPlayers()), mw))
                rD = 0
                pcall(function()
                    rD = math.floor(lD.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                Label:SetText(lW("Ping", tostring(rD) .. " ms", mB))
                Label4:SetText(lW("Game", mc, mB))
                Label2:SetText(lW("Job", string.sub(game.JobId, 1, 8) .. "...", mq))
                task.wait(1)
            else
                rG = true
            end
        until rG
    end)
end
lO = {
    AntiAfk = true,
    NoGameplayPaused = true,
    AutoReconnect = false,
    Disable3D = false,
    FpsBoost = false,
    AfkConn = nil,
    AfkTask = nil,
    AfkCount = 0,
    ReconnectConns = {},
    FpsSnapshots = {},
    FpsConn = nil,
    PausedConn = nil
}
local function mQ_1()
    local function ha()
        if not l0.CurrentCamera then
            return false
        end
        local rH_1 = not mr(lD.VirtualUser.CaptureController) or not mr(lD.VirtualUser.ClickButton2)
        if rH_1 then
            return false
        end
        local rH_2 = pcall(function()
            lD.VirtualUser:CaptureController()
            lD.VirtualUser:ClickButton2(Vector2.new())
        end)
        if rH_2 then
            lO.AfkCount = lO.AfkCount + 1
        end
        return rH_2
    end
    lI.SetAntiAfk = function(hn)
        local rS = hn and true or false
        lO.AntiAfk = rS
        if lO.AfkConn then
            lO.AfkConn:Disconnect()
            lO.AfkConn = nil
        end
        if lO.AfkTask then
            pcall(task.cancel, lO.AfkTask)
            lO.AfkTask = nil
        end
        if not lO.AntiAfk then
            return
        end
        lO.AfkConn = mI.Idled:Connect(function()
            local rM = mf() and lO.AntiAfk
            if rM then
                ha()
            end
        end)
        lO.AfkTask = task.spawn(function()
            local rO = os.clock()
            while true do
                local rP = mf() and lO.AntiAfk
                if rP then
                    task.wait(1)
                    local rP_1 = not mf() or not lO.AntiAfk
                    if rP_1 then
                        break
                    end
                    if os.clock() - rO >= 60 then
                        rO = os.clock()
                        ha()
                    end
                    continue
                end
                break
            end
        end)
    end
    lI.SetNoGameplayPaused = function(hF)
        local r9
        local sb = hF and true or false
        lO.NoGameplayPaused = sb
        if lO.PausedConn then
            lO.PausedConn:Disconnect()
            lO.PausedConn = nil
        end
        if not lO.NoGameplayPaused then
            return
        end
        r9 = function()
            pcall(function()
                local RobloxGui = lD.CoreGui:FindFirstChild("RobloxGui")
                local rY = RobloxGui and RobloxGui:FindFirstChild("Notifications")
                if rY then
                    for i, descendant in ipairs(rY:GetDescendants()) do
                        local rX_2 = descendant:IsA("TextLabel") and string.find(string.lower(descendant.Text), "gameplay paused")
                        if rX_2 then
                            local Frame = descendant:FindFirstAncestorOfClass("Frame")
                            if Frame then
                                Frame.Visible = false
                            end
                        end
                    end
                end
            end)
        end
        r9()
        lO.PausedConn = lD.CoreGui.DescendantAdded:Connect(function()
            if lO.NoGameplayPaused then
                r9()
            end
        end)
    end
    lI.SetAutoReconnect = function(hU)
        local sm = hU and true or false
        lO.AutoReconnect = sm
        for i, v in ipairs(lO.ReconnectConns) do
            v:Disconnect()
        end
        table.clear(lO.ReconnectConns)
        if not lO.AutoReconnect then
            return
        end
        table.insert(lO.ReconnectConns, lD.TeleportService.TeleportInitFailed:Connect(function()
            local sg = not mf()
            local sk = if sg then 1 else 0
            local si = 1387 * sk + 3509 * (1 - sk)
            local sj = 3083 * sk + 1205 * (1 - sk)
            if not ((si * 3042 + sj * 3382 + si * sj) % 16777213 == 2144868) then
                sg = not lO.AutoReconnect
            end
            if sg then
                return
            end
            task.wait(1)
            local sg_1 = mf() and lO.AutoReconnect
            if sg_1 then
                pcall(function()
                    lD.TeleportService:Teleport(game.PlaceId, mI)
                end)
            end
        end))
    end
    lI.SetDisable3D = function(h8)
        local sv = h8 and true or false
        lO.Disable3D = sv
        pcall(function()
            lD.RunService:Set3dRenderingEnabled(not lO.Disable3D)
        end)
    end
    lI.SetFpsBoost = function(ie)
        local sU
        local sW = ie and true or false
        lO.FpsBoost = sW
        if lO.FpsConn then
            lO.FpsConn:Disconnect()
            lO.FpsConn = nil
        end
        local function sV_1()
            for k, v in pairs(lO.FpsSnapshots) do
                local sC = k
                if sC and sC.Parent then
                    for k, v in pairs(v) do
                        local sI = k
                        local sK = v
                        pcall(function()
                            sC[sI] = sK
                        end)
                    end
                end
            end
            table.clear(lO.FpsSnapshots)
        end
        if not lO.FpsBoost then
            sV_1()
            return
        end
        sU = function(it)
            if lO.FpsSnapshots[it] then
                return
            end
            local sL = (it:IsA("ParticleEmitter"))
            local sP = if sL then 1 else 0
            local sN = 311 * sP + 1102 * (1 - sP)
            local sO = 2597 * sP + 2518 * (1 - sP)
            if not ((sN * 657 + sO * 265 + sN * sO) % 16777213 == 1700199) then
                sL = it:IsA("Trail")
            end
            if not sL then
                sL = it:IsA("Beam")
            end
            local sS = if sL then 1 else 0
            local sQ = 732 * sS + 2804 * (1 - sS)
            local sR = 1108 * sS + 3230 * (1 - sS)
            if not ((sQ * 3168 + sR * 3888 + sQ * sR) % 16777213 == 7437936) then
                sL = it:IsA("Fire")
            end
            if not sL then
                sL = it:IsA("Smoke")
            end
            if not sL then
                sL = it:IsA("Sparkles")
            end
            if sL then
                lO.FpsSnapshots[it] = { Enabled = it.Enabled }
                it.Enabled = false
            end
        end
        for i, descendant in ipairs(l0:GetDescendants()) do
            sU(descendant)
        end
        if lO.FpsSnapshots[lD.Lighting] == nil then
            lO.FpsSnapshots[lD.Lighting] = { GlobalShadows = lD.Lighting.GlobalShadows, FogEnd = lD.Lighting.FogEnd }
            lD.Lighting.GlobalShadows = false
        end
        lO.FpsConn = l0.DescendantAdded:Connect(function(iA)
            if lO.FpsBoost then
                sU(iA)
            end
        end)
    end
    lI.Track(function()
        lI.SetAntiAfk(false)
        lI.SetNoGameplayPaused(false)
        lI.SetAutoReconnect(false)
        lI.SetDisable3D(false)
        lI.SetFpsBoost(false)
    end)
end
if (not mi or ml) and (not mi or mi) and (leaderstats and not ml and (not mi and leaderstats)) and not ((not mi or ml) and (not mi or mi) and (leaderstats and not ml and (not mi and leaderstats))) then
    fn824()
    mQ_1()
    fn419()
    fn858()
    m_()
else
    m_()
    fn419()
    fn858()
    mQ_1()
    fn824()
end
end)(...)
