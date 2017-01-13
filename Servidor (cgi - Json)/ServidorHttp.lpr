program ServidorHttp;

{$mode objfpc}{$H+}

uses
  fphttpapp, Unit1, crt,sysutils;

begin
  Application.Port:=1200;
  Application.Initialize;
  ClrScr;
  cursoroff;
  TextColor(Yellow);
  WriteLn(StringofChar('*',79));
  WriteLn('');
  WriteLn('');
  WriteLn(STRINGOFCHAR(' ',40 - (LENGTH('Midas Sistemas - Servidor de Dados (json)') DIV 2)) + 'Midas Sistemas - Servidor de Dados (json)');
  WriteLn('');
  WriteLn('');
  WriteLn(StringofChar('*',79));
  TextColor(White);
  WriteLn( format('Servidor iniciado em: %s' , [ formatdatetime('dd/mm/yyyy hh:mm:ss:zzz',now)  ])  );
  WriteLn( '' );
  WriteLn( '' );
  Application.Run;
end.

