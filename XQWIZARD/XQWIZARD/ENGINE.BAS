Attribute VB_Name = "mdlEngine"
' XQWIZARD.BAS - Source Code for XiangQi Wizard, Part I
'
' XiangQi Wizard - a Chinese Chess Program (GUI for UCCI Engines)
' Designed by Morning Yellow, Version: 4.79, Last Modified: Sep. 2010
' Copyright (C) 2004-2010 www.xqbase.com
'
' This program is free software; you can redistribute it and/or modify
' it under the terms of the GNU General Public License as published by
' the Free Software Foundation; either version 2 of the License, or
' (at your option) any later version.

' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU General Public License for more details.

' You should have received a copy of the GNU General Public License along
' with this program; if not, write to the Free Software Foundation, Inc.,
' 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

Option Explicit

' ȫ�ֱ�����������
Public Engine_bEngineLog        As Boolean  ' �Ƿ��¼������־
Public Engine_szLogFile         As String   ' ������־�ļ���
Public Engine_bUseBook          As Boolean  ' �Ƿ�ʹ�ÿ��ֿ�
Public Engine_bUseEgtb          As Boolean  ' �Ƿ�ʹ�òоֿ�
Public Engine_szBookFiles       As String   ' ���ֿ��ļ���
Public Engine_szEgtbPaths       As String   ' �оֿ��ļ���
Public Engine_nHash             As Integer  ' �û�����С
Public Engine_nThreads          As Integer  ' ����ʹ�õ��߳���
Public Engine_nRandomness       As Integer  ' ���
Public Engine_nStyle            As Integer  ' ���
Public Engine_szFile            As String   ' �����ļ�
Public Engine_pipe          As PipeStruct   ' ����ܵ�
Public Engine_nStatus           As Integer  ' ����״̬
Public Engine_nTimeRatio        As Long     ' ����ʱ�����(������1����������1000)
Public Engine_szName            As String   ' ��������
Public Engine_szVersion         As String   ' ����汾
Public Engine_szCopyright       As String   ' �����Ȩ
Public Engine_szAuthor          As String   ' ��������
Public Engine_szUser            As String   ' �����û�
Public Engine_posBoard  As PositionStruct   ' ����˼���ľ���
Public Engine_dwTime            As Double   ' ����˼����ʱ��
Public Engine_nMoves            As Integer  ' ����˼���ľ�������߷���
Public Engine_nDepth            As Integer  ' ����˼�������
Public Engine_nCurrMove         As Integer  ' ����˼���ľ���ĵ�ǰ�߷���
Public Engine_bRed              As Boolean  ' ����ִ��
Public Engine_bBlack            As Boolean  ' ����ִ��
Public Engine_bPonder           As Boolean  ' ��̨˼��
Public Engine_bAnalyze          As Boolean  ' �������
Public Engine_mvPonder          As Long     ' ��̨˼���²��ŷ�
Public Engine_mvPonderFinished  As Long     ' ��̨˼����ɵ��ŷ�
Public Engine_mvPonderFinishedPonder As Long ' ��̨˼����ɵĲ²��ŷ�
Public Engine_bPonderFinishedResign As Long ' ��̨˼����ɺ�����
Public Engine_bPonderFinishedDraw As Long   ' ��̨˼����ɺ���ͻ�������
Public Engine_szPonderStr       As String   ' ��̨˼��ָ�
Public Engine_bDraw             As Integer  ' ���
Public Engine_mvBan             As Long     ' ����
Public Engine_bSlaveRed         As Boolean  ' ������ִ��
Public Engine_bSlaveBlack       As Boolean  ' ������ִ��
Public Engine_pipeSlave     As PipeStruct   ' ������ܵ�
Public Engine_nTimeRatioSlave   As Long     ' ������ʱ�����
Public Engine_szSlaveName       As String   ' ����������

' ��ʾ������Ϣ�ĶԻ���
Public Sub AboutEngine()

MessageBeep vbInformation
If Options_nLanguage = LANGUAGE_ZH_CN Then
    MsgBoxIcon IIf(Engine_szName = "", "", "���棺" & Engine_szName & vbCrLf) & _
            IIf(Engine_szVersion = "", "", "�汾��" & Engine_szVersion & vbCrLf) & _
            IIf(Engine_szCopyright = "", "", "��Ȩ��" & Engine_szCopyright & vbCrLf) & _
            IIf(Engine_szAuthor = "", "", "���ߣ�" & Engine_szAuthor & vbCrLf) & _
            IIf(Engine_szUser = "", "", "�û���" & Engine_szUser), , "����UCCI����", Engine_szFile
Else
    MsgBoxIcon IIf(Engine_szName = "", "", "���棺" & Engine_szName & vbCrLf) & _
            IIf(Engine_szVersion = "", "", "�汾��" & Engine_szVersion & vbCrLf) & _
            IIf(Engine_szCopyright = "", "", "��ࣺ" & Engine_szCopyright & vbCrLf) & _
            IIf(Engine_szAuthor = "", "", "���ߣ�" & Engine_szAuthor & vbCrLf) & _
            IIf(Engine_szUser = "", "", "�Ñ���" & Engine_szUser), , "�P�UCCI����", Engine_szFile
