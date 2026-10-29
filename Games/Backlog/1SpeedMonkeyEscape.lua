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
getgenv().TempoHoodSubtitle = "+1 SPEED MONKEY ESCAPE"
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
local hd
local gV
local hg
local gY
local hj
local Trails
local g0
local gI
local g3
local EquipBestCharms
local gL
local g6
local gO
local g9
local gR
local hc
local hf
local connection
local hi
local gX
local g_
local hl
local BuyAura
local g2
local connection2
local gK
local g5
local gN
local Label
local gQ
local hb
local gT
local Charms
local gW
local hh
local gZ
local hk
local g1
local hn
local g4
local gJ
local PlayerUtil
local gM
local ha
local gP
local SelectUpgrade
local function autoEquipBestUpgradeLoop()
    while true do
        task.wait(2)
        if hb.Unloaded then
            break
        end
        if g1.AutoEquipBestUpgrade.Value then
            local kB = -1
            local kC
            for i, child in hl.UnlockedUpgrades:GetChildren() do
                local kD_1 = tonumber(child.Name)
                local kE = kD_1 and gJ[kD_1]
                local kF = kE
                if kE then
                    kE = kF.Multi > kB
                end
                if kE then
                    kC = kD_1
                    kB = kF.Multi
                end
            end
            if kC and hl.SelectedUpgrade.Value ~= kC then
                SelectUpgrade:FireServer(kC)
            end
        end
    end
end
local function autoRebirthLoop()
    while true do
        task.wait(2)
        if hb.Unloaded then
            break
        end
        if g1.AutoRebirth.Value then
            local kk = gO.RebirthLevels[hl.Rebirths.Value + 1]
            local kj_1 = kk and PlayerUtil.GetLevel(hl) >= kk
            if kj_1 then
                gZ:FireServer()
            end
        end
    end
end
local function autoBuyUpgradesLoop()
    while true do
        task.wait(1)
        if hb.Unloaded then
            break
        end
        if g1.AutoBuyUpgrades.Value then
            local km = hh()
            local kn = -1
            local ko
            for k, v in gJ do
                local kp = km >= v.WinsRequirement and v.WinsRequirement > kn and not hl.UnlockedUpgrades:FindFirstChild(tostring(k))
                if kp then
                    ko = k
                    kn = v.WinsRequirement
                end
            end
            if ko then
                SelectUpgrade:FireServer(ko)
            end
        end
    end
end
local function autoWinLoop()
    while true do
        local wait = task.wait
        local j9 = g1.AutoWin.Value and math.max(gY.WinDelay.Value, 0.5)
        local ka = j9 or 0.5
        wait(ka)
        if hb.Unloaded then
            break
        end
        if g1.AutoWin.Value and firetouchinterest then
            local j8_2 = g5[gY.WinPlate.Value]
            local j9_1 = j8_2 and g6(j8_2.World)
            if j9_1 then
                local j9_2 = hf(j8_2)
                local ka_1 = gM()
                if j9_2 and ka_1 then
                    firetouchinterest(ka_1, j9_2, 0)
                    firetouchinterest(ka_1, j9_2, 1)
                else
                    hg(j8_2)
                end
            end
        end
    end
end
local function antiAfkLoop()
    while true do
        task.wait(2)
        if hb.Unloaded then
            break
        end
        if g1.AntiAfk.Value then
            local jZ = tick() - gR
            local j_ = tick() - gN
            if jZ >= 300 and j_ >= 60 then
                pcall(hc)
            else
                if jZ < 300 and j_ >= 300 then
                    pcall(hc)
                end
            end
        end
    end
end
local function fn64(J, K)
    return string.format('<font color="%s">%s</font>', K, J)
end
local function autoBuyTrailsLoop()
    while true do
        task.wait(2)
        if hb.Unloaded then
            break
        end
        if g1.AutoBuyTrails.Value then
            for k, v in Trails do
                local k_ = hh() >= v.Price and not hl.UnlockedTrails:FindFirstChild(k)
                if k_ then
                    gL:FireServer(k)
                    task.wait(0.2)
                end
            end
        end
    end
end
local function worker()
    local jH_1
    while true do
        task.wait(1)
        if hb.Unloaded then
            break
        end
        local jG = math.floor(os.clock() - gI)
        if jG < 60 then
            jH_1 = jG .. "s"
        elseif jG < 3600 then
            jH_1 = string.format("%dm %ds", math.floor((jG) / (60)), jG % 60)
        else
            jH_1 = string.format("%dh %dm", math.floor((jG) / (3600)), math.floor((jG % 3600) / (60)))
        end
        Label:SetText(gK("Session time", jH_1, g4))
    end
end
local function onChanged()
    table.clear(hi)
end
local function fn161()
    if setclipboard then
        setclipboard(g0)
    elseif toclipboard then
        toclipboard(g0)
    end
    hb:Notify("Copied Discord invite to clipboard")
end
local function fn218(bn)
    for i, descendant in bn:GetDescendants() do
        local i5 = descendant:IsA("BasePart") and hk:HasTag(descendant, "Treadmill")
        if i5 then
            return descendant
        end
    end
    return nil
end
local function autoBuyItemsLoop()
    while true do
        task.wait(2)
        if hb.Unloaded then
            break
        end
        if g1.AutoBuyItems.Value then
            local CharmShop = hl.CharmShop
            for i, child in CharmShop:GetChildren() do
                local kO = tonumber(child.Name:match("^Slot(%d+)$"))
                local kP = kO and CharmShop:FindFirstChild("Bought" .. kO)
                local kQ = kO
                if kQ then
                    kQ = child.Value ~= ""
                end
                if kQ then
                    kQ = Charms.Items[child.Value]
                end
                local kP_1 = kQ
                if kQ then
                    kQ = kP
                end
                if kQ then
                    kQ = not kP.Value
                end
                if kQ then
                    kQ = hh() >= kP_1.Price
                end
                if kQ then
                    gQ:FireServer(kO)
                    task.wait(0.2)
                end
            end
        end
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(gX)
    elseif toclipboard then
        toclipboard(gX)
    end
    hb:Notify("Copied Rscripts profile to clipboard")
