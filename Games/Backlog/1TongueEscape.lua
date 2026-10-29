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
getgenv().TempoHoodSubtitle = "+1 TONGUE ESCAPE"
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
local uf
local tX
local uE
local t2
local ur
local u8
local uQ
local ue
local uW
local uk
local t1
local uJ
local uq
local u7
local t7
local uP
local uw
local ud
local uV
local uC
local u0
local t0
local CoreGui
local connection
local uO
local uv
local vc
local uB
local u_
local t_
local uH
local uo
local u5
local t5
local vb
local uT
local uA
local uh
local uZ
local tZ
local uG
local un
local u4
local uM
local va
local ua
local uS
local State
local ug
local LocalPlayer
local um
local u3
local t3
local uL
local us
local u9
local t9
local uR
local function fn2()
    local Map = u5:FindFirstChild("Map")
    local w9 = Map and Map:FindFirstChild("GiveWins")
    return w9 or nil
end
local function fn36(al, am)
    local v5 = if not t3() then 1 else 0
    if v5 == 1 then
        return
    end
    local Notifications = State.Notifications
    local v0 = tostring(al)
    local v1 = am or 5
    table.insert(Notifications, { text = v0, time = v1 })
    if #State.Notifications > 12 then
        table.remove(State.Notifications, 1)
    end
end
local function fn40()
    local y0 = uR()
    local y1 = y0 and y0:FindFirstChild("Equipped")
    local y0_1 = y1
    if y1 then
        y1 = y0_1:IsA("StringValue")
    end
    if y1 then
        return y0_1.Value
    end
    return nil
end
local function fn52()
    local Map = u5:FindFirstChild("Map")
    local zu = Map and Map:FindFirstChild("Lobby")
    local zt_1 = zu
    if zu then
        zu = zt_1:FindFirstChild("Trainers")
    end
    return zu or nil
end
local function fn53(gc)
    if gc then
        uL(t5, uh)
    else
        uH(t5)
        if not tZ.running then
            t2(nil)
        end
    end
    t5.running = gc == true
end
local function fn90()
    if State.MoveBusy then
        return
    end
    local B6 = t7()
    if #B6 == 0 then
        u0("Tongue upgrade pads are not loaded")
        return
    end
    local targets = uS.targets
    local B8 = next(targets) ~= nil
    local B9
    for i, v in ipairs(B6) do
        if not uV(v.Name) then
            B9 = v
            break
        end
    end
    if not B9 then
        u0("Every tongue upgrade is owned")
        return
    end
    if B8 then
        local B6_1 = false
        for k in pairs(targets) do
            if not uV(k) then
                B6_1 = true
                break
            end
        end
        if not B6_1 then
            return
        end
    end
    local B6_2 = tX("Wins")
    if B6_2 < B9.Cost then
        u0(string.format("Next tongue %s costs %d wins", B9.Name, B9.Cost))
        return
    end
    local Cn = if uv(B9) then 1 else 0
    if Cn == 1 then
        uf(string.format("Bought %s, +%d tongue", B9.Name, B9.Bonus))
        u0("Bought " .. B9.Name)
    end
end
local function fn99()
    local Bp_1
    local Bo_1
    local Bm = tX("Level")
    local Bn = va()
    if Bm < Bn then
        return
    end
    local Bn_1 = tX("Rebirths")
    Bo_1, Bp_1 = uM("RequestRebirth")
    if Bo_1 and Bp_1 ~= false then
        task.wait(0.5)
        if tX("Rebirths") > Bn_1 then
            uf("Rebirthed at level " .. Bm)
            u0("Rebirthed at level " .. Bm)
        end
    end
end
local function fn102()
    local z0_1
    local zY = us()
    local zZ = tX("Rebirths")
    local z_ = zY and ug(zY.levelForRebirth)
    local z__1
    if z_ then
        z__1, z0_1 = pcall(zY.levelForRebirth, zZ)
        local zY_1 = z__1 and tonumber(z0_1)
        if zY_1 then
            return tonumber(z0_1)
        end
        return (zZ + 1) * 10
    end
    return (zZ + 1) * 10
end
local function fn109(bF)
    local wT_1
    local wS_2
    local wR = os.clock() + 8
    while true do
        local wS_1 = State.MoveBusy and t3() and os.clock() < wR
        if wS_1 then
            task.wait(0.1)
            continue
        end
        break
    end
    local wR_1 = State.MoveBusy or not t3()
    if wR_1 then
        return false
    end
    State.MoveBusy = true
    local wR_2 = t9
    wS_2, wT_1 = pcall(bF)
    State.MoveBusy = false
    t2(wR_2)
    if not wS_2 then
        warn("[Tempo] movement error: " .. tostring(wT_1))
        return false
    end
    return wT_1
end
local function fn147()
    connection:Disconnect()
    t9 = nil
end
local function fn189(hj)
    local By = tonumber(hj) or 5
    vc.interval = math.max(By, 1)
end
local function fn316()
    local yp_1
    local yo_1
    yo_1, yp_1 = {}, {}
    for i, v in ipairs(um()) do
        local ys = v.Row == "TwoWin" and "Row 2" or "Row 1"
        local yr_1 = string.format("%s %s (+%d)", ys, v.Name, v.Amount)
        table.insert(yo_1, yr_1)
        yp_1[yr_1] = v.Key
    end
    return yo_1, yp_1
end
local function fn321(iV)
    uS.targets = uq(iV)
end
local function fn359(hA)
    if hA then
        uL(u7, uk)
    else
        uH(u7)
    end
end
local function fn372()
    local BL = tX("Wins")
    local targets = uZ.targets
    local BN = next(targets) ~= nil
    local BO
    for i, v in ipairs(t1()) do
        local BP = not t3() or uZ.stopped
        if BP then
            break
        else
            local BP_1 = not BN or targets[v.Name] or targets[v.ID]
            local BQ = BP_1
            if BP_1 then
                BP_1 = not uA(v.ID)
            end
            if BP_1 then
                BP_1 = v.Cost > 0
            end
            if BP_1 then
                BP_1 = BL >= v.Cost
            end
            if BP_1 then
                if ue("TrailAction", "BuyWins", v.ID) then
                    task.wait(0.6)
                    if uA(v.ID) then
                        uf("Bought " .. v.Name)
                        u0("Bought " .. v.Name)
                    end
                    BL = tX("Wins")
                end
            end
            local BP_2 = uA(v.ID)
            if BP_2 and (not BN or BQ) then
                if not BO or v.Boost > BO.Boost then
                    BO = v
                end
            end
        end
    end
    local BL_1 = uZ.equip and BO and ua() ~= BO.ID
    if BL_1 then
        if ue("TrailAction", "Equip", BO.ID) then
            u0("Equipped " .. BO.Name)
        end
    end
end
local function fn391(gl, gm)
    local AP = uq(gl)
    local AQ = {}
    for k in pairs(AP) do
        local AP_2 = gm and gm[k] or k
        AQ[AP_2] = true
    end
    t5.pads = AQ
end
local function fn411()
    return CoreGui
end
local function fn418(e_)
    local zP = e_ == ""
    local zQ = type(e_) ~= "string" or zP
    if zQ then
        return nil
    end
    local zP_1 = e_:match("^(.-)%s*%(x%d+%)$") or e_
    for i, v in ipairs(u_()) do
        if v.Name == zP_1 then
            return v
        end
    end
    return nil
end
local function fn422(V)
    local vU = typeof(cloneref) == "function" and typeof(V) == "Instance"
    if vU then
        return cloneref(V)
    end
    return V
end
local function fn469(gu)
    local AY = tonumber(gu) or 160
    t5.radius = math.max(AY, 0)
end
local function fn495()
    return LocalPlayer:FindFirstChild("Trails")
