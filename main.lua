function _init()
    gtime = 0
    ndeath = 0
    freeze_time = 0
    shake = 0
    cam = {x = 0, y = 0, mode = 1}
    printable = 0
    --
    init_level()
    -- diable btnp repeat
    poke(0X5F5C, 255)
end

function init_level()
    gtime = 0
    objects = {}
    particles = {}
    -- gen map
    for i=0, 127 do
        for y=0, 63 do
            if mget(i, y) == roof.spr then
                create(roof, i*8, y*8)
            end
        end
    end
    player = create(blob, 5.5* 8*16, 0*8*16)
    local target = create(target, 5.6* 8*16, 1*8*16 - 16)
    target.trg = function (self)
        -- create(blob, 5.5* 8*16, 0*8*16)
    end
    local blobg = {{25, 14, 3},{23, 14, 3}, {21, 14, 3},
    {35, 14, 3}, {38, 14, 3}, {39, 14, 3}, {41, 14, 3}, {43, 14, 3}}
    for all in all(blobg) do
        create(blob_green, all[1]*8, all[2]*8, all[3], all[3])
    end
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

    -- cam
    if cam.mode == 0 then
        local offset_x = player.state == 1 and player.facing * 12 or 0
        cam.x = lerp(cam.x, player.x + player.hit_w/2 - 64 + offset_x, 0.1)
    elseif cam.mode == 1 then
        local scene_x = flr((player.x + player.hit_w/2) / 128)
        cam.x = lerp(cam.x, scene_x * 128, 0.1)
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
    map(0, 0, 0, 0, 128, 16, 128)

    -- draw objects
    for o in all(objects) do
        o:draw()
    end

    -- draw particles
    for a in all(particles) do
        a:draw()
    end

    -- UI
    print(printable, cam.x + 80, cam.y + 8, 8)
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