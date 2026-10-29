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
getgenv().TempoHoodSubtitle = "BEAT THE ANIME BOSS!"
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
local mc
local my
local SellInventory
local l2
local m5
local mK
local Workspace
local m8
local l8
local mQ
local mN
local mx
local mT
local mA
local mh
local mZ
local mk
local CollectAllChestPets
local m4
local mJ
local l4
local m7
local na
local mP
local mw
local mS
local ma
local md
local mV
local mz
local mC
local mg
local mF
local Library
local Toggles
local mL
local m6
local l6
local EquipBestPets
local Options
local AttackBoss
local CharacterConfig
local function worker6()
    while not Library.Unloaded do
        if m7("AutoEquipBest") then
            pcall(mw)
        end
        task.wait(3)
    end
end
local function fn69(aG, aH)
    local n6 = Options[aG]
    if n6 and n6.Value ~= nil then
        return n6.Value
    end
    return aH
end
local function worker8()
    while not Library.Unloaded do
        if m7("AutoSell") then
            pcall(na)
        end
        task.wait(2)
    end
end
local function fn113(aY, aZ)
    return string.format('<font color="%s">%s</font>', aZ, aY)
end
local function fn127()
    return mz
end
local function fn156()
    if l2.SkipCurrentFight then
        return
    end
    local ql = l2.LastCharacterId and mP(l2.LastCharacterId)
    if ql then
        l2.SkipCurrentFight = true
        m8()
        return
    end
    pcall(function()
        AttackBoss:FireServer("Click")
    end)
end
local function fn199()
    mC(mx, "Copied Discord invite to clipboard")
end
local function fn237(ea)
    if ea then
        l2.WeSetAutoClick = true
        m8()
    elseif l2.WeSetAutoClick then
        l2.WeSetAutoClick = false
        l6(false)
    end
end
local function fn251()
    my.FireServer(my)
end
local function fn257(aR, aS)
    local oc = l8(aR)
    if oc[aS] == true then
        return true
    end
    for k, v in oc do
        if v == aS then
            return true
        end
    end
    return false
end
local function fn297(a0, a1, a2)
    return string.format("<b>%s</b> %s %s", a0, mc("-", "#5a6070"), mc(a1, a2))
end
local function worker4()
    while not Library.Unloaded do
        if m7("AutoCollectMoney") then
            pcall(mL)
        end
        task.wait(1)
    end
end
local function worker5()
    while not Library.Unloaded do
        if m7("AutoCollectCharacters") then
            pcall(mJ)
        end
        task.wait(2)
    end
end
local function fn362()
    local ow = m4()
    if not ow then
        return nil
    end
    return tonumber(ow.Name:match("%d+"))
end
local function worker()
    while Library and not Library.Unloaded do
        mV()
        task.wait(1)
    end
end
local function fn440()
    m5(EquipBestPets)
end
local function worker2()
    while not Library.Unloaded do
        local q_ = (m7("AutoRoll"))
        if not q_ then
            local q0 = m7("AutoFightRoll") and l2.SkipCurrentFight
            q_ = q0
        end
        if q_ then
            pcall(mZ)
        end
        task.wait(0.35)
    end
end
local function fn454(a5, a6)
    if setclipboard then
        setclipboard(a5)
    elseif toclipboard then
        toclipboard(a5)
    end
    Library:Notify(a6)
end
local function worker3()
    while not Library.Unloaded do
        local q5 = if m7("AutoFightRoll") then 1 else 0
        if q5 == 1 then
            pcall(mk)
            task.wait(0.1)
        else
            task.wait(0.35)
        end
    end
end
local function fn476()
    m5(CollectAllChestPets)
