Config = {
    Map = "math.market_base",
    Items = {
        "math.market_extention", "math.market_wall", "math.market_roof", "math.market_wall_base",
        "math.market_payment", "math.market_bakery",
        "math.market_boss"
    }
}

-- Shops static table
local shops = {
    payment = {
        shops = {
            {
                enable = true,
                position = Number3(34.28, 5.00, 150.94),
                rotation =  Number3(0, -math.pi / 2, 0),
                level = 1
            }
        },
        model = Items.math.market_payment,
        scale = 2.3,
        itemsPerSeconds = 1,
        itemsPrice = nil,
        price = 20,
    },
    bakery = {
        shops = {
            {
                enable = true,
                position = Number3(110, 4.00, 210),
                rotation =  Number3(0, 0, 0),
                level = 1
            },
        },
        model = Items.math.market_bakery,
        scale = 2,
        itemsPerSeconds = 1,
        itemsPrice = 1,
        price = 20,
    }
}

function spawnMarket(item, x, y, z)
    local map = Shape(item)

    map.Pivot = Number3(0, 0, 0)
    map.Scale = 5
    map.Position = Number3(x, y, z)
    map.Physics = PhysicsMode.StaticPerBlock
    map.Friction = Map.Friction
    map.Bounciness = Map.Bounciness

    World:AddChild(map)
    map.CollisionGroups = 1

    return map
end

Client.OnStart = function()
    
    -- Init Player

    Player.money = 0
    Player.market = {
        level = 1,
        shops = shops
    }

    -- Init Map

    Map.items = {}
    Map.shops = {}
    Map.npc = {}

    Map.addShop = function(self, meta, shop)
        local item = Shape(meta.model)

        item.Pivot = Number3(0, 0, 0)
        item.Position = shop.position
        item.Rotation = shop.rotation
        item.Scale = meta.scale
        item.Physics = PhysicsMode.StaticPerBlock
        item.Friction = Map.Friction
        item.Bounciness = Map.Bounciness
        item.CollisionGroups = 1

        World:AddChild(item)
        table.insert(self.shops, item)
        return item
    end

    Map.addnpc = function(self, npc)
        local item = Shape(npc.model)

        item.Pivot = Number3(0, 0, 0)
        item.Position = npc.position
        item.Rotation = npc.rotation
        item.Scale = npc.scale
        item.Physics = PhysicsMode.StaticPerBlock
        item.Friction = Map.Friction
        item.Bounciness = Map.Bounciness
        item.name = npc.name
        item.CollisionGroups = 1
    
        World:AddChild(item)
        table.insert(self.npc, item)
        return item
    end

    -- Init Market Shapes

    spawnMarket(Items.math.market_roof, -5, 45, -5) -- Roof of main part
    spawnMarket(Items.math.market_wall_base, -5, 0, -5) -- Wall main part
    Map.items.wall = spawnMarket(Items.math.market_wall, Map.Width * 5, 5, 0) -- Wall
    -- TODO: Add extentions

    -- Init Sync Server
    -- TODO: Sync Server

    -- Init Shops Shapes

    for _, shops in pairs(Player.market.shops) do
        if shops.model ~= nil then
            for _, shop in pairs(shops.shops) do
                if shop.enable == true then
                    Map:addShop(shops, shop)
                end
            end
        end
    end

    -- Init NPCs Shapes
    local boss = {
        model = Items.math.market_boss,
        position = Number3(12, 5, 237),
        rotation = Number3(0, math.pi / 3, 0),
        scale = 0.7,
        name = "boss"
    }
    Map:addnpc(boss)

    dropPlayer = function()
        Player.Position = Number3(15.21, 5.01, 212.48)
        Player.Rotation = { 0, math.pi / 2, 0 }
        Player.Velocity = { 0, 0, 0 }
    end

    -- START GAME

    World:AddChild(Player)
    dropPlayer()

    -- Init Time
    TimeCycle.On = false
    Fog.On = false
    Time.Current = Time.Noon

end

Client.Tick = function(dt)
    if Player.Position.Y < -500 then
        dropPlayer()
        Player:TextBubble("💀 Oops!")
    end
end

Client.Action1 = function()
    if Player.IsOnGround then
        Player.Velocity.Y = 100
    end
end
