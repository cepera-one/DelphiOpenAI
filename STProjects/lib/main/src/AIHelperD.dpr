library AIHelperD;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.

  Important note about VCL usage: when this DLL will be implicitly
  loaded and this DLL uses TWicImage / TImageCollection created in
  any unit initialization section, then Vcl.WicImageInit must be
  included into your library's USES clause. }

uses
  System.SysUtils,
  System.Classes,
  STAIHelper in '..\..\..\interface\STAIHelper.pas',
  AIHelperImpl in 'AIHelperImpl.pas',
  OpenAI,
  OpenAI.API,
  OpenAI.API.Params,
  OpenAI.Audio,
  OpenAI.Chat,
  OpenAI.Completions,
  OpenAI.Edits,
  OpenAI.Embeddings,
  OpenAI.Engines,
  OpenAI.Errors,
  OpenAI.Files,
  OpenAI.FineTunes,
  OpenAI.Images,
  OpenAI.Models,
  OpenAI.Moderations,
  OpenAI.Utils.ChatHistory;

{$R *.res}

begin
end.
