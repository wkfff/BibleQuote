unit GfxRenderers;

interface

uses TagsDb, Graphics, Windows, ICommandProcessor, WinUIServices, Htmlsubs,
  System.UITypes;

type
  TbqTagVersesContent = (tvcTag, tvcPlainTxt, tvcLink);

  TbqTagsRenderer = class(TObject)
  private
    class var miCommandProcessor: IBibleQuoteCommandProcessor;
    class var miUIServices: IBibleWinUIServices;
    class var mCurrentRenderer: TSectionList;
    class var mVmargin, mHmargin, mCurveRadius: integer;
    class var mSaveBrush: TBrush;
    class var mTagFont, mDefaultVerseFont: TFont;

    class function EffectiveGetVerseNodeText(var nd: TVersesNodeData; var usedFnt: string): string; static;
    class function GetHTMLRenderer(id: int64; out match: boolean): TSectionList; static;
    class procedure ResetRendererStyles(renderer: TSectionList; prefFnt: string);

    class function BuildVerseHTML(
      const verseTxt: string;
      const verseCommand: string;
      const verseSignature: string): string; static;

    class procedure SetVMargin(value: integer); static;
    class procedure SetHMargin(value: integer); static;
  public
    class procedure Init(
      ICommandProcessor: IBibleQuoteCommandProcessor;
      iUIServices: IBibleWinUIServices;
      tagFont, verseFont: TFont);

    class procedure Done();

    class function RenderTagNode(
      canvas: TCanvas;
      nodeData: TVersesNodeData;
      const title: string;
      selected, calcOnly: boolean; var rect: TRect): integer; static;

    class function RenderVerseNode(
      canvas: TCanvas;
      var nodeData: TVersesNodeData;
      calcOnly: boolean; var rect: TRect): integer; static;

    class function CurrentRenderer(): TSectionList; static;
    class procedure InvalidateRenderers(); static;

    class function GetContentTypeAt(
      x, y: integer;
      canvas: TCanvas;
      var nodeData: TVersesNodeData;
      rect: TRect): TbqTagVersesContent; static;

    class property VMargin: integer read mVmargin write SetVMargin;
    class property HMargin: integer read mHmargin write SetHMargin;
    class property CurveRadius: integer read mCurveRadius write mCurveRadius;
    class property tagFont: TFont read mTagFont write mTagFont;
    class property DefaultVerseFont: TFont read mDefaultVerseFont write mDefaultVerseFont;
  end;

implementation

uses PlainUtils, Readhtml, SysUtils, CommandProcessor, HTMLUn2,
  HTMLEmbedInterfaces, HTMLViewerSite;

type
  TRendererPair = record
    id: int64;
    renderer: TSectionList;
  end;

  { TbqTagsRenderer }
var
  _rendererPair: TRendererPair;

class function TbqTagsRenderer.BuildVerseHTML(
  const verseTxt: string;
  const verseCommand: string;
  const verseSignature: string): string;
begin
  result := Format('<HTML><BODY><a href="%s">%s</a> %s</BODY></HTML>',
    [verseCommand, verseSignature, verseTxt]);
end;

class function TbqTagsRenderer.CurrentRenderer: TSectionList;
begin
  result := mCurrentRenderer
end;

class procedure TbqTagsRenderer.Done;
begin
  miCommandProcessor := nil;
  miUIServices := nil;
  FreeAndNil(mSaveBrush);
  mCurrentRenderer := nil;
end;

class function TbqTagsRenderer.EffectiveGetVerseNodeText(var nd: TVersesNodeData; var usedFnt: string): string;
var
  cmd, verseSig, verseText: string;
  commandType: TbqCommandType;
  hr: HRESULT;
