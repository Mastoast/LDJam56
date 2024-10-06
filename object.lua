objects = {}
types = {}
lookup = {}
function lookup.__index(self, i) return self.base[i] end

object = {}
object.speed_x = 0;
object.speed_y = 0;
object.remainder_x = 0;
object.remainder_y = 0;
object.hit_x = 0
object.hit_y = 0
object.hit_w = 8
object.hit_h = 8
object.spr_w = 8
object.spr_h = 8
object.facing = 1
object.solid = true
object.freeze = 0

function object.init(self) end
function object.update(self) end
function object.draw(self)
    spr(self.spr, self.x, self.y, 1, 1, self.flip_x, self.flip_y)
end

function object.move_x(self, x, on_collide)
    self.remainder_x += x
    local mx = flr(self.remainder_x + 0.5)
    self.remainder_x -= mx

    local total = mx
    local mxs = sgn(mx)
    while mx != 0
    do
        if self:check_solid(mxs, 0) then
            if on_collide then
                on_collide(self, total - mx, total)
            end
            return true
        else
            self.x += mxs
            mx -= mxs
        end
    end

    return false
end

function object.move_y(self, y, on_collide)
    self.remainder_y += y
    local my = flr(self.remainder_y + 0.5)
    self.remainder_y -= my

    local total = my
    local mys = sgn(my)
    while my != 0
    do
        if self:check_solid(0, mys) then
            if on_collide then
                on_collide(self, total - my, total)
            end
            return true
        else
            self.y += mys
            my -= mys
        end
    end
    
    return false
end

function object.overlaps(self, b, ox, oy)
    if self == b then return false end
    ox = ox or 0
    oy = oy or 0
    return
        ox + self.x + self.hit_x + self.hit_w > b.x + b.hit_x and
        oy + self.y + self.hit_y + self.hit_h > b.y + b.hit_y and
        ox + self.x + self.hit_x < b.x + b.hit_x + b.hit_w and
        oy + self.y + self.hit_y < b.y + b.hit_y + b.hit_h
end

function object.contains(self, px, py)
    return
        px >= self.x + self.hit_x and
        px < self.x + self.hit_x + self.hit_w and
        py >= self.y + self.hit_y and
        py < self.y + self.hit_y + self.hit_h
end

function object.check_solid(self, ox, oy)
    ox = ox or 0
    oy = oy or 0

    -- map collisions
    for i = flr((ox + self.x + self.hit_x) / 8),flr((ox + self.x + self.hit_x + self.hit_w - 1) / 8) do
        for j = flr((oy + self.y + self.hit_y)/8),flr((oy + self.y + self.hit_y + self.hit_h - 1)/8) do
            if (fget(mget(i, j), 0)) then
                return true
            end
		end
	end

    -- object collisions
    if not self.ghost then
        for o in all(objects) do
            if o != self and not o.destroyed and o.solid and self:overlaps(o, ox, oy) then
                if self.base == missile and (o.base == bat or o.base == target) then
                    o:dmg()
                end
                if self.base == bullet and (o.base == blob or o.base == target) then
                    o:dmg()
                end
                if (self.base == missile and o.base == blob) or (self.base == bullet and o.base == bat) then
                    goto exit_loop
                end
                return true
            end
            ::exit_loop::
        end
    end

    -- border collisions
    -- return
    --     self.x + ox < 0 or
    --     self.x + ox > 127 - self.hit_w or
    --     self.y + oy > 127 - self.hit_h or
    --     self.y + oy < 0

end

function create(type, x, y, hit_w, hit_h)
    local obj = {}
    obj.base = type
    obj.x = x
    obj.y = y
    obj.hit_w = hit_w or type.hit_w or 8
    obj.hit_h = hit_h or type.hit_h or 8
    setmetatable(obj, lookup)
    add(objects, obj)
    obj:init()
    return obj
end

function new_type(spr)
    local obj = {}
    obj.spr = spr
    obj.base = object
    setmetatable(obj, lookup)
    types[spr] = obj
    return obj
end
