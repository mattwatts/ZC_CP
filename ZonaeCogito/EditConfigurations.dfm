object EditConfigurationsForm: TEditConfigurationsForm
  Tag = 6
  Left = 988
  Top = 158
  Width = 599
  Height = 420
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = 'Edit Planning Unit Configurations'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 437
    Top = 41
    Width = 3
    Height = 352
    Cursor = crHSplit
    Align = alRight
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 591
    Height = 41
    Align = alTop
    TabOrder = 0
    object PUConfiguration: TEdit
      Left = 280
      Top = 0
      Width = 41
      Height = 21
      TabOrder = 0
      Visible = False
    end
    object btnAdd: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'New'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object Button1: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Report'
      TabOrder = 2
      OnClick = Button1Click
    end
    object btnSendToMarxan: TButton
      Left = 168
      Top = 8
      Width = 89
      Height = 25
      Caption = 'Send to Marxan'
      TabOrder = 3
      OnClick = btnSendToMarxanClick
    end
    object Button5: TButton
      Left = 264
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Stop Editing'
      TabOrder = 4
      OnClick = Button5Click
    end
    object ListBoxConfigFieldNames: TListBox
      Left = 360
      Top = 0
      Width = 17
      Height = 17
      ItemHeight = 13
      TabOrder = 5
      Visible = False
    end
    object ListBox1: TListBox
      Left = 432
      Top = 8
      Width = 17
      Height = 17
      ItemHeight = 13
      TabOrder = 6
      Visible = False
    end
    object StatusGrid: TStringGrid
      Left = 472
      Top = 0
      Width = 41
      Height = 33
      TabOrder = 7
      Visible = False
    end
  end
  object ListBoxPUConfiguration: TListBox
    Left = 0
    Top = 41
    Width = 437
    Height = 352
    Align = alClient
    ItemHeight = 13
    TabOrder = 1
    OnKeyUp = ListBoxPUConfigurationKeyUp
    OnMouseUp = ListBoxPUConfigurationMouseUp
  end
  object Panel2: TPanel
    Left = 440
    Top = 41
    Width = 151
    Height = 352
    Align = alRight
    TabOrder = 2
    object PanelSave: TPanel
      Left = 1
      Top = 301
      Width = 149
      Height = 25
      Align = alBottom
      Caption = 'Save'
      TabOrder = 1
      OnClick = PanelSaveClick
    end
    object RadioGroupAction: TRadioGroup
      Left = 1
      Top = 1
      Width = 149
      Height = 300
      Align = alClient
      Caption = 'Assign To'
      ItemIndex = 1
      Items.Strings = (
        'Available'
        'Reserved'
        'Excluded')
      TabOrder = 0
    end
    object PanelUndo: TPanel
      Left = 1
      Top = 326
      Width = 149
      Height = 25
      Align = alBottom
      Caption = 'Undo'
      TabOrder = 2
      OnClick = PanelUndoClick
    end
  end
  object ThemeTable: TTable
    Left = 384
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 352
    Top = 24
  end
end