end
local function fn498()
    local y6 = uO()
    local y7 = {}
    if not y6 then
        return y7
    end
    for i, child in ipairs(y6:GetChildren()) do
        local y6_1 = tonumber(child:GetAttribute("WinCost"))
        if y6_1 then
            local Touch = child:FindFirstChild("Touch")
            local y9 = Touch and Touch:IsA("BasePart")
            if y9 then
                ud[child.Name] = Touch.Position
            end
            local insert = table.insert
            local Name = child.Name
            local za = tonumber(child:GetAttribute("TongueBonus")) or 0
            insert(y7, { Name = Name, Cost = y6_1, Bonus = za, Model = child, Position = ud[child.Name] })
        end
    end
    table.sort(y7, function(eo, ep)
        return eo.Cost < ep.Cost
    end)
    return y7
end
local function fn517(h_)
    if h_ then
        uL(uZ, t_)
    else
        uH(uZ)
    end
end
local function fn529(ew)
    local Upgrades = LocalPlayer:FindFirstChild("Upgrades")
    local zr = Upgrades ~= nil and Upgrades:FindFirstChild(ew) ~= nil
    return zr
end
local function fn540(gj)
    local AN = tonumber(gj) or 1
    t5.interval = math.max(AN, 0.1)
end
local function fn565()
    local xf = u4()
    if not xf then
        return 0
    end
    local xg = 0
    for i, v in ipairs(uQ) do
        local xh = xf:FindFirstChild(v)
        if xh then
            for i, child in ipairs(xh:GetChildren()) do
                local Touch = child:FindFirstChild("Touch")
                local xi = Touch and Touch:IsA("BasePart")
                if xi then
                    local xi_1 = v .. "/" .. child.Name
                    local xj = State.WinPads[xi_1]
                    if not xj or xj.Seeded then
                        xg += 1
                    end
                    local WinPads = State.WinPads
                    local Name = child.Name
                    local xl = tonumber(child:GetAttribute("WinAmount")) or 0
                    WinPads[xi_1] = { Key = xi_1, Row = v, Name = Name, Amount = xl, Position = Touch.Position }
                end
            end
        end
    end
    return xg
end
local function fn570(bb)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local wB = leaderstats and leaderstats:FindFirstChild(bb)
    local wA_1 = wB
    if wB then
        wB = tonumber(wA_1.Value)
    end
    return wB or 0
end
local function fn575(gO)
    if gO then
        uL(tZ, uG)
    else
        uH(tZ)
        if not t5.running then
            t2(nil)
        end
    end
    tZ.running = gO == true
end
local function onHeartbeat()
    local wO = not t9
    local wP = not t3() or wO
    if wP then
        return
    end
    local wO_1 = ur()
    if not wO_1 then
        return
    end
    wO_1.CFrame = t9
    wO_1.AssemblyLinearVelocity = Vector3.zero
end
local function fn664(he)
    if he then
        uL(vc, t0)
    else
        uH(vc)
    end
end
local function fn676()
    local zw = un()
    local zx = {}
    if not zw then
        return zx
    end
    for i, child in ipairs(zw:GetChildren()) do
        local zw_1 = tonumber(child:GetAttribute("TrainMultiplier"))
        local zy = zw_1 and child:IsA("Model")
        if zy then
            local Hitbox = child:FindFirstChild("Hitbox")
            local zz = Hitbox and Hitbox:IsA("BasePart")
            if zz then
                u9[child.Name] = Hitbox.Position + Vector3.new(0, Hitbox.Size.Y / 2, 0)
            end
            table.insert(zx, { Name = child.Name, Multiplier = zw_1, Model = child, Position = u9[child.Name] })
        end
    end
    table.sort(zx, function(eS, eT)
        return eS.Multiplier < eT.Multiplier
    end)
    return zx
end
local function fn677()
    local zi = {}
    for i, v in ipairs(t7()) do
        table.insert(zi, v.Name)
    end
    return zi
end
local function fn687()
    local zH = {}
    for i, v in ipairs(u_()) do
        table.insert(zH, string.format("%s (x%d)", v.Name, v.Multiplier))
    end
    return zH
end
local function fn725(gX)
    local Bb = type(gX) == "string" and gX
    local Bc = Bb
    local Bj = if Bc then 1 else 0
    local Bh = 2377 * Bj + 1768 * (1 - Bj)
    local Bi = 1113 * Bj + 1855 * (1 - Bj)
    if not ((Bh * 3851 + Bi * 3019 + Bh * Bi) % 16777213 == 15159575) then
        Bc = nil
    end
    tZ.label = Bc
