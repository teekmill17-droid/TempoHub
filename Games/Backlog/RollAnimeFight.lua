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
getgenv().TempoHoodSubtitle = "ROLL ANIME & FIGHT"
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
local FH_4_1
local sP
local tw
local su
local sV
local Options
local LocalPlayer
local s0
local tI
local tp
local sO
local tv
local tc
local tB
local sB
local ti
local s_
local tH
local sH
local s5
local tN
local Workspace
local ss
local tb
local sT
local tA
local sA
local th
local tn
local s4
local tM
local sM
local tt
local sr
local sS
local sy
local SharedConfig
local sY
local tF
local sF
local tm
local tL
local sL
local ts
local sq
local s9
local sR
local ty
local sw
local tf
local sX
local tE
local Library
local tl
local s2
local Toggles
local tr
local s8
local sQ
local sv
local te
local sW
local tk
local sJ
local tq
local SkillConfig
local tP
local function onOnClientEvent3(eZ)
    local x8 = typeof(eZ) == "table" and eZ.team == "Enemy"
    if x8 then
        if eZ.id ~= nil then
            tq[eZ.id] = nil
        end
        if typeof(eZ.position) == "Vector3" then
            local x8_1 = eZ.id
            local yc = if x8_1 then 1 else 0
            local ya = 853 * yc + 3246 * (1 - yc)
            local yb = 3971 * yc + 3036 * (1 - yc)
            if not ((ya * 3474 + yb * 1612 + ya * yb) % 16777213 == 12751837) then
                x8_1 = 0
            end
            tq[x8_1] = { pos = eZ.position, at = os.clock() }
        end
    end
end
local function fn46(dI)
    if dI == nil or tk.kind == dI then
        tk.goal = nil
        tk.lookAt = nil
        tk.kind = nil
    end
end
local function fn77()
    local zV = if os.clock() - sW.sword < 1.2 then 1 else 0
    if zV == 1 then
        return
    end
    sW.sword = os.clock()
    local zL = s8("RequestForgeState")
    local zM = typeof(zL) ~= "table" or typeof(zL.catalog) ~= "table"
    if zM then
        tt("Sword", "No forge")
        return
    end
    local zM_1 = nil
    for k, v in zL.catalog do
        local zN_1 = typeof(v) == "table" and not v.premium and not v.starter
        if zN_1 then
            local zN_2 = zL.owned and zL.owned[v.id]
            local zN_3 = v.affordable == true
            local zP = v.progressionUnlocked == true
            local zQ = tonumber(v.damage) or 0
            if zP and (zN_2 or zN_3) then
                if not zM_1 or zQ > zM_1.damage then
                    zM_1 = { id = v.id, damage = zQ, owned = zN_2 == true, name = v.displayName }
                end
            end
        end
    end
    if not zM_1 then
        tt("Sword", "None available")
        return
    end
    if not zM_1.owned then
        local zL_1 = s8("PurchaseWeapon", zM_1.id)
        local zN_6 = typeof(zL_1) == "table" and zL_1.success
        if not zN_6 then
            tt("Sword", "Buy failed")
            return
        end
    end
    s8("RequestEquipWeapon", zM_1.id)
    local zL_2 = zM_1.name or zM_1.id
    tt("Sword", zL_2)
end
local function fn82()
    if os.clock() - sW.armor < 1.5 then
        return
    end
    sW.armor = os.clock()
    local z1 = s8("RequestArmorState")
    local z2 = typeof(z1) ~= "table" or typeof(z1.catalog) ~= "table"
    if z2 then
        tt("Armor", "No armor")
        return
    end
    local z2_1 = (tonumber(z1.forgeStones))
    local Ad = if z2_1 then 1 else 0
    local Ab = 3715 * Ad + 1992 * (1 - Ad)
    local Ac = 2800 * Ad + 3664 * (1 - Ad)
    if not ((Ab * 145 + Ac * 2308 + Ab * Ac) % 16777213 == 625862) then
        z2_1 = 0
    end
    local z3 = {}
    local z4 = z2_1
    for k, v in z1.catalog do
        local z2_2 = typeof(v) == "table" and v.id and v.slot
        if z2_2 then
            local z2_3 = tonumber(v.forgeStoneCost) or 0
            local z2_4 = z1.owned and z1.owned[v.id]
            local z7 = (sR[v.rarity] or 0) * 1000 + z2_3
            local z2_6 = z3[v.slot]
            local z9 = z2_4 or z2_3 <= z4
            if z9 then
                z9 = not z2_6 or z7 > z2_6.score
            end
            if z9 then
                z3[v.slot] = { id = v.id, score = z7, owned = z2_4 == true, cost = z2_3, name = v.displayName }
            end
        end
    end
    local z2_7 = 0
    for k, v in z3 do
        local z1_1 = not v.owned
        if z1_1 ~= false then
            z1_1 = v.cost <= z4
        end
        if z1_1 then
            local z1_2 = s8("PurchaseArmor", v.id)
            local z3_1 = typeof(z1_2) == "table" and z1_2.success
            if z3_1 then
                z4 -= v.cost
                v.owned = true
            end
        end
        if v.owned then
            local z1_3 = s8("RequestEquipArmor", v.id)
            local z3_2 = typeof(z1_3) == "table" and z1_3.success
            if z3_2 then
                z2_7 += 1
            end
        end
    end
    local z2_8 = z2_7 > 0 and "Equipped " .. z2_7 or "Waiting"
    tt("Armor", z2_8)
end
local function fn106()
    if os.clock() - sW.attack < 0.08 then
        return
    end
    sW.attack = os.clock()
    local yP = s8("RequestAutoSwingState")
    local yQ = typeof(yP) == "table" and yP.hasGamepass and not yP.enabled
    if yQ then
        s8("SetAutoSwingEnabled", true)
    end
    tN("SwordAttackRequested")
    tt("Attack", "Swinging")
end
local function fn168()
    tv(tP, "Copied Discord invite to clipboard")
end
local function fn188()
    if os.clock() - sW.potion < 1 then
        return
    end
    sW.potion = os.clock()
    local Aq = s8("RequestPotionState")
    local Ar = typeof(Aq) ~= "table" or typeof(Aq.inventory) ~= "table"
    if Ar then
        tt("Potions", "No potions")
        return
    end
    local Ar_1 = 0
    for k, v in sB do
        local As = tonumber(Aq.inventory[v]) or 0
        if As > 0 then
            local As_1 = s8("UsePotion", v)
            local At_1 = typeof(As_1) == "table" and As_1.success
            if At_1 then
                Ar_1 += 1
            end
        end
    end
    local Ar_2 = Ar_1 > 0 and "Used " .. Ar_1 or "None ready"
    tt("Potions", Ar_2)
end
local function fn199()
    local Character = LocalPlayer.Character
    local uM = Character and Character:FindFirstChildOfClass("Humanoid")
    return uM
end
local function fn214()
    local zc_1
    local zb_1
    local y7 = tw("FarmMode", "Overhead")
    local y9 = y7 == "Orbit" and 0.05
    local zj = if y9 then 1 else 0
    local zh = 3896 * zj + 3134 * (1 - zj)
    local zi = 408 * zj + 2892 * (1 - zj)
    if not ((zh * 719 + zi * 1505 + zh * zi) % 16777213 == 5004832) then
        y9 = 0.15
    end
    local y8_1 = y9
    local y9_1 = os.clock() - sW.farm < y8_1 and tk.kind == "farm" and tk.goal
    local za = y9_1 and y7 ~= "Orbit"
    local za_3
    if za then
        local y8_3 = tA()
        if y8_3 then
            local y9_2 = sy(y8_3.Position)
            local za_1 = y9_2 and su(y8_3.Position, y9_2, tk.goal, 8)
            if za_1 then
                tN("SwordAttackRequested")
                tt("Farm", y7)
            end
        end
        return
    end
    sW.farm = os.clock()
    local y8_4 = tA()
    if not y8_4 then
        tt("Farm", "No character")
        tn("farm")
        return
    end
    local y9_3 = s8("RequestBossRaidState")
    local za_2 = typeof(y9_3) == "table" and y9_3.inRaid
    if za_2 then
        tt("Farm", "In raid")
        tn("farm")
        return
    end
    local y9_4 = sy(y8_4.Position)
    if not y9_4 then
        if tk.kind == "farm" then
            tn("farm")
        end
        tt("Farm", "Waiting")
        return
    end
    zb_1, za_3, zc_1 = sY(y9_4, y8_4.Position)
    local zd = tk.kind == "farm" and tk.goal
    if zd then
        local ze_1 = tk.lookAt or tk.goal
        zd = tr(ze_1, y9_4) < 6
    end
    local zd_1 = y7 == "Orbit" or not zd
    if not zd_1 then
        zd_1 = (y8_4.Position - (tk.goal or zb_1)).Magnitude > 10
    end
    if zd_1 then
        sw(zb_1, "farm", za_3)
    else
        tk.lookAt = za_3
        if y7 == "Overhead" then
            tk.goal = Vector3.new(y9_4.X, y9_4.Y + 6, y9_4.Z)
        elseif y7 == "Behind" then
            sw(zb_1, "farm", za_3)
        end
    end
    local zs = if su(y8_4.Position, y9_4, zb_1, zc_1) then 1 else 0
    if zs == 1 then
        tN("SwordAttackRequested")
        tt("Farm", y7)
    else
        tt("Farm", "Approaching")
    end
end
local function fn219()
    if os.clock() - sW.raid < 1 then
        return
    end
    sW.raid = os.clock()
    local yo = s8("RequestBossRaidState")
    if typeof(yo) ~= "table" then
        tt("BossRaid", "No state")
        return
    end
    if yo.inRaid then
        local yp_1 = yo.encounterPhase or "In raid"
        tt("BossRaid", tostring(yp_1))
        if yo.encounterPhase == "Ended" or yo.phase == "Waiting" then
            s8("RequestBossRaidLeave")
            tt("BossRaid", "Left")
        end
        return
    end
    if yo.active and yo.arenaReady then
        local yp_4 = s8("RequestRunState")
        local yq_1 = typeof(yp_4) == "table" and yp_4.active
        if yq_1 then
            s8("RequestStopRun")
            task.wait(0.2)
        end
        local yp_5 = Workspace:FindFirstChild("BossRaidPortal") and Workspace.BossRaidPortal:FindFirstChild("BossRaidPortalHitbox")
        local yp_6 = tA()
        if yp_5 and yp_6 then
            yp_6.CFrame = yp_5.CFrame
            if firetouchinterest then
                for i, child in LocalPlayer.Character:GetChildren() do
                    if child:IsA("BasePart") then
                        pcall(firetouchinterest, child, yp_5, 0)
                    end
                end
                task.wait(0.1)
                for i, child in LocalPlayer.Character:GetChildren() do
                    if child:IsA("BasePart") then
                        pcall(firetouchinterest, child, yp_5, 1)
                    end
                end
            end
            tt("BossRaid", "Joining")
        else
            tt("BossRaid", "No portal")
        end
        return
    end
    local max = math.max
    local floor = math.floor
    local yr_2 = tonumber(yo.endsAt) or 0
    local ys = (tonumber(yo.serverNow))
    local yx = if ys then 1 else 0
    local yv = 178 * yx + 2777 * (1 - yx)
    local yw = 2375 * yx + 2168 * (1 - yx)
    if not ((yv * 663 + yw * 3028 + yv * yw) % 16777213 == 7732264) then
        ys = 0
    end
    local yt = max(0, floor(yr_2 - ys))
    tt("BossRaid", yo.phase .. " (" .. yt .. "s)")
