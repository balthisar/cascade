unit UCSS2Document;

{=============================================================================
  OPTION LEVELS 0 / 1
  This unit defines the TCSSRecord type, which holds CSS Information for a
  single class, and the TCascadeDocument type, which holds Information for
  multiple classes.

  DOCUMENT OPTION 1 = Mixed Media Manager
 =============================================================================}

interface

uses Classes, Graphics, ComCtrls, UJDParseCSS;

{=============================================================================
  TCSSRecordType Declaration
   This type is used to determine which types of subclasses can be derived.
 =============================================================================}
type
  TCSSRecordType = (rtElement, rtClass, rtSubClass, rtPseudoClass, rtSubPseudo,
                    rtContextual, rtID, rtCustom, rtMedia);

{=============================================================================
  TCSSRecord Declaration
  This class is able to manipulate CSS information completely.
  All of the information is stored textually, in anticipation of cross-
  platform versions if Cascade. This will make the file a true text file,
  which can be more easily implemented under MacOS, Rhapsody, or YellowBox.
  All arrays use their natural datatypes, but will be all text when saved.
  Also newly supported is the "expandability" of the record. The OptionLevel
  specifies which extra features belong to the record. Currently only option
  level 0 is supported, which includes all features of Cascade. If an app-
  lication uses this class/component, it's the *application's responsibility*
  to see that OptionLevel for loaded classes are still 0!
 =============================================================================}
type
  TCSSRecord = Class(TComponent)
    Public
     Selector  : String[255];
     IsTagged  : Boolean; //determines whether the element is tagged
     OptionLevel : Integer;  //determines the "level" of the record. Currently 0.
     RecordType : TCSSRecordType; // the type of record
     CGroups   : Array[1..91] of Boolean;
     Lights    : Array[1..91] of Boolean;
     Spinners  : Array[1..53] of Extended;
     Selects   : Array[1..122] of String;
     Radios    : Array[1..133] of Boolean;
     Checks    : Array[1..27] of Boolean;
     Textuals  : Array[1..19] of String;
     Colorfuls : Array[1..7] of String;
     constructor Create(AOwner : TComponent); override;
     procedure Assign(Source : TCSSRecord);
     procedure Duplicate(Source : TCSSRecord);
     procedure AddToStream(var Target : String);
     procedure GetFromStream(var Source : String);
     procedure GetCSS(Dest : TStringList; SingleQuotes : Boolean);
  End; {CSSRecord type}

{=============================================================================
  TCascadeDocument Declaration
  This class is a complete Cascade document. Newly added is the OptionLevel,
  which makes the document expandable for future use. Currently only level 0
  is supported, which is everything provided by this version of Cascade. If
  an application uses *this* class/component, it's the application's respon-
  sibility to ensure that after the document has loaded, the OptionLevel is
  still at zero!
 =============================================================================}
type
  TCascadeDocument = Class(TComponent)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
      Procedure AddToStream(var Target : String);
      function GetFromStream(var Source : String) : Boolean;
      Procedure SaveDocument(FileName : String);
      Procedure OpenDocument(FileName : String);
      Procedure PutIntoTree(Target : TTreeView);
      Procedure GetFromTree(Source : TTreeView);
      Procedure GetCSS(Dest : TStringList; SingleQuotes, Tagged : Boolean);
      Procedure GetClasses(Dest : TStringList; Tagged : Boolean);
      function AddRecord(CSSRecord : TCSSRecord) : Integer;
      Procedure InsertRecord(Index: Integer; CSSRecord: TCSSRecord);
      Procedure InterpretCSS(theCSS : TStyleSheet);
      Procedure InterpretRule(CasDoc : TCSSRecord; CSSRule : TCSSRule);
  Private
      FAuthor      : ShortString;
      FAuthorMail  : ShortString;
      FAuthorURL   : ShortString;
      FAppName     : ShortString;
      FRecords     : TList; {list of TCSSRecords}
      FileSig      : String[14];
      FOptionLevel : Integer;  {options included in this file. Currently 0.}
  Published
      Property Author     : ShortString read FAuthor write FAuthor;
      Property AuthorMail : ShortString read FAuthorMail write FAuthorMail;
      Property AuthorURL  : ShortString read FAuthorURL  write FAuthorURL;
      Property AppName    : ShortString read FAppName write FAppName;
      Property Records    : TList read FRecords write FRecords;
      Property OptionLevel : Integer read FOptionLevel write FOptionLevel;
  End;

implementation
uses SysUtils, Dialogs, Forms;

const DefaultString : Array[1..122] of String = ( 'medium', 'larger', '%',
       'none', '%', '400 - normal', 'normal', 'normal', 'normal', 'normal', 'caption',
       '%', 'inherit', 'none', 'inherit', 'pt', 'normal', 'pt', 'normal',
       'none', 'normal', 'lines', 'normal', 'visible', '%', 'baseline',
       'inherit', 'pt', 'pt', 'pt', 'pt', 'auto', '%', 'auto', '%', 'auto',
       '%', 'auto', '%', 'auto', '%', '%', '%', '%', 'pt', 'medium', 'none',
       'pt', 'medium', 'none', 'pt', 'medium', 'none', 'pt', 'medium', 'none',
       'repeat', 'scroll', 'transparent', 'none', 'left', 'top', '%', '%',
       'auto', '%', 'auto', '%', 'auto', '%', 'auto', 'inline', 'static', 'ltr',
       'none', 'normal', 'none', 'auto', '%', 'auto', '%', '%', '%', 'auto',
       '%', '%', 'inherit', 'pt', 'auto', 'none', 'none', 'none', 'disc',
       'none', 'outside', 'auto', 'collapse', 'borders', 'once', 'top', '%',
       'auto', 'pt', 'medium', 'none', 'medium', 's', 'deg', 'center',
       'leftwards', 'auto', 's', 'deg', 'level', 'normal', 'none', 'none',
       'medium', 'medium', 'male', 'none', 'continuous');

      RecordOptionLevels : Array[0..0] of String = (
       {0}  'No Record Options'
            );

      DocumentOptionLevels : Array[0..1] of String = (
       {0}  'No Document Options',
       {1}  'Mixed Media Support'
            );

      C_CSS_LEVEL = 0;
      C_DOC_LEVEL = 1;
      C_FILE_SIG = 'WWS1VERSION2b1';

function StripQuotes(theS : String) : String; forward;
function Strip(theS : String) : String; forward;
function StringInSet(theSub, theString : String) : Boolean; forward;
function RightStr(theString : String; theLength : LongInt) : String; forward;
function LeftStr(theString : String; theLength : LongInt) : String; forward;
function ValueOf(theString : String) : Extended; forward;
function IsBorderAttribute(Attribute : String) : Boolean; forward;

{=============================================================================
  TCSSRecord Methods
 =============================================================================}

{-----------------------------------------------------------------------------
  TCSSRecord.Create
  Calls the inherited Create functions, and initializes to default values.
 -----------------------------------------------------------------------------}
constructor TCSSRecord.Create(AOwner : TComponent);
var i : Integer;
Begin
   inherited Create(AOwner);
   { now we tediously assign initial values to all of the data elements }
   For i := 1 to 91 do CGroups[i] := False;
   For i := 1 to 91 do Lights[i] := False;
   For i := 1 to 19 do Textuals[i] := '';
   Textuals[1] := 'Times';
   Textuals[2] := 'Times New Roman';
   Textuals[3] := 'serif';
   Textuals[10] := '“'; Textuals[11] := '”';
   Textuals[12] := '‘'; Textuals[13] := '’';
   For i := 1 to 54 do Spinners[i] := 0;
   Spinners[1] := 100;  Spinners[2] := 100;  Spinners[33] := 100;
   Spinners[36] := 100; Spinners[38] := 1;   Spinners[39] := 1;
   Spinners[43] := 50;  Spinners[44] := 100; Spinners[51] := 50;
   Spinners[52] := 50;  Spinners[53] := 50;
   For i := 1 to 133 do Radios[i] := False;
   Radios[2] := True;   Radios[3] := True;   Radios[7] := True;
   Radios[10] := True;  Radios[11] := True;  Radios[14] := True;
   Radios[16] := True;  Radios[18] := True;  Radios[20] := True;
   Radios[22] := True;  Radios[24] := True;  Radios[26] := True;
   Radios[28] := True;  Radios[29] := True;  Radios[31] := True;
   Radios[33] := True;  Radios[35] := True;  Radios[37] := True;
   Radios[39] := True;  Radios[41] := True;  Radios[43] := True;
   Radios[46] := True;  Radios[48] := True;  Radios[50] := True;
   Radios[52] := True;  Radios[54] := True;  Radios[56] := True;
   Radios[58] := True;  Radios[60] := True;  Radios[63] := True;
   Radios[65] := True;  Radios[67] := True;  Radios[69] := True;
   Radios[71] := True;  Radios[73] := True;  Radios[74] := True;
   Radios[76] := True;  Radios[79] := True;  Radios[80] := True;
   Radios[82] := True;  Radios[84] := True;  Radios[87] := True;
   Radios[89] := True;  Radios[91] := True;  Radios[93] := True;
   Radios[95] := True;  Radios[96] := True;  Radios[98] := True;
   Radios[100] := True; Radios[103] := True; Radios[106] := True;
   Radios[108] := True; Radios[110] := True; Radios[113] := True;
   Radios[115] := True; Radios[117] := True; Radios[119] := True;
   Radios[121] := True; Radios[123] := True; Radios[125] := True;
   Radios[127] := True; Radios[129] := True; Radios[131] := True;
   Radios[133] := True;
   For i := 1 to 27 do Checks[i] := False;
   Checks[1] := True;  Checks[2] := True;  Checks[3] := True;
   Checks[16] := True; Checks[17] := True; Checks[19] := True;
   Checks[20] := True; Checks[21] := True; Checks[19] := True;
   For i := 1 to 7 do Colorfuls[i] := 'white';
   Colorfuls[5] := 'black';  Colorfuls[7] := 'black';
   For i := 1 to 122 do Selects[i] := DefaultString[i];
   IsTagged := True;
   OptionLevel := C_CSS_LEVEL; {minimum level}
   Selector := 'ELEMENT';
   RecordType := rtElement;
End; {TCSSRecord.Create}

{-----------------------------------------------------------------------------
  TCSSRecord.Assign
  Creats a verbatim copy of Source
 -----------------------------------------------------------------------------}
procedure TCSSRecord.Assign(Source : TCSSRecord);
Begin
   Duplicate(Source);
   IsTagged := Source.IsTagged;
   Selector  := Source.Selector;
   OptionLevel := Source.OptionLevel;
   RecordType := Source.RecordType;
End; {TCSSRecord.Assign}

{-----------------------------------------------------------------------------
  TCSSRecord.Duplicate
  Creates a copy of the CSS1 data of source, but not the status information
 -----------------------------------------------------------------------------}
procedure TCSSRecord.Duplicate(Source : TCSSRecord);
Begin
   CGroups   := Source.CGroups;
   Lights    := Source.Lights;
   Spinners  := Source.Spinners;
   Selects   := Source.Selects;
   Radios    := Source.Radios;
   Checks    := Source.Checks;
   Textuals  := Source.Textuals;
   Colorfuls := Source.Colorfuls;
   OptionLevel := Source.OptionLevel;
End; {TCSSRecord.Duplicate}

{-----------------------------------------------------------------------------
  TCSSRecord.AddToStream
  Puts the data into a TStrings. We are going to do this textually. The stream
  for a TCSSRecord should look like this, starting with the first byte:
  o Selector, a stream of length (ASCII) + Chars, i.e., 01P
  o Record Type - a single character Ord its value
  o IsTagged - a single byte 0 or 1
  o OptionLevel (single, textual byte) - designates the BIT of the option. In
     this case, since there are no options, the bit will be zero. Each add-
     itional option (as added) will add its own bit.
  o CGroups stream - a stream of 91 characters, either 0 or 1
  o Lights stream - a stream of 91 characters, either 0 or 1
  o Radios stream - a stream of 133 characters, either 0 or 1
  o Checks stream - a stream of 27 characters, either 0 or 1
  o Spinners stream - a stream of length (ASCII) + Chars, i.e., 73.14159
  o Textuals stream - a stream of length (ASCII) + Chars, i.e., 05Hello
  o Selects stream - a stream of length (ASCII) + Chars, i.e., 09inherited
  o Colorfuls stream - a stream of length (ASCII) + Chars, i.e., 03red
  o Optional Streams - not used. As options are added, the initial OptionLevel
      tells the program that more data follows. Since OptionLevel is currently
      0, this tells the program that any bytes following the previous stream
      are part of the next record.
  o End-Of-Record Marker - the #0
 -----------------------------------------------------------------------------}
procedure TCSSRecord.AddToStream(var Target : String);
var h, i : String;
    j    : Integer;
   Procedure Add(theStr : String);
   Begin
      Target := Target + theStr;
   End;
