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
getgenv().TempoHoodSubtitle = "+1 SLASH PER CLICK!"
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
local rF
local r3
local rL
local ss
local rs
local r9
local rR
local ry
local sf
local rX
local rE
local sl
local r2
local rK
local sr
local rr
local r8
local rQ
local rx
local rW
local rD
local rJ
local sq
local rq
local rP
local sw
local rw
local sd
local rV
local rC
local sj
local r0
local sp
local rp
local r6
local rO
local sv
local rv
local sc
local LocalPlayer
local rB
local si
local r_
local rH
local so
local ro
local r5
local rN
local su
local ru
local sb
local rT
local rA
local sh
local rZ
local rG
local sn
local rn
local r4
local rM
local st
local rt
local sa
local rS
local rz
local sg
local rY
local function worker2()
    while not rF.Unloaded do
        if rY.Enabled.BestPets then
            sa:FireServer("EquipBest")
            task.wait(2.2)
        else
            task.wait(0.5)
        end
    end
end
local function fn41()
    return math.floor(r8(sl(), "Rebirths"))
end
local function fn68()
    return LocalPlayer:FindFirstChild("NumericStats")
end
local function worker5()
    while not rF.Unloaded do
        local xf = rY.Enabled.Train and not rv()
        if xf then
            local xf_1 = rT[rY.TrainLabel]
            if r9(xf_1) then
                if ro() ~= xf_1.Index then
                    local xg = ss(ro())
                    if xg and xg.Index ~= xf_1.Index then
                        r6()
                        task.wait(0.35)
                        if rF.Unloaded or not rY.Enabled.Train then
                            continue
                        end
                        so(xf_1)
                        task.wait(0.45)
                        continue
                    end
                    so(xf_1)
                    task.wait(0.45)
                    continue
                end
                task.wait(0.6)
                continue
            end
            task.wait(0.4)
            continue
        end
        task.wait(0.3)
    end
end
local function fn93()
    while not rF.Unloaded do
        if rY.Enabled.Rebirth then
            local xn = rN.GetRebirthLevel(rW())
            if rD() >= xn then
                rp:FireServer()
                task.wait(1.2)
            else
                task.wait(0.45)
            end
        else
            task.wait(0.4)
        end
    end
end
local function fn115(fC)
    local wt_1
    local wu_1, wu_4
    if not fC then
        return false
    elseif ro() == fC.Index then
        return true
    else
        wu_1, wt_1 = rP(fC)
        local wv = not wu_1
        if wv ~= false then
            wv = wt_1
        end
        if wv then
            ry(sj(wt_1))
            rJ(wt_1)
            task.wait(0.35)
            if rF.Unloaded then
                return false
            end
            local wu_2 = select(1, rP(fC))
            if not wu_1 then
                return false
            end
            sr(wu_2)
            task.wait(0.15)
            if rF.Unloaded then
                return false
            end
            local wt_2 = rz(wu_2)
            local wu_3 = wt_2 and ro() ~= fC.Index
            if wu_4 then
                rM(wt_2)
            end
            return true
        elseif not wu_1 then
            return false
        else
            sr(wu_1)
            task.wait(0.15)
            if rF.Unloaded then
                return false
            end
            local wt_3 = rz(wu_1)
            wu_4 = wt_3 and ro() ~= fC.Index
            if wu_4 then
                rM(wt_3)
            end
            return true
        end
    end
end
local function fn122()
    local PunchEscapePersonalWalls = r3:FindFirstChild("PunchEscapePersonalWalls")
    local uw = PunchEscapePersonalWalls and rB(PunchEscapePersonalWalls)
    local uv_1 = uw
    local uA = if uv_1 then 1 else 0
    local uy = 226 * uA + 1256 * (1 - uA)
    local uz = 2764 * uA + 3661 * (1 - uA)
    if not ((uy * 1717 + uz * 2434 + uy * uz) % 16777213 == 7740282) then
        uv_1 = nil
    end
    return uv_1
end
local function fn138(P)
    return type(P) == "function"
end
local function worker()
    while not rF.Unloaded do
        local xw = rY.Enabled.Lucky and not rv()
        if xw then
            local xw_1 = sb[rY.LuckyLabel]
            local LuckyAmount = rY.LuckyAmount
            local xy = xw_1 and not su()
            if xy then
                local xy_1 = rE.GetWinsCost(xw_1.Station, LuckyAmount)
                local xz = sc()
                local xA = tonumber(xy_1) or math.huge
                if xz >= xA then
                    sh:FireServer(xw_1.Station, "Wins", LuckyAmount)
                    task.wait(0.35)
                end
            end
            task.wait(0.45)
        else
            task.wait(0.4)
        end
    end
end
local function fn191(aR, aS)
    local ty = aR and aR:FindFirstChild(aS)
    local tz = ty
    if ty then
        ty = tonumber(tz.Value)
    end
    local tz_1 = ty
    local tD = if tz_1 then 1 else 0
    local tB = 827 * tD + 2572 * (1 - tD)
    local tC = 3421 * tD + 3136 * (1 - tD)
    if not ((tB * 1491 + tC * 3155 + tB * tC) % 16777213 == 14855479) then
        tz_1 = 0
    end
    return tz_1
end
local function fn203(eD)
    if not eD then
        return false
    elseif eD.GamePassId then
        return sn(eD.GamePassId)
    else
        return rW() >= eD.Rebirths
    end
end
local function fn207()
    while not rF.Unloaded do
        local xd = rY.Enabled.Click and not rv()
        if xd then
            rS()
            task.wait(0.08)
        else
            task.wait(0.2)
        end
    end
end
local function fn217()
    local v7 = sc()
    for i, v in ipairs(rN.Auras) do
        local v8 = type(v) == "table" and not r_(i)
        if v8 then
            local v8_1 = tonumber(v.Cost) or 0
            if v8_1 <= v7 then
                return i
            end
            return nil
        end
    end
end
local function fn219(ch)
    local uo_1
    local un_1
    local um_1
    un_1, um_1, uo_1 = sg()
    local um_2 = uo_1 and ch and ch:IsA("BasePart")
    if not um_2 then
        return false
    end
    if sd then
        pcall(sd, ch, uo_1, 1)
        pcall(sd, ch, uo_1, 0)
    end
    return true
end
local function fn222(c3)
    local uO, uQ, uR, uT, uV, uW
    local uN = 10
    while true do
        local uN_1 = 4321 - uN
        do
            if uN_1 < 4314 then
                if uN_1 < 4312 then
                    if uN_1 < 4311 then
                        if uN_1 < 4309 then
                            if uN_1 < 2892 then
                                break
                            elseif uN_1 < 4308 then
                                break
                            else
                                uN = if not rV(uR, uW) then 3 else 1
                            end
                        elseif uN_1 < 4310 then
                            break
                        elseif uN_1 == 4310 then
                            uV += 1
                            uN = 8
                        else
                            uN = 4313
                            continue
                        end
                    else
                        uQ = 1
                        uO = c3
                        uN = 4
                    end
                elseif uN_1 < 4313 then
                    uW = uV
                    uN = 13
                else
                    uN = if uV <= uT then 9 else 7
                end
            elseif uN_1 < 4320 then
                if uN_1 < 4319 then
                    if uN_1 < 4316 then
                        if uN_1 < 4315 then
                            uN = 0
                        elseif uN_1 == 4315 then
                            uR = uQ
                            uN = 2
                        else
                            uN = 4312
                            continue
                        end
                    elseif uN_1 < 4317 then
                        uN = 12
                    elseif uN_1 < 4318 then
                        uN = if uQ <= uO then 6 else 5
                    elseif uN_1 == 4318 then
                        return rw(uR, uW), uR, uW
                    else
                        uN = 4320
                        continue
                    end
                elseif uN_1 == 4319 then
                    uV = 1
                    uT = rQ
                    uN = 8
                else
                    uN = 4308
                    continue
                end
            elseif uN_1 < 4321 then
                if uN_1 == 4320 then
                    uN = 11
                else
                    uN = 4317
                    continue
                end
            elseif uN_1 < 5427 then
                if uN_1 == 4321 then
                    uQ += 1
                    uN = 4
                else
                    break
                end
            else
                break
            end
        end
    end