end
local function fn253(fZ)
    local y_ = tw("FarmMode", "Overhead")
    if y_ == "Orbit" then
        local y0_1 = os.clock() * 1.75
        local y2_1 = Vector3.new(math.cos(y0_1) * 6, 3.5, math.sin(y0_1) * 6)
        return fZ + y2_1, fZ, 9
    elseif y_ == "Behind" then
        local y__1 = Vector3.new(0, 0, 1)
        local y0_2 = tl()
        local y1 = y0_2 and y0_2:FindFirstChild("EnterZone")
        local y2_2 = y0_2
        if y2_2 then
            y2_2 = y0_2:FindFirstChild("PlaceZone")
        end
        local y0_3 = y1
        local y1_1 = y2_2
        if y0_3 then
            y0_3 = y1_1
        end
        if y0_3 then
            y0_3 = y1:IsA("BasePart")
        end
        if y0_3 then
            y0_3 = y1_1:IsA("BasePart")
        end
        if y0_3 then
            local y0_4 = Vector3.new(y1.Position.X - y1_1.Position.X, 0, y1.Position.Z - y1_1.Position.Z)
            if y0_4.Magnitude > 0.1 then
                y__1 = y0_4.Unit
            end
        end
        return fZ + y__1 * 5 + Vector3.new(0, 3, 0), fZ, 8
    else
        return fZ + Vector3.new(0, 6, 0), fZ, 8
    end
end
local function fn265()
    if os.clock() - sW.roll < 0.12 then
        return
    end
    sW.roll = os.clock()
    tN("RollAnimationFinished")
    local vw = s8("RequestRoll")
    if typeof(vw) ~= "table" then
        tt("Roll", "No response")
        return
    end
    if vw.success ~= true then
        local vx = vw.reason or "Waiting"
        tt("Roll", tostring(vx))
        return
    end
    table.clear(tE)
    if typeof(vw.rolled) == "table" then
        for k, v in vw.rolled do
            table.insert(tE, v)
        end
    end
    tt("Roll", "Rolled " .. #tE)
    local vB = if sF("AutoBuyRoll") then 1 else 0
    if vB == 1 then
        tp()
    end
end
local function fn266(az)
    local ux = tw(az, {})
    if typeof(ux) ~= "table" then
        return {}
    end
    local uy = {}
    for k, v in ux do
        if v == true then
            uy[k] = true
        else
            local ux_1 = typeof(k) == "number" and typeof(v) == "string"
            if ux_1 then
                uy[v] = true
            end
        end
    end
    return uy
end
local function fn279(bI)
    local rarity = bI.rarity
    local u6 = bI.mutation or "Normal"
    if typeof(rarity) ~= "string" then
        return false
    end
    local u6_1 = sR[tw("BuyRollMinRarity", "Rare")] or 1
    if (sR[rarity] or 0) < u6_1 then
        return false
    end
    local u6_3 = sT("BuyRollRarities")
    local u8_1 = next(u6_3) ~= nil and u6_3[rarity] ~= true
    if u8_1 then
        return false
    end
    local u5_1 = sT("BuyRollMutations")
    local u6_4 = next(u5_1) ~= nil and u5_1[u6] ~= true
    if u6_4 then
        return false
    end
    return true
end
local function fn301()
    if os.clock() - sW.buyRoll < 0.08 then
        return
    end
    sW.buyRoll = os.clock()
    if #tE == 0 then
        tt("BuyRoll", "Waiting")
        return
    end
    local vb = 0
    local vc = {}
    local vd = 0
    for k, v in tE do
        if ts(v) then
            local ve_1 = s8("PurchaseRolledUnit", v.slotIndex)
            local vf = typeof(ve_1) == "table" and ve_1.success
            if vf then
                vb += 1
            else
                table.insert(vc, v)
            end
        else
            vd += 1
        end
    end
    table.clear(tE)
    for k, v in vc do
        table.insert(tE, v)
    end
    if vb > 0 then
        local ve_2 = vd > 0 and " / skip " .. vd or ""
        tt("BuyRoll", "Bought " .. vb .. ve_2)
    elseif vd > 0 then
        tt("BuyRoll", "Skipped " .. vd)
    else
        tt("BuyRoll", "Waiting")
    end
end
local function fn309(dD, dE, dF)
    if typeof(dD) ~= "Vector3" then
        return
    end
    tk.goal = dD
    tk.kind = dE
    local w2 = typeof(dF) == "Vector3" and dF
    local w3 = w2 or nil
    tk.lookAt = w3
end
local function fn321(fV, fW)
    local fX = fV - fW
    return Vector3.new(fX.X, 0, fX.Z).Magnitude
end
local function worker()
    while not Library.Unloaded do
        task.wait(0.05)
        if sF("InstantAutoRoll") then
            pcall(s0)
        elseif ss.Roll ~= "Idle" then
            tt("Roll", "Idle")
        end
        if sF("AutoBuyRoll") then
            if not sF("InstantAutoRoll") then
                pcall(tp)
            end
        elseif ss.BuyRoll ~= "Idle" then
            tt("BuyRoll", "Idle")
        end
        if sF("AutoFastAttack") then
            pcall(sX)
        elseif ss.Attack ~= "Idle" then
            tt("Attack", "Idle")
        end
        if sF("AutoFarmMobs") then
            pcall(s_)
        else
            tn("farm")
            if ss.Farm ~= "Idle" then
                tt("Farm", "Idle")
            end
        end
        if sF("AutoCollectLoot") then
            pcall(tF)
        else
            tn("loot")
            if ss.Loot ~= "Idle" then
                tt("Loot", "Idle")
            end
        end
    end
end
local function fn403(dM)
    local w7 = tA()
    local goal = tk.goal
    if not (w7 and goal) then
        return false
    end
    local Position = w7.Position
    local xa = goal - Position
    local Magnitude = xa.Magnitude
    local xb = tk.kind == "farm" and tw("FarmMode", "Overhead") == "Orbit"
    local xb_1 = xb and 2.5 or tk.arrive
    local xc_1 = Position
    if Magnitude > xb_1 then
        local xb_2 = math.min(Magnitude, tk.speed * dM)
        xc_1 = Position + xa.Unit * xb_2
    end
    local lookAt = tk.lookAt
    if typeof(lookAt) == "Vector3" then
        if (lookAt - xc_1).Magnitude > 0.05 then
            w7.CFrame = CFrame.lookAt(xc_1, lookAt)
        else
            w7.CFrame = CFrame.new(xc_1)
        end
    else
        local w9_3 = Vector3.new(xa.X, 0, xa.Z)
        if w9_3.Magnitude > 0.05 then
            w7.CFrame = CFrame.lookAt(xc_1, xc_1 + w9_3.Unit)
        else
            w7.CFrame = CFrame.new(xc_1)
        end
    end
    w7.AssemblyLinearVelocity = Vector3.zero
    return Magnitude <= xb_1
end
local function fn409()
    local wL_2
    local wK_2
    if os.clock() - sW.place < 0.35 then
        return
    end
    sW.place = os.clock()
    local wF = s8("RequestRunState")
    local wG = typeof(wF) == "table" and wF.active
    if wG then
        tt("Place", "Waiting (run active)")
        return
    end
    local wF_1 = s8("RequestPlacementState")
    local wG_1 = s8("RequestInventory")
    local wH = typeof(wF_1) ~= "table" or typeof(wG_1) ~= "table"
    if wH then
        tt("Place", "No state")
        return
    end
    local wH_1 = tonumber(wF_1.slotsUsed) or 0
    local wH_2 = tonumber(wF_1.slotsMax) or 0
    local wJ_3
    if wH_1 >= wH_2 then
        tt("Place", "Slots full")
        return
    end
    local wH_3 = {}
    for k, v in wG_1.units do
        local unit = v.unit
        local wI_1 = typeof(unit) == "table" and not v.placed and not unit.locked
        if wI_1 then
            local insert = table.insert
            local uid = unit.uid
            local wK_1 = sR[unit.rarity] or 0
            local wL_1 = tonumber(unit.level) or 1
            insert(wH_3, { uid = uid, rank = wK_1, level = wL_1 })
        end
    end
    table.sort(wH_3, function(dd, de)
        if dd.rank ~= de.rank then
            return dd.rank > de.rank
        end
        return dd.level > de.level
    end)
    if #wH_3 == 0 then
        tt("Place", "No units")
        return
    end
    local wG_3 = tonumber(wF_1.footprint) or SharedConfig.Placement.FootprintSize
    local wI_3 = wG_3 or 6
    local wJ_2 = wF_1.placed or {}
    local wF_2 = {}
    local wI_5 = wJ_2
    local wX = 1
    while true do
        if wX <= 12 then
            wL_2, wK_2, wJ_3 = sQ(wI_5, wI_3, wF_2)
            if wL_2 == nil then
                tt("Place", "No free cell")
                return
            end
            local wM = s8("RequestPlacement", wH_3[1].uid, wL_2, wK_2, wJ_3)
            local wJ_4 = typeof(wM) == "table" and wM.success
            if wJ_4 then
                tt("Place", string.format("Placed @ %.1f,%.1f", wL_2, wK_2))
                return
            end
            local wJ_5 = typeof(wM) == "table"
            if wJ_5 then
                local wN = wM.reason or "Failed"
                wJ_5 = tostring(wN)
            end
            wJ_2 = wJ_5 or "Failed"
            if wJ_2 == "Overlapping" then
                wF_2[string.format("%.2f:%.2f", wL_2, wK_2)] = true
                table.insert(wI_5, { x = wL_2, z = wK_2 })
                tt("Place", "Retrying slot")
                wX += 1
                continue
            end
            break
        end
        tt("Place", "Overlapping")
        return
    end
    tt("Place", wJ_2)
    return
end
local function fn433()
    local w_ = os.clock()
    if tc and tc.Parent and w_ - s4 < 5 then
        return tc
    end
    local w0_1 = s8("RequestPlot")
    if typeof(w0_1) == "Instance" then
        tc = w0_1
        s4 = w_
    end
    return w0_1
end
local function onOnClientEvent2(eX)
    sM(eX)
end
local function fn521()
    if os.clock() - sW.playtime < 2 then
        return
    end
    sW.playtime = os.clock()
    local Bi = 0
    local Bo = 1
    while Bo <= 6 do
        local Bp = Bo
        local Bj_1 = s8("ClaimOnlineReward", Bp)
        local Bk = typeof(Bj_1) == "table" and Bj_1.success
        if Bk then
            Bi += 1
        end
        Bo += 1
    end
    local Bi_1 = Bi > 0 and "Claimed " .. Bi or "Waiting"
    tt("Playtime", Bi_1)
end
local function fn535()
    if os.clock() - sW.wave < 0.4 then
        return
    end
    sW.wave = os.clock()
    local yS = s8("RequestBossRaidState")
    local yT = typeof(yS) == "table" and yS.inRaid
    if yT then
        tt("Wave", "In raid")
        return
    end
    local yS_1 = s8("RequestRunState")
    local yT_1 = typeof(yS_1) ~= "table" or not yS_1.active
    if yT_1 then
        local yT_2 = s8("RequestStartRun")
        local yT_3 = yT_2 and "Started run" or "Starting"
        tt("Wave", yT_3)
        return
    end
    if yS_1.autoWaveAvailable and not yS_1.autoWaveEnabled then
        s8("RequestAutoWave", true)
    end
    local yT_5 = yS_1.waitingForNextWave
    if not yT_5 then
        local yU_2 = tonumber(yS_1.enemiesRemaining) or 1
        yT_5 = yU_2 <= 0
    end
    if yT_5 then
        local yT_6 = s8("RequestNextWave")
        local yU_3 = yT_6
        if yU_3 then
            local yT_7 = yS_1.wave or 0
            yU_3 = "Wave " .. tostring(yT_7 + 1)
        end
        local yT_8 = yU_3
        local yZ_1 = if yT_8 then 1 else 0
        local yX_1 = 3507 * yZ_1 + 983 * (1 - yZ_1)
        local yY_1 = 2956 * yZ_1 + 4039 * (1 - yZ_1)
        if not ((yX_1 * 2127 + yY_1 * 431 + yX_1 * yY_1) % 16777213 == 2322904) then
            local yU_4 = yS_1.wave or "?"
            yT_8 = "Wave " .. tostring(yU_4)
        end
        tt("Wave", yT_8)
        return
    end
    local yT_9 = yS_1.wave or "?"
    local yU_5 = tostring(yT_9)
    local yV = yS_1.enemiesRemaining
    local yZ_2 = if yV then 1 else 0
    local yX_2 = 100 * yZ_2 + 1641 * (1 - yZ_2)
    local yY_2 = 3842 * yZ_2 + 527 * (1 - yZ_2)
    if not ((yX_2 * 2664 + yY_2 * 1519 + yX_2 * yY_2) % 16777213 == 6486598) then
        yV = "?"
    end
    tt("Wave", "Wave " .. yU_5 .. " (" .. tostring(yV) .. " left)")
end
local function fn541(co, cp, cq, cr)
    for k, v in cq do
        local vY = tonumber(v.x)
        local vZ = tonumber(v.z)
        local v_ = vY and vZ and math.abs(co - vY) < cr and math.abs(cp - vZ) < cr
        if v_ then
            return true
        end
    end
    return false
end
local function fn544()
    if os.clock() - sW.skill < 1 then
        return
    end
    sW.skill = os.clock()
    local A6 = s8("RequestRunState")
    local A7 = typeof(A6) == "table" and A6.active
    if A7 then
        tt("Skills", "Waiting (run)")
        return
    end
    local A6_1 = s8("RequestSkills")
    if typeof(A6_1) ~= "table" then
        tt("Skills", "No skills")
        return
    end
    for k, v in SkillConfig.Order do
        local A7_1 = SkillConfig.getNode(v)
        if A7_1 and not A6_1[v] and A7_1.currency == "Coins" and not A7_1.isPremium then
            local prerequisite = A7_1.prerequisite
            if not prerequisite or A6_1[prerequisite] then
                local A8_2 = s8("PurchaseSkill", v)
                local A9_1 = A8_2 == true
                if not A9_1 then
                    local Ba = typeof(A8_2) == "table" and A8_2.success
                    A9_1 = Ba
                end
                if A9_1 then
                    local A8_3 = A7_1.displayName or v
                    tt("Skills", A8_3)
                    return
                end
            end
        end
    end
    tt("Skills", "Caught up")
end
local function fn606(aV, aW)
    tM[aW] = aV:AddLabel(sH("Idle", sP), true)
end
local function fn621(ac, ad)
    return string.format('<font color="%s">%s</font>', ad, ac)
end
local function fn656()
    local Character = LocalPlayer.Character
    local uP = Character and Character:FindFirstChild("HumanoidRootPart")
    return uP
end
local function fn686(d2)
    local xf = tl()
    local xf_7, xf_10
    if not xf then
        return false
    end
    local PlaceZone = xf:FindFirstChild("PlaceZone")
    local xg_2
    local EnterZone = xf:FindFirstChild("EnterZone")
    local xf_1 = PlaceZone and PlaceZone:IsA("BasePart")
    if xf_1 then
        local xf_2 = PlaceZone.CFrame:PointToObjectSpace(d2)
        local xi_1 = PlaceZone.Size * 0.5
        local xj_1 = math.abs(xf_2.X) <= xi_1.X + 12 and math.abs(xf_2.Z) <= xi_1.Z + 18
        if xj_1 then
            return true
        end
        local xf_3 = EnterZone and EnterZone:IsA("BasePart") and PlaceZone and PlaceZone:IsA("BasePart")
        if xf_7 then
            local xf_4 = PlaceZone.Position - EnterZone.Position
            local xg_1 = Vector3.new(xf_4.X, 0, xf_4.Z)
            if xg_2.Magnitude > 1 then
                local Unit = xg_1.Unit
                local xi_2 = d2 - EnterZone.Position
                xi_2:Dot(Unit)
                if xf_10 then
                    return true
                end
                return false
            end
            return false
        end
        return false
    end
    xf_7 = EnterZone and EnterZone:IsA("BasePart") and PlaceZone and PlaceZone:IsA("BasePart")
    if xf_7 then
        local xf_8 = PlaceZone.Position - EnterZone.Position
        xg_2 = Vector3.new(xf_8.X, 0, xf_8.Z)
        if xg_2.Magnitude > 1 then
            local Unit = xg_2.Unit
            local xi_3 = d2 - EnterZone.Position
            local xh_2 = xi_3:Dot(Unit)
            xf_10 = xh_2 >= -6 and xh_2 <= xg_2.Magnitude + 10 and (xi_3 - Unit * xh_2).Magnitude <= 28
            if xf_10 then
                return true
            end
            return false
        end
        return false
    end
    return false
end
local function fn785(by)
    local DiscordGroup = by:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = s2 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = s2 })
