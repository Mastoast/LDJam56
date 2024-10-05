rectangle = new_type(0)
rectangle.color = 7

function rectangle.draw(self)
    rectfill(self.x, self.y, self.x + self.hit_w - 1, self.y + self.hit_h - 1, self.color)
end

missile = new_type(5)
missile.color = 8
missile.acc = 0.1
missile.friction = 0.97
missile.sprs = {5, 6, 7}

function missile.update(self)

    self:move_x(self.speed_x, function(self, ox, nx)
        self:dmg()
    end)

    self:move_y(self.speed_y, function(self, oy, ny)
        self:dmg()
    end)

    if abs(self.speed_x) < 0.05 and abs(self.speed_y) < 0.05 then
        self.speed_x = 0
        self.speed_y = 0
    end

    self.speed_x *= self.friction
    self.speed_y += 0.05
end

function missile.dmg(self)
    self.destroyed = true
    spawn_particles(10, 2, self.x, self.y, 3)
    local next = create(blob_green, self.x, self.y)
    next.hit_h = self.hit_h
    next.hit_w = self.hit_w
end

function missile.draw(self)
    self.flip_x = self.speed_x < 0
    self.flip_y = self.speed_y > 0
    -- choose sprite based on speed
    local thsp = 1.8
    local current_spr = abs(self.speed_x) > thsp * abs(self.speed_y) and self.sprs[3]
    or abs(self.speed_y) > thsp * abs(self.speed_x) and self.sprs[1]
    or self.sprs[2]
    sspr((current_spr % 16) * 8, flr(current_spr \ 16) * 8,
    self.spr_w, self.spr_h, self.x, self.y, self.hit_w, self.hit_h, self.flip_x, self.flip_y)
end

bat = new_type(10)
bat.sprs = {10, 12}
bat.hit_w = 16
bat.spr_w = 16

function bat.update(self)

    -- fly pattern
    self.speed_x = 1.5 * cos(gtime / 60)
    self.speed_y = 0.5 * sin(gtime / 180)

    self:move_x(self.speed_x, function(self, ox, nx)
        self.speed_x = 0
    end)

    self:move_y(self.speed_y, function(self, oy, ny)
        self.speed_y = 0
    end)
end

function bat.dmg(self)
    self.destroyed = true
    spawn_particles(10, 2, self.x, self.y, 5)
end

function bat.draw(self)
    local anim_speed = 16
    local current_spr = self.sprs[flr(gtime / anim_speed) % #self.sprs + 1]
    sspr((current_spr % 16) * 8, flr(current_spr \ 16) * 8,
    self.spr_w, self.spr_h, self.x, self.y, self.hit_w, self.hit_h, self.flip_x, self.flip_y)
end

-- PARTICLES
particles = {}

-- number
-- size
-- x / y
-- color
function spawn_particles(nb,s,x,y,c)
    for i=1,flr(nb) do
        add(particles, make_particle(s,x,y,c))
    end
end

function make_particle(s,x,y,c)
    local p={
        s=s or 1,
        c=c or 7,
        x=x,y=y,k=k,
        t=0, t_max=16+flr(rnd(4)),
        dx=rnd(2)-1,dy=-rnd(3),
        ddy=0.05,
        update=update_particle,
        draw=draw_particle
    }
    return p
end

function draw_particle(a)
    circfill(a.x,a.y,a.s,a.c)
end

function update_particle(a)
    if a.s>=1 and a.t%4==0 then a.s-=1 end
    if a.t%2==0 then
        a.dy+=a.ddy
        a.x+=a.dx
        a.y+=a.dy
    end
    a.t+=1
    if (a.t==a.t_max) del(particles, a)
end