//////////////////////////////////////////////////////////
//	Desenvolvedor: Humberto Sales de Oliveira       //
//	Email: 	humbertoliveira@hotmail.com		//
//		humbertosales@midassistemas.com.br	//
//		humberto_s_o@yahoo.com.br		//
//	Objetivo:                                       //  
//		1)Conectar software atraves da internet //
//		2)Conectar software atraves da Intranet //
//                                                      //
//	licensa: free                                   //
//                                                      //
//	*Auterações, modificações serão bem vindos      //
//	Créditos:                                       //      
//                                                      //   
//////////////////////////////////////////////////////////

unit conecta;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, Controls, ComCtrls, db;


type
  TipoCon = (tcZConnection,tcSqlConnector,tcCGI,tcSOCKET);

  TPathBanco = Record
      Conexao  : String;
      Ip       : String;
      porta    : String;
      Banco    : String;
      Usuario  : String;
      Senha    : String;
      TipoBanco: String;
      Pacotes  : String;
  end;

  TBaseQuery = Class
     Public
        Procedure Open; Virtual;Abstract;
        procedure close; Virtual;Abstract;
        procedure ExecSql; Virtual;Abstract;
        Function DataSet : TDataSet; Virtual;Abstract;
        Function Sql : TStrings; Virtual;Abstract;
        Function Fields : TFields; Virtual;Abstract;
        Function Params : TParams; Virtual;Abstract;
        Function Parambyname(Const AparamName: String) : TParam; Virtual;Abstract;
        Function IsEmpty : Boolean; Virtual;Abstract;
        procedure CriarDataSource; Virtual;Abstract;
        Function DataSource : TDataSource; Virtual;Abstract;
  end;


  { TBaseConector }

  TBaseConector = Class
    private
       FConectado : Boolean;
    Public
        Constructor create; Virtual;Abstract;
        Destructor destroy; Virtual;Abstract;
        Function CriarQuery : TBaseQuery; Virtual;Abstract;
        Procedure Open; Virtual;Abstract;
        Procedure Close; Virtual;Abstract;
    Published
        Property conectado : boolean read Fconectado default false;
  end;

  { TConecta }

  TConecta = Class
   Private
      Con : TBaseConector;
   Public
      Constructor create;
      Destructor Destroy; Override;
      procedure Open;
      procedure close;
      Function CriarQuery : TBaseQuery;
      function criarDataSource : TDataSource;
      procedure destroiQuery(qry : TBaseQuery);
   Published

  end;



implementation
    uses scon,zcon,ccon,skcon;

{ TConecta }

constructor TConecta.create;
var
  Lista : TStrings;
  Path : TPathBanco;
begin
  If FileExists(Application.Location + 'PathBanco.txt') = False then
       begin
            If Messagedlg('Erro ao Abrir', 'O arquivo "PathBanco.txt" não foi encontrado junto ao aplicativo' + #13 + 'Deseja cria-lo?', MtConfirmation, [Mbyes,Mbno],0) = Mryes then
                  begin
                       try
                       Lista := TStringList.Create;
                       Lista.add('CONEXAO= selecione aqui uma das opções: TcZConnection,tcSqlConnector,tcCGi');
                       Lista.add('IP= Digite aqui o ip do servidor do banco de dados');
                       Lista.add('PORTA= Digite a porta usada pelo banco de dados');
                       Lista.add('BANCO= Nome ou caminho do banco de dados. Para opção tcCGI, informe o caminho do servidor');
                       Lista.add('USUARIO= Digite o usuário do banco de dados');
                       Lista.add('SENHA= Digite a senha do banco de dados');
                       Lista.add('TIPOBANCO= Tipo de banco de dados usado na conexão');
                       Lista.add('PACOTES= Usados somentes para tipo tcCGi para limitação de registros');
                       Lista.SaveToFile('PathBanco.txt');
                       finally
                         Lista.free;
                       end;
                  end
                   Else
                       Raise Exception.Create('Não ha como continuar sem o arquivo de configuração');
       end
       Else Begin
         Try
            Lista := TStringList.Create;
            Lista.LoadFromFile('PathBanco.txt');
            With Path do
              begin
                  CONEXAO   := Lista.Values['CONEXAO'];
                  IP        := Lista.Values['IP'];
                  PORTA     := Lista.Values['PORTA'];
                  BANCO     := Lista.Values['BANCO'];
                  USUARIO   := Lista.Values['USUARIO'];
                  SENHA     := Lista.Values['SENHA'];
                  TIPOBANCO := Lista.Values['TIPOBANCO'];
                  PACOTES   := Lista.Values['PACOTES'];
              end;

            Case uppercase(Lista.Values['CONEXAO']) of
                'TCZCONNECTION'  : Con := TZcon.create(path);
                'TCSQLCONNECTOR' : Con := TSqlCon.create(Path);
                'TCCGI'          : Con := TCGI.create(path);
                'TCSOCKET'       : Con := TSKSocket.create(path);
            end;

         finally
            Lista.free;
         end;
       end;

end;

destructor TConecta.Destroy;
var
  i : Word;
begin
if Con <> Nil then
  Con.Close;
  FreeAndNil(Con);
  inherited Destroy;
end;

procedure TConecta.Open;
begin
   Con.Open;
end;

procedure TConecta.close;
begin
   Con.Close;
end;

function TConecta.CriarQuery: TBaseQuery;
begin
  Result := Con.CriarQuery;
end;

function TConecta.criarDataSource: TDataSource;
begin
  Result := TDataSource.Create(Nil);
end;

procedure TConecta.destroiQuery(qry : TBaseQuery);
begin
 if Qry <> Nil then
   FreeAndNil(Qry);
end;




end.