end
local function fn283()
    while not rF.Unloaded do
        local w9 = if not rv() then 1 else 0
        if w9 == 1 then
            task.wait(0.25)
            continue
        end
        local clamp = math.clamp
        local floor = math.floor
        local w5 = tonumber(rY.Stage) or 1
        local w4_1 = clamp(floor(w5), 1, rL)
        local w3_1 = r5(w4_1)
        if w3_1 then
            local w5_1 = rr(w3_1)
            if w5_1 then
                ry(w5_1)
            end
            local w5_2 = rF.Unloaded
            local xc = if w5_2 then 1 else 0
            local xa = 3076 * xc + 3291 * (1 - xc)
            local xb = 2176 * xc + 3492 * (1 - xc)
            if not ((xa * 1180 + xb * 2984 + xa * xb) % 16777213 == 39027) then
                w5_2 = not rv()
            end
            if w5_2 then
                continue
            end
            rR(w3_1.Position)
            local wait = task.wait
            local w5_3 = rN.PunchInterval or 0.5
            wait(w5_3)
            continue
        end
        si(w4_1)
        task.wait(0.45)
    end
end
local function fn295()
    return LocalPlayer:FindFirstChild("PlayerStats")
end
local function fn303()
    return math.floor(r8(rn(), "Level"))
end
local function fn324(eH)
    local vO = rN.GetWorldForFist(eH) or 1
    local vO_1 = sq(vO)
    local vQ = vO_1 and vO_1:FindFirstChild("Fists")
    local vO_2 = vQ
    if vQ then
        vQ = vO_2:FindFirstChild("Fist " .. tostring(eH))
    end
    local vO_3 = vQ
    if vQ then
        vQ = vO_3:IsA("BasePart")
    end
    if vQ then
        return vO_3
    end
    local vO_4 = sq(1)
    local vQ_1 = vO_4 and vO_4:FindFirstChild("Fists")
    local vO_5 = vQ_1
    if vQ_1 then
        vQ_1 = vO_5:FindFirstChild("Fist " .. tostring(eH))
    end
    local vO_6 = vQ_1
    if vQ_1 then
        vQ_1 = vO_6:IsA("BasePart")
    end
    if vQ_1 then
        return nil, vO_6.Position + sf(vO)
    end
end
local function fn330()
    sp:FireServer()
end
local function fn356()
    local wA = ss(ro())
    if not wA then
        return
    end
    local wB = select(1, rP(wA))
    local wA_1 = rz(wB)
    if wA_1 then
        rM(wA_1)
    end
end
local function fn381(ei)
    if not ei then
        return nil
    end
    local vz = sq(ei.World)
    local vA = vz and vz:FindFirstChild("Train")
    local vz_1 = vA
    if vA then
        vA = vz_1:FindFirstChild("Train" .. tostring(ei.LocalIndex))
    end
    local vz_2 = vA
    if vA then
        vA = vz_2:IsA("BasePart")
    end
    if vA then
        return vz_2
    end
    local vz_3 = sq(1)
    local vA_1 = vz_3 and vz_3:FindFirstChild("Train")
    local vz_4 = vA_1
    if vA_1 then
        vA_1 = vz_4:FindFirstChild("Train" .. tostring(ei.LocalIndex))
    end
    local vz_5 = vA_1
    if vA_1 then
        vA_1 = vz_5:IsA("BasePart")
    end
    if vA_1 then
        return nil, vz_5.Position + sf(ei.World)
    end
end
local function fn382()
    for k, v in r0 do
        pcall(task.cancel, v)
    end
end
local function fn438(M)
    local tw = typeof(cloneref) == "function" and typeof(M) == "Instance"
    if tw then
        return cloneref(M)
    end
    return M
end
local function fn449(e3)
    local OwnedAuras = LocalPlayer:FindFirstChild("OwnedAuras")
    return rA(OwnedAuras, "Aura" .. tostring(e3))
end
local function fn511(aX, aY)
    local tE = aX and aX:FindFirstChild(aY)
    local tF = tE
    if tE then
        tE = tF.Value == true
    end
    return tE
end
local function fn518(ex)
    local vC = ex and ex:FindFirstChild("AFKPrompt")
    return vC
end
local function fn551()
    return r8(sl(), "Wins")
end
local function worker4()
    while not rF.Unloaded do
        if rY.Enabled.BuyAura then
            local xp = ru()
            if xp then
                st:FireServer("AuraWins", xp)
                task.wait(0.8)
            else
                task.wait(0.6)
            end
        else
            task.wait(0.4)
        end
    end
end
local function fn591(da)
    if not da then
        return nil
    end
    local Size = da.Size
    local uZ = da.CFrame.RightVector
    if Size.Z >= Size.X then
        uZ = da.CFrame.LookVector
    end
    local uY_1 = sq(1)
    local u_ = uY_1 and uY_1:FindFirstChild("Train")
    local uY_2 = u_
    if u_ then
        u_ = uY_2:FindFirstChild("Train1")
    end
    local uY_3 = u_
    if u_ then
        u_ = uY_3:IsA("BasePart")
    end
    if u_ then
        local u__1 = Vector3.new(uY_3.Position.X - da.Position.X, 0, uY_3.Position.Z - da.Position.Z)
        local uY_4 = u__1.Magnitude > 0.1 and uZ:Dot(u__1.Unit) < 0
        if uY_4 then
            uZ = -uZ
        end
    end
    return sj(da.Position + uZ.Unit * 8)
end
local function fn597()
    local vh_1
    local vg_1
    local vf_1
    vg_1, vf_1, vh_1 = sg()
    if not vh_1 then
        return false
    end
    local vf_2 = rZ()
    if vf_2 then
        local vg_2 = (tonumber(rN.MaximumWallPunchDistance))
        local vm = if vg_2 then 1 else 0
        local vk = 761 * vm + 3912 * (1 - vm)
        local vl = 1592 * vm + 51 * (1 - vm)
        if not ((vk * 3726 + vl * 2226 + vk * vl) % 16777213 == 7590790) then
            vg_2 = 90
        end
        local vi = vg_2
        for i, child in vf_2:GetChildren() do
            local vf_3 = child:IsA("BasePart") and child:GetAttribute("PersonalWall") == true and child.CanQuery and child.Transparency < 1
            if vf_3 then
                local WallStatus = child:FindFirstChild("WallStatus")
                local vg_3 = WallStatus and WallStatus:IsA("SurfaceGui") and WallStatus.Enabled and (child.Position - vh_1.Position).Magnitude <= vi
                if vg_3 then
                    return rR(child.Position)
                end
            end
        end
    end
    return rR(vh_1.Position + vh_1.CFrame.LookVector * 12)
end
local function fn625(gl)
    local wZ = tonumber(gl)
    if wZ == 1 or wZ == 3 or wZ == 6 then
        rY.LuckyAmount = wZ
    end
end
local function fn642(gi)
    if sb[gi] then
        rY.LuckyLabel = gi
    end
end
local function fn644(cL, cM)
    local uB = rZ()
    local uC = uB and uB:FindFirstChild("Stage" .. tostring(cL) .. "Wall" .. tostring(cM))
    local uB_1 = uC
    if uC then
        uC = uB_1:IsA("BasePart")
    end
    if uC then
        return uB_1
    end
end
local function fn717(b1)
    local Character = LocalPlayer.Character
    local uf = RaycastParams.new()
    uf.FilterType = Enum.RaycastFilterType.Exclude
    if Character then
        uf.FilterDescendantsInstances = { Character }
    end
    local ue_1 = b1.Y + 8
    local ug = r3:Raycast(Vector3.new(b1.X, ue_1, b1.Z), Vector3.new(0, -80, 0), uf)
    if ug then
        return ug.Position + Vector3.new(0, 3, 0)
    end
    return Vector3.new(b1.X, b1.Y, b1.Z)
