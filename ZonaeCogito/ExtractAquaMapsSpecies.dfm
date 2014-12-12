object ExtractAquaMapSpeciesForm: TExtractAquaMapSpeciesForm
  Left = 1299
  Top = 219
  Width = 453
  Height = 330
  Caption = 'Extract AquaMap Species'
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
    Top = 24
    Width = 150
    Height = 13
    Caption = 'DBF Table with species records'
  end
  object Label2: TLabel
    Left = 16
    Top = 152
    Width = 148
    Height = 13
    Caption = 'SHP File with polygon locations'
  end
  object Label3: TLabel
    Left = 32
    Top = 48
    Width = 103
    Height = 13
    Caption = 'Species Name Field 1'
  end
  object Label4: TLabel
    Left = 32
    Top = 67
    Width = 103
    Height = 13
    Caption = 'Species Name Field 2'
  end
  object Label5: TLabel
    Left = 32
    Top = 88
    Width = 102
    Height = 13
    Caption = 'C Squares Code Field'
  end
  object Label6: TLabel
    Left = 32
    Top = 108
    Width = 73
    Height = 13
    Caption = 'Probability Field'
  end
  object Label7: TLabel
    Left = 32
    Top = 176
    Width = 102
    Height = 13
    Caption = 'C Squares Code Field'
  end
  object ComboDBFSpeciesRecords: TComboBox
    Left = 176
    Top = 20
    Width = 249
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    OnChange = ComboDBFSpeciesRecordsChange
  end
  object ComboSHPPolygonLocations: TComboBox
    Left = 176
    Top = 148
    Width = 249
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    OnChange = ComboSHPPolygonLocationsChange
  end
  object BitBtn1: TBitBtn
    Left = 16
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Extract'
    TabOrder = 2
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 352
    Top = 256
    Width = 75
    Height = 25
    TabOrder = 3
    Kind = bkCancel
  end
  object ComboSpec1: TComboBox
    Left = 144
    Top = 44
    Width = 177
    Height = 21
    ItemHeight = 13
    TabOrder = 4
  end
  object ComboSpec2: TComboBox
    Left = 144
    Top = 64
    Width = 177
    Height = 21
    ItemHeight = 13
    TabOrder = 5
  end
  object ComboCCode: TComboBox
    Left = 144
    Top = 84
    Width = 177
    Height = 21
    ItemHeight = 13
    TabOrder = 7
  end
  object ComboProb: TComboBox
    Left = 144
    Top = 104
    Width = 177
    Height = 21
    ItemHeight = 13
    TabOrder = 6
  end
  object ComboSHPCCode: TComboBox
    Left = 144
    Top = 172
    Width = 177
    Height = 21
    ItemHeight = 13
    TabOrder = 8
  end
  object CheckFilterProbability: TCheckBox
    Left = 16
    Top = 216
    Width = 153
    Height = 17
    Caption = 'Filter Probability less than'
    TabOrder = 9
  end
  object EditFilterPr: TEdit
    Left = 168
    Top = 214
    Width = 121
    Height = 21
    TabOrder = 10
    Text = '0.50'
  end
  object InputTable: TTable
    Left = 384
    Top = 56
  end
end
