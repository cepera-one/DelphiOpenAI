unit AIHelperImpl;

interface

uses
  System.SysUtils,
  OpenAI,
  OpenAI.Chat,
  STAIHelper,
  System.Generics.Collections;

type

  TST_AIChatMessage = class;


  TST_AIHelper = class(TInterfacedObject, IST_AIHelper)
  private
  public
    function CreateOpenAIAPIWithKey(const APIKey: WideString): IST_AIAPI; safecall;
    function CreateSprutCAMAIAPI: IST_AIAPI; safecall;
  end;

  TST_AIAPI = class(TInterfacedObject, IST_AIAPI)
  private
    fOpenAI: IOpenAI;
  public
    constructor Create(const APIKey: WideString);

    function CreateConversation: IST_OpenAIChatConversation; safecall;
    function Get_Completions: IST_OpenAICompletionEndpoint; safecall;
    property Completions: IST_OpenAICompletionEndpoint read Get_Completions;
  end;

  TST_AIChatConversation = class(TInterfacedObject, IST_AIChatConversation,
    IST_OpenAIChatConversation)
  private const
    DefaultMaxTokens = 1024;
  private
    fOpenAI: IOpenAI;
    fMessages: TList<IST_AIChatMessage>;
  public
    constructor Create(OpenAI: IOpenAI);

    //IST_AIChatConversation
    function Get_MessagesCount: Integer; safecall;
    function Get_Messages(index: Integer): IST_AIChatMessage; safecall;
    function Get_MostResentAPIResult: IST_AIChatResult; safecall;
    procedure AppendExampleChatbotOutput(const Content: WideString); safecall;
    procedure AppendMessage(Role: TChatMessageRole; const Content: WideString); safecall;
    procedure AppendSystemMessage(const Content: WideString); safecall;
    procedure AppendUserInput(const Content: WideString); safecall;
    procedure AppendUserInputWithName(const userName: WideString; const Content: WideString); safecall;
    function GetResponseFromChatbot: WideString; safecall;
    procedure StreamResponseFromChatbot(const resultHandler: IST_StreamResponseFromChatbotHandler); safecall;
    property MessagesCount: Integer read Get_MessagesCount;
    property Messages[index: Integer]: IST_AIChatMessage read Get_Messages;
    property MostResentAPIResult: IST_AIChatResult read Get_MostResentAPIResult;

    //IST_OpenAIChatConversation
    function Get_RequestParameters: IST_OpenAIChatRequest; safecall;
    property RequestParameters: IST_OpenAIChatRequest read Get_RequestParameters;
  end;

  TST_AIChatMessage = class(TInterfacedObject, IST_AIChatMessage)
  private
    fRole: TChatMessageRole;
    fContent: WideString;
    fName: WideString;
  public
    function Get_Role: TChatMessageRole; safecall;
    procedure Set_Role(Value: TChatMessageRole); safecall;
    function Get_RoleAsString: WideString; safecall;
    function Get_Content: WideString; safecall;
    procedure Set_Content(const Value: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    property Role: TChatMessageRole read Get_Role write Set_Role;
    property RoleAsString: WideString read Get_RoleAsString;
    property Content: WideString read Get_Content write Set_Content;
    property Name: WideString read Get_Name write Set_Name;
  end;


  function CreateAIHelper(): IST_AIHelper;

exports
  CreateAIHelper;

implementation

function CreateAIHelper(): IST_AIHelper;
begin
  result := TST_AIHelper.Create;
end;

{ TST_AIHelper }

function TST_AIHelper.CreateOpenAIAPIWithKey(
  const APIKey: WideString): IST_AIAPI;
begin
  result := TST_AIAPI.Create(APIKey);
end;

function TST_AIHelper.CreateSprutCAMAIAPI: IST_AIAPI;
begin
  result := nil;
end;

{ TST_AIAPI }

constructor TST_AIAPI.Create(const APIKey: WideString);
begin
  inherited Create;
  fOpenAI := TOpenAI.Create(APIKey);
end;

function TST_AIAPI.CreateConversation: IST_OpenAIChatConversation;
begin
  result := TST_AIChatConversation.Create(fOpenAI);
end;

function TST_AIAPI.Get_Completions: IST_OpenAICompletionEndpoint;
begin
  result := nil;
end;

{ TST_AIChatConversation }

procedure TST_AIChatConversation.AppendExampleChatbotOutput(
  const Content: WideString);
begin
  var msg := TST_AIChatMessage.Create;
  fMessages.Add(msg);
  msg.Role := TChatMessageRole.cmrAssistant;
  msg.Content := Content;
end;

procedure TST_AIChatConversation.AppendMessage(Role: TChatMessageRole;
  const Content: WideString);
begin
  var msg := TST_AIChatMessage.Create;
  fMessages.Add(msg);
  msg.Role := Role;
  msg.Content := Content;
end;

procedure TST_AIChatConversation.AppendSystemMessage(const Content: WideString);
begin
  var msg := TST_AIChatMessage.Create;
  fMessages.Add(msg);
  msg.Role := TChatMessageRole.cmrSystem;
  msg.Content := Content;
end;

procedure TST_AIChatConversation.AppendUserInput(const Content: WideString);
begin
  var msg := TST_AIChatMessage.Create;
  fMessages.Add(msg);
  msg.Role := TChatMessageRole.cmrUser;
  msg.Content := Content;
end;

procedure TST_AIChatConversation.AppendUserInputWithName(const userName,
  Content: WideString);
begin
  var msg := TST_AIChatMessage.Create;
  fMessages.Add(msg);
  msg.Role := TChatMessageRole.cmrUser;
  msg.Content := Content;
  msg.Name := userName;
end;

constructor TST_AIChatConversation.Create(OpenAI: IOpenAI);
begin
  inherited Create;
  fOpenAI := OpenAI;
  fMessages := TList<IST_AIChatMessage>.Create;
end;

function TST_AIChatConversation.GetResponseFromChatbot: WideString;
begin
  result := '';
  try
    var Chat := fOpenAI.Chat.Create(
      procedure(Params: TChatParams)
      begin
        var ml: TArray<TChatMessageBuild> := nil;
        SetLength(ml, fMessages.Count);
        for var i := 0 to fMessages.Count-1 do begin
          var msg := fMessages[i];
          var mb: TChatMessageBuild;
          case msg.Role of
            cmrSystem:
              mb := TChatMessageBuild.System(msg.Content, msg.Name);
            cmrUser:
              mb := TChatMessageBuild.User(msg.Content, msg.Name);
            cmrAssistant:
              mb := TChatMessageBuild.Assistant(msg.Content, msg.Name);
          end;
          ml[i] := mb;
        end;
        Params.Messages(ml);
        Params.MaxTokens(DefaultMaxTokens);
      end);
    try
      if Length(Chat.Choices)>0 then begin
        var c := Chat.Choices[0];
        if c.Message<>nil then begin
          AppendMessage(TChatMessageRole.cmrAssistant, c.Message.Content);
          result := c.Message.Content;
        end;
      end;
    finally
      Chat.Free;
    end;
  except
    on E: Exception do begin
      result := E.Message;
    end;
  end;
end;

function TST_AIChatConversation.Get_Messages(index: Integer): IST_AIChatMessage;
begin
  result := fMessages[index];
end;

function TST_AIChatConversation.Get_MessagesCount: Integer;
begin
  result := fMessages.Count;
end;

function TST_AIChatConversation.Get_MostResentAPIResult: IST_AIChatResult;
begin
  result := nil;
end;

function TST_AIChatConversation.Get_RequestParameters: IST_OpenAIChatRequest;
begin
  result := nil;
end;

procedure TST_AIChatConversation.StreamResponseFromChatbot(
  const resultHandler: IST_StreamResponseFromChatbotHandler);
begin
  var resultContent := '';
  fOpenAI.Chat.CreateStream(
    procedure(Params: TChatParams)
    begin
      var ml: TArray<TChatMessageBuild> := nil;
      SetLength(ml, fMessages.Count);
      for var i := 0 to fMessages.Count-1 do begin
        var msg := fMessages[i];
        var mb: TChatMessageBuild;
        case msg.Role of
          cmrSystem:
            mb := TChatMessageBuild.System(msg.Content, msg.Name);
          cmrUser:
            mb := TChatMessageBuild.User(msg.Content, msg.Name);
          cmrAssistant:
            mb := TChatMessageBuild.Assistant(msg.Content, msg.Name);
        end;
        ml[i] := mb;
      end;
      Params.Messages(ml);
      Params.MaxTokens(DefaultMaxTokens);
      Params.Stream;
    end,
    procedure(Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
    begin
      var ok := false;
      if IsDone then
        AppendMessage(TChatMessageRole.cmrAssistant, resultContent);
      if Assigned(Chat) and (Length(Chat.Choices)>0) then begin
        var c := Chat.Choices[0];
        if c.Delta<>nil then begin
          resultHandler.HandleResponse(c.Index, c.Delta.Content);
          resultContent := resultContent + c.Delta.Content;
          ok := true;
        end;
      end;
    end
  );
end;

{ TST_AIChatMessage }

function TST_AIChatMessage.Get_Content: WideString;
begin
  result := fContent;
end;

function TST_AIChatMessage.Get_Name: WideString;
begin
  result := fName;
end;

function TST_AIChatMessage.Get_Role: TChatMessageRole;
begin
  result := fRole;
end;

function TST_AIChatMessage.Get_RoleAsString: WideString;
begin
  case fRole of
    cmrSystem: result := 'System';
    cmrUser: result := 'User';
    cmrAssistant: result := 'Assistant';
  end;
end;

procedure TST_AIChatMessage.Set_Content(const Value: WideString);
begin
  fContent := Value;
end;

procedure TST_AIChatMessage.Set_Name(const Value: WideString);
begin
  fName := Value;
end;

procedure TST_AIChatMessage.Set_Role(Value: TChatMessageRole);
begin
  fRole := Value;
end;

end.