end
local function fn727()
    local Map = u5:FindFirstChild("Map")
    local xA = Map and Map:FindFirstChild("Stages")
    if not xA then
        return
    end
    local xF = 1
    local xD = uW
    while xF <= xD do
        local xG = xF
        local xA_1 = xA:FindFirstChild("Stage" .. xG)
        if xA_1 and not State.StageAnchors[xG] then
            for i, descendant in ipairs(xA_1:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    State.StageAnchors[xG] = descendant.Position
                    break
                end
            end
        end
        xF += 1
    end
end
local function fn734()
    return not uC.Unloaded
end
local function fn778(gV)
    local A9 = tonumber(gV) or 0.25
    tZ.interval = math.max(A9, 0.05)
end
local function fn786(ch, ci)
    local xb = u4()
    local xc = xb and xb:FindFirstChild(ch)
    local xb_1 = xc
    if xc then
        xc = xb_1:FindFirstChild(ci)
    end
    local xb_2 = xc
    if xc then
        xc = xb_2:FindFirstChild("Touch")
    end
    local xb_3 = xc
    if xc then
        xc = xb_3:IsA("BasePart")
    end
    return xc and xb_3 or nil
end
local function fn794()
    gethui = u8
end
local function fn804()
    local xX = 0
    for k in pairs(State.WinPads) do
        xX += 1
    end
    return xX
end
local function fn808()
    local Character = LocalPlayer.Character
    local wE = Character and Character:FindFirstChild("HumanoidRootPart")
    return wE or nil
end
local function fn812(au)
    local v8_1
    local v6 = uE[au]
    if v6 ~= nil then
        if v6 == false then
            return nil
        end
        return v6
    end
    local Modules = vb:FindFirstChild("Modules")
    local v7 = Modules and Modules:FindFirstChild(au)
    local v7_2
    local v7_1 = not v7 or not v7:IsA("ModuleScript")
    if v7_1 then
        uE[au] = false
        return nil
    end
    v7_2, v8_1 = pcall(require, v7)
    local v6_3 = not v7_2 or type(v8_1) ~= "table"
    if v6_3 then
        uE[au] = false
        return nil
    end
    uE[au] = v8_1
    return v8_1
end
local function fn834(fz)
    fz.stopped = true
    local Ab = fz.generation or 0
    fz.generation = Ab + 1
end
local function fn841(h7)
    uZ.equip = h7 == true
end
local function fn845(bW, bX)
    local wW = os.clock()
    local wX = bX
    local w1 = if wX then 1 else 0
    local w_ = 3594 * w1 + 3726 * (1 - w1)
    local w0 = 111 * w1 + 878 * (1 - w1)
    if not ((w_ * 2174 + w0 * 3468 + w_ * w0) % 16777213 == 8597238) then
        wX = 6
    end
    local wY = wW + wX
    while true do
        local wW_1 = t3() and os.clock() < wY
        if not wW_1 then
            local wW_2 = bW()
            local wX_1 = wW_2 and wW_2:IsA("BasePart")
            return wX_1 and wW_2 or nil
        end
        wW = bW()
        local wX_2 = wW and wW:IsA("BasePart")
        if wX_2 then
            break
        end
        task.wait(0.15)
    end
    return wW
end
local function fn869(b5)
    local w2 = not b5
    local w7 = if w2 then 1 else 0
    local w5 = 1188 * w7 + 3543 * (1 - w7)
    local w6 = 1863 * w7 + 3478 * (1 - w7)
    if not ((w5 * 3107 + w6 * 975 + w5 * w6) % 16777213 == 7720785) then
        w2 = not b5:IsA("BasePart")
    end
    if w2 then
        return false
    end
    local w2_1 = ur()
    local w3 = not w2_1 or not ug(firetouchinterest)
    if w3 then
        return false
    end
    local w3_1 = pcall(firetouchinterest, w2_1, b5, 0)
    pcall(firetouchinterest, w2_1, b5, 1)
    return w3_1
end
local function fn888()
    local xP = {}
    for k, v in pairs(State.WinPads) do
        table.insert(xP, v)
    end
    table.sort(xP, function(cV, cW)
        if cV.Amount ~= cW.Amount then
            return cV.Amount > cW.Amount
        end
        return cV.Key < cW.Key
    end)
    return xP
end
local function fn900()
    local BE_1
    local BD_1
    BD_1, BE_1 = uJ()
    if not BD_1 then
        u0(string.format("Daily reward in %dh %dm", math.floor((BE_1) / (3600)), math.floor((BE_1 % 3600) / (60))))
        return
    end
    local BD_2 = tonumber(LocalPlayer:GetAttribute("DailyLastClaim")) or 0
    if not ue("DailyClaim") then
        return
    end
    task.wait(1)
    local BD_3 = (tonumber(LocalPlayer:GetAttribute("DailyLastClaim")))
    local BJ = if BD_3 then 1 else 0
    local BH = 2452 * BJ + 221 * (1 - BJ)
    local BI = 2710 * BJ + 1918 * (1 - BJ)
    if not ((BH * 499 + BI * 2598 + BH * BI) % 16777213 == 14909048) then
        BD_3 = 0
    end
    if BD_3 > BD_2 then
        local BD_4 = tonumber(LocalPlayer:GetAttribute("DailyStreak")) or 0
        uf("Claimed the daily reward, streak " .. BD_4)
        u0("Claimed the daily reward, streak " .. BD_4)
    end
end
local function fn909()
    local yA = uw("TrailConfigurations")
    local yB = not yA
    local yC = {}
    local yJ = if yB then 1 else 0
    local yH = 2124 * yJ + 41 * (1 - yJ)
    local yI = 1736 * yJ + 3023 * (1 - yJ)
    if not ((yH * 22 + yI * 2645 + yH * yI) % 16777213 == 8325712) then
        yB = type(yA.Trails) ~= "table"
    end
    if yB then
        return yC
    end
    for i, v in ipairs(yA.Trails) do
        local yA_1 = type(v) == "table" and type(v.ID) == "string"
        if yA_1 then
            local insert = table.insert
            local ID = v.ID
            local yD = type(v.Name) == "string" and v.Name
            local yE = yD or v.ID
            local yD_1 = tonumber(v.WinCost) or 0
            local yF = tonumber(v.TongueBoost) or 0
            insert(yC, { ID = ID, Name = yE, Cost = yD_1, Boost = yF })
        end
    end
    table.sort(yC, function(dO, dP)
        return dO.Cost < dP.Cost
    end)
    return yC
end
local function fn957()
    if tZ.stand and not State.MoveBusy and not t5.running then
        local A__1 = uo(tZ.label)
        local A1 = A__1 and A__1.Position or nil
        if A__1 and not A1 then
            local A__2 = ur()
            if A__2 then
                uP(A__2.Position)
            end
        end
        if A1 then
            u3(A1, 3)
        end
    end
    ue("AddTongue")
    u0(string.format("Training | Tongue %d | Level %d", tX("Tongue"), tX("Level")))
end
local function fn962(aq)
    State.Status = tostring(aq)
end
local function fn969()
    local yQ = {}
    for i, v in ipairs(t1()) do
        table.insert(yQ, v.Name)
    end
    return yQ
end
local function fn985()
    local BA = tonumber(LocalPlayer:GetAttribute("DailyLastClaim")) or 0
    if BA <= 0 then
        return true, 0
    end
    local BA_1 = BA + 86400 - os.time()
    return BA_1 <= 0, math.max(BA_1, 0)
end
local function fn986()
    local pads = t5.pads
    local An = next(pads)
    local Ao = {}
    local Ap = An ~= nil
    for i, v in ipairs(um()) do
        if not Ap or pads[v.Key] then
            table.insert(Ao, v)
        end
    end
    return Ao
end
local function fn1016(dY)
    local yY = uR()
    local yZ = yY ~= nil and yY:FindFirstChild(dY) ~= nil
    return yZ
end
local function fn1102(h4)
    uZ.targets = uq(h4)
end
local function fn1110(gw)
    t5.scan = gw == true
end
local function fn1114(iQ)
    if iQ then
        uL(uS, uT)
    else
        uH(uS)
    end
end
local function fn1125(fB)
    local Ad = {}
    if type(fB) == "table" then
        for k, v in pairs(fB) do
            local Ae = v == true and type(k) == "string"
            if Ae then
                Ad[k] = true
            elseif type(v) == "string" then
                Ad[v] = true
            end
        end
    end
    return Ad
end
local function fn1130(aP, aQ)
    local Events = vb:FindFirstChild("Events")
    local wo = Events and Events:FindFirstChild(aP)
    local wn_1 = wo
    if wo then
        wo = wn_1:IsA(aQ)
    end
    if wo then
        return wn_1
    end
    return nil
end
local function fn1131()
    local wi_1
    if uB ~= nil then
        return uB or nil
    end
    local TongueShared = vb:FindFirstChild("TongueShared")
    local wh = not TongueShared or not TongueShared:IsA("ModuleScript")
    local wh_1
    if wh then
        uB = false
        return nil
    end
    wh_1, wi_1 = pcall(require, TongueShared)
    local wg_3 = not wh_1 or type(wi_1) ~= "table"
    if wg_3 then
        uB = false
        return nil
    end
    uB = wi_1
    return wi_1
end
local function fn1132()
    local Map = u5:FindFirstChild("Map")
    local y4 = Map and Map:FindFirstChild("Lobby")
    local y3_1 = y4
    if y4 then
        y4 = y3_1:FindFirstChild("UpgradeWins")
    end
    return y4 or nil
end
local function fn1151(gZ)
    tZ.stand = gZ == true
    if not tZ.stand and not t5.running then
        t2(nil)
    end
end
local function fn1174(Y)
    return type(Y) == "function"
end
local function fn1196(bn)
    t9 = bn
end
tX = nil
LocalPlayer = nil
tZ = nil
t_ = nil
t0 = nil
t1 = nil
t2 = nil
t3 = nil
t5 = nil
t7 = nil
t9 = nil
ua = nil
ud = nil
ue = nil
uf = nil
ug = nil
uh = nil
uk = nil
um = nil
un = nil
uo = nil
CoreGui = nil
uq = nil
ur = nil
us = nil
uv = nil
uw = nil
State = nil
uA = nil
uB = nil
uC = nil
uE = nil
uG = nil
uH = nil
local Players, t4, Workspace, t8, ub, Lighting, ui, uj, ul, ut, uu, GuiService, uy, uD, HttpService, uI
uJ = nil
uL = nil
uM = nil
uO = nil
uP = nil
uQ = nil
uR = nil
uS = nil
uT = nil
uV = nil
uW = nil
uZ = nil
u_ = nil
u0 = nil
u3 = nil
u4 = nil
u5 = nil
connection = nil
u7 = nil
u8 = nil
u9 = nil
va = nil
vb = nil
vc = nil
local uK, VirtualUser, UserInputService, uX, uY, RunService, u2, vd
local vh_1
local vq = if not game:IsLoaded() then 1 else 0
if vq == 1 then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, ui, Lighting, Workspace, LocalPlayer, vh_1, u8 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
game:GetService("CollectionService")
ui = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
if (CoreGui and CoreGui and (CoreGui and CoreGui) or (not ReplicatedStorage or not CoreGui) and (not CoreGui and ReplicatedStorage)) and not (CoreGui and CoreGui and (CoreGui and CoreGui) or (not ReplicatedStorage or not CoreGui) and (not CoreGui and ReplicatedStorage)) then
    ui = "TempoTongueEscape"
else
    vh_1 = "TempoTongueEscape"
end
u8 = fn411
if getgenv then
    getgenv().gethui = u8
end
uC, vb, u5, uW, uQ, State, t8, ug, t3 = nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn794)
local function vf(u)
    local vJ
    local vK
    local vI
    vI = nil
    vJ = nil
    vK = nil
    local vL = u ~= ""
    local vM = type(u) == "string" and vL
    assert(vM, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    vJ = getgenv()
    assert(type(vJ) == "table", "getgenv did not return a table")
    local vL_1 = vJ[u]
    if vL_1 ~= nil then
        local vM_1 = type(vL_1) == "table" and type(vL_1.Unload) == "function"
        assert(vM_1, "Namespace is occupied")
        vL_1.Unload()
        assert(vJ[u] == nil, "Previous instance did not release its namespace")
    end
    vK = {}
    vI = { State = {}, Unloaded = false }
    vI.Track = function(A)
        assert(type(A) == "function", "Cleanup must be callable")
        if vI.Unloaded then
            A()
        else
            table.insert(vK, A)
        end
        return A
    end
    vI.Unload = function()
        local vB_1
        local vA_1
        if vI.Unloaded then
            return
        end
        vI.Unloaded = true
        local vy = {}
        local vF = #vK
        local vE = -1
        while false and vF <= 1 or true and vF >= 1 do
            local vG = vF
            local vz_1 = table.remove(vK, vG)
            vA_1, vB_1 = pcall(vz_1)
            if not vA_1 then
                table.insert(vy, tostring(vB_1))
            end
            vF += vE
        end
        table.clear(vI.State)
        if #vy > 0 then
            error("Cleanup incomplete: " .. table.concat(vy, "; "), 0)
        end
        if vJ[u] == vI then
            vJ[u] = nil
        end
    end
    vJ[u] = vI
    return vI
end
t8 = function(N, O)
    local vS = type(N) == "table" and type(N.Track) == "function"
    assert(vS, "FeatureAPI required")
    local vS_1 = type(O) == "table" and type(O.OnUnload) == "function"
    assert(vS_1, "UI library required")
    assert(type(O.Unload) == "function", "UI unload required")
    N.Track(function()
        if not O.Unloaded then
            O:Unload()
        end
    end)
    O:OnUnload(function()
        N.Unload()
    end)
end
uC = vf(vh_1)
ug = fn1174
t3 = fn734
vb = fn422(ReplicatedStorage)
u5 = fn422(Workspace)
uW = 12
uQ = { "OneWin", "TwoWin" }
local vj = {
    { "OneWin", "Button1", 1, Vector3.new(2894, 845, -564) },
    { "OneWin", "Button2", 3, Vector3.new(2506, 845, -564) },
    { "OneWin", "Button3", 5, Vector3.new(2076, 845, -564) },
    { "OneWin", "Button4", 10, Vector3.new(1604, 1116, -564) },
    { "OneWin", "Button5", 20, Vector3.new(1084, 1036, -564) },
    { "OneWin", "Button12", 1000, Vector3.new(-5364, 516, -564) },
    { "OneWin", "Button13", 2000, Vector3.new(-7058, 502, -562) },
    { "OneWin", "Button14", 4000, Vector3.new(-9432, 502, -562) },
    { "OneWin", "Button15", 8000, Vector3.new(-13196, 502, -562) },
    { "TwoWin", "Button13", 2000, Vector3.new(-7078, 502, -562) },
    { "TwoWin", "Button14", 4000, Vector3.new(-9452, 502, -562) },
    { "TwoWin", "Button15", 8000, Vector3.new(-13216, 502, -562) }
}
State = uC.State
if State and not uC and (State and not t3) or not t3 and State and (t3 or uC) or not (State and not uC and (State and not t3) or not t3 and State and (t3 or uC)) then
    State.Notifications = {}
    State.Status = "Idle"
    State.WinPads = {}
    State.StageAnchors = {}
    State.MoveBusy = false
    State.Scanning = false
    State.Scanned = false
else
    State.Notifications = {}
    State.Status = "Idle"
    State.WinPads = {}
    State.StageAnchors = {}
    State.MoveBusy = false
    State.Scanning = false
    State.Scanned = false
end
for i, v in ipairs(vj) do
    local ve_1 = v[1] .. "/" .. v[2]
    State.WinPads[ve_1] = { Key = ve_1, Row = v[1], Name = v[2], Amount = v[3], Position = v[4], Seeded = true }
end
uE, uB, t9, connection, ud, u9, t5, tZ, vc, u7, uZ, uS, uf, u0, uw, us, u2, ue, uM, tX, ur, t2, u3, uK, uP, uj, uu, u4, uy, uD, ul, um, uY, ut, uI, t1, t4, uR, uA, ua, uO, t7, ub, uV, un, u_, uX, uo, va, uL, uH, uq, vd, uh, uG, t0, uJ, uk, t_, uv, uT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
uf = fn36
u0 = fn962
uE = {}
uw = fn812
us = fn1131
u2 = fn1130
ue = function(aX, ...)
    local wt
    local wu
    wt = nil
    wu = nil
    wt = u2(aX, "RemoteEvent")
    if not wt then
        return false
    end
    wu = table.pack(...)
    return (pcall(function()
        wt:FireServer(table.unpack(wu, 1, wu.n))
    end))
end
uM = function(a3, ...)
    local wx
    local ww
    ww = nil
    wx = nil
    ww = u2(a3, "RemoteFunction")
    if not ww then
        return false, "remote unavailable"
    end
    wx = table.pack(...)
    local wy = table.pack(pcall(function()
        return ww:InvokeServer(table.unpack(wx, 1, wx.n))
    end))
    if not wy[1] then
        return false, "remote rejected"
    end
    return true, table.unpack(wy, 2, wy.n)
end
tX = fn570
ur = fn808
t9 = nil
t2 = fn1196
u3 = function(bq, br)
    local wG
    if typeof(bq) ~= "Vector3" then
        return false
    end
    local wJ = br or 5
    t9 = CFrame.new(bq + Vector3.new(0, wJ, 0))
    wG = ur()
    if not wG then
        return false
    end
    return (pcall(function()
        wG.CFrame = t9
        wG.AssemblyLinearVelocity = Vector3.zero
    end))
end
connection = RunService.Heartbeat:Connect(onHeartbeat)
uC.Track(fn147)
uK = fn109
uP = function(bR)
    if typeof(bR) ~= "Vector3" then
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(bR)
    end)
