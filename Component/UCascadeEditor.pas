unit UCascadeEditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

{============================================================================
  COMPONENT declaration
 ============================================================================}
type
  TCascadeDLOG = class(TComponent)
   private
      FHelpFile : String;
      FHelpContext : THelpContext;
      FStartDocuments : String;
      FRegistryKey : String;
      FPassword : String;
      FTitle : String;
      FDefDir : String;
   public
      Function Execute : Boolean; overload;
      Function Execute(How : Integer; const Splash : Boolean) : Boolean; overload;
   published
      Property HelpFile : String read FHelpFile write FHelpFile;
      Property HelpContext : THelpContext read FHelpContext write FHelpContext;
      Property StartDocuments : String read FStartDocuments write FStartDocuments;
      Property RegistryKey : String read FRegistryKey write FRegistryKey;
      Property Password : String read FPassword write FPassword;
      Property Title : String read FTitle write FTitle;
      Property DefaultDir : String read FDefDir write FDefDir;
  end;

Const
   APP_PASSCODE = 200;

procedure Register;

implementation

uses UEditorMain;

{============================================================================
  COMPONENT Methods
 ============================================================================}

{----------------------------------------------------------------------------
 TCascadeDLOG.Execute(1)
 Executes Cascade in Component mode
----------------------------------------------------------------------------}
function TCascadeDLOG.Execute : Boolean;
var tmpStr : String;
Begin
   try
      Result := False;
      wEditorMain := TwEditorMain.Create(Application);
      wEditorMain.BorderIcons := [];
      wEditorMain.APP_MODE := False;
      wEditorMain.HELP_FILE := FHelpFile;
      tmpStr := Application.HelpFile;
      Application.HelpFile := FHelpFile;
      wEditorMain.HELP_CONTEXT := FHelpContext;
      wEditorMain.DOCUMENT_LIST := FStartDocuments;
      wEditorMain.REGISTRY_KEY := FRegistryKey;
      wEditorMain.ABOUT_PASSWORD := FPassword;
      wEditorMain.APPLICATION_NAME := FTitle;
      wEditorMain.thePrefs.DEFAULT_DIR := FDefDir;
      if wEditorMain.ShowModal = mrOK then Result := True;
   finally
       wEditorMain.Free;
   End;
   Application.HelpFile := tmpStr;
End; {TCascadeDLOG.Execute(1)}

{----------------------------------------------------------------------------
  TCascadeDLOG.Execute(2)
  Executes Cascade in Application mode.
 ----------------------------------------------------------------------------}
function TCascadeDLOG.Execute(How : Integer; const Splash : Boolean) : Boolean;
var tmpStr : String;
Begin
   If How <> APP_PASSCODE then Execute;
   try
      Result := False;
      wEditorMain := TwEditorMain.Create(Application);
      wEditorMain.APP_MODE := True;
      wEditorMain.HELP_FILE := FHelpFile;
      tmpStr := Application.HelpFile;
      Application.HelpFile := FHelpFile;
      wEditorMain.HELP_CONTEXT := FHelpContext;
      wEditorMain.DOCUMENT_LIST := '';
      wEditorMain.REGISTRY_KEY := FRegistryKey;
      wEditorMain.ABOUT_PASSWORD := FPassword;
      wEditorMain.APPLICATION_NAME := FTitle;
      wEditorMain.thePrefs.DEFAULT_DIR := FDefDir;
      If Splash then wEditorMain.ShowSplash;
      If wEditorMain.ShowModal = mrOK then Result := True;
   finally
      wEditorMain.Free;
   End;
   Application.HelpFile := tmpStr;
End; {TCascadeDLOG.Execute(2)}

procedure Register;
begin
  RegisterComponents('Private', [TCascadeDLOG]);
end;

end.
