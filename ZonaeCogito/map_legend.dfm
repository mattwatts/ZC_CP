object MapLegendForm: TMapLegendForm
  Left = 1259
  Top = 120
  Width = 511
  Height = 411
  BorderIcons = [biSystemMenu]
  Caption = 'Select Shape Colours'
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 503
    Height = 343
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = 'Single Colour'
      object ColorGrid1: TColorGrid
        Left = 8
        Top = 8
        Width = 184
        Height = 184
        ClickEnablesColor = True
        BackgroundEnabled = False
        TabOrder = 0
        OnChange = ColorGrid1Change
        OnClick = ColorGrid1Click
      end
      object btnCustomColour: TButton
        Left = 328
        Top = 32
        Width = 91
        Height = 25
        Caption = 'Custom Colour'
        TabOrder = 1
        Visible = False
        OnClick = btnCustomColourClick
      end
      object CustomPanel1: TPanel
        Left = 272
        Top = 24
        Width = 49
        Height = 41
        TabOrder = 2
        Visible = False
        OnClick = CustomPanel1Click
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Specify Legend'
      Enabled = False
      ImageIndex = 1
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 93
        Height = 13
        Caption = 'Shape Display Field'
      end
      object Label2: TLabel
        Left = 8
        Top = 56
        Width = 94
        Height = 13
        Caption = 'Number Of Intervals'
      end
      object ComboDisplayField: TComboBox
        Left = 8
        Top = 24
        Width = 145
        Height = 21
        ItemHeight = 13
        TabOrder = 0
        Text = 'ComboDisplayField'
        OnChange = ComboDisplayFieldChange
      end
      object EditIntervalCount: TEdit
        Left = 8
        Top = 72
        Width = 121
        Height = 21
        TabOrder = 1
        Text = '10'
        OnChange = EditIntervalCountChange
      end
      object RadioLegendType: TRadioGroup
        Left = 190
        Top = 16
        Width = 185
        Height = 81
        Caption = 'Legend Type'
        ItemIndex = 0
        Items.Strings = (
          'Unique Values'
          'Equal Intervals')
        TabOrder = 2
        OnClick = RadioColourTypeClick
      end
      object ColorGrid2: TColorGrid
        Left = 0
        Top = 112
        Width = 184
        Height = 184
        ClickEnablesColor = True
        BackgroundEnabled = False
        TabOrder = 3
      end
      object StringGridValues: TDrawGrid
        Left = 184
        Top = 112
        Width = 161
        Height = 183
        ColCount = 2
        DefaultColWidth = 69
        FixedCols = 0
        RowCount = 4
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
        TabOrder = 4
        OnDrawCell = StringGridValuesDrawCell
      end
      object btnDeleteInterval: TButton
        Left = 360
        Top = 136
        Width = 113
        Height = 25
        Caption = 'Delete Interval'
        TabOrder = 5
        OnClick = btnDeleteIntervalClick
      end
      object btnAddInterval: TButton
        Left = 360
        Top = 176
        Width = 113
        Height = 25
        Caption = 'Add Interval'
        TabOrder = 6
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 343
    Width = 503
    Height = 41
    Align = alBottom
    TabOrder = 1
    object BitBtn1: TBitBtn
      Left = 8
      Top = 8
      Width = 121
      Height = 25
      Caption = 'Accept Change'
      TabOrder = 0
      OnClick = BitBtn1Click
      Kind = bkOK
    end
    object BitBtn2: TBitBtn
      Left = 376
      Top = 8
      Width = 121
      Height = 25
      Caption = 'Cancel Change'
      TabOrder = 1
      Kind = bkCancel
    end
    object ListBoxValues: TListBox
      Left = 328
      Top = 8
      Width = 25
      Height = 25
      ItemHeight = 13
      TabOrder = 2
      Visible = False
    end
  end
  object Table1: TTable
    Left = 264
    Top = 352
  end
  object ColorDialog1: TColorDialog
    Ctl3D = True
    Options = [cdFullOpen]
    Left = 296
    Top = 352
  end
end
