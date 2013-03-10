unit UPage12;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RXSpin, UTiGroupBoxSet, StdCtrls, Lightchk, Mask, ToolEdit, RXCtrls,
  ExtCtrls, UMultiPage, UCSS2Document;

type
  TwPage12 = class(TTabPageForm)
    Panel12: TPanel;
    Group73: TiGroupBox;
    Select102: TRxSpeedButton;
    Textual15: TComboEdit;
    Light73: TLightCheck;
    Check18: TCheckBox;
    Check19: TCheckBox;
    Group74: TiGroupBox;
    Select103: TRxSpeedButton;
    Select105: TRxSpeedButton;
    Select104: TRxSpeedButton;
    Radio102: TRadioButton;
    Radio103: TRadioButton;
    Colorful7: TComboEdit;
    Check21: TiCheckBox;
    Light74: TLightCheck;
    Check20: TiCheckBox;
    Spinner42: TRxSpinEdit;
    Check22: TCheckBox;
    CGroup73: TiCheckBox;
    CGroup74: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
    procedure doEditor(Sender: TObject); override;
    procedure doColors(Sender: TObject); override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage12: TwPage12;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage12.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage12.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup73.Checked then Begin
      Textual15.Enabled := Check18.Checked;
      Select102.Enabled := Check19.Checked;
   End;

   If CGroup74.Checked then Begin
      Spinner42.Enabled := Radio102.Checked;
      Select103.Enabled := Radio102.Checked;
      Select104.Enabled := Radio103.Checked;
      Select105.Enabled := Check20.Checked;
      Colorful7.Enabled := Check21.Checked and not Check22.Checked;
      Check22.Enabled := Check21.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end; {TwPage12.Enablements}


{------------------------------------------------------------------------
  TwPage12.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage12.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 73 to 74 do CGroups[i] := aCGroup[i];
      For i := 73 to 74 do Lights[i] := aLight[i];
      For i := 102 to 103 do Radios[i] := aRadio[i];
      For i := 42 to 42 do Spinners[i] := aSpinner[i];
      For i := 102 to 105 do Selects[i] := aSelect[i];
      For i := 18 to 22 do Checks[i] := aCheck[i];
      For i := 15 to 15 do Textuals[i] := aTextual[i];
      For i := 7 to 7 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage12.SavePageData}


{------------------------------------------------------------------------
  TwPage12.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage12.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 73 to 74 do aCGroup[i] := CGroups[i];
      For i := 73 to 74 do aLight[i] := Lights[i];
      For i := 102 to 103 do aRadio[i] := Radios[i];
      For i := 42 to 42 do aSpinner[i] := Spinners[i];
      For i := 102 to 105 do aSelect[i] := Selects[i];
      For i := 18 to 22 do aCheck[i] := Checks[i];
      For i := 15 to 15 do aTextual[i] := Textuals[i];
      For i := 7 to 7 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage12.RecallPageData}


procedure TwPage12.doEditor(Sender: TObject);
begin
   inherited doEditor(Sender);
end;

procedure TwPage12.doColors(Sender: TObject);
begin
   inherited doColors(Sender);
end;

end.
