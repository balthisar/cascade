unit UPage13;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UTiGroupBoxSet, StdCtrls, RXSpin, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
  UCSS2Document;

type
  TwPage13 = class(TTabPageForm)
    Panel13: TPanel;
    Group78: TiGroupBox;
    Select111: TRxSpeedButton;
    Light78: TLightCheck;
    Radio112: TRadioButton;
    Radio113: TRadioButton;
    Textual16: TEdit;
    Check24: TCheckBox;
    Check25: TCheckBox;
    Group79: TiGroupBox;
    Select112: TRxSpeedButton;
    Radio115: TRadioButton;
    Light79: TLightCheck;
    Radio114: TRadioButton;
    Spinner47: TRxSpinEdit;
    Group80: TiGroupBox;
    Select113: TRxSpeedButton;
    Select114: TRxSpeedButton;
    Light80: TLightCheck;
    Radio116: TRadioButton;
    Spinner48: TRxSpinEdit;
    Radio117: TRadioButton;
    Group81: TiGroupBox;
    Select115: TRxSpeedButton;
    Light81: TLightCheck;
    Group77: TiGroupBox;
    Select110: TRxSpeedButton;
    Select108: TRxSpeedButton;
    Select109: TRxSpeedButton;
    Light77: TLightCheck;
    Radio109: TRadioButton;
    Radio111: TRadioButton;
    Spinner46: TRxSpinEdit;
    Radio110: TRadioButton;
    Check23: TCheckBox;
    Group76: TiGroupBox;
    Select107: TRxSpeedButton;
    Radio108: TRadioButton;
    Light76: TLightCheck;
    Radio107: TRadioButton;
    Spinner45: TRxSpinEdit;
    Group75: TiGroupBox;
    Select106: TRxSpeedButton;
    Label14: TLabel;
    Label15: TLabel;
    Light75: TLightCheck;
    Radio104: TRadioButton;
    Radio106: TRadioButton;
    Spinner43: TRxSpinEdit;
    Spinner44: TRxSpinEdit;
    Radio105: TRadioButton;
    CGroup81: TiCheckBox;
    CGroup80: TiCheckBox;
    CGroup79: TiCheckBox;
    CGroup78: TiCheckBox;
    CGroup75: TiCheckBox;
    CGroup76: TiCheckBox;
    CGroup77: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage13: TwPage13;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage13.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage13.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup75.Checked then Begin
      Spinner43.Enabled := Radio104.Checked;
      Spinner44.Enabled := Radio105.Checked;
      Select106.Enabled := Radio106.Checked;
   End;

   If CGroup76.Checked then Begin
      Spinner45.Enabled := Radio107.Checked;
      Select107.Enabled := Radio107.Checked;
   End;

   If CGroup77.Checked then Begin
      Spinner46.Enabled := Radio109.Checked;
      Select108.Enabled := Radio109.Checked;
      Select109.Enabled := Radio110.Checked;
      Check23.Enabled := Radio110.Checked;
      Select110.Enabled := Radio111.Checked;
   End;

   If CGroup78.Checked then Begin
      Textual16.Enabled := Radio112.Checked;
      Check24.Enabled := Radio112.Checked;
      Check25.Enabled := Radio112.Checked;
      Select111.Enabled := Radio113.Checked;
   End;

   If CGroup79.Checked then Begin
      Spinner47.Enabled := Radio114.Checked;
      Select112.Enabled := Radio114.Checked;
   End;

   If CGroup80.Checked then Begin
      Spinner48.Enabled := Radio116.Checked;
      Select113.Enabled := Radio116.Checked;
      Select114.Enabled := Radio117.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end; {TwPage13.Enablements}


{------------------------------------------------------------------------
  TwPage13.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage13.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 75 to 81 do CGroups[i] := aCGroup[i];
      For i := 75 to 81 do Lights[i] := aLight[i];
      For i := 104 to 117 do Radios[i] := aRadio[i];
      For i := 43 to 48 do Spinners[i] := aSpinner[i];
      For i := 106 to 115 do Selects[i] := aSelect[i];
      For i := 23 to 25 do Checks[i] := aCheck[i];
      For i := 16 to 16 do Textuals[i] := aTextual[i];
      //For i := 7 to 7 do Colorfuls[i] := aColorful(i);
   End; {with}
End; {TwPage13.SavePageData}


{------------------------------------------------------------------------
  TwPage13.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage13.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 75 to 81 do aCGroup[i] := CGroups[i];
      For i := 75 to 81 do aLight[i] := Lights[i];
      For i := 104 to 117 do aRadio[i] := Radios[i];
      For i := 43 to 48 do aSpinner[i] := Spinners[i];
      For i := 106 to 115 do aSelect[i] := Selects[i];
      For i := 23 to 25 do aCheck[i] := Checks[i];
      For i := 16 to 16 do aTextual[i] := Textuals[i];
      //For i := 7 to 7 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage13.RecallPageData}

end.
