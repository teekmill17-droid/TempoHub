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
getgenv().TempoHoodSubtitle = "PARKOUR PANDEMIC"
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
local s1_23, s1_26
local l9
local mR
local lR
local connection3
local mf
local Library
local lX
local lE
local ml
local connection5
local l2
local mK
local connection4
local Options
local l8
local HttpService
local DisasterAmpCooldownRounds
local mx
local me
local VirtualUser
local lW
local mD
local MapBoundsHalfX
local connection2
local m1
local l1
local lJ
local mq
local m7
local BuyGearEvent
local mP
local lP
local mw
local md
local mV
local lV
local mC
local lC
local mj
local UserInputService
local l0
local mI
local lI
local mp
local m6
local l6
local connection
local lO
local Toggles
local mc
local mU
local Status
local mB
local lB
local mi
local m_
local RequestSpawn
local mH
local __tempo_gen
local mo
local m5
local ClaimDailyReward
local mN
local lN
local LocalPlayer
local mb
local mT
local lT
local SaveManager
local MapBoundsHalfZ
local mh
local mZ
local lZ
local Label
local lG
local mn
local m4
local RequestDailyRewardState
local mM
local lM
local mt
local BuyExtraDisaster
local PendingExtraDisasters
local Workspace
local ShopConfig
local mY
local DisasterActive
local mF
local MapCenterZ
local mm
local m3
local l3
local mL
local MapCenterX
local ms
function fns.fn12()
    if not Toggles.WalkSpeedEnabled.Value then
        local rl = lI()
        if rl then
            rl.WalkSpeed = 16
        end
    end
end
function fns.onImportConfigFromClipboardTex()
    local sy_1
    local sw = Options.SaveManager_ImportSource.Value or ""
    local sw_1
    local sx = tostring(sw):match("^%s*(.-)%s*$")
    if sx == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    sw_1, sy_1 = pcall(HttpService.JSONDecode, HttpService, sx)
    local sx_1 = not sw_1 or type(sy_1) ~= "table" or type(sy_1.objects) ~= "table"
    if sx_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local sw_2 = 0
    for i, v in ipairs(sy_1.objects) do
        if mL(v) then
            sw_2 += 1
        end
    end
    if sw_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local sy_2 = sw_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(sw_2, sy_2), 6)
end
function fns.onInputBegan()
    mq = tick()
end
function fns.onCopyUSDTAddress()
    mc(ms, "Copied USDT address")
end
function fns.fn81(ba)
    local oc = lR()
    if not oc then
        return
    end
    if oc.PrimaryPart then
        oc:PivotTo(ba)
    else
        local oc_1 = m5()
        if oc_1 then
            oc_1.CFrame = ba
        end
    end
end
function fns.fn107(ac, ad, ae)
    return string.format("<b>%s</b> %s %s", ac, lT("-", "#5a6070"), lT(ad, ae))
end
function fns.fn111()
    local pZ_1
    local pY_1
    local pX_1
    local pW_1
    local pU = tick()
    if pU - mI >= 0.12 then
        mM = mF()
        mI = pU
    end
    local pU_1 = mY(mM)
    local pV = me(pU_1)
    pX_1, pZ_1, pW_1, pY_1 = lP()
    if mV then
        local p_ = math.abs(mV.X - pX_1) > pW_1 + 50 or math.abs(mV.Z - pZ_1) > pY_1 + 50
        if p_ then
            mV = nil
        end
    end
    local pW_2 = pV[1]
    local pX_2 = -math.huge
    for i, v in ipairs(pV) do
        local pV_1 = lW(v.X, v.Z, mM)
        if pV_1 > pX_2 then
            pX_2 = pV_1
            pW_2 = v
        end
    end
    if mV then
        local pV_2 = Vector3.new(mV.X, pU_1, mV.Z)
        local pU_2 = lW(pV_2.X, pV_2.Z, mM)
        if pU_2 >= 55 and pU_2 >= pX_2 - 35 then
            mV = pV_2
            return CFrame.new(mV)
        end
        mV = pW_2
        return CFrame.new(mV)
    end
    mV = pW_2
    return CFrame.new(mV)
end
function fns.fn113()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local oj = leaderstats and leaderstats:FindFirstChild("Volts")
    local oi_1 = oj
    if oj then
        oj = tonumber(oi_1.Value)
    end
    local oi_2 = oj
    local oo = if oi_2 then 1 else 0
    local om = 1953 * oo + 997 * (1 - oo)
    local on = 3676 * oo + 4055 * (1 - oo)
    if not ((om * 3429 + on * 1557 + om * on) % 16777213 == 2822384) then
        oi_2 = 0
    end
    return oi_2
end
function fns.fn135()
    local n3 = lR()
    local n4 = n3 and n3:FindFirstChildOfClass("Humanoid")
    return n4
end
function fns.fn140(aL)
    if Library.Unloaded then
        return false
    end
    local nV = Toggles[aL]
    return nV ~= nil and nV.Value == true
end
function fns.onCopyVenmoLink()
    mc(md, "Copied Venmo link")
end
function fns.fn191()
    if not Toggles.Fly.Value then
        local rj = lI()
        if rj then
            rj.PlatformStand = false
        end
    end
