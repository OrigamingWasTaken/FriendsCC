---@meta

---DirectGPU peripheral for high-performance graphics.
---Peripheral type: "directgpu"
---@class DirectGPU
local DirectGPU = {}

-- region Display Management

---@return number displayId
function DirectGPU:autoDetectAndCreateDisplay() end

---@param resolutionMultiplier number
---@return number displayId
function DirectGPU:autoDetectAndCreateDisplayWithResolution(resolutionMultiplier) end

---@return string monitorName
---@nodiscard
function DirectGPU:autoDetectMonitor() end

function DirectGPU:clearAllDisplays() end

---@param x number
---@param y number
---@param z number
---@param facing string
---@param width number
---@param height number
---@return number displayId
function DirectGPU:createDisplay(x, y, z, facing, width, height) end

---@param x number
---@param y number
---@param z number
---@param facing string
---@param width number
---@param height number
---@return number displayId
function DirectGPU:createDisplayAt(x, y, z, facing, width, height) end

---@param x number
---@param y number
---@param z number
---@param facing string
---@param width number
---@param height number
---@param resolutionMultiplier number
---@return number displayId
function DirectGPU:createDisplayWithResolution(x, y, z, facing, width, height, resolutionMultiplier) end

---@param displayId number
---@return string info JSON
---@nodiscard
function DirectGPU:getDisplayInfo(displayId) end

---@return string stats JSON
---@nodiscard
function DirectGPU:getResourceStats() end

---@return table displays
---@nodiscard
function DirectGPU:listDisplays() end

---@param displayId number
---@return boolean
function DirectGPU:removeDisplay(displayId) end

---@param displayId number
---@param persistent boolean
function DirectGPU:setDisplayPersistent(displayId, persistent) end

---@param displayId number
function DirectGPU:updateDisplay(displayId) end

-- endregion

-- region 2D Drawing

---@param displayId number
---@param r number 0-255
---@param g number 0-255
---@param b number 0-255
function DirectGPU:clear(displayId, r, g, b) end

---@param displayId number
---@param cx number
---@param cy number
---@param radius number
---@param r number
---@param g number
---@param b number
---@param filled boolean
function DirectGPU:drawCircle(displayId, cx, cy, radius, r, g, b, filled) end

---@param displayId number
---@param cx number
---@param cy number
---@param rx number
---@param ry number
---@param r number
---@param g number
---@param b number
---@param filled boolean
function DirectGPU:drawEllipse(displayId, cx, cy, rx, ry, r, g, b, filled) end

---@param displayId number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param r number
---@param g number
---@param b number
function DirectGPU:drawLine(displayId, x1, y1, x2, y2, r, g, b) end

---@param displayId number
---@param pointsObj table
---@param r number
---@param g number
---@param b number
function DirectGPU:drawPolygon(displayId, pointsObj, r, g, b) end

---@param displayId number
---@param pointsObj table
---@param r number
---@param g number
---@param b number
function DirectGPU:drawPolylines(displayId, pointsObj, r, g, b) end

---@param displayId number
---@param cx number
---@param cy number
---@param rx number
---@param ry number
---@param r number
---@param g number
---@param b number
function DirectGPU:fillEllipse(displayId, cx, cy, rx, ry, r, g, b) end

---@param displayId number
---@param x number
---@param y number
---@param w number
---@param h number
---@param r number
---@param g number
---@param b number
function DirectGPU:fillRect(displayId, x, y, w, h, r, g, b) end

---@param displayId number
---@param x number
---@param y number
---@return table pixel
---@nodiscard
function DirectGPU:getPixel(displayId, x, y) end

---@param displayId number
---@param x number
---@param y number
---@param r number
---@param g number
---@param b number
function DirectGPU:setPixel(displayId, x, y, r, g, b) end

-- endregion

-- region Text Rendering

function DirectGPU:clearFontCache() end

---@param displayId number
---@param text string
---@param x number
---@param y number
---@param r number
---@param g number
---@param b number
---@param fontName string
---@param fontSize number
---@param style string
---@return string info
function DirectGPU:drawText(displayId, text, x, y, r, g, b, fontName, fontSize, style) end

---@param displayId number
---@param text string
---@param x number
---@param y number
---@param fgR number
---@param fgG number
---@param fgB number
---@param bgR number
---@param bgG number
---@param bgB number
---@param padding number
---@param fontName string
---@param fontSize number
---@param style string
---@return string info
function DirectGPU:drawTextWithBg(displayId, text, x, y, fgR, fgG, fgB, bgR, bgG, bgB, padding, fontName, fontSize, style) end

---@param displayId number
---@param text string
---@param x number
---@param y number
---@param maxWidth number
---@param r number
---@param g number
---@param b number
---@param lineSpacing number
---@param fontName string
---@param fontSize number
---@param style string
---@return string info
function DirectGPU:drawTextWrapped(displayId, text, x, y, maxWidth, r, g, b, lineSpacing, fontName, fontSize, style) end

---@param text string
---@param fontName string
---@param fontSize number
---@param style string
---@return string info JSON
---@nodiscard
function DirectGPU:measureText(text, fontName, fontSize, style) end

-- endregion

-- region Image & JPEG

function DirectGPU:clearJPEGCache() end

---@param base64JpegData string
---@param targetWidth number
---@param targetHeight number
---@return string result
function DirectGPU:decodeAndScaleJPEG(base64JpegData, targetWidth, targetHeight) end

---@param base64JpegData string
---@return string result
function DirectGPU:decodeJPEG(base64JpegData) end

---@param base64JpegData string
---@return string dimensions JSON
---@nodiscard
function DirectGPU:getJPEGDimensions(base64JpegData) end

---@return string stats JSON
---@nodiscard
function DirectGPU:getJPEGNetworkStats() end

---@param targetWidth number
---@param targetHeight number
---@return string settings JSON
---@nodiscard
function DirectGPU:getRecommendedJPEGSettings(targetWidth, targetHeight) end

---@param displayId number
---@param base64JpegData string
function DirectGPU:loadJPEGFullscreen(displayId, base64JpegData) end

---@param displayId number
---@param jpegBinaryData string
---@param x number
---@param y number
---@param w number
---@param h number
function DirectGPU:loadJPEGRegion(displayId, jpegBinaryData, x, y, w, h) end

---@param displayId number
---@param base64JpegData string
---@param x number
---@param y number
---@param w number
---@param h number
function DirectGPU:loadJPEGRegionBytes(displayId, base64JpegData, x, y, w, h) end

---@param displayId number
---@param jpegSequence table
function DirectGPU:preloadJPEGSequence(displayId, jpegSequence) end

-- endregion

-- region Dictionary Compression

function DirectGPU:clearDictionary() end

---@param base64Data string
---@return string compressed
function DirectGPU:compressWithDict(base64Data) end

---@param hashMap table
---@return string decompressed
function DirectGPU:decompressFromDict(hashMap) end

---@param hash number
---@return string chunk
---@nodiscard
function DirectGPU:getChunk(hash) end

---@return string stats JSON
---@nodiscard
function DirectGPU:getDictionaryStats() end

---@param hash number
---@return boolean
---@nodiscard
function DirectGPU:hasChunk(hash) end

-- endregion

-- region 3D Camera

---@param displayId number
function DirectGPU:clearZBuffer(displayId) end

---@param displayId number
---@return string info JSON
---@nodiscard
function DirectGPU:getCameraInfo(displayId) end

---@param displayId number
---@param targetX number
---@param targetY number
---@param targetZ number
function DirectGPU:lookAt(displayId, targetX, targetY, targetZ) end

---@param displayId number
---@param x number
---@param y number
---@param z number
function DirectGPU:setCameraPosition(displayId, x, y, z) end

---@param displayId number
---@param pitch number
---@param yaw number
---@param roll number
function DirectGPU:setCameraRotation(displayId, pitch, yaw, roll) end

---@param displayId number
---@param x number
---@param y number
---@param z number
function DirectGPU:setCameraTarget(displayId, x, y, z) end

---@param displayId number
---@param fov number
---@param near number
---@param far number
---@return string info
function DirectGPU:setupCamera(displayId, fov, near, far) end

-- endregion

-- region 3D Primitives

