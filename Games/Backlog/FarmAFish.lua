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
getgenv().TempoHoodSubtitle = "FARM A FISH"
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
local l6
local lO
local mv
local lv
local mc
local Options
local lB
local ShopType
local shop_restock
local lH
local mo
local l5
local tool_util
local mu
local lu
local default
local gears
local connection
local LocalPlayer
local lZ
local lG
local connection2
local components
local lM
local ToolType
local lt
local ma
local lS
local lz
local mg
local bait
local lF
local mm
local l3
local fish_utils
local ms
local l9
local lR
local BaitMutation
local mf
local lX
local lE
local PlaceableType
local player_data
local lK
local VirtualUser
local World
local lQ
local mx
local lx
local me
local lW
local lD
local mk
local l1
local lJ
local mq
local l7
local lP
local mw
local lw
local md
local lV
local Baits
local mj
local l0
local lI
local mp
local function fn8(ah, ai)
    return ah.order < ai.order
end
local function onPlaceEggs(ec)
    lI = lH(ec, mw)
end
local function fn30(cX, cY)
    local pF = cX[cY]
    if not pF then
        return
    end
    local pG = cY + 1
    local pH = #cX
    local pN = pG
    while pN <= pH do
        local pG_1 = cX[pN]
        local pH_1 = (pF.size.X + pG_1.size.X) / 2 - 0.5
        local pI = (pF.size.Z + pG_1.size.Z) / 2 - 0.5
        local pJ = math.abs(pF.world.X - pG_1.world.X) < pH_1 and math.abs(pF.world.Z - pG_1.world.Z) < pI
        if pJ then
            pG_1.blocked = true
        end
        pN += 1
    end
end
local function fn38(dw)
    local p8 = {}
    for k, v in dw.inventory.baits do
        local p9 = Baits[v.baitType]
        local qa = #p8 + 1
        local baitType = v.baitType
        local qc = v.amount or 0
        local mutation = v.mutation
        local p9_1 = p9 and p9.baseValue or 0
        p8[qa] = { id = k, baitType = baitType, amount = qc, mutation = mutation, value = p9_1 }
    end
    table.sort(p8, function(dF, dG)
        return dF.value > dG.value
    end)
    return p8
end
local function onDeleteBaits(eK)
    mx = lH(eK, lw)
end
local function fn53(da, db, dc)
    local pT = type(db) ~= "number"
    local pX = if pT then 1 else 0
    local pV = 382 * pX + 443 * (1 - pX)
    local pW = 1682 * pX + 1821 * (1 - pX)
    if not ((pV * 493 + pW * 3543 + pV * pW) % 16777213 == 6790176) then
        pT = db ~= db
    end
    if not pT then
        pT = db == math.huge
    end
    if pT then
        return false
    end
    local pT_1 = mf(md(), da)
    if not pT_1 then
        return false
    end
    return pT_1 - db >= dc
end
local function fn59(cp, cq, cr, cs)
    local o2 = lM(cp)
    local o3 = ms(cp)
    local pivot = cp:GetPivot()
    local o5 = {}
    local o6 = {}
    for i, v in ipairs(o2) do
        local Position = v.hitbox.Position
        local o7 = v.hitbox.Size.X / 2
        local o8 = v.hitbox.Size.Z / 2
        local pa = cs and v.origin
        local po = if pa then 1 else 0
        local pm = 1877 * po + 298 * (1 - po)
        local pn = 7 * po + 3739 * (1 - po)
        if not ((pm * 3962 + pn * 1751 + pm * pn) % 16777213 == 7462070) then
            pa = nil
        end
        local o9_1 = pa
        local pr = -o7
        while cr > 0 and pr <= o7 or cr <= 0 and pr >= o7 do
            local ps = pr
            local pw = -o8
            while cr > 0 and pw <= o8 or cr <= 0 and pw >= o8 do
                local px = pw
                local pa_3 = l5(Position + Vector3.new(ps, 0, px), cq, cr, o9_1)
                local pb = string.format("%.2f,%.2f", pa_3.X, pa_3.Z)
                if not o5[pb] then
                    o5[pb] = true
                    local pb_1 = math.abs(pa_3.X - Position.X) <= o7 - cq.X / 2 + 0.6
                    local pc = math.abs(pa_3.Z - Position.Z) <= o8 - cq.Z / 2 + 0.6
                    if pb_1 and pc then
                        local pb_2 = true
                        for i, v in ipairs(o3) do
                            local pc_1 = (v.size.X + cq.X) / 2 - 0.5
                            local pd_1 = (v.size.Z + cq.Z) / 2 - 0.5
                            local pe = math.abs(v.position.X - pa_3.X) < pc_1 and math.abs(v.position.Z - pa_3.Z) < pd_1
                            if pe then
                                pb_2 = false
                                break
                            end
                        end
                        if pb_2 then
                            o6[#o6 + 1] = {
                                position = pivot:ToObjectSpace(CFrame.new(pa_3)).Position,
                                distance = (pa_3 - Position).Magnitude,
                                world = pa_3,
                                size = cq
                            }
                        end
                    end
                end
                pw += cr
            end
            pr += cr
        end
    end
    table.sort(o6, function(cU, cV)
        return cU.distance < cV.distance
    end)
    return o6
end
local function fn86(cg, ch, ci)
    local o0_1
    local oZ = tool_util.getToolPlacementModel(cg, ch, ci)
    if not oZ then
        return nil
    end
    local Hitbox = oZ:FindFirstChild("Hitbox", true)
    local o__1
    if Hitbox then
        return Hitbox.Size
    end
    o__1, o0_1 = oZ:GetBoundingBox()
    return o0_1
end
local function fn87()
    if setclipboard then
        setclipboard(lR)
    elseif toclipboard then
        toclipboard(lR)
    end
    l6:Notify("Copied Discord invite to clipboard")
end
local function onInputChanged(e1)
    local UserInputType = e1.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        l1 = tick()
    end
end
local function fn132()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    lZ = tick()
end
local function fn136(a3)
    local og = 0
    for k in a3 do
        og += 1
    end
    return og
end
local function onDeleteGroups(eG)
    lt = lH(eG, lS)
end
local function onPlacePets(em)
    lB = lH(em, mo)
end
local function onPlaceBaits(dY)
    lK = lH(dY, lw)
end
local function autoHatchLoop()
    while not l6.Unloaded do
        local tZ = Options.HatchLoopDelay and Options.HatchLoopDelay.Value or 5
        task.wait(tZ)
        if l6.Unloaded then
            break
        end
        if lW.AutoHatch.Value then
            pcall(function()
                local tJ = ma(md())
                if not tJ then
                    return
                end
                local Value2 = lW.HatchAnyEgg.Value
                local tL = 0
                local Value = Options.HatchPerCycle.Value
                for k, v in World:query(components.Egg) do
                    if tL >= Value or l6.Unloaded or not lW.AutoHatch.Value then
                        break
                    else
                        local tN_1 = tJ.eggs[v.eggId]
                        local tO = World:has(k, components.CanHatch) and not World:has(k, components.Hatching)
                        local tP = tN_1
                        if tP then
                            tP = tO
                        end
                        if tP then
                            tP = Value2 or lE[v.eggType]
                        end
                        if tP then
                            default.pets.hatchEgg(v.eggId)
                            tL += 1
                            task.wait(Options.HatchStepDelay.Value)
                        end
                    end
                end
            end)
        end
    end
end
local function fn175()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn185(bZ, b_, b0, b1)
    local oT_1, oT_2
    local oS_1, oS_2
    local oP = b1 and b1.X % b0 or 0
    local oO_1 = b1
    if oO_1 then
        oO_1 = b1.Z % b0
    end
    local oP_1 = oO_1 or 0
    local oP_2 = math.round(b_.X / b0) * b0
    local oR = math.round(b_.Z / b0) * b0
    oT_1, oS_1 = bZ.X, bZ.Z
    local oU = oP_2 / 2 % 1
    if oU >= 0.25 and oU <= 0.75 then
        oT_2 = math.floor((oT_1 - oP) / b0) * b0 + b0 / 2 + oP
    else
        oT_2 = math.round((oT_1 - oP) / b0) * b0 + oP
    end
    local oP_4 = oR / 2 % 1
    if oP_4 >= 0.25 and oP_4 <= 0.75 then
        oS_2 = math.floor((oS_1 - oP_1) / b0) * b0 + b0 / 2 + oP_1
    else
        oS_2 = math.round((oS_1 - oP_1) / b0) * b0 + oP_1
    end
    return Vector3.new(oT_2, lz, oS_2)
end
local function fn188(dK)
    local DiscordGroup = dK:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lO })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lO })
end
local function onInputBegan()
    l1 = tick()
