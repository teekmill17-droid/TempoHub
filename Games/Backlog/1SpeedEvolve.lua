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
getgenv().TempoHoodSubtitle = "+1 SPEED EVOLVE"
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
local ug_2, ug_22, ScriptsGroup, ug_32, ug_35
local mS
local nz
local mz
local ng
local nY
local mY
local VirtualUser
local Label
local nm
local TrailRemoteEvent
local m3
local nL
local TrailData
local ns
local ms
local m9
local nR
local UpgradesData
local my
local nf
local nX
local Toggles
local nE
local mE
local nl
local ml
local m2
local nK
local mK
local nr
local WinsData
local m8
local nQ
local mQ
local nx
local mx
local connection2
local CurrentCamera2
local mW
local nD
local mD
local nk
local AuraRemoteEvent
local SaveManager
local RebirthRemoteEvent
local mJ
local Workspace
local mq
local m7
local EvolutionRemoteEvent
local mP
local connection
local mw
local nd
local nV
local TreadmillData
local nC
local mC
local nj
local Helper
local UserInputService
local mI
local np
local mp
local m6
local nO
local mO
local mv
local nc
local nU
local mU
local HttpService
local mB
local ni
local m_
local WorldsRemoteEvent
local mH
local no
local mo
local m5
local nN
local mN
local nu
local mu
local nb
local nT
local Options
local nA
local mA
local nh
local mZ
local nG
local ItemData
local LocalPlayer
local mn
local nM
local mM
local nt
local mt
local Library
local ItemRemoteEvent
function fns.onCopySolanaAddress()
    mM(mY, "Copied Solana address")
end
function fns.fn58()
    local sp_1
    local so_1
    if identifyexecutor then
        sp_1, so_1 = identifyexecutor()
        local sq = sp_1 ~= ""
        local sr = type(sp_1) == "string" and sq
        if sr then
            local sq_1 = type(so_1) == "string" and so_1 ~= "" and sp_1 .. " " .. so_1
            m8 = sq_1 or sp_1
        end
    end
end
function fns.fn67()
    local oW = nA()
    local oX = oW and oW:FindFirstChildOfClass("Humanoid")
    return oX
end
function fns.onCopyBitcoinAddress()
    mM(nb, "Copied Bitcoin address")
end
function fns.fn85()
    local sd = nQ()
    local se = nt()
    local sf
    for i, v in ipairs(mq()) do
        if sd >= v.RebirthsRequired and se >= v.UpgradeRequired then
            if v.PlaceId ~= game.PlaceId then
                sf = v
            end
        end
    end
    if sf then
        WorldsRemoteEvent:FireServer(sf.Name)
    end
end
function fns.onCopyPayPalLink()
    mM(mU, "Copied PayPal link")
end
function fns.fn103()
    local rF_1
    local rE_1
    local rD = nN(mK)
    rF_1, rE_1 = nk(rD, mp(), no)
    if not rF_1 then
        return
    end
    if not rE_1 then
        AuraRemoteEvent:FireServer({ Action = "Buy", AuraName = rF_1.Name })
        return
    end
    if nY() ~= rF_1.Name then
        AuraRemoteEvent:FireServer({ Action = "Equip", AuraName = rF_1.Name })
    end
end
function fns.fn145()
    local rO = Options.ItemShopItems and Options.ItemShopItems.Value
    if type(rO) ~= "table" then
        return
    end
    local rO_1 = mp()
    for k, v in pairs(rO) do
        local rP_1 = v and ItemData[k] and not m5(k)
        if rP_1 then
            local rP_2 = tonumber(ItemData[k].WinsCost) or 0
            if rO_1 >= rP_2 then
                ItemRemoteEvent:FireServer({ Action = "Buy", ItemName = k })
            end
        end
    end
end
function fns.fn146(bV)
    local pr = mz("AurasOwned", bV) or nc(bV .. " Aura") or nc(bV)
    return pr
end
function fns.fn171(dK)
    local qS = nj()
    local Order = mA.Order
    if type(Order) == "table" then
        local qX = 1
        while qX <= qS do
            if Order[qX] == dK then
                return true
            end
            qX += 1
        end
    end
    if nc(dK) then
        return true
    end
    local DailyLoginEvolutions = LocalPlayer:FindFirstChild("DailyLoginEvolutions")
    local qT_1 = DailyLoginEvolutions and DailyLoginEvolutions:FindFirstChild(dK)
    if qT_1 then
        return true
    end
    return false
end
function fns.onRscripts()
    mM(nd, "Copied Rscripts profile to clipboard")
end
function fns.worker3()
    while not Library.Unloaded do
        task.wait(1.25)
        if nU("AutoBuySpeedUpgrade") then
            pcall(mD)
        end
        if nU("AutoBuyBestTrail") then
            pcall(mn)
        end
        if nU("AutoBuyBestAura") then
            pcall(nl)
        end
        if nU("AutoBuyItemShop") then
            pcall(ni)
        end
        if nU("AutoUseItems") then
            pcall(mo)
        end
    end
