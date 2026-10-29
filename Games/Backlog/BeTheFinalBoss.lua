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
getgenv().TempoHoodSubtitle = "BE THE FINAL BOSS"
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
local lL
local ms
local l9
local lR
local my
local mf
local BossRoomWorldConfig
local mE
local ml
local l2
local lK
local mr
local l8
local mx
local me
local lW
local mD
local mk
local l1
local lJ
local l7
local lP
local LocalPlayer
local md
local lV
local mC
local Toggles
local UnitMutationConfig
local connection
local mp
local UnitConfig
local lO
local mv
local mc
local lU
local mB
local RemoteEvents
local l_
local lH
local mo
local l5
local SkillTreeNodesConfig
local mu
local mb
local connection2
local mh
local lZ
local mG
local lG
local mn
local Label
local lM
local mt
local PlayerDataClient
local lS
local VirtualUser
local mg
local lY
local mF
local mm
local l3
local function onOnClientEvent(gw)
    local rz = type(gw) == "table" and gw.ownerUserId == LocalPlayer.UserId and gw.reason == "Roll"
    if rz then
        mE = os.clock()
    end
end
local function autoSkillTreeLoop()
    while not ms.Unloaded do
        if Toggles.AutoSkillTree.Value then
            local Value2 = mk.SkillCoinReserve.Value
            local Value = mk.SkillSoulReserve.Value
            local tf = {}
            local tg = { Coin = Value2, Soul = Value }
            for k, v in pairs(SkillTreeNodesConfig) do
                local td_1 = type(v) == "table" and v.isNavigation ~= true and type(v.storeItemKey) ~= "string"
                if td_1 then
                    local currency = v.currency
                    local te_1 = type(v.price) == "table" and tonumber(v.price.quantity)
                    local th = te_1 or nil
                    local te_2 = currency
                    if te_2 then
                        te_2 = th
                    end
                    if te_2 then
                        te_2 = mk.SkillCurrencies.Value[currency]
                    end
                    if te_2 then
                        te_2 = not l3(k)
                    end
                    if te_2 then
                        local te_3 = lP(v.parentNodeId) and lP(v.requiredNodeId)
                        if te_3 then
                            local te_4 = md(currency) - th
                            if te_4 >= (tg[currency] or 0) then
                                table.insert(tf, { id = k, price = th })
                            end
                        end
                    end
                end
            end
            table.sort(tf, function(iR, iS)
                if Toggles.SkillCheapestFirst.Value then
                    return iR.price < iS.price
                end
                return iR.price > iS.price
            end)
            local td_3 = tf[1]
            if td_3 then
                RemoteEvents.BossRoomUnlockSkillNode:FireServer(td_3.id)
                task.wait(0.5)
            end
        end
        task.wait(1)
    end
end
local function onInputChanged(eh)
    local UserInputType = eh.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        me = tick()
    end
end
local function fn71()
    if not Toggles.AutoBuyRoll.Value or not Toggles.BuyWaitForSouls.Value then
        return false
    end
    for k, v in mn() do
        local se_1 = mv(v) and not l2(v)
        if se_1 then
            return true
        end
    end
    return false
end
local function onRscripts()
    mc(mf)
    ms:Notify("Copied Rscripts profile to clipboard")
end
local function fn127(cg, ch)
    if ch == "Level" then
        return l8.getUnitLevel(cg)
    elseif ch == "Rarity" then
        return l8.getRarityTier(cg)
    else
        return l8.getUnitPower(cg)
    end
end
local function onInputBegan()
    me = tick()
end
local function fn166(a6)
    if a6:IsA("BasePart") then
        return a6
    end
    local ob = a6.PrimaryPart or a6:FindFirstChild("HumanoidRootPart") or a6:FindFirstChildWhichIsA("BasePart", true)
    return ob
end
local function fn169(c_)
    if c_ == nil then
        return true
    end
    local pG = SkillTreeNodesConfig[c_]
    if type(pG) ~= "table" then
        return false
    elseif pG.isNavigation == true then
        return true
    else
        return l3(c_)
    end
end
local function fn173(bj, bk)
    local oo = bj.CFrame:PointToObjectSpace(bk)
    local op = math.abs(oo.X) <= bj.Size.X / 2 and math.abs(oo.Z) <= bj.Size.Z / 2
    return op
end
local function onCopyJoinScript_JobID()
    local dq = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, l_)
    mc(dq)
    ms:Notify("Copied join script to clipboard")
end
local function fn214(az, aA)
    return string.format('<font color="%s">%s</font>', aA, az)
end
local function antiAfkLoop()
    while not ms.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local p7 = tick() - me
            local p8 = tick() - l9
            if p7 >= 300 and p8 >= 60 then
                pcall(lV)
            else
                if p7 < 300 and p8 >= 300 then
                    pcall(lV)
                end
            end
        end
    end
end
local function fn245(ct)
    local pi_1
    local ph_1
    ph_1, pi_1 = UnitMutationConfig.decodeUnitId(ct)
    local pj = ph_1 and UnitConfig[ph_1]
    if not pj then
        return math.huge
    end
    local pj_1 = lY.getSummonCostForUnit(pj)
    local ph_3 = pj_1 and pj_1.soul
    local pj_2 = tonumber(ph_3) or 0
    return math.ceil(pj_2 * UnitMutationConfig.getCostMultiplier(pi_1))
end
local function fn247()
    local qu = lZ()
    local qv = lM(qu)
    if not qv then
        return false
    end
    local qw = l1(mk.PlaceUnits)
    local qx = {}
    for k, v in l8.getOwnedUnitKeys() do
        local qy_1 = next(qw) == nil or qw[v]
        if qy_1 then
            table.insert(qx, v)
        end
    end
    local qx_1 = l8.sortOwnedUnitKeys(qx, mk.PlacePriority.Value)
    local qw_1 = mu(qu)
    local Value2 = mk.PlaceLimit.Value
    local Value = mk.PlaceSpacing.Value
    if Value2 ~= 0 and #qw_1 >= Value2 then
        return false
    end
    local qy_3 = mt("BossPopulationRemaining", mt("BossRoomMinionsAvailable", 0))
    for k, v in qx_1 do
        local qx_2 = l8.getUnitPopulation(v)
        if qx_2 <= qy_3 then
            local qx_3 = mD(qv, qu, Value, mk.PlaceFormation.Value)
            for k, v2 in qx_3 do
                if lS(v2, qw_1, BossRoomWorldConfig.MINION_PLACEMENT_RADIUS) then
                    RemoteEvents.BossRoomPlaceMinion:FireServer(v2, v)
                    return true
                end
            end
            return false
        end
    end
    return false
end
local function fn267(ha)
    local hc = UnitMutationConfig.encodeUnitId(ha.unitKey, ha.mutation)
    return md("Soul") - mb(hc) >= mk.SoulReserve.Value
end
local function fn300(eY)
    local qj = {}
    for k, v in pairs(eY.Value) do
        if v then
            qj[k] = true
        end
    end
    return qj
end
local function fn312(bo, bp, bq)
    local ot = lZ()
    local ot_2
    local ou = ot and ot:FindFirstChild(BossRoomWorldConfig.HEROS_FOLDER_NAME)
    if not ou then
        return nil
    end
    local ou_1 = lM(ot)
    local ow = bq and not ou_1
    local ow_1
    if ow then
        return nil
    end
    ow_1, ot_2 = nil, bp
    for i, child in ou:GetChildren() do
        local Humanoid = child:FindFirstChildWhichIsA("Humanoid")
        local ox = mC(child)
        if ox and (not Humanoid or Humanoid.Health > 0) then
            local ov_2 = not bq or l5(ou_1, ox.Position)
            if ov_2 then
                local Magnitude = (ox.Position - bo).Magnitude
                if Magnitude <= ot_2 then
                    ow_1, ot_2 = ox, Magnitude
                end
            end
        end
    end
    return ow_1
end
local function fn317(bM, bN, bO)
    for k, v in bN do
        local oH = v - bM
        if Vector3.new(oH.X, 0, oH.Z).Magnitude < bO then
            return false
        end
    end
    return true
end
local function fn329()
    local nI = mm()
    for k, v in mr do
        if nI:find(v:lower(), 1, true) then
            return true
        end
    end
    return false
end
local function worker()
    local pU_1
    while true do
        task.wait(1)
        if ms.Unloaded then
            break
        end
        local pT = math.floor(os.clock() - lH)
        if pT < 60 then
            pU_1 = pT .. "s"
        elseif pT < 3600 then
            pU_1 = string.format("%dm %ds", math.floor((pT) / (60)), pT % 60)
        else
            pU_1 = string.format("%dh %dm", math.floor((pT) / (3600)), math.floor((pT % 3600) / (60)))
        end
        Label:SetText(lL("Session time", pU_1, my))
    end
end
local function worker2()
    while not ms.Unloaded do
        lJ()
        task.wait(0.05)
    end