begin
  cmd := nd.getText();

  commandType := GetCommandType(cmd);
  if commandType = bqctInvalid then
  begin
    hr := nd.unpackCached(cmd, verseSig, usedFnt, verseText);
  end
  else
    hr := 0;
  if (commandType <> bqctInvalid) or (hr <> 0) then
  begin
    if hr <> 0 then
    begin

      nd.cachedTxt := ''; // clear txt so that initialize to cmd
      cmd := nd.getText(); // rebuild cmd from db values
    end;
    verseText := miCommandProcessor.GetAutoTxt(cmd, 20, usedFnt, verseSig);
    nd.packCached(verseSig, verseText, usedFnt);
  end;
  result := BuildVerseHTML(verseText, cmd, verseSig);
end;

class function TbqTagsRenderer.GetContentTypeAt(
  x, y: integer;
  canvas: TCanvas;
  var nodeData: TVersesNodeData;
  rect: TRect): TbqTagVersesContent;
var
  renderer: TSectionList;
  match: boolean;
  txt: string;
  usedFnt: string;
  sw, cur: integer;
  UrlTarget: TUrlTarget;
  formControl: TIDObject;
  title: string;

  gur: guResultType;
begin

  if nodeData.nodeType = bqvntTag then
  begin
    result := tvcTag;
    exit;
  end;
  renderer := GetHTMLRenderer(nodeData.SelfId, match);
  try
    mCurrentRenderer := renderer;
    if not match then
    begin
      txt := EffectiveGetVerseNodeText(nodeData, usedFnt);
      ResetRendererStyles(renderer, usedFnt);
      ParseHTMLString(txt, renderer, nil, nil, nil, nil);
      renderer.DoLogic(canvas, rect.Top + VMargin, rect.Right - rect.Left - HMargin - HMargin, 500, 0, sw, cur);
    end;

    UrlTarget := nil;
    formControl := nil;
    gur := renderer.GetURL(canvas, x - HMargin, y + renderer.YOff, UrlTarget, formControl, title);

    if guUrl in gur then
      result := tvcLink
    else
      result := tvcPlainTxt;
  finally
    mCurrentRenderer := nil;
  end;
end;

class function TbqTagsRenderer.GetHTMLRenderer(id: int64; out match: boolean): TSectionList;
var
  ihtmlViewer: IHtmlViewerBase;
  isite: IHTMLViewerSite;
  r: HRESULT;
begin
  if not assigned(_rendererPair.renderer) then
  begin
    ihtmlViewer := miUIServices.GetIViewerBase();
    _rendererPair.renderer := TSectionList.Create(ihtmlViewer, miUIServices.GetMainWindow());
    r := ihtmlViewer.QueryInterface(IHTMLViewerSite, isite);
    if r <> S_OK then
      raise Exception.Create('Wrong ihtmlviewersite passed');

    isite.Init(_rendererPair.renderer);
    match := false;
  end
  else
  begin
    if _rendererPair.id <> id then
    begin
      _rendererPair.renderer.Clear();
      match := false;
    end
    else
      match := true;
  end;
  result := _rendererPair.renderer;
  _rendererPair.id := id;
end;

class procedure TbqTagsRenderer.Init(
  ICommandProcessor: IBibleQuoteCommandProcessor;
  iUIServices: IBibleWinUIServices;
  tagFont, verseFont: TFont);
begin
  miCommandProcessor := ICommandProcessor;
  miUIServices := iUIServices;
  mSaveBrush := TBrush.Create();
  mTagFont := tagFont;
  mDefaultVerseFont := verseFont;
end;

class procedure TbqTagsRenderer.InvalidateRenderers;
begin
  _rendererPair.id := -1;
  if assigned(_rendererPair.renderer) then
    _rendererPair.renderer.Clear();
end;

class function TbqTagsRenderer.RenderTagNode(
  canvas: TCanvas;
  nodeData: TVersesNodeData;
  const title: string;
  selected, calcOnly: boolean;
  var rect: TRect): integer;
var
  h, hRectMargin, rectInflateValue: integer;
  flgs: Cardinal;
  tagNodeBorder, tagNodecolor, saveFontColor, savePenColor, saveBrushColor: TColor;
const
  smallMarg = 2;