end
uj = fn845
uu = fn869
u4 = fn2
uy = fn786
uD = fn565
ul = fn727
um = fn888
uY = fn804
ut = function()
    local yj
    local yl = State.Scanning or not t3()
    if yl then
        return false
    end
    State.Scanning = true
    local yl_1 = ur()
    local yl_2 = yl_1 and yl_1.CFrame or nil
    yj = 0
    local yk = yl_2
    uK(function()
        ul()
        uD()
        local x2 = State.StageAnchors[1]
        local x9 = 1
        local x7 = uW
        while x9 <= x7 do
            local ya = x9
            local ye = if not t3() then 1 else 0
            if ye == 1 then
                break
            end
            local x3 = State.StageAnchors[ya]
            local x4 = not x3
            if x4 ~= false then
                x4 = x2
            end
            if x4 then
                u0("Streaming stage " .. ya)
                uP(x2)
                u3(x2, 12)
                local x4_1 = os.clock() + 5
                while true do
                    local x5 = t3() and os.clock() < x4_1
                    if x5 then
                        x5 = not State.StageAnchors[ya]
                    end
                    if x5 then
                        task.wait(0.25)
                        ul()
                        continue
                    end
                    break
                end
                x3 = State.StageAnchors[ya]
            end
            if not x3 then
                break
            end
            uP(x3)
            u3(x3, 12)
            task.wait(0.8)
            ul()
            yj += uD()
            x2 = x3
            x9 += 1
        end
    end)
    t2(nil)
    if yk then
        local yi = ur()
        if yi then
            pcall(function()
                yi.CFrame = yk
            end)
        end
    end
    State.Scanning = false
    State.Scanned = true
    uf(string.format("Win pad scan finished: %d pads, %d new", uY(), yj))
    u0(string.format("Known win pads: %d", uY()))
    return true