end
local function fn358(e2, e3)
    local qr = os.clock() + e3
    while true do
        local qs = os.clock() < qr and not ms.Unloaded
        if not qs then
            return #mx() == e2
        end
        if #mx() == e2 then
            break
        end
        task.wait(0.1)
    end
    return true
end
local function fn363()
    local pr = PlayerDataClient.get("Summon")
    local ps = type(pr) ~= "table"
    local pw = if ps then 1 else 0
    local pu = 570 * pw + 2214 * (1 - pw)
    local pv = 3595 * pw + 2135 * (1 - pw)
    if not ((pu * 3669 + pv * 1357 + pu * pv) % 16777213 == 9018895) then
        ps = type(pr.currentOffers) ~= "table"
    end
    if ps then
        return {}
    end
    local ps_1 = {}
    for k, v in pairs(pr.currentOffers) do
        local pr_1 = type(v) == "table" and typeof(v.slotIndex) == "number" and v.unitKey
        if pr_1 then
            table.insert(ps_1, v)
        end
    end
    return ps_1
end
local function fn419(aC, aD, aE)
    return string.format("<b>%s</b> %s %s", aC, lU("-", "#5a6070"), lU(aD, aE))
end
local function onRefreshAllowedUnits()
    mk.ReplaceUnits:SetValues(l8.getOwnedUnitKeys())
    ms:Notify("Refreshed allowed units")
end
local function onClearAllPlacements()
    RemoteEvents.BossRoomClearMinions:FireServer()
    ms:Notify("Cleared all placements")
end
local function fn456()
    local o8 = PlayerDataClient.get("BossRoom")
    local o9 = type(o8) ~= "table" or type(o8.placements) ~= "table"
    if o9 then
        return {}
    end
    local o9_1 = {}
    for k, v in pairs(o8.placements) do
        local o8_1 = type(v) == "table" and v.unitKey
        if o8_1 then
            table.insert(o9_1, {
                id = k,
                unitId = UnitMutationConfig.encodeUnitId(v.unitKey, v.mutation),
                offset = Vector3.new(v.x, v.y, v.z)
            })
        end
    end
    return o9_1
end
local function autoUpgradeLoop()
    while not ms.Unloaded do
        local sA = false
        local sB = Toggles.AutoUpgrade.Value and mh() == "Preparing"
        if sB then
            local sB_1 = {}
            for k, v in pairs(mk.UpgradeUnits.Value) do
                if v then
                    sB_1[k] = true
                end
            end
            local sC = {}
            for k, v in l8.getOwnedUnitKeys() do
                local sD_1 = next(sB_1) == nil or sB_1[v]
                if sD_1 then
                    table.insert(sC, v)
                end
            end
            local sC_1 = l8.sortOwnedUnitKeys(sC, mk.UpgradePriority.Value)
            local sB_2 = tonumber(mk.UpgradeLevelCap.Value) or 0
            for k, v in sC_1 do
                local sB_3 = sB_2 == 0 or l8.getUnitLevel(v) < sB_2
                if sB_3 then
                    local sB_4 = l8.getFusionShardUpgradeInfo(v)
                    local sC_2 = sB_4.missingExperience
                    if mk.UpgradeMode.Value == "Max Level" and sB_2 == 0 then
                        sC_2 = sB_4.totalMissingExperience
                    end
                    local sE_1 = math.max(0, sB_4.count - mk.ShardReserve.Value)
                    if sC_2 > 0 and sE_1 > 0 then
                        local sB_6 = math.min(sC_2, sE_1)
                        if sB_6 == sC_2 or not Toggles.UpgradeFullStepsOnly.Value then
                            RemoteEvents.BossRoomUpgradeUnit:FireServer(v, sB_6)
                            sA = true
                            break
                        end
                    end
                end
            end
        end
        if sA then
            task.wait(mk.UpgradeDelay.Value)
        else
            task.wait(1)
        end
    end
end
local function autoBuyWeaponLoop()
    while not ms.Unloaded do
        if Toggles.AutoBuyWeapon.Value then
            local sX = PlayerDataClient.get("Weapon")
            if type(sX) == "table" then
                local sY = lR.getNextLockedWeapon(sX)
                if sY and sY.key then
                    local sX_2 = tonumber(sY.unlockCost) or 0
                    if md("Coin") - sX_2 >= mk.CoinReserve.Value then
                        RemoteEvents.BossRoomUpgradeWeapon:FireServer(sY.key)
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(1)
    end
end
local function fn491(a0)
    local n8 = a0 and a0:FindFirstChild(BossRoomWorldConfig.COMBAT_AREA_PART_NAME)
    local n9 = n8
    if n8 then
        n8 = n9:IsA("BasePart")
    end
    if n8 then
        return n9
    end
    return nil
end
local function fn495(at)
    if setclipboard then
        setclipboard(at)
    elseif toclipboard then
        toclipboard(at)
    end
end
local function fn513()
    local pM_1
    local pL_1
    if identifyexecutor then
        pM_1, pL_1 = identifyexecutor()
        local pN = pM_1 ~= ""
        local pO = type(pM_1) == "string" and pN
        if pO then
            local pN_1 = type(pL_1) == "string" and pL_1 ~= "" and pM_1 .. " " .. pL_1
            local pL_2 = pN_1
            local pS = if pL_2 then 1 else 0
            local pQ = 2392 * pS + 1553 * (1 - pS)
            local pR = 2087 * pS + 1276 * (1 - pS)
            if not ((pQ * 2494 + pR * 2883 + pQ * pR) % 16777213 == 197360) then
                pL_2 = pM_1
            end
            ml = pL_2
        end
    end
end
local function fn534(cF)
    local pl = UnitMutationConfig.decodeUnitId(cF)
    local pm = pl and UnitConfig[pl]
    local pl_1 = pm
    if pm then
        pm = pl_1.rarity
    end
    return pm or nil
end
local function fn552(aS)
    local nX = PlayerDataClient.get("Currency")
    if type(nX) ~= "table" then
        return 0
    end
    local n_ = (tonumber(nX[aS]))
    local n3 = if n_ then 1 else 0
    local n1 = 3161 * n3 + 67 * (1 - n3)
    local n2 = 3309 * n3 + 1298 * (1 - n3)
    if not ((n1 * 1198 + n2 * 2618 + n1 * n2) % 16777213 == 6132376) then
        n_ = 0
    end
    return math.max(0, math.floor(n_))
end
local function fn570()
    local n4 = mt("BossRoomInstanceName", "")
    if n4 == "" then
        return nil
    end
    local BLDS = workspace:FindFirstChild("BLDS")
    local n6 = BLDS and BLDS:FindFirstChild(n4)
    return n6 or nil
end
local function fn576()
    return mt("BossRoomBattleState", "Preparing")
end
local function fn577(gO)
    for k, v in pairs(gO.Value) do
        if v == true then
            return true
        end
    end
    return false
end
local function fn600()
    if not Toggles.AutoBuyRoll.Value then
        return
    end
    for k, v in mn() do
        local r6 = typeof(v.rollId) == "string" and mv(v) and l2(v)
        if r6 then
            RemoteEvents.BossRoomBuySummonOffer:FireServer(v.slotIndex, v.rollId)
            if mk.BuyDelay.Value > 0 then
                task.wait(mk.BuyDelay.Value)
            end
        end
    end
end
local function autoRollLoop()
    local sq_2
    while not ms.Unloaded do
        if not Toggles.AutoRoll.Value then
            task.wait(0.2)
        elseif mo() then
            task.wait(0.5)
        else
            local sp = false
            if Toggles.StopOnTarget.Value then
                for k, v in mn() do
                    local sq_1 = (lK(v))
                    if sq_1 then
                        local sr_1 = Toggles.AutoBuyRoll.Value and mv(v) and not l2(v)
                        sq_1 = not sr_1
                    end
                    if sq_1 then
                        sp = true
                        break
                    end
                end
            end
            if sp then
                Toggles.AutoRoll:SetValue(false)
                ms:Notify("Auto Roll paused on target result")
            else
                local sp_1 = os.clock()
                RemoteEvents.BossRoomRollSummonPool:FireServer()
                repeat
                    task.wait(0.05)
                    sq_2 = ms.Unloaded or not Toggles.AutoRoll.Value or mE > sp_1 or os.clock() - sp_1 >= 0.75
                until sq_2
                if mE > sp_1 then
                    lJ()
                    local sq_3 = math.max(mk.RollDelay.Value, lG)
                    local sr_2 = sq_3 - (os.clock() - sp_1)
                    if sr_2 > 0 then
                        task.wait(sr_2)
                    end
                end
            end
        end
    end
end
local function fn652()
    mc(mg)
    ms:Notify("Copied Discord invite to clipboard")
end
local function onUnload()
    ms:Unload()
end
local function fn668(cV)
    local pD = PlayerDataClient.get("SkillNodes")
    if type(pD) ~= "table" then
        return false
    end
    local pE = tonumber(pD[cV]) or 0
    return pE > 0
