unit UEditorMain;

{===========================================================================
  UEditorMain
   This is where the bulk of all of the processing takes place
 ===========================================================================}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, Menus, UEditorMenus, RXCtrls, HETreeView,
  RXSplit, Placemnt, UMultiPage, UCSS2Document, UInputDLOG,
  UPreferences, USelectDLOG, UPage1, UPage2, UPage3, UPage4, UPage5, UPage6,
  UPage7, UPage8, UPage9, UPage10, UPage11, UPage12, UPage13, UPage14,
  ToolWin, ImgList, USimpleDialogs, UAboutMe, dropsource, DropTarget,
  DdeMan, UMediaTypesEditor, OleCtrls;


{-------------------------------------------------------------------
  Multi-document support.
 -------------------------------------------------------------------}
const
   CAPACITY = 10; {maximum number of files allowed}

type TDocStats = RECORD {holds the unique information for each open document}
        ORIG_AUTHOR   : String;    {the original author of the document}
        ORIG_EMAIL    : String;    {the email address of the original author}
        ORIG_URL      : String;    {the URL of the original author}
        FILE_PATH     : String;    {the complete path of the saved-as file}
        PREVIEW_PATH  : String;    {the default path for the browser document}
        TREE_POS      : Integer;   {the selected element in the tree}
        IS_TEMPLATE   : Boolean;   {indicates the file is a template file}
        NEEDS_SAVE_AS : Boolean;   {indicates the file hasn't been saved-as}
        DIRTY         : Boolean;   {indicates the file is dirty}
        LEVEL_DOC     : Integer;   {indicates the current document features}
        LEVEL_REC     : Integer;   {indicates the current record features}
     End; {Record}


{-------------------------------------------------------------------
  Preferences Record
 -------------------------------------------------------------------}
type TEditorPrefs = RECORD {holds the preferences for the editor}
        PREF_FONTS       : Boolean;   {true if fonts lists should be own font}
        SHOW_COLORS      : Boolean;   {true if color boxes should have color}
        ALLOW_SYS_COLORS : Boolean;   {allow system colors in the picker?}
        SHOW_SHORTCUTS   : Boolean;   {true if the shortcut bar should be shown}
        CONFIRM_DELETE   : Boolean;   {true if DEL should be confirmed}
        NEW_AUTHOR       : String;    {default name for new author}
        NEW_EMAIL        : String;    {default name for author email}
        NEW_URL          : String;    {default name for author URL}
        DEFAULT_DIR      : String;    {initial directory to save things}
        TREE_POS         : TRect;     {detached tree position, if any}
        CODE_POS         : TRect;     {detached preview position, if any}
        MAIN_POS         : TPoint;    {position of the main form}
        SINGLE_QUOTES    : Boolean;   {single quotes instead of double}
        DUPLICATE_WARN   : Boolean;   {warn if duplicate selector}
     End; {Record}


{-------------------------------------------------------------------
  Detachable Window Records Record
 -------------------------------------------------------------------}
 type TDetachRecord = RECORD
         theWin   : TForm;
         OrigDims : TRect;
         NewDims  : TRect;
      End; {Record}

 {-------------------------------------------------------------------
  Miscellaneous constants
 -------------------------------------------------------------------}
type
  veSaveType = (veBoth, veExport, veSave, veNone);
  exType = (exAll, exSelected);

const
  APP_TITLE = 'Cascade 2.0';  {needed for file opening in Application mode}
  ABOOT = 'I''m honest and I paid.';
  WinKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion';
  CharsUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  CharsLower = 'abcdefghijklmnopqrstuvwxyz';
  CharsNumbers = '1234567890';
  CharsExpert = '@.: -#,*>+';
  tempHTML = 'temphtml.html';
  tempCSS = 'tempcss.css';

  AllClasses = True;
  SelectedClasses = False;


{-------------------------------------------------------------------
  Dialog Strings
 -------------------------------------------------------------------}
  UsedStrings : Array[1..29] of String = (
  {1}   'Create HTML Element',
  {2}   'Please type the name of the HTML Element you wish to create.',
  {3}   'The element %S already exists!',
  {4}   'Create a Class',
  {5}   'Please type the name of the class you wish to create.',
  {6}   'The item %S already exists!',
  {7}   'Rename a CSS2 class...',
  {8}   'Go ahead and make any desired changes to the class name below.',
  {9}   'Create an ID Class',
  {10}  'Please type the name of the ID you wish to create.',
  {11}  'Create a Contextual class for <%S>',
  {12}  'Type the name of an HTML Element to be used in context with <%S>.',
  {13}  'Create a Subclass of <%S>',
  {14}  'Please type a name for the new subclass of <%S>.',
  {15}  'Create a Custom Selector (Expert Mode)',
  {16}  'Please type the complete selector exactly as you wish it to appear in your stylesheet.',
  {17}  'Create a Pseudoclass or Pseudoelement',
  {18}  'Please select the pseudoclass you would like for %S.',
  {19}  'Paste from Clipboard (Expert Selector)',
  {20}  'The class below already exists. Please type a complete, new selector to paste this class.',
  {21}  'Are you sure you wish to remove the class %S?',
  {22}  'The document %S has been changed. Do you wish to save the changes?',
  {23}  'The extension %S is not a valid extension, so nothing will be written to your disk.',
  {24}  'Drop a Dragged Class (Expert Selector)',
  {25}  'The class below already exists. Please type a complete, new selector to drop this class.',
  {26}  'Stylesheet URL needed.',
  {27}  'Please enter the fully-qualified -or- relative URL for the stylesheet %S will access, as the stylesheet will exist on the server.',
  {28}  'Some of your documents will not be opened, because the maximum number of documents has been reached.',
  {29}  'The file %S is not a valid Cascade file, and will not be opened.'
     );


{-------------------------------------------------------------------
  Strings to add for HTML
 -------------------------------------------------------------------}
  HTMLStr : Array[1..9] of String = (
  {1}   '<!--',
  {2}   '    This CSS2 Style Sheet by Balthisar Cascade for Win32.',
  {3}   '    Balthisar Cascade is the CSS2 editor everyone''s heard about!',
  {4}   '-->',
  {5}   '',
  {6}   '<STYLE TYPE="text/css">',
  {7}   '<!--',
  {8}   '-->',
  {9}   '</STYLE>'
    );


{-------------------------------------------------------------------
  Strings to add for Pseudos picker
 -------------------------------------------------------------------}
   Pseudos : Array[1..10] of String = (
      {1} ':first-child',
      {2} ':link',
      {3} ':visited',
      {4} ':hover',
      {5} ':active',
      {6} ':focus',
      {7} ':first-line',
      {8} ':first-letter',
      {9} ':before',
     {10} ':after');


{-------------------------------------------------------------------
  Initial strings for the HTML Element Picker
 -------------------------------------------------------------------}
  Elements : Array[1..15] of String = (
  {1}   'A',
  {2}   'TABLE',
  {3}   'P',
  {4}   'OL',
  {5}   'UL',
  {6}   'LI',
  {7}   'TR',
  {8}   'HR',
  {9}   'SPAN',
  {10}  'H1',
  {11}  'H2',
  {12}  'H3',
  {13}  'H4',
  {14}  'H5',
  {15}  'H6' );


{-------------------------------------------------------------------
  Declaration of the form, proper
 -------------------------------------------------------------------}
type
  TwEditorMain = class(TForm)
    // menus
    MainMenu1: TMainMenu;
    mMenu1: TMenuItem;
    mMenu2: TMenuItem;
    mMenu3: TMenuItem;
    mMenu4: TMenuItem;
    mMenu5: TMenuItem;
    mMenu6: TMenuItem;
    // popup menus
    PopupTree: TPopupMenu;
    PopupPreview: TPopupMenu;
    PopupExport: TPopupMenu;
    cmAbout: TMenuItem;
    cmApply: TMenuItem;
    cmAsDocument: TMenuItem;
    cmClose: TMenuItem;
    cmContextClass: TMenuItem;
    cmContextClass1: TMenuItem;
    cmCopy: TMenuItem;
    cmCopy1: TMenuItem;
    cmCopyAll: TMenuItem;
    cmCopySelected: TMenuItem;
    cmCut: TMenuItem;
    cmCut1: TMenuItem;
    cmDelete: TMenuItem;
    cmDelete1: TMenuItem;
    cmExit: TMenuItem;
    cmExpertSelector: TMenuItem;
    cmExport: TMenuItem;
    cmExportAll: TMenuItem;
    cmExportAll2: TMenuItem;
    cmExportSelected: TMenuItem;
    cmExportSelected2: TMenuItem;
    cmExportTagged: TMenuItem;
    cmExportTagged2: TMenuItem;
    cmHelp: TMenuItem;
    cmInBrowser: TMenuItem;
    cmInstallTool: TMenuItem;
    cmMediaType: TMenuItem;
    cmNew: TMenuItem;
    cmNewClass: TMenuItem;
    cmNewElement: TMenuItem;
    cmNewID: TMenuItem;
    cmOpen: TMenuItem;
    cmPaste: TMenuItem;
    cmPaste1: TMenuItem;
    cmPreferences: TMenuItem;
    cmPreviewAll: TMenuItem;
    cmPreviewSingle: TMenuItem;
    cmPreviewTagged: TMenuItem;
    cmPseudoClass: TMenuItem;
    cmPseudoclass1: TMenuItem;
    cmRename: TMenuItem;
    cmRename1: TMenuItem;
    cmSave: TMenuItem;
    cmSaveAs: TMenuItem;
    cmShowClassesDetached: TMenuItem;
    cmShowCodeDetached: TMenuItem;
    cmShowShortcuts: TMenuItem;
    cmSubClass: TMenuItem;
    cmSubclass1: TMenuItem;
    cmTag: TMenuItem;
    cmTag1: TMenuItem;
    // menu dividers
    cmDivider1: TMenuItem;
    cmDivider2: TMenuItem;
    cmDivider3: TMenuItem;
    cmDivider4: TMenuItem;
    cmDivider5: TMenuItem;
    cmDivider6: TMenuItem;
    cmDivider7: TMenuItem;
    cmDivider8: TMenuItem;
    cmDivider10: TMenuItem;
    cmDivider11: TMenuItem;
    cmDivider12: TMenuItem;
    cmDivider13: TMenuItem;
    cmDivider14: TMenuItem;
    // panels
    PanelDocuments: TPanel;
    PanelShortcuts: TToolBar;
    PanelStatus: TPanel;
    PanelPreview: TPanel;
    PanelPreviewButton: TPanel;
    PanelTree: TPanel;
    PanelTreeButton: TPanel;
    //shortcut bar items
    ControlBar1: TControlBar;
    Shortcut1: TRxSpeedButton;
    Shortcut2: TRxSpeedButton;
    Shortcut3: TRxSpeedButton;
    Shortcut4: TRxSpeedButton;
    Shortcut5: TRxSpeedButton;
    Shortcut6: TRxSpeedButton;
    Shortcut7: TRxSpeedButton;
    Shortcut8: TRxSpeedButton;
    Shortcut9: TRxSpeedButton;
    Shortcut10: TRxSpeedButton;
    Shortcut11: TRxSpeedButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    Memo1: TMemo;
    // other buttons
    Button1: TButton;
    Button2: TRxSpeedButton;
    // miscellaneous
    Image1: TImage;
    Image2: TImage;
    theStatusBar1: TStatusBar;
    theStatusBar2: TStatusBar;
    TabDocuments: TTabControl;
    Timer1: TTimer;
    System: TDdeServerConv;
    ImageList1: TImageList;
    N1: TMenuItem;
    SelectDLOG: TSelectDLOG;
    DropFileTarget1: TDropFileTarget;
    DropFileTarget2: TDropFileTarget;
    SaveDialog1: TSaveDLOG;
    OpenDialog1: TOpenDLOG;
    InputDLOG: TInputDLOG;
    theTree: THETreeView;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;

    // form routines
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    //-------------------
    // user menu actions
    //-------------------
    procedure Button1Click(Sender: TObject);       // toggle tagged/untagged
    procedure Shortcut10Click(Sender: TObject);    // initiate context-help
    // --file
    procedure cmCloseClick(Sender: TObject);
    procedure cmExitClick(Sender: TObject);
    procedure cmExportSelectedClick(Sender: TObject);
    procedure cmInBrowserClick(Sender: TObject);
    procedure cmNewClick(Sender: TObject);
    procedure cmOpenClick(Sender: TObject);
    procedure cmSaveAsClick(Sender: TObject);
    procedure cmSaveClick(Sender: TObject);
    // --edit
    procedure cmCopyClick(Sender: TObject);
    procedure cmCutClick(Sender: TObject);
    procedure cmDeleteClick(Sender: TObject);
    procedure cmPasteClick(Sender: TObject);
    procedure cmPreferencesClick(Sender: TObject);
    procedure cmRenameClick(Sender: TObject);
    // --view
    procedure cmShowClassesDetachedClick(Sender: TObject);
    procedure cmShowCodeDetachedClick(Sender: TObject);
    procedure cmShowShortcutsClick(Sender: TObject);
    // --classes
    procedure cmContextClassClick(Sender: TObject);
    procedure cmExpertSelectorClick(Sender: TObject);
    procedure cmMediaTypeClick(Sender: TObject);
    procedure cmNewClassClick(Sender: TObject);
    procedure cmNewElementClick(Sender: TObject);
    procedure cmNewIDClick(Sender: TObject);
    procedure cmPseudoClassClick(Sender: TObject);
    procedure cmSubClassClick(Sender: TObject);
    // --tools
    procedure cmApplyClick(Sender: TObject);
    // --help
    procedure cmAboutClick(Sender: TObject);
    procedure cmHelpClick(Sender: TObject);
    // --contexts not in main menu
    procedure cmCopyAllClick(Sender: TObject);
    procedure cmCopySelectedClick(Sender: TObject);
    procedure cmPaste1Click(Sender: TObject);
    procedure cmPreviewClick(Sender: TObject);
    // page/document/class switching
    procedure PageControl1Change(Sender: TObject);
    procedure TabDocumentsChange(Sender: TObject);
    procedure TabDocumentsChanging(Sender: TObject; var AllowChange: Boolean);
    procedure theTreeChange(Sender: TObject; Node: TTreeNode);
    procedure theTreeChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    // dragging, not including detachable items
    procedure TabDocumentsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TabDocumentsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure theTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure theTreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    // popup routines, not including initiation of actions
    procedure PopupPreviewPopup(Sender: TObject);
    procedure PopupTreePopup(Sender: TObject);
    procedure theTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    // miscellaneous event-driven routines
    procedure AttachAPanel(Sender: TObject; var Action: TCloseAction);
    procedure ControlBar1Resize(Sender: TObject);
    procedure DetachAPanel(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure mMenu1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; DragType: TDragType;
      Files: TStrings; Point: TPoint);
    procedure SystemExecuteMacro(Sender: TObject; Msg: TStrings);
  ///////
  private
    {internally used}
    MenuHolder : TMenuModule;    {contains the menus we assign to popup items}
    pageList   : Array[1..14] of TTabPageFormClass; {holds a list of dynamic pages}
    CBOARD     : TCSSRecord;     {local clipboard for local use}
    CBOARD2    : TCSSRecord;     {extra CBOARD for inter-file drag and drop}
    EXPERT_R   : Boolean;        {use expert rename mode?}
    USE_WWTD   : Boolean;        {look for a template in creating a file?}
    TreeWin    : TDetachRecord;  {holds the detached tree}
    PreviewWin : TDetachRecord;  {holds the detached preview pane}
    // form maintenance, including detached items
    procedure DetachedKeyPress(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure NeutralizePositions;
    procedure ShowPage(i : Integer);
    procedure WMSysCommand(var Message : TWMSysCommand); message WM_SYSCOMMAND;
    // display maintenance
    procedure ClearTheTree;
    procedure EmboldenTree;
    procedure UpdateMenus;
    // CSS2 class support
    function ClassExists(const theName : String) : Boolean;
    procedure AppendNewClass(aName : String; aKind : TCSSRecordType);
    // I/O maintenance
    function CloseDocument(index : Integer) : Word;
    function EZFile : String;
    function VExtension(theExt : String; how : veSaveType) : Boolean;
    procedure ExportDocument(FileName : String; qAll : exType);
    procedure ReallyOpen(FileName : String);
    procedure ReallySave(FileName : String);
    procedure ImportCSS(FileName : String);
    // Other routines
    procedure WritePreferences;
    procedure ReadPreferences;
  //////
  public
    pageForm : TTabPageForm;                       {holder for dynamic forms}
    thePrefs : TEditorPrefs;                       {preferences}
    {multi-file support}
    CURRENT_FILE     : Integer;   {index of the current editor file.}
    FILE_COUNT       : Integer;   {how many files are in use?}
    DOC_COUNT        : Integer;   {the "Document n" next available count.}
    TEMP_DIR         : String;    {location of the Windows TEMP directory.}
    theFile : Array[0..CAPACITY-1] of TDocStats;   {multi-file statistics}
    {shell document-opening support / component-use support}
    START_FILES : Array[0..CAPACITY-1] of String;
    {component-published}
    DOCUMENT_LIST    : String;    {the list the component uses for docs}
    REGISTRY_KEY     : String;    {the key to the COMPONENT's registry}
    ABOUT_PASSWORD   : String;    {the password to disable the about box}
    APPLICATION_NAME : String;    {the name of the application}
    HELP_FILE        : String;    {the name of the help file}
    HELP_CONTEXT     : THelpContext; {the help context to use for help}
    {component-private}
    APP_MODE         : Boolean;   {running in Application Mode or not?}
    DONE_STARTING    : Boolean;   {has the application finished onShow first?}
    function ParseFileList : Integer;
    procedure MarkDirty(isDirty : Boolean);
    procedure ParseHTML(FileName : String; CSSName : String);
    procedure DoBoldTree;
    procedure ShowSplash;
  end;


var
  wEditorMain: TwEditorMain;

{=========================================================================}
{                              IMPLEMENTATION                             }
{=========================================================================}

implementation

uses Registry, UTiGroupBoxSet, lightchk, RxSpin, ToolEdit, ShellAPI,
     UJimsUtilities, UJDParseCSS;

{$R *.DFM}


{=========================================================================}
{ FORM ROUTINES                                                           }
{=========================================================================}


{-------------------------------------------------------------------------
  TwEditorMain.FormClose
     o Free-up allocated memory.
     o Erase any temporary files.
 -------------------------------------------------------------------------}
procedure TwEditorMain.FormClose(Sender: TObject; var Action: TCloseAction);
var j : TSearchRec;
    i : Integer;
begin
   theTree.Visible := False;
   // close all files
   For i := FILE_COUNT -1 downto 0 do
      if CloseDocument(i) = mrCancel then Begin
         theTree.Visible := True;
         Action := caNone;
         Exit;
      end; {if}
   // free up allocated memory
   pageForm.Free;
   MenuHolder.Free;
   CBOARD.Free;
   CBOARD2.Free;
   // clean up any temporary files
   If FindFirst(TEMP_DIR + '*.WWST', faAnyFile, j) = 0 then
      DeleteFile(TEMP_DIR + j.Name);
   While FindNext(j) = 0 do
      DeleteFile(TEMP_DIR + j.Name);
   FindClose(j);
   DeleteFile(TEMP_DIR + tempHTML);
   DeleteFile(TEMP_DIR + tempCSS);
   // write the preferences
   WritePreferences;
end; {TwEditorMain.FormClose}


{-------------------------------------------------------------------------
  TwEditorMain.FormCreate
     o Create the form which contains the menus.
     o Create the pageList (an array of types for the pages).
     o Default the globals before the preferences are read.
     o Default other pertinent globals.
 -------------------------------------------------------------------------}
procedure TwEditorMain.FormCreate(Sender: TObject);
begin
   {create the menu holder}
   MenuHolder := TMenuModule.Create(Application);

   {create the pageList}
   pageList[1] := TwPage1;   pageList[2] := TwPage2;   pageList[3] := TwPage3;
   pageList[4] := TwPage4;   pageList[5] := TwPage5;   pageList[6] := TwPage6;
   pageList[7] := TwPage7;   pageList[8] := TwPage8;   pageList[9] := TwPage9;
   pageList[10] := TwPage10; pageList[11]:= TwPage11;  pageList[12]:= TwPage12;
   pageList[13] := TwPage13; pageList[14] := TwPage14;

   {default preferences}
   with thePrefs do Begin
      PREF_FONTS       := True;
      SHOW_COLORS      := True;
      ALLOW_SYS_COLORS := True;
      SHOW_SHORTCUTS   := True;
      CONFIRM_DELETE   := True;
      NEW_AUTHOR       := 'Anonymous';
      NEW_EMAIL        := 'you@domain.name';
      NEW_URL          := 'http://www.yourdomain.name';
   End; {with}

   {multi-file defaults}
   CURRENT_FILE := 0;
   FILE_COUNT   := 0;
   DOC_COUNT    := 0;
   MarkDirty(False);

   {other defaults}
   EXPERT_R := False;      {we are NOT in expert-rename mode}
   USE_WWTD := True;       {we ARE using a template for New...}
   DONE_STARTING := False; {we are NOT done starting the app}
end; {TwEditorMain.FormCreate}


{-------------------------------------------------------------------------
  TwEditorMain.FormShow
    o Read the preferences from the registy.
    o Set up the application's title.
    o Locate the Windows TEMP directory.
    o Adjust the display for the preferences.
    o Handle component registration.
    o Handle App-mode vs. Component-mode.
    o Show the loaded documents on the TabControl.
    o Show the first page, and update the menus.
 -------------------------------------------------------------------------}
procedure TwEditorMain.FormShow(Sender: TObject);
var myReg : TRegistry;
      j,i : Integer;
begin
   {only do this the first time the form is shown}
   If DONE_STARTING then Exit;
   DONE_STARTING := TRUE;
   {set up the application's title}
   If APP_MODE then
      Application.Title := APP_TITLE
   Else
      Application.Title := APPLICATION_NAME;
   // neutralize the default positions before reading preferences
   NeutralizePositions;
   {read the preferences}
   ReadPreferences;
   {find out where the windows TEMP directory is}
   myReg := TRegistry.Create;
   myReg.RootKey := HKEY_LOCAL_MACHINE;
   if myReg.KeyExists(WinKey) then Begin
      myReg.OpenKey(WinKey, False);
      if myReg.ValueExists('SystemRoot') then
         TEMP_DIR := myReg.ReadString('SystemRoot') + '\TEMP\'
      else
         TEMP_DIR := GetCurrentDir;
   end; {if}
   myReg.CloseKey;
   myReg.Free;
   {registration for component}
   If ABOUT_PASSWORD = ABOOT then Begin
      cmAbout.Visible := False;
      cmDivider4.Visible := False;
   End;
   {if HELP_FILE is empty, hide it}
   cmHelp.Visible := HELP_FILE <> '';
   cmDivider4.Visible := HELP_FILE <> '';
   Shortcut10.Visible := HELP_FILE <> '';
   {AppMode vs Component Mode}
   cmNew.Visible := APP_MODE;
   cmOpen.Visible := APP_MODE;
   cmSave.Visible := APP_MODE;
   cmSaveAs.Visible := APP_MODE;
   cmDivider7.Visible := not APP_MODE;
   cmAsDocument.Visible := not APP_MODE;
   cmInBrowser.Visible := APP_MODE;
   cmDivider12.Visible := APP_MODE;
   {show the first page}
   PageControl1.ActivePage := TabSheet1;
   ShowPage(PageControl1.ActivePage.Tag);
   UpdateMenus;
   {================================}
   {show all of the loaded documents}
   {================================}
   j := ParseFileList;
   {open the the documents}
   TabDocuments.Tabs.Clear;
   for i := 0 to j-1 do ReallyOpen(START_FILES[i]);
   {start with a blank document if necessary}
   If FILE_COUNT = 0 then Begin
      cmNewClick(Sender);
      FILE_COUNT := 1;
   End;
   {=========================================}
   {initialize the TreeWin and the PreviewWin}
   {=========================================}
   TreeWin.NewDims.Top := Top + 20;
   TreeWin.NewDims.Left := -1;
   TreeWin.NewDims.Bottom := 400;
   TreeWin.NewDims.Right := 200;
   PreviewWin.NewDims.Top := Top + 20;
   PreviewWin.NewDims.Left := -1;
   PreviewWin.NewDims.Bottom := 400;
   PreviewWin.NewDims.Right := 200;
end; {TwEditorMain.FormShow}


{=========================================================================}
{ USER MENU ACTIONS                                                       }
{=========================================================================}


{=========================================================================}
{ USER MENU ACTIONS -- misc.                                              }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.Button1Click
   The user is toggling "tagged"
    o Toggle the IsTagged flag and change the emboldening.
    o Mark the file as dirty.
    o Update the menus to reflect the new state.
 ------------------------------------------------------------------------}
procedure TwEditorMain.Button1Click(Sender: TObject);
begin
   {toggle IsTagged, and reset the emboldening}
   with TCSSRecord(theTree.Selected.Data) do Begin
      IsTagged := not IsTagged;
      theTree.SetItemBold(theTree.Selected, IsTagged);
   end; {with}
   MarkDirty(True);
   UpdateMenus;
end; {TwEditorMain.Button1Click}


{------------------------------------------------------------------------
  TwEditorMain.Shortcut10Click
    Start context-sensitive help.
 ------------------------------------------------------------------------}
procedure TwEditorMain.Shortcut10Click(Sender: TObject);
begin
   SendMessage(Handle, WM_SYSCOMMAND, SC_CONTEXTHELP, 0)
end; {TwEditorMain.Shortcut10Click}


{=========================================================================}
{ USER MENU ACTIONS -- file                                               }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.cmCloseClick
   Close the current document.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmCloseClick(Sender: TObject);
begin
   CloseDocument(TabDocuments.TabIndex);
end; {TwEditorMain.cmCloseClick}


{------------------------------------------------------------------------
  TwEditorMain.cmExitClick
   The user is quitting.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmExitClick(Sender: TObject);
begin
   Close;
end; {TwEditorMain.cmExitClick}


{------------------------------------------------------------------------
  TwEditorMain.cmExportSelectedClick
   Export only the currently selected class. Only supported to CSS.
    o Set up the file dialog.
    o Validate the name
    o Get the CSS from the TCSSRecord in the tree.
    o Write it to disk.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmExportSelectedClick(Sender: TObject);
var myFile  : TextFile;
    tmpStr,
    tmpExt  : String;
    theList : TStringList;
    i       : Integer;
begin
   // set up the dialog
   SaveDialog1.Title := 'Export CSS Class';
   SaveDialog1.Filter := 'Cascading Style Sheet|*.CSS';
   SaveDialog1.FilterIndex := 1;
   SaveDialog1.FileName := '';
   SaveDialog1.DefaultExt := 'CSS';
   If not SaveDialog1.Execute then Exit;
   tmpStr := SaveDialog1.FileName;
   tmpExt := ExtractFileExt(tmpStr);
   if not VExtension(tmpExt, veExport) then Exit;
   // create the CSS
   theList := TStringList.Create;
   TCSSRecord(theTree.Selected.Data).GetCSS(theList, thePrefs.SINGLE_QUOTES);
   // output the list
   try
      AssignFile(myFile, tmpStr);
      ReWrite(myFile);
      for i := 0 to theList.Count -1 do WriteLn(myFile, theList.Strings[i]);
   finally
      CloseFile(myFile);
   end;
   // clean up
   theList.Free;
end; {TwEditorMain.cmExportSelectedClick}


{------------------------------------------------------------------------
  TwEditorMain.cmInBrowserClick
   Preview the current stylesheet in the browser.
   o Get the HTML filename.
   o Save the temporary CSS stylesheet
   o Start loading the HTML file, and PARSE OUT the unwanted parts, while
     inserting the necessary parts.
   o Save the HTML file to a temp file.
   o ShellExec the HTML file.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmInBrowserClick(Sender: TObject);
var tmpStr : String;
    tmpExt : String;
    myPChr : PChar;
begin
   // set up the file open dialogue
   OpenDialog1.Title := 'Choose the HTML file to preview the CSS';
   OpenDialog1.Filter := 'HTML File|*.HTML;*.HTM';
   OpenDialog1.DefaultExt := '';
   OpenDialog1.FilterIndex := 1;
   OpenDialog1.Options := OpenDialog1.Options - [ofAllowMultiSelect];
   If not OpenDialog1.Execute then Exit;
   // get the user's file of choice
   tmpStr := ExtractFileName(OpenDialog1.FileName);
   tmpExt := UpperCase(ExtractFileExt(tmpStr));
   // make sure the file is valid.
   if (tmpExt <> '.HTML') and (tmpExt <> '.HTM') then
      If not VExtension(tmpExt, veNone) then Exit;
   If not FileExists(tmpStr) then Exit;
   // save the temporary CSS file.
   ExportDocument(TEMP_DIR + tempCSS, exAll);
   // parse the HTML file -- automatically creates tempHTML in TEMP_DIR
   ParseHTML(tmpStr, tempCSS); // tempCSS is the name of the file for the HTML
   // execute the document
   tmpStr := TEMP_DIR + tempHTML;
   GetMem(myPChr, Length(tmpStr) + 1);
   StrPCopy(myPChr, tmpStr);
   ShellExecute(Handle, nil, myPChr, nil, nil, SW_SHOWNORMAL);
   FreeMem(myPChr);
   SaveDialog1.InitialDir := '';
   OpenDialog1.InitialDir := '';
end; {TwEditorMain.cmInBrowserClick}


{------------------------------------------------------------------------
  TwEditorMain.cmNewClick
   Create a new, blank document if able.
    - called any time a document is Opened
    - called any time the user wants a blank document.
    - called during initial startup.
      o Increase the FILE_COUNT and DOC_COUNT by one.
      o Set initial values.
      o Create the temp file, so we can switch in TabDocuments.Change
      o Add to the tabs, and make them visible
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmNewClick(Sender: TObject);
var myDoc : TCascadeDocument;
        j : Integer;
        k : Boolean;
   tmpStr : String;
begin
   // initialize
   k := True;
   If FILE_COUNT >= CAPACITY then Exit;
   // increase counters
   DOC_COUNT := DOC_COUNT + 1;          // increase the DOC_COUNT
   FILE_COUNT := FILE_COUNT + 1;        // increase the file count.
   j := FILE_COUNT-1;                   // set temporary "current file."
   // set initial values
   with theFile[j] do Begin
      DIRTY         := False;           // mark it not dirty
      NEEDS_SAVE_AS := True;            // mark as requiring a "save as"
      IS_TEMPLATE   := False;           // mark as not being a template
      TREE_POS      := -1;              // marks as nothing selected
      FILE_PATH     := 'Document ' + IntToStr(DOC_COUNT);
      ORIG_AUTHOR := thePrefs.NEW_AUTHOR;
      ORIG_EMAIL := thePrefs.NEW_EMAIL;
      ORIG_URL := thePrefs.NEW_URL;
      PREVIEW_PATH := '';
      LEVEL_DOC := 0;
      LEVEL_REC := 0
   end; {with}
   // we need to create the temp file now
   myDoc := TCascadeDocument.Create(nil);
   tmpStr := StripFileName(theFile[j].FILE_PATH) + '.WWST';
   If (APP_MODE) and (Sender <> nil) and (USE_WWTD) then // load default
      myDoc.OpenDocument(ExtractFilePath(ParamStr(0)) + 'default.WWTD');
   myDoc.SaveDocument(TEMP_DIR + tmpStr);
   myDoc.Free;
   // switch away from the old tab...
   If FILE_COUNT > 1 then TabDocumentsChanging(Sender, k);
   // add to the "TabDocuments"
   TabDocuments.Tabs.Add(theFile[j].FILE_PATH);
   TabDocuments.TabIndex := j;
   TabDocuments.Visible := True;
   // switch to the new tab
   TabDocumentsChange(Sender);
   // finalize
   USE_WWTD := True;
end; {TwEditorMain.cmNewClick}


{------------------------------------------------------------------------
  TwEditorMain.cmOpenClick
   Open a Document
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmOpenClick(Sender: TObject);
var tmpStr : String;
    tmpExt : String;
         i : Integer;
         k : Boolean;
begin
   // set up the file open dialogue
   OpenDialog1.Title := 'Open Cascade Document';
   OpenDialog1.Filter := 'Cascade Readable Files|*.WWS2;*.WWTD;*.CSS;*.HTML;*.HTM' +
                         '|Cascade 2.0 Document|*.WWS2|Cascade Stationary|*.WWTD' +
                         '|Cascading Stylesheet|*.CSS|HTML File|*.HTML|Archaic HTM Document|*.HTM';
   OpenDialog1.DefaultExt := 'WWS2';
   OpenDialog1.FilterIndex := 1;
   OpenDialog1.Options := OpenDialog1.Options - [OfAllowMultiSelect];
   If not OpenDialog1.Execute then Exit;
   tmpStr := OpenDialog1.FileName;
   tmpExt := ExtractFileExt(tmpStr);
   If not VExtension(tmpExt, veBoth) then Exit;
   If (UpperCase(tmpExt) = '.CSS') or (UpperCase(tmpExt) = '.HTML') or (UpperCase(tmpExt) = '.HTM') then
      ImportCSS(tmpStr)
   Else Begin
      // if the document is already opened, we can switch to its page.
      For i := 0 to CAPACITY - 1 do
         If tmpStr = theFile[i].FILE_PATH then Begin // a match
            TabDocuments.TabIndex := i;
            k := True;
            TabDocumentsChanging(Sender, k); // force the two events that don't...
            TabDocumentsChange(Sender);      // happen when TabIndex is manually set.
            Exit;
         End; {Begin/For}
      // if the current file hasn't ever been touched, then we can close it.
      with theFile[CURRENT_FILE] do
         If (NEEDS_SAVE_AS) and (not DIRTY) and (FILE_PATH = 'Document 1') then
            CloseDocument(CURRENT_FILE);
      // load the file
      ReallyOpen(tmpStr);
   End; {if}
   // now erase the default dir, leaving it where the user left it.
   SaveDialog1.InitialDir := '';
   OpenDialog1.InitialDir := '';
   UpdateMenus;
end; {TwEditorMain.cmOpenClick}


{------------------------------------------------------------------------
  TwEditorMain.cmSaveAsClick
   Save the current file as...
    - also responds to the export buttons!
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmSaveAsClick(Sender: TObject);
var tempStr : String;
    tempExt : String;
          i : veSaveType;
begin
   SaveDialog1.Title := 'Save Cascade Document';
   SaveDialog1.Filter := 'HTML Document|*.HTML' +
                         '|Archaic HTM Document|*.HTM' +
                         '|Cascading Style Sheet|*.CSS';
   If (Sender <> cmExportTagged) and (Sender <> cmExportAll) and
      (Sender <> cmExportTagged2) and (Sender <> cmExportAll2) then
         SaveDialog1.Filter := 'Cascade 2.0 Document|*.WWS2'+
                               '|Cascade Stationary|*.WWTD|' +
                               SaveDialog1.Filter;
   // setup default extension/filename
   If (Sender = cmExportTagged) or (Sender = cmExportAll) or
      (Sender = cmExportTagged2) or (Sender = cmExportAll2) then Begin
      SaveDialog1.DefaultExt := 'CSS';
      SaveDialog1.FilterIndex := 3;
      SaveDialog1.FileName := StripFileName(EZFile);
      SaveDialog1.Title := 'Export Cascade Document';
   End Else Begin
      If ExtractFileExt(EZFile) = '.WWTD' then Begin
         SaveDialog1.DefaultExt := 'WWTD';
         SaveDialog1.FilterIndex := 2;
      End Else Begin
         SaveDialog1.DefaultExt := 'WWS2';
         SaveDialog1.FilterIndex := 1;
      End;
      SaveDialog1.FileName := StripFileName(EZFile);
   End; {if}
   If not SaveDialog1.Execute then Exit;
   tempStr := SaveDialog1.FileName;
   tempExt := ExtractFileExt(tempstr);
   // make sure the extension is legal.
   if (Sender = cmExportTagged) or (Sender = cmExportAll) or
      (Sender = cmExportTagged2) or (Sender = cmExportAll2) then
      i := veExport
   else
      i := veBoth;
   If not VExtension(tempExt, i) then Exit;
   // call the saving routines
   If (tempExt = '.WWTD') or (tempExt = '.WWS2') then {Template or Document}
      ReallySave(tempStr);
   {Export the File}
   If (tempExt = '.HTML') or (tempExt = '.CSS') or (tempExt = '.HTM')  then Begin
      If (Sender = cmExportTagged) or (Sender = cmExportTagged2) then
         ExportDocument(tempStr, exSelected)
      else
         ExportDocument(tempStr, exAll);
   End; {if}

   // if saved as Stationary or WSS2 mark as okay, and update filename.
   If (tempExt = '.WWTD') or (tempExt = '.WWS2') then Begin
      theFile[CURRENT_FILE].NEEDS_SAVE_AS := False;
      theFile[CURRENT_FILE].FILE_PATH := tempStr;
   End; {if}
   // if it was a template, then change the flag
   If tempExt = '.WWTD' then
      theFile[CURRENT_FILE].IS_TEMPLATE := True;
   // now erase the default dir, leaving it where the user left it.
   SaveDialog1.InitialDir := '';
   OpenDialog1.InitialDir := '';
   UpdateMenus;
end; {TwEditorMain.cmSaveAsClick}


{------------------------------------------------------------------------
  TwEditorMain.cmSaveClick
   Save the document if it's already named; otherwise, Save As
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmSaveClick(Sender: TObject);
begin
   If theFile[CURRENT_FILE].NEEDS_SAVE_AS then
      cmSaveAsClick(Sender)
   Else Begin
      ReallySave(EZFile);
      UpdateMenus;
   End; {if}
end; {TwEditorMain.cmSaveClick}


{=========================================================================}
{ USER MENU ACTIONS -- edit                                               }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.cmCopyClick
   Copy the current TCSSRecord into the CBOARD. Put a textual represent-
   ation of it in the system clipboard.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmCopyClick(Sender: TObject);
var i,j : Integer;
begin
   CBOARD.Free;
   if theTree.Selected = nil then Exit;
   CBOARD := TCSSRecord.Create(nil);
   CBOARD.Assign(TCSSRecord(theTree.Selected.Data));   // copy to CBOARD
   UpdateMenus;
   { now, put text on the clipboard }
   pageForm.PreviewUpdate(nil);
   i := Memo1.SelStart;
   j := Memo1.SelLength;
   Memo1.SelectAll;
   Memo1.CopyToClipBoard;
   Memo1.SelStart := i;
   Memo1.SelLength := j;
end; {TwEditorMain.cmCopyClick}


{------------------------------------------------------------------------
  TwEditorMain.cmCutClick
   Cut the current class into the clipboard.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmCutClick(Sender: TObject);
begin
   cmCopyClick(Sender);
   cmDeleteClick(Sender);
end; {TwEditorMain.cmCutClick}


{------------------------------------------------------------------------
  TwEditorMain.cmDeleteClick
   Delete the current class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmDeleteClick(Sender: TObject);
begin
   If theTree.Selected = nil then Exit;
   // confirm delete, if necessary
   if thePrefs.CONFIRM_DELETE then
      if MessageDlg(Format(UsedStrings[21],[theTree.Selected.Text]),
         mtConfirmation, [mbYes,mbNo], 0) = mrNo then Exit;
   // delete the item
   theTree.Selected.Delete;
   pageForm.PreviewUpdate(nil);
   if theTree.Selected <> nil then
      pageForm.RecallPageData
   else
      pageForm.TurnOffPage;
   MarkDirty(True);
   UpdateMenus;
end; {TwEditorMain.cmDeleteClick}


{------------------------------------------------------------------------
  TwEditorMain.cmPasteClick
   Paste into a new class. Copying ONLY the CSS2, and creating EXPERT.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmPasteClick(Sender: TObject);
var theType : TCSSRecordType;
begin
  if CBOARD = nil then Exit;
  InputDLOG.TextMask.AllowedChars := CharsUpper + CharsLower + CharsNumbers + CharsExpert;
  InputDLOG.TextMask.ForceCaps := False;
  InputDLOG.TextMask.MaxLength := 64;
  InputDLOG.Title := UsedStrings[19];
  InputDLOG.Prompt := UsedStrings[20];
  InputDLOG.Text := CBOARD.Selector;
  theType := CBOARD.RecordType;
  While ClassExists(InputDLOG.Text) do Begin
     If not InputDLOG.Execute then Exit;
     theType := rtCustom;
  end; {while}
  { at this point, let's create the class, and add it to the end of theTree}
  AppendNewClass(InputDLOG.Text, theType);
  { the new item is now selected -- let's copy the clipboard data to it }
  TCSSRecord(theTree.Selected.Data).Duplicate(CBOARD);
  pageForm.RecallPageData;
  pageForm.PreviewUpdate(nil);
  MarkDirty(True);
  UpdateMenus;
end; {TwEditorMain.cmPasteClick}


{------------------------------------------------------------------------
  TwEditorMain.cmPreferencesClick
   Open the preferences panel
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmPreferencesClick(Sender: TObject);
var myWin : TwPreferences;
begin
   myWin := TwPreferences.Create(Application);
   myWin.ShowModal;
   WritePreferences;
   // recall the page, if applicable, to update prefs' appearances
   if theTree.Selected <> nil then Begin
      pageForm.RecallPageData;
      pageForm.PreviewUpdate(nil);
   end; {if}
end; {TwEditorMain.cmPreferencesClick}


{------------------------------------------------------------------------
  TwEditorMain.cmRenameClick
   Rename an existing class name
     o we pay attention to the type.
     o if the user held Ctrl when using the menu, change to expert mode
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmRenameClick(Sender: TObject);
var myOld1 : String; {first part of old selector}
    myOld2 : String; {second part of old selector}
    myOld3 : String; {third part of old selector}
    i,j    : integer;
    myDLOG : TwMediaEditor;
    tmpStr : String;
begin
   // Handle @media descriptors first
   If (TCSSRecord(theTree.Selected.Data).RecordType = rtMedia) then Begin
      myDLOG := TwMediaEditor.Create(Application);
      myDLOG.LabelPreview.Caption := theTree.Selected.Text;
      i := myDLOG.ShowModal;
      tmpStr := myDLOG.LabelPreview.Caption;
      myDLOG.Free;
      If i <> mrOK then Exit;
   End {if} Else Begin
   // Handle everything else other than @media
      myOld1 := ''; myOld2 := ''; myOld3 := '';
      with TCSSRecord(theTree.Selected.Data) do Begin
     {---------------------------------------}
     { first, save the complete old selector }
     {---------------------------------------}
        // if we're a rtElement or rtCustom, save nothing
        if (RecordType in [rtElement, rtCustom]) or (EXPERT_R) then
           myOld2 := Selector;
        // if we're a rtClass or rtSubClass, save everything up until .
        if RecordType in [rtClass, rtSubClass] then Begin
           i := Pos('.', Selector);
           myOld1 := Copy(Selector, 1, i);
           myOld2 := Copy(Selector, i+1, Length(Selector) - i);
        End;
        // if we're a rtPseudo, save everything after :
        if RecordType in [rtPseudoClass] then Begin
           i := Pos(':', Selector);
           myOld2 := Copy(Selector, 1, i-1);
           myOld3 := Copy(Selector, i, Length(Selector) - 1);
        end;
        // if we're a rtContext, save everything up to the space
        if RecordType in [rtContextual] then Begin
           i := Pos(' ', Selector);
           myOld1 := Copy(Selector, 1, i);
           myOld2 := Copy(Selector, i+1, Length(Selector) - i);
        end;
        // if we're a rtID. save the #
        if RecordType in [rtID] then Begin
           myOld1 := '#';
           myOld2 := Copy(Selector, 2, Length(Selector)-1);
        end;
        // if we're a rtSubPseudo, save everything up until . and after :
        if RecordType in [rtSubPseudo] then Begin
           i := Pos('.', Selector);
           j := Pos(':', Selector);
           myOld1 := Copy(Selector, 1, i);
           myOld2 := Copy(Selector, i+1, j-i);
           myOld3 := Copy(Selector, j, Length(Selector) - j);
        end;
        {--------------------------------------}
        {set up the dialog allowable characters}
        {--------------------------------------}
        InputDLOG.TextMask.AllowedChars := CharsNumbers + CharsUpper + CharsLower;
        If (RecordType = rtCustom) or (EXPERT_R) then
           InputDLOG.TextMask.AllowedChars := InputDLOG.TextMask.AllowedChars + CharsExpert;
        {---------------------------------------}
        {set up the maximum allowable characters}
        {---------------------------------------}
        InputDLOG.TextMask.MaxLength := 64 - (Length(myOld1) + Length(myOld3));
        {----------------------------}
        {set up forced capitalization}
        {----------------------------}
        InputDLOG.TextMask.ForceCaps := (RecordType = rtElement);
        If EXPERT_R then InputDLOG.TextMask.ForceCaps := False;
      end; {with}

     { set up the prompts. }
     InputDLOG.Title := UsedStrings[7];
     InputDLOG.Prompt := UsedStrings[8];
     InputDLOG.Text := myOld2;

     If not InputDLOG.Execute then Exit; // exit if the user cancelled
     { prefix the saved items }
     tmpStr := myOld1 + InputDLOG.Text + myOld3;
   End; {if, from way above -- now is the common items change items}

   { make sure it doesn't exist! }
   If ClassExists(tmpStr) then Begin
      MessageDlg(Format(UsedStrings[6], [tmpStr]), mtError, [mbOK], 0);
      Exit;
   End; {if}
   { at this point, let's rename the class, and change the name in the tree.}
   TCSSRecord(theTree.Selected.Data).Selector := tmpStr;
   If EXPERT_R then
      TCSSRecord(theTree.Selected.Data).RecordType := rtCustom;
   theTree.Selected.Text := tmpStr;
   MarkDirty(True);
   UpdateMenus;
   EXPERT_R := False;
end; {TwEditorMain.cmRenameClick}


{=========================================================================}
{ USER MENU ACTIONS -- view                                               }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.cmShowClassesDetachedClick
   Toggle Shortcut visibility
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmShowClassesDetachedClick(Sender: TObject);
begin
   cmShowClassesDetached.Checked := not cmShowClassesDetached.Checked;
   If cmShowClassesDetached.Checked then
      DetachAPanel(Image1)
   Else
      TreeWin.theWin.Close;
end; {TwEditorMain.cmShowClassesDetachedClick}


{------------------------------------------------------------------------
  TwEditorMain.cmShowCodeDetachedClick
   Toggle Shortcut visibility
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmShowCodeDetachedClick(Sender: TObject);
begin
   cmShowCodeDetached.Checked := not cmShowCodeDetached.Checked;
   If cmShowCodeDetached.Checked then
      Begin
         Memo1.ScrollBars := ssBoth;
         DetachAPanel(Image2);
      End
   Else
      Begin
         Memo1.ScrollBars := ssNone;
         PreviewWin.theWin.Close;
      End;
end; {TwEditorMain.cmShowCodeDetachedClick}


{------------------------------------------------------------------------
  TwEditorMain.cmShowShortcutsClick
   Toggle Shortcut visibility
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmShowShortcutsClick(Sender: TObject);
begin
   PanelShortcuts.Visible := not PanelShortcuts.Visible;
   cmShowShortcuts.Checked := PanelShortcuts.Visible;
end; {TwEditorMain.cmShowShortcutsClick}


{=========================================================================}
{ USER MENU ACTIONS -- classes                                            }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.TwEditorMain.cmContextClassClick
   Create a contextual class of the currently selected class
    o Get the user input.
    o Append anything that needs to be added.
    o Call AppendNewClass to add the class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmContextClassClick(Sender: TObject);
begin
  InputDLOG.TextMask.AllowedChars := CharsUpper + CharsLower + CharsNumbers;
  InputDLOG.TextMask.ForceCaps := True;
  InputDLOG.TextMask.MaxLength := 63 - Length(theTree.Selected.Text);
  InputDLOG.Title := Format(UsedStrings[11], [theTree.Selected.Text]);
  InputDLOG.Prompt := Format(UsedStrings[12], [theTree.Selected.Text]);
  InputDLOG.Text := '';
  If not InputDLOG.Execute then Exit; // exit if the user cancelled
  { prefix the contexual selector to the beginning }
  InputDLOG.Text := theTree.Selected.Text + #32 + InputDLOG.Text;
  { at this point, let's create the class, and add it to the end of theTree}
  AppendNewClass(InputDLOG.Text, rtContextual);
end; {TwEditorMain.cmContextClassClick}


{------------------------------------------------------------------------
  TwEditorMain.cmExpertSelectorClick
   Allow the user to type his own complete selector
    o Get the user input.
    o Append anything that needs to be added.
    o Call AppendNewClass to add the class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmExpertSelectorClick(Sender: TObject);
begin
  InputDLOG.TextMask.AllowedChars := CharsUpper + CharsLower + CharsNumbers + CharsExpert;
  InputDLOG.TextMask.ForceCaps := False;
  InputDLOG.TextMask.MaxLength := 64;
  InputDLOG.Title := UsedStrings[15];
  InputDLOG.Prompt := UsedStrings[16];
  InputDLOG.Text := '';
  If not InputDLOG.Execute then Exit; // exit if the user cancelled
  { at this point, let's create the class, and add it to the end of theTree}
  AppendNewClass(InputDLOG.Text, rtCustom);
end; {TwEditorMain.cmExpertSelectorClick}


{------------------------------------------------------------------------
  TwEditorMain.cmMediaTypeClick
   Create a new Media Type
    o Open the media-type creator
    o Create a dummy record
    o Call AppendNewClass to add the "class"
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmMediaTypeClick(Sender: TObject);
var myForm : TwMediaEditor;
begin
   myForm := TwMediaEditor.Create(Application);
   If myForm.ShowModal = mrOk then Begin
      // add the class
      AppendNewClass(myForm.LabelPreview.Caption, rtMedia);
   End; {if}
   myForm.Free;
end; {TwEditorMain.cmMediaTypeClick}


{------------------------------------------------------------------------
  TwEditorMain.cmNewClassClick
   Create a new CLASS
    o Get the user input.
    o Append anything that needs to be added.
    o Call AppendNewClass to add the class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmNewClassClick(Sender: TObject);
begin
  { ask the user for the new CLASS name }
  InputDLOG.TextMask.AllowedChars := CharsUpper + CharsLower + CharsNumbers;
  InputDLOG.TextMask.ForceCaps := False;
  InputDLOG.TextMask.MaxLength := 63;
  InputDLOG.Title := UsedStrings[4];
  InputDLOG.Prompt := UsedStrings[5];
  InputDLOG.Text := '';
  If not InputDLOG.Execute then Exit; // exit if the user cancelled
  { prefix the period to the beginning }
  InputDLOG.Text := '.' + InputDLOG.Text;
  { at this point, let's create the class, and add it to the end of theTree}
  AppendNewClass(InputDLOG.Text, rtClass);
end; {TwEditorMain.cmNewClassClick}


{------------------------------------------------------------------------
  TwEditorMain.cmNewElementClick
   Create a new ELEMENT
    o Get the user input.
    o Append anything that needs to be added.
    o Call AppendNewClass to add the class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmNewElementClick(Sender: TObject);
var i : Integer;
begin
  { Set up the dialog }
  with SelectDLOG do Begin
     with EditorTextMask do Begin
        ForceCaps := True;
        AllowedChars := CharsUpper + '123456';
        MaxLength := 64;
     end; {inner with}
     Title := UsedStrings[1];
     Prompt := UsedStrings[2];
     ListItems.Clear;
     For i := 1 to High(Elements) do ListItems.Add(Elements[i]);
     ItemIndex := 0;
     ItemKey := REGISTRY_KEY + '\ElementList';
  End; {with}
  If not SelectDLOG.Execute then Exit; // exit if the user cancelled
  { at this point, let's create the class, and add it to the end of theTree}
  AppendNewClass(SelectDLOG.ItemValue, rtElement);
end; {TwEditorMain.cmNewElementClick}


{------------------------------------------------------------------------
  TwEditorMain.cmNewIDClick
   Create a new CLASS
    o Get the user input.
    o Append anything that needs to be added.
    o Call AppendNewClass to add the class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmNewIDClick(Sender: TObject);
begin
  { ask the user for the new ID name }
  InputDLOG.TextMask.AllowedChars := CharsUpper + CharsLower + CharsNumbers;
  InputDLOG.TextMask.ForceCaps := False;
  InputDLOG.TextMask.MaxLength := 63;
  InputDLOG.Title := UsedStrings[9];
  InputDLOG.Prompt := UsedStrings[10];
  InputDLOG.Text := '';
  If not InputDLOG.Execute then Exit; // exit if the user cancelled
  { prefix the pound to the beginning }
  InputDLOG.Text := '#' + InputDLOG.Text;
  { at this point, let's create the class, and add it to the end of theTree}
  AppendNewClass(InputDLOG.Text, rtID);
end; {TwEditorMain.cmNewIDClick}


{------------------------------------------------------------------------
  TwEditorMain.cmPseudoClassClick
   create a pseudo-class or pseudo-element.
    o Get the user input.
    o Append anything that needs to be added.
    o Call AppendNewClass to add the class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmPseudoClassClick(Sender: TObject);
var myTxt : String;
        i : Integer;
begin
  { Set up the dialog }
  with SelectDLOG do Begin
     with EditorTextMask do Begin
        ForceCaps := False;
        AllowedChars := CharsUpper + CharsLower + CharsNumbers + CharsExpert;
        MaxLength := 64;
     end; {inner with}
     Title := UsedStrings[17];
     Prompt := Format(UsedStrings[18], [theTree.Selected.Text]);
     ListItems.Clear;
     For i := 1 to High(Pseudos) do ListItems.Add(Pseudos[i]);
     ItemIndex := 0;
     ItemKey := REGISTRY_KEY + '\PseudoList';
  End; {with}
  If not SelectDLOG.Execute then Exit; // exit if the user cancelled
  { at this point, let's create the class, and add it to the end of theTree}
  myTxt := theTree.Selected.Text + SelectDLOG.ItemValue;
  { at this point, let's create the class, and add it to the end of theTree}
  If TCSSRecord(theTree.Selected.Data).RecordType = rtSubclass then
     AppendNewClass(myTxt, rtSubPseudo)
  Else
     AppendNewClass(myTxt, rtPseudoClass);
end; {TwEditorMain.cmPseudoClassClick}


{------------------------------------------------------------------------
  TwEditorMain.cmSubClassClick
   Create a subclass of the currently selected class
    o Get the user input.
    o Append anything that needs to be added.
    o Call AppendNewClass to add the class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmSubClassClick(Sender: TObject);
begin
  InputDLOG.TextMask.AllowedChars := CharsUpper + CharsLower + CharsNumbers;
  InputDLOG.TextMask.ForceCaps := False;
  InputDLOG.TextMask.MaxLength := 63 - Length(theTree.Selected.Text);
  InputDLOG.Title := Format(UsedStrings[13], [theTree.Selected.Text]);
  InputDLOG.Prompt := Format(UsedStrings[14], [theTree.Selected.Text]);
  InputDLOG.Text := '';
  If not InputDLOG.Execute then Exit; // exit if the user cancelled
  { prefix the element selector to the beginning }
  InputDLOG.Text := theTree.Selected.Text + #46 + InputDLOG.Text;
  { at this point, let's create the class, and add it to the end of theTree}
  AppendNewClass(InputDLOG.Text, rtSubClass);
end; {TwEditorMain.cmSubClassClick}


{=========================================================================}
{ USER MENU ACTIONS -- tools                                              }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.cmApplyClick
   Apply the current stylesheet to any HTML file(s) the user wishes.
   o Let the user pick files.
   o Ask the user the server file path to the css file he wants.
   o Parse the HTML file, and re-save it.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmApplyClick(Sender: TObject);
var tmpStr : String;
    tmpExt : String;
         i : Integer;
    CSSNam : String;
    SrcFil : PChar;
    DstFil : PChar;
begin
   // set up the file open dialogue
   OpenDialog1.Title := 'Apply stylesheets to HTML files you choose';
   OpenDialog1.Filter := 'HTML File (*.HTML or *.HTM)|*.HTML;*.HTM';
   OpenDialog1.DefaultExt := '';
   OpenDialog1.FilterIndex := 1;
   OpenDialog1.Options := OpenDialog1.Options + [ofAllowMultiSelect];
   If not OpenDialog1.Execute then Exit;
   // ask the user for the name of the CSS file.
   If OpenDialog1.Files.Count > 1 then
      tmpExt := Format(UsedStrings[27], ['these HTML documents'])
   else
      tmpExt := Format(UsedStrings[27], ['this HTML document']);
   CSSNam := ChangeFileExt(ExtractFileName(EZFile), '') + '.css';
   InputDLOG.TextMask.AllowedChars := '';
   InputDLOG.TextMask.ForceCaps := False;
   InputDLOG.TextMask.MaxLength := 64;
   InputDLOG.Prompt := tmpExt;
   InputDLOG.Text := CSSNam;
   InputDLOG.Title := UsedStrings[26];
   If not InputDLOG.Execute then Exit;
   CSSNam := InputDLOG.Text;
   // iterate through all the files the user selected
   for i := 0 to OpenDialog1.Files.Count - 1 do begin
      // get the user's files of choice
      tmpStr := ExtractFileName(OpenDialog1.Files[i]);
      If not FileExists(tmpStr) then Break;
      // parse the HTML file
      ParseHTML(tmpStr, CSSNam);
      // copy the tempHTML back to the original
      GetMem(SrcFil, Length(TEMP_DIR + tempHTML) + 1);
      GetMem(DstFil, Length(tmpStr) + 1);
      StrPCopy(SrcFil, TEMP_DIR + tempHTML);
      StrPCopy(DstFil, tmpStr);
      CopyFile(SrcFil, DstFil, False);
      FreeMem(SrcFil);
      FreeMem(DstFil);
   End; {for}
   // clean up
   SaveDialog1.InitialDir := '';
   OpenDialog1.InitialDir := '';
end; {TwEditorMain.cmApplyClick}


{=========================================================================}
{ USER MENU ACTIONS -- help                                               }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.cmAboutClick
   Show the about box.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmAboutClick(Sender: TObject);
var AboutWin : TwAboutMe;
begin
   AboutWin := TwAboutMe.Create(Application);
   AboutWin.ShowModal;
   AboutWin.Free;
end; {TwEditorMain.cmAboutClick}


{------------------------------------------------------------------------
  TwEditorMain.cmHelpClick
    Start normal help.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmHelpClick(Sender: TObject);
begin
   Application.HelpContext(HELP_CONTEXT);
end; {TwEditorMain.cmHelpClick}


{=========================================================================}
{ USER MENU ACTIONS -- contexts not in main menu                          }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.cmCopyAllClick
   Copy the all the text into the system clipboard.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmCopyAllClick(Sender: TObject);
var i,j : Integer;
begin
   i := Memo1.SelStart;
   j := Memo1.SelLength;
   Memo1.SelectAll;
   Memo1.CopyToClipBoard;
   Memo1.SelStart := i;
   Memo1.SelLength := j;
end; {TwEditorMain.cmCopyAllClick}


{------------------------------------------------------------------------
  TwEditorMain.cmCopySelectedClick
   Copy the text the user has selected into the system clipboard.
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmCopySelectedClick(Sender: TObject);
begin
   Memo1.CopyToClipBoard;
end; {TwEditorMain.cmCopySelectedClick}


{------------------------------------------------------------------------
  TwEditorMain.cmPaste1Click
   Paste OVER the currently selected class. Copying ONLY the CSS2!!!!
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmPaste1Click(Sender: TObject);
begin
   if (theTree.Selected = nil) or (CBOARD = nil) then Exit;
   TCSSRecord(theTree.Selected.Data).Duplicate(CBOARD);
   pageForm.RecallPageData;
   pageForm.PreviewUpdate(nil);
   MarkDirty(True);
   UpdateMenus;
end; {TwEditorMain.cmPaste1Click}


{------------------------------------------------------------------------
  TwEditorMain.cmPreviewClick
   Change the preview mode
 ------------------------------------------------------------------------}
procedure TwEditorMain.cmPreviewClick(Sender: TObject);
var theText : TStringList;
    myDoc   : TCascadeDocument;
begin
   // do the preview
   theText := TStringList.Create;
   If (Sender = cmPreviewAll) or (Sender = cmPreviewTagged) then Begin
      myDoc := TCascadeDocument.Create(Application);
      myDoc.GetFromTree(theTree);
      myDoc.GetCSS(theText, thePrefs.SINGLE_QUOTES, (Sender = cmPreviewTagged));
      myDoc.Free;
   End;

   If (Sender <> cmPreviewTagged) and (Sender <> cmPreviewAll) then Begin
      if theTree.Selected = nil then
         theText.Text := 'Nothing Selected'
      else
         TCSSRecord(theTree.Selected.Data).GetCSS(theText, thePrefs.SINGLE_QUOTES);
   End;
   Memo1.Lines.Assign(theText);
   theText.Free;
end; {TwEditorMain.cmPreviewClick}


{=========================================================================}
{ PAGE/DOCUMENT/CLASS SWITCHING                                           }
{=========================================================================}


{-------------------------------------------------------------------------
  TwEditorMain.PageControl1Change
    o Turn to the new page.
 -------------------------------------------------------------------------}
procedure TwEditorMain.PageControl1Change(Sender: TObject);
begin
   ShowPage(PageControl1.ActivePage.Tag);
end; {TwEditorMain.PageControl1Change}


{------------------------------------------------------------------------
  TwEditorMain.TabDocumentsChange
   save the current tree's document to a temp file
    - called any time a new page is selected
      o If there *is no* file we are chaning to, do nothing.
      o Make the CURRENT_FILE equal to the new tab-page
      o Create a temporary document
      o Load it from the disk temporary file.
      o Put it into the tree.
      o Restore the settings
      o Update the display.
      o Make the hint reflect the entire file path.
 ------------------------------------------------------------------------}
procedure TwEditorMain.TabDocumentsChange(Sender: TObject);
var myDoc : TCascadeDocument;
   tmpStr : String;
begin
   // update the local variables...
   CURRENT_FILE := TabDocuments.TabIndex;
   If CURRENT_FILE = -1 then Exit;
   // create a temporary document.
   myDoc := TCascadeDocument.Create(nil);
   // load it from the temporary file.
   tmpStr := StripFileName(EZFile) + '.WWST';
   myDoc.OpenDocument(TEMP_DIR + tmpStr);
   // put it into the tree
   myDoc.PutIntoTree(theTree);
   myDoc.Free;
   EmboldenTree;
   // select the correct, saved node.
   with theFile[CURRENT_FILE] do
      if TREE_POS <> -1 then
         theTree.Selected := theTree.Items[TREE_POS]
      else Begin
         theTree.Selected := Nil;
         pageForm.TurnOffPage;
      end; {if/with}
   // update the menus
   UpdateMenus;
   pageForm.PreviewUpdate(nil);
end; {TwEditorMain.TabDocumentsChange}


{------------------------------------------------------------------------
  TwEditorMain.TabDocumentsChanging
   save the current tree's document to a temp file
   - called any time we are about to change from one document.
    o If there is nothing to change *from* then only clear the tree.
    o Remember theTree.Selected.Index.
    o Create a temporary document.
    o Save it to disk.
    o Clear theTree.
 ------------------------------------------------------------------------}
procedure TwEditorMain.TabDocumentsChanging(Sender: TObject; var AllowChange: Boolean);
var myDoc : TCascadeDocument;
    tmpStr : String;
begin
   {if there is a document to change from, then do these:}
   If CURRENT_FILE >= 0 then Begin
      // remember theTree position
      theFile[CURRENT_FILE].TREE_POS := theTree.Selected.Index;
      // create a temporary document
      myDoc := TCascadeDocument.Create(nil);
      myDoc.GetFromTree(theTree);
      // save the temporary document to disk
      tmpStr := StripFileName(EZFile) + '.WWST';
      myDoc.SaveDocument(TEMP_DIR + tmpStr);
      myDoc.Free;
   End; {if}
   ClearTheTree;
end; {TwEditorMain.TabDocumentsChanging}


{-------------------------------------------------------------------------
  TwEditorMain.theTreeChange
     o Recall the new items's page data, and enable the page.
     o Call UpdateMenus to reflect the new selection.
     o Update the Preview with a call to PreviewUpdate.
 -------------------------------------------------------------------------}
procedure TwEditorMain.theTreeChange(Sender: TObject; Node: TTreeNode);
begin
   {some things to do only if something's selected}
   if theTree.Selected <> nil then
      // enable the current page and recall its data
      If TCSSRecord(theTree.Selected.Data).RecordType <> rtMedia then Begin
         pageForm.RecallPageData;
         pageForm.EnablePage;
      End {Begin} Else
         pageForm.TurnOffPage;
   {update the menus to reflect the current selected item, if any}
   UpdateMenus;
   {update the preview}
   //pageForm.PreviewUpdate(nil);
   if Node <> nil then pageForm.Enablements(nil);
end; {TwEditorMain.theTreeChange}


{-------------------------------------------------------------------------
  TwEditorMain.theTreeChanging
     o Turn off the current page's content (which saves data)
 -------------------------------------------------------------------------}
procedure TwEditorMain.theTreeChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
   If theTree.Selected <> nil then Begin
   pageForm.TurnOffPage;
   End;
end; {TwEditorMain.theTreeChanging}


{=========================================================================}
{ DRAGGING, NOT INCLUDING DETACHABLE ITEMS                                }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.TabDocumentsDragDrop
   The user is dropping a class on a tab to duplicate the class in the
   current document, or in another open document. We need to do these:
    o Make a copy of the source item in the auxilliary clipboard.
    o Simulate a click on the TabDocuments to switch to the new page.
    o Get a name from the user, if required.
    o Put in the class.
 ------------------------------------------------------------------------}
procedure TwEditorMain.TabDocumentsDragDrop(Sender, Source: TObject; X, Y: Integer);
var theMess : TMessage;
    theType : TCSSRecordType;
begin
   {copy the source item}
   CBOARD2.Free;
   if theTree.Selected = nil then Exit;
   CBOARD2 := TCSSRecord.Create(nil);
   CBOARD2.Assign(TCSSRecord(theTree.Selected.Data));   // copy to CBOARD2
   {select the destination page by simulating a click}
   with theMess do Begin
      WParam := 0;
      LParamLo := X;
      LParamHi := Y;
      SendMessage(TabDocuments.Handle, WM_LBUTTONDOWN, WParam, LParam);
      SendMessage(TabDocuments.Handle, WM_LBUTTONUP, WParam, LParam);
   end;
   {the new page is now showing... ask the user what to do.}
   InputDLOG.TextMask.AllowedChars := CharsUpper + CharsLower + CharsNumbers + CharsExpert;
   InputDLOG.TextMask.ForceCaps := False;
   InputDLOG.TextMask.MaxLength := 64;
   InputDLOG.Title := UsedStrings[24];
   InputDLOG.Prompt := UsedStrings[25];
   InputDLOG.Text := CBOARD2.Selector;
   theType := CBOARD2.RecordType;
   While ClassExists(InputDLOG.Text) do Begin
      If not InputDLOG.Execute then Exit;
      theType := rtCustom;
   end; {while}
   { at this point, let's create the class, and add it to the end of theTree}
   AppendNewClass(InputDLOG.Text, theType);
   { the new item is now selected -- let's copy the clipboard data to it }
   TCSSRecord(theTree.Selected.Data).Duplicate(CBOARD2);
   pageForm.RecallPageData;
   pageForm.PreviewUpdate(nil);
   MarkDirty(True);
   UpdateMenus;
end; {TwEditorMain.TabDocumentsDragDrop}


{------------------------------------------------------------------------
  TwEditorMain.TabDocumentsDragOver
   If the user is attempting to drag a class over the tabset, let him.
 ------------------------------------------------------------------------}
procedure TwEditorMain.TabDocumentsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   If (Source = theTree) then Accept := True;
end; {TwEditorMain.TabDocumentsDragOver}


{------------------------------------------------------------------------
  TwEditorMain.theTreeDragDrop
   Drop the dragged item (reorder the list)
 ------------------------------------------------------------------------}
procedure TwEditorMain.theTreeDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var theDest : TTreeNode;
begin
   { which list item got dropped upon? }
   If theTree.GetNodeAt(X,Y) = nil then exit;
   theDest := theTree.GetNodeAT(X,Y); // inserted *after* this
   theTree.Selected.MoveTo(theDest, naInsert); // insert on top of
   { embolden properly }
   theTree.SetItemBold(theTree.Selected, TCSSRecord(theTree.Selected.Data).IsTagged);
   MarkDirty(True);
end; {TwEditorMain.theTreeDragDrop}


{------------------------------------------------------------------------
  TwEditorMain.theTreeDragOver
   If the item being dragged is the tree itself, then accept it.
 ------------------------------------------------------------------------}
procedure TwEditorMain.theTreeDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   If Source = theTree then Accept := True;
end; {TwEditorMain.theTreeDragOver}


{=========================================================================}
{ POPUP ROUTINES, NOT INCLUDING THE INITIATION OF ACTIONS                 }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.PopupPreviewPopup
   Hide or show the copy items in the preview popup menu.
 ------------------------------------------------------------------------}
procedure TwEditorMain.PopupPreviewPopup(Sender: TObject);
begin
   {Hide or show the copy items in the preview popup menu.}
   cmDivider8.Visible := PopupPreview.PopupComponent = Memo1;
   cmCopyAll.Visible := PopupPreview.PopupComponent = Memo1;
   cmCopySelected.Visible := (PopupPreview.PopupComponent = Memo1) and
                             (Memo1.SelLength > 0);
end; {TwEditorMain.PopupPreviewPopup}


{------------------------------------------------------------------------
  TwEditorMain.PopupTreePopup
   Popup the menu over the TreeView.
    o if nothing is selected, disable all items.
    o if EXPERT_R then Rename the cmRename1.
 ------------------------------------------------------------------------}
procedure TwEditorMain.PopupTreePopup(Sender: TObject);
var i : Integer;
begin
  { if nothing is selected, disable all items }
  if theTree.Selected = nil then
     with PopupTree do
        for i := 0 to Items.Count - 1 do
           Items[i].Enabled := False;
  { if EXPERT_R then rename the cmRename1}
  if EXPERT_R then
     cmRename1.Caption := 'Expert Rename...'
  else
     cmRename1.Caption := 'Rename...';
end; {TwEditorMain.PopupTreePopup}


{------------------------------------------------------------------------
  TwEditorMain.theTreeMouseDown
   Select the item being right-clicked before the menu activates.
 ------------------------------------------------------------------------}
procedure TwEditorMain.theTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   EXPERT_R := ((ssCtrl in Shift) and (Button = mbRight));
   If Button = mbRight then
      If theTree.GetNodeAt(X,Y) <> nil then
         theTree.Selected := theTree.GetNodeAT(X,Y)
      else
         theTree.Selected := nil;
end; {TwEditorMain.theTreeMouseDown}


{=========================================================================}
{ MISCELLANEOUS EVENT_DRIVEN ROUTINES                                     }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.AttachAPanel
    Handle the closing of a window to re-attach it to the main window.
 ------------------------------------------------------------------------}
procedure TwEditorMain.AttachAPanel(Sender: TObject; var Action: TCloseAction);
var myRec : TDetachRecord;
    myPane : TPanel;
begin
   // who are we reattaching?
   If TForm(Sender).Tag = 1 then Begin
      myRec := TreeWin;
      myPane := PanelTree;
   End Else Begin
      myRec := PreviewWin;
      myPane := PanelPreview;
   End; {if}
   // remember the user's window size, position; and hide it
   myRec.NewDims.Top := myRec.theWin.Top;
   myRec.NewDims.Left := myRec.theWin.Left;
   myRec.NewDims.Bottom := myRec.theWin.ClientHeight;
   myRec.NewDims.Right := myRec.theWin.ClientWidth;
   myRec.theWin.Hide;
   // restore the panel settings
   If myRec.theWin.Tag = 1 then
      myPane.Align := alLeft
   Else
      myPane.Align := alRight;
   myPane.AutoSize := False;
   myPane.Top := myRec.OrigDims.Top;
   myPane.Left := myRec.OrigDims.Left;
   myPane.Height := myRec.OrigDims.Bottom;
   myPane.Width := myRec.OrigDims.Right;
   myPane.AutoSize := True;
   If myRec.theWin.Tag = 1 then
      Image1.Visible := True
   Else
      Image2.Visible := True;
   myPane.Parent := wEditorMain;
   // free the form
   myRec.theWin.Free;
   // Save the record
   If TForm(Sender).Tag = 1 then
      TreeWin := myRec
   Else
      PreviewWin := myRec;
   // force update the display
   If TForm(Sender).Tag = 1 then DoBoldTree;
   SendMessage(handle, WM_SIZE, 0, 0);
   if TForm(Sender).Tag <> 1 then Memo1.ScrollBars := ssNone;
end; {TwEditorMain.AttachAPanel}


{------------------------------------------------------------------------
  TwEditorMain.ControlBar1Resize
    Force the window to resize after certain elements are detached.
 ------------------------------------------------------------------------}
procedure TwEditorMain.ControlBar1Resize(Sender: TObject);
begin
   SendMessage(handle, WM_SIZE, 0, 0);
end; {TwEditorMain.ControlBar1Resize}


{------------------------------------------------------------------------
  TwEditorMain.DetachAPanel
    Detach the Class List or the Code Preview Window.
 ------------------------------------------------------------------------}
procedure TwEditorMain.DetachAPanel(Sender: TObject);
var myRec : TDetachRecord;
    myPane : TPanel;
begin
   // who are we detaching?
   If Sender = Image1 then Begin
      myRec := TreeWin;
      myPane := PanelTree;
   End Else Begin
      myRec := PreviewWin;
      myPane := PanelPreview;
   End; {if}
   // create the form
   myRec.theWin := TForm.Create(Self);
   myRec.theWin.Parent := nil;
   myRec.theWin.BorderStyle := bsSizeToolWin;
   // save old points
   myRec.OrigDims.Top := myPane.Top;
   myRec.OrigDims.Left := myPane.Left;
   myRec.OrigDims.Bottom := myPane.Height;
   myRec.OrigDims.Right := myPane.Width;
   // process initial left position
   If myRec.NewDims.Left = -1 then Begin
   If Sender = Image1 then
      myRec.NewDims.Left := Left - myRec.NewDims.Right
   Else
      myRec.NewDims.Left := Left + Width - 200;
   End; {if}
   // set window position
   with myRec do Begin
      theWin.Top := NewDims.Top;
      theWin.Left := NewDims.Left;
      theWin.ClientHeight := NewDims.Bottom;
      theWin.ClientWidth := NewDims.Right;
      theWin.FormStyle := fsStayOnTop;
      theWin.KeyPreview := True;
      theWin.onKeyDown := DetachedKeyPress;
      theWin.OnClose := AttachAPanel;
   End; {with}
   // finalize the form display
   If Sender = Image1 then Begin
      myRec.theWin.Caption := 'Class List';
      myRec.theWin.Tag := 1;
      Image1.Visible := False;
   End Else Begin
      myRec.theWin.Caption := 'Code Preview Pane';
      myRec.theWin.Tag := 2;
      Image2.Visible := False;
   End; {if}
   // move the pane to the window, and show it.
   myPane.Parent := myRec.theWin;
   myPane.Align := alClient;
   myRec.theWin.Show;
   // Save the record
   If Sender = Image1 then
      TreeWin := myRec
   Else
      PreviewWin := myRec;
   // Embolden properly theTree
   DoBoldTree;
   // force update the display
   ClientWidth := 0;
   if Sender = Image2 then Memo1.ScrollBars := ssBoth;
end; {TwEditorMain.DetachAPanel}


{------------------------------------------------------------------------
  TwEditorMain.FormKeyDown
   Respond to Ctrl-F4 as an alternate to Ctrl-W for closing things.
 ------------------------------------------------------------------------}
procedure TwEditorMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   If (Key = 115) and (ssCtrl in Shift) and (cmClose.Enabled) then
      cmCloseClick(nil);
   If (Key = 112) and (ssShift in Shift) then
      Shortcut10.Click;
end; {TwEditorMain.FormKeyDown}


{------------------------------------------------------------------------
  TwEditorMain.FormKeyPress
   Respond to Ctrl-N to set something USE_WWTD to False.
 ------------------------------------------------------------------------}
procedure TwEditorMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
   If Key = #14 then begin
      USE_WWTD := False;
      cmNewClick(Sender);
   End;
end; {TwEditorMain.FormKeyPress}


{------------------------------------------------------------------------
  TwEditorMain.mMenu1Click
   Force the FILE menu to update.
 ------------------------------------------------------------------------}
procedure TwEditorMain.mMenu1Click(Sender: TObject);
begin
   UpdateMenus;
end; {TwEditorMain.mMenu1Click}


{------------------------------------------------------------------------
  TwEditorMain.Timer1Timer
   Show the dirty status.
 ------------------------------------------------------------------------}
procedure TwEditorMain.Timer1Timer(Sender: TObject);
begin
   If FILE_COUNT > 0 then Begin
      TabDocuments.Hint := 'Current file is: ' + theFile[CURRENT_FILE].FILE_PATH;
      If theFile[CURRENT_FILE].DIRTY then
         theStatusBar1.Panels[0].Text := 'NOT SAVED'
      else
         theStatusBar1.Panels[0].Text := 'UP-TO-DATE';
   End Else
      theStatusBar1.Panels[0].Text := 'Idle.';
end; {TwEditorMain.Timer1Timer}


{**************************************************************************
 ***                      PRIVATE ROUTINES                              ***
 **************************************************************************}


{=========================================================================}
{ FORM MAINTENANCE, INCLUDING DETACHED ITEMS                              }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.DetachedKeyPress
    Re-focus the main window to handle Alt-key combinations.
 ------------------------------------------------------------------------}
procedure TwEditorMain.DetachedKeyPress(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   Self.BringToFront;
end; {TwEditorMain.DetachedKeyPress}


{------------------------------------------------------------------------
  TwEditorMain.NeutralizePositions
    Reset all floating preference positions.
 ------------------------------------------------------------------------}
procedure TwEditorMain.NeutralizePositions;
Begin
   thePrefs.TREE_POS.Top := -1;
   thePrefs.TREE_POS.Bottom := -1;
   thePrefs.TREE_POS.Left := -1;
   thePrefs.TREE_POS.Right := -1;
   thePrefs.CODE_POS := thePrefs.TREE_POS;
   thePrefs.MAIN_POS.X := Left;
   thePrefs.MAIN_POS.Y := Top;
End; {TwEditorMain.NeutralizePositions}

{-------------------------------------------------------------------------
  TwEditorMain.ShowPage
     o Free the current page, create the desired page, and display it.
     o Display default combo-box items.
     o Turn off items, or recall data, as appropriate.
     o Recall the decimals stored in the registry
 -------------------------------------------------------------------------}
procedure TwEditorMain.ShowPage(i : Integer);
Begin
   { create the new page}
   pageForm.Free;
   pageForm := pageList[i].Create(wEditorMain);
   pageForm.Parent := TWinControl(FindComponent('TabSheet' + IntToStr(i)));
   pageForm.Top := 0;
   pageForm.Left := 0;
   pageForm.Visible := True;

   {------------------------------------------------------------------------}
   {handle default combo-box items - if data exists, this will be overwrote }
   {------------------------------------------------------------------------}
   // this is the generic-font box
   If PageControl1.ActivePage = TabSheet1 then
      with TwPage1(pageForm).Textual3 do ItemIndex := Tag;
   // these are the quote boxes
   If PageControl1.ActivePage = TabSheet9 then Begin
      with TwPage9(pageForm).Textual10 do ItemIndex := Tag;
      with TwPage9(pageForm).Textual11 do ItemIndex := Tag;
      with TwPage9(pageForm).Textual12 do ItemIndex := Tag;
      with TwPage9(pageForm).Textual13 do ItemIndex := Tag;
   End; {if}
   {-------------------------------------------}
   { turn off everything if nothing selected   }
   { (or rtMedia, otherwise, recall the data   }
   {-------------------------------------------}
   If (theTree.Selected = nil) or
      (TCSSRecord(theTree.Selected.Data).RecordType = rtMedia) then
      pageForm.TurnOffPage
   Else Begin
      pageForm.EnablePage;
      pageForm.RecallPageData;
   End;
   {--------------------------------------------}
   { recall the decimals stored in the registry }
   {--------------------------------------------}
   pageForm.RecallDecimals;
End; {TwEditorMain.ShowPage}


{-----------------------------------------------------------------------------
  TwEditorMain.WMSysCommand
    o Intercept the form minimization in order to minimize the document.
 -----------------------------------------------------------------------------}
procedure TwEditorMain.WMSysCommand(var Message : TWMSysCommand);
Begin
   If (Message.CmdType and $FFF0) = SC_MINIMIZE then Begin
      Application.Minimize;
      Message.Result := 0;
      Exit;
   End;
   inherited;
End; {TwEditorMain.WMSysCommand}


{=========================================================================}
{ DISPLAY MAINTENANCE                                                     }
{=========================================================================}


{-------------------------------------------------------------------------
  TwEditorMain.ClearTheTree
     Clears the tree with event processing turned off.
 -------------------------------------------------------------------------}
Procedure TwEditorMain.ClearTheTree;
var eV1   : TTVChangingEvent;
    eV2   : TTVChangedEvent;
Begin
   eV1 := theTree.OnChanging;
   eV2 := theTree.OnChange;
   theTree.OnChanging := nil;
   theTree.OnChange := nil;
   theTree.Items.Clear;
   theTree.OnChanging := eV1;
   theTree.OnChange := eV2;
End; {TwEditorMain.ClearTheTree}


{------------------------------------------------------------------------
  TwEditorMain.EmboldenTree
   Embolden all IsTagged tree items.
 ------------------------------------------------------------------------}
procedure TwEditorMain.EmboldenTree;
var i : Integer;
Begin
   // embolden the correct items.
   For i := 0 to theTree.Items.Count - 1 do
      with TCSSRecord(theTree.Items[i].Data) do Begin
         If IsTagged then theTree.SetItemBold(theTree.Items[i], True);
         If RecordType = rtMedia then Begin
            theTree.Items[i].ImageIndex := 1;
            theTree.Items[i].SelectedIndex := 1;
         End; {if}
      end; {with}
End; {TwEditorMain.EmboldenTree}


{-------------------------------------------------------------------------
  TwEditorMain.UpdateMenus
     o preview menu - en-/disable according to the existance of classes.
     o disable all menus effected when no item is selected.
     o handle the tag/untag thing.
     o handle the classes menu appropriate to what's selected.
     o Also update the status area.
 -------------------------------------------------------------------------}
Procedure TwEditorMain.UpdateMenus;
var i : Integer;
    j : Boolean;
Begin
   {Disable the Classes menu if no documents are open}
   mMenu3.Enabled := FILE_COUNT > 0;
   {Update the status areas}
   with theStatusBar2 do Begin
      // show the complete name on the first panel.
      If FILE_COUNT = 0 then
         Panels[0].Text := 'No files opened.'
      Else Begin
         Panels[0].Text := ExtractFileName(EZFile);
         If ExtractFileExt(EZFile) = '' then // no extension
            Panels[0].Text := Panels[0].Text + ' (Never Saved)';
      End;
   end; {with}
   with theStatusBar1 do Begin
      // show the number of classes
      Panels[1].Text := IntToStr(theTree.Items.Count) + ' Class';
      If theTree.Items.Count <> 1 then Panels[1].Text := Panels[1].Text + 'es';
   end; {with}
   If APP_MODE then
      Application.Title := StripFileName(EZFile) + ' - ' + APPLICATION_NAME;
   {display the type of class}
   If theTree.Selected <> nil then with theStatusBar1.Panels[2] do Begin
      Case TCSSRecord(theTree.Selected.Data).RecordType of
         rtElement:     Text := '<' + theTree.Selected.Text + '> is an HTML Element.';
         rtClass:       Text := theTree.Selected.Text + ' is a simple CSS2 Class.';
         rtSubClass:    Text := theTree.Selected.Text + ' is a Subclass.';
         rtPseudoClass: Text := theTree.Selected.Text + ' is a Pseudoclass.';
         rtSubPseudo:   Text := theTree.Selected.Text + ' is a Pseudoclass of a subclass.';
         rtContextual:  Text := theTree.Selected.Text + ' is a Contextual Class.';
         rtID:          Text := theTree.Selected.Text + ' is a CSS2 ID.';
         rtCustom:      Text := theTree.Selected.Text + ' is an Expert/Custom Class.';
         rtMedia:       Text := theTree.Selected.Text + ' is a media descriptor.';
      End; {case}
   End else
      theStatusBar1.Panels[2].Text := 'No Class Selected.';

   { handle preview menu }
   cmPreviewAll.Enabled := theTree.Items.Count > 0;
   cmPreviewTagged.Enabled := theTree.Items.Count > 0;;
   cmPreviewSingle.Enabled := theTree.Items.Count > 0;
   { handle the editing menu items }
   cmCopy.Enabled := theTree.Selected <> nil;
   cmCopy1.Enabled := cmCopy.Enabled;
   Shortcut5.Enabled := cmCopy.Enabled;
   cmPaste.Enabled := (CBOARD <> nil);
   cmPaste1.Enabled := (CBOARD <> nil) and (theTree.Selected <> nil);
   Shortcut6.Enabled := cmPaste.Enabled;
   cmCut.Enabled := cmCopy.Enabled;
   cmCut1.Enabled := cmCopy.Enabled;
   Shortcut4.Enabled := cmCut.Enabled;
   cmDelete.Enabled := cmCopy.Enabled;
   cmDelete1.Enabled := cmCopy.Enabled;
   Shortcut7.Enabled := cmCopy.Enabled;
   cmRename.Enabled := cmCopy.Enabled;
   cmRename1.Enabled := cmCopy.Enabled;
   { handle the file menu }
   cmNew.Enabled := FILE_COUNT < CAPACITY;
   Shortcut1.Enabled := cmNew.Enabled;
   cmOpen.Enabled := FILE_COUNT < CAPACITY;
   Shortcut2.Enabled := cmOpen.Enabled;
   cmSaveAs.Enabled := theTree.Items.Count > 0;
   cmAsDocument.Enabled := theTree.Items.Count > 0;
   cmExportSelected.Enabled := theTree.Selected <> nil;
   cmExportSelected2.Enabled := theTree.Selected <> nil;
   cmExportAll.Enabled := theTree.Items.Count > 0;
   cmExportAll2.Enabled := theTree.Items.Count > 0;
   cmSave.Enabled := (theFile[CURRENT_FILE].DIRTY) and (theTree.Items.Count > 0);
   Shortcut3.Enabled := cmSave.Enabled;
   cmClose.Enabled := FILE_COUNT > 0;
   cmInBrowser.Enabled := (FILE_COUNT > 0) and (theTree.Items.Count > 0);
   Shortcut8.Enabled := cmInBrowser.Enabled;
   { handle the View menu }
   cmShowShortcuts.Checked := PanelShortcuts.Visible;
   cmShowClassesDetached.Checked := not Image1.Visible;
   cmShowCodeDetached.Checked := not Image2.Visible;
   // allow export enabled ONLY if something is tagged
   j := False;
   For i := 0 to theTree.Items.Count - 1 do
      with TCSSRecord(theTree.Items[i].Data) do
         If (IsTagged) and (RecordType <> rtMedia) then j := True;
   cmExportTagged.Enabled := j;
   cmExportTagged2.Enabled := j;
   { handle no item being selected }
   If theTree.Selected = nil then Begin
      Button1.Enabled := False;
      Button1.Caption := 'Tag';
      cmTag.Caption := '&Tag';
      cmTag.Enabled := False;
      cmContextClass.Enabled := False;
      cmSubClass.Enabled := False;
      cmPseudoClass.Enabled := False;
      Exit;
   End;
   {from this point on, things only apply if a tree item is selected}
   with TCSSRecord(theTree.Selected.Data) do Begin
      Button1.Enabled := RecordType <> rtMedia;
      cmTag.Enabled := RecordType <> rtMedia;
      cmTag1.Enabled := RecordType <> rtMedia;
   end; {with}
   with TCSSRecord(theTree.Selected.Data) do Begin
      { handle the tag/untag thing }
      If IsTagged then Begin
         Button1.Caption := 'Untag';
         cmTag.Caption := 'Un&tag';
         cmTag1.Caption := 'Untag';
      End Else Begin
         Button1.Caption := 'Tag';
         cmTag.Caption := '&Tag';
         cmTag1.Caption := 'Tag';
      End;
      { handle classes menu }
      cmContextClass.Enabled := RecordType in [rtElement, rtClass, rtSubClass];
      cmSubClass.Enabled := RecordType in [rtElement];
      cmPseudoClass.Enabled := RecordType in [rtElement, rtClass, rtSubClass,
                                             rtContextual];
      cmContextClass1.Enabled := cmContextClass.Enabled;
      cmSubClass1.Enabled := cmSubClass.Enabled;
      cmPseudoClass1.Enabled := cmPseudoClass.Enabled;
   End; {with}
End; {TwEditorMain.UpdateMenus}


{=========================================================================}
{ CSS2 CLASS SUPPORT                                                      }
{=========================================================================}


{-------------------------------------------------------------------------
  TwEditorMain.ClassExists
     o Enumerate theTree to see if theName exists in the tree.
 -------------------------------------------------------------------------}
function TwEditorMain.ClassExists(const theName : String) : Boolean;
var i : Integer;
Begin
   Result := False;
   For i := 0 to theTree.Items.Count - 1 do
      If theTree.Items[i].Text = theName then Result := True;
   If not thePrefs.DUPLICATE_WARN then Result := False;
End; {TwEditorMain.ClassExists}


{------------------------------------------------------------------------
  TwEditorMain.AppendNewClass
   Respond to the user having create any new class.
    o Make sure the class doesn't already exist.
    o Create a temporary record, and assign defaults
    o Load default measurements, if applicable, from the registry.
    o Insert the new item and select it.
    o Mark the file as dirty, and update the menus.
 ------------------------------------------------------------------------}
procedure TwEditorMain.AppendNewClass(aName : String; aKind : TCSSRecordType);
var myRec : TCSSRecord;
    myReg : TRegistry;
    i     : Integer;
Begin
  { make sure it doesn't exist! }
  If ClassExists(aName) then Begin
     MessageDlg(Format(UsedStrings[6], [aName]), mtError, [mbOK], 0);
     Exit;
  End; {if}
  {Create a temporary record, and assign defaults}
  myRec := TCSSRecord.Create(nil);
  myRec.IsTagged := True;
  myRec.Selector := aName;
  myRec.RecordType := aKind;
  { see if we need to change the default measurements, from the registry }
  myReg := TRegistry.Create;
  myReg.RootKey := HKEY_CURRENT_USER;
  myReg.OpenKey(wEditorMain.REGISTRY_KEY + '\Measurements', False);
  for i := 1 to 122 do
     if myReg.ValueExists(IntToStr(i)) then
        myRec.Selects[i] := myReg.ReadString(IntToStr(i));
  myReg.CloseKey;
  myReg.Free;
  {insert the new item and select it}
  with theTree do Begin
     if Selected <> nil then pageForm.SavePageData; // save old data
     Selected := Items.AddObject(Selected, myRec.Selector, myRec);
     SetItemBold(Selected, True);
     if Selected.Text[1] = '@' then Begin // mark as @media
        Selected.ImageIndex := 1;
        Selected.SelectedIndex := 1;
     end; {if}
  End; {with}
  {mark the file as dirty, and update the menus}
  MarkDirty(True);
  UpdateMenus;
End; {TwEditorMain.AppendNewClass}


{=========================================================================}
{ I/O MAINTENANCE                                                         }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.CloseDocument
   Close the document on Tab Nr index
    o Switch to the document to be closed.
    o Offer to save the file if it's dirty.
    o Do TabDocumentsChanging (which only clear the screen)
    o Delete the tab. If possible, select a new tab.
    o Compress the indexed arra and change the file counter.
    o if possible, do TabDocumentsChange
      else         Disable all.
 ------------------------------------------------------------------------}
function TwEditorMain.CloseDocument(index : Integer) : Word;
var k : Boolean; {dummy}
    i : Integer;
Begin
   Result := mrYes;
   // Switch to the document to be closed, if not already there.
   If TabDocuments.TabIndex <> index then Begin
      TabDocuments.TabIndex := index;
      k := True;
      TabDocumentsChanging(nil, k);
      TabDocumentsChange(nil);
   End;
   // If the file to be closed is dirty, then ask to save it.
   If theFile[CURRENT_FILE].DIRTY then Begin
      Result := MessageDlg(Format(UsedStrings[22],
                   [StripFileName(EZFile)]), mtConfirmation, mbYesNoCancel, 0);
      If Result = mrCancel then Exit;
      If Result = mrYes then cmSaveClick(nil);
   End;
   // Clear the display
   k := True;
   TabDocumentsChanging(nil, k);
   // Erase Tab Number index, and position the next tab
   If TabDocuments.Tabs.Count = 1 then
      TabDocuments.Visible := False;
   TabDocuments.Tabs.Delete(CURRENT_FILE);
   If TabDocuments.Tabs.Count > 0 then Begin // select the next tab
      If TabDocuments.Tabs.Count >= CURRENT_FILE + 1 then
         TabDocuments.TabIndex := CURRENT_FILE
      Else
         TabDocuments.TabIndex := CURRENT_FILE -1;
   End; {if}
   // compress the indexed array and change the file counter.
   For i := CURRENT_FILE to CAPACITY - 2 do theFile[i] := theFile[i + 1];
   FILE_COUNT := FILE_COUNT - 1;

   // switch to the next page, if possible.
   If TabDocuments.TabIndex <> - 1 then // we can switch
      TabDocumentsChange(nil) // this sets the new CURRENT_FILE, too.
   Else                                 // we've closed the last document
      pageForm.TurnOffPage;
   UpdateMenus;
   pageForm.PreviewUpdate(nil);
End; {TwEditorMain.CloseDocument}


{-------------------------------------------------------------------------
  TwEditorMain.EZFile
     o Simply return theFile[CURRENT_FILE].FILE_PATH.
 -------------------------------------------------------------------------}
Function TwEditorMain.EZFile : String;
Begin
   Result := theFile[CURRENT_FILE].FILE_PATH;
End; {TwEditorMain.EZFile}


{------------------------------------------------------------------------
  TwEditorMain.VExtension
   Make sure the extension is valid
 ------------------------------------------------------------------------}
function TwEditorMain.VExtension(theExt : String; how : veSaveType) : Boolean;
Begin
   Result := False;
   // during a save or export, WWS2 or WWTD are okay.
   If ((how = veBoth) or (how = veSave)) and
      ((theExt = '.WWS2') or (theExt = '.WWTD')) then
      Result := True;
   // during a save, import, or export, HTML, CSS, or HTM are okay.
   If ((how = veBoth) or (how = veExport)) and
      ((theExt = '.HTML') or (theExt = '.CSS') or (theExt = '.HTM')) then
      Result := True;
   If Result then Exit; // all is okay here
   // display the warning
   MessageDlg(Format(UsedStrings[23], [theExt]), mtError, [mbCancel], 0);
End; {TwEditorMain.VExtension}


{------------------------------------------------------------------------
  TwEditorMain.ExportDocument
   Export the file.
    o Create a TCascadeDocument.
    o Set its options.
    o Get the list of strings.
    o Manipulate the lines.
    o Write it to disk.
 ------------------------------------------------------------------------}
procedure TwEditorMain.ExportDocument(FileName : String; qAll : exType);
var myDoc  : TCascadeDocument;
    myList : TStringList;
    i      : Integer;
    myFile : TextFile;
Begin
   // create the document and its options.
   myDoc := TCascadeDocument.Create(nil);
   myDoc.GetFromTree(theTree);
   with theFile[CURRENT_FILE] do Begin
      myDoc.Author     := ORIG_AUTHOR;
      myDoc.AuthorMail := ORIG_EMAIL;
      myDoc.AuthorURL  := ORIG_URL;
      myDoc.AppName    := APPLICATION_NAME;
   end; {with}
   // get the CSS
   myList := TStringList.Create;
   myDoc.GetCSS(myList, thePrefs.SINGLE_QUOTES, Boolean(qAll));
   // turn the list into an HTML format.
   If ExtractFileExt(FileName) = '.HTML' then Begin
      For i := 0 to 6 do myList.Insert(i, HTMLStr[i+1]);
      For i := 8 to 9 do myList.Add(HTMLStr[i]);
   End; {if}
   // now write the file
   try
      AssignFile(myFile, FileName);
      Rewrite(myFile);
      For i := 0 to myList.Count-1 do WriteLn(myFile, myList.Strings[i]);
   finally
      CloseFile(myFile);
   end;
   // clean up
   myDoc.Free;
   myList.Free;
End; {TwEditorMain.ExportDocument}


{------------------------------------------------------------------------
  TwEditorMain.ReallyOpen
   The filename is known, so really open the document.
 ------------------------------------------------------------------------}
procedure TwEditorMain.ReallyOpen(FileName : String);
var myDoc : TCascadeDocument;
        i : Integer;
begin
   // if the filename already exists, then forget it!
   for i := 0 to FILE_COUNT - 1 do
      if theFile[i].FILE_PATH = FileName then Exit;
   // create a new, untitled document, and undo the document counter.
   cmNewClick(nil);
   DOC_COUNT := DOC_COUNT - 1;
   // create a temporary document, and load it.
   myDoc := TCascadeDocument.Create(nil);
   try
      myDoc.OpenDocument(FileName);
   finally
   end;
   myDoc.PutIntoTree(theTree);
   // set up all the related variables
   with theFile[CURRENT_FILE] do Begin
      ORIG_AUTHOR   := myDoc.Author;
      ORIG_EMAIL    := myDoc.AuthorMail;
      ORIG_URL      := myDoc.AuthorURL;
      DIRTY         := False;
      IS_TEMPLATE   := (ExtractFileExt(FileName) = '.WWTD');
      NEEDS_SAVE_AS := False;
      FILE_PATH     := FileName;
      LEVEL_DOC     := myDoc.OptionLevel;
   end; {with}
   If theTree.Items.Count = 0 then
      theTree.Selected := nil
   else
      theTree.Selected := theTree.Items[0];
   TabDocuments.Tabs[CURRENT_FILE] := StripFileName(EZFile);
   // embolden the correct items.
   EmboldenTree;
   // Free the temporary document
   myDoc.Free;
   // update the menus
   UpdateMenus;
end; {TwEditorMain.ReallyOpen}


{------------------------------------------------------------------------
  TwEditorMain.ReallySave
   Really Save the Document (everything else is prepared)
 ------------------------------------------------------------------------}
procedure TwEditorMain.ReallySave(FileName : String);
var myDoc : TCascadeDocument;
Begin
   myDoc := TCascadeDocument.Create(nil);
   myDoc.GetFromTree(theTree);
   with theFile[CURRENT_FILE] do Begin
      myDoc.Author := ORIG_AUTHOR;
      myDoc.AuthorMail := ORIG_EMAIL;
      myDoc.AuthorURL := ORIG_URL;
      myDoc.AppName := APPLICATION_NAME;
      myDoc.OptionLevel := 0; {because this Cascade only supports 0!}
   end; {with}
   myDoc.SaveDocument(FileName);
   myDoc.Free;
   MarkDirty(False);
   TabDocuments.Tabs[CURRENT_FILE] := StripFileName(FileName);
End; {TwEditorMain.ReallySave}

{------------------------------------------------------------------------
  TwEditorMain.ImportCSS
   Import CSS Code.
 ------------------------------------------------------------------------}
procedure TwEditorMain.ImportCSS(FileName : String);
var myDoc : TCascadeDocument;  // will be used to translate the Stylesheet.
    myCSS : TStyleSheet;       // will be used to translate the original file.
begin
   // create a new, untitled document.
   cmNewClick(nil);
   // create a temporary document, and load it.
   myDoc := TCascadeDocument.Create(nil);
   myCSS := TStyleSheet.Create;
   try
      myCSS.LoadFromFile(FileName);
   finally
   end;
   myDoc.InterpretCSS(myCSS);
   myDoc.PutIntoTree(theTree);
   // set up all the related variables
   with theFile[CURRENT_FILE] do Begin
      DIRTY         := False;           // mark it not dirty
      NEEDS_SAVE_AS := True;            // mark as requiring a "save as"
      IS_TEMPLATE   := False;           // mark as not being a template
      TREE_POS      := -1;              // marks as nothing selected
      FILE_PATH     := 'Document ' + IntToStr(DOC_COUNT);
      ORIG_AUTHOR := thePrefs.NEW_AUTHOR;
      ORIG_EMAIL := thePrefs.NEW_EMAIL;
      ORIG_URL := thePrefs.NEW_URL;
      PREVIEW_PATH := '';
      LEVEL_DOC := 0;
      LEVEL_REC := 0
   end; {with}
   If theTree.Items.Count = 0 then
      theTree.Selected := nil
   else
      theTree.Selected := theTree.Items[0];
   TabDocuments.Tabs[CURRENT_FILE] := StripFileName(EZFile);
   // embolden the correct items.
   EmboldenTree;
   // Free the temporary document
   myDoc.Free;
   // update the menus
   UpdateMenus;
end; {TwEditorMain.ImportCSS}


{=========================================================================}
{   OTHER ROUTINES                                                        }
{=========================================================================}


{------------------------------------------------------------------------
  TwEditorMain.WritePreferences
   Write the preferences to the registry.
 ------------------------------------------------------------------------}
procedure TwEditorMain.WritePreferences;
var myReg : TRegistry;
begin
   {make sure SHOW_SHORTCUTS reflects the actual state}
   thePrefs.SHOW_SHORTCUTS := PanelShortcuts.Visible;
   {update the prefs for all of the windowette positions}
   NeutralizePositions;
   If not Image1.Visible then Begin
      thePrefs.TREE_POS.Top := TreeWin.theWin.Top;
      thePrefs.TREE_POS.Left := TreeWin.theWin.Left;
      thePrefs.TREE_POS.Bottom := TreeWin.theWin.ClientHeight;
      thePrefs.TREE_POS.Right := TreeWin.theWin.ClientWidth;
   End; {if}
   If not Image2.Visible then Begin
      thePrefs.CODE_POS.Top := PreviewWin.theWin.Top;
      thePrefs.CODE_POS.Left := PreviewWin.theWin.Left;
      thePrefs.CODE_POS.Bottom := PreviewWin.theWin.ClientHeight;
      thePrefs.CODE_POS.Right := PreviewWin.theWin.ClientWidth;
   End; {if}
   thePrefs.MAIN_POS.X := Left;
   thePrefs.MAIN_POS.Y := Top;
   {write them out}
   with thePrefs do Begin
      myReg := TRegistry.Create;
      myReg.RootKey := HKEY_CURRENT_USER;
      myReg.OpenKey(wEditorMain.REGISTRY_KEY + '\Preferences', True);
      myReg.WriteBool('ShowFonts', PREF_FONTS);
      myReg.WriteBool('ShowColors', SHOW_COLORS);
      myReg.WriteBool('AllowColors', ALLOW_SYS_COLORS);
      myReg.WriteBool('ShowBar', SHOW_SHORTCUTS);
      myReg.WriteBinaryData('ListP', thePrefs.TREE_POS, SizeOf(thePrefs.TREE_POS));
      myReg.WriteBinaryData('CodeP', thePrefs.CODE_POS, SizeOf(thePrefs.CODE_POS));
      myReg.WriteBinaryData('MainP', thePrefs.MAIN_POS, SizeOf(thePrefs.MAIN_POS));
      myReg.WriteBool('ConfirmDelete', CONFIRM_DELETE);
      myReg.WriteString('NewAuthor', NEW_AUTHOR);
      myReg.WriteString('NewEmail', NEW_EMAIL);
      myReg.WriteString('NewURL', NEW_URL);
      myReg.WriteString('DefaultDir', DEFAULT_DIR);
      myReg.WriteBool('SingleQuotes', SINGLE_QUOTES);
      myReg.WriteBool('DuplicateWarn', DUPLICATE_WARN);
      myReg.CloseKey;
      myReg.Free;
   end; {with}
End; {TwEditorMain.WritePreferences}


{------------------------------------------------------------------------
  TwEditorMain.ReadPreferences
   Read the preferences from the registry.
 ------------------------------------------------------------------------}
procedure TwEditorMain.ReadPreferences;
var myReg : TRegistry;
begin
   myReg := TRegistry.Create;
   myReg.RootKey := HKEY_CURRENT_USER;
   if myReg.KeyExists(REGISTRY_KEY + '\Preferences') then with thePrefs do
      Begin {read the preferences}
         myReg.OpenKey(REGISTRY_KEY + '\Preferences', False);
         if myReg.ValueExists('ShowFonts') then
            PREF_FONTS := myReg.ReadBool('ShowFonts');
         if myReg.ValueExists('ShowColors') then
            SHOW_COLORS := myReg.ReadBool('ShowColors');
         if myReg.ValueExists('AllowColors') then
            ALLOW_SYS_COLORS := myReg.ReadBool('AllowColors');
         if myReg.ValueExists('ShowBar') then
            SHOW_SHORTCUTS := myReg.ReadBool('ShowBar');
         if myReg.ValueExists('ListP') then
            myReg.ReadBinaryData('ListP', thePrefs.TREE_POS, SizeOf(thePrefs.TREE_POS));
         if myReg.ValueExists('CodeP') then
            myReg.ReadBinaryData('CodeP', thePrefs.CODE_POS, SizeOf(thePrefs.CODE_POS));
         if myReg.ValueExists('MainP') then
            myReg.ReadBinaryData('MainP', thePrefs.MAIN_POS, SizeOf(thePrefs.MAIN_POS));
         if myReg.ValueExists('ConfirmDelete') then
            CONFIRM_DELETE := myReg.ReadBool('ConfirmDelete');
         if myReg.ValueExists('NewAuthor') then
            NEW_AUTHOR := myReg.ReadString('NewAuthor');
         if myReg.ValueExists('NewEmail') then
            NEW_EMAIL := myReg.ReadString('NewEmail');
         if myReg.ValueExists('NewURL') then
            NEW_URL := myReg.ReadString('NewURL');
         if myReg.ValueExists('DefaultDir') then
            DEFAULT_DIR := myReg.ReadString('DefaultDir');
         if myReg.ValueExists('SingleQuotes') then
            SINGLE_QUOTES := myReg.ReadBool('SingleQuotes');
         if myReg.ValueExists('DuplicateWarn') then
            DUPLICATE_WARN := myReg.ReadBool('DuplicateWarn');
      End; {begin/if}
   myReg.CloseKey;
   { update the display to reflect changes}
   PanelShortcuts.Visible := thePrefs.SHOW_SHORTCUTS;
   SaveDialog1.InitialDir := thePrefs.DEFAULT_DIR;
   OpenDialog1.InitialDir := thePrefs.DEFAULT_DIR;
   If thePrefs.TREE_POS.Top <> -1 then Begin
      DetachAPanel(Image1);
      TreeWin.theWin.Top := thePrefs.TREE_POS.Top;
      TreeWin.theWin.Left := thePrefs.TREE_POS.Left;
      TreeWin.theWin.ClientHeight := thePrefs.TREE_POS.Bottom;
      TreeWin.theWin.ClientWidth := thePrefs.TREE_POS.Right;
   End;
   If thePrefs.CODE_POS.Top <> -1 then Begin
      DetachAPanel(Image2);
      PreviewWin.theWin.Top := thePrefs.CODE_POS.Top;
      PreviewWin.theWin.Left := thePrefs.CODE_POS.Left;
      PreviewWin.theWin.ClientHeight := thePrefs.CODE_POS.Bottom;
      PreviewWin.theWin.ClientWidth := thePrefs.CODE_POS.Right;
   End;
   Left := thePrefs.MAIN_POS.X;
   Top := thePrefs.MAIN_POS.Y;

End; {TwEditorMain.ReadPreferences}


{**************************************************************************
 ***     PRIVATE ROUTINES MADE PUBLICLY AVAILABLE FOR OTHER UNITS       ***
 **************************************************************************}


{------------------------------------------------------------------------
  TwEditorMain.ParseFileList
   Put the file list into START_FILES[]
   Returns the number of files
 ------------------------------------------------------------------------}
function TwEditorMain.ParseFileList : Integer;
var      i : Integer;
    tmpStr : String;
   procedure doFileAttributes(fileName : String; index : Integer);
   var myStr : String;
   begin
      myStr := GetLongPath(Trim(fileName));
      { make sure there's a legal extension }
      If Pos(ExtractFileExt(myStr), '.WWS2.WWTD') = 0 then begin
         i := i -1; // decrease the counter
         Exit;
      End;
      { add it to the array - defaults will be set when file is opened}
      START_FILES[index] := myStr;
   end;
begin
   {clear START_FILES[n].FILE_PATH}
   for i := 0 to CAPACITY - 1 do START_FILES[i] := '';
   Result := 0;
   tmpStr := DOCUMENT_LIST;
   If tmpStr = '' then Exit; // nothing to parse
   { if no pipe at all, assume the whole thing is the file list }
   If Pos(#124, tmpStr) = 0 then Begin
      doFileAttributes(tmpStr, 0);
      Result := 1;
      Exit;
   End; {if}
   { add trailing pipe }
   If tmpStr[Length(tmpStr)] <> #124 then
      tmpStr := tmpstr + #124;
   { break into components }
   i := -1;
   Repeat
      i := i + 1;
      doFileAttributes(Copy(tmpStr, 1, Pos(#124, tmpStr)-1), i);
      Delete(tmpStr, 1, Pos(#124, tmpStr));
   Until Pos(#124, tmpStr) = 0;
   Result := i+1;
end; {TwEditorMain.ParseFileList}


{-------------------------------------------------------------------------
  TwEditorMain.MarkDirty
     o Simply set theFile[CURRENT_FILE].DIRTY := True/False.
 -------------------------------------------------------------------------}
Procedure TwEditorMain.MarkDirty(isDirty : Boolean);
Begin
   theFile[CURRENT_FILE].DIRTY := isDirty;
End; {TwEditorMain.MarkDirty}


{------------------------------------------------------------------------
  TwEditorMain.ParseHTML
   Fix an HTML file so it will use stylesheets. File created is
   temphtml.html in the windows temporary directory.
 ------------------------------------------------------------------------}
procedure TwEditorMain.ParseHTML(FileName : String; CSSName : String);
var srcFile,
    dstFile : TextFile;
    tmpStr  : String;
    tmpChr  : Char;
const L1 = #13 + '<LINK REL=STYLESHEET TYPE="text/css" HREF=' + #34;
      L2 = #34 + ' TITLE="none">';
Begin
   {set up the files}
   AssignFile(srcFile, FileName);
   Reset(srcFile);
   AssignFile(dstFile, TEMP_DIR + tempHTML);
   Rewrite(dstFile);
   {read the source file a character at a time, seeking tags.}
   While not Eof(srcFile) do Begin
      Read(srcFile, tmpChr);
      If tmpChr = '<' then Begin // a tag found
         tmpStr := '<';
         {read in the entire tag}
         While (tmpChr <> '>') and (not Eof(srcFile)) do Begin // whole tag
            Read(srcFile, tmpChr);
            tmpStr := tmpStr + tmpChr;
         End; {while -- we now how a string of an <element>}
         If Pos('TEXT/CSS', UpperCase(tmpStr)) <> 0 then // the tag is okay.
            tmpStr := '';
         If UpperCase(tmpStr) = '<HEAD>' then
            tmpStr := tmpStr + L1 + CSSName + L2;
         If tmpStr <> '' then
            Write(dstFile, tmpStr);
      End {if} Else
         Write(dstFile, tmpChr);
   End; {while}
   CloseFile(srcFile);
   CloseFile(dstFile);
End; {TwEditorMain.ParseHTML}


{------------------------------------------------------------------------
  TwEditorMain.ShowAbout
   Show/Hide the about box non-modally
 ------------------------------------------------------------------------}
procedure TwEditorMain.ShowSplash;
var myWin : TwAboutMe;
begin
   myWin := TwAboutMe.Create(Application);
   myWin.LabelStatus.Caption := 'Starting up...';
   myWin.Timer1.Enabled := True;
   myWin.ShowModal;
end; {TwEditorMain.ShowAbout}

{------------------------------------------------------------------------
  TwEditorMain.EmboldenTree
   Make sure things are properly bold where needed.
 ------------------------------------------------------------------------}
procedure TwEditorMain.DoBoldTree;
var myNode : TTreeNode;
begin
   myNode := theTree.Items.GetFirstNode;
   While myNode <> Nil do Begin
        with TCSSRecord(myNode.Data) do theTree.SetItemBold(myNode, IsTagged);
   myNode := myNode.GetNext;
   End; {While}
end; {TwEditorMain.EmboldenTree}

{------------------------------------------------------------------------
  TwEditorMain.DropTarget1Drop
   The user is dropping a file to open it.
 ------------------------------------------------------------------------}
procedure TwEditorMain.DropFileTarget1Drop(Sender: TObject;
  DragType: TDragType; Files: TStrings; Point: TPoint);
var i : Integer;
    T : String;
begin
   for i := 0 to Files.Count - 1 do Begin
      If FILE_COUNT >= CAPACITY then Begin
         MessageDlg(UsedStrings[28], mtInformation, [mbOK], 0);
         Exit;
      End; {if}
      T := Files[i];
      If (ExtractFileExt(T) = '.WWS2') or (ExtractFileExt(T) = '.WWTD') then
         ReallyOpen(T)
      Else
      If (ExtractFileExt(T) = '.CSS') or (ExtractFileExt(T) = '.HTML')  or (ExtractFileExt(T) = '.HTM') then
         ImportCSS(T)
      Else
         MessageDlg(Format(UsedStrings[29], [T]), mtWarning, [mbOK], 0);
   end; {for}
end; {TwEditorMain.DropTarget1Drop}


{------------------------------------------------------------------------
  TwEditorMain.SystemExecuteMacro
   Monitor for the OPEN DDE Message, and open the files as required.
 ------------------------------------------------------------------------}
procedure TwEditorMain.SystemExecuteMacro(Sender: TObject; Msg: TStrings);
var tmpStr : String;
begin
   tmpStr := Msg[0];
   // is this the right message?
   If Copy(Uppercase(tmpStr),1,6) = '[OPEN(' then Begin
      If FILE_COUNT >= CAPACITY then Begin
         MessageDlg(UsedStrings[28], mtInformation, [mbOK], 0);
         Exit;
      End; {if}
      tmpStr := Copy(tmpStr, 8, Length(tmpStr)-10);
      ReallyOpen(tmpStr);
   End; {if}
end; {TwEditorMain.SystemExecuteMacro}



end.
