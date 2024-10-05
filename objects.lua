rectangle = new_type(0)
rectangle.color = 7

function rectangle.draw(self)
    rectfill(self.x, self.y, self.x + self.hit_w - 1, self.y + self.hit_h - 1, self.color)
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