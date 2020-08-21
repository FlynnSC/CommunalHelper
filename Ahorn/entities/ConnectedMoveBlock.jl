module CommunalHelperConnectedMoveBlock
using ..Ahorn, Maple

@mapdef Entity "CommunalHelper/ConnectedMoveBlock" ConnectedMoveBlock(
                            x::Integer, y::Integer,
                            width::Integer = Maple.defaultBlockWidth, 
                            height::Integer = Maple.defaultBlockWidth,
                            direction::String="Right", 
                            fast::Bool=false)

const placements = Ahorn.PlacementDict(
    "Connected Move Block ($direction) (Communal Helper)" => Ahorn.EntityPlacement(
        ConnectedMoveBlock,
        "rectangle",
        Dict{String, Any}(
            "direction" => direction
        )
    ) for direction in Maple.move_block_directions
)

Ahorn.editingOptions(entity::ConnectedMoveBlock) = Dict{String, Any}(
    "direction" => Maple.move_block_directions
)
Ahorn.minimumSize(entity::ConnectedMoveBlock) = 16, 16
Ahorn.resizable(entity::ConnectedMoveBlock) = true, true

Ahorn.selection(entity::ConnectedMoveBlock) = Ahorn.getEntityRectangle(entity)

const arrows = Dict{String, String}(
    "up" => "objects/moveBlock/arrow02",
    "left" => "objects/moveBlock/arrow04",
    "right" => "objects/moveBlock/arrow00",
    "down" => "objects/moveBlock/arrow06",
)
const buttonColor = (71, 64, 112, 255) ./ 255
const button = "objects/moveBlock/button"

const midColor = (4, 3, 23, 255) ./ 255
const highlightColor = (59, 50, 101, 255) ./ 255

# Gets rectangles from Solid Extensions
function getExtensionRectangles(room::Maple.Room)
    entities = filter(e -> e.name == "CommunalHelper/SolidExtension", room.entities)
    rects = []

    for e in entities
        push!(rects, Ahorn.Rectangle(
            Int(get(e.data, "x", 0)),
            Int(get(e.data, "y", 0)),
            Int(get(e.data, "width", 8)),
            Int(get(e.data, "height", 8))
        ))
    end
        
    return rects
end

# Checks for collision with an array of rectangles at specified tile position
function notAdjacent(entity::ConnectedMoveBlock, ox, oy, rects)
    x, y = Ahorn.position(entity)
    rect = Ahorn.Rectangle(x + ox + 4, y + oy + 4, 1, 1)

    for r in rects
        if Ahorn.checkCollision(r, rect)
            return false
        end
    end

    return true
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::ConnectedMoveBlock, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    tileWidth = div(width, 8)
    tileHeight = div(height, 8)

    Ahorn.drawRectangle(ctx, 1, 1, width - 2, height - 2, highlightColor, highlightColor)
    Ahorn.drawRectangle(ctx, 8, 8, width - 16, height - 16, midColor)

    direction = lowercase(get(entity.data, "direction", "up"))
    arrowSprite = Ahorn.getSprite(arrows[lowercase(direction)], "Gameplay")

    block, innerCorners = "objects/moveBlock/base",  "objects/CommunalHelper/connectedMoveBlock/innerCorners"

    rects = getExtensionRectangles(room)
    rect = Ahorn.Rectangle(x, y, width, height)
	if !(rect in rects)
        push!(rects, rect)
    end

    for i in 1:tileWidth, j in 1:tileHeight
		drawX, drawY = (i - 1) * 8, (j - 1) * 8
		
        closedLeft = !notAdjacent(entity, drawX - 8, drawY, rects)
        closedRight = !notAdjacent(entity, drawX + 8, drawY, rects)
        closedUp = !notAdjacent(entity, drawX, drawY - 8, rects)
        closedDown = !notAdjacent(entity, drawX, drawY + 8, rects)
        completelyClosed = closedLeft && closedRight && closedUp && closedDown

        if completelyClosed
            
            if notAdjacent(entity, drawX + 8, drawY - 8, rects)
                # up right
                Ahorn.drawImage(ctx, innerCorners, drawX, drawY, 8, 0, 8, 8)

            elseif notAdjacent(entity, drawX - 8, drawY - 8, rects)
                # up left
                Ahorn.drawImage(ctx, innerCorners, drawX, drawY, 0, 0, 8, 8)

            elseif notAdjacent(entity, drawX + 8, drawY + 8, rects)
                # down right
                Ahorn.drawImage(ctx, innerCorners, drawX, drawY, 8, 8, 8, 8)

            elseif notAdjacent(entity, drawX - 8, drawY + 8, rects)
                # down left
                Ahorn.drawImage(ctx, innerCorners, drawX, drawY, 0, 8, 8, 8)

            else
                # entirely surrounded, fill tile
                Ahorn.drawImage(ctx, block, drawX, drawY, 8, 8, 8, 8)

            end
        else 
            if closedLeft && closedRight && !closedUp && closedDown
                Ahorn.drawImage(ctx, block, drawX, drawY, 8, 0, 8, 8)

            elseif closedLeft && closedRight && closedUp && !closedDown
                Ahorn.drawImage(ctx, block, drawX, drawY, 8, 16, 8, 8)

            elseif closedLeft && !closedRight && closedUp && closedDown
                Ahorn.drawImage(ctx, block, drawX, drawY, 16, 8, 8, 8)

            elseif !closedLeft && closedRight && closedUp && closedDown
                Ahorn.drawImage(ctx, block, drawX, drawY, 0, 8, 8, 8)

            elseif closedLeft && !closedRight && !closedUp && closedDown
                Ahorn.drawImage(ctx, block, drawX, drawY, 16, 0, 8, 8)

            elseif !closedLeft && closedRight && !closedUp && closedDown
                Ahorn.drawImage(ctx, block, drawX, drawY, 0, 0, 8, 8)

            elseif !closedLeft && closedRight && closedUp && !closedDown
                Ahorn.drawImage(ctx, block, drawX, drawY, 0, 16, 8, 8)

            elseif closedLeft && !closedRight && closedUp && !closedDown
                Ahorn.drawImage(ctx, block, drawX, drawY, 16, 16, 8, 8)
            end
        end
    end

    Ahorn.drawRectangle(ctx, div(width - arrowSprite.width, 2) + 1, div(height - arrowSprite.height, 2) + 1, 8, 8, highlightColor, highlightColor)
    Ahorn.drawImage(ctx, arrowSprite, div(width - arrowSprite.width, 2), div(height - arrowSprite.height, 2))
end

end