---@param displayId number
function DirectGPU:clear3D(displayId) end

---@param displayId number
---@param x number
---@param y number
---@param z number
---@param size number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param r number
---@param g number
---@param b number
function DirectGPU:drawCube(displayId, x, y, z, size, rotX, rotY, rotZ, r, g, b) end

---@param displayId number
---@param x number
---@param y number
---@param z number
---@param size number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param r number
---@param g number
---@param b number
function DirectGPU:drawPyramid(displayId, x, y, z, size, rotX, rotY, rotZ, r, g, b) end

---@param displayId number
---@param x number
---@param y number
---@param z number
---@param radius number
---@param segments number
---@param r number
---@param g number
---@param b number
---@param textureNameObj? any
function DirectGPU:drawSphere(displayId, x, y, z, radius, segments, r, g, b, textureNameObj) end

-- endregion

-- region 3D Models

function DirectGPU:clearAll3DModels() end

---@param displayId number
---@param modelId number
---@param x number
---@param y number
---@param z number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param scale number
---@param r number
---@param g number
---@param b number
function DirectGPU:draw3DModel(displayId, modelId, x, y, z, rotX, rotY, rotZ, scale, r, g, b) end

---@param displayId number
---@param modelId number
---@param x number
---@param y number
---@param z number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param scale number
---@param textureId number
function DirectGPU:draw3DModelTextured(displayId, modelId, x, y, z, rotX, rotY, rotZ, scale, textureId) end

---@param modelId number
---@return string info JSON
---@nodiscard
function DirectGPU:get3DModelInfo(modelId) end

---@param objData string OBJ format
---@return number modelId
function DirectGPU:load3DModel(objData) end

---@param base64ObjData string
---@return number modelId
function DirectGPU:load3DModelFromBytes(base64ObjData) end

---@param modelId number
---@return boolean
function DirectGPU:unload3DModel(modelId) end

-- endregion

-- region 3D Lighting

---@param displayId number
---@param r number
---@param g number
---@param b number
---@param intensity number
function DirectGPU:addAmbientLight(displayId, r, g, b, intensity) end

---@param displayId number
---@param dirX number
---@param dirY number
---@param dirZ number
---@param r number
---@param g number
---@param b number
---@param intensity number
function DirectGPU:addDirectionalLight(displayId, dirX, dirY, dirZ, r, g, b, intensity) end

---@param displayId number
function DirectGPU:clearLights(displayId) end

---@param displayId number
---@param enabled boolean
function DirectGPU:setBackfaceCulling(displayId, enabled) end

---@param displayId number
---@param enabled boolean
function DirectGPU:setPhongShading(displayId, enabled) end

-- endregion

-- region Textures

---@param textureId number
---@return string info JSON
---@nodiscard
function DirectGPU:getTextureInfo(textureId) end

---@param width number
---@param height number
---@param base64PixelData string
---@return number textureId
function DirectGPU:loadTexture(width, height, base64PixelData) end

---@param imageData any
---@return number textureId
function DirectGPU:loadTextureFromImage(imageData) end

---@param textureId number
---@return boolean
function DirectGPU:unloadTexture(textureId) end

-- endregion

-- region Input Events

---@param displayId number
function DirectGPU:clearEvents(displayId) end

---@param displayId number
---@return boolean
---@nodiscard
function DirectGPU:hasEvents(displayId) end

---@param displayId number
---@return string event JSON
function DirectGPU:pollEvent(displayId) end

-- endregion

-- region World Data

---@param x number
---@param y number
---@param z number
---@return string biome
---@nodiscard
function DirectGPU:getBiomeAt(x, y, z) end

---@return string dimension
---@nodiscard
function DirectGPU:getDimension() end

---@return string moonInfo JSON
---@nodiscard
function DirectGPU:getMoonInfo() end

---@return string timeInfo JSON
---@nodiscard
function DirectGPU:getTimeInfo() end

---@return string weather JSON
---@nodiscard
function DirectGPU:getWeather() end

---@return string worldInfo JSON
---@nodiscard
function DirectGPU:getWorldInfo() end

-- endregion

-- region Controller Input

