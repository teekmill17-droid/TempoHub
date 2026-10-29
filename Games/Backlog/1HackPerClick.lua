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
getgenv().TempoHoodSubtitle = "+1 HACK PER CLICK"
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
local KickBagConstants
local ReplicaController
local lc
local kB
local Label
local k_
local AddKick
local lo
local Options
local kN
local lb
local kA
local lh
local kg
local kZ
local kG
local ln
local connection
local lt
local connection2
local la
local EggConfig
local kz
local Library
local kf
local HitWall
local lm
local kl
local kL
local ls
local kr
local Toggles
local kR
local lf
local kE
local ll
local kk
local k2
local OwnsWinsGamepass
local lr
local k8
local kQ
local kd
local kD
local lk
local k1
local kJ
local lq
local kp
local k7
local kw
local ld
local kV
local kC
local lj
local lp
local ko
local k6
local function fn28()
    pcall(function()
        kC:InvokeServer()
    end)
end
local function fn32()
    local qa_1
    local p9_1
    if identifyexecutor then
        qa_1, p9_1 = identifyexecutor()
        local qb = qa_1 ~= ""
        local qc = type(qa_1) == "string" and qb
        if qc then
            local qb_1 = type(p9_1) == "string" and p9_1 ~= "" and qa_1 .. " " .. p9_1
            kD = qb_1 or qa_1
        end
    end
end
local function fn34(cR)
    local n2 = lh:FindFirstChild(KickBagConstants.TrainingFolder)
    if not n2 then
        return nil
    end
    local n3 = ln()
    local n4 = math.huge
    local n5
    local n6 = lf.Character and lf.Character:FindFirstChild("HumanoidRootPart")
    local n7 = n6
    if n6 then
        n6 = n7.Position
    end
    local n7_1 = n6
    for i, child in ipairs(n2:GetChildren()) do
        if child.Name == cR then
            local BasePart = child:FindFirstChildWhichIsA("BasePart", true)
            if BasePart then
                if (BasePart.Position.Z < 350 and "world2" or "world1") == n3 then
                    if not n7_1 then
                        return BasePart
                    end
                    local Magnitude = (BasePart.Position - n7_1).Magnitude
                    if Magnitude < n4 then
                        n4 = Magnitude
                        n5 = BasePart
                    end
                end
            end
        end
    end
    if n5 then
        return n5
    end
    for i, child in ipairs(n2:GetChildren()) do
        if child.Name == cR then
            local BasePart = child:FindFirstChildWhichIsA("BasePart", true)
            if BasePart then
                return BasePart
            end
        end
    end
    return nil
end
local function fn37(a2)
    local mM = Toggles[a2]
    return mM ~= nil and mM.Value == true
end
local function fn41()
    pcall(function()
        HitWall:InvokeServer()
    end)
end
local function worker4()
    while not Library.Unloaded do
        task.wait(0.35)
        if lj("AutoBuyPcs") then
            pcall(ld)
        end
        if lj("AutoBuyBoosts") then
            pcall(ll)
        end
        if lj("AutoBuyUpgrades") then
            pcall(kZ)
        end
        if lj("AutoRebirth") then
            pcall(kA)
        end
    end
end
local function fn104()
    local m7 = lr()
    if m7 and m7.Rebirths ~= nil then
        local m8_1 = tonumber(m7.Rebirths) or 0
        return m8_1
    end
    local leaderstats = lf:FindFirstChild("leaderstats")
    local m8_2 = leaderstats and leaderstats:FindFirstChild("Rebirths")
    local m7_2 = m8_2
    if m8_2 then
        local m9 = tonumber(m7_2.Value) or 0
        m8_2 = m9
    end
    local m7_3 = m8_2
    local nd = if m7_3 then 1 else 0
    local nb = 3101 * nd + 3827 * (1 - nd)
    local nc = 474 * nd + 200 * (1 - nd)
    if not ((nb * 3440 + nc * 2932 + nb * nc) % 16777213 == 13527082) then
        m7_3 = 0
    end
    return m7_3
end
local function fn149(a7)
    local mP = Options[a7]
    return mP and mP.Value or nil
end
local function fn185()
    local Character = lf.Character
    local nl = Character and Character:FindFirstChild("HumanoidRootPart")
    local nk_1 = nl
    if nl then
        nl = nk_1.Position.Z < 350
    end
    if nl then
        return "world2"
    end
    return "world1"
end
local function fn192()
    ReplicaController.RequestData()
end
local function worker2()
    while not Library.Unloaded do
        task.wait(0.35)
        if lj("AutoRollTitles") then
            pcall(kV)
        end
        if lj("AutoEquipBestTitle") then
            pcall(kJ)
        end
        if lj("AutoEquipBestPet") then
            pcall(lb)
        end
    end
end
local function worker()
    local qk_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local qj = math.floor(os.clock() - lc)
        if qj < 60 then
            qk_1 = qj .. "s"
        elseif qj < 3600 then
            qk_1 = string.format("%dm %ds", math.floor((qj) / (60)), qj % 60)
        else
            qk_1 = string.format("%dh %dm", math.floor((qj) / (3600)), math.floor((qj % 3600) / (60)))
        end
        Label:SetText(kr("Session time", qk_1, ls))
    end
end
local function fn281()
    local Index = lt:WaitForChild("Packages"):WaitForChild("_Index")
    local mr = Index:FindFirstChild("sleitnick_knit@1.7.0")
    if not mr then
        for i, child in Index:GetChildren() do
            if string.match(child.Name, "^sleitnick_knit@") then
                mr = child
                break
            end
        end
    end
    assert(mr, "Knit package not found")
    return mr:WaitForChild("knit"):WaitForChild("Services")
end
local function fn295(ai, aj)
    if ai.Order == aj.Order then
        return ai.DamagePerClick < aj.DamagePerClick
    end
    return ai.Order < aj.Order
end
local function onCopyJoinScript_JobID()
    local qh = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kf)
    if setclipboard then
        setclipboard(qh)
    elseif toclipboard then
        toclipboard(qh)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn344()
    local nn = {}
    local no = lr()
    local np = no and type(no.OwnedBackpacks) == "table"
    if np then
        for i, v in ipairs(no.OwnedBackpacks) do
            nn[v] = true
        end
    end
    return nn
end
local function worker8()
    while not Library.Unloaded do
        task.wait(2)
        if lj("AntiAfk") then
            local qC = tick() - lq
            local qD = tick() - lk
            if qC >= 300 and qD >= 60 then
                pcall(k7)
            else
                if qC < 300 and qD >= 300 then
                    pcall(k7)
                end
            end
        end
    end
end
local function fn379(ar, as)
    local mA = EggConfig.Eggs[ar].WinCost
    local mG = if mA then 1 else 0
    local mE = 3332 * mG + 3005 * (1 - mG)
    local mF = 1002 * mG + 4012 * (1 - mG)
    if not ((mE * 1632 + mF * 849 + mE * mF) % 16777213 == 9627186) then
        mA = 0
    end
    local mB = mA
    local mA_1 = EggConfig.Eggs[as].WinCost
    local mG_1 = if mA_1 then 1 else 0
    local mE_1 = 3327 * mG_1 + 856 * (1 - mG_1)
    local mF_1 = 2321 * mG_1 + 2017 * (1 - mG_1)
    if not ((mE_1 * 1519 + mF_1 * 3172 + mE_1 * mF_1) % 16777213 == 3360679) then
        mA_1 = 0
    end
    local mC = mA_1
    if mB == mC then
        return ar < as
    end
    return mB < mC
