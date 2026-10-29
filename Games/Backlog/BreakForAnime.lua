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
getgenv().TempoHoodSubtitle = "BREAK FOR ANIME!"
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
local Pickaxe2
local o3
local oq
local oO
local ov
local PlayerStateClient
local n9
local oU
local oc
local oB
local Car2
local Toggles
local o_
local o2
local oH
local Upgrade
local oK
local oi
local op
local Block2
local n8
local oT
local ob
local oW
local Mutation
local oe
local oG
local o1
local oh
local oJ
local oM
local oo
local oP
local ot
local Library
local Options
local oz
local od
local oC
local oY
local Workspace
local o0
local function fn35()
    if not oT("AutoBuyPickaxes") then
        return
    end
    if os.clock() - oM.pickaxeBuyAt < 1.5 then
        return
    end
    local Pickaxes = Pickaxe2.Pickaxes
    if type(Pickaxes) ~= "table" then
        return
    end
    local s6 = 0
    for i, v in ipairs(Pickaxes) do
        local s7 = type(v) == "table" and type(v.Name) == "string" and od("OwnedPickaxes", v.Name)
        if s7 then
            s6 = i
        end
    end
    for i, v in ipairs(Pickaxes) do
        local s5_1 = Library.Unloaded or not oT("AutoBuyPickaxes")
        if s5_1 then
            return
        end
        local s5_2 = i > s6 and type(v) == "table" and type(v.Name) == "string"
        if s5_2 then
            local s5_3 = v.RobuxOnly or type(v.Price) ~= "number"
            if not s5_3 then
                if not od("OwnedPickaxes", v.Name) then
                    if oM.canSpend(v.Price) then
                        oM.pickaxeBuyAt = os.clock()
                        oo:FireServer("Buy", v.Name)
                        task.wait(0.35)
                        oo:FireServer("Equip", v.Name)
                        return
                    end
                    return
                end
            end
        end
    end
end
local function fn47(a6, a7)
    local p8_1
    local p7_1
    p7_1, p8_1 = pcall(PlayerStateClient.Get, a6)
    if p7_1 and p8_1 ~= nil then
        return p8_1
    end
    return a7
end
local function fn105()
    return oW(oJ("Cash", 0))
end
local function fn110()
    local ux, uy
    if not oT("AutoBreak") then
        oM.setAutoSwing(false)
        return
    end
    local uu = oM.resolvePlot()
    if not uu then
        oM.setAutoSwing(false)
        return
    end
    local uv = oM.blockSlots(uu)
    if #uv == 0 then
        oM.setAutoSwing(false)
        return
    end
    oM.ensurePickaxe()
    oM.setAutoSwing(true)
    local uw = math.max(oM.pickaxeDamage(), 1)
    local uB = false
    for k, v in uv do
        local uA = 10
        while true do
            if uA < 12 then
                if uA < 6 then
                    if uA < 3 then
                        if uA < 1 then
                            oM.standAtSlot(uu, v.index)
                            task.wait(0.2)
                            uA = 23
                        elseif uA < 2 then
                            uA = if uy then 4 else 0
                        else
                            uy = uv.Pending
                            uA = 18
                        end
                    elseif uA < 4 then
                        uy = uv.Type ~= "Block"
                        uA = 7
                    elseif uA < 5 then
                        uA = 13
                    else
                        uv = Library.Unloaded
                        uA = if uv then 16 else 12
                    end
                elseif uA < 9 then
                    if uA < 7 then
                        uA = if uv then 21 else 17
                    elseif uA < 8 then
                        uA = if uy then 18 else 2
                    else
                        uA = 20
                    end
                elseif uA < 10 then
                    return
                elseif uA < 11 then
                    uv = Library.Unloaded
                    uA = if uv then 6 else 14
                else
                    break
                end
            elseif uA < 18 then
                if uA < 15 then
                    if uA < 13 then
                        uv = not oT("AutoBreak")
                        uA = 16
                    elseif uA < 14 then
                        uA = 11
                    else
                        uv = not oT("AutoBreak")
                        uA = 6
                    end
                elseif uA < 16 then
                    uB = true
                    uA = 11
                elseif uA < 17 then
                    uA = if uv then 9 else 22
                else
                    oM.ensurePickaxe()
                    oM.standAtSlot(uu, v.index)
                    uv = math.ceil(math.max(v.health, 1) / uw)
                    ux = os.clock() + math.clamp(uv * oc + 1.5, 2, 25)
                    uA = 8
                end
            elseif uA < 21 then
                if uA < 19 then
                    uA = if uy then 1 else 19
                elseif uA < 20 then
                    uy = not uv.Occupied
                    uA = 1
                else
                    uA = if os.clock() < ux then 5 else 24
                end
            elseif uA < 23 then
                if uA < 22 then
                    return
                end
                uv = od("Plot.Slots", v.index)
                uy = not uv
                uA = if uy then 7 else 3
            elseif uA < 24 then
                uA = 8
            else
                uA = 13
            end
        end
        if uB then
            break
        end
    end
end
local function fn154()
    if not Toggles.AutoBreak.Value then
        oM.setAutoSwing(false)
    end
end
local function fn214()
    return oH
end
local function fn256()
    if not oT("AutoSell") then
        return
    end
    local tW = oJ("Cars", {})
    if type(tW) ~= "table" then
        return
    end
    local tX = oT("KeepMutations")
    local tY = os.clock()
    for k, v in oM.sold do
        if tY - v > 4 then
            oM.sold[k] = nil
        end
    end
    for k, v in tW do
        local tW_1 = Library.Unloaded or not oT("AutoSell")
        if tW_1 then
            return
        end
        if type(v) == "table" then
            local tW_2 = v.UUID
            if type(tW_2) ~= "string" then
                local tZ_1 = type(k) == "string" and k
                tW_2 = tZ_1 or nil
            end
            if not (tW_2 and oM.sold[tW_2]) then
                local Name = v.Name
                local t__2 = v.Mutation or "Normal"
                local t__3 = type(tW_2) == "string" and type(Name) == "string"
                if t__3 then
                    local t__4 = Car2.GetCarData(Name)
                    local tZ_4 = t__4 and t__4.Rarity
                    local tZ_5 = type(tZ_4) == "string" and oz(Options.SellRarities, tZ_4)
                    if tZ_5 then
                        if not (tX and t__2 ~= "Normal") then
                            oM.sold[tW_2] = tY
                            oi:FireServer(tW_2)
                            task.wait(oY)
                        end
                    end
                end
            end
        end
    end
end
local function fn264(aS)
    local pR = Toggles[aS]
    return pR ~= nil and pR.Value == true
