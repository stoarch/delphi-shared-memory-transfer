object SharedMemoryHubForm: TSharedMemoryHubForm
  Left = 231
  Top = 966
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Shared memory hub'
  ClientHeight = 32
  ClientWidth = 229
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object SMName: TLabel
    Left = 8
    Top = 8
    Width = 79
    Height = 13
    Caption = 'Shared memory:'
  end
end