end
function fns.worker2()
    while not Library.Unloaded and lM.__tempo_gen == __tempo_gen do
        task.wait(0.15)
        if mD("AutoFarm") then
            mt()
        end
    end
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    local ro = Toggles.NoClip and Toggles.NoClip.Value
    if not ro then
        local rn_1 = lZ() and mD("AutoFarm")
        ro = rn_1
    end
    if ro then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local rn_3 = descendant:IsA("BasePart") and descendant.CanCollide
                if rn_3 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.onCopyLitecoinAddress()
    mc(mH, "Copied Litecoin address")
end
function fns.fn245(dK)
    local qm = lN()
    lC += dK * 10
    local qn = Vector3.new(math.cos(lC) * 22, math.sin(lC * 2) * 10, math.sin(lC) * 22)
    local qo = CFrame.new(qm.Position + qn)
    l2(qo.Position)
    mp(qo)
    local qm_1 = m5()
    if qm_1 then
        qm_1.AssemblyLinearVelocity = Vector3.zero
        qm_1.AssemblyAngularVelocity = Vector3.zero
    end
end
function fns.onRenderStepped(f1)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local rB_1 = lI()
        if rB_1 then
            rB_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    local rB_2 = lZ() and m5() ~= nil
    if rB_2 then
        if mD("AutoBeacons") then
            lO()
        end
        if mD("AutoFarm") then
            l6(f1)
            return
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local rB_4 = m5()
        local rC = lI()
        mf = Workspace.CurrentCamera or mf
        if rB_4 and rC and mf then
            rC.PlatformStand = true
            local rC_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                rC_1 = rC_1 + mf.CFrame.LookVector
            end
            local rI = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if rI == 1 then
                rC_1 = rC_1 - mf.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                rC_1 = rC_1 - mf.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                rC_1 = rC_1 + mf.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                rC_1 = rC_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                rC_1 = rC_1 - Vector3.new(0, 1, 0)
            end
            rB_4.Velocity = Vector3.zero
            if rC_1.Magnitude > 0 then
                rB_4.CFrame = rB_4.CFrame + rC_1.Unit * Options.FlySpeed.Value * f1
            end
        end
    end
end
function fns.fn320()
    local oP = tonumber(MapCenterX.Value) or 0
    local oP_1 = tonumber(MapCenterZ.Value) or 0
    local oP_2 = tonumber(MapBoundsHalfX.Value) or 0
    local oP_3 = tonumber(MapBoundsHalfZ.Value) or 0
    return oP, oP_1, oP_2, oP_3
end
function fns.fn324(aP, aQ)
    local nY = Options[aP]
    local nZ = nY and tonumber(nY.Value)
    if nZ then
        return nZ
    end
    return aQ
end
function fns.fn336(bs)
    local OwnedGears = LocalPlayer:FindFirstChild("OwnedGears")
    local oq = OwnedGears ~= nil and OwnedGears:FindFirstChild(bs) ~= nil
    return oq
end
function fns.fn345(b6, b7, b8, b9)
    local pb = Workspace:FindFirstChild(b7)
    if not pb then
        return
    end
    local pc = 0
    for i, child in ipairs(pb:GetChildren()) do
        mm(b6, child, b8)
        pc += 1
        if pc >= b9 then
            break
        end
    end
end
function fns.onTeleportToBorder()
    local dW = lN()
    l2(dW.Position)
    mp(dW)
end
function fns.fn373()
    mN(RequestDailyRewardState)
    local qT = 1
    while qT <= 7 do
        local qU = qT
        mN(ClaimDailyReward, qU)
        qT += 1
    end
end
function fns.onExportConfigToClipboard()
    local sq_1
    local sp_1
    sp_1, sq_1 = pcall(HttpService.JSONEncode, HttpService, l1())
    if not sp_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local sp_2 = setclipboard or toclipboard
    local sp_3 = type(sp_2) ~= "function" or not pcall(sp_2, sq_1)
    if sp_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.fn435()
    return LocalPlayer.Character
end
local function fn438(gH, gI)
    local rZ_1 = (gH == "Toggle" and Toggles or Options)[gI]
    local rY_2 = type(rZ_1) == "table" and rZ_1.Type == gH
    return rY_2 and rZ_1 or nil
end
local function onCopyEthereumAddress()
    mc(mw, "Copied Ethereum address")
end
local function fn464()
    if DisasterActive.Value == true then
        return true
    end
    local oN = tostring(Status.Value)
    return string.find(oN, "Survive", 1, true) ~= nil
end
local function onInputChanged(gz)
    local UserInputType = gz.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        mq = tick()
    end
end
local function antiGameplayPauseLoop()
    while true do
        if not Library.Unloaded and lM.__tempo_gen == __tempo_gen then
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                lE(true)
            end
            local sI_1 = mD("AutoDaily") and tick() - m1 >= 8
            if sI_1 then
                m1 = tick()
                mh()
            end
            if tick() - m4 >= 1.2 then
                m4 = tick()
                if mD("AutoBuyDisasters") then
                    mP()
                end
                if mD("AutoBuyGears") then
                    lX()
                end
            end
            continue
        end
        break
    end