end
local function fn289()
    local sq = if not oT("AutoBuyBlocks") then 1 else 0
    if sq == 1 then
        return
    end
    local sj = oM.resolvePlot()
    if not sj then
        return
    end
    local SpawnedBlocks = sj:FindFirstChild("SpawnedBlocks")
    if not SpawnedBlocks then
        return
    end
    local sj_1 = os.clock()
    for k, v in oM.bought do
        if sj_1 - v > 8 then
            oM.bought[k] = nil
        end
    end
    for i, child in SpawnedBlocks:GetChildren() do
        local sk_1 = Library.Unloaded or not oT("AutoBuyBlocks")
        if sk_1 then
            return
        end
        local sk_2 = oM.readSpawned(child)
        local sl = sk_2 and not oM.bought[sk_2.uuid] and oz(Options.BuyBlockFilter, sk_2.name)
        if sl then
            local sl_1 = oM.blockPrice(sk_2.name, sk_2.mutation)
            local sm = sl_1 and oM.canSpend(sl_1)
            if sm then
                oM.bought[sk_2.uuid] = sj_1
                oP:FireServer(sk_2.uuid)
                task.wait(n8)
            end
        end
    end
end
local function fn366(cl)
    local Name = cl.Name
    if type(Name) ~= "string" then
        return nil
    end
    for k, v in o_ do
        if Name == v then
            return v
        end
    end
    local rg = string.match(Name, "^%[X%d+%]%s*(.+)$")
    if rg then
        return rg
    end
    return Name
end
local function fn388(aE)
    o2[#o2 + 1] = aE
    return aE
end
local function fn394()
    local rM = os.clock()
    local rM_1
    local rN = rM - oM.collectAllChecked < 60 and oM.collectAllChecked > 0
    local rN_1
    if rN then
        return oM.ownsCollectAll
    end
    oM.collectAllChecked = rM
    if oh <= 0 then
        oM.ownsCollectAll = false
        return false
    end
    rM_1, rN_1 = pcall(function()
        return op:UserOwnsGamePassAsync(ob.UserId, oh)
    end)
    local rP = rM_1 and rN_1 == true
    oM.ownsCollectAll = rP
    return oM.ownsCollectAll
end
local function fn420()
    if not oT("AutoPlaceBlocks") then
        return
    end
    local sD = oM.resolvePlot()
    if not sD then
        return
    end
    local sE = os.clock()
    for k, v in oM.placed do
        if sE - v > 4 then
            oM.placed[k] = nil
        end
    end
    for k, v in oM.inventoryBlocks() do
        local sF = Library.Unloaded or not oT("AutoPlaceBlocks")
        if sF then
            return
        end
        if not oM.placed[v.uuid] then
            if not not oz(Options.PlaceBlockFilter, v.name) then
                local sF_1 = oM.nextEmptySlot(sD)
                if not sF_1 then
                    return
                end
                oM.placed[v.uuid] = sE
                oK:FireServer(sF_1, "Block", v.uuid)
                task.wait(o1)
            end
        end
    end
end
local function fn458()
    local r6 = oJ("EquippedPickaxe", "Wooden Pickaxe")
    if type(r6) ~= "string" then
        return 15
    end
    local r7 = Pickaxe2.GetPickaxeData(r6)
    local r6_1 = type(r7) == "table" and type(r7.Damage) == "number"
    if r6_1 then
        return r7.Damage
    end
    return 15
end
local function fn460(bY)
    if not bY or not bY.Parent then
        return nil
    end
    local BlockUI = bY:FindFirstChild("BlockUI", true)
    local qT = BlockUI and BlockUI:FindFirstChild("BlockName")
    local qU = BlockUI
    if qU then
        qU = BlockUI:FindFirstChild("Mutation")
    end
    local qS_2 = qT
    local qT_1 = qU
    if qS_2 then
        qS_2 = qT.Text
    end
    local qU_1 = qS_2
    local qS_3 = qU_1 == ""
    local qV_1 = type(qU_1) ~= "string" or qS_3
    if qV_1 then
        return nil
    end
    local qT_2 = qT_1 and qT_1.Text
    local qS_5 = qT_2 == ""
    local qV_2 = type(qT_2) ~= "string" or qS_5
    if qV_2 then
        qT_2 = "Normal"
    end
    return { uuid = bY.Name, name = qU_1, mutation = qT_2 }
end
local function fn521()
    if not oT("AutoBuySlots") then
        return
    end
    if os.clock() - oM.slotBuyAt < 1.5 then
        return
    end
    local to = oM.upgradeLevel() + 1
    local tp = Upgrade.GetUpgradeCost(to)
    if type(tp) ~= "number" then
        return
    end
    if not oM.canSpend(tp) then
        return
    end
    oM.slotBuyAt = os.clock()
    n9:FireServer(to)
end
local function fn631(fF)
    local ue = fF
    local uf = {}
    if ue then
        ue = fF:FindFirstChild("Slots")
    end
    local ug = ue
    if not ug then
        return uf
    end
    local ue_1 = oM.upgradeLevel()
    for i, child in ug:GetChildren() do
        local ug_1 = tonumber(child.Name)
        if ug_1 and ug_1 <= ue_1 then
            local uh_1 = od("Plot.Slots", ug_1)
            if uh_1 and uh_1.Occupied and uh_1.Type == "Block" and not uh_1.Pending then
                local uj_1 = type(uh_1.Name) == "string" and oz(Options.BreakBlockFilter, uh_1.Name)
                if uj_1 then
                    uf[#uf + 1] = { index = ug_1, health = oW(uh_1.Health) }
                end
            end
        end
    end
    table.sort(uf, function(fR, fS)
        return fR.index < fS.index
    end)
    return uf
end
local function fn633(dp, dq)
    local sc = ob.Character and ob.Character:FindFirstChild("HumanoidRootPart")
    local sd = dp
    if sd then
        sd = dp:FindFirstChild("Slots")
    end
    local sc_1 = sd
    if sd then
        sd = sc_1:FindFirstChild(tostring(dq))
    end
    local sc_2 = sd
    if not (sc and sc_2) then
        return false
    end
    sc.CFrame = sc_2:GetPivot() * CFrame.new(0, 4, 3)
    sc.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function fn656()
    if not oT("AutoUpgradePlaced") then
        return
    end
    if os.clock() - oM.upgradeAt < 0.2 then
        return
    end
    local tu = oM.resolvePlot()
    local tv = tu and tu:FindFirstChild("Slots")
    if not tv then
        return
    end
    local tv_1 = 25
    if Options.UpgradeMaxLevel then
        tv_1 = oW(Options.UpgradeMaxLevel.Value)
    end
    if tv_1 < 1 then
        tv_1 = 1
    end
    local tw = oM.upgradeLevel()
    local tx = os.clock()
    for k, v in oM.upgradeSent do
        if tx - v.at > 3 then
            oM.upgradeSent[k] = nil
        end
    end
    local ty = {}
    for i, child in tv:GetChildren() do
        local tu_2 = Library.Unloaded or not oT("AutoUpgradePlaced")
        if tu_2 then
            return
        end
        local tu_3 = tonumber(child.Name)
        if tu_3 and tu_3 <= tw then
            local tz_1 = od("Plot.Slots", tu_3)
            if tz_1 and tz_1.Occupied and tz_1.Type == "Car" and not tz_1.Pending then
                local tA_1 = oW(tz_1.Level)
                if tA_1 < 1 then
                    tA_1 = 1
                end
                if tA_1 < tv_1 then
                    local tB = Car2.GetCarData(tz_1.Name)
                    local tC = tB and tB.Rarity
                    local tC_1 = type(tC) == "string" and tC ~= "Exclusive" and oz(Options.UpgradeRarities, tC)
                    if tC_1 then
                        local tB_2 = oM.upgradeSent[tu_3]
                        if not (tB_2 and tB_2.level == tA_1 and tx - tB_2.at < 2) then
                            local CalculateUpgradeCost = Car2.CalculateUpgradeCost
                            local Name = tz_1.Name
                            local tD = tz_1.Mutation or "Normal"
                            local tE = CalculateUpgradeCost(Name, tA_1, tD)
                            local tz_2 = type(tE) == "number" and oM.canSpend(tE)
                            if tz_2 then
                                ty[#ty + 1] = { index = tu_3, level = tA_1, cost = tE }
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(ty, function(fd, fe)
        return fd.cost < fe.cost
    end)
    for k, v in ty do
        local tu_4 = Library.Unloaded or not oT("AutoUpgradePlaced")
        if tu_4 then
            return
        end
        if oM.canSpend(v.cost) then
            oM.upgradeAt = os.clock()
            oM.upgradeSent[v.index] = { level = v.level, at = oM.upgradeAt }
            oe:FireServer(v.index)
            task.wait(0.15)
        end
    end
end
local function fn675(b8)
    if not b8 then
        return nil
    end
    local Slots = b8:FindFirstChild("Slots")
    if not Slots then
        return nil
    end
    local q0 = oM.upgradeLevel()
    local q1
    for i, child in Slots:GetChildren() do
        local q__1 = tonumber(child.Name)
        if q__1 and q__1 <= q0 then
            local q2_1 = od("Plot.Slots", q__1)
            local q3 = not q2_1
            if not q3 then
                local q4 = not q2_1.Occupied
                if q4 ~= false then
                    q4 = not q2_1.Pending
                end
                q3 = q4
            end
            if q3 then
                local q2_2 = not q1
                local q8 = if q2_2 then 1 else 0
                local q6 = 3109 * q8 + 3929 * (1 - q8)
                local q7 = 548 * q8 + 222 * (1 - q8)
                if not ((q6 * 560 + q7 * 508 + q6 * q7) % 16777213 == 3723156) then
                    q2_2 = q__1 < q1
                end
                if q2_2 then
                    q1 = q__1
                end
            end
        end
    end
    return q1
end
local function fn679(aH, aI)
    if setclipboard then
        setclipboard(aH)
    elseif toclipboard then
        toclipboard(aH)
    end
    Library:Notify(aI)
end
local function fn720(aO)
    local DiscordGroup = aO:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ot })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ot })
