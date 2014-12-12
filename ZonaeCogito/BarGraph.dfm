object BarGraphForm: TBarGraphForm
  Left = 328
  Top = 699
  Width = 543
  Height = 521
  Caption = 'Bar Graph'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 65
    Width = 535
    Height = 429
    Align = alClient
    AutoSize = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 535
    Height = 65
    Align = alTop
    TabOrder = 0
    object LabelPageNumber: TLabel
      Left = 224
      Top = 14
      Width = 88
      Height = 13
      Caption = 'LabelPageNumber'
      Visible = False
    end
    object LabelObjectsPerPage: TLabel
      Left = 352
      Top = 14
      Width = 83
      Height = 13
      Caption = 'Objects Per Page'
      Visible = False
    end
    object Label1: TLabel
      Left = 240
      Top = 43
      Width = 33
      Height = 13
      Caption = 'Sort by'
      Visible = False
    end
    object Label2: TLabel
      Left = 208
      Top = 44
      Width = 59
      Height = 13
      Caption = 'Y Axis Scale'
      Visible = False
    end
    object LabelRunNumber: TLabel
      Left = 488
      Top = 14
      Width = 83
      Height = 13
      Caption = 'LabelRunNumber'
      Visible = False
    end
    object BitBtn1: TBitBtn
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      Kind = bkOK
    end
    object btnSave: TButton
      Left = 96
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Save to file'
      TabOrder = 1
      OnClick = btnSaveClick
    end
    object UpDown1: TUpDown
      Left = 184
      Top = 8
      Width = 33
      Height = 25
      Min = 1
      Orientation = udHorizontal
      Position = 1
      TabOrder = 2
      Visible = False
      Wrap = False
      OnClick = UpDown1Click
    end
    object UpDown2: TUpDown
      Left = 312
      Top = 8
      Width = 33
      Height = 25
      Min = 1
      Orientation = udHorizontal
      Position = 1
      TabOrder = 3
      Visible = False
      Wrap = False
      OnClick = UpDown2Click
    end
    object ComboBoxSortBy: TComboBox
      Left = 240
      Top = 40
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Text = 'Feature Index'
      Visible = False
      Items.Strings = (
        'Feature Index'
        'Target'
        'Amont Held'
        'Existing Reserve'
        'Shortfall')
    end
    object ComboBoxYAxisScale: TComboBox
      Left = 272
      Top = 40
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 5
      Text = 'Absolute Value'
      Visible = False
      Items.Strings = (
        'Absolute Value'
        'Fraction')
    end
    object CheckUseName: TCheckBox
      Left = 128
      Top = 42
      Width = 113
      Height = 17
      Caption = 'Use Feature Name'
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = CheckUseNameClick
    end
    object CheckFractions: TCheckBox
      Left = 8
      Top = 42
      Width = 105
      Height = 17
      Caption = 'Fractional Values'
      TabOrder = 7
      OnClick = CheckFractionsClick
    end
    object UpDown3: TUpDown
      Left = 448
      Top = 8
      Width = 33
      Height = 25
      Min = 1
      Orientation = udHorizontal
      Position = 1
      TabOrder = 8
      Wrap = False
      OnClick = UpDown3Click
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.bmp'
    Filter = 'Bitmap Files (*.bmp)|*.bmp'
    Title = 'Save to a bitmap file'
    Left = 144
    Top = 65528
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 136
  end
end
