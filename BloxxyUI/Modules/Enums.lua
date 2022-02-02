local Enums = {
    _enums = {
        ["Scrolling"] = {
            ["Type"] = {
                ["DevProducts"] = "developer_products";
            };
        };
    };
}
Enums.__index = Enums;
local findInTables

function findInTables(tbl, index, prefix)
    prefix = prefix or "Enum"
    local found = nil

    for i,v in next, tbl do
        if i == index then
            return tbl[i], prefix
        elseif typeof(v) == "table" then
            found = findInTables(v, index)
        end
        prefix = prefix .. "." .. index
    end
    
    if prefix ~= "" then
        return found, prefix
    end
end

function Enums:Get(Name)
    local found,prefix = findInTables(self._enums, Name)

    return found
end

function Enums.new(Type)

end

return Enums