end
local function fn764(a3)
    local p2 = tonumber(a3)
    if p2 then
        return p2
    elseif type(a3) == "string" then
        local p2_1 = tonumber((string.gsub(a3, "[,%s%$]", "")))
        if p2_1 then
            return p2_1
        end
        return 0
    else
        return 0
    end
end
local function fn775()
    if not oT("AutoCollect") then
        return
    end
    if oM.refreshCollectAll() then
        oC:FireServer()
        return
    end
    local sW = oM.resolvePlot()
    local sX = sW and sW:FindFirstChild("Slots")
    if not sX then
        return
    end
    for i, child in sX:GetChildren() do
        local sW_2 = Library.Unloaded or not oT("AutoCollect")
        if sW_2 then
            return
        end
        local sW_3 = tonumber(child.Name)
        if sW_3 then
            local sX_1 = od("Plot.Slots", sW_3)
            local sY = sX_1 and sX_1.Occupied and sX_1.Type == "Car" and not sX_1.Pending and oW(sX_1.Cash) > 0
            if sY then
                oG:FireServer(sW_3)
                task.wait(oU)
            end
        end
    end
end
local function fn776()
    oO(oB, "Copied Discord invite to clipboard")
end
local function fn815()
    local KeepCash = Options.KeepCash
    if not KeepCash then
        return 0
    end
    return math.max(oW(KeepCash.Value), 0)
end
local function fn864(bc, bd)
    local qg_1
    local qf_1
    qf_1, qg_1 = pcall(PlayerStateClient.GetFromDict, bc, bd)
    if qf_1 then
        return qg_1
    end
    return nil
end
local function fn901(M)
    local pL = cloneref and typeof(M) == "Instance"
    if pL then
        return cloneref(M)
    end
    return M
end
local function fn903(bO, bP)
    local qK = Block2.GetBlockData(bO)
    local qL = type(qK) ~= "table" or type(qK.Price) ~= "number"
    if qL then
        return nil
    elseif o0:GetAttribute("BlockSale") then
        return 1
    else
        local GetMutationData = Mutation.GetMutationData
        local qM = bP or "Normal"
        local qN = GetMutationData(qM)
        local qL_2 = 1
        local qM_1 = type(qN) == "table" and type(qN.IncomeMultiplier) == "number"
        if qM_1 then
            qL_2 = qN.IncomeMultiplier
        end
        return qK.Price * qL_2
    end
end
local function fn913()
    local qu_1
    local qt_1
    local qs = oJ("UpgradeLevel", nil)
    if qs == nil then
        qt_1, qu_1 = pcall(PlayerStateClient.GetPath, "UpgradeLevel")
        if qt_1 then
            qs = qu_1
        end
    end
    local qs_1 = oW(qs)
    if qs_1 <= 0 then
        return 9
    end
    return qs_1
end
local function fn924()
    local plot = oM.plot
    local qz_1
    local qA = plot and plot.Parent
    local qA_1
    if qA then
        return plot
    end
    qz_1, qA_1 = pcall(function()
        return ov:InvokeServer()
    end)
    local qB = qz_1 and typeof(qA_1) == "Instance"
    if qB then
        oM.plot = oq(qA_1)
        return oM.plot
    end
    local UserId = ob.UserId
    local PlotLocations = Workspace:FindFirstChild("PlotLocations")
    local Plots = Workspace:FindFirstChild("Plots")
    if PlotLocations and Plots then
        for i, child in PlotLocations:GetChildren() do
            if child:GetAttribute("OwnerId") == UserId then
                local qA_3 = Plots:FindFirstChild(child.Name)
                if qA_3 then
                    oM.plot = oq(qA_3)
                    return oM.plot
                end
            end
        end
    end
    return nil
end
local function fn929(bn)
    bn = oW(bn)
    local qn = bn ~= bn
    local qr = if qn then 1 else 0
    local qp = 3329 * qr + 3694 * (1 - qr)
    local qq = 2942 * qr + 3022 * (1 - qr)
    if not ((qp * 3222 + qq * 2921 + qp * qq) % 16777213 == 12336325) then
        qn = bn < 0
    end
    if qn then
        return false
    end
    return oM.cash() - oM.keepCash() >= bn
end
local function fn1044(aX, aY)
    local pU = aX and aX.Value
    if type(pU) ~= "table" then
        return false
    elseif pU[aY] == true then
        return true
    else
        for k, v in pairs(pU) do
            if v == aY then
                return true
            end
        end
        return false
    end