end
local function fn732()
    return rY.Enabled.Farm == true and not rF.Unloaded
end
local function fn742(f3, f4)
    local wM = f4 == true
    if f3 == "Train" and rY.Enabled.Train and not wM then
        r6()
    end
    rY.Enabled[f3] = wM
end
local function fn756()
    local PlayerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    local wH = PlayerScripts and PlayerScripts:FindFirstChild("LuckyBlockCinematicClient")
    local wG_1 = wH
    if wH then
        wH = wG_1:GetAttribute("Busy") == true
    end
    return wH
end
local function fn766()
    return math.floor(r8(rn(), "AFKPad"))
end
local function fn770(eA)
    local vF = (tonumber(eA))
    local vJ = if vF then 1 else 0
    local vH = 1050 * vJ + 1044 * (1 - vJ)
    local vI = 3134 * vJ + 4093 * (1 - vJ)
    if not ((vH * 2326 + vI * 3628 + vH * vI) % 16777213 == 325939) then
        vF = 0
    end
    eA = math.floor(vF)
    if eA < 1 then
        return nil
    end
    return r2[eA]
end
local function fn799(dF)
    local vb = sc()
    local vc = os.clock() + 8
    while true do
        local vd = not rF.Unloaded and rv() and os.clock() < vc
        if not vd then
            return sc() > vb
        end
        if not rq(dF) then
            return false
        end
        local vd_1 = sw(dF)
        if vd_1 then
            sr(vd_1)
        else
            local vd_2 = rw(dF, rQ)
            if vd_2 then
                rJ(vd_2.Position + Vector3.new(-12, 0, 0))
            end
        end
        if sc() > vb then
            break
        end
        task.wait(0.2)
    end
    return true
end
local function fn828()
    local Character = LocalPlayer.Character
    local tI = Character and Character:FindFirstChildOfClass("Humanoid")
    local tJ = Character
    if tJ then
        tJ = Character:FindFirstChild("HumanoidRootPart")
    end
    local tI_1 = Character
    local tL = tJ
    if tI_1 then
        tI_1 = tI
    end
    if tI_1 then
        tI_1 = tL
    end
    if tI_1 then
        tI_1 = tI.Health > 0
    end
    if tI_1 then
        return Character, tI, tL
    end
end
local function fn884(dp)
    local u7 = rN.GetWorldForStage(dp)
    local u8 = sq(u7)
    local u7_1 = u8
    if u7_1 then
        local u9 = u8:FindFirstChild("Destructable walls") or u8:FindFirstChild("Destructable Walls")
        u7_1 = u9
    end
    local u8_1 = u7_1
    if u7_1 then
        u7_1 = u8_1:FindFirstChild("Stage" .. tostring(dp))
    end
    local u8_2 = u7_1
    if u7_1 then
        u7_1 = u8_2:FindFirstChild("WinPart")
    end
    local u8_3 = u7_1
    if not u8_3 then
        return nil
    end
    local u7_2 = u8_3:FindFirstChild("x1 Win") or u8_3:FindFirstChildWhichIsA("BasePart")
    return u7_2
end
local function fn888(cu)
    local ut_1
    local us_1
    if typeof(cu) ~= "Vector3" then
        return false
    elseif ro() > 0 then
        return false
    else
        us_1, ut_1 = sg()
        if not ut_1 or ut_1.Health <= 0 then
            return false
        end
        local us_3 = tonumber(rN.PunchInterval) or 0.5
        local us_4 = os.clock()
        if us_4 - rY.LastPunch < us_3 then
            return false
        end
        rY.LastPunch = us_4
        rt:FireServer(cu)
        return true
    end
end
local function fn906()
    local vV = sc()
    local vW
    local vX = -1
    for k, v in rN.Fists do
        local vY = type(k) == "number" and type(v) == "table" and not sv(k)
        if vY then
            local vY_1 = tonumber(v.Cost) or 0
            local vY_2 = tonumber(v.Power) or 0
            if vY_1 <= vV and vY_2 > vX then
                vX = vY_2
                vW = k
            end
        end
    end
    return vW
end
local function fn909(cp)
    local uq = cp and cp:IsA("BasePart")
    if not uq then
        return false
    end
    ry(cp.Position + Vector3.new(0, 3, 0))
    rX(cp)
    return true
end
local function fn941()
    return { Stages = rG, Train = rO, Lucky = r4, LuckyAmounts = rs }
end
local function fn955(cT, cU)
    local uE = rw(cT, cU)
    if not uE then
        return true
    end
    return uE.Transparency >= 1 and uE.CanQuery == false
end
local function fn1025()
    rY.Enabled.Click = false
    rY.Enabled.Farm = false
    rY.Enabled.Rebirth = false
    rY.Enabled.Train = false
    rY.Enabled.BuyAura = false
    rY.Enabled.BuyPower = false
    rY.Enabled.BestPets = false
    rY.Enabled.Lucky = false
end
local function fn1044(cZ)
    local uK = 1
    local uI = rQ
    while uK <= uI do
        local uL = uK
        if not rV(cZ, uL) then
            return false
        end
        uK += 1
    end
    return true
end
local function fn1046(eZ)
    local OwnedFists = LocalPlayer:FindFirstChild("OwnedFists")
    return rA(OwnedFists, "Fist" .. tostring(eZ))
end
local function fn1049(bQ)
    local WorldOffset = rN.WorldOffset
    local max = math.max
    local t7 = tonumber(bQ) or 1
    local t5_1 = max(1, math.floor(t7)) - 1
    if typeof(WorldOffset) == "Vector3" then
        return WorldOffset * t5_1
    end
    return Vector3.new(0, 0, 2500 * t5_1)
end
local function fn1067(gf)
    if rT[gf] then
        rY.TrainLabel = gf
    end
end
local function worker3()
    local xs_1
    local xt_1
    while not rF.Unloaded do
        local xr = rY.Enabled.BuyPower and not rv()
        if xr then
            local xr_1 = rx()
            if xr_1 then
                xt_1, xs_1 = rK(xr_1)
                local xu = not xt_1
                if xu ~= false then
                    xu = xs_1
                end
                if xu then
                    ry(sj(xs_1))
                    rJ(xs_1)
                    task.wait(0.4)
                    if rF.Unloaded then
                        break
                    end
                    local xt_2 = select(1, rK(xr_1))
                    if xt_1 then
                        sr(xt_2)
                        local xr_2 = rH(xt_2, "FistPrompt", 2)
                        rM(xr_2)
                    end
                    task.wait(0.9)
                    continue
                end
                if xt_1 then
                    sr(xt_1)
                    local xr_3 = rH(xt_1, "FistPrompt", 2)
                    rM(xr_3)
                end
                task.wait(0.9)
                continue
            end
            task.wait(0.7)
            continue
        end
        task.wait(0.4)
    end
end
local function fn1075(b9)
    local uk_1
    local uj_1
    local ui_1
    ui_1, uk_1, uj_1 = sg()
    local ui_2 = uj_1 and typeof(b9) == "Vector3"
    if not ui_2 then
        return false
    end
    rJ(b9)
    uj_1.CFrame = CFrame.new(b9)
    uj_1.AssemblyLinearVelocity = Vector3.zero
    if uk_1 then
        uk_1:ChangeState(Enum.HumanoidStateType.Running)
    end
    return true
end
local function fn1081(f9)
    local wU = rC[f9] or tonumber(f9)
    if type(wU) == "number" then
        rY.Stage = math.clamp(math.floor(wU), 1, rL)
    end
