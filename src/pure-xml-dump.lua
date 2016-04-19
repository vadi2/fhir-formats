-- Copyright (C) Marcin Kalicinski 2006, 2009, Gaspard Bucher 2014.

-- This software may be modified and distributed under the terms
-- of the MIT license.  See the MIT-LICENSE file for details.

-- this is a cannibalised XML encoding portion of https://github.com/lubyk/xml

local ipairs, pairs, insert, type,
      match, tostring =
      ipairs, pairs, table.insert, type,
      string.match, tostring

local function escape(v)
  if type(v) == 'boolean' then
    return v and 'true' or 'false'
  else
    return v:gsub('&','&amp;'):gsub('>','&gt;'):gsub('<','&lt;'):gsub("'",'&apos;')
  end
end

local function tagWithAttributes(data)
  local res = data.xml or 'table'
  for k,v in pairs(data) do
    if k ~= 'xml' and type(k) == 'string' then
      res = res .. ' ' .. k .. "='" .. escape(v) .. "'"
    end
  end
  return res
end

local function doDump(data, indent, output, last, depth, max_depth)
  if depth > max_depth then
    error(string.format("Could not dump table to XML. Maximal depth of %i reached.", max_depth))
  end

  if data[1] then
    insert(output, (last == 'n' and indent or '')..'<'..tagWithAttributes(data)..'>')
    last = 'n'
    local ind = indent..'  '
    for _, child in ipairs(data) do
      local typ = type(child)
      if typ == 'table' then
        doDump(child, ind, output, last, depth + 1, max_depth)
        last = 'n'
      elseif typ == 'number' then
        insert(output, tostring(child))
      else
        local s = escape(child)
        insert(output, s)
        last = 's'
      end
    end
    insert(output, (last == 'n' and indent or '')..'</'..(data.xml or 'table')..'>')
    last = 'n'
  else
    -- no children
    insert(output, (last == 'n' and indent or '')..'<'..tagWithAttributes(data)..'/>')
    last = 'n'
  end
end

local function dump(data, max_depth)
  local max_depth = max_depth or 3000
  local res = {}
  doDump(data, '\n', res, 's', 1, max_depth)
  return table.concat(res, '')
end

return dump
