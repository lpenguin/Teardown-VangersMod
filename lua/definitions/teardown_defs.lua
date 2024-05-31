---@alias Vec3 number[3]
---@alias Quat number[4]
---@alias Handle integer


---@class Transform
---@field pos Vec3
---@field rot Quat


---@meta
---@return Vec3
---@param x number
---@param y number
---@param z number
function Vec(x, y, z)
end

---@meta
---@param v1 Vec3
---@param v2 Vec3
---@return Vec3
function VecAdd(v1, v2) end

---@meta
---@param v Vec3
---@param scale number
---@return Vec3
function VecScale(v, scale) end


---@meta
---@param v Vec3
---@return Vec3
function VecNormalize(v) end

---@meta
---@param quat Quat
---@param v Vec3
---@return Vec3
function QuatRotateVec(quat, v) end

---@meta
---@param x number
---@param y number
---@param z number
---@return Quat
function QuatEuler(x, y, z) end



---@meta
---@param quat Quat
---@return number,number,number
function GetQuatEuler(quat) end

---@meta
---@param message string
function DebugPrint(message) end


---@meta 
---@param title string
---@param value any
function DebugWatch(title, value) end

---@meta
---@param v1 Vec3	
---@param v2 Vec3
---@param r number
---@param g number
---@param b number
---@param a number?
function DebugLine(v1, v2, r, g, b, a) end


---@meta
---@param position Vec3	
---@param r number
---@param g number
---@param b number
---@param a number?
function DebugCross(position, r, g, b, a) end

---@meta
---@param entity Handle
function Delete(entity) end

---@meta
---@param entity Handle
---@return string
function GetDescription(entity) end


---@meta
---@param entity Handle
---@param tag string
---@return boolean
function HasTag(entity, tag) end


---@meta
---@param entity Handle
---@param tag string
---@param value string?
function SetTag(entity, tag, value) end

---@meta
---@param entity Handle
---@param tag string
---@return string
function GetTagValue(entity, tag) end

---@meta
---@param entity Handle
---@param tag string
function RemoveTag(entity, tag) end


---@meta
---@param tag string
---@param global boolean?
---@return Handle
function FindBody(tag, global) end


---@meta
---@param tag string
---@param global boolean?
---@return Handle[]
function FindBodies(tag, global) end


---@meta
---@param tag string
---@param global boolean?
---@return Handle[]
function FindVehicles(tag, global) end


---@meta
---@param vehicle Handle
---@return Transform
function GetVehicleTransform(vehicle) end

---@meta
---@param vehicle Handle
---@return Handle
function GetVehicleBody(vehicle) end


---@meta
---@param pos Vec3
---@return Transform
function Transform(pos) end

---@meta
---@param xmlstr string
---@param transform Transform
---@param allowStatic? boolean
---@param jointExisting? boolean
---@return Handle[]
function Spawn(xmlstr, transform, allowStatic, jointExisting) end

---@meta
---@return Handle
function GetWorldBody() end

---@meta
---@param body Handle
---@return Transform
function GetBodyTransform(body) end

---@meta
---@param body Handle
---@param transform Transform
function SetBodyTransform(body, transform) end

---@meta
---@param body Handle
---@param dynamic boolean
function SetBodyDynamic(body, dynamic) end

---@meta
---@param body Handle
---@param active boolean
function SetBodyActive(body, active) end

---@meta
---@param body Handle
---@return Handle[]
function GetBodyShapes(body) end

---@meta
---@param tag string
---@param global boolean?
---@return Handle
function FindShape(tag, global) end


---@meta
---@param tag string
---@param global boolean?
---@return Handle[]
function FindShapes(tag, global) end


---@meta
---@param shape Handle
---@return Transform
function GetShapeLocalTransform(shape) end

---@meta
---@param shape Handle
---@param transform Transform
function SetShapeLocalTransform(shape, transform) end

---@meta
---@param handle Handle
---@param scale number
function SetShapeEmissiveScale(handle, scale) end

---@meta
---@param includePitch boolean?
---@return Transform
function GetPlayerTransform(includePitch) end

---@meta
---@param transform Transform
---@param includePitch boolean
function SetPlayerTransform(transform, includePitch) end

---@meta
---@return Handle
function GetPlayerVehicle(includePitch) end

---@meta
---@return Transform
function GetPlayerCameraTransform() end

---@meta
---@return Transform
function GetCameraTransform() end

---@meta
---@param transform Transform
---@param fov number?
function SetCameraTransform(transform, fov) end


---@meta
---@return Transform
function GetPlayerCameraTransform() end

---@meta
---@return Vec3
function GetPlayerVelocity() end

---@meta
---@param veclocity Vec3
function SetPlayerVelocity(veclocity) end


---@meta
---@return number
function GetTime() end

---@meta
---@param key string
---@return boolean
function InputPressed(key) end

---@meta
---@param key string
---@return boolean
function InputReleased(key) end

---@meta
---@param body Handle
---@param position Vec3
---@param direction Vec3
function ApplyBodyImpulse(body, position, direction) end