end
rn = nil
ro = nil
rp = nil
rq = nil
rr = nil
rs = nil
rt = nil
ru = nil
rv = nil
rw = nil
rx = nil
ry = nil
rz = nil
rA = nil
rB = nil
rC = nil
rD = nil
rE = nil
rF = nil
rG = nil
rH = nil
rJ = nil
rK = nil
rL = nil
rM = nil
rN = nil
rO = nil
rP = nil
rQ = nil
rR = nil
rS = nil
rT = nil
LocalPlayer = nil
rV = nil
rW = nil
rX = nil
rY = nil
rZ = nil
r_ = nil
r0 = nil
r2 = nil
r3 = nil
r4 = nil
r5 = nil
r6 = nil
r8 = nil
local Players, rI, r1, r7
r9 = nil
sa = nil
sb = nil
sc = nil
sd = nil
sf = nil
sg = nil
sh = nil
si = nil
sj = nil
sl = nil
sn = nil
so = nil
sp = nil
sq = nil
sr = nil
ss = nil
st = nil
su = nil
sv = nil
sw = nil
local se, sk, sm, sx, sD, sE, sF, sG
local sC_1, sC_2
local sz_1, sz_7
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, sC_1, sk, se, r7, r3, LocalPlayer, rF, sm, rB, sx = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
if ((not sC_1 and sC_1 and (not se and se) or sC_1 and sC_1 and (rF and not rF)) and (se and not rF and (sC_1 and not sC_1) and (not se or not se or (se or not se))) or (not se or not rF) and (not rF and not se) and (not rF and rF or (sC_1 or se)) and ((not se or not sC_1) and (not se or rF) and (se or not se or (not rF or not se)))) and not ((not sC_1 and sC_1 and (not se and se) or sC_1 and sC_1 and (rF and not rF)) and (se and not rF and (sC_1 and not sC_1) and (not se or not se or (se or not se))) or (not se or not rF) and (not rF and not se) and (not rF and rF or (sC_1 or se)) and ((not se or not sC_1) and (not se or rF) and (se or not se or (not rF or not se)))) then
    r7 = game:GetService("ReplicatedStorage")
    se = game:GetService("RunService")
    sC_2 = game:GetService("HttpService")
    r3 = game:GetService("MarketplaceService")
    sk = game:GetService("Workspace")
else
    sC_2 = game:GetService("ReplicatedStorage")
    sk = game:GetService("RunService")
    se = game:GetService("HttpService")
    r7 = game:GetService("MarketplaceService")
    r3 = game:GetService("Workspace")
end
LocalPlayer = Players.LocalPlayer
local function sy(l)
    local tl
    local tm
    local tk
    tk = nil
    tl = nil
    tm = nil
    local tn = l ~= ""
    local to = type(l) == "string" and tn
    assert(to, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    tk = getgenv()
    assert(type(tk) == "table", "getgenv did not return a table")
    local tn_1 = tk[l]
    if tn_1 ~= nil then
        local to_1 = type(tn_1) == "table" and type(tn_1.Unload) == "function"
        assert(to_1, "Namespace is occupied")
        tn_1.Unload()
        assert(tk[l] == nil, "Previous instance did not release its namespace")
    end
    tl = {}
    tm = { State = {}, Unloaded = false }
    tm.Track = function(r)
        assert(type(r) == "function", "Cleanup must be callable")
        if tm.Unloaded then
            r()
        else
            table.insert(tl, r)
        end
        return r
    end
    tm.Unload = function()
        local ta_1
        local s9_1
        if tm.Unloaded then
            return
        end
        tm.Unloaded = true
        local s7 = {}
        local te = #tl
        local td = -1
        while false and te <= 1 or true and te >= 1 do
            local tf = te
            local s8_1 = table.remove(tl, tf)
            s9_1, ta_1 = pcall(s8_1)
            if not s9_1 then
                table.insert(s7, tostring(ta_1))
            end
            te += td
        end
        table.clear(tm.State)
        if #s7 > 0 then
            error("Cleanup incomplete: " .. table.concat(s7, "; "), 0)
        end
        if tk[l] == tm then
            tk[l] = nil
        end
    end
    tk[l] = tm
    return tm
end
sm = function(E, F)
    local tu = type(E) == "table" and type(E.Track) == "function"
    assert(tu, "FeatureAPI required")
    local tu_1 = type(F) == "table" and type(F.OnUnload) == "function"
    assert(tu_1, "UI library required")
    assert(type(F.Unload) == "function", "UI unload required")
    E.Track(function()
        if not F.Unloaded then
            F:Unload()
        end
    end)
    F:OnUnload(function()
        E.Unload()
    end)
end
rF = sy("TempoSlashPerClick")
rB = fn438
sx = fn138
local sB = sx(firetouchinterest) and firetouchinterest
local sy_1 = sB or nil
sd = nil
sd = sy_1
local sA = sx(fireproximityprompt) and fireproximityprompt
local sy_2 = sA or nil
r1, sB, rN, rI, rE, sz_1, rt, rp, st, sp, sh, sa, rY, rQ, rL, rG, rC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sA = 7
repeat
    sD = (sA * 8 + 2) % 9 + 1
    if sD <= 5 then
        if sD <= 3 then
            if sD <= 2 then
                if sD <= 1 then
                    sE = (vector.create((sA * 2 + 1) % 11 + 1, (sA * 8 + 1) % 13 + 1, (sA * 8 + 7) % 17 + 1))
                    sF = (vector.create((sA * 5 + 1) % 11 + 1, (sA * 7 + 7) % 13 + 1, (sA * 6 + 5) % 17 + 1))
                    sG = (vector.create((sA * 5 + 7) % 11 + 1, (sA * 8 + 10) % 13 + 1, (sA * 1 + 10) % 17 + 1))
                    if vector.dot(vector.cross(sE, sF), sG) == vector.dot(vector.cross(sF, sG), sE) then
                        sz_1 = rB(sB:WaitForChild("PunchEscapeRemotes"))
                        rt = rB(sz_1:WaitForChild("PunchRequest"))
                        rp = rB(sz_1:WaitForChild("RebirthRequest"))
                        st = rB(sz_1:WaitForChild("PurchaseRequest"))
                        sp = rB(sz_1:WaitForChild("WallSyncRequest"))
                    else
                        st = sp(rB:WaitForChild("PunchEscapeRemotes"))
                        sz_1 = sp(st:WaitForChild("PunchRequest"))
                        rt = sp(st:WaitForChild("RebirthRequest"))
                        rp = sp(st:WaitForChild("PurchaseRequest"))
                        sB = sp(st:WaitForChild("WallSyncRequest"))
                    end
                    sA = (sA + 8) % 36
                else
                    if (not rp or not sA or (st or not sA)) and ((not rG or rp) and (sA and not rp)) and not ((not rp or not sA or (st or not sA)) and ((not rG or rp) and (sA and not rp))) then
                        rY = sa(rB:WaitForChild("LuckyBlockOpenRequest"))
                        sh = sa(rB:WaitForChild("PetInventoryAction"))
                        pcall(fn330)
                        sB = rQ.State
                        sB.Enabled = {
                            BuyAura = false,
                            Lucky = false,
                            Farm = false,
                            BestPets = false,
                            Rebirth = false,
                            BuyPower = false,
                            Click = false,
                            Train = false
                        }
                        sB.Stage = 1
                        sB.TrainLabel = nil
                        sB.LuckyLabel = nil
                        sB.LuckyAmount = 1
                        sB.LastStream = 0
                        sB.LastPunch = 0
                        sB.PassCache = {}
                        rF = 10
                    else
                        sh = rB(sB:WaitForChild("LuckyBlockOpenRequest"))
                        sa = rB(sB:WaitForChild("PetInventoryAction"))
                        pcall(fn330)
                        rY = rF.State
                        rY.Enabled = {
                            Click = false,
                            Farm = false,
                            Rebirth = false,
                            Train = false,
                            BuyAura = false,
                            BuyPower = false,
                            BestPets = false,
                            Lucky = false
                        }
                        rY.Stage = 1
                        rY.TrainLabel = nil
                        rY.LuckyLabel = nil
                        rY.LuckyAmount = 1
                        rY.LastStream = 0
                        rY.LastPunch = 0
                        rY.PassCache = {}
                        rQ = 10
                    end
                    sA = (sA + 35) % 36
                end
            else
                sE = (vector.create((sA * 7 + 1) % 11 + 1, (sA * 11 + 4) % 13 + 1, (sA * 8 + 6) % 17 + 1))
                local CV = vector.floor(sE) + vector.ceil(sE * -1)
                if vector.dot(CV, CV) == 3 then
                    rN = #rL.Walls
                else
                    rL = #rN.Walls
                end
                sA = (sA + 35) % 36
            end
        elseif sD <= 4 then
            if (not sB and not sh or (not r1 or sp)) and ((not r1 or sB) and (not sh and sz_1)) and (sB and sB and (not sB or not sh) or not r1 and sp and (not sz_1 or sB)) or not ((not sB and not sh or (not r1 or sp)) and ((not r1 or sB) and (not sh and sz_1)) and (sB and sB and (not sB or not sh) or not r1 and sp and (not sz_1 or sB))) then
                rG = {}
                rC = {}
            else
                rC = {}
                rG = {}
            end
            sA = (sA + 8) % 36
        else
            if (sA * 1 + 4) * 9 % 4 == ((sA * 1 + 4) * 9 + 13) % 4 then
                sy_2 = r1
            else
                r1 = sy_2
            end
            sA = (sA + 26) % 36
        end
    elseif sD <= 7 then
        if sD <= 6 then
            sE = {
                "jaokf",
                "omflfrrqdv",
                "ctufdzfvmoe",
                "zbpqfn",
                "lqfsozzllci",
                "cferun",
                "rxukro",
                "oud",
                "wiwmcbpij",
                "nazn",
                "zta",
                "ofsraiccw"
            }
            local DI = sA
            sF = sE[DI % 12 + 1]
            if sF:len() <= sF:reverse():rep(DI % 3 + 2):len() then
                sB = rB(sC_2)
            else
                sC_2 = sB(rB)
            end
            sA = (sA + 8) % 36
        else
            sE = {
                "uqzmxubf",
                "itkrmm",
                "vzvevx",
                "ppblchgkdfp",
                "vriqtohsl",
                "srvth",
                "fcfb",
                "nnax",
                "zxhcz",
                "qqleaapx",
                "kkga",
                "qifvuymhonx",
                "ogjecgqrre"
            }
            if sE[(sA * 70 + 27) % 13 + 1] < sE[(sA * 70 + 27) % 13 + 1] then
                rB = require(sB(rN:WaitForChild("PunchEscapeConfig")))
            else
                rN = require(rB(sB:WaitForChild("PunchEscapeConfig")))
            end
            sA = (sA + 17) % 36
        end
    elseif sD <= 8 then
        sD = {
            "aeaqdrasoxy",
            "ivx",
            "mhuoxmq",
            "jmqaionyehj",
            "qav",
            "hxknm",
            "ukwhqt",
            "nvm",
            "cbrtzgnp",
            "wnrimen",
            "tcsrnrgdis",
            "eqmr"
        }
        local Dp = sA
        sE = sD[Dp % 12 + 1]
        if sE:len() <= sE:reverse():rep(Dp % 3 + 2):len() then
            rI = require(rB(sB:WaitForChild("PunchEscapeWorlds")))
        else
            sB = require(rI(rB:WaitForChild("PunchEscapeWorlds")))
        end
        sA = (sA + 35) % 36
    else
        local CW = bit32.rrotate(bit32.bxor(bit32.lrotate(sA, 24), string.byte(tostring(r1))), 28)
        if bit32.bxor(bit32.lrotate(bit32.bxor(CW, 3687292124), 2), 1864266611) ~= bit32.lrotate(CW, 2) then
            sB = require(rE(rB:WaitForChild("LuckyBlockConfig")))
        else
            rE = require(rB(sB:WaitForChild("LuckyBlockConfig")))
        end
        sA = (sA + 35) % 36
    end
until (sA * 29 + 32) % 36 == 10
local sT = 1
local sR = rL
while sT <= sR do
    local sU = sT
    local sy_3 = rN.Walls[sU]
    local sz_2 = type(sy_3) == "table" and sy_3.StageName
    local sy_4 = sz_2 or nil
    local sz_3 = sy_4
    if sy_4 then
        sy_4 = ("%* %*"):format(sU, sz_3)
    end
    local sz_4 = sy_4 or ("Stage %*"):format(sU)
    table.insert(rG, sz_4)
    rC[sz_4] = sU
    sT += 1
end
r2, rT, rO = nil, nil, nil
local sz_5 = 0
repeat
    local DB = bit32.rrotate(bit32.bxor(bit32.lrotate(sz_5, 27), string.byte(tostring(rT))), 2)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(DB, 2063984339), 2174364610), (bit32.bxor(bit32.band(DB, 2230982956), 1372050722))), 2174364610), 1372050722) ~= DB then
        rO = {}
        r2 = {}
        rT = {}
    else
        r2 = {}
        rT = {}
        rO = {}
    end
    sz_5 = (sz_5 + 1) % 4
