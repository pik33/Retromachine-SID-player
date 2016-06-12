program project1;
// added a line to test githu push

{$mode objfpc}{$H+}

uses
  cthreads,
   Classes, SysUtils,FileUtil,
   umain,retromalina,sdl,unit6502,baseunix;

var s,currentdir,currentdir2:string;
    sr:tsearchrec;
    filenames:array[0..1000,0..1] of string;
    l,i,j,ilf,ild:integer;
    sel:integer=0;
    selstart:integer=0;
    buf:array[0..25] of  byte;
    fn:string;
    fs:integer;
    cia:integer;
    song:word=0;
    songs:word=0;
    init:word;
    atitle,author,copyright:string[32];
    workdir:string;
    pause:boolean=true;

// ---- procedures

procedure sidopen (var fh:integer);

var i:integer;
    speed:cardinal;
    version,offset,load,startsong,flags:word;
    dump:word;
    il,b:byte;

begin
reset6502;
atitle:='                                ';
author:='                                ';
copyright:='                                ';
fileread(fh,version,2); version:=(version shl 8) or (version shr 8);
fileread(fh,offset,2); offset:=(offset shl 8) or (offset shr 8);
fileread(fh,load,2); load:=(load shl 8) or (load shr 8);
fileread(fh,init,2); init:=(init shl 8) or (init shr 8);
fileread(fh,play,2);  play:=(play shl 8) or (play shr 8);
fileread(fh,songs,2); songs:=(songs shl 8) or (songs shr 8);
fileread(fh,startsong,2); startsong:=(startsong shl 8) or (startsong shr 8);
fileread(fh,speed,4);
speed:=speed shr 24+((speed shr 8) and $0000FF00) + ((speed shl 8) and $00FF0000) + (speed shl 24);
fileread(fh,atitle[1],32);
fileread(fh,author[1],32);
fileread(fh,copyright[1],32);
if version>1 then begin
  fileread(fh,flags,2); flags:=(flags shl 8) or (flags shr 8);
  fileread(fh,dump,2);
  fileread(fh,dump,2);
  b:=0; if load=0 then begin b:=1; fileread(fh,load,2); end;
  end;
for i:=1 to 32 do if byte(atitle[i])=$F1 then atitle[i]:=char(26);
for i:=1 to 32 do if byte(author[i])=$F1 then author[i]:=char(26);
box(18,132,800,600,178);
outtextxyz(18,132,'type: PSID',188,2,2);
outtextxyz(18,164,'version: '+inttostr(version),188,2,2);
outtextxyz(18,196,'offset: ' +inttohex(offset,4),188,2,2);
outtextxyz(18,228,'load: '+inttohex(load,4),188-144*b,2,2);
outtextxyz(18,260,'init: '+inttohex(init,4),188,2,2);
outtextxyz(18,292,'play: '+inttohex(play,4),188,2,2);
outtextxyz(18,324,'songs: '+inttostr(songs),188,2,2);
outtextxyz(18,356,'startsong: '+inttostr(startsong),188,2,2);
outtextxyz(18,388,'speed: '+inttohex(speed,8),188,2,2);
outtextxyz(18,420,'title: '+atitle,188,2,2);
outtextxyz(18,452,'author: '+author,188,2,2);
outtextxyz(18,484,'copyright: '+copyright,188,2,2);
outtextxyz(18,516,'flags: '+inttohex(flags,4),188,2,2);
song:=startsong-1;

reset6502;
for i:=0 to 65535 do write6502(i,0);
repeat
  il:=fileread(fh,b,1);
  write6502(load,b);
  load+=1;
until il<>1;
fileseek(fh,0,fsfrombeginning);
jsr6502(song,init);
cia:=read6502($dc04)+256*read6502($dc05);
outtextxyz(18,578,'cia: '+inttohex(read6502($dc04)+256*read6502($dc05),4),188,2,2);
end;


procedure sort;

// A simple bubble sort for filenames

var i,j:integer;
    s,s2:string;

