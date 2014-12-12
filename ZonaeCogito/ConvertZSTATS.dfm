object ConvertZSTATSForm: TConvertZSTATSForm
  Left = 1222
  Top = 203
  Width = 531
  Height = 229
  Caption = 'Convert ZSTATS tables'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 16
    Width = 180
    Height = 13
    Caption = 'Folder containing files to be converted'
  end
  object EditInputPath: TEdit
    Left = 24
    Top = 32
    Width = 393
    Height = 21
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 432
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object BitBtn1: TBitBtn
    Left = 16
    Top = 160
    Width = 105
    Height = 25
    Caption = 'Convert'
    TabOrder = 2
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 432
    Top = 160
    Width = 75
    Height = 25
    TabOrder = 3
    Kind = bkCancel
  end
  object RadioConvertField: TRadioGroup
    Left = 24
    Top = 64
    Width = 105
    Height = 65
    Caption = 'Field to convert'
    ItemIndex = 0
    Items.Strings = (
      'SUM'
      'MEAN')
    TabOrder = 4
  end
  object Table1: TTable
    Left = 440
    Top = 64
  end
  object Query1: TQuery
    Left = 472
    Top = 64
  end
end