end
n8 = nil
n9 = nil
Options = nil
ob = nil
oc = nil
od = nil
oe = nil
Toggles = nil
Workspace = nil
oh = nil
oi = nil
Upgrade = nil
oo = nil
op = nil
oq = nil
ot = nil
ov = nil
Library = nil
oz = nil
Mutation = nil
oB = nil
oC = nil
Car2 = nil
oG = nil
oH = nil
Pickaxe2 = nil
oJ = nil
oK = nil
oM = nil
Block2 = nil
oO = nil
oP = nil
PlayerStateClient = nil
oT = nil
oU = nil
local oV
oW = nil
local n7, SaveManager, ol, on, ou, TeleportService, oy, oD, oF, oL, oQ, oS, oX
oY = nil
o_ = nil
o0 = nil
o1 = nil
o2 = nil
o3 = nil
local oZ
local pk_1
local o8_2
local o5_3
n7, o0, oX, oS, oQ, oL, oH, oD, TeleportService, op, ol, Workspace, ob, o3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local o4 = 1
repeat
    local o5_1 = (o4 * 5 + 2) % 6 + 1
    if o5_1 <= 3 then
        if o5_1 <= 2 then
            if o5_1 <= 1 then
                local o6_1 = { "xyu", "gzjelbwi", "snv", "yflaeq", "vye", "drhw", "csqgygjj", "jvflkdiqhs", "ixxjdln" }
                local yx = o4
                local o7_1 = o6_1[yx % 9 + 1]
                if o7_1:len() <= o7_1:gsub("(.)", "%1%1", yx % 3 % 2 + 1):len() then
                    o3 = fn214
                else
                    ol = fn214
                end
                o4 = (o4 + 5) % 24
            else
                local o6_2 = (vector.create((o4 * 3 + 7) % 11 + 1, (o4 * 1 + 13) % 13 + 1, (o4 * 11 + 10) % 17 + 1))
                local o7_2 = (vector.create((o4 * 5 + 3) % 11 + 1, (o4 * 8 + 5) % 13 + 1, (o4 * 2 + 3) % 17 + 1))
                local zo = vector.cross(o6_2, o7_2)
                local zp = vector.dot(o6_2, o7_2)
                if vector.dot(zo, zo) + zp * zp == vector.dot(o6_2, o6_2) * vector.dot(o7_2, o7_2) + 4 then
                    op = game:GetService("Players")
                else
                    n7 = game:GetService("Players")
                end
                o4 = (o4 + 11) % 24
            end
        else
            local o6_3 = {
                "zvwm",
                "cxjsdyf",
                "gunotbzb",
                "chol",
                "eplf",
                "kgcpowfzonn",
                "noxo",
                "gukmdv",
                "vheoh",
                "wzjshvb",
                "fkoxqpprqu"
            }
            if o6_3[(o4 * 73 + 97) % 11 + 1] <= o6_3[(o4 * 73 + 97) % 11 + 1] then
                o0 = game:GetService("ReplicatedStorage")
                oX = game:GetService("RunService")
                oS = game:GetService("UserInputService")
                oQ = game:GetService("VirtualUser")
                oL = game:GetService("HttpService")
            else
                oX = game:GetService("ReplicatedStorage")
                oQ = game:GetService("RunService")
                oL = game:GetService("UserInputService")
                oS = game:GetService("VirtualUser")
                o0 = game:GetService("HttpService")
            end
            o4 = (o4 + 11) % 24
        end
    elseif o5_1 <= 5 then
        if o5_1 <= 4 then
            if o4 * 32255863 + 4 + 7 <= o4 * 32255863 + 4 + 7 + 2 then
                oH = game:GetService("CoreGui")
                oD = game:GetService("GuiService")
            else
                oD = game:GetService("CoreGui")
                oH = game:GetService("GuiService")
            end
            o4 = (o4 + 11) % 24
        else
            local o5_2 = { "knslvubcuulw", "secvzrxjvmmi", "mztwyejixsfm", "plxajc", "zfxrvbvc", "zzmbv", "iya", "husnkp" }
            if o5_2[(o4 * 37 + 106) % 8 + 1] <= o5_2[(o4 * 37 + 106) % 8 + 1] then
                TeleportService = game:GetService("TeleportService")
            else
                ob = game:GetService("TeleportService")
            end
            o4 = (o4 + 23) % 24
        end
    else
        if (o4 * 2 + 7) * 4 % 3 == ((o4 * 2 + 7) * 4 + 6) % 3 then
            op = game:GetService("MarketplaceService")
            ol = game:GetService("Lighting")
            Workspace = game:GetService("Workspace")
            ob = n7.LocalPlayer
        else
            ol = game:GetService("MarketplaceService")
            op = game:GetService("Lighting")
            ob = game:GetService("Workspace")
            n7 = Workspace.LocalPlayer
        end
        o4 = (o4 + 5) % 24
    end
until (o4 * 17 + 20) % 24 == 7
if getgenv then
    oV, o5_3 = nil, nil
    local o4_1 = 15
    repeat
        if (o4_1 * 1 + 1) % 2 + 1 <= 1 then
            local zj = bit32.rrotate(bit32.bxor(bit32.lrotate(o4_1, 30), string.byte(tostring(oV))), 31)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(zj, 1474140331), 1014752041), (bit32.bxor(bit32.band(zj, 2820826964), 3589582476))), 1014752041), 3589582476) ~= zj then
                getgenv().gethui = oV
                o3 = getgenv().__TempoBreakForAnimeLib
            else
                getgenv().gethui = o3
                oV = getgenv().__TempoBreakForAnimeLib
            end
            o4_1 = (o4_1 + 13) % 16
        else
            local o6_5 = (vector.create((o4_1 * 2 + 5) % 11 + 1, (o4_1 * 7 + 3) % 13 + 1, (o4_1 * 12 + 9) % 17 + 1))
            local o7_3 = (vector.create((o4_1 * 1 + 9) % 11 + 1, (o4_1 * 11 + 8) % 13 + 1, (o4_1 * 9 + 3) % 17 + 1))
            local o8_1 = (vector.create((o4_1 * 3 + 5) % 5 + 1, (o4_1 * 1 + 5) % 7 + 1, (o4_1 * 2 + 5) % 9 + 1))
            if math.abs((vector.angle(o6_5, o7_3, o8_1))) - math.abs((vector.angle(o7_3, o6_5, o8_1))) == 0 then
                o5_3 = oV
            else
                oV = o5_3
            end
            o4_1 = (o4_1 + 7) % 16
        end
    until (o4_1 * 1 + 15) % 16 == 2
    if o5_3 then
        o5_3 = oV.Unload
    end
    if o5_3 then
        pcall(function()
            oV:Unload()
        end)
    end
end
pcall(function()
    gethui = o3
end)
if setthreadidentity then
    setthreadidentity(8)