end
local function autoBuyGearLoop()
    while not l6.Unloaded do
        local sa = Options.GearBuyLoopDelay and Options.GearBuyLoopDelay.Value or 5
        task.wait(sa)
        if l6.Unloaded then
            break
        end
        if lW.AutoBuyGear.Value then
            pcall(function()
                local r0, r1, r2
                local rY = md()
                if not rY then
                    return
                end
                local rY_1 = 0
                local Value2 = Options.GearBuyPerCycle.Value
                local Value = Options.GearCoinReserve.Value
                local r5 = false
                for k in mq do
                    local r4 = 7
                    while true do
                        if r4 < 14 then
                            if r4 < 7 then
                                if r4 < 3 then
                                    if r4 < 1 then
                                        r2 = l7(r0.currency, r0.price, Value)
                                        r4 = 18
                                    elseif r4 < 2 then
                                        r2 = rY_1 < Value2
                                        r4 = 10
                                    else
                                        r4 = 11
                                    end
                                elseif r4 < 5 then
                                    if r4 < 4 then
                                        r4 = if r2 then 26 else 6
                                    else
                                        r0 = not lW.AutoBuyGear.Value
                                        r4 = 28
                                    end
                                elseif r4 < 6 then
                                    r2 = r1 > 0
                                    r4 = if r2 then 1 else 10
                                else
                                    default.shop.purchaseGear(k)
                                    r4 = if lW.GearBuyNotify.Value then 9 else 14
                                end
                            elseif r4 < 10 then
                                if r4 < 8 then
                                    r0 = rY_1 >= Value2
                                    r4 = if r0 then 24 else 16
                                elseif r4 < 9 then
                                    r4 = 21
                                else
                                    r2 = r0.name
                                    r4 = if r2 then 25 else 13
                                end
                            elseif r4 < 12 then
                                if r4 < 11 then
                                    r4 = if r2 then 0 else 18
                                else
                                    break
                                end
                            elseif r4 < 13 then
                                r2 = l6.Unloaded
                                r4 = if r2 then 3 else 19
                            else
                                r2 = k
                                r4 = 25
                            end
                        elseif r4 < 21 then
                            if r4 < 17 then
                                if r4 < 15 then
                                    rY_1 += 1
                                    task.wait(Options.GearBuyStepDelay.Value)
                                    r1 = lQ(md(), ShopType.Gear, k)
                                    r4 = 8
                                elseif r4 < 16 then
                                    r1 = lQ(md(), ShopType.Gear, k)
                                    r4 = 21
                                else
                                    r0 = l6.Unloaded
                                    r4 = 24
                                end
                            elseif r4 < 19 then
                                if r4 < 18 then
                                    r4 = 27
                                else
                                    r4 = if r2 then 12 else 23
                                end
                            elseif r4 < 20 then
                                r2 = not lW.AutoBuyGear.Value
                                r4 = 3
                            else
                                r4 = 2
                            end
                        elseif r4 < 25 then
                            if r4 < 23 then
                                if r4 < 22 then
                                    r4 = 5
                                else
                                    r0 = mv[k]
                                    r4 = if r0 then 15 else 2
                                end
                            elseif r4 < 24 then
                                r4 = 20
                            else
                                r4 = if r0 then 28 else 4
                            end
                        elseif r4 < 27 then
                            if r4 < 26 then
                                l6:Notify("Bought " .. r2)
                                r4 = 14
                            else
                                r4 = 20
                            end
                        elseif r4 < 28 then
                            r5 = true
                            r4 = 11
                        else
                            r4 = if r0 then 17 else 22
                        end
                    end
                    if r5 then
                        break
                    end
                end
            end)
        end
    end
end
local function autoCollectLoop()
    while not l6.Unloaded do
        local rH = Options.CollectLoopDelay and Options.CollectLoopDelay.Value or 3
        task.wait(rH)
        if l6.Unloaded then
            break
        end
        if lW.AutoCollect.Value then
            pcall(function()
                local rt = ma(md())
                if not rt then
                    return
                end
                local Value = Options.CollectMinFish.Value
                for k, v in rt.baits do
                    if l6.Unloaded or not lW.AutoCollect.Value then
                        break
                    else
                        local rt_2 = mp(v.fishes)
                        local rv = Baits[v.bait.baitType]
                        local rw = rv and bait.getNetCapacity(rv.netSize)
                        local rv_1 = rw or 0
                        local rv_2 = rt_2 >= Value
                        if lW.CollectOnlyFull.Value then
                            rv_2 = rv_1 > 0 and rt_2 >= rv_1
                        end
                        if rv_2 then
                            default.bait.collectAllFish(k)
                            task.wait(Options.CollectStepDelay.Value)
                        end
                    end
                end
            end)
        end
    end
end
local function autoPlacePetLoop()
    while not l6.Unloaded do
        local ud = Options.PetPlaceLoopDelay and Options.PetPlaceLoopDelay.Value or 5
        task.wait(ud)
        if l6.Unloaded then
            break
        end
        if lW.AutoPlacePet.Value then
            pcall(function()
                local t0 = md()
                if not t0 then
                    return
                end
                local Value2 = lW.PlaceAnyPet.Value
                local t2 = not Value2
                if t2 ~= false then
                    t2 = mp(lB) == 0
                end
                if t2 then
                    return
                end
                local t2_1 = 0
                local Value = Options.PetPlacePerCycle.Value
                for k, v in t0.inventory.pets do
                    if t2_1 >= Value or l6.Unloaded or not lW.AutoPlacePet.Value then
                        break
                    end
                    if Value2 or lB[v.petType] then
                        default.pets.placePetFromInventory(k)
                        t2_1 += 1
                        task.wait(Options.PetPlaceStepDelay.Value)
                    end
                end
            end)
        end
    end
end
local function onBuyGears(er)
    mq = lH(er, lV)
end
local function autoDeleteLoop()
    while not l6.Unloaded do
        local tH = Options.DeleteLoopDelay and Options.DeleteLoopDelay.Value or 10
        task.wait(tH)
        if l6.Unloaded then
            break
        end
        if lW.AutoDelete.Value then
            pcall(function()
                local th = ma(md())
                if not th then
                    return
                end
                local ti = 0
                local Value4 = Options.DeletePerCycle.Value
                local Value3 = lW.DeleteAnyBait.Value
                local Value2 = Options.DeleteBaitBelowValue.Value
                local Value = lW.DeleteOnlyEmpty.Value
                for i, v in ipairs(lX) do
                    if ti >= Value4 or l6.Unloaded or not lW.AutoDelete.Value then
                        break
                    elseif lt[v.key] then
                        for k, v2 in th[v.key] do
                            if ti >= Value4 or l6.Unloaded or not lW.AutoDelete.Value then
                                break
                            end
                            local tn_2 = true
                            if v.key == "baits" then
                                local baitType = v2.bait.baitType
                                local tp = Baits[baitType]
                                local to_1 = Value3 or mx[baitType]
                                if Value2 > 0 and tp and (tp.baseValue or 0) >= Value2 then
                                    to_1 = false
                                end
                                local tp_1 = Value and mp(v2.fishes) > 0
                                if tp_1 then
                                    to_1 = false
                                end
                                tn_2 = to_1
                            end
                            if tn_2 then
                                default.ponds.deleteBuilding(k)
                                ti += 1
                                task.wait(Options.DeleteStepDelay.Value)
                            end
                        end
                    end
                end
            end)
        end
    end
end
local function onScoopBaits(eB)
    lx = lH(eB, lw)
end
local function fn303(aN, aO)
    return aO.source == gears.GearSource.GearShop
end
local function fn308(c5, c6)
    local pQ_1 = c5[c6 or "coins"]
    if type(pQ_1) == "number" then
        return pQ_1
    end
    return nil
end
local function onHatchEggs(eh)
    lE = lH(eh, mw)
end
local function antiAfkLoop()
    while not l6.Unloaded do
        task.wait(2)
        if lW.AntiAfk.Value then
            local qD = tick() - l1
            local qE = tick() - lZ
            if qD >= 300 and qE >= 60 then
                pcall(lP)
            else
                if qD < 300 and qE >= 300 then
                    pcall(lP)
                end
            end
        end
    end
end
local function onBuyBaits(d2)
    mu = lH(d2, lw)
end
local function fn345(di, dj, dk)
    local pY = shop_restock.shopRestock()
    if not pY then
        return 0
    end
    local pZ = pY.availableItems and pY.availableItems[dj]
    local p_ = pZ
    if pZ then
        pZ = p_[dk]
    end
    local pZ_1 = pZ or 0
    local p__2 = di.shopPurchases and di.shopPurchases[dj]
    local p0 = p__2
    if p__2 then
        p__2 = p0.currentTimeSlot == pY.currentTimeSlot
    end
    if p__2 then
        local pY_1 = p0.purchases[dk] or 0
        pZ_1 -= pY_1
    end
    return pZ_1
