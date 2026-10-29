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
getgenv().TempoHoodSubtitle = "MERGE A SQUISHY"
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
local iz
local iY
local connection
local iu
local iF
local Toggles
local jb
local je
local ix
local Lock
local jh
local iA
local iO
local Rebirth
local connection2
local Config
local iU
local Library
local LocalPlayer
local iB
local ji
local i_
local iH
local function fn23()
    local Character = LocalPlayer.Character
    local mx = Character and Character:FindFirstChild("HumanoidRootPart")
    return mx
end
local function fn34()
    local j0 = iH()
    local j1 = j0 and j0:FindFirstChild("Squishies")
    local j0_1 = j1
    local j5 = if j0_1 then 1 else 0
    local j3 = 2971 * j5 + 2049 * (1 - j5)
    local j4 = 2003 * j5 + 331 * (1 - j5)
    if not ((j3 * 3717 + j4 * 1927 + j3 * j4) % 16777213 == 4076688) then
        j0_1 = nil
    end
    return j0_1
end
local function fn39(cM)
    local Character = cM.Character
    local lQ = Character and Character:FindFirstChild("HumanoidRootPart")
    if lQ then
        return lQ.Position
    end
    local attr = cM:GetAttribute("PlotId")
    local lQ_1 = attr and workspace.Plots:FindFirstChild(tostring(attr))
    local lP_3 = lQ_1
    if lQ_1 then
        lQ_1 = lP_3:FindFirstChild("Floor")
    end
    local lP_4 = lQ_1
    if lQ_1 then
        lQ_1 = lP_4.Position
    end
    return lQ_1 or nil
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        if Toggles.AutoRebirth and Toggles.AutoRebirth.Value then
            local mc_1 = LocalPlayer:GetAttribute("Rebirths") or 0
            local mc_2 = mc_1 < iu
            if mc_2 then
                local md_1 = LocalPlayer:GetAttribute("ReachedTier") or 1
                mc_2 = md_1 >= iY()
            end
            if mc_2 then
                pcall(function()
                    Rebirth:InvokeServer()
                end)
            end
        end
        task.wait(3)
    end
end
local function fn47()
    local Character = LocalPlayer.Character
    local mu = Character and Character:FindFirstChildOfClass("Humanoid")
    return mu
end
local function fn48()
    ix(false)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
    if connection2 then
        pcall(function()
            connection2:Disconnect()
        end)
    end
end
local function fn76()
    local Character = LocalPlayer.Character
    local j7 = Character and Character:FindFirstChild("HumanoidRootPart")
    return j7 or nil
end
local function fn95(aI)
    local DiscordGroup = aI:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = iU })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = iU })
end
local function autoLaunchLoop()
    while not Library.Unloaded do
        if Toggles.AutoLaunch and Toggles.AutoLaunch.Value then
            pcall(iB)
        end
        task.wait(0.3)
    end
end
local function fn114(ad, ae)
    if setclipboard then
        setclipboard(ad)
    elseif toclipboard then
        toclipboard(ad)
    end
    Library:Notify(ae)
end
local function fn155()
    Config = require(iO.Shared.Config)
end
local function fn170()
    jb(iA, "Copied Discord invite to clipboard")
end
local function autoLockBaseLoop()
    while not Library.Unloaded do
        if Toggles.AutoLockBase and Toggles.AutoLockBase.Value then
            local mo_1 = iH()
            if mo_1 then
                local mp = workspace:GetServerTimeNow()
                local mq = mo_1:GetAttribute("ShieldUntil") or 0
                local mr = mq <= mp
                if mr then
                    local mq_1 = mo_1:GetAttribute("ShieldCDUntil") or 0
                    mr = mq_1 <= mp
                end
                if mr then
                    pcall(function()
                        Lock:InvokeServer()
                    end)
                end
            end
        end
        task.wait(2)
    end
end
local function fn429(d0)
    if not d0:IsA("ProximityPrompt") then
        return
    end
    d0.HoldDuration = 0
    d0.MaxActivationDistance = 50
    d0.RequiresLineOfSight = false
end
local function autoMergeLoop()
    while not Library.Unloaded do
        if Toggles.AutoMerge and Toggles.AutoMerge.Value then
            pcall(i_)
        end
        task.wait(0.25)
    end
end
local function fn522(aO, aP)
    return string.format('<font color="%s">%s</font>', aP, aO)