until (sz_5 * 1 + 2) % 4 == 3
for i, v in ipairs(rN.Training) do
    local sy_6 = rN.GetWorldForTraining(i) or 1
    sA = v.GamePassId and "Gamepass"
    if not sA then
        local sy_8 = tonumber(v.Rebirths) or 0
        sA = ("%* Rebirths"):format(sy_8)
    end
    local sy_9 = sA
    sA = (("W%* x%* (%*)"):format(sy_6, tostring(v.Multiplier), sy_9))
    local sy_10 = (i - 1) % 9 + 1
    sB = tonumber(v.Multiplier) or 1
    local sC_3 = tonumber(v.Rebirths) or 0
    sD = {
        Index = i,
        Label = sA,
        World = sy_6,
        LocalIndex = sy_10,
        Multiplier = sB,
        Rebirths = sC_3,
        GamePassId = tonumber(v.GamePassId)
    }
    table.insert(r2, sD)
    rT[sA] = sD
    table.insert(rO, sA)
end
sB, sb, r4, sz_7 = nil, nil, nil, nil
local sy_11 = 2
repeat
    sA = (sy_11 * 1 + 0) % 2 + 1
    if sA <= 1 then
        if sy_11 * 132227479 + 1 + 5 >= sy_11 * 132227479 + 1 + 5 + 1 then
            sB.TrainLabel = sb[1]
            rO = {}
            r4 = {}
            rY = {}
        else
            rY.TrainLabel = rO[1]
            sB = {}
            sb = {}
            r4 = {}
        end
        sy_11 = (sy_11 + 7) % 16
    else
        local DF = bit32.rrotate(bit32.bxor(bit32.lrotate(sy_11, 21), string.byte(tostring(r4))), 5)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(DF, 639275029), 1376913347), (bit32.bxor(bit32.band(DF, 3655692266), 4127884482))), 1376913347), 4127884482) == DF then
            sz_7 = { "Lucky Block", "Super Lucky Block", "Mega Lucky Block" }
        else
            r4 = { "Mega Lucky Block", "Lucky Block", "Super Lucky Block" }
        end
        sy_11 = (sy_11 + 5) % 16
    end
until (sy_11 * 1 + 9) % 16 == 7
local s3 = 1
while s3 <= 12 do
    local s4 = s3
    local sy_12 = math.floor((s4 - 1) / 3) + 1
    sA = (s4 - 1) % 3 + 1
    local sC_4 = (("W%* %*"):format(sy_12, sz_7[sA]))
    sD = { Station = s4, Label = sC_4, World = sy_12, Tier = sA }
    table.insert(sB, sD)
    sb[sC_4] = sD
    table.insert(r4, sC_4)
    s3 += 1
end
rs, r0, rn, sl, r8, rA, sc, rW, rD, ro, sg, rv, sn, sq, sf, rJ, sj, ry, rX, sr, rR, rZ, rw, rV, rq, r5, rr, sw, si, rS, rH, rP, rz, ss, r9, rK, sv, r_, rx, ru, rM, so, r6, su = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
rY.LuckyLabel = r4[1]
rs = { "1", "3", "6" }
rn = fn295
sl = fn68
r8 = fn191
rA = fn511
sc = fn551
rW = fn41
rD = fn303
ro = fn766
sg = fn828
rv = fn732
sn = function(bq)
    local tT_1
    local tS = type(bq) ~= "number" or bq <= 0
    local tS_2
    if tS then
        return false
    end
    local tS_1 = rY.PassCache[bq]
    if tS_1 ~= nil then
        return tS_1
    end
    tS_2, tT_1 = pcall(function()
        return r7:UserOwnsGamePassAsync(LocalPlayer.UserId, bq)
    end)
    if tS_2 then
        rY.PassCache[bq] = tT_1 == true
        return tT_1 == true
    end
    return false
