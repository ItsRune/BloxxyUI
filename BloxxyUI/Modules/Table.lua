local tbl = {}

function tbl.insert(tbl, value)
    return table.insert(tbl, value)
end

function tbl.remove(tbl, index)
    return table.remove(tbl, index)
end

function tbl.concat(tbl, sep, i, j)
    return table.concat(tbl, sep, i, j)
end

function tbl.len(tbl, recursive)
    local x = 0
    
    if recursive then
        for i,v in next, tbl do
            if typeof(v) == "table" then
                x = x + tbl.len(v)
            else
                x = x + 1
            end
        end
    else
        for i,v in next, tbl do
            x = x + 1
        end
    end

    return x
end

function tbl.create(count, val)
    return table.create(count, val)
end

function tbl.foreach(tbl, callback)
    return table.foreach(tbl, callback)
end

function tbl.foreachi(tbl, callback)
    return table.foreachi(tbl, callback)
end

return tbl