end
local function fn279(ap)
    local Map = workspace:FindFirstChild("Map")
    local iC = Map and Map:FindFirstChild("World" .. tostring(ap.World))
    local iB_1 = iC
    if iC then
        iC = iB_1:FindFirstChild("Stages")
    end
    local iB_2 = iC
    if iC then
        iC = iB_2:FindFirstChild("Stage" .. tostring(ap.Order))
    end
    local iB_3 = iC
    if iC then
        local iE = ap.Double and "VipWin" or "NormalWin"
        iC = iB_3:FindFirstChild(iE)
    end
    local iB_4 = iC
    if iC then
        iC = iB_4:FindFirstChild("Button")
    end
    return iC
end
local function autoTreadmillLoop()
    while true do
        local wait = task.wait
        local kf = g1.AutoTreadmill.Value and 0.03 or 0.5
        wait(kf)
        if hb.Unloaded then
            break
        end
        if g1.AutoTreadmill.Value then
            local kd_1 = g2[gY.Treadmill.Value]
            local ke_1 = kd_1 and g_(kd_1)
            local Character = g9.Character
            local kf_1 = Character and Character:FindFirstChild("HumanoidRootPart")
            local kg = Character
            if kg then
                kg = Character:FindFirstChildOfClass("Humanoid")
            end
            local ke_3 = ke_1
            local kf_2 = kg
            if ke_3 then
                ke_3 = kf_1
            end
            if ke_3 then
                ke_3 = kf_2
            end
            if ke_3 then
                ke_3 = kf_2.Health > 0
            end
            if ke_3 then
                if (kf_1.Position - ke_1.Position).Magnitude > 6 then
                    kf_1.AssemblyLinearVelocity = Vector3.zero
                    kf_1.AssemblyAngularVelocity = Vector3.zero
                    kf_1.CFrame = CFrame.new(ke_1.Position + Vector3.new(0, 2, 0))
                end
                kf_2:Move(Vector3.new(0, 0, -1), false)
            end
        end
    end
end
local function fn287()
    if not workspace.CurrentCamera then
        return
    end
    ha:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    ha:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    gN = tick()
end
local function fn317(bt)
    local Map = workspace:FindFirstChild("Map")
    local je = Map and Map:FindFirstChild("World" .. tostring(hl.World.Value))
    local jd_1 = je
    if je then
        je = jd_1:FindFirstChild("Stages")
    end
    local jd_2 = je
    if je then
        je = jd_2:FindFirstChild("Spawn")
    end
    local jf = je
    if je then
        je = jf:FindFirstChild("Treadmills")
    end
    local jf_1 = je
    if je then
        je = jf_1:FindFirstChild(bt.Model)
    end
    local jf_2 = je
    if je then
        je = hn(jf_2)
    end
    local jf_3 = je
    if jf_3 then
        return jf_3
    elseif not jd_2 then
        return nil
    else
        for i, child in jd_2:GetChildren() do
            for i, child in child:GetChildren() do
                if child.Name == bt.Model then
                    local jf_4 = hn(child)
                    if jf_4 then
                        return jf_4
                    end
                end
            end
        end
        return nil
    end
end
local function fn357(aE)
    if hl.World.Value == aE then
        return true
    end
    local iG = gO.WorldRebirthsRequired["World" .. tostring(aE)]
    if iG and hl.Rebirths.Value < iG then
        if not hi[aE] then
            hi[aE] = true
            hb:Notify("World " .. tostring(aE) .. " needs " .. tostring(iG) .. " rebirths")
        end
        return false
    end
    if os.clock() - hd >= 5 then
        hd = os.clock()
        gV:FireServer(aE)
    end
    return false
end
local function onInputChanged(cH)
    local UserInputType = cH.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        gR = tick()
    end
end
local function autoEquipBestItemLoop()
    while true do
        task.wait(3)
        if hb.Unloaded then
            break
        end
        if g1.AutoEquipBestItem.Value then
            EquipBestCharms:FireServer()
        end
    end
end
local function fn383()
    return hl.Wins.Value
end
local function fn384()
    local jx_1
    local jw_1
    if identifyexecutor then
        jx_1, jw_1 = identifyexecutor()
        local jy = jx_1 ~= ""
        local jz = type(jx_1) == "string" and jy
        if jz then
            local jy_1 = type(jw_1) == "string" and jw_1 ~= "" and jx_1 .. " " .. jw_1
            gP = jy_1 or jx_1
        end
    end
end
local function autoBuyAurasLoop()
    while true do
        task.wait(2)
        if hb.Unloaded then
            break
        end
        if g1.AutoBuyAuras.Value then
            for k, v in hj do
                local k7 = hh() >= v.Price and not hl.UnlockedAuras:FindFirstChild(k)
                if k7 then
                    BuyAura:FireServer(k)
                    task.wait(0.2)
                end
            end
        end
    end
end
local function fn440()
    local Character = g9.Character
    local iw = Character and Character:FindFirstChild("HumanoidRootPart")
    return iw
end
local function onUnload()
    hb:Unload()
end
local function fn474(bQ)
    local DiscordGroup = bQ:AddLeftGroupbox("Discord", nil, true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = gW })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = gW })
end
local function onCopyJoinScript_JobID()
    local jE = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, g3)
    if setclipboard then
        setclipboard(jE)
    elseif toclipboard then
        toclipboard(jE)
    end
    hb:Notify("Copied join script to clipboard")
end
local function onInputBegan()
    gR = tick()
end
local function fn580(M, N, O)
    return string.format("<b>%s</b> %s %s", M, gT("-", "#5a6070"), gT(N, O))
end
local function fn584()
    connection:Disconnect()
    connection2:Disconnect()
    select("#", "+1 Speed Monkey Escape unloaded")
