local pd <const> = playdate
local gfx <const> = playdate.graphics

local AUTOTILE_MAP = {
    [1]=1, [2]=13, [3]=2, [4]=14,
    [5]=5, [6]=9, [7]=6, [8]=10,
    [9]=4, [10]=16, [11]=2, [12]=15,
    [13]=8, [14]=12, [15]=7, [16]=11
}

Autotile = {}
class("Autotile").extends(gfx.sprite)

Autotile.STATE = {EMPTY=0, SOLID=1}

function Autotile.getIndex(x, y, width)
    -- Get position for a coordinate
    return math.floor(width * (y - 1) + x)
end

function Autotile.createData(width, height, value, callback)
    -- Create an empty matrix with default value
    local tiles = {}
    for x = 1, width do
        for y = 1, height do
            tiles[Autotile.getIndex(x, y, width)] = value
            if callback ~= nil then
                callback(x, y)
            end
        end
    end

    return tiles
end

function Autotile:init(path, columns, rows)
    Autotile.super.init(self)
    -- Path must be `[filename]-table-[width]-[height]` format
    self.imagetable = gfx.imagetable.new(path)
    self.tilemap = gfx.tilemap.new()
    self.tilemap:setImageTable(self.imagetable)

    self.columns, self.rows = columns, rows
    self:setupTilemap()
    self:setTilemap(self.tilemap)
    self:add()
end

function Autotile:getTileIndex(x, y)
    -- Do simpile bitmask-type math to get a mapped index
    if self.tiles[self.getIndex(x, y, self.columns)] == Autotile.STATE.EMPTY then
        return 0
    end

    local bitmap = 1

    if x > 1 and self.tiles[self.getIndex(x - 1, y, self.columns)] ~= Autotile.STATE.EMPTY then
        bitmap += 8
    end
    if x < self.columns and self.tiles[self.getIndex(x + 1, y, self.columns)] ~= Autotile.STATE.EMPTY then
        bitmap += 2
    end

    if y > 1 and self.tiles[self.getIndex(x, y - 1, self.columns)] ~= Autotile.STATE.EMPTY then
        bitmap += 1
    end
    if y < self.rows and self.tiles[self.getIndex(x, y + 1, self.columns)] ~= Autotile.STATE.EMPTY then
        bitmap += 4
    end

    return AUTOTILE_MAP[bitmap]
end

function Autotile:updateTileIndex(x, y)
    -- Refresh a tile
    local tile_index = self:getTileIndex(x, y)
    self.tilemap:setTileAtPosition(x, y, tile_index)
end

function Autotile:setupTilemap()
    -- Reset it
    local callback = function(x, y)
        self:setTile(x, y, Autotile.STATE.EMPTY)
    end
    self.tiles = {}
    self.tiles = Autotile.createData(self.columns, self.rows, Autotile.STATE.EMPTY, callback)
    self.tilemap:setTiles(Autotile.createData(self.columns, self.rows, Autotile.STATE.EMPTY), self.columns)
end

function Autotile:setTile(x, y, state)
    -- State can be whatever, I use an enum
    local index = self.getIndex(x, y, self.columns)
    self.tiles[index] = state
    self:updateTileIndex(x, y)

    if x > 1 then
        self:updateTileIndex(x - 1, y)
    end
    if x < self.columns then
        self:updateTileIndex(x + 1, y)
    end

    if y > 1 then
        self:updateTileIndex(x, y - 1)
    end
    if y < self.rows then
        self:updateTileIndex(x, y+ 1)
    end
end

function Autotile:setCallback(data, width, callback)
    -- Set each cell to the returned value of a callback
    for x = 1, self.columns do
        for y = 1, self.rows do
            local index = Autotile.getIndex(x, y, width)
            self:setTile(x, y, callback(data[index]))
        end
    end
end
