unit UnitAutomaslo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, SQLiteTable3,
  Vcl.ComCtrls;

const
FileSeparator = ';';
FileQuotes='"';

Brands : array [1..9] of WideString = ('AGIP','AGRINOL','�������', 'ARAL','BP','CASTROL','ELF','FUCHS TITAN','HONDA');

Header_Size = 70;
Export_Header : array [1..Header_size] of WideString =
('���������','�����','��������� �����','����','���� �������',
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

Annotation_text_header = '<p><img src=/files/uploads/oil-cange.jpg width="179" height="130"/><img src=/files/uploads/104967w640_h640.jpg width="293" height="130" /></p><p><span style="font-family: arial, helvetica, sans-serif;"><strong><span style="font-size: small;">';
Annotation_text_footer = '</span></strong></span></p>';

//Row_size=11;
//My_Rows :array [1..Row_size] of WideString = ('���������','�����','�����','�������', '�������� ��������',
//                  '���������','��������','�����������','�������������','��� �����','SAE (��������)');
type ExportRows=record
Empty, Category, Item, variant, Description, images, ShortImage,  Vendor:widestring;
Model, Brand, Oil_type, SAE, Page_description, Annotation:WideString;
Visible:WideString;
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
   Brand - �������� ����� �� ��������������
   ��� �����      Oil_type
   SAE (��������)  SAE
}

type
  TFormAutoMaslo = class(TForm)
    BitBtnClose: TBitBtn;
    BitBtnStart: TBitBtn;
    OpenDialog1: TOpenDialog;
    MemoHtml: TMemo;
    MemoCodes: TMemo;
    BitBtnSave: TBitBtn;
    SaveDialog1: TSaveDialog;
    PB: TProgressBar;
    MemoSQL: TMemo;
    procedure BitBtnStartClick(Sender: TObject);
    procedure BitBtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function ReplaceCapitals(const Str:WideString):WideString;
    function SaveFirstTab(const Str: widestring): WideString;
    function SaveQuotedTab(const Str: widestring):WideString;
    function SavePlainTab(const Str: widestring): WideString;
  public

    //ExportArray:array of ExportRows;
    //ExportArray_Size:integer;
    function CopyBySample(const SearchStr, SampleBegin, SampleEnd:WideString):Widestring;
    //procedure AddRowToArray(NewRow:ExportRows);
    procedure InitRow(Row:ExportRows);
  end;

var
  FormAutoMaslo: TFormAutoMaslo;

implementation

{$R *.dfm}

uses System.WideStrUtils;

procedure TFormAutoMaslo.InitRow(Row: ExportRows);
begin
with Row do
  begin
  Empty:='';
  Visible:='';
  Category:='';
  Item:='';
  variant:='';
  images:='';
  ShortImage:='';
  Vendor:='';
  Model:='';
  Brand:='';
  Oil_type:='';
  SAE:='';
  Description:='';
  Annotation:='';
  Page_Description:='';
  end;
end;