end
BuyAura = nil
gI = nil
gJ = nil
gK = nil
gL = nil
gM = nil
gN = nil
gO = nil
gP = nil
gQ = nil
gR = nil
SelectUpgrade = nil
gT = nil
connection = nil
gV = nil
gW = nil
gX = nil
gY = nil
gZ = nil
g_ = nil
g0 = nil
g1 = nil
g2 = nil
g3 = nil
g4 = nil
g5 = nil
g6 = nil
PlayerUtil = nil
Label = nil
g9 = nil
ha = nil
hb = nil
hc = nil
hd = nil
Charms = nil
hf = nil
hg = nil
hh = nil
hi = nil
hj = nil
hk = nil
hl = nil
Trails = nil
hn = nil
connection2 = nil
EquipBestCharms = nil
local ht
local hs_1, hs_7
local hq_1, AccountGroup
local hu, hw, hx, hy, hz, hB, hC, hD, hE, hF, hG, hH, hK, hL
local hA_1
local hv_1
hq_1, hv_1, hk, hG, ha, g9, hB, g0, gX, ht, hs_1, gO, gJ, hy, Trails, hj, Charms, hx, PlayerUtil, hw, gZ, gV, SelectUpgrade, gQ, gL, BuyAura, EquipBestCharms, hl, hu, hb, hE, hC, g1, gY, hz, hD, g4, hA_1, hF, g5, gT, gK, gW, gM, hh = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local hr = 83
local hr_3
repeat
    hH = (hr * 2 + 16) % 21 + 1
    if hH <= 11 then
        if hH <= 6 then
            if hH <= 3 then
                if hH <= 2 then
                    if hH <= 1 then
                        local hI_1 = {
                            "ydeg",
                            "www",
                            "hjrykqripi",
                            "hshtjkgopvu",
                            "sgbocacadw",
                            "mefmvmqzcb",
                            "sqqscf",
                            "ttecwph",
                            "djbzby",
                            "vngbczh",
                            "pymbzqf",
                            "blgeyyzeu"
                        }
                        local md = hr
                        local hJ_1 = hI_1[md % 12 + 1]
                        if hJ_1:len() <= hJ_1:gsub("(.)", "%1%1", md % 3 % 2 + 1):len() then
                            hs_1 = hv_1:WaitForChild("Config")
                        else
                            hv_1 = hs_1:WaitForChild("Config")
                        end
                        hr = (hr + 32) % 84
                    else
                        if (ht or not hC) and (not ht or hr) or not hr and not ht and (hr and hr) or not ((ht or not hC) and (not ht or hr) or not hr and not ht and (hr and hr)) then
                            gO = require(hs_1:WaitForChild("Main"))
                            gJ = require(hs_1:WaitForChild("Upgrades"))
                            hy = require(hs_1:WaitForChild("Treadmills"))
                            Trails = require(hs_1:WaitForChild("Trails"))
                        else
                            hy = require(Trails:WaitForChild("Main"))
                            gO = require(Trails:WaitForChild("Upgrades"))
                            gJ = require(Trails:WaitForChild("Treadmills"))
                            hs_1 = require(Trails:WaitForChild("Trails"))
                        end
                        hr = (hr + 53) % 84
                    end
                else
                    local hI_2 = { "rrhtrse", "kanadf", "mqloqtfmmjn", "zpxvskquhr", "lkeookzlix", "ysrou", "fqiuhhwg", "wovihwodu" }
                    if hI_2[(hr * 86 + 23) % 8 + 1] < hI_2[(hr * 86 + 23) % 8 + 1] then
                        hx = require(Charms:WaitForChild("Auras"))
                        hs_1 = require(Charms:WaitForChild("Charms"))
                        hj = require(Charms:WaitForChild("ProductIDs"))
                    else
                        hj = require(hs_1:WaitForChild("Auras"))
                        Charms = require(hs_1:WaitForChild("Charms"))
                        hx = require(hs_1:WaitForChild("ProductIDs"))
                    end
                    hr = (hr + 74) % 84
                end
            elseif hH <= 5 then
                if hH <= 4 then
                    if hr * 48445297 + 2 + 2 <= hr * 48445297 + 2 + 2 + 6 then
                        PlayerUtil = require(hv_1:WaitForChild("Util"):WaitForChild("PlayerUtil"))
                    else
                        hv_1 = require(PlayerUtil:WaitForChild("Util"):WaitForChild("PlayerUtil"))
                    end
                    hr = (hr + 53) % 84
                else
                    local hI_3 = (vector.create((hr * 3 + 4) % 11 + 1, (hr * 3 + 11) % 13 + 1, (hr * 7 + 13) % 17 + 1))
                    local hJ_2 = (vector.create((hr * 6 + 3) % 11 + 1, (hr * 7 + 1) % 13 + 1, (hr * 12 + 5) % 17 + 1))
                    local lV = vector.cross(hI_3, hJ_2)
                    local lW = vector.dot(hI_3, hJ_2)
                    if vector.dot(lV, lV) + lW * lW == vector.dot(hI_3, hI_3) * vector.dot(hJ_2, hJ_2) + 2 then
                        gZ = require(hw.Util:WaitForChild("Formatter"))
                        gV = SelectUpgrade:WaitForChild("Rebirth")
                        gQ = SelectUpgrade:WaitForChild("TeleportWorld")
                        hv_1 = SelectUpgrade:WaitForChild("SelectUpgrade")
                        ht = SelectUpgrade:WaitForChild("BuyCharm")
                    else
                        hw = require(hv_1.Util:WaitForChild("Formatter"))
                        gZ = ht:WaitForChild("Rebirth")
                        gV = ht:WaitForChild("TeleportWorld")
                        SelectUpgrade = ht:WaitForChild("SelectUpgrade")
                        gQ = ht:WaitForChild("BuyCharm")
                    end
                    hr = (hr + 32) % 84
                end
            else
                local hI_4 = (vector.create((hr * 5 + 4) % 11 + 1, (hr * 10 + 13) % 13 + 1, (hr * 1 + 6) % 17 + 1))
                local hJ_3 = (vector.create((hr * 6 + 5) % 11 + 1, (hr * 9 + 12) % 13 + 1, (hr * 10 + 10) % 17 + 1))
                local lI = vector.dot(hI_4, hJ_3)
                if lI * lI <= vector.dot(hI_4, hI_4) * vector.dot(hJ_3, hJ_3) then
                    gL = ht:WaitForChild("BuyTrail")
                    BuyAura = ht:WaitForChild("BuyAura")
                    EquipBestCharms = ht:WaitForChild("EquipBestCharms")
                    hl = g9:WaitForChild("Data")
                else
                    ht = BuyAura:WaitForChild("BuyTrail")
                    gL = BuyAura:WaitForChild("BuyAura")
                    hl = BuyAura:WaitForChild("EquipBestCharms")
                    g9 = EquipBestCharms:WaitForChild("Data")
                end
                hr = (hr + 74) % 84
            end
        elseif hH <= 9 then
            if hH <= 8 then
                if hH <= 7 then
                    if hr * 25309581 + 9 + 5 >= hr * 25309581 + 9 + 5 + 2 then
                        gV = ""
                    else
                        hu = ""
                    end
                    hr = (hr + 74) % 84
                else
                    local hI_5 = (vector.create((hr * 3 + 2) % 11 + 1, (hr * 1 + 7) % 13 + 1, (hr * 13 + 5) % 17 + 1))
                    local hJ_4 = (vector.create((hr * 3 + 9) % 11 + 1, (hr * 1 + 12) % 13 + 1, (hr * 12 + 15) % 17 + 1))
                    local l3 = vector.cross(hI_5, hJ_4)
                    local l4 = vector.dot(hI_5, hJ_4)
                    if vector.dot(l3, l3) + l4 * l4 == vector.dot(hI_5, hI_5) * vector.dot(hJ_4, hJ_4) + 2 then
                        gY = getgenv().Library
                        hb = getgenv().ThemeManager
                        hu = getgenv().SaveManager
                        hE = gY.Toggles
                        g1 = gY.Options
                    else
                        hb = getgenv().Library
                        hE = getgenv().ThemeManager
                        hC = getgenv().SaveManager
                        g1 = hb.Toggles
                        gY = hb.Options
                    end
                    hr = (hr + 11) % 84
                end
            else
                local lU = bit32.rrotate(bit32.bxor(bit32.lrotate(hr, 27), string.byte(tostring(gO))), 16)
                if bit32.bxor(bit32.lrotate(bit32.bxor(lU, 666886808), 0), 666886808) ~= bit32.lrotate(lU, 0) then
                    gK = fn64
                    gT = fn580
                else
                    gT = fn64
                    gK = fn580
                end
                hr = (hr + 74) % 84
            end
        elseif hH <= 10 then
            if (g1 or gW) and (hb or g9) or g1 and not gW and (not g9 and not gW) or (gW or not hb or g1 and not hC) and (hb and hb or (hb or not gW)) or not ((g1 or gW) and (hb or g9) or g1 and not gW and (not g9 and not gW) or (gW or not hb or g1 and not hC) and (hb and hb or (hb or not gW))) then
                hz = "#7fd47f"
            else
                gK = "#7fd47f"
            end
            hr = (hr + 32) % 84
        else
            local hI_6 = (vector.create((hr * 5 + 7) % 11 + 1, (hr * 3 + 1) % 13 + 1, (hr * 3 + 2) % 17 + 1))
            local lO = vector.floor(hI_6) + vector.ceil(hI_6 * -1)
            if vector.dot(lO, lO) == 0 then
                hD = "#6ec1ff"
                g4 = "#e8a34d"
            else
                g4 = "#6ec1ff"
                hD = "#e8a34d"
            end
            hr = (hr + 74) % 84
        end
    elseif hH <= 16 then
        if hH <= 14 then
            if hH <= 13 then
                if hH <= 12 then
                    local lT = bit32.rrotate(bit32.bxor(bit32.lrotate(hr, 27), string.byte(tostring(hA_1))), 23)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(lT, 4011580601), 4256026318), (bit32.bxor(bit32.band(lT, 283386694), 1450872663))), 4256026318), 1450872663) == lT then
                        hA_1 = "#8b93a3"
                        gW = fn161
                    else
                        gW = "#8b93a3"
                        hA_1 = fn161
                    end
                    hr = (hr + 74) % 84
                else
                    local hI_7 = (vector.create((hr * 7 + 5) % 11 + 1, (hr * 8 + 3) % 13 + 1, (hr * 10 + 10) % 17 + 1))
                    local hJ_5 = (vector.create((hr * 7 + 7) % 11 + 1, (hr * 9 + 1) % 13 + 1, (hr * 15 + 3) % 17 + 1))
                    local l0 = vector.cross(hI_7, hJ_5)
                    local l1 = vector.dot(hI_7, hJ_5)
                    if vector.dot(l0, l0) + l1 * l1 == vector.dot(hI_7, hI_7) * vector.dot(hJ_5, hJ_5) + 1 then
                        hD = fn440
                    else
                        gM = fn440
                    end
                    hr = (hr + 74) % 84
                end
            else
                local hI_8 = (vector.create((hr * 7 + 8) % 11 + 1, (hr * 4 + 13) % 13 + 1, (hr * 7 + 2) % 17 + 1))
                local hJ_6 = (vector.create((hr * 2 + 9) % 11 + 1, (hr * 7 + 8) % 13 + 1, (hr * 3 + 1) % 17 + 1))
                hK = (vector.create((hr * 1 + 9) % 11 + 1, (hr * 2 + 1) % 13 + 1, (hr * 1 + 2) % 17 + 1))
                if vector.dot(vector.cross(hI_8, hJ_6), hK) == vector.dot(vector.cross(hJ_6, hK), hI_8) + 4 then
                    g5 = fn383
                    hh = {}
                    hF = {}
                else
                    hh = fn383
                    hF = {}
                    g5 = {}
                end
                hr = (hr + 11) % 84
            end
        elseif hH <= 15 then
            local hI_9 = { "yjzwvrd", "xlsomzhbzv", "rurt", "nnyziepgqre", "hnl", "iwfj", "ltamcbqbror" }
            local lH = hr
            local hJ_7 = hI_9[lH % 7 + 1]
            if hJ_7:len() >= hJ_7:gsub("(.)", "%1%1", lH % 3 % 2 + 1):len() then
                hw = game:GetService("Players")
            else
                hq_1 = game:GetService("Players")
            end
            hr = (hr + 11) % 84
        else
            local hI_10 = {
                "phgcpnuxh",
                "luag",
                "bvcowzkesiu",
                "zfxlnlwrr",
                "qmod",
                "ceatvbxbbwy",
                "gosyqzukb",
                "zhmvs",
                "vscpxz",
                "vpfytidi",
                "ueojknelu"
            }
            if hI_10[(hr * 25 + 71) % 11 + 1] < hI_10[(hr * 25 + 71) % 11 + 1] then
                hs_1 = game:GetService("ReplicatedStorage")
            else
                hv_1 = game:GetService("ReplicatedStorage")
            end
            hr = (hr + 11) % 84
        end
    elseif hH <= 19 then
        if hH <= 18 then
            if hH <= 17 then
                local hI_11 = {
                    "thtuubsc",
                    "gjlnybb",
                    "gglkuhr",
                    "tgunuh",
                    "qtnsabbi",
                    "zbdgfycnft",
                    "qccvzhgoylr",
                    "ipe",
                    "pymn"
                }
                local mb = hr
                local hJ_8 = hI_11[mb % 9 + 1]
                if hJ_8:len() <= hJ_8:gsub("(.)", "%1%1", mb % 3 % 2 + 1):len() then
                    hk = game:GetService("CollectionService")
                    hG = game:GetService("UserInputService")
                    ha = game:GetService("VirtualUser")
                else
                    ha = game:GetService("CollectionService")
                    hk = game:GetService("UserInputService")
                    hG = game:GetService("VirtualUser")
                end
                hr = (hr + 53) % 84
            else
                local hI_12 = (vector.create((hr * 1 + 7) % 11 + 1, (hr * 7 + 13) % 13 + 1, (hr * 14 + 7) % 17 + 1))
                local hJ_9 = (vector.create((hr * 7 + 7) % 11 + 1, (hr * 8 + 2) % 13 + 1, (hr * 3 + 4) % 17 + 1))
                hK = (vector.create((hr * 5 + 5) % 11 + 1, (hr * 1 + 3) % 13 + 1, (hr * 14 + 14) % 17 + 1))
                hL = (vector.create((hr * 3 + 2) % 5 + 1, (hr * 3 + 6) % 7 + 1, (hr * 5 + 7) % 9 + 1))
                if vector.dot(vector.cross(hI_12, (vector.cross(hJ_9, hK))), hL) == vector.dot(hJ_9 * vector.dot(hI_12, hK) - hK * vector.dot(hI_12, hJ_9), hL) then
                    g9 = hq_1.LocalPlayer
                else
                    hq_1 = g9.LocalPlayer
                end
                hr = (hr + 53) % 84
            end
        else
            local lS = bit32.rrotate(bit32.bxor(bit32.lrotate(hr, 4), string.byte(tostring(g4))), 26)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(lS, 1790992379), 334129806), (bit32.bxor(bit32.band(lS, 2503974916), 2560079233))), 334129806), 2560079233) == lS then
                hB = "+1 Speed Monkey Escape"
                g0 = "https://discord.gg/K7Qxnxkk46"
            else
                g0 = "+1 Speed Monkey Escape"
                hB = "https://discord.gg/K7Qxnxkk46"
            end
            hr = (hr + 11) % 84
        end
    elseif hH <= 20 then
        local mi = bit32.rrotate(bit32.bxor(bit32.lrotate(hr, 17), string.byte(tostring(PlayerUtil))), 30)
        if bit32.bxor(bit32.lrotate(bit32.bxor(mi, 3172346937), 14), 2332979013) ~= bit32.lrotate(mi, 14) then
            hz = "https://discord.gg/K7Qxnxkk46"
        else
            gX = "https://discord.gg/K7Qxnxkk46"
        end
        hr = (hr + 74) % 84
    else
        hH = { "djx", "mkonjqus", "hysc", "kejvkryue", "kugktcjptph", "anvlc", "byrbudhzy" }
        local mj = hr
        local hI_13 = hH[mj % 7 + 1]
        if hI_13:len() <= hI_13:gsub("(.)", "%1%1", mj % 3 % 2 + 1):len() then
            ht = hv_1:WaitForChild("Remotes")
        else
            hv_1 = ht:WaitForChild("Remotes")
        end
        hr = (hr + 53) % 84
    end