---@param controllerId number
function DirectGPU:clearControllerEvents(controllerId) end

---@param controllerId number
---@return table axes
---@nodiscard
function DirectGPU:getAxes(controllerId) end

---@param controllerId number
---@param axisIndex number
---@return number value
---@nodiscard
function DirectGPU:getAxis(controllerId, axisIndex) end

---@param controllerId number
---@param buttonIndex number
---@return boolean pressed
---@nodiscard
function DirectGPU:getButton(controllerId, buttonIndex) end

---@param controllerId number
---@return table buttons
---@nodiscard
function DirectGPU:getButtons(controllerId) end

---@return number count
---@nodiscard
function DirectGPU:getControllerCount() end

---@return number deadzone
---@nodiscard
function DirectGPU:getControllerDeadzone() end

---@param controllerId number
---@return string info JSON
---@nodiscard
function DirectGPU:getControllerInfo(controllerId) end

---@param controllerId number
---@return boolean
---@nodiscard
function DirectGPU:hasControllerEvents(controllerId) end

---@param controllerId number
---@return string event JSON
function DirectGPU:pollControllerEvent(controllerId) end

function DirectGPU:scanForControllers() end

---@param deadzone number
function DirectGPU:setControllerDeadzone(deadzone) end

---@param controllerId number
function DirectGPU:updateControllerState(controllerId) end

-- endregion

-- region Controller Mapping

---@param controllerId number
---@return string state JSON
---@nodiscard
function DirectGPU:exportRawControllerState(controllerId) end

---@param controllerId number
---@return string mapping JSON
---@nodiscard
function DirectGPU:getControllerMapping(controllerId) end

---@param controllerId number
---@param axisName string
---@return number value
---@nodiscard
function DirectGPU:getMappedAxis(controllerId, axisName) end

---@param controllerId number
---@param buttonName string
---@return boolean pressed
---@nodiscard
function DirectGPU:getMappedButton(controllerId, buttonName) end

---@param controllerId number
function DirectGPU:resetControllerMapping(controllerId) end

function DirectGPU:saveControllerMappings() end

---@param controllerId number
---@param axisName string
---@param rawAxis number
---@param inverted boolean
function DirectGPU:setAxisMapping(controllerId, axisName, rawAxis, inverted) end

---@param controllerId number
---@param buttonName string
---@param rawButton number
function DirectGPU:setButtonMapping(controllerId, buttonName, rawButton) end

-- endregion

-- region Controller Profiles

---@param controllerId number
---@return string axisNames JSON
---@nodiscard
function DirectGPU:getControllerAxisNames(controllerId) end

---@param controllerId number
---@return string buttonNames JSON
---@nodiscard
function DirectGPU:getControllerButtonNames(controllerId) end

---@param controllerId number
---@return table inputs
---@nodiscard
function DirectGPU:getControllerInputs(controllerId) end

---@param controllerId number
---@return string profile JSON
---@nodiscard
function DirectGPU:getControllerProfile(controllerId) end

---@param controllerId number
---@return string controllerType
---@nodiscard
function DirectGPU:getControllerType(controllerId) end

---@param controllerId number
---@param threshold number
---@return string activeAxes JSON
---@nodiscard
function DirectGPU:getNamedAxesActive(controllerId, threshold) end

---@param controllerId number
---@param axisName string
---@return number value
---@nodiscard
function DirectGPU:getNamedAxis(controllerId, axisName) end

---@param controllerId number
---@param buttonName string
---@return boolean pressed
---@nodiscard
function DirectGPU:getNamedButton(controllerId, buttonName) end

---@param controllerId number
---@return string pressedButtons JSON
---@nodiscard
function DirectGPU:getNamedButtonsPressed(controllerId) end

---@param controllerId number
---@param inputName string
---@return boolean
---@nodiscard
function DirectGPU:hasInput(controllerId, inputName) end

---@param controllerId number
function DirectGPU:refreshControllerProfile(controllerId) end

-- endregion

-- region Server-Side Controllers

---@return string uuid
---@nodiscard
function DirectGPU:getPlayerUUID() end

---@param playerUUID string
---@param localControllerId number
---@return table axes
---@nodiscard
function DirectGPU:getServerControllerAxes(playerUUID, localControllerId) end

