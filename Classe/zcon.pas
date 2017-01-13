//////////////////////////////////////////////////////////
//	Desenvolvedor: Humberto Sales de Oliveira       //
//	Email: 	humbertoliveira@hotmail.com		//
//		humbertosales@midassistemas.com.br	//
//		humberto_s_o@yahoo.com.br		//
//	Objetivo:                                       //  
//		1)Conectar software atraves da Intranet //
//		usando os componentes ZEOS		//
//                                                      //
//	licensa: free                                   //
//                                                      //
//	*Auterações, modificações serão bem vindos      //
//	Créditos:                                       //      
//                                                      //   
//////////////////////////////////////////////////////////

unit zcon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,conecta,db,ZDataset,ZConnection;

Type

  { TZCon }

  TZCon = Class(TBaseConector)

  Private
      FCon : TZConnection;
      Fconectado : Boolean;
  Public
      Constructor create(Configuracao : TPathBanco); overload;
      Destructor destroy;override;
      Function CriarQuery : TBaseQuery; Override;
      Function CriarDataSource : TDataSource; virtual; Abstract;
      procedure open; Override;
      procedure close; Override;
  published
      property Conectado : boolean read FConectado default false;
  end;



  { TZQry }

  TZQry = Class(TBaseQuery)

      Private
        FQuery : TZQuery;
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
         function IsEmpty : Boolean; override;
         procedure CriarDataSource;  override;
         Function DataSource : TDataSource;  override;
      Published
        Property query : TZQuery read FQuery;
  end;

implementation

{ TZQry }

constructor TZQry.create;
begin
  FQuery := TZQuery.Create(nil);
  CriarDataSource;
end;

destructor TZQry.Destroy;
begin
  FreeAndNil(FDataSource);
  FreeAndNil(FQuery);
  inherited destroy;
end;

procedure TZQry.Open;
begin
  FQuery.Open;
end;

procedure TZQry.close;
begin
  FQuery.Close;
end;

procedure TZQry.execsql;
begin
  FQuery.ExecSQL;
end;

function TZQry.dataset: TDataSet;
begin
  Result := FQuery;
end;

function TZQry.sql: TStrings;
begin
  Result := FQuery.Sql;
end;

function TZQry.fields: Tfields;
begin
   Result := Fquery.Fields;
end;

function TZQry.params: TParams;
begin
   Result := FQuery.Params;
end;

function TZQry.ParambyName(const AparamName: String): TParam;
begin
   Result := FQuery.ParamByName(AparamName);
end;

function TZQry.IsEmpty: Boolean;
begin
    Result := FQuery.IsEmpty;
end;

procedure TZQry.CriarDataSource;
begin
  fDataSource := TDataSource.Create(Nil);
  DataSource.DataSet := FQuery;
end;

function TZQry.DataSource: TDataSource;
begin
   Result := fDataSource;
end;


{ TZCon }

constructor TZCon.create(Configuracao: TPathBanco);
begin
Try
  Fcon := TZConnection.Create(nil);
  With Fcon,Configuracao do
       begin
          Hostname := IP;
          DataBase := Banco;
          Port     := StrToInt(Porta);
          User     := Usuario;
          Password := Senha;
          Protocol := TipoBanco;
          Open;
       end;
Except
   Raise Exception.Create('Houve um erro ao inserir as configurações no arquivo "PathBanco.txt" para o componente ZConnection.' + #13 + 'Corrija as configurações e tente novamente!');
end;

end;

destructor TZCon.destroy;
begin
   FreeAndNil(FCon);
end;

function TZCon.CriarQuery: TBaseQuery;
Var
  Qry : TZQry;
begin
  Qry := TZQry.create;
  Qry.FQuery.Connection := FCon;
  Result := Qry
end;


procedure TZCon.open;
begin
Fcon.Connected:= true;
FConectado := true;
end;

procedure TZCon.close;
begin
Fcon.Connected:= false;
FConectado := False;
end;

end.

