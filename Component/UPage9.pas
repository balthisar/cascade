unit UPage9;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, UTiGroupBoxSet, RXSpin, Mask, ToolEdit, Lightchk, RXCtrls,
  ExtCtrls, UMultiPage, UCSS2Document, UTiComboBox;

type
  TwPage9 = class(TTabPageForm)
    Panel9: TPanel;
    Group61: TiGroupBox;
    Select92: TRxSpeedButton;
    Label8: TRxLabel;
    Label18: TRxLabel;
    Light61: TLightCheck;
    Radio92: TRadioButton;
    Radio93: TRadioButton;
    Textual10: TiComboBox;
    Textual11: TiComboBox;
    Textual13: TiComboBox;
    Textual12: TiComboBox;
    Group60: TiGroupBox;
    Select91: TRxSpeedButton;
    Light60: TLightCheck;
    Radio90: TRadioButton;
    Radio91: TRadioButton;
    Textual9: TComboEdit;
    Group58: TiGroupBox;
    Select88: TRxSpeedButton;
    Select89: TRxSpeedButton;
    Light58: TLightCheck;
    Radio86: TRadioButton;
    Radio87: TRadioButton;
    Spinner37: TRxSpinEdit;
    Group57: TiGroupBox;
    Select87: TRxSpeedButton;
    Light57: TLightCheck;
    Radio84: TRadioButton;
    Radio85: TRadioButton;
    Textual7: TComboEdit;
    Group59: TiGroupBox;
    Select90: TRxSpeedButton;
    Light59: TLightCheck;
    Radio88: TRadioButton;
    Radio89: TRadioButton;
    Textual8: TComboEdit;
    CGroup61: TiCheckBox;
    CGroup60: TiCheckBox;
    CGroup58: TiCheckBox;
    CGroup59: TiCheckBox;
    CGroup57: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
    procedure doEditor(Sender: TObject); override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage9: TwPage9;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage9.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage9.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup57.Checked then Begin
      Textual7.Enabled := Radio84.Checked;
      Select87.Enabled := Radio85.Checked;
   End;

   If CGroup58.Checked then Begin
      Spinner37.Enabled := Radio86.Checked;
      Select88.Enabled := Radio86.Checked;
      Select89.Enabled := Radio87.Checked;
   End;

   If CGroup59.Checked then Begin
      Textual8.Enabled := Radio88.Checked;
      Select90.Enabled := Radio89.Checked;
   End;

   If CGroup60.Checked then Begin
      Textual9.Enabled := Radio90.Checked;
      Select91.Enabled := Radio91.Checked;
   End;

   If CGroup61.Checked then Begin
      Textual10.Enabled := Radio92.Checked;
      Textual11.Enabled := Radio92.Checked;
      Textual12.Enabled := Radio92.Checked;
      Textual13.Enabled := Radio92.Checked;
      Select92.Enabled := Radio93.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end;


{------------------------------------------------------------------------
  TwPage9.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage9.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 57 to 61 do CGroups[i] := aCGroup[i];
      For i := 57 to 61 do Lights[i] := aLight[i];
      For i := 84 to 93 do Radios[i] := aRadio[i];
      For i := 37 to 37 do Spinners[i] := aSpinner[i];
      For i := 87 to 92 do Selects[i] := aSelect[i];
      //For i := 16 to 16 do Checks[i] := aCheck[i];
      For i := 7 to 13 do Textuals[i] := aTextual[i];
      //For i := 1 to 4 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage9.SavePageData}


{------------------------------------------------------------------------
  TwPage9.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage9.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 57 to 61 do aCGroup[i] := CGroups[i];
      For i := 57 to 61 do aLight[i] := Lights[i];
      For i := 84 to 93 do aRadio[i] := Radios[i];
      For i := 37 to 37 do aSpinner[i] := Spinners[i];
      For i := 87 to 92 do aSelect[i] := Selects[i];
      //For i := 16 to 16 do aCheck[i] := Checks[i];
      For i := 7 to 13 do aTextual[i] := Textuals[i];
      //For i := 1 to 4 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage9.RecallPageData}

procedure TwPage9.doEditor(Sender: TObject);
begin
   inherited doEditor(Sender)
end;

end.