---@param playerUUID string
---@param controllerId number
---@param axisIndex number
---@return number value
---@nodiscard
function DirectGPU:getServerControllerAxis(playerUUID, controllerId, axisIndex) end

---@param playerUUID string
---@param controllerId number
---@param buttonIndex number
---@return boolean pressed
---@nodiscard
function DirectGPU:getServerControllerButton(playerUUID, controllerId, buttonIndex) end

---@param playerUUID string
---@param localControllerId number
---@return table buttons
---@nodiscard
function DirectGPU:getServerControllerButtons(playerUUID, localControllerId) end

---@param playerUUID string
---@return number count
---@nodiscard
function DirectGPU:getServerControllerCount(playerUUID) end

---@param playerUUID string
---@param localControllerId number
---@return string info JSON
---@nodiscard
function DirectGPU:getServerControllerInfo(playerUUID, localControllerId) end

---@param playerUUID string
---@param controllerId number
---@return string state JSON
---@nodiscard
function DirectGPU:getServerControllerState(playerUUID, controllerId) end

---@param playerUUID string
---@param localControllerId number
---@return boolean
---@nodiscard
function DirectGPU:hasServerController(playerUUID, localControllerId) end

-- endregion

-- region Vector Graphics

---@param displayId number
---@param pointsObj table
---@param r number
---@param g number
---@param b number
---@param segmentsObj? any
function DirectGPU:drawBezierCurve(displayId, pointsObj, r, g, b, segmentsObj) end

---@param displayId number
---@param x number
---@param y number
---@param w number
---@param h number
---@param radius number
---@param r number
---@param g number
---@param b number
---@param filled boolean
function DirectGPU:drawRoundedRect(displayId, x, y, w, h, radius, r, g, b, filled) end

---@param displayId number
---@param pathData string SVG path data
---@param x number
---@param y number
---@param scale number
---@param r number
---@param g number
---@param b number
function DirectGPU:drawSVGPath(displayId, pathData, x, y, scale, r, g, b) end

---@param displayId number
---@param cx number
---@param cy number
---@param points number
---@param outerRadius number
---@param innerRadius number
---@param r number
---@param g number
---@param b number
---@param filled boolean
function DirectGPU:drawStar(displayId, cx, cy, points, outerRadius, innerRadius, r, g, b, filled) end

-- endregion

-- region Metaballs

---@param systemId number
---@param x number
---@param y number
---@param radius number
---@param strength number
---@return number ballId
function DirectGPU:addMetaball(systemId, x, y, radius, strength) end

---@param systemId number
function DirectGPU:clearMetaballs(systemId) end

---@param displayId number
---@return number systemId
function DirectGPU:createMetaballSystem(displayId) end

---@param systemId number
---@return number count
---@nodiscard
function DirectGPU:getMetaballCount(systemId) end

---@param systemId number
---@param ballId number
---@return string info JSON
---@nodiscard
function DirectGPU:getMetaballInfo(systemId, ballId) end

---@param systemId number
function DirectGPU:removeMetaballSystem(systemId) end

---@param systemId number
---@param threshold number
---@param renderMode number
function DirectGPU:renderMetaballs(systemId, threshold, renderMode) end

---@param systemId number
---@param ballId number
---@param r number
---@param g number
---@param b number
function DirectGPU:setMetaballColor(systemId, ballId, r, g, b) end

---@param systemId number
---@param enabled boolean
---@param gravity number
---@param drag number
function DirectGPU:setMetaballPhysics(systemId, enabled, gravity, drag) end

---@param systemId number
---@param ballId number
---@param vx number
---@param vy number
function DirectGPU:setMetaballVelocity(systemId, ballId, vx, vy) end

---@param systemId number
---@param deltaTime number
function DirectGPU:updateMetaballs(systemId, deltaTime) end

-- endregion

-- region Calibration

---@return string values JSON
---@nodiscard
function DirectGPU:getCalibrationValues() end

---@param enabled boolean
---@param divisor number
---@param subtract number
function DirectGPU:setCalibrationMode(enabled, divisor, subtract) end

-- endregion
