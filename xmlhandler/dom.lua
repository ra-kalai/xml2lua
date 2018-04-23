----
--      Handler to generate a DOM-like node tree structure with 
--      a single ROOT node parent - each node is a table comprising 
--      fields below.
--  
--      node = { _name = <Element Name>,
--              _type = ROOT|ELEMENT|TEXT|COMMENT|PI|DECL|DTD,
--              _attr = { Node attributes - see callback API },
--              _parent = <Parent Node>
--              _children = { List of child nodes - ROOT/NODE only }
--            }
--
--      The dom structure is capable of representing any valid XML document
--
-- Options
-- =======
--    options.(comment|pi|dtd|decl)Node = bool 
--        - Include/exclude given node types
--
--  License:
--  ========
--
--      This code is freely distributable under the terms of the [MIT license](LICENSE).
--
--@author Paul Chakravarti (paulc@passtheaardvark.com)
--@author Manoel Campos da Silva Filho

local _G, print, string, table, pairs, type, tostring, tonumber, error, io
      = 
      _G, print, string, table, pairs, type, tostring, tonumber, error, io

if _VERSION:match("5%.1") then
    module "xmlhandler.dom"
end

local options = {commentNode=1, piNode=1, dtdNode=1, declNode=1}
local root = { _children = {n=0}, _type = "ROOT" }
local current = root

function starttag(self, t, a)
        local node = { _type = 'ELEMENT', 
                        _name = t, 
                        _attr = a, 
                        _parent = current,
                        _children = {n=0} }
        table.insert(current._children,node)
        current = node
end

function endtag(self, t, s)
        if t ~= current._name then
        error("XML Error - Unmatched Tag ["..s..":"..t.."]\n")
        end
        current = current._parent
end

function text(self, t)
        local node = { _type = "TEXT", 
                        _parent = current,
                        _text = t }
        table.insert(current._children,node)
end

function comment(self, t)
        if options.commentNode then
        local node = { _type = "COMMENT", 
                        _parent = current,
                        _text = t }
        table.insert(current._children,node)
        end
end

function pi(self, t, a)
        if options.piNode then
        local node = { _type = "PI", 
                        _name = t,
                        _attr = a, 
                        _parent = current }
        table.insert(current._children,node)
        end
end

function decl(self, t, a)
        if options.declNode then
        local node = { _type = "DECL", 
                        _name = t,
                        _attr = a, 
                        _parent = current }
        table.insert(current._children,node)
        end
end

function dtd(self, t, a)
        if options.dtdNode then
        local node = { _type = "DTD", 
                        _name = t,
                        _attr = a, 
                        _parent = current }
        table.insert(current._children,node)
        end
end

cdata = text

return {
    root=root,
    options=options,
    starttag=starttag,
    endtag=endtag,
    text=text,
    comment=comment,
    pi=pi,
    decl=decl,
    dtd=dtd,
    cdata=text,
}