end
local function onHeartbeat(jQ)
    if Library.Unloaded then
        return
    end
    local B2 = sF("AutoFarmMobs") or sF("AutoCollectLoot")
    if not B2 then
        return
    end
    if tk.goal then
        sS(math.clamp(jQ, 0, 0.05))
    end
end
local function fn853(bl, bm)
    local u0 = sR[bl]
    local u1 = sR[bm]
    if not u0 or not u1 then
        return false
    end
    return u0 <= u1
end
local function fn865()
    local zw_1
    local zv_1, zv_2, zv_4
    local zB = if os.clock() - sW.loot < 0.2 then 1 else 0
    if zB == 1 then
        return
    end
    sW.loot = os.clock()
    local zt = tA()
    local zt_1, zt_6
    if not zt then
        tt("Loot", "No character")
        tn("loot")
        return
    end
    local zu = sF("AutoFarmMobs") and sy(zt.Position)
    if zu then
        if tk.kind ~= "loot" then
            tt("Loot", "Farm priority")
        end
        return
    end
    local zu_1 = th()
    if #zu_1 == 0 then
        tn("loot")
        tt("Loot", "None")
        return
    end
    zw_1, zv_1 = te(zt.Position, zu_1)
    if not zw_1 then
        tn("loot")
        tt("Loot", "None")
        return
    end
    if zv_1 <= 7 then
        zt_1, zv_2 = tI(zw_1, zu_1, 14)
        local zt_2 = zt_1 or zw_1
        sw(zt_2 + Vector3.new(0, 2.2, 0), "loot")
        local zv_3 = zv_2 > 1 and "Sweep x" .. zv_2 or "Collecting"
        tt("Loot", zv_3)
        return
    end
    if tk.kind == "loot" and tk.goal then
        local zt_5 = false
        for k, v in zu_1 do
            if (v - tk.goal).Magnitude < 12 then
                zt_5 = true
                break
            end
        end
        if zt_5 then
            tt("Loot", "Moving")
            return
        end
    end
    zt_6, zv_4 = tI(zw_1, zu_1, 18)
    local zu_2 = zt_6 or zw_1
    local zt_7 = zu_2 + Vector3.new(0, 2.2, 0)
    sw(zt_7, "loot")
    local zu_3 = zv_4 > 1 and "To cluster x" .. zv_4 or "Moving"
    tt("Loot", zu_3)
end
local function fn890(e2)
    local yd = os.clock()
    local pos
    local yf = math.huge
    for k, v in tq do
        if yd - v.at > 4 then
            tq[k] = nil
        else
            local yg = typeof(v.pos) == "Vector3" and sq(v.pos)
            if yg then
                local Magnitude = (v.pos - e2).Magnitude
                if Magnitude < yf then
                    yf = Magnitude
                    pos = v.pos
                end
            end
        end
    end
    return pos, yf
end
local function worker3()
    while not Library.Unloaded do
        task.wait(0.75)
        if sF("AutoBuyBestSword") then
            pcall(tf)
        elseif ss.Sword ~= "Idle" then
            tt("Sword", "Idle")
        end
        if sF("AutoBuyEquipArmor") then
            pcall(sv)
        elseif ss.Armor ~= "Idle" then
            tt("Armor", "Idle")
        end
        if sF("AutoConsumePotions") then
            pcall(tm)
        elseif ss.Potions ~= "Idle" then
            tt("Potions", "Idle")
        end
        if sF("AutoMerchantBuyer") then
            pcall(sO)
        elseif ss.Merchant ~= "Idle" then
            tt("Merchant", "Idle")
        end
        if sF("AutoUpgradeSkillTree") then
            pcall(s9)
        elseif ss.Skills ~= "Idle" then
            tt("Skills", "Idle")
        end
        if sF("AutoClaimPlaytime") then
            pcall(sA)
        elseif ss.Playtime ~= "Idle" then
            tt("Playtime", "Idle")
        end
        if sF("AutoClaimBattlePass") then
            pcall(sV)
        elseif ss.BattlePass ~= "Idle" then
            tt("BattlePass", "Idle")
        end
        if sF("AutoClaimQuests") then
            pcall(tL)
        elseif ss.Quests ~= "Idle" then
            tt("Quests", "Idle")
        end
        if sF("SmartAutoSpin") then
            pcall(tH)
        elseif ss.Spin ~= "Idle" then
            tt("Spin", "Idle")
        end
    end
