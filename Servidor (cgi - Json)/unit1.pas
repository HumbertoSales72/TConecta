//////////////////////////////////////////////////////////
//	Desenvolvedor: Humberto Sales de Oliveira       //
//	Email: 	humbertoliveira@hotmail.com		//
//		humbertosales@midassistemas.com.br	//
//		humberto_s_o@yahoo.com.br		//
//	Objetivo:                                       //  
//		1)Servidor CGI com Json para internet 	//
//							// 
//                                                      //
//	licensa: free                                   //
//                                                      //
//	*Auterações, modificações serão bem vindos      //
//	Créditos:                                       //      
//                                                      //   
//////////////////////////////////////////////////////////
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, jsonlib, codificacao, httpdefs, fpHTTP, fpWeb, ZConnection,
  ZDataset, fpjson, db, strutils;

type

  { TFPWebModule1 }
  TTipoConexao = (tcPostgresql,tcFirebird,tcMysql);
  TFPWebModule1 = class(TFPWebModule)
    procedure acaoRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
    procedure onlineRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
    Procedure ProcessarParametros(Fjson : TJsonObject; AResponse : TResponse);
  private
    function IsOnline: boolean;


  public

  end;

var
  FPWebModule1: TFPWebModule1;
  Con : TZConnection;
  Qry : TZQuery;
  tpConexao : TTipoConexao;
  TLimite : array[0..2] of string=(' LIMIT ', ' TO ', ' LIMIT ');
  TPOSICAO: array[0..2] of string=(' OFFSET ', ' ROWS ', ' , ');
  TCursorInicial : array[0..2] of integer=( 0,1,0 );


implementation

{$R *.lfm}

function TFPWebModule1.IsOnline : boolean;
var
  x : Integer;
begin
 x := 0;
 result := false;
 if Con.PingServer then
    result := True
 Else begin
    Con.Connected := False;
    WriteLn('Servidor desconectado do banco. Tentativa de Reconexão em 5 segundos');
    while x < 5000 do
       begin
          sleep(1000);
          writeLn('Reiniando conexão em ' + inttostr(5000 - x));
          x := x + 1000;
          if x = 5000 then
            begin
               Con.Connected := true;
               if Con.PingServer then
                 begin
                     result := True;
                     break;
                 end
               else begin
                    x := 0;
               end;
            end;

       end;

 end;
end;


procedure TFPWebModule1.acaoRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
var
  x : integer;
  JRequest : TJsonObject;
begin
  WriteLn(Format('Cliente "%s" Data/Hora: %s  Requisicao: %s', [ARequest.RemoteAddr,formatdatetime('dd/mm/yyyy hh:mm:ss:zzz',now),ARequest.QueryFields.Values['QUERY']]));
  WriteLn('');
  WriteLn('');
  try
      aResponse.ContentType:= 'text/html';
      JRequest := TJsonObject.create;
      JRequest := TJsonObject(  GetJson(ARequest.QueryFields.Values['QUERY'])  );
      if IsOnline then
        ProcessarParametros(JRequest,AResponse);
      Handled := true;
  finally
     JRequest.free;
  end;
  WriteLn(Format('Cliente "%s" Data/Hora da Resposta: %s ', [ARequest.RemoteAddr,formatdatetime('dd/mm/yyyy hh:mm:ss:zzz',now)]));
  WriteLn('');
  WriteLn('');

end;

procedure TFPWebModule1.onlineRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
begin
  WriteLn(Format('Cliente "%s" Data/Hora: %s Requisição: %s ', [ARequest.RemoteAddr,formatdatetime('dd/mm/yyyy hh:mm:ss:zzz',now), 'Online']));
  WriteLn('');
  WriteLn('');
  Aresponse.Content:= 'online';
  Handled := True;
end;

procedure TFPWebModule1.ProcessarParametros(Fjson: TJsonObject;
  AResponse: TResponse);
var
  i,J : integer;
  SubNivel : TJsonObject;
  F : TMemoryStream;
  S,G : String;