end
local function fn393(e9)
    local DiscordGroup = e9:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kQ })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kQ })
end
local function worker7()
    while not Library.Unloaded do
        local qG = lj("FastDestroyWall") or lj("AutoWin")
        if qG then
            local qG_1 = math.clamp(math.floor(kR("FastDestroySpeed", 1)), 1, 200)
            local qK = 1
            while qK <= qG_1 do
                task.spawn(kd)
                qK += 1
            end
            task.wait()
        else
            task.wait(0.1)
        end
    end
end
local function fn447(bk)
    ko = bk
end
local function fn449(aR, aS)
    return string.format('<font color="%s">%s</font>', aS, aR)
end
local function worker6()
    while not Library.Unloaded do
        task.wait(0.25)
        if lj("AutoWin") then
            pcall(lp)
        end
    end
end
local function onUnload()
    Library:Unload()
end
local function fn515()
    k1(la, "Copied Discord invite to clipboard")
end
local function fn555()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn567()
    kw()
    local nQ = kk()
    if lo(nQ) then
        k_(nQ)
    end
end
local function onInputChanged(f0)
    local UserInputType = f0.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lq = tick()
    end
end
local function fn579()
    pcall(function()
        kg:InvokeServer()
    end)
end
local function fn592()
    local ny_1
    local nx_1
    if tick() - kB < 5 then
        return
    end
    kB = tick()
    nx_1, ny_1 = pcall(function()
        return OwnsWinsGamepass:InvokeServer()
    end)
    if nx_1 then
        kG = ny_1 == true
    end
end
local function fn633(bc, bd)
    local mS = Options[bc]
    local mT = mS and tonumber(mS.Value)
    if mT then
        return mT
    end
    return bd
end
local function worker3()
    while not Library.Unloaded do
        task.wait(0.4)
        if lj("AutoHatchEggs") then
            pcall(kp)
        end
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(k8)
    elseif toclipboard then
        toclipboard(k8)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn656()
    local nS = kN()
    local nT = -1
    local Name
    for i, v in ipairs(kl) do
        if v.RebirthsRequired <= nS and v.Multiplier >= nT then
            Name = v.Name
            nT = v.Multiplier
        end
    end
    return Name or "Starter Desk"
end
local function fn677(aB, aC)
    if aB.Multiplier == aC.Multiplier then
        return aB.RebirthsRequired < aC.RebirthsRequired
    end
    return aB.Multiplier < aC.Multiplier
end
local function fn682(bL)
    local Character = lf.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(bL)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = bL
        end
    end
end
local function worker5()
    while not Library.Unloaded do
        if lj("AutoTrain") then
            pcall(kz)
        elseif lj("AutoClick") then
            pcall(kL)
        else
            task.wait(0.1)
        end
    end
end
local function fn724()
    pcall(function()
        AddKick:InvokeServer(nil)
    end)
end
local function onInputBegan()
    lq = tick()
end
local function fn762(aU, aV, aW)
    return string.format("<b>%s</b> %s %s", aU, kE("-", "#5a6070"), kE(aV, aW))
end
local function fn807()
    local nK = k6("WinPlate")
    if type(nK) == "string" then
        local nL = tonumber(nK:match("%d+"))
        if nL then
            return math.clamp(nL, 1, k2)
        end
        return 1
    end
    return 1
end
local function fn811()
    local mW = ko and ko.Data
    local m_ = if mW then 1 else 0
    local mY = 3434 * m_ + 1207 * (1 - m_)
    local mZ = 3700 * m_ + 3025 * (1 - m_)
    if not ((mY * 2637 + mZ * 2103 + mY * mZ) % 16777213 == 12765145) then
        mW = nil
    end
    return mW
end
local function fn818(aK, aL)
    if setclipboard then
        setclipboard(aK)
    elseif toclipboard then
        toclipboard(aK)
    end
    Library:Notify(aL)
end
local function fn833()
    local CurrentCamera = lh.CurrentCamera
    if not CurrentCamera then
        return
    end
    lm:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    lm:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    lk = tick()
end
local function fn841()
    local m0 = lr()
    if m0 and m0.Wins ~= nil then
        local m1_1 = tonumber(m0.Wins) or 0
        return m1_1
    end
    local leaderstats = lf:FindFirstChild("leaderstats")
    local m1_2 = leaderstats and leaderstats:FindFirstChild("Wins")
    local m0_2 = m1_2
    if m1_2 then
        local m2 = tonumber(m0_2.Value) or 0
        m1_2 = m2
    end
    local m0_3 = m1_2
    local m6 = if m0_3 then 1 else 0
    local m4 = 2168 * m6 + 3297 * (1 - m6)
    local m5 = 2296 * m6 + 727 * (1 - m6)
    if not ((m4 * 2073 + m5 * 3784 + m4 * m5) % 16777213 == 1382843) then
        m0_3 = 0
    end
    return m0_3
