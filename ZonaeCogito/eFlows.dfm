object eFlowsForm: TeFlowsForm
  Tag = 7
  Left = 370
  Top = 132
  Width = 789
  Height = 537
  Caption = 'eFlows'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxeFlowSpreadsheetOptions: TGroupBox
    Left = 0
    Top = 0
    Width = 781
    Height = 65
    Align = alTop
    Caption = 'eFlows Spreadsheet'
    TabOrder = 0
    object EditeFlowSpreadsheetPathName: TEdit
      Left = 24
      Top = 24
      Width = 497
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object ButtonUpdate: TButton
      Left = 584
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Run'
      Enabled = False
      TabOrder = 1
      OnClick = ButtonUpdateClick
    end
  end
  object GroupBoxDebuggingControls: TGroupBox
    Left = 0
    Top = 65
    Width = 781
    Height = 80
    Align = alTop
    Caption = 'Debugging Controls'
    TabOrder = 1
    object btnLaunch: TButton
      Left = 8
      Top = 16
      Width = 75
      Height = 25
      Caption = 'launch'
      TabOrder = 0
      OnClick = btnLaunchClick
    end
    object CheckLaunchVisible: TCheckBox
      Left = 88
      Top = 22
      Width = 97
      Height = 17
      Caption = 'Launch Visible'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object btnclose: TButton
      Left = 8
      Top = 48
      Width = 75
      Height = 25
      Caption = 'close'
      TabOrder = 2
    end
    object CheckSaveChanges: TCheckBox
      Left = 88
      Top = 52
      Width = 209
      Height = 17
      Caption = 'Save Changes to spreadsheet'
      TabOrder = 3
    end
    object btnSpreadsheet: TButton
      Left = 280
      Top = 16
      Width = 75
      Height = 25
      Caption = 'spreadsheet'
      TabOrder = 4
      OnClick = btnSpreadsheetClick
    end
    object btnTracker: TButton
      Left = 280
      Top = 48
      Width = 75
      Height = 25
      Caption = 'tracker'
      TabOrder = 5
    end
    object btnWrite: TButton
      Left = 360
      Top = 48
      Width = 75
      Height = 25
      Caption = 'write to cell'
      TabOrder = 6
    end
    object btnRead: TButton
      Left = 440
      Top = 48
      Width = 75
      Height = 25
      Caption = 'read from cell'
      TabOrder = 7
    end
    object btnRunAllocate: TButton
      Left = 360
      Top = 16
      Width = 75
      Height = 25
      Caption = 'run allocate'
      TabOrder = 8
      OnClick = btnRunAllocateClick
    end
  end
  object PanelEditParameter: TPanel
    Left = 0
    Top = 145
    Width = 781
    Height = 72
    Align = alTop
    TabOrder = 2
    object Label1: TLabel
      Left = 32
      Top = 12
      Width = 116
      Height = 13
      Caption = 'eFlow Parameter To Edit'
    end
    object LabelEditValue: TLabel
      Left = 368
      Top = 12
      Width = 48
      Height = 13
      Caption = 'Edit Value'
    end
    object LabelDescriptive: TLabel
      Left = 360
      Top = 56
      Width = 79
      Height = 13
      Caption = 'LabelDescriptive'
      Visible = False
    end
    object ComboParameterToEdit: TComboBox
      Left = 24
      Top = 32
      Width = 145
      Height = 21
      Style = csDropDownList
      DropDownCount = 11
      Enabled = False
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboParameterToEditChange
      Items.Strings = (
        'TotalVol'
        'species'
        'flow scenario'
        'planning unit selector'
        'Temp'
        'BenefitThresh'
        'Iters'
        'TotalRun')
    end
    object EditValue: TEdit
      Left = 360
      Top = 32
      Width = 121
      Height = 21
      Enabled = False
      TabOrder = 1
      OnChange = EditValueChange
    end
    object ButtonSaveParameter: TButton
      Left = 192
      Top = 22
      Width = 97
      Height = 25
      Caption = 'Save Parameter'
      Enabled = False
      TabOrder = 2
      OnClick = ButtonSaveParameterClick
    end
    object CheckEditAllRows: TCheckBox
      Left = 192
      Top = 48
      Width = 97
      Height = 17
      Caption = 'Edit All Rows'
      TabOrder = 3
      Visible = False
    end
    object PUIDGrid: TStringGrid
      Left = 504
      Top = 8
      Width = 137
      Height = 57
      ColCount = 2
      FixedCols = 0
      RowCount = 2
      FixedRows = 0
      TabOrder = 4
      Visible = False
    end
    object ComboEditValue: TComboBox
      Left = 32
      Top = 40
      Width = 145
      Height = 21
      Style = csDropDownList
      DropDownCount = 11
      ItemHeight = 13
      TabOrder = 5
      OnChange = ComboEditValueChange
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6')
    end
  end
  object ParameterGrid: TStringGrid
    Left = 0
    Top = 217
    Width = 448
    Height = 293
    Align = alClient
    ColCount = 1
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 3
    OnKeyUp = ParameterGridKeyUp
    OnMouseUp = ParameterGridMouseUp
  end
  object GroupBoxGIS: TGroupBox
    Left = 40
    Top = 289
    Width = 721
    Height = 88
    Caption = 'GIS'
    TabOrder = 4
    Visible = False
    object Label2: TLabel
      Left = 32
      Top = 12
      Width = 106
      Height = 13
      Caption = 'Planning unit shapefile'
    end
    object LabelKeyField: TLabel
      Left = 552
      Top = 12
      Width = 43
      Height = 13
      Caption = 'Key Field'
    end
    object ComboPUShapefile: TComboBox
      Left = 24
      Top = 32
      Width = 401
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object ComboKeyField: TComboBox
      Left = 552
      Top = 32
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
  end
  object ComboOutputToMap: TComboBox
    Left = 432
    Top = 58
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 5
    Visible = False
    OnChange = ComboOutputToMapChange
    Items.Strings = (
      'Summed Solution'
      'Best Solution'
      'Solution 1'
      'Solution 2'
      'Solution 3'
      'Solution 4'
      'Solution 5'
      'Solution 6'
      'Solution 7'
      'Solution 8'
      'Solution 9'
      'Solution 10')
  end
  object DescriptionGrid: TStringGrid
    Left = 448
    Top = 217
    Width = 333
    Height = 293
    Align = alRight
    TabOrder = 6
    Visible = False
  end
  object ExcelApplication1: TExcelApplication
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    AutoQuit = False
    Left = 744
    Top = 24
  end
  object ExcelWorksheet1: TExcelWorksheet
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 704
    Top = 24
  end
  object ExcelWorkbook1: TExcelWorkbook
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 672
    Top = 24
  end
  object ThemeTable: TTable
    Left = 544
    Top = 97
  end
  object ThemeQuery: TQuery
    Left = 592
    Top = 97
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 568
    Top = 24
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer2Timer
    Left = 544
    Top = 32
  end
  object Timer3: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer3Timer
    Left = 536
    Top = 16
  end
end