end
local function fn995(eG, eH, eI)
    local xO = Vector3.zero
    local xP = 0
    for k, v in eH do
        if (v - eG).Magnitude <= eI then
            xO += v
            xP += 1
        end
    end
    if xP == 0 then
        return nil, 0
    end
    return xO / xP, xP
end
local function worker2()
    while not Library.Unloaded do
        task.wait(0.25)
        if sF("AutoSellUnits") then
            pcall(tb)
        elseif ss.Sell ~= "Idle" then
            tt("Sell", "Idle")
        end
        if sF("SmartAutoPlace") then
            pcall(sL)
        elseif ss.Place ~= "Idle" then
            tt("Place", "Idle")
        end
        if sF("AutoNextWave") then
            pcall(tB)
        elseif ss.Wave ~= "Idle" then
            tt("Wave", "Idle")
        end
        if sF("BossRaid") then
            pcall(sJ)
        elseif ss.BossRaid ~= "Idle" then
            tt("BossRaid", "Idle")
        end
    end
end
local function fn1025()
    if os.clock() - sW.battlepass < 1.5 then
        return
    end
    sW.battlepass = os.clock()
    local Br = s8("RequestBattlepassState")
    if typeof(Br) ~= "table" then
        tt("BattlePass", "No state")
        return
    end
    local Bs = tonumber(Br.currentTier) or 1
    local Bt = 0
    local Bz = 1
    while Bz <= Bs do
        local BA = Bz
        local Bs_1 = Br.claimedFree
        if Bs_1 then
            Bs_1 = Br.claimedFree[BA]
        end
        if not Bs_1 then
            local Bs_2 = s8("ClaimBattlepassTier", BA, "free")
            local Bv_1 = typeof(Bs_2) == "table" and Bs_2.success
            if Bv_1 then
                Bt += 1
            end
        end
        if Br.hasPremium then
            local Bs_3 = Br.claimedPremium
            if Bs_3 then
                Bs_3 = Br.claimedPremium[BA]
            end
            if not Bs_3 then
                local Bs_4 = s8("ClaimBattlepassTier", BA, "premium")
                local Bv_3 = typeof(Bs_4) == "table" and Bs_4.success
                if Bv_3 then
                    Bt += 1
                end
            end
        end
        Bz += 1
    end
    local Bs_5 = Bt > 0 and "Claimed " .. Bt
    local BE = if Bs_5 then 1 else 0
    local BC = 3307 * BE + 982 * (1 - BE)
    local BD = 1349 * BE + 3285 * (1 - BE)
    if not ((BC * 3965 + BD * 202 + BC * BD) % 16777213 == 1068683) then
        Bs_5 = "Tier " .. Bs
    end
    tt("BattlePass", Bs_5)
end
local function fn1060(h_)
    local AB = h_.rewardType or ""
    local AC = tostring(AB)
    if AC == "Unit" then
        return "Unit"
    elseif AC == "Currency" then
        return "Currency"
    else
        local lower = string.lower
        local AE = h_.id or h_.displayName or ""
        local AD_1 = lower(tostring(AE))
        local AB_2 = AD_1:find("potion") or AD_1:find("booster")
        local AI = if AB_2 then 1 else 0
        local AG = 2492 * AI + 3749 * (1 - AI)
        local AH = 1984 * AI + 2847 * (1 - AI)
        if not ((AG * 2231 + AH * 1511 + AG * AH) % 16777213 == 13501604) then
            AB_2 = AD_1:find("luck_pair")
        end
        if not AB_2 then
            AB_2 = AD_1:find("shard_pair")
        end
        if AB_2 then
            return "Potion"
        end
        local AB_3 = AC == "Item" or AD_1:find("shard") or AD_1:find("forge") or AD_1:find("cache")
        if AB_3 then
            return "Item"
        elseif AC ~= "" then
            return "Other"
        else
            return "Item"
        end
    end
end
local function fn1109(eO)
    if typeof(eO) ~= "table" then
        return
    end
    local xX = eO.targetPosition or eO.position
    local xZ = eO.targetId or eO.id
    if typeof(xX) ~= "Vector3" then
        return
    end
    if xZ == nil then
        xZ = string.format("%.1f:%.1f:%.1f", xX.X, xX.Y, xX.Z)
    end
    tq[xZ] = { pos = xX, at = os.clock() }
end
local function fn1121(gf, gg, gh, gi)
    if tk.kind == "farm" and tk.goal then
        if (gf - tk.goal).Magnitude <= tk.arrive + 1.5 then
            return true
        elseif (gf - gh).Magnitude <= tk.arrive + 2 then
            return true
        else
            return tr(gf, gg) <= gi
        end
    elseif (gf - gh).Magnitude <= tk.arrive + 2 then
        return true
    else
        return tr(gf, gg) <= gi
    end
end
local function fn1168()
    if os.clock() - sW.sell < 0.75 then
        return
    end
    sW.sell = os.clock()
    local vI = s8("RequestInventory")
    local vJ = typeof(vI) ~= "table"
    local vQ = if vJ then 1 else 0
    local vO = 1715 * vQ + 1742 * (1 - vQ)
    local vP = 204 * vQ + 2385 * (1 - vQ)
    if not ((vO * 2906 + vP * 2965 + vO * vP) % 16777213 == 5938510) then
        vJ = typeof(vI.units) ~= "table"
    end
    if vJ then
        tt("Sell", "No inventory")
        return
    end
    local vJ_1 = tw("SellMaxRarity", "Uncommon")
    local vK = {}
    for k, v in vI.units do
        local unit = v.unit
        local vL_1 = typeof(unit) == "table" and not v.placed and not unit.locked
        if vL_1 then
            local rarity = unit.rarity
            local vM = typeof(rarity) == "string" and s5(rarity, vJ_1)
            if vM then
                table.insert(vK, unit.uid)
            end
        end
    end
    if #vK == 0 then
        tt("Sell", "Nothing to sell")
        return
    end
    local vI_2 = s8("SellUnits", vK)
    if typeof(vI_2) == "table" then
        local vJ_2 = vI_2.soldCount or 0
        local vK_1 = tostring(vJ_2)
        local vL_3 = vI_2.totalValue or 0
        tt("Sell", "Sold " .. vK_1 .. " (+" .. tostring(vL_3) .. ")")
    else
        tt("Sell", "Failed")
    end
end
local function onOnClientEvent4(fw)
    local yK = typeof(fw) == "table" and typeof(fw.position) == "Vector3"
    if yK then
        table.insert(ty, { pos = fw.position, at = os.clock() })
        if #ty > 40 then
            table.remove(ty, 1)
        end
    end
end
local function onOnClientEvent(eU)
    local x3 = typeof(eU) == "table" and typeof(eU.targetPosition) == "Vector3"
    if x3 then
        local x3_1 = eU.targetId or 0
        tq[x3_1] = { pos = eU.targetPosition, at = os.clock() }
    end
end
local function fn1291(h6)
    local AK_3
    local rarity = h6.rarity
    local AJ_2
    if typeof(rarity) == "string" then
        local AK_1 = sT("MerchantBuyRarities")
        local AL = next(AK_1) ~= nil and AK_1[rarity] ~= true
        if AL then
            return false
        end
        sT("MerchantBuyTypes")
        if next(AJ_2) ~= nil then
            ti(h6)
            if AJ_2[AK_3] ~= true then
                return false
            end
            return true
        end
        return true
    end
    AJ_2 = sT("MerchantBuyTypes")
    if next(AJ_2) ~= nil then
        AK_3 = ti(h6)
        if AJ_2[AK_3] ~= true then
            return false
        end
        return true
    end
    return true
end
local function fn1305(ey, ez)
    local xE
    local xF = math.huge
    for k, v in ez do
        local Magnitude = (v - ey).Magnitude
        if Magnitude < xF then
            xF = Magnitude
            xE = v
        end
    end
    return xE, xF
end
local function fn1322(ap)
    local us = Toggles[ap]
    return us ~= nil and us.Value == true
end
local function fn1348()
    local BL = if os.clock() - sW.quest < 1.5 then 1 else 0
    if BL == 1 then
        return
    end
    sW.quest = os.clock()
    local BF = s8("RequestQuestState")
    local BG = typeof(BF) ~= "table"
    local BL_1 = if BG then 1 else 0
    local BJ = 960 * BL_1 + 3840 * (1 - BL_1)
    local BK = 2538 * BL_1 + 1603 * (1 - BL_1)
    if not ((BJ * 1099 + BK * 1150 + BJ * BK) % 16777213 == 6410220) then
        BG = typeof(BF.quests) ~= "table"
    end
    if BG then
        tt("Quests", "No quests")
        return
    end
    local BG_1 = 0
    for k, v in BF.quests do
        if v.complete and not v.claimed and v.id then
            local BF_2 = s8("ClaimQuest", v.id)
            local BH = typeof(BF_2) == "table" and BF_2.success
            if BH then
                BG_1 += 1
            end
        end
    end
    local BG_2 = BG_1 > 0 and "Claimed " .. BG_1 or "Waiting"
    tt("Quests", BG_2)
end
local function fn1357()
    local BY = if os.clock() - sW.spin < 2 then 1 else 0
    if BY == 1 then
        return
    end
    sW.spin = os.clock()
    local BS = s8("RequestSpinState")
    if typeof(BS) ~= "table" then
        tt("Spin", "No state")
        return
    end
    if not BS.canSpin then
        local BT_1 = BS.secondsUntilSpin and math.floor(BS.secondsUntilSpin) .. "s"
        local BU_1 = BT_1 or "Locked"
        tt("Spin", BU_1)
        return
    end
    local BT_2 = BS.canFreeSpin
    local BY_1 = if BT_2 then 1 else 0
    local BW = 1264 * BY_1 + 2418 * (1 - BY_1)
    local BX = 839 * BY_1 + 2492 * (1 - BY_1)
    if not ((BW * 3467 + BX * 3922 + BW * BX) % 16777213 == 8733342) then
        local BU_2 = tonumber(BS.rollTokens) or 0
        BT_2 = BU_2 > 0
    end
    if not BT_2 then
        tt("Spin", "No tickets")
        return
    end
    local BS_1 = s8("PerformSpin")
    local BT_3 = typeof(BS_1) == "table" and BS_1.success
    if BT_3 then
        local reward = BS_1.reward
        local BS_2 = reward
        if BS_2 then
            local BT_5 = reward.displayName or reward.shortLabel or "Spun"
            BS_2 = tostring(BT_5)
        end
        local BT_6 = BS_2
        local BY_2 = if BT_6 then 1 else 0
        local BW_1 = 251 * BY_2 + 3789 * (1 - BY_2)
        local BX_1 = 3790 * BY_2 + 3667 * (1 - BY_2)
        if not ((BW_1 * 2900 + BX_1 * 366 + BW_1 * BX_1) % 16777213 == 3066330) then
            BT_6 = "Spun"
        end
        tt("Spin", BT_6)
    else
        tt("Spin", "Failed")
    end
