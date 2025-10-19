{
High quality AY/YM sound chip emulator by Peter Sovietov aka true-grue.
https://github.com/true-grue/ayumi
(c) Peter Sovietov

Rewriten to Delphi by Ivan Pirog aka Flexx.
}
unit ayumi;

interface

const

  TONE_CHANNELS = 3;
  DECIMATE_FACTOR = 8;
  FIR_SIZE = 192;
  DC_FILTER_SIZE = 1024;
  //DC_CUTOFF = 3;

  AY_DAC_TABLE : array[0..31] of Double = (
    0.0, 0.0,
    0.00999465934234, 0.00999465934234,
    0.0144502937362, 0.0144502937362,
    0.0210574502174, 0.0210574502174,
    0.0307011520562, 0.0307011520562,
    0.0455481803616, 0.0455481803616,
    0.0644998855573, 0.0644998855573,
    0.107362478065, 0.107362478065,
    0.126588845655, 0.126588845655,
    0.20498970016, 0.20498970016,
    0.292210269322, 0.292210269322,
    0.372838941024, 0.372838941024,
    0.492530708782, 0.492530708782,
    0.635324635691, 0.635324635691,
    0.805584802014, 0.805584802014,
    1.0, 1.0
  );


  YM_DAC_TABLE : array[0..31] of Double = (
    0.0, 0.0,
    0.00465400167849, 0.00772106507973,
    0.0109559777218, 0.0139620050355,
    0.0169985503929, 0.0200198367285,
    0.024368657969, 0.029694056611,
    0.0350652323186, 0.0403906309606,
    0.0485389486534, 0.0583352407111,
    0.0680552376593, 0.0777752346075,
    0.0925154497597, 0.111085679408,
    0.129747463188, 0.148485542077,
    0.17666895552, 0.211551079576,
    0.246387426566, 0.281101701381,
    0.333730067903, 0.400427252613,
    0.467383840696, 0.53443198291,
    0.635172045472, 0.75800717174,
    0.879926756695, 1.0
  );




type

  PFirChannel  = ^TFirChannel;
  TFirChannel  = array[0..FIR_SIZE*2] of Double;

  PToneChannel = ^TToneChannel;
  TToneChannel = record
    tonePeriod:  Integer;
    toneCounter: Integer;
    tone:        Integer;
    tOff:        Integer;
    nOff:        Integer;
    eOn:         Integer;
    volume:      Integer;
    panLeft:     Double;
    panRight:    Double;
  end;


  PInterpolatorArray = ^TInterpolatorArray;
  TInterpolatorArray = array[0..4] of Double;
  TInterpolator = record
    c: TInterpolatorArray;
    y: TInterpolatorArray;
  end;


  PDCFilter = ^TDCFilter;
  TDCFilter = record
    sum:   Double;
    delay: array[0..DC_FILTER_SIZE] of Double;
  end;

  PDCFilterWbcbz7 = ^TDCFilterWbcbz7;
  TDCFilterWbcbz7 = record
    r: Double;
    oldX, oldY: Double;
  end;

  TProc = (CSlideUp, CSlideDown, CHoldBottom, CHoldTop);

const

  ENVELOPE_SHAPES : array[0..15] of array[0..1] of TProc = (
  
    (CSlideDown, CHoldBottom),
    (CSlideDown, CHoldBottom),
    (CSlideDown, CHoldBottom),
    (CSlideDown, CHoldBottom),

    (CSlideUp, CHoldBottom),
    (CSlideUp, CHoldBottom),
    (CSlideUp, CHoldBottom),
    (CSlideUp, CHoldBottom),

    (CSlideDown, CSlideDown),
    (CSlideDown, CHoldBottom),
    (CSlideDown, CSlideUp),
    (CSlideDown, CHoldTop),

    (CSlideUp, CSlideUp),
    (CSlideUp, CHoldTop),
    (CSlideUp, CSlideDown),
    (CSlideUp, CHoldBottom)

  );


