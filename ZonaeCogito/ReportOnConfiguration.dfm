object SummariseZonesForm: TSummariseZonesForm
  Left = 165
  Top = 1229
  Width = 553
  Height = 516
  Caption = 'Summarise Zones'
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
  object Label7: TLabel
    Left = 8
    Top = 388
    Width = 48
    Height = 13
    Caption = 'Output file'
  end
  object BitBtn1: TBitBtn
    Left = 80
    Top = 448
    Width = 129
    Height = 25
    Caption = 'Report'
    TabOrder = 0
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 320
    Top = 448
    Width = 105
    Height = 25
    TabOrder = 1
    Kind = bkCancel
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 152
    Width = 529
    Height = 129
    Caption = 'Feature file'
    TabOrder = 2
    object Label4: TLabel
      Left = 16
      Top = 24
      Width = 122
      Height = 13
      Caption = 'Values file (eg. puvsp.dat)'
    end
    object Label6: TLabel
      Left = 16
      Top = 72
      Width = 44
      Height = 13
      Caption = 'Name file'
    end
    object EditValuesFile: TEdit
      Left = 24
      Top = 40
      Width = 393
      Height = 21
      TabOrder = 0
    end
    object Button3: TButton
      Left = 430
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 1
      OnClick = Button3Click
    end
    object EditNameFile: TEdit
      Left = 24
      Top = 88
      Width = 393
      Height = 21
      TabOrder = 2
    end
    object Button4: TButton
      Left = 430
      Top = 88
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 3
      OnClick = Button4Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 529
    Height = 129
    Caption = 'Field To Summarise'
    TabOrder = 3
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 176
      Height = 13
      Caption = 'Select Configuration Shape file (*.dbf)'
    end
    object Label2: TLabel
      Left = 56
      Top = 72
      Width = 51
      Height = 13
      Caption = 'PUID Field'
    end
    object Label3: TLabel
      Left = 280
      Top = 72
      Width = 92
      Height = 13
      Caption = 'Field To Summarise'
    end
    object EditShapefile: TEdit
      Left = 24
      Top = 40
      Width = 393
      Height = 21
      TabOrder = 0
    end
    object ComboShapePUID: TComboBox
      Left = 56
      Top = 88
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
    object Button1: TButton
      Left = 430
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 2
      OnClick = Button1Click
    end
    object ComboReportField: TComboBox
      Left = 272
      Top = 88
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 3
    end
  end
  object Button5: TButton
    Left = 446
    Top = 400
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 4
    OnClick = Button5Click
  end
  object EditOutput: TEdit
    Left = 16
    Top = 404
    Width = 409
    Height = 21
    TabOrder = 5
  end
  object ListFieldValues: TListBox
    Left = 200
    Top = 384
    Width = 17
    Height = 17
    ItemHeight = 13
    Sorted = True
    TabOrder = 6
    Visible = False
  end
  object GridFieldValues: TStringGrid
    Left = 232
    Top = 384
    Width = 17
    Height = 17
    TabOrder = 7
    Visible = False
  end
  object GridFeatName: TStringGrid
    Left = 264
    Top = 384
    Width = 17
    Height = 17
    TabOrder = 8
    Visible = False
  end
  object RadioOutputType: TRadioGroup
    Left = 8
    Top = 296
    Width = 225
    Height = 81
    Caption = 'Output Type'
    ItemIndex = 0
    Items.Strings = (
      'Sum of Total'
      'Percentage of Total')
    TabOrder = 9
  end
  object CheckZones: TCheckBox
    Left = 272
    Top = 304
    Width = 145
    Height = 17
    Caption = 'Generate Zones File'
    TabOrder = 10
  end
  object CheckPUID: TCheckBox
    Left = 272
    Top = 328
    Width = 145
    Height = 17
    Caption = 'Generate PUID File'
    TabOrder = 11
  end
  object CheckFeat: TCheckBox
    Left = 272
    Top = 352
    Width = 169
    Height = 17
    Caption = 'Generate Feature File'
    TabOrder = 12
  end
  object OpenDBF: TOpenDialog
    Filter = 'dBase Table (*.dbf)|*.dbf'
    Title = 'Select DBF File'
    Left = 456
    Top = 56
  end
  object InputTable: TTable
    Left = 456
    Top = 80
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'Comma Delimited Ascii (*.csv)|*.csv'
    Title = 'Save Output File'
    Left = 464
    Top = 416
  end
  object OpenValues: TOpenDialog
    Title = 'Select Values File'
    Left = 432
    Top = 200
  end
  object OpenName: TOpenDialog
    Title = 'Select Name File'
    Left = 432
    Top = 248
  end
end
