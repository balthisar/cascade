unit UEditorMenus;

{============================================================================
  This unit handles all of the menus for the component
 ============================================================================}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus;

type
  TMenuModule = class(TDataModule)
    Menu2: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    pt1: TMenuItem;
    pc1: TMenuItem;
    in1: TMenuItem;
    cm1: TMenuItem;
    mm1: TMenuItem;
    N3: TMenuItem;
    em1: TMenuItem;
    ex1: TMenuItem;
    px1: TMenuItem;
    N6: TMenuItem;
    MakeDefault2: TMenuItem;
    Menu3: TPopupMenu;
    pt2: TMenuItem;
    pi1: TMenuItem;
    in2: TMenuItem;
    cm2: TMenuItem;
    mm2: TMenuItem;
    N4: TMenuItem;
    em2: TMenuItem;
    ex2: TMenuItem;
    px2: TMenuItem;
    N5: TMenuItem;
    MakeDefault1: TMenuItem;
    Menu1: TPopupMenu;
    WholeNumbers1: TMenuItem;
    Menu4: TPopupMenu;
    Lines1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    in3: TMenuItem;
    pi2: TMenuItem;
    in4: TMenuItem;
    cm3: TMenuItem;
    mm3: TMenuItem;
    N10: TMenuItem;
    em3: TMenuItem;
    ex3: TMenuItem;
    px3: TMenuItem;
    N11: TMenuItem;
    MakeDefault3: TMenuItem;
    Menu5: TPopupMenu;
    Inherit1: TMenuItem;
    none1: TMenuItem;
    Menu6: TPopupMenu;
    auto1: TMenuItem;
    inherit2: TMenuItem;
    Popup1: TPopupMenu;
    xxsmall1: TMenuItem;
    xsmall1: TMenuItem;
    small1: TMenuItem;
    medium1: TMenuItem;
    large1: TMenuItem;
    xlarge1: TMenuItem;
    xxlarge1: TMenuItem;
    Popup2: TPopupMenu;
    larger1: TMenuItem;
    small2: TMenuItem;
    Popup3: TPopupMenu;
    N1001: TMenuItem;
    N2001: TMenuItem;
    N3001: TMenuItem;
    N4001: TMenuItem;
    N5001: TMenuItem;
    N6001: TMenuItem;
    N7001: TMenuItem;
    N8001: TMenuItem;
    N9001: TMenuItem;
    Popup4: TPopupMenu;
    normal1: TMenuItem;
    N12: TMenuItem;
    bold1: TMenuItem;
    bolder1: TMenuItem;
    lighter1: TMenuItem;
    Popup5: TPopupMenu;
    inherit3: TMenuItem;
    normal2: TMenuItem;
    N7: TMenuItem;
    smallcaps1: TMenuItem;
    Popup6: TPopupMenu;
    inherit4: TMenuItem;
    normal3: TMenuItem;
    N13: TMenuItem;
    italic1: TMenuItem;
    oblique1: TMenuItem;
    Popup7: TPopupMenu;
    inherit5: TMenuItem;
    normal4: TMenuItem;
    N14: TMenuItem;
    condensed1: TMenuItem;
    expanded1: TMenuItem;
    extracondensed1: TMenuItem;
    extraexpanded1: TMenuItem;
    narrower1: TMenuItem;
    semiexpanded1: TMenuItem;
    semicondensed1: TMenuItem;
    ultracondensed1: TMenuItem;
    ultraexpanded1: TMenuItem;
    wider1: TMenuItem;
    Popup8: TPopupMenu;
    caption1: TMenuItem;
    icon1: TMenuItem;
    mmenu: TMenuItem;
    messagebox1: TMenuItem;
    smallcaption1: TMenuItem;
    statusbar1: TMenuItem;
    Popup9: TPopupMenu;
    inheri4: TMenuItem;
    n17: TMenuItem;
    center1: TMenuItem;
    justify1: TMenuItem;
    left1: TMenuItem;
    right1: TMenuItem;
    Menu7: TPopupMenu;
    inherit6: TMenuItem;
    normal5: TMenuItem;
    Popup10: TPopupMenu;
    inherit7: TMenuItem;
    none2: TMenuItem;
    N15: TMenuItem;
    capitalize1: TMenuItem;
    lowercase1: TMenuItem;
    uppercase1: TMenuItem;
    Popup11: TPopupMenu;
    inherit8: TMenuItem;
    normal6: TMenuItem;
    N16: TMenuItem;
    nowrap1: TMenuItem;
    pre1: TMenuItem;
    Popup12: TPopupMenu;
    inerit1: TMenuItem;
    N18: TMenuItem;
    baseline1: TMenuItem;
    bottom1: TMenuItem;
    middle1: TMenuItem;
    sub1: TMenuItem;
    super1: TMenuItem;
    textbottom1: TMenuItem;
    texttop1: TMenuItem;
    top1: TMenuItem;
    Popup13: TPopupMenu;
    auto2: TMenuItem;
    inherit9: TMenuItem;
    N19: TMenuItem;
    hidden1: TMenuItem;
    scroll1: TMenuItem;
    visible1: TMenuItem;
    Popup14: TPopupMenu;
    inherit10: TMenuItem;
    N20: TMenuItem;
    collapse1: TMenuItem;
    hidden2: TMenuItem;
    visible2: TMenuItem;
    Popup15: TPopupMenu;
    medium2: TMenuItem;
    thick1: TMenuItem;
    thin1: TMenuItem;
    Popup16: TPopupMenu;
    none3: TMenuItem;
    N21: TMenuItem;
    dashed1: TMenuItem;
    dotted1: TMenuItem;
    double1: TMenuItem;
    groove1: TMenuItem;
    hidden3: TMenuItem;
    inset1: TMenuItem;
    outset1: TMenuItem;
    ridge1: TMenuItem;
    solid1: TMenuItem;
    Popup17: TPopupMenu;
    inherit11: TMenuItem;
    N22: TMenuItem;
    norepeat1: TMenuItem;
    repeat1: TMenuItem;
    repeatx1: TMenuItem;
    repeaty1: TMenuItem;
    Popup18: TPopupMenu;
    inherit12: TMenuItem;
    N23: TMenuItem;
    fixed1: TMenuItem;
    scroll2: TMenuItem;
    Popup19: TPopupMenu;
    inherit13: TMenuItem;
    transparent1: TMenuItem;
    Popup20: TPopupMenu;
    center2: TMenuItem;
    left2: TMenuItem;
    right2: TMenuItem;
    Popup21: TPopupMenu;
    bottom2: TMenuItem;
    center3: TMenuItem;
    top2: TMenuItem;
    Popup22: TPopupMenu;
    inherit14: TMenuItem;
    none4: TMenuItem;
    N24: TMenuItem;
    block1: TMenuItem;
    compact1: TMenuItem;
    inline1: TMenuItem;
    inlinetable1: TMenuItem;
    listitem1: TMenuItem;
    marker1: TMenuItem;
    runin1: TMenuItem;
    table1: TMenuItem;
    tablecaption1: TMenuItem;
    tablecell1: TMenuItem;
    tablecolumngroup1: TMenuItem;
    tablefootergroup1: TMenuItem;
    tableheadergroup1: TMenuItem;
    tablerow1: TMenuItem;
    tablerowgroup1: TMenuItem;
    Popup23: TPopupMenu;
    inherit15: TMenuItem;
    N25: TMenuItem;
    absolute1: TMenuItem;
    fixed2: TMenuItem;
    relative1: TMenuItem;
    static1: TMenuItem;
    Popup24: TPopupMenu;
    inherit16: TMenuItem;
    N26: TMenuItem;
    ltr1: TMenuItem;
    rtl1: TMenuItem;
    Popup25: TPopupMenu;
    inherite1: TMenuItem;
    none5: TMenuItem;
    N27: TMenuItem;
    left3: TMenuItem;
    right3: TMenuItem;
    both1: TMenuItem;
    Popup26: TPopupMenu;
    inherit17: TMenuItem;
    normal7: TMenuItem;
    N28: TMenuItem;
    bidioverride1: TMenuItem;
    embed1: TMenuItem;
    Popup27: TPopupMenu;
    inherit18: TMenuItem;
    none6: TMenuItem;
    N29: TMenuItem;
    left4: TMenuItem;
    right4: TMenuItem;
    Popup28: TPopupMenu;
    inherit19: TMenuItem;
    N30: TMenuItem;
    closequote1: TMenuItem;
    openquote1: TMenuItem;
    noclosequote1: TMenuItem;
    noopenquote1: TMenuItem;
    Popup29: TPopupMenu;
    inherit20: TMenuItem;
    none7: TMenuItem;
    N31: TMenuItem;
    circle1: TMenuItem;
    deciam1: TMenuItem;
    disk1: TMenuItem;
    square1: TMenuItem;
    N32: TMenuItem;
    armenian1: TMenuItem;
    cjkideographic1: TMenuItem;
    georgian1: TMenuItem;
    hebrew1: TMenuItem;
    hiragana1: TMenuItem;
    hiraganairoha1: TMenuItem;
    katakana1: TMenuItem;
    katakanairoha1: TMenuItem;
    leadingzero1: TMenuItem;
    loweralpha1: TMenuItem;
    lowergreek1: TMenuItem;
    lowerlatin1: TMenuItem;
    lowerroman1: TMenuItem;
    upperalpha1: TMenuItem;
    upperlatin1: TMenuItem;
    upperroman1: TMenuItem;
    Popup30: TPopupMenu;
    inherit21: TMenuItem;
    N33: TMenuItem;
    inside1: TMenuItem;
    outside1: TMenuItem;
    Popup31: TPopupMenu;
    auto3: TMenuItem;
    fixed3: TMenuItem;
    inherit22: TMenuItem;
    Popup32: TPopupMenu;
    inherit23: TMenuItem;
    N34: TMenuItem;
    collapse2: TMenuItem;
    separate1: TMenuItem;
    Popup33: TPopupMenu;
    inherit24: TMenuItem;
    N35: TMenuItem;
    borders1: TMenuItem;
    noborders1: TMenuItem;
    Popup34: TPopupMenu;
    inherit25: TMenuItem;
    N36: TMenuItem;
    always1: TMenuItem;
    once1: TMenuItem;
    Popup35: TPopupMenu;
    inherit26: TMenuItem;
    N37: TMenuItem;
    top3: TMenuItem;
    bottom3: TMenuItem;
    left5: TMenuItem;
    right5: TMenuItem;
    Popup36: TPopupMenu;
    inherit27: TMenuItem;
    N38: TMenuItem;
    silent1: TMenuItem;
    xsoft1: TMenuItem;
    soft1: TMenuItem;
    medium3: TMenuItem;
    loud1: TMenuItem;
    xload1: TMenuItem;
    Popup37: TPopupMenu;
    leftside1: TMenuItem;
    farleft1: TMenuItem;
    left6: TMenuItem;
    centerleft1: TMenuItem;
    center5: TMenuItem;
    centerright1: TMenuItem;
    right6: TMenuItem;
    farright1: TMenuItem;
    rightside1: TMenuItem;
    Popup38: TPopupMenu;
    inherit28: TMenuItem;
    N39: TMenuItem;
    leftwards1: TMenuItem;
    rightwards1: TMenuItem;
    Popup39: TPopupMenu;
    inherit30: TMenuItem;
    N40: TMenuItem;
    below1: TMenuItem;
    level1: TMenuItem;
    above1: TMenuItem;
    N41: TMenuItem;
    higher1: TMenuItem;
    lower1: TMenuItem;
    Menu8: TPopupMenu;
    s1: TMenuItem;
    ms1: TMenuItem;
    Menu9: TPopupMenu;
    deg1: TMenuItem;
    grad1: TMenuItem;
    rad1: TMenuItem;
    Menu10: TPopupMenu;
    auto4: TMenuItem;
    inherit29: TMenuItem;
    none8: TMenuItem;
    Popup40: TPopupMenu;
    inherit31: TMenuItem;
    normal8: TMenuItem;
    N42: TMenuItem;
    none9: TMenuItem;
    Popup41: TPopupMenu;
    inherit32: TMenuItem;
    N43: TMenuItem;
    xlow1: TMenuItem;
    low1: TMenuItem;
    medium4: TMenuItem;
    high1: TMenuItem;
    xhigh1: TMenuItem;
    Popup42: TPopupMenu;
    inherit33: TMenuItem;
    N44: TMenuItem;
    xslow1: TMenuItem;
    slow1: TMenuItem;
    medium5: TMenuItem;
    fast1: TMenuItem;
    xfast1: TMenuItem;
    N45: TMenuItem;
    faster1: TMenuItem;
    slower1: TMenuItem;
    Popup43: TPopupMenu;
    inherit34: TMenuItem;
    N46: TMenuItem;
    child1: TMenuItem;
    female1: TMenuItem;
    male1: TMenuItem;
    Popup44: TPopupMenu;
    inherit35: TMenuItem;
    N47: TMenuItem;
    code1: TMenuItem;
    none10: TMenuItem;
    Popup45: TPopupMenu;
    inherit36: TMenuItem;
    N48: TMenuItem;
    continuous1: TMenuItem;
    digits1: TMenuItem;
    Popup46: TPopupMenu;
    inherit37: TMenuItem;
    N50: TMenuItem;
    N49: TMenuItem;
    Menu11: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    N51: TMenuItem;
    auto5: TMenuItem;
    procedure MenusPopup(Sender: TObject);
    procedure MenusClick(Sender: TObject);
    procedure Menu1Popup(Sender: TObject);
    procedure WholeNumbers1Click(Sender: TObject);
    procedure MakeDefaultClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MenuModule : TMenuModule;
  theTarget  : TComponent;   { this is a marker so we know who the target is}