end
local function autoStartWaveLoop()
    while not ms.Unloaded do
        local ru = Toggles.AutoStartWave.Value and mh() == "Preparing"
        if ru then
            local ru_1 = lZ()
            local rv = #mu(ru_1) > 0
            local ru_2 = tonumber(mk.StopWave.Value) or 0
            local ru_3 = mt("BossRoomAbsoluteWave", 0)
            if Toggles.AutoStopAtWave.Value and ru_2 > 0 and ru_3 >= ru_2 then
                Toggles.AutoStartWave:SetValue(false)
                ms:Notify("Reached wave " .. ru_3 .. ", stopped auto start")
            elseif rv then
                RemoteEvents.BossRoomStartBattle:FireServer()
                task.wait(mk.StartWaveDelay.Value)
            end
        end
        task.wait(0.5)
    end
end
local function onRefreshOwnedUnits()
    mk.PlaceUnits:SetValues(l8.getOwnedUnitKeys())
    ms:Notify("Refreshed owned units")
end
local function fn694(c6)
    local DiscordGroup = c6:AddLeftGroupbox("Discord", nil, true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = l7 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = l7 })
end
local function fn714()
    local nC_1
    local nB_1
    nB_1, nC_1 = pcall(function()
        return identifyexecutor()
    end)
    local nD = not nB_1
    local nH = if nD then 1 else 0
    local nF = 2305 * nH + 3023 * (1 - nH)
    local nG = 3461 * nH + 2602 * (1 - nH)
    if not ((nF * 1802 + nG * 3251 + nF * nG) % 16777213 == 6605713) then
        nD = type(nC_1) ~= "string"
    end
    if nD then
        return ""
    end
    return nC_1:lower()
end
local function fn778(a9)
    local od = a9
    local oe = {}
    if od then
        od = a9:FindFirstChild(BossRoomWorldConfig.MINIONS_FOLDER_NAME)
    end
    local of = od
    if not of then
        return oe
    end
    for i, child in of:GetChildren() do
        local od_1 = mC(child)
        if od_1 then
            table.insert(oe, od_1.Position)
        end
    end
    return oe
end
local function fn787()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    l9 = tick()
end
local function autoPlaceLoop()
    while not ms.Unloaded do
        local rr = false
        if mh() == "Preparing" then
            local rs = Toggles.AutoPlace.Value and mB()
            if rs then
                rr = true
                task.wait(mk.PlaceDelay.Value)
            else
                local rs_1 = Toggles.AutoReplace.Value and mp()
                if rs_1 then
                    rr = true
                    task.wait(mk.ReplaceDelay.Value)
                end
            end
        end
        if not rr then
            task.wait(0.5)
        end
    end
end
local function fn868(aL, aM)
    local attr = LocalPlayer:GetAttribute(aL)
    if typeof(attr) ~= typeof(aM) then
        return aM
    end
    return attr
end
local function autoEquipWeaponLoop()
    local s2_1
    while not ms.Unloaded do
        if Toggles.AutoEquipWeapon.Value then
            local s0 = PlayerDataClient.get("Weapon")
            local s1 = type(s0) == "table" and type(s0.unlockedWeapons) == "table"
            local s1_1
            if s1 then
                s2_1, s1_1 = nil, -1
                for k, v in pairs(s0.unlockedWeapons) do
                    if v == true then
                        local s3_1 = lR.getDamage(k)
                        local s4 = type(s3_1) == "number" and s3_1 > s1_1
                        if s4 then
                            s2_1, s1_1 = k, s3_1
                        end
                    end
                end
                local s3_2 = s2_1 and lR.getCurrentWeaponKey(s0) ~= s2_1
                if s3_2 then
                    RemoteEvents.BossRoomUpgradeWeapon:FireServer(s2_1)
                    task.wait(0.5)
                end
            end
        end
        task.wait(1)
    end
end
local function fn916(gB)
    local rB = mG(gB.unitKey)
    local rC = UnitMutationConfig.normalize(gB.mutation)
    local rD = rB ~= nil and mk.BuyRarities.Value[rB] == true
    local rC_1 = rC ~= UnitMutationConfig.None and mk.BuyMutations.Value[rC] == true
    local rD_2 = mk.BuyUnits.Value[gB.unitKey] == true
    if Toggles.BuyRequireMutation.Value then
        return (rD or rD_2) and rC_1
    end
    return rD or rC_1 or rD_2
end
local function onRefreshOwnedUnits2()
    mk.UpgradeUnits:SetValues(l8.getOwnedUnitKeys())
    ms:Notify("Refreshed owned units")
end
local function fn959(gS)
    local StopRarities = mk.StopRarities
    local StopUnits = mk.StopUnits
    local StopMutations = mk.StopMutations
    local rU = lW(StopRarities)
    local rV = lW(StopUnits)
    local rW = lW(StopMutations)
    local rX = not rV
    local rY = not rU
    if rY ~= false then
        rY = rX
    end
    if rY and not rW then
        return false
    end
    local rX_2 = mG(gS.unitKey)
    local rY_1 = rU
    if rY_1 then
        rY_1 = rX_2 == nil or StopRarities.Value[rX_2] ~= true
    end
    if rY_1 then
        return false
    end
    if rV and StopUnits.Value[gS.unitKey] ~= true then
        return false
    elseif rW then
        local rR_2 = UnitMutationConfig.normalize(gS.mutation)
        if rR_2 == UnitMutationConfig.None or StopMutations.Value[rR_2] ~= true then
            return false
        end
        return true
    else
        return true
    end
end
local function fn991()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn994()
    local q4_1
    local q2_1
    local q3_2
    local q1_2
    local qX = lZ()
    local qY = lM(qX)
    local qX_1 = mx()
    local Value = mk.ReplaceMetric.Value
    if not qY or #qX_1 == 0 then
        return false
    end
    local q__1 = {}
    for k, v in qX_1 do
        local unitId = v.unitId
        local q1_1 = q__1[v.unitId] or 0
        q__1[unitId] = q1_1 + 1
    end
    local q0_2 = l1(mk.ReplaceUnits)
    q2_1, q1_2 = nil, math.huge
    for k, v in qX_1 do
        local q3_1 = mF(v.unitId, Value)
        if q3_1 < q1_2 then
            q2_1, q1_2 = v, q3_1
        end
    end
    if not q2_1 then
        return false
    end
    q4_1, q3_2 = nil, -1
    for k, v in l8.getOwnedUnitKeys() do
        if v ~= q2_1.unitId then
            local q5 = (next(q0_2) == nil or q0_2[v]) and (Toggles.ReplaceAllowDuplicates.Value or not q__1[v])
            if q5 then
                local q5_1 = mF(v, Value)
                if q5_1 > q3_2 then
                    q4_1, q3_2 = v, q5_1
                end
            end
        end
    end
    if not q4_1 then
        return false
    end
    if q3_2 <= q1_2 or q3_2 < q1_2 * (1 + mk.ReplaceMinGain.Value / 100) then
        return false
    end
    local qZ_2 = mt("BossPopulationCap", 0)
    local q__3 = mt("BossPopulationUsed", 0)
    local q0_3 = q__3 - l8.getUnitPopulation(q2_1.unitId) + l8.getUnitPopulation(q4_1)
    if q0_3 > qZ_2 then
        return false
    end
    local qZ_3 = #qX_1
    RemoteEvents.BossRoomRemoveMinion:FireServer(q2_1.id)
    local rq = if not lO(qZ_3 - 1, 2) then 1 else 0
    if rq == 1 then
        return false
    end
    local Position = (qY.CFrame * CFrame.new(q2_1.offset)).Position
    RemoteEvents.BossRoomPlaceMinion:FireServer(Position, q4_1)
    if not lO(qZ_3, 2) then
        RemoteEvents.BossRoomPlaceMinion:FireServer(Position, q2_1.unitId)
        lO(qZ_3, 2)
    end
    return true
