unit UPage2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UTiGroupBoxSet, StdCtrls, Mask, ToolEdit, RXSpin, Lightchk, RXCtrls,
  ExtCtrls, UMultiPage, UCSS2Document;

type
  TwPage2 = class(TTabPageForm)
    Panel2: TPanel;
    Group16: TiGroupBox;
    Select21: TRxSpeedButton;
    Light16: TLightCheck;
    Group15: TiGroupBox;
    Select20: TRxSpeedButton;
    Light15: TLightCheck;
    Group14: TiGroupBox;
    Select18: TRxSpeedButton;
    Select19: TRxSpeedButton;
    Light14: TLightCheck;
    Radio21: TRadioButton;
    Radio22: TRadioButton;
    Spinner5: TRxSpinEdit;
    Group13: TiGroupBox;
    Select16: TRxSpeedButton;
    Select17: TRxSpeedButton;
    Light13: TLightCheck;
    Radio19: TRadioButton;
    Radio20: TRadioButton;
    Spinner4: TRxSpinEdit;
    Group12: TiGroupBox;
    Select15: TRxSpeedButton;
    Light12: TLightCheck;
    Radio17: TRadioButton;
    Radio18: TRadioButton;
    Textual5: TComboEdit;
    Group11: TiGroupBox;
    Select14: TRxSpeedButton;
    Light11: TLightCheck;
    Radio15: TRadioButton;
    Radio16: TRadioButton;
    Check4: TCheckBox;
    Check6: TCheckBox;
    Check5: TCheckBox;
    Check7: TCheckBox;
    Group10: TiGroupBox;
    Select13: TRxSpeedButton;
    Light10: TLightCheck;
    Radio13: TRadioButton;
    Radio14: TRadioButton;
    Textual4: TEdit;
    Group9: TiGroupBox;
    Select12: TRxSpeedButton;
    Radio12: TRadioButton;
    Light9: TLightCheck;
    Radio11: TRadioButton;
    Spinner3: TRxSpinEdit;
    CGroup16: TiCheckBox;
    CGroup15: TiCheckBox;
    CGroup14: TiCheckBox;
    CGroup13: TiCheckBox;
    CGroup12: TiCheckBox;
    CGroup11: TiCheckBox;
    CGroup10: TiCheckBox;
    CGroup9: TiCheckBox;
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
  wPage2: TwPage2;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage2.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage2.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup9.Checked then Begin
      Spinner3.Enabled := Radio11.Checked;
      Select12.Enabled := Radio11.Checked;
   End;

   If CGroup10.Checked then Begin
      Textual4.Enabled := Radio13.Checked;
      Select13.Enabled := Radio14.Checked;
   End;

   If CGroup11.Checked then Begin
      Check4.Enabled := Radio15.Checked;
      Check5.Enabled := Radio15.Checked;
      Check6.Enabled := Radio15.Checked;
      Check7.Enabled := Radio15.Checked;
      Select14.Enabled := Radio16.Checked;
   End;

   If CGroup12.Checked then Begin
      Textual5.Enabled := Radio17.Checked;
      Select15.Enabled := Radio18.Checked;
   End;

   If CGroup13.Checked then Begin
      Spinner4.Enabled := Radio19.Checked;
      Select16.Enabled := Radio19.Checked;
      Select17.Enabled := Radio20.Checked;
   End;

   If CGroup14.Checked then Begin
      Spinner5.Enabled := Radio21.Checked;
      Select18.Enabled := Radio21.Checked;
      Select19.Enabled := Radio22.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end; {TwPage2.Enablements}


{------------------------------------------------------------------------
  TwPage2.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage2.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 9 to 16 do CGroups[i] := aCGroup[i];
      For i := 9 to 16 do Lights[i] := aLight[i];
      For i := 11 to 22 do Radios[i] := aRadio[i];
      For i := 3 to 5 do Spinners[i] := aSpinner[i];
      For i := 12 to 21 do Selects[i] := aSelect[i];
      For i := 4 to 7 do Checks[i] := aCheck[i];
      For i := 4 to 5 do Textuals[i] := aTextual[i];
      //For i := 0 to 0 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage2.SavePageData}


{------------------------------------------------------------------------
  TwPage2.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage2.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 9 to 16 do aCGroup[i] := CGroups[i];
      For i := 9 to 16 do aLight[i] := Lights[i];
      For i := 11 to 22 do aRadio[i] := Radios[i];
      For i := 3 to 5 do aSpinner[i] := Spinners[i];
      For i := 12 to 21 do aSelect[i] := Selects[i];
      For i := 4 to 7 do aCheck[i] := Checks[i];
      For i := 4 to 5 do aTextual[i] := Textuals[i];
      //For i := 0 to 0 do Colorfuls[i] := aColorful(i).Text;
   End; {with}
   ToggleEvents(True);
End; {TwPage2.RecallPageData}

procedure TwPage2.doEditor(Sender: TObject);
begin
   inherited doEditor(Sender);
end;

end.
