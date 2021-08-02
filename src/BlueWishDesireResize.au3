#include <File.au3>
#include <MsgBoxConstants.au3>
#include <compileParams.au3>
#include <WindowsConstants.au3>
#include <WinAPISysWin.au3>

Main(@ScriptDir)

Func Main($sGameDir)
	Local $iTimeoutFindGameWindowMsec = 120000
	Local $iTimeoutSetStyleWindowMsec = 30000

	$sGameExe = FindFirstFile($sGameDir, "*.exe")
	if $sGameExe == False Then MessageExit("Cannot find game file =(")

	FileChangeDir($sGameDir)
	$iPID = run($sGameExe)
	if $iPID == 0 then MessageExit("Cannot run game =(")

	$hWnd = GetHwndFromPID($iPID, $iTimeoutFindGameWindowMsec, 600, 400)
	if $hWnd == 0 Then MessageExit("Cannot find game window =(")

	if Not SetWindowResizeStyleTimeout($hWnd, $iTimeoutSetStyleWindowMsec) Then _
		MessageExit("Cannot set style game window =(")
EndFunc   ;==>Main

Func FindFirstFile($sDir, $sFilter)
	Local $aFileList = _FileListToArray($sDir, $sFilter)
	If @error <> 0 Then Return False
	For $i = 1 to $aFileList[0]
		If CurrentScriptName() == StringLower($aFileList[$i]) Then ContinueLoop
		return $aFileList[$i]
	Next
	return False
EndFunc   ;==>FindFirstFile

Func CurrentScriptName()
	Local $aMatches = StringRegExp(StringLower(@ScriptName), "(.*)\.(au3|exe)$", $STR_REGEXPARRAYMATCH)
	return $aMatches[0] & ".exe"
EndFunc   ;==>CurrentScriptName

Func GetHwndFromPID($PID, $iTimeoutMSec = 10000, $iW = 100, $iH = 100)
	Local $hWnd = 0
	Local $iCurTimeMSec = 0
	Local $iTimeTryMSec = 500
	Do
		Sleep($iTimeTryMSec)
		Local $winlist = WinList()
		For $i = 1 To $winlist[0][0]
			If $winlist[$i][0] <> "" Then
				Local $iPID2 = WinGetProcess($winlist[$i][1])
				if $iPID2 = $PID AND WindowIsNormalSize($winlist[$i][1], $iW, $iH) Then
					$hWnd = $winlist[$i][1]
					ExitLoop
				EndIf
			EndIf
		Next
		$iCurTimeMSec = $iCurTimeMSec + $iTimeTryMSec
	Until $hWnd <> 0 OR $iCurTimeMSec > $iTimeoutMSec
	Return $hWnd
EndFunc   ;==>GetHwndFromPID

Func WindowIsNormalSize($hWnd, $iW, $iH)
	Local $aSize = WinGetClientSize($hWnd)
	if @error <> 0 Then return True
	return $aSize[0] > $iW AND $aSize[1] > $iH
EndFunc   ;==>WindowIsNormalSize

Func SetWindowResizeStyleTimeout($hWnd, $iTimeoutMSec = 10000)
	Local $iCurTimeMSec = 0
	Local $iTimeTryMSec = 500
	While Not SetWindowResizeStyle($hWnd)
		Sleep($iTimeTryMSec)
		$iCurTimeMSec = $iCurTimeMSec + $iTimeTryMSec
		If $iCurTimeMSec > $iTimeoutMSec Then Return False
	Wend
	Return True
EndFunc   ;==>SetWindowResizeStyleTimeout

Func SetWindowResizeStyle($hWnd)
	Local $wStyle = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
	if @error = 1 Then return false
	$wStyle = BitOR($wStyle, $WS_MAXIMIZEBOX, $WS_THICKFRAME)
	if _WinAPI_SetWindowLong($hWnd, $GWL_STYLE, $wStyle) = 0 Then return false
	Local $wNewStyle = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
	if @error = 1 Then return false
	return $wStyle == $wNewStyle
EndFunc   ;==>SetWindowResizeStyle

Func MessageExit($text)
	MsgBox($MB_ICONINFORMATION, "Blue Wish Desire Resize", $text)
	Exit
EndFunc   ;==>MessageExit