until (hr * 17 + 65) % 84 == 48
local h1 = 1
while h1 <= 4 do
    local h2 = h1
    local h3 = h2
    local hq_2 = gO.StageWins["World" .. tostring(h3)]
    if hq_2 then
        for i, v in ipairs(hq_2) do
            for k, v2 in { false, true } do
                local hq_4 = v2 and v * 2 or v
                local format = string.format
                h3 = h2
                ht = v2 and "Double" or "Normal"
                local hs_3 = format("World %d - Stage %d - %s (+%s)", h3, i, ht, hw.Format(hq_4))
                if v2 then
                    hs_3 = hs_3 .. " [Gamepass]"
                end
                table.insert(hF, hs_3)
                g5[hs_3] = { World = h3, Order = i, Double = v2 }
            end
        end
    end
    h1 += 1
end
hi, hd, hr_3, hu, g2, ht, hf, g6, hg = nil, nil, nil, nil, nil, nil, nil, nil, nil
local hq_5 = 22
repeat
    local hs_4 = (hq_5 * 4 + 2) % 5 + 1
    if hs_4 <= 3 then
        if hs_4 <= 2 then
            if hs_4 <= 1 then
                local hv_2 = (vector.create((hq_5 * 4 + 7) % 11 + 1, (hq_5 * 9 + 5) % 13 + 1, (hq_5 * 1 + 7) % 17 + 1))
                hw = (vector.create((hq_5 * 1 + 1) % 11 + 1, (hq_5 * 3 + 10) % 13 + 1, (hq_5 * 1 + 12) % 17 + 1))
                hH = (vector.create((hq_5 * 3 + 9) % 11 + 1, (hq_5 * 4 + 10) % 13 + 1, (hq_5 * 5 + 4) % 17 + 1))
                local hI_14 = (vector.create((hq_5 * 1 + 4) % 11 + 1, (hq_5 * 6 + 4) % 13 + 1, (hq_5 * 6 + 6) % 17 + 1))
                if vector.dot(vector.cross(hv_2, hw), (vector.cross(hH, hI_14))) == vector.dot(hv_2, hH) * vector.dot(hw, hI_14) - vector.dot(hv_2, hI_14) * vector.dot(hw, hH) + 3 then
                    hr_3 = fn279
                else
                    hf = fn279
                end
                hq_5 = (hq_5 + 19) % 40
            else
                local l8 = bit32.rrotate(bit32.bxor(bit32.lrotate(hq_5, 19), string.byte(tostring(hd))), 1)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(l8, 1698175147), 3088874695), (bit32.bxor(bit32.band(l8, 2596792148), 756416866))), 3088874695), 756416866) ~= l8 then
                    g6 = {}
                    hi = 0
                    hd.Rebirths.Changed:Connect(onChanged)
                    hl = fn357
                else
                    hi = {}
                    hd = 0
                    hl.Rebirths.Changed:Connect(onChanged)
                    g6 = fn357
                end
                hq_5 = (hq_5 + 4) % 40
            end
        else
            if (hq_5 * 3 + 3) * 13 % 4 == ((hq_5 * 3 + 3) * 13 + 11) % 4 then
                hi = function(aO)
                    local iM
                    local Map = workspace:FindFirstChild("Map")
                    local iO = Map and Map:FindFirstChild("Checkpoints")
                    local iN_7 = iO
                    if iO then
                        iO = iN_7:FindFirstChild("World" .. tostring(aO.World))
                    end
                    local iN_8 = iO
                    if not iN_8 then
                        return
                    end
                    local iO_5 = iN_8:FindFirstChild("Checkpoint" .. tostring(aO.Order))
                    if not iO_5 then
                        local iP_3 = 0
                        for i, child in iN_8:GetChildren() do
                            local iN_9 = tonumber(child.Name:match("^Checkpoint(%d+)$"))
                            if iN_9 and iN_9 > iP_3 and iN_9 < aO.Order then
                                iP_3 = iN_9
                                iO_5 = child
                            end
                        end
                    end
                    local iN_10 = iO_5
                    if iN_10 then
                        local iP_4 = iO_5:FindFirstChild("SpawnPoint") or iO_5:FindFirstChild("Hitbox")
                        iN_10 = iP_4
                    end
                    local iO_6 = iN_10
                    local iN_11 = not iO_6 or not iO_6:IsA("BasePart")
                    local i_ = if iN_11 then 1 else 0
                    local iY = 2752 * i_ + 1648 * (1 - i_)
                    local iZ = 1276 * i_ + 2344 * (1 - i_)
                    if not ((iY * 1426 + iZ * 2667 + iY * iZ) % 16777213 == 10838996) then
                        iN_11 = not gM()
                    end
                    if iN_11 then
                        return
                    end
                    iM = iO_6.Position + Vector3.new(0, 5, 0)
                    pcall(function()
                        g9:RequestStreamAroundAsync(iM)
                    end)
                    local iN_12 = RaycastParams.new()
                    iN_12.FilterType = Enum.RaycastFilterType.Exclude
                    iN_12.FilterDescendantsInstances = { g9.Character }
                    local i2 = 1
                    while i2 <= 60 do
                        local i3 = i2
                        local iO_7 = gM()
                        if not iO_7 then
                            return
                        end
                        iO_7.AssemblyLinearVelocity = Vector3.zero
                        iO_7.AssemblyAngularVelocity = Vector3.zero
                        iO_7.CFrame = CFrame.new(iM)
                        local iO_8 = i3 > 4 and workspace:Raycast(iM, Vector3.new(0, -100, 0), iN_12)
                        if iO_8 then
                            break
                        end
                        task.wait(0.05)
                        i2 += 1
                    end
                end
            else
                hg = function(aO)
                    local iM
                    local Map = workspace:FindFirstChild("Map")
                    local iO = Map and Map:FindFirstChild("Checkpoints")
                    local iN_1 = iO
                    if iO then
                        iO = iN_1:FindFirstChild("World" .. tostring(aO.World))
                    end
                    local iN_2 = iO
                    if not iN_2 then
                        return
                    end
                    local iO_1 = iN_2:FindFirstChild("Checkpoint" .. tostring(aO.Order))
                    if not iO_1 then
                        local iP_1 = 0
                        for i, child in iN_2:GetChildren() do
                            local iN_3 = tonumber(child.Name:match("^Checkpoint(%d+)$"))
                            if iN_3 and iN_3 > iP_1 and iN_3 < aO.Order then
                                iP_1 = iN_3
                                iO_1 = child
                            end
                        end
                    end
                    local iN_4 = iO_1
                    if iN_4 then
                        local iP_2 = iO_1:FindFirstChild("SpawnPoint") or iO_1:FindFirstChild("Hitbox")
                        iN_4 = iP_2
                    end
                    local iO_2 = iN_4
                    local iN_5 = not iO_2 or not iO_2:IsA("BasePart")
                    local i_ = if iN_5 then 1 else 0
                    local iY = 2752 * i_ + 1648 * (1 - i_)
                    local iZ = 1276 * i_ + 2344 * (1 - i_)
                    if not ((iY * 1426 + iZ * 2667 + iY * iZ) % 16777213 == 10838996) then
                        iN_5 = not gM()
                    end
                    if iN_5 then
                        return
                    end
                    iM = iO_2.Position + Vector3.new(0, 5, 0)
                    pcall(function()
                        g9:RequestStreamAroundAsync(iM)
                    end)
                    local iN_6 = RaycastParams.new()
                    iN_6.FilterType = Enum.RaycastFilterType.Exclude
                    iN_6.FilterDescendantsInstances = { g9.Character }
                    local i2 = 1
                    while i2 <= 60 do
                        local i3 = i2
                        local iO_3 = gM()
                        if not iO_3 then
                            return
                        end
                        iO_3.AssemblyLinearVelocity = Vector3.zero
                        iO_3.AssemblyAngularVelocity = Vector3.zero
                        iO_3.CFrame = CFrame.new(iM)
                        local iO_4 = i3 > 4 and workspace:Raycast(iM, Vector3.new(0, -100, 0), iN_6)
                        if iO_4 then
                            break
                        end
                        task.wait(0.05)
                        i2 += 1
                    end
                end
            end
            hq_5 = (hq_5 + 24) % 40
        end
    elseif hs_4 <= 4 then
        if hq_5 * 64829005 + 12 + 7 <= hq_5 * 64829005 + 12 + 7 + 4 then
            hr_3 = {
                { Name = "Celestial", Model = "TreadmillCelestial" },
                { Name = "Void", Model = "TreadmillVoid" },
                { Name = "Galaxy", Model = "TreadmillGalaxy" },
                { Name = "Diamond", Model = "TreadmillDiamond" },
                { Name = "Golden", Model = "TreadmillGold" },
                { Name = "Reward", Model = "TreadmillPlaytime" },
                { Name = "Basic", Model = "TreadmillBasic" }
            }
        else
            g2 = {
                { Name = "Void", Model = "TreadmillVoid" },
                { Name = "Reward", Model = "TreadmillPlaytime" },
                { Name = "Celestial", Model = "TreadmillCelestial" },
                { Name = "Galaxy", Model = "TreadmillGalaxy" },
                { Name = "Diamond", Model = "TreadmillDiamond" },
                { Name = "Basic", Model = "TreadmillBasic" },
                { Name = "Golden", Model = "TreadmillGold" }
            }
        end
        hq_5 = (hq_5 + 4) % 40
    else
        local hs_5 = (vector.create((hq_5 * 3 + 2) % 11 + 1, (hq_5 * 10 + 8) % 13 + 1, (hq_5 * 4 + 14) % 17 + 1))
        local l9 = vector.floor(hs_5) + vector.ceil(hs_5 * -1)
        if vector.dot(l9, l9) == 0 then
            hu = {}
            g2 = {}
            ht = nil
        else
            ht = {}
            hu = {}
            g2 = nil
        end
        hq_5 = (hq_5 + 9) % 40
    end
