unit UPage1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UTiGroupBoxSet, StdCtrls, RXSpin, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
  UCSS2Document, UTiComboBox;

type
  TwPage1 = class(TTabPageForm)
    Panel1: TPanel;
    Group8: TiGroupBox;
    Select11: TRxSpeedButton;
    Light8: TLightCheck;
    Group7: TiGroupBox;
    Select10: TRxSpeedButton;
    Light7: TLightCheck;
    Group6: TiGroupBox;
    Select9: TRxSpeedButton;
    Light6: TLightCheck;
    Group5: TiGroupBox;
    Select8: TRxSpeedButton;
    Light5: TLightCheck;
    Group4: TiGroupBox;
    Select6: TRxSpeedButton;
    Select7: TRxSpeedButton;
    Light4: TLightCheck;
    Radio9: TRadioButton;
    Radio10: TRadioButton;
    Group1: TiGroupBox;
    Textual3: TiComboBox;
    Light1: TLightCheck;
    Textual1: TComboBox;
    Textual2: TComboBox;
    Check1: TCheckBox;
    Check2: TCheckBox;
    Check3: TCheckBox;
    Radio1: TRadioButton;
    Radio2: TRadioButton;
    Group2: TiGroupBox;
    Select3: TRxSpeedButton;
    Select1: TRxSpeedButton;
    Select2: TRxSpeedButton;
    Radio3: TRadioButton;
    Radio4: TRadioButton;
    Light2: TLightCheck;
    Radio5: TRadioButton;
    Radio6: TRadioButton;
    Spinner1: TRxSpinEdit;
    Group3: TiGroupBox;
    Select5: TRxSpeedButton;
    Select4: TRxSpeedButton;
    Radio7: TRadioButton;
    Light3: TLightCheck;
    Radio8: TRadioButton;
    Spinner2: TRxSpinEdit;
    CGroup8: TiCheckBox;
    CGroup7: TiCheckBox;
    CGroup6: TiCheckBox;
    CGroup5: TiCheckBox;
    CGroup4: TiCheckBox;
    CGroup3: TiCheckBox;
    CGroup2: TiCheckBox;
    CGroup1: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure doFontChoice(Sender : TObject);
    procedure SavePageData; override;
    Procedure RecallPageData; override;
    procedure FontDropDown(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage1: TwPage1;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage1.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage1.Enablements(Sender: TObject);
Begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup1.Checked then Begin // font-family
      Check1.Enabled := Radio1.Checked;
      Check2.Enabled := Radio1.Checked;
      Check3.Enabled := Radio1.Checked;
      Textual1.Enabled := Check1.Checked and Radio1.Checked;
      Textual2.Enabled := Check2.Checked and Radio1.Checked;
      Textual3.Enabled := Check3.Checked and Radio1.Checked;
   End; {if}

   If CGroup2.Checked then Begin // font-size
      Select1.Enabled := Radio3.Checked;
      Select2.Enabled := Radio4.Checked;
      Spinner1.Enabled := Radio5.Checked;
      Select3.Enabled := Radio5.Checked;
   End; {if}

   If CGroup3.Checked then Begin // font-size-adjust
      Select4.Enabled := Radio7.Checked;
      Spinner2.Enabled := Radio8.Checked;
      Select5.Enabled := Radio8.Checked;
   End; {if}

   If CGroup4.Checked then Begin // font-weight
      Select6.Enabled := Radio9.Checked;
      Select7.Enabled := Radio10.Checked;
   End; {if}

   If wEditorMain <> nil then Begin // save the change, and update preview
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}

   If Sender is TComboBox then doFontChoice(Sender);

end; {TwPage1.Enablements}

{-----------------------------------------------------------------------------
  TwStyleEdit.doFontChoice
  Font Names should be in own font
 -----------------------------------------------------------------------------}
procedure TwPage1.doFontChoice(Sender : TObject);
begin
   If wEditorMain.thePrefs.PREF_FONTS then Begin
      If Screen.Fonts.IndexOf(Textual1.Text) <> -1 then
         Textual1.Font.Name := Textual1.Text
      Else
         Textual1.Font.Name := 'MS Sans Serif';
      If Screen.Fonts.IndexOf(Textual2.Text) <> -1 then
         Textual2.Font.Name := Textual2.Text
      Else
         Textual2.Font.Name := 'MS Sans Serif';
   End Else Begin
      Textual1.Font.Name := 'MS Sans Serif';
      Textual2.Font.Name := 'MS Sans Serif';
   End;
end; {TwPage1.doFontChoice}

{------------------------------------------------------------------------
  TwPage1.SavePageData
   Saves the current page data into the passed-in record
 ------------------------------------------------------------------------}
procedure TwPage1.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 1 to 8 do CGroups[i] := aCGroup[i];
      For i := 1 to 8 do Lights[i] := aLight[i];
      For i := 1 to 10 do Radios[i] := aRadio[i];
      For i := 1 to 2 do Spinners[i] := (aSpinner[i]);
      For i := 1 to 11 do Selects[i] := aSelect[i];
      For i := 1 to 3 do Checks[i] := aCheck[i];
      For i := 1 to 3 do Textuals[i] := aTextual[i];
   End; {with}
End; {TwPage1.SavePageData}


{----------------------------------------------------------------------------
  TwPage1.RecallPageData
   Gets the current page data from the passed-in record, and puts on-screen.
 ----------------------------------------------------------------------------}
procedure TwPage1.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 1 to 8 do aCGroup[i] := CGroups[i];
      For i := 1 to 8 do aLight[i] := Lights[i];
      For i := 1 to 10 do aRadio[i] := Radios[i];
      For i := 1 to 2 do aSpinner[i] := Spinners[i];
      For i := 1 to 11 do aSelect[i] := Selects[i];
      For i := 1 to 3 do aCheck[i] := Checks[i];
      For i := 1 to 3 do aTextual[i] := Textuals[i];
   End; {with}
   ToggleEvents(True);
   doFontChoice(nil);
End; {TwPage1.RecallPageData}


{----------------------------------------------------------------------------
  TwPage1.FontDropDown
   Gets the current page data from the passed-in record, and puts on-screen.
 ----------------------------------------------------------------------------}
procedure TwPage1.FontDropDown(Sender: TObject);
begin
   TComboBox(Sender).Items.Assign(Screen.Fonts);
   TComboBox(Sender).Items.Add(TComboBox(Sender).Text);
   TComboBox(Sender).Font.Name := 'MS Sans Serif';
end; {TwPage1.FontDropDown}

end.
