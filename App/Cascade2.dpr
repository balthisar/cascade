program Cascade2;

uses
  Forms,
  UPersonalize in 'UPersonalize.pas' {wPersonalize},
  URunOnlyOnce in 'URunOnlyOnce.pas',
  UMainModule in 'UMainModule.pas' {MainModule: TDataModule};

{$R *.RES}
{$R Document.Res}

begin
   If (not IsPrevInst) or (ParamStr(1) = 'miaok') then Begin
      Application.Initialize;
      Application.Title := 'Cascade2';
      Application.CreateForm(TMainModule, MainModule);
  Application.Run;
   End;
end.