begin
repeat
  j:=0;
  for i:=0 to ilf-2 do
    begin
    if lowercase(filenames[i,0])>lowercase(filenames[i+1,0]) then
      begin
      s:=filenames[i,0]; s2:=filenames[i,1];
      filenames[i,0]:=filenames[i+1,0];
      filenames[i,1]:=filenames[i+1,1];
      filenames[i+1,0]:=s; filenames[i+1,1]:=s2;
      j:=1;
      end;
    end;
until j=0;
end;


procedure dirlist(dir:string);

begin
currentdir2:=dir;
setcurrentdir(currentdir2);
currentdir2:=getcurrentdir+'/';
box2(897,67,1782,115,36);
box2(897,118,1782,1008,34);
s:=currentdir2;
if length(s)>55 then s:=copy(s,1,55);
l:=length(s);
outtextxyz(1344-8*l,75,s,44,2,2);
ilf:=0;
currentdir:=currentdir2+'*';
if findfirst(currentdir,fadirectory,sr)=0 then
  repeat
  if (sr.attr and faDirectory) = faDirectory then
    begin
    filenames[ilf,0]:=sr.name;
    filenames[ilf,1]:='[DIR]';
    ilf+=1;
    end;
  until (findnext(sr)<>0) or (ilf=1000);
sysutils.findclose(sr);

currentdir:=currentdir2+'*.sid';
if findfirst(currentdir,faAnyFile,sr)=0 then
  repeat
  filenames[ilf,0]:=sr.name;
  filenames[ilf,1]:='';
  ilf+=1;
  until (findnext(sr)<>0) or (ilf=1000);
sysutils.findclose(sr);

currentdir:=currentdir2+'*.dmp';
if findfirst(currentdir,faAnyFile,sr)=0 then
  repeat
  filenames[ilf,0]:=sr.name;
  filenames[ilf,1]:='';
  ilf+=1;
  until (findnext(sr)<>0) or (ilf=1000);
sysutils.findclose(sr);
sort;

box(920,132,840,32,36);
if ilf<26 then ild:=ilf-1 else ild:=26;
for i:=0 to ild do
  begin
  if filenames[i,1]='' then l:=length(filenames[i,0])-4 else  l:=length(filenames[i,0]);
  if filenames[i,1]='' then  s:=copy(filenames[i,0],1,length(filenames[i,0])-4) else s:=filenames[i,0];
  if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
  for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
  if filenames[i,1]='' then outtextxyz(1344-8*l,132+32*i,s,44,2,2);
  if filenames[i,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*i,s,44,2,2);  outtextxyz(1672,132+32*i,'[DIR]',44,2,2);   end;
  end;
sel:=0; selstart:=0;
box2(897,67,1782,115,36);
s:=currentdir2;
if length(s)>55 then s:=copy(s,1,55);
l:=length(s);
outtextxyz(1344-8*l,75,s,44,2,2);

end;



//------------------- The main loop

begin

if paramstr(1)='-f' then fs:=1 else fs:=0;

