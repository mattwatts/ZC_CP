object BoundaryFileMakerForm: TBoundaryFileMakerForm
  Left = 372
  Top = 163
  Width = 745
  Height = 309
  Caption = 'Generate Marxan Boundary Length File'
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
    Width = 203
    Height = 13
    Caption = 'Whice shapefile is your planning unit layer?'
  end
  object Label2: TLabel
    Left = 16
    Top = 72
    Width = 195
    Height = 13
    Caption = 'Which field in the shapefile is your PUID?'
  end
  object Label3: TLabel
    Left = 16
    Top = 168
    Width = 261
    Height = 13
    Caption = 'Where do you want to write the boundary length file to?'
  end
  object ComboPulayer: TComboBox
    Left = 16
    Top = 32
    Width = 705
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    OnChange = ComboPulayerChange
  end
  object ComboPUIDField: TComboBox
    Left = 16
    Top = 88
    Width = 705
    Height = 21
    ItemHeight = 13
    TabOrder = 1
  end
  object CheckIncludeEdges: TCheckBox
    Left = 16
    Top = 128
    Width = 329
    Height = 17
    Caption = 'Do you want to include external edges in the output file?'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object EditOutputFileName: TEdit
    Left = 16
    Top = 184
    Width = 625
    Height = 21
    TabOrder = 3
  end
  object btnBrowse: TButton
    Left = 648
    Top = 182
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 4
    OnClick = btnBrowseClick
  end
  object BitBtn1: TBitBtn
    Left = 16
    Top = 240
    Width = 185
    Height = 25
    Caption = 'Generate Boundry Length File'
    TabOrder = 5
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 648
    Top = 240
    Width = 75
    Height = 25
    TabOrder = 6
    Kind = bkCancel
  end
  object SaveBoundaryLengthFile: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'Comma Delimited Ascii (*.csv)|*.csv|All Files (*.*)|*.*'
    Title = 'Save Distance File'
    Left = 632
    Top = 192
  end
end
