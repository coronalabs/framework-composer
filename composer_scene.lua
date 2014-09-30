-----------------------------------------------------------------------------------------
--
-- composer_scene.lua
--
-----------------------------------------------------------------------------------------

-- still cheating. Which object is the Runtime super? EventListener?
local Super = Runtime._super

-- the scene object
local Scene = Super:new()

-- libraries we need
local json = require( "json" )
local physics = require( "physics" )

local function print_r(object, mesg)
	if mesg then
		tag = mesg .. ": "
	else
		tag = ""
	end

	--print(tag .. json.encode(object, { indent = true }))
end

-- Needed because the table order gets scrambled by JSON roundtrip
local function unpack_color(rgbTable)
	local r = rgbTable.r
	local g = rgbTable.g
	local b = rgbTable.b
	return r, g, b
end

-----------------------------------------------------------------------------------------
-- initialize()
-- class constructor
-----------------------------------------------------------------------------------------
function Scene:initialize()
	Super.initialize( self )
	self.view = Super.view
	self._objects = {}
	self._hasPhysics = false
end

function Scene:setComposerSceneName( file )
	self._composerFileName = file
end

function Scene:getComposerSceneName()
	return self._composerFileName
end

-------

-- graphics object handling

-------

-- splits a string by a pattern
local function split(string, pat)
  pat = pat or '%s+'
  local st, g = 1, string:gmatch("()("..pat..")")
  local function getter(segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return string:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  return function() if st then return getter(st, g()) end end
end

-- create a display group
local function _newGroup( params )
	local group = display.newGroup()
	if params.tag then
		group.tag = params.tag
	end
	
	return group
end

local function getGroupByTag ( group, groupTag )
	
	local returnGroup
	
	for i = 1, group.numChildren do
		
		local child = group[ i ]
		
		-- if we have a tag, return it
		if groupTag == child.tag then
			returnGroup = child
		end
		
		if child.numChildren and child.numChildren > 0 then
			getGroupByTag( child, groupTag )
		end
	end
	
	return returnGroup

end


-- create a image
local function _newImage( params )
	
	local methodArgs = {}
	
	if params.parentGroup then
		local group = getGroupByTag( display.getCurrentStage(), params.parentGroup )
		if group then
			table.insert ( methodArgs, group )
		end
	end
	
	if params.baseDir then
		table.insert( methodArgs, params.baseDir )
	end
	
	if params.imageFile then
		table.insert( methodArgs, params.imageFile )
	end

	if params.x then
		table.insert( methodArgs, params.x )
	end
	
	if params.y then
		table.insert( methodArgs, params.y )
	end
	
	table.insert( methodArgs, true )
	
	newImage = display.newImage( unpack( methodArgs ) )
	
	if params.physicsEnabled then
		newImage.width = newImage.width * params.xScale
		newImage.height = newImage.height * params.yScale
	end

	return newImage
	
end

-- create a rectangle
local function _newRect ( params )
	
	local methodArgs = {}
	
	if params.parentGroup then
		local group = newDisplay.getGroupByTag( display.getCurrentStage(), params.parentGroup )
		if group then
			table.insert ( methodArgs, group )
		end
	end

	if params.x then
		table.insert( methodArgs, params.x )
	end
	
	if params.y then
		table.insert( methodArgs, params.y )
	end

	if params.rectWidth then
		if params.physicsEnabled then
			table.insert( methodArgs, params.rectWidth * params.xScale )
		else
			table.insert( methodArgs, params.rectWidth )
		end
	end
	
	if params.rectHeight then
		if params.physicsEnabled then
			table.insert( methodArgs, params.rectHeight * params.yScale )
		else
			table.insert( methodArgs, params.rectHeight )
		end
	end
	
	local newRect = display.newRect( unpack ( methodArgs ) )
	
	if params.fillColor then
		--[[
		local fillTable = {}
		for token in split( params.fillColor, "," ) do
   			table.insert( fillTable, tonumber( token ) )
		end
		newRect:setFillColor( unpack( fillTable ) )
		--]]
		newRect:setFillColor( unpack_color(params.fillColor) )
	end
	
	if params.strokeColor then
		--[[
		local strokeTable = {}
		for token in split( params.strokeColor, "," ) do
   			table.insert( strokeTable, tonumber( token ) )
		end
		newRect:setStrokeColor( unpack( strokeTable ) )
		--]]
		newRect:setStrokeColor( unpack_color(params.strokeColor) )
	end
	
	if params.strokeWidth then
		newRect.strokeWidth = params.strokeWidth
	end
	
	return newRect
	
end

-- create a circle
local function _newCircle ( params )
	
	local methodArgs = {}
	
	if params.parentGroup then
		local group = newDisplay.getGroupByTag( display.getCurrentStage(), params.parentGroup )
		if group then
			table.insert ( methodArgs, group )
		end
	end

	if params.x then
		table.insert( methodArgs, params.x )
	end
	
	if params.y then
		table.insert( methodArgs, params.y )
	end

	if params.circleRadius then
		table.insert( methodArgs, params.circleRadius )
	end
	
	local newCircle = display.newCircle( unpack ( methodArgs ) )
	
	--newCircle.width = newCircle.width * params.xScale
	--newCircle.height = newCircle.height * params.yScale
	newCircle.width = newCircle.width
	newCircle.height = newCircle.height

	if params.physicsEnabled then
		newCircle.width = newCircle.width * params.xScale
		newCircle.height = newCircle.height * params.yScale
	end

	if params.fillColor then
		--[[
		local fillTable = {}
		for token in split( params.fillColor, "," ) do
   			table.insert( fillTable, tonumber( token ) )
		end
		newCircle:setFillColor( unpack( fillTable ) )
		--]]
		newCircle:setFillColor( unpack_color(params.fillColor) )
	end
	
	if params.strokeColor then
		--[[
		local strokeTable = {}
		for token in split( params.strokeColor, "," ) do
   			table.insert( strokeTable, tonumber( token ) )
		end
		newCircle:setStrokeColor( unpack( strokeTable ) )
		--]]
		newCircle:setStrokeColor( unpack_color(params.strokeColor) )
	end
	
	if params.strokeWidth then
		newCircle.strokeWidth = params.strokeWidth
	end
	
	return newCircle
	
end

-- create a line
local function _newLine ( params )
	
	local methodArgs = {}
	
	if params.parentGroup then
		local group = newDisplay.getGroupByTag( display.getCurrentStage(), params.parentGroup )
		if group then
			table.insert ( methodArgs, group )
		end
	end

	if params.x1 then
		table.insert( methodArgs, params.x1 )
	end
	
	if params.y1 then
		table.insert( methodArgs, params.y1 )
	end

	if params.x2 then
		table.insert( methodArgs, params.x2 )
	end
	
	if params.y2 then
		table.insert( methodArgs, params.y2 )
	end
	
	local newLine = display.newLine( params.x1, params.y1, params.x2, params.y2 )

	if params.lineColor then
		newLine:setStrokeColor( unpack_color(params.lineColor) )
	end
	
	if params.lineWidth then
		newLine.strokeWidth = params.lineWidth
	end
	
	newLine.x = params.x
	newLine.y = params.y
	
	return newLine
	
end

-- create a text
local function _newText ( params )
	
	local methodArgs = {}
	
	if params.parentGroup then
		local group = newDisplay.getGroupByTag( display.getCurrentStage(), params.parentGroup )
		if group then
			table.insert ( methodArgs, group )
		end
	end

	if params.text then
		table.insert( methodArgs, params.text )
	end
	
	if params.x then
		table.insert( methodArgs, params.x )
	end
	
	if params.y then
		table.insert( methodArgs, params.y )
	end

	if params.font and params.font ~= "" then
		-- Note we have a string and we want the internal representation
		if params.font == "native.systemFont" then
			table.insert( methodArgs, native.systemFont )
		elseif params.font == "native.systemFontBold" then
			table.insert( methodArgs, native.systemFontBold )
		else
			table.insert( methodArgs, params.font )
		end
	else
		table.insert( methodArgs, native.systemFont )
	end

	if params.size then
		table.insert( methodArgs, params.size )
	end
	
	-- We could also just pass "params" to newText() (almost)
	local newText = display.newText( unpack ( methodArgs ) )
	
	if params.textColor then
		--[[
		local colorTable = {}
		for token in split( params.textColor, "," ) do
   			table.insert( colorTable, tonumber( token ) )
		end
		--]]
		-- there seems to be a disagreement about the limit
		newText:setFillColor( unpack_color(params.textColor) )
	end
	
	if params.physicsEnabled then
		if params.xScale then
			--newText.xScale = params.xScale
		end
		
		if params.yScale then
			--newText.yScale = params.yScale
		end
	end
	
	if params.width then
		newText.width = params.width
	end
	
	return newText
	
end

-- transition handling
function Scene:computeTransitions( object, transitionTable )
		
	local function createTransitionParams( object, objectModel )

		if not object.isVisible then
			return
		end
	
		if objectModel then
			local timeline = objectModel

			-- timeline contains the keyframes, that have:
			-- index = the object index, position = the keyframe position in the timeline, time = the effective time of the keyframe,
			-- params = all the tween params

			-- first, we need a sorting of the timeline table based on keyframe positions
			local tranTable = timeline
			local function compare( a, b )
				return a.position < b.position
			end

			table.sort(tranTable, compare)
			
			local copyTable = tranTable

			-- if we have at least a keyframe
			if #copyTable > 0 then

				local initialDelay = copyTable[ 1 ].time
				-- then we iterate the keyframes
				-- if only one keyframe, we just show the object at the params contained in the keyframe
				local transitionParams = copyTable[ 1 ].params
				transitionParams.time = initialDelay
				-- OBSOLETE: instead of transitioning here, we just place the object properties
				--transition.to( object, transitionParams )
				for k, v in pairs( transitionParams ) do
					object[ k ] = v
				end

				-- if more keyframes
				if #copyTable > 1 then
					local delayCount = initialDelay
					for i = 2, #timeline do
						-- setup the params
						local transitionParams = copyTable[ i ].params

						transitionParams.delay = delayCount
						transitionParams.time = copyTable[ i ].time - copyTable[ i - 1 ].time
						transition.to( object, transitionParams )
						delayCount = delayCount + transitionParams.time
					end
				end
			end
		end
	end
	
	createTransitionParams( object, transitionTable )
	
end

function Scene:newObject ( params )

	local factoryMethods = {
		image = _newImage,
		rect = _newRect,
		circle = _newCircle, 
		line = _newLine, 
		text = _newText,
		group = _newGroup
	}

	local returnedObject
	local objectType = params.type
	local factory = factoryMethods[ objectType ]

	if nil ~= factory then
		returnedObject = factory( params )
	end
	
	return returnedObject
	
end

local function dragBody ( event, params )
	local body = event.target
	local phase = event.phase
	local stage = display.getCurrentStage()

	if "began" == phase then
		stage:setFocus( body, event.id )
		body.isFocus = true

		-- Create a temporary touch joint and store it in the object for later reference
		if params and params.center then
			-- drag the body from its center point
			body.tempJoint = physics.newJoint( "touch", body, body.x, body.y )
		else
			-- drag the body from the point where it was touched
			body.tempJoint = physics.newJoint( "touch", body, event.x, event.y )
		end

		-- Apply optional joint parameters
		if params then
			local maxForce, frequency, dampingRatio

			if params.maxForce then
				-- Internal default is (1000 * mass), so set this fairly high if setting manually
				body.tempJoint.maxForce = params.maxForce
			end
			
			if params.frequency then
				-- This is the response speed of the elastic joint: higher numbers = less lag/bounce
				body.tempJoint.frequency = params.frequency
			end
			
			if params.dampingRatio then
				-- Possible values: 0 (no damping) to 1.0 (critical damping)
				body.tempJoint.dampingRatio = params.dampingRatio
			end
		end
	
	elseif body.isFocus then
		if "moved" == phase then
		
			-- Update the joint to track the touch
			body.tempJoint:setTarget( event.x, event.y )

		elseif "ended" == phase or "cancelled" == phase then
			stage:setFocus( body, nil )
			body.isFocus = false
			
			-- Remove the joint when the touch ends			
			body.tempJoint:removeSelf()
			
		end
	end

	-- Stop further propagation of touch event
	return true
end

-- scene rendering methods

function Scene:loadFile ( filename )
    -- set default base dir if none specified
    local base = system.ResourceDirectory
 
    -- create a file path for corona i/o
    local path = system.pathForFile( filename, base )
 
    -- will hold contents of file
    local contents
 
    -- io.open opens a file at path. returns nil if no file found
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        contents = file:read( "*a" )
        io.close( file )    -- close the file after using it
        --print(contents)
        --return decoded json string
        return json.decode( contents )
    else
        --or return nil if file didn't ex
        return nil
    end
end

function Scene:createObject( objData )

	local v = objData
	
	if not v.type then
		v.type = "image"
	end

	display.setDefault( "background", 1, 1, 1 )

	if v.children and v.sceneName then
		local background = display.newRect( self.view, display.contentWidth * 0.5, display.contentHeight * 0.5, display.contentWidth, display.contentHeight )
		if v.bgColor then
			background:setFillColor( unpack_color(v.bgColor) )
		end
		background:toBack()
	else

		local object = self:newObject( v )

		-- properties and positioning
		if object then

			-- position
			if not object.numChildren then
				object.x = v.x
				object.y = v.y
			end
	
			-- rotation
			if v.rotation then
				object.rotation = v.rotation
			end
	
			-- tint color
			if v.bgColor and v.type ~= "group" then
				object:setFillColor( unpack_color( v.bgColor ) )
			end
			
			-- tint color for image objects
			if v.fillColor and v.fillColor.r and v.fillColor.g and v.fillColor.b then
				object:setFillColor( v.fillColor.r, v.fillColor.g, v.fillColor.b )
			end
		
			if v.alpha then
				object.alpha = v.alpha
			end
			
			if v.fillEffect then
				object.fill.effect = v.fillEffect
			end
		
			-- mirrors code in CCSceneMethods.lua
			if v.physicsEnabled then
				
				-- if at least one object has physics enabled, we enable physics
				if not self._hasPhysics then
					self._hasPhysics = true
					physics.start()
				end
			
				local bodyShape, radius
				if v.radius and v.radius ~= 0 then
					radius = v.radius
				else
					if v.bodyShape then
						bodyShape = {}
						for i=1,#v.bodyShape do
							bodyShape[#bodyShape+1] = v.bodyShape[i].x * v.xScale
							bodyShape[#bodyShape+1] = v.bodyShape[i].y * v.yScale
						end
					end
				end
				physics.addBody( object, v.bodyType, { bounce=v.bounce, density=v.density, friction=v.friction, shape=bodyShape, radius=radius } )
				

				
				if v.hasJoint == true then
					object:addEventListener( "touch", dragBody )
				end
				
				--further physics properties
				if v.isSensor then
					object.isSensor = v.isSensor
				end
				
				if v.isBullet then
					object.isBullet = v.isBullet
				end

				if v.isFixedRotation then
					object.isFixedRotation = v.isFixedRotation
				end				

				if v.isBodyActive then
					object.isBodyActive = v.isBodyActive
				end	

				if v.isBodyActive then
					object.isBodyActive = v.isBodyActive
				end
				
				if v.linearDamping then
					object.linearDamping = v.linearDamping
				end	

				if v.angularDamping then
					object.angularDamping = v.angularDamping
				end	

				if v.isSleepingAllowed then
					object.isSleepingAllowed = v.isSleepingAllowed
				end					

				if v.isAwake then
					object.isAwake = v.isAwake
				end	
				
			end
		
			object.isVisible = v.isVisible
		
			object.tag = v.id

			table.insert( self._objects, object )
			return object
		end
	
	end
	
end

function Scene:load( fileName )
	self._objects = {}
	self._hasPhysics = false

	local objects = self:loadFile( fileName )
	local root = objects["objects"]

	-- create the bg
	local objData = root.id1
	self:createObject( objData )

	-- then all the objects
	local function showObjects( group, parentGroup )
		
		for i = 1, #group do
			local objData = root[ group[ i ] ]
			local obj = self:createObject( objData )
			parentGroup:insert( obj )
			if obj.numChildren then
				showObjects( objData.children, obj )
			end
			local tran = objData[ "timeline" ]
			if ( #tran > 0 ) then
				self:computeTransitions( obj, tran )
			end
		end

	end
	
	showObjects( root.id1.children, self.view )
end

function Scene:getObjectByTag( searchTag )
	for i = 1, #self._objects do
		local currentObject = self._objects[ i ]
		if currentObject.tag == searchTag then
			return currentObject
		end
	end
	return nil
end

return Scene
