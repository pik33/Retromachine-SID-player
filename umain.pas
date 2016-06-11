unit umain;

{$mode objfpc}{$H+}

interface

uses sdl,sysutils,classes,retromalina;

var test:integer ;
    event:tsdl_event;
    licznik:integer=0;
    songname:string;
    q1,q2,q3:extended;
    thread:TRetro;
    sprx,sprxd,spryd,spry:integer;
    spr2x,spr2xd,spr2yd,spr2y:integer;
    spr3x,spr3xd,spr3yd,spr3y:integer;
    c:int64=0;
    c6:int64=1;
    avsct:int64=0;
    avspt:int64=0;
    avall:int64=0;
    avsid:int64=0;
    av6502:int64=0;
    qq:integer;
 //   pause:boolean=false;

procedure main1;
procedure main2;

implementation

procedure main1 ;
var  t:int64;
     i:integer;

begin

// hide all sprites

raml^[$18010]:=$01001100;    raml^[$18011]:=$00040004;
raml^[$18012]:=$01001100;    raml^[$18013]:=$00040004;
raml^[$18014]:=$01001100;    raml^[$18015]:=$00040004;
raml^[$18016]:=$01001100;    raml^[$18017]:=$00040004;
raml^[$18018]:=$01001100;    raml^[$18019]:=$00040004;
raml^[$1801a]:=$01001100;    raml^[$1801b]:=$00040004;
raml^[$1801c]:=$01001100;    raml^[$1801d]:=$00040004;
raml^[$1801e]:=$01001100;    raml^[$1801f]:=$00020002;

// set sprite shapes

for i:=0 to 31 do
  for j:=0 to 31 do  begin
    if j<16 then k:=j*16 else k:=(31-j)*16 ;
    if (i<11) or (i>21) or (j<11) or (j>21) then raml^[$14800+i+32*j]:=k else  raml^[$14800+i+32*j]:=$0;
    end;

for i:=0 to 31 do
  for j:=0 to 31 do  begin
    if j<16 then k:=j*16 else k:=(31-j)*16 ;
    k:=k shl 8;
    if (i<11) or (i>21) or (j<11) or (j>21) then raml^[$14C00+i+32*j]:=k else  raml^[$14C00+i+32*j]:=$0;
    end;

for i:=0 to 31 do
  for j:=0 to 31 do  begin
    if j<16 then k:=j*16 else k:=(31-j)*16 ;
    k:=k shl 16;
    if (i<11) or (i>21) or (j<11) or (j>21) then raml^[$15000+i+32*j]:=k else  raml^[$15000+i+32*j]:=$0;
    end;

// --------- main program start

raml^[$18002]:=0;
raml^[$18008]:=1792;
raml^[$18009]:=1120;
setataripallette(0);
setataripallette(1);
setataripallette(2);
setataripallette(3);
cls(146);
outtextxyz(128,16,'The retromachine player v. 0.07 --- 2016.06.06',154,4,2);
box2(8,64,1784,1112,0);
box2(10,1062,1782,1110,120);
outtextxyz(32,1070,'Screen time:',124,2,2);
k:=raml^[$18000];
raml^[$18003]:=$002040;
sethidecolor(250,0,$FF);
sethidecolor(44,0,$FF);
sethidecolor(190,0,$FF);
sethidecolor(188,0,$FF);
c:=0;
avsct:=0;
avspt:=0;
avall:=0;
avsid:=0;
box2(10,1011,1782,1012,48+16);
box2(10,1013,1782,1014,48+17);
box2(10,1015,1782,1016,48+18);
box2(10,1017,1782,1018,48+19);
box2(10,1019,1782,1020,48+20);
box2(10,1021,1782,1022,48+21);
box2(10,1023,1782,1024,48+22);
box2(10,1025,1782,1026,48+23);
box2(10,1027,1782,1028,48+24);
box2(10,1029,1782,1030,48+25);
box2(10,1031,1782,1032,48+26);
box2(10,1033,1782,1034,48+27);
box2(10,1035,1782,1036,48+28);
box2(10,1037,1782,1038,48+29);
box2(10,1039,1782,1040,48+30);
box2(10,1041,1782,1042,48+31);
box2(10,1043,1782,1044,48+32);
box2(10,1045,1782,1046,48+33);
box2(10,1047,1782,1048,48+34);
box2(10,1049,1782,1050,48+35);
box2(10,1051,1782,1052,48+36);
box2(10,1053,1782,1054,48+37);
box2(10,1055,1782,1056,48+38);
box2(10,1057,1782,1058,48+39);
outtextxyz(24,1019,'A retromachine SID player by pik33 --- inspired by Johannes Ahlebrand''s Parallax Propeller SIDCog',89,2,2);
blit($1000000,10,1011,$1800000,10,1011,1771,48,1792,1792);
box2(10,800,894,848,246);
box2(10,851,894,1008,244);
outtextxyz(320,808,'Now playing',250,2,2);
box2(10,118,894,797,178);
box2(10,67,894,115,180);
outtextxyz(320,75,'File info',188,2,2);
box2(897,118,1782,1008,34);
box2(897,67,1782,115,36);
outtextxyz(1296,75,'Files',44,2,2);
end;


