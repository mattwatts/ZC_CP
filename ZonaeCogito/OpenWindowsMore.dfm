object OpenMoreForm: TOpenMoreForm
  Left = 104
  Top = 1263
  Width = 800
  Height = 600
  Caption = 'Open windows'
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 792
    Height = 41
    Align = alTop
    TabOrder = 0
    object BitBtn1: TBitBtn
      Left = 40
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 0
      OnClick = BitBtn1Click
      Kind = bkOK
    end
    object BitBtn2: TBitBtn
      Left = 672
      Top = 8
      Width = 75
      Height = 25
      TabOrder = 1
      Kind = bkCancel
    end
  end
  object ListBox1: TListBox
    Left = 0
    Top = 41
    Width = 792
    Height = 532
    Align = alClient
    ItemHeight = 13
    TabOrder = 1
    OnClick = ListBox1Click
  end
end
