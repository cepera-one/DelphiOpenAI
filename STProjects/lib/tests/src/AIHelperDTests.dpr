program AIHelperDTests;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  Winapi.Windows,
  STAIHelper in '..\..\..\interface\STAIHelper.pas';


type
  THandleResponseProc = reference to procedure (index: Integer; const Content: string);

  TResponseFromChatbotHandler = class(TInterfacedObject, IST_StreamResponseFromChatbotHandler)
  private
    fProc: THandleResponseProc;
  public
    constructor Create(proc: THandleResponseProc);
    procedure HandleResponse(index: Integer; const Content: WideString); safecall;
  end;

{ TResponseFromChatbotHandler }

constructor TResponseFromChatbotHandler.Create(proc: THandleResponseProc);
begin
  inherited Create;
  fProc := proc;
end;

procedure TResponseFromChatbotHandler.HandleResponse(index: Integer;
  const Content: WideString);
begin
  fProc(index, Content);
end;

function ExpandEnvironmentVariables(s: string): string;
var
  BufSize: Integer;
begin
  if s='' then
    Exit(s);
  BufSize := ExpandEnvironmentStrings(PChar(s), nil, 0);
  if BufSize > 0 then begin
    SetLength(Result, BufSize - 1);
    ExpandEnvironmentStrings(PChar(s), PChar(Result), BufSize);
  end else
    Result := '';
end;

procedure Test1(const api: IST_AIAPI);
begin
  var chat := api.CreateConversation();

  /// give instruction as System
  chat.AppendSystemMessage('You are a teacher who helps children understand '  +
    'if things are animals or not.  If the user tells you an animal, you say "yes".  ' +
    'If the user tells you something that is not an animal, you say "no".  ' +
    'You only ever respond with "yes" or "no".  You do not say anything else.');

  // give a few examples as user and assistant
  chat.AppendUserInput('Is this an animal? Cat');
  chat.AppendExampleChatbotOutput('Yes');
  chat.AppendUserInput('Is this an animal? House');
  chat.AppendExampleChatbotOutput('No');

  // now let's ask it a question'
  chat.AppendUserInput('Is this an animal? Dog');
  // and get the response
  var response := chat.GetResponseFromChatbot();
  WriteLn(response); // "Yes"

  // and continue the conversation by asking another
  chat.AppendUserInput('Is this an animal? Chair');
  // and get another response
  response := chat.GetResponseFromChatbot();
  WriteLn(response); // "No"

  // the entire chat history is available in chat.Messages
  for var i:=0 to chat.MessagesCount-1 do begin
    var msg := chat.Messages[i];
    WriteLn(msg.RoleAsString + ' ' + msg.Content);
  end;
end;

procedure TestCodeStreamMode(const api: IST_AIAPI);
begin
  var chat := api.CreateConversation();
//  chat.RequestParameters.Temperature = 0.7;
  chat.AppendSystemMessage(
    'You are the assistant of the SprutCAM CAM system software. ' +
    'You must answer user questions clearly and concisely. ' +
    'When you provide code examples, separate them from' +
    'the rest of your answer using three ` before and after the each code block.'
  );
  chat.AppendUserInput(
    'Explain me provided G code. Show the G code with comments itself only.' + #13#10 +
    'G90' + #13#10 +
    'G21' + #13#10 +
    'X10 Y10' + #13#10 +
    'Z5' + #13#10 +

    'G1 Z-1 F100' + #13#10 +
    'G1 X50 Y10 F500' + #13#10 +
    'G1 X50 Y40' + #13#10 +
    'G1 X10 Y40' + #13#10 +
    'G1 X10 Y10' + #13#10 +
    'G1 Z5' + #13#10 +
    'M2'
  );

  // and get response step by step
  chat.StreamResponseFromChatbot(
    TResponseFromChatbotHandler.Create(
      procedure (index: Integer; const Content: string)
      begin
        Write(content);
      end
    )
  );
  WriteLn('');
  // the entire chat history is available in chat.Messages
  for var i := 0 to chat.MessagesCount-1 do begin
    var msg := chat.Messages[i];
    WriteLn('Role: ' + msg.RoleAsString);
    Write(msg.Content);
    WriteLn('');
  end;
end;


procedure Main();
var
  CreateHelperFunc: function (): IST_AIHelper;
begin
  var h := LoadLibrary('AIHelperD.dll');
  if h<>0 then begin
    CreateHelperFunc := GetProcAddress(h, 'CreateAIHelper');
    if Assigned(CreateHelperFunc) then begin
      var helper := CreateHelperFunc();
      if helper<>nil then begin
        var apiKey := '';
        var kfn := ExpandEnvironmentVariables('%userprofile%\.openai\api.key');
        if FileExists(kfn) then
          apiKey := Trim(TFile.ReadAllText(kfn));
        var api := helper.CreateOpenAIAPIWithKey(apiKey);

//        Test1(api);
        TestCodeStreamMode(api);

      end;
    end;
    FreeLibrary(h);
  end;
  WriteLn('Press any key...');
  var s: string;
  ReadLn(s);
end;

begin
  try
    Main();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