procedure main2;

var ii,iii,il,i:integer;
    buf:array[0..24] of byte;
    qqq,mm,hh,ss:int64;
    mms,hhs,sss,kwas:string;
    rect:tsdl_rect;

begin


k:=raml^[$18000];
if peek($70006)=0 then repeat until raml^[$18000]>k;
qqq:=gettime;
if (fullscreen=0) and (peek($70006)=0) then sdl_flip(scr);
qqq:=gettime-qqq;
if peek($70006)=0 then sdlevents;// get events from SDL and update system variables
c:=c+1;
if time6502>0 then c6+=1;
ss:=(songtime div 1000000) mod 60;
mm:=(songtime div 60000000) mod 60;
hh:=(songtime div 3600000000);
sss:=inttostr(ss); if ss<10 then sss:='0'+sss;
mms:=inttostr(mm); if mm<10 then mms:='0'+mms;
hhs:=inttostr(hh); if hh<10 then hhs:='0'+hhs;
songfreq:=1000000 div siddelay;
box(18,864,640,32,244);
box(18,960,640,32,244);
outtextxyz(18,864,songname,250,2,2);
outtextxyz(18,960,hhs+':'+mms+':'+sss,190,4,2);
avsct:=avsct+tim;
avspt:=avspt+ts;
avall:=avall+t3;
av6502:=av6502+time6502;
box2(10,1062,1782,1110,118);
outtextxyz(32,1070,'Avg screen time: '+inttostr(round(avsct/c))+' us',44,2,2);
outtextxyz(438,1070,'Avg sprite time: '+inttostr(round(avspt/c))+' us',186,2,2);
if sidcount<>0 then outtextxyz(828,1070,'Avg SID time: '+inttostr(round(sidtime/sidcount))+' us',233,2,2);
outtextxyz(1190,1070,'6502 time: '+floattostrf((time6502/16),fffixed,4,1)+' us',124,2,2);
if peek($70003)=1 then outtextxyz(1540,1070,inttostr(peek($d404)shr 4),108,2,2);
if peek($70004)=1 then outtextxyz(1580,1070,inttostr(peek($d40b)shr 4),200,2,2);
if peek($70005)=1 then outtextxyz(1620,1070,inttostr(peek($d412)shr 4),40,2,2);
outtextxyz(1680,1070,inttostr(dpeek($60028)),44,2,2);
 for i:=64 to 88 do lpoke($10000+4*i,lpeek($10000+2048+4*((c div 2) mod 256)+4*i));
if (c mod 32)=0 then lpoke($10000+4*89,lpeek($10000+2048+(4*(c div 32) mod 256)))   ;
blit($1800000,10+(2*c mod 1772),1011,$1000000,12,1011,1771-(2*c mod 1772),48,1792,1792);
blit($1800000,10,1011,$1000000,11+1771-(2*c mod 1772),1011,(2*c mod 1772),48,1792,1792);
box2(10,610,894,797,178);
box2(10,700,894,701,140);
box2(10,636,894,637,140);
box2(10,764,894,765,140);
for j:=20 to 840 do if abs(scope[j])<46000 then box(20+j,700-scope[j] div 512,2,2,190);
sprx:=round(dpeek($d400)/40+74);
spry:=920-3*(peek($d406) and $F0);
raml^[$18010]:=(spry shl 16)+sprx+2048*(1-peek($70003));
spr2x:=round(dpeek($d407)/40+74);
spr2y:=920-3*(peek($d40d) and $F0);
raml^[$18012]:=(spr2y shl 16)+spr2x+2048*(1-peek($70004));
spr3x:=round(dpeek($d40e)/40+74);
spr3y:=920-3*(peek($d414) and $F0);
raml^[$18014]:=(spr3y shl 16)+spr3x+2048*(1-peek($70005));
raml^[$1801e]:=raml^[$1800B] shl 1;
end;


end.

