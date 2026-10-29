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
getgenv().TempoHoodSubtitle = "BACKFLIP FOR ANIMALS!"
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
local FK_7
local tX
local uE
local tE
local ul
local tl
local t2
local tK
local ur
local tr
local t8
local s8
local tQ
local tx
local ue
local te
local tW
local uD
local tD
local tk
local Options
local tJ
local Library
local tq
local t7
local s7
local uw
local tw
local td
local tV
local uC
local tC
local tj
local t0
local tI
local up
local tp
local Toggles
local tO
local tv
local tc
local ui
local ti
local GameConfig
local uo
local to
local t5
local uu
local tu
local tb
local PlaytimeRewardsState
local uA
local tA
local uh
local th
local uG
local tG
local PlotConfig
local tn
local t4
local tM
local ut
local tt
local ua
local ta
local tS
local uz
local ug
local tg
local tY
local LocalPlayer
local tF
local um
local tm
local t3
local tL
local ts
local t9
local s9
local tR
local uy
local ty
local uf
function fns.fn9()
    local BT = t8("Collect")
    local BU = BT and BT:IsA("BasePart")
    if BU then
        tc(BT.Position)
    end
end
function fns.fn25(ht)
    local AU = ht and true or false
    tL.AutoEquipBest = AU
    if tL.AutoEquipBest then
        tJ("equipBest", 2, function()
            if tL.AutoEquipBest then
                th()
            end
        end)
    else
        tY("equipBest")
    end
end
function fns.fn47(ip)
    local BB = ip and true or false
    tL.AutoTreadmill = BB
    if tL.AutoTreadmill then
        tJ("treadmill", 1.2, function()
            if tL.AutoTreadmill then
                uw()
            end
        end)
    else
        tY("treadmill")
        ui("Treadmill", "leaveTreadmill")
    end
end
function fns.onCharacterAdded(kU)
    task.wait(0.2)
    if not ts() then
        return
    end
    local Humanoid = kU:FindFirstChildOfClass("Humanoid")
    if Humanoid and tL.WalkSpeedEnabled then
        t3[Humanoid] = Humanoid.WalkSpeed
        Humanoid.WalkSpeed = tL.WalkSpeedValue
    end
end
function fns.fn76(hm)
    local AQ = hm and true or false
    tL.AutoRebirth = AQ
    if tL.AutoRebirth then
        tJ("rebirth", 2.5, function()
            if tL.AutoRebirth then
                tG()
            end
        end)
    else
        tY("rebirth")
    end
end
function fns.fn108(c6)
    if not c6 then
        return false
    end
    local attr = c6:GetAttribute(uG.EggAttribute.EggId)
    if not t4(tS(attr), tL.PlaceRarities) then
        return false
    end
    uf(c6)
    task.wait(0.15)
    local xD_1 = t8("Plot")
    local xE = xD_1 and xD_1:IsA("BasePart")
    if xE then
        tc(xD_1.Position)
        task.wait(0.2)
    end
    local xD_2 = ta()
    if not xD_2 then
        return false
    end
    return ui("PlotEggs", "placeEgg", xD_2, c6)
end
function fns.fn109(ko)
    local Du = ko and true or false
    tL.Fly = Du
    if tt.Fly then
        tt.Fly:Disconnect()
        tt.Fly = nil
    end
    local Dt_1 = tD()
    if Dt_1 then
        local OuroFlyBV = Dt_1:FindFirstChild("OuroFlyBV")
        if OuroFlyBV then
            OuroFlyBV:Destroy()
        end
    end
    local Dt_2 = tq()
    if Dt_2 then
        Dt_2.PlatformStand = false
    end
    if not tL.Fly then
        return
    end
    tt.Fly = s7.RunService.RenderStepped:Connect(function()
        local Dj = not ts()
        local Ds = if Dj then 1 else 0
        local Dq = 3812 * Ds + 4014 * (1 - Ds)
        local Dr = 2796 * Ds + 3027 * (1 - Ds)
        if not ((Dq * 3332 + Dr * 485 + Dq * Dr) % 16777213 == 7938783) then
            Dj = not tL.Fly
        end
        if Dj then
            return
        end
        if s7.UserInputService:GetFocusedTextBox() then
            return
        end
        local Dj_1 = tD()
        local Dk = tq()
        local CurrentCamera = tj.CurrentCamera
        if not Dj_1 or not Dk or not CurrentCamera then
            return
        end
        local Dm_2 = Dj_1:FindFirstChild("OuroFlyBV")
        if not Dm_2 then
            Dm_2 = Instance.new("BodyVelocity")
            Dm_2.Name = "OuroFlyBV"
            Dm_2.MaxForce = Vector3.new(100000, 100000, 100000)
            Dm_2.Parent = Dj_1
        end
        local Dj_2 = Vector3.zero
        local LookVector = CurrentCamera.CFrame.LookVector
        local RightVector = CurrentCamera.CFrame.RightVector
        local Ds_1 = if s7.UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
        if Ds_1 == 1 then
            Dj_2 += LookVector
        end
        if s7.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            Dj_2 -= LookVector
        end
        if s7.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            Dj_2 -= RightVector
        end
        local Ds_2 = if s7.UserInputService:IsKeyDown(Enum.KeyCode.D) then 1 else 0
        if Ds_2 == 1 then
            Dj_2 += RightVector
        end
        if s7.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Dj_2 += Vector3.new(0, 1, 0)
        end
        if s7.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            Dj_2 -= Vector3.new(0, 1, 0)
        end
        if Dj_2.Magnitude > 0 then
            Dm_2.Velocity = Dj_2.Unit * tL.FlySpeed
        else
            Dm_2.Velocity = Vector3.zero
        end
        Dk.PlatformStand = true
    end)
end
function fns.fn112()
    local attr = LocalPlayer:GetAttribute(uG.PlayerAttribute.PlotId)
    if type(attr) == "number" then
        return attr
    end
    return nil
end
function fns.fn127()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then
        return false
    end
    local y9 = false
    for i, descendant in ipairs(PlayerGui:GetDescendants()) do
        local y8_1 = descendant:IsA("GuiButton") and descendant.Name == "Boost" and descendant.Visible
        if y8_1 then
            local AbsoluteSize = descendant.AbsoluteSize
            if AbsoluteSize.X > 20 and AbsoluteSize.Y > 20 then
                if to(descendant) then
                end
                ui("Treadmill", "claimBoost")
                y9 = true
                break
            end
        end
    end
    return y9
end
function fns.fn177(h1)
    local Bm = h1 and true or false
    tL.AutoUpgradeCollector = Bm
    if tL.AutoUpgradeCollector then
        tJ("collector", 5, function()
            if tL.AutoUpgradeCollector then
                t5()
            end
        end)
    else
        tY("collector")
    end
end
function fns.fn181()
    ui("Plots", "requestSendToPlot")
    local BN = t8("Plot")
    local BO = BN and BN:IsA("BasePart")
    if BO then
        tc(BN.Position)
    end
end
function fns.fn201()
    local Ae = t8("Treadmill")
    local Af = Ae and Ae:IsA("BasePart")
    if Af then
        tc(Ae.Position)
        task.wait(0.25)
    end
    ui("Treadmill", "enterTreadmill")
end
function fns.fn211()
    return not tR.Unloaded
end
function fns.fn222(lj, lk, ll)
    return string.format("<b>%s</b> %s %s", lj, tr("-", "#5a6070"), tr(lk, ll))
end
function fns.fn224(hT)
    local A8 = hT and true or false
    tL.SellKeepEquipped = A8
end
function fns.fn235(a7, a8)
    if not tu(a8) then
        return true
    end
    local v7 = tl(a8)
    return a7 ~= nil and v7[a7] == true
end
function fns.fn237(jK)
    local CO = jK and true or false
    tL.WalkSpeedEnabled = CO
    local CN_1 = tq()
    if not CN_1 then
        return
    end
    if tL.WalkSpeedEnabled then
        if t3[CN_1] == nil then
            t3[CN_1] = CN_1.WalkSpeed
        end
        CN_1.WalkSpeed = tL.WalkSpeedValue
    else
        tp(CN_1)
    end
end
function fns.fn245()
    if tA() then
        return tI()
    end
    local yc = #tn() > 0 and tL.AutoPlace
    if yc then
        return tm()
    end
    local yc_1 = uu()
    if #yc_1 == 0 then
        return false
    end
    local yd = yc_1[1]
    tc(yd.Part.Position)
    task.wait(0.3)
    tK(yd.Prompt)
    local yc_2 = os.clock() + 3
    while true do
        local yd_1 = ts() and os.clock() < yc_2
        if not yd_1 then
            local yc_3 = tA() or #tn() > 0
            return yc_3
        end
        if tA() then
            break
        end
        task.wait(0.1)
    end
    return tI()
end
function fns.fn248()
    local BW = t8("Treadmill")
    local BX = BW and BW:IsA("BasePart")
    if BX then
        tc(BW.Position)
    end