type


  TAyumi = class
    SamRate: Integer;

    channels: array[0..TONE_CHANNELS] of TToneChannel;

    noisePeriod:  Integer;
    noiseCounter: Integer;
    noise:        Integer;

    envelopeCounter:  Integer;
    envelopePeriod:   Integer;
    envelopeShape:    Integer;
    envelopeSegment:  Integer;
    envelope:         Integer;

    dacTable: array[0..31] of Double;

    step: Double;
    x:    Double;

    interpolatorLeft:  TInterpolator;
    interpolatorRight: TInterpolator;

    firLeft:  TFirChannel;
    firRight: TFirChannel;
    firIndex: Integer;


    DCType:   Integer;
    DCCutOff: Integer;

    DCLeft:   TDCFilter;
    DCRight:  TDCFilter;

    DCLeftWbcbz7:  TDCFilterWbcbz7;
    DCRightWbcbz7: TDCFilterWbcbz7;



    DCIndex:  Integer;

    left:  Double;
    right: Double;

    constructor Create;
    destructor Destroy; override;
    procedure Configure(isYM: Boolean; clockRate: Double; sampleRate: Integer; ADCType: Integer);
    procedure SetDCType(Value: Integer);
    procedure SetDCCutoff(Value: Integer);
    procedure ResetChip;

    procedure SetChipType(isYM: Boolean);
    procedure SetChipFreq(clockRate: Double);
    procedure SetPan(index: Integer; pan: Double; isEqp: Boolean);
    procedure SetTone(index, period: Integer);
    procedure SetNoise(period: Integer);
    procedure SetMixer(index, tOff, nOff, eOn: Integer);
    procedure SetVolume(index, volume: Integer);
    procedure ResetSegment;
    procedure SetEnvelope(period: Integer);
    procedure SetEnvelopeShape(shape: Integer);

    procedure SlideUp;
    procedure SlideDown;
    procedure HoldTop;
    procedure HoldBottom;

    function  UpdateTone(index: Integer): Integer;
    function  UpdateNoise: Integer;
    function  UpdateEnvelope: Integer;
    procedure UpdateMixer;



    function  Decimate(x: PFirChannel): Double;
    function  DCFilter(dc: PDCFilter; index: Integer; x: Double): Double;
    function  DCFilterWbcbz7(dc: PDCFilterWbcbz7; x: Double): Double;
    procedure RemoveDC;

    procedure Process;

  end;



implementation


constructor TAyumi.Create;
begin
  //
end;


destructor TAyumi.Destroy;
begin
  inherited;
end;


procedure TAyumi.Configure(isYM: Boolean; clockRate: Double; sampleRate: Integer; ADCType: Integer);
var
  i: Integer;

begin

  noise    := 1;
  SamRate  := sampleRate;
  if SamRate = 0 then SamRate := 44100;
  DCType   := ADCType;
  DCCutOff := 3;

  SetEnvelope(1);
  SetChipType(isYM);
  SetChipFreq(clockRate);

  if DCType = 2 then begin
    DCLeftWbcbz7.r  := 1 - (2 * 3.14159265358979 * DCCutOff / SamRate);
    DCRightWbcbz7.r := DCLeftWbcbz7.r;
  end;

  for i := 0 to High(channels) do
    SetTone(i, 1);

end;


procedure TAyumi.SetDCType(Value: Integer);
begin
  DCType := Value;
end;


procedure TAyumi.SetDCCutoff(Value: Integer);
begin
  if (Value < 3) or (Value > 10) then Exit;
  DCCutOff := Value;

  DCLeftWbcbz7.oldX := 0;
  DCLeftWbcbz7.oldY := 0;
  DCRightWbcbz7.oldX := 0;
  DCRightWbcbz7.oldY := 0;
  DCLeftWbcbz7.r  := 1 - (2 * 3.14159265358979 * DCCutOff / SamRate);
  DCRightWbcbz7.r := DCLeftWbcbz7.r;
end;

