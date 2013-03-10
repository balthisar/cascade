unit UPage8;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, UTiGroupBoxSet, RXSpin, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
  UCSS2Document;

type
  TwPage8 = class(TTabPageForm)
    Panel8: TPanel;
    GroupBox5: TGroupBox;
    Group51: TiGroupBox;
    Select79: TRxSpeedButton;
    Select80: TRxSpeedButton;
    Radio73: TRadioButton;
    Light51: TLightCheck;
    Radio72: TRadioButton;
    Spinner31: TRxSpinEdit;
    Group52: TiGroupBox;
    Select81: TRxSpeedButton;
    Radio75: TRadioButton;
    Light52: TLightCheck;
    Radio74: TRadioButton;
    Spinner32: TRxSpinEdit;
    Group53: TiGroupBox;
    Select82: TRxSpeedButton;
    Radio77: TRadioButton;
    Light53: TLightCheck;
    Radio76: TRadioButton;
    Spinner33: TRxSpinEdit;
    CGroup51: TiCheckBox;
    CGroup52: TiCheckBox;
    CGroup53: TiCheckBox;
    GroupBox6: TGroupBox;
    Group54: TiGroupBox;
    Select83: TRxSpeedButton;
    Select84: TRxSpeedButton;
    Radio79: TRadioButton;
    Light54: TLightCheck;
    Radio78: TRadioButton;
    Spinner34: TRxSpinEdit;
    Group55: TiGroupBox;
    Select85: TRxSpeedButton;
    Radio81: TRadioButton;
    Light55: TLightCheck;
    Radio80: TRadioButton;
    Spinner35: TRxSpinEdit;
    Group56: TiGroupBox;
    Select86: TRxSpeedButton;
    Radio83: TRadioButton;
    Light56: TLightCheck;
    Radio82: TRadioButton;
    Spinner36: TRxSpinEdit;
    CGroup54: TiCheckBox;
    CGroup55: TiCheckBox;
    CGroup56: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage8: TwPage8;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage8.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage8.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup51.Checked then Begin
      Spinner31.Enabled := Radio72.Checked;
      Select79.Enabled := Radio72.Checked;
      Select80.Enabled := Radio73.Checked;
   End;

   If CGroup52.Checked then Begin
      Spinner32.Enabled := Radio74.Checked;
      Select81.Enabled := Radio74.Checked;
   End;

   If CGroup53.Checked then Begin
      Spinner33.Enabled := Radio76.Checked;
      Select82.Enabled := Radio76.Checked;
   End;

   If CGroup54.Checked then Begin
      Spinner34.Enabled := Radio78.Checked;
      Select83.Enabled := Radio78.Checked;
      Select84.Enabled := Radio79.Checked;
   End;

   If CGroup55.Checked then Begin
      Spinner35.Enabled := Radio80.Checked;
      Select85.Enabled := Radio80.Checked;
   End;

   If CGroup56.Checked then Begin
      Spinner36.Enabled := Radio82.Checked;
      Select86.Enabled := Radio82.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end;


{------------------------------------------------------------------------
  TwPage8.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage8.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 51 to 56 do CGroups[i] := aCGroup[i];
      For i := 51 to 56 do Lights[i] := aLight[i];
      For i := 72 to 83 do Radios[i] := aRadio[i];
      For i := 31 to 36 do Spinners[i] := aSpinner[i];
      For i := 79 to 86 do Selects[i] := aSelect[i];
      //For i := 16 to 16 do Checks[i] := aCheck[i];
      //For i := 6 to 6 do Textuals[i] := aTextual[i];
      //For i := 1 to 4 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage8.SavePageData}


{------------------------------------------------------------------------
  TwPage8.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage8.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 51 to 56 do aCGroup[i] := CGroups[i];
      For i := 51 to 56 do aLight[i] := Lights[i];
      For i := 72 to 83 do aRadio[i] := Radios[i];
      For i := 31 to 36 do aSpinner[i] := Spinners[i];
      For i := 79 to 86 do aSelect[i] := Selects[i];
      //For i := 16 to 16 do aCheck[i] := Checks[i];
      //For i := 6 to 6 do aTextual[i] := Textuals[i];
      //For i := 1 to 4 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage8.RecallPageData}

end.
