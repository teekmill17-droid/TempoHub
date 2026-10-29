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
getgenv().TempoHoodSubtitle = "+1 POOP PER CLICK"
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
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local function hubGetHui()
	return CoreGui
end
if getgenv then
	getgenv().gethui = hubGetHui
	local previous = getgenv().__TempoPoopPerClickLib
	if previous and previous.Unload then
		pcall(function()
			previous:Unload()
		end)
	end
end
pcall(function()
	gethui = hubGetHui
end)
if setthreadidentity then
	setthreadidentity(8)
end
local function cref(instance)
	if cloneref and typeof(instance) == "Instance" then
		return cloneref(instance)
	end
	return instance
end
local GAME_NAME = "+1 Poop Per Click"
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local RSCRIPTS_LINK = "https://discord.gg/K7Qxnxkk46"
local WEBSITE_LINK = "https://tempohub.shop"
local GameShared = ReplicatedStorage:WaitForChild("GameShared")
local Remotes = GameShared:WaitForChild("Remotes")
local GameConfig = require(GameShared:WaitForChild("Config"):WaitForChild("GameConfig"))
local RequestClick = cref(Remotes:WaitForChild("RequestClick"))
local RequestRebirth = cref(Remotes:WaitForChild("RequestRebirth"))
local RequestUpgrade = cref(Remotes:WaitForChild("RequestUpgrade"))
local RequestAuraRoll = cref(Remotes:WaitForChild("RequestAuraRoll"))
local BattleEvent = cref(Remotes:WaitForChild("BattleEvent"))
local StateChanged = cref(Remotes:WaitForChild("StateChanged"))
local MANUAL_CLICKS_PER_SECOND = tonumber(GameConfig.MANUAL_CLICKS_PER_SECOND) or 14
local CLICK_INTERVAL = 1 / math.max(1, MANUAL_CLICKS_PER_SECOND)
local WIN_PAD_COOLDOWN = tonumber(GameConfig.WIN_PAD_COOLDOWN_SECONDS) or 0.5
local AURA_ROLL_COST = tonumber(GameConfig.AURA_ROLL_COST) or 1000
local STAGE_COUNT = 20
local WIN_MODE_BEST = "Best Unlocked"
local WIN_MODE_SELECTED = "Selected"
local UPGRADE_ORDER = { "WalkSpeed", "AuraLuck" }
local UPGRADE_LABELS = {}
local UPGRADE_BY_LABEL = {}
for _, id in UPGRADE_ORDER do
	local data = GameConfig.UPGRADES[id]
	local label = data and data.displayName or id
	UPGRADE_LABELS[#UPGRADE_LABELS + 1] = label
	UPGRADE_BY_LABEL[label] = id
end
local TOILET_LABELS = {}
local TOILET_BY_LABEL = {}
do
	local list = {}
	for id, data in GameConfig.TOILETS do
		list[#list + 1] = {
			id = id,
			multiplier = tonumber(data.multiplier) or 0,
		}
	end
	table.sort(list, function(a, b)
		return a.multiplier < b.multiplier
	end)
	for _, entry in list do
		local label = entry.multiplier .. "x"
		TOILET_LABELS[#TOILET_LABELS + 1] = label
		TOILET_BY_LABEL[label] = entry.id
	end
end
local Toggles
local Options
local connections = {}
local function track(connection)
	if connection then
		connections[#connections + 1] = connection
	end
	return connection
end
local replica = nil
local lastWorldId = 0
local lastClickAt = 0
local lastFoodAt = 0
local lastUpgradeAt = 0
local lastAuraAt = 0
local lastBattleAt = 0
local lastWinTouchAt = 0
local parkedWinStage = nil
local parkedWinCharacter = nil
local battleBusy = false
local battleBusyAt = 0
local battleLockUntil = 0
local CUTSCENE_BIND = "TempoPoopNoCutscene"
local function isOn(name)
	local toggle = Toggles and Toggles[name]
	return toggle ~= nil and toggle.Value == true
end
local function getChoice(name)
	local option = Options[name]
	return option and option.Value or nil
end
local function selectedHas(option, label)
	local value = option and option.Value
	if type(value) ~= "table" then
		return false
	end
	if value[label] == true then
		return true
	end
	for _, entry in value do
		if entry == label then
			return true
		end
	end
	return false
end
local function asNumber(value)
	local n = tonumber(value)
	if n then
		return n
	end
	if type(value) == "string" then
		n = tonumber((string.gsub(value, "[,%s]", "")))
		if n then
			return n
		end
	end
	return 0
end
local function getHumanoid()
	local character = LocalPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
	local character = LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end
local function getLeaderstat(name)
	local stats = LocalPlayer:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild(name)
	return value and asNumber(value.Value) or 0
end
local function captureReplicaFromConnections()
	if not getconnections or not debug or not debug.getupvalues then
		return
	end
	local ok, conns = pcall(getconnections, StateChanged.OnClientEvent)
	if not ok or type(conns) ~= "table" then
		return
	end
	for _, connection in conns do
		local fn = connection.Function
		if type(fn) == "function" then
			local uvOk, uvs = pcall(debug.getupvalues, fn)
			if uvOk and type(uvs) == "table" then
				for _, value in uvs do
					if type(value) == "table" and value.rebirths ~= nil and value.highestUnlockedStage ~= nil then
						replica = value
						return
					end
				end
			end
		end
	end
end
track(StateChanged.OnClientEvent:Connect(function(state)
	if type(state) == "table" then
		replica = state
	end
end))
captureReplicaFromConnections()
local function cancelCameraTweens(camera)
	if not camera then
		return
	end
	pcall(function()
		for _, tween in TweenService:GetPlayingTweens() do
			if tween.Instance == camera then
				tween:Cancel()
			end
		end
	end)
end
local function restoreBattleCamera()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		return
	end
	cancelCameraTweens(camera)
	camera.CameraType = Enum.CameraType.Custom
	local humanoid = getHumanoid()
	if humanoid then
		camera.CameraSubject = humanoid
	end
end
track(BattleEvent.OnClientEvent:Connect(function(action)
	if action == "Start" or action == "Begin" or action == "Update" then
		battleBusy = true
		battleBusyAt = os.clock()
		restoreBattleCamera()
	elseif action == "StageCompleted" then
		battleLockUntil = math.max(battleLockUntil, os.clock() + 2.2)
		restoreBattleCamera()
	elseif action == "Result" then
		battleBusy = false
		battleLockUntil = math.max(battleLockUntil, os.clock() + 1.7)
		restoreBattleCamera()
	end
end))
local function getState()
	local state = replica
	if type(state) ~= "table" then
		return {
			wins = getLeaderstat("Wins"),
			poop = getLeaderstat("Poop"),
			rebirths = getLeaderstat("Rebirths"),
			level = getLeaderstat("Level"),
			highestUnlockedStage = 1,
			currentWorldId = Workspace:GetAttribute("ActiveWorldId") or 1,
			equippedFoodId = "",
			unlockedFoods = {},
			ownedAuras = {},
			passOwnership = {},
			walkSpeedLevel = 0,
			auraLuckLevel = 0,
			luckyAuraRolls = 0,
			superAuraRolls = 0,
			autoWinsEnabled = false,
			isBattling = false,
			worldProgress = {},
		}
	end
	return state
end
local function battleBlocking()
	return battleBusy or getState().isBattling or os.clock() < battleLockUntil
end
local function currentWorldId()
	local state = getState()
	local worldId = tonumber(state.currentWorldId)
	if not worldId then
		worldId = tonumber(Workspace:GetAttribute("ActiveWorldId"))
	end
	return math.clamp(worldId or 1, 1, 3)
end
local function highestUnlockedStage()
	local state = getState()
	local stage = tonumber(state.highestUnlockedStage) or 1
	return math.clamp(stage, 1, STAGE_COUNT + 1)
end
local function foodOwned(foodId)
	local state = getState()
	if state.equippedFoodId == foodId then
		return true
	end
	local unlocked = state.unlockedFoods
	if type(unlocked) ~= "table" then
		return false
	end
	for _, id in unlocked do
		if id == foodId then
			return true
		end
	end
	return false
end
local function hasPass(passKey)
	if type(passKey) ~= "string" or passKey == "" then
		return true
	end
	local ownership = getState().passOwnership
	return type(ownership) == "table" and ownership[passKey] == true
end
local function stageLabel(worldId, stageIndex)
	local worldStages = GameConfig.WORLD_STAGES[worldId]
	local data = worldStages and worldStages[stageIndex]
	local npcName = data and data.npcName or ("Stage " .. stageIndex)
	return stageIndex .. " · " .. npcName
end
local function stageValues(worldId)
	local values = {}
	for index = 1, STAGE_COUNT do
		values[index] = stageLabel(worldId, index)
	end
	return values
end
local function parseStage(label)
	return tonumber(string.match(tostring(label), "^(%d+)"))
end
local function selectedStages(optionName)
	local option = Options and Options[optionName]
	local stages = {}
	if not option then
		return stages
	end
	local value = option.Value
	if type(value) ~= "table" then
		return stages
	end
	for key, entry in value do
		local label = type(key) == "string" and entry == true and key or entry
		local stage = parseStage(label)
		if stage then
			stages[#stages + 1] = stage
		end
	end
	table.sort(stages)
	return stages
end
local function worldFolder(name)
	local authority = Workspace:FindFirstChild("WorldInteractionAuthority")
	if authority then
		local world = authority:FindFirstChild("World" .. tostring(currentWorldId()))
		if world then
			local child = world:FindFirstChild(name)
			if child then
				return child
			end
		end
	end
	local visuals = Workspace:FindFirstChild("WorldClientVisuals")
	if visuals then
		return visuals:FindFirstChild(name)
	end
	return nil
end
local function stageFolder(stageIndex)
	local interactables = Workspace:FindFirstChild("Interactables")
	local stages = interactables and interactables:FindFirstChild("Stages")
	return stages and stages:FindFirstChild("Stage" .. tostring(stageIndex))
end
local function winPad(stageIndex)
	local folder = stageFolder(stageIndex)
	if not folder then
		return nil
	end
	local useDouble = hasPass("DoubleWins")
	local pad = folder:FindFirstChild(useDouble and "2xLevelWinsPad" or "LevelWinsPad")
	if pad and pad:IsA("BasePart") then
		return pad
	end
	return nil
end
local function battlePrompt(stageIndex)
	local folder = stageFolder(stageIndex)
	local toilet = folder and folder:FindFirstChild("Playertoilet")
	if not toilet then
		return nil
	end
	local prompt = toilet:FindFirstChild("BattlePrompt", true)
	if prompt and prompt:IsA("ProximityPrompt") then
		return prompt
	end
	return nil
end
local function teleportTo(part, extra)
	local root = getRoot()
	if not root or not part then
		return false
	end
	local position
	if typeof(part) == "Vector3" then
		position = part
	elseif part:IsA("BasePart") then
		position = part.Position
	elseif part:IsA("Model") then
		position = part:GetPivot().Position
	else
		return false
	end
	local offset = extra or Vector3.new(0, 3, 0)
	local look = root.CFrame.LookVector
	root.CFrame = CFrame.new(position + offset, position + offset + look)
	return true
end
local function touchPart(part)
	local root = getRoot()
	if not root or not part or not part:IsA("BasePart") then
		return
	end
	if firetouchinterest then
		pcall(firetouchinterest, root, part, 0)
		task.defer(function()
			pcall(firetouchinterest, root, part, 1)
		end)
	end
end
local function firePrompt(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") then
		return false
	end
	pcall(function()
		prompt.Enabled = true
		prompt.HoldDuration = 0
		prompt.RequiresLineOfSight = false
	end)
	local parent = prompt.Parent
	local root = getRoot()
	if parent and parent:IsA("BasePart") then
		if not root or (root.Position - parent.Position).Magnitude > 5 then
			teleportTo(parent, Vector3.new(0, 2, 0))
		end
	elseif parent then
		teleportTo(parent)
	end
	local ok = false
	if fireproximityprompt then
		ok = pcall(fireproximityprompt, prompt)
	end
	if firesignal then
		pcall(firesignal, prompt.Triggered, LocalPlayer)
		ok = true
	end
	if not ok then
		ok = pcall(function()
			ProximityPromptService.PromptTriggered:Fire(prompt, LocalPlayer)
		end)
	end
	return ok
end
local function requestClick()
	local now = os.clock()
	if now - lastClickAt < CLICK_INTERVAL then
		return
	end
	lastClickAt = now
	RequestClick:FireServer()
end
local function toiletModel(toiletId)
	local toilets = worldFolder("Toilets")
	if not toilets then
		return nil
	end
	return toilets:FindFirstChild("Toilet_" .. toiletId)
end
local function toiletSeat(model)
	if not model then
		return nil
	end
	local seat = model:FindFirstChild("ToiletSeat", true)
	if seat and seat:IsA("Seat") then
		return seat
	end
	return model:FindFirstChildWhichIsA("Seat", true)
end
local function bestFood()
	local pads = worldFolder("FoodPads")
	if not pads then
		return nil
	end
	local wins = tonumber(getState().wins) or 0
	local best
	for _, pad in pads:GetChildren() do
		local foodId = pad:GetAttribute("FoodId")
		if type(foodId) == "string" then
			local data = GameConfig.FOODS[foodId]
			if data and hasPass(data.passKey) then
				local cost = tonumber(data.winCost) or 0
				local owned = foodOwned(foodId)
				if owned or wins >= cost then
					local power = tonumber(data.basePower) or 0
					if not best or power > best.power then
						local prompt = pad:FindFirstChild("FoodPrompt")
						if prompt and prompt:IsA("ProximityPrompt") and prompt.MaxActivationDistance > 0 then
							best = {
								id = foodId,
								power = power,
								owned = owned,
								pad = pad,
								prompt = prompt,
							}
						end
					end
				end
			end
		end
	end
	return best
end
local function ensureFood(foodId)
	if type(foodId) ~= "string" or foodOwned(foodId) then
		return foodOwned(foodId)
	end
	local pads = worldFolder("FoodPads")
	local pad = pads and pads:FindFirstChild(foodId)
	if not pad then
		return false
	end
	local data = GameConfig.FOODS[foodId]
	local cost = data and tonumber(data.winCost) or 0
	if (tonumber(getState().wins) or 0) < cost then
		return false
	end
	local prompt = pad:FindFirstChild("FoodPrompt")
	if prompt then
		firePrompt(prompt)
	end
	return false
end
local Farm = {}
function Farm.click()
	if isOn("AutoClick") or battleBusy or getState().isBattling then
		requestClick()
	end
end
function Farm.rebirth()
	if not isOn("AutoRebirth") then
		return
	end
	local state = getState()
	if battleBlocking() then
		return
	end
	local rebirths = tonumber(state.rebirths) or 0
	local level = tonumber(state.level) or 0
	local requirement = GameConfig.getRebirthRequirement(rebirths)
	if level >= requirement then
		RequestRebirth:FireServer()
	end
end
function Farm.upgrades()
	if not isOn("AutoBuyUpgrades") then
		return
	end
	local now = os.clock()
	if now - lastUpgradeAt < 0.35 then
		return
	end
	local state = getState()
	local wins = tonumber(state.wins) or 0
	local worldId = currentWorldId()
	local scale = GameConfig.getWorldNumericScale(worldId)
	local option = Options.UpgradeKinds
	for _, label in UPGRADE_LABELS do
		if selectedHas(option, label) then
			local id = UPGRADE_BY_LABEL[label]
			local data = GameConfig.UPGRADES[id]
			if data then
				local level = 0
				if id == "WalkSpeed" then
					level = tonumber(state.walkSpeedLevel) or 0
				elseif id == "AuraLuck" then
					level = tonumber(state.auraLuckLevel) or 0
				end
				if level < (tonumber(data.maxLevel) or 0) then
					local ok, cost = pcall(GameConfig.getUpgradeWinCost, id, level)
					if ok then
						local scaled = cost * (tonumber(scale) or 1)
						if wins >= scaled then
							lastUpgradeAt = now
							RequestUpgrade:FireServer(id)
							return
						end
					end
				end
			end
		end
	end
end
function Farm.auras()
	if not isOn("AutoRollAura") then
		return
	end
	local now = os.clock()
	if now - lastAuraAt < 0.85 then
		return
	end
	local state = getState()
	if (tonumber(state.superAuraRolls) or 0) > 0 then
		lastAuraAt = now
		RequestAuraRoll:FireServer("Super")
		return
	end
	if (tonumber(state.luckyAuraRolls) or 0) > 0 then
		lastAuraAt = now
		RequestAuraRoll:FireServer("Lucky")
		return
	end
	local wins = math.max(asNumber(state.wins), getLeaderstat("Wins"))
	if wins >= AURA_ROLL_COST then
		lastAuraAt = now
		RequestAuraRoll:FireServer("Regular")
	end
end
function Farm.buyClick()
	if not isOn("AutoBuyClick") then
		return
	end
	if battleBlocking() then
		return
	end
	local now = os.clock()
	if now - lastFoodAt < 0.45 then
		return
	end
	local food = bestFood()
	if not food then
		return
	end
	if getState().equippedFoodId == food.id then
		return
	end
	lastFoodAt = now
	firePrompt(food.prompt)
end
function Farm.train()
	if not isOn("AutoTrain") then
		return
	end
	if isOn("AutoWin") or battleBlocking() then
		return
	end
	local toiletId = TOILET_BY_LABEL[getChoice("TrainToilet")]
	if type(toiletId) ~= "string" then
		return
	end
	local model = toiletModel(toiletId)
	local seat = toiletSeat(model)
	local target = seat
	if not target and model then
		target = model:FindFirstChild("Pad") or model
	end
	if not target then
		return
	end
	local root = getRoot()
	local position = target:IsA("BasePart") and target.Position or target:GetPivot().Position
	if root and (root.Position - position).Magnitude < 8 then
		return
	end
	teleportTo(target, Vector3.new(0, 3, 0))
end
function Farm.battle()
	if not isOn("AutoBattleInOrder") then
		return
	end
	if battleBusy and os.clock() - battleBusyAt > 45 then
		battleBusy = false
	end
	if battleBusy or getState().isBattling then
		restoreBattleCamera()
		return
	end
	local now = os.clock()
	if now < battleLockUntil then
		return
	end
	if now - lastBattleAt < 0.55 then
		return
	end
	local target = highestUnlockedStage()
	if target < 1 or target > STAGE_COUNT then
		return
	end
	local prompt = battlePrompt(target)
	if not prompt then
		return
	end
	pcall(function()
		local api
		if getrenv then
			local env = getrenv()
			api = env.EwwPooBattlePrompt or (env._G and env._G.EwwPooBattlePrompt)
		end
		api = api or rawget(_G, "EwwPooBattlePrompt")
		if type(api) == "table" and type(api.set) == "function" then
			api.set(target, true)
		end
		prompt.Enabled = true
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 15
	end)
	lastBattleAt = now
	battleLockUntil = now + 2.5
	firePrompt(prompt)
end
function Farm.win()
	if not isOn("AutoWin") then
		parkedWinStage = nil
		parkedWinCharacter = nil
		return
	end
	if battleBlocking() then
		return
	end
	local unlocked = highestUnlockedStage()
	local target
	if getChoice("WinMode") == WIN_MODE_SELECTED then
		for _, stage in selectedStages("SelectedStages") do
			if stage >= 1 and stage <= STAGE_COUNT and stage <= unlocked then
				if not target or stage > target then
					target = stage
				end
			end
		end
	else
		target = math.clamp(unlocked, 1, STAGE_COUNT)
	end
	if not target then
		return
	end
	local pad = winPad(target)
	if not pad then
		return
	end
	local character = LocalPlayer.Character
	local root = getRoot()
	local far = not root or (root.Position - pad.Position).Magnitude > 10
	if parkedWinStage ~= target or parkedWinCharacter ~= character or far then
		parkedWinStage = target
		parkedWinCharacter = character
		teleportTo(pad, Vector3.new(0, 3, 0))
	end
	local now = os.clock()
	if now - lastWinTouchAt >= WIN_PAD_COOLDOWN then
		lastWinTouchAt = now
		touchPart(pad)
	end
end
function Farm.skipCutscene()
	if battleBusy and os.clock() - battleBusyAt > 45 then
		battleBusy = false
	end
	local fighting = battleBusy or getState().isBattling
	if not fighting and not isOn("AutoBattleInOrder") then
		return
	end
	restoreBattleCamera()
end
function Farm.refreshStageDropdown()
	local worldId = currentWorldId()
	if worldId == lastWorldId then
		return
	end
	lastWorldId = worldId
	local values = stageValues(worldId)
	if Options.SelectedStages then
		Options.SelectedStages:SetValues(values)
	end
end
local repo = ""
local Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
if getgenv then
	getgenv().__TempoPoopPerClickLib = Library
end
Toggles = Library.Toggles
Options = Library.Options
local function copyText(text, message)
	if setclipboard then
		setclipboard(text)
	elseif toclipboard then
		toclipboard(text)
	end
	Library:Notify(message)
end
local function copyDiscord()
	copyText(DISCORD_INVITE, "Copied Discord invite to clipboard")
end
local function AddDiscordButton(Tab)
	local DiscordGroup = Tab:AddLeftGroupbox("Discord")
	DiscordGroup:AddButton({
		Text = "Join Discord to Make Money",
		Func = copyDiscord,
	})
	DiscordGroup:AddButton({
		Text = "Join Discord for Keyless Scripts",
		Func = copyDiscord,
	})
end
local Window = Library:CreateWindow({
	Title = "Tempo",
	Font = Enum.Font.BuilderSans,
	Footer = {
		{ Text = DISCORD_INVITE, Copyable = true },
		"|",
		GAME_NAME,
	},
	Icon = 78539693571783,
	NotifySide = "Right",
	ShowCustomCursor = false,
	CornerRadius = 0,
	SidebarCompacted = true,
	TabSwipeFrom = "bottom",
	Animations = {
		TabSwitch = true,
	},
})
Window:SetGlow(true, {
	Color = Color3.fromRGB(242, 154, 196),
	Radius = 24,
	Transparency = 0.3,
})
local Tabs = {
	Info = Window:AddTab("Info", "info"),
	Main = Window:AddTab("Main", "gamepad-2"),
	Player = Window:AddTab("Player", "person-standing"),
	Settings = Window:AddTab("Settings", "settings"),
}
for name, Tab in Tabs do
	if name ~= "Info" then
		AddDiscordButton(Tab)
	end
end
local FarmGroup = Tabs.Main:AddLeftGroupbox("Farm", "trophy")
FarmGroup:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
FarmGroup:AddDropdown("WinMode", {
	Text = "Win Mode",
	Values = { WIN_MODE_BEST, WIN_MODE_SELECTED },
	Default = WIN_MODE_BEST,
})
FarmGroup:AddDropdown("SelectedStages", {
	Text = "Win Stages",
	Values = stageValues(currentWorldId()),
	Multi = true,
	Default = {},
	Expandable = true,
})
FarmGroup:AddDivider("Battle")
FarmGroup:AddToggle("AutoBattleInOrder", { Text = "Auto Battle In Order", Default = false })
local ProgressGroup = Tabs.Main:AddRightGroupbox("Progress", "trending-up")
ProgressGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ProgressGroup:AddDivider("Click")
ProgressGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
ProgressGroup:AddToggle("AutoBuyClick", { Text = "Auto Buy Click", Default = false })
ProgressGroup:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
ProgressGroup:AddDropdown("TrainToilet", {
	Text = "Toilet",
	Values = TOILET_LABELS,
	Default = TOILET_LABELS[1],
	Expandable = true,
})
ProgressGroup:AddDivider("Shop")
ProgressGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ProgressGroup:AddDropdown("UpgradeKinds", {
	Text = "Upgrades",
	Values = UPGRADE_LABELS,
	Multi = true,
	Default = { ["Walk Speed"] = true, ["Aura Luck"] = true },
	Expandable = true,
})
ProgressGroup:AddToggle("AutoRollAura", { Text = "Auto Roll Aura", Default = false })
lastWorldId = currentWorldId()
local function setupInfoTab()
	local GREEN = "#7fd47f"
	local BLUE = "#6ec1ff"
	local ORANGE = "#e8a34d"
	local GREY = "#8b93a3"
	local RED = "#e05a5a"
	local function colored(text, color)
		return string.format('<font color="%s">%s</font>', color, text)
	end
	local function field(key, value, color)
		return string.format("<b>%s</b> %s %s", key, colored("-", "#5a6070"), colored(value, color))
	end
	local function detectSupport()
		local flags = {
			hookfunction ~= nil,
			hookmetamethod ~= nil,
			getrawmetatable ~= nil,
			setrawmetatable ~= nil,
			getgc ~= nil,
			getgenv ~= nil,
			getreg ~= nil,
			getconnections ~= nil,
			firesignal ~= nil,
			getcallbackvalue ~= nil,
			setclipboard ~= nil,
			getcustomasset ~= nil,
			getnamecallmethod ~= nil,
			isexecutorclosure ~= nil,
			fireproximityprompt ~= nil,
			firetouchinterest ~= nil,
			WebSocket ~= nil,
			readfile ~= nil,
			writefile ~= nil,
			(request or http_request) ~= nil,
			(debug and debug.getupvalues) ~= nil,
			(debug and debug.setupvalue) ~= nil,
		}
		local available = 0
		for _, ok in ipairs(flags) do
			if ok then
				available += 1
			end
		end
		local ratio = available / #flags
		if ratio >= 0.9 then
			return colored("Full Support", GREEN)
		elseif ratio >= 0.6 then
			return colored("Half Support", ORANGE)
		else
			return colored("Low Support", RED)
		end
	end
	local executorName = "Unknown"
	pcall(function()
		if identifyexecutor then
			local name, version = identifyexecutor()
			if type(name) == "string" and name ~= "" then
				executorName = type(version) == "string" and version ~= "" and (name .. " " .. version) or name
			end
		end
	end)
	local supportText = detectSupport()
	local sessionStart = os.clock()
	local function sessionElapsed()
		local elapsed = math.floor(os.clock() - sessionStart)
		if elapsed < 60 then
			return elapsed .. "s"
		elseif elapsed < 3600 then
			return string.format("%dm %ds", math.floor((elapsed) / (60)), elapsed % 60)
		else
			return string.format("%dh %dm", math.floor((elapsed) / (3600)), math.floor(((elapsed % 3600)) / (60)))
		end
	end
	local UserGroup = Tabs.Info:AddLeftGroupbox("User", "circle-user")
	UserGroup:AddPlayerInfo("InfoUserCard", {
		Player = LocalPlayer,
		Title = "User",
		HeaderIcon = "user",
		Collapsible = false,
	})
	UserGroup:AddLabel(field("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, GREEN), true)
	UserGroup:AddLabel(field("UserId", tostring(LocalPlayer.UserId), BLUE), true)
	UserGroup:AddLabel(field("Executor", executorName .. "  " .. supportText, GREEN), true)
	UserGroup:AddDivider()
	local SessionLabel = UserGroup:AddLabel(field("Session", sessionElapsed(), ORANGE), true)
	UserGroup:AddDivider()
	UserGroup:AddButton({ Text = "Copy Username", Func = function() copyText(LocalPlayer.Name, "Copied username") end })
	UserGroup:AddButton({
		Text = "Copy Profile Link",
		Func = function()
			copyText("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
		end,
	})
	local SessionGroup = Tabs.Info:AddRightGroupbox("Session", "signal")
	SessionGroup:AddDivider("Server")
	SessionGroup:AddLabel(field("Game", GAME_NAME, BLUE), true)
	local PlayersLabel = SessionGroup:AddLabel(field("Players", "0/0", GREEN), true)
	local jobId = tostring(game.JobId)
	local shortJobId = #jobId > 18 and (string.sub(jobId, 1, 18) .. "...") or jobId
	SessionGroup:AddLabel(field("Job", shortJobId, GREY), true)
	local PingLabel = SessionGroup:AddLabel(field("Ping", "0 ms", ORANGE), true)
	SessionGroup:AddDivider()
	SessionGroup:AddButton({ Text = "Rejoin Server", Func = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
	SessionGroup:AddButton({ Text = "Copy Job ID", Func = function() copyText(jobId, "Copied Job ID") end })
	task.spawn(function()
		while true do
			task.wait(1)
			if Library.Unloaded then
				break
			end
			SessionLabel:SetText(field("Session", sessionElapsed(), ORANGE))
			PlayersLabel:SetText(field("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), GREEN))
			local ok, ping = pcall(function()
				return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			PingLabel:SetText(field("Ping", ok and (ping .. " ms") or "n/a", ORANGE))
		end
	end)
	local SocialsGroup = Tabs.Info:AddRightGroupbox("Socials", "link")
	SocialsGroup:AddButton({ Text = "Discord", Func = copyDiscord })
	SocialsGroup:AddButton({
		Text = "Rscripts",
		Func = function()
			if setclipboard then
				setclipboard(RSCRIPTS_LINK)
			elseif toclipboard then
				toclipboard(RSCRIPTS_LINK)
			end
			Library:Notify("Copied Rscripts profile to clipboard")
		end,
	})
	SocialsGroup:AddButton({ Text = "Website", Func = function() copyText(WEBSITE_LINK, "Copied website link") end })
end
local function setupPlayerTab()
	local MovementGroup = Tabs.Player:AddLeftGroupbox("Movement", "footprints")
	MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
	MovementGroup:AddSlider("WalkSpeed", {
		Text = "WalkSpeed Amount",
		Default = 32,
		Min = 16,
		Max = 250,
		Rounding = 0,
	})
	MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
	MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
	MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
	local FlyGroup = Tabs.Player:AddRightGroupbox("Fly", "feather")
	FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
	FlyGroup:AddSlider("FlySpeed", {
		Text = "Fly Speed",
		Default = 60,
		Min = 10,
		Max = 400,
		Rounding = 0,
	})
	track(RunService.Stepped:Connect(function()
		if Library.Unloaded then
			return
		end
		if Toggles.NoClip and Toggles.NoClip.Value then
			local character = LocalPlayer.Character
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end
	end))
	track(UserInputService.JumpRequest:Connect(function()
		if Library.Unloaded then
			return
		end
		if Toggles.InfJump and Toggles.InfJump.Value then
			local humanoid = getHumanoid()
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end))
	local Camera = Workspace.CurrentCamera
	track(RunService.RenderStepped:Connect(function(dt)
		if Library.Unloaded then
			return
		end
		if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
			local humanoid = getHumanoid()
			if humanoid then
				humanoid.WalkSpeed = Options.WalkSpeed.Value
			end
		end
		if Toggles.Fly and Toggles.Fly.Value then
			local root = getRoot()
			local humanoid = getHumanoid()
			if root and humanoid then
				humanoid.PlatformStand = true
				local direction = Vector3.zero
				Camera = Workspace.CurrentCamera
				if Camera then
					if UserInputService:IsKeyDown(Enum.KeyCode.W) then
						direction += Camera.CFrame.LookVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then
						direction -= Camera.CFrame.LookVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then
						direction -= Camera.CFrame.RightVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then
						direction += Camera.CFrame.RightVector
					end
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					direction += Vector3.new(0, 1, 0)
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
					direction -= Vector3.new(0, 1, 0)
				end
				root.AssemblyLinearVelocity = Vector3.zero
				if direction.Magnitude > 0 then
					root.CFrame += direction.Unit * Options.FlySpeed.Value * dt
				end
			end
		end
	end))
	Toggles.Fly:OnChanged(function()
		if not Toggles.Fly.Value then
			local humanoid = getHumanoid()
			if humanoid then
				humanoid.PlatformStand = false
			end
		end
	end)
	Toggles.WalkSpeedEnabled:OnChanged(function()
		if not Toggles.WalkSpeedEnabled.Value then
			local humanoid = getHumanoid()
			if humanoid then
				humanoid.WalkSpeed = 16
			end
		end
	end)
	local function applyInstantPrompt(prompt)
		if not prompt:IsA("ProximityPrompt") then
			return
		end
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 50
		prompt.RequiresLineOfSight = false
	end
	local instantPromptConnection
	Toggles.InstantProximityPrompt:OnChanged(function()
		if Toggles.InstantProximityPrompt.Value then
			for _, prompt in ipairs(Workspace:GetDescendants()) do
				pcall(applyInstantPrompt, prompt)
			end
			instantPromptConnection = Workspace.DescendantAdded:Connect(function(descendant)
				if Toggles.InstantProximityPrompt.Value then
					pcall(applyInstantPrompt, descendant)
				end
			end)
			track(instantPromptConnection)
		elseif instantPromptConnection then
			instantPromptConnection:Disconnect()
			instantPromptConnection = nil
		end
	end)
	Library:OnUnload(function()
		if instantPromptConnection then
			instantPromptConnection:Disconnect()
		end
	end)
end
local function setupMenuFeatures()
	local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "logs")
	MenuGroup:AddToggle("AntiAfk", {
		Text = "Anti-AFK",
		Default = true,
	})
	local antiAfkStat = MenuGroup:AddLabel("AFK triggers: 0")
	MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
	MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
	MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
	MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
	MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
	MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
		Default = "RightShift",
		NoUI = true,
		Text = "Menu keybind",
	})
	Library.ToggleKeybind = Options.MenuKeybind
	local antiAfkTriggerCount = 0
	local antiAfkLastPulse = tick()
	local function antiAfkTap()
		local camera = Workspace.CurrentCamera
		if not camera then
			return
		end
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(0, 0), camera.CFrame)
		antiAfkTriggerCount += 1
		antiAfkLastPulse = tick()
		pcall(function()
			antiAfkStat:SetText("AFK triggers: " .. antiAfkTriggerCount)
		end)
	end
	local antiAfkIdledConnection = LocalPlayer.Idled:Connect(function()
		if Toggles.AntiAfk.Value then
			pcall(antiAfkTap)
		end
	end)
	track(antiAfkIdledConnection)
	task.spawn(function()
		while not Library.Unloaded do
			task.wait(2)
			if Toggles.AntiAfk.Value and tick() - antiAfkLastPulse >= 60 then
				pcall(antiAfkTap)
			end
		end
	end)
	local function applyAntiGameplayPause(enabled)
		pcall(function()
			GuiService:SetGameplayPausedNotificationEnabled(not enabled)
		end)
		pcall(function()
			local notification = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
			if notification then
				notification.Enabled = not enabled
			end
		end)
		if not enabled then
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
	Toggles.AntiGameplayPause:OnChanged(function()
		applyAntiGameplayPause(Toggles.AntiGameplayPause.Value)
	end)
	task.spawn(function()
		while not Library.Unloaded do
			task.wait(1)
			if Toggles.AntiGameplayPause.Value then
				applyAntiGameplayPause(true)
			end
		end
	end)
	local reconnecting = false
	local function rejoin()
		if reconnecting then
			return
		end
		reconnecting = true
		local placeId, jobId = game.PlaceId, game.JobId
		local ok = pcall(function()
			TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
		end)
		if not ok then
			pcall(function()
				TeleportService:Teleport(placeId, LocalPlayer)
			end)
		end
	end
	task.spawn(function()
		local overlay = CoreGui:WaitForChild("RobloxPromptGui", 30)
		overlay = overlay and overlay:WaitForChild("promptOverlay", 30)
		if not overlay then
			return
		end
		track(overlay.ChildAdded:Connect(function(child)
			if Library.Unloaded then
				return
			end
			if Toggles.AutoReconnect.Value and child.Name == "ErrorPrompt" then
				rejoin()
			end
		end))
	end)
	track(TeleportService.TeleportInitFailed:Connect(function()
		if Toggles.AutoReconnect.Value then
			reconnecting = false
			rejoin()
		end
	end))
	Toggles.Disable3D:OnChanged(function()
		pcall(function()
			RunService:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
		end)
	end)
	local strippedClasses = {
		ParticleEmitter = true,
		Trail = true,
		Smoke = true,
		Fire = true,
		Sparkles = true,
		Explosion = true,
		Beam = true,
	}
	local function stripEffect(instance)
		if strippedClasses[instance.ClassName] then
			pcall(function()
				instance.Enabled = false
			end)
		end
	end
	local fpsBoostConnection
	Toggles.FpsBoost:OnChanged(function()
		if Toggles.FpsBoost.Value then
			pcall(function()
				settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			end)
			pcall(function()
				Lighting.GlobalShadows = false
			end)
			pcall(function()
				Lighting.FogEnd = 9e9
			end)
			for _, instance in ipairs(Workspace:GetDescendants()) do
				pcall(stripEffect, instance)
			end
			fpsBoostConnection = Workspace.DescendantAdded:Connect(function(instance)
				if Toggles.FpsBoost.Value then
					pcall(stripEffect, instance)
				end
			end)
			track(fpsBoostConnection)
		else
			pcall(function()
				settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
			end)
			pcall(function()
				Lighting.GlobalShadows = true
			end)
			if fpsBoostConnection then
				fpsBoostConnection:Disconnect()
				fpsBoostConnection = nil
			end
		end
	end)
	local ScriptGroup = Tabs.Settings:AddLeftGroupbox("Script", "terminal")
	ScriptGroup:AddButton({
		Text = "Unload Script",
		Func = function()
			Library:Unload()
		end,
	})
	Library:OnUnload(function()
		if antiAfkIdledConnection then
			antiAfkIdledConnection:Disconnect()
		end
		applyAntiGameplayPause(false)
		pcall(function()
			RunService:Set3dRenderingEnabled(true)
		end)
		pcall(function()
			RunService:UnbindFromRenderStep(CUTSCENE_BIND)
		end)
		if fpsBoostConnection then
			fpsBoostConnection:Disconnect()
		end
		for _, connection in connections do
			pcall(function()
				connection:Disconnect()
			end)
		end
		table.clear(connections)
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
			humanoid.WalkSpeed = 16
		end
		if getgenv then
			getgenv().__TempoPoopPerClickLib = nil
		end
	end)
end
local function setupConfigExport(ConfigurationBox)
	local function configElement(objectType, index)
		local holder = objectType == "Toggle" and Toggles or Options
		local element = holder[index]
		return type(element) == "table" and element.Type == objectType and element or nil
	end
	local function encodeConfigObject(index, element)
		local elementType = element.Type
		if elementType == "Toggle" then
			return { idx = index, type = "Toggle", value = element.Value == true }
		elseif elementType == "Slider" then
			return { idx = index, type = "Slider", value = tostring(element.Value) }
		elseif elementType == "Dropdown" then
			return { idx = index, type = "Dropdown", multi = element.Multi == true, value = element.Value }
		elseif elementType == "Input" then
			return { idx = index, type = "Input", text = tostring(element.Value or "") }
		elseif elementType == "ColorPicker" then
			return {
				idx = index,
				type = "ColorPicker",
				value = element.Value:ToHex(),
				transparency = element.Transparency,
			}
		elseif elementType == "KeyPicker" then
			return {
				idx = index,
				type = "KeyPicker",
				mode = element.Mode,
				key = element.Value,
				modifiers = element.Modifiers,
				toggled = element.Toggled,
			}
		end
		return nil
	end
	local function buildConfigPayload()
		local objects = {}
		for _, holder in ipairs({ Toggles, Options }) do
			for index, element in pairs(holder) do
				if type(element) == "table"
					and type(element.Type) == "string"
					and not SaveManager.Ignore[index]
				then
					local encoded = encodeConfigObject(index, element)
					if encoded then
						objects[#objects + 1] = encoded
					end
				end
			end
		end
		table.sort(objects, function(a, b)
			if a.type ~= b.type then
				return a.type < b.type
			end
			return a.idx < b.idx
		end)
		return { objects = objects }
	end
	local function applyConfigObject(object)
		if type(object) ~= "table"
			or type(object.idx) ~= "string"
			or type(object.type) ~= "string"
			or SaveManager.Ignore[object.idx]
		then
			return false
		end
		local element = configElement(object.type, object.idx)
		if not element then
			return false
		end
		local applied = pcall(function()
			if object.type == "Input" then
				if type(object.text) ~= "string" then
					return
				end
				element:SetValue(object.text)
			elseif object.type == "ColorPicker" then
				element:SetValueRGB(Color3.fromHex(object.value), object.transparency)
			elseif object.type == "KeyPicker" then
				element:SetValue({ object.key, object.mode, object.modifiers })
				if object.mode == "Toggle" and object.toggled ~= nil then
					element.Toggled = object.toggled
					element:Update()
				end
			else
				element:SetValue(object.value)
			end
		end)
		return applied
	end
	ConfigurationBox:AddDivider()
	ConfigurationBox:AddInput("SaveManager_ImportSource", {
		Text = "Paste exported config here",
		Finished = true,
		AllowEmpty = true,
	})
	ConfigurationBox:AddButton("Export Config to Clipboard", function()
		local encodeSuccess, encoded = pcall(HttpService.JSONEncode, HttpService, buildConfigPayload())
		if not encodeSuccess then
			Library:Notify("Failed to encode the config")
			return
		end
		local writeClipboard = setclipboard or toclipboard
		if type(writeClipboard) ~= "function" or not pcall(writeClipboard, encoded) then
			Library:Notify("Your executor does not support copying to the clipboard")
			return
		end
		Library:Notify("Config copied to clipboard", 6)
	end)
	ConfigurationBox:AddButton("Import Config from Clipboard Text", function()
		local source = tostring(Options.SaveManager_ImportSource.Value or ""):match("^%s*(.-)%s*$")
		if source == "" then
			Library:Notify("Paste an exported config into the box first")
			return
		end
		local decodeSuccess, decoded = pcall(HttpService.JSONDecode, HttpService, source)
		if not decodeSuccess or type(decoded) ~= "table" or type(decoded.objects) ~= "table" then
			Library:Notify("That is not a valid exported config")
			return
		end
		local applied = 0
		for _, object in ipairs(decoded.objects) do
			if applyConfigObject(object) then
				applied += 1
			end
		end
		if applied == 0 then
			Library:Notify("No settings in that config matched this script")
			return
		end
		Options.SaveManager_ImportSource:SetValue("")
		Library:Notify(("Imported %d setting%s"):format(applied, applied == 1 and "" or "s"), 6)
	end)
end
setupInfoTab()
setupPlayerTab()
setupMenuFeatures()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/PoopPerClick")
local ConfigurationBox = SaveManager:BuildConfigSection(Tabs.Settings)
setupConfigExport(ConfigurationBox)
SaveManager:LoadAutoloadConfig()
if Toggles.HideUiOnStart and Toggles.HideUiOnStart.Value then
	Library:Toggle(false)
end
local function farmLoop(interval, runner)
	task.spawn(function()
		while not Library.Unloaded do
			pcall(runner)
			task.wait(interval)
		end
	end)
end
farmLoop(CLICK_INTERVAL, Farm.click)
farmLoop(0.2, Farm.win)
farmLoop(0.35, Farm.battle)
farmLoop(0.4, Farm.buyClick)
farmLoop(0.35, Farm.train)
farmLoop(0.4, Farm.upgrades)
farmLoop(0.45, Farm.auras)
farmLoop(1, Farm.rebirth)
farmLoop(1, Farm.refreshStageDropdown)
pcall(function()
	RunService:BindToRenderStep(CUTSCENE_BIND, Enum.RenderPriority.Camera.Value + 1, function()
		if Library.Unloaded then
			return
		end
		Farm.skipCutscene()
	end)
end)
end)(...)