end
local function fn631()
    local jS = LocalPlayer:GetAttribute("Rebirths") or 0
    local jS_1
    local jT = Config
    local jT_1
    if jT then
        jT = Config.tierCap
    end
    if jT then
        jS_1, jT_1 = pcall(Config.tierCap, jS)
        local jV = jS_1 and type(jT_1) == "number"
        if jV then
            return jT_1
        end
        return math.min(ji, 30 + jS * 5)
    end
    return math.min(ji, 30 + jS * 5)
end
local function fn649()
    local ke = hookfunction ~= nil
    local kf = hookmetamethod ~= nil
    local kg = getrawmetatable ~= nil
    local kh = setrawmetatable ~= nil
    local ki = getgc ~= nil
    local kj = getgenv ~= nil
    local kk = getreg ~= nil
    local kl = getconnections ~= nil
    local km = firesignal ~= nil
    local kn = getcallbackvalue ~= nil
    local ko = setclipboard ~= nil
    local kp = getcustomasset ~= nil
    local kq = getnamecallmethod ~= nil
    local kr = isexecutorclosure ~= nil
    local ks = fireproximityprompt ~= nil
    local kt = firetouchinterest ~= nil
    local kv = WebSocket ~= nil
    local kw = readfile ~= nil
    local kx = writefile ~= nil
    local kz = (request or http_request) ~= nil
    local kB = (debug and debug.getupvalues) ~= nil
    local kD = (debug and debug.setupvalue) ~= nil
    local kE = 0
    local kF = { ke, kf, kg, kh, ki, kj, kk, kl, km, kn, ko, kp, kq, kr, ks, kt, kv, kw, kx, kz, kB, kD }
    for i, v in ipairs(kF) do
        if v then
            kE += 1
        end
    end
    local ke_1 = kE / #kF
    if ke_1 >= 0.9 then
        return je("Full Support", iF)
    elseif ke_1 >= 0.6 then
        return je("Half Support", iz)
    else
        return je("Low Support", jh)
    end
end
local function fn667()
    local attr = LocalPlayer:GetAttribute("PlotId")
    local jZ = attr and workspace.Plots:FindFirstChild(tostring(attr))
    return jZ or nil
end
local function fn677(aR, aS, aT)
    return string.format("<b>%s</b> %s %s", aR, je("-", "#5a6070"), je(aS, aT))
end
local function fn678()
    if Config then
        if Config.Economy and Config.Economy.REBIRTH_MAX then
            iu = Config.Economy.REBIRTH_MAX
        end
        if Config.MAX_TIER then
            ji = Config.MAX_TIER
        end
    end
end
iu = nil
ix = nil
Library = nil
iz = nil
iA = nil
iB = nil
connection2 = nil
iF = nil
Config = nil
iH = nil
LocalPlayer = nil
Lock = nil
connection = nil
iO = nil
iU = nil
iY = nil
Rebirth = nil
i_ = nil
Toggles = nil
jb = nil
je = nil
local is, it, iv, iw, iC, iE, iI, iK, iM, iP, Launch, iR, TeleportService, Upgrade, iV, Options, HttpService, VirtualUser, i2, i3, DropEvent, i5, UserInputService, i7, PickupEvent, RunService, TryMerge, Players2, jd
jh = nil
ji = nil
local jf, SaveManager, jj
local Remotes
Library, SaveManager, Players2, RunService, UserInputService, VirtualUser, HttpService, TeleportService, iO, LocalPlayer, iE, iA, iw, is, Remotes, TryMerge, PickupEvent, DropEvent, Rebirth, Upgrade, Launch, Lock, Config, iu, ji, Toggles, Options, iR, iY, jb, iU, iH, jj, i2, iK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
getgenv().gethui = function()
    local jL
    local screenGui
    jL = nil
    screenGui = nil
    local jN = cloneref and cloneref(game:GetService("CoreGui"))
    local jO = jN or game:GetService("CoreGui")
    jL = jO
    screenGui = Instance.new("ScreenGui")
    local jN_1 = pcall(function()
        if protectgui then
            protectgui(screenGui)
        end
        screenGui.Parent = jL
    end)
    screenGui:Destroy()
    if jN_1 then
        return jL
    end
    local Players = game:GetService("Players")
    local jO_1 = Players.LocalPlayer or Players.PlayerAdded:Wait()
    return jO_1:WaitForChild("PlayerGui")