end
local function fn494()
    if lZ() then
        return
    end
    local qx = lJ()
    local qy = mx()
    local GEARS = ShopConfig.GEARS
    for i, v in ipairs(m3) do
        local qP = if not m_(v) then 1 else 0
        if qP == 1 then
            local qA = GEARS[v]
            if qA and not qA.locked then
                if qy >= (qA.questUnlock or 0) and qx >= (qA.price or 0) then
                    mN(BuyGearEvent, v)
                    return
                end
            end
        end
    end
end
local function fn505()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then
        return 0
    end
    for i, v in ipairs({ "QuestHUD", "NewQuestHUDGui", "new quest gui" }) do
        local ov = PlayerGui:FindFirstChild(v)
        if ov then
            for i, descendant in ipairs(ov:GetDescendants()) do
                if descendant:IsA("TextLabel") then
                    local ov_1 = string.match(descendant.Text, "Quest%s+(%d+)")
                    if ov_1 then
                        local ow = tonumber(ov_1) or 0
                        return ow
                    end
                end
            end
        end
    end
    return 0
end
local function onUnload()
    Library:Unload()
end
local function fn548()
    local sQ = lM.__tempo_gen or 0
    lM.__tempo_gen = sQ + 1
    pcall(function()
        connection:Disconnect()
        connection2:Disconnect()
        connection3:Disconnect()
        connection4:Disconnect()
        connection5:Disconnect()
        lE(false)
        local sO = lI()
        if sO then
            sO.PlatformStand = false
            sO.WalkSpeed = 16
        end
    end)
    pcall(function()
        Library:Unload()
    end)
    lM.__tempo_cleanup = nil
end
local function onCopySolanaAddress()
    mc(mo, "Copied Solana address")
end
local function antiAfkLoop()
    while true do
        if not Library.Unloaded and lM.__tempo_gen == __tempo_gen then
            task.wait(2)
            if Toggles.AntiAfk.Value then
                local sK_1 = tick() - mq
                local sL = tick() - ml
                if sK_1 >= 300 and sL >= 60 then
                    pcall(l3)
                else
                    if sK_1 < 300 and sL >= 300 then
                        pcall(l3)
                    end
                end
            end
            continue
        end
        break
    end
end
local function fn596()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn603(cw, cy, cA)
    local pz = math.huge
    for i, v in ipairs(cA) do
        local pA = cw - v.x
        local pB = cy - v.z
        local pC = math.sqrt(pA * pA + pB * pB) - v.radius
        if pC < pz then
            pz = pC
        end
    end
    if pz == math.huge then
        return 1000
    end
    return pz
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local rw_1 = lI()
        if rw_1 then
            rw_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn619(cI)
    local pK = 260
    local BaseplateWater = Workspace:FindFirstChild("BaseplateWater")
    local pM = BaseplateWater and BaseplateWater:IsA("BasePart")
    if pM then
        pK = math.max(pK, BaseplateWater.Position.Y + BaseplateWater.Size.Y * 0.5 + 50)
    end
    for i, v in ipairs(cI) do
        if v.top and v.radius >= 40 then
            pK = math.max(pK, v.top + 40)
        end
    end
    if pK > 520 then
        pK = 520
    end
    return pK
end
local function fn628()
    if LocalPlayer:GetAttribute("HasEntered") then
        return
    end
    if tick() - mZ < 2 then
        return
    end
    mZ = tick()
    mN(RequestSpawn)
end
local function fn637(Z, aa)
    return string.format('<font color="%s">%s</font>', aa, Z)
end
local function onRscripts()
    mc(mi, "Copied Rscripts profile to clipboard")
end
local function worker()
    local q7_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local q6 = math.floor(os.clock() - l8)
        if q6 < 60 then
            q7_1 = q6 .. "s"
        elseif q6 < 3600 then
            q7_1 = string.format("%dm %ds", math.floor((q6) / (60)), q6 % 60)
        else
            q7_1 = string.format("%dh %dm", math.floor((q6) / (3600)), math.floor((q6 % 3600) / (60)))
        end
        Label:SetText(lG("Session time", q7_1, mU))
    end
end
local function fn686()
    if lZ() then
        return
    end
    if DisasterAmpCooldownRounds.Value > 0 then
        return
    end
    local qq = l9("ExtraDisasterAmount", 1)
    local qr = tonumber(PendingExtraDisasters.Value) or 0
    if qr >= qq then
        return
    end
    if qr >= 10 then
        return
    end
    local qq_1 = lJ()
    if qr > 0 and qq_1 < m6 then
        return
    end
    mN(BuyExtraDisaster)
end
local function fn688()
    pcall(function()
        connection:Disconnect()
        connection2:Disconnect()
        connection3:Disconnect()
        connection4:Disconnect()
        connection5:Disconnect()
    end)
    lE(false)
    local sS = lI()
    if sS then
        sS.PlatformStand = false
        sS.WalkSpeed = 16
    end
end
local function fn718(ex)
    local DiscordGroup = ex:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = l0 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = l0 })
