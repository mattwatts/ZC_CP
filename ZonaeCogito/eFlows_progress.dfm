object eFlowsProgressForm: TeFlowsProgressForm
  Left = 294
  Top = 74
  Width = 465
  Height = 168
  BorderIcons = []
  Caption = 'eFlowsProgressForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LabelProgress: TLabel
    Left = 112
    Top = 32
    Width = 67
    Height = 13
    Caption = 'LabelProgress'
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 250
    OnTimer = Timer1Timer
    Left = 40
    Top = 32
  end
end
