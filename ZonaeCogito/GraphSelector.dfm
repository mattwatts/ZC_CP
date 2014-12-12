object GraphSelectorForm: TGraphSelectorForm
  Left = 1222
  Top = 705
  Width = 441
  Height = 284
  Caption = 'GraphSelectorForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 43
    Height = 13
    Caption = 'Input File'
  end
  object ComboInputFile: TComboBox
    Left = 16
    Top = 32
    Width = 321
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    Text = 'ComboInputFile'
  end
  object RadioGraphType: TRadioGroup
    Left = 16
    Top = 72
    Width = 185
    Height = 105
    Caption = 'Graph Type'
    ItemIndex = 0
    Items.Strings = (
      'Line Graph'
      'Bar Graph Missing Values'
      'Bar Graph Report Configurations'
      'Bar Graph Summary File')
    TabOrder = 1
  end
  object BitBtnOk: TBitBtn
    Left = 32
    Top = 208
    Width = 75
    Height = 25
    TabOrder = 2
    OnClick = BitBtnOkClick
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 328
    Top = 208
    Width = 75
    Height = 25
    TabOrder = 3
    Kind = bkCancel
  end
  object btnBrowse: TButton
    Left = 344
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 4
    OnClick = btnBrowseClick
  end
  object OpenDialog1: TOpenDialog
    Left = 392
    Top = 8
  end
end