procedure TAyumi.ResetChip;
var i: Integer;
begin
  x := 0;
  noisePeriod  := 0;
  noiseCounter := 0;
  noise := 1;
  envelopeCounter := 0;
  envelopePeriod  := 0;
  envelopeShape   := 0;
  envelopeSegment := 0;
  envelope := 0;
  SetEnvelope(1);
  for i := 0 to 4 do begin
    interpolatorLeft.c[i]  := 0;
    interpolatorLeft.y[i]  := 0;
    interpolatorRight.c[i] := 0;
    interpolatorRight.y[i] := 0;
  end;
  for i := 0 to FIR_SIZE*2 do begin
    firLeft[i]  := 0;
    firRight[i] := 0;
  end;
  firIndex := 0;
  DCIndex := 0;

  DCLeft.sum := 0;
  DCRight.sum := 0;
  for i := 0 to High(DCLeft.Delay) do
    DCLeft.delay[i] := 0;
   for i := 0 to High(DCRight.Delay) do
    DCRight.delay[i] := 0;

  DCLeftWbcbz7.oldX := 0;
  DCLeftWbcbz7.oldY := 0;
  DCRightWbcbz7.oldX := 0;
  DCRightWbcbz7.oldY := 0;
  left  := 0;
  right := 0;
end;


procedure TAyumi.SetChipType(isYM: Boolean);
var i: Integer;
begin
  for i := 0 to 31 do
    if isYM then
      dacTable[i] := YM_DAC_TABLE[i]
    else
      dacTable[i] := AY_DAC_TABLE[i];
end;


procedure TAyumi.SetChipFreq(clockRate: Double);
begin
  step := clockRate / (SamRate * 8 * DECIMATE_FACTOR);
end;


procedure TAyumi.SetPan(index: Integer; pan: Double; isEqp: Boolean);
begin

  if isEqp then
  begin
    channels[index].panLeft  := Sqrt(1 - pan);
    channels[index].panRight := Sqrt(pan);
  end
  else
  begin
    channels[index].panLeft  := 1 - pan;
    channels[index].panRight := pan;
  end;

end;


procedure TAyumi.SetTone(index, period: Integer);
begin
  period := period and $0fff;
  channels[index].tonePeriod := Ord(period = 0) or period;
end;


procedure TAyumi.SetNoise(period: Integer);
begin
  period := period and $1f;
  noisePeriod := Ord((period = 0)) or period;
end;



procedure TAyumi.SetMixer(index, tOff, nOff, eOn: Integer);
begin
  channels[index].tOff := tOff and 1;
  channels[index].nOff := nOff and 1;
  channels[index].eOn  := eOn;
end;


procedure TAyumi.SetVolume(index, volume: Integer);
begin
  channels[index].volume := volume and $0f;
end;


procedure TAyumi.SetEnvelope(period: Integer);
begin
  period := period and $ffff;
  envelopePeriod := Ord(period = 0) or period;
end;


procedure TAyumi.ResetSegment;
var
  envProc: TProc;

begin

  envProc := ENVELOPE_SHAPES[envelopeShape][envelopeSegment];

  if (envProc = CSlideDown) or (envProc = CHoldTop) then
    envelope := 31
  else
    envelope := 0;

end;



procedure TAyumi.SetEnvelopeShape(shape: Integer);
begin
  envelopeShape := shape and $0f;
  envelopeCounter := 0;
  envelopeSegment := 0;
  ResetSegment;
end;


  procedure TAyumi.SlideUp;
begin

  Inc(envelope);

  if envelope > 31 then begin
    envelopeSegment := envelopeSegment xor 1;
    ResetSegment;
  end;

end;


procedure TAyumi.SlideDown;
begin

  Dec(envelope);

  if envelope < 0 then begin
    envelopeSegment := envelopeSegment xor 1;
    ResetSegment;
  end

end;


procedure TAyumi.HoldTop;
begin
  //
end;


procedure TAyumi.HoldBottom;
begin
  //
end;


