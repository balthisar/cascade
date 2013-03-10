unit UMultiPage;

interface

uses Forms, StdCtrls, UTiGroupBoxSet, UCSS2Document, RXCtrls, RXSpin, Lightchk,
     SysUtils, Classes, Graphics, Controls, Dialogs, ExtCtrls, ToolEdit,
     UTiComboBox;

type
   TTabPageForm = Class(TForm)
      Private
         onClickList : Array[0..500] of TNotifyEvent;
         onChangeList : Array[0..500] of TNotifyEvent;
         Procedure SetaCGroup(num : Integer; const Value : Boolean); virtual;
         Function  GetaCGroup(num : Integer) : Boolean; virtual;
         Procedure SetaLight(num : Integer; const Value : Boolean); virtual;
         Function  GetaLight(num : Integer) : Boolean; virtual;
         Procedure SetaSpinner(num : Integer; const Value : Extended); virtual;
         Function  GetaSpinner(num : Integer) : Extended; virtual;
         Procedure SetaSelect(num : Integer; const Value : String); virtual;
         Function  GetaSelect(num : Integer) : String; virtual;
         Procedure SetaRadio(num : Integer; const Value : Boolean); virtual;
         Function  GetaRadio(num : Integer) : Boolean; virtual;
         Procedure SetaCheck(num : Integer; const Value : Boolean); virtual;
         Function  GetaCheck(num : Integer) : Boolean; virtual;
         Procedure SetaColorful(num : Integer; const Value : String); virtual;
         Function  GetaColorful(num : Integer) : String; virtual;
         Procedure SetaTextual(num : Integer; const Value : String); virtual;
         Function  GetaTextual(num : Integer) : String; virtual;
      Public
         Procedure Enablements(Sender : TObject); virtual; abstract;
         Procedure SavePageData; virtual; abstract;
         Procedure RecallPageData; virtual; abstract;
         procedure PreviewUpdate(Sender : TObject); virtual;
         Procedure ToggleEvents(how : Boolean); virtual;
         Procedure TurnOffPage; virtual;
         Procedure EnablePage; virtual;
         Procedure RecallDecimals; virtual;
         Procedure doEditor(Sender : TObject); virtual; // the onButtonClick for Textuals
         Procedure doColors(Sender : TObject); virtual; // the onButtonClick for Colorfuls

         Property aCGroup[num : Integer] : Boolean
                  read GetaCGroup write SetaCGroup;
         Property aLight[num : Integer] : Boolean
                  read GetaLight write SetaLight;
         Property aSpinner[num : Integer] : Extended
                  read GetaSpinner write SetaSpinner;
         Property aSelect[num : Integer] : String
                  read GetaSelect write SetaSelect;
         Property aRadio[num : Integer] : Boolean
                  read GetaRadio write SetaRadio;
         Property aCheck[num : Integer] : Boolean
                  read GetaCheck write SetaCheck;
         Property aColorful[num : Integer] : String
                  read GetaColorful write SetaColorful;
         Property aTextual[num : Integer] : String
                  read GetaTextual write SetaTextual;
   End;

   TTabPageFormClass = Class of TTabPageForm;

implementation

uses Windows, Messages, Registry, UNetColorPicker, UEditorMain, UTextEditor,
     UHTMLColors;


{------------------------------------------------------------------------
  TTabPageForm.doEditor
   Opens the text editor for longer text entry.
 ------------------------------------------------------------------------}
procedure TTabPageForm.doEditor(Sender : TObject);
var myText : String;
    i      : Integer;
