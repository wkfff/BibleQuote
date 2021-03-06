unit ExceptionFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SystemInfo;

type
  TExceptionForm = class(TForm)
    memError: TMemo;
    lblLog: TLabel;
    btnOK: TButton;
    btnHalt: TButton;
    procedure btnHaltClick(Sender: TObject);
  private
    mNonContinuable: boolean;
  end;

procedure BqShowException(e: Exception; addInfo: string = ''; nonContinuable: boolean = false);
function StackLst(codePtr, stackTop: Pointer): string;

var
  ExceptionForm: TExceptionForm;

implementation

uses JclDebug, BibleQuoteUtils, PlainUtils, AppInfo;
{$R *.dfm}

var
  bqExceptionLog: TbqTextFileWriter;

function getExceptionLog(): TbqTextFileWriter;
begin
  if not assigned(bqExceptionLog) then
    bqExceptionLog := TbqTextFileWriter.Create(CreateAndGetConfigFolder() + 'bqErr.log');

  result := bqExceptionLog;
end;

function CloseLog(): HRESULT;
begin
  if assigned(bqExceptionLog) then
  begin
    FreeAndNil(bqExceptionLog);
    result := S_OK;
  end
  else
    result := S_FALSE;
end;

procedure BqShowException(e: Exception; addInfo: string = ''; nonContinuable: boolean = false);
var
  lns: TStrings;
  iv: TIdleEvent;
  exceptionLog: TbqTextFileWriter;
begin

  if not assigned(ExceptionForm) then
    ExceptionForm := TExceptionForm.Create(Application);
  exceptionLog := getExceptionLog();
  ExceptionForm.memError.Lines.clear();
  lns := TStringList.Create();
  iv := Application.OnIdle;
  Application.OnIdle := nil;
  try
    ExceptionForm.mNonContinuable := ExceptionForm.mNonContinuable or
      nonContinuable;
    lns.clear;
    JclLastExceptStackListToStrings(lns, true, true, true, false);
    lns.Insert(0, Format('Exception:%s, msg:%s', [e.ClassName, e.Message]));

    if g_ExceptionContext.Count > 0 then
      lns.Insert(1, 'Context:'#13#10 + g_ExceptionContext.Text);

    if length(addInfo) > 0 then
      lns.Insert(0, addInfo);

    ExceptionForm.btnOK.Enabled := not nonContinuable;
    lns.Add('OS info:' + WinInfoString());
    lns.Add('bqVersion: ' + GetAppVersionStr());
    ExceptionForm.memError.Lines.AddStrings(lns);
    exceptionLog.WriteLine(NowDateTimeString() + ':');
    exceptionLog.WriteLine(lns.Text);
    exceptionLog.WriteLine('--------');
    if not ExceptionForm.visible then
    begin
      ExceptionForm.ShowModal();
      if nonContinuable then
        halt(1);
    end;

  finally
    ExceptionForm.mNonContinuable := false;
    lns.free();
    g_ExceptionContext.clear();
    Application.OnIdle := iv;
  end;
end;

function StackLst(codePtr, stackTop: Pointer): string;
var
  stackInfo: TJclStackInfoList;
  sl: TStringList;
begin
  sl := nil;
  result := '';
  stackInfo := TJclStackInfoList.Create(
    true, 3, codePtr, false, nil, stackTop);

  if assigned(stackInfo) then
  begin
    try
      sl := TStringList.Create();
      stackInfo.AddToStrings(sl, true, true, true);
      result := sl.Text;
    finally
      stackInfo.free();
      sl.free();
    end;
  end;

end;

procedure TExceptionForm.btnHaltClick(Sender: TObject);
begin

  CloseLog();
  halt(1);
end;

initialization

finalization

CloseLog();

end.
