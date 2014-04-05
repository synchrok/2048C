
local composer = require( "composer" )
local scene = composer.newScene()

local score = 0
local touchEvent
local showWin = false

-- r, g, b, text
local colors = {
    {238, 228, 218, 1},
    {237, 224, 200, 1},
    {242, 177, 121, 2},
    {245, 149, 99, 2},
    {246, 124, 95, 2},
    {246, 94, 59, 2},
    {237, 207, 114, 2},
    {237, 204, 97, 2},
    {237, 200, 80, 2},
    {237, 197, 63, 2},
    {237, 197, 63, 2}
}

function scene:create( event )
    local sceneGroup = self.view

    score = 0

    newRect(sceneGroup, 0, 0, 320, 568, {250/255, 248/255, 239/255}, topLeft)

    newRoundedRect(sceneGroup, 320-7, 10, 100, 50, 3, {187/255, 173/255, 160/255}, topRight)
    newText(sceneGroup, "SCORE", 320-57, 20, 10, center, {1, 1, 1})
    scoreUI = newTextBold(sceneGroup, "0", 320-57, 40, 25, center, {1, 1, 1})

    local panX, panY = 17, 140
    newRoundedRect(sceneGroup, panX-10, panY-10, 306, 306, 3, {187/255, 173/255, 160/255}, topLeft)

    for i = 1, 4 do
        for j = 1, 4 do
            newRoundedRect(sceneGroup, panX+(j-1)*74, panY+(i-1)*74, 64, 64, 3, {204/255, 192/255, 179/255}, topLeft)
        end
    end

    local tilex = function(x) return panX+(x-1)*74 end
    local tiley = function(y) return panY+(y-1)*74 end
    
    local tiles = {} 
    for i = 1, 4 do tiles[i] = {} end

    local debugprint = function()
        for i = 1, 4 do
            local str = ""
            for j = 1, 4 do
                if tiles[i][j] == nil then
                    str = str .. "0 "
                else
                    str = str .. tiles[i][j].number .. " "
                end
            end print(str)
        end print("")
    end 

    local addScore = function(s)
        score = score + s
        scoreUI.text(score)
    end

    local winGroup = newGroup(sceneGroup)
    newRect(winGroup, 0, 0, 320, 568, {0, 0, 0, 0.5}, topLeft)
    newText(winGroup, "You Win!", 160, 200, 40, center, {1, 1, 0})
    newText(winGroup, "Score", 160, 270, 20, center, {1, 1, 1})
    local winScore = newText(winGroup, "", 160, 300, 40, center, {1, 1, 1})
    newText(winGroup, "Touch to continue", 160, 380, 20, center, {1, 1, 1})
    winGroup.alpha = 0

    local makeTile = function(x, y, n)
        local tile = newGroup(sceneGroup)

        tile.rect = newRoundedRect(tile, 0, 0, 64, 64, 3, {238/255, 228/255, 218/255}, topLeft)        
        tile.text = newTextBold(tile, n, 32, 32, 30, center, {119/255, 110/255, 101/255})

        tile.anchorChildren = true
        setReferencePoint(tile, center)
        tile.x, tile.y = tilex(x)+32, tiley(y)+32
        
        tile.alpha = 0
        scale(tile, 0.01)
        transition.to(tile, {time=200, xScale=1, yScale=1, alpha=1, transition=easing.inQuad})

        tile.level = t(n==2, 1, 2)
        tile.tx, tile.ty = x, y
        tile.number = n
        tile.moving = false
        tile.upgrading = false
        tile.toUpgrade = false

        if showWin then
            winGroup:toFront()
            transition.to(winGroup, {time=300, alpha=1})
            winScore.text = score
        end

        if n == 4 then
            tile.rect.fill = {colors[tile.level][1]/255, colors[tile.level][2]/255, colors[tile.level][3]/255}
        end

        tile.move = function(vector, distance, die)
            local tile = tiles[tile.ty][tile.tx]

            tile.moving = true

            local nx, ny = tile.tx+vector.x*distance, tile.ty+vector.y*distance

            if not die then
                tiles[ny][nx] = tiles[tile.ty][tile.tx]
                tiles[tile.ty][tile.tx] = nil
                tile.tx, tile.ty = nx, ny
            else
                tiles[tile.ty][tile.tx] = nil
                tile:toBack()
            end
          
            transition.to(tile, {time=200, x=tilex(nx)+32, y=tiley(ny)+32, transition=easing.inOutExpo, onComplete=function()
                tile.moving = false
                if die then
                    tile:removeSelf()
                    tile = nil
                else
                    if tile.toUpgrade then
                        tile.toUpgrade = false
                        tile.upgrade()
                    end
                end                
            end})
        end

        tile.upgrade = function()
            if tile.moving then
                tile.toUpgrade = true
            else
                local tile = tiles[tile.ty][tile.tx]
                tile.level = tile.level + 1
                tile.number = tile.number * 2
                addScore(tile.number)
                tile.text.text(tile.number)
                if colors[tile.level][4] == 2 then
                    tile.text.fill({1, 1, 1})
                end
                tile.rect.fill = {colors[tile.level][1]/255, colors[tile.level][2]/255, colors[tile.level][3]/255}
                transition.to(tile, {time=100, xScale=1.2, yScale=1.2, onComplete=function()
                    transition.to(tile, {time=100, xScale=1, yScale=1})
                end})

                if tile.number == 2048 then
                    showWin = true                    
                end
            end
        end

        tiles[y][x] = tile
    end

    local getBlankTiles = function()
        local blanks = {}
        for i = 1, 4 do
            for j = 1, 4 do
                if tiles[i][j] == nil then
                    table.insert(blanks, {j, i})
                end
            end
        end

        return blanks
    end

    local makeTileInBlank = function()
        local blanks = getBlankTiles()
        local r = math.random(1, #blanks)
        local n = t(math.random(1, 10)<9, 2, 4)

        makeTile(blanks[r][1], blanks[r][2], n)    
    end

    local init = function()
        makeTileInBlank()
        makeTileInBlank()
    end init()

    debugprint()

    local getVector = function(way)
        if way == "left" then
            return {x=-1, y=0}
        elseif way == "right" then
            return {x=1, y=0}
        elseif way == "up" then
            return {x=0, y=-1}
        elseif way == "down" then
            return {x=0, y=1} 
        end
    end

    local getNearTileInWay = function(x, y, vector)
        for i = 1, 4 do
            x, y = x+vector.x, y+vector.y
            if x < 1 or y < 1 or x > 4 or y > 4 then break end
            if tiles[y][x] ~= nil then
                return tiles[y][x]
            end
        end
    end

    local upgradingClear = function()
        for i = 1, 4 do
            for j = 1, 4 do
                if tiles[i][j] ~= nil and tiles[i][j].upgrading then
                    tiles[i][j].upgrading = false
                end
            end
        end
    end

    local moving = function(way)
        local moved = false
        local vector = getVector(way)        
        local blankCount = 0

        -- can not modularization cause of bug
        if way == "up" or way == "down" then
            for j = 1, 4 do
                blankCount = 0
                for i = t(way=="up", 1, 4), t(way=="up", 4, 1), -vector.y do 
                    if tiles[i][j] ~= nil then
                        local nearest = getNearTileInWay(j, i, vector)
                        if nearest ~= nil and tiles[i][j].number == nearest.number and not tiles[i][j].upgrading and not nearest.upgrading then
                            tiles[i][j].upgrading, nearest.upgrading = true, true
                            local distance = math.abs(tiles[i][j].ty-nearest.ty)                            
                            tiles[i][j].move(vector, distance, true) -- bomb self
                            blankCount = blankCount + 1
                            nearest.upgrade()
                            moved = true
                        else
                            if blankCount > 0 then
                                tiles[i][j].move(vector, blankCount)
                                moved = true
                            end
                        end
                    else
                        blankCount = blankCount + 1
                    end 

                end
            end
        elseif way == "left" or way == "right" then
            for i = 1, 4 do
                blankCount = 0
                for j = t(way=="left", 1, 4), t(way=="left", 4, 1), -vector.x do 
                    if tiles[i][j] ~= nil then
                        local nearest = getNearTileInWay(j, i, vector)
                        if nearest ~= nil and tiles[i][j].number == nearest.number and not tiles[i][j].upgrading and not nearest.upgrading then
                            tiles[i][j].upgrading, nearest.upgrading = true, true
                            local distance = math.abs(tiles[i][j].ty-nearest.ty)                            
                            tiles[i][j].move(vector, distance, true) -- bomb self
                            blankCount = blankCount + 1
                            nearest.upgrade()
                            moved = true
                        else
                            if blankCount > 0 then
                                tiles[i][j].move(vector, blankCount)
                                moved = true
                            end
                        end
                    else
                        blankCount = blankCount + 1
                    end 

                end
            end
        end

        if moved then
            makeTileInBlank()
            upgradingClear()
        end
    end

    local moved, tsx, tsy
    touchEvent = function(e)
        if showWin then
            if e.phase == "began" then
                showWin = false
                transition.to(winGroup, {time=200, alpha=0})
            end
        else
            if e.phase == "began" then
                tsx, tsy = e.x, e.y
                moved = false
            elseif e.phase == "moved" and not moved then
                if math.abs(e.y - tsy) > 100 then
                    if e.y > tsy then
                        moving("down") 
                        moved = true
                    else
                        moving("up") 
                        moved = true end
                elseif math.abs(e.x - tsx) > 100 then
                    if e.x > tsx then
                        moving("right") 
                        moved = true
                    else
                        moving("left")
                        moved = true end
                end
            elseif e.phase == "ended" then
            end
        end
    end
    Runtime:addEventListener( "touch", touchEvent )
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene