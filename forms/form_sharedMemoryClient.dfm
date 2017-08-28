object SharedMemoryClientForm: TSharedMemoryClientForm
  Left = 696
  Top = 654
  Width = 357
  Height = 308
  Caption = 'Shared memory client'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object TestLabel: TLabel
    Left = 8
    Top = 40
    Width = 20
    Height = 13
    Caption = 'File:'
  end
  object Label1: TLabel
    Left = 8
    Top = 64
    Width = 107
    Height = 13
    Caption = 'File transfer progress:'
  end
  object Label2: TLabel
    Left = 8
    Top = 104
    Width = 21
    Height = 13
    Caption = 'Log:'
  end
  object buttonSelectFile: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Select file'
    TabOrder = 0
    OnClick = buttonSelectFileClick
  end
  object progressBarFileTransfer: TProgressBar
    Left = 8
    Top = 80
    Width = 321
    Height = 17
    TabOrder = 1
  end
  object memoLog: TMemo
    Left = 8
    Top = 120
    Width = 321
    Height = 129
    Lines.Strings = (
      'memoLog')
    TabOrder = 2
  end
  object statusBar2: TStatusBar
    Left = 0
    Top = 250
    Width = 341
    Height = 19
    Panels = <>
  end
  object buttonTransferFile: TButton
    Left = 88
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Transfer'
    Enabled = False
    TabOrder = 4
    OnClick = buttonTransferFileClick
  end
  object dlgOpen: TOpenDialog
    Left = 272
    Top = 8
  end
end