end
local function fn727()
    local r5 = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local r6 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if r6 then
                local r6_1 = mb(k, v)
                if r6_1 then
                    r5[#r5 + 1] = r6_1
                end
            end
        end
    end
    table.sort(r5, function(g2, g3)
        if g2.type ~= g3.type then
            return g2.type < g3.type
        end
        return g2.idx < g3.idx
    end)
    return { objects = r5 }
end
local function onCopyPayPalLink()
    mc(mj, "Copied PayPal link")
end
local function fn734()
    lE(Toggles.AntiGameplayPause.Value)
end
local function onCopyBitcoinAddress()
    mc(mC, "Copied Bitcoin address")
end
local function fn769(bZ, b_, b0)
    local o2_1
    local o1_1
    local o0_1
    if not b_ then
        return
    end
    o2_1, o0_1, o1_1 = mR(b_)
    if not o2_1 then
        return
    end
    local o3 = #bZ + 1
    local o4 = o2_1.X
    local o5 = o2_1.Z
    local o6 = o0_1 or 8
    local o0_2 = b0 or 12
    bZ[o3] = { x = o4, z = o5, top = o1_1, radius = o6 + o0_2 }
end
local function fn786(gP, gQ)
    local Type = gQ.Type
    if Type == "Toggle" then
        return { idx = gP, type = "Toggle", value = gQ.Value == true }
    elseif Type == "Slider" then
        return { idx = gP, type = "Slider", value = tostring(gQ.Value) }
    elseif Type == "Dropdown" then
        return { idx = gP, type = "Dropdown", multi = gQ.Multi == true, value = gQ.Value }
    elseif Type == "Input" then
        local r2 = gQ.Value or ""
        return { idx = gP, type = "Input", text = tostring(r2) }
    elseif Type == "ColorPicker" then
        return { idx = gP, type = "ColorPicker", value = gQ.Value:ToHex(), transparency = gQ.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = gP,
            type = "KeyPicker",
            mode = gQ.Mode,
            key = gQ.Value,
            modifiers = gQ.Modifiers,
            toggled = gQ.Toggled
        }
    else
        return nil
    end
end
local function onCopyJoinScript_JobID()
    local eO = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mB)
    mc(eO, "Copied join script to clipboard")
end
local function fn845()
    local n9 = lR()
    local oa = n9 and n9:FindFirstChild("HumanoidRootPart")
    return oa
end
local function fn868()
    local pk = {}
    mm(pk, Workspace:FindFirstChild("TornadoModel2"), 48)
    mm(pk, Workspace:FindFirstChild("TornadoModel"), 48)
    mm(pk, Workspace:FindFirstChild("killzone"), 20)
    lV(pk, "FallingMeteors", 45, 25)
    lV(pk, "LooseParts", 14, 15)
    lV(pk, "BrokenParts", 14, 15)
    lV(pk, "TornadoJunk", 16, 15)
    lV(pk, "GhostedBHParts", 24, 12)
    for i, child in ipairs(Workspace:GetChildren()) do
        if not mK[child.Name] then
            local pl = string.lower(child.Name)
            for k, v in mT do
                if string.find(pl, k, 1, true) then
                    mm(pk, child, v)
                    break
                end
            end
        end
    end
    return pk
end
local function fn870(S, T)
    if setclipboard then
        setclipboard(S)
    elseif toclipboard then
        toclipboard(S)
    end
    Library:Notify(T)
end
local function fn877()
    if not firetouchinterest then
        return false
    end
    local p7 = m5()
    if not p7 then
        return false
    end
    local ClockRemnants = Workspace:FindFirstChild("ClockRemnants")
    if not ClockRemnants then
        return false
    elseif tick() - m7 < 0.2 then
        return false
    else
        m7 = tick()
        local p9 = false
        for i, child in ipairs(ClockRemnants:GetChildren()) do
            local p8_1 = child.Name == "Remanat(unactivated)" or child:GetAttribute("IsClockRemnant") == true
            if p8_1 then
                local Ray2 = child:FindFirstChild("Ray2")
                local qa_1 = Ray2 and Ray2:IsA("BasePart")
                if qa_1 then
                    pcall(firetouchinterest, Ray2, p7, 0)
                    pcall(firetouchinterest, Ray2, p7, 1)
                    p9 = true
                end
            end
        end
        return p9
    end
end
local function fn883()
    local qX_1
    local qW_1
    if identifyexecutor then
        qX_1, qW_1 = identifyexecutor()
        local qY = qX_1 ~= ""
        local qZ = type(qX_1) == "string" and qY
        if qZ then
            local qY_1 = type(qW_1) == "string" and qW_1 ~= "" and qX_1 .. " " .. qW_1
            lB = qY_1 or qX_1
        end
    end
end
local function fn891(cR)
    local cT, cU, cV, cW = lP()
    local cX = math.max(cV - 18, 24)
    local cY = math.max(cW - 18, 24)
    return {
        Vector3.new(cT + cX, cR, cU),
        Vector3.new(cT - cX, cR, cU),
        Vector3.new(cT, cR, cU + cY),
        Vector3.new(cT, cR, cU - cY),
        Vector3.new(cT + cX, cR, cU + cY),
        Vector3.new(cT + cX, cR, cU - cY),
        Vector3.new(cT - cX, cR, cU + cY),
        Vector3.new(cT - cX, cR, cU - cY)
    }
end
local function fn897()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    ml = tick()
end
local function fn921()
    mc(mn, "Copied Discord invite to clipboard")