songtime:=0;
pause:=true;
siddelay:=20000;
setcurrentdir(workdir);
initmachine(fs);
poke($70002,0);
poke($70006,0);
poke($70007,0);
poke($70008,1);
lpoke($6000c,$002040);
main1;
dirlist('/home/pi/');
      {
currentdir2:='/home/pi/';
setcurrentdir(currentdir2);
box2(897,67,1782,115,36);
s:=currentdir2;
if length(s)>55 then s:=copy(s,1,55);
l:=length(s);
outtextxyz(1344-8*l,75,s,44,2,2);
ilf:=0;
currentdir:=currentdir2+'*';
if findfirst(currentdir,fadirectory,sr)=0 then
  repeat
  if (sr.attr and faDirectory) = faDirectory then
    begin
    filenames[ilf,0]:=sr.name;
    filenames[ilf,1]:='[DIR]';
    ilf+=1;
    end;
  until (findnext(sr)<>0) or (ilf=1000);
sysutils.findclose(sr);

currentdir:=currentdir2+'*.sid';
if findfirst(currentdir,faAnyFile,sr)=0 then
  repeat
  filenames[ilf,0]:=sr.name;
  filenames[ilf,1]:='';
  ilf+=1;
  until (findnext(sr)<>0) or (ilf=1000);
sysutils.findclose(sr);

currentdir:=currentdir2+'*.dmp';
if findfirst(currentdir,faAnyFile,sr)=0 then
  repeat
  filenames[ilf,0]:=sr.name;
  filenames[ilf,1]:='';
  ilf+=1;
  until (findnext(sr)<>0) or (ilf=1000);
sysutils.findclose(sr);

sort;

box(920,132,840,32,36);
if ilf<26 then ild:=ilf-1 else ild:=26;
for i:=0 to ild do
  begin
  if filenames[i,1]='' then l:=length(filenames[i,0])-4 else  l:=length(filenames[i,0]);
  if filenames[i,1]='' then  s:=copy(filenames[i,0],1,length(filenames[i,0])-4) else s:=filenames[i,0];
  if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
  for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
  if filenames[i,1]='' then outtextxyz(1344-8*l,132+32*i,s,44,2,2);
  if filenames[i,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*i,s,44,2,2);  outtextxyz(1672,132+32*i,'[DIR]',44,2,2);   end;
  end;
 }
poke($70003,1);
poke($70004,1);
poke($70005,1);

