blob = new_type(1)
blob.jump_count = 0
blob.sprs = {1, 2, 1, 3}
blob.jump_spr = 4
blob.linked = {}

function blob.update(self)
    local on_ground = self:check_solid(0, 1)

    if btn(⬅️) then self.speed_x = -1
    elseif btn(➡️) then self.speed_x = 1
    else self.speed_x = 0 end
    if self.speed_x != 0 then self.facing = self.speed_x end
    self.flip_x = self.facing == -1

    --size
    if btnp(⬆️) then
        scale_up(self)
    end
    if btnp(⬇️) then
        scale_down(self)
    end


    -- gravity
    local max_spd = 3.3
    if not on_ground then
        if abs(self.speed_y) < 999 and btn(❎) then
            self.speed_y = min(self.speed_y + 0.2, max_spd)
        else
            self.speed_y = min(self.speed_y + 0.5, max_spd)
        end
    else
        self.speed_y = 0
    end
    
    -- hold jump
    if self.jump_count > 0 then
        if btn(❎) then
            self.jump_count -= 1
            self.speed_y = -1.0 * self.hit_h / 8
        else
            self.jump_count = 0
        end
    end
    printable = self.jump_count
    -- jump
    if on_ground and btnp(❎) then
        self.jump_count = 7
        self.speed_y = -2
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
        if o.base == blob_green and self:overlaps(o) and o.hit_w < self.hit_w then
            o.destroyed = true
            scale_up(self)
            scale_up(self)
        end
    end

end

function scale_up(self)
    if not self:check_solid(1, 0) then
        self.hit_w += 1
        self.hit_h += 1
        self.x += 1
        self.y -= 1
    elseif not self:check_solid(-1, 0) then
        self.hit_w += 1
        self.hit_h += 1
        self.x -= 1
        self.y -= 1
    end
end

function scale_down(self)
    if self.hit_w == 1 then return end
    self.hit_w -= 1
    self.hit_h -= 1
end

function blob.draw(self)
    local anim_speed = 16
    local current_spr = self.speed_y != 0 and self.jump_spr or self.sprs[flr(gtime / anim_speed) % #self.sprs + 1]
    sspr((current_spr % 16) * 8, flr(current_spr \ 16) * 8,
    self.spr_w, self.spr_h, self.x, self.y, self.hit_w, self.hit_h, self.flip_x, self.flip_y)
end


blob_green = new_type(1)
blob_green.sprs = {1, 2, 1, 3}
blob_green.solid = false

function blob_green.update(self)
    -- gravity
    local on_ground = self:check_solid(0, 1)
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
    local anim_speed = 16
    local current_spr = self.speed_y != 0 and self.jump_spr or self.sprs[flr(gtime / anim_speed) % #self.sprs + 1]
    sspr((current_spr % 16) * 8, flr(current_spr \ 16) * 8,
    self.spr_w, self.spr_h, self.x, self.y, self.hit_w, self.hit_h, self.flip_x, self.flip_y)
end