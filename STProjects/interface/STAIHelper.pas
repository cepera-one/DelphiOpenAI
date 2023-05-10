{$M+}unit STAIHelper;

{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

{$MINENUMSIZE 4}
interface


  
const
  STAIHelperMajorVersion = 1;
  STAIHelperMinorVersion = 0;

  // Constants for  TChatMessageRole
type
  TChatMessageRole = 
  (
    cmrSystem = 0,
    cmrUser = 1,
    cmrAssistant = 2
  );

type
  IST_AIAPI = interface;
  IST_AIChatConversation = interface;
  IST_OpenAIChatConversation = interface;
  IST_AIChatMessage = interface;
  IST_AIChatResult = interface;
  IST_AIChatChoice = interface;
  IST_AIUsage = interface;
  IST_AIChatUsage = interface;
  IST_StreamResponseFromChatbotHandler = interface;
  IST_ChatRequestOptions = interface;
  IST_OpenAIChatRequest = interface;
  IST_OpenAIChatMultipleStopSequences = interface;
  IST_AICompletionEndpoint = interface;
  IST_OpenAICompletionEndpoint = interface;
  IST_AIHelper = interface;


  IST_AIAPI = interface(IUnknown)
    ['{B6C4689C-8933-4D24-B48F-9422035A8107}']
    function CreateConversation: IST_OpenAIChatConversation; safecall;
    function Get_Completions: IST_OpenAICompletionEndpoint; safecall;
    property Completions: IST_OpenAICompletionEndpoint read Get_Completions;
  end;

  IST_AIChatConversation = interface(IUnknown)
    ['{E80EA825-82D3-4055-B570-2D4A34251A85}']
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
  end;

  IST_OpenAIChatConversation = interface(IST_AIChatConversation)
    ['{5F22E9A2-50AE-439A-934D-56D12AEF5FDE}']
    function Get_RequestParameters: IST_OpenAIChatRequest; safecall;
    property RequestParameters: IST_OpenAIChatRequest read Get_RequestParameters;
  end;

  IST_AIChatMessage = interface(IUnknown)
    ['{128C8B5A-F1D8-4436-B24E-EE1551C7228B}']
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

  IST_AIChatResult = interface(IUnknown)
    ['{9CE87B7E-8FAE-4D14-8EE7-A1CDFCE85AA7}']
    function Get_Id: WideString; safecall;
    procedure Set_Id(const Value: WideString); safecall;
    function Get_Choices(index: Integer): IST_AIChatChoice; safecall;
    procedure Set_Choices(index: Integer; const Value: IST_AIChatChoice); safecall;
    function Get_Usage: IST_AIChatUsage; safecall;
    function ToString: WideString; safecall;
    property Id: WideString read Get_Id write Set_Id;
    property Choices[index: Integer]: IST_AIChatChoice read Get_Choices write Set_Choices;
    property Usage: IST_AIChatUsage read Get_Usage;
  end;

  IST_AIChatChoice = interface(IUnknown)
    ['{77D53FC7-F7A0-4ECE-B871-FAF5A45F1DE9}']
    function Get_index: Integer; safecall;
    procedure Set_index(Value: Integer); safecall;
    function Get_Message: IST_AIChatMessage; safecall;
    procedure Set_Message(const Value: IST_AIChatMessage); safecall;
    function Get_FinishReason: WideString; safecall;
    procedure Set_FinishReason(const Value: WideString); safecall;
    function Get_Delta: IST_AIChatMessage; safecall;
    procedure Set_Delta(const Value: IST_AIChatMessage); safecall;
    function ToString: WideString; safecall;
    property index: Integer read Get_index write Set_index;
    property Message: IST_AIChatMessage read Get_Message write Set_Message;
    property FinishReason: WideString read Get_FinishReason write Set_FinishReason;
    property Delta: IST_AIChatMessage read Get_Delta write Set_Delta;
  end;

  IST_AIUsage = interface(IUnknown)
    ['{12D59E3C-4F33-4D36-AEE1-A2BD2DB53E1D}']
    function Get_PromptTokens: Integer; safecall;
    procedure Set_PromptTokens(Value: Integer); safecall;
    function Get_TotalTokens: Integer; safecall;
    procedure Set_TotalTokens(Value: Integer); safecall;
    property PromptTokens: Integer read Get_PromptTokens write Set_PromptTokens;
    property TotalTokens: Integer read Get_TotalTokens write Set_TotalTokens;
  end;

  IST_AIChatUsage = interface(IST_AIUsage)
    ['{6F71879F-443F-413B-95CC-A68E66132D06}']
    function Get_CompletionTokens: Integer; safecall;
    procedure Set_CompletionTokens(Value: Integer); safecall;
    property CompletionTokens: Integer read Get_CompletionTokens write Set_CompletionTokens;
  end;

  IST_StreamResponseFromChatbotHandler = interface(IUnknown)
    ['{B34A5368-2E32-43F1-A933-A30D8DD838BA}']
    procedure HandleResponse(index: Integer; const Content: WideString); safecall;
  end;

  IST_ChatRequestOptions = interface(IUnknown)
    ['{F166651C-D5D2-4D0E-9FC0-6C7D47C04750}']
  end;

  IST_OpenAIChatRequest = interface(IST_ChatRequestOptions)
    ['{32B40B1E-DFC3-4657-9EE9-88A6F588B18B}']
    function Get_Model: WideString; safecall;
    procedure Set_Model(const Value: WideString); safecall;
    function Get_MessagesCount: Integer; safecall;
    function Get_Messages(index: Integer): IST_AIChatMessage; safecall;
    function Get_Temperature: Double; safecall;
    procedure Set_Temperature(Value: Double); safecall;
    function Get_TopP: Double; safecall;
    procedure Set_TopP(Value: Double); safecall;
    function Get_NumChoicesPerMessage: Integer; safecall;
    procedure Set_NumChoicesPerMessage(Value: Integer); safecall;
    function Get_Stream: WordBool; safecall;
    function Get_MultipleStopSequences: IST_OpenAIChatMultipleStopSequences; safecall;
    function Get_StopSequence: WideString; safecall;
    procedure Set_StopSequence(const Value: WideString); safecall;
    function Get_MaxTokens: Integer; safecall;
    procedure Set_MaxTokens(Value: Integer); safecall;
    function Get_FrequencyPenalty: Double; safecall;
    procedure Set_FrequencyPenalty(Value: Double); safecall;
    function Get_PresencePenalty: Double; safecall;
    procedure Set_PresencePenalty(Value: Double); safecall;
    function Get_user: WideString; safecall;
    procedure Set_user(const Value: WideString); safecall;
    property Model: WideString read Get_Model write Set_Model;
    property MessagesCount: Integer read Get_MessagesCount;
    property Messages[index: Integer]: IST_AIChatMessage read Get_Messages;
    property Temperature: Double read Get_Temperature write Set_Temperature;
    property TopP: Double read Get_TopP write Set_TopP;
    property NumChoicesPerMessage: Integer read Get_NumChoicesPerMessage write Set_NumChoicesPerMessage;
    property Stream: WordBool read Get_Stream;
    property MultipleStopSequences: IST_OpenAIChatMultipleStopSequences read Get_MultipleStopSequences;
    property StopSequence: WideString read Get_StopSequence write Set_StopSequence;
    property MaxTokens: Integer read Get_MaxTokens write Set_MaxTokens;
    property FrequencyPenalty: Double read Get_FrequencyPenalty write Set_FrequencyPenalty;
    property PresencePenalty: Double read Get_PresencePenalty write Set_PresencePenalty;
    property user: WideString read Get_user write Set_user;
  end;

  IST_OpenAIChatMultipleStopSequences = interface(IUnknown)
    ['{BA2E9C4D-CDF7-45E6-9164-0EA34EA32BE2}']
    function Get_Count: Integer; safecall;
    function Get_Sequences(index: Integer): WideString; safecall;
    procedure Set_Sequences(index: Integer; const Value: WideString); safecall;
    property Count: Integer read Get_Count;
    property Sequences[index: Integer]: WideString read Get_Sequences write Set_Sequences;
  end;

  IST_AICompletionEndpoint = interface(IUnknown)
    ['{A8D7C493-F748-4EB3-8167-68E0412FDCF3}']
    function GetCompletion(const prompt: WideString): WideString; safecall;
  end;

  IST_OpenAICompletionEndpoint = interface(IST_AICompletionEndpoint)
    ['{535759EE-9CD5-473E-AFC1-06472FCC2B6E}']
  end;

  IST_AIHelper = interface(IUnknown)
    ['{BCC9BEE5-7020-44FB-9B37-3C93F2CF6791}']
    function CreateOpenAIAPIWithKey(const APIKey: WideString): IST_AIAPI; safecall;
    function CreateSprutCAMAIAPI: IST_AIAPI; safecall;
  end;

implementation



end.
