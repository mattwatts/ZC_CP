object ConvertLayerForm: TConvertLayerForm
  Left = 724
  Top = 249
  Width = 472
  Height = 156
  Caption = 'ConvertLayerForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 12
    Width = 77
    Height = 13
    Caption = 'Layer to convert'
  end
  object Label1: TLabel
    Left = 8
    Top = 40
    Width = 77
    Height = 13
    Caption = 'Output file name'
  end
  object ComboLayer: TComboBox
    Left = 96
    Top = 8
    Width = 265
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object EditOutput: TEdit
    Left = 96
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object btnBrowse: TButton
    Left = 224
    Top = 38
    Width = 75
    Height = 25
    Caption = 'btnBrowse'
    TabOrder = 2
    OnClick = btnBrowseClick
  end
  object BitBtnOk: TBitBtn
    Left = 24
    Top = 80
    Width = 75
    Height = 25
    TabOrder = 3
    OnClick = BitBtnOkClick
    Kind = bkOK
  end
  object BitBtnCancel: TBitBtn
    Left = 224
    Top = 80
    Width = 75
    Height = 25
    TabOrder = 4
    Kind = bkCancel
  end
  object SaveDialog1: TSaveDialog
    Left = 256
    Top = 48
  end
end