function TAyumi.UpdateTone(index: Integer): Integer;
begin

  with channels[index] do begin

    Inc(toneCounter);

    if toneCounter >= tonePeriod then begin
      toneCounter := 0;
      tone := tone xor 1;
    end;

    Result := tone;

  end;

end;


function TAyumi.UpdateNoise: Integer;
var
  bit0x3: Integer;

begin

  Inc(noiseCounter);

  if noiseCounter >= (noisePeriod shl 1) then begin

    noiseCounter := 0;
    bit0x3 := ((noise xor (noise shr 3)) and 1);
    noise := (noise shr 1) or (bit0x3 shl 16);

  end;

  Result := noise and 1;

end;


function TAyumi.UpdateEnvelope: Integer;
begin

  Inc(envelopeCounter);

  if envelopeCounter >= envelopePeriod then begin

    envelopeCounter := 0;
    Case ENVELOPE_SHAPES[envelopeShape][envelopeSegment] of
      CSlideUp: SlideUp;
      CSlideDown: SlideDown;
      CHoldTop: HoldTop;
      CHoldBottom: HoldBottom;
    end;

  end;

  Result := envelope;

end;


procedure TAyumi.UpdateMixer;
var
  i, res: Integer;
  iNoise: Integer;

begin

  iNoise := UpdateNoise;
  UpdateEnvelope;

  left  := 0;
  right := 0;

  for i := 0 to TONE_CHANNELS - 1 do begin

    res := (updateTone(i) or channels[i].tOff) and (iNoise or channels[i].nOff);

    if channels[i].eOn <> 0 then
      res := res * envelope
    else
      res := res * channels[i].volume * 2 + 1;

    left  := left + dacTable[res] * channels[i].panLeft;
    right := right + dacTable[res] * channels[i].panRight;

  end;

end;







function TAyumi.Decimate(x: PFirChannel): Double;
var
  i: Integer;
const
  cn: array [0..84] of Double = (
  -0.0000046183113992051936, -0.00001117761640887225,  -0.000018610264502005432, -0.000025134586135631012,
  -0.000028494281690666197,  -0.000026396828793275159, -0.000017094212558802156,
  0.000023798193576966866,   0.000051281160242202183,  0.00007762197826243427,   0.000096759426664120416,
  0.00010240229300393402,    0.000089344614218077106,  0.000054875700118949183,
  -0.000069839082210680165,  -0.0001447966132360757,   -0.00021158452917708308,  -0.00025535069106550544,
  -0.00026228714374322104,   -0.00022258805927027799,  -0.00013323230495695704,
  0.00016182578767055206,    0.00032846175385096581,   0.00047045611576184863,   0.00055713851457530944,
  0.00056212565121518726,    0.00046901918553962478,   0.00027624866838952986,
  -0.00032564179486838622,   -0.00065182310286710388,  -0.00092127787309319298,  -0.0010772534348943575,
  -0.0010737727700273478,    -0.00088556645390392634,  -0.00051581896090765534,
  0.00059548767193795277,    0.0011803558710661009,    0.0016527320270369871,    0.0019152679330965555,
  0.0018927324805381538,     0.0015481870327877937,    0.00089470695834941306,
  -0.0010178225878206125,    -0.0020037400552054292,   -0.0027874356824117317,   -0.003210329988021943,
  -0.0031540624117984395,    -0.0025657163651900345,   -0.0014750752642111449,
  0.0016624165446378462,     0.0032591192839069179,    0.0045165685815867747,    0.0051838984346123896,
  0.0050774264697459933,     0.0041192521414141585,    0.0023628575417966491,
  -0.0026543507866759182,    -0.0051990251084333425,   -0.0072020238234656924,   -0.0082672928192007358,
  -0.0081033739572956287,    -0.006583111539570221,    -0.0037839040415292386,
  0.0042781252851152507,     0.0084176358598320178,    0.01172566057463055,      0.013550476647788672,
  0.013388189369997496,      0.010979501242341259,     0.006381274941685413,
  -0.007421229604153888,     -0.01486456304340213,     -0.021143584622178104,    -0.02504275058758609,
  -0.025473530942547201,     -0.021627310017882196,    -0.013104323383225543,
  0.017065133989980476,      0.036978919264451952,     0.05823318062093958,      0.079072012081405949,
  0.097675998716952317,      0.11236045936950932,      0.12176343577287731,
  0.125);

