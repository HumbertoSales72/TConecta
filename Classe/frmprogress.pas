unit frmprogress;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,forms,BGRAFlashProgressBar,Controls;

type

{ TfrmProgresso }

TfrmProgresso = Class
  private
    Frm : TForm;
    Progress : TBGRAFlashProgressBar;
    FMostrarProcesso: Boolean;
    FTitulo: String;
    FValorFinal: integer;
    procedure SetTitulo(AValue: String);
  public
    constructor create;
    constructor create(const TituloForm: string; VlrFinal: Integer);
    destructor Destroy; override;
    procedure incrementar(Posicao : Integer);
    procedure inicializar(vlrFinal : Integer);
    procedure inicializar(const TituloForm: String; vlrFinal: Integer);
  published
    Property ValorFinal : integer read FValorFinal write FValorFinal default 0;
    Property MostrarProcesso : Boolean read FMostrarProcesso write FMostrarProcesso default false;
    Property Titulo : String read FTitulo write SetTitulo;
end;

implementation

procedure TfrmProgresso.SetTitulo(AValue: String);
begin
  if FTitulo=AValue then Exit;
  FTitulo:=AValue;
  Frm.Caption := FTitulo;
end;

constructor TfrmProgresso.create;
begin
  frm := TForm.Create(Nil);
  Progress := TBGRAFlashProgressBar.Create(frm);
  Progress.Parent := Frm;
  Progress.Align:= alClient;
  Progress.Value:= 0;

  With Frm do
     begin
       FormStyle:= fsStayOnTop;
       Position:= poDesktopCenter;
       Width:= 320;
       Height:= 52;
       BorderIcons:= BorderIcons - [biMaximize,biSystemMenu,biMinimize];
     end;

end;

constructor TfrmProgresso.create(const TituloForm: string; VlrFinal: Integer);
begin
  create;
  Titulo := TituloForm;
  if VlrFinal = 0 then
    Raise Exception.Create('VlrFinal não pode ser 0');
  fValorFinal := VlrFinal;
  frm.Show;
end;

destructor TfrmProgresso.Destroy;
begin
FreeAndNil(Progress);
FreeAndNil(Frm);
Inherited Destroy;
end;

procedure TfrmProgresso.incrementar(Posicao: Integer);
begin
 Progress.Value := Posicao * 100 div ValorFinal;
 Progress.refresh;
 if FMostrarProcesso then
   begin
       Frm.Caption :=  format(' %s %s',[FTitulo , ' - ' + Inttostr(Posicao)]);
       frm.update;
   end;
 if Posicao = ValorFinal then
   frm.Close;
end;

procedure TfrmProgresso.inicializar(vlrFinal: Integer);
begin
  FValorFinal:= vlrFinal;
  Progress.Value := 0;
  Frm.Show;
end;

procedure TfrmProgresso.inicializar(const TituloForm: String; vlrFinal: Integer
  );
begin
Inicializar(vlrFinal);
Titulo := TituloForm;
end;



end.