end
function fns.onExportConfigToClipboard()
    local tW_1
    local tV_1
    tV_1, tW_1 = pcall(HttpService.JSONEncode, HttpService, nR())
    if not tV_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local tV_2 = setclipboard or toclipboard
    local tV_3 = type(tV_2) ~= "function" or not pcall(tV_2, tW_1)
    if tV_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.fn205(ix, iy)
    local Type = iy.Type
    if Type == "Toggle" then
        return { idx = ix, type = "Toggle", value = iy.Value == true }
    elseif Type == "Slider" then
        return { idx = ix, type = "Slider", value = tostring(iy.Value) }
    elseif Type == "Dropdown" then
        return { idx = ix, type = "Dropdown", multi = iy.Multi == true, value = iy.Value }
    elseif Type == "Input" then
        local ts = iy.Value or ""
        return { idx = ix, type = "Input", text = tostring(ts) }
    elseif Type == "ColorPicker" then
        return { idx = ix, type = "ColorPicker", value = iy.Value:ToHex(), transparency = iy.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = ix,
            type = "KeyPicker",
            mode = iy.Mode,
            key = iy.Value,
            modifiers = iy.Modifiers,
            toggled = iy.Toggled
        }
    else
        return nil
    end
end
function fns.fn207(gF)
    local DiscordGroup = gF:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mv })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mv })
end
function fns.fn215()
    local r1 = m7()
    if r1 == "" then
        return
    end
    local r2 = mA.GetNextEvolution(r1)
    local r1_1 = r2 == ""
    local r3 = type(r2) ~= "string" or r1_1
    if r3 then
        return
    end
    local r1_2 = mA.Evolutions[r2]
    if type(r1_2) ~= "table" then
        return
    end
    local r2_1 = tonumber(r1_2.WinsCost) or 0
    local r2_2 = tonumber(r1_2.Level) or 0
    local r2_3 = mp() >= r2_1 and nE() >= r2_2
    if r2_3 then
        EvolutionRemoteEvent:FireServer({ Action = "Evolve" })
    end
end
function fns.fn220()
    local rB_1
    local rA_1
    local rz = nN(TrailData)
    rB_1, rA_1 = nk(rz, mp(), nG)
    if not rB_1 then
        return
    end
    if not rA_1 then
        TrailRemoteEvent:FireServer({ Action = "Buy", TrailName = rB_1.Name })
        return
    end
    if mJ() ~= rB_1.Name then
        TrailRemoteEvent:FireServer({ Action = "Equip", TrailName = rB_1.Name })
    end
end
function fns.onInputChanged(g3)
    local UserInputType = g3.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        mH = tick()
    end
end
function fns.fn237(dz, dA, dB)
    local qH
    local qI
    for i, v in ipairs(dz) do
        if dB(v.Name) then
            qH = v
        elseif dA >= v.Cost then
            qI = v
        end
    end
    if qI and (not qH or qI.Multiplier > qH.Multiplier) then
        return qI, false
    end
    return qH, true
end
function fns.onCopyLitecoinAddress()
    mM(nf, "Copied Litecoin address")
end
function fns.fn246()
    if not Toggles.Fly.Value then
        local tg = ns()
        if tg then
            tg.PlatformStand = false
        end
    end