end
function fns.fn251()
    ul(tV.Main)
    local AutoStealGroup = tV.Main:AddLeftGroupbox("Auto Steal", "egg")
    AutoStealGroup:AddToggle("AutoStealEggs", { Text = "Auto Steal", Default = false })
    AutoStealGroup:AddDropdown("ZoneFilter", { Text = "Zones", Values = tF, Multi = true, AllowNull = true, Default = tF })
    AutoStealGroup:AddDropdown("StealRarityFilter", { Text = "Rarities", Values = ti, Multi = true, AllowNull = true, Default = ti })
    local Place_HatchGroup = tV.Main:AddLeftGroupbox("Place & Hatch", "package")
    Place_HatchGroup:AddToggle("AutoPlaceEggs", { Text = "Auto Place", Default = false })
    Place_HatchGroup:AddDropdown("PlaceRarityFilter", { Text = "Place Rarities", Values = ti, Multi = true, AllowNull = true, Default = ti })
    Place_HatchGroup:AddToggle("AutoHatchEggs", { Text = "Auto Hatch", Default = false })
    Place_HatchGroup:AddToggle("AutoEquipBestAnimals", { Text = "Auto Equip Best", Default = false })
    local UpgradesGroup = tV.Main:AddLeftGroupbox("Upgrades", "wrench")
    UpgradesGroup:AddToggle("AutoUpgradeCollector", { Text = "Auto Upgrade Collector", Default = false })
    UpgradesGroup:AddToggle("AutoUpgradePlot", { Text = "Auto Upgrade Plot", Default = false })
    UpgradesGroup:AddToggle("AutoUpgradeTreadmill", { Text = "Auto Upgrade Treadmill", Default = false })
    UpgradesGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
    UpgradesGroup:AddToggle("AutoGoOnTreadmill", { Text = "Auto Go On Treadmill", Default = false })
    UpgradesGroup:AddToggle("AutoTreadmill2x", { Text = "Auto 2x", Default = false })
    local Money_ProgressGroup = tV.Main:AddRightGroupbox("Money & Progress", "circle-dollar-sign")
    Money_ProgressGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
    Money_ProgressGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
    Money_ProgressGroup:AddToggle("AutoClaimPlaytime", { Text = "Auto Claim Playtime", Default = false })
    Money_ProgressGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    local AutoSellGroup = tV.Main:AddRightGroupbox("Auto Sell", "tags")
    AutoSellGroup:AddToggle("AutoSellAnimals", { Text = "Auto Sell", Default = false })
    AutoSellGroup:AddDropdown("SellRarityFilter", {
        Text = "Sell Rarities",
        Values = ti,
        Multi = true,
        AllowNull = true,
        Default = { "Common", "Uncommon", "Rare" }
    })
    AutoSellGroup:AddSlider("SellKeepTop", { Text = "Keep Top Animals", Default = 3, Min = 0, Max = 20, Rounding = 0 })
    AutoSellGroup:AddToggle("SellKeepEquipped", { Text = "Keep Equipped", Default = true })
    Toggles.AutoStealEggs:OnChanged(function(mF)
        tR.SetAutoSteal(mF)
    end)
    Options.ZoneFilter:OnChanged(function(mJ)
        tR.SetSelectedZones(mJ)
    end)
    Options.StealRarityFilter:OnChanged(function(mL)
        tR.SetStealRarities(mL)
    end)
    Toggles.AutoPlaceEggs:OnChanged(function(mN)
        tR.SetAutoPlace(mN)
    end)
    Options.PlaceRarityFilter:OnChanged(function(mP)
        tR.SetPlaceRarities(mP)
    end)
    Toggles.AutoHatchEggs:OnChanged(function(mR)
        tR.SetAutoHatch(mR)
    end)
    Toggles.AutoEquipBestAnimals:OnChanged(function(mT)
        tR.SetAutoEquipBest(mT)
    end)
    Toggles.AutoUpgradeCollector:OnChanged(function(mV)
        tR.SetAutoUpgradeCollector(mV)
    end)
    Toggles.AutoUpgradePlot:OnChanged(function(mX)
        tR.SetAutoUpgradePlot(mX)
    end)
    Toggles.AutoUpgradeTreadmill:OnChanged(function(mZ)
        tR.SetAutoUpgradeTreadmill(mZ)
    end)
    Toggles.AutoBuyTrails:OnChanged(function(m0)
        tR.SetAutoBuyTrails(m0)
    end)
    Toggles.AutoGoOnTreadmill:OnChanged(function(m2)
        tR.SetAutoTreadmill(m2)
    end)
    Toggles.AutoTreadmill2x:OnChanged(function(m4)
        tR.SetAutoTreadmill2x(m4)
    end)
    Toggles.AutoCollectMoney:OnChanged(function(m6)
        tR.SetAutoCollect(m6)
    end)
    Toggles.AutoClaimIndex:OnChanged(function(m8)
        tR.SetAutoClaimIndex(m8)
    end)
    Toggles.AutoClaimPlaytime:OnChanged(function(na)
        tR.SetAutoClaimPlaytime(na)
    end)
    Toggles.AutoRebirth:OnChanged(function(nc)
        tR.SetAutoRebirth(nc)
    end)
    Toggles.AutoSellAnimals:OnChanged(function(ne)
        tR.SetAutoSell(ne)
    end)
    Options.SellRarityFilter:OnChanged(function(ng)
        tR.SetSellRarities(ng)
    end)
    Options.SellKeepTop:OnChanged(function(ni)
        tR.SetSellKeepTop(ni)
    end)
    Toggles.SellKeepEquipped:OnChanged(function(nk)
        tR.SetSellKeepEquipped(nk)
    end)
end
function fns.fn258()
    for k in pairs(uo) do
        uo[k] = nil
    end
    for k, v in pairs(tt) do
        if typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        end
    end
    table.clear(tt)
    ui("Treadmill", "leaveTreadmill")
    tR.SetWalkSpeedEnabled(false)
    tR.SetNoClip(false)
    tR.SetFly(false)
    tR.SetInfJump(false)
    tR.SetInstantProximityPrompt(false)
