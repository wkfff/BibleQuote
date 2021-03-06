unit bible;

// {$LONGSTRINGS ON}

interface

uses
  Windows, Messages, SysUtils, Classes, IOUtils, Types,
  Graphics, Controls, Forms, Dialogs, IOProcs,
  StringProcs, BibleQuoteUtils, LinksParserIntf, WinUIServices;

const
  RusToEngTable: array [1 .. 27] of integer = (1, 2, 3, 4, 5, 20, 21, 22, 23,
    24, 25, 26, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 27);

  EngToRusTable: array [1 .. 27] of integer = (1, 2, 3, 4, 5, 13, 14, 15, 16,
    17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 6, 7, 8, 9, 10, 11, 12, 27);

const

  TSKShortNames: array [1 .. 66] of string = // used to translate TSK references
    ('Ge. Ge Gen. Gen Gn. Gn Genesis', 'Ex. Ex Exo. Exo Exod. Exod Exodus',
    'Lev. Lev Le. Le Lv. Lv Levit. Levit Leviticus',
    'Nu. Nu Num. Num Nm. Nm Numb. Numb Numbers',
    'De. De Deut. Deut Deu. Deu Dt. Dt  Deuteron. Deuteron Deuteronomy',
    'Jos. Jos Josh. Josh Joshua', 'Jdg. Jdg Judg. Judg Judge. Judge Judges',
    'Ru. Ru Ruth Rth. Rth Rt. Rt',
    '1Sa. 1Sa 1S. 1S 1Sam. 1Sam 1Sm. 1Sm 1Sml. 1Sml 1Samuel',
    '2Sa. 2Sa 2S. 2S 2Sam. 2Sam 2Sm. 2Sm 2Sml. 2Sml 2Samuel',
    '1Ki. 1Ki 1K. 1K 1Kn. 1Kn 1Kg. 1Kg 1King. 1King 1Kng. 1Kng 1Kings',
    '2Ki. 2Ki 2K. 2K 2Kn. 2Kn 2Kg. 2Kg 2King. 2King 2Kng. 2Kng 2Kings',
    '1Chr. 1Chr 1Ch. 1Ch 1Chron. 1Chron', '2Chr. 2Chr 2Ch. 2Ch 2Chron. 2Chron',
    'Ezr. Ezr Ezra', 'Ne. Ne Neh. Neh Nehem. Nehem Nehemiah',
    'Esth. Esth Est. Est Esther Es Es.', 'Job. Job Jb. Jb',
    'Ps. Ps Psa. Psa Psal. Psal Psalm Psalms',
    'Pr. Pr Prov. Prov Pro. Pro Proverb Proverbs',
    'Ec. Ec Eccl. Eccl Ecc. Ecc Ecclesia. Ecclesia',
    'Song. Song Songs SS. SS Sol. Sol', 'Isa. Isa Is. Is Isaiah',
    'Je. Je Jer. Jer Jerem. Jerem Jeremiah',
    'La. La Lam. Lam Lament. Lament Lamentation Lamentations',
    'Ez. Ez Eze. Eze Ezek. Ezek Ezekiel', 'Da. Da Dan. Dan Daniel',
    'Hos. Hos Ho. Ho Hosea', 'Joel. Joel Joe. Joe', 'Am. Am Amos Amo. Amo',
    'Ob. Ob Obad. Obad. Obadiah Oba. Oba',
    'Jon. Jon Jnh. Jnh. Jona. Jona Jonah', 'Mi. Mi Mic. Mic Micah',
    'Na. Na Nah. Nah Nahum', 'Hab. Hab Habak. Habak Habakkuk',
    'Zeph. Zeph  Zep. Zep Zephaniah', 'Hag. Hag Haggai',
    'Ze. Ze Zec. Zec Zech. Zech Zechariah', 'Mal. Mal Malachi',
    'Mt. Mt Ma. Ma Matt. Matt Mat. Mat Matthew',
    'Mk. Mk Mar. Mar Mr. Mr Mrk. Mrk Mark', 'Lk. Lk Lu. Lu Luk. Luk Luke',
    'Jn. Jn Jno. Jno Joh. Joh John', 'Ac. Ac Act. Act Acts',
    'Ro. Ro Rom. Rom Romans',
    '1Co. 1Co 1Cor. 1Cor 1Corinth. 1Corinth 1Corinthians',
    '2Co. 2Co 2Cor. 2Cor 2Corinth. 2Corinth 2Corinthians',
    'Ga. Ga Gal. Gal Galat. Galat Galatians',
    'Eph. Eph Ep. Ep Ephes. Ephes Ephesians',
    'Php. Php Ph. Ph Phil. Phil Phi. Phi. Philip. Philip Philippians',
    'Col. Col Colos. Colos Colossians',
    '1Th. 1Th 1Thes. 1Thes 1Thess. 1Thess 1Thessalonians',
    '2Th. 2Th 2Thes. 2Thes 2Thess. 2Thess 2Thessalonians',
    '1Ti. 1Ti 1Tim. 1Tim 1Timothy', '2Ti. 2Ti 2Tim. 2Tim 2Timothy',
    'Tit. Tit Ti. Ti Titus', 'Phm. Phm Phile. Phile Phlm. Phlm Philemon',
    'He. He Heb. Heb Hebr. Hebr Hebrews',
    'Jas. Jas Ja. Ja Jam. Jam Jms. Jms James', '1Pe. 1Pe 1Pet. 1Pet 1Peter',
    '2Pe. 2Pe 2Pet. 2Pet 2Peter',
    '1Jn. 1Jn 1Jo. 1Jo 1Joh. 1Joh 1Jno. 1Jno 1John',
    '2Jn. 2Jn 2Jo. 2Jo 2Joh. 2Joh 2Jno. 2Jno 2John',
    '3Jn. 3Jn 3Jo. 3Jo 3Joh. 3Joh 3Jno. 3Jno 3John', 'Jud. Jud Jude Jd. Jd',
    'Rev. Rev Re. Re Rv. Rv Revelation');

  RussianShortNames: array [1 .. 66] of string =
  // used to translate dictionary references
    ('���. ��� ��. �� ����� Ge. Ge Gen. Gen Gn. Gn Genesis',
    '���. ��� ����� Ex. Ex Exo. Exo Exod. Exod Exodus',
    '���. ��� ��. �� ����� Lev. Lev Le. Le Lv. Lv Levit. Levit Leviticus',
    '���. ��� ��. �� ����. ���� ����� Nu. Nu Num. Num Nm. Nm Numb. Numb Numbers',
    '����. ���� ��. �� �����. ����� ������������ De. De Deut. Deut Deu. Deu Dt. Dt  Deuteron. Deuteron Deuteronomy',
    '���.���. ���.��� ���. ��� ����� ����� Jos. Jos Josh. Josh Joshua',
    '���. ��� ��. �� ����� Jdg. Jdg Judg. Judg Judge. Judge Judges',
    '���. ��� ��. �� ���� Ru. Ru Ruth Rth. Rth Rt. Rt',
    '1���. 1��� 1��. 1�� 1� 1������. 1������ 1Sa. 1Sa 1S. 1S 1Sam. 1Sam 1Sm. 1Sm 1Sml. 1Sml 1Samuel',
    '2���. 2��� 2��. 2�� 2� 2������. 2������ 2Sa. 2Sa 2S. 2S 2Sam. 2Sam 2Sm. 2Sm 2Sml. 2Sml 2Samuel',
    '3���. 3��� 3��. 3�� 3� 3������. 3������ 1Ki. 1Ki 1K. 1K 1Kn. 1Kn 1Kg. 1Kg 1King. 1King 1Kng. 1Kng 1Kings',
    '4���. 4��� 4��. 4�� 4� 4������. 4������ 2Ki. 2Ki 2K. 2K 2Kn. 2Kn 2Kg. 2Kg 2King. 2King 2Kng. 2Kng 2Kings',
    '1���. 1��� 1��. 1�� 1Chr. 1Chr 1Ch. 1Ch 1Chron. 1Chron',
    '2���. 2��� 2��. 2�� 2Chr. 2Chr 2Ch. 2Ch 2Chron. 2Chron',
    '����. ���� ���. ��� ��. �� ����� Ezr. Ezr Ezra',
    '����. ����. ��. �� ������ Ne. Ne Neh. Neh Nehem. Nehem Nehemiah',
    '���. ��� ��. �� ������ Esth. Esth Est. Est Esther',
    '���. ��� ��. �� Job. Job Jb. Jb',
    '��. �� �����. ����� ����. ���� ���. ��� ������ �������� ������ Ps. Ps Psa. Psa Psal. Psal Psalm Psalms',
    '����. ���� �����. ����� ��. �� ������ ������ Pr. Pr Prov. Prov Pro. Pro Proverb Proverbs',
    '����. ���� ��. �� ���. ��� ���������� Ec. Ec Eccl. Eccl Ecc. Ecc Ecclesia. Ecclesia',
    '����. ���� ���. ��� ���. ��� ����.������ ����� Song. Song Songs SS. SS Sol. Sol',
    '��. �� ���. ��� ����� ����� Isa. Isa Is. Is Isaiah',
    '���. ��� �����. ����� ������� Je. Je Jer. Jer Jerem. Jerem Jeremiah',
    '����. ���� ���. ��� ��. �� ��.���. ��.��� ���� ������� La. La Lam. Lam Lament. Lament Lamentation Lamentations',
    '���. ��� ��. �����. ����� ��������� Ez. Ez Eze. Eze Ezek. Ezek Ezekiel',
    '���. ��� ��. �� ���. ��� ������ Da. Da Dan. Dan Daniel',
    '��. �� ���� Hos. Hos Ho. Ho Hosea',
    '����. ���� ��. �� ����� Joel. Joel Joe. Joe',
    '��. �� ���. ��� ���� Am. Am Amos Amo. Amo',
    '���. ��� ����� Ob. Ob Obad. Obad. Obadiah Oba. Oba',
    '���. ���. ���� Jon. Jon Jnh. Jnh. Jona. Jona Jonah',
    '���. ��� ��. �� ����� Mi. Mi Mic. Mic Micah',
    '����. ���� Na. Na Nah. Nah Nahum',
    '���. ��� �����. ����� ������� Hab. Hab Habak. Habak Habakkuk',
    '���. ��� �����. ����� ������� Zeph. Zeph  Zep. Zep Zephaniah',
    '���. ��� ����� Hag. Hag Haggai',
    '���. ��� ���. ��� �����. ����� ������� Ze. Ze Zec. Zec Zech. Zech Zechariah',
    '���. ��� �����. ����� ���. ��� ������� Mal. Mal Malachi',
    '����. ���� ���. ��� ��. �� ��. �� ������ ������ ��� ���. Mt. Mt Ma. Ma Matt. Matt Mat. Mat Matthew',
    '���. ��� ����. ���� ���. ��� ��. �� ����� �� ��. Mk. Mk Mar. Mar Mr. Mr Mrk. Mrk Mark',
    '���. ��� ��. �� ���a ���� Lk. Lk Lu. Lu Luk. Luk Luke',
    '����. ���� ��. �� ����� ������ Jn. Jn Jno. Jno Joh. Joh John',
    '����. ���� ���. ��� �.�. ������ Ac. Ac Act. Act Acts',
    '���. ��� ��. �� ����� ������ Jas. Jas Ja. Ja Jam. Jam Jms. Jms James',
    '1���. 1��� 1��. 1�� 1���. 1��� 1����. 1���� 1����� 1Pe. 1Pe 1Pet. 1Pet 1Peter',
    '2���. 2��� 2��. 2�� 2���. 2��� 2����. 2���� 2����� 2Pe. 2Pe 2Pet. 2Pet 2Peter',
    '1����. 1���� 1��. 1�� 1����� 1������ 1Jn. 1Jn 1Jo. 1Jo 1Joh. 1Joh 1Jno. 1Jno 1John',
    '2����. 2���� 2��. 2�� 2����� 2������ 2Jn. 2Jn 2Jo. 2Jo 2Joh. 2Joh 2Jno. 2Jno 2John',
    '3����. 3���� 3��. 3�� 3����� 3������ 3Jn. 3Jn 3Jo. 3Jo 3Joh. 3Joh 3Jno. 3Jno 3John',
    '���. ��� ��. �� ���� ���� Jud. Jud Jude Jd. Jd',
    '���. ��� ����. ���� �������� Ro. Ro Rom. Rom Romans',
    '1���. 1��� 1������. 1������ 1���������� 1���������� 1Co. 1Co 1Cor. 1Cor 1Corinth. 1Corinth 1Corinthians',
    '2���. 2��� 2������. 2������ 2���������� 2���������� 2Co. 2Co 2Cor. 2Cor 2Corinth. 2Corinth 2Corinthians',
    '���. ��� �����. ����� ������� Ga. Ga Gal. Gal Galat. Galat Galatians',
    '��. �� ����. ���� �������� Eph. Eph Ep. Ep Ephes. Ephes Ephesians',
    '���. ��� ���. ��� �����. ����� ����������� Php. Php Ph. Ph Phil. Phil Phi. Phi. Philip. Philip Philippians',
    '���. ��� �����. ����� ���������� Col. Col Colos. Colos Colossians',
    '1����. 1���� 1���. 1��� 1��������������� 1���. 1��� 1��������� 1Th. 1Th 1Thes. 1Thes 1Thess. 1Thess 1Thessalonians',
    '2����. 2���� 2���. 2��� 2��������������� 2���. 2��� 2��������� 2Th. 2Th 2Thes. 2Thes 2Thess. 2Thess 2Thessalonians',
    '1���. 1���  1�����. 1����� 1������� 1Ti. 1Ti 1Tim. 1Tim 1Timothy',
    '2���. 2��� 2�����. 2����� 2������� 2Ti. 2Ti 2Tim. 2Tim 2Timothy',
    '���. ��� ���� Tit. Tit Ti. Ti Titus',
    '���. ��� �������. ������� �������� Phm. Phm Phile. Phile Phlm. Phlm Philemon',
    '���. ��� ������ He. He Heb. Heb Hebr. Hebr Hebrews',
    '����. ���� ���. ��� ��������. �������� ����. ���� ���������� ����������� Rev. Rev Re. Re Rv. Rv Revelation');