end
sq = function(bC)
    local tZ_1
    local tY_1
    tY_1, tZ_1 = pcall(function()
        return rI.GetRoot(bC)
    end)
    local t_ = tY_1 and typeof(tZ_1) == "Instance"
    if t_ then
        return rB(tZ_1)
    end
    local Worlds = r3:FindFirstChild("Worlds")
    local tZ_2 = Worlds and Worlds:FindFirstChild("World " .. tostring(bC))
    local tY_3 = tZ_2
    if tZ_2 then
        tZ_2 = rB(tY_3)
    end
    return tZ_2 or nil
end
sf = fn1049
rJ = function(bV)
    if typeof(bV) ~= "Vector3" then
        return
    end
    local t9 = os.clock()
    if t9 - rY.LastStream < 0.45 then
        return
    end
    rY.LastStream = t9
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(bV, 8)
    end)
end
sj = fn717
ry = fn1075
rX = fn219
sr = fn909
rR = fn888
rZ = fn122
rw = fn644
rV = fn955
rq = fn1044
r5 = fn222
rr = fn591
sw = fn884
si = fn799
rS = fn597
if (sl or not si or not su and si or sl and sl and (not su or si)) and (not sl and not su and (not si and not sl) or sl and not sl and (not sw and sl)) or (not sw or su) and (su or not sl) and ((not sw or not si) and (si and sl)) and (not sw and si and (sl and not sw) or (sw or not sl) and (sw or not si)) or not ((sl or not si or not su and si or sl and sl and (not su or si)) and (not sl and not su and (not si and not sl) or sl and not sl and (not sw and sl)) or (not sw or su) and (su or not sl) and ((not sw or not si) and (si and sl)) and (not sw and si and (sl and not sw) or (sw or not sl) and (sw or not si))) then
    rH = function(d9, ea, eb)
        local vw_2
        if not d9 then
            return nil
        end
        local vv = d9:FindFirstChild(ea)
        local vv_2
        if vv then
            return rB(vv)
        end
        vv_2, vw_2 = pcall(function()
            local vt = eb or 6
            return d9:WaitForChild(ea, vt)
        end)
        if vv_2 and vw_2 then
            return rB(vw_2)
        end
    end
    rP = fn381
    rz = fn518
    ss = fn770
    r9 = fn203
else
    ss = function(d9, ea, eb)
        local vw_1
        if not d9 then
            return nil
        end
        local vv = d9:FindFirstChild(ea)
        local vv_1
        if vv then
            return rB(vv)
        end
        vv_1, vw_1 = pcall(function()
            local vt = eb or 6
            return d9:WaitForChild(ea, vt)
        end)
        if vv_1 and vw_1 then
            return rB(vw_1)
        end
    end
    rz = fn381
    r9 = fn518
    rH = fn770
    rP = fn203
end
rK = fn324
sv = fn1046
r_ = fn449
rx = fn906
ru = fn217
rM = function(fv)
    local wl = not fv
    local wp = if wl then 1 else 0
    local wn = 1350 * wp + 539 * (1 - wp)
    local wo = 1183 * wp + 3197 * (1 - wp)
    if not ((wn * 1432 + wo * 2043 + wn * wo) % 16777213 == 5947119) then
        wl = not fv:IsA("ProximityPrompt")
    end
    if wl then
        return false
    elseif r1 then
        return pcall(r1, fv)
    else
        return pcall(function()
            fv:InputHoldBegin()
            task.wait(fv.HoldDuration)
            if rF.Unloaded then
                return
            end
            fv:InputHoldEnd()
        end)
    end
