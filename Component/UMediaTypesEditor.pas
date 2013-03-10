unit UMediaTypesEditor;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons;

type
  TwMediaEditor = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    SrcList: TListBox;
    DstList: TListBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    Label1: TLabel;
    LabelPreview: TLabel;
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExcAllBtnClick(Sender: TObject);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetButtons;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wMediaEditor: TwMediaEditor;

implementation

{$R *.DFM}

{===========================================================================
   TwMediaEditor.IncludeBtnClick
      Include a single item in the destination list.
 ===========================================================================}
procedure TwMediaEditor.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(SrcList);
  MoveSelected(SrcList, DstList.Items);
  SetItem(SrcList, Index);
end; {TwMediaEditor.IncludeBtnClick}


{===========================================================================
   TwMediaEditor.ExcludeBtnClick
      Exclude a single item in the destination list.
 ===========================================================================}
procedure TwMediaEditor.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(DstList);
  MoveSelected(DstList, SrcList.Items);
  SetItem(DstList, Index);
end; {TwMediaEditor.ExcludeBtnClick}


{===========================================================================
   TwMediaEditor.IncAllBtnClick
      Include all items in the destination list.
 ===========================================================================}
procedure TwMediaEditor.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to SrcList.Items.Count - 1 do
    DstList.Items.AddObject(SrcList.Items[I],
      SrcList.Items.Objects[I]);
  SrcList.Items.Clear;
  SetItem(SrcList, 0);
end; {TwMediaEditor.IncAllBtnClick}


{===========================================================================
   TwMediaEditor.ExcAllBtnClick
      Exclude all items in the destination list.
 ===========================================================================}
procedure TwMediaEditor.ExcAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
  DstList.Items.Clear;
  SetItem(DstList, 0);
end; {TwMediaEditor.ExcAllBtnClick}


{===========================================================================
   TwMediaEditor.MoveSelected
      Let the user rearrange the list.
 ===========================================================================}
procedure TwMediaEditor.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end; {TwMediaEditor.MoveSelected}


{===========================================================================
   TwMediaEditor.SetButtons
      Set the button states accordingly
 ===========================================================================}
procedure TwMediaEditor.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  IncludeBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled := not SrcEmpty;
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
end; {TwMediaEditor.SetButtons}


{===========================================================================
   TwMediaEditor.GetFirstSelection
      Get the first selection.
 ===========================================================================}
function TwMediaEditor.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end; {TwMediaEditor.GetFirstSelection}



{===========================================================================
   TwMediaEditor.SetItem
      Set an item in the list.
 ===========================================================================}
procedure TwMediaEditor.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
         i: Integer;
    tmpStr: String;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
  // update LabelPreview
  tmpStr := '@media ';
  For i := 0 to DstList.Items.Count - 1 do
     tmpStr := tmpStr + DstList.Items[i] + ', ';
  tmpStr := Copy(tmpStr, 1, Length(tmpStr)-2);
  LabelPreview.Caption := tmpStr;
end; {TwMediaEditor.SetItem}


{===========================================================================
   TwMediaEditor.FormShow
      Make the list reflect the current @media selection.
 ===========================================================================}
procedure TwMediaEditor.FormShow(Sender: TObject);
var tmpStr : String;
    tmpSt2 : String;
         i : Integer;
begin
   If LabelPreview.Caption = '@media' then Exit; // nothing to parse
   // Iterate through media descriptors and add to DstList.
   tmpStr := Copy(LabelPreview.Caption, 8, Length(LabelPreview.Caption)-7) + ',';
   tmpSt2 := '';
   for i := 1 to Length(tmpStr) do Begin
      If tmpStr[i] <> ',' then
         tmpSt2 := Trim(tmpSt2 + tmpStr[i])
      Else Begin
         DstList.Items.Add(tmpSt2);
         tmpSt2 := '';
      End; {if}
   end; {for}
   // Iterate through DstList, and remove items from SrcList if present.
   For i := 0 to DstList.Items.Count - 1 do
      If SrcList.Items.IndexOf(DstList.Items[i]) <> - 1 then
         SrcList.Items.Delete(SrcList.Items.IndexOf(DstList.Items[i]));

end; {TwMediaEditor.FormShow}

end.