const
  MAX_BOOKQTY = 256;

  C_TotalPsalms = 150;

  // search params bits
  spWordParts = $01;
  spContainAll = $02;
  spFreeOrder = $04;
  spAnyCase = $08;
  spExactPhrase = $10;

type
  TBibleSet = set of 0 .. 255;

type
  TBible = class;
  TBibleSearchEvent = procedure(
    Sender: TObject;
    NumVersesFound, book, chapter, verse: integer;
    s: string;
    removeStrongs: boolean) of object;

  TBiblePasswordRequired = procedure(
    aSender: TBible;
    out outPassword: string) of object;

  TModuleLocation = record
    bookIx, ChapterIx, VerseStartIx, VerseEndIx: integer;
  end;

  TbqModuleStateEntries = (bqmsFontsInstallPending);
  TbqModuleState = set of TbqModuleStateEntries;
  TbqModuleType = (bqmBible, bqmCommentary, bqmBook);
  TbqModuleTrait = (
    bqmtOldCovenant,
    bqmtNewCovenant,
    bqmtApocrypha,
    bqmtEnglishPsalms,
    bqmtStrongs,
    bqmtIncludeChapterHead,
    bqmtZeroChapter,
    bqmtNoForcedLineBreaks);

  TbqModuleTraits = set of TbqModuleTrait;

  TBible = class
  private
    { Private declarations }
    FIniFile: string;
    FPath: string;
    FShortPath: string;
    FName: string; // full description (title) of the module
    FShortName: string; // short abbreviation, like NIV, KJV
    FCopyright: string; // short copyright notice; full page should be in copyright.html

    FBible: boolean; // is this a Bible translation?
    FBookQty: integer; // quantity of books in module (default = 66)
    FChapterSign: string; // the beginning of a chapter
    FVerseSign: string; // the beginning of a verse

    FDefaultEncoding: TEncoding;
    // Default 8-bit encoding for all book files of TBible.
    FDesiredFontCharset: integer;
    FUseRightAlignment: boolean;

    FFontName: string;
    FAlphabet: string; // ALL letters that can be parts of text in the module

    FSoundDir: string;
    FStrongsDir: string;
    FStrongsPrefixed: boolean; // Gxxxx and Hxxx numbers or not?

    FModuleName: string;
    FModuleAuthor: string;
    FModuleCompiler: string;
    FModuleVersion: string;
    FModuleImage: string;

    FHTML: string; // allowed HTML codes
    FFiltered: boolean;
    FDefaultFilter: boolean; // using default filter

    FLines: TStrings; // these are verses when you open a chapter

    BookLines: TStrings; // just a buffer

    FBook, FChapter, FVerseQty: integer;
    FRememberPlace: boolean;

    FChapterString, FChapterStringPs, FChapterZeroString: string;

    FVersesFound: integer; // run-time counter of words found during search
    FOnVerseFound: TBibleSearchEvent;
    FOnSearchComplete: TNotifyEvent;
    FStopSearching: boolean;

    FOnChangeModule: TNotifyEvent;

    FOnPasswordRequired: TBiblePasswordRequired;

    AlphabetArray: array [0 .. 2047] of Cardinal;
    mModuleState: TbqModuleState;
    mTraits: TbqModuleTraits;
    mCategories: TStringList;
    mChapterHead: string;
    mInstallFontNames: string;
    mDesiredUIFont: string;
    mUIServices: IBibleWinUIServices;
    procedure ClearAlphabetBits();
    procedure SetAlphabetBit(aCode: integer; aValue: boolean);
    function GetAlphabetBit(aCode: integer): boolean;

  protected
    mRecognizeBibleLinks: boolean;
    mFuzzyResolveLinks: boolean;
    mShortNamesVars: TStringList;
    mModuleType: TbqModuleType;

    procedure LoadIniFile(fileName: string);

    function SearchOK(source: string; words: TStrings; params: byte): boolean;
    procedure SearchBook(words: TStrings; params: byte; book: integer; removeStrongs: boolean);
    procedure SetHTMLFilter(value: string);

    function toInternal(
      const bl: TBibleLink;
      out obl: TBibleLink;
      englishbible: boolean = False;
      EnglishPsalms: boolean = False): boolean;

    function GetShortNameVars(bookIx: integer): string;
    procedure SetShortNameVars(bookIx: integer; const Name: string);
    procedure InstallFonts();
    function GetVerse(i: Cardinal): string;
    function getTraitState(trait: TbqModuleTrait): boolean;
    procedure setTraitState(trait: TbqModuleTrait; state: boolean);

  public
    ChapterQtys: array [1 .. MAX_BOOKQTY] of integer;
    FullNames: array [1 .. MAX_BOOKQTY] of string;

    // variants for shortening the title of the book
    ShortNames: array [1 .. MAX_BOOKQTY] of string;

    PathNames: array [1 .. MAX_BOOKQTY] of string;
    function GetStucture(): string;
    function GetDefaultEncoding(): TEncoding;
    function ChapterCountForBook(bk: integer; internalAddr: boolean): integer;
    function GetModuleName(): string;
    function GetAuthor(): string;

    function LinkValidnessStatus(
      path: string;
      bl: TBibleLink;
      internalAddr: boolean = true;
      checkverse: boolean = true): integer;

    function SyncToBible(const refBible: TBible; const bl: TBibleLink; out outBibleLink): integer;
    function IsCommentary(): boolean;
    property IniFile: string read FIniFile write LoadIniFile;
    property path: string read FPath;
    property ShortPath: string read FShortPath;
    property Name: string read GetModuleName;
    property ShortName: string read FShortName;
    property Categories: TStringList read mCategories;
    property ChapterString: string read FChapterString;
    property ChapterStringPs: string read FChapterStringPs;
    property ChapterZeroString: string read FChapterZeroString;

    // new attributes
    property ModuleName: string read FModuleName;
    property Author: string read GetAuthor;
    property ModuleVersion: string read FModuleVersion;
    property ModuleCompiler: string read FModuleCompiler;
    property ModuleImage: string read FModuleImage;

    property ShortNamesVars[ix: integer]: string read GetShortNameVars;
    property Copyright: string read FCopyright;

    property isBible: boolean read FBible;
    property ModuleType: TbqModuleType read mModuleType;

    property BookQty: integer read FBookQty;
    property ChapterSign: string read FChapterSign;
    property VerseSign: string read FVerseSign;

    property DefaultEncoding: TEncoding read GetDefaultEncoding;
    property DesiredCharset: integer read FDesiredFontCharset;
    property DesiredUIFont: string read mDesiredUIFont;
    property UseRightAlignment: boolean read FUseRightAlignment;

    property Alphabet: string read FAlphabet;
    property FontName: string read FFontName;

    property CurBook: integer read FBook;
    property CurChapter: integer read FChapter;
    property VerseQty: integer read FVerseQty write FVerseQty;
    property ChapterHead: string read mChapterHead;

    property RememberPlace: boolean read FRememberPlace write FRememberPlace;

    property Verses[i: Cardinal]: string read GetVerse; default;

    property SoundDirectory: string read FSoundDir;
    property StrongsDirectory: string read FStrongsDir;
    property StrongsPrefixed: boolean read FStrongsPrefixed;

    constructor Create(uiServices: IBibleWinUIServices); reintroduce;
    destructor Destroy; override;

    function OpenChapter(book, chapter: integer;
      forceResolveLinks: boolean = False): boolean;

    function OpenReference(s: string; var book, chapter, fromverse, toverse: integer): boolean;
    function OpenTSKReference(s: string; var book, chapter, fromverse, toverse: integer): boolean;
    function OpenRussianReference(s: string; var book, chapter, fromverse, toverse: integer): boolean;

    procedure Search(s: string; params: byte; bookset: TBibleSet; removeStrongs: boolean);
    procedure StopSearching;

    procedure ClearBuffers;

    function ReferenceToInternal(
      book, chapter, verse: integer;
      var ibook, ichapter, iverse: integer;
      checkShortNames: boolean = true): boolean; overload;

    function ReferenceToInternal(
      const moduleRelatedRef: TBibleLink;
      out independent: TBibleLink): integer; overload;

    function InternalToReference(
      ibook, ichapter, iverse: integer;
      var book, chapter, verse: integer;
      checkShortNames: boolean = true) : boolean; overload;

    function InternalToReference(inputLnk: TBibleLink; out outLink: TBibleLink): integer; overload;
    function ShortPassageSignature(book, chapter, fromverse, toverse: integer): string;
    function FullPassageSignature(book, chapter, fromverse, toverse: integer): string;

    function CountVerses(book, chapter: integer): integer;

    function isEnglish: boolean;

    procedure ENG2RUS(book, chapter, verse: integer; var rbook, rchapter, rverse: integer);
    procedure RUS2ENG(book, chapter, verse: integer; var ebook, echapter, everse: integer);

    function ReferenceToEnglish(
      book, chapter, verse: integer;
      var ebook, echapter, everse: integer;
      checkShortNames: boolean = true): boolean;

    function EnglishToReference(
      ebook, echapter, everse: integer;
      var book, chapter, verse: integer): boolean;

    procedure _InternalSetContext(book, chapter: integer);
    procedure SetHTMLFilterX(value: string; forceUserFilter: boolean);
    function VerseCount(): integer;
    property Traits: TbqModuleTraits read mTraits;
    property trait[index: TbqModuleTrait]: boolean read getTraitState;

  published
    property Filtered: boolean read FFiltered write FFiltered;
    property HTMLFilter: string read FHTML write SetHTMLFilter;
    property VersesFound: integer read FVersesFound;

    property OnVerseFound: TBibleSearchEvent read FOnVerseFound write FOnVerseFound;
    property OnSearchComplete: TNotifyEvent read FOnSearchComplete write FOnSearchComplete;
    property OnChangeModule: TNotifyEvent read FOnChangeModule write FOnChangeModule;
    property OnPasswordRequired: TBiblePasswordRequired read FOnPasswordRequired write FOnPasswordRequired;
    property RecognizeBibleLinks: boolean read mRecognizeBibleLinks write mRecognizeBibleLinks;
    property FuzzyResolve: boolean read mFuzzyResolveLinks write mFuzzyResolveLinks;

  end;