begin
  result := rect.Top;
  if selected and (not calcOnly) then
  begin
    rectInflateValue := 0;
    hRectMargin := 0;
  end
  else
  begin
    rectInflateValue := -1;
    dec(rect.Bottom, 1);
    dec(result);
    hRectMargin := smallMarg;
  end;
  InflateRect(rect, -hRectMargin, rectInflateValue);

  saveFontColor := canvas.Font.Color;
  savePenColor := canvas.Pen.Color;
  saveBrushColor := canvas.Brush.Color;

  if not calcOnly then
  begin
    canvas.Font.Color := clBlack;

    if selected then
    begin
      tagNodeBorder := $0096C7F3;
      tagNodecolor := $ACD5FF;
    end
    else
    begin
      tagNodecolor := $0D9EAFB;
      tagNodeBorder := $000A98ED;
    end;

    canvas.Brush.Color := tagNodecolor;
    canvas.Pen.Color := tagNodeBorder;
    canvas.RoundRect(rect.Left, rect.Top, rect.Right, rect.Bottom, mCurveRadius, mCurveRadius);
  end;

  InflateRect(rect, -mHmargin, -mVmargin);
  if selected and (not calcOnly) then
  begin
    inc(rect.Top);
    inc(rect.Left, hRectMargin);
  end;

  result := rect.Top - result;
  flgs := DT_WORDBREAK or DT_VCENTER or (ord(calcOnly) * DT_CALCRECT);
  h := Windows.DrawText(canvas.Handle, PChar(Pointer(title)), -1, rect, flgs);
  result := h + result + result;

  if not calcOnly then
  begin
    canvas.Brush.Color := saveBrushColor;
    canvas.Pen.Color := savePenColor;
    canvas.Font.Color := saveFontColor;
  end;
end;

class function TbqTagsRenderer.RenderVerseNode(
  canvas: TCanvas;
  var nodeData: TVersesNodeData;
  calcOnly: boolean;
  var rect: TRect): integer;
var
  usedFont: string;
  txt: string;
  scrollWidth, scrollHeight, curs: integer;
  renderer: TSectionList;
  match: boolean;
begin
  result := 0;
  txt := EffectiveGetVerseNodeText(nodeData, usedFont);
  renderer := GetHTMLRenderer(nodeData.SelfId, match);
  try
    mCurrentRenderer := renderer;

    if calcOnly or (not match) then
    begin
      if not match then
      begin
        renderer.Clear();
        ResetRendererStyles(renderer, usedFont);

        ParseHTMLString(txt, renderer, nil, nil, nil, nil);
      end;

      scrollHeight := renderer.DoLogic(
        canvas, VMargin, rect.Right - rect.Left - HMargin - HMargin,
        rect.Bottom, 0, scrollWidth, curs);

      result := scrollHeight + VMargin;
    end;
    if not calcOnly then
    begin

      mSaveBrush.Assign(canvas.Brush);

      canvas.Brush.Color := clWhite;
      renderer.Draw(canvas, rect, rect.Right - rect.Left, rect.Left + HMargin, 0, 0, 0);
      canvas.Brush.Assign(mSaveBrush);

    end;

  finally
    mCurrentRenderer := nil;
  end;
end;

class procedure TbqTagsRenderer.ResetRendererStyles(renderer: TSectionList; prefFnt: string);

begin
  renderer.Clear();
  if length(prefFnt) <= 0 then
  begin
    prefFnt := mDefaultVerseFont.Name;
  end;
  renderer.SetFonts(prefFnt, prefFnt, mDefaultVerseFont.Size, $0, $5122A3, $0, $0, $00, true, false, 0, 10, 10);

end;

class procedure TbqTagsRenderer.SetHMargin(value: integer);
begin
  mHmargin := value;
  InvalidateRenderers();
end;

class procedure TbqTagsRenderer.SetVMargin(value: integer);
begin
  mVmargin := value;
  InvalidateRenderers();
end;

end.
