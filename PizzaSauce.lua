-- PizzaSauce: Smooth, declarative animation library for WoW 1.12

local _G = getfenv(0)

local lib = {}
lib.version = "0.1.1"
PizzaSauce = lib

lib._types = {}
lib._easing = {}
lib._active = {}
lib._pending = {}
lib._pendingN = 0
lib._count = 0
lib._finBuf = {}

lib._frame = CreateFrame("Frame", nil, UIParent)
lib._frame:Hide()

local lastTime = GetTime()

local function activate(anim)
  if anim._active then return end
  anim._active = true
  lib._count = lib._count + 1
  lib._active[anim] = true
  if lib._count == 1 then
    lastTime = GetTime()
    lib._frame:Show()
  end
end

local function deactivate(anim)
  if not anim._active then return end
  anim._active = false
  lib._count = lib._count - 1
  lib._active[anim] = nil
  if lib._count <= 0 then
    lib._count = 0
    if lib._pendingN == 0 then lib._frame:Hide() end
  end
end

lib._frame:SetScript("OnUpdate", function()
  local now = GetTime()
  local dt = now - lastTime
  lastTime = now
  if dt <= 0 then return end

  -- Process pending auto-play animations
  local pendingN = lib._pendingN
  if pendingN > 0 then
    lib._pendingN = 0
    for i = 1, pendingN do
      local anim = lib._pending[i]
      lib._pending[i] = nil
      if anim._autoplay then anim:Play() end
    end
  end

  -- Hide driver if nothing to do
  if lib._count == 0 then
    lib._frame:Hide()
    return
  end

  -- Tick all active, collect finished into scratch buffer.
  -- Can't finish inline because _finish() callbacks may create new animations,
  -- which would modify _active while we're iterating it.
  local finN = 0
  for anim in pairs(lib._active) do
    if anim:_tick(dt, now) then
      finN = finN + 1
      lib._finBuf[finN] = anim
    end
  end

  for i = 1, finN do
    lib._finBuf[i]:_finish()
    lib._finBuf[i] = nil
  end
end)

lib._activate = activate
lib._deactivate = deactivate

function lib._schedulePending(anim)
  anim._autoplay = true
  lib._pendingN = lib._pendingN + 1
  lib._pending[lib._pendingN] = anim
  lastTime = GetTime()
  lib._frame:Show()
end

function lib:RegisterType(name, handlers)
  lib._types[name] = handlers
end

function lib:RegisterEasing(name, fn)
  lib._easing[name] = fn
end

function lib:RegisterHelper(name, fn)
  if lib[name] then
    DEFAULT_CHAT_FRAME:AddMessage(
      "PizzaSauce: RegisterHelper('" .. name .. "') would overwrite an existing method")
    return
  end
  lib[name] = fn
end
local E = lib._easing

local pi = math.pi
local sin = math.sin
local cos = math.cos
local pow = math.pow
local sqrt = math.sqrt

E["linear"] = function(t) return t end
E["swing"] = function(t) return 0.5 - cos(t * pi) / 2 end

-- Quad (power of 2)
E["inQuad"] = function(t) return t * t end
E["outQuad"] = function(t) return t * (2 - t) end
E["inOutQuad"] = function(t)
  if t < 0.5 then return 2 * t * t end
  return -1 + (4 - 2 * t) * t
end

-- Cubic (power of 3)
E["inCubic"] = function(t) return t * t * t end
E["outCubic"] = function(t) local u = t - 1; return u * u * u + 1 end
E["inOutCubic"] = function(t)
  if t < 0.5 then return 4 * t * t * t end
  local u = 2 * t - 2; return (u * u * u + 2) / 2
end

-- Quart (power of 4)
E["inQuart"] = function(t) return t * t * t * t end
E["outQuart"] = function(t) local u = t - 1; return 1 - u * u * u * u end
E["inOutQuart"] = function(t)
  if t < 0.5 then return 8 * t * t * t * t end
  local u = t - 1; return 1 - 8 * u * u * u * u
end

-- Quint (power of 5)
E["inQuint"] = function(t) return t * t * t * t * t end
E["outQuint"] = function(t) local u = t - 1; return 1 + u * u * u * u * u end
E["inOutQuint"] = function(t)
  if t < 0.5 then return 16 * t * t * t * t * t end
  local u = t - 1; return 1 + 16 * u * u * u * u * u
end

-- Sine
E["inSine"] = function(t) return 1 - cos(t * pi / 2) end
E["outSine"] = function(t) return sin(t * pi / 2) end
E["inOutSine"] = function(t) return 0.5 - cos(t * pi) / 2 end

-- Expo
E["inExpo"] = function(t)
  if t == 0 then return 0 end
  return pow(2, 10 * (t - 1))
end
E["outExpo"] = function(t)
  if t == 1 then return 1 end
  return 1 - pow(2, -10 * t)