end
oF, oB, ou, on, oh, oc, n8, o1, oY, oU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
oF = "Break For Anime!"
oB = "https://discord.gg/K7Qxnxkk46"
ou = "https://discord.gg/K7Qxnxkk46"
on = "https://tempohub.shop"
oh = 1932204488
oc = 0.85
n8 = 0.12
o1 = 0.12
oY = 0.12
oU = 0.08
local o7_4 = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Cosmic",
    "Secret",
    "Celestial",
    "Godly",
    "Immortal",
    "Exclusive"
}
local o6_6 = {}
local o5_4 = {}
for k, v in o7_4 do
    if v ~= "Exclusive" then
        o6_6[#o6_6 + 1] = v
        o5_4[v] = true
    end
end
oP, oK, oG, oC, ov, oo, oi, oe, n9, PlayerStateClient, Block2, Pickaxe2, Car2, Mutation, Upgrade, oq = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
oq = fn901
local Remotes = o0:WaitForChild("Remotes")
local Plot = Remotes:WaitForChild("Plot")
local pf_1
local Block = Remotes:WaitForChild("Block")
local Pickaxe = Remotes:WaitForChild("Pickaxe")
local Car = Remotes:WaitForChild("Car")
local o9_1
oP = oq(Block:WaitForChild("BuyBlock"))
oK = oq(Plot:WaitForChild("PlaceItem"))
oG = oq(Plot:WaitForChild("CollectCash"))
oC = oq(Plot:WaitForChild("CollectAll"))
ov = oq(Plot:WaitForChild("GetPlot"))
oo = oq(Pickaxe:WaitForChild("PickaxeRemote"))
oi = oq(Car:WaitForChild("SellCar"))
oe = oq(Car:WaitForChild("UpgradeCar"))
n9 = oq(Remotes:WaitForChild("BuyUpgrade"))
local Shared = o0:WaitForChild("Shared")
local Configurations = Shared:WaitForChild("Configurations")
local Libraries = o0:WaitForChild("Libraries")
local pa_1
PlayerStateClient = require(Libraries:WaitForChild("PlayerState"):WaitForChild("PlayerStateClient"))
Block2 = require(Configurations:WaitForChild("Block"))
Pickaxe2 = require(Configurations:WaitForChild("Pickaxe"))
Car2 = require(Configurations:WaitForChild("Car"))
Mutation = require(Configurations:WaitForChild("Mutation"))
local Market = require(Configurations:WaitForChild("Market"))
local ph_1
Upgrade = require(Configurations:WaitForChild("Upgrade"))
if Market.Gamepasses and Market.Gamepasses.CollectAll then
    oh = Market.Gamepasses.CollectAll
end
o8_2, pa_1, o_, o9_1 = nil, nil, nil, nil
local o4_3 = 12
repeat
    if (o4_3 * 1 + 1) % 2 + 1 <= 1 then
        local pb_2 = {
            "kuvcrqqnfby",
            "sxu",
            "prea",
            "qkzcy",
            "ygvyvhjxil",
            "exfwoos",
            "wphcuib",
            "hgyz",
            "neixnazhbko",
            "exedumtd"
        }
        local yl = o4_3
        local pc_1 = pb_2[yl % 10 + 1]
        if pc_1:len() <= pc_1:reverse():rep(yl % 3 + 2):len() then
            pa_1 = {}
            o_ = {}
            o9_1 = {}
        else
            o9_1 = {}
            pa_1 = {}
            o_ = {}
        end
        o4_3 = (o4_3 + 5) % 16
    else
        if o4_3 * 114075953 + 2 + 4 >= o4_3 * 114075953 + 2 + 4 + 1 then
            o_ = {}
        else
            o8_2 = {}
        end
        o4_3 = (o4_3 + 5) % 16
    end
until (o4_3 * 3 + 8) % 16 == 10
for i, v in ipairs(Block2.Blocks) do
    local o4_4 = type(v) == "table" and type(v.Name) == "string"
    if o4_4 then
        o_[#o_ + 1] = v.Name
        o9_1[v.Name] = true
        if type(v.Price) == "number" then
            o8_2[#o8_2 + 1] = v.Name
            if #o8_2 <= 4 then
                pa_1[v.Name] = true
            end
        end
    end
end
Library, SaveManager = nil, nil
local pd_1 = { Common = true, Uncommon = true }
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoBreakForAnimeLib = Library
end
Toggles, Options, o2, oM, oy, oZ, oO, ot, oT, oz, oW, oJ, od = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
o2 = {}
oZ = fn388
oO = fn679
ot = fn776
oT = fn264
oz = fn1044
oW = fn764
oJ = fn47
od = fn864
oM = {
    plot = nil,
    bought = {},
    placed = {},
    sold = {},
    pickaxeBuyAt = 0,
    slotBuyAt = 0,
    upgradeAt = 0,
    upgradeSent = {},
    swingSent = nil,
    ownsCollectAll = false,
    collectAllChecked = 0
}
oM.cash = fn105
oM.keepCash = fn815
oM.canSpend = fn929
oM.upgradeLevel = fn913
oM.resolvePlot = fn924
oM.blockPrice = fn903
oM.readSpawned = fn460
oM.nextEmptySlot = fn675
oM.toolBlockName = fn366
oM.inventoryBlocks = function()
    local rA, rB
    rA = {}
    rB = {}
    local rC = oJ("Blocks", {})
    if type(rC) == "table" then
        for k, v in rC do
            if type(v) == "table" then
                local rC_1 = v.UUID
                if type(rC_1) ~= "string" then
                    local rD_1 = type(k) == "string" and k
                    rC_1 = rD_1 or nil
                end
                local Name = v.Name
                local rE_2 = type(rC_1) == "string" and type(Name) == "string"
                if rE_2 then
                    rA[rC_1] = true
                    rB[#rB + 1] = { uuid = rC_1, name = Name }
                end
            end
        end
    end
    local function rC_2(cB)
        if not cB then
            return
        end
        for i, child in cB:GetChildren() do
            local ro = child:IsA("Tool") and child:GetAttribute("ItemType") == "Block"
            if ro then
                local attr = child:GetAttribute("UUID")
                local rp = type(attr) == "string" and not rA[attr]
                if rp then
                    local rp_1 = oM.toolBlockName(child)
                    if type(rp_1) == "string" then
                        rA[attr] = true
                        rB[#rB + 1] = { uuid = attr, name = rp_1 }
                    end
                end
            end
        end
    end
    rC_2(ob:FindFirstChild("Backpack"))
    rC_2(ob.Character)
    return rB
end
oM.refreshCollectAll = fn394
oM.setAutoSwing = function(cY)
    if oM.swingSent == cY then
        return
    end
    oM.swingSent = cY
    pcall(function()
        oo:FireServer("AutoSwing", cY)
    end)
end
oM.ensurePickaxe = function()
    local rS, rT
    local rW_3
    local Character = ob.Character
    if Character then
        local Tool = Character:FindFirstChildWhichIsA("Tool")
        local rW_1 = Tool and Tool:GetAttribute("ItemType") == "Pickaxe"
        if rW_1 then
            return true
        end
        rT = oJ("EquippedPickaxe", "Wooden Pickaxe")
        if rW_3 then
            pcall(function()
                oo:FireServer("Equip", rT)
            end)
        end
        local rV_3 = Character and Character:FindFirstChildOfClass("Humanoid")
        rS = rV_3
        local Backpack = ob:FindFirstChild("Backpack")
        if rS and Backpack then
            for i, child in Backpack:GetChildren() do
                local r2 = child
                local rU_2 = r2:IsA("Tool") and r2:GetAttribute("ItemType") == "Pickaxe"
                if rU_2 then
                    pcall(function()
                        rS:EquipTool(r2)
                    end)
                    return true
                end
            end
        end
        return false
    end
    rT = oJ("EquippedPickaxe", "Wooden Pickaxe")
    local rV_5 = rT ~= ""
    rW_3 = type(rT) == "string" and rV_5
    if rW_3 then
        pcall(function()
            oo:FireServer("Equip", rT)
        end)
    end
    local rV_6 = Character and Character:FindFirstChildOfClass("Humanoid")
    rS = rV_6
    local Backpack = ob:FindFirstChild("Backpack")
    if rS and Backpack then
        for i, child in Backpack:GetChildren() do
            local r2 = child
            local rU_4 = r2:IsA("Tool") and r2:GetAttribute("ItemType") == "Pickaxe"
            if rU_4 then
                pcall(function()
                    rS:EquipTool(r2)
                end)
                return true
            end
        end
    end
    return false
end
oM.pickaxeDamage = fn458
oM.standAtSlot = fn633
oM.buyBlocks = fn289
oM.placeBlocks = fn420
oM.collectMoney = fn775
oM.buyPickaxes = fn35
oM.buySlots = fn521
oM.upgradePlaced = fn656
oM.sellCars = fn256
oM.blockSlots = fn631
oM.breakBlocks = fn110
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = oB, Copyable = true }, "|", oF },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
oy = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "box"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in oy do
    if k ~= "Info" then
        fn720(v)
    end
end
ph_1, pk_1, pf_1 = nil, nil, nil
local FarmGroup = oy.Main:AddLeftGroupbox("Farm", "pickaxe")
FarmGroup:AddToggle("AutoBuyBlocks", { Text = "Auto Buy Luck Blocks", Default = false })
FarmGroup:AddDropdown("BuyBlockFilter", { Text = "Luck Blocks", Values = o8_2, Multi = true, Default = pa_1, Expandable = true })
FarmGroup:AddInput("KeepCash", { Text = "Keep Cash", Default = "0", Numeric = true, Finished = false, Placeholder = "0" })
FarmGroup:AddDivider("Plot")
FarmGroup:AddToggle("AutoPlaceBlocks", { Text = "Auto Place Lucky Blocks", Default = false })
FarmGroup:AddDropdown("PlaceBlockFilter", { Text = "Place Blocks", Values = o_, Multi = true, Default = o9_1, Expandable = true })
FarmGroup:AddToggle("AutoBreak", { Text = "Auto Break", Default = false })
FarmGroup:AddDropdown("BreakBlockFilter", { Text = "Break Blocks", Values = o_, Multi = true, Default = o9_1, Expandable = true })
FarmGroup:AddDivider("Upgrade")
FarmGroup:AddToggle("AutoUpgradePlaced", { Text = "Auto Upgrade Placed", Default = false })
FarmGroup:AddDropdown("UpgradeRarities", { Text = "Rarities", Values = o6_6, Multi = true, Default = o5_4, Expandable = true })
FarmGroup:AddSlider("UpgradeMaxLevel", { Text = "Max Level", Default = 25, Min = 1, Max = 100, Rounding = 0 })
FarmGroup:AddDivider("Cash")
FarmGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false })
local ShopGroup = oy.Main:AddRightGroupbox("Shop", "shopping-bag")
ShopGroup:AddToggle("AutoBuyPickaxes", { Text = "Auto Buy Pickaxes", Default = false })
ShopGroup:AddToggle("AutoBuySlots", { Text = "Auto Buy Slots", Default = false })
ShopGroup:AddDivider("Sell")
ShopGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
ShopGroup:AddDropdown("SellRarities", { Text = "Rarities", Values = o7_4, Multi = true, Default = pd_1, Expandable = true })
ShopGroup:AddToggle("KeepMutations", { Text = "Keep Mutations", Default = true })
Toggles.AutoBreak:OnChanged(fn154)
local function pj()
    local vz
    local vF
    local vE
    local vA
    local vH
    local vD
    vz = nil
    vA = nil
    vD = nil
    vE = nil
    vF = nil
    vH = nil
    local Label3, vB, Label, vG, vI, Label2
    local vL = "#8b93a3"
    vE = "#e8a34d"
    vA = "#e05a5a"
    vH = "#7fd47f"
    vF = function(gn, go)
        return string.format('<font color="%s">%s</font>', go, gn)
    end
    vG = function(gq, gr, gs)
        return string.format("<b>%s</b> %s %s", gq, vF("-", "#5a6070"), vF(gr, gs))
    end
    local function vM()
        local uH = hookfunction ~= nil
        local uI = hookmetamethod ~= nil
        local uJ = getrawmetatable ~= nil
        local uK = setrawmetatable ~= nil
        local uL = getgc ~= nil
        local uM = getgenv ~= nil
        local uN = getreg ~= nil
        local uO = getconnections ~= nil
        local uP = firesignal ~= nil
        local uQ = getcallbackvalue ~= nil
        local uR = setclipboard ~= nil
        local uS = getcustomasset ~= nil
        local uT = getnamecallmethod ~= nil
        local uU = isexecutorclosure ~= nil
        local uV = fireproximityprompt ~= nil
        local uW = firetouchinterest ~= nil
        local uX = WebSocket ~= nil
        local uY = readfile ~= nil
        local uZ = writefile ~= nil
        local u_ = request
        local va = if u_ then 1 else 0
        local u8 = 658 * va + 910 * (1 - va)
        local u9 = 2986 * va + 1318 * (1 - va)
        if not ((u8 * 154 + u9 * 1973 + u8 * u9) % 16777213 == 7957498) then
            u_ = http_request
        end
        local u0 = u_ ~= nil
        local u2 = (debug and debug.getupvalues) ~= nil
        local u4 = (debug and debug.setupvalue) ~= nil
        local u5 = 0
        local u6 = { uH, uI, uJ, uK, uL, uM, uN, uO, uP, uQ, uR, uS, uT, uU, uV, uW, uX, uY, uZ, u0, u2, u4 }
        for i, v in ipairs(u6) do
            if v then
                u5 += 1
            end
        end
        local uH_1 = u5 / #u6
        if uH_1 >= 0.9 then
            return vF("Full Support", vH)
        elseif uH_1 >= 0.6 then
            return vF("Half Support", vE)
        else
            return vF("Low Support", vA)
        end
    end
    vz = "Unknown"
    pcall(function()
        local vi_1
        local vh_1
        if identifyexecutor then
            vi_1, vh_1 = identifyexecutor()
            local vj = vi_1 ~= ""
            local vk = type(vi_1) == "string" and vj
            if vk then
                local vj_1 = type(vh_1) == "string" and vh_1 ~= "" and vi_1 .. " " .. vh_1
                vz = vj_1 or vi_1
            end
        end
    end)
    local vN = vM()
    vD = os.clock()
    vI = function()
        local vm = math.floor(os.clock() - vD)
        if vm < 60 then
            return vm .. "s"
        elseif vm < 3600 then
            return string.format("%dm %ds", math.floor((vm) / (60)), vm % 60)
        else
            return string.format("%dh %dm", math.floor((vm) / (3600)), math.floor((vm % 3600) / (60)))
        end
    end
    local UserGroup = oy.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = ob, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(vG("User", ob.DisplayName .. " @" .. ob.Name, vH), true)
    UserGroup:AddLabel(vG("UserId", tostring(ob.UserId), "#6ec1ff"), true)
    UserGroup:AddLabel(vG("Executor", vz .. "  " .. vN, vH), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(vG("Session", vI(), vE), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            oO(ob.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            oO("https://www.roblox.com/users/" .. tostring(ob.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = oy.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(vG("Game", oF, "#6ec1ff"), true)
    Label2 = SessionGroup:AddLabel(vG("Players", "0/0", vH), true)
    vB = tostring(game.JobId)
    local vK = #vB > 18 and string.sub(vB, 1, 18) .. "..."
    local vN_1 = vK or vB
    SessionGroup:AddLabel(vG("Job", vN_1, vL), true)
    Label = SessionGroup:AddLabel(vG("Ping", "0 ms", vE), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            TeleportService:Teleport(game.PlaceId, ob)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            oO(vB, "Copied Job ID")
        end
    })
    task.spawn(function()
        local vv_1
        local vu_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(vG("Session", vI(), vE))
            Label2:SetText(vG("Players", #n7:GetPlayers() .. "/" .. tostring(n7.MaxPlayers), vH))
            vu_1, vv_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local vu_2 = vu_1 and vv_1 .. " ms" or "n/a"
            Label:SetText(vG("Ping", vu_2, vE))
        end
    end)
    local SocialsGroup = oy.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = ot })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            oO(ou, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            oO(on, "Copied website link")
        end
    })
end
if ((false or not pf_1) and (not pf_1 or pk_1) or (pj or not ShopGroup or (not ShopGroup or pj)) or (not pf_1 and pf_1 or not pf_1 and not ShopGroup or (pf_1 or pf_1) and (pj or ShopGroup))) and (false and (pj and pj) and (false and (pk_1 or false)) or (not pf_1 and not ShopGroup or (pj or false)) and ((pj or pk_1) and (false or not pf_1))) or not (((false or not pf_1) and (not pf_1 or pk_1) or (pj or not ShopGroup or (not ShopGroup or pj)) or (not pf_1 and pf_1 or not pf_1 and not ShopGroup or (pf_1 or pf_1) and (pj or ShopGroup))) and (false and (pj and pj) and (false and (pk_1 or false)) or (not pf_1 and not ShopGroup or (pj or false)) and ((pj or pk_1) and (false or not pf_1)))) then
    ph_1 = function()
        local connection
        local MovementGroup = oy.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = oy.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local function hB()
            local Character = ob.Character
            local vQ = Character and Character:FindFirstChildOfClass("Humanoid")
            return vQ
        end
        local function hG()
            local Character = ob.Character
            local vT = Character and Character:FindFirstChild("HumanoidRootPart")
            return vT
        end
        oZ(oX.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            if Toggles.NoClip and Toggles.NoClip.Value then
                local Character = ob.Character
                if Character then
                    for i, descendant in ipairs(Character:GetDescendants()) do
                        local vV_2 = descendant:IsA("BasePart") and descendant.CanCollide
                        if vV_2 then
                            descendant.CanCollide = false
                        end
                    end
                end
            end
        end))
        oZ(oS.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            if Toggles.InfJump and Toggles.InfJump.Value then
                local v2_1 = hB()
                if v2_1 then
                    v2_1:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end))
        local h2 = Workspace.CurrentCamera
        oZ(oX.RenderStepped:Connect(function(h3)
            if Library.Unloaded then
                return
            end
            if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
                local v7_1 = hB()
                if v7_1 then
                    v7_1.WalkSpeed = Options.WalkSpeed.Value
                end
            end
            if Toggles.Fly and Toggles.Fly.Value then
                local v7_3 = hG()
                local v8 = hB()
                if v7_3 and v8 then
                    v8.PlatformStand = true
                    local v8_1 = Vector3.zero
                    h2 = Workspace.CurrentCamera
                    if h2 then
                        if oS:IsKeyDown(Enum.KeyCode.W) then
                            v8_1 += h2.CFrame.LookVector
                        end
                        if oS:IsKeyDown(Enum.KeyCode.S) then
                            v8_1 -= h2.CFrame.LookVector
                        end
                        if oS:IsKeyDown(Enum.KeyCode.A) then
                            v8_1 -= h2.CFrame.RightVector
                        end
                        if oS:IsKeyDown(Enum.KeyCode.D) then
                            v8_1 += h2.CFrame.RightVector
                        end
                    end
                    if oS:IsKeyDown(Enum.KeyCode.Space) then
                        v8_1 += Vector3.new(0, 1, 0)
                    end
                    if oS:IsKeyDown(Enum.KeyCode.LeftControl) then
                        v8_1 -= Vector3.new(0, 1, 0)
                    end
                    v7_3.AssemblyLinearVelocity = Vector3.zero
                    if v8_1.Magnitude > 0 then
                        v7_3.CFrame = v7_3.CFrame + v8_1.Unit * Options.FlySpeed.Value * h3
                    end
                end
            end
        end))
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                local wh = hB()
                if wh then
                    wh.PlatformStand = false
                end
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                local wj = hB()
                if wj then
                    wj.WalkSpeed = 16
                end
            end
        end)
        local function ir(is)
            if not is:IsA("ProximityPrompt") then
                return
            end
            is.HoldDuration = 0
            is.MaxActivationDistance = 50
            is.RequiresLineOfSight = false
        end
        connection = nil
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for i, descendant in ipairs(Workspace:GetDescendants()) do
                    pcall(ir, descendant)
                end
                connection = Workspace.DescendantAdded:Connect(function(iA)
                    if Toggles.InstantProximityPrompt.Value then
                        pcall(ir, iA)
                    end
                end)
                oZ(connection)
            elseif connection then
                connection:Disconnect()
                connection = nil
            end
        end)
        Library:OnUnload(function()
            if connection then
                connection:Disconnect()
            end
        end)
    end
