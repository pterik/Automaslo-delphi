unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TFormMain = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    MemoParsed: TMemo;
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function CopyBySample(SearchStr, SampleBegin, SampleEnd:string):string;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses ComObj, XMLIntf, XMLDoc, MsXml, MsXmldom, ActiveX, XmlDom, XmlConst;

procedure TFormMain.BitBtn2Click(Sender: TObject);
var FName, FilesFolder:string;
//FileStream:TFileStream;
//S:TStringStream;
i,j, Desc_begin, Desc_End, Desc_Len:integer;
//SearchString, SampleBegin, SampleEnd:string;
HeadingTitle, Brand, Model, BigImg, SmallImg:string;
Description:array of string;
begin
if OpenDialog1.Execute then
  begin
    FName:=OpenDialog1.FileName;
    FIlesfolder:=ExtractFileDir(FName);
    //S.LoadFromFile(FName);

    Memo1.Lines.LoadFromFile(FName, TEncoding.UTF8);
    for I := 0 to Memo1.Lines.Count-1 do
      begin
      if Pos('<h1 class="heading_title">',Memo1.Lines[i])>0
        then
          begin
          HeadingTitle:=CopyBySample(Memo1.Lines[i], '<span>','</span>');
          MemoParsed.Lines.Add('HeadingTitle="'+HeadingTitle+'"!');
          end;
      if Pos('<a itemprop="brand" content=',Memo1.Lines[i])>0
        then
          begin
          Brand:=CopyBySample(Memo1.Lines[i], 'content="','" href=');
          MemoParsed.Lines.Add('Brand="'+Brand+'"!');
          end;
      if Pos('<span>������:</span>',Memo1.Lines[i])>0
        then
          begin
          Model:=Trim(CopyBySample(Memo1.Lines[i], '</span>','<br />'));
          MemoParsed.Lines.Add('Model="'+Model+'"!');
          end;
      if Pos('<div class="image">',Memo1.Lines[i])>0
        then
          begin
          BigImg:=Trim(CopyBySample(Memo1.Lines[i], 'image"><a href="','" title="'));
          MemoParsed.Lines.Add('BigImg="'+BigImg+'"!');
          SmallImg:=Trim(CopyBySample(Memo1.Lines[i], '<img itemprop="image" src="','" title="'));
          MemoParsed.Lines.Add('SmallImg="'+SmallImg+'"!');
          end;
      if Pos('itemprop="desctiption">',Memo1.Lines[i])>0
        then
          begin
          Desc_Begin:=0;
          Desc_End:=0;
          for j:=1 to 50 do
            begin
            if Pos('<div class="left">',Memo1.Lines[i+j])>0 then Desc_Begin:=j;
            if Pos('<ul class="product-benefit">',Memo1.Lines[i+j])>0 then begin Desc_End:=j; break; end;
            end;
          SetLength(Description,0);
          if (Desc_End>Desc_Begin)  and not (Desc_begin+Desc_End=0) then
            begin
            Desc_Len:=Desc_End-Desc_Begin;
            SetLength(Description,Desc_Len);
            for j := 0 to Desc_Len-1 do
              begin
              Description[j]:=Trim(Memo1.Lines[i+Desc_Begin+j]);
              end;
            end;
          //MemoParsed.Lines.Add('Description="'+IntToStr(Desc_Begin)+'!'+IntToStr(Desc_End));
          for j := 0 to Desc_Len-1 do
            if (Pos('<div',Description[j])>0) or (Pos('</div>', Description[j])>0) then Description[j]:='';
          for j := 0 to Desc_Len-1 do
            if not (Description[j]='') then MemoParsed.Lines.Add(Description[j]);
          end;

      //Ifs finished here
      end;
  end;

end;

function TFormMain.CopyBySample(SearchStr, SampleBegin, SampleEnd: string): string;
var Pos1, Pos2:integer;
begin
Pos1:=Pos(SampleBegin, SearchStr);
Pos2:=Pos(SampleEnd, SearchStr, Pos1);
if (Pos1>0) and (Pos2>0)
  then Result:=Copy(SearchStr,Pos1+length(SampleBegin), Pos2-Pos1-length(SampleBegin))
  else Result:='';
end;

end.