end
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Players2 = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
TeleportService = game:GetService("TeleportService")
iO = game:GetService("ReplicatedStorage")
LocalPlayer = Players2.LocalPlayer
iE = "Merge a Squishy"
if ((not Players2 or not Upgrade) and (Options and is) or not i2 and Remotes and (not Upgrade and not Upgrade) or ((Upgrade or Remotes) and (false and Remotes) or (Options or Players2) and (not Options or Options))) and ((Upgrade and false or (i2 or not Upgrade)) and (not i2 and not Options or (Upgrade or not Upgrade)) or is and not Upgrade and false and (Upgrade and Options or is and not Remotes)) and not (((not Players2 or not Upgrade) and (Options and is) or not i2 and Remotes and (not Upgrade and not Upgrade) or ((Upgrade or Remotes) and (false and Remotes) or (Options or Players2) and (not Options or Options))) and ((Upgrade and false or (i2 or not Upgrade)) and (not i2 and not Options or (Upgrade or not Upgrade)) or is and not Upgrade and false and (Upgrade and Options or is and not Remotes))) then
    jj = "https://discord.gg/K7Qxnxkk46"
else
    iA = "https://discord.gg/K7Qxnxkk46"
end
iw = "https://discord.gg/K7Qxnxkk46"
is = "https://tempohub.shop"
if (jb or not TeleportService) and (TeleportService or TeleportService) or not iu and not jb and (not iu or iu) or not ((jb or not TeleportService) and (TeleportService or TeleportService) or not iu and not jb and (not iu or iu)) then
    Remotes = iO:WaitForChild("Remotes")
else
    iO = Remotes:WaitForChild("Remotes")
end
TryMerge = Remotes:WaitForChild("TryMerge")
PickupEvent = Remotes:WaitForChild("PickupEvent")
DropEvent = Remotes:WaitForChild("DropEvent")
Rebirth = Remotes:WaitForChild("Rebirth")
Upgrade = Remotes:WaitForChild("Upgrade")
Launch = Remotes:WaitForChild("Launch")
Lock = Remotes:WaitForChild("Lock")
Config = nil
pcall(fn155)
iu = 6
ji = 60
pcall(fn678)
iY = fn631
jb = fn114
iU = fn170
iH = fn667
jj = fn34
i2 = fn76
iK = function(aw)
    local mesh_node = aw:FindFirstChild("mesh_node")
    local ka = i2()
    if not mesh_node or not ka then
        return
    end
    ka.CFrame = CFrame.new(mesh_node.Position + Vector3.new(0, 3, 0))
    pcall(function()
        PickupEvent:FireServer(aw)
    end)
end
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = iA, Copyable = true }, "|", iE },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
Toggles = Library.Toggles
Options = Library.Options
iR = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in iR do
    if k ~= "Info" then
        fn95(v)
    end