begin
  Result :=  cn[0] * (x[1] + x[191]) +
             cn[1] * (x[2] + x[190]) +
             cn[2] * (x[3] + x[189]) +
             cn[3] * (x[4] + x[188]) +
             cn[4] * (x[5] + x[187]) +
             cn[5] * (x[6] + x[186]) +
             cn[6] * (x[7] + x[185]) +

             cn[7] * (x[9] + x[183]) +
             cn[8] * (x[10] + x[182]) +
             cn[9] * (x[11] + x[181]) +
             cn[10] * (x[12] + x[180]) +
             cn[11] * (x[13] + x[179]) +
             cn[12] * (x[14] + x[178]) +
             cn[13] * (x[15] + x[177]) +

             cn[14] * (x[17] + x[175]) +
             cn[15] * (x[18] + x[174]) +
             cn[16] * (x[19] + x[173]) +
             cn[17] * (x[20] + x[172]) +
             cn[18] * (x[21] + x[171]) +
             cn[19] * (x[22] + x[170]) +
             cn[20] * (x[23] + x[169]) +

             cn[21] * (x[25] + x[167]) +
             cn[22] * (x[26] + x[166]) +
             cn[23] * (x[27] + x[165]) +
             cn[24] * (x[28] + x[164]) +
             cn[25] * (x[29] + x[163]) +
             cn[26] * (x[30] + x[162]) +
             cn[27] * (x[31] + x[161]) +

             cn[28] * (x[33] + x[159]) +
             cn[29] * (x[34] + x[158]) +
             cn[30] * (x[35] + x[157]) +
             cn[31] * (x[36] + x[156]) +
             cn[32] * (x[37] + x[155]) +
             cn[33] * (x[38] + x[154]) +
             cn[34] * (x[39] + x[153]) +

             cn[35] * (x[41] + x[151]) +
             cn[36] * (x[42] + x[150]) +
             cn[37] * (x[43] + x[149]) +
             cn[38] * (x[44] + x[148]) +
             cn[39] * (x[45] + x[147]) +
             cn[40] * (x[46] + x[146]) +
             cn[41] * (x[47] + x[145]) +

             cn[42] * (x[49] + x[143]) +
             cn[43] * (x[50] + x[142]) +
             cn[44] * (x[51] + x[141]) +
             cn[45] * (x[52] + x[140]) +
             cn[46] * (x[53] + x[139]) +
             cn[47] * (x[54] + x[138]) +
             cn[48] * (x[55] + x[137]) +

             cn[49] * (x[57] + x[135]) +
             cn[50] * (x[58] + x[134]) +
             cn[51] * (x[59] + x[133]) +
             cn[52] * (x[60] + x[132]) +
             cn[53] * (x[61] + x[131]) +
             cn[54] * (x[62] + x[130]) +
             cn[55] * (x[63] + x[129]) +

             cn[56] * (x[65] + x[127]) +
             cn[57] * (x[66] + x[126]) +
             cn[58] * (x[67] + x[125]) +
             cn[59] * (x[68] + x[124]) +
             cn[60] * (x[69] + x[123]) +
             cn[61] * (x[70] + x[122]) +
             cn[62] * (x[71] + x[121]) +

             cn[63] * (x[73] + x[119]) +
             cn[64] * (x[74] + x[118]) +
             cn[65] * (x[75] + x[117]) +
             cn[66] * (x[76] + x[116]) +
             cn[67] * (x[77] + x[115]) +
             cn[68] * (x[78] + x[114]) +
             cn[69] * (x[79] + x[113]) +

             cn[70] * (x[81] + x[111]) +
             cn[71] * (x[82] + x[110]) +
             cn[72] * (x[83] + x[109]) +
             cn[73] * (x[84] + x[108]) +
             cn[74] * (x[85] + x[107]) +
             cn[75] * (x[86] + x[106]) +
             cn[76] * (x[87] + x[105]) +

             cn[77] * (x[89] + x[103]) +
             cn[78] * (x[90] + x[102]) +
             cn[79] * (x[91] + x[101]) +
             cn[80] * (x[92] + x[100]) +
             cn[81] * (x[93] + x[99]) +
             cn[82] * (x[94] + x[98]) +
             cn[83] * (x[95] + x[97]) +
             cn[84] * x[96];

  for i := 0 to DECIMATE_FACTOR-1 do
    x[FIR_SIZE - DECIMATE_FACTOR + i] := x[i];

