unit UPage5;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UTiGroupBoxSet, RXSpin, Lightchk, StdCtrls, Mask, ToolEdit, RXCtrls,
  ExtCtrls, UMultiPage, UCSS2Document;

type
  TwPage5 = class(TTabPageForm)
    Panel5: TPanel;
    GroupBox3: TGroupBox;
    Group30: TiGroupBox;
    Select45: TRxSpeedButton;
    Select47: TRxSpeedButton;
    Select46: TRxSpeedButton;
    Radio45: TRadioButton;
    Radio46: TRadioButton;
    Colorful1: TComboEdit;
    Check9: TCheckBox;
    Light30: TLightCheck;
    Check8: TCheckBox;
    Spinner20: TRxSpinEdit;
    Group32: TiGroupBox;
    Select51: TRxSpeedButton;
    Select53: TRxSpeedButton;
    Select52: TRxSpeedButton;
    Radio49: TRadioButton;
    Radio50: TRadioButton;
    Colorful3: TComboEdit;
    Check13: TCheckBox;
    Light32: TLightCheck;
    Check12: TCheckBox;
    Spinner22: TRxSpinEdit;
    Group31: TiGroupBox;
    Select48: TRxSpeedButton;
    Select50: TRxSpeedButton;
    Select49: TRxSpeedButton;
    Radio47: TRadioButton;
    Radio48: TRadioButton;
    Colorful2: TComboEdit;
    Check11: TCheckBox;
    Light31: TLightCheck;
    Check10: TCheckBox;
    Spinner21: TRxSpinEdit;
    Group33: TiGroupBox;
    Select54: TRxSpeedButton;
    Select56: TRxSpeedButton;
    Select55: TRxSpeedButton;
    Radio51: TRadioButton;
    Radio52: TRadioButton;
    Colorful4: TComboEdit;
    Check15: TCheckBox;
    Light33: TLightCheck;
    Check14: TCheckBox;
    Spinner23: TRxSpinEdit;
    CGroup31: TiCheckBox;
    CGroup33: TiCheckBox;
    CGroup32: TiCheckBox;
    CGroup30: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
    procedure doColors(Sender: TObject); override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage5: TwPage5;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage5.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage5.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup30.Checked then Begin
      Spinner20.Enabled := Radio45.Checked;
      Select45.Enabled := Radio45.Checked;
      Select46.Enabled := Radio46.Checked;
      Select47.Enabled := Check8.Checked;
      Colorful1.Enabled := Check9.Checked;
   End;

   If CGroup31.Checked then Begin
      Spinner21.Enabled := Radio47.Checked;
      Select48.Enabled := Radio47.Checked;
      Select49.Enabled := Radio48.Checked;
      Select50.Enabled := Check10.Checked;
      Colorful2.Enabled := Check11.Checked;
   End;

   If CGroup32.Checked then Begin
      Spinner22.Enabled := Radio49.Checked;
      Select51.Enabled := Radio49.Checked;
      Select52.Enabled := Radio50.Checked;
      Select53.Enabled := Check12.Checked;
      Colorful3.Enabled := Check13.Checked;
   End;

   If CGroup33.Checked then Begin
      Spinner23.Enabled := Radio51.Checked;
      Select54.Enabled := Radio51.Checked;
      Select55.Enabled := Radio52.Checked;
      Select56.Enabled := Check14.Checked;
      Colorful4.Enabled := Check15.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end;


{------------------------------------------------------------------------
  TwPage5.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage5.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 30 to 33 do CGroups[i] := aCGroup[i];
      For i := 30 to 33 do Lights[i] := aLight[i];
      For i := 45 to 52 do Radios[i] := aRadio[i];
      For i := 20 to 23 do Spinners[i] := aSpinner[i];
      For i := 45 to 56 do Selects[i] := aSelect[i];
      For i := 8 to 15 do Checks[i] := aCheck[i];
      //For i := 0 to 0 do Textuals[i] := aTextual[i];
      For i := 1 to 4 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage5.SavePageData}


{------------------------------------------------------------------------
  TwPage5.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage5.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 30 to 33 do aCGroup[i] := CGroups[i];
      For i := 30 to 33 do aLight[i] := Lights[i];
      For i := 45 to 52 do aRadio[i] := Radios[i];
      For i := 20 to 23 do aSpinner[i] := Spinners[i];
      For i := 45 to 56 do aSelect[i] := Selects[i];
      For i := 8 to 15 do aCheck[i] := Checks[i];
      //For i := 0 to 0 do aTextual[i] := Textuals[i];
      For i := 1 to 4 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage5.RecallPageData}

procedure TwPage5.doColors(Sender: TObject);
begin
   inherited doColors(Sender);
end;

end.