end
function fns.fn264(jV)
    local C0 = jV and true or false
    tL.InfJump = C0
    if tt.InfJump then
        tt.InfJump:Disconnect()
        tt.InfJump = nil
    end
    if not tL.InfJump then
        return
    end
    tt.InfJump = s7.UserInputService.JumpRequest:Connect(function()
        local CY = not ts() or not tL.InfJump
        if CY then
            return
        end
        local CY_1 = tq()
        if CY_1 then
            CY_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
function fns.fn272(hV)
    local Bi = hV and true or false
    tL.AutoCollect = Bi
    if tL.AutoCollect then
        tJ("collect", 1.2, function()
            if tL.AutoCollect then
                uA()
            end
        end)
    else
        tY("collect")
    end
end
function fns.fn305(gH)
    local Ao = tO(gH)
    local Ap = {}
    for k in pairs(Ao) do
        local Ao_1 = tC[k]
        if Ao_1 then
            Ap[Ao_1] = true
            Ap[tostring(Ao_1)] = true
        end
    end
    tL.SelectedZones = Ap
end
function fns.fn320(hA)
    local AY = hA and true or false
    tL.AutoBuyTrails = AY
    if tL.AutoBuyTrails then
        tJ("trails", 2, function()
            if tL.AutoBuyTrails then
                tk()
            end
        end)
    else
        tY("trails")
    end
end
function fns.fn351(ca, cb)
    if not ca then
        return nil
    end
    for i, descendant in ipairs(ca:GetDescendants()) do
        local wX = (descendant:IsA("ProximityPrompt"))
        if wX then
            local wY = not cb or cb(descendant)
            wX = wY
        end
        if wX then
            return descendant
        end
    end
    return nil
end
function fns.fn368()
    local z5 = tv({ "plot", "capacity" })
    local z6 = PlotConfig.upgradeCost(z5)
    if not z6 then
        return
    end
    local z5_1 = tv("cash") or 0
    if z5_1 < z6 then
        return
    end
    ui("PlotUpgrades", "upgradePlot")
end
function fns.fn380()
    local xX = {}
    for i, v in ipairs(s7.CollectionService:GetTagged(uG.Tag.EggAnchor)) do
        local xY = v:IsA("BasePart") and v:GetAttribute(uG.EggAttribute.State) == uG.EggState.Nest
        if xY then
            local attr = v:GetAttribute(uG.EggAttribute.EggId)
            local xZ = tE(v:GetAttribute(uG.EggAttribute.SpawnId))
            local x_ = xZ and uz(xZ) and t4(tS(attr), tL.StealRarities)
            if x_ then
                local x__1 = tg(v, function(dJ)
                    local xU = dJ:GetAttribute(uG.PromptAttribute.Id) == uG.PromptId.StealEgg or dJ.ActionText == "Steal"
                    return xU
                end)
                if x__1 and x__1.Enabled then
                    local insert = table.insert
                    local x1 = tonumber(v:GetAttribute(uG.EggAttribute.Scale)) or 0
                    insert(xX, { Part = v, Prompt = x__1, Scale = x1, Platform = xZ, EggId = attr })
                end
            end
        end
    end
    table.sort(xX, function(dO, dP)
        if dO.Platform ~= dP.Platform then
            return dO.Platform > dP.Platform
        end
        return dO.Scale > dP.Scale
    end)
    return xX
end
local function fn397()
    ui("AnimalInventory", "equipBestAnimals")
end
local function fn414(gP)
    tL.StealRarities = tO(gP)
end
local function fn462(T)
    return type(T) == "function"
end
local function fn477(...)
    local wy_1
    local wx_1
    wx_1, wy_1 = pcall(function(...)
        return s9:get(...)
    end, ...)
    if wx_1 then
        return wy_1
    end
    return nil
end
local function fn484()
    local zl = tv("rebirths")
    local zm = t2.costFor(zl)
    if not zm then
        return
    end
    local zl_1 = (tv("cash"))
    local zr = if zl_1 then 1 else 0
    local zp = 3002 * zr + 2710 * (1 - zr)
    local zq = 847 * zr + 3782 * (1 - zr)
    if not ((zp * 1627 + zq * 1762 + zp * zq) % 16777213 == 8919362) then
        zl_1 = 0
    end
    if zl_1 >= zm then
        ui("Rebirth", "requestRebirth")
    end
end
local function fn546()
    local zz = tv({ "plot", "animals" })
    if type(zz) ~= "table" then
        return
    end
    local zA = tQ()
    local zB = {}
    for k, v in pairs(zz) do
        local zz_1 = type(v) == "table" and type(v.animalId) == "string"
        if zz_1 then
            local zz_2 = um(v.animalId)
            if t4(zz_2, tL.SellRarities) then
                table.insert(zB, {
                    Key = k,
                    Income = uC.ownRate(v.animalId, v.scale, v.mutation),
                    Equipped = zA[k] == true,
                    Rarity = zz_2
                })
            end
        end
    end
    table.sort(zB, function(fD, fE)
        return fD.Income > fE.Income
    end)
    local max = math.max
    local floor = math.floor
    local zC = tonumber(tL.SellKeepTop) or 0
    local zD = max(0, floor(zC))
    local zz_4 = {}
    local zA_2 = math.min(zD, #zB)
    local zQ = 1
    while zQ <= zA_2 do
        local zR = zQ
        zz_4[zB[zR].Key] = true
        zQ += 1
    end
    for i, v in ipairs(zB) do
        if not zz_4[v.Key] then
            if not (tL.SellKeepEquipped and v.Equipped) then
                if v.Equipped then
                    ui("AnimalInventory", "unequipAnimal", v.Key)
                    task.wait(0.25)
                end
                ui("AnimalInventory", "sellAnimal", v.Key)
                task.wait(0.3)
            end
        end
    end
end
local function fn556(aT)
    for k in pairs(aT) do
        return true
    end
    return false
end
local function fn573(lr)
    local DiscordGroup = lr:AddLeftGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = ur,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    return DiscordGroup
end
local function fn591()
    if tA() then
        tI()
    end
    local xM = tn()
    for i, v in ipairs(xM) do
        if uh(v) then
            task.wait(0.35)
            return true
        end
    end
    return false
end
local function fn596(ih)
    local Bu = ih and true or false
    tL.AutoUpgradeTreadmill = Bu
    if tL.AutoUpgradeTreadmill then
        tJ("treadUpgrade", 1.8, function()
            if tL.AutoUpgradeTreadmill then
                td()
            end
        end)
    else
        tY("treadUpgrade")
    end
end
local function fn597()
    local zZ = t8("Collect")
    local z_ = zZ and zZ:IsA("BasePart")
    if z_ then
        tc(zZ.Position)
        task.wait(0.45)
    end
end
local function fn602(bW)
    local wM = uE()
    local wN = wM and wM:FindFirstChild(bW, true)
    return wN
end
local function fn634(gA)
    local Am = gA and true or false
    tL.AutoSteal = Am
    if tL.AutoSteal then
        tJ("steal", 0.85, function()
            if tL.AutoSteal then
                uD()
            end
        end)
    else
        tY("steal")
    end
end
local function fn636()
    local B7 = tj:FindFirstChild("Pads") and tj.Pads:FindFirstChild("Trails")
    local B8 = B7
    if B7 then
        B7 = B8:IsA("BasePart")
    end
    if B7 then
        tc(B8.Position)
    end
end
local function fn651()
    if tW.owns(LocalPlayer, GameConfig.DOUBLE_CASH_GAMEPASS_ID) then
        return
    end
    local z4 = if os.clock() - tX < 20 then 1 else 0
    if z4 == 1 then
        return
    end
    tX = os.clock()
    pcall(function()
        s7.MarketplaceService:PromptGamePassPurchase(LocalPlayer, GameConfig.DOUBLE_CASH_GAMEPASS_ID)
    end)
end
local function fn653(gZ)
    tL.PlaceRarities = tO(gZ)
end
local function fn664(Q)
    local vF = typeof(cloneref) == "function" and typeof(Q) == "Instance"
    if vF then
        return cloneref(Q)
    end
    return Q
end
local function fn668()
    local xx = t8("Plot")
    local xy = xx and xx:IsA("BasePart")
    if xy then
        return xx.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
    end
    local xx_1 = tD()
    return xx_1 and xx_1.Position
end
local function fn691()
    local B1 = tj:FindFirstChild("Pads") and tj.Pads:FindFirstChild("Sell")
    local B2 = B1
    if B1 then
        B1 = B2:IsA("BasePart")
    end
    if B1 then
        tc(B2.Position)
    end
end
local function fn695(a2)
    local v6 = if not tu(tL.SelectedZones) then 1 else 0
    if v6 == 1 then
        return true
    end
    local v2 = tL.SelectedZones[tostring(a2)] == true
    local v6_1 = if v2 then 1 else 0
    local v4 = 3244 * v6_1 + 3832 * (1 - v6_1)
    local v5 = 1203 * v6_1 + 1432 * (1 - v6_1)
    if not ((v4 * 3669 + v5 * 2260 + v4 * v5) % 16777213 == 1746335) then
        v2 = tL.SelectedZones[a2] == true
    end
    return v2
end
local function fn699(g8)
    local AI = g8 and true or false
    tL.AutoClaimIndex = AI
    if tL.AutoClaimIndex then
        tJ("index", 2.5, function()
            if tL.AutoClaimIndex then
                s8()
            end
        end)
    else
        tY("index")
    end
end
local function fn713()
    local Ab = tv({ "plot", "treadmillLevel" })
    local Ac = ue.upgradeCost(Ab)
    if not Ac then
        return
    end
    local Ab_1 = tv("cash") or 0
    if Ab_1 < Ac then
        return
    end
    ui("Treadmill", "upgradeTreadmill")
end
local function fn714(hO)
    tL.SellRarities = tO(hO)
end
local function fn729(ix)
    local BL = ix and true or false
    tL.AutoTreadmill2x = BL
    if tL.AutoTreadmill2x then
        tJ("treadmill2x", 0.2, function()
            if tL.AutoTreadmill2x then
                uy()
            end
        end)
    else
        tY("treadmill2x")
    end
end
local function fn734()
    local zs = tv("trails")
    local zt = type(zs) == "table" and zs.owned
    local zt_1 = zt or nil
    local zs_2 = tv("cash") or 0
    local zs_3 = ua.affordableUpgrade(zt_1, zs_2)
    if not zs_3 then
        return
    end
    ui("Trails", "buyTrail", zs_3.id)
    task.wait(0.25)
    ui("Trails", "equipTrail", zs_3.id)
end
local function fn774()
    gethui = t7
end
local function fn785(hf)
    local AM = hf and true or false
    tL.AutoClaimPlaytime = AM
    if tL.AutoClaimPlaytime then
        tJ("playtime", 2.5, function()
            if tL.AutoClaimPlaytime then
                t9()
            end
        end)
    else
        tY("playtime")
    end
end
local function fn797(k8, k9)
    local DP = false
    if type(setclipboard) == "function" then
        DP = pcall(setclipboard, k8)
    elseif type(toclipboard) == "function" then
        DP = pcall(toclipboard, k8)
    end
    if DP and k9 then
        Library:Notify(k9, 2)
    elseif not DP then
        Library:Notify("Clipboard unavailable", 2)
    end
end
local function fn801(aN)
    local vH = {}
    if type(aN) ~= "table" then
        return vH
    end
    for k, v in pairs(aN) do
        if v == true then
            vH[tostring(k)] = true
        else
            local vI = type(k) == "number" and type(v) == "string"
            if vI then
                vH[v] = true
            end
        end
    end
    return vH
end
local function fn809()
    local yF = tv("discoveredAnimals")
    local yG = tv("claimedAnimalRewards")
    local claimable = ut.claimable
    local yI = type(yF) == "table" and yF
    local yF_1 = {}
    local yJ = yI
    local yN = if yJ then 1 else 0
    local yL = 1097 * yN + 3559 * (1 - yN)
    local yM = 430 * yN + 2424 * (1 - yN)
    if not ((yL * 2698 + yM * 2168 + yL * yM) % 16777213 == 4363656) then
        yJ = yF_1
    end
    local yF_2 = type(yG) == "table" and yG
    local yI_1 = yF_2 or {}
    local yF_3 = claimable(yJ, yI_1)
    local yG_2 = type(yF_3) == "table" and #yF_3 > 0
    if yG_2 then
        ui("Index", "claimAllRewards")
    end
end
local function fn820()
    local yv, yw, yx
    local yt = {}
    local yu = te()
    if not yu then
        return yt
    end
    local yA = false
    for i, v in ipairs(s7.CollectionService:GetTagged(uG.Tag.PlotAnimal)) do
        local yz = 5
        while true do
            if yz < 7 then
                if yz < 3 then
                    if yz < 1 then
                        yt[yw] = true
                        yz = 12
                    elseif yz < 2 then
                        yw = yv ~= tj
                        yx = yv
                        yz = if yx then 14 else 3
                    else
                        yw = v:GetAttribute(uG.AnimalAttribute.Key)
                        yz = if type(yw) == "string" then 0 else 12
                    end
                elseif yz < 5 then
                    if yz < 4 then
                        yz = if yx then 11 else 9
                    else
                        yz = 7
                    end
                elseif yz < 6 then
                    yv = v
                    yz = 7
                else
                    yz = 13
                end
            elseif yz < 11 then
                if yz < 9 then
                    if yz < 8 then
                        yz = 1
                    else
                        yv = yv.Parent
                        yz = 4
                    end
                elseif yz < 10 then
                    yz = 6
                else
                    yA = true
                    yz = 13
                end
            elseif yz < 13 then
                if yz < 12 then
                    yz = if yv:GetAttribute(uG.PlotAttribute.PlotId) == yu then 2 else 8
                else
                    yz = 6
                end
            elseif yz < 14 then
                break
            else
                yx = yw
                yz = 3
            end
        end
        if yA then
            break
        end
    end
    return yt
end
local function fn824(cr)
    if type(cr) ~= "string" then
        return nil
    end
    return tonumber(string.match(cr, "^(%d+)"))
end
local function fn839(lf, lg)
    return string.format('<font color="%s">%s</font>', lg, ty(lf))
end
local function fn857(g1)
    local AE = g1 and true or false
    tL.AutoHatch = AE
    if tL.AutoHatch then
        tJ("hatch", 1.2, function()
            if tL.AutoHatch then
                tw()
            end
        end)
    else
        tY("hatch")
    end
end
local function fn929(ld)
    return (tostring(ld):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end
local function fn931(gS)
    local AA = gS and true or false
    tL.AutoPlace = AA
    if tL.AutoPlace then
        tJ("place", 0.9, function()
            if tL.AutoPlace then
                tm()
            end
        end)
    else
        tY("place")
    end
end
local function fn965(hR)
    local A5 = tonumber(hR) or 0
    tL.SellKeepTop = math.max(0, math.floor(A5))
end
local function fn972(i8)
    if not i8:IsA("ProximityPrompt") then
        return
    end
    if ug[i8] == nil then
        ug[i8] = {
            HoldDuration = i8.HoldDuration,
            MaxActivationDistance = i8.MaxActivationDistance,
            RequiresLineOfSight = i8.RequiresLineOfSight
        }
    end
    if tL.InstantPrompt then
        i8.HoldDuration = 0
        i8.MaxActivationDistance = 50
        i8.RequiresLineOfSight = false
    else
        local Cg = ug[i8]
        if Cg then
            i8.HoldDuration = Cg.HoldDuration
            i8.MaxActivationDistance = Cg.MaxActivationDistance
            i8.RequiresLineOfSight = Cg.RequiresLineOfSight
        end
    end
end
local function fn987(ci)
    local w5 = ci and uC.Animals[ci]
    local w6 = w5
    if w5 then
        w5 = w6.rarity
    end
    return w5 or nil
end
local function fn1010(gi)
    uo[gi] = nil
end
local function fn1030()
    return s7.CoreGui
end
local function fn1061()
    local attr = LocalPlayer:GetAttribute(uG.PlayerAttribute.CarryingEgg)
    local xa = attr ~= ""
    local xb = type(attr) == "string" and xa
    return xb
end
local function fn1064()
    local Character = LocalPlayer.Character
    local we = Character and Character:FindFirstChild("HumanoidRootPart")
    return we
end
local function fn1104(jQ)
    local CQ = tonumber(jQ) or 32
    tL.WalkSpeedValue = CQ
    if tL.WalkSpeedEnabled then
        local CQ_1 = tq()
        if CQ_1 then
            if t3[CQ_1] == nil then
                t3[CQ_1] = CQ_1.WalkSpeed
            end
            CQ_1.WalkSpeed = tL.WalkSpeedValue
        end
    end
end
local function fn1130(hH)
    local A1 = hH and true or false
    tL.AutoSell = A1
    if tL.AutoSell then
        tJ("sell", 2, function()
            if tL.AutoSell then
                up()
            end
        end)
    else
        tY("sell")
    end
end
local function fn1132()
    local yh, yi, yj, yk, yl
    local yf = te()
    if not yf then
        return
    end
    local yg = tj:GetServerTimeNow()
    local yo = false
    for i, v in ipairs(s7.CollectionService:GetTagged(uG.Tag.PlacedEgg)) do
        local yn = 3
        while true do
            if yn < 11 then
                if yn < 5 then
                    if yn < 2 then
                        if yn < 1 then
                            yk = type(yi) == "string"
                            yn = 15
                        else
                            yn = 6
                        end
                    elseif yn < 3 then
                        yi = yh ~= tj
                        yj = yh
                        yn = if yj then 18 else 10
                    elseif yn < 4 then
                        yn = if v:IsA("BasePart") then 11 else 6
                    else
                        yo = true
                        yn = 21
                    end
                elseif yn < 8 then
                    if yn < 6 then
                        yj = type(yk) == "number"
                        yn = if yj then 14 else 13
                    elseif yn < 7 then
                        yn = 21
                    else
                        yn = 19
                    end
                elseif yn < 9 then
                    yn = 1
                elseif yn < 10 then
                    ui("PlotEggs", "hatchEgg", yi)
                    task.wait(0.2)
                    yn = 8
                else
                    yn = if yj then 16 else 12
                end
            elseif yn < 17 then
                if yn < 14 then
                    if yn < 12 then
                        yh = v
                        yn = 19
                    elseif yn < 13 then
                        yn = 1
                    else
                        yl = yj
                        yn = 17
                    end
                elseif yn < 15 then
                    yj = yk <= yg
                    yn = 13
                elseif yn < 16 then
                    yn = if yk then 9 else 8
                else
                    yn = if yh:GetAttribute(uG.PlotAttribute.PlotId) == yf then 22 else 20
                end
            elseif yn < 20 then
                if yn < 18 then
                    yj = yl
                    yk = yj
                    yn = if yk then 0 else 15
                elseif yn < 19 then
                    yj = yi
                    yn = 10
                else
                    yn = 2
                end
            elseif yn < 21 then
                yh = yh.Parent
                yn = 7
            elseif yn < 22 then
                break
            else
                yi = v:GetAttribute(uG.EggAttribute.PlacedId)
                yj = v:GetAttribute(uG.EggAttribute.State)
                yk = v:GetAttribute(uG.EggAttribute.HatchAt)
                yl = yj == uG.EggState.Ready
                yn = if yl then 17 else 5
            end
        end
        if yo then
            break
        end
    end
end
local function fn1144(j5)
    local Db = j5 and true or false
    tL.NoClip = Db
    if tt.NoClip then
        tt.NoClip:Disconnect()
        tt.NoClip = nil
    end
    local Character2 = LocalPlayer.Character
    if not tL.NoClip then
        if Character2 then
            for i, descendant in ipairs(Character2:GetDescendants()) do
                local Da_2 = descendant:IsA("BasePart") and t0[descendant] ~= nil
                if Da_2 then
                    descendant.CanCollide = t0[descendant]
                end
            end
        end
        return
    end
    tt.NoClip = s7.RunService.Stepped:Connect(function()
        local C2 = not ts() or not tL.NoClip
        if C2 then
            return
        end
        local Character = LocalPlayer.Character
        if not Character then
            return
        end
        for i, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if t0[descendant] == nil then
                    t0[descendant] = descendant.CanCollide
                end
                descendant.CanCollide = false
            end
        end
    end)
end
local function fn1179()
    ul(tV.Player)
    local MovementGroup = tV.Player:AddLeftGroupbox("Movement", "person-standing")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "Noclip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = tV.Player:AddRightGroupbox("Fly", "plane")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    Toggles.WalkSpeedEnabled:OnChanged(function(nK)
        tR.SetWalkSpeedEnabled(nK)
    end)
    Options.WalkSpeed:OnChanged(function(nO)
        tR.SetWalkSpeedValue(nO)
    end)
    Toggles.InfJump:OnChanged(function(nQ)
        tR.SetInfJump(nQ)
    end)
    Toggles.NoClip:OnChanged(function(nS)
        tR.SetNoClip(nS)
    end)
    Toggles.InstantProximityPrompt:OnChanged(function(nU)
        tR.SetInstantProximityPrompt(nU)
    end)
    Toggles.Fly:OnChanged(function(nW)
        tR.SetFly(nW)
    end)
    Options.FlySpeed:OnChanged(function(nY)
        tR.SetFlySpeed(nY)
    end)
end
local function fn1203()
    local yO = tv("playtimeRewards")
    if type(yO) ~= "table" then
        yO = {}
    end
    local sessionStart = PlaytimeRewardsState.sessionStart
    local yQ = 0
    local yR = type(sessionStart) == "number" and sessionStart > 0
    if yR then
        yQ = math.max(0, os.time() - sessionStart)
    end
    for i, v in ipairs(tM) do
        local yP_1 = yO[tostring(i)] ~= true and yQ >= v
        if yP_1 then
            ui("PlaytimeRewards", "claim", i)
            task.wait(1.1)
            yO = tv("playtimeRewards")
            if type(yO) ~= "table" then
                yO = {}
            end
        end
    end
end
local function fn1209()
    local wF = te()
    if not wF then
        return nil
    end
    local Plots = tj:FindFirstChild("Plots")
    local wH = Plots and Plots:FindFirstChild(tostring(wF))
    return wH
end
local function fn1225(i0)
    local Platforms = tj:FindFirstChild("Platforms")
    local Cb = Platforms and Platforms:FindFirstChild(tostring(i0))
    if not Cb then
        return
    end
    local BasePart = Cb:FindFirstChildWhichIsA("BasePart", true)
    if BasePart then
        tc(BasePart.Position)
    end
end
local function fn1259(aW)
    local vV = {}
    for k in pairs(aW) do
        local vW = tb[k] or string.lower(k)
        if vW then
            vV[vW] = true
        end
    end
    return vV
end
local function fn1272(co)
    return um(co)
end
local function fn1289(jH)
    if not jH then
        return
    end
    local CL = t3[jH]
    if CL ~= nil then
        jH.WalkSpeed = CL
    end
end
local function fn1303(h8)
    local Bq = h8 and true or false
    tL.AutoUpgradePlot = Bq
    if tL.AutoUpgradePlot then
        tJ("plotUpgrade", 1.8, function()
            if tL.AutoUpgradePlot then
                tx()
            end
        end)
    else
        tY("plotUpgrade")
    end
end
local function fn1305(kO)
    local Dz = tonumber(kO) or 60
    tL.FlySpeed = Dz
end
local function fn1312()
    local Character = LocalPlayer.Character
    local wh = Character and Character:FindFirstChildOfClass("Humanoid")
    return wh
end
s7 = nil
s8 = nil
s9 = nil
ta = nil
tb = nil
tc = nil
td = nil
te = nil
tg = nil
th = nil
ti = nil
tj = nil
tk = nil
tl = nil
tm = nil
tn = nil
to = nil
tp = nil
tq = nil
tr = nil
ts = nil
tt = nil
tu = nil
tv = nil
tw = nil
tx = nil
ty = nil
tA = nil
tC = nil
tD = nil
tE = nil
tF = nil
tG = nil
tI = nil
tJ = nil
tK = nil
tL = nil
tM = nil
tO = nil
tQ = nil
tR = nil
tS = nil
PlaytimeRewardsState = nil
local tf, tz, tB, remotes, tN, tP, tU
tV = nil
tW = nil
tX = nil
tY = nil
GameConfig = nil
t0 = nil
Options = nil
t2 = nil
t3 = nil
t4 = nil
t5 = nil
Toggles = nil
t7 = nil
t8 = nil
t9 = nil
ua = nil
ue = nil
uf = nil
ug = nil
uh = nil
ui = nil
ul = nil
um = nil
PlotConfig = nil
uo = nil
up = nil
Library = nil
ur = nil
ut = nil
uu = nil
uw = nil
uy = nil
uz = nil
uA = nil
uC = nil
uD = nil
uE = nil
LocalPlayer = nil
uG = nil
local tZ, ub, SaveManager, ud, uj, ThemeManager, us, uv, ux, uB
tZ = nil
ub = nil
SaveManager = nil
ud = nil
uj = nil
ThemeManager = nil
us = nil
uv = nil
ux = nil
uB = nil
local uO, uQ, uR, uS, uU
if not game:IsLoaded() then
    game.Loaded:Wait()
end
s7, LocalPlayer, uv, ur, uj, ud, t7 = nil, nil, nil, nil, nil, nil, nil
s7 = {}
s7.Players = game:GetService("Players")
s7.ReplicatedStorage = game:GetService("ReplicatedStorage")
s7.RunService = game:GetService("RunService")
s7.UserInputService = game:GetService("UserInputService")
s7.VirtualUser = game:GetService("VirtualUser")
s7.HttpService = game:GetService("HttpService")
s7.TeleportService = game:GetService("TeleportService")
s7.Workspace = game:GetService("Workspace")
s7.Lighting = game:GetService("Lighting")
s7.Stats = game:GetService("Stats")
s7.CoreGui = game:GetService("CoreGui")
s7.CollectionService = game:GetService("CollectionService")
s7.MarketplaceService = game:GetService("MarketplaceService")
s7.ProximityPromptService = game:GetService("ProximityPromptService")
LocalPlayer = s7.Players.LocalPlayer
local FK_1 = "TempoBackflipForAnimals"
local FK_8 = "v0.3"
uv = "Backflip for Animals"
ur = "https://discord.gg/K7Qxnxkk46"
uj = "https://discord.gg/K7Qxnxkk46"
ud = "https://tempohub.shop"
t7 = fn1030
if getgenv then
    getgenv().gethui = t7
end
tR, tL, tj, uO, FK_7, tz, ts = nil, nil, nil, nil, nil, nil, nil
pcall(fn774)
local function FK_11(o)
    local vs
    local vq
    local vr
    vq = nil
    vr = nil
    vs = nil
    local vt = o ~= ""
    local vu = type(o) == "string" and vt
    assert(vu, "Namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    vs = getgenv()
    assert(type(vs) == "table", "getgenv did not return a table")
    local vt_1 = vs[o]
    if vt_1 ~= nil then
        local vu_1 = type(vt_1) == "table" and type(vt_1.Unload) == "function"
        assert(vu_1, "Namespace is occupied")
        vt_1.Unload()
        assert(vs[o] == nil, "Previous instance did not release its namespace")
    end
    vq = {}
    vr = { State = {}, Unloaded = false }
    vr.Track = function(u)
        assert(type(u) == "function", "Cleanup must be callable")
        if vr.Unloaded then
            u()
        else
            table.insert(vq, u)
        end
        return u
    end
    vr.Unload = function()
        local vg_1
        local vf_1
        if vr.Unloaded then
            return
        end
        vr.Unloaded = true
        local vd = {}
        local vk = #vq
        local vj = -1
        while false and vk <= 1 or true and vk >= 1 do
            local vl = vk
            local ve_1 = table.remove(vq, vl)
            vf_1, vg_1 = pcall(ve_1)
            if not vf_1 then
                table.insert(vd, tostring(vg_1))
            end
            vk += vj
        end
        table.clear(vr.State)
        if #vd > 0 then
            error("Cleanup incomplete: " .. table.concat(vd, "; "), 0)
        end
        if vs[o] == vr then
            vs[o] = nil
        end
    end
    vs[o] = vr
    return vr
end
local function uP(H, I)
    local vD = type(H) == "table" and type(H.Track) == "function"
    assert(vD, "FeatureAPI required")
    local vD_1 = type(I) == "table" and type(I.OnUnload) == "function"
    assert(vD_1, "UI library required")
    assert(type(I.Unload) == "function", "UI unload required")
    H.Track(function()
        if not I.Unloaded then
            I:Unload()
        end
    end)
    I:OnUnload(function()
        H.Unload()
    end)
end
tR = FK_11(FK_1)
tL = tR.State
local FK_5 = fn664
tz = fn462
ts = fns.fn211
local FK_6 = FK_5(s7.ReplicatedStorage)
if ((false or (not FK_11 or false)) and (tR or false or not uO and not FK_11) or (uO or uO or uO and false) and (FK_11 or uO or (FK_11 or FK_5))) and ((not tR or FK_5) and (uP and uP) and (uP or uO or false) or (uO and false or (tR or tR) or not tR and FK_11 and (not uO or FK_5))) and not (((false or (not FK_11 or false)) and (tR or false or not uO and not FK_11) or (uO or uO or uO and false) and (FK_11 or uO or (FK_11 or FK_5))) and ((not tR or FK_5) and (uP and uP) and (uP or uO or false) or (uO and false or (tR or tR) or not tR and FK_11 and (not uO or FK_5)))) then
    s7 = tj(FK_5.Workspace)
else
    tj = FK_5(s7.Workspace)
end
uO = FK_6:WaitForChild("Libraries", 30)
if (tj or not FK_7) and (not tR and tj) or (not FK_6 and not tR or tR and not FK_7) or (tR and tR or not FK_6 and not FK_6 or not tR and 22 and (not FK_7 or 22)) or not ((tj or not FK_7) and (not tR and tj) or (not FK_6 and not tR or tR and not FK_7) or (tR and tR or not FK_6 and not FK_6 or not tR and 22 and (not FK_7 or 22))) then
    FK_7 = FK_6:WaitForChild("Packages", 30)
else
    FK_7:WaitForChild("Packages", 30)
end
local FK_3 = uO and FK_7
s9, uG, FK_6, uC, FK_5, ut, PlotConfig, ue, ua, t2, GameConfig, tW, PlaytimeRewardsState, tM, remotes, tF, tC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
FK_1 = 9
repeat
    FK_11 = (FK_1 * 1 + 4) % 5 + 1
    if FK_11 <= 3 then
        if FK_11 <= 2 then
            if FK_11 <= 1 then
                uQ = (vector.create((FK_1 * 5 + 4) % 11 + 1, (FK_1 * 4 + 11) % 13 + 1, (FK_1 * 9 + 3) % 17 + 1))
                uR = (vector.create((FK_1 * 7 + 7) % 11 + 1, (FK_1 * 2 + 6) % 13 + 1, (FK_1 * 7 + 10) % 17 + 1))
                uS = (vector.create((FK_1 * 1 + 5) % 5 + 1, (FK_1 * 2 + 1) % 7 + 1, (FK_1 * 1 + 7) % 9 + 1))
                if math.abs((vector.angle(uQ, uR, uS))) - math.abs((vector.angle(uR, uQ, uS))) == 2 then
                    t2 = require(GameConfig.SpeedConfig)
                    tW = require(GameConfig.TrailConfig)
                    ua = require(GameConfig.RebirthConfig)
                    uO = require(GameConfig.GameConfig)
                    ue = require(GameConfig.Gamepasses)
                else
                    ue = require(uO.SpeedConfig)
                    ua = require(uO.TrailConfig)
                    t2 = require(uO.RebirthConfig)
                    GameConfig = require(uO.GameConfig)
                    tW = require(uO.Gamepasses)
                end
                FK_1 = (FK_1 + 1) % 20
            else
                uQ = {
                    "zxmnkjurydh",
                    "pfyyj",
                    "mfkxnxpqliw",
                    "hexqryrl",
                    "sncmqypg",
                    "aegin",
                    "rwijxtuny",
                    "glrq",
                    "izqjuhgdeira",
                    "hkfyzahq",
                    "oqxmfs",
                    "xsyir",
                    "xheaifzzbfja",
                    "dsqklsgarbpd",
                    "kdzn",
                    "fntaeikiyjj"
                }
                if uQ[(FK_1 * 42 + 64) % 16 + 1] < uQ[(FK_1 * 42 + 64) % 16 + 1] then
                    uO = require(tM.PlaytimeRewardsState)
                    FK_7 = { 2400, 1200, 3900, 2100, 3300, 600, 300, 1500, 900 }
                    tF = PlaytimeRewardsState.Networker:WaitForChild("_remotes", 30)
                    assert(tF, "Network remotes missing")
                    remotes.AutoSteal = false
                    remotes.SelectedZones = {}
                    remotes.StealRarities = {}
                    remotes.AutoPlace = false
                    remotes.PlaceRarities = {}
                    remotes.AutoHatch = false
                    remotes.AutoClaimIndex = false
                    remotes.AutoClaimPlaytime = false
                    remotes.AutoRebirth = false
                    remotes.AutoEquipBest = false
                    remotes.AutoBuyTrails = false
                    remotes.AutoSell = false
                    remotes.SellRarities = {}
                    remotes.SellKeepTop = 3
                    remotes.SellKeepEquipped = true
                    remotes.AutoCollect = false
                    remotes.AutoUpgradeCollector = false
                    remotes.AutoUpgradePlot = false
                    remotes.AutoUpgradeTreadmill = false
                    remotes.AutoTreadmill = false
                    remotes.AutoTreadmill2x = false
                    remotes.InstantPrompt = false
                    remotes.WalkSpeedEnabled = false
                    remotes.WalkSpeedValue = 32
                    remotes.InfJump = false
                    remotes.NoClip = false
                    remotes.Fly = false
                    remotes.FlySpeed = 60
                    tL = {}
                else
                    PlaytimeRewardsState = require(uO.PlaytimeRewardsState)
                    tM = { 300, 600, 900, 1200, 1500, 2100, 2400, 3300, 3900 }
                    remotes = FK_7.Networker:WaitForChild("_remotes", 30)
                    assert(remotes, "Network remotes missing")
                    tL.AutoSteal = false
                    tL.SelectedZones = {}
                    tL.StealRarities = {}
                    tL.AutoPlace = false
                    tL.PlaceRarities = {}
                    tL.AutoHatch = false
                    tL.AutoClaimIndex = false
                    tL.AutoClaimPlaytime = false
                    tL.AutoRebirth = false
                    tL.AutoEquipBest = false
                    tL.AutoBuyTrails = false
                    tL.AutoSell = false
                    tL.SellRarities = {}
                    tL.SellKeepTop = 3
                    tL.SellKeepEquipped = true
                    tL.AutoCollect = false
                    tL.AutoUpgradeCollector = false
                    tL.AutoUpgradePlot = false
                    tL.AutoUpgradeTreadmill = false
                    tL.AutoTreadmill = false
                    tL.AutoTreadmill2x = false
                    tL.InstantPrompt = false
                    tL.WalkSpeedEnabled = false
                    tL.WalkSpeedValue = 32
                    tL.InfJump = false
                    tL.NoClip = false
                    tL.Fly = false
                    tL.FlySpeed = 60
                    tF = {}
                end
                FK_1 = (FK_1 + 16) % 20
            end
        else
            uQ = {
                "qaontnpj",
                "ccqugpmcji",
                "kvbcraelbqt",
                "vvpryz",
                "kapeb",
                "lxdemn",
                "sxu",
                "vkqk",
                "usxpgmz",
                "nfp",
                "pwika"
            }
            local HF = FK_1
            uR = uQ[HF % 11 + 1]
            if uR:len() <= uR:gsub("(.)", "%1%1", HF % 3 % 2 + 1):len() then
                tC = {}
            else
                ua = {}
            end
            FK_1 = (FK_1 + 11) % 20
        end
    elseif FK_11 <= 4 then
        if FK_1 * 8510305 + 13 + 1 >= FK_1 * 8510305 + 13 + 1 + 1 then
            assert(uO, "Game libraries missing")
            uC = require(FK_3.DataService).client
            FK_7 = require(FK_6.Enums)
            FK_5 = require(FK_6.EggConfig)
            s9 = require(FK_6.AnimalConfig)
            uG = require(FK_6.Rarities)
        else
            assert(FK_3, "Game libraries missing")
            s9 = require(FK_7.DataService).client
            uG = require(uO.Enums)
            FK_6 = require(uO.EggConfig)
            uC = require(uO.AnimalConfig)
            FK_5 = require(uO.Rarities)
        end
        FK_1 = (FK_1 + 1) % 20
    else
        FK_11 = (vector.create((FK_1 * 5 + 2) % 11 + 1, (FK_1 * 10 + 8) % 13 + 1, (FK_1 * 13 + 3) % 17 + 1))
        local Hx = vector.floor(FK_11) + vector.ceil(FK_11 * -1)
        if vector.dot(Hx, Hx) == 0 then
            ut = require(uO.IndexConfig)
            PlotConfig = require(uO.PlotConfig)
        else
            uO = require(PlotConfig.IndexConfig)
            ut = require(PlotConfig.PlotConfig)
        end
        FK_1 = (FK_1 + 11) % 20
    end
until (FK_1 * 7 + 0) % 20 == 3
for i, v in ipairs(ut.Sets) do
    FK_3 = string.format
    FK_1 = v.name or v.id
    FK_6 = FK_3("%d. %s", i, FK_1)
    table.insert(tF, FK_6)
    tC[FK_6] = i
end
FK_1, FK_11, ti, tb = nil, nil, nil, nil
FK_3 = 8
repeat
    FK_6 = (FK_3 * 2 + 0) % 3 + 1
    if FK_6 <= 2 then
        if FK_6 <= 1 then
            FK_6 = (vector.create((FK_3 * 2 + 6) % 11 + 1, (FK_3 * 8 + 6) % 13 + 1, (FK_3 * 12 + 3) % 17 + 1))
            FK_7 = (vector.create((FK_3 * 7 + 4) % 11 + 1, (FK_3 * 2 + 13) % 13 + 1, (FK_3 * 3 + 17) % 17 + 1))
            local Hv = vector.cross(FK_6, FK_7)
            local Hw = vector.dot(FK_6, FK_7)
            if vector.dot(Hv, Hv) + Hw * Hw == vector.dot(FK_6, FK_6) * vector.dot(FK_7, FK_7) + 2 then
                tb = {}
                ti = {}
            else
                ti = {}
                tb = {}
            end
            FK_3 = (FK_3 + 14) % 24
        else
            local G5 = bit32.rrotate(bit32.bxor(bit32.lrotate(FK_3, 27), string.byte(tostring(tb))), 30)
            if bit32.bxor(bit32.lrotate(bit32.bxor(G5, 2167805450), 12), 1633724435) == bit32.lrotate(G5, 12) then
                FK_1 = {
                    "common",
                    "uncommon",
                    "rare",
                    "epic",
                    "legendary",
                    "mythic",
                    "cosmic",
                    "secret",
                    "divine",
                    "eternal",
                    "admin"
                }
            else
                ti = {
                    "mythic",
                    "rare",
                    "legendary",
                    "common",
                    "eternal",
                    "admin",
                    "uncommon",
                    "cosmic",
                    "epic",
                    "secret",
                    "divine"
                }
            end
            FK_3 = (FK_3 + 17) % 24
        end
    else
        FK_6 = (vector.create((FK_3 * 2 + 9) % 11 + 1, (FK_3 * 10 + 4) % 13 + 1, (FK_3 * 12 + 10) % 17 + 1))
        FK_7 = (vector.create((FK_3 * 1 + 1) % 11 + 1, (FK_3 * 11 + 2) % 13 + 1, (FK_3 * 13 + 8) % 17 + 1))
        uO = (vector.create((FK_3 * 4 + 4) % 11 + 1, (FK_3 * 1 + 11) % 13 + 1, (FK_3 * 11 + 8) % 17 + 1))
        uQ = (vector.create((FK_3 * 7 + 1) % 11 + 1, (FK_3 * 11 + 10) % 13 + 1, (FK_3 * 2 + 12) % 17 + 1))
        if vector.dot(vector.cross(FK_6, FK_7), (vector.cross(uO, uQ))) == vector.dot(FK_6, uO) * vector.dot(FK_7, uQ) - vector.dot(FK_6, uQ) * vector.dot(FK_7, uO) + 1 then
            ti = {
                uncommon = "Uncommon",
                eternal = "ETERNAL",
                secret = "Secret",
                cosmic = "Cosmic",
                rare = "Rare",
                divine = "DIVINE",
                epic = "Epic",
                legendary = "Legendary",
                common = "Common",
                mythic = "Mythic",
                admin = "ADMIN"
            }
        else
            FK_11 = {
                common = "Common",
                uncommon = "Uncommon",
                rare = "Rare",
                epic = "Epic",
                legendary = "Legendary",
                mythic = "Mythic",
                cosmic = "Cosmic",
                secret = "Secret",
                divine = "DIVINE",
                eternal = "ETERNAL",
                admin = "ADMIN"
            }
        end
        FK_3 = (FK_3 + 8) % 24
    end
until (FK_3 * 11 + 7) % 24 == 20
for i, v in ipairs(FK_1) do
    FK_3 = FK_5[v]
    FK_1 = FK_3 and type(FK_3.name) == "string" and FK_3.name ~= "" and FK_3.name
    FK_3 = FK_1 or FK_11[v]
    FK_1 = FK_3 or v
    FK_3 = FK_1
    table.insert(ti, FK_3)
    tb[FK_3] = v
end
uo, ug, ub, t3, t0, tX, tU, tN, tt, Library, ThemeManager, SaveManager, Toggles, Options, tV, uB, ux, us, tB, tO, tu, tl, uz, t4, tD, tq, tc, ui, tv, te, uE, t8, tK, tg, um, tS, tE, tA, tn, uf, tI, ta, uh, tm, uu, uD, tw, tQ, th, s8, t9, to, uy, tG, tk, up, uA, t5, tx, td, uw, tY, tJ, tZ, tp, tP, ty, tr, tf, ul, uU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
uo = {}
ug = setmetatable({}, { __mode = "k" })
ub = {}
t3 = setmetatable({}, { __mode = "k" })
t0 = setmetatable({}, { __mode = "k" })
tX = 0
tU = {}
tO = fn801
tu = fn556
tl = fn1259
uz = fn695
t4 = fns.fn235
tD = fn1064
tq = fn1312
tc = function(bm)
    local wj
    wj = nil
    wj = tD()
    local wk = not wj or typeof(bm) ~= "Vector3"
    if wk then
        return false
    end
    local wk_1 = pcall(function()
        wj.CFrame = CFrame.new(bm + Vector3.new(0, 4, 0))
    end)
    return wk_1
end
ui = function(bu, bw, ...)
    local wp
    wp = nil
    local wq = os.clock()
    local wr = bu .. ":" .. bw
    local ws = tU[wr]
    local ww = if ws then 1 else 0
    local wu = 3183 * ww + 1407 * (1 - ww)
    local wv = 2540 * ww + 1018 * (1 - ww)
    if not ((wu * 1811 + wv * 3591 + wu * wv) % 16777213 == 6193160) then
        ws = 0
    end
    if ws + 0.2 > wq then
        return false
    end
    tU[wr] = wq
    local wq_1 = remotes:FindFirstChild(bu)
    local wr_1 = wq_1 and wq_1:FindFirstChild("RemoteEvent")
    wp = wr_1
    if not wp then
        return false
    end
    return pcall(function(...)
        wp:FireServer(bw, ...)
    end, ...)
end
tv = fn477
te = fns.fn112
uE = fn1209
t8 = fn602
tK = function(b0)
    local wS = not b0 or not b0:IsA("ProximityPrompt")
    local wW = if wS then 1 else 0
    local wU = 3685 * wW + 2774 * (1 - wW)
    local wV = 671 * wW + 2527 * (1 - wW)
    if not ((wU * 905 + wV * 1679 + wU * wV) % 16777213 == 6934169) then
        wS = not b0.Enabled
    end
    if wS then
        return false
    end
    if tL.InstantPrompt then
        pcall(function()
            b0.HoldDuration = 0
            b0.MaxActivationDistance = 50
            b0.RequiresLineOfSight = false
        end)
    end
    if tz(fireproximityprompt) then
        return pcall(fireproximityprompt, b0)
    end
    local wS_1 = pcall(function()
        s7.ProximityPromptService:InputHoldBegin(b0)
        task.wait(0.05)
        s7.ProximityPromptService:InputHoldEnd(b0)
    end)
    return wS_1
end
tg = fns.fn351
um = fn987
tS = fn1272
tE = fn824
tA = fn1061
tn = function()
    local cx = {}
    local function cy(cz)
        if not cz then
            return
        end
        for i, child in ipairs(cz:GetChildren()) do
            local xd = child:IsA("Tool") and type(child:GetAttribute(uG.EggAttribute.EggId)) == "string"
            if xd then
                table.insert(cx, child)
            end
        end
    end
    cy(LocalPlayer:FindFirstChild("Backpack"))
    cy(LocalPlayer.Character)
    return cx
end
uf = function(cI)
    local xl
    xl = nil
    if not cI then
        return false
    end
    xl = tq()
    if not xl then
        return false
    end
    return pcall(function()
        xl:EquipTool(cI)
    end)
end
tN = Vector3.new(277, 5, 41)
tI = function()
    local xq
    local xw = if not tA() then 1 else 0
    if xw == 1 then
        return true
    end
    xq = tD()
    if not xq then
        return false
    end
    local xr = pcall(function()
        xq.CFrame = CFrame.new(tN)
    end)
    if not xr then
        return false
    end
    local xr_1 = os.clock() + 3
    while true do
        local xs = ts() and tA() and os.clock() < xr_1
        if xs then
            task.wait(0.1)
            continue
        end
        break
    end
    return not tA()
end
ta = fn668
uh = fns.fn108
tm = fn591
uu = fns.fn380
uD = fns.fn245
tw = fn1132
tQ = fn820
th = fn397
s8 = fn809
t9 = fn1203
to = function(eU)
    local y6 = not eU or not eU:IsA("GuiButton")
    if y6 then
        return false
    end
    local y5 = false
    if tz(firesignal) then
        local y6_1 = pcall(firesignal, eU.Activated) or y5
        y5 = y6_1
        local y6_2 = pcall(firesignal, eU.MouseButton1Click) or y5
        y5 = y6_2
    end
    if tz(getconnections) then
        pcall(function()
            for i, v in ipairs(getconnections(eU.Activated)) do
                if v.Fire then
                    v:Fire()
                    y5 = true
                elseif v.Function then
                    v.Function()
                    y5 = true
                end
            end
        end)
    end
    return y5
end
uy = fns.fn127
tG = fn484
tk = fn734
up = fn546
uA = fn597
t5 = fn651
tx = fns.fn368
td = fn713
uw = fns.fn201
tY = fn1010
tJ = function(gl, gm, gn)
    tY(gl)
    uo[gl] = true
    task.spawn(function()
        local Ai_1
        while true do
            local Ah = ts() and uo[gl]
            local Ah_1
            if Ah then
                Ah_1, Ai_1 = pcall(gn)
                if not Ah_1 then
                    warn("[Tempo] " .. gl .. ": " .. tostring(Ai_1))
                end
                task.wait(gm)
                local Ah_2 = not ts() or not uo[gl]
                if Ah_2 then
                    break
                end
                continue
            end
            break
        end
    end)
end
tR.SetAutoSteal = fn634
tR.SetSelectedZones = fns.fn305
tR.SetStealRarities = fn414
tR.SetAutoPlace = fn931
tR.SetPlaceRarities = fn653
tR.SetAutoHatch = fn857
tR.SetAutoClaimIndex = fn699
tR.SetAutoClaimPlaytime = fn785
tR.SetAutoRebirth = fns.fn76
tR.SetAutoEquipBest = fns.fn25
tR.SetAutoBuyTrails = fns.fn320
tR.SetAutoSell = fn1130
tR.SetSellRarities = fn714
tR.SetSellKeepTop = fn965
tR.SetSellKeepEquipped = fns.fn224
tR.SetAutoCollect = fns.fn272
tR.SetAutoUpgradeCollector = fns.fn177
tR.SetAutoUpgradePlot = fn1303
tR.SetAutoUpgradeTreadmill = fn596
tR.SetAutoTreadmill = fns.fn47
tR.SetAutoTreadmill2x = fn729
tR.TeleportMyPlot = fns.fn181
tR.TeleportCollect = fns.fn9
tR.TeleportTreadmill = fns.fn248
tR.TeleportSellPad = fn691
tR.TeleportTrailsPad = fn636
tR.TeleportPlatform = fn1225
tZ = fn972
tR.SetInstantProximityPrompt = function(jc)
    local Cu = jc and true or false
    tL.InstantPrompt = Cu
    for i, descendant in ipairs(tj:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            tZ(descendant)
        end
    end
    if tL.InstantPrompt and not ub._conn then
        ub._conn = tj.DescendantAdded:Connect(function(jr)
            local Ci = ts() and tL.InstantPrompt and jr:IsA("ProximityPrompt")
            if Ci then
                tZ(jr)
            end
        end)
        tR.Track(function()
            if ub._conn then
                ub._conn:Disconnect()
                ub._conn = nil
            end
            for k, v in pairs(ug) do
                local Cq = k
                local Cs = v
                if Cq and Cq.Parent and Cs then
                    pcall(function()
                        Cq.HoldDuration = Cs.HoldDuration
                        Cq.MaxActivationDistance = Cs.MaxActivationDistance
                        Cq.RequiresLineOfSight = Cs.RequiresLineOfSight
                    end)
                end
            end
        end)
    else
        if not tL.InstantPrompt and ub._conn then
            ub._conn:Disconnect()
            ub._conn = nil
            for k, v in pairs(ug) do
                local CI = k
                local CK = v
                if CI and CI.Parent and CK then
                    pcall(function()
                        CI.HoldDuration = CK.HoldDuration
                        CI.MaxActivationDistance = CK.MaxActivationDistance
                        CI.RequiresLineOfSight = CK.RequiresLineOfSight
                    end)
                end
            end
        end
    end
end
tt = {}
tp = fn1289
tR.SetWalkSpeedEnabled = fns.fn237
tR.SetWalkSpeedValue = fn1104
tR.SetInfJump = fns.fn264
tR.SetNoClip = fn1144
tR.SetFly = fns.fn109
tR.SetFlySpeed = fn1305
tR.Track(fns.fn258)
LocalPlayer.CharacterAdded:Connect(fns.onCharacterAdded)
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles, Options = Library.Toggles, Library.Options
uP(tR, Library)
uQ = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = ur, Copyable = true }, "|", uv, "|", FK_8 },
    Icon = 132608042600488,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
tV = {}
tV.Info = uQ:AddTab("Info", "info")
tV.Main = uQ:AddTab("Main", "gamepad-2")
tV.Teleports = uQ:AddTab("Teleports", "map-pin")
tV.Player = uQ:AddTab("Player", "person-standing")
tV.Settings = uQ:AddTab("Settings", "settings")
tP = fn797
ty = fn929
tr = fn839
tf = fns.fn222
uB = "#7fd47f"
ux = "#6ec1ff"
us = "#e8a34d"
ul = fn573
uR = function()
    local lA
    local lv
    lv = "Unknown"
    pcall(function()
        local DW_1
        local DV_1
        if type(identifyexecutor) == "function" then
            DW_1, DV_1 = identifyexecutor()
            local DX = DW_1 ~= ""
            local DY = type(DW_1) == "string" and DX
            if DY then
                local DX_1 = type(DV_1) == "string" and DV_1 ~= "" and DW_1 .. " " .. DV_1
                lv = DX_1 or DW_1
            end
        end
    end)
    lA = os.clock()
    local function lB()
        local D_ = math.floor(os.clock() - lA)
        if D_ < 60 then
            return D_ .. "s"
        elseif D_ < 3600 then
            return string.format("%dm %ds", math.floor((D_) / (60)), D_ % 60)
        else
            return string.format("%dh %dm", math.floor((D_) / (3600)), math.floor((D_ % 3600) / (60)))
        end
    end
    local UserGroup = tV.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(tf("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, uB), true)
    UserGroup:AddLabel(tf("UserId", tostring(LocalPlayer.UserId), ux), true)
    UserGroup:AddLabel(tf("Executor", lv, uB), true)
    UserGroup:AddDivider()
    local Label5 = UserGroup:AddLabel(tf("Session", lB(), us), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            tP(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            tP("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local DiscordGroup = tV.Info:AddRightGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = ur,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    local SessionGroup = tV.Info:AddRightGroupbox("Session", "signal")
    local Label4 = SessionGroup:AddLabel(tf("Game", uv, uB), true)
    local Label3 = SessionGroup:AddLabel(tf("Players", tostring(#s7.Players:GetPlayers()), ux), true)
    local Label2 = SessionGroup:AddLabel(tf("Job", string.sub(game.JobId, 1, 8) .. "...", us), true)
    local Label = SessionGroup:AddLabel(tf("Ping", "0 ms", uB), true)
    SessionGroup:AddButton({
        Text = "Rejoin Place",
        Func = function()
            pcall(function()
                s7.TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            tP(game.JobId, "Copied Job ID")
        end
    })
    local SocialsGroup = tV.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({
        Text = "Copy Discord",
        Func = function()
            tP(ur, "Copied Discord")
        end
    })
    SocialsGroup:AddButton({
        Text = "Copy Rscripts",
        Func = function()
            tP(uj, "Copied Rscripts")
        end
    })
    SocialsGroup:AddButton({
        Text = "Copy Website",
        Func = function()
            tP(ud, "Copied Website")
        end
    })
    task.spawn(function()
        local D4 = false
        repeat
            local D1
            if ts() then
                Label5:SetText(tf("Session", lB(), us))
                Label3:SetText(tf("Players", tostring(#s7.Players:GetPlayers()), ux))
                D1 = 0
                pcall(function()
                    D1 = math.floor(s7.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                Label:SetText(tf("Ping", tostring(D1) .. " ms", uB))
                Label4:SetText(tf("Game", uv, uB))
                Label2:SetText(tf("Job", string.sub(game.JobId, 1, 8) .. "...", us))
                task.wait(1)
            else
                D4 = true
            end
        until D4
    end)
end
FK_1 = fns.fn251
if ((not uh or not uh) and (s8 or s8) and (not s8 or s8 or false) or ((s8 or false) and false or (not uh or not uh) and (tK or not s8))) and not ((not uh or not uh) and (s8 or s8) and (not s8 or s8 or false) or ((s8 or false) and false or (not uh or not uh) and (tK or not s8))) then
    um = function()
        ul(tV.Teleports)
        local PlotGroup = tV.Teleports:AddLeftGroupbox("Plot", "home")
        PlotGroup:AddButton({
            Text = "Teleport to My Plot",
            Func = function()
                tR.TeleportMyPlot()
            end
        })
        PlotGroup:AddButton({
            Text = "Teleport to Collector",
            Func = function()
                tR.TeleportCollect()
            end
        })
        PlotGroup:AddButton({
            Text = "Teleport to Treadmill",
            Func = function()
                tR.TeleportTreadmill()
            end
        })
        PlotGroup:AddButton({
            Text = "Teleport to Sell Pad",
            Func = function()
                tR.TeleportSellPad()
            end
        })
        PlotGroup:AddButton({
            Text = "Teleport to Trails Pad",
            Func = function()
                tR.TeleportTrailsPad()
            end
        })
        local PlatformsGroup = tV.Teleports:AddRightGroupbox("Platforms", "map")
        for i, v in ipairs(ut.Sets) do
            local D5
            D5 = i
            local D8 = v.name or v.id
            PlatformsGroup:AddButton({
                Text = string.format("%d. %s", i, D8),
                Func = function()
                    tR.TeleportPlatform(D5)
                end
            })
        end
    end
else
    uU = function()
        ul(tV.Teleports)
        local PlotGroup = tV.Teleports:AddLeftGroupbox("Plot", "home")
        PlotGroup:AddButton({
            Text = "Teleport to My Plot",
            Func = function()
                tR.TeleportMyPlot()
            end
        })
        PlotGroup:AddButton({
            Text = "Teleport to Collector",
            Func = function()
                tR.TeleportCollect()
            end
        })
        PlotGroup:AddButton({
            Text = "Teleport to Treadmill",
            Func = function()
                tR.TeleportTreadmill()
            end
        })
        PlotGroup:AddButton({
            Text = "Teleport to Sell Pad",
            Func = function()
                tR.TeleportSellPad()
            end
        })
        PlotGroup:AddButton({
            Text = "Teleport to Trails Pad",
            Func = function()
                tR.TeleportTrailsPad()
            end
        })
        local PlatformsGroup = tV.Teleports:AddRightGroupbox("Platforms", "map")
        for i, v in ipairs(ut.Sets) do
            local D5
            D5 = i
            local D8 = v.name or v.id
            PlatformsGroup:AddButton({
                Text = string.format("%d. %s", i, D8),
                Func = function()
                    tR.TeleportPlatform(D5)
                end
            })
        end
    end
end
FK_6 = fn1179
tB = {
    AntiAfk = true,
    NoGameplayPaused = true,
    AutoReconnect = false,
    Disable3D = false,
    FpsBoost = false,
    AfkConn = nil,
    AfkTask = nil,
    ReconnectConns = {},
    FpsSnapshots = {},
    FpsConn = nil,
    PausedConn = nil,
    AfkCount = 0
}
FK_7 = function()
    local function n1()
        local Eg = not tz(s7.VirtualUser.CaptureController) or not tz(s7.VirtualUser.ClickButton2)
        if Eg then
            return false
        end
        return pcall(function()
            s7.VirtualUser:CaptureController()
            s7.VirtualUser:ClickButton2(Vector2.new())
        end)
    end
    tR.SetAntiAfk = function(n8)
        local Eu = n8 and true or false
        tB.AntiAfk = Eu
        if tB.AfkConn then
            tB.AfkConn:Disconnect()
            tB.AfkConn = nil
        end
        if tB.AfkTask then
            pcall(task.cancel, tB.AfkTask)
            tB.AfkTask = nil
        end
        if not tB.AntiAfk then
            return
        end
        tB.AfkConn = LocalPlayer.Idled:Connect(function()
            local Ei = ts() and tB.AntiAfk and n1()
            if Ei then
                tB.AfkCount = tB.AfkCount + 1
            end
        end)
        tB.AfkTask = task.spawn(function()
            local Eq = os.clock()
            while true do
                local Er = ts() and tB.AntiAfk
                if Er then
                    task.wait(1)
                    local Er_1 = not ts() or not tB.AntiAfk
                    if Er_1 then
                        break
                    end
                    if os.clock() - Eq >= 60 then
                        Eq = os.clock()
                        if n1() then
                            tB.AfkCount = tB.AfkCount + 1
                        end
                    end
                    continue
                end
                break
            end
        end)
    end
    tR.SetNoGameplayPaused = function(ou)
        local EM
        local EO = ou and true or false
        tB.NoGameplayPaused = EO
        if tB.PausedConn then
            tB.PausedConn:Disconnect()
            tB.PausedConn = nil
        end
        if not tB.NoGameplayPaused then
            return
        end
        EM = function()
            pcall(function()
                local RobloxGui = s7.CoreGui:FindFirstChild("RobloxGui")
                local EA = RobloxGui and RobloxGui:FindFirstChild("Notifications")
                if EA then
                    for i, descendant in ipairs(EA:GetDescendants()) do
                        local Ez_2 = descendant:IsA("TextLabel") and string.find(string.lower(descendant.Text), "gameplay paused")
                        if Ez_2 then
                            local Frame = descendant:FindFirstAncestorOfClass("Frame")
                            if Frame then
                                Frame.Visible = false
                            end
                        end
                    end
                end
            end)
        end
        EM()
        tB.PausedConn = s7.CoreGui.DescendantAdded:Connect(function()
            if tB.NoGameplayPaused then
                EM()
            end
        end)
    end
    tR.SetAutoReconnect = function(oJ)
        local EZ = oJ and true or false
        tB.AutoReconnect = EZ
        for i, v in ipairs(tB.ReconnectConns) do
            v:Disconnect()
        end
        table.clear(tB.ReconnectConns)
        if not tB.AutoReconnect then
            return
        end
        table.insert(tB.ReconnectConns, s7.TeleportService.TeleportInitFailed:Connect(function()
            local ET = not ts() or not tB.AutoReconnect
            if ET then
                return
            end
            task.wait(1)
            local ET_1 = ts() and tB.AutoReconnect
            if ET_1 then
                pcall(function()
                    s7.TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
            end
        end))
    end
    tR.SetDisable3D = function(oY)
        local E7 = oY and true or false
        tB.Disable3D = E7
        pcall(function()
            s7.RunService:Set3dRenderingEnabled(not tB.Disable3D)
        end)
    end
    tR.SetFpsBoost = function(o2)
        local Ft
        local Fv = o2 and true or false
        tB.FpsBoost = Fv
        if tB.FpsConn then
            tB.FpsConn:Disconnect()
            tB.FpsConn = nil
        end
        local function Fu_1()
            for k, v in pairs(tB.FpsSnapshots) do
                local Fe = k
                if Fe and Fe.Parent then
                    for k, v in pairs(v) do
                        local Fk = k
                        local Fm = v
                        pcall(function()
                            Fe[Fk] = Fm
                        end)
                    end
                end
            end
            table.clear(tB.FpsSnapshots)
        end
        if not tB.FpsBoost then
            Fu_1()
            return
        end
        Ft = function(pf)
            if tB.FpsSnapshots[pf] then
                return
            end
            local Fn = pf:IsA("ParticleEmitter") or pf:IsA("Trail") or pf:IsA("Beam") or pf:IsA("Fire") or pf:IsA("Smoke") or pf:IsA("Sparkles")
            if Fn then
                tB.FpsSnapshots[pf] = { Enabled = pf.Enabled }
                pf.Enabled = false
            end
        end
        for i, descendant in ipairs(tj:GetDescendants()) do
            Ft(descendant)
        end
        if tB.FpsSnapshots[s7.Lighting] == nil then
            tB.FpsSnapshots[s7.Lighting] = { GlobalShadows = s7.Lighting.GlobalShadows }
            s7.Lighting.GlobalShadows = false
        end
        tB.FpsConn = tj.DescendantAdded:Connect(function(pn)
            if tB.FpsBoost then
                Ft(pn)
            end
        end)
    end
    tR.Track(function()
        tR.SetAntiAfk(false)
        tR.SetNoGameplayPaused(false)
        tR.SetAutoReconnect(false)
        tR.SetDisable3D(false)
        tR.SetFpsBoost(false)
    end)
end
uS = function()
    local Label
    ul(tV.Settings)
    local MenuGroup = tV.Settings:AddLeftGroupbox("Menu", "settings")
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Label = MenuGroup:AddLabel(tf("AFK Triggers", "0", us), true)
    MenuGroup:AddToggle("NoGameplayPaused", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3DRendering", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FPSBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUIOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local ScriptGroup = tV.Settings:AddLeftGroupbox("Script", "scroll-text")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    Toggles.AntiAfk:OnChanged(function(pD)
        tR.SetAntiAfk(pD)
    end)
    Toggles.NoGameplayPaused:OnChanged(function(pG)
        tR.SetNoGameplayPaused(pG)
    end)
    Toggles.AutoReconnect:OnChanged(function(pI)
        tR.SetAutoReconnect(pI)
    end)
    Toggles.Disable3DRendering:OnChanged(function(pK)
        tR.SetDisable3D(pK)
    end)
    Toggles.FPSBoost:OnChanged(function(pM)
        tR.SetFpsBoost(pM)
    end)
    task.spawn(function()
        while ts() do
            Label:SetText(tf("AFK Triggers", tostring(tB.AfkCount), us))
            task.wait(1)
        end
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(tV.Settings)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    SaveManager:SetFolder("TempoHub/BackflipForAnimals")
    SaveManager:BuildConfigSection(tV.Settings)
    pcall(function()
        ThemeManager:LoadDefault()
    end)
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
    tR.SetAntiAfk(Toggles.AntiAfk.Value)
    tR.SetNoGameplayPaused(Toggles.NoGameplayPaused.Value)
    tR.SetAutoReconnect(Toggles.AutoReconnect.Value)
    tR.SetDisable3D(Toggles.Disable3DRendering.Value)
    tR.SetFpsBoost(Toggles.FPSBoost.Value)
    tR.SetSelectedZones(Options.ZoneFilter.Value)
    tR.SetStealRarities(Options.StealRarityFilter.Value)
    tR.SetPlaceRarities(Options.PlaceRarityFilter.Value)
    tR.SetSellRarities(Options.SellRarityFilter.Value)
    tR.SetSellKeepTop(Options.SellKeepTop.Value)
    tR.SetSellKeepEquipped(Toggles.SellKeepEquipped.Value)
    tR.SetAutoSteal(Toggles.AutoStealEggs.Value)
    tR.SetAutoPlace(Toggles.AutoPlaceEggs.Value)
    tR.SetAutoHatch(Toggles.AutoHatchEggs.Value)
    tR.SetAutoEquipBest(Toggles.AutoEquipBestAnimals.Value)
    tR.SetAutoUpgradeCollector(Toggles.AutoUpgradeCollector.Value)
    tR.SetAutoUpgradePlot(Toggles.AutoUpgradePlot.Value)
    tR.SetAutoUpgradeTreadmill(Toggles.AutoUpgradeTreadmill.Value)
    tR.SetAutoBuyTrails(Toggles.AutoBuyTrails.Value)
    tR.SetAutoTreadmill(Toggles.AutoGoOnTreadmill.Value)
    tR.SetAutoTreadmill2x(Toggles.AutoTreadmill2x.Value)
    tR.SetAutoCollect(Toggles.AutoCollectMoney.Value)
    tR.SetAutoClaimIndex(Toggles.AutoClaimIndex.Value)
    tR.SetAutoClaimPlaytime(Toggles.AutoClaimPlaytime.Value)
    tR.SetAutoRebirth(Toggles.AutoRebirth.Value)
    tR.SetAutoSell(Toggles.AutoSellAnimals.Value)
    tR.SetWalkSpeedEnabled(Toggles.WalkSpeedEnabled.Value)
    tR.SetWalkSpeedValue(Options.WalkSpeed.Value)
    tR.SetInfJump(Toggles.InfJump.Value)
    tR.SetNoClip(Toggles.NoClip.Value)
    tR.SetInstantProximityPrompt(Toggles.InstantProximityPrompt.Value)
    tR.SetFly(Toggles.Fly.Value)
    tR.SetFlySpeed(Options.FlySpeed.Value)
    if Toggles.HideUIOnStart.Value then
        pcall(function()
            Library:Toggle(false)
        end)
    end
end
FK_7()
uR()
FK_1()
uU()
FK_6()
uS()
end)(...)