end
MapBoundsHalfZ = nil
lB = nil
lC = nil
MapBoundsHalfX = nil
lE = nil
MapCenterZ = nil
lG = nil
__tempo_gen = nil
lI = nil
lJ = nil
connection4 = nil
MapCenterX = nil
lM = nil
lN = nil
lO = nil
lP = nil
DisasterAmpCooldownRounds = nil
lR = nil
PendingExtraDisasters = nil
lT = nil
Status = nil
lV = nil
lW = nil
lX = nil
DisasterActive = nil
lZ = nil
RequestSpawn = nil
l0 = nil
l1 = nil
l2 = nil
l3 = nil
RequestDailyRewardState = nil
ClaimDailyReward = nil
l6 = nil
BuyGearEvent = nil
l8 = nil
l9 = nil
BuyExtraDisaster = nil
mb = nil
mc = nil
md = nil
me = nil
mf = nil
ShopConfig = nil
mh = nil
mi = nil
mj = nil
connection2 = nil
ml = nil
mm = nil
mn = nil
mo = nil
mp = nil
mq = nil
Options = nil
ms = nil
mt = nil
LocalPlayer = nil
Toggles = nil
mw = nil
mx = nil
connection3 = nil
Workspace = nil
SaveManager = nil
mB = nil
mC = nil
mD = nil
mF = nil
Label = nil
mH = nil
mI = nil
mK = nil
mL = nil
mM = nil
mN = nil
connection = nil
mP = nil
HttpService = nil
mR = nil
mT = nil
mU = nil
mV = nil
VirtualUser = nil
Library = nil
mY = nil
mZ = nil
m_ = nil
UserInputService = nil
m1 = nil
connection5 = nil
m3 = nil
m4 = nil
m5 = nil
m6 = nil
m7 = nil
local CoreGui, GuiService, mS
CoreGui = nil
GuiService = nil
mS = nil
local ny, nB
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer = nil, nil, nil, nil, nil, nil, nil
local s1_16 = game:GetService("Players")
local s1_9 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = s1_16.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
if setthreadidentity then
    setthreadidentity(8)
end
ShopConfig, BuyExtraDisaster, BuyGearEvent, ClaimDailyReward, RequestDailyRewardState, RequestSpawn, DisasterActive, Status, PendingExtraDisasters, DisasterAmpCooldownRounds, MapCenterX, MapCenterZ, MapBoundsHalfX, MapBoundsHalfZ, m6, m3, Library, SaveManager, Toggles, Options, mn, mi, mU, mH, mC, mw, ms, mo, mj, md, mc, l0, lT, lG = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local s1_1 = "Parkour Pandemic"
ShopConfig = require(s1_9:WaitForChild("ShopConfig"))
BuyExtraDisaster = s1_9:WaitForChild("BuyExtraDisaster")
BuyGearEvent = s1_9:WaitForChild("BuyGearEvent")
ClaimDailyReward = s1_9:WaitForChild("ClaimDailyReward")
RequestDailyRewardState = s1_9:WaitForChild("RequestDailyRewardState")
RequestSpawn = s1_9:WaitForChild("RequestSpawn")
DisasterActive = s1_9:WaitForChild("DisasterActive")
Status = s1_9:WaitForChild("Status")
PendingExtraDisasters = s1_9:WaitForChild("PendingExtraDisasters")
DisasterAmpCooldownRounds = s1_9:WaitForChild("DisasterAmpCooldownRounds")
MapCenterX = s1_9:WaitForChild("MapCenterX")
MapCenterZ = s1_9:WaitForChild("MapCenterZ")
MapBoundsHalfX = s1_9:WaitForChild("MapBoundsHalfX")
MapBoundsHalfZ = s1_9:WaitForChild("MapBoundsHalfZ")
m6 = 2000
m3 = { "SpeedGear", "BoostGear", "PowerGear" }
Library = getgenv().Library
pcall(fn596)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
mn = "https://discord.gg/K7Qxnxkk46"
mi = "https://discord.gg/K7Qxnxkk46"
mc = fn870
l0 = fn921
lT = fn637
lG = fns.fn107
local s1_13 = "#7fd47f"
local s1_3 = "#6ec1ff"
mU = "#e8a34d"
local s1_21 = "#8b93a3"
mH = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
mC = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
mw = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ms = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
mo = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
mj = ""
md = ""
local s1_17 = "#345d9d"
local s1_7 = "#f7931a"
local s1_25 = "#627eea"
local s1_14 = "#26a17b"
local s1_5 = "#14f195"
local s1_22 = "#0070ba"
local s1_12 = "#008cff"
local s1_2 = getgenv and getgenv()
s1_16 = {}
local s1_27 = s1_2
local nN = if s1_27 then 1 else 0
local nL = 3423 * nN + 2580 * (1 - nN)
local nM = 3811 * nN + 3086 * (1 - nN)
if not ((nL * 1242 + nM * 2527 + nL * nM) % 16777213 == 10149603) then
    s1_27 = s1_16