end
iF, iC, iz, it, jh, i5, connection, iM, iI, connection2, jf, je, i3, jd, i_, iv, iB, i7, iP, ix, iV = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
je = fn522
i3 = fn677
iF = "#7fd47f"
iC = "#6ec1ff"
iz = "#e8a34d"
it = "#8b93a3"
jh = "#e05a5a"
jd = fn649
local function jt()
    local k6
    local k3
    k3 = nil
    k6 = nil
    local k1, k2, Label, Label2, Label3
    k3 = "Unknown"
    pcall(function()
        local kR_1
        local kQ_1
        if identifyexecutor then
            kR_1, kQ_1 = identifyexecutor()
            local kS = kR_1 ~= ""
            local kT = type(kR_1) == "string" and kS
            if kT then
                local kS_1 = type(kQ_1) == "string" and kQ_1 ~= "" and kR_1 .. " " .. kQ_1
                k3 = kS_1 or kR_1
            end
        end
    end)
    local k8 = jd()
    k6 = os.clock()
    k2 = function()
        local kV = math.floor(os.clock() - k6)
        if kV < 60 then
            return kV .. "s"
        elseif kV < 3600 then
            return string.format("%dm %ds", math.floor((kV) / (60)), kV % 60)
        else
            return string.format("%dh %dm", math.floor((kV) / (3600)), math.floor((kV % 3600) / (60)))
        end
    end
    local UserGroup = iR.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(i3("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, iF), true)
    UserGroup:AddLabel(i3("UserId", tostring(LocalPlayer.UserId), iC), true)
    UserGroup:AddLabel(i3("Executor", k3 .. "  " .. k8, iF), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(i3("Session", k2(), iz), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            jb(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            jb("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = iR.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(i3("Game", iE, iC), true)
    Label2 = SessionGroup:AddLabel(i3("Players", "0/0", iF), true)
    k1 = tostring(game.JobId)
    local k9_1 = #k1 > 18 and string.sub(k1, 1, 18) .. "..."
    local k9_2 = k9_1 or k1
    SessionGroup:AddLabel(i3("Job", k9_2, it), true)
    Label = SessionGroup:AddLabel(i3("Ping", "0 ms", iz), true)
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
            jb(k1, "Copied Job ID")
        end
    })
    task.spawn(function()
        local kY_1
        local kX_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(i3("Session", k2(), iz))
            Label2:SetText(i3("Players", #Players2:GetPlayers() .. "/" .. tostring(Players2.MaxPlayers), iF))
            kX_1, kY_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local kX_2 = kX_1 and kY_1 .. " ms" or "n/a"
            Label:SetText(i3("Ping", kX_2, iz))
        end
    end)
    local SocialsGroup = iR.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = iU })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            if setclipboard then
                setclipboard(iw)
            elseif toclipboard then
                toclipboard(iw)
            end
            Library:Notify("Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            jb(is, "Copied website link")
        end
    })
end
jt()
local MergeGroup = iR.Main:AddLeftGroupbox("Merge", "git-merge")
MergeGroup:AddToggle("AutoMerge", { Text = "Auto Merge", Default = false })
local RebirthGroup = iR.Main:AddLeftGroupbox("Rebirth", "repeat")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local BaseGroup = iR.Main:AddLeftGroupbox("Base", "shield")
BaseGroup:AddToggle("AutoLockBase", { Text = "Auto Lock Base", Default = false })
local UpgradesGroup = iR.Main:AddRightGroupbox("Upgrades", "arrow-up")
UpgradesGroup:AddToggle("AutoUpgrades", { Text = "Auto Buy Upgrades", Default = false })
UpgradesGroup:AddDropdown("UpgradeKinds", {
    Values = { "Spawn Tier", "Max Spawn", "Lock Base" },
    Default = { "Spawn Tier", "Max Spawn", "Lock Base" },
    Multi = true,
    Text = "Upgrades to buy"
})
local LaunchGroup = iR.Main:AddRightGroupbox("Launch", "rocket")
LaunchGroup:AddToggle("AutoLaunch", { Text = "Auto Launch", Default = false })
LaunchGroup:AddDropdown("LaunchTarget", { SpecialType = "Player", ExcludeLocalPlayer = true, Text = "Target player" })
i5 = { ["Spawn Tier"] = "SpawnTier", ["Max Spawn"] = "MaxSpawn", ["Lock Base"] = "LockBase" }
i_ = function()
    local li
    local lj = jj()
    if not lj then
        return
    end
    local lk = iY()
    local ll = LocalPlayer:GetAttribute("CarryId") or 0
    if ll ~= 0 then
        local ll_1 = (LocalPlayer:GetAttribute("CarryTier"))
        local lr = if ll_1 then 1 else 0
        local lp = 609 * lr + 768 * (1 - lr)
        local lq = 1683 * lr + 1513 * (1 - lr)
        if not ((lp * 2292 + lq * 1535 + lp * lq) % 16777213 == 5004180) then
            ll_1 = 0
        end
        local ln_1 = ll_1
        if ln_1 > 0 and ln_1 + 1 <= lk then
            for i, child in ipairs(lj:GetChildren()) do
                local lx = child
                local ll_3 = lx:GetAttribute("Tier") == ln_1 and not lx:GetAttribute("Carried") and lx:GetAttribute("Id") ~= ll
                if ll_3 then
                    pcall(function()
                        TryMerge:FireServer(lx)
                    end)
                    return
                end
            end
        end
        li = i2()
        pcall(function()
            local lg = li and li.Position or nil
            DropEvent:FireServer(lg, LocalPlayer:GetAttribute("CarryTier"))
        end)
        return
    end
    local ll_4 = {}
    for i, child in ipairs(lj:GetChildren()) do
        local attr = child:GetAttribute("Tier")
        local ln_2 = attr and not child:GetAttribute("Carried")
        if ln_2 then
            local ln_3 = ll_4[attr] or 0
            ll_4[attr] = ln_3 + 1
        end
    end
    local lm_2 = lk - 1
    local lG = 1
    while lG <= lm_2 do
        local lH = lG
        if (ll_4[lH] or 0) >= 2 then
            for i, child in ipairs(lj:GetChildren()) do
                local lk_2 = child:GetAttribute("Tier") == lH and not child:GetAttribute("Carried")
                if lk_2 then
                    iK(child)
                    return
                end
            end
        end
        lG += 1
    end
end
iv = fn39
iB = function()
    local lV
    local Value = Options.LaunchTarget.Value
    if not Value or Value == "" then
        return
    end
    local lX_1 = Players2:FindFirstChild(Value)
    if not lX_1 then
        return
    end
    local lW_1 = LocalPlayer:GetAttribute("CarryId") or 0
    if lW_1 == 0 then
        local lW_2 = jj()
        if not lW_2 then
            return
        end
        for i, child in ipairs(lW_2:GetChildren()) do
            local lW_3 = child:GetAttribute("Tier") and not child:GetAttribute("Carried")
            if lW_3 then
                iK(child)
                return
            end
        end
        return
    end
    lV = iv(lX_1)
    if not lV then
        return
    end
    pcall(function()
        Launch:InvokeServer(lV)
    end)
end
task.spawn(autoMergeLoop)
task.spawn(autoLaunchLoop)
task.spawn(autoRebirthLoop)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoUpgrades and Toggles.AutoUpgrades.Value then
            for k, v in pairs(Options.UpgradeKinds.Value) do
                if v then
                    local mf = i5[k]
                    if mf then
                        pcall(function()
                            Upgrade:InvokeServer(mf)
                        end)
                    end
                end
            end
        end
        task.wait(0.75)
    end
end)
task.spawn(autoLockBaseLoop)
i7 = fn47
iP = fn23
ix = function(dU)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not dU)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not dU
        end
    end)
    if not dU then
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
iV = fn429
local function jn_2()
    local MovementGroup = iR.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = iR.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local CurrentCamera = workspace.CurrentCamera
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local mK_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if mK_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local mS_1 = i7()
            if mS_1 then
                mS_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    RunService.RenderStepped:Connect(function(eq)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local mU_1 = i7()
            if mU_1 then
                mU_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local mU_3 = iP()
            local mV = i7()
            if mU_3 and mV then
                mV.PlatformStand = true
                local mV_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    mV_1 = mV_1 + CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    mV_1 = mV_1 - CurrentCamera.CFrame.LookVector
                end
                local m2 = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                if m2 == 1 then
                    mV_1 = mV_1 - CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    mV_1 = mV_1 + CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    mV_1 = mV_1 + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    mV_1 = mV_1 - Vector3.new(0, 1, 0)
                end
                mU_3.Velocity = Vector3.zero
                if mV_1.Magnitude > 0 then
                    mU_3.CFrame = mU_3.CFrame + mV_1.Unit * Options.FlySpeed.Value * eq
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local m6 = i7()
            if m6 then
                m6.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local m8 = i7()
            if m8 then
                m8.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        ix(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                ix(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(workspace:GetDescendants()) do
                pcall(iV, descendant)
            end
            connection = workspace.DescendantAdded:Connect(function(eZ)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(iV, eZ)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
end
jn_2()
iM = 0
iI = tick()
local function jm_1()
    local MenuGroup = iR.Settings:AddLeftGroupbox("Menu", "menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function fa()
        if not workspace.CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        iM = iM + 1
        iI = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. iM)
        end)
    end
    connection2 = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(fa)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local ns = Toggles.AntiAfk.Value and tick() - iI >= 60
            if ns then
                pcall(fa)
            end
        end
    end)
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
end
jm_1()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(iR.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/MergeASquishy")
jf = SaveManager:BuildConfigSection(iR.Settings)
local function ju()
    local function fy(fz, fA)
        local nv_1 = (fz == "Toggle" and Toggles or Options)[fA]
        local nu_2 = type(nv_1) == "table" and nv_1.Type == fz
        return nu_2 and nv_1 or nil
    end
    local function fI(fJ, fK)
        local Type = fK.Type
        if Type == "Toggle" then
            return { idx = fJ, type = "Toggle", value = fK.Value == true }
        elseif Type == "Slider" then
            return { idx = fJ, type = "Slider", value = tostring(fK.Value) }
        elseif Type == "Dropdown" then
            return { idx = fJ, type = "Dropdown", multi = fK.Multi == true, value = fK.Value }
        elseif Type == "Input" then
            local nz = fK.Value
            local nD = if nz then 1 else 0
            local nB = 366 * nD + 2859 * (1 - nD)
            local nC = 100 * nD + 205 * (1 - nD)
            if not ((nB * 976 + nC * 1953 + nB * nC) % 16777213 == 589116) then
                nz = ""
            end
            return { idx = fJ, type = "Input", text = tostring(nz) }
        elseif Type == "ColorPicker" then
            return { idx = fJ, type = "ColorPicker", value = fK.Value:ToHex(), transparency = fK.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = fJ,
                type = "KeyPicker",
                mode = fK.Mode,
                key = fK.Value,
                modifiers = fK.Modifiers,
                toggled = fK.Toggled
            }
        else
            return nil
        end
    end
    local function fM()
        local nF = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local nG = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if nG then
                    local nG_1 = fI(k, v)
                    if nG_1 then
                        nF[#nF + 1] = nG_1
                    end
                end
            end
        end
        table.sort(nF, function(fW, fX)
            if fW.type ~= fX.type then
                return fW.type < fX.type
            end
            return fW.idx < fX.idx
        end)
        return { objects = nF }
    end
    local function fY(fZ)
        local nW
        nW = nil
        local nX = type(fZ) ~= "table" or type(fZ.idx) ~= "string" or type(fZ.type) ~= "string" or SaveManager.Ignore[fZ.idx]
        if nX then
            return false
        end
        nW = fy(fZ.type, fZ.idx)
        if not nW then
            return false
        end
        local nX_1 = pcall(function()
            if fZ.type == "Input" then
                if type(fZ.text) ~= "string" then
                    return
                end
                nW:SetValue(fZ.text)
            elseif fZ.type == "ColorPicker" then
                nW:SetValueRGB(Color3.fromHex(fZ.value), fZ.transparency)
            elseif fZ.type == "KeyPicker" then
                nW:SetValue({ fZ.key, fZ.mode, fZ.modifiers })
                if fZ.mode == "Toggle" and fZ.toggled ~= nil then
                    nW.Toggled = fZ.toggled
                    nW:Update()
                end
            else
                nW:SetValue(fZ.value)
            end
        end)
        return nX_1
    end
    jf:AddDivider()
    jf:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    jf:AddButton("Export Config to Clipboard", function()
        local n__1
        local nZ_1
        nZ_1, n__1 = pcall(HttpService.JSONEncode, HttpService, fM())
        if not nZ_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local nZ_2 = setclipboard
        local n4 = if nZ_2 then 1 else 0
        local n2 = 2177 * n4 + 951 * (1 - n4)
        local n3 = 1752 * n4 + 1945 * (1 - n4)
        if not ((n2 * 218 + n3 * 3641 + n2 * n3) % 16777213 == 10667722) then
            nZ_2 = toclipboard
        end
        local n0 = nZ_2
        local nZ_3 = type(n0) ~= "function"
        local n7 = if nZ_3 then 1 else 0
        local n5 = 3857 * n7 + 973 * (1 - n7)
        local n6 = 2662 * n7 + 252 * (1 - n7)
        if not ((n5 * 110 + n6 * 2445 + n5 * n6) % 16777213 == 422981) then
            nZ_3 = not pcall(n0, n__1)
        end
        if nZ_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    jf:AddButton("Import Config from Clipboard Text", function()
        local oa_1
        local n8 = Options.SaveManager_ImportSource.Value or ""
        local n8_1
        local n9 = tostring(n8):match("^%s*(.-)%s*$")
        if n9 == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        n8_1, oa_1 = pcall(HttpService.JSONDecode, HttpService, n9)
        local n9_1 = not n8_1 or type(oa_1) ~= "table" or type(oa_1.objects) ~= "table"
        if n9_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local n8_2 = 0
        for i, v in ipairs(oa_1.objects) do
            if fY(v) then
                n8_2 += 1
            end
        end
        if n8_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local oa_2 = n8_2 == 1 and ""
        local ol = if oa_2 then 1 else 0
        local oi = 1600 * ol + 1157 * (1 - ol)
        local oj = 1513 * ol + 3525 * (1 - ol)
        if not ((oi * 1983 + oj * 1639 + oi * oj) % 16777213 == 8073407) then
            oa_2 = "s"
        end
        Library:Notify(("Imported %d setting%s"):format(n8_2, oa_2), 6)
    end)
end
ju()
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn48)
Library:Notify("Tempo Hub loaded for Merge a Squishy")
end)(...)
