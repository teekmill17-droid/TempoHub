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
getgenv().TempoHoodSubtitle = "+1 SWORD FIGHTING ESCAPE"
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
local A8_12_1
local FightManagerClient
local rb
local Enemies
local qb
local qu
local qe
local pT
local rh
local qA
local StrengthClickRemote
local qG
local rn_1
local p1
local qJ
local q1
local TrainingZones
local p7
local qa
local qS
local rd
local connection
local RebirthRemote
local qd
local Toggles
local LocalPlayer
local pV
local rj
local SwingInput
local qY
local qm
local rm
local Workspace
local pL
local Library
local q6
local pO
local p9
local qR
local pR
local qc
local Upgrades
local Options
local qX
local pX
local qE
local RebirthManagerClient
local Auras
local ql
local CollectionService
local qO
local pK
local p8
local function fn4()
    local yh = hookfunction ~= nil
    local yi = hookmetamethod ~= nil
    local yj = getrawmetatable ~= nil
    local yk = setrawmetatable ~= nil
    local yl = getgc ~= nil
    local ym = getgenv ~= nil
    local yn = getreg ~= nil
    local yo = getconnections ~= nil
    local yp = firesignal ~= nil
    local yq = getcallbackvalue ~= nil
    local yr = setclipboard ~= nil
    local ys = getcustomasset ~= nil
    local yt = getnamecallmethod ~= nil
    local yu = isexecutorclosure ~= nil
    local yv = fireproximityprompt ~= nil
    local yw = firetouchinterest ~= nil
    local yx = WebSocket ~= nil
    local yy = readfile ~= nil
    local yz = writefile ~= nil
    local yB = (request or http_request) ~= nil
    local yD = (debug and debug.getupvalues) ~= nil
    local yF = (debug and debug.setupvalue) ~= nil
    local yG = 0
    local yH = { yh, yi, yj, yk, yl, ym, yn, yo, yp, yq, yr, ys, yt, yu, yv, yw, yx, yy, yz, yB, yD, yF }
    for i, v in ipairs(yH) do
        if v then
            yG += 1
        end
    end
    local yh_1 = yG / #yH
    if yh_1 >= 0.9 then
        return qc("Full Support", rj)
    elseif yh_1 >= 0.6 then
        return qc("Half Support", rb)
    else
        return qc("Low Support", q1)
    end
end
local function fn70()
    local sm = p1()
    local sn = sm and sm.currencies and tonumber(sm.currencies.Wins)
    return sn or 0
end
local function fn75(ax, ay, az)
    return string.format("<b>%s</b> %s %s", ax, qc("-", "#5a6070"), qc(ay, az))
end
local function fn112(d_)
    local uM = d_ == ""
    local uN = type(d_) ~= "string"
    local uR = if uN then 1 else 0
    local uP = 253 * uR + 1662 * (1 - uR)
    local uQ = 2225 * uR + 1343 * (1 - uR)
    if not ((uP * 2789 + uQ * 1465 + uP * uQ) % 16777213 == 4528167) then
        uN = uM
    end
    if uN then
        return nil
    end
    local uM_1 = string.match(d_, "%(([^%)]+)%)$") or d_
    return uM_1
end
local function fn125()
    local Character = LocalPlayer.Character
    local sg = Character and Character:FindFirstChild("HumanoidRootPart")
    return sg
end
local function fn128(il)
    local DiscordGroup = il:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ql })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ql })
end
local function fn145()
    local Character = LocalPlayer.Character
    local sa = Character and Character:FindFirstChildOfClass("Humanoid")
    return sa
end
local function fn152(b5)
    if not b5 then
        return nil
    end
    local s6 = b5:GetAttribute("EnemyId") or b5.Name
    return s6
end
local function fn154()
    local tY_1
    local tX_1
    tX_1, tY_1 = pcall(function()
        return FightManagerClient.pendingReward()
    end)
    local tZ = tX_1 and tonumber(tY_1)
    return tZ or 0
