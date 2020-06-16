Objective = {pos = vector3(0, 0, 0), name = ""}

-- use setmetatable for inheritance
function Objective:new  (o)
    o.parent =  self
    return o
end

-- function Point:move (p)
--     self.x = self.x + p.x
--     self.y = self.y + p.y
--   end

-- p1 = Point:create{x = 10, y = 20}
-- p2 = Point:create{x = 10}  -- y will be inherited until it is set

-- --
-- -- example of a method invocation
-- --
-- p1:move(p2)