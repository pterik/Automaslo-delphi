program Parser_Automaslo;

uses
  Vcl.Forms,
  UnitMain in 'UnitMain.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