end
E["inOutExpo"] = function(t)
  if t == 0 or t == 1 then return t end
  if t < 0.5 then return pow(2, 20 * t - 10) / 2 end
  return (2 - pow(2, -20 * t + 10)) / 2
end

-- Circ
E["inCirc"] = function(t) return 1 - sqrt(1 - t * t) end
E["outCirc"] = function(t) local u = t - 1; return sqrt(1 - u * u) end
E["inOutCirc"] = function(t)
  if t < 0.5 then return (1 - sqrt(1 - 4 * t * t)) / 2 end
  local u = 2 * t - 2; return (sqrt(1 - u * u) + 1) / 2
end

-- Elastic
E["inElastic"] = function(t)
  if t == 0 or t == 1 then return t end
  return -pow(2, 10 * t - 10) * sin((t * 10 - 10.75) * (2 * pi) / 3)
end
E["outElastic"] = function(t)
  if t == 0 or t == 1 then return t end
  return pow(2, -10 * t) * sin((t * 10 - 0.75) * (2 * pi) / 3) + 1
end
E["inOutElastic"] = function(t)
  if t == 0 or t == 1 then return t end
  if t < 0.5 then
    return -pow(2, 20 * t - 10) * sin((20 * t - 11.125) * (2 * pi) / 4.5) / 2
  end
  return pow(2, -20 * t + 10) * sin((20 * t - 11.125) * (2 * pi) / 4.5) / 2 + 1
end

-- Back
E["inBack"] = function(t)
  local s = 1.70158
  return t * t * ((s + 1) * t - s)
end
E["outBack"] = function(t)
  local s = 1.70158
  local u = t - 1
  return u * u * ((s + 1) * u + s) + 1
end
E["inOutBack"] = function(t)
  local s = 1.70158 * 1.525
  if t < 0.5 then
    return (2 * t) * (2 * t) * ((s + 1) * (2 * t) - s) / 2
  end
  local u = 2 * t - 2
  return (u * u * ((s + 1) * u + s) + 2) / 2
end

-- Bounce
E["outBounce"] = function(t)
  if t < 1 / 2.75 then
    return 7.5625 * t * t
  elseif t < 2 / 2.75 then
    t = t - 1.5 / 2.75
    return 7.5625 * t * t + 0.75
  elseif t < 2.5 / 2.75 then
    t = t - 2.25 / 2.75
    return 7.5625 * t * t + 0.9375
  else
    t = t - 2.625 / 2.75
    return 7.5625 * t * t + 0.984375
  end
end
E["inBounce"] = function(t) return 1 - E["outBounce"](1 - t) end
E["inOutBounce"] = function(t)
  if t < 0.5 then return (1 - E["outBounce"](1 - 2 * t)) / 2 end
  return (1 + E["outBounce"](2 * t - 1)) / 2
end
local function lerp(a, b, t) return a + (b - a) * t end

local function rotCorner(a)
  local r = math.rad(a)
  return 0.5 + math.cos(r) / 1.4142, 0.5 + math.sin(r) / 1.4142
end

local function applyRotation(texture, angle)
  local a = -angle
  local ULx, ULy = rotCorner(a + 225)
  local LLx, LLy = rotCorner(a + 135)
  local URx, URy = rotCorner(a - 45)
  local LRx, LRy = rotCorner(a + 45)
  texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end

lib:RegisterType("alpha", {
  init = function(target, from)
    return from or target:GetAlpha()
  end,
  apply = function(target, from, to, t)
    target:SetAlpha(lerp(from, to, t))
  end,
})

lib:RegisterType("scale", {
  init = function(target, from, to, tween)
    tween._baseW = target:GetWidth()
    tween._baseH = target:GetHeight()
    return from or 1.0
  end,
  apply = function(target, from, to, t, tween)
    local s = lerp(from, to, t)
    target:SetWidth(tween._baseW * s)
    target:SetHeight(tween._baseH * s)
  end,
})

lib:RegisterType("size", {
  init = function(target, from)
    return from or { target:GetWidth(), target:GetHeight() }
  end,
  apply = function(target, from, to, t)
    target:SetWidth(lerp(from[1], to[1], t))
    target:SetHeight(lerp(from[2], to[2], t))
  end,
})

lib:RegisterType("position", {
  init = function(target, from, to, tween)
    local point, rel, relPoint, x, y = target:GetPoint(1)
    tween._point = point or "CENTER"
    tween._rel = rel
    tween._relPoint = relPoint or "CENTER"
    return from or { x or 0, y or 0 }
  end,
  apply = function(target, from, to, t, tween)
    target:ClearAllPoints()
    target:SetPoint(tween._point, tween._rel, tween._relPoint,
      lerp(from[1], to[1], t), lerp(from[2], to[2], t))
  end,
})

lib:RegisterType("color", {
  init = function(target, from)
    return from or { 1, 1, 1, 1 }
  end,
  apply = function(target, from, to, t)
    target:SetVertexColor(
      lerp(from[1], to[1], t),
      lerp(from[2], to[2], t),
      lerp(from[3], to[3], t),
      lerp(from[4] or 1, to[4] or 1, t))
  end,
})

