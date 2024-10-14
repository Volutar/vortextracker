{
This is part of Vortex Tracker II project

(c)2000-2009 S.V.Bulba
Author: Sergey Bulba, vorobey@mail.khstu.ru
Support page: http://bulba.untergrund.net/

(c)2017-2021 Version 2.0 and later
Ivan Pirog (Flexx/Enhancers), ivan.pirog@gmail.com
}

{.$DEFINE NOREDRAW}
{.$DEFINE DEBUG}
{.$DEFINE LOGGER}

unit Main;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, AY, WaveOutAPI, trfuncs, grids, ChildWin,
  MidiType, MidiIn, ColorThemes, ShellAPI, inifiles, RegExpr{$IFDEF LOGGER}, Logger {$ENDIF};

const
  UM_REDRAWTRACKS   = WM_USER + 1;
  UM_PLAYINGOFF     = WM_USER + 2;
  UM_FINALIZEWO     = WM_USER + 3;


  StdAutoEnvMax = 7;
  StdAutoEnv: array[0..StdAutoEnvMax, 0..1] of integer =
  ((1, 1), (3, 4), (1, 2), (1, 4), (3, 1), (5, 2), (2, 1), (3, 2));


  AppName = 'Vortex Tracker';
  VersionString = '2.6.1';
  IsBeta = '';
  BetaNumber = '';

  VersionFullString = VersionString + IsBeta + BetaNumber;

  FullVersString = AppName + ' ' + VersionFullString;
  HalfVersString = 'Version ' + VersionFullString;


  VortexDirName = AppName + ' ' + VersionString + IsBeta;
  SamplesDefaultDir = '\Instruments\Samples';
  OrnamentsDefaultDir = '\Instruments\Ornaments';
  DemosongsDefaultDir = '\Demosongs';
  FontsDir = '\Fonts';

  InternalFonts: array[0..26] of array[0..1] of string = (
    ('SegoeVT',         'Segoe VT'),
    ('ArrowsFont',      'Arrows'),
    ('ConsolasFont',    'Consolas'),
    ('ConsolasBFont',   'Consolas'),
    ('CQMono',          'CQ Mono'),
    ('DroidSansFont',   'Droid Sans Mono'),
    ('ConsolaMono',     'Consola Mono'),
    ('ConsolaMonoBold', 'Consola Mono'),
    ('EtelkaMono',      'Etelka Monospace Pro'),
    ('EtelkaMonoBold',  'Etelka Monospace Pro'),
    ('RobotoMono',      'Roboto Mono'),
    ('RobotoMonoBold',  'Roboto Mono'),
    ('HackFont',        'Hack'),
    ('HackBFont',       'Hack'),
    ('LiberationFont',  'Liberation Mono'),
    ('LiberationBFont', 'Liberation Mono'),
    ('ShareTechFont',   'Share Tech Mono'),
    ('ZXSpectrumFont',  'ZX Spectrum'),
    ('Kongtext',        'Kongtext'),
    ('Gohufont',        'gohufont-14'),
    ('GohufontBold',    'gohufont-14b'),
    ('ProFontWindows',  'ProFontWindows'),
    ('JackInput',       'JackInput'),
    ('CourierNew',      'Courier New'),
    ('CourierNewB',     'Courier New'),
    ('CourierNewI',     'Courier New'),
    ('wstgerm',         'WST_Germ')
  );
  

  ModuleExtensions: array[0..14] of string = (
    '.vt2', '.pt1', '.pt2', '.pt3', '.stc', '.stp',
    '.sqt', '.asc', '.psc', '.fls', '.gtr', '.ftc',
    '.psm', '.fxm', '.ay'
  );


