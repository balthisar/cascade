unit UAboutMe;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UrlLabel, ExtCtrls, RXCtrls, StdCtrls;

type
  TwAboutMe = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    Label10: TLabel;
    RxLabel1: TRxLabel;
    RxLabel2: TRxLabel;
    Panel3: TPanel;
    LabelStatus: TLabel;
    Label2: TLabel;
    Panel4: TPanel;
    Label4: TLabel;
    Bevel1: TBevel;
    LabelOwner: TLabel;
    LabelCompany: TLabel;
    UrlLabel1: TUrlLabel;
    UrlLabel2: TUrlLabel;
    Timer1: TTimer;
    Label8: TLabel;
    procedure Panel2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wAboutMe: TwAboutMe;

implementation

uses Registry, UEditorMain;

{$R *.DFM}

procedure TwAboutMe.Panel2Click(Sender: TObject);
begin
   ModalResult := mrOk;
end;

procedure TwAboutMe.FormShow(Sender: TObject);
var myReg : TRegistry;
begin
   // read in the personalization data
   myReg := TRegistry.Create;
   myReg.RootKey := HKEY_CURRENT_USER;
   if myReg.KeyExists(wEditorMain.REGISTRY_KEY) then
      Begin {see if the registered flag is there}
         myReg.OpenKey(wEditorMain.REGISTRY_KEY, False);
         if myReg.ValueExists('Personalized') then    {it exists...}
            if myReg.ReadBool('Personalized') then  {is it true? }
               Begin {no need to re-personalize}
                  LabelOwner.Caption := myReg.ReadString('Name');
                  LabelCompany.Caption := myReg.ReadString('Company');
            End Else Begin
                  LabelOwner.Caption := 'This product has not been personalized.';
                  LabelCompany.Caption := 'Please contact the application vendor.';
            End; {if}
      myReg.CloseKey;
      myReg.Free;
   End; {if}

end;

procedure TwAboutMe.Timer1Timer(Sender: TObject);
begin
   ModalResult := mrOk;
end;

end.