lib:RegisterType("rotation", {
  init = function(target, from)
    return from or 0
  end,
  apply = function(target, from, to, t)
    applyRotation(target, lerp(from, to, t))
  end,
})

lib:RegisterType("custom", {
  init = function(target, from, to, tween)
    if from ~= nil then return from end
    if tween._getter then return tween._getter(target) end
    return 0
  end,
  apply = function(target, from, to, t, tween)
    if tween._setter then
      tween._setter(target, lerp(from, to, t))
    end
  end,
})
local function resolveEasing(easing)
  if type(easing) == "function" then return easing end
  return lib._easing[easing] or lib._easing["inOutQuad"]
end

local Tween = {}

function Tween:Play()
  self._elapsed = 0
  self._started = false
  self._done = false
  lib._activate(self)
end

function Tween:Cancel()
  if not self._active then return end
  lib._deactivate(self)
  self._done = true
  if self._onCancel then self:_onCancel() end
end

function Tween:IsPlaying()
  return self._active == true
end

function Tween:_start()
  local handler = lib._types[self._type]
  if handler and handler.init then
    self._from = handler.init(self._target, self._from, self._to, self)
  end
  self._started = true
  if self._onStart then self:_onStart() end
end

function Tween:_tick(dt)
  self._elapsed = self._elapsed + dt

  if self._elapsed < self._delay then return false end

  if not self._started then self:_start() end

  local t = self._duration > 0
    and math.min((self._elapsed - self._delay) / self._duration, 1)
    or 1

  local handler = lib._types[self._type]
  if handler and handler.apply and self._target then
    handler.apply(self._target, self._from, self._to, resolveEasing(self._easing)(t), self)
  end

  if self._onUpdate then self:_onUpdate(t) end

  return t >= 1
end

function Tween:_finish()
  lib._deactivate(self)
  self._done = true

  -- Apply one final time at exactly t=1 -- the last _tick may have landed
  -- slightly before 1.0 depending on frame timing.
  local handler = lib._types[self._type]
  if handler and handler.apply and self._target then
    handler.apply(self._target, self._from, self._to, 1, self)
  end
  if handler and handler.cleanup then
    handler.cleanup(self._target, self)
  end

  if self._onFinish then self:_onFinish() end
end

function Tween:SetFrom(val) self._from = val end
function Tween:SetTo(val) self._to = val end
function Tween:SetDuration(val) self._duration = val end
function Tween:SetDelay(val) self._delay = val end
function Tween:SetTarget(val) self._target = val end

function Tween:_reset()
  self._elapsed = 0
  self._started = false
  self._done = false
end

local TweenMT = { __index = Tween }

local KNOWN_OPTS = {
  type = true, from = true, to = true, duration = true, easing = true,
  delay = true, onStart = true, onUpdate = true, onFinish = true,
  onCancel = true, getter = true, setter = true, defer = true,
}

function lib:Tween(target, opts)
  local tween = setmetatable({
    _target   = target,
    _type     = opts.type or "alpha",
    _from     = opts.from,
    _to       = opts.to,
    _duration = opts.duration or 0.3,
    _easing   = opts.easing or "inOutQuad",
    _delay    = opts.delay or 0,
    _onStart  = opts.onStart,
    _onUpdate = opts.onUpdate,
    _onFinish = opts.onFinish,
    _onCancel = opts.onCancel,
    _getter   = opts.getter,
    _setter   = opts.setter,
  }, TweenMT)

  -- Forward extra opts to the tween for custom type handlers.
  -- Internal fields use underscore prefix, so user params (vx, radius, etc.)
  -- are accessible as tween.vx, tween.radius without collision.
  for k, v in pairs(opts) do
    if not KNOWN_OPTS[k] then
      tween[k] = v
    end
  end

  if not opts.defer then
    lib._schedulePending(tween)
  end

  return tween
end
local Sequence = {}

function Sequence:Play()
  self._index = 1
  self._loopCount = 0
  self._elapsed = 0
  self._done = false
  self:_resetChildren()
  lib._activate(self)
end

function Sequence:Cancel()
  if not self._active then return end
  local child = self._children[self._index]
  if child and child._started and child.Cancel then child:Cancel() end
  lib._deactivate(self)
  self._done = true
  if self._onCancel then self:_onCancel() end
end

function Sequence:IsPlaying()
  return self._active == true
end

function Sequence:_tick(dt)
  self._elapsed = self._elapsed + dt
  if self._elapsed < self._delay then return false end

  local child = self._children[self._index]
  if not child then return true end

  if not child._started then child:_start() end

  if child:_tick(dt) then
    child:_finish()
    self._index = self._index + 1

    if self._index > table.getn(self._children) then
      return self:_handleLoop()
    end
  end

  return false
end