Begin
   // write the selector's length, and then the selector
   i := Format('%2.2d', [Length(Selector)]);
   Add(i);
   Add(Selector);
   // write the record type
   i := Format('%1.1d', [Ord(RecordType)]);
   Add(i);
   // write the IsTagged character
   i := '0';
   If IsTagged then i := '1';
   Add(i);
   // write the OptionLevel byte;
   i := Format('%1.1d',  [OptionLevel]);
   Add(i);
   // write the CGroups stream
   For j := 1 to 91 do Begin
      i := '0';
      If CGroups[j] then i := '1';
      Add(i);
   End; {for}
   // write the Lights stream
   For j := 1 to 91 do Begin
      i := '0';
      If Lights[j] then i := '1';
      Add(i);
   End; {for}
   // write the Radios stream
   For j := 1 to 133 do Begin
      i := '0';
      If Radios[j] then i := '1';
      Add(i);
   End; {for}
   // write the Checks stream
   For j := 1 to 27 do Begin
      i := '0';
      If Checks[j] then i := '1';
      Add(i);
   End; {for}
   // write the Spinners stream
   For j := 1 to 53 do Begin
      h := FloatToStr(Spinners[j]);
      i := Format('%1.1d', [Length(h)]);
      Add(i);
      Add(h);
   End; {for}
   // write the Textuals stream
   For j := 1 to 19 do Begin
      h := Textuals[j];
      i := Format('%2.2d', [Length(h)]);
      Add(i);
      Add(h);
   End; {for}
   // write the Selects stream
   For j := 1 to 122 do Begin
      h := Selects[j];
      i := Format('%2.2d', [Length(h)]);
      Add(i);
      Add(h);
   End; {for}
   // write the Colorfuls stream
   For j := 1 to 7 do Begin
      h := Colorfuls[j];
      i := Format('%2.2d', [Length(h)]);
      Add(i);
      Add(h);
   End; {for}
   { at this point, we would start writing out OptionLevel=1 data }
   { since there are no options, we simply add the End-Of-Record marker }
   Add(#0);
End; {TCSSRecord.AddToStream}


{-----------------------------------------------------------------------------
  TCSSRecord.GetFromStream
  Reads the record back from the stream. See notes for TCSSRecord.AddToStream.
 -----------------------------------------------------------------------------}
procedure TCSSRecord.GetFromStream(var Source : String);
var j : Integer;
    function Extract(num : Integer) : String;
    Begin
       Result := Copy(Source, 1, num);
       Delete(Source, 1, num);
    End; {Extract}
Begin
   // read the selector's length, and then the selector
   Selector := Extract(StrToInt(Extract(2)));
   // read the record type
   RecordType := rtElement;
   j := StrToInt(Extract(1));
   while Ord(RecordType) <> j do Inc(RecordType);
   // read the IsTagged character
   IsTagged := Boolean(StrToInt(Extract(1)));
   // read the OptionLevel byte
   OptionLevel := StrToInt(Extract(1));
   // read the CGroups stream
   For j := 1 to 91 do CGroups[j] := Boolean(StrToInt(Extract(1)));
   // read the Lights stream
   For j := 1 to 91 do Lights[j] := Boolean(StrToInt(Extract(1)));
   // read the Radios stream
   For j := 1 to 133 do Radios[j] := Boolean(StrToInt(Extract(1)));
   // read the Checks stream
   For j := 1 to 27 do Checks[j] := Boolean(StrToInt(Extract(1)));
   // read the Spinners stream
   For j := 1 to 53 do
      Spinners[j] := StrToFloat(Extract(StrToInt(Extract(1))));
   // read the Textuals stream
   For j := 1 to 19 do Textuals[j] := Extract(StrToInt(Extract(2)));
   // read the Selects stream
   For j := 1 to 122 do Selects[j] := Extract(StrToInt(Extract(2)));
   // read the Colorfuls stream
   For j := 1 to 7 do Colorfuls[j] := Extract(StrToInt(Extract(2)));
   { at this point, we would start reading in OptionLevel>0 data }
   { just in case this program is used later to attempt to open a file with }
   { options, we need to read past any option data until #0}
   Repeat Until Extract(1) = #0;
End; {TCSSRecord.GetFromStream}

{-----------------------------------------------------------------------------
  TCSSRecord.GetCSS
  Simply append the textuals data to the list passed into it.
 -----------------------------------------------------------------------------}
Procedure TCSSRecord.GetCSS(Dest : TStringList; SingleQuotes : Boolean);
const C = ', ';      // simplifies the comma-space
      S = '''';      // simplifies the single quotation mark
      N = 'inherit'; // avoids retyping 'inherit' all the time
var tmpStr : String;
         i : integer;
         Q : String; // simplifies the quotation mark
     {----------------------------------------------------------}
     { This little gem helps a bit with outputting results, etc }
     {----------------------------------------------------------}
     procedure PutOut(num : integer);
     Begin
        if Lights[num] then tmpStr := tmpStr + ' ! IMPORTANT';
        tmpStr := '          ' + tmpStr + ';';
        Dest.Add(tmpStr);
     End;
     {----------------------------------------------------------}
     { This little thing makes it simpler to add to tmpStr      }
     {----------------------------------------------------------}
     procedure Add( what : String);
     Begin
        tmpStr := tmpStr + what;
     End;
     {----------------------------------------------------------}
Begin
   If RecordType = rtMedia then Exit;
   { set up Q}
   Q := '"';
   If SingleQuotes then Q := '''';
   { set up the first line }
   Dest.Add('   ' + Selector + ' {');

   {------------}
   { Font Panel }
   {------------}

   If CGroups[1] then Begin {font-family}
      tmpStr := 'font-family: ';
      If Radios[1] then Begin
         If Checks[1] then Add(Q + Textuals[1] + Q);
         If (Checks[1] and Checks[2]) then Add(C);
         If Checks[2] then Add(Q + Textuals[2] + Q);
         If ((Checks[1] and Checks[3]) or (Checks[2]) and Checks[3]) then
            Add(C);
         If Checks[3] then Add(Q + Textuals[3] + Q);
      End {if} Else
         Add(N);
      PutOut(1);
   End; {font-family}

   If CGroups[2] then Begin {font-size}
      tmpStr := 'font-size: ';
      If Radios[3] then Add(Selects[1]);
      If Radios[4] then Add(Selects[2]);
      If Radios[5] then Add(FloatToStr(Spinners[1]) + Selects[3]);
      If Radios[6] then Add(N);
      PutOut(2);
   End; {font-size}

   If CGroups[3] then Begin {font-size-adjust}
      tmpStr := 'font-size-adjust: ';
      If Radios[7] then Add(Selects[4]);
      If Radios[8] then Add(FloatToStr(Spinners[2]) + Selects[5]);
      PutOut(3);
   End; {font-size-adjust}

   If CGroups[4] then Begin {font-weight}
      tmpStr := 'font-weight: ';
      If Radios[9] then Add(Copy(Selects[6],1,3));
      If Radios[10] then Add(Selects[7]);
      PutOut(4);
   End;

   If CGroups[5] then Begin {font-variant}
      tmpStr := 'font-variant: ' + Selects[8];
      PutOut(5);
   End; {font-variant}

   If CGroups[6] then Begin {font-style}
      tmpStr := 'font-style: ' + Selects[9];
      PutOut(6);
   End; {font-style}

   If CGroups[7] then Begin {font-stretch}
      tmpStr := 'font-stretch: ' + Selects[10];
      PutOut(7);
   End; {font-stretch}

   If CGroups[8] then Begin {font}
      tmpStr := 'font: ' + Selects[11];
      PutOut(8);
   End; {font}

   {------------}
   { Text Panel }
   {------------}
   If CGroups[9] then Begin {text-indent}
      tmpStr := 'text-indent: ';
      If Radios[11] then Add(FloatToStr(Spinners[3]) + Selects[12]);
      If Radios[12] then Add(N);
      PutOut(9);
   End; {text-indent}

   If CGroups[10] then Begin {text-align}
      tmpStr := 'text-align: ';
      If Radios[13] then Add(Textuals[4]);
      If Radios[14] then Add(Selects[13]);
      PutOut(10);
   End; {text-align}

   If CGroups[11] then Begin {text-decoration}
      tmpStr := 'text-decoration: ';
      If Radios[15] then Begin
         If Checks[4] then Add('underline ');
         If Checks[5] then Add('line-through ');
         If Checks[6] then Add('overline ');
         If Checks[7] then Add('blink');
      End;
      If Radios[16] then Add(Selects[14]);
      PutOut(11);
   End; {text-decoration}

   If CGroups[12] then Begin {text-shadow}
      tmpStr := 'text-shadow: ';
      If Radios[17] then Add(Textuals[5]);
      If Radios[18] then Add(Selects[15]);
      PutOut(12);
   End; {text-shadow}

   If CGroups[13] then Begin {letter-spacing}
      tmpStr := 'letter-spacing: ';
      If Radios[19] then Add(FloatToStr(Spinners[4]) + Selects[16]);
      If Radios[20] then Add(Selects[17]);
      PutOut(13);
   End; {letter-spacing}

   If CGroups[14] then Begin {word-spacing}
      tmpStr := 'word-spacing: ';
      If Radios[21] then Add(FloatToStr(Spinners[5]) + Selects[18]);
      If Radios[22] then Add(Selects[19]);
      PutOut(14);
   End; {word-spacing}

   If CGroups[15] then Begin {text-transform}
      tmpStr := 'text-transform: ' + Selects[20];
      PutOut(15);
   End; {text-transform}

   If CGroups[16] then Begin {white-space}
      tmpStr := 'white-space: ' + Selects[21];
      PutOut(16);
   End; {white-space}

   {-----------------}
   { Alignment Panel }
   {-----------------}

   If CGroups[17] then Begin {line-height}
      tmpStr := 'line-height: ';
      If Radios[23] then Begin
         Add(FloatToStr(Spinners[6]));
         If Selects[22] <> 'lines' then Add(Selects[22]);
      End;
      If Radios[24] then Add(Selects[23]);
      PutOut(17);
   End; {line-height}

   If CGroups[18] then Begin {overflow}
      tmpStr := 'overflow: ' + Selects[24];
      PutOut(18);
   End;  {overflow}

   If CGroups[19] then Begin {vertical-align}
      tmpStr := 'vertical-align: ';
      If Radios[25] then Add(FloatToStr(Spinners[7]) + Selects[25]);
      If Radios[26] then Add(Selects[26]);
      PutOut(19);
   End; {vertical-align}

   If CGroups[20] then Begin {visibility}
      tmpStr := 'visibility: ' + Selects[27];
      PutOut(20);
   End; {visibility}

   If CGroups[21] then Begin {clip}
      tmpStr := 'clip: ';
      If Radios[27] then Begin {top right bottom left}
         Add('rect( ');
         if Selects[28] <> 'auto' then Add(FloatToStr(Spinners[8]) + Selects[28] + C) else Add(Selects[28] + C);  {top}
         if Selects[31] <> 'auto' then Add(FloatToStr(Spinners[11])+ Selects[31] + C) else Add(Selects[31] + C);  {right}
         if Selects[29] <> 'auto' then Add(FloatToStr(Spinners[9])  + Selects[29] + C) else Add(Selects[29] + C); {bottom}
         if Selects[30] <> 'auto' then Add(FloatToStr(Spinners[10]) + Selects[30]) else Add(Selects[30]);         {left}
         Add(' )');
      End;
      If Radios[28] then Add(Selects[32]);
      PutOut(21);
   End; {clip}

   {---------------}
   { Margins Panel }
   {---------------}

   If CGroups[22] then Begin {margin-top}
      tmpStr := 'margin-top: ';
      If Radios[29] then Add(FloatToStr(Spinners[12]) + Selects[33]);
      If Radios[30] then Add(Selects[34]);
      PutOut(22);
   End; {margin-top}

   If CGroups[23] then Begin {margin-bottom}
      tmpStr := 'margin-bottom: ';
      If Radios[31] then Add(FloatToStr(Spinners[13]) + Selects[35]);
      If Radios[32] then Add(Selects[36]);
      PutOut(23);
   End; {margin-bottom}

   If CGroups[24] then Begin {margin-left}
      tmpStr := 'margin-left: ';
      If Radios[33] then Add(FloatToStr(Spinners[14]) + Selects[37]);
      If Radios[34] then Add(Selects[38]);
      PutOut(24);
   End;  {margin-left}

   If CGroups[25] then Begin {margin-right}
      tmpStr := 'margin-right: ';
      If Radios[35] then Add(FloatToStr(Spinners[15]) + Selects[39]);
      If Radios[36] then Add(Selects[40]);
      PutOut(25);
   End; {margin-right}

   If CGroups[26] then Begin {padding-top}
      tmpStr := 'padding-top: ';
      If Radios[37] then Add(FloatToStr(Spinners[16]) + Selects[41]);
      If Radios[38] then Add(N);
      PutOut(26);
   End; {padding-top}

   If CGroups[27] then Begin {padding-bottom}
      tmpStr := 'padding-bottom: ';
      If Radios[39] then Add(FloatToStr(Spinners[17]) + Selects[42]);
      If Radios[40] then Add(N);
      PutOut(27);
   End; {padding-bottom}

   If CGroups[28] then Begin {padding-left}
      tmpStr := 'padding-left: ';
      If Radios[41] then Add(FloatToStr(Spinners[18]) + Selects[43]);
      If Radios[42] then Add(N);
      PutOut(28);
   End; {padding-left}

   If CGroups[29] then Begin {padding-right}
      tmpStr := 'padding-right: ';
      If Radios[43] then Add(FloatToStr(Spinners[19]) + Selects[44]);
      If Radios[44] then Add(N);
      PutOut(29);
   End; {padding-right}

   {---------------}
   { Borders Panel }
   {---------------}

   If CGroups[30] then Begin {border-top}
      tmpStr := 'border-top: ';
      If Radios[45] then Add(FloatToStr(Spinners[20]) + Selects[45]);
      If Radios[46] then Add(Selects[46]);
      If Checks[8] then Add(' ' + Selects[47]);
      If Checks[9] then Add(' ' + Colorfuls[1]);
      PutOut(30);
   End; {border-top}

   If CGroups[31] then Begin {border-bottom}
      tmpStr := 'border-bottom: ';
      If Radios[47] then Add(FloatToStr(Spinners[21]) + Selects[48]);
      If Radios[48] then Add(Selects[49]);
      If Checks[10] then Add(' ' + Selects[50]);
      If Checks[11] then Add(' ' + Colorfuls[2]);
      PutOut(31);
   End; {border-bottom}

   If CGroups[32] then Begin {border-left}
      tmpStr := 'border-left: ';
      If Radios[49] then Add(FloatToStr(Spinners[22]) + Selects[51]);
      If Radios[50] then Add(Selects[52]);
      If Checks[12] then Add(' ' + Selects[53]);
      If Checks[13] then Add(' ' + Colorfuls[3]);
      PutOut(32);
   End; {border-left}

   If CGroups[33] then Begin {border-right}
      tmpStr := 'border-right: ';
      If Radios[51] then Add(FloatToStr(Spinners[23]) + Selects[54]);
      If Radios[52] then Add(Selects[55]);
      If Checks[14] then Add(' ' + Selects[56]);
      If Checks[15] then Add(' ' + Colorfuls[4]);
      PutOut(33);
   End; {border-right}

   {------------------------}
   { Color/Background Panel }
   {------------------------}

   If CGroups[34] then Begin {color}
      tmpStr := 'color: ';
      If Radios[53] then Add(Colorfuls[5]);
      If Radios[54] then Add(N);
      PutOut(34);
   End; {color}

   If CGroups[35] then Begin {background-repeat}
      tmpStr := 'background-repeat: ' + Selects[57];
      PutOut(35);
   End; {background-repeat}

   If CGroups[36] then Begin {background-attachment}
      tmpStr := 'background-attachment: ' + Selects[58];
      PutOut(36);
   End; {background-attachment}

   If CGroups[37] then Begin {background-color}
      tmpStr := 'background-color: ';
      If Radios[55] then Add(Colorfuls[6]);
      If Radios[56] then Add(Selects[59]);
      PutOut(37);
   End; {background-color}

   If CGroups[38] then Begin {background-image}
      tmpStr := 'background-image: ';
      If Radios[57] then Add('url(' + Textuals[6] + ')');
      If Radios[58] then Add(Selects[60]);
      PutOut(38);
   End; {background-image}

   If CGroups[39] then Begin {background-position}
      tmpStr := 'background-position: ';
      If Radios[59] then Begin
         Add(Selects[61]);
         If Checks[16] then Add(' ' + Selects[62]);
      End;
      If Radios[60] then Begin
         Add(FloatToStr(Spinners[24]) + Selects[63]);
         If Checks[16] then Add(' ' + FloatToStr(Spinners[25]) + Selects[63]);
      End;
      If Radios[61] then Add(N);
      PutOut(39);
   End; {background-position}

   {-----------------}
   { Rendering Panel }
   {-----------------}

   If CGroups[40] then Begin {top}
      tmpStr := 'top: ';
      If Radios[62] then Add(FloatToStr(Spinners[26]) + Selects[64]);
      If Radios[63] then Add(Selects[65]);
      PutOut(40);
   End; {top}

   If CGroups[41] then Begin {bottom}
      tmpStr := 'bottom: ';
      If Radios[64] then Add(FloatToStr(Spinners[27]) + Selects[66]);
      If Radios[65] then Add(Selects[67]);
      PutOut(41);
   End; {bottom}

   If CGroups[42] then Begin {left}
      tmpStr := 'left: ';
      If Radios[66] then Add(FloatToStr(Spinners[28]) + Selects[68]);
      If Radios[67] then Add(Selects[69]);
      PutOut(42);
   End; {left}

   If CGroups[43] then Begin {right}
      tmpStr := 'right: ';
      If Radios[68] then Add(FloatToStr(Spinners[29]) + Selects[70]);
      If Radios[69] then Add(Selects[71]);
      PutOut(43);
   End; {right}

   If CGroups[44] then Begin {display}
      tmpStr := 'display: ' + Selects[72];
      PutOut(44);
   End; {display}

   If CGroups[45] then Begin {position}
      tmpStr := 'position: ' + Selects[73];
      PutOut(45);
   End; {position}

   If CGroups[46] then Begin {direction}
      tmpStr := 'direction: ' + Selects[74];
      PutOut(46);
   End; {direction}

   If CGroups[47] then Begin {clear}
      tmpStr := 'clear: ' + Selects[75];
      PutOut(47);
   End; {clear}

   If CGroups[48] then Begin {unicode-bidi}
      tmpStr := 'unicode-bidi: ' + Selects[76];
      PutOut(48);
   End; {unicode-bidi}

   If CGroups[49] then Begin {float}
      tmpStr := 'float: ' + Selects[77];
      PutOut(49);
   End; {float}

   If CGroups[50] then Begin {z-index}
      tmpStr := 'z-index: ';
      If Radios[70] then Add(FloatToStr(Spinners[30]));
      If Radios[71] then Add(Selects[78]);
      PutOut(50);
   End; {z-index}

   {----------------------}
   { Box Dimensions Panel }
   {----------------------}

   If CGroups[51] then Begin {width}
      tmpStr := 'width: ';
      If Radios[72] then Add(FloatToStr(Spinners[31]) + Selects[79]);
      If Radios[73] then Add(Selects[80]);
      PutOut(51);
   End; {width}

   If CGroups[52] then Begin {min-width}
      tmpStr := 'min-width: ';
      If Radios[74] then Add(FloatToStr(Spinners[32]) + Selects[81]);
      If Radios[75] then Add(N);
      PutOut(52);
   End; {min-width}

   If CGroups[53] then Begin {max-width}
      tmpStr := 'max-width: ';
      If Radios[76] then Add(FloatToStr(Spinners[33]) + Selects[82]);
      If Radios[77] then Add(N);
      PutOut(53);
   End; {max-width}

   If CGroups[54] then Begin {height}
      tmpStr := 'height: ';
      If Radios[78] then Add(FloatToStr(Spinners[34]) + Selects[83]);
      If Radios[79] then Add(Selects[84]);
      PutOut(54);
   End; {height}

   If CGroups[55] then Begin {min-height}
      tmpStr := 'min-height: ';
      If Radios[80] then Add(FloatToStr(Spinners[35]) + Selects[85]);
      If Radios[81] then Add(N);
      PutOut(55);
   End; {min-height}

   If CGroups[56] then Begin {max-height}
      tmpStr := 'max-height: ';
      If Radios[82] then Add(FloatToStr(Spinners[36]) + Selects[86]);
      If Radios[83] then Add(N);
      PutOut(56);
   End; {max-height}

   {-------------------------}
   { Generated Content Panel }
   {-------------------------}

   If CGroups[57] then Begin {content}
      tmpStr := 'content: ';
      If Radios[84] then Add(Textuals[7]);
      If Radios[85] then Add(Selects[87]);
      PutOut(57);
   End; {content}

   If CGroups[58] then Begin {marker-offset}
      tmpStr := 'marker-offset: ';
      If Radios[86] then Add(FloatToStr(Spinners[37]) + Selects[88]);
      If Radios[87] then Add(Selects[89]);
      PutOut(58);
   End; {marker-offset}

   If CGroups[59] then Begin {counter-reset}
      tmpStr := 'counter-reset: ';
      If Radios[88] then Add(Textuals[8]);
      If Radios[89] then Add(Selects[90]);
      PutOut(59);
   End; {counter-reset}

   If CGroups[60] then Begin {counter-increment}
      tmpStr := 'counter-increment: ';
      If Radios[90] then Add(Textuals[9]);
      If Radios[91] then Add(Selects[91]);
      PutOut(60);
   End; {counter-increment}

   If CGroups[61] then Begin {quotes}
      tmpStr := 'quotes: ';
      If Radios[92] then
         For i := 10 to 13 do
            If Textuals[i] = '"' then
               Add(S + Textuals[i] + S + ' ')
            Else
               Add(Q + Textuals[i] + Q + ' ');
      If Radios[93] then Add(Selects[92]);
      PutOut(61);
   End; {quotes}

   {-------------}
   { Lists Panel }
   {-------------}

   If CGroups[62] then Begin {list-style-type}
      tmpStr := 'list-style-type: ' + Selects[93];
      PutOut(62);
   End; {list-style-type}

   If CGroups[63] then Begin {list-style-image}
      tmpStr := 'list-style-image: ';
      If Radios[94] then Add('url(' + Textuals[14] + ')');
      If Radios[95] then Add(Selects[94]);
      PutOut(63);
   End; {list-style-image}

   If CGroups[64] then Begin {list-style-position}
      tmpStr := 'list-style-position: ' + Selects[95];
      PutOut(64);
   End; {list-style-position}

   {--------------}
   { Tables Panel }
   {--------------}

   If CGroups[65] then Begin {table-layout}
      tmpStr := 'table-layout: ' + Selects[96];
      PutOut(65);
   End; {table-layout}

   If CGroups[66] then Begin {border-collapse}
      tmpStr := 'border-collapse: ' + Selects[97];
      PutOut(66);
   End; {border-collapse}

   If CGroups[67] then Begin {empty-cells}
      tmpStr := 'empty-cells: ' + Selects[98];
      PutOut(67);
   End; {empty-cells}

   If CGroups[68] then Begin {speak-header}
      tmpStr := 'speak-header: ' + Selects[99];
      PutOut(68);
   End; {speak-header}

   If CGroups[69] then Begin {caption-side}
      tmpStr := 'caption-side: ' + Selects[100];
      PutOut(69);
   End; {caption-side}

// row-span and column-span are no longer part of the specification   
(*   If CGroups[70] then Begin {row-span}
      tmpStr := 'row-span: ';
      If Radios[96] then Add(FloatToStr(Spinners[38]));
      If Radios[97] then Add(N);
      PutOut(70);
   End; {row-span}

   If CGroups[71] then Begin {column-span}
      tmpStr := 'column-span: ';
      If Radios[98] then Add(FloatToStr(Spinners[39]));
      If Radios[99] then Add(N);
      PutOut(71);
   End; {column-span}
*)
   If CGroups[72] then Begin {border-spacing}
      tmpStr := 'border-spacing: ';
      If Radios[100] then Begin
         Add(FloatToStr(Spinners[40]) + Selects[101]);
         If Checks[17] then Add(' ' + FloatToStr(Spinners[41]) + Selects[101]);
      End;
      If Radios[101] then Add(N);
      PutOut(72);
   End;  {border-spacing}

   {---------------------}
   { Miscellaneous Panel }
   {---------------------}

   If CGroups[73] then Begin {cursor}
      tmpStr := 'cursor: ';
      If Checks[18] then Add(Textuals[15]);
      If (Checks[18] and Checks[19]) then Add(', ');
      If Checks[19] then Add(Selects[102]);
      PutOut(73);
   End; {cursor}

   If CGroups[74] then Begin {outline}
      tmpStr := 'outline: ';
      If Radios[102] then Add(FloatToStr(Spinners[42]) + Selects[103]);
      If Radios[103] then Add(Selects[104]);
      If Checks[20] then Add(' ' + Selects[105]);
      If Checks[21] and not Checks[22] then Add(' ' + Colorfuls[7]);
      If Checks[21] and Checks[22] then Add(' invert');
      PutOut(74);
   End; {outline}

   {----------------------}
   { Aural Settings Panel }
   {----------------------}

   If CGroups[75] then Begin {volume}
      tmpStr := 'volume: ';
      If Radios[104] then Add(FloatToStr(Spinners[43]));
      If Radios[105] then Add(FloatToStr(Spinners[44]) + '%');
      If Radios[106] then Add(Selects[106]);
      PutOut(75);
   End; {volume}

   If CGroups[76] then Begin {pause-before}
      tmpStr := 'pause-before: ';
      If Radios[107] then Add(FloatToStr(Spinners[45]) + Selects[107]);
      If Radios[108] then Add(N);
      PutOut(76);
   End; {pause-before}

   If CGroups[77] then Begin {azimuth}
      tmpStr := 'azimuth: ';
      If Radios[109] then Add(FloatToStr(Spinners[46]) + Selects[108]);
      If Radios[110] then Begin
         If Checks[23] then Add('behind ');
         Add(Selects[109]);
      End;
      If Radios[111] then Add(Selects[110]);
      PutOut(77);
   End; {azimuth}

   If CGroups[78] then Begin {play-during}
      tmpStr := 'play-during: ';
      If Radios[112] then Begin
         Add('url(' + Textuals[16] + ')');
         If Checks[24] then Add(' mix');
         If Checks[25] then Add(' repeat');
      End;
      If Radios[113] then Add(Selects[111]);
      PutOut(78);
   End; {play-during}

   If CGroups[79] then Begin {pause-after}
      tmpStr := 'pause-after: ';
      If Radios[114] then Add(FloatToStr(Spinners[47]) + Selects[112]);
      If Radios[115] then Add(N);
      PutOut(79);
   End; {pause-after}

   If CGroups[80] then Begin {elevation}
      tmpStr := 'elevation: ';
      If Radios[116] then Add(FloatToStr(Spinners[48]) + Selects[113]);
      If Radios[117] then Add(Selects[114]);
      PutOut(80);
   End; {elevation}

   If CGroups[81] then Begin {speak}
      tmpStr := 'speak: ' + Selects[115];
      PutOut(81);
   End; {speak}

   {-----------------------------}
   { Aural Characteristics Panel }
   {-----------------------------}

   If CGroups[82] then Begin {cue-before}
      tmpStr := 'cue-before: ';
      If Radios[118] then Add('url(' + Textuals[17] + ')');
      If Radios[119] then Add(Selects[116]);
      PutOut(82);
   End; {cue-before}

   If CGroups[83] then Begin {cue-after}
      tmpStr := 'cue-after: ';
      If Radios[120] then Add('url(' + Textuals[18] + ')');
      If Radios[121] then Add(Selects[117]);
      PutOut(83);
   End; {cue-after}

   If CGroups[84] then Begin {pitch}
      tmpStr := 'pitch: ';
      If Radios[122] then Add(FloatToStr(Spinners[49]) + 'hz');
      If Radios[123] then Add(Selects[118]);
      PutOut(84);
   End; {pitch}

   If CGroups[85] then Begin {speech-rate}
      tmpStr := 'speech-rate: ';
      If Radios[124] then Add(FloatToStr(Spinners[50]));
      If Radios[125] then Add(Selects[119]);
      PutOut(85);
   End; {speech-rate}

   If CGroups[86] then Begin {voice-family}
      tmpStr := 'voice-family: ';
      If Radios[126] then Begin
         If Checks[26] then Add(Textuals[19]);
         If (Checks[26] and Checks[27]) then Add(', ');
         If Checks[27] then Add(Selects[120]);
      End;
      If Radios[127] then Add(N);
      PutOut(86);
   End; {voice-family}

   If CGroups[87] then Begin {richness}
      tmpStr := 'richness: ';
      If Radios[128] then Add(FloatToStr(Spinners[51]));
      If Radios[129] then Add(N);
      PutOut(87);
   End; {richness}

   If CGroups[88] then Begin {pitch-range}
      tmpStr := 'pitch-range: ';
      If Radios[130] then Add(FloatToStr(Spinners[52]));
      If Radios[131] then Add(N);
      PutOut(88);
   End; {pitch-range}

   If CGroups[89] then Begin {stress}
      tmpStr := 'stress: ';
      If Radios[132] then Add(FloatToStr(Spinners[53]));
      If Radios[133] then Add(N);
      PutOut(89);
   End; {stress}

   If CGroups[90] then Begin {speak-punctuation}
      tmpStr := 'speak-punctuation: ' + Selects[121];
      PutOut(90);
   End; {speak-punctuation}

   If CGroups[91] then Begin {speak-numeral}
      tmpStr := 'speak-numeral: ' + Selects[122];
      PutOut(91);
   End; {speak-numeral}

   {add the final, closing lines}
   tmpStr := '';
   For i := 1 to Length(Selector)+4 do tmpStr := tmpStr + ' ';
   Dest.Add(tmpStr + '}');
   tmpStr := '';
   Dest.Add(tmpStr);
End; {TCSSRecord.GetHTML}


{=============================================================================
  TCascadeDocument Methods
 =============================================================================}

{-----------------------------------------------------------------------------
 TCascadeDocument.Create
 Creates the FRecords list, and initializes some fields.
-----------------------------------------------------------------------------}
constructor TCascadeDocument.Create(AOwner : TComponent);
Begin
   inherited Create(AOwner);
   FRecords := TList.Create;
   FAuthor := '<author name>';
   FAuthorMail := '<author email>';
   FAuthorURL := '<author url>';
   FAppName := Application.Title;
   FOptionLevel := C_DOC_LEVEL;
   FileSig := C_FILE_SIG;
End;{TCascadeDocument.Create}

{-----------------------------------------------------------------------------
 TCascadeDocument.Destroy
 Fress the FRecords list
-----------------------------------------------------------------------------}
destructor TCascadeDocument.Destroy;
Begin
   FRecords.Free;
   inherited Destroy;
End; {TCascadeDocument.Destroy}

{-----------------------------------------------------------------------------
 TCascadeDocument.AddToStream
 Places the entire Cascade document into the Target stream. This is textual,
 so our "fields" in the stream are going to be thus:
  o File Signature -- a stream of length-2 (ASCII) + char-n
  o OptionLevel    -- a stream of char-1
  o AppName        -- a stream of length-3 (ASCII) + char-n
  o AuthorName     -- a stream of length-3 (ASCII) + char-n
  o AuthorMail     -- a stream of length-3 (ASCII) + char-n
  o AuthorURL      -- a stream of length-3 (ASCII) + char-n
  o RecordCount    -- a stream of char-4
  o Records        -- in user's order, a stream of TCSSRecords. Since the
                      record can read itself (even if it's a higher Option-
                      Level), and because we have a record count, we know
                      the *anything* remaining in the file is a future option,
                      and can be safely ignored.
  o Optional Streams -- not used. As options are added, the initial OptionLevel
                      tells the program that more data follows. Since
                      OptionLevel is currently 0, this tells the program that
                      any bytes following the previous streams are part of
                      some future options.
-----------------------------------------------------------------------------}
Procedure TCascadeDocument.AddToStream(var Target : String);
var i : String;
    j : Integer;
   Procedure Add(theStr : String);
   Begin
      Target := Target + theStr;
   End;
Begin
   // initialize the stream
   Target := '';
   // write the file signature
   i := Format('%2.2d', [Length(FileSig)]);
   Add(i);
   Add(FileSig);
   // write the option level
   i := Format('%1.1d', [FOptionLevel]);
   Add(i);
   // write the AppName
   i := Format('%3.3d', [Length(FAppName)]);
   Add(i);
   Add(FAppName);
   // write the AuthorName
   i := Format('%3.3d', [Length(FAuthor)]);
   Add(i);
   Add(FAuthor);
   // write the AuthorMail
   i := Format('%3.3d', [Length(FAuthorMail)]);
   Add(i);
   Add(FAuthorMail);
   // write the AuthorURL
   i := Format('%3.3d', [Length(FAuthorURL)]);
   Add(i);
   Add(FAuthorURL);
   // write the RecordCount
   i := Format('%4.4d', [FRecords.Count]);
   Add(i);
   // write the Records
   For j := 0 to FRecords.Count - 1 do
      TCSSRecord(FRecords.Items[j]).AddToStream(Target);
   // this is where we would add the Options in the future.
End; {TCascadeDocument.AddToStream}

{-----------------------------------------------------------------------------
  TCascadeDocument.GetFromStream
  Reads a Cascade document from the Source stream. Returns *false* if the
  document is not a valid document. Will digest any future option levels.
 -----------------------------------------------------------------------------}
function TCascadeDocument.GetFromStream(var Source : String) : Boolean;
var i    : String;
    j, k : Integer;
    aRec : TCSSRecord;
    function Extract(num : Integer) : String;
    Begin
       Result := Copy(Source, 1, num);
       Delete(Source, 1, num);
    End; {Extract}
Begin
   // set the return reseult to false, signalling *not* accomplished
   Result := False;
   // read the file signature
   i := Extract(StrToInt(Extract(2)));
   // make sure it's a Cascade2 document
   If i <> FileSig then Exit;
   // read the OptionLevel
   FOptionLevel := StrToInt(Extract(1));
   // read the AppName
   FAppName := Extract(StrToInt(Extract(3)));
   // read the AuthorName
   FAuthor := Extract(StrToInt(Extract(3)));
   // read the AuthorMail
   FAuthorMail := Extract(StrToInt(Extract(3)));
   // read the AuthorURL
   FAuthorURL := Extract(StrToInt(Extract(3)));
   // read the RecordCount
   k := StrToInt(Extract(4));
   // read the Records
   FRecords.Clear;
   For j := 1 to k do Begin
      aRec := TCSSRecord.Create(nil);  // create a new record
      aRec.GetFromStream(Source);      // read in the data
      FRecords.Add(aRec);              // add it to the list
   End;
   // this is where we would read the Options in the future.
   // finally, set the result to true, meaning all is okay.
   Result := True;
End; {TCascadeDocument.GetFromStream}

{-----------------------------------------------------------------------------
  TCascadeDocument.SaveDocument
   Given a filename, saves itself to a file, replacing any file that alreay
   exists. This is a "dumb-save." It merely works or it doesn't. The develop-
   er can still use AddToStream and his own file system if he wants something
   more robust.
 -----------------------------------------------------------------------------}
procedure TCascadeDocument.SaveDocument(FileName : String);
var myFile : TextFile;
    aStr   : String;
Begin
   aStr := '';
   AddToStream(aStr);
   try
      AssignFile(myFile, FileName);
      Rewrite(myFile);
      Write(myFile, aStr);
   finally
      CloseFile(myFile);
   end;
End; {TCascadeDocument.SaveDocument}

{-----------------------------------------------------------------------------
  TCascadeDocument.OpenDocument
   Given a filename, opens itself from the file. The developer can still use
   GetFromStream and his own file system if he wants something more robust.
   This OpenDocument will do the following:
   o Warn the user if any TCSSRecords are beyond OptionLevel 0.
   o Warn the user if the TCascadeDocument is beyond OptionLevel 0.
 -----------------------------------------------------------------------------}
procedure TCascadeDocument.OpenDocument(FileName : String);
var myFile : TextFile;
    aStr   : String;
    Warn   : Boolean;
    i      : Integer;
Begin
   if not FileExists(FileName) then Exit;
   try
      AssignFile(myFile, FileName);
      Reset(myFile);
      Read(myFile, aStr);
   finally
      CloseFile(myFile);
   end;
   If not GetFromStream(aStr) then Begin
      aStr := 'The file you are attempting to open is not in a recognized '
            + 'format (it is not a Cascade version 2 or higher document).';
      MessageDlg(aStr, mtError, [mbOK], 0);
   End; {if}

   Warn := False;
   If FOptionLevel > C_DOC_LEVEL then Warn := True; {document has options}
   For i := 0 to FRecords.Count - 1 do              {check record options}
      If TCSSRecord(FRecords[i]).OptionLevel > C_CSS_LEVEL then Warn := True;

   {let the user know if any records have options beyond what we handle}
   If Warn then Begin
      aStr := 'Although the document has been processed successfully, it '
            + 'contains information about features this application predates. '
            + 'If you save this file again, these advanced features will be '
            + 'lost.';
         MessageDlg(aStr, mtWarning, [mbOK], 0);
   End; {if}

End; {TCascadeDocument.OpenDocument}

{-----------------------------------------------------------------------------
  TCascadeDocument.PutIntoTree
  Puts the document into the Target tree. It is the application's responsib-
  ility to look at whether a class is active, and use a TTreeView's descend-
  ant class to embolden the active line (or whatever method is used).
 -----------------------------------------------------------------------------}
Procedure TCascadeDocument.PutIntoTree(Target : TTreeView);
var i     : Integer;
    aNode : TTreeNode;
    aRec  : TCSSRecord;
    eV1   : TTVChangingEvent;
    eV2   : TTVChangedEvent;
Begin
   eV1 := Target.OnChanging;
   eV2 := Target.OnChange;
   Target.OnChange := nil;
   Target.OnChanging := nil;
   Target.Items.Clear;
   If FRecords.Count > 0 then Begin;
      Target.Items.BeginUpdate;
      For i := 0 to FRecords.Count-1 do Begin
         aRec := TCSSRecord(FRecords.Items[i]);
         aNode := Target.Selected;
         Target.Items.AddChildObject(aNode, aRec.Selector, aRec);
      End; {for}
      Target.Items.EndUpdate;
   End; {if}
   Target.OnChanging := eV1;
   Target.OnChange := eV2;
End; {TCascadeDocument.PutIntoTree}

{-----------------------------------------------------------------------------
  TCascadeDocument.GetFromTree
  Get's the Source TreeView's DATA items and builds the Cascade document.
  Uses FRECORDS as its storage
 -----------------------------------------------------------------------------}
Procedure TCascadeDocument.GetFromTree(Source : TTreeView);
var i : Integer;
Begin
   FRecords.Clear;
   For i := 0 to Source.Items.Count-1 do
      FRecords.Add(TCSSRecord(Source.Items[i].Data));
End; {TCascadeDocument.GetFromTree}

{-----------------------------------------------------------------------------
  TCascadeDocument.GetCSS
  Generates Cascading Style Sheet text.
  If Tagged is true, we only generate CSS for classes which are tagged.
 -----------------------------------------------------------------------------}
procedure TCascadeDocument.GetCSS(Dest : TStringList; SingleQuotes, Tagged : Boolean);
var i      : Integer;
    MediaNest : Boolean; {flag if we are nested in @media}
    procedure DoCSS( nr : Integer);
    Begin
       TCSSRecord(FRecords.Items[nr]).GetCSS(Dest, SingleQuotes);
    End;
    procedure DoMedia( nr: Integer);
    Begin
       Dest.Add(TCSSRecord(FRecords.Items[nr]).Selector + ' {');
       MediaNest := True;
    End;
Begin
   Dest.Clear;
   MediaNest := False;
   { loop through all of the records, and get their CSS if applicable }
   For i := 0 to FRecords.Count - 1 do Begin
      If TCSSRecord(FRecords.Items[i]).RecordType = rtMedia then Begin
         {handle @media}
         If MediaNest then Begin
            Dest.Add('}');
            MediaNest := False;
         End; {if}
         DoMedia(i);
      End Else Begin
         {handle anything but @media}
         If (Tagged and TCSSRecord(FRecords.Items[i]).IsTagged) then doCSS(i);
         If not Tagged then doCSS(i);
      End; {if}
   End; {for}
   If MediaNest then Dest.Add('}');
End; {TCascadeDocument.GetCSS}

{-----------------------------------------------------------------------------
  TCascadeDocument.GetClasses
  Merely provide a list of all the classes present in the document. If the
  Tagged parameter is true, only show results for tagged items.
 -----------------------------------------------------------------------------}
Procedure TCascadeDocument.GetClasses(Dest : TStringList; Tagged : Boolean);
var i : Integer;
Begin
   Dest.Clear;
   For i := 0 to FRecords.Count - 1 do Begin
      If (Tagged and TCSSRecord(FRecords.Items[i]).IsTagged) then
         Dest.Add(TCSSRecord(FRecords[i]).Selector);
      If not Tagged then
         Dest.Add(TCSSRecord(FRecords[i]).Selector);
   End; {for}
End; {TCascadeDocument.GetClasses}

{-----------------------------------------------------------------------------
  TCascadeDocument.AddRecord
   Appends an existing record at the end of the document.
 -----------------------------------------------------------------------------}
function TCascadeDocument.AddRecord(CSSRecord : TCSSRecord) : Integer;
Begin
   Result := FRecords.Add(CSSRecord);
End; {TCascadeDocument.AppendRecord}

{-----------------------------------------------------------------------------
  TCascadeDocument.InsertRecord
   Inserts a CSS Record into the document.
 -----------------------------------------------------------------------------}
Procedure TCascadeDocument.InsertRecord(Index: Integer; CSSRecord: TCSSRecord);
Begin
   FRecords.Insert(Index, CSSRecord);
End;

{-----------------------------------------------------------------------------
  TCascadeDocument.InterpretCSS;
   Creates itself anew from a passed-in UJDCSS document.
 -----------------------------------------------------------------------------}
Procedure TCascadeDocument.InterpretCSS(theCSS : TStylesheet);
var i, j, k : LongInt;
       cRecord : TCSSRecord;
       cSelect : LongInt; // the current selector that we are adding rules to.
Begin
   FRecords.Clear;

   // loop through ALL the media-types in the document.
   For i := 0 to theCSS.MediaList.Count - 1 do Begin
       cRecord := TCSSRecord.Create(Self.Owner);
       cRecord.Selector := '@media ' + theCSS.aMedia[i].Media;
       cRecord.RecordType := rtMedia;
       AddRecord(cRecord);

       // now loop through all of the selectors in the media type
       For j := 0 to theCSS.aMedia[i].Selectors.Count-1 do Begin
          cRecord := TCSSRecord.Create(Self.Owner);
          cRecord.Selector := theCSS.aMedia[i].aSelector[j].Selector;
          cRecord.RecordType := rtCustom;
          cSelect := AddRecord(cRecord);

          // clear the current, new record
          for k := 1 to 133 do
             TCSSRecord(Records[cSelect]).Radios[k] := False;
          for k := 1 to 27 do
             TCSSRecord(Records[cSelect]).Checks[k] := False;

          // now loop through all of the rules in the selector
          For k := 0 to theCSS.aMedia[i].aSelector[j].Rules.Count-1 do
             InterpretRule(TCSSRecord(Records[cSelect]), theCSS.aMedia[i].aSelector[j].aRule[k]);

       End; {for LOOP through each selector}

   End; {for LOOP through each media type}

End; {TCascadeDocument.InterpretCSS}

{-----------------------------------------------------------------------------
  TCascadeDocument.InterpretRule
    Interpret the passed-in rule and apply it to the passed-in Cascade document.
 -----------------------------------------------------------------------------}
procedure TCascadeDocument.InterpretRule(CasDoc : TCSSRecord; CSSRule : TCSSRule);
type theB = Record
        SizeNum  : String;
        SizeSgn  : String;
        SizeTxt  : String;
        StyleTxt : String;
        ColorTxt : String
     end; {record}
const S : Array[1..56] of String = (
       {1}  'cursive,fantasy,monospace,sans-serif,serif' ,
       {2}  'xx-small,x-small,small,medium,large,x-large,xx-large' ,
       {3}  'larger,smaller',
       {4}  'pt,pc,in,cm,mm,em,ex,px',
       {5}  'inherit,none',
       {6}  '100,200,300,400,500,600,700,800,900',
       {7}  'normal,inherit,bold,bolder,lighter',
       {8}  'inherit,normal,small-caps',
       {9}  'inherit,normal,italic,oblique',
       {10} 'inherit,normal,condensed,expanded,extra-condensed,extra-expanded,narrower,semi-expanded,semi-condensed,ultra-condensed,ultra-expanded,wider',
       {11} 'caption,icon,menu,message-box,small-caption,status-bar',
       {12} 'inherit,center,justify,left,right',
       {13} 'inherit,none',
       {14} 'inherit,normal',
       {15} 'inherit,none,capitalize,lowercase,uppercase',
       {16} 'inherit,normal,nowrap,pre',
       {17} 'auto,inherit,hidden,scroll,visible',
       {18} 'inherit,baseline,bottom,middle,sub,super,text-bottom,text-top,top',
       {19} 'inherit,collapse,hidden,visible',
       {20} 'auto,inherit',
       {21} 'medium,thick,thin',
       {22} 'none,dashed,dotted,double,groove,hidden,inset,outset,ridge,solid',
       {23} 'inherit,no-repeat,repeat-x,repeat-y',
       {24} 'inherit,fixed,scroll',
       {25} 'inherit,transparent',
       {26} 'center,left,right',
       {27} 'bottom,center,top',
       {28} 'inherit,none,block,compact,inline,inline-table,list-item,marker,run-in,table,table-caption,table-cell,table-column-group,table-footer-group,table-header-group,table-row,table-row-group',
       {29} 'inherit,absolute,fixed,relative,static',
       {30} 'inherit,ltr,rtl',
       {31} 'inherit,none,left,right,both',
       {32} 'inherit,normal,bidi-override,embed',
       {33} 'inherit,none,left,right',
       {34} 'inherit,close-quote,open-quote,no-close-quote,no-open-quote',
       {35} 'inherit,none,circle,disk,square,armenian,cjk-ideographic,decimal,georgian,hebrew,hiragana,hiragana-iroha,katakana,katakana-iroha,decimal-leading-zero,lower-alpha,lower-greek,lower-latin,lower-roman,upper-alpha,upper-latin,upper-roman',
       {36} 'inherit,inside,outside',
       {37} 'auto,fixed,inherit',
       {38} 'inherit,collapse,separate',
       {39} 'inherit,borders,no-borders',
       {40} 'inherit,always,once',
       {41} 'inherit,top,bottom,left,right',
       {42} 'auto,inherit,crosshair,default,help,move,pointer,text,wait,n-resize,e-resize,s-resize,w-resize,ne-resize,se-resize,sw-resize,nw-resize',
       {43} 'inherit,silent,x-soft,soft,medium,loud,x-loud',
       {44} 's,ms',
       {45} 'deg,grad,rad',
       {46} 'left-side,far-left,left,center-left,center,center-right,far-right',
       {47} 'leftwards,rightwards',
       {48} 'auto,inherit,none',
       {49} 'inherit,below,level,above,higher-lower',
       {50} 'inherit,none,normal,spell-out',
       {51} 'inherit,x-low,low,medium,high,x-high',
       {52} 'inherit,x-slow,slow,medium,fast,x-fast,slower,faster',
       {53} 'inherit,child,female,male',
       {54} 'inherit,code,none',
       {55} 'inherit,continuous,digits',
       {56} 'outline,outline-width,outline-style,outline-color' { not in a menu! }
         );
var tmp : String;     // sometimes-needed temporary string.
      i : LongInt;    // an index
   myB  : theB;       // will hold our border values.
begin
   with CasDoc do with CSSRule do Begin
      {=======================================================================
        wPage1 - Font
       =======================================================================}
      If Attribute = 'font-family' then Begin
         CGroups[1] := True;
         Lights[1] := Important;
         if ValueLC = 'inherit' then
            Radios[2] := True
         else Begin
            Radios[1] := True;
            if Values.Count >= 1 then Begin
               Textuals[1] := StripQuotes(Values[0]);
               Checks[1] := True;
            End; {if}
            if Values.Count >= 2 then Begin
               Textuals[2] := StripQuotes(Values[1]);
               Checks[2] := True;
            end; {if}
            if Values.Count >= 3 then
               If StringInSet(Values[2], S[1]) then Begin
                  Textuals[3] := StripQuotes(Values[2]);
                  Checks[3] := True;
               End; {if}
         end; {if}
      end; {if Attribute}

      if Attribute = 'font-size' then Begin
         CGroups[2] := True;
         Lights[2] := Important;
         if StringInSet(Value, S[2]) then Begin
            Radios[3] := True;
            Selects[1] := ValueLC;
         end; {if}
         if StringInSet(Value, S[3]) then Begin
            Radios[4] := True;
            Selects[2] := ValueLC;
         end; {if}
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[5] := True;
            Spinners[1] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[3] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[5] := True;
            Spinners[1] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[3] := RightStr(ValueLC, 2);
         End; {if}
         if ValueLC = 'inherit' then Radios[6] := True;
      end; {if Attribute}

      if Attribute = 'font-size-adjust' then Begin
         CGroups[3] := True;
         Lights[3] := Important;
         if StringInSet(Value, S[5]) then Begin
            Radios[7] := True;
            Selects[4] := ValueLC;
         end; {if}
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[8] := True;
            Spinners[2] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[5] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[8] := True;
            Spinners[2] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[5] := RightStr(ValueLC, 2);
         End; {if}
      end; {if Attribute}

      if Attribute = 'font-weight' then Begin
         CGroups[4] := True;
         Lights[4] := Important;
         if StringInSet(ValueLC, S[6]) then Begin
            Radios[9] := True;
            Selects[6] := ValueLC;
            If Selects[6] = '100' then Selects[6] := '100 - extra-light';
            If Selects[6] = '200' then Selects[6] := '200 - light';
            If Selects[6] = '300' then Selects[6] := '300 - semi-light';
            If Selects[6] = '400' then Selects[6] := '400 - normal';
            If Selects[6] = '500' then Selects[6] := '500 - medium';
            If Selects[6] = '600' then Selects[6] := '600 - semi-bold';
            If Selects[6] = '700' then Selects[6] := '700 - bold';
            If Selects[6] = '800' then Selects[6] := '800 - extra-bold';
            If Selects[6] = '900' then Selects[6] := '900 - heavy';
         end; {if}
         if StringInSet(ValueLC, S[7]) then Begin
            Radios[10] := True;
            Selects[7] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'font-variant' then Begin
         CGroups[5] := True;
         Lights[5] := Important;
         if StringInSet(ValueLC, S[8]) then Selects[8] := ValueLC;
      end; {if Attribute}

      if Attribute = 'font-style' then Begin
         CGroups[6] := True;
         Lights[6] := Important;
         if StringInSet(ValueLC, S[9]) then Selects[9] := ValueLC;
      end; {if Attribute}

      if Attribute = 'font-stretch' then Begin
         CGroups[7] := True;
         Lights[7] := Important;
         if StringInSet(ValueLC, S[10]) then Selects[10] := ValueLC;
      end; {if Attribute}

      if Attribute = 'font' then Begin
         CGroups[8] := True;
         Lights[8] := Important;
         if StringInSet(ValueLC, S[11]) then Selects[11] := ValueLC;
      end; {if Attribute}

      {=======================================================================
        wPage2 - Text
       =======================================================================}
      if Attribute = 'text-indent' then Begin
         CGroups[9] := True;
         Lights[9] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[11] := True;
            Spinners[3] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[12] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[11] := True;
            Spinners[3] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[12] := RightStr(ValueLC, 2);
         End; {if}
         if ValueLC = 'inherit' then Radios[12] := True;
      end; {if Attribute}

      if Attribute = 'text-align' then Begin
         CGroups[10] := True;
         Lights[10] := Important;
         If StringInSet(ValueLC, S[12]) then Begin
            Radios[14] := True;
            Selects[13] := ValueLC;
         End Else Begin
            Radios[13] := True;
            Textuals[4] := Value;
         End; {if}
      end; {if Attribute}

      if Attribute = 'text-decoration' then Begin
         CGroups[11] := True;
         Lights[11] := Important;
         If StringInSet(ValueLC, S[12]) then Begin
            Radios[16] := True;
            Selects[14] := ValueLC;
         End Else Begin
            Radios[15] := True;
            Checks[4] := StringInSet('underline', ValueLC);
            Checks[5] := StringInSet('line-through', ValueLC);
            Checks[6] := StringInSet('overline', ValueLC);
            Checks[7] := StringInSet('blink', ValueLC);
         End; {if}
      end; {if Attribute}

      if Attribute = 'text-shadow' then Begin
         CGroups[12] := True;
         Lights[12] := Important;
         If StringInSet(ValueLC, S[13]) then Begin
            Radios[18] := True;
            Selects[15] := ValueLC;
         End Else Begin
            Radios[17] := True;
            Textuals[5] := Value;
         End; {if}
      end; {if Attribute}

      if Attribute = 'letter-spacing' then Begin
         CGroups[13] := True;
         Lights[13] := Important;
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[19] := True;
            Spinners[4] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[16] := RightStr(ValueLC, 2);
         End else
            if StringInSet(ValueLC, S[14]) then Begin
               Radios[20] := True;
               Selects[17] := ValueLC;
            end; {if}
      end; {if Attribute}

      if Attribute = 'word-spacing' then Begin
         CGroups[14] := True;
         Lights[14] := Important;
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[21] := True;
            Spinners[5] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[18] := RightStr(ValueLC, 2);
         End else
            if StringInSet(ValueLC, S[14]) then Begin
               Radios[22] := True;
               Selects[19] := ValueLC;
            end; {if}
      end; {if Attribute}

      if Attribute = 'text-transform' then Begin
         CGroups[15] := True;
         Lights[15] := Important;
         if StringInSet(ValueLC, S[15]) then Selects[20] := ValueLC;
      end; {if Attribute}

      if Attribute = 'white-space' then Begin
         CGroups[16] := True;
         Lights[16] := Important;
         if StringInSet(ValueLC, S[16]) then Selects[21] := ValueLC;
      end; {if Attribute}

      {=======================================================================
        wPage3 - Alignment
       =======================================================================}
      if Attribute = 'line-height' then Begin
         CGroups[17] := True;
         Lights[17] := Important;
         if StringInSet(Value, S[14]) then Begin
            Radios[24] := True;
            Selects[23] := ValueLC;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[23] := True;
               Spinners[6] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[22] := '%';
            End else Begin {%}
               if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
                  Radios[23] := True;
                  Spinners[6] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
                  Selects[22] := RightStr(ValueLC, 2);
               End else Begin  {if S[4]}
                  Radios[23] := True;
                  Spinners[6] := ValueOf(ValueLC);
                  Selects[22] := 'lines';
               End; {if}
            End; {if %}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'overflow' then Begin
         CGroups[18] := True;
         Lights[18] := Important;
         if StringInSet(ValueLC, S[17]) then Selects[24] := ValueLC;
      end; {if Attribute}

      if Attribute = 'vertical-align' then Begin
         CGroups[19] := True;
         Lights[19] := Important;
         if StringInSet(ValueLC, S[18]) then Begin
            Radios[26] := True;
            Selects[26] := ValueLC;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[25] := True;
               Spinners[7] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[25] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[25] := True;
               Spinners[7] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[25] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'visibility' then Begin
         CGroups[20] := True;
         Lights[20] := Important;
         if StringInSet(ValueLC, S[19]) then Selects[27] := ValueLC;
      end; {if Attribute}

      if Attribute = 'clip' then Begin
         CGroups[21] := True;
         Lights[21] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Selects[32] := ValueLC;
            Radios[28] := True;
         End;
         if LeftStr(ValueLC, 5) = 'rect(' then Begin
            Radios[27] := True;
            if RightStr(LowerCase(Values[0]), 4) = 'auto' then // TOP
               Selects[28] := 'auto'
            else Begin
               tmp := Copy(Values[0], Pos('(', Values[0])+1, Length(Values[0]));
               Spinners[8] := ValueOf(LeftStr(tmp, Length(tmp)-2));
               Selects[28] := RightStr(Values[0], 2);
            end; {if TOP}
            if RightStr(LowerCase(Values[1]), 4) = 'auto' then // RIGHT
               Selects[31] := 'auto'
            else Begin
               Spinners[11] := ValueOf(LeftStr(Values[1], Length(Values[1])-2));
               Selects[31] := RightStr(Values[1], 2);
            end; {if RIGHT}
            if RightStr(LowerCase(Values[2]), 4) = 'auto' then // BOTTOM
               Selects[29] := 'auto'
            else Begin
               Spinners[9] := ValueOf(LeftStr(Values[2], Length(Values[2])-2));
               Selects[29] := RightStr(Values[2], 2);
            end; {if BOTTOM}
            // LEFT
            tmp := Strip(LowerCase(Copy(Values[3], 1, Pos(')', Values[3])-1))); // copy the LEFT value.
            if RightStr(tmp, 4) = 'auto' then
               Selects[30] := 'auto'
            else Begin
               Spinners[10] := ValueOf(LeftStr(tmp, Length(tmp)-2));
               Selects[23] := RightStr(tmp, 2);
            end; {if TOP}
         end; {if}
      end; {if Attribute}

      {=======================================================================
        wPage4 - Margins
       =======================================================================}
      if Attribute = 'margin-top' then Begin
         CGroups[22] := True;
         Lights[22] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[29] := True;
            Spinners[12] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[33] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[29] := True;
            Spinners[12] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[33] := RightStr(ValueLC, 2);
         End; {if}
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[30] := True;
            Selects[34] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'margin-bottom' then Begin
         CGroups[23] := True;
         Lights[23] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[31] := True;
            Spinners[13] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[35] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[31] := True;
            Spinners[13] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[35] := RightStr(ValueLC, 2);
         End; {if}
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[32] := True;
            Selects[36] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'margin-left' then Begin
         CGroups[24] := True;
         Lights[24] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[33] := True;
            Spinners[14] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[37] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[33] := True;
            Spinners[14] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[37] := RightStr(ValueLC, 2);
         End; {if}
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[34] := True;
            Selects[38] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'margin-right' then Begin
         CGroups[25] := True;
         Lights[25] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[35] := True;
            Spinners[15] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[39] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[35] := True;
            Spinners[15] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[39] := RightStr(ValueLC, 2);
         End; {if}
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[36] := True;
            Selects[40] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'padding-top' then Begin
         CGroups[26] := True;
         Lights[26] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[37] := True;
            Spinners[16] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[41] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[37] := True;
            Spinners[16] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[41] := RightStr(ValueLC, 2);
         End; {if}
         if ValueLC = 'inherit' then Radios[38] := True;
      end; {if Attribute}

      if Attribute = 'padding-bottom' then Begin
         CGroups[27] := True;
         Lights[27] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[39] := True;
            Spinners[17] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[42] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[39] := True;
            Spinners[17] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[42] := RightStr(ValueLC, 2);
         End; {if}
         if ValueLC = 'inherit' then Radios[40] := True;
      end; {if Attribute}

      if Attribute = 'padding-left' then Begin
         CGroups[28] := True;
         Lights[28] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[41] := True;
            Spinners[18] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[43] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[41] := True;
            Spinners[18] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[43] := RightStr(ValueLC, 2);
         End; {if}
         if ValueLC = 'inherit' then Radios[42] := True;
      end; {if Attribute}

      if Attribute = 'padding-right' then Begin
         CGroups[29] := True;
         Lights[29] := Important;
         if RightStr(ValueLC, 1) = '%' then Begin
            Radios[43] := True;
            Spinners[19] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            Selects[44] := '%';
         End; {if}
         if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
            Radios[43] := True;
            Spinners[19] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
            Selects[44] := RightStr(ValueLC, 2);
         End; {if}
         if ValueLC = 'inherit' then Radios[44] := True;
      end; {if Attribute}

      {=======================================================================
        wPage5 - Borders
       =======================================================================}
       // first, cyphon-out the value(s), whatever the are.
       if IsBorderAttribute(Attribute) then Begin
          // cyphon the WIDTH
          if RightStr(Attribute, 5) = 'width' then Begin
             if StringInSet(LowerCase(Values[0]), S[21]) then Begin
                myB.SizeTxt := LowerCase(Values[0]);
                myB.SizeNum := '';
                myB.SizeSgn := '';
             end else begin
                If StringInSet(LowerCase(RightStr(Values[0], 2)), S[4]) then Begin
                   myB.SizeNum := LeftStr(Values[0], Length(Values[0])-2);
                   myB.SizeSgn := LowerCase(RightStr(Values[0], 2));
                   myB.SizeTxt := '';
                End;
             end;
          End; {width}
          // cyphon the color
          if RightStr(Attribute, 5) = 'color' then Begin
             myB.ColorTxt := ValueLC;
          End; {color}
          // cyphon the style
          if RightStr(Attribute, 5) = 'style' then Begin
             if StringInSet(ValueLC, S[22]) then myB.StyleTxt := ValueLC;
          End; {style}
          // Attempt to cyphon ALL data.
          If (Attribute = 'border') or (Attribute = 'border-top') or (Attribute = 'border-bottom') or (Attribute = 'border-left') or (Attribute = 'border-right') then Begin
             // if the last-two aren't in the menu, and the item's not in the other menus, it must be a color.
             For i := 0 to Values.Count - 1 do Begin
                tmp := LowerCase(Values[i]);
                If StringInSet(tmp, S[21]) then Begin
                   myB.SizeTxt := tmp;
                   myB.SizeNum := '';
                   myB.SizeSgn := '';
                end else Begin
                   if StringInSet(RightStr(tmp, 2), S[4]) then Begin
                      myB.SizeNum := LeftStr(tmp, Length(tmp)-2);
                      myB.SizeSgn := RightStr(tmp, 2);
                      myB.SizeTxt := '';
                   end else Begin
                      If StringInSet(tmp, S[22]) then Begin
                         myB.StyleTxt := tmp;
                      end else Begin
                         myB.ColorTxt := tmp;
                      end; {if}
                   end;
                end;
             End; {for}
          End; {ALL}
          // NOW APPLY ALL OF THE DATA
          // Apply to border-top
          If (Attribute = 'border') or (LeftStr(Attribute, 10) = 'border-top') or
                (Attribute = 'border-width') or (Attribute = 'border-style') or (Attribute = 'border-color') then Begin
             CGroups[30] := True;
             Lights[30] := Important;
             if myB.SizeNum <> '' then Begin  // size as number and unit
                Radios[45] := True;
                Radios[46] := False;
                Spinners[20] := ValueOf(myB.SizeNum);
                Selects[45] := myB.SizeSgn;
             end; {if}
             if myB.SizeTxt <> '' then Begin // size as menu
                Radios[45] := False;
                Radios[46] := True;
                Selects[46] := myB.SizeTxt;
             end; {if}
             if myB.StyleTxt <> '' then Begin // style as menu
                Checks[8] := True;
                Selects[47] :=  myB.StyleTxt;
             end; {if}
             if myB.ColorTxt <> '' then Begin // color as text
                Checks[9] := True;
                Colorfuls[1] := myB.ColorTxt;
             end; {if}
          End; {if - border-top}
          // Apply to border-bottom
          If (Attribute = 'border') or (LeftStr(Attribute, 13) = 'border-bottom') or
                (Attribute = 'border-width') or (Attribute = 'border-style') or (Attribute = 'border-color') then Begin
             CGroups[31] := True;
             Lights[31] := Important;
             if myB.SizeNum <> '' then Begin  // size as number and unit
                Radios[47] := True;
                Radios[48] := False;
                Spinners[21] := ValueOf(myB.SizeNum);
                Selects[48] := myB.SizeSgn;
             end; {if}
             if myB.SizeTxt <> '' then Begin // size as menu
                Radios[47] := False;
                Radios[48] := True;
                Selects[49] := myB.SizeTxt;
             end; {if}
             if myB.StyleTxt <> '' then Begin // style as menu
                Checks[10] := True;
                Selects[50] :=  myB.StyleTxt;
             end; {if}
             if myB.ColorTxt <> '' then Begin // color as text
                Checks[11] := True;
                Colorfuls[2] := myB.ColorTxt;
             end; {if}
          End; {if - border-bottom}
          // Apply to border-left
          If (Attribute = 'border') or (LeftStr(Attribute, 11) = 'border-left') or
                (Attribute = 'border-width') or (Attribute = 'border-style') or (Attribute = 'border-color') then Begin
             CGroups[32] := True;
             Lights[32] := Important;
             if myB.SizeNum <> '' then Begin  // size as number and unit
                Radios[49] := True;
                Radios[50] := False;
                Spinners[22] := ValueOf(myB.SizeNum);
                Selects[51] := myB.SizeSgn;
             end; {if}
             if myB.SizeTxt <> '' then Begin // size as menu
                Radios[49] := False;
                Radios[50] := True;
                Selects[52] := myB.SizeTxt;
             end; {if}
             if myB.StyleTxt <> '' then Begin // style as menu
                Checks[12] := True;
                Selects[53] :=  myB.StyleTxt;
             end; {if}
             if myB.ColorTxt <> '' then Begin // color as text
                Checks[13] := True;
                Colorfuls[3] := myB.ColorTxt;
             end; {if}
          End; {if - border-left}
          // Apply to border-right
          If (Attribute = 'border') or (LeftStr(Attribute, 12) = 'border-right') or
                (Attribute = 'border-width') or (Attribute = 'border-style') or (Attribute = 'border-color') then Begin
             CGroups[33] := True;
             Lights[33] := Important;
             if myB.SizeNum <> '' then Begin  // size as number and unit
                Radios[51] := True;
                Radios[52] := False;
                Spinners[23] := ValueOf(myB.SizeNum);
                Selects[54] := myB.SizeSgn;
             end; {if}
             if myB.SizeTxt <> '' then Begin // size as menu
                Radios[51] := False;
                Radios[52] := True;
                Selects[55] := myB.SizeTxt;
             end; {if}
             if myB.StyleTxt <> '' then Begin // style as menu
                Checks[14] := True;
                Selects[56] :=  myB.StyleTxt;
             end; {if}
             if myB.ColorTxt <> '' then Begin // color as text
                Checks[15] := True;
                Colorfuls[4] := myB.ColorTxt;
             end; {if}
          End; {if - border-right}
       end; {if Attribute}

      {=======================================================================
        wPage6 - Color/Background
       =======================================================================}
      if Attribute = 'color' then Begin
         CGroups[34] := True;
         Lights[34] := Important;
         if ValueLC = 'inherit' then
            Radios[54] := True
         else Begin
            Radios[53] := True;
            Colorfuls[5] := ValueLC;
         End; {if}
      end; {if Attribute}

      if Attribute = 'background-repeat' then Begin
         if StringInSet(ValueLC, S[23]) then Begin
            CGroups[35] := True;
            Lights[35] := Important;
            Selects[57] := ValueLC;
         end; {if}
      End; {if Attribute}

      if Attribute = 'background-attachment' then Begin
         if StringInSet(ValueLC, S[24]) then Begin
            CGroups[36] := True;
            Lights[36] := Important;
            Selects[58] := ValueLC;
         end; {if}
      End; {if Attribute}

      if Attribute = 'background-color' then Begin
         CGroups[37] := True;
         Lights[37] := Important;
         if StringInSet(ValueLC, S[25]) then Begin
            Radios[56] := True;
            Selects[59] := ValueLC;
         end else Begin
            Radios[55] := True;
            Colorfuls[6] := ValueLC;
         End; {if}
      end; {if Attribute}

      if Attribute = 'background-image' then Begin
         CGroups[38] := True;
         Lights[38] := Important;
         if StringInSet(ValueLC, S[13]) then Begin
            Radios[58] := True;
            Selects[60] := ValueLC;
         end else Begin
            Radios[57] := True;
            Textuals[6] := ValueLC;
         End; {if}
      end; {if Attribute}

      if Attribute = 'background-position' then Begin
         CGroups[39] := True;
         Lights[39] := Important;
         if StringInSet(LowerCase(Values[0]), S[26]) then Begin
            Radios[59] := True;
            Selects[61] := LowerCase(Values[0]);
            if Values.Count >= 2 then Begin
               Checks[16] := True;
               if StringInSet(LowerCase(Values[1]), S[27]) then Selects[62] := LowerCase(Values[1]) else Checks[16] := False;
            end; {if}
         end; {if}
         if RightStr(Values[0], 1) = '%' then Begin
            Radios[60] := True;
            Spinners[24] := ValueOf(LeftStr(Values[0], Length(Values[0])-1));
            if Values.Count >= 2 then Begin
               Checks[16] := True;
               Spinners[25] := ValueOf(LeftStr(Values[1], Length(Values[1])-1));
            end; {if}
            Selects[63] := '%';
         end; {if}
         if StringInSet(RightStr(Values[0], 2), S[4]) then Begin
            Radios[60] := True;
            Spinners[24] := ValueOf(LeftStr(Values[0], Length(Values[0])-2));
            if Values.Count >= 2 then Begin
               Checks[16] := True;
               Spinners[25] := ValueOf(LeftStr(Values[1], Length(Values[1])-2));
            end; {if}
            Selects[63] := RightStr(Values[0], 2);
         end; {if}
      end; {if Attribute}


      {=======================================================================
        wPage7 - Rendering
       =======================================================================}
      if Attribute = 'top' then Begin
         CGroups[40] := True;
         Lights[40] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[63] := True;
            Selects[65] := ValueLC;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[62] := True;
               Spinners[26] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[64] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[62] := True;
               Spinners[26] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[64] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'bottom' then Begin
         CGroups[41] := True;
         Lights[41] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[65] := True;
            Selects[67] := ValueLC;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[64] := True;
               Spinners[27] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[66] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[64] := True;
               Spinners[27] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[66] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'left' then Begin
         CGroups[42] := True;
         Lights[42] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[67] := True;
            Selects[69] := ValueLC;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[66] := True;
               Spinners[28] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[68] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[66] := True;
               Spinners[28] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[68] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'right' then Begin
         CGroups[43] := True;
         Lights[43] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[69] := True;
            Selects[71] := ValueLC;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[68] := True;
               Spinners[29] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[70] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[68] := True;
               Spinners[29] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[70] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'display' then Begin
         if StringInSet(ValueLC, S[28]) then Begin
            CGroups[44] := True;
            Lights[44] := Important;
            Selects[72] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'position' then Begin
         if StringInSet(ValueLC, S[29]) then Begin
            CGroups[45] := True;
            Lights[45] := Important;
            Selects[73] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'direction' then Begin
         if StringInSet(ValueLC, S[30]) then Begin
            CGroups[46] := True;
            Lights[46] := Important;
            Selects[74] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'clear' then Begin
         if StringInSet(ValueLC, S[31]) then Begin
            CGroups[47] := True;
            Lights[47] := Important;
            Selects[75] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'unicode-bidi' then Begin
         if StringInSet(ValueLC, S[32]) then Begin
            CGroups[48] := True;
            Lights[48] := Important;
            Selects[76] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'float' then Begin
         if StringInSet(ValueLC, S[33]) then Begin
            CGroups[49] := True;
            Lights[49] := Important;
            Selects[77] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'z-index' then Begin
         CGroups[50] := True;
         Lights[50] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[71] := True;
            Selects[78] := ValueLC;
         end else Begin {if}
            Radios[70] := True;
            Spinners[30] := ValueOf(ValueLC);
         end; {if}
      end; {if Attribute}

      {=======================================================================
        wPage8 - Box Dimensions
       =======================================================================}
      if Attribute = 'width' then Begin
         CGroups[51] := True;
         Lights[51] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[73] := True;
            Selects[80] := ValueLC;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[72] := True;
               Spinners[31] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[79] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[72] := True;
               Spinners[31] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[79] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'min-width' then Begin
         CGroups[52] := True;
         Lights[52] := Important;
         if ValueLC = 'inherit' then Begin
            Radios[75] := True;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[74] := True;
               Spinners[32] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[81] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[74] := True;
               Spinners[32] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[81] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'max-width' then Begin
         CGroups[53] := True;
         Lights[53] := Important;
         if ValueLC = 'inherit' then Begin
            Radios[77] := True;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[76] := True;
               Spinners[33] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[82] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[76] := True;
               Spinners[33] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[82] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'height' then Begin
         CGroups[54] := True;
         Lights[54] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[79] := True;
            Selects[84] := ValueLC;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[78] := True;
               Spinners[34] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[83] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[78] := True;
               Spinners[34] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[83] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'min-height' then Begin
         CGroups[55] := True;
         Lights[55] := Important;
         if ValueLC = 'inherit' then Begin
            Radios[81] := True;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[80] := True;
               Spinners[35] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[85] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[80] := True;
               Spinners[35] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[85] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      if Attribute = 'max-height' then Begin
         CGroups[56] := True;
         Lights[56] := Important;
         if ValueLC = 'inherit' then Begin
            Radios[83] := True;
         end else Begin {if}
            if RightStr(ValueLC, 1) = '%' then Begin
               Radios[82] := True;
               Spinners[36] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
               Selects[86] := '%';
            End;{%}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[82] := True;
               Spinners[36] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[86] := RightStr(ValueLC, 2);
            End; {if}
         end; {if S[14]}
      end; {if Attribute}

      {=======================================================================
        wPage9 - Generated Content
       =======================================================================}
      if Attribute = 'content' then Begin
         CGroups[57] := True;
         Lights[57] := Important;
         if StringInSet(ValueLC, S[34]) then Begin
            Radios[85] := True;
            Selects[87] := ValueLC;
         end else Begin {if}
            Radios[84] := True;
            Textuals[7] := Value;
         end; {if}
      end; {if Attribute}

      if Attribute = 'marker-offset' then Begin
         CGroups[58] := True;
         Lights[58] := Important;
         if StringInSet(ValueLC, S[20]) then Begin
            Radios[87] := True;
            Selects[89] := ValueLC;
         end else Begin {if}
            if StringInSet(RightStr(ValueLC, 2), S[4]) then Begin
               Radios[86] := True;
               Spinners[37] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Selects[88] := RightStr(ValueLC, 2);
            End; {if}
         end; {if}
      end; {if Attribute}

      if Attribute = 'counter-reset' then Begin
         CGroups[59] := True;
         Lights[59] := Important;
         if StringInSet(ValueLC, S[13]) then Begin
            Radios[89] := True;
            Selects[90] := ValueLC;
         end else Begin {if}
            Radios[88] := True;
            Textuals[8] := Value;
         end; {if}
      end; {if Attribute}

      if Attribute = 'counter-increment' then Begin
         CGroups[60] := True;
         Lights[60] := Important;
         if StringInSet(ValueLC, S[13]) then Begin
            Radios[91] := True;
            Selects[91] := ValueLC;
         end else Begin {if}
            Radios[90] := True;
            Textuals[9] := Value;
         end; {if}
      end; {if Attribute}

      if Attribute = 'quotes' then Begin
         CGroups[61] := True;
         Lights[61] := Important;
         if StringInSet(ValueLC, S[13]) then Begin
            Radios[93] := True;
            Selects[92] := ValueLC;
         end else Begin {if}
            Radios[92] := True;
         end; {if}
      end; {if Attribute}

      {=======================================================================
        wPage10 - Lists
       =======================================================================}
      if Attribute = 'list-style-type' then Begin
         if StringInSet(ValueLC, S[35]) then Begin
            CGroups[62] := True;
            Lights[62] := Important;
            Selects[93] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'list-style-image' then Begin
         CGroups[63] := True;
         Lights[63] := Important;
         if StringInSet(ValueLC, S[13]) then Begin
            Radios[95] := True;
            Selects[94] := ValueLC;
         end else Begin {if}
            Radios[94] := True;
            If LeftStr(ValueLC, 3) <> 'url' then
               Textuals[14] := Value
            else Begin
               Textuals[14] := LowerCase(Trim(Copy(Value, 5, Length(Value))));
               Textuals[14] := Copy(Textuals[14], 1, Length(Textuals[14])-1);
            end; {if}
         end; {if}
      end; {if Attribute}

      if Attribute = 'list-style-position' then Begin
         if StringInSet(ValueLC, S[36]) then Begin
            CGroups[64] := True;
            Lights[64] := Important;
            Selects[95] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'list-style' then Begin
         for i := 0 to Values.Count - 1 do Begin
            if StringInSet(LowerCase(Values[i]),S[35]) then Begin
               CGroups[62] := True;
               Lights[62] := Important;
               Selects[93] := LowerCase(Values[i]);
            end; {if}
            if StringInSet(LowerCase(Values[i]),S[13]) then Begin
               CGroups[63] := True;
               Lights[63] := Important;
               Selects[94] := LowerCase(Values[i]);
               Radios[95] := True;
            end; {if}
            if StringInSet(LowerCase(Values[i]),S[36]) then Begin
               CGroups[64] := True;
               Lights[64] := Important;
               Selects[95] := LowerCase(Values[i]);
            end; {if}
            if LeftStr(LowerCase(Values[i]), 3) = 'url' then Begin
               CGroups[63] := True;
               Lights[63] := Important;
               Textuals[14] := LowerCase(Trim(Copy(Values[i], 5, Length(Values[i]))));
               Textuals[14] := Copy(Textuals[14], 1, Length(Textuals[14])-1);
               Radios[94] := True;
            end; {if}
         end; {for}
      end; {if Attribute}

      {=======================================================================
        wPage11 - Tables
       =======================================================================}
      if Attribute = 'table-layout' then Begin
         if StringInSet(ValueLC, S[37]) then Begin
            CGroups[65] := True;
            Lights[65] := Important;
            Selects[96] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'border-collapse' then Begin
         if StringInSet(ValueLC, S[38]) then Begin
            CGroups[66] := True;
            Lights[66] := Important;
            Selects[97] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'empty-cells' then Begin
         if StringInSet(ValueLC, S[39]) then Begin
            CGroups[67] := True;
            Lights[67] := Important;
            Selects[98] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'speak-header' then Begin
         if StringInSet(ValueLC, S[40]) then Begin
            CGroups[68] := True;
            Lights[68] := Important;
            Selects[99] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'caption-side' then Begin
         if StringInSet(ValueLC, S[41]) then Begin
            CGroups[69] := True;
            Lights[69] := Important;
            Selects[100] := ValueLC;
         end; {if}
      end; {if Attribute}

      if Attribute = 'border-spacing' then Begin
         CGroups[72] := True;
         Lights[72] := Important;
         if ValueLC = 'inherit' then
            Radios[101] := True
         else Begin
            Radios[100] := True;
            if RightStr(Values[0], 1) = '%' then Begin
               Spinners[40] := ValueOf(LeftStr(Values[0], Length(Values[0])-1));
               if Values.Count >= 2 then Begin
                  Checks[17] := True;
                  Spinners[41] := ValueOf(LeftStr(Values[1], Length(Values[1])-1));
               end; {if}
               Selects[101] := '%';
            end; {if}
            if StringInSet(RightStr(Values[0], 2), S[4]) then Begin
               Spinners[40] := ValueOf(LeftStr(Values[0], Length(Values[0])-2));
               if Values.Count >= 2 then Begin
                  Checks[17] := True;
                  Spinners[41] := ValueOf(LeftStr(Values[1], Length(Values[1])-2));
               end; {if}
               Selects[101] := RightStr(Values[0], 2);
            end; {if}
         end; {if}
      end; {if Attribute}

      {=======================================================================
        wPage12 - Miscellaneous
       =======================================================================}
       if Attribute = 'cursor' then Begin
         CGroups[73] := True;
         Lights[73] := Important;
         for i := 0 to Values.Count - 1 do
            if StringInSet(LowerCase(Values[i]), S[42]) then Begin
               Checks[19] := True;
               Selects[102] := LowerCase(Values[i]);
            end else Begin
               Checks[18] := True;
               Textuals[15] := Values[i];
            end; {if}
      end; {if Attribute}

       // the OUTLINE attribute is another of those complicated ones.
       If StringInSet(Attribute, S[56]) then Begin
          // cyphon the WIDTH
          if RightStr(Attribute, 5) = 'width' then Begin
             if StringInSet(LowerCase(Values[0]), S[21]) then Begin
                myB.SizeTxt := LowerCase(Values[0]);
                myB.SizeNum := '';
                myB.SizeSgn := '';
             end else begin
                If StringInSet(LowerCase(RightStr(Values[0], 2)), S[4]) then Begin
                   myB.SizeNum := LeftStr(Values[0], Length(Values[0])-2);
                   myB.SizeSgn := LowerCase(RightStr(Values[0], 2));
                   myB.SizeTxt := '';
                End;
             end;
          End; {width}
          // cyphon the COLOR
          if RightStr(Attribute, 5) = 'color' then Begin
             myB.ColorTxt := ValueLC;
          End; {color}
          // cyphon the STYLE
          if RightStr(Attribute, 5) = 'style' then Begin
             if StringInSet(ValueLC, S[22]) then myB.StyleTxt := ValueLC;
          End; {style}
          // Attempt to cyphon ALL data.
          If (Attribute = 'outline') then Begin
             // if the last-two aren't in the menu, and the item's not in the other menus, it must be a color.
             For i := 0 to Values.Count - 1 do Begin
                tmp := LowerCase(Values[i]);
                If StringInSet(tmp, S[21]) then Begin
                   myB.SizeTxt := tmp;
                   myB.SizeNum := '';
                   myB.SizeSgn := '';
                end else Begin
                   if StringInSet(RightStr(tmp, 2), S[4]) then Begin
                      myB.SizeNum := LeftStr(tmp, Length(tmp)-2);
                      myB.SizeSgn := RightStr(tmp, 2);
                      myB.SizeTxt := '';
                   end else Begin
                      If StringInSet(tmp, S[22]) then Begin
                         myB.StyleTxt := tmp;
                      end else Begin
                         myB.ColorTxt := tmp;
                      end; {if}
                   end;
                end;
             End; {for}
          End; {ALL}
          // NOW APPLY ALL OF THE DATA
          CGroups[74] := True;
          Lights[74] := Important;
          if myB.SizeNum <> '' then Begin  // size as number and unit
             Radios[102] := True;
             Radios[103] := False;
             Spinners[42] := ValueOf(myB.SizeNum);
             Selects[103] := myB.SizeSgn;
          end; {if}
          if myB.SizeTxt <> '' then Begin // size as menu
             Radios[102] := False;
             Radios[103] := True;
             Selects[104] := myB.SizeTxt;
          end; {if}
          if myB.StyleTxt <> '' then Begin // style as menu
             Checks[20] := True;
             Selects[105] :=  myB.StyleTxt;
          end; {if}
          if myB.ColorTxt <> '' then Begin // color as text
             Checks[21] := True;
             Colorfuls[7] := myB.ColorTxt;
             if LowerCase(myB.ColorTxt) = 'invert' then Checks[22] := True;
          end; {if}
       end; {if Attribute}

      {=======================================================================
        wPage13 - Aural Settings
       =======================================================================}
      if Attribute = 'volume' then Begin
         CGroups[75] := True;
         Lights[75] := True;
         if StringInSet(ValueLC, S[43]) then Begin
            Selects[106] := ValueLC;
            Radios[106] := True;
         end else Begin {if}
            if RightStr(Value, 1) = '%' then Begin
               Radios[105] := True;
               Spinners[44] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
            end else Begin
               Radios[104] := True;
               Spinners[43] := ValueOf(ValueLC);
            end; {if}
         end; {if}
      end; {if Attribute}

      if Attribute = 'pause-before' then Begin
         CGroups[76] := True;
         Lights[76] := True;
         if ValueLC = 'inherit' then
            Radios[108] := True
         else Begin
            If (RightStr(ValueLC, 2) = 'ms') then Begin
               Selects[107] := 'ms';
               Spinners[45] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Radios[107] := True;
            End else Begin
               If (RightStr(ValueLC, 1) = 's') then Begin
                  Selects[107] := 's';
                  Spinners[45] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
                  Radios[107] := True;
               end; {if}
            End; {if}
         End; {if}
      end; {if Attribute}

      if Attribute = 'azimuth' then Begin
         CGroups[77] := True;
         Lights[77] := True;
         if StringInSet(ValueLC, S[47]) then Begin
            Radios[111] := True;
            Selects[110] := ValueLC;
         End Else Begin
            If StringInSet(RightStr(ValueLC, 3), S[45]) then Begin
               Radios[109] := True;
               Selects[108] := RightStr(ValueLC, 3);
               Spinners[46] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-3));
            End Else Begin
               If (LowerCase(Values[0]) = 'behind') or (LowerCase(Values[0]) = 'behind') then Begin
                  Checks[23] := True;
                  Radios[110] := True;
               End; {If}
               If StringInSet(LowerCase(Values[0]), S[46]) then Begin
                  Selects[109] := LowerCase(Values[0]);
                  Checks[23] := True;
                  Radios[110] := True;
               End else Begin
                  If StringInSet(LowerCase(Values[0]), S[46]) then Begin
                     Selects[109] := LowerCase(Values[0]);
                     Checks[23] := True;
                     Radios[110] := True;
                  End; {if}
               End; {if}
            End; {if}
         End; {If}
      End; {if Attribute}

      if Attribute = 'play-during' then Begin
         CGroups[78] := True;
         Lights[78] := True;
         for i := 0 to Values.Count - 1 do
            if StringInSet(LowerCase(Values[i]), 'mix|repeat') then Begin
               Radios[112] := True;
               Checks[24] := LowerCase(Values[i]) = 'mix';
               Checks[25] := LowerCase(Values[i]) = 'repeat';
            end else {if}
               If StringInSet(LowerCase(Values[i]), S[48]) then Begin
                  Radios[113] := True;
                  Selects[111] := LowerCase(Values[i]);
               End Else {if}
                  If LeftStr(Values[i], 4) = 'url(' then Begin
                     Radios[112] := True;
                     Textuals[16] := LowerCase(Trim(Copy(Values[i], 5, Length(Values[i]))));
                     Textuals[16] := Copy(Textuals[16], 1, Length(Textuals[16])-1);
               End; {if}
      end; {if Attribute}

      if Attribute = 'pause-after' then Begin
         CGroups[79] := True;
         Lights[79] := True;
         if ValueLC = 'inherit' then
            Radios[115] := True
         else Begin
            If (RightStr(ValueLC, 2) = 'ms') then Begin
               Selects[112] := 'ms';
               Spinners[47] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-2));
               Radios[114] := True;
            End else Begin
               If (RightStr(ValueLC, 1) = 's') then Begin
                  Selects[112] := 's';
                  Spinners[47] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-1));
                  Radios[114] := True;
               end; {if}
            End; {if}
         End; {if}
      end; {if Attribute}

      if Attribute = 'elevation' then Begin
         CGroups[80] := True;
         Lights[80] := True;
         if StringInSet(ValueLC, S[49]) then Begin
            Radios[117] := True;
            Selects[114] := ValueLC;
         end else Begin
            If StringInSet(RightStr(ValueLC, 3), S[45]) then Begin
               Selects[113] := RightStr(ValueLC, 3);
               Spinners[48] := ValueOf(LeftStr(ValueLC, Length(ValueLC)-3));
               Radios[116] := True;
            End;
         End; {if}
      end; {if Attribute}

      if Attribute = 'speak' then Begin
         if StringInSet(ValueLC, S[50]) then Begin
            CGroups[81] := True;
            Lights[81] := True;
            Selects[115] := ValueLC;
         End; {if}
      end; {if Attribute}

      {=======================================================================
        wPage14 - Aural Characteristics
       =======================================================================}
      if Attribute = 'cue-before' then Begin
         CGroups[82] := True;
         Lights[82] := True;
         If StringInSet(ValueLC, S[13]) then Begin
            Selects[116] := ValueLC;
            Radios[119] := True;
         End Else Begin
            If LeftStr(ValueLC, 4) = 'url(' then Begin
               Textuals[17] := LowerCase(Trim(Copy(Value, 5, Length(Value))));
               Textuals[17] := Copy(Textuals[17], 1, Length(Textuals[17])-1);
            End Else
               Textuals[17] := Value;
            Radios[118] := True;
         End; {if}
      end; {if Attribute}

      if Attribute = 'cue-after' then Begin
         CGroups[83] := True;
         Lights[83] := True;
         If StringInSet(ValueLC, S[13]) then Begin
            Selects[117] := ValueLC;
            Radios[121] := True;
         End Else Begin
            If LeftStr(ValueLC, 4) = 'url(' then Begin
               Textuals[18] := LowerCase(Trim(Copy(Value, 5, Length(Value))));
               Textuals[18] := Copy(Textuals[18], 1, Length(Textuals[18])-1);
            End Else
               Textuals[18] := Value;
            Radios[120] := True;
         End; {if}
      end; {if Attribute}

      if Attribute = 'pitch' then Begin
         CGroups[84] := True;
         Lights[84] := True;
         If StringInSet(ValueLC, S[51]) then Begin
            Selects[118] := ValueLC;
            Radios[123] := True;
         End Else Begin
            Radios[122] := True;
            Spinners[49] := ValueOf(Value);
         End; {if}
      end; {if Attribute}

      if Attribute = 'speech-rate' then Begin
         CGroups[85] := True;
         Lights[85] := True;
         If StringInSet(ValueLC, S[52]) then Begin
            Selects[119] := ValueLC;
            Radios[125] := True;
         End Else Begin
            Radios[124] := True;
            Spinners[50] := ValueOf(Value);
         End; {if}
      end; {if Attribute}

      if Attribute = 'voice-family' then Begin
         CGroups[86] := True;
         Lights[86] := True;
         If ValueLC = 'inherit' then
            Radios[127] := True
         Else Begin
            Radios[126] := True;
            For i := 0 to Values.Count - 1 do
               If StringInSet(LowerCase(Values[i]), S[53]) then Begin
                  Selects[120] := LowerCase(Values[i]);
                  Checks[27] := True;
               End Else Begin
                  Textuals[9] := Values[i];
                  Checks[26] := True;
               End;
         End; {if}
      end; {if Attribute}

      if Attribute = 'richness' then Begin
         CGroups[87] := True;
         Lights[87] := True;
         If ValueLC = 'inherit' then
            Radios[129] := True
         Else Begin
            Radios[128] := True;
            Spinners[51] := ValueOf(Value);
         End; {if}
      end; {if Attribute}

      if Attribute = 'pitch-range' then Begin
         CGroups[88] := True;
         Lights[88] := True;
         If ValueLC = 'inherit' then
            Radios[131] := True
         Else Begin
            Radios[130] := True;
            Spinners[52] := ValueOf(Value);
         End; {if}
      end; {if Attribute}

      if Attribute = 'stress' then Begin
         CGroups[89] := True;
         Lights[89] := True;
         If ValueLC = 'inherit' then
            Radios[133] := True
         Else Begin
            Radios[132] := True;
            Spinners[53] := ValueOf(Value);
         End; {if}
      end; {if Attribute}

      if Attribute = 'speak-punctuation' then Begin
         If StringInSet(ValueLC, S[54]) then Begin
            CGroups[90] := True;
            Lights[90] := True;
            Selects[121] := ValueLC;
         End; {if}
      end; {if Attribute}

      if Attribute = 'speak-numeral' then Begin
         If StringInSet(ValueLC, S[55]) then Begin
            CGroups[91] := True;
            Lights[91] := True;
            Selects[122] := ValueLC;
         End; {if}
      end; {if Attribute}


   end; {with}
