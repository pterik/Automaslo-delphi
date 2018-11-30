object FormAutoMaslo: TFormAutoMaslo
  Left = 0
  Top = 0
  Caption = #1040#1074#1090#1086#1084#1072#1089#1083#1086
  ClientHeight = 488
  ClientWidth = 896
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    896
    488)
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtnClose: TBitBtn
    Left = 800
    Top = 455
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Kind = bkClose
    NumGlyphs = 2
    TabOrder = 0
  end
  object BitBtnStart: TBitBtn
    Left = 16
    Top = 455
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Start'
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
    OnClick = BitBtnStartClick
  end
  object MemoHtml: TMemo
    Left = 8
    Top = 8
    Width = 880
    Height = 241
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object MemoCodes: TMemo
    Left = 8
    Top = 264
    Width = 880
    Height = 185
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 3
    WantReturns = False
    WordWrap = False
  end
  object BitBtnSave: TBitBtn
    Left = 104
    Top = 455
    Width = 75
    Height = 25
    Anchors = [akLeft, akTop, akBottom]
    Caption = 'Save'
    TabOrder = 4
    OnClick = BitBtnSaveClick
  end
  object PB: TProgressBar
    Left = 200
    Top = 463
    Width = 577
    Height = 17
    TabOrder = 5
  end
  object MemoSQL: TMemo
    Left = 304
    Top = 96
    Width = 513
    Height = 249
    Lines.Strings = (
      'MemoSQL')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 6
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.html'
    Filter = 'Html files|*.html|CSV files|*.csv|Text files|*.txt|Any files|*.*'
    Left = 200
    Top = 184
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.csv'
    Filter = '*.csv|*.csv'
    Options = [ofReadOnly, ofHideReadOnly, ofEnableSizing]
    Left = 256
    Top = 344
  end
end