begin
  {"sql":"select * from veiculo where codigo = :codigo","posicao":0,"pacotes":10, "parametros":{"codigo":10}}
  Qry.close;
  SubNivel := TJsonObject.Create;
  For i := 0 to pred(FJson.count) do
       begin
           Case uppercase(Fjson.Names[i]) of
             'SQL' : Qry.sql.text := fJson.Items[i].asstring;
             'PARAMETROS' : BEGIN
                                Try
                                   SubNivel := TJsonObject(GetJson(fJson.Items[i].AsJson));

                                   For j := 0 to pred(subNivel.Count) do
                                          begin
                                              if (SubNivel.Items[j] is TJSONFloatNumber) then
                                                 Qry.Params.ParamByName(SubNivel.Names[j]).Asfloat := SubNivel.Items[j].Asfloat;
                                              if (SubNivel.Items[j] is TJSONIntegerNumber) then
                                                 Qry.Params.ParamByName(SubNivel.Names[j]).AsInteger := SubNivel.Items[j].Asinteger;
                                              if (SubNivel.Items[j] is TJSONInt64Number) then
                                                 Qry.Params.ParamByName(SubNivel.Names[j]).AsInteger := SubNivel.Items[j].AsInteger;
                                              if (SubNivel.Items[j] is TJSONString) then
                                                 if copy(SubNivel.Items[j].AsString ,1,6) = '#blob#' then
                                                    begin
                                                      S := SubNivel.Items[j].AsString;
                                                      Delete(S,1,6);
                                                      S := desconverter(S);
                                                      try
                                                      F := TMemoryStream.create;
                                                      Decode64StringToStream(S,F);
                                                      Qry.Params.ParamByName(SubNivel.Names[j]).LoadFromStream(F,ftblob);
                                                      finally
                                                        FreeAndNil( F );
                                                      end;
                                                    end
                                                    else
                                                      Qry.Params.ParamByName(SubNivel.Names[j]).AsString := SubNivel.Items[j].AsString;
                                              if (SubNivel.Items[j] is TJSONBoolean) then
                                                 Qry.Params.ParamByName(SubNivel.Names[j]).AsBoolean := SubNivel.Items[j].AsBoolean;
                                          end;
                                finally
                                   SubNivel.free;
                                end;
                            END;
             'POSICAO' : BEGIN
                              //comentado antigo
                             // if (copy( uppercase(Fjson.items[0].asstring), 1,6) = 'SELECT' ) AND ( LastDelimiter('OFFSET',UPPERCASE(Fjson.items[0].asstring) ) > 0 ) THEN
                              //   Qry.sql.text := format('%s %s' , [Qry.sql.text,' OFFSET ' + inttostr(Fjson.Items[i].AsInteger)]);
                              if (copy( uppercase(Fjson.items[0].asstring), 1,6) = 'SELECT' ) AND ( LastDelimiter(TPOSICAO[ORD(tpConexao)],UPPERCASE(Fjson.items[0].asstring) ) > 0 ) THEN
                                 Qry.sql.text := format('%s %s' , [Qry.sql.text,TPOSICAO[ORD(tpConexao)] + inttostr(Fjson.Items[i].AsInteger + TCURSORINICIAL[ORD(tpConexao)] )]  );
                         END;
             'PACOTES' : BEGIN
                             if ( copy( uppercase(Fjson.items[0].asstring), 1,6) = 'SELECT' )  AND ( LastDelimiter(TLIMITE[ORD(tpConexao)],UPPERCASE(Fjson.items[0].asstring)) > 0 ) THEN
                                    Qry.sql.text := format('%s %s' , [Qry.sql.text,TLIMITE[ORD(tpConexao)] + inttostr(Fjson.Items[i].AsInteger)])
                             Else
                                 IF (copy( uppercase(Fjson.items[0].asstring), 1,6) = 'SELECT' ) AND (  LastDelimiter(TLIMITE[ORD(tpConexao)],uppercase(Fjson.items[0].asstring)) < LastDelimiter('FROM',uppercase(Fjson.items[0].asstring)) ) THEN
                                    Qry.sql.text := format('%s %s' , [Qry.sql.text,TLIMITE[ORD(tpConexao)] + inttostr(Fjson.Items[i].AsInteger)])

                         END;
             end; //end case

       end;  //end for
  writeln('SQL Alterada ----->> ' + TPOSICAO[ORD(tpConexao)] + '  ' + Qry.sql.text);
  Case UpperCase(Fjson.Names[0]) of
      'SQL' : BEGIN
                  Try
                          Case Copy(UpperCase(Qry.Sql.text),1,Pos(' ',Qry.Sql.text) -1) of
                             'SELECT' :
                                        BEGIN
                                            Qry.open;
                                            AResponse.Content := DataSetToJson(Qry);
                                        END;
                             'INSERT','UPDATE','DELETE' :
                                        BEGIN
                                            Qry.ExecSql;
                                            Qry.Close;
                                            Qry.Sql.Text := 'Commit';
                                            Qry.ExecSql;
                                            Case Copy(UpperCase(Qry.Sql.text),1,Pos(' ',Qry.Sql.text) -1) of
                                               'INSERT' : Aresponse.Content := '{"#msg":"Inserido com sucesso!"}';
                                               'UPDATE' : Aresponse.Content := '{"#msg":"Atualizado com sucesso!"}';
                                               'DELETE' : Aresponse.Content := '{"#msg":"Removido com sucesso!"}';
                                            end;
                                        END;

                          end;
                  Except
                      On E:Exception do
                         begin
                             AResponse.Content := '{"#msg":"' + E.Message + '"}';
                             Qry.Close;
                         end;
                  end;


              END;
  end;//case
  //WriteLn(AResponse.Content);
end;

procedure criarConexoes;
var
  Path : TStrings;
begin
  Con := TZConnection.Create(Nil);
  Qry := TZQuery.Create(nil);
Try
  Path := TStringList.Create;
  if FileExists('PathBanco.txt') then
       Path.LoadFromFile('PathBanco.txt')
   else
       Raise Exception.Create('Não foi encontrado o arquivo de configuração');
  With Con do
     begin
        Database  := Path.Values['Banco'];
        HostName  := Path.Values['IP'];
        Port      := StrToInt(Path.Values['Porta']);
        Protocol  := Path.Values['TipoBanco'];
        Case UpperCase(Copy(Protocol,1,5)) of
           'POSTG' : tpConexao := tcPostgresql;
           'FIREB' : tpConexao := tcFirebird;
           'MYSQL' : tpConexao := tcMysql;
        end;
        PassWord  := Path.Values['Senha'];
        User      := Path.Values['Usuario'];
        Connected := True;
     end;
  Qry.Connection := Con;
finally
   FreeAndNil(Path);
end;

end;

Procedure DestroiConexoes;
begin
  Qry.close;
  Con.Connected := false;
  FreeandNil(qry);
  FreeandNil(Con);
end;

initialization
  RegisterHTTPModule('TFPWebModule1', TFPWebModule1);
  CriarConexoes;
  DefaultFormatSettings.DateSeparator:='/';

finalization
  DestroiConexoes;
end.