implementation

uses PlainUtils, bibleLinkParser, ExceptionFrm;

function Diff(a, b: integer): integer;
begin
  if a < b then
    Result := b - a
  else
    Result := a - b;
end;

constructor TBible.Create(uiServices: IBibleWinUIServices);
begin
  FLines := TStringList.Create;
  BookLines := TStringList.Create;
  mCategories := TStringList.Create();
  mShortNamesVars := TStringList.Create();
  mUIServices := uiServices;
end;

destructor TBible.Destroy;
begin
  BookLines.Free;
  FLines.Free;
  mCategories.Free();
  mShortNamesVars.Free();
  inherited Destroy;
end;

function TBible.ReferenceToInternal(const moduleRelatedRef: TBibleLink; out independent: TBibleLink): integer;
begin
  moduleRelatedRef.AssignTo(independent);
  Result := ord(ReferenceToInternal(
    moduleRelatedRef.book,
    moduleRelatedRef.chapter,
    moduleRelatedRef.vstart,
    independent.book,
    independent.chapter, independent.vstart)) - 1;

  if Result < 0 then
  begin
    Result := -2;
    exit;
  end;
  Inc(Result, ord(ReferenceToInternal(
    moduleRelatedRef.book,
    moduleRelatedRef.chapter,
    moduleRelatedRef.vend,
    independent.book,
    independent.chapter,
    independent.vend)) - 1);
end;

function TBible.ChapterCountForBook(bk: integer; internalAddr: boolean)
  : integer;
var
  obk, och, ovs: integer;
begin
  if internalAddr then
  begin
    if not InternalToReference(bk, 1, 1, obk, och, ovs) then
    begin
      Result := -1;
      exit;
    end;
  end
  else
    obk := bk;
  if obk > BookQty then
    Result := -1
  else
  begin
    Result := ChapterQtys[obk];
  end;
end;

procedure TBible.ClearAlphabetBits();
var
  i: integer;
begin
  for i := 0 to 2047 do
    AlphabetArray[i] := 0;
end;

procedure TBible.SetAlphabetBit(aCode: integer; aValue: boolean);
var
  dIndex: integer;
  dMask: Cardinal;
begin
  dIndex := aCode div 32;
  if (dIndex > 2047) or (dIndex < 0) then
    exit;

  dMask := 1 shl (aCode mod 32);

  if aValue then
    AlphabetArray[dIndex] := AlphabetArray[dIndex] or dMask
  else
    AlphabetArray[dIndex] := AlphabetArray[dIndex] and not dMask;

end;

function TBible.GetAlphabetBit(aCode: integer): boolean;
var
  dIndex: integer;
  dMask: Cardinal;
begin
  Result := False;

  dIndex := aCode div 32;
  if (dIndex > 2047) or (dIndex < 0) then
    exit;

  dMask := 1 shl (aCode mod 32);

  Result := (AlphabetArray[dIndex] and dMask) <> 0;

end;
{$J+}

var
  bookNames: TStringList = nil;
{$J-}

function TBible.GetShortNameVars(bookIx: integer): string;
begin
  dec(bookIx);
  if (bookIx < 0) or (bookIx >= mShortNamesVars.Count) then
    raise ERangeError.CreateFmt
      ('Invalid request of shortNames property, invalid index=%d not in [1 - %d]',
      [bookIx + 1, 0, mShortNamesVars.Count]);

  Result := mShortNamesVars[bookIx];

end;

function TBible.GetModuleName: string;
begin
  if (FModuleName <> '') then
    Result := FModuleName
  else
    Result := FName;
end;

function TBible.GetAuthor: string;
begin
  if (FModuleAuthor <> '') then
    Result := FModuleAuthor
  else
    Result := FCopyright;
end;

function TBible.GetStucture: string;
var
  bookIx, bookCnt: integer;
  s: string;

