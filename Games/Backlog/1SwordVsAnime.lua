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
getgenv().TempoHoodSubtitle = "+1 SWORD VS ANIME"
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
local qw
local State
local qS
local qz
local rg
local qV
local qY
local rj
local qF
local q0
local qI
local qp
local LocalPlayer
local CoreGui
local q9
local qv
local qy
local rf
local ri
local qE
local qH
local q2
local qo
local qK
local q5
local qr
local q8
local qN
local qQ
local qT
local re
local qA
local qW
local qG
local q1
local qn
local Services
local qJ
local qq
local qM
local qt
local ra
local function fn3()
    local Character = LocalPlayer.Character
    local sx = Character and Character:FindFirstChild("HumanoidRootPart")
    return sx
end
local function fn16(cF, cG)
    for i, v in ipairs(qp) do
        local t2 = type(v) == "table" and not cF[i]
        if t2 then
            local t2_1 = i - 1
            local ue = 1
            while ue <= t2_1 do
                if not cF[ue] then
                    return nil
                end
                ue += 1
            end
            local max = math.max
            local t3 = tonumber(v.needNum) or 0
            local t4 = max(t3, 0)
            if t4 <= cG then
                return i
            end
            return nil
        end
    end
    return nil
end
local function fn111(dY)
    local WinTouchPartFolder = rg:FindFirstChild("WinTouchPartFolder")
    if not WinTouchPartFolder then
        return nil
    end
    local vg = WinTouchPartFolder:FindFirstChild("DefaultWin" .. tostring(dY))
    local vf_1 = vg and vg:IsA("Model")
    if not vf_1 then
        return nil
    end
    local HitBox = vg:FindFirstChild("HitBox")
    local vg_1 = HitBox and HitBox:IsA("BasePart")
    if vg_1 then
        return HitBox
    end
    return nil
end
local function fn141(cV)
    if type(cV) ~= "table" then
        return "Unknown"
    end
    local us = cV.name or "Aura " .. tostring(cV.id)
    local ut = tostring(us)
    local us_1 = cV.levelName or ""
    local uu = tostring(us_1)
    if uu ~= "" then
        return ut .. " (" .. uu .. ")"
    end
    return ut
end
local function fn143(cu)
    local SwordInit = LocalPlayer:FindFirstChild("SwordInit")
    local tW_1
    local tX = SwordInit and SwordInit:IsA("NumberValue")
    local tX_1
    if not tX then
        return false, "SwordInit missing"
    end
    SwordInit.Value = cu
    tW_1, tX_1 = qG(rf.BuySword, cu)
    if not tW_1 then
        return false, tX_1
    end
    local tW_2 = type(tX_1) == "table" and tX_1.Status
    local tY = tW_2 or tX_1
    local tX_2 = tY == "Owned"
    local tY_1 = tY == "Purchased"
    local t1 = if tY_1 then 1 else 0
    local t_ = 2709 * t1 + 1271 * (1 - t1)
    local t0 = 3140 * t1 + 2683 * (1 - t1)
    if not ((t_ * 3571 + t0 * 3356 + t_ * t0) % 16777213 == 11940726) then
        tY_1 = tX_2
    end
    if tY_1 then
        return true, tY
    end
    return false, tY
end
local function fn149(bo)
    local sX = typeof(bo) ~= "Instance" or not bo:IsA("BasePart")
    if sX then
        return false
    end
    local Character = LocalPlayer.Character
    local sY = not Character or not qI(firetouchinterest)
    if sY then
        return false
    end
    local sY_1 = false
    for i, child in ipairs(Character:GetChildren()) do
        if child:IsA("BasePart") then
            local sZ = pcall(firetouchinterest, bo, child, 0)
            sY_1 = sY_1 or sZ
        end
    end
    task.wait(0.05)
    for i, child in ipairs(Character:GetChildren()) do
        if child:IsA("BasePart") then
            pcall(firetouchinterest, bo, child, 1)
        end
    end
    return sY_1
end
local function fn222()
    local ww = { "Best" }
    local wx = #ra
    local wB = 1
    while wB <= wx do
        local wC = wB
        table.insert(ww, "Train " .. tostring(wC))
        wB += 1
    end
    return ww
end
local function fn231()
    local vP = math.floor(qt("Rebirth"))
    local vP_3
    if vP + 1 == #rj then
        State.RebirthStatus = "Max rebirth"
        return
    end
    local vQ = rj[vP + 1]
    local vQ_2
    if type(vQ) ~= "table" then
        State.RebirthStatus = "No next rebirth"
        return
    end
    local vP_1 = tonumber(vQ.needNum) or 0
    local vP_2 = qt("Level")
    if vP_2 < vP_1 then
        State.RebirthStatus = string.format("Need level %s", tostring(vP_1))
        return
    end
    State.RebirthStatus = "Rebirthing"
    vP_3, vQ_2 = qG(rf.Rebirth)
    if vP_3 and vQ_2 == true then
        State.RebirthStatus = "Rebirth success"
    else
        State.RebirthStatus = "Rebirth blocked"
    end
end
local function fn275(af)
    local so_1
    local sn_1
    local sm = q8:FindFirstChild(af)
    assert(sm, af .. " missing")
    sn_1, so_1 = pcall(require, sm)
    local sm_1 = sn_1 and type(so_1) == "table"
    assert(sm_1, af .. " failed to load")
    return so_1
end
local function fn277(cN)
    local ui_1
    local uh_1
    ui_1, uh_1 = nil, -1
    for i, v in ipairs(qp) do
        local uj = cN[i] and type(v) == "table"
        if uj then
            local uj_1 = tonumber(v.attack) or 0
            if uj_1 > uh_1 then
                uh_1 = uj_1
                ui_1 = i
            end
        end
    end
    return ui_1
end
local function fn312()
    local wb_1
    local v8 = qt("Win")
    local v8_1
    local v9 = qS()
    local wa = q9(v9, v8)
    if wa then
        State.TrailStatus = "Buying trail " .. tostring(wa)
        v8_1, wb_1 = qG(rf.BuyTrail, wa)
        if v8_1 and (wb_1 == "Purchased" or wb_1 == "Owned") then
            v9[wa] = true
            qG(rf.EquipTrail, wa)
            State.TrailStatus = "Bought " .. tostring(wa)
        else
            State.TrailStatus = "Buy failed (" .. tostring(wb_1) .. ")"
            task.wait(1)
        end
        return
    end
    local v8_2 = qr(v9)
    if v8_2 then
        qG(rf.EquipTrail, v8_2)
        State.TrailStatus = "Best trail " .. tostring(v8_2)
    else
        State.TrailStatus = "No affordable trail"
    end
end
local function fn320()
    local Character = LocalPlayer.Character
    local sD = Character and Character:FindFirstChildOfClass("Humanoid")
    return sD
end
local function fn331()
    local uw = { "None" }
    for i, v in ipairs(q5) do
        if type(v) == "table" then
            table.insert(uw, qM(v))
        end
    end
    return uw
end
local function fn339(U)
    local sk = typeof(cloneref) == "function" and typeof(U) == "Instance"
    if sk then
        return cloneref(U)
    end
    return U
end
local function fn343(aF, aG)
    local st = Services:FindFirstChild(aF)
    if not st then
        return nil
    end
    local comm = st:FindFirstChild("__comm__")
    local st_1 = comm and comm:FindFirstChild("RF")
    local su_1 = st_1
    if st_1 then
        st_1 = su_1:FindFirstChild(aG)
    end
    return st_1
end
local function fn351(fO)
    local wf = fO ~= ""
    local wg = type(fO) == "string" and wf
    if wg then
        qQ.StopAt = fO
    end
end
local function fn357(X)
    return type(X) == "function"
end
local function fn381()
    local ts_1
    local tr_1
    local tq = {}
    tr_1, ts_1 = qG(rf.GetSword)
    local tt = tr_1 and type(ts_1) == "table"
    if tt then
        for i, v in ipairs(ts_1) do
            local tr_2 = tonumber(v)
            if tr_2 then
                tq[tr_2] = true
            end
        end
    end
    return tq
end
local function fn386()
    local u7 = qy()
    local u8 = qJ[u7]
    local u9 = type(u8) ~= "table" or #u8 == 0
    if u9 then
        return u7, nil, nil
    end
    local u9_1 = #u8
    local va = u8[u9_1]
    local u8_1 = va and va.addNum
    local va_1 = tonumber(u8_1) or 0
    return u7, u9_1, va_1
end
local function fn425(da)
    if type(da) ~= "table" then
        return false
    end
    local uO = tonumber(da.id)
    if uO and uO >= 4 and uO <= 9 then
        return qY("TrainModel" .. uO)
    elseif type(da.needName) ~= "string" then
        return false
    else
        local uO_1 = qy()
        local uP_1 = da["needNum" .. uO_1]
        if typeof(uP_1) ~= "number" then
            return false
        end
        local uO_2 = LocalPlayer:FindFirstChild(da.needName)
        local uQ = uO_2 and uO_2:IsA("NumberValue")
        if not uQ then
            return false
        end
        return uP_1 <= uO_2.Value
    end
end
local function fn484(fg)
    local vU = fg ~= ""
    local vV = type(fg) == "string" and vU
    if vV then
        qF.Selection = fg
    end
