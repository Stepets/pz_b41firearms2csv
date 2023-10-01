local parser = {}

function parser.new()
    local p = { 
        env = {
            module = setmetatable({},{
                __index = function(self, key)
                    print('module', key)
                    self[key] = setmetatable({}, {
                        __call = function(self, tbl)
                            for k,v in pairs(tbl) do
                                print('adding', k, v)
                                if self[k] then
                                    print('warning: Overriding ', key .. '.' .. k)
                                end
                                self[k] = v
                            end
                        end
                    })
                    return self[key]
                end
            })
        }
    }
    return setmetatable(p, {__index = parser})
end

function parser:parse(text)
    text = text:gsub('/%*.-%*/', '')
    text = text:gsub('(%w+)%s*=%s*(.-),', '%1 = "%2",')
    text = text:gsub('module (%w+)%s+', 'module["%1"] ')
    text = text:gsub('item%s+([^%s]+)%s+{(.-)}', '["%1"] = {%2},')
    --print(text)

    local func, err = load(text, 'empty', 't', self.env)
    if not func then
        error(err)
    end
    func()
end

local function dump(val, tab)
  tab = tab or ''

  if type(val) == 'table' then
    io.write('{\n')
    for k,v in pairs(val) do
      io.write(tab .. tostring(k) .. " = ")
      dump(v, tab .. '\t')
      io.write("\n")
    end
    io.write(tab .. '}\n')
  else
    io.write(tostring(val))
  end
end

function parser:dump()
    dump(self.env.module)
end

function parser:csv(...)
    local res = 'item'
    local fields = {...}
    -- headers
    for _, field in pairs(fields) do
        res = res .. ',' .. field
    end
    res = res .. '\n'
    -- values
    for module_name, module in pairs(self.env.module) do
        for item_name, item in pairs(module) do
            res = res .. module_name .. '.' .. item_name
            for _, field in pairs(fields) do
                local val = item[field] or 'null'
                res = res .. ',' .. val
            end
            res = res .. '\n'
        end
    end

    return res
end

return parser