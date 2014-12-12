object GISOptionsForm: TGISOptionsForm
  Left = 637
  Top = 232
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Display Options'
  ClientHeight = 399
  ClientWidth = 388
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
  object Label4: TLabel
    Left = 8
    Top = 12
    Width = 95
    Height = 13
    Caption = 'Shapefile to change'
  end
  object Transparency: TLabel
    Left = 8
    Top = 44
    Width = 93
    Height = 13
    Caption = 'Transparency Ratio'
  end
  object Label1: TLabel
    Left = 8
    Top = 88
    Width = 57
    Height = 13
    Caption = 'Transparent'
  end
  object Label2: TLabel
    Left = 336
    Top = 88
    Width = 38
    Height = 13
    Caption = 'Opaque'
  end
  object LabelTrackBarSize: TLabel
    Left = 8
    Top = 124
    Width = 91
    Height = 13
    Caption = 'Line and Point Size'
  end
  object LabelField: TLabel
    Left = 16
    Top = 232
    Width = 22
    Height = 13
    Caption = 'Field'
  end
  object LabelJustify: TLabel
    Left = 216
    Top = 232
    Width = 55
    Height = 13
    Caption = 'Justification'
  end
  object LabelFontSize: TLabel
    Left = 8
    Top = 276
    Width = 44
    Height = 13
    Caption = 'Font Size'
  end
  object ScrollBar1: TScrollBar
    Left = 8
    Top = 64
    Width = 369
    Height = 16
    PageSize = 0
    TabOrder = 0
  end
  object ComboShapefile: TComboBox
    Left = 112
    Top = 8
    Width = 265
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    OnChange = ComboShapefileChange
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 357
    Width = 75
    Height = 25
    TabOrder = 2
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object btnApply: TButton
    Left = 304
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 3
    OnClick = btnApplyClick
  end
  object TrackBarSize: TTrackBar
    Left = 8
    Top = 144
    Width = 369
    Height = 45
    Max = 20
    Min = 1
    Orientation = trHorizontal
    Frequency = 1
    Position = 1
    SelEnd = 0
    SelStart = 0
    TabOrder = 4
    TickMarks = tmBottomRight
    TickStyle = tsAuto
  end
  object CheckLabel: TCheckBox
    Left = 16
    Top = 208
    Width = 97
    Height = 17
    Caption = 'Display Label'
    TabOrder = 5
    OnClick = CheckLabelClick
  end
  object ComboLabelField: TComboBox
    Left = 16
    Top = 248
    Width = 153
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
  end
  object ComboLabelJustification: TComboBox
    Left = 216
    Top = 248
    Width = 153
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 7
    Items.Strings = (
      'Left'
      'Center'
      'Right'
      'None')
  end
  object TrackBarFontSize: TTrackBar
    Left = 8
    Top = 296
    Width = 369
    Height = 45
    Max = 30
    Min = 5
    Orientation = trHorizontal
    Frequency = 1
    Position = 8
    SelEnd = 0
    SelStart = 0
    TabOrder = 8
    TickMarks = tmBottomRight
    TickStyle = tsAuto
  end
end