End If

End Sub

' �����������ӷ���ת���̲���ʾ����˫��
Public Sub EnginePlayer()

Dim szName As String, szSlaveName As String, szUser As String
Engine_bPonder = False
App_frmMain.mnEnginePonder.Checked = False
If Engine_bRed Eqv Engine_bBlack Then
    App_frmMain.mnEnginePonder.Enabled = False
Else
    App_frmMain.mnEnginePonder.Enabled = True
    If Options_bAlwaysPonder Then
        Engine_bPonder = True
        App_frmMain.mnEnginePonder.Checked = True
    End If
    If Options_bAutoFlip Then
        App_bFlipped = Engine_bRed
        CoordFlush
        BoardFlush
    End If
End If
App_frmMain.mnPosFlip.Checked = App_bFlipped
App_frmMain.tlb.Buttons("PosFlip").Value = IIf(App_bFlipped, tbrPressed, tbrUnpressed)
If Options_bEngineName Then
    szName = IIf(Engine_szName = "ElephantEye", L("������ʦ", "�����׎�"), Engine_szName)
    szSlaveName = IIf(Engine_szSlaveName = "ElephantEye", L("������ʦ", "�����׎�"), Engine_szSlaveName)
    szUser = IIf(Options_szUser = "", IIf(Timer_nDepth < 0, LevelString(Timer_nDepth), ""), Options_szUser)
    Game_szRedPlayer = IIf(Engine_bRed, IIf(Engine_bSlaveRed, szSlaveName, szName), szUser)
    Game_szBlackPlayer = IIf(Engine_bBlack, IIf(Engine_bSlaveBlack, szSlaveName, szName), szUser)
End If
LabelFlush
StartTimer

End Sub

' ���������Ƿ���˼������ʾ�˵��͹������ϵĿ��ù���
Public Sub EngineBusy(ByVal bBusy As Boolean)

App_frmMain.mnPosMirror.Enabled = Not bBusy
App_frmMain.mnPosEdit.Enabled = Not bBusy
App_frmMain.tlb.Buttons("PosEdit").Enabled = Not bBusy
App_frmMain.mnPosPaste.Enabled = Not bBusy
App_frmMain.mnPosLoad.Enabled = Not bBusy
App_frmMain.mnWizardPlay.Enabled = Not bBusy
App_frmMain.tlb.Buttons("WizardPlay").Enabled = Not bBusy
App_frmMain.mnWizardHandicap_.Enabled = Not bBusy
App_frmMain.mnEndgamesStart.Enabled = Not bBusy
App_frmMain.tlb.Buttons("EndgamesStart").Enabled = Not bBusy
App_frmMain.mnEndgames_.Enabled = Not bBusy
App_frmMain.mnEngineLevel.Enabled = Not bBusy
App_frmMain.tlb.Buttons("EngineLevel").Enabled = Not bBusy
App_frmMain.mnEngineSet.Enabled = Not bBusy
App_frmMain.mnEngineStop.Enabled = bBusy
App_frmMain.tlb.Buttons("EngineStop").Enabled = bBusy
If bBusy And App_bPlay Then
    App_bPlay = False
    App_frmMain.mnWizardPlay.Checked = False
    App_frmMain.tlb.Buttons("WizardPlay").Value = tbrUnpressed
End If

End Sub

' �����淢��ָ�����¼��־������ѡ���������滹�Ǹ�����
Public Sub SendEngine(ByVal szLineStr As String, Optional ByVal bSlaveEngine As Boolean = False)

Dim nLogFileNo As Integer
If bSlaveEngine Then
    PipeLineOutput Engine_pipeSlave, szLineStr
Else
    PipeLineOutput Engine_pipe, szLineStr
End If
If Engine_bEngineLog And Engine_szLogFile <> "" Then
    nLogFileNo = FreeFile
    On Error GoTo lnErrorOpen
    Open Engine_szLogFile For Append As #nLogFileNo
    Print #nLogFileNo, "<font color=""" & IIf(bSlaveEngine, "#FF00FF", "#FF0000") & """>" & szLineStr & "</font><br>"
    Close #nLogFileNo
End If

lnErrorOpen:
On Error GoTo 0

End Sub

' �ѽ��յ������淴��������־
Public Sub ReceiveEngineLog(ByVal szLineStr As String, Optional ByVal bSlaveEngine As Boolean = False)

Dim nLogFileNo As Integer
If Engine_bEngineLog And Engine_szLogFile <> "" Then
    nLogFileNo = FreeFile
    On Error GoTo lnErrorOpen
    Open Engine_szLogFile For Append As #nLogFileNo
    Print #nLogFileNo, "<font color=""" & IIf(bSlaveEngine, "#000080", "#0000FF") & """>" & szLineStr & "</font><br>"
    Close #nLogFileNo
End If

lnErrorOpen:
On Error GoTo 0