end
local function fn485()
    if m7("SellAllInventory") then
        local Character = ma.Character
        local qF_1 = Character and Character:FindFirstChildOfClass("Humanoid")
        if qF_1 then
            qF_1:UnequipTools()
        end
        task.wait(0.1)
        m5(SellInventory)
        return
    end
    local Character = ma.Character
    local qF_2 = Character and Character:FindFirstChildOfClass("Humanoid")
    local Backpack = ma:FindFirstChild("Backpack")
    if not (qF_2 and Backpack) then
        return
    end
    local qG_1 = {}
    for i, child in Backpack:GetChildren() do
        if child:IsA("Tool") then
            qG_1[#qG_1 + 1] = child
        end
    end
    for k, v in qG_1 do
        local qF_4 = Library.Unloaded or not m7("AutoSell")
        if qF_4 then
            break
        end
        local attr = v:GetAttribute("UID")
        if not mh(attr) then
            local qF_6 = mN(v)
            local qG_2 = not qF_6 or not mQ("SellRarities", qF_6)
            if not qG_2 then
                qF_2:EquipTool(v)
                task.wait(0.15)
                m5(mT)
                task.wait(0.25)
            end
        end
    end
end
local function fn506()
    if not m7("AutoFightRoll") then
        return
    end
    if l2.SkipCurrentFight then
        l6(false)
    else
        l2.WeSetAutoClick = true
        l6(true)
    end
end
local function fn509()
    if m7("AutoRoll") then
        mS(false)
    end
    if l2.WeSetAutoClick then
        l6(false)
    end
    if getgenv then
        getgenv().__TempoBeatAnimeBossLib = nil
    end
end
local function onOnClientEvent(cb)
    if type(cb) ~= "table" then
        return
    end
    if cb.Money ~= nil then
        l2.Money = cb.Money
    end
    if cb.Stats then
        l2.Stats = cb.Stats
    end
    if cb.SummonerSettings then
        l2.SummonerSettings = cb.SummonerSettings
    end
    if cb.ActiveSummonerLevel then
        l2.ActiveSummonerLevel = cb.ActiveSummonerLevel
    end
    if cb.SummonerLevel then
        l2.SummonerLevel = cb.SummonerLevel
        l2.Stats.Summoner = cb.SummonerLevel
    end
    if cb.AutoClickEnabled ~= nil then
        l2.AutoClickEnabled = cb.AutoClickEnabled
    end
    if cb.LockedPets then
        l2.LockedPets = cb.LockedPets
    end
end
local function fn531(aB)
    local n3 = Toggles[aB]
    return n3 and n3.Value == true
end
local function fn543(bn)
    if type(bn) ~= "string" then
        return nil
    end
    local oB = CharacterConfig.GetInfo and CharacterConfig.GetInfo(bn)
    return oB or CharacterConfig.Characters[bn]
end
local function fn550(by)
    if not by then
        return false
    end
    return l2.LockedPets[by] == true
end
local function onOnClientEvent2(cd, ce, cf)
    if cd ~= mA() then
        return
    end
    l2.LastCharacterId = ce
    l2.SkipCurrentFight = mP(ce)
    local o0 = tonumber(cf) or 3
    local o1 = o0 + 0.35
    l2.BossBusyUntil = os.clock() + o1
    m8()
    local o0_1 = l2.SkipCurrentFight
    if o0_1 then
        local o2 = m7("AutoRoll") or m7("AutoFightRoll")
        o0_1 = o2
    end
    if o0_1 then
        task.delay(o1, function()
            if Library.Unloaded then
                return
            end
            if not l2.SkipCurrentFight then
                return
            end
            local oZ = m7("AutoRoll") or m7("AutoFightRoll")
            if not oZ then
                return
            end
            mK()
        end)
    end
end
local function worker7()
    while not Library.Unloaded do
        if m7("AutoBuyUpgrades") then
            pcall(md)
        end
        task.wait(1)
    end
end
local function fn647()
    local oz = tonumber(l2.ActiveSummonerLevel) or 1
    return math.clamp(oz, 1, 3)
end
local function fn672(d8)
    mS(d8)
end
local function fn681(bR)
    local oL = l4(bR)
    if not oL then
        return false
    end
    local oM = m7("SkipRarity") and oL.Rarity and mQ("SkipRarities", oL.Rarity)
    if oM then
        return true
    elseif m7("SkipOverHealth") then
        local oM_1 = tonumber(oL.MaxHealth) or 0
        if oM_1 > mF("MaxBossHealth", 1000000) then
            return true
        end
        return false
    else
        return false
    end
end
local function fn699(aM)
    local n9 = Options[aM]
    if not n9 then
        return {}
    end
    local Value = n9.Value
    if type(Value) ~= "table" then
        return {}
    end
    return Value
end
local function fn728(cN)
    local DiscordGroup = cN:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mg })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mg })
end
local function fn734()
    local qf = (m7("AutoRoll"))
    local qk = if qf then 1 else 0
    local qi = 859 * qk + 3549 * (1 - qk)
    local qj = 861 * qk + 1889 * (1 - qk)
    if not ((qi * 1786 + qj * 911 + qi * qj) % 16777213 == 3058144) then
        local qg = m7("AutoFightRoll") and l2.SkipCurrentFight
        qf = qg
    end
    if not qf then
        return
    end
    if os.clock() < l2.BossBusyUntil then
        return
    end
    local qf_1 = l2.SkipCurrentFight or m7("AutoRoll")
    if qf_1 then
        mK()
    end
end
local function fn769(bs)
    local attr = bs:GetAttribute("CharacterId")
    local oF = l4(attr)
    return oF and oF.Rarity or nil
end
local function fn774()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in Plots:GetChildren() do
        if child:GetAttribute("OwnerPlayerId") == ma.UserId then
            return child
        end
    end
    return nil
end
local function onOnClientEvent3(cw)
    if cw == "BossSpawned" then
        l2.BossBusyUntil = math.max(l2.BossBusyUntil, os.clock() + 0.35)
        if l2.LastCharacterId then
            l2.SkipCurrentFight = mP(l2.LastCharacterId)
            m8()
        end
    end
