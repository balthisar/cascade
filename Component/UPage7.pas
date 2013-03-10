unit UPage7;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, UTiGroupBoxSet, RXSpin, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
  UCSS2Document;

type
  TwPage7 = class(TTabPageForm)
    Panel7: TPanel;
    GroupBox4: TiGroupBox;
    Group43: TiGroupBox;
    Select70: TRxSpeedButton;
    Select71: TRxSpeedButton;
    Radio69: TRadioButton;
    Light43: TLightCheck;
    Radio68: TRadioButton;
    Spinner29: TRxSpinEdit;
    Group42: TiGroupBox;
    Select68: TRxSpeedButton;
    Select69: TRxSpeedButton;
    Radio67: TRadioButton;
    Light42: TLightCheck;
    Radio66: TRadioButton;
    Spinner28: TRxSpinEdit;
    Group41: TiGroupBox;
    Select66: TRxSpeedButton;
    Select67: TRxSpeedButton;
    Radio65: TRadioButton;
    Light41: TLightCheck;
    Radio64: TRadioButton;
    Spinner27: TRxSpinEdit;
    Group40: TiGroupBox;
    Select64: TRxSpeedButton;
    Select65: TRxSpeedButton;
    Radio63: TRadioButton;
    Light40: TLightCheck;
    Radio62: TRadioButton;
    Spinner26: TRxSpinEdit;
    CGroup40: TiCheckBox;
    CGroup41: TiCheckBox;
    CGroup43: TiCheckBox;
    CGroup42: TiCheckBox;
    Group44: TiGroupBox;
    Select72: TRxSpeedButton;
    Light44: TLightCheck;
    Group45: TiGroupBox;
    Select73: TRxSpeedButton;
    Light45: TLightCheck;
    Group46: TiGroupBox;
    Select74: TRxSpeedButton;
    Light46: TLightCheck;
    Group49: TiGroupBox;
    Select77: TRxSpeedButton;
    Light49: TLightCheck;
    Group48: TiGroupBox;
    Select76: TRxSpeedButton;
    Light48: TLightCheck;
    Group47: TiGroupBox;
    Select75: TRxSpeedButton;
    Light47: TLightCheck;
    Group50: TiGroupBox;
    Select78: TRxSpeedButton;
    Radio71: TRadioButton;
    Light50: TLightCheck;
    Spinner30: TRxSpinEdit;
    Radio70: TRadioButton;
    CGroup50: TiCheckBox;
    CGroup49: TiCheckBox;
    CGroup48: TiCheckBox;
    CGroup47: TiCheckBox;
    CGroup46: TiCheckBox;
    CGroup45: TiCheckBox;
    CGroup44: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage7: TwPage7;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage7.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage7.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup40.Checked then Begin
      Spinner26.Enabled := Radio62.Checked;
      Select64.Enabled := Radio62.Checked;
      Select65.Enabled := Radio63.Checked;
   End;

   If CGroup41.Checked then Begin
      Spinner27.Enabled := Radio64.Checked;
      Select66.Enabled := Radio64.Checked;
      Select67.Enabled := Radio65.Checked;
   End;

   If CGroup42.Checked then Begin
      Spinner28.Enabled := Radio66.Checked;
      Select68.Enabled := Radio66.Checked;
      Select69.Enabled := Radio67.Checked;
   End;

   If CGroup42.Checked then Begin
      Spinner29.Enabled := Radio68.Checked;
      Select70.Enabled := Radio68.Checked;
      Select71.Enabled := Radio69.Checked;
   End;

   If CGroup50.Checked then Begin
      Spinner30.Enabled := Radio70.Checked;
      Select78.Enabled := Radio71.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end;


{------------------------------------------------------------------------
  TwPage7.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage7.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 40 to 50 do CGroups[i] := aCGroup[i];
      For i := 40 to 50 do Lights[i] := aLight[i];
      For i := 62 to 71 do Radios[i] := aRadio[i];
      For i := 26 to 30 do Spinners[i] := aSpinner[i];
      For i := 64 to 78 do Selects[i] := aSelect[i];
      //For i := 16 to 16 do Checks[i] := aCheck[i];
      //For i := 6 to 6 do Textuals[i] := aTextual[i];
      //For i := 1 to 4 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage7.SavePageData}


{------------------------------------------------------------------------
  TwPage7.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage7.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 40 to 50 do aCGroup[i] := CGroups[i];
      For i := 40 to 50 do aLight[i] := Lights[i];
      For i := 62 to 71 do aRadio[i] := Radios[i];
      For i := 26 to 30 do aSpinner[i] := Spinners[i];
      For i := 64 to 78 do aSelect[i] := Selects[i];
      //For i := 16 to 16 do aCheck[i] := Checks[i];
      //For i := 6 to 6 do aTextual[i] := Textuals[i];
      //For i := 1 to 4 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage7.RecallPageData}

end.