end
so = fn115
r6 = fn356
su = fn756
rF.SetEnabled = fn742
rF.SetStage = fn1081
rF.SetTrain = fn1067
rF.SetLucky = fn642
rF.SetLuckyAmount = fn625
rF.Options = fn941
sG = fn283
sD = fn207
sE = fn93
rF.Track(fn1025)
r0 = {
    task.spawn(sG),
    task.spawn(sD),
    task.spawn(worker5),
    task.spawn(sE),
    task.spawn(worker4),
    task.spawn(worker3),
    task.spawn(worker2),
    task.spawn(worker)
}
rF.Track(fn382)
sA = function()
    local onDiscord
    local BW
    local BP
    onDiscord = nil
    BP = nil
    BW = nil
    local BJ, BK, Library, Toggles, TeleportService, SaveManager, UserInputService, BS, BT, ThemeManager, Options
    UserInputService = game:GetService("UserInputService")
    BJ = "+1 Slash Per Click"
    BP = "https://discord.gg/K7Qxnxkk46"
    BS = "https://tempohub.shop"
    BK = "https://discord.gg/K7Qxnxkk46"
    TeleportService = game:GetService("TeleportService")
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    sm(rF, Library)
    BW = function(h7, h8)
        local xJ = sx(setclipboard) and setclipboard
        local xK = xJ
        if not xK then
            local xJ_1 = sx(toclipboard) and toclipboard
            xK = xJ_1 or nil
        end
        local xJ_2 = xK
        if not xJ_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local xK_1 = pcall(xJ_2, h7)
        if xK_1 then
            Library:Notify(h8)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        BW(BP, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = BP, Copyable = true }, "|", BJ, "|", "v0.2" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
    BT = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Shop = Window:AddTab("Shop", "shopping-cart"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function BX_1(ip)
        local DiscordGroup = ip:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in BT do
        if k ~= "Info" then
            BX_1(v)
        end
    end
    local BX_2 = rF.Options()
    local FarmGroup = BT.Main:AddLeftGroupbox("Farm", "trophy")
    FarmGroup:AddToggle("AutoFarm", {
        Text = "Auto Farm Stage",
        Default = false,
        Callback = function(iw)
            rF.SetEnabled("Farm", iw)
        end
    })
    FarmGroup:AddDropdown("FarmStage", {
        Text = "Stage",
        Values = BX_2.Stages,
        Default = 1,
        Callback = function(iy)
            rF.SetStage(iy)
        end
    })
    FarmGroup:AddToggle("AutoClick", {
        Text = "Auto Click",
        Default = false,
        Callback = function(iA)
            rF.SetEnabled("Click", iA)
        end
    })
    FarmGroup:AddToggle("AutoRebirth", {
        Text = "Auto Rebirth",
        Default = false,
        Callback = function(iC)
            rF.SetEnabled("Rebirth", iC)
        end
    })
    local TrainGroup = BT.Main:AddRightGroupbox("Train", "target")
    TrainGroup:AddToggle("AutoTrain", {
        Text = "Auto Train",
        Default = false,
        Callback = function(iF)
            rF.SetEnabled("Train", iF)
        end
    })
    TrainGroup:AddDropdown("TrainPad", {
        Text = "Dummy",
        Values = BX_2.Train,
        Default = 1,
        Callback = function(iH)
            rF.SetTrain(iH)
        end
    })
    local BuyGroup = BT.Shop:AddLeftGroupbox("Buy", "shopping-bag")
    BuyGroup:AddToggle("AutoBuyAura", {
        Text = "Auto Buy Aura",
        Default = false,
        Callback = function(iK)
            rF.SetEnabled("BuyAura", iK)
        end
    })
    BuyGroup:AddToggle("AutoBuyPower", {
        Text = "Auto Buy Best Power",
        Default = false,
        Callback = function(iM)
            rF.SetEnabled("BuyPower", iM)
        end
    })
    local EquipGroup = BT.Shop:AddLeftGroupbox("Equip", "backpack")
    EquipGroup:AddToggle("AutoBestPets", {
        Text = "Auto Equip Best Pet",
        Default = false,
        Callback = function(iP)
            rF.SetEnabled("BestPets", iP)
        end
    })
    local LuckyBlockGroup = BT.Shop:AddRightGroupbox("Lucky Block", "box")
    LuckyBlockGroup:AddToggle("AutoLucky", {
        Text = "Auto Open Lucky Block",
        Default = false,
        Callback = function(iS)
            rF.SetEnabled("Lucky", iS)
        end
    })
    LuckyBlockGroup:AddDropdown("LuckyBlock", {
        Text = "Lucky Block",
        Values = BX_2.Lucky,
        Default = 1,
        Callback = function(iU)
            rF.SetLucky(iU)
        end
    })
    LuckyBlockGroup:AddDropdown("LuckyAmount", {
        Text = "Amount",
        Values = BX_2.LuckyAmounts,
        Default = 1,
        Callback = function(iW)
            rF.SetLuckyAmount(iW)
        end
    })
    local function BX_3()
        local xZ
        local x3
        local x8
        local x0
        xZ = nil
        x0 = nil
        x3 = nil
        x8 = nil
        local Label3, x1, x2, Label, x5, x6, x7, x9, Label2
        x8 = function(i_)
            return (tostring(i_):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        x3 = function(i1, i2)
            return string.format('<font color="%s">%s</font>', i2, x8(i1))
        end
        x9 = function(i5, i6, i7)
            return string.format("<b>%s</b> %s %s", i5, x3("-", "#5a6070"), x3(i6, i7))
        end
        local yb = {}
        local yc = "#8b93a3"
        x1 = "#e8a34d"
        x6 = "#7fd47f"
        local yd = "#6ec1ff"
        if not sd then
            table.insert(yb, "firetouchinterest")
        end
        if not r1 then
            table.insert(yb, "fireproximityprompt")
        end
        local yf = #yb == 0 and "ready"
        local yj = if yf then 1 else 0
        local yh = 2770 * yj + 2492 * (1 - yj)
        local yi = 904 * yj + 1571 * (1 - yj)
        if not ((yh * 3776 + yi * 1645 + yh * yi) % 16777213 == 14450680) then
            yf = "limited: " .. table.concat(yb, ", ")
        end
        x7 = "Unknown"
        local yb_1 = yf
        pcall(function()
            local xO_1
            local xN_1
            if sx(identifyexecutor) then
                xO_1, xN_1 = identifyexecutor()
                local xP = xO_1 ~= ""
                local xQ = type(xO_1) == "string" and xP
                if xQ then
                    local xP_1 = type(xN_1) == "string" and xN_1 ~= "" and xO_1 .. " " .. xN_1
                    x7 = xP_1 or xO_1
                end
            end
        end)
        xZ = os.clock()
        x5 = function()
            local xS = math.floor(os.clock() - xZ)
            if xS < 60 then
                return xS .. "s"
            elseif xS < 3600 then
                return string.format("%dm %ds", math.floor((xS) / (60)), xS % 60)
            else
                return string.format("%dh %dm", math.floor((xS) / (3600)), math.floor((xS % 3600) / (60)))
            end
        end
        local UserGroup = BT.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(x9("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, x6), true)
        UserGroup:AddLabel(x9("UserId", tostring(LocalPlayer.UserId), yd), true)
        UserGroup:AddLabel(x9("Executor", x7 .. "  " .. yb_1, x6), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(x9("Session", x5(), x1), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                BW(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                BW("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = BT.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(x9("Game", BJ, yd), true)
        Label2 = SessionGroup:AddLabel(x9("Players", "0/0", x6), true)
        x2 = tostring(game.JobId)
        local yd_1 = #x2 > 18 and string.sub(x2, 1, 18) .. "..."
        local ye_2 = yd_1 or x2
        SessionGroup:AddLabel(x9("Job", ye_2, yc), true)
        Label = SessionGroup:AddLabel(x9("Ping", "0 ms", x1), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                BW(x2, "Copied Job ID")
            end
        })
        x0 = task.spawn(function()
            local xV_1
            local xU_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(x9("Session", x5(), x1))
                Label2:SetText(x9("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), x6))
                xU_1, xV_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local xU_2 = xU_1 and xV_1 .. " ms" or "n/a"
                Label:SetText(x9("Ping", xU_2, x1))
            end
        end)
        rF.Track(function()
            if coroutine.status(x0) ~= "dead" then
                task.cancel(x0)
            end
        end)
        local SocialsGroup = BT.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                BW(BK, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                BW(BS, "Copied website link")
            end
        })
    end
    BX_3()
    local function BX_4()
        local kn
        local kl
        local ko
        local km
        local MovementGroup = BT.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = BT.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        kn = {}
        ko = {}
        kl = {}
        km = {}
        local kk = {}
        local function kp()
            for k, v in kl do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(kl)
        end
        local function kt()
            for k, v in km do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(km)
        end
        local function ky()
            for k, v in kn do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(kn)
        end
        local function kC(kD)
            local yI = if not kD:IsA("ProximityPrompt") then 1 else 0
            if yI == 1 then
                return
            end
            if ko[kD] == nil then
                ko[kD] = {
                    HoldDuration = kD.HoldDuration,
                    MaxActivationDistance = kD.MaxActivationDistance,
                    RequiresLineOfSight = kD.RequiresLineOfSight
                }
            end
            kD.HoldDuration = 0
            kD.MaxActivationDistance = 50
            kD.RequiresLineOfSight = false
        end
        local function kF()
            for k, v in ko do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(ko)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                ky()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                kt()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                kp()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in r3:QueryDescendants("ProximityPrompt") do
                    pcall(kC, v)
                end
            else
                kF()
            end
        end)
        table.insert(kk, r3.DescendantAdded:Connect(function(kY)
            if Toggles.InstantProximityPrompt.Value then
                kC(kY)
            end
        end))
        table.insert(kk, sk.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if kl[v] == nil then
                        kl[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(kk, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local zj = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and zj then
                zj:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(kk, sk.RenderStepped:Connect(function(li)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local zm = Character and Character:FindFirstChildOfClass("Humanoid")
            local zn = Character
            if zn then
                zn = Character:FindFirstChild("HumanoidRootPart")
            end
            local zl_1 = zn
            local CurrentCamera = r3.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and zm then
                if km[zm] == nil then
                    km[zm] = zm.WalkSpeed
                end
                zm.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and zl_1 and zm and CurrentCamera then
                if kn[zm] == nil then
                    kn[zm] = zm.PlatformStand
                end
                zm.PlatformStand = true
                local zn_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        zn_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        zn_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        zn_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        zn_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        zn_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        zn_4 -= Vector3.new(0, 1, 0)
                    end
                end
                zl_1.AssemblyLinearVelocity = Vector3.zero
                if zn_4.Magnitude > 0 then
                    zl_1.CFrame = zl_1.CFrame + zn_4.Unit * Options.FlySpeed.Value * li
                end
            end
        end))
        rF.Track(function()
            for k, v in kk do
                v:Disconnect()
            end
            kp()
            kt()
            ky()
            kF()
        end)
    end
    BX_4()
    local function BX_5()
        local lE
        local ml
        local Lighting = game:GetService("Lighting")
        local GuiService = game:GetService("GuiService")
        local CoreGui = game:GetService("CoreGui")
        local VirtualUser = game:GetService("VirtualUser")
        lE = {}
        local lD = {}
        local lF
        local lI = 0
        local lH = 0
        local lG = false
        local lJ = os.clock()
        local MenuGroup = BT.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = MenuGroup:AddLabel("AFK triggers: 0")
        local function lN()
            local CurrentCamera
            CurrentCamera = r3.CurrentCamera
            if not CurrentCamera then
                return
            end
            local zL = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero, CurrentCamera.CFrame)
            end)
            if not zL then
                return
            end
            lI += 1
            lJ = os.clock()
            Label:SetText("AFK triggers: " .. lI)
        end
        local function onAntiGameplayPause(lZ)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not lZ)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not lZ
                end
            end)
            if lZ then
                pcall(function()
                    if sx(sethiddenproperty) then
                        sethiddenproperty(LocalPlayer, "GameplayPaused", false)
                    else
                        LocalPlayer.GameplayPaused = false
                    end
                end)
            end
        end
        local function mc()
            for k, v in lE do
                local zV = k
                local zX = v
                if zV.Parent then
                    pcall(function()
                        zV.Enabled = zX
                    end)
                end
            end
            table.clear(lE)
            if lF then
                pcall(function()
                    settings().Rendering.QualityLevel = lF.Quality
                end)
                Lighting.GlobalShadows = lF.Shadows
                Lighting.FogEnd = lF.Fog
                lF = nil
            end
        end
        ml = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
        local function mm(mn)
            if ml[mn.ClassName] then
                if lE[mn] == nil then
                    lE[mn] = mn.Enabled
                end
                mn.Enabled = false
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true, Callback = onAntiGameplayPause })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(mq)
                pcall(function()
                    sk:Set3dRenderingEnabled(not mq)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(mv)
                if mv then
                    if not lF then
                        lF = {
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
                    for k, v in r3:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(mm, v)
                    end
                else
                    mc()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        onAntiGameplayPause(true)
        local ScriptGroup = BT.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        table.insert(lD, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                lN()
            end
        end))
        table.insert(lD, r3.DescendantAdded:Connect(function(mM)
            if Toggles.FpsBoost.Value then
                mm(mM)
            end
        end))
        local function mP(mQ)
            if lG or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            lG = true
            local Ad = lH
            local Ae_1 = pcall(function()
                if mQ then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Ae_1 then
                lG = false
                if not mQ and Ad == lH then
                    task.delay(1.5, function()
                        if Ad == lH then
                            mP(true)
                        end
                    end)
                end
            end
        end
        table.insert(lD, TeleportService.TeleportInitFailed:Connect(function(m7)
            local Al
            if m7 == LocalPlayer and lG then
                lG = false
                Al = lH
                task.delay(3, function()
                    if Al == lH then
                        mP(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Aq = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not Aq then
                return
            end
            table.insert(lD, Aq.ChildAdded:Connect(function(nm)
                if nm.Name == "ErrorPrompt" then
                    mP(false)
                end
            end))
        end)
        local nv = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    onAntiGameplayPause(true)
                end
                local At = Toggles.AntiAfk.Value and os.clock() - lJ >= 60
                if At then
                    lN()
                end
                task.wait(1)
            end
        end)
        rF.Track(function()
            lH += 1
            for k, v in lD do
                v:Disconnect()
            end
            pcall(task.cancel, nv)
            onAntiGameplayPause(false)
            mc()
            pcall(function()
                sk:Set3dRenderingEnabled(true)
            end)
        end)
    end
    BX_5()
    local function BX_6()
        local BD, BE, BF, BG
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(BT.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/SlashPerClick")
        local BH = SaveManager:BuildConfigSection(BT.Settings)
        BG = function(nN, nO)
            local AG_1 = (nN == "Toggle" and Toggles or Options)[nO]
            local AF_2 = type(AG_1) == "table" and AG_1.Type == nN
            return AF_2 and AG_1 or nil
        end
        BE = function(nX, nY)
            local Type = nY.Type
            if Type == "Toggle" then
                return { idx = nX, type = "Toggle", value = nY.Value == true }
            elseif Type == "Slider" then
                return { idx = nX, type = "Slider", value = tostring(nY.Value) }
            elseif Type == "Dropdown" then
                return { idx = nX, type = "Dropdown", multi = nY.Multi == true, value = nY.Value }
            elseif Type == "Input" then
                local AK = nY.Value or ""
                return { idx = nX, type = "Input", text = tostring(AK) }
            elseif Type == "ColorPicker" then
                return { idx = nX, type = "ColorPicker", value = nY.Value:ToHex(), transparency = nY.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = nX,
                    type = "KeyPicker",
                    mode = nY.Mode,
                    key = nY.Value,
                    modifiers = nY.Modifiers,
                    toggled = nY.Toggled
                }
            else
                return nil
            end
        end
        BD = function()
            local AT = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local AU = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if AU then
                        local AU_1 = BE(k, v)
                        if AU_1 then
                            AT[#AT + 1] = AU_1
                        end
                    end
                end
            end
            table.sort(AT, function(n7, n8)
                if n7.type ~= n8.type then
                    return n7.type < n8.type
                end
                return n7.idx < n8.idx
            end)
            return { objects = AT }
        end
        BF = function(oa)
            local Bc
            Bc = nil
            local Bd = type(oa) ~= "table" or type(oa.idx) ~= "string" or type(oa.type) ~= "string" or SaveManager.Ignore[oa.idx]
            if Bd then
                return false
            end
            Bc = BG(oa.type, oa.idx)
            if not Bc then
                return false
            end
            local Bd_1 = pcall(function()
                if oa.type == "Input" then
                    if type(oa.text) ~= "string" then
                        return
                    end
                    Bc:SetValue(oa.text)
                elseif oa.type == "ColorPicker" then
                    Bc:SetValueRGB(Color3.fromHex(oa.value), oa.transparency)
                elseif oa.type == "KeyPicker" then
                    Bc:SetValue({ oa.key, oa.mode, oa.modifiers })
                    if oa.mode == "Toggle" and oa.toggled ~= nil then
                        Bc.Toggled = oa.toggled
                        Bc:Update()
                    end
                else
                    Bc:SetValue(oa.value)
                end
            end)
            return Bd_1
        end
        BH:AddDivider()
        BH:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        BH:AddButton("Export Config to Clipboard", function()
            local Bg_1
            local Bf_1
            Bf_1, Bg_1 = pcall(se.JSONEncode, se, BD())
            if not Bf_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local Bf_2 = sx(setclipboard) and setclipboard
            local Bh = Bf_2
            local Bm = if Bh then 1 else 0
            local Bk = 3085 * Bm + 215 * (1 - Bm)
            local Bl = 11 * Bm + 1790 * (1 - Bm)
            if not ((Bk * 343 + Bl * 347 + Bk * Bl) % 16777213 == 1095907) then
                local Bf_3 = sx(toclipboard) and toclipboard
                Bh = Bf_3 or nil
            end
            local Bf_4 = Bh
            local Bh_1 = type(Bf_4) ~= "function" or not pcall(Bf_4, Bg_1)
            if Bh_1 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end)
        BH:AddButton("Import Config from Clipboard Text", function()
            local Bp_1
            local Bn = Options.SaveManager_ImportSource.Value or ""
            local Bn_1
            local Bo = tostring(Bn):match("^%s*(.-)%s*$")
            if Bo == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #Bo > 262144 then
                Library:Notify("That config is too large")
                return
            end
            Bn_1, Bp_1 = pcall(se.JSONDecode, se, Bo)
            local Bo_1 = not Bn_1
            local Bw = if Bo_1 then 1 else 0
            local Bu = 184 * Bw + 2790 * (1 - Bw)
            local Bv = 3178 * Bw + 3403 * (1 - Bw)
            if not ((Bu * 3897 + Bv * 483 + Bu * Bv) % 16777213 == 2836774) then
                Bo_1 = type(Bp_1) ~= "table"
            end
            if not Bo_1 then
                Bo_1 = type(Bp_1.objects) ~= "table"
            end
            if Bo_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #Bp_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local Bn_2 = 0
            for i, v in ipairs(Bp_1.objects) do
                if BF(v) then
                    Bn_2 += 1
                end
            end
            if Bn_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local Bp_2 = Bn_2 == 1 and ""
            local Bt = if Bp_2 then 1 else 0
            local Br = 2775 * Bt + 1048 * (1 - Bt)
            local Bs = 3148 * Bt + 2987 * (1 - Bt)
            if not ((Br * 1094 + Bs * 1815 + Br * Bs) % 16777213 == 707957) then
                Bp_2 = "s"
            end
            Library:Notify(("Imported %d setting%s"):format(Bn_2, Bp_2), 6)
        end)
        SaveManager:LoadAutoloadConfig()
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    BX_6()
end
sA()
end)(...)