end
local function fn1391()
    local xo = os.clock()
    local xp = {}
    local xv = #ty
    local xu = -1
    while false and xv <= 1 or true and xv >= 1 do
        local xw = xv
        local xq_1 = ty[xw]
        if xo - xq_1.at > 10 then
            table.remove(ty, xw)
        elseif typeof(xq_1.pos) == "Vector3" then
            table.insert(xp, xq_1.pos)
        end
        xv += xu
    end
    local Runtime = Workspace:FindFirstChild("Runtime")
    local xq_2 = Runtime and Runtime:FindFirstChild("Client")
    local xo_2 = xq_2
    if xq_2 then
        xq_2 = xo_2:FindFirstChild("Effects")
    end
    local xo_3 = xq_2
    if xq_2 then
        xq_2 = xo_3:FindFirstChild("Loot")
    end
    local xo_4 = xq_2
    if xo_4 then
        for i, child in xo_4:GetChildren() do
            if child:IsA("BasePart") then
                table.insert(xp, child.Position)
            end
        end
    end
    return xp
end
local function fn1404(V, W)
    if setclipboard then
        setclipboard(V)
    elseif toclipboard then
        toclipboard(V)
    end
    Library:Notify(W)
end
local function fn1408(au, av)
    local uv = Options[au]
    if uv == nil then
        return av
    end
    return uv.Value
end
local function fn1412(af, ag, ah)
    return string.format("<b>%s</b> %s %s", af, sH("-", "#5a6070"), sH(ag, ah))
end
local function fn1428()
    if os.clock() - sW.merchant < 1.5 then
        return
    end
    sW.merchant = os.clock()
    local AQ = s8("RequestMerchantState")
    if typeof(AQ) ~= "table" then
        tt("Merchant", "No state")
        return
    end
    if not AQ.active then
        tt("Merchant", "Inactive")
        return
    end
    local AR = Workspace:FindFirstChild("Main") and Workspace.Main:FindFirstChild("Merchant")
    local AR_1 = tA()
    if AR and AR_1 then
        local Position = AR:GetPivot().Position
        AR_1.CFrame = CFrame.new(Position + Vector3.new(0, 3, 0))
        task.wait(0.15)
    end
    local AR_2 = (tonumber(AQ.currencyAmount))
    local A_ = if AR_2 then 1 else 0
    local AY = 2784 * A_ + 1810 * (1 - A_)
    local AZ = 1497 * A_ + 2831 * (1 - A_)
    if not ((AY * 711 + AZ * 1520 + AY * AZ) % 16777213 == 8422512) then
        AR_2 = 0
    end
    local AS_1 = AR_2
    local AT_2 = nil
    if typeof(AQ.stock) == "table" then
        for k, v in AQ.stock do
            if sr(v) then
                local AQ_1 = tonumber(v.price) or math.huge
                local AQ_2 = tonumber(v.limit) or 0
                local AQ_3 = tonumber(v.purchased) or 0
                if (AQ_2 == 0 or AQ_3 < AQ_2) and AQ_1 <= AS_1 then
                    local AQ_5 = sR[v.rarity] or 0
                    local AU_1 = AT_2
                    if AU_1 then
                        AU_1 = sR[AT_2.rarity] or 0
                    end
                    local AQ_7 = AU_1 or -1
                    local AU_2 = not AT_2
                    if not AU_2 then
                        AU_2 = AQ_5 > AQ_7
                    end
                    if not AU_2 then
                        AU_2 = AQ_5 == AQ_7 and AQ_1 < AT_2.price
                    end
                    if AU_2 then
                        AT_2 = v
                    end
                end
            end
        end
    end
    if not AT_2 then
        tt("Merchant", "No match")
        return
    end
    local AQ_9 = s8("PurchaseMerchantOffer", AT_2.id)
    local AR_4 = typeof(AQ_9) == "table" and AQ_9.success
    if AR_4 then
        local AR_5 = AT_2.displayName or AT_2.id
        tt("Merchant", "Bought " .. tostring(AR_5))
    else
        local AR_6 = typeof(AQ_9) == "table"
        if AR_6 then
            local AS_2 = AQ_9.reason or "Failed"
            AR_6 = tostring(AS_2)
        end
        local AQ_10 = AR_6 or "Failed"
        tt("Merchant", AQ_10)
    end
end
sq = nil
sr = nil
ss = nil
su = nil
sv = nil
sw = nil
sy = nil
sA = nil
sB = nil
LocalPlayer = nil
Library = nil
sF = nil
sH = nil
sJ = nil
sL = nil
sM = nil
Workspace = nil
sO = nil
sP = nil
sQ = nil
sR = nil
sS = nil
sT = nil
sV = nil
sW = nil
sX = nil
sY = nil
s_ = nil
s0 = nil
s2 = nil
s4 = nil
s5 = nil
SkillConfig = nil
s8 = nil
s9 = nil
tb = nil
tc = nil
local Players, st, sD, sG, Lighting, sK, TeleportService, sZ, s1, CoreGui, s6, GuiService, td
te = nil
tf = nil
SharedConfig = nil
th = nil
ti = nil
tk = nil
tl = nil
tm = nil
tn = nil
tp = nil
tq = nil
tr = nil
ts = nil
tt = nil
tv = nil
tw = nil
ty = nil
tA = nil
tB = nil
Options = nil
tE = nil
tF = nil
tH = nil
tI = nil
Toggles = nil
tL = nil
tM = nil
tN = nil
tP = nil
local HttpService, to, Remotes, tx, tz, tD, tG, tJ, tO, SaveManager
HttpService = nil
to = nil
Remotes = nil
tx = nil
tz = nil
tD = nil
tG = nil
tJ = nil
tO = nil
SaveManager = nil
local t8_1
local t5_1
Players, tD, tx, to, HttpService, GuiService, CoreGui, TeleportService, Workspace, Lighting, LocalPlayer, st, tP, tG, tz, Remotes, SharedConfig, SkillConfig, sR = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local FH_7 = game:GetService("ReplicatedStorage")
if (SharedConfig and st and (not to or not SharedConfig) and ("Rule a Anime Dungeon" and (SharedConfig or false)) or (false and to or st and not SharedConfig) and ((not SharedConfig or SharedConfig) and (SharedConfig and st))) and (to and SharedConfig and (not to or to) and ((SharedConfig or st) and (not to and not to)) or ((not SharedConfig or SharedConfig) and (to and SharedConfig) or (SharedConfig or to or not SharedConfig and not SharedConfig))) and not ((SharedConfig and st and (not to or not SharedConfig) and ("Rule a Anime Dungeon" and (SharedConfig or false)) or (false and to or st and not SharedConfig) and ((not SharedConfig or SharedConfig) and (SharedConfig and st))) and (to and SharedConfig and (not to or to) and ((SharedConfig or st) and (not to and not to)) or ((not SharedConfig or SharedConfig) and (to and SharedConfig) or (SharedConfig or to or not SharedConfig and not SharedConfig)))) then
    to = game:GetService("RunService")
    tD = game:GetService("UserInputService")
    tx = game:GetService("VirtualUser")
else
    tD = game:GetService("RunService")
    tx = game:GetService("UserInputService")
    to = game:GetService("VirtualUser")
end
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Workspace = game:GetService("Workspace")
Lighting = game:GetService("Lighting")
LocalPlayer = Players.LocalPlayer
st = "Rule a Anime Dungeon"
tP = "https://discord.gg/K7Qxnxkk46"
tG = "https://discord.gg/K7Qxnxkk46"
tz = "https://tempohub.shop"
Remotes = FH_7:WaitForChild("Remotes")
local FH_2 = FH_7:WaitForChild("Shared")
SharedConfig = require(FH_2:WaitForChild("SharedConfig"))
SkillConfig = require(FH_2:WaitForChild("SkillConfig"))
local FH_6 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Unique" }
sR = {}
for k, v in FH_6 do
    sR[v] = k
end
sB, ss, tM, tE, ty, tq, tk, tc, s4, sW, Library, SaveManager, Toggles, Options, td, s6, sZ, sP, sK, tJ, FH_4_1, t8_1, t5_1, s1, tv, s2, sH, tO, sF, tw, sT, tt, sD, tA, s8, tN, s5, ts, tp, s0, tb, sG, sQ, sL, tl, sw, tn, sS, sq, th, te, tI, sM, sy, sJ, sX, tB, tr, sY, su, s_, tF, tf, sv, tm, ti, sr, sO, s9, sA, sV, tL, tH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sB = {
    "potion_attack",
    "potion_health",
    "potion_luck",
    "potion_coin",
    "potion_soul",
    "potion_morale",
    "potion_shard_drop",
    "potion_forge_stone"
}
ss = {
    Roll = "Idle",
    BuyRoll = "Idle",
    Sell = "Idle",
    Place = "Idle",
    BossRaid = "Idle",
    Farm = "Idle",
    Attack = "Idle",
    Wave = "Idle",
    Loot = "Idle",
    Sword = "Idle",
    Armor = "Idle",
    Potions = "Idle",
    Merchant = "Idle",
    Skills = "Idle",
    Playtime = "Idle",
    BattlePass = "Idle",
    Quests = "Idle",
    Spin = "Idle"
}
tM = {}
tE = {}
ty = {}
tq = {}
tk = { goal = nil, lookAt = nil, kind = nil, speed = 52, arrive = 5 }
tc = nil
s4 = 0
sW = {
    roll = 0,
    buyRoll = 0,
    sell = 0,
    place = 0,
    attack = 0,
    wave = 0,
    loot = 0,
    farm = 0,
    sword = 0,
    armor = 0,
    potion = 0,
    merchant = 0,
    skill = 0,
    playtime = 0,
    battlepass = 0,
    quest = 0,
    spin = 0,
    raid = 0
}
local tY = { "Normal", "Golden", "Shiny", "Cursed", "Radiant", "Corrupted", "Divine" }
Library = getgenv().Library
FH_7 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
tv = fn1404
s2 = fn168
sH = fn621
tO = fn1412
td = "#7fd47f"
s6 = "#6ec1ff"
sZ = "#e8a34d"
if (false and tk or (not sM or false)) and (sM and sM or (sM or not sM)) or not ((false and tk or (not sM or false)) and (sM and sM or (sM or not sM))) then
    sP = "#8b93a3"
    sK = "#e05a5a"
    sF = fn1322
    tw = fn1408
