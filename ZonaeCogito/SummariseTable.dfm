object SummariseTableForm: TSummariseTableForm
  Left = 1326
  Top = 200
  Width = 265
  Height = 149
  Caption = 'Summarise Table'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 86
    Height = 13
    Caption = 'Field to summarise'
  end
  object StringGrid1: TStringGrid
    Left = 120
    Top = 16
    Width = 121
    Height = 49
    ColCount = 2
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 3
    Visible = False
  end
  object ComboField: TComboBox
    Left = 16
    Top = 32
    Width = 225
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 16
    Top = 80
    Width = 75
    Height = 25
    TabOrder = 1
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 168
    Top = 80
    Width = 75
    Height = 25
    TabOrder = 2
    Kind = bkCancel
  end
end