procedure TFormAutoMaslo.BitBtnStartClick(Sender: TObject);
var FName, FilesDir:WideString;
ParsedRow:ExportRows;
//FileStream:TFileStream;
//S:TStringStream;
i,j, where, offset, Desc_begin, Desc_End, Desc_Len, IFrame_begin, IFrame_end:integer;
ExportedFile, DirName:Widestring;
HeadingTitle, litraz, BigImg, Annotation:WideString;
Description:array of WideString;
Descr:WideString;
OutputStr:WideString;
sr:TSearchRec;
begin
if not OpenDialog1.Execute then exit;
//SetLength(ExportArray,0);
BitBtnSave.Enabled:=true;
PB.Position:=Pb.Min;
MemoHtml.Clear;
MemoCodes.Clear;
FName:=OpenDialog1.FileName;
FilesDir:=ExtractFileDir(FName);
PB.StepIt;
if FindFirst(FilesDir+'\*.html', FaAnyFile, sr)=0 then
  begin
  OutputStr:=Export_Header[1];
  for I := 2 to Header_Size do OutputStr:=OutputStr+FileSeparator+Export_Header[i];
  MemoCodes.Lines.Add(OutputStr);
  repeat
  OutputStr:='';
  InitRow(ParsedRow);
  MemoHtml.Clear;
  MemoHtml.Lines.LoadFromFile(FilesDir+'\'+sr.Name, TEncoding.UTF8);
  HeadingTitle:='';
  Litraz:='';
  Annotation:='';
  for I := 0 to MemoHtml.Lines.Count-1 do
      begin
      if Pos('<h1 class="heading_title">',MemoHtml.Lines[i])>0
        then
          begin
          HeadingTitle:=Uppercase(trim(CopyBySample(MemoHtml.Lines[i], '<span>','</span>')));
          if (Pos(',',HeadingTitle)>0) or (LastDelimiter('�',HeadingTitle)>length(HeadingTitle)-2) then
          // ��������
          // 'title 4�'
          // 'title 4�.'
          // 'title, 4�.
          // 'title,4�'
          //������� ������� - �� ��� �������� ������
          //������� ���, ���� ���� � ��� �. �� ������� �, ���� ��������� ������, ������� �������� ������������
            begin
            if (Pos(',',HeadingTitle)>0) then
              begin
              Litraz:=Trim(Copy(HeadingTitle,1+LastDelimiter(',',HeadingTitle), length(HeadingTitle)));
              HeadingTitle:=Trim(Copy(HeadingTitle,1, -1+LastDelimiter(',',HeadingTitle)));
              Litraz:='����� '+trim(WideStringReplace(litraz,'�.', '�',[rfReplaceAll]));
              end;
            if (LastDelimiter('�',HeadingTitle)>length(HeadingTitle)-2) then
              begin
              Litraz:=Trim(Copy(HeadingTitle,1+LastDelimiter(' ',HeadingTitle), length(HeadingTitle)));
              HeadingTitle:=Trim(Copy(HeadingTitle,1, -1+LastDelimiter(' ',HeadingTitle)));
              Litraz:='����� '+trim(WideStringReplace(litraz,'�.', '�',[rfReplaceAll]));
              end;
            end;//
          end;//������ heading title � litraz
      if Pos('<a itemprop="brand" content=',MemoHtml.Lines[i])>0
        then
          begin
          ParsedRow.Vendor:=Trim(CopyBySample(MemoHtml.Lines[i], 'content="','" href='));
          end;
      if Pos('<span>������:</span>',MemoHtml.Lines[i])>0
        then
          begin
          ParsedRow.Model:=Trim(CopyBySample(MemoHtml.Lines[i], '</span>','<br />'));
          end;
      if Pos('<div class="image">',MemoHtml.Lines[i])>0
        then
          begin
          BigImg:=Trim(CopyBySample(MemoHtml.Lines[i], 'image"><a href="','" title="'));
          //SmallImg:=Trim(CopyBySample(MemoHtml.Lines[i], '<img itemprop="image" src="','" title="'));
          //SmallImg:=''; //������� shortimage, �� �� �����
//          if (Length(BigImg)>0) and (Length(SmallImg)>0) then
//            begin
//            ParsedRow.images:=BigImg+','+SmallImg;
//            end;
//          if (Length(BigImg)>0) and (Length(SmallImg)=0) then
          if (Length(BigImg)>0) then
            begin
            ParsedRow.images:=BigImg;
            end;
          if (Length(ParsedRow.images)>0) then
            begin
//          https://automaslo.com/image/cache/data/products/aral/Maslo/hight_5w40_5l-800x800.JPG,https://automaslo.com/image/cache/data/products/aral/Maslo/hight_5w40_5l-350x350.JPG
//          ../image/cache/data/products/aral/Maslo/hight_5w40_5l-800x800.JPG,../image/cache/data/products/aral/Maslo/hight_5w40_5l-350x350.JPG
//            ShortImg:=WideStringReplace(ParsedRow.images, 'https://', '',[rfReplaceAll]);
            ParsedRow.images:=WideStringReplace(ParsedRow.images, 'https://automaslo.com/image/cache/data/', 'http://petrik.tk/files/',[rfReplaceAll]);
            ParsedRow.images:=WideStringReplace(ParsedRow.images, '../image/cache/data/', 'http://petrik.tk/files/',[rfReplaceAll]);
//            ParsedRow.images:=WideStringReplace(ParsedRow.images, '../image/cache/data/', 'petrik.tk/',[rfReplaceAll]);
//            ParsedRow.images:=WideStringReplace(ParsedRow.images,'automaslo.com', 'petrik.tk',[rfReplaceAll]);
            //ParsedRow.images:=trim(WideStringReplace(ParsedRow.images,'/', '\',[rfReplaceAll]));
            //ParsedRow.images:=ExtractFileName(ShortImg);
            end;
          end;
      if Pos('itemprop="desctiption">',MemoHtml.Lines[i])>0
        then
          begin
          Desc_Begin:=0;
          Desc_End:=0;
          for j:=0 to 50 do
            begin
            if Pos('<div class="left">',MemoHtml.Lines[i+j])>0 then Desc_Begin:=j;
            if Pos('<ul class="product-benefit">',MemoHtml.Lines[i+j])>0 then begin Desc_End:=j; break; end;
            end;
          SetLength(Description,0);
          Desc_len:=0;
          if (Desc_End>Desc_Begin) and not (Desc_begin+Desc_End=0) then
            begin
            Desc_Len:=Desc_End-Desc_Begin+1;
            SetLength(Description,Desc_Len);
            for j := 0 to Desc_Len-1 do
              begin
              Description[j]:=Trim(MemoHtml.Lines[i+Desc_Begin+j]);
              end;
            end;

          Annotation:=Trim(MemoHtml.Lines[i+Desc_Begin+0])+Trim(MemoHtml.Lines[i+Desc_Begin+1]);
          Annotation:=WideStringReplace(Annotation, '&amp;nbsp', '',[rfReplaceAll]);
          Annotation:=WideStringReplace(Annotation, '&nbsp;', '',[rfReplaceAll]);
          Annotation:=WideStringReplace(Annotation, '&amp;', '',[rfReplaceAll]);
          Annotation:=WideStringReplace(Annotation, '&ndash;', '',[rfReplaceAll]);
          //MemoParsed.Lines.Add('Description="'+IntToStr(Desc_Begin)+'!'+IntToStr(Desc_End));
//          for j := 0 to Desc_Len-1 do
//            if (Pos(WideString('<div'),Description[j])>0) or (Pos(WideString('</div>'), Description[j])>0) then Description[j]:='';
          for j := 0 to Desc_Len-1 do
            if (Pos(WideString('</div>'), Description[j])>0) then Description[j]:='';
          Descr:='';
          for j := 0 to Desc_Len-1 do
            if not (Description[j]='') then Descr:=Descr+Description[j];
          Descr:=WideStringReplace(Descr, chr(13)+chr(10), '',[rfReplaceAll]);
          Descr:=WideStringReplace(Descr, '&nbsp', ' ',[rfReplaceAll]);
          if (Pos(WideString('<iframe'),Descr)>0) then IFrame_begin:=Pos(WideString('<iframe'),Descr) else IFrame_begin:=0;
          if (Pos(WideString('</iframe>'),Descr)>0) then IFrame_end:=Pos(WideString('</iframe>'),Descr) else IFrame_end:=0;
          if (IFrame_begin>0) and (IFrame_end>0) and (IFrame_begin<IFrame_end)
            then
            begin
            Descr:=Copy(Descr, 1, IFrame_begin-1)+Copy(Descr, IFrame_end+length('</iframe>'), Length(Descr));
            end;

          ParsedRow.Description:=trim(WideStringReplace(Descr, chr(9), ' ',[rfReplaceAll]));
          end;  // Pos('itemprop="desctiption">',MemoHtml.Lines[i])>0
//      ParsedRow.Category:='���� �����/��������/��������, ���� �����/��������/�������������';
      ParsedRow.Category:='';
      ParsedRow.Annotation:=Annotation_text_header+Annotation+Annotation_text_footer;
      ParsedRow.Page_Description:='';
      ParsedRow.Item:=Uppercase(WideStringReplace(HeadingTitle, '�', 'C',[rfReplaceAll]));
      ParsedRow.Variant:=LowerCase(WideStringReplace(litraz, '.', '',[rfReplaceAll]));
      ParsedRow.Visible:='1';
      end;   //MemoHtml.Lines.Count-1
  OutputStr:='';
  with ParsedRow do
    begin
    OutputStr:=OutputStr+SaveFirstTab(ParsedRow.Category); // 1 ���������
    OutputStr:=OutputStr+SaveQuotedTab(ParsedRow.Item);     // 2 �����
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);    // 3 ��������� �����
    OutputStr:=OutputStr+SavePlainTab('0.01');    // 4 ����
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);   // 5 ���� �������
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);   // 6 ����� - ������ �� ��������
    OutputStr:=OutputStr+SaveQuotedTab(ParsedRow.Visible);  // 7 ������� - �������� �� �����
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);   // 8 �������������  - �������� ������
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);    // 9 ����� - ��������� ����
    OutputStr:=OutputStr+SaveQuotedTab(ParsedRow.variant);  // 10 �������, ������ - ����� 1�
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);   // 11 ������ ����
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);    // 12 ������� - �� �����������, �������� ����������
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);    // 13 �����  - �����
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);;    // 14 ��������� �������� = �����, ����������� �� �����
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);    // 15 �������� �����
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Page_description);    // 16 �������� �������� - ������ ����������� �� ��������, ������ ���������
    OutputStr:=OutputStr+SaveQuotedTab(ParsedRow.Annotation);       // 17 ���������, ������� �������� - HTML, �������� ���� 2 ��������
    OutputStr:=OutputStr+SaveQuotedTab(ParsedRow.Description); // 18 ��������
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.images);   // 19 �����������
    OutputStr:=OutputStr+SavePlainTab(Uppercase(ParsedRow.Vendor));   // 20 �������������
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);    // 21 �������
    OutputStr:=OutputStr+SaveQuotedTab(ParsedRow.Oil_type);    // 22 ��� �����
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);    // 23 ��� ���������
    OutputStr:=OutputStr+SaveQuotedTab(ParsedRow.SAE);      // 24 SAE (��������)
    OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);    // 25 ����������
    for I := 26 to Header_Size do OutputStr:=OutputStr+SavePlainTab(ParsedRow.Empty);
    end;
  MemoCodes.Lines.Add(OutputStr);
  PB.StepIt;
  until Findnext(sr)<>0;
  FindClose(sr);
  end;
