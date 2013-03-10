unit UPersonalize;

{============================================================================
  This unit serves to register the application in the system registry.
 ============================================================================}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, UrlLabel, RXCtrls;

type
  TwPersonalize = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    RxLabel1: TRxLabel;
    RxLabel2: TRxLabel;
    UrlLabel1: TUrlLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    bOkay: TBitBtn;
    procedure bOkayClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    RegistryKey : String;
  end;


implementation

uses Registry;

{$R *.DFM}

{=========================================================================
  TwPersonalize.bOkayClick
   Set the ModalResult if the okay button is pressed - this closes form.
 =========================================================================}
procedure TwPersonalize.bOkayClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end; {TwPersonalize.bOkayClick}


{=========================================================================
  TwPersonalize.Edit1Change
   If text is present in both fields, enable the okay button
 =========================================================================}
procedure TwPersonalize.Edit1Change(Sender: TObject);
begin
   if (Edit1.Text <> '') and (Edit2.Text <> '') then
      bOkay.Enabled := True
   Else
      bOkay.Enabled := False;
end; {TwPersonalize.Edit1Change}


{=========================================================================
  TwPersonalize.FormClose
   o If the form is not okay to close (the button is gray), then don't.
   o If the form is okay to close, add the user info to the registry.
 =========================================================================}
procedure TwPersonalize.FormClose(Sender: TObject; var Action: TCloseAction);
var myReg : TRegistry;
begin
   if not bOkay.Enabled then Action := caNone;
   {write the new info}
   myReg := TRegistry.Create;
   myReg.RootKey := HKEY_CURRENT_USER;
   myReg.OpenKey(RegistryKey, True);
   myReg.WriteString('Name', Edit1.Text);
   myReg.WriteString('Company', Edit2.Text);
   myReg.WriteBool('Personalized', True);
   myReg.CloseKey;
   myReg.Free;
end; {TwPersonalize.FormClose}

end.