repeat
  main2;
  if pause then begin for i:=$d400 to $d400+25 do poke(i,0); end;

  if dpeek($60028)=ord('5') then begin dpoke ($60028,0); siddelay:=20000; songfreq:=50; skip:=0; end;
  if dpeek($60028)=ord('1') then begin dpoke ($60028,0); siddelay:=10000; songfreq:=100; skip:=0; end;
  if dpeek($60028)=ord('2') then begin dpoke ($60028,0); siddelay:=5000; songfreq:=200; skip:=0;end;
  if dpeek($60028)=ord('3') then begin dpoke ($60028,0); siddelay:=6666; songfreq:=150; skip:=0; end;
  if dpeek($60028)=ord('4') then begin dpoke ($60028,0); siddelay:=2500; songfreq:=400; skip:=0; end;
  if dpeek($60028)=ord('p') then begin dpoke ($60028,0); pause:=not pause; if pause then sdl_pauseaudio(1) else sdl_pauseaudio(0); end;
  if dpeek($60028)=282 then begin dpoke($60028,0); if peek($70003)=0 then poke ($70003,1) else poke ($70003,0); end;
  if dpeek($60028)=283 then begin dpoke($60028,0); if peek($70004)=0 then poke ($70004,1) else poke ($70004,0); end;
  if dpeek($60028)=284 then begin dpoke($60028,0); if peek($70005)=0 then poke ($70005,1) else poke ($70005,0); end;

  if dpeek($60028)=ord('f') then
    begin
    dpoke($60028,0);
    poke ($70006,1);
    repeat until peek($70007)=1;
    if fullscreen=0 then
      begin
      SDL_FreeSurface(scr);
      p:=@tabl[0];
      fpioctl(scrfh,getvinfo,p);
      tabl2:=tabl;
      p2:=nil;                               //pointer to framebuffer memory init
      scr:=SDL_SetVideoMode(tabl[0], tabl[1], 32, SDL_SWSURFACE or SDL_FULLSCREEN);
      SDL_EnableKeyRepeat(200,50);
      sdl_showcursor(0);
      tabl[0]:=1920;
      tabl[1]:=1200;
      tabl[2]:=1920 ;
      tabl[3]:=2400 ;
      tabl[6]:=32;
      fpioctl(scrfh,setvinfo,p);
      p2:=fpmmap(nil,1920*2400*4,prot_read or prot_write,map_shared,scrfh,0);
      for i:=0 to 1920*2400-1 do (p2+i)^:=$FFFF;
      scrconvert:=@scrconvert16f;
      fullscreen:=1;
      poke($70006,0);
      poke($70007,0);
      end
    else
      begin
      sdl_pauseaudio(1);
      sdl_closeaudio;
      fpmunmap(p2,1920*2400*4);
      p:=@tabl;
      tabl:=tabl2;
      fpioctl(scrfh,setvinfo,p);
      fullscreen:=0;
      p2:=nil;
      scr:=SDL_SetVideoMode(960, 600, 32, SDL_SWSURFACE);
      sdl_sound_init;
      scrconvert:=@scrconvert16;
      poke($70006,0);
      poke($70007,0);
      sdl_pauseaudio(0);
      end;

    end;

  if dpeek($60028)=274 then
    begin
    dpoke($60028,0);
    if sel<ild then
      begin
      box(920,132+32*sel,840,32,34);
      if filenames[sel+selstart,1]='' then l:=length(filenames[sel+selstart,0])-4 else  l:=length(filenames[sel+selstart,0]);
      if filenames[sel+selstart,1]='' then  s:=copy(filenames[sel+selstart,0],1,length(filenames[sel+selstart,0])-4) else s:=filenames[sel+selstart,0];
      if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
      for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
      if filenames[sel+selstart,1]='' then outtextxyz(1344-8*l,132+32*(sel),s,44,2,2);
      if filenames[sel+selstart,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*(sel),s,44,2,2);  outtextxyz(1672,132+32*(sel),'[DIR]',44,2,2);   end;
      sel+=1;
      box(920,132+32*sel,840,32,36);
      if filenames[sel+selstart,1]='' then l:=length(filenames[sel+selstart,0])-4 else  l:=length(filenames[sel+selstart,0]);
      if filenames[sel+selstart,1]='' then  s:=copy(filenames[sel+selstart,0],1,length(filenames[sel+selstart,0])-4) else s:=filenames[sel+selstart,0];
      if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
      for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
      if filenames[sel+selstart,1]='' then outtextxyz(1344-8*l,132+32*(sel),s,44,2,2);
      if filenames[sel+selstart,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*(sel),s,44,2,2);  outtextxyz(1672,132+32*(sel),'[DIR]',44,2,2);   end;
      end
    else if sel+selstart<ilf-1 then
      begin
      selstart+=1;
      box2(897,118,1782,1008,34);
      box(920,132+32*sel,840,32,36);
      for i:=0 to ild do
        begin
        if filenames[i+selstart,1]='' then l:=length(filenames[i+selstart,0])-4 else  l:=length(filenames[i+selstart,0]);
        if filenames[i+selstart,1]='' then  s:=copy(filenames[i+selstart,0],1,length(filenames[i+selstart,0])-4) else s:=filenames[i+selstart,0];
        if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
        for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
        if filenames[i+selstart,1]='' then outtextxyz(1344-8*l,132+32*i,s,44,2,2);
        if filenames[i+selstart,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*i,s,44,2,2);  outtextxyz(1672,132+32*i,'[DIR]',44,2,2);   end;
        end;
      end;
    end;

  if dpeek($60028)=273 then
     begin
      dpoke($60028,0);
      if sel>0 then
        begin
        box(920,132+32*sel,840,32,34);
        if filenames[sel+selstart,1]='' then l:=length(filenames[sel+selstart,0])-4 else  l:=length(filenames[sel+selstart,0]);
        if filenames[sel+selstart,1]='' then  s:=copy(filenames[sel+selstart,0],1,length(filenames[sel+selstart,0])-4) else s:=filenames[sel+selstart,0];
        if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
        for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
        if filenames[sel+selstart,1]='' then outtextxyz(1344-8*l,132+32*(sel),s,44,2,2);
        if filenames[sel+selstart,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*(sel),s,44,2,2);  outtextxyz(1672,132+32*(sel),'[DIR]',44,2,2);   end;
        sel-=1;
        box(920,132+32*sel,840,32,36);
        if filenames[sel+selstart,1]='' then l:=length(filenames[sel+selstart,0])-4 else  l:=length(filenames[sel+selstart,0]);
        if filenames[sel+selstart,1]='' then  s:=copy(filenames[sel+selstart,0],1,length(filenames[sel+selstart,0])-4) else s:=filenames[sel+selstart,0];
        if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
        for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
        if filenames[sel+selstart,1]='' then outtextxyz(1344-8*l,132+32*(sel),s,44,2,2);
        if filenames[sel+selstart,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*(sel),s,44,2,2);  outtextxyz(1672,132+32*(sel),'[DIR]',44,2,2);   end;
        end
      else if sel+selstart>0 then
        begin
        selstart-=1;
        box2(897,118,1782,1008,34);
        box(920,132+32*sel,840,32,36);
        for i:=0 to ild do
          begin
          if filenames[i+selstart,1]='' then l:=length(filenames[i+selstart,0])-4 else  l:=length(filenames[i+selstart,0]);
          if filenames[i+selstart,1]='' then s:=copy(filenames[i+selstart,0],1,length(filenames[i+selstart,0])-4) else s:=filenames[i+selstart,0];
          if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
          for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
          if filenames[i+selstart,1]='' then outtextxyz(1344-8*l,132+32*i,s,44,2,2);
          if filenames[i+selstart,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*i,s,44,2,2);  outtextxyz(1672,132+32*i,'[DIR]',44,2,2);   end;
          end;
        end;
      end;

      if dpeek($60028)=270 then
      begin
      dpoke($60028,0);
      if songs>0 then
        begin
        if song<songs then
          begin
          sdl_pauseaudio(1);
          for i:=1 to 20000000 do;
          song+=1;
          jsr6502(song,init);
          sdl_pauseaudio(0);
          end;
        end;
      end;

     if dpeek($60028)=269 then
      begin
      dpoke($60028,0);
      if songs>0 then
        begin
        if song>0 then
          begin
          sdl_pauseaudio(1);
          for i:=1 to 20000000 do;
          song-=1;
          jsr6502(song,init);
          sdl_pauseaudio(0);
          end;
        end;
      end;

    if dpeek($60028)=13 then
      begin
      dpoke($60028,0);
      if filenames[sel+selstart,1]='[DIR]' then
        begin
        dirlist(currentdir2+filenames[sel+selstart,0]+'/'); {

        box2(897,118,1782,1008,34);
        s:=filenames[sel+selstart,0];
        if copy(s,length(s),1)<>'\' then
          begin
          setcurrentdir(currentdir2+s);
          currentdir2:=getcurrentdir+'/';
          if copy(currentdir2,length(currentdir2)-1,2)='\\'then currentdir2:=copy(currentdir2,1,length(currentdir2)-1);
          end
        else
          begin
          setcurrentdir(s);
          currentdir2:=getcurrentdir;
          end;
        ilf:=0;
        currentdir:=currentdir2+'*';
        if findfirst(currentdir,fadirectory,sr)=0 then
          repeat
          if (sr.attr and faDirectory) = faDirectory then
            begin
            filenames[ilf,0]:=sr.name;
            filenames[ilf,1]:='[DIR]';
            ilf+=1;
            end;
          until (findnext(sr)<>0) or (ilf=1000);
        sysutils.findclose(sr);

        currentdir:=currentdir2+'*.sid';

        if findfirst(currentdir,faAnyFile,sr)=0 then
          repeat
          filenames[ilf,0]:=sr.name;
          filenames[ilf,1]:='';
          ilf+=1;
          until (findnext(sr)<>0) or (ilf=1000);
        sysutils.findclose(sr);

        currentdir:=currentdir2+'*.dmp';

        if findfirst(currentdir,faAnyFile,sr)=0 then
          repeat
          filenames[ilf,0]:=sr.name;
          filenames[ilf,1]:='';
          ilf+=1;
          until (findnext(sr)<>0) or (ilf=1000);
        sysutils.findclose(sr);

        sort;

        box(920,132,840,32,36);
        if ilf<26 then ild:=ilf-1 else ild:=26;
        for i:=0 to ild do
          begin
          if filenames[i,1]='' then l:=length(filenames[i,0])-4 else  l:=length(filenames[i,0]);
          if filenames[i,1]='' then  s:=copy(filenames[i,0],1,length(filenames[i,0])-4) else s:=filenames[i,0];
          if length(s)>40 then begin s:=copy(s,1,40); l:=40; end;
          for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
          if filenames[i,1]='' then outtextxyz(1344-8*l,132+32*i,s,44,2,2);
          if filenames[i,1]='[DIR]' then begin outtextxyz(1344-8*l,132+32*i,s,44,2,2);  outtextxyz(1672,132+32*i,'[DIR]',44,2,2);   end;
          end;
        //application.processmessages;
        sel:=0; selstart:=0;
        box2(897,67,1782,115,36);
        s:=currentdir2;
        if length(s)>55 then s:=copy(s,1,55);
        l:=length(s);
        outtextxyz(1344-8*l,75,s,44,2,2);                }
        end

      else

        begin if not pause then
          begin
          pause:=true;
          sdl_pauseaudio(1);
          end;
        for i:=0 to 20000000 do begin end;
        for i:=0 to $2F do siddata[i]:=0;
        for i:=$50 to $7F do siddata[i]:=0;
        siddata[$0e]:=$7FFFF8;
        siddata[$1e]:=$7FFFF8;
        siddata[$2e]:=$7FFFF8;
        if sfh>=0 then fileclose(sfh);
        sfh:=-1;
        songtime:=0;

        for i:=0 to 6 do raml^[$3500+i]:=0;
        fn:= currentdir2+filenames[sel+selstart,0];
        sfh:=fileopen(fn,$40);
        s:=copy(filenames[sel+selstart,0],1,length(filenames[sel+selstart,0])-4);
        for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
        siddelay:=20000;
        filetype:=0;
        fileread(sfh,buf,4);
        if (buf[0]=ord('S')) and (buf[1]=ord('D')) and (buf[2]=ord('M')) and (buf[3]=ord('P')) then
          begin
          box(18,132,800,600,178);
          outtextxyz(18,132,'type: SDMP',188,2,2);
          songs:=0;
          fileread(sfh,buf,4);
          siddelay:=1000000 div buf[0];
          outtextxyz(18,196,'speed: '+inttostr(buf[0])+' Hz',188,2,2);
          atitle:='                                ';
          fileread(sfh,atitle[1],16);
          fileread(sfh,buf,1);
          outtextxyz(18,164,'atitle: '+atitle,188,2,2);
          box(18,912,800,32,244);
          outtextxyz(18,912,'SIDCog DMP file, '+inttostr(songfreq)+' Hz',250,2,2);
          end
        else if (buf[0]=ord('P')) and (buf[1]=ord('S')) and (buf[2]=ord('I')) and (buf[3]=ord('D')) then
          begin
          reset6502;
          sidopen(sfh);
          if cia>0 then siddelay:={985248}1000000 div (50*round(19652/cia));
          filetype:=1;
          box(18,912,800,32,244);
          outtextxyz(18,912,'PSID file, '+inttostr(1000000 div siddelay)+' Hz',250,2,2);
          end
        else if (buf[0]=ord('R')) and (buf[1]=ord('S')) and (buf[2]=ord('I')) and (buf[3]=ord('D')) then
          begin
          filetype:=2;
          box(18,132,800,600,178);
          outtextxyz(18,132,'type: RSID, not yet supported',44,2,2);
          end
        else
          begin
          fileread(sfh,buf,21);
          box(18,132,800,600,178);
          outtextxyz(18,132,'type: unknown, 50 Hz SDMP assumed',188,2,2);
          box(18,912,800,32,244);
          outtextxyz(18,912,'SIDCog DMP file, 50 Hz',250,2,2);
          end;
        songname:=s;
        songtime:=0;
        timer1:=-1;
        if filetype<>2 then begin pause:=false; sdl_pauseaudio(0); end;
        end;
    end;
  until (dpeek($60028)=27) ;
  sdl_pauseaudio(1);
  for i:=0 to 100000000 do;
  if sfh>0 then fileclose(sfh);
  setcurrentdir(workdir);
  stopmachine;
end.

