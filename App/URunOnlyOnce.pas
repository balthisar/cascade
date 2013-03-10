unit URunOnlyOnce;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Registry;


const
   FIND_APP = 'Balthisar Cascade 2.0';

type COPYDATASTRUCT = Record
        dwData : LongInt;
        cbData : LongInt;
        lpData : PChar;
     End;

     PCOPYDATASTRUCT = ^COPYDATASTRUCT;


function IsPrevInst : Boolean;

implementation

uses UJimsUtilities;


// =======================================================
// Prevents a 2nd instance of the program from executing,
// and instead activates the already executing instance.
// =======================================================
function IsPrevInst: Boolean;
var
   semName,
   appClass: PChar;
   hWndIt  : HWnd;
   appTitle: Array[0..MAX_PATH] of Char;
begin
   Result := FALSE;
   GetMem(semName,17);
   GetMem(appClass,15);
   StrPCopy(appTitle, FIND_APP);        // name of window to find
   hWndIt := FindWindow(nil, appTitle); // this window is running
   If hWndIt <> 0 then Begin // the app is already running!
      BringWindowToTop(hWndIt);
      ShowWindow(hWndIt,SW_SHOWNORMAL);
      Result := True
   End; {if}
   FreeMem(semName,17);
   FreeMem(appClass,15);
 end;

end.