End Sub

' ������˼����˼��ǰ��������˼��״̬(BUSY_ANALYZE/BUSY_THINK/BUSY_PONDER)
Public Sub RunEngine()

Dim i As Integer, nMoves As Integer, bSlaveEngine As Boolean
Dim nTimeRatio As Long, nMoveStatus As Long
Dim szFenStr As String, szGoPonder As String
Dim nMoveList(1 To 128) As Long

Engine_posBoard = Game_pos
Engine_dwTime = Timer
Engine_nMoves = CchessGenMoves(Engine_posBoard, nMoveList(1))
Engine_nDepth = 0
Engine_nCurrMove = 0
If Engine_bAnalyze Then
    frmThink.txtThink.Text = ""
End If
szFenStr = Game_szFen
nMoves = Game_nCurrMove + 1 - Game_pos.nMoveNum
If Game_nCurrMove > nMoves Then
    szFenStr = szFenStr & " moves"
    For i = nMoves + 1 To Game_nCurrMove
        szFenStr = szFenStr & " " & Move2Coord(Game_mvMove(i))
    Next
End If
szGoPonder = "go"
If Engine_nStatus = BUSY_PONDER Then
    Select Case Game_nFormat
    Case 0
        Engine_szPonderStr = MkC(CchessFile2Chin(CchessMove2File(Engine_mvPonder, Engine_posBoard), Engine_posBoard.sdPlayer))
    Case 1
        Engine_szPonderStr = MkL(CchessMove2File(Engine_mvPonder, Engine_posBoard))
    Case 2
        Engine_szPonderStr = Move2Iccs(Engine_mvPonder)
    End Select
    If CchessTryMove(Engine_posBoard, nMoveStatus, Engine_mvPonder) <> 0 Then
        szFenStr = szFenStr & IIf(Game_nCurrMove > nMoves, "", " moves")
        szFenStr = szFenStr & " " & Move2Coord(Engine_mvPonder)
        szGoPonder = szGoPonder & " ponder"
    End If
Else
    If Engine_bDraw Then
        szGoPonder = szGoPonder & " draw"
    End If
End If
bSlaveEngine = IIf(Engine_posBoard.sdPlayer = 0, Engine_bSlaveRed, Engine_bSlaveBlack)
nTimeRatio = IIf(bSlaveEngine, Engine_nTimeRatioSlave, Engine_nTimeRatio)
SendEngine "position fen " & szFenStr, bSlaveEngine
If Engine_mvBan <> 0 Then
    SendEngine "banmoves " & Move2Coord(Engine_mvBan), bSlaveEngine
End If
If Engine_nStatus = BUSY_ANALYZE Then
    SendEngine "go infinite", bSlaveEngine
Else
    If Timer_nDepth = 0 Then
        If Timer_bIncMode Then
            SendEngine szGoPonder & " time " & (nTimeRatio * Timer_nTimeLeft(Engine_posBoard.sdPlayer)) & _
                    " increment " & IIf(Timer_nIncTime < 0, 0, nTimeRatio * Timer_nIncTime) & _
                    " opptime " & (nTimeRatio * Timer_nTimeLeft(1 - Engine_posBoard.sdPlayer)) & _
                    " oppincrement " & IIf(Timer_nIncTime < 0, 0, nTimeRatio * Timer_nIncTime), bSlaveEngine
        Else
            SendEngine szGoPonder & " time " & (nTimeRatio * Timer_nTimeLeft(Engine_posBoard.sdPlayer)) & _
                    " movestogo " & Timer_nMoveLeft(Engine_posBoard.sdPlayer) & _
                    " opptime " & (nTimeRatio * Timer_nTimeLeft(1 - Engine_posBoard.sdPlayer)) & _
                    " oppmovestogo " & (Timer_nMoveLeft(1 - Engine_posBoard.sdPlayer)), bSlaveEngine
        End If
    ElseIf Timer_nDepth < 0 Then
        SendEngine szGoPonder & " nodes " & (6 ^ (2 - Timer_nDepth)), bSlaveEngine
    Else
        SendEngine szGoPonder & " depth " & Timer_nDepth, bSlaveEngine
    End If
End If
App_frmMain.stb.Panels("Curr").Text = ""
App_frmMain.stb.Panels("Nps").Text = ""
App_frmMain.stb.Panels("Pv").Text = ""
App_frmMain.stb.Panels("Msg").Text = ""
EngineBusy True

End Sub

' ��˼��ϸ�ڿ��������Ϣ������λ���
Public Sub AppendThink(ByVal sz As String)

Dim nTextLen As Long
If frmThink.txtThink.Text = "" Then
    frmThink.txtThink.Text = sz
    frmThink.txtThink.SelStart = 0
Else
    frmThink.txtThink.Text = frmThink.txtThink.Text & vbCrLf
    nTextLen = Len(frmThink.txtThink.Text)
    frmThink.txtThink.Text = frmThink.txtThink.Text & sz
    frmThink.txtThink.SelStart = nTextLen
End If

End Sub

