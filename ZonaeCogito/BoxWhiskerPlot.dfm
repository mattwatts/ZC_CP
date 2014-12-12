object BoxWhiskerPlotForm: TBoxWhiskerPlotForm
  Left = 1341
  Top = 64
  Width = 525
  Height = 484
  Caption = 'Monthly Allocation Chart Box Whisker Plot'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 41
    Width = 517
    Height = 416
    Align = alClient
    AutoSize = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 517
    Height = 41
    Align = alTop
    TabOrder = 0
    object BitBtn1: TBitBtn
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      Kind = bkOK
    end
    object btnSave: TButton
      Left = 96
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Save to file'
      TabOrder = 1
      OnClick = btnSaveClick
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.bmp'
    Filter = 'Bitmap Files (*.bmp)|*.bmp'
    Title = 'Save to a bitmap file'
    Left = 144
    Top = 65528
  end
end