end
lG = nil
lH = nil
connection = nil
lJ = nil
lK = nil
lL = nil
lM = nil
SkillTreeNodesConfig = nil
lO = nil
lP = nil
lR = nil
lS = nil
lU = nil
lV = nil
lW = nil
BossRoomWorldConfig = nil
lY = nil
lZ = nil
l_ = nil
UnitMutationConfig = nil
l1 = nil
l2 = nil
l3 = nil
Label = nil
l5 = nil
UnitConfig = nil
l7 = nil
l8 = nil
l9 = nil
PlayerDataClient = nil
mb = nil
mc = nil
md = nil
me = nil
mf = nil
mg = nil
mh = nil
RemoteEvents = nil
Toggles = nil
mk = nil
ml = nil
mm = nil
mn = nil
mo = nil
mp = nil
mr = nil
ms = nil
local lQ, lT, mq
mt = nil
mu = nil
mv = nil
LocalPlayer = nil
mx = nil
my = nil
VirtualUser = nil
connection2 = nil
mB = nil
mC = nil
mD = nil
mE = nil
mF = nil
mG = nil
local mI, mJ, mP, mQ, mR, mS, mV, mW, GameInfoGroup, m4, SkillTreeGroup, WeaponsGroup, AutoBuyRollGroup, ScriptsGroup, AutoUpgradeUnitsGroup
VirtualUser, LocalPlayer, mr, mq, mm = nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local mH_3
local mM = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local mO = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
local mN = "Be The Final Boss"
mr = { "Xeno", "Solara" }
mq = table.concat({
    "[English] Solara and Xeno are not supported. This is not the fault of this script, those executors are broken themselves.",
    "[Tiếng Việt] Solara và Xeno không được hỗ trợ. Đây không phải lỗi của script này, chính các executor đó bị lỗi.",
    "[Русский] Solara и Xeno не поддерживаются. Это не вина этого скрипта, сами эти инжекторы работают неправильно.",
    "[Português (BR)] Solara e Xeno não são suportados. A culpa não é deste script, os próprios executores é que não funcionam.",
    "[ไทย] ไม่รองรับ Solara และ Xeno นี่ไม่ใช่ความผิดของสคริปต์นี้ ตัวโปรแกรม executor เองที่มีปัญหา",
    "[Filipino] Hindi suportado ang Solara at Xeno. Hindi ito kasalanan ng script na ito, ang mga executor mismo ang sira."
}, "\n\n")
mm = fn714
local mK = fn329
local function mL()
    local screenGui
    screenGui = nil
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TempoExecutorNotice"
    screenGui.DisplayOrder = 2147483647
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local nR = pcall(function()
        screenGui.Parent = gethui()
    end)
    if not nR then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    local frame2 = Instance.new("Frame")
    frame2.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    frame2.BackgroundTransparency = 0.05
    frame2.BorderSizePixel = 0
    frame2.Size = UDim2.fromScale(1, 1)
    frame2.Parent = screenGui
    local uIListLayout2 = Instance.new("UIListLayout")
    uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout2.Parent = frame2
    local uIPadding = Instance.new("UIPadding")
    uIPadding.PaddingLeft = UDim.new(0, 48)
    uIPadding.PaddingRight = UDim.new(0, 48)
    uIPadding.Parent = frame2
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = frame2
    local uISizeConstraint = Instance.new("UISizeConstraint")
    uISizeConstraint.MaxSize = Vector2.new(760, math.huge)
    uISizeConstraint.Parent = frame
    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Padding = UDim.new(0, 28)
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Parent = frame
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.BackgroundTransparency = 1
    textLabel2.Size = UDim2.new(1, 0, 0, 40)
    textLabel2.Font = Enum.Font.GothamBold
    textLabel2.Text = "Unsupported Executor"
    textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel2.TextSize = 32
    textLabel2.TextXAlignment = Enum.TextXAlignment.Left
    textLabel2.LayoutOrder = 1
    textLabel2.Parent = frame
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 0, 0)
    textLabel.AutomaticSize = Enum.AutomaticSize.Y
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.Text = mq
    textLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
    textLabel.TextSize = 19
    textLabel.LineHeight = 1.35
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.LayoutOrder = 2
    textLabel.Parent = frame
    local textButton = Instance.new("TextButton")
    textButton.Size = UDim2.fromOffset(160, 44)
    textButton.AutoButtonColor = true
    textButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    textButton.BorderSizePixel = 0
    textButton.Font = Enum.Font.GothamBold
    textButton.Text = "OK"
    textButton.TextColor3 = Color3.fromRGB(20, 20, 20)
    textButton.TextSize = 17
    textButton.LayoutOrder = 3
    textButton.Parent = frame
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(0, 4)
    uICorner.Parent = textButton
    textButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end
if mK() then
    mL()
    return