' ����������Ϣ����ʾ����ʾ˼�����ں�״̬��
Public Sub PopEngine(ByVal szReceived As String)

Dim i As Integer, nScore As Integer, nOldDepth As Integer
Dim nTime As Long, nNodes As Long
Dim szMoveList As String, nMoveStatus As Long, mv As Long
Dim pos As PositionStruct

' �����ǰ˼���ŷ�
i = InStr(szReceived, " currmove ")
If i > 0 Then
    Engine_nCurrMove = Engine_nCurrMove + 1
    If Options_bStatusBar Then
        mv = Coord2Move(Mid(szReceived, i + 10))
        Select Case Game_nFormat
        Case 0
            szMoveList = MkC(CchessFile2Chin(CchessMove2File(mv, Engine_posBoard), Engine_posBoard.sdPlayer))
        Case 1
            szMoveList = MkL(CchessMove2File(mv, Engine_posBoard))
        Case 2
            szMoveList = Move2Iccs(mv)
        End Select
        App_frmMain.stb.Panels("Curr").Text = Engine_nDepth & _
                " (" & Engine_nCurrMove & "/" & Engine_nMoves & ") " & szMoveList
    End If
End If

' ����ٶ�
If Options_bStatusBar Then
    i = InStr(szReceived, " nodes ")
    If i > 0 Then
        nNodes = Str2Lng(Mid(szReceived, i + 7))
        nTime = (Timer - Engine_dwTime) * 1000
        nTime = IIf(nTime < 0, nTime + 86400000, nTime)
        If nTime > 0 Then
            App_frmMain.stb.Panels("Nps").Text = "NPS " & (nNodes \ nTime) & "K"
        End If
    End If
End If

' �����Ҫ����
i = InStr(szReceived, " depth ")
If i > 0 Then
    nOldDepth = Engine_nDepth
    Engine_nDepth = Str2Int(Mid(szReceived, i + 7), -999, 999)
    If Engine_nDepth > nOldDepth Then
        Engine_nCurrMove = 0
    End If
    If Engine_nDepth > 0 Then
        If Engine_bAnalyze And Options_bEngineTime Then
            nTime = Int((Timer - Engine_dwTime) * 1000)
            nTime = IIf(nTime < 0, nTime + 86400000, nTime)
            AppendThink TimeText(nTime \ 1000) & "." & ((nTime \ 100) Mod 10) & " ->"
        End If
    End If
    szMoveList = Space(3 - Len("" & Engine_nDepth)) & Engine_nDepth
    i = InStr(szReceived, " score ")
    If i > 0 Then
        If Mid(szReceived, i + 7, 5) = "mate " Then
            nScore = Str2Int(Mid(szReceived, i + 12))
            nScore = IIf(nScore < 0, -10000, 10000) - nScore
        Else
            nScore = Str2Int(Mid(szReceived, i + 7))
        End If
        If nScore > 0 Then
            szMoveList = szMoveList & Space(5 - Len("" & nScore)) & "(+" & nScore & ")"
        ElseIf nScore < 0 Then
            szMoveList = szMoveList & Space(6 - Len("" & nScore)) & "(" & nScore & ")"
        Else
            szMoveList = szMoveList & "     (0)"
        End If
        i = InStr(szReceived, " pv ")
        If i > 0 Then
            pos = Engine_posBoard
            If Engine_nStatus = BUSY_PONDER Then
                szMoveList = szMoveList & " (" & Engine_szPonderStr & ")"
            End If
            i = i + 4
            Do While i < Len(szReceived)
                mv = Coord2Move(Mid(szReceived, i))
                Select Case Game_nFormat
                Case 0
                    szMoveList = szMoveList & " " & MkC(CchessFile2Chin(CchessMove2File(mv, pos), pos.sdPlayer))
                Case 1
                    szMoveList = szMoveList & " " & MkL(CchessMove2File(mv, pos))
                Case 2
                    szMoveList = szMoveList & " " & Move2Iccs(mv)
                End Select
                CchessTryMove pos, nMoveStatus, mv
                i = i + 5
            Loop
        End If
        If Options_bStatusBar And Engine_nDepth > 0 Then
            App_frmMain.stb.Panels("Pv").Text = szMoveList
        End If
    End If
    If Engine_bAnalyze Then
        AppendThink szMoveList
    End If
End If

' ���������ʾ��Ϣ
i = InStr(szReceived, " message ")
If i > 0 Then
    If Options_bStatusBar Then
        App_frmMain.stb.Panels("Msg").Text = Mid(szReceived, i + 9)
    End If
    If Engine_bAnalyze Then
        AppendThink Mid(szReceived, i + 9)
    End If
End If

End Sub

' ������˼��ʱ������������Ϣ
Public Function ReceiveEngine() As Boolean

Dim lpStr As Long, bSlaveEngine As Boolean, szReceived As String
Dim i As Integer, mv As Long

If Engine_nStatus = IDLE_UNLOAD Then
    ReceiveEngine = False
    Exit Function