end
local function fn518(cj, ck, cl)
    for i, v in ipairs(qw) do
        local tM = type(v) == "table" and not cj[i]
        if tM then
            local floor = math.floor
            local tO_1 = tonumber(v.worldNum) or 0
            tM = floor(tO_1) == cl
        end
        if tM then
            tM = tostring(v.needName) ~= "Robux"
        end
        if tM then
            local tN_2 = tonumber(v.productId) or 0
            tM = tN_2 == 0
        end
        if tM then
            if (i - 1) % 11 + 1 > 1 and not cj[i - 1] then
                return nil
            end
            local max = math.max
            local tN_4 = tonumber(v.needNum) or 0
            local tO_2 = max(tN_4, 0)
            if tO_2 <= ck then
                return i
            end
            return nil
        end
    end
    return nil
end
local function fn588(aY)
    local sI = LocalPlayer:FindFirstChild(aY)
    local sJ = sI
    if sJ then
        local sK = sI:IsA("NumberValue") or sI:IsA("IntValue")
        sJ = sK
    end
    if sJ then
        local sJ_1 = tonumber(sI.Value) or 0
        return sJ_1
    end
    return 0
end
local function fn601()
    return not q0.Unloaded
end
local function fn619(a4)
    local sM = LocalPlayer:FindFirstChild(a4)
    local sN = sM ~= nil and sM:IsA("BoolValue") and sM.Value == true
    return sN
end
local function fn639()
    local vC_1
    local vB_1
    local vA_1
    vC_1, vA_1, vB_1 = re()
    if not vA_1 then
        State.WinStatus = string.format("World %d | No eligible win", vC_1)
        return
    end
    local vD = qA(vA_1)
    if not vD then
        State.WinStatus = string.format("World %d | Win pad missing", vC_1)
        return
    end
    local vA_2 = qt("Win")
    State.WinStatus = string.format("World %d | Claiming +%s", vC_1, tostring(vB_1))
    qo(vD, 3)
    task.wait(0.12)
    qq(vD)
    local vE = os.clock() + 1.25
    while true do
        local vF = qz() and WinController.Enabled and os.clock() < vE
        if vF then
            if qy() ~= vC_1 then
                State.WinStatus = string.format("World %d | World changed", qy())
                return
            end
            if qt("Win") > vA_2 then
                break
            end
            qq(vD)
            task.wait(0.1)
            continue
        end
        State.WinStatus = string.format("World %d | Waiting +%s", vC_1, tostring(vB_1))
        return
    end
    State.WinStatus = string.format("World %d | Claimed +%s", vC_1, tostring(vB_1))
    task.wait(0.35)
    return
end
local function fn656()
    local tD_1
    local tC_1
    local tB = {}
    tC_1, tD_1 = qG(rf.GetTrail)
    local tE = tC_1 and type(tD_1) == "table"
    if tE then
        for i, v in ipairs(tD_1) do
            local tC_2 = tonumber(v)
            if tC_2 then
                tB[tC_2] = true
            end
        end
    end
    local tC_3 = math.floor(qt("TrailInit"))
    if tC_3 > 0 then
        tB[tC_3] = true
    end
    return tB
end
local function fn675()
    qT.SetEnabled(false)
    qH.SetEnabled(false)
    qK.SetEnabled(false)
    qF.SetEnabled(false)
    qW.SetEnabled(false)
    qQ.SetEnabled(false)
end
local function fn712()
    local vK = qy()
    local vK_1
    local vL = qt("Win")
    local vL_1
    local vM = qE()
    local vN = qV(vM, vL, vK)
    if not vN then
        State.SwordStatus = "No affordable sword"
        return
    end
    State.SwordStatus = "Buying sword " .. tostring(vN)
    vK_1, vL_1 = q1(vN)
    if vK_1 then
        qG(rf.EquipSword, vN)
        State.SwordStatus = "Bought " .. tostring(vN)
    else
        State.SwordStatus = "Buy failed (" .. tostring(vL_1) .. ")"
        task.wait(1)
    end
end
local function fn735(dt)
    local uY_2, uY_3
    local uX_2, uX_3
    local uW_2, uW_3
    local TrainModelFolder = rg:FindFirstChild("TrainModelFolder")
    if not TrainModelFolder then
        return nil, nil
    elseif type(dt) == "string" then
        local uW_1 = tonumber(dt:match("(%d+)$"))
        if uW_1 then
            local uX_1 = TrainModelFolder:FindFirstChild("TrainModel" .. uW_1)
            local uY_1 = ra[uW_1]
            local uZ_1 = uX_1 and qn(uY_1)
            if uZ_1 then
                return uX_1, uW_1
            end
            return nil, uW_1
        end
        uY_2, uX_2, uW_2 = nil, nil, -1
        for i, child in ipairs(TrainModelFolder:GetChildren()) do
            if child:IsA("Model") then
                local uV_1 = tonumber(string.match(child.Name, "(%d+)$"))
                local uZ_2 = uV_1 and ra[uV_1]
                local u__1 = uZ_2
                if uZ_2 then
                    uZ_2 = qn(u__1)
                end
                if uZ_2 then
                    local uZ_3 = qv(u__1)
                    if uZ_3 > uW_2 then
                        uW_2 = uZ_3
                        uY_2 = child
                        uX_2 = uV_1
                    end
                end
            end
        end
        return uY_2, uX_2
    else
        uY_3, uX_3, uW_3 = nil, nil, -1
        for i, child in ipairs(TrainModelFolder:GetChildren()) do
            if child:IsA("Model") then
                local uV_2 = tonumber(string.match(child.Name, "(%d+)$"))
                local uZ_4 = uV_2 and ra[uV_2]
                local u__2 = uZ_4
                if uZ_4 then
                    uZ_4 = qn(u__2)
                end
                if uZ_4 then
                    local uZ_5 = qv(u__2)
                    if uZ_5 > uW_3 then
                        uW_3 = uZ_5
                        uY_3 = child
                        uX_3 = uV_2
                    end
                end
            end
        end
        return uY_3, uX_3
    end
end
local function fn798(dl)
    if type(dl) ~= "table" then
        return 0
    end
    local uS = tonumber(dl.id)
    if uS and uS >= 4 then
        local uS_1 = tonumber(dl.attack) or 0
        return uS_1
    end
    local uS_2 = qy()
    local uT_1 = tonumber(dl["attack" .. uS_2]) or tonumber(dl.attack)
    return uT_1 or 0
end
local function fn829()
    gethui = ri
end
local function fn931()
    local vi = math.max(math.floor(qt("BuyWorld")), 1)
    local vj = q2[1]
    local vk = -math.huge
    for i, v in ipairs(q2) do
        local floor = math.floor
        local vm = tonumber(v.world) or tonumber(v.id)
        local vn = vm or 1
        local vm_1 = floor(vn)
        if vm_1 <= vi and vm_1 > vk then
            vj = v
            vk = vm_1
        end
    end
    return vj
end
local function fn937(c4)
    local uE = c4 == ""
    local uF = type(c4) ~= "string" or uE
    if uF or c4 == "None" then
        return nil
    end
    for i, v in ipairs(q5) do
        if qM(v) == c4 then
            local uE_2 = tonumber(v.id) or i
            return uE_2
        end
    end
    return nil
end
local function fn982()
    return CoreGui
end
local function fn1008()
    local GameScene = LocalPlayer:FindFirstChild("GameScene")
    local sQ = GameScene
    if sQ then
        local sR_1 = GameScene:IsA("NumberValue") or GameScene:IsA("IntValue")
        sQ = sR_1
    end
    if sQ then
        return math.clamp(math.floor(GameScene.Value), 1, qN)
    end
    local CurrentWorld = LocalPlayer:FindFirstChild("CurrentWorld")
    local sQ_1 = CurrentWorld
    if sQ_1 then
        local sR_2 = (CurrentWorld:IsA("NumberValue"))
        local sV = if sR_2 then 1 else 0
        local sT = 3773 * sV + 3399 * (1 - sV)
        local sU = 2753 * sV + 3813 * (1 - sV)
        if not ((sT * 3549 + sU * 2716 + sT * sU) % 16777213 == 14477381) then
            sR_2 = CurrentWorld:IsA("IntValue")
        end
        sQ_1 = sR_2
    end
    if sQ_1 then
        return math.clamp(math.floor(CurrentWorld.Value), 1, qN)
    end
    return 1
end
qn = nil
qo = nil
qp = nil
qq = nil
qr = nil
LocalPlayer = nil
qt = nil
qv = nil
qw = nil
qy = nil
qz = nil
qA = nil
qE = nil
qF = nil
qG = nil
qH = nil
qI = nil
qJ = nil
qK = nil
qM = nil
qN = nil
CoreGui = nil
qQ = nil
qS = nil
qT = nil
qV = nil
qW = nil
qY = nil
q0 = nil
q1 = nil
q2 = nil
Services = nil
q5 = nil
q8 = nil
local Players, qu, qx, qB, qC, Lighting, TeleportService, qP, qR, GuiService, qX, qZ, HttpService, VirtualUser, UserInputService, q7
q9 = nil
ra = nil
State = nil
re = nil
rf = nil
rg = nil
ri = nil
rj = nil
local RunService, rc, rh
local rt_1
local rs_1
local rr_1
local rq_1
local rp_1, rp_2
local ro_1, ro_2
local rC = if not game:IsLoaded() then 1 else 0
if rC == 1 then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, qB, LocalPlayer, ri = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local rm = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
qB = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local rl = "TempoSwordVsAnime"
ri = fn982
if getgenv then
    getgenv().gethui = ri
