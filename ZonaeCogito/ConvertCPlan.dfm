object ConvertCPlanForm: TConvertCPlanForm
  Left = 739
  Top = 492
  Width = 418
  Height = 278
  Caption = 'Convert matrix to C-Plan dataset'
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
    Left = 16
    Top = 16
    Width = 43
    Height = 13
    Caption = 'Input File'
  end
  object EditInputFile: TEdit
    Left = 16
    Top = 32
    Width = 297
    Height = 21
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 320
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object BitBtn1: TBitBtn
    Left = 48
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Convert'
    TabOrder = 2
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 256
    Top = 208
    Width = 75
    Height = 25
    TabOrder = 3
    Kind = bkCancel
  end
  object RadioGroupInputFormat: TRadioGroup
    Left = 24
    Top = 72
    Width = 185
    Height = 89
    Caption = 'Input File Format'
    ItemIndex = 0
    Items.Strings = (
      'feature,planning unit,amount'
      'planning unit,feature,amount')
    TabOrder = 4
  end
  object OpenDialog1: TOpenDialog
    Left = 344
    Top = 88
  end
  object Table1: TTable
    Left = 272
    Top = 112
  end
  object Query1: TQuery
    Left = 272
    Top = 80
  end
end
