//////////////////////////////////////////////////////////
//	Desenvolvedor: Humberto Sales de Oliveira       //
//	Email: 	humbertoliveira@hotmail.com		//
//		humbertosales@midassistemas.com.br	//
//		humberto_s_o@yahoo.com.br		//
//	Objetivo:                                       //  
//		1)Conectar software atraves da internet //
//	usando um servidor CGI - vide pasta "Servidor 	//
//	socket"						//
//		                                        //
//                                                      //
//	licensa: free                                   //
//                                                      //
//	*Auterações, modificações serão bem vindos      //
//	Créditos:                                       //      
//                                                      //   
//////////////////////////////////////////////////////////

unit skcon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Conecta, jsonlib, codificacao, Dialogs, ComCtrls,
  DB, BufDataset, memds, fpjson, strutils,blcksock;


Type

  { TStatus }

  TStatus = Class
  private
    Fstatus: String;
    procedure Setstatus(AValue: String);
    Published
      property status : String read Fstatus write Setstatus;
  end;

  { TMyQuery }

  TMyQuery = Class
    Private
      FParams :TParams;
      FSql : TStringList;
    Public
        FMemDataSet : TMemDataset;
        Constructor create;
        Destructor Destroy; Override;
        procedure open;
        procedure close;
        procedure clear;
        procedure insert;
        procedure post;
        procedure next;
        procedure prior;
        procedure last;
        procedure first;
        procedure enablecontrols;
        procedure disablecontrols;
        procedure GotoBookmark(const ABookmark: TBookmark);
        procedure FreeBookmark(ABookmark: TBookmark);
        function BookmarkValid(ABookmark: TBookmark): Boolean;
        function GetBookmark: TBookmark;
        function Fields : TFields;
        function DataSet : TDataSet;
        function IsEmpty : Boolean;
        Function Parambyname(Const AParamName : String) : TParam;
        Function Bookmark: TBookmark;
    protected

    Published
        property params : TParams read FParams Write Fparams;
        property Sql : TStringList read FSql Write FSql;
        property MemDataSet : TMemDataSet read FMemDataSet write FMemDataSet;
  end;



  { TCSOCKET }

  TSKSocket = Class(TBaseConector)
  Private
      Fconectado : Boolean;
      FStatus: String;
      procedure SetStatus(AValue: String);
  Public
      Constructor create(Configuracao : TPathBanco); overload;
      Destructor destroy;override;
      Function CriarQuery : TBaseQuery; Override;
      procedure open; Override;
      procedure close; Override;
  published
      property Conectado : boolean read FConectado default false;
      property Status : String read FStatus write SetStatus;
  end;


  { TCQry }

  { TSKQry }

  TSKQry = Class(TBaseQuery)
  Private
      FQuery : TMyQuery;
      FDataSource : TDataSource;
      FStatus: String;
      procedure SetStatus(AValue: String);
  Public
      constructor create;
      destructor destroy; override;
      procedure open; override;
      procedure close; override;
      procedure execsql; override;
      procedure posicaocursor(DSet : TDataSet);
      procedure enviar(Js : TJSONStringType);
      procedure Reenviar(Js : TJSONStringType);
      Function dataset : TDataSet; override;
      function sql : TStringList; override;
      function Fields : TFields; override;
      function params : TParams; override;
      function processarsql(Sq : TStringList; parametros : TParams; Pacotes, Posicao : Integer) : TJSONStringType;
      function processarparametros(Parametros : TParams) : TJSONStringType;
      function parambyname(Const AparamName: String) : TParam; override;
      function isEmpty : Boolean; override;
      procedure CriarDataSource;  override;
      Function DataSource : TDataSource;  override;
    Published
      property Status : String read FStatus write SetStatus;
  end;


Var
  Conf : TPathBanco;
  FStatusServer : TStatus;
  cli : TTCPBlockSocket;

implementation

{ TStatus }

procedure TStatus.Setstatus(AValue: String);
begin
  if Fstatus=AValue then Exit;
  Fstatus:=AValue;
end;

{ TSKQry }

procedure TSKQry.SetStatus(AValue: String);
begin
  if FStatus=AValue then Exit;
  FStatus:=AValue;
  FStatusServer.status := AValue;
end;

constructor TSKQry.create;
begin
  FQuery := TMyQuery.create;
  CriarDataSource;
end;

