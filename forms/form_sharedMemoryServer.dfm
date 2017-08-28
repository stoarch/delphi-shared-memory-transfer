object SharedMemoryServerForm: TSharedMemoryServerForm
  Left = 235
  Top = 607
  Width = 453
  Height = 361
  Caption = 'Shared memory server'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    437
    322)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 91
    Height = 13
    Caption = 'File receive status:'
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 21
    Height = 13
    Caption = 'Log:'
  end
  object progressBarFileReceive: TProgressBar
    Left = 16
    Top = 32
    Width = 409
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object memoLog: TMemo
    Left = 16
    Top = 72
    Width = 409
    Height = 225
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'memoLog')
    TabOrder = 1
  end
  object statusBar: TStatusBar
    Left = 0
    Top = 303
    Width = 437
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
end
