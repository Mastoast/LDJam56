blob = new_type(1)
blob.jump_count = 0
blob.sprs = {1, 2, 1, 3}
blob.jump_spr = 4
blob.linked = {}
blob.acc = 0.4
blob.friction = 0.8
blob.nbscale = 1

function blob.update(self)
    local on_ground = self:check_solid(0, 1)

    local c_acc = self.acc * self.hit_w / 8 * 0.6
    if btn(⬅️) then self.speed_x -= c_acc; self.facing = -1
    elseif btn(➡️) then self.speed_x += c_acc; self.facing = 1
    end
    self.flip_x = self.facing == -1

    -- friction
    self.speed_x *= self.friction

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

    -- jump
    if on_ground and btnp(❎) then
        self.jump_count = 7
        self.speed_y = -2
    end

    -- interactions
    for o in all(objects) do
        if o.base == blob_green and self:overlaps(o) and o.hit_w < self.hit_w then
            o.destroyed = true
            spawn_particles(self.hit_w, 2, o.x, o.y, 3)
            scale_up(self)
        end
    end

    -- shoot missile
    if btnp(🅾️) and self.hit_w > 2 then
        local m = create(missile, self.x + self.hit_w/2, self.y)
        m.hit_h = self.hit_h - 2*self.nbscale
        m.hit_w = self.hit_w - 2*self.nbscale
        m.speed_x = (self.facing * 1.5 + self.speed_x) * self.hit_w / 8
        m.speed_y = (not btn(⬆️) and -0.5 or -1.5) * self.hit_h / 8
        if btn(⬆️) and abs(self.speed_x) < 0.2 then m.speed_y, m.speed_x = -2.5, 0 end
        scale_down(self)
    end

    -- move
    self:move_x(self.speed_x, function(self, ox, nx)
        self.speed_x = 0
    end)

    self:move_y(self.speed_y, function(self, oy, ny)
        self.speed_y = 0
    end)
end

function blob.dmg(self)
    self.speed_x = self.facing * -4.2
    self.speed_y = -4
    spawn_particles(8, 2, self.x + self.hit_w / 2, self.y + self.hit_h / 2, 8)
    local m = create(missile, self.x + self.hit_w/2, self.y)
    m.hit_h = self.hit_h - 2*self.nbscale
    m.hit_w = self.hit_w - 2*self.nbscale
    m.speed_x = (-self.facing * 2.5) * self.hit_w / 8
    m.speed_y = -2.0 * self.hit_h / 8
    scale_down(self)
    shake = 10
end

function scale_up(self)
    if not self:check_solid(self.facing * self.nbscale, 0) then
        self.hit_w += self.nbscale
        self.hit_h += self.nbscale
        self.x -= self.facing * self.nbscale
        self.y -= self.nbscale
    elseif not self:check_solid(-self.facing * self.nbscale, 0) then
        self.hit_w += self.nbscale
        self.hit_h += self.nbscale
        self.y -= self.nbscale
    end
end

function scale_down(self)
    if self.hit_w <= self.nbscale then return end
    self.hit_w -= self.nbscale
    self.hit_h -= self.nbscale
end

function blob.draw(self)
    local anim_speed = 16
    local current_spr = self.speed_y != 0 and self.jump_spr
    or self.sprs[flr(gtime / anim_speed) % #self.sprs + 1]
    sspr((current_spr % 16) * 8, flr(current_spr \ 16) * 8,
    self.spr_w, self.spr_h, self.x, self.y, self.hit_w, self.hit_h, self.flip_x, self.flip_y)
end


blob_green = new_type(1)
blob_green.sprs = {17, 18}
blob_green.solid = false

function blob_green.update(self)
    -- gravity
    local on_ground = self:check_solid(0, 1)
    if not on_ground then
        self.speed_y = min(self.speed_y + 0.5, 4.4)
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
    local anim_speed = 32
    local current_spr = self.speed_y != 0 and self.jump_spr
    or self.sprs[flr(gtime / anim_speed) % #self.sprs + 1]
    sspr((current_spr % 16) * 8, flr(current_spr \ 16) * 8,
    self.spr_w, self.spr_h, self.x, self.y, self.hit_w, self.hit_h, self.flip_x, self.flip_y)
end