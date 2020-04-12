object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Restart Explorer v1.0.9'
  ClientHeight = 269
  ClientWidth = 488
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 24
    Width = 47
    Height = 13
    Caption = 'Explorer: '
  end
  object lblCredits: TLabel
    Left = 8
    Top = 248
    Width = 291
    Height = 13
    Caption = 'Author: vhanla https://github.com/vhanla/ExplorerRestarter'
  end
  object btnStart: TButton
    Left = 89
    Top = 58
    Width = 89
    Height = 25
    Caption = 'Start Explorer'
    TabOrder = 0
    OnClick = btnStartClick
  end
  object btnKill: TButton
    Left = 8
    Top = 58
    Width = 75
    Height = 25
    Caption = 'Kill Explorer'
    TabOrder = 1
    OnClick = btnKillClick
  end
  object ListBox1: TListBox
    Left = 8
    Top = 89
    Width = 472
    Height = 153
    ItemHeight = 13
    TabOrder = 2
    OnDblClick = ListBox1DblClick
  end
  object btnListExplorers: TButton
    Left = 184
    Top = 58
    Width = 82
    Height = 25
    Caption = 'List Explorers'
    TabOrder = 3
    OnClick = btnListExplorersClick
  end
  object HotKey1: THotKey
    Left = 280
    Top = 24
    Width = 200
    Height = 19
    Hint = 'Press ESC to clear, then save changes'
    HotKey = 57457
    Modifiers = [hkShift, hkCtrl, hkAlt]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnChange = HotKey1Change
  end
  object btnSetHotkey: TButton
    Left = 184
    Top = 19
    Width = 82
    Height = 25
    Caption = 'Set Hotkey'
    TabOrder = 5
    OnClick = btnSetHotkeyClick
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
    object Settings1: TMenuItem
      Caption = '&Settings'
      OnClick = Settings1Click
    end
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
end