end
RemoteEvents, mJ, mI, PlayerDataClient, l8, UnitConfig, UnitMutationConfig, lY, BossRoomWorldConfig, lT, lR, SkillTreeNodesConfig, mP, mL, mK, mR, mQ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local mH_1 = 10
repeat
    mS = (mH_1 * 9 + 5) % 10 + 1
    if mS <= 5 then
        if mS <= 3 then
            if mS <= 2 then
                if mS <= 1 then
                    local mT_1 = {
                        "minbufcx",
                        "zazenfo",
                        "cjwoeyrxy",
                        "gcdjld",
                        "harxvybpv",
                        "jgnviyymzk",
                        "tpjhqha",
                        "qgxpagi",
                        "gdyxgrmvc",
                        "idymmsowu"
                    }
                    local uN = mH_1
                    local mU_1 = mT_1[uN % 10 + 1]
                    if mU_1:len() <= mU_1:reverse():rep(uN % 3 + 2):len() then
                        UnitConfig = require(mI.BossRoom.UnitConfig)
                    else
                        mI = require(UnitConfig.BossRoom.UnitConfig)
                    end
                    mH_1 = (mH_1 + 69) % 80
                else
                    if not SkillTreeNodesConfig and not mK and (not mK or not RemoteEvents) or SkillTreeNodesConfig and not UnitMutationConfig and (not SkillTreeNodesConfig or not RemoteEvents) or not BossRoomWorldConfig and not UnitMutationConfig and (SkillTreeNodesConfig or not BossRoomWorldConfig) and (not RemoteEvents and not UnitMutationConfig and (not mK or BossRoomWorldConfig)) or (not SkillTreeNodesConfig and BossRoomWorldConfig and (BossRoomWorldConfig and mK) or (not RemoteEvents and not BossRoomWorldConfig or BossRoomWorldConfig and not mK)) and ((mK or not UnitMutationConfig or BossRoomWorldConfig and RemoteEvents) and ((not BossRoomWorldConfig or not BossRoomWorldConfig) and (not BossRoomWorldConfig or BossRoomWorldConfig))) or not (not SkillTreeNodesConfig and not mK and (not mK or not RemoteEvents) or SkillTreeNodesConfig and not UnitMutationConfig and (not SkillTreeNodesConfig or not RemoteEvents) or not BossRoomWorldConfig and not UnitMutationConfig and (SkillTreeNodesConfig or not BossRoomWorldConfig) and (not RemoteEvents and not UnitMutationConfig and (not mK or BossRoomWorldConfig)) or (not SkillTreeNodesConfig and BossRoomWorldConfig and (BossRoomWorldConfig and mK) or (not RemoteEvents and not BossRoomWorldConfig or BossRoomWorldConfig and not mK)) and ((mK or not UnitMutationConfig or BossRoomWorldConfig and RemoteEvents) and ((not BossRoomWorldConfig or not BossRoomWorldConfig) and (not BossRoomWorldConfig or BossRoomWorldConfig)))) then
                        UnitMutationConfig = require(mI.BossRoom.UnitMutationConfig)
                    else
                        mI = require(UnitMutationConfig.BossRoom.UnitMutationConfig)
                    end
                    mH_1 = (mH_1 + 39) % 80
                end
            else
                local mT_2 = (vector.create((mH_1 * 1 + 8) % 11 + 1, (mH_1 * 7 + 13) % 13 + 1, (mH_1 * 7 + 2) % 17 + 1))
                local mU_2 = (vector.create((mH_1 * 6 + 2) % 11 + 1, (mH_1 * 3 + 3) % 13 + 1, (mH_1 * 12 + 13) % 17 + 1))
                mV = (vector.create((mH_1 * 3 + 2) % 11 + 1, (mH_1 * 5 + 3) % 13 + 1, (mH_1 * 1 + 8) % 17 + 1))
                mW = (vector.create((mH_1 * 1 + 5) % 5 + 1, (mH_1 * 2 + 5) % 7 + 1, (mH_1 * 5 + 3) % 9 + 1))
                if vector.dot(vector.cross(mT_2, (vector.cross(mU_2, mV))), mW) == vector.dot(mU_2 * vector.dot(mT_2, mV) - mV * vector.dot(mT_2, mU_2), mW) + 5 then
                    mI = require(lY.BossRoom.SummonConfig)
                else
                    lY = require(mI.BossRoom.SummonConfig)
                end
                mH_1 = (mH_1 + 79) % 80
            end
        elseif mS <= 4 then
            local mT_3 = (vector.create((mH_1 * 3 + 4) % 11 + 1, (mH_1 * 2 + 4) % 13 + 1, (mH_1 * 7 + 10) % 17 + 1))
            local mU_3 = (vector.create((mH_1 * 6 + 6) % 11 + 1, (mH_1 * 11 + 11) % 13 + 1, (mH_1 * 11 + 4) % 17 + 1))
            local uo = vector.dot(mT_3, mU_3)
            if uo * uo <= vector.dot(mT_3, mT_3) * vector.dot(mU_3, mU_3) then
                BossRoomWorldConfig = require(mI.BossRoom.BossRoomWorldConfig)
                lT = require(mI.BossRoom.PlayerCombatConfig)
                lR = require(mI.Weapon.WeaponConfig)
                SkillTreeNodesConfig = require(mI.SkillTree.SkillTreeNodesConfig)
                mP = lY.RARITY_DISPLAY_ORDER
            else
                lT = require(BossRoomWorldConfig.BossRoom.BossRoomWorldConfig)
                mI = require(BossRoomWorldConfig.BossRoom.PlayerCombatConfig)
                lY = require(BossRoomWorldConfig.Weapon.WeaponConfig)
                mP = require(BossRoomWorldConfig.SkillTree.SkillTreeNodesConfig)
                lR = SkillTreeNodesConfig.RARITY_DISPLAY_ORDER
            end
            mH_1 = (mH_1 + 9) % 80
        else
            if mH_1 * 66347415 + 13 + 2 <= mH_1 * 66347415 + 13 + 2 + 1 then
                mL = { "Shiny", "Cursed", "Demonic" }
                mK = l8.UNIT_SORT_MODES
                mR = { "Grid", "Front Line", "Back Line", "Random" }
                mQ = {}
            else
                l8 = { "Cursed", "Shiny", "Demonic" }
                mR = mL.UNIT_SORT_MODES
                mQ = { "Grid", "Back Line", "Random", "Front Line" }
                mK = {}
            end
            mH_1 = (mH_1 + 29) % 80
        end
    elseif mS <= 8 then
        if mS <= 7 then
            if mS <= 6 then
                local uq = bit32.rrotate(bit32.bxor(bit32.lrotate(mH_1, 26), string.byte(tostring(l8))), 3)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(uq, 2771768323), 1902751725), (bit32.bxor(bit32.band(uq, 1523198972), 3626970682))), 1902751725), 3626970682) == uq then
                    RemoteEvents = mM:WaitForChild("Remotes"):WaitForChild("RemoteEvents")
                else
                    mM = RemoteEvents:WaitForChild("Remotes"):WaitForChild("RemoteEvents")
                end
                mH_1 = (mH_1 + 49) % 80
            else
                local mT_4 = (vector.create((mH_1 * 5 + 9) % 11 + 1, (mH_1 * 9 + 2) % 13 + 1, (mH_1 * 4 + 9) % 17 + 1))
                local uf = vector.floor(mT_4) + vector.ceil(mT_4 * -1)
                if vector.dot(uf, uf) == 0 then
                    mJ = mM:WaitForChild("ReplicatedCode")
                else
                    mM = mJ:WaitForChild("ReplicatedCode")
                end
                mH_1 = (mH_1 + 69) % 80
            end
        else
            local mT_5 = (vector.create((mH_1 * 4 + 2) % 11 + 1, (mH_1 * 1 + 5) % 13 + 1, (mH_1 * 4 + 12) % 17 + 1))
            local mU_4 = (vector.create((mH_1 * 6 + 2) % 11 + 1, (mH_1 * 9 + 12) % 13 + 1, (mH_1 * 4 + 16) % 17 + 1))
            mV = (vector.create((mH_1 * 4 + 3) % 11 + 1, (mH_1 * 11 + 11) % 13 + 1, (mH_1 * 11 + 8) % 17 + 1))
            mW = (vector.create((mH_1 * 2 + 1) % 5 + 1, (mH_1 * 3 + 3) % 7 + 1, (mH_1 * 5 + 5) % 9 + 1))
            if vector.dot(vector.cross(mT_5, (vector.cross(mU_4, mV))), mW) == vector.dot(mU_4 * vector.dot(mT_5, mV) - mV * vector.dot(mT_5, mU_4), mW) then
                mI = mJ.GameLogic.Shared.Configs
            else
                mJ = mI.GameLogic.Shared.Configs
            end
            mH_1 = (mH_1 + 29) % 80
        end
    elseif mS <= 9 then
        if (mQ or mL or not mI and lY) and (SkillTreeNodesConfig or not lY or (lY or SkillTreeNodesConfig)) or (not SkillTreeNodesConfig and not mI or mI and PlayerDataClient) and (mQ and PlayerDataClient or SkillTreeNodesConfig and mQ) or ((not mQ or not SkillTreeNodesConfig) and (not mQ and not SkillTreeNodesConfig) or SkillTreeNodesConfig and mQ and (mI or mL)) and (not lY or lY or (not mI or not SkillTreeNodesConfig) or not mL and not SkillTreeNodesConfig and (not mL or not PlayerDataClient)) or not ((mQ or mL or not mI and lY) and (SkillTreeNodesConfig or not lY or (lY or SkillTreeNodesConfig)) or (not SkillTreeNodesConfig and not mI or mI and PlayerDataClient) and (mQ and PlayerDataClient or SkillTreeNodesConfig and mQ) or ((not mQ or not SkillTreeNodesConfig) and (not mQ and not SkillTreeNodesConfig) or SkillTreeNodesConfig and mQ and (mI or mL)) and (not lY or lY or (not mI or not SkillTreeNodesConfig) or not mL and not SkillTreeNodesConfig and (not mL or not PlayerDataClient))) then
            PlayerDataClient = require(mJ.Framework.DataStore.PlayerDataClient)
        else
            mJ = require(PlayerDataClient.Framework.DataStore.PlayerDataClient)
        end
        mH_1 = (mH_1 + 9) % 80
    else
        mS = { "djjytudatsl", "wtkf", "jdnxxkryljg", "bpohpxtdnt", "cnrggjh", "weudbtblhbj", "meac" }
        local uB = mH_1
        local mT_6 = mS[uB % 7 + 1]
        if mT_6:len() <= mT_6:gsub("(.)", "%1%1", uB % 3 % 2 + 1):len() then
            l8 = require(mJ.GameLogic.Guis.BossUnitBagUtil)
        else
            mJ = require(l8.GameLogic.Guis.BossUnitBagUtil)
        end
        mH_1 = (mH_1 + 39) % 80
    end
until (mH_1 * 47 + 3) % 80 == 53
for k, v in pairs(UnitConfig) do
    local mH_2 = type(v) == "table" and v.rarity
    if mH_2 then
        table.insert(mQ, k)
    end
end
ms, mk, Toggles, mg, mf, my, mc, l7, lU, lL, mt, mh, md, lZ, lM, mC, mu, l5, lQ, lS, mD, mF, mx, mb, mG, mn, l3, lP, mM = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(mQ)
ms = getgenv().Library
local ThemeManager = getgenv().ThemeManager
mS = getgenv().SaveManager
mk = ms.Options
Toggles = ms.Toggles
mg = "https://discord.gg/K7Qxnxkk46"
mf = "https://discord.gg/K7Qxnxkk46"
mc = fn495
l7 = fn652
lU = fn214
lL = fn419
mW = "#7fd47f"
mV = "#6ec1ff"
my = "#e8a34d"
local mU_5 = "#8b93a3"
mt = fn868
mh = fn576
md = fn552
lZ = fn570
lM = fn491
mC = fn166
if (false or not l3 or "#6ec1ff" or (lZ and lZ or not lS and false)) and ((not l3 and mM or (mV or not my)) and (not l3 and false or false and my)) and ((false or l3) and (not mM or not mM) and (my or mM or (not l3 or not my)) or (not lS or lZ or mM and lZ or mM and mV and (not l3 or mV))) or not ((false or not l3 or "#6ec1ff" or (lZ and lZ or not lS and false)) and ((not l3 and mM or (mV or not my)) and (not l3 and false or false and my)) and ((false or l3) and (not mM or not mM) and (my or mM or (not l3 or not my)) or (not lS or lZ or mM and lZ or mM and mV and (not l3 or mV)))) then
    mu = fn778
    l5 = fn173
    lQ = fn312
else
    lQ = fn778
    mu = fn173
    l5 = fn312
end
lS = fn317
mD = function(bT, bU, bV, bW)
    local Position
    local COMBAT_AREA_EDGE_PADDING = BossRoomWorldConfig.COMBAT_AREA_EDGE_PADDING
    local oU = bT.Size.X / 2 - COMBAT_AREA_EDGE_PADDING
    local oV = bT.Size.Z / 2 - COMBAT_AREA_EDGE_PADDING
    local oT_1 = bT.Size.Y / 2
    local oW = {}
    local oX = -oU
    while oX <= oU do
        local oY = -oV
        while oY <= oV do
            table.insert(oW, (bT.CFrame * CFrame.new(oX, oT_1, oY)).Position)
            oY = oY + bV
        end
        oX = oX + bV
    end
    if bW == "Random" then
        local o1 = #oW
        local o0 = -1
        while false and o1 <= 2 or true and o1 >= 2 do
            local o2 = o1
            local oT_3 = math.random(o2)
            oW[o2], oW[oT_3] = oW[oT_3], oW[o2]
            o1 += o0
        end
        return oW
    end
    local oT_4 = bU:FindFirstChild(BossRoomWorldConfig.HERO_SPAWN_PART_NAME, true)
    local oV_1 = bW == "Front Line" or bW == "Back Line"
    local oU_2 = oV_1 and oT_4 and oT_4:IsA("BasePart")
    if oU_2 then
        Position = oT_4.Position
        table.sort(oW, function(b9, ca)
            local Magnitude2 = (Vector3.new(b9.X, 0, b9.Z) - Vector3.new(Position.X, 0, Position.Z)).Magnitude
            local Magnitude = (Vector3.new(ca.X, 0, ca.Z) - Vector3.new(Position.X, 0, Position.Z)).Magnitude
            if bW == "Front Line" then
                return Magnitude2 < Magnitude
            end
            return Magnitude2 > Magnitude
        end)
    end
    return oW
