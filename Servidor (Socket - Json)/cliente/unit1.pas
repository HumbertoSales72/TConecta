unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, fphttpclient, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,blcksock;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button2: TButton;
    Edit1: TEdit;
    Host: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    procedure Button2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button2Click(Sender: TObject);
var
  cli : TTCPBlockSocket;
  s  : string;
begin
  Memo1.clear;
  cli := TTCPBlockSocket.Create;
  Cli.Connect(  host.text  ,'1300');
  if Cli.LastError <> 0 then
      MEMO1.LINES.ADD('HOUVE ERRO')
  ELSE begin
        Memo1.lines.add('cliente (inicio): ' + formatdatetime('hh:mm:ss:zzz',time));
        Cli.SendString('query=' + Edit1.text + CRLF);
        s := '';
        s := Cli.RecvString(7000);
        memo1.lines.add(s);
        Memo1.lines.add('cliente (final): ' + formatdatetime('hh:mm:ss:zzz',time));
  end;
  cli.CloseSocket;
  FreeAndNil(cli);
end;

end.