end
kd = nil
kf = nil
kg = nil
Label = nil
kk = nil
kl = nil
ko = nil
kp = nil
kr = nil
connection2 = nil
ReplicaController = nil
kw = nil
kz = nil
kA = nil
kB = nil
kC = nil
kD = nil
kE = nil
kG = nil
AddKick = nil
kJ = nil
OwnsWinsGamepass = nil
kL = nil
connection = nil
kN = nil
KickBagConstants = nil
kQ = nil
kR = nil
EggConfig = nil
kV = nil
HitWall = nil
kZ = nil
k_ = nil
local Equip, ki, kj, OpenEgg, EquipBackpack, kq, Purchase, PurchaseBoost, ky, TitleConfig, PetConfig, ClaimReward2x, kT, kU, kW, kX, k0
k1 = nil
k2 = nil
Options = nil
k6 = nil
k7 = nil
k8 = nil
Toggles = nil
la = nil
lb = nil
lc = nil
ld = nil
lf = nil
Library = nil
lh = nil
lj = nil
lk = nil
ll = nil
lm = nil
ln = nil
lo = nil
lp = nil
lq = nil
lr = nil
ls = nil
lt = nil
local k3, k4, le, li, lu, lw, lx, ly, lA, lB, lC, lD, lE, lF, lG, lH, lI, lJ, lK, lL, lM, lN, lO
local lv_1
local lP, lR, lS, lT, lU
lv_1, lt, lP, lm, lh, lf, lN, la, k8, k2, lA, lL, lM, EggConfig, KickBagConstants, PetConfig, TitleConfig, ly, ReplicaController, lw, lK, lJ, lI, lH, lG, lF, lE, lD, lC, lB, HitWall, kW, kT, ClaimReward2x, OwnsWinsGamepass, AddKick, kC, PurchaseBoost, Purchase, kq, EquipBackpack, OpenEgg, kj, kg, Equip, lu, lO, lx = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local lz = 25
repeat
    local lQ = (lz * 3 + 23) % 34 + 1
    if lQ <= 17 then
        if lQ <= 9 then
            if lQ <= 5 then
                if lQ <= 3 then
                    if lQ <= 2 then
                        if lQ <= 1 then
                            lR = {
                                "bbeonzldpgn",
                                "gafhce",
                                "nadn",
                                "lrpvbvbmvz",
                                "etaoos",
                                "udesvutjw",
                                "eccmyyru",
                                "qubfgji",
                                "lpwkoonucm",
                                "lycjqb",
                                "ailmkicibax",
                                "idp",
                                "wcljijveer",
                                "scbfnzuwvf",
                                "dkw",
                                "xowg"
                            }
                            if lR[(lz * 21 + 73) % 16 + 1] < lR[(lz * 21 + 73) % 16 + 1] then
                                la = "+1 Hack Per Click"
                                lN = "https://discord.gg/K7Qxnxkk46"
                            else
                                lN = "+1 Hack Per Click"
                                la = "https://discord.gg/K7Qxnxkk46"
                            end
                            lz = (lz + 125) % 136
                        else
                            local rG = bit32.rrotate(bit32.bxor(bit32.lrotate(lz, 18), string.byte(tostring(lJ))), 16)
                            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(rG, 696498747), 3494709117), (bit32.bxor(bit32.band(rG, 3598468548), 3029894822))), 3494709117), 3029894822) ~= rG then
                                lK = "https://discord.gg/K7Qxnxkk46"
                            else
                                k8 = "https://discord.gg/K7Qxnxkk46"
                            end
                            lz = (lz + 57) % 136
                        end
                    else
                        lR = { "govmh", "fhfqjle", "omddmtni", "wmskwiq", "jqdizlv", "vrzoxeavyd", "dfqag", "aeqvxcpnxv" }
                        local ro = lz
                        lS = lR[ro % 8 + 1]
                        if lS:len() <= lS:gsub("(.)", "%1%1", ro % 3 % 2 + 1):len() then
                            k2 = 15
                        else
                            lv_1 = 15
                        end
                        lz = (lz + 57) % 136
                    end
                elseif lQ <= 4 then
                    local r0 = bit32.rrotate(bit32.bxor(bit32.lrotate(lz, 18), string.byte(tostring(lI))), 12)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(r0, 774289193), 2130068149), (bit32.bxor(bit32.band(r0, 3520678102), 3383110459))), 2130068149), 3383110459) ~= r0 then
                        lt = lA:WaitForChild("Shared")
                    else
                        lA = lt:WaitForChild("Shared")
                    end
                    lz = (lz + 125) % 136
                else
                    if lz * 82926869 + 12 + 2 >= lz * 82926869 + 12 + 2 + 6 then
                        lA = require(lL:WaitForChild("BackpackConfig"))
                    else
                        lL = require(lA:WaitForChild("BackpackConfig"))
                    end
                    lz = (lz + 91) % 136
                end
            elseif lQ <= 7 then
                if lQ <= 6 then
                    lR = (vector.create((lz * 5 + 8) % 11 + 1, (lz * 5 + 5) % 13 + 1, (lz * 8 + 3) % 17 + 1))
                    lS = (vector.create((lz * 7 + 1) % 11 + 1, (lz * 2 + 10) % 13 + 1, (lz * 13 + 17) % 17 + 1))
                    local rz = vector.cross(lR, lS)
                    local rA = vector.dot(lR, lS)
                    if vector.dot(rz, rz) + rA * rA == vector.dot(lR, lR) * vector.dot(lS, lS) then
                        lM = require(lA:WaitForChild("BoostConfig"))
                    else
                        lA = require(lM:WaitForChild("BoostConfig"))
                    end
                    lz = (lz + 57) % 136
                else
                    if (lz * 2 + 6) * 10 % 3 == ((lz * 2 + 6) * 10 + 4) % 3 then
                        lA = require(EggConfig:WaitForChild("EggConfig"))
                    else
                        EggConfig = require(lA:WaitForChild("EggConfig"))
                    end
                    lz = (lz + 125) % 136
                end
            elseif lQ <= 8 then
                lR = {
                    "cajcblkmwj",
                    "suolzlljbdc",
                    "uaflliorhr",
                    "smlqachnzz",
                    "gznjvhu",
                    "yazclc",
                    "keukidzgu",
                    "cwiwwvsosc",
                    "srxbis",
                    "boci",
                    "mbyr"
                }
                local r2 = lz
                lS = lR[r2 % 11 + 1]
                if lS:len() <= lS:gsub("(.)", "%1%1", r2 % 3 % 2 + 1):len() then
                    KickBagConstants = require(lA:WaitForChild("KickBagConstants"))
                else
                    lA = require(KickBagConstants:WaitForChild("KickBagConstants"))
                end
                lz = (lz + 23) % 136
            else
                lR = { "yxklhp", "aisb", "tbdj", "ppsm", "fzk", "bcpwfkjbc", "leo" }
                local rl = lz
                lS = lR[rl % 7 + 1]
                if lS:len() <= lS:reverse():rep(rl % 3 + 2):len() then
                    PetConfig = require(lA:WaitForChild("PetConfig"))
                else
                    lA = require(PetConfig:WaitForChild("PetConfig"))
                end
                lz = (lz + 57) % 136
            end
        elseif lQ <= 13 then
            if lQ <= 11 then
                if lQ <= 10 then
                    lR = {
                        "czxbretbqwn",
                        "sewvkxqbh",
                        "pkwhsadzcj",
                        "swriq",
                        "mmzpmdoyix",
                        "gpgm",
                        "lkz",
                        "vishrncijm",
                        "orbb",
                        "iwgs",
                        "rfzq"
                    }
                    local r3 = lz
                    lS = lR[r3 % 11 + 1]
                    if lS:len() >= lS:gsub("(.)", "%1%1", r3 % 3 % 2 + 1):len() then
                        ly = require(TitleConfig:WaitForChild("TitleConfig"))
                        lA = require(TitleConfig:WaitForChild("UpgradesConfig"))
                    else
                        TitleConfig = require(lA:WaitForChild("TitleConfig"))
                        ly = require(lA:WaitForChild("UpgradesConfig"))
                    end
                    lz = (lz + 91) % 136
                else
                    lR = {
                        "huknrrx",
                        "bervnkrwdeg",
                        "aukdzfxdp",
                        "xnnryyl",
                        "xrkcbbb",
                        "wfnluztbhx",
                        "chqb",
                        "vovqdjqfcm",
                        "nmvrajcai",
                        "upviy",
                        "ojth"
                    }
                    local rE = lz
                    lS = lR[rE % 11 + 1]
                    if lS:len() <= lS:reverse():rep(rE % 3 + 2):len() then
                        ReplicaController = require(lt:WaitForChild("ReplicaController"))
                    else
                        lt = require(ReplicaController:WaitForChild("ReplicaController"))
                    end
                    lz = (lz + 91) % 136
                end
            elseif lQ <= 12 then
                if (not lt and PetConfig or (PetConfig or not PetConfig)) and (lt and HitWall and (HitWall and PetConfig)) and (lt and not lt and (not PetConfig and not lt) or (not lt or HitWall or lt and not HitWall)) or not ((not lt and PetConfig or (PetConfig or not PetConfig)) and (lt and HitWall and (HitWall and PetConfig)) and (lt and not lt and (not PetConfig and not lt) or (not lt or HitWall or lt and not HitWall))) then
                    lx = fn281
                else
                    lH = fn281
                end
                lz = (lz + 125) % 136
            else
                lR = { "rdptepa", "gkdt", "kjwabufrxpjp", "lgiy", "qlakk", "jinkghvxw", "oqlarxrmuzvq", "qixjfkmnd" }
                if lR[(lz * 18 + 88) % 8 + 1] <= lR[(lz * 18 + 88) % 8 + 1] then
                    lw = lx()
                else
                    lx = lw()
                end
                lz = (lz + 91) % 136
            end
        elseif lQ <= 15 then
            if lQ <= 14 then
                lR = { "hqexboqyfg", "pkfewfui", "kqlbrsz", "opmmnkppyed", "beign", "tirzfryudtj", "crjxdjri", "hjau" }
                local ri = lz
                lS = lR[ri % 8 + 1]
                if lS:len() <= lS:gsub("(.)", "%1%1", ri % 3 % 2 + 1):len() then
                    lK = lw:WaitForChild("BreakWallService")
                else
                    lw = lK:WaitForChild("BreakWallService")
                end
                lz = (lz + 125) % 136
            else
                lR = (vector.create((lz * 2 + 4) % 11 + 1, (lz * 10 + 9) % 13 + 1, (lz * 11 + 16) % 17 + 1))
                lS = (vector.create((lz * 5 + 5) % 11 + 1, (lz * 1 + 4) % 13 + 1, (lz * 1 + 10) % 17 + 1))
                lT = (vector.create((lz * 5 + 3) % 11 + 1, (lz * 2 + 7) % 13 + 1, (lz * 15 + 17) % 17 + 1))
                lU = (vector.create((lz * 5 + 3) % 11 + 1, (lz * 7 + 12) % 13 + 1, (lz * 15 + 13) % 17 + 1))
                if vector.dot(vector.cross(lR, lS), (vector.cross(lT, lU))) == vector.dot(lR, lT) * vector.dot(lS, lU) - vector.dot(lR, lU) * vector.dot(lS, lT) + 3 then
                    lw = lJ:WaitForChild("RewardZoneService")
                else
                    lJ = lw:WaitForChild("RewardZoneService")
                end
                lz = (lz + 91) % 136
            end
        elseif lQ <= 16 then
            if (not lz or EquipBackpack) and (not EggConfig or not lF) or lx and lx and (not EggConfig and lx) or lx and not EggConfig and (EggConfig or lx) and (not lz and lF or not EggConfig and not EquipBackpack) or not ((not lz or EquipBackpack) and (not EggConfig or not lF) or lx and lx and (not EggConfig and lx) or lx and not EggConfig and (EggConfig or lx) and (not lz and lF or not EggConfig and not EquipBackpack)) then
                lI = lw:WaitForChild("KickService")
            else
                lw = lI:WaitForChild("KickService")
            end
            lz = (lz + 57) % 136
        else
            lR = {
                "wtzllqrzv",
                "fnuo",
                "lcdghcitr",
                "rsvtevu",
                "yblomnlv",
                "famklwsc",
                "winbpvqn",
                "enigjm",
                "irjqwj",
                "eynqwhc",
                "kobp",
                "uvckpiw"
            }
            local rZ = lz
            lS = lR[rZ % 12 + 1]
            if lS:len() <= lS:reverse():rep(rZ % 3 + 2):len() then
                lH = lw:WaitForChild("RebirthService")
            else
                lw = lH:WaitForChild("RebirthService")
            end
            lz = (lz + 23) % 136
        end
    elseif lQ <= 26 then
        if lQ <= 22 then
            if lQ <= 20 then
                if lQ <= 19 then
                    if lQ <= 18 then
                        if (not lP or not lP or (ly or not lG) or (not lG or not lN or not lN and not EquipBackpack)) and ((not EquipBackpack and not EquipBackpack or (not lN or not ly)) and (not lP and ly or (not ly or lP))) or ((lG or not lN or (lG or not lP)) and ((not lP or lP) and (not lG and lP)) or (not lN or not lN or EquipBackpack and not lP) and (ly and lP or (not ly or lG))) or not ((not lP or not lP or (ly or not lG) or (not lG or not lN or not lN and not EquipBackpack)) and ((not EquipBackpack and not EquipBackpack or (not lN or not ly)) and (not lP and ly or (not ly or lP))) or ((lG or not lN or (lG or not lP)) and ((not lP or lP) and (not lG and lP)) or (not lN or not lN or EquipBackpack and not lP) and (ly and lP or (not ly or lG)))) then
                            lG = lw:WaitForChild("BoostService")
                        else
                            lw = lG:WaitForChild("BoostService")
                        end
                        lz = (lz + 23) % 136
                    else
                        local rV = bit32.rrotate(bit32.bxor(bit32.lrotate(lz, 12), string.byte(tostring(lK))), 30)
                        if bit32.bxor(bit32.lrotate(bit32.bxor(rV, 1106786153), 24), 1765931063) ~= bit32.lrotate(rV, 24) then
                            lw = lF:WaitForChild("UpgradesService")
                        else
                            lF = lw:WaitForChild("UpgradesService")
                        end
                        lz = (lz + 125) % 136
                    end
                else
                    lR = { "kdddjdomo", "lfyqkrmua", "atgkbboj", "tqdn", "ammha", "obompmktwu", "wnzqrdy", "lwetxpzibadk" }
                    if lR[(lz * 22 + 110) % 8 + 1] < lR[(lz * 22 + 110) % 8 + 1] then
                        lw = lE:WaitForChild("BackpackService")
                    else
                        lE = lw:WaitForChild("BackpackService")
                    end
                    lz = (lz + 57) % 136
                end
            elseif lQ <= 21 then
                if (not lA and not lH or not lO and not lO or (not lH and lO or lH and lH)) and (lH or lH or (lH or lO) or (not lH or lH) and (not lH and lA)) and not ((not lA and not lH or not lO and not lO or (not lH and lO or lH and lH)) and (lH or lH or (lH or lO) or (not lH or lH) and (not lH and lA))) then
                    lw = lD:WaitForChild("EggService")
                else
                    lD = lw:WaitForChild("EggService")
                end
                lz = (lz + 23) % 136
            else
                lR = (vector.create((lz * 3 + 2) % 11 + 1, (lz * 4 + 12) % 13 + 1, (lz * 15 + 16) % 17 + 1))
                lS = (vector.create((lz * 1 + 2) % 11 + 1, (lz * 7 + 9) % 13 + 1, (lz * 1 + 17) % 17 + 1))
                lT = (vector.create((lz * 3 + 1) % 11 + 1, (lz * 6 + 3) % 13 + 1, (lz * 8 + 15) % 17 + 1))
                lU = (vector.create((lz * 3 + 4) % 11 + 1, (lz * 9 + 6) % 13 + 1, (lz * 8 + 16) % 17 + 1))
                if vector.dot(vector.cross(lR, lS), (vector.cross(lT, lU))) == vector.dot(lR, lT) * vector.dot(lS, lU) - vector.dot(lR, lU) * vector.dot(lS, lT) then
                    lC = lw:WaitForChild("TitleService")
                else
                    lw = lC:WaitForChild("TitleService")
                end
                lz = (lz + 57) % 136
            end
        elseif lQ <= 24 then
            if lQ <= 23 then
                lR = {
                    "xenftxn",
                    "ydomrb",
                    "vtseoep",
                    "zluidi",
                    "kvbks",
                    "rkyr",
                    "xiwh",
                    "uupkhcwww",
                    "evksthszqiq",
                    "pohgsu",
                    "drprplwu",
                    "xrps"
                }
                local r9 = lz
                lS = lR[r9 % 12 + 1]
                if lS:len() >= lS:gsub("(.)", "%1%1", r9 % 3 % 2 + 1):len() then
                    lw = lB:WaitForChild("PetsService")
                else
                    lB = lw:WaitForChild("PetsService")
                end
                lz = (lz + 23) % 136
            else
                lR = (vector.create((lz * 3 + 8) % 11 + 1, (lz * 9 + 12) % 13 + 1, (lz * 6 + 5) % 17 + 1))
                lS = (vector.create((lz * 7 + 7) % 11 + 1, (lz * 7 + 6) % 13 + 1, (lz * 7 + 14) % 17 + 1))
                lT = (vector.create((lz * 3 + 6) % 11 + 1, (lz * 2 + 2) % 13 + 1, (lz * 13 + 14) % 17 + 1))
                lU = (vector.create((lz * 6 + 1) % 11 + 1, (lz * 7 + 8) % 13 + 1, (lz * 7 + 9) % 17 + 1))
                if vector.dot(vector.cross(lR, lS), (vector.cross(lT, lU))) == vector.dot(lR, lT) * vector.dot(lS, lU) - vector.dot(lR, lU) * vector.dot(lS, lT) then
                    HitWall = lK:WaitForChild("RF"):WaitForChild("HitWall")
                else
                    lK = HitWall:WaitForChild("RF"):WaitForChild("HitWall")
                end
                lz = (lz + 23) % 136
            end
        elseif lQ <= 25 then
            lR = {
                "duhtrhkzo",
                "wyrbklrnox",
                "jhetoxzxdq",
                "ryfnxjdksqp",
                "epawvwgyh",
                "zgir",
                "jck",
                "ccatrayo",
                "oewmg"
            }
            local rD = lz
            lS = lR[rD % 9 + 1]
            if lS:len() >= lS:gsub("(.)", "%1%1", rD % 3 % 2 + 1):len() then
                kT = lJ:WaitForChild("RF"):WaitForChild("IsStageComplete")
                lK = ClaimReward2x:WaitForChild("RF"):WaitForChild("ClaimReward")
                kW = ClaimReward2x:WaitForChild("RF"):WaitForChild("ClaimReward2x")
            else
                kW = lK:WaitForChild("RF"):WaitForChild("IsStageComplete")
                kT = lJ:WaitForChild("RF"):WaitForChild("ClaimReward")
                ClaimReward2x = lJ:WaitForChild("RF"):WaitForChild("ClaimReward2x")
            end
            lz = (lz + 125) % 136
        else
            lR = { "qpefqbhn", "nttpgxj", "pviztxeomb", "vlcs", "kod", "cfzfwdogu", "cgcegvg", "vjoqd" }
            local rY = lz
            lS = lR[rY % 8 + 1]
            if lS:len() >= lS:gsub("(.)", "%1%1", rY % 3 % 2 + 1):len() then
                lJ = OwnsWinsGamepass:WaitForChild("RF"):WaitForChild("OwnsWinsGamepass")
            else
                OwnsWinsGamepass = lJ:WaitForChild("RF"):WaitForChild("OwnsWinsGamepass")
            end
            lz = (lz + 23) % 136
        end
    elseif lQ <= 30 then
        if lQ <= 28 then
            if lQ <= 27 then
                lR = (vector.create((lz * 7 + 8) % 11 + 1, (lz * 5 + 6) % 13 + 1, (lz * 11 + 2) % 17 + 1))
                lS = (vector.create((lz * 5 + 9) % 11 + 1, (lz * 1 + 12) % 13 + 1, (lz * 13 + 16) % 17 + 1))
                local rL = vector.dot(lR, lS)
                if rL * rL <= vector.dot(lR, lR) * vector.dot(lS, lS) then
                    AddKick = lI:WaitForChild("RF"):WaitForChild("AddKick")
                    kC = lH:WaitForChild("RF"):WaitForChild("Rebirth")
                    PurchaseBoost = lG:WaitForChild("RF"):WaitForChild("PurchaseBoost")
                else
                    lH = PurchaseBoost:WaitForChild("RF"):WaitForChild("AddKick")
                    lI = lG:WaitForChild("RF"):WaitForChild("Rebirth")
                    kC = AddKick:WaitForChild("RF"):WaitForChild("PurchaseBoost")
                end
                lz = (lz + 91) % 136
            else
                lR = { "wqogx", "prpykd", "bcwdakjijz", "qxnpeofyitb", "vwixo", "kulpocrtuhb", "runsyxpldac", "pnf" }
                local r5 = lz
                lS = lR[r5 % 8 + 1]
                if lS:len() >= lS:reverse():rep(r5 % 3 + 2):len() then
                    lF = Purchase:WaitForChild("RF"):WaitForChild("Purchase")
                else
                    Purchase = lF:WaitForChild("RF"):WaitForChild("Purchase")
                end
                lz = (lz + 57) % 136
            end
        elseif lQ <= 29 then
            lR = (vector.create((lz * 4 + 6) % 11 + 1, (lz * 9 + 8) % 13 + 1, (lz * 4 + 11) % 17 + 1))
            lS = (vector.create((lz * 4 + 3) % 11 + 1, (lz * 11 + 10) % 13 + 1, (lz * 1 + 1) % 17 + 1))
            lT = (vector.create((lz * 1 + 3) % 11 + 1, (lz * 11 + 4) % 13 + 1, (lz * 12 + 11) % 17 + 1))
            if vector.dot(vector.cross(lR, lS), lT) == vector.dot(vector.cross(lS, lT), lR) then
                kq = lE:WaitForChild("RF"):WaitForChild("UnlockBackpack")
                EquipBackpack = lE:WaitForChild("RF"):WaitForChild("EquipBackpack")
                OpenEgg = lD:WaitForChild("RF"):WaitForChild("OpenEgg")
            else
                lE = EquipBackpack:WaitForChild("RF"):WaitForChild("UnlockBackpack")
                kq = EquipBackpack:WaitForChild("RF"):WaitForChild("EquipBackpack")
                lD = OpenEgg:WaitForChild("RF"):WaitForChild("OpenEgg")
            end
            lz = (lz + 91) % 136
        else
            local rh = bit32.rrotate(bit32.bxor(bit32.lrotate(lz, 1), string.byte(tostring(ly))), 13)
            if bit32.bxor(bit32.lrotate(bit32.bxor(rh, 3737960265), 26), 662385405) ~= bit32.lrotate(rh, 26) then
                lB = lO:WaitForChild("RF"):WaitForChild("OpenEggMulti")
                lu = lD:WaitForChild("RF"):WaitForChild("Roll")
                lC = lD:WaitForChild("RF"):WaitForChild("Equip")
                kj = Equip:WaitForChild("RF"):WaitForChild("SetEquipped")
                kg = {}
            else
                kj = lD:WaitForChild("RF"):WaitForChild("OpenEggMulti")
                kg = lC:WaitForChild("RF"):WaitForChild("Roll")
                Equip = lC:WaitForChild("RF"):WaitForChild("Equip")
                lu = lB:WaitForChild("RF"):WaitForChild("SetEquipped")
                lO = {}
            end
            lz = (lz + 23) % 136
        end
    elseif lQ <= 32 then
        if lQ <= 31 then
            lR = {
                "gexi",
                "bkvivhzhbnx",
                "ducuxfjzrixt",
                "nfjnal",
                "hjshqoc",
                "dopv",
                "uxofjcb",
                "kmzxbk",
                "jmh",
                "ahafnft",
                "ebrzedkeu"
            }
            if lR[(lz * 32 + 38) % 11 + 1] <= lR[(lz * 32 + 38) % 11 + 1] then
                lv_1 = game:GetService("Players")
            else
                lE = game:GetService("Players")
            end
            lz = (lz + 23) % 136
        else
            lR = { "ikbstccedc", "rzamf", "iousc", "wrad", "qnxieolw", "xopqsvoodq", "nvnyf", "ktoihonz" }
            local rR = lz
            lS = lR[rR % 8 + 1]
            if lS:len() <= lS:gsub("(.)", "%1%1", rR % 3 % 2 + 1):len() then
                lt = game:GetService("ReplicatedStorage")
            else
                lM = game:GetService("ReplicatedStorage")
            end
            lz = (lz + 23) % 136
        end
    elseif lQ <= 33 then
        lQ = {
            "qgvde",
            "dyohcbhlr",
            "ppyfm",
            "gkrw",
            "kieh",
            "zyygzxp",
            "pfts",
            "jwog",
            "zkzhtosemag",
            "gskuxzyxjmh",
            "xelqokns",
            "fbkrxnvuh",
            "yidc",
            "dtk",
            "jcwrtcqkzuit",
            "bfdbujvdo"
        }
        if lQ[(lz * 32 + 34) % 16 + 1] <= lQ[(lz * 32 + 34) % 16 + 1] then
            lP = game:GetService("UserInputService")
            lm = game:GetService("VirtualUser")
            lh = game:GetService("Workspace")
        else
            lm = game:GetService("UserInputService")
            lh = game:GetService("VirtualUser")
            lP = game:GetService("Workspace")
        end
        lz = (lz + 23) % 136
    else
        local rT = bit32.rrotate(bit32.bxor(bit32.lrotate(lz, 21), string.byte(tostring(lt))), 23)
        if bit32.bxor(bit32.lrotate(bit32.bxor(rT, 620166830), 30), 2302525355) ~= bit32.lrotate(rT, 30) then
            lv_1 = lf.LocalPlayer
        else
            lf = lv_1.LocalPlayer
        end
        lz = (lz + 57) % 136
    end