End If
bSlaveEngine = (Engine_nStatus >= BUSY_WAIT And _
        IIf(Engine_posBoard.sdPlayer = 0, Engine_bSlaveRed, Engine_bSlaveBlack))
If bSlaveEngine Then
    lpStr = PipeLineInput(Engine_pipeSlave)
Else
    lpStr = PipeLineInput(Engine_pipe)
End If
If lpStr = 0 Then
    If bSlaveEngine Then
        If PipeEof(Engine_pipeSlave) Then
            PipeClose Engine_pipeSlave
            MsgBox L("�������쳣�˳���", "�����殐���˳���"), vbExclamation
            Engine_bSlaveRed = False
            Engine_bSlaveBlack = False
            Engine_nStatus = IDLE_READY
            EngineBusy False
        End If
    Else
        If PipeEof(Engine_pipe) Then
            PipeClose Engine_pipe
            MsgBox L("�����쳣�˳���", "���殐���˳���"), vbExclamation
            Engine_nStatus = IDLE_UNLOAD
            EngineLoaded False
        End If
    End If
    ReceiveEngine = False
    Exit Function
End If

szReceived = AllocString(lpStr)
ReceiveEngineLog szReceived, bSlaveEngine
If Left(szReceived, 9) = "bestmove " Then
    EngineBusy False
    mv = Coord2Move(Mid(szReceived, 10, 4))
    Select Case Engine_nStatus
    Case BUSY_WAIT
        Engine_nStatus = IDLE_READY
    Case BUSY_PONDER
        Engine_mvPonderFinished = mv
        If Engine_bPonder And Mid(szReceived, 14, 8) = " ponder " Then
            Engine_mvPonderFinishedPonder = Coord2Move(Mid(szReceived, 22, 4))
        Else
            Engine_mvPonderFinishedPonder = 0
        End If
        Engine_bPonderFinishedResign = (Right(szReceived, 7) = " resign")
        Engine_bPonderFinishedDraw = (Right(szReceived, 5) = " draw")
        Engine_nStatus = IDLE_PONDER
    Case BUSY_ANALYZE
        Engine_nStatus = IDLE_REST
    Case BUSY_THINK
        Do While Game_nCurrMove < Game_nMaxMove
            MoveForward
        Loop
        If Options_nMoveDelay > 0 Then
            Sleep Options_nMoveDelay * 800
        End If
        If Options_bAllowResign And Right(szReceived, 7) = " resign" Then
            EngineResign
        ElseIf Engine_bDraw And Right(szReceived, 5) = " draw" Then
            EngineAcceptDraw
        Else
            Engine_nStatus = IDLE_READY
            ' һ��Ҫ�� IDLE_READY ��ʱ�� AddMove
            If AddMove(mv, MOVE_WITH_ECHO, MOVE_BY_ENGINE) Then
                App_frmMain.SetFocus
                If Options_bAllowResign And Right(szReceived, 5) = " draw" Then
                    EngineOfferDraw
                End If
                If Engine_bPonder And Mid(szReceived, 14, 8) = " ponder " Then
                    Engine_mvPonder = Coord2Move(Mid(szReceived, 22, 4))
                    Engine_nStatus = BUSY_PONDER
                    RunEngine
                End If
            Else
                ' ����û�гɹ�����������˼��
                Engine_nStatus = IDLE_REST
            End If
        End If
    Case Else
        ' ���ý��յ���������Ϣ
    End Select
    If Options_bStatusBar Then
        App_frmMain.stb.Panels("Curr").Text = ""
    End If
ElseIf Left(szReceived, 10) = "nobestmove" Then
    EngineBusy False
    Select Case Engine_nStatus
    Case BUSY_WAIT
        Engine_nStatus = IDLE_READY
    Case BUSY_PONDER
        Engine_nStatus = IDLE_READY
    Case BUSY_ANALYZE
        Engine_nStatus = IDLE_REST
    Case BUSY_THINK
        Engine_nStatus = IDLE_REST
    Case Else
        ' ���ý��յ��������Ϣ
    End Select
    If Options_bStatusBar Then
        App_frmMain.stb.Panels("Curr").Text = ""
    End If
ElseIf Left(szReceived, 12) = "info string " Then
ElseIf Left(szReceived, 5) = "info " Then
    PopEngine szReceived
End If
ReceiveEngine = True

End Function

' ��ֹ����˼��
Public Sub StopEngine()

