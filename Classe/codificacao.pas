//////////////////////////////////////////////////////////
//	Desenvolvedor: Anonimo ou nao Encontrado        //
//	Email: -------					//
//							//
//	Objetivo:                                       //  
//		1)Pegar imagens e transformar em texto  //
//		                                        //
//                                                      //
//	licensa: free                                   //
//                                                      //
//	*Auterações, modificações serão bem vindos      //
//	Créditos:                                       //      
//                                                      //   
//////////////////////////////////////////////////////////

unit codificacao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils;

function Encode64String(S: string): string;
function Decode64String(S: string): string;
function Encode64StringToStream(const Input: TStream; var Output: string): Boolean;
procedure Decode64StringToStream(const Input: string; Output: TStream);
procedure StringToStream(Stream: TStream; const S: string);
function StreamToString(MS: TMemoryStream): string;
function Converte(G : String) : String;
function desconverter(G : String) : String;
Const
  Keys64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';

implementation

function StreamToString(MS: TMemoryStream): string;
begin
  SetString(Result, PChar(MS.Memory), MS.Size div SizeOf(Char));
end;


function Encode64String(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := 1 to Length(s) do
  begin
    x := Ord(s[i]);
    b := b * 256 + x;
    a := a + 8;
    while a >= 6 do
    begin
      a := a - 6;
      x := b div (1 shl a);
      b := b mod (1 shl a);
      Result := Result + Keys64[x + 1];
    end;
  end;
  if a > 0 then
  begin
    x := b shl (6 - a);
    Result := Result + Keys64[x + 1];
  end;
end;

function Decode64String(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := 1 to Length(s) do
  begin
    x := Pos(s[i], Keys64) - 1;
    if x >= 0 then
    begin
      b := b * 64 + x;
      a := a + 6;
      if a >= 8 then
      begin
        a := a - 8;
        x := b shr a;
        b := b mod (1 shl a);
        x := x mod 256;
        Result := Result + chr(x);
      end;
    end
    else
      Exit;
  end;
end;

function Encode64StringToStream(const Input: TStream; var Output: string): Boolean;
var
  MS: TMemoryStream;
begin
  Result := False;

  MS := TMemoryStream.Create;
  try
    Input.Seek(0, soFromBeginning);
    MS.CopyFrom(Input, Input.Size);
    MS.Seek(0, soFromBeginning);
    Output := Encode64String(StreamToString(MS));
  finally
    MS.Free;
  end;

  Result := True;
end;

procedure Decode64StringToStream(const Input: string; Output: TStream);
var
  MS: TMemoryStream;
begin
  try
    MS := TMemoryStream.Create;
    try
      StringToStream(MS, Decode64String(Input));

      MS.Seek(0, soFromBeginning);
      Output.CopyFrom(MS, MS.Size);
      Output.Position := 0;
    finally
      MS.Free;
    end;

  except on E: Exception do
    raise Exception.Create('stream decode error - ' + E.Message);
  end;
end;

procedure StringToStream(Stream: TStream; const S: string);
begin
  Stream.Write(Pointer(S)^, Length(S));
end;

function Converte(G : String) : String;
var
  x : Smallint;
  S : String;
begin
  Result := '';
  for x := 1 to Length(g) do
      Result := Result + inttostr(  ord(g[x])   )+ ' ';

end;

function desconverter(G : String) : String;
begin
  Result := '';
  While AnsiContainsStr(G,' ') do
      begin
        Result := Result + chr(StrToInt(  Trim( Copy(G,1,POS(' ',G)) ) ) );
        DELETE(G,1, POS(' ',G)  );
      end;
end;

end.