else
    sF = "#8b93a3"
    tw = "#e05a5a"
    sK = fn1322
    sP = fn1408
end
sT = fn266
tt = function(aH, aI)
    ss[aH] = aI
    local uJ = tM[aH]
    if uJ then
        pcall(function()
            local uH = aI == "Idle" and sP or td
            uJ:SetText(sH(aI, uH))
        end)
    end
end
sD = fn199
tA = fn656
s8 = function(a8, ...)
    local uR
    uR = nil
    local uT_1
    local uS_1
    uR = Remotes:FindFirstChild(a8)
    if not uR then
        return nil
    end
    uS_1, uT_1 = pcall(function(...)
        return uR:InvokeServer(...)
    end, ...)
    if uS_1 then
        return uT_1
    end
    return nil
end
tN = function(bf, ...)
    local uV
    uV = nil
    uV = Remotes:FindFirstChild(bf)
    if not uV then
        return false
    end
    local uW = pcall(function(...)
        uV:FireServer(...)
    end, ...)
    return uW
end
s5 = fn853
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = tP, Copyable = true }, "|", st },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
tJ = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "swords"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
local t6 = tJ.Main:AddSubTab("Automate", "sparkles")
local t4 = tJ.Main:AddSubTab("Combat", "swords")
local t3 = tJ.Main:AddSubTab("Shop", "shopping-bag")
local t1 = tJ.Main:AddSubTab("Rewards", "gift")
fn785(t6)
fn785(t4)
fn785(t3)
fn785(t1)
fn785(tJ.Player)
fn785(tJ.Settings)
local RollGroup = t6:AddLeftGroupbox("Roll", "dices")
RollGroup:AddToggle("InstantAutoRoll", { Text = "Instant Auto Roll", Default = false })
fn606(RollGroup, "Roll")
RollGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
fn606(RollGroup, "BuyRoll")
RollGroup:AddDivider("Buy Config")
RollGroup:AddDropdown("BuyRollRarities", {
    Text = "Buy Rarities",
    Values = FH_6,
    Multi = true,
    Default = { Rare = true, Epic = true, Legendary = true, Mythic = true, Secret = true, Unique = true }
})
RollGroup:AddDropdown("BuyRollMutations", { Text = "Buy Mutations", Values = tY, Multi = true, Default = {} })
RollGroup:AddDropdown("BuyRollMinRarity", { Text = "Min Buy Rarity", Values = FH_6, Default = "Rare" })
RollGroup:AddToggle("AutoSellUnits", { Text = "Auto Sell by Rarity", Default = false })
fn606(RollGroup, "Sell")
RollGroup:AddDropdown("SellMaxRarity", { Text = "Sell Max Rarity", Values = FH_6, Default = "Uncommon" })
RollGroup:AddToggle("SmartAutoPlace", { Text = "Smart Auto Place", Default = false })
fn606(RollGroup, "Place")
local SpinGroup = t6:AddRightGroupbox("Spin", "refresh-cw")
if not tY and td and (td or not sB) and (sQ or false or (td or sB)) and not (not tY and td and (td or not sB) and (sQ or false or (td or sB))) then
    t4:AddToggle("SmartAutoSpin", { Text = "Auto Spin Wheel", Default = false })
    t5_1(t4, "Spin")
    FH_6 = t8_1:AddLeftGroupbox("Combat", "swords")
    FH_6:AddToggle("BossRaid", { Text = "Auto Boss Raid", Default = false })
    t5_1(FH_6, "BossRaid")
    FH_6:AddToggle("AutoFarmMobs", { Text = "Auto Farm Mobs", Default = false })
    t5_1(FH_6, "Farm")
    FH_6:AddDropdown("FarmMode", { Text = "Farm Mode", Values = { "Overhead", "Behind", "Orbit" }, Default = "Overhead" })
    FH_6:AddToggle("AutoFastAttack", { Text = "Auto Fast Attack", Default = false })
    t5_1(FH_6, "Attack")
    FH_6:AddToggle("AutoNextWave", { Text = "Auto Next Wave", Default = false })
    t5_1(FH_6, "Wave")
    FH_6:AddToggle("AutoCollectLoot", { Text = "Auto Collect Loot", Default = false })
    t5_1(FH_6, "Loot")
    t1 = FH_4_1:AddLeftGroupbox("Gear", "sword")
    t1:AddToggle("AutoBuyBestSword", { Text = "Auto Buy Best Sword", Default = false })
    t5_1(t1, "Sword")
    t1:AddToggle("AutoBuyEquipArmor", { Text = "Auto Buy Armor", Default = false })
    t5_1(t1, "Armor")
    t1:AddToggle("AutoConsumePotions", { Text = "Auto Use Potions", Default = false })
    t5_1(t1, "Potions")
    local VendorsGroup = FH_4_1:AddRightGroupbox("Vendors", "store")
    VendorsGroup:AddToggle("AutoMerchantBuyer", { Text = "Auto Merchant Buyer", Default = false })
    t5_1(VendorsGroup, "Merchant")
    VendorsGroup:AddDropdown("MerchantBuyRarities", {
        Values = fn606,
        Multi = true,
        Text = "Merchant Rarities",
        Default = { Secret = true, Mythic = true, Unique = true, Legendary = true }
    })
    VendorsGroup:AddDropdown("MerchantBuyTypes", {
        Multi = true,
        Default = { Potion = true, Unit = true, Item = true },
        Text = "Merchant Types",
        Values = { "Other", "Potion", "Item", "Currency", "Unit" }
    })
    VendorsGroup:AddToggle("AutoUpgradeSkillTree", { Text = "Auto Skill Tree", Default = false })
    t5_1(VendorsGroup, "Skills")
    ts = t3:AddLeftGroupbox("Claims", "trophy")
    ts:AddToggle("AutoClaimPlaytime", { Text = "Auto Claim Playtime", Default = false })
    t5_1(ts, "Playtime")
    ts:AddToggle("AutoClaimBattlePass", { Text = "Auto Claim Battle Pass", Default = false })
    t5_1(ts, "BattlePass")
    ts:AddToggle("AutoClaimQuests", { Text = "Auto Claim Quests", Default = false })
    t5_1(ts, "Quests")
else
    SpinGroup:AddToggle("SmartAutoSpin", { Text = "Auto Spin Wheel", Default = false })
    fn606(SpinGroup, "Spin")
    local FH_4_2 = t4:AddLeftGroupbox("Combat", "swords")
    FH_4_2:AddToggle("BossRaid", { Text = "Auto Boss Raid", Default = false })
    fn606(FH_4_2, "BossRaid")
    FH_4_2:AddToggle("AutoFarmMobs", { Text = "Auto Farm Mobs", Default = false })
    fn606(FH_4_2, "Farm")
    FH_4_2:AddDropdown("FarmMode", { Text = "Farm Mode", Values = { "Overhead", "Orbit", "Behind" }, Default = "Overhead" })
    FH_4_2:AddToggle("AutoFastAttack", { Text = "Auto Fast Attack", Default = false })
    fn606(FH_4_2, "Attack")
    FH_4_2:AddToggle("AutoNextWave", { Text = "Auto Next Wave", Default = false })
    fn606(FH_4_2, "Wave")
    FH_4_2:AddToggle("AutoCollectLoot", { Text = "Auto Collect Loot", Default = false })
    fn606(FH_4_2, "Loot")
    local GearGroup = t3:AddLeftGroupbox("Gear", "sword")
    GearGroup:AddToggle("AutoBuyBestSword", { Text = "Auto Buy Best Sword", Default = false })
    fn606(GearGroup, "Sword")
    GearGroup:AddToggle("AutoBuyEquipArmor", { Text = "Auto Buy Armor", Default = false })
    fn606(GearGroup, "Armor")
    GearGroup:AddToggle("AutoConsumePotions", { Text = "Auto Use Potions", Default = false })
    fn606(GearGroup, "Potions")
    local VendorsGroup = t3:AddRightGroupbox("Vendors", "store")
    VendorsGroup:AddToggle("AutoMerchantBuyer", { Text = "Auto Merchant Buyer", Default = false })
    fn606(VendorsGroup, "Merchant")
    VendorsGroup:AddDropdown("MerchantBuyRarities", {
        Text = "Merchant Rarities",
        Values = FH_6,
        Multi = true,
        Default = { Legendary = true, Mythic = true, Secret = true, Unique = true }
    })
    VendorsGroup:AddDropdown("MerchantBuyTypes", {
        Text = "Merchant Types",
        Values = { "Unit", "Item", "Potion", "Currency", "Other" },
        Multi = true,
        Default = { Unit = true, Item = true, Potion = true }
    })
    VendorsGroup:AddToggle("AutoUpgradeSkillTree", { Text = "Auto Skill Tree", Default = false })
    fn606(VendorsGroup, "Skills")
    local ClaimsGroup = t1:AddLeftGroupbox("Claims", "trophy")
    ClaimsGroup:AddToggle("AutoClaimPlaytime", { Text = "Auto Claim Playtime", Default = false })
    fn606(ClaimsGroup, "Playtime")
    ClaimsGroup:AddToggle("AutoClaimBattlePass", { Text = "Auto Claim Battle Pass", Default = false })
    fn606(ClaimsGroup, "BattlePass")
    ClaimsGroup:AddToggle("AutoClaimQuests", { Text = "Auto Claim Quests", Default = false })
    fn606(ClaimsGroup, "Quests")
    ts = fn279
