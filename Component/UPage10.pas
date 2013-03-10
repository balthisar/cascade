unit UPage10;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, UTiGroupBoxSet, Lightchk, RXCtrls, ExtCtrls, UMultiPage,
  UCSS2Document;

type
  TwPage10 = class(TTabPageForm)
    Panel10: TPanel;
    Group62: TiGroupBox;
    Select93: TRxSpeedButton;
    Light62: TLightCheck;
    Group63: TiGroupBox;
    Select94: TRxSpeedButton;
    Light63: TLightCheck;
    Radio94: TRadioButton;
    Radio95: TRadioButton;
    Textual14: TEdit;
    Group64: TiGroupBox;
    Select95: TRxSpeedButton;
    Light64: TLightCheck;
    CGroup64: TiCheckBox;
    CGroup63: TiCheckBox;
    CGroup62: TiCheckBox;
    procedure Enablements(Sender: TObject); override;
    procedure SavePageData; override;
    Procedure RecallPageData; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPage10: TwPage10;

implementation

uses UEditorMain;

{$R *.DFM}

{------------------------------------------------------------------------
  TwPage10.Enablements
   Respond to what should and shouldn't be enabled
 ------------------------------------------------------------------------}
procedure TwPage10.Enablements(Sender: TObject);
begin
   If Sender <> nil then wEditorMain.MarkDirty(True);
   If CGroup63.Checked then Begin
      Textual14.Enabled := Radio94.Checked;
      Select94.Enabled := Radio95.Checked;
   End;

   If wEditorMain <> nil then Begin
      SavePageData;
      PreviewUpdate(Sender);
   End; {if}
end; {TwPage10.Enablements}


{------------------------------------------------------------------------
  TwPage10.SavePageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage10.SavePageData;
Var i : integer;
Begin
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 62 to 64 do CGroups[i] := aCGroup[i];
      For i := 62 to 64 do Lights[i] := aLight[i];
      For i := 94 to 95 do Radios[i] := aRadio[i];
      //For i := 37 to 37 do Spinners[i] := aSpinner[i];
      For i := 93 to 95 do Selects[i] := aSelect[i];
      //For i := 16 to 16 do Checks[i] := aCheck[i];
      For i := 14 to 14 do Textuals[i] := aTextual[i];
      //For i := 1 to 4 do Colorfuls[i] := aColorful[i];
   End; {with}
End; {TwPage10.SavePageData}


{------------------------------------------------------------------------
  TwPage10.RecallPageData
   Saves the current page data into the passed-in document
 ------------------------------------------------------------------------}
procedure TwPage10.RecallPageData;
Var i : integer;
Begin
   ToggleEvents(False);
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do Begin
      For i := 62 to 64 do aCGroup[i] := CGroups[i];
      For i := 62 to 64 do aLight[i] := Lights[i];
      For i := 94 to 95 do aRadio[i] := Radios[i];
      //For i := 37 to 37 do aSpinner[i] := Spinners[i];
      For i := 93 to 95 do aSelect[i] := Selects[i];
      //For i := 16 to 16 do aCheck[i] := Checks[i];
      For i := 14 to 14 do aTextual[i] := Textuals[i];
      //For i := 1 to 4 do aColorful[i] := Colorfuls[i];
   End; {with}
   ToggleEvents(True);
End; {TwPage10.RecallPageData}

end.
