unit UPage14;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UTiGroupBoxSet, StdCtrls, RXSpin, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
  UCSS2Document;

type
  TwPage14 = class(TTabPageForm)
    Panel14: TPanel;
    Group84: TiGroupBox;
    Select118: TRxSpeedButton;
    Label16: TLabel;
    Light84: TLightCheck;
    Radio122: TRadioButton;
    Spinner49: TRxSpinEdit;
    Radio123: TRadioButton;
    Group83: TiGroupBox;
    Select117: TRxSpeedButton;
    Light83: TLightCheck;
    Radio120: TRadioButton;
    Radio121: TRadioButton;
    Textual18: TEdit;
    Group82: TiGroupBox;
    Select116: TRxSpeedButton;
    Light82: TLightCheck;
    Radio118: TRadioButton;
    Radio119: TRadioButton;
    Textual17: TEdit;
    Group86: TiGroupBox;
    Select120: TRxSpeedButton;
    Light86: TLightCheck;
    Check26: TCheckBox;
    Check27: TCheckBox;
    Radio126: TRadioButton;
    Radio127: TRadioButton;
    Textual19: TEdit;
    Group85: TiGroupBox;
    Select119: TRxSpeedButton;
    Label17: TLabel;
    Light85: TLightCheck;
    Radio124: TRadioButton;
    Spinner50: TRxSpinEdit;
    Radio125: TRadioButton;
    Group89: TiGroupBox;
    Light89: TLightCheck;
    Radio132: TRadioButton;
    Spinner53: TRxSpinEdit;
    Radio133: TRadioButton;
    Group88: TiGroupBox;
    Light88: TLightCheck;
    Radio130: TRadioButton;
    Spinner52: TRxSpinEdit;
    Radio131: TRadioButton;
    Group87: TiGroupBox;
    Light87: TLightCheck;
    Radio128: TRadioButton;
    Spinner51: TRxSpinEdit;
    Radio129: TRadioButton;
    Group91: TiGroupBox;
    Select122: TRxSpeedButton;
    Light91: TLightCheck;
    Group90: TiGroupBox;
    Select121: TRxSpeedButton;
    Light90: TLightCheck;
    CGroup84: TiCheckBox;
    CGroup83: TiCheckBox;
    CGroup82: TiCheckBox;
    CGroup86: TiCheckBox;
    CGroup85: TiCheckBox;
    CGroup89: TiCheckBox;
    CGroup88: TiCheckBox;
    CGroup87: TiCheckBox;
    CGroup91: TiCheckBox;
    CGroup90: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage14: TwPage14;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage14.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage14.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup82.Checked then Begin
      Textual17.Enabled := Radio118.Checked;
      Select116.Enabled := Radio119.Checked;
   End; {if}

   If CGroup83.Checked then Begin
      Textual18.Enabled := Radio120.Checked;
      Select117.Enabled := Radio121.Checked;
   End; {if}

   If CGroup84.Checked then Begin
      Spinner49.Enabled := Radio122.Checked;
      Select118.Enabled := Radio123.Checked;
   End;

   If CGroup85.Checked then Begin
      Spinner50.Enabled := Radio124.Checked;
      Select119.Enabled := Radio125.Checked;
   End;

   If CGroup86.Checked then Begin
      Check26.Enabled := Radio126.Checked;
      Check27.Enabled := Radio126.Checked;
      Textual19.Enabled := Radio126.Checked and Check26.Checked;
      Select120.Enabled := Radio126.Checked and Check27.Checked;
   End;

   If CGroup87.Checked then Begin
      Spinner51.Enabled := Radio128.Checked;
   End;

   If CGroup88.Checked then Begin
      Spinner52.Enabled := Radio130.Checked;
   End;

   If CGroup89.Checked then Begin
      Spinner53.Enabled := Radio132.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end; {TwPage14.Enablements}


{------------------------------------------------------------------------
  TwPage14.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage14.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 82 to 91 do CGroups[i] := aCGroup[i];
      For i := 82 to 91 do Lights[i] := aLight[i];
      For i := 118 to 133 do Radios[i] := aRadio[i];
      For i := 49 to 53 do Spinners[i] := aSpinner[i];
      For i := 116 to 122 do Selects[i] := aSelect[i];
      For i := 26 to 27 do Checks[i] := aCheck[i];
      For i := 17 to 19 do Textuals[i] := aTextual[i];
      //For i := 7 to 7 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage14.SavePageData}


{------------------------------------------------------------------------
  TwPage14.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage14.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 82 to 91 do aCGroup[i] := CGroups[i];
      For i := 82 to 91 do aLight[i] := Lights[i];
      For i := 118 to 133 do aRadio[i] := Radios[i];
      For i := 49 to 53 do aSpinner[i] := Spinners[i];
      For i := 116 to 122 do aSelect[i] := Selects[i];
      For i := 26 to 27 do aCheck[i] := Checks[i];
      For i := 17 to 19 do aTextual[i] := Textuals[i];
      //For i := 7 to 7 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage14.RecallPageData}

end.
