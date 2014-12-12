object LoadProgressForm: TLoadProgressForm
  Left = 69
  Top = 549
  Width = 308
  Height = 165
  Caption = 'LoadProgressForm'
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
  object lblProgress: TLabel
    Left = 48
    Top = 16
    Width = 51
    Height = 13
    Caption = 'lblProgress'
  end
  object ProgressBar1: TProgressBar
    Left = 24
    Top = 56
    Width = 217
    Height = 16
    Min = 0
    Max = 100
    TabOrder = 0
  end
end
