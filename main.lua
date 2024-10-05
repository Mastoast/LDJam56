function _init()
    gtime = 0
    ndeath = 0
    freeze_time = 0
    shake = 0
    cam = {x = 0, y = 0}
    printable = 0
    --
    init_level()
    -- diable btn repeat
    poke(0x5f5d, 25)
end

function init_level()
    gtime = 0
    objects = {}
    particles = {}
    -- gen checkpoints
    -- for i=0, 127 do
    --     for y=0, 63 do
    --         if mget(i, y) == 4 then
    --             create(rectangle, i*8 + 4, y*8 + 4)
    --         end
    --     end
    -- end
    create(blob, 8, 0)
    local test = create(blob_green, 32, 0)
    test.hit_h = 2
    test.hit_w = 2
    local test = create(blob_green, 40, 0)
    test.hit_h = 4
    test.hit_w = 4
    local test = create(blob_green, 50, 0)
    test.hit_h = 6
    test.hit_w = 6
    local test = create(blob_green, 60, 0)
    test.hit_h = 8
    test.hit_w = 8
end

function _update60()
    -- timers
    gtime += 1

    update_level()
end

function update_level()
    -- freeze
    if freeze_time > 0 then
        freeze_time -= 1
        return
    end

    -- screenshake
    shake = max(shake - 1)

    for o in all(objects) do
        if o.freeze > 0 then
            o.freeze -= 1
        else
            o:update()
        end

        if o.base != player and o.destroyed then
            del(objects, o)
        end
    end

    for a in all(particles) do
        a:update()
    end
end

function _draw()
    cls(0)
    
    -- camera
    if shake > 0 then
        camera(cam.x - 2 + rnd(5), cam.y - 2 + rnd(5))
    else
        camera(cam.x, cam.y)
    end

    -- draw map
    map(0, 0, 0, 0, 16, 16)

    -- draw objects
    for o in all(objects) do
        o:draw()
    end

    -- draw particles
    for a in all(particles) do
        a:draw()
    end

    -- UI
    
    print(printable, cam.x + 80, cam.y + 8, 4)
end

-- UTILS
-- linear interpolation
function lerp(start,finish,t)
    return mid(start,start*(1-t)+finish*t,finish)
end

-- print at center
function print_centered(str, offset_x, y, col)
    print(str, cam.x + 64 - (#str * 2) + offset_x, y, col)
end

-- random range
function rrnd(min, max)
    return flr(min + rnd(max - min))
end

-- find index for element in table
function find_item_table_index(item, table)
    for k, v in pairs(table) do
        if v == item then return k end
    end
    return 0
end