end
uI = fn316
t1 = fn909
t4 = fn969
uR = fn495
uA = fn1016
ua = fn40
uO = fn1132
ud = {}
t7 = fn498
ub = fn677
uV = fn529
un = fn52
u9 = {}
u_ = fn676
uX = fn687
uo = fn418
va = fn102
t5 = { interval = 1, pads = {}, radius = 160, scan = true }
tZ = { interval = 0.25, label = nil, stand = true }
if (u2 and not connection and (u2 or not connection) or (u2 or connection or (u2 or u2))) and ((connection or not connection) and (u2 and connection) and (not connection or u2 or not connection and connection)) or not ((u2 and not connection and (u2 or not connection) or (u2 or connection or (u2 or u2))) and ((connection or not connection) and (u2 and connection) and (not connection or u2 or not connection and connection))) then
    vc = { interval = 5 }
else
    uG = { interval = 5 }
end
u7 = { interval = 60 }
uZ = { interval = 10, targets = {}, equip = true }
uS = { interval = 5, targets = {} }
uL = function(fl, fm)
    local generation
    local z9 = fl.generation or 0
    fl.generation = z9 + 1
    fl.stopped = false
    generation = fl.generation
    task.spawn(function()
        local z6_1
        while true do
            local z5 = t3() and not fl.stopped and fl.generation == generation
            local z5_1
            if z5 then
                z5_1, z6_1 = pcall(fm)
                if not z5_1 then
                    warn("[Tempo] loop error: " .. tostring(z6_1))
                end
                local z5_2 = not t3() or fl.stopped or fl.generation ~= generation
                if z5_2 then
                    break
                end
                task.wait(fl.interval)
                continue
            end
            break
        end
    end)
end
uH = fn834
uq = fn1125
vd = fn986
uh = function()
    if State.MoveBusy then
        return
    end
    uD()
    local Ay = vd()
    if #Ay == 0 then
        if t5.scan and not State.Scanning and not State.Scanned then
            ut()
            return
        end
        u0("No win pads known, run Scan Win Pads")
        return
    end
    local Ax = Ay[1]
    local Az_2 = uy(Ax.Row, Ax.Name)
    if not Az_2 then
        uP(Ax.Position)
        u3(Ax.Position, 6)
        Az_2 = uj(function()
            return uy(Ax.Row, Ax.Name)
        end, 12)
    end
    if not Az_2 then
        u0("Waiting for " .. Ax.Key .. " to stream in")
        return
    end
    u3(Az_2.Position, 6)
    local Az_3 = 0
    for i, v in ipairs(Ay) do
        if (v.Position - Ax.Position).Magnitude <= t5.radius then
            local Ay_1 = uy(v.Row, v.Name)
            local AA = Ay_1 and uu(Ay_1)
            if AA then
                Az_3 += 1
            end
        end
    end
    u0(string.format("Farming %s (+%d) on %d pads | Wins %d", Ax.Key, Ax.Amount, Az_3, tX("Wins")))
end
t5.SetEnabled = fn53
t5.SetDelay = fn540
t5.SetPads = fn391
t5.SetRadius = fn469
t5.SetScan = fn1110
uG = fn957
tZ.SetEnabled = fn575
tZ.SetDelay = fn778
tZ.SetTrainer = fn725
tZ.SetStand = fn1151
t0 = fn99
vc.SetEnabled = fn664
vc.SetDelay = fn189
uJ = fn985
uk = fn900
u7.SetEnabled = fn359
t_ = fn372
uZ.SetEnabled = fn517
uZ.SetTargets = fn1102
uZ.SetEquip = fn841
uv = function(ia)
    return uK(function()
        local B2 = ia.Model:FindFirstChild("Touch")
        local B3 = not B2
        if B3 ~= false then
            B3 = ia.Position
        end
        if B3 then
            uP(ia.Position)
            u3(ia.Position, 5)
            B2 = uj(function()
                return ia.Model:FindFirstChild("Touch")
            end, 6)
        end
        local B3_1 = not B2 or not B2:IsA("BasePart")
        if B3_1 then
            return false
        end
        u3(B2.Position, 5)
        local B3_2 = os.clock() + 4
        while true do
            local B4 = t3() and os.clock() < B3_2 and not uV(ia.Name)
            if B4 then
                uu(B2)
                task.wait(0.2)
                continue
            end
            break
        end
        return uV(ia.Name)
    end)
