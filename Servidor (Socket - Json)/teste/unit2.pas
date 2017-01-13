unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,fpjson, jsonparser;

Type

  TTipoConexao = (tcPostgresql,tcFirebird,tcMysql);

  { TFormataSql }

  TFormataSql = Class

  private
      FJson: TJSONObject;
      FSQL: TStringList;
      FTipoConexao : TTipoConexao;
      FLimit: integer;
      FOffSet: integer;
      FCursor: Integer;
      FLimitador : String;    //para limit
      FDeslocamento : String; //para offset
      function GetLimit: integer;
      function GetOffSet: integer;
      procedure SetJson(AValue: TJSONObject);
      procedure SetLimit(AValue: integer);
      procedure SetOffSet(AValue: integer);
      procedure SetSQL(AValue: TStringList);
    public
      constructor create(Tipo : TTipoConexao);
      destructor Destroy; override;
      function retorno : TJSONObject;
      procedure run;
    published
      property Json : TJSONObject read FJson write SetJson;
      property Limit  : integer read GetLimit write SetLimit;
      property OffSet : integer read GetOffSet write SetOffSet;
      property Cursor : Integer read FCursor write FCursor;
      property Limitador : String read Flimitador write Flimitador;
      property Deslocamento : String read FDeslocamento write FDeslocamento;
      property SQL : TStringList read FSQL write SetSQL;

  end;

implementation


{ TFormataSql }




function TFormataSql.GetLimit: integer;
begin
  FLimit := FJson.Items[2].AsInteger;
end;

function TFormataSql.GetOffSet: integer;
begin
  FOffSet:= FJson.Items[1].AsInteger;
end;

procedure TFormataSql.SetJson(AValue: TJSONObject);
begin
  if FJson=AValue then Exit;
  FJson:=AValue;
end;


procedure TFormataSql.SetLimit(AValue: integer);
begin
  if FLimit=AValue then Exit;
  FLimit:=AValue;
end;

procedure TFormataSql.SetOffSet(AValue: integer);
begin
  if FOffSet=AValue then Exit;
  FOffSet:=AValue;
end;



procedure TFormataSql.SetSQL(AValue: TStringList);
begin
  if FSQL=AValue then Exit;
  FSQL:=AValue;
end;

constructor TFormataSql.create(Tipo: TTipoConexao);
begin
  FSql := TStringList.create; //observar se vai precisar criar pq talvez nao precise
  FTipoConexao:=Tipo;
  Case FTipoConexao of

     tcPostgresql :
                begin
                  FLimitador := 'LIMIT';
                  FDeslocamento := 'OFFSET';
                  FCursor:= 0;
                end;
     tcFirebird :
                begin
                  FLimitador := 'TO';
                  FDeslocamento := 'ROWS';
                  FCursor:= 1;
                end;
     tcMysql :
                begin
                  FLimitador := 'LIMIT';
                  FDeslocamento := 'OFFSET';
                  FCursor:= 1;
                end;
  end;


end;

destructor TFormataSql.Destroy;
begin
  inherited Destroy;
end;

function TFormataSql.retorno: TJSONObject;
begin

end;

procedure TFormataSql.run;
begin
  FSQL.Text := FJson.Items[0].AsString;
  //FLimit    := FJson.Items[1].AsInteger;
  ///FOffSet   := FJson.Items[2].AsInteger;


end;

end.