until (lz * 103 + 34) % 136 == 59
local lY = 1
local lW = k2
while lY <= lW do
    local lZ = lY
    lO[lZ] = "Plate " .. lZ
    lY += 1
end
li = {}
for k, v in pairs(lL.Backpacks) do
    local lv_2 = #li + 1
    lw = v.Order or 0
    lx = v.WinsNeeded or 0
    ly = v.DamagePerClick or 0
    lz = v.ProductId
    lA = v.GamepassId or v.LegacyGamepassId
    li[lv_2] = { Key = k, Order = lw, WinsNeeded = lx, DamagePerClick = ly, ProductId = lz, GamepassId = lA }
end
k0 = nil
lz = 3
repeat
    if (lz * 2 + 5) * 7 % 3 == ((lz * 2 + 5) * 7 + 0) % 3 then
        table.sort(li, fn295)
        k0 = {}
    else
        table.sort(k0, fn295)
        li = {}
    end
    lz = (lz + 2) % 4
until (lz * 3 + 0) % 4 == 3
for k in pairs(lM.Boosts) do
    k0[#k0 + 1] = k
end
kX, kU = nil, nil
local lv_3 = 0
repeat
    lw = (lv_3 * 1 + 0) % 2 + 1
    if lw <= 1 then
        if (not kU or lv_3) and (lv_3 and not kX) or (lv_3 or kU or not lv_3 and kU) or (not kU and kX or not lv_3 and not kU) and (not kU and not kX and (lv_3 or kU)) or (lv_3 and not lv_3 or (kX or not kX)) and ((kX or lv_3) and (kU and not lv_3)) and (not kU and kX or (not kU or not kU) or kU and lv_3 and (not kU and not lv_3)) or not ((not kU or lv_3) and (lv_3 and not kX) or (lv_3 or kU or not lv_3 and kU) or (not kU and kX or not lv_3 and not kU) and (not kU and not kX and (lv_3 or kU)) or (lv_3 and not lv_3 or (kX or not kX)) and ((kX or lv_3) and (kU and not lv_3)) and (not kU and kX or (not kU or not kU) or kU and lv_3 and (not kU and not lv_3))) then
            table.sort(k0)
            kX = { "ClickSpeed", "TrainingSpeed", "Walkspeed" }
        else
            table.sort(kX)
            k0 = { "Walkspeed", "ClickSpeed", "TrainingSpeed" }
        end
        lv_3 = (lv_3 + 11) % 16
    else
        if (lv_3 * 3 + 5) * 17 % 4 == ((lv_3 * 3 + 5) * 17 + 11) % 4 then
            kX = {}
        else
            kU = {}
        end
        lv_3 = (lv_3 + 15) % 16
    end
until (lv_3 * 9 + 6) % 16 == 0
for k, v in pairs(EggConfig.Eggs) do
    local lv_4 = type(v) == "table"
    if lv_4 then
        lw = tonumber(v.WinCost) or 0
        lv_4 = lw > 0
    end
    if lv_4 then
        kU[#kU + 1] = k
    end
end
kl = nil
table.sort(kU, fn379)
lw = { "1", "3" }
kl = {}
lx = KickBagConstants.Bags or {}
for i, v in ipairs(lx) do
    local lv_6 = not v.GamepassId
    if lv_6 ~= false then
        lv_6 = not v.ProductId
    end
    if lv_6 then
        local lv_7 = #kl + 1
        lx = v.Name
        ly = v.Multiplier or 1
        lz = v.RebirthsRequired or 0
        kl[lv_7] = { Name = lx, Multiplier = ly, RebirthsRequired = lz }
    end
end
Library, Toggles, Options, ls, ko, k1, kQ, kE, kr, lj, k6, kR = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(kl, fn677)
Library = getgenv().Library
lF = getgenv().ThemeManager
lE = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
k1 = fn818
kQ = fn515
kE = fn449
kr = fn762
lB = "#7fd47f"
lD = "#6ec1ff"
if (kQ and not kr and "#7fd47f" or (not kr and not kr or not Toggles and lB)) and not (kQ and not kr and "#7fd47f" or (not kr and not kr or not Toggles and lB)) then
    lD = "#e8a34d"
else
    ls = "#e8a34d"
end
if lj and not kr and (not kr and kr) and (lj or not kr or (not lj or not kr)) or (kr or not kr or not lj and kr) and ((kr or kr) and (kr and kr)) or not (lj and not kr and (not kr and kr) and (lj or not kr or (not lj or not kr)) or (kr or not kr or not lj and kr) and ((kr or kr) and (kr and kr))) then
    lC = "#8b93a3"
    lj = fn37
    k6 = fn149
else
    k6 = "#8b93a3"
    lC = fn37
    lj = fn149
end
kR = fn633
ko = nil
pcall(fn192)
ReplicaController.ReplicaOfClassCreated("PlayerData", fn447)
for k, v in pairs(ReplicaController._replicas) do
    if v.Data and v.Data.Wins ~= nil then
        ko = v
        break
    end
end
kG, kB, lr, le, kN, ki, ln, k3, kw, kd, lo, k_, kk, lp, k4, ky, kL, kz, ld, ll, kZ, kA, kp, kV, kJ, lb = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lr = fn811
le = fn841
kN = fn104
ki = fn682
ln = fn185
k3 = fn344
kG = false
kB = 0
kw = fn592
kd = fn41
lo = function(cd)
    local nB_1
    local nA_1
    nA_1, nB_1 = pcall(function()
        return kW:InvokeServer(cd)
    end)
    return nA_1 and nB_1 == true
end
k_ = function(ck)
    local nG_1, nG_2, nG_3
    local nF_1, nF_2, nF_3
    if kG then
        nF_1, nG_1 = pcall(function()
            return ClaimReward2x:InvokeServer(ck)
        end)
        if nF_1 and nG_1 == true then
            return true
        end
        nF_2, nG_2 = pcall(function()
            return kT:InvokeServer(ck)
        end)
        return nF_2 and nG_2 == true
    end
    nF_3, nG_3 = pcall(function()
        return kT:InvokeServer(ck)
    end)
    return nF_3 and nG_3 == true
end
kk = fn807
lp = fn567
k4 = fn656
ky = fn34
kL = fn724
kz = function()
    local ot
    ot = k4()
    local ou = ky(ot)
    if ou then
        local ov = lf.Character and lf.Character:FindFirstChild("HumanoidRootPart")
        local ow = ov
        if ov then
            ov = (ow.Position - ou.Position).Magnitude > 8
        end
        if ov then
            ki(ou.CFrame + Vector3.new(0, 3, 0))
        end
    end
    pcall(function()
        AddKick:InvokeServer(ot)
    end)
end
ld = function()
    local oG_1
    local oF_2
    local oC = le()
    local oD = k3()
    local oE = -1
    local oB
    for i, v in ipairs(li) do
        local oP = v
        if not oP.ProductId and not oP.GamepassId then
            if oD[oP.Key] then
                if oP.DamagePerClick > oE then
                    oE = oP.DamagePerClick
                    oB = oP.Key
                end
            elseif oP.WinsNeeded <= oC then
                oF_2, oG_1 = pcall(function()
                    return kq:InvokeServer(oP.Key)
                end)
                if oF_2 and oG_1 == true then
                    oD[oP.Key] = true
                    if oP.DamagePerClick > oE then
                        oE = oP.DamagePerClick
                        oB = oP.Key
                    end
                end
            end
        end
    end
    local oF_3 = lr()
    if oB and oB ~= (oF_3 and oF_3.EquippedBackpack) then
        pcall(function()
            EquipBackpack:InvokeServer(oB)
        end)
    end
end
ll = function()
    for i, v in ipairs(k0) do
        local oW = v
        pcall(function()
            PurchaseBoost:InvokeServer(oW)
        end)
    end
end
kZ = function()
    for i, v in ipairs(kX) do
        local o2 = v
        pcall(function()
            Purchase:InvokeServer(o2)
        end)
    end
end
kA = fn28
kp = function()
    local o3
    o3 = k6("EggChoice")
    local o4 = o3 == ""
    local o4_2
    local o5 = type(o3) ~= "string" or o4
    local o5_2
    if o5 then
        o3 = kU[1]
    end
    if not o3 then
        return
    end
    local o4_1 = tonumber(k6("HatchAmount")) or 1
    if o4_1 >= 3 then
        o4_2, o5_2 = pcall(function()
            return kj:InvokeServer(o3, 3)
        end)
        local o6 = o4_2 and type(o5_2) == "table" and o5_2.Error == "TripleLocked"
        if o6 then
            local pd = 1
            while pd <= 3 do
                pcall(function()
                    OpenEgg:InvokeServer(o3)
                end)
                pd += 1
            end
        end
        return
    end
    pcall(function()
        OpenEgg:InvokeServer(o3)
    end)
end
kV = fn579
kJ = function()
    local ph = lr()
    if not ph then
        return
    end
    local pi = {}
    if type(ph.OwnedTitles) == "table" then
        for i, v in ipairs(ph.OwnedTitles) do
            pi[v] = true
        end
    end
    local Name
    local pj = -math.huge
    local pl = TitleConfig.Titles or {}
    for i, v in ipairs(pl) do
        local pk_1 = pi[v.Name]
        if pk_1 then
            pk_1 = (v.Multiplier or 0) > pj
        end
        if pk_1 then
            Name = v.Name
            pj = v.Multiplier or 0
        end
    end
    if Name and Name ~= ph.Title then
        pcall(function()
            Equip:InvokeServer(Name)
        end)
    end
end
lb = function()
    local pH = lr()
    local pI = not pH or type(pH.Pets) ~= "table"
    if pI then
        return
    end
    local min = math.min
    local pJ = tonumber(pH.PetSlots) or 1
    local pK = min(pJ, 10)
    local pI_2 = {}
    for i, v in ipairs(pH.Pets) do
        local pF
        local pU = v
        pF = 0
        pcall(function()
            local pz = (PetConfig.getPetMultiplier(pU))
            local pD = if pz then 1 else 0
            local pB = 664 * pD + 1894 * (1 - pD)
            local pC = 331 * pD + 3839 * (1 - pD)
            if not ((pB * 754 + pC * 3804 + pB * pC) % 16777213 == 1979564) then
                pz = 0
            end
            pF = pz
        end)
        pI_2[#pI_2 + 1] = { Index = i, Multiplier = pF }
    end
    table.sort(pI_2, function(eS, eT)
        if eS.Multiplier == eT.Multiplier then
            return eS.Index < eT.Index
        end
        return eS.Multiplier > eT.Multiplier
    end)
    local pG = {}
    local pJ_1 = math.min(pK, #pI_2)
    local pX = 1
    while pX <= pJ_1 do
        local pY = pX
        pG[pY] = pI_2[pY].Index
        pX += 1
    end
    local pJ_2 = pH.Equipped or {}
    local pI_4 = #pJ_2 == #pG
    if pI_4 then
        local pJ_3 = {}
        for i, v in ipairs(pJ_2) do
            pJ_3[v] = true
        end
        for i, v in ipairs(pG) do
            if not pJ_3[v] then
                pI_4 = false
                break
            end
        end
    end
    local pH_2 = not pI_4
    if pH_2 ~= false then
        pH_2 = #pG > 0
    end
    if pH_2 then
        pcall(function()
            lu:InvokeServer(pG)
        end)
    end
end
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = la, Copyable = true }, "|", lN },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
lz = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "keyboard"),
    Settings = Window:AddTab("Settings", "settings")
}
lz.Farm = lz.Main:AddSubTab("Farm", "keyboard")
lz.Shop = lz.Main:AddSubTab("Shop", "shopping-bag")
lz.Eggs = lz.Main:AddSubTab("Eggs", "egg")
lz.Extra = lz.Main:AddSubTab("Extra", "sparkles")
ly = fn393
for k, v in lz do
    if v ~= lz.Main then
        ly(v)
    end
