
-----------------------------------------
-- Corona Helper
--
-- Author: synchrok
-----------------------------------------

-- common define
topLeft = {0, 0}
topRight = {1, 0}
topCenter = {0.5, 0}
centerLeft = {0, 0.5}
center = {0.5, 0.5}
centerRight = {1, 0.5}
bottomLeft = {0, 1}
bottomRight = {1, 1}
bottomCenter = {0.5, 1}

white = {1, 1, 1}
hwhite = {1, 1, 1, 0.5}
black = {0, 0, 0}
hblack = {0, 0, 0, 0.5}

function setReferencePoint( o, referencePoint )
	o.anchorX, o.anchorY = referencePoint[1], referencePoint[2]
end

-- group
function newGroup(parent)
	local g = display.newGroup()
	if parent ~= nil then
		parent:insert(g) end
	return g
end

-- text
defaultFont = "NanumGothic"

function newText(group, text, x, y, font, size, ref, color, w, h)
	if type(font) == "number" then 
		h = w
		w = color
		color = ref
		ref = size
		size = font
		font = nil end
	ref = ref or topLeft
	font = font or defaultFont
	size = size or 20

	if system.getInfo("platformName") == "Win" then
		if ref == topLeft or ref == topRight or ref == topCenter then y = y + 5
		elseif ref == center then y = y + 2
		else y = y + 4 end
	elseif system.getInfo("platformName") == "Android" then
		if ref == topLeft or ref == topRight or ref == topCenter then y = y + 6
		elseif ref == center then y = y + 1
		else y = y + 6 end end

	local t = nil

	if w == nil then
		t = display.newText(group, text, x, y, font, size)
	else
		t = display.newText(group, text, x, y, w, h, font, size) end		

	if ref ~= nil then
		t.anchorX, t.anchorY = ref[1], ref[2] 
		t.x, t.y = x, y end

	if color ~= nil then
		t.fill = color end

	return t
end

function newOLText(group, text, x, y, font, size, ref, color, olColor)
	if type(font) == "number" then 
		olColor = color
		color = ref
		ref = size
		size = font
		font = nil end
		
	local texts = {}
	table.insert(texts, newText(group, text, x-1, y, font, size, ref, olColor))
	table.insert(texts, newText(group, text, x+1, y, font, size, ref, olColor))
	table.insert(texts, newText(group, text, x, y-1, font, size, ref, olColor))
	table.insert(texts, newText(group, text, x, y+1, font, size, ref, olColor))
	table.insert(texts, newText(group, text, x+0.5, y+0.5, font, size, ref, olColor))
	table.insert(texts, newText(group, text, x+0.5, y-0.5, font, size, ref, olColor))
	table.insert(texts, newText(group, text, x-0.5, y+0.5, font, size, ref, olColor))
	table.insert(texts, newText(group, text, x-0.5, y-0.5, font, size, ref, olColor))
	table.insert(texts, newText(group, text, x, y, font, size, ref, color))

	texts.setText = function(t)
		for i, v in pairs(texts) do
			if type(v) ~= "function" then
				texts[i].text = t end
		end
	end

	return texts
end

function newSDText(group, text, x, y, font, size, ref, color, sdColor, offset)
	if type(font) == "number" then 
		offset = sdColor
		sdColor = color
		color = ref
		ref = size
		size = font
		font = nil end
	offset = offset or 1
	newText(group, text, x+offset, y-offset, font, size, ref, sdColor)
	newText(group, text, x, y, font, size, ref, color)
end

function newTextBold(group, text, x, y, font, size, ref, color)
	if type(font) == "number" then 
		color = ref
		ref = size
		size = font
		font = nil end

	local texts = {}
	
	table.insert(texts, newText(group, text, x-0.75, y, font, size, ref, color))
	table.insert(texts, newText(group, text, x+0.75, y, font, size, ref, color))
	table.insert(texts, newText(group, text, x, y, font, size, ref, color))
	
	texts.text = function(t)
		for i, v in pairs(texts) do
			if type(v) ~= "function" then
				texts[i].text = t end
		end
	end

	texts.fill = function(c)
		for i, v in pairs(texts) do
			if type(v) ~= "function" then
				texts[i].fill = c end
		end
	end

	return texts
end

-- image
function newImage(group, path, x, y, ref)
	local img = display.newImage(group, path, x, y)
	if ref ~= nil then
		img.anchorX, img.anchorY = ref[1], ref[2] end
	img.x, img.y = x or 0, y or 0
	return img
end

function newImageRect(group, path, width, height, x, y, ref)
	local img = display.newImageRect(group, path, width, height)
	if ref ~= nil then
		img.anchorX, img.anchorY = ref[1], ref[2] end
	img.x, img.y = x or 0, y or 0
	return img
end

-- rect
function newRect(group, x, y, width, height, color, ref)
	local rect = nil
	if group == nil then
		rect = display.newRect(x, y, width, height)
	else
		rect = display.newRect(group, x, y, width, height) end
	rect.fill = color or white
	if ref ~= nil then
		rect.anchorX, rect.anchorY = ref[1], ref[2] 
		rect.x, rect.y = x, y end
	return rect
end

-- rounded rect
function newRoundedRect(group, x, y, width, height, radius, color, ref)
	local rect = nil
	if group == nil then
		rect = display.newRoundedRect(x, y, width, height, radius)
	else
		rect = display.newRoundedRect(group, x, y, width, height, radius) end
	rect.fill = color or white
	if ref ~= nil then
		rect.anchorX, rect.anchorY = ref[1], ref[2] 
		rect.x, rect.y = x, y end
	return rect
end

-- transition
function fadeIn(object, t, event)
	object.alpha = 0
	transition.to(object, { time=t, alpha=1, onComplete=event })
end

function fadeOut(object, t, event)
	object.alpha = 1
	transition.to(object, { time=t, alpha=0, onComplete=event })
end

-- sound
local bgmOn = true
local bgm = nil
local channels, counter = {}, 1
function playBgm(fileName, o)
	if bgmOn then
		o = o or { }
		if not o.nonStop then
			audio.stop() end
		bgm = audio.loadStream(fileName)
		o.loop = o.loop or true
		channels[o.key or fileName] = audio.play( bgm, { channel=counter, loops=t(not o.loop, 1, -1) } )
		counter = counter + 1
	end
end

function stopBgm(key)
	audio.stop(channels[key])
end

function pauseBgm(key)
	audio.pause(channels[key])
end

function resumeBgm(key)
	audio.resume(channels[key])
end

-- others
function drawLetterbox()
	local w = display.contentWidth
	local h = display.contentHeight

	newRect(nil, display.screenOriginX, 0, -display.screenOriginX, h, black, topLeft)
	newRect(nil, w, 0, w-display.screenOriginX, h, black, topLeft)
	newRect(nil, 0, display.screenOriginY, w, -display.screenOriginY, black, topLeft)
	newRect(nil, 0, h, w, -display.screenOriginY, black, topLeft)
end

function scale(o, v)
	o.xScale, o.yScale = v, v
	return o
end

function groupClear(g)
	local count = g.numChildren
	for i = 1, count do
		g:remove(1)
	end
end

function t( c, a, b ) if c then return a else return b end end

function readFromFile( filename, baseDirectory )
    local baseDirectory = baseDirectory or system.ResourceDirectory
    local path = system.pathForFile( filename, baseDirectory )
    local file = io.open( path, "r" )
    local data = file:read( "*a" )
    io.close( file )
    return data
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
		table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end