implementation

uses RXCtrls, RxSpin, UEditorMain, Registry;

{$R *.DFM}

{---------------------------------------------------------------------------
  TMenuModule.MenusPopup -- FOR ALL POPUP MENUS EXCEPT RxSPINEDITS
   Register the popup component to we know which caption to change
 ---------------------------------------------------------------------------}
procedure TMenuModule.MenusPopup(Sender: TObject);
var i : Integer;
begin
   theTarget := TPopUpMenu(Sender).PopupComponent;
   {let's see if the current caption matches an existing caption...}
   with TPopupMenu(Sender) do
      for i := 0 to TPopupMenu(Sender).Items.Count - 1 do
         if Items[i].Caption = TRXSpeedButton(theTarget).Caption then
            Items[i].Checked := True
         else
            ITems[i].Checked := False;
end; {TMenuModule.MenusPopup}


{-------------------------------------------------------------------------
  TMenuModule.MenusClick  -- FOR ALL MENU ITEMS WHICH CHANGE CAPTIONS
   Change the caption of the targeted item.
 -------------------------------------------------------------------------}
procedure TMenuModule.MenusClick(Sender: TObject);
Begin
   {assign the new caption}
   TRXSpeedButton(theTarget).Caption := TMenuItem(Sender).Caption;
   with wEditorMain do
      pageForm.Enablements(Sender);
End; {TMenuModule.MenusClick}

{---------------------------------------------------------------------------
  TMenuModule.Menu1Popup -- FOR RxSPINEDIT POPUPS TO CHANGE DECIMALS
   Register the popup component so we know which decimal place to change.
 ---------------------------------------------------------------------------}
procedure TMenuModule.Menu1Popup(Sender: TObject);
var j : Integer;
begin
   theTarget := TPopupMenu(Sender).PopupComponent;
   TPopupMenu(Sender).Items[0].Checked := False;
   with TRxSpinEdit(theTarget) do
      If (Decimal = 0) or (ValueType = vtInteger) then
         TPopupMenu(Sender).Items[0].Checked := True;
   j := StrToInt(Copy(TRxSpinEdit(theTarget).Name, 8, 2));
   If j in [30,38,39,43,49,50,51,52,53] then
      TPopUpMenu(Sender).Items[0].Enabled := False
   Else
      TPopUpMenu(Sender).Items[0].Enabled := True;
end; {TMenuModule.Menu1Popup}


{---------------------------------------------------------------------------
  TMenuModule.WholeNumbers1Click -- FOR RxSPINEDITS TO CHANGE THE DECIMAL
   Toggle the decimal points.
 ---------------------------------------------------------------------------}
procedure TMenuModule.WholeNumbers1Click(Sender: TObject);
var myReg : TRegistry;
    j     : String;
begin
   with TRxSpinEdit(theTarget) do
      if Decimal = 0 then Decimal := 2 else Decimal := 0;
   {store in the registry}
   myReg := TRegistry.Create;
   myReg.RootKey := HKEY_CURRENT_USER;
   myReg.OpenKey(wEditorMain.REGISTRY_KEY + '\Decimals', True);
   j := Copy(TRxSpinEdit(theTarget).Name,8,2);
   myReg.WriteBool(j, TRxSpinEdit(theTarget).Decimal = 0);
   myReg.CloseKey;
   myReg.Free;
end; {TMenuModule.WholeNumbers1Click}

{---------------------------------------------------------------------------
  TMenuModule.MakeDefaultClick
   Put the default units into the registry
 ---------------------------------------------------------------------------}
procedure TMenuModule.MakeDefaultClick(Sender: TObject);
var myReg : TRegistry;
begin
   myReg := TRegistry.Create;
   myReg.RootKey := HKEY_CURRENT_USER;
   myReg.OpenKey(wEditorMain.REGISTRY_KEY + '\Measurements', True);
   with TRxSpeedButton(theTarget) do
      myReg.WriteString(Copy(Name,7,3), Caption);
end; {TMenuModule.MakeDefaultClick}

end.
