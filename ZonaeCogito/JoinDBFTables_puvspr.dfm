object JoinDBFTablesForm: TJoinDBFTablesForm
  Left = 333
  Top = 125
  Width = 531
  Height = 309
  Caption = 'Join DBF Tables To Marxan PUVSPR File'
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
    Width = 160
    Height = 13
    Caption = 'Folder containing files to be joined'
  end
  object Label2: TLabel
    Left = 24
    Top = 192
    Width = 80
    Height = 13
    Caption = 'Number of zones'
    Enabled = False
  end
  object EditInputPath: TEdit
    Left = 24
    Top = 32
    Width = 393
    Height = 21
    TabOrder = 0
  end
  object RadioGroupFeatureIndexType: TRadioGroup
    Left = 24
    Top = 80
    Width = 185
    Height = 65
    Caption = 'Feature Index Type'
    ItemIndex = 0
    Items.Strings = (
      'Assign Unique Index'
      'Use Column Names From Files')
    TabOrder = 1
  end
  object BitBtn1: TBitBtn
    Left = 16
    Top = 240
    Width = 105
    Height = 25
    Caption = 'Execute Join'
    TabOrder = 2
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 432
    Top = 240
    Width = 75
    Height = 25
    TabOrder = 3
    Kind = bkCancel
  end
  object btnBrowse: TButton
    Left = 432
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 4
    OnClick = btnBrowseClick
  end
  object CheckSPORDER: TCheckBox
    Left = 256
    Top = 128
    Width = 193
    Height = 17
    Caption = 'Create sporder.dat'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object CheckPUDAT: TCheckBox
    Left = 256
    Top = 96
    Width = 97
    Height = 17
    Caption = 'Create pu.dat'
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = CheckPUDATClick
  end
  object CheckSPECDAT: TCheckBox
    Left = 256
    Top = 112
    Width = 97
    Height = 17
    Caption = 'Create spec.dat'
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = CheckSPECDATClick
  end
  object CheckConvertM2: TCheckBox
    Left = 256
    Top = 160
    Width = 209
    Height = 17
    Caption = 'Convert metres squared to hectares'
    TabOrder = 8
  end
  object CheckSummary: TCheckBox
    Left = 256
    Top = 80
    Width = 185
    Height = 17
    Caption = 'Create summary information file'
    Checked = True
    State = cbChecked
    TabOrder = 9
  end
  object CheckCPlan: TCheckBox
    Left = 256
    Top = 144
    Width = 145
    Height = 17
    Caption = 'Create C-Plan database'
    TabOrder = 10
    Visible = False
  end
  object CheckCK1: TCheckBox
    Left = 256
    Top = 184
    Width = 225
    Height = 17
    Caption = 'Retain unsorted joined file (join.csv)'
    TabOrder = 11
  end
  object CheckCreateMarZone: TCheckBox
    Left = 24
    Top = 168
    Width = 185
    Height = 17
    Caption = 'Create Marxan with Zones files'
    TabOrder = 12
    OnClick = CheckCreateMarZoneClick
  end
  object EditZoneCount: TEdit
    Left = 120
    Top = 189
    Width = 57
    Height = 21
    Enabled = False
    TabOrder = 13
    Text = '2'
  end
  object CheckSkipFirstDBFColumn: TCheckBox
    Left = 256
    Top = 224
    Width = 145
    Height = 17
    Caption = 'Skip First DBF Column'
    TabOrder = 14
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