end
local function fn176(bm)
    local Character = LocalPlayer.Character
    local sH = Character and Character:FindFirstChild("HumanoidRootPart")
    local sI = not Character
    local sN = if sI then 1 else 0
    local sL = 934 * sN + 3777 * (1 - sN)
    local sM = 3833 * sN + 3456 * (1 - sN)
    if not ((sL * 4052 + sM * 2402 + sL * sM) % 16777213 == 16571456) then
        sI = not sH
    end
    if not sI then
        sI = typeof(bm) ~= "CFrame"
    end
    if sI then
        return false
    end
    Character:PivotTo(bm)
    sH.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function fn193()
    local uE = {}
    for k, v in qe() do
        uE[#uE + 1] = v.Name .. " (" .. v.Id .. ")"
    end
    if #uE == 0 then
        uE[1] = "Dummy (Dummy)"
    end
    return uE
end
local function fn196(cz)
    local tE = cz:FindFirstChild("HumanoidRootPart") or cz.PrimaryPart or cz:FindFirstChildWhichIsA("BasePart", true)
    return tE
end
local function worker()
    while not Library.Unloaded do
        pcall(qY)
        pcall(rm)
        pcall(p7)
        pcall(p8)
        pcall(pR)
        pcall(pX)
        pcall(qO)
        pcall(qd)
        task.wait(0.05)
    end
end
local function fn220()
    qA(qu, "Copied Discord invite to clipboard")
end
local function fn268(dk, dl)
    if not dk then
        return false
    end
    local ue = os.clock()
    local ug = ue + (dl or 2.5)
    while os.clock() < ug do
        if Library.Unloaded then
            return false
        end
        dk = qm(dk)
        local uf_1 = dk and dk.Enemy
        local ue_2 = pT(uf_1)
        local uh = qS(dk.Id)
        local ui = uf_1 and ue_2
        if ui then
            ui = uh == nil or uh > 0
        end
        if ui then
            return true
        end
        task.wait(0.1)
    end
    dk = qm(dk)
    local ue_4 = dk and qS(dk.Id)
    local uf_2 = dk
    if uf_2 then
        uf_2 = dk.Enemy ~= nil
    end
    if uf_2 then
        uf_2 = ue_4 == nil or ue_4 > 0
    end
    return uf_2
end
local function fn329()
    local uq_1
    local up_1
    local uo = {}
    up_1, uq_1 = pcall(function()
        return Enemies.getConfigs()
    end)
    local ur = not up_1 or type(uq_1) ~= "table"
    if ur then
        return uo
    end
    for k, v in uq_1 do
        local up_2 = type(v) == "table" and not Enemies.isWorld2EnemyId(k)
        if up_2 then
            local up_3 = #uo + 1
            local uq_2 = tonumber(v.level) or 0
            local ur_1 = Enemies.getCombatLevel(v)
            local us = tonumber(v.reward) or 0
            local ut = v.displayName or k
            uo[up_3] = { Id = k, Level = uq_2, Combat = ur_1, Reward = us, Name = ut, Config = v }
        end
    end
    table.sort(uo, function(dS, dT)
        if dS.Level == dT.Level then
            return dS.Reward < dT.Reward
        end
        return dS.Level < dT.Level
    end)
    return uo
end
local function fn393(an, ao)
    if setclipboard then
        setclipboard(an)
    elseif toclipboard then
        toclipboard(an)
    end
    Library:Notify(ao)
end
local function fn409(hj, hk)
    if not hj then
        return false
    end
    local xA = tonumber(hj.rebirthRequired) or 0
    local xA_1 = tonumber(hk.rebirths) or 0
    if xA > xA_1 then
        return false
    end
    if hj.worldId == rh.World2 and not hk.world2Unlocked then
        return false
    elseif hj.developerProductId then
        local ownedProducts = hk.ownedProducts
        local xB_1 = type(ownedProducts) ~= "table" or not ownedProducts[hj.developerProductId]
        if xB_1 then
            return false
        end
        return true
    else
        return true
    end
end
local function fn469(cC)
    local tG_6
    if cC then
        local Parent2 = cC.Parent
        if Parent2 and Parent2.Name == "Stage" then
            local RewardPad = Parent2:FindFirstChild("RewardPad")
            if RewardPad then
                if RewardPad:IsA("BasePart") then
                    return RewardPad
                end
                local BasePart = RewardPad:FindFirstChildWhichIsA("BasePart", true)
                if BasePart then
                    return BasePart
                end
                local tG_3 = pT(cC)
                if not tG_6 then
                    return nil
                end
                local World1 = Workspace:FindFirstChild("World1")
                local tI_1 = nil
                local tJ_1 = nil
                for k, v in CollectionService:GetTagged(p9.RewardPad) do
                    local tK_1 = v:IsA("BasePart") and World1 and v:IsDescendantOf(World1)
                    if tK_1 then
                        local Parent = v.Parent
                        local tL_1 = Parent
                        if tL_1 then
                            tL_1 = Parent.Name == "SkipEnemyPad" or Parent.Name == "TripleRewardPad"
                        end
                        if not tL_1 then
                            local tL_2 = v.Name == "RewardPad"
                            if not tL_2 then
                                tL_2 = Parent and Parent.Name == "RewardPad"
                            end
                            if not not tL_2 then
                                local Magnitude = (v.Position - tG_3.Position).Magnitude
                                if not tJ_1 or Magnitude < tJ_1 then
                                    tI_1 = v
                                    tJ_1 = Magnitude
                                end
                            end
                        end
                    end
                end
                return tI_1
            end
            local tG_4 = pT(cC)
            if not tG_6 then
                return nil
            end
            local World1 = Workspace:FindFirstChild("World1")
            local tI_2 = nil
            local tJ_2 = nil
            for k, v in CollectionService:GetTagged(p9.RewardPad) do
                local tK_4 = v:IsA("BasePart") and World1 and v:IsDescendantOf(World1)
                if tK_4 then
                    local Parent = v.Parent
                    local tL_4 = Parent
                    if tL_4 then
                        tL_4 = Parent.Name == "SkipEnemyPad" or Parent.Name == "TripleRewardPad"
                    end
                    if not tL_4 then
                        local tL_5 = v.Name == "RewardPad"
                        if not tL_5 then
                            tL_5 = Parent and Parent.Name == "RewardPad"
                        end
                        if not not tL_5 then
                            local Magnitude = (v.Position - tG_4.Position).Magnitude
                            if not tJ_2 or Magnitude < tJ_2 then
                                tI_2 = v
                                tJ_2 = Magnitude
                            end
                        end
                    end
                end
            end
            return tI_2
        end
        local tG_5 = pT(cC)
        if not tG_6 then
            return nil
        end
        local World1 = Workspace:FindFirstChild("World1")
        local tI_3 = nil
        local tJ_3 = nil
        for k, v in CollectionService:GetTagged(p9.RewardPad) do
            local tK_7 = v:IsA("BasePart") and World1 and v:IsDescendantOf(World1)
            if tK_7 then
                local Parent = v.Parent
                local tL_7 = Parent
                if tL_7 then
                    tL_7 = Parent.Name == "SkipEnemyPad" or Parent.Name == "TripleRewardPad"
                end
                if not tL_7 then
                    local tL_8 = v.Name == "RewardPad"
                    if not tL_8 then
                        tL_8 = Parent and Parent.Name == "RewardPad"
                    end
                    if not not tL_8 then
                        local Magnitude = (v.Position - tG_5.Position).Magnitude
                        if not tJ_3 or Magnitude < tJ_3 then
                            tI_3 = v
                            tJ_3 = Magnitude
                        end
                    end
                end
            end
        end
        return tI_3
    end
    tG_6 = pT(cC)
    if not tG_6 then
        return nil
    end
    local World1 = Workspace:FindFirstChild("World1")
    local tI_4 = nil
    local tJ_4 = nil
    for k, v in CollectionService:GetTagged(p9.RewardPad) do
        local tK_10 = v:IsA("BasePart") and World1 and v:IsDescendantOf(World1)
        if tK_10 then
            local Parent = v.Parent
            local tL_10 = Parent
            if tL_10 then
                tL_10 = Parent.Name == "SkipEnemyPad" or Parent.Name == "TripleRewardPad"
            end
            if not tL_10 then
                local tL_11 = v.Name == "RewardPad"
                if not tL_11 then
                    tL_11 = Parent and Parent.Name == "RewardPad"
                end
                if not not tL_11 then
                    local Magnitude = (v.Position - tG_6.Position).Magnitude
                    if not tJ_4 or Magnitude < tJ_4 then
                        tI_4 = v
                        tJ_4 = Magnitude
                    end
                end
            end
        end
    end
    return tI_4
end
local function fn478(W)
    if W then
        qb[#qb + 1] = W
    end
    return W
end
local function fn503()
    qR = 1
    qJ = false
end
local function fn512(c7)
    local t1_1
    local t0_1
    t0_1, t1_1 = pcall(function()
        return FightManagerClient.getEnemyHealths()
    end)
    local t2 = not t0_1 or type(t1_1) ~= "table"
    if t2 or not c7 then
        return nil
    end
    local t0_3 = tonumber(t1_1["World1:" .. c7]) or tonumber(t1_1[c7])
    return t0_3
end
local function fn561(df)
    if not df then
        return nil
    end
    local t8 = qE(df.Id)
    if t8 and t8.Enemy then
        return t8
    end
    return df
end
local function fn583()
    local wA = Options.UpgradeSelect and Options.UpgradeSelect.Value
    local wB = {}
    if type(wA) == "table" then
        for k, v in wA do
            if v then
                wB[#wB + 1] = k
            end
        end
    else
        local wA_1 = wA ~= ""
        local wD = type(wA) == "string" and wA_1
        if wD then
            wB[1] = wA
        end
    end
    if #wB == 0 then
        for k, v in Upgrades.order do
            wB[#wB + 1] = v
        end
    end
    return wB
end
local function fn605()
    local wc_1
    local wb_1
    if not qX("AutoRebirth") then
        return
    end
    if os.clock() - pL < 1.25 then
        return
    end
    pL = os.clock()
    wb_1, wc_1 = pcall(function()
        return RebirthManagerClient.canRebirth()
    end)
    if not wb_1 or not wc_1 then
        return
    end
    pcall(function()
        RebirthManagerClient.request()
    end)
    pcall(function()
        RebirthRemote:FireServer()
    end)
end
local function fn650(ea)
    if not ea then
        return nil
    end
    local u4 = qE(ea.Id)
    if u4 then
        return u4
    end
    return {
        Id = ea.Id,
        Enemy = nil,
        Config = ea.Config,
        Level = ea.Level,
        Combat = ea.Combat,
        Reward = ea.Reward,
        Name = ea.Name
    }
end
local function fn661()
    if not qX("AutoClick") then
        pcall(function()
            if SwingInput.isAutoFightEnabled() then
                SwingInput.setAutoFightEnabled(false)
            end
        end)
        return
    end
    pcall(function()
        if not SwingInput.isAutoFightEnabled() then
            SwingInput.setAutoFightEnabled(true)
        end
    end)
    if qX("AutoTrain") then
        return
    end
    local x1 = tonumber(pK.clickCooldown) or 0.15
    local x6 = if os.clock() - q6 < x1 then 1 else 0
    if x6 == 1 then
        return
    end
    q6 = os.clock()
    pcall(function()
        StrengthClickRemote:FireServer()
    end)
end
local function fn722()
    local uS = qe()
    local uT = Options.FarmStage and Options.FarmStage.Value
    local uU = qG(uT)
    if not uU then
        return math.max(1, #uS)
    end
    for k, v in uS do
        if v.Id == uU then
            return k
        end
    end
    return math.max(1, #uS)
end
local function fn733(cn)
    for k, v in pV() do
        if v.Id == cn then
            return v
        end
    end
    local to = Workspace:FindFirstChild(cn, true)
    local tp = to and to:IsA("Model") and CollectionService:HasTag(to, p9.Enemy)
    if tp then
        local tp_1 = Enemies.getConfig(cn)
        if tp_1 then
            local tq = tonumber(tp_1.level) or 0
            local tr = Enemies.getCombatLevel(tp_1)
            local ts = tonumber(tp_1.reward) or 0
            return {
                Id = cn,
                Enemy = to,
                Config = tp_1,
                Level = tq,
                Combat = tr,
                Reward = ts,
                Name = tp_1.displayName or cn
            }
        end
    end
end
local function fn763(au, av)
    return string.format('<font color="%s">%s</font>', av, au)
end
local function fn870()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end
local function fn893()
    local sj_1
    local si_1
    si_1, sj_1 = pcall(function()
        return rd:get()
    end)
    local sk = si_1 and type(sj_1) == "table"
    if sk then
        return sj_1
    end
    return nil
end
local function fn971(gN)
    for k, v in CollectionService:GetTagged(p9.SwordPrompt) do
        local w4 = v:IsA("ProximityPrompt") and v:GetAttribute("SwordId") == gN
        if w4 then
            return v
        end
    end
end
local function fn973()
    local s9 = {}
    for k, v in CollectionService:GetTagged(p9.Enemy) do
        local ta = v:IsA("Model") and v.Parent and v.Parent.Name == "Stage"
        if ta then
            local ta_1 = qa(v)
            local tb = ta_1 and Enemies.getConfig(ta_1)
            if ta_1 and tb then
                local tb_2 = #s9 + 1
                local td = tonumber(tb.level) or 0
                local te = Enemies.getCombatLevel(tb)
                local tf = tonumber(tb.reward) or 0
                local tg = tb.displayName or ta_1
                s9[tb_2] = { Id = ta_1, Enemy = v, Config = tb, Level = td, Combat = te, Reward = tf, Name = tg }
            end
        end
    end
    table.sort(s9, function(ck, cl)
        if ck.Level == cl.Level then
            return ck.Reward < cl.Reward
        end
        return ck.Level < cl.Level
    end)
    return s9
end
local function fn974(aH)
    if Library.Unloaded then
        return false
    end
    local r6 = Toggles[aH]
    return r6 ~= nil and r6.Value == true
end
local function fn985()
    local wg = {}
    for k in Auras.AuraId do
        local wh = Auras.getConfig(k)
        if wh and not wh.RobuxOnly then
            local wi_1 = #wg + 1
            local wj = tonumber(wh.price) or 0
            local wk = tonumber(wh.strengthMultiplier) or 0
            wg[wi_1] = { Id = k, Price = wj, Multi = wk }
        end
    end
    table.sort(wg, function(f_, f0)
        return f_.Price < f0.Price
    end)
    return wg
end
local function fn1036()
    local xG = p1()
    if not xG then
        return nil
    end
    local xH
    local xI = -1
    for k in TrainingZones.TrainingZoneId do
        local xJ = TrainingZones.getConfig(k)
        if pO(xJ, xG) then
            local xK = tonumber(xJ.strengthMultiplier) or 0
            if xK > xI then
                xI = xK
                xH = k
            end
        end
    end
    if not xH then
        return nil
    end
    for k, v in CollectionService:GetTagged(p9.TrainingZone) do
        local xG_1 = v:IsA("BasePart") and v:GetAttribute("TrainingZoneId") == xH
        if xG_1 then
            return v, xH
        end
    end
end
pK = nil
pL = nil
TrainingZones = nil
pO = nil
Enemies = nil
pR = nil
connection = nil
pT = nil
Upgrades = nil
pV = nil
pX = nil
Auras = nil
p1 = nil
p7 = nil
p8 = nil
p9 = nil
qa = nil
qb = nil
qc = nil
qd = nil
qe = nil
Options = nil
Toggles = nil
ql = nil
qm = nil
Library = nil
qu = nil
local Players, pJ, pN, pP, pW, pY, pZ, p0, p2, p3, Swords, p5, p6, qh, qi, qj, SaveManager, qn, qo, qp, qq, qr, qt
RebirthRemote = nil
qA = nil
LocalPlayer = nil
StrengthClickRemote = nil
qE = nil
SwingInput = nil
qG = nil
CollectionService = nil
qJ = nil
Workspace = nil
qO = nil
FightManagerClient = nil
qR = nil
qS = nil
qX = nil
qY = nil
RebirthManagerClient = nil
q1 = nil
q6 = nil
rb = nil
rd = nil
rh = nil
local qv, qw, qx, qy, qB, FightActionRemote, qK, UpgradeManagerClient, qN, CoreGui, TeleportService, qV, qW, GuiService, q0, q3, HttpService, q5, q7, q8, AuraPackets, ra, rc, re, rf, rg
rj = nil
rm = nil
local ri, rk, rl, ro, rp
ri = nil
rk = nil
rl = nil
ro = nil
rp = nil
Players, rg, rc, q8, HttpService, GuiService, TeleportService, CoreGui, Workspace, CollectionService, LocalPlayer, qy, qu, qr, qp, p9, Swords, Auras, Upgrades, Enemies, TrainingZones, pK, rn_1, rh, rd, AuraPackets, q5, RebirthManagerClient, FightManagerClient, UpgradeManagerClient, FightActionRemote, StrengthClickRemote, RebirthRemote, Library, SaveManager, Toggles, Options, qb, connection, pN, pL, ro, ri, re, ra, q6, q0, qV, qR, qN, qJ, SwingInput, rj, rf, rb, q7, q1, qo, p6, qA, ql, qc, pW, qX, qw, qh, p1, rl, pY, pP, q3, p3, qa, pV, qE, pT, rp, rk, qS, qm, p2, qn, qe, qG, qx, pZ, pJ, p5, qv, qY, rm, qB, p7, qK, p8, qj, pR, pO, qW, pX, qO, qd, A8_12_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
if ((false or qb and p2) and ("https://tempohub.shop" or p2 and p2) or (qp or qb or (p2 or not p2) or "https://tempohub.shop" and (p2 or not qb))) and ((qb and qp or (not p2 or qp) or (p2 and qp or (qb or not p2))) and ((qp and not p2 or false and not p2) and (false and not p2 or qb and not qb))) or not (((false or qb and p2) and ("https://tempohub.shop" or p2 and p2) or (qp or qb or (p2 or not p2) or "https://tempohub.shop" and (p2 or not qb))) and ((qb and qp or (not p2 or qp) or (p2 and qp or (qb or not p2))) and ((qp and not p2 or false and not p2) and (false and not p2 or qb and not qb)))) then
    rg = game:GetService("RunService")
    rc = game:GetService("UserInputService")
    q8 = game:GetService("VirtualUser")
else
    q8 = game:GetService("RunService")
    rg = game:GetService("UserInputService")
    rc = game:GetService("VirtualUser")
end
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
TeleportService = game:GetService("TeleportService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
CollectionService = game:GetService("CollectionService")
LocalPlayer = Players.LocalPlayer
qy = "+1 Sword Fighting Escape"
qu = "https://discord.gg/K7Qxnxkk46"
qr = "https://discord.gg/K7Qxnxkk46"
qp = "https://tempohub.shop"
local A8_19 = ReplicatedStorage:WaitForChild("Source")
local A8_26 = A8_19:WaitForChild("Configs")
local A8_7 = A8_19:WaitForChild("Features")
if (false or Swords or Swords and not p9) and (Swords and Swords and (qv or not A8_12_1)) and not ((false or Swords or Swords and not p9) and (Swords and Swords and (qv or not A8_12_1))) then
    A8_26 = require(Swords:WaitForChild("Tags"))
    p9 = require(Swords:WaitForChild("Swords"))
else
    p9 = require(A8_26:WaitForChild("Tags"))
    Swords = require(A8_26:WaitForChild("Swords"))
end
Auras = require(A8_26:WaitForChild("Auras"))
if ((qS or not qA) and (not qA or not qS) or (qA and qS or (qS or qS))) and not ((qS or not qA) and (not qA or not qS) or (qA and qS or (qS or qS))) then
    A8_26 = require(Upgrades:WaitForChild("Upgrades"))
else
    Upgrades = require(A8_26:WaitForChild("Upgrades"))
end
Enemies = require(A8_26:WaitForChild("Enemies"))
TrainingZones = require(A8_26:WaitForChild("TrainingZones"))
if (StrengthClickRemote or StrengthClickRemote or (StrengthClickRemote or not StrengthClickRemote)) and (StrengthClickRemote or StrengthClickRemote or StrengthClickRemote and not StrengthClickRemote) or not ((StrengthClickRemote or StrengthClickRemote or (StrengthClickRemote or not StrengthClickRemote)) and (StrengthClickRemote or StrengthClickRemote or StrengthClickRemote and not StrengthClickRemote)) then
    pK = require(A8_26:WaitForChild("Training"))
    require(A8_26:WaitForChild("Levels"))
    rh = require(A8_26:WaitForChild("Worlds"))
else
    rh = require(rn_1:WaitForChild("Training"))
    require(rn_1:WaitForChild("Levels"))
    pK = require(rn_1:WaitForChild("Worlds"))
end
if ((not qB and not q6 or not qB and not q6) and ((pJ or q6) and (q6 and not qB)) or ((not q6 or pJ) and (qB and q6) or (not qB and q6 or not qB and pJ)) or ((false and q6 or qB and false) and (q6 and q6 and (pJ or false)) or (not qB and false and (q6 or not q6) or (q6 or not qB or pJ and not q6)))) and not ((not qB and not q6 or not qB and not q6) and ((pJ or q6) and (q6 and not qB)) or ((not q6 or pJ) and (qB and q6) or (not qB and q6 or not qB and pJ)) or ((false and q6 or qB and false) and (q6 and q6 and (pJ or false)) or (not qB and false and (q6 or not q6) or (q6 or not qB or pJ and not q6)))) then
    q5 = require(AuraPackets:WaitForChild("PlayerDataClient"))
    A8_7 = require(RebirthManagerClient:WaitForChild("Auras"):WaitForChild("AuraPackets"))
    A8_19 = require(RebirthManagerClient:WaitForChild("Upgrades"):WaitForChild("UpgradePackets"))
    rd = require(RebirthManagerClient:WaitForChild("Rebirths"):WaitForChild("RebirthManagerClient"))
else
    rd = require(A8_19:WaitForChild("PlayerDataClient"))
    AuraPackets = require(A8_7:WaitForChild("Auras"):WaitForChild("AuraPackets"))
    q5 = require(A8_7:WaitForChild("Upgrades"):WaitForChild("UpgradePackets"))
    RebirthManagerClient = require(A8_7:WaitForChild("Rebirths"):WaitForChild("RebirthManagerClient"))
end
require(A8_7:WaitForChild("Levels"):WaitForChild("LevelManagerClient"))
FightManagerClient = require(A8_7:WaitForChild("Fighting"):WaitForChild("FightManagerClient"))
UpgradeManagerClient = require(A8_7:WaitForChild("Upgrades"):WaitForChild("UpgradeManagerClient"))
FightActionRemote = ReplicatedStorage:WaitForChild("FightActionRemote")
StrengthClickRemote = ReplicatedStorage:WaitForChild("StrengthClickRemote")
RebirthRemote = ReplicatedStorage:WaitForChild("RebirthRemote")
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
qb = {}
p6 = fn478
pN = 0
pL = 0
ro = 0
ri = 0
re = 0
ra = 0
q6 = 0
if (qG or not qN or (not rl or qN) or (not qG and qG or qN and not qG)) and (not qN and qN or qN and not qN or (qG and qG or (qG or not rl))) or not ((qG or not qN or (not rl or qN) or (not qG and qG or qN and not qG)) and (not qN and qN or qN and not qN or (qG and qG or (qG or not rl)))) then
    q0 = 0
    qV = false
else
    qV = 0
    q0 = false
end
qR = 1
qN = nil
qJ = false
SwingInput = require(A8_19:WaitForChild("SwingInput"))
qA = fn393
ql = fn220
qc = fn763
pW = fn75
rj = "#7fd47f"
rf = "#6ec1ff"
rb = "#e8a34d"
q7 = "#8b93a3"
q1 = "#e05a5a"
qX = fn974
qw = fn145
qh = fn125
p1 = fn893
rl = fn70
pY = fn870
pP = fn176
q3 = function(bt)
    pY()
    connection = rg.Heartbeat:Connect(function()
        local sP_1
        local sO_1
        if Library.Unloaded then
            pY()
            return
        end
        sO_1, sP_1 = pcall(bt)
        local sQ = sO_1 and typeof(sP_1) == "CFrame"
        if sQ then
            pP(sP_1)
        end
    end)
    p6(connection)
end
p3 = function(bI)
    local sV = qh()
    local sW = not sV or not bI or not bI.Parent or not bI:IsA("BasePart")
    if sW then
        return false
    elseif firetouchinterest then
        local sW_1 = pcall(function()
            firetouchinterest(sV, bI, 0)
            firetouchinterest(sV, bI, 1)
        end)
        return sW_1
    else
        return false
    end
end
local function onTPToSpawn()
    local s_
    pY()
    pcall(function()
        FightManagerClient.returnToSpawn()
    end)
    s_ = "World1"
    pcall(function()
        local sY = rh.getPlayerWorld(LocalPlayer) or "World1"
        s_ = sY
    end)
    local s0 = Workspace:FindFirstChild(s_)
    local s1 = s0 and s0:FindFirstChild("SpawnLocation", true)
    local s0_1 = s1
    local s1_1 = not s0_1 or not s0_1:IsA("BasePart")
    if s1_1 then
        s0_1 = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    end
    if s0_1 then
        pP(s0_1.CFrame + Vector3.new(0, 3, 0))
    end
end
qa = fn152
pV = fn973
if (not RebirthManagerClient or not qm or (RebirthManagerClient or pX) or (qm or not RebirthManagerClient or (qb or not FightActionRemote))) and ((FightActionRemote and qm or qm and not RebirthManagerClient) and (qb and false and (RebirthManagerClient and qb))) or not ((not RebirthManagerClient or not qm or (RebirthManagerClient or pX) or (qm or not RebirthManagerClient or (qb or not FightActionRemote))) and ((FightActionRemote and qm or qm and not RebirthManagerClient) and (qb and false and (RebirthManagerClient and qb)))) then
    qE = fn733
    pT = fn196
    rp = fn469
else
    pT = fn733
    rp = fn196
    qE = fn469
end
rk = fn154
qS = fn512
qm = fn561
p2 = fn268
qn = fn503
qe = fn329
qG = fn112
qx = fn722
pZ = fn650
pJ = function(ee)
    local u8 = pT(ee)
    if not u8 then
        return false
    end
    q3(function()
        local u6 = pT(ee)
        if not u6 then
            return nil
        end
        return u6.CFrame * CFrame.new(0, 2, 5)
    end)
    local u8_1 = tonumber(Enemies.attackRange) or 14
    local u8_2 = os.clock() + 1.5
    while true do
        if not (os.clock() < u8_2) then
            local va_1 = qh()
            local u8_3 = pT(ee)
            return va_1 ~= nil and u8_3 ~= nil and (va_1.Position - u8_3.Position).Magnitude <= u8_1 + 2
        end
        if Library.Unloaded then
            pY()
            return false
        end
        local va_2 = qh()
        local vb_2 = pT(ee)
        if va_2 and vb_2 and (va_2.Position - vb_2.Position).Magnitude <= u8_1 then
            break
        end
        task.wait(0.05)
    end
    task.wait(0.15)
    return true
end
p5 = function(ey)
    if not ey then
        return false
    elseif not p2(ey, 4) then
        return false
    else
        ey = qm(ey)
        local vk = ey and ey.Enemy
        local vl_1 = not vk or not pT(vk)
        if vl_1 then
            return false
        end
        local vl_2 = rk()
        if not pJ(vk) then
            pY()
            return false
        end
        local vq = 1
        while vq <= 6 do
            if Library.Unloaded then
                pY()
                return false
            end
            pcall(function()
                FightActionRemote:FireServer("Defeat", { enemy = vk })
            end)
            task.wait(0.08)
            if rk() > vl_2 then
                pY()
                return true
            end
            vq += 1
        end
        local vm = os.clock() + 1.25
        while os.clock() < vm do
            if rk() > vl_2 then
                pY()
                return true
            end
            task.wait(0.05)
        end
        pY()
        return rk() > vl_2
    end
end
qv = function(eQ)
    local vu
    vu = nil
    if not eQ then
        return false
    end
    eQ = qm(eQ)
    local vv = eQ and eQ.Enemy
    vu = rp(vv)
    if not vu then
        return false
    end
    local vv_1 = rl()
    local vw = rk()
    if vw <= 0 then
        return false
    end
    q3(function()
        if not vu.Parent then
            return nil
        end
        return vu.CFrame + Vector3.new(0, 3, 0)
    end)
    task.wait(0.12)
    local vF = 1
    while vF <= 12 do
        p3(vu)
        local vx_1 = rk() <= 0 or rl() > vv_1
        if vx_1 then
            break
        end
        task.wait(0.05)
        vF += 1
    end
    pY()
    local vx_2 = os.clock() + 0.8
    while true do
        local vC = if os.clock() < vx_2 then 1 else 0
        local vA = 522 * vC + 3280 * (1 - vC)
        local vB = 2506 * vC + 2908 * (1 - vC)
        if not ((vA * 3479 + vB * 2705 + vA * vB) % 16777213 == 9902900) then
            local vx_3 = rl() > vv_1 or rk() < vw
            return vx_3
        end
        local vy = rl() > vv_1 or rk() < vw
        if vy then
            break
        end
        task.wait(0.05)
    end
    return true
end
qY = function()
    local vX, vY
    if not qX("AutoFarmStage") then
        if qV then
            qV = false
            pY()
        end
        return
    end
    if qV then
        return
    end
    local v_ = Options.FarmDelay and Options.FarmDelay.Value or 0.45
    if os.clock() - pN < v_ then
        return
    end
    vX = qe()
    if #vX == 0 then
        return
    end
    local vZ_2 = Options.FarmStage and Options.FarmStage.Value
    if vZ_2 ~= qN then
        qN = vZ_2
        qn()
    end
    vY = qx()
    if qR < 1 then
        qR = 1
    elseif qR > vY then
        qR = vY
    end
    local vZ_3 = qR > 1 and rk() <= 0
    if vZ_3 and not qJ then
        qR = 1
    end
    qV = true
    pN = os.clock()
    pcall(function()
        if qJ then
            local vL_1 = pZ(vX[1])
            if p2(vL_1, 3) then
                qJ = false
                qR = 1
            end
            return
        end
        local vL_2 = vX[qR]
        local vM = pZ(vL_2)
        if not vM or not vM.Enemy then
            local vN_1 = vM or { Id = vL_2.Id }
            p2(vN_1, 3)
            vM = pZ(vL_2)
        end
        local vL_3 = not vM
        local vR = if vL_3 then 1 else 0
        local vP = 2095 * vR + 3952 * (1 - vR)
        local vQ = 1325 * vR + 2164 * (1 - vR)
        if not ((vP * 4032 + vQ * 3180 + vP * vQ) % 16777213 == 15436415) then
            vL_3 = not vM.Enemy
        end
        if vL_3 then
            return
        end
        local vL_4 = qR >= vY
        local vN_2 = p5(vM)
        if not vN_2 then
            pcall(function()
                FightManagerClient.returnToSpawn()
            end)
            return
        end
        if vL_4 then
            local vU = 1
            while true do
                if not (vU <= 3) then
                    return
                end
                if qv(vM) then
                    break
                end
                task.wait(0.12)
                vU += 1
            end
            qn()
            qJ = true
            return
        end
        qR += 1
    end)
    pY()
    qV = false
end
rm = fn605
qB = fn985
p7 = function()
    if not qX("AutoBuyAura") then
        return
    end
    if os.clock() - ro < 1 then
        return
    end
    ro = os.clock()
    local wq = p1()
    if not wq then
        return
    end
    local ws = wq.ownedAuras or {}
    local ws_1 = wq.currencies and wq.currencies.Wins
    local wq_1 = tonumber(ws_1) or 0
    local ws_2 = wq_1
    for k, v in qB() do
        local wz = v
        if not ws[wz.Id] and wz.Price > 0 and ws_2 >= wz.Price then
            pcall(function()
                AuraPackets.request.send({ auraId = wz.Id })
            end)
            ws_2 -= wz.Price
        end
    end
end
qK = fn583
p8 = function()
    local wW_1, wW_2
    local wV_1, wV_2
    if not qX("AutoBuyUpgrades") then
        return
    end
    if os.clock() - ri < 0.85 then
        return
    end
    ri = os.clock()
    local wU = rl()
    for k, v in qK() do
        local w3 = v
        wV_1, wW_1 = pcall(function()
            return UpgradeManagerClient.isMaxed(w3)
        end)
        if not (wV_1 and wW_1) then
            wV_2, wW_2 = pcall(function()
                return UpgradeManagerClient.getCost(w3)
            end)
            local wX_1 = wV_2 and tonumber(wW_2)
            local wV_3 = wX_1 or nil
            local wW_3 = wV_3
            if wV_3 then
                wV_3 = wU >= wW_3
            end
            if wV_3 then
                pcall(function()
                    q5.request.send({ upgradeId = w3 })
                end)
                wU -= wW_3
            end
        end
    end
end
qj = fn971
pR = function()
    if not qX("AutoBuySword") then
        return
    end
    if os.clock() - re < 1.1 then
        return
    end
    re = os.clock()
    local xk = p1()
    if not xk then
        return
    end
    local xl = {}
    local xm = xk.ownedSwords
    local xt = if xm then 1 else 0
    local xr = 3578 * xt + 257 * (1 - xt)
    local xs = 774 * xt + 2056 * (1 - xt)
    if not ((xr * 386 + xs * 1675 + xr * xs) % 16777213 == 5446930) then
        xm = xl
    end
    local xi = xm
    local xl_1 = xk.currencies and xk.currencies.Wins
    local xk_1 = tonumber(xl_1) or 0
    local xj = xk_1
    local xk_2 = Swords.progression or Swords.world1Progression
    for k, v in xk_2 do
        local xg
        local xz = v
        if not xi[xz] then
            xg = false
            pcall(function()
                xg = Swords.canBuyWithWins(xi, xz, xj) == true
            end)
            if not xg then
                return
            end
            local xh = qj(xz)
            if not xh then
                return
            end
            local BasePart = xh:FindFirstAncestorWhichIsA("BasePart")
            if BasePart then
                q3(function()
                    return BasePart.CFrame + Vector3.new(0, 3, 0)
                end)
                task.wait(0.15)
            end
            if fireproximityprompt then
                pcall(fireproximityprompt, xh)
            else
                pcall(function()
                    xh:InputHoldBegin()
                    local xd = xh.HoldDuration or 0.05
                    task.wait(xd)
                    xh:InputHoldEnd()
                end)
            end
            pY()
            return
        end
    end
end
pO = fn409
qW = fn1036
pX = function()
    local xW
    xW = nil
    if not qX("AutoTrain") then
        if not qX("AutoFarmStage") then
            pY()
        end
        return
    end
    if qX("AutoFarmStage") then
        return
    end
    local xX = tonumber(pK.clickCooldown) or 0.15
    if os.clock() - ra < xX then
        return
    end
    ra = os.clock()
    xW = qW()
    if not xW then
        return
    end
    q3(function()
        return xW.CFrame + Vector3.new(0, 3, 0)
    end)
    pcall(function()
        StrengthClickRemote:FireServer()
    end)
end
qO = fn661
qd = function()
    local yc
    if not qX("AutoRespawn") then
        return
    end
    if os.clock() - q0 < 1.25 then
        return
    end
    yc = false
    pcall(function()
        local x7 = FightManagerClient.isReviveChoiceOpen and FightManagerClient.isReviveChoiceOpen()
        if x7 then
            yc = true
        end
    end)
    pcall(function()
        local x9 = FightManagerClient.playerHealth and FightManagerClient.playerHealth()
        local x9_1 = type(x9) == "number" and x9 <= 0
        if x9_1 then
            yc = true
        end
    end)
    local yd = qw()
    if yd and yd.Health <= 0 then
        yc = true
    end
    if not yc then
        return
    end
    q0 = os.clock()
    pcall(function()
        FightManagerClient.returnToSpawn()
    end)
    pcall(function()
        FightActionRemote:FireServer("Lost", {})
    end)
    pcall(function()
        LocalPlayer:LoadCharacter()
    end)
end
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = qu, Copyable = true }, "|", qy },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
qo = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "swords"),
    Shop = Window:AddTab("Shop", "shopping-cart"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in qo do
    if k ~= "Info" then
        fn128(v)
    end
end
local A8_26_1 = qo.Main:AddLeftGroupbox("Auto Farm", "swords")
A8_26_1:AddToggle("AutoFarmStage", { Text = "Auto Farm Stage", Default = false })
A8_26_1:AddDropdown("FarmStage", { Text = "Up To Stage", Values = fn193(), Default = 1 })
A8_26_1:AddSlider("FarmDelay", { Text = "Farm Delay", Default = 0.45, Min = 0.2, Max = 3, Rounding = 2 })
local A8_7_1 = qo.Main:AddRightGroupbox("Progress", "rotate-ccw")
A8_7_1:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
A8_7_1:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
A8_7_1:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
A8_7_1:AddToggle("AutoRespawn", { Text = "Auto Respawn", Default = false })
A8_7_1:AddButton({ Text = "TP to Spawn", Func = onTPToSpawn })
local ShopGroup = qo.Shop:AddLeftGroupbox("Shop", "sparkles")
ShopGroup:AddToggle("AutoBuyAura", { Text = "Auto Buy Aura", Default = false })
ShopGroup:AddToggle("AutoBuySword", { Text = "Auto Buy Sword", Default = false })
ShopGroup:AddDivider("Upgrades")
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
local A8_28_1 = {}
local A8_7_2 = #Upgrades.order
local rW = 1
while rW <= A8_7_2 do
    local rX = rW
    A8_28_1[#A8_28_1 + 1] = Upgrades.order[rX]
    rW += 1
end
if #A8_28_1 == 0 then
    for k, v in Upgrades.order do
        A8_28_1[#A8_28_1 + 1] = v
    end
end
qq, qi, p0, qt = nil, nil, nil, nil
ShopGroup:AddDropdown("UpgradeSelect", { Text = "Upgrades", Values = A8_28_1, Multi = true, Default = {} })
task.spawn(worker)
qt = fn4
local function A8_22_1()
    local y7
    local zb
    y7 = nil
    zb = nil
    local Label, Label2, Label3, y9, za
    zb = "Unknown"
    pcall(function()
        local yT_1
        local yS_1
        if identifyexecutor then
            yT_1, yS_1 = identifyexecutor()
            local yU = yT_1 ~= ""
            local yV = type(yT_1) == "string" and yU
            if yV then
                local yU_1 = type(yS_1) == "string" and yS_1 ~= "" and yT_1 .. " " .. yS_1
                local yS_2 = yU_1
                local yZ = if yS_2 then 1 else 0
                local yX = 649 * yZ + 1878 * (1 - yZ)
                local yY = 3621 * yZ + 360 * (1 - yZ)
                if not ((yX * 3862 + yY * 1430 + yX * yY) % 16777213 == 10034497) then
                    yS_2 = yT_1
                end
                zb = yS_2
            end
        end
    end)
    local zc = qt()
    y7 = os.clock()
    za = function()
        local y_ = math.floor(os.clock() - y7)
        if y_ < 60 then
            return y_ .. "s"
        elseif y_ < 3600 then
            return string.format("%dm %ds", math.floor((y_) / (60)), y_ % 60)
        else
            return string.format("%dh %dm", math.floor((y_) / (3600)), math.floor((y_ % 3600) / (60)))
        end
    end
    local UserGroup = qo.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(pW("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, rj), true)
    UserGroup:AddLabel(pW("UserId", tostring(LocalPlayer.UserId), rf), true)
    UserGroup:AddLabel(pW("Executor", zb .. "  " .. zc, rj), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(pW("Session", za(), rb), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            qA(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            qA("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = qo.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(pW("Game", qy, rf), true)
    Label2 = SessionGroup:AddLabel(pW("Players", "0/0", rj), true)
    y9 = tostring(game.JobId)
    local zd_1 = #y9 > 18 and string.sub(y9, 1, 18) .. "..."
    local ze = zd_1
    local zi = if ze then 1 else 0
    local zg = 2470 * zi + 2399 * (1 - zi)
    local zh = 834 * zi + 1211 * (1 - zi)
    if not ((zg * 4025 + zh * 975 + zg * zh) % 16777213 == 12814880) then
        ze = y9
    end
    local zd_2 = ze
    SessionGroup:AddLabel(pW("Job", zd_2, q7), true)
    Label = SessionGroup:AddLabel(pW("Ping", "0 ms", rb), true)
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
            qA(y9, "Copied Job ID")
        end
    })
    task.spawn(function()
        local y2_1
        local y1_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(pW("Session", za(), rb))
            Label2:SetText(pW("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), rj))
            y1_1, y2_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local y1_2 = y1_1 and y2_1 .. " ms" or "n/a"
            Label:SetText(pW("Ping", y1_2, rb))
        end
    end)
    local SocialsGroup = qo.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = ql })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            qA(qr, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            qA(qp, "Copied website link")
        end
    })
end
A8_22_1()
local function A8_1()
    local connection
    local MovementGroup = qo.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = qo.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function jV(jW)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not jW)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not jW
            end
        end)
        if not jW then
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
    local function j8(j9)
        if not j9:IsA("ProximityPrompt") then
            return
        end
        j9.HoldDuration = 0
        j9.MaxActivationDistance = 50
        j9.RequiresLineOfSight = false
    end
    connection = nil
    p6(rg.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local zo_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if zo_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    p6(rc.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local zw_1 = qw()
            if zw_1 then
                zw_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local CurrentCamera = Workspace.CurrentCamera
    p6(rg.RenderStepped:Connect(function(kx)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local zy_1 = qw()
            if zy_1 then
                zy_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local zy_3 = qh()
            local zz = qw()
            if zy_3 and zz then
                zz.PlatformStand = true
                local zz_1 = Vector3.zero
                local zH = if rc:IsKeyDown(Enum.KeyCode.W) then 1 else 0
                if zH == 1 then
                    zz_1 += CurrentCamera.CFrame.LookVector
                end
                if rc:IsKeyDown(Enum.KeyCode.S) then
                    zz_1 -= CurrentCamera.CFrame.LookVector
                end
                if rc:IsKeyDown(Enum.KeyCode.A) then
                    zz_1 -= CurrentCamera.CFrame.RightVector
                end
                if rc:IsKeyDown(Enum.KeyCode.D) then
                    zz_1 += CurrentCamera.CFrame.RightVector
                end
                if rc:IsKeyDown(Enum.KeyCode.Space) then
                    zz_1 += Vector3.new(0, 1, 0)
                end
                if rc:IsKeyDown(Enum.KeyCode.LeftControl) then
                    zz_1 -= Vector3.new(0, 1, 0)
                end
                zy_3.AssemblyLinearVelocity = Vector3.zero
                if zz_1.Magnitude > 0 then
                    zy_3.CFrame = zy_3.CFrame + zz_1.Unit * Options.FlySpeed.Value * kx
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local zI = qw()
            if zI then
                zI.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local zK = qw()
            if zK then
                zK.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        jV(Toggles.AntiGameplayPause.Value)
    end)
    jV(true)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in Workspace:GetDescendants() do
                pcall(j8, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(k0)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(j8, k0)
                end
            end)
            p6(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                jV(true)
            end
        end
    end)
    return jV, function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end
qq, qi = A8_1()
local function A8_11(lb)
    local lc = 0
    local ld = tick()
    lb:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = lb:AddLabel("AFK triggers: 0")
    local function lf()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        q8:CaptureController()
        q8:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        lc += 1
        ld = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. lc)
        end)
    end
    local connection = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(lf)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local z7 = Toggles.AntiAfk.Value and tick() - ld >= 60
            if z7 then
                pcall(lf)
            end
        end
    end)
    lb:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    return connection
end
local MenuGroup = qo.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
p0 = A8_11(MenuGroup)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(qo.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/SwordFightingEscape")
local A8_26_2 = SaveManager:BuildConfigSection(qo.Settings)
SaveManager:LoadAutoloadConfig()
local function A8_7_3(lG)
    local function lH(lI, lJ)
        local Aa_1 = (lI == "Toggle" and Toggles or Options)[lJ]
        local z9_2 = type(Aa_1) == "table" and Aa_1.Type == lI
        return z9_2 and Aa_1 or nil
    end
    local function lR(lS, lT)
        local Type = lT.Type
        if Type == "Toggle" then
            return { idx = lS, type = "Toggle", value = lT.Value == true }
        elseif Type == "Slider" then
            return { idx = lS, type = "Slider", value = tostring(lT.Value) }
        elseif Type == "Dropdown" then
            return { idx = lS, type = "Dropdown", multi = lT.Multi == true, value = lT.Value }
        elseif Type == "Input" then
            local Ah = lT.Value or ""
            return { idx = lS, type = "Input", text = tostring(Ah) }
        elseif Type == "ColorPicker" then
            return { idx = lS, type = "ColorPicker", value = lT.Value:ToHex(), transparency = lT.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = lS,
                type = "KeyPicker",
                mode = lT.Mode,
                key = lT.Value,
                modifiers = lT.Modifiers,
                toggled = lT.Toggled
            }
        else
            return nil
        end
    end
    local function lV()
        local An = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local Ao = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if Ao then
                    local Ao_1 = lR(k, v)
                    if Ao_1 then
                        An[#An + 1] = Ao_1
                    end
                end
            end
        end
        table.sort(An, function(l2, l3)
            if l2.type ~= l3.type then
                return l2.type < l3.type
            end
            return l2.idx < l3.idx
        end)
        return { objects = An }
    end
    local function l4(l5)
        local AE
        AE = nil
        local AF = type(l5) ~= "table" or type(l5.idx) ~= "string" or type(l5.type) ~= "string"
        local AJ = if AF then 1 else 0
        local AH = 3918 * AJ + 565 * (1 - AJ)
        local AI = 2671 * AJ + 2269 * (1 - AJ)
        if not ((AH * 3662 + AI * 639 + AH * AI) % 16777213 == 9742250) then
            AF = SaveManager.Ignore[l5.idx]
        end
        if AF then
            return false
        end
        AE = lH(l5.type, l5.idx)
        if not AE then
            return false
        end
        local AF_1 = pcall(function()
            if l5.type == "Input" then
                if type(l5.text) ~= "string" then
                    return
                end
                AE:SetValue(l5.text)
            elseif l5.type == "ColorPicker" then
                AE:SetValueRGB(Color3.fromHex(l5.value), l5.transparency)
            elseif l5.type == "KeyPicker" then
                AE:SetValue({ l5.key, l5.mode, l5.modifiers })
                if l5.mode == "Toggle" and l5.toggled ~= nil then
                    AE.Toggled = l5.toggled
                    AE:Update()
                end
            else
                AE:SetValue(l5.value)
            end
        end)
        return AF_1
    end
    lG:AddDivider()
    lG:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    lG:AddButton("Export Config to Clipboard", function()
        local AL_1
        local AK_1
        AK_1, AL_1 = pcall(HttpService.JSONEncode, HttpService, lV())
        if not AK_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local AK_2 = setclipboard or toclipboard
        local AK_3 = type(AK_2) ~= "function" or not pcall(AK_2, AL_1)
        if AK_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    lG:AddButton("Import Config from ClipboardText", function()
        local AQ_1
        local AO = Options.SaveManager_ImportSource.Value or ""
        local AO_1
        local AP = tostring(AO):match("^%s*(.-)%s*$")
        if AP == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        AO_1, AQ_1 = pcall(HttpService.JSONDecode, HttpService, AP)
        local AP_1 = not AO_1 or type(AQ_1) ~= "table" or type(AQ_1.objects) ~= "table"
        if AP_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local AO_2 = 0
        for k, v in AQ_1.objects do
            if l4(v) then
                AO_2 += 1
            end
        end
        if AO_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local AQ_2 = AO_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(AO_2, AQ_2), 6)
    end)
end
A8_7_3(A8_26_2)
Library:OnUnload(function()
    pY()
    pcall(function()
        SwingInput.setAutoFightEnabled(false)
    end)
    qq(false)
    qi()
    if p0 then
        p0:Disconnect()
    end
    for k, v in qb do
        local A4 = v
        pcall(function()
            A4:Disconnect()
        end)
    end
    table.clear(qb)
    local AY = qw()
    if AY then
        AY.PlatformStand = false
        AY.WalkSpeed = 16
    end
end)
end)(...)
