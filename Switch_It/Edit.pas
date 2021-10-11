unit Edit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, Grids, StdCtrls;

type
  TMap = array [0..15, 0..4, 0..4] of boolean;
  TForm1 = class(TForm)
    DrawGrid1: TDrawGrid;
    ImageList1: TImageList;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1  : TForm1;
  Current: Integer;
  Map    : TMap;
implementation

{$R *.dfm}

procedure RedrawGrid;
var x, y : Integer;
begin
  for x := 0 to 4 do
    for y := 0 to 4 do
      Form1.DrawGrid1DrawCell(Form1.DrawGrid1, x, y, Form1.DrawGrid1.CellRect(x, y), []);
end;

procedure TForm1.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  ImageList1.Draw((Sender as TDrawGrid).Canvas, Rect.Left, Rect.Top, Ord(map[Current, ACol, ARow]));
end;

procedure TForm1.DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  Map[Current, ACol, ARow] := not Map[Current, ACol, Arow];
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if Current < 15 then inc(Current);
  RedrawGrid;
  Label1.Caption := IntToStr(Current);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if current > 0 then dec(Current);
  RedrawGrid;
  Label1.Caption := IntToStr(Current);
end;

procedure TForm1.FormCreate(Sender: TObject);
var Fle : file of TMap;
begin
  AssignFile(Fle, 'levels');
  Reset(fle);
  Read(fle, map);
  CloseFile(fle);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var Fle : file of TMap;
begin
  AssignFile(Fle, 'levels');
  Rewrite(fle);
  Write(Fle, Map);
  CloseFile(fle);

end;

end.