end
q0, rs_1, rg, State, q8, qw, qp, rj, rr_1, ra, q5, q2, rt_1, qN, qJ, rq_1, qC, ro_1, qI, qz, rp_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local rk = 62
repeat
    local ru = (rk * 11 + 17) % 18 + 1
    if ru <= 9 then
        if ru <= 5 then
            if ru <= 3 then
                if ru <= 2 then
                    if ru <= 1 then
                        local rv_1 = {
                            "yjiluwsyq",
                            "rqa",
                            "dkqyhcqrpp",
                            "yzsrekdogjmb",
                            "yrifqpwxdrme",
                            "lburtlwpaag",
                            "bnjuyuvauxe",
                            "oevbj",
                            "jtsyrizkky",
                            "fctzcms",
                            "wbvdnlfs",
                            "frrhczpww",
                            "iltlbiekeqj"
                        }
                        if rv_1[(rk * 59 + 61) % 13 + 1] <= rv_1[(rk * 59 + 61) % 13 + 1] then
                            ro_1 = fn339
                        else
                            q2 = fn339
                        end
                        rk = (rk + 41) % 72
                    else
                        local rv_2 = {
                            "xmerjxbcdzm",
                            "bfxqmbzheoxk",
                            "etysa",
                            "xphs",
                            "loiptjevk",
                            "mjnbybesxuzy",
                            "vdr",
                            "vrm",
                            "nrbu"
                        }
                        if rv_2[(rk * 5 + 6) % 9 + 1] < rv_2[(rk * 5 + 6) % 9 + 1] then
                            qz = fn357
                            qI = fn601
                        else
                            qI = fn357
                            qz = fn601
                        end
                        rk = (rk + 41) % 72
                    end
                else
                    local rv_3 = (vector.create((rk * 1 + 1) % 11 + 1, (rk * 4 + 10) % 13 + 1, (rk * 14 + 10) % 17 + 1))
                    local rw_1 = (vector.create((rk * 3 + 6) % 11 + 1, (rk * 8 + 6) % 13 + 1, (rk * 15 + 8) % 17 + 1))
                    local B2 = vector.cross(rv_3, rw_1)
                    local B3 = vector.dot(rv_3, rw_1)
                    if vector.dot(B2, B2) + B3 * B3 == vector.dot(rv_3, rv_3) * vector.dot(rw_1, rw_1) then
                        rs_1 = ro_1(rm)
                    else
                        rm = rs_1(ro_1)
                    end
                    rk = (rk + 41) % 72
                end
            elseif ru <= 4 then
                local C2 = bit32.rrotate(bit32.bxor(bit32.lrotate(rk, 22), string.byte(tostring(ra))), 20)
                if bit32.bxor(bit32.lrotate(bit32.bxor(C2, 724110295), 26), 1554818095) ~= bit32.lrotate(C2, 26) then
                    qB = rg(ro_1)
                else
                    rg = ro_1(qB)
                end
                rk = (rk + 59) % 72
            else
                if rk * 65654165 + 1 + 3 <= rk * 65654165 + 1 + 3 + 1 then
                    State = q0.State
                else
                    q0 = State.State
                end
                rk = (rk + 5) % 72
            end
        elseif ru <= 7 then
            if ru <= 6 then
                local rv_4 = {
                    "iuazvppfllig",
                    "xlebgcuxjm",
                    "hvrysxydyo",
                    "qjliocrbvjpd",
                    "psiaz",
                    "tfzduflztq",
                    "rstycwcq",
                    "fbsswnvxygf"
                }
                if rv_4[(rk * 79 + 1) % 8 + 1] <= rv_4[(rk * 79 + 1) % 8 + 1] then
                    State.WinStatus = "Idle"
                    State.SwordStatus = "Idle"
                    State.RebirthStatus = "Idle"
                    State.TrainStatus = "Idle"
                    State.TrailStatus = "Idle"
                    State.AuraStatus = "Idle"
                    q8 = rs_1:WaitForChild("Config", 30)
                else
                    q8.WinStatus = "Idle"
                    q8.SwordStatus = "Idle"
                    q8.RebirthStatus = "Idle"
                    q8.TrainStatus = "Idle"
                    q8.TrailStatus = "Idle"
                    q8.AuraStatus = "Idle"
                    rs_1 = State:WaitForChild("Config", 30)
                end
                rk = (rk + 5) % 72
            else
                local rv_5 = (vector.create((rk * 1 + 2) % 11 + 1, (rk * 1 + 2) % 13 + 1, (rk * 12 + 12) % 17 + 1))
                local rw_2 = (vector.create((rk * 7 + 6) % 11 + 1, (rk * 5 + 5) % 13 + 1, (rk * 8 + 6) % 17 + 1))
                local rx_1 = (vector.create((rk * 5 + 6) % 11 + 1, (rk * 5 + 3) % 13 + 1, (rk * 8 + 15) % 17 + 1))
                local ry = (vector.create((rk * 1 + 2) % 11 + 1, (rk * 2 + 11) % 13 + 1, (rk * 7 + 7) % 17 + 1))
                if vector.dot(vector.cross(rv_5, rw_2), (vector.cross(rx_1, ry))) == vector.dot(rv_5, rx_1) * vector.dot(rw_2, ry) - vector.dot(rv_5, ry) * vector.dot(rw_2, rx_1) + 1 then
                    assert(rp_1, "Config folder missing")
                    q8 = fn275
                else
                    assert(q8, "Config folder missing")
                    rp_1 = fn275
                end
                rk = (rk + 23) % 72
            end
        elseif ru <= 8 then
            local rv_6 = (vector.create((rk * 1 + 2) % 11 + 1, (rk * 6 + 7) % 13 + 1, (rk * 7 + 16) % 17 + 1))
            local rw_3 = (vector.create((rk * 5 + 8) % 11 + 1, (rk * 3 + 6) % 13 + 1, (rk * 9 + 8) % 17 + 1))
            local CY = vector.cross(rv_6, rw_3)
            local CZ = vector.dot(rv_6, rw_3)
            if vector.dot(CY, CY) + CZ * CZ == vector.dot(rv_6, rv_6) * vector.dot(rw_3, rw_3) then
                qw = rp_1("SwordConfig")
            else
                rp_1 = qw("SwordConfig")
            end
            rk = (rk + 23) % 72
        else
            local rv_7 = {
                "teqynzxjhvz",
                "mpjjiqqjmria",
                "qxfh",
                "ikywgr",
                "finnkumrbj",
                "iwfvarqu",
                "mzbn",
                "ohwlxhz",
                "ftyswxeovty",
                "ceanec",
                "bjpghilbcrz",
                "vysh",
                "zsolkalnfi"
            }
            if rv_7[(rk * 58 + 62) % 13 + 1] <= rv_7[(rk * 58 + 62) % 13 + 1] then
                qp = rp_1("TrailConfig")
                rj = rp_1("RebirthConfig")
            else
                rj = qp("TrailConfig")
                rp_1 = qp("RebirthConfig")
            end
            rk = (rk + 59) % 72
        end
    elseif ru <= 14 then
        if ru <= 12 then
            if ru <= 11 then
                if ru <= 10 then
                    local B1 = bit32.rrotate(bit32.bxor(bit32.lrotate(rk, 18), string.byte(tostring(rg))), 8)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(B1, 3849586315), 996028640), (bit32.bxor(bit32.band(B1, 445380980), 3483164457))), 996028640), 3483164457) == B1 then
                        rr_1 = rp_1("LevelWinConfig")
                    else
                        rp_1 = rr_1("LevelWinConfig")
                    end
                    rk = (rk + 23) % 72
                else
                    if (rk * 2 + 1) * 7 % 3 == ((rk * 2 + 1) * 7 + 3) % 3 then
                        ra = rp_1("TrainConfig")
                    else
                        rp_1 = ra("TrainConfig")
                    end
                    rk = (rk + 41) % 72
                end
            else
                if (rk * 1 + 4) * 9 % 4 == ((rk * 1 + 4) * 9 + 8) % 4 then
                    q5 = rp_1("AuraConfig")
                    q2 = rp_1("DrawAuraConfig")
                else
                    rp_1 = q2("AuraConfig")
                    q5 = q2("DrawAuraConfig")
                end
                rk = (rk + 41) % 72
            end
        elseif ru <= 13 then
            local rv_8 = {
                "iblocpgwn",
                "dbosxzdyep",
                "knv",
                "pjhpgqiyx",
                "vtued",
                "lcokvcjetia",
                "xjvuuimrjbk",
                "ubwkwcm",
                "dttblto",
                "ggan"
            }
            if rv_8[(rk * 12 + 64) % 10 + 1] <= rv_8[(rk * 12 + 64) % 10 + 1] then
                rt_1 = rp_1("TrainClickBonusConfig")
            else
                rp_1 = rt_1("TrainClickBonusConfig")
            end
            rk = (rk + 23) % 72
        else
            local rv_9 = (vector.create((rk * 7 + 3) % 11 + 1, (rk * 1 + 1) % 13 + 1, (rk * 9 + 10) % 17 + 1))
            local rw_4 = (vector.create((rk * 7 + 8) % 11 + 1, (rk * 11 + 12) % 13 + 1, (rk * 14 + 10) % 17 + 1))
            local rx_2 = (vector.create((rk * 3 + 3) % 11 + 1, (rk * 6 + 2) % 13 + 1, (rk * 11 + 16) % 17 + 1))
            if vector.dot(vector.cross(rv_9, rw_4), rx_2) == vector.dot(vector.cross(rw_4, rx_2), rv_9) + 2 then
                rp_1 = qN("TeleportConfig")
                math.max(#rp_1, 1)
            else
                local rn_1 = rp_1("TeleportConfig")
                qN = math.max(#rn_1, 1)
            end
            rk = (rk + 41) % 72
        end
    elseif ru <= 16 then
        if ru <= 15 then
            local rv_10 = {
                "poqf",
                "jtzlqp",
                "yiihezuyba",
                "rkcsil",
                "qfhkzh",
                "tbc",
                "wrgsmlzjsa",
                "cqbdnyqgydc",
                "hylbjormeg"
            }
            local B0 = rk
            local rw_5 = rv_10[B0 % 9 + 1]
            if rw_5:len() >= rw_5:gsub("(.)", "%1%1", B0 % 3 % 2 + 1):len() then
                rq_1 = {}
            else
                qJ = {}
            end
            rk = (rk + 23) % 72
        else
            if ((not qN or not rj) and (rs_1 and rs_1) and (not ro_1 and rj or not rs_1 and not ro_1) or not rj and not ro_1 and (not qN or not ro_1) and ((rs_1 or not ra) and (qN or rj))) and ((ra and ra or (ra or not ra)) and (ra and ro_1 and (qN or ra)) or (rj and not rj and (not qN or not ro_1) or (ro_1 or not ro_1 or not rj and rs_1))) and not (((not qN or not rj) and (rs_1 and rs_1) and (not ro_1 and rj or not rs_1 and not ro_1) or not rj and not ro_1 and (not qN or not ro_1) and ((rs_1 or not ra) and (qN or rj))) and ((ra and ra or (ra or not ra)) and (ra and ro_1 and (qN or ra)) or (rj and not rj and (not qN or not ro_1) or (ro_1 or not ro_1 or not rj and rs_1)))) then
                pcall(fn829)
                qw = function(t)
                    local r4
                    local r2
                    local r3
                    r2 = nil
                    r3 = nil
                    r4 = nil
                    local r5 = t ~= ""
                    local r6 = type(t) == "string" and r5
                    assert(r6, "Atypical is required")
                    assert(type(getgenv) == "function", "getgenv is unavailable")
                    r2 = getgenv()
                    assert(type(r2) == "table", "getgenv did not return a table")
                    local r5_2 = r2[t]
                    if r5_2 ~= nil then
                        local r6_2 = type(r5_2) == "table" and type(r5_2.Unload) == "function"
                        assert(r6_2, "Namespace is occupied")
                        r5_2.Unload()
                        assert(r2[t] == nil, "Previous instance did not release its namespace")
                    end
                    r3 = {}
                    r4 = { State = {}, Unloaded = false }
                    r4.Track = function(z)
                        assert(type(z) == "function", "Cleanup must be callable")
                        if r4.Unloaded then
                            z()
                        else
                            table.insert(r3, z)
                        end
                        return z
                    end
                    r4.Unload = function()
                        local rW_2
                        local rV_2
                        if r4.Unloaded then
                            return
                        end
                        r4.Unloaded = true
                        local rT = {}
                        local r_ = #r3
                        local rZ = -1
                        while false and r_ <= 1 or true and r_ >= 1 do
                            local r0 = r_
                            local rU_2 = table.remove(r3, r0)
                            rV_2, rW_2 = pcall(rU_2)
                            if not rV_2 then
                                table.insert(rT, tostring(rW_2))
                            end
                            r_ += rZ
                        end
                        table.clear(r4.State)
                        if #rT > 0 then
                            error("Cleanup incomplete: " .. table.concat(rT, "; "), 0)
                        end
                        if r2[t] == r4 then
                            r2[t] = nil
                        end
                    end
                    r2[t] = r4
                    return r4
                end
            else
                pcall(fn829)
                rq_1 = function(t)
                    local r4
                    local r2
                    local r3
                    r2 = nil
                    r3 = nil
                    r4 = nil
                    local r5 = t ~= ""
                    local r6 = type(t) == "string" and r5
                    assert(r6, "Atypical is required")
                    assert(type(getgenv) == "function", "getgenv is unavailable")
                    r2 = getgenv()
                    assert(type(r2) == "table", "getgenv did not return a table")
                    local r5_1 = r2[t]
                    if r5_1 ~= nil then
                        local r6_1 = type(r5_1) == "table" and type(r5_1.Unload) == "function"
                        assert(r6_1, "Namespace is occupied")
                        r5_1.Unload()
                        assert(r2[t] == nil, "Previous instance did not release its namespace")
                    end
                    r3 = {}
                    r4 = { State = {}, Unloaded = false }
                    r4.Track = function(z)
                        assert(type(z) == "function", "Cleanup must be callable")
                        if r4.Unloaded then
                            z()
                        else
                            table.insert(r3, z)
                        end
                        return z
                    end
                    r4.Unload = function()
                        local rW_1
                        local rV_1
                        if r4.Unloaded then
                            return
                        end
                        r4.Unloaded = true
                        local rT = {}
                        local r_ = #r3
                        local rZ = -1
                        while false and r_ <= 1 or true and r_ >= 1 do
                            local r0 = r_
                            local rU_1 = table.remove(r3, r0)
                            rV_1, rW_1 = pcall(rU_1)
                            if not rV_1 then
                                table.insert(rT, tostring(rW_1))
                            end
                            r_ += rZ
                        end
                        table.clear(r4.State)
                        if #rT > 0 then
                            error("Cleanup incomplete: " .. table.concat(rT, "; "), 0)
                        end
                        if r2[t] == r4 then
                            r2[t] = nil
                        end
                    end
                    r2[t] = r4
                    return r4
                end
            end
            rk = (rk + 59) % 72
        end
    elseif ru <= 17 then
        local ru_1 = (vector.create((rk * 7 + 3) % 11 + 1, (rk * 11 + 6) % 13 + 1, (rk * 4 + 17) % 17 + 1))
        local rv_11 = (vector.create((rk * 6 + 6) % 11 + 1, (rk * 8 + 7) % 13 + 1, (rk * 9 + 3) % 17 + 1))
        local rw_6 = (vector.create((rk * 4 + 1) % 11 + 1, (rk * 5 + 6) % 13 + 1, (rk * 13 + 6) % 17 + 1))
        if vector.dot(vector.cross(ru_1, rv_11), rw_6) == vector.dot(vector.cross(rv_11, rw_6), ru_1) + 5 then
            qJ = function(M, N)
                local sf = type(M) == "table" and type(M.Track) == "function"
                assert(sf, "FeatureAPI required")
                local sf_2 = type(N) == "table" and type(N.OnUnload) == "function"
                assert(sf_2, "UI library required")
                assert(type(N.Unload) == "function", "UI unload required")
                M.Track(function()
                    if not N.Unloaded then
                        N:Unload()
                    end
                end)
                N:OnUnload(function()
                    M.Unload()
                end)
            end
        else
            qC = function(M, N)
                local sf = type(M) == "table" and type(M.Track) == "function"
                assert(sf, "FeatureAPI required")
                local sf_1 = type(N) == "table" and type(N.OnUnload) == "function"
                assert(sf_1, "UI library required")
                assert(type(N.Unload) == "function", "UI unload required")
                M.Track(function()
                    if not N.Unloaded then
                        N:Unload()
                    end
                end)
                N:OnUnload(function()
                    M.Unload()
                end)
            end
        end
        rk = (rk + 41) % 72
    else
        if (rk * 3 + 7) * 13 % 4 == ((rk * 3 + 7) * 13 + 14) % 4 then
            rl = q0(rq_1)
        else
            q0 = rq_1(rl)
        end
        rk = (rk + 23) % 72
    end
until (rk * 35 + 64) % 72 == 38
for i, v in ipairs(rr_1) do
    local max = math.max
    local floor = math.floor
    local rm_1 = tonumber(v.worldNum) or 1
    local rl_2 = max(floor(rm_1), 1)
    local rm_2 = qJ[rl_2] or {}
    qJ[rl_2] = rm_2
    table.insert(qJ[rl_2], v)
end
for k, v in pairs(qJ) do
    table.sort(v, function(aB, aC)
        local sq = tonumber(aB.id) or 0
        local sr = tonumber(aC.id) or 0
        return sq < sr
    end)
end
Services, rf = nil, nil
Services = rs_1:WaitForChild("Packages", 30):WaitForChild("Knit", 30):WaitForChild("Services", 30)
rf = {
    AddNum = fn343("PlayerService", "AddNum"),
    Rebirth = fn343("PlayerService", "Rebirth"),
    ClaimTrainClickBonus = fn343("PlayerService", "ClaimTrainClickBonus"),
    BuySword = fn343("SwordService", "BuySword"),
    EquipSword = fn343("SwordService", "EquipSword"),
    GetSword = fn343("SwordService", "GetSword"),
    SetFlyingSwordTrainingTarget = fn343("SwordService", "SetFlyingSwordTrainingTarget"),
    BuyTrail = fn343("TrailService", "BuyTrail"),
    EquipTrail = fn343("TrailService", "EquipTrail"),
    GetTrail = fn343("TrailService", "GetTrail"),
    DrawAura = fn343("AuraService", "DrawAura")
}
local max = math.max
local rk_3 = tonumber(rt_1.Interval) or 8
rc, qT, qH, qK, qF, qW, qQ, q7, qP, qt, qY, qy, qG, qq, qo, qx, qE, qS, qV, q1, q9, qr, qM, rh, qR, qn, qv, qZ, re, qA, qX, qu = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
rc = max(rk_3, 1)
q7 = fn3
qP = fn320
qt = fn588
if not qu and false and ((not qt or qQ) and (qM or qQ)) and (not qQ and qu and false or (not qM or false) and false) and not (not qu and false and ((not qt or qQ) and (qM or qQ)) and (not qQ and qu and false or (not qM or false) and false)) then
    qo = fn619
    qY = fn1008
    qq = function(bl, ...)
        if not bl then
            return false, "missing remote"
        end
        return pcall(function(...)
            return bl:InvokeServer(...)
        end, ...)
    end
    qG = fn149
    qy = function(bC, bD)
        local tg
        local th
        tg = nil
        th = nil
        th = q7()
        local ti = not th or typeof(bC) ~= "Instance" or not bC:IsA("BasePart")
        if ti then
            return false
        end
        local ti_3 = typeof(bD) == "number" and bD
        tg = ti_3 or 3
        local ti_4 = pcall(function()
            th.AssemblyLinearVelocity = Vector3.zero
            th.CFrame = bC.CFrame + Vector3.new(0, tg, 0)
        end)
        return ti_4
    end
else
    qY = fn619
    qy = fn1008
    qG = function(bl, ...)
        if not bl then
            return false, "missing remote"
        end
        return pcall(function(...)
            return bl:InvokeServer(...)
        end, ...)
    end
    qq = fn149
    qo = function(bC, bD)
        local tg
        local th
        tg = nil
        th = nil
        th = q7()
        local ti = not th or typeof(bC) ~= "Instance" or not bC:IsA("BasePart")
        if ti then
            return false
        end
        local ti_1 = typeof(bD) == "number" and bD
        tg = ti_1 or 3
        local ti_2 = pcall(function()
            th.AssemblyLinearVelocity = Vector3.zero
            th.CFrame = bC.CFrame + Vector3.new(0, tg, 0)
        end)
        return ti_2
    end
end
qx = function(bN, bO)
    local tm
    local tl
    tl = nil
    tm = nil
    local tn = typeof(bN) ~= "Instance" or not bN:IsA("Model")
    if tn then
        return false
    end
    tl = q7()
    if not tl then
        return false
    end
    local tn_1 = typeof(bO) == "number" and bO
    tm = tn_1 or 4
    local tn_2 = pcall(function()
        tl.AssemblyLinearVelocity = Vector3.zero
        tl.CFrame = bN:GetPivot() * CFrame.new(0, tm, 0)
    end)
    return tn_2
end
qE = fn381
qS = fn656
qV = fn518
q1 = fn143
q9 = fn16
qr = fn277
qM = fn141
rh = fn331
qR = fn937
qn = fn425
qv = fn798
qZ = fn735
re = fn386
qA = fn111
qX = fn931
local function rn_2(eg, eh, ei)
    local ej = { Enabled = false, Generation = 0 }
    ej.SetEnabled = function(ek)
        local Generation
        ek = ek == true
        if ej.Enabled == ek then
            return
        end
        ej.Enabled = ek
        ej.Generation = ej.Generation + 1
        Generation = ej.Generation
        if not ek then
            State[eg] = "Idle"
            return
        end
        task.spawn(function()
            local vw_1
            while true do
                local vv = qz() and ej.Enabled and ej.Generation == Generation
                local vv_1
                if vv then
                    vv_1, vw_1 = pcall(ei, ej)
                    if not vv_1 then
                        State[eg] = "Error"
                        warn("[Tempo] " .. eg .. ":", vw_1)
                        task.wait(1)
                    else
                        task.wait(eh)
                    end
                    continue
                end
                break
            end
            if ej.Generation == Generation then
                State[eg] = "Idle"
            end
        end)
    end
    return ej
end
qT = rn_2("WinStatus", 0.35, fn639)
qH = rn_2("SwordStatus", 0.75, fn712)
qK = rn_2("RebirthStatus", 0.6, fn231)
qF = { Enabled = false, Generation = 0, Selection = "Best", LastClaimAt = 0 }
qF.SetSelection = fn484
qF.SetEnabled = function(fi)
    local Generation
    fi = fi == true
    if qF.Enabled == fi then
        return
    end
    qF.Enabled = fi
    qF.Generation = qF.Generation + 1
    Generation = qF.Generation
    if not fi then
        qG(rf.SetFlyingSwordTrainingTarget, 0)
        State.TrainStatus = "Idle"
        return
    end
    task.spawn(function()
        local v0_1
        while true do
            local v_ = qz() and qF.Enabled and qF.Generation == Generation
            local v__1
            if v_ then
                v__1, v0_1 = qZ(qF.Selection)
                local v1 = v__1 and v0_1
                local v1_2
                if not v1 then
                    State.TrainStatus = "Train locked"
                    task.wait(0.8)
                    continue
                end
                local v1_1 = q7()
                if not v1_1 then
                    State.TrainStatus = "No character"
                    task.wait(0.5)
                    continue
                end
                local Position = v__1:GetPivot().Position
                local v2_1
                local v3 = v1_1.Position.X - Position.X
                local v4 = v1_1.Position.Z - Position.Z
                if v3 * v3 + v4 * v4 > 120 then
                    qx(v__1, 4)
                    task.wait(0.1)
                end
                State.TrainStatus = "Training " .. tostring(v0_1)
                qG(rf.SetFlyingSwordTrainingTarget, v0_1)
                local v__2 = os.clock()
                if v__2 - qF.LastClaimAt >= rc then
                    v1_2, v2_1 = qG(rf.ClaimTrainClickBonus, v0_1)
                    if v1_2 and v2_1 ~= false then
                        qF.LastClaimAt = v__2
                    else
                        if v1_2 and v2_1 == false then
                            qF.LastClaimAt = v__2
                        end
                    end
                end
                task.wait(0.25)
                continue
            end
            break
        end
        if qF.Generation == Generation then
            qG(rf.SetFlyingSwordTrainingTarget, 0)
            State.TrainStatus = "Idle"
        end
    end)
end
qW = rn_2("TrailStatus", 0.5, fn312)
qQ = { Enabled = false, Generation = 0, StopAt = "None", OnStop = nil }
qQ.SetStopAt = fn351
qQ.SetEnabled = function(fQ)
    local Generation
    fQ = fQ == true
    if qQ.Enabled == fQ then
        return
    end
    qQ.Enabled = fQ
    qQ.Generation = qQ.Generation + 1
    Generation = qQ.Generation
    if not fQ then
        State.AuraStatus = "Idle"
        return
    end
    task.spawn(function()
        while true do
            local wl_1 = qz() and qQ.Enabled and qQ.Generation == Generation
            if wl_1 then
                local wl_2 = qR(qQ.StopAt)
                local wm = math.floor(qt("AuraInit"))
                local wm_3
                local wn = wm == wl_2
                local wn_4
                if wl_2 and wn then
                    State.AuraStatus = "Stop aura owned"
                    qQ.Enabled = false
                    if type(qQ.OnStop) == "function" then
                        pcall(qQ.OnStop)
                    end
                    break
                end
                local wm_1 = qX()
                if type(wm_1) ~= "table" then
                    State.AuraStatus = "No aura draw"
                    task.wait(0.8)
                    continue
                end
                local wn_1 = wm_1.needName or "Win"
                local wo_1 = tostring(wn_1)
                local max = math.max
                local wp = tonumber(wm_1.needNum) or 0
                local wm_2 = max(wp, 0)
                local wn_3 = qt(wo_1)
                if wn_3 < wm_2 then
                    State.AuraStatus = string.format("Need %s %s", wo_1, tostring(wm_2))
                    task.wait(0.8)
                    continue
                end
                State.AuraStatus = "Spinning aura"
                wn_4, wm_3 = qG(rf.DrawAura, "Win")
                local wo_2 = wn_4 and type(wm_3) == "table" and wm_3.Status == "Success"
                if wo_2 then
                    local wo_3 = tonumber(wm_3.AuraId) or tonumber(wm_3.EquippedAuraId)
                    local wm_4 = wo_3
                    local wt = if wo_3 then 1 else 0
                    local wr = 957 * wt + 1593 * (1 - wt)
                    local ws = 3279 * wt + 540 * (1 - wt)
                    if not ((wr * 1565 + ws * 1888 + wr * ws) % 16777213 == 10826460) then
                        wo_3 = "?"
                    end
                    State.AuraStatus = "Got aura " .. tostring(wo_3)
                    if wl_2 and wm_4 == wl_2 then
                        qQ.Enabled = false
                        State.AuraStatus = "Stop aura hit"
                        if type(qQ.OnStop) == "function" then
                            pcall(qQ.OnStop)
                        end
                        break
                    end
                    task.wait(0.55)
                    continue
                end
                if wn_4 then
                    State.AuraStatus = "Spin blocked"
                    task.wait(0.8)
                else
                    State.AuraStatus = "Spin failed"
                    task.wait(0.8)
                end
                task.wait(0.55)
                continue
            end
            break
        end
        if qQ.Generation == Generation and not qQ.Enabled then
            if State.AuraStatus ~= "Stop aura owned" and State.AuraStatus ~= "Stop aura hit" then
                State.AuraStatus = "Idle"
            end
        end
    end)
end
q0.Track(fn675)
qu = fn222
ro_2, rp_2 = pcall(function()
    local Ar
    local Library
    local Options
    local Ax
    local Toggles
    Ar = nil
    Options = nil
    Ax = nil
    Library = nil
    Toggles = nil
    local Aq, At, Au, Av, Aw, AA, AB
    Ax = "https://discord.gg/K7Qxnxkk46"
    AB = "+1 Sword vs Anime"
    AA = "https://discord.gg/K7Qxnxkk46"
    At = "https://tempohub.shop"
    Library = getgenv().Library
    local ThemeManager = getgenv().ThemeManager
    local SaveManager = getgenv().SaveManager
    Toggles, Options = Library.Toggles, Library.Options
    qC(q0, Library)
    Av = function(gx, gy)
        local wE = type(setclipboard) == "function" and setclipboard
        local wF = wE
        if not wF then
            local wE_1 = type(toclipboard) == "function" and toclipboard
            wF = wE_1
        end
        local wF_1 = wF or nil
        if not wF_1 then
            Library:Notify("Clipboard unavailable")
            return false
        end
        local wE_3 = pcall(wF_1, tostring(gx))
        if wE_3 then
            local wF_2 = gy or "Copied"
            Library:Notify(wF_2)
        else
            Library:Notify("Copy failed")
        end
        return wE_3
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Ax, Copyable = true }, "|", AB, "|", "v0.6" },
        Icon = 132608042600488,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Au = {}
    Au.Info = Window:AddTab("Info", "info")
    Au.Main = Window:AddTab("Main", "gamepad-2")
    Au.Player = Window:AddTab("Player", "person-standing")
    Au.Settings = Window:AddTab("Settings", "settings")
    local function AC(gJ)
        local DiscordGroup = gJ:AddLeftGroupbox("Discord", "message-circle")
        DiscordGroup:AddDiscordBox(nil, {
            Banner = 95892854151512,
            Avatar = 132608042600488,
            Title = "Tempo Hub",
            Subtitle = "Dupes, keyless scripts and updates",
            Status = "online",
            Accent = Color3.fromRGB(88, 101, 242),
            Link = Ax,
            Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
        })
        return DiscordGroup
    end
    for k, v in pairs(Au) do
        if k ~= "Info" then
            AC(v)
        end
    end
    local function AD_1()
        local w2
        local w0
        local xb
        local w7
        local w3
        w0 = nil
        w2 = nil
        w3 = nil
        w7 = nil
        xb = nil
        local w_, w1, w4, Label, w6, Label2, w9, Label4, Label3, xd, xe, Label5
        w_ = "#7fd47f"
        w6 = "#e8a34d"
        w1 = "#8b93a3"
        w9 = "#6ec1ff"
        xb = function(gU)
            return (tostring(gU):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        w2 = function(gW, gX)
            return string.format('<font color="%s">%s</font>', gX, xb(gW))
        end
        xe = function(g_, g0, g1)
            return string.format("<b>%s</b> %s %s", g_, w2("-", "#5a6070"), w2(g0, g1))
        end
        local xg = {}
        for k, v in pairs(rf) do
            if v == nil then
                table.insert(xg, k)
            end
        end
        local xh = #xg == 0 and "Remotes ready"
        local xi = xh or "Missing " .. table.concat(xg, ", ")
        w0 = "Unknown"
        pcall(function()
            local wI_1
            local wH_1
            if type(identifyexecutor) == "function" then
                wI_1, wH_1 = identifyexecutor()
                local wJ = wI_1 ~= ""
                local wK = type(wI_1) == "string" and wJ
                if wK then
                    local wJ_1 = type(wH_1) == "string" and wH_1 ~= "" and wI_1 .. " " .. wH_1
                    w0 = wJ_1 or wI_1
                end
            end
        end)
        w7 = os.clock()
        w4 = function()
            local wP = math.floor(os.clock() - w7)
            if wP < 60 then
                return wP .. "s"
            elseif wP < 3600 then
                return string.format("%dm %ds", math.floor((wP) / (60)), wP % 60)
            else
                return string.format("%dh %dm", math.floor((wP) / (3600)), math.floor((wP % 3600) / (60)))
            end
        end
        local UserGroup = Au.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(xe("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, w_), true)
        UserGroup:AddLabel(xe("UserId", tostring(LocalPlayer.UserId), w9), true)
        UserGroup:AddLabel(xe("Executor", w0 .. "  " .. xi, w_), true)
        UserGroup:AddDivider()
        Label5 = UserGroup:AddLabel(xe("Session", w4(), w6), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                Av(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                Av("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local DiscordGroup = Au.Info:AddRightGroupbox("Discord", "message-circle")
        DiscordGroup:AddDiscordBox(nil, {
            Banner = 95892854151512,
            Avatar = 132608042600488,
            Title = "Tempo Hub",
            Subtitle = "Dupes, keyless scripts and updates",
            Status = "online",
            Accent = Color3.fromRGB(88, 101, 242),
            Link = Ax,
            Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
        })
        local SessionGroup = Au.Info:AddRightGroupbox("Session", "signal")
        Label4 = SessionGroup:AddLabel(xe("Game", AB, w_), true)
        Label3 = SessionGroup:AddLabel(xe("Players", tostring(#Players:GetPlayers()), w9), true)
        local JobId = game.JobId
        local xi_1 = #JobId > 12 and JobId:sub(1, 12) .. "..."
        xd = xi_1 or JobId
        local xi_2 = xd ~= "" and xd or "N/A"
        Label2 = SessionGroup:AddLabel(xe("Job", xi_2, w1), true)
        Label = SessionGroup:AddLabel(xe("Ping", "...", w6), true)
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                Av(game.JobId, "Copied Job ID")
            end
        })
        local SocialsGroup = Au.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({
            Text = "Copy Discord Invite",
            Func = function()
                Av(Ax, "Copied Discord invite")
            end
        })
        SocialsGroup:AddButton({
            Text = "Copy Rscripts Link",
            Func = function()
                Av(AA, "Copied Rscripts link")
            end
        })
        SocialsGroup:AddButton({
            Text = "Copy Website Link",
            Func = function()
                Av(At, "Copied website link")
            end
        })
        w3 = task.spawn(function()
            local wZ = false
            repeat
                local wU
                local wV = not Library.Unloaded and qz()
                if wV then
                    Label5:SetText(xe("Session", w4(), w6))
                    Label3:SetText(xe("Players", tostring(#Players:GetPlayers()), w9))
                    wU = 0
                    pcall(function()
                        wU = math.floor(LocalPlayer:GetNetworkPing() * 1000)
                    end)
                    Label:SetText(xe("Ping", tostring(wU) .. "ms", w6))
                    Label4:SetText(xe("Game", AB, w_))
                    local wW = xd ~= "" and xd or "N/A"
                    Label2:SetText(xe("Job", wW, w1))
                    task.wait(1)
                else
                    wZ = true
                end
            until wZ
        end)
        q0.Track(function()
            pcall(task.cancel, w3)
        end)
    end
    AD_1()
    local function AC_1()
        local ju
        local FarmGroup = Au.Main:AddLeftGroupbox("Farm", "swords")
        local Label6 = FarmGroup:AddLabel(State.WinStatus, true)
        local Label5 = FarmGroup:AddLabel(State.SwordStatus, true)
        FarmGroup:AddDivider()
        FarmGroup:AddToggle("AutoBestWin", {
            Text = "Auto Best Win",
            Default = false,
            Callback = function(iw)
                qT.SetEnabled(iw)
            end
        })
        FarmGroup:AddToggle("AutoBuyBestSword", {
            Text = "Auto Buy Best Affordable Sword",
            Default = false,
            Callback = function(iA)
                qH.SetEnabled(iA)
            end
        })
        local ProgressGroup = Au.Main:AddLeftGroupbox("Progress", "trending-up")
        local Label4 = ProgressGroup:AddLabel(State.RebirthStatus, true)
        local Label3 = ProgressGroup:AddLabel(State.TrailStatus, true)
        local Label2 = ProgressGroup:AddLabel(State.AuraStatus, true)
        ProgressGroup:AddDivider()
        ProgressGroup:AddToggle("AutoRebirth", {
            Text = "Auto Rebirth",
            Default = false,
            Callback = function(iI)
                qK.SetEnabled(iI)
            end
        })
        ProgressGroup:AddToggle("AutoBuyTrails", {
            Text = "Auto Buy Trails",
            Default = false,
            Callback = function(iM)
                qW.SetEnabled(iM)
            end
        })
        ProgressGroup:AddToggle("AutoBuyAuras", {
            Text = "Auto Spin Auras",
            Default = false,
            Callback = function(iQ)
                qQ.SetEnabled(iQ)
            end
        })
        local iW = rh()
        ProgressGroup:AddDropdown("AuraStopAt", {
            Text = "Stop At Aura",
            Values = iW,
            Default = iW[1],
            Multi = false,
            AllowNull = false,
            Callback = function(iX)
                qQ.SetStopAt(iX)
            end
        })
        qQ.OnStop = function()
            if Toggles.AutoBuyAuras then
                Toggles.AutoBuyAuras:SetValue(false)
            end
        end
        local TrainingGroup = Au.Main:AddRightGroupbox("Training", "dumbbell")
        local Label = TrainingGroup:AddLabel(State.TrainStatus, true)
        TrainingGroup:AddDivider()
        TrainingGroup:AddToggle("AutoTrain", {
            Text = "Auto Train",
            Default = false,
            Callback = function(i2)
                qF.SetEnabled(i2)
            end
        })
        local i8 = qu()
        TrainingGroup:AddDropdown("TrainSelect", {
            Text = "Train Target",
            Values = i8,
            Default = i8[1],
            Multi = false,
            AllowNull = false,
            Callback = function(i9)
                qF.SetSelection(i9)
            end
        })
        ju = task.spawn(function()
            while true do
                local xs = not Library.Unloaded and qz()
                if xs then
                    pcall(function()
                        Label6:SetText(State.WinStatus)
                        Label5:SetText(State.SwordStatus)
                        Label4:SetText(State.RebirthStatus)
                        Label3:SetText(State.TrailStatus)
                        Label2:SetText(State.AuraStatus)
                        Label:SetText(State.TrainStatus)
                    end)
                    task.wait(0.2)
                    continue
                end
                break
            end
        end)
        q0.Track(function()
            pcall(task.cancel, ju)
        end)
    end
    AC_1()
    local function AC_2()
        local jy
        jy = {
            [1] = false,
            [2] = 16,
            [3] = nil,
            [4] = false,
            [5] = 50,
            [6] = nil,
            [7] = nil,
            [8] = nil,
            [9] = false,
            [10] = nil,
            [11] = false,
            [12] = nil,
            [13] = false,
            [14] = nil
        }
        local function jz()
            return qP()
        end
        local function jD()
            local xu = jz()
            if not xu then
                return
            end
            if jy[3] == nil then
                jy[3] = xu.WalkSpeed
            end
            if jy[1] then
                xu.WalkSpeed = jy[2]
            elseif jy[3] then
                xu.WalkSpeed = jy[3]
            end
        end
        local function jH()
            if jy[8] then
                jy[8]:Disconnect()
                jy[8] = nil
            end
            if jy[6] then
                jy[6]:Destroy()
                jy[6] = nil
            end
            if jy[7] then
                jy[7]:Destroy()
                jy[7] = nil
            end
        end
        local function jJ()
            local xG, xH, bodyGyro, bodyVelocity
            jH()
            xH = q7()
            xG = jz()
            local xK = not xG
            local xL = not xH
            local xP = if xL then 1 else 0
            local xN = 3398 * xP + 886 * (1 - xP)
            local xO = 270 * xP + 3962 * (1 - xP)
            if not ((xN * 3557 + xO * 457 + xN * xO) % 16777213 == 13127536) then
                xL = xK
            end
            if xL then
                return
            end
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            bodyVelocity.Velocity = Vector3.zero
            bodyVelocity.Parent = xH
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
            bodyGyro.P = 10000
            bodyGyro.Parent = xH
            jy[6] = bodyVelocity
            jy[7] = bodyGyro
            jy[8] = RunService.RenderStepped:Connect(function()
                if not jy[4] or q0.Unloaded then
                    return
                end
                xH = q7()
                xG = jz()
                if not xH or not xG or not bodyVelocity.Parent or not bodyGyro.Parent then
                    return
                end
                local CurrentCamera = qB.CurrentCamera
                if not CurrentCamera then
                    return
                end
                local xB = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    xB += CurrentCamera.CFrame.LookVector
                end
                local xF = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
                if xF == 1 then
                    xB -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    xB -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    xB += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    xB += Vector3.yAxis
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    xB -= Vector3.yAxis
                end
                if xB.Magnitude > 0 then
                    xB = xB.Unit * jy[5]
                end
                bodyVelocity.Velocity = xB
                bodyGyro.CFrame = CurrentCamera.CFrame
            end)
        end
        local MovementGroup = Au.Player:AddLeftGroupbox("Movement", "person-standing")
        MovementGroup:AddToggle("WalkSpeedEnabled", {
            Text = "WalkSpeed",
            Default = false,
            Callback = function(ke)
                jy[1] = ke
                jD()
            end
        })
        MovementGroup:AddSlider("WalkSpeed", {
            Text = "Speed",
            Default = 16,
            Min = 16,
            Max = 200,
            Rounding = 0,
            Callback = function(kh)
                jy[2] = kh
                if jy[1] then
                    jD()
                end
            end
        })
        MovementGroup:AddToggle("Fly", {
            Text = "Fly",
            Default = false,
            Callback = function(kk)
                jy[4] = kk
                if kk then
                    jJ()
                else
                    jH()
                end
            end
        })
        MovementGroup:AddSlider("FlySpeed", {
            Text = "Fly Speed",
            Default = 50,
            Min = 10,
            Max = 250,
            Rounding = 0,
            Callback = function(ko)
                jy[5] = ko
            end
        })
        MovementGroup:AddToggle("InfJump", {
            Text = "Infinite Jump",
            Default = false,
            Callback = function(kq)
                jy[11] = kq
                if jy[12] then
                    jy[12]:Disconnect()
                    jy[12] = nil
                end
                if kq then
                    jy[12] = UserInputService.JumpRequest:Connect(function()
                        local xY = jz()
                        if xY then
                            xY:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end)
                end
            end
        })
        MovementGroup:AddToggle("NoClip", {
            Text = "Noclip",
            Default = false,
            Callback = function(kx)
                jy[9] = kx
                if jy[10] then
                    jy[10]:Disconnect()
                    jy[10] = nil
                end
                if kx then
                    jy[10] = RunService.Stepped:Connect(function()
                        local Character = LocalPlayer.Character
                        if not Character then
                            return
                        end
                        for i, descendant in ipairs(Character:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                descendant.CanCollide = false
                            end
                        end
                    end)
                end
            end
        })
        MovementGroup:AddToggle("InstantProximityPrompt", {
            Text = "Instant ProximityPrompt",
            Default = false,
            Callback = function(kG)
                jy[13] = kG
                if jy[14] then
                    jy[14]:Disconnect()
                    jy[14] = nil
                end
                if kG then
                    local function onDescendantAdded(kJ)
                        if kJ:IsA("ProximityPrompt") then
                            kJ.HoldDuration = 0
                        end
                    end
                    for i, descendant in ipairs(rg:GetDescendants()) do
                        onDescendantAdded(descendant)
                    end
                    jy[14] = rg.DescendantAdded:Connect(onDescendantAdded)
                end
            end
        })
        q0.Track(function()
            jH()
            if jy[10] then
                jy[10]:Disconnect()
            end
            if jy[12] then
                jy[12]:Disconnect()
            end
            if jy[14] then
                jy[14]:Disconnect()
            end
            jy[1] = false
            jD()
        end)
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            local yp = not qz()
            local yt = if yp then 1 else 0
            local yr = 1978 * yt + 43 * (1 - yt)
            local ys = 4014 * yt + 1378 * (1 - yt)
            if not ((yr * 1340 + ys * 3636 + yr * ys) % 16777213 == 8407903) then
                yp = Library.Unloaded
            end
            if yp then
                return
            end
            jy[3] = nil
            if jy[1] then
                jD()
            end
            if jy[4] then
                jJ()
            end
        end)
    end
    AC_2()
    local function AC_3()
        local zu
        local zr
        zr = nil
        zu = nil
        local Label, zq, zs, zt, zv, zw, zx, zy, zz, zA
        zt = {}
        zq = {}
        zy = nil
        zA = 0
        zu = 0
        zr = false
        local MenuGroup = Au.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        zs = function()
            local CurrentCamera
            CurrentCamera = qB.CurrentCamera
            local yv = not CurrentCamera or not qI(VirtualUser.CaptureController) or not qI(VirtualUser.ClickButton2)
            if yv then
                return false
            end
            local yv_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not yv_1 then
                return false
            end
            zA += 1
            pcall(function()
                Label:SetText("AFK triggers: " .. zA)
            end)
            return true
        end
        zz = function(lr)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not lr)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not lr
                end
            end)
            if not lr then
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
        zw = function(lH)
            if lH.ClassName == "ParticleEmitter" or lH.ClassName == "Trail" or lH.ClassName == "Smoke" or lH.ClassName == "Fire" or lH.ClassName == "Sparkles" or lH.ClassName == "Explosion" or lH.ClassName == "Beam" then
                if zt[lH] == nil then
                    zt[lH] = lH.Enabled
                end
                pcall(function()
                    lH.Enabled = false
                end)
            end
        end
        zv = function()
            for k, v in pairs(zt) do
                local yK = k
                local yM = v
                if yK.Parent then
                    pcall(function()
                        yK.Enabled = yM
                    end)
                end
            end
            table.clear(zt)
            if zy then
                pcall(function()
                    settings().Rendering.QualityLevel = zy.Quality
                end)
                Lighting.GlobalShadows = zy.Shadows
                Lighting.FogEnd = zy.Fog
                zy = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(lW)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not lW)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(l0)
                if l0 then
                    if not zy then
                        zy = {
                            Quality = settings().Rendering.QualityLevel,
                            Shadows = Lighting.GlobalShadows,
                            Fog = Lighting.FogEnd
                        }
                    end
                    pcall(function()
                        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    end)
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9000000000
                    for k, v in rg:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(zw, v)
                    end
                else
                    zv()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        zz(true)
        local ScriptGroup = Au.Settings:AddLeftGroupbox("Script", "scroll-text")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            zz(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            zz(true)
        end
        table.insert(zq, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                zs()
            end
        end))
        table.insert(zq, rg.DescendantAdded:Connect(function(mk)
            if Toggles.FpsBoost.Value then
                zw(mk)
            end
        end))
        zx = function(mo)
            local y2 = zr
            local y7 = if y2 then 1 else 0
            local y5 = 135 * y7 + 4009 * (1 - y7)
            local y6 = 1950 * y7 + 3063 * (1 - y7)
            if not ((y5 * 1893 + y6 * 1478 + y5 * y6) % 16777213 == 3400905) then
                y2 = Library.Unloaded
            end
            if not y2 then
                y2 = not Toggles.AutoReconnect.Value
            end
            if y2 then
                return
            end
            zr = true
            local y1 = zu
            local y2_1 = pcall(function()
                if mo then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not y2_1 then
                zr = false
                if not mo and y1 == zu then
                    task.delay(1.5, function()
                        if y1 == zu then
                            zx(true)
                        end
                    end)
                end
            end
        end
        table.insert(zq, TeleportService.TeleportInitFailed:Connect(function(mG)
            if mG == LocalPlayer and zr then
                zr = false
                zx(true)
            end
        end))
        table.insert(zq, LocalPlayer.OnTeleport:Connect(function()
            zr = false
            zu += 1
        end))
        table.insert(zq, GuiService.ErrorMessageChanged:Connect(function()
            if Toggles.AutoReconnect.Value and not Library.Unloaded then
                zx(false)
            end
        end))
        q0.Track(function()
            for i, v in ipairs(zq) do
                local zo = v
                pcall(function()
                    zo:Disconnect()
                end)
            end
            zv()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
            zz(false)
        end)
    end
    AC_3()
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(Au.Settings)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/SwordVsAnime")
    local AC_4 = SaveManager:BuildConfigSection(Au.Settings)
    Ar = function(m0, m1)
        local zE = m0 == "Toggle" and Toggles
        local zJ = if zE then 1 else 0
        local zH = 2735 * zJ + 3625 * (1 - zJ)
        local zI = 3220 * zJ + 1878 * (1 - zJ)
        if not ((zH * 814 + zI * 881 + zH * zI) % 16777213 == 13869810) then
            zE = Options
        end
        local zE_1 = zE[m1]
        local zD_2 = type(zE_1) == "table" and zE_1.Type == m0
        local zD_3 = zD_2 and zE_1
        local zJ_1 = if zD_3 then 1 else 0
        local zH_1 = 445 * zJ_1 + 3651 * (1 - zJ_1)
        local zI_1 = 3950 * zJ_1 + 453 * (1 - zJ_1)
        if not ((zH_1 * 634 + zI_1 * 1328 + zH_1 * zI_1) % 16777213 == 7285480) then
            zD_3 = nil
        end
        return zD_3
    end
    Aq = function(m8, m9)
        local Type = m9.Type
        if Type == "Toggle" then
            return { idx = m8, type = "Toggle", value = m9.Value == true }
        elseif Type == "Slider" then
            return { idx = m8, type = "Slider", value = tostring(m9.Value) }
        elseif Type == "Dropdown" then
            return { idx = m8, type = "Dropdown", multi = m9.Multi == true, value = m9.Value }
        elseif Type == "Input" then
            local zL_1 = m9.Value or ""
            return { idx = m8, type = "Input", text = tostring(zL_1) }
        elseif Type == "ColorPicker" then
            return { idx = m8, type = "ColorPicker", value = m9.Value:ToHex(), transparency = m9.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = m8,
                type = "KeyPicker",
                key = m9.Value,
                mode = m9.Mode,
                syncToggleState = m9.SyncToggleState or nil
            }
        else
            return nil
        end
    end
    Aw = function(nc)
        local zO = type(nc) ~= "table" or type(nc.idx) ~= "string" or type(nc.type) ~= "string"
        if zO then
            return false
        end
        local zO_1 = Ar(nc.type, nc.idx)
        if not zO_1 then
            return false
        end
        local zP = nc.type == "Toggle" and type(nc.value) == "boolean"
        if zP then
            zO_1:SetValue(nc.value)
            return true
        elseif nc.type == "Slider" then
            local zP_1 = tonumber(nc.value)
            if zP_1 then
                zO_1:SetValue(zP_1)
                return true
            end
            return false
        elseif nc.type == "Dropdown" then
            zO_1:SetValue(nc.value)
            return true
        else
            local zP_2 = nc.type == "Input" and type(nc.text) == "string"
            if zP_2 then
                zO_1:SetValue(nc.text)
                return true
            end
            local zP_3 = nc.type == "ColorPicker" and type(nc.value) == "string"
            if zP_3 then
                zO_1:SetValueRGB(Color3.fromHex(nc.value))
                if type(nc.transparency) == "number" then
                    zO_1:SetTransparency(nc.transparency)
                end
                return true
            end
            local zP_4 = nc.type == "KeyPicker" and type(nc.key) == "string"
            if zP_4 then
                local key = nc.key
                local zQ = nc.mode or "Toggle"
                zO_1:SetValue({ key, zQ })
                return true
            end
            return false
        end
    end
    AC_4:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Default = "", Finished = true, AllowEmpty = true })
    AC_4:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local z__2
            local zZ_4
            local zY = {}
            for k, v in pairs(Toggles) do
                if k ~= "MenuKeybind" then
                    local zZ_1 = Aq(k, v)
                    if zZ_1 then
                        table.insert(zY, zZ_1)
                    end
                end
            end
            for k, v in pairs(Options) do
                if k ~= "MenuKeybind" and k ~= "SaveManager_ImportSource" then
                    local zZ_3 = Aq(k, v)
                    if zZ_3 then
                        table.insert(zY, zZ_3)
                    end
                end
            end
            table.sort(zY, function(ns, nt)
                return ns.idx < nt.idx
            end)
            zZ_4, z__2 = pcall(HttpService.JSONEncode, HttpService, { objects = zY })
            if not zZ_4 then
                Library:Notify("Failed to encode config")
                return
            end
            Av(z__2, "Copied config to clipboard")
        end
    })
    AC_4:AddButton({
        Text = "Import Config from Clipboard Text",
        Func = function()
            local Af_1
            local Ae = Options.SaveManager_ImportSource and Options.SaveManager_ImportSource.Value or ""
            local Ae_1
            if Ae == "" then
                Library:Notify("Paste a config first")
                return
            end
            Ae_1, Af_1 = pcall(HttpService.JSONDecode, HttpService, Ae)
            local Ad_2 = not Ae_1 or type(Af_1) ~= "table" or type(Af_1.objects) ~= "table"
            if Ad_2 then
                Library:Notify("Invalid config JSON")
                return
            end
            local Ad_3 = 0
            for i, v in ipairs(Af_1.objects) do
                if Aw(v) then
                    Ad_3 += 1
                end
            end
            Library:Notify("Imported " .. tostring(Ad_3) .. " settings")
        end
    })
    SaveManager:LoadAutoloadConfig()
    if Toggles.HideUiOnStart and Toggles.HideUiOnStart.Value then
        pcall(function()
            Library:Toggle(false)
        end)
    end
    if Options.TrainSelect then
        qF.SetSelection(Options.TrainSelect.Value)
    end
    if Options.AuraStopAt then
        qQ.SetStopAt(Options.AuraStopAt.Value)
    end
end)
if not ro_2 then
    local rk_4 = 5
    repeat
        if rk_4 * 111919171 + 13 + 7 >= rk_4 * 111919171 + 13 + 7 + 1 then
            pcall(rp_2.Unload)
            error(q0, 0)
        else
            pcall(q0.Unload)
            error(rp_2, 0)
        end
        rk_4 = (rk_4 + 4) % 8
    until (rk_4 * 1 + 1) % 8 == 2
end
end)(...)
