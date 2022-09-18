---@meta 
---@param x number
---@param y number
function UiTranslate(x, y) end


---@meta 
---@param scale number
function UiScale(scale) end

---@meta 
---@param angle number
function UiRotate(angle) end


---@meta 
---@return number
function UiWidth() end

---@meta 
---@return number
function UiHeight() end

---@meta 
--- The alignment determines how content is aligned with respect to the cursor.
---   left: Horizontally align to the left
---   right: Horizontally align to the right
---   center: Horizontally align to the center
---   top: Vertically align to the top
---   bottom: Veritcally align to the bottom
---   middle: Vertically align to the middle
---@param aligh_str string
function UiAlign(aligh_str) end

---@meta 
--- Draw image at cursor position. 
--- If x0, y0, x1, y1 is provided a cropped version will be drawn in that coordinate range. 
---@param path string Path to image (PNG or JPG format)
---@param x0 number? Lower x coordinate (default is 0)
---@param y0 number? Lower y coordinate (default is 0)
---@param x1 number? Upper x coordinate (default is image width)
---@param y1 number? Upper y coordinate (default is image height)
---@return number, number w Width and height of drawn image
function UiImage(path, x0, y0, x1, y1) end


---@meta 
--- Push state onto stack. This is used in combination with UiPop to remember a state and restore to that state later. 
function UiPush() end

---@meta 
--[[Pop state from stack and make it the current one. 
    This is used in combination with UiPush to remember a previous state and go back to it later. ]]
function UiPop() end