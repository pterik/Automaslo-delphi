unit UnitAutomaslo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, SQLiteTable3,
  Vcl.ComCtrls;

const
FileSeparator = Chr(9);

Brands : array [1..9] of WideString = ('AGIP','AGRINOL','�������', 'ARAL','BP','CASTROL','ELF','FUCHS TITAN','HONDA');

Header_Size = 70;
Export_Header : array [1..Header_size] of WideString = ('���������','�����','��������� �����','����','���� �������',
'�����','�����','�������������','�����','�������',
'������ ����','�������','�����','��������� ��������','�������� �����',
'�������� ��������','���������','��������','�����������','�������������',
'�������','��� �����','��� ���������','SAE (��������)','����������',
'ACEA','API','ILSAC','DEXTRON','JASO',
'ISO','CCMC','CIK-FIA','NMMA','����� ��������',
'��� �������','�������','������','������ H1 (mm)','������ H2 (mm)',
'������� ������� OD1 (mm)','������� ������� OD2 (mm)','������� ���������� ID1 (mm)','������� ���������� ID2 (mm)','������ (?)',
'������ ������ (?)','�����. ������� ��������� OD2 (mm)','�����. ������� ��������� ID2 (mm)','��� �������','��������/������',
'��� �����','���-�� ���������','������� (mm) ','������� ����� (mm)','����� L1 (mm)',
'����� L2 (mm)','������ W1 (mm)','������ W2 (mm)','������� (��)','������ (mm)',
'��� ���������','������ ����������','������� ��������� (mm)','�������� ������� (mm)','��������� ������� (mm)',
'�������� ������� (?)','��������� ������� (?)','�������� (��)','��������','����������');


Row_size=11;
My_Rows :array [1..Row_size] of WideString = ('���������','�����','�����','�������', '�������� ��������',
                  '���������','��������','�����������','�������������','��� �����','SAE (��������)');
type ExportRows=record
Visible:char;
Category, Item, variant, Short_descr, Full_descr, images, Vendor, Model, Oil_type, SAE:WideString;
end;

// Parsed_Export:array
{
   ���������   Category
   �����       Item
   �����       Visible
   �������     variant
   ���������   Short_description
   ��������    Full_description
   �����������  images
   �������������  Vendor
   ������         Model   -- �� ��������������
   ��� �����      Oil_type
   SAE (��������)  SAE
}

type
  TFormAutoMaslo = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    MemoHtml: TMemo;
    MemoCode: TMemo;
    BitBtn3: TBitBtn;
    SaveDialog1: TSaveDialog;
    PB: TProgressBar;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function ReplaceCapitals(const Str:WideString):WideString;
  public
    OutputStr:widestring;
    //ExportArray:array of ExportRows;
    //ExportArray_Size:integer;
    function CopyBySample(SearchStr, SampleBegin, SampleEnd:WideString):Widestring;
    procedure SaveIt(var Str: widestring; const FirstPosition:boolean; const isQuoted:boolean);
    //procedure AddRowToArray(NewRow:ExportRows);
    procedure InitRow(Row:ExportRows);
  end;

var
  FormAutoMaslo: TFormAutoMaslo;

implementation

{$R *.dfm}

uses System.WideStrUtils;

{
procedure TFormAutoMaslo.AddRowToArray(NewRow: ExportRows);
begin
inc(ExportArray_Size);
SetLength(ExportArray,ExportArray_Size);
ExportArray[ExportArray_Size].Visible:=NewRow.Visible;
ExportArray[ExportArray_Size].Category:=NewRow.Category;
ExportArray[ExportArray_Size].Item:=NewRow.Item;
ExportArray[ExportArray_Size].Variant:=NewRow.Variant;
ExportArray[ExportArray_Size].Short_descr:=NewRow.Short_descr;
ExportArray[ExportArray_Size].Full_descr:=NewRow.Full_descr;
ExportArray[ExportArray_Size].images:=NewRow.images;
ExportArray[ExportArray_Size].Vendor:=NewRow.Vendor;
ExportArray[ExportArray_Size].Model:=NewRow.Model;
ExportArray[ExportArray_Size].Oil_type:=NewRow.Oil_type;
ExportArray[ExportArray_Size].SAE:=NewRow.SAE;
end;
}

procedure TFormAutoMaslo.InitRow(Row: ExportRows);
begin
with Row do
  begin
  Visible:='0';
  Category:='';
  Item:='';
  variant:='';
  Short_descr:='';
  Full_descr:='';
  images:='';
  Vendor:='';
  Model:='';
  Oil_type:='';
  SAE:='';
  end;
end;