end
local function fn377(am, an)
    local nM_1
    local nL_1
    nL_1, nM_1 = {}, {}
    local nN = {}
    for k, v in am do
        local nO = not an or an(k, v)
        if nO then
            local nO_1 = #nN + 1
            local nP = v.name or k
            local nQ = v.price or 0
            nN[nO_1] = { key = k, name = nP, price = nQ }
        end
    end
    table.sort(nN, function(au, av)
        if au.price == av.price then
            return au.key < av.key
        end
        return au.price < av.price
    end)
    for k, v in nN do
        local nN_1 = v.name
        if nM_1[nN_1] then
            nN_1 = nN_1 .. " (" .. v.key .. ")"
        end
        nL_1[#nL_1 + 1] = nN_1
        nM_1[nN_1] = v.key
    end
    return nL_1, nM_1
end
local function fn396(bI)
    local ou = {}
    for k, v, bO, bP in World:query(components.SubPond, components.Hitbox, components.Model) do
        if bO.hitbox:IsDescendantOf(bI) then
            ou[#ou + 1] = { hitbox = bO.hitbox, origin = bP.model:GetPivot().Position }
        end
    end
    return ou
end
local function autoBuyBaitLoop()
    while not l6.Unloaded do
        local rr = Options.BaitBuyLoopDelay and Options.BaitBuyLoopDelay.Value or 5
        task.wait(rr)
        if l6.Unloaded then
            break
        end
        if lW.AutoBuyBait.Value then
            pcall(function()
                local q9, ra
                local q5 = md()
                if not q5 then
                    return
                end
                local q5_1 = 0
                local Value2 = Options.BaitBuyPerCycle.Value
                local Value = Options.BaitCoinReserve.Value
                local q8 = {}
                if lW.BuyAnyAffordableBait.Value then
                    q8 = mj
                else
                    for k in mu do
                        q8[#q8 + 1] = k
                    end
                end
                local rk = false
                for i, v in ipairs(q8) do
                    local rj = 13
                    while true do
                        if rj < 14 then
                            if rj < 7 then
                                if rj < 3 then
                                    if rj < 1 then
                                        q5_1 += 1
                                        task.wait(Options.BaitBuyStepDelay.Value)
                                        q9 = lQ(md(), ShopType.Bait, v)
                                        rj = 8
                                    elseif rj < 2 then
                                        ra = not lW.AutoBuyBait.Value
                                        rj = 6
                                    else
                                        rj = 25
                                    end
                                elseif rj < 5 then
                                    if rj < 4 then
                                        ra = l7(q8.currency, q8.price, Value)
                                        rj = 9
                                    else
                                        rk = true
                                        rj = 16
                                    end
                                elseif rj < 6 then
                                    default.shop.purchaseBait(v)
                                    rj = if lW.BaitBuyNotify.Value then 26 else 0
                                else
                                    rj = if ra then 10 else 5
                                end
                            elseif rj < 10 then
                                if rj < 8 then
                                    rj = 4
                                elseif rj < 9 then
                                    rj = 2
                                else
                                    rj = if ra then 22 else 17
                                end
                            elseif rj < 12 then
                                if rj < 11 then
                                    rj = 15
                                else
                                    q8 = l6.Unloaded
                                    rj = 19
                                end
                            elseif rj < 13 then
                                rj = 16
                            else
                                q8 = q5_1 >= Value2
                                rj = if q8 then 19 else 11
                            end
                        elseif rj < 21 then
                            if rj < 17 then
                                if rj < 15 then
                                    rj = if ra then 3 else 9
                                elseif rj < 16 then
                                    rj = 12
                                else
                                    break
                                end
                            elseif rj < 19 then
                                if rj < 18 then
                                    rj = 15
                                else
                                    ra = q5_1 < Value2
                                    rj = 14
                                end
                            elseif rj < 20 then
                                rj = if q8 then 27 else 24
                            else
                                ra = v
                                rj = 28
                            end
                        elseif rj < 25 then
                            if rj < 23 then
                                if rj < 22 then
                                    q8 = Baits[v]
                                    rj = if q8 then 23 else 12
                                else
                                    ra = l6.Unloaded
                                    rj = if ra then 6 else 1
                                end
                            elseif rj < 24 then
                                q9 = lQ(md(), ShopType.Bait, v)
                                rj = 2
                            else
                                q8 = not lW.AutoBuyBait.Value
                                rj = 27
                            end
                        elseif rj < 27 then
                            if rj < 26 then
                                ra = q9 > 0
                                rj = if ra then 18 else 14
                            else
                                ra = q8.name
                                rj = if ra then 28 else 20
                            end
                        elseif rj < 28 then
                            rj = if q8 then 7 else 21
                        else
                            l6:Notify("Bought " .. ra)
                            rj = 0
                        end
                    end
                    if rk then
                        break
                    end
                end
            end)
        end
    end
end
local function autoScoopLoop()
    while not l6.Unloaded do
        local tf = Options.ScoopLoopDelay and Options.ScoopLoopDelay.Value or 3
        task.wait(tf)
        if l6.Unloaded then
            break
        end
        if lW.AutoScoop.Value then
            pcall(function()
                local sU = md()
                local sV = ma(sU)
                if not sV then
                    return
                end
                local sW = l9[Options.ScoopGear.Value]
                local sX = sW and sU.inventory.gears[sW]
                local sX_1 = not sX
                if not sX_1 then
                    sX_1 = (sX.amount or 0) <= 0
                end
                if sX_1 then
                    return
                end
                local Value2 = lW.ScoopAnyBait.Value
                local sX_2 = 0
                local Value = Options.ScoopPerCycle.Value
                for k, v in sV.baits do
                    if sX_2 >= Value or l6.Unloaded or not lW.AutoScoop.Value then
                        break
                    else
                        local baitType = v.bait.baitType
                        if Value2 or lx[baitType] then
                            local sZ_1 = false
                            if lW.ScoopSkipFull.Value then
                                local s_ = Baits[baitType]
                                local sV_3 = s_ and bait.getNetCapacity(s_.netSize)
                                local s__1 = sV_3 or 0
                                local s__2 = s__1 > 0 and mp(v.fishes) >= s__1
                                sZ_1 = s__2
                            end
                            if not sZ_1 then
                                default.gear.useFishFeeder(sW, k)
                                sX_2 += 1
                                task.wait(Options.ScoopStepDelay.Value)
                            end
                        end
                    end
                end
            end)
        end
    end
end
local function fn548(aS, aT)
    return aT.buildingType ~= nil
end
local function autoPlaceEggLoop()
    while not l6.Unloaded do
        local sS = Options.EggPlaceLoopDelay and Options.EggPlaceLoopDelay.Value or 5
        task.wait(sS)
        if l6.Unloaded then
            break
        end
        if lW.AutoPlaceEgg.Value then
            pcall(function()
                local sA, sB, sC
                local sv = md()
                local sw = l3()
                local sx = not sw
                local sy = not sv
                local sG = if sy then 1 else 0
                local sE = 2754 * sG + 1140 * (1 - sG)
                local sF = 24 * sG + 2456 * (1 - sG)
                if not ((sE * 3939 + sF * 2761 + sE * sF) % 16777213 == 10980366) then
                    sy = sx
                end
                if sy then
                    return
                end
                local Value2 = lW.PlaceAnyEgg.Value
                local sy_1 = not Value2
                if sy_1 ~= false then
                    sy_1 = mp(lI) == 0
                end
                if sy_1 then
                    return
                end
                local sy_2 = 0
                local Value = Options.EggPlacePerCycle.Value
                local sL = false
                for k, v in sv.inventory.eggs do
                    local sK = 5
                    while true do
                        if sK < 17 then
                            if sK < 8 then
                                if sK < 4 then
                                    if sK < 2 then
                                        if sK < 1 then
                                            sB = sy_2 < Value
                                            sK = 27
                                        else
                                            sK = if sv then 3 else 6
                                        end
                                    elseif sK < 3 then
                                        break
                                    else
                                        sv = mm(ToolType.Egg, v.eggType)
                                        sK = if sv then 18 else 13
                                    end
                                elseif sK < 6 then
                                    if sK < 5 then
                                        sv += 1
                                        sK = 22
                                    else
                                        sv = sy_2 >= Value
                                        sK = if sv then 19 else 14
                                    end
                                elseif sK < 7 then
                                    sK = 2
                                else
                                    sK = 13
                                end
                            elseif sK < 12 then
                                if sK < 10 then
                                    if sK < 9 then
                                        sK = 32
                                    else
                                        sB = l6.Unloaded
                                        sK = if sB then 11 else 15
                                    end
                                elseif sK < 11 then
                                    sK = if sv then 8 else 26
                                else
                                    sK = if sB then 12 else 31
                                end
                            elseif sK < 14 then
                                if sK < 13 then
                                    sK = 7
                                else
                                    sK = 6
                                end
                            elseif sK < 15 then
                                sv = l6.Unloaded
                                sK = 19
                            elseif sK < 16 then
                                sB = not lW.AutoPlaceEgg.Value
                                sK = 11
                            else
                                sB = sv <= #sA
                                sK = 17
                            end
                        elseif sK < 25 then
                            if sK < 21 then
                                if sK < 19 then
                                    if sK < 18 then
                                        sK = if sB then 9 else 24
                                    else
                                        sA = l0(sw, sv, lD, false)
                                        sv = 1
                                        sB = v.amount
                                        sK = if sB then 29 else 30
                                    end
                                elseif sK < 20 then
                                    sK = if sv then 10 else 21
                                else
                                    sK = 33
                                end
                            elseif sK < 23 then
                                if sK < 22 then
                                    sv = not lW.AutoPlaceEgg.Value
                                    sK = 10
                                else
                                    sK = 20
                                end
                            elseif sK < 24 then
                                default.ponds.placeBuilding(PlaceableType.Egg, k, sB.position, nil)
                                lG(sA, sv)
                                sv += 1
                                sC -= 1
                                sy_2 += 1
                                task.wait(Options.EggPlaceStepDelay.Value)
                                sK = 22
                            else
                                sK = 7
                            end
                        elseif sK < 29 then
                            if sK < 27 then
                                if sK < 26 then
                                    sB = sC > 0
                                    sK = if sB then 0 else 27
                                else
                                    sv = Value2
                                    sK = if sv then 1 else 28
                                end
                            elseif sK < 28 then
                                sK = if sB then 16 else 17
                            else
                                sv = lI[v.eggType]
                                sK = 1
                            end
                        elseif sK < 31 then
                            if sK < 30 then
                                sC = sB
                                sK = 33
                            else
                                sB = 0
                                sK = 29
                            end
                        elseif sK < 32 then
                            sB = sA[sv]
                            sK = if sB.blocked then 4 else 23
                        elseif sK < 33 then
                            sL = true
                            sK = 2
                        else
                            sK = 25
                        end
                    end
                    if sL then
                        break
                    end
                end
            end)
        end
    end
end
local function autoPlaceGearLoop()
    while not l6.Unloaded do
        local st = Options.GearPlaceLoopDelay and Options.GearPlaceLoopDelay.Value or 5
        task.wait(st)
        if l6.Unloaded then
            break
        end
        if lW.AutoPlaceGear.Value then
            pcall(function()
                local sh, si, sj
                local sc = md()
                local sd = l3()
                if not sc or not sd then
                    return
                end
                local Value2 = lW.PlaceAnyGear.Value
                local sf_1 = not Value2
                if sf_1 ~= false then
                    sf_1 = mp(mk) == 0
                end
                if sf_1 then
                    return
                end
                local sf_2 = 0
                local Value = Options.GearPlacePerCycle.Value
                local sm = false
                for k, v in sc.inventory.gears do
                    local sl = 29
                    while true do
                        if sl < 19 then
                            if sl < 9 then
                                if sl < 4 then
                                    if sl < 2 then
                                        if sl < 1 then
                                            si = not lW.AutoPlaceGear.Value
                                            sl = 11
                                        else
                                            sh = mk[v.gearType]
                                            sl = 9
                                        end
                                    elseif sl < 3 then
                                        si = sc <= #sh
                                        sl = 8
                                    else
                                        sl = if sc then 37 else 21
                                    end
                                elseif sl < 6 then
                                    if sl < 5 then
                                        sl = if si then 2 else 8
                                    else
                                        sl = 30
                                    end
                                elseif sl < 7 then
                                    sl = 28
                                elseif sl < 8 then
                                    default.ponds.placeBuilding(PlaceableType.Booster, k, si.position, nil)
                                    lG(sh, sc)
                                    sc += 1
                                    sj -= 1
                                    sf_2 += 1
                                    task.wait(Options.GearPlaceStepDelay.Value)
                                    sl = 35
                                else
                                    sl = if si then 14 else 36
                                end
                            elseif sl < 14 then
                                if sl < 11 then
                                    if sl < 10 then
                                        si = sc
                                        sj = sh
                                        sl = if si then 18 else 32
                                    else
                                        sl = if sc then 3 else 31
                                    end
                                elseif sl < 12 then
                                    sl = if si then 6 else 27
                                elseif sl < 13 then
                                    sl = 24
                                else
                                    si = sf_2 < Value
                                    sl = 4
                                end
                            elseif sl < 16 then
                                if sl < 15 then
                                    si = l6.Unloaded
                                    sl = if si then 11 else 0
                                else
                                    sl = 5
                                end
                            elseif sl < 17 then
                                sc += 1
                                sl = 35
                            elseif sl < 18 then
                                sl = if sc then 19 else 12
                            else
                                si = sc.buildingType
                                sl = 32
                            end
                        elseif sl < 28 then
                            if sl < 23 then
                                if sl < 21 then
                                    if sl < 20 then
                                        sc = mm(ToolType.Gear, v.gearType)
                                        sl = if sc then 25 else 26
                                    else
                                        sc = l6.Unloaded
                                        sl = 10
                                    end
                                elseif sl < 22 then
                                    sc = mv[v.gearType]
                                    sh = Value2
                                    sl = if sh then 9 else 1
                                else
                                    sm = true
                                    sl = 24
                                end
                            elseif sl < 25 then
                                if sl < 24 then
                                    sj = si
                                    sl = 5
                                else
                                    break
                                end
                            elseif sl < 26 then
                                sh = l0(sd, sc, lD, false)
                                sc = 1
                                si = v.amount
                                sl = if si then 23 else 34
                            elseif sl < 27 then
                                sl = 12
                            else
                                si = sh[sc]
                                sl = if si.blocked then 16 else 7
                            end
                        elseif sl < 33 then
                            if sl < 30 then
                                if sl < 29 then
                                    sl = 26
                                else
                                    sc = sf_2 >= Value
                                    sl = if sc then 10 else 20
                                end
                            elseif sl < 31 then
                                si = sj > 0
                                sl = if si then 13 else 4
                            elseif sl < 32 then
                                sc = not lW.AutoPlaceGear.Value
                                sl = 3
                            else
                                sc = si
                                sl = if sc then 33 else 17
                            end
                        elseif sl < 35 then
                            if sl < 34 then
                                sc = sj
                                sl = 17
                            else
                                si = 0
                                sl = 23
                            end
                        elseif sl < 36 then
                            sl = 15
                        elseif sl < 37 then
                            sl = 28
                        else
                            sl = 22
                        end
                    end
                    if sm then
                        break
                    end
                end
            end)
        end
    end
end
local function fn623()
    local qn_1
    local qm_1
    if identifyexecutor then
        qn_1, qm_1 = identifyexecutor()
        local qo = qn_1 ~= ""
        local qp = type(qn_1) == "string" and qo
        if qp then
            local qo_1 = type(qm_1) == "string" and qm_1 ~= "" and qn_1 .. " " .. qm_1
            lu = qo_1 or qn_1
        end
    end
end
local function fn657()
    return player_data.getPlayerData(LocalPlayer)
end
local function fn660(aX, aY)
    local n6 = {}
    for k, v in aX do
        if v then
            local n8 = aY and aY[k] or k
            n6[n8] = true
        end
    end
    return n6
end
local function onUnload()
    l6:Unload()
end
local function autoSellLoop()
    while not l6.Unloaded do
        local rW = Options.SellLoopDelay and Options.SellLoopDelay.Value or 5
        task.wait(rW)
        if l6.Unloaded then
            break
        end
        if lW.AutoSell.Value then
            pcall(function()
                local rJ = md()
                if not rJ then
                    return
                end
                local fishes = rJ.inventory.fishes
                if mp(fishes) < Options.SellMinHeld.Value then
                    return
                end
                if Options.SellMode.Value == lv then
                    default.sellFish.sellAllFish()
                    return
                end
                local Value2 = Options.SellMaxValue.Value
                local Value = lW.SellKeepLiked.Value
                for k, v in fishes do
                    if l6.Unloaded or not lW.AutoSell.Value then
                        break
                    end
                    if not (Value and v.liked) then
                        local rK_3 = fish_utils.getFishRarity(v.fishType)
                        if mg[rK_3] then
                            local rK_4 = fish_utils.calculateFishValue(v) or 0
                            if rK_4 <= Value2 then
                                default.sellFish.sellFish(k)
                                task.wait(Options.SellStepDelay.Value)
                            end
                        end
                    end
                end
            end)
        end
    end
end
local function fn672(by)
    if not by then
        return nil
    end
    return by.ponds[by.currentPond]
end
local function fn686(bR)
    local oG = {}
    for k in World:query(components.Building) do
        local oH = World:get(k, components.Hitbox)
        local oI = oH and oH.hitbox:IsDescendantOf(bR)
        if oI then
            oG[#oG + 1] = { position = oH.hitbox.Position, size = oH.hitbox.Size }
        end
    end
    return oG
end
local function fn693()
    l6.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn721()
    if not me then
        return nil
    end
    local on = me.getClientEntity()
    if not on then
        return nil
    end
    local oo = World:target(on, components.OwnsPond)
    if not oo then
        return nil
    end
    local on_1 = World:get(oo, components.Model)
    return on_1 and on_1.model or nil
end
local function onSellRarities(d8)
    mg = lH(d8)
end
local function autoPlaceBaitLoop()
    while not l6.Unloaded do
        local q3 = Options.PlaceLoopDelay and Options.PlaceLoopDelay.Value or 3
        task.wait(q3)
        if l6.Unloaded then
            break
        end
        if lW.AutoPlaceBait.Value then
            pcall(function()
                local qO
                local qN_1
                local qM_1
                local qH = md()
                local qI = l3()
                if not qH or not qI then
                    return
                end
                local Value2 = lW.PlaceAnyBait.Value
                local qK_1 = not Value2
                if qK_1 ~= false then
                    qK_1 = mp(lK) == 0
                end
                if qK_1 then
                    return
                end
                local qK_2 = 0
                local Value = Options.PlacePerCycle.Value
                qM_1, qN_1 = nil, 1
                local qX = false
                for i, v in ipairs(mc(qH)) do
                    local qW = 24
                    while true do
                        if qW < 17 then
                            if qW < 8 then
                                if qW < 4 then
                                    if qW < 2 then
                                        if qW < 1 then
                                            qN_1 += 1
                                            qW = 5
                                        else
                                            break
                                        end
                                    elseif qW < 3 then
                                        qW = if not qM_1 then 20 else 10
                                    else
                                        qW = 22
                                    end
                                elseif qW < 6 then
                                    if qW < 5 then
                                        qO = qH > 0
                                        qW = if qO then 26 else 18
                                    else
                                        qW = 3
                                    end
                                elseif qW < 7 then
                                    qW = 23
                                else
                                    qW = if qH then 21 else 23
                                end
                            elseif qW < 12 then
                                if qW < 10 then
                                    if qW < 9 then
                                        qW = if qH then 33 else 25
                                    else
                                        qH = lK[v.baitType]
                                        qW = 7
                                    end
                                elseif qW < 11 then
                                    qH = v.amount
                                    qW = 22
                                else
                                    qO = qM_1[qN_1]
                                    qW = if qO.blocked then 0 else 31
                                end
                            elseif qW < 14 then
                                if qW < 13 then
                                    qO = l6.Unloaded
                                    qW = if qO then 19 else 28
                                else
                                    qW = if qH then 8 else 17
                                end
                            elseif qW < 15 then
                                qW = 6
                            elseif qW < 16 then
                                qH = l6.Unloaded
                                qW = 13
                            else
                                qW = 14
                            end
                        elseif qW < 25 then
                            if qW < 21 then
                                if qW < 19 then
                                    if qW < 18 then
                                        qH = not lW.AutoPlaceBait.Value
                                        qW = 8
                                    else
                                        qW = if qO then 30 else 29
                                    end
                                elseif qW < 20 then
                                    qW = if qO then 16 else 11
                                else
                                    qM_1 = l0(qI, qH, lF, true)
                                    qW = 10
                                end
                            elseif qW < 23 then
                                if qW < 22 then
                                    qH = mm(ToolType.Bait, v.baitType, { diamond = v.mutation == BaitMutation.Diamond })
                                    qW = if qH then 2 else 6
                                else
                                    qW = 4
                                end
                            elseif qW < 24 then
                                qW = 1
                            else
                                qH = qK_2 >= Value
                                qW = if qH then 13 else 15
                            end
                        elseif qW < 29 then
                            if qW < 27 then
                                if qW < 26 then
                                    qH = Value2
                                    qW = if qH then 7 else 9
                                else
                                    qO = qK_2 < Value
                                    qW = 18
                                end
                            elseif qW < 28 then
                                qX = true
                                qW = 1
                            else
                                qO = not lW.AutoPlaceBait.Value
                                qW = 19
                            end
                        elseif qW < 31 then
                            if qW < 30 then
                                qW = if qO then 12 else 32
                            else
                                qO = qN_1 <= #qM_1
                                qW = 29
                            end
                        elseif qW < 32 then
                            default.ponds.placeBuilding(PlaceableType.Bait, v.id, qO.position, nil)
                            lG(qM_1, qN_1)
                            qN_1 += 1
                            qH -= 1
                            qK_2 += 1
                            task.wait(Options.PlaceStepDelay.Value)
                            qW = 5
                        elseif qW < 33 then
                            qW = 14
                        else
                            qW = 27
                        end
                    end
                    if qX then
                        break
                    end
                end
            end)
        end
    end
end
local function fn782(aI, aJ)
    return (Baits[aI].price or math.huge) > (Baits[aJ].price or math.huge)
end
local function onPlaceGears(ew)
    mk = lH(ew, lJ)
end
lt = nil
lu = nil
lv = nil
lw = nil
lx = nil
BaitMutation = nil
lz = nil
connection = nil
lB = nil
Baits = nil
lD = nil
lE = nil
lF = nil
lG = nil
lH = nil
lI = nil
lJ = nil
lK = nil
fish_utils = nil
lM = nil
tool_util = nil
lO = nil
lP = nil
lQ = nil
lR = nil
lS = nil
gears = nil
Options = nil
lV = nil
lW = nil
lX = nil
bait = nil
lZ = nil
shop_restock = nil
l0 = nil
l1 = nil
player_data = nil
l3 = nil
components = nil
l5 = nil
l6 = nil
l7 = nil
World = nil
l9 = nil
ma = nil
default = nil
mc = nil
md = nil
me = nil
mf = nil
mg = nil
LocalPlayer = nil
ShopType = nil
mj = nil
mk = nil
PlaceableType = nil
mm = nil
connection2 = nil
mo = nil
mp = nil
mq = nil
VirtualUser = nil
ms = nil
ToolType = nil
mu = nil
mv = nil
mw = nil
mx = nil
local mD, mE, mG, mI, mL, mM, mN, AutoCollectGroup, AutoPlaceGearsGroup, AutoPlacePetsGroup
local mK_4
VirtualUser, LocalPlayer = nil, nil
local Players = game:GetService("Players")
local my_9
local mA = game:GetService("ReplicatedStorage")
VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
LocalPlayer = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
default, World, components, player_data, shop_restock, bait, mD, gears, mG, tool_util, fish_utils, Baits, BaitMutation, mI, mv, ToolType, PlaceableType, ShopType, me = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local mF = mA:WaitForChild("TS")
local mF_6
default = require(mF.remotes).default
World = require(mF.World).World
components = require(mF.components.components)
player_data = require(mF.state["player-data"])
shop_restock = require(mF.state["shop-restock"])
if (mG or (not mI or not bait) or (default and not PlaceableType or default and PlaceableType)) and ((not bait or bait or (mI or bait)) and (not bait or mG or (default or mG))) or (not bait and not bait and (not PlaceableType and not bait) or (not bait or not mG) and (not mI or 55) or (not PlaceableType and 55 or false or mI and not bait and (not PlaceableType and not mG))) or not ((mG or (not mI or not bait) or (default and not PlaceableType or default and PlaceableType)) and ((not bait or bait or (mI or bait)) and (not bait or mG or (default or mG))) or (not bait and not bait and (not PlaceableType and not bait) or (not bait or not mG) and (not mI or 55) or (not PlaceableType and 55 or false or mI and not bait and (not PlaceableType and not mG)))) then
    bait = require(mF.lists.game.bait)
else
    mF = require(bait.lists.game.bait)
end
if (not Baits or World) and (gears or mv) and (gears or World or Baits and gears) and ((not mG or not Baits) and (gears and not Baits) or World and Baits and (not Baits and mv)) and not ((not Baits or World) and (gears or mv) and (gears or World or Baits and gears) and ((not mG or not Baits) and (gears and not Baits) or World and Baits and (not Baits and mv))) then
    mF = require(mD.lists.eggs)
else
    mD = require(mF.lists.eggs)
end
local mC = require(mF.lists.game.pets)
gears = require(mF.lists.game.gears.gears)
mG = require(mF.lists.rarities)
tool_util = require(mF.utils["tool.util"])
fish_utils = require(mF.utils["fish.utils"])
local mz = require(mF.lists.game["tool-meta"])
local placeable_meta = require(mF.lists.game["placeable-meta"])
Baits = bait.Baits
BaitMutation = bait.BaitMutation
mI = mD.Eggs
local mH = mC.Pets
mv = gears.Gears
ToolType = mz.ToolType
PlaceableType = placeable_meta.PlaceableType
ShopType = shop_restock.ShopType
for i, descendant in ipairs(LocalPlayer:WaitForChild("PlayerScripts"):GetDescendants()) do
    local my_2 = descendant:IsA("ModuleScript") and descendant.Name == "assignClient"
    if my_2 then
        me = require(descendant)
        break
    end
end
mz, l6, mD, mC, lW, Options, lR, lF, lD, lz, lv, mA, mE, lO = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local my_3 = 2
repeat
    local mF_1 = (my_3 * 5 + 3) % 6 + 1
    if mF_1 <= 3 then
        if mF_1 <= 2 then
            if mF_1 <= 1 then
                if my_3 * 63323711 + 12 + 7 <= my_3 * 63323711 + 12 + 7 + 4 then
                    lv = "All Fish"
                    mA = "Filtered"
                    mE = {}
                else
                    mA = "All Fish"
                    mE = "Filtered"
                    lv = {}
                end
                my_3 = (my_3 + 23) % 24
            else
                if (not mz and Options or lv and false) and (not lv and Options or mA and not Options) and (mz or not lv or false and not mz or Options and Options and (lz and not lv)) or not ((not mz and Options or lv and false) and (not lv and Options or mA and not Options) and (mz or not lv or false and not mz or Options and Options and (lz and not lv))) then
                    mz = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
                else
                    mE = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
                end
                my_3 = (my_3 + 11) % 24
            end
        else
            local vm = bit32.rrotate(bit32.bxor(bit32.lrotate(my_3, 18), 49), 1)
            if bit32.bxor(bit32.lrotate(bit32.bxor(vm, 1230971509), 10), 2089407781) ~= bit32.lrotate(vm, 10) then
                mC = getgenv().Library
                pcall(fn693)
                lW = getgenv().ThemeManager
                mz = getgenv().SaveManager
                l6 = mC.Toggles
                mD = mC.Options
            else
                l6 = getgenv().Library
                pcall(fn693)
                mD = getgenv().ThemeManager
                mC = getgenv().SaveManager
                lW = l6.Toggles
                Options = l6.Options
            end
            my_3 = (my_3 + 17) % 24
        end
    elseif mF_1 <= 5 then
        if mF_1 <= 4 then
            local mF_2 = {
                "nvflzlagqogr",
                "ezyilxdplp",
                "uthromrjnys",
                "sefmanpy",
                "jwnimbqbnc",
                "wifzhun",
                "alce",
                "ynirvxz",
                "ssxpmdhn"
            }
            if mF_2[(my_3 * 64 + 42) % 9 + 1] <= mF_2[(my_3 * 64 + 42) % 9 + 1] then
                lR = "https://discord.gg/K7Qxnxkk46"
                lO = fn87
                lF = 5
            else
                lF = "https://discord.gg/K7Qxnxkk46"
                lR = fn87
                lO = 5
            end
            my_3 = (my_3 + 5) % 24
        else
            local mF_3 = (vector.create((my_3 * 6 + 1) % 11 + 1, (my_3 * 6 + 1) % 13 + 1, (my_3 * 7 + 6) % 17 + 1))
            local mK_1 = (vector.create((my_3 * 4 + 1) % 11 + 1, (my_3 * 3 + 12) % 13 + 1, (my_3 * 8 + 10) % 17 + 1))
            mL = (vector.create((my_3 * 6 + 5) % 11 + 1, (my_3 * 3 + 3) % 13 + 1, (my_3 * 13 + 13) % 17 + 1))
            mM = (vector.create((my_3 * 1 + 9) % 11 + 1, (my_3 * 4 + 11) % 13 + 1, (my_3 * 2 + 9) % 17 + 1))
            if vector.dot(vector.cross(mF_3, mK_1), (vector.cross(mL, mM))) == vector.dot(mF_3, mL) * vector.dot(mK_1, mM) - vector.dot(mF_3, mM) * vector.dot(mK_1, mL) then
                lD = 1
            else
                mz = 1
            end
            my_3 = (my_3 + 23) % 24
        end
    else
        local mF_4 = {
            "xdhmpvj",
            "lgsuuiifib",
            "cylqczf",
            "rcwargzre",
            "hocqnszqyl",
            "rpflflrdops",
            "rpikqfpjj",
            "pxneleogrvi",
            "axyh",
            "mcyhotkn",
            "tjnek",
            "aixu"
        }
        local vh = my_3
        local mK_2 = mF_4[vh % 12 + 1]
        local nf = if mK_2:len() <= mK_2:gsub("(.)", "%1%1", vh % 3 % 2 + 1):len() then 1 else 0
        if nf == 1 then
            lz = 4.5
        else
            mE = 4.5
        end
        my_3 = (my_3 + 23) % 24
    end
until (my_3 * 13 + 19) % 24 == 3
local mF_5 = {}
for k, v in mG.Rarity do
    local my_4 = #mF_5 + 1
    mz = mG.RARITY_ORDER[v] or 0
    mF_5[my_4] = { name = k, order = mz }
end
local mK_3 = 0
repeat
    local my_5 = { "tdpaousc", "iwxs", "emx", "hxbi", "justvncios", "tbk", "xax", "wjrxisfisp", "wbkfeobzne" }
    if my_5[(mK_3 * 16 + 73) % 9 + 1] < my_5[(mK_3 * 16 + 73) % 9 + 1] then
        table.sort(mF_5, fn8)
    else
        table.sort(mF_5, fn8)
    end
    mK_3 = (mK_3 + 7) % 8
until (mK_3 * 1 + 7) % 8 == 6
for k, v in mF_5 do
    mE[#mE + 1] = v.name
end
lw, mw, mo, mj = nil, nil, nil, nil
mz = fn377
mG, lw = mz(Baits)
mF_6, mw = mz(mI)
mK_4, mo = mz(mH)
if (not mj and not mK_4) or not mj and mG and false or mG and mG and (not mj and not mG) and (not lw or mo or (not mG or mK_4)) or not ((not mj and not mK_4) or not mj and mG and false or mG and mG and (not mj and not mG) and (not lw or mo or (not mG or mK_4))) then
    mj = {}
else
    lw = {}
end
for k, v in Baits do
    if v.source == bait.BaitSource.BaitShop then
        mj[#mj + 1] = k
    end
end
mL, lV, mI, lJ, mH, mM, l9, lH, mp = nil, nil, nil, nil, nil, nil, nil, nil, nil
local my_6 = 34
repeat
    mN = (my_6 * 1 + 0) % 5 + 1
    if mN <= 3 then
        if mN <= 2 then
            if mN <= 1 then
                local uX = bit32.rrotate(bit32.bxor(bit32.lrotate(my_6, 17), string.byte(tostring(mI))), 15)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(uX, 659667551), 676950241), (bit32.bxor(bit32.band(uX, 3635299744), 153913486))), 676950241), 153913486) ~= uX then
                    lH, mv = mI(mz, fn548)
                    lJ = fn660
                else
                    mI, lJ = mz(mv, fn548)
                    lH = fn660
                end
                my_6 = (my_6 + 1) % 40
            else
                if my_6 * 41021143 + 1 + 2 <= my_6 * 41021143 + 1 + 2 + 3 then
                    mp = fn136
                else
                    mL = fn136
                end
                my_6 = (my_6 + 16) % 40
            end
        else
            if (my_6 * 3 + 4) * 5 % 4 == ((my_6 * 3 + 4) * 5 + 12) % 4 then
                mH = { "FoodScoop", "GoldenFoodScoop" }
            else
                lJ = { "FoodScoop", "GoldenFoodScoop" }
            end
            my_6 = (my_6 + 21) % 40
        end
    elseif mN <= 4 then
        mN = {
            "wkknaecc",
            "xht",
            "huufghn",
            "ckiphrc",
            "vvisryhg",
            "vnpnt",
            "kubh",
            "nhgcybuwmjgy",
            "noxluulr",
            "ztkozyxh",
            "adc",
            "otf"
        }
        if mN[(my_6 * 77 + 63) % 12 + 1] < mN[(my_6 * 77 + 63) % 12 + 1] then
            l9 = {}
            mM = {}
        else
            mM = {}
            l9 = {}
        end
        my_6 = (my_6 + 36) % 40
    else
        if ((lJ or not lJ) and (mM or not mL) or (not mL or mL or not mH and not mH)) and ((not lJ or mH or mM and lH) and (not my_6 or my_6 or lJ and not lH)) and (not mM or mH or (mH or not lH) or lH and not mL and (mH and not lJ) or (not my_6 and my_6 and (not my_6 or not mH) or (not my_6 or not lJ) and (not mH or not mL))) or not (((lJ or not lJ) and (mM or not mL) or (not mL or mL or not mH and not mH)) and ((not lJ or mH or mM and lH) and (not my_6 or my_6 or lJ and not lH)) and (not mM or mH or (mH or not lH) or lH and not mL and (mH and not lJ) or (not my_6 and my_6 and (not my_6 or not mH) or (not my_6 or not lJ) and (not mH or not mL)))) then
            table.sort(mj, fn782)
            mL, lV = mz(mv, fn303)
        else
            table.sort(mv, fn782)
            mz, mL = lV(mj, fn303)
        end
        my_6 = (my_6 + 31) % 40
    end
until (my_6 * 27 + 11) % 40 == 4
for i, v in ipairs(mH) do
    local my_7 = mv[v]
    mz = my_7 and my_7.name
    mz = mz or v
    mM[#mM + 1] = mz
    l9[mz] = v
end
lX, lS = nil, nil
lX = {
    { name = "Baits", key = "baits" },
    { name = "Boosters", key = "boosters" },
    { name = "Eggs", key = "eggs" },
    { name = "Machines", key = "machines" },
    { name = "Cosmetics", key = "cosmetics" },
    { name = "Cosmetic Extras", key = "cosmeticsExtra" }
}
mH = {}
lS = {}
for i, v in ipairs(lX) do
    mH[#mH + 1] = v.name
    lS[v.name] = v.key
end
lK, lI, lE, lB, lx, lt, mx, mu, mq, mk, mg, my_9, md, ma, l3, lM, ms, l5, mm, l0, lG, mf, l7, lQ, mc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lK = {}
lI = {}
lE = {}
lB = {}
lx = {}
lt = {}
if (my_9 or not my_9 or (l7 or l7) or (not mf or not my_9) and (mf or mf)) and ((not mf or not l7 or my_9 and l7) and ((not l7 or my_9) and (not l7 or l7))) and (my_9 and mf and (not my_9 and not my_9) and (not my_9 and not l7 and (mf and not my_9)) or ((not l7 or l7) and (l7 or my_9) or (not mf and not l7 or (l7 or l7)))) and not ((my_9 or not my_9 or (l7 or l7) or (not mf or not my_9) and (mf or mf)) and ((not mf or not l7 or my_9 and l7) and ((not l7 or my_9) and (not l7 or l7))) and (my_9 and mf and (not my_9 and not my_9) and (not my_9 and not l7 and (mf and not my_9)) or ((not l7 or l7) and (l7 or my_9) or (not mf and not l7 or (l7 or l7))))) then
    mu = {}
    mx = {}
else
    mx = {}
    mu = {}
end
mq = {}
mk = {}
mg = {}
md = fn657
ma = fn672
l3 = fn721
lM = fn396
if lM and lM or (lM or lM) or lM and not lM and (not lG and lM) or not (lM and lM or (lM or lM) or lM and not lM and (not lG and lM)) then
    ms = fn686
    l5 = fn185
    mm = fn86
    l0 = fn59
else
    l5 = fn686
    ms = fn185
    l0 = fn86
    mm = fn59
end
lG = fn30
mf = fn308
l7 = fn53
lQ = fn345
mc = fn38
local Window = l6:CreateWindow({
    Title = "Tempo Hub",
    Footer = lR .. " | Farm a Fish",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false
})
local mO = {
    Info = Window:AddTab("Info", "info"),
    Bait = Window:AddTab("Bait", "worm"),
    Fish = Window:AddTab("Fish", "fish"),
    Eggs = Window:AddTab("Eggs", "egg"),
    Pets = Window:AddTab("Pets", "paw-print"),
    Gear = Window:AddTab("Gear", "wrench"),
    Pond = Window:AddTab("Pond", "droplet"),
    Settings = Window:AddTab("Settings", "settings")
}
mN = fn188
for k, v in mO do
    mN(v)
end
lu, AutoCollectGroup, AutoPlacePetsGroup, AutoPlaceGearsGroup, l1, lZ, connection, connection2, lP = nil, nil, nil, nil, nil, nil, nil, nil, nil
local BasicInfoGroup = mO.Info:AddLeftGroupbox("Basic Info", "circle-user")
lu = "Unknown"
pcall(fn623)
BasicInfoGroup:AddLabel("Executor: " .. lu, true)
BasicInfoGroup:AddLabel("Game: Farm a Fish", true)
BasicInfoGroup:AddLabel("Player: " .. LocalPlayer.Name, true)
BasicInfoGroup:AddLabel("Status: Keyless", true)
local TempoHubGroup = mO.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = lO })
local FaqGroup = mO.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoPlaceSeedsGroup = mO.Bait:AddLeftGroupbox("Auto Place Seeds", "sprout")
AutoPlaceSeedsGroup:AddToggle("AutoPlaceBait", { Text = "Auto Place Seeds", Default = false })
AutoPlaceSeedsGroup:AddToggle("PlaceAnyBait", { Text = "Place Any Owned Bait", Default = true })
AutoPlaceSeedsGroup:AddDropdown("PlaceBaits", {
    Text = "Baits To Place",
    Values = mG,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = onPlaceBaits
})
AutoPlaceSeedsGroup:AddSlider("PlacePerCycle", { Text = "Place Per Cycle", Default = 5, Min = 1, Max = 25, Rounding = 0 })
AutoPlaceSeedsGroup:AddSlider("PlaceStepDelay", { Text = "Place Step Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 2 })
AutoPlaceSeedsGroup:AddSlider("PlaceLoopDelay", { Text = "Place Loop Delay", Default = 3, Min = 1, Max = 30, Rounding = 1 })
local AutoBuyBaitGroup = mO.Bait:AddRightGroupbox("Auto Buy Bait", "shopping-basket")
if (l1 and not lP and (not l1 and AutoPlaceGearsGroup) or not l1 and AutoPlaceGearsGroup and (not l1 and AutoPlaceGearsGroup) or (not AutoPlaceGearsGroup and lP or (l1 or AutoPlaceGearsGroup)) and (lP and l1 or AutoPlaceGearsGroup and not AutoPlaceGearsGroup)) and not (l1 and not lP and (not l1 and AutoPlaceGearsGroup) or not l1 and AutoPlaceGearsGroup and (not l1 and AutoPlaceGearsGroup) or (not AutoPlaceGearsGroup and lP or (l1 or AutoPlaceGearsGroup)) and (lP and l1 or AutoPlaceGearsGroup and not AutoPlaceGearsGroup)) then
    mG:AddToggle("AutoBuyBait", { Text = "Auto Buy Bait", Default = false })
    mG:AddToggle("BuyAnyAffordableBait", { Text = "Buy Any Affordable Bait", Default = false })
    mG:AddDropdown("BuyBaits", {
        Multi = true,
        Values = AutoCollectGroup,
        Text = "Baits To Buy",
        Searchable = true,
        Callback = onBuyBaits,
        Default = {}
    })
    mG:AddSlider("BaitCoinReserve", { Text = "Coin Reserve", Min = 0, Default = 0, Max = 10000000, Rounding = 0 })
    mG:AddSlider("BaitBuyPerCycle", { Text = "Buy Per Cycle", Rounding = 0, Min = 1, Default = 10, Max = 50 })
    mG:AddSlider("BaitBuyStepDelay", { Min = 0.1, Max = 3, Text = "Buy Step Delay", Rounding = 2, Default = 0.3 })
    mG:AddSlider("BaitBuyLoopDelay", { Text = "Buy Loop Delay", Rounding = 1, Min = 1, Max = 60, Default = 5 })
    mG:AddToggle("BaitBuyNotify", { Text = "Notify On Purchase", Default = false })
    mO = AutoBuyBaitGroup.Fish:AddLeftGroupbox("Auto Collect", "hand-grab")
else
    AutoBuyBaitGroup:AddToggle("AutoBuyBait", { Text = "Auto Buy Bait", Default = false })
    AutoBuyBaitGroup:AddToggle("BuyAnyAffordableBait", { Text = "Buy Any Affordable Bait", Default = false })
    AutoBuyBaitGroup:AddDropdown("BuyBaits", {
        Text = "Baits To Buy",
        Values = mG,
        Default = {},
        Multi = true,
        Searchable = true,
        Callback = onBuyBaits
    })
    AutoBuyBaitGroup:AddSlider("BaitCoinReserve", { Text = "Coin Reserve", Default = 0, Min = 0, Max = 10000000, Rounding = 0 })
    AutoBuyBaitGroup:AddSlider("BaitBuyPerCycle", { Text = "Buy Per Cycle", Default = 10, Min = 1, Max = 50, Rounding = 0 })
    AutoBuyBaitGroup:AddSlider("BaitBuyStepDelay", { Text = "Buy Step Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 2 })
    AutoBuyBaitGroup:AddSlider("BaitBuyLoopDelay", { Text = "Buy Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
    AutoBuyBaitGroup:AddToggle("BaitBuyNotify", { Text = "Notify On Purchase", Default = false })
    AutoCollectGroup = mO.Fish:AddLeftGroupbox("Auto Collect", "hand-grab")
end
AutoCollectGroup:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
AutoCollectGroup:AddToggle("CollectOnlyFull", { Text = "Only Collect Full Nets", Default = false })
AutoCollectGroup:AddSlider("CollectMinFish", { Text = "Minimum Fish In Net", Default = 1, Min = 1, Max = 10, Rounding = 0 })
AutoCollectGroup:AddSlider("CollectStepDelay", { Text = "Collect Step Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
AutoCollectGroup:AddSlider("CollectLoopDelay", { Text = "Collect Loop Delay", Default = 3, Min = 1, Max = 60, Rounding = 1 })
local AutoSellGroup = mO.Fish:AddRightGroupbox("Auto Sell", "banknote")
AutoSellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
AutoSellGroup:AddDropdown("SellMode", { Text = "Sell Mode", Values = { lv, mA }, Default = lv, Multi = false })
AutoSellGroup:AddDropdown("SellRarities", { Text = "Rarities To Sell", Values = mE, Default = {}, Multi = true, Callback = onSellRarities })
AutoSellGroup:AddSlider("SellMaxValue", { Text = "Maximum Fish Value", Default = 1000000, Min = 0, Max = 100000000, Rounding = 0 })
AutoSellGroup:AddToggle("SellKeepLiked", { Text = "Keep Liked Fish", Default = true })
AutoSellGroup:AddSlider("SellMinHeld", { Text = "Sell Above Fish Count", Default = 1, Min = 1, Max = 200, Rounding = 0 })
AutoSellGroup:AddSlider("SellStepDelay", { Text = "Sell Step Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
AutoSellGroup:AddSlider("SellLoopDelay", { Text = "Sell Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
mz = mO.Eggs:AddLeftGroupbox("Auto Place Eggs", "egg")
mz:AddToggle("AutoPlaceEgg", { Text = "Auto Place Eggs", Default = false })
mz:AddToggle("PlaceAnyEgg", { Text = "Place Any Owned Egg", Default = true })
mz:AddDropdown("PlaceEggs", {
    Text = "Eggs To Place",
    Values = mF_6,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = onPlaceEggs
})
mz:AddSlider("EggPlacePerCycle", { Text = "Place Per Cycle", Default = 3, Min = 1, Max = 25, Rounding = 0 })
mz:AddSlider("EggPlaceStepDelay", { Text = "Place Step Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 2 })
mz:AddSlider("EggPlaceLoopDelay", { Text = "Place Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
local AutoOpenReadyEggsGroup = mO.Eggs:AddRightGroupbox("Auto Open Ready Eggs", "egg-fried")
if AutoPlaceGearsGroup and lP and (lP and AutoPlaceGearsGroup) and (lZ or not AutoPlaceGearsGroup or AutoPlaceGearsGroup and not AutoPlaceGearsGroup) or not (AutoPlaceGearsGroup and lP and (lP and AutoPlaceGearsGroup) and (lZ or not AutoPlaceGearsGroup or AutoPlaceGearsGroup and not AutoPlaceGearsGroup)) then
    AutoOpenReadyEggsGroup:AddToggle("AutoHatch", { Text = "Auto Open Ready Eggs", Default = false })
    AutoOpenReadyEggsGroup:AddToggle("HatchAnyEgg", { Text = "Open Any Ready Egg", Default = true })
    AutoOpenReadyEggsGroup:AddDropdown("HatchEggs", {
        Text = "Eggs To Open",
        Values = mF_6,
        Default = {},
        Multi = true,
        Searchable = true,
        Callback = onHatchEggs
    })
    AutoOpenReadyEggsGroup:AddSlider("HatchPerCycle", { Text = "Open Per Cycle", Default = 5, Min = 1, Max = 50, Rounding = 0 })
    AutoOpenReadyEggsGroup:AddSlider("HatchStepDelay", { Text = "Open Step Delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2 })
    AutoOpenReadyEggsGroup:AddSlider("HatchLoopDelay", { Text = "Open Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
    AutoPlacePetsGroup = mO.Pets:AddLeftGroupbox("Auto Place Pets", "paw-print")
else
    mO:AddToggle("AutoHatch", { Text = "Auto Open Ready Eggs", Default = false })
    mO:AddToggle("HatchAnyEgg", { Text = "Open Any Ready Egg", Default = true })
    mO:AddDropdown("HatchEggs", {
        Text = "Eggs To Open",
        Callback = onHatchEggs,
        Values = AutoPlacePetsGroup,
        Default = {},
        Multi = true,
        Searchable = true
    })
    mO:AddSlider("HatchPerCycle", { Rounding = 0, Max = 50, Default = 5, Text = "Open Per Cycle", Min = 1 })
    mO:AddSlider("HatchStepDelay", { Rounding = 2, Max = 3, Min = 0.1, Text = "Open Step Delay", Default = 0.4 })
    mO:AddSlider("HatchLoopDelay", { Text = "Open Loop Delay", Default = 5, Max = 60, Rounding = 1, Min = 1 })
    AutoOpenReadyEggsGroup.Pets:AddLeftGroupbox("Auto Place Pets", "paw-print")
end
AutoPlacePetsGroup:AddToggle("AutoPlacePet", { Text = "Auto Place Pets", Default = false })
AutoPlacePetsGroup:AddToggle("PlaceAnyPet", { Text = "Place Any Owned Pet", Default = true })
AutoPlacePetsGroup:AddDropdown("PlacePets", {
    Text = "Pets To Place",
    Values = mK_4,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = onPlacePets
})
AutoPlacePetsGroup:AddSlider("PetPlacePerCycle", { Text = "Place Per Cycle", Default = 3, Min = 1, Max = 25, Rounding = 0 })
AutoPlacePetsGroup:AddSlider("PetPlaceStepDelay", { Text = "Place Step Delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2 })
AutoPlacePetsGroup:AddSlider("PetPlaceLoopDelay", { Text = "Place Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
local AutoBuyGearsGroup = mO.Gear:AddLeftGroupbox("Auto Buy Gears", "shopping-cart")
AutoBuyGearsGroup:AddToggle("AutoBuyGear", { Text = "Auto Buy Gears", Default = false })
AutoBuyGearsGroup:AddDropdown("BuyGears", {
    Text = "Gears To Buy",
    Values = mL,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = onBuyGears
})
AutoBuyGearsGroup:AddSlider("GearCoinReserve", { Text = "Coin Reserve", Default = 0, Min = 0, Max = 10000000, Rounding = 0 })
AutoBuyGearsGroup:AddSlider("GearBuyPerCycle", { Text = "Buy Per Cycle", Default = 5, Min = 1, Max = 50, Rounding = 0 })
AutoBuyGearsGroup:AddSlider("GearBuyStepDelay", { Text = "Buy Step Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 2 })
AutoBuyGearsGroup:AddSlider("GearBuyLoopDelay", { Text = "Buy Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
AutoBuyGearsGroup:AddToggle("GearBuyNotify", { Text = "Notify On Purchase", Default = false })
AutoPlaceGearsGroup = mO.Gear:AddRightGroupbox("Auto Place Gears", "hammer")
AutoPlaceGearsGroup:AddToggle("AutoPlaceGear", { Text = "Auto Place Gears", Default = false })
AutoPlaceGearsGroup:AddToggle("PlaceAnyGear", { Text = "Place Any Owned Gear", Default = true })
AutoPlaceGearsGroup:AddDropdown("PlaceGears", {
    Text = "Gears To Place",
    Values = mI,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = onPlaceGears
})
AutoPlaceGearsGroup:AddSlider("GearPlacePerCycle", { Text = "Place Per Cycle", Default = 3, Min = 1, Max = 25, Rounding = 0 })
AutoPlaceGearsGroup:AddSlider("GearPlaceStepDelay", { Text = "Place Step Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 2 })
AutoPlaceGearsGroup:AddSlider("GearPlaceLoopDelay", { Text = "Place Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
local AutoScoopGroup = mO.Pond:AddLeftGroupbox("Auto Scoop", "utensils")
AutoScoopGroup:AddToggle("AutoScoop", { Text = "Auto Scoop", Default = false })
AutoScoopGroup:AddDropdown("ScoopGear", { Text = "Scoop Gear", Values = mM, Default = mM[1], Multi = false })
AutoScoopGroup:AddToggle("ScoopAnyBait", { Text = "Scoop Any Bait", Default = true })
AutoScoopGroup:AddDropdown("ScoopBaits", {
    Text = "Baits To Scoop",
    Values = mG,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = onScoopBaits
})
AutoScoopGroup:AddToggle("ScoopSkipFull", { Text = "Skip Full Nets", Default = true })
AutoScoopGroup:AddSlider("ScoopPerCycle", { Text = "Scoops Per Cycle", Default = 10, Min = 1, Max = 100, Rounding = 0 })
AutoScoopGroup:AddSlider("ScoopStepDelay", { Text = "Scoop Step Delay", Default = 0.2, Min = 0.05, Max = 3, Rounding = 2 })
AutoScoopGroup:AddSlider("ScoopLoopDelay", { Text = "Scoop Loop Delay", Default = 3, Min = 1, Max = 60, Rounding = 1 })
local AutoDeleteBuildingsGroup = mO.Pond:AddRightGroupbox("Auto Delete Buildings", "trash-2")
AutoDeleteBuildingsGroup:AddToggle("AutoDelete", { Text = "Auto Delete Buildings", Default = false })
AutoDeleteBuildingsGroup:AddDropdown("DeleteGroups", {
    Text = "Building Types To Delete",
    Values = mH,
    Default = {},
    Multi = true,
    Callback = onDeleteGroups
})
AutoDeleteBuildingsGroup:AddToggle("DeleteAnyBait", { Text = "Delete Any Bait Type", Default = false })
AutoDeleteBuildingsGroup:AddDropdown("DeleteBaits", {
    Text = "Baits To Delete",
    Values = mG,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = onDeleteBaits
})
AutoDeleteBuildingsGroup:AddSlider("DeleteBaitBelowValue", { Text = "Delete Baits Below Base Value", Default = 0, Min = 0, Max = 1000000, Rounding = 0 })
AutoDeleteBuildingsGroup:AddToggle("DeleteOnlyEmpty", { Text = "Only Delete Empty Nets", Default = true })
AutoDeleteBuildingsGroup:AddSlider("DeletePerCycle", { Text = "Delete Per Cycle", Default = 5, Min = 1, Max = 50, Rounding = 0 })
AutoDeleteBuildingsGroup:AddSlider("DeleteStepDelay", { Text = "Delete Step Delay", Default = 0.3, Min = 0.1, Max = 3, Rounding = 2 })
AutoDeleteBuildingsGroup:AddSlider("DeleteLoopDelay", { Text = "Delete Loop Delay", Default = 10, Min = 1, Max = 120, Rounding = 1 })
local MenuGroup = mO.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
l6.ToggleKeybind = Options.MenuKeybind
l1 = tick()
lZ = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local qx = v
        pcall(function()
            qx:Disable()
        end)
    end
end)
lP = fn132
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
l6:OnUnload(fn175)
task.spawn(antiAfkLoop)
task.spawn(autoPlaceBaitLoop)
task.spawn(autoBuyBaitLoop)
task.spawn(autoCollectLoop)
task.spawn(autoSellLoop)
task.spawn(autoBuyGearLoop)
task.spawn(autoPlaceGearLoop)
task.spawn(autoPlaceEggLoop)
task.spawn(autoScoopLoop)
task.spawn(autoDeleteLoop)
task.spawn(autoHatchLoop)
task.spawn(autoPlacePetLoop)
mD:SetLibrary(l6)
mD:SetFolder("TempoHub")
mD:SaveDefault("Mint")
mC:SetLibrary(l6)
mC:IgnoreThemeSettings()
mC:SetIgnoreIndexes({ "MenuKeybind" })
mC:SetFolder("TempoHub/FarmAFish")
mC:BuildConfigSection(mO.Settings)
mD:ApplyToTab(mO.Settings)
mD:LoadDefault()
mC:LoadAutoloadConfig()
end)(...)