type

  TSize = record
    Width: Integer;
    Height: Integer;
    Left: Integer;
    Top: Integer;
  end;


  TChansArrayBool = array[0..2] of boolean;
  ERegistryError = class(Exception);
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    FileNew1: TAction;
    FileSave1: TAction;
    FileExit1: TAction;
    FileOpen1: TAction;
    FileSaveAs1: TAction;
    HelpAbout1: TAction;
    FileClose1: TWindowClose;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton9: TToolButton;
    ImageList1: TImageList;
    N2: TMenuItem;
    Options1: TMenuItem;
    SaveDialog1: TSaveDialog;
    ToolButton13: TToolButton;
    Play1: TAction;
    Play2: TMenuItem;
    Play4: TMenuItem;
    Stop2: TMenuItem;
    PopupMenu1: TPopupMenu;
    Setloopposition1: TMenuItem;
    Deleteposition1: TMenuItem;
    Insertposition1: TMenuItem;
    SetLoopPos: TAction;
    InsertPosition: TAction;
    DeletePosition: TAction;
    ToolButton15: TToolButton;
    ToggleLooping: TAction;
    Togglelooping1: TMenuItem;
    N3: TMenuItem;
    RFile1: TMenuItem;
    RFile2: TMenuItem;
    RFile3: TMenuItem;
    RFile4: TMenuItem;
    RFile5: TMenuItem;
    RFile6: TMenuItem;
    ToggleChip: TAction;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    ToggleChanAlloc: TAction;
    ToolButton17: TToolButton;
    ToggleLoopingAll: TAction;
    Play3: TMenuItem;
    Toggleloopingall1: TMenuItem;
    N4: TMenuItem;
    Tracksmanager1: TMenuItem;
    Globaltransposition1: TMenuItem;
    TrackBar1: TTrackBar;
    PlayPat: TAction;
    PlayPatFromLine: TAction;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    Playpatternfromstart1: TMenuItem;
    Playpatternfromcurrentline1: TMenuItem;
    Exports1: TMenuItem;
    SaveSNDHMenu: TMenuItem;
    SaveDialogSNDH: TSaveDialog;
    SaveforZXMenu: TMenuItem;
    SaveDialogZXAY: TSaveDialog;
    EditCopy1: TAction;
    EditCut1: TAction;
    EditPaste1: TAction;
    Undo: TAction;
    Redo: TAction;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    TransposeUp1: TAction;
    TransposeDown1: TAction;
    TransposeUp12: TAction;
    TransposeDown12: TAction;
    PopupMenu2: TPopupMenu;
    TransposeUp1a: TMenuItem;
    TransposeDown1a: TMenuItem;
    TransposeUp12a: TMenuItem;
    TransposeDown12a: TMenuItem;
    N5: TMenuItem;
    Undo2: TMenuItem;
    Redo2: TMenuItem;
    N6: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N7: TMenuItem;
    ToolButton26: TToolButton;
    ToolButton27: TToolButton;
    PopupMenu3: TPopupMenu;
    File2: TMenuItem;
    Play5: TMenuItem;
    rack1: TMenuItem;
    N8: TMenuItem;
    Togglesamples1: TMenuItem;
    ToolButton25: TToolButton;
    N9: TMenuItem;
    ExpandTwice1: TMenuItem;
    Compresspattern1: TMenuItem;
    Merge1: TMenuItem;
    midiin1: TMidiInput;
    RenumberPatterns: TMenuItem;
    DuplicateLastNoteParams: TAction;
    MoveBetwnPatrns: TAction;
    AutoNumeratePatterns: TMenuItem;
    ToolButton29: TToolButton;
    BackupTimer: TTimer;
    Color1: TMenuItem;
    PositionColorRed: TMenuItem;
    PositionColorBlue: TMenuItem;
    PositionColorGreen: TMenuItem;
    PositionColorMaroon: TMenuItem;
    PositionColorPurple: TMenuItem;
    PositionColorGray: TMenuItem;
    PositionColorTeal: TMenuItem;
    PositionColorDefault: TMenuItem;
    SyncCheckTimer: TTimer;
    SyncFinishTimer: TTimer;
    ResetColors: TMenuItem;
    sep1: TMenuItem;
    sep2: TMenuItem;
    sep3: TMenuItem;
    DuplicatePosition1: TMenuItem;
    ClonePosition1: TMenuItem;
    Changepatternslength1: TMenuItem;
    sep4: TMenuItem;
    Splitpattern1: TMenuItem;
    SyncCopyBuffers: TTimer;
    PlayStopBtn: TToolButton;
    PlayStop: TAction;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    AutoStep0: TAction;
    AutoStep1: TAction;
    AutoStep2: TAction;
    AutoStep3: TAction;
    AutoStep4: TAction;
    AutoStep5: TAction;
    AutoStep6: TAction;
    AutoStep7: TAction;
    AutoStep8: TAction;
    AutoStep9: TAction;
    ExportWAV: TMenuItem;
    N11: TMenuItem;
    ExportToWAV: TAction;
    NewTurbosound: TAction;
    Newturbosoudtrack1: TMenuItem;
    SaveAsTwoModules: TAction;
    Saveas2modules1: TMenuItem;
    Stop: TAction;
    Maximize: TMenuItem;
    Maximize1: TAction;
    Normal: TAction;
    Normal1: TMenuItem;
    PlayFromLine: TAction;
    PlayFromLine1: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    SwapChannelsLeft: TMenuItem;
    SwapChannelsRight: TMenuItem;
    SwapChannelsLeft1: TAction;
    SwapChannelsRight1: TAction;
    JoinTracks: TAction;
    JoinTracks1: TMenuItem;
    SaveAsTemplate: TAction;
    SaveAsTemplate1: TMenuItem;
    OpenDemo: TMenuItem;
    JmpPatStartAct: TAction;
    JmpPatEndAct: TAction;
    JmpLineStartAct: TAction;
    JmpLineEndAct: TAction;
    ExportPSG: TMenuItem;
    MIDITimer: TTimer;
    PositionColorL1: TMenuItem;
    PositionColorL2: TMenuItem;
    PositionColorL3: TMenuItem;
    PositionColorL4: TMenuItem;
    PositionColorL5: TMenuItem;
    TransposeUp3: TAction;
    TransposeUp5: TAction;
    TransposeDown3: TAction;
    TransposeDown5: TAction;
    TransposeUp3a: TMenuItem;
    TransposeDown3a: TMenuItem;
    TransposeUp5a: TMenuItem;
    TransposeDown5a: TMenuItem;
    CopyToExt: TMenuItem;
    CopyToExtAct: TAction;
    CopyToExternalTracker: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    PackPatternAct: TAction;
    PackPattern1: TMenuItem;
    ExportPSGAct: TAction;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    JoinTracksBtn: TAction;
    ToggleSamplesAct: TAction;
    TracksManagerAct: TAction;
    GlobalTranspositionAct: TAction;
    Newturbosoudtrack3: TMenuItem;
    CenteringTimer: TTimer;
    Clearpatterns1: TMenuItem;
    function IsFileWritable(FilePath: String): Boolean;
    function VScrollVisible(NewHeight: Integer): Boolean;
    function HScrollVisible(NewLeft: Integer): Boolean;
    function VScrollSize(NewHeight: Integer): Integer;
    function HScrollSize(NewLeft: Integer): Integer;
    function BorderSize: Integer;
    function DoubleBorderSize: Integer;
    function AbsTop: Integer;
    function OuterHeight: Integer;
    function MonitorWorkAreaWidth: Integer;
    function MonitorWorkAreaHeight: Integer;
    function WorkAreaHeight(NewHeight: Integer): Integer;
    function OneTrack: Boolean;
    function ResizeChildsHeight: Boolean;
    function ChildsWidth: Integer;
    function ChildsRight: Integer;
    function ChildsBottom: Integer;
    function ChildsMaxHeight: Integer;
    procedure SetWidth(Value: Integer; Fixed: Boolean);
    procedure FixWidth;
    procedure ResetConstraints(CalculateMinWidth: Boolean);
    function IsShortCut(var Message: TWMKey): Boolean; override;
    function NoPatterns: Boolean;
    function GetSizeForChilds(MainWindowState: TWindowState; MoveChild: Boolean): TSize;
    procedure SetWindowSize(NewSize: TSize);
    procedure AddWindowListItem(Child: TMDIChild);
    procedure DeleteWindowListItem(Child: TMDIChild);    
    procedure AutoMetrixForChilds(MainWindowState: TWindowState);
    procedure SetChildsTab(Tab: Integer);
    procedure UnpackSamples;
    procedure UnpackOrnaments;
    procedure OpenDemosong(Sender: TObject);
    procedure UnpackDemosongs;
    procedure AppException(Sender: TObject; E: Exception);
    procedure SetChildsPosition(MainWindowState: TWindowState);
    procedure CreateChildWrapper(const Name: string);
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RedrawAllSamOrnBrowsers;
    procedure RedrawChilds;
    procedure umredrawtracks(var Msg: TMessage); message UM_REDRAWTRACKS;
    procedure umplayingoff(var Msg: TMessage); message UM_PLAYINGOFF;
    procedure umfinalizewo(var Msg: TMessage); message UM_FINALIZEWO;
    procedure Options1Click(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FileSave1Update(Sender: TObject);
    procedure FileSaveAs1Execute(Sender: TObject);
    procedure FileSaveAs1Update(Sender: TObject);
    procedure Play1Update(Sender: TObject);
    procedure Play1Execute(Sender: TObject);
    procedure RestoreTracksFocus;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SetLoopPosExecute(Sender: TObject);
    procedure SetLoopPosUpdate(Sender: TObject);
    procedure InsertPositionExecute(Sender: TObject);
    procedure DeletePositionExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ToggleLoopingExecute(Sender: TObject);
    procedure AddFileName(FN: string);
    procedure OpenRecent(n: integer);
    procedure RFile1Click(Sender: TObject);
    procedure RFile2Click(Sender: TObject);
    procedure RFile3Click(Sender: TObject);
    procedure RFile4Click(Sender: TObject);
    procedure RFile5Click(Sender: TObject);
    procedure RFile6Click(Sender: TObject);
    procedure RestoreControls;
    procedure ScrollToPlayingWindow;
    procedure ToggleChipExecute(Sender: TObject);
    procedure ToggleChanAllocExecute(Sender: TObject);
    procedure SetChannelsAllocation(CA: integer);
    procedure ToggleLoopingAllExecute(Sender: TObject);
    procedure DisableControls(DisableTracks: Boolean);
    //procedure CheckSecondWindow(DisableTracks: Boolean);

    {

    // Commented code block, because users really
    // don't need templates for samples

    procedure SetSampleTemplate(Tmp: integer);
    procedure AddToSampTemplate(const SamTik: TSampleTick);
    procedure ResetSampTemplate;

    }

    procedure SetEmulatingChip(ChType: ChTypes);

    procedure TracksManagerUpdate(Sender: TObject);
    procedure TracksManagerClick(Sender: TObject);
    procedure GlobalTranspositionUpdate(Sender: TObject);
    procedure GlobalTranspositionClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure ResetOptions;
    function IsFontValid(FontName: string): Boolean;
    procedure GetFileAssocFromText(FileAssocText: string);
    function FileAssocToText: string;
    procedure SaveOptions;
    procedure LoadOptions;
    function IsFileAssociationExists(FileExt: string): boolean;
    function IsVortexFileAssociation(FileExt, AssocName: string): boolean;
    procedure CheckFileAssociations;
    procedure SetFileAssociations;
    procedure PlayPatFromLineUpdate(Sender: TObject);
    procedure PlayPatUpdate(Sender: TObject);
    procedure PlayPatExecute(Sender: TObject);
    procedure PlayPatFromLineExecute(Sender: TObject);
    procedure SaveSNDHMenuClick(Sender: TObject);
    procedure SaveforZXMenuClick(Sender: TObject);
    procedure SaveDialogZXAYTypeChange(Sender: TObject);
    procedure SetDialogZXAYExt;
    procedure SaveDialog1TypeChange(Sender: TObject);
    procedure SetPriority(Pr: longword);
    procedure EditCopy1Update(Sender: TObject);
    procedure EditCut1Update(Sender: TObject);
    procedure EditCut1Execute(Sender: TObject);
    procedure EditCopy1Execute(Sender: TObject);
    procedure EditPaste1Update(Sender: TObject);
    procedure EditPaste1Execute(Sender: TObject);
    procedure UndoUpdate(Sender: TObject);
    procedure UndoExecute(Sender: TObject);
    procedure RedoUpdate(Sender: TObject);
    procedure RedoExecute(Sender: TObject);
    procedure CheckCommandLine;
    function GetFirstModule(CW:TMDIChild):TMDIChild;
    function SavePT3(CW: TMDIChild; FileName: string; AsText: boolean): boolean;
    function SavePT3Backup(CW: TMDIChild; FileName: string; AsText: boolean): boolean;
    function AllowSave(fn: string): boolean;
    procedure RedrawPlWindow(PW: TMDIChild; ps, pat, line: integer);
    procedure TransposeChannel(WorkWin: TMDIChild; Pat, Chn, i, Semitones: integer);
    procedure TransposeColumns(WorkWin: TMDIChild; Pat: integer; Env: boolean; Chans: TChansArrayBool; LFrom, LTo, Semitones: integer; MakeUndo: boolean);
    procedure TransposeSelection(Semitones: integer);
    procedure TransposeUp1Update(Sender: TObject);
    procedure TransposeDown1Update(Sender: TObject);
    procedure TransposeUp12Update(Sender: TObject);
    procedure TransposeDown12Update(Sender: TObject);
    procedure TransposeUp1Execute(Sender: TObject);
    procedure TransposeDown1Execute(Sender: TObject);
    procedure TransposeUp12Execute(Sender: TObject);
    procedure TransposeDown12Execute(Sender: TObject);
    procedure PopupMenu3Click(Sender: TObject);
    procedure SetBar(BarNum: integer; Value: boolean);
    procedure ToggleSamplesUpdate(Sender: TObject);
    procedure ToggleSamplesClick(Sender: TObject);
    procedure ExpandTwice1Click(Sender: TObject);
    procedure Compresspattern1Click(Sender: TObject);
    procedure Merge1Click(Sender: TObject);
    procedure midiin1MidiInput(Sender: TObject);
    procedure RenumberPatternsClick(Sender: TObject);
    procedure UpdateEnvelopeAsNote;
    procedure ChangeDupNoteParams;
    procedure DuplicateLastNoteParamsExecute(Sender: TObject);
    procedure ChangeBetweenPatterns;
    procedure MoveBetwnPatrnsExecute(Sender: TObject);
    procedure AutoNumeratePatternsClick(Sender: TObject);
    procedure AutoCutChilds(NewSize: TSize);
    procedure AutoToolBarPosition(NewSize: TSize);
    procedure SaveBackups(Sender: TObject);
    procedure ChangeBackupTimer;
    procedure SetPositionColor(NumColor: byte);
    procedure PositionColorRedClick(Sender: TObject);
    procedure PositionColorGreenClick(Sender: TObject);
    procedure PositionColorBlueClick(Sender: TObject);
    procedure PositionColorMaroonClick(Sender: TObject);
    procedure PositionColorPurpleClick(Sender: TObject);
    procedure PositionColorGrayClick(Sender: TObject);
    procedure PositionColorTealClick(Sender: TObject);
    procedure PositionColorDefaultClick(Sender: TObject);
    procedure PositionColorRedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorGreenDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorBlueDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorMaroonDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorPurpleDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorGrayDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorTealDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorDefaultDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorL1DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorL1Click(Sender: TObject);
    procedure PositionColorL2DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorL2Click(Sender: TObject);
    procedure PositionColorL3DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorL3Click(Sender: TObject);
    procedure PositionColorL4DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorL4Click(Sender: TObject);
    procedure PositionColorL5DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PositionColorL5Click(Sender: TObject);
    procedure Setloopposition1MeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure DrawSubmenuColor(Color: TColor; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure SendSyncMessage;
    procedure SyncCheckTimerTimer(Sender: TObject);
    procedure SyncFinishTimerTimer(Sender: TObject);
    procedure PrepareColors;
    procedure ResetColorsClick(Sender: TObject);
    procedure DuplicatePosition1Click(Sender: TObject);
    procedure ClonePosition1Click(Sender: TObject);
    procedure Changepatternslength1Click(Sender: TObject);
    procedure Splitpattern1Click(Sender: TObject);
    procedure PositionColorBlackClick(Sender: TObject);
    procedure RedrawOff;
    procedure RedrawOn;
    procedure InsertPositionUpdate(Sender: TObject);
    procedure DeletePositionUpdate(Sender: TObject);
    procedure SyncCopyBuffersTimer(Sender: TObject);
    procedure PlayStopExecute(Sender: TObject);
    procedure PlayStopUpdate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure AutoStep0Execute(Sender: TObject);
    procedure AutoStep1Execute(Sender: TObject);
    procedure AutoStep2Execute(Sender: TObject);
    procedure AutoStep3Execute(Sender: TObject);
    procedure AutoStep4Execute(Sender: TObject);
    procedure AutoStep5Execute(Sender: TObject);
    procedure AutoStep6Execute(Sender: TObject);
    procedure AutoStep7Execute(Sender: TObject);
    procedure AutoStep8Execute(Sender: TObject);
    procedure AutoStep9Execute(Sender: TObject);
    procedure ExportToWAVExecute(Sender: TObject);
    procedure ExportToWAVUpdate(Sender: TObject);
    procedure NewTurbosoundExecute(Sender: TObject);
    procedure SaveAsTwoModulesUpdate(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure StopExecute(Sender: TObject);
    procedure Maximize1Execute(Sender: TObject);
    procedure NormalExecute(Sender: TObject);
    procedure PlayFromLineExecute(Sender: TObject);
    procedure SaveAsTwoModulesExecute(Sender: TObject);
    procedure PlayFromLineUpdate(Sender: TObject);
    procedure ToggleLoopingAllUpdate(Sender: TObject);
    procedure ToggleLoopingUpdate(Sender: TObject);
    procedure StopUpdate(Sender: TObject);
    procedure FileNew1Update(Sender: TObject);
    procedure FileOpen1Update(Sender: TObject);
    procedure FileClose1Update(Sender: TObject);
    procedure NewTurbosoundUpdate(Sender: TObject);
    procedure SwapChannelsLeft1Execute(Sender: TObject);
    procedure SwapChannelsRight1Execute(Sender: TObject);
    procedure SwapChannelsLeft1Update(Sender: TObject);
    procedure SwapChannelsRight1Update(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MultitrackReorder;
    procedure JoinTracksUpdate(Sender: TObject);
    procedure JoinTracksExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveAsTemplateUpdate(Sender: TObject);
    procedure SaveAsTemplateExecute(Sender: TObject);
    procedure UpdateDecHexValues;
    procedure DisableControlsForExport;
    procedure EnableControlsForExport;
    procedure MIDITimerTimer(Sender: TObject);
    procedure TransposeUp3Execute(Sender: TObject);
    procedure TransposeDown3Execute(Sender: TObject);
    procedure TransposeUp5Execute(Sender: TObject);
    procedure TransposeDown5Execute(Sender: TObject);
    procedure TransposeUp3Update(Sender: TObject);
    procedure TransposeDown3Update(Sender: TObject);
    procedure TransposeUp5Update(Sender: TObject);
    procedure TransposeDown5Update(Sender: TObject);
    procedure CopyToExtActUpdate(Sender: TObject);
    procedure CopyToExtActExecute(Sender: TObject);
    procedure PackPatternActExecute(Sender: TObject);
    procedure ExportPSGActExecute(Sender: TObject);
    procedure ExportPSGActUpdate(Sender: TObject);
    procedure StatusBarDblClick(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure CenteringTimerTimer(Sender: TObject);
    procedure Clearpatterns1Click(Sender: TObject);

  private
    { Private declarations }
    procedure CloseTemplateModule;
    procedure CreateMDIChild(const Name: string; Turbosound: Integer);
    procedure WMSysCommand(var Msg: TWMSysCommand);message WM_SYSCOMMAND;
    //procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    //procedure WMSizing(var Msg: TWMSize); message WM_SIZING;
    procedure WMPosChanging(var Msg: TWMWINDOWPOSCHANGING); message WM_WINDOWPOSCHANGING;
    //procedure WMWindowPosChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMDropFiles(var Msg: TWMDropFiles);message WM_DROPFILES;
    procedure WMDisplayChange(var Message: TWMDisplayChange);message WM_DISPLAYCHANGE;
    procedure WMUser(var Message:TMessage); message WM_USER;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    { Public declarations }
    PrevTop: Integer;
    WidthFix, HeightFix: Integer;
    SizeFixed: Boolean;
    SnapedToRight: Boolean;
    Snaped: Boolean;
    MaximizeChilds: Boolean;

    Tone_Table_On_Load: integer;
    EditorFont: TFont;
    TestLineFont: TFont;
    RecentFiles: array[0..5] of string;
    LoopAllAllowed: boolean;
    {
    // Sample templates is disabled now

    SampleLineTemplates: array of TSampleTick;
    CurrentSampleLineTemplate: integer;
    }
    GlobalVolume, GlobalVolumeMax: integer;
    DefaultTable: Smallint;
    StartupAction: Byte;
    StartupOpenModule: Boolean;
    StartupOpenTheme: Boolean;
    TemplateSongPath: string;
    WinThemeIndex: Integer;
//  samples and ornaments for global buffer, for copy/paste
    BuffSample: TSample;
    BuffOrnament: TOrnament;
    NumberOfLinesChanged: boolean;
    ResizeActionBlocked: boolean;
    SampleBrowserVisible, OrnamentsBrowserVisible: boolean;
    VTExit: boolean;
    LastChildWidth, LastChildHeight: Integer;
    SamplesDir, OrnamentsDir: String;
    RedrawEnabled: Boolean;
    ChildsTable: array of TMDIChild;

    DontAddToRecent: Boolean;
  end;



function IntelWord(a: word): word;

function GetCursorPos: TPoint;

type
  TLastClipboard = (LCNone, LCTracks, LCSamples, LCOrnaments);

  TTracksCopy = record
    SrcWindow: TMDIChild;
    Pattern: PPattern;
    PatNum: Integer;
    Channel: Byte;
    FromLine: Byte;
    ToLine: Byte;
    Ornament: Boolean;
    Command: Boolean;
  end;

  TSampleCopy = record
    SrcWindow: TMDIChild;
    Sample: PSample;
    FromColumn: Byte;
    ToColumn: Byte;
    FromLine: Byte;
    ToLine: Byte;
    StartColumn: Byte;
    StartLine: Byte;    
    Ready: Boolean;
  end;


var
  MainForm: TMainForm;
  Priority: dword = NORMAL_PRIORITY_CLASS;
  TracksCursorXLeft: Integer;
  OrnXShift: Integer;
  OrnNCol: Integer = 4;
  OrnNChars: Integer = 9;
  DisableUpdateChilds: Boolean;
  SyncMessageFile: string;
  SyncVTInstanses: boolean;
  SyncSampleBufferFile, SyncOrnamentBufferFile, SyncSamplePartFile: string;
  SyncSampleBufferFileAge, SyncOrnamentBufferFileAge, SyncSamplePartFileAge: Integer;
  SyncBufferBlocked: Boolean;
  ChildsEventsBlocked: Boolean;
  EditorFontChanged: Boolean;
  DisplayChanged: Boolean;
  ColorTheme: TColorTheme;
  ColorThemeName: String;
  CBackground, CSelLineBackground, CHighlBackground, COutBackground,
      COutHlBackground, CText, CSelLineText, CHighlText, COutText,
      CLineNum, CSelLineNum, CHighlLineNum, CEnvelope, CSelEnvelope, CNoise, CSelNoise,
      CNote, CSelNote, CNoteParams, CSelNoteParams, CNoteCommands,
      CSelNoteCommands, CSeparators, COutSeparators,
      CSamOrnBackground,  CSamOrnSelBackground, CSamOrnText, CSamOrnSelText,
      CSamOrnLineNum, CSamOrnSelLineNum, CSamNoise, CSamSelNoise,
      CSamOrnSeparators, CSamOrnTone, CSamOrnSelTone,
      CFullScreenBackground: TColor;

  NoteKeys: array[0..255] of shortint;
  Panoram: array[0..2] of Byte;
  VortexDir, VortexDocumentsDir, ConfigFilePath: String;

  EnvelopeAsNote: Boolean;
  DupNoteParams: Boolean;
  MoveBetweenPatrns: Boolean;
  SamToneShiftAsNote: Boolean;
  OrnToneShiftAsNote: Boolean;

  CenterOffset: Integer;
  PositionSize: Integer;
  DecBaseLinesOn: Boolean;
  DecBaseNoiseOn: Boolean;
  HighlightSpeedOn: Boolean;
  DisableSeparators: Boolean;
  AutoBackupsOn: Boolean;
  AutoBackupsMins: byte;
  DisableHints: Boolean;
  DisableCtrlClick: Boolean;
  DisableInfoWin: Boolean;
  DisableMidi: Boolean;
  VortexFirstStart: Boolean;
  ManualChipFreq: Integer;
  DefaultChipFreq: Integer;
  DefaultIntFreq: Integer;
  ExternalTracker: Integer;

  ExportSampleRate, ExportBitRate, ExportChannels, ExportChip, ExportRepeats: Integer;
  ExportPath: String;

  ChanAlloc: TChansArray;
  ChanAllocIndex: integer;
  ChanRemapPan: Boolean;

  SysCmd: Integer;
  WindowSnap, WindowUnsnap: Boolean;
  VScrollbarSize, HScrollbarSize: Integer;
  DrawOffAfterClose: Boolean;
  MoveShift: Integer;
  WinCount: Integer;
  FileAssocChanged: Boolean;
  SetChildAsTemplate: Boolean;

  LastClipboard: TLastClipboard;
  TracksCopy: TTracksCopy;
  SampleCopy: TSampleCopy;
  OrnamentCopySrcWindow: TMDIChild;

  SamplesQuickDir, OrnamentsQuickDir: String;

  DialogWinHandle: ^integer;
  CenterWinHandle: integer;

  {$IFDEF LOGGER}Logger: TLogger;{$ENDIF}

  FileAssociations: array[0..13, 0..3] of string =
  (
    ('1', '.vt2', 'VortexTracker2',      'VortexTracker 2 module'),
    ('1', '.vtt', 'VortexTracker2Theme', 'VortexTracker Color Theme'),
    ('0', '.pt1', 'ProTracker1',         'ProTracker 1 module'),
    ('0', '.pt2', 'ProTracker2',         'ProTracker 2 module'),
    ('0', '.pt3', 'ProTracker3',         'ProTracker 3 module'),
    ('0', '.ftc', 'FastTracker',         'Fast Tracker module'),
    ('0', '.stc', 'SoundTracker1',       'SoundTracker 1.X module'),
    ('0', '.stp', 'SoundTrackerPro',     'SoundTracker Pro module'),
    ('0', '.asc', 'ASCSoundMaster',      'ASC Sound Master module'),
    ('0', '.fls', 'FlashTracker',        'Flash Tracker module'),
    ('0', '.gtr', 'GlobalTracker',       'Global Tracker module'),
    ('0', '.psc', 'ProSoundCreator',     'Pro Sound Creator module'),
    ('0', '.psm', 'ProSoundMaker',       'Pro Sound Maker module'),
    ('0', '.sqt', 'SQTracker',           'SQ-Tracker module')
  );


implementation

{$R *.DFM}
{$J+} { Assignable Typed Constant }

uses About, options, TrkMng, GlbTrn, ExportZX, selectts, TglSams, HotKeys,
  Math, Types, InstrumentsPack, Registry, ShlObj, StrUtils, ClipBrd;

type
  TStr4 = array[0..3] of char;


const
  TSData2: packed record
    Type1: TStr4; Size1: word;
    Type2: TStr4; Size2: word;
    TSID: TStr4;
  end = (Type1: 'PT3!'; Type2: 'PT3!'; TSID: '02TS');

  TSData3: packed record
    Type0: TStr4; Size0: word;
    Type1: TStr4; Size1: word;
    Type2: TStr4; Size2: word;
    TSID: TStr4;
  end = (Type0: 'PT3!'; Type1: 'PT3!'; Type2: 'PT3!'; TSID: '03TS');

var
  LibHandle: THandle;
  AddFontMemResource: function (p1: Pointer; p2: Cardinal; p3: PDesignVector; p4: PDWORD): Cardinal; stdcall;



function UnderWine: Boolean;
const
  IsWine: Boolean = False;
  Detected: Boolean = False;
var
  H: Cardinal;
begin
  if Detected then begin
    Result := IsWine;
    Exit;
  end;
  Result := False;
  H := LoadLibrary('ntdll.dll');
  if H > HINSTANCE_ERROR then
    begin
      Result := Assigned(GetProcAddress(H, 'wine_get_version'));
      FreeLibrary(H);
    end;
  IsWine   := Result;
  Detected := True;
end;

function GetCursorPos: TPoint;
var
  CurDesktop: HDESK;
begin
  if UnderWine then
   begin
    result:=Mouse.CursorPos;
    exit;
   end;
  CurDesktop := OpenInputDesktop(0, false, DESKTOP_READOBJECTS); //wine doesn't support that
  try
    if CurDesktop > 0 then
      Win32Check(Windows.GetCursorPos(Result))
    else
      Result := Point(0, 0);
  finally
    CloseDesktop(CurDesktop);
  end;
end;


function GetUserDocumentsDir: string;
var
  FilePath: array [0..MAX_PATH] of char;
begin
  ShGetSpecialFolderPath(0, FilePath, CSIDL_PERSONAL, False);
  Result := FilePath;
end;


function TMainForm.IsFileWritable(FilePath: String): Boolean;
var attrs: Integer;
begin
  {$WARN SYMBOL_PLATFORM OFF}
  Result := True;

  // File doesn't exists
  if not FileExists(FilePath) then Exit;

  // Get current file attributes
  attrs  := FileGetAttr(FilePath);

  if attrs and faReadOnly > 0 then begin
    // Try to unset read only attribute
    FileSetAttr(FilePath, attrs and not faReadOnly);

    // And check for read only again
    if FileGetAttr(FilePath) and faReadOnly > 0 then begin
      Application.MessageBox(PChar('File "'+ ExtractFilename(FilePath) +'" is read only.'), 'Vortex Tracker',
        MB_OK + MB_ICONSTOP + MB_TOPMOST);
        Result := False;
    end;

  end;
  {$WARN SYMBOL_PLATFORM ON}
end;


function TMainForm.VScrollVisible(NewHeight: Integer): Boolean;
var i: Integer;
begin

  for i := 0 to MDIChildCount-1 do with TMDIChild(MDIChildren[i]) do
    if Top < 0 then begin
      Result := True;
      Exit;
    end;

  Result := Top + ChildsBottom + OuterHeight + ToolBar2.Height + StatusBar.Height - 6 > Monitor.WorkareaRect.Bottom;

end;



function TMainForm.HScrollVisible(NewLeft: Integer): Boolean;
var i: Integer;
begin
  if MDIChildCount < 2 then begin
    Result := False;
    Exit;
  end;

  for i := 0 to MDIChildCount-1 do with TMDIChild(MDIChildren[i]) do
    if Left < 0 then begin
      Result := True;
      Exit;
    end;

  Result := NewLeft + ChildsRight {+ BorderSize} > Monitor.WorkareaRect.Right;

end;


function TMainForm.VScrollSize(NewHeight: Integer): Integer;
begin
  if VScrollVisible(NewHeight) then
    Result := VScrollbarSize
  else
    Result := 0;
end;


function TMainForm.HScrollSize(NewLeft: Integer): Integer;
begin
  if HScrollVisible(NewLeft) then
    Result := HScrollbarSize
  else
    Result := 0;
end;


function TMainForm.BorderSize: Integer;
const Value: Integer = 0;
begin
  if Value = 0 then Value := ((Width - ClientWidth) div 2);
  Result := Value;
end;


function TMainForm.DoubleBorderSize: Integer;
const Value: Integer = 0;
begin
  if Value = 0 then Value := Width - ClientWidth;
  Result := Value;
end;


function TMainForm.AbsTop: Integer;
begin
  Result := Top - Monitor.WorkareaRect.Top;
end;


function TMainForm.OuterHeight: Integer;
const Value: Integer = 0;
begin
  if Value = 0 then Value := Height - ClientHeight;
  Result := Value;
end;



function TMainForm.MonitorWorkAreaWidth: Integer;
const
  MonitorNum: Integer = -1;
  Value: Integer = 0;

begin
  if (MonitorNum = Monitor.MonitorNum) and not DisplayChanged then begin
    Result := Value;
    Exit;
  end;
  MonitorNum := Monitor.MonitorNum;
  Value  := Monitor.WorkareaRect.Right - Monitor.WorkareaRect.Left;
  Result := Value;
end;


function TMainForm.MonitorWorkAreaHeight: Integer;
const
  MonitorNum: Integer = -1;
  Value: Integer = 0;

begin
  if (MonitorNum = Monitor.MonitorNum) and not DisplayChanged then begin
    Result := Value;
    Exit;
  end;
  MonitorNum := Monitor.MonitorNum;
  Value  := Monitor.WorkareaRect.Bottom - Monitor.WorkareaRect.Top;
  Result := Value;
end;



function TMainForm.WorkAreaHeight(NewHeight: Integer): Integer;
begin
  Result := NewHeight - ToolBar2.Height - StatusBar.Height - 5;
end;


function TMainForm.OneTrack: Boolean;
begin
  Result := (MDIChildCount = 1) or ((MDIChildCount = 2) and (TMDIChild(ActiveMDIChild).TSWindow[0] <> nil))
  or ((MDIChildCount = 3) and (TMDIChild(ActiveMDIChild).TSWindow[0] <> nil) and (TMDIChild(ActiveMDIChild).TSWindow[1] <> nil));
end;


function TMainForm.ResizeChildsHeight: Boolean;
var i: Integer;
begin

  Result := OneTrack;
  if Result then Exit;

  Result := True;
  for i := 0 to MDIChildCount-1 do
    if TMDIChild(MDIChildren[i]).Top <> 0 then begin
      Result := False;
      Exit;
    end;

end;


function TMainForm.ChildsWidth: Integer;
var
 ChildCount: Integer;
begin
  ChildCount := MDIChildCount;

  if ChildCount = 0 then
    Result := LastChildWidth
  else if ChildCount = 1 then
    Result := TMDIChild(MDIChildren[0]).PageControl1.Width
  else
    Result := TMDIChild(MDIChildren[0]).Width * ChildCount + 5;

end;


function TMainForm.ChildsRight: Integer;
var
  i, ChildsCount, Right: Integer;
begin

  ChildsCount := MDIChildCount;

  if ChildsCount = 0 then
    Result := LastChildWidth
  else if ChildsCount = 1 then
    Result := TMDIChild(MDIChildren[0]).PageControl1.Width
  else
  begin
    Result := 0;
    for i := 0 to ChildsCount-1 do begin
      Right := TMDIChild(MDIChildren[i]).Left + TMDIChild(MDIChildren[i]).Width;
      if Right > Result then Result := Right;
    end;
    Inc(Result, 5);
  end;

end;



function TMainForm.ChildsBottom: Integer;
var
  i, ChildsCount, Bottom: Integer;
begin

  ChildsCount := MDIChildCount;

  if ChildsCount = 0 then
    Result := LastChildHeight
  else if ChildsCount = 1 then
    Result := TMDIChild(MDIChildren[0]).PageControl1.Height
  else
  begin
    Result := 0;
    for i := 0 to ChildsCount-1 do begin
      Bottom := TMDIChild(MDIChildren[i]).Top + TMDIChild(MDIChildren[i]).Height;
      if Bottom > Result then Result := Bottom;
    end;
    Inc(Result, 5);
  end;

end;


function TMainForm.ChildsMaxHeight: Integer;
var
  i: Integer;
  Heights: array of Integer;
begin

  if MDIChildCount = 1 then begin
    Result := TMDIChild(MDIChildren[0]).PageControl1.Height;
    Exit;
  end;

  SetLength(Heights, MDIChildCount);

  for i := 0 to MDIChildCount-1 do
    Heights[i] := TMDIChild(MDIChildren[i]).Height;

  Result := MaxIntValue(Heights);

end;




procedure TMainForm.SetWidth(Value: Integer; Fixed: Boolean);
var Flag: Boolean;
begin
  Flag := ResizeActionBlocked;
  ResizeActionBlocked := True;

  ResetConstraints(False);

  ClientWidth := Value;
  if Fixed then begin
    Constraints.MaxWidth := Value + DoubleBorderSize;
    Constraints.MinWidth := Value + DoubleBorderSize;
  end;

  ResizeActionBlocked := Flag;
end;



procedure TMainForm.FixWidth;
begin
  Constraints.MaxWidth := Width;
  Constraints.MinWidth := Width;
end;


procedure TMainForm.ResetConstraints(CalculateMinWidth: Boolean);
var
  RightX: Integer;
begin

  Constraints.MaxWidth  := 0;
  Constraints.MaxHeight := 0;
  Constraints.MinWidth  := 0;
  Constraints.MinHeight := 570;

  if MDIChildCount < 2 then Exit;
  if not CalculateMinWidth then Exit;
  if ChildsWidth > ClientWidth then Exit;

  RightX := ChildsRight - 5;
  if RightX + DoubleBorderSize + 5 <= MonitorWorkAreaWidth then
    Constraints.MinWidth := RightX + DoubleBorderSize + 5
  else
    Constraints.MinWidth := MonitorWorkAreaWidth;


end;



function TMainForm.IsShortCut(var Message: TWMKey): Boolean;
begin

  if (MDIChildCount <> 0) and (TMDIChild(ActiveMDIChild).ActiveControl is TCustomEdit) and (Message.CharCode <> 27) then
  begin
    Result := False;
  end
  else
    Result := inherited IsShortCut(Message)

end;


function IsFontExists(FontName: string): Boolean;
var i: Integer;
begin

  if Win32MajorVersion > 4 then
    for i := 0 to High(InternalFonts) do
      if InternalFonts[i][1] = FontName then
      begin
        Result := True;
        Exit;
      end;

  Result := Screen.Fonts.IndexOf(FontName) <> -1;

end;


function LoadResourceFont(ResourceName, FontName: string) : boolean;
var
  ResStream : tResourceStream;
  FontsCount : integer;
  hFont : tHandle;
begin
  if Screen.Fonts.IndexOf(FontName) <> -1 then begin
    Result := True;
    Exit;
  end;
  ResStream := tResourceStream.Create(hInstance, ResourceName, RT_RCDATA);
  hFont := AddFontMemResource(ResStream.Memory, ResStream.Size, nil, @FontsCount);
  result := (hFont <> 0);
  ResStream.Free();
end;


function LoadAndSaveResourceFont(ResourceName, FontName: string) : boolean;
var
   ResStream : tResourceStream;
   FontPath: string;

begin

  Result := True;
  if Screen.Fonts.IndexOf(FontName) <> -1 then Exit;

  if not DirectoryExists(VortexDir + FontsDir) then
    ForceDirectories(VortexDir + FontsDir);

  FontPath := VortexDir + FontsDir +'\'+ ResourceName +'.ttf';
  ResStream := tResourceStream.Create(hInstance, ResourceName, RT_RCDATA);
  if not FileExists(FontPath) then
    ResStream.SavetoFile(FontPath);
  AddFontResource(PChar(FontPath));
  SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
  ResStream.Free();
end;


function GetWin(Comand: string): string;
var
  buff: array [0 .. $FF] of char;
begin
  ExpandEnvironmentStrings(PChar(Comand), buff, SizeOf(buff));
  Result := buff;
end;


function TMainForm.NoPatterns: Boolean;
begin
  Result := False;
  if TMDIChild(ActiveMDIChild).VTMP.Positions.Length = 0 then Result := True;
  if (TMDIChild(ActiveMDIChild).TSWindow[0] <> nil) and (TMDIChild(ActiveMDIChild).TSWindow[0].VTMP.Positions.Length = 0) then Result := True;
  if (TMDIChild(ActiveMDIChild).TSWindow[1] <> nil) and (TMDIChild(ActiveMDIChild).TSWindow[1].VTMP.Positions.Length = 0) then Result := True;
end;

procedure TMainForm.SetChildsTab(Tab: Integer);
var i: Integer;
begin

  for i := 0 to MDIChildCount-1 do
    with TMDIChild(MDIChildren[i]) do
      if (PageControl1.ActivePage = OrnamentsSheet) and (Tab = 2) then
        PageControl1.ActivePageIndex := 2
      else
        PageControl1.ActivePageIndex := Tab-1;

{  for i := 0 to MDIChildCount-1 do
    with TMDIChild(MDIChildren[i]) do
      if (PageControl1.ActivePage = PatternsSheet) and (Tab <> 1) then
        PageControl1.ActivePage := SamplesSheet
      else
        PageControl1.ActivePage := PatternsSheet;    }


   {   case Tab of
        1: PageControl1.ActivePage := PatternsSheet;
        2: PageControl1.ActivePage := SamplesSheet;
      end;    }
    
end;



function IntelWord(a: word): word;
asm
xchg al,ah
end;



procedure initBuffSample;
begin
  MainForm.BuffSample.Length := 1;
  MainForm.BuffSample.Loop := 0;
  MainForm.BuffSample.Items[0].Add_to_Ton := 0;
  MainForm.BuffSample.Items[0].Add_to_Ton := 0;
  MainForm.BuffSample.Items[0].Ton_Accumulation := False;
  MainForm.BuffSample.Items[0].Amplitude := 0;
  MainForm.BuffSample.Items[0].Amplitude_Sliding := False;
  MainForm.BuffSample.Items[0].Amplitude_Slide_Up := False;
  MainForm.BuffSample.Items[0].Envelope_Enabled := False;
  MainForm.BuffSample.Items[0].Envelope_or_Noise_Accumulation := False;
  MainForm.BuffSample.Items[0].Add_to_Envelope_or_Noise := 0;
  MainForm.BuffSample.Items[0].Mixer_Ton := False;
  MainForm.BuffSample.Items[0].Mixer_Noise := False;
end;

procedure initBuffOrnament;
begin
  MainForm.BuffOrnament.Length := 1;
  MainForm.BuffOrnament.Loop := 0;
  MainForm.BuffOrnament.Items[0] := 0;
end;

procedure initBuffTracks;
begin
  TracksCopy.Pattern  := nil;
  TracksCopy.Channel  := 0;
  TracksCopy.FromLine := 0;
  TracksCopy.ToLine   := 0;
  SampleCopy.Ready := False;
end;



function TMainForm.GetSizeForChilds(MainWindowState: TWindowState; MoveChild: Boolean): TSize;
var
  ChildCount: Integer;
  MonitorRect: TRect;

  procedure AlignRightSnaped(var NewSize: TSize);
  begin
    if SnapedToRight and (Result.Left + Result.Width + DoubleBorderSize < MonitorRect.Right) then
      NewSize.Left := MonitorRect.Right - Result.Width - BorderSize - 1;
  end;

begin
  ChildCount := MDIChildCount;
  MonitorRect := Monitor.WorkareaRect;

  Result.Top    := Top;
  Result.Left   := Left;
  Result.Width  := ClientWidth;
  Result.Height := ClientHeight;

  if ((ChildCount = 0) and (LastChildHeight = 0)) or (MainWindowState = wsMaximized) then Exit;
  
  if (ChildCount = 0)  and (LastChildWidth <> 0) then
    Result.Width  := LastChildWidth;

  if ChildCount = 1 then
    Result.Width  := TMDIChild(MDIChildren[0]).PageControl1.Width;

  AlignRightSnaped(Result);
  if ChildCount < 2 then Exit;


  // ChildCount > 1

  if MoveChild then begin
    Result.Width  := ChildsRight;
    Result.Height := ChildsBottom + ToolBar2.Height + StatusBar.Height;
  end
  else
    Result.Width  := ChildsWidth;


  if not MoveChild and not WindowUnsnap and (SysCmd <> SC_RESTORE) then begin

    if Left + Result.Width + DoubleBorderSize > MonitorRect.Right then
    
      if Result.Width + DoubleBorderSize > MonitorWorkAreaWidth then begin
        Result.Left := MonitorRect.Left - BorderSize + 1;
        Result.Width := MonitorWorkAreaWidth;
      end
      else
        Result.Left := MonitorRect.Right - Result.Width - BorderSize - 1;

  end;


  AlignRightSnaped(Result);


  if MoveChild then begin

    Inc(Result.Width,  VScrollSize(Result.Height));
    Inc(Result.Height, HScrollSize(Result.Left));

    if (Result.Left + Result.Width + BorderSize > MonitorRect.Right - 2) then
      Result.Width := MonitorRect.Right - Result.Left - BorderSize - 2;

    if (Result.Top + Result.Height + OuterHeight > MonitorRect.Bottom - 2) then
      Result.Height := MonitorRect.Bottom - Result.Top - OuterHeight + BorderSize - 2;

    if not EditorFontChanged and (Result.Width < ClientWidth)   then Result.Width  := ClientWidth;
    if not EditorFontChanged and (Result.Height < ClientHeight) then Result.Height := ClientHeight;

  end;

end;


procedure TMainForm.SetWindowSize(NewSize: TSize);
var
  Flag: Boolean;
  wp : TWindowPlacement;
begin
  Flag := ResizeActionBlocked;
  ResizeActionBlocked := True;
  ResetConstraints(False);

  if (Left <> NewSize.Left) or (Top <> NewSize.Top) then begin
    Left := NewSize.Left;
    Top  := NewSize.Top;
  end;

  if SizeFixed then begin
    WidthFix := NewSize.Width + DoubleBorderSize;
    HeightFix := NewSize.Height + OuterHeight;
  end;

  if (ClientWidth <> NewSize.Width) or (ClientHeight <> NewSize.Height) then
  begin
    if MDIChildCount = 1 then
      SetWidth(NewSize.Width, True)
    else
      ClientWidth  := NewSize.Width;
    ClientHeight := NewSize.Height;
  end;

  if WindowSnap then begin
    wp.length := SizeOf(wp);
    GetWindowPlacement(Handle, @wp);
    wp.rcNormalPosition := BoundsRect;
    SetWindowPlacement(Handle, @wp);
  end;

  StatusBar.Panels[0].Width := ClientWidth - StatusBar.Panels[1].Width - StatusBar.Panels[2].Width - 8;
  ResizeActionBlocked := Flag;
end;


procedure TMainForm.AddWindowListItem(Child: TMDIChild);
begin
  SetLength(ChildsTable, Length(ChildsTable)+1);
  ChildsTable[High(ChildsTable)] := Child;
end;


procedure TMainForm.DeleteWindowListItem(Child: TMDIChild);
var
  i, j, k: integer;
begin

  // Remove child
  for i := 0 to High(ChildsTable) do
    if ChildsTable[i] = Child then
    begin
      // Remove turbotrack window
      for j := 0 to High(ChildsTable) do
        if ChildsTable[i] = Child.TSWindow[0] then
        begin
          ChildsTable[i] := nil;
          Break;
        end;

      // Remove third turbotrack window
      for j := 0 to High(ChildsTable) do
        if ChildsTable[i] = Child.TSWindow[1] then
        begin
          ChildsTable[i] := nil;
          Break;
        end;
      ChildsTable[i] := nil;
      Break;
    end;


  // remove spaces
  j := 0;
  i := 0;
  k := High(ChildsTable)+1;
  while i<k do
  begin
    while (ChildsTable[j] = nil) and (j<k) do inc(j);
    if (j<k) and (j>i) then ChildsTable[i] := ChildsTable[j];
    inc(i);
    inc(j);
  end;
  SetLength(ChildsTable, Length(ChildsTable)-(j-i))


end;


procedure TMainForm.AutoMetrixForChilds(MainWindowState: TWindowState);
var
  i, ChildCount: Integer;
  c: TMDIChild;
  PrevEventsFlag: Boolean;
  MonitorRect: TRect;
begin

  ChildCount := MDIChildCount;
  if ChildCount = 0 then Exit;
  
  PrevEventsFlag := ChildsEventsBlocked;
  ChildsEventsBlocked := True;
  
  MonitorRect := Monitor.WorkareaRect;

  // Just one child window - forced maximization & no sizeable
  if (ChildCount = 1) then with TMDIChild(MDIChildren[0]) do begin
    if Closed then Exit;
    Constraints.MaxWidth := 0;
    Constraints.MinWidth := 0;    
    BorderStyle := bsSingle;
    WindowState := wsMaximized;
  end

  // If num childs > 1, then set wsNormal state & sizeable
  else
    for i := 0 to ChildCount-1 do with TMDIChild(MDIChildren[i]) do begin
      if Closed then Continue;
      WindowState := wsNormal;
      BorderStyle := bsSizeable;
    end;


  // Just one child
  if ChildCount = 1 then
    begin

    // Just one child & main window in maximized state:
    if MainWindowState = wsMaximized then
    begin
      c := TMDIChild(MDIChildren[0]);
      if c.Closed then Exit;
      c.DisableAlign;

      c.PageControl1.Top  := 10;
      c.PageControl1.Left := (Width div 2) - (c.PageControl1.Width div 2);
      c.PageControl1.Height := WorkAreaHeight(ClientHeight) - c.PageControl1.Top - 7;

      c.TopBackgroundBox.Left    := c.PageControl1.Left;
      c.TopBackgroundBox.Width   := c.PageControl1.Width;
      c.TopBackgroundBox.Visible := True;

      c.HeightChanged := c.LastHeight <> c.PageControl1.Height;
      c.LastHeight := c.PageControl1.Height;
      c.EnableAlign;
    end

    else

    // Just one child & window state = normal
    begin
      c := TMDIChild(MDIChildren[0]);
      if c.Closed then Exit;

      c.DisableAlign;
      c.PageControl1.Left := 0;
      c.PageControl1.Top  := 10;
      c.PageControl1.Height := WorkAreaHeight(ClientHeight) - c.PageControl1.Top + 5;
      c.HeightChanged := c.LastHeight <> c.PageControl1.Height;
      c.LastHeight := c.PageControl1.Height;
      c.TopBackgroundBox.Left    := 0;
      c.TopBackgroundBox.Width   := c.PageControl1.Width;
      c.TopBackgroundBox.Visible := True;
      c.EnableAlign;

    end;
//    c.Panel16.Left := 456 + c.PageControl1.Left;
//    c.Panel17.Left := 456 + c.PageControl1.Left + c.Panel16.Width+1;
    c.Panel16.Left := c.PageControl1.Left+c.PageControl1.Width-c.Panel16.Width*2-16;
    c.Panel17.Left := c.Panel16.Left + c.Panel16.Width+2;
  end
  else

    // Childs count > 1
    for i := 0 to MDIChildCount-1 do
    begin
      c := TMDIChild(MDIChildren[i]);
      if c.Closed then Continue;

      ChildsEventsBlocked := True;

      c.DisableAlign;
      c.PageControl1.Left := 0;
      c.PageControl1.Top  := 0;

//      c.Panel16.Left := 456 + c.PageControl1.Left;
//      c.Panel17.Left := 456 + c.PageControl1.Left + c.Panel16.Width+1;
      c.Panel16.Left := c.PageControl1.Left+c.PageControl1.Width-c.Panel16.Width*2-16;
      c.Panel17.Left := c.Panel16.Left + c.Panel16.Width+2;

      c.TopBackgroundBox.Visible := False;
      c.SetWidth(c.PageControl1.Width, True);

      if MaximizeChilds then
        c.Height := WorkAreaHeight(ClientHeight) - c.Top;

      c.PageControl1.Height := c.ClientHeight;
      c.HeightChanged := c.LastHeight <> c.PageControl1.Height;
      c.LastHeight := c.PageControl1.Height;

      c.EnableAlign;
      ChildsEventsBlocked := False;

    end;

  LastChildWidth := TMDIChild(MDIChildren[0]).PageControl1.Width;
  LastChildHeight := ChildsMaxHeight;
  
  ChildsEventsBlocked := PrevEventsFlag;

end;


procedure TMainForm.AutoCutChilds(NewSize: TSize);
var
  i: Integer;
  c: TMDIChild;
  
begin
  if MDIChildCount < 2 then Exit;
  if not HScrollVisible(NewSize.Left) then Exit;
  if ChildsWidth <= NewSize.Width then Exit;

  // Fix childs extra height
  for i := 0 to MDIChildCount-1 do
  begin
    c := TMDIChild(MDIChildren[i]);
    if c.Top + c.Height > WorkAreaHeight(NewSize.Height) - HScrollbarSize then
    begin
      c.Height := WorkAreaHeight(NewSize.Height) - HScrollbarSize - c.Top;
      c.PageControl1.Height := c.ClientHeight;
      c.HeightChanged := True;
      if EditorFontChanged then c.AutoResizeForm;
    end;
  end;

end;


procedure TMainForm.AutoToolBarPosition(NewSize: TSize);
const MaxTrackBarWidth = 250;
var
  ToolBarWidth: Integer;
  c: TMDIChild;
begin

  if (MDIChildCount < 2) and (WindowState <> wsMaximized) then begin
    ToolBar2.Indent := 0;
    Exit;
  end;

  if MDIChildCount = 1 then begin
    c := TMDIChild(MDIChildren[0]);
    ToolBar2.Indent := c.PageControl1.Left - 2;
    Exit;
  end;

  // Set toolbar to main window center
  ToolBarWidth := TrackBar1.Left + TrackBar1.Width - ToolBar2.Indent;
  ToolBar2.Indent := (NewSize.Width div 2) - (ToolBarWidth div 2);

end;


procedure TMainForm.SetChildsPosition(MainWindowState: TWindowState);
var
  i, j, PrevChildRightCorner: Integer;
  PrevEventsFlag: Boolean;
  tmpMDIchild: TMDIChild;

begin
  if MDIChildCount < 2 then Exit;

  PrevChildRightCorner := 0;
  PrevEventsFlag := ChildsEventsBlocked;
  ChildsEventsBlocked := True;

  //reorder
  for i := 0 to High(ChildsTable) do
    for j := i+1 to High(ChildsTable) do
      if ChildsTable[i].Left>ChildsTable[j].Left then
       begin
        tmpMDIchild := ChildsTable[i];
        ChildsTable[i] := ChildsTable[j];
        ChildsTable[j] := tmpMDIchild;
       end;

  if (MainWindowState = wsMaximized) and (ChildsWidth < ClientWidth)  then
    PrevChildRightCorner := (ClientWidth div 2) - (ChildsWidth div 2);

  for i := 0 to High(ChildsTable) do
    if ChildsTable[i] <> nil then
      with ChildsTable[i] do
      begin
        if Closed then Continue;
        Top := 0;
        Left := PrevChildRightCorner;
        PrevChildRightCorner := PrevChildRightCorner + Width;
      end;

  ChildsEventsBlocked  := PrevEventsFlag;

end;



procedure TMainForm.CreateChildWrapper(const Name: string);
begin
  if (Name <> '') and not FileExists(Name) then
  begin
    MessageBox(Handle, PChar('File not found: "'+ Name +'"'), 'Can''t open file', MB_OK +
       MB_ICONWARNING + MB_TOPMOST);
    Exit;
  end;
  RedrawOff;
  CreateMDIChild(Name, 1);
  RedrawOn;
end;



procedure TMainForm.CloseTemplateModule;
var
  Child: TMDIChild;
begin

  if Length(ChildsTable) = 0 then Exit;  
  if ChildsTable[0] = nil then Exit;
  if not ChildsTable[0].IsTemplate then Exit;


  Child := ChildsTable[0];

  // Don't kill window if SongChanged OR playing right now
  Child.IsTemplate := not (Child.SongChanged or Child.Tracks.IsTrackPlaying);

  if Child.IsTemplate then begin
    // Otherwise... say bye-bye to window

    if Child.TSWindow[1] <> nil then begin
      DrawOffAfterClose := True;
      Child.TSWindow[1].Free;
      ChildsTable[2] := nil;
    end;

    if Child.TSWindow[0] <> nil then begin
      DrawOffAfterClose := True;
      Child.TSWindow[0].Free;
      ChildsTable[1] := nil;
    end;

    DrawOffAfterClose := True;
    Child.Free;
//    ChildsTable[0] := nil;
    RedrawOff;
  end;


end;




procedure TMainForm.CreateMDIChild(const Name: string; Turbosound: Integer);
var
  Child: TMDIChild;
  Ok: boolean;
  VTMP2,VTMP3: PModule;
  i, numb, InitLeft: integer;
  NewSize: TSize;
  OpenedFiles: TStringList;

begin

  // --- Check is module already opened

  // Create list of opened files
  OpenedFiles            := TStringList.Create;
  OpenedFiles.Sorted     := True;
  OpenedFiles.Duplicates := dupIgnore;

  for i := 0 to MDIChildCount - 1 do begin
    Child := TMDIChild(MDIChildren[i]);
    if Child.WinFileName <> '' then
      OpenedFiles.Add(Child.WinFileName);
  end;

  // Check if file already opened
  for i := 0 to OpenedFiles.Count - 1 do begin
    if OpenedFiles[i] = Name then begin
      Application.MessageBox(PChar('Module "'+ ExtractFilename(Name) +'"is already opened.'), 'Vortex Tracker',
        MB_OK + MB_ICONINFORMATION);
      OpenedFiles.Free;
      Exit;
    end;
  end;

  OpenedFiles.Free;

  // Create MDIChild
  Inc(WinCount);
  ChildsEventsBlocked := True;
  ResizeActionBlocked := True;
  VTMP2 := nil;
  VTMP3 := nil;

  if (MDIChildCount = 1) and (Turbosound = 1) then with TMDIChild(MDIChildren[0]) do begin

    WindowState  := wsNormal;
    BorderStyle  := bsSizeable;

    PageControl1.Left := 0;
    PageControl1.Top  := 0;

    Height := WorkAreaHeight(MainForm.ClientHeight);
    PageControl1.Height := ClientHeight;
    ClientWidth := PageControl1.Width;
    LastChildHeight := Height;

    ResetConstraints(False);
  end;

  // Close unchanged & unplaying template song
  CloseTemplateModule;

  for i := 0 to 2 do
  begin

    // Create a new child
    Child := TMDIChild.Create(Application);
    Child.Top := 0;
    if i=0 then InitLeft:=Child.Left
    else Child.Left := InitLeft + i*20;
    if (WindowState = wsNormal) and (LastChildHeight <> 0) and (MDIChildCount > 1) then begin
      Child.Height := LastChildHeight;
      Child.PageControl1.Height := Child.ClientHeight;
    end;
    if (WindowState = wsNormal) and (MDIChildCount = 1) then begin
      Child.Height := WorkAreaHeight(ClientHeight) + 5;
      Child.PageControl1.Height := Child.ClientHeight;
      LastChildHeight := Child.Height;
    end;

    // Some initial shit
    Child.WinNumber := MDIChildCount;
    Child.Caption := 'New module ' + IntToStr(WinCount);
    Child.EnvelopeAsNoteOpt.Checked := EnvelopeAsNote;
    DrawOffAfterClose := False;
    AddWindowListItem(Child);


    // Load module
    Ok := True;

    if Name = '' then begin
      Child.VTMP.Positions.Length := 1;
      Child.ValidatePattern2(0);
    end;

    if (Name <> '') then
    begin
     if FileExists(Name) then
       Ok := Child.LoadTrackerModule(Name, i, numb, VTMP2, VTMP3);
    end
     else numb := Turbosound;

    // Shit happens
    if not Ok then begin
      DeleteWindowListItem(Child);
      Child.Close;
      Dec(WinCount);
      ChildsEventsBlocked := False;
      ResizeActionBlocked := False;
      Exit;
    end;

    if i+1 >= numb then break;
    // VTMP2=nil means non-turbotrack
//    if (VTMP2 = nil) and (VTMP3 = nil) and (not Turbosound) then Break;
//    if (VTMP3 = nil) and (not Turbosound) then Break;
  end;

  if (Name = '') then begin
    Child.VTMP.Positions.Length := 1;
    if Child.TSWindow[0] <> nil then Child.TSWindow[0].VTMP.Positions.Length := 1;
    if Child.TSWindow[1] <> nil then Child.TSWindow[1].VTMP.Positions.Length := 1;
  end;

  if (VTMP2 <> nil) or (VTMP3 <> nil) or (Turbosound > 1) then
  begin
    Child.NumModule := 1;
    Child.InitTrack;
    Child.TSWindow[0] := ChildsTable[High(ChildsTable)-1];
    Child.TSWindow[0].TSWindow[0] := Child; //self
    Child.TSWindow[0].TSWindow[1] := nil;
    Child.TSWindow[0].InitTrack;
    Child.TSWindow[0].NumModule := 2;
    if (VTMP3 <> nil) or (Turbosound = 3) then //third
    begin
      Child.TSWindow[1] := ChildsTable[High(ChildsTable)-2];
      Child.TSWindow[1].TSWindow[0] := Child;
      Child.TSWindow[1].TSWindow[1] := Child.TSWindow[0];
      Child.TSWindow[0].TSWindow[1] := Child.TSWindow[1];
      Child.TSWindow[1].InitTrack;
      Child.TSWindow[1].NumModule := 3;
    end;
  end
  else
    Child.InitTrack;

  // Accept to show new child
  AutoMetrixForChilds(WindowState);
  SetChildsPosition(WindowState);
  NewSize := GetSizeForChilds(WindowState, False);
  AutoToolBarPosition(NewSize);
  AutoCutChilds(NewSize);
  RedrawChilds;
  SetWindowSize(NewSize);

  if HScrollVisible(Left) then
    PostMessage(ClientHandle, WM_HSCROLL, SB_RIGHT, 0);


  if MDIChildCount > 0 then begin
    Child.InitFinished := True;
    if Child.TSWindow[0] <> nil then Child.TSWindow[0].InitFinished := True;
    if Child.TSWindow[1] <> nil then Child.TSWindow[1].InitFinished := True;
  end;

//  if VTMP2<>nil then FreeVTMP(VTMP2);
//  if VTMP3<>nil then FreeVTMP(VTMP3);

  ChildsEventsBlocked := False;
  ResizeActionBlocked := False;
  JoinTracksUpdate(Self);

end;



procedure TMainForm.FileNew1Execute(Sender: TObject);
begin

  if ExportStarted then Exit;

  if (
    (Length(ChildsTable) > 0) and
    (ChildsTable[0] <> nil) and
    (ChildsTable[0].IsTemplate)
  )
  then ChildsTable[0].IsTemplate := False;

  CreateChildWrapper('');
end;

procedure TMainForm.FileOpen1Execute(Sender: TObject);
var
  i: integer;
  OpenPath: string;
begin

  if ExportStarted then Exit;

  if (RecentFiles[0] <> '') then
  begin
    OpenPath := ExtractFilePath(RecentFiles[0]);
    if DirectoryExists(OpenPath) then
      OpenDialog.InitialDir := OpenPath;
  end;

  CenterWinHandle := MainForm.handle;
  DialogWinHandle := @OpenDialog.Handle;
  CenteringTimer.Enabled := True;

  if OpenDialog.Execute then
  begin
    RedrawOff;
    ChildsEventsBlocked := True;
    i := OpenDialog.Files.Count - 1;
    if i > 16 then i := 16;
    for i := i downto 0 do CreateMDIChild(OpenDialog.Files.Strings[i], 1);
    ChildsEventsBlocked := False;
    RedrawOn;
  end;

end;

procedure TMainForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.UnpackSamples;
var
  i: Integer;
  SamplesDir, SampleDir, SampleFilePath: String;
  ResStream: TResourceStream;

begin

  SamplesDir := VortexDocumentsDir + SamplesDefaultDir;
  if DirectoryExists(SamplesDir) then
    Exit
  else
    ForceDirectories(SamplesDir);

  for i := 0 to High(SampleResources) do
  begin
    SampleDir := SamplesDir + '\' + SampleResources[i][0];
    SampleFilePath := SampleDir +'\'+ SampleResources[i][1] + '.vts';

    if not DirectoryExists(SampleDir) then
      ForceDirectories(SampleDir);

    if FileExists(SampleFilePath) then
      Continue;

    ResStream := TResourceStream.Create(HInstance, SampleResources[i][1], RT_RCDATA);
    try
      ResStream.Position := 0;
      ResStream.SaveToFile(SampleFilePath);
    finally
      ResStream.Free;
    end;

  end;

end;

procedure TMainForm.UnpackOrnaments;
var
  i: Integer;
  OrnamentsDir, OrnamentFilePath: String;
  ResStream: TResourceStream;
begin

  OrnamentsDir := VortexDocumentsDir + OrnamentsDefaultDir;
  if DirectoryExists(OrnamentsDir) then Exit;
  ForceDirectories(OrnamentsDir);

  for i := 0 to High(OrnamentResources) do
  begin
    OrnamentFilePath := OrnamentsDir +'\'+ OrnamentResources[i] + '.vto';

    if FileExists(OrnamentFilePath) then
      Continue;

    ResStream := TResourceStream.Create(HInstance, OrnamentResources[i], RT_RCDATA);
    try
      ResStream.Position := 0;
      ResStream.SaveToFile(OrnamentFilePath);
    finally
      ResStream.Free;
    end;

  end;
end;

procedure TMainForm.OpenDemosong(Sender: TObject);
var
  FilePath: String;
begin

  if Sender is TMenuItem then
  begin
    DontAddToRecent := True;
    FilePath := (Sender as TMenuItem).Hint;
    CreateChildWrapper(FilePath);
    DontAddToRecent := False;
  end;

end;

procedure TMainForm.UnpackDemosongs;
var
  i: Integer;
  SongsDir, SongFilePath: String;
  ResStream: TResourceStream;
  SongMenuItem: TMenuItem;
  Year, PrevYear: Integer;
  re: TRegExpr;
  DemoMenu:TMenuItem;
begin

  re := TRegExpr.Create;
  re.ModifierI := True;
  Year := 0;
  PrevYear := 0;

  DemoMenu := OpenDemo; //  DemoMenu := MainMenu1.Items[0].Items[4];
  SongsDir := VortexDocumentsDir + DemosongsDefaultDir;
  if not DirectoryExists(SongsDir) then
    ForceDirectories(SongsDir);

  for i := 0 to High(SongResources) do
  begin
    SongFilePath := SongsDir +'\'+ SongResources[i] +'.vt2';

    re.Expression := '^([0-9]+)_.*$';
    if re.Exec(SongResources[i]) then
      Year := StrToInt(re.Match[1]);

    // Add separator between years
    if (PrevYear <> 0) and (Year <> PrevYear) then begin
      SongMenuItem := TMenuItem.Create(MainForm);
      SongMenuItem.Caption := '-';
      DemoMenu.Add(SongMenuItem);
    end;


    SongMenuItem := TMenuItem.Create(MainForm);
    SongMenuItem.Caption := SongResources[i];
    SongMenuItem.OnClick := OpenDemosong;
    SongMenuItem.Hint    := SongFilePath;
    DemoMenu.Add(SongMenuItem);

    PrevYear := Year;

    if FileExists(SongFilePath) then
      Continue;

    ResStream := TResourceStream.Create(HInstance, SongResources[i], RT_RCDATA);
    try
      ResStream.Position := 0;
      ResStream.SaveToFile(SongFilePath);
    finally
      ResStream.Free;
    end;

  end;

  re.Free;
end;


procedure TMainForm.AppException(Sender: TObject; E: Exception);
var i: Integer;
begin
  if IsPlaying then
    StopPlaying;

  for i := 0 to MDIChildCount do
    TMDIChild(MDIChildren[i]).Free;

  RestoreSystemColors;
  SaveBackups(MainForm);
  Application.MessageBox('Application error occured. Backup file saved.', 
    'Vortex Tracker', MB_OK + MB_ICONSTOP + MB_TOPMOST);
  Application.Terminate;
  
  {if Application.MessageBox('Something wrong. I recommend to reset settings file.?',
      'Vortex Tracker II', MB_YESNO + MB_ICONERROR + MB_TOPMOST) = IDYES
      then
      begin
        ResetOptions;
        Application.MessageBox('Settings file reseted successfully. Try to restart Vortex again.',
          'Vortex Tracker II', MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
      end; }
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: integer;
  BM: TBitmap;

begin
  {$IFDEF LOGGER}Logger := TLogger.Create('out.txt');{$ENDIF}
  MaximizeChilds := True;
  RedrawEnabled  := True;
  DoubleBuffered := True;
  StatusBar.DoubleBuffered := True;
  ToolBar2.DoubleBuffered := True;
  TrackBar1.DoubleBuffered := True;
  PrevTop := 0;
  DialogWinHandle := nil;
  CenterWinHandle := 0;


  Application.OnException := AppException;
  Caption := AppName +' '+ VersionString;

  BM := TBitmap.Create;
  BM.Canvas.Font := StatusBar.Font;
  StatusBar.Panels[1].Width := BM.Canvas.TextWidth('12345:1230:12345') + 10;
  StatusBar.Panels[2].Width := BM.Canvas.TextWidth('00:00 / 00:00') + 6;
  BM.Free;

  // Save system colors for window decoration
  SaveSystemColors;


  // Set VortexDir variable
  if GetEnvironmentVariable('APPDATA') = '' then begin
    VortexDir := 'C:\' + VortexDirName;
    VortexDocumentsDir := VortexDir;
  end
  else begin
    VortexDir := GetEnvironmentVariable('APPDATA') + '\' + VortexDirName;
    VortexDocumentsDir := GetUserDocumentsDir + '\' + VortexDirName;
  end;


  ConfigFilePath := VortexDir + '\config.ini';
  IsFileWritable(ConfigFilePath);

  // Load fonts
  if Win32MajorVersion > 4 then
  begin
    LibHandle :=  LoadLibrary('gdi32.dll');
    @AddFontMemResource := GetProcAddress(LibHandle, 'AddFontMemResourceEx');
    for i := 0 to High(InternalFonts) do
      LoadResourceFont(InternalFonts[i][0], InternalFonts[i][1]);
    FreeLibrary(LibHandle);
  end
  else
    for i := 0 to High(InternalFonts) do
      LoadAndSaveResourceFont(InternalFonts[i][0], InternalFonts[i][1]);

  DragAcceptFiles(Self.Handle, True);

  // Init syncronization
  SyncMessageFile :=  VortexDir + '\sync';
  if FileExists(SyncMessageFile) then
    DeleteFile(SyncMessageFile);
  SyncCheckTimer.Enabled := True;
  SyncFinishTimer.Enabled := False;

  SyncSampleBufferFile := VortexDir + '\sample';
  SyncSamplePartFile := VortexDir + '\samplepart';
  SyncOrnamentBufferFile := VortexDir + '\ornament';

  // Init FamiTracker clipboard format
  FamiClipboardType := RegisterClipboardFormat('FamiTracker Pattern');

  // Unpack instruments & demosongs
  UnpackSamples;
  UnpackOrnaments;
  UnpackDemosongs;

  WinCount := 0;
  LastChildWidth := 0;
  LastChildHeight := 0;
  SetChildAsTemplate := False;

  for i := 0 to 5 do RecentFiles[i] := '';
  FillChar(NoteKeys, SizeOf(NoteKeys), -3);
  //qwertyuiop[]
  //Asd ghjKl;
  //zxcvbnm,./
  //A= R-- K= ---
  NoteKeys[ORD('A')] := -2;
  NoteKeys[ORD('K')] := -1;
  NoteKeys[ORD('Z')] := 0;
  NoteKeys[ORD('S')] := 1;
  NoteKeys[ORD('X')] := 2;
  NoteKeys[ORD('D')] := 3;
  NoteKeys[ORD('C')] := 4;
  NoteKeys[ORD('V')] := 5;
  NoteKeys[ORD('G')] := 6;
  NoteKeys[ORD('B')] := 7;
  NoteKeys[ORD('H')] := 8;
  NoteKeys[ORD('N')] := 9;
  NoteKeys[ORD('J')] := 10;
  NoteKeys[ORD('M')] := 11;
  NoteKeys[188] := 12; // ',<'
  NoteKeys[ORD('L')] := 13;
  NoteKeys[190] := 14; // '.>'
  NoteKeys[186] := 15; // ';:'
  NoteKeys[191] := 16; // '/?'
  NoteKeys[ORD('Q')] := 12;
  NoteKeys[ORD('2')] := 13;
  NoteKeys[ORD('W')] := 14;
  NoteKeys[ORD('3')] := 15;
  NoteKeys[ORD('E')] := 16;
  NoteKeys[ORD('R')] := 17;
  NoteKeys[ORD('5')] := 18;
  NoteKeys[ORD('T')] := 19;
  NoteKeys[ORD('6')] := 20;
  NoteKeys[ORD('Y')] := 21;
  NoteKeys[ORD('7')] := 22;
  NoteKeys[ORD('U')] := 23;
  NoteKeys[ORD('I')] := 24;
  NoteKeys[ORD('9')] := 25;
  NoteKeys[ORD('O')] := 26;
  NoteKeys[ORD('0')] := 27;
  NoteKeys[ORD('P')] := 28;
  NoteKeys[219] := 29; // '[{'
  NoteKeys[187] := 30; // '=+'
  NoteKeys[221] := 31; // ']}'
  NoteKeys[VK_NUMPAD1] := 33;
  NoteKeys[VK_NUMPAD2] := 34;
  NoteKeys[VK_NUMPAD3] := 35;
  NoteKeys[VK_NUMPAD4] := 36;
  NoteKeys[VK_NUMPAD5] := 37;
  NoteKeys[VK_NUMPAD6] := 38;
  NoteKeys[VK_NUMPAD7] := 39;
  NoteKeys[VK_NUMPAD8] := 40;
  ChanAlloc[0] := 0;
  ChanAlloc[1] := 1;
  ChanAlloc[2] := 2;
  ChanAllocIndex := 0;
  ChanRemapPan := False;
  Enabled := True;
  FileMode := 0;
  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));
  EditorFont := TFont.Create;
  EditorFont.Name := 'Consolas';
  EditorFont.Size := 15;
  EditorFont.Style := [fsBold];
  TestLineFont := TFont.Create;
  TestLineFont.Name := 'Consolas';
  TestLineFont.Size := 15;
  TestLineFont.Style := [fsBold];
  LoopAllowed := False;
  LoopAllAllowed := False;
  GlobalVolume := TrackBar1.Position;
  GlobalVolumeMax := TrackBar1.Max;
  SetDefault(SampleRate_Def, NumberOfChannels_Def, SampleBit_Def);
  ResetMutex := CreateMutex(nil, False, PChar('VTII_Reset' + IntToStr(GetCurrentProcessId)));
  Synthesizer := Synthesizer_Stereo16;
  ExportStarted := False;
  DrawOffAfterClose := False;
  VScrollbarSize := GetSystemMetrics(SM_CXVSCROLL);
  HScrollbarSize := GetSystemMetrics(SM_CYVSCROLL);

  LoadOptions;
  SetFileAssociations;
  InitColorThemes;

  if (midiin1.NumDevs > 0) and not DisableMidi then
  begin
    try
      midiin1.OpenAndStart;
    except
      DisableMidi:=True;
      Application.MessageBox('Sorry, MIDI keyboard busy or... something else happened :)',
        'Vortex Tracker II', MB_OK + MB_ICONWARNING + MB_TOPMOST);
    end;
  end;

  initBuffSample;
  initBuffOrnament;
  initBuffTracks;
  LastClipboard := LCNone;

  ChangeBackupTimer;
  ControlStyle := ControlStyle + [csOpaque];

  StatusBar.Panels[0].Width := ClientWidth - StatusBar.Panels[1].Width - StatusBar.Panels[2].Width - 8;
end;

procedure TMainForm.RedrawPlWindow(PW: TMDIChild; ps, pat, line: integer);
begin
  If PW = nil then Exit;
  if pat > Length(PW.VTMP.Patterns)-1 then Exit;

  //PW.Tracks.RedrawDisabled := True;
  {$IFDEF LOGGER}   
  Logger.Add(IntToStr(line));
  //Logger.Add(Format('Pos: %d, Pat: %d, Line: %d', [ps, pat, line]));
  {$ENDIF}
  if (ps < 256) and (ps <> PW.PositionNumber) then
  begin
    PW.IsSinchronizing := True;
    PW.SelectPosition2(ps);
    PW.IsSinchronizing := False;
  end;

  if (PW.Tracks.ShownPattern <> PW.VTMP.Patterns[pat]) or (PW.Tracks.ShownFrom <> line) then
  begin
    PW.PatNum := pat;
    if PlayMode <> PMPlayPattern then
      PW.PatternNumUpDown.Position := pat;
    PW.Tracks.ShownPattern := PW.VTMP.Patterns[pat];
    PW.Tracks.ShownFrom := line;
    if PW.Tracks.Enabled then PW.Tracks.HideMyCaret;
    PW.Tracks.CursorY := PW.Tracks.N1OfLines;
    PW.Tracks.RemoveSelection;
    if PW.Tracks.Enabled then PW.Tracks.ShowMyCaret;
    PW.IsSinchronizing := True;
    PW.CalculatePos(line);
    PW.IsSinchronizing := False;
  end;

  if not PW.Tracks.RedrawDisabled then
    PW.Tracks.RedrawTracks(0);
end;

procedure TMainForm.RedrawAllSamOrnBrowsers;
var i: Integer;
begin

  for i := 0 to MDIChildCount-1 do with TMDIChild(MDIChildren[i]) do begin

    SamplesBrowser.Visible      := SampleBrowserVisible;
    SamplesDriveSelect.Visible  := SampleBrowserVisible;
    ShowSamBrowserBtn.Visible   := not SampleBrowserVisible;
    HideSamBrowserBtn.Visible   := SampleBrowserVisible;

    OrnamentsBrowser.Visible     := OrnamentsBrowserVisible;
    OrnamentsDriveSelect.Visible := OrnamentsBrowserVisible;
    ShowOrnBrowserBtn.Visible    := not OrnamentsBrowserVisible;
    HideOrnBrowserBtn.Visible    := OrnamentsBrowserVisible;

  end;

end;


procedure TMainForm.RedrawChilds;
var
  i, ChildCount: Smallint;

begin
  ChildCount  := MDIChildCount;
  if ChildCount = 0 then Exit;

  for i := 0 to ChildCount-1 do with TMDIChild(MDIChildren[i]) do begin
    if Closed then Continue;

    InitStringGridMetrix;
    Tracks.RedrawDisabled := True;
    Tracks.InitMetrix;
    
    if EditorFontChanged then begin
      Dec(LastWidth);
      if WindowState <> wsMaximized then begin
        Height := WorkAreaHeight(MainForm.ClientHeight) - Top;
        PageControl1.Height := ClientHeight;
      end;
      HeightChanged := True;
    end;

    AutoResizeForm;
    SamplesBrowser.Color   := CSamOrnBackground;
    OrnamentsBrowser.Color := CSamOrnBackground;
    SamplesDriveSelect.Color := CSamOrnBackground;
    OrnamentsDriveSelect.Color := CSamOrnBackground;
    UpdateSpeedBPM;
    Tracks.RedrawDisabled := False;

    // Fix scrollbar repaint bug
    RefreshPositionsHScroll;
  end;

end;

procedure TMainForm.umredrawtracks(var Msg: TMessage);
var
  line, pat, ps: integer;
  PWChanged: Boolean;
  tr:integer;
begin
  //if Stop then Exit;
  if IsPlaying and (PlayMode = PMPLayLine) then Exit;
  if not IsPlaying or UnlimiteDelay then Exit;

  tr := Msg.LParam; //!!!//

  if PlayingWindow[tr]=nil then Exit;
  PlayingWindow[tr].Tracks.RedrawDisabled := True;

  // Get Chip: position (ps), pattern number (pat), line number (line)
  ps := Msg.WParam and $1FF;
  pat := (Msg.WParam shr 9) and $FF;
  line := (Msg.WParam shr 17) and $1FF;
  if line < 0 then line := 0;

  // Is track state changed?
  PWChanged := (
    (line <> PlayingWindow[tr].Tracks.ShownFrom) or
    (pat  <> PlayingWindow[tr].PatNum) or
    (ps   <> PlayingWindow[tr].PositionNumber)
  );
  if PWChanged then
    RedrawPlWindow(PlayingWindow[tr], ps, pat, line);

  // Enable redraw procedure
  PlayingWindow[tr].Tracks.RedrawDisabled := False;

  // No need to redraw tracks, because no changes
  if not PWChanged then Exit;

  // Set 'manual bitblt' flag ON
  PlayingWindow[tr].Tracks.ManualBitBlt := True;

  // Prepare tracks
  if PlayingWindow[tr].PageControl1.ActivePageIndex = 0 then
    PlayingWindow[tr].Tracks.RedrawTracks(0);

  // Fast copy from buffer to screen
  if PlayingWindow[tr].PageControl1.ActivePageIndex = 0 then
    PlayingWindow[tr].Tracks.DoBitBlt;

  // Set 'manual bitblt' flag OFF
  PlayingWindow[tr].Tracks.ManualBitBlt := False;

end;


procedure TMainForm.Options1Click(Sender: TObject);
var
    Saved_ChanAllocIndex,
    Saved_ChipFreq,
    Saved_StdChannelsAllocation,
    Saved_Interrupt_Freq,
    Saved_SampleRate,
    Saved_SampleBit,
    Saved_NumberOfChannels,
    Saved_BufLen_ms,
    Saved_NumberOfBuffers,
    Saved_WODevice: integer;
    Saved_ChipType: ChTypes;
    Saved_ExternalTracker: Integer;
    Saved_EngineIndex: Integer;
    Saved_FeaturesLevel: integer;
    Saved_DetectFeaturesLevel,
    Saved_VortexModuleHeader,
    Saved_DetectModuleHeader: boolean;
    Saved_ChanRemapPan,
    Saved_IsFilt: boolean;
    Saved_Filt_M: integer;
    Saved_Prior: DWORD;
    Saved_EnvelopeAsNote: Boolean;
    Saved_DecBaseLinesOn: Boolean;
    Saved_DecBaseNoiseOn: Boolean;
    Saved_TestForever: Boolean;
    Saved_HighlightSpeedOn: Boolean;
    Saved_DupNoteParams: Boolean;
    Saved_MoveBetweenPatrns: Boolean;
    Saved_DefaultTable: Smallint;
    Saved_DisableSeparators: Boolean;
    Saved_AutoBackupsOn: Boolean;
    Saved_AutoBackupsMins: byte;
    Saved_TrackFont: TFont;
    Saved_ThemeName: String;
    Saved_Panoram: array[0..2] of Byte;
    Saved_DisableHints: Boolean;
    Saved_TemplateSongPath: String;
    Saved_StartupAction: byte;
    Saved_WinThemeIndex: Integer;
    Saved_DisableMidi: Boolean;
    Saved_DisableCtrlClick: Boolean;
    Saved_DisableInfoWin: Boolean;    
    Saved_ManualChipFreq: Integer;
    Saved_ManualIntFreq: Integer;
    Saved_CenterOffset: Integer;
    Saved_PositionSize: Integer;
    Saved_DCType: Integer;
    Saved_DCCutOff: Integer;
    i: integer;
    f: Double;
    ChanAllocChanged, PanoramChanged: Boolean;
    NewSize: TSize;
    NewLeft, NewTop: integer;

begin
  DisableUpdateChilds := True;
  InitOptionsHotKeys;
  Form1.InitFonts;
  Form1.InitFileAssociations;
  FillColorThemesList;

  Saved_PositionSize := PositionSize;

  Saved_EnvelopeAsNote := EnvelopeAsNote;
  Saved_DupNoteParams := DupNoteParams;
  Saved_MoveBetweenPatrns := MoveBetweenPatrns;

  Saved_DisableCtrlClick := DisableCtrlClick;
  Form1.DisableCtrlClickOpt.Checked := DisableCtrlClick;

  Saved_DisableInfoWin := DisableInfoWin;
  Form1.DisableInfoWinOpt.Checked := DisableInfoWin;

  Form1.StartsAction.ItemIndex := StartupAction;
  Saved_StartupAction := StartupAction;

  Form1.TemplateSong.Text := TemplateSongPath;
  Saved_TemplateSongPath  := TemplateSongPath;

  Form1.DisablePatSeparators.Checked := DisableSeparators;
  Saved_DisableSeparators := DisableSeparators;

  Form1.UpDown2.Position := DefaultTable;
  Saved_DefaultTable := DefaultTable;
  Form1.TableName.Caption := TableNames[DefaultTable];

  Form1.BackupEveryMins.Position := AutoBackupsMins;
  Saved_AutoBackupsMins := AutoBackupsMins;

  Form1.AutoSaveBackups.Checked := AutoBackupsOn;
  Saved_AutoBackupsOn := AutoBackupsOn;
  Form1.BackupsMinsVal.Enabled := AutoBackupsOn;
  Form1.BackupEveryMins.Enabled := AutoBackupsOn;

  Form1.DecNumbersLines.Checked := DecBaseLinesOn;
  Saved_DecBaseLinesOn := DecBaseLinesOn;

  Form1.DecNumbersNoise.Checked := DecBaseNoiseOn;
  Saved_DecBaseNoiseOn := DecBaseNoiseOn;

  Saved_ThemeName := ColorThemeName;
  Saved_TrackFont := EditorFont;

  Form1.CenterOffInt.Position := CenterOffset;
  Saved_CenterOffset := CenterOffset;

  Form1.ChipSel.ItemIndex := Ord(Emulating_Chip) - 1;
  Saved_ChipType := Emulating_Chip;

  Saved_StdChannelsAllocation := StdChannelsAllocation;

  Form1.ChanVisAlloc.ItemIndex := ChanAllocIndex;

  Form1.RemapOnlyPan1.Checked := ChanRemapPan;
  Saved_ChanRemapPan := ChanRemapPan;

  Form1.chkHS.Checked := HighlightSpeedOn;
  Saved_HighlightSpeedOn := HighlightSpeedOn;

  Saved_ChanAllocIndex := ChanAllocIndex;
  Saved_Panoram[0] := Panoram[0];
  Saved_Panoram[1] := Panoram[1];
  Saved_Panoram[2] := Panoram[2];
  Form1.APan.Position := Panoram[0];
  Form1.BPan.Position := Panoram[1];
  Form1.CPan.Position := Panoram[2];
  Form1.APanValue.Text := IntToStr(Panoram[0]);
  Form1.BPanValue.Text := IntToStr(Panoram[1]);
  Form1.CPanValue.Text := IntToStr(Panoram[2]);

  ChanAllocChanged := False;
  PanoramChanged := False;

  Form1.DisableHintsOpt.Checked := DisableHints;
  Saved_DisableHints := DisableHints;

  Saved_WinThemeIndex := WinThemeIndex;
  Form1.WinColorsBox.ItemIndex := WinThemeIndex;

  Form1.optMidiEnable.Checked := not DisableMidi;
  Saved_DisableMidi := DisableMidi;

  Saved_ManualChipFreq := ManualChipFreq;
  if ManualChipFreq > 0 then
    Form1.EdChipFrq.Text := IntToStr(ManualChipFreq);

  Saved_ChipFreq := DefaultChipFreq;
  case DefaultChipFreq of
    894887:  Form1.ChFreq.ItemIndex := 0;
    831303:  Form1.ChFreq.ItemIndex := 1;
    1773400: Form1.ChFreq.ItemIndex := 2;
    1750000: Form1.ChFreq.ItemIndex := 3;
    1000000: Form1.ChFreq.ItemIndex := 4;
    1500000: Form1.ChFreq.ItemIndex := 5;
    2000000: Form1.ChFreq.ItemIndex := 6;
    3500000: Form1.ChFreq.ItemIndex := 7;
    1520640: Form1.ChFreq.ItemIndex := 8;
    1611062: Form1.ChFreq.ItemIndex := 9;
    1706861: Form1.ChFreq.ItemIndex := 10;
    1808356: Form1.ChFreq.ItemIndex := 11;
    1915886: Form1.ChFreq.ItemIndex := 12;
    2029811: Form1.ChFreq.ItemIndex := 13;
    2150510: Form1.ChFreq.ItemIndex := 14;
    2278386: Form1.ChFreq.ItemIndex := 15;
    2413866: Form1.ChFreq.ItemIndex := 16;
    2557401: Form1.ChFreq.ItemIndex := 17;
    2709472: Form1.ChFreq.ItemIndex := 18;
    2870586: Form1.ChFreq.ItemIndex := 19;
    3041280: Form1.ChFreq.ItemIndex := 20;
  else
    begin
     // Form1.EdChipFrq.Text := IntToStr(AY_Freq);
      Form1.ChFreq.ItemIndex := 21;
    end;
  end;


  Saved_Interrupt_Freq := DefaultIntFreq;
  case DefaultIntFreq of
    48828: Form1.IntSel.ItemIndex := 0;
    50000: Form1.IntSel.ItemIndex := 1;
    60000: Form1.IntSel.ItemIndex := 2;
    100000: Form1.IntSel.ItemIndex := 3;
    200000: Form1.IntSel.ItemIndex := 4;
    48000: Form1.IntSel.ItemIndex := 5;
  else
    begin
      f := DefaultIntFreq / 1000;
      Form1.EdIntFrq.Text := FloatToStr(f);
      Form1.IntSel.ItemIndex := 6;
    end;
  end;

  Saved_ExternalTracker := ExternalTracker;
  Form1.ExtTrackerOpt.ItemIndex := ExternalTracker;

  Saved_EngineIndex := RenderEngine;
  Form1.Opt.ItemIndex := RenderEngine;

  if DetectFeaturesLevel then
    Form1.RadioGroup1.ItemIndex := 3
  else
    Form1.RadioGroup1.ItemIndex := FeaturesLevel;
  Saved_FeaturesLevel := FeaturesLevel;
  Saved_DetectFeaturesLevel := DetectFeaturesLevel;
  if DetectModuleHeader then
    Form1.SaveHead.ItemIndex := 2
  else if VortexModuleHeader then
    Form1.SaveHead.ItemIndex := 0
  else
    Form1.SaveHead.ItemIndex := 1;
  Saved_VortexModuleHeader := VortexModuleHeader;
  Saved_DetectModuleHeader := DetectModuleHeader;

  if SampleRate = 11025 then
    Form1.SR.ItemIndex := 0
  else if SampleRate = 22050 then
    Form1.SR.ItemIndex := 1
  else if SampleRate = 44100 then
    Form1.SR.ItemIndex := 2
  else if SampleRate = 48000 then
    Form1.SR.ItemIndex := 3
  else if SampleRate = 88200 then
    Form1.SR.ItemIndex := 4
  else if SampleRate = 96000 then
    Form1.SR.ItemIndex := 5
  else if SampleRate = 192000 then
    Form1.SR.ItemIndex := 6;
  Saved_SampleRate := SampleRate;

  if (RenderEngine < 2) and (SampleBit > 16) then begin
    SampleBit := 16;
    Form1.BR.ItemIndex := 1;
  end;

  Saved_SampleBit := SampleBit;
  case SampleBit of
    8:  Form1.BR.ItemIndex := 0;
    16: Form1.BR.ItemIndex := 1;
    24: Form1.BR.ItemIndex := 2;
    32: Form1.BR.ItemIndex := 3;
  end;

  Form1.NCh.ItemIndex := Ord(NumberOfChannels = 2);
  Saved_NumberOfChannels := NumberOfChannels;
  Form1.TrackBar1.Position := BufLen_ms;
  Saved_BufLen_ms := BufLen_ms;
  Form1.TrackBar2.Position := NumberOfBuffers;
  Saved_NumberOfBuffers := NumberOfBuffers;
  if integer(WODevice) >= 0 then
    if not Form1.ComboBox1.Visible then Form1.Button4Click(Sender);
  if Form1.ComboBox1.Visible then
    Form1.ComboBox1.ItemIndex := WODevice + 1;

  Saved_WODevice := WODevice;
  Saved_IsFilt := IsFilt;
  Form1.FiltChk.Checked := IsFilt;
  Saved_Filt_M := Filt_M;
  Form1.FiltNK.Position := round(Ln(Filt_M) / Ln(2));
  Saved_Prior := Priority;
  Form1.PriorGrp.ItemIndex := Ord(Priority <> NORMAL_PRIORITY_CLASS);

  Saved_DCType := DCType;
  Form1.SetDCType;
  Saved_DCCutOff := DCCutOff;
  Form1.DCCutOffBar.Position := DCCutOff;

  DisableUpdateChilds := False;

  NewLeft := MainForm.Left + MainForm.Width div 2 - Form1.Width div 2;
  NewTop := MainForm.Top + MainForm.Height div 2 - Form1.Height div 2;
  Form1.SetBounds(NewLeft, NewTop, Form1.Width, Form1.Height);

  Form1.FileAssocList.Top:=Form1.AllFileAssoc.Top+Form1.AllFileAssoc.Height+8;
//  Form1.FileAssocList.Left:=Form1.AllFileAssoc.Top+Form1.AllFileAssoc.Height+8;
  Form1.FileAssocList.Height:=Form1.FileAssocBox.Height-(Form1.AllFileAssoc.Top+Form1.AllFileAssoc.Height)-16;
  Form1.FileAssocList.Width:=Form1.FileAssocBox.Width-16;

  // Apply Options - user press OK button
  if Form1.ShowModal = mrOk then
  begin
    Form1.ApplyFileAssociations;
    SaveOptions;
  end
  else


  // CANCEL options
  begin
    Form1.InitFileAssociations;
    SetFileAssociations;

    ManualChipFreq := Saved_ManualChipFreq;
    DisableCtrlClick := Saved_DisableCtrlClick;
    DisableInfoWin := Saved_DisableInfoWin;

    PositionSize := Saved_PositionSize;
    CenterOffset := Saved_CenterOffset;

    if Saved_StartupAction <> StartupAction then
      StartupAction := Saved_StartupAction;

    if Saved_TemplateSongPath <> TemplateSongPath then
      TemplateSongPath := Saved_TemplateSongPath;

    if Saved_DecBaseLinesOn then
      TracksCursorXLeft := 4
    else
      TracksCursorXLeft := 3;

    if Saved_TrackFont <> EditorFont then
      EditorFontChanged := True;

    if Saved_WinThemeIndex <> WinThemeIndex then
    begin
      WinThemeIndex := Saved_WinThemeIndex;
      SetWindowColors(WinThemeIndex);
      TrackBar1.SliderVisible := False;
      TrackBar1.SliderVisible := True;
    end;

    DecBaseLinesOn     := Saved_DecBaseLinesOn;
    DecBaseNoiseOn     := Saved_DecBaseNoiseOn;
    EnvelopeAsNote     := Saved_EnvelopeAsNote;
    HighlightSpeedOn   := Saved_HighlightSpeedOn;
    DupNoteParams      := Saved_DupNoteParams;
    MoveBetweenPatrns  := Saved_MoveBetweenPatrns;
    DefaultTable       := Saved_DefaultTable;
    DisableSeparators  := Saved_DisableSeparators;
    EditorFont         := Saved_TrackFont;
    AutoBackupsOn      := Saved_AutoBackupsOn;
    AutoBackupsMins    := Saved_AutoBackupsMins;
    DisableHints       := Saved_DisableHints;
    DisableMidi        := Saved_DisableMidi;
    SetColorThemeByName(Saved_ThemeName);


    ChangeBackupTimer;

    if MDIChildCount <> 0 then
    begin
      RedrawOff;
      ChildsEventsBlocked  := True;
      EditorFontChanged    := True;

      RedrawChilds;
      AutoMetrixForChilds(WindowState);
      SetChildsPosition(WindowState);
      NewSize := GetSizeForChilds(WindowState, False);
      AutoCutChilds(NewSize);
      AutoToolBarPosition(NewSize);
      SetWindowSize(NewSize);

      NumberOfLinesChanged := False;
      EditorFontChanged    := False;
      ChildsEventsBlocked  := False;
      RedrawOn;

    end;


    if (Saved_ChanAllocIndex <> ChanAllocIndex)
     or (Saved_ChanRemapPan <> ChanRemapPan) then
    begin
      SetChannelsAllocation(Saved_ChanAllocIndex);
      ChanRemapPan := Saved_ChanRemapPan;
      PanoramChanged := True;
    end;

    SetEmulatingChip(Saved_ChipType);

    if Saved_ChipFreq <> DefaultChipFreq then
     DefaultChipFreq := Saved_ChipFreq;

    if Saved_StdChannelsAllocation <> StdChannelsAllocation then
    begin
      ToggleChanAlloc.Caption := SetStdChannelsAllocation(Saved_StdChannelsAllocation);
      ChanAllocChanged := True;
    end;

    if (Saved_Panoram[0] <> Panoram[0]) or (Saved_Panoram[1] <> Panoram[1]) or (Saved_Panoram[2] <> Panoram[2]) then
    begin
      Panoram[0] := Saved_Panoram[0];
      Panoram[1] := Saved_Panoram[1];
      Panoram[2] := Saved_Panoram[2];
      PanoramChanged := True;
    end;

    if ChanAllocChanged or PanoramChanged then
    begin
      Index_AL := 255 - Panoram[0];
      Index_AR := Panoram[0];
      Index_BL := 255 - Panoram[1];
      Index_BR := Panoram[1];
      Index_CL := 255 - Panoram[2];
      Index_CR := Panoram[2];
      Calculate_Level_Tables;
      if RenderEngine = 2 then
        UpdatePanoram
      else if IsPlaying then
      begin
        ResetPlaying;
        PlayingWindow[1].RerollToLine(1);
        UnresetPlaying;
      end;

    end;

    if Saved_Interrupt_Freq <> DefaultIntFreq then
      DefaultIntFreq := Saved_Interrupt_Freq;

    if Saved_ExternalTracker <> ExternalTracker then
      ExternalTracker := Saved_ExternalTracker;

    if RenderEngine <> Saved_EngineIndex then
      Set_Engine(Saved_EngineIndex);

    DCType := Saved_DCType;
    DCCutOff := Saved_DCCutOff;
    if (AyumiChip0 <> nil) then begin
      AyumiChip0.SetDCType(DCType);
      AyumiChip0.SetDCCutoff(DCCutOff);
    end;
    if (AyumiChip1 <> nil) then begin
      AyumiChip1.SetDCType(DCType);
      AyumiChip1.SetDCCutoff(DCCutOff);
    end;
    if (AyumiChip2 <> nil) then begin
      AyumiChip2.SetDCType(DCType);
      AyumiChip2.SetDCCutoff(DCCutOff);
    end;
    if (AyumiChip3 <> nil) then begin
      AyumiChip3.SetDCType(DCType);
      AyumiChip3.SetDCCutoff(DCCutOff);
    end;

    FeaturesLevel := Saved_FeaturesLevel;
    DetectFeaturesLevel := Saved_DetectFeaturesLevel;
    VortexModuleHeader := Saved_VortexModuleHeader;
    DetectModuleHeader := Saved_DetectModuleHeader;
    if not WOThreadActive then
    begin
      if Saved_SampleRate <> SampleRate then
        SetSampleRate(Saved_SampleRate);
      if Saved_SampleBit <> SampleBit then
        SetBitRate(Saved_SampleBit);
      if Saved_NumberOfChannels <> NumberOfChannels then
        SetNChans(Saved_NumberOfChannels);
      if (Saved_BufLen_ms <> BufLen_ms) or
        (Saved_NumberOfBuffers <> NumberOfBuffers) then
        SetBuffers(Saved_BufLen_ms, Saved_NumberOfBuffers);
      WODevice := Saved_WODevice
    end;
    SetFilter(Saved_IsFilt, Saved_Filt_M);
    SetPriority(Saved_Prior)
  end;
end;

function TMainForm.GetFirstModule(CW:TMDIChild):TMDIChild;
var
  xl,xlb:Integer;
begin
  xl:=CW.Left;
  xlb:=0;
  if CW.TSWindow[0]<>nil then
  begin
    if CW.TSWindow[0].Left<xl then
    begin
      xl:=CW.TSWindow[0].Left;
      xlb:=1;
    end;
  end;
  if CW.TSWindow[1]<>nil then
  begin
    if CW.TSWindow[1].Left<xl then
    begin
      xl:=CW.TSWindow[1].Left;
      xlb:=2;
    end;
  end;
  if xlb=0 then result:=CW;
  if xlb=1 then result:=CW.TSWindow[0];
  if xlb=2 then result:=CW.TSWindow[1];
end;

function TMainForm.SavePT3(CW: TMDIChild; FileName: string; AsText: boolean):boolean;
var
  PT3: TSpeccyModule;
  Size: integer;
  f: file;

  errmsg:string;
begin
  Result := False;
  if not IsFileWritable(FileName) then Exit;
  CW:=GetFirstModule(CW);
  if not AsText then
  begin
    ErrMsg := VTM2PT3(@PT3, CW.VTMP, Size);
    if ErrMsg<>'' then
    begin
      Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(FileName));
      exit;
    end;
    AssignFile(f, FileName);
    Rewrite(f, 1);
    try
      BlockWrite(f, PT3, Size);
      if (CW.TSWindow[0] <> nil) and (CW.TSWindow[1] <> nil) then
      begin
        TSData3.Size0 := Size;
        ErrMsg := VTM2PT3(@PT3, CW.TSWindow[0].VTMP, Size);
        if ErrMsg<>'' then
        begin
          Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(FileName));
          exit;
        end;
        BlockWrite(f, PT3, Size);
        TSData3.Size1 := Size;
        ErrMsg := VTM2PT3(@PT3, CW.TSWindow[1].VTMP, Size);
        if ErrMsg<>'' then
        begin
          Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(FileName));
          exit;
        end;
        BlockWrite(f, PT3, Size);
        TSData3.Size2 := Size;
        BlockWrite(f, TSData3, SizeOf(TSData3));
      end
      else
      if CW.TSWindow[0] <> nil then
      begin
        TSData2.Size1 := Size;
        ErrMsg := VTM2PT3(@PT3, CW.TSWindow[0].VTMP, Size);
        if ErrMsg<>'' then
        begin
          Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(FileName));
          exit;
        end;
        BlockWrite(f, PT3, Size);
        TSData2.Size2 := Size;
        BlockWrite(f, TSData2, SizeOf(TSData2));
      end;
    finally
      CloseFile(f);
    end;
  end
  else
  begin
    // Swap left and right module, if need