end
mF = fn127
mx = fn456
mb = fn245
mG = fn534
mn = fn363
l3 = fn668
lP = fn169
mJ = ms:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Be The Final Boss",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false,
    Size = UDim2.fromOffset(880, 700)
})
local mX = {
    Info = mJ:AddTab("Info", "info"),
    Combat = mJ:AddTab("Combat", "swords"),
    Units = mJ:AddTab("Units", "users"),
    Summon = mJ:AddTab("Summon", "dice-5"),
    Progression = mJ:AddTab("Progression", "git-branch"),
    Settings = mJ:AddTab("Settings", "settings")
}
mM = fn694
for k, v in mX do
    mM(v)
end
ml, mH_3, GameInfoGroup, Label, l_, mJ = nil, nil, nil, nil, nil, nil
mI = 7
repeat
    mM = (mI * 2 + 0) % 3 + 1
    if mM <= 2 then
        if mM <= 1 then
            if (mI * 2 + 7) * 7 % 3 == ((mI * 2 + 7) * 7 + 0) % 3 then
                l_ = tostring(game.JobId)
            else
                mJ = tostring(game.JobId)
            end
            mI = (mI + 20) % 24
        else
            if ((not mI or Label) and (not mH_3 and mH_3) or (not Label or not mI) and (mH_3 and not mI) or (not ml or not mI or (Label or Label)) and (mI and ml and (not mH_3 and not mH_3))) and not ((not mI or Label) and (not mH_3 and mH_3) or (not Label or not mI) and (mH_3 and not mI) or (not ml or not mI or (Label or Label)) and (mI and ml and (not mH_3 and not mH_3))) then
                l_ = #mJ > 18
            else
                mJ = #l_ > 18
            end
            mI = (mI + 2) % 24
        end
    else
        if (mI * 3 + 2) * 13 % 4 == ((mI * 3 + 2) * 13 + 12) % 4 then
            ml = "Unknown"
            pcall(fn513)
            mH_3 = mX.Info:AddLeftGroupbox("Account", "circle-user")
            mH_3:AddLabel(lL("User", LocalPlayer.Name, mW), true)
            mH_3:AddLabel(lL("Status", "Keyless", mW), true)
            mH_3:AddLabel(lL("Executor", ml, mW), true)
            GameInfoGroup = mX.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            GameInfoGroup:AddLabel(lU(mN .. " [" .. tostring(game.PlaceId) .. "]", mV), true)
            GameInfoGroup:AddLabel(lL("Place ID", tostring(game.PlaceId), mV), true)
            Label = GameInfoGroup:AddLabel(lL("Session time", "0s", my), true)
        else
            mH_3 = "Unknown"
            pcall(fn513)
            mX = (nil):AddLeftGroupbox("Account", "circle-user")
            mX:AddLabel(mV("User", GameInfoGroup.Name, mN), true)
            mX:AddLabel(mV("Status", "Keyless", mN), true)
            mX:AddLabel(mV("Executor", "Unknown", mN), true)
            lL = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
            lL:AddLabel(Label(ml .. " [" .. tostring(game.PlaceId) .. "]", lU), true)
            lL:AddLabel(mV("Place ID", tostring(game.PlaceId), lU), true)
            my = lL:AddLabel(mV("Session time", "0s", LocalPlayer), true)
        end
        mI = (mI + 14) % 24
    end
until (mI * 11 + 19) % 24 == 12
if mJ then
    local mH_4 = 2
    repeat
        mI = {
            "axjl",
            "awyqrjt",
            "akztwh",
            "gpwklmhnfbap",
            "ayvunyo",
            "dhvfykhozc",
            "jpmvfmilak",
            "gtkhddgmpvxt"
        }
        if mI[(mH_4 * 72 + 106) % 8 + 1] <= mI[(mH_4 * 72 + 106) % 8 + 1] then
            mJ = string.sub(l_, 1, 18) .. "..."
        else
            l_ = string.sub(mJ, 1, 18) .. "..."
        end
        mH_4 = (mH_4 + 1) % 4
    until (mH_4 * 1 + 0) % 4 == 3