PB.Position:=PB.Max;
DirName:=trim(WideStringReplace(ParsedRow.Vendor,'"', '',[rfReplaceAll]));
if length(DirName)=0 then DirName:='empty';
ExportedFile:=FilesDir+'\'+DirName+'.csv';
MemoHtml.Lines.Add(ExportedFile);
try
if FileExists(ExportedFile) then DeleteFile(ExportedFile);
  except on E: Exception do
  begin
  ShowMessage('���� ������� � ������ ���������, �� ���� ������� - '+ExportedFile);
  exit;
  end;
end;
MemoCodes.Lines.SaveToFile(ExportedFile, TEncoding.Utf8);
end;

procedure TFormAutoMaslo.BitBtnSaveClick(Sender: TObject);
begin
if not SaveDialog1.Execute then exit;
MemoCodes.Lines.SaveToFile(SaveDialog1.FileName, TEncoding.ANSI);
end;

function TFormAutoMaslo.CopyBySample(const SearchStr, SampleBegin, SampleEnd: WideString): WideString;
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
BitBtnSave.Enabled:=false;
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

function TFormAutoMaslo.SavePlainTab(const Str: widestring):WideString;
begin
Result:=FileSeparator+WideStringReplace(Str, FileSeparator, ' ',[rfReplaceAll]);
end;

function TFormAutoMaslo.SaveQuotedTab(const Str: widestring):WideString;
begin
Result:=FileSeparator+FileQuotes+WideStringReplace(Str, FileSeparator, ' ',[rfReplaceAll])+FileQuotes;
end;

function TFormAutoMaslo.SaveFirstTab(const Str: widestring):WideString;
begin
Result:=FileQuotes+WideStringReplace(Str, FileSeparator, ' ',[rfReplaceAll])+FileQuotes;
end;

end.
