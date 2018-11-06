object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 488
  ClientWidth = 896
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    896
    488)
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 800
    Top = 455
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Kind = bkClose
    NumGlyphs = 2
    TabOrder = 0
  end
  object BitBtn2: TBitBtn
    Left = 16
    Top = 455
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Start'
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
    OnClick = BitBtn2Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 880
    Height = 241
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Memo2: TMemo
    Left = 8
    Top = 264
    Width = 880
    Height = 185
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 3
    WantReturns = False
  end
  object BitBtn3: TBitBtn
    Left = 168
    Top = 455
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 4
    OnClick = BitBtn3Click
  end
  object OpenDialog1: TOpenDialog
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