end
tp = fn301
s0 = fn265
tb = fn1168
sG = fn541
sQ = function(cz, cA, cB)
    local wc, wd, we, wf, wg, wk, wl, wn, wo, wp, wq, ws, wt, wu, wv, wx, wz
    local wh = 33
    while true do
        local wh_1 = 2529 - wh
        do
            if wh_1 < 2509 then
                if wh_1 < 2501 then
                    if wh_1 < 2495 then
                        if wh_1 < 2494 then
                            if wh_1 < 2492 then
                                if wh_1 < 2491 then
                                    break
                                elseif wh_1 == 2491 then
                                    wh = if wt > 0 and wu <= 36 or wt <= 0 and wu >= 36 then 9 else 1
                                else
                                    wh = 2492
                                    continue
                                end
                            elseif wh_1 < 2493 then
                                if wh_1 == 2492 then
                                    wu += wt
                                    wh = 38
                                else
                                    wh = 2503
                                    continue
                                end
                            elseif wh_1 == 2493 then
                                wh = 28
                            else
                                wh = 14348
                                continue
                            end
                        elseif wh_1 == 2494 then
                            wf = math.abs(wq) == wl * wd
                            wh = 0
                        else
                            wh = 2491
                            continue
                        end
                    elseif wh_1 < 2499 then
                        if wh_1 < 2496 then
                            wh = 36
                        elseif wh_1 < 2497 then
                            if wh_1 == 2496 then
                                wc = SharedConfig.Placement.GridSize
                                wh = if wc then 27 else 25
                            else
                                wh = 10732
                                continue
                            end
                        elseif wh_1 < 2498 then
                            wl = wk
                            wh = 12
                        elseif wh_1 == 2498 then
                            wp += wo
                            wh = 7
                        else
                            wh = 2523
                            continue
                        end
                    elseif wh_1 < 2500 then
                        wh = if wo > 0 and wp <= 36 or wo <= 0 and wp >= 36 then 18 else 4
                    elseif wh_1 == 2500 then
                        wf = wl == 0
                        wh = if wf then 0 else 35
                    else
                        wh = 2492
                        continue
                    end
                elseif wh_1 < 2507 then
                    if wh_1 < 2504 then
                        if wh_1 < 2502 then
                            wu += wt
                            wh = 14
                        elseif wh_1 < 2503 then
                            if wh_1 == 2502 then
                                wd = cA
                                we = wc
                                wc = function(cG, cH)
                                    local v7 = cB and cB[string.format("%.2f:%.2f", cG, cH)]
                                    if v7 then
                                        return true
                                    end
                                    return sG(cG, cH, cz, cA)
                                end
                                wk = 0
                                wh = 2
                            else
                                wh = 2527
                                continue
                            end
                        elseif wh_1 == 2503 then
                            wd = -36
                            wf = we * 2
                            wu = wd
                            wt = wf
                            wh = 38
                        else
                            wh = 2504
                            continue
                        end
                    elseif wh_1 < 2505 then
                        if wh_1 == 2504 then
                            wc = 0.5
                            wh = 27
                        else
                            wh = 2494
                            continue
                        end
                    elseif wh_1 < 2506 then
                        if wh_1 == 2505 then
                            wp += wo
                            wh = 30
                        else
                            wh = 6715
                            continue
                        end
                    else
                        wf = math.round(wq / we) * we
                        wg = math.round(wv / we) * we
                        wh = if not wc(wf, wg) then 15 else 34
                    end
                elseif wh_1 < 2508 then
                    wk += 1
                    wh = 2
                elseif wh_1 == 2508 then
                    wf = -wl * wd
                    wg = wl * wd
                    wu = wf
                    ws = wg
                    wt = wd
                    wh = 14
                else
                    wh = 2511
                    continue
                end
            elseif wh_1 < 2518 then
                if wh_1 < 2515 then
                    if wh_1 < 2513 then
                        if wh_1 < 2511 then
                            if wh_1 < 2510 then
                                wh = 31
                            elseif wh_1 == 2510 then
                                wh = 37
                            else
                                wh = 2518
                                continue
                            end
                        elseif wh_1 < 2512 then
                            wx = wp
                            wh = 26
                        elseif wh_1 == 2512 then
                            wh = if wf then 23 else 36
                        else
                            wh = 2520
                            continue
                        end
                    elseif wh_1 < 2514 then
                        return wd, wf, 0
                    else
                        return wf, wg, 0
                    end
                elseif wh_1 < 2516 then
                    wh = if wt > 0 and wu <= ws or wt <= 0 and wu >= ws then 10 else 20
                elseif wh_1 < 2517 then
                    wd = math.round(wx / we) * we
                    wf = math.round(wz / we) * we
                    wh = if not wc(wd, wf) then 16 else 19
                else
                    wf = -wl * wd
                    wg = wl * wd
                    wp = wf
                    wn = wg
                    wo = wd
                    wh = 7
                end
            elseif wh_1 < 2527 then
                if wh_1 < 2523 then
                    if wh_1 < 2520 then
                        if wh_1 < 2519 then
                            if wh_1 == 2518 then
                                wh = 22
                            else
                                wh = 2502
                                continue
                            end
                        elseif wh_1 == 2519 then
                            wv = wu
                            wh = 29
                        else
                            wh = 2501
                            continue
                        end
                    elseif wh_1 < 2521 then
                        if wh_1 == 2520 then
                            wz = wu
                            wh = 13
                        else
                            wh = 2491
                            continue
                        end
                    elseif wh_1 < 2522 then
                        break
                    elseif wh_1 == 2522 then
                        wh = if wo > 0 and wp <= wn or wo <= 0 and wp >= wn then 6 else 11
                    else
                        wh = 2518
                        continue
                    end
                elseif wh_1 < 2525 then
                    if wh_1 < 2524 then
                        if wh_1 == 2523 then
                            wq = wp
                            wh = 21
                        else
                            wh = 2511
                            continue
                        end
                    elseif wh_1 == 2524 then
                        wf = -36
                        wd = we * 2
                        wp = wf
                        wo = wd
                        wh = 30
                    else
                        wh = 2527
                        continue
                    end
                elseif wh_1 < 2526 then
                    return nil
                else
                    wf = math.abs(wv) == wl * wd
                    wh = 17
                end
            elseif wh_1 < 4241 then
                if wh_1 < 2528 then
                    if wh_1 == 2527 then
                        wh = if wk <= 12 then 32 else 5
                    else
                        wh = 2493
                        continue
                    end
                elseif wh_1 < 2529 then
                    if wh_1 == 2528 then
                        wh = 24
                    else
                        wh = 2501
                        continue
                    end
                elseif wh_1 == 2529 then
                    wh = if wf then 17 else 3
                else
                    break
                end
            else
                break
            end
        end
    end
end
sL = fn409
tl = fn433
sw = fn309
tn = fn46
sS = fn403
sq = fn686
th = fn1391
te = fn1305
tI = fn995
sM = fn1109
Remotes.CombatAttack.OnClientEvent:Connect(onOnClientEvent)
Remotes.CombatDamage.OnClientEvent:Connect(onOnClientEvent2)
Remotes.CombatDeath.OnClientEvent:Connect(onOnClientEvent3)
sy = fn890
sJ = fn219
Remotes.LootGranted.OnClientEvent:Connect(onOnClientEvent4)
sX = fn106
tB = fn535
if (s2 and not tO and false or (sQ and s2 or 16)) and (tM or false or false or (tM or not tM) and (tM and false)) or not ((s2 and not tO and false or (sQ and s2 or 16)) and (tM or false or false or (tM or not tM) and (tM and false))) then
    tr = fn321
    sY = fn253
    su = fn1121
else
    su = fn321
    tr = fn253
    sY = fn1121
