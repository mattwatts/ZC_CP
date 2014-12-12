object ReportConfigurationsForm: TReportConfigurationsForm
  Left = 847
  Top = 685
  Width = 321
  Height = 346
  Caption = 'Report on Planning Unit Configurations'
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
    Top = 8
    Width = 242
    Height = 13
    Caption = '1. Select Planning Unit Configurations for Reporting'
  end
  object Label3: TLabel
    Left = 16
    Top = 144
    Width = 122
    Height = 13
    Caption = '2. Select reports to create'
  end
  object ListBoxNames: TListBox
    Left = 16
    Top = 32
    Width = 281
    Height = 105
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 0
  end
  object BitBtnOk: TBitBtn
    Left = 16
    Top = 272
    Width = 75
    Height = 25
    TabOrder = 1
    OnClick = BitBtnOkClick
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 216
    Top = 272
    Width = 75
    Height = 25
    TabOrder = 2
    Kind = bkCancel
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 160
    Width = 281
    Height = 89
    TabOrder = 3
    object CheckTargetAchievement: TCheckBox
      Left = 8
      Top = 14
      Width = 137
      Height = 17
      Caption = 'target achievement'
      TabOrder = 0
      OnClick = CheckTargetAchievementClick
    end
    object CheckSummary: TCheckBox
      Left = 8
      Top = 30
      Width = 97
      Height = 17
      Caption = 'summary'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object CheckPUDetail: TCheckBox
      Left = 8
      Top = 46
      Width = 137
      Height = 17
      Caption = 'planning unit detail'
      TabOrder = 2
    end
    object CheckPUShape: TCheckBox
      Left = 8
      Top = 62
      Width = 137
      Height = 17
      Caption = 'planning unit shapfile'
      TabOrder = 3
    end
    object CheckBarGraph: TCheckBox
      Left = 136
      Top = 14
      Width = 121
      Height = 17
      Caption = 'display bar graph'
      Enabled = False
      TabOrder = 4
    end
  end
  object ListBoxFields: TListBox
    Left = 80
    Top = 56
    Width = 25
    Height = 25
    ItemHeight = 13
    TabOrder = 4
    Visible = False
  end
  object ThemeTable: TTable
    Left = 208
    Top = 64
  end
end
