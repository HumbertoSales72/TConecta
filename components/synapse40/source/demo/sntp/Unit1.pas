unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  blcksock, sntpsend;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
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

procedure TForm1.Button1Click(Sender: TObject);
var
  sntp:TSntpSend;
begin
  sntp:=TSntpSend.Create;
  try
    sntp.TargetHost:=Edit1.Text;
    if sntp.GetSNTP
      then label2.Caption:=Datetimetostr(sntp.NTPTime)+' UTC'
      else label2.Caption:='Not contacted!';
  finally
    sntp.Free;
  end;
end;

end.