end; {TCascadeDocument.InterpretRule}


{-----------------------------------------------------------------------------
  ValueOf;
     Converts a string to a float without errors.
 -----------------------------------------------------------------------------}
function ValueOf(theString : String) : Extended;
begin
   try
      Result := StrToFloat(theString)
   except
      Result := 0.0;
   end; {try}
end; {ValueOf}

{-----------------------------------------------------------------------------
  StringInSet;
     Returns TRUE if the unquoted theSub is in theString with no regard to case.
 -----------------------------------------------------------------------------}
function StringInSet(theSub, theString : String) : Boolean;
var myL : TStringList;
      i : LongInt;
Begin
   Result := False;
   myL := TStringList.Create;
   myL.CommaText := theString;
   for i := 0 to myL.Count - 1 do
      if LowerCase(myL[i]) = LowerCase(theSub) then Result := True;
End;

{-----------------------------------------------------------------------------
  RightStr;
     RightStr function.
 -----------------------------------------------------------------------------}
function RightStr(theString : String; theLength : LongInt) : String;
Begin
   If theLength > Length(theString) then theLength := Length(theString);
   Result := Copy(theString, Length(theString) - theLength + 1, theLength);
End;

{-----------------------------------------------------------------------------
  LeftStr;
     LeftStr function.
 -----------------------------------------------------------------------------}
