object ParseDelimitedFileForm: TParseDelimitedFileForm
  Left = 446
  Top = 116
  Width = 563
  Height = 322
  Caption = 'Parse Delimited File'
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
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 43
    Height = 13
    Caption = 'Input File'
  end
  object Label2: TLabel
    Left = 16
    Top = 80
    Width = 40
    Height = 13
    Caption = 'Delimiter'
  end
  object Label3: TLabel
    Left = 16
    Top = 48
    Width = 51
    Height = 13
    Caption = 'Output File'
  end
  object Label5: TLabel
    Left = 24
    Top = 232
    Width = 52
    Height = 13
    Caption = 'Field Value'
  end
  object EditIn: TEdit
    Left = 72
    Top = 8
    Width = 369
    Height = 21
    TabOrder = 0
  end
  object EditOut: TEdit
    Left = 72
    Top = 48
    Width = 369
    Height = 21
    TabOrder = 1
  end
  object btnBrowse: TButton
    Left = 448
    Top = 8
    Width = 75
    Height = 25
    Caption = '&Browse'
    TabOrder = 2
    OnClick = btnBrowseClick
  end
  object EditDelimiter: TEdit
    Left = 72
    Top = 80
    Width = 121
    Height = 21
    TabOrder = 3
    Text = ','
  end
  object EditValue: TEdit
    Left = 80
    Top = 232
    Width = 121
    Height = 21
    TabOrder = 5
  end
  object RadioType: TRadioGroup
    Left = 16
    Top = 112
    Width = 185
    Height = 105
    Caption = 'Specify which field'
    ItemIndex = 0
    Items.Strings = (
      'Field Name'
      'Field 1 based index')
    TabOrder = 6
  end
  object EditName: TEdit
    Left = 152
    Top = 136
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object SpinIndex: TSpinEdit
    Left = 152
    Top = 176
    Width = 121
    Height = 22
    MaxValue = 99999
    MinValue = 1
    TabOrder = 7
    Value = 1
  end
  object BitBtnParse: TBitBtn
    Left = 304
    Top = 256
    Width = 91
    Height = 25
    Caption = '&Parse File'
    TabOrder = 8
    OnClick = BitBtnParseClick
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 424
    Top = 256
    Width = 75
    Height = 25
    Caption = '&Cancel'
    TabOrder = 9
    OnClick = BitBtn2Click
    Kind = bkCancel
  end
  object OpenDialog1: TOpenDialog
    Left = 384
    Top = 16
  end
end
