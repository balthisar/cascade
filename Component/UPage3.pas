unit UPage3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, UTiGroupBoxSet, RXSpin, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
  UCSS2Document;

type
  TwPage3 = class(TTabPageForm)
    Panel3: TPanel;
    Group21: TiGroupBox;
    Bevel1: TBevel;
    Select28: TRxSpeedButton;
    Select30: TRxSpeedButton;
    Select29: TRxSpeedButton;
    Select31: TRxSpeedButton;
    Select32: TRxSpeedButton;
    Label1: TRxLabel;
    Label2: TRxLabel;
    Label3: TRxLabel;
    Label4: TRxLabel;
    Light21: TLightCheck;
    Radio27: TRadioButton;
    Radio28: TRadioButton;
    Spinner8: TRxSpinEdit;
    Spinner10: TRxSpinEdit;
    Spinner11: TRxSpinEdit;
    Spinner9: TRxSpinEdit;
    Group20: TiGroupBox;
    Select27: TRxSpeedButton;
    Light20: TLightCheck;
    Group19: TiGroupBox;
    Select25: TRxSpeedButton;
    Select26: TRxSpeedButton;
    Light19: TLightCheck;
    Radio25: TRadioButton;
    Radio26: TRadioButton;
    Spinner7: TRxSpinEdit;
    Group18: TiGroupBox;
    Select24: TRxSpeedButton;
    Light18: TLightCheck;
    Group17: TiGroupBox;
    Select22: TRxSpeedButton;
    Select23: TRxSpeedButton;
    Light17: TLightCheck;
    Radio23: TRadioButton;
    Radio24: TRadioButton;
    Spinner6: TRxSpinEdit;
    CGroup21: TiCheckBox;
    CGroup20: TiCheckBox;
    CGroup19: TiCheckBox;
    CGroup18: TiCheckBox;
    CGroup17: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage3: TwPage3;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage3.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage3.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup17.Checked then Begin
      Spinner6.Enabled := Radio23.Checked;
      Select22.Enabled := Radio23.Checked;
      Select23.Enabled := Radio24.Checked;
   End;

   If CGroup19.Checked then Begin
      Spinner7.Enabled := Radio25.Checked;
      Select25.Enabled := Radio25.Checked;
      Select26.Enabled := Radio26.Checked;
   End;

   If CGroup21.Checked then Begin
      Spinner8.Enabled := Radio27.Checked AND (Select28.Caption <> 'auto');
      Spinner9.Enabled := Radio27.Checked AND (Select29.Caption <> 'auto');
      Spinner10.Enabled := Radio27.Checked AND (Select30.Caption <> 'auto');
      Spinner11.Enabled := Radio27.Checked AND (Select31.Caption <> 'auto');
      Select28.Enabled := Radio27.Checked;
      Select29.Enabled := Radio27.Checked;
      Select30.Enabled := Radio27.Checked;
      Select31.Enabled := Radio27.Checked;
      Select32.Enabled := Radio28.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end;


{------------------------------------------------------------------------
  TwPage3.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage3.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 17 to 21 do CGroups[i] := aCGroup[i];
      For i := 17 to 21 do Lights[i] := aLight[i];
      For i := 23 to 28 do Radios[i] := aRadio[i];
      For i := 6 to 11 do Spinners[i] := aSpinner[i];
      For i := 22 to 32 do Selects[i] := aSelect[i];
      //For i := 0 to 0 do Checks[i] := aCheck[i];
      //For i := 0 to 0 do Textuals[i] := aTextual[i];
      //For i := 0 to 0 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage3.SavePageData}


{------------------------------------------------------------------------
  TwPage3.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage3.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 17 to 21 do aCGroup[i] := CGroups[i];
      For i := 17 to 21 do aLight[i] := Lights[i];
      For i := 23 to 28 do aRadio[i] := Radios[i];
      For i := 6 to 11 do aSpinner[i] := Spinners[i];
      For i := 22 to 32 do aSelect[i] := Selects[i];
      //For i := 0 to 0 do aCheck[i] := Checks[i];
      //For i := 0 to 0 do aTextual[i] := Textuals[i];
      //For i := 0 to 0 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage3.RecallPageData}

end.
