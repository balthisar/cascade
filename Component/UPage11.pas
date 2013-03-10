unit UPage11;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UTiGroupBoxSet, StdCtrls, RXSpin, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
   UCSS2Document;

type
  TwPage11 = class(TTabPageForm)
    Panel11: TPanel;
    Group72: TiGroupBox;
    Label12: TRxLabel;
    Select101: TRxSpeedButton;
    Label13: TRxLabel;
    Radio100: TRadioButton;
    Light72: TLightCheck;
    Check17: TCheckBox;
    Label11: TCheckBox;
    Radio101: TRadioButton;
    Spinner40: TRxSpinEdit;
    Spinner41: TRxSpinEdit;
    Group71: TiGroupBox;
    Label10: TLabel;
    Radio99: TRadioButton;
    Light71: TLightCheck;
    Radio98: TRadioButton;
    Spinner39: TRxSpinEdit;
    Group70: TiGroupBox;
    Label9: TLabel;
    Radio97: TRadioButton;
    Light70: TLightCheck;
    Radio96: TRadioButton;
    Spinner38: TRxSpinEdit;
    Group69: TiGroupBox;
    Select100: TRxSpeedButton;
    Light69: TLightCheck;
    Group65: TiGroupBox;
    Select96: TRxSpeedButton;
    Light65: TLightCheck;
    Group66: TiGroupBox;
    Select97: TRxSpeedButton;
    Light66: TLightCheck;
    Group67: TiGroupBox;
    Select98: TRxSpeedButton;
    Light67: TLightCheck;
    Group68: TiGroupBox;
    Select99: TRxSpeedButton;
    Light68: TLightCheck;
    CGroup72: TiCheckBox;
    CGroup71: TiCheckBox;
    CGroup70: TiCheckBox;
    CGroup69: TiCheckBox;
    CGroup68: TiCheckBox;
    CGroup67: TiCheckBox;
    CGroup66: TiCheckBox;
    CGroup65: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage11: TwPage11;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage11.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage11.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup70.Checked then Begin
      Spinner38.Enabled := Radio96.Checked;
   End;

   If CGroup71.Checked then Begin
      Spinner39.Enabled := Radio98.Checked;
   End;

   If CGroup72.Checked then Begin
      Spinner40.Enabled := Radio100.Checked;
      Select101.Enabled := Radio100.Checked;
      Spinner41.Enabled := Radio100.Checked and Check17.Checked;
      Check17.Enabled := Radio100.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end; {TwPage11.Enablements}


{------------------------------------------------------------------------
  TwPage11.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage11.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 65 to 72 do CGroups[i] := aCGroup[i];
      For i := 65 to 72 do Lights[i] := aLight[i];
      For i := 96 to 101 do Radios[i] := aRadio[i];
      For i := 38 to 41 do Spinners[i] := aSpinner[i];
      For i := 96 to 101 do Selects[i] := aSelect[i];
      For i := 17 to 17 do Checks[i] := aCheck[i];
      //For i := 14 to 14 do Textuals[i] := aTextual(i).Text;
      //For i := 1 to 4 do Colorfuls[i] := aColorful(i).Text;
   End; {with}
End; {TwPage11.SavePageData}


{------------------------------------------------------------------------
  TwPage11.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage11.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 65 to 72 do aCGroup[i] := CGroups[i];
      For i := 65 to 72 do aLight[i] := Lights[i];
      For i := 96 to 101 do aRadio[i] := Radios[i];
      For i := 38 to 41 do aSpinner[i] := Spinners[i];
      For i := 96 to 101 do aSelect[i] := Selects[i];
      For i := 17 to 17 do aCheck[i] := Checks[i];
      //For i := 14 to 14 do aTextual[i] := Textuals[i];
      //For i := 1 to 4 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage11.RecallPageData}

end.
