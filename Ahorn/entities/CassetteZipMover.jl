module CommunalHelperCassetteZipMover

using ..Ahorn, Maple

@mapdef Entity "CommunalHelper/CassetteZipMover" CassetteZipMover(x::Integer, 
                                                                  y::Integer, 
                                                                  width::Integer=Maple.defaultBlockWidth, 
                                                                  height::Integer=Maple.defaultBlockHeight,
                                                                  index::Integer=0,
                                                                  tempo::Number=1.0) 

const colorNames = Dict{String, Int}(
    "Blue" => 0,
    "Rose" => 1,
    "Bright Sun" => 2,
    "Malachite" => 3
)

const colors = Dict{Int, Ahorn.colorTupleType}(
    1 => (240, 73, 190, 255) ./ 255,
	2 => (252, 220, 58, 255) ./ 255,
	3 => (56, 224, 78, 255) ./ 255
)

const ropeColors = Dict{Int, Ahorn.colorTupleType}(
    1 => (194, 116, 171, 255) ./ 255,
	2 => (227, 214, 148, 255) ./ 255,
	3 => (128, 224, 141, 255) ./ 255
)

const defaultRopeColor = (110, 189, 245, 255) ./ 255
const defaultColor = (73, 170, 240, 255) ./ 255

const placements = Ahorn.PlacementDict(
    "Cassette Zip Mover ($index - $color) (Communal Helper)" => Ahorn.EntityPlacement(
        CassetteZipMover,
        "rectangle",
        Dict{String, Any}(
            "index" => index,
        ),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + Int(entity.data["width"]) + 8, Int(entity.data["y"]))]
        end
    ) for (color, index) in colorNames
)

Ahorn.editingOptions(entity::CassetteZipMover) = Dict{String, Any}(
    "index" => colorNames
)

Ahorn.nodeLimits(entity::CassetteZipMover) = 1, 1

Ahorn.minimumSize(entity::CassetteZipMover) = 16, 16
Ahorn.resizable(entity::CassetteZipMover) = true, true

function Ahorn.selection(entity::CassetteZipMover)
    x, y = Ahorn.position(entity)
    nx, ny = Int.(entity.data["nodes"][1])

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    return [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(nx + floor(Int, width / 2) - 5, ny + floor(Int, height / 2) - 5, 10, 10)]
end

function getTextures(entity::CassetteZipMover)
    return "objects/cassetteblock/solid", "objects/CommunalHelper/cassetteZipMover/cog"
end

function renderCassetteZipMover(ctx::Ahorn.Cairo.CairoContext, entity::CassetteZipMover)
    x, y = Ahorn.position(entity)
    nx, ny = Int.(entity.data["nodes"][1])

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    block, cog = getTextures(entity)

    index = Int(get(entity.data, "index", 0))
    color = get(colors, index, defaultColor)
    ropeColor = get(ropeColors, index, defaultRopeColor)

    # Node Rendering
    cx, cy = x + width / 2, y + height / 2
    cnx, cny = nx + width / 2, ny + height / 2
    length = sqrt((x - nx)^2 + (y - ny)^2)
    theta = atan(cny - cy, cnx - cx)

    Ahorn.Cairo.save(ctx)
    Ahorn.set_antialias(ctx, 1)
    Ahorn.set_line_width(ctx, 1)
    Ahorn.translate(ctx, cx, cy)
    Ahorn.rotate(ctx, theta)
    Ahorn.setSourceColor(ctx, ropeColor)
    # Offset for rounding errors
    Ahorn.move_to(ctx, 0, 4 + (theta <= 0))
    Ahorn.line_to(ctx, length, 4 + (theta <= 0))
    Ahorn.move_to(ctx, 0, -4 - (theta > 0))
    Ahorn.line_to(ctx, length, -4 - (theta > 0))
    Ahorn.stroke(ctx)
    Ahorn.Cairo.restore(ctx)
    Ahorn.drawSprite(ctx, cog, cnx, cny, tint=color)
    
    for i in 1:tilesWidth, j in 1:tilesHeight
        tx = (i == 1) ? 0 : ((i == tilesWidth) ? 16 : 8)
        ty = (j == 1) ? 0 : ((j == tilesHeight) ? 16 : 8)

        Ahorn.drawImage(ctx, block, x + (i - 1) * 8, y + (j - 1) * 8, tx, ty, 8, 8, tint=color)
    end
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::CassetteZipMover, room::Maple.Room)
    renderCassetteZipMover(ctx, entity)
end

end