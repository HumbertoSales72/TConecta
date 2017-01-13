//////////////////////////////////////////////////////////
//	Desenvolvedor: Humberto Sales de Oliveira       //
//	Email: 	humbertoliveira@hotmail.com		//
//		humbertosales@midassistemas.com.br	//
//		humberto_s_o@yahoo.com.br		//
//	Objetivo:                                       //  
//		1)Conectar software atraves da Intranet //
//		usando os components SQLDB		//
//                                                      //
//	licensa: free                                   //
//                                                      //
//	*Auterações, modificações serão bem vindos      //
//	Créditos:                                       //      
//                                                      //   
//////////////////////////////////////////////////////////

unit scon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Conecta, Dialogs,SqlDb,db;

Type

  TSqlCon = Class(TBaseConector)

  Private
      FCon : TSqlConnector;
      Fconectado : Boolean;
  Public
      Constructor create(Configuracao : TPathBanco); overload;
      Destructor destroy;override;
      Function CriarQuery : TBaseQuery; Override;
      procedure open; Override;
      procedure close; Override;
  published
      property  Conectado : boolean read FConectado default false;
  end;



  { TSqlQry }

  TSqlQry = Class(TBaseQuery)

      Private
        FQuery : TSqlQuery;
        FDataSource : TDataSource;
      Public
         Constructor create;
         Destructor Destroy;
         procedure Open; override;
         procedure close; override;
         procedure execsql;  override;
         function dataset : TDataSet; override;
         function sql : TStrings;  override;
         Function fields : Tfields; override;
         function params : TParams; override;
         function ParambyName(Const AparamName :  String): TParam; override;
         function IsEmpty : boolean; override;
         procedure CriarDataSource;  override;
         Function DataSource : TDataSource;  override;
      Published
        Property query : TsqlQuery read FQuery;
  end;





  var
    FTra : TSQLTransaction;

implementation

{ TSqlQry }

constructor TSqlQry.create;
begin
  FQuery := TSqlquery.create(nil);
  CriarDataSource;
end;

destructor TSqlQry.Destroy;
begin
  FreeAndNil(FDataSource);
  FreeAndNil(FQuery);
  inherited destroy;
end;

procedure TSqlQry.Open;
begin
  FQuery.open;
end;

procedure TSqlQry.close;
begin
  FQuery.Close;
end;

procedure TSqlQry.execsql;
begin
   FQuery.ExecSQL;
   FTra.CommitRetaining;
end;

function TSqlQry.dataset: TDataSet;
begin
  Result := FQuery;
end;

function TSqlQry.sql: TStrings;
begin
   Result := FQuery.Sql;
end;

function TSqlQry.fields: Tfields;
begin
   Result := FQuery.Fields;
end;

function TSqlQry.params: TParams;
begin
   Result := FQuery.Params;
end;

function TSqlQry.ParambyName(const AparamName: String): TParam;
begin
    Result := FQuery.Parambyname(AparamName);
end;

function TSqlQry.IsEmpty: boolean;
begin
  Result := FQuery.IsEmpty;
end;

procedure TSqlQry.CriarDataSource;
begin
  FDataSource := TDataSource.Create(Nil);
  DataSource.DataSet := FQuery;
end;

function TSqlQry.DataSource: TDataSource;
begin
  Result := FDataSource;
end;

{ TSqlCon }

constructor TSqlCon.create(Configuracao: TPathBanco);
begin
try
  FCon := TSQLConnector.create(nil);
  FTra := TSQLTransaction.create(nil);
  Ftra.DataBase := FCon;
  With Fcon, Configuracao do
      begin
        DatabaseName :=  Banco;
        HostName     :=  IP;
        Password     :=  Senha;
        UserName     :=  Usuario;
        ConnectorType:=  TipoBanco;
        Open;
      end;

Except
    Showmessage('Houve um erro ao inserir as configurações do "PathBanco.txt" no componente SQLConnector' + #13 + 'Corrija as configurações e tente Novamente!');
end;
end;

destructor TSqlCon.destroy;
begin
  freeAndNil(FCon);
  FreeAndNil(Ftra);
end;

function TSqlCon.CriarQuery: TBaseQuery;
var
  Qry : TSqlQry;
begin
  Qry := TSqlqry.create;
  With Qry.Query do
      begin
         Database := Fcon;
         Transaction := FTra;
      end;
  Result := Qry;


end;

procedure TSqlCon.open;
begin
   FCon.Open;
   Fconectado:= True;
end;

procedure TSqlCon.close;
begin
   FCon.Close;
   Fconectado:= False;
end;

end.