function LeftStr(theString : String; theLength : LongInt) : String;
Begin
   If theLength > Length(theString) then theLength := Length(theString);
   Result := Copy(theString, 1, theLength);
End;

 {-----------------------------------------------------------------------------
  StripQuotes;
   Cascade automatically provides quotes. Ensure that things here don't have
   them at the beginning and/or ending.
 -----------------------------------------------------------------------------}
function StripQuotes(theS : String) : String;
var T : String;
Begin
   T := theS;
   while (Length(T) > 1) AND ((Copy(T, 1, 1) = '''') or (Copy(T, 1, 1) = '"')) do
      T := Copy(T, 2, Length(T));
   while (Length(T) > 1) AND ((Copy(T, Length(T), 1) = '''') or (Copy(T, Length(T), 1) = '"')) do
      T := Copy(T, 1, Length(T)-1);
   Result := Strip(T);
End; {StripQuotes}

{-----------------------------------------------------------------------------
  Strip;
   Remove spaces.
 -----------------------------------------------------------------------------}
function Strip(theS : String) : String;
Begin
   Result := Trim(theS);
End; {Strip}

{-----------------------------------------------------------------------------
  IsBorderAttribute
   Returns TRUE if the attribute is one of the border attributes.
 -----------------------------------------------------------------------------}
function IsBorderAttribute(Attribute : String) : Boolean;
begin
   Result := False;
   if Attribute = 'border' then Result := True;
   if Attribute = 'border-top' then Result := True;
   if Attribute = 'border-bottom' then Result := True;
   if Attribute = 'border-left' then Result := True;
   if Attribute = 'border-right' then Result := True;
   if Attribute = 'border-width' then Result := True;
   if Attribute = 'border-color' then Result := True;
   if Attribute = 'border-style' then Result := True;
   if Attribute = 'border-top-width' then Result := True;
   if Attribute = 'border-top-color' then Result := True;
   if Attribute = 'border-top-style' then Result := True;
   if Attribute = 'border-bottom-width' then Result := True;
   if Attribute = 'border-bottom-color' then Result := True;
   if Attribute = 'border-bottom-style' then Result := True;
   if Attribute = 'border-left-width' then Result := True;
   if Attribute = 'border-left-color' then Result := True;
   if Attribute = 'border-left-style' then Result := True;
   if Attribute = 'border-right-width' then Result := True;
   if Attribute = 'border-right-color' then Result := True;
   if Attribute = 'border-right-style' then Result := True;
end; {IsBorderAttribute}

end.

