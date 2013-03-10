unit UPreferences;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, UrlLabel, Buttons, Mask, ToolEdit, BrowseDr;

type
  TwPreferences = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    CheckFonts: TCheckBox;
    CheckColors: TCheckBox;
    CheckSystemColors: TCheckBox;
    FieldName: TEdit;
    FieldEmail: TEdit;
    FieldURL: TEdit;
    CheckConfirm: TCheckBox;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabelName: TLabel;
    LabelApp: TLabel;
    LabelFeatures: TLabel;
    LabelEmail: TUrlLabel;
    LabelURL: TUrlLabel;
    BitBtn1: TBitBtn;
    Label6: TLabel;
    FieldDirectory: TComboEdit;
    DirPicker: TBrowseDirectoryDlg;
    CheckSingleQuotes: TCheckBox;
    CheckDuplicateWarn: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure UpdateDocInfo;
    procedure BitBtn1Click(Sender: TObject);
    procedure FieldDirectoryButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  wPreferences: TwPreferences;

implementation

uses UEditorMain, Registry;

{$R *.DFM}

{--------------------------------------------------------------------------
  Get the current preferences
 --------------------------------------------------------------------------}
procedure TwPreferences.FormShow(Sender: TObject);
begin
   PageControl1.ActivePage := TabSheet1;

   { page one -- preferences }
   with wEditorMain.thePrefs do Begin
      CheckFonts.Checked := PREF_FONTS;
      CheckColors.Checked := SHOW_COLORS;
      CheckSystemColors.Checked := ALLOW_SYS_COLORS;
      CheckConfirm.Checked := CONFIRM_DELETE;
      CheckSingleQuotes.Checked := SINGLE_QUOTES;
      CheckDuplicateWarn.Checked := DUPLICATE_WARN;
      FieldName.Text := NEW_AUTHOR;
      FieldEmail.Text := NEW_EMAIL;
      FieldURL.Text := NEW_URL;
      FieldDirectory.Text := DEFAULT_DIR;
   end; {with}

   { page two - document information }
   UpdateDocInfo;
end; {TwPreferences.FormShow}


{--------------------------------------------------------------------------
  Show the document information.
 --------------------------------------------------------------------------}
procedure TwPreferences.UpdateDocInfo;
Begin
   If wEditorMain.FILE_COUNT > 0 then
      with wEditorMain do
         with theFile[CURRENT_FILE] do Begin
            LabelName.Caption := ORIG_AUTHOR;
            LabelEmail.Caption := ORIG_EMAIL;
            LabelEmail.URL := ORIG_EMAIL;
            LabelURL.Caption := ORIG_URL;
            LabelURL.URL := ORIG_URL;
            LabelApp.Caption := APPLICATION_NAME;
            If LEVEL_DOC = 0 then
               LabelFeatures.Caption := 'None Present'
            else
               LabelFeatures.Caption := 'Level ' + IntToStr(LEVEL_DOC) +
               ' (will be lost on save)';
      End; {withs}
End; {TwPreferences.UpdateDocInfo}


{--------------------------------------------------------------------------
  Set the current preferences
 --------------------------------------------------------------------------}
procedure TwPreferences.FormClose(Sender: TObject;  var Action: TCloseAction);
begin
   {change the program preferences}
   with wEditorMain.thePrefs do Begin
      PREF_FONTS := CheckFonts.Checked;
      SHOW_COLORS := CheckColors.Checked;
      ALLOW_SYS_COLORS := CheckSystemColors.Checked;
      CONFIRM_DELETE := CheckConfirm.Checked;
      SINGLE_QUOTES := CheckSingleQuotes.Checked;
      DUPLICATE_WARN := CheckDuplicateWarn.Checked;
      NEW_AUTHOR := FieldName.Text;
      NEW_EMAIL := FieldEmail.Text;
      NEW_URL := FieldURL.Text;
      DEFAULT_DIR := FieldDirectory.Text;
   end; {with}
end; {TwPreferences.FormClose}


{--------------------------------------------------------------------------
  Apply the default identity to this document.
 --------------------------------------------------------------------------}
procedure TwPreferences.BitBtn1Click(Sender: TObject);
begin
   // apply the deault identity to this document
   with wEditorMain do
      with theFile[CURRENT_FILE] do Begin
         ORIG_AUTHOR := FieldName.Text;
         ORIG_EMAIL := FieldEmail.Text;
         ORIG_URL := FieldURL.Text;
         DIRTY := True;
   End; {withs}
   UpdateDocInfo;
end; {TwPreferences.BitBtn1Click}


{--------------------------------------------------------------------------
  Browse for a new path.
 --------------------------------------------------------------------------}
procedure TwPreferences.FieldDirectoryButtonClick(Sender: TObject);
begin
   DirPicker.Selection := FieldDirectory.Text;
   If DirPicker.Execute then FieldDirectory.Text := DirPicker.Selection;
end;

end.