//    if (CW.TSWindow[0] <> nil) and not CW.LeftModule then
//      CW := CW.TSWindow[0];

    // Save left module
    VTM2TextFile(FileName, CW.VTMP, False);
    // Save right module
    if CW.TSWindow[0] <> nil then
      VTM2TextFile(FileName, CW.TSWindow[0].VTMP, True);
    // Save middle module
    if CW.TSWindow[1] <> nil then
      VTM2TextFile(FileName, CW.TSWindow[1].VTMP, True);
  end;
  CW.SavedAsText := AsText;
  CW.SongChanged := False;
  CW.BackupSongChanged := False;
  if CW.TSWindow[0] <> nil then
  begin
    CW.TSWindow[0].SavedAsText := AsText;
    CW.TSWindow[0].SongChanged := False;
    CW.TSWindow[0].BackupSongChanged := False;
    CW.TSWindow[0].SetFileName(FileName);
  end;
  if CW.TSWindow[1] <> nil then
  begin
    CW.TSWindow[1].SavedAsText := AsText;
    CW.TSWindow[1].SongChanged := False;
    CW.TSWindow[1].BackupSongChanged := False;
    CW.TSWindow[1].SetFileName(FileName);
  end;
  AddFileName(FileName);
  Result := True
end;

function TMainForm.SavePT3Backup(CW: TMDIChild; FileName: string; AsText: boolean): boolean;
var
  PT3: TSpeccyModule;
  Size: integer;
  f: file;
  ErrMsg: String;
