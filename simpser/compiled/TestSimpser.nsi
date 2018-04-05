;��� ����������
!define PRODUCT_NAME "Tests simpser"
;������ ����������
!define PRODUCT_VERSION "0.0.0.1"
;�����, ��� ����� ��������� �������� �����, ���������� ������.
;!define pkgdir "d:\package"

;����� ���������
!include "MUI.nsh"

;������� ������
SetCompressor /SOLID lzma

;��������� MUI_ABORTWARNING ����������, �������� �� �������������� ��� �������� ����������� �������������. 
;�� ���� ������: ��� ������������� ������ �������� ��������� ..��� ��� � � ������ ��� � ����.
!define MUI_ABORTWARNING

;��������� MUI_ICON ���������� ������ �����������:
!define MUI_ICON "..\simpser_setup.ico" ;"${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"

;���� �� �����, ����� ��� �������� ������ ������� ���� �� ������� �����, ���������� ����� �������� ����� ������� �����������:
!insertmacro MUI_LANGUAGE "Russian"

;Name ������ �������� ������ ������������ �� ������ �����. � ����� ������ �� ����� ������������ � � ��������� ����:
Name "${PRODUCT_NAME}"

;Caption ������ ��������� ���� �����������. Ÿ �� ������� ������
Caption "��������� ${PRODUCT_NAME}" ;�����[ ${PRODUCT_VERSION}"]

;��� ����� ������������ �������� �������� OutFile
OutFile "setup_simpser.exe"

VIProductVersion ${PRODUCT_VERSION}
VIAddVersionKey ProductName "${PRODUCT_NAME}"
VIAddVersionKey Comments "���������� ${PRODUCT_NAME}, ������� ��������� ����."
VIAddVersionKey CompanyName "������� �������"
VIAddVersionKey LegalCopyright "������� �������"
;VIAddVersionKey FileDescription "${PRODUCT_NAME}"
;VIAddVersionKey FileVersion ${PRODUCT_VERSION}
;VIAddVersionKey ProductVersion ${PRODUCT_VERSION}
;VIAddVersionKey InternalName "simser.exe"
;VIAddVersionKey LegalTrademarks "������� �������"
;VIAddVersionKey OriginalFilename "simser.exe"

;ShowInstDetails, ������� �����������, ��� � ���� ���� ���������� ������������ ������ 
;���� ����� �������� ��� ��������. 
;�� ��������� �� �����, � ���������� ������ �� ������� ������ �������. 
;��������� ��������: hide, show � nevershow. �������� �� ��������� ������������� hide, 
;nevershow ��������� � �������������� ������, � �� ���������� show � ����������.
ShowInstDetails hide

InstallDir $DESKTOP\TestsSimpser
RequestExecutionLevel user

Page components
Page directory
Page instfiles

Section "" ;��� ��������� ������, ����� �� ���� �������� � ������ �����������

  SetOutPath $INSTDIR
  File A_resources.zip
  File simpser.exe
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\simpser "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "������� ����� �� ������� �����" SLink

  CreateShortcut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\simpser.exe" "" "$INSTDIR\simpser.exe" 0
  
SectionEnd

Section "������ � ���� Windows" SStMnLinks

  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\simpser.exe" "" "$INSTDIR\simpser.exe" 0
  
SectionEnd

Section "�������� ���������� ������" SDbgVer

  File simpser_dbg.exe
  
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SLink} "����� ��������� ����� �������� ������� ����� �� ������� �����."
	!insertmacro MUI_DESCRIPTION_TEXT ${SStMnLinks} "����� ��������� � ���� ���� ����� ������� �� ������ � �������� ���������."
	!insertmacro MUI_DESCRIPTION_TEXT ${SDbgVer} "��������� ����� ���������� ������, ����� �������� ���� �����������. ������� �� ��� �������� �� �����."
!insertmacro MUI_FUNCTION_DESCRIPTION_END
	

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
  DeleteRegKey HKLM SOFTWARE\simpser

  ; Remove files and uninstaller
  Delete $INSTDIR\*.*
  ;Delete $INSTDIR\A_resources.zip
  ;Delete $INSTDIR\simpser.exe
  ;Delete $INSTDIR\uninstall.exe
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  
  RMDir "$INSTDIR"

SectionEnd