end
uT = fn90
uS.SetEnabled = fn1114
uS.SetTargets = fn321
vf = function()
    local GY
    local onDiscord
    local G2
    onDiscord = nil
    GY = nil
    G2 = nil
    local GO, Library, GQ, Toggles, GT, ThemeManager, GV, Options, GX, GZ, G_, SaveManager, G1, G3
    G3 = "https://discord.gg/K7Qxnxkk46"
    GY = "https://discord.gg/K7Qxnxkk46"
    G1 = "+1 Tongue Escape"
    GT = "https://tempohub.shop"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    t8(uC, Library)
    GO = t4()
    G_ = ub()
    GV = uX()
    GQ, GX = uI()
    G2 = function(jl, jm)
        local Cp = ug(setclipboard) and setclipboard
        local Cq = Cp
        if not Cq then
            local Cp_1 = ug(toclipboard) and toclipboard
            Cq = Cp_1 or nil
        end
        local Cp_2 = Cq
        if not Cp_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local Cq_1 = pcall(Cp_2, jl)
        if Cq_1 then
            Library:Notify(jm)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        G2(GY, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = GY, Copyable = true }, "|", G1, "|", "v0.3" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    GZ = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function G4(jz)
        local DiscordGroup = jz:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in GZ do
        if k ~= "Info" then
            G4(v)
        end
    end
    local function G5_1()
        local CD
        CD = nil
        local Label
        local WinsGroup = GZ.Main:AddLeftGroupbox("Wins", "trophy")
        Label = WinsGroup:AddLabel(State.Status, true)
        WinsGroup:AddDivider()
        WinsGroup:AddToggle("AutoWins", {
            Text = "Auto Get Wins",
            Default = false,
            Tooltip = "Holds you on the best known win pad and touches every pad in range on a timer.",
            Callback = function(jK)
                t5.SetEnabled(jK)
            end
        })
        WinsGroup:AddDropdown("WinPads", {
            Text = "Win Pads",
            Values = GQ,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to always farm the highest paying pad that has been found.",
            Callback = function(jP)
                t5.SetPads(jP, GX)
            end
        })
        WinsGroup:AddSlider("WinDelay", {
            Text = "Touch Delay",
            Default = 1,
            Min = 0.2,
            Max = 10,
            Rounding = 1,
            Suffix = "s",
            Tooltip = "The pads only pay out about once per second each.",
            Callback = function(jT)
                t5.SetDelay(jT)
            end
        })
        WinsGroup:AddSlider("WinRadius", {
            Text = "Pad Radius",
            Default = 160,
            Min = 20,
            Max = 600,
            Rounding = 0,
            Suffix = " studs",
            Tooltip = "Also touches other known pads this close to the pad you are standing on.",
            Callback = function(jV)
                t5.SetRadius(jV)
            end
        })
        WinsGroup:AddToggle("WinAutoScan", {
            Text = "Scan Stages Automatically",
            Default = true,
            Tooltip = "Runs the streaming scan once when Auto Get Wins finds no pads.",
            Callback = function(jX)
                t5.SetScan(jX)
            end
        })
        WinsGroup:AddButton({
            Text = "Scan Win Pads",
            Func = function()
                task.spawn(function()
                    ut()
                    local j5, j6 = uI()
                    GX = j6
                    pcall(function()
                        Options.WinPads:SetValues(j5)
                    end)
                end)
            end
        })
        local TreadmillsGroup = GZ.Main:AddLeftGroupbox("Treadmills", "dumbbell")
        TreadmillsGroup:AddToggle("AutoTrain", {
            Text = "Auto Treadmills",
            Default = false,
            Tooltip = "Sends the training point remote on a timer to raise Tongue and Level.",
            Callback = function(kf)
                tZ.SetEnabled(kf)
            end
        })
        local CF = GV[1] or ""
        TreadmillsGroup:AddDropdown("TrainerChoice", {
            Text = "Treadmill",
            Values = GV,
            Default = CF,
            Multi = false,
            AllowNull = true,
            Tooltip = "The treadmill to stand on while training. Locked treadmills still need their gamepass or rebirths.",
            Callback = function(kk)
                tZ.SetTrainer(kk)
            end
        })
        TreadmillsGroup:AddToggle("TrainStand", {
            Text = "Stand On Treadmill",
            Default = true,
            Tooltip = "Holds you on the selected treadmill. Turn off to train from wherever you are.",
            Callback = function(km)
                tZ.SetStand(km)
            end
        })
        TreadmillsGroup:AddSlider("TrainDelay", {
            Text = "Train Delay",
            Default = 0.25,
            Min = 0.05,
            Max = 5,
            Rounding = 2,
            Suffix = "s",
            Callback = function(ko)
                tZ.SetDelay(ko)
            end
        })
        local ProgressGroup = GZ.Main:AddRightGroupbox("Progress", "trending-up")
        ProgressGroup:AddToggle("AutoRebirth", {
            Text = "Auto Rebirth",
            Default = false,
            Tooltip = "Rebirths as soon as your level reaches the requirement.",
            Callback = function(kr)
                vc.SetEnabled(kr)
            end
        })
        ProgressGroup:AddSlider("RebirthDelay", {
            Text = "Rebirth Check Delay",
            Default = 5,
            Min = 1,
            Max = 60,
            Rounding = 0,
            Suffix = "s",
            Callback = function(kw)
                vc.SetDelay(kw)
            end
        })
        ProgressGroup:AddToggle("AutoDaily", {
            Text = "Auto Claim Daily",
            Default = false,
            Tooltip = "Claims the daily reward whenever the cooldown is finished.",
            Callback = function(ky)
                u7.SetEnabled(ky)
            end
        })
        local ShopsGroup = GZ.Main:AddRightGroupbox("Shops", "shopping-cart")
        ShopsGroup:AddToggle("AutoTongues", {
            Text = "Auto Buy Affordable Tongues",
            Default = false,
            Tooltip = "Buys the tongue upgrades in order, since each pad is locked until the previous one is owned.",
            Callback = function(kD)
                uS.SetEnabled(kD)
            end
        })
        ShopsGroup:AddDropdown("TongueTargets", {
            Text = "Tongues",
            Values = G_,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Buying stops once every ticked tongue is owned. Cheaper ones are still bought first because they unlock the next pad.",
            Callback = function(kI)
                uS.SetTargets(kI)
            end
        })
        ShopsGroup:AddDivider("Trails")
        ShopsGroup:AddToggle("AutoTrails", {
            Text = "Auto Buy Trails",
            Default = false,
            Tooltip = "Buys unowned trails with wins, cheapest first.",
            Callback = function(kK)
                uZ.SetEnabled(kK)
            end
        })
        ShopsGroup:AddDropdown("TrailTargets", {
            Text = "Trails",
            Values = GO,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to buy every trail you can afford.",
            Callback = function(kP)
                uZ.SetTargets(kP)
            end
        })
        ShopsGroup:AddToggle("TrailEquip", {
            Text = "Equip Best Trail",
            Default = true,
            Tooltip = "Equips the owned trail with the highest point boost after buying.",
            Callback = function(kR)
                uZ.SetEquip(kR)
            end
        })
        CD = task.spawn(function()
            while not Library.Unloaded do
                pcall(function()
                    local k6 = string.format("Wins %d  |  Tongue %d  |  Level %d/%d  |  Rebirths %d  |  Pads %d", tX("Wins"), tX("Tongue"), tX("Level"), va(), tX("Rebirths"), uY())
                    Label:SetText(k6 .. "  |  " .. tostring(State.Status))
                end)
                local CA = false
                repeat
                    local Cw
                    if State.Notifications and #State.Notifications > 0 then
                        Cw = table.remove(State.Notifications, 1)
                        pcall(function()
                            Library:Notify(Cw.text, Cw.time)
                        end)
                    else
                        CA = true
                    end
                until CA
                task.wait(0.3)
            end
        end)
        uC.Track(function()
            if coroutine.status(CD) ~= "dead" then
                pcall(task.cancel, CD)
            end
        end)
    end
    G5_1()
    local function G4_1()
        local C_
        local C8
        local C6
        local C2
        C_ = nil
        C2 = nil
        C6 = nil
        C8 = nil
        local Label, C0, C1, C3, C4, Label3, Label2, C9, Da
        C2 = function(lk)
            return (tostring(lk):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        C8 = function(lm, ln)
            return string.format('<font color="%s">%s</font>', ln, C2(lm))
        end
        C3 = function(lq, lr, ls)
            return string.format("<b>%s</b> %s %s", lq, C8("-", "#5a6070"), C8(lr, ls))
        end
        local Db = "#8b93a3"
        C1 = "#7fd47f"
        local Dc = {}
        local Dd = "#6ec1ff"
        C9 = "#e8a34d"
        local Dj = if not ug(firetouchinterest) then 1 else 0
        if Dj == 1 then
            table.insert(Dc, "wins and tongue upgrades")
        end
        if not u4() then
            table.insert(Dc, "win pads")
        end
        local Dm = if not u2("AddTongue", "RemoteEvent") then 1 else 0
        if Dm == 1 then
            table.insert(Dc, "training")
        end
        if not u2("RequestRebirth", "RemoteFunction") then
            table.insert(Dc, "rebirths")
        end
        if not u2("DailyClaim", "RemoteEvent") then
            table.insert(Dc, "daily rewards")
        end
        local Dj_1 = if not u2("TrailAction", "RemoteEvent") then 1 else 0
        if Dj_1 == 1 then
            table.insert(Dc, "trails")
        end
        local De = #Dc == 0 and "ready"
        local Df = De or "limited: " .. table.concat(Dc, ", ")
        C4 = "Unknown"
        pcall(function()
            local CI_1
            local CH_1
            if ug(identifyexecutor) then
                CI_1, CH_1 = identifyexecutor()
                local CJ = CI_1 ~= ""
                local CK = type(CI_1) == "string" and CJ
                if CK then
                    local CJ_1 = type(CH_1) == "string" and CH_1 ~= "" and CI_1 .. " " .. CH_1
                    C4 = CJ_1 or CI_1
                end
            end
        end)
        C6 = os.clock()
        C0 = function()
            local CP = math.floor(os.clock() - C6)
            if CP < 60 then
                return CP .. "s"
            elseif CP < 3600 then
                return string.format("%dm %ds", math.floor((CP) / (60)), CP % 60)
            else
                return string.format("%dh %dm", math.floor((CP) / (3600)), math.floor((CP % 3600) / (60)))
            end
        end
        local UserGroup = GZ.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(C3("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, C1), true)
        UserGroup:AddLabel(C3("UserId", tostring(LocalPlayer.UserId), Dd), true)
        UserGroup:AddLabel(C3("Executor", C4 .. "  " .. Df, C1), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(C3("Session", C0(), C9), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                G2(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                G2("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = GZ.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(C3("Game", G1, Dd), true)
        Label2 = SessionGroup:AddLabel(C3("Players", "0/0", C1), true)
        Da = tostring(game.JobId)
        local Dd_1 = #Da > 18 and string.sub(Da, 1, 18) .. "..."
        local De_2 = Dd_1 or Da
        SessionGroup:AddLabel(C3("Job", De_2, Db), true)
        Label = SessionGroup:AddLabel(C3("Ping", "0 ms", C9), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                ui:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                G2(Da, "Copied Job ID")
            end
        })
        C_ = task.spawn(function()
            local CV_1
            local CU_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(C3("Session", C0(), C9))
                Label2:SetText(C3("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), C1))
                CU_1, CV_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local CU_2 = CU_1 and CV_1 .. " ms" or "n/a"
                Label:SetText(C3("Ping", CU_2, C9))
            end
        end)
        uC.Track(function()
            if coroutine.status(C_) ~= "dead" then
                task.cancel(C_)
            end
        end)
        local SocialsGroup = GZ.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                G2(G3, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                G2(GT, "Copied website link")
            end
        })
    end
    G4_1()
    local function G4_2()
        local mJ
        local mH
        local mK
        local mI
        local MovementGroup = GZ.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = GZ.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local mG = {}
        mK = {}
        mH = {}
        mJ = {}
        mI = {}
        local function mL()
            for k, v in mH do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(mH)
        end
        local function mP()
            for k, v in mI do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(mI)
        end
        local function mT()
            for k, v in mJ do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(mJ)
        end
        local function mX(mY)
            if not mY:IsA("ProximityPrompt") then
                return
            end
            if mK[mY] == nil then
                mK[mY] = {
                    HoldDuration = mY.HoldDuration,
                    MaxActivationDistance = mY.MaxActivationDistance,
                    RequiresLineOfSight = mY.RequiresLineOfSight
                }
            end
            mY.HoldDuration = 0
            mY.MaxActivationDistance = 50
            mY.RequiresLineOfSight = false
        end
        local function m_()
            for k, v in mK do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(mK)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                mT()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                mP()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                mL()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(mX, v)
                end
            else
                m_()
            end
        end)
        table.insert(mG, Workspace.DescendantAdded:Connect(function(ni)
            if Toggles.InstantProximityPrompt.Value then
                mX(ni)
            end
        end))
        table.insert(mG, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if mH[v] == nil then
                        mH[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(mG, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Ea = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and Ea then
                Ea:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(mG, RunService.RenderStepped:Connect(function(nE)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Eg = Character and Character:FindFirstChildOfClass("Humanoid")
            local Eh = Character
            if Eh then
                Eh = Character:FindFirstChild("HumanoidRootPart")
            end
            local Ef_1 = Eh
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and Eg then
                if mI[Eg] == nil then
                    mI[Eg] = Eg.WalkSpeed
                end
                Eg.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and Ef_1 and Eg and CurrentCamera then
                if mJ[Eg] == nil then
                    mJ[Eg] = Eg.PlatformStand
                end
                Eg.PlatformStand = true
                local Eh_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        Eh_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        Eh_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        Eh_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        Eh_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Eh_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        Eh_4 -= Vector3.new(0, 1, 0)
                    end
                end
                Ef_1.AssemblyLinearVelocity = Vector3.zero
                if Eh_4.Magnitude > 0 then
                    Ef_1.CFrame = Ef_1.CFrame + Eh_4.Unit * Options.FlySpeed.Value * nE
                end
            end
        end))
        uC.Track(function()
            for k, v in mG do
                v:Disconnect()
            end
            mL()
            mP()
            mT()
            m_()
        end)
    end
    G4_2()
    local function G4_3()
        local Fx, Fy, Fz, FA, FB, FC, FD, Label, FF, FG, FH, FI, FJ, FK
        FF = {}
        Fz = {}
        FK = nil
        FB = false
        Fx = 0
        FH = 0
        FC = os.clock()
        local MenuGroup = GZ.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        FI = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local Ew = not CurrentCamera or not ug(VirtualUser.CaptureController)
            local EA = if Ew then 1 else 0
            local Ey = 1140 * EA + 2750 * (1 - EA)
            local Ez = 124 * EA + 3990 * (1 - EA)
            if not ((Ey * 2744 + Ez * 309 + Ey * Ez) % 16777213 == 3307836) then
                Ew = not ug(VirtualUser.ClickButton2)
            end
            if Ew then
                return false
            end
            local Ew_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not Ew_1 then
                return false
            end
            Fx += 1
            FC = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. Fx)
            end)
            return true
        end
        FD = function(oo)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not oo)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not oo
                end
            end)
            if not oo then
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
        FA = function(oG)
            local EF = oG.ClassName == "ParticleEmitter" or oG.ClassName == "Trail" or oG.ClassName == "Smoke" or oG.ClassName == "Fire"
            local EJ = if EF then 1 else 0
            local EH = 1795 * EJ + 656 * (1 - EJ)
            local EI = 1965 * EJ + 2353 * (1 - EJ)
            if not ((EH * 3784 + EI * 998 + EH * EI) % 16777213 == 12280525) then
                EF = oG.ClassName == "Sparkles"
            end
            local EJ_1 = if EF then 1 else 0
            local EH_1 = 803 * EJ_1 + 662 * (1 - EJ_1)
            local EI_1 = 851 * EJ_1 + 3689 * (1 - EJ_1)
            if not ((EH_1 * 1059 + EI_1 * 1019 + EH_1 * EI_1) % 16777213 == 2400899) then
                EF = oG.ClassName == "Explosion"
            end
            if not EF then
                EF = oG.ClassName == "Beam"
            end
            if EF then
                if FF[oG] == nil then
                    FF[oG] = oG.Enabled
                end
                pcall(function()
                    oG.Enabled = false
                end)
            end
        end
        Fy = function()
            for k, v in FF do
                local EO = k
                local EQ = v
                if EO.Parent then
                    pcall(function()
                        EO.Enabled = EQ
                    end)
                end
            end
            table.clear(FF)
            if FK then
                pcall(function()
                    settings().Rendering.QualityLevel = FK.Quality
                end)
                Lighting.GlobalShadows = FK.Shadows
                Lighting.FogEnd = FK.Fog
                FK = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(oV)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not oV)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(o_)
                if o_ then
                    if not FK then
                        FK = {
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
                    for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(FA, v)
                    end
                else
                    Fy()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        FD(true)
        local ScriptGroup = GZ.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            FD(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            FD(true)
        end
        table.insert(Fz, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                FI()
            end
        end))
        table.insert(Fz, Workspace.DescendantAdded:Connect(function(pi)
            if Toggles.FpsBoost.Value then
                FA(pi)
            end
        end))
        FJ = function(pm)
            if FB or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            FB = true
            local E2 = FH
            local E3_1 = pcall(function()
                if pm then
                    ui:Teleport(game.PlaceId, LocalPlayer)
                else
                    ui:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not E3_1 then
                FB = false
                if not pm and E2 == FH then
                    task.delay(1.5, function()
                        if E2 == FH then
                            FJ(true)
                        end
                    end)
                end
            end
        end
        table.insert(Fz, ui.TeleportInitFailed:Connect(function(pE)
            local Fa
            if pE == LocalPlayer and FB then
                FB = false
                Fa = FH
                task.delay(3, function()
                    if Fa == FH then
                        FJ(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Fi = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not Fi then
                return
            end
            table.insert(Fz, Fi.ChildAdded:Connect(function(pT)
                if pT.Name == "ErrorPrompt" then
                    FJ(false)
                end
            end))
        end)
        FG = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    FD(true)
                end
                local Fo = Toggles.AntiAfk.Value and os.clock() - FC >= 60
                if Fo then
                    FI()
                end
                task.wait(1)
            end
        end)
        uC.Track(function()
            FH += 1
            for k, v in Fz do
                v:Disconnect()
            end
            pcall(task.cancel, FG)
            FD(false)
            Fy()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    G4_3()
    local function G4_4()
        local GF, GG, GH, GI
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(GZ.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/TongueEscape")
        local GJ = SaveManager:BuildConfigSection(GZ.Settings)
        GF = function(qj, qk)
            local FO_1 = (qj == "Toggle" and Toggles or Options)[qk]
            local FN_2 = type(FO_1) == "table" and FO_1.Type == qj
            return FN_2 and FO_1 or nil
        end
        GH = function(qt, qu)
            local Type = qu.Type
            if Type == "Toggle" then
                return { idx = qt, type = "Toggle", value = qu.Value == true }
            elseif Type == "Slider" then
                return { idx = qt, type = "Slider", value = tostring(qu.Value) }
            elseif Type == "Dropdown" then
                return { idx = qt, type = "Dropdown", multi = qu.Multi == true, value = qu.Value }
            elseif Type == "Input" then
                local FS = qu.Value
                local FW = if FS then 1 else 0
                local FU = 1582 * FW + 3608 * (1 - FW)
                local FV = 4083 * FW + 3836 * (1 - FW)
                if not ((FU * 3749 + FV * 2116 + FU * FV) % 16777213 == 4252639) then
                    FS = ""
                end
                return { idx = qt, type = "Input", text = tostring(FS) }
            elseif Type == "ColorPicker" then
                return { idx = qt, type = "ColorPicker", value = qu.Value:ToHex(), transparency = qu.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = qt,
                    type = "KeyPicker",
                    mode = qu.Mode,
                    key = qu.Value,
                    modifiers = qu.Modifiers,
                    toggled = qu.Toggled
                }
            else
                return nil
            end
        end
        GG = function()
            local FY = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local FZ = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if FZ then
                        local FZ_1 = GH(k, v)
                        if FZ_1 then
                            FY[#FY + 1] = FZ_1
                        end
                    end
                end
            end
            table.sort(FY, function(qE, qF)
                if qE.type ~= qF.type then
                    return qE.type < qF.type
                end
                return qE.idx < qF.idx
            end)
            return { objects = FY }
        end
        GI = function(qH)
            local Gh
            Gh = nil
            local Gi = type(qH) ~= "table" or type(qH.idx) ~= "string"
            local Gm = if Gi then 1 else 0
            local Gk = 835 * Gm + 1052 * (1 - Gm)
            local Gl = 3965 * Gm + 3707 * (1 - Gm)
            if not ((Gk * 4047 + Gl * 3406 + Gk * Gl) % 16777213 == 3417597) then
                Gi = type(qH.type) ~= "string"
            end
            local Gm_1 = if Gi then 1 else 0
            local Gk_1 = 3959 * Gm_1 + 3584 * (1 - Gm_1)
            local Gl_1 = 3470 * Gm_1 + 3153 * (1 - Gm_1)
            if not ((Gk_1 * 1534 + Gl_1 * 2330 + Gk_1 * Gl_1) % 16777213 == 11118723) then
                Gi = SaveManager.Ignore[qH.idx]
            end
            if Gi then
                return false
            end
            Gh = GF(qH.type, qH.idx)
            if not Gh then
                return false
            end
            local Gi_1 = pcall(function()
                if qH.type == "Input" then
                    if type(qH.text) ~= "string" then
                        return
                    end
                    Gh:SetValue(qH.text)
                elseif qH.type == "ColorPicker" then
                    Gh:SetValueRGB(Color3.fromHex(qH.value), qH.transparency)
                elseif qH.type == "KeyPicker" then
                    Gh:SetValue({ qH.key, qH.mode, qH.modifiers })
                    if qH.mode == "Toggle" and qH.toggled ~= nil then
                        Gh.Toggled = qH.toggled
                        Gh:Update()
                    end
                else
                    Gh:SetValue(qH.value)
                end
            end)
            return Gi_1
        end
        GJ:AddDivider()
        GJ:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        GJ:AddButton("Export Config to Clipboard", function()
            local Go_1
            local Gn_1
            Gn_1, Go_1 = pcall(HttpService.JSONEncode, HttpService, GG())
            if Gn_1 then
                local Gn_2 = ug(setclipboard) and setclipboard
                local Gp = Gn_2
                if not Gp then
                    local Gn_3 = ug(toclipboard) and toclipboard
                    Gp = Gn_3 or nil
                end
                local Gn_4 = Gp
                local Gp_1 = type(Gn_4) == "function" and pcall(Gn_4, Go_1)
                if Gp_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        GJ:AddButton("Import Config from Clipboard Text", function()
            local Gu_1
            local Gs = Options.SaveManager_ImportSource.Value or ""
            local Gs_1
            local Gt = tostring(Gs):match("^%s*(.-)%s*$")
            if Gt == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #Gt > 262144 then
                Library:Notify("That config is too large")
                return
            end
            Gs_1, Gu_1 = pcall(HttpService.JSONDecode, HttpService, Gt)
            local Gt_1 = not Gs_1 or type(Gu_1) ~= "table"
            local Gy = if Gt_1 then 1 else 0
            local Gw = 275 * Gy + 3515 * (1 - Gy)
            local Gx = 3030 * Gy + 2377 * (1 - Gy)
            if not ((Gw * 2122 + Gx * 2112 + Gw * Gx) % 16777213 == 7816160) then
                Gt_1 = type(Gu_1.objects) ~= "table"
            end
            if Gt_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #Gu_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local Gs_2 = 0
            for i, v in ipairs(Gu_1.objects) do
                if GI(v) then
                    Gs_2 += 1
                end
            end
            if Gs_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local Gu_2 = Gs_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(Gs_2, Gu_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.WinDelay then
            t5.SetDelay(Options.WinDelay.Value)
        end
        if Options.WinRadius then
            t5.SetRadius(Options.WinRadius.Value)
        end
        if Options.WinPads then
            t5.SetPads(Options.WinPads.Value, GX)
        end
        if Toggles.WinAutoScan then
            t5.SetScan(Toggles.WinAutoScan.Value)
        end
        if Options.TrainDelay then
            tZ.SetDelay(Options.TrainDelay.Value)
        end
        if Options.TrainerChoice then
            tZ.SetTrainer(Options.TrainerChoice.Value)
        end
        if Toggles.TrainStand then
            tZ.SetStand(Toggles.TrainStand.Value)
        end
        if Options.RebirthDelay then
            vc.SetDelay(Options.RebirthDelay.Value)
        end
        if Options.TongueTargets then
            uS.SetTargets(Options.TongueTargets.Value)
        end
        if Options.TrailTargets then
            uZ.SetTargets(Options.TrailTargets.Value)
        end
        if Toggles.TrailEquip then
            uZ.SetEquip(Toggles.TrailEquip.Value)
        end
        if Toggles.AutoWins then
            t5.SetEnabled(Toggles.AutoWins.Value)
        end
        if Toggles.AutoTrain then
            tZ.SetEnabled(Toggles.AutoTrain.Value)
        end
        if Toggles.AutoRebirth then
            vc.SetEnabled(Toggles.AutoRebirth.Value)
        end
        if Toggles.AutoDaily then
            u7.SetEnabled(Toggles.AutoDaily.Value)
        end
        if Toggles.AutoTongues then
            uS.SetEnabled(Toggles.AutoTongues.Value)
        end
        if Toggles.AutoTrails then
            uZ.SetEnabled(Toggles.AutoTrails.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    G4_4()
end
vf()
end)(...)
