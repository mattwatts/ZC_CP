object SaveMarxanMatrixForm: TSaveMarxanMatrixForm
  Left = 639
  Top = 122
  Width = 488
  Height = 264
  Caption = 'Save Marxan Matrix'
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
    Width = 51
    Height = 13
    Caption = 'Output File'
  end
  object Label2: TLabel
    Left = 16
    Top = 72
    Width = 208
    Height = 13
    Caption = 'Input number to add to starting feature index'
  end
  object EditOutFile: TEdit
    Left = 24
    Top = 32
    Width = 353
    Height = 21
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 384
    Top = 30
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object BitBtn1: TBitBtn
    Left = 16
    Top = 192
    Width = 75
    Height = 25
    TabOrder = 2
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 384
    Top = 192
    Width = 75
    Height = 25
    TabOrder = 3
    Kind = bkCancel
  end
  object CheckHeader: TCheckBox
    Left = 16
    Top = 120
    Width = 161
    Height = 17
    Caption = 'Include Header Row'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object EditStartingFeatureIndex: TEdit
    Left = 24
    Top = 88
    Width = 121
    Height = 21
    TabOrder = 5
    Text = '0'
  end
  object CheckConvertM2: TCheckBox
    Left = 16
    Top = 136
    Width = 193
    Height = 17
    Caption = 'Convert metres squared to hectares'
    TabOrder = 6
  end
  object RadioSaveType: TRadioGroup
    Left = 272
    Top = 72
    Width = 113
    Height = 73
    Caption = 'Row Order'
    ItemIndex = 0
    Items.Strings = (
      'Planning Units'
      'Features')
    TabOrder = 7
  end
  object CheckAppend: TCheckBox
    Left = 16
    Top = 152
    Width = 217
    Height = 17
    Caption = 'Append output to existing matrix file'
    TabOrder = 8
    OnClick = CheckAppendClick
  end
  object SaveDialog1: TSaveDialog
    Title = 'Select Output File'
    Left = 400
    Top = 40
  end
end