procedure TFormAutoMaslo.BitBtn2Click(Sender: TObject);
var FName, FilesDir:WideString;
ParsedRow:ExportRows;
//FileStream:TFileStream;
//S:TStringStream;
i,j, offset, Desc_begin, Desc_End, Desc_Len:integer;
ExportedFile, DirName:Widestring;
BigImg, SmallImg, ShortImg:WideString;
Description:array of WideString;
Descr:wideString;
sr:TSearchRec;
begin
if not OpenDialog1.Execute then exit;
//SetLength(ExportArray,0);
BitBtn3.Enabled:=true;
PB.Position:=Pb.Min;
MemoHtml.Clear;
MemoCode.Clear;
FName:=OpenDialog1.FileName;
FilesDir:=ExtractFileDir(FName);
PB.StepIt;
if FindFirst(FilesDir+'\*.html', FaAnyFile, sr)=0 then
  begin
  OutputStr:=Export_Header[1];
  for I := 2 to Header_Size do OutputStr:=OutputStr+FileSeparator+Export_Header[i];
  MemoCode.Lines.Add(OutputStr);
  repeat
  MemoHtml.Clear;
  MemoHtml.Lines.LoadFromFile(FilesDir+'\'+sr.Name, TEncoding.UTF8);
  for I := 0 to MemoHtml.Lines.Count-1 do
      begin
      InitRow(ParsedRow);
      if Pos('<h1 class="heading_title">',MemoHtml.Lines[i])>0
        then
          begin
          ParsedRow.Item:=CopyBySample(MemoHtml.Lines[i], '<span>','</span>');
          if (Pos(WideString(','),ParsedRow.Item)>0) and (Pos(WideString('�.'),ParsedRow.Item)>0) then
            begin
            ParsedRow.Variant:=Trim(Copy(ParsedRow.Item,1+Pos(',',ParsedRow.Item), length(ParsedRow.Item)));
            ParsedRow.Item:=Trim(Copy(ParsedRow.Item,1, -1+Pos(',',ParsedRow.Item)));
            ParsedRow.Item:=ReplaceCapitals(ParsedRow.Item);
            SaveIt(ParsedRow.Item,true, true);
            ParsedRow.Variant:='����� '+WideStringReplace(ParsedRow.Variant,',', '',[rfReplaceAll]);
            SaveIt(ParsedRow.Variant,false, true);
            end
            else
              begin
              SaveIt(ParsedRow.Item,true, true);
              ParsedRow.Variant:='';
              SaveIt(ParsedRow.Variant,false,true);
              end;
          end;
      if Pos('<a itemprop="brand" content=',MemoHtml.Lines[i])>0
        then
          begin
          ParsedRow.Vendor:=CopyBySample(MemoHtml.Lines[i], 'content="','" href=');
          SaveIt(ParsedRow.Vendor, false, true);
          end;
      if Pos('<span>������:</span>',MemoHtml.Lines[i])>0
        then
          begin
          ParsedRow.Model:=Trim(CopyBySample(MemoHtml.Lines[i], '</span>','<br />'));
          SaveIt(ParsedRow.Model, false, true);
          end;
      if Pos('<div class="image">',MemoHtml.Lines[i])>0
        then
          begin
          BigImg:=Trim(CopyBySample(MemoHtml.Lines[i], 'image"><a href="','" title="'));
          SmallImg:=Trim(CopyBySample(MemoHtml.Lines[i], '<img itemprop="image" src="','" title="'));
          if (Length(BigImg)>0) and (Length(SmallImg)>0) then
            begin
            ParsedRow.images:=BigImg+','+SmallImg;
            end;
          if (Length(BigImg)>0) and (Length(SmallImg)=0) then
            begin
            ParsedRow.images:=BigImg;
            end;
          // ������ ������� �������� ��� ����
          if (Length(BigImg)>0) then
            begin
            ShortImg:=WideStringReplace(ParsedRow.images, 'https://', '',[rfReplaceAll]);
            ParsedRow.images:=WideStringReplace(ParsedRow.images, 'http://', '',[rfReplaceAll]);
            ParsedRow.images:=WideStringReplace(ParsedRow.images,'automaslo.com', 'C:\',[rfReplaceAll]);
            ParsedRow.images:=WideStringReplace(ParsedRow.images,'/', '\',[rfReplaceAll]);
            //ParsedRow.images:=ExtractFileName(ShortImg);
            end
            else ParsedRow.images:='';
          SaveIt(ParsedRow.images, false, true);
          end;
      if Pos('itemprop="desctiption">',MemoHtml.Lines[i])>0
        then
          begin
          Desc_Begin:=0;
          Desc_End:=0;
          for j:=1 to 50 do
            begin
            if Pos('<div class="left">',MemoHtml.Lines[i+j])>0 then Desc_Begin:=j;
            if Pos('<ul class="product-benefit">',MemoHtml.Lines[i+j])>0 then begin Desc_End:=j; break; end;
            end;
          SetLength(Description,0);
          Desc_len:=0;
          if (Desc_End>Desc_Begin)  and not (Desc_begin+Desc_End=0) then
            begin
            Desc_Len:=Desc_End-Desc_Begin;
            SetLength(Description,Desc_Len);
            for j := 0 to Desc_Len-1 do
              begin
              Description[j]:=Trim(MemoHtml.Lines[i+Desc_Begin+j]);
              end;
            end;
          //MemoParsed.Lines.Add('Description="'+IntToStr(Desc_Begin)+'!'+IntToStr(Desc_End));
          for j := 0 to Desc_Len-1 do
            if (Pos(WideString('<div'),Description[j])>0) or (Pos(WideString('</div>'), Description[j])>0) then Description[j]:='';
          Descr:='';
          for j := 0 to Desc_Len-1 do
            if not (Description[j]='') then Descr:=Descr+Description[j];
          Descr:=WideStringReplace(Descr, chr(13)+chr(10), '',[rfReplaceAll]);
          ParsedRow.Full_descr:=WideStringReplace(Descr, chr(9), ' ',[rfReplaceAll]);
          SaveIt(ParsedRow.Full_descr, false, false);
          // Todo: ��������� �� ���� �������� - ��� ��������� ��� HTML, ������������� ������ �� ��������� ���
          end;
      end;
  OutputStr:='';
  with ParsedRow do
    begin
    OutputStr:=OutputStr+ParsedRow.Full_descr;
    OutputStr:=OutputStr+ParsedRow.Visible;
    OutputStr:=OutputStr+ParsedRow.Category;
    OutputStr:=OutputStr+ParsedRow.Item;
    OutputStr:=OutputStr+ParsedRow.variant;
    OutputStr:=OutputStr+ParsedRow.Short_descr;
    OutputStr:=OutputStr+ParsedRow.Full_descr;
    OutputStr:=OutputStr+ParsedRow.images;
    OutputStr:=OutputStr+ParsedRow.Vendor;
    OutputStr:=OutputStr+ParsedRow.Model;
    OutputStr:=OutputStr+ParsedRow.Oil_type;
    OutputStr:=OutputStr+ParsedRow.SAE;
    end;
  MemoCode.Lines.Add(OutputStr);
  PB.StepIt;
  until Findnext(sr)<>0;
  FindClose(sr);
  end;
PB.Position:=PB.Max;
//DirName:=FilesDir;
//while Pos('\',DirName)>0 do
//  begin
//  DirName:=Copy(DirName,Pos('\',DirName)+1, length(DirName));
//  MemoHtml.Lines.Add(DirName);
//  end;
//if length(DirName)=0 then DirName:='empty';
//ExportedFile:=FilesDir+'\'+DirName+'.csv';
//MemoHtml.Lines.Add(ExportedFile);
//try
//if FileExists(ExportedFile) then DeleteFile(ExportedFile);
//  except on E: Exception do
//  begin
//  ShowMessage('���� ������� � ������ ���������, �� ���� ������� - '+ExportedFile);
//  exit;
//  end;
//end;
//MemoCode.Lines.SaveToFile(ExportedFile, TEncoding.ANSI);
end;

procedure TFormAutoMaslo.BitBtn3Click(Sender: TObject);
begin
if not SaveDialog1.Execute then exit;
MemoCode.Lines.SaveToFile(SaveDialog1.FileName, TEncoding.ANSI);
end;

function TFormAutoMaslo.CopyBySample(SearchStr, SampleBegin, SampleEnd: WideString): WideString;
var Pos1, Pos2:integer;
begin
Pos1:=Pos(SampleBegin, SearchStr);
Pos2:=Pos(SampleEnd, SearchStr, Pos1);
if (Pos1>0) and (Pos2>0)
  then Result:=Copy(SearchStr,Pos1+length(SampleBegin), Pos2-Pos1-length(SampleBegin))
  else Result:='';
end;

procedure TFormAutoMaslo.FormCreate(Sender: TObject);
begin
BitBtn3.Enabled:=false;
end;

function TFormAutoMaslo.ReplaceCapitals(const Str: Widestring): Widestring;
var Brandname:WideString;
where, i:integer;
begin
Result:=Str;
for I := 1 to 9 do
  begin
  BrandName:=Brands[i];
  if  (pos(BrandName,WideString(UpperCase(Str)))=0)
  and (pos(BrandName,WideString(Str))>0)
    then
    begin
    Where:=pos(BrandName,WideString(UpperCase(Str)));
    Result:=Copy(Str,1, where)
            +Copy(str, where+1, length(BrandName))
            +Copy(str, where+length(BrandName)+1,length(Str));
    end;
  end;
end;

procedure TFormAutoMaslo.SaveIt(var Str: widestring; const FirstPosition:boolean; const isQuoted:boolean);
var Quote:WideString;
begin
if (isQuoted=true) then Quote:='"' else Quote:='';
if (FirstPosition = true)
  then Str:=Quote+WideStringReplace(Str, FileSeparator, ' ',[rfReplaceAll])+Quote
  else Str:=OutputStr+FileSeparator+Quote+WideStringReplace(Str, FileSeparator, ' ',[rfReplaceAll])+Quote;
end;

end.