function Sequence:_finish()
  lib._deactivate(self)
  self._done = true
  if self._onFinish then self:_onFinish() end
end

function Sequence:_start()
  self._started = true
end

function Sequence:_reset()
  self._index = 1
  self._loopCount = 0
  self._elapsed = 0
  self._done = false
  self._started = false
  self:_resetChildren()
end

function Sequence:_resetChildren()
  for i = 1, table.getn(self._children) do
    self._children[i]:_reset()
  end
end

function Sequence:_handleLoop()
  self._loopCount = self._loopCount + 1
  if self._loop ~= 0 and self._loopCount >= self._loop then
    return true
  end

  if self._yoyo then
    local c = self._children
    local n = table.getn(c)
    for i = 1, math.floor(n / 2) do
      c[i], c[n - i + 1] = c[n - i + 1], c[i]
    end
  end

  self._index = 1
  self:_resetChildren()
  return false
end

local SequenceMT = { __index = Sequence }

function lib:Sequence(children, opts)
  opts = opts or {}

  for i = 1, table.getn(children) do
    children[i]._autoplay = false
  end

  local seq = setmetatable({
    _children  = children,
    _index     = 1,
    _loop      = opts.loop or 1,
    _yoyo      = opts.yoyo or false,
    _loopCount = 0,
    _delay     = opts.delay or 0,
    _elapsed   = 0,
    _onFinish  = opts.onFinish,
    _onCancel  = opts.onCancel,
    _done      = false,
  }, SequenceMT)

  if not opts.defer then
    lib._schedulePending(seq)
  end

  return seq
end
local Group = {}

function Group:Play()
  self._loopCount = 0
  self._elapsed = 0
  self._done = false
  self:_resetChildren()
  lib._activate(self)
end

function Group:Cancel()
  if not self._active then return end
  for i = 1, table.getn(self._children) do
    local child = self._children[i]
    if child._active or child._started then
      if child.Cancel then child:Cancel() end
    end
  end
  lib._deactivate(self)
  self._done = true
  if self._onCancel then self:_onCancel() end
end

function Group:IsPlaying()
  return self._active == true
end

function Group:_tick(dt)
  self._elapsed = self._elapsed + dt
  if self._elapsed < self._delay then return false end

  local allDone = true

  for i = 1, table.getn(self._children) do
    local child = self._children[i]
    if not child._done then
      if not child._started then child:_start() end
      if child:_tick(dt) then
        child:_finish()
      else
        allDone = false
      end
    end
  end

  if allDone then
    return self:_handleLoop()
  end
  return false
end

function Group:_handleLoop()
  self._loopCount = self._loopCount + 1
  if self._loop ~= 0 and self._loopCount >= self._loop then
    return true
  end

  if self._yoyo then
    local c = self._children
    local n = table.getn(c)
    for i = 1, math.floor(n / 2) do
      c[i], c[n - i + 1] = c[n - i + 1], c[i]
    end
  end

  self:_resetChildren()
  return false
end

function Group:_finish()
  lib._deactivate(self)
  self._done = true
  if self._onFinish then self:_onFinish() end
end

function Group:_start()
  self._started = true
end

function Group:_reset()
  self._loopCount = 0
  self._elapsed = 0
  self._done = false
  self._started = false
  self:_resetChildren()
end

function Group:_resetChildren()
  for i = 1, table.getn(self._children) do
    self._children[i]:_reset()
  end
end

local GroupMT = { __index = Group }

function lib:Group(children, opts)
  opts = opts or {}

  for i = 1, table.getn(children) do
    children[i]._autoplay = false
  end

  local grp = setmetatable({
    _children  = children,
    _loop      = opts.loop or 1,
    _yoyo      = opts.yoyo or false,
    _loopCount = 0,
    _delay     = opts.delay or 0,
    _elapsed   = 0,
    _onFinish  = opts.onFinish,
    _onCancel  = opts.onCancel,
    _done      = false,
  }, GroupMT)

  if not opts.defer then
    lib._schedulePending(grp)
  end

  return grp
end
-- Directional offsets for slide animations
local directions = {
  LEFT  = function(d) return { -d, 0 } end,
  RIGHT = function(d) return {  d, 0 } end,
  UP    = function(d) return {  0, d } end,
  DOWN  = function(d) return {  0,-d } end,
}

local function dirOffset(dir, dist)
  local fn = directions[string.upper(dir or "LEFT")]
  return fn and fn(dist) or { 0, 0 }
end

local function getAnchorPos(frame)
  local _, _, _, x, y = frame:GetPoint(1)
  return { x or 0, y or 0 }
end

local EMPTY = {}
local function opts(o)
  if type(o) == "table" then return o end
  return EMPTY
end

-- ============================================================
-- Alpha
-- ============================================================