end;


function TAyumi.DCFilter(dc: PDCFilter; index: Integer; x: Double): Double;
begin

  dc.sum := dc.sum + x - dc.delay[index] ;
  dc.delay[index] := x;

  Result := x - (dc.sum / DC_FILTER_SIZE);

end;


function TAyumi.DCFilterWbcbz7(dc: PDCFilterWbcbz7; x: Double): Double;
var y: Double;
begin

  y := x - dc.oldX + dc.r * dc.oldY;
  dc.oldX := x;
  dc.oldY := y;

  Result := y;

end;


procedure TAyumi.RemoveDC;
begin

  case DCType of

    1: begin
      left  := DCFilter(@DCLeft, DCIndex, left);
      right := DCFilter(@DCRight, DCIndex, right);
      DCIndex := (DCIndex + 1) and (DC_FILTER_SIZE - 1);
    end;

    2: begin
      left  := DCFilterWbcbz7(@DCLeftWbcbz7, left);
      right := DCFilterWbcbz7(@DCRightWbcbz7, right);
    end;

  end;

end;



procedure TAyumi.Process;
var
  i: Integer;
  y1: Double;
  cLeft, yLeft, cRight, yRight: PInterpolatorArray;
  pFirLeft, pFirRight: PFirChannel;
  firOffset: Integer;

begin

  cLeft  := @interpolatorLeft.c;
  yLeft  := @interpolatorLeft.y;

  cRight := @interpolatorRight.c;
  yRight := @interpolatorRight.y;

  firOffset := FIR_SIZE - (firIndex * DECIMATE_FACTOR);
  pFirLeft  := @firLeft[firOffset];
  pFirRight := @firRight[firOffset];

  firIndex  := (firIndex + 1) mod ((FIR_SIZE div DECIMATE_FACTOR) - 1);

  for i := DECIMATE_FACTOR - 1 downto 0 do begin

    x := x + step;
    while x >= 1 do begin

      x := x - 1;
      yLeft[0] := yLeft[1];
      yLeft[1] := yLeft[2];
      yLeft[2] := yLeft[3];

      yRight[0] := yRight[1];
      yRight[1] := yRight[2];
      yRight[2] := yRight[3];

      UpdateMixer;

      yLeft[3]  := left;
      yRight[3] := right;

      y1 := yLeft[2] - yLeft[0];
      cLeft[0] := 0.5 * yLeft[1] + 0.25 * (yLeft[0] + yLeft[2]);
      cLeft[1] := 0.5 * y1;
      cLeft[2] := 0.25 * (yLeft[3] - yLeft[1] - y1);

      y1 := yRight[2] - yRight[0];
      cRight[0] := 0.5 * yRight[1] + 0.25 * (yRight[0] + yRight[2]);
      cRight[1] := 0.5 * y1;
      cRight[2] := 0.25 * (yRight[3] - yRight[1] - y1);

    end;

    pFirLeft[i]  := (cLeft[2] * x + cLeft[1]) * x + cLeft[0];
    pFirRight[i] := (cRight[2] * x + cRight[1]) * x + cRight[0];

  end;

  left  := decimate(pFirLeft);
  right := decimate(pFirRight);


end;



end.
