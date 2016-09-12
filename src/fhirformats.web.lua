package.preload['lunajson._str_lib']=(function(...)
local e=math.huge
local u,s,l=string.byte,string.char,string.sub
local a=setmetatable
local o=math.floor
local t=nil
local t={
0,1,2,3,4,5,6,7,8,9,e,e,e,e,e,e,
e,10,11,12,13,14,15,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,10,11,12,13,14,15,e,e,e,e,e,e,e,e,e,
}
t.__index=function()
return e
end
a(t,t)
return function(r)
local h={
['"']='"',
['\\']='\\',
['/']='/',
['b']='\b',
['f']='\f',
['n']='\n',
['r']='\r',
['t']='\t'
}
h.__index=function()
r("invalid escape sequence")
end
a(h,h)
local a=0
local function c(d,n)
local i
if d=='u'then
local u,d,c,h=u(n,1,4)
local t=t[u-47]*4096+t[d-47]*256+t[c-47]*16+t[h-47]
if t==e then
r("invalid unicode charcode")
end
n=l(n,5)
if t<128 then
i=s(t)
elseif t<2048 then
i=s(192+o(t*.015625),128+t%64)
elseif t<55296 or 57344<=t then
i=s(224+o(t*.000244140625),128+o(t*.015625)%64,128+t%64)
elseif 55296<=t and t<56320 then
if a==0 then
a=t
if n==''then
return''
end
end
else
if a==0 then
a=1
else
t=65536+(a-55296)*1024+(t-56320)
a=0
i=s(240+o(t*3814697265625e-18),128+o(t*.000244140625)%64,128+o(t*.015625)%64,128+t%64)
end
end
end
if a~=0 then
r("invalid surrogate pair")
end
return(i or h[d])..n
end
local function e()
return a==0
end
return{
subst=c,
surrogateok=e
}
end
end)
package.preload['lunajson.decoder']=(function(...)
local w=error
local s,e,h,y,l,u=string.byte,string.char,string.find,string.gsub,string.match,string.sub
local r=tonumber
local n,v=tostring,setmetatable
local c
if _VERSION=="Lua 5.3"then
c=require'lunajson._str_lib_lua53'
else
c=require'lunajson._str_lib'
end
local e=nil
local function k()
local a,t,b,f
local d,o
local function i(e)
w("parse error at "..t..": "..e)
end
local function e()
i('invalid value')
end
local function g()
if u(a,t,t+2)=='ull'then
t=t+3
return b
end
i('invalid value')
end
local function k()
if u(a,t,t+3)=='alse'then
t=t+4
return false
end
i('invalid value')
end
local function q()
if u(a,t,t+2)=='rue'then
t=t+3
return true
end
i('invalid value')
end
local n=l(n(.5),'[^0-9]')
local m=r
if n~='.'then
if h(n,'%W')then
n='%'..n
end
m=function(e)
return r(y(e,'.',n))
end
end
local function n()
i('invalid number')
end
local function p(h)
local o=t
local e
local i=s(a,o)
if not i then
return n()
end
if i==46 then
e=l(a,'^.[0-9]*',t)
local e=#e
if e==1 then
return n()
end
o=t+e
i=s(a,o)
end
if i==69 or i==101 then
local a=l(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not a then
return n()
end
if e then
e=a
end
o=t+#a
end
t=o
if e then
e=m(e)
else
e=0
end
if h then
e=-e
end
return e
end
local function r(h)
t=t-1
local e=l(a,'^.[0-9]*%.?[0-9]*',t)
if s(e,-1)==46 then
return n()
end
local o=t+#e
local i=s(a,o)
if i==69 or i==101 then
e=l(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not e then
return n()
end
o=t+#e
end
t=o
e=m(e)-0
if h then
e=-e
end
return e
end
local function m()
local e=s(a,t)
if e then
t=t+1
if e>48 then
if e<58 then
return r(true)
end
else
if e>47 then
return p(true)
end
end
end
i('invalid number')
end
local n=c(i)
local x=n.surrogateok
local j=n.subst
local l=v({},{__mode="v"})
local function c(d)
local e=t-2
local o=t
local r,n
repeat
e=h(a,'"',o,true)
if not e then
i("unterminated string")
end
o=e+1
while true do
r,n=s(a,e-2,e-1)
if n~=92 or r~=92 then
break
end
e=e-2
end
until n~=92
local a=u(a,t,o-2)
t=o
if d then
local e=l[a]
if e then
return e
end
end
local e=a
if h(e,'\\',1,true)then
e=y(e,'\\(.)([^\\]*)',j)
if not x()then
i("invalid surrogate pair")
end
end
if d then
l[a]=e
end
return e
end
local function u()
local r={}
o,t=h(a,'^[ \n\r\t]*',t)
t=t+1
local n=0
if s(a,t)~=93 then
local e=t-1
repeat
n=n+1
o=d[s(a,e+1)]
t=e+2
r[n]=o()
o,e=h(a,'^[ \n\r\t]*,[ \n\r\t]*',t)
until not e
o,e=h(a,'^[ \n\r\t]*%]',t)
if not e then
i("no closing bracket of an array")
end
t=e
end
t=t+1
if f then
r[0]=n
end
return r
end
local function l()
local r={}
o,t=h(a,'^[ \n\r\t]*',t)
t=t+1
if s(a,t)~=125 then
local n=t-1
repeat
t=n+1
if s(a,t)~=34 then
i("not key")
end
t=t+1
local l=c(true)
o=e
do
local i,e,a=s(a,t,t+3)
if i==58 then
n=t
if e==32 then
n=n+1
e=a
end
o=d[e]
end
end
if o==e then
o,n=h(a,'^[ \n\r\t]*:[ \n\r\t]*',t)
if not n then
i("no colon after a key")
end
end
o=d[s(a,n+1)]
t=n+2
r[l]=o()
o,n=h(a,'^[ \n\r\t]*,[ \n\r\t]*',t)
until not n
o,n=h(a,'^[ \n\r\t]*}',t)
if not n then
i("no closing bracket of an object")
end
t=n
end
t=t+1
return r
end
d={
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,c,e,e,e,e,e,e,e,e,e,e,m,e,e,
p,r,r,r,r,r,r,r,r,r,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,u,e,e,e,e,
e,e,e,e,e,e,k,e,e,e,e,e,e,e,g,e,
e,e,e,e,q,e,e,e,e,e,e,l,e,e,e,e,
}
d[0]=e
d.__index=function()
i("unexpected termination")
end
v(d,d)
local function r(r,i,n,e)
a,t,b,f=r,i,n,e
t=t or 1
o,t=h(a,'^[ \n\r\t]*',t)
t=t+1
o=d[s(a,t)]
t=t+1
local e=o()
if i then
return e,t
else
o,t=h(a,'^[ \n\r\t]*',t)
if t~=#a then
w('json ended')
end
return e
end
end
return r
end
return k
end)
package.preload['lunajson.encoder']=(function(...)
local h=error
local b,d,f,r,i=string.byte,string.find,string.format,string.gsub,string.match
local v=table.concat
local o=tostring
local g,l=pairs,type
local w=setmetatable
local k,y=1/0,-1/0
local n
if _VERSION=="Lua 5.1"then
n='[^ -!#-[%]^-\255]'
else
n='[\0-\31"\\]'
end
local e=nil
local function q()
local m,c
local e,t,s
local function p(a)
t[e]=o(a)
e=e+1
end
local a=i(o(.5),'[^0-9]')
local o=i(o(12345.12345),'[^0-9'..a..']')
if a=='.'then
a=nil
end
local u
if a or o then
u=true
if a and d(a,'%W')then
a='%'..a
end
if o and d(o,'%W')then
o='%'..o
end
end
local y=function(i)
if y<i and i<k then
local i=f("%.17g",i)
if u then
if o then
i=r(i,o,'')
end
if a then
i=r(i,a,'.')
end
end
t[e]=i
e=e+1
return
end
h('invalid number')
end
local i
local o={
['"']='\\"',
['\\']='\\\\',
['\b']='\\b',
['\f']='\\f',
['\n']='\\n',
['\r']='\\r',
['\t']='\\t',
__index=function(t,e)
return f('\\u00%02X',b(e))
end
}
w(o,o)
local function u(a)
t[e]='"'
if d(a,n)then
a=r(a,n,o)
end
t[e+1]=a
t[e+2]='"'
e=e+3
end
local function r(o)
if s[o]then
h("loop detected")
end
s[o]=true
local a=o[0]
if l(a)=='number'then
t[e]='['
e=e+1
for a=1,a do
i(o[a])
t[e]=','
e=e+1
end
if a>0 then
e=e-1
end
t[e]=']'
else
a=o[1]
if a~=nil then
t[e]='['
e=e+1
local n=2
repeat
i(a)
a=o[n]
if a==nil then
break
end
n=n+1
t[e]=','
e=e+1
until false
t[e]=']'
else
t[e]='{'
e=e+1
local n=e
for a,o in g(o)do
if l(a)~='string'then
h("non-string key")
end
u(a)
t[e]=':'
e=e+1
i(o)
t[e]=','
e=e+1
end
if e>n then
e=e-1
end
t[e]='}'
end
end
e=e+1
s[o]=nil
end
local o={
boolean=p,
number=y,
string=u,
table=r,
__index=function()
h("invalid type value")
end
}
w(o,o)
function i(a)
if a==c then
t[e]='null'
e=e+1
return
end
return o[l(a)](a)
end
local function o(o,a)
m,c=o,a
e,t,s=1,{},{}
i(m)
return v(t)
end
return o
end
return q
end)
package.preload['lunajson.sax']=(function(...)
local j=error
local i,N,l,k,f,u=string.byte,string.char,string.find,string.gsub,string.match,string.sub
local q=tonumber
local I,r,z=tostring,type,table.unpack or unpack
local b
if _VERSION=="Lua 5.3"then
b=require'lunajson._str_lib_lua53'
else
b=require'lunajson._str_lib'
end
local e=nil
local function e()end
local function g(h,n)
local a,d
local o,t,y=0,1,0
local m,s
if r(h)=='string'then
a=h
o=#a
d=function()
a=''
o=0
d=e
end
else
d=function()
y=y+o
t=1
repeat
a=h()
if not a then
a=''
o=0
d=e
return
end
o=#a
until o>0
end
d()
end
local x=n.startobject or e
local _=n.key or e
local T=n.endobject or e
local E=n.startarray or e
local A=n.endarray or e
local O=n.string or e
local p=n.number or e
local r=n.boolean or e
local w=n.null or e
local function v()
local e=i(a,t)
if not e then
d()
e=i(a,t)
end
return e
end
local function n(e)
j("parse error at "..y+t..": "..e)
end
local function g()
return v()or n("unexpected termination")
end
local function h()
while true do
s,t=l(a,'^[ \n\r\t]*',t)
if t~=o then
t=t+1
return
end
if o==0 then
n("unexpected termination")
end
d()
end
end
local function e()
n('invalid value')
end
local function c(a,e,s,o)
for e=1,e do
local o=g()
if i(a,e)~=o then
n("invalid char")
end
t=t+1
end
return o(s)
end
local function H()
if u(a,t,t+2)=='ull'then
t=t+3
return w(nil)
end
return c('ull',3,nil,w)
end
local function R()
if u(a,t,t+3)=='alse'then
t=t+4
return r(false)
end
return c('alse',4,false,r)
end
local function S()
if u(a,t,t+2)=='rue'then
t=t+3
return r(true)
end
return c('rue',3,true,r)
end
local r=f(I(.5),'[^0-9]')
local w=q
if r~='.'then
if l(r,'%W')then
r='%'..r
end
w=function(e)
return q(k(e,'.',r))
end
end
local function c(h)
local s={}
local o=1
local e=i(a,t)
t=t+1
local function a()
s[o]=e
o=o+1
e=v()
t=t+1
end
if e==48 then
a()
else
repeat a()until not(e and 48<=e and e<58)
end
if e==46 then
a()
if not(e and 48<=e and e<58)then
n('invalid number')
end
repeat a()until not(e and 48<=e and e<58)
end
if e==69 or e==101 then
a()
if e==43 or e==45 then
a()
end
if not(e and 48<=e and e<58)then
n('invalid number')
end
repeat a()until not(e and 48<=e and e<58)
end
t=t-1
local e=N(z(s))
e=w(e)-0
if h then
e=-e
end
return p(e)
end
local function q(h)
local n=t
local e
local s=i(a,n)
if s==46 then
e=f(a,'^.[0-9]*',t)
local e=#e
if e==1 then
t=t-1
return c(h)
end
n=t+e
s=i(a,n)
end
if s==69 or s==101 then
local a=f(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not a then
t=t-1
return c(h)
end
if e then
e=a
end
n=t+#a
end
if n>o then
t=t-1
return c(h)
end
t=n
if e then
e=w(e)
else
e=0
end
if h then
e=-e
end
return p(e)
end
local function r(s)
t=t-1
local e=f(a,'^.[0-9]*%.?[0-9]*',t)
if i(e,-1)==46 then
return c(s)
end
local n=t+#e
local i=i(a,n)
if i==69 or i==101 then
e=f(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not e then
return c(s)
end
n=t+#e
end
if n>o then
return c(s)
end
t=n
e=w(e)-0
if s then
e=-e
end
return p(e)
end
local function p()
local e=i(a,t)or g()
if e then
t=t+1
if e>48 then
if e<58 then
return r(true)
end
else
if e>47 then
return q(true)
end
end
end
n("invalid number")
end
local c=b(n)
local w=c.surrogateok
local f=c.subst
local function c(c)
local h=t
local s
local e=''
local r
while true do
while true do
s=l(a,'[\\"]',h)
if s then
break
end
e=e..u(a,t,o)
if h==o+2 then
h=2
else
h=1
end
d()
end
if i(a,s)==34 then
break
end
h=s+2
r=true
end
e=e..u(a,t,s-1)
t=s+1
if r then
e=k(e,'\\(.)([^\\]*)',f)
if not w()then
n("invalid surrogate pair")
end
end
if c then
return _(e)
end
return O(e)
end
local function w()
E()
h()
if i(a,t)~=93 then
local e
while true do
s=m[i(a,t)]
t=t+1
s()
s,e=l(a,'^[ \n\r\t]*,[ \n\r\t]*',t)
if not e then
s,e=l(a,'^[ \n\r\t]*%]',t)
if e then
t=e
break
end
h()
local a=i(a,t)
if a==44 then
t=t+1
h()
e=t-1
elseif a==93 then
break
else
n("no closing bracket of an array")
end
end
t=e+1
if t>o then
h()
end
end
end
t=t+1
return A()
end
local function f()
x()
h()
if i(a,t)~=125 then
local e
while true do
if i(a,t)~=34 then
n("not key")
end
t=t+1
c(true)
s,e=l(a,'^[ \n\r\t]*:[ \n\r\t]*',t)
if not e then
h()
if i(a,t)~=58 then
n("no colon after a key")
end
t=t+1
h()
e=t-1
end
t=e+1
if t>o then
h()
end
s=m[i(a,t)]
t=t+1
s()
s,e=l(a,'^[ \n\r\t]*,[ \n\r\t]*',t)
if not e then
s,e=l(a,'^[ \n\r\t]*}',t)
if e then
t=e
break
end
h()
local a=i(a,t)
if a==44 then
t=t+1
h()
e=t-1
elseif a==125 then
break
else
n("no closing bracket of an object")
end
end
t=e+1
if t>o then
h()
end
end
end
t=t+1
return T()
end
m={
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,c,e,e,e,e,e,e,e,e,e,e,p,e,e,
q,r,r,r,r,r,r,r,r,r,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,w,e,e,e,e,
e,e,e,e,e,e,R,e,e,e,e,e,e,e,H,e,
e,e,e,e,S,e,e,e,e,e,e,f,e,e,e,e,
}
m[0]=e
local function n()
h()
s=m[i(a,t)]
t=t+1
s()
end
local function s(e)
if e<0 then
j("the argument must be non-negative")
end
local e=(t-1)+e
local i=u(a,t,e)
while e>o and o~=0 do
d()
e=e-(o-(t-1))
i=i..u(a,t,e)
end
if o~=0 then
t=e+1
end
return i
end
local function e()
return y+t
end
return{
run=n,
tryc=v,
read=s,
tellpos=e,
}
end
local function a(e,a)
local e=io.open(e)
local function o()
local t
if e then
t=e:read(8192)
if not t then
e:close()
e=nil
end
end
return t
end
return g(o,a)
end
return{
newparser=g,
newfileparser=a
}
end)
package.preload['lunajson']=(function(...)
local a=require'lunajson.decoder'
local t=require'lunajson.encoder'
local e=require'lunajson.sax'
return{
decode=a(),
encode=t(),
newparser=e.newparser,
newfileparser=e.newfileparser,
}
end)
package.preload['slaxml']=(function(...)
local w={
VERSION="0.7",
_call={
pi=function(t,e)
print(string.format("<?%s %s?>",t,e))
end,
comment=function(e)
print(string.format("<!-- %s -->",e))
end,
startElement=function(a,t,e)
io.write("<")
if e then io.write(e,":")end
io.write(a)
if t then io.write(" (ns='",t,"')")end
print(">")
end,
attribute=function(o,a,e,t)
io.write('  ')
if t then io.write(t,":")end
io.write(o,'=',string.format('%q',a))
if e then io.write(" (ns='",e,"')")end
io.write("\n")
end,
text=function(e)
print(string.format("  text: %q",e))
end,
closeElement=function(e,t,t)
print(string.format("</%s>",e))
end,
}
}
function w:parser(e)
return{_call=e or self._call,parse=w.parse}
end
function w:parse(s,p)
if not p then p={stripWhitespace=false}end
local r,q,y,l,z,k,v=string.find,string.sub,string.gsub,string.char,table.insert,table.remove,table.concat
local e,a,o,i,t,b,m
local w=unpack or table.unpack
local t=1
local f="text"
local d=1
local h={}
local c={}
local u
local n={}
local g=false
local x={{2047,192},{65535,224},{2097151,240}}
local function j(e)
if e<128 then return l(e)end
local t={}
for o,a in ipairs(x)do
if e<=a[1]then
for o=o+1,2,-1 do
local a=e%64
e=(e-a)/64
t[o]=l(128+a)
end
t[1]=l(a[2]+e)
return v(t)
end
end
end
local l={["lt"]="<",["gt"]=">",["amp"]="&",["quot"]='"',["apos"]="'"}
local l=function(a,t,e)return l[e]or t=="#"and j(tonumber('0'..e))or a end
local function v(e)return y(e,'(&(#?)([%d%a]+);)',l)end
local function l()
if e>d and self._call.text then
local e=q(s,d,e-1)
if p.stripWhitespace then
e=y(e,'^%s+','')
e=y(e,'%s+$','')
if#e==0 then e=nil end
end
if e then self._call.text(v(e))end
end
end
local function _()
e,a,o,i=r(s,'^<%?([:%a_][:%w_.-]*) ?(.-)%?>',t)
if e then
l()
if self._call.pi then self._call.pi(o,i)end
t=a+1
d=t
return true
end
end
local function j()
e,a,o=r(s,'^<!%-%-(.-)%-%->',t)
if e then
l()
if self._call.comment then self._call.comment(o)end
t=a+1
d=t
return true
end
end
local function y(e)
if e=='xml'then return'http://www.w3.org/XML/1998/namespace'end
for t=#n,1,-1 do if n[t][e]then return n[t][e]end end
error(("Cannot find namespace for prefix %s"):format(e))
end
local function x()
g=true
e,a,o=r(s,'^<([%a_][%w_.-]*)',t)
if e then
h[2]=nil
h[3]=nil
l()
t=a+1
e,a,i=r(s,'^:([%a_][%w_.-]*)',t)
if e then
h[1]=i
h[3]=o
o=i
t=a+1
else
h[1]=o
for e=#n,1,-1 do if n[e]['!']then h[2]=n[e]['!'];break end end
end
u=0
z(n,{})
return true
end
end
local function q()
e,a,o=r(s,'^%s+([:%a_][:%w_.-]*)%s*=%s*',t)
if e then
b=a+1
e,a,i=r(s,'^"([^<"]*)"',b)
if e then
t=a+1
i=v(i)
else
e,a,i=r(s,"^'([^<']*)'",b)
if e then
t=a+1
i=v(i)
end
end
end
if o and i then
local t={o,i}
local e,a=string.match(o,'^([^:]+):([^:]+)$')
if e then
if e=='xmlns'then
n[#n][a]=i
else
t[1]=a
t[4]=e
end
else
if o=='xmlns'then
n[#n]['!']=i
h[2]=i
end
end
u=u+1
c[u]=t
return true
end
end
local function v()
e,a,o=r(s,'^<!%[CDATA%[(.-)%]%]>',t)
if e then
l()
if self._call.text then self._call.text(o)end
t=a+1
d=t
return true
end
end
local function p()
e,a,o=r(s,'^%s*(/?)>',t)
if e then
f="text"
t=a+1
d=t
if h[3]then h[2]=y(h[3])end
if self._call.startElement then self._call.startElement(w(h))end
if self._call.attribute then
for e=1,u do
if c[e][4]then c[e][3]=y(c[e][4])end
self._call.attribute(w(c[e]))
end
end
if o=="/"then
k(n)
if self._call.closeElement then self._call.closeElement(w(h))end
end
return true
end
end
local function h()
e,a,o,i=r(s,'^</([%a_][%w_.-]*)%s*>',t)
if e then
m=nil
for e=#n,1,-1 do if n[e]['!']then m=n[e]['!'];break end end
else
e,a,i,o=r(s,'^</([%a_][%w_.-]*):([%a_][%w_.-]*)%s*>',t)
if e then m=y(i)end
end
if e then
l()
if self._call.closeElement then self._call.closeElement(o,m)end
t=a+1
d=t
k(n)
return true
end
end
while t<#s do
if f=="text"then
if not(_()or j()or v()or h())then
if x()then
f="attributes"
else
e,a=r(s,'^[^<]+',t)
t=(e and a or t)+1
end
end
elseif f=="attributes"then
if not q()then
if not p()then
error("Was in an element and couldn't find attributes or the close.")
end
end
end
end
if not g then error("Parsing did not discover any elements")end
if#n>0 then error("Parsing ended with unclosed elements")end
end
return w
end)
package.preload['pure-xml-dump']=(function(...)
local c,o,a,n,
e,u=
ipairs,pairs,table.insert,type,
string.match,tostring
local function r(e)
if n(e)=='boolean'then
return e and'true'or'false'
else
return e:gsub('&','&amp;'):gsub('>','&gt;'):gsub('<','&lt;'):gsub("'",'&apos;')
end
end
local function l(t)
local e=t.xml or'table'
for t,a in o(t)do
if t~='xml'and n(t)=='string'then
e=e..' '..t.."='"..r(a).."'"
end
end
return e
end
local function h(o,i,t,e,d,s)
if d>s then
error(string.format("Could not dump table to XML. Maximal depth of %i reached.",s))
end
if o[1]then
a(t,(e=='n'and i or'')..'<'..l(o)..'>')
e='n'
local l=i..'  '
for i,o in c(o)do
local i=n(o)
if i=='table'then
h(o,l,t,e,d+1,s)
e='n'
elseif i=='number'then
a(t,u(o))
else
local o=r(o)
a(t,o)
e='s'
end
end
a(t,(e=='n'and i or'')..'</'..(o.xml or'table')..'>')
e='n'
else
a(t,(e=='n'and i or'')..'<'..l(o)..'/>')
e='n'
end
end
local function a(t,e)
local a=e or 3e3
local e={}
h(t,'\n',e,'s',1,a)
return table.concat(e,'')
end
return a
end)
package.preload['pure-xml-load']=(function(...)
local i=require'slaxml'
local o={}
local e={o}
local t={}
local a=function(i,o,a)
local a=e[#e]
if o~=t[#t]then
t[#t+1]=o
else
o=nil
end
a[#a+1]={xml=i,xmlns=o}
e[#e+1]=a[#a]
end
local n=function(t,a)
local e=e[#e]
e[t]=a
end
local s=function(o,a)
table.remove(e)
if a~=t[#t]then
t[#t]=nil
end
end
local h=function(t)
local e=e[#e]
e[#e+1]=t
end
local i=i:parser{
startElement=a,
attribute=n,
closeElement=s,
text=h
}
local function a(a)
o={}
e={o}
t={}
i:parse(a,{stripWhitespace=true})
return select(2,next(o))
end
return a
end)
package.preload['resty.prettycjson']=(function(...)
local a=require"cjson.safe".encode
local n=table.concat
local m=string.sub
local d=string.rep
return function(t,r,i,l,e)
local t,e=(e or a)(t)
if not t then return t,e end
r,i,l=r or"\n",i or"\t",l or" "
local e,a,u,c,o,s,h=1,0,0,#t,{},nil,nil
local f=m(l,-1)=="\n"
for c=1,c do
local t=m(t,c,c)
if not h and(t=="{"or t=="[")then
o[e]=s==":"and n{t,r}or n{d(i,a),t,r}
a=a+1
elseif not h and(t=="}"or t=="]")then
a=a-1
if s=="{"or s=="["then
e=e-1
o[e]=n{d(i,a),s,t}
else
o[e]=n{r,d(i,a),t}
end
elseif not h and t==","then
o[e]=n{t,r}
u=-1
elseif not h and t==":"then
o[e]=n{t,l}
if f then
e=e+1
o[e]=d(i,a)
end
else
if t=='"'and s~="\\"then
h=not h and true or nil
end
if a~=u then
o[e]=d(i,a)
e,u=e+1,a
end
o[e]=t
end
s,e=t,e+1
end
return n(o)
end
end)
do local t={};
t["fhir-data/fhir-elements.json"]="[\
	{\
		\"path\": \"date\",\
		\"weight\": 1,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"date.id\",\
		\"weight\": 2,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"date.extension\",\
		\"weight\": 3,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"date.value\",\
		\"weight\": 4,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:gYear OR xsd:gYearMonth OR xsd:date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"dateTime\",\
		\"weight\": 5,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"dateTime.id\",\
		\"weight\": 6,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"dateTime.extension\",\
		\"weight\": 7,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"dateTime.value\",\
		\"weight\": 8,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:gYear OR xsd:gYearMonth OR xsd:date OR xsd:dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"code\",\
		\"weight\": 9,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"code.extension\",\
		\"weight\": 10,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"code.value\",\
		\"weight\": 11,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:token\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"string\",\
		\"weight\": 12,\
		\"derivations\": [\
			\"code\",\
			\"id\",\
			\"markdown\"\
		],\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"string.id\",\
		\"weight\": 13,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"string.extension\",\
		\"weight\": 14,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"string.value\",\
		\"weight\": 15,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"integer\",\
		\"weight\": 16,\
		\"derivations\": [\
			\"positiveInt\",\
			\"unsignedInt\"\
		],\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"integer.id\",\
		\"weight\": 17,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"integer.extension\",\
		\"weight\": 18,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"integer.value\",\
		\"weight\": 19,\
		\"type_json\": \"number\",\
		\"type_xml\": \"xsd:int\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"oid\",\
		\"weight\": 20,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"oid.extension\",\
		\"weight\": 21,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"oid.value\",\
		\"weight\": 22,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"uri\",\
		\"weight\": 23,\
		\"derivations\": [\
			\"oid\",\
			\"uuid\"\
		],\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"uri.id\",\
		\"weight\": 24,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"uri.extension\",\
		\"weight\": 25,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"uri.value\",\
		\"weight\": 26,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"uuid\",\
		\"weight\": 27,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"uuid.extension\",\
		\"weight\": 28,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"uuid.value\",\
		\"weight\": 29,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"instant\",\
		\"weight\": 30,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"instant.id\",\
		\"weight\": 31,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"instant.extension\",\
		\"weight\": 32,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"instant.value\",\
		\"weight\": 33,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"boolean\",\
		\"weight\": 34,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"boolean.id\",\
		\"weight\": 35,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"boolean.extension\",\
		\"weight\": 36,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"boolean.value\",\
		\"weight\": 37,\
		\"type_json\": \"true | false\",\
		\"type_xml\": \"xsd:boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"base64Binary\",\
		\"weight\": 38,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"base64Binary.id\",\
		\"weight\": 39,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"base64Binary.extension\",\
		\"weight\": 40,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"base64Binary.value\",\
		\"weight\": 41,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"unsignedInt\",\
		\"weight\": 42,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"unsignedInt.extension\",\
		\"weight\": 43,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"unsignedInt.value\",\
		\"weight\": 44,\
		\"type_json\": \"number\",\
		\"type_xml\": \"xsd:nonNegativeInteger\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"markdown\",\
		\"weight\": 45,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"markdown.extension\",\
		\"weight\": 46,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"markdown.value\",\
		\"weight\": 47,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"time\",\
		\"weight\": 48,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"time.id\",\
		\"weight\": 49,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"time.extension\",\
		\"weight\": 50,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"time.value\",\
		\"weight\": 51,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"id\",\
		\"weight\": 52,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"id.extension\",\
		\"weight\": 53,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"id.value\",\
		\"weight\": 54,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xsd:string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"positiveInt\",\
		\"weight\": 55,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"positiveInt.extension\",\
		\"weight\": 56,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"positiveInt.value\",\
		\"weight\": 57,\
		\"type_json\": \"number\",\
		\"type_xml\": \"xsd:positiveInteger\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"decimal\",\
		\"weight\": 58,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"decimal.id\",\
		\"weight\": 59,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"decimal.extension\",\
		\"weight\": 60,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"decimal.value\",\
		\"weight\": 61,\
		\"type_json\": \"number\",\
		\"type_xml\": \"xsd:decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"xhtml\",\
		\"weight\": 62,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"xhtml.id\",\
		\"weight\": 63,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"xhtml.extension\",\
		\"weight\": 64,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"0\"\
	},\
	{\
		\"path\": \"xhtml.value\",\
		\"weight\": 65,\
		\"type_json\": \"string\",\
		\"type_xml\": \"xhtml:div\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference\",\
		\"weight\": 66,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Reference.id\",\
		\"weight\": 67,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference.extension\",\
		\"weight\": 68,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Reference.reference\",\
		\"weight\": 69,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference.display\",\
		\"weight\": 70,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity\",\
		\"weight\": 71,\
		\"derivations\": [\
			\"Age\",\
			\"Count\",\
			\"Distance\",\
			\"Duration\",\
			\"Money\"\
		],\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Quantity.id\",\
		\"weight\": 72,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.extension\",\
		\"weight\": 73,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Quantity.value\",\
		\"weight\": 74,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.comparator\",\
		\"weight\": 75,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.unit\",\
		\"weight\": 76,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.system\",\
		\"weight\": 77,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.code\",\
		\"weight\": 78,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period\",\
		\"weight\": 79,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Period.id\",\
		\"weight\": 80,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period.extension\",\
		\"weight\": 81,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Period.start\",\
		\"weight\": 82,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period.end\",\
		\"weight\": 83,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment\",\
		\"weight\": 84,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Attachment.id\",\
		\"weight\": 85,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.extension\",\
		\"weight\": 86,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Attachment.contentType\",\
		\"weight\": 87,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.language\",\
		\"weight\": 88,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.data\",\
		\"weight\": 89,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.url\",\
		\"weight\": 90,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.size\",\
		\"weight\": 91,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.hash\",\
		\"weight\": 92,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.title\",\
		\"weight\": 93,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.creation\",\
		\"weight\": 94,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Duration\",\
		\"weight\": 95,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Duration.id\",\
		\"weight\": 96,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Duration.extension\",\
		\"weight\": 97,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Duration.value\",\
		\"weight\": 98,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Duration.comparator\",\
		\"weight\": 99,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Duration.unit\",\
		\"weight\": 100,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Duration.system\",\
		\"weight\": 101,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Duration.code\",\
		\"weight\": 102,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Count\",\
		\"weight\": 103,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Count.id\",\
		\"weight\": 104,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Count.extension\",\
		\"weight\": 105,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Count.value\",\
		\"weight\": 106,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Count.comparator\",\
		\"weight\": 107,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Count.unit\",\
		\"weight\": 108,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Count.system\",\
		\"weight\": 109,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Count.code\",\
		\"weight\": 110,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range\",\
		\"weight\": 111,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Range.id\",\
		\"weight\": 112,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range.extension\",\
		\"weight\": 113,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Range.low\",\
		\"weight\": 114,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range.high\",\
		\"weight\": 115,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation\",\
		\"weight\": 116,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Annotation.id\",\
		\"weight\": 117,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.extension\",\
		\"weight\": 118,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 119,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 119,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 119,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.authorString\",\
		\"weight\": 119,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.time\",\
		\"weight\": 120,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.text\",\
		\"weight\": 121,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Money\",\
		\"weight\": 122,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Money.id\",\
		\"weight\": 123,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Money.extension\",\
		\"weight\": 124,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Money.value\",\
		\"weight\": 125,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Money.comparator\",\
		\"weight\": 126,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Money.unit\",\
		\"weight\": 127,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Money.system\",\
		\"weight\": 128,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Money.code\",\
		\"weight\": 129,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier\",\
		\"weight\": 130,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Identifier.id\",\
		\"weight\": 131,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.extension\",\
		\"weight\": 132,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Identifier.use\",\
		\"weight\": 133,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.type\",\
		\"weight\": 134,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.system\",\
		\"weight\": 135,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.value\",\
		\"weight\": 136,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.period\",\
		\"weight\": 137,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.assigner\",\
		\"weight\": 138,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding\",\
		\"weight\": 139,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coding.id\",\
		\"weight\": 140,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.extension\",\
		\"weight\": 141,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coding.system\",\
		\"weight\": 142,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.version\",\
		\"weight\": 143,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.code\",\
		\"weight\": 144,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.display\",\
		\"weight\": 145,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.userSelected\",\
		\"weight\": 146,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature\",\
		\"weight\": 147,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.id\",\
		\"weight\": 148,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.extension\",\
		\"weight\": 149,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.type\",\
		\"weight\": 150,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.when\",\
		\"weight\": 151,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoUri\",\
		\"weight\": 152,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.onBehalfOfUri\",\
		\"weight\": 153,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.contentType\",\
		\"weight\": 154,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.blob\",\
		\"weight\": 155,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData\",\
		\"weight\": 156,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SampledData.id\",\
		\"weight\": 157,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.extension\",\
		\"weight\": 158,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SampledData.origin\",\
		\"weight\": 159,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.period\",\
		\"weight\": 160,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.factor\",\
		\"weight\": 161,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.lowerLimit\",\
		\"weight\": 162,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.upperLimit\",\
		\"weight\": 163,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.dimensions\",\
		\"weight\": 164,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.data\",\
		\"weight\": 165,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio\",\
		\"weight\": 166,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Ratio.id\",\
		\"weight\": 167,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio.extension\",\
		\"weight\": 168,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Ratio.numerator\",\
		\"weight\": 169,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio.denominator\",\
		\"weight\": 170,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Distance\",\
		\"weight\": 171,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Distance.id\",\
		\"weight\": 172,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Distance.extension\",\
		\"weight\": 173,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Distance.value\",\
		\"weight\": 174,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Distance.comparator\",\
		\"weight\": 175,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Distance.unit\",\
		\"weight\": 176,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Distance.system\",\
		\"weight\": 177,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Distance.code\",\
		\"weight\": 178,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Age\",\
		\"weight\": 179,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Age.id\",\
		\"weight\": 180,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Age.extension\",\
		\"weight\": 181,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Age.value\",\
		\"weight\": 182,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Age.comparator\",\
		\"weight\": 183,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Age.unit\",\
		\"weight\": 184,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Age.system\",\
		\"weight\": 185,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Age.code\",\
		\"weight\": 186,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeableConcept\",\
		\"weight\": 187,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.id\",\
		\"weight\": 188,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeableConcept.extension\",\
		\"weight\": 189,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.coding\",\
		\"weight\": 190,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.text\",\
		\"weight\": 191,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension\",\
		\"weight\": 192,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Extension.id\",\
		\"weight\": 193,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.extension\",\
		\"weight\": 194,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Extension.url\",\
		\"weight\": 195,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueBase64Binary\",\
		\"weight\": 196,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueBoolean\",\
		\"weight\": 196,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueCode\",\
		\"weight\": 196,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueDate\",\
		\"weight\": 196,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueDateTime\",\
		\"weight\": 196,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueDecimal\",\
		\"weight\": 196,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueId\",\
		\"weight\": 196,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueInstant\",\
		\"weight\": 196,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueInteger\",\
		\"weight\": 196,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueMarkdown\",\
		\"weight\": 196,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueOid\",\
		\"weight\": 196,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valuePositiveInt\",\
		\"weight\": 196,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueString\",\
		\"weight\": 196,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueTime\",\
		\"weight\": 196,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueUnsignedInt\",\
		\"weight\": 196,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueUri\",\
		\"weight\": 196,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueAddress\",\
		\"weight\": 196,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueAge\",\
		\"weight\": 196,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueAnnotation\",\
		\"weight\": 196,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueAttachment\",\
		\"weight\": 196,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueCodeableConcept\",\
		\"weight\": 196,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueCoding\",\
		\"weight\": 196,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueContactPoint\",\
		\"weight\": 196,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueCount\",\
		\"weight\": 196,\
		\"type\": \"Count\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueDistance\",\
		\"weight\": 196,\
		\"type\": \"Distance\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueDuration\",\
		\"weight\": 196,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueHumanName\",\
		\"weight\": 196,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueIdentifier\",\
		\"weight\": 196,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueMoney\",\
		\"weight\": 196,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valuePeriod\",\
		\"weight\": 196,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueQuantity\",\
		\"weight\": 196,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueRange\",\
		\"weight\": 196,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueRatio\",\
		\"weight\": 196,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueReference\",\
		\"weight\": 196,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueSampledData\",\
		\"weight\": 196,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueSignature\",\
		\"weight\": 196,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueTiming\",\
		\"weight\": 196,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueMeta\",\
		\"weight\": 196,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BackboneElement\",\
		\"weight\": 197,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BackboneElement.id\",\
		\"weight\": 198,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BackboneElement.extension\",\
		\"weight\": 199,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BackboneElement.modifierExtension\",\
		\"weight\": 200,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative\",\
		\"weight\": 201,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative.id\",\
		\"weight\": 202,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Narrative.extension\",\
		\"weight\": 203,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative.status\",\
		\"weight\": 204,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Narrative.div\",\
		\"weight\": 205,\
		\"type\": \"xhtml\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Element\",\
		\"weight\": 206,\
		\"derivations\": [\
			\"Address\",\
			\"Annotation\",\
			\"Attachment\",\
			\"BackboneElement\",\
			\"CodeableConcept\",\
			\"Coding\",\
			\"ContactDetail\",\
			\"ContactPoint\",\
			\"Contributor\",\
			\"DataRequirement\",\
			\"ElementDefinition\",\
			\"Extension\",\
			\"HumanName\",\
			\"Identifier\",\
			\"Meta\",\
			\"Narrative\",\
			\"ParameterDefinition\",\
			\"Period\",\
			\"Quantity\",\
			\"Range\",\
			\"Ratio\",\
			\"Reference\",\
			\"RelatedResource\",\
			\"SampledData\",\
			\"Signature\",\
			\"Timing\",\
			\"TriggerDefinition\",\
			\"UsageContext\",\
			\"base64Binary\",\
			\"boolean\",\
			\"date\",\
			\"dateTime\",\
			\"decimal\",\
			\"instant\",\
			\"integer\",\
			\"string\",\
			\"time\",\
			\"uri\",\
			\"xhtml\"\
		],\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Element.id\",\
		\"weight\": 207,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Element.extension\",\
		\"weight\": 208,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta\",\
		\"weight\": 209,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.id\",\
		\"weight\": 210,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.extension\",\
		\"weight\": 211,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.versionId\",\
		\"weight\": 212,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.lastUpdated\",\
		\"weight\": 213,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.profile\",\
		\"weight\": 214,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.security\",\
		\"weight\": 215,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.tag\",\
		\"weight\": 216,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedResource\",\
		\"weight\": 217,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedResource.id\",\
		\"weight\": 218,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedResource.extension\",\
		\"weight\": 219,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedResource.type\",\
		\"weight\": 220,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedResource.display\",\
		\"weight\": 221,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedResource.citation\",\
		\"weight\": 222,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedResource.url\",\
		\"weight\": 223,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedResource.document\",\
		\"weight\": 224,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedResource.resource\",\
		\"weight\": 225,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address\",\
		\"weight\": 226,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.id\",\
		\"weight\": 227,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.extension\",\
		\"weight\": 228,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.use\",\
		\"weight\": 229,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.type\",\
		\"weight\": 230,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.text\",\
		\"weight\": 231,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.line\",\
		\"weight\": 232,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.city\",\
		\"weight\": 233,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.district\",\
		\"weight\": 234,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.state\",\
		\"weight\": 235,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.postalCode\",\
		\"weight\": 236,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.country\",\
		\"weight\": 237,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.period\",\
		\"weight\": 238,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition\",\
		\"weight\": 239,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TriggerDefinition.id\",\
		\"weight\": 240,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.extension\",\
		\"weight\": 241,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TriggerDefinition.type\",\
		\"weight\": 242,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventName\",\
		\"weight\": 243,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingTiming\",\
		\"weight\": 244,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingReference\",\
		\"weight\": 244,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingDate\",\
		\"weight\": 244,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingDateTime\",\
		\"weight\": 244,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventData\",\
		\"weight\": 245,\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contributor\",\
		\"weight\": 246,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contributor.id\",\
		\"weight\": 247,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contributor.extension\",\
		\"weight\": 248,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contributor.type\",\
		\"weight\": 249,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contributor.name\",\
		\"weight\": 250,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contributor.contact\",\
		\"weight\": 251,\
		\"type\": \"ContactDetail\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement\",\
		\"weight\": 252,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.id\",\
		\"weight\": 253,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.extension\",\
		\"weight\": 254,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.type\",\
		\"weight\": 255,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.profile\",\
		\"weight\": 256,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.mustSupport\",\
		\"weight\": 257,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter\",\
		\"weight\": 258,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.id\",\
		\"weight\": 259,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.extension\",\
		\"weight\": 260,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.path\",\
		\"weight\": 261,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueSetString\",\
		\"weight\": 262,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueSetReference\",\
		\"weight\": 262,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCode\",\
		\"weight\": 263,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCoding\",\
		\"weight\": 264,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCodeableConcept\",\
		\"weight\": 265,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter\",\
		\"weight\": 266,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.id\",\
		\"weight\": 267,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.extension\",\
		\"weight\": 268,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.path\",\
		\"weight\": 269,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.valueDateTime\",\
		\"weight\": 270,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.valuePeriod\",\
		\"weight\": 270,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.valueDuration\",\
		\"weight\": 270,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactDetail\",\
		\"weight\": 271,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ContactDetail.id\",\
		\"weight\": 272,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactDetail.extension\",\
		\"weight\": 273,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ContactDetail.name\",\
		\"weight\": 274,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactDetail.telecom\",\
		\"weight\": 275,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName\",\
		\"weight\": 276,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.id\",\
		\"weight\": 277,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.extension\",\
		\"weight\": 278,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.use\",\
		\"weight\": 279,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.text\",\
		\"weight\": 280,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.family\",\
		\"weight\": 281,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.given\",\
		\"weight\": 282,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.prefix\",\
		\"weight\": 283,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.suffix\",\
		\"weight\": 284,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.period\",\
		\"weight\": 285,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint\",\
		\"weight\": 286,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ContactPoint.id\",\
		\"weight\": 287,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.extension\",\
		\"weight\": 288,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ContactPoint.system\",\
		\"weight\": 289,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.value\",\
		\"weight\": 290,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.use\",\
		\"weight\": 291,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.rank\",\
		\"weight\": 292,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.period\",\
		\"weight\": 293,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"UsageContext\",\
		\"weight\": 294,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.id\",\
		\"weight\": 295,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"UsageContext.extension\",\
		\"weight\": 296,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.patientGender\",\
		\"weight\": 297,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.patientAgeGroup\",\
		\"weight\": 298,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.clinicalFocus\",\
		\"weight\": 299,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.targetUser\",\
		\"weight\": 300,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.workflowSetting\",\
		\"weight\": 301,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.workflowTask\",\
		\"weight\": 302,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.clinicalVenue\",\
		\"weight\": 303,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"UsageContext.jurisdiction\",\
		\"weight\": 304,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing\",\
		\"weight\": 305,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.id\",\
		\"weight\": 306,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.extension\",\
		\"weight\": 307,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.event\",\
		\"weight\": 308,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.repeat\",\
		\"weight\": 309,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.id\",\
		\"weight\": 310,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.extension\",\
		\"weight\": 311,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsDuration\",\
		\"weight\": 312,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsRange\",\
		\"weight\": 312,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsPeriod\",\
		\"weight\": 312,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.count\",\
		\"weight\": 313,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.countMax\",\
		\"weight\": 314,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.duration\",\
		\"weight\": 315,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.durationMax\",\
		\"weight\": 316,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.durationUnit\",\
		\"weight\": 317,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.frequency\",\
		\"weight\": 318,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.frequencyMax\",\
		\"weight\": 319,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.period\",\
		\"weight\": 320,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.periodMax\",\
		\"weight\": 321,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.periodUnit\",\
		\"weight\": 322,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.when\",\
		\"weight\": 323,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.offset\",\
		\"weight\": 324,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.code\",\
		\"weight\": 325,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition\",\
		\"weight\": 326,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.id\",\
		\"weight\": 327,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.extension\",\
		\"weight\": 328,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.path\",\
		\"weight\": 329,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.representation\",\
		\"weight\": 330,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.name\",\
		\"weight\": 331,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.label\",\
		\"weight\": 332,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.code\",\
		\"weight\": 333,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing\",\
		\"weight\": 334,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.id\",\
		\"weight\": 335,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.extension\",\
		\"weight\": 336,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.discriminator\",\
		\"weight\": 337,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.description\",\
		\"weight\": 338,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.ordered\",\
		\"weight\": 339,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.rules\",\
		\"weight\": 340,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.short\",\
		\"weight\": 341,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.definition\",\
		\"weight\": 342,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.comments\",\
		\"weight\": 343,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.requirements\",\
		\"weight\": 344,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.alias\",\
		\"weight\": 345,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.min\",\
		\"weight\": 346,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.max\",\
		\"weight\": 347,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base\",\
		\"weight\": 348,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.id\",\
		\"weight\": 349,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.extension\",\
		\"weight\": 350,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.path\",\
		\"weight\": 351,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.min\",\
		\"weight\": 352,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.max\",\
		\"weight\": 353,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.contentReference\",\
		\"weight\": 354,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type\",\
		\"weight\": 355,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.id\",\
		\"weight\": 356,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.extension\",\
		\"weight\": 357,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.code\",\
		\"weight\": 358,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.profile\",\
		\"weight\": 359,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.targetProfile\",\
		\"weight\": 360,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.aggregation\",\
		\"weight\": 361,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.versioning\",\
		\"weight\": 362,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueBase64Binary\",\
		\"weight\": 363,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueBoolean\",\
		\"weight\": 363,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCode\",\
		\"weight\": 363,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDate\",\
		\"weight\": 363,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDateTime\",\
		\"weight\": 363,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDecimal\",\
		\"weight\": 363,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueId\",\
		\"weight\": 363,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueInstant\",\
		\"weight\": 363,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueInteger\",\
		\"weight\": 363,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueMarkdown\",\
		\"weight\": 363,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueOid\",\
		\"weight\": 363,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValuePositiveInt\",\
		\"weight\": 363,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueString\",\
		\"weight\": 363,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueTime\",\
		\"weight\": 363,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueUnsignedInt\",\
		\"weight\": 363,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueUri\",\
		\"weight\": 363,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAddress\",\
		\"weight\": 363,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAge\",\
		\"weight\": 363,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAnnotation\",\
		\"weight\": 363,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAttachment\",\
		\"weight\": 363,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCodeableConcept\",\
		\"weight\": 363,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCoding\",\
		\"weight\": 363,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueContactPoint\",\
		\"weight\": 363,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCount\",\
		\"weight\": 363,\
		\"type\": \"Count\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDistance\",\
		\"weight\": 363,\
		\"type\": \"Distance\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDuration\",\
		\"weight\": 363,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueHumanName\",\
		\"weight\": 363,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueIdentifier\",\
		\"weight\": 363,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueMoney\",\
		\"weight\": 363,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValuePeriod\",\
		\"weight\": 363,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueQuantity\",\
		\"weight\": 363,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueRange\",\
		\"weight\": 363,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueRatio\",\
		\"weight\": 363,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueReference\",\
		\"weight\": 363,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueSampledData\",\
		\"weight\": 363,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueSignature\",\
		\"weight\": 363,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueTiming\",\
		\"weight\": 363,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueMeta\",\
		\"weight\": 363,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.meaningWhenMissing\",\
		\"weight\": 364,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedBase64Binary\",\
		\"weight\": 365,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedBoolean\",\
		\"weight\": 365,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCode\",\
		\"weight\": 365,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDate\",\
		\"weight\": 365,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDateTime\",\
		\"weight\": 365,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDecimal\",\
		\"weight\": 365,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedId\",\
		\"weight\": 365,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedInstant\",\
		\"weight\": 365,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedInteger\",\
		\"weight\": 365,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedMarkdown\",\
		\"weight\": 365,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedOid\",\
		\"weight\": 365,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedPositiveInt\",\
		\"weight\": 365,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedString\",\
		\"weight\": 365,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedTime\",\
		\"weight\": 365,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedUnsignedInt\",\
		\"weight\": 365,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedUri\",\
		\"weight\": 365,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAddress\",\
		\"weight\": 365,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAge\",\
		\"weight\": 365,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAnnotation\",\
		\"weight\": 365,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAttachment\",\
		\"weight\": 365,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCodeableConcept\",\
		\"weight\": 365,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCoding\",\
		\"weight\": 365,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedContactPoint\",\
		\"weight\": 365,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCount\",\
		\"weight\": 365,\
		\"type\": \"Count\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDistance\",\
		\"weight\": 365,\
		\"type\": \"Distance\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDuration\",\
		\"weight\": 365,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedHumanName\",\
		\"weight\": 365,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedIdentifier\",\
		\"weight\": 365,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedMoney\",\
		\"weight\": 365,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedPeriod\",\
		\"weight\": 365,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedQuantity\",\
		\"weight\": 365,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedRange\",\
		\"weight\": 365,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedRatio\",\
		\"weight\": 365,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedReference\",\
		\"weight\": 365,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedSampledData\",\
		\"weight\": 365,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedSignature\",\
		\"weight\": 365,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedTiming\",\
		\"weight\": 365,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedMeta\",\
		\"weight\": 365,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternBase64Binary\",\
		\"weight\": 366,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternBoolean\",\
		\"weight\": 366,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCode\",\
		\"weight\": 366,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDate\",\
		\"weight\": 366,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDateTime\",\
		\"weight\": 366,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDecimal\",\
		\"weight\": 366,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternId\",\
		\"weight\": 366,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternInstant\",\
		\"weight\": 366,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternInteger\",\
		\"weight\": 366,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternMarkdown\",\
		\"weight\": 366,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternOid\",\
		\"weight\": 366,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternPositiveInt\",\
		\"weight\": 366,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternString\",\
		\"weight\": 366,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternTime\",\
		\"weight\": 366,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternUnsignedInt\",\
		\"weight\": 366,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternUri\",\
		\"weight\": 366,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAddress\",\
		\"weight\": 366,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAge\",\
		\"weight\": 366,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAnnotation\",\
		\"weight\": 366,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAttachment\",\
		\"weight\": 366,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCodeableConcept\",\
		\"weight\": 366,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCoding\",\
		\"weight\": 366,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternContactPoint\",\
		\"weight\": 366,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCount\",\
		\"weight\": 366,\
		\"type\": \"Count\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDistance\",\
		\"weight\": 366,\
		\"type\": \"Distance\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDuration\",\
		\"weight\": 366,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternHumanName\",\
		\"weight\": 366,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternIdentifier\",\
		\"weight\": 366,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternMoney\",\
		\"weight\": 366,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternPeriod\",\
		\"weight\": 366,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternQuantity\",\
		\"weight\": 366,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternRange\",\
		\"weight\": 366,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternRatio\",\
		\"weight\": 366,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternReference\",\
		\"weight\": 366,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternSampledData\",\
		\"weight\": 366,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternSignature\",\
		\"weight\": 366,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternTiming\",\
		\"weight\": 366,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternMeta\",\
		\"weight\": 366,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleBase64Binary\",\
		\"weight\": 367,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleBoolean\",\
		\"weight\": 367,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCode\",\
		\"weight\": 367,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDate\",\
		\"weight\": 367,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDateTime\",\
		\"weight\": 367,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDecimal\",\
		\"weight\": 367,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleId\",\
		\"weight\": 367,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleInstant\",\
		\"weight\": 367,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleInteger\",\
		\"weight\": 367,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleMarkdown\",\
		\"weight\": 367,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleOid\",\
		\"weight\": 367,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.examplePositiveInt\",\
		\"weight\": 367,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleString\",\
		\"weight\": 367,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleTime\",\
		\"weight\": 367,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleUnsignedInt\",\
		\"weight\": 367,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleUri\",\
		\"weight\": 367,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAddress\",\
		\"weight\": 367,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAge\",\
		\"weight\": 367,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAnnotation\",\
		\"weight\": 367,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAttachment\",\
		\"weight\": 367,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCodeableConcept\",\
		\"weight\": 367,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCoding\",\
		\"weight\": 367,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleContactPoint\",\
		\"weight\": 367,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCount\",\
		\"weight\": 367,\
		\"type\": \"Count\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDistance\",\
		\"weight\": 367,\
		\"type\": \"Distance\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDuration\",\
		\"weight\": 367,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleHumanName\",\
		\"weight\": 367,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleIdentifier\",\
		\"weight\": 367,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleMoney\",\
		\"weight\": 367,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.examplePeriod\",\
		\"weight\": 367,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleQuantity\",\
		\"weight\": 367,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleRange\",\
		\"weight\": 367,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleRatio\",\
		\"weight\": 367,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleReference\",\
		\"weight\": 367,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleSampledData\",\
		\"weight\": 367,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleSignature\",\
		\"weight\": 367,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleTiming\",\
		\"weight\": 367,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleMeta\",\
		\"weight\": 367,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDate\",\
		\"weight\": 368,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDateTime\",\
		\"weight\": 368,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueInstant\",\
		\"weight\": 368,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueTime\",\
		\"weight\": 368,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDecimal\",\
		\"weight\": 368,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueInteger\",\
		\"weight\": 368,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValuePositiveInt\",\
		\"weight\": 368,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueUnsignedInt\",\
		\"weight\": 368,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueQuantity\",\
		\"weight\": 368,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDate\",\
		\"weight\": 369,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDateTime\",\
		\"weight\": 369,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueInstant\",\
		\"weight\": 369,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueTime\",\
		\"weight\": 369,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDecimal\",\
		\"weight\": 369,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueInteger\",\
		\"weight\": 369,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValuePositiveInt\",\
		\"weight\": 369,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueUnsignedInt\",\
		\"weight\": 369,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueQuantity\",\
		\"weight\": 369,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxLength\",\
		\"weight\": 370,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.condition\",\
		\"weight\": 371,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint\",\
		\"weight\": 372,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.id\",\
		\"weight\": 373,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.extension\",\
		\"weight\": 374,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.key\",\
		\"weight\": 375,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.requirements\",\
		\"weight\": 376,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.severity\",\
		\"weight\": 377,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.human\",\
		\"weight\": 378,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.expression\",\
		\"weight\": 379,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.xpath\",\
		\"weight\": 380,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mustSupport\",\
		\"weight\": 381,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.isModifier\",\
		\"weight\": 382,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.isSummary\",\
		\"weight\": 383,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding\",\
		\"weight\": 384,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.id\",\
		\"weight\": 385,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.extension\",\
		\"weight\": 386,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.strength\",\
		\"weight\": 387,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.description\",\
		\"weight\": 388,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.valueSetUri\",\
		\"weight\": 389,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.valueSetReference\",\
		\"weight\": 389,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping\",\
		\"weight\": 390,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.id\",\
		\"weight\": 391,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.extension\",\
		\"weight\": 392,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.identity\",\
		\"weight\": 393,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.language\",\
		\"weight\": 394,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.map\",\
		\"weight\": 395,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition\",\
		\"weight\": 396,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ParameterDefinition.id\",\
		\"weight\": 397,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.extension\",\
		\"weight\": 398,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ParameterDefinition.name\",\
		\"weight\": 399,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.use\",\
		\"weight\": 400,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.min\",\
		\"weight\": 401,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.max\",\
		\"weight\": 402,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.documentation\",\
		\"weight\": 403,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.type\",\
		\"weight\": 404,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.profile\",\
		\"weight\": 405,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem\",\
		\"weight\": 406,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.id\",\
		\"weight\": 407,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.meta\",\
		\"weight\": 408,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.implicitRules\",\
		\"weight\": 409,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.language\",\
		\"weight\": 410,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.text\",\
		\"weight\": 411,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contained\",\
		\"weight\": 412,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.extension\",\
		\"weight\": 413,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.modifierExtension\",\
		\"weight\": 414,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.url\",\
		\"weight\": 415,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.identifier\",\
		\"weight\": 416,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.version\",\
		\"weight\": 417,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.name\",\
		\"weight\": 418,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.status\",\
		\"weight\": 419,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.experimental\",\
		\"weight\": 420,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.publisher\",\
		\"weight\": 421,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact\",\
		\"weight\": 422,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.id\",\
		\"weight\": 423,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.extension\",\
		\"weight\": 424,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.modifierExtension\",\
		\"weight\": 425,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.name\",\
		\"weight\": 426,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.telecom\",\
		\"weight\": 427,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.date\",\
		\"weight\": 428,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.description\",\
		\"weight\": 429,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.useContext\",\
		\"weight\": 430,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.requirements\",\
		\"weight\": 431,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.copyright\",\
		\"weight\": 432,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.caseSensitive\",\
		\"weight\": 433,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.valueSet\",\
		\"weight\": 434,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.hierarchyMeaning\",\
		\"weight\": 435,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.compositional\",\
		\"weight\": 436,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.versionNeeded\",\
		\"weight\": 437,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.content\",\
		\"weight\": 438,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.count\",\
		\"weight\": 439,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter\",\
		\"weight\": 440,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.id\",\
		\"weight\": 441,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.extension\",\
		\"weight\": 442,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.modifierExtension\",\
		\"weight\": 443,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.code\",\
		\"weight\": 444,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.description\",\
		\"weight\": 445,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.operator\",\
		\"weight\": 446,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.value\",\
		\"weight\": 447,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property\",\
		\"weight\": 448,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.id\",\
		\"weight\": 449,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.extension\",\
		\"weight\": 450,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.modifierExtension\",\
		\"weight\": 451,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.code\",\
		\"weight\": 452,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.uri\",\
		\"weight\": 453,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.description\",\
		\"weight\": 454,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.type\",\
		\"weight\": 455,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept\",\
		\"weight\": 456,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.id\",\
		\"weight\": 457,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.extension\",\
		\"weight\": 458,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.modifierExtension\",\
		\"weight\": 459,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.code\",\
		\"weight\": 460,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.display\",\
		\"weight\": 461,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.definition\",\
		\"weight\": 462,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation\",\
		\"weight\": 463,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.id\",\
		\"weight\": 464,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.extension\",\
		\"weight\": 465,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.modifierExtension\",\
		\"weight\": 466,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.language\",\
		\"weight\": 467,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.use\",\
		\"weight\": 468,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.value\",\
		\"weight\": 469,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property\",\
		\"weight\": 470,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.id\",\
		\"weight\": 471,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.extension\",\
		\"weight\": 472,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.modifierExtension\",\
		\"weight\": 473,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.code\",\
		\"weight\": 474,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueCode\",\
		\"weight\": 475,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueCoding\",\
		\"weight\": 475,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueString\",\
		\"weight\": 475,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueInteger\",\
		\"weight\": 475,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueBoolean\",\
		\"weight\": 475,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueDateTime\",\
		\"weight\": 475,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.concept\",\
		\"weight\": 476,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet\",\
		\"weight\": 477,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.id\",\
		\"weight\": 478,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.meta\",\
		\"weight\": 479,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.implicitRules\",\
		\"weight\": 480,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.language\",\
		\"weight\": 481,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.text\",\
		\"weight\": 482,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contained\",\
		\"weight\": 483,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.extension\",\
		\"weight\": 484,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.modifierExtension\",\
		\"weight\": 485,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.url\",\
		\"weight\": 486,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.identifier\",\
		\"weight\": 487,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.version\",\
		\"weight\": 488,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.name\",\
		\"weight\": 489,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.status\",\
		\"weight\": 490,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.experimental\",\
		\"weight\": 491,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.publisher\",\
		\"weight\": 492,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact\",\
		\"weight\": 493,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.id\",\
		\"weight\": 494,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact.extension\",\
		\"weight\": 495,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.modifierExtension\",\
		\"weight\": 496,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.name\",\
		\"weight\": 497,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact.telecom\",\
		\"weight\": 498,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.date\",\
		\"weight\": 499,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.lockedDate\",\
		\"weight\": 500,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.description\",\
		\"weight\": 501,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.useContext\",\
		\"weight\": 502,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.immutable\",\
		\"weight\": 503,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.requirements\",\
		\"weight\": 504,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.copyright\",\
		\"weight\": 505,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.extensible\",\
		\"weight\": 506,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose\",\
		\"weight\": 507,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.id\",\
		\"weight\": 508,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.extension\",\
		\"weight\": 509,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.modifierExtension\",\
		\"weight\": 510,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.import\",\
		\"weight\": 511,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include\",\
		\"weight\": 512,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.id\",\
		\"weight\": 513,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.extension\",\
		\"weight\": 514,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.modifierExtension\",\
		\"weight\": 515,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.system\",\
		\"weight\": 516,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.version\",\
		\"weight\": 517,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept\",\
		\"weight\": 518,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.id\",\
		\"weight\": 519,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.extension\",\
		\"weight\": 520,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.modifierExtension\",\
		\"weight\": 521,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.code\",\
		\"weight\": 522,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.display\",\
		\"weight\": 523,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation\",\
		\"weight\": 524,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.id\",\
		\"weight\": 525,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.extension\",\
		\"weight\": 526,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.modifierExtension\",\
		\"weight\": 527,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.language\",\
		\"weight\": 528,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.use\",\
		\"weight\": 529,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.value\",\
		\"weight\": 530,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter\",\
		\"weight\": 531,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.id\",\
		\"weight\": 532,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.extension\",\
		\"weight\": 533,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.modifierExtension\",\
		\"weight\": 534,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.property\",\
		\"weight\": 535,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.op\",\
		\"weight\": 536,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.value\",\
		\"weight\": 537,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.exclude\",\
		\"weight\": 538,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion\",\
		\"weight\": 539,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.id\",\
		\"weight\": 540,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.extension\",\
		\"weight\": 541,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.modifierExtension\",\
		\"weight\": 542,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.identifier\",\
		\"weight\": 543,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.timestamp\",\
		\"weight\": 544,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.total\",\
		\"weight\": 545,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.offset\",\
		\"weight\": 546,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter\",\
		\"weight\": 547,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.id\",\
		\"weight\": 548,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.extension\",\
		\"weight\": 549,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.modifierExtension\",\
		\"weight\": 550,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.name\",\
		\"weight\": 551,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueString\",\
		\"weight\": 552,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueBoolean\",\
		\"weight\": 552,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueInteger\",\
		\"weight\": 552,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueDecimal\",\
		\"weight\": 552,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueUri\",\
		\"weight\": 552,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueCode\",\
		\"weight\": 552,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains\",\
		\"weight\": 553,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.id\",\
		\"weight\": 554,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.extension\",\
		\"weight\": 555,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.modifierExtension\",\
		\"weight\": 556,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.system\",\
		\"weight\": 557,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.abstract\",\
		\"weight\": 558,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.version\",\
		\"weight\": 559,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.code\",\
		\"weight\": 560,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.display\",\
		\"weight\": 561,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.contains\",\
		\"weight\": 562,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource\",\
		\"weight\": 563,\
		\"derivations\": [\
			\"Account\",\
			\"ActivityDefinition\",\
			\"AllergyIntolerance\",\
			\"Appointment\",\
			\"AppointmentResponse\",\
			\"AuditEvent\",\
			\"Basic\",\
			\"BodySite\",\
			\"CarePlan\",\
			\"CareTeam\",\
			\"Claim\",\
			\"ClaimResponse\",\
			\"ClinicalImpression\",\
			\"CodeSystem\",\
			\"Communication\",\
			\"CommunicationRequest\",\
			\"CompartmentDefinition\",\
			\"Composition\",\
			\"ConceptMap\",\
			\"Condition\",\
			\"Conformance\",\
			\"Consent\",\
			\"Contract\",\
			\"Coverage\",\
			\"DataElement\",\
			\"DecisionSupportServiceModule\",\
			\"DetectedIssue\",\
			\"Device\",\
			\"DeviceComponent\",\
			\"DeviceMetric\",\
			\"DeviceUseRequest\",\
			\"DeviceUseStatement\",\
			\"DiagnosticReport\",\
			\"DiagnosticRequest\",\
			\"DocumentManifest\",\
			\"DocumentReference\",\
			\"EligibilityRequest\",\
			\"EligibilityResponse\",\
			\"Encounter\",\
			\"Endpoint\",\
			\"EnrollmentRequest\",\
			\"EnrollmentResponse\",\
			\"EpisodeOfCare\",\
			\"ExpansionProfile\",\
			\"ExplanationOfBenefit\",\
			\"FamilyMemberHistory\",\
			\"Flag\",\
			\"Goal\",\
			\"Group\",\
			\"GuidanceResponse\",\
			\"HealthcareService\",\
			\"ImagingManifest\",\
			\"ImagingStudy\",\
			\"Immunization\",\
			\"ImmunizationRecommendation\",\
			\"ImplementationGuide\",\
			\"Library\",\
			\"Linkage\",\
			\"List\",\
			\"Location\",\
			\"Measure\",\
			\"MeasureReport\",\
			\"Media\",\
			\"Medication\",\
			\"MedicationAdministration\",\
			\"MedicationDispense\",\
			\"MedicationOrder\",\
			\"MedicationStatement\",\
			\"MessageHeader\",\
			\"NamingSystem\",\
			\"NutritionRequest\",\
			\"Observation\",\
			\"OperationDefinition\",\
			\"OperationOutcome\",\
			\"Organization\",\
			\"Patient\",\
			\"PaymentNotice\",\
			\"PaymentReconciliation\",\
			\"Person\",\
			\"PlanDefinition\",\
			\"Practitioner\",\
			\"PractitionerRole\",\
			\"Procedure\",\
			\"ProcedureRequest\",\
			\"ProcessRequest\",\
			\"ProcessResponse\",\
			\"Provenance\",\
			\"Questionnaire\",\
			\"QuestionnaireResponse\",\
			\"ReferralRequest\",\
			\"RelatedPerson\",\
			\"RiskAssessment\",\
			\"Schedule\",\
			\"SearchParameter\",\
			\"Sequence\",\
			\"Slot\",\
			\"Specimen\",\
			\"StructureDefinition\",\
			\"StructureMap\",\
			\"Subscription\",\
			\"Substance\",\
			\"SupplyDelivery\",\
			\"SupplyRequest\",\
			\"Task\",\
			\"TestScript\",\
			\"ValueSet\",\
			\"VisionPrescription\"\
		],\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource.id\",\
		\"weight\": 564,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.meta\",\
		\"weight\": 565,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.implicitRules\",\
		\"weight\": 566,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.language\",\
		\"weight\": 567,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.text\",\
		\"weight\": 568,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.contained\",\
		\"weight\": 569,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource.extension\",\
		\"weight\": 570,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource.modifierExtension\",\
		\"weight\": 571,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters\",\
		\"weight\": 572,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.id\",\
		\"weight\": 573,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.meta\",\
		\"weight\": 574,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.implicitRules\",\
		\"weight\": 575,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.language\",\
		\"weight\": 576,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter\",\
		\"weight\": 577,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.id\",\
		\"weight\": 578,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.extension\",\
		\"weight\": 579,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.modifierExtension\",\
		\"weight\": 580,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.name\",\
		\"weight\": 581,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueBase64Binary\",\
		\"weight\": 582,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueBoolean\",\
		\"weight\": 582,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCode\",\
		\"weight\": 582,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDate\",\
		\"weight\": 582,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDateTime\",\
		\"weight\": 582,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDecimal\",\
		\"weight\": 582,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueId\",\
		\"weight\": 582,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueInstant\",\
		\"weight\": 582,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueInteger\",\
		\"weight\": 582,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueMarkdown\",\
		\"weight\": 582,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueOid\",\
		\"weight\": 582,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valuePositiveInt\",\
		\"weight\": 582,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueString\",\
		\"weight\": 582,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueTime\",\
		\"weight\": 582,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueUnsignedInt\",\
		\"weight\": 582,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueUri\",\
		\"weight\": 582,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAddress\",\
		\"weight\": 582,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAge\",\
		\"weight\": 582,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAnnotation\",\
		\"weight\": 582,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAttachment\",\
		\"weight\": 582,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCodeableConcept\",\
		\"weight\": 582,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCoding\",\
		\"weight\": 582,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueContactPoint\",\
		\"weight\": 582,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCount\",\
		\"weight\": 582,\
		\"type\": \"Count\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDistance\",\
		\"weight\": 582,\
		\"type\": \"Distance\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDuration\",\
		\"weight\": 582,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueHumanName\",\
		\"weight\": 582,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueIdentifier\",\
		\"weight\": 582,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueMoney\",\
		\"weight\": 582,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valuePeriod\",\
		\"weight\": 582,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueQuantity\",\
		\"weight\": 582,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueRange\",\
		\"weight\": 582,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueRatio\",\
		\"weight\": 582,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueReference\",\
		\"weight\": 582,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueSampledData\",\
		\"weight\": 582,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueSignature\",\
		\"weight\": 582,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueTiming\",\
		\"weight\": 582,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueMeta\",\
		\"weight\": 582,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.resource\",\
		\"weight\": 583,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.part\",\
		\"weight\": 584,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Resource\",\
		\"weight\": 585,\
		\"derivations\": [\
			\"Binary\",\
			\"Bundle\",\
			\"DomainResource\",\
			\"Parameters\"\
		],\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Resource.id\",\
		\"weight\": 586,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.meta\",\
		\"weight\": 587,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.implicitRules\",\
		\"weight\": 588,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.language\",\
		\"weight\": 589,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account\",\
		\"weight\": 590,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.id\",\
		\"weight\": 591,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.meta\",\
		\"weight\": 592,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.implicitRules\",\
		\"weight\": 593,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.language\",\
		\"weight\": 594,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.text\",\
		\"weight\": 595,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.contained\",\
		\"weight\": 596,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.extension\",\
		\"weight\": 597,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.modifierExtension\",\
		\"weight\": 598,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.identifier\",\
		\"weight\": 599,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.name\",\
		\"weight\": 600,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.type\",\
		\"weight\": 601,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.status\",\
		\"weight\": 602,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.active\",\
		\"weight\": 603,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.currency\",\
		\"weight\": 604,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.balance\",\
		\"weight\": 605,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.coverage\",\
		\"weight\": 606,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.coveragePeriod\",\
		\"weight\": 607,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.subject\",\
		\"weight\": 608,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.owner\",\
		\"weight\": 609,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.description\",\
		\"weight\": 610,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition\",\
		\"weight\": 611,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.id\",\
		\"weight\": 612,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.meta\",\
		\"weight\": 613,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.implicitRules\",\
		\"weight\": 614,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.language\",\
		\"weight\": 615,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.text\",\
		\"weight\": 616,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.contained\",\
		\"weight\": 617,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.extension\",\
		\"weight\": 618,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.modifierExtension\",\
		\"weight\": 619,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.url\",\
		\"weight\": 620,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.identifier\",\
		\"weight\": 621,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.version\",\
		\"weight\": 622,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.name\",\
		\"weight\": 623,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.title\",\
		\"weight\": 624,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.status\",\
		\"weight\": 625,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.experimental\",\
		\"weight\": 626,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.description\",\
		\"weight\": 627,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.purpose\",\
		\"weight\": 628,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.usage\",\
		\"weight\": 629,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.publicationDate\",\
		\"weight\": 630,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.lastReviewDate\",\
		\"weight\": 631,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.effectivePeriod\",\
		\"weight\": 632,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.coverage\",\
		\"weight\": 633,\
		\"type\": \"UsageContext\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.topic\",\
		\"weight\": 634,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.contributor\",\
		\"weight\": 635,\
		\"type\": \"Contributor\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.publisher\",\
		\"weight\": 636,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.contact\",\
		\"weight\": 637,\
		\"type\": \"ContactDetail\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.copyright\",\
		\"weight\": 638,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.relatedResource\",\
		\"weight\": 639,\
		\"type\": \"RelatedResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.library\",\
		\"weight\": 640,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.category\",\
		\"weight\": 641,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.code\",\
		\"weight\": 642,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.timingCodeableConcept\",\
		\"weight\": 643,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.timingTiming\",\
		\"weight\": 643,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.location\",\
		\"weight\": 644,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.participantType\",\
		\"weight\": 645,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.productReference\",\
		\"weight\": 646,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.productReference\",\
		\"weight\": 646,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.productCodeableConcept\",\
		\"weight\": 646,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.quantity\",\
		\"weight\": 647,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.transform\",\
		\"weight\": 648,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.dynamicValue\",\
		\"weight\": 649,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.dynamicValue.id\",\
		\"weight\": 650,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.dynamicValue.extension\",\
		\"weight\": 651,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.dynamicValue.modifierExtension\",\
		\"weight\": 652,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActivityDefinition.dynamicValue.description\",\
		\"weight\": 653,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.dynamicValue.path\",\
		\"weight\": 654,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.dynamicValue.language\",\
		\"weight\": 655,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActivityDefinition.dynamicValue.expression\",\
		\"weight\": 656,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance\",\
		\"weight\": 657,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.id\",\
		\"weight\": 658,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.meta\",\
		\"weight\": 659,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.implicitRules\",\
		\"weight\": 660,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.language\",\
		\"weight\": 661,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.text\",\
		\"weight\": 662,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.contained\",\
		\"weight\": 663,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.extension\",\
		\"weight\": 664,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.modifierExtension\",\
		\"weight\": 665,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.identifier\",\
		\"weight\": 666,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.status\",\
		\"weight\": 667,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.type\",\
		\"weight\": 668,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.category\",\
		\"weight\": 669,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.criticality\",\
		\"weight\": 670,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.code\",\
		\"weight\": 671,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.patient\",\
		\"weight\": 672,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.attestedDate\",\
		\"weight\": 673,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.recorder\",\
		\"weight\": 674,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reporter\",\
		\"weight\": 675,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.onset\",\
		\"weight\": 676,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.lastOccurrence\",\
		\"weight\": 677,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.note\",\
		\"weight\": 678,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction\",\
		\"weight\": 679,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.id\",\
		\"weight\": 680,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.extension\",\
		\"weight\": 681,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.modifierExtension\",\
		\"weight\": 682,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.substance\",\
		\"weight\": 683,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.certainty\",\
		\"weight\": 684,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.manifestation\",\
		\"weight\": 685,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.description\",\
		\"weight\": 686,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.onset\",\
		\"weight\": 687,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.severity\",\
		\"weight\": 688,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.exposureRoute\",\
		\"weight\": 689,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.note\",\
		\"weight\": 690,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment\",\
		\"weight\": 691,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.id\",\
		\"weight\": 692,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.meta\",\
		\"weight\": 693,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.implicitRules\",\
		\"weight\": 694,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.language\",\
		\"weight\": 695,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.text\",\
		\"weight\": 696,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.contained\",\
		\"weight\": 697,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.extension\",\
		\"weight\": 698,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.modifierExtension\",\
		\"weight\": 699,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.identifier\",\
		\"weight\": 700,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.status\",\
		\"weight\": 701,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.serviceCategory\",\
		\"weight\": 702,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.serviceType\",\
		\"weight\": 703,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.specialty\",\
		\"weight\": 704,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.appointmentType\",\
		\"weight\": 705,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.reason\",\
		\"weight\": 706,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.priority\",\
		\"weight\": 707,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.description\",\
		\"weight\": 708,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.start\",\
		\"weight\": 709,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.end\",\
		\"weight\": 710,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.minutesDuration\",\
		\"weight\": 711,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.slot\",\
		\"weight\": 712,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.created\",\
		\"weight\": 713,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.comment\",\
		\"weight\": 714,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant\",\
		\"weight\": 715,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.id\",\
		\"weight\": 716,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.extension\",\
		\"weight\": 717,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.modifierExtension\",\
		\"weight\": 718,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.type\",\
		\"weight\": 719,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.actor\",\
		\"weight\": 720,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.required\",\
		\"weight\": 721,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.status\",\
		\"weight\": 722,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse\",\
		\"weight\": 723,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.id\",\
		\"weight\": 724,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.meta\",\
		\"weight\": 725,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.implicitRules\",\
		\"weight\": 726,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.language\",\
		\"weight\": 727,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.text\",\
		\"weight\": 728,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.contained\",\
		\"weight\": 729,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.extension\",\
		\"weight\": 730,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.modifierExtension\",\
		\"weight\": 731,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.identifier\",\
		\"weight\": 732,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.appointment\",\
		\"weight\": 733,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.start\",\
		\"weight\": 734,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.end\",\
		\"weight\": 735,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.participantType\",\
		\"weight\": 736,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.actor\",\
		\"weight\": 737,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.participantStatus\",\
		\"weight\": 738,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.comment\",\
		\"weight\": 739,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent\",\
		\"weight\": 740,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.id\",\
		\"weight\": 741,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.meta\",\
		\"weight\": 742,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.implicitRules\",\
		\"weight\": 743,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.language\",\
		\"weight\": 744,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.text\",\
		\"weight\": 745,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.contained\",\
		\"weight\": 746,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.extension\",\
		\"weight\": 747,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.modifierExtension\",\
		\"weight\": 748,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.type\",\
		\"weight\": 749,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.subtype\",\
		\"weight\": 750,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.action\",\
		\"weight\": 751,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.recorded\",\
		\"weight\": 752,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.outcome\",\
		\"weight\": 753,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.outcomeDesc\",\
		\"weight\": 754,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.purposeOfEvent\",\
		\"weight\": 755,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent\",\
		\"weight\": 756,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.id\",\
		\"weight\": 757,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.extension\",\
		\"weight\": 758,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.modifierExtension\",\
		\"weight\": 759,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.role\",\
		\"weight\": 760,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.reference\",\
		\"weight\": 761,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.userId\",\
		\"weight\": 762,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.altId\",\
		\"weight\": 763,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.name\",\
		\"weight\": 764,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.requestor\",\
		\"weight\": 765,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.location\",\
		\"weight\": 766,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.policy\",\
		\"weight\": 767,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.media\",\
		\"weight\": 768,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network\",\
		\"weight\": 769,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.id\",\
		\"weight\": 770,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.extension\",\
		\"weight\": 771,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.modifierExtension\",\
		\"weight\": 772,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.address\",\
		\"weight\": 773,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.type\",\
		\"weight\": 774,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.purposeOfUse\",\
		\"weight\": 775,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source\",\
		\"weight\": 776,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.id\",\
		\"weight\": 777,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.extension\",\
		\"weight\": 778,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source.modifierExtension\",\
		\"weight\": 779,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source.site\",\
		\"weight\": 780,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.identifier\",\
		\"weight\": 781,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.type\",\
		\"weight\": 782,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity\",\
		\"weight\": 783,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.id\",\
		\"weight\": 784,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.extension\",\
		\"weight\": 785,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.modifierExtension\",\
		\"weight\": 786,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.identifier\",\
		\"weight\": 787,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.reference\",\
		\"weight\": 788,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.type\",\
		\"weight\": 789,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.role\",\
		\"weight\": 790,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.lifecycle\",\
		\"weight\": 791,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.securityLabel\",\
		\"weight\": 792,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.name\",\
		\"weight\": 793,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.description\",\
		\"weight\": 794,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.query\",\
		\"weight\": 795,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail\",\
		\"weight\": 796,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.id\",\
		\"weight\": 797,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.extension\",\
		\"weight\": 798,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.modifierExtension\",\
		\"weight\": 799,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.type\",\
		\"weight\": 800,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.value\",\
		\"weight\": 801,\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic\",\
		\"weight\": 802,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.id\",\
		\"weight\": 803,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.meta\",\
		\"weight\": 804,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.implicitRules\",\
		\"weight\": 805,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.language\",\
		\"weight\": 806,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.text\",\
		\"weight\": 807,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.contained\",\
		\"weight\": 808,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.extension\",\
		\"weight\": 809,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.modifierExtension\",\
		\"weight\": 810,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.identifier\",\
		\"weight\": 811,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.code\",\
		\"weight\": 812,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.subject\",\
		\"weight\": 813,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.created\",\
		\"weight\": 814,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.author\",\
		\"weight\": 815,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary\",\
		\"weight\": 816,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Binary.id\",\
		\"weight\": 817,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.meta\",\
		\"weight\": 818,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.implicitRules\",\
		\"weight\": 819,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.language\",\
		\"weight\": 820,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.contentType\",\
		\"weight\": 821,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.content\",\
		\"weight\": 822,\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite\",\
		\"weight\": 823,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.id\",\
		\"weight\": 824,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.meta\",\
		\"weight\": 825,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.implicitRules\",\
		\"weight\": 826,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.language\",\
		\"weight\": 827,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.text\",\
		\"weight\": 828,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.contained\",\
		\"weight\": 829,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.extension\",\
		\"weight\": 830,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.modifierExtension\",\
		\"weight\": 831,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.patient\",\
		\"weight\": 832,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.identifier\",\
		\"weight\": 833,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.code\",\
		\"weight\": 834,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.modifier\",\
		\"weight\": 835,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.description\",\
		\"weight\": 836,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.image\",\
		\"weight\": 837,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle\",\
		\"weight\": 838,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.id\",\
		\"weight\": 839,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.meta\",\
		\"weight\": 840,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.implicitRules\",\
		\"weight\": 841,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.language\",\
		\"weight\": 842,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.type\",\
		\"weight\": 843,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.total\",\
		\"weight\": 844,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link\",\
		\"weight\": 845,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.id\",\
		\"weight\": 846,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link.extension\",\
		\"weight\": 847,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.modifierExtension\",\
		\"weight\": 848,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.relation\",\
		\"weight\": 849,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link.url\",\
		\"weight\": 850,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry\",\
		\"weight\": 851,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.id\",\
		\"weight\": 852,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.extension\",\
		\"weight\": 853,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.modifierExtension\",\
		\"weight\": 854,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.link\",\
		\"weight\": 855,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.fullUrl\",\
		\"weight\": 856,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.resource\",\
		\"weight\": 857,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search\",\
		\"weight\": 858,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.id\",\
		\"weight\": 859,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.extension\",\
		\"weight\": 860,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.modifierExtension\",\
		\"weight\": 861,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.mode\",\
		\"weight\": 862,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.score\",\
		\"weight\": 863,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request\",\
		\"weight\": 864,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.id\",\
		\"weight\": 865,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.extension\",\
		\"weight\": 866,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.modifierExtension\",\
		\"weight\": 867,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.method\",\
		\"weight\": 868,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.url\",\
		\"weight\": 869,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifNoneMatch\",\
		\"weight\": 870,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifModifiedSince\",\
		\"weight\": 871,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifMatch\",\
		\"weight\": 872,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifNoneExist\",\
		\"weight\": 873,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response\",\
		\"weight\": 874,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.id\",\
		\"weight\": 875,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.extension\",\
		\"weight\": 876,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.modifierExtension\",\
		\"weight\": 877,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.status\",\
		\"weight\": 878,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.location\",\
		\"weight\": 879,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.etag\",\
		\"weight\": 880,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.lastModified\",\
		\"weight\": 881,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.outcome\",\
		\"weight\": 882,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.signature\",\
		\"weight\": 883,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan\",\
		\"weight\": 884,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.id\",\
		\"weight\": 885,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.meta\",\
		\"weight\": 886,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.implicitRules\",\
		\"weight\": 887,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.language\",\
		\"weight\": 888,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.text\",\
		\"weight\": 889,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.contained\",\
		\"weight\": 890,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.extension\",\
		\"weight\": 891,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.modifierExtension\",\
		\"weight\": 892,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.identifier\",\
		\"weight\": 893,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.subject\",\
		\"weight\": 894,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.status\",\
		\"weight\": 895,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.context\",\
		\"weight\": 896,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.period\",\
		\"weight\": 897,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.author\",\
		\"weight\": 898,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.modified\",\
		\"weight\": 899,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.category\",\
		\"weight\": 900,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.description\",\
		\"weight\": 901,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.addresses\",\
		\"weight\": 902,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.support\",\
		\"weight\": 903,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan\",\
		\"weight\": 904,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.id\",\
		\"weight\": 905,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.extension\",\
		\"weight\": 906,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.modifierExtension\",\
		\"weight\": 907,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.code\",\
		\"weight\": 908,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.plan\",\
		\"weight\": 909,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.careTeam\",\
		\"weight\": 910,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.goal\",\
		\"weight\": 911,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity\",\
		\"weight\": 912,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.id\",\
		\"weight\": 913,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.extension\",\
		\"weight\": 914,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.modifierExtension\",\
		\"weight\": 915,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.actionResulting\",\
		\"weight\": 916,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.outcome\",\
		\"weight\": 917,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.progress\",\
		\"weight\": 918,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.reference\",\
		\"weight\": 919,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail\",\
		\"weight\": 920,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.id\",\
		\"weight\": 921,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.extension\",\
		\"weight\": 922,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.modifierExtension\",\
		\"weight\": 923,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.category\",\
		\"weight\": 924,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.definition\",\
		\"weight\": 925,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.code\",\
		\"weight\": 926,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.reasonCode\",\
		\"weight\": 927,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.reasonReference\",\
		\"weight\": 928,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.goal\",\
		\"weight\": 929,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.status\",\
		\"weight\": 930,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.statusReason\",\
		\"weight\": 931,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.prohibited\",\
		\"weight\": 932,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledTiming\",\
		\"weight\": 933,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledPeriod\",\
		\"weight\": 933,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledString\",\
		\"weight\": 933,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.location\",\
		\"weight\": 934,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.performer\",\
		\"weight\": 935,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productCodeableConcept\",\
		\"weight\": 936,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"weight\": 936,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"weight\": 936,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.dailyAmount\",\
		\"weight\": 937,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.quantity\",\
		\"weight\": 938,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.description\",\
		\"weight\": 939,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.note\",\
		\"weight\": 940,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam\",\
		\"weight\": 941,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.id\",\
		\"weight\": 942,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.meta\",\
		\"weight\": 943,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.implicitRules\",\
		\"weight\": 944,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.language\",\
		\"weight\": 945,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.text\",\
		\"weight\": 946,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.contained\",\
		\"weight\": 947,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.extension\",\
		\"weight\": 948,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.modifierExtension\",\
		\"weight\": 949,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.identifier\",\
		\"weight\": 950,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.status\",\
		\"weight\": 951,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.type\",\
		\"weight\": 952,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.name\",\
		\"weight\": 953,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.subject\",\
		\"weight\": 954,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.period\",\
		\"weight\": 955,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant\",\
		\"weight\": 956,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.id\",\
		\"weight\": 957,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.extension\",\
		\"weight\": 958,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.modifierExtension\",\
		\"weight\": 959,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.role\",\
		\"weight\": 960,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.member\",\
		\"weight\": 961,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.period\",\
		\"weight\": 962,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.managingOrganization\",\
		\"weight\": 963,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim\",\
		\"weight\": 964,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.id\",\
		\"weight\": 965,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.meta\",\
		\"weight\": 966,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.implicitRules\",\
		\"weight\": 967,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.language\",\
		\"weight\": 968,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.text\",\
		\"weight\": 969,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.contained\",\
		\"weight\": 970,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.extension\",\
		\"weight\": 971,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.modifierExtension\",\
		\"weight\": 972,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.identifier\",\
		\"weight\": 973,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.status\",\
		\"weight\": 974,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.type\",\
		\"weight\": 975,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.subType\",\
		\"weight\": 976,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.ruleset\",\
		\"weight\": 977,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.originalRuleset\",\
		\"weight\": 978,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.created\",\
		\"weight\": 979,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.billablePeriod\",\
		\"weight\": 980,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.insurerIdentifier\",\
		\"weight\": 981,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.insurerReference\",\
		\"weight\": 981,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.providerIdentifier\",\
		\"weight\": 982,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.providerReference\",\
		\"weight\": 982,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.organizationIdentifier\",\
		\"weight\": 983,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.organizationReference\",\
		\"weight\": 983,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.use\",\
		\"weight\": 984,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.priority\",\
		\"weight\": 985,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.fundsReserve\",\
		\"weight\": 986,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.entererIdentifier\",\
		\"weight\": 987,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.entererReference\",\
		\"weight\": 987,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.facilityIdentifier\",\
		\"weight\": 988,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.facilityReference\",\
		\"weight\": 988,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related\",\
		\"weight\": 989,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.id\",\
		\"weight\": 990,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.extension\",\
		\"weight\": 991,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.modifierExtension\",\
		\"weight\": 992,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.claimIdentifier\",\
		\"weight\": 993,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.claimReference\",\
		\"weight\": 993,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.relationship\",\
		\"weight\": 994,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.reference\",\
		\"weight\": 995,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.prescriptionIdentifier\",\
		\"weight\": 996,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.prescriptionReference\",\
		\"weight\": 996,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.prescriptionReference\",\
		\"weight\": 996,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.originalPrescriptionIdentifier\",\
		\"weight\": 997,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.originalPrescriptionReference\",\
		\"weight\": 997,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee\",\
		\"weight\": 998,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.id\",\
		\"weight\": 999,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.extension\",\
		\"weight\": 1000,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.payee.modifierExtension\",\
		\"weight\": 1001,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.payee.type\",\
		\"weight\": 1002,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.resourceType\",\
		\"weight\": 1003,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyIdentifier\",\
		\"weight\": 1004,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 1004,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 1004,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 1004,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 1004,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.referralIdentifier\",\
		\"weight\": 1005,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.referralReference\",\
		\"weight\": 1005,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.information\",\
		\"weight\": 1006,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.information.id\",\
		\"weight\": 1007,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.information.extension\",\
		\"weight\": 1008,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.information.modifierExtension\",\
		\"weight\": 1009,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.information.category\",\
		\"weight\": 1010,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.information.code\",\
		\"weight\": 1011,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.information.timingDate\",\
		\"weight\": 1012,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.information.timingPeriod\",\
		\"weight\": 1012,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.information.valueString\",\
		\"weight\": 1013,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.information.valueQuantity\",\
		\"weight\": 1013,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.diagnosis\",\
		\"weight\": 1014,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.id\",\
		\"weight\": 1015,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.extension\",\
		\"weight\": 1016,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.modifierExtension\",\
		\"weight\": 1017,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.sequence\",\
		\"weight\": 1018,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.diagnosis\",\
		\"weight\": 1019,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.type\",\
		\"weight\": 1020,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.drg\",\
		\"weight\": 1021,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure\",\
		\"weight\": 1022,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.id\",\
		\"weight\": 1023,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.extension\",\
		\"weight\": 1024,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.modifierExtension\",\
		\"weight\": 1025,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.sequence\",\
		\"weight\": 1026,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.date\",\
		\"weight\": 1027,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.procedureCoding\",\
		\"weight\": 1028,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.procedureReference\",\
		\"weight\": 1028,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.patientIdentifier\",\
		\"weight\": 1029,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.patientReference\",\
		\"weight\": 1029,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage\",\
		\"weight\": 1030,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.id\",\
		\"weight\": 1031,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.extension\",\
		\"weight\": 1032,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.modifierExtension\",\
		\"weight\": 1033,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.sequence\",\
		\"weight\": 1034,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.focal\",\
		\"weight\": 1035,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.coverageIdentifier\",\
		\"weight\": 1036,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.coverageReference\",\
		\"weight\": 1036,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.businessArrangement\",\
		\"weight\": 1037,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.preAuthRef\",\
		\"weight\": 1038,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.claimResponse\",\
		\"weight\": 1039,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.originalRuleset\",\
		\"weight\": 1040,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accident\",\
		\"weight\": 1041,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accident.id\",\
		\"weight\": 1042,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accident.extension\",\
		\"weight\": 1043,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.accident.modifierExtension\",\
		\"weight\": 1044,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.accident.date\",\
		\"weight\": 1045,\
		\"type\": \"date\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accident.type\",\
		\"weight\": 1046,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accident.locationAddress\",\
		\"weight\": 1047,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accident.locationReference\",\
		\"weight\": 1047,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.employmentImpacted\",\
		\"weight\": 1048,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.hospitalization\",\
		\"weight\": 1049,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item\",\
		\"weight\": 1050,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.id\",\
		\"weight\": 1051,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.extension\",\
		\"weight\": 1052,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.modifierExtension\",\
		\"weight\": 1053,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.sequence\",\
		\"weight\": 1054,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam\",\
		\"weight\": 1055,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.id\",\
		\"weight\": 1056,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.extension\",\
		\"weight\": 1057,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.modifierExtension\",\
		\"weight\": 1058,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.providerIdentifier\",\
		\"weight\": 1059,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.providerReference\",\
		\"weight\": 1059,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.providerReference\",\
		\"weight\": 1059,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.responsible\",\
		\"weight\": 1060,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.role\",\
		\"weight\": 1061,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.careTeam.qualification\",\
		\"weight\": 1062,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.diagnosisLinkId\",\
		\"weight\": 1063,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.revenue\",\
		\"weight\": 1064,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.category\",\
		\"weight\": 1065,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.service\",\
		\"weight\": 1066,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.modifier\",\
		\"weight\": 1067,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.programCode\",\
		\"weight\": 1068,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.servicedDate\",\
		\"weight\": 1069,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.servicedPeriod\",\
		\"weight\": 1069,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.locationCoding\",\
		\"weight\": 1070,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.locationAddress\",\
		\"weight\": 1070,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.locationReference\",\
		\"weight\": 1070,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.quantity\",\
		\"weight\": 1071,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.unitPrice\",\
		\"weight\": 1072,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.factor\",\
		\"weight\": 1073,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.points\",\
		\"weight\": 1074,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.net\",\
		\"weight\": 1075,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.udi\",\
		\"weight\": 1076,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.bodySite\",\
		\"weight\": 1077,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.subSite\",\
		\"weight\": 1078,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail\",\
		\"weight\": 1079,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.id\",\
		\"weight\": 1080,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.extension\",\
		\"weight\": 1081,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.modifierExtension\",\
		\"weight\": 1082,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.sequence\",\
		\"weight\": 1083,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.revenue\",\
		\"weight\": 1084,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.category\",\
		\"weight\": 1085,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.service\",\
		\"weight\": 1086,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.modifier\",\
		\"weight\": 1087,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.programCode\",\
		\"weight\": 1088,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.quantity\",\
		\"weight\": 1089,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.unitPrice\",\
		\"weight\": 1090,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.factor\",\
		\"weight\": 1091,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.points\",\
		\"weight\": 1092,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.net\",\
		\"weight\": 1093,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.udi\",\
		\"weight\": 1094,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail\",\
		\"weight\": 1095,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.id\",\
		\"weight\": 1096,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.extension\",\
		\"weight\": 1097,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.modifierExtension\",\
		\"weight\": 1098,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.sequence\",\
		\"weight\": 1099,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.revenue\",\
		\"weight\": 1100,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.category\",\
		\"weight\": 1101,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.service\",\
		\"weight\": 1102,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.modifier\",\
		\"weight\": 1103,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.programCode\",\
		\"weight\": 1104,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.quantity\",\
		\"weight\": 1105,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.unitPrice\",\
		\"weight\": 1106,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.factor\",\
		\"weight\": 1107,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.points\",\
		\"weight\": 1108,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.net\",\
		\"weight\": 1109,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.udi\",\
		\"weight\": 1110,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis\",\
		\"weight\": 1111,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.id\",\
		\"weight\": 1112,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.extension\",\
		\"weight\": 1113,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.modifierExtension\",\
		\"weight\": 1114,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.initial\",\
		\"weight\": 1115,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.priorDate\",\
		\"weight\": 1116,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.priorMaterial\",\
		\"weight\": 1117,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.total\",\
		\"weight\": 1118,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth\",\
		\"weight\": 1119,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.id\",\
		\"weight\": 1120,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.extension\",\
		\"weight\": 1121,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.modifierExtension\",\
		\"weight\": 1122,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.tooth\",\
		\"weight\": 1123,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.reason\",\
		\"weight\": 1124,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.extractionDate\",\
		\"weight\": 1125,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse\",\
		\"weight\": 1126,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.id\",\
		\"weight\": 1127,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.meta\",\
		\"weight\": 1128,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.implicitRules\",\
		\"weight\": 1129,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.language\",\
		\"weight\": 1130,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.text\",\
		\"weight\": 1131,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.contained\",\
		\"weight\": 1132,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.extension\",\
		\"weight\": 1133,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.modifierExtension\",\
		\"weight\": 1134,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.identifier\",\
		\"weight\": 1135,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.status\",\
		\"weight\": 1136,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestIdentifier\",\
		\"weight\": 1137,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestReference\",\
		\"weight\": 1137,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.ruleset\",\
		\"weight\": 1138,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.originalRuleset\",\
		\"weight\": 1139,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.created\",\
		\"weight\": 1140,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.organizationIdentifier\",\
		\"weight\": 1141,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.organizationReference\",\
		\"weight\": 1141,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestProviderIdentifier\",\
		\"weight\": 1142,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestProviderReference\",\
		\"weight\": 1142,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestOrganizationIdentifier\",\
		\"weight\": 1143,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestOrganizationReference\",\
		\"weight\": 1143,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.outcome\",\
		\"weight\": 1144,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.disposition\",\
		\"weight\": 1145,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payeeType\",\
		\"weight\": 1146,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item\",\
		\"weight\": 1147,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.id\",\
		\"weight\": 1148,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.extension\",\
		\"weight\": 1149,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.modifierExtension\",\
		\"weight\": 1150,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.sequenceLinkId\",\
		\"weight\": 1151,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.noteNumber\",\
		\"weight\": 1152,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication\",\
		\"weight\": 1153,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.id\",\
		\"weight\": 1154,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.extension\",\
		\"weight\": 1155,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.modifierExtension\",\
		\"weight\": 1156,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.category\",\
		\"weight\": 1157,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.reason\",\
		\"weight\": 1158,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.amount\",\
		\"weight\": 1159,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.value\",\
		\"weight\": 1160,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail\",\
		\"weight\": 1161,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.id\",\
		\"weight\": 1162,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.extension\",\
		\"weight\": 1163,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.modifierExtension\",\
		\"weight\": 1164,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.sequenceLinkId\",\
		\"weight\": 1165,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.noteNumber\",\
		\"weight\": 1166,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication\",\
		\"weight\": 1167,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail\",\
		\"weight\": 1168,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.id\",\
		\"weight\": 1169,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.extension\",\
		\"weight\": 1170,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.modifierExtension\",\
		\"weight\": 1171,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.sequenceLinkId\",\
		\"weight\": 1172,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.noteNumber\",\
		\"weight\": 1173,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication\",\
		\"weight\": 1174,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem\",\
		\"weight\": 1175,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.id\",\
		\"weight\": 1176,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.extension\",\
		\"weight\": 1177,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.modifierExtension\",\
		\"weight\": 1178,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.sequenceLinkId\",\
		\"weight\": 1179,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.revenue\",\
		\"weight\": 1180,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.category\",\
		\"weight\": 1181,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.service\",\
		\"weight\": 1182,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.modifier\",\
		\"weight\": 1183,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.fee\",\
		\"weight\": 1184,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.noteNumber\",\
		\"weight\": 1185,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication\",\
		\"weight\": 1186,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail\",\
		\"weight\": 1187,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.id\",\
		\"weight\": 1188,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.extension\",\
		\"weight\": 1189,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.modifierExtension\",\
		\"weight\": 1190,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.revenue\",\
		\"weight\": 1191,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.category\",\
		\"weight\": 1192,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.service\",\
		\"weight\": 1193,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.modifier\",\
		\"weight\": 1194,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.fee\",\
		\"weight\": 1195,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.noteNumber\",\
		\"weight\": 1196,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication\",\
		\"weight\": 1197,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error\",\
		\"weight\": 1198,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.id\",\
		\"weight\": 1199,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.extension\",\
		\"weight\": 1200,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.modifierExtension\",\
		\"weight\": 1201,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.sequenceLinkId\",\
		\"weight\": 1202,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.detailSequenceLinkId\",\
		\"weight\": 1203,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.subdetailSequenceLinkId\",\
		\"weight\": 1204,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.code\",\
		\"weight\": 1205,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.totalCost\",\
		\"weight\": 1206,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.unallocDeductable\",\
		\"weight\": 1207,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.totalBenefit\",\
		\"weight\": 1208,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment\",\
		\"weight\": 1209,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.id\",\
		\"weight\": 1210,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.extension\",\
		\"weight\": 1211,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.modifierExtension\",\
		\"weight\": 1212,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.type\",\
		\"weight\": 1213,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.adjustment\",\
		\"weight\": 1214,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.adjustmentReason\",\
		\"weight\": 1215,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.date\",\
		\"weight\": 1216,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.amount\",\
		\"weight\": 1217,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payment.identifier\",\
		\"weight\": 1218,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.reserved\",\
		\"weight\": 1219,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.form\",\
		\"weight\": 1220,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note\",\
		\"weight\": 1221,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.id\",\
		\"weight\": 1222,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.extension\",\
		\"weight\": 1223,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.modifierExtension\",\
		\"weight\": 1224,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.number\",\
		\"weight\": 1225,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.type\",\
		\"weight\": 1226,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.text\",\
		\"weight\": 1227,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.language\",\
		\"weight\": 1228,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage\",\
		\"weight\": 1229,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.id\",\
		\"weight\": 1230,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.extension\",\
		\"weight\": 1231,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.modifierExtension\",\
		\"weight\": 1232,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.sequence\",\
		\"weight\": 1233,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.focal\",\
		\"weight\": 1234,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.coverageIdentifier\",\
		\"weight\": 1235,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.coverageReference\",\
		\"weight\": 1235,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.businessArrangement\",\
		\"weight\": 1236,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.preAuthRef\",\
		\"weight\": 1237,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.claimResponse\",\
		\"weight\": 1238,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression\",\
		\"weight\": 1239,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.id\",\
		\"weight\": 1240,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.meta\",\
		\"weight\": 1241,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.implicitRules\",\
		\"weight\": 1242,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.language\",\
		\"weight\": 1243,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.text\",\
		\"weight\": 1244,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.contained\",\
		\"weight\": 1245,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.extension\",\
		\"weight\": 1246,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.modifierExtension\",\
		\"weight\": 1247,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.identifier\",\
		\"weight\": 1248,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.status\",\
		\"weight\": 1249,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.code\",\
		\"weight\": 1250,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.description\",\
		\"weight\": 1251,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.subject\",\
		\"weight\": 1252,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.assessor\",\
		\"weight\": 1253,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.date\",\
		\"weight\": 1254,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.effectiveDateTime\",\
		\"weight\": 1255,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.effectivePeriod\",\
		\"weight\": 1255,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.context\",\
		\"weight\": 1256,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.previous\",\
		\"weight\": 1257,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.problem\",\
		\"weight\": 1258,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations\",\
		\"weight\": 1259,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.id\",\
		\"weight\": 1260,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.extension\",\
		\"weight\": 1261,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.modifierExtension\",\
		\"weight\": 1262,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.code\",\
		\"weight\": 1263,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.item\",\
		\"weight\": 1264,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.protocol\",\
		\"weight\": 1265,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.summary\",\
		\"weight\": 1266,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding\",\
		\"weight\": 1267,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.id\",\
		\"weight\": 1268,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.extension\",\
		\"weight\": 1269,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.modifierExtension\",\
		\"weight\": 1270,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.itemCodeableConcept\",\
		\"weight\": 1271,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.itemReference\",\
		\"weight\": 1271,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.itemReference\",\
		\"weight\": 1271,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.cause\",\
		\"weight\": 1272,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.prognosisCodeableConcept\",\
		\"weight\": 1273,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.prognosisReference\",\
		\"weight\": 1274,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.plan\",\
		\"weight\": 1275,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.action\",\
		\"weight\": 1276,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.note\",\
		\"weight\": 1277,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication\",\
		\"weight\": 1278,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.id\",\
		\"weight\": 1279,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.meta\",\
		\"weight\": 1280,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.implicitRules\",\
		\"weight\": 1281,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.language\",\
		\"weight\": 1282,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.text\",\
		\"weight\": 1283,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.contained\",\
		\"weight\": 1284,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.extension\",\
		\"weight\": 1285,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.modifierExtension\",\
		\"weight\": 1286,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.identifier\",\
		\"weight\": 1287,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.basedOn\",\
		\"weight\": 1288,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.parent\",\
		\"weight\": 1289,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.status\",\
		\"weight\": 1290,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.category\",\
		\"weight\": 1291,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.medium\",\
		\"weight\": 1292,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.subject\",\
		\"weight\": 1293,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.topic\",\
		\"weight\": 1294,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.context\",\
		\"weight\": 1295,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.sent\",\
		\"weight\": 1296,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.received\",\
		\"weight\": 1297,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.sender\",\
		\"weight\": 1298,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.recipient\",\
		\"weight\": 1299,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.reason\",\
		\"weight\": 1300,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload\",\
		\"weight\": 1301,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.id\",\
		\"weight\": 1302,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.payload.extension\",\
		\"weight\": 1303,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.modifierExtension\",\
		\"weight\": 1304,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.contentString\",\
		\"weight\": 1305,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.payload.contentAttachment\",\
		\"weight\": 1305,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.payload.contentReference\",\
		\"weight\": 1305,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.note\",\
		\"weight\": 1306,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest\",\
		\"weight\": 1307,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.id\",\
		\"weight\": 1308,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.meta\",\
		\"weight\": 1309,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.implicitRules\",\
		\"weight\": 1310,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.language\",\
		\"weight\": 1311,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.text\",\
		\"weight\": 1312,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.contained\",\
		\"weight\": 1313,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.extension\",\
		\"weight\": 1314,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.modifierExtension\",\
		\"weight\": 1315,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.identifier\",\
		\"weight\": 1316,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.category\",\
		\"weight\": 1317,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.sender\",\
		\"weight\": 1318,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.recipient\",\
		\"weight\": 1319,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload\",\
		\"weight\": 1320,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.id\",\
		\"weight\": 1321,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.extension\",\
		\"weight\": 1322,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.modifierExtension\",\
		\"weight\": 1323,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentString\",\
		\"weight\": 1324,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentAttachment\",\
		\"weight\": 1324,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentReference\",\
		\"weight\": 1324,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.medium\",\
		\"weight\": 1325,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.requester\",\
		\"weight\": 1326,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.status\",\
		\"weight\": 1327,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.encounter\",\
		\"weight\": 1328,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.scheduledDateTime\",\
		\"weight\": 1329,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.scheduledPeriod\",\
		\"weight\": 1329,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.reason\",\
		\"weight\": 1330,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.requestedOn\",\
		\"weight\": 1331,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.subject\",\
		\"weight\": 1332,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.priority\",\
		\"weight\": 1333,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition\",\
		\"weight\": 1334,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.id\",\
		\"weight\": 1335,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.meta\",\
		\"weight\": 1336,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.implicitRules\",\
		\"weight\": 1337,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.language\",\
		\"weight\": 1338,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.text\",\
		\"weight\": 1339,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contained\",\
		\"weight\": 1340,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.extension\",\
		\"weight\": 1341,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.modifierExtension\",\
		\"weight\": 1342,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.url\",\
		\"weight\": 1343,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.name\",\
		\"weight\": 1344,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.status\",\
		\"weight\": 1345,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.experimental\",\
		\"weight\": 1346,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.publisher\",\
		\"weight\": 1347,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact\",\
		\"weight\": 1348,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.id\",\
		\"weight\": 1349,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.extension\",\
		\"weight\": 1350,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.modifierExtension\",\
		\"weight\": 1351,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.name\",\
		\"weight\": 1352,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.telecom\",\
		\"weight\": 1353,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.date\",\
		\"weight\": 1354,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.description\",\
		\"weight\": 1355,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.requirements\",\
		\"weight\": 1356,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.code\",\
		\"weight\": 1357,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.search\",\
		\"weight\": 1358,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource\",\
		\"weight\": 1359,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.id\",\
		\"weight\": 1360,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.extension\",\
		\"weight\": 1361,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.modifierExtension\",\
		\"weight\": 1362,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.code\",\
		\"weight\": 1363,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.param\",\
		\"weight\": 1364,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.documentation\",\
		\"weight\": 1365,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition\",\
		\"weight\": 1366,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.id\",\
		\"weight\": 1367,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.meta\",\
		\"weight\": 1368,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.implicitRules\",\
		\"weight\": 1369,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.language\",\
		\"weight\": 1370,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.text\",\
		\"weight\": 1371,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.contained\",\
		\"weight\": 1372,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.extension\",\
		\"weight\": 1373,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.modifierExtension\",\
		\"weight\": 1374,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.identifier\",\
		\"weight\": 1375,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.date\",\
		\"weight\": 1376,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.type\",\
		\"weight\": 1377,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.class\",\
		\"weight\": 1378,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.title\",\
		\"weight\": 1379,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.status\",\
		\"weight\": 1380,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.confidentiality\",\
		\"weight\": 1381,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.subject\",\
		\"weight\": 1382,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.author\",\
		\"weight\": 1383,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester\",\
		\"weight\": 1384,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.id\",\
		\"weight\": 1385,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.attester.extension\",\
		\"weight\": 1386,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.modifierExtension\",\
		\"weight\": 1387,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.mode\",\
		\"weight\": 1388,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.time\",\
		\"weight\": 1389,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.attester.party\",\
		\"weight\": 1390,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.custodian\",\
		\"weight\": 1391,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event\",\
		\"weight\": 1392,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.id\",\
		\"weight\": 1393,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event.extension\",\
		\"weight\": 1394,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.modifierExtension\",\
		\"weight\": 1395,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.code\",\
		\"weight\": 1396,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.period\",\
		\"weight\": 1397,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event.detail\",\
		\"weight\": 1398,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.encounter\",\
		\"weight\": 1399,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section\",\
		\"weight\": 1400,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.id\",\
		\"weight\": 1401,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.extension\",\
		\"weight\": 1402,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.modifierExtension\",\
		\"weight\": 1403,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.title\",\
		\"weight\": 1404,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.code\",\
		\"weight\": 1405,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.text\",\
		\"weight\": 1406,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.mode\",\
		\"weight\": 1407,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.orderedBy\",\
		\"weight\": 1408,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.entry\",\
		\"weight\": 1409,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.emptyReason\",\
		\"weight\": 1410,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.section\",\
		\"weight\": 1411,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap\",\
		\"weight\": 1412,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.id\",\
		\"weight\": 1413,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.meta\",\
		\"weight\": 1414,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.implicitRules\",\
		\"weight\": 1415,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.language\",\
		\"weight\": 1416,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.text\",\
		\"weight\": 1417,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contained\",\
		\"weight\": 1418,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.extension\",\
		\"weight\": 1419,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.modifierExtension\",\
		\"weight\": 1420,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.url\",\
		\"weight\": 1421,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.identifier\",\
		\"weight\": 1422,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.version\",\
		\"weight\": 1423,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.name\",\
		\"weight\": 1424,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.status\",\
		\"weight\": 1425,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.experimental\",\
		\"weight\": 1426,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.publisher\",\
		\"weight\": 1427,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact\",\
		\"weight\": 1428,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.id\",\
		\"weight\": 1429,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.extension\",\
		\"weight\": 1430,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.modifierExtension\",\
		\"weight\": 1431,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.name\",\
		\"weight\": 1432,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.telecom\",\
		\"weight\": 1433,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.date\",\
		\"weight\": 1434,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.description\",\
		\"weight\": 1435,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.useContext\",\
		\"weight\": 1436,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.requirements\",\
		\"weight\": 1437,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.copyright\",\
		\"weight\": 1438,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceUri\",\
		\"weight\": 1439,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceReference\",\
		\"weight\": 1439,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceReference\",\
		\"weight\": 1439,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.targetUri\",\
		\"weight\": 1440,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.targetReference\",\
		\"weight\": 1440,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.targetReference\",\
		\"weight\": 1440,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group\",\
		\"weight\": 1441,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.id\",\
		\"weight\": 1442,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.extension\",\
		\"weight\": 1443,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.modifierExtension\",\
		\"weight\": 1444,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.source\",\
		\"weight\": 1445,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.sourceVersion\",\
		\"weight\": 1446,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.target\",\
		\"weight\": 1447,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.targetVersion\",\
		\"weight\": 1448,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element\",\
		\"weight\": 1449,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.id\",\
		\"weight\": 1450,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.extension\",\
		\"weight\": 1451,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.modifierExtension\",\
		\"weight\": 1452,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.code\",\
		\"weight\": 1453,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target\",\
		\"weight\": 1454,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.id\",\
		\"weight\": 1455,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.extension\",\
		\"weight\": 1456,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.modifierExtension\",\
		\"weight\": 1457,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.code\",\
		\"weight\": 1458,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.equivalence\",\
		\"weight\": 1459,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.comments\",\
		\"weight\": 1460,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.dependsOn\",\
		\"weight\": 1461,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.dependsOn.id\",\
		\"weight\": 1462,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.dependsOn.extension\",\
		\"weight\": 1463,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.dependsOn.modifierExtension\",\
		\"weight\": 1464,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.dependsOn.property\",\
		\"weight\": 1465,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.dependsOn.system\",\
		\"weight\": 1466,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.dependsOn.code\",\
		\"weight\": 1467,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.group.element.target.product\",\
		\"weight\": 1468,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition\",\
		\"weight\": 1469,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.id\",\
		\"weight\": 1470,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.meta\",\
		\"weight\": 1471,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.implicitRules\",\
		\"weight\": 1472,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.language\",\
		\"weight\": 1473,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.text\",\
		\"weight\": 1474,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.contained\",\
		\"weight\": 1475,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.extension\",\
		\"weight\": 1476,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.modifierExtension\",\
		\"weight\": 1477,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.identifier\",\
		\"weight\": 1478,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.clinicalStatus\",\
		\"weight\": 1479,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.verificationStatus\",\
		\"weight\": 1480,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.category\",\
		\"weight\": 1481,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.severity\",\
		\"weight\": 1482,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.code\",\
		\"weight\": 1483,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.bodySite\",\
		\"weight\": 1484,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.subject\",\
		\"weight\": 1485,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.context\",\
		\"weight\": 1486,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetDateTime\",\
		\"weight\": 1487,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetAge\",\
		\"weight\": 1487,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetPeriod\",\
		\"weight\": 1487,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetRange\",\
		\"weight\": 1487,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetString\",\
		\"weight\": 1487,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementDateTime\",\
		\"weight\": 1488,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementAge\",\
		\"weight\": 1488,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementBoolean\",\
		\"weight\": 1488,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementPeriod\",\
		\"weight\": 1488,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementRange\",\
		\"weight\": 1488,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementString\",\
		\"weight\": 1488,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.dateRecorded\",\
		\"weight\": 1489,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.asserter\",\
		\"weight\": 1490,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage\",\
		\"weight\": 1491,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.id\",\
		\"weight\": 1492,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.extension\",\
		\"weight\": 1493,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.stage.modifierExtension\",\
		\"weight\": 1494,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.stage.summary\",\
		\"weight\": 1495,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.assessment\",\
		\"weight\": 1496,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence\",\
		\"weight\": 1497,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.id\",\
		\"weight\": 1498,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.evidence.extension\",\
		\"weight\": 1499,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.modifierExtension\",\
		\"weight\": 1500,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.code\",\
		\"weight\": 1501,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.evidence.detail\",\
		\"weight\": 1502,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.note\",\
		\"weight\": 1503,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance\",\
		\"weight\": 1504,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.id\",\
		\"weight\": 1505,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.meta\",\
		\"weight\": 1506,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implicitRules\",\
		\"weight\": 1507,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.language\",\
		\"weight\": 1508,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.text\",\
		\"weight\": 1509,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contained\",\
		\"weight\": 1510,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.extension\",\
		\"weight\": 1511,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.modifierExtension\",\
		\"weight\": 1512,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.url\",\
		\"weight\": 1513,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.version\",\
		\"weight\": 1514,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.name\",\
		\"weight\": 1515,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.status\",\
		\"weight\": 1516,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.experimental\",\
		\"weight\": 1517,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.date\",\
		\"weight\": 1518,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.publisher\",\
		\"weight\": 1519,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact\",\
		\"weight\": 1520,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.id\",\
		\"weight\": 1521,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact.extension\",\
		\"weight\": 1522,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.modifierExtension\",\
		\"weight\": 1523,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.name\",\
		\"weight\": 1524,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact.telecom\",\
		\"weight\": 1525,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.description\",\
		\"weight\": 1526,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.useContext\",\
		\"weight\": 1527,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.requirements\",\
		\"weight\": 1528,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.copyright\",\
		\"weight\": 1529,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.kind\",\
		\"weight\": 1530,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.instantiates\",\
		\"weight\": 1531,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.software\",\
		\"weight\": 1532,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.id\",\
		\"weight\": 1533,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.extension\",\
		\"weight\": 1534,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.software.modifierExtension\",\
		\"weight\": 1535,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.software.name\",\
		\"weight\": 1536,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.version\",\
		\"weight\": 1537,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.releaseDate\",\
		\"weight\": 1538,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation\",\
		\"weight\": 1539,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.id\",\
		\"weight\": 1540,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.extension\",\
		\"weight\": 1541,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.implementation.modifierExtension\",\
		\"weight\": 1542,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.implementation.description\",\
		\"weight\": 1543,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.url\",\
		\"weight\": 1544,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.fhirVersion\",\
		\"weight\": 1545,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.acceptUnknown\",\
		\"weight\": 1546,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.format\",\
		\"weight\": 1547,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.profile\",\
		\"weight\": 1548,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest\",\
		\"weight\": 1549,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.id\",\
		\"weight\": 1550,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.extension\",\
		\"weight\": 1551,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.modifierExtension\",\
		\"weight\": 1552,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.mode\",\
		\"weight\": 1553,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.documentation\",\
		\"weight\": 1554,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security\",\
		\"weight\": 1555,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.id\",\
		\"weight\": 1556,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.extension\",\
		\"weight\": 1557,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.modifierExtension\",\
		\"weight\": 1558,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.cors\",\
		\"weight\": 1559,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.service\",\
		\"weight\": 1560,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.description\",\
		\"weight\": 1561,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate\",\
		\"weight\": 1562,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.id\",\
		\"weight\": 1563,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.extension\",\
		\"weight\": 1564,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.modifierExtension\",\
		\"weight\": 1565,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.type\",\
		\"weight\": 1566,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.blob\",\
		\"weight\": 1567,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource\",\
		\"weight\": 1568,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.id\",\
		\"weight\": 1569,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.extension\",\
		\"weight\": 1570,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.modifierExtension\",\
		\"weight\": 1571,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.type\",\
		\"weight\": 1572,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.profile\",\
		\"weight\": 1573,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.documentation\",\
		\"weight\": 1574,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction\",\
		\"weight\": 1575,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.id\",\
		\"weight\": 1576,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.extension\",\
		\"weight\": 1577,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.modifierExtension\",\
		\"weight\": 1578,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.code\",\
		\"weight\": 1579,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.documentation\",\
		\"weight\": 1580,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.versioning\",\
		\"weight\": 1581,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.readHistory\",\
		\"weight\": 1582,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.updateCreate\",\
		\"weight\": 1583,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalCreate\",\
		\"weight\": 1584,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalRead\",\
		\"weight\": 1585,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalUpdate\",\
		\"weight\": 1586,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalDelete\",\
		\"weight\": 1587,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchInclude\",\
		\"weight\": 1588,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchRevInclude\",\
		\"weight\": 1589,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam\",\
		\"weight\": 1590,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.id\",\
		\"weight\": 1591,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.extension\",\
		\"weight\": 1592,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.modifierExtension\",\
		\"weight\": 1593,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.name\",\
		\"weight\": 1594,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.definition\",\
		\"weight\": 1595,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.type\",\
		\"weight\": 1596,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.documentation\",\
		\"weight\": 1597,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.target\",\
		\"weight\": 1598,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.modifier\",\
		\"weight\": 1599,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.chain\",\
		\"weight\": 1600,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction\",\
		\"weight\": 1601,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.id\",\
		\"weight\": 1602,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.extension\",\
		\"weight\": 1603,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.modifierExtension\",\
		\"weight\": 1604,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.code\",\
		\"weight\": 1605,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.documentation\",\
		\"weight\": 1606,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.searchParam\",\
		\"weight\": 1607,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation\",\
		\"weight\": 1608,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.id\",\
		\"weight\": 1609,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.extension\",\
		\"weight\": 1610,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.modifierExtension\",\
		\"weight\": 1611,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.name\",\
		\"weight\": 1612,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.definition\",\
		\"weight\": 1613,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.compartment\",\
		\"weight\": 1614,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging\",\
		\"weight\": 1615,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.id\",\
		\"weight\": 1616,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.extension\",\
		\"weight\": 1617,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.modifierExtension\",\
		\"weight\": 1618,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint\",\
		\"weight\": 1619,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.id\",\
		\"weight\": 1620,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.extension\",\
		\"weight\": 1621,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.modifierExtension\",\
		\"weight\": 1622,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.protocol\",\
		\"weight\": 1623,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.address\",\
		\"weight\": 1624,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.reliableCache\",\
		\"weight\": 1625,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.documentation\",\
		\"weight\": 1626,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event\",\
		\"weight\": 1627,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.id\",\
		\"weight\": 1628,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.extension\",\
		\"weight\": 1629,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.modifierExtension\",\
		\"weight\": 1630,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.code\",\
		\"weight\": 1631,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.category\",\
		\"weight\": 1632,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.mode\",\
		\"weight\": 1633,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.focus\",\
		\"weight\": 1634,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.request\",\
		\"weight\": 1635,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.response\",\
		\"weight\": 1636,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.documentation\",\
		\"weight\": 1637,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document\",\
		\"weight\": 1638,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.id\",\
		\"weight\": 1639,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.extension\",\
		\"weight\": 1640,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.modifierExtension\",\
		\"weight\": 1641,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.mode\",\
		\"weight\": 1642,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.documentation\",\
		\"weight\": 1643,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.profile\",\
		\"weight\": 1644,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent\",\
		\"weight\": 1645,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.id\",\
		\"weight\": 1646,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.meta\",\
		\"weight\": 1647,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.implicitRules\",\
		\"weight\": 1648,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.language\",\
		\"weight\": 1649,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.text\",\
		\"weight\": 1650,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.contained\",\
		\"weight\": 1651,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.extension\",\
		\"weight\": 1652,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.modifierExtension\",\
		\"weight\": 1653,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.identifier\",\
		\"weight\": 1654,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.status\",\
		\"weight\": 1655,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.category\",\
		\"weight\": 1656,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.dateTime\",\
		\"weight\": 1657,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.period\",\
		\"weight\": 1658,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.patient\",\
		\"weight\": 1659,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.consentor\",\
		\"weight\": 1660,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.organization\",\
		\"weight\": 1661,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.sourceAttachment\",\
		\"weight\": 1662,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.sourceIdentifier\",\
		\"weight\": 1662,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1662,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1662,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1662,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1662,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.policy\",\
		\"weight\": 1663,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.recipient\",\
		\"weight\": 1664,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.purpose\",\
		\"weight\": 1665,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except\",\
		\"weight\": 1666,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.id\",\
		\"weight\": 1667,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.except.extension\",\
		\"weight\": 1668,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.modifierExtension\",\
		\"weight\": 1669,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.type\",\
		\"weight\": 1670,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.except.period\",\
		\"weight\": 1671,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.except.actor\",\
		\"weight\": 1672,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.actor.id\",\
		\"weight\": 1673,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.except.actor.extension\",\
		\"weight\": 1674,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.actor.modifierExtension\",\
		\"weight\": 1675,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.actor.role\",\
		\"weight\": 1676,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.except.actor.reference\",\
		\"weight\": 1677,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.except.action\",\
		\"weight\": 1678,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.securityLabel\",\
		\"weight\": 1679,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.purpose\",\
		\"weight\": 1680,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.class\",\
		\"weight\": 1681,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.code\",\
		\"weight\": 1682,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.data\",\
		\"weight\": 1683,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.data.id\",\
		\"weight\": 1684,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.except.data.extension\",\
		\"weight\": 1685,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.data.modifierExtension\",\
		\"weight\": 1686,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Consent.except.data.meaning\",\
		\"weight\": 1687,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Consent.except.data.reference\",\
		\"weight\": 1688,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract\",\
		\"weight\": 1689,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.id\",\
		\"weight\": 1690,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.meta\",\
		\"weight\": 1691,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.implicitRules\",\
		\"weight\": 1692,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.language\",\
		\"weight\": 1693,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.text\",\
		\"weight\": 1694,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.contained\",\
		\"weight\": 1695,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.extension\",\
		\"weight\": 1696,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.modifierExtension\",\
		\"weight\": 1697,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.identifier\",\
		\"weight\": 1698,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.issued\",\
		\"weight\": 1699,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.applies\",\
		\"weight\": 1700,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.subject\",\
		\"weight\": 1701,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.topic\",\
		\"weight\": 1702,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.authority\",\
		\"weight\": 1703,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.domain\",\
		\"weight\": 1704,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.type\",\
		\"weight\": 1705,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.subType\",\
		\"weight\": 1706,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.action\",\
		\"weight\": 1707,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.actionReason\",\
		\"weight\": 1708,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent\",\
		\"weight\": 1709,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.id\",\
		\"weight\": 1710,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.agent.extension\",\
		\"weight\": 1711,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.modifierExtension\",\
		\"weight\": 1712,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.actor\",\
		\"weight\": 1713,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.agent.role\",\
		\"weight\": 1714,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer\",\
		\"weight\": 1715,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.id\",\
		\"weight\": 1716,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.extension\",\
		\"weight\": 1717,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.modifierExtension\",\
		\"weight\": 1718,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.type\",\
		\"weight\": 1719,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.party\",\
		\"weight\": 1720,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.signature\",\
		\"weight\": 1721,\
		\"type\": \"Signature\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem\",\
		\"weight\": 1722,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.id\",\
		\"weight\": 1723,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.extension\",\
		\"weight\": 1724,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.modifierExtension\",\
		\"weight\": 1725,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.entityCodeableConcept\",\
		\"weight\": 1726,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.entityReference\",\
		\"weight\": 1726,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.identifier\",\
		\"weight\": 1727,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.effectiveTime\",\
		\"weight\": 1728,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.quantity\",\
		\"weight\": 1729,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.unitPrice\",\
		\"weight\": 1730,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.factor\",\
		\"weight\": 1731,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.points\",\
		\"weight\": 1732,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.net\",\
		\"weight\": 1733,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term\",\
		\"weight\": 1734,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.id\",\
		\"weight\": 1735,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.extension\",\
		\"weight\": 1736,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.modifierExtension\",\
		\"weight\": 1737,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.identifier\",\
		\"weight\": 1738,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.issued\",\
		\"weight\": 1739,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.applies\",\
		\"weight\": 1740,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.type\",\
		\"weight\": 1741,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.subType\",\
		\"weight\": 1742,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.topic\",\
		\"weight\": 1743,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.action\",\
		\"weight\": 1744,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.actionReason\",\
		\"weight\": 1745,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent\",\
		\"weight\": 1746,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.id\",\
		\"weight\": 1747,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.agent.extension\",\
		\"weight\": 1748,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.modifierExtension\",\
		\"weight\": 1749,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.actor\",\
		\"weight\": 1750,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.agent.role\",\
		\"weight\": 1751,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.text\",\
		\"weight\": 1752,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem\",\
		\"weight\": 1753,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.id\",\
		\"weight\": 1754,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.extension\",\
		\"weight\": 1755,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.modifierExtension\",\
		\"weight\": 1756,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.entityCodeableConcept\",\
		\"weight\": 1757,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.entityReference\",\
		\"weight\": 1757,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.identifier\",\
		\"weight\": 1758,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.effectiveTime\",\
		\"weight\": 1759,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.quantity\",\
		\"weight\": 1760,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.unitPrice\",\
		\"weight\": 1761,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.factor\",\
		\"weight\": 1762,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.points\",\
		\"weight\": 1763,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.net\",\
		\"weight\": 1764,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.group\",\
		\"weight\": 1765,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.bindingAttachment\",\
		\"weight\": 1766,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1766,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1766,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1766,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly\",\
		\"weight\": 1767,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.id\",\
		\"weight\": 1768,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.extension\",\
		\"weight\": 1769,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.modifierExtension\",\
		\"weight\": 1770,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentAttachment\",\
		\"weight\": 1771,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1771,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1771,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1771,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal\",\
		\"weight\": 1772,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.id\",\
		\"weight\": 1773,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.extension\",\
		\"weight\": 1774,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.modifierExtension\",\
		\"weight\": 1775,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.contentAttachment\",\
		\"weight\": 1776,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1776,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1776,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1776,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.rule\",\
		\"weight\": 1777,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.id\",\
		\"weight\": 1778,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.rule.extension\",\
		\"weight\": 1779,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.modifierExtension\",\
		\"weight\": 1780,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.contentAttachment\",\
		\"weight\": 1781,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.rule.contentReference\",\
		\"weight\": 1781,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage\",\
		\"weight\": 1782,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.id\",\
		\"weight\": 1783,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.meta\",\
		\"weight\": 1784,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.implicitRules\",\
		\"weight\": 1785,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.language\",\
		\"weight\": 1786,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.text\",\
		\"weight\": 1787,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.contained\",\
		\"weight\": 1788,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.extension\",\
		\"weight\": 1789,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.modifierExtension\",\
		\"weight\": 1790,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.status\",\
		\"weight\": 1791,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.issuerIdentifier\",\
		\"weight\": 1792,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.issuerReference\",\
		\"weight\": 1792,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.issuerReference\",\
		\"weight\": 1792,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.issuerReference\",\
		\"weight\": 1792,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.isAgreement\",\
		\"weight\": 1793,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.bin\",\
		\"weight\": 1794,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.period\",\
		\"weight\": 1795,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.type\",\
		\"weight\": 1796,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.planholderIdentifier\",\
		\"weight\": 1797,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.planholderReference\",\
		\"weight\": 1797,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.planholderReference\",\
		\"weight\": 1797,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.beneficiaryIdentifier\",\
		\"weight\": 1798,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.beneficiaryReference\",\
		\"weight\": 1798,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.relationship\",\
		\"weight\": 1799,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.identifier\",\
		\"weight\": 1800,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.group\",\
		\"weight\": 1801,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.subGroup\",\
		\"weight\": 1802,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.plan\",\
		\"weight\": 1803,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.subPlan\",\
		\"weight\": 1804,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.class\",\
		\"weight\": 1805,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.dependent\",\
		\"weight\": 1806,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.sequence\",\
		\"weight\": 1807,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.network\",\
		\"weight\": 1808,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.contract\",\
		\"weight\": 1809,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement\",\
		\"weight\": 1810,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.id\",\
		\"weight\": 1811,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.meta\",\
		\"weight\": 1812,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.implicitRules\",\
		\"weight\": 1813,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.language\",\
		\"weight\": 1814,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.text\",\
		\"weight\": 1815,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contained\",\
		\"weight\": 1816,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.extension\",\
		\"weight\": 1817,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.modifierExtension\",\
		\"weight\": 1818,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.url\",\
		\"weight\": 1819,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.identifier\",\
		\"weight\": 1820,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.version\",\
		\"weight\": 1821,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.status\",\
		\"weight\": 1822,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.experimental\",\
		\"weight\": 1823,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.publisher\",\
		\"weight\": 1824,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.date\",\
		\"weight\": 1825,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.name\",\
		\"weight\": 1826,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact\",\
		\"weight\": 1827,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.id\",\
		\"weight\": 1828,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact.extension\",\
		\"weight\": 1829,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.modifierExtension\",\
		\"weight\": 1830,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.name\",\
		\"weight\": 1831,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact.telecom\",\
		\"weight\": 1832,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.useContext\",\
		\"weight\": 1833,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.copyright\",\
		\"weight\": 1834,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.stringency\",\
		\"weight\": 1835,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping\",\
		\"weight\": 1836,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.id\",\
		\"weight\": 1837,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.extension\",\
		\"weight\": 1838,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.modifierExtension\",\
		\"weight\": 1839,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.identity\",\
		\"weight\": 1840,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.uri\",\
		\"weight\": 1841,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.name\",\
		\"weight\": 1842,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.comment\",\
		\"weight\": 1843,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.element\",\
		\"weight\": 1844,\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule\",\
		\"weight\": 1845,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.id\",\
		\"weight\": 1846,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.meta\",\
		\"weight\": 1847,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.implicitRules\",\
		\"weight\": 1848,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.language\",\
		\"weight\": 1849,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.text\",\
		\"weight\": 1850,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.contained\",\
		\"weight\": 1851,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.extension\",\
		\"weight\": 1852,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.modifierExtension\",\
		\"weight\": 1853,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.url\",\
		\"weight\": 1854,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.identifier\",\
		\"weight\": 1855,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.version\",\
		\"weight\": 1856,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.name\",\
		\"weight\": 1857,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.title\",\
		\"weight\": 1858,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.status\",\
		\"weight\": 1859,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.experimental\",\
		\"weight\": 1860,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.description\",\
		\"weight\": 1861,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.purpose\",\
		\"weight\": 1862,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.usage\",\
		\"weight\": 1863,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.publicationDate\",\
		\"weight\": 1864,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.lastReviewDate\",\
		\"weight\": 1865,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.effectivePeriod\",\
		\"weight\": 1866,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.coverage\",\
		\"weight\": 1867,\
		\"type\": \"UsageContext\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.topic\",\
		\"weight\": 1868,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.contributor\",\
		\"weight\": 1869,\
		\"type\": \"Contributor\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.publisher\",\
		\"weight\": 1870,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.contact\",\
		\"weight\": 1871,\
		\"type\": \"ContactDetail\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.copyright\",\
		\"weight\": 1872,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.relatedResource\",\
		\"weight\": 1873,\
		\"type\": \"RelatedResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.trigger\",\
		\"weight\": 1874,\
		\"type\": \"TriggerDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.parameter\",\
		\"weight\": 1875,\
		\"type\": \"ParameterDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.dataRequirement\",\
		\"weight\": 1876,\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue\",\
		\"weight\": 1877,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.id\",\
		\"weight\": 1878,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.meta\",\
		\"weight\": 1879,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.implicitRules\",\
		\"weight\": 1880,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.language\",\
		\"weight\": 1881,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.text\",\
		\"weight\": 1882,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.contained\",\
		\"weight\": 1883,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.extension\",\
		\"weight\": 1884,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.modifierExtension\",\
		\"weight\": 1885,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.patient\",\
		\"weight\": 1886,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.category\",\
		\"weight\": 1887,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.severity\",\
		\"weight\": 1888,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.implicated\",\
		\"weight\": 1889,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.detail\",\
		\"weight\": 1890,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.date\",\
		\"weight\": 1891,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.author\",\
		\"weight\": 1892,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.identifier\",\
		\"weight\": 1893,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.reference\",\
		\"weight\": 1894,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation\",\
		\"weight\": 1895,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.id\",\
		\"weight\": 1896,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.extension\",\
		\"weight\": 1897,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.modifierExtension\",\
		\"weight\": 1898,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.action\",\
		\"weight\": 1899,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.date\",\
		\"weight\": 1900,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.author\",\
		\"weight\": 1901,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device\",\
		\"weight\": 1902,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.id\",\
		\"weight\": 1903,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.meta\",\
		\"weight\": 1904,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.implicitRules\",\
		\"weight\": 1905,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.language\",\
		\"weight\": 1906,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.text\",\
		\"weight\": 1907,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.contained\",\
		\"weight\": 1908,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.extension\",\
		\"weight\": 1909,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.modifierExtension\",\
		\"weight\": 1910,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.identifier\",\
		\"weight\": 1911,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.udiCarrier\",\
		\"weight\": 1912,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.status\",\
		\"weight\": 1913,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.type\",\
		\"weight\": 1914,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.lotNumber\",\
		\"weight\": 1915,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.manufacturer\",\
		\"weight\": 1916,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.manufactureDate\",\
		\"weight\": 1917,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.expirationDate\",\
		\"weight\": 1918,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.model\",\
		\"weight\": 1919,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.version\",\
		\"weight\": 1920,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.patient\",\
		\"weight\": 1921,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.owner\",\
		\"weight\": 1922,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.contact\",\
		\"weight\": 1923,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.location\",\
		\"weight\": 1924,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.url\",\
		\"weight\": 1925,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.note\",\
		\"weight\": 1926,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent\",\
		\"weight\": 1927,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.id\",\
		\"weight\": 1928,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.meta\",\
		\"weight\": 1929,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.implicitRules\",\
		\"weight\": 1930,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.language\",\
		\"weight\": 1931,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.text\",\
		\"weight\": 1932,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.contained\",\
		\"weight\": 1933,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.extension\",\
		\"weight\": 1934,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.modifierExtension\",\
		\"weight\": 1935,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.type\",\
		\"weight\": 1936,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.identifier\",\
		\"weight\": 1937,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.lastSystemChange\",\
		\"weight\": 1938,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.source\",\
		\"weight\": 1939,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.parent\",\
		\"weight\": 1940,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.operationalStatus\",\
		\"weight\": 1941,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.parameterGroup\",\
		\"weight\": 1942,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.measurementPrinciple\",\
		\"weight\": 1943,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification\",\
		\"weight\": 1944,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.id\",\
		\"weight\": 1945,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.extension\",\
		\"weight\": 1946,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.modifierExtension\",\
		\"weight\": 1947,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.specType\",\
		\"weight\": 1948,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.componentId\",\
		\"weight\": 1949,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.productionSpec\",\
		\"weight\": 1950,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.languageCode\",\
		\"weight\": 1951,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric\",\
		\"weight\": 1952,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.id\",\
		\"weight\": 1953,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.meta\",\
		\"weight\": 1954,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.implicitRules\",\
		\"weight\": 1955,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.language\",\
		\"weight\": 1956,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.text\",\
		\"weight\": 1957,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.contained\",\
		\"weight\": 1958,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.extension\",\
		\"weight\": 1959,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.modifierExtension\",\
		\"weight\": 1960,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.type\",\
		\"weight\": 1961,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.identifier\",\
		\"weight\": 1962,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.unit\",\
		\"weight\": 1963,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.source\",\
		\"weight\": 1964,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.parent\",\
		\"weight\": 1965,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.operationalStatus\",\
		\"weight\": 1966,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.color\",\
		\"weight\": 1967,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.category\",\
		\"weight\": 1968,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.measurementPeriod\",\
		\"weight\": 1969,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration\",\
		\"weight\": 1970,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.id\",\
		\"weight\": 1971,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.extension\",\
		\"weight\": 1972,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.modifierExtension\",\
		\"weight\": 1973,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.type\",\
		\"weight\": 1974,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.state\",\
		\"weight\": 1975,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.time\",\
		\"weight\": 1976,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest\",\
		\"weight\": 1977,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.id\",\
		\"weight\": 1978,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.meta\",\
		\"weight\": 1979,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.implicitRules\",\
		\"weight\": 1980,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.language\",\
		\"weight\": 1981,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.text\",\
		\"weight\": 1982,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.contained\",\
		\"weight\": 1983,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.extension\",\
		\"weight\": 1984,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.modifierExtension\",\
		\"weight\": 1985,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.identifier\",\
		\"weight\": 1986,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.definition\",\
		\"weight\": 1987,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.basedOn\",\
		\"weight\": 1988,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.replaces\",\
		\"weight\": 1989,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.requisition\",\
		\"weight\": 1990,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.status\",\
		\"weight\": 1991,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.stage\",\
		\"weight\": 1992,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.deviceReference\",\
		\"weight\": 1993,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.deviceCodeableConcept\",\
		\"weight\": 1993,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.subject\",\
		\"weight\": 1994,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.context\",\
		\"weight\": 1995,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.occurrenceDateTime\",\
		\"weight\": 1996,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.occurrencePeriod\",\
		\"weight\": 1996,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.occurrenceTiming\",\
		\"weight\": 1996,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.authored\",\
		\"weight\": 1997,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.requester\",\
		\"weight\": 1998,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.performerType\",\
		\"weight\": 1999,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.performer\",\
		\"weight\": 2000,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.reasonCode\",\
		\"weight\": 2001,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.reasonReference\",\
		\"weight\": 2002,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.supportingInfo\",\
		\"weight\": 2003,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.note\",\
		\"weight\": 2004,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.relevantHistory\",\
		\"weight\": 2005,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement\",\
		\"weight\": 2006,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.id\",\
		\"weight\": 2007,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.meta\",\
		\"weight\": 2008,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.implicitRules\",\
		\"weight\": 2009,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.language\",\
		\"weight\": 2010,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.text\",\
		\"weight\": 2011,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.contained\",\
		\"weight\": 2012,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.extension\",\
		\"weight\": 2013,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.modifierExtension\",\
		\"weight\": 2014,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.bodySiteCodeableConcept\",\
		\"weight\": 2015,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.bodySiteReference\",\
		\"weight\": 2015,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.whenUsed\",\
		\"weight\": 2016,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.device\",\
		\"weight\": 2017,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.identifier\",\
		\"weight\": 2018,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.indication\",\
		\"weight\": 2019,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.notes\",\
		\"weight\": 2020,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.recordedOn\",\
		\"weight\": 2021,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.subject\",\
		\"weight\": 2022,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingTiming\",\
		\"weight\": 2023,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingPeriod\",\
		\"weight\": 2023,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingDateTime\",\
		\"weight\": 2023,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport\",\
		\"weight\": 2024,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.id\",\
		\"weight\": 2025,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.meta\",\
		\"weight\": 2026,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.implicitRules\",\
		\"weight\": 2027,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.language\",\
		\"weight\": 2028,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.text\",\
		\"weight\": 2029,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.contained\",\
		\"weight\": 2030,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.extension\",\
		\"weight\": 2031,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.modifierExtension\",\
		\"weight\": 2032,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.identifier\",\
		\"weight\": 2033,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.status\",\
		\"weight\": 2034,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.category\",\
		\"weight\": 2035,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.code\",\
		\"weight\": 2036,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.subject\",\
		\"weight\": 2037,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.encounter\",\
		\"weight\": 2038,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.effectiveDateTime\",\
		\"weight\": 2039,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.effectivePeriod\",\
		\"weight\": 2039,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.issued\",\
		\"weight\": 2040,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.performer\",\
		\"weight\": 2041,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.request\",\
		\"weight\": 2042,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.specimen\",\
		\"weight\": 2043,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.result\",\
		\"weight\": 2044,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.imagingStudy\",\
		\"weight\": 2045,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image\",\
		\"weight\": 2046,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.id\",\
		\"weight\": 2047,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.extension\",\
		\"weight\": 2048,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.modifierExtension\",\
		\"weight\": 2049,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.comment\",\
		\"weight\": 2050,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.link\",\
		\"weight\": 2051,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.conclusion\",\
		\"weight\": 2052,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.codedDiagnosis\",\
		\"weight\": 2053,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.presentedForm\",\
		\"weight\": 2054,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest\",\
		\"weight\": 2055,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.id\",\
		\"weight\": 2056,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.meta\",\
		\"weight\": 2057,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.implicitRules\",\
		\"weight\": 2058,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.language\",\
		\"weight\": 2059,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.text\",\
		\"weight\": 2060,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.contained\",\
		\"weight\": 2061,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.extension\",\
		\"weight\": 2062,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.modifierExtension\",\
		\"weight\": 2063,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.identifier\",\
		\"weight\": 2064,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.definition\",\
		\"weight\": 2065,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.basedOn\",\
		\"weight\": 2066,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.replaces\",\
		\"weight\": 2067,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.requisition\",\
		\"weight\": 2068,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.status\",\
		\"weight\": 2069,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.stage\",\
		\"weight\": 2070,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.code\",\
		\"weight\": 2071,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.subject\",\
		\"weight\": 2072,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.context\",\
		\"weight\": 2073,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.occurrenceDateTime\",\
		\"weight\": 2074,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.occurrencePeriod\",\
		\"weight\": 2074,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.occurrenceTiming\",\
		\"weight\": 2074,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.authored\",\
		\"weight\": 2075,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.requester\",\
		\"weight\": 2076,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.performerType\",\
		\"weight\": 2077,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.performer\",\
		\"weight\": 2078,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.reason\",\
		\"weight\": 2079,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.supportingInformation\",\
		\"weight\": 2080,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.note\",\
		\"weight\": 2081,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticRequest.relevantHistory\",\
		\"weight\": 2082,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest\",\
		\"weight\": 2083,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.id\",\
		\"weight\": 2084,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.meta\",\
		\"weight\": 2085,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.implicitRules\",\
		\"weight\": 2086,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.language\",\
		\"weight\": 2087,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.text\",\
		\"weight\": 2088,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.contained\",\
		\"weight\": 2089,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.extension\",\
		\"weight\": 2090,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.modifierExtension\",\
		\"weight\": 2091,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.masterIdentifier\",\
		\"weight\": 2092,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.identifier\",\
		\"weight\": 2093,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.subject\",\
		\"weight\": 2094,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.recipient\",\
		\"weight\": 2095,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.type\",\
		\"weight\": 2096,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.author\",\
		\"weight\": 2097,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.created\",\
		\"weight\": 2098,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.source\",\
		\"weight\": 2099,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.status\",\
		\"weight\": 2100,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.description\",\
		\"weight\": 2101,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.content\",\
		\"weight\": 2102,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.id\",\
		\"weight\": 2103,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.extension\",\
		\"weight\": 2104,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.modifierExtension\",\
		\"weight\": 2105,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.pAttachment\",\
		\"weight\": 2106,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.pReference\",\
		\"weight\": 2106,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.related\",\
		\"weight\": 2107,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.id\",\
		\"weight\": 2108,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.extension\",\
		\"weight\": 2109,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.modifierExtension\",\
		\"weight\": 2110,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.identifier\",\
		\"weight\": 2111,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.ref\",\
		\"weight\": 2112,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference\",\
		\"weight\": 2113,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.id\",\
		\"weight\": 2114,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.meta\",\
		\"weight\": 2115,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.implicitRules\",\
		\"weight\": 2116,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.language\",\
		\"weight\": 2117,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.text\",\
		\"weight\": 2118,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.contained\",\
		\"weight\": 2119,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.extension\",\
		\"weight\": 2120,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.modifierExtension\",\
		\"weight\": 2121,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.masterIdentifier\",\
		\"weight\": 2122,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.identifier\",\
		\"weight\": 2123,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.subject\",\
		\"weight\": 2124,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.type\",\
		\"weight\": 2125,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.class\",\
		\"weight\": 2126,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.author\",\
		\"weight\": 2127,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.custodian\",\
		\"weight\": 2128,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.authenticator\",\
		\"weight\": 2129,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.created\",\
		\"weight\": 2130,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.indexed\",\
		\"weight\": 2131,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.status\",\
		\"weight\": 2132,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.docStatus\",\
		\"weight\": 2133,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo\",\
		\"weight\": 2134,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.id\",\
		\"weight\": 2135,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.extension\",\
		\"weight\": 2136,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.modifierExtension\",\
		\"weight\": 2137,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.code\",\
		\"weight\": 2138,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.target\",\
		\"weight\": 2139,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.description\",\
		\"weight\": 2140,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.securityLabel\",\
		\"weight\": 2141,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content\",\
		\"weight\": 2142,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.id\",\
		\"weight\": 2143,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.content.extension\",\
		\"weight\": 2144,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.modifierExtension\",\
		\"weight\": 2145,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.attachment\",\
		\"weight\": 2146,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.content.format\",\
		\"weight\": 2147,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context\",\
		\"weight\": 2148,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.id\",\
		\"weight\": 2149,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.extension\",\
		\"weight\": 2150,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.modifierExtension\",\
		\"weight\": 2151,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.encounter\",\
		\"weight\": 2152,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.event\",\
		\"weight\": 2153,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.period\",\
		\"weight\": 2154,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.facilityType\",\
		\"weight\": 2155,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.practiceSetting\",\
		\"weight\": 2156,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.sourcePatientInfo\",\
		\"weight\": 2157,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related\",\
		\"weight\": 2158,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.id\",\
		\"weight\": 2159,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.extension\",\
		\"weight\": 2160,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.modifierExtension\",\
		\"weight\": 2161,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.identifier\",\
		\"weight\": 2162,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.ref\",\
		\"weight\": 2163,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest\",\
		\"weight\": 2164,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.id\",\
		\"weight\": 2165,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.meta\",\
		\"weight\": 2166,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.implicitRules\",\
		\"weight\": 2167,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.language\",\
		\"weight\": 2168,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.text\",\
		\"weight\": 2169,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.contained\",\
		\"weight\": 2170,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.extension\",\
		\"weight\": 2171,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.modifierExtension\",\
		\"weight\": 2172,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.identifier\",\
		\"weight\": 2173,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.status\",\
		\"weight\": 2174,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.ruleset\",\
		\"weight\": 2175,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.originalRuleset\",\
		\"weight\": 2176,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.created\",\
		\"weight\": 2177,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.insurerIdentifier\",\
		\"weight\": 2178,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.insurerReference\",\
		\"weight\": 2178,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.providerIdentifier\",\
		\"weight\": 2179,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.providerReference\",\
		\"weight\": 2179,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.organizationIdentifier\",\
		\"weight\": 2180,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.organizationReference\",\
		\"weight\": 2180,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.priority\",\
		\"weight\": 2181,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.entererIdentifier\",\
		\"weight\": 2182,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.entererReference\",\
		\"weight\": 2182,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.facilityIdentifier\",\
		\"weight\": 2183,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.facilityReference\",\
		\"weight\": 2183,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.patientIdentifier\",\
		\"weight\": 2184,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.patientReference\",\
		\"weight\": 2184,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.coverageIdentifier\",\
		\"weight\": 2185,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.coverageReference\",\
		\"weight\": 2185,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.businessArrangement\",\
		\"weight\": 2186,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.servicedDate\",\
		\"weight\": 2187,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.servicedPeriod\",\
		\"weight\": 2187,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.benefitCategory\",\
		\"weight\": 2188,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.benefitSubCategory\",\
		\"weight\": 2189,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse\",\
		\"weight\": 2190,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.id\",\
		\"weight\": 2191,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.meta\",\
		\"weight\": 2192,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.implicitRules\",\
		\"weight\": 2193,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.language\",\
		\"weight\": 2194,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.text\",\
		\"weight\": 2195,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.contained\",\
		\"weight\": 2196,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.extension\",\
		\"weight\": 2197,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.modifierExtension\",\
		\"weight\": 2198,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.identifier\",\
		\"weight\": 2199,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.status\",\
		\"weight\": 2200,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestIdentifier\",\
		\"weight\": 2201,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestReference\",\
		\"weight\": 2201,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.outcome\",\
		\"weight\": 2202,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.disposition\",\
		\"weight\": 2203,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.ruleset\",\
		\"weight\": 2204,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.originalRuleset\",\
		\"weight\": 2205,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.created\",\
		\"weight\": 2206,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.organizationIdentifier\",\
		\"weight\": 2207,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.organizationReference\",\
		\"weight\": 2207,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestProviderIdentifier\",\
		\"weight\": 2208,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestProviderReference\",\
		\"weight\": 2208,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestOrganizationIdentifier\",\
		\"weight\": 2209,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestOrganizationReference\",\
		\"weight\": 2209,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.inforce\",\
		\"weight\": 2210,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.contract\",\
		\"weight\": 2211,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.form\",\
		\"weight\": 2212,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance\",\
		\"weight\": 2213,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.id\",\
		\"weight\": 2214,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.extension\",\
		\"weight\": 2215,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.modifierExtension\",\
		\"weight\": 2216,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.category\",\
		\"weight\": 2217,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.subCategory\",\
		\"weight\": 2218,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.name\",\
		\"weight\": 2219,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.description\",\
		\"weight\": 2220,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.network\",\
		\"weight\": 2221,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.unit\",\
		\"weight\": 2222,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.term\",\
		\"weight\": 2223,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial\",\
		\"weight\": 2224,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.id\",\
		\"weight\": 2225,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.extension\",\
		\"weight\": 2226,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.modifierExtension\",\
		\"weight\": 2227,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.type\",\
		\"weight\": 2228,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUnsignedInt\",\
		\"weight\": 2229,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitString\",\
		\"weight\": 2229,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitMoney\",\
		\"weight\": 2229,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUsedUnsignedInt\",\
		\"weight\": 2230,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUsedMoney\",\
		\"weight\": 2230,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error\",\
		\"weight\": 2231,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.id\",\
		\"weight\": 2232,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.extension\",\
		\"weight\": 2233,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.modifierExtension\",\
		\"weight\": 2234,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.code\",\
		\"weight\": 2235,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter\",\
		\"weight\": 2236,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.id\",\
		\"weight\": 2237,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.meta\",\
		\"weight\": 2238,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.implicitRules\",\
		\"weight\": 2239,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.language\",\
		\"weight\": 2240,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.text\",\
		\"weight\": 2241,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.contained\",\
		\"weight\": 2242,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.extension\",\
		\"weight\": 2243,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.modifierExtension\",\
		\"weight\": 2244,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.identifier\",\
		\"weight\": 2245,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.status\",\
		\"weight\": 2246,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory\",\
		\"weight\": 2247,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.id\",\
		\"weight\": 2248,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.extension\",\
		\"weight\": 2249,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.modifierExtension\",\
		\"weight\": 2250,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.status\",\
		\"weight\": 2251,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.period\",\
		\"weight\": 2252,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.class\",\
		\"weight\": 2253,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.type\",\
		\"weight\": 2254,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.priority\",\
		\"weight\": 2255,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.patient\",\
		\"weight\": 2256,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.episodeOfCare\",\
		\"weight\": 2257,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.incomingReferral\",\
		\"weight\": 2258,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant\",\
		\"weight\": 2259,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.id\",\
		\"weight\": 2260,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.participant.extension\",\
		\"weight\": 2261,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.modifierExtension\",\
		\"weight\": 2262,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.type\",\
		\"weight\": 2263,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.period\",\
		\"weight\": 2264,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.participant.individual\",\
		\"weight\": 2265,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.appointment\",\
		\"weight\": 2266,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.period\",\
		\"weight\": 2267,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.length\",\
		\"weight\": 2268,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.reason\",\
		\"weight\": 2269,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.indication\",\
		\"weight\": 2270,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.account\",\
		\"weight\": 2271,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization\",\
		\"weight\": 2272,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.id\",\
		\"weight\": 2273,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.extension\",\
		\"weight\": 2274,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.modifierExtension\",\
		\"weight\": 2275,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.preAdmissionIdentifier\",\
		\"weight\": 2276,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.origin\",\
		\"weight\": 2277,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.admitSource\",\
		\"weight\": 2278,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.admittingDiagnosis\",\
		\"weight\": 2279,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.reAdmission\",\
		\"weight\": 2280,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dietPreference\",\
		\"weight\": 2281,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.specialCourtesy\",\
		\"weight\": 2282,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.specialArrangement\",\
		\"weight\": 2283,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.destination\",\
		\"weight\": 2284,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dischargeDisposition\",\
		\"weight\": 2285,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dischargeDiagnosis\",\
		\"weight\": 2286,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location\",\
		\"weight\": 2287,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.id\",\
		\"weight\": 2288,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.extension\",\
		\"weight\": 2289,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.modifierExtension\",\
		\"weight\": 2290,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.location\",\
		\"weight\": 2291,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.status\",\
		\"weight\": 2292,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.period\",\
		\"weight\": 2293,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.serviceProvider\",\
		\"weight\": 2294,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.partOf\",\
		\"weight\": 2295,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint\",\
		\"weight\": 2296,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.id\",\
		\"weight\": 2297,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.meta\",\
		\"weight\": 2298,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.implicitRules\",\
		\"weight\": 2299,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.language\",\
		\"weight\": 2300,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.text\",\
		\"weight\": 2301,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.contained\",\
		\"weight\": 2302,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.extension\",\
		\"weight\": 2303,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.modifierExtension\",\
		\"weight\": 2304,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.identifier\",\
		\"weight\": 2305,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.status\",\
		\"weight\": 2306,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.name\",\
		\"weight\": 2307,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.managingOrganization\",\
		\"weight\": 2308,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.contact\",\
		\"weight\": 2309,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.connectionType\",\
		\"weight\": 2310,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.method\",\
		\"weight\": 2311,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.period\",\
		\"weight\": 2312,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.address\",\
		\"weight\": 2313,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.payloadFormat\",\
		\"weight\": 2314,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.payloadType\",\
		\"weight\": 2315,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.header\",\
		\"weight\": 2316,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.publicKey\",\
		\"weight\": 2317,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest\",\
		\"weight\": 2318,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.id\",\
		\"weight\": 2319,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.meta\",\
		\"weight\": 2320,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.implicitRules\",\
		\"weight\": 2321,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.language\",\
		\"weight\": 2322,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.text\",\
		\"weight\": 2323,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.contained\",\
		\"weight\": 2324,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.extension\",\
		\"weight\": 2325,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.modifierExtension\",\
		\"weight\": 2326,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.identifier\",\
		\"weight\": 2327,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.status\",\
		\"weight\": 2328,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.ruleset\",\
		\"weight\": 2329,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.originalRuleset\",\
		\"weight\": 2330,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.created\",\
		\"weight\": 2331,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.insurerIdentifier\",\
		\"weight\": 2332,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.insurerReference\",\
		\"weight\": 2332,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.providerIdentifier\",\
		\"weight\": 2333,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.providerReference\",\
		\"weight\": 2333,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.organizationIdentifier\",\
		\"weight\": 2334,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.organizationReference\",\
		\"weight\": 2334,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.subjectIdentifier\",\
		\"weight\": 2335,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.subjectReference\",\
		\"weight\": 2335,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.coverage\",\
		\"weight\": 2336,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse\",\
		\"weight\": 2337,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.id\",\
		\"weight\": 2338,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.meta\",\
		\"weight\": 2339,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.implicitRules\",\
		\"weight\": 2340,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.language\",\
		\"weight\": 2341,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.text\",\
		\"weight\": 2342,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.contained\",\
		\"weight\": 2343,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.extension\",\
		\"weight\": 2344,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.modifierExtension\",\
		\"weight\": 2345,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.identifier\",\
		\"weight\": 2346,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.status\",\
		\"weight\": 2347,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestIdentifier\",\
		\"weight\": 2348,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestReference\",\
		\"weight\": 2348,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.outcome\",\
		\"weight\": 2349,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.disposition\",\
		\"weight\": 2350,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.ruleset\",\
		\"weight\": 2351,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.originalRuleset\",\
		\"weight\": 2352,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.created\",\
		\"weight\": 2353,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.organizationIdentifier\",\
		\"weight\": 2354,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.organizationReference\",\
		\"weight\": 2354,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestProviderIdentifier\",\
		\"weight\": 2355,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestProviderReference\",\
		\"weight\": 2355,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestOrganizationIdentifier\",\
		\"weight\": 2356,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestOrganizationReference\",\
		\"weight\": 2356,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare\",\
		\"weight\": 2357,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.id\",\
		\"weight\": 2358,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.meta\",\
		\"weight\": 2359,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.implicitRules\",\
		\"weight\": 2360,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.language\",\
		\"weight\": 2361,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.text\",\
		\"weight\": 2362,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.contained\",\
		\"weight\": 2363,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.extension\",\
		\"weight\": 2364,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.modifierExtension\",\
		\"weight\": 2365,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.identifier\",\
		\"weight\": 2366,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.status\",\
		\"weight\": 2367,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory\",\
		\"weight\": 2368,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.id\",\
		\"weight\": 2369,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.extension\",\
		\"weight\": 2370,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.modifierExtension\",\
		\"weight\": 2371,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.status\",\
		\"weight\": 2372,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.period\",\
		\"weight\": 2373,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.type\",\
		\"weight\": 2374,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.condition\",\
		\"weight\": 2375,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.patient\",\
		\"weight\": 2376,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.managingOrganization\",\
		\"weight\": 2377,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.period\",\
		\"weight\": 2378,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.referralRequest\",\
		\"weight\": 2379,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.careManager\",\
		\"weight\": 2380,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.team\",\
		\"weight\": 2381,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.account\",\
		\"weight\": 2382,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile\",\
		\"weight\": 2383,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.id\",\
		\"weight\": 2384,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.meta\",\
		\"weight\": 2385,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.implicitRules\",\
		\"weight\": 2386,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.language\",\
		\"weight\": 2387,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.text\",\
		\"weight\": 2388,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contained\",\
		\"weight\": 2389,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.extension\",\
		\"weight\": 2390,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.modifierExtension\",\
		\"weight\": 2391,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.url\",\
		\"weight\": 2392,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.identifier\",\
		\"weight\": 2393,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.version\",\
		\"weight\": 2394,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.name\",\
		\"weight\": 2395,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.status\",\
		\"weight\": 2396,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.experimental\",\
		\"weight\": 2397,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.publisher\",\
		\"weight\": 2398,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact\",\
		\"weight\": 2399,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.id\",\
		\"weight\": 2400,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.extension\",\
		\"weight\": 2401,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.modifierExtension\",\
		\"weight\": 2402,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.name\",\
		\"weight\": 2403,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.telecom\",\
		\"weight\": 2404,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.date\",\
		\"weight\": 2405,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.description\",\
		\"weight\": 2406,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem\",\
		\"weight\": 2407,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.id\",\
		\"weight\": 2408,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.extension\",\
		\"weight\": 2409,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.modifierExtension\",\
		\"weight\": 2410,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include\",\
		\"weight\": 2411,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.id\",\
		\"weight\": 2412,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.extension\",\
		\"weight\": 2413,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.modifierExtension\",\
		\"weight\": 2414,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem\",\
		\"weight\": 2415,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.id\",\
		\"weight\": 2416,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.extension\",\
		\"weight\": 2417,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.modifierExtension\",\
		\"weight\": 2418,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.system\",\
		\"weight\": 2419,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.version\",\
		\"weight\": 2420,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude\",\
		\"weight\": 2421,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.id\",\
		\"weight\": 2422,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.extension\",\
		\"weight\": 2423,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.modifierExtension\",\
		\"weight\": 2424,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem\",\
		\"weight\": 2425,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.id\",\
		\"weight\": 2426,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.extension\",\
		\"weight\": 2427,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.modifierExtension\",\
		\"weight\": 2428,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.system\",\
		\"weight\": 2429,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.version\",\
		\"weight\": 2430,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeDesignations\",\
		\"weight\": 2431,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation\",\
		\"weight\": 2432,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.id\",\
		\"weight\": 2433,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.extension\",\
		\"weight\": 2434,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.modifierExtension\",\
		\"weight\": 2435,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include\",\
		\"weight\": 2436,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.id\",\
		\"weight\": 2437,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.extension\",\
		\"weight\": 2438,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.modifierExtension\",\
		\"weight\": 2439,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation\",\
		\"weight\": 2440,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.id\",\
		\"weight\": 2441,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.extension\",\
		\"weight\": 2442,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.modifierExtension\",\
		\"weight\": 2443,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.language\",\
		\"weight\": 2444,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.use\",\
		\"weight\": 2445,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude\",\
		\"weight\": 2446,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.id\",\
		\"weight\": 2447,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.extension\",\
		\"weight\": 2448,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.modifierExtension\",\
		\"weight\": 2449,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation\",\
		\"weight\": 2450,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.id\",\
		\"weight\": 2451,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.extension\",\
		\"weight\": 2452,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.modifierExtension\",\
		\"weight\": 2453,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.language\",\
		\"weight\": 2454,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.use\",\
		\"weight\": 2455,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeDefinition\",\
		\"weight\": 2456,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeInactive\",\
		\"weight\": 2457,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludeNested\",\
		\"weight\": 2458,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludeNotForUI\",\
		\"weight\": 2459,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludePostCoordinated\",\
		\"weight\": 2460,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.displayLanguage\",\
		\"weight\": 2461,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.limitedExpansion\",\
		\"weight\": 2462,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit\",\
		\"weight\": 2463,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.id\",\
		\"weight\": 2464,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.meta\",\
		\"weight\": 2465,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.implicitRules\",\
		\"weight\": 2466,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.language\",\
		\"weight\": 2467,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.text\",\
		\"weight\": 2468,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.contained\",\
		\"weight\": 2469,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.extension\",\
		\"weight\": 2470,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.modifierExtension\",\
		\"weight\": 2471,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.identifier\",\
		\"weight\": 2472,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.status\",\
		\"weight\": 2473,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.authorIdentifier\",\
		\"weight\": 2474,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.authorReference\",\
		\"weight\": 2474,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimIdentifier\",\
		\"weight\": 2475,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimReference\",\
		\"weight\": 2475,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimResponseIdentifier\",\
		\"weight\": 2476,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimResponseReference\",\
		\"weight\": 2476,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.type\",\
		\"weight\": 2477,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.subType\",\
		\"weight\": 2478,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.ruleset\",\
		\"weight\": 2479,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalRuleset\",\
		\"weight\": 2480,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.created\",\
		\"weight\": 2481,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.billablePeriod\",\
		\"weight\": 2482,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.outcome\",\
		\"weight\": 2483,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.disposition\",\
		\"weight\": 2484,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.providerIdentifier\",\
		\"weight\": 2485,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.providerReference\",\
		\"weight\": 2485,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.organizationIdentifier\",\
		\"weight\": 2486,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.organizationReference\",\
		\"weight\": 2486,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.facilityIdentifier\",\
		\"weight\": 2487,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.facilityReference\",\
		\"weight\": 2487,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related\",\
		\"weight\": 2488,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.id\",\
		\"weight\": 2489,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.extension\",\
		\"weight\": 2490,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.modifierExtension\",\
		\"weight\": 2491,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.claimIdentifier\",\
		\"weight\": 2492,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.claimReference\",\
		\"weight\": 2492,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.relationship\",\
		\"weight\": 2493,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.reference\",\
		\"weight\": 2494,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionIdentifier\",\
		\"weight\": 2495,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionReference\",\
		\"weight\": 2495,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionReference\",\
		\"weight\": 2495,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalPrescriptionIdentifier\",\
		\"weight\": 2496,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalPrescriptionReference\",\
		\"weight\": 2496,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee\",\
		\"weight\": 2497,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.id\",\
		\"weight\": 2498,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.extension\",\
		\"weight\": 2499,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.modifierExtension\",\
		\"weight\": 2500,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.type\",\
		\"weight\": 2501,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.resourceType\",\
		\"weight\": 2502,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyIdentifier\",\
		\"weight\": 2503,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2503,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2503,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2503,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2503,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.referralIdentifier\",\
		\"weight\": 2504,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.referralReference\",\
		\"weight\": 2504,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information\",\
		\"weight\": 2505,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.id\",\
		\"weight\": 2506,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.extension\",\
		\"weight\": 2507,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.modifierExtension\",\
		\"weight\": 2508,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.category\",\
		\"weight\": 2509,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.code\",\
		\"weight\": 2510,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.timingDate\",\
		\"weight\": 2511,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.timingPeriod\",\
		\"weight\": 2511,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.valueString\",\
		\"weight\": 2512,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.information.valueQuantity\",\
		\"weight\": 2512,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis\",\
		\"weight\": 2513,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.id\",\
		\"weight\": 2514,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.extension\",\
		\"weight\": 2515,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.modifierExtension\",\
		\"weight\": 2516,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.sequence\",\
		\"weight\": 2517,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.diagnosis\",\
		\"weight\": 2518,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.type\",\
		\"weight\": 2519,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.drg\",\
		\"weight\": 2520,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure\",\
		\"weight\": 2521,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.id\",\
		\"weight\": 2522,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.extension\",\
		\"weight\": 2523,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.modifierExtension\",\
		\"weight\": 2524,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.sequence\",\
		\"weight\": 2525,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.date\",\
		\"weight\": 2526,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.procedureCoding\",\
		\"weight\": 2527,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.procedureReference\",\
		\"weight\": 2527,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.patientIdentifier\",\
		\"weight\": 2528,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.patientReference\",\
		\"weight\": 2528,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.precedence\",\
		\"weight\": 2529,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage\",\
		\"weight\": 2530,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.id\",\
		\"weight\": 2531,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.extension\",\
		\"weight\": 2532,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.modifierExtension\",\
		\"weight\": 2533,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.coverageIdentifier\",\
		\"weight\": 2534,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.coverageReference\",\
		\"weight\": 2534,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.preAuthRef\",\
		\"weight\": 2535,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accident\",\
		\"weight\": 2536,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accident.id\",\
		\"weight\": 2537,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accident.extension\",\
		\"weight\": 2538,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accident.modifierExtension\",\
		\"weight\": 2539,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accident.date\",\
		\"weight\": 2540,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accident.type\",\
		\"weight\": 2541,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accident.locationAddress\",\
		\"weight\": 2542,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accident.locationReference\",\
		\"weight\": 2542,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.employmentImpacted\",\
		\"weight\": 2543,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.hospitalization\",\
		\"weight\": 2544,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item\",\
		\"weight\": 2545,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.id\",\
		\"weight\": 2546,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.extension\",\
		\"weight\": 2547,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.modifierExtension\",\
		\"weight\": 2548,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.sequence\",\
		\"weight\": 2549,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam\",\
		\"weight\": 2550,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.id\",\
		\"weight\": 2551,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.extension\",\
		\"weight\": 2552,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.modifierExtension\",\
		\"weight\": 2553,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.providerIdentifier\",\
		\"weight\": 2554,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.providerReference\",\
		\"weight\": 2554,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.providerReference\",\
		\"weight\": 2554,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.responsible\",\
		\"weight\": 2555,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.role\",\
		\"weight\": 2556,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.careTeam.qualification\",\
		\"weight\": 2557,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.diagnosisLinkId\",\
		\"weight\": 2558,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.revenue\",\
		\"weight\": 2559,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.category\",\
		\"weight\": 2560,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.service\",\
		\"weight\": 2561,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.modifier\",\
		\"weight\": 2562,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.programCode\",\
		\"weight\": 2563,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.servicedDate\",\
		\"weight\": 2564,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.servicedPeriod\",\
		\"weight\": 2564,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.locationCoding\",\
		\"weight\": 2565,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.locationAddress\",\
		\"weight\": 2565,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.locationReference\",\
		\"weight\": 2565,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.quantity\",\
		\"weight\": 2566,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.unitPrice\",\
		\"weight\": 2567,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.factor\",\
		\"weight\": 2568,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.points\",\
		\"weight\": 2569,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.net\",\
		\"weight\": 2570,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.udi\",\
		\"weight\": 2571,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.bodySite\",\
		\"weight\": 2572,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.subSite\",\
		\"weight\": 2573,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.noteNumber\",\
		\"weight\": 2574,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication\",\
		\"weight\": 2575,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.id\",\
		\"weight\": 2576,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.extension\",\
		\"weight\": 2577,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.modifierExtension\",\
		\"weight\": 2578,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.category\",\
		\"weight\": 2579,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.reason\",\
		\"weight\": 2580,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.amount\",\
		\"weight\": 2581,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.value\",\
		\"weight\": 2582,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail\",\
		\"weight\": 2583,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.id\",\
		\"weight\": 2584,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.extension\",\
		\"weight\": 2585,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.modifierExtension\",\
		\"weight\": 2586,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.sequence\",\
		\"weight\": 2587,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.type\",\
		\"weight\": 2588,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.revenue\",\
		\"weight\": 2589,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.category\",\
		\"weight\": 2590,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.service\",\
		\"weight\": 2591,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.modifier\",\
		\"weight\": 2592,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.programCode\",\
		\"weight\": 2593,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.quantity\",\
		\"weight\": 2594,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.unitPrice\",\
		\"weight\": 2595,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.factor\",\
		\"weight\": 2596,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.points\",\
		\"weight\": 2597,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.net\",\
		\"weight\": 2598,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.udi\",\
		\"weight\": 2599,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.noteNumber\",\
		\"weight\": 2600,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication\",\
		\"weight\": 2601,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail\",\
		\"weight\": 2602,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.id\",\
		\"weight\": 2603,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.extension\",\
		\"weight\": 2604,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.modifierExtension\",\
		\"weight\": 2605,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.sequence\",\
		\"weight\": 2606,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.type\",\
		\"weight\": 2607,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.revenue\",\
		\"weight\": 2608,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.category\",\
		\"weight\": 2609,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.service\",\
		\"weight\": 2610,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.modifier\",\
		\"weight\": 2611,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.programCode\",\
		\"weight\": 2612,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.quantity\",\
		\"weight\": 2613,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.unitPrice\",\
		\"weight\": 2614,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.factor\",\
		\"weight\": 2615,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.points\",\
		\"weight\": 2616,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.net\",\
		\"weight\": 2617,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.udi\",\
		\"weight\": 2618,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.noteNumber\",\
		\"weight\": 2619,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication\",\
		\"weight\": 2620,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis\",\
		\"weight\": 2621,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.id\",\
		\"weight\": 2622,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.extension\",\
		\"weight\": 2623,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.modifierExtension\",\
		\"weight\": 2624,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.initial\",\
		\"weight\": 2625,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.priorDate\",\
		\"weight\": 2626,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.priorMaterial\",\
		\"weight\": 2627,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem\",\
		\"weight\": 2628,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.id\",\
		\"weight\": 2629,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.extension\",\
		\"weight\": 2630,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.modifierExtension\",\
		\"weight\": 2631,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.sequenceLinkId\",\
		\"weight\": 2632,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.revenue\",\
		\"weight\": 2633,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.category\",\
		\"weight\": 2634,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.service\",\
		\"weight\": 2635,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.modifier\",\
		\"weight\": 2636,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.fee\",\
		\"weight\": 2637,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.noteNumber\",\
		\"weight\": 2638,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication\",\
		\"weight\": 2639,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail\",\
		\"weight\": 2640,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.id\",\
		\"weight\": 2641,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.extension\",\
		\"weight\": 2642,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.modifierExtension\",\
		\"weight\": 2643,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.revenue\",\
		\"weight\": 2644,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.category\",\
		\"weight\": 2645,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.service\",\
		\"weight\": 2646,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.modifier\",\
		\"weight\": 2647,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.fee\",\
		\"weight\": 2648,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.noteNumber\",\
		\"weight\": 2649,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication\",\
		\"weight\": 2650,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth\",\
		\"weight\": 2651,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.id\",\
		\"weight\": 2652,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.extension\",\
		\"weight\": 2653,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.modifierExtension\",\
		\"weight\": 2654,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.tooth\",\
		\"weight\": 2655,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.reason\",\
		\"weight\": 2656,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.extractionDate\",\
		\"weight\": 2657,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.totalCost\",\
		\"weight\": 2658,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.unallocDeductable\",\
		\"weight\": 2659,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.totalBenefit\",\
		\"weight\": 2660,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment\",\
		\"weight\": 2661,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.id\",\
		\"weight\": 2662,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.extension\",\
		\"weight\": 2663,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.modifierExtension\",\
		\"weight\": 2664,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.type\",\
		\"weight\": 2665,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.adjustment\",\
		\"weight\": 2666,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.adjustmentReason\",\
		\"weight\": 2667,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.date\",\
		\"weight\": 2668,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.amount\",\
		\"weight\": 2669,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payment.identifier\",\
		\"weight\": 2670,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.form\",\
		\"weight\": 2671,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note\",\
		\"weight\": 2672,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.id\",\
		\"weight\": 2673,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.extension\",\
		\"weight\": 2674,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.modifierExtension\",\
		\"weight\": 2675,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.number\",\
		\"weight\": 2676,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.type\",\
		\"weight\": 2677,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.text\",\
		\"weight\": 2678,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.language\",\
		\"weight\": 2679,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance\",\
		\"weight\": 2680,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.id\",\
		\"weight\": 2681,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.extension\",\
		\"weight\": 2682,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.modifierExtension\",\
		\"weight\": 2683,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.category\",\
		\"weight\": 2684,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.subCategory\",\
		\"weight\": 2685,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.name\",\
		\"weight\": 2686,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.description\",\
		\"weight\": 2687,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.network\",\
		\"weight\": 2688,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.unit\",\
		\"weight\": 2689,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.term\",\
		\"weight\": 2690,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial\",\
		\"weight\": 2691,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.id\",\
		\"weight\": 2692,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.extension\",\
		\"weight\": 2693,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.modifierExtension\",\
		\"weight\": 2694,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.type\",\
		\"weight\": 2695,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUnsignedInt\",\
		\"weight\": 2696,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitString\",\
		\"weight\": 2696,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitMoney\",\
		\"weight\": 2696,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUsedUnsignedInt\",\
		\"weight\": 2697,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUsedMoney\",\
		\"weight\": 2697,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory\",\
		\"weight\": 2698,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.id\",\
		\"weight\": 2699,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.meta\",\
		\"weight\": 2700,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.implicitRules\",\
		\"weight\": 2701,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.language\",\
		\"weight\": 2702,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.text\",\
		\"weight\": 2703,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.contained\",\
		\"weight\": 2704,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.extension\",\
		\"weight\": 2705,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.modifierExtension\",\
		\"weight\": 2706,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.identifier\",\
		\"weight\": 2707,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.patient\",\
		\"weight\": 2708,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.date\",\
		\"weight\": 2709,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.status\",\
		\"weight\": 2710,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.name\",\
		\"weight\": 2711,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.relationship\",\
		\"weight\": 2712,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.gender\",\
		\"weight\": 2713,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornPeriod\",\
		\"weight\": 2714,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornDate\",\
		\"weight\": 2714,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornString\",\
		\"weight\": 2714,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageAge\",\
		\"weight\": 2715,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageRange\",\
		\"weight\": 2715,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageString\",\
		\"weight\": 2715,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.estimatedAge\",\
		\"weight\": 2716,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedBoolean\",\
		\"weight\": 2717,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedAge\",\
		\"weight\": 2717,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedRange\",\
		\"weight\": 2717,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedDate\",\
		\"weight\": 2717,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedString\",\
		\"weight\": 2717,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.note\",\
		\"weight\": 2718,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition\",\
		\"weight\": 2719,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.id\",\
		\"weight\": 2720,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.extension\",\
		\"weight\": 2721,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.modifierExtension\",\
		\"weight\": 2722,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.code\",\
		\"weight\": 2723,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.outcome\",\
		\"weight\": 2724,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetAge\",\
		\"weight\": 2725,\
		\"type\": \"Age\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetRange\",\
		\"weight\": 2725,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetPeriod\",\
		\"weight\": 2725,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetString\",\
		\"weight\": 2725,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.note\",\
		\"weight\": 2726,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag\",\
		\"weight\": 2727,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.id\",\
		\"weight\": 2728,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.meta\",\
		\"weight\": 2729,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.implicitRules\",\
		\"weight\": 2730,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.language\",\
		\"weight\": 2731,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.text\",\
		\"weight\": 2732,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.contained\",\
		\"weight\": 2733,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.extension\",\
		\"weight\": 2734,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.modifierExtension\",\
		\"weight\": 2735,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.identifier\",\
		\"weight\": 2736,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.category\",\
		\"weight\": 2737,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.status\",\
		\"weight\": 2738,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.period\",\
		\"weight\": 2739,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.subject\",\
		\"weight\": 2740,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.encounter\",\
		\"weight\": 2741,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.author\",\
		\"weight\": 2742,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.code\",\
		\"weight\": 2743,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal\",\
		\"weight\": 2744,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.id\",\
		\"weight\": 2745,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.meta\",\
		\"weight\": 2746,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.implicitRules\",\
		\"weight\": 2747,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.language\",\
		\"weight\": 2748,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.text\",\
		\"weight\": 2749,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.contained\",\
		\"weight\": 2750,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.extension\",\
		\"weight\": 2751,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.modifierExtension\",\
		\"weight\": 2752,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.identifier\",\
		\"weight\": 2753,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.subject\",\
		\"weight\": 2754,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.startDate\",\
		\"weight\": 2755,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.startCodeableConcept\",\
		\"weight\": 2755,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.targetDate\",\
		\"weight\": 2756,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.targetDuration\",\
		\"weight\": 2756,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.category\",\
		\"weight\": 2757,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.description\",\
		\"weight\": 2758,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.status\",\
		\"weight\": 2759,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.statusDate\",\
		\"weight\": 2760,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.statusReason\",\
		\"weight\": 2761,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.expressedBy\",\
		\"weight\": 2762,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.priority\",\
		\"weight\": 2763,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.addresses\",\
		\"weight\": 2764,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.note\",\
		\"weight\": 2765,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome\",\
		\"weight\": 2766,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.id\",\
		\"weight\": 2767,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.outcome.extension\",\
		\"weight\": 2768,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.modifierExtension\",\
		\"weight\": 2769,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.resultCodeableConcept\",\
		\"weight\": 2770,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.outcome.resultReference\",\
		\"weight\": 2770,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group\",\
		\"weight\": 2771,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.id\",\
		\"weight\": 2772,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.meta\",\
		\"weight\": 2773,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.implicitRules\",\
		\"weight\": 2774,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.language\",\
		\"weight\": 2775,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.text\",\
		\"weight\": 2776,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.contained\",\
		\"weight\": 2777,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.extension\",\
		\"weight\": 2778,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.modifierExtension\",\
		\"weight\": 2779,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.identifier\",\
		\"weight\": 2780,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.type\",\
		\"weight\": 2781,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.actual\",\
		\"weight\": 2782,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.active\",\
		\"weight\": 2783,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.code\",\
		\"weight\": 2784,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.name\",\
		\"weight\": 2785,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.quantity\",\
		\"weight\": 2786,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic\",\
		\"weight\": 2787,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.id\",\
		\"weight\": 2788,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.extension\",\
		\"weight\": 2789,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.modifierExtension\",\
		\"weight\": 2790,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.code\",\
		\"weight\": 2791,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueCodeableConcept\",\
		\"weight\": 2792,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueBoolean\",\
		\"weight\": 2792,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueQuantity\",\
		\"weight\": 2792,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueRange\",\
		\"weight\": 2792,\
		\"type\": \"Range\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.exclude\",\
		\"weight\": 2793,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.period\",\
		\"weight\": 2794,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member\",\
		\"weight\": 2795,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.id\",\
		\"weight\": 2796,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.extension\",\
		\"weight\": 2797,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.modifierExtension\",\
		\"weight\": 2798,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.entity\",\
		\"weight\": 2799,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.period\",\
		\"weight\": 2800,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.inactive\",\
		\"weight\": 2801,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse\",\
		\"weight\": 2802,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.id\",\
		\"weight\": 2803,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.meta\",\
		\"weight\": 2804,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.implicitRules\",\
		\"weight\": 2805,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.language\",\
		\"weight\": 2806,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.text\",\
		\"weight\": 2807,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.contained\",\
		\"weight\": 2808,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.extension\",\
		\"weight\": 2809,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.modifierExtension\",\
		\"weight\": 2810,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.requestId\",\
		\"weight\": 2811,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.identifier\",\
		\"weight\": 2812,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.module\",\
		\"weight\": 2813,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.status\",\
		\"weight\": 2814,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.subject\",\
		\"weight\": 2815,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.context\",\
		\"weight\": 2816,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.occurrenceDateTime\",\
		\"weight\": 2817,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.performer\",\
		\"weight\": 2818,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.reasonCodeableConcept\",\
		\"weight\": 2819,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.reasonReference\",\
		\"weight\": 2819,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.note\",\
		\"weight\": 2820,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.evaluationMessage\",\
		\"weight\": 2821,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.outputParameters\",\
		\"weight\": 2822,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action\",\
		\"weight\": 2823,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.id\",\
		\"weight\": 2824,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.extension\",\
		\"weight\": 2825,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.modifierExtension\",\
		\"weight\": 2826,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.actionIdentifier\",\
		\"weight\": 2827,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.label\",\
		\"weight\": 2828,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.title\",\
		\"weight\": 2829,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.description\",\
		\"weight\": 2830,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.textEquivalent\",\
		\"weight\": 2831,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.concept\",\
		\"weight\": 2832,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.documentation\",\
		\"weight\": 2833,\
		\"type\": \"RelatedResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction\",\
		\"weight\": 2834,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.id\",\
		\"weight\": 2835,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.extension\",\
		\"weight\": 2836,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.modifierExtension\",\
		\"weight\": 2837,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.actionIdentifier\",\
		\"weight\": 2838,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.relationship\",\
		\"weight\": 2839,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.offsetDuration\",\
		\"weight\": 2840,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.offsetRange\",\
		\"weight\": 2840,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.anchor\",\
		\"weight\": 2841,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.timingDateTime\",\
		\"weight\": 2842,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.timingPeriod\",\
		\"weight\": 2842,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.timingDuration\",\
		\"weight\": 2842,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.timingRange\",\
		\"weight\": 2842,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.participant\",\
		\"weight\": 2843,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.type\",\
		\"weight\": 2844,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.groupingBehavior\",\
		\"weight\": 2845,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.selectionBehavior\",\
		\"weight\": 2846,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.requiredBehavior\",\
		\"weight\": 2847,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.precheckBehavior\",\
		\"weight\": 2848,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.cardinalityBehavior\",\
		\"weight\": 2849,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.resource\",\
		\"weight\": 2850,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.action\",\
		\"weight\": 2851,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.dataRequirement\",\
		\"weight\": 2852,\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService\",\
		\"weight\": 2853,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.id\",\
		\"weight\": 2854,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.meta\",\
		\"weight\": 2855,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.implicitRules\",\
		\"weight\": 2856,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.language\",\
		\"weight\": 2857,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.text\",\
		\"weight\": 2858,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.contained\",\
		\"weight\": 2859,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.extension\",\
		\"weight\": 2860,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.modifierExtension\",\
		\"weight\": 2861,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.identifier\",\
		\"weight\": 2862,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.active\",\
		\"weight\": 2863,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.providedBy\",\
		\"weight\": 2864,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceCategory\",\
		\"weight\": 2865,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceType\",\
		\"weight\": 2866,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.specialty\",\
		\"weight\": 2867,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.location\",\
		\"weight\": 2868,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceName\",\
		\"weight\": 2869,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.comment\",\
		\"weight\": 2870,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.extraDetails\",\
		\"weight\": 2871,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.photo\",\
		\"weight\": 2872,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.telecom\",\
		\"weight\": 2873,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.coverageArea\",\
		\"weight\": 2874,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceProvisionCode\",\
		\"weight\": 2875,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.eligibility\",\
		\"weight\": 2876,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.eligibilityNote\",\
		\"weight\": 2877,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.programName\",\
		\"weight\": 2878,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.characteristic\",\
		\"weight\": 2879,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.referralMethod\",\
		\"weight\": 2880,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.publicKey\",\
		\"weight\": 2881,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.appointmentRequired\",\
		\"weight\": 2882,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime\",\
		\"weight\": 2883,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.id\",\
		\"weight\": 2884,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.extension\",\
		\"weight\": 2885,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.modifierExtension\",\
		\"weight\": 2886,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.daysOfWeek\",\
		\"weight\": 2887,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.allDay\",\
		\"weight\": 2888,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.availableStartTime\",\
		\"weight\": 2889,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.availableEndTime\",\
		\"weight\": 2890,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable\",\
		\"weight\": 2891,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.id\",\
		\"weight\": 2892,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.extension\",\
		\"weight\": 2893,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.modifierExtension\",\
		\"weight\": 2894,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.description\",\
		\"weight\": 2895,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.during\",\
		\"weight\": 2896,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availabilityExceptions\",\
		\"weight\": 2897,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest\",\
		\"weight\": 2898,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.id\",\
		\"weight\": 2899,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.meta\",\
		\"weight\": 2900,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.implicitRules\",\
		\"weight\": 2901,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.language\",\
		\"weight\": 2902,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.text\",\
		\"weight\": 2903,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.contained\",\
		\"weight\": 2904,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.extension\",\
		\"weight\": 2905,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.modifierExtension\",\
		\"weight\": 2906,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.uid\",\
		\"weight\": 2907,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.patient\",\
		\"weight\": 2908,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.authoringTime\",\
		\"weight\": 2909,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.author\",\
		\"weight\": 2910,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.title\",\
		\"weight\": 2911,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.description\",\
		\"weight\": 2912,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study\",\
		\"weight\": 2913,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.id\",\
		\"weight\": 2914,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.extension\",\
		\"weight\": 2915,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.modifierExtension\",\
		\"weight\": 2916,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.uid\",\
		\"weight\": 2917,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.imagingStudy\",\
		\"weight\": 2918,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.baseLocation\",\
		\"weight\": 2919,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.baseLocation.id\",\
		\"weight\": 2920,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.baseLocation.extension\",\
		\"weight\": 2921,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.baseLocation.modifierExtension\",\
		\"weight\": 2922,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.baseLocation.type\",\
		\"weight\": 2923,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.baseLocation.url\",\
		\"weight\": 2924,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series\",\
		\"weight\": 2925,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.id\",\
		\"weight\": 2926,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.extension\",\
		\"weight\": 2927,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.modifierExtension\",\
		\"weight\": 2928,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.uid\",\
		\"weight\": 2929,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.baseLocation\",\
		\"weight\": 2930,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.baseLocation.id\",\
		\"weight\": 2931,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.baseLocation.extension\",\
		\"weight\": 2932,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.baseLocation.modifierExtension\",\
		\"weight\": 2933,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.baseLocation.type\",\
		\"weight\": 2934,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.baseLocation.url\",\
		\"weight\": 2935,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.instance\",\
		\"weight\": 2936,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.instance.id\",\
		\"weight\": 2937,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.instance.extension\",\
		\"weight\": 2938,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.instance.modifierExtension\",\
		\"weight\": 2939,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.instance.sopClass\",\
		\"weight\": 2940,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingManifest.study.series.instance.uid\",\
		\"weight\": 2941,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy\",\
		\"weight\": 2942,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.id\",\
		\"weight\": 2943,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.meta\",\
		\"weight\": 2944,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.implicitRules\",\
		\"weight\": 2945,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.language\",\
		\"weight\": 2946,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.text\",\
		\"weight\": 2947,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.contained\",\
		\"weight\": 2948,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.extension\",\
		\"weight\": 2949,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.modifierExtension\",\
		\"weight\": 2950,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.uid\",\
		\"weight\": 2951,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.accession\",\
		\"weight\": 2952,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.identifier\",\
		\"weight\": 2953,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.availability\",\
		\"weight\": 2954,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.modalityList\",\
		\"weight\": 2955,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.patient\",\
		\"weight\": 2956,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.context\",\
		\"weight\": 2957,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.started\",\
		\"weight\": 2958,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.basedOn\",\
		\"weight\": 2959,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.referrer\",\
		\"weight\": 2960,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.interpreter\",\
		\"weight\": 2961,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.baseLocation\",\
		\"weight\": 2962,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.baseLocation.id\",\
		\"weight\": 2963,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.baseLocation.extension\",\
		\"weight\": 2964,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.baseLocation.modifierExtension\",\
		\"weight\": 2965,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.baseLocation.type\",\
		\"weight\": 2966,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.baseLocation.url\",\
		\"weight\": 2967,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.numberOfSeries\",\
		\"weight\": 2968,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.numberOfInstances\",\
		\"weight\": 2969,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.procedure\",\
		\"weight\": 2970,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.reason\",\
		\"weight\": 2971,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.description\",\
		\"weight\": 2972,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series\",\
		\"weight\": 2973,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.id\",\
		\"weight\": 2974,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.extension\",\
		\"weight\": 2975,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.modifierExtension\",\
		\"weight\": 2976,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.uid\",\
		\"weight\": 2977,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.number\",\
		\"weight\": 2978,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.modality\",\
		\"weight\": 2979,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.description\",\
		\"weight\": 2980,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.numberOfInstances\",\
		\"weight\": 2981,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.availability\",\
		\"weight\": 2982,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.baseLocation\",\
		\"weight\": 2983,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.baseLocation.id\",\
		\"weight\": 2984,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.baseLocation.extension\",\
		\"weight\": 2985,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.baseLocation.modifierExtension\",\
		\"weight\": 2986,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.baseLocation.type\",\
		\"weight\": 2987,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.baseLocation.url\",\
		\"weight\": 2988,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.bodySite\",\
		\"weight\": 2989,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.laterality\",\
		\"weight\": 2990,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.started\",\
		\"weight\": 2991,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance\",\
		\"weight\": 2992,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.id\",\
		\"weight\": 2993,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.extension\",\
		\"weight\": 2994,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.modifierExtension\",\
		\"weight\": 2995,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.uid\",\
		\"weight\": 2996,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.number\",\
		\"weight\": 2997,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.sopClass\",\
		\"weight\": 2998,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.title\",\
		\"weight\": 2999,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization\",\
		\"weight\": 3000,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.id\",\
		\"weight\": 3001,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.meta\",\
		\"weight\": 3002,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.implicitRules\",\
		\"weight\": 3003,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.language\",\
		\"weight\": 3004,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.text\",\
		\"weight\": 3005,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.contained\",\
		\"weight\": 3006,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.extension\",\
		\"weight\": 3007,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.modifierExtension\",\
		\"weight\": 3008,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.identifier\",\
		\"weight\": 3009,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.status\",\
		\"weight\": 3010,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.date\",\
		\"weight\": 3011,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccineCode\",\
		\"weight\": 3012,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.patient\",\
		\"weight\": 3013,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.wasNotGiven\",\
		\"weight\": 3014,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reported\",\
		\"weight\": 3015,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.performer\",\
		\"weight\": 3016,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.requester\",\
		\"weight\": 3017,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.encounter\",\
		\"weight\": 3018,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.manufacturer\",\
		\"weight\": 3019,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.location\",\
		\"weight\": 3020,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.lotNumber\",\
		\"weight\": 3021,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.expirationDate\",\
		\"weight\": 3022,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.site\",\
		\"weight\": 3023,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.route\",\
		\"weight\": 3024,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.doseQuantity\",\
		\"weight\": 3025,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.note\",\
		\"weight\": 3026,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation\",\
		\"weight\": 3027,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.explanation.id\",\
		\"weight\": 3028,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.explanation.extension\",\
		\"weight\": 3029,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.modifierExtension\",\
		\"weight\": 3030,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.reason\",\
		\"weight\": 3031,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.reasonNotGiven\",\
		\"weight\": 3032,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction\",\
		\"weight\": 3033,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.id\",\
		\"weight\": 3034,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.extension\",\
		\"weight\": 3035,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.modifierExtension\",\
		\"weight\": 3036,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.date\",\
		\"weight\": 3037,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.detail\",\
		\"weight\": 3038,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.reported\",\
		\"weight\": 3039,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol\",\
		\"weight\": 3040,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.id\",\
		\"weight\": 3041,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.extension\",\
		\"weight\": 3042,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.modifierExtension\",\
		\"weight\": 3043,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseSequence\",\
		\"weight\": 3044,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.description\",\
		\"weight\": 3045,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.authority\",\
		\"weight\": 3046,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.series\",\
		\"weight\": 3047,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.seriesDoses\",\
		\"weight\": 3048,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.targetDisease\",\
		\"weight\": 3049,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseStatus\",\
		\"weight\": 3050,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseStatusReason\",\
		\"weight\": 3051,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation\",\
		\"weight\": 3052,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.id\",\
		\"weight\": 3053,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.meta\",\
		\"weight\": 3054,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.implicitRules\",\
		\"weight\": 3055,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.language\",\
		\"weight\": 3056,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.text\",\
		\"weight\": 3057,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.contained\",\
		\"weight\": 3058,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.extension\",\
		\"weight\": 3059,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.modifierExtension\",\
		\"weight\": 3060,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.identifier\",\
		\"weight\": 3061,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.patient\",\
		\"weight\": 3062,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation\",\
		\"weight\": 3063,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.id\",\
		\"weight\": 3064,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.extension\",\
		\"weight\": 3065,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.modifierExtension\",\
		\"weight\": 3066,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.date\",\
		\"weight\": 3067,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.vaccineCode\",\
		\"weight\": 3068,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.doseNumber\",\
		\"weight\": 3069,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.forecastStatus\",\
		\"weight\": 3070,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion\",\
		\"weight\": 3071,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.id\",\
		\"weight\": 3072,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.extension\",\
		\"weight\": 3073,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.modifierExtension\",\
		\"weight\": 3074,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.code\",\
		\"weight\": 3075,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.value\",\
		\"weight\": 3076,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol\",\
		\"weight\": 3077,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.id\",\
		\"weight\": 3078,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.extension\",\
		\"weight\": 3079,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.modifierExtension\",\
		\"weight\": 3080,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.doseSequence\",\
		\"weight\": 3081,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.description\",\
		\"weight\": 3082,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.authority\",\
		\"weight\": 3083,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.series\",\
		\"weight\": 3084,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingImmunization\",\
		\"weight\": 3085,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingPatientInformation\",\
		\"weight\": 3086,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide\",\
		\"weight\": 3087,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.id\",\
		\"weight\": 3088,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.meta\",\
		\"weight\": 3089,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.implicitRules\",\
		\"weight\": 3090,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.language\",\
		\"weight\": 3091,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.text\",\
		\"weight\": 3092,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contained\",\
		\"weight\": 3093,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.extension\",\
		\"weight\": 3094,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.modifierExtension\",\
		\"weight\": 3095,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.url\",\
		\"weight\": 3096,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.version\",\
		\"weight\": 3097,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.name\",\
		\"weight\": 3098,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.status\",\
		\"weight\": 3099,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.experimental\",\
		\"weight\": 3100,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.publisher\",\
		\"weight\": 3101,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact\",\
		\"weight\": 3102,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.id\",\
		\"weight\": 3103,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.extension\",\
		\"weight\": 3104,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.modifierExtension\",\
		\"weight\": 3105,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.name\",\
		\"weight\": 3106,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.telecom\",\
		\"weight\": 3107,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.date\",\
		\"weight\": 3108,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.description\",\
		\"weight\": 3109,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.useContext\",\
		\"weight\": 3110,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.copyright\",\
		\"weight\": 3111,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.fhirVersion\",\
		\"weight\": 3112,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency\",\
		\"weight\": 3113,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.id\",\
		\"weight\": 3114,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.extension\",\
		\"weight\": 3115,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.modifierExtension\",\
		\"weight\": 3116,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.type\",\
		\"weight\": 3117,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.uri\",\
		\"weight\": 3118,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package\",\
		\"weight\": 3119,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.id\",\
		\"weight\": 3120,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.extension\",\
		\"weight\": 3121,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.modifierExtension\",\
		\"weight\": 3122,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.name\",\
		\"weight\": 3123,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.description\",\
		\"weight\": 3124,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource\",\
		\"weight\": 3125,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.id\",\
		\"weight\": 3126,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.extension\",\
		\"weight\": 3127,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.modifierExtension\",\
		\"weight\": 3128,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.example\",\
		\"weight\": 3129,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.name\",\
		\"weight\": 3130,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.description\",\
		\"weight\": 3131,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.acronym\",\
		\"weight\": 3132,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.sourceUri\",\
		\"weight\": 3133,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.sourceReference\",\
		\"weight\": 3133,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.exampleFor\",\
		\"weight\": 3134,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global\",\
		\"weight\": 3135,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.id\",\
		\"weight\": 3136,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.extension\",\
		\"weight\": 3137,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.modifierExtension\",\
		\"weight\": 3138,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.type\",\
		\"weight\": 3139,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.profile\",\
		\"weight\": 3140,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.binary\",\
		\"weight\": 3141,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page\",\
		\"weight\": 3142,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.id\",\
		\"weight\": 3143,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.extension\",\
		\"weight\": 3144,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.modifierExtension\",\
		\"weight\": 3145,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.source\",\
		\"weight\": 3146,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.title\",\
		\"weight\": 3147,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.kind\",\
		\"weight\": 3148,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.type\",\
		\"weight\": 3149,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.package\",\
		\"weight\": 3150,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.format\",\
		\"weight\": 3151,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.page\",\
		\"weight\": 3152,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library\",\
		\"weight\": 3153,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.id\",\
		\"weight\": 3154,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.meta\",\
		\"weight\": 3155,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.implicitRules\",\
		\"weight\": 3156,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.language\",\
		\"weight\": 3157,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.text\",\
		\"weight\": 3158,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.contained\",\
		\"weight\": 3159,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.extension\",\
		\"weight\": 3160,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.modifierExtension\",\
		\"weight\": 3161,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.url\",\
		\"weight\": 3162,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.identifier\",\
		\"weight\": 3163,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.version\",\
		\"weight\": 3164,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.name\",\
		\"weight\": 3165,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.title\",\
		\"weight\": 3166,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.type\",\
		\"weight\": 3167,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.status\",\
		\"weight\": 3168,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.experimental\",\
		\"weight\": 3169,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.description\",\
		\"weight\": 3170,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.purpose\",\
		\"weight\": 3171,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.usage\",\
		\"weight\": 3172,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.publicationDate\",\
		\"weight\": 3173,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.lastReviewDate\",\
		\"weight\": 3174,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.effectivePeriod\",\
		\"weight\": 3175,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.coverage\",\
		\"weight\": 3176,\
		\"type\": \"UsageContext\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.topic\",\
		\"weight\": 3177,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.contributor\",\
		\"weight\": 3178,\
		\"type\": \"Contributor\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.publisher\",\
		\"weight\": 3179,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.contact\",\
		\"weight\": 3180,\
		\"type\": \"ContactDetail\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.copyright\",\
		\"weight\": 3181,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.relatedResource\",\
		\"weight\": 3182,\
		\"type\": \"RelatedResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.parameter\",\
		\"weight\": 3183,\
		\"type\": \"ParameterDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.dataRequirement\",\
		\"weight\": 3184,\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.content\",\
		\"weight\": 3185,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage\",\
		\"weight\": 3186,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.id\",\
		\"weight\": 3187,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.meta\",\
		\"weight\": 3188,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.implicitRules\",\
		\"weight\": 3189,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.language\",\
		\"weight\": 3190,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.text\",\
		\"weight\": 3191,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.contained\",\
		\"weight\": 3192,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.extension\",\
		\"weight\": 3193,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.modifierExtension\",\
		\"weight\": 3194,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.author\",\
		\"weight\": 3195,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item\",\
		\"weight\": 3196,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.id\",\
		\"weight\": 3197,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item.extension\",\
		\"weight\": 3198,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.modifierExtension\",\
		\"weight\": 3199,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.type\",\
		\"weight\": 3200,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item.resource\",\
		\"weight\": 3201,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List\",\
		\"weight\": 3202,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.id\",\
		\"weight\": 3203,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.meta\",\
		\"weight\": 3204,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.implicitRules\",\
		\"weight\": 3205,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.language\",\
		\"weight\": 3206,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.text\",\
		\"weight\": 3207,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.contained\",\
		\"weight\": 3208,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.extension\",\
		\"weight\": 3209,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.modifierExtension\",\
		\"weight\": 3210,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.identifier\",\
		\"weight\": 3211,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.status\",\
		\"weight\": 3212,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.mode\",\
		\"weight\": 3213,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.title\",\
		\"weight\": 3214,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.code\",\
		\"weight\": 3215,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.subject\",\
		\"weight\": 3216,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.encounter\",\
		\"weight\": 3217,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.date\",\
		\"weight\": 3218,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.source\",\
		\"weight\": 3219,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.orderedBy\",\
		\"weight\": 3220,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.note\",\
		\"weight\": 3221,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry\",\
		\"weight\": 3222,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.id\",\
		\"weight\": 3223,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.extension\",\
		\"weight\": 3224,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.modifierExtension\",\
		\"weight\": 3225,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.flag\",\
		\"weight\": 3226,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.deleted\",\
		\"weight\": 3227,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.date\",\
		\"weight\": 3228,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.item\",\
		\"weight\": 3229,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.emptyReason\",\
		\"weight\": 3230,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location\",\
		\"weight\": 3231,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.id\",\
		\"weight\": 3232,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.meta\",\
		\"weight\": 3233,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.implicitRules\",\
		\"weight\": 3234,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.language\",\
		\"weight\": 3235,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.text\",\
		\"weight\": 3236,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.contained\",\
		\"weight\": 3237,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.extension\",\
		\"weight\": 3238,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.modifierExtension\",\
		\"weight\": 3239,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.identifier\",\
		\"weight\": 3240,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.status\",\
		\"weight\": 3241,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.name\",\
		\"weight\": 3242,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.alias\",\
		\"weight\": 3243,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.description\",\
		\"weight\": 3244,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.mode\",\
		\"weight\": 3245,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.type\",\
		\"weight\": 3246,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.telecom\",\
		\"weight\": 3247,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.address\",\
		\"weight\": 3248,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.physicalType\",\
		\"weight\": 3249,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position\",\
		\"weight\": 3250,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.id\",\
		\"weight\": 3251,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.extension\",\
		\"weight\": 3252,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.position.modifierExtension\",\
		\"weight\": 3253,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.position.longitude\",\
		\"weight\": 3254,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.latitude\",\
		\"weight\": 3255,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.altitude\",\
		\"weight\": 3256,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.managingOrganization\",\
		\"weight\": 3257,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.partOf\",\
		\"weight\": 3258,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.endpoint\",\
		\"weight\": 3259,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure\",\
		\"weight\": 3260,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.id\",\
		\"weight\": 3261,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.meta\",\
		\"weight\": 3262,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.implicitRules\",\
		\"weight\": 3263,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.language\",\
		\"weight\": 3264,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.text\",\
		\"weight\": 3265,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.contained\",\
		\"weight\": 3266,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.extension\",\
		\"weight\": 3267,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.modifierExtension\",\
		\"weight\": 3268,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.url\",\
		\"weight\": 3269,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.identifier\",\
		\"weight\": 3270,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.version\",\
		\"weight\": 3271,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.name\",\
		\"weight\": 3272,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.title\",\
		\"weight\": 3273,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.status\",\
		\"weight\": 3274,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.experimental\",\
		\"weight\": 3275,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.description\",\
		\"weight\": 3276,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.purpose\",\
		\"weight\": 3277,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.usage\",\
		\"weight\": 3278,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.publicationDate\",\
		\"weight\": 3279,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.lastReviewDate\",\
		\"weight\": 3280,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.effectivePeriod\",\
		\"weight\": 3281,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.coverage\",\
		\"weight\": 3282,\
		\"type\": \"UsageContext\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.topic\",\
		\"weight\": 3283,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.contributor\",\
		\"weight\": 3284,\
		\"type\": \"Contributor\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.publisher\",\
		\"weight\": 3285,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.contact\",\
		\"weight\": 3286,\
		\"type\": \"ContactDetail\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.copyright\",\
		\"weight\": 3287,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.relatedResource\",\
		\"weight\": 3288,\
		\"type\": \"RelatedResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.library\",\
		\"weight\": 3289,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.disclaimer\",\
		\"weight\": 3290,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.scoring\",\
		\"weight\": 3291,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.type\",\
		\"weight\": 3292,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.riskAdjustment\",\
		\"weight\": 3293,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.rateAggregation\",\
		\"weight\": 3294,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.rationale\",\
		\"weight\": 3295,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.clinicalRecommendationStatement\",\
		\"weight\": 3296,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.improvementNotation\",\
		\"weight\": 3297,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.definition\",\
		\"weight\": 3298,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.guidance\",\
		\"weight\": 3299,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.set\",\
		\"weight\": 3300,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group\",\
		\"weight\": 3301,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.id\",\
		\"weight\": 3302,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.extension\",\
		\"weight\": 3303,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.modifierExtension\",\
		\"weight\": 3304,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.identifier\",\
		\"weight\": 3305,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.name\",\
		\"weight\": 3306,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.description\",\
		\"weight\": 3307,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population\",\
		\"weight\": 3308,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.id\",\
		\"weight\": 3309,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.extension\",\
		\"weight\": 3310,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.modifierExtension\",\
		\"weight\": 3311,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.type\",\
		\"weight\": 3312,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.identifier\",\
		\"weight\": 3313,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.name\",\
		\"weight\": 3314,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.description\",\
		\"weight\": 3315,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.criteria\",\
		\"weight\": 3316,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier\",\
		\"weight\": 3317,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.id\",\
		\"weight\": 3318,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.extension\",\
		\"weight\": 3319,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.modifierExtension\",\
		\"weight\": 3320,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.identifier\",\
		\"weight\": 3321,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.criteria\",\
		\"weight\": 3322,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.path\",\
		\"weight\": 3323,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData\",\
		\"weight\": 3324,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.id\",\
		\"weight\": 3325,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.extension\",\
		\"weight\": 3326,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.modifierExtension\",\
		\"weight\": 3327,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.identifier\",\
		\"weight\": 3328,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.usage\",\
		\"weight\": 3329,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.criteria\",\
		\"weight\": 3330,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.path\",\
		\"weight\": 3331,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport\",\
		\"weight\": 3332,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.id\",\
		\"weight\": 3333,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.meta\",\
		\"weight\": 3334,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.implicitRules\",\
		\"weight\": 3335,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.language\",\
		\"weight\": 3336,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.text\",\
		\"weight\": 3337,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.contained\",\
		\"weight\": 3338,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.extension\",\
		\"weight\": 3339,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.modifierExtension\",\
		\"weight\": 3340,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.measure\",\
		\"weight\": 3341,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.type\",\
		\"weight\": 3342,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.patient\",\
		\"weight\": 3343,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.period\",\
		\"weight\": 3344,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.status\",\
		\"weight\": 3345,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.date\",\
		\"weight\": 3346,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.reportingOrganization\",\
		\"weight\": 3347,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group\",\
		\"weight\": 3348,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.id\",\
		\"weight\": 3349,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.extension\",\
		\"weight\": 3350,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.modifierExtension\",\
		\"weight\": 3351,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.identifier\",\
		\"weight\": 3352,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population\",\
		\"weight\": 3353,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.id\",\
		\"weight\": 3354,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.extension\",\
		\"weight\": 3355,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.modifierExtension\",\
		\"weight\": 3356,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.type\",\
		\"weight\": 3357,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.count\",\
		\"weight\": 3358,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.patients\",\
		\"weight\": 3359,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.measureScore\",\
		\"weight\": 3360,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier\",\
		\"weight\": 3361,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.id\",\
		\"weight\": 3362,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.extension\",\
		\"weight\": 3363,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.modifierExtension\",\
		\"weight\": 3364,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.identifier\",\
		\"weight\": 3365,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group\",\
		\"weight\": 3366,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.id\",\
		\"weight\": 3367,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.extension\",\
		\"weight\": 3368,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.modifierExtension\",\
		\"weight\": 3369,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.value\",\
		\"weight\": 3370,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population\",\
		\"weight\": 3371,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.id\",\
		\"weight\": 3372,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.extension\",\
		\"weight\": 3373,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.modifierExtension\",\
		\"weight\": 3374,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.type\",\
		\"weight\": 3375,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.count\",\
		\"weight\": 3376,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.patients\",\
		\"weight\": 3377,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.measureScore\",\
		\"weight\": 3378,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData\",\
		\"weight\": 3379,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.id\",\
		\"weight\": 3380,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.extension\",\
		\"weight\": 3381,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.modifierExtension\",\
		\"weight\": 3382,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.identifier\",\
		\"weight\": 3383,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group\",\
		\"weight\": 3384,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.id\",\
		\"weight\": 3385,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.extension\",\
		\"weight\": 3386,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.modifierExtension\",\
		\"weight\": 3387,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.value\",\
		\"weight\": 3388,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.count\",\
		\"weight\": 3389,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.patients\",\
		\"weight\": 3390,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.evaluatedResources\",\
		\"weight\": 3391,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media\",\
		\"weight\": 3392,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.id\",\
		\"weight\": 3393,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.meta\",\
		\"weight\": 3394,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.implicitRules\",\
		\"weight\": 3395,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.language\",\
		\"weight\": 3396,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.text\",\
		\"weight\": 3397,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.contained\",\
		\"weight\": 3398,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.extension\",\
		\"weight\": 3399,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.modifierExtension\",\
		\"weight\": 3400,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.identifier\",\
		\"weight\": 3401,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.type\",\
		\"weight\": 3402,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.subtype\",\
		\"weight\": 3403,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.view\",\
		\"weight\": 3404,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.subject\",\
		\"weight\": 3405,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.operator\",\
		\"weight\": 3406,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.deviceName\",\
		\"weight\": 3407,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.height\",\
		\"weight\": 3408,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.width\",\
		\"weight\": 3409,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.frames\",\
		\"weight\": 3410,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.duration\",\
		\"weight\": 3411,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.content\",\
		\"weight\": 3412,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication\",\
		\"weight\": 3413,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.id\",\
		\"weight\": 3414,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.meta\",\
		\"weight\": 3415,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.implicitRules\",\
		\"weight\": 3416,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.language\",\
		\"weight\": 3417,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.text\",\
		\"weight\": 3418,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.contained\",\
		\"weight\": 3419,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.extension\",\
		\"weight\": 3420,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.modifierExtension\",\
		\"weight\": 3421,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.code\",\
		\"weight\": 3422,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.isBrand\",\
		\"weight\": 3423,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.manufacturer\",\
		\"weight\": 3424,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product\",\
		\"weight\": 3425,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.id\",\
		\"weight\": 3426,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.extension\",\
		\"weight\": 3427,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.modifierExtension\",\
		\"weight\": 3428,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.form\",\
		\"weight\": 3429,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient\",\
		\"weight\": 3430,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.id\",\
		\"weight\": 3431,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.extension\",\
		\"weight\": 3432,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.modifierExtension\",\
		\"weight\": 3433,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemCodeableConcept\",\
		\"weight\": 3434,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemReference\",\
		\"weight\": 3434,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemReference\",\
		\"weight\": 3434,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.amount\",\
		\"weight\": 3435,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch\",\
		\"weight\": 3436,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.id\",\
		\"weight\": 3437,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch.extension\",\
		\"weight\": 3438,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.modifierExtension\",\
		\"weight\": 3439,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.lotNumber\",\
		\"weight\": 3440,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch.expirationDate\",\
		\"weight\": 3441,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package\",\
		\"weight\": 3442,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.id\",\
		\"weight\": 3443,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.extension\",\
		\"weight\": 3444,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.modifierExtension\",\
		\"weight\": 3445,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.container\",\
		\"weight\": 3446,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content\",\
		\"weight\": 3447,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.id\",\
		\"weight\": 3448,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content.extension\",\
		\"weight\": 3449,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.modifierExtension\",\
		\"weight\": 3450,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.itemCodeableConcept\",\
		\"weight\": 3451,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content.itemReference\",\
		\"weight\": 3451,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content.amount\",\
		\"weight\": 3452,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration\",\
		\"weight\": 3453,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.id\",\
		\"weight\": 3454,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.meta\",\
		\"weight\": 3455,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.implicitRules\",\
		\"weight\": 3456,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.language\",\
		\"weight\": 3457,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.text\",\
		\"weight\": 3458,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.contained\",\
		\"weight\": 3459,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.extension\",\
		\"weight\": 3460,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.modifierExtension\",\
		\"weight\": 3461,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.identifier\",\
		\"weight\": 3462,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.status\",\
		\"weight\": 3463,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.medicationCodeableConcept\",\
		\"weight\": 3464,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.medicationReference\",\
		\"weight\": 3464,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.patient\",\
		\"weight\": 3465,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.encounter\",\
		\"weight\": 3466,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.effectiveTimeDateTime\",\
		\"weight\": 3467,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.effectiveTimePeriod\",\
		\"weight\": 3467,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.performer\",\
		\"weight\": 3468,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.prescription\",\
		\"weight\": 3469,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.wasNotGiven\",\
		\"weight\": 3470,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.reasonNotGiven\",\
		\"weight\": 3471,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.reasonGiven\",\
		\"weight\": 3472,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.device\",\
		\"weight\": 3473,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.note\",\
		\"weight\": 3474,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage\",\
		\"weight\": 3475,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.id\",\
		\"weight\": 3476,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.extension\",\
		\"weight\": 3477,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.modifierExtension\",\
		\"weight\": 3478,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.text\",\
		\"weight\": 3479,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.siteCodeableConcept\",\
		\"weight\": 3480,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.siteReference\",\
		\"weight\": 3480,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.route\",\
		\"weight\": 3481,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.method\",\
		\"weight\": 3482,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.dose\",\
		\"weight\": 3483,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.rateRatio\",\
		\"weight\": 3484,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.rateQuantity\",\
		\"weight\": 3484,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory\",\
		\"weight\": 3485,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory.id\",\
		\"weight\": 3486,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory.extension\",\
		\"weight\": 3487,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory.modifierExtension\",\
		\"weight\": 3488,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory.status\",\
		\"weight\": 3489,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory.action\",\
		\"weight\": 3490,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory.dateTime\",\
		\"weight\": 3491,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory.actor\",\
		\"weight\": 3492,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.eventHistory.reason\",\
		\"weight\": 3493,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense\",\
		\"weight\": 3494,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.id\",\
		\"weight\": 3495,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.meta\",\
		\"weight\": 3496,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.implicitRules\",\
		\"weight\": 3497,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.language\",\
		\"weight\": 3498,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.text\",\
		\"weight\": 3499,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.contained\",\
		\"weight\": 3500,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.extension\",\
		\"weight\": 3501,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.modifierExtension\",\
		\"weight\": 3502,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.identifier\",\
		\"weight\": 3503,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.status\",\
		\"weight\": 3504,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.medicationCodeableConcept\",\
		\"weight\": 3505,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.medicationReference\",\
		\"weight\": 3505,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.patient\",\
		\"weight\": 3506,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dispenser\",\
		\"weight\": 3507,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dispensingOrganization\",\
		\"weight\": 3508,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.authorizingPrescription\",\
		\"weight\": 3509,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.type\",\
		\"weight\": 3510,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.quantity\",\
		\"weight\": 3511,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.daysSupply\",\
		\"weight\": 3512,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.whenPrepared\",\
		\"weight\": 3513,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.whenHandedOver\",\
		\"weight\": 3514,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.destination\",\
		\"weight\": 3515,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.receiver\",\
		\"weight\": 3516,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.note\",\
		\"weight\": 3517,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction\",\
		\"weight\": 3518,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.id\",\
		\"weight\": 3519,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.extension\",\
		\"weight\": 3520,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.modifierExtension\",\
		\"weight\": 3521,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.text\",\
		\"weight\": 3522,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.additionalInstructions\",\
		\"weight\": 3523,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.timing\",\
		\"weight\": 3524,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.asNeededBoolean\",\
		\"weight\": 3525,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.asNeededCodeableConcept\",\
		\"weight\": 3525,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.siteCodeableConcept\",\
		\"weight\": 3526,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.siteReference\",\
		\"weight\": 3526,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.route\",\
		\"weight\": 3527,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.method\",\
		\"weight\": 3528,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.doseRange\",\
		\"weight\": 3529,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.doseQuantity\",\
		\"weight\": 3529,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.rateRatio\",\
		\"weight\": 3530,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.rateRange\",\
		\"weight\": 3530,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.rateQuantity\",\
		\"weight\": 3530,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.maxDosePerPeriod\",\
		\"weight\": 3531,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution\",\
		\"weight\": 3532,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.id\",\
		\"weight\": 3533,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.extension\",\
		\"weight\": 3534,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.modifierExtension\",\
		\"weight\": 3535,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.type\",\
		\"weight\": 3536,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.reason\",\
		\"weight\": 3537,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.responsibleParty\",\
		\"weight\": 3538,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory\",\
		\"weight\": 3539,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory.id\",\
		\"weight\": 3540,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory.extension\",\
		\"weight\": 3541,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory.modifierExtension\",\
		\"weight\": 3542,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory.status\",\
		\"weight\": 3543,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory.action\",\
		\"weight\": 3544,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory.dateTime\",\
		\"weight\": 3545,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory.actor\",\
		\"weight\": 3546,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.eventHistory.reason\",\
		\"weight\": 3547,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder\",\
		\"weight\": 3548,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.id\",\
		\"weight\": 3549,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.meta\",\
		\"weight\": 3550,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.implicitRules\",\
		\"weight\": 3551,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.language\",\
		\"weight\": 3552,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.text\",\
		\"weight\": 3553,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.contained\",\
		\"weight\": 3554,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.extension\",\
		\"weight\": 3555,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.modifierExtension\",\
		\"weight\": 3556,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.identifier\",\
		\"weight\": 3557,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.status\",\
		\"weight\": 3558,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.medicationCodeableConcept\",\
		\"weight\": 3559,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.medicationReference\",\
		\"weight\": 3559,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.patient\",\
		\"weight\": 3560,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.encounter\",\
		\"weight\": 3561,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dateWritten\",\
		\"weight\": 3562,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.prescriber\",\
		\"weight\": 3563,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.reasonCode\",\
		\"weight\": 3564,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.reasonReference\",\
		\"weight\": 3565,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.note\",\
		\"weight\": 3566,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.category\",\
		\"weight\": 3567,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction\",\
		\"weight\": 3568,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.id\",\
		\"weight\": 3569,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.extension\",\
		\"weight\": 3570,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.modifierExtension\",\
		\"weight\": 3571,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.text\",\
		\"weight\": 3572,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.additionalInstructions\",\
		\"weight\": 3573,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.timing\",\
		\"weight\": 3574,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.asNeededBoolean\",\
		\"weight\": 3575,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.asNeededCodeableConcept\",\
		\"weight\": 3575,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.siteCodeableConcept\",\
		\"weight\": 3576,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.siteReference\",\
		\"weight\": 3576,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.route\",\
		\"weight\": 3577,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.method\",\
		\"weight\": 3578,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.doseRange\",\
		\"weight\": 3579,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.doseQuantity\",\
		\"weight\": 3579,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerPeriod\",\
		\"weight\": 3580,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerAdministration\",\
		\"weight\": 3581,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerLifetime\",\
		\"weight\": 3582,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateRatio\",\
		\"weight\": 3583,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateRange\",\
		\"weight\": 3583,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateQuantity\",\
		\"weight\": 3583,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest\",\
		\"weight\": 3584,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.id\",\
		\"weight\": 3585,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.extension\",\
		\"weight\": 3586,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.modifierExtension\",\
		\"weight\": 3587,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.validityPeriod\",\
		\"weight\": 3588,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.numberOfRepeatsAllowed\",\
		\"weight\": 3589,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.quantity\",\
		\"weight\": 3590,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.expectedSupplyDuration\",\
		\"weight\": 3591,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution\",\
		\"weight\": 3592,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.id\",\
		\"weight\": 3593,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.extension\",\
		\"weight\": 3594,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.modifierExtension\",\
		\"weight\": 3595,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.allowed\",\
		\"weight\": 3596,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.reason\",\
		\"weight\": 3597,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.priorPrescription\",\
		\"weight\": 3598,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory\",\
		\"weight\": 3599,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory.id\",\
		\"weight\": 3600,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory.extension\",\
		\"weight\": 3601,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory.modifierExtension\",\
		\"weight\": 3602,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory.status\",\
		\"weight\": 3603,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory.action\",\
		\"weight\": 3604,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory.dateTime\",\
		\"weight\": 3605,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory.actor\",\
		\"weight\": 3606,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.eventHistory.reason\",\
		\"weight\": 3607,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement\",\
		\"weight\": 3608,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.id\",\
		\"weight\": 3609,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.meta\",\
		\"weight\": 3610,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.implicitRules\",\
		\"weight\": 3611,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.language\",\
		\"weight\": 3612,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.text\",\
		\"weight\": 3613,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.contained\",\
		\"weight\": 3614,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.extension\",\
		\"weight\": 3615,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.modifierExtension\",\
		\"weight\": 3616,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.identifier\",\
		\"weight\": 3617,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.status\",\
		\"weight\": 3618,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.medicationCodeableConcept\",\
		\"weight\": 3619,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.medicationReference\",\
		\"weight\": 3619,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.patient\",\
		\"weight\": 3620,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.effectiveDateTime\",\
		\"weight\": 3621,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.effectivePeriod\",\
		\"weight\": 3621,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.informationSource\",\
		\"weight\": 3622,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.supportingInformation\",\
		\"weight\": 3623,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dateAsserted\",\
		\"weight\": 3624,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.notTaken\",\
		\"weight\": 3625,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonNotTaken\",\
		\"weight\": 3626,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonForUseCode\",\
		\"weight\": 3627,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonForUseReference\",\
		\"weight\": 3628,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.note\",\
		\"weight\": 3629,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.category\",\
		\"weight\": 3630,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage\",\
		\"weight\": 3631,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.id\",\
		\"weight\": 3632,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.extension\",\
		\"weight\": 3633,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.modifierExtension\",\
		\"weight\": 3634,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.text\",\
		\"weight\": 3635,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.additionalInstructions\",\
		\"weight\": 3636,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.timing\",\
		\"weight\": 3637,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.asNeededBoolean\",\
		\"weight\": 3638,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.asNeededCodeableConcept\",\
		\"weight\": 3638,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.siteCodeableConcept\",\
		\"weight\": 3639,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.siteReference\",\
		\"weight\": 3639,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.route\",\
		\"weight\": 3640,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.method\",\
		\"weight\": 3641,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.doseQuantity\",\
		\"weight\": 3642,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.doseRange\",\
		\"weight\": 3642,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.rateRatio\",\
		\"weight\": 3643,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.rateRange\",\
		\"weight\": 3643,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.rateQuantity\",\
		\"weight\": 3643,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.maxDosePerPeriod\",\
		\"weight\": 3644,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader\",\
		\"weight\": 3645,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.id\",\
		\"weight\": 3646,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.meta\",\
		\"weight\": 3647,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.implicitRules\",\
		\"weight\": 3648,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.language\",\
		\"weight\": 3649,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.text\",\
		\"weight\": 3650,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.contained\",\
		\"weight\": 3651,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.extension\",\
		\"weight\": 3652,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.modifierExtension\",\
		\"weight\": 3653,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.timestamp\",\
		\"weight\": 3654,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.event\",\
		\"weight\": 3655,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response\",\
		\"weight\": 3656,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.id\",\
		\"weight\": 3657,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.extension\",\
		\"weight\": 3658,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.response.modifierExtension\",\
		\"weight\": 3659,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.response.identifier\",\
		\"weight\": 3660,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.code\",\
		\"weight\": 3661,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.details\",\
		\"weight\": 3662,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source\",\
		\"weight\": 3663,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.id\",\
		\"weight\": 3664,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.extension\",\
		\"weight\": 3665,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.source.modifierExtension\",\
		\"weight\": 3666,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.source.name\",\
		\"weight\": 3667,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.software\",\
		\"weight\": 3668,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.version\",\
		\"weight\": 3669,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.contact\",\
		\"weight\": 3670,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.endpoint\",\
		\"weight\": 3671,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination\",\
		\"weight\": 3672,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.id\",\
		\"weight\": 3673,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.extension\",\
		\"weight\": 3674,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.modifierExtension\",\
		\"weight\": 3675,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.name\",\
		\"weight\": 3676,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.target\",\
		\"weight\": 3677,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.endpoint\",\
		\"weight\": 3678,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.enterer\",\
		\"weight\": 3679,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.author\",\
		\"weight\": 3680,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.receiver\",\
		\"weight\": 3681,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.responsible\",\
		\"weight\": 3682,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.reason\",\
		\"weight\": 3683,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.data\",\
		\"weight\": 3684,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem\",\
		\"weight\": 3685,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.id\",\
		\"weight\": 3686,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.meta\",\
		\"weight\": 3687,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.implicitRules\",\
		\"weight\": 3688,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.language\",\
		\"weight\": 3689,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.text\",\
		\"weight\": 3690,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contained\",\
		\"weight\": 3691,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.extension\",\
		\"weight\": 3692,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.modifierExtension\",\
		\"weight\": 3693,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.name\",\
		\"weight\": 3694,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.status\",\
		\"weight\": 3695,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.kind\",\
		\"weight\": 3696,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.date\",\
		\"weight\": 3697,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.publisher\",\
		\"weight\": 3698,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact\",\
		\"weight\": 3699,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.id\",\
		\"weight\": 3700,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.extension\",\
		\"weight\": 3701,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.modifierExtension\",\
		\"weight\": 3702,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.name\",\
		\"weight\": 3703,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.telecom\",\
		\"weight\": 3704,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.responsible\",\
		\"weight\": 3705,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.type\",\
		\"weight\": 3706,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.description\",\
		\"weight\": 3707,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.useContext\",\
		\"weight\": 3708,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.usage\",\
		\"weight\": 3709,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId\",\
		\"weight\": 3710,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.id\",\
		\"weight\": 3711,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.extension\",\
		\"weight\": 3712,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.modifierExtension\",\
		\"weight\": 3713,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.type\",\
		\"weight\": 3714,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.value\",\
		\"weight\": 3715,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.preferred\",\
		\"weight\": 3716,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.comment\",\
		\"weight\": 3717,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.period\",\
		\"weight\": 3718,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.replacedBy\",\
		\"weight\": 3719,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest\",\
		\"weight\": 3720,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.id\",\
		\"weight\": 3721,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.meta\",\
		\"weight\": 3722,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.implicitRules\",\
		\"weight\": 3723,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.language\",\
		\"weight\": 3724,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.text\",\
		\"weight\": 3725,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.contained\",\
		\"weight\": 3726,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.extension\",\
		\"weight\": 3727,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.modifierExtension\",\
		\"weight\": 3728,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.identifier\",\
		\"weight\": 3729,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.status\",\
		\"weight\": 3730,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.patient\",\
		\"weight\": 3731,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.encounter\",\
		\"weight\": 3732,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.dateTime\",\
		\"weight\": 3733,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.orderer\",\
		\"weight\": 3734,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.allergyIntolerance\",\
		\"weight\": 3735,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.foodPreferenceModifier\",\
		\"weight\": 3736,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.excludeFoodModifier\",\
		\"weight\": 3737,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet\",\
		\"weight\": 3738,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.id\",\
		\"weight\": 3739,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.extension\",\
		\"weight\": 3740,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.modifierExtension\",\
		\"weight\": 3741,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.type\",\
		\"weight\": 3742,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.schedule\",\
		\"weight\": 3743,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.nutrient\",\
		\"weight\": 3744,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.nutrient.id\",\
		\"weight\": 3745,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.nutrient.extension\",\
		\"weight\": 3746,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.nutrient.modifierExtension\",\
		\"weight\": 3747,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.nutrient.modifier\",\
		\"weight\": 3748,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.nutrient.amount\",\
		\"weight\": 3749,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.texture\",\
		\"weight\": 3750,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.texture.id\",\
		\"weight\": 3751,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.texture.extension\",\
		\"weight\": 3752,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.texture.modifierExtension\",\
		\"weight\": 3753,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.texture.modifier\",\
		\"weight\": 3754,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.texture.foodType\",\
		\"weight\": 3755,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.fluidConsistencyType\",\
		\"weight\": 3756,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.oralDiet.instruction\",\
		\"weight\": 3757,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement\",\
		\"weight\": 3758,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement.id\",\
		\"weight\": 3759,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement.extension\",\
		\"weight\": 3760,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement.modifierExtension\",\
		\"weight\": 3761,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement.type\",\
		\"weight\": 3762,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement.productName\",\
		\"weight\": 3763,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement.schedule\",\
		\"weight\": 3764,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement.quantity\",\
		\"weight\": 3765,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.supplement.instruction\",\
		\"weight\": 3766,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula\",\
		\"weight\": 3767,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.id\",\
		\"weight\": 3768,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.extension\",\
		\"weight\": 3769,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.modifierExtension\",\
		\"weight\": 3770,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.baseFormulaType\",\
		\"weight\": 3771,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.baseFormulaProductName\",\
		\"weight\": 3772,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.additiveType\",\
		\"weight\": 3773,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.additiveProductName\",\
		\"weight\": 3774,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.caloricDensity\",\
		\"weight\": 3775,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.routeofAdministration\",\
		\"weight\": 3776,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administration\",\
		\"weight\": 3777,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administration.id\",\
		\"weight\": 3778,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administration.extension\",\
		\"weight\": 3779,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administration.modifierExtension\",\
		\"weight\": 3780,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administration.schedule\",\
		\"weight\": 3781,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administration.quantity\",\
		\"weight\": 3782,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administration.rateQuantity\",\
		\"weight\": 3783,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administration.rateRatio\",\
		\"weight\": 3783,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.maxVolumeToDeliver\",\
		\"weight\": 3784,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionRequest.enteralFormula.administrationInstruction\",\
		\"weight\": 3785,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation\",\
		\"weight\": 3786,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.id\",\
		\"weight\": 3787,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.meta\",\
		\"weight\": 3788,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.implicitRules\",\
		\"weight\": 3789,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.language\",\
		\"weight\": 3790,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.text\",\
		\"weight\": 3791,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.contained\",\
		\"weight\": 3792,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.extension\",\
		\"weight\": 3793,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.modifierExtension\",\
		\"weight\": 3794,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.identifier\",\
		\"weight\": 3795,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.status\",\
		\"weight\": 3796,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.category\",\
		\"weight\": 3797,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.code\",\
		\"weight\": 3798,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.subject\",\
		\"weight\": 3799,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.encounter\",\
		\"weight\": 3800,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.effectiveDateTime\",\
		\"weight\": 3801,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.effectivePeriod\",\
		\"weight\": 3801,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.issued\",\
		\"weight\": 3802,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.performer\",\
		\"weight\": 3803,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.valueQuantity\",\
		\"weight\": 3804,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueCodeableConcept\",\
		\"weight\": 3804,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueString\",\
		\"weight\": 3804,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueRange\",\
		\"weight\": 3804,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueRatio\",\
		\"weight\": 3804,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueSampledData\",\
		\"weight\": 3804,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueAttachment\",\
		\"weight\": 3804,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueTime\",\
		\"weight\": 3804,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueDateTime\",\
		\"weight\": 3804,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valuePeriod\",\
		\"weight\": 3804,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.dataAbsentReason\",\
		\"weight\": 3805,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.interpretation\",\
		\"weight\": 3806,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.comment\",\
		\"weight\": 3807,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.bodySite\",\
		\"weight\": 3808,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.method\",\
		\"weight\": 3809,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.specimen\",\
		\"weight\": 3810,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.device\",\
		\"weight\": 3811,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange\",\
		\"weight\": 3812,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.id\",\
		\"weight\": 3813,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.extension\",\
		\"weight\": 3814,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.modifierExtension\",\
		\"weight\": 3815,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.low\",\
		\"weight\": 3816,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.high\",\
		\"weight\": 3817,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.meaning\",\
		\"weight\": 3818,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.age\",\
		\"weight\": 3819,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.text\",\
		\"weight\": 3820,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related\",\
		\"weight\": 3821,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.id\",\
		\"weight\": 3822,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related.extension\",\
		\"weight\": 3823,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.modifierExtension\",\
		\"weight\": 3824,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.type\",\
		\"weight\": 3825,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related.target\",\
		\"weight\": 3826,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component\",\
		\"weight\": 3827,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.id\",\
		\"weight\": 3828,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.extension\",\
		\"weight\": 3829,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.modifierExtension\",\
		\"weight\": 3830,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.code\",\
		\"weight\": 3831,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueQuantity\",\
		\"weight\": 3832,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueCodeableConcept\",\
		\"weight\": 3832,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueString\",\
		\"weight\": 3832,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueRange\",\
		\"weight\": 3832,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueRatio\",\
		\"weight\": 3832,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueSampledData\",\
		\"weight\": 3832,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueAttachment\",\
		\"weight\": 3832,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueTime\",\
		\"weight\": 3832,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueDateTime\",\
		\"weight\": 3832,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valuePeriod\",\
		\"weight\": 3832,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.dataAbsentReason\",\
		\"weight\": 3833,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.interpretation\",\
		\"weight\": 3834,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.referenceRange\",\
		\"weight\": 3835,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition\",\
		\"weight\": 3836,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.id\",\
		\"weight\": 3837,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.meta\",\
		\"weight\": 3838,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.implicitRules\",\
		\"weight\": 3839,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.language\",\
		\"weight\": 3840,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.text\",\
		\"weight\": 3841,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contained\",\
		\"weight\": 3842,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.extension\",\
		\"weight\": 3843,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.modifierExtension\",\
		\"weight\": 3844,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.url\",\
		\"weight\": 3845,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.version\",\
		\"weight\": 3846,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.name\",\
		\"weight\": 3847,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.status\",\
		\"weight\": 3848,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.kind\",\
		\"weight\": 3849,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.experimental\",\
		\"weight\": 3850,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.date\",\
		\"weight\": 3851,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.publisher\",\
		\"weight\": 3852,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact\",\
		\"weight\": 3853,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.id\",\
		\"weight\": 3854,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.extension\",\
		\"weight\": 3855,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.modifierExtension\",\
		\"weight\": 3856,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.name\",\
		\"weight\": 3857,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.telecom\",\
		\"weight\": 3858,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.description\",\
		\"weight\": 3859,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.useContext\",\
		\"weight\": 3860,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.requirements\",\
		\"weight\": 3861,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.idempotent\",\
		\"weight\": 3862,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.code\",\
		\"weight\": 3863,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.comment\",\
		\"weight\": 3864,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.base\",\
		\"weight\": 3865,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.system\",\
		\"weight\": 3866,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.type\",\
		\"weight\": 3867,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.instance\",\
		\"weight\": 3868,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter\",\
		\"weight\": 3869,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.id\",\
		\"weight\": 3870,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.extension\",\
		\"weight\": 3871,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.modifierExtension\",\
		\"weight\": 3872,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.name\",\
		\"weight\": 3873,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.use\",\
		\"weight\": 3874,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.min\",\
		\"weight\": 3875,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.max\",\
		\"weight\": 3876,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.documentation\",\
		\"weight\": 3877,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.type\",\
		\"weight\": 3878,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.searchType\",\
		\"weight\": 3879,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.profile\",\
		\"weight\": 3880,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding\",\
		\"weight\": 3881,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.id\",\
		\"weight\": 3882,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.extension\",\
		\"weight\": 3883,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.modifierExtension\",\
		\"weight\": 3884,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.strength\",\
		\"weight\": 3885,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.valueSetUri\",\
		\"weight\": 3886,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.valueSetReference\",\
		\"weight\": 3886,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.part\",\
		\"weight\": 3887,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome\",\
		\"weight\": 3888,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.id\",\
		\"weight\": 3889,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.meta\",\
		\"weight\": 3890,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.implicitRules\",\
		\"weight\": 3891,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.language\",\
		\"weight\": 3892,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.text\",\
		\"weight\": 3893,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.contained\",\
		\"weight\": 3894,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.extension\",\
		\"weight\": 3895,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.modifierExtension\",\
		\"weight\": 3896,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue\",\
		\"weight\": 3897,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.id\",\
		\"weight\": 3898,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.extension\",\
		\"weight\": 3899,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.modifierExtension\",\
		\"weight\": 3900,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.severity\",\
		\"weight\": 3901,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.code\",\
		\"weight\": 3902,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.details\",\
		\"weight\": 3903,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.diagnostics\",\
		\"weight\": 3904,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.location\",\
		\"weight\": 3905,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.expression\",\
		\"weight\": 3906,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization\",\
		\"weight\": 3907,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.id\",\
		\"weight\": 3908,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.meta\",\
		\"weight\": 3909,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.implicitRules\",\
		\"weight\": 3910,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.language\",\
		\"weight\": 3911,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.text\",\
		\"weight\": 3912,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contained\",\
		\"weight\": 3913,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.extension\",\
		\"weight\": 3914,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.modifierExtension\",\
		\"weight\": 3915,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.identifier\",\
		\"weight\": 3916,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.active\",\
		\"weight\": 3917,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.type\",\
		\"weight\": 3918,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.name\",\
		\"weight\": 3919,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.alias\",\
		\"weight\": 3920,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.telecom\",\
		\"weight\": 3921,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.address\",\
		\"weight\": 3922,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.partOf\",\
		\"weight\": 3923,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact\",\
		\"weight\": 3924,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.id\",\
		\"weight\": 3925,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.extension\",\
		\"weight\": 3926,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.modifierExtension\",\
		\"weight\": 3927,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.purpose\",\
		\"weight\": 3928,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.name\",\
		\"weight\": 3929,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.telecom\",\
		\"weight\": 3930,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.address\",\
		\"weight\": 3931,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.endpoint\",\
		\"weight\": 3932,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient\",\
		\"weight\": 3933,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.id\",\
		\"weight\": 3934,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.meta\",\
		\"weight\": 3935,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.implicitRules\",\
		\"weight\": 3936,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.language\",\
		\"weight\": 3937,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.text\",\
		\"weight\": 3938,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contained\",\
		\"weight\": 3939,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.extension\",\
		\"weight\": 3940,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.modifierExtension\",\
		\"weight\": 3941,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.identifier\",\
		\"weight\": 3942,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.active\",\
		\"weight\": 3943,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.name\",\
		\"weight\": 3944,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.telecom\",\
		\"weight\": 3945,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.gender\",\
		\"weight\": 3946,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.birthDate\",\
		\"weight\": 3947,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.deceasedBoolean\",\
		\"weight\": 3948,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.deceasedDateTime\",\
		\"weight\": 3948,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.address\",\
		\"weight\": 3949,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.maritalStatus\",\
		\"weight\": 3950,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.multipleBirthBoolean\",\
		\"weight\": 3951,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.multipleBirthInteger\",\
		\"weight\": 3951,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.photo\",\
		\"weight\": 3952,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact\",\
		\"weight\": 3953,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.id\",\
		\"weight\": 3954,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.extension\",\
		\"weight\": 3955,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.modifierExtension\",\
		\"weight\": 3956,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.relationship\",\
		\"weight\": 3957,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.name\",\
		\"weight\": 3958,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.telecom\",\
		\"weight\": 3959,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.address\",\
		\"weight\": 3960,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.gender\",\
		\"weight\": 3961,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.organization\",\
		\"weight\": 3962,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.period\",\
		\"weight\": 3963,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal\",\
		\"weight\": 3964,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.id\",\
		\"weight\": 3965,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.extension\",\
		\"weight\": 3966,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.animal.modifierExtension\",\
		\"weight\": 3967,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.animal.species\",\
		\"weight\": 3968,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.breed\",\
		\"weight\": 3969,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.genderStatus\",\
		\"weight\": 3970,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication\",\
		\"weight\": 3971,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.id\",\
		\"weight\": 3972,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication.extension\",\
		\"weight\": 3973,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.modifierExtension\",\
		\"weight\": 3974,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.language\",\
		\"weight\": 3975,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication.preferred\",\
		\"weight\": 3976,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.generalPractitioner\",\
		\"weight\": 3977,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.managingOrganization\",\
		\"weight\": 3978,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link\",\
		\"weight\": 3979,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.id\",\
		\"weight\": 3980,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link.extension\",\
		\"weight\": 3981,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.modifierExtension\",\
		\"weight\": 3982,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.other\",\
		\"weight\": 3983,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link.type\",\
		\"weight\": 3984,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice\",\
		\"weight\": 3985,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.id\",\
		\"weight\": 3986,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.meta\",\
		\"weight\": 3987,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.implicitRules\",\
		\"weight\": 3988,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.language\",\
		\"weight\": 3989,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.text\",\
		\"weight\": 3990,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.contained\",\
		\"weight\": 3991,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.extension\",\
		\"weight\": 3992,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.modifierExtension\",\
		\"weight\": 3993,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.identifier\",\
		\"weight\": 3994,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.status\",\
		\"weight\": 3995,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.ruleset\",\
		\"weight\": 3996,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.originalRuleset\",\
		\"weight\": 3997,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.created\",\
		\"weight\": 3998,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.targetIdentifier\",\
		\"weight\": 3999,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.targetReference\",\
		\"weight\": 3999,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.providerIdentifier\",\
		\"weight\": 4000,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.providerReference\",\
		\"weight\": 4000,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.organizationIdentifier\",\
		\"weight\": 4001,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.organizationReference\",\
		\"weight\": 4001,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.requestIdentifier\",\
		\"weight\": 4002,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.requestReference\",\
		\"weight\": 4002,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.responseIdentifier\",\
		\"weight\": 4003,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.responseReference\",\
		\"weight\": 4003,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.paymentStatus\",\
		\"weight\": 4004,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.statusDate\",\
		\"weight\": 4005,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation\",\
		\"weight\": 4006,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.id\",\
		\"weight\": 4007,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.meta\",\
		\"weight\": 4008,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.implicitRules\",\
		\"weight\": 4009,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.language\",\
		\"weight\": 4010,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.text\",\
		\"weight\": 4011,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.contained\",\
		\"weight\": 4012,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.extension\",\
		\"weight\": 4013,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.modifierExtension\",\
		\"weight\": 4014,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.identifier\",\
		\"weight\": 4015,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.status\",\
		\"weight\": 4016,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestIdentifier\",\
		\"weight\": 4017,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestReference\",\
		\"weight\": 4017,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.outcome\",\
		\"weight\": 4018,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.disposition\",\
		\"weight\": 4019,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.ruleset\",\
		\"weight\": 4020,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.originalRuleset\",\
		\"weight\": 4021,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.created\",\
		\"weight\": 4022,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.period\",\
		\"weight\": 4023,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.organizationIdentifier\",\
		\"weight\": 4024,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.organizationReference\",\
		\"weight\": 4024,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestProviderIdentifier\",\
		\"weight\": 4025,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestProviderReference\",\
		\"weight\": 4025,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestOrganizationIdentifier\",\
		\"weight\": 4026,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestOrganizationReference\",\
		\"weight\": 4026,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail\",\
		\"weight\": 4027,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.id\",\
		\"weight\": 4028,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.extension\",\
		\"weight\": 4029,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.modifierExtension\",\
		\"weight\": 4030,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.type\",\
		\"weight\": 4031,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.requestIdentifier\",\
		\"weight\": 4032,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.requestReference\",\
		\"weight\": 4032,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.responseIdentifier\",\
		\"weight\": 4033,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.responseReference\",\
		\"weight\": 4033,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.submitterIdentifier\",\
		\"weight\": 4034,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.submitterReference\",\
		\"weight\": 4034,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.payeeIdentifier\",\
		\"weight\": 4035,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.payeeReference\",\
		\"weight\": 4035,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.date\",\
		\"weight\": 4036,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.amount\",\
		\"weight\": 4037,\
		\"type\": \"Money\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.form\",\
		\"weight\": 4038,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.total\",\
		\"weight\": 4039,\
		\"type\": \"Money\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note\",\
		\"weight\": 4040,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.id\",\
		\"weight\": 4041,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.extension\",\
		\"weight\": 4042,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.modifierExtension\",\
		\"weight\": 4043,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.type\",\
		\"weight\": 4044,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.text\",\
		\"weight\": 4045,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person\",\
		\"weight\": 4046,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.id\",\
		\"weight\": 4047,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.meta\",\
		\"weight\": 4048,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.implicitRules\",\
		\"weight\": 4049,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.language\",\
		\"weight\": 4050,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.text\",\
		\"weight\": 4051,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.contained\",\
		\"weight\": 4052,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.extension\",\
		\"weight\": 4053,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.modifierExtension\",\
		\"weight\": 4054,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.identifier\",\
		\"weight\": 4055,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.name\",\
		\"weight\": 4056,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.telecom\",\
		\"weight\": 4057,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.gender\",\
		\"weight\": 4058,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.birthDate\",\
		\"weight\": 4059,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.address\",\
		\"weight\": 4060,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.photo\",\
		\"weight\": 4061,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.managingOrganization\",\
		\"weight\": 4062,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.active\",\
		\"weight\": 4063,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link\",\
		\"weight\": 4064,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.id\",\
		\"weight\": 4065,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link.extension\",\
		\"weight\": 4066,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.modifierExtension\",\
		\"weight\": 4067,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.target\",\
		\"weight\": 4068,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link.assurance\",\
		\"weight\": 4069,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition\",\
		\"weight\": 4070,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.id\",\
		\"weight\": 4071,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.meta\",\
		\"weight\": 4072,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.implicitRules\",\
		\"weight\": 4073,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.language\",\
		\"weight\": 4074,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.text\",\
		\"weight\": 4075,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.contained\",\
		\"weight\": 4076,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.extension\",\
		\"weight\": 4077,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.modifierExtension\",\
		\"weight\": 4078,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.url\",\
		\"weight\": 4079,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.identifier\",\
		\"weight\": 4080,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.version\",\
		\"weight\": 4081,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.name\",\
		\"weight\": 4082,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.title\",\
		\"weight\": 4083,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.type\",\
		\"weight\": 4084,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.status\",\
		\"weight\": 4085,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.experimental\",\
		\"weight\": 4086,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.description\",\
		\"weight\": 4087,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.purpose\",\
		\"weight\": 4088,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.usage\",\
		\"weight\": 4089,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.publicationDate\",\
		\"weight\": 4090,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.lastReviewDate\",\
		\"weight\": 4091,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.effectivePeriod\",\
		\"weight\": 4092,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.coverage\",\
		\"weight\": 4093,\
		\"type\": \"UsageContext\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.topic\",\
		\"weight\": 4094,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.contributor\",\
		\"weight\": 4095,\
		\"type\": \"Contributor\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.publisher\",\
		\"weight\": 4096,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.contact\",\
		\"weight\": 4097,\
		\"type\": \"ContactDetail\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.copyright\",\
		\"weight\": 4098,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.relatedResource\",\
		\"weight\": 4099,\
		\"type\": \"RelatedResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.library\",\
		\"weight\": 4100,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition\",\
		\"weight\": 4101,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.id\",\
		\"weight\": 4102,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.extension\",\
		\"weight\": 4103,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.modifierExtension\",\
		\"weight\": 4104,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.actionIdentifier\",\
		\"weight\": 4105,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.label\",\
		\"weight\": 4106,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.title\",\
		\"weight\": 4107,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.description\",\
		\"weight\": 4108,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.textEquivalent\",\
		\"weight\": 4109,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.concept\",\
		\"weight\": 4110,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.documentation\",\
		\"weight\": 4111,\
		\"type\": \"RelatedResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.triggerDefinition\",\
		\"weight\": 4112,\
		\"type\": \"TriggerDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.condition\",\
		\"weight\": 4113,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.condition.id\",\
		\"weight\": 4114,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.condition.extension\",\
		\"weight\": 4115,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.condition.modifierExtension\",\
		\"weight\": 4116,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.condition.description\",\
		\"weight\": 4117,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.condition.language\",\
		\"weight\": 4118,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.condition.expression\",\
		\"weight\": 4119,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction\",\
		\"weight\": 4120,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.id\",\
		\"weight\": 4121,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.extension\",\
		\"weight\": 4122,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.modifierExtension\",\
		\"weight\": 4123,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.actionIdentifier\",\
		\"weight\": 4124,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.relationship\",\
		\"weight\": 4125,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.offsetDuration\",\
		\"weight\": 4126,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.offsetRange\",\
		\"weight\": 4126,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.anchor\",\
		\"weight\": 4127,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.timingDateTime\",\
		\"weight\": 4128,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.timingPeriod\",\
		\"weight\": 4128,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.timingDuration\",\
		\"weight\": 4128,\
		\"type\": \"Duration\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.timingRange\",\
		\"weight\": 4128,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.timingTiming\",\
		\"weight\": 4128,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.participantType\",\
		\"weight\": 4129,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.type\",\
		\"weight\": 4130,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.groupingBehavior\",\
		\"weight\": 4131,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.selectionBehavior\",\
		\"weight\": 4132,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.requiredBehavior\",\
		\"weight\": 4133,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.precheckBehavior\",\
		\"weight\": 4134,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.cardinalityBehavior\",\
		\"weight\": 4135,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.activityDefinition\",\
		\"weight\": 4136,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.transform\",\
		\"weight\": 4137,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue\",\
		\"weight\": 4138,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.id\",\
		\"weight\": 4139,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.extension\",\
		\"weight\": 4140,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.modifierExtension\",\
		\"weight\": 4141,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.description\",\
		\"weight\": 4142,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.path\",\
		\"weight\": 4143,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.language\",\
		\"weight\": 4144,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.expression\",\
		\"weight\": 4145,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PlanDefinition.actionDefinition.actionDefinition\",\
		\"weight\": 4146,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner\",\
		\"weight\": 4147,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.id\",\
		\"weight\": 4148,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.meta\",\
		\"weight\": 4149,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.implicitRules\",\
		\"weight\": 4150,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.language\",\
		\"weight\": 4151,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.text\",\
		\"weight\": 4152,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.contained\",\
		\"weight\": 4153,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.extension\",\
		\"weight\": 4154,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.modifierExtension\",\
		\"weight\": 4155,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.identifier\",\
		\"weight\": 4156,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.active\",\
		\"weight\": 4157,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.name\",\
		\"weight\": 4158,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.telecom\",\
		\"weight\": 4159,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.address\",\
		\"weight\": 4160,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.gender\",\
		\"weight\": 4161,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.birthDate\",\
		\"weight\": 4162,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.photo\",\
		\"weight\": 4163,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role\",\
		\"weight\": 4164,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role.id\",\
		\"weight\": 4165,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.role.extension\",\
		\"weight\": 4166,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role.modifierExtension\",\
		\"weight\": 4167,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role.organization\",\
		\"weight\": 4168,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.role.code\",\
		\"weight\": 4169,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.role.specialty\",\
		\"weight\": 4170,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role.identifier\",\
		\"weight\": 4171,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role.telecom\",\
		\"weight\": 4172,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role.period\",\
		\"weight\": 4173,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.role.location\",\
		\"weight\": 4174,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role.healthcareService\",\
		\"weight\": 4175,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.role.endpoint\",\
		\"weight\": 4176,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification\",\
		\"weight\": 4177,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.id\",\
		\"weight\": 4178,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.extension\",\
		\"weight\": 4179,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.modifierExtension\",\
		\"weight\": 4180,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.identifier\",\
		\"weight\": 4181,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.code\",\
		\"weight\": 4182,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.period\",\
		\"weight\": 4183,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.issuer\",\
		\"weight\": 4184,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.communication\",\
		\"weight\": 4185,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole\",\
		\"weight\": 4186,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.id\",\
		\"weight\": 4187,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.meta\",\
		\"weight\": 4188,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.implicitRules\",\
		\"weight\": 4189,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.language\",\
		\"weight\": 4190,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.text\",\
		\"weight\": 4191,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.contained\",\
		\"weight\": 4192,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.extension\",\
		\"weight\": 4193,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.modifierExtension\",\
		\"weight\": 4194,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.identifier\",\
		\"weight\": 4195,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.active\",\
		\"weight\": 4196,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.practitioner\",\
		\"weight\": 4197,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.organization\",\
		\"weight\": 4198,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.code\",\
		\"weight\": 4199,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.specialty\",\
		\"weight\": 4200,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.location\",\
		\"weight\": 4201,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.healthcareService\",\
		\"weight\": 4202,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.telecom\",\
		\"weight\": 4203,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.period\",\
		\"weight\": 4204,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime\",\
		\"weight\": 4205,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.id\",\
		\"weight\": 4206,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.extension\",\
		\"weight\": 4207,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.modifierExtension\",\
		\"weight\": 4208,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.daysOfWeek\",\
		\"weight\": 4209,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.allDay\",\
		\"weight\": 4210,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.availableStartTime\",\
		\"weight\": 4211,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.availableEndTime\",\
		\"weight\": 4212,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable\",\
		\"weight\": 4213,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.id\",\
		\"weight\": 4214,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.extension\",\
		\"weight\": 4215,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.modifierExtension\",\
		\"weight\": 4216,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.description\",\
		\"weight\": 4217,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.during\",\
		\"weight\": 4218,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availabilityExceptions\",\
		\"weight\": 4219,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.endpoint\",\
		\"weight\": 4220,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure\",\
		\"weight\": 4221,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.id\",\
		\"weight\": 4222,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.meta\",\
		\"weight\": 4223,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.implicitRules\",\
		\"weight\": 4224,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.language\",\
		\"weight\": 4225,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.text\",\
		\"weight\": 4226,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.contained\",\
		\"weight\": 4227,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.extension\",\
		\"weight\": 4228,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.modifierExtension\",\
		\"weight\": 4229,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.identifier\",\
		\"weight\": 4230,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.subject\",\
		\"weight\": 4231,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.status\",\
		\"weight\": 4232,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.category\",\
		\"weight\": 4233,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.code\",\
		\"weight\": 4234,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.notPerformed\",\
		\"weight\": 4235,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.reasonNotPerformed\",\
		\"weight\": 4236,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.bodySite\",\
		\"weight\": 4237,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.reasonReference\",\
		\"weight\": 4238,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.reasonCode\",\
		\"weight\": 4239,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer\",\
		\"weight\": 4240,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.id\",\
		\"weight\": 4241,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performer.extension\",\
		\"weight\": 4242,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.modifierExtension\",\
		\"weight\": 4243,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.actor\",\
		\"weight\": 4244,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performer.role\",\
		\"weight\": 4245,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performedDateTime\",\
		\"weight\": 4246,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performedPeriod\",\
		\"weight\": 4246,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.encounter\",\
		\"weight\": 4247,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.location\",\
		\"weight\": 4248,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.outcome\",\
		\"weight\": 4249,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.report\",\
		\"weight\": 4250,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.complication\",\
		\"weight\": 4251,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.followUp\",\
		\"weight\": 4252,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.request\",\
		\"weight\": 4253,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.notes\",\
		\"weight\": 4254,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice\",\
		\"weight\": 4255,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.id\",\
		\"weight\": 4256,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.extension\",\
		\"weight\": 4257,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.modifierExtension\",\
		\"weight\": 4258,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.action\",\
		\"weight\": 4259,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.manipulated\",\
		\"weight\": 4260,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.usedReference\",\
		\"weight\": 4261,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.usedCode\",\
		\"weight\": 4262,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.component\",\
		\"weight\": 4263,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest\",\
		\"weight\": 4264,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.id\",\
		\"weight\": 4265,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.meta\",\
		\"weight\": 4266,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.implicitRules\",\
		\"weight\": 4267,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.language\",\
		\"weight\": 4268,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.text\",\
		\"weight\": 4269,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.contained\",\
		\"weight\": 4270,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.extension\",\
		\"weight\": 4271,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.modifierExtension\",\
		\"weight\": 4272,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.identifier\",\
		\"weight\": 4273,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.subject\",\
		\"weight\": 4274,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.code\",\
		\"weight\": 4275,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.bodySite\",\
		\"weight\": 4276,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.reasonCodeableConcept\",\
		\"weight\": 4277,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.reasonReference\",\
		\"weight\": 4277,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledDateTime\",\
		\"weight\": 4278,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledPeriod\",\
		\"weight\": 4278,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledTiming\",\
		\"weight\": 4278,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.encounter\",\
		\"weight\": 4279,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.performer\",\
		\"weight\": 4280,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.status\",\
		\"weight\": 4281,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.notes\",\
		\"weight\": 4282,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.asNeededBoolean\",\
		\"weight\": 4283,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.asNeededCodeableConcept\",\
		\"weight\": 4283,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.orderedOn\",\
		\"weight\": 4284,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.orderer\",\
		\"weight\": 4285,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.priority\",\
		\"weight\": 4286,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest\",\
		\"weight\": 4287,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.id\",\
		\"weight\": 4288,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.meta\",\
		\"weight\": 4289,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.implicitRules\",\
		\"weight\": 4290,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.language\",\
		\"weight\": 4291,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.text\",\
		\"weight\": 4292,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.contained\",\
		\"weight\": 4293,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.extension\",\
		\"weight\": 4294,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.modifierExtension\",\
		\"weight\": 4295,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.identifier\",\
		\"weight\": 4296,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.status\",\
		\"weight\": 4297,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.ruleset\",\
		\"weight\": 4298,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.originalRuleset\",\
		\"weight\": 4299,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.action\",\
		\"weight\": 4300,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.created\",\
		\"weight\": 4301,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.targetIdentifier\",\
		\"weight\": 4302,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.targetReference\",\
		\"weight\": 4302,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.providerIdentifier\",\
		\"weight\": 4303,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.providerReference\",\
		\"weight\": 4303,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.organizationIdentifier\",\
		\"weight\": 4304,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.organizationReference\",\
		\"weight\": 4304,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.requestIdentifier\",\
		\"weight\": 4305,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.requestReference\",\
		\"weight\": 4305,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.responseIdentifier\",\
		\"weight\": 4306,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.responseReference\",\
		\"weight\": 4306,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.nullify\",\
		\"weight\": 4307,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.reference\",\
		\"weight\": 4308,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.item\",\
		\"weight\": 4309,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.id\",\
		\"weight\": 4310,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.extension\",\
		\"weight\": 4311,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.modifierExtension\",\
		\"weight\": 4312,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.sequenceLinkId\",\
		\"weight\": 4313,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.include\",\
		\"weight\": 4314,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.exclude\",\
		\"weight\": 4315,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.period\",\
		\"weight\": 4316,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse\",\
		\"weight\": 4317,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.id\",\
		\"weight\": 4318,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.meta\",\
		\"weight\": 4319,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.implicitRules\",\
		\"weight\": 4320,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.language\",\
		\"weight\": 4321,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.text\",\
		\"weight\": 4322,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.contained\",\
		\"weight\": 4323,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.extension\",\
		\"weight\": 4324,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.modifierExtension\",\
		\"weight\": 4325,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.identifier\",\
		\"weight\": 4326,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.status\",\
		\"weight\": 4327,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestIdentifier\",\
		\"weight\": 4328,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestReference\",\
		\"weight\": 4328,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.outcome\",\
		\"weight\": 4329,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.disposition\",\
		\"weight\": 4330,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.ruleset\",\
		\"weight\": 4331,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.originalRuleset\",\
		\"weight\": 4332,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.created\",\
		\"weight\": 4333,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.organizationIdentifier\",\
		\"weight\": 4334,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.organizationReference\",\
		\"weight\": 4334,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestProviderIdentifier\",\
		\"weight\": 4335,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestProviderReference\",\
		\"weight\": 4335,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestOrganizationIdentifier\",\
		\"weight\": 4336,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestOrganizationReference\",\
		\"weight\": 4336,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.form\",\
		\"weight\": 4337,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes\",\
		\"weight\": 4338,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.id\",\
		\"weight\": 4339,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.extension\",\
		\"weight\": 4340,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.modifierExtension\",\
		\"weight\": 4341,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.type\",\
		\"weight\": 4342,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.text\",\
		\"weight\": 4343,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.error\",\
		\"weight\": 4344,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance\",\
		\"weight\": 4345,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.id\",\
		\"weight\": 4346,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.meta\",\
		\"weight\": 4347,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.implicitRules\",\
		\"weight\": 4348,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.language\",\
		\"weight\": 4349,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.text\",\
		\"weight\": 4350,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.contained\",\
		\"weight\": 4351,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.extension\",\
		\"weight\": 4352,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.modifierExtension\",\
		\"weight\": 4353,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.target\",\
		\"weight\": 4354,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.period\",\
		\"weight\": 4355,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.recorded\",\
		\"weight\": 4356,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.reason\",\
		\"weight\": 4357,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.activity\",\
		\"weight\": 4358,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.location\",\
		\"weight\": 4359,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.policy\",\
		\"weight\": 4360,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent\",\
		\"weight\": 4361,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.id\",\
		\"weight\": 4362,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.extension\",\
		\"weight\": 4363,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.modifierExtension\",\
		\"weight\": 4364,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.role\",\
		\"weight\": 4365,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.actor\",\
		\"weight\": 4366,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.userId\",\
		\"weight\": 4367,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent\",\
		\"weight\": 4368,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.id\",\
		\"weight\": 4369,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.extension\",\
		\"weight\": 4370,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.modifierExtension\",\
		\"weight\": 4371,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.type\",\
		\"weight\": 4372,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.target\",\
		\"weight\": 4373,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity\",\
		\"weight\": 4374,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.id\",\
		\"weight\": 4375,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.extension\",\
		\"weight\": 4376,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.modifierExtension\",\
		\"weight\": 4377,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.role\",\
		\"weight\": 4378,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.type\",\
		\"weight\": 4379,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.reference\",\
		\"weight\": 4380,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.display\",\
		\"weight\": 4381,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.agent\",\
		\"weight\": 4382,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.signature\",\
		\"weight\": 4383,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire\",\
		\"weight\": 4384,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.id\",\
		\"weight\": 4385,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.meta\",\
		\"weight\": 4386,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.implicitRules\",\
		\"weight\": 4387,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.language\",\
		\"weight\": 4388,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.text\",\
		\"weight\": 4389,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.contained\",\
		\"weight\": 4390,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.extension\",\
		\"weight\": 4391,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.modifierExtension\",\
		\"weight\": 4392,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.url\",\
		\"weight\": 4393,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.identifier\",\
		\"weight\": 4394,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.version\",\
		\"weight\": 4395,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.status\",\
		\"weight\": 4396,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.date\",\
		\"weight\": 4397,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.publisher\",\
		\"weight\": 4398,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.telecom\",\
		\"weight\": 4399,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.useContext\",\
		\"weight\": 4400,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.title\",\
		\"weight\": 4401,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.concept\",\
		\"weight\": 4402,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.subjectType\",\
		\"weight\": 4403,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item\",\
		\"weight\": 4404,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.id\",\
		\"weight\": 4405,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.extension\",\
		\"weight\": 4406,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.modifierExtension\",\
		\"weight\": 4407,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.linkId\",\
		\"weight\": 4408,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.concept\",\
		\"weight\": 4409,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.prefix\",\
		\"weight\": 4410,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.text\",\
		\"weight\": 4411,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.type\",\
		\"weight\": 4412,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen\",\
		\"weight\": 4413,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.id\",\
		\"weight\": 4414,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.extension\",\
		\"weight\": 4415,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.modifierExtension\",\
		\"weight\": 4416,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.question\",\
		\"weight\": 4417,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.hasAnswer\",\
		\"weight\": 4418,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerBoolean\",\
		\"weight\": 4419,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDecimal\",\
		\"weight\": 4419,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerInteger\",\
		\"weight\": 4419,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDate\",\
		\"weight\": 4419,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDateTime\",\
		\"weight\": 4419,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerInstant\",\
		\"weight\": 4419,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerTime\",\
		\"weight\": 4419,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerString\",\
		\"weight\": 4419,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerUri\",\
		\"weight\": 4419,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerAttachment\",\
		\"weight\": 4419,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerCoding\",\
		\"weight\": 4419,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerQuantity\",\
		\"weight\": 4419,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerReference\",\
		\"weight\": 4419,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.required\",\
		\"weight\": 4420,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.repeats\",\
		\"weight\": 4421,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.readOnly\",\
		\"weight\": 4422,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.maxLength\",\
		\"weight\": 4423,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.options\",\
		\"weight\": 4424,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option\",\
		\"weight\": 4425,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.id\",\
		\"weight\": 4426,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.extension\",\
		\"weight\": 4427,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.modifierExtension\",\
		\"weight\": 4428,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueInteger\",\
		\"weight\": 4429,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueDate\",\
		\"weight\": 4429,\
		\"type\": \"date\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueTime\",\
		\"weight\": 4429,\
		\"type\": \"time\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueString\",\
		\"weight\": 4429,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueCoding\",\
		\"weight\": 4429,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialBoolean\",\
		\"weight\": 4430,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDecimal\",\
		\"weight\": 4430,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialInteger\",\
		\"weight\": 4430,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDate\",\
		\"weight\": 4430,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDateTime\",\
		\"weight\": 4430,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialInstant\",\
		\"weight\": 4430,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialTime\",\
		\"weight\": 4430,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialString\",\
		\"weight\": 4430,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialUri\",\
		\"weight\": 4430,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialAttachment\",\
		\"weight\": 4430,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialCoding\",\
		\"weight\": 4430,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialQuantity\",\
		\"weight\": 4430,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialReference\",\
		\"weight\": 4430,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.item\",\
		\"weight\": 4431,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse\",\
		\"weight\": 4432,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.id\",\
		\"weight\": 4433,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.meta\",\
		\"weight\": 4434,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.implicitRules\",\
		\"weight\": 4435,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.language\",\
		\"weight\": 4436,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.text\",\
		\"weight\": 4437,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.contained\",\
		\"weight\": 4438,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.extension\",\
		\"weight\": 4439,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.modifierExtension\",\
		\"weight\": 4440,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.identifier\",\
		\"weight\": 4441,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.basedOn\",\
		\"weight\": 4442,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.parent\",\
		\"weight\": 4443,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.questionnaire\",\
		\"weight\": 4444,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.status\",\
		\"weight\": 4445,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.subject\",\
		\"weight\": 4446,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.context\",\
		\"weight\": 4447,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.author\",\
		\"weight\": 4448,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.authored\",\
		\"weight\": 4449,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.source\",\
		\"weight\": 4450,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item\",\
		\"weight\": 4451,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.id\",\
		\"weight\": 4452,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.extension\",\
		\"weight\": 4453,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.modifierExtension\",\
		\"weight\": 4454,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.linkId\",\
		\"weight\": 4455,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.text\",\
		\"weight\": 4456,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.subject\",\
		\"weight\": 4457,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer\",\
		\"weight\": 4458,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.id\",\
		\"weight\": 4459,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.extension\",\
		\"weight\": 4460,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.modifierExtension\",\
		\"weight\": 4461,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueBoolean\",\
		\"weight\": 4462,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDecimal\",\
		\"weight\": 4462,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueInteger\",\
		\"weight\": 4462,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDate\",\
		\"weight\": 4462,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDateTime\",\
		\"weight\": 4462,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueInstant\",\
		\"weight\": 4462,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueTime\",\
		\"weight\": 4462,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueString\",\
		\"weight\": 4462,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueUri\",\
		\"weight\": 4462,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueAttachment\",\
		\"weight\": 4462,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueCoding\",\
		\"weight\": 4462,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueQuantity\",\
		\"weight\": 4462,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueReference\",\
		\"weight\": 4462,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.item\",\
		\"weight\": 4463,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.item\",\
		\"weight\": 4464,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest\",\
		\"weight\": 4465,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.id\",\
		\"weight\": 4466,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.meta\",\
		\"weight\": 4467,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.implicitRules\",\
		\"weight\": 4468,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.language\",\
		\"weight\": 4469,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.text\",\
		\"weight\": 4470,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.contained\",\
		\"weight\": 4471,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.extension\",\
		\"weight\": 4472,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.modifierExtension\",\
		\"weight\": 4473,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.identifier\",\
		\"weight\": 4474,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.basedOn\",\
		\"weight\": 4475,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.parent\",\
		\"weight\": 4476,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.status\",\
		\"weight\": 4477,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.category\",\
		\"weight\": 4478,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.type\",\
		\"weight\": 4479,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.priority\",\
		\"weight\": 4480,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.patient\",\
		\"weight\": 4481,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.context\",\
		\"weight\": 4482,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.fulfillmentTime\",\
		\"weight\": 4483,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.authored\",\
		\"weight\": 4484,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.requester\",\
		\"weight\": 4485,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.specialty\",\
		\"weight\": 4486,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.recipient\",\
		\"weight\": 4487,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.reason\",\
		\"weight\": 4488,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.description\",\
		\"weight\": 4489,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.serviceRequested\",\
		\"weight\": 4490,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.supportingInformation\",\
		\"weight\": 4491,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson\",\
		\"weight\": 4492,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.id\",\
		\"weight\": 4493,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.meta\",\
		\"weight\": 4494,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.implicitRules\",\
		\"weight\": 4495,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.language\",\
		\"weight\": 4496,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.text\",\
		\"weight\": 4497,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.contained\",\
		\"weight\": 4498,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.extension\",\
		\"weight\": 4499,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.modifierExtension\",\
		\"weight\": 4500,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.identifier\",\
		\"weight\": 4501,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.active\",\
		\"weight\": 4502,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.patient\",\
		\"weight\": 4503,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.relationship\",\
		\"weight\": 4504,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.name\",\
		\"weight\": 4505,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.telecom\",\
		\"weight\": 4506,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.gender\",\
		\"weight\": 4507,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.birthDate\",\
		\"weight\": 4508,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.address\",\
		\"weight\": 4509,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.photo\",\
		\"weight\": 4510,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.period\",\
		\"weight\": 4511,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment\",\
		\"weight\": 4512,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.id\",\
		\"weight\": 4513,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.meta\",\
		\"weight\": 4514,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.implicitRules\",\
		\"weight\": 4515,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.language\",\
		\"weight\": 4516,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.text\",\
		\"weight\": 4517,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.contained\",\
		\"weight\": 4518,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.extension\",\
		\"weight\": 4519,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.modifierExtension\",\
		\"weight\": 4520,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.identifier\",\
		\"weight\": 4521,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.basedOn\",\
		\"weight\": 4522,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.parent\",\
		\"weight\": 4523,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.status\",\
		\"weight\": 4524,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.code\",\
		\"weight\": 4525,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.subject\",\
		\"weight\": 4526,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.context\",\
		\"weight\": 4527,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.occurrenceDateTime\",\
		\"weight\": 4528,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.occurrencePeriod\",\
		\"weight\": 4528,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.condition\",\
		\"weight\": 4529,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.performer\",\
		\"weight\": 4530,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.reasonCodeableConcept\",\
		\"weight\": 4531,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.reasonReference\",\
		\"weight\": 4531,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.method\",\
		\"weight\": 4532,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.basis\",\
		\"weight\": 4533,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction\",\
		\"weight\": 4534,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.id\",\
		\"weight\": 4535,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.extension\",\
		\"weight\": 4536,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.modifierExtension\",\
		\"weight\": 4537,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.outcome\",\
		\"weight\": 4538,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityDecimal\",\
		\"weight\": 4539,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityRange\",\
		\"weight\": 4539,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityCodeableConcept\",\
		\"weight\": 4539,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.relativeRisk\",\
		\"weight\": 4540,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.whenPeriod\",\
		\"weight\": 4541,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.whenRange\",\
		\"weight\": 4541,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.rationale\",\
		\"weight\": 4542,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.mitigation\",\
		\"weight\": 4543,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.note\",\
		\"weight\": 4544,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule\",\
		\"weight\": 4545,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.id\",\
		\"weight\": 4546,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.meta\",\
		\"weight\": 4547,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.implicitRules\",\
		\"weight\": 4548,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.language\",\
		\"weight\": 4549,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.text\",\
		\"weight\": 4550,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.contained\",\
		\"weight\": 4551,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.extension\",\
		\"weight\": 4552,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.modifierExtension\",\
		\"weight\": 4553,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.identifier\",\
		\"weight\": 4554,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.active\",\
		\"weight\": 4555,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.serviceCategory\",\
		\"weight\": 4556,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.serviceType\",\
		\"weight\": 4557,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.specialty\",\
		\"weight\": 4558,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.actor\",\
		\"weight\": 4559,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.planningHorizon\",\
		\"weight\": 4560,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.comment\",\
		\"weight\": 4561,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter\",\
		\"weight\": 4562,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.id\",\
		\"weight\": 4563,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.meta\",\
		\"weight\": 4564,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.implicitRules\",\
		\"weight\": 4565,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.language\",\
		\"weight\": 4566,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.text\",\
		\"weight\": 4567,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contained\",\
		\"weight\": 4568,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.extension\",\
		\"weight\": 4569,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.modifierExtension\",\
		\"weight\": 4570,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.url\",\
		\"weight\": 4571,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.name\",\
		\"weight\": 4572,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.status\",\
		\"weight\": 4573,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.experimental\",\
		\"weight\": 4574,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.date\",\
		\"weight\": 4575,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.publisher\",\
		\"weight\": 4576,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact\",\
		\"weight\": 4577,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.id\",\
		\"weight\": 4578,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.extension\",\
		\"weight\": 4579,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.modifierExtension\",\
		\"weight\": 4580,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.name\",\
		\"weight\": 4581,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.telecom\",\
		\"weight\": 4582,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.useContext\",\
		\"weight\": 4583,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.requirements\",\
		\"weight\": 4584,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.code\",\
		\"weight\": 4585,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.base\",\
		\"weight\": 4586,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.type\",\
		\"weight\": 4587,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.description\",\
		\"weight\": 4588,\
		\"type\": \"markdown\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.expression\",\
		\"weight\": 4589,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.xpath\",\
		\"weight\": 4590,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.xpathUsage\",\
		\"weight\": 4591,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.target\",\
		\"weight\": 4592,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.component\",\
		\"weight\": 4593,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence\",\
		\"weight\": 4594,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.id\",\
		\"weight\": 4595,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.meta\",\
		\"weight\": 4596,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.implicitRules\",\
		\"weight\": 4597,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.language\",\
		\"weight\": 4598,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.text\",\
		\"weight\": 4599,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.contained\",\
		\"weight\": 4600,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.extension\",\
		\"weight\": 4601,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.modifierExtension\",\
		\"weight\": 4602,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.identifier\",\
		\"weight\": 4603,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.type\",\
		\"weight\": 4604,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.coordinateSystem\",\
		\"weight\": 4605,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.patient\",\
		\"weight\": 4606,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.specimen\",\
		\"weight\": 4607,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.device\",\
		\"weight\": 4608,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quantity\",\
		\"weight\": 4609,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq\",\
		\"weight\": 4610,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.id\",\
		\"weight\": 4611,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.extension\",\
		\"weight\": 4612,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.modifierExtension\",\
		\"weight\": 4613,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.chromosome\",\
		\"weight\": 4614,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.genomeBuild\",\
		\"weight\": 4615,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqId\",\
		\"weight\": 4616,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqPointer\",\
		\"weight\": 4617,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqString\",\
		\"weight\": 4618,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.strand\",\
		\"weight\": 4619,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.windowStart\",\
		\"weight\": 4620,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.windowEnd\",\
		\"weight\": 4621,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variant\",\
		\"weight\": 4622,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.variant.id\",\
		\"weight\": 4623,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variant.extension\",\
		\"weight\": 4624,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.variant.modifierExtension\",\
		\"weight\": 4625,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.variant.start\",\
		\"weight\": 4626,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variant.end\",\
		\"weight\": 4627,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variant.observedAllele\",\
		\"weight\": 4628,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variant.referenceAllele\",\
		\"weight\": 4629,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variant.cigar\",\
		\"weight\": 4630,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variant.variantPointer\",\
		\"weight\": 4631,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.observedSeq\",\
		\"weight\": 4632,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality\",\
		\"weight\": 4633,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.id\",\
		\"weight\": 4634,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.extension\",\
		\"weight\": 4635,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.modifierExtension\",\
		\"weight\": 4636,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.standardSequence\",\
		\"weight\": 4637,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.start\",\
		\"weight\": 4638,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.end\",\
		\"weight\": 4639,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.score\",\
		\"weight\": 4640,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.method\",\
		\"weight\": 4641,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.truthTP\",\
		\"weight\": 4642,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.queryTP\",\
		\"weight\": 4643,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.truthFN\",\
		\"weight\": 4644,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.queryFP\",\
		\"weight\": 4645,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.gtFP\",\
		\"weight\": 4646,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.precision\",\
		\"weight\": 4647,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.recall\",\
		\"weight\": 4648,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.fScore\",\
		\"weight\": 4649,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.readCoverage\",\
		\"weight\": 4650,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository\",\
		\"weight\": 4651,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.id\",\
		\"weight\": 4652,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.extension\",\
		\"weight\": 4653,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.modifierExtension\",\
		\"weight\": 4654,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.url\",\
		\"weight\": 4655,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.name\",\
		\"weight\": 4656,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.variantId\",\
		\"weight\": 4657,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.readId\",\
		\"weight\": 4658,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.pointer\",\
		\"weight\": 4659,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant\",\
		\"weight\": 4660,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.id\",\
		\"weight\": 4661,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.extension\",\
		\"weight\": 4662,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.modifierExtension\",\
		\"weight\": 4663,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.precisionOfBoundaries\",\
		\"weight\": 4664,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.reportedaCGHRatio\",\
		\"weight\": 4665,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.length\",\
		\"weight\": 4666,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.outer\",\
		\"weight\": 4667,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.outer.id\",\
		\"weight\": 4668,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.outer.extension\",\
		\"weight\": 4669,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.outer.modifierExtension\",\
		\"weight\": 4670,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.outer.start\",\
		\"weight\": 4671,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.outer.end\",\
		\"weight\": 4672,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.inner\",\
		\"weight\": 4673,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.inner.id\",\
		\"weight\": 4674,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.inner.extension\",\
		\"weight\": 4675,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.inner.modifierExtension\",\
		\"weight\": 4676,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.inner.start\",\
		\"weight\": 4677,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariant.inner.end\",\
		\"weight\": 4678,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot\",\
		\"weight\": 4679,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.id\",\
		\"weight\": 4680,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.meta\",\
		\"weight\": 4681,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.implicitRules\",\
		\"weight\": 4682,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.language\",\
		\"weight\": 4683,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.text\",\
		\"weight\": 4684,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.contained\",\
		\"weight\": 4685,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.extension\",\
		\"weight\": 4686,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.modifierExtension\",\
		\"weight\": 4687,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.identifier\",\
		\"weight\": 4688,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.serviceCategory\",\
		\"weight\": 4689,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.serviceType\",\
		\"weight\": 4690,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.specialty\",\
		\"weight\": 4691,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.appointmentType\",\
		\"weight\": 4692,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.schedule\",\
		\"weight\": 4693,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.status\",\
		\"weight\": 4694,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.start\",\
		\"weight\": 4695,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.end\",\
		\"weight\": 4696,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.overbooked\",\
		\"weight\": 4697,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.comment\",\
		\"weight\": 4698,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen\",\
		\"weight\": 4699,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.id\",\
		\"weight\": 4700,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.meta\",\
		\"weight\": 4701,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.implicitRules\",\
		\"weight\": 4702,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.language\",\
		\"weight\": 4703,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.text\",\
		\"weight\": 4704,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.contained\",\
		\"weight\": 4705,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.extension\",\
		\"weight\": 4706,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.modifierExtension\",\
		\"weight\": 4707,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.identifier\",\
		\"weight\": 4708,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.accessionIdentifier\",\
		\"weight\": 4709,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.status\",\
		\"weight\": 4710,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.type\",\
		\"weight\": 4711,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.subject\",\
		\"weight\": 4712,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.receivedTime\",\
		\"weight\": 4713,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.parent\",\
		\"weight\": 4714,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.request\",\
		\"weight\": 4715,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection\",\
		\"weight\": 4716,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.id\",\
		\"weight\": 4717,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.extension\",\
		\"weight\": 4718,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection.modifierExtension\",\
		\"weight\": 4719,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection.collector\",\
		\"weight\": 4720,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.collectedDateTime\",\
		\"weight\": 4721,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.collectedPeriod\",\
		\"weight\": 4721,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.quantity\",\
		\"weight\": 4722,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.method\",\
		\"weight\": 4723,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.bodySite\",\
		\"weight\": 4724,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment\",\
		\"weight\": 4725,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.id\",\
		\"weight\": 4726,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.extension\",\
		\"weight\": 4727,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.modifierExtension\",\
		\"weight\": 4728,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.description\",\
		\"weight\": 4729,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.procedure\",\
		\"weight\": 4730,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.additive\",\
		\"weight\": 4731,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.timeDateTime\",\
		\"weight\": 4732,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.timePeriod\",\
		\"weight\": 4732,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container\",\
		\"weight\": 4733,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.id\",\
		\"weight\": 4734,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.extension\",\
		\"weight\": 4735,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.modifierExtension\",\
		\"weight\": 4736,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.identifier\",\
		\"weight\": 4737,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.description\",\
		\"weight\": 4738,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.type\",\
		\"weight\": 4739,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.capacity\",\
		\"weight\": 4740,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.specimenQuantity\",\
		\"weight\": 4741,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.additiveCodeableConcept\",\
		\"weight\": 4742,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.additiveReference\",\
		\"weight\": 4742,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.note\",\
		\"weight\": 4743,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition\",\
		\"weight\": 4744,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.id\",\
		\"weight\": 4745,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.meta\",\
		\"weight\": 4746,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.implicitRules\",\
		\"weight\": 4747,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.language\",\
		\"weight\": 4748,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.text\",\
		\"weight\": 4749,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contained\",\
		\"weight\": 4750,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.extension\",\
		\"weight\": 4751,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.modifierExtension\",\
		\"weight\": 4752,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.url\",\
		\"weight\": 4753,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.identifier\",\
		\"weight\": 4754,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.version\",\
		\"weight\": 4755,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.name\",\
		\"weight\": 4756,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.display\",\
		\"weight\": 4757,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.status\",\
		\"weight\": 4758,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.experimental\",\
		\"weight\": 4759,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.publisher\",\
		\"weight\": 4760,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact\",\
		\"weight\": 4761,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.id\",\
		\"weight\": 4762,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.extension\",\
		\"weight\": 4763,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.modifierExtension\",\
		\"weight\": 4764,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.name\",\
		\"weight\": 4765,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.telecom\",\
		\"weight\": 4766,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.date\",\
		\"weight\": 4767,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.description\",\
		\"weight\": 4768,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.useContext\",\
		\"weight\": 4769,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.requirements\",\
		\"weight\": 4770,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.copyright\",\
		\"weight\": 4771,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.code\",\
		\"weight\": 4772,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.fhirVersion\",\
		\"weight\": 4773,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping\",\
		\"weight\": 4774,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.id\",\
		\"weight\": 4775,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.extension\",\
		\"weight\": 4776,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.modifierExtension\",\
		\"weight\": 4777,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.identity\",\
		\"weight\": 4778,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.uri\",\
		\"weight\": 4779,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.name\",\
		\"weight\": 4780,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.comments\",\
		\"weight\": 4781,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.kind\",\
		\"weight\": 4782,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.abstract\",\
		\"weight\": 4783,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contextType\",\
		\"weight\": 4784,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.context\",\
		\"weight\": 4785,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.type\",\
		\"weight\": 4786,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.baseDefinition\",\
		\"weight\": 4787,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.derivation\",\
		\"weight\": 4788,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot\",\
		\"weight\": 4789,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.id\",\
		\"weight\": 4790,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.extension\",\
		\"weight\": 4791,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.modifierExtension\",\
		\"weight\": 4792,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.element\",\
		\"weight\": 4793,\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential\",\
		\"weight\": 4794,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.id\",\
		\"weight\": 4795,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.extension\",\
		\"weight\": 4796,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.modifierExtension\",\
		\"weight\": 4797,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.element\",\
		\"weight\": 4798,\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap\",\
		\"weight\": 4799,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.id\",\
		\"weight\": 4800,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.meta\",\
		\"weight\": 4801,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.implicitRules\",\
		\"weight\": 4802,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.language\",\
		\"weight\": 4803,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.text\",\
		\"weight\": 4804,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contained\",\
		\"weight\": 4805,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.extension\",\
		\"weight\": 4806,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.modifierExtension\",\
		\"weight\": 4807,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.url\",\
		\"weight\": 4808,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.identifier\",\
		\"weight\": 4809,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.version\",\
		\"weight\": 4810,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.name\",\
		\"weight\": 4811,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.status\",\
		\"weight\": 4812,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.experimental\",\
		\"weight\": 4813,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.publisher\",\
		\"weight\": 4814,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact\",\
		\"weight\": 4815,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.id\",\
		\"weight\": 4816,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact.extension\",\
		\"weight\": 4817,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.modifierExtension\",\
		\"weight\": 4818,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.name\",\
		\"weight\": 4819,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact.telecom\",\
		\"weight\": 4820,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.date\",\
		\"weight\": 4821,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.description\",\
		\"weight\": 4822,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.useContext\",\
		\"weight\": 4823,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.requirements\",\
		\"weight\": 4824,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.copyright\",\
		\"weight\": 4825,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure\",\
		\"weight\": 4826,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.id\",\
		\"weight\": 4827,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.extension\",\
		\"weight\": 4828,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.modifierExtension\",\
		\"weight\": 4829,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.url\",\
		\"weight\": 4830,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.mode\",\
		\"weight\": 4831,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.documentation\",\
		\"weight\": 4832,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.import\",\
		\"weight\": 4833,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group\",\
		\"weight\": 4834,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.id\",\
		\"weight\": 4835,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.extension\",\
		\"weight\": 4836,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.modifierExtension\",\
		\"weight\": 4837,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.name\",\
		\"weight\": 4838,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.extends\",\
		\"weight\": 4839,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.documentation\",\
		\"weight\": 4840,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input\",\
		\"weight\": 4841,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.id\",\
		\"weight\": 4842,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.extension\",\
		\"weight\": 4843,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.modifierExtension\",\
		\"weight\": 4844,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.name\",\
		\"weight\": 4845,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.type\",\
		\"weight\": 4846,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.mode\",\
		\"weight\": 4847,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.documentation\",\
		\"weight\": 4848,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule\",\
		\"weight\": 4849,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.id\",\
		\"weight\": 4850,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.extension\",\
		\"weight\": 4851,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.modifierExtension\",\
		\"weight\": 4852,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.name\",\
		\"weight\": 4853,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source\",\
		\"weight\": 4854,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.id\",\
		\"weight\": 4855,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.extension\",\
		\"weight\": 4856,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.modifierExtension\",\
		\"weight\": 4857,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.required\",\
		\"weight\": 4858,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.context\",\
		\"weight\": 4859,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.contextType\",\
		\"weight\": 4860,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.element\",\
		\"weight\": 4861,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.listMode\",\
		\"weight\": 4862,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.variable\",\
		\"weight\": 4863,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.condition\",\
		\"weight\": 4864,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.check\",\
		\"weight\": 4865,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target\",\
		\"weight\": 4866,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.id\",\
		\"weight\": 4867,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.extension\",\
		\"weight\": 4868,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.modifierExtension\",\
		\"weight\": 4869,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.context\",\
		\"weight\": 4870,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.contextType\",\
		\"weight\": 4871,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.element\",\
		\"weight\": 4872,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.variable\",\
		\"weight\": 4873,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.listMode\",\
		\"weight\": 4874,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.listRuleId\",\
		\"weight\": 4875,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.transform\",\
		\"weight\": 4876,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter\",\
		\"weight\": 4877,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.id\",\
		\"weight\": 4878,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.extension\",\
		\"weight\": 4879,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.modifierExtension\",\
		\"weight\": 4880,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueId\",\
		\"weight\": 4881,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueString\",\
		\"weight\": 4881,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueBoolean\",\
		\"weight\": 4881,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueInteger\",\
		\"weight\": 4881,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueDecimal\",\
		\"weight\": 4881,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.rule\",\
		\"weight\": 4882,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent\",\
		\"weight\": 4883,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.id\",\
		\"weight\": 4884,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.extension\",\
		\"weight\": 4885,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.modifierExtension\",\
		\"weight\": 4886,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.name\",\
		\"weight\": 4887,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.variable\",\
		\"weight\": 4888,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.documentation\",\
		\"weight\": 4889,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription\",\
		\"weight\": 4890,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.id\",\
		\"weight\": 4891,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.meta\",\
		\"weight\": 4892,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.implicitRules\",\
		\"weight\": 4893,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.language\",\
		\"weight\": 4894,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.text\",\
		\"weight\": 4895,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.contained\",\
		\"weight\": 4896,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.extension\",\
		\"weight\": 4897,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.modifierExtension\",\
		\"weight\": 4898,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.criteria\",\
		\"weight\": 4899,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.contact\",\
		\"weight\": 4900,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.reason\",\
		\"weight\": 4901,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.status\",\
		\"weight\": 4902,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.error\",\
		\"weight\": 4903,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel\",\
		\"weight\": 4904,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.id\",\
		\"weight\": 4905,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.extension\",\
		\"weight\": 4906,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.channel.modifierExtension\",\
		\"weight\": 4907,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.channel.type\",\
		\"weight\": 4908,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.endpoint\",\
		\"weight\": 4909,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.payload\",\
		\"weight\": 4910,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.header\",\
		\"weight\": 4911,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.end\",\
		\"weight\": 4912,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.tag\",\
		\"weight\": 4913,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance\",\
		\"weight\": 4914,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.id\",\
		\"weight\": 4915,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.meta\",\
		\"weight\": 4916,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.implicitRules\",\
		\"weight\": 4917,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.language\",\
		\"weight\": 4918,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.text\",\
		\"weight\": 4919,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.contained\",\
		\"weight\": 4920,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.extension\",\
		\"weight\": 4921,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.modifierExtension\",\
		\"weight\": 4922,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.identifier\",\
		\"weight\": 4923,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.category\",\
		\"weight\": 4924,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.code\",\
		\"weight\": 4925,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.description\",\
		\"weight\": 4926,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance\",\
		\"weight\": 4927,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.id\",\
		\"weight\": 4928,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.extension\",\
		\"weight\": 4929,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.modifierExtension\",\
		\"weight\": 4930,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.identifier\",\
		\"weight\": 4931,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.expiry\",\
		\"weight\": 4932,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.quantity\",\
		\"weight\": 4933,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient\",\
		\"weight\": 4934,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.id\",\
		\"weight\": 4935,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient.extension\",\
		\"weight\": 4936,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.modifierExtension\",\
		\"weight\": 4937,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.quantity\",\
		\"weight\": 4938,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient.substanceCodeableConcept\",\
		\"weight\": 4939,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient.substanceReference\",\
		\"weight\": 4939,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery\",\
		\"weight\": 4940,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.id\",\
		\"weight\": 4941,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.meta\",\
		\"weight\": 4942,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.implicitRules\",\
		\"weight\": 4943,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.language\",\
		\"weight\": 4944,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.text\",\
		\"weight\": 4945,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.contained\",\
		\"weight\": 4946,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.extension\",\
		\"weight\": 4947,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.modifierExtension\",\
		\"weight\": 4948,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.identifier\",\
		\"weight\": 4949,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.status\",\
		\"weight\": 4950,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.patient\",\
		\"weight\": 4951,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.type\",\
		\"weight\": 4952,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.quantity\",\
		\"weight\": 4953,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.suppliedItemCodeableConcept\",\
		\"weight\": 4954,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.suppliedItemReference\",\
		\"weight\": 4954,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.suppliedItemReference\",\
		\"weight\": 4954,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.suppliedItemReference\",\
		\"weight\": 4954,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.supplier\",\
		\"weight\": 4955,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.whenPrepared\",\
		\"weight\": 4956,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.time\",\
		\"weight\": 4957,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.destination\",\
		\"weight\": 4958,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.receiver\",\
		\"weight\": 4959,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest\",\
		\"weight\": 4960,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.id\",\
		\"weight\": 4961,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.meta\",\
		\"weight\": 4962,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.implicitRules\",\
		\"weight\": 4963,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.language\",\
		\"weight\": 4964,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.text\",\
		\"weight\": 4965,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.contained\",\
		\"weight\": 4966,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.extension\",\
		\"weight\": 4967,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.modifierExtension\",\
		\"weight\": 4968,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.patient\",\
		\"weight\": 4969,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.source\",\
		\"weight\": 4970,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.date\",\
		\"weight\": 4971,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.identifier\",\
		\"weight\": 4972,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.status\",\
		\"weight\": 4973,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.kind\",\
		\"weight\": 4974,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.orderedItemCodeableConcept\",\
		\"weight\": 4975,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.orderedItemReference\",\
		\"weight\": 4975,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.orderedItemReference\",\
		\"weight\": 4975,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.orderedItemReference\",\
		\"weight\": 4975,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.supplier\",\
		\"weight\": 4976,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.reasonCodeableConcept\",\
		\"weight\": 4977,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.reasonReference\",\
		\"weight\": 4977,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when\",\
		\"weight\": 4978,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.id\",\
		\"weight\": 4979,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.extension\",\
		\"weight\": 4980,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.modifierExtension\",\
		\"weight\": 4981,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.code\",\
		\"weight\": 4982,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.schedule\",\
		\"weight\": 4983,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task\",\
		\"weight\": 4984,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.id\",\
		\"weight\": 4985,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.meta\",\
		\"weight\": 4986,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.implicitRules\",\
		\"weight\": 4987,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.language\",\
		\"weight\": 4988,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.text\",\
		\"weight\": 4989,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.contained\",\
		\"weight\": 4990,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.extension\",\
		\"weight\": 4991,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.modifierExtension\",\
		\"weight\": 4992,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.identifier\",\
		\"weight\": 4993,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.basedOn\",\
		\"weight\": 4994,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.requisition\",\
		\"weight\": 4995,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.parent\",\
		\"weight\": 4996,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.status\",\
		\"weight\": 4997,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.statusReason\",\
		\"weight\": 4998,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.businessStatus\",\
		\"weight\": 4999,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.stage\",\
		\"weight\": 5000,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.code\",\
		\"weight\": 5001,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.priority\",\
		\"weight\": 5002,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.description\",\
		\"weight\": 5003,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.focus\",\
		\"weight\": 5004,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.for\",\
		\"weight\": 5005,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.context\",\
		\"weight\": 5006,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.created\",\
		\"weight\": 5007,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.lastModified\",\
		\"weight\": 5008,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.requester\",\
		\"weight\": 5009,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.owner\",\
		\"weight\": 5010,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.performerType\",\
		\"weight\": 5011,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.reason\",\
		\"weight\": 5012,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.note\",\
		\"weight\": 5013,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.fulfillment\",\
		\"weight\": 5014,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.fulfillment.id\",\
		\"weight\": 5015,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.fulfillment.extension\",\
		\"weight\": 5016,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.fulfillment.modifierExtension\",\
		\"weight\": 5017,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.fulfillment.repetitions\",\
		\"weight\": 5018,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.fulfillment.period\",\
		\"weight\": 5019,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.fulfillment.recipients\",\
		\"weight\": 5020,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.definition\",\
		\"weight\": 5021,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input\",\
		\"weight\": 5022,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.id\",\
		\"weight\": 5023,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.extension\",\
		\"weight\": 5024,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.modifierExtension\",\
		\"weight\": 5025,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.type\",\
		\"weight\": 5026,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueBase64Binary\",\
		\"weight\": 5027,\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueBoolean\",\
		\"weight\": 5027,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueCode\",\
		\"weight\": 5027,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueDate\",\
		\"weight\": 5027,\
		\"type\": \"date\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueDateTime\",\
		\"weight\": 5027,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueDecimal\",\
		\"weight\": 5027,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueId\",\
		\"weight\": 5027,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueInstant\",\
		\"weight\": 5027,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueInteger\",\
		\"weight\": 5027,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueMarkdown\",\
		\"weight\": 5027,\
		\"type\": \"markdown\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueOid\",\
		\"weight\": 5027,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valuePositiveInt\",\
		\"weight\": 5027,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueString\",\
		\"weight\": 5027,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueTime\",\
		\"weight\": 5027,\
		\"type\": \"time\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueUnsignedInt\",\
		\"weight\": 5027,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueUri\",\
		\"weight\": 5027,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueAddress\",\
		\"weight\": 5027,\
		\"type\": \"Address\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueAge\",\
		\"weight\": 5027,\
		\"type\": \"Age\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueAnnotation\",\
		\"weight\": 5027,\
		\"type\": \"Annotation\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueAttachment\",\
		\"weight\": 5027,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueCodeableConcept\",\
		\"weight\": 5027,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueCoding\",\
		\"weight\": 5027,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueContactPoint\",\
		\"weight\": 5027,\
		\"type\": \"ContactPoint\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueCount\",\
		\"weight\": 5027,\
		\"type\": \"Count\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueDistance\",\
		\"weight\": 5027,\
		\"type\": \"Distance\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueDuration\",\
		\"weight\": 5027,\
		\"type\": \"Duration\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueHumanName\",\
		\"weight\": 5027,\
		\"type\": \"HumanName\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueIdentifier\",\
		\"weight\": 5027,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueMoney\",\
		\"weight\": 5027,\
		\"type\": \"Money\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valuePeriod\",\
		\"weight\": 5027,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueQuantity\",\
		\"weight\": 5027,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueRange\",\
		\"weight\": 5027,\
		\"type\": \"Range\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueRatio\",\
		\"weight\": 5027,\
		\"type\": \"Ratio\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueReference\",\
		\"weight\": 5027,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueSampledData\",\
		\"weight\": 5027,\
		\"type\": \"SampledData\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueSignature\",\
		\"weight\": 5027,\
		\"type\": \"Signature\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueTiming\",\
		\"weight\": 5027,\
		\"type\": \"Timing\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueMeta\",\
		\"weight\": 5027,\
		\"type\": \"Meta\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output\",\
		\"weight\": 5028,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.id\",\
		\"weight\": 5029,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.extension\",\
		\"weight\": 5030,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.modifierExtension\",\
		\"weight\": 5031,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.type\",\
		\"weight\": 5032,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueBase64Binary\",\
		\"weight\": 5033,\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueBoolean\",\
		\"weight\": 5033,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueCode\",\
		\"weight\": 5033,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueDate\",\
		\"weight\": 5033,\
		\"type\": \"date\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueDateTime\",\
		\"weight\": 5033,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueDecimal\",\
		\"weight\": 5033,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueId\",\
		\"weight\": 5033,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueInstant\",\
		\"weight\": 5033,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueInteger\",\
		\"weight\": 5033,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueMarkdown\",\
		\"weight\": 5033,\
		\"type\": \"markdown\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueOid\",\
		\"weight\": 5033,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valuePositiveInt\",\
		\"weight\": 5033,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueString\",\
		\"weight\": 5033,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueTime\",\
		\"weight\": 5033,\
		\"type\": \"time\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueUnsignedInt\",\
		\"weight\": 5033,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueUri\",\
		\"weight\": 5033,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueAddress\",\
		\"weight\": 5033,\
		\"type\": \"Address\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueAge\",\
		\"weight\": 5033,\
		\"type\": \"Age\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueAnnotation\",\
		\"weight\": 5033,\
		\"type\": \"Annotation\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueAttachment\",\
		\"weight\": 5033,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueCodeableConcept\",\
		\"weight\": 5033,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueCoding\",\
		\"weight\": 5033,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueContactPoint\",\
		\"weight\": 5033,\
		\"type\": \"ContactPoint\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueCount\",\
		\"weight\": 5033,\
		\"type\": \"Count\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueDistance\",\
		\"weight\": 5033,\
		\"type\": \"Distance\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueDuration\",\
		\"weight\": 5033,\
		\"type\": \"Duration\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueHumanName\",\
		\"weight\": 5033,\
		\"type\": \"HumanName\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueIdentifier\",\
		\"weight\": 5033,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueMoney\",\
		\"weight\": 5033,\
		\"type\": \"Money\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valuePeriod\",\
		\"weight\": 5033,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueQuantity\",\
		\"weight\": 5033,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueRange\",\
		\"weight\": 5033,\
		\"type\": \"Range\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueRatio\",\
		\"weight\": 5033,\
		\"type\": \"Ratio\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueReference\",\
		\"weight\": 5033,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueSampledData\",\
		\"weight\": 5033,\
		\"type\": \"SampledData\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueSignature\",\
		\"weight\": 5033,\
		\"type\": \"Signature\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueTiming\",\
		\"weight\": 5033,\
		\"type\": \"Timing\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueMeta\",\
		\"weight\": 5033,\
		\"type\": \"Meta\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript\",\
		\"weight\": 5034,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.id\",\
		\"weight\": 5035,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.meta\",\
		\"weight\": 5036,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.implicitRules\",\
		\"weight\": 5037,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.language\",\
		\"weight\": 5038,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.text\",\
		\"weight\": 5039,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contained\",\
		\"weight\": 5040,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.extension\",\
		\"weight\": 5041,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.modifierExtension\",\
		\"weight\": 5042,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.url\",\
		\"weight\": 5043,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.version\",\
		\"weight\": 5044,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.name\",\
		\"weight\": 5045,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.status\",\
		\"weight\": 5046,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.identifier\",\
		\"weight\": 5047,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.experimental\",\
		\"weight\": 5048,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.publisher\",\
		\"weight\": 5049,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact\",\
		\"weight\": 5050,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.id\",\
		\"weight\": 5051,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact.extension\",\
		\"weight\": 5052,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.modifierExtension\",\
		\"weight\": 5053,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.name\",\
		\"weight\": 5054,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact.telecom\",\
		\"weight\": 5055,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.date\",\
		\"weight\": 5056,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.description\",\
		\"weight\": 5057,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.useContext\",\
		\"weight\": 5058,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.requirements\",\
		\"weight\": 5059,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.copyright\",\
		\"weight\": 5060,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin\",\
		\"weight\": 5061,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.id\",\
		\"weight\": 5062,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin.extension\",\
		\"weight\": 5063,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.modifierExtension\",\
		\"weight\": 5064,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.index\",\
		\"weight\": 5065,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin.profile\",\
		\"weight\": 5066,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination\",\
		\"weight\": 5067,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.id\",\
		\"weight\": 5068,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination.extension\",\
		\"weight\": 5069,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.modifierExtension\",\
		\"weight\": 5070,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.index\",\
		\"weight\": 5071,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination.profile\",\
		\"weight\": 5072,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata\",\
		\"weight\": 5073,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.id\",\
		\"weight\": 5074,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.extension\",\
		\"weight\": 5075,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.modifierExtension\",\
		\"weight\": 5076,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link\",\
		\"weight\": 5077,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.id\",\
		\"weight\": 5078,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.extension\",\
		\"weight\": 5079,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.modifierExtension\",\
		\"weight\": 5080,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.url\",\
		\"weight\": 5081,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.description\",\
		\"weight\": 5082,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability\",\
		\"weight\": 5083,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.id\",\
		\"weight\": 5084,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.extension\",\
		\"weight\": 5085,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.modifierExtension\",\
		\"weight\": 5086,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.required\",\
		\"weight\": 5087,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.validated\",\
		\"weight\": 5088,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.description\",\
		\"weight\": 5089,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.origin\",\
		\"weight\": 5090,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.destination\",\
		\"weight\": 5091,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.link\",\
		\"weight\": 5092,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.conformance\",\
		\"weight\": 5093,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture\",\
		\"weight\": 5094,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.id\",\
		\"weight\": 5095,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.extension\",\
		\"weight\": 5096,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.modifierExtension\",\
		\"weight\": 5097,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.autocreate\",\
		\"weight\": 5098,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.autodelete\",\
		\"weight\": 5099,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.resource\",\
		\"weight\": 5100,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.profile\",\
		\"weight\": 5101,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable\",\
		\"weight\": 5102,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.id\",\
		\"weight\": 5103,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.extension\",\
		\"weight\": 5104,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.modifierExtension\",\
		\"weight\": 5105,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.name\",\
		\"weight\": 5106,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.defaultValue\",\
		\"weight\": 5107,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.headerField\",\
		\"weight\": 5108,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.path\",\
		\"weight\": 5109,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.sourceId\",\
		\"weight\": 5110,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule\",\
		\"weight\": 5111,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.id\",\
		\"weight\": 5112,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.extension\",\
		\"weight\": 5113,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.modifierExtension\",\
		\"weight\": 5114,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.resource\",\
		\"weight\": 5115,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param\",\
		\"weight\": 5116,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.id\",\
		\"weight\": 5117,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.extension\",\
		\"weight\": 5118,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.modifierExtension\",\
		\"weight\": 5119,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.name\",\
		\"weight\": 5120,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.value\",\
		\"weight\": 5121,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset\",\
		\"weight\": 5122,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.id\",\
		\"weight\": 5123,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.extension\",\
		\"weight\": 5124,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.modifierExtension\",\
		\"weight\": 5125,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.resource\",\
		\"weight\": 5126,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule\",\
		\"weight\": 5127,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.id\",\
		\"weight\": 5128,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.extension\",\
		\"weight\": 5129,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.modifierExtension\",\
		\"weight\": 5130,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.ruleId\",\
		\"weight\": 5131,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param\",\
		\"weight\": 5132,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.id\",\
		\"weight\": 5133,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.extension\",\
		\"weight\": 5134,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.modifierExtension\",\
		\"weight\": 5135,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.name\",\
		\"weight\": 5136,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.value\",\
		\"weight\": 5137,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup\",\
		\"weight\": 5138,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.id\",\
		\"weight\": 5139,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.extension\",\
		\"weight\": 5140,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.modifierExtension\",\
		\"weight\": 5141,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action\",\
		\"weight\": 5142,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.id\",\
		\"weight\": 5143,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.extension\",\
		\"weight\": 5144,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.modifierExtension\",\
		\"weight\": 5145,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation\",\
		\"weight\": 5146,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.id\",\
		\"weight\": 5147,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.extension\",\
		\"weight\": 5148,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.modifierExtension\",\
		\"weight\": 5149,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.type\",\
		\"weight\": 5150,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.resource\",\
		\"weight\": 5151,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.label\",\
		\"weight\": 5152,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.description\",\
		\"weight\": 5153,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.accept\",\
		\"weight\": 5154,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.contentType\",\
		\"weight\": 5155,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.destination\",\
		\"weight\": 5156,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.encodeRequestUrl\",\
		\"weight\": 5157,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.origin\",\
		\"weight\": 5158,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.params\",\
		\"weight\": 5159,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader\",\
		\"weight\": 5160,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.id\",\
		\"weight\": 5161,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.extension\",\
		\"weight\": 5162,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.modifierExtension\",\
		\"weight\": 5163,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.field\",\
		\"weight\": 5164,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.value\",\
		\"weight\": 5165,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.responseId\",\
		\"weight\": 5166,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.sourceId\",\
		\"weight\": 5167,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.targetId\",\
		\"weight\": 5168,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.url\",\
		\"weight\": 5169,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert\",\
		\"weight\": 5170,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.id\",\
		\"weight\": 5171,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.extension\",\
		\"weight\": 5172,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.modifierExtension\",\
		\"weight\": 5173,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.label\",\
		\"weight\": 5174,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.description\",\
		\"weight\": 5175,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.direction\",\
		\"weight\": 5176,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.compareToSourceId\",\
		\"weight\": 5177,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.compareToSourcePath\",\
		\"weight\": 5178,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.contentType\",\
		\"weight\": 5179,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.headerField\",\
		\"weight\": 5180,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.minimumId\",\
		\"weight\": 5181,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.navigationLinks\",\
		\"weight\": 5182,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.operator\",\
		\"weight\": 5183,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.path\",\
		\"weight\": 5184,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.requestURL\",\
		\"weight\": 5185,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.resource\",\
		\"weight\": 5186,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.response\",\
		\"weight\": 5187,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.responseCode\",\
		\"weight\": 5188,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule\",\
		\"weight\": 5189,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.id\",\
		\"weight\": 5190,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.extension\",\
		\"weight\": 5191,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.modifierExtension\",\
		\"weight\": 5192,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.ruleId\",\
		\"weight\": 5193,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param\",\
		\"weight\": 5194,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.id\",\
		\"weight\": 5195,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.extension\",\
		\"weight\": 5196,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.modifierExtension\",\
		\"weight\": 5197,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.name\",\
		\"weight\": 5198,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.value\",\
		\"weight\": 5199,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset\",\
		\"weight\": 5200,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.id\",\
		\"weight\": 5201,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.extension\",\
		\"weight\": 5202,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.modifierExtension\",\
		\"weight\": 5203,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rulesetId\",\
		\"weight\": 5204,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule\",\
		\"weight\": 5205,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.id\",\
		\"weight\": 5206,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.extension\",\
		\"weight\": 5207,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.modifierExtension\",\
		\"weight\": 5208,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.ruleId\",\
		\"weight\": 5209,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param\",\
		\"weight\": 5210,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.id\",\
		\"weight\": 5211,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.extension\",\
		\"weight\": 5212,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.modifierExtension\",\
		\"weight\": 5213,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.name\",\
		\"weight\": 5214,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.value\",\
		\"weight\": 5215,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.sourceId\",\
		\"weight\": 5216,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.validateProfileId\",\
		\"weight\": 5217,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.value\",\
		\"weight\": 5218,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.warningOnly\",\
		\"weight\": 5219,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test\",\
		\"weight\": 5220,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.id\",\
		\"weight\": 5221,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.extension\",\
		\"weight\": 5222,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.modifierExtension\",\
		\"weight\": 5223,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.name\",\
		\"weight\": 5224,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.description\",\
		\"weight\": 5225,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action\",\
		\"weight\": 5226,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.id\",\
		\"weight\": 5227,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action.extension\",\
		\"weight\": 5228,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.modifierExtension\",\
		\"weight\": 5229,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.operation\",\
		\"weight\": 5230,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action.assert\",\
		\"weight\": 5231,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown\",\
		\"weight\": 5232,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.id\",\
		\"weight\": 5233,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.extension\",\
		\"weight\": 5234,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.modifierExtension\",\
		\"weight\": 5235,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action\",\
		\"weight\": 5236,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.id\",\
		\"weight\": 5237,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.extension\",\
		\"weight\": 5238,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.modifierExtension\",\
		\"weight\": 5239,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.operation\",\
		\"weight\": 5240,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription\",\
		\"weight\": 5241,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.id\",\
		\"weight\": 5242,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.meta\",\
		\"weight\": 5243,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.implicitRules\",\
		\"weight\": 5244,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.language\",\
		\"weight\": 5245,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.text\",\
		\"weight\": 5246,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.contained\",\
		\"weight\": 5247,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.extension\",\
		\"weight\": 5248,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.modifierExtension\",\
		\"weight\": 5249,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.identifier\",\
		\"weight\": 5250,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dateWritten\",\
		\"weight\": 5251,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.patient\",\
		\"weight\": 5252,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.prescriber\",\
		\"weight\": 5253,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.encounter\",\
		\"weight\": 5254,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.reasonCodeableConcept\",\
		\"weight\": 5255,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.reasonReference\",\
		\"weight\": 5255,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense\",\
		\"weight\": 5256,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.id\",\
		\"weight\": 5257,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.extension\",\
		\"weight\": 5258,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.modifierExtension\",\
		\"weight\": 5259,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.product\",\
		\"weight\": 5260,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.eye\",\
		\"weight\": 5261,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.sphere\",\
		\"weight\": 5262,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.cylinder\",\
		\"weight\": 5263,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.axis\",\
		\"weight\": 5264,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.prism\",\
		\"weight\": 5265,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.base\",\
		\"weight\": 5266,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.add\",\
		\"weight\": 5267,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.power\",\
		\"weight\": 5268,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.backCurve\",\
		\"weight\": 5269,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.diameter\",\
		\"weight\": 5270,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.duration\",\
		\"weight\": 5271,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.color\",\
		\"weight\": 5272,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.brand\",\
		\"weight\": 5273,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.notes\",\
		\"weight\": 5274,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	}\
]"function require_resource(e)return t[e]or error("resource '"..tostring(e).."' not found");end end
local e,a,t,h
if js and js.global then
h={}
h.dump=require("pure-xml-dump")
h.load=require("pure-xml-load")
t=require("lunajson")
package.loaded["cjson.safe"]={encode=function()end}
else
h=require("xml")
e=require("cjson")
a=require("datafile")
end
local L=require("resty.prettycjson")
local c,x,s,u,U,R,r,v,D
=ipairs,pairs,type,print,tonumber,string.gmatch,table.remove,string.format,table.sort
local l,w,z,m,o
local A,_,k,I
local N,O,j,q,g
local f,b,E
local T,p,S
local n
local i
local d,y
if e then
i=e.null
d,y=e.decode,e.encode
elseif t then
i=function()end
d=function(e)
return t.decode(e,nil,i)
end
y=function(e)
return t.encode(e,i)
end
else
error("neither cjson nor luajson libraries found for JSON parsing")
end
O=function(e)
local e=io.open(e,"r")
if e~=nil then io.close(e)return true else return false end
end
local H=(...and(...):match("(.+)%.[^%.]+$")or(...))or"(path of the script unknown)"
w=function(e)
local n={(e or""),"fhir-data/fhir-elements.json","src/fhir-data/fhir-elements.json","../src/fhir-data/fhir-elements.json","fhir-data/fhir-elements.json"}
local e
for a,t in c(n)do
if O(t)then
io.input(t)
e=d(io.read("*a"))
break
end
end
local t,i,o
if not e and a then
o=true
t,i=a.open("src/fhir-data/fhir-elements.json","r")
if t then e=d(t:read("*a"))end
end
if not e and require_resource then
e=d(require_resource("fhir-data/fhir-elements.json"))
end
assert(e,string.format("read_fhir_data: FHIR Schema could not be found in these locations starting from %s:  %s\n\n%s%s",H,table.concat(n,"\n  "),o and("Datafile could not find LuaRocks installation as well; error is: \n"..i)or'',require_resource and"Embedded JSON data could not be found as well."or''))
return e
end
z=function(e,a)
if not e then return nil end
for t=1,#e do
if e[t]==a then return t end
end
end
S=function(e,a)
if not e then return nil end
local t={}
if s(a)=="function"then
for o=1,#e do
local e=e[o]
t[e]=a(e)
end
else
for o=1,#e do
t[e[o]]=a
end
end
return t
end
slice=function(o,e,t)
local a={}
for e=(e and e or 1),(t and t or#o)do
a[e]=o[e]
end
return a
end
m=function(a)
n={}
local i,o
o=function(t)
local e=n
for t in R(t.path,"([^%.]+)")do
e[t]=e[t]or{}
e=e[t]
end
e._max=t.max
e._type=t.type
e._type_json=t.type_json
e._weight=t.weight
e._derivations=S(t.derivations,function(e)return n[e]end)
i(e)
if s(n[t.type])=="table"then
e[1]=n[t.type]
end
end
i=function(e,t)
if not(e and e._derivations)then return end
local t=t and t._derivations or e._derivations
for a,t in x(t)do
if t._derivations then
for a,t in x(t._derivations)do
if e~=t then
e._derivations[a]=t
end
end
end
end
end
for e=1,#a do
local e=a[e]
o(e)
end
for e=1,#a do
local e=a[e]
o(e)
end
for e=1,#a do
local e=a[e]
o(e)
end
return n
end
j=function(e,t)
return t(e)
end
q=function(e,t)
io.input(e)
local e=io.read("*a")
io.input():close()
return t(e)
end
o=function(a,e)
local o=e.value
local t=l(a,e.xml)
if not t then
u(string.format("Warning: %s is not a known FHIR element; couldn't check its FHIR type to decide the JSON type.",table.concat(a,".")))
return o
end
local t=t._type or t._type_json
if t=="boolean"then
if e.value=="true"then return true
elseif e.value=="false"then return false
else
u(string.format("Warning: %s.%s is of type %s in FHIR JSON - its XML value of %s is invalid.",table.concat(a),e.xml,t,e.value))
end
elseif t=="integer"or
t=="unsignedInt"or
t=="positiveInt"or
t=="decimal"then
return U(e.value)
else return o end
end
l=function(t,a)
local e
for o=1,#t+1 do
local t=(t[o]or a)
if not e then
e=n[t]
elseif e[t]then
e=e[t]
elseif e[1]then
e=e[1][t]or(e[1]._derivations and e[1]._derivations[t]or nil)
else
e=nil
break
end
end
return e
end
g=function(o,i)
local e,a
local t=l(o,i)
if not t then
u(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.",table.concat(o,"."),i))
end
if t and t._max=="*"then
e={{}}
a=e[1]
else
e={}
a=e
end
return e,a
end
A=function(t,a)
local e=l(t,a)
if e==nil then
u(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.",table.concat(t,"."),a))
end
if e and e._max=="*"then
return"array"
end
return"object"
end
print_xml_value=function(e,a,n,s)
if not a[e.xml]then
local t
if A(n,e.xml)=="array"then
t={}
local a=a["_"..e.xml]
if a then
for e=1,#a do
t[#t+1]=i
end
end
t[#t+1]=o(n,e)
else
t=o(n,e)
end
a[e.xml]=t
else
local t=a[e.xml]
t[#t+1]=o(n,e)
local e=a["_"..e.xml]
if e and not s then
e[#e+1]=i
end
end
end
need_shadow_element=function(a,e,t)
if a~=1 and e[1]
and t[#t]~="extension"and e.xml~="extension"
then
if e.id then return true
else
for t=1,#e do
if e[t].xml=="extension"then return true end
end
end
end
end
_=function(e,a,l,o,r)
assert(e.xml,"error from parsed xml: node.xml is missing")
local n=a-1
local d=need_shadow_element(a,e,r)
local t
if a~=1 then
t=o[n][#o[n]]
end
if a==1 then
l.resourceType=e.xml
elseif r[#r]=="contained"then
t.resourceType=e.xml
o[a]=o[a]or{}
o[a][#o[a]+1]=t
return
elseif e.value then
print_xml_value(e,t,r,d)
end
if s(e[1])=="table"and a~=1 then
local n,h
if s(t[e.xml])=="table"and not d then
local e=t[e.xml]
e[#e+1]={}
h=e[#e]
elseif not t[e.xml]and(e[1]or e.value)and not d then
n,h=g(r,e.xml)
t[e.xml]=n
end
if d then
n,h=g(r,e.xml)
local a=v('_%s',e.xml)
local o
if not t[a]then
t[a]=n
o=true
else
t[a][#t[a]+1]=h
end
local a=z(t[e.xml],e.value)
if o and a and a>1 then
n[1]=nil
for e=1,a-1 do
n[#n+1]=i
end
n[#n+1]={}
h=n[#n]
end
if not e.value and t[e.xml]then
if s(t[e.xml][#t[e.xml]])=="table"then
t[e.xml][#t[e.xml]]=nil
end
t[e.xml][#t[e.xml]+1]=i
end
end
o[a]=o[a]or{}
o[a][#o[a]+1]=h
end
if e.url then
o[a][#o[a]].url=e.url
end
if e.id then
o[a][#o[a]].id=e.id
end
return l
end
I=function(a,t,e)
a[e][#a[e]][t.xml]=h.dump(t)
end
k=function(e,t,o,i,a)
t=(t and(t+1)or 1)
o=_(e,t,o,i,a)
a[#a+1]=e.xml
for n,e in c(e)do
if e.xml=="div"and e.xmlns=="http://www.w3.org/1999/xhtml"then
I(i,e,t)
else
assert(s(e)=="table",v("unexpected type value encountered: %s (%s), expecting table",tostring(e),s(e)))
k(e,t,o,i,a)
end
end
r(a)
return o
end
N=function(a,e)
n=n or m(w())
assert(next(n),"convert_to_json: FHIR Schema could not be parsed in.")
local t
if e and e.file then
t=q(a,h.load)
else
t=j(a,h.load)
end
local a={}
local i={[1]={a}}
local o={}
local t=k(t,nil,a,i,o)
return(e and e.pretty)and L(t,nil,'  ',nil,y)
or y(t)
end
b=function(a,o,n,t,s)
if a:find("_",1,true)then return end
local e=n[#n]
if a=="div"then
e[#e+1]=h.load(o)
elseif a=="url"and(t[#t]=="extension"or t[#t]=="modifierExtension")then
e.url=o
elseif a=="id"then
local t=l(slice(t,1,#t-1),t[#t])._type
if t~="Resource"and t~="DomainResource"then
e.id=o
else
e[#e+1]={xml=a,value=tostring(o)}
end
elseif o==i then
e[#e+1]={xml=a}
else
e[#e+1]={xml=a,value=tostring(o)}
end
local o=e[#e]
if o then
o._weight=get_xml_weight(t,a)
o._count=#e
end
if s then
n[#n+1]=e[#e]
t[#t+1]=e[#e].xml
f(s,n,t)
r(n)
r(t)
end
end
get_xml_weight=function(e,t)
local a=l(e,t)
if not a then
u(string.format("Warning: %s.%s is not a known FHIR element; won't be able to sort it properly in the XML output.",table.concat(e,"."),t))
return 0
else
return a._weight
end
end
p=function(i,n,e,a)
if i:find("_",1,true)then return end
local t=e[#e]
t[#t+1]={xml=i}
local o=t[#t]
o._weight=get_xml_weight(a,i)
o._count=#t
e[#e+1]=o
a[#a+1]=o.xml
f(n,e,a)
r(e)
r(a)
end
print_contained_resource=function(a,t,o)
local e=t[#t]
e[#e+1]={xml=a.resourceType,xmlns="http://hl7.org/fhir"}
t[#t+1]=e[#e]
o[#o+1]=e[#e].xml
a.resourceType=nil
end
f=function(n,t,o)
local h
if n.resourceType then
print_contained_resource(n,t,o)
h=true
end
for a,e in x(n)do
if s(e)=="table"then
if s(e[1])=="table"then
for n,e in c(e)do
if e~=i then
p(a,e,t,o)
end
end
elseif e[1]and s(e[1])~="table"then
for h,s in c(e)do
local n,e=n[v("_%s",a)]
if n then
e=n[h]
if e==i then e=nil end
end
b(a,s,t,o,e)
end
elseif e~=i then
p(a,e,t,o)
end
elseif e~=i then
b(a,e,t,o,n[v("_%s",a)])
end
if a:sub(1,1)=='_'and not n[a:sub(2)]then
p(a:sub(2),e,t,o)
end
end
local e=t[#t]
D(e,function(t,e)
return(t.xml==e.xml)and(t._count<e._count)or(t._weight<e._weight)
end)
for t=1,#e do
local e=e[t]
e._weight=nil
e._count=nil
end
if h then
r(t)
r(o)
end
end
E=function(e,t,o,a)
if e.resourceType then
t.xmlns="http://hl7.org/fhir"
t.xml=e.resourceType
e.resourceType=nil
a[#a+1]=t.xml
end
return f(e,o,a)
end
T=function(t,a)
n=n or m(w())
assert(next(n),"convert_to_xml: FHIR Schema could not be parsed in.")
local e
if a and a.file then
e=q(t,d)
else
e=j(t,d)
end
local t,o={},{}
local a={t}
E(e,t,a,o)
return h.dump(t)
end
m(w())
return{
to_json=N,
to_xml=T
}