until (hq_5 * 17 + 28) % 40 == 22
for k, v in hr_3 do
    local hr_4 = hy.Multis[v.Name] or 1
    local hq_7 = v.Name .. " (x" .. tostring(hr_4) .. " Speed)"
    if hx[v.Name] then
        hq_7 = hq_7 .. " [Robux]"
    end
    table.insert(hu, hq_7)
    g2[hq_7] = v
    local hr_5 = not ht
    if hr_5 ~= false then
        hr_5 = not hx[v.Name]
    end
    if hr_5 then
        ht = hq_7
    end
end
hn, g_ = nil, nil
hn = fn218
g_ = fn317
local Window = hb:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = g0, Copyable = true }, "|", hB },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10,
    Size = UDim2.fromOffset(940, 720)
})
hw = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Shop = Window:AddTab("Shop", "shopping-cart"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in hw do
    fn474(v)
end
gP, AccountGroup, hx, Label, g3, hs_7 = nil, nil, nil, nil, nil, nil
local hr_6 = 7
repeat
    local hv_4 = (hr_6 * 2 + 2) % 3 + 1
    if hv_4 <= 2 then
        if hv_4 <= 1 then
            local mk = bit32.rrotate(bit32.bxor(bit32.lrotate(hr_6, 12), string.byte(tostring(hx))), 12)
            if bit32.bxor(bit32.lrotate(bit32.bxor(mk, 842339379), 6), 2370112716) ~= bit32.lrotate(mk, 6) then
                g3 = #hs_7 > 18
            else
                hs_7 = #g3 > 18
            end
            hr_6 = (hr_6 + 23) % 24
        else
            local hv_5 = {
                "gork",
                "rovsjonnw",
                "xfrygwkcjz",
                "ugsntmwhzhf",
                "tzyxxcftwyj",
                "hlx",
                "ptzeyvk",
                "fdhpha",
                "vowib",
                "nqnx"
            }
            if hv_5[(hr_6 * 89 + 87) % 10 + 1] < hv_5[(hr_6 * 89 + 87) % 10 + 1] then
                gK = "Unknown"
                pcall(fn384)
                hx = Label.Info:AddLeftGroupbox("Account", "circle-user")
                hx:AddLabel(gT("User", g4.Name, hw), true)
                hx:AddLabel(gT("Status", "Keyless", hw), true)
                hx:AddLabel(gT("Executor", gK, hw), true)
                gP = Label.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                gP:AddLabel(AccountGroup(g9 .. " [" .. tostring(game.PlaceId) .. "]", hB), true)
                gP:AddLabel(gT("Place ID", tostring(game.PlaceId), hB), true)
                hz = gP:AddLabel(gT("Session time", "0s", hD), true)
            else
                gP = "Unknown"
                pcall(fn384)
                AccountGroup = hw.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(gK("User", g9.Name, hz), true)
                AccountGroup:AddLabel(gK("Status", "Keyless", hz), true)
                AccountGroup:AddLabel(gK("Executor", gP, hz), true)
                hx = hw.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                hx:AddLabel(gT(hB .. " [" .. tostring(game.PlaceId) .. "]", hD), true)
                hx:AddLabel(gK("Place ID", tostring(game.PlaceId), hD), true)
                Label = hx:AddLabel(gK("Session time", "0s", g4), true)
            end
            hr_6 = (hr_6 + 11) % 24
        end
    else
        local hv_6 = { "aikrthzbfd", "rturgblo", "zsrvdiq", "yga", "qyuflh", "nlgfcb", "hfmsdagqte", "ndc" }
        if hv_6[(hr_6 * 50 + 101) % 8 + 1] <= hv_6[(hr_6 * 50 + 101) % 8 + 1] then
            g3 = tostring(game.JobId)
        else
            hx = tostring(game.JobId)
        end
        hr_6 = (hr_6 + 2) % 24
    end
until (hr_6 * 5 + 7) % 24 == 6
if hs_7 then
    local hq_9 = 0
    repeat
        local hr_7 = (vector.create((hq_9 * 7 + 9) % 11 + 1, (hq_9 * 4 + 6) % 13 + 1, (hq_9 * 12 + 8) % 17 + 1))
        local hv_7 = (vector.create((hq_9 * 2 + 6) % 11 + 1, (hq_9 * 11 + 10) % 13 + 1, (hq_9 * 9 + 1) % 17 + 1))
        local lJ = vector.cross(hr_7, hv_7)
        local lK = vector.dot(hr_7, hv_7)
        if vector.dot(lJ, lJ) + lK * lK == vector.dot(hr_7, hr_7) * vector.dot(hv_7, hv_7) + 1 then
            g3 = string.sub(hs_7, 1, 18) .. "..."
        else
            hs_7 = string.sub(g3, 1, 18) .. "..."
        end
        hq_9 = (hq_9 + 7) % 8
    until (hq_9 * 3 + 7) % 8 == 4
end
local hq_10 = hs_7 or g3
gI, hz, gR, gN, connection, connection2, hc = nil, nil, nil, nil, nil, nil, nil
hy = hq_10
hx:AddLabel(gK("Server", hy, hA_1), true)
hx:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
gI = os.clock()
task.spawn(worker)
hH = hw.Info:AddRightGroupbox("Scripts", "package")
hH:AddLabel(gT("Included in this hub", hA_1), true)
hH:AddLabel(gT(hB, hD), true)
local FeaturesGroup = hw.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(gT("Auto Win", hD), true)
FeaturesGroup:AddLabel(gT("Auto Treadmill", hD), true)
FeaturesGroup:AddLabel(gT("Auto Rebirth", g4), true)
FeaturesGroup:AddLabel(gT("Auto Buy and Equip Speed Upgrades", hD), true)
FeaturesGroup:AddLabel(gT("Auto Buy Items, Trails and Auras", g4), true)
FeaturesGroup:AddLabel(gT("Auto Equip Best Item", hA_1), true)
local SocialsGroup = hw.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = gW })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = hw.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = gW })
local FaqGroup = hw.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoWinGroup = hw.Main:AddLeftGroupbox("Auto Win", "trophy")
AutoWinGroup:AddLabel("Game doesn't let you get the best possible win, it has speed checks, get high speed and you'll be able to get better wins.", true)
AutoWinGroup:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
AutoWinGroup:AddDropdown("WinPlate", { Text = "Win Plate", Values = hF, Default = hF[1] })
AutoWinGroup:AddSlider("WinDelay", { Text = "Win Delay", Default = 2, Min = 0.5, Max = 10, Rounding = 1 })
local AutoTreadmillGroup = hw.Main:AddLeftGroupbox("Auto Treadmill", "footprints")
AutoTreadmillGroup:AddToggle("AutoTreadmill", { Text = "Auto Treadmill", Default = false })
AutoTreadmillGroup:AddDropdown("Treadmill", { Text = "Treadmill", Values = hu, Default = ht })
local AutoRebirthGroup = hw.Main:AddRightGroupbox("Auto Rebirth", "rotate-ccw")
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
hL = hw.Main:AddRightGroupbox("Auto Buy Speed Upgrades", "arrow-up-circle")
hL:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Speed Upgrades", Default = false })
hL:AddToggle("AutoEquipBestUpgrade", { Text = "Auto Equip Best Speed Upgrade", Default = false })
hK = hw.Shop:AddLeftGroupbox("Auto Buy Items", "gem")
hK:AddToggle("AutoBuyItems", { Text = "Auto Buy Items", Default = false })
hK:AddToggle("AutoEquipBestItem", { Text = "Auto Equip Best Item", Default = false })
local AutoBuyTrailsGroup = hw.Shop:AddRightGroupbox("Auto Buy Trails", "wind")
if ((not AutoTreadmillGroup and AutoTreadmillGroup or hH and AutoTreadmillGroup) and (not AutoTreadmillGroup or hH or (AutoTreadmillGroup or hH)) or (not hH or not hH) and (not hH or AutoTreadmillGroup) and (hH and hH and (not AutoTreadmillGroup or hH))) and not ((not AutoTreadmillGroup and AutoTreadmillGroup or hH and AutoTreadmillGroup) and (not AutoTreadmillGroup or hH or (AutoTreadmillGroup or hH)) or (not hH or not hH) and (not hH or AutoTreadmillGroup) and (hH and hH and (not AutoTreadmillGroup or hH))) then
    hz:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
    hw = AutoBuyTrailsGroup.Shop:AddRightGroupbox("Auto Buy Auras", "sparkles")
