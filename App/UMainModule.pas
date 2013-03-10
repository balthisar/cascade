unit UMainModule;

{============================================================================
  MAINMODULE
   The Operating System interface to the Cascade component. It's responsible
   for personalizing the application, and responding to command-line par-
   ameters, which are used to open a file by double-clicking in the shell
 ============================================================================}

{----------------------------------------------------------------------------
  STARTUP PARAMETERS FOR DEBUGGING -- leave in final build
     miaok -- multiple instances are okay
     pdsss -- please don't show splash screen
 ----------------------------------------------------------------------------}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UCascadeEditor;
                                              
type
  TMainModule = class(TDataModule)
    CascadeDLOG: TCascadeDLOG;
    procedure DataModule2Create(Sender: TObject);
  private            
    { Private declarations }
  public
    { Public declarations }
  end;

const APP_KEY = 'SOFTWARE\Balthisar\Cascade\v2.0';
      APP_PASSCODE = 200;

var
  MainModule: TMainModule;



{============================================================================
                               IMPLEMENTATION
 ============================================================================}

implementation

uses Registry, UPersonalize, UJimsUtilities;

{$R *.DFM}

{=======================================================================
  PERSONALIZE
   Asks the user to personalize the program if it is not already done.
 =======================================================================}
Procedure Personalize;
var myReg : TRegistry;
    myWin : TwPersonalize;
Begin
   {see if personalization information already exists}
   myReg := TRegistry.Create;
   myReg.RootKey := HKEY_CURRENT_USER;
   if myReg.KeyExists(APP_KEY) then
      Begin {see if the registered flag is there}
         myReg.OpenKey(APP_KEY, False);
         if myReg.ValueExists('Personalized') then    {it exists...}
            if myReg.ReadBool('Personalized') then  {is it true? }
               Begin {no need to re-personalize}
                  myReg.CloseKey;
                  myReg.Free;
                  Exit;
               end; {if}
      End; {if}
   myReg.CloseKey;
   myReg.Free;

   {it doesn't exist, so bring up the personalize window}
   myWin := TwPersonalize.Create(Application);
   myWin.RegistryKey := APP_KEY;
   myWin.ShowModal;
   myWin.Free;

End; {Personalize}


{=======================================================================
  DataModule2Create
   Start the Application.
     o Personalize
     o Set up CLI parameters (documents)
     o Show the splash-screen
     o Set up the default directory
     o Show the component.
 =======================================================================}
procedure TMainModule.DataModule2Create(Sender: TObject);
var
   SS : Boolean; // show the splash screen?
begin
   {personalize the application}
   Personalize;
   {get the splash screen information}
   SS := (ParamStr(1) <> 'pdsss') and (ParamStr(2) <> 'pdsss');
   {don't process documents, that's for the component version. The application
    will rely on proper implementation of DDE from the shell}

   {show the component}
   CascadeDLOG.DefaultDir := ExtractFilePath(ParamStr(0));
   CascadeDLOG.RegistryKey := APP_KEY;
   CascadeDLOG.Execute(APP_PASSCODE, SS);
end; {DataModule2Create}

end.