end
local mH_5 = mJ or l_
lH, ScriptsGroup, AutoUpgradeUnitsGroup, AutoBuyRollGroup, WeaponsGroup, SkillTreeGroup, me, l9, connection, connection2, lG, mE, lV, l1, lO, mB, mp, mv, lW, lK, l2, lJ, mo = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
mM = mH_5
GameInfoGroup:AddLabel(lL("Server", mM, mU_5), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
lH = os.clock()
if (mB and AutoUpgradeUnitsGroup and (not AutoUpgradeUnitsGroup or mB) and (AutoUpgradeUnitsGroup and not mB and (mB and mE)) or ((mE or not AutoUpgradeUnitsGroup) and (not mE and not mB) or (not mB and mB or (AutoUpgradeUnitsGroup or not AutoUpgradeUnitsGroup)))) and ((AutoUpgradeUnitsGroup or not mE or (AutoUpgradeUnitsGroup or not AutoUpgradeUnitsGroup)) and (not mB and mE and (AutoUpgradeUnitsGroup or not mB)) or (AutoUpgradeUnitsGroup and mE and (mB or not mE) or not mE and mB and (not AutoUpgradeUnitsGroup and not mB))) and not ((mB and AutoUpgradeUnitsGroup and (not AutoUpgradeUnitsGroup or mB) and (AutoUpgradeUnitsGroup and not mB and (mB and mE)) or ((mE or not AutoUpgradeUnitsGroup) and (not mE and not mB) or (not mB and mB or (AutoUpgradeUnitsGroup or not AutoUpgradeUnitsGroup)))) and ((AutoUpgradeUnitsGroup or not mE or (AutoUpgradeUnitsGroup or not AutoUpgradeUnitsGroup)) and (not mB and mE and (AutoUpgradeUnitsGroup or not mB)) or (AutoUpgradeUnitsGroup and mE and (mB or not mE) or not mE and mB and (not AutoUpgradeUnitsGroup and not mB)))) then
    task.spawn(worker)
    mX = ScriptsGroup.Info:AddRightGroupbox("Scripts", "package")
else
    task.spawn(worker)
    ScriptsGroup = mX.Info:AddRightGroupbox("Scripts", "package")
end
ScriptsGroup:AddLabel(lU("Included in this hub", mU_5), true)
ScriptsGroup:AddLabel(lU(mN, mV), true)
local FeaturesGroup = mX.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(lU("Auto Farm", mV), true)
FeaturesGroup:AddLabel(lU("Auto Waves", mV), true)
FeaturesGroup:AddLabel(lU("Auto Place & Replace Units", my), true)
FeaturesGroup:AddLabel(lU("Auto Upgrade Units", my), true)
FeaturesGroup:AddLabel(lU("Auto Roll & Auto Buy", mW), true)
FeaturesGroup:AddLabel(lU("Weapons & Skill Tree", mU_5), true)
local SocialsGroup = mX.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = l7 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = mX.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = l7 })
local FaqGroup = mX.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoFarmGroup = mX.Combat:AddLeftGroupbox("Auto Farm", "sword")
AutoFarmGroup:AddToggle("KillAura", { Text = "Auto Farm", Default = false })
AutoFarmGroup:AddSlider("AttackDelay", { Text = "Attack Delay", Default = 0.15, Min = lT.MIN_COOLDOWN, Max = 1, Rounding = 2 })
AutoFarmGroup:AddToggle("KillAuraBattleOnly", { Text = "Only During Battle", Default = true })
AutoFarmGroup:AddToggle("AuraWaitForZone", { Text = "Wait For Combat Zone", Default = true })
AutoFarmGroup:AddToggle("AuraReposition", { Text = "Teleport To Target", Default = true })
AutoFarmGroup:AddSlider("AuraRange", { Text = "Aura Range", Default = 250, Min = 10, Max = 500, Rounding = 0 })
AutoFarmGroup:AddSlider("AuraStrikeDistance", { Text = "Strike Distance", Default = 4, Min = 1, Max = 12, Rounding = 1 })
AutoFarmGroup:AddToggle("AuraMaxCombo", { Text = "Force Max Combo", Default = true })
local WavesGroup = mX.Combat:AddRightGroupbox("Waves", "flag")
WavesGroup:AddToggle("AutoStartWave", { Text = "Auto Start Wave", Default = false })
WavesGroup:AddSlider("StartWaveDelay", { Text = "Start Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
WavesGroup:AddToggle("AutoStopAtWave", { Text = "Auto Stop At Wave", Default = false })
WavesGroup:AddInput("StopWave", { Text = "Stop At Wave", Default = "25", Numeric = true, Finished = true })
local AutoPlaceGroup = mX.Units:AddLeftGroupbox("Auto Place", "map-pin")
AutoPlaceGroup:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
AutoPlaceGroup:AddDropdown("PlaceUnits", { Text = "Units", Values = l8.getOwnedUnitKeys(), Default = {}, Multi = true, AllowNull = true })
AutoPlaceGroup:AddButton({ Text = "Refresh Owned Units", Func = onRefreshOwnedUnits })
AutoPlaceGroup:AddDropdown("PlacePriority", { Text = "Priority", Values = mK, Default = mK[1], Multi = false })
AutoPlaceGroup:AddDropdown("PlaceFormation", { Text = "Formation", Values = mR, Default = mR[1], Multi = false })
mJ = mX.Units:AddRightGroupbox("Placement Tuning", "sliders-horizontal")
mJ:AddSlider("PlaceSpacing", {
    Text = "Spacing",
    Default = 4.5,
    Min = BossRoomWorldConfig.MINION_PLACEMENT_RADIUS,
    Max = 12,
    Rounding = 1
})
mJ:AddSlider("PlaceDelay", { Text = "Place Delay", Default = 0.3, Min = 0.05, Max = 3, Rounding = 2 })
mJ:AddSlider("PlaceLimit", { Text = "Max Units (0 = Unlimited)", Default = 0, Min = 0, Max = 30, Rounding = 0 })
mJ:AddButton({ Text = "Clear All Placements", Func = onClearAllPlacements })
mI = mX.Units:AddLeftGroupbox("Auto Replace Units", "arrow-up-circle")
mI:AddToggle("AutoReplace", { Text = "Auto Replace Units", Default = false })
mI:AddDropdown("ReplaceUnits", {
    Text = "Allowed Units",
    Values = l8.getOwnedUnitKeys(),
    Default = {},
    Multi = true,
    AllowNull = true
})
mI:AddButton({ Text = "Refresh Allowed Units", Func = onRefreshAllowedUnits })
mI:AddDropdown("ReplaceMetric", { Text = "Compare By", Values = mK, Default = mK[1], Multi = false })
mI:AddSlider("ReplaceMinGain", { Text = "Min Gain %", Default = 10, Min = 0, Max = 200, Rounding = 0 })
mI:AddToggle("ReplaceAllowDuplicates", { Text = "Allow Duplicate Units", Default = true })
mI:AddSlider("ReplaceDelay", { Text = "Replace Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2 })
AutoUpgradeUnitsGroup = mX.Units:AddRightGroupbox("Auto Upgrade Units", "arrow-big-up")
AutoUpgradeUnitsGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrade Units", Default = false })
AutoUpgradeUnitsGroup:AddDropdown("UpgradeUnits", { Text = "Units", Values = l8.getOwnedUnitKeys(), Default = {}, Multi = true, AllowNull = true })
AutoUpgradeUnitsGroup:AddButton({ Text = "Refresh Owned Units", Func = onRefreshOwnedUnits2 })
AutoUpgradeUnitsGroup:AddDropdown("UpgradePriority", { Text = "Priority", Values = mK, Default = mK[1], Multi = false })
AutoUpgradeUnitsGroup:AddDropdown("UpgradeMode", { Text = "Mode", Values = { "Next Level", "Max Level" }, Default = "Next Level", Multi = false })
AutoUpgradeUnitsGroup:AddToggle("UpgradeFullStepsOnly", { Text = "Only If Shards Cover Step", Default = true })
AutoUpgradeUnitsGroup:AddInput("UpgradeLevelCap", { Text = "Level Cap (0 = None)", Default = "0", Numeric = true, Finished = true })
AutoUpgradeUnitsGroup:AddSlider("ShardReserve", { Text = "Shard Reserve", Default = 0, Min = 0, Max = 10000, Rounding = 0 })
AutoUpgradeUnitsGroup:AddSlider("UpgradeDelay", { Text = "Upgrade Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2 })
local AutoRollGroup = mX.Summon:AddLeftGroupbox("Auto Roll", "dice-5")
if (l2 or lH) and (not l2 or AutoBuyRollGroup) and (l2 or l2 or not lH and lH) or (lH or lH) and (AutoBuyRollGroup or AutoBuyRollGroup) and ((not l2 or not l2) and (not l2 and l2)) or (l2 or lH or lH and lH or lH and not l2 and (not lH and not lH)) and ((not AutoBuyRollGroup and not l2 or l2 and not lH) and ((not AutoBuyRollGroup or AutoBuyRollGroup) and (lH and lH))) or not ((l2 or lH) and (not l2 or AutoBuyRollGroup) and (l2 or l2 or not lH and lH) or (lH or lH) and (AutoBuyRollGroup or AutoBuyRollGroup) and ((not l2 or not l2) and (not l2 and l2)) or (l2 or lH or lH and lH or lH and not l2 and (not lH and not lH)) and ((not AutoBuyRollGroup and not l2 or l2 and not lH) and ((not AutoBuyRollGroup or AutoBuyRollGroup) and (lH and lH)))) then
    AutoRollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
    AutoRollGroup:AddSlider("RollDelay", { Text = "Roll Delay", Default = 0.1, Min = 0, Max = 10, Rounding = 2 })
    AutoRollGroup:AddToggle("StopOnTarget", { Text = "Stop On Target", Default = false })
    AutoRollGroup:AddDropdown("StopRarities", { Text = "Stop Rarities", Values = mP, Default = {}, Multi = true, AllowNull = true })
    AutoRollGroup:AddDropdown("StopUnits", { Text = "Stop Characters", Values = mQ, Default = {}, Multi = true, AllowNull = true })
    AutoRollGroup:AddDropdown("StopMutations", { Text = "Stop Mutations", Values = mL, Default = {}, Multi = true, AllowNull = true })
    AutoBuyRollGroup = mX.Summon:AddRightGroupbox("Auto Buy Roll", "shopping-cart")
    AutoBuyRollGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
    AutoBuyRollGroup:AddDropdown("BuyRarities", { Text = "Buy Rarities", Values = mP, Default = {}, Multi = true, AllowNull = true })
    AutoBuyRollGroup:AddDropdown("BuyUnits", { Text = "Buy Characters", Values = mQ, Default = {}, Multi = true, AllowNull = true })
    AutoBuyRollGroup:AddDropdown("BuyMutations", { Text = "Buy Mutations", Values = mL, Default = {}, Multi = true, AllowNull = true })
    AutoBuyRollGroup:AddToggle("BuyRequireMutation", { Text = "Require Mutation Match", Default = false })
    AutoBuyRollGroup:AddToggle("BuyWaitForSouls", { Text = "Hold Roll Until Affordable", Default = false })
    AutoBuyRollGroup:AddSlider("SoulReserve", { Text = "Soul Reserve", Default = 0, Min = 0, Max = 100000, Rounding = 0 })
    AutoBuyRollGroup:AddSlider("BuyDelay", { Text = "Buy Delay", Default = 0, Min = 0, Max = 5, Rounding = 2 })
    WeaponsGroup = mX.Progression:AddLeftGroupbox("Weapons", "axe")
    WeaponsGroup:AddToggle("AutoBuyWeapon", { Text = "Auto Buy Best Affordable Weapon", Default = false })
    WeaponsGroup:AddSlider("CoinReserve", { Text = "Coin Reserve", Default = 0, Min = 0, Max = 1000000, Rounding = 0 })
    WeaponsGroup:AddToggle("AutoEquipWeapon", { Text = "Auto Equip Best Owned Weapon", Default = false })
    SkillTreeGroup = mX.Progression:AddRightGroupbox("Skill Tree", "git-branch")
    SkillTreeGroup:AddToggle("AutoSkillTree", { Text = "Auto Purchase Affordable Skills", Default = false })
    SkillTreeGroup:AddDropdown("SkillCurrencies", {
        Text = "Currencies",
        Values = { "Coin", "Soul" },
        Default = { Coin = true },
        Multi = true,
        AllowNull = true
    })
    SkillTreeGroup:AddToggle("SkillCheapestFirst", { Text = "Cheapest First", Default = true })
    SkillTreeGroup:AddSlider("SkillCoinReserve", { Text = "Coin Reserve", Default = 0, Min = 0, Max = 1000000, Rounding = 0 })
    SkillTreeGroup:AddSlider("SkillSoulReserve", { Text = "Soul Reserve", Default = 0, Min = 0, Max = 100000, Rounding = 0 })
    m4 = mX.Settings:AddLeftGroupbox("Menu", "menu")
    m4:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    m4:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    m4:AddButton("Unload", onUnload)
    ms.ToggleKeybind = mk.MenuKeybind
    me = tick()
else
    mP:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
    mP:AddSlider("RollDelay", { Text = "Roll Delay", Min = 0, Max = 10, Rounding = 2, Default = 0.1 })
    mP:AddToggle("StopOnTarget", { Text = "Stop On Target", Default = false })
    mP:AddDropdown("StopRarities", { Default = {}, Values = AutoBuyRollGroup, Multi = true, AllowNull = true, Text = "Stop Rarities" })
    mP:AddDropdown("StopUnits", { Default = {}, Values = mL, Multi = true, Text = "Stop Characters", AllowNull = true })
    mP:AddDropdown("StopMutations", { Values = SkillTreeGroup, AllowNull = true, Default = {}, Multi = true, Text = "Stop Mutations" })
    ms = WeaponsGroup.Summon:AddRightGroupbox("Auto Buy Roll", "shopping-cart")
    ms:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
    ms:AddDropdown("BuyRarities", { Default = {}, Text = "Buy Rarities", Multi = true, Values = AutoBuyRollGroup, AllowNull = true })
    ms:AddDropdown("BuyUnits", { AllowNull = true, Default = {}, Text = "Buy Characters", Multi = true, Values = mL })
    ms:AddDropdown("BuyMutations", { Default = {}, AllowNull = true, Values = SkillTreeGroup, Text = "Buy Mutations", Multi = true })
    ms:AddToggle("BuyRequireMutation", { Text = "Require Mutation Match", Default = false })
    ms:AddToggle("BuyWaitForSouls", { Text = "Hold Roll Until Affordable", Default = false })
    ms:AddSlider("SoulReserve", { Rounding = 0, Max = 100000, Default = 0, Min = 0, Text = "Soul Reserve" })
    ms:AddSlider("BuyDelay", { Rounding = 2, Text = "Buy Delay", Min = 0, Default = 0, Max = 5 })
    m4 = WeaponsGroup.Progression:AddLeftGroupbox("Weapons", "axe")
    m4:AddToggle("AutoBuyWeapon", { Text = "Auto Buy Best Affordable Weapon", Default = false })
    m4:AddSlider("CoinReserve", { Default = 0, Text = "Coin Reserve", Max = 1000000, Rounding = 0, Min = 0 })
    m4:AddToggle("AutoEquipWeapon", { Text = "Auto Equip Best Owned Weapon", Default = false })
    mX = WeaponsGroup.Progression:AddRightGroupbox("Skill Tree", "git-branch")
    mX:AddToggle("AutoSkillTree", { Text = "Auto Purchase Affordable Skills", Default = false })
    mX:AddDropdown("SkillCurrencies", {
        Values = { "Coin", "Soul" },
        AllowNull = true,
        Default = { Coin = true },
        Text = "Currencies",
        Multi = true
    })
    mX:AddToggle("SkillCheapestFirst", { Text = "Cheapest First", Default = true })
    mX:AddSlider("SkillCoinReserve", { Min = 0, Max = 1000000, Text = "Coin Reserve", Default = 0, Rounding = 0 })
    mX:AddSlider("SkillSoulReserve", { Min = 0, Max = 100000, Text = "Soul Reserve", Default = 0, Rounding = 0 })
    me = WeaponsGroup.Settings:AddLeftGroupbox("Menu", "menu")
    me:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    me:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { NoUI = true, Default = "RightShift", Text = "Menu keybind" })
    me:AddButton("Unload", onUnload)
    mQ.ToggleKeybind = AutoRollGroup.MenuKeybind
    mk = tick()
end
if ((not mI and not mI or (connection2 or connection2)) and (not SkillTreeGroup and not mo or SkillTreeGroup and connection2) or mo and AutoFarmGroup and (not AutoFarmGroup and connection2) and ((mo or AutoFarmGroup) and (not mo and not mI))) and not ((not mI and not mI or (connection2 or connection2)) and (not SkillTreeGroup and not mo or SkillTreeGroup and connection2) or mo and AutoFarmGroup and (not AutoFarmGroup and connection2) and ((mo or AutoFarmGroup) and (not mo and not mI))) then
    lV = tick()
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local p1 = v
            pcall(function()
                p1:Disable()
            end)
        end
    end)
    l9 = fn787
else
    l9 = tick()
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local p1 = v
            pcall(function()
                p1:Disable()
            end)
        end
    end)
    lV = fn787
end
if ((lH and AutoUpgradeUnitsGroup or not lH and mB) and (not mB or lH or (mB or lH)) or (not FaqGroup and not lH or mB and AutoUpgradeUnitsGroup) and (AutoUpgradeUnitsGroup or not AutoUpgradeUnitsGroup or mB and FaqGroup) or (not AutoUpgradeUnitsGroup and not lH or (not AutoUpgradeUnitsGroup or AutoUpgradeUnitsGroup) or (not AutoUpgradeUnitsGroup and not AutoUpgradeUnitsGroup or (not FaqGroup or not FaqGroup))) and ((AutoUpgradeUnitsGroup or not lH or (not mB or not lH)) and (lH or FaqGroup or FaqGroup and not lH))) and not ((lH and AutoUpgradeUnitsGroup or not lH and mB) and (not mB or lH or (mB or lH)) or (not FaqGroup and not lH or mB and AutoUpgradeUnitsGroup) and (AutoUpgradeUnitsGroup or not AutoUpgradeUnitsGroup or mB and FaqGroup) or (not AutoUpgradeUnitsGroup and not lH or (not AutoUpgradeUnitsGroup or AutoUpgradeUnitsGroup) or (not AutoUpgradeUnitsGroup and not AutoUpgradeUnitsGroup or (not FaqGroup or not FaqGroup))) and ((AutoUpgradeUnitsGroup or not lH or (not mB or not lH)) and (lH or FaqGroup or FaqGroup and not lH))) then
    mO = connection.InputBegan:Connect(onInputBegan)
else
    connection = mO.InputBegan:Connect(onInputBegan)
end
connection2 = mO.InputChanged:Connect(onInputChanged)
task.spawn(antiAfkLoop)
task.spawn(function()
    local qb = 0
    local qc = os.clock()
    local qd = #lT.ATTACK_STAGES
    while not ms.Unloaded do
        local qe = math.max(lT.MIN_COOLDOWN, mk.AttackDelay.Value)
        local qf = Toggles.KillAura.Value
        if qf then
            local qg_1 = not Toggles.KillAuraBattleOnly.Value or mh() == "Battle"
            qf = qg_1
        end
        if qf then
            local Character = LocalPlayer.Character
            local qg_2 = Character and Character:FindFirstChild("HumanoidRootPart")
            local qf_2 = qg_2
            if qg_2 then
                qg_2 = lQ(qf_2.Position, mk.AuraRange.Value, Toggles.AuraWaitForZone.Value)
            end
            local qh = qg_2 or nil
            local qg_3 = qh
            if qh then
                qh = Toggles.AuraReposition.Value
            end
            if qh then
                local qh_1 = qg_3.Position + (qf_2.Position - qg_3.Position).Unit * mk.AuraStrikeDistance.Value
                qf_2.CFrame = CFrame.lookAt(Vector3.new(qh_1.X, qg_3.Position.Y, qh_1.Z), qg_3.Position)
            end
            local qf_3 = qg_3
            if not qf_3 then
                qf_3 = not (Toggles.AuraReposition.Value or Toggles.AuraWaitForZone.Value)
            end
            if qf_3 then
                local qf_4 = os.clock()
                if Toggles.AuraMaxCombo.Value then
                    qb = qd
                else
                    qb = lT.getNextComboIndex(qb, qf_4 - qc)
                end
                qc = qf_4
                pcall(function()
                    RemoteEvents.BossRoomWeaponAttack:FireServer(nil, qb)
                end)
                task.wait(qe)
            else
                task.wait(0.1)
            end
        else
            task.wait(0.2)
        end
    end
end)
l1 = fn300
lO = fn358
do
    mB = fn247
    mp = fn994
    task.spawn(autoPlaceLoop)
    task.spawn(autoStartWaveLoop)
    lG = 0.5
    mE = 0
    RemoteEvents.BossRoomSummonPoolResult.OnClientEvent:Connect(onOnClientEvent)
    mv = fn916
end
lW = fn577
lK = fn959
l2 = fn267
lJ = fn600
mo = fn71
task.spawn(autoRollLoop)
task.spawn(worker2)
task.spawn(autoUpgradeLoop)
task.spawn(autoBuyWeaponLoop)
task.spawn(autoEquipWeaponLoop)
task.spawn(autoSkillTreeLoop)
ThemeManager:SetLibrary(ms)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
ThemeManager:ApplyToTab(mX.Settings)
ThemeManager:LoadDefault()
mS:SetLibrary(ms)
mS:IgnoreThemeSettings()
mS:SetIgnoreIndexes({ "MenuKeybind" })
mS:SetFolder("TempoHub/be-the-final-boss")
mS:BuildConfigSection(mX.Settings)
mS:LoadAutoloadConfig()
ms:OnUnload(fn991)
end)(...)
