unit UPage6;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UTiGroupBoxSet, Mask, ToolEdit, StdCtrls, RXSpin, Lightchk, RXCtrls,
  ExtCtrls, UMultiPage, UCSS2Document;

type
  TwPage6 = class(TTabPageForm)
    Panel6: TPanel;
    Group39: TiGroupBox;
    Label6: TRxLabel;
    Label7: TRxLabel;
    Select63: TRxSpeedButton;
    Select61: TRxSpeedButton;
    Select62: TRxSpeedButton;
    Radio59: TRadioButton;
    Radio60: TRadioButton;
    Light39: TLightCheck;
    Check16: TCheckBox;
    Label5: TCheckBox;
    Radio61: TRadioButton;
    Spinner24: TRxSpinEdit;
    Spinner25: TRxSpinEdit;
    Group38: TiGroupBox;
    Select60: TRxSpeedButton;
    Light38: TLightCheck;
    Radio57: TRadioButton;
    Radio58: TRadioButton;
    Textual6: TEdit;
    Group37: TiGroupBox;
    Select59: TRxSpeedButton;
    Colorful6: TComboEdit;
    Light37: TLightCheck;
    Radio55: TRadioButton;
    Radio56: TRadioButton;
    Group34: TiGroupBox;
    Colorful5: TComboEdit;
    Light34: TLightCheck;
    Radio53: TRadioButton;
    Radio54: TRadioButton;
    Group35: TiGroupBox;
    Select57: TRxSpeedButton;
    Light35: TLightCheck;
    Group36: TiGroupBox;
    Select58: TRxSpeedButton;
    Light36: TLightCheck;
    CGroup39: TiCheckBox;
    CGroup38: TiCheckBox;
    CGroup37: TiCheckBox;
    CGroup36: TiCheckBox;
    CGroup35: TiCheckBox;
    CGroup34: TiCheckBox;
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
  wPage6: TwPage6;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage6.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage6.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup34.Checked then Begin
      Colorful5.Enabled := Radio53.Checked;
   End;

   If CGroup37.Checked then Begin
      Colorful6.Enabled := Radio55.Checked;
      Select59.Enabled := Radio56.Checked;
   End;

   If CGroup38.Checked then Begin
      Textual6.Enabled := Radio57.Checked;
      Select60.Enabled := Radio58.Checked;
   End;

   If CGroup39.Checked then Begin
      Check16.Enabled := Radio59.Checked or Radio60.Checked;
      Select61.Enabled := Radio59.Checked;
      Select62.Enabled := Radio59.Checked and Check16.Checked;
      Spinner24.Enabled := Radio60.Checked;
      Select63.Enabled := Radio60.Checked;
      Spinner25.Enabled := Radio60.Checked and Check16.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end;


{------------------------------------------------------------------------
  TwPage6.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage6.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 34 to 39 do CGroups[i] := aCGroup[i];
      For i := 34 to 39 do Lights[i] := aLight[i];
      For i := 53 to 61 do Radios[i] := aRadio[i];
      For i := 24 to 25 do Spinners[i] := aSpinner[i];
      For i := 57 to 63 do Selects[i] := aSelect[i];
      For i := 16 to 16 do Checks[i] := aCheck[i];
      For i := 6 to 6 do Textuals[i] := aTextual[i];
      For i := 5 to 6 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage6.SavePageData}



{------------------------------------------------------------------------
  TwPage6.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage6.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 34 to 39 do aCGroup[i] := CGroups[i];
      For i := 34 to 39 do aLight[i] := Lights[i];
      For i := 53 to 61 do aRadio[i] := Radios[i];
      For i := 24 to 25 do aSpinner[i] := Spinners[i];
      For i := 57 to 63 do aSelect[i] := Selects[i];
      For i := 16 to 16 do aCheck[i] := Checks[i];
      For i := 6 to 6 do aTextual[i] := Textuals[i];
      For i := 5 to 6 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage6.RecallPageData}

procedure TwPage6.doColors(Sender: TObject);
begin
   inherited doColors(Sender);
end;

end.