end
function fns.fn259()
    local ty = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local tz = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if tz then
                local tz_1 = ms(k, v)
                if tz_1 then
                    ty[#ty + 1] = tz_1
                end
            end
        end
    end
    table.sort(ty, function(iI, iJ)
        if iI.type ~= iJ.type then
            return iI.type < iJ.type
        end
        return iI.idx < iJ.idx
    end)
    return { objects = ty }
end
function fns.fn277(cR)
    local p4 = nD()
    if #p4 == 0 then
        return nil
    elseif cR == "Worst" then
        table.sort(p4, function(cW, cX)
            if cW.Reward == cX.Reward then
                return cW.Stage < cX.Stage
            end
            return cW.Reward < cX.Reward
        end)
        return p4[1]
    elseif cR == "Nearest" then
        table.sort(p4, function(cU, cV)
            return cU.Distance < cV.Distance
        end)
        return p4[1]
    elseif cR == "Random" then
        return p4[math.random(1, #p4)]
    else
        table.sort(p4, function(cY, cZ)
            if cY.Reward == cZ.Reward then
                return cY.Stage > cZ.Stage
            end
            return cY.Reward > cZ.Reward
        end)
        return p4[1]
    end
end
function fns.worker()
    local su_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local st = math.floor(os.clock() - nO)
        if st < 60 then
            su_1 = st .. "s"
        elseif st < 3600 then
            su_1 = string.format("%dm %ds", math.floor((st) / (60)), st % 60)
        else
            su_1 = string.format("%dh %dm", math.floor((st) / (3600)), math.floor((st % 3600) / (60)))
        end
        Label:SetText(nL("Session time", su_1, nm))
    end
end
function fns.fn306()
    local rv = m3()
    if not rv then
        return
    end
    if nx() then
        local rw = ng()
        if rw and (rw.Position - rv.Position).Magnitude > 12 then
            nK(rv)
        end
        return
    end
    nK(rv)
end
function fns.fn335()
    local q_
    local q0 = -1
    local Evolutions = mA.Evolutions
    if type(Evolutions) ~= "table" then
        return nil
    end
    for k, v in pairs(Evolutions) do
        local q1_1 = type(v) == "table" and v.SpeedMultiplier and mx(k)
        if q1_1 then
            local q1_2 = tonumber(v.SpeedMultiplier) or 0
            if q1_2 > q0 then
                q0 = q1_2
                q_ = k
            end
        end
    end
    return q_, q0
end
function fns.fn338(b2)
    local pt = ng()
    local pu = not b2
    local pv = not pt
    local pz = if pv then 1 else 0
    local px = 3711 * pz + 3798 * (1 - pz)
    local py = 2084 * pz + 1797 * (1 - pz)
    if not ((px * 234 + py * 231 + px * py) % 16777213 == 9083502) then
        pv = pu
    end
    if pv then
        return false
    elseif typeof(b2) == "Instance" then
        if b2:IsA("Model") then
            b2 = b2:GetPivot().Position
            pt.CFrame = CFrame.new(b2 + Vector3.new(0, 3, 0))
            return true
        elseif b2:IsA("BasePart") then
            b2 = b2.Position
            pt.CFrame = CFrame.new(b2 + Vector3.new(0, 3, 0))
            return true
        else
            return false
        end
    else
        pt.CFrame = CFrame.new(b2 + Vector3.new(0, 3, 0))
        return true
    end
end
function fns.fn361()
    ItemRemoteEvent:FireServer({ Action = "EquipBest" })
end
function fns.fn395()
    local r8 = nu()
    if not r8 then
        return
    end
    local sc = if m7() == r8 then 1 else 0
    if sc == 1 then
        return
    end
    EvolutionRemoteEvent:FireServer({ Action = "Select", EvolutionName = r8 })
end
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            mw(true)
        end
    end
end
function fns.fn411()
    local rg = {}
    for k, v in pairs(mt) do
        local rh = type(v) == "table" and v.PlaceId
        if rh then
            local rh_1 = #rg + 1
            local ri = tonumber(v.PlaceId) or 0
            local rj = tonumber(v.RebirthsRequired) or 0
            local rk = tonumber(v.UpgradeRequired) or 0
            rg[rh_1] = { Name = k, PlaceId = ri, RebirthsRequired = rj, UpgradeRequired = rk }
        end
    end
    table.sort(rg, function(ef, eg)
        return ef.RebirthsRequired < eg.RebirthsRequired
    end)
    return rg
end
function fns.fn440()
    local pQ = {}
    local pR = ng()
    local pS = pR and pR.Position
    for k, v in pairs(nC) do
        local pS_1 = nr(k)
        local pT = #pQ + 1
        local pV = pS and (pS - v).Magnitude or math.huge
        pQ[pT] = { Stage = k, Position = v, Reward = pS_1, Distance = pV }
    end
    return pQ
end
function fns.fn441()
    local rt = Options.AutoWinMode and Options.AutoWinMode.Value or "Best"
    local rt_1 = mO(rt)
    if not rt_1 then
        return
    end
    local rs_2 = mu(rt_1.Stage)
    if rs_2 then
        nK(rs_2)
        return
    end
    mS(rt_1.Position)
end
function fns.fn446()
    return mI(mP(), "Wins")
end
function fns.fn464(dq)
    local qs = {}
    for k, v in pairs(dq) do
        local qt = type(v) == "table" and v.SpeedMultiplier
        if qt then
            local qt_1 = #qs + 1
            local qu = tonumber(v.SpeedMultiplier) or 0
            local qv = (tonumber(v.WinsCost))
            local qG = if qv then 1 else 0
            local qE = 2888 * qG + 3744 * (1 - qG)
            local qF = 1698 * qG + 3021 * (1 - qG)
            if not ((qE * 3075 + qF * 405 + qE * qF) % 16777213 == 14472114) then
                qv = 0
            end
            local qw = tonumber(v.LayoutOrder) or 0
            qs[qt_1] = { Name = k, Multiplier = qu, Cost = qv, Order = qw }
        end
    end
    table.sort(qs, function(dw, dx)
        if dw.Multiplier == dx.Multiplier then
            return dw.Order < dx.Order
        end
        return dw.Multiplier < dx.Multiplier
    end)
    return qs
end
function fns.fn479(b_)
    return mz("ItemsOwned", b_)
end
function fns.fn483()
    return LocalPlayer:FindFirstChild("PlayerStats")
end
function fns.fn488(ip, iq)
    local to_1 = (ip == "Toggle" and Toggles or Options)[iq]
    local tn_2 = type(to_1) == "table" and to_1.Type == ip
    return tn_2 and to_1 or nil
end
function fns.fn499()
    local pa = mZ()
    local pb = pa and pa:FindFirstChild("AuraEquipped")
    local pa_1 = pb
    if pb then
        pb = tostring(pa_1.Value)
    end
    return pb or "None"
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local sU_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if sU_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn525(cd)
    local pC = ng()
    local pD = not pC or not cd or not cd:IsA("BasePart")
    if pD then
        return false
    end
    pC.CFrame = cd.CFrame + Vector3.new(0, 3, 0)
    if firetouchinterest then
        pcall(firetouchinterest, pC, cd, 0)
        task.wait()
        pcall(firetouchinterest, pC, cd, 1)
    end
    return true
end
function fns.onImportConfigFromClipboardTex()
    local t0_1
    local tZ = Options.SaveManager_ImportSource.Value or ""
    local tZ_1
    local t_ = tostring(tZ):match("^%s*(.-)%s*$")
    if t_ == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    tZ_1, t0_1 = pcall(HttpService.JSONDecode, HttpService, t_)
    local t__1 = not tZ_1 or type(t0_1) ~= "table" or type(t0_1.objects) ~= "table"
    if t__1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local tZ_2 = 0
    for i, v in ipairs(t0_1.objects) do
        local ua = if m_(v) then 1 else 0
        if ua == 1 then
            tZ_2 += 1
        end
    end
    if tZ_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local t0_2 = tZ_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(tZ_2, t0_2), 6)
end
function fns.onCopyVenmoLink()
    mM(mN, "Copied Venmo link")
end
function fns.fn533()
    local rK = mQ()
    if not rK then
        return
    end
    local rL = UpgradesData[rK] or UpgradesData[tostring(rK)]
    if not rL then
        return
    end
    local rL_1 = tonumber(rL.Cost) or 0
    if mp() < rL_1 then
        return
    end
    local UpgradeButtons = Workspace:FindFirstChild("UpgradeButtons")
    local rM_2 = UpgradeButtons and UpgradeButtons:FindFirstChild(tostring(rK))
    local rL_3 = rM_2 and rM_2:FindFirstChild("Touch")
    if rL_3 then
        nK(rL_3)
    end
end
local function fn549(ci)
    local pF = WinsData[ci]
    local pK = if pF then 1 else 0
    local pI = 2025 * pK + 2392 * (1 - pK)
    local pJ = 1812 * pK + 1256 * (1 - pK)
    if not ((pI * 1574 + pJ * 3747 + pI * pJ) % 16777213 == 13646214) then
        pF = WinsData[tostring(ci)]
    end
    local pG = pF
    local pF_1 = tonumber(pG) or 0
    return pF_1
end
local function fn557()
    local oZ = nA()
    local o_ = oZ and oZ:FindFirstChild("HumanoidRootPart")
    return o_
end
local function fn560()
    local o4 = mZ()
    local o5 = o4 and o4:FindFirstChild("EvolutionSelected")
    local o4_1 = o5
    if o5 then
        o5 = tostring(o4_1.Value)
    end
    return o5 or ""
end
local function fn598(c0, c1, c2)
    if type(c1) ~= "table" then
        return false
    end
    local Treadmills = Workspace:FindFirstChild("Treadmills")
    local p7 = Treadmills and Treadmills:FindFirstChild(c0)
    local p7_1 = not p7 or not p7:FindFirstChild("TouchPart")
    if p7_1 then
        return false
    end
    local p6_2 = tonumber(c1.RebirthsRequired) or 0
    if c2 < p6_2 then
        return false
    end
    local p6_3 = c1.GamepassName and not nc(c1.GamepassName)
    if p6_3 then
        return false
    end
    return true
end
local function fn601(cn)
    local Wins = Workspace:FindFirstChild("Wins")
    local pM = Wins and Wins:FindFirstChild(tostring(cn))
    local pL_1 = pM
    if pM then
        pM = pL_1:FindFirstChild("Touch")
    end
    local pL_2 = pM
    if pM then
        pM = pL_2:IsA("BasePart")
    end
    if pM then
        return pL_2
    end
    return nil
end
local function fn612()
    return mI(mZ(), "Level")
end
local function fn617(ad, ae, af)
    return string.format("<b>%s</b> %s %s", ad, ml("-", "#5a6070"), ml(ae, af))
end
local function onCopyJoinScript_JobID()
    local f8 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, my)
    mM(f8, "Copied join script to clipboard")
end
local function fn643()
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    mw(false)
    local ub = ns()
    if ub then
        ub.PlatformStand = false
        ub.WalkSpeed = 16
    end
end
local function worker2()
    while not Library.Unloaded do
        task.wait(0.75)
        if nU("AutoWin") then
            pcall(nz)
        elseif nU("AutoTrain") then
            pcall(mW)
        end
    end
end
local function fn658()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    mC = tick()
end
local function onInputBegan()
    mH = tick()
end
local function fn668()
    local rY = nQ()
    local rZ = Helper.GetRebirthLevelRequired(rY)
    local rY_1 = nE()
    local r_ = tonumber(rZ) or math.huge
    if rY_1 >= r_ then
        RebirthRemoteEvent:FireServer()
    end
end
local function fn676(bI, bJ)
    local pm = LocalPlayer:FindFirstChild(bI)
    if not pm then
        return false
    end
    local pn = pm:FindFirstChild(bJ)
    if not pn then
        return false
    elseif pn:IsA("BoolValue") then
        return pn.Value == true
    else
        local Owned = pn:FindFirstChild("Owned")
        local pn_1 = Owned and Owned:IsA("BoolValue")
        if pn_1 then
            return Owned.Value == true
        end
        return true
    end
end
local function fn697(aA)
    local oT = Toggles[aA]
    return oT ~= nil and oT.Value == true
end
local function fn702()
    local o7 = mZ()
    local o8 = o7 and o7:FindFirstChild("TrailEquipped")
    local o7_1 = o8
    if o8 then
        o8 = tostring(o7_1.Value)
    end
    return o8 or "None"
end
local function fn714(K, L)
    return (ItemData[K].LayoutOrder or 0) < (ItemData[L].LayoutOrder or 0)
end
local function fn725(T, U)
    if setclipboard then
        setclipboard(T)
    elseif toclipboard then
        toclipboard(T)
    end
    Library:Notify(U)
end
local function fn727()
    if not Toggles.WalkSpeedEnabled.Value then
        local ti = ns()
        if ti then
            ti.WalkSpeed = 16
        end
    end
end
local function fn733()
    local pd = mZ()
    local pe = pd and pd:FindFirstChild("OnTreadmill")
    local pd_1 = pe
    if pe then
        pe = pd_1.Value == true
    end
    return pe
end
local function onUnload()
    Library:Unload()
end
local function fn751(cw)
    local pO = m9(cw)
    if pO then
        return pO
    end
    local pO_1 = nC[cw]
    if not pO_1 then
        return nil
    end
    mB(pO_1, 8)
    mS(pO_1)
    task.wait(0.35)
    return m9(cw)
end
local function fn759()
    return mI(mZ(), "EvolutionProgress")
end
local function fn773()
    return mI(mZ(), "UpgradesOwned")
end
local function onCopyUSDTAddress()
    mM(m2, "Copied USDT address")
end
local function fn810()
    return mI(mP(), "Rebirths")
end
local function fn813()
    return LocalPlayer.Character
end
local function fn814(bz)
    local Gamepasses = LocalPlayer:FindFirstChild("Gamepasses")
    local ph = Gamepasses and Gamepasses:FindFirstChild(bz)
    local pg_1 = ph
    if ph then
        ph = pg_1:FindFirstChild("Owned")
    end
    local pg_2 = ph
    if ph then
        ph = pg_2.Value == true
    end
    return ph
end
local function fn827()
    return LocalPlayer:FindFirstChild("leaderstats")
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local sI = tick() - mH
            local sJ = tick() - mC
            if sI >= 300 and sJ >= 60 then
                pcall(nT)
            else
                if sI < 300 and sJ >= 300 then
                    pcall(nT)
                end
            end
        end
    end
end
local function fn872(aa, ab)
    return string.format('<font color="%s">%s</font>', ab, aa)
end
local function fn874()
    local rd = nt()
    local re = rd + 1
    local rd_1 = UpgradesData[re] or UpgradesData[tostring(re)]
    if rd_1 then
        return re
    end
    return nil
end
local function onRenderStepped(hL)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local s6_1 = ns()
        if s6_1 then
            s6_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local s6_3 = ng()
        local s7 = ns()
        if s6_3 and s7 then
            s7.PlatformStand = true
            local s7_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                s7_1 = s7_1 + CurrentCamera2.CFrame.LookVector
            end
            local tc = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if tc == 1 then
                s7_1 = s7_1 - CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                s7_1 = s7_1 - CurrentCamera2.CFrame.RightVector
            end
            local tc_1 = if UserInputService:IsKeyDown(Enum.KeyCode.D) then 1 else 0
            if tc_1 == 1 then
                s7_1 = s7_1 + CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                s7_1 = s7_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                s7_1 = s7_1 - Vector3.new(0, 1, 0)
            end
            s6_3.AssemblyLinearVelocity = Vector3.zero
            if s7_1.Magnitude > 0 then
                s6_3.CFrame = s6_3.CFrame + s7_1.Unit * Options.FlySpeed.Value * hL
            end
        end
    end
end
local function fn880()
    mw(Toggles.AntiGameplayPause.Value)
end
local function worker4()
    while not Library.Unloaded do
        task.wait(2)
        if nU("AutoRebirth") then
            pcall(nV)
        end
        if nU("AutoEvolve") then
            pcall(np)
        end
        if nU("AutoSelectBestCreature") then
            pcall(mE)
        end
        if nU("AutoBuyWorlds") then
            pcall(nX)
        end
    end
end
local function fn897(aT, aU)
    if not aT then
        return 0
    end
    local o1 = aT:FindFirstChild(aU)
    if not o1 then
        return 0
    end
    local o2 = tonumber(o1.Value) or 0
    return o2
end
local function fn902()
    local qc = nQ()
    local qd
    local qe = -1
    for k, v in pairs(TreadmillData) do
        if nM(k, v, qc) then
            local qf_1 = tonumber(v.Multiplier) or 0
            if qf_1 > qe then
                qe = qf_1
                qd = k
            end
        end
    end
    if not qd then
        return nil
    end
    local qc_1 = Workspace.Treadmills:FindFirstChild(qd)
    local qf_2 = qc_1 and qc_1:FindFirstChild("TouchPart")
    return qf_2, qd, qe
end
local function fn947()
    mM(nh, "Copied Discord invite to clipboard")
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local s4_1 = ns()
        if s4_1 then
            s4_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn960(bQ)
    local pp = mz("TrailsOwned", bQ) or nc(bQ .. " Trail") or nc(bQ)
    return pp
end
local function onCopyEthereumAddress()
    mM(m6, "Copied Ethereum address")
end
AuraRemoteEvent = nil
ml = nil
TrailRemoteEvent = nil
mn = nil
mo = nil
mp = nil
mq = nil
WinsData = nil
ms = nil
mt = nil
mu = nil
mv = nil
mw = nil
mx = nil
my = nil
mz = nil
mA = nil
mB = nil
mC = nil
mD = nil
mE = nil
Label = nil
ItemData = nil
mH = nil
mI = nil
mJ = nil
mK = nil
TrailData = nil
mM = nil
mN = nil
mO = nil
mP = nil
mQ = nil
UpgradesData = nil
mS = nil
Options = nil
mU = nil
TreadmillData = nil
mW = nil
Toggles = nil
mY = nil
mZ = nil
m_ = nil
Helper = nil
SaveManager = nil
m2 = nil
m3 = nil
m5 = nil
m6 = nil
local m4
m7 = nil
m8 = nil
m9 = nil
Library = nil
nb = nil
nc = nil
nd = nil
connection2 = nil
nf = nil
ng = nil
nh = nil
ni = nil
nj = nil
nk = nil
nl = nil
nm = nil
LocalPlayer = nil
no = nil
np = nil
Workspace = nil
nr = nil
ns = nil
nt = nil
nu = nil
connection = nil
nx = nil
nz = nil
nA = nil
HttpService = nil
nC = nil
nD = nil
nE = nil
VirtualUser = nil
nG = nil
WorldsRemoteEvent = nil
UserInputService = nil
RebirthRemoteEvent = nil
nK = nil
nL = nil
nM = nil
nN = nil
nO = nil
EvolutionRemoteEvent = nil
nQ = nil
nR = nil
ItemRemoteEvent = nil
nT = nil
nU = nil
local CoreGui, GuiService
nV = nil
CurrentCamera2 = nil
nX = nil
nY = nil
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, nh, nd, Helper, TreadmillData, UpgradesData, TrailData, mK, ItemData, mA, mt, WinsData, TrailRemoteEvent, AuraRemoteEvent, ItemRemoteEvent, EvolutionRemoteEvent, RebirthRemoteEvent, WorldsRemoteEvent, nC, ug_32 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ug_27 = game:GetService("Players")
local ug_17 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = ug_27.LocalPlayer
local ug_6 = "+1 Speed Evolve"
nh = "https://discord.gg/K7Qxnxkk46"
nd = "https://discord.gg/K7Qxnxkk46"
local ug_30 = ug_17:WaitForChild("Modules"):WaitForChild("Shared")
local ug_4 = ug_30:WaitForChild("RemoteEventService")
Helper = require(ug_30:WaitForChild("Helper"))
TreadmillData = require(ug_30:WaitForChild("TreadmillData"))
UpgradesData = require(ug_30:WaitForChild("UpgradesData"))
TrailData = require(ug_30:WaitForChild("TrailData"))
if (not ug_32 and not ug_32 and (not TrailData and ug_32) or (TrailData or ItemRemoteEvent or (ItemRemoteEvent or ug_32))) and not (not ug_32 and not ug_32 and (not TrailData and ug_32) or (TrailData or ItemRemoteEvent or (ItemRemoteEvent or ug_32))) then
    ug_30 = require(ItemData:WaitForChild("AuraData"))
    mA = require(ItemData:WaitForChild("ItemData"))
    mt = require(ItemData:WaitForChild("EvolutionData"))
    mK = require(ItemData:WaitForChild("WorldsData"))
else
    mK = require(ug_30:WaitForChild("AuraData"))
    ItemData = require(ug_30:WaitForChild("ItemData"))
    mA = require(ug_30:WaitForChild("EvolutionData"))
    mt = require(ug_30:WaitForChild("WorldsData"))
end
WinsData = require(ug_30:WaitForChild("WinsData"))
TrailRemoteEvent = ug_4:WaitForChild("TrailRemoteEvent")
AuraRemoteEvent = ug_4:WaitForChild("AuraRemoteEvent")
ItemRemoteEvent = ug_4:WaitForChild("ItemRemoteEvent")
EvolutionRemoteEvent = ug_4:WaitForChild("EvolutionRemoteEvent")
RebirthRemoteEvent = ug_4:WaitForChild("RebirthRemoteEvent")
WorldsRemoteEvent = ug_4:WaitForChild("WorldsRemoteEvent")
nC = {
    [1] = Vector3.new(425.99993896484, 10.5, 39.999996185303),
    [2] = Vector3.new(705.99993896484, 10.5, 39.999996185303),
    [3] = Vector3.new(1246, 92.5, 43.999996185303),
    [4] = Vector3.new(1846, 92.5, 37.999996185303),
    [5] = Vector3.new(2476, 92.5, 39.999996185303),
    [6] = Vector3.new(3334, 92.5, 39.999996185303),
    [7] = Vector3.new(4244, 92.500053405762, 40.000072479248),
    [8] = Vector3.new(4770, 92.5, 39.999996185303),
    [9] = Vector3.new(6210, 92.5, 39.999996185303),
    [10] = Vector3.new(7354, 92.5, 39.999996185303)
}
ug_32 = {}
for k in pairs(ItemData) do
    ug_27 = type(ItemData[k]) == "table" and ItemData[k].SpeedMultiplier
    if ug_27 then
        ug_32[#ug_32 + 1] = k
    end
end
table.sort(ug_32, fn714)
Library, SaveManager, Toggles, Options, ug_2, nm, nf, nb, m6, m2, mY, mU, mN, ug_17, m8, Label, my, mM, mv, ml, nL, nU, nA, ns, ng, mZ, mP, mI, mp, nQ, nE, nt, nj, m7, mJ, nY, nx, nc, mz, nG, no, m5, mS, mB, nK, nr, m9, mu, nD, mO, nM, m3, nN, nk, mx, nu, mQ, mq, nz, mW, mn, nl, mD, ni, mo, nV, np, mE, nX = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
mM = fn725
mv = fn947
ml = fn872
nL = fn617
local ug_26 = "#7fd47f"
if ((not nL or m3 or nE and not ug_17) and ((nL or not m3) and (not ug_17 or nE)) or nL and m3 and (ug_17 or m3) and ((nE or not nL) and (ug_17 or ug_17))) and (ug_17 and m3 and (not nL and ug_17) or (ug_17 or not ug_17) and (not nE and nE) or nE and nE and (not ug_17 or nE) and (nL and not m3 or (not nE or not nE))) or not (((not nL or m3 or nE and not ug_17) and ((nL or not m3) and (not ug_17 or nE)) or nL and m3 and (ug_17 or m3) and ((nE or not nL) and (ug_17 or ug_17))) and (ug_17 and m3 and (not nL and ug_17) or (ug_17 or not ug_17) and (not nE and nE) or nE and nE and (not ug_17 or nE) and (nL and not m3 or (not nE or not nE)))) then
    ug_2 = "#6ec1ff"
end
nm = "#e8a34d"
local ug_13 = "#8b93a3"
nf = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
nb = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
m6 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
m2 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
mY = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
mU = ""
mN = ""
local ug_25 = "#345d9d"
local ug_12 = "#f7931a"
local ug_24 = "#627eea"
local ug_36 = "#26a17b"
local ug_10 = "#14f195"
if (not mu or not nz) and (ns and not nz) and (mu and ns and (not nk and ns)) or not ns and mE and (nt and nt) and ((nk or not nt) and (nk and not mu)) or not ((not mu or not nz) and (ns and not nz) and (mu and ns and (not nk and ns)) or not ns and mE and (nt and nt) and ((nk or not nt) and (nk and not mu))) then
    ug_22 = "#0070ba"
    ug_35 = "#008cff"
    nU = fn697
else
    nU = "#0070ba"
    ug_22 = "#008cff"
    ug_35 = fn697
end
nA = fn813
ns = fns.fn67
ng = fn557
mZ = fns.fn483
mP = fn827
mI = fn897
mp = fns.fn446
nQ = fn810
nE = fn612
nt = fn773
nj = fn759
m7 = fn560
mJ = fn702
nY = fns.fn499
nx = fn733
nc = fn814
mz = fn676
nG = fn960
no = fns.fn146
m5 = fns.fn479
mS = fns.fn338
mB = function(b6, b7)
    pcall(function()
        local pA = b7 or 5
        LocalPlayer:RequestStreamAroundAsync(b6, pA)
    end)
end
nK = fns.fn525
nr = fn549
m9 = fn601
mu = fn751
nD = fns.fn440
mO = fns.fn277
nM = fn598
m3 = fn902
nN = fns.fn464
nk = fns.fn237
mx = fns.fn171
nu = fns.fn335
mQ = fn874
if (nM or not nj or (not mM or not mp) or (not ng and not ng or mp and nj) or (not mp or not nj) and (not mM and not mp) and (not mM or not nM or nM and nM)) and ((nM or not ng) and (not mp and not nM) and ((not nj or not mM) and (not nj and not nM)) or (mp and mp or not ng and nM or (nM or nM) and (nj or not nM))) and not ((nM or not nj or (not mM or not mp) or (not ng and not ng or mp and nj) or (not mp or not nj) and (not mM and not mp) and (not mM or not nM or nM and nM)) and ((nM or not ng) and (not mp and not nM) and ((not nj or not mM) and (not nj and not nM)) or (mp and mp or not ng and nM or (nM or nM) and (nj or not nM)))) then
    mW = fns.fn411
    mq = fns.fn441
    nz = fns.fn306
else
    mq = fns.fn411
    nz = fns.fn441
    mW = fns.fn306
end
mn = fns.fn220
nl = fns.fn103
mD = fns.fn533
ni = fns.fn145
mo = fns.fn361
nV = fn668
np = fns.fn215
mE = fns.fn395
nX = fns.fn85
ug_17 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = nh, Copyable = true }, "|", ug_6 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local ug_3 = {
    Info = ug_17:AddTab("Info", "info"),
    Main = ug_17:AddTab("Main", "gauge"),
    Player = ug_17:AddTab("Player", "person-standing"),
    Settings = ug_17:AddTab("Settings", "settings")
}
m8 = "Unknown"
pcall(fns.fn58)
local ug_15 = ug_3.Info:AddLeftGroupbox("Account", "circle-user")
ug_15:AddLabel(nL("User", LocalPlayer.Name, ug_26), true)
ug_15:AddLabel(nL("Status", "Keyless", ug_26), true)
ug_15:AddLabel(nL("Executor", m8, ug_26), true)
local GameInfoGroup = ug_3.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(ml(ug_6 .. " [" .. tostring(game.PlaceId) .. "]", ug_2), true)
GameInfoGroup:AddLabel(nL("Place ID", tostring(game.PlaceId), ug_2), true)
Label = GameInfoGroup:AddLabel(nL("Session time", "0s", nm), true)
my = tostring(game.JobId)
local ug_8 = #my > 18
if ug_8 then
    ug_27 = 5
    repeat
        ug_15 = (vector.create((ug_27 * 1 + 4) % 11 + 1, (ug_27 * 2 + 11) % 13 + 1, (ug_27 * 11 + 9) % 17 + 1))
        local uM = vector.floor(ug_15) + vector.ceil(ug_15 * -1)
        if vector.dot(uM, uM) == 0 then
            ug_8 = string.sub(my, 1, 18) .. "..."
        else
            my = string.sub(ug_8, 1, 18) .. "..."
        end
        ug_27 = (ug_27 + 3) % 8
    until (ug_27 * 7 + 3) % 8 == 3
end
ug_27 = ug_8 or my
nO, ScriptsGroup = nil, nil
ug_15 = ug_27
GameInfoGroup:AddLabel(nL("Server", ug_15, ug_13), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
nO = os.clock()
if (not nO and false) or (not ug_15 and not nO) or not ((not nO and false) or (not ug_15 and not nO)) then
    task.spawn(fns.worker)
    ScriptsGroup = ug_3.Info:AddRightGroupbox("Scripts", "package")
else
    task.spawn(fns.worker)
    ug_3 = ScriptsGroup.Info:AddRightGroupbox("Scripts", "package")
end
ScriptsGroup:AddLabel(ml("Included in this hub", ug_13), true)
ScriptsGroup:AddLabel(ml(ug_6, ug_2), true)
ug_8 = ug_3.Info:AddRightGroupbox("Features", "list")
ug_8:AddLabel(ml("Auto Train", ug_2), true)
ug_8:AddLabel(ml("Auto Win", nm), true)
ug_8:AddLabel(ml("Auto Shop", ug_26), true)
ug_8:AddLabel(ml("Auto Progress", ug_2), true)
ug_8:AddLabel(ml("Player Utilities", ug_13), true)
ug_17 = ug_3.Info:AddRightGroupbox("Socials", "link")
ug_17:AddButton({ Text = "Discord", Func = mv })
ug_17:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
ug_30 = ug_3.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
ug_30:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
ug_30:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
ug_30:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
ug_30:AddButton({ Text = "Copy Discord Invite", Func = mv })
ug_4 = ug_3.Info:AddRightGroupbox("Donations", "heart")
ug_4:AddLabel(ml("All donations are optional but appreciated.", nm), true)
ug_4:AddLabel(ml("If you donate you get a special role, just PING after you donate.", ug_26), true)
ug_4:AddDivider()
ug_4:AddLabel(ml("LTC / Litecoin", ug_25), true)
ug_4:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
ug_4:AddLabel(ml("BTC / Bitcoin", ug_12), true)
ug_4:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
ug_4:AddLabel(ml("ETH / Ethereum", ug_24), true)
ug_4:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
ug_4:AddLabel(ml("USDT", ug_36), true)
ug_4:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
ug_4:AddLabel(ml("Solana", ug_10), true)
ug_4:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
ug_4:AddLabel(ml("PayPal", ug_22), true)
ug_4:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
ug_4:AddLabel(ml("Venmo", ug_35), true)
ug_4:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
ug_4:AddDivider()
ug_4:AddLabel(ml("Don't have any of the listed currencies but still wanna donate?", ug_13), true)
ug_4:AddLabel(ml("DM me and we'll work something out.", ug_2), true)
local FaqGroup = ug_3.Info:AddRightGroupbox("FAQ", "circle-help")
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
for k, v in pairs(ug_3) do
    if v ~= ug_3.Info then
        fns.fn207(v)
    end
end
mH, mC, connection, connection2, CurrentCamera2, nT, mw, m4, ms, nR, m_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ug_8 = ug_3.Main:AddLeftGroupbox("Farm", "bot")
ug_8:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
ug_8:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
ug_8:AddDropdown("AutoWinMode", { Text = "Win Mode", Values = { "Best", "Worst", "Nearest", "Random" }, Default = "Best" })
ug_17 = ug_3.Main:AddLeftGroupbox("Progress", "sprout")
ug_17:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ug_17:AddToggle("AutoEvolve", { Text = "Auto Evolve", Default = false })
ug_17:AddToggle("AutoSelectBestCreature", { Text = "Auto Select Best Creature", Default = false })
ug_17:AddToggle("AutoBuyWorlds", { Text = "Auto Buy Worlds", Default = false })
ug_30 = ug_3.Main:AddRightGroupbox("Shop", "shopping-bag")
ug_30:AddToggle("AutoBuyBestTrail", { Text = "Auto Buy Best Trail", Default = false })
ug_30:AddToggle("AutoBuyBestAura", { Text = "Auto Buy Best Aura", Default = false })
ug_30:AddToggle("AutoBuySpeedUpgrade", { Text = "Auto Buy Speed Upgrade", Default = false })
ug_30:AddToggle("AutoBuyItemShop", { Text = "Auto Buy Item Shop", Default = false })
ug_30:AddDropdown("ItemShopItems", { Text = "Item Shop", Values = ug_32, Default = {}, Multi = true })
ug_30:AddToggle("AutoUseItems", { Text = "Auto Use Items", Default = false })
ug_4 = ug_3.Player:AddLeftGroupbox("Movement", "footprints")
ug_4:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
ug_4:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
ug_4:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
ug_4:AddToggle("NoClip", { Text = "NoClip", Default = false })
ug_4:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
ug_15 = ug_3.Player:AddRightGroupbox("Fly", "feather")
ug_15:AddToggle("Fly", { Text = "Fly", Default = false })
ug_15:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
ug_27 = ug_3.Settings:AddLeftGroupbox("Menu")
ug_27:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
ug_27:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
ug_27:AddButton({ Text = "Unload", Func = onUnload })
mH = tick()
mC = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local sC = v
        pcall(function()
            sC:Disable()
        end)
    end
end)
nT = fn658
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
task.spawn(antiAfkLoop)
mw = function(hi)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not hi)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not hi
        end
    end)
    if not hi then
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
Toggles.AntiGameplayPause:OnChanged(fn880)
task.spawn(fns.antiGameplayPauseLoop)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera2 = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn246)
Toggles.WalkSpeedEnabled:OnChanged(fn727)
task.spawn(worker2)
task.spawn(fns.worker3)
task.spawn(worker4)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(ug_3.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/SpeedEvolve")
ug_6 = SaveManager:BuildConfigSection(ug_3.Settings)
m4 = fns.fn488
ms = fns.fn205
nR = fns.fn259
m_ = function(iL)
    local tP
    tP = nil
    local tQ = type(iL) ~= "table" or type(iL.idx) ~= "string" or type(iL.type) ~= "string" or SaveManager.Ignore[iL.idx]
    if tQ then
        return false
    end
    tP = m4(iL.type, iL.idx)
    if not tP then
        return false
    end
    local tQ_1 = pcall(function()
        if iL.type == "Input" then
            if type(iL.text) ~= "string" then
                return
            end
            tP:SetValue(iL.text)
        elseif iL.type == "ColorPicker" then
            tP:SetValueRGB(Color3.fromHex(iL.value), iL.transparency)
        elseif iL.type == "KeyPicker" then
            tP:SetValue({ iL.key, iL.mode, iL.modifiers })
            if iL.mode == "Toggle" and iL.toggled ~= nil then
                tP.Toggled = iL.toggled
                tP:Update()
            end
        else
            tP:SetValue(iL.value)
        end
    end)
    return tQ_1
end
ug_6:AddDivider()
ug_6:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
ug_6:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
ug_6:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn643)
end)(...)
