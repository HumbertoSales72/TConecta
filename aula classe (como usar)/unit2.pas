unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DbCtrls, ExtCtrls, DBGrids, CONECTA, db;

type

  { TForm2 }

  TForm2 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    btGravar: TButton;
    btNovo: TButton;
    btEditar: TButton;
    btApagar: TButton;
    btCancelar: TButton;
    btFechar: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    codigo: TEdit;
    Edit1: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    modelo: TEdit;
    marca: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RadioGroup1: TRadioGroup;
    procedure btGravarClick(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure btEditarClick(Sender: TObject);
    procedure btApagarClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;
  MyQueryVisualizar : TBaseQuery; //look
  MyQueryAlterar : TBaseQuery;    //edit


implementation
    USES UNIT1;
{$R *.lfm}

{ TForm2 }

//////////////////////////////////////exemplo de como trabalhar//////////////////////////////////////////

procedure TForm2.FormCreate(Sender: TObject);
begin
  MyQueryVisualizar := MyCon.CriarQuery;
  MyQueryAlterar  := MyCon.CriarQuery;
  DataSource1.DataSet := MyQueryVisualizar.Dataset;
  dbgrid1.DataSource := DataSource1;
end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  MyQueryVisualizar.close;
  MyQueryAlterar.close;
  FreeAndNil(MyQueryVisualizar);
  FreeAndNil(MyQueryAlterar);
  CloseAction:= CaFree;
end;

procedure TForm2.btNovoClick(Sender: TObject);
begin
  With MyQueryAlterar do
     begin
        close;
        Sql.text := 'Insert into veiculo (codigo,modelo,marca) values (:codigo,:modelo,:marca)';
     end;
  Codigo.setfocus;
  form1.LeQuery(Form2,MyQueryVisualizar,EsLimpar);
  form1.LeQuery(Form2,MyQueryVisualizar,EsBotoesAlterar);
end;

procedure TForm2.btGravarClick(Sender: TObject);
begin
With MyQueryAlterar do
    begin
       parambyname('codigo').Asstring := codigo.text;
       parambyname('modelo').Asstring := modelo.text;
       parambyname('marca').Asstring := marca.text;
       ExecSql;
    end;
form1.LeQuery(Form2,MyQueryVisualizar,EsGravando);
form1.LeQuery(Form2,MyQueryVisualizar,EsBotoesNormais);
end;

procedure TForm2.btEditarClick(Sender: TObject);
begin
With MyQueryAlterar do
   begin
      close;
      Sql.text := 'Update veiculo set modelo=:modelo,marca=:marca where codigo = :codigo';
   end;
codigo.ReadOnly:=true;
modelo.setfocus;
form1.LeQuery(Form2,MyQueryVisualizar,esEditando);
form1.LeQuery(Form2,MyQueryVisualizar,EsBotoesAlterar);

end;

procedure TForm2.btApagarClick(Sender: TObject);
begin
  if messagedlg('remover registro' , 'Remover registro atual?',MtConfirmation, [mbyes,mbno],0) = mryes then
     begin
       With MyQueryAlterar do
          begin
             close;
             Sql.text := 'delete from veiculo where codigo = :codigo';
             parambyname('codigo').asstring := codigo.text;
             Execsql;
          end;
       With MyQueryVisualizar do
          begin
             close;
             open;
          end;
       Form1.LeQuery(form2,MyQueryVisualizar,esVisualizando);
     end;
end;

procedure TForm2.btCancelarClick(Sender: TObject);
begin
Form1.LeQuery(form2,MyQueryVisualizar,esVisualizando);
form1.LeQuery(Form2,MyQueryVisualizar,EsBotoesNormais);
end;

procedure TForm2.btFecharClick(Sender: TObject);
begin
 Close;
end;

procedure TForm2.DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
begin
    Form1.LeQuery(Form2,MyQueryVisualizar,esVisualizando);
end;

procedure TForm2.Edit1KeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
      begin
        With MyQueryVisualizar do
               begin
                  close;
                  Case Radiogroup1.itemindex of
                  0 : begin
                        sql.text := 'select codigo,Modelo,Marca from veiculo where codigo =:codigo order by codigo';
                        parambyname('codigo').asstring := edit1.text;
                      end;

                  1 : begin
                       sql.text := 'select codigo,Modelo,Marca from veiculo where upper(Marca) like upper(:Marca) order by marca';
                       parambyname('marca').asstring := edit1.text + '%';
                      end;
                  2 : begin
                       sql.text := 'select codigo,Modelo,Marca from veiculo where upper(modelo) like upper(:Modelo) order by modelo';
                       parambyname('modelo').asstring := edit1.text + '%';
                      end;
                  end;
                  open;
               end;
      end;

end;



procedure TForm2.FormShow(Sender: TObject);
begin
  With MyQueryVisualizar do
   begin
      close;
      Sql.text := 'Select * from veiculo';
      open;
      DBNavigator1.DataSource := DataSource1;
   end;
    Form1.LeQuery(Form2,MyQueryVisualizar,esVisualizando);
    form1.LeQuery(Form2,MyQueryVisualizar,EsBotoesNormais);
end;

procedure TForm2.RadioGroup1Click(Sender: TObject);
begin
  Edit1.setfocus;
  edit1.selectall;
end;

end.