begin
  Result := False;
  if not IsFileWritable(FileName) then Exit;
  CW:=GetFirstModule(CW);
  if not AsText then
  begin
    ErrMsg := VTM2PT3(@PT3, CW.VTMP, Size);
    if ErrMsg<>'' then
    begin
      Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(FileName));
      exit;
    end;
    AssignFile(f, FileName);
    Rewrite(f, 1);
    try
      BlockWrite(f, PT3, Size);
      if (CW.TSWindow[0] <> nil) and (CW.TSWindow[1] <> nil) then
      begin
        TSData3.Size0 := Size;
        ErrMsg := VTM2PT3(@PT3, CW.TSWindow[0].VTMP, Size);
        if ErrMsg<>'' then
        begin
          Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(FileName));
          exit;
        end;
        BlockWrite(f, PT3, Size);
        TSData3.Size1 := Size;
        ErrMsg := VTM2PT3(@PT3, CW.TSWindow[1].VTMP, Size);
        if ErrMsg<>'' then
        begin
          Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(FileName));
          exit;
        end;
        BlockWrite(f, PT3, Size);
        TSData3.Size2 := Size;
        BlockWrite(f, TSData3, SizeOf(TSData3));
      end
      else
      if CW.TSWindow[0] <> nil then
      begin
        TSData2.Size1 := Size;
        ErrMsg := VTM2PT3(@PT3, CW.TSWindow[0].VTMP, Size);
        if ErrMsg<>'' then
        begin
          Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(FileName));
          exit;
        end;
        BlockWrite(f, PT3, Size);
        TSData2.Size2 := Size;
        BlockWrite(f, TSData2, SizeOf(TSData2));
      end;
    finally
      CloseFile(f);
    end;
  end
  else
  begin
    VTM2TextFile(FileName, CW.VTMP, False);
    if CW.TSWindow[0] <> nil then
      VTM2TextFile(FileName, CW.TSWindow[0].VTMP, True);
    if CW.TSWindow[1] <> nil then
      VTM2TextFile(FileName, CW.TSWindow[1].VTMP, True);
  end;
  CW.BackupSongChanged := False;
  if CW.TSWindow[0] <> nil then CW.TSWindow[0].BackupSongChanged := False;
  if CW.TSWindow[1] <> nil then CW.TSWindow[1].BackupSongChanged := False;
end;

function GetMainModule:TMDIChild;
var
 curwin: TMDIChild;
begin
  curwin := TMDIChild(MainForm.ActiveMDIChild);
  if (curwin.TSWindow[0] <> nil) and (curwin.TSWindow[0].NumModule = 1) then
  result := curwin.TSWindow[0]
  else
  if (curwin.TSWindow[1] <> nil) and (curwin.TSWindow[1].NumModule = 1) then
  result := curwin.TSWindow[1]
  else result := curwin;
end;

procedure TMainForm.FileSave1Execute(Sender: TObject);
begin
  GetMainModule.SaveModule;
end;

procedure TMainForm.FileSaveAs1Execute(Sender: TObject);
begin
  GetMainModule.SaveModuleAs;
end;

procedure TMainForm.FileSave1Update(Sender: TObject);
begin
  if MDIChildCount = 0 then begin
    FileSave1.Enabled := False;
    Exit;
  end;
  FileSave1.Enabled := not ExportStarted and (MDIChildCount <> 0) and
    ( (TMDIChild(ActiveMDIChild).SongChanged or
    ((TMDIChild(ActiveMDIChild).TSWindow[0] <> nil) and
    TMDIChild(ActiveMDIChild).TSWindow[0].SongChanged))
    or
    (TMDIChild(ActiveMDIChild).SongChanged or
    ((TMDIChild(ActiveMDIChild).TSWindow[1] <> nil) and
    TMDIChild(ActiveMDIChild).TSWindow[1].SongChanged))
    );
end;

procedure TMainForm.FileSaveAs1Update(Sender: TObject);
begin
  FileSaveAs1.Enabled := (MDIChildCount <> 0) and not ExportStarted;
end;

procedure TMainForm.SaveDialog1TypeChange(Sender: TObject);
var
  s: string;
begin
  if SaveDialog1.FilterIndex = 1 then
    s := 'txt'
  else
    s := 'pt3';
  SaveDialog1.DefaultExt := s
end;

procedure TMainForm.Play1Update(Sender: TObject);
begin
  Play1.Enabled := (MDIChildCount <> 0) and not ExportStarted;
end;


procedure TMainForm.PlayPatUpdate(Sender: TObject);
begin
  PlayPat.Enabled := (MDIChildCount <> 0) and not ExportStarted;
end;

procedure TMainForm.PlayPatFromLineUpdate(Sender: TObject);
begin
  PlayPatFromLine.Enabled := (MDIChildCount <> 0) and not ExportStarted;
end;



procedure TMainForm.Play1Execute(Sender: TObject);
var
  i: integer;
begin
  if MDIChildCount = 0 then exit;
  if TMDIChild(ActiveMDIChild).VTMP.Positions.Length <= 0 then exit;

  if IsPlaying then
  begin
    StopPlaying;
    RestoreControls
  end;

  if NoPatterns then Exit;

  DisableControls(True);

  PlayMode := PMPlayModule;
  TMDIChild(ActiveMDIChild).PlayStopState := BStop;
  TMDIChild(ActiveMDIChild).Tracks.RemoveSelection;
  TMDIChild(ActiveMDIChild).CheckStringGrid1Position;
  ScrollToPlayingWindow;
  
  for i := 1 to NumberOfSoundChips do
  begin
    if PlayingWindow[i]=nil then continue;
    Module_SetPointer(PlayingWindow[i].VTMP, i);
    Module_SetDelay(PlayingWindow[i].VTMP.Initial_Delay);
    Module_SetCurrentPosition(0);
  end;
  InitForAllTypes(True);
  StartWOThread
end;


procedure TMainForm.PlayPatExecute(Sender: TObject);
var
  i: integer;
begin
  if MDIChildCount = 0 then exit;
  if IsPlaying then
  begin
    StopPlaying;
    RestoreControls
  end;

  if NoPatterns then Exit;

  TMDIChild(ActiveMDIChild).PlayStopState := BStop;
  PlayMode := PMPlayPattern;

  DisableControls(True);

  PlayingWindow[1].ValidatePattern2(PlayingWindow[1].PatNum);
  PlayingWindow[1].Tracks.RemoveSelection;
  PlayingWindow[1].CheckStringGrid1Position;
  ScrollToPlayingWindow;

  for i := 1 to NumberOfSoundChips do
  begin
    if PlayingWindow[i]=nil then continue;
    Module_SetPointer(PlayingWindow[i].VTMP,i);
    Module_SetDelay(PlayingWindow[i].VTMP.Initial_Delay);
    Module_SetCurrentPosition(PlayingWindow[i].PositionNumber);
    Module_SetCurrentPattern(PlayingWindow[i].PatNum);
  end;

  InitForAllTypes(False);
  StartWOThread
end;

procedure TMainForm.PlayPatFromLineExecute(Sender: TObject);
begin

  // Current line already playing
  if IsPlaying and (PlayMode in [PMPlayPattern, PMPlayModule]) then Exit;

  if MDIChildCount = 0 then exit;
  if IsPlaying then
  begin
    StopPlaying;
    RestoreControls
  end;

  if NoPatterns then Exit;

  DisableControls(True);

  with TMDIChild(ActiveMDIChild) do begin
    PlayStopState := BStop;
    ValidatePattern2(PatNum);
    Tracks.RemoveSelection;
    ScrollToPlayingWindow;

    if TSWindow[0] = nil then
      RestartPlaying(True, False)
    else
      RestartPlayingTS(True, False);
    CheckStringGrid1Position;
  end;

end;

procedure TMainForm.RestoreTracksFocus;
begin
  // Set focus on the pattern editor, if patterns tab active
  if (TMDIChild(ActiveMDIChild) = PlayingWindow[1]) and (PlayingWindow[1].PageControl1.ActivePageIndex = 0) then
    PlayingWindow[1].Tracks.SetFocus;

  // Set focus on the pattern editor, if patterns tab of second turbotrack window is active
  if NumberOfSoundChips < 2 then exit;
  if (TMDIChild(ActiveMDIChild) = PlayingWindow[2]) and (PlayingWindow[2].PageControl1.ActivePageIndex = 0) then
    PlayingWindow[2].Tracks.SetFocus;

  if NumberOfSoundChips < 3 then exit;
  if (TMDIChild(ActiveMDIChild) = PlayingWindow[3]) and (PlayingWindow[3].PageControl1.ActivePageIndex = 0) then
    PlayingWindow[3].Tracks.SetFocus;
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  VTExit := True;
  StopPlaying;
  SaveOptions;
  RestoreSystemColors;
  if FileExists(SyncSampleBufferFile) then
    try
      DeleteFile(SyncSampleBufferFile);
    except
    end;
  if FileExists(SyncOrnamentBufferFile) then
    try
      DeleteFile(SyncOrnamentBufferFile);
    except
    end;
  if FileExists(SyncSamplePartFile) then
    try
      DeleteFile(SyncSamplePartFile);
    except
    end;

end;

procedure TMainForm.SetLoopPosExecute(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  with TMDIChild(ActiveMDIChild) do
  begin
    if (StringGrid1.Selection.Left < VTMP.Positions.Length) and
      (StringGrid1.Selection.Left <> VTMP.Positions.Loop) then
      SetLoopPos(StringGrid1.Selection.Left);
    InputPNumber := 0
  end
end;

procedure TMainForm.SetLoopPosUpdate(Sender: TObject);
begin
  SetLoopPos.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).StringGrid1.Focused and
    (TMDIChild(ActiveMDIChild).VTMP.Positions.Length >
    TMDIChild(ActiveMDIChild).StringGrid1.Selection.Left)
end;

