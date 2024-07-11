unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Threading, System.Generics.Collections, System.SyncObjs;

type
  TForm2 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TMain = class
  private
    class var
      n: Integer;
      lock: TCriticalSection;
    class function IsPrime(number: Integer): Boolean;
    class procedure WriteToFile(n: Integer; threadName: string);
    class procedure PrimeFinder;
  public
    class procedure Main;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

{ TMain }
class function TMain.IsPrime(number: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  if (number <= 1) then
    Exit;
  for i := 2 to Trunc(Sqrt(number)) do
  begin
    if (number mod i = 0) then
      Exit;
  end;
  Result := True;
end;

class procedure TMain.WriteToFile(n: Integer; threadName: string);
var
  writer: TStreamWriter;
  commonWriter: TStreamWriter;
begin
  commonWriter:= TStreamWriter.Create('Result.txt', True, TEncoding.UTF8);
  commonWriter.Write(n.ToString	 + ' ');
  commonWriter.Free;
  writer := TStreamWriter.Create('thread_id_' + threadName + '.txt', True, TEncoding.UTF8);
  writer.Write(n.ToString + ' ');
  writer.Free;
end;

class procedure TMain.PrimeFinder;
var
  i: Integer;
  threadID: TThreadID;
begin
  threadID := TThread.CurrentThread.ThreadID;
  for i := 0 to 1_000_000 do
  begin
    lock.Acquire;
    try
      if (i > n) and IsPrime(i) then
      begin
        n := i;
        WriteToFile(n, IntToStr(threadID));
      end;
    finally
      lock.Release;
    end;
  end;
end;

class procedure TMain.Main;
var
  thread1, thread2: TThread;
begin
  n := 0;
  lock := TCriticalSection.Create;
  TThread.CreateAnonymousThread(PrimeFinder).Start;
  TThread.CreateAnonymousThread(PrimeFinder).Start;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
TMain.Main;
end;

end.