end
s_ = fn214
tF = fn865
tf = fn77
sv = fn82
tm = fn188
ti = fn1060
sr = fn1291
sO = fn1428
s9 = fn544
sA = fn521
sV = fn1025
tL = fn1348
tH = fn1357
task.spawn(worker)
tD.Heartbeat:Connect(onHeartbeat)
task.spawn(worker2)
task.spawn(worker3)
local function t9()
    local CZ
    local C4
    CZ = nil
    C4 = nil
    local Label, Label2, Label3, C2, C3
    local function C5()
        local Cc = hookfunction ~= nil
        local Cd = hookmetamethod ~= nil
        local Ce = getrawmetatable ~= nil
        local Cf = setrawmetatable ~= nil
        local Cg = getgc ~= nil
        local Ch = getgenv ~= nil
        local Ci = getreg ~= nil
        local Cj = getconnections ~= nil
        local Ck = firesignal ~= nil
        local Cl = getcallbackvalue ~= nil
        local Cm = setclipboard ~= nil
        local Cn = getcustomasset ~= nil
        local Co = getnamecallmethod ~= nil
        local Cp = isexecutorclosure ~= nil
        local Cq = fireproximityprompt ~= nil
        local Cr = firetouchinterest ~= nil
        local Cs = WebSocket ~= nil
        local Ct = readfile ~= nil
        local Cu = writefile ~= nil
        local Cw = (request or http_request) ~= nil
        local Cy = (debug and debug.getupvalues) ~= nil
        local CA = (debug and debug.setupvalue) ~= nil
        local CB = 0
        local CC = { Cc, Cd, Ce, Cf, Cg, Ch, Ci, Cj, Ck, Cl, Cm, Cn, Co, Cp, Cq, Cr, Cs, Ct, Cu, Cw, Cy, CA }
        for i, v in ipairs(CC) do
            if v then
                CB += 1
            end
        end
        local Cc_1 = CB / #CC
        if Cc_1 >= 0.9 then
            return sH("Full Support", td)
        elseif Cc_1 >= 0.6 then
            return sH("Half Support", sZ)
        else
            return sH("Low Support", sK)
        end
    end
    C4 = "Unknown"
    pcall(function()
        local CO_1
        local CN_1
        if identifyexecutor then
            CO_1, CN_1 = identifyexecutor()
            local CP = CO_1 ~= ""
            local CQ = type(CO_1) == "string" and CP
            if CQ then
                local CP_1 = type(CN_1) == "string" and CN_1 ~= "" and CO_1 .. " " .. CN_1
                C4 = CP_1 or CO_1
            end
        end
    end)
    local C6 = C5()
    CZ = os.clock()
    C2 = function()
        local CS = math.floor(os.clock() - CZ)
        if CS < 60 then
            return CS .. "s"
        elseif CS < 3600 then
            return string.format("%dm %ds", math.floor((CS) / (60)), CS % 60)
        else
            return string.format("%dh %dm", math.floor((CS) / (3600)), math.floor((CS % 3600) / (60)))
        end
    end
    local UserGroup = tJ.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(tO("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, td), true)
    UserGroup:AddLabel(tO("UserId", tostring(LocalPlayer.UserId), s6), true)
    UserGroup:AddLabel(tO("Executor", C4 .. "  " .. C6, td), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(tO("Session", C2(), sZ), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            tv(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            tv("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = tJ.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(tO("Game", st, s6), true)
    Label2 = SessionGroup:AddLabel(tO("Players", "0/0", td), true)
    C3 = tostring(game.JobId)
    local C6_1 = #C3 > 18 and string.sub(C3, 1, 18) .. "..."
    local C6_2 = C6_1 or C3
    SessionGroup:AddLabel(tO("Job", C6_2, sP), true)
    Label = SessionGroup:AddLabel(tO("Ping", "0 ms", sZ), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            tv(C3, "Copied Job ID")
        end
    })
    task.spawn(function()
        local CV_1
        local CU_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(tO("Session", C2(), sZ))
            Label2:SetText(tO("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), td))
            CU_1, CV_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local CU_2 = CU_1 and CV_1 .. " ms" or "n/a"
            Label:SetText(tO("Ping", CU_2, sZ))
        end
    end)
    local SocialsGroup = tJ.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = s2 })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            if setclipboard then
                setclipboard(tG)
            elseif toclipboard then
                toclipboard(tG)
            end
            Library:Notify("Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            tv(tz, "Copied website link")
        end
    })
end
t9()
FH_2 = function()
    local connection
    local EC
    local EA
    local EB
    connection = nil
    EA = nil
    EB = nil
    EC = nil
    local CurrentCamera, Ev, connection2, onDescendantAdded, Ey, ED
    local MovementGroup = tJ.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = tJ.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local PerformanceGroup = tJ.Player:AddRightGroupbox("Performance", "gauge")
    PerformanceGroup:AddToggle("BoostFps", { Text = "FPS Boost", Default = false })
    connection2 = nil
    ED = setmetatable({}, { __mode = "k" })
    EA = function(lA, lB, lC)
        local Db_1
        local Da_1
        local C9 = ED[lA]
        if not C9 then
            C9 = {}
            ED[lA] = C9
        end
        if C9[lB] == nil then
            Da_1, Db_1 = pcall(function()
                return lA[lB]
            end)
            if not Da_1 then
                return
            end
            C9[lB] = Db_1
        end
        pcall(function()
            lA[lB] = lC
        end)
    end
    onDescendantAdded = function(lN)
        if lN:IsA("BasePart") then
            EA(lN, "CastShadow", false)
            EA(lN, "Reflectance", 0)
        else
            local Dg = (lN:IsA("Decal"))
            local Dk = if Dg then 1 else 0
            local Di = 2489 * Dk + 3053 * (1 - Dk)
            local Dj = 2390 * Dk + 2973 * (1 - Dk)
            if not ((Di * 3990 + Dj * 3042 + Di * Dj) % 16777213 == 6372987) then
                Dg = lN:IsA("Texture")
            end
            if Dg then
                EA(lN, "Transparency", 1)
            else
                local Dg_1 = lN:IsA("ParticleEmitter") or lN:IsA("Trail") or lN:IsA("Beam") or lN:IsA("Smoke") or lN:IsA("Fire") or lN:IsA("Sparkles") or lN:IsA("PostEffect")
                if Dg_1 then
                    EA(lN, "Enabled", false)
                elseif lN:IsA("Atmosphere") then
                    EA(lN, "Density", 0)
                end
            end
        end
    end
    EB = function()
        if connection2 then
            connection2:Disconnect()
            connection2 = nil
        end
        for k, v in ED do
            local Dp = k
            for k, v in v do
                local Dv = k
                local Dx = v
                pcall(function()
                    Dp[Dv] = Dx
                end)
            end
        end
        table.clear(ED)
    end
    Ev = function(l1)
        EB()
        if not l1 then
            return
        end
        local Rendering = settings().Rendering
        EA(Rendering, "QualityLevel", Enum.QualityLevel.Level01)
        EA(Lighting, "GlobalShadows", false)
        EA(Lighting, "EnvironmentDiffuseScale", 0)
        EA(Lighting, "EnvironmentSpecularScale", 0)
        local Terrain = Workspace.Terrain
        EA(Terrain, "Decoration", false)
        EA(Terrain, "WaterWaveSize", 0)
        EA(Terrain, "WaterWaveSpeed", 0)
        EA(Terrain, "WaterReflectance", 0)
        for i, descendant in Workspace:GetDescendants() do
            onDescendantAdded(descendant)
        end
        for i, descendant in Lighting:GetDescendants() do
            onDescendantAdded(descendant)
        end
        connection2 = game.DescendantAdded:Connect(onDescendantAdded)
    end
    Toggles.BoostFps:OnChanged(function()
        Ev(Toggles.BoostFps.Value)
    end)
    if Toggles.BoostFps.Value then
        Ev(true)
    end
    tD.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local DM_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if DM_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    tx.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local DU_1 = sD()
            if DU_1 then
                DU_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    CurrentCamera = Workspace.CurrentCamera
    tD.RenderStepped:Connect(function(mC)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local DZ_1 = sD()
            if DZ_1 then
                DZ_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local DZ_3 = tA()
            local D_ = sD()
            if DZ_3 and D_ then
                D_.PlatformStand = true
                local D__1 = Vector3.zero
                if tx:IsKeyDown(Enum.KeyCode.W) then
                    D__1 += CurrentCamera.CFrame.LookVector
                end
                if tx:IsKeyDown(Enum.KeyCode.S) then
                    D__1 -= CurrentCamera.CFrame.LookVector
                end
                if tx:IsKeyDown(Enum.KeyCode.A) then
                    D__1 -= CurrentCamera.CFrame.RightVector
                end
                local D7 = if tx:IsKeyDown(Enum.KeyCode.D) then 1 else 0
                if D7 == 1 then
                    D__1 += CurrentCamera.CFrame.RightVector
                end
                if tx:IsKeyDown(Enum.KeyCode.Space) then
                    D__1 += Vector3.new(0, 1, 0)
                end
                if tx:IsKeyDown(Enum.KeyCode.LeftControl) then
                    D__1 -= Vector3.new(0, 1, 0)
                end
                DZ_3.AssemblyLinearVelocity = Vector3.zero
                if D__1.Magnitude > 0 then
                    DZ_3.CFrame = DZ_3.CFrame + D__1.Unit * Options.FlySpeed.Value * mC
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local D8 = sD()
            if D8 then
                D8.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local Ea = sD()
            if Ea then
                Ea.WalkSpeed = 16
            end
        end
    end)
    EC = function(mZ)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not mZ)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not mZ
            end
        end)
        if not mZ then
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
    Toggles.AntiGameplayPause:OnChanged(function()
        EC(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                EC(true)
            end
        end
    end)
    Ey = function(ng)
        if not ng:IsA("ProximityPrompt") then
            return
        end
        ng.HoldDuration = 0
        ng.MaxActivationDistance = 50
        ng.RequiresLineOfSight = false
    end
    connection = nil
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(Ey, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(no)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(Ey, no)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        EC(false)
        EB()
        if connection then
            connection:Disconnect()
        end
    end)
end
FH_2()
local function t7()
    local connection
    local MenuGroup = tJ.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local nz = 0
    local nA = tick()
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function nC()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        to:CaptureController()
        to:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        nz += 1
        nA = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. nz)
        end)
    end
    connection = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(nC)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local EJ = Toggles.AntiAfk.Value and tick() - nA >= 60
            if EJ then
                pcall(nC)
            end
        end
    end)
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
t7()
FH_7:SetLibrary(Library)
FH_7:SetFolder("TempoHub")
FH_7:SaveDefault("Evil Hello Kitty")
FH_7:ApplyToTab(tJ.Settings)
FH_7:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/RuleAAnimeDungeon")
s1 = SaveManager:BuildConfigSection(tJ.Settings)
local function tZ()
    local function n0(n1, n2)
        local EN = n1 == "Toggle" and Toggles
        local ES = if EN then 1 else 0
        local EQ = 282 * ES + 1468 * (1 - ES)
        local ER = 2636 * ES + 358 * (1 - ES)
        if not ((EQ * 2303 + ER * 1381 + EQ * ER) % 16777213 == 5033114) then
            EN = Options
        end
        local EN_1 = EN[n2]
        local EM_2 = type(EN_1) == "table" and EN_1.Type == n1
        return EM_2 and EN_1 or nil
    end
    local function oa(ob, oc)
        local Type = oc.Type
        if Type == "Toggle" then
            return { idx = ob, type = "Toggle", value = oc.Value == true }
        elseif Type == "Slider" then
            return { idx = ob, type = "Slider", value = tostring(oc.Value) }
        elseif Type == "Dropdown" then
            return { idx = ob, type = "Dropdown", multi = oc.Multi == true, value = oc.Value }
        elseif Type == "Input" then
            local EU = oc.Value or ""
            return { idx = ob, type = "Input", text = tostring(EU) }
        elseif Type == "ColorPicker" then
            return { idx = ob, type = "ColorPicker", value = oc.Value:ToHex(), transparency = oc.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = ob,
                type = "KeyPicker",
                mode = oc.Mode,
                key = oc.Value,
                modifiers = oc.Modifiers,
                toggled = oc.Toggled
            }
        else
            return nil
        end
    end
    local function oe()
        local E_ = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local E0 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if E0 then
                    local E0_1 = oa(k, v)
                    if E0_1 then
                        E_[#E_ + 1] = E0_1
                    end
                end
            end
        end
        table.sort(E_, function(oq, ot)
            if oq.type ~= ot.type then
                return oq.type < ot.type
            end
            return oq.idx < ot.idx
        end)
        return { objects = E_ }
    end
    local function ou(ov)
        local Fg
        Fg = nil
        local Fh = type(ov) ~= "table" or type(ov.idx) ~= "string" or type(ov.type) ~= "string" or SaveManager.Ignore[ov.idx]
        if Fh then
            return false
        end
        Fg = n0(ov.type, ov.idx)
        if not Fg then
            return false
        end
        local Fh_1 = pcall(function()
            if ov.type == "Input" then
                if type(ov.text) ~= "string" then
                    return
                end
                Fg:SetValue(ov.text)
            elseif ov.type == "ColorPicker" then
                Fg:SetValueRGB(Color3.fromHex(ov.value), ov.transparency)
            elseif ov.type == "KeyPicker" then
                Fg:SetValue({ ov.key, ov.mode, ov.modifiers })
                if ov.mode == "Toggle" and ov.toggled ~= nil then
                    Fg.Toggled = ov.toggled
                    Fg:Update()
                end
            else
                Fg:SetValue(ov.value)
            end
        end)
        return Fh_1
    end
    s1:AddDivider()
    s1:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    s1:AddButton("Export Config to Clipboard", function()
        local Fk_1
        local Fj_1
        Fj_1, Fk_1 = pcall(HttpService.JSONEncode, HttpService, oe())
        if not Fj_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local Fj_2 = setclipboard or toclipboard
        local Fj_3 = type(Fj_2) ~= "function" or not pcall(Fj_2, Fk_1)
        if Fj_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    s1:AddButton("Import Config from Clipboard Text", function()
        local Fp_1
        local Fn = Options.SaveManager_ImportSource.Value or ""
        local Fn_1
        local Fo = tostring(Fn):match("^%s*(.-)%s*$")
        if Fo == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        Fn_1, Fp_1 = pcall(HttpService.JSONDecode, HttpService, Fo)
        local Fo_1 = not Fn_1 or type(Fp_1) ~= "table" or type(Fp_1.objects) ~= "table"
        if Fo_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local Fn_2 = 0
        for k, v in Fp_1.objects do
            if ou(v) then
                Fn_2 += 1
            end
        end
        if Fn_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local Fp_2 = Fn_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(Fn_2, Fp_2), 6)
    end)
end
tZ()
SaveManager:LoadAutoloadConfig()
end)(...)