destructor TSKQry.destroy;
begin
  FreeAndNil(FDataSource);
  FreeAndNil(Fquery);
  inherited destroy;
end;

procedure TSKQry.open;
Var
  Js : TJSONStringType;
begin
  Js := processarsql(FQuery.Sql,FQuery.params,strtoint(Conf.Pacotes),0);
  Js := ReplaceStr(Js,'\n','');
  With FQuery do
        Begin
            DisableControls;
            close;
            MemDataSet.BeforeScroll:= Nil;
            Clear;
            Fields.Clear;
            Enviar( Js );
            Open;
            First;
            EnableControls;
            MemDataSet.BeforeScroll:= @posicaocursor;
        end;
end;

procedure TSKQry.close;
begin
  FQuery.close;
  FQuery.Params.Clear;
end;

procedure TSKQry.execsql;
Var
  Js : TJSONStringType;
begin
  Js := processarsql(FQuery.Sql,FQuery.Params,StrtoInt(Conf.Pacotes),0);
  Js := ReplaceStr(Js,'\n','');
  FQuery.MemDataSet.BeforeScroll:= Nil;
  Enviar( Js );
end;

procedure TSKQry.posicaocursor(DSet: TDataSet);
var
  Js : TJSONStringType;
  B : TBookMark;
begin
  if DSet.RecNo = DSet.RecordCount then
      begin
          With FQuery do
              begin
                Js := processarsql(FQuery.Sql,FQuery.Params,strtoint(Conf.Pacotes),dSet.Recno);
                Try
                   MemDataSet.BeforeScroll := Nil;
                   DisableControls;
                   B := GetBookmark;
                   Reenviar( js );
                finally
                    if BookmarkValid(b) then
                       GotoBookmark(b);
                    FreeBookmark(B);
                    EnableControls;
                    MemDataSet.BeforeScroll:= @posicaocursor;
                end;
              end;
      end;


end;

procedure TSKQry.enviar(Js: TJSONStringType);
Var
  Resposta : String;
  Json : TJSONObject;
  I : Byte;
begin
  Try
     Json := TJSONObject.Create;
     Js := ReplaceStr(Js,'\n','');
     Js := ReplaceStr(Js,'\r','');
     Cli := TTCPBlockSocket.Create;
     Cli.Connect(Conf.Ip,Conf.porta);
     Cli.SendString('query=' + Js  + CRLF);
     Resposta := Cli.RecvString(10000);
     if Cli.LastError <> 0 then
        Status := 'Sem resposta do servidor! Erro: ' + IntToStr(Cli.LastError);

      if Resposta = '' then
         Status := 'Sem resposta do servidor!';
      if AnsiContainsStr(LowerCase(Resposta) , '#msg' ) then
          begin
              Json := TJSONObject( GetJson(Resposta) );
              Status := Json.Items[0].AsString;
          end
      Else Begin
          Json := TJSONObject( GetJson(Resposta) );
          Jsonlib.JSONToDataset(TDataSet(FQuery.FMemDataSet),Json);
      end;
  finally
      FreeAndNil(Cli);
      freeAndNil(Json);
  end;

end;

procedure TSKQry.Reenviar(Js: TJSONStringType);
var
  Resposta : String;
  Json : TJSONObject;
  i : SmallInt;
  Buf : TBufDataSet;
begin
  Try
     Json := TJSONObject.create;
     Cli := TTCPBlockSocket.Create;
     Cli.Connect(Conf.Ip,Conf.porta);
     Cli.SendString('query=' + Js  + CRLF);
     Resposta := Cli.RecvString(10000);
     if Cli.LastError <> 0 then
        Status := 'Sem resposta do servidor! Erro: ' + IntToStr(Cli.LastError);
     if Resposta = '' then
        Status := 'Sem resposta do servidor!';
     if AnsiContainsStr(LowerCase(Resposta) , '#msg' ) then
         begin
             Json := TJSONObject( GetJson(Resposta) );
             Status := Json.Items[0].AsString;
         end
         Else Begin
            Buf := TBufDataSet.create(nil);
            Json := TJSONObject( GetJson(Resposta) );
            jsonlib.JSONToDataset(TDataSet(Buf),Json);
            if Buf.IsEmpty = false then
                Try
                    Buf.first;
                    While not Buf.eof do
                        begin
                          FQuery.insert;
                          For i := 0 to pred(Buf.FieldCount) do
                            FQuery.Fields.Fields[i].value := Buf.Fields.Fields[i].Value;
                            FQuery.post;
                          Buf.next;
                        end;
                finally
                    Buf.free;
                end;
         end;
  finally
      FreeAndNil(Cli);
      FreeAndNil(Json);
  end;