end
l2 = nil
l4 = nil
l6 = nil
l8 = nil
Options = nil
ma = nil
mc = nil
md = nil
mg = nil
mh = nil
Toggles = nil
mk = nil
Workspace = nil
AttackBoss = nil
mw = nil
mx = nil
my = nil
mz = nil
mA = nil
mC = nil
mF = nil
mJ = nil
mK = nil
mL = nil
mN = nil
local l0, l1, l3, l5, l7, UpgradeSummoner, me, mf, mi, RequestSummonerUpgradeConfir, MenuGroup, mn, mo, mp, SaveManager, BuyUpgrade, mt, mu, mB, mD, RequestBossRoll, mG, mH, StatsConfig, mM
mP = nil
mQ = nil
CharacterConfig = nil
mS = nil
mT = nil
mV = nil
local mW
SellInventory = nil
mZ = nil
Library = nil
CollectAllChestPets = nil
m4 = nil
m5 = nil
m6 = nil
m7 = nil
m8 = nil
EquipBestPets = nil
na = nil
local mO, mU, mY, m_, m2, m3
local DataSync
local nc_1
local nd_5
l0, nc_1, mY, mU, mO, mH, mD, mz, mu, Workspace, mi, ma, l3, m6 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local nb = 14
repeat
    local nd_1 = (nb * 5 + 0) % 6 + 1
    if nd_1 <= 3 then
        if nd_1 <= 2 then
            if nd_1 <= 1 then
                if nb * 26544973 + 1 + 1 >= nb * 26544973 + 1 + 1 + 4 then
                    mO = game:GetService("RunService")
                    mY = game:GetService("UserInputService")
                    mH = game:GetService("VirtualUser")
                    mD = game:GetService("HttpService")
                    mU = game:GetService("GuiService")
                else
                    mY = game:GetService("RunService")
                    mU = game:GetService("UserInputService")
                    mO = game:GetService("VirtualUser")
                    mH = game:GetService("HttpService")
                    mD = game:GetService("GuiService")
                end
                nb = (nb + 17) % 48
            else
                if ((m6 or ma) and (not m6 or m6) or (not m6 or not ma) and (ma and not ma)) and not ((m6 or ma) and (not m6 or m6) or (not m6 or not ma) and (ma and not ma)) then
                    mu = game:GetService("CoreGui")
                    mz = game:GetService("TeleportService")
                else
                    mz = game:GetService("CoreGui")
                    mu = game:GetService("TeleportService")
                end
                nb = (nb + 23) % 48
            end
        else
            local ne_1 = (vector.create((nb * 4 + 6) % 11 + 1, (nb * 3 + 4) % 13 + 1, (nb * 11 + 10) % 17 + 1))
            local nf_1 = (vector.create((nb * 6 + 8) % 11 + 1, (nb * 6 + 7) % 13 + 1, (nb * 6 + 2) % 17 + 1))
            local ue = vector.dot(ne_1, nf_1)
            if ue * ue <= vector.dot(ne_1, ne_1) * vector.dot(nf_1, nf_1) then
                Workspace = game:GetService("Workspace")
                mi = game:GetService("Lighting")
                ma = l0.LocalPlayer
                l3 = ma:WaitForChild("PlayerGui")
            else
                mi = game:GetService("Workspace")
                ma = game:GetService("Lighting")
                l3 = Workspace.LocalPlayer
                l0 = l3:WaitForChild("PlayerGui")
            end
            nb = (nb + 35) % 48
        end
    elseif nd_1 <= 5 then
        if nd_1 <= 4 then
            local nd_2 = { "fywoehn", "ygeagcuv", "rda", "gbovnx", "ojweinqddhg", "kob", "dnnjl", "ltrr" }
            local uA = nb
            local ne_2 = nd_2[uA % 8 + 1]
            if ne_2:len() >= ne_2:reverse():rep(uA % 3 + 2):len() then
                l3 = fn127
            else
                m6 = fn127
            end
            nb = (nb + 5) % 48
        else
            local nd_3 = (vector.create((nb * 4 + 4) % 11 + 1, (nb * 9 + 11) % 13 + 1, (nb * 12 + 10) % 17 + 1))
            local u7 = vector.floor(nd_3) + vector.ceil(nd_3 * -1)
            if vector.dot(u7, u7) == 3 then
                nc_1 = game:GetService("Players")
            else
                l0 = game:GetService("Players")
            end
            nb = (nb + 41) % 48
        end
    else
        local nd_4 = (vector.create((nb * 4 + 3) % 11 + 1, (nb * 4 + 12) % 13 + 1, (nb * 2 + 12) % 17 + 1))
        local ne_3 = (vector.create((nb * 1 + 5) % 11 + 1, (nb * 2 + 2) % 13 + 1, (nb * 1 + 11) % 17 + 1))
        local uz = vector.dot(nd_4, ne_3)
        if uz * uz <= vector.dot(nd_4, nd_4) * vector.dot(ne_3, ne_3) then
            nc_1 = game:GetService("ReplicatedStorage")
        else
            ma = game:GetService("ReplicatedStorage")
        end
        nb = (nb + 35) % 48
    end
until (nb * 35 + 21) % 48 == 19
if getgenv then
    mW, nd_5 = nil, nil
    local nb_1 = 8
    repeat
        if (nb_1 * 1 + 1) % 2 + 1 <= 1 then
            local ne_5 = {
                "west",
                "aljbjfxuxmvu",
                "usrq",
                "ooonaw",
                "fzo",
                "wnwrib",
                "xxeykbcmc",
                "ldmgicx",
                "bfxnyj",
                "pktzdm",
                "exdmkyan",
                "bbffl",
                "tooquvbco",
                "zwvmtuf",
                "zoeirai",
                "omgwprw"
            }
            if ne_5[(nb_1 * 40 + 48) % 16 + 1] < ne_5[(nb_1 * 40 + 48) % 16 + 1] then
                mW = nd_5
            else
                nd_5 = mW
            end
            nb_1 = (nb_1 + 11) % 16
        else
            if nb_1 * 95516535 + 2 + 5 >= nb_1 * 95516535 + 2 + 5 + 1 then
                getgenv().gethui = mW
                m6 = getgenv().__TempoBeatAnimeBossLib
            else
                getgenv().gethui = m6
                mW = getgenv().__TempoBeatAnimeBossLib
            end
            nb_1 = (nb_1 + 1) % 16
        end
    until (nb_1 * 1 + 13) % 16 == 1
    if nd_5 then
        nd_5 = mW.Unload
    end
    if nd_5 then
        pcall(function()
            mW:Unload()
        end)
    end