begin
   with TComboEdit(Sender) do Begin
      If Name = 'Textual5' then myText := 'Text Shadow';
      If Name = 'Textual7' then myText := 'Content';
      If Name = 'Textual8' then myText := 'Counter-Reset';
      If Name = 'Textual9' then myText := 'Counter-Increment';
      If Name = 'Textual15' then myText := 'Cursor';
   End; {with}
   myText := myText + ' Property Editor';
   wTextEditor := TwTextEditor.Create(Application);
   wTextEditor.Caption := myText;
   wTextEditor.Memo1.Text := TComboEdit(Sender).Text;
   If wTextEditor.ShowModal = mrOk then Begin;
      myText := wTextEditor.Memo1.Text;
      while Pos(#13, myText) <> 0 do Begin
         i := Pos(#13, myText);
         Delete(myText, i, 2);
         Insert(#32, myText, i);
      End; {while}
      TComboEdit(Sender).Text := myText;
   End; {if}
   wTextEditor.Free;
end; {TTabPageForm.doEditor}


{------------------------------------------------------------------------
  TTabPageForm.doColors
   Opens the color picker
 ------------------------------------------------------------------------}
procedure TTabPageForm.doColors(Sender : TObject);
var myDLOG : TNetColorDLOG;
begin
   myDLOG := TNetColorDLOG.Create(Application);
   myDLOG.UseSystemColors := wEditorMain.thePrefs.ALLOW_SYS_COLORS;
   myDLOG.RegistryKey := wEditorMain.REGISTRY_KEY;

   with TComboEdit(Sender) do Begin
      // set up the initial dialogue color
      myDLOG.SystemColor := Text;
      If myDLOG.SystemColor = '' then Begin
         If (Copy(Text,1,1) = '#') or (Copy(Text,1,1) = '$') then
            myDLOG.HTMLColor := '$' + Copy(Text,2,6)
         Else
            myDLOG.HTMLName := Text;
      End; {if}

      // store the changes if a change was made
      If myDLOG.Execute then Begin

         If myDLOG.SystemColor <> '' then Begin
            Text := myDLOG.SystemColor;
            If Copy(Text, 1, 1) = '$' then
               Text := '#' + Copy(Text, 2, 6);
         End; {if}
         If myDLOG.SystemColor = '' then Begin
            if myDLOG.HTMLName = '' then
               Text := '#' + Copy(myDLOG.HTMLColor,2,6)
            Else
               Text := myDLOG.HTMLName;
         End; {if not}
         if (wEditorMain.thePrefs.SHOW_COLORS) and (myDLOG.SystemColor = '') then
            Color := myDLOG.WinColor
         else
            Color := clWhite;
      End; {if}
   End; {with}
   myDLOG.Free;
end; {TTabPageForm.doColors}


{--------------------------------------------------------------------------
  TTabPageForm.RecallDecimals
   Loads the current decimal settings onto the screen
 --------------------------------------------------------------------------}
Procedure TTabPageForm.RecallDecimals;
var i     : Integer;
    j     : String;
    myReg : TRegistry;
    myEvt : TNotifyEvent;
Begin
   if wEditorMain = nil then Exit;
   myReg := TRegistry.Create;
   myReg.RootKey := HKEY_CURRENT_USER;
   myReg.OpenKey(wEditorMain.REGISTRY_KEY + '\Decimals', False);
   for i := 0 to ComponentCount - 1 do
     If Copy(Components[i].Name, 1, 7) = 'Spinner' then Begin
        myEvt := TRxSpinEdit(Components[i]).onChange;
        TRxSpinEdit(Components[i]).onChange := nil;
        j := Copy(Components[i].Name, 8, 2);
        If myReg.ValueExists(j) then
           TRxSpinEdit(Components[i]).Decimal := 2 * Ord(not myReg.ReadBool(j));
        TRxSpinEdit(Components[i]).onChange := myEvt;
     End;
   myReg.CloseKey;
   myReg.Free;
End; {TTabPageForm.RecallDecimals}


{--------------------------------------------------------------------------
  TTabPageForm.ToggleEvents
   Disables/Enables the OnClick Events. Assumes the OnClick is the same!
 --------------------------------------------------------------------------}
Procedure TTabPageForm.ToggleEvents(how : Boolean);
var i : Integer;
Begin
   If not how then // turn off components' events
      for i := 0 to ComponentCount - 1 do Begin
         onClickList[i] := TiCheckBox(Components[i]).onClick;
         TiCheckBox(Components[i]).onClick := nil;
         If (Components[i] is TRxSpinEdit) or
            (Components[i] is TEdit) or
            (Components[i] is TComboBox) or
            (Components[i] is TComboEdit) then Begin
                onChangeList[i] := TEdit(Components[i]).onChange;
                TEdit(Components[i]).onChange := nil;
         End; {if}
      End {for}
   Else // turn on components
      for i := 0 to ComponentCount - 1 do Begin
         TiCheckBox(Components[i]).onClick := onClickList[i];
         If (Components[i] is TRxSpinEdit) or
            (Components[i] is TEdit) or
            (Components[i] is TComboBox) or
            (Components[i] is TComboEdit) then
                TEdit(Components[i]).onChange := onChangeList[i];
      End; {for/if}
End; {TTabPageForm.ToggleEvents}


{--------------------------------------------------------------------------
  TTabPageForm.TurnOffPage
   Finds any occurrance of CGroup and disables it
 --------------------------------------------------------------------------}
Procedure TTabPageForm.TurnOffPage;
var i : Integer;
Begin
   ToggleEvents(False);
   For i := 0 to ComponentCount - 1 do
     If Copy(Components[i].Name, 1, 6) = 'CGroup' then Begin
        TiCheckBox(Components[i]).Enabled := False;
        TiCheckBox(Components[i]).Checked := False;
     End;
   ToggleEvents(True);
End;

{--------------------------------------------------------------------------
  TTabPageForm.EnablePage
   Finds any occurrance of CGroup and enables it
 --------------------------------------------------------------------------}
Procedure TTabPageForm.EnablePage;
var i : Integer;
Begin
   ToggleEvents(False);
   For i := 0 to ComponentCount - 1 do
     If Copy(Components[i].Name, 1, 6) = 'CGroup' then
        TiCheckBox(Components[i]).Enabled := True;
   ToggleEvents(True);
End;


{------------------------------------------------------------------------
  TTabPageForm.PreviewUpdate
   Updates the preview.
 ------------------------------------------------------------------------}
procedure TTabPageForm.PreviewUpdate(Sender : TObject);
var myText : TStringList;
begin
   // nothing is selected
   If wEditorMain.theTree.Selected = nil then Begin
      wEditorMain.Memo1.Text := 'Nothing Selected';
      Exit;
   End;
   // a media descriptor is selected
   with TCSSRecord(wEditorMain.theTree.Selected.Data) do
      If RecordType = rtMedia then Begin
         wEditorMain.Memo1.Text := Selector + ' (media descriptor)';
         Exit;
      End; {If}
   // otherwise...
   if wEditorMain.theTree.Selected.Data = nil then Exit;
   myText := TStringList.Create;
   with wEditorMain.theTree.Selected do
      TCSSRecord(Data).GetCSS(myText, wEditorMain.thePrefs.SINGLE_QUOTES);
   wEditorMain.Memo1.Lines.Assign(myText);
   myText.Free;
end; {TTabPageForm.PreviewUpdate}


{==========================================================================
  GET and SET methods
    set - puts theTree.Selected.Data onto the screen display
    get - puts the screen display into theTree.Selected.Data
 ==========================================================================}

{--------------------------------------------------------------------------
  aCGRoup
   Set and Get for aCGroup property.
 --------------------------------------------------------------------------}
procedure TTabPageForm.SetaCGroup(num : Integer; const Value : Boolean);
var myComp : TiCheckBox;
Begin
   myComp := TiCheckBox(FindComponent('CGroup' + IntToStr(num)));
   myComp.Checked := Value;
End;

function TTabPageForm.GetaCGroup(num : Integer) : Boolean;
var myComp : TiCheckBox;
Begin
   myComp := TiCheckBox(FindComponent('CGroup' + IntToStr(num)));
   Result := myComp.Checked;
End;

{--------------------------------------------------------------------------
  aLight
   Set and Get for aLight property.
 --------------------------------------------------------------------------}
procedure TTabPageForm.SetaLight(num : Integer; const Value : Boolean);
var myComp : TLightCheck;
Begin
   myComp := TLightCheck(FindComponent('Light' + IntToStr(num)));
   myComp.Checked := Value;
End;

function TTabPageForm.GetaLight(num : Integer) : Boolean;
var myComp : TLightCheck;
Begin
   myComp := TLightCheck(FindComponent('Light' + IntToStr(num)));
   Result := myComp.Checked;
End;

{--------------------------------------------------------------------------
  aSpinner
   Set and Get for aSpinner property.
 --------------------------------------------------------------------------}
procedure TTabPageForm.SetaSpinner(num : Integer; const Value : Extended);
var myComp : TRxSpinEdit;
Begin
   myComp := TRxSpinEdit(FindComponent('Spinner' + IntToStr(num)));
   myComp.Value := Value;
End;

function TTabPageForm.GetaSpinner(num : Integer) : Extended;
var myComp : TRxSpinEdit;
Begin
   myComp := TRxSpinEdit(FindComponent('Spinner' + IntToStr(num)));
   try
      Result := myComp.Value;
   except
      on EConvertError do Result := 0;
   end; {try}
End;

{--------------------------------------------------------------------------
  aSelect
   Set and Get for aSelect property.
 --------------------------------------------------------------------------}
procedure TTabPageForm.SetaSelect(num : Integer; const Value : String);
var myComp : TRxSpeedButton;
Begin
   myComp := TRxSpeedButton(FindComponent('Select' + IntToStr(num)));
   myComp.Caption := Value;
End;

function TTabPageForm.GetaSelect(num : Integer) : String;
var myComp : TRxSpeedButton;
Begin
   myComp := TRxSpeedButton(FindComponent('Select' + IntToStr(num)));
   Result := myComp.Caption;
End;

{--------------------------------------------------------------------------
  aRadio
   Set and Get for aRadio property.
 --------------------------------------------------------------------------}
procedure TTabPageForm.SetaRadio(num : Integer; const Value : Boolean);
var myComp : TRadioButton;
Begin
   myComp := TRadioButton(FindComponent('Radio' + IntToStr(num)));
   myComp.Checked := Value;
End;

function TTabPageForm.GetaRadio(num : Integer) : Boolean;
var myComp : TRadioButton;
Begin
   myComp := TRadioButton(FindComponent('Radio' + IntToStr(num)));
   Result := myComp.Checked;
End;

{--------------------------------------------------------------------------
  aCheck
   Set and Get for aCheck property.
 --------------------------------------------------------------------------}
procedure TTabPageForm.SetaCheck(num : Integer; const Value : Boolean);
var myComp : TCheckBox;
Begin
   myComp := TCheckBox(FindComponent('Check' + IntToStr(num)));
   myComp.Checked := Value;
End;

function TTabPageForm.GetaCheck(num : Integer) : Boolean;
var myComp : TCheckBox;
Begin
   myComp := TCheckBox(FindComponent('Check' + IntToStr(num)));
   Result := myComp.Checked;
End;

{--------------------------------------------------------------------------
  aColorful
   Set and Get for aColorful property.
 --------------------------------------------------------------------------}
procedure TTabPageForm.SetaColorful(num : Integer; const Value : String);
var myComp : TComboEdit;
    myTxt  : String;
Begin
   myTxt := Value;
   myComp := TComboEdit(FindComponent('Colorful' + IntToStr(num)));
   myComp.Text := myTxt;
   If (wEditorMain.thePrefs.SHOW_COLORS) and
       (GetSystemIndex(myTxt) = -1) then Begin
      If GetIndex(myTxt) <> -1 then  // use HTML color name
         myComp.Color := ReturnWinColor(myTxt)
      Else // use HTML color value
         myComp.Color := SwapBytes(StrToInt('$'+Copy(myTxt,2,6)));
   End {Begin}
   Else
      myComp.Color := clWhite;
End;

function TTabPageForm.GetaColorful(num : Integer) : String;
var myComp : TComboEdit;
Begin
   myComp := TComboEdit(FindComponent('Colorful' + IntToStr(num)));
   Result := myComp.Text;
End;

{--------------------------------------------------------------------------
  aTextual
   Set and Get for aTextual property.
 --------------------------------------------------------------------------}
procedure TTabPageForm.SetaTextual(num : Integer; const Value : String);
var myComp : TComponent;
Begin
   myComp := FindComponent('Textual' + IntToStr(num));
   if (myComp is TiComboBox) then
      TiComboBox(myComp).Text := Value
   Else Begin
      If (myComp is TComboBox) then
         TComboBox(myComp).Text := Value
      else
         TEdit(myComp).Text := Value;
   End;
End;

function TTabPageForm.GetaTextual(num : Integer) : String;
var myComp : TComponent;
Begin
   myComp := FindComponent('Textual' + IntToStr(num));
   if (myComp is TiComboBox) then
      Result := TiComboBox(myComp).Text
   Else Begin
      If (myComp is TComboBox) then
         Result := TComboBox(myComp).Text
      else
         Result := TEdit(myComp).Text;
   End;
End;

end.
