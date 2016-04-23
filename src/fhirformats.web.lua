package.preload['lunajson._str_lib']=(function(...)
local e=math.huge
local l,s,u=string.byte,string.char,string.sub
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
local function m(d,i)
local n
if d=='u'then
local c,d,l,h=l(i,1,4)
local t=t[c-47]*4096+t[d-47]*256+t[l-47]*16+t[h-47]
if t==e then
r("invalid unicode charcode")
end
i=u(i,5)
if t<128 then
n=s(t)
elseif t<2048 then
n=s(192+o(t*.015625),128+t%64)
elseif t<55296 or 57344<=t then
n=s(224+o(t*.000244140625),128+o(t*.015625)%64,128+t%64)
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
n=s(240+o(t*3814697265625e-18),128+o(t*.000244140625)%64,128+o(t*.015625)%64,128+t%64)
end
end
end
if a~=0 then
r("invalid surrogate pair")
end
return(n or h[d])..i
end
local function e()
return a==0
end
return{
subst=m,
surrogateok=e
}
end
end)
package.preload['lunajson.decoder']=(function(...)
local v=error
local n,e,h,p,l,u=string.byte,string.char,string.find,string.gsub,string.match,string.sub
local r=tonumber
local s,b=tostring,setmetatable
local m
if _VERSION=="Lua 5.3"then
m=require'lunajson._str_lib_lua53'
else
m=require'lunajson._str_lib'
end
local e=nil
local function q()
local a,t,w,f
local d,o
local function i(e)
v("parse error at "..t..": "..e)
end
local function e()
i('invalid value')
end
local function q()
if u(a,t,t+2)=='ull'then
t=t+3
return w
end
i('invalid value')
end
local function x()
if u(a,t,t+3)=='alse'then
t=t+4
return false
end
i('invalid value')
end
local function j()
if u(a,t,t+2)=='rue'then
t=t+3
return true
end
i('invalid value')
end
local s=l(s(.5),'[^0-9]')
local c=r
if s~='.'then
if h(s,'%W')then
s='%'..s
end
c=function(e)
return r(p(e,'.',s))
end
end
local function s()
i('invalid number')
end
local function y(h)
local o=t
local e
local i=n(a,o)
if not i then
return s()
end
if i==46 then
e=l(a,'^.[0-9]*',t)
local e=#e
if e==1 then
return s()
end
o=t+e
i=n(a,o)
end
if i==69 or i==101 then
local a=l(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not a then
return s()
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
local e=l(a,'^.[0-9]*%.?[0-9]*',t)
if n(e,-1)==46 then
return s()
end
local o=t+#e
local i=n(a,o)
if i==69 or i==101 then
e=l(a,'^[^eE]*[eE][-+]?[0-9]+',t)
if not e then
return s()
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
local e=n(a,t)
if e then
t=t+1
if e>48 then
if e<58 then
return r(true)
end
else
if e>47 then
return y(true)
end
end
end
i('invalid number')
end
local s=m(i)
local g=s.surrogateok
local m=s.subst
local c=b({},{__mode="v"})
local function l(d)
local e=t-2
local o=t
local r,s
repeat
e=h(a,'"',o,true)
if not e then
i("unterminated string")
end
o=e+1
while true do
r,s=n(a,e-2,e-1)
if s~=92 or r~=92 then
break
end
e=e-2
end
until s~=92
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
e=p(e,'\\(.)([^\\]*)',m)
if not g()then
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
local s=0
if n(a,t)~=93 then
local e=t-1
repeat
s=s+1
o=d[n(a,e+1)]
t=e+2
r[s]=o()
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
r[0]=s
end
return r
end
local function c()
local r={}
o,t=h(a,'^[ \n\r\t]*',t)
t=t+1
if n(a,t)~=125 then
local s=t-1
repeat
t=s+1
if n(a,t)~=34 then
i("not key")
end
t=t+1
local l=l(true)
o=e
do
local a,e,i=n(a,t,t+3)
if a==58 then
s=t
if e==32 then
s=s+1
e=i
end
o=d[e]
end
end
if o==e then
o,s=h(a,'^[ \n\r\t]*:[ \n\r\t]*',t)
if not s then
i("no colon after a key")
end
end
o=d[n(a,s+1)]
t=s+2
r[l]=o()
o,s=h(a,'^[ \n\r\t]*,[ \n\r\t]*',t)
until not s
o,s=h(a,'^[ \n\r\t]*}',t)
if not s then
i("no closing bracket of an object")
end
t=s
end
t=t+1
return r
end
d={
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,l,e,e,e,e,e,e,e,e,e,e,k,e,e,
y,r,r,r,r,r,r,r,r,r,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,u,e,e,e,e,
e,e,e,e,e,e,x,e,e,e,e,e,e,e,q,e,
e,e,e,e,j,e,e,e,e,e,e,c,e,e,e,e,
}
d[0]=e
d.__index=function()
i("unexpected termination")
end
b(d,d)
local function s(e,i,r,s)
a,t,w,f=e,i,r,s
t=t or 1
o,t=h(a,'^[ \n\r\t]*',t)
t=t+1
o=d[n(a,t)]
t=t+1
local e=o()
if i then
return e,t
else
o,t=h(a,'^[ \n\r\t]*',t)
if t~=#a then
v('json ended')
end
return e
end
end
return s
end
return q
end)
package.preload['lunajson.encoder']=(function(...)
local h=error
local g,l,w,d,i=string.byte,string.find,string.format,string.gsub,string.match
local b=table.concat
local o=tostring
local k,r=pairs,type
local f=setmetatable
local q,y=1/0,-1/0
local s
if _VERSION=="Lua 5.1"then
s='[^ -!#-[%]^-\255]'
else
s='[\0-\31"\\]'
end
local e=nil
local function v()
local m,u
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
local c
if a or o then
c=true
if a and l(a,'%W')then
a='%'..a
end
if o and l(o,'%W')then
o='%'..o
end
end
local y=function(i)
if y<i and i<q then
local i=w("%.17g",i)
if c then
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
return w('\\u00%02X',g(e))
end
}
f(o,o)
local function c(a)
t[e]='"'
if l(a,s)then
a=d(a,s,o)
end
t[e+1]=a
t[e+2]='"'
e=e+3
end
local function s(a)
if n[a]then
h("loop detected")
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
for a,o in k(a)do
if r(a)~='string'then
h("non-string key")
end
c(a)
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
local a={
boolean=p,
number=y,
string=c,
table=s,
__index=function()
h("invalid type value")
end
}
f(a,a)
function i(o)
if o==u then
t[e]='null'
e=e+1
return
end
return a[r(o)](o)
end
local function o(o,a)
m,u=o,a
e,t,n=1,{},{}
i(m)
return b(t)
end
return o
end
return v
end)
package.preload['lunajson.sax']=(function(...)
local x=error
local i,S,l,g,m,u=string.byte,string.char,string.find,string.gsub,string.match,string.sub
local j=tonumber
local E,r,A=tostring,type,table.unpack or unpack
local b
if _VERSION=="Lua 5.3"then
b=require'lunajson._str_lib_lua53'
else
b=require'lunajson._str_lib'
end
local e=nil
local function e()end
local function q(h,n)
local a,d
local o,t,y=0,1,0
local f,s
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
local I=n.startobject or e
local O=n.key or e
local N=n.endobject or e
local _=n.startarray or e
local T=n.endarray or e
local z=n.string or e
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
x("parse error at "..y+t..": "..e)
end
local function k()
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
local function c(e,a,s,o)
for a=1,a do
local o=k()
if i(e,a)~=o then
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
local function D()
if u(a,t,t+3)=='alse'then
t=t+4
return r(false)
end
return c('alse',4,false,r)
end
local function R()
if u(a,t,t+2)=='rue'then
t=t+3
return r(true)
end
return c('rue',3,true,r)
end
local r=m(E(.5),'[^0-9]')
local w=j
if r~='.'then
if l(r,'%W')then
r='%'..r
end
w=function(e)
return j(g(e,'.',r))
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
local e=S(A(s))
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
e=m(a,'^.[0-9]*',t)
local e=#e
if e==1 then
t=t-1
return c(h)
end
n=t+e
s=i(a,n)
end
if s==69 or s==101 then
local a=m(a,'^[^eE]*[eE][-+]?[0-9]+',t)
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
local e=m(a,'^.[0-9]*%.?[0-9]*',t)
if i(e,-1)==46 then
return c(s)
end
local n=t+#e
local i=i(a,n)
if i==69 or i==101 then
e=m(a,'^[^eE]*[eE][-+]?[0-9]+',t)
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
local e=i(a,t)or k()
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
e=g(e,'\\(.)([^\\]*)',m)
if not w()then
n("invalid surrogate pair")
end
end
if c then
return O(e)
end
return z(e)
end
local function w()
_()
h()
if i(a,t)~=93 then
local e
while true do
s=f[i(a,t)]
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
return T()
end
local function m()
I()
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
s=f[i(a,t)]
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
return N()
end
f={
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,c,e,e,e,e,e,e,e,e,e,e,p,e,e,
q,r,r,r,r,r,r,r,r,r,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,
e,e,e,e,e,e,e,e,e,e,e,w,e,e,e,e,
e,e,e,e,e,e,D,e,e,e,e,e,e,e,H,e,
e,e,e,e,R,e,e,e,e,e,e,m,e,e,e,e,
}
f[0]=e
local function r()
h()
s=f[i(a,t)]
t=t+1
s()
end
local function n(e)
if e<0 then
x("the argument must be non-negative")
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
run=r,
tryc=v,
read=n,
tellpos=e,
}
end
local function i(e,a)
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
return q(o,a)
end
return{
newparser=q,
newfileparser=i
}
end)
package.preload['lunajson']=(function(...)
local t=require'lunajson.decoder'
local a=require'lunajson.encoder'
local e=require'lunajson.sax'
return{
decode=t(),
encode=a(),
newparser=e.newparser,
newfileparser=e.newfileparser,
}
end)
package.preload['slaxml']=(function(...)
local m={
VERSION="0.7",
_call={
pi=function(e,t)
print(string.format("<?%s %s?>",e,t))
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
function m:parser(e)
return{_call=e or self._call,parse=m.parse}
end
function m:parse(s,w)
if not w then w={stripWhitespace=false}end
local h,q,p,c,j,g,x=string.find,string.sub,string.gsub,string.char,table.insert,table.remove,table.concat
local e,a,o,i,t,v,m
local y=unpack or table.unpack
local t=1
local f="text"
local d=1
local r={}
local l={}
local u
local n={}
local k=false
local z={{2047,192},{65535,224},{2097151,240}}
local function b(e)
if e<128 then return c(e)end
local t={}
for a,o in ipairs(z)do
if e<=o[1]then
for o=a+1,2,-1 do
local a=e%64
e=(e-a)/64
t[o]=c(128+a)
end
t[1]=c(o[2]+e)
return x(t)
end
end
end
local c={["lt"]="<",["gt"]=">",["amp"]="&",["quot"]='"',["apos"]="'"}
local c=function(a,t,e)return c[e]or t=="#"and b(tonumber('0'..e))or a end
local function b(e)return p(e,'(&(#?)([%d%a]+);)',c)end
local function c()
if e>d and self._call.text then
local e=q(s,d,e-1)
if w.stripWhitespace then
e=p(e,'^%s+','')
e=p(e,'%s+$','')
if#e==0 then e=nil end
end
if e then self._call.text(b(e))end
end
end
local function z()
e,a,o,i=h(s,'^<%?([:%a_][:%w_.-]*) ?(.-)%?>',t)
if e then
c()
if self._call.pi then self._call.pi(o,i)end
t=a+1
d=t
return true
end
end
local function q()
e,a,o=h(s,'^<!%-%-(.-)%-%->',t)
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
k=true
e,a,o=h(s,'^<([%a_][%w_.-]*)',t)
if e then
r[2]=nil
r[3]=nil
c()
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
u=0
j(n,{})
return true
end
end
local function j()
e,a,o=h(s,'^%s+([:%a_][:%w_.-]*)%s*=%s*',t)
if e then
v=a+1
e,a,i=h(s,'^"([^<"]*)"',v)
if e then
t=a+1
i=b(i)
else
e,a,i=h(s,"^'([^<']*)'",v)
if e then
t=a+1
i=b(i)
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
u=u+1
l[u]=e
return true
end
end
local function p()
e,a,o=h(s,'^<!%[CDATA%[(.-)%]%]>',t)
if e then
c()
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
if self._call.startElement then self._call.startElement(y(r))end
if self._call.attribute then
for e=1,u do
if l[e][4]then l[e][3]=w(l[e][4])end
self._call.attribute(y(l[e]))
end
end
if o=="/"then
g(n)
if self._call.closeElement then self._call.closeElement(y(r))end
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
c()
if self._call.closeElement then self._call.closeElement(o,m)end
t=a+1
d=t
g(n)
return true
end
end
while t<#s do
if f=="text"then
if not(z()or q()or p()or r())then
if x()then
f="attributes"
else
e,a=h(s,'^[^<]+',t)
t=(e and a or t)+1
end
end
elseif f=="attributes"then
if not j()then
if not v()then
error("Was in an element and couldn't find attributes or the close.")
end
end
end
end
if not k then error("Parsing did not discover any elements")end
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
local function l(t)
local e=t.xml or'table'
for t,a in a(t)do
if t~='xml'and n(t)=='string'then
e=e..' '..t.."='"..d(a).."'"
end
end
return e
end
local function r(a,i,t,e,h,s)
if h>s then
error(string.format("Could not dump table to XML. Maximal depth of %i reached.",s))
end
if a[1]then
o(t,(e=='n'and i or'')..'<'..l(a)..'>')
e='n'
local l=i..'  '
for i,a in u(a)do
local i=n(a)
if i=='table'then
r(a,l,t,e,h+1,s)
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
o(t,(e=='n'and i or'')..'<'..l(a)..'/>')
e='n'
end
end
local function a(a,e)
local t=e or 3e3
local e={}
r(a,'\n',e,'s',1,t)
return table.concat(e,'')
end
return a
end)
package.preload['pure-xml-load']=(function(...)
local s=require'slaxml'
local o={}
local e={o}
local t={}
local i=function(i,a,o)
local o=e[#e]
if a~=t[#t]then
t[#t+1]=a
else
a=nil
end
o[#o+1]={xml=i,xmlns=a}
e[#e+1]=o[#o]
end
local n=function(a,t)
local e=e[#e]
e[a]=t
end
local h=function(o,a)
table.remove(e)
if a~=t[#t]then
t[#t]=nil
end
end
local a=function(t)
local e=e[#e]
e[#e+1]=t
end
local n=s:parser{
startElement=i,
attribute=n,
closeElement=h,
text=a
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
local e=require"cjson.safe".encode
local i=table.concat
local m=string.sub
local d=string.rep
return function(t,r,n,l,a)
local t,e=(a or e)(t)
if not t then return t,e end
r,n,l=r or"\n",n or"\t",l or" "
local e,a,u,c,o,h,s=1,0,0,#t,{},nil,nil
local f=m(l,-1)=="\n"
for c=1,c do
local t=m(t,c,c)
if not s and(t=="{"or t=="[")then
o[e]=h==":"and i{t,r}or i{d(n,a),t,r}
a=a+1
elseif not s and(t=="}"or t=="]")then
a=a-1
if h=="{"or h=="["then
e=e-1
o[e]=i{d(n,a),h,t}
else
o[e]=i{r,d(n,a),t}
end
elseif not s and t==","then
o[e]=i{t,r}
u=-1
elseif not s and t==":"then
o[e]=i{t,l}
if f then
e=e+1
o[e]=d(n,a)
end
else
if t=='"'and h~="\\"then
s=not s and true or nil
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
		\"type_xml\": \"xs:gYear, xs:gYearMonth, xs:date\",\
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
		\"type_xml\": \"xs:gYear, xs:gYearMonth, xs:date, xs:dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"string\",\
		\"weight\": 9,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"string.id\",\
		\"weight\": 10,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"string.extension\",\
		\"weight\": 11,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"string.value\",\
		\"weight\": 12,\
		\"type_json\": \"string\",\
		\"type_xml\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"integer\",\
		\"weight\": 13,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"integer.id\",\
		\"weight\": 14,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"integer.extension\",\
		\"weight\": 15,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"integer.value\",\
		\"weight\": 16,\
		\"type_json\": \"number\",\
		\"type_xml\": \"int\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"uri\",\
		\"weight\": 17,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"uri.id\",\
		\"weight\": 18,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"uri.extension\",\
		\"weight\": 19,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"uri.value\",\
		\"weight\": 20,\
		\"type_json\": \"string\",\
		\"type_xml\": \"anyURI\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"instant\",\
		\"weight\": 21,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"instant.id\",\
		\"weight\": 22,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"instant.extension\",\
		\"weight\": 23,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"instant.value\",\
		\"weight\": 24,\
		\"type_json\": \"string\",\
		\"type_xml\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"boolean\",\
		\"weight\": 25,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"boolean.id\",\
		\"weight\": 26,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"boolean.extension\",\
		\"weight\": 27,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"boolean.value\",\
		\"weight\": 28,\
		\"type_json\": \"true | false\",\
		\"type_xml\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"base64Binary\",\
		\"weight\": 29,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"base64Binary.id\",\
		\"weight\": 30,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"base64Binary.extension\",\
		\"weight\": 31,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"base64Binary.value\",\
		\"weight\": 32,\
		\"type_json\": \"string\",\
		\"type_xml\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"time\",\
		\"weight\": 33,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"time.id\",\
		\"weight\": 34,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"time.extension\",\
		\"weight\": 35,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"time.value\",\
		\"weight\": 36,\
		\"type_json\": \"string\",\
		\"type_xml\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"decimal\",\
		\"weight\": 37,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"decimal.id\",\
		\"weight\": 38,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"decimal.extension\",\
		\"weight\": 39,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"decimal.value\",\
		\"weight\": 40,\
		\"type_json\": \"number\",\
		\"type_xml\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier\",\
		\"weight\": 41,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Identifier.id\",\
		\"weight\": 42,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.extension\",\
		\"weight\": 43,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Identifier.use\",\
		\"weight\": 44,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.type\",\
		\"weight\": 45,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.system\",\
		\"weight\": 46,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.value\",\
		\"weight\": 47,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.period\",\
		\"weight\": 48,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.assigner\",\
		\"weight\": 49,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding\",\
		\"weight\": 50,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coding.id\",\
		\"weight\": 51,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.extension\",\
		\"weight\": 52,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coding.system\",\
		\"weight\": 53,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.version\",\
		\"weight\": 54,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.code\",\
		\"weight\": 55,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.display\",\
		\"weight\": 56,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.userSelected\",\
		\"weight\": 57,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference\",\
		\"weight\": 58,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Reference.id\",\
		\"weight\": 59,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference.extension\",\
		\"weight\": 60,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Reference.reference\",\
		\"weight\": 61,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference.display\",\
		\"weight\": 62,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature\",\
		\"weight\": 63,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.id\",\
		\"weight\": 64,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.extension\",\
		\"weight\": 65,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.type\",\
		\"weight\": 66,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.when\",\
		\"weight\": 67,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoUri\",\
		\"weight\": 68,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 68,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 68,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 68,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 68,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"weight\": 68,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.contentType\",\
		\"weight\": 69,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.blob\",\
		\"weight\": 70,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData\",\
		\"weight\": 71,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SampledData.id\",\
		\"weight\": 72,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.extension\",\
		\"weight\": 73,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SampledData.origin\",\
		\"weight\": 74,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.period\",\
		\"weight\": 75,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.factor\",\
		\"weight\": 76,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.lowerLimit\",\
		\"weight\": 77,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.upperLimit\",\
		\"weight\": 78,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.dimensions\",\
		\"weight\": 79,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.data\",\
		\"weight\": 80,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity\",\
		\"weight\": 81,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Quantity.id\",\
		\"weight\": 82,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.extension\",\
		\"weight\": 83,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Quantity.value\",\
		\"weight\": 84,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.comparator\",\
		\"weight\": 85,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.unit\",\
		\"weight\": 86,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.system\",\
		\"weight\": 87,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.code\",\
		\"weight\": 88,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period\",\
		\"weight\": 89,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Period.id\",\
		\"weight\": 90,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period.extension\",\
		\"weight\": 91,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Period.start\",\
		\"weight\": 92,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period.end\",\
		\"weight\": 93,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment\",\
		\"weight\": 94,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Attachment.id\",\
		\"weight\": 95,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.extension\",\
		\"weight\": 96,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Attachment.contentType\",\
		\"weight\": 97,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.language\",\
		\"weight\": 98,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.data\",\
		\"weight\": 99,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.url\",\
		\"weight\": 100,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.size\",\
		\"weight\": 101,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.hash\",\
		\"weight\": 102,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.title\",\
		\"weight\": 103,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.creation\",\
		\"weight\": 104,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio\",\
		\"weight\": 105,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Ratio.id\",\
		\"weight\": 106,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio.extension\",\
		\"weight\": 107,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Ratio.numerator\",\
		\"weight\": 108,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio.denominator\",\
		\"weight\": 109,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range\",\
		\"weight\": 110,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Range.id\",\
		\"weight\": 111,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range.extension\",\
		\"weight\": 112,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Range.low\",\
		\"weight\": 113,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range.high\",\
		\"weight\": 114,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation\",\
		\"weight\": 115,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Annotation.id\",\
		\"weight\": 116,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.extension\",\
		\"weight\": 117,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 118,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 118,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"weight\": 118,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.authorString\",\
		\"weight\": 118,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.time\",\
		\"weight\": 119,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.text\",\
		\"weight\": 120,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeableConcept\",\
		\"weight\": 121,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.id\",\
		\"weight\": 122,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeableConcept.extension\",\
		\"weight\": 123,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.coding\",\
		\"weight\": 124,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.text\",\
		\"weight\": 125,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension\",\
		\"weight\": 126,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Extension.id\",\
		\"weight\": 127,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.extension\",\
		\"weight\": 128,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Extension.url\",\
		\"weight\": 129,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueBoolean\",\
		\"weight\": 130,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueInteger\",\
		\"weight\": 130,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueDecimal\",\
		\"weight\": 130,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueBase64Binary\",\
		\"weight\": 130,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueInstant\",\
		\"weight\": 130,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueString\",\
		\"weight\": 130,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueUri\",\
		\"weight\": 130,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueDate\",\
		\"weight\": 130,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueDateTime\",\
		\"weight\": 130,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueTime\",\
		\"weight\": 130,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueCode\",\
		\"weight\": 130,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueOid\",\
		\"weight\": 130,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueId\",\
		\"weight\": 130,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueUnsignedInt\",\
		\"weight\": 130,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valuePositiveInt\",\
		\"weight\": 130,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueMarkdown\",\
		\"weight\": 130,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueAnnotation\",\
		\"weight\": 130,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueAttachment\",\
		\"weight\": 130,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueIdentifier\",\
		\"weight\": 130,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueCodeableConcept\",\
		\"weight\": 130,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueCoding\",\
		\"weight\": 130,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueQuantity\",\
		\"weight\": 130,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueRange\",\
		\"weight\": 130,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valuePeriod\",\
		\"weight\": 130,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueRatio\",\
		\"weight\": 130,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueSampledData\",\
		\"weight\": 130,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueSignature\",\
		\"weight\": 130,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueHumanName\",\
		\"weight\": 130,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueAddress\",\
		\"weight\": 130,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueContactPoint\",\
		\"weight\": 130,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueTiming\",\
		\"weight\": 130,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueReference\",\
		\"weight\": 130,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueMeta\",\
		\"weight\": 130,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BackboneElement\",\
		\"weight\": 131,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BackboneElement.id\",\
		\"weight\": 132,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BackboneElement.extension\",\
		\"weight\": 133,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BackboneElement.modifierExtension\",\
		\"weight\": 134,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative\",\
		\"weight\": 135,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative.id\",\
		\"weight\": 136,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Narrative.extension\",\
		\"weight\": 137,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative.status\",\
		\"weight\": 138,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Narrative.div\",\
		\"weight\": 139,\
		\"type\": \"xhtml\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Element\",\
		\"weight\": 140,\
		\"derivations\": [\
			\"ActionDefinition\",\
			\"Address\",\
			\"Annotation\",\
			\"Attachment\",\
			\"BackboneElement\",\
			\"CodeableConcept\",\
			\"Coding\",\
			\"ContactPoint\",\
			\"DataRequirement\",\
			\"ElementDefinition\",\
			\"Extension\",\
			\"HumanName\",\
			\"Identifier\",\
			\"Meta\",\
			\"ModuleMetadata\",\
			\"Narrative\",\
			\"ParameterDefinition\",\
			\"Period\",\
			\"Quantity\",\
			\"Range\",\
			\"Ratio\",\
			\"Reference\",\
			\"SampledData\",\
			\"Signature\",\
			\"Timing\",\
			\"TriggerDefinition\",\
			\"base64Binary\",\
			\"boolean\",\
			\"date\",\
			\"dateTime\",\
			\"decimal\",\
			\"instant\",\
			\"integer\",\
			\"string\",\
			\"time\",\
			\"uri\"\
		],\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Element.id\",\
		\"weight\": 141,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Element.extension\",\
		\"weight\": 142,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName\",\
		\"weight\": 143,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.id\",\
		\"weight\": 144,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.extension\",\
		\"weight\": 145,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.use\",\
		\"weight\": 146,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.text\",\
		\"weight\": 147,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.family\",\
		\"weight\": 148,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.given\",\
		\"weight\": 149,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.prefix\",\
		\"weight\": 150,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.suffix\",\
		\"weight\": 151,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.period\",\
		\"weight\": 152,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint\",\
		\"weight\": 153,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ContactPoint.id\",\
		\"weight\": 154,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.extension\",\
		\"weight\": 155,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ContactPoint.system\",\
		\"weight\": 156,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.value\",\
		\"weight\": 157,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.use\",\
		\"weight\": 158,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.rank\",\
		\"weight\": 159,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.period\",\
		\"weight\": 160,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta\",\
		\"weight\": 161,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.id\",\
		\"weight\": 162,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.extension\",\
		\"weight\": 163,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.versionId\",\
		\"weight\": 164,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.lastUpdated\",\
		\"weight\": 165,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.profile\",\
		\"weight\": 166,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.security\",\
		\"weight\": 167,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.tag\",\
		\"weight\": 168,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address\",\
		\"weight\": 169,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.id\",\
		\"weight\": 170,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.extension\",\
		\"weight\": 171,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.use\",\
		\"weight\": 172,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.type\",\
		\"weight\": 173,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.text\",\
		\"weight\": 174,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.line\",\
		\"weight\": 175,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.city\",\
		\"weight\": 176,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.district\",\
		\"weight\": 177,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.state\",\
		\"weight\": 178,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.postalCode\",\
		\"weight\": 179,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.country\",\
		\"weight\": 180,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.period\",\
		\"weight\": 181,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition\",\
		\"weight\": 182,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TriggerDefinition.id\",\
		\"weight\": 183,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.extension\",\
		\"weight\": 184,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TriggerDefinition.type\",\
		\"weight\": 185,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventName\",\
		\"weight\": 186,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingTiming\",\
		\"weight\": 187,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingReference\",\
		\"weight\": 187,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingDate\",\
		\"weight\": 187,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingDateTime\",\
		\"weight\": 187,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventData\",\
		\"weight\": 188,\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata\",\
		\"weight\": 189,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.id\",\
		\"weight\": 190,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.extension\",\
		\"weight\": 191,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.url\",\
		\"weight\": 192,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.identifier\",\
		\"weight\": 193,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.version\",\
		\"weight\": 194,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.name\",\
		\"weight\": 195,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.title\",\
		\"weight\": 196,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.type\",\
		\"weight\": 197,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.status\",\
		\"weight\": 198,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.experimental\",\
		\"weight\": 199,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.description\",\
		\"weight\": 200,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.purpose\",\
		\"weight\": 201,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.usage\",\
		\"weight\": 202,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.publicationDate\",\
		\"weight\": 203,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.lastReviewDate\",\
		\"weight\": 204,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.effectivePeriod\",\
		\"weight\": 205,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage\",\
		\"weight\": 206,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage.id\",\
		\"weight\": 207,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage.extension\",\
		\"weight\": 208,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage.focus\",\
		\"weight\": 209,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage.value\",\
		\"weight\": 210,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.topic\",\
		\"weight\": 211,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor\",\
		\"weight\": 212,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.id\",\
		\"weight\": 213,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.extension\",\
		\"weight\": 214,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.type\",\
		\"weight\": 215,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.name\",\
		\"weight\": 216,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact\",\
		\"weight\": 217,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact.id\",\
		\"weight\": 218,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact.extension\",\
		\"weight\": 219,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact.name\",\
		\"weight\": 220,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact.telecom\",\
		\"weight\": 221,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.publisher\",\
		\"weight\": 222,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact\",\
		\"weight\": 223,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact.id\",\
		\"weight\": 224,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact.extension\",\
		\"weight\": 225,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact.name\",\
		\"weight\": 226,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact.telecom\",\
		\"weight\": 227,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.copyright\",\
		\"weight\": 228,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource\",\
		\"weight\": 229,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.id\",\
		\"weight\": 230,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.extension\",\
		\"weight\": 231,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.type\",\
		\"weight\": 232,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.document\",\
		\"weight\": 233,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.resource\",\
		\"weight\": 234,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing\",\
		\"weight\": 235,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.id\",\
		\"weight\": 236,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.extension\",\
		\"weight\": 237,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.event\",\
		\"weight\": 238,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.repeat\",\
		\"weight\": 239,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.id\",\
		\"weight\": 240,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.extension\",\
		\"weight\": 241,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsQuantity\",\
		\"weight\": 242,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsRange\",\
		\"weight\": 242,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsPeriod\",\
		\"weight\": 242,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.count\",\
		\"weight\": 243,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.countMax\",\
		\"weight\": 244,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.duration\",\
		\"weight\": 245,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.durationMax\",\
		\"weight\": 246,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.durationUnit\",\
		\"weight\": 247,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.frequency\",\
		\"weight\": 248,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.frequencyMax\",\
		\"weight\": 249,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.period\",\
		\"weight\": 250,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.periodMax\",\
		\"weight\": 251,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.periodUnit\",\
		\"weight\": 252,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.when\",\
		\"weight\": 253,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.offset\",\
		\"weight\": 254,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.code\",\
		\"weight\": 255,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition\",\
		\"weight\": 256,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.id\",\
		\"weight\": 257,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.extension\",\
		\"weight\": 258,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.path\",\
		\"weight\": 259,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.representation\",\
		\"weight\": 260,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.name\",\
		\"weight\": 261,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.label\",\
		\"weight\": 262,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.code\",\
		\"weight\": 263,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing\",\
		\"weight\": 264,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.id\",\
		\"weight\": 265,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.extension\",\
		\"weight\": 266,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.discriminator\",\
		\"weight\": 267,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.description\",\
		\"weight\": 268,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.ordered\",\
		\"weight\": 269,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.rules\",\
		\"weight\": 270,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.short\",\
		\"weight\": 271,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.definition\",\
		\"weight\": 272,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.comments\",\
		\"weight\": 273,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.requirements\",\
		\"weight\": 274,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.alias\",\
		\"weight\": 275,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.min\",\
		\"weight\": 276,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.max\",\
		\"weight\": 277,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base\",\
		\"weight\": 278,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.id\",\
		\"weight\": 279,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.extension\",\
		\"weight\": 280,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.path\",\
		\"weight\": 281,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.min\",\
		\"weight\": 282,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.max\",\
		\"weight\": 283,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.contentReference\",\
		\"weight\": 284,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type\",\
		\"weight\": 285,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.id\",\
		\"weight\": 286,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.extension\",\
		\"weight\": 287,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.code\",\
		\"weight\": 288,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.profile\",\
		\"weight\": 289,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.aggregation\",\
		\"weight\": 290,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.versioning\",\
		\"weight\": 291,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueBoolean\",\
		\"weight\": 292,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueInteger\",\
		\"weight\": 292,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDecimal\",\
		\"weight\": 292,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueBase64Binary\",\
		\"weight\": 292,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueInstant\",\
		\"weight\": 292,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueString\",\
		\"weight\": 292,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueUri\",\
		\"weight\": 292,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDate\",\
		\"weight\": 292,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDateTime\",\
		\"weight\": 292,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueTime\",\
		\"weight\": 292,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCode\",\
		\"weight\": 292,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueOid\",\
		\"weight\": 292,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueId\",\
		\"weight\": 292,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueUnsignedInt\",\
		\"weight\": 292,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValuePositiveInt\",\
		\"weight\": 292,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueMarkdown\",\
		\"weight\": 292,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAnnotation\",\
		\"weight\": 292,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAttachment\",\
		\"weight\": 292,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueIdentifier\",\
		\"weight\": 292,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCodeableConcept\",\
		\"weight\": 292,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCoding\",\
		\"weight\": 292,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueQuantity\",\
		\"weight\": 292,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueRange\",\
		\"weight\": 292,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValuePeriod\",\
		\"weight\": 292,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueRatio\",\
		\"weight\": 292,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueSampledData\",\
		\"weight\": 292,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueSignature\",\
		\"weight\": 292,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueHumanName\",\
		\"weight\": 292,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAddress\",\
		\"weight\": 292,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueContactPoint\",\
		\"weight\": 292,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueTiming\",\
		\"weight\": 292,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueReference\",\
		\"weight\": 292,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueMeta\",\
		\"weight\": 292,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.meaningWhenMissing\",\
		\"weight\": 293,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedBoolean\",\
		\"weight\": 294,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedInteger\",\
		\"weight\": 294,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDecimal\",\
		\"weight\": 294,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedBase64Binary\",\
		\"weight\": 294,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedInstant\",\
		\"weight\": 294,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedString\",\
		\"weight\": 294,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedUri\",\
		\"weight\": 294,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDate\",\
		\"weight\": 294,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDateTime\",\
		\"weight\": 294,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedTime\",\
		\"weight\": 294,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCode\",\
		\"weight\": 294,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedOid\",\
		\"weight\": 294,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedId\",\
		\"weight\": 294,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedUnsignedInt\",\
		\"weight\": 294,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedPositiveInt\",\
		\"weight\": 294,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedMarkdown\",\
		\"weight\": 294,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAnnotation\",\
		\"weight\": 294,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAttachment\",\
		\"weight\": 294,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedIdentifier\",\
		\"weight\": 294,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCodeableConcept\",\
		\"weight\": 294,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCoding\",\
		\"weight\": 294,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedQuantity\",\
		\"weight\": 294,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedRange\",\
		\"weight\": 294,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedPeriod\",\
		\"weight\": 294,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedRatio\",\
		\"weight\": 294,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedSampledData\",\
		\"weight\": 294,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedSignature\",\
		\"weight\": 294,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedHumanName\",\
		\"weight\": 294,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAddress\",\
		\"weight\": 294,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedContactPoint\",\
		\"weight\": 294,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedTiming\",\
		\"weight\": 294,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedReference\",\
		\"weight\": 294,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedMeta\",\
		\"weight\": 294,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternBoolean\",\
		\"weight\": 295,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternInteger\",\
		\"weight\": 295,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDecimal\",\
		\"weight\": 295,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternBase64Binary\",\
		\"weight\": 295,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternInstant\",\
		\"weight\": 295,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternString\",\
		\"weight\": 295,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternUri\",\
		\"weight\": 295,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDate\",\
		\"weight\": 295,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDateTime\",\
		\"weight\": 295,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternTime\",\
		\"weight\": 295,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCode\",\
		\"weight\": 295,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternOid\",\
		\"weight\": 295,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternId\",\
		\"weight\": 295,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternUnsignedInt\",\
		\"weight\": 295,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternPositiveInt\",\
		\"weight\": 295,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternMarkdown\",\
		\"weight\": 295,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAnnotation\",\
		\"weight\": 295,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAttachment\",\
		\"weight\": 295,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternIdentifier\",\
		\"weight\": 295,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCodeableConcept\",\
		\"weight\": 295,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCoding\",\
		\"weight\": 295,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternQuantity\",\
		\"weight\": 295,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternRange\",\
		\"weight\": 295,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternPeriod\",\
		\"weight\": 295,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternRatio\",\
		\"weight\": 295,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternSampledData\",\
		\"weight\": 295,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternSignature\",\
		\"weight\": 295,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternHumanName\",\
		\"weight\": 295,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAddress\",\
		\"weight\": 295,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternContactPoint\",\
		\"weight\": 295,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternTiming\",\
		\"weight\": 295,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternReference\",\
		\"weight\": 295,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternMeta\",\
		\"weight\": 295,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleBoolean\",\
		\"weight\": 296,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleInteger\",\
		\"weight\": 296,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDecimal\",\
		\"weight\": 296,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleBase64Binary\",\
		\"weight\": 296,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleInstant\",\
		\"weight\": 296,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleString\",\
		\"weight\": 296,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleUri\",\
		\"weight\": 296,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDate\",\
		\"weight\": 296,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDateTime\",\
		\"weight\": 296,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleTime\",\
		\"weight\": 296,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCode\",\
		\"weight\": 296,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleOid\",\
		\"weight\": 296,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleId\",\
		\"weight\": 296,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleUnsignedInt\",\
		\"weight\": 296,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.examplePositiveInt\",\
		\"weight\": 296,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleMarkdown\",\
		\"weight\": 296,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAnnotation\",\
		\"weight\": 296,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAttachment\",\
		\"weight\": 296,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleIdentifier\",\
		\"weight\": 296,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCodeableConcept\",\
		\"weight\": 296,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCoding\",\
		\"weight\": 296,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleQuantity\",\
		\"weight\": 296,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleRange\",\
		\"weight\": 296,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.examplePeriod\",\
		\"weight\": 296,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleRatio\",\
		\"weight\": 296,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleSampledData\",\
		\"weight\": 296,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleSignature\",\
		\"weight\": 296,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleHumanName\",\
		\"weight\": 296,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAddress\",\
		\"weight\": 296,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleContactPoint\",\
		\"weight\": 296,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleTiming\",\
		\"weight\": 296,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleReference\",\
		\"weight\": 296,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleMeta\",\
		\"weight\": 296,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueBoolean\",\
		\"weight\": 297,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueInteger\",\
		\"weight\": 297,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDecimal\",\
		\"weight\": 297,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueBase64Binary\",\
		\"weight\": 297,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueInstant\",\
		\"weight\": 297,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueString\",\
		\"weight\": 297,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueUri\",\
		\"weight\": 297,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDate\",\
		\"weight\": 297,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDateTime\",\
		\"weight\": 297,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueTime\",\
		\"weight\": 297,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueCode\",\
		\"weight\": 297,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueOid\",\
		\"weight\": 297,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueId\",\
		\"weight\": 297,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueUnsignedInt\",\
		\"weight\": 297,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValuePositiveInt\",\
		\"weight\": 297,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueMarkdown\",\
		\"weight\": 297,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueAnnotation\",\
		\"weight\": 297,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueAttachment\",\
		\"weight\": 297,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueIdentifier\",\
		\"weight\": 297,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueCodeableConcept\",\
		\"weight\": 297,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueCoding\",\
		\"weight\": 297,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueQuantity\",\
		\"weight\": 297,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueRange\",\
		\"weight\": 297,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValuePeriod\",\
		\"weight\": 297,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueRatio\",\
		\"weight\": 297,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueSampledData\",\
		\"weight\": 297,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueSignature\",\
		\"weight\": 297,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueHumanName\",\
		\"weight\": 297,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueAddress\",\
		\"weight\": 297,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueContactPoint\",\
		\"weight\": 297,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueTiming\",\
		\"weight\": 297,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueReference\",\
		\"weight\": 297,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueMeta\",\
		\"weight\": 297,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueBoolean\",\
		\"weight\": 298,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueInteger\",\
		\"weight\": 298,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDecimal\",\
		\"weight\": 298,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueBase64Binary\",\
		\"weight\": 298,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueInstant\",\
		\"weight\": 298,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueString\",\
		\"weight\": 298,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueUri\",\
		\"weight\": 298,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDate\",\
		\"weight\": 298,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDateTime\",\
		\"weight\": 298,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueTime\",\
		\"weight\": 298,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueCode\",\
		\"weight\": 298,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueOid\",\
		\"weight\": 298,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueId\",\
		\"weight\": 298,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueUnsignedInt\",\
		\"weight\": 298,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValuePositiveInt\",\
		\"weight\": 298,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueMarkdown\",\
		\"weight\": 298,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueAnnotation\",\
		\"weight\": 298,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueAttachment\",\
		\"weight\": 298,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueIdentifier\",\
		\"weight\": 298,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueCodeableConcept\",\
		\"weight\": 298,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueCoding\",\
		\"weight\": 298,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueQuantity\",\
		\"weight\": 298,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueRange\",\
		\"weight\": 298,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValuePeriod\",\
		\"weight\": 298,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueRatio\",\
		\"weight\": 298,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueSampledData\",\
		\"weight\": 298,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueSignature\",\
		\"weight\": 298,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueHumanName\",\
		\"weight\": 298,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueAddress\",\
		\"weight\": 298,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueContactPoint\",\
		\"weight\": 298,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueTiming\",\
		\"weight\": 298,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueReference\",\
		\"weight\": 298,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueMeta\",\
		\"weight\": 298,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxLength\",\
		\"weight\": 299,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.condition\",\
		\"weight\": 300,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint\",\
		\"weight\": 301,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.id\",\
		\"weight\": 302,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.extension\",\
		\"weight\": 303,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.key\",\
		\"weight\": 304,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.requirements\",\
		\"weight\": 305,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.severity\",\
		\"weight\": 306,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.human\",\
		\"weight\": 307,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.expression\",\
		\"weight\": 308,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.xpath\",\
		\"weight\": 309,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mustSupport\",\
		\"weight\": 310,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.isModifier\",\
		\"weight\": 311,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.isSummary\",\
		\"weight\": 312,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding\",\
		\"weight\": 313,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.id\",\
		\"weight\": 314,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.extension\",\
		\"weight\": 315,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.strength\",\
		\"weight\": 316,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.description\",\
		\"weight\": 317,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.valueSetUri\",\
		\"weight\": 318,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.valueSetReference\",\
		\"weight\": 318,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping\",\
		\"weight\": 319,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.id\",\
		\"weight\": 320,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.extension\",\
		\"weight\": 321,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.identity\",\
		\"weight\": 322,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.language\",\
		\"weight\": 323,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.map\",\
		\"weight\": 324,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement\",\
		\"weight\": 325,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.id\",\
		\"weight\": 326,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.extension\",\
		\"weight\": 327,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.type\",\
		\"weight\": 328,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.profile\",\
		\"weight\": 329,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.mustSupport\",\
		\"weight\": 330,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter\",\
		\"weight\": 331,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.id\",\
		\"weight\": 332,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.extension\",\
		\"weight\": 333,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.path\",\
		\"weight\": 334,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueSetString\",\
		\"weight\": 335,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueSetReference\",\
		\"weight\": 335,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCode\",\
		\"weight\": 336,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCoding\",\
		\"weight\": 337,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCodeableConcept\",\
		\"weight\": 338,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter\",\
		\"weight\": 339,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.id\",\
		\"weight\": 340,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.extension\",\
		\"weight\": 341,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.path\",\
		\"weight\": 342,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.valueDateTime\",\
		\"weight\": 343,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.valuePeriod\",\
		\"weight\": 343,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition\",\
		\"weight\": 344,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.id\",\
		\"weight\": 345,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.extension\",\
		\"weight\": 346,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.actionIdentifier\",\
		\"weight\": 347,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.label\",\
		\"weight\": 348,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.title\",\
		\"weight\": 349,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.description\",\
		\"weight\": 350,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.textEquivalent\",\
		\"weight\": 351,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.concept\",\
		\"weight\": 352,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.supportingEvidence\",\
		\"weight\": 353,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.documentation\",\
		\"weight\": 354,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction\",\
		\"weight\": 355,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.id\",\
		\"weight\": 356,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.extension\",\
		\"weight\": 357,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.actionIdentifier\",\
		\"weight\": 358,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.relationship\",\
		\"weight\": 359,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.offsetQuantity\",\
		\"weight\": 360,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.offsetRange\",\
		\"weight\": 360,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.anchor\",\
		\"weight\": 361,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.participantType\",\
		\"weight\": 362,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.type\",\
		\"weight\": 363,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior\",\
		\"weight\": 364,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior.id\",\
		\"weight\": 365,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior.extension\",\
		\"weight\": 366,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior.type\",\
		\"weight\": 367,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior.value\",\
		\"weight\": 368,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.resource\",\
		\"weight\": 369,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization\",\
		\"weight\": 370,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization.id\",\
		\"weight\": 371,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization.extension\",\
		\"weight\": 372,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization.path\",\
		\"weight\": 373,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization.expression\",\
		\"weight\": 374,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.action\",\
		\"weight\": 375,\
		\"type\": \"ActionDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ParameterDefinition\",\
		\"weight\": 376,\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ParameterDefinition.id\",\
		\"weight\": 377,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.extension\",\
		\"weight\": 378,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ParameterDefinition.name\",\
		\"weight\": 379,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.use\",\
		\"weight\": 380,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.min\",\
		\"weight\": 381,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.max\",\
		\"weight\": 382,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.documentation\",\
		\"weight\": 383,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.type\",\
		\"weight\": 384,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.profile\",\
		\"weight\": 385,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem\",\
		\"weight\": 386,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.id\",\
		\"weight\": 387,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.meta\",\
		\"weight\": 388,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.implicitRules\",\
		\"weight\": 389,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.language\",\
		\"weight\": 390,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.text\",\
		\"weight\": 391,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contained\",\
		\"weight\": 392,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.extension\",\
		\"weight\": 393,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.modifierExtension\",\
		\"weight\": 394,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.url\",\
		\"weight\": 395,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.identifier\",\
		\"weight\": 396,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.version\",\
		\"weight\": 397,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.name\",\
		\"weight\": 398,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.status\",\
		\"weight\": 399,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.experimental\",\
		\"weight\": 400,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.publisher\",\
		\"weight\": 401,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact\",\
		\"weight\": 402,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.id\",\
		\"weight\": 403,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.extension\",\
		\"weight\": 404,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.modifierExtension\",\
		\"weight\": 405,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.name\",\
		\"weight\": 406,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.telecom\",\
		\"weight\": 407,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.date\",\
		\"weight\": 408,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.description\",\
		\"weight\": 409,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.useContext\",\
		\"weight\": 410,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.requirements\",\
		\"weight\": 411,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.copyright\",\
		\"weight\": 412,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.caseSensitive\",\
		\"weight\": 413,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.valueSet\",\
		\"weight\": 414,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.compositional\",\
		\"weight\": 415,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.versionNeeded\",\
		\"weight\": 416,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.content\",\
		\"weight\": 417,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.count\",\
		\"weight\": 418,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter\",\
		\"weight\": 419,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.id\",\
		\"weight\": 420,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.extension\",\
		\"weight\": 421,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.modifierExtension\",\
		\"weight\": 422,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.code\",\
		\"weight\": 423,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.description\",\
		\"weight\": 424,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.operator\",\
		\"weight\": 425,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.value\",\
		\"weight\": 426,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property\",\
		\"weight\": 427,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.id\",\
		\"weight\": 428,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.extension\",\
		\"weight\": 429,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.modifierExtension\",\
		\"weight\": 430,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.code\",\
		\"weight\": 431,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.description\",\
		\"weight\": 432,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.type\",\
		\"weight\": 433,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept\",\
		\"weight\": 434,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.id\",\
		\"weight\": 435,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.extension\",\
		\"weight\": 436,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.modifierExtension\",\
		\"weight\": 437,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.code\",\
		\"weight\": 438,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.display\",\
		\"weight\": 439,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.definition\",\
		\"weight\": 440,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation\",\
		\"weight\": 441,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.id\",\
		\"weight\": 442,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.extension\",\
		\"weight\": 443,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.modifierExtension\",\
		\"weight\": 444,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.language\",\
		\"weight\": 445,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.use\",\
		\"weight\": 446,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.value\",\
		\"weight\": 447,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property\",\
		\"weight\": 448,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.id\",\
		\"weight\": 449,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.extension\",\
		\"weight\": 450,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.modifierExtension\",\
		\"weight\": 451,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.code\",\
		\"weight\": 452,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueCode\",\
		\"weight\": 453,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueCoding\",\
		\"weight\": 453,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueString\",\
		\"weight\": 453,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueInteger\",\
		\"weight\": 453,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueBoolean\",\
		\"weight\": 453,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueDateTime\",\
		\"weight\": 453,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.concept\",\
		\"weight\": 454,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet\",\
		\"weight\": 455,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.id\",\
		\"weight\": 456,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.meta\",\
		\"weight\": 457,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.implicitRules\",\
		\"weight\": 458,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.language\",\
		\"weight\": 459,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.text\",\
		\"weight\": 460,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contained\",\
		\"weight\": 461,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.extension\",\
		\"weight\": 462,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.modifierExtension\",\
		\"weight\": 463,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.url\",\
		\"weight\": 464,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.identifier\",\
		\"weight\": 465,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.version\",\
		\"weight\": 466,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.name\",\
		\"weight\": 467,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.status\",\
		\"weight\": 468,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.experimental\",\
		\"weight\": 469,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.publisher\",\
		\"weight\": 470,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact\",\
		\"weight\": 471,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.id\",\
		\"weight\": 472,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact.extension\",\
		\"weight\": 473,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.modifierExtension\",\
		\"weight\": 474,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.name\",\
		\"weight\": 475,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact.telecom\",\
		\"weight\": 476,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.date\",\
		\"weight\": 477,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.lockedDate\",\
		\"weight\": 478,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.description\",\
		\"weight\": 479,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.useContext\",\
		\"weight\": 480,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.immutable\",\
		\"weight\": 481,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.requirements\",\
		\"weight\": 482,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.copyright\",\
		\"weight\": 483,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.extensible\",\
		\"weight\": 484,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose\",\
		\"weight\": 485,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.id\",\
		\"weight\": 486,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.extension\",\
		\"weight\": 487,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.modifierExtension\",\
		\"weight\": 488,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.import\",\
		\"weight\": 489,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include\",\
		\"weight\": 490,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.id\",\
		\"weight\": 491,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.extension\",\
		\"weight\": 492,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.modifierExtension\",\
		\"weight\": 493,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.system\",\
		\"weight\": 494,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.version\",\
		\"weight\": 495,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept\",\
		\"weight\": 496,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.id\",\
		\"weight\": 497,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.extension\",\
		\"weight\": 498,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.modifierExtension\",\
		\"weight\": 499,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.code\",\
		\"weight\": 500,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.display\",\
		\"weight\": 501,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation\",\
		\"weight\": 502,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.id\",\
		\"weight\": 503,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.extension\",\
		\"weight\": 504,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.modifierExtension\",\
		\"weight\": 505,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.language\",\
		\"weight\": 506,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.use\",\
		\"weight\": 507,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.value\",\
		\"weight\": 508,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter\",\
		\"weight\": 509,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.id\",\
		\"weight\": 510,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.extension\",\
		\"weight\": 511,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.modifierExtension\",\
		\"weight\": 512,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.property\",\
		\"weight\": 513,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.op\",\
		\"weight\": 514,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.value\",\
		\"weight\": 515,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.exclude\",\
		\"weight\": 516,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion\",\
		\"weight\": 517,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.id\",\
		\"weight\": 518,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.extension\",\
		\"weight\": 519,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.modifierExtension\",\
		\"weight\": 520,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.identifier\",\
		\"weight\": 521,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.timestamp\",\
		\"weight\": 522,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.total\",\
		\"weight\": 523,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.offset\",\
		\"weight\": 524,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter\",\
		\"weight\": 525,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.id\",\
		\"weight\": 526,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.extension\",\
		\"weight\": 527,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.modifierExtension\",\
		\"weight\": 528,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.name\",\
		\"weight\": 529,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueString\",\
		\"weight\": 530,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueBoolean\",\
		\"weight\": 530,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueInteger\",\
		\"weight\": 530,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueDecimal\",\
		\"weight\": 530,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueUri\",\
		\"weight\": 530,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueCode\",\
		\"weight\": 530,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains\",\
		\"weight\": 531,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.id\",\
		\"weight\": 532,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.extension\",\
		\"weight\": 533,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.modifierExtension\",\
		\"weight\": 534,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.system\",\
		\"weight\": 535,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.abstract\",\
		\"weight\": 536,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.version\",\
		\"weight\": 537,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.code\",\
		\"weight\": 538,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.display\",\
		\"weight\": 539,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.contains\",\
		\"weight\": 540,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource\",\
		\"weight\": 541,\
		\"derivations\": [\
			\"Account\",\
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
			\"Contract\",\
			\"Coverage\",\
			\"DataElement\",\
			\"DecisionSupportRule\",\
			\"DecisionSupportServiceModule\",\
			\"DetectedIssue\",\
			\"Device\",\
			\"DeviceComponent\",\
			\"DeviceMetric\",\
			\"DeviceUseRequest\",\
			\"DeviceUseStatement\",\
			\"DiagnosticOrder\",\
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
			\"Group\",\
			\"GuidanceResponse\",\
			\"HealthcareService\",\
			\"ImagingExcerpt\",\
			\"ImagingObjectSelection\",\
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
			\"ModuleDefinition\",\
			\"NamingSystem\",\
			\"NutritionOrder\",\
			\"Observation\",\
			\"OperationDefinition\",\
			\"OperationOutcome\",\
			\"Order\",\
			\"OrderResponse\",\
			\"OrderSet\",\
			\"Organization\",\
			\"Patient\",\
			\"PaymentNotice\",\
			\"PaymentReconciliation\",\
			\"Person\",\
			\"Practitioner\",\
			\"PractitionerRole\",\
			\"Procedure\",\
			\"ProcedureRequest\",\
			\"ProcessRequest\",\
			\"ProcessResponse\",\
			\"Protocol\",\
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
		\"weight\": 542,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.meta\",\
		\"weight\": 543,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.implicitRules\",\
		\"weight\": 544,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.language\",\
		\"weight\": 545,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.text\",\
		\"weight\": 546,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.contained\",\
		\"weight\": 547,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource.extension\",\
		\"weight\": 548,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource.modifierExtension\",\
		\"weight\": 549,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters\",\
		\"weight\": 550,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.id\",\
		\"weight\": 551,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.meta\",\
		\"weight\": 552,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.implicitRules\",\
		\"weight\": 553,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.language\",\
		\"weight\": 554,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter\",\
		\"weight\": 555,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.id\",\
		\"weight\": 556,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.extension\",\
		\"weight\": 557,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.modifierExtension\",\
		\"weight\": 558,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.name\",\
		\"weight\": 559,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueBoolean\",\
		\"weight\": 560,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueInteger\",\
		\"weight\": 560,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDecimal\",\
		\"weight\": 560,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueBase64Binary\",\
		\"weight\": 560,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueInstant\",\
		\"weight\": 560,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueString\",\
		\"weight\": 560,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueUri\",\
		\"weight\": 560,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDate\",\
		\"weight\": 560,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDateTime\",\
		\"weight\": 560,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueTime\",\
		\"weight\": 560,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCode\",\
		\"weight\": 560,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueOid\",\
		\"weight\": 560,\
		\"type\": \"oid\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueId\",\
		\"weight\": 560,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueUnsignedInt\",\
		\"weight\": 560,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valuePositiveInt\",\
		\"weight\": 560,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueMarkdown\",\
		\"weight\": 560,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAnnotation\",\
		\"weight\": 560,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAttachment\",\
		\"weight\": 560,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueIdentifier\",\
		\"weight\": 560,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCodeableConcept\",\
		\"weight\": 560,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCoding\",\
		\"weight\": 560,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueQuantity\",\
		\"weight\": 560,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueRange\",\
		\"weight\": 560,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valuePeriod\",\
		\"weight\": 560,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueRatio\",\
		\"weight\": 560,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueSampledData\",\
		\"weight\": 560,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueSignature\",\
		\"weight\": 560,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueHumanName\",\
		\"weight\": 560,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAddress\",\
		\"weight\": 560,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueContactPoint\",\
		\"weight\": 560,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueTiming\",\
		\"weight\": 560,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueReference\",\
		\"weight\": 560,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueMeta\",\
		\"weight\": 560,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.resource\",\
		\"weight\": 561,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.part\",\
		\"weight\": 562,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Resource\",\
		\"weight\": 563,\
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
		\"weight\": 564,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.meta\",\
		\"weight\": 565,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.implicitRules\",\
		\"weight\": 566,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.language\",\
		\"weight\": 567,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account\",\
		\"weight\": 568,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.id\",\
		\"weight\": 569,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.meta\",\
		\"weight\": 570,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.implicitRules\",\
		\"weight\": 571,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.language\",\
		\"weight\": 572,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.text\",\
		\"weight\": 573,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.contained\",\
		\"weight\": 574,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.extension\",\
		\"weight\": 575,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.modifierExtension\",\
		\"weight\": 576,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.identifier\",\
		\"weight\": 577,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.name\",\
		\"weight\": 578,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.type\",\
		\"weight\": 579,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.status\",\
		\"weight\": 580,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.activePeriod\",\
		\"weight\": 581,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.currency\",\
		\"weight\": 582,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.balance\",\
		\"weight\": 583,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.coveragePeriod\",\
		\"weight\": 584,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.subject\",\
		\"weight\": 585,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.owner\",\
		\"weight\": 586,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.description\",\
		\"weight\": 587,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance\",\
		\"weight\": 588,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.id\",\
		\"weight\": 589,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.meta\",\
		\"weight\": 590,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.implicitRules\",\
		\"weight\": 591,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.language\",\
		\"weight\": 592,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.text\",\
		\"weight\": 593,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.contained\",\
		\"weight\": 594,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.extension\",\
		\"weight\": 595,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.modifierExtension\",\
		\"weight\": 596,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.identifier\",\
		\"weight\": 597,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.status\",\
		\"weight\": 598,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.type\",\
		\"weight\": 599,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.category\",\
		\"weight\": 600,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.criticality\",\
		\"weight\": 601,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.substance\",\
		\"weight\": 602,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.patient\",\
		\"weight\": 603,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.recordedDate\",\
		\"weight\": 604,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.recorder\",\
		\"weight\": 605,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reporter\",\
		\"weight\": 606,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.onset\",\
		\"weight\": 607,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.lastOccurence\",\
		\"weight\": 608,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.note\",\
		\"weight\": 609,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction\",\
		\"weight\": 610,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.id\",\
		\"weight\": 611,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.extension\",\
		\"weight\": 612,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.modifierExtension\",\
		\"weight\": 613,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.substance\",\
		\"weight\": 614,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.certainty\",\
		\"weight\": 615,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.manifestation\",\
		\"weight\": 616,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.description\",\
		\"weight\": 617,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.onset\",\
		\"weight\": 618,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.severity\",\
		\"weight\": 619,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.exposureRoute\",\
		\"weight\": 620,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.note\",\
		\"weight\": 621,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment\",\
		\"weight\": 622,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.id\",\
		\"weight\": 623,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.meta\",\
		\"weight\": 624,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.implicitRules\",\
		\"weight\": 625,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.language\",\
		\"weight\": 626,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.text\",\
		\"weight\": 627,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.contained\",\
		\"weight\": 628,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.extension\",\
		\"weight\": 629,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.modifierExtension\",\
		\"weight\": 630,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.identifier\",\
		\"weight\": 631,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.status\",\
		\"weight\": 632,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.serviceCategory\",\
		\"weight\": 633,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.serviceType\",\
		\"weight\": 634,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.specialty\",\
		\"weight\": 635,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.appointmentType\",\
		\"weight\": 636,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.reason\",\
		\"weight\": 637,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.priority\",\
		\"weight\": 638,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.description\",\
		\"weight\": 639,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.start\",\
		\"weight\": 640,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.end\",\
		\"weight\": 641,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.minutesDuration\",\
		\"weight\": 642,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.slot\",\
		\"weight\": 643,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.created\",\
		\"weight\": 644,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.comment\",\
		\"weight\": 645,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant\",\
		\"weight\": 646,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.id\",\
		\"weight\": 647,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.extension\",\
		\"weight\": 648,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.modifierExtension\",\
		\"weight\": 649,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.type\",\
		\"weight\": 650,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.actor\",\
		\"weight\": 651,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.required\",\
		\"weight\": 652,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.status\",\
		\"weight\": 653,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse\",\
		\"weight\": 654,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.id\",\
		\"weight\": 655,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.meta\",\
		\"weight\": 656,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.implicitRules\",\
		\"weight\": 657,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.language\",\
		\"weight\": 658,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.text\",\
		\"weight\": 659,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.contained\",\
		\"weight\": 660,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.extension\",\
		\"weight\": 661,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.modifierExtension\",\
		\"weight\": 662,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.identifier\",\
		\"weight\": 663,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.appointment\",\
		\"weight\": 664,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.start\",\
		\"weight\": 665,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.end\",\
		\"weight\": 666,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.participantType\",\
		\"weight\": 667,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.actor\",\
		\"weight\": 668,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.participantStatus\",\
		\"weight\": 669,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.comment\",\
		\"weight\": 670,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent\",\
		\"weight\": 671,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.id\",\
		\"weight\": 672,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.meta\",\
		\"weight\": 673,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.implicitRules\",\
		\"weight\": 674,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.language\",\
		\"weight\": 675,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.text\",\
		\"weight\": 676,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.contained\",\
		\"weight\": 677,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.extension\",\
		\"weight\": 678,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.modifierExtension\",\
		\"weight\": 679,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.type\",\
		\"weight\": 680,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.subtype\",\
		\"weight\": 681,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.action\",\
		\"weight\": 682,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.recorded\",\
		\"weight\": 683,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.outcome\",\
		\"weight\": 684,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.outcomeDesc\",\
		\"weight\": 685,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.purposeOfEvent\",\
		\"weight\": 686,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent\",\
		\"weight\": 687,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.id\",\
		\"weight\": 688,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.extension\",\
		\"weight\": 689,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.modifierExtension\",\
		\"weight\": 690,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.role\",\
		\"weight\": 691,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.reference\",\
		\"weight\": 692,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.userId\",\
		\"weight\": 693,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.altId\",\
		\"weight\": 694,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.name\",\
		\"weight\": 695,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.requestor\",\
		\"weight\": 696,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.location\",\
		\"weight\": 697,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.policy\",\
		\"weight\": 698,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.media\",\
		\"weight\": 699,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network\",\
		\"weight\": 700,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.id\",\
		\"weight\": 701,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.extension\",\
		\"weight\": 702,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.modifierExtension\",\
		\"weight\": 703,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.address\",\
		\"weight\": 704,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.type\",\
		\"weight\": 705,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.purposeOfUse\",\
		\"weight\": 706,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source\",\
		\"weight\": 707,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.id\",\
		\"weight\": 708,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.extension\",\
		\"weight\": 709,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source.modifierExtension\",\
		\"weight\": 710,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source.site\",\
		\"weight\": 711,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.identifier\",\
		\"weight\": 712,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.type\",\
		\"weight\": 713,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity\",\
		\"weight\": 714,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.id\",\
		\"weight\": 715,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.extension\",\
		\"weight\": 716,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.modifierExtension\",\
		\"weight\": 717,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.identifier\",\
		\"weight\": 718,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.reference\",\
		\"weight\": 719,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.type\",\
		\"weight\": 720,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.role\",\
		\"weight\": 721,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.lifecycle\",\
		\"weight\": 722,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.securityLabel\",\
		\"weight\": 723,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.name\",\
		\"weight\": 724,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.description\",\
		\"weight\": 725,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.query\",\
		\"weight\": 726,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail\",\
		\"weight\": 727,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.id\",\
		\"weight\": 728,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.extension\",\
		\"weight\": 729,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.modifierExtension\",\
		\"weight\": 730,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.type\",\
		\"weight\": 731,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.value\",\
		\"weight\": 732,\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic\",\
		\"weight\": 733,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.id\",\
		\"weight\": 734,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.meta\",\
		\"weight\": 735,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.implicitRules\",\
		\"weight\": 736,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.language\",\
		\"weight\": 737,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.text\",\
		\"weight\": 738,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.contained\",\
		\"weight\": 739,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.extension\",\
		\"weight\": 740,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.modifierExtension\",\
		\"weight\": 741,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.identifier\",\
		\"weight\": 742,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.code\",\
		\"weight\": 743,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.subject\",\
		\"weight\": 744,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.created\",\
		\"weight\": 745,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.author\",\
		\"weight\": 746,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary\",\
		\"weight\": 747,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Binary.id\",\
		\"weight\": 748,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.meta\",\
		\"weight\": 749,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.implicitRules\",\
		\"weight\": 750,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.language\",\
		\"weight\": 751,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.contentType\",\
		\"weight\": 752,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.content\",\
		\"weight\": 753,\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite\",\
		\"weight\": 754,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.id\",\
		\"weight\": 755,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.meta\",\
		\"weight\": 756,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.implicitRules\",\
		\"weight\": 757,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.language\",\
		\"weight\": 758,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.text\",\
		\"weight\": 759,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.contained\",\
		\"weight\": 760,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.extension\",\
		\"weight\": 761,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.modifierExtension\",\
		\"weight\": 762,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.patient\",\
		\"weight\": 763,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.identifier\",\
		\"weight\": 764,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.code\",\
		\"weight\": 765,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.modifier\",\
		\"weight\": 766,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.description\",\
		\"weight\": 767,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.image\",\
		\"weight\": 768,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle\",\
		\"weight\": 769,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.id\",\
		\"weight\": 770,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.meta\",\
		\"weight\": 771,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.implicitRules\",\
		\"weight\": 772,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.language\",\
		\"weight\": 773,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.type\",\
		\"weight\": 774,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.total\",\
		\"weight\": 775,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link\",\
		\"weight\": 776,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.id\",\
		\"weight\": 777,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link.extension\",\
		\"weight\": 778,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.modifierExtension\",\
		\"weight\": 779,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.relation\",\
		\"weight\": 780,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link.url\",\
		\"weight\": 781,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry\",\
		\"weight\": 782,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.id\",\
		\"weight\": 783,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.extension\",\
		\"weight\": 784,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.modifierExtension\",\
		\"weight\": 785,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.link\",\
		\"weight\": 786,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.fullUrl\",\
		\"weight\": 787,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.resource\",\
		\"weight\": 788,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search\",\
		\"weight\": 789,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.id\",\
		\"weight\": 790,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.extension\",\
		\"weight\": 791,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.modifierExtension\",\
		\"weight\": 792,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.mode\",\
		\"weight\": 793,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.score\",\
		\"weight\": 794,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request\",\
		\"weight\": 795,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.id\",\
		\"weight\": 796,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.extension\",\
		\"weight\": 797,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.modifierExtension\",\
		\"weight\": 798,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.method\",\
		\"weight\": 799,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.url\",\
		\"weight\": 800,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifNoneMatch\",\
		\"weight\": 801,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifModifiedSince\",\
		\"weight\": 802,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifMatch\",\
		\"weight\": 803,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifNoneExist\",\
		\"weight\": 804,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response\",\
		\"weight\": 805,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.id\",\
		\"weight\": 806,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.extension\",\
		\"weight\": 807,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.modifierExtension\",\
		\"weight\": 808,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.status\",\
		\"weight\": 809,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.location\",\
		\"weight\": 810,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.etag\",\
		\"weight\": 811,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.lastModified\",\
		\"weight\": 812,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.signature\",\
		\"weight\": 813,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan\",\
		\"weight\": 814,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.id\",\
		\"weight\": 815,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.meta\",\
		\"weight\": 816,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.implicitRules\",\
		\"weight\": 817,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.language\",\
		\"weight\": 818,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.text\",\
		\"weight\": 819,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.contained\",\
		\"weight\": 820,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.extension\",\
		\"weight\": 821,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.modifierExtension\",\
		\"weight\": 822,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.identifier\",\
		\"weight\": 823,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.subject\",\
		\"weight\": 824,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.status\",\
		\"weight\": 825,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.context\",\
		\"weight\": 826,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.period\",\
		\"weight\": 827,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.author\",\
		\"weight\": 828,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.modified\",\
		\"weight\": 829,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.category\",\
		\"weight\": 830,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.description\",\
		\"weight\": 831,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.addresses\",\
		\"weight\": 832,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.support\",\
		\"weight\": 833,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan\",\
		\"weight\": 834,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.id\",\
		\"weight\": 835,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.extension\",\
		\"weight\": 836,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.modifierExtension\",\
		\"weight\": 837,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.code\",\
		\"weight\": 838,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.plan\",\
		\"weight\": 839,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.participant\",\
		\"weight\": 840,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.participant.id\",\
		\"weight\": 841,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.participant.extension\",\
		\"weight\": 842,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.participant.modifierExtension\",\
		\"weight\": 843,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.participant.role\",\
		\"weight\": 844,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.participant.member\",\
		\"weight\": 845,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.goal\",\
		\"weight\": 846,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity\",\
		\"weight\": 847,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.id\",\
		\"weight\": 848,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.extension\",\
		\"weight\": 849,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.modifierExtension\",\
		\"weight\": 850,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.actionResulting\",\
		\"weight\": 851,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.progress\",\
		\"weight\": 852,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.reference\",\
		\"weight\": 853,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail\",\
		\"weight\": 854,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.id\",\
		\"weight\": 855,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.extension\",\
		\"weight\": 856,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.modifierExtension\",\
		\"weight\": 857,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.category\",\
		\"weight\": 858,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.code\",\
		\"weight\": 859,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.reasonCode\",\
		\"weight\": 860,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.reasonReference\",\
		\"weight\": 861,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.goal\",\
		\"weight\": 862,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.status\",\
		\"weight\": 863,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.statusReason\",\
		\"weight\": 864,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.prohibited\",\
		\"weight\": 865,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledTiming\",\
		\"weight\": 866,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledPeriod\",\
		\"weight\": 866,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledString\",\
		\"weight\": 866,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.location\",\
		\"weight\": 867,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.performer\",\
		\"weight\": 868,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productCodeableConcept\",\
		\"weight\": 869,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"weight\": 869,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"weight\": 869,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.dailyAmount\",\
		\"weight\": 870,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.quantity\",\
		\"weight\": 871,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.description\",\
		\"weight\": 872,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.note\",\
		\"weight\": 873,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam\",\
		\"weight\": 874,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.id\",\
		\"weight\": 875,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.meta\",\
		\"weight\": 876,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.implicitRules\",\
		\"weight\": 877,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.language\",\
		\"weight\": 878,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.text\",\
		\"weight\": 879,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.contained\",\
		\"weight\": 880,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.extension\",\
		\"weight\": 881,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.modifierExtension\",\
		\"weight\": 882,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.identifier\",\
		\"weight\": 883,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.status\",\
		\"weight\": 884,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.type\",\
		\"weight\": 885,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.name\",\
		\"weight\": 886,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.subject\",\
		\"weight\": 887,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.period\",\
		\"weight\": 888,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant\",\
		\"weight\": 889,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.id\",\
		\"weight\": 890,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.extension\",\
		\"weight\": 891,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.modifierExtension\",\
		\"weight\": 892,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.role\",\
		\"weight\": 893,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.member\",\
		\"weight\": 894,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.period\",\
		\"weight\": 895,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.managingOrganization\",\
		\"weight\": 896,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim\",\
		\"weight\": 897,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.id\",\
		\"weight\": 898,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.meta\",\
		\"weight\": 899,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.implicitRules\",\
		\"weight\": 900,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.language\",\
		\"weight\": 901,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.text\",\
		\"weight\": 902,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.contained\",\
		\"weight\": 903,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.extension\",\
		\"weight\": 904,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.modifierExtension\",\
		\"weight\": 905,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.type\",\
		\"weight\": 906,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.subType\",\
		\"weight\": 907,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.identifier\",\
		\"weight\": 908,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.ruleset\",\
		\"weight\": 909,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.originalRuleset\",\
		\"weight\": 910,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.created\",\
		\"weight\": 911,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.billablePeriod\",\
		\"weight\": 912,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.targetIdentifier\",\
		\"weight\": 913,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.targetReference\",\
		\"weight\": 913,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.providerIdentifier\",\
		\"weight\": 914,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.providerReference\",\
		\"weight\": 914,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.organizationIdentifier\",\
		\"weight\": 915,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.organizationReference\",\
		\"weight\": 915,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.use\",\
		\"weight\": 916,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.priority\",\
		\"weight\": 917,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.fundsReserve\",\
		\"weight\": 918,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.entererIdentifier\",\
		\"weight\": 919,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.entererReference\",\
		\"weight\": 919,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.facilityIdentifier\",\
		\"weight\": 920,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.facilityReference\",\
		\"weight\": 920,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related\",\
		\"weight\": 921,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.id\",\
		\"weight\": 922,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.extension\",\
		\"weight\": 923,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.modifierExtension\",\
		\"weight\": 924,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.claimIdentifier\",\
		\"weight\": 925,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.claimReference\",\
		\"weight\": 925,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.relationship\",\
		\"weight\": 926,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.reference\",\
		\"weight\": 927,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.prescriptionIdentifier\",\
		\"weight\": 928,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.prescriptionReference\",\
		\"weight\": 928,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.prescriptionReference\",\
		\"weight\": 928,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.originalPrescriptionIdentifier\",\
		\"weight\": 929,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.originalPrescriptionReference\",\
		\"weight\": 929,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee\",\
		\"weight\": 930,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.id\",\
		\"weight\": 931,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.extension\",\
		\"weight\": 932,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.payee.modifierExtension\",\
		\"weight\": 933,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.payee.type\",\
		\"weight\": 934,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyIdentifier\",\
		\"weight\": 935,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 935,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 935,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 935,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"weight\": 935,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.referralIdentifier\",\
		\"weight\": 936,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.referralReference\",\
		\"weight\": 936,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.occurrenceCode\",\
		\"weight\": 937,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.occurenceSpanCode\",\
		\"weight\": 938,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.valueCode\",\
		\"weight\": 939,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis\",\
		\"weight\": 940,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.id\",\
		\"weight\": 941,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.extension\",\
		\"weight\": 942,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.modifierExtension\",\
		\"weight\": 943,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.sequence\",\
		\"weight\": 944,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.diagnosis\",\
		\"weight\": 945,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure\",\
		\"weight\": 946,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.id\",\
		\"weight\": 947,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.extension\",\
		\"weight\": 948,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.modifierExtension\",\
		\"weight\": 949,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.sequence\",\
		\"weight\": 950,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.date\",\
		\"weight\": 951,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.procedureCoding\",\
		\"weight\": 952,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.procedureReference\",\
		\"weight\": 952,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.specialCondition\",\
		\"weight\": 953,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.patientIdentifier\",\
		\"weight\": 954,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.patientReference\",\
		\"weight\": 954,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage\",\
		\"weight\": 955,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.id\",\
		\"weight\": 956,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.extension\",\
		\"weight\": 957,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.modifierExtension\",\
		\"weight\": 958,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.sequence\",\
		\"weight\": 959,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.focal\",\
		\"weight\": 960,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.coverageIdentifier\",\
		\"weight\": 961,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.coverageReference\",\
		\"weight\": 961,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.businessArrangement\",\
		\"weight\": 962,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.preAuthRef\",\
		\"weight\": 963,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.claimResponse\",\
		\"weight\": 964,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.originalRuleset\",\
		\"weight\": 965,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accidentDate\",\
		\"weight\": 966,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accidentType\",\
		\"weight\": 967,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accidentLocationAddress\",\
		\"weight\": 968,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accidentLocationReference\",\
		\"weight\": 968,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.interventionException\",\
		\"weight\": 969,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.onset\",\
		\"weight\": 970,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.onset.id\",\
		\"weight\": 971,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.onset.extension\",\
		\"weight\": 972,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.onset.modifierExtension\",\
		\"weight\": 973,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.onset.timeDate\",\
		\"weight\": 974,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.onset.timePeriod\",\
		\"weight\": 974,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.onset.type\",\
		\"weight\": 975,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.employmentImpacted\",\
		\"weight\": 976,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.hospitalization\",\
		\"weight\": 977,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item\",\
		\"weight\": 978,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.id\",\
		\"weight\": 979,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.extension\",\
		\"weight\": 980,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.modifierExtension\",\
		\"weight\": 981,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.sequence\",\
		\"weight\": 982,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.type\",\
		\"weight\": 983,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.providerIdentifier\",\
		\"weight\": 984,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.providerReference\",\
		\"weight\": 984,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.supervisorIdentifier\",\
		\"weight\": 985,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.supervisorReference\",\
		\"weight\": 985,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.providerQualification\",\
		\"weight\": 986,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.diagnosisLinkId\",\
		\"weight\": 987,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.service\",\
		\"weight\": 988,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.serviceModifier\",\
		\"weight\": 989,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.modifier\",\
		\"weight\": 990,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.programCode\",\
		\"weight\": 991,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.servicedDate\",\
		\"weight\": 992,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.servicedPeriod\",\
		\"weight\": 992,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.place\",\
		\"weight\": 993,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.quantity\",\
		\"weight\": 994,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.unitPrice\",\
		\"weight\": 995,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.factor\",\
		\"weight\": 996,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.points\",\
		\"weight\": 997,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.net\",\
		\"weight\": 998,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.udi\",\
		\"weight\": 999,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.bodySite\",\
		\"weight\": 1000,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.subSite\",\
		\"weight\": 1001,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail\",\
		\"weight\": 1002,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.id\",\
		\"weight\": 1003,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.extension\",\
		\"weight\": 1004,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.modifierExtension\",\
		\"weight\": 1005,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.sequence\",\
		\"weight\": 1006,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.type\",\
		\"weight\": 1007,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.service\",\
		\"weight\": 1008,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.programCode\",\
		\"weight\": 1009,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.quantity\",\
		\"weight\": 1010,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.unitPrice\",\
		\"weight\": 1011,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.factor\",\
		\"weight\": 1012,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.points\",\
		\"weight\": 1013,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.net\",\
		\"weight\": 1014,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.udi\",\
		\"weight\": 1015,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail\",\
		\"weight\": 1016,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.id\",\
		\"weight\": 1017,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.extension\",\
		\"weight\": 1018,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.modifierExtension\",\
		\"weight\": 1019,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.sequence\",\
		\"weight\": 1020,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.type\",\
		\"weight\": 1021,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.service\",\
		\"weight\": 1022,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.programCode\",\
		\"weight\": 1023,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.quantity\",\
		\"weight\": 1024,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.unitPrice\",\
		\"weight\": 1025,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.factor\",\
		\"weight\": 1026,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.points\",\
		\"weight\": 1027,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.net\",\
		\"weight\": 1028,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.udi\",\
		\"weight\": 1029,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis\",\
		\"weight\": 1030,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.id\",\
		\"weight\": 1031,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.extension\",\
		\"weight\": 1032,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.modifierExtension\",\
		\"weight\": 1033,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.initial\",\
		\"weight\": 1034,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.priorDate\",\
		\"weight\": 1035,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.priorMaterial\",\
		\"weight\": 1036,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.total\",\
		\"weight\": 1037,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.additionalMaterial\",\
		\"weight\": 1038,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth\",\
		\"weight\": 1039,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.id\",\
		\"weight\": 1040,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.extension\",\
		\"weight\": 1041,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.modifierExtension\",\
		\"weight\": 1042,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.tooth\",\
		\"weight\": 1043,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.reason\",\
		\"weight\": 1044,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.extractionDate\",\
		\"weight\": 1045,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse\",\
		\"weight\": 1046,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.id\",\
		\"weight\": 1047,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.meta\",\
		\"weight\": 1048,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.implicitRules\",\
		\"weight\": 1049,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.language\",\
		\"weight\": 1050,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.text\",\
		\"weight\": 1051,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.contained\",\
		\"weight\": 1052,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.extension\",\
		\"weight\": 1053,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.modifierExtension\",\
		\"weight\": 1054,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.identifier\",\
		\"weight\": 1055,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestIdentifier\",\
		\"weight\": 1056,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestReference\",\
		\"weight\": 1056,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.ruleset\",\
		\"weight\": 1057,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.originalRuleset\",\
		\"weight\": 1058,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.created\",\
		\"weight\": 1059,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.organizationIdentifier\",\
		\"weight\": 1060,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.organizationReference\",\
		\"weight\": 1060,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestProviderIdentifier\",\
		\"weight\": 1061,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestProviderReference\",\
		\"weight\": 1061,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestOrganizationIdentifier\",\
		\"weight\": 1062,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestOrganizationReference\",\
		\"weight\": 1062,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.outcome\",\
		\"weight\": 1063,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.disposition\",\
		\"weight\": 1064,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payeeType\",\
		\"weight\": 1065,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item\",\
		\"weight\": 1066,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.id\",\
		\"weight\": 1067,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.extension\",\
		\"weight\": 1068,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.modifierExtension\",\
		\"weight\": 1069,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.sequenceLinkId\",\
		\"weight\": 1070,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.noteNumber\",\
		\"weight\": 1071,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication\",\
		\"weight\": 1072,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.id\",\
		\"weight\": 1073,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.extension\",\
		\"weight\": 1074,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.modifierExtension\",\
		\"weight\": 1075,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.category\",\
		\"weight\": 1076,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.reason\",\
		\"weight\": 1077,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.amount\",\
		\"weight\": 1078,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.value\",\
		\"weight\": 1079,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail\",\
		\"weight\": 1080,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.id\",\
		\"weight\": 1081,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.extension\",\
		\"weight\": 1082,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.modifierExtension\",\
		\"weight\": 1083,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.sequenceLinkId\",\
		\"weight\": 1084,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication\",\
		\"weight\": 1085,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.id\",\
		\"weight\": 1086,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.extension\",\
		\"weight\": 1087,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.modifierExtension\",\
		\"weight\": 1088,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.category\",\
		\"weight\": 1089,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.reason\",\
		\"weight\": 1090,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.amount\",\
		\"weight\": 1091,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.value\",\
		\"weight\": 1092,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail\",\
		\"weight\": 1093,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.id\",\
		\"weight\": 1094,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.extension\",\
		\"weight\": 1095,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.modifierExtension\",\
		\"weight\": 1096,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.sequenceLinkId\",\
		\"weight\": 1097,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication\",\
		\"weight\": 1098,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.id\",\
		\"weight\": 1099,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.extension\",\
		\"weight\": 1100,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.modifierExtension\",\
		\"weight\": 1101,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.category\",\
		\"weight\": 1102,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.reason\",\
		\"weight\": 1103,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.amount\",\
		\"weight\": 1104,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.value\",\
		\"weight\": 1105,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem\",\
		\"weight\": 1106,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.id\",\
		\"weight\": 1107,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.extension\",\
		\"weight\": 1108,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.modifierExtension\",\
		\"weight\": 1109,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.sequenceLinkId\",\
		\"weight\": 1110,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.service\",\
		\"weight\": 1111,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.fee\",\
		\"weight\": 1112,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.noteNumberLinkId\",\
		\"weight\": 1113,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication\",\
		\"weight\": 1114,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.id\",\
		\"weight\": 1115,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.extension\",\
		\"weight\": 1116,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.modifierExtension\",\
		\"weight\": 1117,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.category\",\
		\"weight\": 1118,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.reason\",\
		\"weight\": 1119,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.amount\",\
		\"weight\": 1120,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.value\",\
		\"weight\": 1121,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail\",\
		\"weight\": 1122,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.id\",\
		\"weight\": 1123,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.extension\",\
		\"weight\": 1124,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.modifierExtension\",\
		\"weight\": 1125,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.service\",\
		\"weight\": 1126,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.fee\",\
		\"weight\": 1127,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication\",\
		\"weight\": 1128,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.id\",\
		\"weight\": 1129,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.extension\",\
		\"weight\": 1130,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.modifierExtension\",\
		\"weight\": 1131,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.category\",\
		\"weight\": 1132,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.reason\",\
		\"weight\": 1133,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.amount\",\
		\"weight\": 1134,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.value\",\
		\"weight\": 1135,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error\",\
		\"weight\": 1136,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.id\",\
		\"weight\": 1137,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.extension\",\
		\"weight\": 1138,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.modifierExtension\",\
		\"weight\": 1139,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.sequenceLinkId\",\
		\"weight\": 1140,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.detailSequenceLinkId\",\
		\"weight\": 1141,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.subdetailSequenceLinkId\",\
		\"weight\": 1142,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.code\",\
		\"weight\": 1143,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.totalCost\",\
		\"weight\": 1144,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.unallocDeductable\",\
		\"weight\": 1145,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.totalBenefit\",\
		\"weight\": 1146,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentAdjustment\",\
		\"weight\": 1147,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentAdjustmentReason\",\
		\"weight\": 1148,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentDate\",\
		\"weight\": 1149,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentAmount\",\
		\"weight\": 1150,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentRef\",\
		\"weight\": 1151,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.reserved\",\
		\"weight\": 1152,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.form\",\
		\"weight\": 1153,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note\",\
		\"weight\": 1154,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.id\",\
		\"weight\": 1155,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.extension\",\
		\"weight\": 1156,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.modifierExtension\",\
		\"weight\": 1157,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.number\",\
		\"weight\": 1158,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.type\",\
		\"weight\": 1159,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.text\",\
		\"weight\": 1160,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage\",\
		\"weight\": 1161,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.id\",\
		\"weight\": 1162,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.extension\",\
		\"weight\": 1163,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.modifierExtension\",\
		\"weight\": 1164,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.sequence\",\
		\"weight\": 1165,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.focal\",\
		\"weight\": 1166,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.coverageIdentifier\",\
		\"weight\": 1167,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.coverageReference\",\
		\"weight\": 1167,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.businessArrangement\",\
		\"weight\": 1168,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.preAuthRef\",\
		\"weight\": 1169,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.claimResponse\",\
		\"weight\": 1170,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression\",\
		\"weight\": 1171,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.id\",\
		\"weight\": 1172,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.meta\",\
		\"weight\": 1173,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.implicitRules\",\
		\"weight\": 1174,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.language\",\
		\"weight\": 1175,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.text\",\
		\"weight\": 1176,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.contained\",\
		\"weight\": 1177,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.extension\",\
		\"weight\": 1178,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.modifierExtension\",\
		\"weight\": 1179,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.patient\",\
		\"weight\": 1180,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.assessor\",\
		\"weight\": 1181,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.status\",\
		\"weight\": 1182,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.date\",\
		\"weight\": 1183,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.description\",\
		\"weight\": 1184,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.previous\",\
		\"weight\": 1185,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.problem\",\
		\"weight\": 1186,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.triggerCodeableConcept\",\
		\"weight\": 1187,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.triggerReference\",\
		\"weight\": 1187,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations\",\
		\"weight\": 1188,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.id\",\
		\"weight\": 1189,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.extension\",\
		\"weight\": 1190,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.modifierExtension\",\
		\"weight\": 1191,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.code\",\
		\"weight\": 1192,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.item\",\
		\"weight\": 1193,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.protocol\",\
		\"weight\": 1194,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.summary\",\
		\"weight\": 1195,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding\",\
		\"weight\": 1196,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.id\",\
		\"weight\": 1197,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.extension\",\
		\"weight\": 1198,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.modifierExtension\",\
		\"weight\": 1199,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.item\",\
		\"weight\": 1200,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.cause\",\
		\"weight\": 1201,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.resolved\",\
		\"weight\": 1202,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut\",\
		\"weight\": 1203,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.id\",\
		\"weight\": 1204,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.extension\",\
		\"weight\": 1205,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.modifierExtension\",\
		\"weight\": 1206,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.item\",\
		\"weight\": 1207,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.reason\",\
		\"weight\": 1208,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.prognosis\",\
		\"weight\": 1209,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.plan\",\
		\"weight\": 1210,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.action\",\
		\"weight\": 1211,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication\",\
		\"weight\": 1212,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.id\",\
		\"weight\": 1213,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.meta\",\
		\"weight\": 1214,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.implicitRules\",\
		\"weight\": 1215,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.language\",\
		\"weight\": 1216,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.text\",\
		\"weight\": 1217,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.contained\",\
		\"weight\": 1218,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.extension\",\
		\"weight\": 1219,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.modifierExtension\",\
		\"weight\": 1220,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.identifier\",\
		\"weight\": 1221,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.category\",\
		\"weight\": 1222,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.sender\",\
		\"weight\": 1223,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.recipient\",\
		\"weight\": 1224,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload\",\
		\"weight\": 1225,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.id\",\
		\"weight\": 1226,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.payload.extension\",\
		\"weight\": 1227,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.modifierExtension\",\
		\"weight\": 1228,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.contentString\",\
		\"weight\": 1229,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.payload.contentAttachment\",\
		\"weight\": 1229,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.payload.contentReference\",\
		\"weight\": 1229,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.medium\",\
		\"weight\": 1230,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.status\",\
		\"weight\": 1231,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.encounter\",\
		\"weight\": 1232,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.sent\",\
		\"weight\": 1233,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.received\",\
		\"weight\": 1234,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.reason\",\
		\"weight\": 1235,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.subject\",\
		\"weight\": 1236,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.requestDetail\",\
		\"weight\": 1237,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest\",\
		\"weight\": 1238,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.id\",\
		\"weight\": 1239,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.meta\",\
		\"weight\": 1240,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.implicitRules\",\
		\"weight\": 1241,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.language\",\
		\"weight\": 1242,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.text\",\
		\"weight\": 1243,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.contained\",\
		\"weight\": 1244,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.extension\",\
		\"weight\": 1245,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.modifierExtension\",\
		\"weight\": 1246,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.identifier\",\
		\"weight\": 1247,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.category\",\
		\"weight\": 1248,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.sender\",\
		\"weight\": 1249,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.recipient\",\
		\"weight\": 1250,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload\",\
		\"weight\": 1251,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.id\",\
		\"weight\": 1252,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.extension\",\
		\"weight\": 1253,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.modifierExtension\",\
		\"weight\": 1254,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentString\",\
		\"weight\": 1255,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentAttachment\",\
		\"weight\": 1255,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentReference\",\
		\"weight\": 1255,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.medium\",\
		\"weight\": 1256,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.requester\",\
		\"weight\": 1257,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.status\",\
		\"weight\": 1258,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.encounter\",\
		\"weight\": 1259,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.scheduledDateTime\",\
		\"weight\": 1260,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.scheduledPeriod\",\
		\"weight\": 1260,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.reason\",\
		\"weight\": 1261,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.requestedOn\",\
		\"weight\": 1262,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.subject\",\
		\"weight\": 1263,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.priority\",\
		\"weight\": 1264,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition\",\
		\"weight\": 1265,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.id\",\
		\"weight\": 1266,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.meta\",\
		\"weight\": 1267,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.implicitRules\",\
		\"weight\": 1268,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.language\",\
		\"weight\": 1269,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.text\",\
		\"weight\": 1270,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contained\",\
		\"weight\": 1271,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.extension\",\
		\"weight\": 1272,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.modifierExtension\",\
		\"weight\": 1273,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.url\",\
		\"weight\": 1274,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.name\",\
		\"weight\": 1275,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.status\",\
		\"weight\": 1276,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.experimental\",\
		\"weight\": 1277,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.publisher\",\
		\"weight\": 1278,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact\",\
		\"weight\": 1279,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.id\",\
		\"weight\": 1280,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.extension\",\
		\"weight\": 1281,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.modifierExtension\",\
		\"weight\": 1282,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.name\",\
		\"weight\": 1283,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.telecom\",\
		\"weight\": 1284,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.date\",\
		\"weight\": 1285,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.description\",\
		\"weight\": 1286,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.requirements\",\
		\"weight\": 1287,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.code\",\
		\"weight\": 1288,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.search\",\
		\"weight\": 1289,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource\",\
		\"weight\": 1290,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.id\",\
		\"weight\": 1291,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.extension\",\
		\"weight\": 1292,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.modifierExtension\",\
		\"weight\": 1293,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.code\",\
		\"weight\": 1294,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.param\",\
		\"weight\": 1295,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.documentation\",\
		\"weight\": 1296,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition\",\
		\"weight\": 1297,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.id\",\
		\"weight\": 1298,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.meta\",\
		\"weight\": 1299,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.implicitRules\",\
		\"weight\": 1300,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.language\",\
		\"weight\": 1301,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.text\",\
		\"weight\": 1302,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.contained\",\
		\"weight\": 1303,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.extension\",\
		\"weight\": 1304,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.modifierExtension\",\
		\"weight\": 1305,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.identifier\",\
		\"weight\": 1306,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.date\",\
		\"weight\": 1307,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.type\",\
		\"weight\": 1308,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.class\",\
		\"weight\": 1309,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.title\",\
		\"weight\": 1310,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.status\",\
		\"weight\": 1311,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.confidentiality\",\
		\"weight\": 1312,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.subject\",\
		\"weight\": 1313,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.author\",\
		\"weight\": 1314,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester\",\
		\"weight\": 1315,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.id\",\
		\"weight\": 1316,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.attester.extension\",\
		\"weight\": 1317,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.modifierExtension\",\
		\"weight\": 1318,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.mode\",\
		\"weight\": 1319,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.time\",\
		\"weight\": 1320,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.attester.party\",\
		\"weight\": 1321,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.custodian\",\
		\"weight\": 1322,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event\",\
		\"weight\": 1323,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.id\",\
		\"weight\": 1324,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event.extension\",\
		\"weight\": 1325,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.modifierExtension\",\
		\"weight\": 1326,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.code\",\
		\"weight\": 1327,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.period\",\
		\"weight\": 1328,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event.detail\",\
		\"weight\": 1329,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.encounter\",\
		\"weight\": 1330,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section\",\
		\"weight\": 1331,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.id\",\
		\"weight\": 1332,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.extension\",\
		\"weight\": 1333,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.modifierExtension\",\
		\"weight\": 1334,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.title\",\
		\"weight\": 1335,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.code\",\
		\"weight\": 1336,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.text\",\
		\"weight\": 1337,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.mode\",\
		\"weight\": 1338,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.orderedBy\",\
		\"weight\": 1339,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.entry\",\
		\"weight\": 1340,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.emptyReason\",\
		\"weight\": 1341,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.section\",\
		\"weight\": 1342,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap\",\
		\"weight\": 1343,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.id\",\
		\"weight\": 1344,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.meta\",\
		\"weight\": 1345,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.implicitRules\",\
		\"weight\": 1346,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.language\",\
		\"weight\": 1347,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.text\",\
		\"weight\": 1348,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contained\",\
		\"weight\": 1349,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.extension\",\
		\"weight\": 1350,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.modifierExtension\",\
		\"weight\": 1351,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.url\",\
		\"weight\": 1352,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.identifier\",\
		\"weight\": 1353,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.version\",\
		\"weight\": 1354,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.name\",\
		\"weight\": 1355,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.status\",\
		\"weight\": 1356,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.experimental\",\
		\"weight\": 1357,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.publisher\",\
		\"weight\": 1358,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact\",\
		\"weight\": 1359,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.id\",\
		\"weight\": 1360,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.extension\",\
		\"weight\": 1361,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.modifierExtension\",\
		\"weight\": 1362,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.name\",\
		\"weight\": 1363,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.telecom\",\
		\"weight\": 1364,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.date\",\
		\"weight\": 1365,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.description\",\
		\"weight\": 1366,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.useContext\",\
		\"weight\": 1367,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.requirements\",\
		\"weight\": 1368,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.copyright\",\
		\"weight\": 1369,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceUri\",\
		\"weight\": 1370,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceReference\",\
		\"weight\": 1370,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceReference\",\
		\"weight\": 1370,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.targetUri\",\
		\"weight\": 1371,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.targetReference\",\
		\"weight\": 1371,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.targetReference\",\
		\"weight\": 1371,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element\",\
		\"weight\": 1372,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.id\",\
		\"weight\": 1373,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.extension\",\
		\"weight\": 1374,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.modifierExtension\",\
		\"weight\": 1375,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.system\",\
		\"weight\": 1376,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.version\",\
		\"weight\": 1377,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.code\",\
		\"weight\": 1378,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target\",\
		\"weight\": 1379,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.id\",\
		\"weight\": 1380,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.extension\",\
		\"weight\": 1381,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.modifierExtension\",\
		\"weight\": 1382,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.system\",\
		\"weight\": 1383,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.version\",\
		\"weight\": 1384,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.code\",\
		\"weight\": 1385,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.equivalence\",\
		\"weight\": 1386,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.comments\",\
		\"weight\": 1387,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn\",\
		\"weight\": 1388,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.id\",\
		\"weight\": 1389,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.extension\",\
		\"weight\": 1390,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.modifierExtension\",\
		\"weight\": 1391,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.element\",\
		\"weight\": 1392,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.system\",\
		\"weight\": 1393,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.code\",\
		\"weight\": 1394,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.product\",\
		\"weight\": 1395,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition\",\
		\"weight\": 1396,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.id\",\
		\"weight\": 1397,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.meta\",\
		\"weight\": 1398,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.implicitRules\",\
		\"weight\": 1399,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.language\",\
		\"weight\": 1400,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.text\",\
		\"weight\": 1401,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.contained\",\
		\"weight\": 1402,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.extension\",\
		\"weight\": 1403,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.modifierExtension\",\
		\"weight\": 1404,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.identifier\",\
		\"weight\": 1405,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.patient\",\
		\"weight\": 1406,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.encounter\",\
		\"weight\": 1407,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.asserter\",\
		\"weight\": 1408,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.dateRecorded\",\
		\"weight\": 1409,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.code\",\
		\"weight\": 1410,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.category\",\
		\"weight\": 1411,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.clinicalStatus\",\
		\"weight\": 1412,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.verificationStatus\",\
		\"weight\": 1413,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.severity\",\
		\"weight\": 1414,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetDateTime\",\
		\"weight\": 1415,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetQuantity\",\
		\"weight\": 1415,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetPeriod\",\
		\"weight\": 1415,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetRange\",\
		\"weight\": 1415,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetString\",\
		\"weight\": 1415,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementDateTime\",\
		\"weight\": 1416,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementQuantity\",\
		\"weight\": 1416,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementBoolean\",\
		\"weight\": 1416,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementPeriod\",\
		\"weight\": 1416,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementRange\",\
		\"weight\": 1416,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.abatementString\",\
		\"weight\": 1416,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage\",\
		\"weight\": 1417,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.id\",\
		\"weight\": 1418,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.extension\",\
		\"weight\": 1419,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.stage.modifierExtension\",\
		\"weight\": 1420,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.stage.summary\",\
		\"weight\": 1421,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.assessment\",\
		\"weight\": 1422,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence\",\
		\"weight\": 1423,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.id\",\
		\"weight\": 1424,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.evidence.extension\",\
		\"weight\": 1425,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.modifierExtension\",\
		\"weight\": 1426,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.code\",\
		\"weight\": 1427,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.evidence.detail\",\
		\"weight\": 1428,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.bodySite\",\
		\"weight\": 1429,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.note\",\
		\"weight\": 1430,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance\",\
		\"weight\": 1431,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.id\",\
		\"weight\": 1432,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.meta\",\
		\"weight\": 1433,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implicitRules\",\
		\"weight\": 1434,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.language\",\
		\"weight\": 1435,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.text\",\
		\"weight\": 1436,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contained\",\
		\"weight\": 1437,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.extension\",\
		\"weight\": 1438,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.modifierExtension\",\
		\"weight\": 1439,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.url\",\
		\"weight\": 1440,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.version\",\
		\"weight\": 1441,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.name\",\
		\"weight\": 1442,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.status\",\
		\"weight\": 1443,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.experimental\",\
		\"weight\": 1444,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.date\",\
		\"weight\": 1445,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.publisher\",\
		\"weight\": 1446,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact\",\
		\"weight\": 1447,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.id\",\
		\"weight\": 1448,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact.extension\",\
		\"weight\": 1449,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.modifierExtension\",\
		\"weight\": 1450,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.name\",\
		\"weight\": 1451,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact.telecom\",\
		\"weight\": 1452,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.description\",\
		\"weight\": 1453,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.useContext\",\
		\"weight\": 1454,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.requirements\",\
		\"weight\": 1455,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.copyright\",\
		\"weight\": 1456,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.kind\",\
		\"weight\": 1457,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software\",\
		\"weight\": 1458,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.id\",\
		\"weight\": 1459,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.extension\",\
		\"weight\": 1460,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.software.modifierExtension\",\
		\"weight\": 1461,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.software.name\",\
		\"weight\": 1462,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.version\",\
		\"weight\": 1463,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.releaseDate\",\
		\"weight\": 1464,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation\",\
		\"weight\": 1465,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.id\",\
		\"weight\": 1466,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.extension\",\
		\"weight\": 1467,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.implementation.modifierExtension\",\
		\"weight\": 1468,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.implementation.description\",\
		\"weight\": 1469,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.url\",\
		\"weight\": 1470,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.fhirVersion\",\
		\"weight\": 1471,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.acceptUnknown\",\
		\"weight\": 1472,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.format\",\
		\"weight\": 1473,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.profile\",\
		\"weight\": 1474,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest\",\
		\"weight\": 1475,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.id\",\
		\"weight\": 1476,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.extension\",\
		\"weight\": 1477,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.modifierExtension\",\
		\"weight\": 1478,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.mode\",\
		\"weight\": 1479,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.documentation\",\
		\"weight\": 1480,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security\",\
		\"weight\": 1481,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.id\",\
		\"weight\": 1482,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.extension\",\
		\"weight\": 1483,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.modifierExtension\",\
		\"weight\": 1484,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.cors\",\
		\"weight\": 1485,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.service\",\
		\"weight\": 1486,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.description\",\
		\"weight\": 1487,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate\",\
		\"weight\": 1488,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.id\",\
		\"weight\": 1489,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.extension\",\
		\"weight\": 1490,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.modifierExtension\",\
		\"weight\": 1491,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.type\",\
		\"weight\": 1492,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.blob\",\
		\"weight\": 1493,\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource\",\
		\"weight\": 1494,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.id\",\
		\"weight\": 1495,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.extension\",\
		\"weight\": 1496,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.modifierExtension\",\
		\"weight\": 1497,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.type\",\
		\"weight\": 1498,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.profile\",\
		\"weight\": 1499,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction\",\
		\"weight\": 1500,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.id\",\
		\"weight\": 1501,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.extension\",\
		\"weight\": 1502,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.modifierExtension\",\
		\"weight\": 1503,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.code\",\
		\"weight\": 1504,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.documentation\",\
		\"weight\": 1505,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.versioning\",\
		\"weight\": 1506,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.readHistory\",\
		\"weight\": 1507,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.updateCreate\",\
		\"weight\": 1508,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalCreate\",\
		\"weight\": 1509,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalUpdate\",\
		\"weight\": 1510,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalDelete\",\
		\"weight\": 1511,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchInclude\",\
		\"weight\": 1512,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchRevInclude\",\
		\"weight\": 1513,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam\",\
		\"weight\": 1514,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.id\",\
		\"weight\": 1515,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.extension\",\
		\"weight\": 1516,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.modifierExtension\",\
		\"weight\": 1517,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.name\",\
		\"weight\": 1518,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.definition\",\
		\"weight\": 1519,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.type\",\
		\"weight\": 1520,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.documentation\",\
		\"weight\": 1521,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.target\",\
		\"weight\": 1522,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.modifier\",\
		\"weight\": 1523,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.chain\",\
		\"weight\": 1524,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction\",\
		\"weight\": 1525,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.id\",\
		\"weight\": 1526,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.extension\",\
		\"weight\": 1527,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.modifierExtension\",\
		\"weight\": 1528,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.code\",\
		\"weight\": 1529,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.documentation\",\
		\"weight\": 1530,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.transactionMode\",\
		\"weight\": 1531,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.searchParam\",\
		\"weight\": 1532,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation\",\
		\"weight\": 1533,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.id\",\
		\"weight\": 1534,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.extension\",\
		\"weight\": 1535,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.modifierExtension\",\
		\"weight\": 1536,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.name\",\
		\"weight\": 1537,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.definition\",\
		\"weight\": 1538,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.compartment\",\
		\"weight\": 1539,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging\",\
		\"weight\": 1540,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.id\",\
		\"weight\": 1541,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.extension\",\
		\"weight\": 1542,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.modifierExtension\",\
		\"weight\": 1543,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint\",\
		\"weight\": 1544,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.id\",\
		\"weight\": 1545,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.extension\",\
		\"weight\": 1546,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.modifierExtension\",\
		\"weight\": 1547,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.protocol\",\
		\"weight\": 1548,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.address\",\
		\"weight\": 1549,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.reliableCache\",\
		\"weight\": 1550,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.documentation\",\
		\"weight\": 1551,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event\",\
		\"weight\": 1552,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.id\",\
		\"weight\": 1553,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.extension\",\
		\"weight\": 1554,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.modifierExtension\",\
		\"weight\": 1555,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.code\",\
		\"weight\": 1556,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.category\",\
		\"weight\": 1557,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.mode\",\
		\"weight\": 1558,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.focus\",\
		\"weight\": 1559,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.request\",\
		\"weight\": 1560,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.response\",\
		\"weight\": 1561,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.documentation\",\
		\"weight\": 1562,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document\",\
		\"weight\": 1563,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.id\",\
		\"weight\": 1564,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.extension\",\
		\"weight\": 1565,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.modifierExtension\",\
		\"weight\": 1566,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.mode\",\
		\"weight\": 1567,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.documentation\",\
		\"weight\": 1568,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.profile\",\
		\"weight\": 1569,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract\",\
		\"weight\": 1570,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.id\",\
		\"weight\": 1571,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.meta\",\
		\"weight\": 1572,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.implicitRules\",\
		\"weight\": 1573,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.language\",\
		\"weight\": 1574,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.text\",\
		\"weight\": 1575,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.contained\",\
		\"weight\": 1576,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.extension\",\
		\"weight\": 1577,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.modifierExtension\",\
		\"weight\": 1578,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.identifier\",\
		\"weight\": 1579,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.issued\",\
		\"weight\": 1580,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.applies\",\
		\"weight\": 1581,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.subject\",\
		\"weight\": 1582,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.topic\",\
		\"weight\": 1583,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.authority\",\
		\"weight\": 1584,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.domain\",\
		\"weight\": 1585,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.type\",\
		\"weight\": 1586,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.subType\",\
		\"weight\": 1587,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.action\",\
		\"weight\": 1588,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.actionReason\",\
		\"weight\": 1589,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent\",\
		\"weight\": 1590,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.id\",\
		\"weight\": 1591,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.agent.extension\",\
		\"weight\": 1592,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.modifierExtension\",\
		\"weight\": 1593,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.actor\",\
		\"weight\": 1594,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.agent.role\",\
		\"weight\": 1595,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer\",\
		\"weight\": 1596,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.id\",\
		\"weight\": 1597,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.extension\",\
		\"weight\": 1598,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.modifierExtension\",\
		\"weight\": 1599,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.type\",\
		\"weight\": 1600,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.party\",\
		\"weight\": 1601,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.signature\",\
		\"weight\": 1602,\
		\"type\": \"Signature\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem\",\
		\"weight\": 1603,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.id\",\
		\"weight\": 1604,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.extension\",\
		\"weight\": 1605,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.modifierExtension\",\
		\"weight\": 1606,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.entityCodeableConcept\",\
		\"weight\": 1607,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.entityReference\",\
		\"weight\": 1607,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.identifier\",\
		\"weight\": 1608,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.effectiveTime\",\
		\"weight\": 1609,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.quantity\",\
		\"weight\": 1610,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.unitPrice\",\
		\"weight\": 1611,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.factor\",\
		\"weight\": 1612,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.points\",\
		\"weight\": 1613,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.net\",\
		\"weight\": 1614,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term\",\
		\"weight\": 1615,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.id\",\
		\"weight\": 1616,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.extension\",\
		\"weight\": 1617,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.modifierExtension\",\
		\"weight\": 1618,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.identifier\",\
		\"weight\": 1619,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.issued\",\
		\"weight\": 1620,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.applies\",\
		\"weight\": 1621,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.type\",\
		\"weight\": 1622,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.subType\",\
		\"weight\": 1623,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.topic\",\
		\"weight\": 1624,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.action\",\
		\"weight\": 1625,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.actionReason\",\
		\"weight\": 1626,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent\",\
		\"weight\": 1627,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.id\",\
		\"weight\": 1628,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.agent.extension\",\
		\"weight\": 1629,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.modifierExtension\",\
		\"weight\": 1630,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.actor\",\
		\"weight\": 1631,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.agent.role\",\
		\"weight\": 1632,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.text\",\
		\"weight\": 1633,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem\",\
		\"weight\": 1634,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.id\",\
		\"weight\": 1635,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.extension\",\
		\"weight\": 1636,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.modifierExtension\",\
		\"weight\": 1637,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.entityCodeableConcept\",\
		\"weight\": 1638,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.entityReference\",\
		\"weight\": 1638,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.identifier\",\
		\"weight\": 1639,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.effectiveTime\",\
		\"weight\": 1640,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.quantity\",\
		\"weight\": 1641,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.unitPrice\",\
		\"weight\": 1642,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.factor\",\
		\"weight\": 1643,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.points\",\
		\"weight\": 1644,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.net\",\
		\"weight\": 1645,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.group\",\
		\"weight\": 1646,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.bindingAttachment\",\
		\"weight\": 1647,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1647,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1647,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"weight\": 1647,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly\",\
		\"weight\": 1648,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.id\",\
		\"weight\": 1649,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.extension\",\
		\"weight\": 1650,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.modifierExtension\",\
		\"weight\": 1651,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentAttachment\",\
		\"weight\": 1652,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1652,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1652,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"weight\": 1652,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal\",\
		\"weight\": 1653,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.id\",\
		\"weight\": 1654,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.extension\",\
		\"weight\": 1655,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.modifierExtension\",\
		\"weight\": 1656,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.contentAttachment\",\
		\"weight\": 1657,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1657,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1657,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"weight\": 1657,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.rule\",\
		\"weight\": 1658,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.id\",\
		\"weight\": 1659,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.rule.extension\",\
		\"weight\": 1660,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.modifierExtension\",\
		\"weight\": 1661,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.contentAttachment\",\
		\"weight\": 1662,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.rule.contentReference\",\
		\"weight\": 1662,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage\",\
		\"weight\": 1663,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.id\",\
		\"weight\": 1664,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.meta\",\
		\"weight\": 1665,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.implicitRules\",\
		\"weight\": 1666,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.language\",\
		\"weight\": 1667,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.text\",\
		\"weight\": 1668,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.contained\",\
		\"weight\": 1669,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.extension\",\
		\"weight\": 1670,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.modifierExtension\",\
		\"weight\": 1671,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.issuerIdentifier\",\
		\"weight\": 1672,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.issuerReference\",\
		\"weight\": 1672,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.bin\",\
		\"weight\": 1673,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.period\",\
		\"weight\": 1674,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.type\",\
		\"weight\": 1675,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.planholderIdentifier\",\
		\"weight\": 1676,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.planholderReference\",\
		\"weight\": 1676,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.planholderReference\",\
		\"weight\": 1676,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.beneficiaryIdentifier\",\
		\"weight\": 1677,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.beneficiaryReference\",\
		\"weight\": 1677,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.relationship\",\
		\"weight\": 1678,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.identifier\",\
		\"weight\": 1679,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.group\",\
		\"weight\": 1680,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.plan\",\
		\"weight\": 1681,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.subPlan\",\
		\"weight\": 1682,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.dependent\",\
		\"weight\": 1683,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.sequence\",\
		\"weight\": 1684,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.exception\",\
		\"weight\": 1685,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.school\",\
		\"weight\": 1686,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.network\",\
		\"weight\": 1687,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.contract\",\
		\"weight\": 1688,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement\",\
		\"weight\": 1689,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.id\",\
		\"weight\": 1690,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.meta\",\
		\"weight\": 1691,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.implicitRules\",\
		\"weight\": 1692,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.language\",\
		\"weight\": 1693,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.text\",\
		\"weight\": 1694,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contained\",\
		\"weight\": 1695,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.extension\",\
		\"weight\": 1696,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.modifierExtension\",\
		\"weight\": 1697,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.url\",\
		\"weight\": 1698,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.identifier\",\
		\"weight\": 1699,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.version\",\
		\"weight\": 1700,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.status\",\
		\"weight\": 1701,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.experimental\",\
		\"weight\": 1702,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.publisher\",\
		\"weight\": 1703,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.date\",\
		\"weight\": 1704,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.name\",\
		\"weight\": 1705,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact\",\
		\"weight\": 1706,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.id\",\
		\"weight\": 1707,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact.extension\",\
		\"weight\": 1708,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.modifierExtension\",\
		\"weight\": 1709,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.name\",\
		\"weight\": 1710,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact.telecom\",\
		\"weight\": 1711,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.useContext\",\
		\"weight\": 1712,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.copyright\",\
		\"weight\": 1713,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.stringency\",\
		\"weight\": 1714,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping\",\
		\"weight\": 1715,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.id\",\
		\"weight\": 1716,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.extension\",\
		\"weight\": 1717,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.modifierExtension\",\
		\"weight\": 1718,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.identity\",\
		\"weight\": 1719,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.uri\",\
		\"weight\": 1720,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.name\",\
		\"weight\": 1721,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.comment\",\
		\"weight\": 1722,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.element\",\
		\"weight\": 1723,\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule\",\
		\"weight\": 1724,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.id\",\
		\"weight\": 1725,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.meta\",\
		\"weight\": 1726,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.implicitRules\",\
		\"weight\": 1727,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.language\",\
		\"weight\": 1728,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.text\",\
		\"weight\": 1729,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.contained\",\
		\"weight\": 1730,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.extension\",\
		\"weight\": 1731,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.modifierExtension\",\
		\"weight\": 1732,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.moduleMetadata\",\
		\"weight\": 1733,\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.library\",\
		\"weight\": 1734,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.trigger\",\
		\"weight\": 1735,\
		\"type\": \"TriggerDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.condition\",\
		\"weight\": 1736,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.action\",\
		\"weight\": 1737,\
		\"type\": \"ActionDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule\",\
		\"weight\": 1738,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.id\",\
		\"weight\": 1739,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.meta\",\
		\"weight\": 1740,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.implicitRules\",\
		\"weight\": 1741,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.language\",\
		\"weight\": 1742,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.text\",\
		\"weight\": 1743,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.contained\",\
		\"weight\": 1744,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.extension\",\
		\"weight\": 1745,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.modifierExtension\",\
		\"weight\": 1746,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.moduleMetadata\",\
		\"weight\": 1747,\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.trigger\",\
		\"weight\": 1748,\
		\"type\": \"TriggerDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.parameter\",\
		\"weight\": 1749,\
		\"type\": \"ParameterDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.dataRequirement\",\
		\"weight\": 1750,\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue\",\
		\"weight\": 1751,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.id\",\
		\"weight\": 1752,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.meta\",\
		\"weight\": 1753,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.implicitRules\",\
		\"weight\": 1754,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.language\",\
		\"weight\": 1755,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.text\",\
		\"weight\": 1756,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.contained\",\
		\"weight\": 1757,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.extension\",\
		\"weight\": 1758,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.modifierExtension\",\
		\"weight\": 1759,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.patient\",\
		\"weight\": 1760,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.category\",\
		\"weight\": 1761,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.severity\",\
		\"weight\": 1762,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.implicated\",\
		\"weight\": 1763,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.detail\",\
		\"weight\": 1764,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.date\",\
		\"weight\": 1765,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.author\",\
		\"weight\": 1766,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.identifier\",\
		\"weight\": 1767,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.reference\",\
		\"weight\": 1768,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation\",\
		\"weight\": 1769,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.id\",\
		\"weight\": 1770,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.extension\",\
		\"weight\": 1771,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.modifierExtension\",\
		\"weight\": 1772,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.action\",\
		\"weight\": 1773,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.date\",\
		\"weight\": 1774,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.author\",\
		\"weight\": 1775,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device\",\
		\"weight\": 1776,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.id\",\
		\"weight\": 1777,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.meta\",\
		\"weight\": 1778,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.implicitRules\",\
		\"weight\": 1779,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.language\",\
		\"weight\": 1780,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.text\",\
		\"weight\": 1781,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.contained\",\
		\"weight\": 1782,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.extension\",\
		\"weight\": 1783,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.modifierExtension\",\
		\"weight\": 1784,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.identifier\",\
		\"weight\": 1785,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.udiCarrier\",\
		\"weight\": 1786,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.status\",\
		\"weight\": 1787,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.type\",\
		\"weight\": 1788,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.lotNumber\",\
		\"weight\": 1789,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.manufacturer\",\
		\"weight\": 1790,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.manufactureDate\",\
		\"weight\": 1791,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.expirationDate\",\
		\"weight\": 1792,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.model\",\
		\"weight\": 1793,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.version\",\
		\"weight\": 1794,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.patient\",\
		\"weight\": 1795,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.owner\",\
		\"weight\": 1796,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.contact\",\
		\"weight\": 1797,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.location\",\
		\"weight\": 1798,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.url\",\
		\"weight\": 1799,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.note\",\
		\"weight\": 1800,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent\",\
		\"weight\": 1801,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.id\",\
		\"weight\": 1802,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.meta\",\
		\"weight\": 1803,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.implicitRules\",\
		\"weight\": 1804,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.language\",\
		\"weight\": 1805,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.text\",\
		\"weight\": 1806,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.contained\",\
		\"weight\": 1807,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.extension\",\
		\"weight\": 1808,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.modifierExtension\",\
		\"weight\": 1809,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.type\",\
		\"weight\": 1810,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.identifier\",\
		\"weight\": 1811,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.lastSystemChange\",\
		\"weight\": 1812,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.source\",\
		\"weight\": 1813,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.parent\",\
		\"weight\": 1814,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.operationalStatus\",\
		\"weight\": 1815,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.parameterGroup\",\
		\"weight\": 1816,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.measurementPrinciple\",\
		\"weight\": 1817,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification\",\
		\"weight\": 1818,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.id\",\
		\"weight\": 1819,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.extension\",\
		\"weight\": 1820,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.modifierExtension\",\
		\"weight\": 1821,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.specType\",\
		\"weight\": 1822,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.componentId\",\
		\"weight\": 1823,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.productionSpec\",\
		\"weight\": 1824,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.languageCode\",\
		\"weight\": 1825,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric\",\
		\"weight\": 1826,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.id\",\
		\"weight\": 1827,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.meta\",\
		\"weight\": 1828,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.implicitRules\",\
		\"weight\": 1829,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.language\",\
		\"weight\": 1830,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.text\",\
		\"weight\": 1831,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.contained\",\
		\"weight\": 1832,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.extension\",\
		\"weight\": 1833,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.modifierExtension\",\
		\"weight\": 1834,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.type\",\
		\"weight\": 1835,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.identifier\",\
		\"weight\": 1836,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.unit\",\
		\"weight\": 1837,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.source\",\
		\"weight\": 1838,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.parent\",\
		\"weight\": 1839,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.operationalStatus\",\
		\"weight\": 1840,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.color\",\
		\"weight\": 1841,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.category\",\
		\"weight\": 1842,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.measurementPeriod\",\
		\"weight\": 1843,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration\",\
		\"weight\": 1844,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.id\",\
		\"weight\": 1845,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.extension\",\
		\"weight\": 1846,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.modifierExtension\",\
		\"weight\": 1847,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.type\",\
		\"weight\": 1848,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.state\",\
		\"weight\": 1849,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.time\",\
		\"weight\": 1850,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest\",\
		\"weight\": 1851,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.id\",\
		\"weight\": 1852,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.meta\",\
		\"weight\": 1853,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.implicitRules\",\
		\"weight\": 1854,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.language\",\
		\"weight\": 1855,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.text\",\
		\"weight\": 1856,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.contained\",\
		\"weight\": 1857,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.extension\",\
		\"weight\": 1858,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.modifierExtension\",\
		\"weight\": 1859,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.bodySiteCodeableConcept\",\
		\"weight\": 1860,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.bodySiteReference\",\
		\"weight\": 1860,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.status\",\
		\"weight\": 1861,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.device\",\
		\"weight\": 1862,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.encounter\",\
		\"weight\": 1863,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.identifier\",\
		\"weight\": 1864,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.indication\",\
		\"weight\": 1865,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.notes\",\
		\"weight\": 1866,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.prnReason\",\
		\"weight\": 1867,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.orderedOn\",\
		\"weight\": 1868,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.recordedOn\",\
		\"weight\": 1869,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.subject\",\
		\"weight\": 1870,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.timingTiming\",\
		\"weight\": 1871,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.timingPeriod\",\
		\"weight\": 1871,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.timingDateTime\",\
		\"weight\": 1871,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.priority\",\
		\"weight\": 1872,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement\",\
		\"weight\": 1873,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.id\",\
		\"weight\": 1874,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.meta\",\
		\"weight\": 1875,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.implicitRules\",\
		\"weight\": 1876,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.language\",\
		\"weight\": 1877,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.text\",\
		\"weight\": 1878,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.contained\",\
		\"weight\": 1879,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.extension\",\
		\"weight\": 1880,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.modifierExtension\",\
		\"weight\": 1881,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.bodySiteCodeableConcept\",\
		\"weight\": 1882,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.bodySiteReference\",\
		\"weight\": 1882,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.whenUsed\",\
		\"weight\": 1883,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.device\",\
		\"weight\": 1884,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.identifier\",\
		\"weight\": 1885,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.indication\",\
		\"weight\": 1886,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.notes\",\
		\"weight\": 1887,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.recordedOn\",\
		\"weight\": 1888,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.subject\",\
		\"weight\": 1889,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingTiming\",\
		\"weight\": 1890,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingPeriod\",\
		\"weight\": 1890,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingDateTime\",\
		\"weight\": 1890,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder\",\
		\"weight\": 1891,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.id\",\
		\"weight\": 1892,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.meta\",\
		\"weight\": 1893,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.implicitRules\",\
		\"weight\": 1894,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.language\",\
		\"weight\": 1895,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.text\",\
		\"weight\": 1896,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.contained\",\
		\"weight\": 1897,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.extension\",\
		\"weight\": 1898,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.modifierExtension\",\
		\"weight\": 1899,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.identifier\",\
		\"weight\": 1900,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.status\",\
		\"weight\": 1901,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.priority\",\
		\"weight\": 1902,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.subject\",\
		\"weight\": 1903,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.encounter\",\
		\"weight\": 1904,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.orderer\",\
		\"weight\": 1905,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.reason\",\
		\"weight\": 1906,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.supportingInformation\",\
		\"weight\": 1907,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.specimen\",\
		\"weight\": 1908,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event\",\
		\"weight\": 1909,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.id\",\
		\"weight\": 1910,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.extension\",\
		\"weight\": 1911,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.modifierExtension\",\
		\"weight\": 1912,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.status\",\
		\"weight\": 1913,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.description\",\
		\"weight\": 1914,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.dateTime\",\
		\"weight\": 1915,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.actor\",\
		\"weight\": 1916,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item\",\
		\"weight\": 1917,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.id\",\
		\"weight\": 1918,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.extension\",\
		\"weight\": 1919,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.modifierExtension\",\
		\"weight\": 1920,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.code\",\
		\"weight\": 1921,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.specimen\",\
		\"weight\": 1922,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.bodySite\",\
		\"weight\": 1923,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.status\",\
		\"weight\": 1924,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.event\",\
		\"weight\": 1925,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.note\",\
		\"weight\": 1926,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport\",\
		\"weight\": 1927,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.id\",\
		\"weight\": 1928,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.meta\",\
		\"weight\": 1929,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.implicitRules\",\
		\"weight\": 1930,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.language\",\
		\"weight\": 1931,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.text\",\
		\"weight\": 1932,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.contained\",\
		\"weight\": 1933,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.extension\",\
		\"weight\": 1934,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.modifierExtension\",\
		\"weight\": 1935,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.identifier\",\
		\"weight\": 1936,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.status\",\
		\"weight\": 1937,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.category\",\
		\"weight\": 1938,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.code\",\
		\"weight\": 1939,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.subject\",\
		\"weight\": 1940,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.encounter\",\
		\"weight\": 1941,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.effectiveDateTime\",\
		\"weight\": 1942,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.effectivePeriod\",\
		\"weight\": 1942,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.issued\",\
		\"weight\": 1943,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.performer\",\
		\"weight\": 1944,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.request\",\
		\"weight\": 1945,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.specimen\",\
		\"weight\": 1946,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.result\",\
		\"weight\": 1947,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.imagingStudy\",\
		\"weight\": 1948,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image\",\
		\"weight\": 1949,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.id\",\
		\"weight\": 1950,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.extension\",\
		\"weight\": 1951,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.modifierExtension\",\
		\"weight\": 1952,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.comment\",\
		\"weight\": 1953,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.link\",\
		\"weight\": 1954,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.conclusion\",\
		\"weight\": 1955,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.codedDiagnosis\",\
		\"weight\": 1956,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.presentedForm\",\
		\"weight\": 1957,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest\",\
		\"weight\": 1958,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.id\",\
		\"weight\": 1959,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.meta\",\
		\"weight\": 1960,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.implicitRules\",\
		\"weight\": 1961,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.language\",\
		\"weight\": 1962,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.text\",\
		\"weight\": 1963,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.contained\",\
		\"weight\": 1964,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.extension\",\
		\"weight\": 1965,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.modifierExtension\",\
		\"weight\": 1966,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.masterIdentifier\",\
		\"weight\": 1967,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.identifier\",\
		\"weight\": 1968,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.subject\",\
		\"weight\": 1969,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.recipient\",\
		\"weight\": 1970,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.type\",\
		\"weight\": 1971,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.author\",\
		\"weight\": 1972,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.created\",\
		\"weight\": 1973,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.source\",\
		\"weight\": 1974,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.status\",\
		\"weight\": 1975,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.description\",\
		\"weight\": 1976,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.content\",\
		\"weight\": 1977,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.id\",\
		\"weight\": 1978,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.extension\",\
		\"weight\": 1979,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.modifierExtension\",\
		\"weight\": 1980,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.pAttachment\",\
		\"weight\": 1981,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.pReference\",\
		\"weight\": 1981,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.related\",\
		\"weight\": 1982,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.id\",\
		\"weight\": 1983,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.extension\",\
		\"weight\": 1984,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.modifierExtension\",\
		\"weight\": 1985,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.identifier\",\
		\"weight\": 1986,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.ref\",\
		\"weight\": 1987,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference\",\
		\"weight\": 1988,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.id\",\
		\"weight\": 1989,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.meta\",\
		\"weight\": 1990,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.implicitRules\",\
		\"weight\": 1991,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.language\",\
		\"weight\": 1992,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.text\",\
		\"weight\": 1993,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.contained\",\
		\"weight\": 1994,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.extension\",\
		\"weight\": 1995,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.modifierExtension\",\
		\"weight\": 1996,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.masterIdentifier\",\
		\"weight\": 1997,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.identifier\",\
		\"weight\": 1998,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.subject\",\
		\"weight\": 1999,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.type\",\
		\"weight\": 2000,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.class\",\
		\"weight\": 2001,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.author\",\
		\"weight\": 2002,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.custodian\",\
		\"weight\": 2003,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.authenticator\",\
		\"weight\": 2004,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.created\",\
		\"weight\": 2005,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.indexed\",\
		\"weight\": 2006,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.status\",\
		\"weight\": 2007,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.docStatus\",\
		\"weight\": 2008,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo\",\
		\"weight\": 2009,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.id\",\
		\"weight\": 2010,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.extension\",\
		\"weight\": 2011,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.modifierExtension\",\
		\"weight\": 2012,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.code\",\
		\"weight\": 2013,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.target\",\
		\"weight\": 2014,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.description\",\
		\"weight\": 2015,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.securityLabel\",\
		\"weight\": 2016,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content\",\
		\"weight\": 2017,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.id\",\
		\"weight\": 2018,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.content.extension\",\
		\"weight\": 2019,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.modifierExtension\",\
		\"weight\": 2020,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.attachment\",\
		\"weight\": 2021,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.content.format\",\
		\"weight\": 2022,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context\",\
		\"weight\": 2023,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.id\",\
		\"weight\": 2024,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.extension\",\
		\"weight\": 2025,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.modifierExtension\",\
		\"weight\": 2026,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.encounter\",\
		\"weight\": 2027,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.event\",\
		\"weight\": 2028,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.period\",\
		\"weight\": 2029,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.facilityType\",\
		\"weight\": 2030,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.practiceSetting\",\
		\"weight\": 2031,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.sourcePatientInfo\",\
		\"weight\": 2032,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related\",\
		\"weight\": 2033,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.id\",\
		\"weight\": 2034,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.extension\",\
		\"weight\": 2035,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.modifierExtension\",\
		\"weight\": 2036,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.identifier\",\
		\"weight\": 2037,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.ref\",\
		\"weight\": 2038,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest\",\
		\"weight\": 2039,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.id\",\
		\"weight\": 2040,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.meta\",\
		\"weight\": 2041,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.implicitRules\",\
		\"weight\": 2042,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.language\",\
		\"weight\": 2043,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.text\",\
		\"weight\": 2044,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.contained\",\
		\"weight\": 2045,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.extension\",\
		\"weight\": 2046,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.modifierExtension\",\
		\"weight\": 2047,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.identifier\",\
		\"weight\": 2048,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.ruleset\",\
		\"weight\": 2049,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.originalRuleset\",\
		\"weight\": 2050,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.created\",\
		\"weight\": 2051,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.targetIdentifier\",\
		\"weight\": 2052,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.targetReference\",\
		\"weight\": 2052,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.providerIdentifier\",\
		\"weight\": 2053,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.providerReference\",\
		\"weight\": 2053,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.organizationIdentifier\",\
		\"weight\": 2054,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.organizationReference\",\
		\"weight\": 2054,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.priority\",\
		\"weight\": 2055,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.entererIdentifier\",\
		\"weight\": 2056,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.entererReference\",\
		\"weight\": 2056,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.facilityIdentifier\",\
		\"weight\": 2057,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.facilityReference\",\
		\"weight\": 2057,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.patientIdentifier\",\
		\"weight\": 2058,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.patientReference\",\
		\"weight\": 2058,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.coverageIdentifier\",\
		\"weight\": 2059,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.coverageReference\",\
		\"weight\": 2059,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.businessArrangement\",\
		\"weight\": 2060,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.servicedDate\",\
		\"weight\": 2061,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.servicedPeriod\",\
		\"weight\": 2061,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.benefitCategory\",\
		\"weight\": 2062,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.benefitSubCategory\",\
		\"weight\": 2063,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse\",\
		\"weight\": 2064,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.id\",\
		\"weight\": 2065,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.meta\",\
		\"weight\": 2066,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.implicitRules\",\
		\"weight\": 2067,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.language\",\
		\"weight\": 2068,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.text\",\
		\"weight\": 2069,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.contained\",\
		\"weight\": 2070,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.extension\",\
		\"weight\": 2071,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.modifierExtension\",\
		\"weight\": 2072,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.identifier\",\
		\"weight\": 2073,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestIdentifier\",\
		\"weight\": 2074,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestReference\",\
		\"weight\": 2074,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.outcome\",\
		\"weight\": 2075,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.disposition\",\
		\"weight\": 2076,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.ruleset\",\
		\"weight\": 2077,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.originalRuleset\",\
		\"weight\": 2078,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.created\",\
		\"weight\": 2079,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.organizationIdentifier\",\
		\"weight\": 2080,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.organizationReference\",\
		\"weight\": 2080,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestProviderIdentifier\",\
		\"weight\": 2081,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestProviderReference\",\
		\"weight\": 2081,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestOrganizationIdentifier\",\
		\"weight\": 2082,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestOrganizationReference\",\
		\"weight\": 2082,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.inforce\",\
		\"weight\": 2083,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.contract\",\
		\"weight\": 2084,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.form\",\
		\"weight\": 2085,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance\",\
		\"weight\": 2086,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.id\",\
		\"weight\": 2087,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.extension\",\
		\"weight\": 2088,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.modifierExtension\",\
		\"weight\": 2089,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.category\",\
		\"weight\": 2090,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.subCategory\",\
		\"weight\": 2091,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.network\",\
		\"weight\": 2092,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.unit\",\
		\"weight\": 2093,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.term\",\
		\"weight\": 2094,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial\",\
		\"weight\": 2095,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.id\",\
		\"weight\": 2096,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.extension\",\
		\"weight\": 2097,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.modifierExtension\",\
		\"weight\": 2098,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.type\",\
		\"weight\": 2099,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUnsignedInt\",\
		\"weight\": 2100,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitQuantity\",\
		\"weight\": 2100,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUsedUnsignedInt\",\
		\"weight\": 2101,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUsedQuantity\",\
		\"weight\": 2101,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error\",\
		\"weight\": 2102,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.id\",\
		\"weight\": 2103,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.extension\",\
		\"weight\": 2104,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.modifierExtension\",\
		\"weight\": 2105,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.code\",\
		\"weight\": 2106,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter\",\
		\"weight\": 2107,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.id\",\
		\"weight\": 2108,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.meta\",\
		\"weight\": 2109,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.implicitRules\",\
		\"weight\": 2110,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.language\",\
		\"weight\": 2111,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.text\",\
		\"weight\": 2112,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.contained\",\
		\"weight\": 2113,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.extension\",\
		\"weight\": 2114,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.modifierExtension\",\
		\"weight\": 2115,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.identifier\",\
		\"weight\": 2116,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.status\",\
		\"weight\": 2117,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory\",\
		\"weight\": 2118,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.id\",\
		\"weight\": 2119,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.extension\",\
		\"weight\": 2120,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.modifierExtension\",\
		\"weight\": 2121,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.status\",\
		\"weight\": 2122,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.period\",\
		\"weight\": 2123,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.class\",\
		\"weight\": 2124,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.type\",\
		\"weight\": 2125,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.priority\",\
		\"weight\": 2126,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.patient\",\
		\"weight\": 2127,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.episodeOfCare\",\
		\"weight\": 2128,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.incomingReferral\",\
		\"weight\": 2129,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant\",\
		\"weight\": 2130,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.id\",\
		\"weight\": 2131,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.participant.extension\",\
		\"weight\": 2132,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.modifierExtension\",\
		\"weight\": 2133,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.type\",\
		\"weight\": 2134,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.period\",\
		\"weight\": 2135,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.participant.individual\",\
		\"weight\": 2136,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.appointment\",\
		\"weight\": 2137,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.period\",\
		\"weight\": 2138,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.length\",\
		\"weight\": 2139,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.reason\",\
		\"weight\": 2140,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.indication\",\
		\"weight\": 2141,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization\",\
		\"weight\": 2142,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.id\",\
		\"weight\": 2143,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.extension\",\
		\"weight\": 2144,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.modifierExtension\",\
		\"weight\": 2145,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.preAdmissionIdentifier\",\
		\"weight\": 2146,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.origin\",\
		\"weight\": 2147,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.admitSource\",\
		\"weight\": 2148,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.admittingDiagnosis\",\
		\"weight\": 2149,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.reAdmission\",\
		\"weight\": 2150,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dietPreference\",\
		\"weight\": 2151,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.specialCourtesy\",\
		\"weight\": 2152,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.specialArrangement\",\
		\"weight\": 2153,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.destination\",\
		\"weight\": 2154,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dischargeDisposition\",\
		\"weight\": 2155,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dischargeDiagnosis\",\
		\"weight\": 2156,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location\",\
		\"weight\": 2157,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.id\",\
		\"weight\": 2158,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.extension\",\
		\"weight\": 2159,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.modifierExtension\",\
		\"weight\": 2160,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.location\",\
		\"weight\": 2161,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.status\",\
		\"weight\": 2162,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.period\",\
		\"weight\": 2163,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.serviceProvider\",\
		\"weight\": 2164,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.partOf\",\
		\"weight\": 2165,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint\",\
		\"weight\": 2166,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.id\",\
		\"weight\": 2167,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.meta\",\
		\"weight\": 2168,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.implicitRules\",\
		\"weight\": 2169,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.language\",\
		\"weight\": 2170,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.text\",\
		\"weight\": 2171,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.contained\",\
		\"weight\": 2172,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.extension\",\
		\"weight\": 2173,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.modifierExtension\",\
		\"weight\": 2174,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.status\",\
		\"weight\": 2175,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.managingOrganization\",\
		\"weight\": 2176,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.contact\",\
		\"weight\": 2177,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.connectionType\",\
		\"weight\": 2178,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.method\",\
		\"weight\": 2179,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.period\",\
		\"weight\": 2180,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.addressUri\",\
		\"weight\": 2181,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.addressString\",\
		\"weight\": 2181,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.payloadFormat\",\
		\"weight\": 2182,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.payloadType\",\
		\"weight\": 2183,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.header\",\
		\"weight\": 2184,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.publicKey\",\
		\"weight\": 2185,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest\",\
		\"weight\": 2186,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.id\",\
		\"weight\": 2187,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.meta\",\
		\"weight\": 2188,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.implicitRules\",\
		\"weight\": 2189,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.language\",\
		\"weight\": 2190,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.text\",\
		\"weight\": 2191,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.contained\",\
		\"weight\": 2192,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.extension\",\
		\"weight\": 2193,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.modifierExtension\",\
		\"weight\": 2194,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.identifier\",\
		\"weight\": 2195,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.ruleset\",\
		\"weight\": 2196,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.originalRuleset\",\
		\"weight\": 2197,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.created\",\
		\"weight\": 2198,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.target\",\
		\"weight\": 2199,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.provider\",\
		\"weight\": 2200,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.organization\",\
		\"weight\": 2201,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.subject\",\
		\"weight\": 2202,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.coverage\",\
		\"weight\": 2203,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.relationship\",\
		\"weight\": 2204,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse\",\
		\"weight\": 2205,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.id\",\
		\"weight\": 2206,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.meta\",\
		\"weight\": 2207,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.implicitRules\",\
		\"weight\": 2208,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.language\",\
		\"weight\": 2209,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.text\",\
		\"weight\": 2210,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.contained\",\
		\"weight\": 2211,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.extension\",\
		\"weight\": 2212,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.modifierExtension\",\
		\"weight\": 2213,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.identifier\",\
		\"weight\": 2214,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.request\",\
		\"weight\": 2215,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.outcome\",\
		\"weight\": 2216,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.disposition\",\
		\"weight\": 2217,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.ruleset\",\
		\"weight\": 2218,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.originalRuleset\",\
		\"weight\": 2219,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.created\",\
		\"weight\": 2220,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.organization\",\
		\"weight\": 2221,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestProvider\",\
		\"weight\": 2222,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestOrganization\",\
		\"weight\": 2223,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare\",\
		\"weight\": 2224,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.id\",\
		\"weight\": 2225,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.meta\",\
		\"weight\": 2226,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.implicitRules\",\
		\"weight\": 2227,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.language\",\
		\"weight\": 2228,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.text\",\
		\"weight\": 2229,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.contained\",\
		\"weight\": 2230,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.extension\",\
		\"weight\": 2231,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.modifierExtension\",\
		\"weight\": 2232,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.identifier\",\
		\"weight\": 2233,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.status\",\
		\"weight\": 2234,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory\",\
		\"weight\": 2235,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.id\",\
		\"weight\": 2236,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.extension\",\
		\"weight\": 2237,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.modifierExtension\",\
		\"weight\": 2238,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.status\",\
		\"weight\": 2239,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.period\",\
		\"weight\": 2240,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.type\",\
		\"weight\": 2241,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.condition\",\
		\"weight\": 2242,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.patient\",\
		\"weight\": 2243,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.managingOrganization\",\
		\"weight\": 2244,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.period\",\
		\"weight\": 2245,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.referralRequest\",\
		\"weight\": 2246,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.careManager\",\
		\"weight\": 2247,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.team\",\
		\"weight\": 2248,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile\",\
		\"weight\": 2249,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.id\",\
		\"weight\": 2250,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.meta\",\
		\"weight\": 2251,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.implicitRules\",\
		\"weight\": 2252,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.language\",\
		\"weight\": 2253,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.text\",\
		\"weight\": 2254,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contained\",\
		\"weight\": 2255,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.extension\",\
		\"weight\": 2256,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.modifierExtension\",\
		\"weight\": 2257,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.url\",\
		\"weight\": 2258,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.identifier\",\
		\"weight\": 2259,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.version\",\
		\"weight\": 2260,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.name\",\
		\"weight\": 2261,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.status\",\
		\"weight\": 2262,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.experimental\",\
		\"weight\": 2263,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.publisher\",\
		\"weight\": 2264,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact\",\
		\"weight\": 2265,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.id\",\
		\"weight\": 2266,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.extension\",\
		\"weight\": 2267,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.modifierExtension\",\
		\"weight\": 2268,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.name\",\
		\"weight\": 2269,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.telecom\",\
		\"weight\": 2270,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.date\",\
		\"weight\": 2271,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.description\",\
		\"weight\": 2272,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem\",\
		\"weight\": 2273,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.id\",\
		\"weight\": 2274,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.extension\",\
		\"weight\": 2275,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.modifierExtension\",\
		\"weight\": 2276,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include\",\
		\"weight\": 2277,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.id\",\
		\"weight\": 2278,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.extension\",\
		\"weight\": 2279,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.modifierExtension\",\
		\"weight\": 2280,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem\",\
		\"weight\": 2281,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.id\",\
		\"weight\": 2282,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.extension\",\
		\"weight\": 2283,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.modifierExtension\",\
		\"weight\": 2284,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.system\",\
		\"weight\": 2285,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.version\",\
		\"weight\": 2286,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude\",\
		\"weight\": 2287,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.id\",\
		\"weight\": 2288,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.extension\",\
		\"weight\": 2289,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.modifierExtension\",\
		\"weight\": 2290,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem\",\
		\"weight\": 2291,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.id\",\
		\"weight\": 2292,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.extension\",\
		\"weight\": 2293,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.modifierExtension\",\
		\"weight\": 2294,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.system\",\
		\"weight\": 2295,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.version\",\
		\"weight\": 2296,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeDesignations\",\
		\"weight\": 2297,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation\",\
		\"weight\": 2298,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.id\",\
		\"weight\": 2299,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.extension\",\
		\"weight\": 2300,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.modifierExtension\",\
		\"weight\": 2301,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include\",\
		\"weight\": 2302,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.id\",\
		\"weight\": 2303,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.extension\",\
		\"weight\": 2304,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.modifierExtension\",\
		\"weight\": 2305,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation\",\
		\"weight\": 2306,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.id\",\
		\"weight\": 2307,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.extension\",\
		\"weight\": 2308,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.modifierExtension\",\
		\"weight\": 2309,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.language\",\
		\"weight\": 2310,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.use\",\
		\"weight\": 2311,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude\",\
		\"weight\": 2312,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.id\",\
		\"weight\": 2313,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.extension\",\
		\"weight\": 2314,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.modifierExtension\",\
		\"weight\": 2315,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation\",\
		\"weight\": 2316,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.id\",\
		\"weight\": 2317,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.extension\",\
		\"weight\": 2318,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.modifierExtension\",\
		\"weight\": 2319,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.language\",\
		\"weight\": 2320,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.use\",\
		\"weight\": 2321,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeDefinition\",\
		\"weight\": 2322,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeInactive\",\
		\"weight\": 2323,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludeNested\",\
		\"weight\": 2324,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludeNotForUI\",\
		\"weight\": 2325,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludePostCoordinated\",\
		\"weight\": 2326,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.displayLanguage\",\
		\"weight\": 2327,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.limitedExpansion\",\
		\"weight\": 2328,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit\",\
		\"weight\": 2329,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.id\",\
		\"weight\": 2330,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.meta\",\
		\"weight\": 2331,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.implicitRules\",\
		\"weight\": 2332,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.language\",\
		\"weight\": 2333,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.text\",\
		\"weight\": 2334,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.contained\",\
		\"weight\": 2335,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.extension\",\
		\"weight\": 2336,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.modifierExtension\",\
		\"weight\": 2337,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.identifier\",\
		\"weight\": 2338,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimIdentifier\",\
		\"weight\": 2339,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimReference\",\
		\"weight\": 2339,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimResponseIdentifier\",\
		\"weight\": 2340,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimResponseReference\",\
		\"weight\": 2340,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.subType\",\
		\"weight\": 2341,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.ruleset\",\
		\"weight\": 2342,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalRuleset\",\
		\"weight\": 2343,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.created\",\
		\"weight\": 2344,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.billablePeriod\",\
		\"weight\": 2345,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.disposition\",\
		\"weight\": 2346,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.providerIdentifier\",\
		\"weight\": 2347,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.providerReference\",\
		\"weight\": 2347,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.organizationIdentifier\",\
		\"weight\": 2348,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.organizationReference\",\
		\"weight\": 2348,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.facilityIdentifier\",\
		\"weight\": 2349,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.facilityReference\",\
		\"weight\": 2349,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related\",\
		\"weight\": 2350,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.id\",\
		\"weight\": 2351,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.extension\",\
		\"weight\": 2352,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.modifierExtension\",\
		\"weight\": 2353,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.claimIdentifier\",\
		\"weight\": 2354,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.claimReference\",\
		\"weight\": 2354,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.relationship\",\
		\"weight\": 2355,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.reference\",\
		\"weight\": 2356,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionIdentifier\",\
		\"weight\": 2357,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionReference\",\
		\"weight\": 2357,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionReference\",\
		\"weight\": 2357,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalPrescriptionIdentifier\",\
		\"weight\": 2358,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalPrescriptionReference\",\
		\"weight\": 2358,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee\",\
		\"weight\": 2359,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.id\",\
		\"weight\": 2360,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.extension\",\
		\"weight\": 2361,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.modifierExtension\",\
		\"weight\": 2362,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.type\",\
		\"weight\": 2363,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyIdentifier\",\
		\"weight\": 2364,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2364,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2364,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2364,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"weight\": 2364,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.referralIdentifier\",\
		\"weight\": 2365,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.referralReference\",\
		\"weight\": 2365,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.occurrenceCode\",\
		\"weight\": 2366,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.occurenceSpanCode\",\
		\"weight\": 2367,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.valueCode\",\
		\"weight\": 2368,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis\",\
		\"weight\": 2369,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.id\",\
		\"weight\": 2370,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.extension\",\
		\"weight\": 2371,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.modifierExtension\",\
		\"weight\": 2372,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.sequence\",\
		\"weight\": 2373,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.diagnosis\",\
		\"weight\": 2374,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure\",\
		\"weight\": 2375,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.id\",\
		\"weight\": 2376,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.extension\",\
		\"weight\": 2377,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.modifierExtension\",\
		\"weight\": 2378,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.sequence\",\
		\"weight\": 2379,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.date\",\
		\"weight\": 2380,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.procedureCoding\",\
		\"weight\": 2381,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.procedureReference\",\
		\"weight\": 2381,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.specialCondition\",\
		\"weight\": 2382,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.patientIdentifier\",\
		\"weight\": 2383,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.patientReference\",\
		\"weight\": 2383,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.precedence\",\
		\"weight\": 2384,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage\",\
		\"weight\": 2385,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.id\",\
		\"weight\": 2386,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.extension\",\
		\"weight\": 2387,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.modifierExtension\",\
		\"weight\": 2388,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.coverageIdentifier\",\
		\"weight\": 2389,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.coverageReference\",\
		\"weight\": 2389,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.preAuthRef\",\
		\"weight\": 2390,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accidentDate\",\
		\"weight\": 2391,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accidentType\",\
		\"weight\": 2392,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accidentLocationAddress\",\
		\"weight\": 2393,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accidentLocationReference\",\
		\"weight\": 2393,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.interventionException\",\
		\"weight\": 2394,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset\",\
		\"weight\": 2395,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.id\",\
		\"weight\": 2396,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.extension\",\
		\"weight\": 2397,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.modifierExtension\",\
		\"weight\": 2398,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.timeDate\",\
		\"weight\": 2399,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.timePeriod\",\
		\"weight\": 2399,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.type\",\
		\"weight\": 2400,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.employmentImpacted\",\
		\"weight\": 2401,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.hospitalization\",\
		\"weight\": 2402,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item\",\
		\"weight\": 2403,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.id\",\
		\"weight\": 2404,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.extension\",\
		\"weight\": 2405,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.modifierExtension\",\
		\"weight\": 2406,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.sequence\",\
		\"weight\": 2407,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.type\",\
		\"weight\": 2408,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.providerIdentifier\",\
		\"weight\": 2409,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.providerReference\",\
		\"weight\": 2409,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.supervisorIdentifier\",\
		\"weight\": 2410,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.supervisorReference\",\
		\"weight\": 2410,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.providerQualification\",\
		\"weight\": 2411,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.diagnosisLinkId\",\
		\"weight\": 2412,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.service\",\
		\"weight\": 2413,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.serviceModifier\",\
		\"weight\": 2414,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.modifier\",\
		\"weight\": 2415,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.programCode\",\
		\"weight\": 2416,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.servicedDate\",\
		\"weight\": 2417,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.servicedPeriod\",\
		\"weight\": 2417,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.place\",\
		\"weight\": 2418,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.quantity\",\
		\"weight\": 2419,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.unitPrice\",\
		\"weight\": 2420,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.factor\",\
		\"weight\": 2421,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.points\",\
		\"weight\": 2422,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.net\",\
		\"weight\": 2423,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.udi\",\
		\"weight\": 2424,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.bodySite\",\
		\"weight\": 2425,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.subSite\",\
		\"weight\": 2426,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.noteNumber\",\
		\"weight\": 2427,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication\",\
		\"weight\": 2428,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.id\",\
		\"weight\": 2429,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.extension\",\
		\"weight\": 2430,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.modifierExtension\",\
		\"weight\": 2431,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.category\",\
		\"weight\": 2432,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.reason\",\
		\"weight\": 2433,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.amount\",\
		\"weight\": 2434,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.value\",\
		\"weight\": 2435,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail\",\
		\"weight\": 2436,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.id\",\
		\"weight\": 2437,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.extension\",\
		\"weight\": 2438,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.modifierExtension\",\
		\"weight\": 2439,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.sequence\",\
		\"weight\": 2440,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.type\",\
		\"weight\": 2441,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.service\",\
		\"weight\": 2442,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.programCode\",\
		\"weight\": 2443,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.quantity\",\
		\"weight\": 2444,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.unitPrice\",\
		\"weight\": 2445,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.factor\",\
		\"weight\": 2446,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.points\",\
		\"weight\": 2447,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.net\",\
		\"weight\": 2448,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.udi\",\
		\"weight\": 2449,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication\",\
		\"weight\": 2450,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.id\",\
		\"weight\": 2451,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.extension\",\
		\"weight\": 2452,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.modifierExtension\",\
		\"weight\": 2453,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.category\",\
		\"weight\": 2454,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.reason\",\
		\"weight\": 2455,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.amount\",\
		\"weight\": 2456,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.value\",\
		\"weight\": 2457,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail\",\
		\"weight\": 2458,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.id\",\
		\"weight\": 2459,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.extension\",\
		\"weight\": 2460,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.modifierExtension\",\
		\"weight\": 2461,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.sequence\",\
		\"weight\": 2462,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.type\",\
		\"weight\": 2463,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.service\",\
		\"weight\": 2464,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.programCode\",\
		\"weight\": 2465,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.quantity\",\
		\"weight\": 2466,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.unitPrice\",\
		\"weight\": 2467,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.factor\",\
		\"weight\": 2468,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.points\",\
		\"weight\": 2469,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.net\",\
		\"weight\": 2470,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.udi\",\
		\"weight\": 2471,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication\",\
		\"weight\": 2472,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.id\",\
		\"weight\": 2473,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.extension\",\
		\"weight\": 2474,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.modifierExtension\",\
		\"weight\": 2475,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.category\",\
		\"weight\": 2476,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.reason\",\
		\"weight\": 2477,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.amount\",\
		\"weight\": 2478,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.value\",\
		\"weight\": 2479,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis\",\
		\"weight\": 2480,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.id\",\
		\"weight\": 2481,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.extension\",\
		\"weight\": 2482,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.modifierExtension\",\
		\"weight\": 2483,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.initial\",\
		\"weight\": 2484,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.priorDate\",\
		\"weight\": 2485,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.priorMaterial\",\
		\"weight\": 2486,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem\",\
		\"weight\": 2487,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.id\",\
		\"weight\": 2488,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.extension\",\
		\"weight\": 2489,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.modifierExtension\",\
		\"weight\": 2490,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.sequenceLinkId\",\
		\"weight\": 2491,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.service\",\
		\"weight\": 2492,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.fee\",\
		\"weight\": 2493,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.noteNumberLinkId\",\
		\"weight\": 2494,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication\",\
		\"weight\": 2495,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.id\",\
		\"weight\": 2496,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.extension\",\
		\"weight\": 2497,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.modifierExtension\",\
		\"weight\": 2498,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.category\",\
		\"weight\": 2499,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.reason\",\
		\"weight\": 2500,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.amount\",\
		\"weight\": 2501,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.value\",\
		\"weight\": 2502,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail\",\
		\"weight\": 2503,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.id\",\
		\"weight\": 2504,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.extension\",\
		\"weight\": 2505,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.modifierExtension\",\
		\"weight\": 2506,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.service\",\
		\"weight\": 2507,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.fee\",\
		\"weight\": 2508,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication\",\
		\"weight\": 2509,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.id\",\
		\"weight\": 2510,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.extension\",\
		\"weight\": 2511,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.modifierExtension\",\
		\"weight\": 2512,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.category\",\
		\"weight\": 2513,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.reason\",\
		\"weight\": 2514,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.amount\",\
		\"weight\": 2515,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.value\",\
		\"weight\": 2516,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth\",\
		\"weight\": 2517,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.id\",\
		\"weight\": 2518,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.extension\",\
		\"weight\": 2519,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.modifierExtension\",\
		\"weight\": 2520,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.tooth\",\
		\"weight\": 2521,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.reason\",\
		\"weight\": 2522,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.extractionDate\",\
		\"weight\": 2523,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.totalCost\",\
		\"weight\": 2524,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.unallocDeductable\",\
		\"weight\": 2525,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.totalBenefit\",\
		\"weight\": 2526,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentAdjustment\",\
		\"weight\": 2527,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentAdjustmentReason\",\
		\"weight\": 2528,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentDate\",\
		\"weight\": 2529,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentAmount\",\
		\"weight\": 2530,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentRef\",\
		\"weight\": 2531,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.reserved\",\
		\"weight\": 2532,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.form\",\
		\"weight\": 2533,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note\",\
		\"weight\": 2534,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.id\",\
		\"weight\": 2535,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.extension\",\
		\"weight\": 2536,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.modifierExtension\",\
		\"weight\": 2537,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.number\",\
		\"weight\": 2538,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.type\",\
		\"weight\": 2539,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.text\",\
		\"weight\": 2540,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance\",\
		\"weight\": 2541,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.id\",\
		\"weight\": 2542,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.extension\",\
		\"weight\": 2543,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.modifierExtension\",\
		\"weight\": 2544,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.category\",\
		\"weight\": 2545,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.subCategory\",\
		\"weight\": 2546,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.network\",\
		\"weight\": 2547,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.unit\",\
		\"weight\": 2548,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.term\",\
		\"weight\": 2549,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial\",\
		\"weight\": 2550,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.id\",\
		\"weight\": 2551,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.extension\",\
		\"weight\": 2552,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.modifierExtension\",\
		\"weight\": 2553,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.type\",\
		\"weight\": 2554,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUnsignedInt\",\
		\"weight\": 2555,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitQuantity\",\
		\"weight\": 2555,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUsedUnsignedInt\",\
		\"weight\": 2556,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUsedQuantity\",\
		\"weight\": 2556,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory\",\
		\"weight\": 2557,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.id\",\
		\"weight\": 2558,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.meta\",\
		\"weight\": 2559,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.implicitRules\",\
		\"weight\": 2560,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.language\",\
		\"weight\": 2561,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.text\",\
		\"weight\": 2562,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.contained\",\
		\"weight\": 2563,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.extension\",\
		\"weight\": 2564,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.modifierExtension\",\
		\"weight\": 2565,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.identifier\",\
		\"weight\": 2566,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.patient\",\
		\"weight\": 2567,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.date\",\
		\"weight\": 2568,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.status\",\
		\"weight\": 2569,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.name\",\
		\"weight\": 2570,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.relationship\",\
		\"weight\": 2571,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.gender\",\
		\"weight\": 2572,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornPeriod\",\
		\"weight\": 2573,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornDate\",\
		\"weight\": 2573,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornString\",\
		\"weight\": 2573,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageQuantity\",\
		\"weight\": 2574,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageRange\",\
		\"weight\": 2574,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageString\",\
		\"weight\": 2574,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedBoolean\",\
		\"weight\": 2575,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedQuantity\",\
		\"weight\": 2575,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedRange\",\
		\"weight\": 2575,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedDate\",\
		\"weight\": 2575,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedString\",\
		\"weight\": 2575,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.note\",\
		\"weight\": 2576,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition\",\
		\"weight\": 2577,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.id\",\
		\"weight\": 2578,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.extension\",\
		\"weight\": 2579,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.modifierExtension\",\
		\"weight\": 2580,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.code\",\
		\"weight\": 2581,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.outcome\",\
		\"weight\": 2582,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetQuantity\",\
		\"weight\": 2583,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetRange\",\
		\"weight\": 2583,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetPeriod\",\
		\"weight\": 2583,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetString\",\
		\"weight\": 2583,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.note\",\
		\"weight\": 2584,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag\",\
		\"weight\": 2585,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.id\",\
		\"weight\": 2586,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.meta\",\
		\"weight\": 2587,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.implicitRules\",\
		\"weight\": 2588,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.language\",\
		\"weight\": 2589,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.text\",\
		\"weight\": 2590,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.contained\",\
		\"weight\": 2591,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.extension\",\
		\"weight\": 2592,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.modifierExtension\",\
		\"weight\": 2593,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.identifier\",\
		\"weight\": 2594,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.category\",\
		\"weight\": 2595,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.status\",\
		\"weight\": 2596,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.period\",\
		\"weight\": 2597,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.subject\",\
		\"weight\": 2598,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.encounter\",\
		\"weight\": 2599,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.author\",\
		\"weight\": 2600,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.code\",\
		\"weight\": 2601,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal\",\
		\"weight\": 2602,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.id\",\
		\"weight\": 2603,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.meta\",\
		\"weight\": 2604,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.implicitRules\",\
		\"weight\": 2605,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.language\",\
		\"weight\": 2606,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.text\",\
		\"weight\": 2607,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.contained\",\
		\"weight\": 2608,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.extension\",\
		\"weight\": 2609,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.modifierExtension\",\
		\"weight\": 2610,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.identifier\",\
		\"weight\": 2611,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.subject\",\
		\"weight\": 2612,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.startDate\",\
		\"weight\": 2613,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.startCodeableConcept\",\
		\"weight\": 2613,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.targetDate\",\
		\"weight\": 2614,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.targetQuantity\",\
		\"weight\": 2614,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.category\",\
		\"weight\": 2615,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.description\",\
		\"weight\": 2616,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.status\",\
		\"weight\": 2617,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.statusDate\",\
		\"weight\": 2618,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.statusReason\",\
		\"weight\": 2619,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.expressedBy\",\
		\"weight\": 2620,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.priority\",\
		\"weight\": 2621,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.addresses\",\
		\"weight\": 2622,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.note\",\
		\"weight\": 2623,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome\",\
		\"weight\": 2624,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.id\",\
		\"weight\": 2625,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.outcome.extension\",\
		\"weight\": 2626,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.modifierExtension\",\
		\"weight\": 2627,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.resultCodeableConcept\",\
		\"weight\": 2628,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.outcome.resultReference\",\
		\"weight\": 2628,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group\",\
		\"weight\": 2629,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.id\",\
		\"weight\": 2630,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.meta\",\
		\"weight\": 2631,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.implicitRules\",\
		\"weight\": 2632,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.language\",\
		\"weight\": 2633,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.text\",\
		\"weight\": 2634,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.contained\",\
		\"weight\": 2635,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.extension\",\
		\"weight\": 2636,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.modifierExtension\",\
		\"weight\": 2637,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.identifier\",\
		\"weight\": 2638,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.type\",\
		\"weight\": 2639,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.actual\",\
		\"weight\": 2640,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.active\",\
		\"weight\": 2641,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.code\",\
		\"weight\": 2642,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.name\",\
		\"weight\": 2643,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.quantity\",\
		\"weight\": 2644,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic\",\
		\"weight\": 2645,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.id\",\
		\"weight\": 2646,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.extension\",\
		\"weight\": 2647,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.modifierExtension\",\
		\"weight\": 2648,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.code\",\
		\"weight\": 2649,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueCodeableConcept\",\
		\"weight\": 2650,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueBoolean\",\
		\"weight\": 2650,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueQuantity\",\
		\"weight\": 2650,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueRange\",\
		\"weight\": 2650,\
		\"type\": \"Range\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.exclude\",\
		\"weight\": 2651,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.period\",\
		\"weight\": 2652,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member\",\
		\"weight\": 2653,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.id\",\
		\"weight\": 2654,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.extension\",\
		\"weight\": 2655,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.modifierExtension\",\
		\"weight\": 2656,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.entity\",\
		\"weight\": 2657,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.period\",\
		\"weight\": 2658,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.inactive\",\
		\"weight\": 2659,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse\",\
		\"weight\": 2660,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.id\",\
		\"weight\": 2661,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.meta\",\
		\"weight\": 2662,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.implicitRules\",\
		\"weight\": 2663,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.language\",\
		\"weight\": 2664,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.text\",\
		\"weight\": 2665,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.contained\",\
		\"weight\": 2666,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.extension\",\
		\"weight\": 2667,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.modifierExtension\",\
		\"weight\": 2668,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.requestId\",\
		\"weight\": 2669,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.module\",\
		\"weight\": 2670,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.status\",\
		\"weight\": 2671,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.evaluationMessage\",\
		\"weight\": 2672,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.outputParameters\",\
		\"weight\": 2673,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action\",\
		\"weight\": 2674,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.id\",\
		\"weight\": 2675,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.extension\",\
		\"weight\": 2676,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.modifierExtension\",\
		\"weight\": 2677,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.actionIdentifier\",\
		\"weight\": 2678,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.label\",\
		\"weight\": 2679,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.title\",\
		\"weight\": 2680,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.description\",\
		\"weight\": 2681,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.textEquivalent\",\
		\"weight\": 2682,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.concept\",\
		\"weight\": 2683,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.supportingEvidence\",\
		\"weight\": 2684,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction\",\
		\"weight\": 2685,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.id\",\
		\"weight\": 2686,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.extension\",\
		\"weight\": 2687,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.modifierExtension\",\
		\"weight\": 2688,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.actionIdentifier\",\
		\"weight\": 2689,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.relationship\",\
		\"weight\": 2690,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.offsetQuantity\",\
		\"weight\": 2691,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.offsetRange\",\
		\"weight\": 2691,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.anchor\",\
		\"weight\": 2692,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.documentation\",\
		\"weight\": 2693,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.participant\",\
		\"weight\": 2694,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.type\",\
		\"weight\": 2695,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior\",\
		\"weight\": 2696,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.id\",\
		\"weight\": 2697,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.extension\",\
		\"weight\": 2698,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.modifierExtension\",\
		\"weight\": 2699,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.type\",\
		\"weight\": 2700,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.value\",\
		\"weight\": 2701,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.resource\",\
		\"weight\": 2702,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.action\",\
		\"weight\": 2703,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.dataRequirement\",\
		\"weight\": 2704,\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService\",\
		\"weight\": 2705,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.id\",\
		\"weight\": 2706,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.meta\",\
		\"weight\": 2707,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.implicitRules\",\
		\"weight\": 2708,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.language\",\
		\"weight\": 2709,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.text\",\
		\"weight\": 2710,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.contained\",\
		\"weight\": 2711,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.extension\",\
		\"weight\": 2712,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.modifierExtension\",\
		\"weight\": 2713,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.identifier\",\
		\"weight\": 2714,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.providedBy\",\
		\"weight\": 2715,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceCategory\",\
		\"weight\": 2716,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceType\",\
		\"weight\": 2717,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.specialty\",\
		\"weight\": 2718,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.location\",\
		\"weight\": 2719,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceName\",\
		\"weight\": 2720,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.comment\",\
		\"weight\": 2721,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.extraDetails\",\
		\"weight\": 2722,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.photo\",\
		\"weight\": 2723,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.telecom\",\
		\"weight\": 2724,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.coverageArea\",\
		\"weight\": 2725,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceProvisionCode\",\
		\"weight\": 2726,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.eligibility\",\
		\"weight\": 2727,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.eligibilityNote\",\
		\"weight\": 2728,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.programName\",\
		\"weight\": 2729,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.characteristic\",\
		\"weight\": 2730,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.referralMethod\",\
		\"weight\": 2731,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.publicKey\",\
		\"weight\": 2732,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.appointmentRequired\",\
		\"weight\": 2733,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime\",\
		\"weight\": 2734,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.id\",\
		\"weight\": 2735,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.extension\",\
		\"weight\": 2736,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.modifierExtension\",\
		\"weight\": 2737,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.daysOfWeek\",\
		\"weight\": 2738,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.allDay\",\
		\"weight\": 2739,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.availableStartTime\",\
		\"weight\": 2740,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.availableEndTime\",\
		\"weight\": 2741,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable\",\
		\"weight\": 2742,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.id\",\
		\"weight\": 2743,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.extension\",\
		\"weight\": 2744,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.modifierExtension\",\
		\"weight\": 2745,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.description\",\
		\"weight\": 2746,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.during\",\
		\"weight\": 2747,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availabilityExceptions\",\
		\"weight\": 2748,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt\",\
		\"weight\": 2749,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.id\",\
		\"weight\": 2750,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.meta\",\
		\"weight\": 2751,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.implicitRules\",\
		\"weight\": 2752,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.language\",\
		\"weight\": 2753,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.text\",\
		\"weight\": 2754,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.contained\",\
		\"weight\": 2755,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.extension\",\
		\"weight\": 2756,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.modifierExtension\",\
		\"weight\": 2757,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.uid\",\
		\"weight\": 2758,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.patient\",\
		\"weight\": 2759,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.authoringTime\",\
		\"weight\": 2760,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.author\",\
		\"weight\": 2761,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.title\",\
		\"weight\": 2762,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.description\",\
		\"weight\": 2763,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study\",\
		\"weight\": 2764,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.id\",\
		\"weight\": 2765,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.extension\",\
		\"weight\": 2766,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.modifierExtension\",\
		\"weight\": 2767,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.uid\",\
		\"weight\": 2768,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.imagingStudy\",\
		\"weight\": 2769,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom\",\
		\"weight\": 2770,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.id\",\
		\"weight\": 2771,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.extension\",\
		\"weight\": 2772,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.modifierExtension\",\
		\"weight\": 2773,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.type\",\
		\"weight\": 2774,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.url\",\
		\"weight\": 2775,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable\",\
		\"weight\": 2776,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.id\",\
		\"weight\": 2777,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.extension\",\
		\"weight\": 2778,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.modifierExtension\",\
		\"weight\": 2779,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.contentType\",\
		\"weight\": 2780,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.height\",\
		\"weight\": 2781,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.width\",\
		\"weight\": 2782,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.frames\",\
		\"weight\": 2783,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.duration\",\
		\"weight\": 2784,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.size\",\
		\"weight\": 2785,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.title\",\
		\"weight\": 2786,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.url\",\
		\"weight\": 2787,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series\",\
		\"weight\": 2788,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.id\",\
		\"weight\": 2789,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.extension\",\
		\"weight\": 2790,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.modifierExtension\",\
		\"weight\": 2791,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.uid\",\
		\"weight\": 2792,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom\",\
		\"weight\": 2793,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.id\",\
		\"weight\": 2794,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.extension\",\
		\"weight\": 2795,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.modifierExtension\",\
		\"weight\": 2796,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.type\",\
		\"weight\": 2797,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.url\",\
		\"weight\": 2798,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance\",\
		\"weight\": 2799,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.id\",\
		\"weight\": 2800,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.extension\",\
		\"weight\": 2801,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.modifierExtension\",\
		\"weight\": 2802,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.sopClass\",\
		\"weight\": 2803,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.uid\",\
		\"weight\": 2804,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom\",\
		\"weight\": 2805,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.id\",\
		\"weight\": 2806,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.extension\",\
		\"weight\": 2807,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.modifierExtension\",\
		\"weight\": 2808,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.type\",\
		\"weight\": 2809,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.url\",\
		\"weight\": 2810,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.frameNumbers\",\
		\"weight\": 2811,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection\",\
		\"weight\": 2812,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.id\",\
		\"weight\": 2813,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.meta\",\
		\"weight\": 2814,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.implicitRules\",\
		\"weight\": 2815,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.language\",\
		\"weight\": 2816,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.text\",\
		\"weight\": 2817,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.contained\",\
		\"weight\": 2818,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.extension\",\
		\"weight\": 2819,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.modifierExtension\",\
		\"weight\": 2820,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.uid\",\
		\"weight\": 2821,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.patient\",\
		\"weight\": 2822,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.authoringTime\",\
		\"weight\": 2823,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.author\",\
		\"weight\": 2824,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.title\",\
		\"weight\": 2825,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.description\",\
		\"weight\": 2826,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study\",\
		\"weight\": 2827,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.id\",\
		\"weight\": 2828,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.extension\",\
		\"weight\": 2829,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.modifierExtension\",\
		\"weight\": 2830,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.uid\",\
		\"weight\": 2831,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.url\",\
		\"weight\": 2832,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.imagingStudy\",\
		\"weight\": 2833,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series\",\
		\"weight\": 2834,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.id\",\
		\"weight\": 2835,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.extension\",\
		\"weight\": 2836,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.modifierExtension\",\
		\"weight\": 2837,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.uid\",\
		\"weight\": 2838,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.url\",\
		\"weight\": 2839,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance\",\
		\"weight\": 2840,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.id\",\
		\"weight\": 2841,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.extension\",\
		\"weight\": 2842,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.modifierExtension\",\
		\"weight\": 2843,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.sopClass\",\
		\"weight\": 2844,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.uid\",\
		\"weight\": 2845,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.url\",\
		\"weight\": 2846,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame\",\
		\"weight\": 2847,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.id\",\
		\"weight\": 2848,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.extension\",\
		\"weight\": 2849,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.modifierExtension\",\
		\"weight\": 2850,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.number\",\
		\"weight\": 2851,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.url\",\
		\"weight\": 2852,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy\",\
		\"weight\": 2853,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.id\",\
		\"weight\": 2854,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.meta\",\
		\"weight\": 2855,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.implicitRules\",\
		\"weight\": 2856,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.language\",\
		\"weight\": 2857,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.text\",\
		\"weight\": 2858,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.contained\",\
		\"weight\": 2859,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.extension\",\
		\"weight\": 2860,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.modifierExtension\",\
		\"weight\": 2861,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.uid\",\
		\"weight\": 2862,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.accession\",\
		\"weight\": 2863,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.identifier\",\
		\"weight\": 2864,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.availability\",\
		\"weight\": 2865,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.modalityList\",\
		\"weight\": 2866,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.patient\",\
		\"weight\": 2867,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.started\",\
		\"weight\": 2868,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.order\",\
		\"weight\": 2869,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.referrer\",\
		\"weight\": 2870,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.interpreter\",\
		\"weight\": 2871,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.url\",\
		\"weight\": 2872,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.numberOfSeries\",\
		\"weight\": 2873,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.numberOfInstances\",\
		\"weight\": 2874,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.procedure\",\
		\"weight\": 2875,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.description\",\
		\"weight\": 2876,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series\",\
		\"weight\": 2877,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.id\",\
		\"weight\": 2878,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.extension\",\
		\"weight\": 2879,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.modifierExtension\",\
		\"weight\": 2880,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.uid\",\
		\"weight\": 2881,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.number\",\
		\"weight\": 2882,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.modality\",\
		\"weight\": 2883,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.description\",\
		\"weight\": 2884,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.numberOfInstances\",\
		\"weight\": 2885,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.availability\",\
		\"weight\": 2886,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.url\",\
		\"weight\": 2887,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.bodySite\",\
		\"weight\": 2888,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.laterality\",\
		\"weight\": 2889,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.started\",\
		\"weight\": 2890,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance\",\
		\"weight\": 2891,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.id\",\
		\"weight\": 2892,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.extension\",\
		\"weight\": 2893,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.modifierExtension\",\
		\"weight\": 2894,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.uid\",\
		\"weight\": 2895,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.number\",\
		\"weight\": 2896,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.sopClass\",\
		\"weight\": 2897,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.type\",\
		\"weight\": 2898,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.title\",\
		\"weight\": 2899,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.content\",\
		\"weight\": 2900,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization\",\
		\"weight\": 2901,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.id\",\
		\"weight\": 2902,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.meta\",\
		\"weight\": 2903,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.implicitRules\",\
		\"weight\": 2904,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.language\",\
		\"weight\": 2905,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.text\",\
		\"weight\": 2906,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.contained\",\
		\"weight\": 2907,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.extension\",\
		\"weight\": 2908,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.modifierExtension\",\
		\"weight\": 2909,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.identifier\",\
		\"weight\": 2910,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.status\",\
		\"weight\": 2911,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.date\",\
		\"weight\": 2912,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccineCode\",\
		\"weight\": 2913,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.patient\",\
		\"weight\": 2914,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.wasNotGiven\",\
		\"weight\": 2915,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reported\",\
		\"weight\": 2916,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.performer\",\
		\"weight\": 2917,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.requester\",\
		\"weight\": 2918,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.encounter\",\
		\"weight\": 2919,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.manufacturer\",\
		\"weight\": 2920,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.location\",\
		\"weight\": 2921,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.lotNumber\",\
		\"weight\": 2922,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.expirationDate\",\
		\"weight\": 2923,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.site\",\
		\"weight\": 2924,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.route\",\
		\"weight\": 2925,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.doseQuantity\",\
		\"weight\": 2926,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.note\",\
		\"weight\": 2927,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation\",\
		\"weight\": 2928,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.explanation.id\",\
		\"weight\": 2929,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.explanation.extension\",\
		\"weight\": 2930,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.modifierExtension\",\
		\"weight\": 2931,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.reason\",\
		\"weight\": 2932,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.reasonNotGiven\",\
		\"weight\": 2933,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction\",\
		\"weight\": 2934,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.id\",\
		\"weight\": 2935,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.extension\",\
		\"weight\": 2936,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.modifierExtension\",\
		\"weight\": 2937,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.date\",\
		\"weight\": 2938,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.detail\",\
		\"weight\": 2939,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.reported\",\
		\"weight\": 2940,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol\",\
		\"weight\": 2941,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.id\",\
		\"weight\": 2942,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.extension\",\
		\"weight\": 2943,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.modifierExtension\",\
		\"weight\": 2944,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseSequence\",\
		\"weight\": 2945,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.description\",\
		\"weight\": 2946,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.authority\",\
		\"weight\": 2947,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.series\",\
		\"weight\": 2948,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.seriesDoses\",\
		\"weight\": 2949,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.targetDisease\",\
		\"weight\": 2950,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseStatus\",\
		\"weight\": 2951,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseStatusReason\",\
		\"weight\": 2952,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation\",\
		\"weight\": 2953,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.id\",\
		\"weight\": 2954,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.meta\",\
		\"weight\": 2955,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.implicitRules\",\
		\"weight\": 2956,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.language\",\
		\"weight\": 2957,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.text\",\
		\"weight\": 2958,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.contained\",\
		\"weight\": 2959,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.extension\",\
		\"weight\": 2960,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.modifierExtension\",\
		\"weight\": 2961,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.identifier\",\
		\"weight\": 2962,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.patient\",\
		\"weight\": 2963,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation\",\
		\"weight\": 2964,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.id\",\
		\"weight\": 2965,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.extension\",\
		\"weight\": 2966,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.modifierExtension\",\
		\"weight\": 2967,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.date\",\
		\"weight\": 2968,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.vaccineCode\",\
		\"weight\": 2969,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.doseNumber\",\
		\"weight\": 2970,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.forecastStatus\",\
		\"weight\": 2971,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion\",\
		\"weight\": 2972,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.id\",\
		\"weight\": 2973,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.extension\",\
		\"weight\": 2974,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.modifierExtension\",\
		\"weight\": 2975,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.code\",\
		\"weight\": 2976,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.value\",\
		\"weight\": 2977,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol\",\
		\"weight\": 2978,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.id\",\
		\"weight\": 2979,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.extension\",\
		\"weight\": 2980,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.modifierExtension\",\
		\"weight\": 2981,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.doseSequence\",\
		\"weight\": 2982,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.description\",\
		\"weight\": 2983,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.authority\",\
		\"weight\": 2984,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.series\",\
		\"weight\": 2985,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingImmunization\",\
		\"weight\": 2986,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingPatientInformation\",\
		\"weight\": 2987,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide\",\
		\"weight\": 2988,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.id\",\
		\"weight\": 2989,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.meta\",\
		\"weight\": 2990,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.implicitRules\",\
		\"weight\": 2991,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.language\",\
		\"weight\": 2992,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.text\",\
		\"weight\": 2993,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contained\",\
		\"weight\": 2994,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.extension\",\
		\"weight\": 2995,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.modifierExtension\",\
		\"weight\": 2996,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.url\",\
		\"weight\": 2997,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.version\",\
		\"weight\": 2998,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.name\",\
		\"weight\": 2999,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.status\",\
		\"weight\": 3000,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.experimental\",\
		\"weight\": 3001,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.publisher\",\
		\"weight\": 3002,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact\",\
		\"weight\": 3003,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.id\",\
		\"weight\": 3004,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.extension\",\
		\"weight\": 3005,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.modifierExtension\",\
		\"weight\": 3006,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.name\",\
		\"weight\": 3007,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.telecom\",\
		\"weight\": 3008,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.date\",\
		\"weight\": 3009,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.description\",\
		\"weight\": 3010,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.useContext\",\
		\"weight\": 3011,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.copyright\",\
		\"weight\": 3012,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.fhirVersion\",\
		\"weight\": 3013,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency\",\
		\"weight\": 3014,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.id\",\
		\"weight\": 3015,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.extension\",\
		\"weight\": 3016,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.modifierExtension\",\
		\"weight\": 3017,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.type\",\
		\"weight\": 3018,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.uri\",\
		\"weight\": 3019,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package\",\
		\"weight\": 3020,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.id\",\
		\"weight\": 3021,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.extension\",\
		\"weight\": 3022,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.modifierExtension\",\
		\"weight\": 3023,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.name\",\
		\"weight\": 3024,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.description\",\
		\"weight\": 3025,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource\",\
		\"weight\": 3026,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.id\",\
		\"weight\": 3027,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.extension\",\
		\"weight\": 3028,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.modifierExtension\",\
		\"weight\": 3029,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.example\",\
		\"weight\": 3030,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.name\",\
		\"weight\": 3031,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.description\",\
		\"weight\": 3032,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.acronym\",\
		\"weight\": 3033,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.sourceUri\",\
		\"weight\": 3034,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.sourceReference\",\
		\"weight\": 3034,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.exampleFor\",\
		\"weight\": 3035,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global\",\
		\"weight\": 3036,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.id\",\
		\"weight\": 3037,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.extension\",\
		\"weight\": 3038,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.modifierExtension\",\
		\"weight\": 3039,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.type\",\
		\"weight\": 3040,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.profile\",\
		\"weight\": 3041,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.binary\",\
		\"weight\": 3042,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page\",\
		\"weight\": 3043,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.id\",\
		\"weight\": 3044,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.extension\",\
		\"weight\": 3045,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.modifierExtension\",\
		\"weight\": 3046,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.source\",\
		\"weight\": 3047,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.name\",\
		\"weight\": 3048,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.kind\",\
		\"weight\": 3049,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.type\",\
		\"weight\": 3050,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.package\",\
		\"weight\": 3051,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.format\",\
		\"weight\": 3052,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.page\",\
		\"weight\": 3053,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library\",\
		\"weight\": 3054,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.id\",\
		\"weight\": 3055,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.meta\",\
		\"weight\": 3056,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.implicitRules\",\
		\"weight\": 3057,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.language\",\
		\"weight\": 3058,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.text\",\
		\"weight\": 3059,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.contained\",\
		\"weight\": 3060,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.extension\",\
		\"weight\": 3061,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.modifierExtension\",\
		\"weight\": 3062,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.moduleMetadata\",\
		\"weight\": 3063,\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.model\",\
		\"weight\": 3064,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.model.id\",\
		\"weight\": 3065,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.model.extension\",\
		\"weight\": 3066,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.model.modifierExtension\",\
		\"weight\": 3067,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.model.name\",\
		\"weight\": 3068,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.model.identifier\",\
		\"weight\": 3069,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.model.version\",\
		\"weight\": 3070,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library\",\
		\"weight\": 3071,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.library.id\",\
		\"weight\": 3072,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.extension\",\
		\"weight\": 3073,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.library.modifierExtension\",\
		\"weight\": 3074,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.library.name\",\
		\"weight\": 3075,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.identifier\",\
		\"weight\": 3076,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.version\",\
		\"weight\": 3077,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.documentAttachment\",\
		\"weight\": 3078,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.documentReference\",\
		\"weight\": 3078,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.codeSystem\",\
		\"weight\": 3079,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.codeSystem.id\",\
		\"weight\": 3080,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.codeSystem.extension\",\
		\"weight\": 3081,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.codeSystem.modifierExtension\",\
		\"weight\": 3082,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.codeSystem.name\",\
		\"weight\": 3083,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.codeSystem.identifier\",\
		\"weight\": 3084,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.codeSystem.version\",\
		\"weight\": 3085,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet\",\
		\"weight\": 3086,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.valueSet.id\",\
		\"weight\": 3087,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet.extension\",\
		\"weight\": 3088,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.valueSet.modifierExtension\",\
		\"weight\": 3089,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.valueSet.name\",\
		\"weight\": 3090,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet.identifier\",\
		\"weight\": 3091,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet.version\",\
		\"weight\": 3092,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet.codeSystem\",\
		\"weight\": 3093,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.parameter\",\
		\"weight\": 3094,\
		\"type\": \"ParameterDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.dataRequirement\",\
		\"weight\": 3095,\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.document\",\
		\"weight\": 3096,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage\",\
		\"weight\": 3097,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.id\",\
		\"weight\": 3098,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.meta\",\
		\"weight\": 3099,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.implicitRules\",\
		\"weight\": 3100,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.language\",\
		\"weight\": 3101,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.text\",\
		\"weight\": 3102,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.contained\",\
		\"weight\": 3103,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.extension\",\
		\"weight\": 3104,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.modifierExtension\",\
		\"weight\": 3105,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.author\",\
		\"weight\": 3106,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item\",\
		\"weight\": 3107,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.id\",\
		\"weight\": 3108,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item.extension\",\
		\"weight\": 3109,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.modifierExtension\",\
		\"weight\": 3110,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.type\",\
		\"weight\": 3111,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item.resource\",\
		\"weight\": 3112,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List\",\
		\"weight\": 3113,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.id\",\
		\"weight\": 3114,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.meta\",\
		\"weight\": 3115,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.implicitRules\",\
		\"weight\": 3116,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.language\",\
		\"weight\": 3117,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.text\",\
		\"weight\": 3118,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.contained\",\
		\"weight\": 3119,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.extension\",\
		\"weight\": 3120,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.modifierExtension\",\
		\"weight\": 3121,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.identifier\",\
		\"weight\": 3122,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.status\",\
		\"weight\": 3123,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.mode\",\
		\"weight\": 3124,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.title\",\
		\"weight\": 3125,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.code\",\
		\"weight\": 3126,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.subject\",\
		\"weight\": 3127,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.encounter\",\
		\"weight\": 3128,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.date\",\
		\"weight\": 3129,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.source\",\
		\"weight\": 3130,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.orderedBy\",\
		\"weight\": 3131,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.note\",\
		\"weight\": 3132,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry\",\
		\"weight\": 3133,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.id\",\
		\"weight\": 3134,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.extension\",\
		\"weight\": 3135,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.modifierExtension\",\
		\"weight\": 3136,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.flag\",\
		\"weight\": 3137,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.deleted\",\
		\"weight\": 3138,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.date\",\
		\"weight\": 3139,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.item\",\
		\"weight\": 3140,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.emptyReason\",\
		\"weight\": 3141,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location\",\
		\"weight\": 3142,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.id\",\
		\"weight\": 3143,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.meta\",\
		\"weight\": 3144,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.implicitRules\",\
		\"weight\": 3145,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.language\",\
		\"weight\": 3146,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.text\",\
		\"weight\": 3147,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.contained\",\
		\"weight\": 3148,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.extension\",\
		\"weight\": 3149,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.modifierExtension\",\
		\"weight\": 3150,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.identifier\",\
		\"weight\": 3151,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.status\",\
		\"weight\": 3152,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.name\",\
		\"weight\": 3153,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.description\",\
		\"weight\": 3154,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.mode\",\
		\"weight\": 3155,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.type\",\
		\"weight\": 3156,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.telecom\",\
		\"weight\": 3157,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.address\",\
		\"weight\": 3158,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.physicalType\",\
		\"weight\": 3159,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position\",\
		\"weight\": 3160,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.id\",\
		\"weight\": 3161,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.extension\",\
		\"weight\": 3162,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.position.modifierExtension\",\
		\"weight\": 3163,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.position.longitude\",\
		\"weight\": 3164,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.latitude\",\
		\"weight\": 3165,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.altitude\",\
		\"weight\": 3166,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.managingOrganization\",\
		\"weight\": 3167,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.partOf\",\
		\"weight\": 3168,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure\",\
		\"weight\": 3169,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.id\",\
		\"weight\": 3170,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.meta\",\
		\"weight\": 3171,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.implicitRules\",\
		\"weight\": 3172,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.language\",\
		\"weight\": 3173,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.text\",\
		\"weight\": 3174,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.contained\",\
		\"weight\": 3175,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.extension\",\
		\"weight\": 3176,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.modifierExtension\",\
		\"weight\": 3177,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.moduleMetadata\",\
		\"weight\": 3178,\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.library\",\
		\"weight\": 3179,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.disclaimer\",\
		\"weight\": 3180,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.scoring\",\
		\"weight\": 3181,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.type\",\
		\"weight\": 3182,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.riskAdjustment\",\
		\"weight\": 3183,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.rateAggregation\",\
		\"weight\": 3184,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.rationale\",\
		\"weight\": 3185,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.clinicalRecommendationStatement\",\
		\"weight\": 3186,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.improvementNotation\",\
		\"weight\": 3187,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.definition\",\
		\"weight\": 3188,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.guidance\",\
		\"weight\": 3189,\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.set\",\
		\"weight\": 3190,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group\",\
		\"weight\": 3191,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.id\",\
		\"weight\": 3192,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.extension\",\
		\"weight\": 3193,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.modifierExtension\",\
		\"weight\": 3194,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.identifier\",\
		\"weight\": 3195,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.name\",\
		\"weight\": 3196,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.description\",\
		\"weight\": 3197,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population\",\
		\"weight\": 3198,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.id\",\
		\"weight\": 3199,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.extension\",\
		\"weight\": 3200,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.modifierExtension\",\
		\"weight\": 3201,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.type\",\
		\"weight\": 3202,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.identifier\",\
		\"weight\": 3203,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.name\",\
		\"weight\": 3204,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.description\",\
		\"weight\": 3205,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.criteria\",\
		\"weight\": 3206,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier\",\
		\"weight\": 3207,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.id\",\
		\"weight\": 3208,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.extension\",\
		\"weight\": 3209,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.modifierExtension\",\
		\"weight\": 3210,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.identifier\",\
		\"weight\": 3211,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.criteria\",\
		\"weight\": 3212,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.path\",\
		\"weight\": 3213,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData\",\
		\"weight\": 3214,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.id\",\
		\"weight\": 3215,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.extension\",\
		\"weight\": 3216,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.modifierExtension\",\
		\"weight\": 3217,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.identifier\",\
		\"weight\": 3218,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.usage\",\
		\"weight\": 3219,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.criteria\",\
		\"weight\": 3220,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.path\",\
		\"weight\": 3221,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport\",\
		\"weight\": 3222,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.id\",\
		\"weight\": 3223,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.meta\",\
		\"weight\": 3224,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.implicitRules\",\
		\"weight\": 3225,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.language\",\
		\"weight\": 3226,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.text\",\
		\"weight\": 3227,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.contained\",\
		\"weight\": 3228,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.extension\",\
		\"weight\": 3229,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.modifierExtension\",\
		\"weight\": 3230,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.measure\",\
		\"weight\": 3231,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.type\",\
		\"weight\": 3232,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.patient\",\
		\"weight\": 3233,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.period\",\
		\"weight\": 3234,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.status\",\
		\"weight\": 3235,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.date\",\
		\"weight\": 3236,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.reportingOrganization\",\
		\"weight\": 3237,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group\",\
		\"weight\": 3238,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.id\",\
		\"weight\": 3239,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.extension\",\
		\"weight\": 3240,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.modifierExtension\",\
		\"weight\": 3241,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.identifier\",\
		\"weight\": 3242,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population\",\
		\"weight\": 3243,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.id\",\
		\"weight\": 3244,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.extension\",\
		\"weight\": 3245,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.modifierExtension\",\
		\"weight\": 3246,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.type\",\
		\"weight\": 3247,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.count\",\
		\"weight\": 3248,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.patients\",\
		\"weight\": 3249,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.measureScore\",\
		\"weight\": 3250,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier\",\
		\"weight\": 3251,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.id\",\
		\"weight\": 3252,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.extension\",\
		\"weight\": 3253,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.modifierExtension\",\
		\"weight\": 3254,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.identifier\",\
		\"weight\": 3255,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group\",\
		\"weight\": 3256,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.id\",\
		\"weight\": 3257,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.extension\",\
		\"weight\": 3258,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.modifierExtension\",\
		\"weight\": 3259,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.value\",\
		\"weight\": 3260,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population\",\
		\"weight\": 3261,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.id\",\
		\"weight\": 3262,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.extension\",\
		\"weight\": 3263,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.modifierExtension\",\
		\"weight\": 3264,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.type\",\
		\"weight\": 3265,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.count\",\
		\"weight\": 3266,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.patients\",\
		\"weight\": 3267,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.measureScore\",\
		\"weight\": 3268,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData\",\
		\"weight\": 3269,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.id\",\
		\"weight\": 3270,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.extension\",\
		\"weight\": 3271,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.modifierExtension\",\
		\"weight\": 3272,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.identifier\",\
		\"weight\": 3273,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group\",\
		\"weight\": 3274,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.id\",\
		\"weight\": 3275,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.extension\",\
		\"weight\": 3276,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.modifierExtension\",\
		\"weight\": 3277,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.value\",\
		\"weight\": 3278,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.count\",\
		\"weight\": 3279,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.patients\",\
		\"weight\": 3280,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.evaluatedResources\",\
		\"weight\": 3281,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media\",\
		\"weight\": 3282,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.id\",\
		\"weight\": 3283,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.meta\",\
		\"weight\": 3284,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.implicitRules\",\
		\"weight\": 3285,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.language\",\
		\"weight\": 3286,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.text\",\
		\"weight\": 3287,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.contained\",\
		\"weight\": 3288,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.extension\",\
		\"weight\": 3289,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.modifierExtension\",\
		\"weight\": 3290,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.identifier\",\
		\"weight\": 3291,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.type\",\
		\"weight\": 3292,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.subtype\",\
		\"weight\": 3293,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.view\",\
		\"weight\": 3294,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.subject\",\
		\"weight\": 3295,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.operator\",\
		\"weight\": 3296,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.deviceName\",\
		\"weight\": 3297,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.height\",\
		\"weight\": 3298,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.width\",\
		\"weight\": 3299,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.frames\",\
		\"weight\": 3300,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.duration\",\
		\"weight\": 3301,\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.content\",\
		\"weight\": 3302,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication\",\
		\"weight\": 3303,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.id\",\
		\"weight\": 3304,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.meta\",\
		\"weight\": 3305,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.implicitRules\",\
		\"weight\": 3306,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.language\",\
		\"weight\": 3307,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.text\",\
		\"weight\": 3308,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.contained\",\
		\"weight\": 3309,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.extension\",\
		\"weight\": 3310,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.modifierExtension\",\
		\"weight\": 3311,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.code\",\
		\"weight\": 3312,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.isBrand\",\
		\"weight\": 3313,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.manufacturer\",\
		\"weight\": 3314,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product\",\
		\"weight\": 3315,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.id\",\
		\"weight\": 3316,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.extension\",\
		\"weight\": 3317,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.modifierExtension\",\
		\"weight\": 3318,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.form\",\
		\"weight\": 3319,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient\",\
		\"weight\": 3320,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.id\",\
		\"weight\": 3321,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.extension\",\
		\"weight\": 3322,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.modifierExtension\",\
		\"weight\": 3323,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemCodeableConcept\",\
		\"weight\": 3324,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemReference\",\
		\"weight\": 3324,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemReference\",\
		\"weight\": 3324,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.amount\",\
		\"weight\": 3325,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch\",\
		\"weight\": 3326,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.id\",\
		\"weight\": 3327,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch.extension\",\
		\"weight\": 3328,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.modifierExtension\",\
		\"weight\": 3329,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.lotNumber\",\
		\"weight\": 3330,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch.expirationDate\",\
		\"weight\": 3331,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package\",\
		\"weight\": 3332,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.id\",\
		\"weight\": 3333,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.extension\",\
		\"weight\": 3334,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.modifierExtension\",\
		\"weight\": 3335,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.container\",\
		\"weight\": 3336,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content\",\
		\"weight\": 3337,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.id\",\
		\"weight\": 3338,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content.extension\",\
		\"weight\": 3339,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.modifierExtension\",\
		\"weight\": 3340,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.itemCodeableConcept\",\
		\"weight\": 3341,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content.itemReference\",\
		\"weight\": 3341,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content.amount\",\
		\"weight\": 3342,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration\",\
		\"weight\": 3343,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.id\",\
		\"weight\": 3344,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.meta\",\
		\"weight\": 3345,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.implicitRules\",\
		\"weight\": 3346,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.language\",\
		\"weight\": 3347,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.text\",\
		\"weight\": 3348,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.contained\",\
		\"weight\": 3349,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.extension\",\
		\"weight\": 3350,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.modifierExtension\",\
		\"weight\": 3351,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.identifier\",\
		\"weight\": 3352,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.status\",\
		\"weight\": 3353,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.medicationCodeableConcept\",\
		\"weight\": 3354,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.medicationReference\",\
		\"weight\": 3354,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.patient\",\
		\"weight\": 3355,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.encounter\",\
		\"weight\": 3356,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.effectiveTimeDateTime\",\
		\"weight\": 3357,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.effectiveTimePeriod\",\
		\"weight\": 3357,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.practitioner\",\
		\"weight\": 3358,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.prescription\",\
		\"weight\": 3359,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.wasNotGiven\",\
		\"weight\": 3360,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.reasonNotGiven\",\
		\"weight\": 3361,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.reasonGiven\",\
		\"weight\": 3362,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.device\",\
		\"weight\": 3363,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.note\",\
		\"weight\": 3364,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage\",\
		\"weight\": 3365,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.id\",\
		\"weight\": 3366,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.extension\",\
		\"weight\": 3367,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.modifierExtension\",\
		\"weight\": 3368,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.text\",\
		\"weight\": 3369,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.siteCodeableConcept\",\
		\"weight\": 3370,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.siteReference\",\
		\"weight\": 3370,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.route\",\
		\"weight\": 3371,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.method\",\
		\"weight\": 3372,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.quantity\",\
		\"weight\": 3373,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.rateRatio\",\
		\"weight\": 3374,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.rateRange\",\
		\"weight\": 3374,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense\",\
		\"weight\": 3375,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.id\",\
		\"weight\": 3376,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.meta\",\
		\"weight\": 3377,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.implicitRules\",\
		\"weight\": 3378,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.language\",\
		\"weight\": 3379,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.text\",\
		\"weight\": 3380,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.contained\",\
		\"weight\": 3381,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.extension\",\
		\"weight\": 3382,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.modifierExtension\",\
		\"weight\": 3383,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.identifier\",\
		\"weight\": 3384,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.status\",\
		\"weight\": 3385,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.medicationCodeableConcept\",\
		\"weight\": 3386,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.medicationReference\",\
		\"weight\": 3386,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.patient\",\
		\"weight\": 3387,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dispenser\",\
		\"weight\": 3388,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.authorizingPrescription\",\
		\"weight\": 3389,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.type\",\
		\"weight\": 3390,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.quantity\",\
		\"weight\": 3391,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.daysSupply\",\
		\"weight\": 3392,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.whenPrepared\",\
		\"weight\": 3393,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.whenHandedOver\",\
		\"weight\": 3394,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.destination\",\
		\"weight\": 3395,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.receiver\",\
		\"weight\": 3396,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.note\",\
		\"weight\": 3397,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction\",\
		\"weight\": 3398,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.id\",\
		\"weight\": 3399,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.extension\",\
		\"weight\": 3400,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.modifierExtension\",\
		\"weight\": 3401,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.text\",\
		\"weight\": 3402,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.additionalInstructions\",\
		\"weight\": 3403,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.timing\",\
		\"weight\": 3404,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.asNeededBoolean\",\
		\"weight\": 3405,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.asNeededCodeableConcept\",\
		\"weight\": 3405,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.siteCodeableConcept\",\
		\"weight\": 3406,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.siteReference\",\
		\"weight\": 3406,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.route\",\
		\"weight\": 3407,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.method\",\
		\"weight\": 3408,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.doseRange\",\
		\"weight\": 3409,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.doseQuantity\",\
		\"weight\": 3409,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.rateRatio\",\
		\"weight\": 3410,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.rateRange\",\
		\"weight\": 3410,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.maxDosePerPeriod\",\
		\"weight\": 3411,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution\",\
		\"weight\": 3412,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.id\",\
		\"weight\": 3413,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.extension\",\
		\"weight\": 3414,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.modifierExtension\",\
		\"weight\": 3415,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.type\",\
		\"weight\": 3416,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.reason\",\
		\"weight\": 3417,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.responsibleParty\",\
		\"weight\": 3418,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder\",\
		\"weight\": 3419,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.id\",\
		\"weight\": 3420,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.meta\",\
		\"weight\": 3421,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.implicitRules\",\
		\"weight\": 3422,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.language\",\
		\"weight\": 3423,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.text\",\
		\"weight\": 3424,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.contained\",\
		\"weight\": 3425,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.extension\",\
		\"weight\": 3426,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.modifierExtension\",\
		\"weight\": 3427,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.identifier\",\
		\"weight\": 3428,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.status\",\
		\"weight\": 3429,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.medicationCodeableConcept\",\
		\"weight\": 3430,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.medicationReference\",\
		\"weight\": 3430,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.patient\",\
		\"weight\": 3431,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.encounter\",\
		\"weight\": 3432,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dateWritten\",\
		\"weight\": 3433,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.prescriber\",\
		\"weight\": 3434,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.reasonCode\",\
		\"weight\": 3435,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.reasonReference\",\
		\"weight\": 3436,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dateEnded\",\
		\"weight\": 3437,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.reasonEnded\",\
		\"weight\": 3438,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.note\",\
		\"weight\": 3439,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction\",\
		\"weight\": 3440,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.id\",\
		\"weight\": 3441,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.extension\",\
		\"weight\": 3442,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.modifierExtension\",\
		\"weight\": 3443,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.text\",\
		\"weight\": 3444,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.additionalInstructions\",\
		\"weight\": 3445,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.timing\",\
		\"weight\": 3446,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.asNeededBoolean\",\
		\"weight\": 3447,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.asNeededCodeableConcept\",\
		\"weight\": 3447,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.siteCodeableConcept\",\
		\"weight\": 3448,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.siteReference\",\
		\"weight\": 3448,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.route\",\
		\"weight\": 3449,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.method\",\
		\"weight\": 3450,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.doseRange\",\
		\"weight\": 3451,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.doseQuantity\",\
		\"weight\": 3451,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerPeriod\",\
		\"weight\": 3452,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerAdministration\",\
		\"weight\": 3453,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateRatio\",\
		\"weight\": 3454,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateRange\",\
		\"weight\": 3454,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateQuantity\",\
		\"weight\": 3454,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest\",\
		\"weight\": 3455,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.id\",\
		\"weight\": 3456,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.extension\",\
		\"weight\": 3457,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.modifierExtension\",\
		\"weight\": 3458,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.medicationCodeableConcept\",\
		\"weight\": 3459,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.medicationReference\",\
		\"weight\": 3459,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.validityPeriod\",\
		\"weight\": 3460,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.numberOfRepeatsAllowed\",\
		\"weight\": 3461,\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.quantity\",\
		\"weight\": 3462,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.expectedSupplyDuration\",\
		\"weight\": 3463,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution\",\
		\"weight\": 3464,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.id\",\
		\"weight\": 3465,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.extension\",\
		\"weight\": 3466,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.modifierExtension\",\
		\"weight\": 3467,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.type\",\
		\"weight\": 3468,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.reason\",\
		\"weight\": 3469,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.priorPrescription\",\
		\"weight\": 3470,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement\",\
		\"weight\": 3471,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.id\",\
		\"weight\": 3472,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.meta\",\
		\"weight\": 3473,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.implicitRules\",\
		\"weight\": 3474,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.language\",\
		\"weight\": 3475,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.text\",\
		\"weight\": 3476,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.contained\",\
		\"weight\": 3477,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.extension\",\
		\"weight\": 3478,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.modifierExtension\",\
		\"weight\": 3479,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.identifier\",\
		\"weight\": 3480,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.status\",\
		\"weight\": 3481,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.medicationCodeableConcept\",\
		\"weight\": 3482,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.medicationReference\",\
		\"weight\": 3482,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.patient\",\
		\"weight\": 3483,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.effectiveDateTime\",\
		\"weight\": 3484,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.effectivePeriod\",\
		\"weight\": 3484,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.informationSource\",\
		\"weight\": 3485,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.supportingInformation\",\
		\"weight\": 3486,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dateAsserted\",\
		\"weight\": 3487,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.wasNotTaken\",\
		\"weight\": 3488,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonNotTaken\",\
		\"weight\": 3489,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonForUseCode\",\
		\"weight\": 3490,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonForUseReference\",\
		\"weight\": 3491,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.note\",\
		\"weight\": 3492,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage\",\
		\"weight\": 3493,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.id\",\
		\"weight\": 3494,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.extension\",\
		\"weight\": 3495,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.modifierExtension\",\
		\"weight\": 3496,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.text\",\
		\"weight\": 3497,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.timing\",\
		\"weight\": 3498,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.asNeededBoolean\",\
		\"weight\": 3499,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.asNeededCodeableConcept\",\
		\"weight\": 3499,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.siteCodeableConcept\",\
		\"weight\": 3500,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.siteReference\",\
		\"weight\": 3500,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.route\",\
		\"weight\": 3501,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.method\",\
		\"weight\": 3502,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.quantityQuantity\",\
		\"weight\": 3503,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.quantityRange\",\
		\"weight\": 3503,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.rateRatio\",\
		\"weight\": 3504,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.rateRange\",\
		\"weight\": 3504,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.maxDosePerPeriod\",\
		\"weight\": 3505,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader\",\
		\"weight\": 3506,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.id\",\
		\"weight\": 3507,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.meta\",\
		\"weight\": 3508,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.implicitRules\",\
		\"weight\": 3509,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.language\",\
		\"weight\": 3510,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.text\",\
		\"weight\": 3511,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.contained\",\
		\"weight\": 3512,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.extension\",\
		\"weight\": 3513,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.modifierExtension\",\
		\"weight\": 3514,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.timestamp\",\
		\"weight\": 3515,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.event\",\
		\"weight\": 3516,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response\",\
		\"weight\": 3517,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.id\",\
		\"weight\": 3518,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.extension\",\
		\"weight\": 3519,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.response.modifierExtension\",\
		\"weight\": 3520,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.response.identifier\",\
		\"weight\": 3521,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.code\",\
		\"weight\": 3522,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.details\",\
		\"weight\": 3523,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source\",\
		\"weight\": 3524,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.id\",\
		\"weight\": 3525,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.extension\",\
		\"weight\": 3526,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.source.modifierExtension\",\
		\"weight\": 3527,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.source.name\",\
		\"weight\": 3528,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.software\",\
		\"weight\": 3529,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.version\",\
		\"weight\": 3530,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.contact\",\
		\"weight\": 3531,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.endpoint\",\
		\"weight\": 3532,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination\",\
		\"weight\": 3533,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.id\",\
		\"weight\": 3534,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.extension\",\
		\"weight\": 3535,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.modifierExtension\",\
		\"weight\": 3536,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.name\",\
		\"weight\": 3537,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.target\",\
		\"weight\": 3538,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.endpoint\",\
		\"weight\": 3539,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.enterer\",\
		\"weight\": 3540,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.author\",\
		\"weight\": 3541,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.receiver\",\
		\"weight\": 3542,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.responsible\",\
		\"weight\": 3543,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.reason\",\
		\"weight\": 3544,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.data\",\
		\"weight\": 3545,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition\",\
		\"weight\": 3546,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.id\",\
		\"weight\": 3547,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.meta\",\
		\"weight\": 3548,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.implicitRules\",\
		\"weight\": 3549,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.language\",\
		\"weight\": 3550,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.text\",\
		\"weight\": 3551,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.contained\",\
		\"weight\": 3552,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.extension\",\
		\"weight\": 3553,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.modifierExtension\",\
		\"weight\": 3554,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.identifier\",\
		\"weight\": 3555,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.version\",\
		\"weight\": 3556,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model\",\
		\"weight\": 3557,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.id\",\
		\"weight\": 3558,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.extension\",\
		\"weight\": 3559,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.modifierExtension\",\
		\"weight\": 3560,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.name\",\
		\"weight\": 3561,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.identifier\",\
		\"weight\": 3562,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.version\",\
		\"weight\": 3563,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library\",\
		\"weight\": 3564,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.id\",\
		\"weight\": 3565,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.extension\",\
		\"weight\": 3566,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.modifierExtension\",\
		\"weight\": 3567,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.name\",\
		\"weight\": 3568,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.identifier\",\
		\"weight\": 3569,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.version\",\
		\"weight\": 3570,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.documentAttachment\",\
		\"weight\": 3571,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.documentReference\",\
		\"weight\": 3571,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem\",\
		\"weight\": 3572,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.id\",\
		\"weight\": 3573,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.extension\",\
		\"weight\": 3574,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.modifierExtension\",\
		\"weight\": 3575,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.name\",\
		\"weight\": 3576,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.identifier\",\
		\"weight\": 3577,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.version\",\
		\"weight\": 3578,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet\",\
		\"weight\": 3579,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.id\",\
		\"weight\": 3580,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.extension\",\
		\"weight\": 3581,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.modifierExtension\",\
		\"weight\": 3582,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.name\",\
		\"weight\": 3583,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.identifier\",\
		\"weight\": 3584,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.version\",\
		\"weight\": 3585,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.codeSystem\",\
		\"weight\": 3586,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter\",\
		\"weight\": 3587,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.id\",\
		\"weight\": 3588,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.extension\",\
		\"weight\": 3589,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.modifierExtension\",\
		\"weight\": 3590,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.name\",\
		\"weight\": 3591,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.use\",\
		\"weight\": 3592,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.documentation\",\
		\"weight\": 3593,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.type\",\
		\"weight\": 3594,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.profile\",\
		\"weight\": 3595,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data\",\
		\"weight\": 3596,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.id\",\
		\"weight\": 3597,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.extension\",\
		\"weight\": 3598,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.modifierExtension\",\
		\"weight\": 3599,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.type\",\
		\"weight\": 3600,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.profile\",\
		\"weight\": 3601,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.mustSupport\",\
		\"weight\": 3602,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter\",\
		\"weight\": 3603,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.id\",\
		\"weight\": 3604,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.extension\",\
		\"weight\": 3605,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.modifierExtension\",\
		\"weight\": 3606,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.path\",\
		\"weight\": 3607,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.valueSetString\",\
		\"weight\": 3608,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.valueSetReference\",\
		\"weight\": 3608,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.codeableConcept\",\
		\"weight\": 3609,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter\",\
		\"weight\": 3610,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.id\",\
		\"weight\": 3611,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.extension\",\
		\"weight\": 3612,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.modifierExtension\",\
		\"weight\": 3613,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.path\",\
		\"weight\": 3614,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.valueDateTime\",\
		\"weight\": 3615,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.valuePeriod\",\
		\"weight\": 3615,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem\",\
		\"weight\": 3616,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.id\",\
		\"weight\": 3617,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.meta\",\
		\"weight\": 3618,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.implicitRules\",\
		\"weight\": 3619,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.language\",\
		\"weight\": 3620,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.text\",\
		\"weight\": 3621,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contained\",\
		\"weight\": 3622,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.extension\",\
		\"weight\": 3623,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.modifierExtension\",\
		\"weight\": 3624,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.name\",\
		\"weight\": 3625,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.status\",\
		\"weight\": 3626,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.kind\",\
		\"weight\": 3627,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.date\",\
		\"weight\": 3628,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.publisher\",\
		\"weight\": 3629,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact\",\
		\"weight\": 3630,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.id\",\
		\"weight\": 3631,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.extension\",\
		\"weight\": 3632,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.modifierExtension\",\
		\"weight\": 3633,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.name\",\
		\"weight\": 3634,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.telecom\",\
		\"weight\": 3635,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.responsible\",\
		\"weight\": 3636,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.type\",\
		\"weight\": 3637,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.description\",\
		\"weight\": 3638,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.useContext\",\
		\"weight\": 3639,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.usage\",\
		\"weight\": 3640,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId\",\
		\"weight\": 3641,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.id\",\
		\"weight\": 3642,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.extension\",\
		\"weight\": 3643,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.modifierExtension\",\
		\"weight\": 3644,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.type\",\
		\"weight\": 3645,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.value\",\
		\"weight\": 3646,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.preferred\",\
		\"weight\": 3647,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.period\",\
		\"weight\": 3648,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.replacedBy\",\
		\"weight\": 3649,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder\",\
		\"weight\": 3650,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.id\",\
		\"weight\": 3651,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.meta\",\
		\"weight\": 3652,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.implicitRules\",\
		\"weight\": 3653,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.language\",\
		\"weight\": 3654,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.text\",\
		\"weight\": 3655,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.contained\",\
		\"weight\": 3656,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.extension\",\
		\"weight\": 3657,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.modifierExtension\",\
		\"weight\": 3658,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.identifier\",\
		\"weight\": 3659,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.status\",\
		\"weight\": 3660,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.patient\",\
		\"weight\": 3661,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.encounter\",\
		\"weight\": 3662,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.dateTime\",\
		\"weight\": 3663,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.orderer\",\
		\"weight\": 3664,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.allergyIntolerance\",\
		\"weight\": 3665,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.foodPreferenceModifier\",\
		\"weight\": 3666,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.excludeFoodModifier\",\
		\"weight\": 3667,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet\",\
		\"weight\": 3668,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.id\",\
		\"weight\": 3669,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.extension\",\
		\"weight\": 3670,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.modifierExtension\",\
		\"weight\": 3671,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.type\",\
		\"weight\": 3672,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.schedule\",\
		\"weight\": 3673,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient\",\
		\"weight\": 3674,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.id\",\
		\"weight\": 3675,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.extension\",\
		\"weight\": 3676,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.modifierExtension\",\
		\"weight\": 3677,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.modifier\",\
		\"weight\": 3678,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.amount\",\
		\"weight\": 3679,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture\",\
		\"weight\": 3680,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.id\",\
		\"weight\": 3681,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.extension\",\
		\"weight\": 3682,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.modifierExtension\",\
		\"weight\": 3683,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.modifier\",\
		\"weight\": 3684,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.foodType\",\
		\"weight\": 3685,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.fluidConsistencyType\",\
		\"weight\": 3686,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.instruction\",\
		\"weight\": 3687,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement\",\
		\"weight\": 3688,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.id\",\
		\"weight\": 3689,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.extension\",\
		\"weight\": 3690,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.modifierExtension\",\
		\"weight\": 3691,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.type\",\
		\"weight\": 3692,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.productName\",\
		\"weight\": 3693,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.schedule\",\
		\"weight\": 3694,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.quantity\",\
		\"weight\": 3695,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.instruction\",\
		\"weight\": 3696,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula\",\
		\"weight\": 3697,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.id\",\
		\"weight\": 3698,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.extension\",\
		\"weight\": 3699,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.modifierExtension\",\
		\"weight\": 3700,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.baseFormulaType\",\
		\"weight\": 3701,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.baseFormulaProductName\",\
		\"weight\": 3702,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.additiveType\",\
		\"weight\": 3703,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.additiveProductName\",\
		\"weight\": 3704,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.caloricDensity\",\
		\"weight\": 3705,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.routeofAdministration\",\
		\"weight\": 3706,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration\",\
		\"weight\": 3707,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.id\",\
		\"weight\": 3708,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.extension\",\
		\"weight\": 3709,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.modifierExtension\",\
		\"weight\": 3710,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.schedule\",\
		\"weight\": 3711,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.quantity\",\
		\"weight\": 3712,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.rateQuantity\",\
		\"weight\": 3713,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.rateRatio\",\
		\"weight\": 3713,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.maxVolumeToDeliver\",\
		\"weight\": 3714,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administrationInstruction\",\
		\"weight\": 3715,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation\",\
		\"weight\": 3716,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.id\",\
		\"weight\": 3717,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.meta\",\
		\"weight\": 3718,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.implicitRules\",\
		\"weight\": 3719,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.language\",\
		\"weight\": 3720,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.text\",\
		\"weight\": 3721,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.contained\",\
		\"weight\": 3722,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.extension\",\
		\"weight\": 3723,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.modifierExtension\",\
		\"weight\": 3724,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.identifier\",\
		\"weight\": 3725,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.status\",\
		\"weight\": 3726,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.category\",\
		\"weight\": 3727,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.code\",\
		\"weight\": 3728,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.subject\",\
		\"weight\": 3729,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.encounter\",\
		\"weight\": 3730,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.effectiveDateTime\",\
		\"weight\": 3731,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.effectivePeriod\",\
		\"weight\": 3731,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.issued\",\
		\"weight\": 3732,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.performer\",\
		\"weight\": 3733,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.valueQuantity\",\
		\"weight\": 3734,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueCodeableConcept\",\
		\"weight\": 3734,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueString\",\
		\"weight\": 3734,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueRange\",\
		\"weight\": 3734,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueRatio\",\
		\"weight\": 3734,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueSampledData\",\
		\"weight\": 3734,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueAttachment\",\
		\"weight\": 3734,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueTime\",\
		\"weight\": 3734,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valueDateTime\",\
		\"weight\": 3734,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.valuePeriod\",\
		\"weight\": 3734,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.dataAbsentReason\",\
		\"weight\": 3735,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.interpretation\",\
		\"weight\": 3736,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.comment\",\
		\"weight\": 3737,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.bodySite\",\
		\"weight\": 3738,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.method\",\
		\"weight\": 3739,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.specimen\",\
		\"weight\": 3740,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.device\",\
		\"weight\": 3741,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange\",\
		\"weight\": 3742,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.id\",\
		\"weight\": 3743,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.extension\",\
		\"weight\": 3744,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.modifierExtension\",\
		\"weight\": 3745,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.low\",\
		\"weight\": 3746,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.high\",\
		\"weight\": 3747,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.meaning\",\
		\"weight\": 3748,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.age\",\
		\"weight\": 3749,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.text\",\
		\"weight\": 3750,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related\",\
		\"weight\": 3751,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.id\",\
		\"weight\": 3752,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related.extension\",\
		\"weight\": 3753,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.modifierExtension\",\
		\"weight\": 3754,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.type\",\
		\"weight\": 3755,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related.target\",\
		\"weight\": 3756,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component\",\
		\"weight\": 3757,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.id\",\
		\"weight\": 3758,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.extension\",\
		\"weight\": 3759,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.modifierExtension\",\
		\"weight\": 3760,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.code\",\
		\"weight\": 3761,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueQuantity\",\
		\"weight\": 3762,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueCodeableConcept\",\
		\"weight\": 3762,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueString\",\
		\"weight\": 3762,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueRange\",\
		\"weight\": 3762,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueRatio\",\
		\"weight\": 3762,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueSampledData\",\
		\"weight\": 3762,\
		\"type\": \"SampledData\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueAttachment\",\
		\"weight\": 3762,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueTime\",\
		\"weight\": 3762,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueDateTime\",\
		\"weight\": 3762,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valuePeriod\",\
		\"weight\": 3762,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.dataAbsentReason\",\
		\"weight\": 3763,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.referenceRange\",\
		\"weight\": 3764,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition\",\
		\"weight\": 3765,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.id\",\
		\"weight\": 3766,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.meta\",\
		\"weight\": 3767,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.implicitRules\",\
		\"weight\": 3768,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.language\",\
		\"weight\": 3769,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.text\",\
		\"weight\": 3770,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contained\",\
		\"weight\": 3771,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.extension\",\
		\"weight\": 3772,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.modifierExtension\",\
		\"weight\": 3773,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.url\",\
		\"weight\": 3774,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.version\",\
		\"weight\": 3775,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.name\",\
		\"weight\": 3776,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.status\",\
		\"weight\": 3777,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.kind\",\
		\"weight\": 3778,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.experimental\",\
		\"weight\": 3779,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.date\",\
		\"weight\": 3780,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.publisher\",\
		\"weight\": 3781,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact\",\
		\"weight\": 3782,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.id\",\
		\"weight\": 3783,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.extension\",\
		\"weight\": 3784,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.modifierExtension\",\
		\"weight\": 3785,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.name\",\
		\"weight\": 3786,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.telecom\",\
		\"weight\": 3787,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.description\",\
		\"weight\": 3788,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.useContext\",\
		\"weight\": 3789,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.requirements\",\
		\"weight\": 3790,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.idempotent\",\
		\"weight\": 3791,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.code\",\
		\"weight\": 3792,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.comment\",\
		\"weight\": 3793,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.base\",\
		\"weight\": 3794,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.system\",\
		\"weight\": 3795,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.type\",\
		\"weight\": 3796,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.instance\",\
		\"weight\": 3797,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter\",\
		\"weight\": 3798,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.id\",\
		\"weight\": 3799,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.extension\",\
		\"weight\": 3800,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.modifierExtension\",\
		\"weight\": 3801,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.name\",\
		\"weight\": 3802,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.use\",\
		\"weight\": 3803,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.min\",\
		\"weight\": 3804,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.max\",\
		\"weight\": 3805,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.documentation\",\
		\"weight\": 3806,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.type\",\
		\"weight\": 3807,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.searchType\",\
		\"weight\": 3808,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.profile\",\
		\"weight\": 3809,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding\",\
		\"weight\": 3810,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.id\",\
		\"weight\": 3811,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.extension\",\
		\"weight\": 3812,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.modifierExtension\",\
		\"weight\": 3813,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.strength\",\
		\"weight\": 3814,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.valueSetUri\",\
		\"weight\": 3815,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.valueSetReference\",\
		\"weight\": 3815,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.part\",\
		\"weight\": 3816,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome\",\
		\"weight\": 3817,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.id\",\
		\"weight\": 3818,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.meta\",\
		\"weight\": 3819,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.implicitRules\",\
		\"weight\": 3820,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.language\",\
		\"weight\": 3821,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.text\",\
		\"weight\": 3822,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.contained\",\
		\"weight\": 3823,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.extension\",\
		\"weight\": 3824,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.modifierExtension\",\
		\"weight\": 3825,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue\",\
		\"weight\": 3826,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.id\",\
		\"weight\": 3827,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.extension\",\
		\"weight\": 3828,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.modifierExtension\",\
		\"weight\": 3829,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.severity\",\
		\"weight\": 3830,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.code\",\
		\"weight\": 3831,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.details\",\
		\"weight\": 3832,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.diagnostics\",\
		\"weight\": 3833,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.location\",\
		\"weight\": 3834,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.expression\",\
		\"weight\": 3835,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order\",\
		\"weight\": 3836,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.id\",\
		\"weight\": 3837,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.meta\",\
		\"weight\": 3838,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.implicitRules\",\
		\"weight\": 3839,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.language\",\
		\"weight\": 3840,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.text\",\
		\"weight\": 3841,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.contained\",\
		\"weight\": 3842,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.extension\",\
		\"weight\": 3843,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.modifierExtension\",\
		\"weight\": 3844,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.identifier\",\
		\"weight\": 3845,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.date\",\
		\"weight\": 3846,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.subject\",\
		\"weight\": 3847,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.source\",\
		\"weight\": 3848,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.target\",\
		\"weight\": 3849,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.reasonCodeableConcept\",\
		\"weight\": 3850,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.reasonReference\",\
		\"weight\": 3850,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.when\",\
		\"weight\": 3851,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.when.id\",\
		\"weight\": 3852,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.when.extension\",\
		\"weight\": 3853,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.when.modifierExtension\",\
		\"weight\": 3854,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.when.code\",\
		\"weight\": 3855,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.when.schedule\",\
		\"weight\": 3856,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.detail\",\
		\"weight\": 3857,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse\",\
		\"weight\": 3858,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.id\",\
		\"weight\": 3859,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.meta\",\
		\"weight\": 3860,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.implicitRules\",\
		\"weight\": 3861,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.language\",\
		\"weight\": 3862,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.text\",\
		\"weight\": 3863,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.contained\",\
		\"weight\": 3864,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.extension\",\
		\"weight\": 3865,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.modifierExtension\",\
		\"weight\": 3866,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.identifier\",\
		\"weight\": 3867,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.request\",\
		\"weight\": 3868,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.date\",\
		\"weight\": 3869,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.who\",\
		\"weight\": 3870,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.orderStatus\",\
		\"weight\": 3871,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.description\",\
		\"weight\": 3872,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.fulfillment\",\
		\"weight\": 3873,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet\",\
		\"weight\": 3874,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.id\",\
		\"weight\": 3875,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.meta\",\
		\"weight\": 3876,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.implicitRules\",\
		\"weight\": 3877,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.language\",\
		\"weight\": 3878,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.text\",\
		\"weight\": 3879,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.contained\",\
		\"weight\": 3880,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.extension\",\
		\"weight\": 3881,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.modifierExtension\",\
		\"weight\": 3882,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.moduleMetadata\",\
		\"weight\": 3883,\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.library\",\
		\"weight\": 3884,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.action\",\
		\"weight\": 3885,\
		\"type\": \"ActionDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization\",\
		\"weight\": 3886,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.id\",\
		\"weight\": 3887,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.meta\",\
		\"weight\": 3888,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.implicitRules\",\
		\"weight\": 3889,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.language\",\
		\"weight\": 3890,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.text\",\
		\"weight\": 3891,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contained\",\
		\"weight\": 3892,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.extension\",\
		\"weight\": 3893,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.modifierExtension\",\
		\"weight\": 3894,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.identifier\",\
		\"weight\": 3895,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.active\",\
		\"weight\": 3896,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.type\",\
		\"weight\": 3897,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.name\",\
		\"weight\": 3898,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.telecom\",\
		\"weight\": 3899,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.address\",\
		\"weight\": 3900,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.partOf\",\
		\"weight\": 3901,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact\",\
		\"weight\": 3902,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.id\",\
		\"weight\": 3903,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.extension\",\
		\"weight\": 3904,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.modifierExtension\",\
		\"weight\": 3905,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.purpose\",\
		\"weight\": 3906,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.name\",\
		\"weight\": 3907,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.telecom\",\
		\"weight\": 3908,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.address\",\
		\"weight\": 3909,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient\",\
		\"weight\": 3910,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.id\",\
		\"weight\": 3911,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.meta\",\
		\"weight\": 3912,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.implicitRules\",\
		\"weight\": 3913,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.language\",\
		\"weight\": 3914,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.text\",\
		\"weight\": 3915,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contained\",\
		\"weight\": 3916,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.extension\",\
		\"weight\": 3917,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.modifierExtension\",\
		\"weight\": 3918,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.identifier\",\
		\"weight\": 3919,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.active\",\
		\"weight\": 3920,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.name\",\
		\"weight\": 3921,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.telecom\",\
		\"weight\": 3922,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.gender\",\
		\"weight\": 3923,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.birthDate\",\
		\"weight\": 3924,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.deceasedBoolean\",\
		\"weight\": 3925,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.deceasedDateTime\",\
		\"weight\": 3925,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.address\",\
		\"weight\": 3926,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.maritalStatus\",\
		\"weight\": 3927,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.multipleBirthBoolean\",\
		\"weight\": 3928,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.multipleBirthInteger\",\
		\"weight\": 3928,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.photo\",\
		\"weight\": 3929,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact\",\
		\"weight\": 3930,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.id\",\
		\"weight\": 3931,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.extension\",\
		\"weight\": 3932,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.modifierExtension\",\
		\"weight\": 3933,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.relationship\",\
		\"weight\": 3934,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.name\",\
		\"weight\": 3935,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.telecom\",\
		\"weight\": 3936,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.address\",\
		\"weight\": 3937,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.gender\",\
		\"weight\": 3938,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.organization\",\
		\"weight\": 3939,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.period\",\
		\"weight\": 3940,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal\",\
		\"weight\": 3941,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.id\",\
		\"weight\": 3942,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.extension\",\
		\"weight\": 3943,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.animal.modifierExtension\",\
		\"weight\": 3944,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.animal.species\",\
		\"weight\": 3945,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.breed\",\
		\"weight\": 3946,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.genderStatus\",\
		\"weight\": 3947,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication\",\
		\"weight\": 3948,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.id\",\
		\"weight\": 3949,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication.extension\",\
		\"weight\": 3950,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.modifierExtension\",\
		\"weight\": 3951,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.language\",\
		\"weight\": 3952,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication.preferred\",\
		\"weight\": 3953,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.careProvider\",\
		\"weight\": 3954,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.managingOrganization\",\
		\"weight\": 3955,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link\",\
		\"weight\": 3956,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.id\",\
		\"weight\": 3957,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link.extension\",\
		\"weight\": 3958,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.modifierExtension\",\
		\"weight\": 3959,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.other\",\
		\"weight\": 3960,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link.type\",\
		\"weight\": 3961,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice\",\
		\"weight\": 3962,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.id\",\
		\"weight\": 3963,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.meta\",\
		\"weight\": 3964,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.implicitRules\",\
		\"weight\": 3965,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.language\",\
		\"weight\": 3966,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.text\",\
		\"weight\": 3967,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.contained\",\
		\"weight\": 3968,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.extension\",\
		\"weight\": 3969,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.modifierExtension\",\
		\"weight\": 3970,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.identifier\",\
		\"weight\": 3971,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.ruleset\",\
		\"weight\": 3972,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.originalRuleset\",\
		\"weight\": 3973,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.created\",\
		\"weight\": 3974,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.targetIdentifier\",\
		\"weight\": 3975,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.targetReference\",\
		\"weight\": 3975,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.providerIdentifier\",\
		\"weight\": 3976,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.providerReference\",\
		\"weight\": 3976,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.organizationIdentifier\",\
		\"weight\": 3977,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.organizationReference\",\
		\"weight\": 3977,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.requestIdentifier\",\
		\"weight\": 3978,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.requestReference\",\
		\"weight\": 3978,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.responseIdentifier\",\
		\"weight\": 3979,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.responseReference\",\
		\"weight\": 3979,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.paymentStatus\",\
		\"weight\": 3980,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.statusDate\",\
		\"weight\": 3981,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation\",\
		\"weight\": 3982,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.id\",\
		\"weight\": 3983,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.meta\",\
		\"weight\": 3984,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.implicitRules\",\
		\"weight\": 3985,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.language\",\
		\"weight\": 3986,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.text\",\
		\"weight\": 3987,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.contained\",\
		\"weight\": 3988,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.extension\",\
		\"weight\": 3989,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.modifierExtension\",\
		\"weight\": 3990,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.identifier\",\
		\"weight\": 3991,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestIdentifier\",\
		\"weight\": 3992,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestReference\",\
		\"weight\": 3992,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.outcome\",\
		\"weight\": 3993,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.disposition\",\
		\"weight\": 3994,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.ruleset\",\
		\"weight\": 3995,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.originalRuleset\",\
		\"weight\": 3996,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.created\",\
		\"weight\": 3997,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.period\",\
		\"weight\": 3998,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.organizationIdentifier\",\
		\"weight\": 3999,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.organizationReference\",\
		\"weight\": 3999,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestProviderIdentifier\",\
		\"weight\": 4000,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestProviderReference\",\
		\"weight\": 4000,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestOrganizationIdentifier\",\
		\"weight\": 4001,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestOrganizationReference\",\
		\"weight\": 4001,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail\",\
		\"weight\": 4002,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.id\",\
		\"weight\": 4003,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.extension\",\
		\"weight\": 4004,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.modifierExtension\",\
		\"weight\": 4005,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.type\",\
		\"weight\": 4006,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.requestIdentifier\",\
		\"weight\": 4007,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.requestReference\",\
		\"weight\": 4007,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.responceIdentifier\",\
		\"weight\": 4008,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.responceReference\",\
		\"weight\": 4008,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.submitterIdentifier\",\
		\"weight\": 4009,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.submitterReference\",\
		\"weight\": 4009,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.payeeIdentifier\",\
		\"weight\": 4010,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.payeeReference\",\
		\"weight\": 4010,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.date\",\
		\"weight\": 4011,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.amount\",\
		\"weight\": 4012,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.form\",\
		\"weight\": 4013,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.total\",\
		\"weight\": 4014,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note\",\
		\"weight\": 4015,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.id\",\
		\"weight\": 4016,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.extension\",\
		\"weight\": 4017,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.modifierExtension\",\
		\"weight\": 4018,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.type\",\
		\"weight\": 4019,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.text\",\
		\"weight\": 4020,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person\",\
		\"weight\": 4021,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.id\",\
		\"weight\": 4022,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.meta\",\
		\"weight\": 4023,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.implicitRules\",\
		\"weight\": 4024,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.language\",\
		\"weight\": 4025,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.text\",\
		\"weight\": 4026,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.contained\",\
		\"weight\": 4027,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.extension\",\
		\"weight\": 4028,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.modifierExtension\",\
		\"weight\": 4029,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.identifier\",\
		\"weight\": 4030,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.name\",\
		\"weight\": 4031,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.telecom\",\
		\"weight\": 4032,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.gender\",\
		\"weight\": 4033,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.birthDate\",\
		\"weight\": 4034,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.address\",\
		\"weight\": 4035,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.photo\",\
		\"weight\": 4036,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.managingOrganization\",\
		\"weight\": 4037,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.active\",\
		\"weight\": 4038,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link\",\
		\"weight\": 4039,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.id\",\
		\"weight\": 4040,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link.extension\",\
		\"weight\": 4041,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.modifierExtension\",\
		\"weight\": 4042,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.target\",\
		\"weight\": 4043,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link.assurance\",\
		\"weight\": 4044,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner\",\
		\"weight\": 4045,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.id\",\
		\"weight\": 4046,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.meta\",\
		\"weight\": 4047,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.implicitRules\",\
		\"weight\": 4048,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.language\",\
		\"weight\": 4049,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.text\",\
		\"weight\": 4050,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.contained\",\
		\"weight\": 4051,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.extension\",\
		\"weight\": 4052,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.modifierExtension\",\
		\"weight\": 4053,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.identifier\",\
		\"weight\": 4054,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.active\",\
		\"weight\": 4055,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.name\",\
		\"weight\": 4056,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.telecom\",\
		\"weight\": 4057,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.address\",\
		\"weight\": 4058,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.gender\",\
		\"weight\": 4059,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.birthDate\",\
		\"weight\": 4060,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.photo\",\
		\"weight\": 4061,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole\",\
		\"weight\": 4062,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.id\",\
		\"weight\": 4063,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.extension\",\
		\"weight\": 4064,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.modifierExtension\",\
		\"weight\": 4065,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.organization\",\
		\"weight\": 4066,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.role\",\
		\"weight\": 4067,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.specialty\",\
		\"weight\": 4068,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.identifier\",\
		\"weight\": 4069,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.telecom\",\
		\"weight\": 4070,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.period\",\
		\"weight\": 4071,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.location\",\
		\"weight\": 4072,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.healthcareService\",\
		\"weight\": 4073,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification\",\
		\"weight\": 4074,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.id\",\
		\"weight\": 4075,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.extension\",\
		\"weight\": 4076,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.modifierExtension\",\
		\"weight\": 4077,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.identifier\",\
		\"weight\": 4078,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.code\",\
		\"weight\": 4079,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.period\",\
		\"weight\": 4080,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.issuer\",\
		\"weight\": 4081,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.communication\",\
		\"weight\": 4082,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole\",\
		\"weight\": 4083,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.id\",\
		\"weight\": 4084,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.meta\",\
		\"weight\": 4085,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.implicitRules\",\
		\"weight\": 4086,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.language\",\
		\"weight\": 4087,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.text\",\
		\"weight\": 4088,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.contained\",\
		\"weight\": 4089,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.extension\",\
		\"weight\": 4090,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.modifierExtension\",\
		\"weight\": 4091,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.identifier\",\
		\"weight\": 4092,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.active\",\
		\"weight\": 4093,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.practitioner\",\
		\"weight\": 4094,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.organization\",\
		\"weight\": 4095,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.role\",\
		\"weight\": 4096,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.specialty\",\
		\"weight\": 4097,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.location\",\
		\"weight\": 4098,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.healthcareService\",\
		\"weight\": 4099,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.telecom\",\
		\"weight\": 4100,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.period\",\
		\"weight\": 4101,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime\",\
		\"weight\": 4102,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.id\",\
		\"weight\": 4103,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.extension\",\
		\"weight\": 4104,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.modifierExtension\",\
		\"weight\": 4105,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.daysOfWeek\",\
		\"weight\": 4106,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.allDay\",\
		\"weight\": 4107,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.availableStartTime\",\
		\"weight\": 4108,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.availableEndTime\",\
		\"weight\": 4109,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable\",\
		\"weight\": 4110,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.id\",\
		\"weight\": 4111,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.extension\",\
		\"weight\": 4112,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.modifierExtension\",\
		\"weight\": 4113,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.description\",\
		\"weight\": 4114,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.during\",\
		\"weight\": 4115,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availabilityExceptions\",\
		\"weight\": 4116,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure\",\
		\"weight\": 4117,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.id\",\
		\"weight\": 4118,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.meta\",\
		\"weight\": 4119,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.implicitRules\",\
		\"weight\": 4120,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.language\",\
		\"weight\": 4121,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.text\",\
		\"weight\": 4122,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.contained\",\
		\"weight\": 4123,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.extension\",\
		\"weight\": 4124,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.modifierExtension\",\
		\"weight\": 4125,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.identifier\",\
		\"weight\": 4126,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.subject\",\
		\"weight\": 4127,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.status\",\
		\"weight\": 4128,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.category\",\
		\"weight\": 4129,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.code\",\
		\"weight\": 4130,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.notPerformed\",\
		\"weight\": 4131,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.reasonNotPerformed\",\
		\"weight\": 4132,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.bodySite\",\
		\"weight\": 4133,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.reasonCodeableConcept\",\
		\"weight\": 4134,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.reasonReference\",\
		\"weight\": 4134,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performer\",\
		\"weight\": 4135,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.id\",\
		\"weight\": 4136,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performer.extension\",\
		\"weight\": 4137,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.modifierExtension\",\
		\"weight\": 4138,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.actor\",\
		\"weight\": 4139,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performer.role\",\
		\"weight\": 4140,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performedDateTime\",\
		\"weight\": 4141,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performedPeriod\",\
		\"weight\": 4141,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.encounter\",\
		\"weight\": 4142,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.location\",\
		\"weight\": 4143,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.outcome\",\
		\"weight\": 4144,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.report\",\
		\"weight\": 4145,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.complication\",\
		\"weight\": 4146,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.followUp\",\
		\"weight\": 4147,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.request\",\
		\"weight\": 4148,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.notes\",\
		\"weight\": 4149,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice\",\
		\"weight\": 4150,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.id\",\
		\"weight\": 4151,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.extension\",\
		\"weight\": 4152,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.modifierExtension\",\
		\"weight\": 4153,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.action\",\
		\"weight\": 4154,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.manipulated\",\
		\"weight\": 4155,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.used\",\
		\"weight\": 4156,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest\",\
		\"weight\": 4157,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.id\",\
		\"weight\": 4158,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.meta\",\
		\"weight\": 4159,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.implicitRules\",\
		\"weight\": 4160,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.language\",\
		\"weight\": 4161,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.text\",\
		\"weight\": 4162,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.contained\",\
		\"weight\": 4163,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.extension\",\
		\"weight\": 4164,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.modifierExtension\",\
		\"weight\": 4165,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.identifier\",\
		\"weight\": 4166,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.subject\",\
		\"weight\": 4167,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.code\",\
		\"weight\": 4168,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.bodySite\",\
		\"weight\": 4169,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.reasonCodeableConcept\",\
		\"weight\": 4170,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.reasonReference\",\
		\"weight\": 4170,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledDateTime\",\
		\"weight\": 4171,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledPeriod\",\
		\"weight\": 4171,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledTiming\",\
		\"weight\": 4171,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.encounter\",\
		\"weight\": 4172,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.performer\",\
		\"weight\": 4173,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.status\",\
		\"weight\": 4174,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.notes\",\
		\"weight\": 4175,\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.asNeededBoolean\",\
		\"weight\": 4176,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.asNeededCodeableConcept\",\
		\"weight\": 4176,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.orderedOn\",\
		\"weight\": 4177,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.orderer\",\
		\"weight\": 4178,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.priority\",\
		\"weight\": 4179,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest\",\
		\"weight\": 4180,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.id\",\
		\"weight\": 4181,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.meta\",\
		\"weight\": 4182,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.implicitRules\",\
		\"weight\": 4183,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.language\",\
		\"weight\": 4184,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.text\",\
		\"weight\": 4185,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.contained\",\
		\"weight\": 4186,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.extension\",\
		\"weight\": 4187,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.modifierExtension\",\
		\"weight\": 4188,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.action\",\
		\"weight\": 4189,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.identifier\",\
		\"weight\": 4190,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.ruleset\",\
		\"weight\": 4191,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.originalRuleset\",\
		\"weight\": 4192,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.created\",\
		\"weight\": 4193,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.targetIdentifier\",\
		\"weight\": 4194,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.targetReference\",\
		\"weight\": 4194,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.providerIdentifier\",\
		\"weight\": 4195,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.providerReference\",\
		\"weight\": 4195,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.organizationIdentifier\",\
		\"weight\": 4196,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.organizationReference\",\
		\"weight\": 4196,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.requestIdentifier\",\
		\"weight\": 4197,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.requestReference\",\
		\"weight\": 4197,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.responseIdentifier\",\
		\"weight\": 4198,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.responseReference\",\
		\"weight\": 4198,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.nullify\",\
		\"weight\": 4199,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.reference\",\
		\"weight\": 4200,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.item\",\
		\"weight\": 4201,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.id\",\
		\"weight\": 4202,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.extension\",\
		\"weight\": 4203,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.modifierExtension\",\
		\"weight\": 4204,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.sequenceLinkId\",\
		\"weight\": 4205,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.include\",\
		\"weight\": 4206,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.exclude\",\
		\"weight\": 4207,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.period\",\
		\"weight\": 4208,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse\",\
		\"weight\": 4209,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.id\",\
		\"weight\": 4210,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.meta\",\
		\"weight\": 4211,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.implicitRules\",\
		\"weight\": 4212,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.language\",\
		\"weight\": 4213,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.text\",\
		\"weight\": 4214,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.contained\",\
		\"weight\": 4215,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.extension\",\
		\"weight\": 4216,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.modifierExtension\",\
		\"weight\": 4217,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.identifier\",\
		\"weight\": 4218,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestIdentifier\",\
		\"weight\": 4219,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestReference\",\
		\"weight\": 4219,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.outcome\",\
		\"weight\": 4220,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.disposition\",\
		\"weight\": 4221,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.ruleset\",\
		\"weight\": 4222,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.originalRuleset\",\
		\"weight\": 4223,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.created\",\
		\"weight\": 4224,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.organizationIdentifier\",\
		\"weight\": 4225,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.organizationReference\",\
		\"weight\": 4225,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestProviderIdentifier\",\
		\"weight\": 4226,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestProviderReference\",\
		\"weight\": 4226,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestOrganizationIdentifier\",\
		\"weight\": 4227,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestOrganizationReference\",\
		\"weight\": 4227,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.form\",\
		\"weight\": 4228,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes\",\
		\"weight\": 4229,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.id\",\
		\"weight\": 4230,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.extension\",\
		\"weight\": 4231,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.modifierExtension\",\
		\"weight\": 4232,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.type\",\
		\"weight\": 4233,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.text\",\
		\"weight\": 4234,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.error\",\
		\"weight\": 4235,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol\",\
		\"weight\": 4236,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.id\",\
		\"weight\": 4237,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.meta\",\
		\"weight\": 4238,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.implicitRules\",\
		\"weight\": 4239,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.language\",\
		\"weight\": 4240,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.text\",\
		\"weight\": 4241,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.contained\",\
		\"weight\": 4242,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.extension\",\
		\"weight\": 4243,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.modifierExtension\",\
		\"weight\": 4244,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.identifier\",\
		\"weight\": 4245,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.title\",\
		\"weight\": 4246,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.status\",\
		\"weight\": 4247,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.type\",\
		\"weight\": 4248,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.subject\",\
		\"weight\": 4249,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.group\",\
		\"weight\": 4250,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.purpose\",\
		\"weight\": 4251,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.author\",\
		\"weight\": 4252,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step\",\
		\"weight\": 4253,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.id\",\
		\"weight\": 4254,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.extension\",\
		\"weight\": 4255,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.modifierExtension\",\
		\"weight\": 4256,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.name\",\
		\"weight\": 4257,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.description\",\
		\"weight\": 4258,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.duration\",\
		\"weight\": 4259,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition\",\
		\"weight\": 4260,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.id\",\
		\"weight\": 4261,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.extension\",\
		\"weight\": 4262,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.modifierExtension\",\
		\"weight\": 4263,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.description\",\
		\"weight\": 4264,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition\",\
		\"weight\": 4265,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.id\",\
		\"weight\": 4266,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.extension\",\
		\"weight\": 4267,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.modifierExtension\",\
		\"weight\": 4268,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.type\",\
		\"weight\": 4269,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.valueCodeableConcept\",\
		\"weight\": 4270,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.valueBoolean\",\
		\"weight\": 4270,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.valueQuantity\",\
		\"weight\": 4270,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.valueRange\",\
		\"weight\": 4270,\
		\"type\": \"Range\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.intersection\",\
		\"weight\": 4271,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.union\",\
		\"weight\": 4272,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.exclude\",\
		\"weight\": 4273,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.exit\",\
		\"weight\": 4274,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.firstActivity\",\
		\"weight\": 4275,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity\",\
		\"weight\": 4276,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.id\",\
		\"weight\": 4277,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.extension\",\
		\"weight\": 4278,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.modifierExtension\",\
		\"weight\": 4279,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.alternative\",\
		\"weight\": 4280,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component\",\
		\"weight\": 4281,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.id\",\
		\"weight\": 4282,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.extension\",\
		\"weight\": 4283,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.modifierExtension\",\
		\"weight\": 4284,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.sequence\",\
		\"weight\": 4285,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.activity\",\
		\"weight\": 4286,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.following\",\
		\"weight\": 4287,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.wait\",\
		\"weight\": 4288,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail\",\
		\"weight\": 4289,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.id\",\
		\"weight\": 4290,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.extension\",\
		\"weight\": 4291,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.modifierExtension\",\
		\"weight\": 4292,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.category\",\
		\"weight\": 4293,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.code\",\
		\"weight\": 4294,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.timingCodeableConcept\",\
		\"weight\": 4295,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.timingTiming\",\
		\"weight\": 4295,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.location\",\
		\"weight\": 4296,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.performer\",\
		\"weight\": 4297,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.product\",\
		\"weight\": 4298,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.quantity\",\
		\"weight\": 4299,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.description\",\
		\"weight\": 4300,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.next\",\
		\"weight\": 4301,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.next.id\",\
		\"weight\": 4302,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.next.extension\",\
		\"weight\": 4303,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.next.modifierExtension\",\
		\"weight\": 4304,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.next.description\",\
		\"weight\": 4305,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.next.reference\",\
		\"weight\": 4306,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.next.condition\",\
		\"weight\": 4307,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance\",\
		\"weight\": 4308,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.id\",\
		\"weight\": 4309,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.meta\",\
		\"weight\": 4310,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.implicitRules\",\
		\"weight\": 4311,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.language\",\
		\"weight\": 4312,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.text\",\
		\"weight\": 4313,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.contained\",\
		\"weight\": 4314,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.extension\",\
		\"weight\": 4315,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.modifierExtension\",\
		\"weight\": 4316,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.target\",\
		\"weight\": 4317,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.period\",\
		\"weight\": 4318,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.recorded\",\
		\"weight\": 4319,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.reason\",\
		\"weight\": 4320,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.activity\",\
		\"weight\": 4321,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.location\",\
		\"weight\": 4322,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.policy\",\
		\"weight\": 4323,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent\",\
		\"weight\": 4324,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.id\",\
		\"weight\": 4325,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.extension\",\
		\"weight\": 4326,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.modifierExtension\",\
		\"weight\": 4327,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.role\",\
		\"weight\": 4328,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.actor\",\
		\"weight\": 4329,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.userId\",\
		\"weight\": 4330,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent\",\
		\"weight\": 4331,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.id\",\
		\"weight\": 4332,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.extension\",\
		\"weight\": 4333,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.modifierExtension\",\
		\"weight\": 4334,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.type\",\
		\"weight\": 4335,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.target\",\
		\"weight\": 4336,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity\",\
		\"weight\": 4337,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.id\",\
		\"weight\": 4338,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.extension\",\
		\"weight\": 4339,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.modifierExtension\",\
		\"weight\": 4340,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.role\",\
		\"weight\": 4341,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.type\",\
		\"weight\": 4342,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.reference\",\
		\"weight\": 4343,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.display\",\
		\"weight\": 4344,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.agent\",\
		\"weight\": 4345,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.signature\",\
		\"weight\": 4346,\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire\",\
		\"weight\": 4347,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.id\",\
		\"weight\": 4348,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.meta\",\
		\"weight\": 4349,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.implicitRules\",\
		\"weight\": 4350,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.language\",\
		\"weight\": 4351,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.text\",\
		\"weight\": 4352,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.contained\",\
		\"weight\": 4353,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.extension\",\
		\"weight\": 4354,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.modifierExtension\",\
		\"weight\": 4355,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.url\",\
		\"weight\": 4356,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.identifier\",\
		\"weight\": 4357,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.version\",\
		\"weight\": 4358,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.status\",\
		\"weight\": 4359,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.date\",\
		\"weight\": 4360,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.publisher\",\
		\"weight\": 4361,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.telecom\",\
		\"weight\": 4362,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.useContext\",\
		\"weight\": 4363,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.title\",\
		\"weight\": 4364,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.concept\",\
		\"weight\": 4365,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.subjectType\",\
		\"weight\": 4366,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item\",\
		\"weight\": 4367,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.id\",\
		\"weight\": 4368,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.extension\",\
		\"weight\": 4369,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.modifierExtension\",\
		\"weight\": 4370,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.linkId\",\
		\"weight\": 4371,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.concept\",\
		\"weight\": 4372,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.prefix\",\
		\"weight\": 4373,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.text\",\
		\"weight\": 4374,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.type\",\
		\"weight\": 4375,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen\",\
		\"weight\": 4376,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.id\",\
		\"weight\": 4377,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.extension\",\
		\"weight\": 4378,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.modifierExtension\",\
		\"weight\": 4379,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.question\",\
		\"weight\": 4380,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.hasAnswer\",\
		\"weight\": 4381,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerBoolean\",\
		\"weight\": 4382,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDecimal\",\
		\"weight\": 4382,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerInteger\",\
		\"weight\": 4382,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDate\",\
		\"weight\": 4382,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDateTime\",\
		\"weight\": 4382,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerInstant\",\
		\"weight\": 4382,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerTime\",\
		\"weight\": 4382,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerString\",\
		\"weight\": 4382,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerUri\",\
		\"weight\": 4382,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerAttachment\",\
		\"weight\": 4382,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerCoding\",\
		\"weight\": 4382,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerQuantity\",\
		\"weight\": 4382,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerReference\",\
		\"weight\": 4382,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.required\",\
		\"weight\": 4383,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.repeats\",\
		\"weight\": 4384,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.readOnly\",\
		\"weight\": 4385,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.maxLength\",\
		\"weight\": 4386,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.options\",\
		\"weight\": 4387,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option\",\
		\"weight\": 4388,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.id\",\
		\"weight\": 4389,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.extension\",\
		\"weight\": 4390,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.modifierExtension\",\
		\"weight\": 4391,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueInteger\",\
		\"weight\": 4392,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueDate\",\
		\"weight\": 4392,\
		\"type\": \"date\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueTime\",\
		\"weight\": 4392,\
		\"type\": \"time\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueString\",\
		\"weight\": 4392,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueCoding\",\
		\"weight\": 4392,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialBoolean\",\
		\"weight\": 4393,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDecimal\",\
		\"weight\": 4393,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialInteger\",\
		\"weight\": 4393,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDate\",\
		\"weight\": 4393,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDateTime\",\
		\"weight\": 4393,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialInstant\",\
		\"weight\": 4393,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialTime\",\
		\"weight\": 4393,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialString\",\
		\"weight\": 4393,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialUri\",\
		\"weight\": 4393,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialAttachment\",\
		\"weight\": 4393,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialCoding\",\
		\"weight\": 4393,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialQuantity\",\
		\"weight\": 4393,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialReference\",\
		\"weight\": 4393,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.item\",\
		\"weight\": 4394,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse\",\
		\"weight\": 4395,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.id\",\
		\"weight\": 4396,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.meta\",\
		\"weight\": 4397,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.implicitRules\",\
		\"weight\": 4398,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.language\",\
		\"weight\": 4399,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.text\",\
		\"weight\": 4400,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.contained\",\
		\"weight\": 4401,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.extension\",\
		\"weight\": 4402,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.modifierExtension\",\
		\"weight\": 4403,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.identifier\",\
		\"weight\": 4404,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.questionnaire\",\
		\"weight\": 4405,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.status\",\
		\"weight\": 4406,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.subject\",\
		\"weight\": 4407,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.author\",\
		\"weight\": 4408,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.authored\",\
		\"weight\": 4409,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.source\",\
		\"weight\": 4410,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.encounter\",\
		\"weight\": 4411,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item\",\
		\"weight\": 4412,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.id\",\
		\"weight\": 4413,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.extension\",\
		\"weight\": 4414,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.modifierExtension\",\
		\"weight\": 4415,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.linkId\",\
		\"weight\": 4416,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.text\",\
		\"weight\": 4417,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.subject\",\
		\"weight\": 4418,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer\",\
		\"weight\": 4419,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.id\",\
		\"weight\": 4420,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.extension\",\
		\"weight\": 4421,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.modifierExtension\",\
		\"weight\": 4422,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueBoolean\",\
		\"weight\": 4423,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDecimal\",\
		\"weight\": 4423,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueInteger\",\
		\"weight\": 4423,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDate\",\
		\"weight\": 4423,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDateTime\",\
		\"weight\": 4423,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueInstant\",\
		\"weight\": 4423,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueTime\",\
		\"weight\": 4423,\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueString\",\
		\"weight\": 4423,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueUri\",\
		\"weight\": 4423,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueAttachment\",\
		\"weight\": 4423,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueCoding\",\
		\"weight\": 4423,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueQuantity\",\
		\"weight\": 4423,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueReference\",\
		\"weight\": 4423,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.item\",\
		\"weight\": 4424,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.item\",\
		\"weight\": 4425,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest\",\
		\"weight\": 4426,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.id\",\
		\"weight\": 4427,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.meta\",\
		\"weight\": 4428,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.implicitRules\",\
		\"weight\": 4429,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.language\",\
		\"weight\": 4430,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.text\",\
		\"weight\": 4431,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.contained\",\
		\"weight\": 4432,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.extension\",\
		\"weight\": 4433,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.modifierExtension\",\
		\"weight\": 4434,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.identifier\",\
		\"weight\": 4435,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.basedOn\",\
		\"weight\": 4436,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.parent\",\
		\"weight\": 4437,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.status\",\
		\"weight\": 4438,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.category\",\
		\"weight\": 4439,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.type\",\
		\"weight\": 4440,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.priority\",\
		\"weight\": 4441,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.patient\",\
		\"weight\": 4442,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.context\",\
		\"weight\": 4443,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.fulfillmentTime\",\
		\"weight\": 4444,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.authored\",\
		\"weight\": 4445,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.requester\",\
		\"weight\": 4446,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.specialty\",\
		\"weight\": 4447,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.recipient\",\
		\"weight\": 4448,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.reason\",\
		\"weight\": 4449,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.description\",\
		\"weight\": 4450,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.serviceRequested\",\
		\"weight\": 4451,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.supportingInformation\",\
		\"weight\": 4452,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson\",\
		\"weight\": 4453,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.id\",\
		\"weight\": 4454,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.meta\",\
		\"weight\": 4455,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.implicitRules\",\
		\"weight\": 4456,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.language\",\
		\"weight\": 4457,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.text\",\
		\"weight\": 4458,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.contained\",\
		\"weight\": 4459,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.extension\",\
		\"weight\": 4460,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.modifierExtension\",\
		\"weight\": 4461,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.identifier\",\
		\"weight\": 4462,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.patient\",\
		\"weight\": 4463,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.relationship\",\
		\"weight\": 4464,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.name\",\
		\"weight\": 4465,\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.telecom\",\
		\"weight\": 4466,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.gender\",\
		\"weight\": 4467,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.birthDate\",\
		\"weight\": 4468,\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.address\",\
		\"weight\": 4469,\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.photo\",\
		\"weight\": 4470,\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.period\",\
		\"weight\": 4471,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment\",\
		\"weight\": 4472,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.id\",\
		\"weight\": 4473,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.meta\",\
		\"weight\": 4474,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.implicitRules\",\
		\"weight\": 4475,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.language\",\
		\"weight\": 4476,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.text\",\
		\"weight\": 4477,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.contained\",\
		\"weight\": 4478,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.extension\",\
		\"weight\": 4479,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.modifierExtension\",\
		\"weight\": 4480,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.subject\",\
		\"weight\": 4481,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.date\",\
		\"weight\": 4482,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.condition\",\
		\"weight\": 4483,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.encounter\",\
		\"weight\": 4484,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.performer\",\
		\"weight\": 4485,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.identifier\",\
		\"weight\": 4486,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.method\",\
		\"weight\": 4487,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.basis\",\
		\"weight\": 4488,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction\",\
		\"weight\": 4489,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.id\",\
		\"weight\": 4490,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.extension\",\
		\"weight\": 4491,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.modifierExtension\",\
		\"weight\": 4492,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.outcome\",\
		\"weight\": 4493,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityDecimal\",\
		\"weight\": 4494,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityRange\",\
		\"weight\": 4494,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityCodeableConcept\",\
		\"weight\": 4494,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.relativeRisk\",\
		\"weight\": 4495,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.whenPeriod\",\
		\"weight\": 4496,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.whenRange\",\
		\"weight\": 4496,\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.rationale\",\
		\"weight\": 4497,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.mitigation\",\
		\"weight\": 4498,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule\",\
		\"weight\": 4499,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.id\",\
		\"weight\": 4500,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.meta\",\
		\"weight\": 4501,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.implicitRules\",\
		\"weight\": 4502,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.language\",\
		\"weight\": 4503,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.text\",\
		\"weight\": 4504,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.contained\",\
		\"weight\": 4505,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.extension\",\
		\"weight\": 4506,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.modifierExtension\",\
		\"weight\": 4507,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.identifier\",\
		\"weight\": 4508,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.serviceCategory\",\
		\"weight\": 4509,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.serviceType\",\
		\"weight\": 4510,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.specialty\",\
		\"weight\": 4511,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.actor\",\
		\"weight\": 4512,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.planningHorizon\",\
		\"weight\": 4513,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.comment\",\
		\"weight\": 4514,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter\",\
		\"weight\": 4515,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.id\",\
		\"weight\": 4516,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.meta\",\
		\"weight\": 4517,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.implicitRules\",\
		\"weight\": 4518,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.language\",\
		\"weight\": 4519,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.text\",\
		\"weight\": 4520,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contained\",\
		\"weight\": 4521,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.extension\",\
		\"weight\": 4522,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.modifierExtension\",\
		\"weight\": 4523,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.url\",\
		\"weight\": 4524,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.name\",\
		\"weight\": 4525,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.status\",\
		\"weight\": 4526,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.experimental\",\
		\"weight\": 4527,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.date\",\
		\"weight\": 4528,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.publisher\",\
		\"weight\": 4529,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact\",\
		\"weight\": 4530,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.id\",\
		\"weight\": 4531,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.extension\",\
		\"weight\": 4532,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.modifierExtension\",\
		\"weight\": 4533,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.name\",\
		\"weight\": 4534,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.telecom\",\
		\"weight\": 4535,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.useContext\",\
		\"weight\": 4536,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.requirements\",\
		\"weight\": 4537,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.code\",\
		\"weight\": 4538,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.base\",\
		\"weight\": 4539,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.type\",\
		\"weight\": 4540,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.description\",\
		\"weight\": 4541,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.expression\",\
		\"weight\": 4542,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.xpath\",\
		\"weight\": 4543,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.xpathUsage\",\
		\"weight\": 4544,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.target\",\
		\"weight\": 4545,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence\",\
		\"weight\": 4546,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.id\",\
		\"weight\": 4547,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.meta\",\
		\"weight\": 4548,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.implicitRules\",\
		\"weight\": 4549,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.language\",\
		\"weight\": 4550,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.text\",\
		\"weight\": 4551,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.contained\",\
		\"weight\": 4552,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.extension\",\
		\"weight\": 4553,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.modifierExtension\",\
		\"weight\": 4554,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.type\",\
		\"weight\": 4555,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.patient\",\
		\"weight\": 4556,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.specimen\",\
		\"weight\": 4557,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.device\",\
		\"weight\": 4558,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quantity\",\
		\"weight\": 4559,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.species\",\
		\"weight\": 4560,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq\",\
		\"weight\": 4561,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.id\",\
		\"weight\": 4562,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.extension\",\
		\"weight\": 4563,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.modifierExtension\",\
		\"weight\": 4564,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.chromosome\",\
		\"weight\": 4565,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.genomeBuild\",\
		\"weight\": 4566,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqId\",\
		\"weight\": 4567,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqPointer\",\
		\"weight\": 4568,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqString\",\
		\"weight\": 4569,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.windowStart\",\
		\"weight\": 4570,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.windowEnd\",\
		\"weight\": 4571,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation\",\
		\"weight\": 4572,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.id\",\
		\"weight\": 4573,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.extension\",\
		\"weight\": 4574,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.variation.modifierExtension\",\
		\"weight\": 4575,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.variation.start\",\
		\"weight\": 4576,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.end\",\
		\"weight\": 4577,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.observedAllele\",\
		\"weight\": 4578,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.referenceAllele\",\
		\"weight\": 4579,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.cigar\",\
		\"weight\": 4580,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality\",\
		\"weight\": 4581,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.id\",\
		\"weight\": 4582,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.extension\",\
		\"weight\": 4583,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.modifierExtension\",\
		\"weight\": 4584,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.start\",\
		\"weight\": 4585,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.end\",\
		\"weight\": 4586,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.score\",\
		\"weight\": 4587,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.method\",\
		\"weight\": 4588,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.allelicState\",\
		\"weight\": 4589,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.allelicFrequency\",\
		\"weight\": 4590,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.copyNumberEvent\",\
		\"weight\": 4591,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.readCoverage\",\
		\"weight\": 4592,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository\",\
		\"weight\": 4593,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.id\",\
		\"weight\": 4594,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.extension\",\
		\"weight\": 4595,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.modifierExtension\",\
		\"weight\": 4596,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.url\",\
		\"weight\": 4597,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.name\",\
		\"weight\": 4598,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.variantId\",\
		\"weight\": 4599,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.readId\",\
		\"weight\": 4600,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.pointer\",\
		\"weight\": 4601,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.observedSeq\",\
		\"weight\": 4602,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.observation\",\
		\"weight\": 4603,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation\",\
		\"weight\": 4604,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.id\",\
		\"weight\": 4605,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.extension\",\
		\"weight\": 4606,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.modifierExtension\",\
		\"weight\": 4607,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.precisionOfBoundaries\",\
		\"weight\": 4608,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.reportedaCGHRatio\",\
		\"weight\": 4609,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.length\",\
		\"weight\": 4610,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer\",\
		\"weight\": 4611,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.id\",\
		\"weight\": 4612,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.extension\",\
		\"weight\": 4613,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.modifierExtension\",\
		\"weight\": 4614,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.start\",\
		\"weight\": 4615,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.end\",\
		\"weight\": 4616,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner\",\
		\"weight\": 4617,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.id\",\
		\"weight\": 4618,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.extension\",\
		\"weight\": 4619,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.modifierExtension\",\
		\"weight\": 4620,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.start\",\
		\"weight\": 4621,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.end\",\
		\"weight\": 4622,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot\",\
		\"weight\": 4623,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.id\",\
		\"weight\": 4624,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.meta\",\
		\"weight\": 4625,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.implicitRules\",\
		\"weight\": 4626,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.language\",\
		\"weight\": 4627,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.text\",\
		\"weight\": 4628,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.contained\",\
		\"weight\": 4629,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.extension\",\
		\"weight\": 4630,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.modifierExtension\",\
		\"weight\": 4631,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.identifier\",\
		\"weight\": 4632,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.serviceCategory\",\
		\"weight\": 4633,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.serviceType\",\
		\"weight\": 4634,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.specialty\",\
		\"weight\": 4635,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.appointmentType\",\
		\"weight\": 4636,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.schedule\",\
		\"weight\": 4637,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.status\",\
		\"weight\": 4638,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.start\",\
		\"weight\": 4639,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.end\",\
		\"weight\": 4640,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.overbooked\",\
		\"weight\": 4641,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.comment\",\
		\"weight\": 4642,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen\",\
		\"weight\": 4643,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.id\",\
		\"weight\": 4644,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.meta\",\
		\"weight\": 4645,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.implicitRules\",\
		\"weight\": 4646,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.language\",\
		\"weight\": 4647,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.text\",\
		\"weight\": 4648,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.contained\",\
		\"weight\": 4649,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.extension\",\
		\"weight\": 4650,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.modifierExtension\",\
		\"weight\": 4651,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.identifier\",\
		\"weight\": 4652,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.accessionIdentifier\",\
		\"weight\": 4653,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.status\",\
		\"weight\": 4654,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.type\",\
		\"weight\": 4655,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.subject\",\
		\"weight\": 4656,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.receivedTime\",\
		\"weight\": 4657,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.parent\",\
		\"weight\": 4658,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection\",\
		\"weight\": 4659,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.id\",\
		\"weight\": 4660,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.extension\",\
		\"weight\": 4661,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection.modifierExtension\",\
		\"weight\": 4662,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection.collector\",\
		\"weight\": 4663,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.comment\",\
		\"weight\": 4664,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.collectedDateTime\",\
		\"weight\": 4665,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.collectedPeriod\",\
		\"weight\": 4665,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.quantity\",\
		\"weight\": 4666,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.method\",\
		\"weight\": 4667,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.bodySite\",\
		\"weight\": 4668,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment\",\
		\"weight\": 4669,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.id\",\
		\"weight\": 4670,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.extension\",\
		\"weight\": 4671,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.modifierExtension\",\
		\"weight\": 4672,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.description\",\
		\"weight\": 4673,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.procedure\",\
		\"weight\": 4674,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.additive\",\
		\"weight\": 4675,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container\",\
		\"weight\": 4676,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.id\",\
		\"weight\": 4677,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.extension\",\
		\"weight\": 4678,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.modifierExtension\",\
		\"weight\": 4679,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.identifier\",\
		\"weight\": 4680,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.description\",\
		\"weight\": 4681,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.type\",\
		\"weight\": 4682,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.capacity\",\
		\"weight\": 4683,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.specimenQuantity\",\
		\"weight\": 4684,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.additiveCodeableConcept\",\
		\"weight\": 4685,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.additiveReference\",\
		\"weight\": 4685,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition\",\
		\"weight\": 4686,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.id\",\
		\"weight\": 4687,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.meta\",\
		\"weight\": 4688,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.implicitRules\",\
		\"weight\": 4689,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.language\",\
		\"weight\": 4690,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.text\",\
		\"weight\": 4691,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contained\",\
		\"weight\": 4692,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.extension\",\
		\"weight\": 4693,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.modifierExtension\",\
		\"weight\": 4694,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.url\",\
		\"weight\": 4695,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.identifier\",\
		\"weight\": 4696,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.version\",\
		\"weight\": 4697,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.name\",\
		\"weight\": 4698,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.display\",\
		\"weight\": 4699,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.status\",\
		\"weight\": 4700,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.experimental\",\
		\"weight\": 4701,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.publisher\",\
		\"weight\": 4702,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact\",\
		\"weight\": 4703,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.id\",\
		\"weight\": 4704,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.extension\",\
		\"weight\": 4705,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.modifierExtension\",\
		\"weight\": 4706,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.name\",\
		\"weight\": 4707,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.telecom\",\
		\"weight\": 4708,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.date\",\
		\"weight\": 4709,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.description\",\
		\"weight\": 4710,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.useContext\",\
		\"weight\": 4711,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.requirements\",\
		\"weight\": 4712,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.copyright\",\
		\"weight\": 4713,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.code\",\
		\"weight\": 4714,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.fhirVersion\",\
		\"weight\": 4715,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping\",\
		\"weight\": 4716,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.id\",\
		\"weight\": 4717,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.extension\",\
		\"weight\": 4718,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.modifierExtension\",\
		\"weight\": 4719,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.identity\",\
		\"weight\": 4720,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.uri\",\
		\"weight\": 4721,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.name\",\
		\"weight\": 4722,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.comments\",\
		\"weight\": 4723,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.kind\",\
		\"weight\": 4724,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.abstract\",\
		\"weight\": 4725,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contextType\",\
		\"weight\": 4726,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.context\",\
		\"weight\": 4727,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.baseType\",\
		\"weight\": 4728,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.baseDefinition\",\
		\"weight\": 4729,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.derivation\",\
		\"weight\": 4730,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot\",\
		\"weight\": 4731,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.id\",\
		\"weight\": 4732,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.extension\",\
		\"weight\": 4733,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.modifierExtension\",\
		\"weight\": 4734,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.element\",\
		\"weight\": 4735,\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential\",\
		\"weight\": 4736,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.id\",\
		\"weight\": 4737,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.extension\",\
		\"weight\": 4738,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.modifierExtension\",\
		\"weight\": 4739,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.element\",\
		\"weight\": 4740,\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap\",\
		\"weight\": 4741,\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.id\",\
		\"weight\": 4742,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.meta\",\
		\"weight\": 4743,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.implicitRules\",\
		\"weight\": 4744,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.language\",\
		\"weight\": 4745,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.text\",\
		\"weight\": 4746,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contained\",\
		\"weight\": 4747,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.extension\",\
		\"weight\": 4748,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.modifierExtension\",\
		\"weight\": 4749,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.url\",\
		\"weight\": 4750,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.identifier\",\
		\"weight\": 4751,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.version\",\
		\"weight\": 4752,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.name\",\
		\"weight\": 4753,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.status\",\
		\"weight\": 4754,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.experimental\",\
		\"weight\": 4755,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.publisher\",\
		\"weight\": 4756,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact\",\
		\"weight\": 4757,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.id\",\
		\"weight\": 4758,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact.extension\",\
		\"weight\": 4759,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.modifierExtension\",\
		\"weight\": 4760,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.name\",\
		\"weight\": 4761,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact.telecom\",\
		\"weight\": 4762,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.date\",\
		\"weight\": 4763,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.description\",\
		\"weight\": 4764,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.useContext\",\
		\"weight\": 4765,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.requirements\",\
		\"weight\": 4766,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.copyright\",\
		\"weight\": 4767,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure\",\
		\"weight\": 4768,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.id\",\
		\"weight\": 4769,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.extension\",\
		\"weight\": 4770,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.modifierExtension\",\
		\"weight\": 4771,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.url\",\
		\"weight\": 4772,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.mode\",\
		\"weight\": 4773,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.documentation\",\
		\"weight\": 4774,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.import\",\
		\"weight\": 4775,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group\",\
		\"weight\": 4776,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.id\",\
		\"weight\": 4777,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.extension\",\
		\"weight\": 4778,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.modifierExtension\",\
		\"weight\": 4779,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.name\",\
		\"weight\": 4780,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.extends\",\
		\"weight\": 4781,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.documentation\",\
		\"weight\": 4782,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input\",\
		\"weight\": 4783,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.id\",\
		\"weight\": 4784,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.extension\",\
		\"weight\": 4785,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.modifierExtension\",\
		\"weight\": 4786,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.name\",\
		\"weight\": 4787,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.type\",\
		\"weight\": 4788,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.mode\",\
		\"weight\": 4789,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.documentation\",\
		\"weight\": 4790,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule\",\
		\"weight\": 4791,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.id\",\
		\"weight\": 4792,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.extension\",\
		\"weight\": 4793,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.modifierExtension\",\
		\"weight\": 4794,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.name\",\
		\"weight\": 4795,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source\",\
		\"weight\": 4796,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.id\",\
		\"weight\": 4797,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.extension\",\
		\"weight\": 4798,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.modifierExtension\",\
		\"weight\": 4799,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.required\",\
		\"weight\": 4800,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.context\",\
		\"weight\": 4801,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.contextType\",\
		\"weight\": 4802,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.element\",\
		\"weight\": 4803,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.listMode\",\
		\"weight\": 4804,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.variable\",\
		\"weight\": 4805,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.condition\",\
		\"weight\": 4806,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.check\",\
		\"weight\": 4807,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target\",\
		\"weight\": 4808,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.id\",\
		\"weight\": 4809,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.extension\",\
		\"weight\": 4810,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.modifierExtension\",\
		\"weight\": 4811,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.context\",\
		\"weight\": 4812,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.contextType\",\
		\"weight\": 4813,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.element\",\
		\"weight\": 4814,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.variable\",\
		\"weight\": 4815,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.listMode\",\
		\"weight\": 4816,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.listRuleId\",\
		\"weight\": 4817,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.transform\",\
		\"weight\": 4818,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter\",\
		\"weight\": 4819,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.id\",\
		\"weight\": 4820,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.extension\",\
		\"weight\": 4821,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.modifierExtension\",\
		\"weight\": 4822,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueId\",\
		\"weight\": 4823,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueString\",\
		\"weight\": 4823,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueBoolean\",\
		\"weight\": 4823,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueInteger\",\
		\"weight\": 4823,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueDecimal\",\
		\"weight\": 4823,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.rule\",\
		\"weight\": 4824,\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent\",\
		\"weight\": 4825,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.id\",\
		\"weight\": 4826,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.extension\",\
		\"weight\": 4827,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.modifierExtension\",\
		\"weight\": 4828,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.name\",\
		\"weight\": 4829,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.variable\",\
		\"weight\": 4830,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.documentation\",\
		\"weight\": 4831,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription\",\
		\"weight\": 4832,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.id\",\
		\"weight\": 4833,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.meta\",\
		\"weight\": 4834,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.implicitRules\",\
		\"weight\": 4835,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.language\",\
		\"weight\": 4836,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.text\",\
		\"weight\": 4837,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.contained\",\
		\"weight\": 4838,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.extension\",\
		\"weight\": 4839,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.modifierExtension\",\
		\"weight\": 4840,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.criteria\",\
		\"weight\": 4841,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.contact\",\
		\"weight\": 4842,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.reason\",\
		\"weight\": 4843,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.status\",\
		\"weight\": 4844,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.error\",\
		\"weight\": 4845,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel\",\
		\"weight\": 4846,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.id\",\
		\"weight\": 4847,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.extension\",\
		\"weight\": 4848,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.channel.modifierExtension\",\
		\"weight\": 4849,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.channel.type\",\
		\"weight\": 4850,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.endpoint\",\
		\"weight\": 4851,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.payload\",\
		\"weight\": 4852,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.header\",\
		\"weight\": 4853,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.end\",\
		\"weight\": 4854,\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.tag\",\
		\"weight\": 4855,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance\",\
		\"weight\": 4856,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.id\",\
		\"weight\": 4857,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.meta\",\
		\"weight\": 4858,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.implicitRules\",\
		\"weight\": 4859,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.language\",\
		\"weight\": 4860,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.text\",\
		\"weight\": 4861,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.contained\",\
		\"weight\": 4862,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.extension\",\
		\"weight\": 4863,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.modifierExtension\",\
		\"weight\": 4864,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.identifier\",\
		\"weight\": 4865,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.category\",\
		\"weight\": 4866,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.code\",\
		\"weight\": 4867,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.description\",\
		\"weight\": 4868,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance\",\
		\"weight\": 4869,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.id\",\
		\"weight\": 4870,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.extension\",\
		\"weight\": 4871,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.modifierExtension\",\
		\"weight\": 4872,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.identifier\",\
		\"weight\": 4873,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.expiry\",\
		\"weight\": 4874,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.quantity\",\
		\"weight\": 4875,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient\",\
		\"weight\": 4876,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.id\",\
		\"weight\": 4877,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient.extension\",\
		\"weight\": 4878,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.modifierExtension\",\
		\"weight\": 4879,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.quantity\",\
		\"weight\": 4880,\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient.substance\",\
		\"weight\": 4881,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery\",\
		\"weight\": 4882,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.id\",\
		\"weight\": 4883,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.meta\",\
		\"weight\": 4884,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.implicitRules\",\
		\"weight\": 4885,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.language\",\
		\"weight\": 4886,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.text\",\
		\"weight\": 4887,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.contained\",\
		\"weight\": 4888,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.extension\",\
		\"weight\": 4889,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.modifierExtension\",\
		\"weight\": 4890,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.identifier\",\
		\"weight\": 4891,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.status\",\
		\"weight\": 4892,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.patient\",\
		\"weight\": 4893,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.type\",\
		\"weight\": 4894,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.quantity\",\
		\"weight\": 4895,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.suppliedItem\",\
		\"weight\": 4896,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.supplier\",\
		\"weight\": 4897,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.whenPrepared\",\
		\"weight\": 4898,\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.time\",\
		\"weight\": 4899,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.destination\",\
		\"weight\": 4900,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.receiver\",\
		\"weight\": 4901,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest\",\
		\"weight\": 4902,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.id\",\
		\"weight\": 4903,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.meta\",\
		\"weight\": 4904,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.implicitRules\",\
		\"weight\": 4905,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.language\",\
		\"weight\": 4906,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.text\",\
		\"weight\": 4907,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.contained\",\
		\"weight\": 4908,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.extension\",\
		\"weight\": 4909,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.modifierExtension\",\
		\"weight\": 4910,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.patient\",\
		\"weight\": 4911,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.source\",\
		\"weight\": 4912,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.date\",\
		\"weight\": 4913,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.identifier\",\
		\"weight\": 4914,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.status\",\
		\"weight\": 4915,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.kind\",\
		\"weight\": 4916,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.orderedItem\",\
		\"weight\": 4917,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.supplier\",\
		\"weight\": 4918,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.reasonCodeableConcept\",\
		\"weight\": 4919,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.reasonReference\",\
		\"weight\": 4919,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when\",\
		\"weight\": 4920,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.id\",\
		\"weight\": 4921,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.extension\",\
		\"weight\": 4922,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.modifierExtension\",\
		\"weight\": 4923,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.code\",\
		\"weight\": 4924,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.schedule\",\
		\"weight\": 4925,\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task\",\
		\"weight\": 4926,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.id\",\
		\"weight\": 4927,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.meta\",\
		\"weight\": 4928,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.implicitRules\",\
		\"weight\": 4929,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.language\",\
		\"weight\": 4930,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.text\",\
		\"weight\": 4931,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.contained\",\
		\"weight\": 4932,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.extension\",\
		\"weight\": 4933,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.modifierExtension\",\
		\"weight\": 4934,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.identifier\",\
		\"weight\": 4935,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.type\",\
		\"weight\": 4936,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.description\",\
		\"weight\": 4937,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.performerType\",\
		\"weight\": 4938,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.priority\",\
		\"weight\": 4939,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.status\",\
		\"weight\": 4940,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.failureReason\",\
		\"weight\": 4941,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.subject\",\
		\"weight\": 4942,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.for\",\
		\"weight\": 4943,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.definition\",\
		\"weight\": 4944,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.created\",\
		\"weight\": 4945,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.lastModified\",\
		\"weight\": 4946,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.creator\",\
		\"weight\": 4947,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.owner\",\
		\"weight\": 4948,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.parent\",\
		\"weight\": 4949,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input\",\
		\"weight\": 4950,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.id\",\
		\"weight\": 4951,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.extension\",\
		\"weight\": 4952,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.modifierExtension\",\
		\"weight\": 4953,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.name\",\
		\"weight\": 4954,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueBoolean\",\
		\"weight\": 4955,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueInteger\",\
		\"weight\": 4955,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueDecimal\",\
		\"weight\": 4955,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueBase64Binary\",\
		\"weight\": 4955,\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueInstant\",\
		\"weight\": 4955,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueString\",\
		\"weight\": 4955,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueUri\",\
		\"weight\": 4955,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueDate\",\
		\"weight\": 4955,\
		\"type\": \"date\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueDateTime\",\
		\"weight\": 4955,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueTime\",\
		\"weight\": 4955,\
		\"type\": \"time\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueCode\",\
		\"weight\": 4955,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueOid\",\
		\"weight\": 4955,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueId\",\
		\"weight\": 4955,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueUnsignedInt\",\
		\"weight\": 4955,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valuePositiveInt\",\
		\"weight\": 4955,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueMarkdown\",\
		\"weight\": 4955,\
		\"type\": \"markdown\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueAnnotation\",\
		\"weight\": 4955,\
		\"type\": \"Annotation\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueAttachment\",\
		\"weight\": 4955,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueIdentifier\",\
		\"weight\": 4955,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueCodeableConcept\",\
		\"weight\": 4955,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueCoding\",\
		\"weight\": 4955,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueQuantity\",\
		\"weight\": 4955,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueRange\",\
		\"weight\": 4955,\
		\"type\": \"Range\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valuePeriod\",\
		\"weight\": 4955,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueRatio\",\
		\"weight\": 4955,\
		\"type\": \"Ratio\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueSampledData\",\
		\"weight\": 4955,\
		\"type\": \"SampledData\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueSignature\",\
		\"weight\": 4955,\
		\"type\": \"Signature\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueHumanName\",\
		\"weight\": 4955,\
		\"type\": \"HumanName\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueAddress\",\
		\"weight\": 4955,\
		\"type\": \"Address\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueContactPoint\",\
		\"weight\": 4955,\
		\"type\": \"ContactPoint\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueTiming\",\
		\"weight\": 4955,\
		\"type\": \"Timing\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueReference\",\
		\"weight\": 4955,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueMeta\",\
		\"weight\": 4955,\
		\"type\": \"Meta\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output\",\
		\"weight\": 4956,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.id\",\
		\"weight\": 4957,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.extension\",\
		\"weight\": 4958,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.modifierExtension\",\
		\"weight\": 4959,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.name\",\
		\"weight\": 4960,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueBoolean\",\
		\"weight\": 4961,\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueInteger\",\
		\"weight\": 4961,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueDecimal\",\
		\"weight\": 4961,\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueBase64Binary\",\
		\"weight\": 4961,\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueInstant\",\
		\"weight\": 4961,\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueString\",\
		\"weight\": 4961,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueUri\",\
		\"weight\": 4961,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueDate\",\
		\"weight\": 4961,\
		\"type\": \"date\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueDateTime\",\
		\"weight\": 4961,\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueTime\",\
		\"weight\": 4961,\
		\"type\": \"time\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueCode\",\
		\"weight\": 4961,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueOid\",\
		\"weight\": 4961,\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueId\",\
		\"weight\": 4961,\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueUnsignedInt\",\
		\"weight\": 4961,\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valuePositiveInt\",\
		\"weight\": 4961,\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueMarkdown\",\
		\"weight\": 4961,\
		\"type\": \"markdown\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueAnnotation\",\
		\"weight\": 4961,\
		\"type\": \"Annotation\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueAttachment\",\
		\"weight\": 4961,\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueIdentifier\",\
		\"weight\": 4961,\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueCodeableConcept\",\
		\"weight\": 4961,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueCoding\",\
		\"weight\": 4961,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueQuantity\",\
		\"weight\": 4961,\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueRange\",\
		\"weight\": 4961,\
		\"type\": \"Range\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valuePeriod\",\
		\"weight\": 4961,\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueRatio\",\
		\"weight\": 4961,\
		\"type\": \"Ratio\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueSampledData\",\
		\"weight\": 4961,\
		\"type\": \"SampledData\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueSignature\",\
		\"weight\": 4961,\
		\"type\": \"Signature\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueHumanName\",\
		\"weight\": 4961,\
		\"type\": \"HumanName\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueAddress\",\
		\"weight\": 4961,\
		\"type\": \"Address\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueContactPoint\",\
		\"weight\": 4961,\
		\"type\": \"ContactPoint\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueTiming\",\
		\"weight\": 4961,\
		\"type\": \"Timing\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueReference\",\
		\"weight\": 4961,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueMeta\",\
		\"weight\": 4961,\
		\"type\": \"Meta\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript\",\
		\"weight\": 4962,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.id\",\
		\"weight\": 4963,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.meta\",\
		\"weight\": 4964,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.implicitRules\",\
		\"weight\": 4965,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.language\",\
		\"weight\": 4966,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.text\",\
		\"weight\": 4967,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contained\",\
		\"weight\": 4968,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.extension\",\
		\"weight\": 4969,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.modifierExtension\",\
		\"weight\": 4970,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.url\",\
		\"weight\": 4971,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.version\",\
		\"weight\": 4972,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.name\",\
		\"weight\": 4973,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.status\",\
		\"weight\": 4974,\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.identifier\",\
		\"weight\": 4975,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.experimental\",\
		\"weight\": 4976,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.publisher\",\
		\"weight\": 4977,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact\",\
		\"weight\": 4978,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.id\",\
		\"weight\": 4979,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact.extension\",\
		\"weight\": 4980,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.modifierExtension\",\
		\"weight\": 4981,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.name\",\
		\"weight\": 4982,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact.telecom\",\
		\"weight\": 4983,\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.date\",\
		\"weight\": 4984,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.description\",\
		\"weight\": 4985,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.useContext\",\
		\"weight\": 4986,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.requirements\",\
		\"weight\": 4987,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.copyright\",\
		\"weight\": 4988,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin\",\
		\"weight\": 4989,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.id\",\
		\"weight\": 4990,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin.extension\",\
		\"weight\": 4991,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.modifierExtension\",\
		\"weight\": 4992,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.index\",\
		\"weight\": 4993,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin.profile\",\
		\"weight\": 4994,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination\",\
		\"weight\": 4995,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.id\",\
		\"weight\": 4996,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination.extension\",\
		\"weight\": 4997,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.modifierExtension\",\
		\"weight\": 4998,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.index\",\
		\"weight\": 4999,\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination.profile\",\
		\"weight\": 5000,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata\",\
		\"weight\": 5001,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.id\",\
		\"weight\": 5002,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.extension\",\
		\"weight\": 5003,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.modifierExtension\",\
		\"weight\": 5004,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link\",\
		\"weight\": 5005,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.id\",\
		\"weight\": 5006,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.extension\",\
		\"weight\": 5007,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.modifierExtension\",\
		\"weight\": 5008,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.url\",\
		\"weight\": 5009,\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.description\",\
		\"weight\": 5010,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability\",\
		\"weight\": 5011,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.id\",\
		\"weight\": 5012,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.extension\",\
		\"weight\": 5013,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.modifierExtension\",\
		\"weight\": 5014,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.required\",\
		\"weight\": 5015,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.validated\",\
		\"weight\": 5016,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.description\",\
		\"weight\": 5017,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.origin\",\
		\"weight\": 5018,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.destination\",\
		\"weight\": 5019,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.link\",\
		\"weight\": 5020,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.conformance\",\
		\"weight\": 5021,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture\",\
		\"weight\": 5022,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.id\",\
		\"weight\": 5023,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.extension\",\
		\"weight\": 5024,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.modifierExtension\",\
		\"weight\": 5025,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.autocreate\",\
		\"weight\": 5026,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.autodelete\",\
		\"weight\": 5027,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.resource\",\
		\"weight\": 5028,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.profile\",\
		\"weight\": 5029,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable\",\
		\"weight\": 5030,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.id\",\
		\"weight\": 5031,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.extension\",\
		\"weight\": 5032,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.modifierExtension\",\
		\"weight\": 5033,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.name\",\
		\"weight\": 5034,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.defaultValue\",\
		\"weight\": 5035,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.headerField\",\
		\"weight\": 5036,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.path\",\
		\"weight\": 5037,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.sourceId\",\
		\"weight\": 5038,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule\",\
		\"weight\": 5039,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.id\",\
		\"weight\": 5040,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.extension\",\
		\"weight\": 5041,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.modifierExtension\",\
		\"weight\": 5042,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.resource\",\
		\"weight\": 5043,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param\",\
		\"weight\": 5044,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.id\",\
		\"weight\": 5045,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.extension\",\
		\"weight\": 5046,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.modifierExtension\",\
		\"weight\": 5047,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.name\",\
		\"weight\": 5048,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.value\",\
		\"weight\": 5049,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset\",\
		\"weight\": 5050,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.id\",\
		\"weight\": 5051,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.extension\",\
		\"weight\": 5052,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.modifierExtension\",\
		\"weight\": 5053,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.resource\",\
		\"weight\": 5054,\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule\",\
		\"weight\": 5055,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.id\",\
		\"weight\": 5056,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.extension\",\
		\"weight\": 5057,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.modifierExtension\",\
		\"weight\": 5058,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param\",\
		\"weight\": 5059,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.id\",\
		\"weight\": 5060,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.extension\",\
		\"weight\": 5061,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.modifierExtension\",\
		\"weight\": 5062,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.name\",\
		\"weight\": 5063,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.value\",\
		\"weight\": 5064,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup\",\
		\"weight\": 5065,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.id\",\
		\"weight\": 5066,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.extension\",\
		\"weight\": 5067,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.modifierExtension\",\
		\"weight\": 5068,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.metadata\",\
		\"weight\": 5069,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action\",\
		\"weight\": 5070,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.id\",\
		\"weight\": 5071,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.extension\",\
		\"weight\": 5072,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.modifierExtension\",\
		\"weight\": 5073,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation\",\
		\"weight\": 5074,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.id\",\
		\"weight\": 5075,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.extension\",\
		\"weight\": 5076,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.modifierExtension\",\
		\"weight\": 5077,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.type\",\
		\"weight\": 5078,\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.resource\",\
		\"weight\": 5079,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.label\",\
		\"weight\": 5080,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.description\",\
		\"weight\": 5081,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.accept\",\
		\"weight\": 5082,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.contentType\",\
		\"weight\": 5083,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.destination\",\
		\"weight\": 5084,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.encodeRequestUrl\",\
		\"weight\": 5085,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.origin\",\
		\"weight\": 5086,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.params\",\
		\"weight\": 5087,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader\",\
		\"weight\": 5088,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.id\",\
		\"weight\": 5089,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.extension\",\
		\"weight\": 5090,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.modifierExtension\",\
		\"weight\": 5091,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.field\",\
		\"weight\": 5092,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.value\",\
		\"weight\": 5093,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.responseId\",\
		\"weight\": 5094,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.sourceId\",\
		\"weight\": 5095,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.targetId\",\
		\"weight\": 5096,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.url\",\
		\"weight\": 5097,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert\",\
		\"weight\": 5098,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.id\",\
		\"weight\": 5099,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.extension\",\
		\"weight\": 5100,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.modifierExtension\",\
		\"weight\": 5101,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.label\",\
		\"weight\": 5102,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.description\",\
		\"weight\": 5103,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.direction\",\
		\"weight\": 5104,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.compareToSourceId\",\
		\"weight\": 5105,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.compareToSourcePath\",\
		\"weight\": 5106,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.contentType\",\
		\"weight\": 5107,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.headerField\",\
		\"weight\": 5108,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.minimumId\",\
		\"weight\": 5109,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.navigationLinks\",\
		\"weight\": 5110,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.operator\",\
		\"weight\": 5111,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.path\",\
		\"weight\": 5112,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.resource\",\
		\"weight\": 5113,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.response\",\
		\"weight\": 5114,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.responseCode\",\
		\"weight\": 5115,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule\",\
		\"weight\": 5116,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.id\",\
		\"weight\": 5117,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.extension\",\
		\"weight\": 5118,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.modifierExtension\",\
		\"weight\": 5119,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param\",\
		\"weight\": 5120,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.id\",\
		\"weight\": 5121,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.extension\",\
		\"weight\": 5122,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.modifierExtension\",\
		\"weight\": 5123,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.name\",\
		\"weight\": 5124,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.value\",\
		\"weight\": 5125,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset\",\
		\"weight\": 5126,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.id\",\
		\"weight\": 5127,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.extension\",\
		\"weight\": 5128,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.modifierExtension\",\
		\"weight\": 5129,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule\",\
		\"weight\": 5130,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.id\",\
		\"weight\": 5131,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.extension\",\
		\"weight\": 5132,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.modifierExtension\",\
		\"weight\": 5133,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param\",\
		\"weight\": 5134,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.id\",\
		\"weight\": 5135,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.extension\",\
		\"weight\": 5136,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.modifierExtension\",\
		\"weight\": 5137,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.name\",\
		\"weight\": 5138,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.value\",\
		\"weight\": 5139,\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.sourceId\",\
		\"weight\": 5140,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.validateProfileId\",\
		\"weight\": 5141,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.value\",\
		\"weight\": 5142,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.warningOnly\",\
		\"weight\": 5143,\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test\",\
		\"weight\": 5144,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.id\",\
		\"weight\": 5145,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.extension\",\
		\"weight\": 5146,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.modifierExtension\",\
		\"weight\": 5147,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.name\",\
		\"weight\": 5148,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.description\",\
		\"weight\": 5149,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.metadata\",\
		\"weight\": 5150,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action\",\
		\"weight\": 5151,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.id\",\
		\"weight\": 5152,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action.extension\",\
		\"weight\": 5153,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.modifierExtension\",\
		\"weight\": 5154,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.operation\",\
		\"weight\": 5155,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action.assert\",\
		\"weight\": 5156,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown\",\
		\"weight\": 5157,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.id\",\
		\"weight\": 5158,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.extension\",\
		\"weight\": 5159,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.modifierExtension\",\
		\"weight\": 5160,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action\",\
		\"weight\": 5161,\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.id\",\
		\"weight\": 5162,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.extension\",\
		\"weight\": 5163,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.modifierExtension\",\
		\"weight\": 5164,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.operation\",\
		\"weight\": 5165,\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription\",\
		\"weight\": 5166,\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.id\",\
		\"weight\": 5167,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.meta\",\
		\"weight\": 5168,\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.implicitRules\",\
		\"weight\": 5169,\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.language\",\
		\"weight\": 5170,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.text\",\
		\"weight\": 5171,\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.contained\",\
		\"weight\": 5172,\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.extension\",\
		\"weight\": 5173,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.modifierExtension\",\
		\"weight\": 5174,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.identifier\",\
		\"weight\": 5175,\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dateWritten\",\
		\"weight\": 5176,\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.patient\",\
		\"weight\": 5177,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.prescriber\",\
		\"weight\": 5178,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.encounter\",\
		\"weight\": 5179,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.reasonCodeableConcept\",\
		\"weight\": 5180,\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.reasonReference\",\
		\"weight\": 5180,\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense\",\
		\"weight\": 5181,\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.id\",\
		\"weight\": 5182,\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.extension\",\
		\"weight\": 5183,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.modifierExtension\",\
		\"weight\": 5184,\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.product\",\
		\"weight\": 5185,\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.eye\",\
		\"weight\": 5186,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.sphere\",\
		\"weight\": 5187,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.cylinder\",\
		\"weight\": 5188,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.axis\",\
		\"weight\": 5189,\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.prism\",\
		\"weight\": 5190,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.base\",\
		\"weight\": 5191,\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.add\",\
		\"weight\": 5192,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.power\",\
		\"weight\": 5193,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.backCurve\",\
		\"weight\": 5194,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.diameter\",\
		\"weight\": 5195,\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.duration\",\
		\"weight\": 5196,\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.color\",\
		\"weight\": 5197,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.brand\",\
		\"weight\": 5198,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.notes\",\
		\"weight\": 5199,\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	}\
]"function require_resource(e)return t[e]or error("resource '"..tostring(e).."' not found");end end
local e,t,n,s
if js and js.global then
s={}
s.dump=require("pure-xml-dump")
s.load=require("pure-xml-load")
n=require("lunajson")
else
s=require("xml")
e=require("cjson")
t=require("datafile")
end
package.preload["cjson.safe"]={encode=function()end}
local L=require("resty.prettycjson")
local w,q,o,a,D,R,r,x,H
=ipairs,pairs,type,print,tonumber,string.gmatch,table.remove,string.format,table.sort
local l,p,I,v,u
local S,N,y,T
local E,_,j,g,b
local m,k,A
local O,c,z
local i
local d
local h,f
if e then
d=e.null
h,f=e.decode,e.encode
elseif n then
d={}
h=function(e)
return n.decode(e,nil,d)
end
f=function(e)
return n.encode(e,d)
end
else
error("neither cjson nor luajson libraries found for JSON parsing")
end
_=function(e)
local e=io.open(e,"r")
if e~=nil then io.close(e)return true else return false end
end
p=function(e)
local a={(e or""),"fhir-data/fhir-elements.json","src/fhir-data/fhir-elements.json","../src/fhir-data/fhir-elements.json","fhir-data/fhir-elements.json"}
local e
for a,t in w(a)do
if _(t)then
io.input(t)
e=h(io.read("*a"))
break
end
end
if not e and t then
local t,a=t.open("src/fhir-data/fhir-elements.json","r")
e=h(t:read("*a"))
end
if not e and require_resource then
e=h(require_resource("fhir-data/fhir-elements.json"))
end
assert(e,string.format("read_fhir_data: FHIR Schema could not be found in these locations:\n  %s.\n%s%s",table.concat(a," "),t and"Datafile could not find LuaRocks installation as well."or'',require_resource and"Embedded JSON data could not be found as well."or''))
return e
end
I=function(e,a)
if not e then return nil end
for t=1,#e do
if e[t]==a then return t end
end
end
z=function(e,a)
if not e then return nil end
local t={}
if o(a)=="function"then
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
v=function(a)
i={}
local s,n
n=function(t)
local e=i
for t in R(t.path,"([^%.]+)")do
e[t]=e[t]or{}
e=e[t]
end
e._max=t.max
e._type=t.type
e._type_json=t.type_json
e._weight=t.weight
e._derivations=z(t.derivations,function(e)return i[e]end)
s(e)
if o(i[t.type])=="table"then
e[1]=i[t.type]
end
end
s=function(e,t)
if not(e and e._derivations)then return end
local t=t and t._derivations or e._derivations
for a,t in q(t)do
if t._derivations then
for a,t in q(t._derivations)do
if e~=t then
e._derivations[a]=t
end
end
end
end
end
for e=1,#a do
local e=a[e]
n(e)
end
for e=1,#a do
local e=a[e]
n(e)
end
return i
end
j=function(t,e)
return e(t)
end
g=function(e,t)
io.input(e)
local e=io.read("*a")
io.input():close()
return t(e)
end
u=function(t,e)
local i=e.value
local o=l(t,e.xml)
if not o then
a(string.format("Warning: %s is not a known FHIR element; couldn't check its FHIR type to decide the JSON type.",table.concat(t,".")))
return i
end
local o=o._type or o._type_json
if o=="boolean"then
if e.value=="true"then return true
elseif e.value=="false"then return false
else
a(string.format("Warning: %s.%s is of type %s in FHIR JSON - its XML value of %s is invalid.",table.concat(t),e.xml,o,e.value))
end
elseif o=="number"then return D(e.value)
else return i
end
end
l=function(t,o)
local e
if o=="id"and t[#t]=="Organization"then
a()
end
for a=1,#t+1 do
local t=(t[a]or o)
if not e then
e=i[t]
elseif e[t]then
e=e[t]
elseif e[1]then
e=e[1][t]or e[1]._derivations[t]
else
e=nil
break
end
end
return e
end
b=function(n,i)
local e,o
local t=l(n,i)
if not t then
a(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.",table.concat(n,"."),i))
end
if t and t._max=="*"then
e={{}}
o=e[1]
else
e={}
o=e
end
return e,o
end
S=function(o,t)
local e=l(o,t)
if e==nil then
a(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.",table.concat(o,"."),t))
end
if e and e._max=="*"then
return"array"
end
return"object"
end
N=function(e,n,r,t,s)
assert(e.xml,"error from parsed xml: node.xml is missing")
local a=n-1
if n==1 then
r.resourceType=e.xml
elseif e.value then
if not t[a][#t[a]][e.xml]then
t[a][#t[a]][e.xml]=(S(s,e.xml)=="array"and{u(s,e)}or u(s,e))
else
local o=t[a][#t[a]][e.xml]
o[#o+1]=u(s,e)
local e=t[a][#t[a]]["_"..e.xml]
if e then
e[#e+1]=d
end
end
end
if o(e[1])=="table"
and n~=1 then
local i,h
if o(t[a][#t[a]][e.xml])=="table"
and not(n~=1 and e[1]and(e[1].xml=="id"or e[1].xml=="extension"))then
local e=t[a][#t[a]][e.xml]
e[#e+1]={}
h=e[#e]
elseif not t[a][#t[a]][e.xml]then
i,h=b(s,e.xml)
t[a][#t[a]][e.xml]=i
end
if n~=1 and e[1]and(e.id or e[1].xml=="extension")then
i,h=b(s,e.xml)
t[a][#t[a]]['_'..e.xml]=i
local e=I(t[a][#t[a]][e.xml],e.value)
if e and e>1 then
i[1]=nil
for e=1,e-1 do
i[#i+1]=d
end
i[#i+1]={}
h=i[#i]
end
end
t[n]=t[n]or{}
t[n][#t[n]+1]=h
end
if e.url then
t[n][#t[n]].url=e.url
end
return r
end
T=function(a,e,t)
a[t][#a[t]][e.xml]=s.dump(e)
end
y=function(e,t,i,n,a)
t=(t and(t+1)or 1)
i=N(e,t,i,n,a)
a[#a+1]=e.xml
for s,e in w(e)do
if e.xml=="div"and e.xmlns=="http://www.w3.org/1999/xhtml"then
T(n,e,t)
else
assert(o(e)=="table",string.format("unexpected type value encountered: %s (%s), expecting table",tostring(e),o(e)))
y(e,t,i,n,a)
end
end
r(a)
return i
end
E=function(a,e)
i=i or v(p())
assert(next(i),"convert_to_json: FHIR Schema could not be parsed in.")
local t
if e and e.file then
t=g(a,s.load)
else
t=j(a,s.load)
end
local a={}
local i={[1]={a}}
local o={}
local t=y(t,nil,a,i,o)
return(e and e.pretty)and L(t,nil,'  ',nil,f)
or f(t)
end
k=function(a,n,t,i,h)
if a:find("_",1,true)then return end
local e=t[#t]
if a=="div"then
e[#e+1]=s.load(n)
elseif a=="url"then
e.url=n
elseif o(n)=="userdata"then
e[#e+1]={xml=a}
else
e[#e+1]={xml=a,value=tostring(n)}
end
local o=e[#e]
if o then
o._weight=l(i,a)._weight
o._count=#e
end
if h then
t[#t+1]=e[#e]
i[#i+1]=e[#e].xml
m(h,t,i)
r(t)
r(i)
end
end
c=function(i,n,e,a)
if i:find("_",1,true)then return end
local t=e[#e]
t[#t+1]={xml=i}
local o=t[#t]
o._weight=l(a,i)._weight
o._count=#t
e[#e+1]=o
a[#a+1]=o.xml
m(n,e,a)
r(e)
r(a)
end
print_contained_resource=function(o,t,a)
local e=t[#t]
e[#e+1]={xml=o.resourceType,xmlns="http://hl7.org/fhir"}
t[#t+1]=e[#e]
a[#a+1]=e[#e].xml
o.resourceType=nil
end
m=function(n,t,i)
local s
if n.resourceType then
print_contained_resource(n,t,i)
s=true
end
for a,e in q(n)do
if o(e)=="table"then
if o(e[1])=="table"then
for n,e in w(e)do
if o(e)~="userdata"then
c(a,e,t,i)
end
end
elseif e[1]and o(e[1])~="table"then
for h,s in w(e)do
local o,e=n[x("_%s",a)]
if o then
e=o[h]
if e==d then e=nil end
end
k(a,s,t,i,e)
end
elseif o(e)~="userdata"then
c(a,e,t,i)
end
elseif o(e)~="userdata"then
k(a,e,t,i,n[x("_%s",a)])
end
if a:sub(1,1)=='_'and not n[a:sub(2)]then
c(a:sub(2),e,t,i)
end
end
local a=t[#t]
H(a,function(t,e)
return(t.xml==e.xml)and(t._count<e._count)or(t._weight<e._weight)
end)
for e=1,#a do
local e=a[e]
e._weight=nil
e._count=nil
end
if s then
r(t)
r(i)
end
end
A=function(e,a,o,t)
if e.resourceType then
a.xmlns="http://hl7.org/fhir"
a.xml=e.resourceType
e.resourceType=nil
t[#t+1]=a.xml
end
return m(e,o,t)
end
O=function(t,a)
i=i or v(p())
assert(next(i),"convert_to_xml: FHIR Schema could not be parsed in.")
local e
if a and a.file then
e=g(t,h)
else
e=j(t,h)
end
local t,o={},{}
local a={t}
A(e,t,a,o)
return s.dump(t)
end
return{
to_json=E,
to_xml=O
}