function lib:FadeTo(target, toAlpha, duration, easing, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "alpha", to = toAlpha,
    duration = duration, easing = easing,
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

function lib:FadeIn(target, duration, easing, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "alpha", from = 0, to = 1,
    duration = duration, easing = easing,
    onStart = function()
      target:SetAlpha(0)
      target:Show()
      if o.onStart then o.onStart() end
    end,
    delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

function lib:FadeOut(target, duration, easing, o)
  o = opts(o)
  local onFinish = o.onFinish
  return lib:FadeTo(target, 0, duration, easing, {
    delay = o.delay, onCancel = o.onCancel, defer = o.defer,
    onFinish = function() target:Hide(); if onFinish then onFinish() end end,
  })
end

function lib:Flash(target, count, duration, o)
  o = opts(o)
  count = count or 3
  duration = duration or 0.6
  local half = duration / count / 2
  local steps = {}
  for i = 1, count do
    table.insert(steps, lib:Tween(target, { type = "alpha", to = 0, duration = half, easing = "inQuad", defer = true }))
    table.insert(steps, lib:Tween(target, { type = "alpha", to = 1, duration = half, easing = "outQuad", defer = true }))
  end
  return lib:Sequence(steps, { delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

function lib:Breathe(target, minAlpha, maxAlpha, duration, o)
  o = opts(o)
  duration = duration or 1.6
  local half = duration / 2
  return lib:Sequence({
    lib:Tween(target, { type = "alpha", from = minAlpha, to = maxAlpha, duration = half, easing = "inOutQuad", defer = true }),
    lib:Tween(target, { type = "alpha", from = maxAlpha, to = minAlpha, duration = half, easing = "inOutQuad", defer = true }),
  }, { loop = 0, delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

-- ============================================================
-- Scale
-- ============================================================

function lib:ScaleIn(target, duration, easing, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "scale", from = 0, to = 1,
    duration = duration or 0.3, easing = easing or "outBack",
    onStart = function()
      target:Show()
      if o.onStart then o.onStart() end
    end,
    delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

function lib:ScaleOut(target, duration, easing, o)
  o = opts(o)
  local onFinish = o.onFinish
  return lib:Tween(target, {
    type = "scale", from = 1, to = 0,
    duration = duration or 0.3, easing = easing or "inBack",
    onStart = o.onStart,
    onFinish = function() target:Hide(); if onFinish then onFinish() end end,
    onCancel = o.onCancel, delay = o.delay, defer = o.defer,
  })
end

function lib:Pulse(target, scale, duration, o)
  o = opts(o)
  scale = scale or 1.3
  local half = (duration or 0.4) / 2
  local baseW, baseH = target:GetWidth(), target:GetHeight()
  local function set(f, s)
    f:SetWidth(baseW * s)
    f:SetHeight(baseH * s)
  end
  return lib:Sequence({
    lib:Tween(target, { type = "custom", from = 1.0, to = scale, duration = half, easing = "outQuad", setter = set, defer = true }),
    lib:Tween(target, { type = "custom", from = scale, to = 1.0, duration = half, easing = "inQuad", setter = set, defer = true }),
  }, { delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

function lib:Rubber(target, scale, duration, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "scale", from = scale or 1.3, to = 1.0,
    duration = duration or 0.5, easing = "outElastic",
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

function lib:Flip(target, axis, duration, o)
  o = opts(o)
  local quarter = (duration or 0.8) / 4
  local horizontal = axis ~= "y"
  local base = horizontal and target:GetWidth() or target:GetHeight()
  local set = horizontal
    and function(f, v) f:SetWidth(v) end
    or function(f, v) f:SetHeight(v) end

  -- Find child textures to mirror via SetTexCoord
  local textures = {}
  if target.GetTexture then
    table.insert(textures, target)
  else
    local children = { target:GetRegions() }
    for i = 1, table.getn(children) do
      if children[i].GetTexture then table.insert(textures, children[i]) end
    end
  end

  local function mirror()
    for i = 1, table.getn(textures) do
      if horizontal then
        textures[i]:SetTexCoord(1, 0, 0, 1)
      else
        textures[i]:SetTexCoord(0, 1, 1, 0)
      end
    end
  end

  local function unmirror()
    for i = 1, table.getn(textures) do
      textures[i]:SetTexCoord(0, 1, 0, 1)
    end
  end

  local shrink = function(f, v) set(f, v) end
  return lib:Sequence({
    -- 0°→90°: shrink to invisible
    lib:Tween(target, { type = "custom", from = base, to = 0.01, duration = quarter, easing = "inQuad", setter = shrink, defer = true }),
    -- 90°→180°: mirror and expand (showing flipped content)
    lib:Tween(target, { type = "custom", from = 0.01, to = base, duration = quarter, easing = "outQuad", setter = shrink, defer = true,
      onStart = function() mirror() end }),
    -- 180°→270°: shrink again
    lib:Tween(target, { type = "custom", from = base, to = 0.01, duration = quarter, easing = "inQuad", setter = shrink, defer = true }),
    -- 270°→360°: unmirror and expand back to original
    lib:Tween(target, { type = "custom", from = 0.01, to = base, duration = quarter, easing = "outQuad", setter = shrink, defer = true,
      onStart = function() unmirror() end }),
  }, { delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

-- ============================================================
-- Position
-- ============================================================

function lib:Move(target, from, to, duration, easing, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "position", from = from, to = to,
    duration = duration or 0.3, easing = easing,
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

function lib:MoveTo(target, to, duration, easing, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "position", to = to,
    duration = duration, easing = easing,
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

function lib:SlideIn(target, direction, distance, duration, easing, o)
  o = opts(o)
  local dest = getAnchorPos(target)
  local offset = dirOffset(direction, distance or 100)
  local from = { dest[1] - offset[1], dest[2] - offset[2] }
  return lib:Group({
    lib:Tween(target, {
      type = "position", from = from, to = dest, duration = duration or 0.3, easing = easing or "outCubic",
      onStart = function()
        target:SetAlpha(0)
        target:Show()
        if o.onStart then o.onStart() end
      end,
      defer = true,
    }),
    lib:Tween(target, {
      type = "alpha",
      from = 0,
      to = 1,
      duration = (duration or 0.3) * 0.6,
      easing = "outQuad",
      defer = true,
    }),
  }, { delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

function lib:SlideOut(target, direction, distance, duration, easing, o)
  o = opts(o)
  local from = getAnchorPos(target)
  local offset = dirOffset(direction, distance or 100)
  local dest = { from[1] + offset[1], from[2] + offset[2] }
  local onFinish = o.onFinish
  return lib:Group({
    lib:Tween(target, { type = "position", from = from, to = dest, duration = duration or 0.3, easing = easing or "inCubic", defer = true }),
    lib:Tween(target, { type = "alpha", to = 0, duration = duration or 0.3, easing = "inQuad", defer = true }),
  }, {
    delay = o.delay, onCancel = o.onCancel, defer = o.defer,
    onFinish = function() target:Hide(); if onFinish then onFinish() end end,
  })
end

function lib:Bounce(target, height, count, duration, o)
  o = opts(o)
  height = height or 30
  count = count or 3
  duration = duration or 0.6
  local pos = getAnchorPos(target)
  local steps = {}
  for i = 1, count do
    local h = height * (1 - (i - 1) / count)  -- decay
    table.insert(steps, lib:Tween(target, {
      type = "position", from = pos, to = { pos[1], pos[2] + h },
      duration = duration / count / 2, easing = "outQuad", defer = true,
    }))
    table.insert(steps, lib:Tween(target, {
      type = "position", from = { pos[1], pos[2] + h }, to = pos,
      duration = duration / count / 2, easing = "inQuad", defer = true,
    }))
  end
  return lib:Sequence(steps, { delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

function lib:Shake(target, intensity, duration, o)
  o = opts(o)
  intensity = intensity or 5
  duration = duration or 0.3
  local pos = getAnchorPos(target)
  local steps = {}
  local stepDur = 0.03
  local numSteps = math.floor(duration / stepDur)
  for i = 1, numSteps do
    local decay = 1 - (i - 1) / numSteps
    local dx = (math.random() * intensity * 2 - intensity) * decay
    local dy = (math.random() * intensity * 2 - intensity) * decay
    table.insert(steps, lib:Tween(target, {
      type = "position", to = { pos[1] + dx, pos[2] + dy },
      duration = stepDur, easing = "linear", defer = true,
    }))
  end
  -- Snap back to original position
  table.insert(steps, lib:Tween(target, {
    type = "position", to = pos,
    duration = stepDur, easing = "linear", defer = true,
  }))
  return lib:Sequence(steps, { delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

function lib:FlyTo(frame, targetFrame, duration, easing, o)
  o = opts(o)
  local toX = targetFrame:GetLeft() + targetFrame:GetWidth() / 2 - UIParent:GetWidth() / 2
  local toY = targetFrame:GetBottom() + targetFrame:GetHeight() / 2 - UIParent:GetHeight() / 2
  return lib:Tween(frame, {
    type = "position", to = { toX, toY },
    duration = duration or 0.5, easing = easing or "inOutQuad",
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

-- ============================================================
-- Rotation
-- ============================================================

function lib:Spin(texture, degreesPerSecond, o)
  o = opts(o)
  local dps = degreesPerSecond or 90
  return lib:Sequence({
    lib:Tween(texture, {
      type = "rotation",
      from = 0,
      to = dps > 0 and 360 or -360,
      duration = 360 / math.abs(dps),
      easing = "linear",
      defer = true,
    }),
  }, { loop = 0, delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

-- ============================================================
-- Color
-- ============================================================

function lib:Color(target, from, to, duration, easing, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "color", from = from, to = to,
    duration = duration or 0.3, easing = easing,
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

function lib:ColorFlash(texture, r, g, b, duration, o)
  o = opts(o)
  duration = duration or 0.4
  local half = duration / 2
  return lib:Sequence({
    lib:Tween(texture, { type = "color", to = { r, g, b, 1 }, duration = half, easing = "outQuad", defer = true }),
    lib:Tween(texture, { type = "color", from = { r, g, b, 1 }, to = { 1, 1, 1, 1 }, duration = half, easing = "inQuad", defer = true }),
  }, { delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

-- ============================================================
-- Size
-- ============================================================

function lib:Size(target, from, to, duration, easing, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "size", from = from, to = to,
    duration = duration or 0.3, easing = easing,
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

function lib:Morph(target, to, duration, easing, o)
  o = opts(o)
  return lib:Tween(target, {
    type = "size", to = to,
    duration = duration or 0.3, easing = easing,
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

-- ============================================================
-- Value
-- ============================================================

function lib:Progress(statusbar, toValue, duration, easing, o)
  o = opts(o)
  return lib:Tween(statusbar, {
    type = "custom",
    to = toValue,
    duration = duration or 0.4,
    easing = easing or "outCubic",
    getter = function(bar) return bar:GetValue() end,
    setter = function(bar, val) bar:SetValue(val) end,
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

-- ============================================================
-- Text
-- ============================================================

function lib:Typewriter(fontstring, text, duration, o)
  o = opts(o)
  local len = string.len(text)
  return lib:Tween(fontstring, {
    type = "custom",
    from = 0, to = len,
    duration = duration or len * 0.05,
    easing = "linear",
    setter = function(fs, val)
      fs:SetText(string.sub(text, 1, math.floor(val)))
    end,
    delay = o.delay, onStart = o.onStart, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer,
  })
end

-- ============================================================
-- Clipping (Reveal / Conceal)
-- ============================================================

-- Progressively reveal a texture from a direction by re-anchoring
-- to one edge, animating width/height, and shifting tex coords.
local clipAnchors = {
  LEFT  = { "TOPLEFT",     "TOPLEFT"     },
  RIGHT = { "TOPRIGHT",    "TOPRIGHT"    },
  UP    = { "TOPLEFT",     "TOPLEFT"     },
  DOWN  = { "BOTTOMLEFT",  "BOTTOMLEFT"  },
}

local function clipTween(target, direction, duration, easing, from, to, o)
  o = opts(o)
  direction = string.upper(direction or "LEFT")
  duration = duration or 0.3

  local parent = target:GetParent()
  local baseW = target._clipBaseW or parent:GetWidth()
  local baseH = target._clipBaseH or parent:GetHeight()
  target._clipBaseW = baseW
  target._clipBaseH = baseH

  local horizontal = (direction == "LEFT" or direction == "RIGHT")
  local reversed = (direction == "RIGHT" or direction == "UP")
  local anchor = clipAnchors[direction]

  target:ClearAllPoints()
  target:SetPoint(anchor[1], parent, anchor[2], 0, 0)

  return lib:Tween(target, {
    type = "custom", from = from, to = to,
    duration = duration, easing = easing or "outQuad",
    setter = function(tex, t)
      if horizontal then
        tex:SetWidth(math.max(baseW * t, 0.01))
        tex:SetHeight(baseH)
        if reversed then
          tex:SetTexCoord(1 - t, 1, 0, 1)
        else
          tex:SetTexCoord(0, t, 0, 1)
        end
      else
        tex:SetWidth(baseW)
        tex:SetHeight(math.max(baseH * t, 0.01))
        if reversed then
          tex:SetTexCoord(0, 1, 1 - t, 1)
        else
          tex:SetTexCoord(0, 1, 0, t)
        end
      end
    end,
    onFinish = function()
      target:SetTexCoord(0, 1, 0, 1)
      target:ClearAllPoints()
      target:SetAllPoints(parent)
      if o.onFinish then o.onFinish() end
    end,
    onCancel = o.onCancel, delay = o.delay, defer = o.defer,
  })
end

function lib:Reveal(target, direction, duration, easing, o)
  target:Show()
  return clipTween(target, direction, duration, easing, 0, 1, o)
end

function lib:Conceal(target, direction, duration, easing, o)
  o = opts(o)
  local onFinish = o.onFinish
  return clipTween(target, direction, duration, easing, 1, 0, {
    delay = o.delay, onCancel = o.onCancel, defer = o.defer,
    onFinish = function() target:Hide(); if onFinish then onFinish() end end,
  })
end

-- WipeIn/WipeOut: texture slides in from a direction while being clipped.
-- Unlike Reveal/Conceal where the image is stationary and a window opens,
-- here the image physically moves into view (like sliding out from under a cover).
-- WipeIn/WipeOut: the image slides into/out of view while being clipped.
-- The texture stays full-size (no stretching) -- we clip by shrinking the
-- visible region and offsetting tex coords so the revealed portion matches
-- the correct part of the image.
--
-- For "LEFT" (image slides in from the left edge):
--   anchor at TOPLEFT, width = baseW * t, texCoord left = 1-t
--   → at t=0 nothing visible; at t=1 full image
local wipeAnchors = {
  LEFT  = "TOPLEFT",
  RIGHT = "TOPRIGHT",
  UP    = "TOPLEFT",
  DOWN  = "BOTTOMLEFT",
}

local function wipeTween(target, direction, duration, easing, from, to, o)
  o = opts(o)
  direction = string.upper(direction or "LEFT")
  duration = duration or 0.3

  local parent = target:GetParent()
  local baseW = target._clipBaseW or parent:GetWidth()
  local baseH = target._clipBaseH or parent:GetHeight()
  target._clipBaseW = baseW
  target._clipBaseH = baseH

  local horizontal = (direction == "LEFT" or direction == "RIGHT")
  local anchor = wipeAnchors[direction]

  target:ClearAllPoints()
  target:SetPoint(anchor, parent, anchor, 0, 0)

  return lib:Tween(target, {
    type = "custom", from = from, to = to,
    duration = duration, easing = easing or "outQuad",
    setter = function(tex, t)
      if horizontal then
        tex:SetWidth(math.max(baseW * t, 0.01))
        tex:SetHeight(baseH)
        if direction == "LEFT" then
          tex:SetTexCoord(1 - t, 1, 0, 1)
        else
          tex:SetTexCoord(0, t, 0, 1)
        end
      else
        tex:SetWidth(baseW)
        tex:SetHeight(math.max(baseH * t, 0.01))
        if direction == "DOWN" then
          tex:SetTexCoord(0, 1, 1 - t, 1)
        else
          tex:SetTexCoord(0, 1, 0, t)
        end
      end
    end,
    onFinish = function()
      target:SetTexCoord(0, 1, 0, 1)
      target:ClearAllPoints()
      target:SetAllPoints(parent)
      if o.onFinish then o.onFinish() end
    end,
    onCancel = o.onCancel, delay = o.delay, defer = o.defer,
  })
end

local wipeInFlip = { LEFT="RIGHT", RIGHT="LEFT", UP="DOWN", DOWN="UP" }

function lib:WipeIn(target, direction, duration, easing, o)
  target:Show()
  local dir = wipeInFlip[string.upper(direction or "LEFT")] or direction
  return wipeTween(target, dir, duration, easing, 0, 1, o)
end

function lib:WipeOut(target, direction, duration, easing, o)
  o = opts(o)
  local onFinish = o.onFinish
  return wipeTween(target, direction, duration, easing, 1, 0, {
    delay = o.delay, onCancel = o.onCancel, defer = o.defer,
    onFinish = function() target:Hide(); if onFinish then onFinish() end end,
  })
end

-- ============================================================
-- Meta / Utility
-- ============================================================

function lib:Stagger(targets, animFn, delay, o)
  o = opts(o)
  delay = delay or 0.08
  local children = {}
  for i = 1, table.getn(targets) do
    local anim = animFn(targets[i], i)
    anim._autoplay = false
    if i > 1 then
      table.insert(children, lib:Sequence({ lib:Delay(delay * (i - 1)), anim }, { defer = true }))
    else
      table.insert(children, anim)
    end
  end
  return lib:Group(children, { delay = o.delay, onFinish = o.onFinish, onCancel = o.onCancel, defer = o.defer })
end

function lib:Delay(duration)
  -- A no-op tween that just waits. Uses a dummy target-less approach.
  local dummy = lib._frame
  return lib:Tween(dummy, {
    type = "alpha",
    from = dummy:GetAlpha(),
    to = dummy:GetAlpha(),
    duration = duration or 1,
    defer = true,
  })
end

function lib:Run(fn, o)
  o = opts(o)
  return lib:Tween(nil, {
    type = "custom", from = 0, to = 0, duration = 0,
    onStart = fn, delay = o.delay, defer = o.defer,
  })
end

function lib:Stop(target)
  for anim in pairs(lib._active) do
    if anim._target == target then
      anim:Cancel()
    elseif anim._children then
      lib:_stopInChildren(anim, anim, target)
    end
  end
  -- Also cancel pending (not yet started) animations for this target
  for i = 1, lib._pendingN do
    local anim = lib._pending[i]
    if anim then
      if anim._target == target then
        anim._autoplay = false
      elseif anim._children then
        if lib:_hasTargetInChildren(anim, target) then
          anim._autoplay = false
        end
      end
    end
  end
end

function lib:_hasTargetInChildren(parent, target)
  for i = 1, table.getn(parent._children) do
    local child = parent._children[i]
    if child._target == target then return true end
    if child._children and lib:_hasTargetInChildren(child, target) then return true end
  end
  return false
end

function lib:_stopInChildren(root, parent, target)
  for i = 1, table.getn(parent._children) do
    local child = parent._children[i]
    if child._target == target then
      root:Cancel()
      return
    elseif child._children then
      lib:_stopInChildren(root, child, target)
      if not root._active then return end
    end
  end
end