end
local function pk_2()
    local MenuGroup = oy.Settings:AddLeftGroupbox("Menu", "logs")
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local iL = 0
    local iM = tick()
    local function iN()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        oQ:CaptureController()
        oQ:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        iL += 1
        iM = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. iL)
        end)
    end
    local connection2 = ob.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(iN)
        end
    end)
    oZ(connection2)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local wE = Toggles.AntiAfk.Value and tick() - iM >= 60
            if wE then
                pcall(iN)
            end
        end
    end)
    local function i8(i9)
        pcall(function()
            oD:SetGameplayPausedNotificationEnabled(not i9)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = oH:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not i9
            end
        end)
        if not i9 then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(ob, "GameplayPaused", false)
            else
                ob.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        i8(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                i8(true)
            end
        end
    end)
    local jq = false
    local function jr()
        local PlaceId, JobId
        if jq then
            return
        end
        jq = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local wN = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, JobId, ob)
        end)
        if not wN then
            pcall(function()
                TeleportService:Teleport(PlaceId, ob)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = oH:WaitForChild("RobloxPromptGui", 30)
        local wS = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not wS then
            return
        end
        oZ(wS.ChildAdded:Connect(function(jK)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and jK.Name == "ErrorPrompt" then
                jr()
            end
        end))
    end)
    oZ(TeleportService.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            jq = false
            jr()
        end
    end))
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            oX:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    local j_ = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    local function j0(j1)
        if j_[j1.ClassName] then
            pcall(function()
                j1.Enabled = false
            end)
        end
    end
    local connection
    Toggles.FpsBoost:OnChanged(function()
        if Toggles.FpsBoost.Value then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                ol.GlobalShadows = false
            end)
            pcall(function()
                ol.FogEnd = 9000000000
            end)
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(j0, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(kg)
                if Toggles.FpsBoost.Value then
                    pcall(j0, kg)
                end
            end)
            oZ(connection)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                ol.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    local ScriptGroup = oy.Settings:AddLeftGroupbox("Script", "terminal")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    Library:OnUnload(function()
        oM.setAutoSwing(false)
        if connection2 then
            connection2:Disconnect()
        end
        i8(false)
        pcall(function()
            oX:Set3dRenderingEnabled(true)
        end)
        if connection then
            connection:Disconnect()
        end
        for k, v in o2 do
            local xb = v
            pcall(function()
                xb:Disconnect()
            end)
        end
        table.clear(o2)
        local Character = ob.Character
        local w4 = Character and Character:FindFirstChildOfClass("Humanoid")
        if w4 then
            w4.PlatformStand = false
            w4.WalkSpeed = 16
        end
        if getgenv then
            getgenv().__TempoBreakForAnimeLib = nil
        end
    end)
