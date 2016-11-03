package.preload['lunajson._str_lib']=(function(...)
local e=math.huge
local u,h,l=string.byte,string.char,string.sub
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
local s={
['"']='"',
['\\']='\\',
['/']='/',
['b']='\b',
['f']='\f',
['n']='\n',
['r']='\r',
['t']='\t'
}
s.__index=function()
r("invalid escape sequence")
end
a(s,s)
local a=0
local function c(d,i)
local n
if d=='u'then
local u,d,c,s=u(i,1,4)
local t=t[u-47]*4096+t[d-47]*256+t[c-47]*16+t[s-47]
if t==e then
r("invalid unicode charcode")
end
i=l(i,5)
if t<128 then
n=h(t)
elseif t<2048 then
n=h(192+o(t*.015625),128+t%64)
elseif t<55296 or 57344<=t then
n=h(224+o(t*.000244140625),128+o(t*.015625)%64,128+t%64)
elseif 55296<=t and t<56320 then
if a==0 then
a=t
if i==''then
return''
end
end
else
if a==0 then
a=1
else
t=65536+(a-55296)*1024+(t-56320)
a=0
n=h(240+o(t*3814697265625e-18),128+o(t*.000244140625)%64,128+o(t*.015625)%64,128+t%64)
end
end
end
if a~=0 then
r("invalid surrogate pair")
end
return(n or s[d])..i
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
local b=error
local s,e,h,p,n,u=string.byte,string.char,string.find,string.gsub,string.match,string.sub
local l=tonumber
local r,v=tostring,setmetatable
local c
if _VERSION=="Lua 5.3"then
c=require'lunajson._str_lib_lua53'
else
c=require'lunajson._str_lib'
end
local e=nil
local function k()
local a,t,y,f
local d,o
local function i(e)
b("parse error at "..t..": "..e)
end
local function e()
i('invalid value')
end
local function g()
if u(a,t,t+2)=='ull'then
t=t+3
return y
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
local r=n(r(.5),'[^0-9]')
local m=l
if r~='.'then
if h(r,'%W')then
r='%'..r
end
m=function(e)
return l(p(e,'.',r))
end
end
local function l()
i('invalid number')
end
local function w(h)
local o=t
local e
local i=s(a,o)
if not i then
return l()
end
if i==46 then
e=n(a,'^.[0-9]*',t)
local e=#e
if e==1 then
return l()
end
o=t+e
i=s(a,o)
end
if i==69 or i==101 then
local a=n(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not a then
return l()
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
local e=n(a,'^.[0-9]*%.?[0-9]*',t)
if s(e,-1)==46 then
return l()
end
local o=t+#e
local i=s(a,o)
if i==69 or i==101 then
e=n(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not e then
return l()
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
return w(true)
end
end
end
i('invalid number')
end
local n=c(i)
local x=n.surrogateok
local j=n.subst
local l=v({},{__mode="v"})
local function c(r)
local e=t-2
local o=t
local d,n
repeat
e=h(a,'"',o,true)
if not e then
i("unterminated string")
end
o=e+1
while true do
d,n=s(a,e-2,e-1)
if n~=92 or d~=92 then
break
end
e=e-2
end
until n~=92
local a=u(a,t,o-2)
t=o
if r then
local e=l[a]
if e then
return e
end
end
local e=a
if h(e,'\\',1,true)then
e=p(e,'\\(.)([^\\]*)',j)
if not x()then
i("invalid surrogate pair")
end
end
if r then
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
w,r,r,r,r,r,r,r,r,r,e,e,e,e,e,e,
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
local function r(r,e,n,i)
a,t,y,f=r,e,n,i
t=t or 1
o,t=h(a,'^[ \n\r\t]*',t)
t=t+1
o=d[s(a,t)]
t=t+1
local i=o()
if e then
return i,t
else
o,t=h(a,'^[ \n\r\t]*',t)
if t~=#a then
b('json ended')
end
return i
end
end
return r
end
return k
end)
package.preload['lunajson.encoder']=(function(...)
local s=error
local b,l,m,d,i=string.byte,string.find,string.format,string.gsub,string.match
local v=table.concat
local o=tostring
local g,r=pairs,type
local w=setmetatable
local k,y=1/0,-1/0
local h
if _VERSION=="Lua 5.1"then
h='[^ -!#-[%]^-\255]'
else
h='[\0-\31"\\]'
end
local e=nil
local function q()
local f,c
local e,t,n
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
if a and l(a,'%W')then
a='%'..a
end
if o and l(o,'%W')then
o='%'..o
end
end
local y=function(i)
if y<i and i<k then
local i=m("%.17g",i)
if u then
if o then
i=d(i,o,'')
end
if a then
i=d(i,a,'.')
end
end
t[e]=i
e=e+1
return
end
s('invalid number')
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
return m('\\u00%02X',b(e))
end
}
w(o,o)
local function u(a)
t[e]='"'
if l(a,h)then
a=d(a,h,o)
end
t[e+1]=a
t[e+2]='"'
e=e+3
end
local function h(a)
if n[a]then
s("loop detected")
end
n[a]=true
local o=a[0]
if r(o)=='number'then
t[e]='['
e=e+1
for o=1,o do
i(a[o])
t[e]=','
e=e+1
end
if o>0 then
e=e-1
end
t[e]=']'
else
o=a[1]
if o~=nil then
t[e]='['
e=e+1
local n=2
repeat
i(o)
o=a[n]
if o==nil then
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
local o=e
for a,o in g(a)do
if r(a)~='string'then
s("non-string key")
end
u(a)
t[e]=':'
e=e+1
i(o)
t[e]=','
e=e+1
end
if e>o then
e=e-1
end
t[e]='}'
end
end
e=e+1
n[a]=nil
end
local o={
boolean=p,
number=y,
string=u,
table=h,
__index=function()
s("invalid type value")
end
}
w(o,o)
function i(a)
if a==c then
t[e]='null'
e=e+1
return
end
return o[r(a)](a)
end
local function o(o,a)
f,c=o,a
e,t,n=1,{},{}
i(f)
return v(t)
end
return o
end
return q
end)
package.preload['lunajson.sax']=(function(...)
local k=error
local o,N,l,g,m,u=string.byte,string.char,string.find,string.gsub,string.match,string.sub
local q=tonumber
local I,r,z=tostring,type,table.unpack or unpack
local v
if _VERSION=="Lua 5.3"then
v=require'lunajson._str_lib_lua53'
else
v=require'lunajson._str_lib'
end
local e=nil
local function e()end
local function x(h,n)
local a,d
local i,t,y=0,1,0
local f,s
if r(h)=='string'then
a=h
i=#a
d=function()
a=''
i=0
d=e
end
else
d=function()
y=y+i
t=1
repeat
a=h()
if not a then
a=''
i=0
d=e
return
end
i=#a
until i>0
end
d()
end
local x=n.startobject or e
local _=n.key or e
local T=n.endobject or e
local E=n.startarray or e
local A=n.endarray or e
local O=n.string or e
local b=n.number or e
local r=n.boolean or e
local w=n.null or e
local function p()
local e=o(a,t)
if not e then
d()
e=o(a,t)
end
return e
end
local function n(e)
k("parse error at "..y+t..": "..e)
end
local function j()
return p()or n("unexpected termination")
end
local function h()
while true do
s,t=l(a,'^[ \n\r\t]*',t)
if t~=i then
t=t+1
return
end
if i==0 then
n("unexpected termination")
end
d()
end
end
local function e()
n('invalid value')
end
local function c(a,e,s,i)
for e=1,e do
local i=j()
if o(a,e)~=i then
n("invalid char")
end
t=t+1
end
return i(s)
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
local r=m(I(.5),'[^0-9]')
local w=q
if r~='.'then
if l(r,'%W')then
r='%'..r
end
w=function(e)
return q(g(e,'.',r))
end
end
local function c(h)
local s={}
local i=1
local e=o(a,t)
t=t+1
local function a()
s[i]=e
i=i+1
e=p()
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
return b(e)
end
local function q(s)
local n=t
local e
local h=o(a,n)
if h==46 then
e=m(a,'^.[0-9]*',t)
local e=#e
if e==1 then
t=t-1
return c(s)
end
n=t+e
h=o(a,n)
end
if h==69 or h==101 then
local a=m(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not a then
t=t-1
return c(s)
end
if e then
e=a
end
n=t+#a
end
if n>i then
t=t-1
return c(s)
end
t=n
if e then
e=w(e)
else
e=0
end
if s then
e=-e
end
return b(e)
end
local function r(n)
t=t-1
local e=m(a,'^.[0-9]*%.?[0-9]*',t)
if o(e,-1)==46 then
return c(n)
end
local s=t+#e
local o=o(a,s)
if o==69 or o==101 then
e=m(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not e then
return c(n)
end
s=t+#e
end
if s>i then
return c(n)
end
t=s
e=w(e)-0
if n then
e=-e
end
return b(e)
end
local function b()
local e=o(a,t)or j()
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
local c=v(n)
local w=c.surrogateok
local m=c.subst
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
e=e..u(a,t,i)
if h==i+2 then
h=2
else
h=1
end
d()
end
if o(a,s)==34 then
break
end
h=s+2
r=true
end
e=e..u(a,t,s-1)
t=s+1
if r then
e=g(e,'\\(.)([^\\]*)',m)
if not w()then
n("invalid surrogate pair")
end
end
if c then
return _(e)
end
return O(e)
end
local function m()
E()
h()
if o(a,t)~=93 then
local e
while true do
s=f[o(a,t)]
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
local a=o(a,t)
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
if t>i then
h()
end
end
end
t=t+1
return A()
end
local function w()
x()
h()
if o(a,t)~=125 then
local e
while true do
if o(a,t)~=34 then
n("not key")
end
t=t+1
c(true)
s,e=l(a,'^[ \n\r\t]*:[ \n\r\t]*',t)
if not e then
h()
if o(a,t)~=58 then
n("no colon after a key")
end
t=t+1
h()
e=t-1
end
t=e+1
if t>i then
h()
end
s=f[o(a,t)]
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
local a=o(a,t)
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
if t>i then
h()
end
end
end
t=t+1
return T()
end
f={
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,c,e,e,e,e,e,e,e,e,e,e,b,e,e,
q,r,r,r,r,r,r,r,r,r,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,m,e,e,e,e,
e,e,e,e,e,e,R,e,e,e,e,e,e,e,H,e,
e,e,e,e,S,e,e,e,e,e,e,w,e,e,e,e,
}
f[0]=e
local function n()
h()
s=f[o(a,t)]
t=t+1
s()
end
local function s(e)
if e<0 then
k("the argument must be non-negative")
end
local e=(t-1)+e
local o=u(a,t,e)
while e>i and i~=0 do
d()
e=e-(i-(t-1))
o=o..u(a,t,e)
end
if i~=0 then
t=e+1
end
return o
end
local function e()
return y+t
end
return{
run=n,
tryc=p,
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
return x(o,a)
end
return{
newparser=x,
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
local m={
VERSION="0.7",
_call={
pi=function(t,e)
print(string.format("<?%s %s?>",t,e))
end,
comment=function(e)
print(string.format("<!-- %s -->",e))
end,
startElement=function(a,e,t)
io.write("<")
if t then io.write(t,":")end
io.write(a)
if e then io.write(" (ns='",e,"')")end
print(">")
end,
attribute=function(o,a,t,e)
io.write('  ')
if e then io.write(e,":")end
io.write(o,'=',string.format('%q',a))
if t then io.write(" (ns='",t,"')")end
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
function m:parser(e)
return{_call=e or self._call,parse=m.parse}
end
function m:parse(s,p)
if not p then p={stripWhitespace=false}end
local r,q,w,c,z,k,y=string.find,string.sub,string.gsub,string.char,table.insert,table.remove,table.concat
local e,a,o,i,t,b,f
local v=unpack or table.unpack
local t=1
local m="text"
local d=1
local h={}
local l={}
local u
local n={}
local g=false
local j={{2047,192},{65535,224},{2097151,240}}
local function x(e)
if e<128 then return c(e)end
local t={}
for a,o in ipairs(j)do
if e<=o[1]then
for o=a+1,2,-1 do
local a=e%64
e=(e-a)/64
t[o]=c(128+a)
end
t[1]=c(o[2]+e)
return y(t)
end
end
end
local c={["lt"]="<",["gt"]=">",["amp"]="&",["quot"]='"',["apos"]="'"}
local c=function(a,t,e)return c[e]or t=="#"and x(tonumber('0'..e))or a end
local function y(e)return w(e,'(&(#?)([%d%a]+);)',c)end
local function c()
if e>d and self._call.text then
local e=q(s,d,e-1)
if p.stripWhitespace then
e=w(e,'^%s+','')
e=w(e,'%s+$','')
if#e==0 then e=nil end
end
if e then self._call.text(y(e))end
end
end
local function _()
e,a,o,i=r(s,'^<%?([:%a_][:%w_.-]*) ?(.-)%?>',t)
if e then
c()
if self._call.pi then self._call.pi(o,i)end
t=a+1
d=t
return true
end
end
local function j()
e,a,o=r(s,'^<!%-%-(.-)%-%->',t)
if e then
c()
if self._call.comment then self._call.comment(o)end
t=a+1
d=t
return true
end
end
local function w(e)
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
c()
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
i=y(i)
else
e,a,i=r(s,"^'([^<']*)'",b)
if e then
t=a+1
i=y(i)
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
l[u]=t
return true
end
end
local function p()
e,a,o=r(s,'^<!%[CDATA%[(.-)%]%]>',t)
if e then
c()
if self._call.text then self._call.text(o)end
t=a+1
d=t
return true
end
end
local function y()
e,a,o=r(s,'^%s*(/?)>',t)
if e then
m="text"
t=a+1
d=t
if h[3]then h[2]=w(h[3])end
if self._call.startElement then self._call.startElement(v(h))end
if self._call.attribute then
for e=1,u do
if l[e][4]then l[e][3]=w(l[e][4])end
self._call.attribute(v(l[e]))
end
end
if o=="/"then
k(n)
if self._call.closeElement then self._call.closeElement(v(h))end
end
return true
end
end
local function h()
e,a,o,i=r(s,'^</([%a_][%w_.-]*)%s*>',t)
if e then
f=nil
for e=#n,1,-1 do if n[e]['!']then f=n[e]['!'];break end end
else
e,a,i,o=r(s,'^</([%a_][%w_.-]*):([%a_][%w_.-]*)%s*>',t)
if e then f=w(i)end
end
if e then
c()
if self._call.closeElement then self._call.closeElement(o,f)end
t=a+1
d=t
k(n)
return true
end
end
while t<#s do
if m=="text"then
if not(_()or j()or p()or h())then
if x()then
m="attributes"
else
e,a=r(s,'^[^<]+',t)
t=(e and a or t)+1
end
end
elseif m=="attributes"then
if not q()then
if not y()then
error("Was in an element and couldn't find attributes or the close.")
end
end
end
end
if not g then error("Parsing did not discover any elements")end
if#n>0 then error("Parsing ended with unclosed elements")end
end
return m
end)
package.preload['pure-xml-dump']=(function(...)
local u,a,o,n,
e,c=
ipairs,pairs,table.insert,type,
string.match,tostring
local function d(e)
if n(e)=='boolean'then
return e and'true'or'false'
else
return e:gsub('&','&amp;'):gsub('>','&gt;'):gsub('<','&lt;'):gsub("'",'&apos;')
end
end
local function r(t)
local e=t.xml or'table'
for t,a in a(t)do
if t~='xml'and n(t)=='string'then
e=e..' '..t.."='"..d(a).."'"
end
end
return e
end
local function l(a,i,t,e,h,s)
if h>s then
error(string.format("Could not dump table to XML. Maximal depth of %i reached.",s))
end
if a[1]then
o(t,(e=='n'and i or'')..'<'..r(a)..'>')
e='n'
local r=i..'  '
for i,a in u(a)do
local i=n(a)
if i=='table'then
l(a,r,t,e,h+1,s)
e='n'
elseif i=='number'then
o(t,c(a))
else
local a=d(a)
o(t,a)
e='s'
end
end
o(t,(e=='n'and i or'')..'</'..(a.xml or'table')..'>')
e='n'
else
o(t,(e=='n'and i or'')..'<'..r(a)..'/>')
e='n'
end
end
local function a(t,e)
local a=e or 3e3
local e={}
l(t,'\n',e,'s',1,a)
return table.concat(e,'')
end
return a
end)
package.preload['pure-xml-load']=(function(...)
local n=require'slaxml'
local i={}
local e={i}
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
local o=function(t,a)
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
local o=n:parser{
startElement=a,
attribute=o,
closeElement=s,
text=h
}
local function a(a)
i={}
e={i}
t={}
o:parse(a,{stripWhitespace=true})
return select(2,next(i))
end
return a
end)
package.preload['resty.prettycjson']=(function(...)
local a=require"cjson.safe".encode
local i=table.concat
local c=string.sub
local d=string.rep
return function(t,s,n,l,e)
local t,e=(e or a)(t)
if not t then return t,e end
s,n,l=s or"\n",n or"\t",l or" "
local e,a,u,m,o,h,r=1,0,0,#t,{},nil,nil
local f=c(l,-1)=="\n"
for m=1,m do
local t=c(t,m,m)
if not r and(t=="{"or t=="[")then
o[e]=h==":"and i{t,s}or i{d(n,a),t,s}
a=a+1
elseif not r and(t=="}"or t=="]")then
a=a-1
if h=="{"or h=="["then
e=e-1
o[e]=i{d(n,a),h,t}
else
o[e]=i{s,d(n,a),t}
end
elseif not r and t==","then
o[e]=i{t,s}
u=-1
elseif not r and t==":"then
o[e]=i{t,l}
if f then
e=e+1
o[e]=d(n,a)
end
else
if t=='"'and h~="\\"then
r=not r and true or nil
end
if a~=u then
o[e]=d(n,a)
e,u=e+1,a
end
o[e]=t
end
h,e=t,e+1
end
return i(o)
end
end)
do local e={};
e["fhir-data/fhir-elements.json"]="[\
	{\
		\"min\": \"0\",\
		\"path\": \"date\",\
		\"weight\": 1,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"date.id\",\
		\"weight\": 2,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"date.extension\",\
		\"weight\": 3,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"date.value\",\
		\"type_xml\": \"xsd:gYear OR xsd:gYearMonth OR xsd:date\",\
		\"weight\": 4,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"dateTime\",\
		\"weight\": 5,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"dateTime.id\",\
		\"weight\": 6,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"dateTime.extension\",\
		\"weight\": 7,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"dateTime.value\",\
		\"type_xml\": \"xsd:gYear OR xsd:gYearMonth OR xsd:date OR xsd:dateTime\",\
		\"weight\": 8,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"code\",\
		\"weight\": 9,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"code.extension\",\
		\"weight\": 10,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"code.value\",\
		\"type_xml\": \"xsd:token\",\
		\"weight\": 11,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"string\",\
		\"weight\": 12,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"derivations\": [\
			\"code\",\
			\"id\",\
			\"markdown\"\
		],\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"string.id\",\
		\"weight\": 13,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"string.extension\",\
		\"weight\": 14,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"string.value\",\
		\"type_xml\": \"xsd:string\",\
		\"weight\": 15,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"integer\",\
		\"weight\": 16,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"derivations\": [\
			\"positiveInt\",\
			\"unsignedInt\"\
		],\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"integer.id\",\
		\"weight\": 17,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"integer.extension\",\
		\"weight\": 18,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"integer.value\",\
		\"type_xml\": \"xsd:int\",\
		\"weight\": 19,\
		\"max\": \"1\",\
		\"type_json\": \"number\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"oid\",\
		\"weight\": 20,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"oid.extension\",\
		\"weight\": 21,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"oid.value\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"weight\": 22,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"uri\",\
		\"weight\": 23,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"derivations\": [\
			\"oid\",\
			\"uuid\"\
		],\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"uri.id\",\
		\"weight\": 24,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"uri.extension\",\
		\"weight\": 25,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"uri.value\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"weight\": 26,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"uuid\",\
		\"weight\": 27,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"uuid.extension\",\
		\"weight\": 28,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"uuid.value\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"weight\": 29,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"instant\",\
		\"weight\": 30,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"instant.id\",\
		\"weight\": 31,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"instant.extension\",\
		\"weight\": 32,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"instant.value\",\
		\"type_xml\": \"xsd:dateTime\",\
		\"weight\": 33,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"boolean\",\
		\"weight\": 34,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"boolean.id\",\
		\"weight\": 35,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"boolean.extension\",\
		\"weight\": 36,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"boolean.value\",\
		\"type_xml\": \"xsd:boolean\",\
		\"weight\": 37,\
		\"max\": \"1\",\
		\"type_json\": \"true | false\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"base64Binary\",\
		\"weight\": 38,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"base64Binary.id\",\
		\"weight\": 39,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"base64Binary.extension\",\
		\"weight\": 40,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"base64Binary.value\",\
		\"type_xml\": \"xsd:base64Binary\",\
		\"weight\": 41,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"unsignedInt\",\
		\"weight\": 42,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"unsignedInt.extension\",\
		\"weight\": 43,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"unsignedInt.value\",\
		\"type_xml\": \"xsd:nonNegativeInteger\",\
		\"weight\": 44,\
		\"max\": \"1\",\
		\"type_json\": \"number\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"markdown\",\
		\"weight\": 45,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"markdown.extension\",\
		\"weight\": 46,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"markdown.value\",\
		\"type_xml\": \"xsd:string\",\
		\"weight\": 47,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"time\",\
		\"weight\": 48,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"time.id\",\
		\"weight\": 49,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"time.extension\",\
		\"weight\": 50,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"time.value\",\
		\"type_xml\": \"xsd:time\",\
		\"weight\": 51,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"id\",\
		\"weight\": 52,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"id.extension\",\
		\"weight\": 53,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"id.value\",\
		\"type_xml\": \"xsd:string\",\
		\"weight\": 54,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"positiveInt\",\
		\"weight\": 55,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"positiveInt.extension\",\
		\"weight\": 56,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"positiveInt.value\",\
		\"type_xml\": \"xsd:positiveInteger\",\
		\"weight\": 57,\
		\"max\": \"1\",\
		\"type_json\": \"number\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"decimal\",\
		\"weight\": 58,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"decimal.id\",\
		\"weight\": 59,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"decimal.extension\",\
		\"weight\": 60,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"decimal.value\",\
		\"type_xml\": \"xsd:decimal\",\
		\"weight\": 61,\
		\"max\": \"1\",\
		\"type_json\": \"number\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"xhtml\",\
		\"weight\": 62,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"xhtml.id\",\
		\"weight\": 63,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"xhtml.extension\",\
		\"weight\": 64,\
		\"max\": \"0\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"xhtml.value\",\
		\"type_xml\": \"xhtml:div\",\
		\"weight\": 65,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Reference\",\
		\"weight\": 66,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Reference.id\",\
		\"weight\": 67,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Reference.extension\",\
		\"weight\": 68,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Reference.reference\",\
		\"weight\": 69,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Reference.display\",\
		\"weight\": 70,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Quantity\",\
		\"weight\": 71,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"derivations\": [\
			\"Age\",\
			\"Count\",\
			\"Distance\",\
			\"Duration\",\
			\"Money\"\
		],\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Quantity.id\",\
		\"weight\": 72,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Quantity.extension\",\
		\"weight\": 73,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Quantity.value\",\
		\"weight\": 74,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Quantity.comparator\",\
		\"weight\": 75,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Quantity.unit\",\
		\"weight\": 76,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Quantity.system\",\
		\"weight\": 77,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Quantity.code\",\
		\"weight\": 78,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Period\",\
		\"weight\": 79,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Period.id\",\
		\"weight\": 80,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Period.extension\",\
		\"weight\": 81,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Period.start\",\
		\"weight\": 82,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Period.end\",\
		\"weight\": 83,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment\",\
		\"weight\": 84,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.id\",\
		\"weight\": 85,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.extension\",\
		\"weight\": 86,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.contentType\",\
		\"weight\": 87,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.language\",\
		\"weight\": 88,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.data\",\
		\"weight\": 89,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.url\",\
		\"weight\": 90,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.size\",\
		\"weight\": 91,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.hash\",\
		\"weight\": 92,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.title\",\
		\"weight\": 93,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Attachment.creation\",\
		\"weight\": 94,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Duration\",\
		\"weight\": 95,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Duration.id\",\
		\"weight\": 96,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Duration.extension\",\
		\"weight\": 97,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Duration.value\",\
		\"weight\": 98,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Duration.comparator\",\
		\"weight\": 99,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Duration.unit\",\
		\"weight\": 100,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Duration.system\",\
		\"weight\": 101,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Duration.code\",\
		\"weight\": 102,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Count\",\
		\"weight\": 103,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Count.id\",\
		\"weight\": 104,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Count.extension\",\
		\"weight\": 105,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Count.value\",\
		\"weight\": 106,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Count.comparator\",\
		\"weight\": 107,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Count.unit\",\
		\"weight\": 108,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Count.system\",\
		\"weight\": 109,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Count.code\",\
		\"weight\": 110,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Range\",\
		\"weight\": 111,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Range.id\",\
		\"weight\": 112,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Range.extension\",\
		\"weight\": 113,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Range.low\",\
		\"weight\": 114,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Range.high\",\
		\"weight\": 115,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Annotation\",\
		\"weight\": 116,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Annotation.id\",\
		\"weight\": 117,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Annotation.extension\",\
		\"weight\": 118,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 119,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 119,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 119,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Annotation.authorString\",\
		\"weight\": 119,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Annotation.time\",\
		\"weight\": 120,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Annotation.text\",\
		\"weight\": 121,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Money\",\
		\"weight\": 122,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Money.id\",\
		\"weight\": 123,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Money.extension\",\
		\"weight\": 124,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Money.value\",\
		\"weight\": 125,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Money.comparator\",\
		\"weight\": 126,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Money.unit\",\
		\"weight\": 127,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Money.system\",\
		\"weight\": 128,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Money.code\",\
		\"weight\": 129,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier\",\
		\"weight\": 130,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier.id\",\
		\"weight\": 131,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier.extension\",\
		\"weight\": 132,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier.use\",\
		\"weight\": 133,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier.type\",\
		\"weight\": 134,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier.system\",\
		\"weight\": 135,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier.value\",\
		\"weight\": 136,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier.period\",\
		\"weight\": 137,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Identifier.assigner\",\
		\"weight\": 138,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coding\",\
		\"weight\": 139,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coding.id\",\
		\"weight\": 140,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coding.extension\",\
		\"weight\": 141,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coding.system\",\
		\"weight\": 142,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coding.version\",\
		\"weight\": 143,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coding.code\",\
		\"weight\": 144,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coding.display\",\
		\"weight\": 145,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coding.userSelected\",\
		\"weight\": 146,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature\",\
		\"weight\": 147,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.id\",\
		\"weight\": 148,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.extension\",\
		\"weight\": 149,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Signature.type\",\
		\"weight\": 150,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Signature.when\",\
		\"weight\": 151,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Signature.whoUri\",\
		\"weight\": 152,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 152,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.onBehalfOfUri\",\
		\"weight\": 153,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 153,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.contentType\",\
		\"weight\": 154,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Signature.blob\",\
		\"weight\": 155,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SampledData\",\
		\"weight\": 156,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SampledData.id\",\
		\"weight\": 157,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SampledData.extension\",\
		\"weight\": 158,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SampledData.origin\",\
		\"weight\": 159,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SampledData.period\",\
		\"weight\": 160,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SampledData.factor\",\
		\"weight\": 161,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SampledData.lowerLimit\",\
		\"weight\": 162,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SampledData.upperLimit\",\
		\"weight\": 163,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SampledData.dimensions\",\
		\"weight\": 164,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SampledData.data\",\
		\"weight\": 165,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Ratio\",\
		\"weight\": 166,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Ratio.id\",\
		\"weight\": 167,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Ratio.extension\",\
		\"weight\": 168,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Ratio.numerator\",\
		\"weight\": 169,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Ratio.denominator\",\
		\"weight\": 170,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Distance\",\
		\"weight\": 171,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Distance.id\",\
		\"weight\": 172,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Distance.extension\",\
		\"weight\": 173,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Distance.value\",\
		\"weight\": 174,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Distance.comparator\",\
		\"weight\": 175,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Distance.unit\",\
		\"weight\": 176,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Distance.system\",\
		\"weight\": 177,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Distance.code\",\
		\"weight\": 178,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Age\",\
		\"weight\": 179,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Age.id\",\
		\"weight\": 180,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Age.extension\",\
		\"weight\": 181,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Age.value\",\
		\"weight\": 182,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Age.comparator\",\
		\"weight\": 183,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Age.unit\",\
		\"weight\": 184,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Age.system\",\
		\"weight\": 185,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Age.code\",\
		\"weight\": 186,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeableConcept\",\
		\"weight\": 187,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeableConcept.id\",\
		\"weight\": 188,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeableConcept.extension\",\
		\"weight\": 189,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeableConcept.coding\",\
		\"weight\": 190,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeableConcept.text\",\
		\"weight\": 191,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension\",\
		\"weight\": 192,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.id\",\
		\"weight\": 193,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.extension\",\
		\"weight\": 194,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Extension.url\",\
		\"weight\": 195,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueBase64Binary\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueBoolean\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueCode\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueDate\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueDateTime\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueDecimal\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueId\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueInstant\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueInteger\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueMarkdown\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueOid\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valuePositiveInt\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueString\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueTime\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueUnsignedInt\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueUri\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueAddress\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueAge\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueAnnotation\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueAttachment\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueCodeableConcept\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueCoding\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueContactPoint\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueCount\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueDistance\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueDuration\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueHumanName\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueIdentifier\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueMoney\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valuePeriod\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueQuantity\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueRange\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueRatio\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueReference\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueSampledData\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueSignature\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueTiming\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Extension.valueMeta\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BackboneElement\",\
		\"weight\": 197,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BackboneElement.id\",\
		\"weight\": 198,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BackboneElement.extension\",\
		\"weight\": 199,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BackboneElement.modifierExtension\",\
		\"weight\": 200,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Narrative\",\
		\"weight\": 201,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Narrative.id\",\
		\"weight\": 202,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Narrative.extension\",\
		\"weight\": 203,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Narrative.status\",\
		\"weight\": 204,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Narrative.div\",\
		\"weight\": 205,\
		\"max\": \"1\",\
		\"type\": \"xhtml\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Element\",\
		\"weight\": 206,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
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
		]\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Element.id\",\
		\"weight\": 207,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Element.extension\",\
		\"weight\": 208,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Meta\",\
		\"weight\": 209,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Meta.id\",\
		\"weight\": 210,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Meta.extension\",\
		\"weight\": 211,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Meta.versionId\",\
		\"weight\": 212,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Meta.lastUpdated\",\
		\"weight\": 213,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Meta.profile\",\
		\"weight\": 214,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Meta.security\",\
		\"weight\": 215,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Meta.tag\",\
		\"weight\": 216,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedResource\",\
		\"weight\": 217,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedResource.id\",\
		\"weight\": 218,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedResource.extension\",\
		\"weight\": 219,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"RelatedResource.type\",\
		\"weight\": 220,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedResource.display\",\
		\"weight\": 221,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedResource.citation\",\
		\"weight\": 222,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedResource.url\",\
		\"weight\": 223,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedResource.document\",\
		\"weight\": 224,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedResource.resource\",\
		\"weight\": 225,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address\",\
		\"weight\": 226,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.id\",\
		\"weight\": 227,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.extension\",\
		\"weight\": 228,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.use\",\
		\"weight\": 229,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.type\",\
		\"weight\": 230,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.text\",\
		\"weight\": 231,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.line\",\
		\"weight\": 232,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.city\",\
		\"weight\": 233,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.district\",\
		\"weight\": 234,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.state\",\
		\"weight\": 235,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.postalCode\",\
		\"weight\": 236,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.country\",\
		\"weight\": 237,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Address.period\",\
		\"weight\": 238,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition\",\
		\"weight\": 239,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition.id\",\
		\"weight\": 240,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition.extension\",\
		\"weight\": 241,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TriggerDefinition.type\",\
		\"weight\": 242,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition.eventName\",\
		\"weight\": 243,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition.eventTimingTiming\",\
		\"weight\": 244,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition.eventTimingReference\",\
		\"weight\": 244,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition.eventTimingDate\",\
		\"weight\": 244,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition.eventTimingDateTime\",\
		\"weight\": 244,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TriggerDefinition.eventData\",\
		\"weight\": 245,\
		\"max\": \"1\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contributor\",\
		\"weight\": 246,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contributor.id\",\
		\"weight\": 247,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contributor.extension\",\
		\"weight\": 248,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contributor.type\",\
		\"weight\": 249,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contributor.name\",\
		\"weight\": 250,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contributor.contact\",\
		\"weight\": 251,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement\",\
		\"weight\": 252,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.id\",\
		\"weight\": 253,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.extension\",\
		\"weight\": 254,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DataRequirement.type\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.profile\",\
		\"weight\": 256,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.mustSupport\",\
		\"weight\": 257,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.codeFilter\",\
		\"weight\": 258,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.codeFilter.id\",\
		\"weight\": 259,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.codeFilter.extension\",\
		\"weight\": 260,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DataRequirement.codeFilter.path\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.codeFilter.valueSetString\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.codeFilter.valueSetReference\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.codeFilter.valueCode\",\
		\"weight\": 263,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.codeFilter.valueCoding\",\
		\"weight\": 264,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.codeFilter.valueCodeableConcept\",\
		\"weight\": 265,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.dateFilter\",\
		\"weight\": 266,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.dateFilter.id\",\
		\"weight\": 267,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.dateFilter.extension\",\
		\"weight\": 268,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DataRequirement.dateFilter.path\",\
		\"weight\": 269,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.dateFilter.valueDateTime\",\
		\"weight\": 270,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.dateFilter.valuePeriod\",\
		\"weight\": 270,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataRequirement.dateFilter.valueDuration\",\
		\"weight\": 270,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactDetail\",\
		\"weight\": 271,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactDetail.id\",\
		\"weight\": 272,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactDetail.extension\",\
		\"weight\": 273,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactDetail.name\",\
		\"weight\": 274,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactDetail.telecom\",\
		\"weight\": 275,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName\",\
		\"weight\": 276,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.id\",\
		\"weight\": 277,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.extension\",\
		\"weight\": 278,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.use\",\
		\"weight\": 279,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.text\",\
		\"weight\": 280,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.family\",\
		\"weight\": 281,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.given\",\
		\"weight\": 282,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.prefix\",\
		\"weight\": 283,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.suffix\",\
		\"weight\": 284,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HumanName.period\",\
		\"weight\": 285,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactPoint\",\
		\"weight\": 286,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactPoint.id\",\
		\"weight\": 287,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactPoint.extension\",\
		\"weight\": 288,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactPoint.system\",\
		\"weight\": 289,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactPoint.value\",\
		\"weight\": 290,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactPoint.use\",\
		\"weight\": 291,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactPoint.rank\",\
		\"weight\": 292,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ContactPoint.period\",\
		\"weight\": 293,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext\",\
		\"weight\": 294,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.id\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.extension\",\
		\"weight\": 296,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.patientGender\",\
		\"weight\": 297,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.patientAgeGroup\",\
		\"weight\": 298,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.clinicalFocus\",\
		\"weight\": 299,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.targetUser\",\
		\"weight\": 300,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.workflowSetting\",\
		\"weight\": 301,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.workflowTask\",\
		\"weight\": 302,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.clinicalVenue\",\
		\"weight\": 303,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"UsageContext.jurisdiction\",\
		\"weight\": 304,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing\",\
		\"weight\": 305,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.id\",\
		\"weight\": 306,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.extension\",\
		\"weight\": 307,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.event\",\
		\"weight\": 308,\
		\"max\": \"*\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat\",\
		\"weight\": 309,\
		\"max\": \"1\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.id\",\
		\"weight\": 310,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.extension\",\
		\"weight\": 311,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.boundsDuration\",\
		\"weight\": 312,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.boundsRange\",\
		\"weight\": 312,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.boundsPeriod\",\
		\"weight\": 312,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.count\",\
		\"weight\": 313,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.countMax\",\
		\"weight\": 314,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.duration\",\
		\"weight\": 315,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.durationMax\",\
		\"weight\": 316,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.durationUnit\",\
		\"weight\": 317,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.frequency\",\
		\"weight\": 318,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.frequencyMax\",\
		\"weight\": 319,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.period\",\
		\"weight\": 320,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.periodMax\",\
		\"weight\": 321,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.periodUnit\",\
		\"weight\": 322,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.when\",\
		\"weight\": 323,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.repeat.offset\",\
		\"weight\": 324,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Timing.code\",\
		\"weight\": 325,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition\",\
		\"weight\": 326,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.id\",\
		\"weight\": 327,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.extension\",\
		\"weight\": 328,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.path\",\
		\"weight\": 329,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.representation\",\
		\"weight\": 330,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.name\",\
		\"weight\": 331,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.label\",\
		\"weight\": 332,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.code\",\
		\"weight\": 333,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.slicing\",\
		\"weight\": 334,\
		\"max\": \"1\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.slicing.id\",\
		\"weight\": 335,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.slicing.extension\",\
		\"weight\": 336,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.slicing.discriminator\",\
		\"weight\": 337,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.slicing.description\",\
		\"weight\": 338,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.slicing.ordered\",\
		\"weight\": 339,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.slicing.rules\",\
		\"weight\": 340,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.short\",\
		\"weight\": 341,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.definition\",\
		\"weight\": 342,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.comments\",\
		\"weight\": 343,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.requirements\",\
		\"weight\": 344,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.alias\",\
		\"weight\": 345,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.min\",\
		\"weight\": 346,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.max\",\
		\"weight\": 347,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.base\",\
		\"weight\": 348,\
		\"max\": \"1\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.base.id\",\
		\"weight\": 349,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.base.extension\",\
		\"weight\": 350,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.base.path\",\
		\"weight\": 351,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.base.min\",\
		\"weight\": 352,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.base.max\",\
		\"weight\": 353,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.contentReference\",\
		\"weight\": 354,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.type\",\
		\"weight\": 355,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.type.id\",\
		\"weight\": 356,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.type.extension\",\
		\"weight\": 357,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.type.code\",\
		\"weight\": 358,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.type.profile\",\
		\"weight\": 359,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.type.targetProfile\",\
		\"weight\": 360,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.type.aggregation\",\
		\"weight\": 361,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.type.versioning\",\
		\"weight\": 362,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueBase64Binary\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueBoolean\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueCode\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueDate\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueDateTime\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueDecimal\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueId\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueInstant\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueInteger\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueMarkdown\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueOid\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValuePositiveInt\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueString\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueTime\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueUnsignedInt\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueUri\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueAddress\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueAge\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueAnnotation\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueAttachment\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueCodeableConcept\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueCoding\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueContactPoint\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueCount\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueDistance\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueDuration\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueHumanName\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueIdentifier\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueMoney\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValuePeriod\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueQuantity\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueRange\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueRatio\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueReference\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueSampledData\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueSignature\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueTiming\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.defaultValueMeta\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.meaningWhenMissing\",\
		\"weight\": 364,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedBase64Binary\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedBoolean\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedCode\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedDate\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedDateTime\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedDecimal\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedId\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedInstant\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedInteger\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedMarkdown\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedOid\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedPositiveInt\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedString\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedTime\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedUnsignedInt\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedUri\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedAddress\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedAge\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedAnnotation\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedAttachment\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedCodeableConcept\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedCoding\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedContactPoint\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedCount\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedDistance\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedDuration\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedHumanName\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedIdentifier\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedMoney\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedPeriod\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedQuantity\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedRange\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedRatio\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedReference\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedSampledData\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedSignature\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedTiming\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.fixedMeta\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternBase64Binary\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternBoolean\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternCode\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternDate\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternDateTime\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternDecimal\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternId\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternInstant\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternInteger\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternMarkdown\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternOid\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternPositiveInt\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternString\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternTime\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternUnsignedInt\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternUri\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternAddress\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternAge\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternAnnotation\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternAttachment\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternCodeableConcept\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternCoding\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternContactPoint\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternCount\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternDistance\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternDuration\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternHumanName\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternIdentifier\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternMoney\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternPeriod\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternQuantity\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternRange\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternRatio\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternReference\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternSampledData\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternSignature\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternTiming\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.patternMeta\",\
		\"weight\": 366,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleBase64Binary\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleBoolean\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleCode\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleDate\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleDateTime\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleDecimal\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleId\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleInstant\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleInteger\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleMarkdown\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleOid\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.examplePositiveInt\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleString\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleTime\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleUnsignedInt\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleUri\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleAddress\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleAge\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleAnnotation\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleAttachment\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleCodeableConcept\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleCoding\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleContactPoint\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleCount\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleDistance\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleDuration\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleHumanName\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleIdentifier\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleMoney\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.examplePeriod\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleQuantity\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleRange\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleRatio\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleReference\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleSampledData\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleSignature\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleTiming\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.exampleMeta\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValueDate\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValueDateTime\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValueInstant\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValueTime\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValueDecimal\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValueInteger\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValuePositiveInt\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValueUnsignedInt\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.minValueQuantity\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValueDate\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValueDateTime\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValueInstant\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValueTime\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValueDecimal\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValueInteger\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValuePositiveInt\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValueUnsignedInt\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxValueQuantity\",\
		\"weight\": 369,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.maxLength\",\
		\"weight\": 370,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.condition\",\
		\"weight\": 371,\
		\"max\": \"*\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.constraint\",\
		\"weight\": 372,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.constraint.id\",\
		\"weight\": 373,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.constraint.extension\",\
		\"weight\": 374,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.constraint.key\",\
		\"weight\": 375,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.constraint.requirements\",\
		\"weight\": 376,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.constraint.severity\",\
		\"weight\": 377,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.constraint.human\",\
		\"weight\": 378,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.constraint.expression\",\
		\"weight\": 379,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.constraint.xpath\",\
		\"weight\": 380,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.mustSupport\",\
		\"weight\": 381,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.isModifier\",\
		\"weight\": 382,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.isSummary\",\
		\"weight\": 383,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.binding\",\
		\"weight\": 384,\
		\"max\": \"1\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.binding.id\",\
		\"weight\": 385,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.binding.extension\",\
		\"weight\": 386,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.binding.strength\",\
		\"weight\": 387,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.binding.description\",\
		\"weight\": 388,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.binding.valueSetUri\",\
		\"weight\": 389,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.binding.valueSetReference\",\
		\"weight\": 389,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.mapping\",\
		\"weight\": 390,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.mapping.id\",\
		\"weight\": 391,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.mapping.extension\",\
		\"weight\": 392,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.mapping.identity\",\
		\"weight\": 393,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ElementDefinition.mapping.language\",\
		\"weight\": 394,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ElementDefinition.mapping.map\",\
		\"weight\": 395,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ParameterDefinition\",\
		\"weight\": 396,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ParameterDefinition.id\",\
		\"weight\": 397,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ParameterDefinition.extension\",\
		\"weight\": 398,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ParameterDefinition.name\",\
		\"weight\": 399,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ParameterDefinition.use\",\
		\"weight\": 400,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ParameterDefinition.min\",\
		\"weight\": 401,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ParameterDefinition.max\",\
		\"weight\": 402,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ParameterDefinition.documentation\",\
		\"weight\": 403,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ParameterDefinition.type\",\
		\"weight\": 404,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ParameterDefinition.profile\",\
		\"weight\": 405,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem\",\
		\"weight\": 406,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.id\",\
		\"weight\": 407,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.meta\",\
		\"weight\": 408,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.implicitRules\",\
		\"weight\": 409,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.language\",\
		\"weight\": 410,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.text\",\
		\"weight\": 411,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.contained\",\
		\"weight\": 412,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.extension\",\
		\"weight\": 413,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.modifierExtension\",\
		\"weight\": 414,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.url\",\
		\"weight\": 415,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.identifier\",\
		\"weight\": 416,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.version\",\
		\"weight\": 417,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.name\",\
		\"weight\": 418,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.status\",\
		\"weight\": 419,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.experimental\",\
		\"weight\": 420,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.publisher\",\
		\"weight\": 421,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.contact\",\
		\"weight\": 422,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.contact.id\",\
		\"weight\": 423,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.contact.extension\",\
		\"weight\": 424,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.contact.modifierExtension\",\
		\"weight\": 425,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.contact.name\",\
		\"weight\": 426,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.contact.telecom\",\
		\"weight\": 427,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.date\",\
		\"weight\": 428,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.description\",\
		\"weight\": 429,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.useContext\",\
		\"weight\": 430,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.requirements\",\
		\"weight\": 431,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.copyright\",\
		\"weight\": 432,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.caseSensitive\",\
		\"weight\": 433,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.valueSet\",\
		\"weight\": 434,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.hierarchyMeaning\",\
		\"weight\": 435,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.compositional\",\
		\"weight\": 436,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.versionNeeded\",\
		\"weight\": 437,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.content\",\
		\"weight\": 438,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.count\",\
		\"weight\": 439,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.filter\",\
		\"weight\": 440,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.filter.id\",\
		\"weight\": 441,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.filter.extension\",\
		\"weight\": 442,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.filter.modifierExtension\",\
		\"weight\": 443,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.filter.code\",\
		\"weight\": 444,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.filter.description\",\
		\"weight\": 445,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.filter.operator\",\
		\"weight\": 446,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.filter.value\",\
		\"weight\": 447,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.property\",\
		\"weight\": 448,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.property.id\",\
		\"weight\": 449,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.property.extension\",\
		\"weight\": 450,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.property.modifierExtension\",\
		\"weight\": 451,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.property.code\",\
		\"weight\": 452,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.property.uri\",\
		\"weight\": 453,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.property.description\",\
		\"weight\": 454,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.property.type\",\
		\"weight\": 455,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept\",\
		\"weight\": 456,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.id\",\
		\"weight\": 457,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.extension\",\
		\"weight\": 458,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.modifierExtension\",\
		\"weight\": 459,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.code\",\
		\"weight\": 460,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.display\",\
		\"weight\": 461,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.definition\",\
		\"weight\": 462,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.designation\",\
		\"weight\": 463,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.designation.id\",\
		\"weight\": 464,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.designation.extension\",\
		\"weight\": 465,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.designation.modifierExtension\",\
		\"weight\": 466,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.designation.language\",\
		\"weight\": 467,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.designation.use\",\
		\"weight\": 468,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.designation.value\",\
		\"weight\": 469,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.property\",\
		\"weight\": 470,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.property.id\",\
		\"weight\": 471,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.property.extension\",\
		\"weight\": 472,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.property.modifierExtension\",\
		\"weight\": 473,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.property.code\",\
		\"weight\": 474,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.property.valueCode\",\
		\"weight\": 475,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.property.valueCoding\",\
		\"weight\": 475,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.property.valueString\",\
		\"weight\": 475,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.property.valueInteger\",\
		\"weight\": 475,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.property.valueBoolean\",\
		\"weight\": 475,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CodeSystem.concept.property.valueDateTime\",\
		\"weight\": 475,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CodeSystem.concept.concept\",\
		\"weight\": 476,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet\",\
		\"weight\": 477,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.id\",\
		\"weight\": 478,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.meta\",\
		\"weight\": 479,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.implicitRules\",\
		\"weight\": 480,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.language\",\
		\"weight\": 481,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.text\",\
		\"weight\": 482,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.contained\",\
		\"weight\": 483,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.extension\",\
		\"weight\": 484,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.modifierExtension\",\
		\"weight\": 485,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.url\",\
		\"weight\": 486,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.identifier\",\
		\"weight\": 487,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.version\",\
		\"weight\": 488,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.name\",\
		\"weight\": 489,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.status\",\
		\"weight\": 490,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.experimental\",\
		\"weight\": 491,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.publisher\",\
		\"weight\": 492,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.contact\",\
		\"weight\": 493,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.contact.id\",\
		\"weight\": 494,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.contact.extension\",\
		\"weight\": 495,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.contact.modifierExtension\",\
		\"weight\": 496,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.contact.name\",\
		\"weight\": 497,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.contact.telecom\",\
		\"weight\": 498,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.date\",\
		\"weight\": 499,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.lockedDate\",\
		\"weight\": 500,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.description\",\
		\"weight\": 501,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.useContext\",\
		\"weight\": 502,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.immutable\",\
		\"weight\": 503,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.requirements\",\
		\"weight\": 504,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.copyright\",\
		\"weight\": 505,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.extensible\",\
		\"weight\": 506,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose\",\
		\"weight\": 507,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.id\",\
		\"weight\": 508,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.extension\",\
		\"weight\": 509,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.modifierExtension\",\
		\"weight\": 510,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.import\",\
		\"weight\": 511,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include\",\
		\"weight\": 512,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.id\",\
		\"weight\": 513,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.extension\",\
		\"weight\": 514,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.modifierExtension\",\
		\"weight\": 515,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.compose.include.system\",\
		\"weight\": 516,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.version\",\
		\"weight\": 517,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept\",\
		\"weight\": 518,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.id\",\
		\"weight\": 519,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.extension\",\
		\"weight\": 520,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.modifierExtension\",\
		\"weight\": 521,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.compose.include.concept.code\",\
		\"weight\": 522,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.display\",\
		\"weight\": 523,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.designation\",\
		\"weight\": 524,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.designation.id\",\
		\"weight\": 525,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.designation.extension\",\
		\"weight\": 526,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.designation.modifierExtension\",\
		\"weight\": 527,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.designation.language\",\
		\"weight\": 528,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.concept.designation.use\",\
		\"weight\": 529,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.compose.include.concept.designation.value\",\
		\"weight\": 530,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.filter\",\
		\"weight\": 531,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.filter.id\",\
		\"weight\": 532,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.filter.extension\",\
		\"weight\": 533,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.include.filter.modifierExtension\",\
		\"weight\": 534,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.compose.include.filter.property\",\
		\"weight\": 535,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.compose.include.filter.op\",\
		\"weight\": 536,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.compose.include.filter.value\",\
		\"weight\": 537,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.compose.exclude\",\
		\"weight\": 538,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion\",\
		\"weight\": 539,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.id\",\
		\"weight\": 540,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.extension\",\
		\"weight\": 541,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.modifierExtension\",\
		\"weight\": 542,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.expansion.identifier\",\
		\"weight\": 543,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.expansion.timestamp\",\
		\"weight\": 544,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.total\",\
		\"weight\": 545,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.offset\",\
		\"weight\": 546,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter\",\
		\"weight\": 547,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.id\",\
		\"weight\": 548,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.extension\",\
		\"weight\": 549,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.modifierExtension\",\
		\"weight\": 550,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ValueSet.expansion.parameter.name\",\
		\"weight\": 551,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.valueString\",\
		\"weight\": 552,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.valueBoolean\",\
		\"weight\": 552,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.valueInteger\",\
		\"weight\": 552,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.valueDecimal\",\
		\"weight\": 552,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.valueUri\",\
		\"weight\": 552,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.parameter.valueCode\",\
		\"weight\": 552,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains\",\
		\"weight\": 553,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.id\",\
		\"weight\": 554,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.extension\",\
		\"weight\": 555,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.modifierExtension\",\
		\"weight\": 556,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.system\",\
		\"weight\": 557,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.abstract\",\
		\"weight\": 558,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.version\",\
		\"weight\": 559,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.code\",\
		\"weight\": 560,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.display\",\
		\"weight\": 561,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ValueSet.expansion.contains.contains\",\
		\"weight\": 562,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource\",\
		\"weight\": 563,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
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
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource.id\",\
		\"weight\": 564,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource.meta\",\
		\"weight\": 565,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource.implicitRules\",\
		\"weight\": 566,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource.language\",\
		\"weight\": 567,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource.text\",\
		\"weight\": 568,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource.contained\",\
		\"weight\": 569,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource.extension\",\
		\"weight\": 570,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DomainResource.modifierExtension\",\
		\"weight\": 571,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters\",\
		\"weight\": 572,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.id\",\
		\"weight\": 573,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.meta\",\
		\"weight\": 574,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.implicitRules\",\
		\"weight\": 575,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.language\",\
		\"weight\": 576,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter\",\
		\"weight\": 577,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.id\",\
		\"weight\": 578,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.extension\",\
		\"weight\": 579,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.modifierExtension\",\
		\"weight\": 580,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Parameters.parameter.name\",\
		\"weight\": 581,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueBase64Binary\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueBoolean\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueCode\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueDate\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueDateTime\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueDecimal\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueId\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueInstant\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueInteger\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueMarkdown\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueOid\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valuePositiveInt\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueString\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueTime\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueUnsignedInt\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueUri\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueAddress\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueAge\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueAnnotation\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueAttachment\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueCodeableConcept\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueCoding\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueContactPoint\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueCount\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueDistance\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueDuration\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueHumanName\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueIdentifier\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueMoney\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valuePeriod\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueQuantity\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueRange\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueRatio\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueReference\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueSampledData\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueSignature\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueTiming\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.valueMeta\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.resource\",\
		\"weight\": 583,\
		\"max\": \"1\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Parameters.parameter.part\",\
		\"weight\": 584,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Resource\",\
		\"weight\": 585,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"derivations\": [\
			\"Binary\",\
			\"Bundle\",\
			\"DomainResource\",\
			\"Parameters\"\
		]\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Resource.id\",\
		\"weight\": 586,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Resource.meta\",\
		\"weight\": 587,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Resource.implicitRules\",\
		\"weight\": 588,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Resource.language\",\
		\"weight\": 589,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account\",\
		\"weight\": 590,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.id\",\
		\"weight\": 591,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.meta\",\
		\"weight\": 592,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.implicitRules\",\
		\"weight\": 593,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.language\",\
		\"weight\": 594,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.text\",\
		\"weight\": 595,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.contained\",\
		\"weight\": 596,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.extension\",\
		\"weight\": 597,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.modifierExtension\",\
		\"weight\": 598,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.identifier\",\
		\"weight\": 599,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.name\",\
		\"weight\": 600,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.type\",\
		\"weight\": 601,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.status\",\
		\"weight\": 602,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.active\",\
		\"weight\": 603,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.currency\",\
		\"weight\": 604,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.balance\",\
		\"weight\": 605,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.coverage\",\
		\"weight\": 606,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.coveragePeriod\",\
		\"weight\": 607,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.subject\",\
		\"weight\": 608,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.owner\",\
		\"weight\": 609,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Account.description\",\
		\"weight\": 610,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition\",\
		\"weight\": 611,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.id\",\
		\"weight\": 612,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.meta\",\
		\"weight\": 613,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.implicitRules\",\
		\"weight\": 614,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.language\",\
		\"weight\": 615,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.text\",\
		\"weight\": 616,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.contained\",\
		\"weight\": 617,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.extension\",\
		\"weight\": 618,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.modifierExtension\",\
		\"weight\": 619,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.url\",\
		\"weight\": 620,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.identifier\",\
		\"weight\": 621,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.version\",\
		\"weight\": 622,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.name\",\
		\"weight\": 623,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.title\",\
		\"weight\": 624,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ActivityDefinition.status\",\
		\"weight\": 625,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.experimental\",\
		\"weight\": 626,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.description\",\
		\"weight\": 627,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.purpose\",\
		\"weight\": 628,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.usage\",\
		\"weight\": 629,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.publicationDate\",\
		\"weight\": 630,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.lastReviewDate\",\
		\"weight\": 631,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.effectivePeriod\",\
		\"weight\": 632,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.coverage\",\
		\"weight\": 633,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.topic\",\
		\"weight\": 634,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.contributor\",\
		\"weight\": 635,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.publisher\",\
		\"weight\": 636,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.contact\",\
		\"weight\": 637,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.copyright\",\
		\"weight\": 638,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.relatedResource\",\
		\"weight\": 639,\
		\"max\": \"*\",\
		\"type\": \"RelatedResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.library\",\
		\"weight\": 640,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.category\",\
		\"weight\": 641,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.code\",\
		\"weight\": 642,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.timingCodeableConcept\",\
		\"weight\": 643,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.timingTiming\",\
		\"weight\": 643,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.location\",\
		\"weight\": 644,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.participantType\",\
		\"weight\": 645,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.productReference\",\
		\"weight\": 646,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.productReference\",\
		\"weight\": 646,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.productCodeableConcept\",\
		\"weight\": 646,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.quantity\",\
		\"weight\": 647,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.transform\",\
		\"weight\": 648,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.dynamicValue\",\
		\"weight\": 649,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.dynamicValue.id\",\
		\"weight\": 650,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.dynamicValue.extension\",\
		\"weight\": 651,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.dynamicValue.modifierExtension\",\
		\"weight\": 652,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.dynamicValue.description\",\
		\"weight\": 653,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.dynamicValue.path\",\
		\"weight\": 654,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.dynamicValue.language\",\
		\"weight\": 655,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ActivityDefinition.dynamicValue.expression\",\
		\"weight\": 656,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance\",\
		\"weight\": 657,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.id\",\
		\"weight\": 658,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.meta\",\
		\"weight\": 659,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.implicitRules\",\
		\"weight\": 660,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.language\",\
		\"weight\": 661,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.text\",\
		\"weight\": 662,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.contained\",\
		\"weight\": 663,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.extension\",\
		\"weight\": 664,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.modifierExtension\",\
		\"weight\": 665,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.identifier\",\
		\"weight\": 666,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.status\",\
		\"weight\": 667,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.type\",\
		\"weight\": 668,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.category\",\
		\"weight\": 669,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.criticality\",\
		\"weight\": 670,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.code\",\
		\"weight\": 671,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AllergyIntolerance.patient\",\
		\"weight\": 672,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.attestedDate\",\
		\"weight\": 673,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.recorder\",\
		\"weight\": 674,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reporter\",\
		\"weight\": 675,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.onset\",\
		\"weight\": 676,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.lastOccurrence\",\
		\"weight\": 677,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.note\",\
		\"weight\": 678,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction\",\
		\"weight\": 679,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.id\",\
		\"weight\": 680,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.extension\",\
		\"weight\": 681,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.modifierExtension\",\
		\"weight\": 682,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.substance\",\
		\"weight\": 683,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.certainty\",\
		\"weight\": 684,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AllergyIntolerance.reaction.manifestation\",\
		\"weight\": 685,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.description\",\
		\"weight\": 686,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.onset\",\
		\"weight\": 687,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.severity\",\
		\"weight\": 688,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.exposureRoute\",\
		\"weight\": 689,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AllergyIntolerance.reaction.note\",\
		\"weight\": 690,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment\",\
		\"weight\": 691,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.id\",\
		\"weight\": 692,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.meta\",\
		\"weight\": 693,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.implicitRules\",\
		\"weight\": 694,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.language\",\
		\"weight\": 695,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.text\",\
		\"weight\": 696,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.contained\",\
		\"weight\": 697,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.extension\",\
		\"weight\": 698,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.modifierExtension\",\
		\"weight\": 699,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.identifier\",\
		\"weight\": 700,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Appointment.status\",\
		\"weight\": 701,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.serviceCategory\",\
		\"weight\": 702,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.serviceType\",\
		\"weight\": 703,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.specialty\",\
		\"weight\": 704,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.appointmentType\",\
		\"weight\": 705,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.reason\",\
		\"weight\": 706,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.priority\",\
		\"weight\": 707,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.description\",\
		\"weight\": 708,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.start\",\
		\"weight\": 709,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.end\",\
		\"weight\": 710,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.minutesDuration\",\
		\"weight\": 711,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.slot\",\
		\"weight\": 712,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.created\",\
		\"weight\": 713,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.comment\",\
		\"weight\": 714,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Appointment.participant\",\
		\"weight\": 715,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.participant.id\",\
		\"weight\": 716,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.participant.extension\",\
		\"weight\": 717,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.participant.modifierExtension\",\
		\"weight\": 718,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.participant.type\",\
		\"weight\": 719,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.participant.actor\",\
		\"weight\": 720,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Appointment.participant.required\",\
		\"weight\": 721,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Appointment.participant.status\",\
		\"weight\": 722,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse\",\
		\"weight\": 723,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.id\",\
		\"weight\": 724,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.meta\",\
		\"weight\": 725,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.implicitRules\",\
		\"weight\": 726,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.language\",\
		\"weight\": 727,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.text\",\
		\"weight\": 728,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.contained\",\
		\"weight\": 729,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.extension\",\
		\"weight\": 730,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.modifierExtension\",\
		\"weight\": 731,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.identifier\",\
		\"weight\": 732,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AppointmentResponse.appointment\",\
		\"weight\": 733,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.start\",\
		\"weight\": 734,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.end\",\
		\"weight\": 735,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.participantType\",\
		\"weight\": 736,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.actor\",\
		\"weight\": 737,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AppointmentResponse.participantStatus\",\
		\"weight\": 738,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AppointmentResponse.comment\",\
		\"weight\": 739,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent\",\
		\"weight\": 740,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.id\",\
		\"weight\": 741,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.meta\",\
		\"weight\": 742,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.implicitRules\",\
		\"weight\": 743,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.language\",\
		\"weight\": 744,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.text\",\
		\"weight\": 745,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.contained\",\
		\"weight\": 746,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.extension\",\
		\"weight\": 747,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.modifierExtension\",\
		\"weight\": 748,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AuditEvent.type\",\
		\"weight\": 749,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.subtype\",\
		\"weight\": 750,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.action\",\
		\"weight\": 751,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AuditEvent.recorded\",\
		\"weight\": 752,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.outcome\",\
		\"weight\": 753,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.outcomeDesc\",\
		\"weight\": 754,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.purposeOfEvent\",\
		\"weight\": 755,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AuditEvent.agent\",\
		\"weight\": 756,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.id\",\
		\"weight\": 757,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.extension\",\
		\"weight\": 758,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.modifierExtension\",\
		\"weight\": 759,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.role\",\
		\"weight\": 760,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.reference\",\
		\"weight\": 761,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.userId\",\
		\"weight\": 762,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.altId\",\
		\"weight\": 763,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.name\",\
		\"weight\": 764,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AuditEvent.agent.requestor\",\
		\"weight\": 765,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.location\",\
		\"weight\": 766,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.policy\",\
		\"weight\": 767,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.media\",\
		\"weight\": 768,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.network\",\
		\"weight\": 769,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.network.id\",\
		\"weight\": 770,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.network.extension\",\
		\"weight\": 771,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.network.modifierExtension\",\
		\"weight\": 772,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.network.address\",\
		\"weight\": 773,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.network.type\",\
		\"weight\": 774,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.agent.purposeOfUse\",\
		\"weight\": 775,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AuditEvent.source\",\
		\"weight\": 776,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.source.id\",\
		\"weight\": 777,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.source.extension\",\
		\"weight\": 778,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.source.modifierExtension\",\
		\"weight\": 779,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.source.site\",\
		\"weight\": 780,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AuditEvent.source.identifier\",\
		\"weight\": 781,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.source.type\",\
		\"weight\": 782,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity\",\
		\"weight\": 783,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.id\",\
		\"weight\": 784,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.extension\",\
		\"weight\": 785,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.modifierExtension\",\
		\"weight\": 786,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.identifier\",\
		\"weight\": 787,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.reference\",\
		\"weight\": 788,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.type\",\
		\"weight\": 789,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.role\",\
		\"weight\": 790,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.lifecycle\",\
		\"weight\": 791,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.securityLabel\",\
		\"weight\": 792,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.name\",\
		\"weight\": 793,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.description\",\
		\"weight\": 794,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.query\",\
		\"weight\": 795,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.detail\",\
		\"weight\": 796,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.detail.id\",\
		\"weight\": 797,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.detail.extension\",\
		\"weight\": 798,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"AuditEvent.entity.detail.modifierExtension\",\
		\"weight\": 799,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AuditEvent.entity.detail.type\",\
		\"weight\": 800,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"AuditEvent.entity.detail.value\",\
		\"weight\": 801,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic\",\
		\"weight\": 802,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.id\",\
		\"weight\": 803,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.meta\",\
		\"weight\": 804,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.implicitRules\",\
		\"weight\": 805,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.language\",\
		\"weight\": 806,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.text\",\
		\"weight\": 807,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.contained\",\
		\"weight\": 808,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.extension\",\
		\"weight\": 809,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.modifierExtension\",\
		\"weight\": 810,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.identifier\",\
		\"weight\": 811,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Basic.code\",\
		\"weight\": 812,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.subject\",\
		\"weight\": 813,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.created\",\
		\"weight\": 814,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Basic.author\",\
		\"weight\": 815,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Binary\",\
		\"weight\": 816,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Binary.id\",\
		\"weight\": 817,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Binary.meta\",\
		\"weight\": 818,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Binary.implicitRules\",\
		\"weight\": 819,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Binary.language\",\
		\"weight\": 820,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Binary.contentType\",\
		\"weight\": 821,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Binary.content\",\
		\"weight\": 822,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite\",\
		\"weight\": 823,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.id\",\
		\"weight\": 824,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.meta\",\
		\"weight\": 825,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.implicitRules\",\
		\"weight\": 826,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.language\",\
		\"weight\": 827,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.text\",\
		\"weight\": 828,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.contained\",\
		\"weight\": 829,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.extension\",\
		\"weight\": 830,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.modifierExtension\",\
		\"weight\": 831,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"BodySite.patient\",\
		\"weight\": 832,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.identifier\",\
		\"weight\": 833,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.code\",\
		\"weight\": 834,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.modifier\",\
		\"weight\": 835,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.description\",\
		\"weight\": 836,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"BodySite.image\",\
		\"weight\": 837,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle\",\
		\"weight\": 838,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.id\",\
		\"weight\": 839,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.meta\",\
		\"weight\": 840,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.implicitRules\",\
		\"weight\": 841,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.language\",\
		\"weight\": 842,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Bundle.type\",\
		\"weight\": 843,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.total\",\
		\"weight\": 844,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.link\",\
		\"weight\": 845,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.link.id\",\
		\"weight\": 846,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.link.extension\",\
		\"weight\": 847,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.link.modifierExtension\",\
		\"weight\": 848,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Bundle.link.relation\",\
		\"weight\": 849,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Bundle.link.url\",\
		\"weight\": 850,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry\",\
		\"weight\": 851,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.id\",\
		\"weight\": 852,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.extension\",\
		\"weight\": 853,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.modifierExtension\",\
		\"weight\": 854,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.link\",\
		\"weight\": 855,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.fullUrl\",\
		\"weight\": 856,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.resource\",\
		\"weight\": 857,\
		\"max\": \"1\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.search\",\
		\"weight\": 858,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.search.id\",\
		\"weight\": 859,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.search.extension\",\
		\"weight\": 860,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.search.modifierExtension\",\
		\"weight\": 861,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.search.mode\",\
		\"weight\": 862,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.search.score\",\
		\"weight\": 863,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.request\",\
		\"weight\": 864,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.request.id\",\
		\"weight\": 865,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.request.extension\",\
		\"weight\": 866,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.request.modifierExtension\",\
		\"weight\": 867,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Bundle.entry.request.method\",\
		\"weight\": 868,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Bundle.entry.request.url\",\
		\"weight\": 869,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.request.ifNoneMatch\",\
		\"weight\": 870,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.request.ifModifiedSince\",\
		\"weight\": 871,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.request.ifMatch\",\
		\"weight\": 872,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.request.ifNoneExist\",\
		\"weight\": 873,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.response\",\
		\"weight\": 874,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.response.id\",\
		\"weight\": 875,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.response.extension\",\
		\"weight\": 876,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.response.modifierExtension\",\
		\"weight\": 877,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Bundle.entry.response.status\",\
		\"weight\": 878,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.response.location\",\
		\"weight\": 879,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.response.etag\",\
		\"weight\": 880,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.response.lastModified\",\
		\"weight\": 881,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.entry.response.outcome\",\
		\"weight\": 882,\
		\"max\": \"1\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Bundle.signature\",\
		\"weight\": 883,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan\",\
		\"weight\": 884,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.id\",\
		\"weight\": 885,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.meta\",\
		\"weight\": 886,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.implicitRules\",\
		\"weight\": 887,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.language\",\
		\"weight\": 888,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.text\",\
		\"weight\": 889,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.contained\",\
		\"weight\": 890,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.extension\",\
		\"weight\": 891,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.modifierExtension\",\
		\"weight\": 892,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.identifier\",\
		\"weight\": 893,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.subject\",\
		\"weight\": 894,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CarePlan.status\",\
		\"weight\": 895,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.context\",\
		\"weight\": 896,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.period\",\
		\"weight\": 897,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.author\",\
		\"weight\": 898,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.modified\",\
		\"weight\": 899,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.category\",\
		\"weight\": 900,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.description\",\
		\"weight\": 901,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.addresses\",\
		\"weight\": 902,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.support\",\
		\"weight\": 903,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.relatedPlan\",\
		\"weight\": 904,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.relatedPlan.id\",\
		\"weight\": 905,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.relatedPlan.extension\",\
		\"weight\": 906,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.relatedPlan.modifierExtension\",\
		\"weight\": 907,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.relatedPlan.code\",\
		\"weight\": 908,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CarePlan.relatedPlan.plan\",\
		\"weight\": 909,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.careTeam\",\
		\"weight\": 910,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.goal\",\
		\"weight\": 911,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity\",\
		\"weight\": 912,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.id\",\
		\"weight\": 913,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.extension\",\
		\"weight\": 914,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.modifierExtension\",\
		\"weight\": 915,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.actionResulting\",\
		\"weight\": 916,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.outcome\",\
		\"weight\": 917,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.progress\",\
		\"weight\": 918,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.reference\",\
		\"weight\": 919,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail\",\
		\"weight\": 920,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.id\",\
		\"weight\": 921,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.extension\",\
		\"weight\": 922,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.modifierExtension\",\
		\"weight\": 923,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.category\",\
		\"weight\": 924,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.definition\",\
		\"weight\": 925,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.code\",\
		\"weight\": 926,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.reasonCode\",\
		\"weight\": 927,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.reasonReference\",\
		\"weight\": 928,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.goal\",\
		\"weight\": 929,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.status\",\
		\"weight\": 930,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.statusReason\",\
		\"weight\": 931,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CarePlan.activity.detail.prohibited\",\
		\"weight\": 932,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.scheduledTiming\",\
		\"weight\": 933,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.scheduledPeriod\",\
		\"weight\": 933,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.scheduledString\",\
		\"weight\": 933,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.location\",\
		\"weight\": 934,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.performer\",\
		\"weight\": 935,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.productCodeableConcept\",\
		\"weight\": 936,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"weight\": 936,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"weight\": 936,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.dailyAmount\",\
		\"weight\": 937,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.quantity\",\
		\"weight\": 938,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.activity.detail.description\",\
		\"weight\": 939,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CarePlan.note\",\
		\"weight\": 940,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam\",\
		\"weight\": 941,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.id\",\
		\"weight\": 942,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.meta\",\
		\"weight\": 943,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.implicitRules\",\
		\"weight\": 944,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.language\",\
		\"weight\": 945,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.text\",\
		\"weight\": 946,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.contained\",\
		\"weight\": 947,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.extension\",\
		\"weight\": 948,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.modifierExtension\",\
		\"weight\": 949,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.identifier\",\
		\"weight\": 950,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.status\",\
		\"weight\": 951,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.type\",\
		\"weight\": 952,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.name\",\
		\"weight\": 953,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.subject\",\
		\"weight\": 954,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.period\",\
		\"weight\": 955,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.participant\",\
		\"weight\": 956,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.participant.id\",\
		\"weight\": 957,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.participant.extension\",\
		\"weight\": 958,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.participant.modifierExtension\",\
		\"weight\": 959,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.participant.role\",\
		\"weight\": 960,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.participant.member\",\
		\"weight\": 961,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.participant.period\",\
		\"weight\": 962,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CareTeam.managingOrganization\",\
		\"weight\": 963,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim\",\
		\"weight\": 964,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.id\",\
		\"weight\": 965,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.meta\",\
		\"weight\": 966,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.implicitRules\",\
		\"weight\": 967,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.language\",\
		\"weight\": 968,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.text\",\
		\"weight\": 969,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.contained\",\
		\"weight\": 970,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.extension\",\
		\"weight\": 971,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.modifierExtension\",\
		\"weight\": 972,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.identifier\",\
		\"weight\": 973,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.status\",\
		\"weight\": 974,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.type\",\
		\"weight\": 975,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.subType\",\
		\"weight\": 976,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.ruleset\",\
		\"weight\": 977,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.originalRuleset\",\
		\"weight\": 978,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.created\",\
		\"weight\": 979,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.billablePeriod\",\
		\"weight\": 980,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.insurerIdentifier\",\
		\"weight\": 981,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.insurerReference\",\
		\"weight\": 981,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.providerIdentifier\",\
		\"weight\": 982,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.providerReference\",\
		\"weight\": 982,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.organizationIdentifier\",\
		\"weight\": 983,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.organizationReference\",\
		\"weight\": 983,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.use\",\
		\"weight\": 984,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.priority\",\
		\"weight\": 985,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.fundsReserve\",\
		\"weight\": 986,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.entererIdentifier\",\
		\"weight\": 987,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.entererReference\",\
		\"weight\": 987,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.facilityIdentifier\",\
		\"weight\": 988,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.facilityReference\",\
		\"weight\": 988,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.related\",\
		\"weight\": 989,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.related.id\",\
		\"weight\": 990,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.related.extension\",\
		\"weight\": 991,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.related.modifierExtension\",\
		\"weight\": 992,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.related.claimIdentifier\",\
		\"weight\": 993,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.related.claimReference\",\
		\"weight\": 993,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.related.relationship\",\
		\"weight\": 994,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.related.reference\",\
		\"weight\": 995,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.prescriptionIdentifier\",\
		\"weight\": 996,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.prescriptionReference\",\
		\"weight\": 996,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.prescriptionReference\",\
		\"weight\": 996,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.originalPrescriptionIdentifier\",\
		\"weight\": 997,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.originalPrescriptionReference\",\
		\"weight\": 997,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee\",\
		\"weight\": 998,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.id\",\
		\"weight\": 999,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.extension\",\
		\"weight\": 1000,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.modifierExtension\",\
		\"weight\": 1001,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.payee.type\",\
		\"weight\": 1002,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.resourceType\",\
		\"weight\": 1003,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.partyIdentifier\",\
		\"weight\": 1004,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 1004,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 1004,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 1004,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 1004,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.referralIdentifier\",\
		\"weight\": 1005,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.referralReference\",\
		\"weight\": 1005,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information\",\
		\"weight\": 1006,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information.id\",\
		\"weight\": 1007,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information.extension\",\
		\"weight\": 1008,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information.modifierExtension\",\
		\"weight\": 1009,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.information.category\",\
		\"weight\": 1010,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information.code\",\
		\"weight\": 1011,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information.timingDate\",\
		\"weight\": 1012,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information.timingPeriod\",\
		\"weight\": 1012,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information.valueString\",\
		\"weight\": 1013,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.information.valueQuantity\",\
		\"weight\": 1013,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.diagnosis\",\
		\"weight\": 1014,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.diagnosis.id\",\
		\"weight\": 1015,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.diagnosis.extension\",\
		\"weight\": 1016,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.diagnosis.modifierExtension\",\
		\"weight\": 1017,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.diagnosis.sequence\",\
		\"weight\": 1018,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.diagnosis.diagnosis\",\
		\"weight\": 1019,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.diagnosis.type\",\
		\"weight\": 1020,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.diagnosis.drg\",\
		\"weight\": 1021,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.procedure\",\
		\"weight\": 1022,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.procedure.id\",\
		\"weight\": 1023,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.procedure.extension\",\
		\"weight\": 1024,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.procedure.modifierExtension\",\
		\"weight\": 1025,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.procedure.sequence\",\
		\"weight\": 1026,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.procedure.date\",\
		\"weight\": 1027,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.procedure.procedureCoding\",\
		\"weight\": 1028,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.procedure.procedureReference\",\
		\"weight\": 1028,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.patientIdentifier\",\
		\"weight\": 1029,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.patientReference\",\
		\"weight\": 1029,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.coverage\",\
		\"weight\": 1030,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.coverage.id\",\
		\"weight\": 1031,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.coverage.extension\",\
		\"weight\": 1032,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.coverage.modifierExtension\",\
		\"weight\": 1033,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.coverage.sequence\",\
		\"weight\": 1034,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.coverage.focal\",\
		\"weight\": 1035,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.coverage.coverageIdentifier\",\
		\"weight\": 1036,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.coverage.coverageReference\",\
		\"weight\": 1036,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.coverage.businessArrangement\",\
		\"weight\": 1037,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.coverage.preAuthRef\",\
		\"weight\": 1038,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.coverage.claimResponse\",\
		\"weight\": 1039,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.coverage.originalRuleset\",\
		\"weight\": 1040,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.accident\",\
		\"weight\": 1041,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.accident.id\",\
		\"weight\": 1042,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.accident.extension\",\
		\"weight\": 1043,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.accident.modifierExtension\",\
		\"weight\": 1044,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.accident.date\",\
		\"weight\": 1045,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.accident.type\",\
		\"weight\": 1046,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.accident.locationAddress\",\
		\"weight\": 1047,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.accident.locationReference\",\
		\"weight\": 1047,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.employmentImpacted\",\
		\"weight\": 1048,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.hospitalization\",\
		\"weight\": 1049,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item\",\
		\"weight\": 1050,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.id\",\
		\"weight\": 1051,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.extension\",\
		\"weight\": 1052,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.modifierExtension\",\
		\"weight\": 1053,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.item.sequence\",\
		\"weight\": 1054,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.careTeam\",\
		\"weight\": 1055,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.careTeam.id\",\
		\"weight\": 1056,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.careTeam.extension\",\
		\"weight\": 1057,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.careTeam.modifierExtension\",\
		\"weight\": 1058,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.item.careTeam.providerIdentifier\",\
		\"weight\": 1059,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.item.careTeam.providerReference\",\
		\"weight\": 1059,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.item.careTeam.providerReference\",\
		\"weight\": 1059,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.careTeam.responsible\",\
		\"weight\": 1060,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.careTeam.role\",\
		\"weight\": 1061,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.careTeam.qualification\",\
		\"weight\": 1062,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.diagnosisLinkId\",\
		\"weight\": 1063,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.revenue\",\
		\"weight\": 1064,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.category\",\
		\"weight\": 1065,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.service\",\
		\"weight\": 1066,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.modifier\",\
		\"weight\": 1067,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.programCode\",\
		\"weight\": 1068,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.servicedDate\",\
		\"weight\": 1069,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.servicedPeriod\",\
		\"weight\": 1069,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.locationCoding\",\
		\"weight\": 1070,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.locationAddress\",\
		\"weight\": 1070,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.locationReference\",\
		\"weight\": 1070,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.quantity\",\
		\"weight\": 1071,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.unitPrice\",\
		\"weight\": 1072,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.factor\",\
		\"weight\": 1073,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.points\",\
		\"weight\": 1074,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.net\",\
		\"weight\": 1075,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.udi\",\
		\"weight\": 1076,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.bodySite\",\
		\"weight\": 1077,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.subSite\",\
		\"weight\": 1078,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail\",\
		\"weight\": 1079,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.id\",\
		\"weight\": 1080,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.extension\",\
		\"weight\": 1081,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.modifierExtension\",\
		\"weight\": 1082,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.item.detail.sequence\",\
		\"weight\": 1083,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.revenue\",\
		\"weight\": 1084,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.category\",\
		\"weight\": 1085,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.service\",\
		\"weight\": 1086,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.modifier\",\
		\"weight\": 1087,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.programCode\",\
		\"weight\": 1088,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.quantity\",\
		\"weight\": 1089,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.unitPrice\",\
		\"weight\": 1090,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.factor\",\
		\"weight\": 1091,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.points\",\
		\"weight\": 1092,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.net\",\
		\"weight\": 1093,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.udi\",\
		\"weight\": 1094,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail\",\
		\"weight\": 1095,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.id\",\
		\"weight\": 1096,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.extension\",\
		\"weight\": 1097,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.modifierExtension\",\
		\"weight\": 1098,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.item.detail.subDetail.sequence\",\
		\"weight\": 1099,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.revenue\",\
		\"weight\": 1100,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.category\",\
		\"weight\": 1101,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.service\",\
		\"weight\": 1102,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.modifier\",\
		\"weight\": 1103,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.programCode\",\
		\"weight\": 1104,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.quantity\",\
		\"weight\": 1105,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.unitPrice\",\
		\"weight\": 1106,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.factor\",\
		\"weight\": 1107,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.points\",\
		\"weight\": 1108,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.net\",\
		\"weight\": 1109,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.detail.subDetail.udi\",\
		\"weight\": 1110,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.prosthesis\",\
		\"weight\": 1111,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.prosthesis.id\",\
		\"weight\": 1112,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.prosthesis.extension\",\
		\"weight\": 1113,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.prosthesis.modifierExtension\",\
		\"weight\": 1114,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.prosthesis.initial\",\
		\"weight\": 1115,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.prosthesis.priorDate\",\
		\"weight\": 1116,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.item.prosthesis.priorMaterial\",\
		\"weight\": 1117,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.total\",\
		\"weight\": 1118,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.missingTeeth\",\
		\"weight\": 1119,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.missingTeeth.id\",\
		\"weight\": 1120,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.missingTeeth.extension\",\
		\"weight\": 1121,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.missingTeeth.modifierExtension\",\
		\"weight\": 1122,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Claim.missingTeeth.tooth\",\
		\"weight\": 1123,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.missingTeeth.reason\",\
		\"weight\": 1124,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Claim.missingTeeth.extractionDate\",\
		\"weight\": 1125,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse\",\
		\"weight\": 1126,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.id\",\
		\"weight\": 1127,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.meta\",\
		\"weight\": 1128,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.implicitRules\",\
		\"weight\": 1129,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.language\",\
		\"weight\": 1130,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.text\",\
		\"weight\": 1131,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.contained\",\
		\"weight\": 1132,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.extension\",\
		\"weight\": 1133,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.modifierExtension\",\
		\"weight\": 1134,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.identifier\",\
		\"weight\": 1135,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.status\",\
		\"weight\": 1136,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.requestIdentifier\",\
		\"weight\": 1137,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.requestReference\",\
		\"weight\": 1137,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.ruleset\",\
		\"weight\": 1138,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.originalRuleset\",\
		\"weight\": 1139,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.created\",\
		\"weight\": 1140,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.organizationIdentifier\",\
		\"weight\": 1141,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.organizationReference\",\
		\"weight\": 1141,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.requestProviderIdentifier\",\
		\"weight\": 1142,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.requestProviderReference\",\
		\"weight\": 1142,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.requestOrganizationIdentifier\",\
		\"weight\": 1143,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.requestOrganizationReference\",\
		\"weight\": 1143,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.outcome\",\
		\"weight\": 1144,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.disposition\",\
		\"weight\": 1145,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payeeType\",\
		\"weight\": 1146,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item\",\
		\"weight\": 1147,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.id\",\
		\"weight\": 1148,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.extension\",\
		\"weight\": 1149,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.modifierExtension\",\
		\"weight\": 1150,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.item.sequenceLinkId\",\
		\"weight\": 1151,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.noteNumber\",\
		\"weight\": 1152,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.adjudication\",\
		\"weight\": 1153,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.adjudication.id\",\
		\"weight\": 1154,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.adjudication.extension\",\
		\"weight\": 1155,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.adjudication.modifierExtension\",\
		\"weight\": 1156,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.item.adjudication.category\",\
		\"weight\": 1157,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.adjudication.reason\",\
		\"weight\": 1158,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.adjudication.amount\",\
		\"weight\": 1159,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.adjudication.value\",\
		\"weight\": 1160,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail\",\
		\"weight\": 1161,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.id\",\
		\"weight\": 1162,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.extension\",\
		\"weight\": 1163,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.modifierExtension\",\
		\"weight\": 1164,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.item.detail.sequenceLinkId\",\
		\"weight\": 1165,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.noteNumber\",\
		\"weight\": 1166,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.adjudication\",\
		\"weight\": 1167,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.subDetail\",\
		\"weight\": 1168,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.subDetail.id\",\
		\"weight\": 1169,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.subDetail.extension\",\
		\"weight\": 1170,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.subDetail.modifierExtension\",\
		\"weight\": 1171,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.item.detail.subDetail.sequenceLinkId\",\
		\"weight\": 1172,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.subDetail.noteNumber\",\
		\"weight\": 1173,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication\",\
		\"weight\": 1174,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem\",\
		\"weight\": 1175,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.id\",\
		\"weight\": 1176,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.extension\",\
		\"weight\": 1177,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.modifierExtension\",\
		\"weight\": 1178,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.sequenceLinkId\",\
		\"weight\": 1179,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.revenue\",\
		\"weight\": 1180,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.category\",\
		\"weight\": 1181,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.service\",\
		\"weight\": 1182,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.modifier\",\
		\"weight\": 1183,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.fee\",\
		\"weight\": 1184,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.noteNumber\",\
		\"weight\": 1185,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.adjudication\",\
		\"weight\": 1186,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail\",\
		\"weight\": 1187,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.id\",\
		\"weight\": 1188,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.extension\",\
		\"weight\": 1189,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.modifierExtension\",\
		\"weight\": 1190,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.revenue\",\
		\"weight\": 1191,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.category\",\
		\"weight\": 1192,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.service\",\
		\"weight\": 1193,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.modifier\",\
		\"weight\": 1194,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.fee\",\
		\"weight\": 1195,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.noteNumber\",\
		\"weight\": 1196,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.addItem.detail.adjudication\",\
		\"weight\": 1197,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.error\",\
		\"weight\": 1198,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.error.id\",\
		\"weight\": 1199,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.error.extension\",\
		\"weight\": 1200,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.error.modifierExtension\",\
		\"weight\": 1201,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.error.sequenceLinkId\",\
		\"weight\": 1202,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.error.detailSequenceLinkId\",\
		\"weight\": 1203,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.error.subdetailSequenceLinkId\",\
		\"weight\": 1204,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.error.code\",\
		\"weight\": 1205,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.totalCost\",\
		\"weight\": 1206,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.unallocDeductable\",\
		\"weight\": 1207,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.totalBenefit\",\
		\"weight\": 1208,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment\",\
		\"weight\": 1209,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.id\",\
		\"weight\": 1210,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.extension\",\
		\"weight\": 1211,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.modifierExtension\",\
		\"weight\": 1212,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.type\",\
		\"weight\": 1213,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.adjustment\",\
		\"weight\": 1214,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.adjustmentReason\",\
		\"weight\": 1215,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.date\",\
		\"weight\": 1216,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.amount\",\
		\"weight\": 1217,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.payment.identifier\",\
		\"weight\": 1218,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.reserved\",\
		\"weight\": 1219,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.form\",\
		\"weight\": 1220,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.note\",\
		\"weight\": 1221,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.note.id\",\
		\"weight\": 1222,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.note.extension\",\
		\"weight\": 1223,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.note.modifierExtension\",\
		\"weight\": 1224,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.note.number\",\
		\"weight\": 1225,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.note.type\",\
		\"weight\": 1226,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.note.text\",\
		\"weight\": 1227,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.note.language\",\
		\"weight\": 1228,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.coverage\",\
		\"weight\": 1229,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.coverage.id\",\
		\"weight\": 1230,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.coverage.extension\",\
		\"weight\": 1231,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.coverage.modifierExtension\",\
		\"weight\": 1232,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.coverage.sequence\",\
		\"weight\": 1233,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.coverage.focal\",\
		\"weight\": 1234,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.coverage.coverageIdentifier\",\
		\"weight\": 1235,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClaimResponse.coverage.coverageReference\",\
		\"weight\": 1235,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.coverage.businessArrangement\",\
		\"weight\": 1236,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.coverage.preAuthRef\",\
		\"weight\": 1237,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClaimResponse.coverage.claimResponse\",\
		\"weight\": 1238,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression\",\
		\"weight\": 1239,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.id\",\
		\"weight\": 1240,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.meta\",\
		\"weight\": 1241,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.implicitRules\",\
		\"weight\": 1242,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.language\",\
		\"weight\": 1243,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.text\",\
		\"weight\": 1244,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.contained\",\
		\"weight\": 1245,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.extension\",\
		\"weight\": 1246,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.modifierExtension\",\
		\"weight\": 1247,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.identifier\",\
		\"weight\": 1248,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClinicalImpression.status\",\
		\"weight\": 1249,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.code\",\
		\"weight\": 1250,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.description\",\
		\"weight\": 1251,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClinicalImpression.subject\",\
		\"weight\": 1252,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.assessor\",\
		\"weight\": 1253,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.date\",\
		\"weight\": 1254,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.effectiveDateTime\",\
		\"weight\": 1255,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.effectivePeriod\",\
		\"weight\": 1255,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.context\",\
		\"weight\": 1256,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.previous\",\
		\"weight\": 1257,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.problem\",\
		\"weight\": 1258,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.investigations\",\
		\"weight\": 1259,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.investigations.id\",\
		\"weight\": 1260,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.investigations.extension\",\
		\"weight\": 1261,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.investigations.modifierExtension\",\
		\"weight\": 1262,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClinicalImpression.investigations.code\",\
		\"weight\": 1263,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.investigations.item\",\
		\"weight\": 1264,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.protocol\",\
		\"weight\": 1265,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.summary\",\
		\"weight\": 1266,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.finding\",\
		\"weight\": 1267,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.finding.id\",\
		\"weight\": 1268,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.finding.extension\",\
		\"weight\": 1269,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.finding.modifierExtension\",\
		\"weight\": 1270,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClinicalImpression.finding.itemCodeableConcept\",\
		\"weight\": 1271,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClinicalImpression.finding.itemReference\",\
		\"weight\": 1271,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ClinicalImpression.finding.itemReference\",\
		\"weight\": 1271,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.finding.cause\",\
		\"weight\": 1272,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.prognosisCodeableConcept\",\
		\"weight\": 1273,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.prognosisReference\",\
		\"weight\": 1274,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.plan\",\
		\"weight\": 1275,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.action\",\
		\"weight\": 1276,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ClinicalImpression.note\",\
		\"weight\": 1277,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication\",\
		\"weight\": 1278,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.id\",\
		\"weight\": 1279,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.meta\",\
		\"weight\": 1280,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.implicitRules\",\
		\"weight\": 1281,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.language\",\
		\"weight\": 1282,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.text\",\
		\"weight\": 1283,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.contained\",\
		\"weight\": 1284,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.extension\",\
		\"weight\": 1285,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.modifierExtension\",\
		\"weight\": 1286,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.identifier\",\
		\"weight\": 1287,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.basedOn\",\
		\"weight\": 1288,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.parent\",\
		\"weight\": 1289,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.status\",\
		\"weight\": 1290,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.category\",\
		\"weight\": 1291,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.medium\",\
		\"weight\": 1292,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.subject\",\
		\"weight\": 1293,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.topic\",\
		\"weight\": 1294,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.context\",\
		\"weight\": 1295,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.sent\",\
		\"weight\": 1296,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.received\",\
		\"weight\": 1297,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.sender\",\
		\"weight\": 1298,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.recipient\",\
		\"weight\": 1299,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.reason\",\
		\"weight\": 1300,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.payload\",\
		\"weight\": 1301,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.payload.id\",\
		\"weight\": 1302,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.payload.extension\",\
		\"weight\": 1303,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.payload.modifierExtension\",\
		\"weight\": 1304,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Communication.payload.contentString\",\
		\"weight\": 1305,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Communication.payload.contentAttachment\",\
		\"weight\": 1305,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Communication.payload.contentReference\",\
		\"weight\": 1305,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Communication.note\",\
		\"weight\": 1306,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest\",\
		\"weight\": 1307,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.id\",\
		\"weight\": 1308,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.meta\",\
		\"weight\": 1309,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.implicitRules\",\
		\"weight\": 1310,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.language\",\
		\"weight\": 1311,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.text\",\
		\"weight\": 1312,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.contained\",\
		\"weight\": 1313,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.extension\",\
		\"weight\": 1314,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.modifierExtension\",\
		\"weight\": 1315,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.identifier\",\
		\"weight\": 1316,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.category\",\
		\"weight\": 1317,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.sender\",\
		\"weight\": 1318,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.recipient\",\
		\"weight\": 1319,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.payload\",\
		\"weight\": 1320,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.payload.id\",\
		\"weight\": 1321,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.payload.extension\",\
		\"weight\": 1322,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.payload.modifierExtension\",\
		\"weight\": 1323,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CommunicationRequest.payload.contentString\",\
		\"weight\": 1324,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CommunicationRequest.payload.contentAttachment\",\
		\"weight\": 1324,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CommunicationRequest.payload.contentReference\",\
		\"weight\": 1324,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.medium\",\
		\"weight\": 1325,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.requester\",\
		\"weight\": 1326,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.status\",\
		\"weight\": 1327,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.encounter\",\
		\"weight\": 1328,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.scheduledDateTime\",\
		\"weight\": 1329,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.scheduledPeriod\",\
		\"weight\": 1329,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.reason\",\
		\"weight\": 1330,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.requestedOn\",\
		\"weight\": 1331,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.subject\",\
		\"weight\": 1332,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CommunicationRequest.priority\",\
		\"weight\": 1333,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CompartmentDefinition\",\
		\"weight\": 1334,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.id\",\
		\"weight\": 1335,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.meta\",\
		\"weight\": 1336,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.implicitRules\",\
		\"weight\": 1337,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.language\",\
		\"weight\": 1338,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.text\",\
		\"weight\": 1339,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.contained\",\
		\"weight\": 1340,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.extension\",\
		\"weight\": 1341,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.modifierExtension\",\
		\"weight\": 1342,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CompartmentDefinition.url\",\
		\"weight\": 1343,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CompartmentDefinition.name\",\
		\"weight\": 1344,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.status\",\
		\"weight\": 1345,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.experimental\",\
		\"weight\": 1346,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.publisher\",\
		\"weight\": 1347,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.contact\",\
		\"weight\": 1348,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.contact.id\",\
		\"weight\": 1349,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.contact.extension\",\
		\"weight\": 1350,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.contact.modifierExtension\",\
		\"weight\": 1351,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.contact.name\",\
		\"weight\": 1352,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.contact.telecom\",\
		\"weight\": 1353,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.date\",\
		\"weight\": 1354,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.description\",\
		\"weight\": 1355,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.requirements\",\
		\"weight\": 1356,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CompartmentDefinition.code\",\
		\"weight\": 1357,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CompartmentDefinition.search\",\
		\"weight\": 1358,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.resource\",\
		\"weight\": 1359,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.resource.id\",\
		\"weight\": 1360,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.resource.extension\",\
		\"weight\": 1361,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.resource.modifierExtension\",\
		\"weight\": 1362,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"CompartmentDefinition.resource.code\",\
		\"weight\": 1363,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.resource.param\",\
		\"weight\": 1364,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"CompartmentDefinition.resource.documentation\",\
		\"weight\": 1365,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition\",\
		\"weight\": 1366,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.id\",\
		\"weight\": 1367,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.meta\",\
		\"weight\": 1368,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.implicitRules\",\
		\"weight\": 1369,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.language\",\
		\"weight\": 1370,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.text\",\
		\"weight\": 1371,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.contained\",\
		\"weight\": 1372,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.extension\",\
		\"weight\": 1373,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.modifierExtension\",\
		\"weight\": 1374,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.identifier\",\
		\"weight\": 1375,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Composition.date\",\
		\"weight\": 1376,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Composition.type\",\
		\"weight\": 1377,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.class\",\
		\"weight\": 1378,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Composition.title\",\
		\"weight\": 1379,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Composition.status\",\
		\"weight\": 1380,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.confidentiality\",\
		\"weight\": 1381,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Composition.subject\",\
		\"weight\": 1382,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Composition.author\",\
		\"weight\": 1383,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.attester\",\
		\"weight\": 1384,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.attester.id\",\
		\"weight\": 1385,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.attester.extension\",\
		\"weight\": 1386,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.attester.modifierExtension\",\
		\"weight\": 1387,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Composition.attester.mode\",\
		\"weight\": 1388,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.attester.time\",\
		\"weight\": 1389,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.attester.party\",\
		\"weight\": 1390,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.custodian\",\
		\"weight\": 1391,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.event\",\
		\"weight\": 1392,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.event.id\",\
		\"weight\": 1393,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.event.extension\",\
		\"weight\": 1394,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.event.modifierExtension\",\
		\"weight\": 1395,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.event.code\",\
		\"weight\": 1396,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.event.period\",\
		\"weight\": 1397,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.event.detail\",\
		\"weight\": 1398,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.encounter\",\
		\"weight\": 1399,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section\",\
		\"weight\": 1400,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.id\",\
		\"weight\": 1401,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.extension\",\
		\"weight\": 1402,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.modifierExtension\",\
		\"weight\": 1403,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.title\",\
		\"weight\": 1404,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.code\",\
		\"weight\": 1405,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.text\",\
		\"weight\": 1406,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.mode\",\
		\"weight\": 1407,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.orderedBy\",\
		\"weight\": 1408,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.entry\",\
		\"weight\": 1409,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.emptyReason\",\
		\"weight\": 1410,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Composition.section.section\",\
		\"weight\": 1411,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap\",\
		\"weight\": 1412,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.id\",\
		\"weight\": 1413,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.meta\",\
		\"weight\": 1414,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.implicitRules\",\
		\"weight\": 1415,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.language\",\
		\"weight\": 1416,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.text\",\
		\"weight\": 1417,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.contained\",\
		\"weight\": 1418,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.extension\",\
		\"weight\": 1419,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.modifierExtension\",\
		\"weight\": 1420,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.url\",\
		\"weight\": 1421,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.identifier\",\
		\"weight\": 1422,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.version\",\
		\"weight\": 1423,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.name\",\
		\"weight\": 1424,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.status\",\
		\"weight\": 1425,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.experimental\",\
		\"weight\": 1426,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.publisher\",\
		\"weight\": 1427,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.contact\",\
		\"weight\": 1428,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.contact.id\",\
		\"weight\": 1429,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.contact.extension\",\
		\"weight\": 1430,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.contact.modifierExtension\",\
		\"weight\": 1431,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.contact.name\",\
		\"weight\": 1432,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.contact.telecom\",\
		\"weight\": 1433,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.date\",\
		\"weight\": 1434,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.description\",\
		\"weight\": 1435,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.useContext\",\
		\"weight\": 1436,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.requirements\",\
		\"weight\": 1437,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.copyright\",\
		\"weight\": 1438,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.sourceUri\",\
		\"weight\": 1439,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.sourceReference\",\
		\"weight\": 1439,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.sourceReference\",\
		\"weight\": 1439,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.targetUri\",\
		\"weight\": 1440,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.targetReference\",\
		\"weight\": 1440,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.targetReference\",\
		\"weight\": 1440,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group\",\
		\"weight\": 1441,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.id\",\
		\"weight\": 1442,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.extension\",\
		\"weight\": 1443,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.modifierExtension\",\
		\"weight\": 1444,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.group.source\",\
		\"weight\": 1445,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.sourceVersion\",\
		\"weight\": 1446,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.target\",\
		\"weight\": 1447,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.targetVersion\",\
		\"weight\": 1448,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.group.element\",\
		\"weight\": 1449,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.id\",\
		\"weight\": 1450,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.extension\",\
		\"weight\": 1451,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.modifierExtension\",\
		\"weight\": 1452,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.code\",\
		\"weight\": 1453,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target\",\
		\"weight\": 1454,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.id\",\
		\"weight\": 1455,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.extension\",\
		\"weight\": 1456,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.modifierExtension\",\
		\"weight\": 1457,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.code\",\
		\"weight\": 1458,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.equivalence\",\
		\"weight\": 1459,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.comments\",\
		\"weight\": 1460,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.dependsOn\",\
		\"weight\": 1461,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.dependsOn.id\",\
		\"weight\": 1462,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.dependsOn.extension\",\
		\"weight\": 1463,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.dependsOn.modifierExtension\",\
		\"weight\": 1464,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.group.element.target.dependsOn.property\",\
		\"weight\": 1465,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.dependsOn.system\",\
		\"weight\": 1466,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ConceptMap.group.element.target.dependsOn.code\",\
		\"weight\": 1467,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ConceptMap.group.element.target.product\",\
		\"weight\": 1468,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition\",\
		\"weight\": 1469,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.id\",\
		\"weight\": 1470,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.meta\",\
		\"weight\": 1471,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.implicitRules\",\
		\"weight\": 1472,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.language\",\
		\"weight\": 1473,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.text\",\
		\"weight\": 1474,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.contained\",\
		\"weight\": 1475,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.extension\",\
		\"weight\": 1476,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.modifierExtension\",\
		\"weight\": 1477,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.identifier\",\
		\"weight\": 1478,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.clinicalStatus\",\
		\"weight\": 1479,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Condition.verificationStatus\",\
		\"weight\": 1480,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.category\",\
		\"weight\": 1481,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.severity\",\
		\"weight\": 1482,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Condition.code\",\
		\"weight\": 1483,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.bodySite\",\
		\"weight\": 1484,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Condition.subject\",\
		\"weight\": 1485,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.context\",\
		\"weight\": 1486,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.onsetDateTime\",\
		\"weight\": 1487,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.onsetAge\",\
		\"weight\": 1487,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.onsetPeriod\",\
		\"weight\": 1487,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.onsetRange\",\
		\"weight\": 1487,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.onsetString\",\
		\"weight\": 1487,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.abatementDateTime\",\
		\"weight\": 1488,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.abatementAge\",\
		\"weight\": 1488,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.abatementBoolean\",\
		\"weight\": 1488,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.abatementPeriod\",\
		\"weight\": 1488,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.abatementRange\",\
		\"weight\": 1488,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.abatementString\",\
		\"weight\": 1488,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.dateRecorded\",\
		\"weight\": 1489,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.asserter\",\
		\"weight\": 1490,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.stage\",\
		\"weight\": 1491,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.stage.id\",\
		\"weight\": 1492,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.stage.extension\",\
		\"weight\": 1493,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.stage.modifierExtension\",\
		\"weight\": 1494,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.stage.summary\",\
		\"weight\": 1495,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.stage.assessment\",\
		\"weight\": 1496,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.evidence\",\
		\"weight\": 1497,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.evidence.id\",\
		\"weight\": 1498,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.evidence.extension\",\
		\"weight\": 1499,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.evidence.modifierExtension\",\
		\"weight\": 1500,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.evidence.code\",\
		\"weight\": 1501,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.evidence.detail\",\
		\"weight\": 1502,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Condition.note\",\
		\"weight\": 1503,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance\",\
		\"weight\": 1504,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.id\",\
		\"weight\": 1505,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.meta\",\
		\"weight\": 1506,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.implicitRules\",\
		\"weight\": 1507,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.language\",\
		\"weight\": 1508,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.text\",\
		\"weight\": 1509,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.contained\",\
		\"weight\": 1510,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.extension\",\
		\"weight\": 1511,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.modifierExtension\",\
		\"weight\": 1512,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.url\",\
		\"weight\": 1513,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.version\",\
		\"weight\": 1514,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.name\",\
		\"weight\": 1515,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.status\",\
		\"weight\": 1516,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.experimental\",\
		\"weight\": 1517,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.date\",\
		\"weight\": 1518,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.publisher\",\
		\"weight\": 1519,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.contact\",\
		\"weight\": 1520,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.contact.id\",\
		\"weight\": 1521,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.contact.extension\",\
		\"weight\": 1522,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.contact.modifierExtension\",\
		\"weight\": 1523,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.contact.name\",\
		\"weight\": 1524,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.contact.telecom\",\
		\"weight\": 1525,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.description\",\
		\"weight\": 1526,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.useContext\",\
		\"weight\": 1527,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.requirements\",\
		\"weight\": 1528,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.copyright\",\
		\"weight\": 1529,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.kind\",\
		\"weight\": 1530,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.instantiates\",\
		\"weight\": 1531,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.software\",\
		\"weight\": 1532,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.software.id\",\
		\"weight\": 1533,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.software.extension\",\
		\"weight\": 1534,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.software.modifierExtension\",\
		\"weight\": 1535,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.software.name\",\
		\"weight\": 1536,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.software.version\",\
		\"weight\": 1537,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.software.releaseDate\",\
		\"weight\": 1538,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.implementation\",\
		\"weight\": 1539,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.implementation.id\",\
		\"weight\": 1540,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.implementation.extension\",\
		\"weight\": 1541,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.implementation.modifierExtension\",\
		\"weight\": 1542,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.implementation.description\",\
		\"weight\": 1543,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.implementation.url\",\
		\"weight\": 1544,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.fhirVersion\",\
		\"weight\": 1545,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.acceptUnknown\",\
		\"weight\": 1546,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.format\",\
		\"weight\": 1547,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.profile\",\
		\"weight\": 1548,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest\",\
		\"weight\": 1549,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.id\",\
		\"weight\": 1550,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.extension\",\
		\"weight\": 1551,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.modifierExtension\",\
		\"weight\": 1552,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.mode\",\
		\"weight\": 1553,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.documentation\",\
		\"weight\": 1554,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security\",\
		\"weight\": 1555,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.id\",\
		\"weight\": 1556,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.extension\",\
		\"weight\": 1557,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.modifierExtension\",\
		\"weight\": 1558,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.cors\",\
		\"weight\": 1559,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.service\",\
		\"weight\": 1560,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.description\",\
		\"weight\": 1561,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.certificate\",\
		\"weight\": 1562,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.certificate.id\",\
		\"weight\": 1563,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.certificate.extension\",\
		\"weight\": 1564,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.certificate.modifierExtension\",\
		\"weight\": 1565,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.certificate.type\",\
		\"weight\": 1566,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.security.certificate.blob\",\
		\"weight\": 1567,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource\",\
		\"weight\": 1568,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.id\",\
		\"weight\": 1569,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.extension\",\
		\"weight\": 1570,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.modifierExtension\",\
		\"weight\": 1571,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.resource.type\",\
		\"weight\": 1572,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.profile\",\
		\"weight\": 1573,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.documentation\",\
		\"weight\": 1574,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.resource.interaction\",\
		\"weight\": 1575,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.interaction.id\",\
		\"weight\": 1576,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.interaction.extension\",\
		\"weight\": 1577,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.interaction.modifierExtension\",\
		\"weight\": 1578,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.resource.interaction.code\",\
		\"weight\": 1579,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.interaction.documentation\",\
		\"weight\": 1580,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.versioning\",\
		\"weight\": 1581,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.readHistory\",\
		\"weight\": 1582,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.updateCreate\",\
		\"weight\": 1583,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.conditionalCreate\",\
		\"weight\": 1584,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.conditionalRead\",\
		\"weight\": 1585,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.conditionalUpdate\",\
		\"weight\": 1586,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.conditionalDelete\",\
		\"weight\": 1587,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchInclude\",\
		\"weight\": 1588,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchRevInclude\",\
		\"weight\": 1589,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam\",\
		\"weight\": 1590,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam.id\",\
		\"weight\": 1591,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam.extension\",\
		\"weight\": 1592,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam.modifierExtension\",\
		\"weight\": 1593,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.resource.searchParam.name\",\
		\"weight\": 1594,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam.definition\",\
		\"weight\": 1595,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.resource.searchParam.type\",\
		\"weight\": 1596,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam.documentation\",\
		\"weight\": 1597,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam.target\",\
		\"weight\": 1598,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam.modifier\",\
		\"weight\": 1599,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.resource.searchParam.chain\",\
		\"weight\": 1600,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.interaction\",\
		\"weight\": 1601,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.interaction.id\",\
		\"weight\": 1602,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.interaction.extension\",\
		\"weight\": 1603,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.interaction.modifierExtension\",\
		\"weight\": 1604,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.interaction.code\",\
		\"weight\": 1605,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.interaction.documentation\",\
		\"weight\": 1606,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.searchParam\",\
		\"weight\": 1607,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.operation\",\
		\"weight\": 1608,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.operation.id\",\
		\"weight\": 1609,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.operation.extension\",\
		\"weight\": 1610,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.operation.modifierExtension\",\
		\"weight\": 1611,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.operation.name\",\
		\"weight\": 1612,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.rest.operation.definition\",\
		\"weight\": 1613,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.rest.compartment\",\
		\"weight\": 1614,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging\",\
		\"weight\": 1615,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.id\",\
		\"weight\": 1616,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.extension\",\
		\"weight\": 1617,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.modifierExtension\",\
		\"weight\": 1618,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.endpoint\",\
		\"weight\": 1619,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.endpoint.id\",\
		\"weight\": 1620,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.endpoint.extension\",\
		\"weight\": 1621,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.endpoint.modifierExtension\",\
		\"weight\": 1622,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.messaging.endpoint.protocol\",\
		\"weight\": 1623,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.messaging.endpoint.address\",\
		\"weight\": 1624,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.reliableCache\",\
		\"weight\": 1625,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.documentation\",\
		\"weight\": 1626,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.messaging.event\",\
		\"weight\": 1627,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.event.id\",\
		\"weight\": 1628,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.event.extension\",\
		\"weight\": 1629,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.event.modifierExtension\",\
		\"weight\": 1630,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.messaging.event.code\",\
		\"weight\": 1631,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.event.category\",\
		\"weight\": 1632,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.messaging.event.mode\",\
		\"weight\": 1633,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.messaging.event.focus\",\
		\"weight\": 1634,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.messaging.event.request\",\
		\"weight\": 1635,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.messaging.event.response\",\
		\"weight\": 1636,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.messaging.event.documentation\",\
		\"weight\": 1637,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.document\",\
		\"weight\": 1638,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.document.id\",\
		\"weight\": 1639,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.document.extension\",\
		\"weight\": 1640,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.document.modifierExtension\",\
		\"weight\": 1641,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.document.mode\",\
		\"weight\": 1642,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Conformance.document.documentation\",\
		\"weight\": 1643,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Conformance.document.profile\",\
		\"weight\": 1644,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent\",\
		\"weight\": 1645,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.id\",\
		\"weight\": 1646,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.meta\",\
		\"weight\": 1647,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.implicitRules\",\
		\"weight\": 1648,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.language\",\
		\"weight\": 1649,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.text\",\
		\"weight\": 1650,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.contained\",\
		\"weight\": 1651,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.extension\",\
		\"weight\": 1652,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.modifierExtension\",\
		\"weight\": 1653,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.identifier\",\
		\"weight\": 1654,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Consent.status\",\
		\"weight\": 1655,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.category\",\
		\"weight\": 1656,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.dateTime\",\
		\"weight\": 1657,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.period\",\
		\"weight\": 1658,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Consent.patient\",\
		\"weight\": 1659,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.consentor\",\
		\"weight\": 1660,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.organization\",\
		\"weight\": 1661,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.sourceAttachment\",\
		\"weight\": 1662,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.sourceIdentifier\",\
		\"weight\": 1662,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1662,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1662,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1662,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1662,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Consent.policy\",\
		\"weight\": 1663,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.recipient\",\
		\"weight\": 1664,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.purpose\",\
		\"weight\": 1665,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except\",\
		\"weight\": 1666,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.id\",\
		\"weight\": 1667,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.extension\",\
		\"weight\": 1668,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.modifierExtension\",\
		\"weight\": 1669,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Consent.except.type\",\
		\"weight\": 1670,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.period\",\
		\"weight\": 1671,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.actor\",\
		\"weight\": 1672,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.actor.id\",\
		\"weight\": 1673,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.actor.extension\",\
		\"weight\": 1674,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.actor.modifierExtension\",\
		\"weight\": 1675,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Consent.except.actor.role\",\
		\"weight\": 1676,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Consent.except.actor.reference\",\
		\"weight\": 1677,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.action\",\
		\"weight\": 1678,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.securityLabel\",\
		\"weight\": 1679,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.purpose\",\
		\"weight\": 1680,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.class\",\
		\"weight\": 1681,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.code\",\
		\"weight\": 1682,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.data\",\
		\"weight\": 1683,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.data.id\",\
		\"weight\": 1684,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.data.extension\",\
		\"weight\": 1685,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Consent.except.data.modifierExtension\",\
		\"weight\": 1686,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Consent.except.data.meaning\",\
		\"weight\": 1687,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Consent.except.data.reference\",\
		\"weight\": 1688,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract\",\
		\"weight\": 1689,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.id\",\
		\"weight\": 1690,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.meta\",\
		\"weight\": 1691,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.implicitRules\",\
		\"weight\": 1692,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.language\",\
		\"weight\": 1693,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.text\",\
		\"weight\": 1694,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.contained\",\
		\"weight\": 1695,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.extension\",\
		\"weight\": 1696,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.modifierExtension\",\
		\"weight\": 1697,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.identifier\",\
		\"weight\": 1698,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.issued\",\
		\"weight\": 1699,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.applies\",\
		\"weight\": 1700,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.subject\",\
		\"weight\": 1701,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.topic\",\
		\"weight\": 1702,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.authority\",\
		\"weight\": 1703,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.domain\",\
		\"weight\": 1704,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.type\",\
		\"weight\": 1705,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.subType\",\
		\"weight\": 1706,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.action\",\
		\"weight\": 1707,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.actionReason\",\
		\"weight\": 1708,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.agent\",\
		\"weight\": 1709,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.agent.id\",\
		\"weight\": 1710,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.agent.extension\",\
		\"weight\": 1711,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.agent.modifierExtension\",\
		\"weight\": 1712,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.agent.actor\",\
		\"weight\": 1713,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.agent.role\",\
		\"weight\": 1714,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.signer\",\
		\"weight\": 1715,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.signer.id\",\
		\"weight\": 1716,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.signer.extension\",\
		\"weight\": 1717,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.signer.modifierExtension\",\
		\"weight\": 1718,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.signer.type\",\
		\"weight\": 1719,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.signer.party\",\
		\"weight\": 1720,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.signer.signature\",\
		\"weight\": 1721,\
		\"max\": \"*\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem\",\
		\"weight\": 1722,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.id\",\
		\"weight\": 1723,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.extension\",\
		\"weight\": 1724,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.modifierExtension\",\
		\"weight\": 1725,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.entityCodeableConcept\",\
		\"weight\": 1726,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.entityReference\",\
		\"weight\": 1726,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.identifier\",\
		\"weight\": 1727,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.effectiveTime\",\
		\"weight\": 1728,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.quantity\",\
		\"weight\": 1729,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.unitPrice\",\
		\"weight\": 1730,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.factor\",\
		\"weight\": 1731,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.points\",\
		\"weight\": 1732,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.valuedItem.net\",\
		\"weight\": 1733,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term\",\
		\"weight\": 1734,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.id\",\
		\"weight\": 1735,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.extension\",\
		\"weight\": 1736,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.modifierExtension\",\
		\"weight\": 1737,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.identifier\",\
		\"weight\": 1738,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.issued\",\
		\"weight\": 1739,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.applies\",\
		\"weight\": 1740,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.type\",\
		\"weight\": 1741,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.subType\",\
		\"weight\": 1742,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.topic\",\
		\"weight\": 1743,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.action\",\
		\"weight\": 1744,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.actionReason\",\
		\"weight\": 1745,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.agent\",\
		\"weight\": 1746,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.agent.id\",\
		\"weight\": 1747,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.agent.extension\",\
		\"weight\": 1748,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.agent.modifierExtension\",\
		\"weight\": 1749,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.term.agent.actor\",\
		\"weight\": 1750,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.agent.role\",\
		\"weight\": 1751,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.text\",\
		\"weight\": 1752,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem\",\
		\"weight\": 1753,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.id\",\
		\"weight\": 1754,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.extension\",\
		\"weight\": 1755,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.modifierExtension\",\
		\"weight\": 1756,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.entityCodeableConcept\",\
		\"weight\": 1757,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.entityReference\",\
		\"weight\": 1757,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.identifier\",\
		\"weight\": 1758,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.effectiveTime\",\
		\"weight\": 1759,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.quantity\",\
		\"weight\": 1760,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.unitPrice\",\
		\"weight\": 1761,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.factor\",\
		\"weight\": 1762,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.points\",\
		\"weight\": 1763,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.valuedItem.net\",\
		\"weight\": 1764,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.term.group\",\
		\"weight\": 1765,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.bindingAttachment\",\
		\"weight\": 1766,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1766,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1766,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1766,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.friendly\",\
		\"weight\": 1767,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.friendly.id\",\
		\"weight\": 1768,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.friendly.extension\",\
		\"weight\": 1769,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.friendly.modifierExtension\",\
		\"weight\": 1770,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.friendly.contentAttachment\",\
		\"weight\": 1771,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1771,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1771,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1771,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.legal\",\
		\"weight\": 1772,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.legal.id\",\
		\"weight\": 1773,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.legal.extension\",\
		\"weight\": 1774,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.legal.modifierExtension\",\
		\"weight\": 1775,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.legal.contentAttachment\",\
		\"weight\": 1776,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1776,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1776,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1776,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.rule\",\
		\"weight\": 1777,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.rule.id\",\
		\"weight\": 1778,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.rule.extension\",\
		\"weight\": 1779,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Contract.rule.modifierExtension\",\
		\"weight\": 1780,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.rule.contentAttachment\",\
		\"weight\": 1781,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Contract.rule.contentReference\",\
		\"weight\": 1781,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage\",\
		\"weight\": 1782,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.id\",\
		\"weight\": 1783,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.meta\",\
		\"weight\": 1784,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.implicitRules\",\
		\"weight\": 1785,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.language\",\
		\"weight\": 1786,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.text\",\
		\"weight\": 1787,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.contained\",\
		\"weight\": 1788,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.extension\",\
		\"weight\": 1789,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.modifierExtension\",\
		\"weight\": 1790,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.status\",\
		\"weight\": 1791,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.issuerIdentifier\",\
		\"weight\": 1792,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.issuerReference\",\
		\"weight\": 1792,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.issuerReference\",\
		\"weight\": 1792,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.issuerReference\",\
		\"weight\": 1792,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.isAgreement\",\
		\"weight\": 1793,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.bin\",\
		\"weight\": 1794,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.period\",\
		\"weight\": 1795,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.type\",\
		\"weight\": 1796,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.planholderIdentifier\",\
		\"weight\": 1797,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.planholderReference\",\
		\"weight\": 1797,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.planholderReference\",\
		\"weight\": 1797,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.beneficiaryIdentifier\",\
		\"weight\": 1798,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.beneficiaryReference\",\
		\"weight\": 1798,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Coverage.relationship\",\
		\"weight\": 1799,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.identifier\",\
		\"weight\": 1800,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.group\",\
		\"weight\": 1801,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.subGroup\",\
		\"weight\": 1802,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.plan\",\
		\"weight\": 1803,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.subPlan\",\
		\"weight\": 1804,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.class\",\
		\"weight\": 1805,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.dependent\",\
		\"weight\": 1806,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.sequence\",\
		\"weight\": 1807,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.network\",\
		\"weight\": 1808,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Coverage.contract\",\
		\"weight\": 1809,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement\",\
		\"weight\": 1810,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.id\",\
		\"weight\": 1811,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.meta\",\
		\"weight\": 1812,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.implicitRules\",\
		\"weight\": 1813,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.language\",\
		\"weight\": 1814,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.text\",\
		\"weight\": 1815,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.contained\",\
		\"weight\": 1816,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.extension\",\
		\"weight\": 1817,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.modifierExtension\",\
		\"weight\": 1818,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.url\",\
		\"weight\": 1819,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.identifier\",\
		\"weight\": 1820,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.version\",\
		\"weight\": 1821,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DataElement.status\",\
		\"weight\": 1822,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.experimental\",\
		\"weight\": 1823,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.publisher\",\
		\"weight\": 1824,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.date\",\
		\"weight\": 1825,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.name\",\
		\"weight\": 1826,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.contact\",\
		\"weight\": 1827,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.contact.id\",\
		\"weight\": 1828,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.contact.extension\",\
		\"weight\": 1829,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.contact.modifierExtension\",\
		\"weight\": 1830,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.contact.name\",\
		\"weight\": 1831,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.contact.telecom\",\
		\"weight\": 1832,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.useContext\",\
		\"weight\": 1833,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.copyright\",\
		\"weight\": 1834,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.stringency\",\
		\"weight\": 1835,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.mapping\",\
		\"weight\": 1836,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.mapping.id\",\
		\"weight\": 1837,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.mapping.extension\",\
		\"weight\": 1838,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.mapping.modifierExtension\",\
		\"weight\": 1839,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DataElement.mapping.identity\",\
		\"weight\": 1840,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.mapping.uri\",\
		\"weight\": 1841,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.mapping.name\",\
		\"weight\": 1842,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DataElement.mapping.comment\",\
		\"weight\": 1843,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DataElement.element\",\
		\"weight\": 1844,\
		\"max\": \"*\",\
		\"type\": \"ElementDefinition\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule\",\
		\"weight\": 1845,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.id\",\
		\"weight\": 1846,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.meta\",\
		\"weight\": 1847,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.implicitRules\",\
		\"weight\": 1848,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.language\",\
		\"weight\": 1849,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.text\",\
		\"weight\": 1850,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.contained\",\
		\"weight\": 1851,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.extension\",\
		\"weight\": 1852,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.modifierExtension\",\
		\"weight\": 1853,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.url\",\
		\"weight\": 1854,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.identifier\",\
		\"weight\": 1855,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.version\",\
		\"weight\": 1856,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.name\",\
		\"weight\": 1857,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.title\",\
		\"weight\": 1858,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DecisionSupportServiceModule.status\",\
		\"weight\": 1859,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.experimental\",\
		\"weight\": 1860,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.description\",\
		\"weight\": 1861,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.purpose\",\
		\"weight\": 1862,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.usage\",\
		\"weight\": 1863,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.publicationDate\",\
		\"weight\": 1864,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.lastReviewDate\",\
		\"weight\": 1865,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.effectivePeriod\",\
		\"weight\": 1866,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.coverage\",\
		\"weight\": 1867,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.topic\",\
		\"weight\": 1868,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.contributor\",\
		\"weight\": 1869,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.publisher\",\
		\"weight\": 1870,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.contact\",\
		\"weight\": 1871,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.copyright\",\
		\"weight\": 1872,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.relatedResource\",\
		\"weight\": 1873,\
		\"max\": \"*\",\
		\"type\": \"RelatedResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.trigger\",\
		\"weight\": 1874,\
		\"max\": \"*\",\
		\"type\": \"TriggerDefinition\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.parameter\",\
		\"weight\": 1875,\
		\"max\": \"*\",\
		\"type\": \"ParameterDefinition\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DecisionSupportServiceModule.dataRequirement\",\
		\"weight\": 1876,\
		\"max\": \"*\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue\",\
		\"weight\": 1877,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.id\",\
		\"weight\": 1878,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.meta\",\
		\"weight\": 1879,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.implicitRules\",\
		\"weight\": 1880,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.language\",\
		\"weight\": 1881,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.text\",\
		\"weight\": 1882,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.contained\",\
		\"weight\": 1883,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.extension\",\
		\"weight\": 1884,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.modifierExtension\",\
		\"weight\": 1885,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.patient\",\
		\"weight\": 1886,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.category\",\
		\"weight\": 1887,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.severity\",\
		\"weight\": 1888,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.implicated\",\
		\"weight\": 1889,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.detail\",\
		\"weight\": 1890,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.date\",\
		\"weight\": 1891,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.author\",\
		\"weight\": 1892,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.identifier\",\
		\"weight\": 1893,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.reference\",\
		\"weight\": 1894,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.mitigation\",\
		\"weight\": 1895,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.mitigation.id\",\
		\"weight\": 1896,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.mitigation.extension\",\
		\"weight\": 1897,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.mitigation.modifierExtension\",\
		\"weight\": 1898,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DetectedIssue.mitigation.action\",\
		\"weight\": 1899,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.mitigation.date\",\
		\"weight\": 1900,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DetectedIssue.mitigation.author\",\
		\"weight\": 1901,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device\",\
		\"weight\": 1902,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.id\",\
		\"weight\": 1903,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.meta\",\
		\"weight\": 1904,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.implicitRules\",\
		\"weight\": 1905,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.language\",\
		\"weight\": 1906,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.text\",\
		\"weight\": 1907,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.contained\",\
		\"weight\": 1908,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.extension\",\
		\"weight\": 1909,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.modifierExtension\",\
		\"weight\": 1910,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.identifier\",\
		\"weight\": 1911,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.udiCarrier\",\
		\"weight\": 1912,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.status\",\
		\"weight\": 1913,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Device.type\",\
		\"weight\": 1914,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.lotNumber\",\
		\"weight\": 1915,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.manufacturer\",\
		\"weight\": 1916,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.manufactureDate\",\
		\"weight\": 1917,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.expirationDate\",\
		\"weight\": 1918,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.model\",\
		\"weight\": 1919,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.version\",\
		\"weight\": 1920,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.patient\",\
		\"weight\": 1921,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.owner\",\
		\"weight\": 1922,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.contact\",\
		\"weight\": 1923,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.location\",\
		\"weight\": 1924,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.url\",\
		\"weight\": 1925,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Device.note\",\
		\"weight\": 1926,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent\",\
		\"weight\": 1927,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.id\",\
		\"weight\": 1928,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.meta\",\
		\"weight\": 1929,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.implicitRules\",\
		\"weight\": 1930,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.language\",\
		\"weight\": 1931,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.text\",\
		\"weight\": 1932,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.contained\",\
		\"weight\": 1933,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.extension\",\
		\"weight\": 1934,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.modifierExtension\",\
		\"weight\": 1935,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceComponent.type\",\
		\"weight\": 1936,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceComponent.identifier\",\
		\"weight\": 1937,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceComponent.lastSystemChange\",\
		\"weight\": 1938,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.source\",\
		\"weight\": 1939,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.parent\",\
		\"weight\": 1940,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.operationalStatus\",\
		\"weight\": 1941,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.parameterGroup\",\
		\"weight\": 1942,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.measurementPrinciple\",\
		\"weight\": 1943,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.productionSpecification\",\
		\"weight\": 1944,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.productionSpecification.id\",\
		\"weight\": 1945,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.productionSpecification.extension\",\
		\"weight\": 1946,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.productionSpecification.modifierExtension\",\
		\"weight\": 1947,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.productionSpecification.specType\",\
		\"weight\": 1948,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.productionSpecification.componentId\",\
		\"weight\": 1949,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.productionSpecification.productionSpec\",\
		\"weight\": 1950,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceComponent.languageCode\",\
		\"weight\": 1951,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric\",\
		\"weight\": 1952,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.id\",\
		\"weight\": 1953,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.meta\",\
		\"weight\": 1954,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.implicitRules\",\
		\"weight\": 1955,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.language\",\
		\"weight\": 1956,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.text\",\
		\"weight\": 1957,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.contained\",\
		\"weight\": 1958,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.extension\",\
		\"weight\": 1959,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.modifierExtension\",\
		\"weight\": 1960,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceMetric.type\",\
		\"weight\": 1961,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceMetric.identifier\",\
		\"weight\": 1962,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.unit\",\
		\"weight\": 1963,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.source\",\
		\"weight\": 1964,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.parent\",\
		\"weight\": 1965,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.operationalStatus\",\
		\"weight\": 1966,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.color\",\
		\"weight\": 1967,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceMetric.category\",\
		\"weight\": 1968,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.measurementPeriod\",\
		\"weight\": 1969,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.calibration\",\
		\"weight\": 1970,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.calibration.id\",\
		\"weight\": 1971,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.calibration.extension\",\
		\"weight\": 1972,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.calibration.modifierExtension\",\
		\"weight\": 1973,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.calibration.type\",\
		\"weight\": 1974,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.calibration.state\",\
		\"weight\": 1975,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceMetric.calibration.time\",\
		\"weight\": 1976,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest\",\
		\"weight\": 1977,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.id\",\
		\"weight\": 1978,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.meta\",\
		\"weight\": 1979,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.implicitRules\",\
		\"weight\": 1980,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.language\",\
		\"weight\": 1981,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.text\",\
		\"weight\": 1982,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.contained\",\
		\"weight\": 1983,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.extension\",\
		\"weight\": 1984,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.modifierExtension\",\
		\"weight\": 1985,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.identifier\",\
		\"weight\": 1986,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.definition\",\
		\"weight\": 1987,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.basedOn\",\
		\"weight\": 1988,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.replaces\",\
		\"weight\": 1989,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.requisition\",\
		\"weight\": 1990,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.status\",\
		\"weight\": 1991,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceUseRequest.stage\",\
		\"weight\": 1992,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceUseRequest.deviceReference\",\
		\"weight\": 1993,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceUseRequest.deviceCodeableConcept\",\
		\"weight\": 1993,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceUseRequest.subject\",\
		\"weight\": 1994,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.context\",\
		\"weight\": 1995,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.occurrenceDateTime\",\
		\"weight\": 1996,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.occurrencePeriod\",\
		\"weight\": 1996,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.occurrenceTiming\",\
		\"weight\": 1996,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.authored\",\
		\"weight\": 1997,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.requester\",\
		\"weight\": 1998,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.performerType\",\
		\"weight\": 1999,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.performer\",\
		\"weight\": 2000,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.reasonCode\",\
		\"weight\": 2001,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.reasonReference\",\
		\"weight\": 2002,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.supportingInfo\",\
		\"weight\": 2003,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.note\",\
		\"weight\": 2004,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseRequest.relevantHistory\",\
		\"weight\": 2005,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement\",\
		\"weight\": 2006,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.id\",\
		\"weight\": 2007,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.meta\",\
		\"weight\": 2008,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.implicitRules\",\
		\"weight\": 2009,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.language\",\
		\"weight\": 2010,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.text\",\
		\"weight\": 2011,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.contained\",\
		\"weight\": 2012,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.extension\",\
		\"weight\": 2013,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.modifierExtension\",\
		\"weight\": 2014,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.bodySiteCodeableConcept\",\
		\"weight\": 2015,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.bodySiteReference\",\
		\"weight\": 2015,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.whenUsed\",\
		\"weight\": 2016,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceUseStatement.device\",\
		\"weight\": 2017,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.identifier\",\
		\"weight\": 2018,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.indication\",\
		\"weight\": 2019,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.notes\",\
		\"weight\": 2020,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.recordedOn\",\
		\"weight\": 2021,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DeviceUseStatement.subject\",\
		\"weight\": 2022,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.timingTiming\",\
		\"weight\": 2023,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.timingPeriod\",\
		\"weight\": 2023,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DeviceUseStatement.timingDateTime\",\
		\"weight\": 2023,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport\",\
		\"weight\": 2024,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.id\",\
		\"weight\": 2025,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.meta\",\
		\"weight\": 2026,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.implicitRules\",\
		\"weight\": 2027,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.language\",\
		\"weight\": 2028,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.text\",\
		\"weight\": 2029,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.contained\",\
		\"weight\": 2030,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.extension\",\
		\"weight\": 2031,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.modifierExtension\",\
		\"weight\": 2032,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.identifier\",\
		\"weight\": 2033,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticReport.status\",\
		\"weight\": 2034,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.category\",\
		\"weight\": 2035,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticReport.code\",\
		\"weight\": 2036,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticReport.subject\",\
		\"weight\": 2037,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.encounter\",\
		\"weight\": 2038,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticReport.effectiveDateTime\",\
		\"weight\": 2039,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticReport.effectivePeriod\",\
		\"weight\": 2039,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticReport.issued\",\
		\"weight\": 2040,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticReport.performer\",\
		\"weight\": 2041,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.request\",\
		\"weight\": 2042,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.specimen\",\
		\"weight\": 2043,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.result\",\
		\"weight\": 2044,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.imagingStudy\",\
		\"weight\": 2045,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.image\",\
		\"weight\": 2046,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.image.id\",\
		\"weight\": 2047,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.image.extension\",\
		\"weight\": 2048,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.image.modifierExtension\",\
		\"weight\": 2049,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.image.comment\",\
		\"weight\": 2050,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticReport.image.link\",\
		\"weight\": 2051,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.conclusion\",\
		\"weight\": 2052,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.codedDiagnosis\",\
		\"weight\": 2053,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticReport.presentedForm\",\
		\"weight\": 2054,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest\",\
		\"weight\": 2055,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.id\",\
		\"weight\": 2056,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.meta\",\
		\"weight\": 2057,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.implicitRules\",\
		\"weight\": 2058,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.language\",\
		\"weight\": 2059,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.text\",\
		\"weight\": 2060,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.contained\",\
		\"weight\": 2061,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.extension\",\
		\"weight\": 2062,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.modifierExtension\",\
		\"weight\": 2063,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.identifier\",\
		\"weight\": 2064,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.definition\",\
		\"weight\": 2065,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.basedOn\",\
		\"weight\": 2066,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.replaces\",\
		\"weight\": 2067,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.requisition\",\
		\"weight\": 2068,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.status\",\
		\"weight\": 2069,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticRequest.stage\",\
		\"weight\": 2070,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticRequest.code\",\
		\"weight\": 2071,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DiagnosticRequest.subject\",\
		\"weight\": 2072,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.context\",\
		\"weight\": 2073,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.occurrenceDateTime\",\
		\"weight\": 2074,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.occurrencePeriod\",\
		\"weight\": 2074,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.occurrenceTiming\",\
		\"weight\": 2074,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.authored\",\
		\"weight\": 2075,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.requester\",\
		\"weight\": 2076,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.performerType\",\
		\"weight\": 2077,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.performer\",\
		\"weight\": 2078,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.reason\",\
		\"weight\": 2079,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.supportingInformation\",\
		\"weight\": 2080,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.note\",\
		\"weight\": 2081,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DiagnosticRequest.relevantHistory\",\
		\"weight\": 2082,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest\",\
		\"weight\": 2083,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.id\",\
		\"weight\": 2084,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.meta\",\
		\"weight\": 2085,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.implicitRules\",\
		\"weight\": 2086,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.language\",\
		\"weight\": 2087,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.text\",\
		\"weight\": 2088,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.contained\",\
		\"weight\": 2089,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.extension\",\
		\"weight\": 2090,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.modifierExtension\",\
		\"weight\": 2091,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.masterIdentifier\",\
		\"weight\": 2092,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.identifier\",\
		\"weight\": 2093,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.subject\",\
		\"weight\": 2094,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.recipient\",\
		\"weight\": 2095,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.type\",\
		\"weight\": 2096,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.author\",\
		\"weight\": 2097,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.created\",\
		\"weight\": 2098,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.source\",\
		\"weight\": 2099,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentManifest.status\",\
		\"weight\": 2100,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.description\",\
		\"weight\": 2101,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentManifest.content\",\
		\"weight\": 2102,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.content.id\",\
		\"weight\": 2103,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.content.extension\",\
		\"weight\": 2104,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.content.modifierExtension\",\
		\"weight\": 2105,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentManifest.content.pAttachment\",\
		\"weight\": 2106,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentManifest.content.pReference\",\
		\"weight\": 2106,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.related\",\
		\"weight\": 2107,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.related.id\",\
		\"weight\": 2108,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.related.extension\",\
		\"weight\": 2109,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.related.modifierExtension\",\
		\"weight\": 2110,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.related.identifier\",\
		\"weight\": 2111,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentManifest.related.ref\",\
		\"weight\": 2112,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference\",\
		\"weight\": 2113,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.id\",\
		\"weight\": 2114,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.meta\",\
		\"weight\": 2115,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.implicitRules\",\
		\"weight\": 2116,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.language\",\
		\"weight\": 2117,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.text\",\
		\"weight\": 2118,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.contained\",\
		\"weight\": 2119,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.extension\",\
		\"weight\": 2120,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.modifierExtension\",\
		\"weight\": 2121,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.masterIdentifier\",\
		\"weight\": 2122,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.identifier\",\
		\"weight\": 2123,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.subject\",\
		\"weight\": 2124,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentReference.type\",\
		\"weight\": 2125,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.class\",\
		\"weight\": 2126,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.author\",\
		\"weight\": 2127,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.custodian\",\
		\"weight\": 2128,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.authenticator\",\
		\"weight\": 2129,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.created\",\
		\"weight\": 2130,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentReference.indexed\",\
		\"weight\": 2131,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentReference.status\",\
		\"weight\": 2132,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.docStatus\",\
		\"weight\": 2133,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.relatesTo\",\
		\"weight\": 2134,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.relatesTo.id\",\
		\"weight\": 2135,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.relatesTo.extension\",\
		\"weight\": 2136,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.relatesTo.modifierExtension\",\
		\"weight\": 2137,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentReference.relatesTo.code\",\
		\"weight\": 2138,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentReference.relatesTo.target\",\
		\"weight\": 2139,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.description\",\
		\"weight\": 2140,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.securityLabel\",\
		\"weight\": 2141,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentReference.content\",\
		\"weight\": 2142,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.content.id\",\
		\"weight\": 2143,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.content.extension\",\
		\"weight\": 2144,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.content.modifierExtension\",\
		\"weight\": 2145,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"DocumentReference.content.attachment\",\
		\"weight\": 2146,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.content.format\",\
		\"weight\": 2147,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context\",\
		\"weight\": 2148,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.id\",\
		\"weight\": 2149,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.extension\",\
		\"weight\": 2150,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.modifierExtension\",\
		\"weight\": 2151,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.encounter\",\
		\"weight\": 2152,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.event\",\
		\"weight\": 2153,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.period\",\
		\"weight\": 2154,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.facilityType\",\
		\"weight\": 2155,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.practiceSetting\",\
		\"weight\": 2156,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.sourcePatientInfo\",\
		\"weight\": 2157,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.related\",\
		\"weight\": 2158,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.related.id\",\
		\"weight\": 2159,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.related.extension\",\
		\"weight\": 2160,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.related.modifierExtension\",\
		\"weight\": 2161,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.related.identifier\",\
		\"weight\": 2162,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"DocumentReference.context.related.ref\",\
		\"weight\": 2163,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest\",\
		\"weight\": 2164,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.id\",\
		\"weight\": 2165,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.meta\",\
		\"weight\": 2166,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.implicitRules\",\
		\"weight\": 2167,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.language\",\
		\"weight\": 2168,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.text\",\
		\"weight\": 2169,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.contained\",\
		\"weight\": 2170,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.extension\",\
		\"weight\": 2171,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.modifierExtension\",\
		\"weight\": 2172,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.identifier\",\
		\"weight\": 2173,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EligibilityRequest.status\",\
		\"weight\": 2174,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.ruleset\",\
		\"weight\": 2175,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.originalRuleset\",\
		\"weight\": 2176,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.created\",\
		\"weight\": 2177,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.insurerIdentifier\",\
		\"weight\": 2178,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.insurerReference\",\
		\"weight\": 2178,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.providerIdentifier\",\
		\"weight\": 2179,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.providerReference\",\
		\"weight\": 2179,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.organizationIdentifier\",\
		\"weight\": 2180,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.organizationReference\",\
		\"weight\": 2180,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.priority\",\
		\"weight\": 2181,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.entererIdentifier\",\
		\"weight\": 2182,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.entererReference\",\
		\"weight\": 2182,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.facilityIdentifier\",\
		\"weight\": 2183,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.facilityReference\",\
		\"weight\": 2183,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.patientIdentifier\",\
		\"weight\": 2184,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.patientReference\",\
		\"weight\": 2184,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.coverageIdentifier\",\
		\"weight\": 2185,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.coverageReference\",\
		\"weight\": 2185,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.businessArrangement\",\
		\"weight\": 2186,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.servicedDate\",\
		\"weight\": 2187,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.servicedPeriod\",\
		\"weight\": 2187,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.benefitCategory\",\
		\"weight\": 2188,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityRequest.benefitSubCategory\",\
		\"weight\": 2189,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse\",\
		\"weight\": 2190,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.id\",\
		\"weight\": 2191,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.meta\",\
		\"weight\": 2192,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.implicitRules\",\
		\"weight\": 2193,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.language\",\
		\"weight\": 2194,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.text\",\
		\"weight\": 2195,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.contained\",\
		\"weight\": 2196,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.extension\",\
		\"weight\": 2197,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.modifierExtension\",\
		\"weight\": 2198,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.identifier\",\
		\"weight\": 2199,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EligibilityResponse.status\",\
		\"weight\": 2200,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.requestIdentifier\",\
		\"weight\": 2201,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.requestReference\",\
		\"weight\": 2201,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.outcome\",\
		\"weight\": 2202,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.disposition\",\
		\"weight\": 2203,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.ruleset\",\
		\"weight\": 2204,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.originalRuleset\",\
		\"weight\": 2205,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.created\",\
		\"weight\": 2206,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.organizationIdentifier\",\
		\"weight\": 2207,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.organizationReference\",\
		\"weight\": 2207,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.requestProviderIdentifier\",\
		\"weight\": 2208,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.requestProviderReference\",\
		\"weight\": 2208,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.requestOrganizationIdentifier\",\
		\"weight\": 2209,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.requestOrganizationReference\",\
		\"weight\": 2209,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.inforce\",\
		\"weight\": 2210,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.contract\",\
		\"weight\": 2211,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.form\",\
		\"weight\": 2212,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance\",\
		\"weight\": 2213,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.id\",\
		\"weight\": 2214,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.extension\",\
		\"weight\": 2215,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.modifierExtension\",\
		\"weight\": 2216,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EligibilityResponse.benefitBalance.category\",\
		\"weight\": 2217,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.subCategory\",\
		\"weight\": 2218,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.name\",\
		\"weight\": 2219,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.description\",\
		\"weight\": 2220,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.network\",\
		\"weight\": 2221,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.unit\",\
		\"weight\": 2222,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.term\",\
		\"weight\": 2223,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial\",\
		\"weight\": 2224,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.id\",\
		\"weight\": 2225,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.extension\",\
		\"weight\": 2226,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.modifierExtension\",\
		\"weight\": 2227,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.type\",\
		\"weight\": 2228,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUnsignedInt\",\
		\"weight\": 2229,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitString\",\
		\"weight\": 2229,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitMoney\",\
		\"weight\": 2229,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUsedUnsignedInt\",\
		\"weight\": 2230,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUsedMoney\",\
		\"weight\": 2230,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.error\",\
		\"weight\": 2231,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.error.id\",\
		\"weight\": 2232,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.error.extension\",\
		\"weight\": 2233,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EligibilityResponse.error.modifierExtension\",\
		\"weight\": 2234,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EligibilityResponse.error.code\",\
		\"weight\": 2235,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter\",\
		\"weight\": 2236,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.id\",\
		\"weight\": 2237,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.meta\",\
		\"weight\": 2238,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.implicitRules\",\
		\"weight\": 2239,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.language\",\
		\"weight\": 2240,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.text\",\
		\"weight\": 2241,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.contained\",\
		\"weight\": 2242,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.extension\",\
		\"weight\": 2243,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.modifierExtension\",\
		\"weight\": 2244,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.identifier\",\
		\"weight\": 2245,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Encounter.status\",\
		\"weight\": 2246,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.statusHistory\",\
		\"weight\": 2247,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.statusHistory.id\",\
		\"weight\": 2248,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.statusHistory.extension\",\
		\"weight\": 2249,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.statusHistory.modifierExtension\",\
		\"weight\": 2250,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Encounter.statusHistory.status\",\
		\"weight\": 2251,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Encounter.statusHistory.period\",\
		\"weight\": 2252,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.class\",\
		\"weight\": 2253,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.type\",\
		\"weight\": 2254,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.priority\",\
		\"weight\": 2255,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.patient\",\
		\"weight\": 2256,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.episodeOfCare\",\
		\"weight\": 2257,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.incomingReferral\",\
		\"weight\": 2258,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.participant\",\
		\"weight\": 2259,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.participant.id\",\
		\"weight\": 2260,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.participant.extension\",\
		\"weight\": 2261,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.participant.modifierExtension\",\
		\"weight\": 2262,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.participant.type\",\
		\"weight\": 2263,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.participant.period\",\
		\"weight\": 2264,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.participant.individual\",\
		\"weight\": 2265,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.appointment\",\
		\"weight\": 2266,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.period\",\
		\"weight\": 2267,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.length\",\
		\"weight\": 2268,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.reason\",\
		\"weight\": 2269,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.indication\",\
		\"weight\": 2270,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.account\",\
		\"weight\": 2271,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization\",\
		\"weight\": 2272,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.id\",\
		\"weight\": 2273,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.extension\",\
		\"weight\": 2274,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.modifierExtension\",\
		\"weight\": 2275,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.preAdmissionIdentifier\",\
		\"weight\": 2276,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.origin\",\
		\"weight\": 2277,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.admitSource\",\
		\"weight\": 2278,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.admittingDiagnosis\",\
		\"weight\": 2279,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.reAdmission\",\
		\"weight\": 2280,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.dietPreference\",\
		\"weight\": 2281,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.specialCourtesy\",\
		\"weight\": 2282,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.specialArrangement\",\
		\"weight\": 2283,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.destination\",\
		\"weight\": 2284,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.dischargeDisposition\",\
		\"weight\": 2285,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.hospitalization.dischargeDiagnosis\",\
		\"weight\": 2286,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.location\",\
		\"weight\": 2287,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.location.id\",\
		\"weight\": 2288,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.location.extension\",\
		\"weight\": 2289,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.location.modifierExtension\",\
		\"weight\": 2290,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Encounter.location.location\",\
		\"weight\": 2291,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.location.status\",\
		\"weight\": 2292,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.location.period\",\
		\"weight\": 2293,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.serviceProvider\",\
		\"weight\": 2294,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Encounter.partOf\",\
		\"weight\": 2295,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint\",\
		\"weight\": 2296,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.id\",\
		\"weight\": 2297,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.meta\",\
		\"weight\": 2298,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.implicitRules\",\
		\"weight\": 2299,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.language\",\
		\"weight\": 2300,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.text\",\
		\"weight\": 2301,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.contained\",\
		\"weight\": 2302,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.extension\",\
		\"weight\": 2303,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.modifierExtension\",\
		\"weight\": 2304,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.identifier\",\
		\"weight\": 2305,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Endpoint.status\",\
		\"weight\": 2306,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.name\",\
		\"weight\": 2307,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.managingOrganization\",\
		\"weight\": 2308,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.contact\",\
		\"weight\": 2309,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Endpoint.connectionType\",\
		\"weight\": 2310,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.method\",\
		\"weight\": 2311,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.period\",\
		\"weight\": 2312,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Endpoint.address\",\
		\"weight\": 2313,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Endpoint.payloadFormat\",\
		\"weight\": 2314,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Endpoint.payloadType\",\
		\"weight\": 2315,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.header\",\
		\"weight\": 2316,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Endpoint.publicKey\",\
		\"weight\": 2317,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest\",\
		\"weight\": 2318,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.id\",\
		\"weight\": 2319,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.meta\",\
		\"weight\": 2320,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.implicitRules\",\
		\"weight\": 2321,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.language\",\
		\"weight\": 2322,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.text\",\
		\"weight\": 2323,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.contained\",\
		\"weight\": 2324,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.extension\",\
		\"weight\": 2325,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.modifierExtension\",\
		\"weight\": 2326,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.identifier\",\
		\"weight\": 2327,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EnrollmentRequest.status\",\
		\"weight\": 2328,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.ruleset\",\
		\"weight\": 2329,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.originalRuleset\",\
		\"weight\": 2330,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.created\",\
		\"weight\": 2331,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.insurerIdentifier\",\
		\"weight\": 2332,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.insurerReference\",\
		\"weight\": 2332,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.providerIdentifier\",\
		\"weight\": 2333,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.providerReference\",\
		\"weight\": 2333,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.organizationIdentifier\",\
		\"weight\": 2334,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentRequest.organizationReference\",\
		\"weight\": 2334,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EnrollmentRequest.subjectIdentifier\",\
		\"weight\": 2335,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EnrollmentRequest.subjectReference\",\
		\"weight\": 2335,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EnrollmentRequest.coverage\",\
		\"weight\": 2336,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse\",\
		\"weight\": 2337,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.id\",\
		\"weight\": 2338,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.meta\",\
		\"weight\": 2339,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.implicitRules\",\
		\"weight\": 2340,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.language\",\
		\"weight\": 2341,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.text\",\
		\"weight\": 2342,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.contained\",\
		\"weight\": 2343,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.extension\",\
		\"weight\": 2344,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.modifierExtension\",\
		\"weight\": 2345,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.identifier\",\
		\"weight\": 2346,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EnrollmentResponse.status\",\
		\"weight\": 2347,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.requestIdentifier\",\
		\"weight\": 2348,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.requestReference\",\
		\"weight\": 2348,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.outcome\",\
		\"weight\": 2349,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.disposition\",\
		\"weight\": 2350,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.ruleset\",\
		\"weight\": 2351,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.originalRuleset\",\
		\"weight\": 2352,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.created\",\
		\"weight\": 2353,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.organizationIdentifier\",\
		\"weight\": 2354,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.organizationReference\",\
		\"weight\": 2354,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.requestProviderIdentifier\",\
		\"weight\": 2355,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.requestProviderReference\",\
		\"weight\": 2355,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.requestOrganizationIdentifier\",\
		\"weight\": 2356,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EnrollmentResponse.requestOrganizationReference\",\
		\"weight\": 2356,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare\",\
		\"weight\": 2357,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.id\",\
		\"weight\": 2358,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.meta\",\
		\"weight\": 2359,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.implicitRules\",\
		\"weight\": 2360,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.language\",\
		\"weight\": 2361,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.text\",\
		\"weight\": 2362,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.contained\",\
		\"weight\": 2363,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.extension\",\
		\"weight\": 2364,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.modifierExtension\",\
		\"weight\": 2365,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.identifier\",\
		\"weight\": 2366,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EpisodeOfCare.status\",\
		\"weight\": 2367,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.statusHistory\",\
		\"weight\": 2368,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.statusHistory.id\",\
		\"weight\": 2369,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.statusHistory.extension\",\
		\"weight\": 2370,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.statusHistory.modifierExtension\",\
		\"weight\": 2371,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EpisodeOfCare.statusHistory.status\",\
		\"weight\": 2372,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EpisodeOfCare.statusHistory.period\",\
		\"weight\": 2373,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.type\",\
		\"weight\": 2374,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.condition\",\
		\"weight\": 2375,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"EpisodeOfCare.patient\",\
		\"weight\": 2376,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.managingOrganization\",\
		\"weight\": 2377,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.period\",\
		\"weight\": 2378,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.referralRequest\",\
		\"weight\": 2379,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.careManager\",\
		\"weight\": 2380,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.team\",\
		\"weight\": 2381,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"EpisodeOfCare.account\",\
		\"weight\": 2382,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile\",\
		\"weight\": 2383,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.id\",\
		\"weight\": 2384,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.meta\",\
		\"weight\": 2385,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.implicitRules\",\
		\"weight\": 2386,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.language\",\
		\"weight\": 2387,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.text\",\
		\"weight\": 2388,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.contained\",\
		\"weight\": 2389,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.extension\",\
		\"weight\": 2390,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.modifierExtension\",\
		\"weight\": 2391,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.url\",\
		\"weight\": 2392,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.identifier\",\
		\"weight\": 2393,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.version\",\
		\"weight\": 2394,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.name\",\
		\"weight\": 2395,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExpansionProfile.status\",\
		\"weight\": 2396,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.experimental\",\
		\"weight\": 2397,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.publisher\",\
		\"weight\": 2398,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.contact\",\
		\"weight\": 2399,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.contact.id\",\
		\"weight\": 2400,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.contact.extension\",\
		\"weight\": 2401,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.contact.modifierExtension\",\
		\"weight\": 2402,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.contact.name\",\
		\"weight\": 2403,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.contact.telecom\",\
		\"weight\": 2404,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.date\",\
		\"weight\": 2405,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.description\",\
		\"weight\": 2406,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem\",\
		\"weight\": 2407,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.id\",\
		\"weight\": 2408,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.extension\",\
		\"weight\": 2409,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.modifierExtension\",\
		\"weight\": 2410,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.include\",\
		\"weight\": 2411,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.include.id\",\
		\"weight\": 2412,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.include.extension\",\
		\"weight\": 2413,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.include.modifierExtension\",\
		\"weight\": 2414,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem\",\
		\"weight\": 2415,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.id\",\
		\"weight\": 2416,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.extension\",\
		\"weight\": 2417,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.modifierExtension\",\
		\"weight\": 2418,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.system\",\
		\"weight\": 2419,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.version\",\
		\"weight\": 2420,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude\",\
		\"weight\": 2421,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.id\",\
		\"weight\": 2422,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.extension\",\
		\"weight\": 2423,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.modifierExtension\",\
		\"weight\": 2424,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem\",\
		\"weight\": 2425,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.id\",\
		\"weight\": 2426,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.extension\",\
		\"weight\": 2427,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.modifierExtension\",\
		\"weight\": 2428,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.system\",\
		\"weight\": 2429,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.version\",\
		\"weight\": 2430,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.includeDesignations\",\
		\"weight\": 2431,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation\",\
		\"weight\": 2432,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.id\",\
		\"weight\": 2433,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.extension\",\
		\"weight\": 2434,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.modifierExtension\",\
		\"weight\": 2435,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include\",\
		\"weight\": 2436,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.id\",\
		\"weight\": 2437,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.extension\",\
		\"weight\": 2438,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.modifierExtension\",\
		\"weight\": 2439,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.designation\",\
		\"weight\": 2440,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.designation.id\",\
		\"weight\": 2441,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.designation.extension\",\
		\"weight\": 2442,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.designation.modifierExtension\",\
		\"weight\": 2443,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.designation.language\",\
		\"weight\": 2444,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.include.designation.use\",\
		\"weight\": 2445,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude\",\
		\"weight\": 2446,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.id\",\
		\"weight\": 2447,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.extension\",\
		\"weight\": 2448,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.modifierExtension\",\
		\"weight\": 2449,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.designation\",\
		\"weight\": 2450,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.designation.id\",\
		\"weight\": 2451,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.designation.extension\",\
		\"weight\": 2452,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.designation.modifierExtension\",\
		\"weight\": 2453,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.designation.language\",\
		\"weight\": 2454,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.designation.exclude.designation.use\",\
		\"weight\": 2455,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.includeDefinition\",\
		\"weight\": 2456,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.includeInactive\",\
		\"weight\": 2457,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.excludeNested\",\
		\"weight\": 2458,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.excludeNotForUI\",\
		\"weight\": 2459,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.excludePostCoordinated\",\
		\"weight\": 2460,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.displayLanguage\",\
		\"weight\": 2461,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExpansionProfile.limitedExpansion\",\
		\"weight\": 2462,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit\",\
		\"weight\": 2463,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.id\",\
		\"weight\": 2464,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.meta\",\
		\"weight\": 2465,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.implicitRules\",\
		\"weight\": 2466,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.language\",\
		\"weight\": 2467,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.text\",\
		\"weight\": 2468,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.contained\",\
		\"weight\": 2469,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.extension\",\
		\"weight\": 2470,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.modifierExtension\",\
		\"weight\": 2471,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.identifier\",\
		\"weight\": 2472,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.status\",\
		\"weight\": 2473,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.authorIdentifier\",\
		\"weight\": 2474,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.authorReference\",\
		\"weight\": 2474,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.claimIdentifier\",\
		\"weight\": 2475,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.claimReference\",\
		\"weight\": 2475,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.claimResponseIdentifier\",\
		\"weight\": 2476,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.claimResponseReference\",\
		\"weight\": 2476,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.type\",\
		\"weight\": 2477,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.subType\",\
		\"weight\": 2478,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.ruleset\",\
		\"weight\": 2479,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.originalRuleset\",\
		\"weight\": 2480,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.created\",\
		\"weight\": 2481,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.billablePeriod\",\
		\"weight\": 2482,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.outcome\",\
		\"weight\": 2483,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.disposition\",\
		\"weight\": 2484,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.providerIdentifier\",\
		\"weight\": 2485,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.providerReference\",\
		\"weight\": 2485,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.organizationIdentifier\",\
		\"weight\": 2486,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.organizationReference\",\
		\"weight\": 2486,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.facilityIdentifier\",\
		\"weight\": 2487,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.facilityReference\",\
		\"weight\": 2487,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.related\",\
		\"weight\": 2488,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.related.id\",\
		\"weight\": 2489,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.related.extension\",\
		\"weight\": 2490,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.related.modifierExtension\",\
		\"weight\": 2491,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.related.claimIdentifier\",\
		\"weight\": 2492,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.related.claimReference\",\
		\"weight\": 2492,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.related.relationship\",\
		\"weight\": 2493,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.related.reference\",\
		\"weight\": 2494,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.prescriptionIdentifier\",\
		\"weight\": 2495,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.prescriptionReference\",\
		\"weight\": 2495,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.prescriptionReference\",\
		\"weight\": 2495,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.originalPrescriptionIdentifier\",\
		\"weight\": 2496,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.originalPrescriptionReference\",\
		\"weight\": 2496,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee\",\
		\"weight\": 2497,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.id\",\
		\"weight\": 2498,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.extension\",\
		\"weight\": 2499,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.modifierExtension\",\
		\"weight\": 2500,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.type\",\
		\"weight\": 2501,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.resourceType\",\
		\"weight\": 2502,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.partyIdentifier\",\
		\"weight\": 2503,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2503,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2503,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2503,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2503,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.referralIdentifier\",\
		\"weight\": 2504,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.referralReference\",\
		\"weight\": 2504,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information\",\
		\"weight\": 2505,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information.id\",\
		\"weight\": 2506,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information.extension\",\
		\"weight\": 2507,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information.modifierExtension\",\
		\"weight\": 2508,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.information.category\",\
		\"weight\": 2509,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information.code\",\
		\"weight\": 2510,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information.timingDate\",\
		\"weight\": 2511,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information.timingPeriod\",\
		\"weight\": 2511,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information.valueString\",\
		\"weight\": 2512,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.information.valueQuantity\",\
		\"weight\": 2512,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.diagnosis\",\
		\"weight\": 2513,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.diagnosis.id\",\
		\"weight\": 2514,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.diagnosis.extension\",\
		\"weight\": 2515,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.diagnosis.modifierExtension\",\
		\"weight\": 2516,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.diagnosis.sequence\",\
		\"weight\": 2517,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.diagnosis.diagnosis\",\
		\"weight\": 2518,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.diagnosis.type\",\
		\"weight\": 2519,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.diagnosis.drg\",\
		\"weight\": 2520,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.procedure\",\
		\"weight\": 2521,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.procedure.id\",\
		\"weight\": 2522,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.procedure.extension\",\
		\"weight\": 2523,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.procedure.modifierExtension\",\
		\"weight\": 2524,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.procedure.sequence\",\
		\"weight\": 2525,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.procedure.date\",\
		\"weight\": 2526,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.procedure.procedureCoding\",\
		\"weight\": 2527,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.procedure.procedureReference\",\
		\"weight\": 2527,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.patientIdentifier\",\
		\"weight\": 2528,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.patientReference\",\
		\"weight\": 2528,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.precedence\",\
		\"weight\": 2529,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.coverage\",\
		\"weight\": 2530,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.coverage.id\",\
		\"weight\": 2531,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.coverage.extension\",\
		\"weight\": 2532,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.coverage.modifierExtension\",\
		\"weight\": 2533,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.coverage.coverageIdentifier\",\
		\"weight\": 2534,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.coverage.coverageReference\",\
		\"weight\": 2534,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.coverage.preAuthRef\",\
		\"weight\": 2535,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.accident\",\
		\"weight\": 2536,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.accident.id\",\
		\"weight\": 2537,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.accident.extension\",\
		\"weight\": 2538,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.accident.modifierExtension\",\
		\"weight\": 2539,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.accident.date\",\
		\"weight\": 2540,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.accident.type\",\
		\"weight\": 2541,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.accident.locationAddress\",\
		\"weight\": 2542,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.accident.locationReference\",\
		\"weight\": 2542,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.employmentImpacted\",\
		\"weight\": 2543,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.hospitalization\",\
		\"weight\": 2544,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item\",\
		\"weight\": 2545,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.id\",\
		\"weight\": 2546,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.extension\",\
		\"weight\": 2547,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.modifierExtension\",\
		\"weight\": 2548,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.sequence\",\
		\"weight\": 2549,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam\",\
		\"weight\": 2550,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.id\",\
		\"weight\": 2551,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.extension\",\
		\"weight\": 2552,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.modifierExtension\",\
		\"weight\": 2553,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.providerIdentifier\",\
		\"weight\": 2554,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.providerReference\",\
		\"weight\": 2554,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.providerReference\",\
		\"weight\": 2554,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.responsible\",\
		\"weight\": 2555,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.role\",\
		\"weight\": 2556,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.careTeam.qualification\",\
		\"weight\": 2557,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.diagnosisLinkId\",\
		\"weight\": 2558,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.revenue\",\
		\"weight\": 2559,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.category\",\
		\"weight\": 2560,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.service\",\
		\"weight\": 2561,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.modifier\",\
		\"weight\": 2562,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.programCode\",\
		\"weight\": 2563,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.servicedDate\",\
		\"weight\": 2564,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.servicedPeriod\",\
		\"weight\": 2564,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.locationCoding\",\
		\"weight\": 2565,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.locationAddress\",\
		\"weight\": 2565,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.locationReference\",\
		\"weight\": 2565,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.quantity\",\
		\"weight\": 2566,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.unitPrice\",\
		\"weight\": 2567,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.factor\",\
		\"weight\": 2568,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.points\",\
		\"weight\": 2569,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.net\",\
		\"weight\": 2570,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.udi\",\
		\"weight\": 2571,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.bodySite\",\
		\"weight\": 2572,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.subSite\",\
		\"weight\": 2573,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.noteNumber\",\
		\"weight\": 2574,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.adjudication\",\
		\"weight\": 2575,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.adjudication.id\",\
		\"weight\": 2576,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.adjudication.extension\",\
		\"weight\": 2577,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.adjudication.modifierExtension\",\
		\"weight\": 2578,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.adjudication.category\",\
		\"weight\": 2579,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.adjudication.reason\",\
		\"weight\": 2580,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.adjudication.amount\",\
		\"weight\": 2581,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.adjudication.value\",\
		\"weight\": 2582,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail\",\
		\"weight\": 2583,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.id\",\
		\"weight\": 2584,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.extension\",\
		\"weight\": 2585,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.modifierExtension\",\
		\"weight\": 2586,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.detail.sequence\",\
		\"weight\": 2587,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.detail.type\",\
		\"weight\": 2588,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.revenue\",\
		\"weight\": 2589,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.category\",\
		\"weight\": 2590,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.service\",\
		\"weight\": 2591,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.modifier\",\
		\"weight\": 2592,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.programCode\",\
		\"weight\": 2593,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.quantity\",\
		\"weight\": 2594,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.unitPrice\",\
		\"weight\": 2595,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.factor\",\
		\"weight\": 2596,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.points\",\
		\"weight\": 2597,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.net\",\
		\"weight\": 2598,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.udi\",\
		\"weight\": 2599,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.noteNumber\",\
		\"weight\": 2600,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication\",\
		\"weight\": 2601,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail\",\
		\"weight\": 2602,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.id\",\
		\"weight\": 2603,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.extension\",\
		\"weight\": 2604,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.modifierExtension\",\
		\"weight\": 2605,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.sequence\",\
		\"weight\": 2606,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.type\",\
		\"weight\": 2607,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.revenue\",\
		\"weight\": 2608,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.category\",\
		\"weight\": 2609,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.service\",\
		\"weight\": 2610,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.modifier\",\
		\"weight\": 2611,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.programCode\",\
		\"weight\": 2612,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.quantity\",\
		\"weight\": 2613,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.unitPrice\",\
		\"weight\": 2614,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.factor\",\
		\"weight\": 2615,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.points\",\
		\"weight\": 2616,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.net\",\
		\"weight\": 2617,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.udi\",\
		\"weight\": 2618,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.noteNumber\",\
		\"weight\": 2619,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication\",\
		\"weight\": 2620,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.prosthesis\",\
		\"weight\": 2621,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.id\",\
		\"weight\": 2622,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.extension\",\
		\"weight\": 2623,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.modifierExtension\",\
		\"weight\": 2624,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.initial\",\
		\"weight\": 2625,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.priorDate\",\
		\"weight\": 2626,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.priorMaterial\",\
		\"weight\": 2627,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem\",\
		\"weight\": 2628,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.id\",\
		\"weight\": 2629,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.extension\",\
		\"weight\": 2630,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.modifierExtension\",\
		\"weight\": 2631,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.sequenceLinkId\",\
		\"weight\": 2632,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.revenue\",\
		\"weight\": 2633,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.category\",\
		\"weight\": 2634,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.service\",\
		\"weight\": 2635,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.modifier\",\
		\"weight\": 2636,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.fee\",\
		\"weight\": 2637,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.noteNumber\",\
		\"weight\": 2638,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication\",\
		\"weight\": 2639,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail\",\
		\"weight\": 2640,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.id\",\
		\"weight\": 2641,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.extension\",\
		\"weight\": 2642,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.modifierExtension\",\
		\"weight\": 2643,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.revenue\",\
		\"weight\": 2644,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.category\",\
		\"weight\": 2645,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.service\",\
		\"weight\": 2646,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.modifier\",\
		\"weight\": 2647,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.fee\",\
		\"weight\": 2648,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.noteNumber\",\
		\"weight\": 2649,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication\",\
		\"weight\": 2650,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.missingTeeth\",\
		\"weight\": 2651,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.missingTeeth.id\",\
		\"weight\": 2652,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.missingTeeth.extension\",\
		\"weight\": 2653,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.missingTeeth.modifierExtension\",\
		\"weight\": 2654,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.missingTeeth.tooth\",\
		\"weight\": 2655,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.missingTeeth.reason\",\
		\"weight\": 2656,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.missingTeeth.extractionDate\",\
		\"weight\": 2657,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.totalCost\",\
		\"weight\": 2658,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.unallocDeductable\",\
		\"weight\": 2659,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.totalBenefit\",\
		\"weight\": 2660,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment\",\
		\"weight\": 2661,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.id\",\
		\"weight\": 2662,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.extension\",\
		\"weight\": 2663,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.modifierExtension\",\
		\"weight\": 2664,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.type\",\
		\"weight\": 2665,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.adjustment\",\
		\"weight\": 2666,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.adjustmentReason\",\
		\"weight\": 2667,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.date\",\
		\"weight\": 2668,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.amount\",\
		\"weight\": 2669,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.payment.identifier\",\
		\"weight\": 2670,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.form\",\
		\"weight\": 2671,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.note\",\
		\"weight\": 2672,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.note.id\",\
		\"weight\": 2673,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.note.extension\",\
		\"weight\": 2674,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.note.modifierExtension\",\
		\"weight\": 2675,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.note.number\",\
		\"weight\": 2676,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.note.type\",\
		\"weight\": 2677,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.note.text\",\
		\"weight\": 2678,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.note.language\",\
		\"weight\": 2679,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance\",\
		\"weight\": 2680,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.id\",\
		\"weight\": 2681,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.extension\",\
		\"weight\": 2682,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.modifierExtension\",\
		\"weight\": 2683,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.category\",\
		\"weight\": 2684,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.subCategory\",\
		\"weight\": 2685,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.name\",\
		\"weight\": 2686,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.description\",\
		\"weight\": 2687,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.network\",\
		\"weight\": 2688,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.unit\",\
		\"weight\": 2689,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.term\",\
		\"weight\": 2690,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial\",\
		\"weight\": 2691,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.id\",\
		\"weight\": 2692,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.extension\",\
		\"weight\": 2693,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.modifierExtension\",\
		\"weight\": 2694,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.type\",\
		\"weight\": 2695,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUnsignedInt\",\
		\"weight\": 2696,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitString\",\
		\"weight\": 2696,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitMoney\",\
		\"weight\": 2696,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUsedUnsignedInt\",\
		\"weight\": 2697,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUsedMoney\",\
		\"weight\": 2697,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory\",\
		\"weight\": 2698,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.id\",\
		\"weight\": 2699,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.meta\",\
		\"weight\": 2700,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.implicitRules\",\
		\"weight\": 2701,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.language\",\
		\"weight\": 2702,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.text\",\
		\"weight\": 2703,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.contained\",\
		\"weight\": 2704,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.extension\",\
		\"weight\": 2705,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.modifierExtension\",\
		\"weight\": 2706,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.identifier\",\
		\"weight\": 2707,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"FamilyMemberHistory.patient\",\
		\"weight\": 2708,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.date\",\
		\"weight\": 2709,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"FamilyMemberHistory.status\",\
		\"weight\": 2710,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.name\",\
		\"weight\": 2711,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"FamilyMemberHistory.relationship\",\
		\"weight\": 2712,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.gender\",\
		\"weight\": 2713,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.bornPeriod\",\
		\"weight\": 2714,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.bornDate\",\
		\"weight\": 2714,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.bornString\",\
		\"weight\": 2714,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.ageAge\",\
		\"weight\": 2715,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.ageRange\",\
		\"weight\": 2715,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.ageString\",\
		\"weight\": 2715,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.estimatedAge\",\
		\"weight\": 2716,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.deceasedBoolean\",\
		\"weight\": 2717,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.deceasedAge\",\
		\"weight\": 2717,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.deceasedRange\",\
		\"weight\": 2717,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.deceasedDate\",\
		\"weight\": 2717,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.deceasedString\",\
		\"weight\": 2717,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.note\",\
		\"weight\": 2718,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition\",\
		\"weight\": 2719,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.id\",\
		\"weight\": 2720,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.extension\",\
		\"weight\": 2721,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.modifierExtension\",\
		\"weight\": 2722,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"FamilyMemberHistory.condition.code\",\
		\"weight\": 2723,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.outcome\",\
		\"weight\": 2724,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.onsetAge\",\
		\"weight\": 2725,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.onsetRange\",\
		\"weight\": 2725,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.onsetPeriod\",\
		\"weight\": 2725,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.onsetString\",\
		\"weight\": 2725,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"FamilyMemberHistory.condition.note\",\
		\"weight\": 2726,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag\",\
		\"weight\": 2727,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.id\",\
		\"weight\": 2728,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.meta\",\
		\"weight\": 2729,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.implicitRules\",\
		\"weight\": 2730,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.language\",\
		\"weight\": 2731,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.text\",\
		\"weight\": 2732,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.contained\",\
		\"weight\": 2733,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.extension\",\
		\"weight\": 2734,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.modifierExtension\",\
		\"weight\": 2735,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.identifier\",\
		\"weight\": 2736,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.category\",\
		\"weight\": 2737,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Flag.status\",\
		\"weight\": 2738,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.period\",\
		\"weight\": 2739,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Flag.subject\",\
		\"weight\": 2740,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.encounter\",\
		\"weight\": 2741,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Flag.author\",\
		\"weight\": 2742,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Flag.code\",\
		\"weight\": 2743,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal\",\
		\"weight\": 2744,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.id\",\
		\"weight\": 2745,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.meta\",\
		\"weight\": 2746,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.implicitRules\",\
		\"weight\": 2747,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.language\",\
		\"weight\": 2748,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.text\",\
		\"weight\": 2749,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.contained\",\
		\"weight\": 2750,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.extension\",\
		\"weight\": 2751,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.modifierExtension\",\
		\"weight\": 2752,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.identifier\",\
		\"weight\": 2753,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.subject\",\
		\"weight\": 2754,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.startDate\",\
		\"weight\": 2755,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.startCodeableConcept\",\
		\"weight\": 2755,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.targetDate\",\
		\"weight\": 2756,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.targetDuration\",\
		\"weight\": 2756,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.category\",\
		\"weight\": 2757,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Goal.description\",\
		\"weight\": 2758,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Goal.status\",\
		\"weight\": 2759,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.statusDate\",\
		\"weight\": 2760,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.statusReason\",\
		\"weight\": 2761,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.expressedBy\",\
		\"weight\": 2762,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.priority\",\
		\"weight\": 2763,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.addresses\",\
		\"weight\": 2764,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.note\",\
		\"weight\": 2765,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.outcome\",\
		\"weight\": 2766,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.outcome.id\",\
		\"weight\": 2767,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.outcome.extension\",\
		\"weight\": 2768,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.outcome.modifierExtension\",\
		\"weight\": 2769,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.outcome.resultCodeableConcept\",\
		\"weight\": 2770,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Goal.outcome.resultReference\",\
		\"weight\": 2770,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group\",\
		\"weight\": 2771,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.id\",\
		\"weight\": 2772,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.meta\",\
		\"weight\": 2773,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.implicitRules\",\
		\"weight\": 2774,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.language\",\
		\"weight\": 2775,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.text\",\
		\"weight\": 2776,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.contained\",\
		\"weight\": 2777,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.extension\",\
		\"weight\": 2778,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.modifierExtension\",\
		\"weight\": 2779,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.identifier\",\
		\"weight\": 2780,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.type\",\
		\"weight\": 2781,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.actual\",\
		\"weight\": 2782,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.active\",\
		\"weight\": 2783,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.code\",\
		\"weight\": 2784,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.name\",\
		\"weight\": 2785,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.quantity\",\
		\"weight\": 2786,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.characteristic\",\
		\"weight\": 2787,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.characteristic.id\",\
		\"weight\": 2788,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.characteristic.extension\",\
		\"weight\": 2789,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.characteristic.modifierExtension\",\
		\"weight\": 2790,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.characteristic.code\",\
		\"weight\": 2791,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.characteristic.valueCodeableConcept\",\
		\"weight\": 2792,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.characteristic.valueBoolean\",\
		\"weight\": 2792,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.characteristic.valueQuantity\",\
		\"weight\": 2792,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.characteristic.valueRange\",\
		\"weight\": 2792,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.characteristic.exclude\",\
		\"weight\": 2793,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.characteristic.period\",\
		\"weight\": 2794,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.member\",\
		\"weight\": 2795,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.member.id\",\
		\"weight\": 2796,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.member.extension\",\
		\"weight\": 2797,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.member.modifierExtension\",\
		\"weight\": 2798,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Group.member.entity\",\
		\"weight\": 2799,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.member.period\",\
		\"weight\": 2800,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Group.member.inactive\",\
		\"weight\": 2801,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse\",\
		\"weight\": 2802,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.id\",\
		\"weight\": 2803,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.meta\",\
		\"weight\": 2804,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.implicitRules\",\
		\"weight\": 2805,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.language\",\
		\"weight\": 2806,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.text\",\
		\"weight\": 2807,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.contained\",\
		\"weight\": 2808,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.extension\",\
		\"weight\": 2809,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.modifierExtension\",\
		\"weight\": 2810,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.requestId\",\
		\"weight\": 2811,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.identifier\",\
		\"weight\": 2812,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"GuidanceResponse.module\",\
		\"weight\": 2813,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"GuidanceResponse.status\",\
		\"weight\": 2814,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.subject\",\
		\"weight\": 2815,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.context\",\
		\"weight\": 2816,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.occurrenceDateTime\",\
		\"weight\": 2817,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.performer\",\
		\"weight\": 2818,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.reasonCodeableConcept\",\
		\"weight\": 2819,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.reasonReference\",\
		\"weight\": 2819,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.note\",\
		\"weight\": 2820,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.evaluationMessage\",\
		\"weight\": 2821,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.outputParameters\",\
		\"weight\": 2822,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action\",\
		\"weight\": 2823,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.id\",\
		\"weight\": 2824,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.extension\",\
		\"weight\": 2825,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.modifierExtension\",\
		\"weight\": 2826,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.actionIdentifier\",\
		\"weight\": 2827,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.label\",\
		\"weight\": 2828,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.title\",\
		\"weight\": 2829,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.description\",\
		\"weight\": 2830,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.textEquivalent\",\
		\"weight\": 2831,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.concept\",\
		\"weight\": 2832,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.documentation\",\
		\"weight\": 2833,\
		\"max\": \"*\",\
		\"type\": \"RelatedResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.relatedAction\",\
		\"weight\": 2834,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.relatedAction.id\",\
		\"weight\": 2835,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.relatedAction.extension\",\
		\"weight\": 2836,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.relatedAction.modifierExtension\",\
		\"weight\": 2837,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"GuidanceResponse.action.relatedAction.actionIdentifier\",\
		\"weight\": 2838,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"GuidanceResponse.action.relatedAction.relationship\",\
		\"weight\": 2839,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.relatedAction.offsetDuration\",\
		\"weight\": 2840,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.relatedAction.offsetRange\",\
		\"weight\": 2840,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.relatedAction.anchor\",\
		\"weight\": 2841,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.timingDateTime\",\
		\"weight\": 2842,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.timingPeriod\",\
		\"weight\": 2842,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.timingDuration\",\
		\"weight\": 2842,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.timingRange\",\
		\"weight\": 2842,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.participant\",\
		\"weight\": 2843,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.type\",\
		\"weight\": 2844,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.groupingBehavior\",\
		\"weight\": 2845,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.selectionBehavior\",\
		\"weight\": 2846,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.requiredBehavior\",\
		\"weight\": 2847,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.precheckBehavior\",\
		\"weight\": 2848,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.cardinalityBehavior\",\
		\"weight\": 2849,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.resource\",\
		\"weight\": 2850,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.action.action\",\
		\"weight\": 2851,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"GuidanceResponse.dataRequirement\",\
		\"weight\": 2852,\
		\"max\": \"*\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService\",\
		\"weight\": 2853,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.id\",\
		\"weight\": 2854,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.meta\",\
		\"weight\": 2855,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.implicitRules\",\
		\"weight\": 2856,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.language\",\
		\"weight\": 2857,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.text\",\
		\"weight\": 2858,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.contained\",\
		\"weight\": 2859,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.extension\",\
		\"weight\": 2860,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.modifierExtension\",\
		\"weight\": 2861,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.identifier\",\
		\"weight\": 2862,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.active\",\
		\"weight\": 2863,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.providedBy\",\
		\"weight\": 2864,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.serviceCategory\",\
		\"weight\": 2865,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.serviceType\",\
		\"weight\": 2866,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.specialty\",\
		\"weight\": 2867,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.location\",\
		\"weight\": 2868,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.serviceName\",\
		\"weight\": 2869,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.comment\",\
		\"weight\": 2870,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.extraDetails\",\
		\"weight\": 2871,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.photo\",\
		\"weight\": 2872,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.telecom\",\
		\"weight\": 2873,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.coverageArea\",\
		\"weight\": 2874,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.serviceProvisionCode\",\
		\"weight\": 2875,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.eligibility\",\
		\"weight\": 2876,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.eligibilityNote\",\
		\"weight\": 2877,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.programName\",\
		\"weight\": 2878,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.characteristic\",\
		\"weight\": 2879,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.referralMethod\",\
		\"weight\": 2880,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.publicKey\",\
		\"weight\": 2881,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.appointmentRequired\",\
		\"weight\": 2882,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availableTime\",\
		\"weight\": 2883,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availableTime.id\",\
		\"weight\": 2884,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availableTime.extension\",\
		\"weight\": 2885,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availableTime.modifierExtension\",\
		\"weight\": 2886,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availableTime.daysOfWeek\",\
		\"weight\": 2887,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availableTime.allDay\",\
		\"weight\": 2888,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availableTime.availableStartTime\",\
		\"weight\": 2889,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availableTime.availableEndTime\",\
		\"weight\": 2890,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.notAvailable\",\
		\"weight\": 2891,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.notAvailable.id\",\
		\"weight\": 2892,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.notAvailable.extension\",\
		\"weight\": 2893,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.notAvailable.modifierExtension\",\
		\"weight\": 2894,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"HealthcareService.notAvailable.description\",\
		\"weight\": 2895,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.notAvailable.during\",\
		\"weight\": 2896,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"HealthcareService.availabilityExceptions\",\
		\"weight\": 2897,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest\",\
		\"weight\": 2898,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.id\",\
		\"weight\": 2899,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.meta\",\
		\"weight\": 2900,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.implicitRules\",\
		\"weight\": 2901,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.language\",\
		\"weight\": 2902,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.text\",\
		\"weight\": 2903,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.contained\",\
		\"weight\": 2904,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.extension\",\
		\"weight\": 2905,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.modifierExtension\",\
		\"weight\": 2906,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.uid\",\
		\"weight\": 2907,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.patient\",\
		\"weight\": 2908,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.authoringTime\",\
		\"weight\": 2909,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.author\",\
		\"weight\": 2910,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.title\",\
		\"weight\": 2911,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.description\",\
		\"weight\": 2912,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study\",\
		\"weight\": 2913,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.id\",\
		\"weight\": 2914,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.extension\",\
		\"weight\": 2915,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.modifierExtension\",\
		\"weight\": 2916,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.uid\",\
		\"weight\": 2917,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.imagingStudy\",\
		\"weight\": 2918,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.baseLocation\",\
		\"weight\": 2919,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.baseLocation.id\",\
		\"weight\": 2920,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.baseLocation.extension\",\
		\"weight\": 2921,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.baseLocation.modifierExtension\",\
		\"weight\": 2922,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.baseLocation.type\",\
		\"weight\": 2923,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.baseLocation.url\",\
		\"weight\": 2924,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.series\",\
		\"weight\": 2925,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.id\",\
		\"weight\": 2926,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.extension\",\
		\"weight\": 2927,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.modifierExtension\",\
		\"weight\": 2928,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.series.uid\",\
		\"weight\": 2929,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.baseLocation\",\
		\"weight\": 2930,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.baseLocation.id\",\
		\"weight\": 2931,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.baseLocation.extension\",\
		\"weight\": 2932,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.baseLocation.modifierExtension\",\
		\"weight\": 2933,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.series.baseLocation.type\",\
		\"weight\": 2934,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.series.baseLocation.url\",\
		\"weight\": 2935,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.series.instance\",\
		\"weight\": 2936,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.instance.id\",\
		\"weight\": 2937,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.instance.extension\",\
		\"weight\": 2938,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingManifest.study.series.instance.modifierExtension\",\
		\"weight\": 2939,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.series.instance.sopClass\",\
		\"weight\": 2940,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingManifest.study.series.instance.uid\",\
		\"weight\": 2941,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy\",\
		\"weight\": 2942,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.id\",\
		\"weight\": 2943,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.meta\",\
		\"weight\": 2944,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.implicitRules\",\
		\"weight\": 2945,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.language\",\
		\"weight\": 2946,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.text\",\
		\"weight\": 2947,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.contained\",\
		\"weight\": 2948,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.extension\",\
		\"weight\": 2949,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.modifierExtension\",\
		\"weight\": 2950,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.uid\",\
		\"weight\": 2951,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.accession\",\
		\"weight\": 2952,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.identifier\",\
		\"weight\": 2953,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.availability\",\
		\"weight\": 2954,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.modalityList\",\
		\"weight\": 2955,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.patient\",\
		\"weight\": 2956,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.context\",\
		\"weight\": 2957,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.started\",\
		\"weight\": 2958,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.basedOn\",\
		\"weight\": 2959,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.referrer\",\
		\"weight\": 2960,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.interpreter\",\
		\"weight\": 2961,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.baseLocation\",\
		\"weight\": 2962,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.baseLocation.id\",\
		\"weight\": 2963,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.baseLocation.extension\",\
		\"weight\": 2964,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.baseLocation.modifierExtension\",\
		\"weight\": 2965,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.baseLocation.type\",\
		\"weight\": 2966,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.baseLocation.url\",\
		\"weight\": 2967,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.numberOfSeries\",\
		\"weight\": 2968,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.numberOfInstances\",\
		\"weight\": 2969,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.procedure\",\
		\"weight\": 2970,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.reason\",\
		\"weight\": 2971,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.description\",\
		\"weight\": 2972,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series\",\
		\"weight\": 2973,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.id\",\
		\"weight\": 2974,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.extension\",\
		\"weight\": 2975,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.modifierExtension\",\
		\"weight\": 2976,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.series.uid\",\
		\"weight\": 2977,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.number\",\
		\"weight\": 2978,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.series.modality\",\
		\"weight\": 2979,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.description\",\
		\"weight\": 2980,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.series.numberOfInstances\",\
		\"weight\": 2981,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.availability\",\
		\"weight\": 2982,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.baseLocation\",\
		\"weight\": 2983,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.baseLocation.id\",\
		\"weight\": 2984,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.baseLocation.extension\",\
		\"weight\": 2985,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.baseLocation.modifierExtension\",\
		\"weight\": 2986,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.series.baseLocation.type\",\
		\"weight\": 2987,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.series.baseLocation.url\",\
		\"weight\": 2988,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.bodySite\",\
		\"weight\": 2989,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.laterality\",\
		\"weight\": 2990,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.started\",\
		\"weight\": 2991,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.instance\",\
		\"weight\": 2992,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.instance.id\",\
		\"weight\": 2993,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.instance.extension\",\
		\"weight\": 2994,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.instance.modifierExtension\",\
		\"weight\": 2995,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.series.instance.uid\",\
		\"weight\": 2996,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.instance.number\",\
		\"weight\": 2997,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImagingStudy.series.instance.sopClass\",\
		\"weight\": 2998,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImagingStudy.series.instance.title\",\
		\"weight\": 2999,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization\",\
		\"weight\": 3000,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.id\",\
		\"weight\": 3001,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.meta\",\
		\"weight\": 3002,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.implicitRules\",\
		\"weight\": 3003,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.language\",\
		\"weight\": 3004,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.text\",\
		\"weight\": 3005,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.contained\",\
		\"weight\": 3006,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.extension\",\
		\"weight\": 3007,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.modifierExtension\",\
		\"weight\": 3008,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.identifier\",\
		\"weight\": 3009,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Immunization.status\",\
		\"weight\": 3010,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.date\",\
		\"weight\": 3011,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Immunization.vaccineCode\",\
		\"weight\": 3012,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Immunization.patient\",\
		\"weight\": 3013,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Immunization.wasNotGiven\",\
		\"weight\": 3014,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Immunization.reported\",\
		\"weight\": 3015,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.performer\",\
		\"weight\": 3016,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.requester\",\
		\"weight\": 3017,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.encounter\",\
		\"weight\": 3018,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.manufacturer\",\
		\"weight\": 3019,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.location\",\
		\"weight\": 3020,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.lotNumber\",\
		\"weight\": 3021,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.expirationDate\",\
		\"weight\": 3022,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.site\",\
		\"weight\": 3023,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.route\",\
		\"weight\": 3024,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.doseQuantity\",\
		\"weight\": 3025,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.note\",\
		\"weight\": 3026,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.explanation\",\
		\"weight\": 3027,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.explanation.id\",\
		\"weight\": 3028,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.explanation.extension\",\
		\"weight\": 3029,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.explanation.modifierExtension\",\
		\"weight\": 3030,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.explanation.reason\",\
		\"weight\": 3031,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.explanation.reasonNotGiven\",\
		\"weight\": 3032,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.reaction\",\
		\"weight\": 3033,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.reaction.id\",\
		\"weight\": 3034,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.reaction.extension\",\
		\"weight\": 3035,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.reaction.modifierExtension\",\
		\"weight\": 3036,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.reaction.date\",\
		\"weight\": 3037,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.reaction.detail\",\
		\"weight\": 3038,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.reaction.reported\",\
		\"weight\": 3039,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol\",\
		\"weight\": 3040,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.id\",\
		\"weight\": 3041,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.extension\",\
		\"weight\": 3042,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.modifierExtension\",\
		\"weight\": 3043,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.doseSequence\",\
		\"weight\": 3044,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.description\",\
		\"weight\": 3045,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.authority\",\
		\"weight\": 3046,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.series\",\
		\"weight\": 3047,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.seriesDoses\",\
		\"weight\": 3048,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Immunization.vaccinationProtocol.targetDisease\",\
		\"weight\": 3049,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Immunization.vaccinationProtocol.doseStatus\",\
		\"weight\": 3050,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Immunization.vaccinationProtocol.doseStatusReason\",\
		\"weight\": 3051,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation\",\
		\"weight\": 3052,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.id\",\
		\"weight\": 3053,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.meta\",\
		\"weight\": 3054,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.implicitRules\",\
		\"weight\": 3055,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.language\",\
		\"weight\": 3056,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.text\",\
		\"weight\": 3057,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.contained\",\
		\"weight\": 3058,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.extension\",\
		\"weight\": 3059,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.modifierExtension\",\
		\"weight\": 3060,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.identifier\",\
		\"weight\": 3061,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImmunizationRecommendation.patient\",\
		\"weight\": 3062,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImmunizationRecommendation.recommendation\",\
		\"weight\": 3063,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.id\",\
		\"weight\": 3064,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.extension\",\
		\"weight\": 3065,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.modifierExtension\",\
		\"weight\": 3066,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImmunizationRecommendation.recommendation.date\",\
		\"weight\": 3067,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImmunizationRecommendation.recommendation.vaccineCode\",\
		\"weight\": 3068,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.doseNumber\",\
		\"weight\": 3069,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImmunizationRecommendation.recommendation.forecastStatus\",\
		\"weight\": 3070,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion\",\
		\"weight\": 3071,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.id\",\
		\"weight\": 3072,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.extension\",\
		\"weight\": 3073,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.modifierExtension\",\
		\"weight\": 3074,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.code\",\
		\"weight\": 3075,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.value\",\
		\"weight\": 3076,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol\",\
		\"weight\": 3077,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.id\",\
		\"weight\": 3078,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.extension\",\
		\"weight\": 3079,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.modifierExtension\",\
		\"weight\": 3080,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.doseSequence\",\
		\"weight\": 3081,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.description\",\
		\"weight\": 3082,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.authority\",\
		\"weight\": 3083,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.series\",\
		\"weight\": 3084,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingImmunization\",\
		\"weight\": 3085,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingPatientInformation\",\
		\"weight\": 3086,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide\",\
		\"weight\": 3087,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.id\",\
		\"weight\": 3088,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.meta\",\
		\"weight\": 3089,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.implicitRules\",\
		\"weight\": 3090,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.language\",\
		\"weight\": 3091,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.text\",\
		\"weight\": 3092,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.contained\",\
		\"weight\": 3093,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.extension\",\
		\"weight\": 3094,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.modifierExtension\",\
		\"weight\": 3095,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.url\",\
		\"weight\": 3096,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.version\",\
		\"weight\": 3097,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.name\",\
		\"weight\": 3098,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.status\",\
		\"weight\": 3099,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.experimental\",\
		\"weight\": 3100,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.publisher\",\
		\"weight\": 3101,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.contact\",\
		\"weight\": 3102,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.contact.id\",\
		\"weight\": 3103,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.contact.extension\",\
		\"weight\": 3104,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.contact.modifierExtension\",\
		\"weight\": 3105,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.contact.name\",\
		\"weight\": 3106,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.contact.telecom\",\
		\"weight\": 3107,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.date\",\
		\"weight\": 3108,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.description\",\
		\"weight\": 3109,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.useContext\",\
		\"weight\": 3110,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.copyright\",\
		\"weight\": 3111,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.fhirVersion\",\
		\"weight\": 3112,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.dependency\",\
		\"weight\": 3113,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.dependency.id\",\
		\"weight\": 3114,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.dependency.extension\",\
		\"weight\": 3115,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.dependency.modifierExtension\",\
		\"weight\": 3116,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.dependency.type\",\
		\"weight\": 3117,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.dependency.uri\",\
		\"weight\": 3118,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package\",\
		\"weight\": 3119,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.id\",\
		\"weight\": 3120,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.extension\",\
		\"weight\": 3121,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.modifierExtension\",\
		\"weight\": 3122,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.package.name\",\
		\"weight\": 3123,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.description\",\
		\"weight\": 3124,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.package.resource\",\
		\"weight\": 3125,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.resource.id\",\
		\"weight\": 3126,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.resource.extension\",\
		\"weight\": 3127,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.resource.modifierExtension\",\
		\"weight\": 3128,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.package.resource.example\",\
		\"weight\": 3129,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.resource.name\",\
		\"weight\": 3130,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.resource.description\",\
		\"weight\": 3131,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.resource.acronym\",\
		\"weight\": 3132,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.package.resource.sourceUri\",\
		\"weight\": 3133,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.package.resource.sourceReference\",\
		\"weight\": 3133,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.package.resource.exampleFor\",\
		\"weight\": 3134,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.global\",\
		\"weight\": 3135,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.global.id\",\
		\"weight\": 3136,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.global.extension\",\
		\"weight\": 3137,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.global.modifierExtension\",\
		\"weight\": 3138,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.global.type\",\
		\"weight\": 3139,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.global.profile\",\
		\"weight\": 3140,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.binary\",\
		\"weight\": 3141,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.page\",\
		\"weight\": 3142,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.page.id\",\
		\"weight\": 3143,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.page.extension\",\
		\"weight\": 3144,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.page.modifierExtension\",\
		\"weight\": 3145,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.page.source\",\
		\"weight\": 3146,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.page.title\",\
		\"weight\": 3147,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ImplementationGuide.page.kind\",\
		\"weight\": 3148,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.page.type\",\
		\"weight\": 3149,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.page.package\",\
		\"weight\": 3150,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.page.format\",\
		\"weight\": 3151,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ImplementationGuide.page.page\",\
		\"weight\": 3152,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library\",\
		\"weight\": 3153,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.id\",\
		\"weight\": 3154,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.meta\",\
		\"weight\": 3155,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.implicitRules\",\
		\"weight\": 3156,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.language\",\
		\"weight\": 3157,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.text\",\
		\"weight\": 3158,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.contained\",\
		\"weight\": 3159,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.extension\",\
		\"weight\": 3160,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.modifierExtension\",\
		\"weight\": 3161,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.url\",\
		\"weight\": 3162,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.identifier\",\
		\"weight\": 3163,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.version\",\
		\"weight\": 3164,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.name\",\
		\"weight\": 3165,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.title\",\
		\"weight\": 3166,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Library.type\",\
		\"weight\": 3167,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Library.status\",\
		\"weight\": 3168,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.experimental\",\
		\"weight\": 3169,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.description\",\
		\"weight\": 3170,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.purpose\",\
		\"weight\": 3171,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.usage\",\
		\"weight\": 3172,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.publicationDate\",\
		\"weight\": 3173,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.lastReviewDate\",\
		\"weight\": 3174,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.effectivePeriod\",\
		\"weight\": 3175,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.coverage\",\
		\"weight\": 3176,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.topic\",\
		\"weight\": 3177,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.contributor\",\
		\"weight\": 3178,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.publisher\",\
		\"weight\": 3179,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.contact\",\
		\"weight\": 3180,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.copyright\",\
		\"weight\": 3181,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.relatedResource\",\
		\"weight\": 3182,\
		\"max\": \"*\",\
		\"type\": \"RelatedResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.parameter\",\
		\"weight\": 3183,\
		\"max\": \"*\",\
		\"type\": \"ParameterDefinition\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Library.dataRequirement\",\
		\"weight\": 3184,\
		\"max\": \"*\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Library.content\",\
		\"weight\": 3185,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage\",\
		\"weight\": 3186,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.id\",\
		\"weight\": 3187,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.meta\",\
		\"weight\": 3188,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.implicitRules\",\
		\"weight\": 3189,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.language\",\
		\"weight\": 3190,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.text\",\
		\"weight\": 3191,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.contained\",\
		\"weight\": 3192,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.extension\",\
		\"weight\": 3193,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.modifierExtension\",\
		\"weight\": 3194,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.author\",\
		\"weight\": 3195,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Linkage.item\",\
		\"weight\": 3196,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.item.id\",\
		\"weight\": 3197,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.item.extension\",\
		\"weight\": 3198,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Linkage.item.modifierExtension\",\
		\"weight\": 3199,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Linkage.item.type\",\
		\"weight\": 3200,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Linkage.item.resource\",\
		\"weight\": 3201,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List\",\
		\"weight\": 3202,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.id\",\
		\"weight\": 3203,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.meta\",\
		\"weight\": 3204,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.implicitRules\",\
		\"weight\": 3205,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.language\",\
		\"weight\": 3206,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.text\",\
		\"weight\": 3207,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.contained\",\
		\"weight\": 3208,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.extension\",\
		\"weight\": 3209,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.modifierExtension\",\
		\"weight\": 3210,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.identifier\",\
		\"weight\": 3211,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"List.status\",\
		\"weight\": 3212,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"List.mode\",\
		\"weight\": 3213,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.title\",\
		\"weight\": 3214,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.code\",\
		\"weight\": 3215,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.subject\",\
		\"weight\": 3216,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.encounter\",\
		\"weight\": 3217,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.date\",\
		\"weight\": 3218,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.source\",\
		\"weight\": 3219,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.orderedBy\",\
		\"weight\": 3220,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.note\",\
		\"weight\": 3221,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.entry\",\
		\"weight\": 3222,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.entry.id\",\
		\"weight\": 3223,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.entry.extension\",\
		\"weight\": 3224,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.entry.modifierExtension\",\
		\"weight\": 3225,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.entry.flag\",\
		\"weight\": 3226,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.entry.deleted\",\
		\"weight\": 3227,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.entry.date\",\
		\"weight\": 3228,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"List.entry.item\",\
		\"weight\": 3229,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"List.emptyReason\",\
		\"weight\": 3230,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location\",\
		\"weight\": 3231,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.id\",\
		\"weight\": 3232,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.meta\",\
		\"weight\": 3233,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.implicitRules\",\
		\"weight\": 3234,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.language\",\
		\"weight\": 3235,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.text\",\
		\"weight\": 3236,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.contained\",\
		\"weight\": 3237,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.extension\",\
		\"weight\": 3238,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.modifierExtension\",\
		\"weight\": 3239,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.identifier\",\
		\"weight\": 3240,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.status\",\
		\"weight\": 3241,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.name\",\
		\"weight\": 3242,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.alias\",\
		\"weight\": 3243,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.description\",\
		\"weight\": 3244,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.mode\",\
		\"weight\": 3245,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.type\",\
		\"weight\": 3246,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.telecom\",\
		\"weight\": 3247,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.address\",\
		\"weight\": 3248,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.physicalType\",\
		\"weight\": 3249,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.position\",\
		\"weight\": 3250,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.position.id\",\
		\"weight\": 3251,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.position.extension\",\
		\"weight\": 3252,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.position.modifierExtension\",\
		\"weight\": 3253,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Location.position.longitude\",\
		\"weight\": 3254,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Location.position.latitude\",\
		\"weight\": 3255,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.position.altitude\",\
		\"weight\": 3256,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.managingOrganization\",\
		\"weight\": 3257,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.partOf\",\
		\"weight\": 3258,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Location.endpoint\",\
		\"weight\": 3259,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure\",\
		\"weight\": 3260,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.id\",\
		\"weight\": 3261,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.meta\",\
		\"weight\": 3262,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.implicitRules\",\
		\"weight\": 3263,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.language\",\
		\"weight\": 3264,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.text\",\
		\"weight\": 3265,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.contained\",\
		\"weight\": 3266,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.extension\",\
		\"weight\": 3267,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.modifierExtension\",\
		\"weight\": 3268,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.url\",\
		\"weight\": 3269,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.identifier\",\
		\"weight\": 3270,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.version\",\
		\"weight\": 3271,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.name\",\
		\"weight\": 3272,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.title\",\
		\"weight\": 3273,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Measure.status\",\
		\"weight\": 3274,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.experimental\",\
		\"weight\": 3275,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.description\",\
		\"weight\": 3276,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.purpose\",\
		\"weight\": 3277,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.usage\",\
		\"weight\": 3278,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.publicationDate\",\
		\"weight\": 3279,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.lastReviewDate\",\
		\"weight\": 3280,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.effectivePeriod\",\
		\"weight\": 3281,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.coverage\",\
		\"weight\": 3282,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.topic\",\
		\"weight\": 3283,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.contributor\",\
		\"weight\": 3284,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.publisher\",\
		\"weight\": 3285,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.contact\",\
		\"weight\": 3286,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.copyright\",\
		\"weight\": 3287,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.relatedResource\",\
		\"weight\": 3288,\
		\"max\": \"*\",\
		\"type\": \"RelatedResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.library\",\
		\"weight\": 3289,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.disclaimer\",\
		\"weight\": 3290,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.scoring\",\
		\"weight\": 3291,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.type\",\
		\"weight\": 3292,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.riskAdjustment\",\
		\"weight\": 3293,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.rateAggregation\",\
		\"weight\": 3294,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.rationale\",\
		\"weight\": 3295,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.clinicalRecommendationStatement\",\
		\"weight\": 3296,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.improvementNotation\",\
		\"weight\": 3297,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.definition\",\
		\"weight\": 3298,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.guidance\",\
		\"weight\": 3299,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.set\",\
		\"weight\": 3300,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group\",\
		\"weight\": 3301,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.id\",\
		\"weight\": 3302,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.extension\",\
		\"weight\": 3303,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.modifierExtension\",\
		\"weight\": 3304,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Measure.group.identifier\",\
		\"weight\": 3305,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.name\",\
		\"weight\": 3306,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.description\",\
		\"weight\": 3307,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.population\",\
		\"weight\": 3308,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.population.id\",\
		\"weight\": 3309,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.population.extension\",\
		\"weight\": 3310,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.population.modifierExtension\",\
		\"weight\": 3311,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Measure.group.population.type\",\
		\"weight\": 3312,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Measure.group.population.identifier\",\
		\"weight\": 3313,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.population.name\",\
		\"weight\": 3314,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.population.description\",\
		\"weight\": 3315,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Measure.group.population.criteria\",\
		\"weight\": 3316,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.stratifier\",\
		\"weight\": 3317,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.stratifier.id\",\
		\"weight\": 3318,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.stratifier.extension\",\
		\"weight\": 3319,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.stratifier.modifierExtension\",\
		\"weight\": 3320,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Measure.group.stratifier.identifier\",\
		\"weight\": 3321,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.stratifier.criteria\",\
		\"weight\": 3322,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.group.stratifier.path\",\
		\"weight\": 3323,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.supplementalData\",\
		\"weight\": 3324,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.supplementalData.id\",\
		\"weight\": 3325,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.supplementalData.extension\",\
		\"weight\": 3326,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.supplementalData.modifierExtension\",\
		\"weight\": 3327,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Measure.supplementalData.identifier\",\
		\"weight\": 3328,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.supplementalData.usage\",\
		\"weight\": 3329,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.supplementalData.criteria\",\
		\"weight\": 3330,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Measure.supplementalData.path\",\
		\"weight\": 3331,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport\",\
		\"weight\": 3332,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.id\",\
		\"weight\": 3333,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.meta\",\
		\"weight\": 3334,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.implicitRules\",\
		\"weight\": 3335,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.language\",\
		\"weight\": 3336,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.text\",\
		\"weight\": 3337,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.contained\",\
		\"weight\": 3338,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.extension\",\
		\"weight\": 3339,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.modifierExtension\",\
		\"weight\": 3340,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.measure\",\
		\"weight\": 3341,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.type\",\
		\"weight\": 3342,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.patient\",\
		\"weight\": 3343,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.period\",\
		\"weight\": 3344,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.status\",\
		\"weight\": 3345,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.date\",\
		\"weight\": 3346,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.reportingOrganization\",\
		\"weight\": 3347,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group\",\
		\"weight\": 3348,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.id\",\
		\"weight\": 3349,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.extension\",\
		\"weight\": 3350,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.modifierExtension\",\
		\"weight\": 3351,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.group.identifier\",\
		\"weight\": 3352,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.population\",\
		\"weight\": 3353,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.population.id\",\
		\"weight\": 3354,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.population.extension\",\
		\"weight\": 3355,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.population.modifierExtension\",\
		\"weight\": 3356,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.group.population.type\",\
		\"weight\": 3357,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.population.count\",\
		\"weight\": 3358,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.population.patients\",\
		\"weight\": 3359,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.measureScore\",\
		\"weight\": 3360,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier\",\
		\"weight\": 3361,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.id\",\
		\"weight\": 3362,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.extension\",\
		\"weight\": 3363,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.modifierExtension\",\
		\"weight\": 3364,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.group.stratifier.identifier\",\
		\"weight\": 3365,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group\",\
		\"weight\": 3366,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.id\",\
		\"weight\": 3367,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.extension\",\
		\"weight\": 3368,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.modifierExtension\",\
		\"weight\": 3369,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.group.stratifier.group.value\",\
		\"weight\": 3370,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.population\",\
		\"weight\": 3371,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.population.id\",\
		\"weight\": 3372,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.population.extension\",\
		\"weight\": 3373,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.population.modifierExtension\",\
		\"weight\": 3374,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.group.stratifier.group.population.type\",\
		\"weight\": 3375,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.population.count\",\
		\"weight\": 3376,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.population.patients\",\
		\"weight\": 3377,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.stratifier.group.measureScore\",\
		\"weight\": 3378,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData\",\
		\"weight\": 3379,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.id\",\
		\"weight\": 3380,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.extension\",\
		\"weight\": 3381,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.modifierExtension\",\
		\"weight\": 3382,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.group.supplementalData.identifier\",\
		\"weight\": 3383,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.group\",\
		\"weight\": 3384,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.group.id\",\
		\"weight\": 3385,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.group.extension\",\
		\"weight\": 3386,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.group.modifierExtension\",\
		\"weight\": 3387,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MeasureReport.group.supplementalData.group.value\",\
		\"weight\": 3388,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.group.count\",\
		\"weight\": 3389,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.group.supplementalData.group.patients\",\
		\"weight\": 3390,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MeasureReport.evaluatedResources\",\
		\"weight\": 3391,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media\",\
		\"weight\": 3392,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.id\",\
		\"weight\": 3393,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.meta\",\
		\"weight\": 3394,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.implicitRules\",\
		\"weight\": 3395,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.language\",\
		\"weight\": 3396,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.text\",\
		\"weight\": 3397,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.contained\",\
		\"weight\": 3398,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.extension\",\
		\"weight\": 3399,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.modifierExtension\",\
		\"weight\": 3400,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.identifier\",\
		\"weight\": 3401,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Media.type\",\
		\"weight\": 3402,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.subtype\",\
		\"weight\": 3403,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.view\",\
		\"weight\": 3404,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.subject\",\
		\"weight\": 3405,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.operator\",\
		\"weight\": 3406,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.deviceName\",\
		\"weight\": 3407,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.height\",\
		\"weight\": 3408,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.width\",\
		\"weight\": 3409,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.frames\",\
		\"weight\": 3410,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Media.duration\",\
		\"weight\": 3411,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Media.content\",\
		\"weight\": 3412,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication\",\
		\"weight\": 3413,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.id\",\
		\"weight\": 3414,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.meta\",\
		\"weight\": 3415,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.implicitRules\",\
		\"weight\": 3416,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.language\",\
		\"weight\": 3417,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.text\",\
		\"weight\": 3418,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.contained\",\
		\"weight\": 3419,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.extension\",\
		\"weight\": 3420,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.modifierExtension\",\
		\"weight\": 3421,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.code\",\
		\"weight\": 3422,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.isBrand\",\
		\"weight\": 3423,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.manufacturer\",\
		\"weight\": 3424,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product\",\
		\"weight\": 3425,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.id\",\
		\"weight\": 3426,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.extension\",\
		\"weight\": 3427,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.modifierExtension\",\
		\"weight\": 3428,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.form\",\
		\"weight\": 3429,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.ingredient\",\
		\"weight\": 3430,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.ingredient.id\",\
		\"weight\": 3431,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.ingredient.extension\",\
		\"weight\": 3432,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.ingredient.modifierExtension\",\
		\"weight\": 3433,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Medication.product.ingredient.itemCodeableConcept\",\
		\"weight\": 3434,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Medication.product.ingredient.itemReference\",\
		\"weight\": 3434,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Medication.product.ingredient.itemReference\",\
		\"weight\": 3434,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.ingredient.amount\",\
		\"weight\": 3435,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.batch\",\
		\"weight\": 3436,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.batch.id\",\
		\"weight\": 3437,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.batch.extension\",\
		\"weight\": 3438,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.batch.modifierExtension\",\
		\"weight\": 3439,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.batch.lotNumber\",\
		\"weight\": 3440,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.product.batch.expirationDate\",\
		\"weight\": 3441,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package\",\
		\"weight\": 3442,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.id\",\
		\"weight\": 3443,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.extension\",\
		\"weight\": 3444,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.modifierExtension\",\
		\"weight\": 3445,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.container\",\
		\"weight\": 3446,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.content\",\
		\"weight\": 3447,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.content.id\",\
		\"weight\": 3448,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.content.extension\",\
		\"weight\": 3449,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.content.modifierExtension\",\
		\"weight\": 3450,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Medication.package.content.itemCodeableConcept\",\
		\"weight\": 3451,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Medication.package.content.itemReference\",\
		\"weight\": 3451,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Medication.package.content.amount\",\
		\"weight\": 3452,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration\",\
		\"weight\": 3453,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.id\",\
		\"weight\": 3454,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.meta\",\
		\"weight\": 3455,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.implicitRules\",\
		\"weight\": 3456,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.language\",\
		\"weight\": 3457,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.text\",\
		\"weight\": 3458,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.contained\",\
		\"weight\": 3459,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.extension\",\
		\"weight\": 3460,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.modifierExtension\",\
		\"weight\": 3461,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.identifier\",\
		\"weight\": 3462,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationAdministration.status\",\
		\"weight\": 3463,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationAdministration.medicationCodeableConcept\",\
		\"weight\": 3464,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationAdministration.medicationReference\",\
		\"weight\": 3464,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationAdministration.patient\",\
		\"weight\": 3465,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.encounter\",\
		\"weight\": 3466,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationAdministration.effectiveTimeDateTime\",\
		\"weight\": 3467,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationAdministration.effectiveTimePeriod\",\
		\"weight\": 3467,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.performer\",\
		\"weight\": 3468,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.prescription\",\
		\"weight\": 3469,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.wasNotGiven\",\
		\"weight\": 3470,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.reasonNotGiven\",\
		\"weight\": 3471,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.reasonGiven\",\
		\"weight\": 3472,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.device\",\
		\"weight\": 3473,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.note\",\
		\"weight\": 3474,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage\",\
		\"weight\": 3475,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.id\",\
		\"weight\": 3476,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.extension\",\
		\"weight\": 3477,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.modifierExtension\",\
		\"weight\": 3478,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.text\",\
		\"weight\": 3479,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.siteCodeableConcept\",\
		\"weight\": 3480,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.siteReference\",\
		\"weight\": 3480,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.route\",\
		\"weight\": 3481,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.method\",\
		\"weight\": 3482,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.dose\",\
		\"weight\": 3483,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.rateRatio\",\
		\"weight\": 3484,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.dosage.rateQuantity\",\
		\"weight\": 3484,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.eventHistory\",\
		\"weight\": 3485,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.eventHistory.id\",\
		\"weight\": 3486,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.eventHistory.extension\",\
		\"weight\": 3487,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.eventHistory.modifierExtension\",\
		\"weight\": 3488,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationAdministration.eventHistory.status\",\
		\"weight\": 3489,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.eventHistory.action\",\
		\"weight\": 3490,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationAdministration.eventHistory.dateTime\",\
		\"weight\": 3491,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.eventHistory.actor\",\
		\"weight\": 3492,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationAdministration.eventHistory.reason\",\
		\"weight\": 3493,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense\",\
		\"weight\": 3494,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.id\",\
		\"weight\": 3495,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.meta\",\
		\"weight\": 3496,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.implicitRules\",\
		\"weight\": 3497,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.language\",\
		\"weight\": 3498,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.text\",\
		\"weight\": 3499,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.contained\",\
		\"weight\": 3500,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.extension\",\
		\"weight\": 3501,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.modifierExtension\",\
		\"weight\": 3502,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.identifier\",\
		\"weight\": 3503,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.status\",\
		\"weight\": 3504,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationDispense.medicationCodeableConcept\",\
		\"weight\": 3505,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationDispense.medicationReference\",\
		\"weight\": 3505,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.patient\",\
		\"weight\": 3506,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dispenser\",\
		\"weight\": 3507,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dispensingOrganization\",\
		\"weight\": 3508,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.authorizingPrescription\",\
		\"weight\": 3509,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.type\",\
		\"weight\": 3510,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.quantity\",\
		\"weight\": 3511,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.daysSupply\",\
		\"weight\": 3512,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.whenPrepared\",\
		\"weight\": 3513,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.whenHandedOver\",\
		\"weight\": 3514,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.destination\",\
		\"weight\": 3515,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.receiver\",\
		\"weight\": 3516,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.note\",\
		\"weight\": 3517,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction\",\
		\"weight\": 3518,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.id\",\
		\"weight\": 3519,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.extension\",\
		\"weight\": 3520,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.modifierExtension\",\
		\"weight\": 3521,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.text\",\
		\"weight\": 3522,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.additionalInstructions\",\
		\"weight\": 3523,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.timing\",\
		\"weight\": 3524,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.asNeededBoolean\",\
		\"weight\": 3525,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.asNeededCodeableConcept\",\
		\"weight\": 3525,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.siteCodeableConcept\",\
		\"weight\": 3526,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.siteReference\",\
		\"weight\": 3526,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.route\",\
		\"weight\": 3527,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.method\",\
		\"weight\": 3528,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.doseRange\",\
		\"weight\": 3529,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.doseQuantity\",\
		\"weight\": 3529,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.rateRatio\",\
		\"weight\": 3530,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.rateRange\",\
		\"weight\": 3530,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.rateQuantity\",\
		\"weight\": 3530,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.dosageInstruction.maxDosePerPeriod\",\
		\"weight\": 3531,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.substitution\",\
		\"weight\": 3532,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.substitution.id\",\
		\"weight\": 3533,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.substitution.extension\",\
		\"weight\": 3534,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.substitution.modifierExtension\",\
		\"weight\": 3535,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationDispense.substitution.type\",\
		\"weight\": 3536,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.substitution.reason\",\
		\"weight\": 3537,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.substitution.responsibleParty\",\
		\"weight\": 3538,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.eventHistory\",\
		\"weight\": 3539,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.eventHistory.id\",\
		\"weight\": 3540,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.eventHistory.extension\",\
		\"weight\": 3541,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.eventHistory.modifierExtension\",\
		\"weight\": 3542,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationDispense.eventHistory.status\",\
		\"weight\": 3543,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.eventHistory.action\",\
		\"weight\": 3544,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationDispense.eventHistory.dateTime\",\
		\"weight\": 3545,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.eventHistory.actor\",\
		\"weight\": 3546,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationDispense.eventHistory.reason\",\
		\"weight\": 3547,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder\",\
		\"weight\": 3548,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.id\",\
		\"weight\": 3549,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.meta\",\
		\"weight\": 3550,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.implicitRules\",\
		\"weight\": 3551,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.language\",\
		\"weight\": 3552,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.text\",\
		\"weight\": 3553,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.contained\",\
		\"weight\": 3554,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.extension\",\
		\"weight\": 3555,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.modifierExtension\",\
		\"weight\": 3556,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.identifier\",\
		\"weight\": 3557,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.status\",\
		\"weight\": 3558,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationOrder.medicationCodeableConcept\",\
		\"weight\": 3559,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationOrder.medicationReference\",\
		\"weight\": 3559,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.patient\",\
		\"weight\": 3560,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.encounter\",\
		\"weight\": 3561,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dateWritten\",\
		\"weight\": 3562,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.prescriber\",\
		\"weight\": 3563,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.reasonCode\",\
		\"weight\": 3564,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.reasonReference\",\
		\"weight\": 3565,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.note\",\
		\"weight\": 3566,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.category\",\
		\"weight\": 3567,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction\",\
		\"weight\": 3568,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.id\",\
		\"weight\": 3569,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.extension\",\
		\"weight\": 3570,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.modifierExtension\",\
		\"weight\": 3571,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.text\",\
		\"weight\": 3572,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.additionalInstructions\",\
		\"weight\": 3573,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.timing\",\
		\"weight\": 3574,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.asNeededBoolean\",\
		\"weight\": 3575,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.asNeededCodeableConcept\",\
		\"weight\": 3575,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.siteCodeableConcept\",\
		\"weight\": 3576,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.siteReference\",\
		\"weight\": 3576,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.route\",\
		\"weight\": 3577,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.method\",\
		\"weight\": 3578,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.doseRange\",\
		\"weight\": 3579,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.doseQuantity\",\
		\"weight\": 3579,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerPeriod\",\
		\"weight\": 3580,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerAdministration\",\
		\"weight\": 3581,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerLifetime\",\
		\"weight\": 3582,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.rateRatio\",\
		\"weight\": 3583,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.rateRange\",\
		\"weight\": 3583,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dosageInstruction.rateQuantity\",\
		\"weight\": 3583,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dispenseRequest\",\
		\"weight\": 3584,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dispenseRequest.id\",\
		\"weight\": 3585,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dispenseRequest.extension\",\
		\"weight\": 3586,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dispenseRequest.modifierExtension\",\
		\"weight\": 3587,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dispenseRequest.validityPeriod\",\
		\"weight\": 3588,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dispenseRequest.numberOfRepeatsAllowed\",\
		\"weight\": 3589,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dispenseRequest.quantity\",\
		\"weight\": 3590,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.dispenseRequest.expectedSupplyDuration\",\
		\"weight\": 3591,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.substitution\",\
		\"weight\": 3592,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.substitution.id\",\
		\"weight\": 3593,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.substitution.extension\",\
		\"weight\": 3594,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.substitution.modifierExtension\",\
		\"weight\": 3595,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationOrder.substitution.allowed\",\
		\"weight\": 3596,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.substitution.reason\",\
		\"weight\": 3597,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.priorPrescription\",\
		\"weight\": 3598,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.eventHistory\",\
		\"weight\": 3599,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.eventHistory.id\",\
		\"weight\": 3600,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.eventHistory.extension\",\
		\"weight\": 3601,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.eventHistory.modifierExtension\",\
		\"weight\": 3602,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationOrder.eventHistory.status\",\
		\"weight\": 3603,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.eventHistory.action\",\
		\"weight\": 3604,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationOrder.eventHistory.dateTime\",\
		\"weight\": 3605,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.eventHistory.actor\",\
		\"weight\": 3606,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationOrder.eventHistory.reason\",\
		\"weight\": 3607,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement\",\
		\"weight\": 3608,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.id\",\
		\"weight\": 3609,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.meta\",\
		\"weight\": 3610,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.implicitRules\",\
		\"weight\": 3611,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.language\",\
		\"weight\": 3612,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.text\",\
		\"weight\": 3613,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.contained\",\
		\"weight\": 3614,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.extension\",\
		\"weight\": 3615,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.modifierExtension\",\
		\"weight\": 3616,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.identifier\",\
		\"weight\": 3617,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationStatement.status\",\
		\"weight\": 3618,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationStatement.medicationCodeableConcept\",\
		\"weight\": 3619,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationStatement.medicationReference\",\
		\"weight\": 3619,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MedicationStatement.patient\",\
		\"weight\": 3620,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.effectiveDateTime\",\
		\"weight\": 3621,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.effectivePeriod\",\
		\"weight\": 3621,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.informationSource\",\
		\"weight\": 3622,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.supportingInformation\",\
		\"weight\": 3623,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dateAsserted\",\
		\"weight\": 3624,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.notTaken\",\
		\"weight\": 3625,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.reasonNotTaken\",\
		\"weight\": 3626,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.reasonForUseCode\",\
		\"weight\": 3627,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.reasonForUseReference\",\
		\"weight\": 3628,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.note\",\
		\"weight\": 3629,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.category\",\
		\"weight\": 3630,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage\",\
		\"weight\": 3631,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.id\",\
		\"weight\": 3632,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.extension\",\
		\"weight\": 3633,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.modifierExtension\",\
		\"weight\": 3634,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.text\",\
		\"weight\": 3635,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.additionalInstructions\",\
		\"weight\": 3636,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.timing\",\
		\"weight\": 3637,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.asNeededBoolean\",\
		\"weight\": 3638,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.asNeededCodeableConcept\",\
		\"weight\": 3638,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.siteCodeableConcept\",\
		\"weight\": 3639,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.siteReference\",\
		\"weight\": 3639,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.route\",\
		\"weight\": 3640,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.method\",\
		\"weight\": 3641,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.doseQuantity\",\
		\"weight\": 3642,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.doseRange\",\
		\"weight\": 3642,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.rateRatio\",\
		\"weight\": 3643,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.rateRange\",\
		\"weight\": 3643,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.rateQuantity\",\
		\"weight\": 3643,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MedicationStatement.dosage.maxDosePerPeriod\",\
		\"weight\": 3644,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader\",\
		\"weight\": 3645,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.id\",\
		\"weight\": 3646,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.meta\",\
		\"weight\": 3647,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.implicitRules\",\
		\"weight\": 3648,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.language\",\
		\"weight\": 3649,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.text\",\
		\"weight\": 3650,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.contained\",\
		\"weight\": 3651,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.extension\",\
		\"weight\": 3652,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.modifierExtension\",\
		\"weight\": 3653,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MessageHeader.timestamp\",\
		\"weight\": 3654,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MessageHeader.event\",\
		\"weight\": 3655,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.response\",\
		\"weight\": 3656,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.response.id\",\
		\"weight\": 3657,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.response.extension\",\
		\"weight\": 3658,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.response.modifierExtension\",\
		\"weight\": 3659,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MessageHeader.response.identifier\",\
		\"weight\": 3660,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MessageHeader.response.code\",\
		\"weight\": 3661,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.response.details\",\
		\"weight\": 3662,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MessageHeader.source\",\
		\"weight\": 3663,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.source.id\",\
		\"weight\": 3664,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.source.extension\",\
		\"weight\": 3665,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.source.modifierExtension\",\
		\"weight\": 3666,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.source.name\",\
		\"weight\": 3667,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.source.software\",\
		\"weight\": 3668,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.source.version\",\
		\"weight\": 3669,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.source.contact\",\
		\"weight\": 3670,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MessageHeader.source.endpoint\",\
		\"weight\": 3671,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.destination\",\
		\"weight\": 3672,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.destination.id\",\
		\"weight\": 3673,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.destination.extension\",\
		\"weight\": 3674,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.destination.modifierExtension\",\
		\"weight\": 3675,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.destination.name\",\
		\"weight\": 3676,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.destination.target\",\
		\"weight\": 3677,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"MessageHeader.destination.endpoint\",\
		\"weight\": 3678,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.enterer\",\
		\"weight\": 3679,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.author\",\
		\"weight\": 3680,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.receiver\",\
		\"weight\": 3681,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.responsible\",\
		\"weight\": 3682,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.reason\",\
		\"weight\": 3683,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"MessageHeader.data\",\
		\"weight\": 3684,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem\",\
		\"weight\": 3685,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.id\",\
		\"weight\": 3686,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.meta\",\
		\"weight\": 3687,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.implicitRules\",\
		\"weight\": 3688,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.language\",\
		\"weight\": 3689,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.text\",\
		\"weight\": 3690,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.contained\",\
		\"weight\": 3691,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.extension\",\
		\"weight\": 3692,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.modifierExtension\",\
		\"weight\": 3693,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NamingSystem.name\",\
		\"weight\": 3694,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NamingSystem.status\",\
		\"weight\": 3695,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NamingSystem.kind\",\
		\"weight\": 3696,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NamingSystem.date\",\
		\"weight\": 3697,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.publisher\",\
		\"weight\": 3698,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.contact\",\
		\"weight\": 3699,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.contact.id\",\
		\"weight\": 3700,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.contact.extension\",\
		\"weight\": 3701,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.contact.modifierExtension\",\
		\"weight\": 3702,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.contact.name\",\
		\"weight\": 3703,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.contact.telecom\",\
		\"weight\": 3704,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.responsible\",\
		\"weight\": 3705,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.type\",\
		\"weight\": 3706,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.description\",\
		\"weight\": 3707,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.useContext\",\
		\"weight\": 3708,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.usage\",\
		\"weight\": 3709,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NamingSystem.uniqueId\",\
		\"weight\": 3710,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.uniqueId.id\",\
		\"weight\": 3711,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.uniqueId.extension\",\
		\"weight\": 3712,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.uniqueId.modifierExtension\",\
		\"weight\": 3713,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NamingSystem.uniqueId.type\",\
		\"weight\": 3714,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NamingSystem.uniqueId.value\",\
		\"weight\": 3715,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.uniqueId.preferred\",\
		\"weight\": 3716,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.uniqueId.comment\",\
		\"weight\": 3717,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.uniqueId.period\",\
		\"weight\": 3718,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NamingSystem.replacedBy\",\
		\"weight\": 3719,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest\",\
		\"weight\": 3720,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.id\",\
		\"weight\": 3721,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.meta\",\
		\"weight\": 3722,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.implicitRules\",\
		\"weight\": 3723,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.language\",\
		\"weight\": 3724,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.text\",\
		\"weight\": 3725,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.contained\",\
		\"weight\": 3726,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.extension\",\
		\"weight\": 3727,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.modifierExtension\",\
		\"weight\": 3728,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.identifier\",\
		\"weight\": 3729,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.status\",\
		\"weight\": 3730,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NutritionRequest.patient\",\
		\"weight\": 3731,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.encounter\",\
		\"weight\": 3732,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"NutritionRequest.dateTime\",\
		\"weight\": 3733,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.orderer\",\
		\"weight\": 3734,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.allergyIntolerance\",\
		\"weight\": 3735,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.foodPreferenceModifier\",\
		\"weight\": 3736,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.excludeFoodModifier\",\
		\"weight\": 3737,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet\",\
		\"weight\": 3738,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.id\",\
		\"weight\": 3739,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.extension\",\
		\"weight\": 3740,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.modifierExtension\",\
		\"weight\": 3741,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.type\",\
		\"weight\": 3742,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.schedule\",\
		\"weight\": 3743,\
		\"max\": \"*\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.nutrient\",\
		\"weight\": 3744,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.nutrient.id\",\
		\"weight\": 3745,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.nutrient.extension\",\
		\"weight\": 3746,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.nutrient.modifierExtension\",\
		\"weight\": 3747,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.nutrient.modifier\",\
		\"weight\": 3748,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.nutrient.amount\",\
		\"weight\": 3749,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.texture\",\
		\"weight\": 3750,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.texture.id\",\
		\"weight\": 3751,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.texture.extension\",\
		\"weight\": 3752,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.texture.modifierExtension\",\
		\"weight\": 3753,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.texture.modifier\",\
		\"weight\": 3754,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.texture.foodType\",\
		\"weight\": 3755,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.fluidConsistencyType\",\
		\"weight\": 3756,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.oralDiet.instruction\",\
		\"weight\": 3757,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement\",\
		\"weight\": 3758,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement.id\",\
		\"weight\": 3759,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement.extension\",\
		\"weight\": 3760,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement.modifierExtension\",\
		\"weight\": 3761,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement.type\",\
		\"weight\": 3762,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement.productName\",\
		\"weight\": 3763,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement.schedule\",\
		\"weight\": 3764,\
		\"max\": \"*\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement.quantity\",\
		\"weight\": 3765,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.supplement.instruction\",\
		\"weight\": 3766,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula\",\
		\"weight\": 3767,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.id\",\
		\"weight\": 3768,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.extension\",\
		\"weight\": 3769,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.modifierExtension\",\
		\"weight\": 3770,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.baseFormulaType\",\
		\"weight\": 3771,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.baseFormulaProductName\",\
		\"weight\": 3772,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.additiveType\",\
		\"weight\": 3773,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.additiveProductName\",\
		\"weight\": 3774,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.caloricDensity\",\
		\"weight\": 3775,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.routeofAdministration\",\
		\"weight\": 3776,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administration\",\
		\"weight\": 3777,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administration.id\",\
		\"weight\": 3778,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administration.extension\",\
		\"weight\": 3779,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administration.modifierExtension\",\
		\"weight\": 3780,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administration.schedule\",\
		\"weight\": 3781,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administration.quantity\",\
		\"weight\": 3782,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administration.rateQuantity\",\
		\"weight\": 3783,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administration.rateRatio\",\
		\"weight\": 3783,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.maxVolumeToDeliver\",\
		\"weight\": 3784,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"NutritionRequest.enteralFormula.administrationInstruction\",\
		\"weight\": 3785,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation\",\
		\"weight\": 3786,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.id\",\
		\"weight\": 3787,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.meta\",\
		\"weight\": 3788,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.implicitRules\",\
		\"weight\": 3789,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.language\",\
		\"weight\": 3790,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.text\",\
		\"weight\": 3791,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.contained\",\
		\"weight\": 3792,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.extension\",\
		\"weight\": 3793,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.modifierExtension\",\
		\"weight\": 3794,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.identifier\",\
		\"weight\": 3795,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Observation.status\",\
		\"weight\": 3796,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.category\",\
		\"weight\": 3797,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Observation.code\",\
		\"weight\": 3798,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.subject\",\
		\"weight\": 3799,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.encounter\",\
		\"weight\": 3800,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.effectiveDateTime\",\
		\"weight\": 3801,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.effectivePeriod\",\
		\"weight\": 3801,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.issued\",\
		\"weight\": 3802,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.performer\",\
		\"weight\": 3803,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueQuantity\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueCodeableConcept\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueString\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueRange\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueRatio\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueSampledData\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueAttachment\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueTime\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valueDateTime\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.valuePeriod\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.dataAbsentReason\",\
		\"weight\": 3805,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.interpretation\",\
		\"weight\": 3806,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.comment\",\
		\"weight\": 3807,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.bodySite\",\
		\"weight\": 3808,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.method\",\
		\"weight\": 3809,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.specimen\",\
		\"weight\": 3810,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.device\",\
		\"weight\": 3811,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange\",\
		\"weight\": 3812,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange.id\",\
		\"weight\": 3813,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange.extension\",\
		\"weight\": 3814,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange.modifierExtension\",\
		\"weight\": 3815,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange.low\",\
		\"weight\": 3816,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange.high\",\
		\"weight\": 3817,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange.meaning\",\
		\"weight\": 3818,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange.age\",\
		\"weight\": 3819,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.referenceRange.text\",\
		\"weight\": 3820,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.related\",\
		\"weight\": 3821,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.related.id\",\
		\"weight\": 3822,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.related.extension\",\
		\"weight\": 3823,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.related.modifierExtension\",\
		\"weight\": 3824,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.related.type\",\
		\"weight\": 3825,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Observation.related.target\",\
		\"weight\": 3826,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component\",\
		\"weight\": 3827,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.id\",\
		\"weight\": 3828,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.extension\",\
		\"weight\": 3829,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.modifierExtension\",\
		\"weight\": 3830,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Observation.component.code\",\
		\"weight\": 3831,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueQuantity\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueCodeableConcept\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueString\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueRange\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueRatio\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueSampledData\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueAttachment\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueTime\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valueDateTime\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.valuePeriod\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.dataAbsentReason\",\
		\"weight\": 3833,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.interpretation\",\
		\"weight\": 3834,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Observation.component.referenceRange\",\
		\"weight\": 3835,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition\",\
		\"weight\": 3836,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.id\",\
		\"weight\": 3837,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.meta\",\
		\"weight\": 3838,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.implicitRules\",\
		\"weight\": 3839,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.language\",\
		\"weight\": 3840,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.text\",\
		\"weight\": 3841,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.contained\",\
		\"weight\": 3842,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.extension\",\
		\"weight\": 3843,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.modifierExtension\",\
		\"weight\": 3844,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.url\",\
		\"weight\": 3845,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.version\",\
		\"weight\": 3846,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.name\",\
		\"weight\": 3847,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.status\",\
		\"weight\": 3848,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.kind\",\
		\"weight\": 3849,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.experimental\",\
		\"weight\": 3850,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.date\",\
		\"weight\": 3851,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.publisher\",\
		\"weight\": 3852,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.contact\",\
		\"weight\": 3853,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.contact.id\",\
		\"weight\": 3854,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.contact.extension\",\
		\"weight\": 3855,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.contact.modifierExtension\",\
		\"weight\": 3856,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.contact.name\",\
		\"weight\": 3857,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.contact.telecom\",\
		\"weight\": 3858,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.description\",\
		\"weight\": 3859,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.useContext\",\
		\"weight\": 3860,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.requirements\",\
		\"weight\": 3861,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.idempotent\",\
		\"weight\": 3862,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.code\",\
		\"weight\": 3863,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.comment\",\
		\"weight\": 3864,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.base\",\
		\"weight\": 3865,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.system\",\
		\"weight\": 3866,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.type\",\
		\"weight\": 3867,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.instance\",\
		\"weight\": 3868,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter\",\
		\"weight\": 3869,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.id\",\
		\"weight\": 3870,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.extension\",\
		\"weight\": 3871,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.modifierExtension\",\
		\"weight\": 3872,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.parameter.name\",\
		\"weight\": 3873,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.parameter.use\",\
		\"weight\": 3874,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.parameter.min\",\
		\"weight\": 3875,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.parameter.max\",\
		\"weight\": 3876,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.documentation\",\
		\"weight\": 3877,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.type\",\
		\"weight\": 3878,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.searchType\",\
		\"weight\": 3879,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.profile\",\
		\"weight\": 3880,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.binding\",\
		\"weight\": 3881,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.binding.id\",\
		\"weight\": 3882,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.binding.extension\",\
		\"weight\": 3883,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.binding.modifierExtension\",\
		\"weight\": 3884,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.parameter.binding.strength\",\
		\"weight\": 3885,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.parameter.binding.valueSetUri\",\
		\"weight\": 3886,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationDefinition.parameter.binding.valueSetReference\",\
		\"weight\": 3886,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationDefinition.parameter.part\",\
		\"weight\": 3887,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome\",\
		\"weight\": 3888,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.id\",\
		\"weight\": 3889,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.meta\",\
		\"weight\": 3890,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.implicitRules\",\
		\"weight\": 3891,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.language\",\
		\"weight\": 3892,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.text\",\
		\"weight\": 3893,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.contained\",\
		\"weight\": 3894,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.extension\",\
		\"weight\": 3895,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.modifierExtension\",\
		\"weight\": 3896,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationOutcome.issue\",\
		\"weight\": 3897,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.issue.id\",\
		\"weight\": 3898,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.issue.extension\",\
		\"weight\": 3899,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.issue.modifierExtension\",\
		\"weight\": 3900,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationOutcome.issue.severity\",\
		\"weight\": 3901,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"OperationOutcome.issue.code\",\
		\"weight\": 3902,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.issue.details\",\
		\"weight\": 3903,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.issue.diagnostics\",\
		\"weight\": 3904,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.issue.location\",\
		\"weight\": 3905,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"OperationOutcome.issue.expression\",\
		\"weight\": 3906,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization\",\
		\"weight\": 3907,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.id\",\
		\"weight\": 3908,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.meta\",\
		\"weight\": 3909,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.implicitRules\",\
		\"weight\": 3910,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.language\",\
		\"weight\": 3911,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.text\",\
		\"weight\": 3912,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contained\",\
		\"weight\": 3913,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.extension\",\
		\"weight\": 3914,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.modifierExtension\",\
		\"weight\": 3915,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.identifier\",\
		\"weight\": 3916,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.active\",\
		\"weight\": 3917,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.type\",\
		\"weight\": 3918,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.name\",\
		\"weight\": 3919,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.alias\",\
		\"weight\": 3920,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.telecom\",\
		\"weight\": 3921,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.address\",\
		\"weight\": 3922,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.partOf\",\
		\"weight\": 3923,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contact\",\
		\"weight\": 3924,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contact.id\",\
		\"weight\": 3925,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contact.extension\",\
		\"weight\": 3926,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contact.modifierExtension\",\
		\"weight\": 3927,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contact.purpose\",\
		\"weight\": 3928,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contact.name\",\
		\"weight\": 3929,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contact.telecom\",\
		\"weight\": 3930,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.contact.address\",\
		\"weight\": 3931,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Organization.endpoint\",\
		\"weight\": 3932,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient\",\
		\"weight\": 3933,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.id\",\
		\"weight\": 3934,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.meta\",\
		\"weight\": 3935,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.implicitRules\",\
		\"weight\": 3936,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.language\",\
		\"weight\": 3937,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.text\",\
		\"weight\": 3938,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contained\",\
		\"weight\": 3939,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.extension\",\
		\"weight\": 3940,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.modifierExtension\",\
		\"weight\": 3941,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.identifier\",\
		\"weight\": 3942,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.active\",\
		\"weight\": 3943,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.name\",\
		\"weight\": 3944,\
		\"max\": \"*\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.telecom\",\
		\"weight\": 3945,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.gender\",\
		\"weight\": 3946,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.birthDate\",\
		\"weight\": 3947,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.deceasedBoolean\",\
		\"weight\": 3948,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.deceasedDateTime\",\
		\"weight\": 3948,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.address\",\
		\"weight\": 3949,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.maritalStatus\",\
		\"weight\": 3950,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.multipleBirthBoolean\",\
		\"weight\": 3951,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.multipleBirthInteger\",\
		\"weight\": 3951,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.photo\",\
		\"weight\": 3952,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact\",\
		\"weight\": 3953,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.id\",\
		\"weight\": 3954,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.extension\",\
		\"weight\": 3955,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.modifierExtension\",\
		\"weight\": 3956,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.relationship\",\
		\"weight\": 3957,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.name\",\
		\"weight\": 3958,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.telecom\",\
		\"weight\": 3959,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.address\",\
		\"weight\": 3960,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.gender\",\
		\"weight\": 3961,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.organization\",\
		\"weight\": 3962,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.contact.period\",\
		\"weight\": 3963,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.animal\",\
		\"weight\": 3964,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.animal.id\",\
		\"weight\": 3965,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.animal.extension\",\
		\"weight\": 3966,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.animal.modifierExtension\",\
		\"weight\": 3967,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Patient.animal.species\",\
		\"weight\": 3968,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.animal.breed\",\
		\"weight\": 3969,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.animal.genderStatus\",\
		\"weight\": 3970,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.communication\",\
		\"weight\": 3971,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.communication.id\",\
		\"weight\": 3972,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.communication.extension\",\
		\"weight\": 3973,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.communication.modifierExtension\",\
		\"weight\": 3974,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Patient.communication.language\",\
		\"weight\": 3975,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.communication.preferred\",\
		\"weight\": 3976,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.generalPractitioner\",\
		\"weight\": 3977,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.managingOrganization\",\
		\"weight\": 3978,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.link\",\
		\"weight\": 3979,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.link.id\",\
		\"weight\": 3980,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.link.extension\",\
		\"weight\": 3981,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Patient.link.modifierExtension\",\
		\"weight\": 3982,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Patient.link.other\",\
		\"weight\": 3983,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Patient.link.type\",\
		\"weight\": 3984,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice\",\
		\"weight\": 3985,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.id\",\
		\"weight\": 3986,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.meta\",\
		\"weight\": 3987,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.implicitRules\",\
		\"weight\": 3988,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.language\",\
		\"weight\": 3989,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.text\",\
		\"weight\": 3990,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.contained\",\
		\"weight\": 3991,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.extension\",\
		\"weight\": 3992,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.modifierExtension\",\
		\"weight\": 3993,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.identifier\",\
		\"weight\": 3994,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PaymentNotice.status\",\
		\"weight\": 3995,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.ruleset\",\
		\"weight\": 3996,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.originalRuleset\",\
		\"weight\": 3997,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.created\",\
		\"weight\": 3998,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.targetIdentifier\",\
		\"weight\": 3999,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.targetReference\",\
		\"weight\": 3999,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.providerIdentifier\",\
		\"weight\": 4000,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.providerReference\",\
		\"weight\": 4000,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.organizationIdentifier\",\
		\"weight\": 4001,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.organizationReference\",\
		\"weight\": 4001,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.requestIdentifier\",\
		\"weight\": 4002,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.requestReference\",\
		\"weight\": 4002,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.responseIdentifier\",\
		\"weight\": 4003,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.responseReference\",\
		\"weight\": 4003,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PaymentNotice.paymentStatus\",\
		\"weight\": 4004,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentNotice.statusDate\",\
		\"weight\": 4005,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation\",\
		\"weight\": 4006,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.id\",\
		\"weight\": 4007,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.meta\",\
		\"weight\": 4008,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.implicitRules\",\
		\"weight\": 4009,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.language\",\
		\"weight\": 4010,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.text\",\
		\"weight\": 4011,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.contained\",\
		\"weight\": 4012,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.extension\",\
		\"weight\": 4013,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.modifierExtension\",\
		\"weight\": 4014,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.identifier\",\
		\"weight\": 4015,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PaymentReconciliation.status\",\
		\"weight\": 4016,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.requestIdentifier\",\
		\"weight\": 4017,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.requestReference\",\
		\"weight\": 4017,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.outcome\",\
		\"weight\": 4018,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.disposition\",\
		\"weight\": 4019,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.ruleset\",\
		\"weight\": 4020,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.originalRuleset\",\
		\"weight\": 4021,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.created\",\
		\"weight\": 4022,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.period\",\
		\"weight\": 4023,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.organizationIdentifier\",\
		\"weight\": 4024,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.organizationReference\",\
		\"weight\": 4024,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.requestProviderIdentifier\",\
		\"weight\": 4025,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.requestProviderReference\",\
		\"weight\": 4025,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.requestOrganizationIdentifier\",\
		\"weight\": 4026,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.requestOrganizationReference\",\
		\"weight\": 4026,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail\",\
		\"weight\": 4027,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.id\",\
		\"weight\": 4028,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.extension\",\
		\"weight\": 4029,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.modifierExtension\",\
		\"weight\": 4030,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PaymentReconciliation.detail.type\",\
		\"weight\": 4031,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.requestIdentifier\",\
		\"weight\": 4032,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.requestReference\",\
		\"weight\": 4032,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.responseIdentifier\",\
		\"weight\": 4033,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.responseReference\",\
		\"weight\": 4033,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.submitterIdentifier\",\
		\"weight\": 4034,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.submitterReference\",\
		\"weight\": 4034,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.payeeIdentifier\",\
		\"weight\": 4035,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.payeeReference\",\
		\"weight\": 4035,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.date\",\
		\"weight\": 4036,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.detail.amount\",\
		\"weight\": 4037,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.form\",\
		\"weight\": 4038,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PaymentReconciliation.total\",\
		\"weight\": 4039,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.note\",\
		\"weight\": 4040,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.note.id\",\
		\"weight\": 4041,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.note.extension\",\
		\"weight\": 4042,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.note.modifierExtension\",\
		\"weight\": 4043,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.note.type\",\
		\"weight\": 4044,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PaymentReconciliation.note.text\",\
		\"weight\": 4045,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person\",\
		\"weight\": 4046,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.id\",\
		\"weight\": 4047,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.meta\",\
		\"weight\": 4048,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.implicitRules\",\
		\"weight\": 4049,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.language\",\
		\"weight\": 4050,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.text\",\
		\"weight\": 4051,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.contained\",\
		\"weight\": 4052,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.extension\",\
		\"weight\": 4053,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.modifierExtension\",\
		\"weight\": 4054,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.identifier\",\
		\"weight\": 4055,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.name\",\
		\"weight\": 4056,\
		\"max\": \"*\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.telecom\",\
		\"weight\": 4057,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.gender\",\
		\"weight\": 4058,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.birthDate\",\
		\"weight\": 4059,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.address\",\
		\"weight\": 4060,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.photo\",\
		\"weight\": 4061,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.managingOrganization\",\
		\"weight\": 4062,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.active\",\
		\"weight\": 4063,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.link\",\
		\"weight\": 4064,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.link.id\",\
		\"weight\": 4065,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.link.extension\",\
		\"weight\": 4066,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.link.modifierExtension\",\
		\"weight\": 4067,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Person.link.target\",\
		\"weight\": 4068,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Person.link.assurance\",\
		\"weight\": 4069,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition\",\
		\"weight\": 4070,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.id\",\
		\"weight\": 4071,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.meta\",\
		\"weight\": 4072,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.implicitRules\",\
		\"weight\": 4073,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.language\",\
		\"weight\": 4074,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.text\",\
		\"weight\": 4075,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.contained\",\
		\"weight\": 4076,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.extension\",\
		\"weight\": 4077,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.modifierExtension\",\
		\"weight\": 4078,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.url\",\
		\"weight\": 4079,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.identifier\",\
		\"weight\": 4080,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.version\",\
		\"weight\": 4081,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.name\",\
		\"weight\": 4082,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.title\",\
		\"weight\": 4083,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.type\",\
		\"weight\": 4084,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PlanDefinition.status\",\
		\"weight\": 4085,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.experimental\",\
		\"weight\": 4086,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.description\",\
		\"weight\": 4087,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.purpose\",\
		\"weight\": 4088,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.usage\",\
		\"weight\": 4089,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.publicationDate\",\
		\"weight\": 4090,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.lastReviewDate\",\
		\"weight\": 4091,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.effectivePeriod\",\
		\"weight\": 4092,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.coverage\",\
		\"weight\": 4093,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.topic\",\
		\"weight\": 4094,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.contributor\",\
		\"weight\": 4095,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.publisher\",\
		\"weight\": 4096,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.contact\",\
		\"weight\": 4097,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.copyright\",\
		\"weight\": 4098,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.relatedResource\",\
		\"weight\": 4099,\
		\"max\": \"*\",\
		\"type\": \"RelatedResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.library\",\
		\"weight\": 4100,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition\",\
		\"weight\": 4101,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.id\",\
		\"weight\": 4102,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.extension\",\
		\"weight\": 4103,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.modifierExtension\",\
		\"weight\": 4104,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.actionIdentifier\",\
		\"weight\": 4105,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.label\",\
		\"weight\": 4106,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.title\",\
		\"weight\": 4107,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.description\",\
		\"weight\": 4108,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.textEquivalent\",\
		\"weight\": 4109,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.concept\",\
		\"weight\": 4110,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.documentation\",\
		\"weight\": 4111,\
		\"max\": \"*\",\
		\"type\": \"RelatedResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.triggerDefinition\",\
		\"weight\": 4112,\
		\"max\": \"*\",\
		\"type\": \"TriggerDefinition\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.condition\",\
		\"weight\": 4113,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.condition.id\",\
		\"weight\": 4114,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.condition.extension\",\
		\"weight\": 4115,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.condition.modifierExtension\",\
		\"weight\": 4116,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.condition.description\",\
		\"weight\": 4117,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.condition.language\",\
		\"weight\": 4118,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.condition.expression\",\
		\"weight\": 4119,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction\",\
		\"weight\": 4120,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.id\",\
		\"weight\": 4121,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.extension\",\
		\"weight\": 4122,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.modifierExtension\",\
		\"weight\": 4123,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.actionIdentifier\",\
		\"weight\": 4124,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.relationship\",\
		\"weight\": 4125,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.offsetDuration\",\
		\"weight\": 4126,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.offsetRange\",\
		\"weight\": 4126,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.relatedAction.anchor\",\
		\"weight\": 4127,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.timingDateTime\",\
		\"weight\": 4128,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.timingPeriod\",\
		\"weight\": 4128,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.timingDuration\",\
		\"weight\": 4128,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.timingRange\",\
		\"weight\": 4128,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.timingTiming\",\
		\"weight\": 4128,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.participantType\",\
		\"weight\": 4129,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.type\",\
		\"weight\": 4130,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.groupingBehavior\",\
		\"weight\": 4131,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.selectionBehavior\",\
		\"weight\": 4132,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.requiredBehavior\",\
		\"weight\": 4133,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.precheckBehavior\",\
		\"weight\": 4134,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.cardinalityBehavior\",\
		\"weight\": 4135,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.activityDefinition\",\
		\"weight\": 4136,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.transform\",\
		\"weight\": 4137,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue\",\
		\"weight\": 4138,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.id\",\
		\"weight\": 4139,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.extension\",\
		\"weight\": 4140,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.modifierExtension\",\
		\"weight\": 4141,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.description\",\
		\"weight\": 4142,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.path\",\
		\"weight\": 4143,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.language\",\
		\"weight\": 4144,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.dynamicValue.expression\",\
		\"weight\": 4145,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PlanDefinition.actionDefinition.actionDefinition\",\
		\"weight\": 4146,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner\",\
		\"weight\": 4147,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.id\",\
		\"weight\": 4148,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.meta\",\
		\"weight\": 4149,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.implicitRules\",\
		\"weight\": 4150,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.language\",\
		\"weight\": 4151,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.text\",\
		\"weight\": 4152,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.contained\",\
		\"weight\": 4153,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.extension\",\
		\"weight\": 4154,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.modifierExtension\",\
		\"weight\": 4155,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.identifier\",\
		\"weight\": 4156,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.active\",\
		\"weight\": 4157,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.name\",\
		\"weight\": 4158,\
		\"max\": \"*\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.telecom\",\
		\"weight\": 4159,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.address\",\
		\"weight\": 4160,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.gender\",\
		\"weight\": 4161,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.birthDate\",\
		\"weight\": 4162,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.photo\",\
		\"weight\": 4163,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role\",\
		\"weight\": 4164,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.id\",\
		\"weight\": 4165,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.extension\",\
		\"weight\": 4166,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.modifierExtension\",\
		\"weight\": 4167,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.organization\",\
		\"weight\": 4168,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.code\",\
		\"weight\": 4169,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.specialty\",\
		\"weight\": 4170,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.identifier\",\
		\"weight\": 4171,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.telecom\",\
		\"weight\": 4172,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.period\",\
		\"weight\": 4173,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.location\",\
		\"weight\": 4174,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.healthcareService\",\
		\"weight\": 4175,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.role.endpoint\",\
		\"weight\": 4176,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.qualification\",\
		\"weight\": 4177,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.qualification.id\",\
		\"weight\": 4178,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.qualification.extension\",\
		\"weight\": 4179,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.qualification.modifierExtension\",\
		\"weight\": 4180,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.qualification.identifier\",\
		\"weight\": 4181,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Practitioner.qualification.code\",\
		\"weight\": 4182,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.qualification.period\",\
		\"weight\": 4183,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.qualification.issuer\",\
		\"weight\": 4184,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Practitioner.communication\",\
		\"weight\": 4185,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole\",\
		\"weight\": 4186,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.id\",\
		\"weight\": 4187,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.meta\",\
		\"weight\": 4188,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.implicitRules\",\
		\"weight\": 4189,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.language\",\
		\"weight\": 4190,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.text\",\
		\"weight\": 4191,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.contained\",\
		\"weight\": 4192,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.extension\",\
		\"weight\": 4193,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.modifierExtension\",\
		\"weight\": 4194,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.identifier\",\
		\"weight\": 4195,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.active\",\
		\"weight\": 4196,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.practitioner\",\
		\"weight\": 4197,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.organization\",\
		\"weight\": 4198,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.code\",\
		\"weight\": 4199,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.specialty\",\
		\"weight\": 4200,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.location\",\
		\"weight\": 4201,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.healthcareService\",\
		\"weight\": 4202,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.telecom\",\
		\"weight\": 4203,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.period\",\
		\"weight\": 4204,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availableTime\",\
		\"weight\": 4205,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availableTime.id\",\
		\"weight\": 4206,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availableTime.extension\",\
		\"weight\": 4207,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availableTime.modifierExtension\",\
		\"weight\": 4208,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availableTime.daysOfWeek\",\
		\"weight\": 4209,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availableTime.allDay\",\
		\"weight\": 4210,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availableTime.availableStartTime\",\
		\"weight\": 4211,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availableTime.availableEndTime\",\
		\"weight\": 4212,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.notAvailable\",\
		\"weight\": 4213,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.notAvailable.id\",\
		\"weight\": 4214,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.notAvailable.extension\",\
		\"weight\": 4215,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.notAvailable.modifierExtension\",\
		\"weight\": 4216,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"PractitionerRole.notAvailable.description\",\
		\"weight\": 4217,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.notAvailable.during\",\
		\"weight\": 4218,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.availabilityExceptions\",\
		\"weight\": 4219,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"PractitionerRole.endpoint\",\
		\"weight\": 4220,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure\",\
		\"weight\": 4221,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.id\",\
		\"weight\": 4222,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.meta\",\
		\"weight\": 4223,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.implicitRules\",\
		\"weight\": 4224,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.language\",\
		\"weight\": 4225,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.text\",\
		\"weight\": 4226,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.contained\",\
		\"weight\": 4227,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.extension\",\
		\"weight\": 4228,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.modifierExtension\",\
		\"weight\": 4229,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.identifier\",\
		\"weight\": 4230,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Procedure.subject\",\
		\"weight\": 4231,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Procedure.status\",\
		\"weight\": 4232,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.category\",\
		\"weight\": 4233,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Procedure.code\",\
		\"weight\": 4234,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.notPerformed\",\
		\"weight\": 4235,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.reasonNotPerformed\",\
		\"weight\": 4236,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.bodySite\",\
		\"weight\": 4237,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.reasonReference\",\
		\"weight\": 4238,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.reasonCode\",\
		\"weight\": 4239,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.performer\",\
		\"weight\": 4240,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.performer.id\",\
		\"weight\": 4241,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.performer.extension\",\
		\"weight\": 4242,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.performer.modifierExtension\",\
		\"weight\": 4243,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.performer.actor\",\
		\"weight\": 4244,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.performer.role\",\
		\"weight\": 4245,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.performedDateTime\",\
		\"weight\": 4246,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.performedPeriod\",\
		\"weight\": 4246,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.encounter\",\
		\"weight\": 4247,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.location\",\
		\"weight\": 4248,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.outcome\",\
		\"weight\": 4249,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.report\",\
		\"weight\": 4250,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.complication\",\
		\"weight\": 4251,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.followUp\",\
		\"weight\": 4252,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.request\",\
		\"weight\": 4253,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.notes\",\
		\"weight\": 4254,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.focalDevice\",\
		\"weight\": 4255,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.focalDevice.id\",\
		\"weight\": 4256,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.focalDevice.extension\",\
		\"weight\": 4257,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.focalDevice.modifierExtension\",\
		\"weight\": 4258,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.focalDevice.action\",\
		\"weight\": 4259,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Procedure.focalDevice.manipulated\",\
		\"weight\": 4260,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.usedReference\",\
		\"weight\": 4261,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.usedCode\",\
		\"weight\": 4262,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Procedure.component\",\
		\"weight\": 4263,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest\",\
		\"weight\": 4264,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.id\",\
		\"weight\": 4265,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.meta\",\
		\"weight\": 4266,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.implicitRules\",\
		\"weight\": 4267,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.language\",\
		\"weight\": 4268,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.text\",\
		\"weight\": 4269,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.contained\",\
		\"weight\": 4270,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.extension\",\
		\"weight\": 4271,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.modifierExtension\",\
		\"weight\": 4272,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.identifier\",\
		\"weight\": 4273,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ProcedureRequest.subject\",\
		\"weight\": 4274,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ProcedureRequest.code\",\
		\"weight\": 4275,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.bodySite\",\
		\"weight\": 4276,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.reasonCodeableConcept\",\
		\"weight\": 4277,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.reasonReference\",\
		\"weight\": 4277,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.scheduledDateTime\",\
		\"weight\": 4278,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.scheduledPeriod\",\
		\"weight\": 4278,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.scheduledTiming\",\
		\"weight\": 4278,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.encounter\",\
		\"weight\": 4279,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.performer\",\
		\"weight\": 4280,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.status\",\
		\"weight\": 4281,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.notes\",\
		\"weight\": 4282,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.asNeededBoolean\",\
		\"weight\": 4283,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.asNeededCodeableConcept\",\
		\"weight\": 4283,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.orderedOn\",\
		\"weight\": 4284,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.orderer\",\
		\"weight\": 4285,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcedureRequest.priority\",\
		\"weight\": 4286,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest\",\
		\"weight\": 4287,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.id\",\
		\"weight\": 4288,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.meta\",\
		\"weight\": 4289,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.implicitRules\",\
		\"weight\": 4290,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.language\",\
		\"weight\": 4291,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.text\",\
		\"weight\": 4292,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.contained\",\
		\"weight\": 4293,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.extension\",\
		\"weight\": 4294,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.modifierExtension\",\
		\"weight\": 4295,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.identifier\",\
		\"weight\": 4296,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ProcessRequest.status\",\
		\"weight\": 4297,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.ruleset\",\
		\"weight\": 4298,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.originalRuleset\",\
		\"weight\": 4299,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ProcessRequest.action\",\
		\"weight\": 4300,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.created\",\
		\"weight\": 4301,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.targetIdentifier\",\
		\"weight\": 4302,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.targetReference\",\
		\"weight\": 4302,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.providerIdentifier\",\
		\"weight\": 4303,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.providerReference\",\
		\"weight\": 4303,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.organizationIdentifier\",\
		\"weight\": 4304,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.organizationReference\",\
		\"weight\": 4304,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.requestIdentifier\",\
		\"weight\": 4305,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.requestReference\",\
		\"weight\": 4305,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.responseIdentifier\",\
		\"weight\": 4306,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.responseReference\",\
		\"weight\": 4306,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.nullify\",\
		\"weight\": 4307,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.reference\",\
		\"weight\": 4308,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.item\",\
		\"weight\": 4309,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.item.id\",\
		\"weight\": 4310,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.item.extension\",\
		\"weight\": 4311,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.item.modifierExtension\",\
		\"weight\": 4312,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ProcessRequest.item.sequenceLinkId\",\
		\"weight\": 4313,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.include\",\
		\"weight\": 4314,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.exclude\",\
		\"weight\": 4315,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessRequest.period\",\
		\"weight\": 4316,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse\",\
		\"weight\": 4317,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.id\",\
		\"weight\": 4318,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.meta\",\
		\"weight\": 4319,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.implicitRules\",\
		\"weight\": 4320,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.language\",\
		\"weight\": 4321,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.text\",\
		\"weight\": 4322,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.contained\",\
		\"weight\": 4323,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.extension\",\
		\"weight\": 4324,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.modifierExtension\",\
		\"weight\": 4325,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.identifier\",\
		\"weight\": 4326,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ProcessResponse.status\",\
		\"weight\": 4327,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.requestIdentifier\",\
		\"weight\": 4328,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.requestReference\",\
		\"weight\": 4328,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.outcome\",\
		\"weight\": 4329,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.disposition\",\
		\"weight\": 4330,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.ruleset\",\
		\"weight\": 4331,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.originalRuleset\",\
		\"weight\": 4332,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.created\",\
		\"weight\": 4333,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.organizationIdentifier\",\
		\"weight\": 4334,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.organizationReference\",\
		\"weight\": 4334,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.requestProviderIdentifier\",\
		\"weight\": 4335,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.requestProviderReference\",\
		\"weight\": 4335,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.requestOrganizationIdentifier\",\
		\"weight\": 4336,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.requestOrganizationReference\",\
		\"weight\": 4336,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.form\",\
		\"weight\": 4337,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.notes\",\
		\"weight\": 4338,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.notes.id\",\
		\"weight\": 4339,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.notes.extension\",\
		\"weight\": 4340,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.notes.modifierExtension\",\
		\"weight\": 4341,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.notes.type\",\
		\"weight\": 4342,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.notes.text\",\
		\"weight\": 4343,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ProcessResponse.error\",\
		\"weight\": 4344,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance\",\
		\"weight\": 4345,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.id\",\
		\"weight\": 4346,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.meta\",\
		\"weight\": 4347,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.implicitRules\",\
		\"weight\": 4348,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.language\",\
		\"weight\": 4349,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.text\",\
		\"weight\": 4350,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.contained\",\
		\"weight\": 4351,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.extension\",\
		\"weight\": 4352,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.modifierExtension\",\
		\"weight\": 4353,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.target\",\
		\"weight\": 4354,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.period\",\
		\"weight\": 4355,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.recorded\",\
		\"weight\": 4356,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.reason\",\
		\"weight\": 4357,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.activity\",\
		\"weight\": 4358,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.location\",\
		\"weight\": 4359,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.policy\",\
		\"weight\": 4360,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.agent\",\
		\"weight\": 4361,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.id\",\
		\"weight\": 4362,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.extension\",\
		\"weight\": 4363,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.modifierExtension\",\
		\"weight\": 4364,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.agent.role\",\
		\"weight\": 4365,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.actor\",\
		\"weight\": 4366,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.userId\",\
		\"weight\": 4367,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.relatedAgent\",\
		\"weight\": 4368,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.relatedAgent.id\",\
		\"weight\": 4369,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.relatedAgent.extension\",\
		\"weight\": 4370,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.agent.relatedAgent.modifierExtension\",\
		\"weight\": 4371,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.agent.relatedAgent.type\",\
		\"weight\": 4372,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.agent.relatedAgent.target\",\
		\"weight\": 4373,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.entity\",\
		\"weight\": 4374,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.entity.id\",\
		\"weight\": 4375,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.entity.extension\",\
		\"weight\": 4376,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.entity.modifierExtension\",\
		\"weight\": 4377,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.entity.role\",\
		\"weight\": 4378,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.entity.type\",\
		\"weight\": 4379,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Provenance.entity.reference\",\
		\"weight\": 4380,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.entity.display\",\
		\"weight\": 4381,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.entity.agent\",\
		\"weight\": 4382,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Provenance.signature\",\
		\"weight\": 4383,\
		\"max\": \"*\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire\",\
		\"weight\": 4384,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.id\",\
		\"weight\": 4385,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.meta\",\
		\"weight\": 4386,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.implicitRules\",\
		\"weight\": 4387,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.language\",\
		\"weight\": 4388,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.text\",\
		\"weight\": 4389,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.contained\",\
		\"weight\": 4390,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.extension\",\
		\"weight\": 4391,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.modifierExtension\",\
		\"weight\": 4392,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.url\",\
		\"weight\": 4393,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.identifier\",\
		\"weight\": 4394,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.version\",\
		\"weight\": 4395,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Questionnaire.status\",\
		\"weight\": 4396,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.date\",\
		\"weight\": 4397,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.publisher\",\
		\"weight\": 4398,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.telecom\",\
		\"weight\": 4399,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.useContext\",\
		\"weight\": 4400,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.title\",\
		\"weight\": 4401,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.concept\",\
		\"weight\": 4402,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.subjectType\",\
		\"weight\": 4403,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item\",\
		\"weight\": 4404,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.id\",\
		\"weight\": 4405,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.extension\",\
		\"weight\": 4406,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.modifierExtension\",\
		\"weight\": 4407,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.linkId\",\
		\"weight\": 4408,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.concept\",\
		\"weight\": 4409,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.prefix\",\
		\"weight\": 4410,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.text\",\
		\"weight\": 4411,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Questionnaire.item.type\",\
		\"weight\": 4412,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen\",\
		\"weight\": 4413,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.id\",\
		\"weight\": 4414,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.extension\",\
		\"weight\": 4415,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.modifierExtension\",\
		\"weight\": 4416,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Questionnaire.item.enableWhen.question\",\
		\"weight\": 4417,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.hasAnswer\",\
		\"weight\": 4418,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerBoolean\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerDecimal\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerInteger\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerDate\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerDateTime\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerInstant\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerTime\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerString\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerUri\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerAttachment\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerCoding\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerQuantity\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.enableWhen.answerReference\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.required\",\
		\"weight\": 4420,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.repeats\",\
		\"weight\": 4421,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.readOnly\",\
		\"weight\": 4422,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.maxLength\",\
		\"weight\": 4423,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.options\",\
		\"weight\": 4424,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.option\",\
		\"weight\": 4425,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.option.id\",\
		\"weight\": 4426,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.option.extension\",\
		\"weight\": 4427,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.option.modifierExtension\",\
		\"weight\": 4428,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Questionnaire.item.option.valueInteger\",\
		\"weight\": 4429,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Questionnaire.item.option.valueDate\",\
		\"weight\": 4429,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Questionnaire.item.option.valueTime\",\
		\"weight\": 4429,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Questionnaire.item.option.valueString\",\
		\"weight\": 4429,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Questionnaire.item.option.valueCoding\",\
		\"weight\": 4429,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialBoolean\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialDecimal\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialInteger\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialDate\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialDateTime\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialInstant\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialTime\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialString\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialUri\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialAttachment\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialCoding\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialQuantity\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.initialReference\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Questionnaire.item.item\",\
		\"weight\": 4431,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse\",\
		\"weight\": 4432,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.id\",\
		\"weight\": 4433,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.meta\",\
		\"weight\": 4434,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.implicitRules\",\
		\"weight\": 4435,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.language\",\
		\"weight\": 4436,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.text\",\
		\"weight\": 4437,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.contained\",\
		\"weight\": 4438,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.extension\",\
		\"weight\": 4439,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.modifierExtension\",\
		\"weight\": 4440,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.identifier\",\
		\"weight\": 4441,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.basedOn\",\
		\"weight\": 4442,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.parent\",\
		\"weight\": 4443,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.questionnaire\",\
		\"weight\": 4444,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"QuestionnaireResponse.status\",\
		\"weight\": 4445,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.subject\",\
		\"weight\": 4446,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.context\",\
		\"weight\": 4447,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.author\",\
		\"weight\": 4448,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.authored\",\
		\"weight\": 4449,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.source\",\
		\"weight\": 4450,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item\",\
		\"weight\": 4451,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.id\",\
		\"weight\": 4452,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.extension\",\
		\"weight\": 4453,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.modifierExtension\",\
		\"weight\": 4454,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.linkId\",\
		\"weight\": 4455,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.text\",\
		\"weight\": 4456,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.subject\",\
		\"weight\": 4457,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer\",\
		\"weight\": 4458,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.id\",\
		\"weight\": 4459,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.extension\",\
		\"weight\": 4460,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.modifierExtension\",\
		\"weight\": 4461,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueBoolean\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueDecimal\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueInteger\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueDate\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueDateTime\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueInstant\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueTime\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueString\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueUri\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueAttachment\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueCoding\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueQuantity\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.valueReference\",\
		\"weight\": 4462,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.answer.item\",\
		\"weight\": 4463,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"QuestionnaireResponse.item.item\",\
		\"weight\": 4464,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest\",\
		\"weight\": 4465,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.id\",\
		\"weight\": 4466,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.meta\",\
		\"weight\": 4467,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.implicitRules\",\
		\"weight\": 4468,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.language\",\
		\"weight\": 4469,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.text\",\
		\"weight\": 4470,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.contained\",\
		\"weight\": 4471,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.extension\",\
		\"weight\": 4472,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.modifierExtension\",\
		\"weight\": 4473,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.identifier\",\
		\"weight\": 4474,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.basedOn\",\
		\"weight\": 4475,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.parent\",\
		\"weight\": 4476,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ReferralRequest.status\",\
		\"weight\": 4477,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"ReferralRequest.category\",\
		\"weight\": 4478,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.type\",\
		\"weight\": 4479,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.priority\",\
		\"weight\": 4480,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.patient\",\
		\"weight\": 4481,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.context\",\
		\"weight\": 4482,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.fulfillmentTime\",\
		\"weight\": 4483,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.authored\",\
		\"weight\": 4484,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.requester\",\
		\"weight\": 4485,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.specialty\",\
		\"weight\": 4486,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.recipient\",\
		\"weight\": 4487,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.reason\",\
		\"weight\": 4488,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.description\",\
		\"weight\": 4489,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.serviceRequested\",\
		\"weight\": 4490,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"ReferralRequest.supportingInformation\",\
		\"weight\": 4491,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson\",\
		\"weight\": 4492,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.id\",\
		\"weight\": 4493,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.meta\",\
		\"weight\": 4494,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.implicitRules\",\
		\"weight\": 4495,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.language\",\
		\"weight\": 4496,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.text\",\
		\"weight\": 4497,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.contained\",\
		\"weight\": 4498,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.extension\",\
		\"weight\": 4499,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.modifierExtension\",\
		\"weight\": 4500,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.identifier\",\
		\"weight\": 4501,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.active\",\
		\"weight\": 4502,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"RelatedPerson.patient\",\
		\"weight\": 4503,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.relationship\",\
		\"weight\": 4504,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.name\",\
		\"weight\": 4505,\
		\"max\": \"*\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.telecom\",\
		\"weight\": 4506,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.gender\",\
		\"weight\": 4507,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.birthDate\",\
		\"weight\": 4508,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.address\",\
		\"weight\": 4509,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.photo\",\
		\"weight\": 4510,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RelatedPerson.period\",\
		\"weight\": 4511,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment\",\
		\"weight\": 4512,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.id\",\
		\"weight\": 4513,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.meta\",\
		\"weight\": 4514,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.implicitRules\",\
		\"weight\": 4515,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.language\",\
		\"weight\": 4516,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.text\",\
		\"weight\": 4517,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.contained\",\
		\"weight\": 4518,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.extension\",\
		\"weight\": 4519,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.modifierExtension\",\
		\"weight\": 4520,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.identifier\",\
		\"weight\": 4521,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.basedOn\",\
		\"weight\": 4522,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.parent\",\
		\"weight\": 4523,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"RiskAssessment.status\",\
		\"weight\": 4524,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.code\",\
		\"weight\": 4525,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.subject\",\
		\"weight\": 4526,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.context\",\
		\"weight\": 4527,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.occurrenceDateTime\",\
		\"weight\": 4528,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.occurrencePeriod\",\
		\"weight\": 4528,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.condition\",\
		\"weight\": 4529,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.performer\",\
		\"weight\": 4530,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.reasonCodeableConcept\",\
		\"weight\": 4531,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.reasonReference\",\
		\"weight\": 4531,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.method\",\
		\"weight\": 4532,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.basis\",\
		\"weight\": 4533,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction\",\
		\"weight\": 4534,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.id\",\
		\"weight\": 4535,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.extension\",\
		\"weight\": 4536,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.modifierExtension\",\
		\"weight\": 4537,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"RiskAssessment.prediction.outcome\",\
		\"weight\": 4538,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.probabilityDecimal\",\
		\"weight\": 4539,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.probabilityRange\",\
		\"weight\": 4539,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.probabilityCodeableConcept\",\
		\"weight\": 4539,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.relativeRisk\",\
		\"weight\": 4540,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.whenPeriod\",\
		\"weight\": 4541,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.whenRange\",\
		\"weight\": 4541,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.prediction.rationale\",\
		\"weight\": 4542,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.mitigation\",\
		\"weight\": 4543,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"RiskAssessment.note\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule\",\
		\"weight\": 4545,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.id\",\
		\"weight\": 4546,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.meta\",\
		\"weight\": 4547,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.implicitRules\",\
		\"weight\": 4548,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.language\",\
		\"weight\": 4549,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.text\",\
		\"weight\": 4550,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.contained\",\
		\"weight\": 4551,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.extension\",\
		\"weight\": 4552,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.modifierExtension\",\
		\"weight\": 4553,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.identifier\",\
		\"weight\": 4554,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.active\",\
		\"weight\": 4555,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.serviceCategory\",\
		\"weight\": 4556,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.serviceType\",\
		\"weight\": 4557,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.specialty\",\
		\"weight\": 4558,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Schedule.actor\",\
		\"weight\": 4559,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.planningHorizon\",\
		\"weight\": 4560,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Schedule.comment\",\
		\"weight\": 4561,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SearchParameter\",\
		\"weight\": 4562,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.id\",\
		\"weight\": 4563,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.meta\",\
		\"weight\": 4564,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.implicitRules\",\
		\"weight\": 4565,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.language\",\
		\"weight\": 4566,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.text\",\
		\"weight\": 4567,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.contained\",\
		\"weight\": 4568,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.extension\",\
		\"weight\": 4569,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.modifierExtension\",\
		\"weight\": 4570,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SearchParameter.url\",\
		\"weight\": 4571,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SearchParameter.name\",\
		\"weight\": 4572,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.status\",\
		\"weight\": 4573,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.experimental\",\
		\"weight\": 4574,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.date\",\
		\"weight\": 4575,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.publisher\",\
		\"weight\": 4576,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.contact\",\
		\"weight\": 4577,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.contact.id\",\
		\"weight\": 4578,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.contact.extension\",\
		\"weight\": 4579,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.contact.modifierExtension\",\
		\"weight\": 4580,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.contact.name\",\
		\"weight\": 4581,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.contact.telecom\",\
		\"weight\": 4582,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.useContext\",\
		\"weight\": 4583,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.requirements\",\
		\"weight\": 4584,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SearchParameter.code\",\
		\"weight\": 4585,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SearchParameter.base\",\
		\"weight\": 4586,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SearchParameter.type\",\
		\"weight\": 4587,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"SearchParameter.description\",\
		\"weight\": 4588,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.expression\",\
		\"weight\": 4589,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.xpath\",\
		\"weight\": 4590,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.xpathUsage\",\
		\"weight\": 4591,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.target\",\
		\"weight\": 4592,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SearchParameter.component\",\
		\"weight\": 4593,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence\",\
		\"weight\": 4594,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.id\",\
		\"weight\": 4595,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.meta\",\
		\"weight\": 4596,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.implicitRules\",\
		\"weight\": 4597,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.language\",\
		\"weight\": 4598,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.text\",\
		\"weight\": 4599,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.contained\",\
		\"weight\": 4600,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.extension\",\
		\"weight\": 4601,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.modifierExtension\",\
		\"weight\": 4602,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.identifier\",\
		\"weight\": 4603,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Sequence.type\",\
		\"weight\": 4604,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Sequence.coordinateSystem\",\
		\"weight\": 4605,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.patient\",\
		\"weight\": 4606,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.specimen\",\
		\"weight\": 4607,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.device\",\
		\"weight\": 4608,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quantity\",\
		\"weight\": 4609,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.referenceSeq\",\
		\"weight\": 4610,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.referenceSeq.id\",\
		\"weight\": 4611,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.referenceSeq.extension\",\
		\"weight\": 4612,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.referenceSeq.modifierExtension\",\
		\"weight\": 4613,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.referenceSeq.chromosome\",\
		\"weight\": 4614,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.referenceSeq.genomeBuild\",\
		\"weight\": 4615,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Sequence.referenceSeq.referenceSeqId\",\
		\"weight\": 4616,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.referenceSeq.referenceSeqPointer\",\
		\"weight\": 4617,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.referenceSeq.referenceSeqString\",\
		\"weight\": 4618,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Sequence.referenceSeq.strand\",\
		\"weight\": 4619,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Sequence.referenceSeq.windowStart\",\
		\"weight\": 4620,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Sequence.referenceSeq.windowEnd\",\
		\"weight\": 4621,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant\",\
		\"weight\": 4622,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.id\",\
		\"weight\": 4623,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.extension\",\
		\"weight\": 4624,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.modifierExtension\",\
		\"weight\": 4625,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.start\",\
		\"weight\": 4626,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.end\",\
		\"weight\": 4627,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.observedAllele\",\
		\"weight\": 4628,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.referenceAllele\",\
		\"weight\": 4629,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.cigar\",\
		\"weight\": 4630,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.variant.variantPointer\",\
		\"weight\": 4631,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.observedSeq\",\
		\"weight\": 4632,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality\",\
		\"weight\": 4633,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.id\",\
		\"weight\": 4634,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.extension\",\
		\"weight\": 4635,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.modifierExtension\",\
		\"weight\": 4636,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.standardSequence\",\
		\"weight\": 4637,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.start\",\
		\"weight\": 4638,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.end\",\
		\"weight\": 4639,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.score\",\
		\"weight\": 4640,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.method\",\
		\"weight\": 4641,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.truthTP\",\
		\"weight\": 4642,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.queryTP\",\
		\"weight\": 4643,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.truthFN\",\
		\"weight\": 4644,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.queryFP\",\
		\"weight\": 4645,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.gtFP\",\
		\"weight\": 4646,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.precision\",\
		\"weight\": 4647,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.recall\",\
		\"weight\": 4648,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.quality.fScore\",\
		\"weight\": 4649,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.readCoverage\",\
		\"weight\": 4650,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.repository\",\
		\"weight\": 4651,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.repository.id\",\
		\"weight\": 4652,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.repository.extension\",\
		\"weight\": 4653,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.repository.modifierExtension\",\
		\"weight\": 4654,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.repository.url\",\
		\"weight\": 4655,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.repository.name\",\
		\"weight\": 4656,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.repository.variantId\",\
		\"weight\": 4657,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.repository.readId\",\
		\"weight\": 4658,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.pointer\",\
		\"weight\": 4659,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant\",\
		\"weight\": 4660,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.id\",\
		\"weight\": 4661,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.extension\",\
		\"weight\": 4662,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.modifierExtension\",\
		\"weight\": 4663,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.precisionOfBoundaries\",\
		\"weight\": 4664,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.reportedaCGHRatio\",\
		\"weight\": 4665,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.length\",\
		\"weight\": 4666,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.outer\",\
		\"weight\": 4667,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.outer.id\",\
		\"weight\": 4668,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.outer.extension\",\
		\"weight\": 4669,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.outer.modifierExtension\",\
		\"weight\": 4670,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.outer.start\",\
		\"weight\": 4671,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.outer.end\",\
		\"weight\": 4672,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.inner\",\
		\"weight\": 4673,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.inner.id\",\
		\"weight\": 4674,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.inner.extension\",\
		\"weight\": 4675,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.inner.modifierExtension\",\
		\"weight\": 4676,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.inner.start\",\
		\"weight\": 4677,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Sequence.structureVariant.inner.end\",\
		\"weight\": 4678,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot\",\
		\"weight\": 4679,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.id\",\
		\"weight\": 4680,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.meta\",\
		\"weight\": 4681,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.implicitRules\",\
		\"weight\": 4682,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.language\",\
		\"weight\": 4683,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.text\",\
		\"weight\": 4684,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.contained\",\
		\"weight\": 4685,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.extension\",\
		\"weight\": 4686,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.modifierExtension\",\
		\"weight\": 4687,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.identifier\",\
		\"weight\": 4688,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.serviceCategory\",\
		\"weight\": 4689,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.serviceType\",\
		\"weight\": 4690,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.specialty\",\
		\"weight\": 4691,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.appointmentType\",\
		\"weight\": 4692,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Slot.schedule\",\
		\"weight\": 4693,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Slot.status\",\
		\"weight\": 4694,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Slot.start\",\
		\"weight\": 4695,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Slot.end\",\
		\"weight\": 4696,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.overbooked\",\
		\"weight\": 4697,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Slot.comment\",\
		\"weight\": 4698,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen\",\
		\"weight\": 4699,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.id\",\
		\"weight\": 4700,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.meta\",\
		\"weight\": 4701,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.implicitRules\",\
		\"weight\": 4702,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.language\",\
		\"weight\": 4703,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.text\",\
		\"weight\": 4704,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.contained\",\
		\"weight\": 4705,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.extension\",\
		\"weight\": 4706,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.modifierExtension\",\
		\"weight\": 4707,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.identifier\",\
		\"weight\": 4708,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.accessionIdentifier\",\
		\"weight\": 4709,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.status\",\
		\"weight\": 4710,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.type\",\
		\"weight\": 4711,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Specimen.subject\",\
		\"weight\": 4712,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.receivedTime\",\
		\"weight\": 4713,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.parent\",\
		\"weight\": 4714,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.request\",\
		\"weight\": 4715,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection\",\
		\"weight\": 4716,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.id\",\
		\"weight\": 4717,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.extension\",\
		\"weight\": 4718,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.modifierExtension\",\
		\"weight\": 4719,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.collector\",\
		\"weight\": 4720,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.collectedDateTime\",\
		\"weight\": 4721,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.collectedPeriod\",\
		\"weight\": 4721,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.quantity\",\
		\"weight\": 4722,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.method\",\
		\"weight\": 4723,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.collection.bodySite\",\
		\"weight\": 4724,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment\",\
		\"weight\": 4725,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment.id\",\
		\"weight\": 4726,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment.extension\",\
		\"weight\": 4727,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment.modifierExtension\",\
		\"weight\": 4728,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment.description\",\
		\"weight\": 4729,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment.procedure\",\
		\"weight\": 4730,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment.additive\",\
		\"weight\": 4731,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment.timeDateTime\",\
		\"weight\": 4732,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.treatment.timePeriod\",\
		\"weight\": 4732,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container\",\
		\"weight\": 4733,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.id\",\
		\"weight\": 4734,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.extension\",\
		\"weight\": 4735,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.modifierExtension\",\
		\"weight\": 4736,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.identifier\",\
		\"weight\": 4737,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.description\",\
		\"weight\": 4738,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.type\",\
		\"weight\": 4739,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.capacity\",\
		\"weight\": 4740,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.specimenQuantity\",\
		\"weight\": 4741,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.additiveCodeableConcept\",\
		\"weight\": 4742,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.container.additiveReference\",\
		\"weight\": 4742,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Specimen.note\",\
		\"weight\": 4743,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition\",\
		\"weight\": 4744,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.id\",\
		\"weight\": 4745,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.meta\",\
		\"weight\": 4746,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.implicitRules\",\
		\"weight\": 4747,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.language\",\
		\"weight\": 4748,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.text\",\
		\"weight\": 4749,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.contained\",\
		\"weight\": 4750,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.extension\",\
		\"weight\": 4751,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.modifierExtension\",\
		\"weight\": 4752,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.url\",\
		\"weight\": 4753,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.identifier\",\
		\"weight\": 4754,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.version\",\
		\"weight\": 4755,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.name\",\
		\"weight\": 4756,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.display\",\
		\"weight\": 4757,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.status\",\
		\"weight\": 4758,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.experimental\",\
		\"weight\": 4759,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.publisher\",\
		\"weight\": 4760,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.contact\",\
		\"weight\": 4761,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.contact.id\",\
		\"weight\": 4762,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.contact.extension\",\
		\"weight\": 4763,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.contact.modifierExtension\",\
		\"weight\": 4764,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.contact.name\",\
		\"weight\": 4765,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.contact.telecom\",\
		\"weight\": 4766,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.date\",\
		\"weight\": 4767,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.description\",\
		\"weight\": 4768,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.useContext\",\
		\"weight\": 4769,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.requirements\",\
		\"weight\": 4770,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.copyright\",\
		\"weight\": 4771,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.code\",\
		\"weight\": 4772,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.fhirVersion\",\
		\"weight\": 4773,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.mapping\",\
		\"weight\": 4774,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.mapping.id\",\
		\"weight\": 4775,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.mapping.extension\",\
		\"weight\": 4776,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.mapping.modifierExtension\",\
		\"weight\": 4777,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.mapping.identity\",\
		\"weight\": 4778,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.mapping.uri\",\
		\"weight\": 4779,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.mapping.name\",\
		\"weight\": 4780,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.mapping.comments\",\
		\"weight\": 4781,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.kind\",\
		\"weight\": 4782,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.abstract\",\
		\"weight\": 4783,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.contextType\",\
		\"weight\": 4784,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.context\",\
		\"weight\": 4785,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.type\",\
		\"weight\": 4786,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.baseDefinition\",\
		\"weight\": 4787,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.derivation\",\
		\"weight\": 4788,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.snapshot\",\
		\"weight\": 4789,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.snapshot.id\",\
		\"weight\": 4790,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.snapshot.extension\",\
		\"weight\": 4791,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.snapshot.modifierExtension\",\
		\"weight\": 4792,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.snapshot.element\",\
		\"weight\": 4793,\
		\"max\": \"*\",\
		\"type\": \"ElementDefinition\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.differential\",\
		\"weight\": 4794,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.differential.id\",\
		\"weight\": 4795,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.differential.extension\",\
		\"weight\": 4796,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureDefinition.differential.modifierExtension\",\
		\"weight\": 4797,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureDefinition.differential.element\",\
		\"weight\": 4798,\
		\"max\": \"*\",\
		\"type\": \"ElementDefinition\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap\",\
		\"weight\": 4799,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.id\",\
		\"weight\": 4800,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.meta\",\
		\"weight\": 4801,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.implicitRules\",\
		\"weight\": 4802,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.language\",\
		\"weight\": 4803,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.text\",\
		\"weight\": 4804,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.contained\",\
		\"weight\": 4805,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.extension\",\
		\"weight\": 4806,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.modifierExtension\",\
		\"weight\": 4807,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.url\",\
		\"weight\": 4808,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.identifier\",\
		\"weight\": 4809,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.version\",\
		\"weight\": 4810,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.name\",\
		\"weight\": 4811,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.status\",\
		\"weight\": 4812,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.experimental\",\
		\"weight\": 4813,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.publisher\",\
		\"weight\": 4814,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.contact\",\
		\"weight\": 4815,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.contact.id\",\
		\"weight\": 4816,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.contact.extension\",\
		\"weight\": 4817,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.contact.modifierExtension\",\
		\"weight\": 4818,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.contact.name\",\
		\"weight\": 4819,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.contact.telecom\",\
		\"weight\": 4820,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.date\",\
		\"weight\": 4821,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.description\",\
		\"weight\": 4822,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.useContext\",\
		\"weight\": 4823,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.requirements\",\
		\"weight\": 4824,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.copyright\",\
		\"weight\": 4825,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.structure\",\
		\"weight\": 4826,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.structure.id\",\
		\"weight\": 4827,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.structure.extension\",\
		\"weight\": 4828,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.structure.modifierExtension\",\
		\"weight\": 4829,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.structure.url\",\
		\"weight\": 4830,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.structure.mode\",\
		\"weight\": 4831,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.structure.documentation\",\
		\"weight\": 4832,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.import\",\
		\"weight\": 4833,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group\",\
		\"weight\": 4834,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.id\",\
		\"weight\": 4835,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.extension\",\
		\"weight\": 4836,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.modifierExtension\",\
		\"weight\": 4837,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.name\",\
		\"weight\": 4838,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.extends\",\
		\"weight\": 4839,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.documentation\",\
		\"weight\": 4840,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.input\",\
		\"weight\": 4841,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.input.id\",\
		\"weight\": 4842,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.input.extension\",\
		\"weight\": 4843,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.input.modifierExtension\",\
		\"weight\": 4844,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.input.name\",\
		\"weight\": 4845,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.input.type\",\
		\"weight\": 4846,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.input.mode\",\
		\"weight\": 4847,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.input.documentation\",\
		\"weight\": 4848,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule\",\
		\"weight\": 4849,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.id\",\
		\"weight\": 4850,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.extension\",\
		\"weight\": 4851,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.modifierExtension\",\
		\"weight\": 4852,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.name\",\
		\"weight\": 4853,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.source\",\
		\"weight\": 4854,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.source.id\",\
		\"weight\": 4855,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.source.extension\",\
		\"weight\": 4856,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.source.modifierExtension\",\
		\"weight\": 4857,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.source.required\",\
		\"weight\": 4858,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.source.context\",\
		\"weight\": 4859,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.source.contextType\",\
		\"weight\": 4860,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.source.element\",\
		\"weight\": 4861,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.source.listMode\",\
		\"weight\": 4862,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.source.variable\",\
		\"weight\": 4863,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.source.condition\",\
		\"weight\": 4864,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.source.check\",\
		\"weight\": 4865,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target\",\
		\"weight\": 4866,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.id\",\
		\"weight\": 4867,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.extension\",\
		\"weight\": 4868,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.modifierExtension\",\
		\"weight\": 4869,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.target.context\",\
		\"weight\": 4870,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.target.contextType\",\
		\"weight\": 4871,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.element\",\
		\"weight\": 4872,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.variable\",\
		\"weight\": 4873,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.listMode\",\
		\"weight\": 4874,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.listRuleId\",\
		\"weight\": 4875,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.transform\",\
		\"weight\": 4876,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.parameter\",\
		\"weight\": 4877,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.parameter.id\",\
		\"weight\": 4878,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.parameter.extension\",\
		\"weight\": 4879,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.target.parameter.modifierExtension\",\
		\"weight\": 4880,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.target.parameter.valueId\",\
		\"weight\": 4881,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.target.parameter.valueString\",\
		\"weight\": 4881,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.target.parameter.valueBoolean\",\
		\"weight\": 4881,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.target.parameter.valueInteger\",\
		\"weight\": 4881,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.target.parameter.valueDecimal\",\
		\"weight\": 4881,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.rule\",\
		\"weight\": 4882,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.dependent\",\
		\"weight\": 4883,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.dependent.id\",\
		\"weight\": 4884,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.dependent.extension\",\
		\"weight\": 4885,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.dependent.modifierExtension\",\
		\"weight\": 4886,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.dependent.name\",\
		\"weight\": 4887,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"StructureMap.group.rule.dependent.variable\",\
		\"weight\": 4888,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"StructureMap.group.rule.documentation\",\
		\"weight\": 4889,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription\",\
		\"weight\": 4890,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.id\",\
		\"weight\": 4891,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.meta\",\
		\"weight\": 4892,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.implicitRules\",\
		\"weight\": 4893,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.language\",\
		\"weight\": 4894,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.text\",\
		\"weight\": 4895,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.contained\",\
		\"weight\": 4896,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.extension\",\
		\"weight\": 4897,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.modifierExtension\",\
		\"weight\": 4898,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Subscription.criteria\",\
		\"weight\": 4899,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.contact\",\
		\"weight\": 4900,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Subscription.reason\",\
		\"weight\": 4901,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Subscription.status\",\
		\"weight\": 4902,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.error\",\
		\"weight\": 4903,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Subscription.channel\",\
		\"weight\": 4904,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.channel.id\",\
		\"weight\": 4905,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.channel.extension\",\
		\"weight\": 4906,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.channel.modifierExtension\",\
		\"weight\": 4907,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Subscription.channel.type\",\
		\"weight\": 4908,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.channel.endpoint\",\
		\"weight\": 4909,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.channel.payload\",\
		\"weight\": 4910,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.channel.header\",\
		\"weight\": 4911,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.end\",\
		\"weight\": 4912,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Subscription.tag\",\
		\"weight\": 4913,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance\",\
		\"weight\": 4914,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.id\",\
		\"weight\": 4915,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.meta\",\
		\"weight\": 4916,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.implicitRules\",\
		\"weight\": 4917,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.language\",\
		\"weight\": 4918,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.text\",\
		\"weight\": 4919,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.contained\",\
		\"weight\": 4920,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.extension\",\
		\"weight\": 4921,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.modifierExtension\",\
		\"weight\": 4922,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.identifier\",\
		\"weight\": 4923,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.category\",\
		\"weight\": 4924,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Substance.code\",\
		\"weight\": 4925,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.description\",\
		\"weight\": 4926,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.instance\",\
		\"weight\": 4927,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.instance.id\",\
		\"weight\": 4928,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.instance.extension\",\
		\"weight\": 4929,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.instance.modifierExtension\",\
		\"weight\": 4930,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.instance.identifier\",\
		\"weight\": 4931,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.instance.expiry\",\
		\"weight\": 4932,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.instance.quantity\",\
		\"weight\": 4933,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.ingredient\",\
		\"weight\": 4934,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.ingredient.id\",\
		\"weight\": 4935,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.ingredient.extension\",\
		\"weight\": 4936,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.ingredient.modifierExtension\",\
		\"weight\": 4937,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Substance.ingredient.quantity\",\
		\"weight\": 4938,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Substance.ingredient.substanceCodeableConcept\",\
		\"weight\": 4939,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Substance.ingredient.substanceReference\",\
		\"weight\": 4939,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery\",\
		\"weight\": 4940,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.id\",\
		\"weight\": 4941,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.meta\",\
		\"weight\": 4942,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.implicitRules\",\
		\"weight\": 4943,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.language\",\
		\"weight\": 4944,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.text\",\
		\"weight\": 4945,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.contained\",\
		\"weight\": 4946,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.extension\",\
		\"weight\": 4947,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.modifierExtension\",\
		\"weight\": 4948,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.identifier\",\
		\"weight\": 4949,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.status\",\
		\"weight\": 4950,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.patient\",\
		\"weight\": 4951,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.type\",\
		\"weight\": 4952,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.quantity\",\
		\"weight\": 4953,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.suppliedItemCodeableConcept\",\
		\"weight\": 4954,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.suppliedItemReference\",\
		\"weight\": 4954,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.suppliedItemReference\",\
		\"weight\": 4954,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.suppliedItemReference\",\
		\"weight\": 4954,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.supplier\",\
		\"weight\": 4955,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.whenPrepared\",\
		\"weight\": 4956,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.time\",\
		\"weight\": 4957,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.destination\",\
		\"weight\": 4958,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyDelivery.receiver\",\
		\"weight\": 4959,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest\",\
		\"weight\": 4960,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.id\",\
		\"weight\": 4961,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.meta\",\
		\"weight\": 4962,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.implicitRules\",\
		\"weight\": 4963,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.language\",\
		\"weight\": 4964,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.text\",\
		\"weight\": 4965,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.contained\",\
		\"weight\": 4966,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.extension\",\
		\"weight\": 4967,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.modifierExtension\",\
		\"weight\": 4968,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.patient\",\
		\"weight\": 4969,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.source\",\
		\"weight\": 4970,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.date\",\
		\"weight\": 4971,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.identifier\",\
		\"weight\": 4972,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.status\",\
		\"weight\": 4973,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.kind\",\
		\"weight\": 4974,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.orderedItemCodeableConcept\",\
		\"weight\": 4975,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.orderedItemReference\",\
		\"weight\": 4975,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.orderedItemReference\",\
		\"weight\": 4975,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.orderedItemReference\",\
		\"weight\": 4975,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.supplier\",\
		\"weight\": 4976,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.reasonCodeableConcept\",\
		\"weight\": 4977,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.reasonReference\",\
		\"weight\": 4977,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.when\",\
		\"weight\": 4978,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.when.id\",\
		\"weight\": 4979,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.when.extension\",\
		\"weight\": 4980,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.when.modifierExtension\",\
		\"weight\": 4981,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.when.code\",\
		\"weight\": 4982,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"SupplyRequest.when.schedule\",\
		\"weight\": 4983,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task\",\
		\"weight\": 4984,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.id\",\
		\"weight\": 4985,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.meta\",\
		\"weight\": 4986,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.implicitRules\",\
		\"weight\": 4987,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.language\",\
		\"weight\": 4988,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.text\",\
		\"weight\": 4989,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.contained\",\
		\"weight\": 4990,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.extension\",\
		\"weight\": 4991,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.modifierExtension\",\
		\"weight\": 4992,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.identifier\",\
		\"weight\": 4993,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.basedOn\",\
		\"weight\": 4994,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.requisition\",\
		\"weight\": 4995,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.parent\",\
		\"weight\": 4996,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.status\",\
		\"weight\": 4997,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.statusReason\",\
		\"weight\": 4998,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.businessStatus\",\
		\"weight\": 4999,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.stage\",\
		\"weight\": 5000,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.code\",\
		\"weight\": 5001,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.priority\",\
		\"weight\": 5002,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.description\",\
		\"weight\": 5003,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.focus\",\
		\"weight\": 5004,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.for\",\
		\"weight\": 5005,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.context\",\
		\"weight\": 5006,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.created\",\
		\"weight\": 5007,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.lastModified\",\
		\"weight\": 5008,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.requester\",\
		\"weight\": 5009,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.owner\",\
		\"weight\": 5010,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.performerType\",\
		\"weight\": 5011,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.reason\",\
		\"weight\": 5012,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.note\",\
		\"weight\": 5013,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.fulfillment\",\
		\"weight\": 5014,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.fulfillment.id\",\
		\"weight\": 5015,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.fulfillment.extension\",\
		\"weight\": 5016,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.fulfillment.modifierExtension\",\
		\"weight\": 5017,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.fulfillment.repetitions\",\
		\"weight\": 5018,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.fulfillment.period\",\
		\"weight\": 5019,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.fulfillment.recipients\",\
		\"weight\": 5020,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.definition\",\
		\"weight\": 5021,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.input\",\
		\"weight\": 5022,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.input.id\",\
		\"weight\": 5023,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.input.extension\",\
		\"weight\": 5024,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.input.modifierExtension\",\
		\"weight\": 5025,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.type\",\
		\"weight\": 5026,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueBase64Binary\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueBoolean\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueCode\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueDate\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueDateTime\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueDecimal\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueId\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueInstant\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueInteger\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueMarkdown\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueOid\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valuePositiveInt\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueString\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueTime\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueUnsignedInt\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueUri\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueAddress\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueAge\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueAnnotation\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueAttachment\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueCodeableConcept\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueCoding\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueContactPoint\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueCount\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueDistance\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueDuration\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueHumanName\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueIdentifier\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueMoney\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valuePeriod\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueQuantity\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueRange\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueRatio\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueReference\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueSampledData\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueSignature\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueTiming\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.input.valueMeta\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.output\",\
		\"weight\": 5028,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.output.id\",\
		\"weight\": 5029,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.output.extension\",\
		\"weight\": 5030,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"Task.output.modifierExtension\",\
		\"weight\": 5031,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.type\",\
		\"weight\": 5032,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueBase64Binary\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueBoolean\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueCode\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueDate\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueDateTime\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueDecimal\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueId\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueInstant\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueInteger\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueMarkdown\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueOid\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valuePositiveInt\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueString\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueTime\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueUnsignedInt\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueUri\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueAddress\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueAge\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueAnnotation\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueAttachment\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueCodeableConcept\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueCoding\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueContactPoint\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueCount\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueDistance\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueDuration\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueHumanName\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueIdentifier\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueMoney\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valuePeriod\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueQuantity\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueRange\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueRatio\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueReference\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueSampledData\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueSignature\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueTiming\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"Task.output.valueMeta\",\
		\"weight\": 5033,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript\",\
		\"weight\": 5034,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.id\",\
		\"weight\": 5035,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.meta\",\
		\"weight\": 5036,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.implicitRules\",\
		\"weight\": 5037,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.language\",\
		\"weight\": 5038,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.text\",\
		\"weight\": 5039,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.contained\",\
		\"weight\": 5040,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.extension\",\
		\"weight\": 5041,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.modifierExtension\",\
		\"weight\": 5042,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.url\",\
		\"weight\": 5043,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.version\",\
		\"weight\": 5044,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.name\",\
		\"weight\": 5045,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.status\",\
		\"weight\": 5046,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.identifier\",\
		\"weight\": 5047,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.experimental\",\
		\"weight\": 5048,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.publisher\",\
		\"weight\": 5049,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.contact\",\
		\"weight\": 5050,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.contact.id\",\
		\"weight\": 5051,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.contact.extension\",\
		\"weight\": 5052,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.contact.modifierExtension\",\
		\"weight\": 5053,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.contact.name\",\
		\"weight\": 5054,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.contact.telecom\",\
		\"weight\": 5055,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.date\",\
		\"weight\": 5056,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.description\",\
		\"weight\": 5057,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.useContext\",\
		\"weight\": 5058,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.requirements\",\
		\"weight\": 5059,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.copyright\",\
		\"weight\": 5060,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.origin\",\
		\"weight\": 5061,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.origin.id\",\
		\"weight\": 5062,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.origin.extension\",\
		\"weight\": 5063,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.origin.modifierExtension\",\
		\"weight\": 5064,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.origin.index\",\
		\"weight\": 5065,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.origin.profile\",\
		\"weight\": 5066,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.destination\",\
		\"weight\": 5067,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.destination.id\",\
		\"weight\": 5068,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.destination.extension\",\
		\"weight\": 5069,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.destination.modifierExtension\",\
		\"weight\": 5070,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.destination.index\",\
		\"weight\": 5071,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.destination.profile\",\
		\"weight\": 5072,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata\",\
		\"weight\": 5073,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.id\",\
		\"weight\": 5074,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.extension\",\
		\"weight\": 5075,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.modifierExtension\",\
		\"weight\": 5076,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.link\",\
		\"weight\": 5077,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.link.id\",\
		\"weight\": 5078,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.link.extension\",\
		\"weight\": 5079,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.link.modifierExtension\",\
		\"weight\": 5080,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.metadata.link.url\",\
		\"weight\": 5081,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.link.description\",\
		\"weight\": 5082,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.metadata.capability\",\
		\"weight\": 5083,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.id\",\
		\"weight\": 5084,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.extension\",\
		\"weight\": 5085,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.modifierExtension\",\
		\"weight\": 5086,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.required\",\
		\"weight\": 5087,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.validated\",\
		\"weight\": 5088,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.description\",\
		\"weight\": 5089,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.origin\",\
		\"weight\": 5090,\
		\"max\": \"*\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.destination\",\
		\"weight\": 5091,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.metadata.capability.link\",\
		\"weight\": 5092,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.metadata.capability.conformance\",\
		\"weight\": 5093,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.fixture\",\
		\"weight\": 5094,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.fixture.id\",\
		\"weight\": 5095,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.fixture.extension\",\
		\"weight\": 5096,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.fixture.modifierExtension\",\
		\"weight\": 5097,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.fixture.autocreate\",\
		\"weight\": 5098,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.fixture.autodelete\",\
		\"weight\": 5099,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.fixture.resource\",\
		\"weight\": 5100,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.profile\",\
		\"weight\": 5101,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.variable\",\
		\"weight\": 5102,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.variable.id\",\
		\"weight\": 5103,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.variable.extension\",\
		\"weight\": 5104,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.variable.modifierExtension\",\
		\"weight\": 5105,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.variable.name\",\
		\"weight\": 5106,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.variable.defaultValue\",\
		\"weight\": 5107,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.variable.headerField\",\
		\"weight\": 5108,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.variable.path\",\
		\"weight\": 5109,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.variable.sourceId\",\
		\"weight\": 5110,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule\",\
		\"weight\": 5111,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule.id\",\
		\"weight\": 5112,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule.extension\",\
		\"weight\": 5113,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule.modifierExtension\",\
		\"weight\": 5114,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.rule.resource\",\
		\"weight\": 5115,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule.param\",\
		\"weight\": 5116,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule.param.id\",\
		\"weight\": 5117,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule.param.extension\",\
		\"weight\": 5118,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule.param.modifierExtension\",\
		\"weight\": 5119,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.rule.param.name\",\
		\"weight\": 5120,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.rule.param.value\",\
		\"weight\": 5121,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset\",\
		\"weight\": 5122,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.id\",\
		\"weight\": 5123,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.extension\",\
		\"weight\": 5124,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.modifierExtension\",\
		\"weight\": 5125,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.ruleset.resource\",\
		\"weight\": 5126,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.ruleset.rule\",\
		\"weight\": 5127,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.rule.id\",\
		\"weight\": 5128,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.rule.extension\",\
		\"weight\": 5129,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.rule.modifierExtension\",\
		\"weight\": 5130,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.ruleset.rule.ruleId\",\
		\"weight\": 5131,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.rule.param\",\
		\"weight\": 5132,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.rule.param.id\",\
		\"weight\": 5133,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.rule.param.extension\",\
		\"weight\": 5134,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.rule.param.modifierExtension\",\
		\"weight\": 5135,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.ruleset.rule.param.name\",\
		\"weight\": 5136,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.ruleset.rule.param.value\",\
		\"weight\": 5137,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup\",\
		\"weight\": 5138,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.id\",\
		\"weight\": 5139,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.extension\",\
		\"weight\": 5140,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.modifierExtension\",\
		\"weight\": 5141,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action\",\
		\"weight\": 5142,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.id\",\
		\"weight\": 5143,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.extension\",\
		\"weight\": 5144,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.modifierExtension\",\
		\"weight\": 5145,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation\",\
		\"weight\": 5146,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.id\",\
		\"weight\": 5147,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.extension\",\
		\"weight\": 5148,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.modifierExtension\",\
		\"weight\": 5149,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.type\",\
		\"weight\": 5150,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.resource\",\
		\"weight\": 5151,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.label\",\
		\"weight\": 5152,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.description\",\
		\"weight\": 5153,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.accept\",\
		\"weight\": 5154,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.contentType\",\
		\"weight\": 5155,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.destination\",\
		\"weight\": 5156,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.encodeRequestUrl\",\
		\"weight\": 5157,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.origin\",\
		\"weight\": 5158,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.params\",\
		\"weight\": 5159,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.requestHeader\",\
		\"weight\": 5160,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.requestHeader.id\",\
		\"weight\": 5161,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.requestHeader.extension\",\
		\"weight\": 5162,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.requestHeader.modifierExtension\",\
		\"weight\": 5163,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.operation.requestHeader.field\",\
		\"weight\": 5164,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.operation.requestHeader.value\",\
		\"weight\": 5165,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.responseId\",\
		\"weight\": 5166,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.sourceId\",\
		\"weight\": 5167,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.targetId\",\
		\"weight\": 5168,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.operation.url\",\
		\"weight\": 5169,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert\",\
		\"weight\": 5170,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.id\",\
		\"weight\": 5171,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.extension\",\
		\"weight\": 5172,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.modifierExtension\",\
		\"weight\": 5173,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.label\",\
		\"weight\": 5174,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.description\",\
		\"weight\": 5175,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.direction\",\
		\"weight\": 5176,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.compareToSourceId\",\
		\"weight\": 5177,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.compareToSourcePath\",\
		\"weight\": 5178,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.contentType\",\
		\"weight\": 5179,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.headerField\",\
		\"weight\": 5180,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.minimumId\",\
		\"weight\": 5181,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.navigationLinks\",\
		\"weight\": 5182,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.operator\",\
		\"weight\": 5183,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.path\",\
		\"weight\": 5184,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.requestURL\",\
		\"weight\": 5185,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.resource\",\
		\"weight\": 5186,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.response\",\
		\"weight\": 5187,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.responseCode\",\
		\"weight\": 5188,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.rule\",\
		\"weight\": 5189,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.rule.id\",\
		\"weight\": 5190,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.rule.extension\",\
		\"weight\": 5191,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.rule.modifierExtension\",\
		\"weight\": 5192,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.assert.rule.ruleId\",\
		\"weight\": 5193,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.rule.param\",\
		\"weight\": 5194,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.rule.param.id\",\
		\"weight\": 5195,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.rule.param.extension\",\
		\"weight\": 5196,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.rule.param.modifierExtension\",\
		\"weight\": 5197,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.assert.rule.param.name\",\
		\"weight\": 5198,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.assert.rule.param.value\",\
		\"weight\": 5199,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset\",\
		\"weight\": 5200,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.id\",\
		\"weight\": 5201,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.extension\",\
		\"weight\": 5202,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.modifierExtension\",\
		\"weight\": 5203,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rulesetId\",\
		\"weight\": 5204,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule\",\
		\"weight\": 5205,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.id\",\
		\"weight\": 5206,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.extension\",\
		\"weight\": 5207,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.modifierExtension\",\
		\"weight\": 5208,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.ruleId\",\
		\"weight\": 5209,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param\",\
		\"weight\": 5210,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.id\",\
		\"weight\": 5211,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.extension\",\
		\"weight\": 5212,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.modifierExtension\",\
		\"weight\": 5213,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.name\",\
		\"weight\": 5214,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.value\",\
		\"weight\": 5215,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.sourceId\",\
		\"weight\": 5216,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.validateProfileId\",\
		\"weight\": 5217,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.value\",\
		\"weight\": 5218,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.setup.action.assert.warningOnly\",\
		\"weight\": 5219,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test\",\
		\"weight\": 5220,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.id\",\
		\"weight\": 5221,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.extension\",\
		\"weight\": 5222,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.modifierExtension\",\
		\"weight\": 5223,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.name\",\
		\"weight\": 5224,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.description\",\
		\"weight\": 5225,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.test.action\",\
		\"weight\": 5226,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.action.id\",\
		\"weight\": 5227,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.action.extension\",\
		\"weight\": 5228,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.action.modifierExtension\",\
		\"weight\": 5229,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.action.operation\",\
		\"weight\": 5230,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.test.action.assert\",\
		\"weight\": 5231,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.teardown\",\
		\"weight\": 5232,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.teardown.id\",\
		\"weight\": 5233,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.teardown.extension\",\
		\"weight\": 5234,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.teardown.modifierExtension\",\
		\"weight\": 5235,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"TestScript.teardown.action\",\
		\"weight\": 5236,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.teardown.action.id\",\
		\"weight\": 5237,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.teardown.action.extension\",\
		\"weight\": 5238,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.teardown.action.modifierExtension\",\
		\"weight\": 5239,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"TestScript.teardown.action.operation\",\
		\"weight\": 5240,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription\",\
		\"weight\": 5241,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.id\",\
		\"weight\": 5242,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.meta\",\
		\"weight\": 5243,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.implicitRules\",\
		\"weight\": 5244,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.language\",\
		\"weight\": 5245,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.text\",\
		\"weight\": 5246,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.contained\",\
		\"weight\": 5247,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.extension\",\
		\"weight\": 5248,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.modifierExtension\",\
		\"weight\": 5249,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.identifier\",\
		\"weight\": 5250,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dateWritten\",\
		\"weight\": 5251,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.patient\",\
		\"weight\": 5252,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.prescriber\",\
		\"weight\": 5253,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.encounter\",\
		\"weight\": 5254,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.reasonCodeableConcept\",\
		\"weight\": 5255,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.reasonReference\",\
		\"weight\": 5255,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense\",\
		\"weight\": 5256,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.id\",\
		\"weight\": 5257,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.extension\",\
		\"weight\": 5258,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.modifierExtension\",\
		\"weight\": 5259,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": \"1\",\
		\"path\": \"VisionPrescription.dispense.product\",\
		\"weight\": 5260,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.eye\",\
		\"weight\": 5261,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.sphere\",\
		\"weight\": 5262,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.cylinder\",\
		\"weight\": 5263,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.axis\",\
		\"weight\": 5264,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.prism\",\
		\"weight\": 5265,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.base\",\
		\"weight\": 5266,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.add\",\
		\"weight\": 5267,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.power\",\
		\"weight\": 5268,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.backCurve\",\
		\"weight\": 5269,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.diameter\",\
		\"weight\": 5270,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.duration\",\
		\"weight\": 5271,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.color\",\
		\"weight\": 5272,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.brand\",\
		\"weight\": 5273,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": \"0\",\
		\"path\": \"VisionPrescription.dispense.notes\",\
		\"weight\": 5274,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	}\
]"function require_resource(t)return e[t]or error("resource '"..tostring(t).."' not found");end end
local e,v,t,h
if js and js.global then
h={}
h.dump=require("pure-xml-dump")
h.load=require("pure-xml-load")
t=require("lunajson")
package.loaded["cjson.safe"]={encode=function()end}
else
h=require("xml")
e=require("cjson")
v=require("datafile")
end
local L=require("resty.prettycjson")
local f,b,s,a,U,R,d,u,D
=ipairs,pairs,type,print,tonumber,string.gmatch,table.remove,string.format,table.sort
local r,y,S,w,o
local T,A,g,z
local _,E,q,k,j
local c,x,I
local N,m,O
local n
local i
local l,p
if e then
i=e.null
l,p=e.decode,e.encode
elseif t then
i=function()end
l=function(e)
return t.decode(e,nil,i)
end
p=function(e)
return t.encode(e,i)
end
else
error("neither cjson nor luajson libraries found for JSON parsing")
end
E=function(e)
local e=io.open(e,"r")
if e~=nil then io.close(e)return true else return false end
end
local H=(...and(...):match("(.+)%.[^%.]+$")or(...))or"(path of the script unknown)"
y=function(e)
local i={(e or""),"fhir-data/fhir-elements.json","src/fhir-data/fhir-elements.json","../src/fhir-data/fhir-elements.json","fhir-data/fhir-elements.json"}
local e
for a,t in f(i)do
if E(t)then
io.input(t)
e=l(io.read("*a"))
break
end
end
local t,o,a
if not e and v then
a=true
t,o=v.open("src/fhir-data/fhir-elements.json","r")
if t then e=l(t:read("*a"))end
end
if not e and require_resource then
e=l(require_resource("fhir-data/fhir-elements.json"))
end
assert(e,string.format("read_fhir_data: FHIR Schema could not be found in these locations starting from %s:  %s\n\n%s%s",H,table.concat(i,"\n  "),a and("Datafile could not find LuaRocks installation as well; error is: \n"..o)or'',require_resource and"Embedded JSON data could not be found as well."or''))
return e
end
S=function(e,a)
if not e then return nil end
for t=1,#e do
if e[t]==a then return t end
end
end
O=function(e,t)
if not e then return nil end
local a={}
if s(t)=="function"then
for o=1,#e do
local e=e[o]
a[e]=t(e)
end
else
for o=1,#e do
a[e[o]]=t
end
end
return a
end
slice=function(e,t,a)
local o={}
for t=(t and t or 1),(a and a or#e)do
o[t]=e[t]
end
return o
end
w=function(a)
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
e._kind=t.kind
e._derivations=O(t.derivations,function(e)return n[e]end)
i(e)
if s(n[t.type])=="table"then
e[1]=n[t.type]
end
end
i=function(e,t)
if not(e and e._derivations)then return end
local t=t and t._derivations or e._derivations
for a,t in b(t)do
if t._derivations then
for a,t in b(t._derivations)do
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
q=function(t,e)
return e(t)
end
k=function(e,t)
io.input(e)
local e=io.read("*a")
io.input():close()
return t(e)
end
o=function(o,e)
local i=e.value
local t=r(o,e.xml)
if not t then
a(string.format("Warning: %s is not a known FHIR element; couldn't check its FHIR type to decide the JSON type.",table.concat(o,".")))
return i
end
local t=t._type or t._type_json
if t=="boolean"then
if e.value=="true"then return true
elseif e.value=="false"then return false
else
a(string.format("Warning: %s.%s is of type %s in FHIR JSON - its XML value of %s is invalid.",table.concat(o),e.xml,t,e.value))
end
elseif t=="integer"or
t=="unsignedInt"or
t=="positiveInt"or
t=="decimal"then
return U(e.value)
else return i end
end
r=function(t,a)
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
j=function(n,i)
local e,t
local o=r(n,i)
if not o then
a(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.",table.concat(n,"."),i))
end
if o and o._max=="*"then
e={{}}
t=e[1]
else
e={}
t=e
end
return e,t
end
T=function(o,t)
local e=r(o,t)
if e==nil then
a(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.",table.concat(o,"."),t))
end
if e and e._max=="*"then
return"array"
end
return"object"
end
get_xml_weight=function(e,t)
local o=r(e,t)
if not o then
a(string.format("Warning: %s.%s is not a known FHIR element; won't be able to sort it properly in the XML output.",table.concat(e,"."),t))
return 0
else
return o._weight
end
end
get_datatype_kind=function(o,t)
local e=r(o,t)
if not e then
a(string.format("Warning: %s.%s is not a known FHIR element; might not convert it to a proper JSON 'element' or '_element' representation.",table.concat(o,"."),t))
return 0
else
local e=r({},e._type)
return e._kind
end
end
print_xml_value=function(e,a,n,s)
if not a[e.xml]then
local t
if T(n,e.xml)=="array"then
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
and get_datatype_kind(t,e.xml)~="complex-type"
then
if e.id then return true
else
for t=1,#e do
if e[t].xml=="extension"then return true end
end
end
end
end
A=function(e,a,l,o,h)
assert(e.xml,"error from parsed xml: node.xml is missing")
local n=a-1
local d=need_shadow_element(a,e,h)
local t
if a~=1 then
t=o[n][#o[n]]
end
if a==1 then
l.resourceType=e.xml
elseif h[#h]=="contained"or h[#h]=="resource"then
t.resourceType=e.xml
o[a]=o[a]or{}
o[a][#o[a]+1]=t
return
elseif e.value then
print_xml_value(e,t,h,d)
end
if s(e[1])=="table"and a~=1 then
local n,r
if s(t[e.xml])=="table"and not d then
local e=t[e.xml]
e[#e+1]={}
r=e[#e]
elseif not t[e.xml]and(e[1]or e.value)and not d then
n,r=j(h,e.xml)
t[e.xml]=n
end
if d then
n,r=j(h,e.xml)
local a=u('_%s',e.xml)
local o
if not t[a]then
t[a]=n
o=true
else
t[a][#t[a]+1]=r
end
local a=S(t[e.xml],e.value)
if o and a and a>1 then
n[1]=nil
for e=1,a-1 do
n[#n+1]=i
end
n[#n+1]={}
r=n[#n]
end
if not e.value and t[e.xml]then
if s(t[e.xml][#t[e.xml]])=="table"then
t[e.xml][#t[e.xml]]=nil
end
t[e.xml][#t[e.xml]+1]=i
end
end
o[a]=o[a]or{}
o[a][#o[a]+1]=r
end
if e.url then
o[a][#o[a]].url=e.url
end
if e.id then
o[a][#o[a]].id=e.id
end
return l
end
z=function(e,t,a)
e[a][#e[a]][t.xml]=h.dump(t)
end
g=function(e,t,o,i,a)
t=(t and(t+1)or 1)
o=A(e,t,o,i,a)
a[#a+1]=e.xml
for n,e in f(e)do
if e.xml=="div"and e.xmlns=="http://www.w3.org/1999/xhtml"then
z(i,e,t)
else
assert(s(e)=="table",u("unexpected type value encountered: %s (%s), expecting table",tostring(e),s(e)))
g(e,t,o,i,a)
end
end
d(a)
return o
end
_=function(a,e)
n=n or w(y())
assert(next(n),"convert_to_json: FHIR Schema could not be parsed in.")
local t
if e and e.file then
t=k(a,h.load)
else
t=q(a,h.load)
end
local a={}
local o={[1]={a}}
local i={}
local t=g(t,nil,a,o,i)
return(e and e.pretty)and L(t,nil,'  ',nil,p)
or p(t)
end
x=function(a,n,o,t,s)
if a:find("_",1,true)then return end
local e=o[#o]
if a=="div"then
e[#e+1]=h.load(n)
elseif a=="url"and(t[#t]=="extension"or t[#t]=="modifierExtension")then
e.url=n
elseif a=="id"then
local t=r(slice(t,1,#t-1),t[#t])._type
if t~="Resource"and t~="DomainResource"then
e.id=n
else
e[#e+1]={xml=a,value=tostring(n)}
end
elseif n==i then
e[#e+1]={xml=a}
else
e[#e+1]={xml=a,value=tostring(n)}
end
local i=e[#e]
if i then
i._weight=get_xml_weight(t,a)
i._count=#e
end
if s then
o[#o+1]=e[#e]
t[#t+1]=e[#e].xml
c(s,o,t)
d(o)
d(t)
end
end
m=function(i,n,e,a)
if i:find("_",1,true)then return end
local t=e[#e]
t[#t+1]={xml=i}
local o=t[#t]
o._weight=get_xml_weight(a,i)
o._count=#t
e[#e+1]=o
a[#a+1]=o.xml
c(n,e,a)
d(e)
d(a)
end
print_contained_resource=function(a,t,o)
local e=t[#t]
e[#e+1]={xml=a.resourceType,xmlns="http://hl7.org/fhir"}
t[#t+1]=e[#e]
o[#o+1]=e[#e].xml
a.resourceType=nil
end
c=function(n,t,o)
local h
if n.resourceType then
print_contained_resource(n,t,o)
h=true
end
for a,e in b(n)do
if s(e)=="table"then
if s(e[1])=="table"then
for n,e in f(e)do
if e~=i then
m(a,e,t,o)
end
end
elseif e[1]and s(e[1])~="table"then
for h,s in f(e)do
local n,e=n[u("_%s",a)]
if n then
e=n[h]
if e==i then e=nil end
end
x(a,s,t,o,e)
end
elseif e~=i then
m(a,e,t,o)
end
elseif e~=i then
x(a,e,t,o,n[u("_%s",a)])
end
if a:sub(1,1)=='_'and not n[a:sub(2)]then
m(a:sub(2),e,t,o)
end
end
local a=t[#t]
D(a,function(t,e)
return(t.xml==e.xml)and(t._count<e._count)or(t._weight<e._weight)
end)
for e=1,#a do
local e=a[e]
e._weight=nil
e._count=nil
end
if h then
d(t)
d(o)
end
end
I=function(e,a,o,t)
if e.resourceType then
a.xmlns="http://hl7.org/fhir"
a.xml=e.resourceType
e.resourceType=nil
t[#t+1]=a.xml
end
return c(e,o,t)
end
N=function(a,e)
n=n or w(y())
assert(next(n),"convert_to_xml: FHIR Schema could not be parsed in.")
local t
if e and e.file then
t=k(a,l)
else
t=q(a,l)
end
local e,o={},{}
local a={e}
I(t,e,a,o)
return h.dump(e)
end
w(y())
return{
to_json=_,
to_xml=N
}