end
lM = s1_27
s1_16 = lM.__tempo_gen or 0
__tempo_gen, s1_9 = nil, nil
s1_27 = 5
repeat
    s1_2 = (s1_27 * 1 + 1) % 2 + 1
    if s1_2 <= 1 then
        s1_2 = {
            "apq",
            "knerqhcmwph",
            "xwcuusa",
            "hglkoccesgv",
            "cezbk",
            "vntxtau",
            "wlujcdhlx",
            "sviezk",
            "mxhfrvm",
            "vjhedqf",
            "alzhqoo",
            "bpggf"
        }
        if s1_2[(s1_27 * 57 + 79) % 12 + 1] <= s1_2[(s1_27 * 57 + 79) % 12 + 1] then
            lM.__tempo_gen = s1_16 + 1
            __tempo_gen = lM.__tempo_gen
        else
            lM.__tempo_gen = __tempo_gen + 1
            lM = s1_16.__tempo_gen
        end
        s1_27 = (s1_27 + 5) % 8
    else
        if s1_27 * 48064299 + 5 + 5 <= s1_27 * 48064299 + 5 + 5 + 5 then
            s1_9 = lM.__tempo_cleanup
        else
            lM = s1_9.__tempo_cleanup
        end
        s1_27 = (s1_27 + 7) % 8
    end
until (s1_27 * 3 + 4) % 8 == 7
if type(s1_9) == "function" then
    s1_16 = 4
    repeat
        s1_27 = {
            "nzzj",
            "bfcmfoo",
            "vomye",
            "jcabhb",
            "rjmuobwbc",
            "jazxmmukb",
            "ngcezyv",
            "bychqesmk",
            "jekv",
            "xfchj",
            "ovymioovsob",
            "ltss"
        }
        local tW = s1_16
        s1_2 = s1_27[tW % 12 + 1]
        if s1_2:len() <= s1_2:reverse():rep(tW % 3 + 2):len() then
            pcall(s1_9)
            lM.__tempo_cleanup = nil
        else
            pcall(lM)
            s1_9.__tempo_cleanup = nil
        end
        s1_16 = (s1_16 + 7) % 8
    until (s1_16 * 5 + 2) % 8 == 1
end
lC, m7, m4, m1, mZ, mV, mM, mI, mT, mK, s1_2, mD, l9, lR, lI, m5, mN, mp, l2, lJ, m_, mx, lZ, lP, mR, mm, lV, mF, lW, mY, me, lN, lO, mt, l6, mP, lX, mh, s1_23 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lC = 0
m7 = 0
m4 = 0
m1 = 0
mZ = 0
mV = nil
mM = {}
mI = 0
mD = fns.fn140
l9 = fns.fn324
lR = fns.fn435
lI = fns.fn135
m5 = fn845
mN = function(a5, ...)
    local a6
    a6 = { ... }
    pcall(function()
        a5:FireServer(table.unpack(a6))
    end)
end
mp = fns.fn81
l2 = function(bg)
    if typeof(bg) ~= "Vector3" then
        return
    end
    if not Workspace.StreamingEnabled then
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(bg)
    end)
end
lJ = fns.fn113
m_ = fns.fn336
mx = fn505
lZ = fn464
lP = fns.fn320
mR = function(bT)
    local oW_1
    local oV_1
    if bT:IsA("BasePart") then
        return bT.Position, math.max(bT.Size.X, bT.Size.Z) * 0.5, bT.Position.Y + bT.Size.Y * 0.5
    elseif bT:IsA("Model") then
        oV_1, oW_1 = pcall(function()
            return bT:GetPivot()
        end)
        if not oV_1 then
            return nil
        end
        local oV_2 = bT:GetExtentsSize()
        return oW_1.Position, math.max(oV_2.X, oV_2.Z) * 0.5, oW_1.Position.Y + oV_2.Y * 0.5
    else
        return nil
    end
end
mm = fn769
lV = fns.fn345
mT = {
    tornado = 48,
    meteor = 40,
    blackhole = 40,
    wave = 30,
    tide = 30,
    star = 25,
    ember = 20,
    frost = 20
}
mK = {
    FallingMeteors = true,
    TornadoJunk = true,
    TornadoDirtVacuum = true,
    TornadoModel2 = true,
    TornadoModel = true,
    killzone = true,
    BaseplateWater = true,
    LooseParts = true,
    BrokenParts = true,
    GhostedBHParts = true,
    DisasterAmpModel = true,
    DisasterAmpDetectionCircle = true
}
mF = fn868
lW = fn603
mY = fn619
me = fn891
lN = fns.fn111
lO = fn877
mt = fn628
l6 = fns.fn245
mP = fn686
lX = fn494
mh = fns.fn373
if ((lN and not lI or not s1_23 and me) and (s1_23 or me or (not me or not s1_23)) or (not lN and s1_23 or (s1_23 or not me)) and ((lI or lI) and (me or not lI))) and not ((lN and not lI or not s1_23 and me) and (s1_23 or me or (not me or not s1_23)) or (not lN and s1_23 or (s1_23 or not me)) and ((lI or lI) and (me or not lI))) then
    s1_1 = s1_2:CreateWindow({
        CornerRadius = 0,
        Footer = { { Text = Library, Copyable = true }, mn, "|" },
        NotifySide = "Right",
        Title = "Tempo",
        ShowCustomCursor = false,
        Font = Enum.Font.BuilderSans,
        Icon = 78539693571783
    })
else
    s1_2 = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = mn, Copyable = true }, "|", s1_1 },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0
    })
end
local s1_6 = {
    Info = s1_2:AddTab("Info", "info"),
    Main = s1_2:AddTab("Main", "gamepad-2"),
    Shop = s1_2:AddTab("Shop", "shopping-bag"),
    Player = s1_2:AddTab("Player", "person-standing"),
    Settings = s1_2:AddTab("Settings", "settings")
}
s1_23 = fn718
for k, v in s1_6 do
    s1_23(v)