end
local function pf_2(kE)
    local function kF(kG, kH)
        local xd_1 = (kG == "Toggle" and Toggles or Options)[kH]
        local xc_2 = type(xd_1) == "table" and xd_1.Type == kG
        return xc_2 and xd_1 or nil
    end
    local function kP(kQ, kR)
        local Type = kR.Type
        if Type == "Toggle" then
            return { idx = kQ, type = "Toggle", value = kR.Value == true }
        elseif Type == "Slider" then
            return { idx = kQ, type = "Slider", value = tostring(kR.Value) }
        elseif Type == "Dropdown" then
            return { idx = kQ, type = "Dropdown", multi = kR.Multi == true, value = kR.Value }
        elseif Type == "Input" then
            local xh = kR.Value or ""
            return { idx = kQ, type = "Input", text = tostring(xh) }
        elseif Type == "ColorPicker" then
            return { idx = kQ, type = "ColorPicker", value = kR.Value:ToHex(), transparency = kR.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = kQ,
                type = "KeyPicker",
                mode = kR.Mode,
                key = kR.Value,
                modifiers = kR.Modifiers,
                toggled = kR.Toggled
            }
        else
            return nil
        end
    end
    local function kT()
        local xk = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local xl = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if xl then
                    local xl_1 = kP(k, v)
                    if xl_1 then
                        xk[#xk + 1] = xl_1
                    end
                end
            end
        end
        table.sort(xk, function(k2, k3)
            if k2.type ~= k3.type then
                return k2.type < k3.type
            end
            return k2.idx < k3.idx
        end)
        return { objects = xk }
    end
    local function k4(k5)
        local xB
        xB = nil
        local xC = type(k5) ~= "table" or type(k5.idx) ~= "string"
        local xG = if xC then 1 else 0
        local xE = 2240 * xG + 3029 * (1 - xG)
        local xF = 2725 * xG + 2816 * (1 - xG)
        if not ((xE * 177 + xF * 3632 + xE * xF) % 16777213 == 16397680) then
            xC = type(k5.type) ~= "string"
        end
        if not xC then
            xC = SaveManager.Ignore[k5.idx]
        end
        if xC then
            return false
        end
        xB = kF(k5.type, k5.idx)
        if not xB then
            return false
        end
        local xC_1 = pcall(function()
            if k5.type == "Input" then
                if type(k5.text) ~= "string" then
                    return
                end
                xB:SetValue(k5.text)
            elseif k5.type == "ColorPicker" then
                xB:SetValueRGB(Color3.fromHex(k5.value), k5.transparency)
            elseif k5.type == "KeyPicker" then
                xB:SetValue({ k5.key, k5.mode, k5.modifiers })
                if k5.mode == "Toggle" and k5.toggled ~= nil then
                    xB.Toggled = k5.toggled
                    xB:Update()
                end
            else
                xB:SetValue(k5.value)
            end
        end)
        return xC_1
    end
    kE:AddDivider()
    kE:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    kE:AddButton("Export Config to Clipboard", function()
        local xI_1
        local xH_1
        xH_1, xI_1 = pcall(oL.JSONEncode, oL, kT())
        if not xH_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local xH_2 = setclipboard
        local xQ = if xH_2 then 1 else 0
        local xO = 1251 * xQ + 2377 * (1 - xQ)
        local xP = 1087 * xQ + 3227 * (1 - xQ)
        if not ((xO * 1099 + xP * 202 + xO * xP) % 16777213 == 2954260) then
            xH_2 = toclipboard
        end
        local xJ = xH_2
        local xH_3 = type(xJ) ~= "function" or not pcall(xJ, xI_1)
        if xH_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    kE:AddButton("Import Config from Clipboard Text", function()
        local xT_1
        local xR = Options.SaveManager_ImportSource.Value or ""
        local xR_1
        local xS = tostring(xR):match("^%s*(.-)%s*$")
        if xS == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        xR_1, xT_1 = pcall(oL.JSONDecode, oL, xS)
        local xS_1 = not xR_1
        local xX = if xS_1 then 1 else 0
        local xV = 2194 * xX + 3609 * (1 - xX)
        local xW = 3688 * xX + 226 * (1 - xX)
        if not ((xV * 61 + xW * 142 + xV * xW) % 16777213 == 8749002) then
            xS_1 = type(xT_1) ~= "table"
        end
        if not xS_1 then
            xS_1 = type(xT_1.objects) ~= "table"
        end
        if xS_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local xR_2 = 0
        for i, v in ipairs(xT_1.objects) do
            if k4(v) then
                xR_2 += 1
            end
        end
        if xR_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local xT_2 = xR_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(xR_2, xT_2), 6)
    end)
end
pj()
ph_1()
pk_2()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(oy.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BreakForAnime")
local pg_1 = SaveManager:BuildConfigSection(oy.Settings)
pf_2(pg_1)
SaveManager:LoadAutoloadConfig()
if Toggles.HideUiOnStart and Toggles.HideUiOnStart.Value then
    Library:Toggle(false)
end
local function o4_7(lC, lD)
    task.spawn(function()
        while not Library.Unloaded do
            pcall(lD)
            task.wait(lC)
        end
    end)
end
o4_7(0.15, oM.buyBlocks)
o4_7(0.2, oM.placeBlocks)
o4_7(1.5, oM.collectMoney)
o4_7(1, oM.buyPickaxes)
o4_7(1, oM.buySlots)
o4_7(0.4, oM.upgradePlaced)
o4_7(0.45, oM.sellCars)
o4_7(0.25, oM.breakBlocks)
end)(...)