end
kD, lG, Label, kf, lA = nil, nil, nil, nil, nil
local lv_10 = 21
repeat
    ly = (lv_10 * 1 + 0) % 3 + 1
    if ly <= 2 then
        if ly <= 1 then
            ly = (vector.create((lv_10 * 1 + 2) % 11 + 1, (lv_10 * 11 + 1) % 13 + 1, (lv_10 * 1 + 16) % 17 + 1))
            lH = (vector.create((lv_10 * 1 + 4) % 11 + 1, (lv_10 * 9 + 9) % 13 + 1, (lv_10 * 13 + 12) % 17 + 1))
            lI = (vector.create((lv_10 * 7 + 9) % 11 + 1, (lv_10 * 2 + 12) % 13 + 1, (lv_10 * 4 + 12) % 17 + 1))
            lJ = (vector.create((lv_10 * 4 + 3) % 5 + 1, (lv_10 * 2 + 3) % 7 + 1, (lv_10 * 2 + 4) % 9 + 1))
            if vector.dot(vector.cross(ly, (vector.cross(lH, lI))), lJ) == vector.dot(lH * vector.dot(ly, lI) - lI * vector.dot(ly, lH), lJ) then
                kD = "Unknown"
                pcall(fn32)
                lx = lz.Info:AddLeftGroupbox("Account", "circle-user")
                lx:AddLabel(kr("User", lf.Name, lB), true)
                lx:AddLabel(kr("Status", "Keyless", lB), true)
                lx:AddLabel(kr("Executor", kD, lB), true)
                lG = lz.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                lG:AddLabel(kE(lN .. " [" .. tostring(game.PlaceId) .. "]", lD), true)
                lG:AddLabel(kr("Place ID", tostring(game.PlaceId), lD), true)
                Label = lG:AddLabel(kr("Session time", "0s", ls), true)
            else
                kE = "Unknown"
                pcall(fn32)
                lf = (nil):AddLeftGroupbox("Account", "circle-user")
                lf:AddLabel(lG("User", kD.Name, kr), true)
                lf:AddLabel(lG("Status", "Keyless", kr), true)
                lf:AddLabel(lG("Executor", kE, kr), true)
                lx = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                lx:AddLabel(lz(Label .. " [" .. tostring(game.PlaceId) .. "]", lN), true)
                lx:AddLabel(lG("Place ID", tostring(game.PlaceId), lN), true)
                lD = lx:AddLabel(lG("Session time", "0s", lB), true)
            end
            lv_10 = (lv_10 + 16) % 24
        else
            ly = (vector.create((lv_10 * 4 + 2) % 11 + 1, (lv_10 * 8 + 8) % 13 + 1, (lv_10 * 5 + 10) % 17 + 1))
            lH = (vector.create((lv_10 * 7 + 6) % 11 + 1, (lv_10 * 1 + 1) % 13 + 1, (lv_10 * 13 + 14) % 17 + 1))
            local rj = vector.cross(ly, lH)
            local rk = vector.dot(ly, lH)
            if vector.dot(rj, rj) + rk * rk == vector.dot(ly, ly) * vector.dot(lH, lH) then
                kf = tostring(game.JobId)
            end
            lv_10 = (lv_10 + 22) % 24
        end
    else
        local r1 = bit32.rrotate(bit32.bxor(bit32.lrotate(lv_10, 11), string.byte(tostring(Label))), 24)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(r1, 875311817), 957929629), (bit32.bxor(bit32.band(r1, 3419655478), 2275997164))), 957929629), 2275997164) ~= r1 then
            kf = #lA > 18
        else
            lA = #kf > 18
        end
        lv_10 = (lv_10 + 22) % 24
    end