end
lB, s1_27, s1_2, Label, mB, s1_9 = nil, nil, nil, nil, nil, nil
s1_16 = 20
repeat
    s1_23 = (s1_16 * 2 + 1) % 3 + 1
    if s1_23 <= 2 then
        if s1_23 <= 1 then
            s1_23 = (vector.create((s1_16 * 1 + 3) % 11 + 1, (s1_16 * 2 + 3) % 13 + 1, (s1_16 * 13 + 6) % 17 + 1))
            s1_26 = (vector.create((s1_16 * 6 + 4) % 11 + 1, (s1_16 * 4 + 2) % 13 + 1, (s1_16 * 8 + 11) % 17 + 1))
            local t_ = vector.dot(s1_23, s1_26)
            if t_ * t_ <= vector.dot(s1_23, s1_23) * vector.dot(s1_26, s1_26) then
                mB = tostring(game.JobId)
            else
                s1_2 = tostring(game.JobId)
            end
            s1_16 = (s1_16 + 8) % 24
        else
            s1_23 = {
                "ugnujqxahsfs",
                "zgdhjkrh",
                "edetkvbas",
                "gjlcdcpcg",
                "ohyumxg",
                "jkiay",
                "crmdxeobm",
                "cacai",
                "jjk",
                "sdchacqjyogt",
                "rlrbax",
                "gxycxcse",
                "vqeni",
                "srfzpu"
            }
            if s1_23[(s1_16 * 71 + 6) % 14 + 1] < s1_23[(s1_16 * 71 + 6) % 14 + 1] then
                mB = #s1_9 > 18
            else
                s1_9 = #mB > 18
            end
            s1_16 = (s1_16 + 8) % 24
        end
    else
        if (s1_16 * 2 + 1) * 4 % 3 == ((s1_16 * 2 + 1) * 4 + 0) % 3 then
            lB = "Unknown"
            pcall(fn883)
            s1_27 = s1_6.Info:AddLeftGroupbox("Account", "circle-user")
            s1_27:AddLabel(lG("User", LocalPlayer.Name, s1_13), true)
            s1_27:AddLabel(lG("Status", "Keyless", s1_13), true)
            s1_27:AddLabel(lG("Executor", lB, s1_13), true)
            s1_2 = s1_6.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            s1_2:AddLabel(lT(s1_1 .. " [" .. tostring(game.PlaceId) .. "]", s1_3), true)
            s1_2:AddLabel(lG("Place ID", tostring(game.PlaceId), s1_3), true)
            Label = s1_2:AddLabel(lG("Session time", "0s", mU), true)
        else
            s1_1 = "Unknown"
            pcall(fn883)
            s1_6 = s1_27.Info:AddLeftGroupbox("Account", "circle-user")
            s1_6:AddLabel(s1_2("User", lG.Name, Label), true)
            s1_6:AddLabel(s1_2("Status", "Keyless", Label), true)
            s1_6:AddLabel(s1_2("Executor", "Unknown", Label), true)
            lB = s1_27.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            lB:AddLabel(LocalPlayer(s1_13 .. " [" .. tostring(game.PlaceId) .. "]", lT), true)
            lB:AddLabel(s1_2("Place ID", tostring(game.PlaceId), lT), true)
            mU = lB:AddLabel(s1_2("Session time", "0s", s1_3), true)
        end
        s1_16 = (s1_16 + 14) % 24
    end
until (s1_16 * 23 + 22) % 24 == 20
if s1_9 then
    s1_16 = 2
    repeat
        s1_27 = (vector.create((s1_16 * 3 + 1) % 11 + 1, (s1_16 * 5 + 10) % 13 + 1, (s1_16 * 10 + 5) % 17 + 1))
        local tJ = vector.floor(s1_27) + vector.ceil(s1_27 * -1)
        if vector.dot(tJ, tJ) == 2 then
            mB = string.sub(s1_9, 1, 18) .. "..."
        else
            s1_9 = string.sub(mB, 1, 18) .. "..."
        end
        s1_16 = (s1_16 + 2) % 4
    until (s1_16 * 3 + 0) % 4 == 0