end
pcall(function()
    gethui = m6
end)
if setthreadidentity then
    setthreadidentity(8)
end
mB, mx, mt, mo, me, l7, l1, m3, m_, CharacterConfig, StatsConfig, RequestBossRoll, AttackBoss, BuyUpgrade, RequestSummonerUpgradeConfir, UpgradeSummoner, EquipBestPets, CollectAllChestPets, SellInventory, mT, mM, mG, DataSync, my, mf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
mB = "Beat the Anime Boss!"
mx = "https://discord.gg/K7Qxnxkk46"
mt = "https://discord.gg/K7Qxnxkk46"
mo = "https://tempohub.shop"
me = "#7fd47f"
l7 = "#6ec1ff"
l1 = "#e8a34d"
m3 = "#8b93a3"
m_ = "#e05a5a"
local nd_6 = nc_1:WaitForChild("Remotes")
CharacterConfig = require(nc_1.Config.CharacterConfig)
StatsConfig = require(nc_1.Config.StatsConfig)
RequestBossRoll = nd_6:WaitForChild("RequestBossRoll")
local RollBoss = nd_6:WaitForChild("RollBoss")
AttackBoss = nd_6:WaitForChild("AttackBoss")
BuyUpgrade = nd_6:WaitForChild("BuyUpgrade")
RequestSummonerUpgradeConfir = nd_6:WaitForChild("RequestSummonerUpgradeConfirmation")
UpgradeSummoner = nd_6:WaitForChild("UpgradeSummoner")
local ShowConfirmation = nd_6:WaitForChild("ShowConfirmation")
EquipBestPets = nd_6:WaitForChild("EquipBestPets")
CollectAllChestPets = nd_6:WaitForChild("CollectAllChestPets")
SellInventory = nd_6:WaitForChild("SellInventory")
if (ShowConfirmation or false) and (false or mG) and (false or not RequestBossRoll and not RequestBossRoll) and (mG or ShowConfirmation or RequestBossRoll and mo or (not RequestBossRoll and EquipBestPets or (EquipBestPets or not ShowConfirmation))) and not ((ShowConfirmation or false) and (false or mG) and (false or not RequestBossRoll and not RequestBossRoll) and (mG or ShowConfirmation or RequestBossRoll and mo or (not RequestBossRoll and EquipBestPets or (EquipBestPets or not ShowConfirmation)))) then
    mG = DataSync:WaitForChild("SellHeldPet")
    nd_6 = DataSync:WaitForChild("SetAutoRollActive")
    my = DataSync:WaitForChild("SetAutoClickEnabled")
    mM = DataSync:WaitForChild("DataSync")
    mT = DataSync:WaitForChild("RequestSync")
else
    mT = nd_6:WaitForChild("SellHeldPet")
    mM = nd_6:WaitForChild("SetAutoRollActive")
    mG = nd_6:WaitForChild("SetAutoClickEnabled")
    DataSync = nd_6:WaitForChild("DataSync")
    my = nd_6:WaitForChild("RequestSync")
