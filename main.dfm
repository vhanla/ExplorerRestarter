object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Restart Explorer'
  ClientHeight = 240
  ClientWidth = 484
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 24
    Width = 47
    Height = 13
    Caption = 'Explorer: '
  end
  object btnStart: TButton
    Left = 120
    Top = 58
    Width = 89
    Height = 25
    Caption = 'Start Explorer'
    TabOrder = 0
    OnClick = btnStartClick
  end
  object btnKill: TButton
    Left = 32
    Top = 58
    Width = 75
    Height = 25
    Caption = 'Kill Explorer'
    TabOrder = 1
    OnClick = btnKillClick
  end
  object ListBox1: TListBox
    Left = 32
    Top = 89
    Width = 417
    Height = 143
    ItemHeight = 13
    TabOrder = 2
  end
  object Button1: TButton
    Left = 215
    Top = 58
    Width = 82
    Height = 25
    Caption = 'List Explorers'
    TabOrder = 3
    OnClick = Button1Click
  end
  object TrayIcon1: TTrayIcon
    PopupMenu = PopupMenu1
    Visible = True
    OnDblClick = TrayIcon1DblClick
    Left = 344
    Top = 168
  end
  object PopupMenu1: TPopupMenu
    Left = 424
    Top = 160
    object Restart1: TMenuItem
      Caption = 'Restart'
      OnClick = Restart1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Exit1: TMenuItem
      Caption = 'E&xit'
      OnClick = Exit1Click
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 216
    Top = 120
  end
  object tmrRestorer: TTimer
    Enabled = False
    OnTimer = tmrRestorerTimer
    Left = 264
    Top = 128
  end
  object tmrListExplorers: TTimer
    Left = 304
    Top = 24
  end
end