end;

function TSKQry.dataset: TDataSet;
begin
  Result := FQuery.DataSet;
end;

function TSKQry.sql: TStringList;
begin
  Result := FQuery.Sql;
end;

function TSKQry.Fields: TFields;
begin
    Result := FQuery.Fields;
end;

function TSKQry.params: TParams;
begin
  Result := FQuery.Params;
end;

function TSKQry.processarsql(Sq: TStringList; parametros: TParams; Pacotes,
  Posicao: Integer): TJSONStringType;
var
Jo : TJSONObject;
Jdados : TJSONStringType;
begin
try
  Jo := TJSONObject.Create;
  Jo.Add('sql',Sq.Text);
  Jo.Add('pacotes',Pacotes);
  Jo.Add('posicao',Posicao);

  JDados := processarparametros(parametros);
  if JDados <> '{}' then
      Jo.Add('parametros',JDados);
  JDados := ReplaceStr(Jo.AsJson,'#10','');
  JDados := ReplaceStr(JDados,'#13','');
  JDados := ReplaceStr(JDados,'"{ \',' { ');
  JDados := ReplaceStr(JDados,'\"','"');
  JDados := ReplaceStr(JDados,'}"','}');
  Result := JDados;
finally
    Jo.free;
end;


end;

function TSKQry.processarparametros(Parametros: TParams): TJSONStringType;
Var
Jo : TJSONObject;
I : Integer;
///////////////////////////
F : TMemoryStream;
S : String;
MyBuffer: Pointer;
J : integer;
begin
Try
Jo := TJSONObject.create;
for i := 0 to Pred(Parametros.Count) do
  begin
      if Parametros.items[i].DataType = ftBlob then
          begin
              Try
                  F := TMemoryStream.Create;
                  J := Parametros.items[i].GetDataSize;
                  MyBuffer:= GetMemory(J);
                  Parametros.ParamByName(Parametros.items[i].name).getData(MyBuffer);
                  F.Write(MyBuffer^,J);
                  Encode64StringToStream(F,S);
                  S := '#blob#' + Converte(S);
                  parambyname( Parametros.items[i].Name ).AsString := S;
              finally
                  FreeAndNil(F);
                  Freemem(MyBuffer);
              end;

          end;
      Case GetJSONType(Parametros.Items[i].DataType) of
          'null'   : Jo.add(parametros.items[i].name,parametros.ParamByName(parametros.items[i].name).AsString);
          'string' : Jo.add(parametros.items[i].name,parametros.items[i].asstring);
          'boolean': Jo.add(parametros.items[i].name,parametros.items[i].asboolean);
          'date'   : Jo.add(parametros.items[i].name,parametros.items[i].asstring);
          'float'  : Jo.add(parametros.items[i].name,parametros.items[i].asfloat);
          'int'    : Jo.add(parametros.items[i].name,parametros.items[i].AsInteger);
      end;
  end;
Result := JO.AsJSON;
finally
 Jo.free;
end;

end;

function TSKQry.parambyname(const AparamName: String): TParam;
begin
  Result := Fquery.ParamByName(AparamName);
end;

function TSKQry.isEmpty: Boolean;
begin
  Result := FQuery.IsEmpty;
end;

procedure TSKQry.CriarDataSource;
begin
  FDataSource := TDataSource.Create(Nil);
  DataSource.DataSet := FQuery.DataSet;
end;

function TSKQry.DataSource: TDataSource;
begin
  Result := FDataSource;
end;


{ TSKSocket }

procedure TSKSocket.SetStatus(AValue: String);
begin
  if FStatus=AValue then Exit;
  FStatus:=AValue;
  FStatusServer.status := AValue;
end;

constructor TSKSocket.create(Configuracao: TPathBanco);
Var
  Resposta : String;
begin
  Conf := Configuracao;
  if Conf.Pacotes = '' then
    Conf.Pacotes := '10';
  Try
    Cli := TTCPBlockSocket.Create;
    Cli.Connect(Conf.Ip,Conf.porta);
    Cli.SendString('online'+ CRLF);
    Resposta := Cli.RecvString(10000);
    if Cli.LastError <> 0 then
      begin
       Raise Exception.Create('Sem resposta do servidor! Erro: ' + IntToStr(Cli.LastError) );
      end
      Else Begin
            if Trim(LowerCase(Resposta)) = 'online' then
                FConectado := True
            Else begin
                FConectado := False;
                Raise Exception.Create('O Servidor não está conectado! Verifique as configurações do "PathBanco.txt" e tente novamente');
            end;
      end;

  finally
     FreeAndNil(Cli);
  end;

  FStatusServer := TStatus.Create;
end;

destructor TSKSocket.destroy;
begin

end;

function TSKSocket.CriarQuery: TBaseQuery;
var
  Qry : TSKQry;
begin
  Qry := TSKQry.create;
  Result := Qry;
end;

procedure TSKSocket.open;
Var
  Resposta : String;
begin
if FConectado = False then
    begin
        Try
          Cli := TTCPBlockSocket.Create;
          Cli.Connect(Conf.Ip,Conf.porta);
          Cli.SendString('online'+ CRLF);
          Resposta := Cli.RecvString(10000);
          if Cli.LastError <> 0 then
             Status := 'Sem resposta do servidor! Erro: ' + IntToStr(Cli.LastError);
          if Trim(LowerCase(Resposta)) = 'online' then
              FConectado := True
          Else
              FConectado := False;
        Finally
           FreeAndNil(cli);
        end;

    end;

end;

procedure TSKSocket.close;
begin
  FConectado := False;
end;

{ TMyQuery }

function TMyQuery.GetBookmark: TBookmark;
begin
  Result := FMemDataSet.Bookmark;
end;

constructor TMyQuery.create;
begin
  FMemDataSet := TMemDataset.create(nil);
  FParams     := TParams.create;
  FSql        := TStringList.Create;
end;

destructor TMyQuery.Destroy;
begin
  FreeAndNil(FMemDataSet);
  FreeAndNil(FParams);
  FreeAndNil(FSql);
  inherited Destroy;
end;

function TMyQuery.Parambyname(const AParamName: String): TParam;
var
  Myparam : TParam;
begin
  if FParams.FindParam(AparamName) = Nil then
      begin
        With TParam.create(fParams) do
              begin
                Name := AParamName;
                ParamType:= ptInput;
                Result := FParams.FindParam(AparamName);
              end;
      end
      Else
      Result := FParams.FindParam(AparamName);

end;

procedure TMyQuery.open;
begin
  FMemDataSet.Open;
end;

procedure TMyQuery.close;
begin
  FMemDataSet.Close;
end;

procedure TMyQuery.clear;
begin
  FMemDataSet.Clear;
end;

function TMyQuery.BookmarkValid(ABookmark: TBookmark): Boolean;
begin
 Result := FMemDataSet.BookmarkValid(ABookMark);
end;

procedure TMyQuery.GotoBookmark(const ABookmark: TBookmark);
begin
 FMemDataSet.GotoBookmark(ABookMark);
end;

procedure TMyQuery.FreeBookmark(ABookmark: TBookmark);
begin
  FMemDataSet.FreeBookmark(ABookMark);
end;

function TMyQuery.Bookmark: TBookmark;
begin
  Result := FMemDataSet.Bookmark;
end;

function TMyQuery.Fields: TFields;
begin
  Result := FMemDataSet.Fields;
end;

function TMyQuery.DataSet: TDataSet;
begin
  Result := FMemDataSet
end;

function TMyQuery.IsEmpty: Boolean;
begin
 Result := FMemDataSet.IsEmpty;
end;

procedure TMyQuery.insert;
begin
  FMemDataSet.Insert;
end;

procedure TMyQuery.post;
begin
  FMemDataSet.Post;
end;

procedure TMyQuery.next;
begin
  FMemDataSet.next;
end;

procedure TMyQuery.prior;
begin
  FMemDataSet.prior;
end;

procedure TMyQuery.last;
begin
  FMemDataSet.last
end;

procedure TMyQuery.first;
begin
 FMemDataSet.first;
end;

procedure TMyQuery.enablecontrols;
begin
  FMemDataSet.EnableControls;
end;

procedure TMyQuery.disablecontrols;
begin
  FMemDataSet.DisableControls;
end;


end.