end
local Communication = nd_6:WaitForChild("Communication")
local Rarities = CharacterConfig.Rarities
mf = {}
for k, v in StatsConfig.Order do
    mf[#mf + 1] = v
end
Library, SaveManager, mV = nil, nil, nil
Library = getgenv().Library
mV = function()
    local function nS(af)
        local nN = not af or not af:IsA("ScreenGui")
        if nN then
            return
        end
        af.ResetOnSpawn = false
        af.IgnoreGuiInset = true
        af.DisplayOrder = math.max(af.DisplayOrder, 1000)
        pcall(function()
            af.ClipToDeviceSafeArea = false
        end)
        pcall(function()
            af.ScreenInsets = Enum.ScreenInsets.None
        end)
        if af.Parent ~= mz then
            af.Parent = mz
        end
    end
    nS(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        nS(Library.ActiveLoading.ScreenGui)
    end
    for k, v in { "Obsidian", "ObsidianLoading" } do
        local nT_1 = mz:FindFirstChild(v) or l3:FindFirstChild(v)
        if nT_1 then
            nS(nT_1)
        end
    end
end
mV()
task.spawn(worker)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoBeatAnimeBossLib = Library
end
Toggles, Options, l2, l5, m7, mF, l8, mQ, mc, m2, mC, mg, m4, mA, mn, l4, mN, mh, m5, mS, l6, mP, m8, mK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
l2 = {
    Money = 0,
    Stats = {},
    SummonerSettings = {},
    ActiveSummonerLevel = 1,
    SummonerLevel = 1,
    AutoClickEnabled = true,
    LockedPets = {},
    LastCharacterId = nil,
    SkipCurrentFight = false,
    BossBusyUntil = 0,
    WeSetAutoClick = false
}
if mS and mh or not mh and mA or (m8 and mS or (mn or m8)) or (mA or mn or mA and not mh or (m8 or not mh) and (not mn and mn)) or not (mS and mh or not mh and mA or (m8 and mS or (mn or m8)) or (mA or mn or mA and not mh or (m8 or not mh) and (not mn and mn))) then
    m7 = fn531
    mF = fn69
    l8 = fn699
    mQ = fn257
else
    l8 = fn531
    mQ = fn69
    m7 = fn699
    mF = fn257
end
mc = fn113
m2 = fn297
mC = fn454
mg = fn199
m4 = fn774
mA = fn362
mn = fn647
l4 = fn543
mN = fn769
mh = fn550
m5 = function(bB)
    pcall(function()
        bB.FireServer(bB)
    end)
end
mS = function(bE)
    local bG = mn()
    pcall(function()
        mM:FireServer(bG, bE == true)
    end)
end
l6 = function(bM)
    pcall(function()
        mG:FireServer(bM == true)
    end)
end
mP = fn681
m8 = fn506
mK = function()
    local oS, oT
    oT = mA()
    if not oT then
        return
    end
    oS = mn()
    pcall(function()
        RequestBossRoll:FireServer(oT, oS)
    end)
end
DataSync.OnClientEvent:Connect(onOnClientEvent)
RollBoss.OnClientEvent:Connect(onOnClientEvent2)
Communication.OnClientEvent:Connect(onOnClientEvent3)
ShowConfirmation.OnClientEvent:Connect(function(cA, cB)
    if not m7("AutoBuyUpgrades") then
        return
    end
    if cA ~= "UpgradeSummoner" then
        return
    end
    if type(cB) ~= "table" then
        return
    end
    local o6 = cB.PlotNumber or mA()
    local o5 = o6
    if o5 then
        pcall(function()
            UpgradeSummoner:FireServer(o5)
        end)
    end
end)
pcall(fn251)
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mx, Copyable = true }, "|", mB },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
l5 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "swords"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in l5 do
    if k ~= "Info" then
        fn728(v)
    end
