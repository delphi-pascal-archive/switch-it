unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, Grids, ExtCtrls, ComCtrls, StdCtrls, Buttons, MMSystem, IniFiles;

type
  TMap = array [0..15, 0..4, 0..4] of Boolean;
  TScore = record
    Name  : PChar;
    Score : Integer;
  end;
  THighscores = array [1..10] of TScore;
  TForm1 = class(TForm)
    Leds: TDrawGrid;
    ImageList1: TImageList;
    Timer1: TTimer;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    Timer2: TTimer;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Label2: TLabel;
    procedure LedsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure LedsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Map  : TMap;
  Current : Integer;
  OrigMap : TMap;
  Scores  : THighscores;
  AppDir  : String;
implementation


{$R *.dfm}

function IsEmpty(Number : Integer) : Boolean;
var x, y : Integer;
begin
  result := true;
  for x := 0 to 4 do
    for y := 0 to 4 do
      if map[number, x, y] then result := false;

end;

procedure RefreshGrid;
var x, y, x1, y1 : Integer;
    R            : TRect;
begin
  for x := 0 to 4 do
    for y := 0 to 4 do begin
      R := Form1.Leds.CellRect(x, y);
      X1 := ((R.Right - R.Left) div 2 - 8) + R.Left;
      Y1 := ((R.Bottom - R.Top) div 2 - 8) + R.Top;
      Form1.ImageList1.Draw(Form1.Leds.Canvas, X1, Y1, Ord(Map[Current, x, y]));
    end;
      
end;

procedure TForm1.LedsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var X, Y : Integer;
    R    : TRect;
begin
  If (ACol < 0) or (ARow > Leds.RowCount - 1) or (ARow < 0) or (ACol > Leds.ColCount - 1) then exit;
  R := (Sender as TDrawGrid).CellRect(ACol, ARow);
  X := ((R.Right - R.Left) div 2 - 8) + R.Left;
  Y := ((R.Bottom - R.Top) div 2 - 8) + R.Top;
  ImageList1.Draw((Sender as TDrawGrid).Canvas, X, Y, Ord(Map[Current, ACol, ARow]));
end;

procedure TForm1.LedsSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  // Вкл - выкл лампы
  Map[Current, ACol, ARow] := not Map[Current, ACol, ARow];
  if ACol > 0 then Map[Current, ACol - 1, ARow] := not Map[Current, ACol - 1, ARow];
  if ACol < Leds.ColCount - 1 then Map[Current, ACol + 1, ARow] := not Map[Current, ACol + 1, ARow];
  if ARow > 0 then Map[Current, ACol, ARow - 1] := not Map[Current, ACol, ARow - 1];
  if ARow < Leds.RowCount - 1 then Map[Current, ACol, ARow + 1] := not Map[Current, ACol, ARow + 1];
  // Перерисовывание
  LedsDrawCell(Leds,ACol - 1, ARow, Rect(ACol-1*15, ARow*15, 0, 0), []);
  LedsDrawCell(Leds,ACol + 1, ARow, Rect(ACol+1*15, ARow*15, 0, 0), []);
  LedsDrawCell(Leds,ACol, ARow - 1, Rect(ACol*15, ARow-1*15, 0, 0), []);
  LedsDrawCell(Leds,ACol, ARow + 1, Rect(ACol*15, ARow+1*15, 0, 0), []);

  PlaySound('switch.wav', 0, SND_ASYNC);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var onned : Boolean;
    x, y  : Integer;
begin
  onned := false;
//  Label1.Visible := false;
  // Проверяем, есть ли включенные лампочки
  for x := 0 to 4 do
    for y := 0 to 4 do
      if Map[Current, x, y] then onned := true;

  if not onned then begin
    if (IsEmpty(Current + 1)) or (Current = 15) then begin
      Label1.Caption := 'Победа!';
      Label1.Visible := true
    end else begin
      Label1.Caption := 'Следующий уровень!';
      Label1.Visible := true;
      Timer2.Enabled := true;
      Current := Current + 1;
      Label2.Caption := IntToStr(current + 1);
      RefreshGrid;
      PlaySound('hit.wav', 0, SND_ASYNC);
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Current := Current + 1;
  RefreshGrid;
end;

procedure TForm1.FormCreate(Sender: TObject);
var fle : file of TMap;
begin
  AppDir := ExtractFilePath(Application.ExeName);
  // Чтение уровней
  AssignFile(fle, 'levels');
  Reset(fle);
  Read(fle, map);
  CloseFile(fle);
  Current := 0;
  OrigMap := Map;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := false;
  Label1.Hide;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  Current := 0;
  Map := OrigMap;
  RefreshGrid;
  PlaySound('return.wav', 0, SND_ASYNC);
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  Map := OrigMap;
  RefreshGrid;
  PlaySound('return.wav', 0, SND_ASYNC);
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  if current = 15 then exit;
  Map[current+1] := OrigMap[current+1];
  inc(current);
  RefreshGrid;
  Label2.Caption := IntToStr(current + 1);
  PlaySound(PChar('levelchrg.wav'), 0, SND_ASYNC);
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  if current = 0 then exit;
  Map[current-1] := OrigMap[current-1];
  dec(current);
  RefreshGrid;
  Label2.Caption := IntToStr(current + 1);
  PlaySound('levelchrg.wav', 0, SND_ASYNC);
end;

end.
