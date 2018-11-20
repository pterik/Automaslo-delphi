unit UnitAutomaslo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

const Brands : array [1..9] of string = ('AGIP','AGRINOL','�������', 'ARAL','BP','CASTROL','ELF','FUCHS TITAN','HONDA');

type
  TFormAutoMaslo = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    Memo2: TMemo;
    BitBtn3: TBitBtn;
    SaveDialog1: TSaveDialog;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  private
    { Private declarations }
    function ReplaceCapitals(const Str:string):string;
  public
    OutputStr:widestring;
    function CopyBySample(SearchStr, SampleBegin, SampleEnd:string):string;
    procedure SaveIt(const PrintStr: widestring; const FirstPosition:boolean; const isQuoted:boolean);
  end;

var
  FormAutoMaslo: TFormAutoMaslo;

implementation

{$R *.dfm}

uses System.WideStrUtils;

procedure TFormAutoMaslo.BitBtn2Click(Sender: TObject);
var FName, FilesFolder:string;
//FileStream:TFileStream;
//S:TStringStream;
i,j, Desc_begin, Desc_End, Desc_Len:integer;
//SearchString, SampleBegin, SampleEnd:string;
Litraz, HeadingTitle, Brand, Model, BigImg, SmallImg, ShortImg:string;
Description:array of string;
Descr:wideString;
sr:TSearchRec;
begin
Memo1.Clear;
Memo2.Clear;
if not OpenDialog1.Execute then exit;
FName:=OpenDialog1.FileName;
FIlesfolder:=ExtractFileDir(FName);
if FindFirst(FIlesfolder+'\*.html', FaAnyFile, sr)=0 then
  begin
  repeat
//  Memo2.Lines.Add(FIlesfolder+'\'+sr.Name);
  Memo1.Clear;
  Memo1.Lines.LoadFromFile(FIlesfolder+'\'+sr.Name, TEncoding.UTF8);
  for I := 0 to Memo1.Lines.Count-1 do
      begin
      if Pos('<h1 class="heading_title">',Memo1.Lines[i])>0
        then
          begin
          HeadingTitle:=CopyBySample(Memo1.Lines[i], '<span>','</span>');
          if (Pos(',',HeadingTitle)>0) and (Pos('�.', HeadingTitle)>0) then
            begin
            Litraz:=Trim(Copy(HeadingTitle,1+Pos(',',HeadingTitle), length(HeadingTitle)));
            HeadingTitle:=Trim(Copy(HeadingTitle,1, -1+Pos(',',HeadingTitle)));
            HeadingTitle:=ReplaceCapitals(HeadingTitle);
            SaveIt(HeadingTitle,true, true);
            //Litraz:=WideStringReplace(Litraz,'"', '',[rfReplaceAll]);
            SaveIt(Litraz,false, true);
            end
            else
              begin
              SaveIt(HeadingTitle,true, true);
              SaveIt('',false, true);
              end;
          end;
      if Pos('<a itemprop="brand" content=',Memo1.Lines[i])>0
        then
          begin
          Brand:=CopyBySample(Memo1.Lines[i], 'content="','" href=');
          SaveIt(Brand, false, true);
          end;
      if Pos('<span>������:</span>',Memo1.Lines[i])>0
        then
          begin
          Model:=Trim(CopyBySample(Memo1.Lines[i], '</span>','<br />'));
          SaveIt(Model, false, true);
          end;
      if Pos('<div class="image">',Memo1.Lines[i])>0
        then
          begin
          BigImg:=Trim(CopyBySample(Memo1.Lines[i], 'image"><a href="','" title="'));
          SmallImg:=Trim(CopyBySample(Memo1.Lines[i], '<img itemprop="image" src="','" title="'));
          if (Length(BigImg)>0) and (Length(SmallImg)>0) then SaveIt(BigImg+','+SmallImg, false, true);
          if (Length(BigImg)>0) and (Length(SmallImg)=0) then SaveIt(BigImg, False, true);
          // ������ ������� �������� ��� ����
          if (Length(BigImg)>0) then
            begin
            ShortImg:=WideStringReplace(BigImg, 'https://', '',[rfReplaceAll]);
            ShortImg:=WideStringReplace(BigImg, 'http://', '',[rfReplaceAll]);
            ShortImg:=WideStringReplace(ShortImg,'automaslo.com', 'C:\',[rfReplaceAll]);
            ShortImg:=WideStringReplace(ShortImg,'/', '\',[rfReplaceAll]);
            SaveIt(ExtractFileName(ShortImg), false, true);
            end
            else SaveIt('', false, true);
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
          Descr:='';
          for j := 0 to Desc_Len-1 do
            if not (Description[j]='') then Descr:=Descr+Description[j];
          Descr:=WideStringReplace(Descr, chr(13)+chr(10), '',[rfReplaceAll]);
          Descr:=WideStringReplace(Descr, chr(9), ' ',[rfReplaceAll]);
          SaveIt(Descr, false, false);
          end;
      //Ifs finished here
      //Title, Brand, Model, Img1+ Img2 ����� �������, Description
      end;
  Memo2.Lines.Add(OutputStr);
  until Findnext(sr)<>0;
  FindClose(sr);
  end;
end;

procedure TFormAutoMaslo.BitBtn3Click(Sender: TObject);
begin
if not SaveDialog1.Execute then exit;
Memo2.Lines.SaveToFile(SaveDialog1.FileName, TEncoding.ANSI);
end;

function TFormAutoMaslo.CopyBySample(SearchStr, SampleBegin, SampleEnd: string): string;
var Pos1, Pos2:integer;
begin
Pos1:=Pos(SampleBegin, SearchStr);
Pos2:=Pos(SampleEnd, SearchStr, Pos1);
if (Pos1>0) and (Pos2>0)
  then Result:=Copy(SearchStr,Pos1+length(SampleBegin), Pos2-Pos1-length(SampleBegin))
  else Result:='';
end;

function TFormAutoMaslo.ReplaceCapitals(const Str: string): string;
var Brandname:string;
where, i:integer;
begin
Result:=Str;
for I := 1 to 9 do
  begin
  BrandName:=Brands[i];
  if (pos(BrandName,UpperCase(Str))=0) and (pos(BrandName,Str)>0)
    then
    begin
    Where:=pos(BrandName,UpperCase(Str));
    Result:=Copy(Str,1, where)
            +Copy(str, where+1, length(BrandName))
            +Copy(str, where+length(BrandName)+1,length(Str));
    end;
  end;
end;

procedure TFormAutoMaslo.SaveIt(const PrintStr: widestring; const FirstPosition:boolean; const isQuoted:boolean);
var Quote:string;
begin
if (isQuoted=true) then Quote:='"' else Quote:='';
if (FirstPosition = true)
  then OutputStr:=Quote+PrintStr+Quote
  else OutputStr:=OutputStr+Chr(9)+Quote+PrintStr+Quote;
end;

end.