until (lv_10 * 23 + 4) % 24 == 19
if lA then
    local lv_11 = 2
    repeat
        lx = { "gtwxjjaeapu", "bofs", "nqnbs", "jrtcmis", "etkwnmiejmf", "hisvzppz", "ehd", "ekljobwwx" }
        local r4 = lv_11
        ly = lx[r4 % 8 + 1]
        if ly:len() >= ly:gsub("(.)", "%1%1", r4 % 3 % 2 + 1):len() then
            kf = string.sub(lA, 1, 18) .. "..."
        else
            lA = string.sub(kf, 1, 18) .. "..."
        end
        lv_11 = (lv_11 + 1) % 4
    until (lv_11 * 3 + 0) % 4 == 1
end
local lv_12 = lA or kf
lc = nil
lL = lv_12
lG:AddLabel(kr("Server", lL, lC), true)
lG:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
lc = os.clock()
task.spawn(worker)
lK = lz.Info:AddRightGroupbox("Scripts", "package")
lK:AddLabel(kE("Included in this hub", lC), true)
lK:AddLabel(kE(lN, lD), true)
lJ = lz.Info:AddRightGroupbox("Features", "list")
lJ:AddLabel(kE("Auto Farm", lD), true)
lJ:AddLabel(kE("Shop Automation", ls), true)
lJ:AddLabel(kE("Eggs & Pets", lD), true)
lJ:AddLabel(kE("Titles", ls), true)
lJ:AddLabel(kE("Wall Breaker", lC), true)
lI = lz.Info:AddRightGroupbox("Socials", "link")
lI:AddButton({ Text = "Discord", Func = kQ })
lI:AddButton({ Text = "Rscripts", Func = onRscripts })
lH = lz.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
lH:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
lH:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
lH:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
lH:AddButton({ Text = "Copy Discord Invite", Func = kQ })
lB = lz.Info:AddRightGroupbox("FAQ", "circle-help")
lB:AddLabel("Where do I get a good config?", true)
lB:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
lB:AddLabel("How do I import / export configs?", true)
lB:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
lB:AddLabel("How do I report bugs?", true)
lB:AddLabel("Join the Discord and post it in the bugs channel.", true)
lB:AddLabel("How do I make suggestions?", true)
lB:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
lB:AddLabel("How do I get help or updates?", true)
lB:AddLabel("Join the Discord, updates and support are posted there first.", true)
lA = lz.Farm:AddLeftGroupbox("Farm", "keyboard")
lA:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
lA:AddDropdown("WinPlate", { Text = "Win plate", Values = lO, Default = "Plate 1" })
lA:AddToggle("FastDestroyWall", { Text = "Fast Destroy Wall", Default = false })
lA:AddSlider("FastDestroySpeed", { Text = "Destroy speed", Default = 1, Min = 1, Max = 200, Rounding = 0 })
lA:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
lA:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
ly = lz.Shop:AddLeftGroupbox("Shop", "shopping-bag")
ly:AddToggle("AutoBuyPcs", { Text = "Auto Buy PCs", Default = false })
ly:AddToggle("AutoBuyBoosts", { Text = "Auto Buy Boosts", Default = false })
ly:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ly:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
lM = lz.Eggs:AddLeftGroupbox("Eggs", "egg")
lM:AddToggle("AutoHatchEggs", { Text = "Auto Hatch Eggs", Default = false })
local lv_13 = kU[1] or "Basic"
lq, lk, connection, connection2, k7 = nil, nil, nil, nil, nil
lM:AddDropdown("EggChoice", { Text = "Egg", Values = kU, Default = lv_13 })
lM:AddDropdown("HatchAmount", { Text = "Amount", Values = lw, Default = "1" })
ly = lz.Extra:AddLeftGroupbox("Titles", "crown")
ly:AddToggle("AutoRollTitles", { Text = "Auto Roll Titles", Default = false })
ly:AddToggle("AutoEquipBestTitle", { Text = "Auto Equip Best Title", Default = false })
lx = lz.Extra:AddRightGroupbox("Pets", "paw-print")
lx:AddToggle("AutoEquipBestPet", { Text = "Auto Equip Best Pet", Default = false })
lB = lz.Settings:AddLeftGroupbox("Menu", "menu")
lB:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
lB:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lB:AddButton({ Text = "Unload", Func = onUnload })
lF:SetLibrary(Library)
lF:SetFolder("TempoHub")
lF:SaveDefault("Monochrome")
lF:ApplyToTab(lz.Settings)
lF:LoadDefault()
lE:SetLibrary(Library)
lE:IgnoreThemeSettings()
lE:SetIgnoreIndexes({ "MenuKeybind" })
lE:SetFolder("TempoHub/+1-hack-per-click")
lE:BuildConfigSection(lz.Settings)
lE:LoadAutoloadConfig()
lq = tick()
lk = tick()
pcall(function()
    for i, v in ipairs(getconnections(lf.Idled)) do
        local qw = v
        pcall(function()
            qw:Disable()
        end)
    end
end)
k7 = fn833
connection = lP.InputBegan:Connect(onInputBegan)
connection2 = lP.InputChanged:Connect(onInputChanged)
if (lx and lx and 18 or not lx and not k7 and (k7 and false)) and not (lx and lx and 18 or not lx and not k7 and (k7 and false)) then
    kw:OnUnload(fn555)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    Library()
else
    Library:OnUnload(fn555)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    kw()
end
end)(...)