end
MenuGroup, mp, mZ, mk, mL, mJ, mw, md, na = nil, nil, nil, nil, nil, nil, nil, nil, nil
local function nh_2()
    local p2
    local p1
    p1 = nil
    p2 = nil
    local Label2, Label3, p_, p0, Label
    local function p4()
        local o8 = hookfunction ~= nil
        local o9 = hookmetamethod ~= nil
        local pa = getrawmetatable ~= nil
        local pb = setrawmetatable ~= nil
        local pc = getgc ~= nil
        local pd = getgenv ~= nil
        local pe = getreg ~= nil
        local pf = getconnections ~= nil
        local pg = firesignal ~= nil
        local ph = getcallbackvalue ~= nil
        local pi = setclipboard ~= nil
        local pj = getcustomasset ~= nil
        local pk = getnamecallmethod ~= nil
        local pl = isexecutorclosure ~= nil
        local pm = fireproximityprompt ~= nil
        local pn = firetouchinterest ~= nil
        local po = WebSocket ~= nil
        local pp = readfile ~= nil
        local pq = writefile ~= nil
        local ps = (request or http_request) ~= nil
        local pu = (debug and debug.getupvalues) ~= nil
        local pw = (debug and debug.setupvalue) ~= nil
        local px = 0
        local py = { o8, o9, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk, pl, pm, pn, po, pp, pq, ps, pu, pw }
        for k, v in py do
            if v then
                px += 1
            end
        end
        local o8_1 = px / #py
        if o8_1 >= 0.9 then
            return mc("Full Support", me)
        elseif o8_1 >= 0.6 then
            return mc("Half Support", l1)
        else
            return mc("Low Support", m_)
        end
    end
    p1 = "Unknown"
    pcall(function()
        local pH_1
        local pG_1
        if identifyexecutor then
            pH_1, pG_1 = identifyexecutor()
            local pI = pH_1 ~= ""
            local pJ = type(pH_1) == "string" and pI
            if pJ then
                local pI_1 = type(pG_1) == "string" and pG_1 ~= "" and pH_1 .. " " .. pG_1
                local pG_2 = pI_1
                local pN = if pG_2 then 1 else 0
                local pL = 2186 * pN + 3928 * (1 - pN)
                local pM = 2204 * pN + 3682 * (1 - pN)
                if not ((pL * 3991 + pM * 575 + pL * pM) % 16777213 == 14809570) then
                    pG_2 = pH_1
                end
                p1 = pG_2
            end
        end
    end)
    local p5 = p4()
    p2 = os.clock()
    p_ = function()
        local pR = math.floor(os.clock() - p2)
        if pR < 60 then
            return pR .. "s"
        elseif pR < 3600 then
            return string.format("%dm %ds", math.floor((pR) / (60)), pR % 60)
        else
            return string.format("%dh %dm", math.floor((pR) / (3600)), math.floor((pR % 3600) / (60)))
        end
    end
    local UserGroup = l5.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = ma, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(m2("User", ma.DisplayName .. " @" .. ma.Name, me), true)
    UserGroup:AddLabel(m2("UserId", tostring(ma.UserId), l7), true)
    UserGroup:AddLabel(m2("Executor", p1 .. "  " .. p5, me), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(m2("Session", p_(), l1), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            mC(ma.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            mC("https://www.roblox.com/users/" .. tostring(ma.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = l5.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(m2("Game", mB, l7), true)
    Label2 = SessionGroup:AddLabel(m2("Players", "0/0", me), true)
    p0 = tostring(game.JobId)
    local p5_1 = #p0 > 18 and string.sub(p0, 1, 18) .. "..."
    local p5_2 = p5_1 or p0
    SessionGroup:AddLabel(m2("Job", p5_2, m3), true)
    Label = SessionGroup:AddLabel(m2("Ping", "0 ms", l1), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            mu:Teleport(game.PlaceId, ma)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            mC(p0, "Copied Job ID")
        end
    })
    task.spawn(function()
        local pU_1
        local pT_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(m2("Session", p_(), l1))
            Label2:SetText(m2("Players", #l0:GetPlayers() .. "/" .. tostring(l0.MaxPlayers), me))
            pT_1, pU_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local pT_2 = pT_1 and pU_1 .. " ms" or "n/a"
            Label:SetText(m2("Ping", pT_2, l1))
        end
    end)
    local SocialsGroup = l5.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = mg })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            if setclipboard then
                setclipboard(mt)
            elseif toclipboard then
                toclipboard(mt)
            end
            Library:Notify("Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            mC(mo, "Copied website link")
        end
    })
end
nh_2()
local AutomationGroup = l5.Main:AddLeftGroupbox("Automation", "bot")
AutomationGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
AutomationGroup:AddToggle("AutoFightRoll", { Text = "Auto Fight Roll", Default = false })
AutomationGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
AutomationGroup:AddToggle("AutoCollectCharacters", { Text = "Auto Collect Characters", Default = false })
AutomationGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
local FilteringGroup = l5.Main:AddRightGroupbox("Filtering", "filter")
FilteringGroup:AddToggle("SkipRarity", { Text = "Skip if Rarity", Default = false })
FilteringGroup:AddDropdown("SkipRarities", { Text = "Skip Rarities", Values = Rarities, Multi = true, Default = {} })
FilteringGroup:AddDivider("Health")
FilteringGroup:AddToggle("SkipOverHealth", { Text = "Skip if Over Health", Default = false })
FilteringGroup:AddSlider("MaxBossHealth", { Text = "Max Health", Default = 1000000, Min = 100, Max = 100000000, Rounding = 0 })
local UpgradesGroup = l5.Main:AddLeftGroupbox("Upgrades", "arrow-big-up")
UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
UpgradesGroup:AddDropdown("UpgradeList", {
    Text = "Upgrades",
    Values = mf,
    Multi = true,
    Default = { Luck = true, WalkSpeed = true, RespawnDelay = true }
})
local SellGroup = l5.Main:AddRightGroupbox("Sell", "badge-dollar-sign")
SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
SellGroup:AddDropdown("SellRarities", {
    Text = "Sell Rarities",
    Values = Rarities,
    Multi = true,
    Default = { Common = true, Uncommon = true }
})
SellGroup:AddToggle("SellAllInventory", { Text = "Sell Whole Inventory", Default = false })
Toggles.AutoRoll:OnChanged(fn672)
Toggles.AutoFightRoll:OnChanged(fn237)
mZ = fn734
mk = fn156
mL = function()
    local qp = m4()
    if not qp then
        return
    end
    local Claimer = qp:FindFirstChild("Claimer")
    local qp_1 = Claimer and Claimer:FindFirstChild("Hitbox")
    local qo = qp_1
    local Character = ma.Character
    local qq_1 = Character and Character:FindFirstChild("HumanoidRootPart")
    local qn = qq_1
    if not (qo and qn) then
        return
    end
    if firetouchinterest then
        pcall(function()
            firetouchinterest(qn, qo, 0)
            firetouchinterest(qn, qo, 1)
        end)
    else
        local CFrame = qn.CFrame
        qn.CFrame = qo.CFrame
        task.wait(0.05)
        qn.CFrame = CFrame
    end
end
mJ = fn476
mw = fn440
md = function()
    for k, v in mf do
        local qD = v
        if not not mQ("UpgradeList", qD) then
            local qw = l2.Stats[qD] or 1
            if qD == "Summoner" then
                qw = l2.SummonerLevel or qw
            end
            if not StatsConfig.IsMaxLevel(qD, qw) then
                local qv_2 = StatsConfig.GetUpgradeCost(qD, qw)
                if not (not qv_2 or qv_2 > l2.Money) then
                    if qD == "Summoner" then
                        pcall(function()
                            RequestSummonerUpgradeConfir:FireServer()
                        end)
                    else
                        pcall(function()
                            BuyUpgrade:FireServer(qD)
                        end)
                    end
                    task.wait(0.2)
                end
            end
        end
    end
end
na = fn485
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
local function no()
    local function fJ()
        local Character = ma.Character
        local rc = Character and Character:FindFirstChildOfClass("Humanoid")
        return rc
    end
    local function fO()
        local Character = ma.Character
        local rf = Character and Character:FindFirstChild("HumanoidRootPart")
        return rf
    end
    local MovementGroup = l5.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = l5.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    mU.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if not m7("InfJump") then
            return
        end
        local rh = fJ()
        if rh then
            rh:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    mY.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        local rt = if m7("NoClip") then 1 else 0
        if rt == 1 then
            local Character = ma.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local rj_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if rj_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    mY.RenderStepped:Connect(function(f9)
        if Library.Unloaded then
            return
        end
        if m7("WalkSpeedEnabled") then
            local ru_1 = fJ()
            if ru_1 then
                ru_1.WalkSpeed = mF("WalkSpeed", 32)
            end
        end
        if m7("Fly") then
            local ru_2 = fO()
            local rv = fJ()
            local CurrentCamera = Workspace.CurrentCamera
            if ru_2 and rv and CurrentCamera then
                rv.PlatformStand = true
                local rv_1 = Vector3.zero
                if mU:IsKeyDown(Enum.KeyCode.W) then
                    rv_1 += CurrentCamera.CFrame.LookVector
                end
                if mU:IsKeyDown(Enum.KeyCode.S) then
                    rv_1 -= CurrentCamera.CFrame.LookVector
                end
                if mU:IsKeyDown(Enum.KeyCode.A) then
                    rv_1 -= CurrentCamera.CFrame.RightVector
                end
                if mU:IsKeyDown(Enum.KeyCode.D) then
                    rv_1 += CurrentCamera.CFrame.RightVector
                end
                if mU:IsKeyDown(Enum.KeyCode.Space) then
                    rv_1 += Vector3.new(0, 1, 0)
                end
                if mU:IsKeyDown(Enum.KeyCode.LeftControl) then
                    rv_1 -= Vector3.new(0, 1, 0)
                end
                ru_2.AssemblyLinearVelocity = Vector3.zero
                if rv_1.Magnitude > 0 then
                    ru_2.CFrame = ru_2.CFrame + rv_1.Unit * mF("FlySpeed", 60) * f9
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local rD = fJ()
            if rD then
                rD.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local rF = fJ()
            if rF then
                rF.WalkSpeed = 16
            end
        end
    end)
    local function gv(gw)
        pcall(function()
            mD:SetGameplayPausedNotificationEnabled(not gw)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = mz:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not gw
            end
        end)
        if not gw then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(ma, "GameplayPaused", false)
            else
                ma.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        gv(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                gv(true)
            end
        end
    end)
    local function gN(gO)
        if not gO:IsA("ProximityPrompt") then
            return
        end
        gO.HoldDuration = 0
        gO.MaxActivationDistance = 50
        gO.RequiresLineOfSight = false
    end
    local connection
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in Workspace:GetDescendants() do
                pcall(gN, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(gW)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(gN, gW)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        gv(false)
        if connection then
            connection:Disconnect()
        end
        local rV = fJ()
        if rV then
            rV.PlatformStand = false
        end
    end)
end
no()
MenuGroup = l5.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect", Default = false })
local function nc_2()
    local sx
    local st
    local sv
    st = nil
    sv = nil
    sx = nil
    local sr, ss, connection, sw
    connection = nil
    sw = nil
    sr = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true }
    ss = function(g8, g9)
        pcall(function()
            g8.Enabled = g9
        end)
    end
    sx = function()
        local QualityLevel
        QualityLevel = nil
        if sw then
            return
        end
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
        QualityLevel = nil
        pcall(function()
            QualityLevel = settings().Rendering.QualityLevel
        end)
        sw = {
            QualityLevel = QualityLevel,
            GlobalShadows = mi.GlobalShadows,
            FogEnd = mi.FogEnd,
            Terrain = Terrain,
            WaterWaveSize = Terrain and Terrain.WaterWaveSize,
            WaterReflectance = Terrain and Terrain.WaterReflectance,
            Effects = {}
        }
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        mi.GlobalShadows = false
        mi.FogEnd = 1000000
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterReflectance = 0
        end
        for i, descendant in Workspace:GetDescendants() do
            if sr[descendant.ClassName] and descendant.Enabled then
                sw.Effects[#sw.Effects + 1] = descendant
                ss(descendant, false)
            end
        end
        connection = Workspace.DescendantAdded:Connect(function(ht)
            local rX = sr[ht.ClassName] and m7("FpsBoost")
            if rX then
                ss(ht, false)
            end
        end)
    end
    st = function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        local se = sw
        if not se then
            return
        end
        sw = nil
        if se.QualityLevel then
            pcall(function()
                settings().Rendering.QualityLevel = se.QualityLevel
            end)
        end
        mi.GlobalShadows = se.GlobalShadows
        mi.FogEnd = se.FogEnd
        if se.Terrain and se.Terrain.Parent then
            se.Terrain.WaterWaveSize = se.WaterWaveSize
            se.Terrain.WaterReflectance = se.WaterReflectance
        end
        for k, v in se.Effects do
            ss(v, true)
        end
    end
    sv = function(hL)
        if hL then
            sx()
        else
            st()
        end
    end
    Toggles.FpsBoost:OnChanged(function()
        sv(m7("FpsBoost"))
    end)
    if m7("FpsBoost") then
        sv(true)
    end
    Library:OnUnload(function()
        sv(false)
    end)
end
nc_2()
local function nb_3()
    local hU = false
    local function hV()
        local sz = pcall(function()
            mu:TeleportToPlaceInstance(game.PlaceId, game.JobId, ma)
        end)
        if not sz then
            pcall(function()
                mu:Teleport(game.PlaceId, ma)
            end)
        end
    end
    local function h4()
        local sB = hU or Library.Unloaded
        local sF = if sB then 1 else 0
        local sD = 2459 * sF + 1884 * (1 - sF)
        local sE = 830 * sF + 2887 * (1 - sF)
        if not ((sD * 3257 + sE * 225 + sD * sE) % 16777213 == 10236683) then
            sB = not m7("AutoReconnect")
        end
        if sB then
            return
        end
        hU = true
        task.delay(2, hV)
    end
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if not m7("AutoReconnect") then
                continue
            end
            local RobloxPromptGui = mz:FindFirstChild("RobloxPromptGui")
            local sH = RobloxPromptGui and RobloxPromptGui:FindFirstChild("promptOverlay")
            if not sH then
                continue
            end
            for i, child in sH:GetChildren() do
                local sG_2 = child.Name:find("ErrorPrompt") and child.Visible
                if sG_2 then
                    h4()
                    break
                end
            end
        end
    end)
end
nb_3()
local function nk()
    local connection
    local iq = 0
    local ir = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function iu()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        mO:CaptureController()
        mO:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        iq += 1
        ir = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. iq)
        end)
    end
    connection = ma.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(iu)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local sS = Toggles.AntiAfk.Value and tick() - ir >= 60
            if sS then
                pcall(iu)
            end
        end
    end)
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
nk()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(l5.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BeatTheAnimeBoss")
mp = SaveManager:BuildConfigSection(l5.Settings)
local function ne_7()
    local function iU(iV, iW)
        local sW_1 = (iV == "Toggle" and Toggles or Options)[iW]
        local sV_2 = type(sW_1) == "table" and sW_1.Type == iV
        return sV_2 and sW_1 or nil
    end
    local function i3(i4, i5)
        local Type = i5.Type
        if Type == "Toggle" then
            return { idx = i4, type = "Toggle", value = i5.Value == true }
        elseif Type == "Slider" then
            return { idx = i4, type = "Slider", value = tostring(i5.Value) }
        elseif Type == "Dropdown" then
            return { idx = i4, type = "Dropdown", multi = i5.Multi == true, value = i5.Value }
        elseif Type == "Input" then
            local s2 = i5.Value or ""
            return { idx = i4, type = "Input", text = tostring(s2) }
        elseif Type == "ColorPicker" then
            return { idx = i4, type = "ColorPicker", value = i5.Value:ToHex(), transparency = i5.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = i4,
                type = "KeyPicker",
                mode = i5.Mode,
                key = i5.Value,
                modifiers = i5.Modifiers,
                toggled = i5.Toggled
            }
        else
            return nil
        end
    end
    local function i7()
        local s8 = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local s9 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if s9 then
                    local s9_1 = i3(k, v)
                    if s9_1 then
                        s8[#s8 + 1] = s9_1
                    end
                end
            end
        end
        table.sort(s8, function(jh, ji)
            if jh.type ~= ji.type then
                return jh.type < ji.type
            end
            return jh.idx < ji.idx
        end)
        return { objects = s8 }
    end
    local function jj(jk)
        local tp
        tp = nil
        local tq = type(jk) ~= "table" or type(jk.idx) ~= "string" or type(jk.type) ~= "string" or SaveManager.Ignore[jk.idx]
        if tq then
            return false
        end
        tp = iU(jk.type, jk.idx)
        if not tp then
            return false
        end
        local tq_1 = pcall(function()
            if jk.type == "Input" then
                if type(jk.text) ~= "string" then
                    return
                end
                tp:SetValue(jk.text)
            elseif jk.type == "ColorPicker" then
                tp:SetValueRGB(Color3.fromHex(jk.value), jk.transparency)
            elseif jk.type == "KeyPicker" then
                tp:SetValue({ jk.key, jk.mode, jk.modifiers })
                if jk.mode == "Toggle" and jk.toggled ~= nil then
                    tp.Toggled = jk.toggled
                    tp:Update()
                end
            else
                tp:SetValue(jk.value)
            end
        end)
        return tq_1
    end
    mp:AddDivider()
    mp:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    mp:AddButton("Export Config to Clipboard", function()
        local tt_1
        local ts_1
        ts_1, tt_1 = pcall(mH.JSONEncode, mH, i7())
        if not ts_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local ts_2 = setclipboard or toclipboard
        local ts_3 = type(ts_2) ~= "function" or not pcall(ts_2, tt_1)
        if ts_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    mp:AddButton("Import Config from Clipboard Text", function()
        local ty_1
        local tw = Options.SaveManager_ImportSource.Value or ""
        local tw_1
        local tx = tostring(tw):match("^%s*(.-)%s*$")
        if tx == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        tw_1, ty_1 = pcall(mH.JSONDecode, mH, tx)
        local tx_1 = not tw_1 or type(ty_1) ~= "table" or type(ty_1.objects) ~= "table"
        if tx_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local tw_2 = 0
        for k, v in ty_1.objects do
            if jj(v) then
                tw_2 += 1
            end
        end
        if tw_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local ty_2 = tw_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(tw_2, ty_2), 6)
    end)
end
ne_7()
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn509)
end)(...)