begin
  bookCnt := FBookQty;
  if not assigned(bookNames) then
    bookNames := TStringList.Create()
  else
    bookNames.Clear();
  if FBible and not(bqmtOldCovenant in mTraits) then
  begin
    for bookIx := 1 to 66 do
      bookNames.Add('0');
  end;

  for bookIx := 1 to bookCnt do
  begin
    if not FBible then
    begin
      s := FullNames[bookIx];
      bookNames.Add(s);
    end
    else
      bookNames.Add(inttoStr(ord(Copy(FullNames[bookIx], 1, 5) <> '-----')));
  end;
  Result := StringReplace(bookNames.Text, #$D#$A, '|', [rfReplaceAll]);
end;

function TBible.GetDefaultEncoding(): TEncoding;
begin
  if assigned(FDefaultEncoding) then
    Result := FDefaultEncoding
  else
    Result := TEncoding.GetEncoding(1251);
end;

function TBible.getTraitState(trait: TbqModuleTrait): boolean;
begin
  Result := trait in mTraits;
end;

function TBible.GetVerse(i: Cardinal): string;
begin
  if (i >= FLines.Count) then
  begin
    g_ExceptionContext.Add(Format('i=%d', [i]));
    raise ERangeError.Create('Invalid verse Number');
  end;
  Result := FLines[i];
end;

procedure TBible.SetHTMLFilter(value: string);
begin
  FHTML := DefaultHTMLFilter + value;
  FDefaultFilter := False;
end;

procedure TBible.SetHTMLFilterX(value: string; forceUserFilter: boolean);
begin
  if forceUserFilter then
    FHTML := value
  else
    FHTML := DefaultHTMLFilter + value;
  FDefaultFilter := False;
end;

procedure TBible.SetShortNameVars(bookIx: integer; const Name: string);
var
  i, countDiff: integer;
begin
  dec(bookIx);
  countDiff := bookIx - mShortNamesVars.Count - 1;
  if (bookIx < 0) or (countDiff > 255) then
    raise ERangeError.CreateFmt
      ('invalid attempt to set ShortNames property, index =%d', [bookIx + 1]);

  for i := 0 to countDiff do
    mShortNamesVars.Add(''); // fill not used
  if countDiff = -1 then
    mShortNamesVars.Add(name)
  else
    mShortNamesVars[bookIx] := name;

end;

procedure TBible.setTraitState(trait: TbqModuleTrait; state: boolean);
begin
  if state then
    Include(mTraits, trait)
  else
    Exclude(mTraits, trait);
end;

procedure TBible.LoadIniFile(fileName: string);
var
  s: TStrings;
  i, cur: integer;
  dFirstPart: string;
  dSecondPart: string;
  isCompressed: boolean;

  function ToBoolean(aValue: string): boolean;
  begin
    Result := (aValue = 'Y') or (aValue = 'y');
  end;

begin
  try
    s := nil;

    try
      FDefaultEncoding := LoadBibleqtIniFileEncoding(fileName, TEncoding.GetEncoding(1251));
      s := ReadTextFileLines(fileName, DefaultEncoding);

    except
      on ex: TBQException do
      begin
        s.Free();

        raise;
      end;
      on Exception do
      begin
        s.Free();
        g_ExceptionContext.Add('TBible.LoadIniFile.value=' + fileName);
        raise Exception.CreateFmt('TBible.LoadIniFile: Error loading file %s', [fileName]);
      end;

    end;
    isCompressed := fileName[1] = '?';
    mModuleType := bqmBook;
    mModuleState := [];
    FBookQty := 0;
    FBook := 1;
    FChapter := 1;
    FDesiredFontCharset := -1;
    FName := '';
    FShortName := '';
    FCopyright := '';
    FModuleName := '';
    FModuleAuthor := '';
    FModuleCompiler := '';
    FModuleVersion := '';
    FModuleImage := '';

    mCategories.Clear();
    FFiltered := true;
    FHTML := DefaultHTMLFilter;
    FDefaultFilter := true;
    FUseRightAlignment := False;

    FAlphabet :=
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' +
      '�����Ũ����������������������������������������������������������';

    FFontName := '';
    FStopSearching := False;

    FRememberPlace := true;

    FSoundDir := '';
    FStrongsDir := '';
    FStrongsPrefixed := False;

    FBible := true;
    mTraits := [bqmtOldCovenant, bqmtNewCovenant];
    mDesiredUIFont := '';
    mInstallFontNames := '';

    for i := 1 to MAX_BOOKQTY do
      ChapterQtys[i] := 0; // clear

    cur := -1;
    i := 0;

    repeat
      Inc(cur);
      if cur = s.Count then
        break;

      dFirstPart := IniStringFirstPart(s[cur]);
      dSecondPart := IniStringSecondPart(s[cur]);

      if dSecondPart = '' then
        continue;

      if dFirstPart = 'BibleName' then
      begin
        FName := dSecondPart;
      end
      else if dFirstPart = 'BibleShortName' then
      begin
        FShortName := dSecondPart;
      end
      else if dFirstPart = 'Copyright' then
      begin
        FCopyright := dSecondPart;
      end
      else if dFirstPart = 'Bible' then
      begin
        FBible := ToBoolean(dSecondPart);
      end
      else if dFirstPart = 'OldTestament' then
      begin
        setTraitState(bqmtOldCovenant, ToBoolean(dSecondPart));
      end
      else if dFirstPart = 'NewTestament' then
      begin
        setTraitState(bqmtNewCovenant, ToBoolean(dSecondPart));
      end
      else if dFirstPart = 'Apocrypha' then
      begin
        setTraitState(bqmtApocrypha, ToBoolean(dSecondPart));
      end
      else if dFirstPart = 'ChapterZero' then
      begin
        setTraitState(bqmtZeroChapter, ToBoolean(dSecondPart));
      end
      else if dFirstPart = 'ChapterString' then
      begin
        FChapterString := dSecondPart;
      end
      else if dFirstPart = 'ChapterStringPs' then
      begin
        FChapterStringPs := dSecondPart;
      end
      else if dFirstPart = 'ChapterZeroString' then
      begin
        FChapterZeroString := dSecondPart;
      end
      else if dFirstPart = 'EnglishPsalms' then
      begin
        setTraitState(bqmtEnglishPsalms, ToBoolean(dSecondPart));
      end
      else if dFirstPart = 'StrongNumbers' then
      begin
        setTraitState(bqmtStrongs, ToBoolean(dSecondPart));
      end
      else if dFirstPart = 'NoForcedLineBreaks' then
      begin
        setTraitState(bqmtNoForcedLineBreaks, ToBoolean(dSecondPart));
      end
      else if dFirstPart = 'HTMLFilter' then
      begin
        HTMLFilter := dSecondPart;
      end
      else if dFirstPart = 'Alphabet' then
      begin
        FAlphabet := dSecondPart;
      end
      else if dFirstPart = 'InstallFonts' then
      begin
        mInstallFontNames := dSecondPart;
        Include(mModuleState, bqmsFontsInstallPending);
      end
      else if dFirstPart = 'DesiredUIFont' then
      begin
        mDesiredUIFont := dSecondPart;
      end
      else if dFirstPart = 'DesiredFontName' then
      begin
        FFontName := dSecondPart;
      end
      else if dFirstPart = 'Categories' then
      begin
        StrToTokens(dSecondPart, '|', mCategories);
      end
      else if dFirstPart = 'DesiredFontCharset' then
      begin
        FDesiredFontCharset := StrToInt(dSecondPart); // AlekId
      end
      else if dFirstPart = 'UseRightAlignment' then
      begin
        FUseRightAlignment := ToBoolean(dSecondPart)
      end
      else if dFirstPart = 'UseChapterHead' then
      begin
        setTraitState(bqmtIncludeChapterHead, ToBoolean(dSecondPart));
      end
      else if dFirstPart = 'ChapterSign' then
      begin
        FChapterSign := dSecondPart;
      end
      else if dFirstPart = 'VerseSign' then
      begin
        FVerseSign := dSecondPart;
      end
      else if dFirstPart = 'BookQty' then
      begin
        FBookQty := StrToInt(dSecondPart);
      end
      else if dFirstPart = 'SoundDirectory' then
      begin
        FSoundDir := dSecondPart;
      end
      else if dFirstPart = 'StrongsDirectory' then
      begin
        FStrongsDir := dSecondPart;
      end
      else if dFirstPart = 'StrongsPrefixed' then
      begin
        FStrongsPrefixed := ToBoolean(dSecondPart);
      end
      else if dFirstPart = 'PathName' then
      begin
        Inc(i);
        PathNames[i] := dSecondPart;
      end
      else if dFirstPart = 'FullName' then
      begin
        FullNames[i] := dSecondPart;
      end
      else if dFirstPart = 'ShortName' then
      begin
        SetShortNameVars(i, dSecondPart);
      end
      else if dFirstPart = 'ModuleName' then
      begin
        FModuleName := dSecondPart;
      end
      else if dFirstPart = 'ModuleAuthor' then
      begin
        FModuleAuthor := dSecondPart;
      end
      else if dFirstPart = 'ModuleVersion' then
      begin
        FModuleVersion := dSecondPart;
      end
      else if dFirstPart = 'ModuleCompiler' then
      begin
        FModuleCompiler := dSecondPart;
      end
      else if dFirstPart = 'ModuleImage' then
      begin
        FModuleImage := dSecondPart;
      end
      else
      begin
        if i <= 0 then
          continue;
        ShortNames[i] := FirstWord(ShortNamesVars[i]);
        if dFirstPart = 'ChapterQty' then
        begin
          ChapterQtys[i] := StrToInt(dSecondPart);
          continue;
        end;

      end;

    until False;

    FIniFile := fileName;

    if isCompressed then
    begin
      FPath := GetArchiveFromSpecial(fileName) + '??';
      FShortPath := ExtractRelativePath('?' + ExePath, FPath);
      FShortPath := GetArchiveFromSpecial(FShortPath);
      FShortPath := Copy(FShortPath, 1, length(FShortPath) - 4);
    end
    else
    begin
      FPath := ExtractFilePath(fileName);
      FShortPath := ExtractRelativePath(ExePath, FPath);
      FShortPath := ExcludeTrailingPathDelimiter(FShortPath);
    end;

    FAlphabet := FAlphabet + '0123456789';

    ClearAlphabetBits;

    for i := 1 to length(FAlphabet) do
      SetAlphabetBit(integer(FAlphabet[i]), true);

    if Self.FBible then
    begin
      if IsCommentary() then
        mModuleType := bqmCommentary
      else
        mModuleType := bqmBible;

      if trait[bqmtOldCovenant] then
        mCategories.Add(Lang.SayDefault('catOT', 'Old Covenant'));

      if trait[bqmtNewCovenant] then
        mCategories.Add(Lang.SayDefault('catNT', 'New Covenant'));

      if trait[bqmtApocrypha] then
        mCategories.Add(Lang.SayDefault('catApocrypha', 'Apocrypha'));
    end
    else
    begin // not bible
      Exclude(mTraits, bqmtOldCovenant);
      Exclude(mTraits, bqmtNewCovenant);
      Exclude(mTraits, bqmtApocrypha);
    end;
    if assigned(FOnChangeModule) then
      FOnChangeModule(Self);
  except
    g_ExceptionContext.Add('TBible.LoadIniFile.value=' + fileName);
    raise;
  end;
end;

function TBible.OpenChapter(
  book, chapter: integer;
  forceResolveLinks: boolean = False): boolean;
var
  j, k, ichapter: integer;
  foundchapter: boolean;
  recLnks: boolean;
begin

  FLines.Clear;
  if bqmsFontsInstallPending in mModuleState then
    InstallFonts();

  mChapterHead := '';
  if (book <= 0) or (book > BookQty) or (chapter <= 0) or
    (chapter > ChapterQtys[book]) then
  begin
    Result := False;
    exit;
  end;
  ReadHtmlTo(FPath + PathNames[book], BookLines, DefaultEncoding);

  ichapter := 0;

  j := -1;

  repeat
    Inc(j);
    if Pos(FChapterSign, BookLines[j]) > 0 then
      Inc(ichapter);
  until (j = BookLines.Count - 1) or (ichapter = chapter);

  foundchapter := (ichapter = chapter);

  if ichapter = chapter then
  begin
    if foundchapter then
      k := j + 1
    else
      k := j;

    for j := k to BookLines.Count - 1 do
    begin
      if Pos(FChapterSign, BookLines[j]) > 0 then
        break;

      if Pos(FVerseSign, BookLines[j]) > 0 then
      begin
        FLines.Add(BookLines[j]); // add newly found verse of this chapter
      end
      else if FLines.Count > 0 then
        FLines[FLines.Count - 1] := FLines[FLines.Count - 1] + ' ' +
          BookLines[j]
      else if trait[bqmtIncludeChapterHead] then
        mChapterHead := mChapterHead + BookLines[j];
      // add to current verse (paragraph)
    end;

    FBook := book;
    FChapter := chapter;
  end;

  if FFiltered and (FLines.Count <> 0) then
    FLines.Text := ParseHTML(FLines.Text, FHTML);
  recLnks := (not FBible) or (IsCommentary());
  if forceResolveLinks or (recLnks and mRecognizeBibleLinks) then
  begin
    FLines.Text := ResolveLinks(FLines.Text, mFuzzyResolveLinks);
  end;

  if FFiltered and trait[bqmtIncludeChapterHead] then
    mChapterHead := ParseHTML(mChapterHead, FHTML);
  FVerseQty := FLines.Count;

  if FLines.Count = 0 then
    raise Exception.CreateFmt(
      'TBible.OpenChapter: Passage not found.' + #13#10
      + #13#10 + 'IniFile = %s' + #13#10 + 'Book=%d Chapter=%d',
      [FIniFile, book, chapter]);

  Result := true;
end;

function TBible.SearchOK(source: string; words: TStrings; params: byte): boolean;
var
  i, lastpos, curpos: integer;
  res, stopKeyword, sr: boolean;
  src, wrd: string;
begin
  res := true;

  src := source;

  if (params and spWordParts <> spWordParts) then
  begin
    for i := 1 to length(src) do
      if not GetAlphabetBit(integer(src[i])) then
        src[i] := ' ';

    if FBible then
    begin
      src := Trim(src);
      StrDeleteFirstNumber(src);
    end;

    src := ' ' + src + ' ';
  end;

  if (params and spAnyCase = spAnyCase) then
    src := LowerCase(src);

  if not(params and spContainAll = spContainAll) then
  begin
    res := False;

    for i := 0 to words.Count - 1 do
    begin
      wrd := words[i];
      stopKeyword := ((wrd[1] = '-') or ((length(wrd) > 1) and (wrd[1] = ' ')
        and (wrd[2] = '-')) { second } );
      if stopKeyword then
        if (params and $F0 > 0) then
          continue // just skip as nothing
        else
        begin
          if wrd[1] = '-' then
            wrd := Copy(wrd, 2, 1024)
          else
            wrd := Copy(wrd, 3, 1024);
          words.objects[i] := TObject(-1);
        end;
      if (params and spAnyCase = spAnyCase) then
        wrd := LowerCase(wrd);
      sr := (Pos(wrd, src) > 0);
      if stopKeyword and sr then
      begin
        res := False;
        break;
      end;

      res := res or sr;
    end;

    Result := res;
    exit;
  end;

  i := 0;
  lastpos := 0;

  repeat
    wrd := words[i];
    stopKeyword := ((wrd[1] = '-') or ((length(wrd) > 1) and (wrd[1] = ' ') and
      (wrd[2] = '-')) { second } );
    if stopKeyword then
    begin

      if (params and $F0 > 0) then
      begin
        Inc(i);
        continue;
      end
      else
      begin
        if wrd[1] = '-' then
          wrd := Copy(wrd, 2, 1024)
        else
          wrd := Copy(wrd, 3, 1024);

      end;
    end;

    if (params and spAnyCase = spAnyCase) then
      wrd := LowerCase(wrd);

    curpos := Pos(wrd, src);
    sr := (curpos > 0) xor stopKeyword;

    res := res and sr;
    if not res then
      break;

    if not stopKeyword and not(params and spFreeOrder = spFreeOrder) then
    begin
      if curpos < lastpos then
      begin
        res := False;
        break;
      end
      else
        lastpos := curpos;
    end;
    words.objects[i] := TObject(curpos);
    Inc(i);
  until (not res) or (i = words.Count);

  Result := res;
end;

function compareKeyWords(List: TStringList; Index1, Index2: integer): integer;
begin
  Result := integer(List.objects[Index1]) - integer(List.objects[Index2]);
end;

procedure TBible.SearchBook(words: TStrings; params: byte; book: integer; removeStrongs: boolean);
var
  i, chapter, verse: integer;
  btmp, tmpwords: TStringList; // lines buffer from the book
  s, snew: string;
  newparams: byte;
begin
  chapter := 0;
  verse := 0;

  tmpwords := TStringList.Create;

  {
    first, we're search in the book as a whole string,
    so parameters like exact phrase or word order should be omitted

    they will be used later on a verse basis
  }

  if (params and spExactPhrase = spExactPhrase) and trait[bqmtStrongs] then
  begin
    newparams := params - spExactPhrase + spWordParts;
    // we're filter results for exact phrases later...
    // in books with Strong's numbers we first search for non-exact phrase
    s := Trim(words[0]);
    while s <> '' do
    begin
      snew := DeleteFirstWord(s);
      tmpwords.Add(snew);
    end;
  end
  else
  begin
    if not(params and spFreeOrder = spFreeOrder) then
      newparams := params + spFreeOrder
    else
      newparams := params;

    tmpwords.AddStrings(words);
  end;

  ReadHtmlTo(FPath + PathNames[book], BookLines, DefaultEncoding);

  // if the whole book doesn't have matches, just skip it
  if not SearchOK(BookLines.Text, tmpwords, newparams or $F0) then
    exit;

  if not(params and spFreeOrder = spFreeOrder) then
    newparams := newparams - spFreeOrder;

  // reformat BookLines to complete VERSES, because verses can go in several lines
  btmp := TStringList.Create;

  s := '';

  for i := 0 to BookLines.Count - 1 do
  begin
    if (Pos(FChapterSign, BookLines[i]) > 0) or
      (Pos(FVerseSign, BookLines[i]) > 0) then
    begin
      btmp.Add(s);
      s := BookLines[i];
    end
    else
      s := s + ' ' + BookLines[i]; // concatenate paragraphs
  end;

  btmp.Add(s);

  BookLines.Clear;
  BookLines.AddStrings(btmp);

  // reformat finished

  for i := 0 to BookLines.Count - 1 do
  begin
    if FStopSearching then
      break;

    if Pos(FChapterSign, BookLines[i]) <> 0 then
    begin
      Inc(chapter);
      verse := 0;
      continue;
    end;

    if Pos(FVerseSign, BookLines[i]) <> 0 then
    begin
      Inc(verse);

      if SearchOK(BookLines[i], tmpwords, newparams) and (chapter > 0) then
      begin
        if ((params and spExactPhrase = spExactPhrase) and trait[bqmtStrongs])
          and (not SearchOK(DeleteStrongNumbers(BookLines[i]), words, params))
        then
          continue; // filter for exact phrases

        Inc(FVersesFound);
        if assigned(FOnVerseFound) then
          FOnVerseFound(Self, FVersesFound, book, chapter, verse, BookLines[i], removeStrongs);
      end;
    end;
  end;

  btmp.Free;
  tmpwords.Free;
end;

procedure TBible.Search(s: string; params: byte; bookset: TBibleSet; removeStrongs: boolean);
var
  words: TStrings;
  w: string;
  i: integer;
{$IFDEF debug_profile}
  timeStart, time: Cardinal;
{$ENDIF}
begin
{$IFDEF debug_profile}
  timeStart := GetTickCount();
{$ENDIF}
  words := TStringList.Create;
  w := s;

  FLines.Clear;

  FVersesFound := 0;
  FStopSearching := False;

  if (params and spExactPhrase <> spExactPhrase) then
    while w <> '' do
      words.Add(DeleteFirstWord(w))
  else
    words.Add(Trim(s));

  if (params and spWordParts <> spWordParts) then
  begin
    for i := 0 to words.Count - 1 do
      words[i] := ' ' + words[i] + ' ';
  end;

  if words.Count > 0 then
  begin
    for i := 1 to FBookQty do
      if (i - 1) in bookset then
      begin
        if FStopSearching then
          break;
        if assigned(FOnVerseFound) then
          FOnVerseFound(Self, FVersesFound, i, 0, 0, '', removeStrongs);
        // just to know that there is a searching -- fire an event
        try
          SearchBook(words, params, i, removeStrongs);
        except
          on e: Exception do
          begin
            g_ExceptionContext.Add
              (Format('TBible.Search: s=%s | i(cbook)=%d', [s, i]));
            BqShowException(e);
          end;
        end;
      end;
  end;

  words.Free;

  if assigned(FOnSearchComplete) then
    FOnSearchComplete(Self);
{$IFDEF debug_profile}
  time := GetTickCount() - timeStart;
  ShowMessage(Format('����� �����: %d', [time]));
{$ENDIF}
end;

procedure TBible.StopSearching;
begin
  FStopSearching := true;
end;

function TBible.SyncToBible(const refBible: TBible; const bl: TBibleLink; out outBibleLink): integer;
var
  independentLink: TBibleLink;
  rslt: integer;
begin
  Result := -1;
  // check if both modules are bibles
  if not(refBible.isBible and isBible) then
    exit; // if not then fail

  // get indendent address
  rslt := refBible.ReferenceToInternal(bl, independentLink);
  if rslt <= -2 then
    exit;

end;

function TBible.toInternal(
  const bl: TBibleLink;
  out obl: TBibleLink;
  englishbible: boolean = False;
  EnglishPsalms: boolean = False): boolean;
begin
  Result := true;
  obl.book := bl.book;
  obl.chapter := bl.chapter;
  obl.vstart := bl.vstart;

  // in English Bible ROMANS follows ACTS instead of JAMES
  if englishbible or (EnglishPsalms and (bl.book = 19)) then
    ENG2RUS(bl.book, bl.chapter, bl.vstart, obl.book, obl.chapter, obl.vstart)
  else
  begin
    obl.book := bl.book;
    obl.chapter := bl.chapter;
    obl.vstart := bl.vstart;
  end;
end;

function TBible.VerseCount: integer;
begin
  Result := FLines.Count;
end;

procedure TBible._InternalSetContext(book, chapter: integer);
begin
  FBook := book;
  FChapter := chapter;
end;

function TBible.OpenRussianReference(s: string; var book, chapter, fromverse, toverse: integer): boolean;
var
  Name: string;
  ibook, ichapter, ifromverse, itoverse: integer;
begin
  Result := False;
  book := 1;
  chapter := 1;
  fromverse := 0;
  toverse := 0;

  if not SplitValue(s, name, ichapter, ifromverse, itoverse) then
    exit;

  name := ' ' + LowerCase(name) + ' ';

  for ibook := 1 to 66 do
    if Pos(string(name), string(' ' + LowerCase(RussianShortNames[ibook]) + ' ')) <> 0 then
    begin
      book := ibook;
      chapter := ichapter;
      fromverse := ifromverse;
      toverse := itoverse;

      Result := true;
      exit;
    end;
end;

function TBible.OpenTSKReference(s: string; var book, chapter, fromverse, toverse: integer): boolean;
var
  Name: string;
  ibook, ichapter, ifromverse, itoverse: integer;
begin
  Result := False;
  book := 1;
  chapter := 1;
  fromverse := 0;
  toverse := 0;

  if not SplitValue(s, name, ichapter, ifromverse, itoverse) then
    exit;

  name := ' ' + LowerCase(name) + ' ';

  for ibook := 1 to 66 do
    if Pos(string(name), string(' ' + LowerCase(TSKShortNames[ibook]) + ' ')) <> 0
    then
    begin
      book := ibook;
      chapter := ichapter;
      fromverse := ifromverse;
      toverse := itoverse;

      Result := true;
      exit;
    end;
end;

function TBible.OpenReference(s: string; var book, chapter, fromverse, toverse: integer): boolean;
var
  Name: string;
  ibook, ichapter, ifromverse, itoverse: integer;
begin
  Result := False;
  book := 1;
  chapter := 1;
  fromverse := 0;
  toverse := 0;

  if not SplitValue(s, name, ichapter, ifromverse, itoverse) then
    exit;

  name := ' ' + LowerCase(name) + ' ';

  for ibook := 1 to FBookQty do
    if Pos(string(name), string(' ' + LowerCase(ShortNamesVars[ibook]) +
      ' ')) <> 0 then
    begin
      book := ibook;
      chapter := ichapter;
      fromverse := ifromverse;
      toverse := itoverse;

      Result := true;
      exit;
    end;
end;

procedure TBible.ClearBuffers;
begin
  BookLines.Clear;
  FLines.Clear;
end;

function TBible.isEnglish: boolean;
begin
  Result := ((not trait[bqmtOldCovenant] and trait[bqmtNewCovenant]) and
    (ChapterQtys[6] = 16)) or (ChapterQtys[45] = 16);
end;

function TBible.LinkValidnessStatus(
  path: string;
  bl: TBibleLink;
  internalAddr: boolean = true;
  checkverse: boolean = true): integer;
var
  effectiveLnk: TBibleLink;
  openchapter_res: boolean;
begin
  Result := 0;
  try
    if FPath <> path then
      LoadIniFile(path);
    if internalAddr then
    begin
      Result := InternalToReference(bl, effectiveLnk);
      if Result < -1 then
      begin
        exit;
      end;
    end
    else
      bl.AssignTo(effectiveLnk);
    if checkverse then
    begin
      openchapter_res := OpenChapter(effectiveLnk.book, effectiveLnk.chapter);

      if (effectiveLnk.vstart > VerseQty) or (effectiveLnk.vstart < 0) then
      begin
        Result := -2;
        exit;
      end;
      if effectiveLnk.vend > effectiveLnk.vstart then
        dec(Result, ord(effectiveLnk.vend > VerseQty));
    end
    else
      openchapter_res := effectiveLnk.chapter <= ChapterQtys[effectiveLnk.book] - ord(trait[bqmtZeroChapter]);

    if not openchapter_res then
    begin
      Result := -2;
      exit;
    end;

  except
    Result := -2;
    g_ExceptionContext.Add('TBible.LinkValidnessStatus.path=' + path);
    g_ExceptionContext.Add('TBible.LinkValidnessStatus.bl=' + bl.ToCommand(''));
  end;

end;

function TBible.ShortPassageSignature(book, chapter, fromverse,
  toverse: integer): string;
var
  offset: integer;
begin
  if trait[bqmtZeroChapter] then
    offset := 1
  else
    offset := 0;

  if (fromverse <= 1) and (toverse = 0) then
    Result := Format('%s%d', [ShortNames[book], chapter - offset])
  else if (fromverse > 1) and (toverse = 0) then
    Result := Format('%s%d:%d', [ShortNames[book], chapter - offset, fromverse])
  else if toverse = fromverse then
    Result := Format('%s%d:%d', [ShortNames[book], chapter - offset, fromverse])
  else if toverse = fromverse + 1 then
    Result := Format('%s%d:%d,%d', [ShortNames[book], chapter - offset, fromverse, toverse])
  else
    Result := Format('%s%d:%d-%d', [ShortNames[book], chapter - offset, fromverse, toverse]);
end;

function TBible.FullPassageSignature(book, chapter, fromverse, toverse: integer): string;
var
  offset: integer;
begin
  if trait[bqmtZeroChapter] then
    offset := 1
  else
    offset := 0;

  if (fromverse <= 1) and (toverse = 0) then
    Result := Format('%s %d', [FullNames[book], chapter - offset])
  else if (fromverse > 1) and (toverse = 0) then
    Result := Format('%s %d:%d', [FullNames[book], chapter - offset, fromverse])
  else if toverse = fromverse then
    Result := Format('%s %d:%d', [FullNames[book], chapter - offset, fromverse])
  else if toverse = fromverse + 1 then
    Result := Format('%s %d:%d,%d', [FullNames[book], chapter - offset, fromverse, toverse])
  else
    Result := Format('%s %d:%d-%d', [FullNames[book], chapter - offset, fromverse, toverse]);
end;

function TBible.CountVerses(book, chapter: integer): integer;
var
  slines: TStrings;
  i, Count: integer;
begin
  if chapter < 1 then
  begin
    Result := CountVerses(book, 1);
    exit;
  end
  else if chapter > ChapterQtys[book] then
  begin
    Result := CountVerses(book, ChapterQtys[book]);
    exit;
  end;

  slines := nil;
  try
    slines := ReadHtml(FPath + PathNames[book], DefaultEncoding);

    i := 0;
    Count := 0;
    repeat
      if Pos(FChapterSign, slines[i]) > 0 then
        Inc(Count);
      if Count = chapter then
        break;
      Inc(i);
    until i = slines.Count;

    if i = slines.Count then
    begin
      Result := 0;
      exit;
    end;

    Count := 0;
    repeat
      if Pos(FVerseSign, slines[i]) > 0 then
        Inc(Count);
      Inc(i);
    until (i = slines.Count) or (Pos(FChapterSign, slines[i]) > 0);

  finally
    slines.Free;

  end;

  Result := Count;
end;

procedure TBible.ENG2RUS(book, chapter, verse: integer; var rbook, rchapter, rverse: integer);
begin
  rbook := book;
  rchapter := chapter;
  rverse := verse;

  if rbook > 39 then
    rbook := EngToRusTable[book - 39] + 39; // convert NT books

  // CHAPTER SHIFT

  case book of
    // JOB=40:1-40:5#-1;41:1-41:8#-1
    18:
      if ((chapter = 40) and (verse in [1 .. 5])) or
        ((chapter = 41) and (verse in [1 .. 8])) then
        rchapter := rchapter - 1;
    // PSA=10:1-147:11#-1
    19:
      begin
        if (chapter in [10 .. 146]) or ((chapter = 147) and (verse in [1 .. 11]))
        then
          rchapter := rchapter - 1;

        if (chapter = 115) then
          rchapter := rchapter - 1; // 115:1-18 = RUS 113:9-26
        // if(chapter = 116) and (verse>=10) then rchapter := rchapter-1; // 116:10-.. = RUS 114
      end;
    // ECC=5:1#-1
    21:
      if (chapter = 5) and (verse = 1) then
        rchapter := rchapter - 1;
    // SNG=6:13#+1
    22:
      if (chapter = 6) and (verse = 13) then
        rchapter := rchapter + 1;
    // DAN=4:1-4:3#-1
    27:
      if (chapter = 4) and (verse in [1 .. 3]) then
        rchapter := rchapter - 1;
    // JON=1:17#1
    32:
      if (chapter = 1) and (verse = 17) then
        rchapter := rchapter + 1;
    // ROM=16:25-16:27#-2
    45:
      if (chapter = 16) and (verse in [25 .. 27]) then
        rchapter := rchapter - 2;
  end;

  // VERSE SHIFT

  // JOB40=1-5#30;6-24#-5
  if (book = 18) and (chapter = 40) and (verse in [1 .. 5]) then
    rverse := rverse + 30;
  if (book = 18) and (chapter = 40) and (verse in [6 .. 24]) then
    rverse := rverse - 5;

  // JOB41=1-8#19;9-34#-8
  if (book = 18) and (chapter = 41) and (verse in [1 .. 8]) then
    rverse := rverse + 19;
  if (book = 18) and (chapter = 41) and (verse in [9 .. 34]) then
    rverse := rverse - 8;

  if (book = 19) then
  begin
    {
      PSA3=2+#1       PSA4=2+#1       PSA5=2+#1       PSA6=2+#1       PSA7=2+#1
      PSA8=2+#1       PSA9=2+#1       PSA18=2+#1      PSA19=2+#1      PSA20=2+#1
      PSA21=2+#1      PSA22=2+#1      PSA30=2+#1      PSA31=2+#1      PSA34=2+#1
      PSA36=2+#1      PSA38=2+#1      PSA39=2+#1      PSA40=2+#1      PSA41=2+#1
      PSA42=2+#1      PSA44=2+#1      PSA45=2+#1      PSA46=2+#1      PSA47=2+#1
      PSA48=2+#1      PSA49=2+#1      PSA53=2+#1      PSA55=2+#1      PSA56=2+#1
      PSA57=2+#1      PSA58=2+#1      PSA61=2+#1      PSA62=2+#1      PSA63=2+#1
      PSA64=2+#1      PSA65=2+#1      PSA67=2+#1      PSA68=2+#1      PSA69=2+#1
      PSA70=2+#1      PSA75=2+#1      PSA76=2+#1      PSA77=2+#1      PSA80=2+#1
      PSA81=2+#1      PSA83=2+#1      PSA84=2+#1      PSA85=2+#1      PSA88=2+#1
      PSA89=2+#1      PSA92=2+#1      PSA102=2+#1     PSA108=2+#1
    }
    if (chapter in [3 .. 9, 12, 13, 18 .. 22, 30, 31, 34, 36, 38 .. 42,
      44 .. 49, 53, 55 .. 58, 59, 61 .. 65, 67 .. 70, 75 .. 77, 80, 81,
      83 .. 85, 88, 89, 90, 92, 102, 108, 140]) and (verse >= 2) then
      rverse := rverse + 1;
    // PSA10=1+#21
    if (chapter = 10) then
      rverse := rverse + 21;
    // PSA51=2#1;3+#2
    // PSA52=2#1;3+#2
    // PSA54=2#1;3+#2
    // PSA60=2#1;3+#2
    if (chapter in [51, 52, 54, 60]) and (verse = 2) then
      rverse := rverse + 1;
    if (chapter in [51, 52, 54, 60]) and (verse >= 3) then
      rverse := rverse + 2;

    if chapter = 115 then
      rverse := rverse + 8;
    if (chapter = 116) and (verse >= 10) then
      rverse := rverse - 9;
    if (chapter = 147) and (verse >= 12) then
      rverse := rverse - 11;
  end;

  // ECC5=1#16;2-20#-1
  if (book = 21) and (chapter = 5) then
    if verse = 1 then
      rverse := rverse + 16
    else if verse in [2 .. 20] then
      rverse := rverse - 1;

  // SNG1=2-16#-1
  if (book = 22) and (chapter = 1) and (verse in [2 .. 16]) then
    rverse := rverse - 1;

  // SNG6=13#-12
  if (book = 22) and (chapter = 6) and (verse = 13) then
    rverse := rverse - 12;

  // SNG7=1-13#1
  if (book = 22) and (chapter = 7) and (verse in [1 .. 13]) then
    rverse := rverse + 1;

  // DAN3=24-30#67
  if (book = 27) and (chapter = 3) and (verse in [24 .. 30]) then
    rverse := rverse + 67;

  // DAN4=1-3#97;4-37#-3
  if (book = 27) and (chapter = 4) then
    if (verse in [1 .. 3]) then
      rverse := rverse + 97
    else if (verse in [4 .. 37]) then
      rverse := rverse - 3;

  // JON2=1-10#1
  if (book = 32) and (chapter = 2) and (verse in [1 .. 10]) then
    rverse := rverse + 1;

  // PRO13=14-25#1
  if (book = 20) and (chapter = 13) and (verse in [14 .. 25]) then
    rverse := rverse + 1;

  // PRO18=8-24#1
  if (book = 20) and (chapter = 18) and (verse in [8 .. 24]) then
    rverse := rverse + 1;

  // ROM16=25-27#-1
  if (book = 45) and (chapter = 16) and (verse in [25 .. 27]) then
    rverse := rverse - 1;

  // 2CO13=13#-1
  if (book = 47) and (chapter = 13) and (verse = 13) then
    rverse := rverse - 1;
end;

procedure TBible.RUS2ENG(book, chapter, verse: integer; var ebook, echapter, everse: integer);
begin
  ebook := book;
  echapter := chapter;
  everse := verse;

  if ebook > 39 then
    ebook := RusToEngTable[book - 39] + 39; // convert NT books

  // rules are ENG 2 RUS, from old KJV2RST method...

  // CHAPTER SHIFT

  case book of
    // JOB=40:1-40:5#-1;41:1-41:8#-1
    18:
      if ((chapter = 39) and (verse in [31 .. 35])) or
        ((chapter = 40) and (verse in [20 .. 27])) then
        echapter := echapter + 1;
    // PSA=10:1-147:11#-1
    19:
      begin
        if (chapter in [10 .. 145]) or ((chapter = 146) and (verse in [1 .. 11])
          ) or ((chapter = 9) and (verse in [22 .. 39])) then
          echapter := echapter + 1;

        if ((chapter = 113) and (verse in [9 .. 26])) or (chapter = 114) then
          echapter := echapter + 1; // +2, RUS 113:9-26 = 115:1-18
      end;
    // ECC=5:1#-1
    21:
      if (chapter = 4) and (verse = 17) then
        echapter := echapter + 1;
    // SNG=6:13#-1
    22:
      if (chapter = 7) and (verse = 1) then
        echapter := echapter - 1;
    // DAN=4:1-4:3#-1
    27:
      if (chapter = 3) and (verse in [98 .. 100]) then
        echapter := echapter - 1;
    // JON=1:17#1
    32:
      if (chapter = 2) and (verse = 1) then
        echapter := echapter - 1;
    // ROM=16:25-16:27#-2
    52:
      if (chapter = 14) and (verse in [24 .. 26]) then
        echapter := echapter + 2;
  end;

  // VERSE SHIFT

  // JOB40=1-5#30;6-24#-5
  if (book = 18) and (chapter = 39) and (verse in [31 .. 35]) then
    everse := everse - 30;
  if (book = 18) and (chapter = 40) and (verse in [1 .. 19]) then
    everse := everse + 5;

  // JOB41=1-8#19;9-34#-8
  if (book = 18) and (chapter = 40) and (verse in [20 .. 27]) then
    everse := everse - 19;
  if (book = 18) and (chapter = 41) and (verse in [1 .. 26]) then
    everse := everse + 8;

  if (book = 19) then
  begin
    {
      PSA3=2+#1       PSA4=2+#1       PSA5=2+#1       PSA6=2+#1       PSA7=2+#1
      PSA8=2+#1       PSA9=2+#1       PSA18=2+#1      PSA19=2+#1      PSA20=2+#1
      PSA21=2+#1      PSA22=2+#1      PSA30=2+#1      PSA31=2+#1      PSA34=2+#1
      PSA36=2+#1      PSA38=2+#1      PSA39=2+#1      PSA40=2+#1      PSA41=2+#1
      PSA42=2+#1      PSA44=2+#1      PSA45=2+#1      PSA46=2+#1      PSA47=2+#1
      PSA48=2+#1      PSA49=2+#1      PSA53=2+#1      PSA55=2+#1      PSA56=2+#1
      PSA57=2+#1      PSA58=2+#1      PSA61=2+#1      PSA62=2+#1      PSA63=2+#1
      PSA64=2+#1      PSA65=2+#1      PSA67=2+#1      PSA68=2+#1      PSA69=2+#1
      PSA70=2+#1      PSA75=2+#1      PSA76=2+#1      PSA77=2+#1      PSA80=2+#1
      PSA81=2+#1      PSA83=2+#1      PSA84=2+#1      PSA85=2+#1      PSA88=2+#1
      PSA89=2+#1      PSA92=2+#1      PSA102=2+#1     PSA108=2+#1
    }
    if (chapter in [3 .. 9, 11, 12, 17, 18 .. 22, 29, 30, 33, 35, 37 .. 41,
      43 .. 48, 52, 54 .. 58, 60 .. 64, 66 .. 69, 74 .. 76, 79, 80, 82 .. 84,
      87, 88, 89, 91, 101, 107, 139]) and (verse >= 2) then
      everse := everse - 1;
    // PSA10=1+#21
    if (chapter = 9) and (verse >= 22) then
      everse := everse - 20;
    // PSA51=2#1;3+#2
    // PSA52=2#1;3+#2
    // PSA54=2#1;3+#2
    // PSA60=2#1;3+#2
    if (chapter in [50, 51, 53, 59]) and (verse <= 2) then
      everse := 1;
    if (chapter in [50, 51, 53, 59]) and (verse >= 3) then
      everse := everse - 2;

    if (chapter = 113) and (verse >= 9) then
      everse := everse - 8;
    if (chapter = 115) then
      everse := everse + 9;
  end;

  // ECC5=1#16;2-20#-1
  if (book = 21) and (chapter = 4) then
    if verse = 17 then
      everse := everse - 16
    else if (chapter = 5) and (verse in [1 .. 19]) then
      everse := everse + 1;

  // SNG1=2-16#-1
  if (book = 22) and (chapter = 1) and (verse in [1 .. 15]) then
    everse := everse + 1;

  // SNG6=13#-12
  if (book = 22) and (chapter = 7) and (verse = 1) then
    everse := everse + 12;

  // SNG7=1-13#1
  if (book = 22) and (chapter = 7) and (verse in [2 .. 14]) then
    everse := everse - 1;

  // DAN3=24-30#67
  if (book = 27) and (chapter = 3) and (verse in [91 .. 97]) then
    everse := everse - 67;

  // DAN4=1-3#97;4-37#-3
  if (book = 27) and (chapter = 3) and (verse in [98 .. 100]) then
    everse := everse - 97;
  if (book = 27) and (chapter = 4) and (verse in [1 .. 34]) then
    everse := everse + 3;

  // JON2=1-10#1
  if (book = 32) and (chapter = 2) and (verse = 1) then
    everse := everse + 16;
  if (book = 32) and (chapter = 2) and (verse in [2 .. 11]) then
    everse := everse - 1;

  // PRO13=14-25#1
  if (book = 20) and (chapter = 13) and (verse in [15 .. 26]) then
    everse := everse - 1;

  // PRO18=8-24#1
  if (book = 20) and (chapter = 18) and (verse in [9 .. 25]) then
    everse := everse - 1;

  // ROM16=25-27#-1
  if (book = 52) and (chapter = 14) and (verse in [24 .. 26]) then
    everse := everse + 1;

  // 2CO13=13#-1
  if (book = 54) and (chapter = 13) and (verse = 13) then
    everse := everse + 1;
end;

{
  procedures to convert a Russian Bible reference (which is stored in xref.dat)
  to equivalent in current module
}
function BookShortNamesToRussianBible(const ShortNames: string; out book: integer): integer;
var
  maxMatchValue, maxMatchIx, currentMatchValue, i: integer;
begin
  maxMatchValue := -1;
  maxMatchIx := -1;
  for i := 1 to 66 do
  begin
    currentMatchValue := CompareTokenStrings(RussianShortNames[i], ShortNames, ' ');
    if currentMatchValue > maxMatchValue then
    begin
      maxMatchValue := currentMatchValue;
      maxMatchIx := i;
    end;
  end;
  Result := maxMatchValue;
  book := maxMatchIx;
end;

function TBible.ReferenceToInternal(
  book, chapter, verse: integer;
  var ibook, ichapter, iverse: integer;
  checkShortNames: boolean = true): boolean;
var
  newTestamentOnly, englishbible: boolean;
  offset, checkNamesResult, savebook: integer;
begin
  Result := true;

  if trait[bqmtZeroChapter] then
    offset := 1
  else
    offset := 0;

  ibook := book;
  ichapter := chapter - offset;
  iverse := verse;

  if (not FBible) or (book > 66) then
  begin
    ibook := 1;
    ichapter := 1;
    iverse := 1;
    Result := False;
    exit;
  end;

  newTestamentOnly := not trait[bqmtOldCovenant] and trait[bqmtNewCovenant];
  englishbible := (newTestamentOnly and (ChapterQtys[6] = 16)) or (ChapterQtys[45] = 16);

  savebook := book;
  if newTestamentOnly then
    Inc(book, 39);

  if checkShortNames then
  begin
    checkNamesResult := BookShortNamesToRussianBible(ShortNamesVars[savebook], ibook);
    if checkNamesResult > 30 then
    begin
      book := ibook;
      if englishbible then
      begin
        RUS2ENG(book, 1, 1, ibook, ichapter, iverse);
        book := ibook;
      end;
    end;
  end;
  // in English Bible ROMANS follows ACTS instead of JAMES

  if not newTestamentOnly then
  begin
    if englishbible or (trait[bqmtEnglishPsalms] and (book = 19)) then
      ENG2RUS(book, chapter - offset, verse, ibook, ichapter, iverse)
    else
    begin
      ibook := book;
      ichapter := chapter - offset;
      iverse := verse;
    end;
  end
  else
  begin
    if englishbible then
      ENG2RUS(book, chapter - offset, verse, ibook, ichapter, iverse)
    else
    begin
      ibook := book;
      ichapter := chapter - offset;
      iverse := verse;
    end;
  end;

end;

procedure TBible.InstallFonts;
var
  pc: PChar;
  saveChar: Char;
  l: integer;
  token: String;

begin
  pc := Pointer(mInstallFontNames);
  if (pc = nil) then
    exit;

  pc := GetTokenFromString(pc, ',', l);
  if pc <> nil then
    repeat
      saveChar := (pc + l)^;
      (pc + l)^ := #0;
      token := pc;
      (pc + l)^ := saveChar;
      mUIServices.InstallFont(FPath + Trim(token));

      Inc(pc, l);

      pc := GetTokenFromString(pc, ',', l);
    until (pc = nil);

end;

function TBible.InternalToReference(inputLnk: TBibleLink; out outLink: TBibleLink): integer;
begin
  inputLnk.AssignTo(outLink);
  outLink.tokenEndOffset := outLink.tokenEndOffset;
  Result := ord(InternalToReference(inputLnk.book, inputLnk.chapter,
    inputLnk.vstart, outLink.book, outLink.chapter, outLink.vstart)) - 1;
  if Result < 0 then
  begin
    Result := -2;
    exit;
  end;
  Inc(Result,
    ord(InternalToReference(inputLnk.book, inputLnk.chapter, inputLnk.vend, outLink.book, outLink.chapter, outLink.vend)) - 1);
end;

function TBible.IsCommentary: boolean;
var
  s: string;
begin
  s := ExtractFileDir(FIniFile);
  s := ExtractFileDir(s);

  s := ExtractFileName(s);
  Result := UpperCase(s) = 'COMMENTARIES';
end;

function RussianBibleBookToModuleBook(bookIx: integer; bibleModule: TBible; out book: integer): integer;
var
  maxMatchValue, maxMatchIx, currentMatchValue, i, modBookCount: integer;
begin
  maxMatchValue := -1;
  maxMatchIx := -1;
  modBookCount := bibleModule.FBookQty;
  for i := 1 to modBookCount do
  begin
    currentMatchValue := CompareTokenStrings(RussianShortNames[bookIx],
      bibleModule.ShortNamesVars[i], ' ');
    if currentMatchValue > maxMatchValue then
    begin
      maxMatchValue := currentMatchValue;
      maxMatchIx := i;
    end;
  end;
  Result := maxMatchValue;
  book := maxMatchIx;
end;

function TBible.InternalToReference(
  ibook, ichapter, iverse: integer;
  var book, chapter, verse: integer;
  checkShortNames: boolean = true): boolean;
var
  newCovenantOnly, oldCovenantOnly, englishbible: boolean;
  checkNamesResult, savebook: integer;
begin
  Result := true;

  book := ibook;
  savebook := ibook;
  chapter := ichapter;
  verse := iverse;

  if ichapter > C_TotalPsalms then
    chapter := 1;

  if (not FBible) then
  begin
    book := 1;
    chapter := 1;
    verse := 1;
    Result := False;
    exit;
  end;
  if (ibook > 66) then
  begin
    Result := true;
    exit;
  end;

  newCovenantOnly := not trait[bqmtOldCovenant] and trait[bqmtNewCovenant];
  // (not FHasOT) and FHasNT;

  englishbible := (newCovenantOnly and (ChapterQtys[6] = 16)) or
    (ChapterQtys[45] = 16);

  // in English Bible ROMANS (16 chaps) follows ACTS instead of JAMES (5 chaps)

  if not newCovenantOnly then // ���� �� ��
  begin
    oldCovenantOnly := not trait[bqmtNewCovenant] and trait[bqmtOldCovenant];
    if oldCovenantOnly and (book >= 40) then
    begin
      book := 1;
      chapter := 1;
      verse := 1;
      Result := False;
      exit;
    end;
    if englishbible or (trait[bqmtEnglishPsalms] and (book = 19)) then
      RUS2ENG(ibook, ichapter, iverse, book, chapter, verse)
    else
    begin
      book := ibook;
      chapter := ichapter;
      verse := iverse;
    end;
  end
  else
  begin // ���� ������ ��
    if englishbible then
    begin
      RUS2ENG(ibook, ichapter, iverse, book, chapter, verse);
      if book > 39 then
        book := book - 39
      else
      begin
        book := 1;
        chapter := 1;
        verse := 1;
        Result := False;
        exit;
      end;
    end
    else
    begin // �� ���������� ������
      if ibook > 39 then
      begin
        book := ibook - 39;
        chapter := ichapter;
        verse := iverse;
      end
      else
      begin
        book := 1;
        chapter := 1;
        verse := 1;
        Result := False;
        exit;
      end;
    end;

  end;
  if trait[bqmtZeroChapter] then
    chapter := chapter + 1;
  if checkShortNames then
  begin
    checkNamesResult := RussianBibleBookToModuleBook(savebook, Self, ibook);
    if checkNamesResult > 30 then
    begin
      book := ibook;
    end;
  end;

  if (chapter = 0) and (not trait[bqmtZeroChapter]) then
    chapter := 1;
end;

function TBible.ReferenceToEnglish(
  book, chapter, verse: integer;
  var ebook, echapter, everse: integer;
  checkShortNames: boolean = true): boolean;
var
  newTestamentOnly, englishbible: boolean;
  offset, savebook, checkNamesResult: integer;
begin
  Result := true;

  offset := 0;
  if trait[bqmtZeroChapter] then
    offset := 1;

  ebook := book;
  echapter := chapter - offset;
  everse := verse;

  if (not FBible) or (book > 66) then
  begin
    ebook := 1;
    echapter := 1;
    everse := 1;
    Result := False;
    exit;
  end;

  newTestamentOnly := not trait[bqmtOldCovenant] or trait[bqmtNewCovenant];
  // (not FHasOT) and FHasNT;
  englishbible := (newTestamentOnly and (ChapterQtys[6] = 16)) or
    (ChapterQtys[45] = 16);
  // in English Bible ROMANS follows ACTS instead of JAMES
  savebook := book;
  if newTestamentOnly then
    Inc(book, 39);
  if checkShortNames then
  begin
    checkNamesResult := BookShortNamesToRussianBible
      (ShortNamesVars[savebook], ebook);
    if checkNamesResult > 30 then
    begin
      book := ebook;
      if englishbible then
      begin
        RUS2ENG(book, 1, 1, ebook, echapter, everse);
        book := ebook;
      end;
    end;
  end;
  if not newTestamentOnly then
  begin
    if englishbible then
    begin
      ebook := book;
      echapter := chapter - offset;
      everse := verse;
    end
    else
    begin
      RUS2ENG(book, chapter - offset, verse, ebook, echapter, everse)
    end;
  end
  else
  begin
    if englishbible then
    begin
      ebook := book;
      echapter := chapter - offset;
      everse := verse;
    end
    else
    begin
      RUS2ENG(book, chapter - offset, verse, ebook, echapter, everse)
    end;
  end;
end;

function TBible.EnglishToReference(
  ebook, echapter, everse: integer;
  var book, chapter, verse: integer): boolean;
var
  newtestament, englishbible: boolean;
begin
  Result := true;

  book := ebook;
  chapter := echapter;
  verse := everse;

  if (not FBible) or (ebook > 66) then
  begin
    book := 1;
    chapter := 1;
    verse := 1;
    Result := False;
    exit;
  end;

  newtestament := not trait[bqmtOldCovenant] and trait[bqmtNewCovenant];
  // (not FHasOT) and FHasNT;
  englishbible := (newtestament and (ChapterQtys[6] = 16)) or
    (ChapterQtys[45] = 16);
  // in English Bible ROMANS (16 chaps) follows ACTS instead of JAMES (5 chaps)

  if not newtestament then
  begin
    if englishbible then
    begin
      book := ebook;
      chapter := echapter;
      verse := everse;
    end
    else
    begin
      ENG2RUS(ebook, echapter, everse, book, chapter, verse)
    end;
  end
  else
  begin
    if englishbible then
    begin
      book := ebook - 39;
      chapter := echapter;
      verse := everse;
    end
    else
    begin
      ENG2RUS(ebook, echapter, everse, book, chapter, verse);
      book := book - 39;
    end;
  end;

  if trait[bqmtZeroChapter] then
    chapter := chapter + 1;
end;

{

  Psalms: array[1..150] of integer =
  (6, 12, 9, 9, 13, 11, 18, 10, 39, 8,
  9, 6, 8, 6, 12, 16, 51, 15, 10, 14,
  32, 7, 11, 23, 13, 15, 10, 12, 13,
  25, 12, 22, 23, 29, 13, 41, 23, 14, 18, 14, 12, 5, 27, 18, 12, 10, 15, 21,
  24, 21, 11, 7, 9, 24, 14, 12, 12, 18, 14, 9, 13, 12, 11, 14, 21, 8, 36, 37, 6,
  24, 20, 29, 24, 11, 13, 21, 73, 14, 20, 17, 9, 19, 13, 14, 18, 7, 19, 53, 17,
  16, 16, 5, 23, 11, 13, 12, 10, 9, 6, 9, 29, 23, 35, 45, 49, 43, 14, 32, 8,
  11, 11, 10, 26, 9, 10, 2, 29, 176, 8, 9, 10, 5, 9, 6, 7, 6, 7, 9, 9, 4, 19,
  4, 4, 22, 26, 9, 9, 25, 14, 11, 8, 13, 16, 22, 10, 11, 9, 14, 9, 6);

}
initialization

finalization

try
  bookNames.Free();
except
end;

end.
