program Parser_Automaslo;

uses
  Vcl.Forms,
  UnitAutomaslo in 'UnitAutomaslo.pas' {FormAutoMaslo};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  //Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormAutoMaslo, FormAutoMaslo);
  Application.Run;
end.
