object Form1: TForm1
  Left = 201
  Top = 125
  Width = 761
  Height = 448
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 0
    Top = 113
    Width = 753
    Height = 308
    Align = alClient
    FixedCols = 0
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 753
    Height = 113
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 24
      Top = 16
      Width = 40
      Height = 13
      Caption = 'InputFile'
    end
    object Button2: TButton
      Left = 416
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Browse'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Edit1: TEdit
      Left = 72
      Top = 16
      Width = 321
      Height = 21
      TabOrder = 1
    end
    object Button1: TButton
      Left = 40
      Top = 72
      Width = 97
      Height = 25
      Caption = 'Display in grid'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 512
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Button3'
      TabOrder = 3
      Visible = False
      OnClick = Button3Click
    end
    object RadioValue: TRadioGroup
      Left = 160
      Top = 48
      Width = 161
      Height = 57
      Caption = 'RadioValue'
      ItemIndex = 0
      Items.Strings = (
        'value type'
        'feat irr type')
      TabOrder = 4
    end
    object Button4: TButton
      Left = 368
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Save Grid'
      TabOrder = 5
      OnClick = Button4Click
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 472
    Top = 32
  end
  object SaveDialog1: TSaveDialog
    Left = 440
    Top = 80
  end
end