procedure TMainForm.InsertPositionExecute(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  if IsPlaying and (PlayMode = PMPlayModule) then exit;
  TMDIChild(ActiveMDIChild).InsertPosition(False, True, True); // Duplicate - false
end;


procedure TMainForm.DuplicatePosition1Click(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  if IsPlaying and (PlayMode = PMPlayModule) then exit;
  TMDIChild(ActiveMDIChild).InsertPosition(True, True, True); // Duplicate - true
end;

procedure TMainForm.ClonePosition1Click(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  if IsPlaying and (PlayMode = PMPlayModule) then exit;
  TMDIChild(ActiveMDIChild).ClonePositions;
end;

procedure TMainForm.DeletePositionExecute(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  if IsPlaying and (PlayMode = PMPlayModule) then exit;
  TMDIChild(ActiveMDIChild).DeletePositions;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DragAcceptFiles(Self.Handle, False);
  CloseHandle(ResetMutex);
  EditorFont.Free;
  TestLineFont.Free;
end;

procedure TMainForm.ToggleLoopingExecute(Sender: TObject);
begin
  LoopAllowed := not LoopAllowed;
  if LoopAllowed then
  begin
    LoopAllAllowed := False;
    ToggleLoopingAll.Checked := False
  end;
  ToggleLooping.Checked := LoopAllowed
end;

procedure TMainForm.ToggleLoopingAllExecute(Sender: TObject);
begin
  LoopAllAllowed := not LoopAllAllowed;
  if LoopAllAllowed then
  begin
    LoopAllowed := False;
    ToggleLooping.Checked := False
  end;
  ToggleLoopingAll.Checked := LoopAllAllowed
end;

procedure TMainForm.AddFileName;
var
  i, j: integer;
  FN1: string;
begin
  if DontAddToRecent then Exit;

  FN1 := AnsiUpperCase(FN);
  for i := 0 to 4 do
    if AnsiUpperCase(RecentFiles[i]) = FN1 then
    begin
      for j := i to 4 do
        RecentFiles[j] := RecentFiles[j + 1];
      break
    end;
  for i := 4 downto 0 do
    RecentFiles[i + 1] := RecentFiles[i];
  RecentFiles[0] := FN;
  j := MainMenu1.Items[0].IndexOf(RFile1);
  for i := 0 to 5 do
    if RecentFiles[i] <> '' then
    begin
      MainMenu1.Items[0].Items[j + i].Caption := IntToStr(i + 1) + ': ' +
        ExtractFileName(RecentFiles[i]);
      MainMenu1.Items[0].Items[j + i].Visible := True
    end
    else
      MainMenu1.Items[0].Items[j + i].Visible := False;
  MainMenu1.Items[0].Items[j + 6].Visible := MainMenu1.Items[0].Items[j].Visible
end;

procedure TMainForm.OpenRecent;
begin
  if (RecentFiles[n] <> '') and FileExists(RecentFiles[n]) then
  begin
    OpenDialog.InitialDir := ExtractFilePath(RecentFiles[n]);
    OpenDialog.FileName := RecentFiles[n];
    CreateChildWrapper(RecentFiles[n]);
  end
end;

procedure TMainForm.RFile1Click(Sender: TObject);
begin
  OpenRecent(0)
end;

procedure TMainForm.RFile2Click(Sender: TObject);
begin
  OpenRecent(1)
end;

procedure TMainForm.RFile3Click(Sender: TObject);
begin
  OpenRecent(2)
end;

procedure TMainForm.RFile4Click(Sender: TObject);
begin
  OpenRecent(3)
end;

procedure TMainForm.RFile5Click(Sender: TObject);
begin
  OpenRecent(4)
end;

procedure TMainForm.RFile6Click(Sender: TObject);
begin
  OpenRecent(5)
end;

procedure TMainForm.umplayingoff;
begin
  RestoreControls
end;

procedure TMainForm.umfinalizewo;
begin
  //if TMDIChild(ActiveMDIChild).BeetweenPatterns.Checked then exit;
  WOThreadFinalization;
  RestoreControls;
  if LoopAllAllowed and (MDIChildCount > 1) then
  begin
    Next;
    Play1Execute(nil)
  end
end;

procedure TMainForm.ToggleChipExecute(Sender: TObject);
var i:integer;
begin
  if Emulating_Chip = AY_Chip then
  begin
    Emulating_Chip := YM_Chip;
    ToggleChip.Caption := 'YM'
  end
  else
  begin
    Emulating_Chip := AY_Chip;
    ToggleChip.Caption := 'AY'
  end;
  if StdChannelsAllocation in [0..6] then
    SetStdChannelsAllocation(StdChannelsAllocation)
  else
    Calculate_Level_Tables;

  if (RenderEngine = 2) and (AyumiChip1 <> nil) then
  begin
    if (AyumiChip0 <> nil) then AyumiChip0.SetChipType(Emulating_Chip = YM_Chip);
    if (AyumiChip1 <> nil) then AyumiChip1.SetChipType(Emulating_Chip = YM_Chip);
    if (AyumiChip2 <> nil) then AyumiChip2.SetChipType(Emulating_Chip = YM_Chip);
    if (AyumiChip3 <> nil) then AyumiChip3.SetChipType(Emulating_Chip = YM_Chip);
  end
  else if IsPlaying then
  begin
    for i:=0 to NumberOfSoundChips do
      if PlayingWindow[i]=nil then PlayingWindow[i].StopAndRestart;
  end
end;

procedure TMainForm.ToggleChanAllocExecute(Sender: TObject);
begin
  Inc(ChanAllocIndex);
  if ChanAllocIndex > 5 then
    ChanAllocIndex := 0;
  RedrawOff;
  SetChannelsAllocation(ChanAllocIndex);
  RedrawOn;
  if RenderEngine = 2 then
    UpdatePanoram
  else if IsPlaying then
    PlayingWindow[1].StopAndRestart
end;

procedure TMainForm.SetChannelsAllocation;
var
  i, c, p, n: integer;
  PrevAlloc: array[0..2] of integer;
  Caption: String;
begin
  Move(ChanAlloc, PrevAlloc, SizeOf(PrevAlloc));
  ChanAllocIndex := CA;
  case CA of
    0: begin ChanAlloc[0] := 0; ChanAlloc[1] := 1; ChanAlloc[2] := 2; Caption := 'Mono' end;
    1: begin ChanAlloc[0] := 0; ChanAlloc[1] := 1; ChanAlloc[2] := 2; Caption := 'ABC' end;
    2: begin ChanAlloc[0] := 0; ChanAlloc[1] := 2; ChanAlloc[2] := 1; Caption := 'ACB' end;
    3: begin ChanAlloc[0] := 1; ChanAlloc[1] := 0; ChanAlloc[2] := 2; Caption := 'BAC' end;
    4: begin ChanAlloc[0] := 1; ChanAlloc[1] := 2; ChanAlloc[2] := 0; Caption := 'BCA' end;
    5: begin ChanAlloc[0] := 2; ChanAlloc[1] := 0; ChanAlloc[2] := 1; Caption := 'CAB' end;
    6: begin ChanAlloc[0] := 2; ChanAlloc[1] := 1; ChanAlloc[2] := 0; Caption := 'CBA' end
  end;
  if ChanRemapPan then
  begin
    ChanAlloc[0] := 0;
    ChanAlloc[1] := 1;
    ChanAlloc[2] := 2;
  end;
  MainForm.ToggleChanAlloc.Caption := Caption;
  for i := 0 to MDIChildCount - 1 do
    with TMDIChild(MDIChildren[i]) do
    begin
      c := (Tracks.CursorX - 8) div 14;
      if c >= 0 then
      begin
        p := PrevAlloc[c];
        n := 0;
        while (n < 2) and (ChanAlloc[n] <> p) do Inc(n);
        Inc(Tracks.CursorX, (n - c) * 14)
      end;
      ResetChanAlloc;
    end;
  SetStdChannelsAllocation(CA);
end;

procedure TMainForm.DisableControls(DisableTracks: Boolean);
var i: Integer;
begin
  // Disable hints, because they makes 'lags' in pattern scrolling
  Application.ShowHint := False;

  // Setup playing windows and number of chips
  PlayingWindow[1] := TMDIChild(ActiveMDIChild);
  if PlayingWindow[1] = PlayingWindow[2] then
    PlayingWindow[2] := nil;
  if PlayingWindow[1] = PlayingWindow[3] then
    PlayingWindow[3] := nil;

  // Is second playing window present? And its positions length <> 0?
  if (PlayingWindow[1].TSWindow[1] <> nil) and (PlayingWindow[1].TSWindow[1].VTMP.Positions.Length <> 0)
  and (PlayingWindow[1].TSWindow[0] <> nil) and (PlayingWindow[1].TSWindow[0].VTMP.Positions.Length <> 0) then
  begin
    PlayingWindow[2] := PlayingWindow[1].TSWindow[0];
    PlayingWindow[3] := PlayingWindow[1].TSWindow[1];
    NumberOfSoundChips := 3;
  end
  else
  if (PlayingWindow[1].TSWindow[0] <> nil) and (PlayingWindow[1].TSWindow[0].VTMP.Positions.Length <> 0) then
  begin
    PlayingWindow[2] := PlayingWindow[1].TSWindow[0];
    PlayingWindow[3] := nil;
    NumberOfSoundChips := 2;
  end
  else
  begin
    PlayingWindow[2] := nil;
    PlayingWindow[3] := nil;
    NumberOfSoundChips := 1;
  end;

  // Disable controls for playing windows
  for i := 1 to NumberOfSoundChips do
  begin
    if PlayingWindow[i] = nil then Continue;

    // Change Play/Stop button state
    PlayingWindow[i].PlayStopState := BStop;

    // Disable pattern number changing
    PlayingWindow[i].PatternNumEdit.Enabled   := False;
    PlayingWindow[i].PatternNumUpDown.Enabled := False;

    // Disable pattern length changing
    PlayingWindow[i].PatternLenEdit.Enabled   := False;
    PlayingWindow[i].PatternLenUpDown.Enabled := False;

    // Disable move between patterns checkbox
    PlayingWindow[i].BetweenPatterns.Enabled := False;

    // Disable duplicate note params checkbox
    PlayingWindow[i].DuplicateNoteParams.Enabled := False;

    // Disable Envelope As Note checkbox
    PlayingWindow[i].EnvelopeAsNoteOpt.Enabled := False;

    // Disable pattern editor
    if DisableTracks then
      PlayingWindow[i].Tracks.Enabled := False;

    // Disable range selection for positions list
    PlayingWindow[i].StringGrid1.Options := PlayingWindow[i].StringGrid1.Options - [goRangeSelect];

    // If playing only current pattern, then disable change position
    //if PlayMode = PMPlayPattern then
    //  PlayingWindow[i].StringGrid1.Options := PlayingWindow[i].StringGrid1.Options - [goRowSelect, goDrawFocusSelected];

  end;

  // Disable some context menu items
  RenumberPatterns.Enabled := False;
  AutoNumeratePatterns.Enabled := False;

end;


procedure TMainForm.RestoreControls;
var
  i: integer;
begin
  Application.ShowHint := True;
  
  // Restore controls for childs
  for i := 0 to MDIChildCount-1 do with TMDIChild(MDIChildren[i]) do
  begin

    // Set Play/Stop button state
    PlayStopState := BPlay;

    // Enable pattern number edit
    PatternNumEdit.Enabled   := True;
    PatternNumUpDown.Enabled := True;

    // Enable pattern length changing
    PatternLenEdit.Enabled   := True;
    PatternLenUpDown.Enabled := True;

    // Set patterns editor cursor position
   { if PlayMode in [PMPlayModule, PMPlayPattern] then
      Tracks.CursorY := Tracks.N1OfLines;  }

    // Enable pattern editor
    Tracks.Enabled := True;

    // Enable range selection for positions list
    StringGrid1.Options := StringGrid1.Options + [goRangeSelect];

    // Enable Move Between Patterns checkbox
    BetweenPatterns.Enabled := True;

    // Enable Duplicate Note Params checkbox
    DuplicateNoteParams.Enabled := True;

    // Enable Envelope As Note checkbox
    EnvelopeAsNoteOpt.Enabled := True;

    // Set play/stop button state
    PlayStopState := BPlay;
    RestoreTracksFocus;
    Tracks.RemoveSelection;

  end;

  // Enable some context menu items
  RenumberPatterns.Enabled := True;
  AutoNumeratePatterns.Enabled := True;
end;


procedure TMainForm.ScrollToPlayingWindow;
var
  WinRect: TRect;
  i, ChildIndex: integer;
  FirstChild, LastChild: Boolean;
  ActiveChild: TMDIChild;
begin

  if MDIChildCount = 1 then Exit;
  if ChildsWidth <= ClientWidth then Exit;

  ActiveChild := TMDIChild(ActiveMDIChild);
  WinRect     := ActiveChild.BoundsRect;


  if (WinRect.Left > 0) and (WinRect.Right < ClientWidth) then
    Exit;


  ChildIndex := 0;
  for i := High(ChildsTable) downto Low(ChildsTable) do
    if ChildsTable[i] <> nil then begin
      ChildIndex := i;
      Break;
    end;
  LastChild := ChildsTable[ChildIndex] = ActiveChild;


  ChildIndex := 0;
  for i := Low(ChildsTable) to High(ChildsTable) do
    if ChildsTable[i] <> nil then begin
      ChildIndex := i;
      Break;
    end;
  FirstChild := ChildsTable[ChildIndex] = ActiveChild;

  
  if FirstChild then
    PostMessage(ClientHandle, WM_HSCROLL, SB_LEFT, 0)

  else if LastChild or (Abs(WinRect.Left - ChildsWidth) < ClientWidth) then
    PostMessage(ClientHandle, WM_HSCROLL, SB_RIGHT, 0)

  else begin
    WinRect.Left := WinRect.Left - (ClientWidth div 2) + (LastChildWidth div 2);

    ScrollWindow(ClientHandle, 0 - WinRect.Left, 0, nil, nil);
    PostMessage(ClientHandle, WM_HSCROLL, SB_LINELEFT, 0);
    PostMessage(ClientHandle, WM_HSCROLL, SB_LINERIGHT, 0);
  end;

  ActiveChild.BringToFront;

end;

{procedure TMainForm.CheckSecondWindow(DisableTracks: Boolean);
begin
  if PlayingWindow[1].TSWindow <> nil then
  begin
    PlayingWindow[2] := PlayingWindow[1].TSWindow;
    if (PlayingWindow[1] <> PlayingWindow[2]) and (PlayingWindow[2].VTMP.Positions.Length <> 0) then
    begin
      NumberOfSoundChips := 2;
      PlayingWindow[2].PlayStopState := BStop;
      PlayingWindow[2].PatternNumEdit.Enabled := False;
      PlayingWindow[2].PatternNumUpDown.Enabled := False;
      // Disable pattern length changing
      PlayingWindow[2].PatternLenEdit.Enabled   := False;
      PlayingWindow[2].PatternLenUpDown.Enabled := False;
      if DisableTracks then
        PlayingWindow[2].Tracks.Enabled := False;
      PlayingWindow[2].TSBut.Enabled := False;
      PlayingWindow[2].StringGrid1.Options := PlayingWindow[2].StringGrid1.Options - [goRangeSelect];
      PlayingWindow[2].BeetweenPatterns.Enabled := False;
      PlayingWindow[2].DuplicateNoteParams.Enabled := False;
      PlayingWindow[2].EnvelopeAsNote.Enabled := False;
      RenumberPatterns.Enabled := False;
      AutoNumeratePatterns.Enabled := False;
    end;
  end;
  PlayingWindow[1].TSBut.Enabled := False;
end; }



procedure TMainForm.ToggleSamplesUpdate(Sender: TObject);
begin
  ToolButton25.Enabled := (MDIChildCount <> 0) and not ExportStarted;
  Togglesamples1.Enabled := ToolButton25.Enabled;
end;


procedure TMainForm.ToggleSamplesClick(Sender: TObject);
begin
  ToglSams.Visible := not ToglSams.Visible;
end;

procedure TMainForm.TracksManagerUpdate(Sender: TObject);
begin
  ToolButton26.Enabled := (MDIChildCount <> 0) and not ExportStarted;
  Tracksmanager1.Enabled := ToolButton26.Enabled;
end;

procedure TMainForm.TracksManagerClick(Sender: TObject);
begin
  TrMng.Visible := not TrMng.Visible;
end;

procedure TMainForm.GlobalTranspositionUpdate(Sender: TObject);
begin
  ToolButton27.Enabled := (MDIChildCount <> 0) and not ExportStarted;
  Globaltransposition1.Enabled := ToolButton27.Enabled;
end;

procedure TMainForm.GlobalTranspositionClick(Sender: TObject);
begin
  GlbTrans.Visible := not GlbTrans.Visible;
end;

procedure TMainForm.TrackBar1Change(Sender: TObject);
begin
  GlobalVolume := TrackBar1.Position;
  Calculate_Level_Tables
end;

procedure TMainForm.SetEmulatingChip(ChType: ChTypes);
begin
  if Emulating_Chip <> ChType then
  begin
    Emulating_Chip := ChType;
    if Emulating_Chip = AY_Chip then
      ToggleChip.Caption := 'AY'
    else
      ToggleChip.Caption := 'YM';
    Calculate_Level_Tables
  end
end;


function GetConfigINI: Tinifile;
begin
  ForceDirectories(ExtractFileDir(ConfigFilePath));
  Result := TiniFile.Create(ConfigFilePath);
end;


procedure TMainForm.ResetOptions;
var ini: Tinifile;

  procedure SetIntParam(ParamName: string; Value: Integer);
  begin
    ini.WriteInteger('VT', ParamName, Value);
  end;

begin
  SetPriority(0);

  ini := GetConfigINI;
  try
    SetIntParam('SampleRate', 44100);
    SetIntParam('SampleBit', 16);
    SetIntParam('BufLen_ms', 100);
    SetIntParam('NumberOfBuffers', 3);
    SetIntParam('WODevice', 0);
    SetIntParam('Optimization', 1);
    SetIntParam('Filtering', 1);
    SetIntParam('FilterQ', 64);
    SetIntParam('Priority', 32);
    SetIntParam('AY_Freq', 1750000);
    SetIntParam('Interrupt_Freq', 48828);
    SetIntParam('NumberOfChannels', 2);
  finally
    ini.Free;
  end;

end;



procedure TMainForm.GetFileAssocFromText(FileAssocText: string);
var
  i : Integer;
begin

  if Length(FileAssocText) <> Length(FileAssociations) then
    Exit;

  for i := 1 to Length(FileAssocText) do
    FileAssociations[i-1][0] := FileAssocText[i];

end;


function TMainForm.FileAssocToText: string;
var
  i : Integer;
begin

  Result := '';
  for i := 0 to High(FileAssociations) do
    Result := Result + FileAssociations[i][0];

end;


procedure TMainForm.SaveOptions;
var
  i: integer;
  ini: Tinifile;
  Themes: TThemesArray;

  procedure SaveTheme(ThemeNum: Integer; Value: string);
  begin
    ini.WriteString('Themes', IntToStr(ThemeNum), Value);
  end;

  procedure SetStrParam(ParamName, Value: string);
  begin
    ini.WriteString('VT', ParamName, Value);
  end;

  procedure SetIntParam(ParamName: string; Value: Integer);
  begin
    ini.WriteInteger('VT', ParamName, Value);
  end;

  procedure SetBoolParam(ParamName: string; Value: Boolean);
  var v: Integer;
  begin
    if Value then
      v := 1
    else
      v := 0;
    ini.WriteInteger('VT', ParamName, v);
  end;

begin
  SetPriority(0);

  ini := GetConfigINI;

  try
    SetBoolParam('ConfigInited', True);
    SetStrParam('Version', VersionFullString);
    SetIntParam('StartupAction', StartupAction);
    SetStrParam('TemplateSongPath', TemplateSongPath);
    SetStrParam('SamplesDir', SamplesDir);
    SetStrParam('OrnamentsDir', OrnamentsDir);
    SetStrParam('SamplesQuickDir', SamplesQuickDir);
    SetStrParam('OrnamentsQuickDir', OrnamentsQuickDir);
    SetBoolParam('AutoBackups', AutoBackupsOn);
    SetIntParam('AutoBackupsMins', AutoBackupsMins);
    SetIntParam('Priority', Priority);
    SetIntParam('ChanAllocIndex', ChanAllocIndex);
    SetIntParam('PanoramA', Panoram[0]);
    SetIntParam('PanoramB', Panoram[1]);
    SetIntParam('PanoramC', Panoram[2]);
    SetBoolParam('ChanRemapPan', ChanRemapPan);
    SetIntParam('DefaultChipFreq', DefaultChipFreq);
    SetIntParam('ManualChipFreq', ManualChipFreq);
    SetIntParam('DefaultIntFreq', DefaultIntFreq);
    SetIntParam('ExternalTracker', ExternalTracker);
    SetIntParam('SampleRate', SampleRate);
    SetIntParam('SampleBit', SampleBit);
    SetIntParam('NumberOfChannels', NumberOfChannels);
    SetIntParam('BufLen_ms', BufLen_ms);
    SetIntParam('NumberOfBuffers', NumberOfBuffers);
    SetIntParam('WODevice', WODevice);
    SetIntParam('ChipType', Ord(Emulating_Chip));
    SetIntParam('RenderEngine', RenderEngine);
    SetIntParam('FeaturesLevel', FeaturesLevel);
    SetBoolParam('DetectFeaturesLevel', DetectFeaturesLevel);
    SetBoolParam('VortexModuleHeader', VortexModuleHeader);
    SetBoolParam('DetectModuleHeader', DetectModuleHeader);
    SetIntParam('ExportSampleRate', ExportSampleRate);
    SetIntParam('ExportBitRate', ExportBitRate);
    SetIntParam('ExportChannels', ExportChannels);    
    SetIntParam('ExportChip', ExportChip);
    SetIntParam('ExportRepeats', ExportRepeats);
    SetStrParam('ExportPath', ExportPath);    
    for i := 0 to 5 do
      SetStrParam('Recent' + IntToStr(i), RecentFiles[i]);
    i := 0;
    if LoopAllowed then
      i := 1
    else if LoopAllAllowed then
      i := 2;
    SetIntParam('LoopMode', i);
    SetIntParam('GlobalVolume', GlobalVolume);
    SetStrParam('TrackFontName', EditorFont.Name);
    SetStrParam('FileAssoc', FileAssocToText);
    SetStrParam('ShortCuts', AllHotKeysToText);
    SetIntParam('TrackFontSize', EditorFont.Size);
    SetIntParam('PositionSize', PositionSize);
    SetIntParam('CenterOffset', CenterOffset);
    SetBoolParam('TrackFontBold', fsBold in EditorFont.Style);
    SetBoolParam('WindowMaximized', WindowState = wsMaximized);
    SetIntParam('DefaultTable', DefaultTable);

    if WindowState <> wsMaximized then
    begin
      SetIntParam('WindowX', Left);
      SetIntParam('WindowY', Top);
      if LastChildWidth>=400 then
        SetIntParam('WindowWidth', LastChildWidth + DoubleBorderSize);
      SetIntParam('WindowHeight', Height);
    end;

    SetBoolParam('Filtering', IsFilt);
    SetIntParam('FilterQ', Filt_M);
    SetIntParam('DCType', DCType);
    SetIntParam('DCCutOff', DCCutOff);        
    SetStrParam('ColorThemeName', ColorThemeName);
    SetBoolParam('EnvelopeAsNote', EnvelopeAsNote);
    SetBoolParam('SamToneShiftAsNote', SamToneShiftAsNote);
    SetBoolParam('OrnToneShiftAsNote', OrnToneShiftAsNote);
    SetBoolParam('DecBaseLines', DecBaseLinesOn);
    SetBoolParam('DecBaseNoise', DecBaseNoiseOn);
    SetBoolParam('HighlightSpeed', HighlightSpeedOn);
    SetBoolParam('DupNoteParams', DupNoteParams);
    SetBoolParam('MoveBetweenPatrns', MoveBetweenPatrns);
    SetBoolParam('DisableSeparators', DisableSeparators);

    Themes := AllUserThemesToStr;
    SetIntParam('NumThemes', Length(Themes));
    for i := Low(Themes) to High(Themes) do
      SaveTheme(i, Themes[i]);

    SetIntParam('WinThemeIndex', WinThemeIndex);

    for i := 0 to 2 do
      SetBoolParam('ToolBar' + IntToStr(i), PopupMenu3.Items[i].Checked);

    SetBoolParam('DisableHints', DisableHints);
    SetBoolParam('DisableCtrlClick', DisableCtrlClick);
    SetBoolParam('DisableInfoWin', DisableInfoWin);
    SetBoolParam('DisableMidi',DisableMidi);

    SetBoolParam('SampleBrowserVisible', SampleBrowserVisible);
    SetBoolParam('OrnamentsBrowserVisible', OrnamentsBrowserVisible);

  finally
    ini.Free;
  end;
  if not VTExit then SendSyncMessage;
end;


function TMainForm.IsFontValid(FontName: string): Boolean;
var
  TestFont: TFont;
  CelW, CelH: Integer;
  DC: HDC;
  sz: tagSIZE;

begin
  TestFont := TFont.Create;
  TestFont.Name := FontName;
  TestFont.Size := 12;
  DC := GetDC(Handle);
  SelectObject(DC, TestFont.Handle);
  GetTextExtentPoint32(DC, '0', 1, sz);
  CelW := sz.cx;
  CelH := sz.cy;
  ReleaseDC(Handle, DC);

  Result := (CelW > 6) and (CelH > 6) and (CelH < 60) and (CelW < 60);
  {ShowMessage(Format('Font name: %s, Font size: %d, CelW: %d, CelH: %d, Result: %d', [
    TestFont.Name, TestFont.Size, CelW, CelH, Ord(Result)
  ]));}

  TestFont.Free;

end;


procedure TMainForm.LoadOptions;
var
  s: string;
  i, v, defFont: integer;
  b: boolean;
  ini: Tinifile;
  ColorTheme: TColorTheme;

  function LoadTheme(ThemeNum: Integer): string;
  begin
    Result := ini.ReadString('Themes', IntToStr(ThemeNum), '');
  end;

  function GetStrParam(ParamName, DefaultValue: string): string;
  begin
    Result := ini.ReadString('VT', ParamName, DefaultValue);
  end;

  function GetIntParam(ParamName: string; DefaultValue: Integer): Integer;
  begin
    Result := ini.ReadInteger('VT', ParamName, DefaultValue);
  end;

  function GetBoolParam(ParamName: string; DefaultValue: Boolean): Boolean;
  var def: Integer;
  begin
    if DefaultValue then
      def := 1
    else
      def := 0;
    Result := ini.ReadInteger('VT', ParamName, def) = 1;
  end;


begin

  // Remove config if version changed
  ini := GetConfigINI;
  try
    if GetStrParam('Version', '') <> VersionFullString then
      DeleteFile(ConfigFilePath);
  finally
    ini.Free;
  end;

  
  ini := GetConfigINI;
  try

    // Vortex started first time with clean config
    if not GetBoolParam('ConfigInited', False) then
      VortexFirstStart := True;

    StartupAction := GetIntParam('StartupAction', 1);
    TemplateSongPath := GetStrParam('TemplateSongPath', '');

    AutoBackupsOn   := GetBoolParam('AutoBackups', True);
    AutoBackupsMins := GetIntParam('AutoBackupsMins', 1);

    if VortexFirstStart then
      CheckFileAssociations
    else
    begin
      s := GetStrParam('FileAssoc', '');
      if s <> '' then
        GetFileAssocFromText(s);
    end;

    s := GetStrParam('ShortCuts', '');
    if s <> '' then
      LoadHotKeysFromText(s)
    else
      SetDefaultHotKeys;

    v := GetIntParam('Priority', NORMAL_PRIORITY_CLASS);
    SetPriority(v);

    SamplesDir   := GetStrParam('SamplesDir', VortexDocumentsDir + SamplesDefaultDir);
    OrnamentsDir := GetStrParam('OrnamentsDir', VortexDocumentsDir + OrnamentsDefaultDir);

    if not DirectoryExists(SamplesDir)   then SamplesDir   := 'C:\';
    if not DirectoryExists(OrnamentsDir) then OrnamentsDir := 'C:\';

    SamplesQuickDir   := GetStrParam('SamplesQuickDir', '');
    OrnamentsQuickDir := GetStrParam('OrnamentsQuickDir', '');

    if not DirectoryExists(SamplesQuickDir)   then SamplesQuickDir   := '';
    if not DirectoryExists(OrnamentsQuickDir) then OrnamentsQuickDir := '';

    if not SyncVTInstanses then
    begin
      EnvelopeAsNote     := GetBoolParam('EnvelopeAsNote', False);
      SamToneShiftAsNote := GetBoolParam('SamToneShiftAsNote', False);
      OrnToneShiftAsNote := GetBoolParam('OrnToneShiftAsNote', False);            
      MoveBetweenPatrns  := GetBoolParam('MoveBetweenPatrns', True);
      DupNoteParams      := GetBoolParam('DupNoteParams', False);
      TrackBar1.Position := GetIntParam('GlobalVolume', 56);
      ChanAllocIndex     := GetIntParam('ChanAllocIndex', 1);
      ChanRemapPan       := GetBoolParam('ChanRemapPan', False);
      SetChannelsAllocation(ChanAllocIndex);
      Panoram[0]         := GetIntParam('PanoramA', 64);
      Panoram[1]         := GetIntParam('PanoramB', 128);
      Panoram[2]         := GetIntParam('PanoramC', 192);

      v := GetIntParam('LoopMode', 1);
      case v of
        1: ToggleLooping.Execute;
        2: ToggleLoopingAll.Execute
      end;
    end;

    if not IsPlaying then
    begin
      SampleRate := GetIntParam('SampleRate', 44100);
      SetSampleRate(SampleRate);

      SampleBit := GetIntParam('SampleBit', 16);
      SetBitRate(SampleBit);

      NumberOfChannels := GetIntParam('NumberOfChannels', 2);
      SetNChans(NumberOfChannels);

      NumberOfBuffers := GetIntParam('NumberOfBuffers', 3);
      BufLen_ms := GetIntParam('BufLen_ms', 100);
      SetBuffers(BufLen_ms, NumberOfBuffers);

      WODevice := GetIntParam('WODevice', 0);



    end;


    if not IsPlaying or (PlayMode = PMPlayLine) then begin
      DCType   := GetIntParam('DCType', 1);
      DCCutOff := GetIntParam('DCCutOff', 3);

      v := GetIntParam('ChipType', 2); // YM by default
      if v in [1, 2] then
        SetEmulatingChip(ChTypes(v))
      else
        SetEmulatingChip(ChTypes(2));

      v := GetIntParam('RenderEngine', 2); // Ayumi render by default
      Set_Engine(v);
    end;

    ExportSampleRate := GetIntParam('ExportSampleRate', 1);
    ExportBitRate    := GetIntParam('ExportBitRate', 0);
    ExportChannels   := GetIntParam('ExportChannels', 1);    
    ExportChip       := GetIntParam('ExportChannels', 1);
    ExportRepeats    := GetIntParam('ExportRepeats', 0);
    ExportPath       := GetStrParam('ExportPath', '');

    FeaturesLevel := GetIntParam('FeaturesLevel', 3);
    DetectFeaturesLevel := GetBoolParam('DetectFeaturesLevel', True);

    VortexModuleHeader := GetBoolParam('VortexModuleHeader', True);
    DetectModuleHeader := GetBoolParam('DetectModuleHeader', True);

    DefaultChipFreq := GetIntParam('DefaultChipFreq', 1750000);
    ManualChipFreq := GetIntParam('ManualChipFreq', 0);
    DefaultIntFreq := GetIntParam('DefaultIntFreq', 48828);

    ExternalTracker := GetIntParam('ExternalTracker', 0);

    b := GetBoolParam('Filtering', True);
    SetFilter(b, Filt_M);

    v := GetIntParam('FilterQ', 64);
    SetFilter(IsFilt, v);
    
    DefaultTable := GetIntParam('DefaultTable', 2);

    for i := 5 downto 0 do
    begin
      s := GetStrParam(PChar('Recent' + IntToStr(i)), '');
      if (s  <> '') and FileExists(s) then
        AddFileName(s);
    end;



    defFont := 16;
    if VortexFirstStart then
      if MonitorWorkAreaHeight <= 600 then
        Top := 0
      else if MonitorWorkAreaHeight <= 768 then
        Top := 5
      else if MonitorWorkAreaHeight <= 840 then
        Top := 10
      else if MonitorWorkAreaHeight <= 900 then
        Top := 15
      else if MonitorWorkAreaHeight <= 1024 then
        Top := 20
      else if MonitorWorkAreaHeight <= 1200 then
      else if MonitorWorkAreaHeight <= 1400 then
        defFont := 17
      else if MonitorWorkAreaHeight <= 1600 then
        defFont := 18
      else
        defFont := 20;

    PositionSize := GetIntParam('PositionSize', 2);

    CenterOffset := GetIntParam('CenterOffset', 0);

    if not SyncVTInstanses then
    begin

      Width := GetIntParam('WindowWidth', (defFont - 4)  * 52);
      Height := GetIntParam('WindowHeight', MonitorWorkAreaHeight - 60);

      Left := GetIntParam('WindowX', (MonitorWorkAreaWidth div 2) - (Width div 2) - 200);
      Top  := GetIntParam('WindowY', (MonitorWorkAreaHeight div 2) - (Height div 2));

      // Window on a second monitor, but monitor turned off.
      if (Left < Monitor.Left) or (Left >= Monitor.Width) then
        Left := (MonitorWorkAreaWidth div 2) - (Width div 2) - 200;

      if (Top < Monitor.Top) or (Top >= Monitor.Height) then
        Top := (MonitorWorkAreaHeight div 2) - (Height div 2);


      if GetBoolParam('WindowMaximized', False) then
        WindowState := wsMaximized
      else
        WindowState := wsNormal;
    end;


    s := GetStrParam('TrackFontName', 'Consolas');
    if IsFontExists(s) then
      EditorFont.Name := s
    else if IsFontExists('Consolas') then
      EditorFont.Name := 'Consolas'
    else if IsFontExists('Courier New') then
      EditorFont.Name := 'Courier New';

    if not IsFontValid(EditorFont.Name) then
    begin
      EditorFont.Name := 'Consolas';
      EditorFont.Size := defFont;
      if not IsFontValid(EditorFont.Name) then
      begin
        EditorFont.Name := 'Lucida Console';
        EditorFont.Size := defFont;
        if not IsFontValid(EditorFont.Name) then
        begin
          EditorFont.Name := 'Courier New';
          EditorFont.Size := defFont;
        end;
      end;
    end;

    EditorFont.Size := GetIntParam('TrackFontSize', defFont);
    if EditorFont.Size < 12 then
      EditorFont.Size := 12;

    if GetBoolParam('TrackFontBold', False) then
      EditorFont.Style := EditorFont.Style + [fsBold]
    else
      EditorFont.Style := EditorFont.Style - [fsBold];


    v := GetIntParam('NumThemes', 0);
    if v <> 0 then
    begin
      SetLength(VTColorThemes, 0);
      for i := 0 to v-1 do
      begin
        ColorTheme := LoadColorThemeFromStr(LoadTheme(i));
        if ColorTheme.Name = '' then Continue;
        SetLength(VTColorThemes, Length(VTColorThemes)+1);
        VTColorThemes[i] := ColorTheme;
      end;
    end;
    ColorThemeName := GetStrParam('ColorThemeName', 'Default');

    InitColorThemes;

    WinThemeIndex := GetIntParam('WinThemeIndex', 0);
    SetWindowColors(WinThemeIndex);

    DecBaseLinesOn := GetBoolParam('DecBaseLines', False);
    DecBaseNoiseOn := GetBoolParam('DecBaseNoise', False);
    DisableSeparators := GetBoolParam('DisableSeparators', False);
    HighlightSpeedOn := GetBoolParam('HighlightSpeed', False);

    if DecBaseLinesOn then
      TracksCursorXLeft := 4
    else
      TracksCursorXLeft := 3;

    for i := 0 to 2 do
    begin
      b := GetBoolParam('ToolBar' + IntToStr(i), True);
      SetBar(i, b);
    end;

    DisableHints := GetBoolParam('DisableHints', False);
    DisableCtrlClick := GetBoolParam('DisableCtrlClick', False);
    DisableInfoWin := GetBoolParam('DisableInfoWin', False);
    DisableMidi := GetBoolParam('DisableMidi', False);
    SampleBrowserVisible := GetBoolParam('SampleBrowserVisible', True);
    OrnamentsBrowserVisible := GetBoolParam('OrnamentsBrowserVisible', True);

  finally
     ini.Free;
  end;
end;


function TMainForm.IsFileAssociationExists(FileExt: string): boolean;
begin
  Result := False;
  with TRegistry.Create do
  try
    begin
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('\Software\Classes\' + FileExt, True) then
        Result := True;
    end;
  finally
    Free;
  end;
end;

function TMainForm.IsVortexFileAssociation(FileExt, AssocName: string): boolean;
var
  ExtOk, PathOk, IconOk: Boolean;
begin
  ExtOk  := False;
  PathOk := False;
  IconOk := False;

  with TRegistry.Create do
  try
    begin
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('\Software\Classes\' + FileExt, True) then
        if ReadString('') = 'VortexTracker2' then
          ExtOk := True;
      if OpenKey('\Software\Classes\'+ AssocName +'\shell\open\command', true) then
        if ReadString('') = Application.ExeName +' "%1"' then
          PathOk := True;
      if OpenKey('\Software\Classes\'+ AssocName +'\DefaultIcon', true) then
        if ReadString('') = Application.ExeName +',0' then
          IconOk := True;
    end;
  finally
    Free;
  end;

  Result := ExtOk and PathOk and IconOk;
end;


procedure TMainForm.CheckFileAssociations;
var
  i: Integer;
  FileExt, AssocName: String;
begin

  for i := 0 to High(FileAssociations) do
  begin
    FileExt   := FileAssociations[i][1];
    AssocName := FileAssociations[i][2];

    // Unckeck file association if already taken by another application
    if IsFileAssociationExists(FileExt) and not IsVortexFileAssociation(FileExt, AssocName) then
      FileAssociations[i][0] := '0';
  end;
end;


procedure TMainForm.SetFileAssociations;
var
  i: Integer;
  FileExt, AssocName: String;

  procedure CreateAssociation(FileExt, Name, Description: string);
  begin

    with TRegistry.Create do
    try
      begin
        RootKey := HKEY_CURRENT_USER;
        if OpenKey('\Software\Classes\' + FileExt, True) then
          WriteString('', 'VortexTracker2');
        if OpenKey('\Software\Classes\'+ Name, true) then
          WriteString('', Description);
        if OpenKey('\Software\Classes\'+ Name +'\DefaultIcon', true) then
          WriteString('', Application.ExeName +',0');
        if OpenKey('\Software\Classes\'+ Name +'\shell\open\command', true) then
          WriteString('', Application.ExeName +' "%1"');
      end;
    finally
	    Free;
    end;
  end;

  procedure RemoveAssociation(FileExt, Name: string);
  begin
    with TRegistry.Create do
    try
      begin
        RootKey := HKEY_CURRENT_USER;
        DeleteKey('\Software\Classes\'+ FileExt);
        DeleteKey('\Software\Classes\'+ Name);
      end;
    finally
	    Free;
    end;
  end;

begin

  FileAssocChanged := False;

  // Check is file associations changed
  for i := 0 to High(FileAssociations) do begin
    FileExt := FileAssociations[i][1];
    AssocName := FileAssociations[i][2];
    if (FileAssociations[i][0] = '1') and (not IsFileAssociationExists(FileExt) or not IsVortexFileAssociation(FileExt, AssocName)) then
    begin
      FileAssocChanged := True;
      Break;
    end;

    if (FileAssociations[i][0] = '0') and IsFileAssociationExists(FileExt) and IsVortexFileAssociation(FileExt, AssocName) then
    begin
      FileAssocChanged := True;
      Break;
    end;
  end;

  if not FileAssocChanged then Exit;

  for i := 0 to High(FileAssociations) do begin
    RemoveAssociation(FileAssociations[i][1], FileAssociations[i][2]);
    if FileAssociations[i][0] = '1' then
      CreateAssociation(FileAssociations[i][1], FileAssociations[i][2], FileAssociations[i][3]);
  end;


  // Notify to Windows - file associations was changed
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);

  FileAssocChanged := False;

end;


procedure TMainForm.SaveSNDHMenuClick(Sender: TObject);
const
  TITL: array[0..3] of char = 'TITL';
  COMM: array[0..3] of char = 'COMM';
  CONV: array[0..3] of char = 'CONV';
  YEAR: array[0..3] of char = 'YEAR';
  TIME: array[0..3] of char = 'TIME';
var
  sndhplsz, sndhhdrsz: integer;
  PT3: TSpeccyModule;
  Size, i, j: integer;
  f: file;
  p: wordptr;
  CurrentWindow: TMDIChild;
  s: string;
  ErrMsg: string;
begin
  if MDIChildCount = 0 then exit;
  CurrentWindow := TMDIChild(ActiveMDIChild);
  if SaveDialogSNDH.InitialDir = '' then
    SaveDialogSNDH.InitialDir := OpenDialog.InitialDir;

  if CurrentWindow.WinFileName = '' then
    MainForm.SaveDialogSNDH.FileName := 'VTIIModule' + IntToStr(CurrentWindow.WinNumber)
  else
    MainForm.SaveDialogSNDH.FileName := ChangeFileExt(CurrentWindow.WinFileName, '');

  repeat
    if not SaveDialogSNDH.Execute then exit;
    s := LowerCase(ExtractFileExt(SaveDialogSNDH.FileName));
    if s = '.snd' then
      SaveDialogSNDH.FileName := SaveDialogSNDH.FileName + 'h'
    else if s <> '.sndh' then
      SaveDialogSNDH.FileName := SaveDialogSNDH.FileName + '.sndh'
  until AllowSave(SaveDialogSNDH.FileName);

  SaveDialogSNDH.InitialDir := ExtractFileDir(SaveDialogSNDH.FileName);
  i := FindResource(HInstance, 'SNDHPLAYER', 'SNDH');
  sndhplsz := SizeofResource(HInstance, i);
  p := LockResource(LoadResource(HInstance, i));
  ErrMsg := VTM2PT3(@PT3, CurrentWindow.VTMP, Size);
  if ErrMsg<>'' then
  begin
    Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(SaveDialogSNDH.FileName));
    exit
  end;
  AssignFile(f, SaveDialogSNDH.FileName);
  Rewrite(f, 1);
  BlockWrite(f, p^, 16);
  sndhhdrsz := 10;
  with CurrentWindow do
  begin
    i := Length(VTMP.Title);
    if i <> 0 then
    begin
      inc(sndhhdrsz, 4 + i + 1);
      BlockWrite(f, TITL, 4);
      BlockWrite(f, VTMP.Title[1], i + 1)
    end;
    i := Length(VTMP.Author);
    if i <> 0 then
    begin
      inc(sndhhdrsz, 4 + i + 1);
      BlockWrite(f, COMM, 4);
      BlockWrite(f, VTMP.Author[1], i + 1)
    end;
    BlockWrite(f, CONV, 4);
    i := Length(FullVersString) + 1; inc(sndhhdrsz, i);
    BlockWrite(f, FullVersString[1], i);
    s := '';
    if InputQuery('SNDHv2 Extra TAG', 'Year of release (empty if no):', s) then
    begin
      s := Trim(s);
      i := Length(s);
      if i <> 0 then
      begin
        inc(sndhhdrsz, i + 5);
        BlockWrite(f, YEAR, 4);
        BlockWrite(f, s[1], i + 1);
      end;
    end;
    j := round(Interrupt_Freq / 1000);
    s := 'TC' + IntToStr(j);
    i := Length(s) + 1; inc(sndhhdrsz, i);
    BlockWrite(f, s[1], i);
    BlockWrite(f, TIME, 4);
    i := round(TotInts / j); if i > 65535 then i := 65535;
    i := IntelWord(i);
    BlockWrite(f, i, 2);
    if (sndhhdrsz and 1) <> 0 then
    begin
      inc(sndhhdrsz);
      i := 0; BlockWrite(f, i, 1);
    end;
    BlockWrite(f, pointer(integer(p) + 16)^, sndhplsz - 16);
    BlockWrite(f, PT3, Size);
  end;
  dec(integer(p), 2);
  for j := 0 to 2 do
  begin
    inc(integer(p), 4);
    i := IntelWord(IntelWord(p^) + sndhhdrsz);
    seek(f, 2 + j * 4); BlockWrite(f, i, 2);
  end;
  CloseFile(f)
end;

procedure TMainForm.SaveforZXMenuClick(Sender: TObject);
var
  s: string;
  PT3_1, PT3_2: TSpeccyModule;
  i, t, j, k: integer;
  f: file;
  p: WordPtr;
  pl: array of byte;
  hobetahdr: packed record
    case Boolean of
      False:
      (Name: array[0..7] of char; Typ: char;
        Start, Leng, SectLeng, CheckSum: word);
      True:
      (Ind: array[0..16] of byte);
  end;
  SCLHdr: packed record
    case Boolean of
      False:
      (SCL: array[0..7] of char;
        NBlk: byte;
        Name1: array[0..7] of char; Typ1: char; Start1, Leng1: word; Sect1: byte;
        Name2: array[0..7] of char; Typ2: char; Start2, Leng2: word; Sect2: byte; );
      True:
      (Ind: array[0..36] of byte);
  end;
  TAPHdr: packed record
    case Boolean of
      False:
      (Sz: word; Flag, Typ: byte;
        Name: array[0..9] of char; Leng, Start, Trash: word; Sum: byte);
      True:
      (Ind: array[0..20] of byte);
  end;
  AYFileHeader: TAYFileHeader;
  SongStructure: TSongStructure;
  AYSongData: TSongData;
  AYPoints: TPoints;
  CurrentWindow: TMDIChild;
  ErrMsg:String;
begin
  if MDIChildCount = 0 then exit;
  CurrentWindow := TMDIChild(ActiveMDIChild);
  ErrMsg:=VTM2PT3(@PT3_1, CurrentWindow.VTMP, ZXModSize1);
  if ErrMsg<>'' then
  begin
    Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(CurrentWindow.Caption));
    exit;
  end;
  ZXModSize2 := 0;
  if (CurrentWindow.TSWindow[0] <> nil) then
  begin
    ErrMsg:=VTM2PT3(@PT3_2, CurrentWindow.TSWindow[0].VTMP, ZXModSize2);
    if ErrMsg<>'' then
    begin
      Application.MessageBox(PAnsiChar(ErrMsg), PAnsiChar(CurrentWindow.TSWindow[0].Caption));
      exit;
    end;
  end;
  if CurrentWindow.TSWindow[0] = nil then
    i := FindResource(HInstance, 'ZXAYPLAYER', 'ZXAY')
  else
    i := FindResource(HInstance, 'ZXTSPLAYER', 'ZXTS');
  p := LockResource(LoadResource(HInstance, i));
  Move(p^, zxplsz, 2);
  Inc(integer(p), 2);
  Move(p^, zxdtsz, 2);
  if ExpDlg.ShowModal <> mrOK then exit;
  if SaveDialogZXAY.InitialDir = '' then
    SaveDialogZXAY.InitialDir := OpenDialog.InitialDir;
  SaveDialogZXAY.FilterIndex := ExpDlg.RadioGroup1.ItemIndex + 1;
  SetDialogZXAYExt;

  if CurrentWindow.WinFileName <> '' then
    SaveDialogZXAY.FileName := ChangeFileExt(CurrentWindow.WinFileName, '')
  else if (CurrentWindow.TSWindow[0] <> nil) and (CurrentWindow.TSWindow[0].WinFileName <> '') then
    SaveDialogZXAY.FileName := ChangeFileExt(CurrentWindow.TSWindow[0].WinFileName, '')
  else
    SaveDialogZXAY.FileName := 'VTIIModule' + IntToStr(CurrentWindow.WinNumber);

  repeat
    if not SaveDialogZXAY.Execute then exit;
    i := SaveDialogZXAY.FilterIndex - 1;
    if not (i in [0..4]) then i := ExpDlg.RadioGroup1.ItemIndex;
    case i of
      0: ChangeFileExt(SaveDialogZXAY.FileName, '$c');
      1: ChangeFileExt(SaveDialogZXAY.FileName, '$m');
      2: ChangeFileExt(SaveDialogZXAY.FileName, 'ay');
      3: ChangeFileExt(SaveDialogZXAY.FileName, 'scl');
      4: ChangeFileExt(SaveDialogZXAY.FileName, 'tap')
    end;
  until AllowSave(SaveDialogZXAY.FileName);

  SaveDialogZXAY.InitialDir := ExtractFileDir(SaveDialogZXAY.FileName);
  if SaveDialogZXAY.FilterIndex in [1..5] then
    ExpDlg.RadioGroup1.ItemIndex := SaveDialogZXAY.FilterIndex - 1;
  t := ExpDlg.RadioGroup1.ItemIndex;
  if t <> 1 then
  begin
    if ZXModSize1 + ZXModSize2 + zxplsz + zxdtsz > 65536 then
    begin
      Application.MessageBox('Size of module with player exceeds 65536 bytes.', 'Cannot export');
      exit;
    end;
    Inc(integer(p), 2);
    SetLength(pl, zxplsz);
    Move(p^, pl[0], zxplsz);
    Inc(integer(p), zxplsz);
    while p^ < zxplsz - 1 do
    begin
      Inc(WordPtr(@pl[p^])^, ZXCompAddr);
      Inc(integer(p), 2);
    end;
    Inc(integer(p), 2);
    while p^ < zxplsz do
    begin
      Inc(BytePtr(@pl[p^])^, ZXCompAddr);
      Inc(integer(p), 2);
    end;
    Inc(integer(p), 2);
    while p^ < zxplsz do
    begin
      i := p^;
      Inc(integer(p), 2);
      BytePtr(@pl[i])^ := (p^ + ZXCompAddr) shr 8;
      Inc(integer(p), 2);
    end;
    if ExpDlg.LoopChk.Checked then pl[10] := pl[10] or 1;
  end;
  AssignFile(f, SaveDialogZXAY.FileName);
  Rewrite(f, 1);
  try
    i := ZXModSize1;
    case t of
      0, 1:
        begin
          inc(i, ZXModSize2);
          if t = 0 then
            inc(i, zxplsz + zxdtsz)
          else
            inc(i, 16);
          with hobetahdr do
          begin
            Name := '        ';
            s := ExtractFileName(SaveDialogZXAY.FileName);
            j := Length(s) - 3;
            if j > 8 then j := 8;
            if j > 0 then Move(s[1], Name, j);
            if t = 0 then
              Typ := 'C'
            else
              Typ := 'm';
            Start := ZXCompAddr;
            Leng := i;
            SectLeng := i and $FF00;
            if i and 255 <> 0 then Inc(SectLeng, $100);
            if SectLeng = 0 then
            begin
              Application.MessageBox('Size of hobeta file exceeds 255 sectors.', 'Cannot export');
              exit;
            end;
            k := 0;
            for j := 0 to 14 do
              Inc(k, Ind[j]);
            CheckSum := k * 257 + 105;
          end;
          BlockWrite(f, hobetahdr, sizeof(hobetahdr));
        end;
      2:
        begin
          with AYFileHeader do
          begin
            FileID := $5941585A;
            TypeID := $4C554D45;
            FileVersion := 0;
            PlayerVersion := 0;
            PSpecialPlayer := 0;
            j := 8 + SizeOf(TSongStructure) + SizeOf(TSongData) + SizeOf(TPoints) +
              Length(CurrentWindow.VTMP.Title) + 1;
            PAuthor := IntelWord(j);
            inc(j, Length(CurrentWindow.VTMP.Author) + 1 - 2);
            PMisc := IntelWord(j);
            NumOfSongs := 0;
            FirstSong := 0;
            PSongsStructure := $200;
          end;
          BlockWrite(f, AYFileHeader, SizeOf(TAYFileHeader));
          with SongStructure do
          begin
            PSongName := IntelWord(4 + SizeOf(TSongData) + SizeOf(TPoints));
            PSongData := $200;
          end;
          BlockWrite(f, SongStructure, SizeOf(TSongStructure));
          with AYSongData do
          begin
            ChanA := 0;
            ChanB := 1;
            ChanC := 2;
            Noise := 3;
            j := CurrentWindow.TotInts;
            if (CurrentWindow.TSWindow[0] <> nil) and (CurrentWindow.TSWindow[0].TotInts > j) then
              j := CurrentWindow.TSWindow[0].TotInts;
            if j > 65535 then SongLength := 65535 else SongLength := IntelWord(j);
            FadeLength := 0;
            if CurrentWindow.TSWindow[0] = nil then
            begin
              HiReg := 0;
              LoReg := 0;
            end
            else
            begin
              j := ZXCompAddr + zxplsz + zxdtsz + ZXModSize1;
              HiReg := j shr 8;
              LoReg := j;
            end;
            PPoints := $400;
            PAddresses := $800;
          end;
          BlockWrite(f, AYSongData, SizeOf(TSongData));
          with AYPoints do
          begin
            Stek := IntelWord(ZXCompAddr);
            Init := IntelWord(ZXCompAddr);
            Inter := IntelWord(ZXCompAddr + 5);
            Adr1 := IntelWord(ZXCompAddr);
            Len1 := IntelWord(zxplsz);
            j := 10 + Length(CurrentWindow.VTMP.Title) +
              Length(CurrentWindow.VTMP.Author) +
              Length(FullVersString) + 3;
            Offs1 := IntelWord(j);
            Adr2 := IntelWord(ZXCompAddr + zxplsz + zxdtsz);
            Len2 := IntelWord(ZXModSize1 + ZXModSize2);
            Offs2 := IntelWord(j - 6 + zxplsz);
            Zero := 0;
          end;
          BlockWrite(f, AYPoints, SizeOf(TPoints));
          j := Length(CurrentWindow.VTMP.Title);
          if j <> 0 then
            BlockWrite(f, CurrentWindow.VTMP.Title[1], j + 1)
          else
            BlockWrite(f, j, 1);
          j := Length(CurrentWindow.VTMP.Author);
          if j <> 0 then
            BlockWrite(f, CurrentWindow.VTMP.Author[1], j + 1)
          else
            BlockWrite(f, j, 1);
          BlockWrite(f, FullVersString[1], Length(FullVersString) + 1);
        end;
      3:
        begin
          with SCLHdr do
          begin
            SCL := 'SINCLAIR'; NBlk := 2;
            if CurrentWindow.TSWindow[0] <> nil then
              Name1 := 'tsplayer'
            else
              Name1 := 'vtplayer';
            Typ1 := 'C';
            Start1 := ZXCompAddr; Leng1 := zxplsz;
            Sect1 := zxplsz shr 8;
            if zxplsz and 255 <> 0 then Inc(Sect1);
            Name2 := '        ';
            s := ExtractFileName(SaveDialogZXAY.FileName);
            j := Length(s) - 4;
            if j > 8 then j := 8;
            if j > 0 then Move(s[1], Name2, j);
            Typ2 := 'C';
            Start2 := ZXCompAddr + zxplsz + zxdtsz;
            Leng2 := ZXModSize1 + ZXModSize2;
            Sect2 := Leng2 shr 8;
            if Leng2 and 255 <> 0 then Inc(Sect2);
            k := 0;
            for j := 0 to sizeof(SCLHdr) - 1 do Inc(k, Ind[j]);
          end;
          BlockWrite(f, SCLHdr, sizeof(SCLHdr));
          for j := 0 to zxplsz - 1 do Inc(k, pl[j]);
          for j := 0 to ZXModSize1 - 1 do Inc(k, PT3_1.Index[j]);
          if CurrentWindow.TSWindow[0] <> nil then
            for j := 0 to ZXModSize2 - 1 do Inc(k, PT3_2.Index[j]);
        end;
      4:
        begin
          with TAPHdr do
          begin
            Sz := 19; Flag := 0; Typ := 3;
            if CurrentWindow.TSWindow[0] <> nil then
              Name := 'tsplayer  '
            else
              Name := 'vtplayer  ';
            Leng := zxplsz; Start := ZXCompAddr; Trash := 32768;
            k := 0; for j := 2 to 19 do k := k xor Ind[j]; Sum := k;
            BlockWrite(f, TAPHdr, 21);
            Sz := 2 + zxplsz; Flag := 255;
          end;
          BlockWrite(f, TAPHdr, 3);
        end
    end;
    if t <> 1 then BlockWrite(f, pl[0], zxplsz);
    case t of
      4:
        begin
          with TAPHdr do
          begin
            k := 255; for j := 0 to zxplsz - 1 do k := k xor pl[j];
            BlockWrite(f, k, 1);
            Sz := 19; Flag := 0; Typ := 3; Name := '          ';
            Leng := ZXModSize1 + ZXModSize2; Start := ZXCompAddr + zxplsz + zxdtsz; Trash := 32768;
            s := ExtractFileName(SaveDialogZXAY.FileName);
            j := Length(s) - 4;
            if j > 10 then j := 10;
            if j > 0 then Move(s[1], Name, j);
            k := 0; for j := 2 to 19 do k := k xor Ind[j]; Sum := k;
            BlockWrite(f, TAPHdr, 21);
            Sz := 2 + ZXModSize1 + ZXModSize2; Flag := 255;
          end;
          BlockWrite(f, TAPHdr, 3);
        end;
      3:
        begin
          j := zxplsz mod 256;
          if j <> 0 then
          begin
            j := 256 - j;
            FillChar(pl[0], j, 0);
            BlockWrite(f, pl[0], j)
          end;
        end;
      0:
        begin
          if zxdtsz > zxplsz then SetLength(pl, zxdtsz);
          FillChar(pl[0], zxdtsz, 0);
          BlockWrite(f, pl[0], zxdtsz)
        end;
    end;
    BlockWrite(f, PT3_1, ZXModSize1);
    if CurrentWindow.TSWindow[0] <> nil then BlockWrite(f, PT3_2, ZXModSize2);
    case t of
      4:
        begin
          k := 255; for j := 0 to ZXModSize1 - 1 do k := k xor PT3_1.Index[j];
          if CurrentWindow.TSWindow[0] <> nil then
            for j := 0 to ZXModSize2 - 1 do k := k xor PT3_2.Index[j];
          BlockWrite(f, k, 1);
        end;
      3:
        begin
          j := (ZXModSize1 + ZXModSize2) mod 256;
          if j <> 0 then
          begin
            j := 256 - j;
            FillChar(pl[0], j, 0);
            BlockWrite(f, pl[0], j)
          end;
          BlockWrite(f, k, 4);
        end;
      0..1:
        begin
          if (t = 1) and (CurrentWindow.TSWindow[0] <> nil) then
          begin
            TSData2.Size1 := ZXModSize1;
            TSData2.Size2 := ZXModSize2;
            BlockWrite(f, TSData2, SizeOf(TSData2));
          end;
          with hobetahdr do
            if SectLeng <> i then
            begin
              FillChar(PT3_1, SectLeng - i, 0);
              BlockWrite(f, PT3_1, SectLeng - i);
            end;
        end;
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TMainForm.SetDialogZXAYExt;
var
  i: integer;
begin
  i := SaveDialogZXAY.FilterIndex - 1;
  if not (i in [0..4]) then i := ExpDlg.RadioGroup1.ItemIndex;
  case i of
    0: SaveDialogZXAY.DefaultExt := '$c';
    1: SaveDialogZXAY.DefaultExt := '$m';
    2: SaveDialogZXAY.DefaultExt := 'ay';
    3: SaveDialogZXAY.DefaultExt := 'scl';
    4: SaveDialogZXAY.DefaultExt := 'tap'
  end
end;

procedure TMainForm.SaveDialogZXAYTypeChange(Sender: TObject);
begin
  SetDialogZXAYExt
end;

procedure TMainForm.SetPriority;
var
  HMyProcess: longword;
begin
  if Pr <> 0 then
    Priority := Pr
  else
    Pr := NORMAL_PRIORITY_CLASS;
  HMyProcess := GetCurrentProcess;
  SetPriorityClass(HMyProcess, Pr);
  CloseHandle(HMyProcess);
end;

function CanCopy: boolean;
var
  A: TWinControl;
begin
  Result := MainForm.MDIChildCount <> 0;
  if not Result then Exit;

  if ExportStarted then
  begin
    Result := False;
    Exit;
  end;

  A := TMDIChild(MainForm.ActiveMDIChild).ActiveControl;

  if (A is TCustomEdit) and ((A as TCustomEdit).SelLength > 0) then
    Result := True

  else if TMDIChild(MainForm.ActiveMDIChild).Tracks = A then
    Result := True

  else if TMDIChild(MainForm.ActiveMDIChild).Samples = A then
    Result := True

  else if TMDIChild(MainForm.ActiveMDIChild).Ornaments = A then
    Result := True

  else if TMDIChild(MainForm.ActiveMDIChild).StringGrid2 = A then
    Result := True

  else if TMDIChild(MainForm.ActiveMDIChild).StringGrid3 = A then
    Result := True

  else
    Result := False;


end;

procedure TMainForm.EditCopy1Update(Sender: TObject);
begin
  EditCopy1.Enabled := CanCopy
end;

procedure TMainForm.EditCut1Update(Sender: TObject);
begin
  EditCut1.Enabled := CanCopy
end;

procedure TMainForm.EditPaste1Update(Sender: TObject);
var
  A: TWinControl;
  R: boolean;
begin
  R := MainForm.MDIChildCount <> 0;
  if not R then
  begin
    EditPaste1.Enabled := False;
    Exit;
  end;

  if ExportStarted then
  begin
    EditPaste1.Enabled := False;
    Exit;
  end;

  A := TMDIChild(MainForm.ActiveMDIChild).ActiveControl;

  if A is TCustomEdit then
    R := True

  else if TMDIChild(MainForm.ActiveMDIChild).Tracks = A then
    R := True

  else if TMDIChild(MainForm.ActiveMDIChild).Samples = A then
    R := True

  else if TMDIChild(MainForm.ActiveMDIChild).Ornaments = A then
    R := True

  else if TMDIChild(MainForm.ActiveMDIChild).StringGrid2 = A then
    R := True

  else if TMDIChild(MainForm.ActiveMDIChild).StringGrid3 = A then
    R := True

  else
    R := False;

  EditPaste1.Enabled := R;
end;

function GetCopyControl(var CT: integer; var WC: TWinControl): boolean;
begin
  Result := MainForm.MDIChildCount <> 0;
  if Result then
  begin
    CT := -1;
    WC := TMDIChild(MainForm.ActiveMDIChild).ActiveControl;
    if WC is TCustomEdit then
    begin
      CT := 0;
      Result := True;
      Exit;
    end;

    if CT < 0 then
    begin
      Result := TMDIChild(MainForm.ActiveMDIChild).Tracks = WC;
      if Result then
      begin
        CT := 1;
        Exit;
      end;

      Result := TMDIChild(MainForm.ActiveMDIChild).Samples = WC;
      if Result then
      begin
        CT := 2;
        Exit;
      end;

      Result := TMDIChild(MainForm.ActiveMDIChild).Ornaments = WC;
      if Result then
      begin
        CT := 3;
        Exit
      end;

      Result := TMDIChild(MainForm.ActiveMDIChild).StringGrid2 = WC;
      if Result then
      begin
        CT := 4;
        Exit;
      end;

      Result := TMDIChild(MainForm.ActiveMDIChild).StringGrid3 = WC;
      if Result then
      begin
        CT := 5;
        Exit;
      end;

    end;
  end
end;

procedure TMainForm.EditCut1Execute(Sender: TObject);
var
  CtrlType: integer;
  WC: TWinControl;
begin
  if GetCopyControl(CtrlType, WC) then
    case CtrlType of
      0: (WC as TCustomEdit).CutToClipboard;
      1: (WC as TTracks).CutToClipboard;
//      2: (WC as TSample).CutToClipBoard;
      3: (WC as TOrnaments).CutToClipBoard;  //weird!!!
      4: TMDIChild(MainForm.ActiveMDIChild).CutSample1Click(self);
      5: TMDIChild(MainForm.ActiveMDIChild).CutOrnament1Click(self);
    end;
end;

procedure TMainForm.EditCopy1Execute(Sender: TObject);
var
  CtrlType: integer;
  WC: TWinControl;
begin
  if GetCopyControl(CtrlType, WC) then
    case CtrlType of
      0: (WC as TCustomEdit).CopyToClipboard;

      1: begin
        (WC as TTracks).CopyToClipboard;
        LastClipboard := LCTracks;
      end;

      2: begin
        TMDIChild(MainForm.ActiveMDIChild).copySampleToBuffer(False);
        LastClipboard := LCSamples;
      end;

      3: begin
        TMDIChild(MainForm.ActiveMDIChild).copyOrnamentToBuffer(False);
        LastClipboard := LCOrnaments;
      end;

      4: begin
        TMDIChild(MainForm.ActiveMDIChild).copySampleToBuffer(True);
        LastClipboard := LCSamples;
      end;

      5: begin
        TMDIChild(MainForm.ActiveMDIChild).copyOrnamentToBuffer(True);
        LastClipboard := LCOrnaments;
      end;

    end;
end;

procedure TMainForm.EditPaste1Execute(Sender: TObject);
var
  CtrlType: integer;
  WC: TWinControl;
begin
  if GetCopyControl(CtrlType, WC) then
    case CtrlType of
      0: (WC as TCustomEdit).PasteFromClipboard;
      1: (WC as TTracks).PasteFromClipboard(False);
      2: TMDIChild(ActiveMDIChild).pasteSampleFromBuffer(False);
      3: TMDIChild(ActiveMDIChild).pasteOrnamentFromBuffer;
      4: TMDIChild(ActiveMDIChild).pasteSampleFromBuffer(True);
      5: TMDIChild(ActiveMDIChild).pasteOrnamentFromBuffer;
    end;
end;

procedure TMainForm.UndoUpdate(Sender: TObject);
begin

  if ExportStarted then
  begin
    Undo.Enabled := False;
    Exit;
  end;

  Undo.Enabled := (MDIChildCount <> 0) and
    ((TMDIChild(ActiveMDIChild).ChangeCount > 0) or
    (TMDIChild(ActiveMDIChild).PageControl1.ActivePageIndex = 4));

end;

procedure TMainForm.UndoExecute(Sender: TObject);
begin
  if (MDIChildCount = 0) then exit;

  if (TMDIChild(ActiveMDIChild).PageControl1.ActivePageIndex = 4) and (TMDIChild(ActiveMDIChild).TrackInfo.Focused) then begin
    TMDIChild(ActiveMDIChild).TrackInfo.Undo;
    Exit;
  end;

  TMDIChild(ActiveMDIChild).DoUndo(1, True)
end;

procedure TMainForm.RedoUpdate(Sender: TObject);
begin

  if ExportStarted then
  begin
    Redo.Enabled := False;
    Exit;
  end;

  Redo.Enabled := (MDIChildCount <> 0) and
    ((TMDIChild(ActiveMDIChild).ChangeCount < TMDIChild(ActiveMDIChild).ChangeTop) or
    (TMDIChild(ActiveMDIChild).PageControl1.ActivePageIndex = 4));

end;

procedure TMainForm.RedoExecute(Sender: TObject);
const
  EM_REDO = WM_USER + 84; 
begin
  if (MDIChildCount = 0) then exit;
  if (TMDIChild(ActiveMDIChild).PageControl1.ActivePageIndex = 4) and (TMDIChild(ActiveMDIChild).TrackInfo.Focused) then begin
    SendMessage(TMDIChild(ActiveMDIChild).TrackInfo.Handle, EM_REDO, 0, 0);
    Exit;
  end;

  TMDIChild(ActiveMDIChild).DoUndo(1, False)
end;

procedure TMainForm.CheckCommandLine;
var
  i: integer;
  FileExt: string;

begin
  i := ParamCount;
  if i = 0 then exit;

  FileExt := ExtractFileExt(ParamStr(1));

  if i = 1 then
  begin
    StartupOpenModule := AnsiMatchStr(FileExt, ModuleExtensions);
    StartupOpenTheme  := FileExt = '.vtt';
    Exit;
  end;

  StartupOpenTheme  := False;
  StartupOpenModule := True;
  for i := i downto 1 do
    CreateMDIChild(ExpandFileName(ParamStr(i)), 1)

end;

function TMainForm.AllowSave(fn: string): boolean;
begin
  Result := not FileExists(fn) or
    (MessageDlg('File ''' + fn + ''' exists. Overwrite?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes)
end;

procedure TMainForm.TransposeChannel(WorkWin: TMDIChild; Pat, Chn, i, Semitones: integer);
var
  j: integer;
begin
  if WorkWin.VTMP.Patterns[Pat].Items[i].Channel[Chn].Note >= 0 then
  begin
    j := WorkWin.VTMP.Patterns[Pat].Items[i].Channel[Chn].Note + Semitones;
    if (j >= 96) or (j < 0) then exit;
    WorkWin.VTMP.Patterns[Pat].Items[i].Channel[Chn].Note := j
  end
end;

procedure TMainForm.TransposeColumns(WorkWin: TMDIChild; Pat: integer; Env: boolean; Chans: TChansArrayBool; LFrom, LTo, Semitones: integer; MakeUndo: boolean);
var
  stk: real;
  i, e {,PLen}, olde, enote: integer;
  f: boolean;
  OldPat: PPattern;
begin
  if Semitones = 0 then exit;
  OldPat := nil;
  with WorkWin do
  begin
    if VTMP.Patterns[Pat] = nil then exit;
    f := Env or Chans[0] or Chans[1] or Chans[2];
    if not f then exit;
//  PLen := VTMP.Patterns[Pat].Length;
//  if LTo >= PLen then LTo := PLen - 1;
  //Work with all pattern lines even if it greater then pattern length
    if LTo >= MaxPatLen then LTo := MaxPatLen - 1;
    if LFrom > LTo then exit;
    SongChanged := True;
    BackupSongChanged := True;
    if MakeUndo then
    begin
      New(OldPat); OldPat^ := VTMP.Patterns[Pat]^;
    end;
    if Chans[0] then
      for i := LFrom to LTo do
        TransposeChannel(WorkWin, Pat, 0, i, Semitones);
    if Chans[1] then
      for i := LFrom to LTo do
        TransposeChannel(WorkWin, Pat, 1, i, Semitones);
    if Chans[2] then
      for i := LFrom to LTo do
        TransposeChannel(WorkWin, Pat, 2, i, Semitones);
    if Env then
    begin
      stk := exp(-Semitones / 12 * ln(2));
      for i := LFrom to LTo do
      begin
        olde := VTMP.Patterns[Pat].Items[i].Envelope; //if e = 0 then e := 1;
        if olde = 0 then Continue;
        enote := GetNoteByEnvelope(olde);
        if enote > 0 then e := Round(getnotefreq(VTMP.Ton_Table, enote + Semitones) / 16)
        else e := round(olde * stk);
//      if (e = 1) and (VTMP.Patterns[Pat].Items[i].Envelope = 0) then e := 0;
        if (e >= 0) and (e < $10000) then VTMP.Patterns[Pat].Items[i].Envelope := e;
      end;
    end;
    if MakeUndo then
    begin
      AddUndo(CATransposePattern, Pat, 0);
      ChangeList[ChangeCount - 1].Pattern := OldPat;
    end;
    if PatNum = Pat then
    begin
      if Tracks.Focused then Tracks.HideMyCaret;
      Tracks.RedrawTracks(0);
      if Tracks.Focused then Tracks.ShowMyCaret;
    end;
  end;
end;

procedure TMainForm.TransposeSelection(Semitones: integer);
var
  X1, X2, Y1, Y2: integer;
  ff: Integer;
  evenVol, tempVol, volChan: Integer; //channel for volume transposition
  Chans: TChansArrayBool;
begin
  if Semitones = 0 then exit;
  if MDIChildCount = 0 then exit;
  volChan := 0;

  with TMDIChild(ActiveMDIChild).Tracks do
  begin
    X2 := CursorX;
    X1 := SelX;
    if X1 > X2 then
    begin
      X1 := X2;
      X2 := SelX
    end;
    Y1 := SelY;
    Y2 := ShownFrom - N1OfLines + CursorY;
    if Y1 > Y2 then
    begin
      Y1 := Y2;
      Y2 := SelY
    end;

    // VOLUME
    if (X2 = X1) and ((X1 = 15) or (X1 = 29) or (X1 = 43)) then
    begin
      TMDIChild(ActiveMDIChild).SavePatternUndo;
      case X1 of
        15: volChan := ChanAlloc[0];
        29: volChan := ChanAlloc[1];
        43: volChan := ChanAlloc[2];
      end;
      evenVol := 0;
      for ff := Y1 to Y2 do
      begin
        tempVol := TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Channel[volChan].Volume;
        if (Abs(Semitones) = 1)
          and
          ((tempVol + Semitones) in [1..15])
          and (tempVol <> 0) then
        begin
          TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Channel[volChan].Volume := tempVol + Semitones;
        end
        else if (Abs(Semitones) = 12) then
        begin
          if (tempVol <> 0) then evenVol := evenVol + 1;

          if (tempVol <> 0) and ((evenVol mod 2) = 0) then
          begin
            if (Semitones > 0)
              and
              ((tempVol + 1) in [1..15]) then
            begin
              TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Channel[volChan].Volume := tempVol + 1;
            end;
            if (Semitones < 0)
              and
              ((tempVol - 1) in [1..15]) then
            begin
              TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Channel[volChan].Volume := tempVol - 1;
            end;

          end;
        end;

      end;
      with TMDIChild(ActiveMDIChild) do
      begin
        Tracks.HideMyCaret;
        Tracks.RedrawTracks(0);
        Tracks.ShowMyCaret;
      end;

      TMDIChild(ActiveMDIChild).SavePatternRedo;
    end

    // NOISE
    else if (X1 = 6) or (X2 = 6) then begin
      TMDIChild(ActiveMDIChild).SavePatternUndo;

      for ff := Y1 to Y2 do begin

        if (Semitones > 0) and (TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Noise < 31) and (TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Noise > 0) then
          Inc(TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Noise);

        if (Semitones < 0) and (TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Noise > 1) then
          Dec(TMDIChild(ActiveMDIChild).VTMP.Patterns[TMDIChild(ActiveMDIChild).PatNum].Items[ff].Noise);

      end;

      TMDIChild(ActiveMDIChild).Tracks.HideMyCaret;
      TMDIChild(ActiveMDIChild).Tracks.RedrawTracks(0);
      TMDIChild(ActiveMDIChild).Tracks.ShowMyCaret;
      TMDIChild(ActiveMDIChild).SavePatternRedo;
    end


    else begin
      Chans[ChanAlloc[0]] := (X1 <= 8) and (X2 >= 8);
      Chans[ChanAlloc[1]] := (X1 <= 22) and (X2 >= 22);
      Chans[ChanAlloc[2]] := (X1 <= 36) and (X2 >= 36);
      TransposeColumns(TMDIChild(ActiveMDIChild), TMDIChild(ActiveMDIChild).PatNum,
        X1 <= 3, Chans, Y1, Y2, Semitones, True);
    end;
  end;
end;

procedure TMainForm.TransposeUp1Update(Sender: TObject);
begin
  TransposeUp1.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).Tracks.Focused;
end;

procedure TMainForm.TransposeDown1Update(Sender: TObject);
begin
  TransposeDown1.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).Tracks.Focused;
end;

procedure TMainForm.TransposeUp12Update(Sender: TObject);
begin
  TransposeUp12.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).Tracks.Focused;
end;

procedure TMainForm.TransposeDown12Update(Sender: TObject);
begin
  TransposeDown12.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).Tracks.Focused;
end;

procedure TMainForm.TransposeUp1Execute(Sender: TObject);
begin
  TransposeSelection(1);
end;

procedure TMainForm.TransposeDown1Execute(Sender: TObject);
begin
  TransposeSelection(-1);
end;

procedure TMainForm.TransposeUp12Execute(Sender: TObject);
begin
  TransposeSelection(12);
end;

procedure TMainForm.TransposeDown12Execute(Sender: TObject);
begin
  TransposeSelection(-12);
end;

//specially for Znahar

procedure TMainForm.SetBar;
begin
  PopupMenu3.Items[BarNum].Checked := Value;
  case BarNum of
    0:
      begin
        ToolButton9.Visible := Value;
        ToolButton1.Visible := Value;
        ToolButton2.Visible := Value;
        //ToolButton3.Visible := Value;
      end;
    1:
      begin
        PlayStopBtn.Visible  := Value;
        ToolButton13.Visible := Value;
        ToolButton20.Visible := Value;
        ToolButton21.Visible := Value;
        ToolButton15.Visible := Value;
        ToolButton17.Visible := Value;
        //ToolButton16.Visible := Value;
        ToolButton25.Visible := Value;
      end;
    2:
      begin
        ToolButton26.Visible := Value;
        ToolButton27.Visible := Value;
        //ToolButton28.Visible := Value;
      end;
{6:
 begin
  SpeedButton1.Visible := Value;
  SpeedButton2.Visible := Value;
  ToolButton19.Visible := Value;
 end;
7:
 begin
  TrackBar1.Visible := Value;
  ToolButton25.Visible := Value;
 end;
8:
 ComboBox1.Visible := Value;}
  end;
end;

procedure TMainForm.PopupMenu3Click(Sender: TObject);
begin
  SetBar((Sender as TMenuItem).Tag, not (Sender as TMenuItem).Checked);
end;

procedure TMainForm.ExpandTwice1Click(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  TMDIChild(ActiveMDIChild).ExpandPattern;
end;

procedure TMainForm.Compresspattern1Click(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  TMDIChild(ActiveMDIChild).CompressPattern;
end;

procedure TMainForm.Merge1Click(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  TMDIChild(ActiveMDIChild).Tracks.PasteFromClipboard(True);
end;


procedure TMainForm.midiin1MidiInput(Sender: TObject);
var
  eve : TMyMidiEvent;
  mess, data1, data2: byte;
  note:integer;
  i, count: Integer;
const
  NoteOn  =144;
  NoteOff =128;

begin
  count := midiin1.MessageCount;

  if count = 0 then Exit;
  for i:= 1 to count do
  begin

    try
      eve := midiin1.GetMidiEvent;
    except
      midiin1.Close;
      Exit;
    end;

    mess := eve.MidiMessage and $F0;

    data1 := eve.Data1;
    data2 := eve.Data2;

    if  (data2 = 0) and (mess = NoteOn) then mess := NoteOff;
    note:= data1 - 24;
    if note > 95 then note := 95;
    if note <= 0 then note := 0;
    if MDIChildCount = 0 then Break;


    // NOTE ON
    if mess = NoteOn then
    with TMDIChild(ActiveMDIChild) do

      if Tracks.Focused then
        TracksMidiNoteOn(note)

      else if SampleTestLine.Focused then
        SampleTestLine.TestLineMidiOn(note)

      else if PageControl1.ActivePage = SamplesSheet then
        SamplesMidiNoteOn(note)

      else if PageControl1.ActivePage = OrnamentsSheet then
        OrnamentsMidiNoteOn(note);

     { else if OrnamentTestLine.Focused then
        TLArpMidiOn(note)

      else if PageControl1.ActivePage = OrnamentsSheet then
        TLArpMidiOn(note);
        // buggy ARP, but nice idea!   }


    // NOTE OFF
    if mess = NoteOff then
    with TMDIChild(ActiveMDIChild) do

      if Tracks.Focused then
        TracksMidiNoteOff(note)

      else if SampleTestLine.Focused then
        SampleTestLine.TestLineMidiOff(note)

      else if PageControl1.ActivePage = SamplesSheet then
        SamplesMidiNoteOff(note)

      {else if OrnamentTestLine.Focused then
        TLArpMidiOff(note)

      else if PageControl1.ActivePage = OrnamentsSheet then
        OrnamentsMidiNoteOff(note);  }

      else if PageControl1.ActivePage = OrnamentsSheet then
        OrnamentsMidiNoteOff(note);

  end;
end;

procedure TMainForm.RenumberPatternsClick(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  if IsPlaying and (PlayMode = PMPlayModule) then exit;
  TMDIChild(ActiveMDIChild).RenumberPatterns;
end;

procedure TMainForm.UpdateEnvelopeAsNote;
var i: Integer;
begin
  for i := 0 to MDIChildCount - 1 do
    if TMDIChild(MDIChildren[i]) <> TMDIChild(ActiveMDIChild) then
    begin
      TMDIChild(MDIChildren[i]).EnvelopeAsNoteOpt.Checked := EnvelopeAsNote;
      TMDIChild(MDIChildren[i]).Tracks.RedrawTracks(0);
    end;
end;

procedure TMainForm.ChangeDupNoteParams;
var i: Integer;
begin
  for i := 0 to MDIChildCount - 1 do
    if TMDIChild(MDIChildren[i]) <> TMDIChild(ActiveMDIChild) then
      TMDIChild(MDIChildren[i]).DuplicateNoteParams.Checked := DupNoteParams;
end;


procedure TMainForm.DuplicateLastNoteParamsExecute(Sender: TObject);
var i: Integer;
begin
  if DupNoteParams then
    DupNoteParams := False
  else
    DupNoteParams := True;
  for i := 0 to MDIChildCount - 1 do
    TMDIChild(MDIChildren[i]).DuplicateNoteParams.Checked := DupNoteParams;
end;


procedure TMainForm.ChangeBetweenPatterns;
var i: Integer;
begin
  for i := 0 to MDIChildCount - 1 do
    if TMDIChild(MDIChildren[i]) <> TMDIChild(ActiveMDIChild) then
      TMDIChild(MDIChildren[i]).BetweenPatterns.Checked := MoveBetweenPatrns;
end;



procedure TMainForm.MoveBetwnPatrnsExecute(Sender: TObject);
var i: Integer;
begin
  if MoveBetweenPatrns then
    MoveBetweenPatrns := False
  else
    MoveBetweenPatrns := True;
  for i := 0 to MDIChildCount - 1 do
    TMDIChild(MDIChildren[i]).BetweenPatterns.Checked := MoveBetweenPatrns;
end;



procedure TMainForm.AutoNumeratePatternsClick(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoNumeratePatterns;
end;



procedure TMainForm.WMSysCommand(var Msg: TWMSysCommand);
begin

  SysCmd  := Msg.CmdType and $FFF0;
  PrevTop := Top;
  MaximizeChilds := (Msg.CmdType <> 61441) and (Msg.CmdType <> 61442);

  if (SysCmd = SC_SIZE) and OneTrack then
    FixWidth
  else
    ResetConstraints(True);

  if OneTrack and ((Msg.CmdType = 61444) or (Msg.CmdType = 61441) or (Msg.CmdType = 61447)) then Exit;


  if (SysCmd = SC_MAXIMIZE) or (SysCmd = SC_RESTORE) then
    RedrawOff;

  inherited;
  RedrawOn;

  MaximizeChilds := True;
  WindowUnsnap := False;
  SizeFixed := False;
  MoveShift := 0;

end;



procedure TMainForm.WMPosChanging(var Msg: TWMWINDOWPOSCHANGING);
const Counter: Integer = 0;
begin

  if Snaped and not WindowSnap and ((Msg.WindowPos.x <> Left) or (Msg.WindowPos.y <> Top)) then begin
    Snaped := False;
    SnapedToRight := False;
  end;

  if (MoveShift <> 0) and (Msg.WindowPos.flags and SWP_NOMOVE = 0) then begin
    Msg.WindowPos.x := Msg.WindowPos.x + MoveShift;
    Msg.Result := 0;
  end;

  if SizeFixed and (Msg.WindowPos.flags and SWP_NOSIZE = 0) then begin
    Msg.WindowPos.cx := WidthFix;
    Msg.WindowPos.cy := HeightFix;
    Msg.Result := 0;
  end;

  inherited;

  
end;


{
procedure TMainForm.WMSize(var Msg: TWMSize);
begin
  inherited;
end;


procedure TMainForm.WMSizing(var Msg: TWMSize);
begin
  inherited;
end;


procedure TMainForm.WMWindowPosChanged(var Msg: TWMWindowPosChanged);
begin
  inherited;
end;

}


procedure TMainForm.WMDisplayChange(var Message: TWMDisplayChange);
var
  NewSize: TSize;
begin

  // Update constants
  DisplayChanged := True;
  MonitorWorkAreaWidth;
  MonitorWorkAreaHeight;
  DisplayChanged := False;

  if WindowState = wsNormal then
  begin
    NormalExecute(Self);
    Exit;
  end;

  NewSize.Width  := ClientWidth;
  NewSize.Height := ClientHeight;
  NewSize.Left   := Left;
  NewSize.Top    := Top;

  RedrawOff;
  SetChildsPosition(wsMaximized);
  AutoMetrixForChilds(wsMaximized);
  AutoCutChilds(NewSize);
  RedrawChilds;
  AutoToolBarPosition(NewSize);
  RedrawOn;

end;


procedure TMainForm.WMUser(var Message:TMessage);
begin

  if StartupOpenModule then
  begin
    CreateChildWrapper(ParamStr(1));
    Exit;
  end;

  if StartupOpenTheme then
  begin
    LoadColorTheme(ParamStr(1));
    MessageBox(Handle, 'Done. Color theme successfully imported!', 'Success',
      MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
  end;

  // Vortex first start - open demosong
  if VortexFirstStart then
  begin
    DontAddToRecent := True;
    CreateChildWrapper(VortexDocumentsDir + DemosongsDefaultDir +'\'+ SongResources[0] +'.vt2');
    DontAddToRecent := False;
    Exit;
  end;

  // Do startup action
  DontAddToRecent := True;
  SetChildAsTemplate := True;
  case StartupAction of
    0:
      if TemplateSongPath <> '' then
      begin
        CreateChildWrapper(TemplateSongPath);
        if not FileExists(TemplateSongPath) then
          TemplateSongPath := '';
      end;
    1: FileNew1Execute(Self);
  end;
  DontAddToRecent := False;
  SetChildAsTemplate := False;

end;


procedure TMainForm.WMDropFiles(var Msg: TWMDropFiles);
var
  DropH: HDROP;               // drop handle
  DroppedFileCount: Integer;  // number of files dropped
  FileNameLength: Integer;    // length of a dropped file name
  FileName, FileExt: string;           // a dropped file name
  I: Integer;                 // loops thru all dropped files
  DropPoint: TPoint;          // point where files dropped
begin
  inherited;
  // Store drop handle from the message
  DropH := Msg.Drop;
  try
    // Get count of files dropped
    DroppedFileCount := DragQueryFile(DropH, $FFFFFFFF, nil, 0);
    // Get name of each file dropped and process it
    for I := 0 to Pred(DroppedFileCount) do
    begin
      // get length of file name
      FileNameLength := DragQueryFile(DropH, I, nil, 0);
      // create string large enough to store file
      // (Delphi allows for #0 terminating character automatically)
      SetLength(FileName, FileNameLength);
      // get the file name
      DragQueryFile(DropH, I, PChar(FileName), FileNameLength + 1);
      // process file name

      FileExt := ExtractFileExt(FileName);

      if FileExt = '.vtt' then
      begin
        if LoadColorTheme(FileName) then
          MessageBox(Handle, 'Done. Color theme successfully imported!', 'Success', MB_OK + MB_ICONINFORMATION + MB_TOPMOST)
        else
          Application.MessageBox('Invalid color theme file', 'Fail', MB_OK + MB_ICONSTOP + MB_TOPMOST);
        Exit;
      end;

      if not AnsiMatchStr(FileExt, ModuleExtensions) then Exit;


      ChildsEventsBlocked := True;

      RedrawOff;
      CreateMDIChild(FileName, 1);
      RedrawOn;

      ChildsEventsBlocked := False;
    end;
    // Optional: Get point at which files were dropped
    DragQueryPoint(DropH, DropPoint);
    // ... do something with drop point here
  finally
    // Tidy up - release the drop handle
    // don't use DropH again after this
    DragFinish(DropH);
  end;
  // Note we handled message
  Msg.Result := 0;
end;


procedure TMainForm.Notification(AComponent: TComponent; Operation: TOperation);
var
  NewSize: TSize;
begin
  inherited;

  // Child closed
  if (Operation = opRemove) and (AComponent is TMDIChild) and
     (TForm(AComponent).FormStyle = fsMDIChild) then
     begin

       if DrawOffAfterClose then begin
         DrawOffAfterClose := False;
         Exit;
       end;

       RedrawOff;
       //Dec(WinCount);

       ChildsEventsBlocked := True;

       AutoMetrixForChilds(WindowState);
       SetChildsPosition(WindowState);
       NewSize := GetSizeForChilds(WindowState, False);
       AutoCutChilds(NewSize);
       AutoToolBarPosition(NewSize);
       RedrawChilds;

       RedrawOn;
       SetWindowSize(NewSize);

       ChildsEventsBlocked := False;

       MainForm.StatusBar.Panels[1].Text := '';
       MainForm.StatusBar.Panels[2].Text := '';
     end;

end;




procedure TMainForm.SaveBackups(Sender: TObject);
var i: integer;
begin
  for i := 0 to MDIChildCount - 1 do
    if TMDIChild(MDIChildren[i]).BackupSongChanged then
      TMDIChild(MDIChildren[i]).SaveModuleBackup;
end;


procedure TMainForm.ChangeBackupTimer;
begin

  if AutoBackupsOn then
  begin
    BackupTimer.Enabled := True;
    BackupTimer.Interval := AutoBackupsMins * 60000;
  end
  else
    BackupTimer.Enabled := False;

end;




procedure TMainForm.SetPositionColor(NumColor: byte);
var i: Integer;
begin
  with TMDIChild(ActiveMDIChild) do
  begin
    for i := PatternsOrderSelection.Left to PatternsOrderSelection.Right do
      VTMP.Positions.Colors[i] := NumColor;
    SongChanged := True;
    BackupSongChanged := True;
    UnselectPositions;
  end;
end;


procedure TMainForm.PositionColorRedClick(Sender: TObject);
begin
  SetPositionColor(1);
end;

procedure TMainForm.PositionColorGreenClick(Sender: TObject);
begin
  SetPositionColor(2);
end;

procedure TMainForm.PositionColorBlueClick(Sender: TObject);
begin
  SetPositionColor(3);
end;

procedure TMainForm.PositionColorMaroonClick(Sender: TObject);
begin
  SetPositionColor(4);
end;

procedure TMainForm.PositionColorPurpleClick(Sender: TObject);
begin
  SetPositionColor(5);
end;

procedure TMainForm.PositionColorGrayClick(Sender: TObject);
begin
  SetPositionColor(6);
end;

procedure TMainForm.PositionColorTealClick(Sender: TObject);
begin
  SetPositionColor(7);
end;

procedure TMainForm.PositionColorBlackClick(Sender: TObject);
begin
  SetPositionColor(8);
end;

procedure TMainForm.PositionColorDefaultClick(Sender: TObject);
begin
  SetPositionColor(0);
end;


procedure TMainForm.PositionColorRedDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($002525BA), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorGreenDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($003A8330), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorBlueDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($0095483E), ACanvas, ARect, Selected);
end;


procedure TMainForm.PositionColorMaroonDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($002958A5), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorPurpleDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($00914899), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorGrayDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($00727272), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorTealDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($008F8C0E), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorDefaultDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($FFFFFF), ACanvas, ARect, Selected);
end;


procedure TMainForm.PositionColorL1DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($008CFFFF), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorL1Click(Sender: TObject);
begin
  SetPositionColor(9);
end;

procedure TMainForm.PositionColorL2DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($00CDCDFF), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorL2Click(Sender: TObject);
begin
  SetPositionColor(10);
end;

procedure TMainForm.PositionColorL3DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($00FFCAFA), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorL3Click(Sender: TObject);
begin
  SetPositionColor(11);
end;

procedure TMainForm.PositionColorL4DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($00B9FFB7), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorL4Click(Sender: TObject);
begin
  SetPositionColor(12);
end;

procedure TMainForm.PositionColorL5DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  DrawSubmenuColor(TColor($00FFC6C6), ACanvas, ARect, Selected);
end;

procedure TMainForm.PositionColorL5Click(Sender: TObject);
begin
  SetPositionColor(13);
end;


procedure TMainForm.PopupMenu1Popup(Sender: TObject);
var
  NumSelected: Integer;
  CanChangePositions, CanChangeColors: Boolean;
  ActiveChild: TMDIChild;

begin
  ActiveChild := TMDIChild(ActiveMDIChild);

  CanChangeColors := (MDIChildCount <> 0)
      and ActiveChild.StringGrid1.Focused
      and (ActiveChild.VTMP.Positions.Length > ActiveChild.StringGrid1.Selection.Right);

  CanChangePositions := CanChangeColors and not (IsPlaying and (PlayMode = PMPlayModule));
  NumSelected := ActiveChild.StringGrid1.Selection.Right - ActiveChild.StringGrid1.Selection.Left + 1;

  Color1.Enabled      := CanChangeColors;
  ResetColors.Enabled := CanChangeColors;

  InsertPosition1.Enabled    := CanChangePositions;
  DeletePosition1.Enabled    := CanChangePositions;
  DuplicatePosition1.Enabled := CanChangePositions;
  ClonePosition1.Enabled     := CanChangePositions;

  if NumSelected > 1 then
  begin
    Changepatternslength1.Visible := True;
    sep4.Visible := True;
    DuplicatePosition1.Caption := 'Duplicate positions';
    Deleteposition1.Caption    := 'Delete positions';
    ClonePosition1.Caption     := 'Clone positions';
  end
  else
  begin
    Changepatternslength1.Visible := False;
    sep4.Visible := False;
    DuplicatePosition1.Caption := 'Duplicate position';
    Deleteposition1.Caption    := 'Delete position';
    ClonePosition1.Caption     := 'Clone position';
  end;

end;

procedure TMainForm.DrawSubmenuColor(Color: TColor; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
   ACanvas.Brush.Color := Color;
   ACanvas.Pen.Color := clBtnFace;
   if Selected then ACanvas.Pen.Color := clMenuHighlight;
   ACanvas.Rectangle(ARect);
end;



procedure TMainForm.Setloopposition1MeasureItem(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
begin
  Width := 155;
end;


procedure TMainForm.PrepareColors;
begin
  CBackground        := GetColor(ColorTheme.Background);
  CSelLineBackground := GetColor(ColorTheme.SelLineBackground);
  CHighlBackground   := GetColor(ColorTheme.HighlBackground);
  COutBackground     := GetColor(ColorTheme.OutBackground);
  COutHlBackground   := GetColor(ColorTheme.OutHlBackground);
  CText              := GetColor(ColorTheme.Text);
  CSelLineText       := GetColor(ColorTheme.SelLineText);
  CHighlText         := GetColor(ColorTheme.HighlText);
  COutText           := GetColor(ColorTheme.OutText);
  CLineNum           := GetColor(ColorTheme.LineNum);
  CSelLineNum        := GetColor(ColorTheme.SelLineNum);
  CHighlLineNum      := GetColor(ColorTheme.HighlLineNum);
  CEnvelope          := GetColor(ColorTheme.Envelope);
  CSelEnvelope       := GetColor(ColorTheme.SelEnvelope);
  CNoise             := GetColor(ColorTheme.Noise);
  CSelNoise          := GetColor(ColorTheme.SelNoise);
  CNote              := GetColor(ColorTheme.Note);
  CSelNote           := GetColor(ColorTheme.SelNote);
  CNoteParams        := GetColor(ColorTheme.NoteParams);
  CSelNoteParams     := GetColor(ColorTheme.SelNoteParams);
  CNoteCommands      := GetColor(ColorTheme.NoteCommands);
  CSelNoteCommands   := GetColor(ColorTheme.SelNoteCommands);
  CSeparators        := GetColor(ColorTheme.Separators);
  COutSeparators     := GetColor(ColorTheme.OutSeparators);
  CSamOrnBackground     := GetColor(ColorTheme.SamOrnBackground);
  CSamOrnSelBackground  := GetColor(ColorTheme.SamOrnSelBackground);
  CSamOrnText           := GetColor(ColorTheme.SamOrnText);
  CSamOrnSelText        := GetColor(ColorTheme.SamOrnSelText);
  CSamOrnLineNum        := GetColor(ColorTheme.SamOrnLineNum);
  CSamOrnSelLineNum     := GetColor(ColorTheme.SamOrnSelLineNum);
  CSamNoise             := GetColor(ColorTheme.SamNoise);
  CSamSelNoise          := GetColor(ColorTheme.SamSelNoise);
  CSamOrnSeparators     := GetColor(ColorTheme.SamOrnSeparators);
  CSamOrnTone           := GetColor(ColorTheme.SamOrnTone);
  CSamOrnSelTone        := GetColor(ColorTheme.SamOrnSelTone);
  CFullScreenBackground := GetColor(ColorTheme.FullScreenBackground);
  //for i := 0 to MDIChildCount - 1 do
  //  TMDIChild(MDIChildren[i]).OutBoxBackground.Brush.Color := CFullScreenBackground;
  //Invalidate;
end;

procedure TMainForm.ResetColorsClick(Sender: TObject);
var i: Integer;
begin
  if Application.MessageBox('Delete all colors?', 'Vortex Tracker II', MB_YESNO +
    MB_ICONQUESTION + MB_TOPMOST) = IDNO then
      Exit;

  with TMDIChild(ActiveMDIChild) do
  begin
    for i := Low(VTMP.Positions.Colors) to High(VTMP.Positions.Colors) do
      VTMP.Positions.Colors[i] := 0;
    StringGrid1.Repaint;
  end;


end;


procedure TMainForm.SendSyncMessage;
var MsgFile: TextFile;
begin
  AssignFile(MsgFile, SyncMessageFile);
  Rewrite(MsgFile);
  Writeln(MsgFile, IntToStr(Handle));
  CloseFile(MsgFile);
end;


procedure TMainForm.SyncCheckTimerTimer(Sender: TObject);
var
  NewSize: TSize;
  SyncFile: TextFile;
  res: string;
begin
  if FileExists(SyncMessageFile) then
  begin
    SyncCheckTimer.Enabled := False;
    SyncFinishTimer.Enabled := True;

    AssignFile(SyncFile, SyncMessageFile);
    Reset(SyncFile);
    Readln(SyncFile, res);
    CloseFile(SyncFile);

    if res = IntToStr(Handle) then
      Exit;

    SyncVTInstanses := True;
    EditorFontChanged := True;
    NumberOfLinesChanged := True;

    LoadOptions;

    RedrawOff;
    ChildsEventsBlocked := True;

    RedrawChilds;
    AutoMetrixForChilds(WindowState);
    SetChildsPosition(WindowState);
    NewSize := GetSizeForChilds(WindowState, False);
    AutoCutChilds(NewSize);
    AutoToolBarPosition(NewSize);
    SetWindowSize(NewSize);

    ChildsEventsBlocked := False;
    RedrawOn;

    SyncVTInstanses := False;
    EditorFontChanged := False;
    NumberOfLinesChanged := False;

    SyncFinishTimer.Enabled := True;
  end;
end;



procedure TMainForm.SyncFinishTimerTimer(Sender: TObject);
begin
  if FileExists(SyncMessageFile) then
    try
      DeleteFile(SyncMessageFile);
    except
    end;
  SyncFinishTimer.Enabled := False;
  SyncCheckTimer.Enabled := True;
end;


procedure TMainForm.SyncCopyBuffersTimer(Sender: TObject);
var
  s: string;
  Sam: PSample;
  Orn: POrnament;
  SampleBufferAge, OrnamenBufferAge, SamplePartBufferAge: Integer;
  SampleBufferReady, OrnamentBufferReady, SamplePartBufferReady: Boolean;
begin
  if SyncBufferBlocked then Exit;
  if MDIChildCount = 0 then Exit;

  SampleBufferAge     := FileAge(SyncSampleBufferFile);
  OrnamenBufferAge    := FileAge(SyncOrnamentBufferFile);
  SamplePartBufferAge := FileAge(SyncSamplePartFile);

  SampleBufferReady     := (SampleBufferAge  <> -1) and (SampleBufferAge <> SyncSampleBufferFileAge);
  OrnamentBufferReady   := (OrnamenBufferAge <> -1) and (OrnamenBufferAge <> SyncOrnamentBufferFileAge);
  SamplePartBufferReady := (SamplePartBufferAge <> -1) and (SamplePartBufferAge <> SyncSamplePartFileAge);

  if not SampleBufferReady and not OrnamentBufferReady and not SamplePartBufferReady then Exit;

  // Sync sample copy/paste buffer
  if SampleBufferReady then
  begin
    SyncSampleBufferFileAge := SampleBufferAge;
    AssignFile(TxtFile, SyncSampleBufferFile);
    Reset(TxtFile);
    New(Sam);
    try
      s := LoadSampleDataTxt(Sam, False);
      if s <> '' then Exit;
      BuffSample.Length  := Sam.Length;
      BuffSample.Loop    := Sam.Loop;
      BuffSample.Enabled := Sam.Enabled;
      BuffSample.Items   := Sam.Items;
      LastClipboard      := LCSamples;
    finally
      CloseFile(TxtFile)
    end;
    Dispose(Sam);
  end;


  if SamplePartBufferReady then
  begin
    SyncSamplePartFileAge := SamplePartBufferAge;
    AssignFile(TxtFile, SyncSamplePartFile);
    Reset(TxtFile);
    try
      Readln(TxtFile, s);
      SampleCopy.FromColumn := StrToInt(s);
      Readln(TxtFile, s);
      SampleCopy.ToColumn := StrToInt(s);
      Readln(TxtFile, s);
      SampleCopy.FromLine := StrToInt(s);
      Readln(TxtFile, s);
      SampleCopy.ToLine := StrToInt(s);

      SampleCopy.Ready  := True;
      SampleCopy.Sample := @BuffSample;
      LastClipboard     := LCSamples;
    finally
      CloseFile(TxtFile)
    end;
  end;


  // Sync ornament copy/paste buffer
  if OrnamentBufferReady then
  begin
    SyncOrnamentBufferFileAge := OrnamenBufferAge;
    AssignFile(TxtFile, SyncOrnamentBufferFile);
    Reset(TxtFile);
    New(Orn);
    try
      Readln(TxtFile, s);
      if RecognizeOrnamentString(s, Orn) then
        begin
          BuffOrnament.Loop   := Orn.Loop;
          BuffOrnament.Length := Orn.Length;
          BuffOrnament.Items  := Orn.Items;
        end;
      Readln(TxtFile, s);
      if s = 'All' then
        BuffOrnament.CopyAll := True;
      LastClipboard := LCOrnaments;
    finally
      CloseFile(TxtFile);
    end;
    Dispose(Orn)
  end;

end;



procedure TMainForm.Changepatternslength1Click(Sender: TObject);
var
  PatternsLength, i: Integer;
  PatternsLengthStr: string;
begin
  repeat
    if not InputQuery('Vortex Tracker II',
      'Enter new length for selected patterns from 1 to ' + IntToStr(MaxPatLen),
      PatternsLengthStr) then
        Exit;
    // Check is number entered
    val(PatternsLengthStr, PatternsLength, i);
    if (i = 0) and (PatternsLength >= 1) and (PatternsLength <= MaxPatLen) then
      Break;
  until False;

  TMDIChild(ActiveMDIChild).ChangePatternsLength(PatternsLength);
end;

procedure TMainForm.Splitpattern1Click(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).SplitPattern;
end;

procedure TMainForm.RedrawOff;
begin
  {$IFDEF NOREDRAW} Exit; {$ENDIF}
  if not RedrawEnabled then Exit;
  SendMessage(ClientHandle, WM_SETREDRAW, Ord(False), 0);
  RedrawEnabled := False;
end;

procedure TMainForm.RedrawOn;
begin
  {$IFDEF NOREDRAW} Exit; {$ENDIF}
  if RedrawEnabled then Exit;
  SendMessage(ClientHandle, WM_SETREDRAW, Ord(True), 0);
  RedrawWindow(ClientHandle, nil, 0, RDW_NOERASE + RDW_NOFRAME + RDW_NOINTERNALPAINT + RDW_INVALIDATE + RDW_ALLCHILDREN + RDW_UPDATENOW);
  RedrawEnabled := True;
end;

procedure TMainForm.InsertPositionUpdate(Sender: TObject);
var
  c: TMDIChild;
  res: Boolean;
begin
  c := TMDIChild(ActiveMDIChild);

  res :=
    (MDIChildCount <> 0)
    and not (IsPlaying and (PlayMode = PMPlayModule))
    and c.StringGrid1.Focused
    and (
      (c.VTMP.Positions.Length > c.StringGrid1.Selection.Left) or
      ((c.VTMP.Positions.Length = 0) and (c.StringGrid1.Selection.Left = 0))
    );

  Insertposition1.Enabled := res;
  InsertPosition.Enabled := res;

end;

procedure TMainForm.DeletePositionUpdate(Sender: TObject);
begin
  DeletePosition.Enabled := (MDIChildCount <> 0) and
    not (IsPlaying and (PlayMode = PMPlayModule)) and
    TMDIChild(ActiveMDIChild).StringGrid1.Focused and
    (TMDIChild(ActiveMDIChild).VTMP.Positions.Length >
    TMDIChild(ActiveMDIChild).StringGrid1.Selection.Left);
end;



procedure TMainForm.PlayStopExecute(Sender: TObject);
var
  PatternsTabActive, SamplesTabActive, OrnamentsTabActive: Boolean;
  CurrentWindowPlaying: Boolean;
begin
  if MDIChildCount = 0 then Exit;

  // Detect active tab
  with TMDIChild(ActiveMDIChild) do
  begin
    PatternsTabActive  := (PageControl1.ActivePage = PatternsSheet) or (PageControl1.ActivePage = OptTab) or (PageControl1.ActivePage = InfoTab);
    SamplesTabActive   := PageControl1.ActivePage = SamplesSheet;
    OrnamentsTabActive := PageControl1.ActivePage = OrnamentsSheet;
  end;

  if NoPatterns and PatternsTabActive and not IsPlaying then
      Exit;


  // Is current window playing?
  CurrentWindowPlaying := TMDIChild(ActiveMDIChild).PlayStopState = BStop;

  // Stop playing all
  if IsPlaying then
  begin
    StopPlaying;
    RestoreControls;
  end;

  if CurrentWindowPlaying then
    Exit;



  // Play track if patterns editor tab is active
  if PatternsTabActive and (TMDIChild(ActiveMDIChild).PlayStopState = BPlay) then
  begin
    PlayMode := PMPlayModule;

    DisableControls(True);

    //CheckSecondWindow(True);
    with TMDIChild(ActiveMDIChild) do
    begin
      CheckStringGrid1Position;
      PlayStopState := BStop;
      Tracks.RemoveSelection;
      RerollToPos(PositionNumber, 1);
    end;

    ScrollToPlayingWindow;
    StartWOThread;
  end;


  // Play sample, if samples tab is active
  if SamplesTabActive and (TMDIChild(ActiveMDIChild).PlayStopState = BPlay) then
  begin
    TMDIChild(ActiveMDIChild).SampleTestLine.PlayCurrentNote;
  end;

  // Play ornament, if samples tab is active
  if OrnamentsTabActive and (TMDIChild(ActiveMDIChild).PlayStopState = BPlay) then
  begin
    TMDIChild(ActiveMDIChild).OrnamentTestLine.PlayCurrentNote;
  end;

end;


procedure TMainForm.PlayStopUpdate(Sender: TObject);
begin

  if (MDIChildCount = 0) or ExportStarted then
  begin
    PlayStopBtn.Enabled := False;
    PlayStop.Enabled := False;
    Stop.Enabled := False;
    Exit;
  end
  else
  begin
    PlayStopBtn.Enabled := True;
    PlayStop.Enabled := True;
  end;


  if IsPlaying then
    Stop.Enabled := True
  else
    Stop.Enabled := False;

  if TMDIChild(ActiveMDIChild) = nil then Exit;
  if TMDIChild(ActiveMDIChild).PlayStopState = BStop then
  begin
    // Stop
    PlayStopBtn.ImageIndex := 20;
    PlayStop.ImageIndex := 20;
  end
  else
  begin
    // Play
    PlayStopBtn.ImageIndex := 18;
    PlayStop.ImageIndex := 18;
  end;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  Color := CFullScreenBackground;
  Canvas.Brush.Color := CFullScreenBackground;
  Canvas.FillRect(Rect(0, ToolBar2.Height, ClientWidth, ClientHeight));
end;

procedure TMainForm.AutoStep0Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 0;
end;

procedure TMainForm.AutoStep1Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 1;
end;

procedure TMainForm.AutoStep2Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 2;
end;

procedure TMainForm.AutoStep3Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 3;
end;

procedure TMainForm.AutoStep4Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 4;
end;

procedure TMainForm.AutoStep5Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 5;
end;

procedure TMainForm.AutoStep6Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 6;
end;

procedure TMainForm.AutoStep7Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 7;
end;

procedure TMainForm.AutoStep8Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 8;
end;

procedure TMainForm.AutoStep9Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).AutoStepUpDown.Position := 9;
end;



procedure TMainForm.ExportToWAVExecute(Sender: TObject);
begin
  if MDIChildCount = 0 then Exit;
  TMDIChild(ActiveMDIChild).ExportToWavFile;
end;

procedure TMainForm.ExportToWAVUpdate(Sender: TObject);
begin
  ExportToWAV.Enabled := (MDIChildCount <> 0) and not ExportStarted;
end;

procedure TMainForm.NewTurbosoundExecute(Sender: TObject);
var
  Window1, Window2, Window3: TMDIChild;
//  TSWindow: array[0..1] of TMDIChild;
  Triple: integer;
begin
  RedrawOff;
  if TMenuItem(Sender)=NewTurbosoudtrack3 then Triple := 3
  else Triple := 2;

  CreateMDIChild('', Triple);

  if Triple = 3 then
  begin
    Window1 := ChildsTable[High(ChildsTable)-2];
    Window2 := Window1.TSWindow[0];
    Window2.Caption  := 'Mid TS ' + IntToStr(WinCount);
    Window3 := Window1.TSWindow[1];
    Window3.Caption := 'Right TS ' + IntToStr(WinCount);
    Window3.NumModule := 3;
  end
  else
  begin
    Window1 := ChildsTable[High(ChildsTable)-1];
    Window2 := Window1.TSWindow[0];
    Window2.Caption  := 'Right TS ' + IntToStr(WinCount);
  end;
  Window1.Caption  := 'Left TS ' + IntToStr(WinCount);
  Window1.NumModule := 1;
  Window2.NumModule := 2;

  RedrawOn;

  Window1.BringToFront;
  if Window1.Tracks.CanFocus then
    Window1.Tracks.SetFocus;

end;


procedure TMainForm.SaveAsTwoModulesUpdate(Sender: TObject);
begin

  SaveAsTwoModules.Enabled := (
    (MDIChildCount <> 0) and
    (TMDIChild(ActiveMDIChild).TSWindow[0] <> nil) and
    not ExportStarted
  );

  if ((MDIChildCount <> 0) and
    (TMDIChild(ActiveMDIChild).TSWindow[0] <> nil) and
    (TMDIChild(ActiveMDIChild).TSWindow[1] <> nil) and
    not ExportStarted)
  then Saveas2modules1.Caption:='Save As 3 modules..'
  else Saveas2modules1.Caption:='Save As 2 modules..';

  Saveas2modules1.Visible := SaveAsTwoModules.Enabled;

end;

procedure TMainForm.FormDblClick(Sender: TObject);
begin
  FileOpen1Execute(Self);
end;

procedure TMainForm.StopExecute(Sender: TObject);
begin

  // Esc for hide active windows
  if GlbTrans.Visible then begin GlbTrans.Hide; Exit; end;
  if ToglSams.Visible then begin ToglSams.Hide; Exit; end;
  if TrMng.Visible    then begin TrMng.Hide;    Exit; end;

  // Stop playing all
  if IsPlaying then
  begin
    StopPlaying;
    RestoreControls;
  end;
  Form1.UpdateAudioSettings;
end;

procedure TMainForm.Maximize1Execute(Sender: TObject);
begin
  ChildsEventsBlocked := True;
  SysCmd := SC_MAXIMIZE;
  WindowState := wsMaximized;
  ChildsEventsBlocked := False;
end;

procedure TMainForm.NormalExecute(Sender: TObject);
begin
  ChildsEventsBlocked := True;
  SysCmd := SC_RESTORE;
  WindowState := wsNormal;
  ChildsEventsBlocked := False;
end;


procedure TMainForm.PlayFromLineExecute(Sender: TObject);
begin

  // Already playing
  if IsPlaying and (PlayMode in [PMPlayModule, PMPlayPattern]) and (TMDIChild(ActiveMDIChild).PlayStopState = BStop) then
    Exit;

  // Stop playing all
  if IsPlaying then
  begin
    StopPlaying;
    RestoreControls;
  end;

  if NoPatterns then Exit;

  DisableControls(True);
  PlayMode := PMPlayModule;
  with TMDIChild(ActiveMDIChild) do
  begin
    CheckStringGrid1Position;
    PlayStopState := BStop;
    ValidatePattern2(PatNum);
    Tracks.RemoveSelection;
    ScrollToPlayingWindow;
    
    if TSWindow[0] = nil then
      RestartPlaying(False, False)
    else
      RestartPlayingTS(False, False);
  end;
  StartWOThread;


end;


procedure TMainForm.SaveAsTwoModulesExecute(Sender: TObject);
var
  TSWin1, TSWin2, TSWin3: TMDIChild;
  FileName: String;
  saved1,saved2,saved3:boolean;
begin

  if IsPlaying then
  begin
    StopPlaying;
    RestoreControls;
  end;

  // Save turbosound windows state
  TSWin1 := TMDIChild(ActiveMDIChild);
  TSWin2 := TSWin1.TSWindow[0];
  TSWin3 := TSWin1.TSWindow[1];
  FileName := TSWin1.WinFileName;

  // Split turbotrack
  TSWin1.TSWindow[0] := nil;
  TSWin2.TSWindow[0] := nil;
  if TSWin3<>nil then TSWin3.TSWindow[0] := nil;

  // Save modules
  saved1 := TSWin1.SaveModuleAs;
  saved2 := TSWin2.SaveModuleAs;
  if TSWin3<>nil then saved3 := TSWin3.SaveModuleAs
  else saved3 := False;

  // Merge turbotrack back
  TSWin1.TSWindow[0] := TSWin2;
  TSWin1.TSWindow[1] := TSWin3;
  TSWin2.TSWindow[0] := TSWin1;
  TSWin2.TSWindow[1] := TSWin3;

  if saved1 then TSWin1.SetFileName(FileName);
  if saved2 then TSWin2.SetFileName(FileName);
  if saved3 and (TSWin3<>nil) then TSWin3.SetFileName(FileName);
end;

procedure TMainForm.PlayFromLineUpdate(Sender: TObject);
begin
  PlayFromLine.Enabled := (MDIChildCount <> 0) and not ExportStarted;
end;

procedure TMainForm.ToggleLoopingAllUpdate(Sender: TObject);
begin
  ToggleLoopingAll.Enabled := not ExportStarted;
end;

procedure TMainForm.ToggleLoopingUpdate(Sender: TObject);
begin
  ToggleLooping.Enabled := not ExportStarted;
end;

procedure TMainForm.StopUpdate(Sender: TObject);
begin
  Stop.Enabled := (MDIChildCount <> 0) and not ExportStarted;
end;

procedure TMainForm.FileNew1Update(Sender: TObject);
begin
  FileNew1.Enabled := not ExportStarted;
end;

procedure TMainForm.FileOpen1Update(Sender: TObject);
begin
  FileOpen1.Enabled := not ExportStarted;
end;

procedure TMainForm.FileClose1Update(Sender: TObject);
begin
  FileClose1.Enabled := not ExportStarted and (MDIChildCount > 0);
end;

procedure TMainForm.NewTurbosoundUpdate(Sender: TObject);
begin
  NewTurbosound.Enabled := not ExportStarted;
end;

procedure TMainForm.SwapChannelsLeft1Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).DoSwapChannels(False);
end;

procedure TMainForm.SwapChannelsRight1Execute(Sender: TObject);
begin
  TMDIChild(ActiveMDIChild).DoSwapChannels(True);
end;

procedure TMainForm.SwapChannelsLeft1Update(Sender: TObject);
begin

  if MDIChildCount = 0 then
  begin
    SwapChannelsLeft1.Enabled := False;
    Exit;
  end;

  with TMDIChild(ActiveMDIChild) do
  begin
    SwapChannelsLeft1.Enabled := (PageControl1.ActivePageIndex = 0);
    SwapChannelsLeft.Visible := SwapChannelsLeft1.Enabled
  end;

end;

procedure TMainForm.SwapChannelsRight1Update(Sender: TObject);
begin

  if MDIChildCount = 0 then
  begin
    SwapChannelsRight1.Enabled := False;
    Exit;
  end;

  with TMDIChild(ActiveMDIChild) do
  begin
    SwapChannelsRight1.Enabled := (PageControl1.ActivePageIndex = 0);
    SwapChannelsRight.Visible := SwapChannelsRight1.Enabled;
    N13.Visible := SwapChannelsRight.Visible;
  end;

end;

procedure TMainForm.FormResize(Sender: TObject);
var
  NewSize: TSize;
  Maximize, ResizeOneChild, Restore, Resize, StateNormal, StateMaximized, MoveCmd: Boolean;
  MonitorRect: TRect;
  MouseX: Integer;
begin

  if MDIChildCount = 0 then Exit;
  if ResizeActionBlocked then Exit;
  if WindowUnsnap then Exit;
  if (SysCmd = -1) and not UnderWine then Exit;

  MouseX := GetCursorPos.x;
  ResizeActionBlocked := True;

  NewSize.Top    := Top;
  NewSize.Left   := Left;
  NewSize.Width  := ClientWidth;
  NewSize.Height := ClientHeight;

  StateNormal    := WindowState = wsNormal;
  StateMaximized := WindowState = wsMaximized;
  MoveCmd        := SysCmd = SC_MOVE;

  Maximize := SysCmd = SC_MAXIMIZE;
  Restore  := SysCmd = SC_RESTORE;
  Maximize := Maximize or (StateNormal and MoveCmd and (ClientWidth = MonitorWorkAreaWidth) and (Height >= MonitorWorkAreaHeight));
  Restore  := Restore  or StateMaximized and MoveCmd;

  Resize   := not Maximize and not Restore;
  ResizeOneChild := Resize and (MDIChildCount = 1);

  WindowSnap := Resize and StateNormal and MoveCmd and ((Top = Monitor.WorkareaRect.Top) or (AbsTop = MonitorWorkAreaHeight div 2)); // and (Top <> PrevTop);
  WindowSnap := WindowSnap or Resize and StateNormal and MoveCmd and (ClientWidth + 2 = MonitorWorkAreaWidth div 2);
  WindowUnsnap := not Restore and not WindowSnap and StateNormal and MoveCmd and Snaped;

  // Event: window snap to the left/right screen border.
  if WindowSnap or WindowUnsnap then
  begin
    ResizeOneChild := False;
    Resize := False;
  end;

  if Maximize or Restore or WindowSnap then RedrawOff;

  // MAXIMIZED EVENT
  if Maximize then
  begin
    SysCmd := SC_MAXIMIZE;
    WindowState := wsMaximized;
    SnapedToRight := False;
    Snaped := False;
    ResetConstraints(False);
    SetChildsPosition(wsMaximized);
    AutoMetrixForChilds(wsMaximized);
    AutoCutChilds(NewSize);
    RedrawChilds;
    AutoToolBarPosition(NewSize);
  end


  // SET NORMAL WINDOW SIZE
  else if Restore then begin

    SysCmd := SC_RESTORE;
    WindowState := wsNormal;
    SnapedToRight := False;
    Snaped := False;

    SetChildsPosition(wsNormal);
    AutoMetrixForChilds(wsNormal);
    NewSize := GetSizeForChilds(wsNormal, False);

    if NewSize.Width > MonitorWorkAreaWidth then
      NewSize.Width := MonitorWorkAreaWidth - DoubleBorderSize;
      
    if MoveCmd then begin
      SizeFixed := True;
      if (MouseX < Left) or (MouseX > Left + NewSize.Width) then
        MoveShift := (MouseX - (NewSize.Width div 2)) - Left;
    end;

    AutoCutChilds(NewSize);
    RedrawChilds;
    SetWindowSize(NewSize);
    AutoToolBarPosition(NewSize);
  end

  // Resize one child
  else if ResizeOneChild then with TMDIChild(ActiveMDIChild) do begin
    PageControl1.Height := WorkAreaHeight(MainForm.ClientHeight) - PageControl1.Top + 5;
    HeightChanged := LastHeight <> PageControl1.Height;
    LastHeight := PageControl1.Height;
    Tracks.RedrawDisabled := True;
    AutoResizeForm;
    Tracks.RedrawDisabled := False;
  end

  else if Resize then begin
    AutoToolBarPosition(NewSize);
    AutoMetrixForChilds(WindowState);
    AutoCutChilds(NewSize);
    RedrawChilds;
  end

  // Aero Snap
  else if WindowSnap then begin
    Snaped := True;
    NewSize := GetSizeForChilds(wsNormal, False);

    MonitorRect := Monitor.WorkareaRect;
    if Left - MonitorRect.Left > 0 then begin
      NewSize.Left := MonitorRect.Right - NewSize.Width - BorderSize - 1;
      SnapedToRight := True;
    end
    else
      SnapedToRight := False;

    NewSize.Top := MonitorRect.Top;
    NewSize.Height := MonitorRect.Bottom - OuterHeight + BorderSize - 1 - NewSize.Top;

    SizeFixed := True;
    SetWindowSize(NewSize);

    SetChildsPosition(wsNormal);
    AutoMetrixForChilds(wsNormal);
    AutoToolBarPosition(NewSize);
    AutoCutChilds(NewSize);
    RedrawChilds;

  end

  // Unsnap
  else if WindowUnsnap then begin
    SizeFixed := True;
    Snaped := False;
    SnapedToRight := False;

    SetChildsPosition(wsNormal);
    AutoMetrixForChilds(wsNormal);

    NewSize.Width := ChildsWidth;
    if NewSize.Width > MonitorWorkAreaWidth then
      NewSize.Width := MonitorWorkAreaWidth - DoubleBorderSize;

    //if (MouseX < Left) or (MouseX > Left + NewSize.Width) then
      MoveShift := (MouseX - (NewSize.Width div 2)) - Left;

    AutoCutChilds(NewSize);
    RedrawChilds;
    WindowState := wsNormal;
    AutoToolBarPosition(NewSize);
    SetWindowSize(NewSize);
  end;


  StatusBar.Panels[0].Width := ClientWidth - StatusBar.Panels[1].Width - StatusBar.Panels[2].Width - 8;

  {$IFDEF DEBUG}
 { StatusBar.Panels[0].Text := Format(
    'Maximize: %d, Restore: %d, Snap: %d, Unsnap: %d, Resize: %d, OneChRes: %d',
    [Ord(Maximize), Ord(Restore), Ord(WindowSnap), Ord(WindowUnsnap), Ord(Resize), Ord(ResizeOneChild)]
  );  }
  {$ENDIF DEBUG}

  ResizeActionBlocked := False;
  WindowSnap := False;

  if Maximize or Restore or WindowSnap or WindowUnsnap then
    SysCmd := -1;

  if Maximize or Restore or WindowSnap then RedrawOn;

end;

procedure TMainForm.JoinTracksUpdate(Sender: TObject);
var
  i, count: Integer;
  Active: Boolean;
  s1,s2:string;
begin
  if (MDIChildCount <= 1) or (ExportStarted) then
  begin
    JoinTracks.Enabled  := False;
    JoinTracks1.Visible := False;
//    if MDIChildCount = 1 then
//      TMDIChild(ActiveMDIChild).JoinTracksBtn.Enabled := False;
    Exit;
  end;

  // Calculate number of non-turbotrack childs
{
  count := 0;
  for i := 0 to MDIChildCount-1 do
    if (TMDIChild(MDIChildren[i]).TSWindow[0] = nil)
     or (TMDIChild(MDIChildren[i]).TSWindow[1] = nil) then
      Inc(count);
}
  MultitrackReorder;

  for i := 0 to MDIChildCount-1 do
  begin
    if TMDIChild(MDIChildren[i]).TSWindow[0] <> nil then begin
      s1:='T'+inttostr(TMDIChild(MDIChildren[i]).TSWindow[0].WinNumber);
      TMDIChild(MDIChildren[i]).ButtonDisjoin.Visible := True;
    end else begin
      s1:='--';
      TMDIChild(MDIChildren[i]).ButtonDisjoin.Visible := False;
    end;
    if TMDIChild(MDIChildren[i]).TSWindow[1] <> nil then
      s2:='T'+inttostr(TMDIChild(MDIChildren[i]).TSWindow[1].WinNumber)
    else s2:='--';
    TMDIChild(MDIChildren[i]).Label4.Caption:=s1+' - '+s2;
  end;

  JoinTracks.Enabled  := True;
  JoinTracks1.Visible := True;

{
  Active := count >= 2;

  JoinTracks.Enabled  := Active;
  JoinTracks1.Visible := Active;
  for i := 0 to MDIChildCount-1 do
    TMDIChild(MDIChildren[i]).JoinTracksBtn.Enabled := Active;
}

end;

procedure TMainForm.MultitrackReorder;
var
  child1,child2,child3: TMDIChild;
  x1,x2,x3:integer;
  i:integer;
begin
//
  for i := 0 to MDIChildCount-1 do
  begin
    child1:=TMDIChild(MDIChildren[i]);
    child2:=child1.TSWindow[0];
    child3:=child1.TSWindow[1];

    x1:=child1.Left;
    if child2<>nil then x2:=child2.Left else x2:=-99999;
    if child3<>nil then x3:=child3.Left else x3:=-99999;

    //single
    if (child3=nil) and (child2=nil) then
      continue;

    //2ts
    if (child3=nil) and (child2<>nil) then
    begin
      if (x1<x2) then
      begin
        child2.NumModule:=1;
        child1.NumModule:=2;
      end;
    end;

    if (child2=nil) or (child3=nil) then continue;

    //3ts
    if ((x1<x3) and (x3<x2)) // 1 3 2 => 1 2 3
    or ((x2<x1) and (x1<x3)) // 2 1 3 => 3 1 2
    or ((x3<x2) and (x2<x1)) // 3 2 1 => 2 3 1
    then
    begin //swap 2 and 3
      child1.TSWindow[0]:=child3;
      child1.TSWindow[1]:=child2;
    end;
    if (x1<x2) and (x2<x3) then
    begin
      child1.NumModule:=1;
      child2.NumModule:=2;
      child3.NumModule:=3;
    end;
  end;

end;

procedure TMainForm.JoinTracksExecute(Sender: TObject);
var
  i: Integer;
  CurChild, ChildToJoin: TMDIChild;
  NewSize: TSize;
  s: string;
begin
  CurChild := TMDIChild(ActiveMDIChild);

  TSSel.ListBox1.Clear;

  for i := 0 to MDIChildCount-1 do
  begin
    if ((TMDIChild(MDIChildren[i]).TSWindow[0] = nil)
     or (TMDIChild(MDIChildren[i]).TSWindow[1] = nil))
     and (TMDIChild(MDIChildren[i]).TSWindow[0] <> CurChild)
     and (TMDIChild(MDIChildren[i]).TSWindow[1] <> CurChild)
     and (TMDIChild(MDIChildren[i]) <> CurChild) then begin
      s := TMDIChild(MDIChildren[i]).Caption;
      if s = '' then s := '---';
      TSSel.ListBox1.AddItem(s, TMDIChild(MDIChildren[i]));
    end;
  end;

  if (TSSel.ListBox1.Count > 0) and (TSSel.ShowModal = mrOk) and (TSSel.ListBox1.ItemIndex >= 0) then
  begin
    Dec(WinCount);

    if MDIChildCount >= 2 then begin
      SetChildsPosition(WindowState);
      AutoMetrixForChilds(WindowState);
      RedrawChilds;
      NewSize := GetSizeForChilds(WindowState, False);
      AutoToolBarPosition(NewSize);
      SetWindowSize(NewSize);
    end;
    ChildToJoin := TMDIChild(TSSel.ListBox1.Items.Objects[TSSel.ListBox1.ItemIndex]);
    CurChild.JoinChild(ChildToJoin);

    JoinTracksUpdate(self);
    CurChild.SinchronizeModules;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  PostMessage(Handle, WM_USER, 0, 0);
end;

procedure TMainForm.SaveAsTemplateUpdate(Sender: TObject);
begin
  SaveAsTemplate.Enabled  := (MDIChildCount <> 0) and not ExportStarted;
  SaveAsTemplate1.Visible := SaveAsTemplate.Enabled;
end;

procedure TMainForm.SaveAsTemplateExecute(Sender: TObject);
begin
  StartupAction := 0;
  TemplateSongPath := VortexDocumentsDir +'\template.vt2';
  DontAddToRecent := True;
  SavePT3(GetMainModule, TemplateSongPath, True);
  DontAddToRecent := False;
  Application.MessageBox('Done. Song is successfully saved as a startup template.',
    'Save As Template', MB_OK + MB_ICONINFORMATION + MB_TOPMOST);

end;

procedure TMainForm.UpdateDecHexValues;
var i: Integer;
begin
  for i := 0 to MDIChildCount-1 do
    with TMDIChild(MDIChildren[i]) do
    begin
      if DecBaseLinesOn then
      begin
        PatternLenEdit.Text   := IntToStr(PatternLenUpDown.Position);
        SampleLenEdit.Text    := IntToStr(SampleLenUpDown.Position);
        SampleLoopEdit.Text   := IntToStr(SampleLoopUpDown.Position);
        OrnamentLenEdit.Text  := IntToStr(OrnamentLenUpDown.Position);
        OrnamentLoopEdit.Text := IntToStr(OrnamentLoopUpDown.Position);
      end
      else
      begin
        PatternLenEdit.Text   := IntToHex(PatternLenUpDown.Position, 2);
        SampleLenEdit.Text    := IntToHex(SampleLenUpDown.Position, 2);
        SampleLoopEdit.Text   := IntToHex(SampleLoopUpDown.Position, 2);
        OrnamentLenEdit.Text  := IntToHex(OrnamentLenUpDown.Position, 2);
        OrnamentLoopEdit.Text := IntToHex(OrnamentLoopUpDown.Position, 2);
      end;
    end;
end;

procedure TMainForm.DisableControlsForExport;
begin
  DisableControls(True);
  ToolBar2.Enabled := False;
  RFile1.Enabled   := False;
  RFile2.Enabled   := False;
  RFile3.Enabled   := False;
  RFile4.Enabled   := False;
  RFile5.Enabled   := False;
  RFile6.Enabled   := False;
  OpenDemo.Enabled := False;
  Options1.Enabled := False;
  Exports1.Enabled := False;
  Togglesamples1.Enabled := False;
  Tracksmanager1.Enabled := False;
  Globaltransposition1.Enabled := False;
  ExportPSG.Enabled := False;
  PlayingWindow[1].PageControl1.Enabled := False;
  if PlayingWindow[2] <> nil then PlayingWindow[2].PageControl1.Enabled := False;
  if PlayingWindow[3] <> nil then PlayingWindow[3].PageControl1.Enabled := False;
end;

procedure TMainForm.EnableControlsForExport;
begin
  ToolBar2.Enabled := True;
  RFile1.Enabled   := True;
  RFile2.Enabled   := True;
  RFile3.Enabled   := True;
  RFile4.Enabled   := True;
  RFile5.Enabled   := True;
  RFile6.Enabled   := True;
  OpenDemo.Enabled := True;
  Options1.Enabled := True;
  Exports1.Enabled := True;
  Togglesamples1.Enabled := True;
  Tracksmanager1.Enabled := True;
  Globaltransposition1.Enabled := True;
  PlayingWindow[1].PageControl1.Enabled := True;
  ExportPSG.Enabled := True;
  if PlayingWindow[2] <> nil then PlayingWindow[2].PageControl1.Enabled := True;
  if PlayingWindow[3] <> nil then PlayingWindow[3].PageControl1.Enabled := True;
  RestoreControls;
end;


procedure TMainForm.MIDITimerTimer(Sender: TObject);
begin

  // MIDI Keyboard switched off
  if (midiin1.State = misOpen) and (midiin1.DeviceCount = 0) then
  begin
    midiin1.Close;
    Exit;
  end;

  if DisableMidi then exit;
  
  // Try to detect newly connected MIDI keyboard
  if (midiin1.State = misClosed) and (midiin1.DeviceCount > 0) then
    try
      midiin1.OpenAndStart;
    except
      DisableMidi := True; //cannot enable
      Form1.optMidiEnable.Checked := not DisableMidi;
    end;

end;


procedure TMainForm.TransposeUp3Execute(Sender: TObject);
begin
  TransposeSelection(3);
end;

procedure TMainForm.TransposeDown3Execute(Sender: TObject);
begin
  TransposeSelection(-3);
end;

procedure TMainForm.TransposeUp5Execute(Sender: TObject);
begin
  TransposeSelection(5);
end;

procedure TMainForm.TransposeDown5Execute(Sender: TObject);
begin
  TransposeSelection(-5);
end;

procedure TMainForm.TransposeUp3Update(Sender: TObject);
begin
  TransposeUp3.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).Tracks.Focused;
end;

procedure TMainForm.TransposeDown3Update(Sender: TObject);
begin
  TransposeDown3.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).Tracks.Focused;
end;

procedure TMainForm.TransposeUp5Update(Sender: TObject);
begin
  TransposeUp5.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).Tracks.Focused;
end;

procedure TMainForm.TransposeDown5Update(Sender: TObject);
begin
  TransposeDown5.Enabled := (MDIChildCount <> 0) and
    TMDIChild(ActiveMDIChild).Tracks.Focused;
end;

procedure TMainForm.CopyToExtActUpdate(Sender: TObject);
var s:string;
begin
  CopyToExtAct.Enabled := (MDIChildCount <> 0) and TMDIChild(ActiveMDIChild).Tracks.Focused and TMDIChild(ActiveMDIChild).Tracks.IsSelected;
  s:='Copy to '+Form1.ExtTrackerOpt.Items[ExternalTracker];
  CopyToExtAct.Caption:=s;
end;

procedure TMainForm.CopyToExtActExecute(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  Case ExternalTracker of
    0 : TMDIChild(ActiveMDIChild).CopyToModplug;
    1 : TMDIChild(ActiveMDIChild).CopyToRenoise;
    2 : TMDIChild(ActiveMDIChild).CopyToFamiTracker;
    3 : TMDIChild(ActiveMDIChild).CopyToFurnace;
  end;
end;

procedure TMainForm.PackPatternActExecute(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  TMDIChild(ActiveMDIChild).PackPattern;
end;

procedure TMainForm.ExportPSGActExecute(Sender: TObject);
begin
  if TMDIChild(ActiveMDIChild) = nil then Exit;
  if MDIChildCount = 0 then Exit;
  if ExportStarted then Exit;
  if NoPatterns then Exit;

  // Stop playing all
  if IsPlaying then
  begin
    StopPlaying;
    RestoreControls;
  end;

  TMDIChild(ActiveMDIChild).ExportPSG;
end;

procedure TMainForm.ExportPSGActUpdate(Sender: TObject);
begin
  ExportPSGAct.Enabled := (MDIChildCount > 0) and not ExportStarted;
  Exports1.Enabled := ExportPSGAct.Enabled;
end;

procedure TMainForm.File1Click(Sender: TObject);
begin
  JoinTracksUpdate(Sender);
end;



procedure TMainForm.StatusBarDblClick(Sender: TObject);
var
  MouseClickCoord: TPoint;
  i, Width, PanelNum: Integer;
begin
  Width := 0;
  PanelNum := -1;

  // Convert absolute mouse coordinates to local coordinates
  MouseClickCoord := SmallPointToPoint(TSmallPoint(DWORD(GetMessagePos)));
  MapWindowPoints(HWND_DESKTOP, StatusBar.Handle, MouseClickCoord, 1);

  // Determine which panel user clicked on
  for i := 0 to StatusBar.Panels.Count - 1 do begin
    Width := Width + StatusBar.Panels[i].Width;
    if MouseClickCoord.X < Width then begin
      PanelNum := i;
      Break;
    end;
  end;

  if (PanelNum = -1) or (PanelNum <> 1) then Exit;

  // Copy ints info to clipboard
  Clipboard.AsText := StatusBar.Panels[1].Text;

end;

procedure TMainForm.CenteringTimerTimer(Sender: TObject);
var
  FormRect, DialogRect: TRect;
  NewLeft, NewTop: integer;
  DialogHandle: integer;
begin
  if DialogWinHandle = nil then exit;
  DialogHandle := getparent(DialogWinHandle^);

  if (DialogHandle <> 0) and IsWindowVisible(DialogHandle) then begin
    GetWindowRect(CenterWinHandle, FormRect);
    GetWindowRect(DialogHandle, DialogRect);

    NewLeft := FormRect.Left
      + (FormRect.Right - FormRect.Left) div 2
      - (DialogRect.Right - DialogRect.Left) div 2;
    NewTop := FormRect.Top
      + (FormRect.Bottom - FormRect.Top) div 2
      - (DialogRect.Bottom - DialogRect.Top) div 2;

    SetWindowPos(DialogHandle, 0, NewLeft, NewTop, 0, 0, swp_NoSize);
    CenteringTimer.Enabled := False;
    DialogWinHandle := nil;
  end;
end;

procedure TMainForm.Clearpatterns1Click(Sender: TObject);
begin
  if MDIChildCount = 0 then exit;
  if IsPlaying and (PlayMode = PMPlayModule) then exit;
  TMDIChild(ActiveMDIChild).CleanPatterns;
end;

end.

