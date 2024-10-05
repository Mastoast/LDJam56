blob = new_type(1)
blob.sprs = {1, 2, 1, 3}
blob.linked = {}

function blob.update(self)
    local on_ground = self:check_solid(0, 1)

    if btn(⬅️) then self.speed_x = -1
    elseif btn(➡️) then self.speed_x = 1
    else self.speed_x = 0 end
    if self.speed_x != 0 then self.facing = self.speed_x end
    self.flip_x = self.facing == -1

    -- gravity
    if not on_ground then
        self.speed_y = min(self.speed_y + 0.8, 4.4)
    else
        self.speed_y = 0
    end

    -- move
    self:move_x(self.speed_x, function(self, ox, nx)
        self.speed_x = 0
    end)

    self:move_y(self.speed_y, function(self, oy, ny)
        self.speed_y = 0
    end)

    -- interactions
    for o in all(objects) do
        if o.base == blob_green and self:overlaps(o, 1) and btnp(❎) then
            o.is_linked = not o.is_linked
        end
    end

end

function blob.draw(self)
    -- 
    local anim_speed = 16
    spr(self.sprs[flr(gtime / anim_speed) % #self.sprs + 1], self.x, self.y, 1, 1, self.flip_x, self.flip_y)
end


blob_green = new_type(1)
blob_green.sprs = {1, 2, 1, 3}
blob_green.is_linked = false

function blob_green.update(self)
    local on_ground = self:check_solid(0, 1)

    if self.is_linked then
        if btn(⬅️) then self.speed_x = -1
        elseif btn(➡️) then self.speed_x = 1
        else self.speed_x = 0 end
    end
    if self.speed_x != 0 then self.facing = self.speed_x end
    self.flip_x = self.facing == -1

    -- gravity
    if not on_ground then
        self.speed_y = min(self.speed_y + 0.8, 4.4)
    else
        self.speed_y = 0
    end

    -- move
    self:move_x(self.speed_x, function(self, ox, nx)
        self.speed_x = 0
    end)

    self:move_y(self.speed_y, function(self, oy, ny)
        self.speed_y = 0
    end)
end

function blob_green.draw(self)
    -- 
    local anim_speed = 16
    spr(self.sprs[flr(gtime / anim_speed) % #self.sprs + 1], self.x, self.y, 1, 1, self.flip_x, self.flip_y)
end