Dim nOldStatus As Integer
Dim dfLastTime As Double, dfThisTime As Double
SendEngine "stop", IIf(Engine_posBoard.sdPlayer = 0, Engine_bSlaveRed, Engine_bSlaveBlack)
dfLastTime = Timer
nOldStatus = Engine_nStatus
Do While Engine_nStatus = nOldStatus
    If Not ReceiveEngine Then
        Sleep 1
        dfThisTime = Timer
        dfThisTime = dfThisTime + IIf(dfThisTime < dfLastTime, 86400#, 0#)
        If dfThisTime > dfLastTime + 10# Then
            Exit Do
        End If
    End If
Loop
If Engine_nStatus = nOldStatus Then
    Engine_nStatus = IDLE_READY
    EngineBusy False
End If

End Sub

' �����������
Public Sub SetEngine(Optional ByVal bSlaveEngine As Boolean = False)

SendEngine "setoption promotion " & IIf(App_bPromotion, "true", "false"), bSlaveEngine
SendEngine "setoption usebook " & IIf(Engine_bUseBook, "true", "false"), bSlaveEngine
SendEngine "setoption useegtb " & IIf(Engine_bUseEgtb, "true", "false"), bSlaveEngine
If Engine_szBookFiles <> "" Then
    SendEngine "setoption bookfiles " & Engine_szBookFiles, bSlaveEngine
End If
If Engine_szEgtbPaths <> "" Then
    SendEngine "setoption egtbpaths " & Engine_szEgtbPaths, bSlaveEngine
End If
SendEngine "setoption hashsize " & IIf(Engine_nHash = 0, 0, 16 * 2 ^ (Engine_nHash - 1)), bSlaveEngine
If Engine_nThreads = 0 Then
    SendEngine "setoption threads 0"
    SendEngine "setoption idle none"
ElseIf Engine_nThreads < 4 Then
    SendEngine "setoption threads 1"
    SendEngine "setoption idle " & Choose(Engine_nThreads, "large", "medium", "small"), bSlaveEngine
Else
    SendEngine "setoption threads " & (2 ^ (Engine_nThreads - 4)), bSlaveEngine
    SendEngine "setoption idle none"
End If
SendEngine "setoption randomness " & Choose(Engine_nRandomness + 1, "none", "small", "medium", "large"), bSlaveEngine
SendEngine "setoption style " & Choose(Engine_nStyle + 1, "solid", "normal", "risky"), bSlaveEngine

End Sub

' ���������Ƿ��Ѽ��أ���ʾ�˵��͹������ϵĿ��ù���
Public Sub EngineLoaded(ByVal bLoaded As Boolean)

App_frmMain.mnEngineSet.Enabled = bLoaded
Engine_bRed = False
App_frmMain.mnEngineRed.Enabled = bLoaded
App_frmMain.mnEngineRed.Checked = False
App_frmMain.tlb.Buttons("EngineRed").Enabled = bLoaded
App_frmMain.tlb.Buttons("EngineRed").Value = tbrUnpressed
Engine_bBlack = False
App_frmMain.mnEngineBlack.Enabled = bLoaded
App_frmMain.mnEngineBlack.Checked = False
App_frmMain.tlb.Buttons("EngineBlack").Enabled = bLoaded
App_frmMain.tlb.Buttons("EngineBlack").Value = tbrUnpressed
Engine_bPonder = False
App_frmMain.mnEnginePonder.Enabled = False
App_frmMain.mnEnginePonder.Checked = False
If Engine_bAnalyze Then
    Unload frmThink
End If
App_frmMain.mnEngineAnalyze.Enabled = bLoaded
App_frmMain.tlb.Buttons("EngineAnalyze").Enabled = bLoaded
App_frmMain.mnEngineStop.Enabled = False
App_frmMain.mnMoveRetract.Enabled = bLoaded
App_frmMain.mnMoveBan.Enabled = bLoaded
App_frmMain.mnMoveDraw.Checked = False
App_frmMain.tlb.Buttons("EngineStop").Enabled = False
App_frmMain.mnHelpEngine.Enabled = bLoaded
If Not bLoaded Then
    Timer_bEnabled = False
    App_frmMain.mnEngineLevel.Checked = False
    App_frmMain.tlb.Buttons("EngineLevel").Value = tbrUnpressed
End If

End Sub

' �ر�����(����и����棬�ȹرո�����)
Public Sub CloseEngine()

If Engine_nStatus > BUSY_WAIT Then
    Engine_nStatus = BUSY_WAIT
    StopEngine
End If
If Engine_bSlaveRed Or Engine_bSlaveBlack Then
    CloseSlaveEngine
End If
SendEngine "quit"
PipeClose Engine_pipe
Engine_nStatus = IDLE_UNLOAD

End Sub

' �رո�����
Public Sub CloseSlaveEngine()

SendEngine "quit", SLAVE_ENGINE
PipeClose Engine_pipeSlave
Engine_bSlaveRed = False
Engine_bSlaveBlack = False

End Sub

' ������
Public Sub OpenEngine(Optional ByVal bInfo As Boolean = False)

Dim dfLastTime As Double, dfThisTime As Double
Dim lpStr As Long, szReceived As String, bPipeEof As Boolean

If Engine_nStatus > IDLE_UNLOAD Then
    CloseEngine
End If
If Engine_szFile = "" Then
    EngineLoaded False
    SetTitle
    Exit Sub
End If

PipeOpen Engine_pipe, Engine_szFile
SendEngine "ucci"
dfLastTime = Timer
Engine_szName = ""
Engine_szVersion = ""
Engine_szCopyright = ""
Engine_szAuthor = ""
Engine_szUser = ""
Engine_nTimeRatio = 1
bPipeEof = False
Do While Engine_nStatus = IDLE_UNLOAD
    lpStr = PipeLineInput(Engine_pipe)
    If lpStr = 0 Then
        If PipeEof(Engine_pipe) Then
            bPipeEof = True
            Exit Do
        End If
        Sleep 1
        dfThisTime = Timer
        dfThisTime = dfThisTime + IIf(dfThisTime < dfLastTime, 86400#, 0#)
        ' ���������ʱ���ӳ���60��
        If dfThisTime > dfLastTime + 60# Then
            Exit Do
        End If
    Else
        szReceived = AllocString(lpStr)
        ReceiveEngineLog szReceived
        If Left(szReceived, 8) = "id name " Then
            Engine_szName = Mid(szReceived, 9)
        ElseIf Left(szReceived, 11) = "id version " Then
            Engine_szVersion = Mid(szReceived, 12)
        ElseIf Left(szReceived, 13) = "id copyright " Then
            Engine_szCopyright = Mid(szReceived, 14)
        ElseIf Left(szReceived, 10) = "id author " Then
            Engine_szAuthor = Mid(szReceived, 11)
        ElseIf Left(szReceived, 8) = "id user " Then
            Engine_szUser = Mid(szReceived, 9)
        ElseIf Left(szReceived, 19) = "option usemillisec " Then
            Engine_nTimeRatio = 1000
        ElseIf szReceived = "ucciok" Then
            Engine_nStatus = IDLE_READY
        End If
    End If
Loop
If Engine_nStatus > IDLE_UNLOAD Then
    Engine_bSlaveRed = False
    Engine_bSlaveBlack = False
    SendEngine "setoption guiname XQWizard"
    If Engine_nTimeRatio = 1000 Then
        SendEngine "setoption usemillisec true"
    End If
    SetEngine
    If bInfo Then
        AboutEngine
    End If
    EngineLoaded True
Else
    SendEngine "quit"
    PipeClose Engine_pipe
    If bPipeEof Then
        MsgBox L("�޷��������棺", "�o�����d���棺") & Engine_szFile, vbExclamation
    Else
        MsgBox L("�޷��������棺", "�o�����d���棺") & Engine_szFile & vbCrLf & vbCrLf & _
                L("��������������ĵ��Ը��ɹ��ض�����ģ����˳�������ʦ�������������Կ���", _
                "�@���������������Xؓ���^�ض�����ģ�Ո�˳������׎��K�����\��ԇԇ����"), vbExclamation
    End If
    Engine_szFile = ""
    EngineLoaded False
End If
SetTitle

End Sub

' �򿪸�����
Public Sub OpenSlaveEngine()

Dim szEngineFile As String, szVersion As String, szCopyright As String, szAuthor As String, szUser As String
Dim dfLastTime As Double, dfThisTime As Double
Dim lpStr As Long, szReceived As String, bPipeEof As Boolean

If Engine_bSlaveRed Or Engine_bSlaveBlack Then
    CloseSlaveEngine
    MsgBox L("��������ж�ء�", "��������ж�d��"), vbInformation
    Exit Sub
End If
szEngineFile = FileDialog(L("���ظ�����", "���d������"), L("�����ļ�", "�����ļ�"), "EXE")
If szEngineFile = "" Then
    Exit Sub
End If
If GetAppType(szEngineFile) <> IMAGE_SUBSYSTEM_WINDOWS_CUI Then
    MsgBox szEngineFile & L(" �����й����������ļ���", " �����Ї����������ļ���"), vbExclamation
    Exit Sub
End If
PipeOpen Engine_pipeSlave, szEngineFile
SendEngine "ucci", SLAVE_ENGINE
dfLastTime = Timer
Engine_szSlaveName = ""
szCopyright = ""
szAuthor = ""
szUser = ""
Engine_nTimeRatioSlave = 1
bPipeEof = False
Do While Not Engine_bSlaveBlack
    lpStr = PipeLineInput(Engine_pipeSlave)
    If lpStr = 0 Then
        If PipeEof(Engine_pipeSlave) Then
            bPipeEof = True
            Exit Do
        End If
        Sleep 1
        dfThisTime = Timer
        dfThisTime = dfThisTime + IIf(dfThisTime < dfLastTime, 86400#, 0#)
        If dfThisTime > dfLastTime + 60# Then
            Exit Do
        End If
    Else
        szReceived = AllocString(lpStr)
        ReceiveEngineLog szReceived, SLAVE_ENGINE
        If Left(szReceived, 8) = "id name " Then
            Engine_szSlaveName = Mid(szReceived, 9)
        ElseIf Left(szReceived, 11) = "id version " Then
            szVersion = Mid(szReceived, 12)
        ElseIf Left(szReceived, 13) = "id copyright " Then
            szCopyright = Mid(szReceived, 14)
        ElseIf Left(szReceived, 10) = "id author " Then
            szAuthor = Mid(szReceived, 11)
        ElseIf Left(szReceived, 8) = "id user " Then
            szUser = Mid(szReceived, 9)
        ElseIf Left(szReceived, 19) = "option usemillisec " Then
            Engine_nTimeRatioSlave = 1000
        ElseIf szReceived = "ucciok" Then
            Engine_bSlaveBlack = True
        End If
    End If
Loop
If Engine_bSlaveBlack Then
    MessageBeep vbInformation
    If Options_nLanguage = LANGUAGE_ZH_CN Then
        MsgBoxIcon IIf(Engine_szSlaveName = "", "", "���棺" & Engine_szSlaveName & vbCrLf) & _
                IIf(szVersion = "", "", "�汾��" & szVersion & vbCrLf) & _
                IIf(szCopyright = "", "", "��Ȩ��" & szCopyright & vbCrLf) & _
                IIf(szAuthor = "", "", "���ߣ�" & szAuthor & vbCrLf) & _
                IIf(szUser = "", "", "�û���" & szUser), , "����UCCI����", szEngineFile
    Else
        MsgBoxIcon IIf(Engine_szSlaveName = "", "", "���棺" & Engine_szSlaveName & vbCrLf) & _
                IIf(szVersion = "", "", "�汾��" & szVersion & vbCrLf) & _
                IIf(szCopyright = "", "", "��ࣺ" & szCopyright & vbCrLf) & _
                IIf(szAuthor = "", "", "���ߣ�" & szAuthor & vbCrLf) & _
                IIf(szUser = "", "", "�Ñ���" & szUser), , "�P�UCCI����", szEngineFile
    End If
    SendEngine "setoption guiname XQWizard", SLAVE_ENGINE
    If Engine_nTimeRatioSlave = 1000 Then
        SendEngine "setoption usemillisec true", SLAVE_ENGINE
    End If
    SetEngine SLAVE_ENGINE
Else
    SendEngine "quit", SLAVE_ENGINE
    PipeClose Engine_pipeSlave
    If bPipeEof Then
        MsgBox L("�޷��������棺", "�o�����d���棺") & szEngineFile, vbExclamation
    Else
        MsgBox L("�޷��������棺", "�o�����d���棺") & szEngineFile & vbCrLf & vbCrLf & _
                L("��������������ĵ��Ը��ɹ��ض�����ģ����˳�������ʦ�������������Կ���", _
                "�@���������������Xؓ���^�ض�����ģ�Ո�˳������׎��K�����\��ԇԇ����"), vbExclamation
    End If
End If

End Sub

' ����ʱ��
Public Sub StartTimer()

Timer_bOver(0) = False
Timer_bOver(1) = False
Timer_nTimeLeft(0) = Timer_nInitTime * 60
Timer_nTimeLeft(1) = Timer_nInitTime * 60
Timer_nMoveLeft(0) = Timer_nIncMove
Timer_nMoveLeft(1) = Timer_nIncMove
SetTimer 0
SetTimer 1
If Timer_nDepth = 0 And (Engine_bRed Or Engine_bBlack) Then
    Timer_dfLastTime = Timer
    Timer_bEnabled = True
    App_frmMain.mnEngineLevel.Checked = True
    App_frmMain.tlb.Buttons("EngineLevel").Value = tbrPressed
Else
    Timer_bEnabled = False
    App_frmMain.mnEngineLevel.Checked = False
    App_frmMain.tlb.Buttons("EngineLevel").Value = tbrUnpressed
End If

End Sub

' �¾�ʱѡ���������ķ�
Public Sub EngineNewGame(Optional ByVal nEnginePlay As Integer = -1)

PlayWavSound "NEWGAME"
If Engine_nStatus = IDLE_UNLOAD Then
    Exit Sub
End If
Select Case IIf(nEnginePlay < 0, Options_nEnginePlay, nEnginePlay)
Case ENGINE_PLAY_NONE
    Engine_bRed = False
    Engine_bBlack = False
Case ENGINE_PLAY_RED
    Engine_bRed = True
    Engine_bBlack = False
Case ENGINE_PLAY_BLACK
    Engine_bRed = False
    Engine_bBlack = True
Case ENGINE_PLAY_TURN
    If App_bRedTurn Then
        Engine_bRed = True
        Engine_bBlack = False
    Else
        Engine_bRed = False
        Engine_bBlack = True
    End If
    App_bRedTurn = Not App_bRedTurn
Case ENGINE_PLAY_RANDOM
    If Rnd < 0.5 Then
        Engine_bRed = True
        Engine_bBlack = False
    Else
        Engine_bRed = False
        Engine_bBlack = True
    End If
End Select
App_frmMain.mnEngineRed.Checked = Engine_bRed
App_frmMain.tlb.Buttons("EngineRed").Value = IIf(Engine_bRed, tbrPressed, tbrUnpressed)
App_frmMain.mnEngineBlack.Checked = Engine_bBlack
App_frmMain.tlb.Buttons("EngineBlack").Value = IIf(Engine_bBlack, tbrPressed, tbrUnpressed)
If Engine_bRed Or Engine_bBlack Then
    EnginePlayer
End If

End Sub