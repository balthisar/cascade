unit UPage4;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, UTiGroupBoxSet, RXSpin, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
  UCSS2Document;

type
  TwPage4 = class(TTabPageForm)
    Panel4: TPanel;
    GroupBox1: TGroupBox;
    Group22: TiGroupBox;
    Select33: TRxSpeedButton;
    Select34: TRxSpeedButton;
    Radio30: TRadioButton;
    Light22: TLightCheck;
    Radio29: TRadioButton;
    Spinner12: TRxSpinEdit;
    CGroup22: TiCheckBox;
    Group24: TiGroupBox;
    Select37: TRxSpeedButton;
    Select38: TRxSpeedButton;
    Radio34: TRadioButton;
    Light24: TLightCheck;
    Radio33: TRadioButton;
    Spinner14: TRxSpinEdit;
    CGroup24: TiCheckBox;
    Group25: TiGroupBox;
    Select39: TRxSpeedButton;
    Select40: TRxSpeedButton;
    Radio36: TRadioButton;
    Light25: TLightCheck;
    Radio35: TRadioButton;
    Spinner15: TRxSpinEdit;
    Group23: TiGroupBox;
    Select35: TRxSpeedButton;
    Select36: TRxSpeedButton;
    Radio32: TRadioButton;
    Light23: TLightCheck;
    Radio31: TRadioButton;
    Spinner13: TRxSpinEdit;
    CGroup25: TiCheckBox;
    CGroup23: TiCheckBox;
    GroupBox2: TGroupBox;
    Group26: TiGroupBox;
    Select41: TRxSpeedButton;
    Radio38: TRadioButton;
    Light26: TLightCheck;
    Radio37: TRadioButton;
    Spinner16: TRxSpinEdit;
    Group28: TiGroupBox;
    Select43: TRxSpeedButton;
    Radio42: TRadioButton;
    Light28: TLightCheck;
    Radio41: TRadioButton;
    Spinner18: TRxSpinEdit;
    Group27: TiGroupBox;
    Select42: TRxSpeedButton;
    Radio40: TRadioButton;
    Light27: TLightCheck;
    Radio39: TRadioButton;
    Spinner17: TRxSpinEdit;
    Group29: TiGroupBox;
    Select44: TRxSpeedButton;
    Radio44: TRadioButton;
    Light29: TLightCheck;
    Radio43: TRadioButton;
    Spinner19: TRxSpinEdit;
    CGroup28: TiCheckBox;
    CGroup29: TiCheckBox;
    CGroup27: TiCheckBox;
    CGroup26: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage4: TwPage4;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage4.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage4.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup22.Checked then Begin
      Spinner12.Enabled := Radio29.Checked;
      Select33.Enabled := Radio29.Checked;
      Select34.Enabled := Radio30.Checked;
   End;

   If CGroup23.Checked then Begin
      Spinner13.Enabled := Radio31.Checked;
      Select35.Enabled := Radio31.Checked;
      Select36.Enabled := Radio32.Checked;
   End;

   If CGroup24.Checked then Begin
      Spinner14.Enabled := Radio33.Checked;
      Select37.Enabled := Radio33.Checked;
      Select38.Enabled := Radio34.Checked;
   End;

   If CGroup25.Checked then Begin
      Spinner15.Enabled := Radio35.Checked;
      Select39.Enabled := Radio35.Checked;
      Select40.Enabled := Radio36.Checked;
   End;

   If CGroup26.Checked then Begin
      Spinner16.Enabled := Radio37.Checked;
      Select41.Enabled := Radio37.Checked;
   End;

   If CGroup27.Checked then Begin
      Spinner17.Enabled := Radio39.Checked;
      Select42.Enabled := Radio39.Checked;
   End;

   If CGroup28.Checked then Begin
      Spinner18.Enabled := Radio41.Checked;
      Select43.Enabled := Radio41.Checked;
   End;

   If CGroup29.Checked then Begin
      Spinner19.Enabled := Radio43.Checked;
      Select44.Enabled := Radio43.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end;


{------------------------------------------------------------------------
  TwPage4.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage4.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 22 to 29 do CGroups[i] := aCGroup[i];
      For i := 22 to 29 do Lights[i] := aLight[i];
      For i := 29 to 44 do Radios[i] := aRadio[i];
      For i := 12 to 19 do Spinners[i] := aSpinner[i];
      For i := 33 to 44 do Selects[i] := aSelect[i];
      //For i := 0 to 0 do Checks[i] := aCheck[i];
      //For i := 0 to 0 do Textuals[i] := aTextual[i];
      //For i := 0 to 0 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage4.SavePageData}


{------------------------------------------------------------------------
  TwPage4.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage4.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 22 to 29 do aCGroup[i] := CGroups[i];
      For i := 22 to 29 do aLight[i] := Lights[i];
      For i := 29 to 44 do aRadio[i] := Radios[i];
      For i := 12 to 19 do aSpinner[i] := Spinners[i];
      For i := 33 to 44 do aSelect[i] := Selects[i];
      //For i := 0 to 0 do aCheck[i] := Checks[i];
      //For i := 0 to 0 do aTextual[i] := Textuals[i];
      //For i := 0 to 0 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage4.RecallPageData}
end.
