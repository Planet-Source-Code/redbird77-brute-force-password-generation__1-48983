VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cPassword"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum ActiveStatesConstants
    asIsActive
    asUserCancelled
    asPasswordFound
    asMaxExceeded
End Enum

' Properties.
Private m_sCharSet      As String
Private m_sCurPass      As String
Private m_sTarget       As String
Private m_iMaxLength    As Integer
Private m_iMinLength    As Integer
Private m_asActiveState As ActiveStatesConstants

' Events.  The concept/implementaion of the events taken directly from the
' Planet-Source-Code post "Fast BruteForce Class Example" by §e7eN.
' http://www.Planet-Source-Code.com/vb/scripts/ShowCode.asp?txtCodeId=48276&lngWId=1
Public Event PasswordsPerSecond(Passwords As Long)
Public Event TotalPasswords(Passwords As Long)

' Module-level variables.
Private m_lPassPerSec As Long
Private m_lPassTime   As Long
Private m_lTotalPass  As Long
Private m_asCharSet() As String
Private m_bFound      As Boolean

Private Declare Function GetTickCount Lib "kernel32" () As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)

Property Let CharacterSet(nv As String)

Dim i As Integer

    m_sCharSet = nv
    
    ReDim m_asCharSet(Len(m_sCharSet) - 1)
    
    ' Create an array of characters based on the charset.
    For i = 0 To UBound(m_asCharSet)
        m_asCharSet(i) = Mid$(m_sCharSet, i + 1, 1)
    Next
        
End Property

Property Get CharacterSet() As String
    CharacterSet = m_sCharSet
End Property

Property Let CurrentPassword(nv As String)
    m_sCurPass = nv
End Property

Property Get CurrentPassword() As String
    CurrentPassword = m_sCurPass
End Property

Property Let Target(nv As String)
    m_sTarget = nv
End Property

Property Get Target() As String
    Target = m_sTarget
End Property

' TODO: Add property validation.
Property Let MaxLength(nv As Integer)
    m_iMaxLength = nv
End Property

Property Get MaxLength() As Integer
    MaxLength = m_iMaxLength
End Property

Property Let MinLength(nv As Integer)
    m_iMinLength = nv
End Property

Property Get MinLength() As Integer
    MinLength = m_iMinLength
End Property

Property Let ActiveState(nv As ActiveStatesConstants)
    m_asActiveState = nv
End Property

Property Get ActiveState() As ActiveStatesConstants
    ActiveState = m_asActiveState
End Property

Private Sub GetPasswordsStats()

    m_lPassPerSec = m_lPassPerSec + 1

    If GetTickCount - m_lPassTime >= 1000 Then
        RaiseEvent PasswordsPerSecond(m_lPassPerSec)
        m_lPassTime = GetTickCount
        m_lTotalPass = m_lTotalPass + m_lPassPerSec
        m_lPassPerSec = 0
        RaiseEvent TotalPasswords(m_lTotalPass)
    End If
    
End Sub

Public Sub Generate()

Dim iLen As Integer, bMaxExceeded As Boolean

    ' Reset variables/flags.
    iLen = m_iMinLength
    m_bFound = False
    m_asActiveState = asIsActive
    m_lTotalPass = 0
    
    ' Generate passwords while:
    ' 1. Password does not match target.
    ' 2. Password length does not exceed user-defined maximum.
    ' 3. User does not cancel operation.

    Do
        pMakePermsWithRepeats iLen
        iLen = iLen + 1
        If iLen > m_iMaxLength Then bMaxExceeded = True
    Loop Until m_bFound Or bMaxExceeded Or m_asActiveState <> asIsActive
    
    ' Determine why password generation stopped.
    If m_bFound Then
        m_asActiveState = asPasswordFound
    ElseIf bMaxExceeded Then
        m_asActiveState = asMaxExceeded
    End If
    
End Sub

Private Sub pMakePermsWithRepeats(ByVal iOutputLen As Integer)

Dim i        As Double
Dim iBase    As Integer
Dim zInvBase As Single
Dim dMaxPass As Double
Dim dDec     As Double
Dim iPos     As Integer

    ' Get number-system base.
    iBase = Len(m_sCharSet): zInvBase = 1 / iBase
    
    ' Ex: base=3, passwords range from 000-222.
    dMaxPass = iBase ^ iOutputLen - 1
    
    m_sCurPass = String$(iOutputLen, Left$(m_sCharSet, 1))
    
    For i = 0 To dMaxPass
    
        dDec = i
        iPos = iOutputLen
      
        ' Convert the decimal number to a password.  This is basically a
        ' base-10 to base-n conversion, then using the values as indicies in
        ' the character string array.
        Do
            Mid$(m_sCurPass, iPos, 1) = m_asCharSet(dDec Mod iBase)
            iPos = iPos - 1
            ' Multiplication by inverse is faster than division.
            dDec = Int(dDec * zInvBase)
        Loop Until dDec = 0
        
        ' TODO: Un-hardcode refresh rate.
        If i Mod 5000 = 0 Then DoEvents

        If m_sCurPass = m_sTarget Then
            m_bFound = True
            Exit Sub
        ' This seems kludgy, but is necessary if user cancels.
        ElseIf m_asActiveState <> asIsActive Then
            Exit Sub
        End If

        GetPasswordsStats
    Next
    
End Sub

Private Sub Class_Initialize()
    m_asActiveState = asUserCancelled
End Sub
