package.preload['lunajson._str_lib']=(function(...)
local e=math.huge
local c,h,u=string.byte,string.char,string.sub
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
local function l(d,n)
local i
if d=='u'then
local d,s,c,l=c(n,1,4)
local t=t[d-47]*4096+t[s-47]*256+t[c-47]*16+t[l-47]
if t==e then
r("invalid unicode charcode")
end
n=u(n,5)
if t<128 then
i=h(t)
elseif t<2048 then
i=h(192+o(t*.015625),128+t%64)
elseif t<55296 or 57344<=t then
i=h(224+o(t*.000244140625),128+o(t*.015625)%64,128+t%64)
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
i=h(240+o(t*3814697265625e-18),128+o(t*.000244140625)%64,128+o(t*.015625)%64,128+t%64)
end
end
end
if a~=0 then
r("invalid surrogate pair")
end
return(i or s[d])..n
end
local function e()
return a==0
end
return{
subst=l,
surrogateok=e
}
end
end)
package.preload['lunajson.decoder']=(function(...)
local y=error
local s,e,h,w,n,u=string.byte,string.char,string.find,string.gsub,string.match,string.sub
local l=tonumber
local r,f=tostring,setmetatable
local m
if _VERSION=="Lua 5.3"then
m=require'lunajson._str_lib_lua53'
else
m=require'lunajson._str_lib'
end
local e=nil
local function j()
local a,t,v,p
local d,o
local function i(e)
y("parse error at "..t..": "..e)
end
local function e()
i('invalid value')
end
local function q()
if u(a,t,t+2)=='ull'then
t=t+3
return v
end
i('invalid value')
end
local function j()
if u(a,t,t+3)=='alse'then
t=t+4
return false
end
i('invalid value')
end
local function x()
if u(a,t,t+2)=='rue'then
t=t+3
return true
end
i('invalid value')
end
local r=n(r(.5),'[^0-9]')
local c=l
if r~='.'then
if h(r,'%W')then
r='%'..r
end
c=function(e)
return l(w(e,'.',r))
end
end
local function l()
i('invalid number')
end
local function b(h)
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
e=c(e)
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
e=c(e)-0
if h then
e=-e
end
return e
end
local function k()
local e=s(a,t)
if e then
t=t+1
if e>48 then
if e<58 then
return r(true)
end
else
if e>47 then
return b(true)
end
end
end
i('invalid number')
end
local n=m(i)
local m=n.surrogateok
local g=n.subst
local c=f({},{__mode="v"})
local function l(d)
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
local e=c[a]
if e then
return e
end
end
local e=a
if h(e,'\\',1,true)then
e=w(e,'\\(.)([^\\]*)',g)
if not m()then
i("invalid surrogate pair")
end
end
if d then
c[a]=e
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
if p then
r[0]=n
end
return r
end
local function c()
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
local l=l(true)
o=e
do
local a,e,i=s(a,t,t+3)
if a==58 then
n=t
if e==32 then
n=n+1
e=i
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
e,e,l,e,e,e,e,e,e,e,e,e,e,k,e,e,
b,r,r,r,r,r,r,r,r,r,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,u,e,e,e,e,
e,e,e,e,e,e,j,e,e,e,e,e,e,e,q,e,
e,e,e,e,x,e,e,e,e,e,e,c,e,e,e,e,
}
d[0]=e
d.__index=function()
i("unexpected termination")
end
f(d,d)
local function r(r,e,i,n)
a,t,v,p=r,e,i,n
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
y('json ended')
end
return i
end
end
return r
end
return j
end)
package.preload['lunajson.encoder']=(function(...)
local n=error
local q,d,w,l,i=string.byte,string.find,string.format,string.gsub,string.match
local v=table.concat
local o=tostring
local p,r=pairs,type
local f=setmetatable
local y,b=1/0,-1/0
local h
if _VERSION=="Lua 5.1"then
h='[^ -!#-[%]^-\255]'
else
h='[\0-\31"\\]'
end
local e=nil
local function k()
local c,m
local e,t,s
local function g(a)
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
if b<i and i<y then
local i=w("%.17g",i)
if u then
if o then
i=l(i,o,'')
end
if a then
i=l(i,a,'.')
end
end
t[e]=i
e=e+1
return
end
n('invalid number')
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
return w('\\u00%02X',q(e))
end
}
f(o,o)
local function u(a)
t[e]='"'
if d(a,h)then
a=l(a,h,o)
end
t[e+1]=a
t[e+2]='"'
e=e+3
end
local function h(a)
if s[a]then
n("loop detected")
end
s[a]=true
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
local s=e
for a,o in p(a)do
if r(a)~='string'then
n("non-string key")
end
u(a)
t[e]=':'
e=e+1
i(o)
t[e]=','
e=e+1
end
if e>s then
e=e-1
end
t[e]='}'
end
end
e=e+1
s[a]=nil
end
local o={
boolean=g,
number=y,
string=u,
table=h,
__index=function()
n("invalid type value")
end
}
f(o,o)
function i(a)
if a==m then
t[e]='null'
e=e+1
return
end
return o[r(a)](a)
end
local function a(o,a)
c,m=o,a
e,t,s=1,{},{}
i(c)
return v(t)
end
return a
end
return k
end)
package.preload['lunajson.sax']=(function(...)
local k=error
local o,H,l,g,m,u=string.byte,string.char,string.find,string.gsub,string.match,string.sub
local q=tonumber
local R,r,O=tostring,type,table.unpack or unpack
local b
if _VERSION=="Lua 5.3"then
b=require'lunajson._str_lib_lua53'
else
b=require'lunajson._str_lib'
end
local e=nil
local function e()end
local function x(s,n)
local a,d
local i,t,y=0,1,0
local f,h
if r(s)=='string'then
a=s
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
a=s()
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
local N=n.startobject or e
local I=n.key or e
local S=n.endobject or e
local T=n.startarray or e
local A=n.endarray or e
local E=n.string or e
local v=n.number or e
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
local function s()
while true do
h,t=l(a,'^[ \n\r\t]*',t)
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
for i=1,e do
local e=j()
if o(a,i)~=e then
n("invalid char")
end
t=t+1
end
return i(s)
end
local function _()
if u(a,t,t+2)=='ull'then
t=t+3
return w(nil)
end
return c('ull',3,nil,w)
end
local function z()
if u(a,t,t+3)=='alse'then
t=t+4
return r(false)
end
return c('alse',4,false,r)
end
local function x()
if u(a,t,t+2)=='rue'then
t=t+3
return r(true)
end
return c('rue',3,true,r)
end
local r=m(R(.5),'[^0-9]')
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
local e=H(O(s))
e=w(e)-0
if h then
e=-e
end
return v(e)
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
return v(e)
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
return v(e)
end
local function w()
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
local c=b(n)
local m=c.surrogateok
local v=c.subst
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
e=g(e,'\\(.)([^\\]*)',v)
if not m()then
n("invalid surrogate pair")
end
end
if c then
return I(e)
end
return E(e)
end
local function m()
T()
s()
if o(a,t)~=93 then
local e
while true do
h=f[o(a,t)]
t=t+1
h()
h,e=l(a,'^[ \n\r\t]*,[ \n\r\t]*',t)
if not e then
h,e=l(a,'^[ \n\r\t]*%]',t)
if e then
t=e
break
end
s()
local a=o(a,t)
if a==44 then
t=t+1
s()
e=t-1
elseif a==93 then
break
else
n("no closing bracket of an array")
end
end
t=e+1
if t>i then
s()
end
end
end
t=t+1
return A()
end
local function v()
N()
s()
if o(a,t)~=125 then
local e
while true do
if o(a,t)~=34 then
n("not key")
end
t=t+1
c(true)
h,e=l(a,'^[ \n\r\t]*:[ \n\r\t]*',t)
if not e then
s()
if o(a,t)~=58 then
n("no colon after a key")
end
t=t+1
s()
e=t-1
end
t=e+1
if t>i then
s()
end
h=f[o(a,t)]
t=t+1
h()
h,e=l(a,'^[ \n\r\t]*,[ \n\r\t]*',t)
if not e then
h,e=l(a,'^[ \n\r\t]*}',t)
if e then
t=e
break
end
s()
local a=o(a,t)
if a==44 then
t=t+1
s()
e=t-1
elseif a==125 then
break
else
n("no closing bracket of an object")
end
end
t=e+1
if t>i then
s()
end
end
end
t=t+1
return S()
end
f={
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,c,e,e,e,e,e,e,e,e,e,e,w,e,e,
q,r,r,r,r,r,r,r,r,r,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,m,e,e,e,e,
e,e,e,e,e,e,z,e,e,e,e,e,e,e,_,e,
e,e,e,e,x,e,e,e,e,e,e,v,e,e,e,e,
}
f[0]=e
local function n()
s()
h=f[o(a,t)]
t=t+1
h()
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
local function o(e,o)
local e=io.open(e)
local function a()
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
return x(a,o)
end
return{
newparser=x,
newfileparser=o
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
local f={
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
function f:parser(e)
return{_call=e or self._call,parse=f.parse}
end
function f:parse(s,w)
if not w then w={stripWhitespace=false}end
local h,x,y,l,z,g,j=string.find,string.sub,string.gsub,string.char,table.insert,table.remove,table.concat
local e,a,o,i,t,v,m
local b=unpack or table.unpack
local t=1
local f="text"
local d=1
local r={}
local u={}
local c
local n={}
local k=false
local q={{2047,192},{65535,224},{2097151,240}}
local function p(e)
if e<128 then return l(e)end
local t={}
for a,o in ipairs(q)do
if e<=o[1]then
for o=a+1,2,-1 do
local a=e%64
e=(e-a)/64
t[o]=l(128+a)
end
t[1]=l(o[2]+e)
return j(t)
end
end
end
local l={["lt"]="<",["gt"]=">",["amp"]="&",["quot"]='"',["apos"]="'"}
local l=function(t,a,e)return l[e]or a=="#"and p(tonumber('0'..e))or t end
local function p(e)return y(e,'(&(#?)([%d%a]+);)',l)end
local function l()
if e>d and self._call.text then
local e=x(s,d,e-1)
if w.stripWhitespace then
e=y(e,'^%s+','')
e=y(e,'%s+$','')
if#e==0 then e=nil end
end
if e then self._call.text(p(e))end
end
end
local function x()
e,a,o,i=h(s,'^<%?([:%a_][:%w_.-]*) ?(.-)%?>',t)
if e then
l()
if self._call.pi then self._call.pi(o,i)end
t=a+1
d=t
return true
end
end
local function j()
e,a,o=h(s,'^<!%-%-(.-)%-%->',t)
if e then
l()
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
local function q()
k=true
e,a,o=h(s,'^<([%a_][%w_.-]*)',t)
if e then
r[2]=nil
r[3]=nil
l()
t=a+1
e,a,i=h(s,'^:([%a_][%w_.-]*)',t)
if e then
r[1]=i
r[3]=o
o=i
t=a+1
else
r[1]=o
for e=#n,1,-1 do if n[e]['!']then r[2]=n[e]['!'];break end end
end
c=0
z(n,{})
return true
end
end
local function y()
e,a,o=h(s,'^%s+([:%a_][:%w_.-]*)%s*=%s*',t)
if e then
v=a+1
e,a,i=h(s,'^"([^<"]*)"',v)
if e then
t=a+1
i=p(i)
else
e,a,i=h(s,"^'([^<']*)'",v)
if e then
t=a+1
i=p(i)
end
end
end
if o and i then
local e={o,i}
local t,a=string.match(o,'^([^:]+):([^:]+)$')
if t then
if t=='xmlns'then
n[#n][a]=i
else
e[1]=a
e[4]=t
end
else
if o=='xmlns'then
n[#n]['!']=i
r[2]=i
end
end
c=c+1
u[c]=e
return true
end
end
local function p()
e,a,o=h(s,'^<!%[CDATA%[(.-)%]%]>',t)
if e then
l()
if self._call.text then self._call.text(o)end
t=a+1
d=t
return true
end
end
local function v()
e,a,o=h(s,'^%s*(/?)>',t)
if e then
f="text"
t=a+1
d=t
if r[3]then r[2]=w(r[3])end
if self._call.startElement then self._call.startElement(b(r))end
if self._call.attribute then
for e=1,c do
if u[e][4]then u[e][3]=w(u[e][4])end
self._call.attribute(b(u[e]))
end
end
if o=="/"then
g(n)
if self._call.closeElement then self._call.closeElement(b(r))end
end
return true
end
end
local function r()
e,a,o,i=h(s,'^</([%a_][%w_.-]*)%s*>',t)
if e then
m=nil
for e=#n,1,-1 do if n[e]['!']then m=n[e]['!'];break end end
else
e,a,i,o=h(s,'^</([%a_][%w_.-]*):([%a_][%w_.-]*)%s*>',t)
if e then m=w(i)end
end
if e then
l()
if self._call.closeElement then self._call.closeElement(o,m)end
t=a+1
d=t
g(n)
return true
end
end
while t<#s do
if f=="text"then
if not(x()or j()or p()or r())then
if q()then
f="attributes"
else
e,a=h(s,'^[^<]+',t)
t=(e and a or t)+1
end
end
elseif f=="attributes"then
if not y()then
if not v()then
error("Was in an element and couldn't find attributes or the close.")
end
end
end
end
if not k then error("Parsing did not discover any elements")end
if#n>0 then error("Parsing ended with unclosed elements")end
end
return f
end)
package.preload['pure-xml-dump']=(function(...)
local c,o,a,n,
e,u=
ipairs,pairs,table.insert,type,
string.match,tostring
local function d(e)
if n(e)=='boolean'then
return e and'true'or'false'
else
return e:gsub('&','&amp;'):gsub('>','&gt;'):gsub('<','&lt;'):gsub("'",'&apos;')
end
end
local function l(e)
local t=e.xml or'table'
for e,a in o(e)do
if e~='xml'and n(e)=='string'then
t=t..' '..e.."='"..d(a).."'"
end
end
return t
end
local function r(o,i,t,e,h,s)
if h>s then
error(string.format("Could not dump table to XML. Maximal depth of %i reached.",s))
end
if o[1]then
a(t,(e=='n'and i or'')..'<'..l(o)..'>')
e='n'
local l=i..'  '
for i,o in c(o)do
local i=n(o)
if i=='table'then
r(o,l,t,e,h+1,s)
e='n'
elseif i=='number'then
a(t,u(o))
else
local o=d(o)
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
local function o(a,e)
local t=e or 3e3
local e={}
r(a,'\n',e,'s',1,t)
return table.concat(e,'')
end
return o
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
local h=function(o,a)
table.remove(e)
if a~=t[#t]then
t[#t]=nil
end
end
local s=function(t)
local e=e[#e]
e[#e+1]=t
end
local n=i:parser{
startElement=a,
attribute=n,
closeElement=h,
text=s
}
local function i(a)
o={}
e={o}
t={}
n:parse(a,{stripWhitespace=true})
return select(2,next(o))
end
return i
end)
package.preload['resty.prettycjson']=(function(...)
local t=require"cjson.safe".encode
local n=table.concat
local c=string.sub
local d=string.rep
return function(a,h,i,l,e)
local t,e=(e or t)(a)
if not t then return t,e end
h,i,l=h or"\n",i or"\t",l or" "
local e,a,u,m,o,s,r=1,0,0,#t,{},nil,nil
local f=c(l,-1)=="\n"
for m=1,m do
local t=c(t,m,m)
if not r and(t=="{"or t=="[")then
o[e]=s==":"and n{t,h}or n{d(i,a),t,h}
a=a+1
elseif not r and(t=="}"or t=="]")then
a=a-1
if s=="{"or s=="["then
e=e-1
o[e]=n{d(i,a),s,t}
else
o[e]=n{h,d(i,a),t}
end
elseif not r and t==","then
o[e]=n{t,h}
u=-1
elseif not r and t==":"then
o[e]=n{t,l}
if f then
e=e+1
o[e]=d(i,a)
end
else
if t=='"'and s~="\\"then
r=not r and true or nil
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
do local e={};
e["fhir-data/fhir-elements.json"]="[\
	{\
		\"min\": 0,\
		\"path\": \"Element\",\
		\"weight\": 1,\
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
			\"Dosage\",\
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
			\"RelatedArtifact\",\
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
		\"min\": 0,\
		\"path\": \"Element.id\",\
		\"weight\": 2,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Element.extension\",\
		\"weight\": 3,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BackboneElement\",\
		\"weight\": 4,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BackboneElement.id\",\
		\"weight\": 5,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BackboneElement.extension\",\
		\"weight\": 6,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BackboneElement.modifierExtension\",\
		\"weight\": 7,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"base64Binary\",\
		\"weight\": 8,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"base64Binary.id\",\
		\"weight\": 9,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"base64Binary.extension\",\
		\"weight\": 10,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"base64Binary.value\",\
		\"type_xml\": \"xsd:base64Binary\",\
		\"weight\": 11,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"boolean\",\
		\"weight\": 12,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"boolean.id\",\
		\"weight\": 13,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"boolean.extension\",\
		\"weight\": 14,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"boolean.value\",\
		\"type_xml\": \"xsd:boolean\",\
		\"weight\": 15,\
		\"max\": \"1\",\
		\"type_json\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"code\",\
		\"weight\": 16,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"code.id\",\
		\"weight\": 17,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"code.extension\",\
		\"weight\": 18,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"code.value\",\
		\"type_xml\": \"xsd:token\",\
		\"weight\": 19,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"date\",\
		\"weight\": 20,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"date.id\",\
		\"weight\": 21,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"date.extension\",\
		\"weight\": 22,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"date.value\",\
		\"type_xml\": \"xsd:gYear OR xsd:gYearMonth OR xsd:date\",\
		\"weight\": 23,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"dateTime\",\
		\"weight\": 24,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"dateTime.id\",\
		\"weight\": 25,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"dateTime.extension\",\
		\"weight\": 26,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"dateTime.value\",\
		\"type_xml\": \"xsd:gYear OR xsd:gYearMonth OR xsd:date OR xsd:dateTime\",\
		\"weight\": 27,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"decimal\",\
		\"weight\": 28,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"decimal.id\",\
		\"weight\": 29,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"decimal.extension\",\
		\"weight\": 30,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"decimal.value\",\
		\"type_xml\": \"xsd:decimal\",\
		\"weight\": 31,\
		\"max\": \"1\",\
		\"type_json\": \"number\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"id\",\
		\"weight\": 32,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"id.id\",\
		\"weight\": 33,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"id.extension\",\
		\"weight\": 34,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"id.value\",\
		\"type_xml\": \"xsd:string\",\
		\"weight\": 35,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"instant\",\
		\"weight\": 36,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"instant.id\",\
		\"weight\": 37,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"instant.extension\",\
		\"weight\": 38,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"instant.value\",\
		\"type_xml\": \"xsd:dateTime\",\
		\"weight\": 39,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"integer\",\
		\"weight\": 40,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"derivations\": [\
			\"positiveInt\",\
			\"unsignedInt\"\
		],\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"integer.id\",\
		\"weight\": 41,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"integer.extension\",\
		\"weight\": 42,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"integer.value\",\
		\"type_xml\": \"xsd:int\",\
		\"weight\": 43,\
		\"max\": \"1\",\
		\"type_json\": \"number\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"markdown\",\
		\"weight\": 44,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"markdown.id\",\
		\"weight\": 45,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"markdown.extension\",\
		\"weight\": 46,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"markdown.value\",\
		\"type_xml\": \"xsd:string\",\
		\"weight\": 47,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"oid\",\
		\"weight\": 48,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"oid.id\",\
		\"weight\": 49,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"oid.extension\",\
		\"weight\": 50,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"oid.value\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"weight\": 51,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"positiveInt\",\
		\"weight\": 52,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"positiveInt.id\",\
		\"weight\": 53,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"positiveInt.extension\",\
		\"weight\": 54,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"positiveInt.value\",\
		\"type_xml\": \"xsd:positiveInteger\",\
		\"weight\": 55,\
		\"max\": \"1\",\
		\"type_json\": \"number\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"string\",\
		\"weight\": 56,\
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
		\"min\": 0,\
		\"path\": \"string.id\",\
		\"weight\": 57,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"string.extension\",\
		\"weight\": 58,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"string.value\",\
		\"type_xml\": \"xsd:string\",\
		\"weight\": 59,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"time\",\
		\"weight\": 60,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"time.id\",\
		\"weight\": 61,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"time.extension\",\
		\"weight\": 62,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"time.value\",\
		\"type_xml\": \"xsd:time\",\
		\"weight\": 63,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"unsignedInt\",\
		\"weight\": 64,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"unsignedInt.id\",\
		\"weight\": 65,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"unsignedInt.extension\",\
		\"weight\": 66,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"unsignedInt.value\",\
		\"type_xml\": \"xsd:nonNegativeInteger\",\
		\"weight\": 67,\
		\"max\": \"1\",\
		\"type_json\": \"number\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"uri\",\
		\"weight\": 68,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"derivations\": [\
			\"oid\",\
			\"uuid\"\
		],\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"uri.id\",\
		\"weight\": 69,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"uri.extension\",\
		\"weight\": 70,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"uri.value\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"weight\": 71,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"uuid\",\
		\"weight\": 72,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"uuid.id\",\
		\"weight\": 73,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"uuid.extension\",\
		\"weight\": 74,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"uuid.value\",\
		\"type_xml\": \"xsd:anyURI\",\
		\"weight\": 75,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"xhtml\",\
		\"weight\": 76,\
		\"max\": \"*\",\
		\"kind\": \"primitive-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"xhtml.id\",\
		\"weight\": 77,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"xhtml.extension\",\
		\"weight\": 78,\
		\"max\": \"0\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"xhtml.value\",\
		\"type_xml\": \"xhtml:div\",\
		\"weight\": 79,\
		\"max\": \"1\",\
		\"type_json\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address\",\
		\"weight\": 80,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.id\",\
		\"weight\": 81,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.extension\",\
		\"weight\": 82,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.use\",\
		\"weight\": 83,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.type\",\
		\"weight\": 84,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.text\",\
		\"weight\": 85,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.line\",\
		\"weight\": 86,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.city\",\
		\"weight\": 87,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.district\",\
		\"weight\": 88,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.state\",\
		\"weight\": 89,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.postalCode\",\
		\"weight\": 90,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.country\",\
		\"weight\": 91,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Address.period\",\
		\"weight\": 92,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Age\",\
		\"weight\": 93,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Age.id\",\
		\"weight\": 94,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Age.extension\",\
		\"weight\": 95,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Age.value\",\
		\"weight\": 96,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Age.comparator\",\
		\"weight\": 97,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Age.unit\",\
		\"weight\": 98,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Age.system\",\
		\"weight\": 99,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Age.code\",\
		\"weight\": 100,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Annotation\",\
		\"weight\": 101,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Annotation.id\",\
		\"weight\": 102,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Annotation.extension\",\
		\"weight\": 103,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 104,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 104,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 104,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Annotation.authorString\",\
		\"weight\": 104,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Annotation.time\",\
		\"weight\": 105,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Annotation.text\",\
		\"weight\": 106,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment\",\
		\"weight\": 107,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.id\",\
		\"weight\": 108,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.extension\",\
		\"weight\": 109,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.contentType\",\
		\"weight\": 110,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.language\",\
		\"weight\": 111,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.data\",\
		\"weight\": 112,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.url\",\
		\"weight\": 113,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.size\",\
		\"weight\": 114,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.hash\",\
		\"weight\": 115,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.title\",\
		\"weight\": 116,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Attachment.creation\",\
		\"weight\": 117,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeableConcept\",\
		\"weight\": 118,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeableConcept.id\",\
		\"weight\": 119,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeableConcept.extension\",\
		\"weight\": 120,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeableConcept.coding\",\
		\"weight\": 121,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeableConcept.text\",\
		\"weight\": 122,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coding\",\
		\"weight\": 123,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coding.id\",\
		\"weight\": 124,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coding.extension\",\
		\"weight\": 125,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coding.system\",\
		\"weight\": 126,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coding.version\",\
		\"weight\": 127,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coding.code\",\
		\"weight\": 128,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coding.display\",\
		\"weight\": 129,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coding.userSelected\",\
		\"weight\": 130,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactDetail\",\
		\"weight\": 131,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactDetail.id\",\
		\"weight\": 132,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactDetail.extension\",\
		\"weight\": 133,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactDetail.name\",\
		\"weight\": 134,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactDetail.telecom\",\
		\"weight\": 135,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactPoint\",\
		\"weight\": 136,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactPoint.id\",\
		\"weight\": 137,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactPoint.extension\",\
		\"weight\": 138,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactPoint.system\",\
		\"weight\": 139,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactPoint.value\",\
		\"weight\": 140,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactPoint.use\",\
		\"weight\": 141,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactPoint.rank\",\
		\"weight\": 142,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ContactPoint.period\",\
		\"weight\": 143,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contributor\",\
		\"weight\": 144,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contributor.id\",\
		\"weight\": 145,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contributor.extension\",\
		\"weight\": 146,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contributor.type\",\
		\"weight\": 147,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contributor.name\",\
		\"weight\": 148,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contributor.contact\",\
		\"weight\": 149,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Count\",\
		\"weight\": 150,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Count.id\",\
		\"weight\": 151,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Count.extension\",\
		\"weight\": 152,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Count.value\",\
		\"weight\": 153,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Count.comparator\",\
		\"weight\": 154,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Count.unit\",\
		\"weight\": 155,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Count.system\",\
		\"weight\": 156,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Count.code\",\
		\"weight\": 157,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement\",\
		\"weight\": 158,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.id\",\
		\"weight\": 159,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.extension\",\
		\"weight\": 160,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DataRequirement.type\",\
		\"weight\": 161,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.profile\",\
		\"weight\": 162,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.mustSupport\",\
		\"weight\": 163,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.codeFilter\",\
		\"weight\": 164,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.codeFilter.id\",\
		\"weight\": 165,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.codeFilter.extension\",\
		\"weight\": 166,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DataRequirement.codeFilter.path\",\
		\"weight\": 167,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.codeFilter.valueSetString\",\
		\"weight\": 168,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.codeFilter.valueSetReference\",\
		\"weight\": 168,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.codeFilter.valueCode\",\
		\"weight\": 169,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.codeFilter.valueCoding\",\
		\"weight\": 170,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.codeFilter.valueCodeableConcept\",\
		\"weight\": 171,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.dateFilter\",\
		\"weight\": 172,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.dateFilter.id\",\
		\"weight\": 173,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.dateFilter.extension\",\
		\"weight\": 174,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DataRequirement.dateFilter.path\",\
		\"weight\": 175,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.dateFilter.valueDateTime\",\
		\"weight\": 176,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.dateFilter.valuePeriod\",\
		\"weight\": 176,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataRequirement.dateFilter.valueDuration\",\
		\"weight\": 176,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Distance\",\
		\"weight\": 177,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Distance.id\",\
		\"weight\": 178,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Distance.extension\",\
		\"weight\": 179,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Distance.value\",\
		\"weight\": 180,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Distance.comparator\",\
		\"weight\": 181,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Distance.unit\",\
		\"weight\": 182,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Distance.system\",\
		\"weight\": 183,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Distance.code\",\
		\"weight\": 184,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage\",\
		\"weight\": 185,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.id\",\
		\"weight\": 186,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.extension\",\
		\"weight\": 187,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.sequence\",\
		\"weight\": 188,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.text\",\
		\"weight\": 189,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.additionalInstruction\",\
		\"weight\": 190,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.patientInstruction\",\
		\"weight\": 191,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.timing\",\
		\"weight\": 192,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.asNeededBoolean\",\
		\"weight\": 193,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.asNeededCodeableConcept\",\
		\"weight\": 193,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.site\",\
		\"weight\": 194,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.route\",\
		\"weight\": 195,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.method\",\
		\"weight\": 196,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.doseRange\",\
		\"weight\": 197,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.doseQuantity\",\
		\"weight\": 197,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.maxDosePerPeriod\",\
		\"weight\": 198,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.maxDosePerAdministration\",\
		\"weight\": 199,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.maxDosePerLifetime\",\
		\"weight\": 200,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.rateRatio\",\
		\"weight\": 201,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.rateRange\",\
		\"weight\": 201,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Dosage.rateQuantity\",\
		\"weight\": 201,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Duration\",\
		\"weight\": 202,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Duration.id\",\
		\"weight\": 203,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Duration.extension\",\
		\"weight\": 204,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Duration.value\",\
		\"weight\": 205,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Duration.comparator\",\
		\"weight\": 206,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Duration.unit\",\
		\"weight\": 207,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Duration.system\",\
		\"weight\": 208,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Duration.code\",\
		\"weight\": 209,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition\",\
		\"weight\": 210,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.id\",\
		\"weight\": 211,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.extension\",\
		\"weight\": 212,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.path\",\
		\"weight\": 213,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.representation\",\
		\"weight\": 214,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.sliceName\",\
		\"weight\": 215,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.label\",\
		\"weight\": 216,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.code\",\
		\"weight\": 217,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.slicing\",\
		\"weight\": 218,\
		\"max\": \"1\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.slicing.id\",\
		\"weight\": 219,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.slicing.extension\",\
		\"weight\": 220,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.slicing.discriminator\",\
		\"weight\": 221,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.slicing.discriminator.id\",\
		\"weight\": 222,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.slicing.discriminator.extension\",\
		\"weight\": 223,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.slicing.discriminator.type\",\
		\"weight\": 224,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.slicing.discriminator.path\",\
		\"weight\": 225,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.slicing.description\",\
		\"weight\": 226,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.slicing.ordered\",\
		\"weight\": 227,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.slicing.rules\",\
		\"weight\": 228,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.short\",\
		\"weight\": 229,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.definition\",\
		\"weight\": 230,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.comment\",\
		\"weight\": 231,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.requirements\",\
		\"weight\": 232,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.alias\",\
		\"weight\": 233,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.min\",\
		\"weight\": 234,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.max\",\
		\"weight\": 235,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.base\",\
		\"weight\": 236,\
		\"max\": \"1\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.base.id\",\
		\"weight\": 237,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.base.extension\",\
		\"weight\": 238,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.base.path\",\
		\"weight\": 239,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.base.min\",\
		\"weight\": 240,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.base.max\",\
		\"weight\": 241,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.contentReference\",\
		\"weight\": 242,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.type\",\
		\"weight\": 243,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.type.id\",\
		\"weight\": 244,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.type.extension\",\
		\"weight\": 245,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.type.code\",\
		\"weight\": 246,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.type.profile\",\
		\"weight\": 247,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.type.targetProfile\",\
		\"weight\": 248,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.type.aggregation\",\
		\"weight\": 249,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.type.versioning\",\
		\"weight\": 250,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueBase64Binary\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueBoolean\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueCode\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueDate\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueDateTime\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueDecimal\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueId\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueInstant\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueInteger\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueMarkdown\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueOid\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValuePositiveInt\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueString\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueTime\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueUnsignedInt\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueUri\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueAddress\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueAge\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueAnnotation\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueAttachment\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueCodeableConcept\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueCoding\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueContactPoint\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueCount\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueDistance\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueDuration\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueHumanName\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueIdentifier\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueMoney\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValuePeriod\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueQuantity\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueRange\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueRatio\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueReference\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueSampledData\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueSignature\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueTiming\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.defaultValueMeta\",\
		\"weight\": 251,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.meaningWhenMissing\",\
		\"weight\": 252,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.orderMeaning\",\
		\"weight\": 253,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedBase64Binary\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedBoolean\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedCode\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedDate\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedDateTime\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedDecimal\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedId\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedInstant\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedInteger\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedMarkdown\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedOid\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedPositiveInt\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedString\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedTime\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedUnsignedInt\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedUri\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedAddress\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedAge\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedAnnotation\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedAttachment\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedCodeableConcept\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedCoding\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedContactPoint\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedCount\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedDistance\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedDuration\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedHumanName\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedIdentifier\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedMoney\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedPeriod\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedQuantity\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedRange\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedRatio\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedReference\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedSampledData\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedSignature\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedTiming\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.fixedMeta\",\
		\"weight\": 254,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternBase64Binary\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternBoolean\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternCode\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternDate\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternDateTime\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternDecimal\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternId\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternInstant\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternInteger\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternMarkdown\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternOid\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternPositiveInt\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternString\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternTime\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternUnsignedInt\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternUri\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternAddress\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternAge\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternAnnotation\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternAttachment\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternCodeableConcept\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternCoding\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternContactPoint\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternCount\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternDistance\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternDuration\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternHumanName\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternIdentifier\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternMoney\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternPeriod\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternQuantity\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternRange\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternRatio\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternReference\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternSampledData\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternSignature\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternTiming\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.patternMeta\",\
		\"weight\": 255,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.example\",\
		\"weight\": 256,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.example.id\",\
		\"weight\": 257,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.example.extension\",\
		\"weight\": 258,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.label\",\
		\"weight\": 259,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueBase64Binary\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueBoolean\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueCode\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueDate\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueDateTime\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueDecimal\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueId\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueInstant\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueInteger\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueMarkdown\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueOid\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valuePositiveInt\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueString\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueTime\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueUnsignedInt\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueUri\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueAddress\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueAge\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueAnnotation\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueAttachment\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueCodeableConcept\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueCoding\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueContactPoint\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueCount\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueDistance\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueDuration\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueHumanName\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueIdentifier\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueMoney\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valuePeriod\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueQuantity\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueRange\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueRatio\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueReference\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueSampledData\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueSignature\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueTiming\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.example.valueMeta\",\
		\"weight\": 260,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValueDate\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValueDateTime\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValueInstant\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValueTime\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValueDecimal\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValueInteger\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValuePositiveInt\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValueUnsignedInt\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.minValueQuantity\",\
		\"weight\": 261,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValueDate\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValueDateTime\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValueInstant\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValueTime\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValueDecimal\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValueInteger\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValuePositiveInt\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValueUnsignedInt\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxValueQuantity\",\
		\"weight\": 262,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.maxLength\",\
		\"weight\": 263,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.condition\",\
		\"weight\": 264,\
		\"max\": \"*\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.constraint\",\
		\"weight\": 265,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.constraint.id\",\
		\"weight\": 266,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.constraint.extension\",\
		\"weight\": 267,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.constraint.key\",\
		\"weight\": 268,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.constraint.requirements\",\
		\"weight\": 269,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.constraint.severity\",\
		\"weight\": 270,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.constraint.human\",\
		\"weight\": 271,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.constraint.expression\",\
		\"weight\": 272,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.constraint.xpath\",\
		\"weight\": 273,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.constraint.source\",\
		\"weight\": 274,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.mustSupport\",\
		\"weight\": 275,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.isModifier\",\
		\"weight\": 276,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.isSummary\",\
		\"weight\": 277,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.binding\",\
		\"weight\": 278,\
		\"max\": \"1\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.binding.id\",\
		\"weight\": 279,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.binding.extension\",\
		\"weight\": 280,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.binding.strength\",\
		\"weight\": 281,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.binding.description\",\
		\"weight\": 282,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.binding.valueSetUri\",\
		\"weight\": 283,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.binding.valueSetReference\",\
		\"weight\": 283,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.mapping\",\
		\"weight\": 284,\
		\"max\": \"*\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.mapping.id\",\
		\"weight\": 285,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.mapping.extension\",\
		\"weight\": 286,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.mapping.identity\",\
		\"weight\": 287,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.mapping.language\",\
		\"weight\": 288,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ElementDefinition.mapping.map\",\
		\"weight\": 289,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ElementDefinition.mapping.comment\",\
		\"weight\": 290,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension\",\
		\"weight\": 291,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.id\",\
		\"weight\": 292,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.extension\",\
		\"weight\": 293,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Extension.url\",\
		\"weight\": 294,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueBase64Binary\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueBoolean\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueCode\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueDate\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueDateTime\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueDecimal\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueId\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueInstant\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueInteger\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueMarkdown\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueOid\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valuePositiveInt\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueString\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueTime\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueUnsignedInt\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueUri\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueAddress\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueAge\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueAnnotation\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueAttachment\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueCodeableConcept\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueCoding\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueContactPoint\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueCount\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueDistance\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueDuration\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueHumanName\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueIdentifier\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueMoney\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valuePeriod\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueQuantity\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueRange\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueRatio\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueReference\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueSampledData\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueSignature\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueTiming\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Extension.valueMeta\",\
		\"weight\": 295,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName\",\
		\"weight\": 296,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.id\",\
		\"weight\": 297,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.extension\",\
		\"weight\": 298,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.use\",\
		\"weight\": 299,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.text\",\
		\"weight\": 300,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.family\",\
		\"weight\": 301,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.given\",\
		\"weight\": 302,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.prefix\",\
		\"weight\": 303,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.suffix\",\
		\"weight\": 304,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HumanName.period\",\
		\"weight\": 305,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier\",\
		\"weight\": 306,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier.id\",\
		\"weight\": 307,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier.extension\",\
		\"weight\": 308,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier.use\",\
		\"weight\": 309,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier.type\",\
		\"weight\": 310,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier.system\",\
		\"weight\": 311,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier.value\",\
		\"weight\": 312,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier.period\",\
		\"weight\": 313,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Identifier.assigner\",\
		\"weight\": 314,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Meta\",\
		\"weight\": 315,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Meta.id\",\
		\"weight\": 316,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Meta.extension\",\
		\"weight\": 317,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Meta.versionId\",\
		\"weight\": 318,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Meta.lastUpdated\",\
		\"weight\": 319,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Meta.profile\",\
		\"weight\": 320,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Meta.security\",\
		\"weight\": 321,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Meta.tag\",\
		\"weight\": 322,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Money\",\
		\"weight\": 323,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Money.id\",\
		\"weight\": 324,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Money.extension\",\
		\"weight\": 325,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Money.value\",\
		\"weight\": 326,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Money.comparator\",\
		\"weight\": 327,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Money.unit\",\
		\"weight\": 328,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Money.system\",\
		\"weight\": 329,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Money.code\",\
		\"weight\": 330,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Narrative\",\
		\"weight\": 331,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Narrative.id\",\
		\"weight\": 332,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Narrative.extension\",\
		\"weight\": 333,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Narrative.status\",\
		\"weight\": 334,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Narrative.div\",\
		\"weight\": 335,\
		\"max\": \"1\",\
		\"type\": \"xhtml\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ParameterDefinition\",\
		\"weight\": 336,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ParameterDefinition.id\",\
		\"weight\": 337,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ParameterDefinition.extension\",\
		\"weight\": 338,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ParameterDefinition.name\",\
		\"weight\": 339,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ParameterDefinition.use\",\
		\"weight\": 340,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ParameterDefinition.min\",\
		\"weight\": 341,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ParameterDefinition.max\",\
		\"weight\": 342,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ParameterDefinition.documentation\",\
		\"weight\": 343,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ParameterDefinition.type\",\
		\"weight\": 344,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ParameterDefinition.profile\",\
		\"weight\": 345,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Period\",\
		\"weight\": 346,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Period.id\",\
		\"weight\": 347,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Period.extension\",\
		\"weight\": 348,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Period.start\",\
		\"weight\": 349,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Period.end\",\
		\"weight\": 350,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Quantity\",\
		\"weight\": 351,\
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
		\"min\": 0,\
		\"path\": \"Quantity.id\",\
		\"weight\": 352,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Quantity.extension\",\
		\"weight\": 353,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Quantity.value\",\
		\"weight\": 354,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Quantity.comparator\",\
		\"weight\": 355,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Quantity.unit\",\
		\"weight\": 356,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Quantity.system\",\
		\"weight\": 357,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Quantity.code\",\
		\"weight\": 358,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Range\",\
		\"weight\": 359,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Range.id\",\
		\"weight\": 360,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Range.extension\",\
		\"weight\": 361,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Range.low\",\
		\"weight\": 362,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Range.high\",\
		\"weight\": 363,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Ratio\",\
		\"weight\": 364,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Ratio.id\",\
		\"weight\": 365,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Ratio.extension\",\
		\"weight\": 366,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Ratio.numerator\",\
		\"weight\": 367,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Ratio.denominator\",\
		\"weight\": 368,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Reference\",\
		\"weight\": 369,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Reference.id\",\
		\"weight\": 370,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Reference.extension\",\
		\"weight\": 371,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Reference.reference\",\
		\"weight\": 372,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Reference.identifier\",\
		\"weight\": 373,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Reference.display\",\
		\"weight\": 374,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedArtifact\",\
		\"weight\": 375,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedArtifact.id\",\
		\"weight\": 376,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedArtifact.extension\",\
		\"weight\": 377,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RelatedArtifact.type\",\
		\"weight\": 378,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedArtifact.display\",\
		\"weight\": 379,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedArtifact.citation\",\
		\"weight\": 380,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedArtifact.url\",\
		\"weight\": 381,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedArtifact.document\",\
		\"weight\": 382,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedArtifact.resource\",\
		\"weight\": 383,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SampledData\",\
		\"weight\": 384,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SampledData.id\",\
		\"weight\": 385,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SampledData.extension\",\
		\"weight\": 386,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SampledData.origin\",\
		\"weight\": 387,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SampledData.period\",\
		\"weight\": 388,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SampledData.factor\",\
		\"weight\": 389,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SampledData.lowerLimit\",\
		\"weight\": 390,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SampledData.upperLimit\",\
		\"weight\": 391,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SampledData.dimensions\",\
		\"weight\": 392,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SampledData.data\",\
		\"weight\": 393,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature\",\
		\"weight\": 394,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.id\",\
		\"weight\": 395,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.extension\",\
		\"weight\": 396,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Signature.type\",\
		\"weight\": 397,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Signature.when\",\
		\"weight\": 398,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Signature.whoUri\",\
		\"weight\": 399,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 399,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 399,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 399,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 399,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 399,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.onBehalfOfUri\",\
		\"weight\": 400,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 400,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 400,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 400,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 400,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.onBehalfOfReference\",\
		\"weight\": 400,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.contentType\",\
		\"weight\": 401,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Signature.blob\",\
		\"weight\": 402,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing\",\
		\"weight\": 403,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.id\",\
		\"weight\": 404,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.extension\",\
		\"weight\": 405,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.event\",\
		\"weight\": 406,\
		\"max\": \"*\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat\",\
		\"weight\": 407,\
		\"max\": \"1\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.id\",\
		\"weight\": 408,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.extension\",\
		\"weight\": 409,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.boundsDuration\",\
		\"weight\": 410,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.boundsRange\",\
		\"weight\": 410,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.boundsPeriod\",\
		\"weight\": 410,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.count\",\
		\"weight\": 411,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.countMax\",\
		\"weight\": 412,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.duration\",\
		\"weight\": 413,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.durationMax\",\
		\"weight\": 414,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.durationUnit\",\
		\"weight\": 415,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.frequency\",\
		\"weight\": 416,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.frequencyMax\",\
		\"weight\": 417,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.period\",\
		\"weight\": 418,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.periodMax\",\
		\"weight\": 419,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.periodUnit\",\
		\"weight\": 420,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.dayOfWeek\",\
		\"weight\": 421,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.timeOfDay\",\
		\"weight\": 422,\
		\"max\": \"*\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.when\",\
		\"weight\": 423,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.repeat.offset\",\
		\"weight\": 424,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Timing.code\",\
		\"weight\": 425,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition\",\
		\"weight\": 426,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition.id\",\
		\"weight\": 427,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition.extension\",\
		\"weight\": 428,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TriggerDefinition.type\",\
		\"weight\": 429,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition.eventName\",\
		\"weight\": 430,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition.eventTimingTiming\",\
		\"weight\": 431,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition.eventTimingReference\",\
		\"weight\": 431,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition.eventTimingDate\",\
		\"weight\": 431,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition.eventTimingDateTime\",\
		\"weight\": 431,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TriggerDefinition.eventData\",\
		\"weight\": 432,\
		\"max\": \"1\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"UsageContext\",\
		\"weight\": 433,\
		\"max\": \"*\",\
		\"kind\": \"complex-type\",\
		\"type\": \"Element\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"UsageContext.id\",\
		\"weight\": 434,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"UsageContext.extension\",\
		\"weight\": 435,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"UsageContext.code\",\
		\"weight\": 436,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"UsageContext.valueCodeableConcept\",\
		\"weight\": 437,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"UsageContext.valueQuantity\",\
		\"weight\": 437,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"UsageContext.valueRange\",\
		\"weight\": 437,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Resource\",\
		\"weight\": 438,\
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
		\"min\": 0,\
		\"path\": \"Resource.id\",\
		\"weight\": 439,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Resource.meta\",\
		\"weight\": 440,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Resource.implicitRules\",\
		\"weight\": 441,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Resource.language\",\
		\"weight\": 442,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account\",\
		\"weight\": 443,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.id\",\
		\"weight\": 444,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.meta\",\
		\"weight\": 445,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.implicitRules\",\
		\"weight\": 446,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.language\",\
		\"weight\": 447,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.text\",\
		\"weight\": 448,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.contained\",\
		\"weight\": 449,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.extension\",\
		\"weight\": 450,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.modifierExtension\",\
		\"weight\": 451,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.identifier\",\
		\"weight\": 452,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.status\",\
		\"weight\": 453,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.type\",\
		\"weight\": 454,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.name\",\
		\"weight\": 455,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.subject\",\
		\"weight\": 456,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.period\",\
		\"weight\": 457,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.active\",\
		\"weight\": 458,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.balance\",\
		\"weight\": 459,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.coverage\",\
		\"weight\": 460,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.coverage.id\",\
		\"weight\": 461,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.coverage.extension\",\
		\"weight\": 462,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.coverage.modifierExtension\",\
		\"weight\": 463,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Account.coverage.coverage\",\
		\"weight\": 464,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.coverage.priority\",\
		\"weight\": 465,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.owner\",\
		\"weight\": 466,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.description\",\
		\"weight\": 467,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.guarantor\",\
		\"weight\": 468,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.guarantor.id\",\
		\"weight\": 469,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.guarantor.extension\",\
		\"weight\": 470,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.guarantor.modifierExtension\",\
		\"weight\": 471,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Account.guarantor.party\",\
		\"weight\": 472,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.guarantor.onHold\",\
		\"weight\": 473,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Account.guarantor.period\",\
		\"weight\": 474,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition\",\
		\"weight\": 475,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.id\",\
		\"weight\": 476,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.meta\",\
		\"weight\": 477,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.implicitRules\",\
		\"weight\": 478,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.language\",\
		\"weight\": 479,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.text\",\
		\"weight\": 480,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.contained\",\
		\"weight\": 481,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.extension\",\
		\"weight\": 482,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.modifierExtension\",\
		\"weight\": 483,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.url\",\
		\"weight\": 484,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.identifier\",\
		\"weight\": 485,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.version\",\
		\"weight\": 486,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.name\",\
		\"weight\": 487,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.title\",\
		\"weight\": 488,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ActivityDefinition.status\",\
		\"weight\": 489,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.experimental\",\
		\"weight\": 490,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.date\",\
		\"weight\": 491,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.publisher\",\
		\"weight\": 492,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.description\",\
		\"weight\": 493,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.purpose\",\
		\"weight\": 494,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.usage\",\
		\"weight\": 495,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.approvalDate\",\
		\"weight\": 496,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.lastReviewDate\",\
		\"weight\": 497,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.effectivePeriod\",\
		\"weight\": 498,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.useContext\",\
		\"weight\": 499,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.jurisdiction\",\
		\"weight\": 500,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.topic\",\
		\"weight\": 501,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.contributor\",\
		\"weight\": 502,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.contact\",\
		\"weight\": 503,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.copyright\",\
		\"weight\": 504,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.relatedArtifact\",\
		\"weight\": 505,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.library\",\
		\"weight\": 506,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.kind\",\
		\"weight\": 507,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.code\",\
		\"weight\": 508,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.timingTiming\",\
		\"weight\": 509,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.timingDateTime\",\
		\"weight\": 509,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.timingPeriod\",\
		\"weight\": 509,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.timingRange\",\
		\"weight\": 509,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.location\",\
		\"weight\": 510,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.participant\",\
		\"weight\": 511,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.participant.id\",\
		\"weight\": 512,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.participant.extension\",\
		\"weight\": 513,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.participant.modifierExtension\",\
		\"weight\": 514,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ActivityDefinition.participant.type\",\
		\"weight\": 515,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.participant.role\",\
		\"weight\": 516,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.productReference\",\
		\"weight\": 517,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.productReference\",\
		\"weight\": 517,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.productCodeableConcept\",\
		\"weight\": 517,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.quantity\",\
		\"weight\": 518,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dosage\",\
		\"weight\": 519,\
		\"max\": \"*\",\
		\"type\": \"Dosage\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.bodySite\",\
		\"weight\": 520,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.transform\",\
		\"weight\": 521,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dynamicValue\",\
		\"weight\": 522,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dynamicValue.id\",\
		\"weight\": 523,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dynamicValue.extension\",\
		\"weight\": 524,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dynamicValue.modifierExtension\",\
		\"weight\": 525,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dynamicValue.description\",\
		\"weight\": 526,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dynamicValue.path\",\
		\"weight\": 527,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dynamicValue.language\",\
		\"weight\": 528,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ActivityDefinition.dynamicValue.expression\",\
		\"weight\": 529,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent\",\
		\"weight\": 530,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.id\",\
		\"weight\": 531,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.meta\",\
		\"weight\": 532,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.implicitRules\",\
		\"weight\": 533,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.language\",\
		\"weight\": 534,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.text\",\
		\"weight\": 535,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.contained\",\
		\"weight\": 536,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.extension\",\
		\"weight\": 537,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.modifierExtension\",\
		\"weight\": 538,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.identifier\",\
		\"weight\": 539,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.category\",\
		\"weight\": 540,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.type\",\
		\"weight\": 541,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.subject\",\
		\"weight\": 542,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.date\",\
		\"weight\": 543,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.reaction\",\
		\"weight\": 544,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.location\",\
		\"weight\": 545,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.seriousness\",\
		\"weight\": 546,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.outcome\",\
		\"weight\": 547,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.recorder\",\
		\"weight\": 548,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.eventParticipant\",\
		\"weight\": 549,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.description\",\
		\"weight\": 550,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity\",\
		\"weight\": 551,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.id\",\
		\"weight\": 552,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.extension\",\
		\"weight\": 553,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.modifierExtension\",\
		\"weight\": 554,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AdverseEvent.suspectEntity.instance\",\
		\"weight\": 555,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.causality\",\
		\"weight\": 556,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.causalityAssessment\",\
		\"weight\": 557,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.causalityProductRelatedness\",\
		\"weight\": 558,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.causalityMethod\",\
		\"weight\": 559,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.causalityAuthor\",\
		\"weight\": 560,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.suspectEntity.causalityResult\",\
		\"weight\": 561,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.subjectMedicalHistory\",\
		\"weight\": 562,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.referenceDocument\",\
		\"weight\": 563,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AdverseEvent.study\",\
		\"weight\": 564,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance\",\
		\"weight\": 565,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.id\",\
		\"weight\": 566,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.meta\",\
		\"weight\": 567,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.implicitRules\",\
		\"weight\": 568,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.language\",\
		\"weight\": 569,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.text\",\
		\"weight\": 570,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.contained\",\
		\"weight\": 571,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.extension\",\
		\"weight\": 572,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.modifierExtension\",\
		\"weight\": 573,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.identifier\",\
		\"weight\": 574,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.clinicalStatus\",\
		\"weight\": 575,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AllergyIntolerance.verificationStatus\",\
		\"weight\": 576,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.type\",\
		\"weight\": 577,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.category\",\
		\"weight\": 578,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.criticality\",\
		\"weight\": 579,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.code\",\
		\"weight\": 580,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AllergyIntolerance.patient\",\
		\"weight\": 581,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.onsetDateTime\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.onsetAge\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.onsetPeriod\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.onsetRange\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.onsetString\",\
		\"weight\": 582,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.assertedDate\",\
		\"weight\": 583,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.recorder\",\
		\"weight\": 584,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.asserter\",\
		\"weight\": 585,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.lastOccurrence\",\
		\"weight\": 586,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.note\",\
		\"weight\": 587,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction\",\
		\"weight\": 588,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.id\",\
		\"weight\": 589,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.extension\",\
		\"weight\": 590,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.modifierExtension\",\
		\"weight\": 591,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.substance\",\
		\"weight\": 592,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AllergyIntolerance.reaction.manifestation\",\
		\"weight\": 593,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.description\",\
		\"weight\": 594,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.onset\",\
		\"weight\": 595,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.severity\",\
		\"weight\": 596,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.exposureRoute\",\
		\"weight\": 597,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AllergyIntolerance.reaction.note\",\
		\"weight\": 598,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment\",\
		\"weight\": 599,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.id\",\
		\"weight\": 600,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.meta\",\
		\"weight\": 601,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.implicitRules\",\
		\"weight\": 602,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.language\",\
		\"weight\": 603,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.text\",\
		\"weight\": 604,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.contained\",\
		\"weight\": 605,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.extension\",\
		\"weight\": 606,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.modifierExtension\",\
		\"weight\": 607,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.identifier\",\
		\"weight\": 608,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Appointment.status\",\
		\"weight\": 609,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.serviceCategory\",\
		\"weight\": 610,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.serviceType\",\
		\"weight\": 611,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.specialty\",\
		\"weight\": 612,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.appointmentType\",\
		\"weight\": 613,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.reason\",\
		\"weight\": 614,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.indication\",\
		\"weight\": 615,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.priority\",\
		\"weight\": 616,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.description\",\
		\"weight\": 617,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.supportingInformation\",\
		\"weight\": 618,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.start\",\
		\"weight\": 619,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.end\",\
		\"weight\": 620,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.minutesDuration\",\
		\"weight\": 621,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.slot\",\
		\"weight\": 622,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.created\",\
		\"weight\": 623,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.comment\",\
		\"weight\": 624,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.incomingReferral\",\
		\"weight\": 625,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Appointment.participant\",\
		\"weight\": 626,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.participant.id\",\
		\"weight\": 627,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.participant.extension\",\
		\"weight\": 628,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.participant.modifierExtension\",\
		\"weight\": 629,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.participant.type\",\
		\"weight\": 630,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.participant.actor\",\
		\"weight\": 631,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.participant.required\",\
		\"weight\": 632,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Appointment.participant.status\",\
		\"weight\": 633,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Appointment.requestedPeriod\",\
		\"weight\": 634,\
		\"max\": \"*\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse\",\
		\"weight\": 635,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.id\",\
		\"weight\": 636,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.meta\",\
		\"weight\": 637,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.implicitRules\",\
		\"weight\": 638,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.language\",\
		\"weight\": 639,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.text\",\
		\"weight\": 640,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.contained\",\
		\"weight\": 641,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.extension\",\
		\"weight\": 642,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.modifierExtension\",\
		\"weight\": 643,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.identifier\",\
		\"weight\": 644,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AppointmentResponse.appointment\",\
		\"weight\": 645,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.start\",\
		\"weight\": 646,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.end\",\
		\"weight\": 647,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.participantType\",\
		\"weight\": 648,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.actor\",\
		\"weight\": 649,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AppointmentResponse.participantStatus\",\
		\"weight\": 650,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AppointmentResponse.comment\",\
		\"weight\": 651,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent\",\
		\"weight\": 652,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.id\",\
		\"weight\": 653,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.meta\",\
		\"weight\": 654,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.implicitRules\",\
		\"weight\": 655,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.language\",\
		\"weight\": 656,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.text\",\
		\"weight\": 657,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.contained\",\
		\"weight\": 658,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.extension\",\
		\"weight\": 659,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.modifierExtension\",\
		\"weight\": 660,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AuditEvent.type\",\
		\"weight\": 661,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.subtype\",\
		\"weight\": 662,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.action\",\
		\"weight\": 663,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AuditEvent.recorded\",\
		\"weight\": 664,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.outcome\",\
		\"weight\": 665,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.outcomeDesc\",\
		\"weight\": 666,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.purposeOfEvent\",\
		\"weight\": 667,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AuditEvent.agent\",\
		\"weight\": 668,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.id\",\
		\"weight\": 669,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.extension\",\
		\"weight\": 670,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.modifierExtension\",\
		\"weight\": 671,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.role\",\
		\"weight\": 672,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.reference\",\
		\"weight\": 673,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.userId\",\
		\"weight\": 674,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.altId\",\
		\"weight\": 675,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.name\",\
		\"weight\": 676,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AuditEvent.agent.requestor\",\
		\"weight\": 677,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.location\",\
		\"weight\": 678,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.policy\",\
		\"weight\": 679,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.media\",\
		\"weight\": 680,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.network\",\
		\"weight\": 681,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.network.id\",\
		\"weight\": 682,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.network.extension\",\
		\"weight\": 683,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.network.modifierExtension\",\
		\"weight\": 684,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.network.address\",\
		\"weight\": 685,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.network.type\",\
		\"weight\": 686,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.agent.purposeOfUse\",\
		\"weight\": 687,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AuditEvent.source\",\
		\"weight\": 688,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.source.id\",\
		\"weight\": 689,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.source.extension\",\
		\"weight\": 690,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.source.modifierExtension\",\
		\"weight\": 691,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.source.site\",\
		\"weight\": 692,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AuditEvent.source.identifier\",\
		\"weight\": 693,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.source.type\",\
		\"weight\": 694,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity\",\
		\"weight\": 695,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.id\",\
		\"weight\": 696,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.extension\",\
		\"weight\": 697,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.modifierExtension\",\
		\"weight\": 698,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.identifier\",\
		\"weight\": 699,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.reference\",\
		\"weight\": 700,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.type\",\
		\"weight\": 701,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.role\",\
		\"weight\": 702,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.lifecycle\",\
		\"weight\": 703,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.securityLabel\",\
		\"weight\": 704,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.name\",\
		\"weight\": 705,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.description\",\
		\"weight\": 706,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.query\",\
		\"weight\": 707,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.detail\",\
		\"weight\": 708,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.detail.id\",\
		\"weight\": 709,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.detail.extension\",\
		\"weight\": 710,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"AuditEvent.entity.detail.modifierExtension\",\
		\"weight\": 711,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AuditEvent.entity.detail.type\",\
		\"weight\": 712,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"AuditEvent.entity.detail.value\",\
		\"weight\": 713,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic\",\
		\"weight\": 714,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.id\",\
		\"weight\": 715,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.meta\",\
		\"weight\": 716,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.implicitRules\",\
		\"weight\": 717,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.language\",\
		\"weight\": 718,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.text\",\
		\"weight\": 719,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.contained\",\
		\"weight\": 720,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.extension\",\
		\"weight\": 721,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.modifierExtension\",\
		\"weight\": 722,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.identifier\",\
		\"weight\": 723,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Basic.code\",\
		\"weight\": 724,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.subject\",\
		\"weight\": 725,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.created\",\
		\"weight\": 726,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Basic.author\",\
		\"weight\": 727,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Binary\",\
		\"weight\": 728,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Binary.id\",\
		\"weight\": 729,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Binary.meta\",\
		\"weight\": 730,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Binary.implicitRules\",\
		\"weight\": 731,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Binary.language\",\
		\"weight\": 732,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Binary.contentType\",\
		\"weight\": 733,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Binary.securityContext\",\
		\"weight\": 734,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Binary.content\",\
		\"weight\": 735,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite\",\
		\"weight\": 736,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.id\",\
		\"weight\": 737,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.meta\",\
		\"weight\": 738,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.implicitRules\",\
		\"weight\": 739,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.language\",\
		\"weight\": 740,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.text\",\
		\"weight\": 741,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.contained\",\
		\"weight\": 742,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.extension\",\
		\"weight\": 743,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.modifierExtension\",\
		\"weight\": 744,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.identifier\",\
		\"weight\": 745,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.active\",\
		\"weight\": 746,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.code\",\
		\"weight\": 747,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.qualifier\",\
		\"weight\": 748,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.description\",\
		\"weight\": 749,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"BodySite.image\",\
		\"weight\": 750,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"BodySite.patient\",\
		\"weight\": 751,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle\",\
		\"weight\": 752,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.id\",\
		\"weight\": 753,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.meta\",\
		\"weight\": 754,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.implicitRules\",\
		\"weight\": 755,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.language\",\
		\"weight\": 756,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.identifier\",\
		\"weight\": 757,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Bundle.type\",\
		\"weight\": 758,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.total\",\
		\"weight\": 759,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.link\",\
		\"weight\": 760,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.link.id\",\
		\"weight\": 761,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.link.extension\",\
		\"weight\": 762,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.link.modifierExtension\",\
		\"weight\": 763,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Bundle.link.relation\",\
		\"weight\": 764,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Bundle.link.url\",\
		\"weight\": 765,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry\",\
		\"weight\": 766,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.id\",\
		\"weight\": 767,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.extension\",\
		\"weight\": 768,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.modifierExtension\",\
		\"weight\": 769,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.link\",\
		\"weight\": 770,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.fullUrl\",\
		\"weight\": 771,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.resource\",\
		\"weight\": 772,\
		\"max\": \"1\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.search\",\
		\"weight\": 773,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.search.id\",\
		\"weight\": 774,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.search.extension\",\
		\"weight\": 775,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.search.modifierExtension\",\
		\"weight\": 776,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.search.mode\",\
		\"weight\": 777,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.search.score\",\
		\"weight\": 778,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.request\",\
		\"weight\": 779,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.request.id\",\
		\"weight\": 780,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.request.extension\",\
		\"weight\": 781,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.request.modifierExtension\",\
		\"weight\": 782,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Bundle.entry.request.method\",\
		\"weight\": 783,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Bundle.entry.request.url\",\
		\"weight\": 784,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.request.ifNoneMatch\",\
		\"weight\": 785,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.request.ifModifiedSince\",\
		\"weight\": 786,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.request.ifMatch\",\
		\"weight\": 787,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.request.ifNoneExist\",\
		\"weight\": 788,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.response\",\
		\"weight\": 789,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.response.id\",\
		\"weight\": 790,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.response.extension\",\
		\"weight\": 791,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.response.modifierExtension\",\
		\"weight\": 792,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Bundle.entry.response.status\",\
		\"weight\": 793,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.response.location\",\
		\"weight\": 794,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.response.etag\",\
		\"weight\": 795,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.response.lastModified\",\
		\"weight\": 796,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.entry.response.outcome\",\
		\"weight\": 797,\
		\"max\": \"1\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Bundle.signature\",\
		\"weight\": 798,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement\",\
		\"weight\": 799,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.id\",\
		\"weight\": 800,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.meta\",\
		\"weight\": 801,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.implicitRules\",\
		\"weight\": 802,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.language\",\
		\"weight\": 803,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.text\",\
		\"weight\": 804,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.contained\",\
		\"weight\": 805,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.extension\",\
		\"weight\": 806,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.modifierExtension\",\
		\"weight\": 807,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.url\",\
		\"weight\": 808,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.version\",\
		\"weight\": 809,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.name\",\
		\"weight\": 810,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.title\",\
		\"weight\": 811,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.status\",\
		\"weight\": 812,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.experimental\",\
		\"weight\": 813,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.date\",\
		\"weight\": 814,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.publisher\",\
		\"weight\": 815,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.contact\",\
		\"weight\": 816,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.description\",\
		\"weight\": 817,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.useContext\",\
		\"weight\": 818,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.jurisdiction\",\
		\"weight\": 819,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.purpose\",\
		\"weight\": 820,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.copyright\",\
		\"weight\": 821,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.kind\",\
		\"weight\": 822,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.instantiates\",\
		\"weight\": 823,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.software\",\
		\"weight\": 824,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.software.id\",\
		\"weight\": 825,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.software.extension\",\
		\"weight\": 826,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.software.modifierExtension\",\
		\"weight\": 827,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.software.name\",\
		\"weight\": 828,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.software.version\",\
		\"weight\": 829,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.software.releaseDate\",\
		\"weight\": 830,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.implementation\",\
		\"weight\": 831,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.implementation.id\",\
		\"weight\": 832,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.implementation.extension\",\
		\"weight\": 833,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.implementation.modifierExtension\",\
		\"weight\": 834,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.implementation.description\",\
		\"weight\": 835,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.implementation.url\",\
		\"weight\": 836,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.fhirVersion\",\
		\"weight\": 837,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.acceptUnknown\",\
		\"weight\": 838,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.format\",\
		\"weight\": 839,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.patchFormat\",\
		\"weight\": 840,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.implementationGuide\",\
		\"weight\": 841,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.profile\",\
		\"weight\": 842,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest\",\
		\"weight\": 843,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.id\",\
		\"weight\": 844,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.extension\",\
		\"weight\": 845,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.modifierExtension\",\
		\"weight\": 846,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.mode\",\
		\"weight\": 847,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.documentation\",\
		\"weight\": 848,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security\",\
		\"weight\": 849,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.id\",\
		\"weight\": 850,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.extension\",\
		\"weight\": 851,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.modifierExtension\",\
		\"weight\": 852,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.cors\",\
		\"weight\": 853,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.service\",\
		\"weight\": 854,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.description\",\
		\"weight\": 855,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.certificate\",\
		\"weight\": 856,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.certificate.id\",\
		\"weight\": 857,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.certificate.extension\",\
		\"weight\": 858,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.certificate.modifierExtension\",\
		\"weight\": 859,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.certificate.type\",\
		\"weight\": 860,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.security.certificate.blob\",\
		\"weight\": 861,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource\",\
		\"weight\": 862,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.id\",\
		\"weight\": 863,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.extension\",\
		\"weight\": 864,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.modifierExtension\",\
		\"weight\": 865,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.resource.type\",\
		\"weight\": 866,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.profile\",\
		\"weight\": 867,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.documentation\",\
		\"weight\": 868,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.resource.interaction\",\
		\"weight\": 869,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.interaction.id\",\
		\"weight\": 870,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.interaction.extension\",\
		\"weight\": 871,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.interaction.modifierExtension\",\
		\"weight\": 872,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.resource.interaction.code\",\
		\"weight\": 873,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.interaction.documentation\",\
		\"weight\": 874,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.versioning\",\
		\"weight\": 875,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.readHistory\",\
		\"weight\": 876,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.updateCreate\",\
		\"weight\": 877,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.conditionalCreate\",\
		\"weight\": 878,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.conditionalRead\",\
		\"weight\": 879,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.conditionalUpdate\",\
		\"weight\": 880,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.conditionalDelete\",\
		\"weight\": 881,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.referencePolicy\",\
		\"weight\": 882,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.searchInclude\",\
		\"weight\": 883,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.searchRevInclude\",\
		\"weight\": 884,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.searchParam\",\
		\"weight\": 885,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.searchParam.id\",\
		\"weight\": 886,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.searchParam.extension\",\
		\"weight\": 887,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.searchParam.modifierExtension\",\
		\"weight\": 888,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.resource.searchParam.name\",\
		\"weight\": 889,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.searchParam.definition\",\
		\"weight\": 890,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.resource.searchParam.type\",\
		\"weight\": 891,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.resource.searchParam.documentation\",\
		\"weight\": 892,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.interaction\",\
		\"weight\": 893,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.interaction.id\",\
		\"weight\": 894,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.interaction.extension\",\
		\"weight\": 895,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.interaction.modifierExtension\",\
		\"weight\": 896,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.interaction.code\",\
		\"weight\": 897,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.interaction.documentation\",\
		\"weight\": 898,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.searchParam\",\
		\"weight\": 899,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.operation\",\
		\"weight\": 900,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.operation.id\",\
		\"weight\": 901,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.operation.extension\",\
		\"weight\": 902,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.operation.modifierExtension\",\
		\"weight\": 903,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.operation.name\",\
		\"weight\": 904,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.rest.operation.definition\",\
		\"weight\": 905,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.rest.compartment\",\
		\"weight\": 906,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging\",\
		\"weight\": 907,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.id\",\
		\"weight\": 908,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.extension\",\
		\"weight\": 909,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.modifierExtension\",\
		\"weight\": 910,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.endpoint\",\
		\"weight\": 911,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.endpoint.id\",\
		\"weight\": 912,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.endpoint.extension\",\
		\"weight\": 913,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.endpoint.modifierExtension\",\
		\"weight\": 914,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.endpoint.protocol\",\
		\"weight\": 915,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.endpoint.address\",\
		\"weight\": 916,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.reliableCache\",\
		\"weight\": 917,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.documentation\",\
		\"weight\": 918,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.supportedMessage\",\
		\"weight\": 919,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.supportedMessage.id\",\
		\"weight\": 920,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.supportedMessage.extension\",\
		\"weight\": 921,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.supportedMessage.modifierExtension\",\
		\"weight\": 922,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.supportedMessage.mode\",\
		\"weight\": 923,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.supportedMessage.definition\",\
		\"weight\": 924,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.event\",\
		\"weight\": 925,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.event.id\",\
		\"weight\": 926,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.event.extension\",\
		\"weight\": 927,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.event.modifierExtension\",\
		\"weight\": 928,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.event.code\",\
		\"weight\": 929,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.event.category\",\
		\"weight\": 930,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.event.mode\",\
		\"weight\": 931,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.event.focus\",\
		\"weight\": 932,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.event.request\",\
		\"weight\": 933,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.messaging.event.response\",\
		\"weight\": 934,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.messaging.event.documentation\",\
		\"weight\": 935,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.document\",\
		\"weight\": 936,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.document.id\",\
		\"weight\": 937,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.document.extension\",\
		\"weight\": 938,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.document.modifierExtension\",\
		\"weight\": 939,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.document.mode\",\
		\"weight\": 940,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CapabilityStatement.document.documentation\",\
		\"weight\": 941,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CapabilityStatement.document.profile\",\
		\"weight\": 942,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan\",\
		\"weight\": 943,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.id\",\
		\"weight\": 944,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.meta\",\
		\"weight\": 945,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.implicitRules\",\
		\"weight\": 946,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.language\",\
		\"weight\": 947,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.text\",\
		\"weight\": 948,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.contained\",\
		\"weight\": 949,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.extension\",\
		\"weight\": 950,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.modifierExtension\",\
		\"weight\": 951,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.identifier\",\
		\"weight\": 952,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.definition\",\
		\"weight\": 953,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.basedOn\",\
		\"weight\": 954,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.replaces\",\
		\"weight\": 955,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.partOf\",\
		\"weight\": 956,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CarePlan.status\",\
		\"weight\": 957,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CarePlan.intent\",\
		\"weight\": 958,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.category\",\
		\"weight\": 959,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.title\",\
		\"weight\": 960,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.description\",\
		\"weight\": 961,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CarePlan.subject\",\
		\"weight\": 962,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.context\",\
		\"weight\": 963,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.period\",\
		\"weight\": 964,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.author\",\
		\"weight\": 965,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.careTeam\",\
		\"weight\": 966,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.addresses\",\
		\"weight\": 967,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.supportingInfo\",\
		\"weight\": 968,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.goal\",\
		\"weight\": 969,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity\",\
		\"weight\": 970,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.id\",\
		\"weight\": 971,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.extension\",\
		\"weight\": 972,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.modifierExtension\",\
		\"weight\": 973,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.outcomeCodeableConcept\",\
		\"weight\": 974,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.outcomeReference\",\
		\"weight\": 975,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.progress\",\
		\"weight\": 976,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.reference\",\
		\"weight\": 977,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail\",\
		\"weight\": 978,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.id\",\
		\"weight\": 979,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.extension\",\
		\"weight\": 980,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.modifierExtension\",\
		\"weight\": 981,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.category\",\
		\"weight\": 982,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.definition\",\
		\"weight\": 983,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.code\",\
		\"weight\": 984,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.reasonCode\",\
		\"weight\": 985,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.reasonReference\",\
		\"weight\": 986,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.goal\",\
		\"weight\": 987,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CarePlan.activity.detail.status\",\
		\"weight\": 988,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.statusReason\",\
		\"weight\": 989,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.prohibited\",\
		\"weight\": 990,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.scheduledTiming\",\
		\"weight\": 991,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.scheduledPeriod\",\
		\"weight\": 991,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.scheduledString\",\
		\"weight\": 991,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.location\",\
		\"weight\": 992,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.performer\",\
		\"weight\": 993,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.productCodeableConcept\",\
		\"weight\": 994,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"weight\": 994,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"weight\": 994,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.dailyAmount\",\
		\"weight\": 995,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.quantity\",\
		\"weight\": 996,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.activity.detail.description\",\
		\"weight\": 997,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CarePlan.note\",\
		\"weight\": 998,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam\",\
		\"weight\": 999,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.id\",\
		\"weight\": 1000,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.meta\",\
		\"weight\": 1001,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.implicitRules\",\
		\"weight\": 1002,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.language\",\
		\"weight\": 1003,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.text\",\
		\"weight\": 1004,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.contained\",\
		\"weight\": 1005,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.extension\",\
		\"weight\": 1006,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.modifierExtension\",\
		\"weight\": 1007,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.identifier\",\
		\"weight\": 1008,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.status\",\
		\"weight\": 1009,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.category\",\
		\"weight\": 1010,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.name\",\
		\"weight\": 1011,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.subject\",\
		\"weight\": 1012,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.context\",\
		\"weight\": 1013,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.period\",\
		\"weight\": 1014,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.participant\",\
		\"weight\": 1015,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.participant.id\",\
		\"weight\": 1016,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.participant.extension\",\
		\"weight\": 1017,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.participant.modifierExtension\",\
		\"weight\": 1018,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.participant.role\",\
		\"weight\": 1019,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.participant.member\",\
		\"weight\": 1020,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.participant.onBehalfOf\",\
		\"weight\": 1021,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.participant.period\",\
		\"weight\": 1022,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.reasonCode\",\
		\"weight\": 1023,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.reasonReference\",\
		\"weight\": 1024,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.managingOrganization\",\
		\"weight\": 1025,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CareTeam.note\",\
		\"weight\": 1026,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem\",\
		\"weight\": 1027,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.id\",\
		\"weight\": 1028,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.meta\",\
		\"weight\": 1029,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.implicitRules\",\
		\"weight\": 1030,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.language\",\
		\"weight\": 1031,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.text\",\
		\"weight\": 1032,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.contained\",\
		\"weight\": 1033,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.extension\",\
		\"weight\": 1034,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.modifierExtension\",\
		\"weight\": 1035,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.identifier\",\
		\"weight\": 1036,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.definition\",\
		\"weight\": 1037,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ChargeItem.status\",\
		\"weight\": 1038,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.partOf\",\
		\"weight\": 1039,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ChargeItem.code\",\
		\"weight\": 1040,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ChargeItem.subject\",\
		\"weight\": 1041,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.context\",\
		\"weight\": 1042,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.occurrenceDateTime\",\
		\"weight\": 1043,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.occurrencePeriod\",\
		\"weight\": 1043,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.occurrenceTiming\",\
		\"weight\": 1043,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.participant\",\
		\"weight\": 1044,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.participant.id\",\
		\"weight\": 1045,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.participant.extension\",\
		\"weight\": 1046,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.participant.modifierExtension\",\
		\"weight\": 1047,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.participant.role\",\
		\"weight\": 1048,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ChargeItem.participant.actor\",\
		\"weight\": 1049,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.performingOrganization\",\
		\"weight\": 1050,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.requestingOrganization\",\
		\"weight\": 1051,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.quantity\",\
		\"weight\": 1052,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.bodysite\",\
		\"weight\": 1053,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.factorOverride\",\
		\"weight\": 1054,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.priceOverride\",\
		\"weight\": 1055,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.overrideReason\",\
		\"weight\": 1056,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.enterer\",\
		\"weight\": 1057,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.enteredDate\",\
		\"weight\": 1058,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.reason\",\
		\"weight\": 1059,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.service\",\
		\"weight\": 1060,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.account\",\
		\"weight\": 1061,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.note\",\
		\"weight\": 1062,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ChargeItem.supportingInformation\",\
		\"weight\": 1063,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim\",\
		\"weight\": 1064,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.id\",\
		\"weight\": 1065,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.meta\",\
		\"weight\": 1066,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.implicitRules\",\
		\"weight\": 1067,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.language\",\
		\"weight\": 1068,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.text\",\
		\"weight\": 1069,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.contained\",\
		\"weight\": 1070,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.extension\",\
		\"weight\": 1071,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.modifierExtension\",\
		\"weight\": 1072,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.identifier\",\
		\"weight\": 1073,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.status\",\
		\"weight\": 1074,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.type\",\
		\"weight\": 1075,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.subType\",\
		\"weight\": 1076,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.use\",\
		\"weight\": 1077,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.patient\",\
		\"weight\": 1078,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.billablePeriod\",\
		\"weight\": 1079,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.created\",\
		\"weight\": 1080,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.enterer\",\
		\"weight\": 1081,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.insurer\",\
		\"weight\": 1082,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.provider\",\
		\"weight\": 1083,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.organization\",\
		\"weight\": 1084,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.priority\",\
		\"weight\": 1085,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.fundsReserve\",\
		\"weight\": 1086,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.related\",\
		\"weight\": 1087,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.related.id\",\
		\"weight\": 1088,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.related.extension\",\
		\"weight\": 1089,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.related.modifierExtension\",\
		\"weight\": 1090,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.related.claim\",\
		\"weight\": 1091,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.related.relationship\",\
		\"weight\": 1092,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.related.reference\",\
		\"weight\": 1093,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.prescription\",\
		\"weight\": 1094,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.originalPrescription\",\
		\"weight\": 1095,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.payee\",\
		\"weight\": 1096,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.payee.id\",\
		\"weight\": 1097,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.payee.extension\",\
		\"weight\": 1098,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.payee.modifierExtension\",\
		\"weight\": 1099,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.payee.type\",\
		\"weight\": 1100,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.payee.resourceType\",\
		\"weight\": 1101,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.payee.party\",\
		\"weight\": 1102,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.referral\",\
		\"weight\": 1103,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.facility\",\
		\"weight\": 1104,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.careTeam\",\
		\"weight\": 1105,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.careTeam.id\",\
		\"weight\": 1106,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.careTeam.extension\",\
		\"weight\": 1107,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.careTeam.modifierExtension\",\
		\"weight\": 1108,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.careTeam.sequence\",\
		\"weight\": 1109,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.careTeam.provider\",\
		\"weight\": 1110,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.careTeam.responsible\",\
		\"weight\": 1111,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.careTeam.role\",\
		\"weight\": 1112,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.careTeam.qualification\",\
		\"weight\": 1113,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information\",\
		\"weight\": 1114,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.id\",\
		\"weight\": 1115,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.extension\",\
		\"weight\": 1116,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.modifierExtension\",\
		\"weight\": 1117,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.information.sequence\",\
		\"weight\": 1118,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.information.category\",\
		\"weight\": 1119,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.code\",\
		\"weight\": 1120,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.timingDate\",\
		\"weight\": 1121,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.timingPeriod\",\
		\"weight\": 1121,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.valueString\",\
		\"weight\": 1122,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.valueQuantity\",\
		\"weight\": 1122,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.valueAttachment\",\
		\"weight\": 1122,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.valueReference\",\
		\"weight\": 1122,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.information.reason\",\
		\"weight\": 1123,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.diagnosis\",\
		\"weight\": 1124,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.diagnosis.id\",\
		\"weight\": 1125,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.diagnosis.extension\",\
		\"weight\": 1126,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.diagnosis.modifierExtension\",\
		\"weight\": 1127,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.diagnosis.sequence\",\
		\"weight\": 1128,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.diagnosis.diagnosisCodeableConcept\",\
		\"weight\": 1129,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.diagnosis.diagnosisReference\",\
		\"weight\": 1129,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.diagnosis.type\",\
		\"weight\": 1130,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.diagnosis.packageCode\",\
		\"weight\": 1131,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.procedure\",\
		\"weight\": 1132,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.procedure.id\",\
		\"weight\": 1133,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.procedure.extension\",\
		\"weight\": 1134,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.procedure.modifierExtension\",\
		\"weight\": 1135,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.procedure.sequence\",\
		\"weight\": 1136,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.procedure.date\",\
		\"weight\": 1137,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.procedure.procedureCodeableConcept\",\
		\"weight\": 1138,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.procedure.procedureReference\",\
		\"weight\": 1138,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.insurance\",\
		\"weight\": 1139,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.insurance.id\",\
		\"weight\": 1140,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.insurance.extension\",\
		\"weight\": 1141,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.insurance.modifierExtension\",\
		\"weight\": 1142,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.insurance.sequence\",\
		\"weight\": 1143,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.insurance.focal\",\
		\"weight\": 1144,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.insurance.coverage\",\
		\"weight\": 1145,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.insurance.businessArrangement\",\
		\"weight\": 1146,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.insurance.preAuthRef\",\
		\"weight\": 1147,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.insurance.claimResponse\",\
		\"weight\": 1148,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.accident\",\
		\"weight\": 1149,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.accident.id\",\
		\"weight\": 1150,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.accident.extension\",\
		\"weight\": 1151,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.accident.modifierExtension\",\
		\"weight\": 1152,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.accident.date\",\
		\"weight\": 1153,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.accident.type\",\
		\"weight\": 1154,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.accident.locationAddress\",\
		\"weight\": 1155,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.accident.locationReference\",\
		\"weight\": 1155,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.employmentImpacted\",\
		\"weight\": 1156,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.hospitalization\",\
		\"weight\": 1157,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item\",\
		\"weight\": 1158,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.id\",\
		\"weight\": 1159,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.extension\",\
		\"weight\": 1160,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.modifierExtension\",\
		\"weight\": 1161,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.item.sequence\",\
		\"weight\": 1162,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.careTeamLinkId\",\
		\"weight\": 1163,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.diagnosisLinkId\",\
		\"weight\": 1164,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.procedureLinkId\",\
		\"weight\": 1165,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.informationLinkId\",\
		\"weight\": 1166,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.revenue\",\
		\"weight\": 1167,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.category\",\
		\"weight\": 1168,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.service\",\
		\"weight\": 1169,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.modifier\",\
		\"weight\": 1170,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.programCode\",\
		\"weight\": 1171,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.servicedDate\",\
		\"weight\": 1172,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.servicedPeriod\",\
		\"weight\": 1172,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.locationCodeableConcept\",\
		\"weight\": 1173,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.locationAddress\",\
		\"weight\": 1173,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.locationReference\",\
		\"weight\": 1173,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.quantity\",\
		\"weight\": 1174,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.unitPrice\",\
		\"weight\": 1175,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.factor\",\
		\"weight\": 1176,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.net\",\
		\"weight\": 1177,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.udi\",\
		\"weight\": 1178,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.bodySite\",\
		\"weight\": 1179,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.subSite\",\
		\"weight\": 1180,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.encounter\",\
		\"weight\": 1181,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail\",\
		\"weight\": 1182,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.id\",\
		\"weight\": 1183,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.extension\",\
		\"weight\": 1184,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.modifierExtension\",\
		\"weight\": 1185,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.item.detail.sequence\",\
		\"weight\": 1186,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.revenue\",\
		\"weight\": 1187,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.category\",\
		\"weight\": 1188,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.service\",\
		\"weight\": 1189,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.modifier\",\
		\"weight\": 1190,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.programCode\",\
		\"weight\": 1191,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.quantity\",\
		\"weight\": 1192,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.unitPrice\",\
		\"weight\": 1193,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.factor\",\
		\"weight\": 1194,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.net\",\
		\"weight\": 1195,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.udi\",\
		\"weight\": 1196,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail\",\
		\"weight\": 1197,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.id\",\
		\"weight\": 1198,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.extension\",\
		\"weight\": 1199,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.modifierExtension\",\
		\"weight\": 1200,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Claim.item.detail.subDetail.sequence\",\
		\"weight\": 1201,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.revenue\",\
		\"weight\": 1202,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.category\",\
		\"weight\": 1203,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.service\",\
		\"weight\": 1204,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.modifier\",\
		\"weight\": 1205,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.programCode\",\
		\"weight\": 1206,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.quantity\",\
		\"weight\": 1207,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.unitPrice\",\
		\"weight\": 1208,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.factor\",\
		\"weight\": 1209,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.net\",\
		\"weight\": 1210,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.item.detail.subDetail.udi\",\
		\"weight\": 1211,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Claim.total\",\
		\"weight\": 1212,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse\",\
		\"weight\": 1213,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.id\",\
		\"weight\": 1214,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.meta\",\
		\"weight\": 1215,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.implicitRules\",\
		\"weight\": 1216,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.language\",\
		\"weight\": 1217,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.text\",\
		\"weight\": 1218,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.contained\",\
		\"weight\": 1219,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.extension\",\
		\"weight\": 1220,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.modifierExtension\",\
		\"weight\": 1221,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.identifier\",\
		\"weight\": 1222,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.status\",\
		\"weight\": 1223,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.patient\",\
		\"weight\": 1224,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.created\",\
		\"weight\": 1225,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.insurer\",\
		\"weight\": 1226,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.requestProvider\",\
		\"weight\": 1227,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.requestOrganization\",\
		\"weight\": 1228,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.request\",\
		\"weight\": 1229,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.outcome\",\
		\"weight\": 1230,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.disposition\",\
		\"weight\": 1231,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payeeType\",\
		\"weight\": 1232,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item\",\
		\"weight\": 1233,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.id\",\
		\"weight\": 1234,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.extension\",\
		\"weight\": 1235,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.modifierExtension\",\
		\"weight\": 1236,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClaimResponse.item.sequenceLinkId\",\
		\"weight\": 1237,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.noteNumber\",\
		\"weight\": 1238,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.adjudication\",\
		\"weight\": 1239,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.adjudication.id\",\
		\"weight\": 1240,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.adjudication.extension\",\
		\"weight\": 1241,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.adjudication.modifierExtension\",\
		\"weight\": 1242,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClaimResponse.item.adjudication.category\",\
		\"weight\": 1243,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.adjudication.reason\",\
		\"weight\": 1244,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.adjudication.amount\",\
		\"weight\": 1245,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.adjudication.value\",\
		\"weight\": 1246,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail\",\
		\"weight\": 1247,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.id\",\
		\"weight\": 1248,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.extension\",\
		\"weight\": 1249,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.modifierExtension\",\
		\"weight\": 1250,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClaimResponse.item.detail.sequenceLinkId\",\
		\"weight\": 1251,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.noteNumber\",\
		\"weight\": 1252,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.adjudication\",\
		\"weight\": 1253,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.subDetail\",\
		\"weight\": 1254,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.subDetail.id\",\
		\"weight\": 1255,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.subDetail.extension\",\
		\"weight\": 1256,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.subDetail.modifierExtension\",\
		\"weight\": 1257,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClaimResponse.item.detail.subDetail.sequenceLinkId\",\
		\"weight\": 1258,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.subDetail.noteNumber\",\
		\"weight\": 1259,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication\",\
		\"weight\": 1260,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem\",\
		\"weight\": 1261,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.id\",\
		\"weight\": 1262,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.extension\",\
		\"weight\": 1263,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.modifierExtension\",\
		\"weight\": 1264,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.sequenceLinkId\",\
		\"weight\": 1265,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.revenue\",\
		\"weight\": 1266,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.category\",\
		\"weight\": 1267,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.service\",\
		\"weight\": 1268,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.modifier\",\
		\"weight\": 1269,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.fee\",\
		\"weight\": 1270,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.noteNumber\",\
		\"weight\": 1271,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.adjudication\",\
		\"weight\": 1272,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail\",\
		\"weight\": 1273,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.id\",\
		\"weight\": 1274,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.extension\",\
		\"weight\": 1275,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.modifierExtension\",\
		\"weight\": 1276,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.revenue\",\
		\"weight\": 1277,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.category\",\
		\"weight\": 1278,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.service\",\
		\"weight\": 1279,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.modifier\",\
		\"weight\": 1280,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.fee\",\
		\"weight\": 1281,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.noteNumber\",\
		\"weight\": 1282,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.addItem.detail.adjudication\",\
		\"weight\": 1283,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.error\",\
		\"weight\": 1284,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.error.id\",\
		\"weight\": 1285,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.error.extension\",\
		\"weight\": 1286,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.error.modifierExtension\",\
		\"weight\": 1287,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.error.sequenceLinkId\",\
		\"weight\": 1288,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.error.detailSequenceLinkId\",\
		\"weight\": 1289,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.error.subdetailSequenceLinkId\",\
		\"weight\": 1290,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClaimResponse.error.code\",\
		\"weight\": 1291,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.totalCost\",\
		\"weight\": 1292,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.unallocDeductable\",\
		\"weight\": 1293,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.totalBenefit\",\
		\"weight\": 1294,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment\",\
		\"weight\": 1295,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.id\",\
		\"weight\": 1296,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.extension\",\
		\"weight\": 1297,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.modifierExtension\",\
		\"weight\": 1298,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.type\",\
		\"weight\": 1299,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.adjustment\",\
		\"weight\": 1300,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.adjustmentReason\",\
		\"weight\": 1301,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.date\",\
		\"weight\": 1302,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.amount\",\
		\"weight\": 1303,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.payment.identifier\",\
		\"weight\": 1304,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.reserved\",\
		\"weight\": 1305,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.form\",\
		\"weight\": 1306,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.processNote\",\
		\"weight\": 1307,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.processNote.id\",\
		\"weight\": 1308,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.processNote.extension\",\
		\"weight\": 1309,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.processNote.modifierExtension\",\
		\"weight\": 1310,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.processNote.number\",\
		\"weight\": 1311,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.processNote.type\",\
		\"weight\": 1312,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.processNote.text\",\
		\"weight\": 1313,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.processNote.language\",\
		\"weight\": 1314,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.communicationRequest\",\
		\"weight\": 1315,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.insurance\",\
		\"weight\": 1316,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.insurance.id\",\
		\"weight\": 1317,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.insurance.extension\",\
		\"weight\": 1318,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.insurance.modifierExtension\",\
		\"weight\": 1319,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClaimResponse.insurance.sequence\",\
		\"weight\": 1320,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClaimResponse.insurance.focal\",\
		\"weight\": 1321,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClaimResponse.insurance.coverage\",\
		\"weight\": 1322,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.insurance.businessArrangement\",\
		\"weight\": 1323,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.insurance.preAuthRef\",\
		\"weight\": 1324,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClaimResponse.insurance.claimResponse\",\
		\"weight\": 1325,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression\",\
		\"weight\": 1326,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.id\",\
		\"weight\": 1327,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.meta\",\
		\"weight\": 1328,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.implicitRules\",\
		\"weight\": 1329,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.language\",\
		\"weight\": 1330,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.text\",\
		\"weight\": 1331,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.contained\",\
		\"weight\": 1332,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.extension\",\
		\"weight\": 1333,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.modifierExtension\",\
		\"weight\": 1334,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.identifier\",\
		\"weight\": 1335,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClinicalImpression.status\",\
		\"weight\": 1336,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.code\",\
		\"weight\": 1337,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.description\",\
		\"weight\": 1338,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClinicalImpression.subject\",\
		\"weight\": 1339,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.context\",\
		\"weight\": 1340,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.effectiveDateTime\",\
		\"weight\": 1341,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.effectivePeriod\",\
		\"weight\": 1341,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.date\",\
		\"weight\": 1342,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.assessor\",\
		\"weight\": 1343,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.previous\",\
		\"weight\": 1344,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.problem\",\
		\"weight\": 1345,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.investigation\",\
		\"weight\": 1346,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.investigation.id\",\
		\"weight\": 1347,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.investigation.extension\",\
		\"weight\": 1348,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.investigation.modifierExtension\",\
		\"weight\": 1349,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClinicalImpression.investigation.code\",\
		\"weight\": 1350,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.investigation.item\",\
		\"weight\": 1351,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.protocol\",\
		\"weight\": 1352,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.summary\",\
		\"weight\": 1353,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.finding\",\
		\"weight\": 1354,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.finding.id\",\
		\"weight\": 1355,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.finding.extension\",\
		\"weight\": 1356,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.finding.modifierExtension\",\
		\"weight\": 1357,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClinicalImpression.finding.itemCodeableConcept\",\
		\"weight\": 1358,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClinicalImpression.finding.itemReference\",\
		\"weight\": 1358,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ClinicalImpression.finding.itemReference\",\
		\"weight\": 1358,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.finding.basis\",\
		\"weight\": 1359,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.prognosisCodeableConcept\",\
		\"weight\": 1360,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.prognosisReference\",\
		\"weight\": 1361,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.action\",\
		\"weight\": 1362,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ClinicalImpression.note\",\
		\"weight\": 1363,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem\",\
		\"weight\": 1364,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.id\",\
		\"weight\": 1365,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.meta\",\
		\"weight\": 1366,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.implicitRules\",\
		\"weight\": 1367,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.language\",\
		\"weight\": 1368,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.text\",\
		\"weight\": 1369,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.contained\",\
		\"weight\": 1370,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.extension\",\
		\"weight\": 1371,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.modifierExtension\",\
		\"weight\": 1372,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.url\",\
		\"weight\": 1373,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.identifier\",\
		\"weight\": 1374,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.version\",\
		\"weight\": 1375,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.name\",\
		\"weight\": 1376,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.title\",\
		\"weight\": 1377,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.status\",\
		\"weight\": 1378,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.experimental\",\
		\"weight\": 1379,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.date\",\
		\"weight\": 1380,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.publisher\",\
		\"weight\": 1381,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.contact\",\
		\"weight\": 1382,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.description\",\
		\"weight\": 1383,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.useContext\",\
		\"weight\": 1384,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.jurisdiction\",\
		\"weight\": 1385,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.purpose\",\
		\"weight\": 1386,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.copyright\",\
		\"weight\": 1387,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.caseSensitive\",\
		\"weight\": 1388,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.valueSet\",\
		\"weight\": 1389,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.hierarchyMeaning\",\
		\"weight\": 1390,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.compositional\",\
		\"weight\": 1391,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.versionNeeded\",\
		\"weight\": 1392,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.content\",\
		\"weight\": 1393,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.count\",\
		\"weight\": 1394,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.filter\",\
		\"weight\": 1395,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.filter.id\",\
		\"weight\": 1396,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.filter.extension\",\
		\"weight\": 1397,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.filter.modifierExtension\",\
		\"weight\": 1398,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.filter.code\",\
		\"weight\": 1399,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.filter.description\",\
		\"weight\": 1400,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.filter.operator\",\
		\"weight\": 1401,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.filter.value\",\
		\"weight\": 1402,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.property\",\
		\"weight\": 1403,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.property.id\",\
		\"weight\": 1404,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.property.extension\",\
		\"weight\": 1405,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.property.modifierExtension\",\
		\"weight\": 1406,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.property.code\",\
		\"weight\": 1407,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.property.uri\",\
		\"weight\": 1408,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.property.description\",\
		\"weight\": 1409,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.property.type\",\
		\"weight\": 1410,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept\",\
		\"weight\": 1411,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.id\",\
		\"weight\": 1412,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.extension\",\
		\"weight\": 1413,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.modifierExtension\",\
		\"weight\": 1414,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.code\",\
		\"weight\": 1415,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.display\",\
		\"weight\": 1416,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.definition\",\
		\"weight\": 1417,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.designation\",\
		\"weight\": 1418,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.designation.id\",\
		\"weight\": 1419,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.designation.extension\",\
		\"weight\": 1420,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.designation.modifierExtension\",\
		\"weight\": 1421,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.designation.language\",\
		\"weight\": 1422,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.designation.use\",\
		\"weight\": 1423,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.designation.value\",\
		\"weight\": 1424,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.property\",\
		\"weight\": 1425,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.property.id\",\
		\"weight\": 1426,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.property.extension\",\
		\"weight\": 1427,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.property.modifierExtension\",\
		\"weight\": 1428,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.property.code\",\
		\"weight\": 1429,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.property.valueCode\",\
		\"weight\": 1430,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.property.valueCoding\",\
		\"weight\": 1430,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.property.valueString\",\
		\"weight\": 1430,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.property.valueInteger\",\
		\"weight\": 1430,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.property.valueBoolean\",\
		\"weight\": 1430,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CodeSystem.concept.property.valueDateTime\",\
		\"weight\": 1430,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CodeSystem.concept.concept\",\
		\"weight\": 1431,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication\",\
		\"weight\": 1432,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.id\",\
		\"weight\": 1433,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.meta\",\
		\"weight\": 1434,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.implicitRules\",\
		\"weight\": 1435,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.language\",\
		\"weight\": 1436,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.text\",\
		\"weight\": 1437,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.contained\",\
		\"weight\": 1438,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.extension\",\
		\"weight\": 1439,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.modifierExtension\",\
		\"weight\": 1440,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.identifier\",\
		\"weight\": 1441,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.definition\",\
		\"weight\": 1442,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.basedOn\",\
		\"weight\": 1443,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.partOf\",\
		\"weight\": 1444,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Communication.status\",\
		\"weight\": 1445,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.notDone\",\
		\"weight\": 1446,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.notDoneReason\",\
		\"weight\": 1447,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.category\",\
		\"weight\": 1448,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.medium\",\
		\"weight\": 1449,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.subject\",\
		\"weight\": 1450,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.recipient\",\
		\"weight\": 1451,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.topic\",\
		\"weight\": 1452,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.context\",\
		\"weight\": 1453,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.sent\",\
		\"weight\": 1454,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.received\",\
		\"weight\": 1455,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.sender\",\
		\"weight\": 1456,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.reasonCode\",\
		\"weight\": 1457,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.reasonReference\",\
		\"weight\": 1458,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.payload\",\
		\"weight\": 1459,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.payload.id\",\
		\"weight\": 1460,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.payload.extension\",\
		\"weight\": 1461,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.payload.modifierExtension\",\
		\"weight\": 1462,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Communication.payload.contentString\",\
		\"weight\": 1463,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Communication.payload.contentAttachment\",\
		\"weight\": 1463,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Communication.payload.contentReference\",\
		\"weight\": 1463,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Communication.note\",\
		\"weight\": 1464,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest\",\
		\"weight\": 1465,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.id\",\
		\"weight\": 1466,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.meta\",\
		\"weight\": 1467,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.implicitRules\",\
		\"weight\": 1468,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.language\",\
		\"weight\": 1469,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.text\",\
		\"weight\": 1470,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.contained\",\
		\"weight\": 1471,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.extension\",\
		\"weight\": 1472,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.modifierExtension\",\
		\"weight\": 1473,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.identifier\",\
		\"weight\": 1474,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.basedOn\",\
		\"weight\": 1475,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.replaces\",\
		\"weight\": 1476,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.groupIdentifier\",\
		\"weight\": 1477,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CommunicationRequest.status\",\
		\"weight\": 1478,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.category\",\
		\"weight\": 1479,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.priority\",\
		\"weight\": 1480,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.medium\",\
		\"weight\": 1481,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.subject\",\
		\"weight\": 1482,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.recipient\",\
		\"weight\": 1483,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.topic\",\
		\"weight\": 1484,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.context\",\
		\"weight\": 1485,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.payload\",\
		\"weight\": 1486,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.payload.id\",\
		\"weight\": 1487,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.payload.extension\",\
		\"weight\": 1488,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.payload.modifierExtension\",\
		\"weight\": 1489,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CommunicationRequest.payload.contentString\",\
		\"weight\": 1490,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CommunicationRequest.payload.contentAttachment\",\
		\"weight\": 1490,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CommunicationRequest.payload.contentReference\",\
		\"weight\": 1490,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.occurrenceDateTime\",\
		\"weight\": 1491,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.occurrencePeriod\",\
		\"weight\": 1491,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.authoredOn\",\
		\"weight\": 1492,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.sender\",\
		\"weight\": 1493,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.requester\",\
		\"weight\": 1494,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.requester.id\",\
		\"weight\": 1495,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.requester.extension\",\
		\"weight\": 1496,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.requester.modifierExtension\",\
		\"weight\": 1497,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CommunicationRequest.requester.agent\",\
		\"weight\": 1498,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.requester.onBehalfOf\",\
		\"weight\": 1499,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.reasonCode\",\
		\"weight\": 1500,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.reasonReference\",\
		\"weight\": 1501,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CommunicationRequest.note\",\
		\"weight\": 1502,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CompartmentDefinition\",\
		\"weight\": 1503,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.id\",\
		\"weight\": 1504,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.meta\",\
		\"weight\": 1505,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.implicitRules\",\
		\"weight\": 1506,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.language\",\
		\"weight\": 1507,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.text\",\
		\"weight\": 1508,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.contained\",\
		\"weight\": 1509,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.extension\",\
		\"weight\": 1510,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.modifierExtension\",\
		\"weight\": 1511,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CompartmentDefinition.url\",\
		\"weight\": 1512,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CompartmentDefinition.name\",\
		\"weight\": 1513,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.title\",\
		\"weight\": 1514,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CompartmentDefinition.status\",\
		\"weight\": 1515,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.experimental\",\
		\"weight\": 1516,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.date\",\
		\"weight\": 1517,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.publisher\",\
		\"weight\": 1518,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.contact\",\
		\"weight\": 1519,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.description\",\
		\"weight\": 1520,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.purpose\",\
		\"weight\": 1521,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.useContext\",\
		\"weight\": 1522,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.jurisdiction\",\
		\"weight\": 1523,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CompartmentDefinition.code\",\
		\"weight\": 1524,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CompartmentDefinition.search\",\
		\"weight\": 1525,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.resource\",\
		\"weight\": 1526,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.resource.id\",\
		\"weight\": 1527,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.resource.extension\",\
		\"weight\": 1528,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.resource.modifierExtension\",\
		\"weight\": 1529,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"CompartmentDefinition.resource.code\",\
		\"weight\": 1530,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.resource.param\",\
		\"weight\": 1531,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"CompartmentDefinition.resource.documentation\",\
		\"weight\": 1532,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition\",\
		\"weight\": 1533,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.id\",\
		\"weight\": 1534,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.meta\",\
		\"weight\": 1535,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.implicitRules\",\
		\"weight\": 1536,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.language\",\
		\"weight\": 1537,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.text\",\
		\"weight\": 1538,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.contained\",\
		\"weight\": 1539,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.extension\",\
		\"weight\": 1540,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.modifierExtension\",\
		\"weight\": 1541,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.identifier\",\
		\"weight\": 1542,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.status\",\
		\"weight\": 1543,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.type\",\
		\"weight\": 1544,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.class\",\
		\"weight\": 1545,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.subject\",\
		\"weight\": 1546,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.encounter\",\
		\"weight\": 1547,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.date\",\
		\"weight\": 1548,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.author\",\
		\"weight\": 1549,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.title\",\
		\"weight\": 1550,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.confidentiality\",\
		\"weight\": 1551,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.attester\",\
		\"weight\": 1552,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.attester.id\",\
		\"weight\": 1553,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.attester.extension\",\
		\"weight\": 1554,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.attester.modifierExtension\",\
		\"weight\": 1555,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.attester.mode\",\
		\"weight\": 1556,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.attester.time\",\
		\"weight\": 1557,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.attester.party\",\
		\"weight\": 1558,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.custodian\",\
		\"weight\": 1559,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.relatesTo\",\
		\"weight\": 1560,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.relatesTo.id\",\
		\"weight\": 1561,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.relatesTo.extension\",\
		\"weight\": 1562,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.relatesTo.modifierExtension\",\
		\"weight\": 1563,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.relatesTo.code\",\
		\"weight\": 1564,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.relatesTo.targetIdentifier\",\
		\"weight\": 1565,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Composition.relatesTo.targetReference\",\
		\"weight\": 1565,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.event\",\
		\"weight\": 1566,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.event.id\",\
		\"weight\": 1567,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.event.extension\",\
		\"weight\": 1568,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.event.modifierExtension\",\
		\"weight\": 1569,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.event.code\",\
		\"weight\": 1570,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.event.period\",\
		\"weight\": 1571,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.event.detail\",\
		\"weight\": 1572,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section\",\
		\"weight\": 1573,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.id\",\
		\"weight\": 1574,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.extension\",\
		\"weight\": 1575,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.modifierExtension\",\
		\"weight\": 1576,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.title\",\
		\"weight\": 1577,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.code\",\
		\"weight\": 1578,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.text\",\
		\"weight\": 1579,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.mode\",\
		\"weight\": 1580,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.orderedBy\",\
		\"weight\": 1581,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.entry\",\
		\"weight\": 1582,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.emptyReason\",\
		\"weight\": 1583,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Composition.section.section\",\
		\"weight\": 1584,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap\",\
		\"weight\": 1585,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.id\",\
		\"weight\": 1586,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.meta\",\
		\"weight\": 1587,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.implicitRules\",\
		\"weight\": 1588,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.language\",\
		\"weight\": 1589,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.text\",\
		\"weight\": 1590,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.contained\",\
		\"weight\": 1591,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.extension\",\
		\"weight\": 1592,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.modifierExtension\",\
		\"weight\": 1593,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.url\",\
		\"weight\": 1594,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.identifier\",\
		\"weight\": 1595,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.version\",\
		\"weight\": 1596,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.name\",\
		\"weight\": 1597,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.title\",\
		\"weight\": 1598,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ConceptMap.status\",\
		\"weight\": 1599,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.experimental\",\
		\"weight\": 1600,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.date\",\
		\"weight\": 1601,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.publisher\",\
		\"weight\": 1602,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.contact\",\
		\"weight\": 1603,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.description\",\
		\"weight\": 1604,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.useContext\",\
		\"weight\": 1605,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.jurisdiction\",\
		\"weight\": 1606,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.purpose\",\
		\"weight\": 1607,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.copyright\",\
		\"weight\": 1608,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.sourceUri\",\
		\"weight\": 1609,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.sourceReference\",\
		\"weight\": 1609,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.targetUri\",\
		\"weight\": 1610,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.targetReference\",\
		\"weight\": 1610,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group\",\
		\"weight\": 1611,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.id\",\
		\"weight\": 1612,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.extension\",\
		\"weight\": 1613,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.modifierExtension\",\
		\"weight\": 1614,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.source\",\
		\"weight\": 1615,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.sourceVersion\",\
		\"weight\": 1616,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.target\",\
		\"weight\": 1617,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.targetVersion\",\
		\"weight\": 1618,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ConceptMap.group.element\",\
		\"weight\": 1619,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.id\",\
		\"weight\": 1620,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.extension\",\
		\"weight\": 1621,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.modifierExtension\",\
		\"weight\": 1622,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.code\",\
		\"weight\": 1623,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.display\",\
		\"weight\": 1624,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target\",\
		\"weight\": 1625,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.id\",\
		\"weight\": 1626,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.extension\",\
		\"weight\": 1627,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.modifierExtension\",\
		\"weight\": 1628,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.code\",\
		\"weight\": 1629,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.display\",\
		\"weight\": 1630,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.equivalence\",\
		\"weight\": 1631,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.comment\",\
		\"weight\": 1632,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.dependsOn\",\
		\"weight\": 1633,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.dependsOn.id\",\
		\"weight\": 1634,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.dependsOn.extension\",\
		\"weight\": 1635,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.dependsOn.modifierExtension\",\
		\"weight\": 1636,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ConceptMap.group.element.target.dependsOn.property\",\
		\"weight\": 1637,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.dependsOn.system\",\
		\"weight\": 1638,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ConceptMap.group.element.target.dependsOn.code\",\
		\"weight\": 1639,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.dependsOn.display\",\
		\"weight\": 1640,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.element.target.product\",\
		\"weight\": 1641,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.unmapped\",\
		\"weight\": 1642,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.unmapped.id\",\
		\"weight\": 1643,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.unmapped.extension\",\
		\"weight\": 1644,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.unmapped.modifierExtension\",\
		\"weight\": 1645,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ConceptMap.group.unmapped.mode\",\
		\"weight\": 1646,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.unmapped.code\",\
		\"weight\": 1647,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.unmapped.display\",\
		\"weight\": 1648,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ConceptMap.group.unmapped.url\",\
		\"weight\": 1649,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition\",\
		\"weight\": 1650,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.id\",\
		\"weight\": 1651,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.meta\",\
		\"weight\": 1652,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.implicitRules\",\
		\"weight\": 1653,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.language\",\
		\"weight\": 1654,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.text\",\
		\"weight\": 1655,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.contained\",\
		\"weight\": 1656,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.extension\",\
		\"weight\": 1657,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.modifierExtension\",\
		\"weight\": 1658,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.identifier\",\
		\"weight\": 1659,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.clinicalStatus\",\
		\"weight\": 1660,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.verificationStatus\",\
		\"weight\": 1661,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.category\",\
		\"weight\": 1662,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.severity\",\
		\"weight\": 1663,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.code\",\
		\"weight\": 1664,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.bodySite\",\
		\"weight\": 1665,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Condition.subject\",\
		\"weight\": 1666,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.context\",\
		\"weight\": 1667,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.onsetDateTime\",\
		\"weight\": 1668,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.onsetAge\",\
		\"weight\": 1668,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.onsetPeriod\",\
		\"weight\": 1668,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.onsetRange\",\
		\"weight\": 1668,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.onsetString\",\
		\"weight\": 1668,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.abatementDateTime\",\
		\"weight\": 1669,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.abatementAge\",\
		\"weight\": 1669,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.abatementBoolean\",\
		\"weight\": 1669,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.abatementPeriod\",\
		\"weight\": 1669,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.abatementRange\",\
		\"weight\": 1669,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.abatementString\",\
		\"weight\": 1669,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.assertedDate\",\
		\"weight\": 1670,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.asserter\",\
		\"weight\": 1671,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.stage\",\
		\"weight\": 1672,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.stage.id\",\
		\"weight\": 1673,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.stage.extension\",\
		\"weight\": 1674,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.stage.modifierExtension\",\
		\"weight\": 1675,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.stage.summary\",\
		\"weight\": 1676,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.stage.assessment\",\
		\"weight\": 1677,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.evidence\",\
		\"weight\": 1678,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.evidence.id\",\
		\"weight\": 1679,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.evidence.extension\",\
		\"weight\": 1680,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.evidence.modifierExtension\",\
		\"weight\": 1681,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.evidence.code\",\
		\"weight\": 1682,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.evidence.detail\",\
		\"weight\": 1683,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Condition.note\",\
		\"weight\": 1684,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent\",\
		\"weight\": 1685,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.id\",\
		\"weight\": 1686,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.meta\",\
		\"weight\": 1687,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.implicitRules\",\
		\"weight\": 1688,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.language\",\
		\"weight\": 1689,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.text\",\
		\"weight\": 1690,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.contained\",\
		\"weight\": 1691,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.extension\",\
		\"weight\": 1692,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.modifierExtension\",\
		\"weight\": 1693,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.identifier\",\
		\"weight\": 1694,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.status\",\
		\"weight\": 1695,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.category\",\
		\"weight\": 1696,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.patient\",\
		\"weight\": 1697,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.period\",\
		\"weight\": 1698,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.dateTime\",\
		\"weight\": 1699,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.consentingParty\",\
		\"weight\": 1700,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.actor\",\
		\"weight\": 1701,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.actor.id\",\
		\"weight\": 1702,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.actor.extension\",\
		\"weight\": 1703,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.actor.modifierExtension\",\
		\"weight\": 1704,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.actor.role\",\
		\"weight\": 1705,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.actor.reference\",\
		\"weight\": 1706,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.action\",\
		\"weight\": 1707,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.organization\",\
		\"weight\": 1708,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.sourceAttachment\",\
		\"weight\": 1709,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.sourceIdentifier\",\
		\"weight\": 1709,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1709,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1709,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1709,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.sourceReference\",\
		\"weight\": 1709,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.policy\",\
		\"weight\": 1710,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.policy.id\",\
		\"weight\": 1711,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.policy.extension\",\
		\"weight\": 1712,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.policy.modifierExtension\",\
		\"weight\": 1713,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.policy.authority\",\
		\"weight\": 1714,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.policy.uri\",\
		\"weight\": 1715,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.policyRule\",\
		\"weight\": 1716,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.securityLabel\",\
		\"weight\": 1717,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.purpose\",\
		\"weight\": 1718,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.dataPeriod\",\
		\"weight\": 1719,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.data\",\
		\"weight\": 1720,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.data.id\",\
		\"weight\": 1721,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.data.extension\",\
		\"weight\": 1722,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.data.modifierExtension\",\
		\"weight\": 1723,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.data.meaning\",\
		\"weight\": 1724,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.data.reference\",\
		\"weight\": 1725,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except\",\
		\"weight\": 1726,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.id\",\
		\"weight\": 1727,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.extension\",\
		\"weight\": 1728,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.modifierExtension\",\
		\"weight\": 1729,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.except.type\",\
		\"weight\": 1730,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.period\",\
		\"weight\": 1731,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.actor\",\
		\"weight\": 1732,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.actor.id\",\
		\"weight\": 1733,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.actor.extension\",\
		\"weight\": 1734,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.actor.modifierExtension\",\
		\"weight\": 1735,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.except.actor.role\",\
		\"weight\": 1736,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.except.actor.reference\",\
		\"weight\": 1737,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.action\",\
		\"weight\": 1738,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.securityLabel\",\
		\"weight\": 1739,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.purpose\",\
		\"weight\": 1740,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.class\",\
		\"weight\": 1741,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.code\",\
		\"weight\": 1742,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.dataPeriod\",\
		\"weight\": 1743,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.data\",\
		\"weight\": 1744,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.data.id\",\
		\"weight\": 1745,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.data.extension\",\
		\"weight\": 1746,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Consent.except.data.modifierExtension\",\
		\"weight\": 1747,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.except.data.meaning\",\
		\"weight\": 1748,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Consent.except.data.reference\",\
		\"weight\": 1749,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract\",\
		\"weight\": 1750,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.id\",\
		\"weight\": 1751,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.meta\",\
		\"weight\": 1752,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.implicitRules\",\
		\"weight\": 1753,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.language\",\
		\"weight\": 1754,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.text\",\
		\"weight\": 1755,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.contained\",\
		\"weight\": 1756,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.extension\",\
		\"weight\": 1757,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.modifierExtension\",\
		\"weight\": 1758,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.identifier\",\
		\"weight\": 1759,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.status\",\
		\"weight\": 1760,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.issued\",\
		\"weight\": 1761,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.applies\",\
		\"weight\": 1762,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.subject\",\
		\"weight\": 1763,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.topic\",\
		\"weight\": 1764,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.authority\",\
		\"weight\": 1765,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.domain\",\
		\"weight\": 1766,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.type\",\
		\"weight\": 1767,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.subType\",\
		\"weight\": 1768,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.action\",\
		\"weight\": 1769,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.actionReason\",\
		\"weight\": 1770,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.decisionType\",\
		\"weight\": 1771,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.contentDerivative\",\
		\"weight\": 1772,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.securityLabel\",\
		\"weight\": 1773,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.agent\",\
		\"weight\": 1774,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.agent.id\",\
		\"weight\": 1775,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.agent.extension\",\
		\"weight\": 1776,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.agent.modifierExtension\",\
		\"weight\": 1777,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.agent.actor\",\
		\"weight\": 1778,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.agent.role\",\
		\"weight\": 1779,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.signer\",\
		\"weight\": 1780,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.signer.id\",\
		\"weight\": 1781,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.signer.extension\",\
		\"weight\": 1782,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.signer.modifierExtension\",\
		\"weight\": 1783,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.signer.type\",\
		\"weight\": 1784,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.signer.party\",\
		\"weight\": 1785,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.signer.signature\",\
		\"weight\": 1786,\
		\"max\": \"*\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem\",\
		\"weight\": 1787,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.id\",\
		\"weight\": 1788,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.extension\",\
		\"weight\": 1789,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.modifierExtension\",\
		\"weight\": 1790,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.entityCodeableConcept\",\
		\"weight\": 1791,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.entityReference\",\
		\"weight\": 1791,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.identifier\",\
		\"weight\": 1792,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.effectiveTime\",\
		\"weight\": 1793,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.quantity\",\
		\"weight\": 1794,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.unitPrice\",\
		\"weight\": 1795,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.factor\",\
		\"weight\": 1796,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.points\",\
		\"weight\": 1797,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.valuedItem.net\",\
		\"weight\": 1798,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term\",\
		\"weight\": 1799,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.id\",\
		\"weight\": 1800,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.extension\",\
		\"weight\": 1801,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.modifierExtension\",\
		\"weight\": 1802,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.identifier\",\
		\"weight\": 1803,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.issued\",\
		\"weight\": 1804,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.applies\",\
		\"weight\": 1805,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.type\",\
		\"weight\": 1806,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.subType\",\
		\"weight\": 1807,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.topic\",\
		\"weight\": 1808,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.action\",\
		\"weight\": 1809,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.actionReason\",\
		\"weight\": 1810,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.securityLabel\",\
		\"weight\": 1811,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.agent\",\
		\"weight\": 1812,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.agent.id\",\
		\"weight\": 1813,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.agent.extension\",\
		\"weight\": 1814,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.agent.modifierExtension\",\
		\"weight\": 1815,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.term.agent.actor\",\
		\"weight\": 1816,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.agent.role\",\
		\"weight\": 1817,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.text\",\
		\"weight\": 1818,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem\",\
		\"weight\": 1819,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.id\",\
		\"weight\": 1820,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.extension\",\
		\"weight\": 1821,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.modifierExtension\",\
		\"weight\": 1822,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.entityCodeableConcept\",\
		\"weight\": 1823,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.entityReference\",\
		\"weight\": 1823,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.identifier\",\
		\"weight\": 1824,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.effectiveTime\",\
		\"weight\": 1825,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.quantity\",\
		\"weight\": 1826,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.unitPrice\",\
		\"weight\": 1827,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.factor\",\
		\"weight\": 1828,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.points\",\
		\"weight\": 1829,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.valuedItem.net\",\
		\"weight\": 1830,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.term.group\",\
		\"weight\": 1831,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.bindingAttachment\",\
		\"weight\": 1832,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1832,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1832,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1832,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.friendly\",\
		\"weight\": 1833,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.friendly.id\",\
		\"weight\": 1834,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.friendly.extension\",\
		\"weight\": 1835,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.friendly.modifierExtension\",\
		\"weight\": 1836,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.friendly.contentAttachment\",\
		\"weight\": 1837,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1837,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1837,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1837,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.legal\",\
		\"weight\": 1838,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.legal.id\",\
		\"weight\": 1839,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.legal.extension\",\
		\"weight\": 1840,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.legal.modifierExtension\",\
		\"weight\": 1841,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.legal.contentAttachment\",\
		\"weight\": 1842,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1842,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1842,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1842,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.rule\",\
		\"weight\": 1843,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.rule.id\",\
		\"weight\": 1844,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.rule.extension\",\
		\"weight\": 1845,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Contract.rule.modifierExtension\",\
		\"weight\": 1846,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.rule.contentAttachment\",\
		\"weight\": 1847,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Contract.rule.contentReference\",\
		\"weight\": 1847,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage\",\
		\"weight\": 1848,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.id\",\
		\"weight\": 1849,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.meta\",\
		\"weight\": 1850,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.implicitRules\",\
		\"weight\": 1851,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.language\",\
		\"weight\": 1852,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.text\",\
		\"weight\": 1853,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.contained\",\
		\"weight\": 1854,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.extension\",\
		\"weight\": 1855,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.modifierExtension\",\
		\"weight\": 1856,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.identifier\",\
		\"weight\": 1857,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.status\",\
		\"weight\": 1858,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.type\",\
		\"weight\": 1859,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.policyHolder\",\
		\"weight\": 1860,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.subscriber\",\
		\"weight\": 1861,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.subscriberId\",\
		\"weight\": 1862,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.beneficiary\",\
		\"weight\": 1863,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.relationship\",\
		\"weight\": 1864,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.period\",\
		\"weight\": 1865,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.payor\",\
		\"weight\": 1866,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping\",\
		\"weight\": 1867,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.id\",\
		\"weight\": 1868,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.extension\",\
		\"weight\": 1869,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.modifierExtension\",\
		\"weight\": 1870,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.group\",\
		\"weight\": 1871,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.groupDisplay\",\
		\"weight\": 1872,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.subGroup\",\
		\"weight\": 1873,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.subGroupDisplay\",\
		\"weight\": 1874,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.plan\",\
		\"weight\": 1875,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.planDisplay\",\
		\"weight\": 1876,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.subPlan\",\
		\"weight\": 1877,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.subPlanDisplay\",\
		\"weight\": 1878,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.class\",\
		\"weight\": 1879,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.classDisplay\",\
		\"weight\": 1880,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.subClass\",\
		\"weight\": 1881,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.grouping.subClassDisplay\",\
		\"weight\": 1882,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.dependent\",\
		\"weight\": 1883,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.sequence\",\
		\"weight\": 1884,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.order\",\
		\"weight\": 1885,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.network\",\
		\"weight\": 1886,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Coverage.contract\",\
		\"weight\": 1887,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement\",\
		\"weight\": 1888,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.id\",\
		\"weight\": 1889,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.meta\",\
		\"weight\": 1890,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.implicitRules\",\
		\"weight\": 1891,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.language\",\
		\"weight\": 1892,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.text\",\
		\"weight\": 1893,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.contained\",\
		\"weight\": 1894,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.extension\",\
		\"weight\": 1895,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.modifierExtension\",\
		\"weight\": 1896,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.url\",\
		\"weight\": 1897,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.identifier\",\
		\"weight\": 1898,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.version\",\
		\"weight\": 1899,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DataElement.status\",\
		\"weight\": 1900,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.experimental\",\
		\"weight\": 1901,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.date\",\
		\"weight\": 1902,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.publisher\",\
		\"weight\": 1903,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.name\",\
		\"weight\": 1904,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.title\",\
		\"weight\": 1905,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.contact\",\
		\"weight\": 1906,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.useContext\",\
		\"weight\": 1907,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.jurisdiction\",\
		\"weight\": 1908,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.copyright\",\
		\"weight\": 1909,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.stringency\",\
		\"weight\": 1910,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.mapping\",\
		\"weight\": 1911,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.mapping.id\",\
		\"weight\": 1912,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.mapping.extension\",\
		\"weight\": 1913,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.mapping.modifierExtension\",\
		\"weight\": 1914,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DataElement.mapping.identity\",\
		\"weight\": 1915,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.mapping.uri\",\
		\"weight\": 1916,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.mapping.name\",\
		\"weight\": 1917,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DataElement.mapping.comment\",\
		\"weight\": 1918,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DataElement.element\",\
		\"weight\": 1919,\
		\"max\": \"*\",\
		\"type\": \"ElementDefinition\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue\",\
		\"weight\": 1920,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.id\",\
		\"weight\": 1921,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.meta\",\
		\"weight\": 1922,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.implicitRules\",\
		\"weight\": 1923,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.language\",\
		\"weight\": 1924,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.text\",\
		\"weight\": 1925,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.contained\",\
		\"weight\": 1926,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.extension\",\
		\"weight\": 1927,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.modifierExtension\",\
		\"weight\": 1928,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.identifier\",\
		\"weight\": 1929,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DetectedIssue.status\",\
		\"weight\": 1930,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.category\",\
		\"weight\": 1931,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.severity\",\
		\"weight\": 1932,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.patient\",\
		\"weight\": 1933,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.date\",\
		\"weight\": 1934,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.author\",\
		\"weight\": 1935,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.implicated\",\
		\"weight\": 1936,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.detail\",\
		\"weight\": 1937,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.reference\",\
		\"weight\": 1938,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.mitigation\",\
		\"weight\": 1939,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.mitigation.id\",\
		\"weight\": 1940,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.mitigation.extension\",\
		\"weight\": 1941,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.mitigation.modifierExtension\",\
		\"weight\": 1942,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DetectedIssue.mitigation.action\",\
		\"weight\": 1943,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.mitigation.date\",\
		\"weight\": 1944,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DetectedIssue.mitigation.author\",\
		\"weight\": 1945,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device\",\
		\"weight\": 1946,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.id\",\
		\"weight\": 1947,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.meta\",\
		\"weight\": 1948,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.implicitRules\",\
		\"weight\": 1949,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.language\",\
		\"weight\": 1950,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.text\",\
		\"weight\": 1951,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.contained\",\
		\"weight\": 1952,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.extension\",\
		\"weight\": 1953,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.modifierExtension\",\
		\"weight\": 1954,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.identifier\",\
		\"weight\": 1955,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi\",\
		\"weight\": 1956,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.id\",\
		\"weight\": 1957,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.extension\",\
		\"weight\": 1958,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.modifierExtension\",\
		\"weight\": 1959,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.deviceIdentifier\",\
		\"weight\": 1960,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.name\",\
		\"weight\": 1961,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.jurisdiction\",\
		\"weight\": 1962,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.carrierHRF\",\
		\"weight\": 1963,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.carrierAIDC\",\
		\"weight\": 1964,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.issuer\",\
		\"weight\": 1965,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.udi.entryType\",\
		\"weight\": 1966,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.status\",\
		\"weight\": 1967,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.type\",\
		\"weight\": 1968,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.lotNumber\",\
		\"weight\": 1969,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.manufacturer\",\
		\"weight\": 1970,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.manufactureDate\",\
		\"weight\": 1971,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.expirationDate\",\
		\"weight\": 1972,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.model\",\
		\"weight\": 1973,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.version\",\
		\"weight\": 1974,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.patient\",\
		\"weight\": 1975,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.owner\",\
		\"weight\": 1976,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.contact\",\
		\"weight\": 1977,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.location\",\
		\"weight\": 1978,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.url\",\
		\"weight\": 1979,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.note\",\
		\"weight\": 1980,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Device.safety\",\
		\"weight\": 1981,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent\",\
		\"weight\": 1982,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.id\",\
		\"weight\": 1983,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.meta\",\
		\"weight\": 1984,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.implicitRules\",\
		\"weight\": 1985,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.language\",\
		\"weight\": 1986,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.text\",\
		\"weight\": 1987,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.contained\",\
		\"weight\": 1988,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.extension\",\
		\"weight\": 1989,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.modifierExtension\",\
		\"weight\": 1990,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceComponent.identifier\",\
		\"weight\": 1991,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceComponent.type\",\
		\"weight\": 1992,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.lastSystemChange\",\
		\"weight\": 1993,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.source\",\
		\"weight\": 1994,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.parent\",\
		\"weight\": 1995,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.operationalStatus\",\
		\"weight\": 1996,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.parameterGroup\",\
		\"weight\": 1997,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.measurementPrinciple\",\
		\"weight\": 1998,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.productionSpecification\",\
		\"weight\": 1999,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.productionSpecification.id\",\
		\"weight\": 2000,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.productionSpecification.extension\",\
		\"weight\": 2001,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.productionSpecification.modifierExtension\",\
		\"weight\": 2002,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.productionSpecification.specType\",\
		\"weight\": 2003,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.productionSpecification.componentId\",\
		\"weight\": 2004,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.productionSpecification.productionSpec\",\
		\"weight\": 2005,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceComponent.languageCode\",\
		\"weight\": 2006,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric\",\
		\"weight\": 2007,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.id\",\
		\"weight\": 2008,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.meta\",\
		\"weight\": 2009,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.implicitRules\",\
		\"weight\": 2010,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.language\",\
		\"weight\": 2011,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.text\",\
		\"weight\": 2012,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.contained\",\
		\"weight\": 2013,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.extension\",\
		\"weight\": 2014,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.modifierExtension\",\
		\"weight\": 2015,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceMetric.identifier\",\
		\"weight\": 2016,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceMetric.type\",\
		\"weight\": 2017,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.unit\",\
		\"weight\": 2018,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.source\",\
		\"weight\": 2019,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.parent\",\
		\"weight\": 2020,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.operationalStatus\",\
		\"weight\": 2021,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.color\",\
		\"weight\": 2022,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceMetric.category\",\
		\"weight\": 2023,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.measurementPeriod\",\
		\"weight\": 2024,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.calibration\",\
		\"weight\": 2025,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.calibration.id\",\
		\"weight\": 2026,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.calibration.extension\",\
		\"weight\": 2027,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.calibration.modifierExtension\",\
		\"weight\": 2028,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.calibration.type\",\
		\"weight\": 2029,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.calibration.state\",\
		\"weight\": 2030,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceMetric.calibration.time\",\
		\"weight\": 2031,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest\",\
		\"weight\": 2032,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.id\",\
		\"weight\": 2033,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.meta\",\
		\"weight\": 2034,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.implicitRules\",\
		\"weight\": 2035,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.language\",\
		\"weight\": 2036,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.text\",\
		\"weight\": 2037,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.contained\",\
		\"weight\": 2038,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.extension\",\
		\"weight\": 2039,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.modifierExtension\",\
		\"weight\": 2040,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.identifier\",\
		\"weight\": 2041,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.definition\",\
		\"weight\": 2042,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.basedOn\",\
		\"weight\": 2043,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.priorRequest\",\
		\"weight\": 2044,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.groupIdentifier\",\
		\"weight\": 2045,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.status\",\
		\"weight\": 2046,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceRequest.intent\",\
		\"weight\": 2047,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.priority\",\
		\"weight\": 2048,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceRequest.codeReference\",\
		\"weight\": 2049,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceRequest.codeCodeableConcept\",\
		\"weight\": 2049,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceRequest.subject\",\
		\"weight\": 2050,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.context\",\
		\"weight\": 2051,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.occurrenceDateTime\",\
		\"weight\": 2052,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.occurrencePeriod\",\
		\"weight\": 2052,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.occurrenceTiming\",\
		\"weight\": 2052,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.authoredOn\",\
		\"weight\": 2053,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.requester\",\
		\"weight\": 2054,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.requester.id\",\
		\"weight\": 2055,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.requester.extension\",\
		\"weight\": 2056,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.requester.modifierExtension\",\
		\"weight\": 2057,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceRequest.requester.agent\",\
		\"weight\": 2058,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.requester.onBehalfOf\",\
		\"weight\": 2059,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.performerType\",\
		\"weight\": 2060,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.performer\",\
		\"weight\": 2061,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.reasonCode\",\
		\"weight\": 2062,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.reasonReference\",\
		\"weight\": 2063,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.supportingInfo\",\
		\"weight\": 2064,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.note\",\
		\"weight\": 2065,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceRequest.relevantHistory\",\
		\"weight\": 2066,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement\",\
		\"weight\": 2067,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.id\",\
		\"weight\": 2068,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.meta\",\
		\"weight\": 2069,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.implicitRules\",\
		\"weight\": 2070,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.language\",\
		\"weight\": 2071,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.text\",\
		\"weight\": 2072,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.contained\",\
		\"weight\": 2073,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.extension\",\
		\"weight\": 2074,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.modifierExtension\",\
		\"weight\": 2075,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.identifier\",\
		\"weight\": 2076,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceUseStatement.status\",\
		\"weight\": 2077,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceUseStatement.subject\",\
		\"weight\": 2078,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.whenUsed\",\
		\"weight\": 2079,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.timingTiming\",\
		\"weight\": 2080,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.timingPeriod\",\
		\"weight\": 2080,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.timingDateTime\",\
		\"weight\": 2080,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.recordedOn\",\
		\"weight\": 2081,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.source\",\
		\"weight\": 2082,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DeviceUseStatement.device\",\
		\"weight\": 2083,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.indication\",\
		\"weight\": 2084,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.bodySite\",\
		\"weight\": 2085,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DeviceUseStatement.note\",\
		\"weight\": 2086,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport\",\
		\"weight\": 2087,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.id\",\
		\"weight\": 2088,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.meta\",\
		\"weight\": 2089,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.implicitRules\",\
		\"weight\": 2090,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.language\",\
		\"weight\": 2091,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.text\",\
		\"weight\": 2092,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.contained\",\
		\"weight\": 2093,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.extension\",\
		\"weight\": 2094,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.modifierExtension\",\
		\"weight\": 2095,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.identifier\",\
		\"weight\": 2096,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.basedOn\",\
		\"weight\": 2097,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DiagnosticReport.status\",\
		\"weight\": 2098,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.category\",\
		\"weight\": 2099,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DiagnosticReport.code\",\
		\"weight\": 2100,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.subject\",\
		\"weight\": 2101,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.context\",\
		\"weight\": 2102,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.effectiveDateTime\",\
		\"weight\": 2103,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.effectivePeriod\",\
		\"weight\": 2103,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.issued\",\
		\"weight\": 2104,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.performer\",\
		\"weight\": 2105,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.performer.id\",\
		\"weight\": 2106,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.performer.extension\",\
		\"weight\": 2107,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.performer.modifierExtension\",\
		\"weight\": 2108,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.performer.role\",\
		\"weight\": 2109,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DiagnosticReport.performer.actor\",\
		\"weight\": 2110,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.specimen\",\
		\"weight\": 2111,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.result\",\
		\"weight\": 2112,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.imagingStudy\",\
		\"weight\": 2113,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.image\",\
		\"weight\": 2114,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.image.id\",\
		\"weight\": 2115,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.image.extension\",\
		\"weight\": 2116,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.image.modifierExtension\",\
		\"weight\": 2117,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.image.comment\",\
		\"weight\": 2118,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DiagnosticReport.image.link\",\
		\"weight\": 2119,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.conclusion\",\
		\"weight\": 2120,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.codedDiagnosis\",\
		\"weight\": 2121,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DiagnosticReport.presentedForm\",\
		\"weight\": 2122,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest\",\
		\"weight\": 2123,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.id\",\
		\"weight\": 2124,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.meta\",\
		\"weight\": 2125,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.implicitRules\",\
		\"weight\": 2126,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.language\",\
		\"weight\": 2127,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.text\",\
		\"weight\": 2128,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.contained\",\
		\"weight\": 2129,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.extension\",\
		\"weight\": 2130,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.modifierExtension\",\
		\"weight\": 2131,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.masterIdentifier\",\
		\"weight\": 2132,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.identifier\",\
		\"weight\": 2133,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentManifest.status\",\
		\"weight\": 2134,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.type\",\
		\"weight\": 2135,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.subject\",\
		\"weight\": 2136,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.created\",\
		\"weight\": 2137,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.author\",\
		\"weight\": 2138,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.recipient\",\
		\"weight\": 2139,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.source\",\
		\"weight\": 2140,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.description\",\
		\"weight\": 2141,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentManifest.content\",\
		\"weight\": 2142,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.content.id\",\
		\"weight\": 2143,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.content.extension\",\
		\"weight\": 2144,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.content.modifierExtension\",\
		\"weight\": 2145,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentManifest.content.pAttachment\",\
		\"weight\": 2146,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentManifest.content.pReference\",\
		\"weight\": 2146,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.related\",\
		\"weight\": 2147,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.related.id\",\
		\"weight\": 2148,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.related.extension\",\
		\"weight\": 2149,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.related.modifierExtension\",\
		\"weight\": 2150,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.related.identifier\",\
		\"weight\": 2151,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentManifest.related.ref\",\
		\"weight\": 2152,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference\",\
		\"weight\": 2153,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.id\",\
		\"weight\": 2154,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.meta\",\
		\"weight\": 2155,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.implicitRules\",\
		\"weight\": 2156,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.language\",\
		\"weight\": 2157,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.text\",\
		\"weight\": 2158,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.contained\",\
		\"weight\": 2159,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.extension\",\
		\"weight\": 2160,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.modifierExtension\",\
		\"weight\": 2161,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.masterIdentifier\",\
		\"weight\": 2162,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.identifier\",\
		\"weight\": 2163,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentReference.status\",\
		\"weight\": 2164,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.docStatus\",\
		\"weight\": 2165,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentReference.type\",\
		\"weight\": 2166,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.class\",\
		\"weight\": 2167,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.subject\",\
		\"weight\": 2168,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.created\",\
		\"weight\": 2169,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentReference.indexed\",\
		\"weight\": 2170,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.author\",\
		\"weight\": 2171,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.authenticator\",\
		\"weight\": 2172,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.custodian\",\
		\"weight\": 2173,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.relatesTo\",\
		\"weight\": 2174,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.relatesTo.id\",\
		\"weight\": 2175,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.relatesTo.extension\",\
		\"weight\": 2176,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.relatesTo.modifierExtension\",\
		\"weight\": 2177,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentReference.relatesTo.code\",\
		\"weight\": 2178,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentReference.relatesTo.target\",\
		\"weight\": 2179,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.description\",\
		\"weight\": 2180,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.securityLabel\",\
		\"weight\": 2181,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentReference.content\",\
		\"weight\": 2182,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.content.id\",\
		\"weight\": 2183,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.content.extension\",\
		\"weight\": 2184,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.content.modifierExtension\",\
		\"weight\": 2185,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"DocumentReference.content.attachment\",\
		\"weight\": 2186,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.content.format\",\
		\"weight\": 2187,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context\",\
		\"weight\": 2188,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.id\",\
		\"weight\": 2189,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.extension\",\
		\"weight\": 2190,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.modifierExtension\",\
		\"weight\": 2191,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.encounter\",\
		\"weight\": 2192,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.event\",\
		\"weight\": 2193,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.period\",\
		\"weight\": 2194,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.facilityType\",\
		\"weight\": 2195,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.practiceSetting\",\
		\"weight\": 2196,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.sourcePatientInfo\",\
		\"weight\": 2197,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.related\",\
		\"weight\": 2198,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.related.id\",\
		\"weight\": 2199,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.related.extension\",\
		\"weight\": 2200,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.related.modifierExtension\",\
		\"weight\": 2201,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.related.identifier\",\
		\"weight\": 2202,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DocumentReference.context.related.ref\",\
		\"weight\": 2203,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource\",\
		\"weight\": 2204,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"derivations\": [\
			\"Account\",\
			\"ActivityDefinition\",\
			\"AdverseEvent\",\
			\"AllergyIntolerance\",\
			\"Appointment\",\
			\"AppointmentResponse\",\
			\"AuditEvent\",\
			\"Basic\",\
			\"BodySite\",\
			\"CapabilityStatement\",\
			\"CarePlan\",\
			\"CareTeam\",\
			\"ChargeItem\",\
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
			\"Consent\",\
			\"Contract\",\
			\"Coverage\",\
			\"DataElement\",\
			\"DetectedIssue\",\
			\"Device\",\
			\"DeviceComponent\",\
			\"DeviceMetric\",\
			\"DeviceRequest\",\
			\"DeviceUseStatement\",\
			\"DiagnosticReport\",\
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
			\"GraphDefinition\",\
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
			\"MedicationRequest\",\
			\"MedicationStatement\",\
			\"MessageDefinition\",\
			\"MessageHeader\",\
			\"MetadataResource\",\
			\"NamingSystem\",\
			\"NutritionOrder\",\
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
			\"RequestGroup\",\
			\"ResearchStudy\",\
			\"ResearchSubject\",\
			\"RiskAssessment\",\
			\"Schedule\",\
			\"SearchParameter\",\
			\"Sequence\",\
			\"ServiceDefinition\",\
			\"Slot\",\
			\"Specimen\",\
			\"StructureDefinition\",\
			\"StructureMap\",\
			\"Subscription\",\
			\"Substance\",\
			\"SupplyDelivery\",\
			\"SupplyRequest\",\
			\"Task\",\
			\"TestReport\",\
			\"TestScript\",\
			\"ValueSet\",\
			\"VisionPrescription\"\
		],\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource.id\",\
		\"weight\": 2205,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource.meta\",\
		\"weight\": 2206,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource.implicitRules\",\
		\"weight\": 2207,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource.language\",\
		\"weight\": 2208,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource.text\",\
		\"weight\": 2209,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource.contained\",\
		\"weight\": 2210,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource.extension\",\
		\"weight\": 2211,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"DomainResource.modifierExtension\",\
		\"weight\": 2212,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest\",\
		\"weight\": 2213,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.id\",\
		\"weight\": 2214,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.meta\",\
		\"weight\": 2215,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.implicitRules\",\
		\"weight\": 2216,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.language\",\
		\"weight\": 2217,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.text\",\
		\"weight\": 2218,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.contained\",\
		\"weight\": 2219,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.extension\",\
		\"weight\": 2220,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.modifierExtension\",\
		\"weight\": 2221,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.identifier\",\
		\"weight\": 2222,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.status\",\
		\"weight\": 2223,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.priority\",\
		\"weight\": 2224,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.patient\",\
		\"weight\": 2225,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.servicedDate\",\
		\"weight\": 2226,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.servicedPeriod\",\
		\"weight\": 2226,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.created\",\
		\"weight\": 2227,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.enterer\",\
		\"weight\": 2228,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.provider\",\
		\"weight\": 2229,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.organization\",\
		\"weight\": 2230,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.insurer\",\
		\"weight\": 2231,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.facility\",\
		\"weight\": 2232,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.coverage\",\
		\"weight\": 2233,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.businessArrangement\",\
		\"weight\": 2234,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.benefitCategory\",\
		\"weight\": 2235,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityRequest.benefitSubCategory\",\
		\"weight\": 2236,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse\",\
		\"weight\": 2237,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.id\",\
		\"weight\": 2238,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.meta\",\
		\"weight\": 2239,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.implicitRules\",\
		\"weight\": 2240,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.language\",\
		\"weight\": 2241,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.text\",\
		\"weight\": 2242,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.contained\",\
		\"weight\": 2243,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.extension\",\
		\"weight\": 2244,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.modifierExtension\",\
		\"weight\": 2245,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.identifier\",\
		\"weight\": 2246,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.status\",\
		\"weight\": 2247,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.created\",\
		\"weight\": 2248,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.requestProvider\",\
		\"weight\": 2249,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.requestOrganization\",\
		\"weight\": 2250,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.request\",\
		\"weight\": 2251,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.outcome\",\
		\"weight\": 2252,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.disposition\",\
		\"weight\": 2253,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurer\",\
		\"weight\": 2254,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.inforce\",\
		\"weight\": 2255,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance\",\
		\"weight\": 2256,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.id\",\
		\"weight\": 2257,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.extension\",\
		\"weight\": 2258,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.modifierExtension\",\
		\"weight\": 2259,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.coverage\",\
		\"weight\": 2260,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.contract\",\
		\"weight\": 2261,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance\",\
		\"weight\": 2262,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.id\",\
		\"weight\": 2263,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.extension\",\
		\"weight\": 2264,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.modifierExtension\",\
		\"weight\": 2265,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.category\",\
		\"weight\": 2266,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.subCategory\",\
		\"weight\": 2267,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.excluded\",\
		\"weight\": 2268,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.name\",\
		\"weight\": 2269,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.description\",\
		\"weight\": 2270,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.network\",\
		\"weight\": 2271,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.unit\",\
		\"weight\": 2272,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.term\",\
		\"weight\": 2273,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial\",\
		\"weight\": 2274,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.id\",\
		\"weight\": 2275,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.extension\",\
		\"weight\": 2276,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.modifierExtension\",\
		\"weight\": 2277,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.type\",\
		\"weight\": 2278,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.allowedUnsignedInt\",\
		\"weight\": 2279,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.allowedString\",\
		\"weight\": 2279,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.allowedMoney\",\
		\"weight\": 2279,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.usedUnsignedInt\",\
		\"weight\": 2280,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.insurance.benefitBalance.financial.usedMoney\",\
		\"weight\": 2280,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.form\",\
		\"weight\": 2281,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.error\",\
		\"weight\": 2282,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.error.id\",\
		\"weight\": 2283,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.error.extension\",\
		\"weight\": 2284,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EligibilityResponse.error.modifierExtension\",\
		\"weight\": 2285,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"EligibilityResponse.error.code\",\
		\"weight\": 2286,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter\",\
		\"weight\": 2287,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.id\",\
		\"weight\": 2288,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.meta\",\
		\"weight\": 2289,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.implicitRules\",\
		\"weight\": 2290,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.language\",\
		\"weight\": 2291,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.text\",\
		\"weight\": 2292,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.contained\",\
		\"weight\": 2293,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.extension\",\
		\"weight\": 2294,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.modifierExtension\",\
		\"weight\": 2295,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.identifier\",\
		\"weight\": 2296,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Encounter.status\",\
		\"weight\": 2297,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.statusHistory\",\
		\"weight\": 2298,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.statusHistory.id\",\
		\"weight\": 2299,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.statusHistory.extension\",\
		\"weight\": 2300,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.statusHistory.modifierExtension\",\
		\"weight\": 2301,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Encounter.statusHistory.status\",\
		\"weight\": 2302,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Encounter.statusHistory.period\",\
		\"weight\": 2303,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.class\",\
		\"weight\": 2304,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.classHistory\",\
		\"weight\": 2305,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.classHistory.id\",\
		\"weight\": 2306,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.classHistory.extension\",\
		\"weight\": 2307,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.classHistory.modifierExtension\",\
		\"weight\": 2308,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Encounter.classHistory.class\",\
		\"weight\": 2309,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Encounter.classHistory.period\",\
		\"weight\": 2310,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.type\",\
		\"weight\": 2311,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.priority\",\
		\"weight\": 2312,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.subject\",\
		\"weight\": 2313,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.episodeOfCare\",\
		\"weight\": 2314,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.incomingReferral\",\
		\"weight\": 2315,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.participant\",\
		\"weight\": 2316,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.participant.id\",\
		\"weight\": 2317,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.participant.extension\",\
		\"weight\": 2318,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.participant.modifierExtension\",\
		\"weight\": 2319,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.participant.type\",\
		\"weight\": 2320,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.participant.period\",\
		\"weight\": 2321,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.participant.individual\",\
		\"weight\": 2322,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.appointment\",\
		\"weight\": 2323,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.period\",\
		\"weight\": 2324,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.length\",\
		\"weight\": 2325,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.reason\",\
		\"weight\": 2326,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.diagnosis\",\
		\"weight\": 2327,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.diagnosis.id\",\
		\"weight\": 2328,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.diagnosis.extension\",\
		\"weight\": 2329,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.diagnosis.modifierExtension\",\
		\"weight\": 2330,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Encounter.diagnosis.condition\",\
		\"weight\": 2331,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.diagnosis.role\",\
		\"weight\": 2332,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.diagnosis.rank\",\
		\"weight\": 2333,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.account\",\
		\"weight\": 2334,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization\",\
		\"weight\": 2335,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.id\",\
		\"weight\": 2336,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.extension\",\
		\"weight\": 2337,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.modifierExtension\",\
		\"weight\": 2338,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.preAdmissionIdentifier\",\
		\"weight\": 2339,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.origin\",\
		\"weight\": 2340,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.admitSource\",\
		\"weight\": 2341,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.reAdmission\",\
		\"weight\": 2342,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.dietPreference\",\
		\"weight\": 2343,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.specialCourtesy\",\
		\"weight\": 2344,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.specialArrangement\",\
		\"weight\": 2345,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.destination\",\
		\"weight\": 2346,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.hospitalization.dischargeDisposition\",\
		\"weight\": 2347,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.location\",\
		\"weight\": 2348,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.location.id\",\
		\"weight\": 2349,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.location.extension\",\
		\"weight\": 2350,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.location.modifierExtension\",\
		\"weight\": 2351,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Encounter.location.location\",\
		\"weight\": 2352,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.location.status\",\
		\"weight\": 2353,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.location.period\",\
		\"weight\": 2354,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.serviceProvider\",\
		\"weight\": 2355,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Encounter.partOf\",\
		\"weight\": 2356,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint\",\
		\"weight\": 2357,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.id\",\
		\"weight\": 2358,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.meta\",\
		\"weight\": 2359,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.implicitRules\",\
		\"weight\": 2360,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.language\",\
		\"weight\": 2361,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.text\",\
		\"weight\": 2362,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.contained\",\
		\"weight\": 2363,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.extension\",\
		\"weight\": 2364,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.modifierExtension\",\
		\"weight\": 2365,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.identifier\",\
		\"weight\": 2366,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Endpoint.status\",\
		\"weight\": 2367,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Endpoint.connectionType\",\
		\"weight\": 2368,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.name\",\
		\"weight\": 2369,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.managingOrganization\",\
		\"weight\": 2370,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.contact\",\
		\"weight\": 2371,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.period\",\
		\"weight\": 2372,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Endpoint.payloadType\",\
		\"weight\": 2373,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.payloadMimeType\",\
		\"weight\": 2374,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Endpoint.address\",\
		\"weight\": 2375,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Endpoint.header\",\
		\"weight\": 2376,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest\",\
		\"weight\": 2377,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.id\",\
		\"weight\": 2378,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.meta\",\
		\"weight\": 2379,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.implicitRules\",\
		\"weight\": 2380,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.language\",\
		\"weight\": 2381,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.text\",\
		\"weight\": 2382,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.contained\",\
		\"weight\": 2383,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.extension\",\
		\"weight\": 2384,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.modifierExtension\",\
		\"weight\": 2385,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.identifier\",\
		\"weight\": 2386,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.status\",\
		\"weight\": 2387,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.created\",\
		\"weight\": 2388,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.insurer\",\
		\"weight\": 2389,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.provider\",\
		\"weight\": 2390,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.organization\",\
		\"weight\": 2391,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.subject\",\
		\"weight\": 2392,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentRequest.coverage\",\
		\"weight\": 2393,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse\",\
		\"weight\": 2394,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.id\",\
		\"weight\": 2395,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.meta\",\
		\"weight\": 2396,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.implicitRules\",\
		\"weight\": 2397,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.language\",\
		\"weight\": 2398,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.text\",\
		\"weight\": 2399,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.contained\",\
		\"weight\": 2400,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.extension\",\
		\"weight\": 2401,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.modifierExtension\",\
		\"weight\": 2402,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.identifier\",\
		\"weight\": 2403,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.status\",\
		\"weight\": 2404,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.request\",\
		\"weight\": 2405,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.outcome\",\
		\"weight\": 2406,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.disposition\",\
		\"weight\": 2407,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.created\",\
		\"weight\": 2408,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.organization\",\
		\"weight\": 2409,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.requestProvider\",\
		\"weight\": 2410,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EnrollmentResponse.requestOrganization\",\
		\"weight\": 2411,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare\",\
		\"weight\": 2412,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.id\",\
		\"weight\": 2413,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.meta\",\
		\"weight\": 2414,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.implicitRules\",\
		\"weight\": 2415,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.language\",\
		\"weight\": 2416,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.text\",\
		\"weight\": 2417,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.contained\",\
		\"weight\": 2418,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.extension\",\
		\"weight\": 2419,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.modifierExtension\",\
		\"weight\": 2420,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.identifier\",\
		\"weight\": 2421,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"EpisodeOfCare.status\",\
		\"weight\": 2422,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.statusHistory\",\
		\"weight\": 2423,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.statusHistory.id\",\
		\"weight\": 2424,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.statusHistory.extension\",\
		\"weight\": 2425,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.statusHistory.modifierExtension\",\
		\"weight\": 2426,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"EpisodeOfCare.statusHistory.status\",\
		\"weight\": 2427,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"EpisodeOfCare.statusHistory.period\",\
		\"weight\": 2428,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.type\",\
		\"weight\": 2429,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.diagnosis\",\
		\"weight\": 2430,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.diagnosis.id\",\
		\"weight\": 2431,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.diagnosis.extension\",\
		\"weight\": 2432,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.diagnosis.modifierExtension\",\
		\"weight\": 2433,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"EpisodeOfCare.diagnosis.condition\",\
		\"weight\": 2434,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.diagnosis.role\",\
		\"weight\": 2435,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.diagnosis.rank\",\
		\"weight\": 2436,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"EpisodeOfCare.patient\",\
		\"weight\": 2437,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.managingOrganization\",\
		\"weight\": 2438,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.period\",\
		\"weight\": 2439,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.referralRequest\",\
		\"weight\": 2440,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.careManager\",\
		\"weight\": 2441,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.team\",\
		\"weight\": 2442,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"EpisodeOfCare.account\",\
		\"weight\": 2443,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile\",\
		\"weight\": 2444,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.id\",\
		\"weight\": 2445,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.meta\",\
		\"weight\": 2446,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.implicitRules\",\
		\"weight\": 2447,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.language\",\
		\"weight\": 2448,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.text\",\
		\"weight\": 2449,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.contained\",\
		\"weight\": 2450,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.extension\",\
		\"weight\": 2451,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.modifierExtension\",\
		\"weight\": 2452,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.url\",\
		\"weight\": 2453,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.identifier\",\
		\"weight\": 2454,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.version\",\
		\"weight\": 2455,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.name\",\
		\"weight\": 2456,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExpansionProfile.status\",\
		\"weight\": 2457,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.experimental\",\
		\"weight\": 2458,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.date\",\
		\"weight\": 2459,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.publisher\",\
		\"weight\": 2460,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.contact\",\
		\"weight\": 2461,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.description\",\
		\"weight\": 2462,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.useContext\",\
		\"weight\": 2463,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.jurisdiction\",\
		\"weight\": 2464,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.fixedVersion\",\
		\"weight\": 2465,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.fixedVersion.id\",\
		\"weight\": 2466,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.fixedVersion.extension\",\
		\"weight\": 2467,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.fixedVersion.modifierExtension\",\
		\"weight\": 2468,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExpansionProfile.fixedVersion.system\",\
		\"weight\": 2469,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExpansionProfile.fixedVersion.version\",\
		\"weight\": 2470,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExpansionProfile.fixedVersion.mode\",\
		\"weight\": 2471,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.excludedSystem\",\
		\"weight\": 2472,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.excludedSystem.id\",\
		\"weight\": 2473,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.excludedSystem.extension\",\
		\"weight\": 2474,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.excludedSystem.modifierExtension\",\
		\"weight\": 2475,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExpansionProfile.excludedSystem.system\",\
		\"weight\": 2476,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.excludedSystem.version\",\
		\"weight\": 2477,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.includeDesignations\",\
		\"weight\": 2478,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation\",\
		\"weight\": 2479,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.id\",\
		\"weight\": 2480,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.extension\",\
		\"weight\": 2481,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.modifierExtension\",\
		\"weight\": 2482,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include\",\
		\"weight\": 2483,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.id\",\
		\"weight\": 2484,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.extension\",\
		\"weight\": 2485,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.modifierExtension\",\
		\"weight\": 2486,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.designation\",\
		\"weight\": 2487,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.designation.id\",\
		\"weight\": 2488,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.designation.extension\",\
		\"weight\": 2489,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.designation.modifierExtension\",\
		\"weight\": 2490,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.designation.language\",\
		\"weight\": 2491,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.include.designation.use\",\
		\"weight\": 2492,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude\",\
		\"weight\": 2493,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.id\",\
		\"weight\": 2494,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.extension\",\
		\"weight\": 2495,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.modifierExtension\",\
		\"weight\": 2496,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.designation\",\
		\"weight\": 2497,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.designation.id\",\
		\"weight\": 2498,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.designation.extension\",\
		\"weight\": 2499,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.designation.modifierExtension\",\
		\"weight\": 2500,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.designation.language\",\
		\"weight\": 2501,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.designation.exclude.designation.use\",\
		\"weight\": 2502,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.includeDefinition\",\
		\"weight\": 2503,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.activeOnly\",\
		\"weight\": 2504,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.excludeNested\",\
		\"weight\": 2505,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.excludeNotForUI\",\
		\"weight\": 2506,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.excludePostCoordinated\",\
		\"weight\": 2507,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.displayLanguage\",\
		\"weight\": 2508,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExpansionProfile.limitedExpansion\",\
		\"weight\": 2509,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit\",\
		\"weight\": 2510,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.id\",\
		\"weight\": 2511,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.meta\",\
		\"weight\": 2512,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.implicitRules\",\
		\"weight\": 2513,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.language\",\
		\"weight\": 2514,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.text\",\
		\"weight\": 2515,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.contained\",\
		\"weight\": 2516,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.extension\",\
		\"weight\": 2517,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.modifierExtension\",\
		\"weight\": 2518,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.identifier\",\
		\"weight\": 2519,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.status\",\
		\"weight\": 2520,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.type\",\
		\"weight\": 2521,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.subType\",\
		\"weight\": 2522,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.patient\",\
		\"weight\": 2523,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.billablePeriod\",\
		\"weight\": 2524,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.created\",\
		\"weight\": 2525,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.enterer\",\
		\"weight\": 2526,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.insurer\",\
		\"weight\": 2527,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.provider\",\
		\"weight\": 2528,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.organization\",\
		\"weight\": 2529,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.referral\",\
		\"weight\": 2530,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.facility\",\
		\"weight\": 2531,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.claim\",\
		\"weight\": 2532,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.claimResponse\",\
		\"weight\": 2533,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.outcome\",\
		\"weight\": 2534,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.disposition\",\
		\"weight\": 2535,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.related\",\
		\"weight\": 2536,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.related.id\",\
		\"weight\": 2537,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.related.extension\",\
		\"weight\": 2538,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.related.modifierExtension\",\
		\"weight\": 2539,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.related.claim\",\
		\"weight\": 2540,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.related.relationship\",\
		\"weight\": 2541,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.related.reference\",\
		\"weight\": 2542,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.prescription\",\
		\"weight\": 2543,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.originalPrescription\",\
		\"weight\": 2544,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payee\",\
		\"weight\": 2545,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payee.id\",\
		\"weight\": 2546,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payee.extension\",\
		\"weight\": 2547,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payee.modifierExtension\",\
		\"weight\": 2548,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payee.type\",\
		\"weight\": 2549,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payee.resourceType\",\
		\"weight\": 2550,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payee.party\",\
		\"weight\": 2551,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information\",\
		\"weight\": 2552,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.id\",\
		\"weight\": 2553,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.extension\",\
		\"weight\": 2554,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.modifierExtension\",\
		\"weight\": 2555,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.information.sequence\",\
		\"weight\": 2556,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.information.category\",\
		\"weight\": 2557,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.code\",\
		\"weight\": 2558,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.timingDate\",\
		\"weight\": 2559,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.timingPeriod\",\
		\"weight\": 2559,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.valueString\",\
		\"weight\": 2560,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.valueQuantity\",\
		\"weight\": 2560,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.valueAttachment\",\
		\"weight\": 2560,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.valueReference\",\
		\"weight\": 2560,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.information.reason\",\
		\"weight\": 2561,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.careTeam\",\
		\"weight\": 2562,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.careTeam.id\",\
		\"weight\": 2563,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.careTeam.extension\",\
		\"weight\": 2564,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.careTeam.modifierExtension\",\
		\"weight\": 2565,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.careTeam.sequence\",\
		\"weight\": 2566,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.careTeam.provider\",\
		\"weight\": 2567,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.careTeam.responsible\",\
		\"weight\": 2568,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.careTeam.role\",\
		\"weight\": 2569,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.careTeam.qualification\",\
		\"weight\": 2570,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.diagnosis\",\
		\"weight\": 2571,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.diagnosis.id\",\
		\"weight\": 2572,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.diagnosis.extension\",\
		\"weight\": 2573,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.diagnosis.modifierExtension\",\
		\"weight\": 2574,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.diagnosis.sequence\",\
		\"weight\": 2575,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.diagnosis.diagnosisCodeableConcept\",\
		\"weight\": 2576,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.diagnosis.diagnosisReference\",\
		\"weight\": 2576,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.diagnosis.type\",\
		\"weight\": 2577,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.diagnosis.packageCode\",\
		\"weight\": 2578,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.procedure\",\
		\"weight\": 2579,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.procedure.id\",\
		\"weight\": 2580,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.procedure.extension\",\
		\"weight\": 2581,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.procedure.modifierExtension\",\
		\"weight\": 2582,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.procedure.sequence\",\
		\"weight\": 2583,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.procedure.date\",\
		\"weight\": 2584,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.procedure.procedureCodeableConcept\",\
		\"weight\": 2585,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.procedure.procedureReference\",\
		\"weight\": 2585,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.precedence\",\
		\"weight\": 2586,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.insurance\",\
		\"weight\": 2587,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.insurance.id\",\
		\"weight\": 2588,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.insurance.extension\",\
		\"weight\": 2589,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.insurance.modifierExtension\",\
		\"weight\": 2590,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.insurance.coverage\",\
		\"weight\": 2591,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.insurance.preAuthRef\",\
		\"weight\": 2592,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.accident\",\
		\"weight\": 2593,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.accident.id\",\
		\"weight\": 2594,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.accident.extension\",\
		\"weight\": 2595,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.accident.modifierExtension\",\
		\"weight\": 2596,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.accident.date\",\
		\"weight\": 2597,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.accident.type\",\
		\"weight\": 2598,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.accident.locationAddress\",\
		\"weight\": 2599,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.accident.locationReference\",\
		\"weight\": 2599,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.employmentImpacted\",\
		\"weight\": 2600,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.hospitalization\",\
		\"weight\": 2601,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item\",\
		\"weight\": 2602,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.id\",\
		\"weight\": 2603,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.extension\",\
		\"weight\": 2604,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.modifierExtension\",\
		\"weight\": 2605,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.item.sequence\",\
		\"weight\": 2606,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.careTeamLinkId\",\
		\"weight\": 2607,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.diagnosisLinkId\",\
		\"weight\": 2608,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.procedureLinkId\",\
		\"weight\": 2609,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.informationLinkId\",\
		\"weight\": 2610,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.revenue\",\
		\"weight\": 2611,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.category\",\
		\"weight\": 2612,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.service\",\
		\"weight\": 2613,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.modifier\",\
		\"weight\": 2614,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.programCode\",\
		\"weight\": 2615,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.servicedDate\",\
		\"weight\": 2616,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.servicedPeriod\",\
		\"weight\": 2616,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.locationCodeableConcept\",\
		\"weight\": 2617,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.locationAddress\",\
		\"weight\": 2617,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.locationReference\",\
		\"weight\": 2617,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.quantity\",\
		\"weight\": 2618,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.unitPrice\",\
		\"weight\": 2619,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.factor\",\
		\"weight\": 2620,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.net\",\
		\"weight\": 2621,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.udi\",\
		\"weight\": 2622,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.bodySite\",\
		\"weight\": 2623,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.subSite\",\
		\"weight\": 2624,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.encounter\",\
		\"weight\": 2625,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.noteNumber\",\
		\"weight\": 2626,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.adjudication\",\
		\"weight\": 2627,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.adjudication.id\",\
		\"weight\": 2628,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.adjudication.extension\",\
		\"weight\": 2629,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.adjudication.modifierExtension\",\
		\"weight\": 2630,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.item.adjudication.category\",\
		\"weight\": 2631,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.adjudication.reason\",\
		\"weight\": 2632,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.adjudication.amount\",\
		\"weight\": 2633,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.adjudication.value\",\
		\"weight\": 2634,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail\",\
		\"weight\": 2635,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.id\",\
		\"weight\": 2636,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.extension\",\
		\"weight\": 2637,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.modifierExtension\",\
		\"weight\": 2638,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.item.detail.sequence\",\
		\"weight\": 2639,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.item.detail.type\",\
		\"weight\": 2640,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.revenue\",\
		\"weight\": 2641,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.category\",\
		\"weight\": 2642,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.service\",\
		\"weight\": 2643,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.modifier\",\
		\"weight\": 2644,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.programCode\",\
		\"weight\": 2645,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.quantity\",\
		\"weight\": 2646,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.unitPrice\",\
		\"weight\": 2647,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.factor\",\
		\"weight\": 2648,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.net\",\
		\"weight\": 2649,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.udi\",\
		\"weight\": 2650,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.noteNumber\",\
		\"weight\": 2651,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication\",\
		\"weight\": 2652,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail\",\
		\"weight\": 2653,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.id\",\
		\"weight\": 2654,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.extension\",\
		\"weight\": 2655,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.modifierExtension\",\
		\"weight\": 2656,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.sequence\",\
		\"weight\": 2657,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.type\",\
		\"weight\": 2658,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.revenue\",\
		\"weight\": 2659,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.category\",\
		\"weight\": 2660,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.service\",\
		\"weight\": 2661,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.modifier\",\
		\"weight\": 2662,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.programCode\",\
		\"weight\": 2663,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.quantity\",\
		\"weight\": 2664,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.unitPrice\",\
		\"weight\": 2665,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.factor\",\
		\"weight\": 2666,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.net\",\
		\"weight\": 2667,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.udi\",\
		\"weight\": 2668,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.noteNumber\",\
		\"weight\": 2669,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication\",\
		\"weight\": 2670,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem\",\
		\"weight\": 2671,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.id\",\
		\"weight\": 2672,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.extension\",\
		\"weight\": 2673,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.modifierExtension\",\
		\"weight\": 2674,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.sequenceLinkId\",\
		\"weight\": 2675,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.revenue\",\
		\"weight\": 2676,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.category\",\
		\"weight\": 2677,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.service\",\
		\"weight\": 2678,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.modifier\",\
		\"weight\": 2679,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.fee\",\
		\"weight\": 2680,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.noteNumber\",\
		\"weight\": 2681,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication\",\
		\"weight\": 2682,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail\",\
		\"weight\": 2683,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.id\",\
		\"weight\": 2684,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.extension\",\
		\"weight\": 2685,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.modifierExtension\",\
		\"weight\": 2686,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.revenue\",\
		\"weight\": 2687,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.category\",\
		\"weight\": 2688,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.service\",\
		\"weight\": 2689,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.modifier\",\
		\"weight\": 2690,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.fee\",\
		\"weight\": 2691,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.noteNumber\",\
		\"weight\": 2692,\
		\"max\": \"*\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication\",\
		\"weight\": 2693,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.totalCost\",\
		\"weight\": 2694,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.unallocDeductable\",\
		\"weight\": 2695,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.totalBenefit\",\
		\"weight\": 2696,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment\",\
		\"weight\": 2697,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.id\",\
		\"weight\": 2698,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.extension\",\
		\"weight\": 2699,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.modifierExtension\",\
		\"weight\": 2700,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.type\",\
		\"weight\": 2701,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.adjustment\",\
		\"weight\": 2702,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.adjustmentReason\",\
		\"weight\": 2703,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.date\",\
		\"weight\": 2704,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.amount\",\
		\"weight\": 2705,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.payment.identifier\",\
		\"weight\": 2706,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.form\",\
		\"weight\": 2707,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.processNote\",\
		\"weight\": 2708,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.processNote.id\",\
		\"weight\": 2709,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.processNote.extension\",\
		\"weight\": 2710,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.processNote.modifierExtension\",\
		\"weight\": 2711,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.processNote.number\",\
		\"weight\": 2712,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.processNote.type\",\
		\"weight\": 2713,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.processNote.text\",\
		\"weight\": 2714,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.processNote.language\",\
		\"weight\": 2715,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance\",\
		\"weight\": 2716,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.id\",\
		\"weight\": 2717,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.extension\",\
		\"weight\": 2718,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.modifierExtension\",\
		\"weight\": 2719,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.category\",\
		\"weight\": 2720,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.subCategory\",\
		\"weight\": 2721,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.excluded\",\
		\"weight\": 2722,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.name\",\
		\"weight\": 2723,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.description\",\
		\"weight\": 2724,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.network\",\
		\"weight\": 2725,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.unit\",\
		\"weight\": 2726,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.term\",\
		\"weight\": 2727,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial\",\
		\"weight\": 2728,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.id\",\
		\"weight\": 2729,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.extension\",\
		\"weight\": 2730,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.modifierExtension\",\
		\"weight\": 2731,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.type\",\
		\"weight\": 2732,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.allowedUnsignedInt\",\
		\"weight\": 2733,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.allowedString\",\
		\"weight\": 2733,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.allowedMoney\",\
		\"weight\": 2733,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.usedUnsignedInt\",\
		\"weight\": 2734,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.usedMoney\",\
		\"weight\": 2734,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory\",\
		\"weight\": 2735,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.id\",\
		\"weight\": 2736,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.meta\",\
		\"weight\": 2737,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.implicitRules\",\
		\"weight\": 2738,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.language\",\
		\"weight\": 2739,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.text\",\
		\"weight\": 2740,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.contained\",\
		\"weight\": 2741,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.extension\",\
		\"weight\": 2742,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.modifierExtension\",\
		\"weight\": 2743,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.identifier\",\
		\"weight\": 2744,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.definition\",\
		\"weight\": 2745,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"FamilyMemberHistory.status\",\
		\"weight\": 2746,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.notDone\",\
		\"weight\": 2747,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.notDoneReason\",\
		\"weight\": 2748,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"FamilyMemberHistory.patient\",\
		\"weight\": 2749,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.date\",\
		\"weight\": 2750,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.name\",\
		\"weight\": 2751,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"FamilyMemberHistory.relationship\",\
		\"weight\": 2752,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.gender\",\
		\"weight\": 2753,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.bornPeriod\",\
		\"weight\": 2754,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.bornDate\",\
		\"weight\": 2754,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.bornString\",\
		\"weight\": 2754,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.ageAge\",\
		\"weight\": 2755,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.ageRange\",\
		\"weight\": 2755,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.ageString\",\
		\"weight\": 2755,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.estimatedAge\",\
		\"weight\": 2756,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.deceasedBoolean\",\
		\"weight\": 2757,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.deceasedAge\",\
		\"weight\": 2757,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.deceasedRange\",\
		\"weight\": 2757,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.deceasedDate\",\
		\"weight\": 2757,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.deceasedString\",\
		\"weight\": 2757,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.reasonCode\",\
		\"weight\": 2758,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.reasonReference\",\
		\"weight\": 2759,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.note\",\
		\"weight\": 2760,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition\",\
		\"weight\": 2761,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.id\",\
		\"weight\": 2762,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.extension\",\
		\"weight\": 2763,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.modifierExtension\",\
		\"weight\": 2764,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"FamilyMemberHistory.condition.code\",\
		\"weight\": 2765,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.outcome\",\
		\"weight\": 2766,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.onsetAge\",\
		\"weight\": 2767,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.onsetRange\",\
		\"weight\": 2767,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.onsetPeriod\",\
		\"weight\": 2767,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.onsetString\",\
		\"weight\": 2767,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"FamilyMemberHistory.condition.note\",\
		\"weight\": 2768,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag\",\
		\"weight\": 2769,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.id\",\
		\"weight\": 2770,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.meta\",\
		\"weight\": 2771,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.implicitRules\",\
		\"weight\": 2772,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.language\",\
		\"weight\": 2773,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.text\",\
		\"weight\": 2774,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.contained\",\
		\"weight\": 2775,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.extension\",\
		\"weight\": 2776,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.modifierExtension\",\
		\"weight\": 2777,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.identifier\",\
		\"weight\": 2778,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Flag.status\",\
		\"weight\": 2779,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.category\",\
		\"weight\": 2780,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Flag.code\",\
		\"weight\": 2781,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Flag.subject\",\
		\"weight\": 2782,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.period\",\
		\"weight\": 2783,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.encounter\",\
		\"weight\": 2784,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Flag.author\",\
		\"weight\": 2785,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal\",\
		\"weight\": 2786,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.id\",\
		\"weight\": 2787,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.meta\",\
		\"weight\": 2788,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.implicitRules\",\
		\"weight\": 2789,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.language\",\
		\"weight\": 2790,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.text\",\
		\"weight\": 2791,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.contained\",\
		\"weight\": 2792,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.extension\",\
		\"weight\": 2793,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.modifierExtension\",\
		\"weight\": 2794,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.identifier\",\
		\"weight\": 2795,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Goal.status\",\
		\"weight\": 2796,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.category\",\
		\"weight\": 2797,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.priority\",\
		\"weight\": 2798,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Goal.description\",\
		\"weight\": 2799,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.subject\",\
		\"weight\": 2800,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.startDate\",\
		\"weight\": 2801,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.startCodeableConcept\",\
		\"weight\": 2801,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target\",\
		\"weight\": 2802,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.id\",\
		\"weight\": 2803,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.extension\",\
		\"weight\": 2804,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.modifierExtension\",\
		\"weight\": 2805,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.measure\",\
		\"weight\": 2806,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.detailQuantity\",\
		\"weight\": 2807,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.detailRange\",\
		\"weight\": 2807,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.detailCodeableConcept\",\
		\"weight\": 2807,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.dueDate\",\
		\"weight\": 2808,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.target.dueDuration\",\
		\"weight\": 2808,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.statusDate\",\
		\"weight\": 2809,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.statusReason\",\
		\"weight\": 2810,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.expressedBy\",\
		\"weight\": 2811,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.addresses\",\
		\"weight\": 2812,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.note\",\
		\"weight\": 2813,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.outcomeCode\",\
		\"weight\": 2814,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Goal.outcomeReference\",\
		\"weight\": 2815,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition\",\
		\"weight\": 2816,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.id\",\
		\"weight\": 2817,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.meta\",\
		\"weight\": 2818,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.implicitRules\",\
		\"weight\": 2819,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.language\",\
		\"weight\": 2820,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.text\",\
		\"weight\": 2821,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.contained\",\
		\"weight\": 2822,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.extension\",\
		\"weight\": 2823,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.modifierExtension\",\
		\"weight\": 2824,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.url\",\
		\"weight\": 2825,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.version\",\
		\"weight\": 2826,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GraphDefinition.name\",\
		\"weight\": 2827,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GraphDefinition.status\",\
		\"weight\": 2828,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.experimental\",\
		\"weight\": 2829,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.date\",\
		\"weight\": 2830,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.publisher\",\
		\"weight\": 2831,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.contact\",\
		\"weight\": 2832,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.description\",\
		\"weight\": 2833,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.useContext\",\
		\"weight\": 2834,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.jurisdiction\",\
		\"weight\": 2835,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.purpose\",\
		\"weight\": 2836,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GraphDefinition.start\",\
		\"weight\": 2837,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.profile\",\
		\"weight\": 2838,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link\",\
		\"weight\": 2839,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.id\",\
		\"weight\": 2840,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.extension\",\
		\"weight\": 2841,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.modifierExtension\",\
		\"weight\": 2842,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GraphDefinition.link.path\",\
		\"weight\": 2843,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.sliceName\",\
		\"weight\": 2844,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.min\",\
		\"weight\": 2845,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.max\",\
		\"weight\": 2846,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.description\",\
		\"weight\": 2847,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GraphDefinition.link.target\",\
		\"weight\": 2848,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.id\",\
		\"weight\": 2849,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.extension\",\
		\"weight\": 2850,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.modifierExtension\",\
		\"weight\": 2851,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GraphDefinition.link.target.type\",\
		\"weight\": 2852,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.profile\",\
		\"weight\": 2853,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.compartment\",\
		\"weight\": 2854,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.compartment.id\",\
		\"weight\": 2855,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.compartment.extension\",\
		\"weight\": 2856,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.compartment.modifierExtension\",\
		\"weight\": 2857,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GraphDefinition.link.target.compartment.code\",\
		\"weight\": 2858,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GraphDefinition.link.target.compartment.rule\",\
		\"weight\": 2859,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.compartment.expression\",\
		\"weight\": 2860,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.compartment.description\",\
		\"weight\": 2861,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GraphDefinition.link.target.link\",\
		\"weight\": 2862,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group\",\
		\"weight\": 2863,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.id\",\
		\"weight\": 2864,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.meta\",\
		\"weight\": 2865,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.implicitRules\",\
		\"weight\": 2866,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.language\",\
		\"weight\": 2867,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.text\",\
		\"weight\": 2868,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.contained\",\
		\"weight\": 2869,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.extension\",\
		\"weight\": 2870,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.modifierExtension\",\
		\"weight\": 2871,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.identifier\",\
		\"weight\": 2872,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.active\",\
		\"weight\": 2873,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.type\",\
		\"weight\": 2874,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.actual\",\
		\"weight\": 2875,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.code\",\
		\"weight\": 2876,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.name\",\
		\"weight\": 2877,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.quantity\",\
		\"weight\": 2878,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.characteristic\",\
		\"weight\": 2879,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.characteristic.id\",\
		\"weight\": 2880,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.characteristic.extension\",\
		\"weight\": 2881,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.characteristic.modifierExtension\",\
		\"weight\": 2882,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.characteristic.code\",\
		\"weight\": 2883,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.characteristic.valueCodeableConcept\",\
		\"weight\": 2884,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.characteristic.valueBoolean\",\
		\"weight\": 2884,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.characteristic.valueQuantity\",\
		\"weight\": 2884,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.characteristic.valueRange\",\
		\"weight\": 2884,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.characteristic.exclude\",\
		\"weight\": 2885,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.characteristic.period\",\
		\"weight\": 2886,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.member\",\
		\"weight\": 2887,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.member.id\",\
		\"weight\": 2888,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.member.extension\",\
		\"weight\": 2889,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.member.modifierExtension\",\
		\"weight\": 2890,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Group.member.entity\",\
		\"weight\": 2891,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.member.period\",\
		\"weight\": 2892,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Group.member.inactive\",\
		\"weight\": 2893,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse\",\
		\"weight\": 2894,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.id\",\
		\"weight\": 2895,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.meta\",\
		\"weight\": 2896,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.implicitRules\",\
		\"weight\": 2897,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.language\",\
		\"weight\": 2898,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.text\",\
		\"weight\": 2899,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.contained\",\
		\"weight\": 2900,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.extension\",\
		\"weight\": 2901,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.modifierExtension\",\
		\"weight\": 2902,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.requestId\",\
		\"weight\": 2903,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.identifier\",\
		\"weight\": 2904,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GuidanceResponse.module\",\
		\"weight\": 2905,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"GuidanceResponse.status\",\
		\"weight\": 2906,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.subject\",\
		\"weight\": 2907,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.context\",\
		\"weight\": 2908,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.occurrenceDateTime\",\
		\"weight\": 2909,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.performer\",\
		\"weight\": 2910,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.reasonCodeableConcept\",\
		\"weight\": 2911,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.reasonReference\",\
		\"weight\": 2911,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.note\",\
		\"weight\": 2912,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.evaluationMessage\",\
		\"weight\": 2913,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.outputParameters\",\
		\"weight\": 2914,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.result\",\
		\"weight\": 2915,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"GuidanceResponse.dataRequirement\",\
		\"weight\": 2916,\
		\"max\": \"*\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService\",\
		\"weight\": 2917,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.id\",\
		\"weight\": 2918,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.meta\",\
		\"weight\": 2919,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.implicitRules\",\
		\"weight\": 2920,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.language\",\
		\"weight\": 2921,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.text\",\
		\"weight\": 2922,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.contained\",\
		\"weight\": 2923,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.extension\",\
		\"weight\": 2924,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.modifierExtension\",\
		\"weight\": 2925,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.identifier\",\
		\"weight\": 2926,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.active\",\
		\"weight\": 2927,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.providedBy\",\
		\"weight\": 2928,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.category\",\
		\"weight\": 2929,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.type\",\
		\"weight\": 2930,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.specialty\",\
		\"weight\": 2931,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.location\",\
		\"weight\": 2932,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.name\",\
		\"weight\": 2933,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.comment\",\
		\"weight\": 2934,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.extraDetails\",\
		\"weight\": 2935,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.photo\",\
		\"weight\": 2936,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.telecom\",\
		\"weight\": 2937,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.coverageArea\",\
		\"weight\": 2938,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.serviceProvisionCode\",\
		\"weight\": 2939,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.eligibility\",\
		\"weight\": 2940,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.eligibilityNote\",\
		\"weight\": 2941,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.programName\",\
		\"weight\": 2942,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.characteristic\",\
		\"weight\": 2943,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.referralMethod\",\
		\"weight\": 2944,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.appointmentRequired\",\
		\"weight\": 2945,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availableTime\",\
		\"weight\": 2946,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availableTime.id\",\
		\"weight\": 2947,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availableTime.extension\",\
		\"weight\": 2948,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availableTime.modifierExtension\",\
		\"weight\": 2949,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availableTime.daysOfWeek\",\
		\"weight\": 2950,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availableTime.allDay\",\
		\"weight\": 2951,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availableTime.availableStartTime\",\
		\"weight\": 2952,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availableTime.availableEndTime\",\
		\"weight\": 2953,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.notAvailable\",\
		\"weight\": 2954,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.notAvailable.id\",\
		\"weight\": 2955,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.notAvailable.extension\",\
		\"weight\": 2956,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.notAvailable.modifierExtension\",\
		\"weight\": 2957,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"HealthcareService.notAvailable.description\",\
		\"weight\": 2958,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.notAvailable.during\",\
		\"weight\": 2959,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.availabilityExceptions\",\
		\"weight\": 2960,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"HealthcareService.endpoint\",\
		\"weight\": 2961,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest\",\
		\"weight\": 2962,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.id\",\
		\"weight\": 2963,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.meta\",\
		\"weight\": 2964,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.implicitRules\",\
		\"weight\": 2965,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.language\",\
		\"weight\": 2966,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.text\",\
		\"weight\": 2967,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.contained\",\
		\"weight\": 2968,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.extension\",\
		\"weight\": 2969,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.modifierExtension\",\
		\"weight\": 2970,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.identifier\",\
		\"weight\": 2971,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingManifest.patient\",\
		\"weight\": 2972,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.authoringTime\",\
		\"weight\": 2973,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.author\",\
		\"weight\": 2974,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.description\",\
		\"weight\": 2975,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingManifest.study\",\
		\"weight\": 2976,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.id\",\
		\"weight\": 2977,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.extension\",\
		\"weight\": 2978,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.modifierExtension\",\
		\"weight\": 2979,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingManifest.study.uid\",\
		\"weight\": 2980,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.imagingStudy\",\
		\"weight\": 2981,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.endpoint\",\
		\"weight\": 2982,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingManifest.study.series\",\
		\"weight\": 2983,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.series.id\",\
		\"weight\": 2984,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.series.extension\",\
		\"weight\": 2985,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.series.modifierExtension\",\
		\"weight\": 2986,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingManifest.study.series.uid\",\
		\"weight\": 2987,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.series.endpoint\",\
		\"weight\": 2988,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingManifest.study.series.instance\",\
		\"weight\": 2989,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.series.instance.id\",\
		\"weight\": 2990,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.series.instance.extension\",\
		\"weight\": 2991,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingManifest.study.series.instance.modifierExtension\",\
		\"weight\": 2992,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingManifest.study.series.instance.sopClass\",\
		\"weight\": 2993,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingManifest.study.series.instance.uid\",\
		\"weight\": 2994,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy\",\
		\"weight\": 2995,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.id\",\
		\"weight\": 2996,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.meta\",\
		\"weight\": 2997,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.implicitRules\",\
		\"weight\": 2998,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.language\",\
		\"weight\": 2999,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.text\",\
		\"weight\": 3000,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.contained\",\
		\"weight\": 3001,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.extension\",\
		\"weight\": 3002,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.modifierExtension\",\
		\"weight\": 3003,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingStudy.uid\",\
		\"weight\": 3004,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.accession\",\
		\"weight\": 3005,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.identifier\",\
		\"weight\": 3006,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.availability\",\
		\"weight\": 3007,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.modalityList\",\
		\"weight\": 3008,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingStudy.patient\",\
		\"weight\": 3009,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.context\",\
		\"weight\": 3010,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.started\",\
		\"weight\": 3011,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.basedOn\",\
		\"weight\": 3012,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.referrer\",\
		\"weight\": 3013,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.interpreter\",\
		\"weight\": 3014,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.endpoint\",\
		\"weight\": 3015,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.numberOfSeries\",\
		\"weight\": 3016,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.numberOfInstances\",\
		\"weight\": 3017,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.procedureReference\",\
		\"weight\": 3018,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.procedureCode\",\
		\"weight\": 3019,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.reason\",\
		\"weight\": 3020,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.description\",\
		\"weight\": 3021,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series\",\
		\"weight\": 3022,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.id\",\
		\"weight\": 3023,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.extension\",\
		\"weight\": 3024,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.modifierExtension\",\
		\"weight\": 3025,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingStudy.series.uid\",\
		\"weight\": 3026,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.number\",\
		\"weight\": 3027,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingStudy.series.modality\",\
		\"weight\": 3028,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.description\",\
		\"weight\": 3029,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.numberOfInstances\",\
		\"weight\": 3030,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.availability\",\
		\"weight\": 3031,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.endpoint\",\
		\"weight\": 3032,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.bodySite\",\
		\"weight\": 3033,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.laterality\",\
		\"weight\": 3034,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.started\",\
		\"weight\": 3035,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.performer\",\
		\"weight\": 3036,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.instance\",\
		\"weight\": 3037,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.instance.id\",\
		\"weight\": 3038,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.instance.extension\",\
		\"weight\": 3039,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.instance.modifierExtension\",\
		\"weight\": 3040,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingStudy.series.instance.uid\",\
		\"weight\": 3041,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.instance.number\",\
		\"weight\": 3042,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImagingStudy.series.instance.sopClass\",\
		\"weight\": 3043,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImagingStudy.series.instance.title\",\
		\"weight\": 3044,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization\",\
		\"weight\": 3045,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.id\",\
		\"weight\": 3046,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.meta\",\
		\"weight\": 3047,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.implicitRules\",\
		\"weight\": 3048,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.language\",\
		\"weight\": 3049,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.text\",\
		\"weight\": 3050,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.contained\",\
		\"weight\": 3051,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.extension\",\
		\"weight\": 3052,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.modifierExtension\",\
		\"weight\": 3053,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.identifier\",\
		\"weight\": 3054,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Immunization.status\",\
		\"weight\": 3055,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Immunization.notGiven\",\
		\"weight\": 3056,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Immunization.vaccineCode\",\
		\"weight\": 3057,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Immunization.patient\",\
		\"weight\": 3058,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.encounter\",\
		\"weight\": 3059,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.date\",\
		\"weight\": 3060,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Immunization.primarySource\",\
		\"weight\": 3061,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.reportOrigin\",\
		\"weight\": 3062,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.location\",\
		\"weight\": 3063,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.manufacturer\",\
		\"weight\": 3064,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.lotNumber\",\
		\"weight\": 3065,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.expirationDate\",\
		\"weight\": 3066,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.site\",\
		\"weight\": 3067,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.route\",\
		\"weight\": 3068,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.doseQuantity\",\
		\"weight\": 3069,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.practitioner\",\
		\"weight\": 3070,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.practitioner.id\",\
		\"weight\": 3071,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.practitioner.extension\",\
		\"weight\": 3072,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.practitioner.modifierExtension\",\
		\"weight\": 3073,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.practitioner.role\",\
		\"weight\": 3074,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Immunization.practitioner.actor\",\
		\"weight\": 3075,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.note\",\
		\"weight\": 3076,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.explanation\",\
		\"weight\": 3077,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.explanation.id\",\
		\"weight\": 3078,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.explanation.extension\",\
		\"weight\": 3079,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.explanation.modifierExtension\",\
		\"weight\": 3080,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.explanation.reason\",\
		\"weight\": 3081,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.explanation.reasonNotGiven\",\
		\"weight\": 3082,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.reaction\",\
		\"weight\": 3083,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.reaction.id\",\
		\"weight\": 3084,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.reaction.extension\",\
		\"weight\": 3085,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.reaction.modifierExtension\",\
		\"weight\": 3086,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.reaction.date\",\
		\"weight\": 3087,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.reaction.detail\",\
		\"weight\": 3088,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.reaction.reported\",\
		\"weight\": 3089,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol\",\
		\"weight\": 3090,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.id\",\
		\"weight\": 3091,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.extension\",\
		\"weight\": 3092,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.modifierExtension\",\
		\"weight\": 3093,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.doseSequence\",\
		\"weight\": 3094,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.description\",\
		\"weight\": 3095,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.authority\",\
		\"weight\": 3096,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.series\",\
		\"weight\": 3097,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.seriesDoses\",\
		\"weight\": 3098,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Immunization.vaccinationProtocol.targetDisease\",\
		\"weight\": 3099,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Immunization.vaccinationProtocol.doseStatus\",\
		\"weight\": 3100,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Immunization.vaccinationProtocol.doseStatusReason\",\
		\"weight\": 3101,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation\",\
		\"weight\": 3102,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.id\",\
		\"weight\": 3103,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.meta\",\
		\"weight\": 3104,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.implicitRules\",\
		\"weight\": 3105,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.language\",\
		\"weight\": 3106,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.text\",\
		\"weight\": 3107,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.contained\",\
		\"weight\": 3108,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.extension\",\
		\"weight\": 3109,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.modifierExtension\",\
		\"weight\": 3110,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.identifier\",\
		\"weight\": 3111,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImmunizationRecommendation.patient\",\
		\"weight\": 3112,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImmunizationRecommendation.recommendation\",\
		\"weight\": 3113,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.id\",\
		\"weight\": 3114,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.extension\",\
		\"weight\": 3115,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.modifierExtension\",\
		\"weight\": 3116,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImmunizationRecommendation.recommendation.date\",\
		\"weight\": 3117,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.vaccineCode\",\
		\"weight\": 3118,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.targetDisease\",\
		\"weight\": 3119,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.doseNumber\",\
		\"weight\": 3120,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImmunizationRecommendation.recommendation.forecastStatus\",\
		\"weight\": 3121,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion\",\
		\"weight\": 3122,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.id\",\
		\"weight\": 3123,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.extension\",\
		\"weight\": 3124,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.modifierExtension\",\
		\"weight\": 3125,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.code\",\
		\"weight\": 3126,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.value\",\
		\"weight\": 3127,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol\",\
		\"weight\": 3128,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.id\",\
		\"weight\": 3129,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.extension\",\
		\"weight\": 3130,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.modifierExtension\",\
		\"weight\": 3131,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.doseSequence\",\
		\"weight\": 3132,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.description\",\
		\"weight\": 3133,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.authority\",\
		\"weight\": 3134,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.series\",\
		\"weight\": 3135,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingImmunization\",\
		\"weight\": 3136,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingPatientInformation\",\
		\"weight\": 3137,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide\",\
		\"weight\": 3138,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.id\",\
		\"weight\": 3139,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.meta\",\
		\"weight\": 3140,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.implicitRules\",\
		\"weight\": 3141,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.language\",\
		\"weight\": 3142,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.text\",\
		\"weight\": 3143,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.contained\",\
		\"weight\": 3144,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.extension\",\
		\"weight\": 3145,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.modifierExtension\",\
		\"weight\": 3146,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.url\",\
		\"weight\": 3147,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.version\",\
		\"weight\": 3148,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.name\",\
		\"weight\": 3149,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.status\",\
		\"weight\": 3150,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.experimental\",\
		\"weight\": 3151,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.date\",\
		\"weight\": 3152,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.publisher\",\
		\"weight\": 3153,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.contact\",\
		\"weight\": 3154,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.description\",\
		\"weight\": 3155,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.useContext\",\
		\"weight\": 3156,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.jurisdiction\",\
		\"weight\": 3157,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.copyright\",\
		\"weight\": 3158,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.fhirVersion\",\
		\"weight\": 3159,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.dependency\",\
		\"weight\": 3160,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.dependency.id\",\
		\"weight\": 3161,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.dependency.extension\",\
		\"weight\": 3162,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.dependency.modifierExtension\",\
		\"weight\": 3163,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.dependency.type\",\
		\"weight\": 3164,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.dependency.uri\",\
		\"weight\": 3165,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package\",\
		\"weight\": 3166,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.id\",\
		\"weight\": 3167,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.extension\",\
		\"weight\": 3168,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.modifierExtension\",\
		\"weight\": 3169,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.package.name\",\
		\"weight\": 3170,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.description\",\
		\"weight\": 3171,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.package.resource\",\
		\"weight\": 3172,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.resource.id\",\
		\"weight\": 3173,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.resource.extension\",\
		\"weight\": 3174,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.resource.modifierExtension\",\
		\"weight\": 3175,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.package.resource.example\",\
		\"weight\": 3176,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.resource.name\",\
		\"weight\": 3177,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.resource.description\",\
		\"weight\": 3178,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.resource.acronym\",\
		\"weight\": 3179,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.package.resource.sourceUri\",\
		\"weight\": 3180,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.package.resource.sourceReference\",\
		\"weight\": 3180,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.package.resource.exampleFor\",\
		\"weight\": 3181,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.global\",\
		\"weight\": 3182,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.global.id\",\
		\"weight\": 3183,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.global.extension\",\
		\"weight\": 3184,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.global.modifierExtension\",\
		\"weight\": 3185,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.global.type\",\
		\"weight\": 3186,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.global.profile\",\
		\"weight\": 3187,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.binary\",\
		\"weight\": 3188,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.page\",\
		\"weight\": 3189,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.page.id\",\
		\"weight\": 3190,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.page.extension\",\
		\"weight\": 3191,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.page.modifierExtension\",\
		\"weight\": 3192,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.page.source\",\
		\"weight\": 3193,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.page.title\",\
		\"weight\": 3194,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ImplementationGuide.page.kind\",\
		\"weight\": 3195,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.page.type\",\
		\"weight\": 3196,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.page.package\",\
		\"weight\": 3197,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.page.format\",\
		\"weight\": 3198,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ImplementationGuide.page.page\",\
		\"weight\": 3199,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library\",\
		\"weight\": 3200,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.id\",\
		\"weight\": 3201,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.meta\",\
		\"weight\": 3202,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.implicitRules\",\
		\"weight\": 3203,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.language\",\
		\"weight\": 3204,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.text\",\
		\"weight\": 3205,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.contained\",\
		\"weight\": 3206,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.extension\",\
		\"weight\": 3207,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.modifierExtension\",\
		\"weight\": 3208,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.url\",\
		\"weight\": 3209,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.identifier\",\
		\"weight\": 3210,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.version\",\
		\"weight\": 3211,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.name\",\
		\"weight\": 3212,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.title\",\
		\"weight\": 3213,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Library.status\",\
		\"weight\": 3214,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.experimental\",\
		\"weight\": 3215,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Library.type\",\
		\"weight\": 3216,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.date\",\
		\"weight\": 3217,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.publisher\",\
		\"weight\": 3218,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.description\",\
		\"weight\": 3219,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.purpose\",\
		\"weight\": 3220,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.usage\",\
		\"weight\": 3221,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.approvalDate\",\
		\"weight\": 3222,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.lastReviewDate\",\
		\"weight\": 3223,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.effectivePeriod\",\
		\"weight\": 3224,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.useContext\",\
		\"weight\": 3225,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.jurisdiction\",\
		\"weight\": 3226,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.topic\",\
		\"weight\": 3227,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.contributor\",\
		\"weight\": 3228,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.contact\",\
		\"weight\": 3229,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.copyright\",\
		\"weight\": 3230,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.relatedArtifact\",\
		\"weight\": 3231,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.parameter\",\
		\"weight\": 3232,\
		\"max\": \"*\",\
		\"type\": \"ParameterDefinition\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.dataRequirement\",\
		\"weight\": 3233,\
		\"max\": \"*\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Library.content\",\
		\"weight\": 3234,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage\",\
		\"weight\": 3235,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.id\",\
		\"weight\": 3236,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.meta\",\
		\"weight\": 3237,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.implicitRules\",\
		\"weight\": 3238,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.language\",\
		\"weight\": 3239,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.text\",\
		\"weight\": 3240,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.contained\",\
		\"weight\": 3241,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.extension\",\
		\"weight\": 3242,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.modifierExtension\",\
		\"weight\": 3243,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.active\",\
		\"weight\": 3244,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.author\",\
		\"weight\": 3245,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Linkage.item\",\
		\"weight\": 3246,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.item.id\",\
		\"weight\": 3247,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.item.extension\",\
		\"weight\": 3248,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Linkage.item.modifierExtension\",\
		\"weight\": 3249,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Linkage.item.type\",\
		\"weight\": 3250,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Linkage.item.resource\",\
		\"weight\": 3251,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List\",\
		\"weight\": 3252,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.id\",\
		\"weight\": 3253,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.meta\",\
		\"weight\": 3254,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.implicitRules\",\
		\"weight\": 3255,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.language\",\
		\"weight\": 3256,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.text\",\
		\"weight\": 3257,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.contained\",\
		\"weight\": 3258,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.extension\",\
		\"weight\": 3259,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.modifierExtension\",\
		\"weight\": 3260,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.identifier\",\
		\"weight\": 3261,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"List.status\",\
		\"weight\": 3262,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"List.mode\",\
		\"weight\": 3263,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.title\",\
		\"weight\": 3264,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.code\",\
		\"weight\": 3265,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.subject\",\
		\"weight\": 3266,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.encounter\",\
		\"weight\": 3267,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.date\",\
		\"weight\": 3268,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.source\",\
		\"weight\": 3269,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.orderedBy\",\
		\"weight\": 3270,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.note\",\
		\"weight\": 3271,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.entry\",\
		\"weight\": 3272,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.entry.id\",\
		\"weight\": 3273,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.entry.extension\",\
		\"weight\": 3274,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.entry.modifierExtension\",\
		\"weight\": 3275,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.entry.flag\",\
		\"weight\": 3276,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.entry.deleted\",\
		\"weight\": 3277,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.entry.date\",\
		\"weight\": 3278,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"List.entry.item\",\
		\"weight\": 3279,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"List.emptyReason\",\
		\"weight\": 3280,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location\",\
		\"weight\": 3281,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.id\",\
		\"weight\": 3282,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.meta\",\
		\"weight\": 3283,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.implicitRules\",\
		\"weight\": 3284,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.language\",\
		\"weight\": 3285,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.text\",\
		\"weight\": 3286,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.contained\",\
		\"weight\": 3287,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.extension\",\
		\"weight\": 3288,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.modifierExtension\",\
		\"weight\": 3289,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.identifier\",\
		\"weight\": 3290,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.status\",\
		\"weight\": 3291,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.operationalStatus\",\
		\"weight\": 3292,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.name\",\
		\"weight\": 3293,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.alias\",\
		\"weight\": 3294,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.description\",\
		\"weight\": 3295,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.mode\",\
		\"weight\": 3296,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.type\",\
		\"weight\": 3297,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.telecom\",\
		\"weight\": 3298,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.address\",\
		\"weight\": 3299,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.physicalType\",\
		\"weight\": 3300,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.position\",\
		\"weight\": 3301,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.position.id\",\
		\"weight\": 3302,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.position.extension\",\
		\"weight\": 3303,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.position.modifierExtension\",\
		\"weight\": 3304,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Location.position.longitude\",\
		\"weight\": 3305,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Location.position.latitude\",\
		\"weight\": 3306,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.position.altitude\",\
		\"weight\": 3307,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.managingOrganization\",\
		\"weight\": 3308,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.partOf\",\
		\"weight\": 3309,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Location.endpoint\",\
		\"weight\": 3310,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure\",\
		\"weight\": 3311,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.id\",\
		\"weight\": 3312,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.meta\",\
		\"weight\": 3313,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.implicitRules\",\
		\"weight\": 3314,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.language\",\
		\"weight\": 3315,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.text\",\
		\"weight\": 3316,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.contained\",\
		\"weight\": 3317,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.extension\",\
		\"weight\": 3318,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.modifierExtension\",\
		\"weight\": 3319,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.url\",\
		\"weight\": 3320,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.identifier\",\
		\"weight\": 3321,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.version\",\
		\"weight\": 3322,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.name\",\
		\"weight\": 3323,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.title\",\
		\"weight\": 3324,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Measure.status\",\
		\"weight\": 3325,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.experimental\",\
		\"weight\": 3326,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.date\",\
		\"weight\": 3327,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.publisher\",\
		\"weight\": 3328,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.description\",\
		\"weight\": 3329,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.purpose\",\
		\"weight\": 3330,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.usage\",\
		\"weight\": 3331,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.approvalDate\",\
		\"weight\": 3332,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.lastReviewDate\",\
		\"weight\": 3333,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.effectivePeriod\",\
		\"weight\": 3334,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.useContext\",\
		\"weight\": 3335,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.jurisdiction\",\
		\"weight\": 3336,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.topic\",\
		\"weight\": 3337,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.contributor\",\
		\"weight\": 3338,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.contact\",\
		\"weight\": 3339,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.copyright\",\
		\"weight\": 3340,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.relatedArtifact\",\
		\"weight\": 3341,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.library\",\
		\"weight\": 3342,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.disclaimer\",\
		\"weight\": 3343,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.scoring\",\
		\"weight\": 3344,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.compositeScoring\",\
		\"weight\": 3345,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.type\",\
		\"weight\": 3346,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.riskAdjustment\",\
		\"weight\": 3347,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.rateAggregation\",\
		\"weight\": 3348,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.rationale\",\
		\"weight\": 3349,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.clinicalRecommendationStatement\",\
		\"weight\": 3350,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.improvementNotation\",\
		\"weight\": 3351,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.definition\",\
		\"weight\": 3352,\
		\"max\": \"*\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.guidance\",\
		\"weight\": 3353,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.set\",\
		\"weight\": 3354,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group\",\
		\"weight\": 3355,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.id\",\
		\"weight\": 3356,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.extension\",\
		\"weight\": 3357,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.modifierExtension\",\
		\"weight\": 3358,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Measure.group.identifier\",\
		\"weight\": 3359,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.name\",\
		\"weight\": 3360,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.description\",\
		\"weight\": 3361,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.population\",\
		\"weight\": 3362,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.population.id\",\
		\"weight\": 3363,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.population.extension\",\
		\"weight\": 3364,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.population.modifierExtension\",\
		\"weight\": 3365,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.population.identifier\",\
		\"weight\": 3366,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.population.code\",\
		\"weight\": 3367,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.population.name\",\
		\"weight\": 3368,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.population.description\",\
		\"weight\": 3369,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Measure.group.population.criteria\",\
		\"weight\": 3370,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.stratifier\",\
		\"weight\": 3371,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.stratifier.id\",\
		\"weight\": 3372,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.stratifier.extension\",\
		\"weight\": 3373,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.stratifier.modifierExtension\",\
		\"weight\": 3374,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.stratifier.identifier\",\
		\"weight\": 3375,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.stratifier.criteria\",\
		\"weight\": 3376,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.group.stratifier.path\",\
		\"weight\": 3377,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.supplementalData\",\
		\"weight\": 3378,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.supplementalData.id\",\
		\"weight\": 3379,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.supplementalData.extension\",\
		\"weight\": 3380,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.supplementalData.modifierExtension\",\
		\"weight\": 3381,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.supplementalData.identifier\",\
		\"weight\": 3382,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.supplementalData.usage\",\
		\"weight\": 3383,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.supplementalData.criteria\",\
		\"weight\": 3384,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Measure.supplementalData.path\",\
		\"weight\": 3385,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport\",\
		\"weight\": 3386,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.id\",\
		\"weight\": 3387,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.meta\",\
		\"weight\": 3388,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.implicitRules\",\
		\"weight\": 3389,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.language\",\
		\"weight\": 3390,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.text\",\
		\"weight\": 3391,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.contained\",\
		\"weight\": 3392,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.extension\",\
		\"weight\": 3393,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.modifierExtension\",\
		\"weight\": 3394,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.identifier\",\
		\"weight\": 3395,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MeasureReport.status\",\
		\"weight\": 3396,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MeasureReport.type\",\
		\"weight\": 3397,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MeasureReport.measure\",\
		\"weight\": 3398,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.patient\",\
		\"weight\": 3399,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.date\",\
		\"weight\": 3400,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.reportingOrganization\",\
		\"weight\": 3401,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MeasureReport.period\",\
		\"weight\": 3402,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group\",\
		\"weight\": 3403,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.id\",\
		\"weight\": 3404,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.extension\",\
		\"weight\": 3405,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.modifierExtension\",\
		\"weight\": 3406,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MeasureReport.group.identifier\",\
		\"weight\": 3407,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.population\",\
		\"weight\": 3408,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.population.id\",\
		\"weight\": 3409,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.population.extension\",\
		\"weight\": 3410,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.population.modifierExtension\",\
		\"weight\": 3411,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.population.identifier\",\
		\"weight\": 3412,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.population.code\",\
		\"weight\": 3413,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.population.count\",\
		\"weight\": 3414,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.population.patients\",\
		\"weight\": 3415,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.measureScore\",\
		\"weight\": 3416,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier\",\
		\"weight\": 3417,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.id\",\
		\"weight\": 3418,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.extension\",\
		\"weight\": 3419,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.modifierExtension\",\
		\"weight\": 3420,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.identifier\",\
		\"weight\": 3421,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum\",\
		\"weight\": 3422,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.id\",\
		\"weight\": 3423,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.extension\",\
		\"weight\": 3424,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.modifierExtension\",\
		\"weight\": 3425,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MeasureReport.group.stratifier.stratum.value\",\
		\"weight\": 3426,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.population\",\
		\"weight\": 3427,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.population.id\",\
		\"weight\": 3428,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.population.extension\",\
		\"weight\": 3429,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.population.modifierExtension\",\
		\"weight\": 3430,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.population.identifier\",\
		\"weight\": 3431,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.population.code\",\
		\"weight\": 3432,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.population.count\",\
		\"weight\": 3433,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.population.patients\",\
		\"weight\": 3434,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.group.stratifier.stratum.measureScore\",\
		\"weight\": 3435,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MeasureReport.evaluatedResources\",\
		\"weight\": 3436,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media\",\
		\"weight\": 3437,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.id\",\
		\"weight\": 3438,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.meta\",\
		\"weight\": 3439,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.implicitRules\",\
		\"weight\": 3440,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.language\",\
		\"weight\": 3441,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.text\",\
		\"weight\": 3442,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.contained\",\
		\"weight\": 3443,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.extension\",\
		\"weight\": 3444,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.modifierExtension\",\
		\"weight\": 3445,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.identifier\",\
		\"weight\": 3446,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.basedOn\",\
		\"weight\": 3447,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Media.type\",\
		\"weight\": 3448,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.subtype\",\
		\"weight\": 3449,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.view\",\
		\"weight\": 3450,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.subject\",\
		\"weight\": 3451,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.context\",\
		\"weight\": 3452,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.occurrenceDateTime\",\
		\"weight\": 3453,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.occurrencePeriod\",\
		\"weight\": 3453,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.operator\",\
		\"weight\": 3454,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.reasonCode\",\
		\"weight\": 3455,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.bodySite\",\
		\"weight\": 3456,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.device\",\
		\"weight\": 3457,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.height\",\
		\"weight\": 3458,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.width\",\
		\"weight\": 3459,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.frames\",\
		\"weight\": 3460,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.duration\",\
		\"weight\": 3461,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Media.content\",\
		\"weight\": 3462,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Media.note\",\
		\"weight\": 3463,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication\",\
		\"weight\": 3464,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.id\",\
		\"weight\": 3465,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.meta\",\
		\"weight\": 3466,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.implicitRules\",\
		\"weight\": 3467,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.language\",\
		\"weight\": 3468,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.text\",\
		\"weight\": 3469,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.contained\",\
		\"weight\": 3470,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.extension\",\
		\"weight\": 3471,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.modifierExtension\",\
		\"weight\": 3472,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.code\",\
		\"weight\": 3473,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.status\",\
		\"weight\": 3474,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.isBrand\",\
		\"weight\": 3475,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.isOverTheCounter\",\
		\"weight\": 3476,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.manufacturer\",\
		\"weight\": 3477,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.form\",\
		\"weight\": 3478,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.ingredient\",\
		\"weight\": 3479,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.ingredient.id\",\
		\"weight\": 3480,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.ingredient.extension\",\
		\"weight\": 3481,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.ingredient.modifierExtension\",\
		\"weight\": 3482,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Medication.ingredient.itemCodeableConcept\",\
		\"weight\": 3483,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Medication.ingredient.itemReference\",\
		\"weight\": 3483,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Medication.ingredient.itemReference\",\
		\"weight\": 3483,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.ingredient.isActive\",\
		\"weight\": 3484,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.ingredient.amount\",\
		\"weight\": 3485,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package\",\
		\"weight\": 3486,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.id\",\
		\"weight\": 3487,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.extension\",\
		\"weight\": 3488,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.modifierExtension\",\
		\"weight\": 3489,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.container\",\
		\"weight\": 3490,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.content\",\
		\"weight\": 3491,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.content.id\",\
		\"weight\": 3492,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.content.extension\",\
		\"weight\": 3493,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.content.modifierExtension\",\
		\"weight\": 3494,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Medication.package.content.itemCodeableConcept\",\
		\"weight\": 3495,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Medication.package.content.itemReference\",\
		\"weight\": 3495,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.content.amount\",\
		\"weight\": 3496,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.batch\",\
		\"weight\": 3497,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.batch.id\",\
		\"weight\": 3498,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.batch.extension\",\
		\"weight\": 3499,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.batch.modifierExtension\",\
		\"weight\": 3500,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.batch.lotNumber\",\
		\"weight\": 3501,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.package.batch.expirationDate\",\
		\"weight\": 3502,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Medication.image\",\
		\"weight\": 3503,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration\",\
		\"weight\": 3504,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.id\",\
		\"weight\": 3505,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.meta\",\
		\"weight\": 3506,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.implicitRules\",\
		\"weight\": 3507,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.language\",\
		\"weight\": 3508,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.text\",\
		\"weight\": 3509,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.contained\",\
		\"weight\": 3510,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.extension\",\
		\"weight\": 3511,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.modifierExtension\",\
		\"weight\": 3512,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.identifier\",\
		\"weight\": 3513,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.definition\",\
		\"weight\": 3514,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.partOf\",\
		\"weight\": 3515,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationAdministration.status\",\
		\"weight\": 3516,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.category\",\
		\"weight\": 3517,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationAdministration.medicationCodeableConcept\",\
		\"weight\": 3518,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationAdministration.medicationReference\",\
		\"weight\": 3518,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationAdministration.subject\",\
		\"weight\": 3519,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.context\",\
		\"weight\": 3520,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.supportingInformation\",\
		\"weight\": 3521,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationAdministration.effectiveDateTime\",\
		\"weight\": 3522,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationAdministration.effectivePeriod\",\
		\"weight\": 3522,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.performer\",\
		\"weight\": 3523,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.performer.id\",\
		\"weight\": 3524,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.performer.extension\",\
		\"weight\": 3525,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.performer.modifierExtension\",\
		\"weight\": 3526,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationAdministration.performer.actor\",\
		\"weight\": 3527,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.performer.onBehalfOf\",\
		\"weight\": 3528,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.notGiven\",\
		\"weight\": 3529,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.reasonNotGiven\",\
		\"weight\": 3530,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.reasonCode\",\
		\"weight\": 3531,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.reasonReference\",\
		\"weight\": 3532,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.prescription\",\
		\"weight\": 3533,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.device\",\
		\"weight\": 3534,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.note\",\
		\"weight\": 3535,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage\",\
		\"weight\": 3536,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.id\",\
		\"weight\": 3537,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.extension\",\
		\"weight\": 3538,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.modifierExtension\",\
		\"weight\": 3539,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.text\",\
		\"weight\": 3540,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.site\",\
		\"weight\": 3541,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.route\",\
		\"weight\": 3542,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.method\",\
		\"weight\": 3543,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.dose\",\
		\"weight\": 3544,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.rateRatio\",\
		\"weight\": 3545,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.dosage.rateQuantity\",\
		\"weight\": 3545,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationAdministration.eventHistory\",\
		\"weight\": 3546,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense\",\
		\"weight\": 3547,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.id\",\
		\"weight\": 3548,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.meta\",\
		\"weight\": 3549,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.implicitRules\",\
		\"weight\": 3550,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.language\",\
		\"weight\": 3551,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.text\",\
		\"weight\": 3552,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.contained\",\
		\"weight\": 3553,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.extension\",\
		\"weight\": 3554,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.modifierExtension\",\
		\"weight\": 3555,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.identifier\",\
		\"weight\": 3556,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.partOf\",\
		\"weight\": 3557,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.status\",\
		\"weight\": 3558,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.category\",\
		\"weight\": 3559,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationDispense.medicationCodeableConcept\",\
		\"weight\": 3560,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationDispense.medicationReference\",\
		\"weight\": 3560,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.subject\",\
		\"weight\": 3561,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.context\",\
		\"weight\": 3562,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.supportingInformation\",\
		\"weight\": 3563,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.performer\",\
		\"weight\": 3564,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.performer.id\",\
		\"weight\": 3565,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.performer.extension\",\
		\"weight\": 3566,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.performer.modifierExtension\",\
		\"weight\": 3567,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationDispense.performer.actor\",\
		\"weight\": 3568,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.performer.onBehalfOf\",\
		\"weight\": 3569,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.authorizingPrescription\",\
		\"weight\": 3570,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.type\",\
		\"weight\": 3571,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.quantity\",\
		\"weight\": 3572,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.daysSupply\",\
		\"weight\": 3573,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.whenPrepared\",\
		\"weight\": 3574,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.whenHandedOver\",\
		\"weight\": 3575,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.destination\",\
		\"weight\": 3576,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.receiver\",\
		\"weight\": 3577,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.note\",\
		\"weight\": 3578,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.dosageInstruction\",\
		\"weight\": 3579,\
		\"max\": \"*\",\
		\"type\": \"Dosage\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.substitution\",\
		\"weight\": 3580,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.substitution.id\",\
		\"weight\": 3581,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.substitution.extension\",\
		\"weight\": 3582,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.substitution.modifierExtension\",\
		\"weight\": 3583,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationDispense.substitution.wasSubstituted\",\
		\"weight\": 3584,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.substitution.type\",\
		\"weight\": 3585,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.substitution.reason\",\
		\"weight\": 3586,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.substitution.responsibleParty\",\
		\"weight\": 3587,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.detectedIssue\",\
		\"weight\": 3588,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.notDone\",\
		\"weight\": 3589,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.notDoneReasonCodeableConcept\",\
		\"weight\": 3590,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.notDoneReasonReference\",\
		\"weight\": 3590,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationDispense.eventHistory\",\
		\"weight\": 3591,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest\",\
		\"weight\": 3592,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.id\",\
		\"weight\": 3593,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.meta\",\
		\"weight\": 3594,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.implicitRules\",\
		\"weight\": 3595,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.language\",\
		\"weight\": 3596,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.text\",\
		\"weight\": 3597,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.contained\",\
		\"weight\": 3598,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.extension\",\
		\"weight\": 3599,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.modifierExtension\",\
		\"weight\": 3600,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.identifier\",\
		\"weight\": 3601,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.definition\",\
		\"weight\": 3602,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.basedOn\",\
		\"weight\": 3603,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.groupIdentifier\",\
		\"weight\": 3604,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.status\",\
		\"weight\": 3605,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationRequest.intent\",\
		\"weight\": 3606,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.category\",\
		\"weight\": 3607,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.priority\",\
		\"weight\": 3608,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationRequest.medicationCodeableConcept\",\
		\"weight\": 3609,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationRequest.medicationReference\",\
		\"weight\": 3609,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationRequest.subject\",\
		\"weight\": 3610,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.context\",\
		\"weight\": 3611,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.supportingInformation\",\
		\"weight\": 3612,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.authoredOn\",\
		\"weight\": 3613,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.requester\",\
		\"weight\": 3614,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.requester.id\",\
		\"weight\": 3615,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.requester.extension\",\
		\"weight\": 3616,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.requester.modifierExtension\",\
		\"weight\": 3617,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationRequest.requester.agent\",\
		\"weight\": 3618,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.requester.onBehalfOf\",\
		\"weight\": 3619,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.recorder\",\
		\"weight\": 3620,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.reasonCode\",\
		\"weight\": 3621,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.reasonReference\",\
		\"weight\": 3622,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.note\",\
		\"weight\": 3623,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dosageInstruction\",\
		\"weight\": 3624,\
		\"max\": \"*\",\
		\"type\": \"Dosage\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest\",\
		\"weight\": 3625,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest.id\",\
		\"weight\": 3626,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest.extension\",\
		\"weight\": 3627,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest.modifierExtension\",\
		\"weight\": 3628,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest.validityPeriod\",\
		\"weight\": 3629,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest.numberOfRepeatsAllowed\",\
		\"weight\": 3630,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest.quantity\",\
		\"weight\": 3631,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest.expectedSupplyDuration\",\
		\"weight\": 3632,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.dispenseRequest.performer\",\
		\"weight\": 3633,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.substitution\",\
		\"weight\": 3634,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.substitution.id\",\
		\"weight\": 3635,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.substitution.extension\",\
		\"weight\": 3636,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.substitution.modifierExtension\",\
		\"weight\": 3637,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationRequest.substitution.allowed\",\
		\"weight\": 3638,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.substitution.reason\",\
		\"weight\": 3639,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.priorPrescription\",\
		\"weight\": 3640,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.detectedIssue\",\
		\"weight\": 3641,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationRequest.eventHistory\",\
		\"weight\": 3642,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement\",\
		\"weight\": 3643,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.id\",\
		\"weight\": 3644,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.meta\",\
		\"weight\": 3645,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.implicitRules\",\
		\"weight\": 3646,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.language\",\
		\"weight\": 3647,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.text\",\
		\"weight\": 3648,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.contained\",\
		\"weight\": 3649,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.extension\",\
		\"weight\": 3650,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.modifierExtension\",\
		\"weight\": 3651,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.identifier\",\
		\"weight\": 3652,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.basedOn\",\
		\"weight\": 3653,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.partOf\",\
		\"weight\": 3654,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.context\",\
		\"weight\": 3655,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationStatement.status\",\
		\"weight\": 3656,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.category\",\
		\"weight\": 3657,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationStatement.medicationCodeableConcept\",\
		\"weight\": 3658,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationStatement.medicationReference\",\
		\"weight\": 3658,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.effectiveDateTime\",\
		\"weight\": 3659,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.effectivePeriod\",\
		\"weight\": 3659,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.dateAsserted\",\
		\"weight\": 3660,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.informationSource\",\
		\"weight\": 3661,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationStatement.subject\",\
		\"weight\": 3662,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.derivedFrom\",\
		\"weight\": 3663,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MedicationStatement.taken\",\
		\"weight\": 3664,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.reasonNotTaken\",\
		\"weight\": 3665,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.reasonCode\",\
		\"weight\": 3666,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.reasonReference\",\
		\"weight\": 3667,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.note\",\
		\"weight\": 3668,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MedicationStatement.dosage\",\
		\"weight\": 3669,\
		\"max\": \"*\",\
		\"type\": \"Dosage\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition\",\
		\"weight\": 3670,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.id\",\
		\"weight\": 3671,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.meta\",\
		\"weight\": 3672,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.implicitRules\",\
		\"weight\": 3673,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.language\",\
		\"weight\": 3674,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.text\",\
		\"weight\": 3675,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.contained\",\
		\"weight\": 3676,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.extension\",\
		\"weight\": 3677,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.modifierExtension\",\
		\"weight\": 3678,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.url\",\
		\"weight\": 3679,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.identifier\",\
		\"weight\": 3680,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.version\",\
		\"weight\": 3681,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.name\",\
		\"weight\": 3682,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.title\",\
		\"weight\": 3683,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageDefinition.status\",\
		\"weight\": 3684,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.experimental\",\
		\"weight\": 3685,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageDefinition.date\",\
		\"weight\": 3686,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.publisher\",\
		\"weight\": 3687,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.contact\",\
		\"weight\": 3688,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.description\",\
		\"weight\": 3689,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.useContext\",\
		\"weight\": 3690,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.jurisdiction\",\
		\"weight\": 3691,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.purpose\",\
		\"weight\": 3692,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.copyright\",\
		\"weight\": 3693,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.base\",\
		\"weight\": 3694,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.parent\",\
		\"weight\": 3695,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.replaces\",\
		\"weight\": 3696,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageDefinition.event\",\
		\"weight\": 3697,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.category\",\
		\"weight\": 3698,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.focus\",\
		\"weight\": 3699,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.focus.id\",\
		\"weight\": 3700,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.focus.extension\",\
		\"weight\": 3701,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.focus.modifierExtension\",\
		\"weight\": 3702,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageDefinition.focus.code\",\
		\"weight\": 3703,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.focus.profile\",\
		\"weight\": 3704,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.focus.min\",\
		\"weight\": 3705,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.focus.max\",\
		\"weight\": 3706,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.responseRequired\",\
		\"weight\": 3707,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.allowedResponse\",\
		\"weight\": 3708,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.allowedResponse.id\",\
		\"weight\": 3709,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.allowedResponse.extension\",\
		\"weight\": 3710,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.allowedResponse.modifierExtension\",\
		\"weight\": 3711,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageDefinition.allowedResponse.message\",\
		\"weight\": 3712,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageDefinition.allowedResponse.situation\",\
		\"weight\": 3713,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader\",\
		\"weight\": 3714,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.id\",\
		\"weight\": 3715,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.meta\",\
		\"weight\": 3716,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.implicitRules\",\
		\"weight\": 3717,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.language\",\
		\"weight\": 3718,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.text\",\
		\"weight\": 3719,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.contained\",\
		\"weight\": 3720,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.extension\",\
		\"weight\": 3721,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.modifierExtension\",\
		\"weight\": 3722,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageHeader.event\",\
		\"weight\": 3723,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.destination\",\
		\"weight\": 3724,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.destination.id\",\
		\"weight\": 3725,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.destination.extension\",\
		\"weight\": 3726,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.destination.modifierExtension\",\
		\"weight\": 3727,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.destination.name\",\
		\"weight\": 3728,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.destination.target\",\
		\"weight\": 3729,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageHeader.destination.endpoint\",\
		\"weight\": 3730,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.receiver\",\
		\"weight\": 3731,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.sender\",\
		\"weight\": 3732,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageHeader.timestamp\",\
		\"weight\": 3733,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.enterer\",\
		\"weight\": 3734,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.author\",\
		\"weight\": 3735,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageHeader.source\",\
		\"weight\": 3736,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.source.id\",\
		\"weight\": 3737,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.source.extension\",\
		\"weight\": 3738,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.source.modifierExtension\",\
		\"weight\": 3739,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.source.name\",\
		\"weight\": 3740,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.source.software\",\
		\"weight\": 3741,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.source.version\",\
		\"weight\": 3742,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.source.contact\",\
		\"weight\": 3743,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageHeader.source.endpoint\",\
		\"weight\": 3744,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.responsible\",\
		\"weight\": 3745,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.reason\",\
		\"weight\": 3746,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.response\",\
		\"weight\": 3747,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.response.id\",\
		\"weight\": 3748,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.response.extension\",\
		\"weight\": 3749,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.response.modifierExtension\",\
		\"weight\": 3750,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageHeader.response.identifier\",\
		\"weight\": 3751,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MessageHeader.response.code\",\
		\"weight\": 3752,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.response.details\",\
		\"weight\": 3753,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MessageHeader.focus\",\
		\"weight\": 3754,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem\",\
		\"weight\": 3755,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.id\",\
		\"weight\": 3756,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.meta\",\
		\"weight\": 3757,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.implicitRules\",\
		\"weight\": 3758,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.language\",\
		\"weight\": 3759,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.text\",\
		\"weight\": 3760,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.contained\",\
		\"weight\": 3761,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.extension\",\
		\"weight\": 3762,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.modifierExtension\",\
		\"weight\": 3763,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NamingSystem.name\",\
		\"weight\": 3764,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NamingSystem.status\",\
		\"weight\": 3765,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NamingSystem.kind\",\
		\"weight\": 3766,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NamingSystem.date\",\
		\"weight\": 3767,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.publisher\",\
		\"weight\": 3768,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.contact\",\
		\"weight\": 3769,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.responsible\",\
		\"weight\": 3770,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.type\",\
		\"weight\": 3771,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.description\",\
		\"weight\": 3772,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.useContext\",\
		\"weight\": 3773,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.jurisdiction\",\
		\"weight\": 3774,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.usage\",\
		\"weight\": 3775,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NamingSystem.uniqueId\",\
		\"weight\": 3776,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.uniqueId.id\",\
		\"weight\": 3777,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.uniqueId.extension\",\
		\"weight\": 3778,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.uniqueId.modifierExtension\",\
		\"weight\": 3779,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NamingSystem.uniqueId.type\",\
		\"weight\": 3780,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NamingSystem.uniqueId.value\",\
		\"weight\": 3781,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.uniqueId.preferred\",\
		\"weight\": 3782,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.uniqueId.comment\",\
		\"weight\": 3783,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.uniqueId.period\",\
		\"weight\": 3784,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NamingSystem.replacedBy\",\
		\"weight\": 3785,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder\",\
		\"weight\": 3786,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.id\",\
		\"weight\": 3787,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.meta\",\
		\"weight\": 3788,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.implicitRules\",\
		\"weight\": 3789,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.language\",\
		\"weight\": 3790,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.text\",\
		\"weight\": 3791,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.contained\",\
		\"weight\": 3792,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.extension\",\
		\"weight\": 3793,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.modifierExtension\",\
		\"weight\": 3794,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.identifier\",\
		\"weight\": 3795,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.status\",\
		\"weight\": 3796,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NutritionOrder.patient\",\
		\"weight\": 3797,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.encounter\",\
		\"weight\": 3798,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"NutritionOrder.dateTime\",\
		\"weight\": 3799,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.orderer\",\
		\"weight\": 3800,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.allergyIntolerance\",\
		\"weight\": 3801,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.foodPreferenceModifier\",\
		\"weight\": 3802,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.excludeFoodModifier\",\
		\"weight\": 3803,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet\",\
		\"weight\": 3804,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.id\",\
		\"weight\": 3805,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.extension\",\
		\"weight\": 3806,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.modifierExtension\",\
		\"weight\": 3807,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.type\",\
		\"weight\": 3808,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.schedule\",\
		\"weight\": 3809,\
		\"max\": \"*\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.nutrient\",\
		\"weight\": 3810,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.nutrient.id\",\
		\"weight\": 3811,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.nutrient.extension\",\
		\"weight\": 3812,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.nutrient.modifierExtension\",\
		\"weight\": 3813,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.nutrient.modifier\",\
		\"weight\": 3814,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.nutrient.amount\",\
		\"weight\": 3815,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.texture\",\
		\"weight\": 3816,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.texture.id\",\
		\"weight\": 3817,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.texture.extension\",\
		\"weight\": 3818,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.texture.modifierExtension\",\
		\"weight\": 3819,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.texture.modifier\",\
		\"weight\": 3820,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.texture.foodType\",\
		\"weight\": 3821,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.fluidConsistencyType\",\
		\"weight\": 3822,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.oralDiet.instruction\",\
		\"weight\": 3823,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement\",\
		\"weight\": 3824,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement.id\",\
		\"weight\": 3825,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement.extension\",\
		\"weight\": 3826,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement.modifierExtension\",\
		\"weight\": 3827,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement.type\",\
		\"weight\": 3828,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement.productName\",\
		\"weight\": 3829,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement.schedule\",\
		\"weight\": 3830,\
		\"max\": \"*\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement.quantity\",\
		\"weight\": 3831,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.supplement.instruction\",\
		\"weight\": 3832,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula\",\
		\"weight\": 3833,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.id\",\
		\"weight\": 3834,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.extension\",\
		\"weight\": 3835,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.modifierExtension\",\
		\"weight\": 3836,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.baseFormulaType\",\
		\"weight\": 3837,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.baseFormulaProductName\",\
		\"weight\": 3838,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.additiveType\",\
		\"weight\": 3839,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.additiveProductName\",\
		\"weight\": 3840,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.caloricDensity\",\
		\"weight\": 3841,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.routeofAdministration\",\
		\"weight\": 3842,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administration\",\
		\"weight\": 3843,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administration.id\",\
		\"weight\": 3844,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administration.extension\",\
		\"weight\": 3845,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administration.modifierExtension\",\
		\"weight\": 3846,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administration.schedule\",\
		\"weight\": 3847,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administration.quantity\",\
		\"weight\": 3848,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administration.rateQuantity\",\
		\"weight\": 3849,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administration.rateRatio\",\
		\"weight\": 3849,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.maxVolumeToDeliver\",\
		\"weight\": 3850,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"NutritionOrder.enteralFormula.administrationInstruction\",\
		\"weight\": 3851,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation\",\
		\"weight\": 3852,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.id\",\
		\"weight\": 3853,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.meta\",\
		\"weight\": 3854,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.implicitRules\",\
		\"weight\": 3855,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.language\",\
		\"weight\": 3856,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.text\",\
		\"weight\": 3857,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.contained\",\
		\"weight\": 3858,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.extension\",\
		\"weight\": 3859,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.modifierExtension\",\
		\"weight\": 3860,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.identifier\",\
		\"weight\": 3861,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.basedOn\",\
		\"weight\": 3862,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Observation.status\",\
		\"weight\": 3863,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.category\",\
		\"weight\": 3864,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Observation.code\",\
		\"weight\": 3865,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.subject\",\
		\"weight\": 3866,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.context\",\
		\"weight\": 3867,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.effectiveDateTime\",\
		\"weight\": 3868,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.effectivePeriod\",\
		\"weight\": 3868,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.issued\",\
		\"weight\": 3869,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.performer\",\
		\"weight\": 3870,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueQuantity\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueCodeableConcept\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueString\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueBoolean\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueRange\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueRatio\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueSampledData\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueAttachment\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueTime\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valueDateTime\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.valuePeriod\",\
		\"weight\": 3871,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.dataAbsentReason\",\
		\"weight\": 3872,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.interpretation\",\
		\"weight\": 3873,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.comment\",\
		\"weight\": 3874,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.bodySite\",\
		\"weight\": 3875,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.method\",\
		\"weight\": 3876,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.specimen\",\
		\"weight\": 3877,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.device\",\
		\"weight\": 3878,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange\",\
		\"weight\": 3879,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.id\",\
		\"weight\": 3880,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.extension\",\
		\"weight\": 3881,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.modifierExtension\",\
		\"weight\": 3882,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.low\",\
		\"weight\": 3883,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.high\",\
		\"weight\": 3884,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.type\",\
		\"weight\": 3885,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.appliesTo\",\
		\"weight\": 3886,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.age\",\
		\"weight\": 3887,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.referenceRange.text\",\
		\"weight\": 3888,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.related\",\
		\"weight\": 3889,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.related.id\",\
		\"weight\": 3890,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.related.extension\",\
		\"weight\": 3891,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.related.modifierExtension\",\
		\"weight\": 3892,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.related.type\",\
		\"weight\": 3893,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Observation.related.target\",\
		\"weight\": 3894,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component\",\
		\"weight\": 3895,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.id\",\
		\"weight\": 3896,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.extension\",\
		\"weight\": 3897,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.modifierExtension\",\
		\"weight\": 3898,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Observation.component.code\",\
		\"weight\": 3899,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueQuantity\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueCodeableConcept\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueString\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueRange\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueRatio\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueSampledData\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueAttachment\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueTime\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valueDateTime\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.valuePeriod\",\
		\"weight\": 3900,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.dataAbsentReason\",\
		\"weight\": 3901,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.interpretation\",\
		\"weight\": 3902,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Observation.component.referenceRange\",\
		\"weight\": 3903,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition\",\
		\"weight\": 3904,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.id\",\
		\"weight\": 3905,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.meta\",\
		\"weight\": 3906,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.implicitRules\",\
		\"weight\": 3907,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.language\",\
		\"weight\": 3908,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.text\",\
		\"weight\": 3909,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.contained\",\
		\"weight\": 3910,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.extension\",\
		\"weight\": 3911,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.modifierExtension\",\
		\"weight\": 3912,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.url\",\
		\"weight\": 3913,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.version\",\
		\"weight\": 3914,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.name\",\
		\"weight\": 3915,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.status\",\
		\"weight\": 3916,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.kind\",\
		\"weight\": 3917,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.experimental\",\
		\"weight\": 3918,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.date\",\
		\"weight\": 3919,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.publisher\",\
		\"weight\": 3920,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.contact\",\
		\"weight\": 3921,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.description\",\
		\"weight\": 3922,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.useContext\",\
		\"weight\": 3923,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.jurisdiction\",\
		\"weight\": 3924,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.purpose\",\
		\"weight\": 3925,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.idempotent\",\
		\"weight\": 3926,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.code\",\
		\"weight\": 3927,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.comment\",\
		\"weight\": 3928,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.base\",\
		\"weight\": 3929,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.resource\",\
		\"weight\": 3930,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.system\",\
		\"weight\": 3931,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.type\",\
		\"weight\": 3932,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.instance\",\
		\"weight\": 3933,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter\",\
		\"weight\": 3934,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.id\",\
		\"weight\": 3935,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.extension\",\
		\"weight\": 3936,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.modifierExtension\",\
		\"weight\": 3937,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.parameter.name\",\
		\"weight\": 3938,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.parameter.use\",\
		\"weight\": 3939,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.parameter.min\",\
		\"weight\": 3940,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.parameter.max\",\
		\"weight\": 3941,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.documentation\",\
		\"weight\": 3942,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.type\",\
		\"weight\": 3943,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.searchType\",\
		\"weight\": 3944,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.profile\",\
		\"weight\": 3945,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.binding\",\
		\"weight\": 3946,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.binding.id\",\
		\"weight\": 3947,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.binding.extension\",\
		\"weight\": 3948,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.binding.modifierExtension\",\
		\"weight\": 3949,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.parameter.binding.strength\",\
		\"weight\": 3950,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.parameter.binding.valueSetUri\",\
		\"weight\": 3951,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationDefinition.parameter.binding.valueSetReference\",\
		\"weight\": 3951,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.parameter.part\",\
		\"weight\": 3952,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.overload\",\
		\"weight\": 3953,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.overload.id\",\
		\"weight\": 3954,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.overload.extension\",\
		\"weight\": 3955,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.overload.modifierExtension\",\
		\"weight\": 3956,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.overload.parameterName\",\
		\"weight\": 3957,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationDefinition.overload.comment\",\
		\"weight\": 3958,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome\",\
		\"weight\": 3959,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.id\",\
		\"weight\": 3960,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.meta\",\
		\"weight\": 3961,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.implicitRules\",\
		\"weight\": 3962,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.language\",\
		\"weight\": 3963,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.text\",\
		\"weight\": 3964,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.contained\",\
		\"weight\": 3965,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.extension\",\
		\"weight\": 3966,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.modifierExtension\",\
		\"weight\": 3967,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationOutcome.issue\",\
		\"weight\": 3968,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.issue.id\",\
		\"weight\": 3969,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.issue.extension\",\
		\"weight\": 3970,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.issue.modifierExtension\",\
		\"weight\": 3971,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationOutcome.issue.severity\",\
		\"weight\": 3972,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"OperationOutcome.issue.code\",\
		\"weight\": 3973,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.issue.details\",\
		\"weight\": 3974,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.issue.diagnostics\",\
		\"weight\": 3975,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.issue.location\",\
		\"weight\": 3976,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"OperationOutcome.issue.expression\",\
		\"weight\": 3977,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization\",\
		\"weight\": 3978,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.id\",\
		\"weight\": 3979,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.meta\",\
		\"weight\": 3980,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.implicitRules\",\
		\"weight\": 3981,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.language\",\
		\"weight\": 3982,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.text\",\
		\"weight\": 3983,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contained\",\
		\"weight\": 3984,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.extension\",\
		\"weight\": 3985,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.modifierExtension\",\
		\"weight\": 3986,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.identifier\",\
		\"weight\": 3987,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.active\",\
		\"weight\": 3988,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.type\",\
		\"weight\": 3989,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.name\",\
		\"weight\": 3990,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.alias\",\
		\"weight\": 3991,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.telecom\",\
		\"weight\": 3992,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.address\",\
		\"weight\": 3993,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.partOf\",\
		\"weight\": 3994,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contact\",\
		\"weight\": 3995,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contact.id\",\
		\"weight\": 3996,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contact.extension\",\
		\"weight\": 3997,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contact.modifierExtension\",\
		\"weight\": 3998,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contact.purpose\",\
		\"weight\": 3999,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contact.name\",\
		\"weight\": 4000,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contact.telecom\",\
		\"weight\": 4001,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.contact.address\",\
		\"weight\": 4002,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Organization.endpoint\",\
		\"weight\": 4003,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters\",\
		\"weight\": 4004,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.id\",\
		\"weight\": 4005,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.meta\",\
		\"weight\": 4006,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.implicitRules\",\
		\"weight\": 4007,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.language\",\
		\"weight\": 4008,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter\",\
		\"weight\": 4009,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.id\",\
		\"weight\": 4010,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.extension\",\
		\"weight\": 4011,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.modifierExtension\",\
		\"weight\": 4012,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Parameters.parameter.name\",\
		\"weight\": 4013,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueBase64Binary\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueBoolean\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueCode\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueDate\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueDateTime\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueDecimal\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueId\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueInstant\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueInteger\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueMarkdown\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueOid\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valuePositiveInt\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueString\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueTime\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueUnsignedInt\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueUri\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueAddress\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueAge\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueAnnotation\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueAttachment\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueCodeableConcept\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueCoding\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueContactPoint\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueCount\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueDistance\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueDuration\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueHumanName\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueIdentifier\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueMoney\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valuePeriod\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueQuantity\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueRange\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueRatio\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueReference\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueSampledData\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueSignature\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueTiming\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.valueMeta\",\
		\"weight\": 4014,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.resource\",\
		\"weight\": 4015,\
		\"max\": \"1\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Parameters.parameter.part\",\
		\"weight\": 4016,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient\",\
		\"weight\": 4017,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.id\",\
		\"weight\": 4018,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.meta\",\
		\"weight\": 4019,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.implicitRules\",\
		\"weight\": 4020,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.language\",\
		\"weight\": 4021,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.text\",\
		\"weight\": 4022,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contained\",\
		\"weight\": 4023,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.extension\",\
		\"weight\": 4024,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.modifierExtension\",\
		\"weight\": 4025,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.identifier\",\
		\"weight\": 4026,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.active\",\
		\"weight\": 4027,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.name\",\
		\"weight\": 4028,\
		\"max\": \"*\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.telecom\",\
		\"weight\": 4029,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.gender\",\
		\"weight\": 4030,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.birthDate\",\
		\"weight\": 4031,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.deceasedBoolean\",\
		\"weight\": 4032,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.deceasedDateTime\",\
		\"weight\": 4032,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.address\",\
		\"weight\": 4033,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.maritalStatus\",\
		\"weight\": 4034,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.multipleBirthBoolean\",\
		\"weight\": 4035,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.multipleBirthInteger\",\
		\"weight\": 4035,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.photo\",\
		\"weight\": 4036,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact\",\
		\"weight\": 4037,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.id\",\
		\"weight\": 4038,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.extension\",\
		\"weight\": 4039,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.modifierExtension\",\
		\"weight\": 4040,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.relationship\",\
		\"weight\": 4041,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.name\",\
		\"weight\": 4042,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.telecom\",\
		\"weight\": 4043,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.address\",\
		\"weight\": 4044,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.gender\",\
		\"weight\": 4045,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.organization\",\
		\"weight\": 4046,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.contact.period\",\
		\"weight\": 4047,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.animal\",\
		\"weight\": 4048,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.animal.id\",\
		\"weight\": 4049,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.animal.extension\",\
		\"weight\": 4050,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.animal.modifierExtension\",\
		\"weight\": 4051,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Patient.animal.species\",\
		\"weight\": 4052,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.animal.breed\",\
		\"weight\": 4053,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.animal.genderStatus\",\
		\"weight\": 4054,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.communication\",\
		\"weight\": 4055,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.communication.id\",\
		\"weight\": 4056,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.communication.extension\",\
		\"weight\": 4057,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.communication.modifierExtension\",\
		\"weight\": 4058,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Patient.communication.language\",\
		\"weight\": 4059,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.communication.preferred\",\
		\"weight\": 4060,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.generalPractitioner\",\
		\"weight\": 4061,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.managingOrganization\",\
		\"weight\": 4062,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.link\",\
		\"weight\": 4063,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.link.id\",\
		\"weight\": 4064,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.link.extension\",\
		\"weight\": 4065,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Patient.link.modifierExtension\",\
		\"weight\": 4066,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Patient.link.other\",\
		\"weight\": 4067,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Patient.link.type\",\
		\"weight\": 4068,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice\",\
		\"weight\": 4069,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.id\",\
		\"weight\": 4070,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.meta\",\
		\"weight\": 4071,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.implicitRules\",\
		\"weight\": 4072,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.language\",\
		\"weight\": 4073,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.text\",\
		\"weight\": 4074,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.contained\",\
		\"weight\": 4075,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.extension\",\
		\"weight\": 4076,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.modifierExtension\",\
		\"weight\": 4077,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.identifier\",\
		\"weight\": 4078,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.status\",\
		\"weight\": 4079,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.request\",\
		\"weight\": 4080,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.response\",\
		\"weight\": 4081,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.statusDate\",\
		\"weight\": 4082,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.created\",\
		\"weight\": 4083,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.target\",\
		\"weight\": 4084,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.provider\",\
		\"weight\": 4085,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.organization\",\
		\"weight\": 4086,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentNotice.paymentStatus\",\
		\"weight\": 4087,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation\",\
		\"weight\": 4088,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.id\",\
		\"weight\": 4089,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.meta\",\
		\"weight\": 4090,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.implicitRules\",\
		\"weight\": 4091,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.language\",\
		\"weight\": 4092,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.text\",\
		\"weight\": 4093,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.contained\",\
		\"weight\": 4094,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.extension\",\
		\"weight\": 4095,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.modifierExtension\",\
		\"weight\": 4096,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.identifier\",\
		\"weight\": 4097,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.status\",\
		\"weight\": 4098,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.period\",\
		\"weight\": 4099,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.created\",\
		\"weight\": 4100,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.organization\",\
		\"weight\": 4101,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.request\",\
		\"weight\": 4102,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.outcome\",\
		\"weight\": 4103,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.disposition\",\
		\"weight\": 4104,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.requestProvider\",\
		\"weight\": 4105,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.requestOrganization\",\
		\"weight\": 4106,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail\",\
		\"weight\": 4107,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.id\",\
		\"weight\": 4108,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.extension\",\
		\"weight\": 4109,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.modifierExtension\",\
		\"weight\": 4110,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"PaymentReconciliation.detail.type\",\
		\"weight\": 4111,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.request\",\
		\"weight\": 4112,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.response\",\
		\"weight\": 4113,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.submitter\",\
		\"weight\": 4114,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.payee\",\
		\"weight\": 4115,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.date\",\
		\"weight\": 4116,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.detail.amount\",\
		\"weight\": 4117,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.form\",\
		\"weight\": 4118,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.total\",\
		\"weight\": 4119,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.processNote\",\
		\"weight\": 4120,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.processNote.id\",\
		\"weight\": 4121,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.processNote.extension\",\
		\"weight\": 4122,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.processNote.modifierExtension\",\
		\"weight\": 4123,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.processNote.type\",\
		\"weight\": 4124,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PaymentReconciliation.processNote.text\",\
		\"weight\": 4125,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person\",\
		\"weight\": 4126,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.id\",\
		\"weight\": 4127,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.meta\",\
		\"weight\": 4128,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.implicitRules\",\
		\"weight\": 4129,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.language\",\
		\"weight\": 4130,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.text\",\
		\"weight\": 4131,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.contained\",\
		\"weight\": 4132,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.extension\",\
		\"weight\": 4133,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.modifierExtension\",\
		\"weight\": 4134,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.identifier\",\
		\"weight\": 4135,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.name\",\
		\"weight\": 4136,\
		\"max\": \"*\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.telecom\",\
		\"weight\": 4137,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.gender\",\
		\"weight\": 4138,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.birthDate\",\
		\"weight\": 4139,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.address\",\
		\"weight\": 4140,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.photo\",\
		\"weight\": 4141,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.managingOrganization\",\
		\"weight\": 4142,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.active\",\
		\"weight\": 4143,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.link\",\
		\"weight\": 4144,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.link.id\",\
		\"weight\": 4145,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.link.extension\",\
		\"weight\": 4146,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.link.modifierExtension\",\
		\"weight\": 4147,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Person.link.target\",\
		\"weight\": 4148,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Person.link.assurance\",\
		\"weight\": 4149,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition\",\
		\"weight\": 4150,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.id\",\
		\"weight\": 4151,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.meta\",\
		\"weight\": 4152,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.implicitRules\",\
		\"weight\": 4153,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.language\",\
		\"weight\": 4154,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.text\",\
		\"weight\": 4155,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.contained\",\
		\"weight\": 4156,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.extension\",\
		\"weight\": 4157,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.modifierExtension\",\
		\"weight\": 4158,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.url\",\
		\"weight\": 4159,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.identifier\",\
		\"weight\": 4160,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.version\",\
		\"weight\": 4161,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.name\",\
		\"weight\": 4162,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.title\",\
		\"weight\": 4163,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.type\",\
		\"weight\": 4164,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"PlanDefinition.status\",\
		\"weight\": 4165,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.experimental\",\
		\"weight\": 4166,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.date\",\
		\"weight\": 4167,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.publisher\",\
		\"weight\": 4168,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.description\",\
		\"weight\": 4169,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.purpose\",\
		\"weight\": 4170,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.usage\",\
		\"weight\": 4171,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.approvalDate\",\
		\"weight\": 4172,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.lastReviewDate\",\
		\"weight\": 4173,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.effectivePeriod\",\
		\"weight\": 4174,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.useContext\",\
		\"weight\": 4175,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.jurisdiction\",\
		\"weight\": 4176,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.topic\",\
		\"weight\": 4177,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.contributor\",\
		\"weight\": 4178,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.contact\",\
		\"weight\": 4179,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.copyright\",\
		\"weight\": 4180,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.relatedArtifact\",\
		\"weight\": 4181,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.library\",\
		\"weight\": 4182,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal\",\
		\"weight\": 4183,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.id\",\
		\"weight\": 4184,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.extension\",\
		\"weight\": 4185,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.modifierExtension\",\
		\"weight\": 4186,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.category\",\
		\"weight\": 4187,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"PlanDefinition.goal.description\",\
		\"weight\": 4188,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.priority\",\
		\"weight\": 4189,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.start\",\
		\"weight\": 4190,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.addresses\",\
		\"weight\": 4191,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.documentation\",\
		\"weight\": 4192,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target\",\
		\"weight\": 4193,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target.id\",\
		\"weight\": 4194,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target.extension\",\
		\"weight\": 4195,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target.modifierExtension\",\
		\"weight\": 4196,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target.measure\",\
		\"weight\": 4197,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target.detailQuantity\",\
		\"weight\": 4198,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target.detailRange\",\
		\"weight\": 4198,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target.detailCodeableConcept\",\
		\"weight\": 4198,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.goal.target.due\",\
		\"weight\": 4199,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action\",\
		\"weight\": 4200,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.id\",\
		\"weight\": 4201,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.extension\",\
		\"weight\": 4202,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.modifierExtension\",\
		\"weight\": 4203,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.label\",\
		\"weight\": 4204,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.title\",\
		\"weight\": 4205,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.description\",\
		\"weight\": 4206,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.textEquivalent\",\
		\"weight\": 4207,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.code\",\
		\"weight\": 4208,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.reason\",\
		\"weight\": 4209,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.documentation\",\
		\"weight\": 4210,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.goalId\",\
		\"weight\": 4211,\
		\"max\": \"*\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.triggerDefinition\",\
		\"weight\": 4212,\
		\"max\": \"*\",\
		\"type\": \"TriggerDefinition\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.condition\",\
		\"weight\": 4213,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.condition.id\",\
		\"weight\": 4214,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.condition.extension\",\
		\"weight\": 4215,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.condition.modifierExtension\",\
		\"weight\": 4216,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"PlanDefinition.action.condition.kind\",\
		\"weight\": 4217,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.condition.description\",\
		\"weight\": 4218,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.condition.language\",\
		\"weight\": 4219,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.condition.expression\",\
		\"weight\": 4220,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.input\",\
		\"weight\": 4221,\
		\"max\": \"*\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.output\",\
		\"weight\": 4222,\
		\"max\": \"*\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.relatedAction\",\
		\"weight\": 4223,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.relatedAction.id\",\
		\"weight\": 4224,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.relatedAction.extension\",\
		\"weight\": 4225,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.relatedAction.modifierExtension\",\
		\"weight\": 4226,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"PlanDefinition.action.relatedAction.actionId\",\
		\"weight\": 4227,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"PlanDefinition.action.relatedAction.relationship\",\
		\"weight\": 4228,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.relatedAction.offsetDuration\",\
		\"weight\": 4229,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.relatedAction.offsetRange\",\
		\"weight\": 4229,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.timingDateTime\",\
		\"weight\": 4230,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.timingPeriod\",\
		\"weight\": 4230,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.timingDuration\",\
		\"weight\": 4230,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.timingRange\",\
		\"weight\": 4230,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.timingTiming\",\
		\"weight\": 4230,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.participant\",\
		\"weight\": 4231,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.participant.id\",\
		\"weight\": 4232,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.participant.extension\",\
		\"weight\": 4233,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.participant.modifierExtension\",\
		\"weight\": 4234,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"PlanDefinition.action.participant.type\",\
		\"weight\": 4235,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.participant.role\",\
		\"weight\": 4236,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.type\",\
		\"weight\": 4237,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.groupingBehavior\",\
		\"weight\": 4238,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.selectionBehavior\",\
		\"weight\": 4239,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.requiredBehavior\",\
		\"weight\": 4240,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.precheckBehavior\",\
		\"weight\": 4241,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.cardinalityBehavior\",\
		\"weight\": 4242,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.definition\",\
		\"weight\": 4243,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.transform\",\
		\"weight\": 4244,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.dynamicValue\",\
		\"weight\": 4245,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.dynamicValue.id\",\
		\"weight\": 4246,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.dynamicValue.extension\",\
		\"weight\": 4247,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.dynamicValue.modifierExtension\",\
		\"weight\": 4248,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.dynamicValue.description\",\
		\"weight\": 4249,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.dynamicValue.path\",\
		\"weight\": 4250,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.dynamicValue.language\",\
		\"weight\": 4251,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.dynamicValue.expression\",\
		\"weight\": 4252,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PlanDefinition.action.action\",\
		\"weight\": 4253,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner\",\
		\"weight\": 4254,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.id\",\
		\"weight\": 4255,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.meta\",\
		\"weight\": 4256,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.implicitRules\",\
		\"weight\": 4257,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.language\",\
		\"weight\": 4258,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.text\",\
		\"weight\": 4259,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.contained\",\
		\"weight\": 4260,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.extension\",\
		\"weight\": 4261,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.modifierExtension\",\
		\"weight\": 4262,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.identifier\",\
		\"weight\": 4263,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.active\",\
		\"weight\": 4264,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.name\",\
		\"weight\": 4265,\
		\"max\": \"*\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.telecom\",\
		\"weight\": 4266,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.address\",\
		\"weight\": 4267,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.gender\",\
		\"weight\": 4268,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.birthDate\",\
		\"weight\": 4269,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.photo\",\
		\"weight\": 4270,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.qualification\",\
		\"weight\": 4271,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.qualification.id\",\
		\"weight\": 4272,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.qualification.extension\",\
		\"weight\": 4273,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.qualification.modifierExtension\",\
		\"weight\": 4274,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.qualification.identifier\",\
		\"weight\": 4275,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Practitioner.qualification.code\",\
		\"weight\": 4276,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.qualification.period\",\
		\"weight\": 4277,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.qualification.issuer\",\
		\"weight\": 4278,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Practitioner.communication\",\
		\"weight\": 4279,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole\",\
		\"weight\": 4280,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.id\",\
		\"weight\": 4281,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.meta\",\
		\"weight\": 4282,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.implicitRules\",\
		\"weight\": 4283,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.language\",\
		\"weight\": 4284,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.text\",\
		\"weight\": 4285,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.contained\",\
		\"weight\": 4286,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.extension\",\
		\"weight\": 4287,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.modifierExtension\",\
		\"weight\": 4288,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.identifier\",\
		\"weight\": 4289,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.active\",\
		\"weight\": 4290,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.period\",\
		\"weight\": 4291,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.practitioner\",\
		\"weight\": 4292,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.organization\",\
		\"weight\": 4293,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.code\",\
		\"weight\": 4294,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.specialty\",\
		\"weight\": 4295,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.location\",\
		\"weight\": 4296,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.healthcareService\",\
		\"weight\": 4297,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.telecom\",\
		\"weight\": 4298,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availableTime\",\
		\"weight\": 4299,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availableTime.id\",\
		\"weight\": 4300,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availableTime.extension\",\
		\"weight\": 4301,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availableTime.modifierExtension\",\
		\"weight\": 4302,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availableTime.daysOfWeek\",\
		\"weight\": 4303,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availableTime.allDay\",\
		\"weight\": 4304,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availableTime.availableStartTime\",\
		\"weight\": 4305,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availableTime.availableEndTime\",\
		\"weight\": 4306,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.notAvailable\",\
		\"weight\": 4307,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.notAvailable.id\",\
		\"weight\": 4308,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.notAvailable.extension\",\
		\"weight\": 4309,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.notAvailable.modifierExtension\",\
		\"weight\": 4310,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"PractitionerRole.notAvailable.description\",\
		\"weight\": 4311,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.notAvailable.during\",\
		\"weight\": 4312,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.availabilityExceptions\",\
		\"weight\": 4313,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"PractitionerRole.endpoint\",\
		\"weight\": 4314,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure\",\
		\"weight\": 4315,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.id\",\
		\"weight\": 4316,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.meta\",\
		\"weight\": 4317,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.implicitRules\",\
		\"weight\": 4318,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.language\",\
		\"weight\": 4319,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.text\",\
		\"weight\": 4320,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.contained\",\
		\"weight\": 4321,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.extension\",\
		\"weight\": 4322,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.modifierExtension\",\
		\"weight\": 4323,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.identifier\",\
		\"weight\": 4324,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.definition\",\
		\"weight\": 4325,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.basedOn\",\
		\"weight\": 4326,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.partOf\",\
		\"weight\": 4327,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Procedure.status\",\
		\"weight\": 4328,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.notDone\",\
		\"weight\": 4329,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.notDoneReason\",\
		\"weight\": 4330,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.category\",\
		\"weight\": 4331,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.code\",\
		\"weight\": 4332,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Procedure.subject\",\
		\"weight\": 4333,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.context\",\
		\"weight\": 4334,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.performedDateTime\",\
		\"weight\": 4335,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.performedPeriod\",\
		\"weight\": 4335,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.performer\",\
		\"weight\": 4336,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.performer.id\",\
		\"weight\": 4337,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.performer.extension\",\
		\"weight\": 4338,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.performer.modifierExtension\",\
		\"weight\": 4339,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.performer.role\",\
		\"weight\": 4340,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Procedure.performer.actor\",\
		\"weight\": 4341,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.performer.onBehalfOf\",\
		\"weight\": 4342,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.location\",\
		\"weight\": 4343,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.reasonCode\",\
		\"weight\": 4344,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.reasonReference\",\
		\"weight\": 4345,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.bodySite\",\
		\"weight\": 4346,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.outcome\",\
		\"weight\": 4347,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.report\",\
		\"weight\": 4348,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.complication\",\
		\"weight\": 4349,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.complicationDetail\",\
		\"weight\": 4350,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.followUp\",\
		\"weight\": 4351,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.note\",\
		\"weight\": 4352,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.focalDevice\",\
		\"weight\": 4353,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.focalDevice.id\",\
		\"weight\": 4354,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.focalDevice.extension\",\
		\"weight\": 4355,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.focalDevice.modifierExtension\",\
		\"weight\": 4356,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.focalDevice.action\",\
		\"weight\": 4357,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Procedure.focalDevice.manipulated\",\
		\"weight\": 4358,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.usedReference\",\
		\"weight\": 4359,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Procedure.usedCode\",\
		\"weight\": 4360,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest\",\
		\"weight\": 4361,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.id\",\
		\"weight\": 4362,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.meta\",\
		\"weight\": 4363,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.implicitRules\",\
		\"weight\": 4364,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.language\",\
		\"weight\": 4365,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.text\",\
		\"weight\": 4366,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.contained\",\
		\"weight\": 4367,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.extension\",\
		\"weight\": 4368,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.modifierExtension\",\
		\"weight\": 4369,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.identifier\",\
		\"weight\": 4370,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.definition\",\
		\"weight\": 4371,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.basedOn\",\
		\"weight\": 4372,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.replaces\",\
		\"weight\": 4373,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.requisition\",\
		\"weight\": 4374,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ProcedureRequest.status\",\
		\"weight\": 4375,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ProcedureRequest.intent\",\
		\"weight\": 4376,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.priority\",\
		\"weight\": 4377,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.doNotPerform\",\
		\"weight\": 4378,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.category\",\
		\"weight\": 4379,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ProcedureRequest.code\",\
		\"weight\": 4380,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ProcedureRequest.subject\",\
		\"weight\": 4381,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.context\",\
		\"weight\": 4382,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.occurrenceDateTime\",\
		\"weight\": 4383,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.occurrencePeriod\",\
		\"weight\": 4383,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.occurrenceTiming\",\
		\"weight\": 4383,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.asNeededBoolean\",\
		\"weight\": 4384,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.asNeededCodeableConcept\",\
		\"weight\": 4384,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.authoredOn\",\
		\"weight\": 4385,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.requester\",\
		\"weight\": 4386,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.requester.id\",\
		\"weight\": 4387,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.requester.extension\",\
		\"weight\": 4388,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.requester.modifierExtension\",\
		\"weight\": 4389,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ProcedureRequest.requester.agent\",\
		\"weight\": 4390,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.requester.onBehalfOf\",\
		\"weight\": 4391,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.performerType\",\
		\"weight\": 4392,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.performer\",\
		\"weight\": 4393,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.reasonCode\",\
		\"weight\": 4394,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.reasonReference\",\
		\"weight\": 4395,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.supportingInfo\",\
		\"weight\": 4396,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.specimen\",\
		\"weight\": 4397,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.bodySite\",\
		\"weight\": 4398,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.note\",\
		\"weight\": 4399,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcedureRequest.relevantHistory\",\
		\"weight\": 4400,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest\",\
		\"weight\": 4401,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.id\",\
		\"weight\": 4402,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.meta\",\
		\"weight\": 4403,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.implicitRules\",\
		\"weight\": 4404,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.language\",\
		\"weight\": 4405,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.text\",\
		\"weight\": 4406,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.contained\",\
		\"weight\": 4407,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.extension\",\
		\"weight\": 4408,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.modifierExtension\",\
		\"weight\": 4409,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.identifier\",\
		\"weight\": 4410,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.status\",\
		\"weight\": 4411,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.action\",\
		\"weight\": 4412,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.target\",\
		\"weight\": 4413,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.created\",\
		\"weight\": 4414,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.provider\",\
		\"weight\": 4415,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.organization\",\
		\"weight\": 4416,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.request\",\
		\"weight\": 4417,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.response\",\
		\"weight\": 4418,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.nullify\",\
		\"weight\": 4419,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.reference\",\
		\"weight\": 4420,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.item\",\
		\"weight\": 4421,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.item.id\",\
		\"weight\": 4422,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.item.extension\",\
		\"weight\": 4423,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.item.modifierExtension\",\
		\"weight\": 4424,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ProcessRequest.item.sequenceLinkId\",\
		\"weight\": 4425,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.include\",\
		\"weight\": 4426,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.exclude\",\
		\"weight\": 4427,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessRequest.period\",\
		\"weight\": 4428,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse\",\
		\"weight\": 4429,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.id\",\
		\"weight\": 4430,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.meta\",\
		\"weight\": 4431,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.implicitRules\",\
		\"weight\": 4432,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.language\",\
		\"weight\": 4433,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.text\",\
		\"weight\": 4434,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.contained\",\
		\"weight\": 4435,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.extension\",\
		\"weight\": 4436,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.modifierExtension\",\
		\"weight\": 4437,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.identifier\",\
		\"weight\": 4438,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.status\",\
		\"weight\": 4439,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.created\",\
		\"weight\": 4440,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.organization\",\
		\"weight\": 4441,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.request\",\
		\"weight\": 4442,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.outcome\",\
		\"weight\": 4443,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.disposition\",\
		\"weight\": 4444,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.requestProvider\",\
		\"weight\": 4445,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.requestOrganization\",\
		\"weight\": 4446,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.form\",\
		\"weight\": 4447,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.processNote\",\
		\"weight\": 4448,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.processNote.id\",\
		\"weight\": 4449,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.processNote.extension\",\
		\"weight\": 4450,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.processNote.modifierExtension\",\
		\"weight\": 4451,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.processNote.type\",\
		\"weight\": 4452,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.processNote.text\",\
		\"weight\": 4453,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.error\",\
		\"weight\": 4454,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ProcessResponse.communicationRequest\",\
		\"weight\": 4455,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance\",\
		\"weight\": 4456,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.id\",\
		\"weight\": 4457,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.meta\",\
		\"weight\": 4458,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.implicitRules\",\
		\"weight\": 4459,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.language\",\
		\"weight\": 4460,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.text\",\
		\"weight\": 4461,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.contained\",\
		\"weight\": 4462,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.extension\",\
		\"weight\": 4463,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.modifierExtension\",\
		\"weight\": 4464,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.target\",\
		\"weight\": 4465,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.period\",\
		\"weight\": 4466,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.recorded\",\
		\"weight\": 4467,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.policy\",\
		\"weight\": 4468,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.location\",\
		\"weight\": 4469,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.reason\",\
		\"weight\": 4470,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.activity\",\
		\"weight\": 4471,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.agent\",\
		\"weight\": 4472,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.id\",\
		\"weight\": 4473,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.extension\",\
		\"weight\": 4474,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.modifierExtension\",\
		\"weight\": 4475,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.role\",\
		\"weight\": 4476,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.agent.whoUri\",\
		\"weight\": 4477,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.agent.whoReference\",\
		\"weight\": 4477,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.agent.whoReference\",\
		\"weight\": 4477,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.agent.whoReference\",\
		\"weight\": 4477,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.agent.whoReference\",\
		\"weight\": 4477,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.agent.whoReference\",\
		\"weight\": 4477,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.onBehalfOfUri\",\
		\"weight\": 4478,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.onBehalfOfReference\",\
		\"weight\": 4478,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.onBehalfOfReference\",\
		\"weight\": 4478,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.onBehalfOfReference\",\
		\"weight\": 4478,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.onBehalfOfReference\",\
		\"weight\": 4478,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.onBehalfOfReference\",\
		\"weight\": 4478,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.agent.relatedAgentType\",\
		\"weight\": 4479,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.entity\",\
		\"weight\": 4480,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.entity.id\",\
		\"weight\": 4481,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.entity.extension\",\
		\"weight\": 4482,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.entity.modifierExtension\",\
		\"weight\": 4483,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.entity.role\",\
		\"weight\": 4484,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.entity.whatUri\",\
		\"weight\": 4485,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.entity.whatReference\",\
		\"weight\": 4485,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Provenance.entity.whatIdentifier\",\
		\"weight\": 4485,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.entity.agent\",\
		\"weight\": 4486,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Provenance.signature\",\
		\"weight\": 4487,\
		\"max\": \"*\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire\",\
		\"weight\": 4488,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.id\",\
		\"weight\": 4489,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.meta\",\
		\"weight\": 4490,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.implicitRules\",\
		\"weight\": 4491,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.language\",\
		\"weight\": 4492,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.text\",\
		\"weight\": 4493,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.contained\",\
		\"weight\": 4494,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.extension\",\
		\"weight\": 4495,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.modifierExtension\",\
		\"weight\": 4496,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.url\",\
		\"weight\": 4497,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.identifier\",\
		\"weight\": 4498,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.version\",\
		\"weight\": 4499,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.name\",\
		\"weight\": 4500,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.title\",\
		\"weight\": 4501,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.status\",\
		\"weight\": 4502,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.experimental\",\
		\"weight\": 4503,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.date\",\
		\"weight\": 4504,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.publisher\",\
		\"weight\": 4505,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.description\",\
		\"weight\": 4506,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.purpose\",\
		\"weight\": 4507,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.approvalDate\",\
		\"weight\": 4508,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.lastReviewDate\",\
		\"weight\": 4509,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.effectivePeriod\",\
		\"weight\": 4510,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.useContext\",\
		\"weight\": 4511,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.jurisdiction\",\
		\"weight\": 4512,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.contact\",\
		\"weight\": 4513,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.copyright\",\
		\"weight\": 4514,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.code\",\
		\"weight\": 4515,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.subjectType\",\
		\"weight\": 4516,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item\",\
		\"weight\": 4517,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.id\",\
		\"weight\": 4518,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.extension\",\
		\"weight\": 4519,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.modifierExtension\",\
		\"weight\": 4520,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.item.linkId\",\
		\"weight\": 4521,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.definition\",\
		\"weight\": 4522,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.code\",\
		\"weight\": 4523,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.prefix\",\
		\"weight\": 4524,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.text\",\
		\"weight\": 4525,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.item.type\",\
		\"weight\": 4526,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen\",\
		\"weight\": 4527,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.id\",\
		\"weight\": 4528,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.extension\",\
		\"weight\": 4529,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.modifierExtension\",\
		\"weight\": 4530,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.item.enableWhen.question\",\
		\"weight\": 4531,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.hasAnswer\",\
		\"weight\": 4532,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerBoolean\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerDecimal\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerInteger\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerDate\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerDateTime\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerTime\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerString\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerUri\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerAttachment\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerCoding\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerQuantity\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.enableWhen.answerReference\",\
		\"weight\": 4533,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.required\",\
		\"weight\": 4534,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.repeats\",\
		\"weight\": 4535,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.readOnly\",\
		\"weight\": 4536,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.maxLength\",\
		\"weight\": 4537,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.options\",\
		\"weight\": 4538,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.option\",\
		\"weight\": 4539,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.option.id\",\
		\"weight\": 4540,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.option.extension\",\
		\"weight\": 4541,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.option.modifierExtension\",\
		\"weight\": 4542,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.item.option.valueInteger\",\
		\"weight\": 4543,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.item.option.valueDate\",\
		\"weight\": 4543,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.item.option.valueTime\",\
		\"weight\": 4543,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.item.option.valueString\",\
		\"weight\": 4543,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Questionnaire.item.option.valueCoding\",\
		\"weight\": 4543,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialBoolean\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialDecimal\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialInteger\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialDate\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialDateTime\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialTime\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialString\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialUri\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialAttachment\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialCoding\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialQuantity\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.initialReference\",\
		\"weight\": 4544,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Questionnaire.item.item\",\
		\"weight\": 4545,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse\",\
		\"weight\": 4546,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.id\",\
		\"weight\": 4547,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.meta\",\
		\"weight\": 4548,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.implicitRules\",\
		\"weight\": 4549,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.language\",\
		\"weight\": 4550,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.text\",\
		\"weight\": 4551,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.contained\",\
		\"weight\": 4552,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.extension\",\
		\"weight\": 4553,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.modifierExtension\",\
		\"weight\": 4554,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.identifier\",\
		\"weight\": 4555,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.basedOn\",\
		\"weight\": 4556,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.parent\",\
		\"weight\": 4557,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.questionnaire\",\
		\"weight\": 4558,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"QuestionnaireResponse.status\",\
		\"weight\": 4559,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.subject\",\
		\"weight\": 4560,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.context\",\
		\"weight\": 4561,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.authored\",\
		\"weight\": 4562,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.author\",\
		\"weight\": 4563,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.source\",\
		\"weight\": 4564,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item\",\
		\"weight\": 4565,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.id\",\
		\"weight\": 4566,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.extension\",\
		\"weight\": 4567,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.modifierExtension\",\
		\"weight\": 4568,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"QuestionnaireResponse.item.linkId\",\
		\"weight\": 4569,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.definition\",\
		\"weight\": 4570,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.text\",\
		\"weight\": 4571,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.subject\",\
		\"weight\": 4572,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer\",\
		\"weight\": 4573,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.id\",\
		\"weight\": 4574,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.extension\",\
		\"weight\": 4575,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.modifierExtension\",\
		\"weight\": 4576,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueBoolean\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueDecimal\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueInteger\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueDate\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueDateTime\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueTime\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueString\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueUri\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueAttachment\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueCoding\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueQuantity\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.valueReference\",\
		\"weight\": 4577,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.answer.item\",\
		\"weight\": 4578,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"QuestionnaireResponse.item.item\",\
		\"weight\": 4579,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest\",\
		\"weight\": 4580,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.id\",\
		\"weight\": 4581,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.meta\",\
		\"weight\": 4582,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.implicitRules\",\
		\"weight\": 4583,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.language\",\
		\"weight\": 4584,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.text\",\
		\"weight\": 4585,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.contained\",\
		\"weight\": 4586,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.extension\",\
		\"weight\": 4587,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.modifierExtension\",\
		\"weight\": 4588,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.identifier\",\
		\"weight\": 4589,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.definition\",\
		\"weight\": 4590,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.basedOn\",\
		\"weight\": 4591,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.replaces\",\
		\"weight\": 4592,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.groupIdentifier\",\
		\"weight\": 4593,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ReferralRequest.status\",\
		\"weight\": 4594,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ReferralRequest.intent\",\
		\"weight\": 4595,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.type\",\
		\"weight\": 4596,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.priority\",\
		\"weight\": 4597,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.serviceRequested\",\
		\"weight\": 4598,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ReferralRequest.subject\",\
		\"weight\": 4599,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.context\",\
		\"weight\": 4600,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.occurrenceDateTime\",\
		\"weight\": 4601,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.occurrencePeriod\",\
		\"weight\": 4601,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.authoredOn\",\
		\"weight\": 4602,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.requester\",\
		\"weight\": 4603,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.requester.id\",\
		\"weight\": 4604,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.requester.extension\",\
		\"weight\": 4605,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.requester.modifierExtension\",\
		\"weight\": 4606,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ReferralRequest.requester.agent\",\
		\"weight\": 4607,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.requester.onBehalfOf\",\
		\"weight\": 4608,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.specialty\",\
		\"weight\": 4609,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.recipient\",\
		\"weight\": 4610,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.reasonCode\",\
		\"weight\": 4611,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.reasonReference\",\
		\"weight\": 4612,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.description\",\
		\"weight\": 4613,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.supportingInfo\",\
		\"weight\": 4614,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.note\",\
		\"weight\": 4615,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ReferralRequest.relevantHistory\",\
		\"weight\": 4616,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson\",\
		\"weight\": 4617,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.id\",\
		\"weight\": 4618,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.meta\",\
		\"weight\": 4619,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.implicitRules\",\
		\"weight\": 4620,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.language\",\
		\"weight\": 4621,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.text\",\
		\"weight\": 4622,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.contained\",\
		\"weight\": 4623,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.extension\",\
		\"weight\": 4624,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.modifierExtension\",\
		\"weight\": 4625,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.identifier\",\
		\"weight\": 4626,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.active\",\
		\"weight\": 4627,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RelatedPerson.patient\",\
		\"weight\": 4628,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.relationship\",\
		\"weight\": 4629,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.name\",\
		\"weight\": 4630,\
		\"max\": \"*\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.telecom\",\
		\"weight\": 4631,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.gender\",\
		\"weight\": 4632,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.birthDate\",\
		\"weight\": 4633,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.address\",\
		\"weight\": 4634,\
		\"max\": \"*\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.photo\",\
		\"weight\": 4635,\
		\"max\": \"*\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RelatedPerson.period\",\
		\"weight\": 4636,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup\",\
		\"weight\": 4637,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.id\",\
		\"weight\": 4638,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.meta\",\
		\"weight\": 4639,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.implicitRules\",\
		\"weight\": 4640,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.language\",\
		\"weight\": 4641,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.text\",\
		\"weight\": 4642,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.contained\",\
		\"weight\": 4643,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.extension\",\
		\"weight\": 4644,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.modifierExtension\",\
		\"weight\": 4645,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.identifier\",\
		\"weight\": 4646,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.definition\",\
		\"weight\": 4647,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.basedOn\",\
		\"weight\": 4648,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.replaces\",\
		\"weight\": 4649,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.groupIdentifier\",\
		\"weight\": 4650,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RequestGroup.status\",\
		\"weight\": 4651,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RequestGroup.intent\",\
		\"weight\": 4652,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.priority\",\
		\"weight\": 4653,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.subject\",\
		\"weight\": 4654,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.context\",\
		\"weight\": 4655,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.authoredOn\",\
		\"weight\": 4656,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.author\",\
		\"weight\": 4657,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.reasonCodeableConcept\",\
		\"weight\": 4658,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.reasonReference\",\
		\"weight\": 4658,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.note\",\
		\"weight\": 4659,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action\",\
		\"weight\": 4660,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.id\",\
		\"weight\": 4661,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.extension\",\
		\"weight\": 4662,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.modifierExtension\",\
		\"weight\": 4663,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.label\",\
		\"weight\": 4664,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.title\",\
		\"weight\": 4665,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.description\",\
		\"weight\": 4666,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.textEquivalent\",\
		\"weight\": 4667,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.code\",\
		\"weight\": 4668,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.documentation\",\
		\"weight\": 4669,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.condition\",\
		\"weight\": 4670,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.condition.id\",\
		\"weight\": 4671,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.condition.extension\",\
		\"weight\": 4672,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.condition.modifierExtension\",\
		\"weight\": 4673,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RequestGroup.action.condition.kind\",\
		\"weight\": 4674,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.condition.description\",\
		\"weight\": 4675,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.condition.language\",\
		\"weight\": 4676,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.condition.expression\",\
		\"weight\": 4677,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.relatedAction\",\
		\"weight\": 4678,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.relatedAction.id\",\
		\"weight\": 4679,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.relatedAction.extension\",\
		\"weight\": 4680,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.relatedAction.modifierExtension\",\
		\"weight\": 4681,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RequestGroup.action.relatedAction.actionId\",\
		\"weight\": 4682,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RequestGroup.action.relatedAction.relationship\",\
		\"weight\": 4683,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.relatedAction.offsetDuration\",\
		\"weight\": 4684,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.relatedAction.offsetRange\",\
		\"weight\": 4684,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.timingDateTime\",\
		\"weight\": 4685,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.timingPeriod\",\
		\"weight\": 4685,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.timingDuration\",\
		\"weight\": 4685,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.timingRange\",\
		\"weight\": 4685,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.timingTiming\",\
		\"weight\": 4685,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.participant\",\
		\"weight\": 4686,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.type\",\
		\"weight\": 4687,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.groupingBehavior\",\
		\"weight\": 4688,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.selectionBehavior\",\
		\"weight\": 4689,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.requiredBehavior\",\
		\"weight\": 4690,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.precheckBehavior\",\
		\"weight\": 4691,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.cardinalityBehavior\",\
		\"weight\": 4692,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.resource\",\
		\"weight\": 4693,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RequestGroup.action.action\",\
		\"weight\": 4694,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy\",\
		\"weight\": 4695,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.id\",\
		\"weight\": 4696,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.meta\",\
		\"weight\": 4697,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.implicitRules\",\
		\"weight\": 4698,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.language\",\
		\"weight\": 4699,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.text\",\
		\"weight\": 4700,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.contained\",\
		\"weight\": 4701,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.extension\",\
		\"weight\": 4702,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.modifierExtension\",\
		\"weight\": 4703,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.identifier\",\
		\"weight\": 4704,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.title\",\
		\"weight\": 4705,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.protocol\",\
		\"weight\": 4706,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.partOf\",\
		\"weight\": 4707,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ResearchStudy.status\",\
		\"weight\": 4708,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.category\",\
		\"weight\": 4709,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.focus\",\
		\"weight\": 4710,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.contact\",\
		\"weight\": 4711,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.relatedArtifact\",\
		\"weight\": 4712,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.keyword\",\
		\"weight\": 4713,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.jurisdiction\",\
		\"weight\": 4714,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.description\",\
		\"weight\": 4715,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.enrollment\",\
		\"weight\": 4716,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.period\",\
		\"weight\": 4717,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.sponsor\",\
		\"weight\": 4718,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.principalInvestigator\",\
		\"weight\": 4719,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.site\",\
		\"weight\": 4720,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.reasonStopped\",\
		\"weight\": 4721,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.note\",\
		\"weight\": 4722,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.arm\",\
		\"weight\": 4723,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.arm.id\",\
		\"weight\": 4724,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.arm.extension\",\
		\"weight\": 4725,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.arm.modifierExtension\",\
		\"weight\": 4726,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ResearchStudy.arm.name\",\
		\"weight\": 4727,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.arm.code\",\
		\"weight\": 4728,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchStudy.arm.description\",\
		\"weight\": 4729,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject\",\
		\"weight\": 4730,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.id\",\
		\"weight\": 4731,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.meta\",\
		\"weight\": 4732,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.implicitRules\",\
		\"weight\": 4733,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.language\",\
		\"weight\": 4734,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.text\",\
		\"weight\": 4735,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.contained\",\
		\"weight\": 4736,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.extension\",\
		\"weight\": 4737,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.modifierExtension\",\
		\"weight\": 4738,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.identifier\",\
		\"weight\": 4739,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ResearchSubject.status\",\
		\"weight\": 4740,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.period\",\
		\"weight\": 4741,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ResearchSubject.study\",\
		\"weight\": 4742,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ResearchSubject.individual\",\
		\"weight\": 4743,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.assignedArm\",\
		\"weight\": 4744,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.actualArm\",\
		\"weight\": 4745,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ResearchSubject.consent\",\
		\"weight\": 4746,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment\",\
		\"weight\": 4747,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.id\",\
		\"weight\": 4748,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.meta\",\
		\"weight\": 4749,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.implicitRules\",\
		\"weight\": 4750,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.language\",\
		\"weight\": 4751,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.text\",\
		\"weight\": 4752,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.contained\",\
		\"weight\": 4753,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.extension\",\
		\"weight\": 4754,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.modifierExtension\",\
		\"weight\": 4755,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.identifier\",\
		\"weight\": 4756,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.basedOn\",\
		\"weight\": 4757,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.parent\",\
		\"weight\": 4758,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RiskAssessment.status\",\
		\"weight\": 4759,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.method\",\
		\"weight\": 4760,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.code\",\
		\"weight\": 4761,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.subject\",\
		\"weight\": 4762,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.context\",\
		\"weight\": 4763,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.occurrenceDateTime\",\
		\"weight\": 4764,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.occurrencePeriod\",\
		\"weight\": 4764,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.condition\",\
		\"weight\": 4765,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.performer\",\
		\"weight\": 4766,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.reasonCodeableConcept\",\
		\"weight\": 4767,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.reasonReference\",\
		\"weight\": 4767,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.basis\",\
		\"weight\": 4768,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction\",\
		\"weight\": 4769,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.id\",\
		\"weight\": 4770,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.extension\",\
		\"weight\": 4771,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.modifierExtension\",\
		\"weight\": 4772,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"RiskAssessment.prediction.outcome\",\
		\"weight\": 4773,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.probabilityDecimal\",\
		\"weight\": 4774,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.probabilityRange\",\
		\"weight\": 4774,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.qualitativeRisk\",\
		\"weight\": 4775,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.relativeRisk\",\
		\"weight\": 4776,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.whenPeriod\",\
		\"weight\": 4777,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.whenRange\",\
		\"weight\": 4777,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.prediction.rationale\",\
		\"weight\": 4778,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.mitigation\",\
		\"weight\": 4779,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"RiskAssessment.comment\",\
		\"weight\": 4780,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule\",\
		\"weight\": 4781,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.id\",\
		\"weight\": 4782,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.meta\",\
		\"weight\": 4783,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.implicitRules\",\
		\"weight\": 4784,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.language\",\
		\"weight\": 4785,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.text\",\
		\"weight\": 4786,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.contained\",\
		\"weight\": 4787,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.extension\",\
		\"weight\": 4788,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.modifierExtension\",\
		\"weight\": 4789,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.identifier\",\
		\"weight\": 4790,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.active\",\
		\"weight\": 4791,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.serviceCategory\",\
		\"weight\": 4792,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.serviceType\",\
		\"weight\": 4793,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.specialty\",\
		\"weight\": 4794,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Schedule.actor\",\
		\"weight\": 4795,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.planningHorizon\",\
		\"weight\": 4796,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Schedule.comment\",\
		\"weight\": 4797,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter\",\
		\"weight\": 4798,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.id\",\
		\"weight\": 4799,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.meta\",\
		\"weight\": 4800,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.implicitRules\",\
		\"weight\": 4801,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.language\",\
		\"weight\": 4802,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.text\",\
		\"weight\": 4803,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.contained\",\
		\"weight\": 4804,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.extension\",\
		\"weight\": 4805,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.modifierExtension\",\
		\"weight\": 4806,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.url\",\
		\"weight\": 4807,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.version\",\
		\"weight\": 4808,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.name\",\
		\"weight\": 4809,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.status\",\
		\"weight\": 4810,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.experimental\",\
		\"weight\": 4811,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.date\",\
		\"weight\": 4812,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.publisher\",\
		\"weight\": 4813,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.contact\",\
		\"weight\": 4814,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.useContext\",\
		\"weight\": 4815,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.jurisdiction\",\
		\"weight\": 4816,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.purpose\",\
		\"weight\": 4817,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.code\",\
		\"weight\": 4818,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.base\",\
		\"weight\": 4819,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.type\",\
		\"weight\": 4820,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.derivedFrom\",\
		\"weight\": 4821,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.description\",\
		\"weight\": 4822,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.expression\",\
		\"weight\": 4823,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.xpath\",\
		\"weight\": 4824,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.xpathUsage\",\
		\"weight\": 4825,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.target\",\
		\"weight\": 4826,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.comparator\",\
		\"weight\": 4827,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.modifier\",\
		\"weight\": 4828,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.chain\",\
		\"weight\": 4829,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.component\",\
		\"weight\": 4830,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.component.id\",\
		\"weight\": 4831,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.component.extension\",\
		\"weight\": 4832,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SearchParameter.component.modifierExtension\",\
		\"weight\": 4833,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.component.definition\",\
		\"weight\": 4834,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SearchParameter.component.expression\",\
		\"weight\": 4835,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence\",\
		\"weight\": 4836,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.id\",\
		\"weight\": 4837,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.meta\",\
		\"weight\": 4838,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.implicitRules\",\
		\"weight\": 4839,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.language\",\
		\"weight\": 4840,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.text\",\
		\"weight\": 4841,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.contained\",\
		\"weight\": 4842,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.extension\",\
		\"weight\": 4843,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.modifierExtension\",\
		\"weight\": 4844,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.identifier\",\
		\"weight\": 4845,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.type\",\
		\"weight\": 4846,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Sequence.coordinateSystem\",\
		\"weight\": 4847,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.patient\",\
		\"weight\": 4848,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.specimen\",\
		\"weight\": 4849,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.device\",\
		\"weight\": 4850,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.performer\",\
		\"weight\": 4851,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quantity\",\
		\"weight\": 4852,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq\",\
		\"weight\": 4853,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.id\",\
		\"weight\": 4854,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.extension\",\
		\"weight\": 4855,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.modifierExtension\",\
		\"weight\": 4856,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.chromosome\",\
		\"weight\": 4857,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.genomeBuild\",\
		\"weight\": 4858,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.referenceSeqId\",\
		\"weight\": 4859,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.referenceSeqPointer\",\
		\"weight\": 4860,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.referenceSeqString\",\
		\"weight\": 4861,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.referenceSeq.strand\",\
		\"weight\": 4862,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Sequence.referenceSeq.windowStart\",\
		\"weight\": 4863,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Sequence.referenceSeq.windowEnd\",\
		\"weight\": 4864,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant\",\
		\"weight\": 4865,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.id\",\
		\"weight\": 4866,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.extension\",\
		\"weight\": 4867,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.modifierExtension\",\
		\"weight\": 4868,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.start\",\
		\"weight\": 4869,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.end\",\
		\"weight\": 4870,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.observedAllele\",\
		\"weight\": 4871,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.referenceAllele\",\
		\"weight\": 4872,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.cigar\",\
		\"weight\": 4873,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.variant.variantPointer\",\
		\"weight\": 4874,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.observedSeq\",\
		\"weight\": 4875,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality\",\
		\"weight\": 4876,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.id\",\
		\"weight\": 4877,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.extension\",\
		\"weight\": 4878,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.modifierExtension\",\
		\"weight\": 4879,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Sequence.quality.type\",\
		\"weight\": 4880,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.standardSequence\",\
		\"weight\": 4881,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.start\",\
		\"weight\": 4882,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.end\",\
		\"weight\": 4883,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.score\",\
		\"weight\": 4884,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.method\",\
		\"weight\": 4885,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.truthTP\",\
		\"weight\": 4886,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.queryTP\",\
		\"weight\": 4887,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.truthFN\",\
		\"weight\": 4888,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.queryFP\",\
		\"weight\": 4889,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.gtFP\",\
		\"weight\": 4890,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.precision\",\
		\"weight\": 4891,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.recall\",\
		\"weight\": 4892,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.quality.fScore\",\
		\"weight\": 4893,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.readCoverage\",\
		\"weight\": 4894,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository\",\
		\"weight\": 4895,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository.id\",\
		\"weight\": 4896,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository.extension\",\
		\"weight\": 4897,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository.modifierExtension\",\
		\"weight\": 4898,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Sequence.repository.type\",\
		\"weight\": 4899,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository.url\",\
		\"weight\": 4900,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository.name\",\
		\"weight\": 4901,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository.datasetId\",\
		\"weight\": 4902,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository.variantsetId\",\
		\"weight\": 4903,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.repository.readsetId\",\
		\"weight\": 4904,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Sequence.pointer\",\
		\"weight\": 4905,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition\",\
		\"weight\": 4906,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.id\",\
		\"weight\": 4907,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.meta\",\
		\"weight\": 4908,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.implicitRules\",\
		\"weight\": 4909,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.language\",\
		\"weight\": 4910,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.text\",\
		\"weight\": 4911,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.contained\",\
		\"weight\": 4912,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.extension\",\
		\"weight\": 4913,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.modifierExtension\",\
		\"weight\": 4914,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.url\",\
		\"weight\": 4915,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.identifier\",\
		\"weight\": 4916,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.version\",\
		\"weight\": 4917,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.name\",\
		\"weight\": 4918,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.title\",\
		\"weight\": 4919,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ServiceDefinition.status\",\
		\"weight\": 4920,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.experimental\",\
		\"weight\": 4921,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.date\",\
		\"weight\": 4922,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.publisher\",\
		\"weight\": 4923,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.description\",\
		\"weight\": 4924,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.purpose\",\
		\"weight\": 4925,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.usage\",\
		\"weight\": 4926,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.approvalDate\",\
		\"weight\": 4927,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.lastReviewDate\",\
		\"weight\": 4928,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.effectivePeriod\",\
		\"weight\": 4929,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.useContext\",\
		\"weight\": 4930,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.jurisdiction\",\
		\"weight\": 4931,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.topic\",\
		\"weight\": 4932,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.contributor\",\
		\"weight\": 4933,\
		\"max\": \"*\",\
		\"type\": \"Contributor\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.contact\",\
		\"weight\": 4934,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.copyright\",\
		\"weight\": 4935,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.relatedArtifact\",\
		\"weight\": 4936,\
		\"max\": \"*\",\
		\"type\": \"RelatedArtifact\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.trigger\",\
		\"weight\": 4937,\
		\"max\": \"*\",\
		\"type\": \"TriggerDefinition\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.dataRequirement\",\
		\"weight\": 4938,\
		\"max\": \"*\",\
		\"type\": \"DataRequirement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ServiceDefinition.operationDefinition\",\
		\"weight\": 4939,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot\",\
		\"weight\": 4940,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.id\",\
		\"weight\": 4941,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.meta\",\
		\"weight\": 4942,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.implicitRules\",\
		\"weight\": 4943,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.language\",\
		\"weight\": 4944,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.text\",\
		\"weight\": 4945,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.contained\",\
		\"weight\": 4946,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.extension\",\
		\"weight\": 4947,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.modifierExtension\",\
		\"weight\": 4948,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.identifier\",\
		\"weight\": 4949,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.serviceCategory\",\
		\"weight\": 4950,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.serviceType\",\
		\"weight\": 4951,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.specialty\",\
		\"weight\": 4952,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.appointmentType\",\
		\"weight\": 4953,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Slot.schedule\",\
		\"weight\": 4954,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Slot.status\",\
		\"weight\": 4955,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Slot.start\",\
		\"weight\": 4956,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Slot.end\",\
		\"weight\": 4957,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.overbooked\",\
		\"weight\": 4958,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Slot.comment\",\
		\"weight\": 4959,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen\",\
		\"weight\": 4960,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.id\",\
		\"weight\": 4961,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.meta\",\
		\"weight\": 4962,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.implicitRules\",\
		\"weight\": 4963,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.language\",\
		\"weight\": 4964,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.text\",\
		\"weight\": 4965,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.contained\",\
		\"weight\": 4966,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.extension\",\
		\"weight\": 4967,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.modifierExtension\",\
		\"weight\": 4968,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.identifier\",\
		\"weight\": 4969,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.accessionIdentifier\",\
		\"weight\": 4970,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.status\",\
		\"weight\": 4971,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.type\",\
		\"weight\": 4972,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Specimen.subject\",\
		\"weight\": 4973,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.receivedTime\",\
		\"weight\": 4974,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.parent\",\
		\"weight\": 4975,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.request\",\
		\"weight\": 4976,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection\",\
		\"weight\": 4977,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.id\",\
		\"weight\": 4978,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.extension\",\
		\"weight\": 4979,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.modifierExtension\",\
		\"weight\": 4980,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.collector\",\
		\"weight\": 4981,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.collectedDateTime\",\
		\"weight\": 4982,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.collectedPeriod\",\
		\"weight\": 4982,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.quantity\",\
		\"weight\": 4983,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.method\",\
		\"weight\": 4984,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.collection.bodySite\",\
		\"weight\": 4985,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing\",\
		\"weight\": 4986,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing.id\",\
		\"weight\": 4987,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing.extension\",\
		\"weight\": 4988,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing.modifierExtension\",\
		\"weight\": 4989,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing.description\",\
		\"weight\": 4990,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing.procedure\",\
		\"weight\": 4991,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing.additive\",\
		\"weight\": 4992,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing.timeDateTime\",\
		\"weight\": 4993,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.processing.timePeriod\",\
		\"weight\": 4993,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container\",\
		\"weight\": 4994,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.id\",\
		\"weight\": 4995,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.extension\",\
		\"weight\": 4996,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.modifierExtension\",\
		\"weight\": 4997,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.identifier\",\
		\"weight\": 4998,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.description\",\
		\"weight\": 4999,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.type\",\
		\"weight\": 5000,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.capacity\",\
		\"weight\": 5001,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.specimenQuantity\",\
		\"weight\": 5002,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.additiveCodeableConcept\",\
		\"weight\": 5003,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.container.additiveReference\",\
		\"weight\": 5003,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Specimen.note\",\
		\"weight\": 5004,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition\",\
		\"weight\": 5005,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.id\",\
		\"weight\": 5006,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.meta\",\
		\"weight\": 5007,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.implicitRules\",\
		\"weight\": 5008,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.language\",\
		\"weight\": 5009,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.text\",\
		\"weight\": 5010,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.contained\",\
		\"weight\": 5011,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.extension\",\
		\"weight\": 5012,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.modifierExtension\",\
		\"weight\": 5013,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.url\",\
		\"weight\": 5014,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.identifier\",\
		\"weight\": 5015,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.version\",\
		\"weight\": 5016,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.name\",\
		\"weight\": 5017,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.title\",\
		\"weight\": 5018,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.status\",\
		\"weight\": 5019,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.experimental\",\
		\"weight\": 5020,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.date\",\
		\"weight\": 5021,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.publisher\",\
		\"weight\": 5022,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.contact\",\
		\"weight\": 5023,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.description\",\
		\"weight\": 5024,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.useContext\",\
		\"weight\": 5025,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.jurisdiction\",\
		\"weight\": 5026,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.purpose\",\
		\"weight\": 5027,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.copyright\",\
		\"weight\": 5028,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.keyword\",\
		\"weight\": 5029,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.fhirVersion\",\
		\"weight\": 5030,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.mapping\",\
		\"weight\": 5031,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.mapping.id\",\
		\"weight\": 5032,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.mapping.extension\",\
		\"weight\": 5033,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.mapping.modifierExtension\",\
		\"weight\": 5034,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.mapping.identity\",\
		\"weight\": 5035,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.mapping.uri\",\
		\"weight\": 5036,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.mapping.name\",\
		\"weight\": 5037,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.mapping.comment\",\
		\"weight\": 5038,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.kind\",\
		\"weight\": 5039,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.abstract\",\
		\"weight\": 5040,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.contextType\",\
		\"weight\": 5041,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.context\",\
		\"weight\": 5042,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.contextInvariant\",\
		\"weight\": 5043,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.type\",\
		\"weight\": 5044,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.baseDefinition\",\
		\"weight\": 5045,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.derivation\",\
		\"weight\": 5046,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.snapshot\",\
		\"weight\": 5047,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.snapshot.id\",\
		\"weight\": 5048,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.snapshot.extension\",\
		\"weight\": 5049,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.snapshot.modifierExtension\",\
		\"weight\": 5050,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.snapshot.element\",\
		\"weight\": 5051,\
		\"max\": \"*\",\
		\"type\": \"ElementDefinition\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.differential\",\
		\"weight\": 5052,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.differential.id\",\
		\"weight\": 5053,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.differential.extension\",\
		\"weight\": 5054,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureDefinition.differential.modifierExtension\",\
		\"weight\": 5055,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureDefinition.differential.element\",\
		\"weight\": 5056,\
		\"max\": \"*\",\
		\"type\": \"ElementDefinition\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap\",\
		\"weight\": 5057,\
		\"max\": \"1\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.id\",\
		\"weight\": 5058,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.meta\",\
		\"weight\": 5059,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.implicitRules\",\
		\"weight\": 5060,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.language\",\
		\"weight\": 5061,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.text\",\
		\"weight\": 5062,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.contained\",\
		\"weight\": 5063,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.extension\",\
		\"weight\": 5064,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.modifierExtension\",\
		\"weight\": 5065,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.url\",\
		\"weight\": 5066,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.identifier\",\
		\"weight\": 5067,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.version\",\
		\"weight\": 5068,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.name\",\
		\"weight\": 5069,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.title\",\
		\"weight\": 5070,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.status\",\
		\"weight\": 5071,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.experimental\",\
		\"weight\": 5072,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.date\",\
		\"weight\": 5073,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.publisher\",\
		\"weight\": 5074,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.contact\",\
		\"weight\": 5075,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.description\",\
		\"weight\": 5076,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.useContext\",\
		\"weight\": 5077,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.jurisdiction\",\
		\"weight\": 5078,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.purpose\",\
		\"weight\": 5079,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.copyright\",\
		\"weight\": 5080,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.structure\",\
		\"weight\": 5081,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.structure.id\",\
		\"weight\": 5082,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.structure.extension\",\
		\"weight\": 5083,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.structure.modifierExtension\",\
		\"weight\": 5084,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.structure.url\",\
		\"weight\": 5085,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.structure.mode\",\
		\"weight\": 5086,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.structure.alias\",\
		\"weight\": 5087,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.structure.documentation\",\
		\"weight\": 5088,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.import\",\
		\"weight\": 5089,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group\",\
		\"weight\": 5090,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.id\",\
		\"weight\": 5091,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.extension\",\
		\"weight\": 5092,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.modifierExtension\",\
		\"weight\": 5093,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.name\",\
		\"weight\": 5094,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.extends\",\
		\"weight\": 5095,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.typeMode\",\
		\"weight\": 5096,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.documentation\",\
		\"weight\": 5097,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.input\",\
		\"weight\": 5098,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.input.id\",\
		\"weight\": 5099,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.input.extension\",\
		\"weight\": 5100,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.input.modifierExtension\",\
		\"weight\": 5101,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.input.name\",\
		\"weight\": 5102,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.input.type\",\
		\"weight\": 5103,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.input.mode\",\
		\"weight\": 5104,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.input.documentation\",\
		\"weight\": 5105,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule\",\
		\"weight\": 5106,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.id\",\
		\"weight\": 5107,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.extension\",\
		\"weight\": 5108,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.modifierExtension\",\
		\"weight\": 5109,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.name\",\
		\"weight\": 5110,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.source\",\
		\"weight\": 5111,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.id\",\
		\"weight\": 5112,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.extension\",\
		\"weight\": 5113,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.modifierExtension\",\
		\"weight\": 5114,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.source.context\",\
		\"weight\": 5115,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.min\",\
		\"weight\": 5116,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.max\",\
		\"weight\": 5117,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.type\",\
		\"weight\": 5118,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueBase64Binary\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueBoolean\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueCode\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueDate\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueDateTime\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueDecimal\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueId\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueInstant\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueInteger\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueMarkdown\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueOid\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValuePositiveInt\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueString\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueTime\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueUnsignedInt\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueUri\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueAddress\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueAge\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueAnnotation\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueAttachment\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueCodeableConcept\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueCoding\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueContactPoint\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueCount\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueDistance\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueDuration\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueHumanName\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueIdentifier\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueMoney\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValuePeriod\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueQuantity\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueRange\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueRatio\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueReference\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueSampledData\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueSignature\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueTiming\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.defaultValueMeta\",\
		\"weight\": 5119,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.element\",\
		\"weight\": 5120,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.listMode\",\
		\"weight\": 5121,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.variable\",\
		\"weight\": 5122,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.condition\",\
		\"weight\": 5123,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.source.check\",\
		\"weight\": 5124,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target\",\
		\"weight\": 5125,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.id\",\
		\"weight\": 5126,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.extension\",\
		\"weight\": 5127,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.modifierExtension\",\
		\"weight\": 5128,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.context\",\
		\"weight\": 5129,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.contextType\",\
		\"weight\": 5130,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.element\",\
		\"weight\": 5131,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.variable\",\
		\"weight\": 5132,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.listMode\",\
		\"weight\": 5133,\
		\"max\": \"*\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.listRuleId\",\
		\"weight\": 5134,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.transform\",\
		\"weight\": 5135,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.parameter\",\
		\"weight\": 5136,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.parameter.id\",\
		\"weight\": 5137,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.parameter.extension\",\
		\"weight\": 5138,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.target.parameter.modifierExtension\",\
		\"weight\": 5139,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.target.parameter.valueId\",\
		\"weight\": 5140,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.target.parameter.valueString\",\
		\"weight\": 5140,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.target.parameter.valueBoolean\",\
		\"weight\": 5140,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.target.parameter.valueInteger\",\
		\"weight\": 5140,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.target.parameter.valueDecimal\",\
		\"weight\": 5140,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.rule\",\
		\"weight\": 5141,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.dependent\",\
		\"weight\": 5142,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.dependent.id\",\
		\"weight\": 5143,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.dependent.extension\",\
		\"weight\": 5144,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.dependent.modifierExtension\",\
		\"weight\": 5145,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.dependent.name\",\
		\"weight\": 5146,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"StructureMap.group.rule.dependent.variable\",\
		\"weight\": 5147,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"StructureMap.group.rule.documentation\",\
		\"weight\": 5148,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription\",\
		\"weight\": 5149,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.id\",\
		\"weight\": 5150,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.meta\",\
		\"weight\": 5151,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.implicitRules\",\
		\"weight\": 5152,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.language\",\
		\"weight\": 5153,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.text\",\
		\"weight\": 5154,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.contained\",\
		\"weight\": 5155,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.extension\",\
		\"weight\": 5156,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.modifierExtension\",\
		\"weight\": 5157,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Subscription.status\",\
		\"weight\": 5158,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.contact\",\
		\"weight\": 5159,\
		\"max\": \"*\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.end\",\
		\"weight\": 5160,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Subscription.reason\",\
		\"weight\": 5161,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Subscription.criteria\",\
		\"weight\": 5162,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.error\",\
		\"weight\": 5163,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Subscription.channel\",\
		\"weight\": 5164,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.channel.id\",\
		\"weight\": 5165,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.channel.extension\",\
		\"weight\": 5166,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.channel.modifierExtension\",\
		\"weight\": 5167,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Subscription.channel.type\",\
		\"weight\": 5168,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.channel.endpoint\",\
		\"weight\": 5169,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.channel.payload\",\
		\"weight\": 5170,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.channel.header\",\
		\"weight\": 5171,\
		\"max\": \"*\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Subscription.tag\",\
		\"weight\": 5172,\
		\"max\": \"*\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance\",\
		\"weight\": 5173,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.id\",\
		\"weight\": 5174,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.meta\",\
		\"weight\": 5175,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.implicitRules\",\
		\"weight\": 5176,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.language\",\
		\"weight\": 5177,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.text\",\
		\"weight\": 5178,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.contained\",\
		\"weight\": 5179,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.extension\",\
		\"weight\": 5180,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.modifierExtension\",\
		\"weight\": 5181,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.identifier\",\
		\"weight\": 5182,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.status\",\
		\"weight\": 5183,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.category\",\
		\"weight\": 5184,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Substance.code\",\
		\"weight\": 5185,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.description\",\
		\"weight\": 5186,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.instance\",\
		\"weight\": 5187,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.instance.id\",\
		\"weight\": 5188,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.instance.extension\",\
		\"weight\": 5189,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.instance.modifierExtension\",\
		\"weight\": 5190,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.instance.identifier\",\
		\"weight\": 5191,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.instance.expiry\",\
		\"weight\": 5192,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.instance.quantity\",\
		\"weight\": 5193,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.ingredient\",\
		\"weight\": 5194,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.ingredient.id\",\
		\"weight\": 5195,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.ingredient.extension\",\
		\"weight\": 5196,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.ingredient.modifierExtension\",\
		\"weight\": 5197,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Substance.ingredient.quantity\",\
		\"weight\": 5198,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Substance.ingredient.substanceCodeableConcept\",\
		\"weight\": 5199,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Substance.ingredient.substanceReference\",\
		\"weight\": 5199,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery\",\
		\"weight\": 5200,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.id\",\
		\"weight\": 5201,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.meta\",\
		\"weight\": 5202,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.implicitRules\",\
		\"weight\": 5203,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.language\",\
		\"weight\": 5204,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.text\",\
		\"weight\": 5205,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.contained\",\
		\"weight\": 5206,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.extension\",\
		\"weight\": 5207,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.modifierExtension\",\
		\"weight\": 5208,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.identifier\",\
		\"weight\": 5209,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.basedOn\",\
		\"weight\": 5210,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.partOf\",\
		\"weight\": 5211,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.status\",\
		\"weight\": 5212,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.patient\",\
		\"weight\": 5213,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.type\",\
		\"weight\": 5214,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem\",\
		\"weight\": 5215,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem.id\",\
		\"weight\": 5216,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem.extension\",\
		\"weight\": 5217,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem.modifierExtension\",\
		\"weight\": 5218,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem.quantity\",\
		\"weight\": 5219,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem.itemCodeableConcept\",\
		\"weight\": 5220,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem.itemReference\",\
		\"weight\": 5220,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem.itemReference\",\
		\"weight\": 5220,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.suppliedItem.itemReference\",\
		\"weight\": 5220,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.occurrenceDateTime\",\
		\"weight\": 5221,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.occurrencePeriod\",\
		\"weight\": 5221,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.occurrenceTiming\",\
		\"weight\": 5221,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.supplier\",\
		\"weight\": 5222,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.destination\",\
		\"weight\": 5223,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyDelivery.receiver\",\
		\"weight\": 5224,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest\",\
		\"weight\": 5225,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.id\",\
		\"weight\": 5226,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.meta\",\
		\"weight\": 5227,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.implicitRules\",\
		\"weight\": 5228,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.language\",\
		\"weight\": 5229,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.text\",\
		\"weight\": 5230,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.contained\",\
		\"weight\": 5231,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.extension\",\
		\"weight\": 5232,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.modifierExtension\",\
		\"weight\": 5233,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.identifier\",\
		\"weight\": 5234,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.status\",\
		\"weight\": 5235,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.category\",\
		\"weight\": 5236,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.priority\",\
		\"weight\": 5237,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.orderedItem\",\
		\"weight\": 5238,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.orderedItem.id\",\
		\"weight\": 5239,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.orderedItem.extension\",\
		\"weight\": 5240,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.orderedItem.modifierExtension\",\
		\"weight\": 5241,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SupplyRequest.orderedItem.quantity\",\
		\"weight\": 5242,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.orderedItem.itemCodeableConcept\",\
		\"weight\": 5243,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.orderedItem.itemReference\",\
		\"weight\": 5243,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.orderedItem.itemReference\",\
		\"weight\": 5243,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.orderedItem.itemReference\",\
		\"weight\": 5243,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.occurrenceDateTime\",\
		\"weight\": 5244,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.occurrencePeriod\",\
		\"weight\": 5244,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.occurrenceTiming\",\
		\"weight\": 5244,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.authoredOn\",\
		\"weight\": 5245,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.requester\",\
		\"weight\": 5246,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.requester.id\",\
		\"weight\": 5247,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.requester.extension\",\
		\"weight\": 5248,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.requester.modifierExtension\",\
		\"weight\": 5249,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"SupplyRequest.requester.agent\",\
		\"weight\": 5250,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.requester.onBehalfOf\",\
		\"weight\": 5251,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.supplier\",\
		\"weight\": 5252,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.reasonCodeableConcept\",\
		\"weight\": 5253,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.reasonReference\",\
		\"weight\": 5253,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.deliverFrom\",\
		\"weight\": 5254,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"SupplyRequest.deliverTo\",\
		\"weight\": 5255,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task\",\
		\"weight\": 5256,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.id\",\
		\"weight\": 5257,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.meta\",\
		\"weight\": 5258,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.implicitRules\",\
		\"weight\": 5259,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.language\",\
		\"weight\": 5260,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.text\",\
		\"weight\": 5261,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.contained\",\
		\"weight\": 5262,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.extension\",\
		\"weight\": 5263,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.modifierExtension\",\
		\"weight\": 5264,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.identifier\",\
		\"weight\": 5265,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.definitionUri\",\
		\"weight\": 5266,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.definitionReference\",\
		\"weight\": 5266,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.basedOn\",\
		\"weight\": 5267,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.groupIdentifier\",\
		\"weight\": 5268,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.partOf\",\
		\"weight\": 5269,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.status\",\
		\"weight\": 5270,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.statusReason\",\
		\"weight\": 5271,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.businessStatus\",\
		\"weight\": 5272,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.intent\",\
		\"weight\": 5273,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.priority\",\
		\"weight\": 5274,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.code\",\
		\"weight\": 5275,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.description\",\
		\"weight\": 5276,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.focus\",\
		\"weight\": 5277,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.for\",\
		\"weight\": 5278,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.context\",\
		\"weight\": 5279,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.executionPeriod\",\
		\"weight\": 5280,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.authoredOn\",\
		\"weight\": 5281,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.lastModified\",\
		\"weight\": 5282,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.requester\",\
		\"weight\": 5283,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.requester.id\",\
		\"weight\": 5284,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.requester.extension\",\
		\"weight\": 5285,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.requester.modifierExtension\",\
		\"weight\": 5286,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.requester.agent\",\
		\"weight\": 5287,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.requester.onBehalfOf\",\
		\"weight\": 5288,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.performerType\",\
		\"weight\": 5289,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.owner\",\
		\"weight\": 5290,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.reason\",\
		\"weight\": 5291,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.note\",\
		\"weight\": 5292,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.relevantHistory\",\
		\"weight\": 5293,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.restriction\",\
		\"weight\": 5294,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.restriction.id\",\
		\"weight\": 5295,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.restriction.extension\",\
		\"weight\": 5296,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.restriction.modifierExtension\",\
		\"weight\": 5297,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.restriction.repetitions\",\
		\"weight\": 5298,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.restriction.period\",\
		\"weight\": 5299,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.restriction.recipient\",\
		\"weight\": 5300,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.input\",\
		\"weight\": 5301,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.input.id\",\
		\"weight\": 5302,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.input.extension\",\
		\"weight\": 5303,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.input.modifierExtension\",\
		\"weight\": 5304,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.type\",\
		\"weight\": 5305,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueBase64Binary\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueBoolean\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueCode\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueDate\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueDateTime\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueDecimal\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueId\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueInstant\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueInteger\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueMarkdown\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueOid\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valuePositiveInt\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueString\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueTime\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueUnsignedInt\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueUri\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueAddress\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueAge\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueAnnotation\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueAttachment\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueCodeableConcept\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueCoding\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueContactPoint\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueCount\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueDistance\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueDuration\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueHumanName\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueIdentifier\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueMoney\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valuePeriod\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueQuantity\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueRange\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueRatio\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueReference\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueSampledData\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueSignature\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueTiming\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.input.valueMeta\",\
		\"weight\": 5306,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.output\",\
		\"weight\": 5307,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.output.id\",\
		\"weight\": 5308,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.output.extension\",\
		\"weight\": 5309,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"Task.output.modifierExtension\",\
		\"weight\": 5310,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.type\",\
		\"weight\": 5311,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueBase64Binary\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueBoolean\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueCode\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueDate\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueDateTime\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueDecimal\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueId\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueInstant\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueInteger\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueMarkdown\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueOid\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valuePositiveInt\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueString\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueTime\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueUnsignedInt\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueUri\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueAddress\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueAge\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Age\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueAnnotation\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueAttachment\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueCodeableConcept\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueCoding\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueContactPoint\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueCount\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Count\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueDistance\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Distance\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueDuration\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Duration\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueHumanName\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueIdentifier\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueMoney\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Money\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valuePeriod\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueQuantity\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueRange\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueRatio\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueReference\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueSampledData\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueSignature\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueTiming\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"Task.output.valueMeta\",\
		\"weight\": 5312,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport\",\
		\"weight\": 5313,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.id\",\
		\"weight\": 5314,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.meta\",\
		\"weight\": 5315,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.implicitRules\",\
		\"weight\": 5316,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.language\",\
		\"weight\": 5317,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.text\",\
		\"weight\": 5318,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.contained\",\
		\"weight\": 5319,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.extension\",\
		\"weight\": 5320,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.modifierExtension\",\
		\"weight\": 5321,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.identifier\",\
		\"weight\": 5322,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.name\",\
		\"weight\": 5323,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.status\",\
		\"weight\": 5324,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.testScript\",\
		\"weight\": 5325,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.result\",\
		\"weight\": 5326,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.score\",\
		\"weight\": 5327,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.tester\",\
		\"weight\": 5328,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.issued\",\
		\"weight\": 5329,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.participant\",\
		\"weight\": 5330,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.participant.id\",\
		\"weight\": 5331,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.participant.extension\",\
		\"weight\": 5332,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.participant.modifierExtension\",\
		\"weight\": 5333,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.participant.type\",\
		\"weight\": 5334,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.participant.uri\",\
		\"weight\": 5335,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.participant.display\",\
		\"weight\": 5336,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup\",\
		\"weight\": 5337,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.id\",\
		\"weight\": 5338,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.extension\",\
		\"weight\": 5339,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.modifierExtension\",\
		\"weight\": 5340,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.setup.action\",\
		\"weight\": 5341,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.id\",\
		\"weight\": 5342,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.extension\",\
		\"weight\": 5343,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.modifierExtension\",\
		\"weight\": 5344,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.operation\",\
		\"weight\": 5345,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.operation.id\",\
		\"weight\": 5346,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.operation.extension\",\
		\"weight\": 5347,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.operation.modifierExtension\",\
		\"weight\": 5348,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.setup.action.operation.result\",\
		\"weight\": 5349,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.operation.message\",\
		\"weight\": 5350,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.operation.detail\",\
		\"weight\": 5351,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.assert\",\
		\"weight\": 5352,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.assert.id\",\
		\"weight\": 5353,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.assert.extension\",\
		\"weight\": 5354,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.assert.modifierExtension\",\
		\"weight\": 5355,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.setup.action.assert.result\",\
		\"weight\": 5356,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.assert.message\",\
		\"weight\": 5357,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.setup.action.assert.detail\",\
		\"weight\": 5358,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test\",\
		\"weight\": 5359,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.id\",\
		\"weight\": 5360,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.extension\",\
		\"weight\": 5361,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.modifierExtension\",\
		\"weight\": 5362,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.name\",\
		\"weight\": 5363,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.description\",\
		\"weight\": 5364,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.test.action\",\
		\"weight\": 5365,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.action.id\",\
		\"weight\": 5366,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.action.extension\",\
		\"weight\": 5367,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.action.modifierExtension\",\
		\"weight\": 5368,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.action.operation\",\
		\"weight\": 5369,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.test.action.assert\",\
		\"weight\": 5370,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.teardown\",\
		\"weight\": 5371,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.teardown.id\",\
		\"weight\": 5372,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.teardown.extension\",\
		\"weight\": 5373,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.teardown.modifierExtension\",\
		\"weight\": 5374,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.teardown.action\",\
		\"weight\": 5375,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.teardown.action.id\",\
		\"weight\": 5376,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.teardown.action.extension\",\
		\"weight\": 5377,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestReport.teardown.action.modifierExtension\",\
		\"weight\": 5378,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestReport.teardown.action.operation\",\
		\"weight\": 5379,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript\",\
		\"weight\": 5380,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.id\",\
		\"weight\": 5381,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.meta\",\
		\"weight\": 5382,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.implicitRules\",\
		\"weight\": 5383,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.language\",\
		\"weight\": 5384,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.text\",\
		\"weight\": 5385,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.contained\",\
		\"weight\": 5386,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.extension\",\
		\"weight\": 5387,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.modifierExtension\",\
		\"weight\": 5388,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.url\",\
		\"weight\": 5389,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.identifier\",\
		\"weight\": 5390,\
		\"max\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.version\",\
		\"weight\": 5391,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.name\",\
		\"weight\": 5392,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.title\",\
		\"weight\": 5393,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.status\",\
		\"weight\": 5394,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.experimental\",\
		\"weight\": 5395,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.date\",\
		\"weight\": 5396,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.publisher\",\
		\"weight\": 5397,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.contact\",\
		\"weight\": 5398,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.description\",\
		\"weight\": 5399,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.useContext\",\
		\"weight\": 5400,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.jurisdiction\",\
		\"weight\": 5401,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.purpose\",\
		\"weight\": 5402,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.copyright\",\
		\"weight\": 5403,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.origin\",\
		\"weight\": 5404,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.origin.id\",\
		\"weight\": 5405,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.origin.extension\",\
		\"weight\": 5406,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.origin.modifierExtension\",\
		\"weight\": 5407,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.origin.index\",\
		\"weight\": 5408,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.origin.profile\",\
		\"weight\": 5409,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.destination\",\
		\"weight\": 5410,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.destination.id\",\
		\"weight\": 5411,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.destination.extension\",\
		\"weight\": 5412,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.destination.modifierExtension\",\
		\"weight\": 5413,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.destination.index\",\
		\"weight\": 5414,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.destination.profile\",\
		\"weight\": 5415,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata\",\
		\"weight\": 5416,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.id\",\
		\"weight\": 5417,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.extension\",\
		\"weight\": 5418,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.modifierExtension\",\
		\"weight\": 5419,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.link\",\
		\"weight\": 5420,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.link.id\",\
		\"weight\": 5421,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.link.extension\",\
		\"weight\": 5422,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.link.modifierExtension\",\
		\"weight\": 5423,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.metadata.link.url\",\
		\"weight\": 5424,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.link.description\",\
		\"weight\": 5425,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.metadata.capability\",\
		\"weight\": 5426,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.id\",\
		\"weight\": 5427,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.extension\",\
		\"weight\": 5428,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.modifierExtension\",\
		\"weight\": 5429,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.required\",\
		\"weight\": 5430,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.validated\",\
		\"weight\": 5431,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.description\",\
		\"weight\": 5432,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.origin\",\
		\"weight\": 5433,\
		\"max\": \"*\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.destination\",\
		\"weight\": 5434,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.metadata.capability.link\",\
		\"weight\": 5435,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.metadata.capability.capabilities\",\
		\"weight\": 5436,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.fixture\",\
		\"weight\": 5437,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.fixture.id\",\
		\"weight\": 5438,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.fixture.extension\",\
		\"weight\": 5439,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.fixture.modifierExtension\",\
		\"weight\": 5440,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.fixture.autocreate\",\
		\"weight\": 5441,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.fixture.autodelete\",\
		\"weight\": 5442,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.fixture.resource\",\
		\"weight\": 5443,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.profile\",\
		\"weight\": 5444,\
		\"max\": \"*\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable\",\
		\"weight\": 5445,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.id\",\
		\"weight\": 5446,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.extension\",\
		\"weight\": 5447,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.modifierExtension\",\
		\"weight\": 5448,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.variable.name\",\
		\"weight\": 5449,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.defaultValue\",\
		\"weight\": 5450,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.description\",\
		\"weight\": 5451,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.expression\",\
		\"weight\": 5452,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.headerField\",\
		\"weight\": 5453,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.hint\",\
		\"weight\": 5454,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.path\",\
		\"weight\": 5455,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.variable.sourceId\",\
		\"weight\": 5456,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule\",\
		\"weight\": 5457,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule.id\",\
		\"weight\": 5458,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule.extension\",\
		\"weight\": 5459,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule.modifierExtension\",\
		\"weight\": 5460,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.rule.resource\",\
		\"weight\": 5461,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule.param\",\
		\"weight\": 5462,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule.param.id\",\
		\"weight\": 5463,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule.param.extension\",\
		\"weight\": 5464,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule.param.modifierExtension\",\
		\"weight\": 5465,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.rule.param.name\",\
		\"weight\": 5466,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.rule.param.value\",\
		\"weight\": 5467,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset\",\
		\"weight\": 5468,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.id\",\
		\"weight\": 5469,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.extension\",\
		\"weight\": 5470,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.modifierExtension\",\
		\"weight\": 5471,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.ruleset.resource\",\
		\"weight\": 5472,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.ruleset.rule\",\
		\"weight\": 5473,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.rule.id\",\
		\"weight\": 5474,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.rule.extension\",\
		\"weight\": 5475,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.rule.modifierExtension\",\
		\"weight\": 5476,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.ruleset.rule.ruleId\",\
		\"weight\": 5477,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.rule.param\",\
		\"weight\": 5478,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.rule.param.id\",\
		\"weight\": 5479,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.rule.param.extension\",\
		\"weight\": 5480,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.rule.param.modifierExtension\",\
		\"weight\": 5481,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.ruleset.rule.param.name\",\
		\"weight\": 5482,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.ruleset.rule.param.value\",\
		\"weight\": 5483,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup\",\
		\"weight\": 5484,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.id\",\
		\"weight\": 5485,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.extension\",\
		\"weight\": 5486,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.modifierExtension\",\
		\"weight\": 5487,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action\",\
		\"weight\": 5488,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.id\",\
		\"weight\": 5489,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.extension\",\
		\"weight\": 5490,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.modifierExtension\",\
		\"weight\": 5491,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation\",\
		\"weight\": 5492,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.id\",\
		\"weight\": 5493,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.extension\",\
		\"weight\": 5494,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.modifierExtension\",\
		\"weight\": 5495,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.type\",\
		\"weight\": 5496,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.resource\",\
		\"weight\": 5497,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.label\",\
		\"weight\": 5498,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.description\",\
		\"weight\": 5499,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.accept\",\
		\"weight\": 5500,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.contentType\",\
		\"weight\": 5501,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.destination\",\
		\"weight\": 5502,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.encodeRequestUrl\",\
		\"weight\": 5503,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.origin\",\
		\"weight\": 5504,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.params\",\
		\"weight\": 5505,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.requestHeader\",\
		\"weight\": 5506,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.requestHeader.id\",\
		\"weight\": 5507,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.requestHeader.extension\",\
		\"weight\": 5508,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.requestHeader.modifierExtension\",\
		\"weight\": 5509,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.operation.requestHeader.field\",\
		\"weight\": 5510,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.operation.requestHeader.value\",\
		\"weight\": 5511,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.requestId\",\
		\"weight\": 5512,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.responseId\",\
		\"weight\": 5513,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.sourceId\",\
		\"weight\": 5514,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.targetId\",\
		\"weight\": 5515,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.operation.url\",\
		\"weight\": 5516,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert\",\
		\"weight\": 5517,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.id\",\
		\"weight\": 5518,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.extension\",\
		\"weight\": 5519,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.modifierExtension\",\
		\"weight\": 5520,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.label\",\
		\"weight\": 5521,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.description\",\
		\"weight\": 5522,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.direction\",\
		\"weight\": 5523,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.compareToSourceId\",\
		\"weight\": 5524,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.compareToSourceExpression\",\
		\"weight\": 5525,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.compareToSourcePath\",\
		\"weight\": 5526,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.contentType\",\
		\"weight\": 5527,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.expression\",\
		\"weight\": 5528,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.headerField\",\
		\"weight\": 5529,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.minimumId\",\
		\"weight\": 5530,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.navigationLinks\",\
		\"weight\": 5531,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.operator\",\
		\"weight\": 5532,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.path\",\
		\"weight\": 5533,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.requestMethod\",\
		\"weight\": 5534,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.requestURL\",\
		\"weight\": 5535,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.resource\",\
		\"weight\": 5536,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.response\",\
		\"weight\": 5537,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.responseCode\",\
		\"weight\": 5538,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.rule\",\
		\"weight\": 5539,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.rule.id\",\
		\"weight\": 5540,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.rule.extension\",\
		\"weight\": 5541,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.rule.modifierExtension\",\
		\"weight\": 5542,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.assert.rule.ruleId\",\
		\"weight\": 5543,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.rule.param\",\
		\"weight\": 5544,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.rule.param.id\",\
		\"weight\": 5545,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.rule.param.extension\",\
		\"weight\": 5546,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.rule.param.modifierExtension\",\
		\"weight\": 5547,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.assert.rule.param.name\",\
		\"weight\": 5548,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.assert.rule.param.value\",\
		\"weight\": 5549,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset\",\
		\"weight\": 5550,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.id\",\
		\"weight\": 5551,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.extension\",\
		\"weight\": 5552,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.modifierExtension\",\
		\"weight\": 5553,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rulesetId\",\
		\"weight\": 5554,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule\",\
		\"weight\": 5555,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.id\",\
		\"weight\": 5556,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.extension\",\
		\"weight\": 5557,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.modifierExtension\",\
		\"weight\": 5558,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.ruleId\",\
		\"weight\": 5559,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param\",\
		\"weight\": 5560,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.id\",\
		\"weight\": 5561,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.extension\",\
		\"weight\": 5562,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.modifierExtension\",\
		\"weight\": 5563,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.name\",\
		\"weight\": 5564,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.value\",\
		\"weight\": 5565,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.sourceId\",\
		\"weight\": 5566,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.validateProfileId\",\
		\"weight\": 5567,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.value\",\
		\"weight\": 5568,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.setup.action.assert.warningOnly\",\
		\"weight\": 5569,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test\",\
		\"weight\": 5570,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.id\",\
		\"weight\": 5571,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.extension\",\
		\"weight\": 5572,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.modifierExtension\",\
		\"weight\": 5573,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.name\",\
		\"weight\": 5574,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.description\",\
		\"weight\": 5575,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.test.action\",\
		\"weight\": 5576,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.action.id\",\
		\"weight\": 5577,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.action.extension\",\
		\"weight\": 5578,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.action.modifierExtension\",\
		\"weight\": 5579,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.action.operation\",\
		\"weight\": 5580,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.test.action.assert\",\
		\"weight\": 5581,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.teardown\",\
		\"weight\": 5582,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.teardown.id\",\
		\"weight\": 5583,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.teardown.extension\",\
		\"weight\": 5584,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.teardown.modifierExtension\",\
		\"weight\": 5585,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.teardown.action\",\
		\"weight\": 5586,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.teardown.action.id\",\
		\"weight\": 5587,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.teardown.action.extension\",\
		\"weight\": 5588,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"TestScript.teardown.action.modifierExtension\",\
		\"weight\": 5589,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"TestScript.teardown.action.operation\",\
		\"weight\": 5590,\
		\"max\": \"1\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet\",\
		\"weight\": 5591,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.id\",\
		\"weight\": 5592,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.meta\",\
		\"weight\": 5593,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.implicitRules\",\
		\"weight\": 5594,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.language\",\
		\"weight\": 5595,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.text\",\
		\"weight\": 5596,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.contained\",\
		\"weight\": 5597,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.extension\",\
		\"weight\": 5598,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.modifierExtension\",\
		\"weight\": 5599,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.url\",\
		\"weight\": 5600,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.identifier\",\
		\"weight\": 5601,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.version\",\
		\"weight\": 5602,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.name\",\
		\"weight\": 5603,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.title\",\
		\"weight\": 5604,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.status\",\
		\"weight\": 5605,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.experimental\",\
		\"weight\": 5606,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.date\",\
		\"weight\": 5607,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.publisher\",\
		\"weight\": 5608,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.contact\",\
		\"weight\": 5609,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.description\",\
		\"weight\": 5610,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.useContext\",\
		\"weight\": 5611,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.jurisdiction\",\
		\"weight\": 5612,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.immutable\",\
		\"weight\": 5613,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.purpose\",\
		\"weight\": 5614,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.copyright\",\
		\"weight\": 5615,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.extensible\",\
		\"weight\": 5616,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose\",\
		\"weight\": 5617,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.id\",\
		\"weight\": 5618,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.extension\",\
		\"weight\": 5619,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.modifierExtension\",\
		\"weight\": 5620,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.lockedDate\",\
		\"weight\": 5621,\
		\"max\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.inactive\",\
		\"weight\": 5622,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.compose.include\",\
		\"weight\": 5623,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.id\",\
		\"weight\": 5624,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.extension\",\
		\"weight\": 5625,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.modifierExtension\",\
		\"weight\": 5626,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.system\",\
		\"weight\": 5627,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.version\",\
		\"weight\": 5628,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept\",\
		\"weight\": 5629,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.id\",\
		\"weight\": 5630,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.extension\",\
		\"weight\": 5631,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.modifierExtension\",\
		\"weight\": 5632,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.compose.include.concept.code\",\
		\"weight\": 5633,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.display\",\
		\"weight\": 5634,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.designation\",\
		\"weight\": 5635,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.designation.id\",\
		\"weight\": 5636,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.designation.extension\",\
		\"weight\": 5637,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.designation.modifierExtension\",\
		\"weight\": 5638,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.designation.language\",\
		\"weight\": 5639,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.concept.designation.use\",\
		\"weight\": 5640,\
		\"max\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.compose.include.concept.designation.value\",\
		\"weight\": 5641,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.filter\",\
		\"weight\": 5642,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.filter.id\",\
		\"weight\": 5643,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.filter.extension\",\
		\"weight\": 5644,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.filter.modifierExtension\",\
		\"weight\": 5645,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.compose.include.filter.property\",\
		\"weight\": 5646,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.compose.include.filter.op\",\
		\"weight\": 5647,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.compose.include.filter.value\",\
		\"weight\": 5648,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.include.valueSet\",\
		\"weight\": 5649,\
		\"max\": \"*\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.compose.exclude\",\
		\"weight\": 5650,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion\",\
		\"weight\": 5651,\
		\"max\": \"1\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.id\",\
		\"weight\": 5652,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.extension\",\
		\"weight\": 5653,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.modifierExtension\",\
		\"weight\": 5654,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.expansion.identifier\",\
		\"weight\": 5655,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.expansion.timestamp\",\
		\"weight\": 5656,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.total\",\
		\"weight\": 5657,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.offset\",\
		\"weight\": 5658,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter\",\
		\"weight\": 5659,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.id\",\
		\"weight\": 5660,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.extension\",\
		\"weight\": 5661,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.modifierExtension\",\
		\"weight\": 5662,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"ValueSet.expansion.parameter.name\",\
		\"weight\": 5663,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.valueString\",\
		\"weight\": 5664,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.valueBoolean\",\
		\"weight\": 5664,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.valueInteger\",\
		\"weight\": 5664,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.valueDecimal\",\
		\"weight\": 5664,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.valueUri\",\
		\"weight\": 5664,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.parameter.valueCode\",\
		\"weight\": 5664,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains\",\
		\"weight\": 5665,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.id\",\
		\"weight\": 5666,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.extension\",\
		\"weight\": 5667,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.modifierExtension\",\
		\"weight\": 5668,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.system\",\
		\"weight\": 5669,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.abstract\",\
		\"weight\": 5670,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.inactive\",\
		\"weight\": 5671,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.version\",\
		\"weight\": 5672,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.code\",\
		\"weight\": 5673,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.display\",\
		\"weight\": 5674,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.designation\",\
		\"weight\": 5675,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"ValueSet.expansion.contains.contains\",\
		\"weight\": 5676,\
		\"max\": \"*\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription\",\
		\"weight\": 5677,\
		\"max\": \"*\",\
		\"kind\": \"resource\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.id\",\
		\"weight\": 5678,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.meta\",\
		\"weight\": 5679,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.implicitRules\",\
		\"weight\": 5680,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.language\",\
		\"weight\": 5681,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.text\",\
		\"weight\": 5682,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.contained\",\
		\"weight\": 5683,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.extension\",\
		\"weight\": 5684,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.modifierExtension\",\
		\"weight\": 5685,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.identifier\",\
		\"weight\": 5686,\
		\"max\": \"*\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.status\",\
		\"weight\": 5687,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.patient\",\
		\"weight\": 5688,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.encounter\",\
		\"weight\": 5689,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dateWritten\",\
		\"weight\": 5690,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.prescriber\",\
		\"weight\": 5691,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.reasonCodeableConcept\",\
		\"weight\": 5692,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.reasonReference\",\
		\"weight\": 5692,\
		\"max\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense\",\
		\"weight\": 5693,\
		\"max\": \"*\",\
		\"type\": \"BackboneElement\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.id\",\
		\"weight\": 5694,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.extension\",\
		\"weight\": 5695,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.modifierExtension\",\
		\"weight\": 5696,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.product\",\
		\"weight\": 5697,\
		\"max\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.eye\",\
		\"weight\": 5698,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.sphere\",\
		\"weight\": 5699,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.cylinder\",\
		\"weight\": 5700,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.axis\",\
		\"weight\": 5701,\
		\"max\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.prism\",\
		\"weight\": 5702,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.base\",\
		\"weight\": 5703,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.add\",\
		\"weight\": 5704,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.power\",\
		\"weight\": 5705,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.backCurve\",\
		\"weight\": 5706,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.diameter\",\
		\"weight\": 5707,\
		\"max\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.duration\",\
		\"weight\": 5708,\
		\"max\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.color\",\
		\"weight\": 5709,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.brand\",\
		\"weight\": 5710,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"VisionPrescription.dispense.note\",\
		\"weight\": 5711,\
		\"max\": \"*\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MetadataResource\",\
		\"weight\": 5712,\
		\"max\": \"1\",\
		\"kind\": \"logical\",\
		\"type\": \"DomainResource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.id\",\
		\"weight\": 5713,\
		\"max\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.meta\",\
		\"weight\": 5714,\
		\"max\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.implicitRules\",\
		\"weight\": 5715,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.language\",\
		\"weight\": 5716,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.text\",\
		\"weight\": 5717,\
		\"max\": \"1\",\
		\"type\": \"Narrative\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.contained\",\
		\"weight\": 5718,\
		\"max\": \"*\",\
		\"type\": \"Resource\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.extension\",\
		\"weight\": 5719,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.modifierExtension\",\
		\"weight\": 5720,\
		\"max\": \"*\",\
		\"type\": \"Extension\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.url\",\
		\"weight\": 5721,\
		\"max\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.version\",\
		\"weight\": 5722,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.name\",\
		\"weight\": 5723,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.title\",\
		\"weight\": 5724,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 1,\
		\"path\": \"MetadataResource.status\",\
		\"weight\": 5725,\
		\"max\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.experimental\",\
		\"weight\": 5726,\
		\"max\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.date\",\
		\"weight\": 5727,\
		\"max\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.publisher\",\
		\"weight\": 5728,\
		\"max\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.contact\",\
		\"weight\": 5729,\
		\"max\": \"*\",\
		\"type\": \"ContactDetail\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.useContext\",\
		\"weight\": 5730,\
		\"max\": \"*\",\
		\"type\": \"UsageContext\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.jurisdiction\",\
		\"weight\": 5731,\
		\"max\": \"*\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"min\": 0,\
		\"path\": \"MetadataResource.description\",\
		\"weight\": 5732,\
		\"max\": \"1\",\
		\"type\": \"markdown\"\
	}\
]"function require_resource(t)return e[t]or error("resource '"..tostring(t).."' not found");end end
local e,x,t,h
if js and js.global then
h={}
h.dump=require("pure-xml-dump")
h.load=require("pure-xml-load")
t=require("lunajson")
package.loaded["cjson.safe"]={encode=function()end}
else
h=require("xml")
e=require("cjson")
x=require("datafile")
end
local U=require("resty.prettycjson")
local f,z,n,s,R,L,d,u,D,a
=ipairs,pairs,type,print,tonumber,string.gmatch,table.remove,string.format,table.sort,table.concat
local r,w,H,m,c
local S,N,b,O
local T,A,g,q,k
local v,j,_
local E,y,I
local o
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
A=function(e)
local e=io.open(e,"r")
if e~=nil then io.close(e)return true else return false end
end
local C=(...and(...):match("(.+)%.[^%.]+$")or(...))or"(path of the script unknown)"
w=function(e)
local n={(e or""),"fhir-data/fhir-elements.json","src/fhir-data/fhir-elements.json","../src/fhir-data/fhir-elements.json","fhir-data/fhir-elements.json"}
local e
for a,t in f(n)do
if A(t)then
io.input(t)
e=l(io.read("*a"))
break
end
end
local t,o,i
if not e and x then
i=true
t,o=x.open("src/fhir-data/fhir-elements.json","r")
if t then e=l(t:read("*a"))end
end
if not e and require_resource then
e=l(require_resource("fhir-data/fhir-elements.json"))
end
assert(e,string.format("read_fhir_data: FHIR Schema could not be found in these locations starting from %s:  %s\n\n%s%s",C,a(n,"\n  "),i and("Datafile could not find LuaRocks installation as well; error is: \n"..o)or'',require_resource and"Embedded JSON data could not be found as well."or''))
return e
end
H=function(e,a)
if not e then return nil end
for t=1,#e do
if e[t]==a then return t end
end
end
I=function(e,t)
if not e then return nil end
local a={}
if n(t)=="function"then
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
slice=function(o,a,t)
local e={}
for t=(a and a or 1),(t and t or#o)do
e[t]=o[t]
end
return e
end
m=function(a)
o={}
local s,i
i=function(t)
local e=o
for t in L(t.path,"([^%.]+)")do
e[t]=e[t]or{}
e=e[t]
end
e._min=t.min
e._max=t.max
e._type=t.type
e._type_json=t.type_json
e._weight=t.weight
e._kind=t.kind
e._derivations=I(t.derivations,function(e)return o[e]end)
s(e)
if n(o[t.type])=="table"then
e[1]=o[t.type]
end
end
s=function(e,t)
if not(e and e._derivations)then return end
local t=t and t._derivations or e._derivations
for a,t in z(t)do
if t._derivations then
for a,t in z(t._derivations)do
if e~=t then
e._derivations[a]=t
end
end
end
end
end
for e=1,#a do
local e=a[e]
i(e)
end
for e=1,#a do
local e=a[e]
i(e)
end
for e=1,#a do
local e=a[e]
i(e)
end
return o
end
g=function(e,t)
return t(e)
end
q=function(e,t)
io.input(e)
local e=io.read("*a")
io.input():close()
return t(e)
end
c=function(o,e)
local i=e.value
local t=r(o,e.xml)
if not t then
s(string.format("Warning: %s is not a known FHIR element; couldn't check its FHIR type to decide the JSON type.",a(o,".")))
return i
end
local t=t._type or t._type_json
if t=="boolean"then
if e.value=="true"then return true
elseif e.value=="false"then return false
else
s(string.format("Warning: %s.%s is of type %s in FHIR JSON - its XML value of %s is invalid.",a(o),e.xml,t,e.value))
end
elseif t=="integer"or
t=="unsignedInt"or
t=="positiveInt"or
t=="decimal"then
return R(e.value)
else return i end
end
r=function(t,a)
local e
for i=1,#t+1 do
local t=(t[i]or a)
if not e then
e=o[t]
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
get_fhir_definition_public=function(...)
local e={...}
local t=e[#e]
e[#e]=nil
local e=r(e,t)
if not e then
return nil,string.format("No element %s found",a({...},'.'))
else
return e
end
end
k=function(i,n)
local e,t
local o=r(i,n)
if not o then
s(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.",a(i,"."),n))
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
S=function(o,t)
local e=r(o,t)
if e==nil then
s(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.",a(o,"."),t))
end
if e and e._max=="*"then
return"array"
end
return"object"
end
get_xml_weight=function(t,e)
local o=r(t,e)
if not o then
s(string.format("Warning: %s.%s is not a known FHIR element; won't be able to sort it properly in the XML output.",a(t,"."),e))
return 0
else
return o._weight
end
end
get_datatype_kind=function(e,t)
local o=r(e,t)
if not o then
s(string.format("Warning: %s.%s is not a known FHIR element; might not convert it to a proper JSON 'element' or '_element' representation.",a(e,"."),t))
return 0
else
local e=r({},o._type)
return e._kind
end
end
print_xml_value=function(e,a,o,n)
if not a[e.xml]then
local t
if S(o,e.xml)=="array"then
t={}
local a=a["_"..e.xml]
if a then
for e=1,#a do
t[#t+1]=i
end
end
t[#t+1]=c(o,e)
else
t=c(o,e)
end
a[e.xml]=t
else
local t=a[e.xml]
t[#t+1]=c(o,e)
local e=a["_"..e.xml]
if e and not n then
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
N=function(e,a,l,o,h)
assert(e.xml,"error from parsed xml: node.xml is missing")
local s=a-1
local d=need_shadow_element(a,e,h)
local t
if a~=1 then
t=o[s][#o[s]]
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
if n(e[1])=="table"and a~=1 then
local s,r
if n(t[e.xml])=="table"and not d then
local e=t[e.xml]
e[#e+1]={}
r=e[#e]
elseif not t[e.xml]and(e[1]or e.value)and not d then
s,r=k(h,e.xml)
t[e.xml]=s
end
if d then
s,r=k(h,e.xml)
local a=u('_%s',e.xml)
local o
if not t[a]then
t[a]=s
o=true
else
t[a][#t[a]+1]=r
end
local a=H(t[e.xml],e.value)
if o and a and a>1 then
s[1]=nil
for e=1,a-1 do
s[#s+1]=i
end
s[#s+1]={}
r=s[#s]
end
if not e.value and t[e.xml]then
if n(t[e.xml][#t[e.xml]])=="table"then
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
O=function(t,e,a)
t[a][#t[a]][e.xml]=h.dump(e)
end
b=function(e,t,o,i,a)
t=(t and(t+1)or 1)
o=N(e,t,o,i,a)
a[#a+1]=e.xml
for s,e in f(e)do
if e.xml=="div"and e.xmlns=="http://www.w3.org/1999/xhtml"then
O(i,e,t)
else
assert(n(e)=="table",u("unexpected type value encountered: %s (%s), expecting table",tostring(e),n(e)))
b(e,t,o,i,a)
end
end
d(a)
return o
end
local a=setmetatable({},{__mode="k"})
function read_only(e)
if n(e)=="table"then
local t=a[e]
if not t then
t=setmetatable({},{
__index=function(a,t)
return readOnly(e[t])
end,
__newindex=function()
error("table is readonly",2)
end,
})
a[e]=t
end
return t
else
return e
end
end
T=function(a,e)
o=o or m(w())
assert(next(o),"convert_to_json: FHIR Schema could not be parsed in.")
read_only(o)
local t
if e and e.file then
t=q(a,h.load)
else
t=g(a,h.load)
end
local a={}
local o={[1]={a}}
local i={}
local t=b(t,nil,a,o,i)
return(e and e.pretty)and U(t,nil,'  ',nil,p)
or p(t)
end
j=function(a,o,n,t,s)
if a:find("_",1,true)then return end
local e=n[#n]
if a=="div"then
e[#e+1]=h.load(o)
elseif a=="url"and(t[#t]=="extension"or t[#t]=="modifierExtension")then
e.url=o
elseif a=="id"then
local t=r(slice(t,1,#t-1),t[#t])._type
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
v(s,n,t)
d(n)
d(t)
end
end
y=function(i,n,e,t)
if i:find("_",1,true)then return end
local a=e[#e]
a[#a+1]={xml=i}
local o=a[#a]
o._weight=get_xml_weight(t,i)
o._count=#a
e[#e+1]=o
t[#t+1]=o.xml
v(n,e,t)
d(e)
d(t)
end
print_contained_resource=function(o,t,a)
local e=t[#t]
e[#e+1]={xml=o.resourceType,xmlns="http://hl7.org/fhir"}
t[#t+1]=e[#e]
a[#a+1]=e[#e].xml
o.resourceType=nil
end
v=function(s,a,o)
local h
if s.resourceType then
print_contained_resource(s,a,o)
h=true
end
for t,e in z(s)do
if n(e)=="table"then
if n(e[1])=="table"then
for n,e in f(e)do
if e~=i then
y(t,e,a,o)
end
end
elseif e[1]and n(e[1])~="table"then
for h,r in f(e)do
local n,e=s[u("_%s",t)]
if n then
e=n[h]
if e==i then e=nil end
end
j(t,r,a,o,e)
end
elseif e~=i then
y(t,e,a,o)
end
elseif e~=i then
j(t,e,a,o,s[u("_%s",t)])
end
if t:sub(1,1)=='_'and not s[t:sub(2)]then
y(t:sub(2),e,a,o)
end
end
local e=a[#a]
D(e,function(t,e)
return(t.xml==e.xml)and(t._count<e._count)or(t._weight<e._weight)
end)
for t=1,#e do
local e=e[t]
e._weight=nil
e._count=nil
end
if h then
d(a)
d(o)
end
end
_=function(e,t,o,a)
if e.resourceType then
t.xmlns="http://hl7.org/fhir"
t.xml=e.resourceType
e.resourceType=nil
a[#a+1]=t.xml
end
return v(e,o,a)
end
E=function(a,e)
o=o or m(w())
assert(next(o),"convert_to_xml: FHIR Schema could not be parsed in.")
read_only(o)
local t
if e and e.file then
t=q(a,l)
else
t=g(a,l)
end
local e,o={},{}
local a={e}
_(t,e,a,o)
return h.dump(e)
end
m(w())
read_only(o)
return{
to_json=T,
to_xml=E,
get_fhir_definition=get_fhir_definition_public
}