else
    AutoBuyTrailsGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
    hz = hw.Shop:AddRightGroupbox("Auto Buy Auras", "sparkles")
end
hz:AddToggle("AutoBuyAuras", { Text = "Auto Buy Auras", Default = false })
local MenuGroup = hw.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
hb.ToggleKeybind = gY.MenuKeybind
gR = tick()
gN = tick()
pcall(function()
    for i, v in ipairs(getconnections(g9.Idled)) do
        local jT = v
        pcall(function()
            jT:Disable()
        end)
    end
end)
hc = fn287
connection = hG.InputBegan:Connect(onInputBegan)
connection2 = hG.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
hE:SetLibrary(hb)
hE:SetFolder("TempoHub")
hE:SaveDefault("Monochrome")
hC:SetLibrary(hb)
hC:IgnoreThemeSettings()
hC:SetIgnoreIndexes({ "MenuKeybind" })
hC:SetFolder("TempoHub/SpeedMonkeyEscape")
hC:BuildConfigSection(hw.Settings)
hE:ApplyToTab(hw.Settings)
hE:LoadDefault()
hC:LoadAutoloadConfig()
hb:OnUnload(fn584)
task.spawn(antiAfkLoop)
task.spawn(autoWinLoop)
task.spawn(autoTreadmillLoop)
task.spawn(autoRebirthLoop)
task.spawn(autoBuyUpgradesLoop)
task.spawn(autoEquipBestUpgradeLoop)
task.spawn(autoBuyItemsLoop)
task.spawn(autoEquipBestItemLoop)
task.spawn(autoBuyTrailsLoop)
task.spawn(autoBuyAurasLoop)
end)(...)