end
s1_16 = s1_9 or mB
l8, connection, connection2, mf, connection3, mq, ml, connection4, connection5, nB, lE, l3, mS, mb, l1, mL, ny = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local nz = s1_16
s1_2:AddLabel(lG("Server", nz, s1_21), true)
s1_2:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
l8 = os.clock()
task.spawn(worker)
s1_26 = s1_6.Info:AddRightGroupbox("Scripts", "package")
s1_26:AddLabel(lT("Included in this hub", s1_21), true)
s1_26:AddLabel(lT(s1_1, s1_3), true)
s1_9 = s1_6.Info:AddRightGroupbox("Features", "list")
s1_9:AddLabel(lT("Auto Farm", s1_3), true)
s1_9:AddLabel(lT("Auto Shop", mU), true)
s1_9:AddLabel(lT("Misc Utilities", s1_21), true)
s1_27 = s1_6.Info:AddRightGroupbox("Socials", "link")
s1_27:AddButton({ Text = "Discord", Func = l0 })
s1_27:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = s1_6.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = l0 })
local DonationsGroup = s1_6.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(lT("All donations are optional but appreciated.", mU), true)
DonationsGroup:AddLabel(lT("If you donate you get a special role, just PING after you donate.", s1_13), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(lT("LTC / Litecoin", s1_17), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
DonationsGroup:AddLabel(lT("BTC / Bitcoin", s1_7), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(lT("ETH / Ethereum", s1_25), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(lT("USDT", s1_14), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
DonationsGroup:AddLabel(lT("Solana", s1_5), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(lT("PayPal", s1_22), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(lT("Venmo", s1_12), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(lT("Don't have any of the listed currencies but still wanna donate?", s1_21), true)
DonationsGroup:AddLabel(lT("DM me and we'll work something out.", s1_3), true)
local FaqGroup = s1_6.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = s1_6.Main:AddLeftGroupbox("Farm", "zap")
FarmGroup:AddToggle("AutoFarm", { Text = "Auto Farm", Default = false })
FarmGroup:AddToggle("AutoBeacons", { Text = "Auto Beacons", Default = false })
FarmGroup:AddToggle("AutoDaily", { Text = "Auto Claim Daily Rewards", Default = false })
local TeleportGroup = s1_6.Main:AddRightGroupbox("Teleport", "map-pin")
TeleportGroup:AddButton({ Text = "Teleport to Border", Func = fns.onTeleportToBorder })
local ShopGroup = s1_6.Shop:AddLeftGroupbox("Shop", "store")
ShopGroup:AddToggle("AutoBuyDisasters", { Text = "Auto Buy Extra Disasters", Default = false })
ShopGroup:AddSlider("ExtraDisasterAmount", { Text = "Extra Disasters", Default = 1, Min = 1, Max = 10, Rounding = 0 })
ShopGroup:AddToggle("AutoBuyGears", { Text = "Auto Buy Gears", Default = false })
local MovementGroup = s1_6.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
s1_23 = s1_6.Player:AddRightGroupbox("Fly", "feather")
s1_23:AddToggle("Fly", { Text = "Fly", Default = false })
s1_23:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
lE = function(fp)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not fp)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fp
        end
    end)
    if not fp then
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
Toggles.AntiGameplayPause:OnChanged(fn734)
Toggles.Fly:OnChanged(fns.fn191)
Toggles.WalkSpeedEnabled:OnChanged(fns.fn12)
connection = RunService.Stepped:Connect(fns.onStepped)
connection2 = UserInputService.JumpRequest:Connect(onJumpRequest)
mf = Workspace.CurrentCamera
connection3 = RunService.RenderStepped:Connect(fns.onRenderStepped)
local MenuGroup = s1_6.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
mq = tick()
ml = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local rS = v
        pcall(function()
            rS:Disable()
        end)
    end
end)
l3 = fn897
connection4 = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection5 = UserInputService.InputChanged:Connect(onInputChanged)
if (DonationsGroup and not l1) or (MovementGroup and not MovementGroup or ny) or not ((DonationsGroup and not l1) or (MovementGroup and not MovementGroup or ny)) then
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(s1_6.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/ParkourPandemic")
    nB = SaveManager:BuildConfigSection(s1_6.Settings)
else
    Library:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Library:AddButton({ Text = "Unload", Func = onUnload })
    s1_6:SetLibrary(nB)
    s1_6:SetFolder("TempoHub")
    s1_6:SaveDefault("Evil Hello Kitty")
    s1_6:ApplyToTab(SaveManager.Settings)
    s1_6:LoadDefault()
    ThemeManager:SetLibrary(nB)
    ThemeManager:IgnoreThemeSettings()
    ThemeManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    ThemeManager:SetFolder("TempoHub/ParkourPandemic")
    ThemeManager:BuildConfigSection(SaveManager.Settings)
end
mS = fn438
mb = fn786
l1 = fn727
mL = function(g5)
    local sm
    sm = nil
    local sn = type(g5) ~= "table" or type(g5.idx) ~= "string" or type(g5.type) ~= "string" or SaveManager.Ignore[g5.idx]
    if sn then
        return false
    end
    sm = mS(g5.type, g5.idx)
    if not sm then
        return false
    end
    local sn_1 = pcall(function()
        if g5.type == "Input" then
            if type(g5.text) ~= "string" then
                return
            end
            sm:SetValue(g5.text)
        elseif g5.type == "ColorPicker" then
            sm:SetValueRGB(Color3.fromHex(g5.value), g5.transparency)
        elseif g5.type == "KeyPicker" then
            sm:SetValue({ g5.key, g5.mode, g5.modifiers })
            if g5.mode == "Toggle" and g5.toggled ~= nil then
                sm.Toggled = g5.toggled
                sm:Update()
            end
        else
            sm:SetValue(g5.value)
        end
    end)
    return sn_1
end
do
    nB:AddDivider()
    nB:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    nB:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
    nB:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
    SaveManager:LoadAutoloadConfig()
    task.spawn(fns.worker2)
    task.spawn(antiGameplayPauseLoop)
    task.spawn(antiAfkLoop)
    ny = fn548
end
lM.__tempo_cleanup = ny
Library:OnUnload(fn688)
end)(...)
