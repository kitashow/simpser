;имя приложения
!define PRODUCT_NAME "Tests simpser"
;версия приложения
;!define PRODUCT_VERSION "0.0001"
;папка, где будут храниться исходные файлы, подлежащие сжатию.
;!define pkgdir "d:\package"

;новый интерфейс
!include "MUI.nsh"

;степень сжатия
SetCompressor /SOLID lzma

;Константа MUI_ABORTWARNING определяет, выдавать ли предупреждение при закрытии инсталятора пользователем. 
;По типу такого: «Вы действительно хотите прервать установку ..бла бла » и кнопки «да» и «нет».
!define MUI_ABORTWARNING

;Константа MUI_ICON определяет значок инсталятора:
!define MUI_ICON "..\simpser.ico" ;"${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"

;Если мы хотим, чтобы все страницы нашего скрипта были на русском языке, необходимо также добавить вызов макроса локализации:
!insertmacro MUI_LANGUAGE "Russian"

;Команда Name задает название кнопки инсталлятора на панели задач. В нашей случае мы будем использовать её в следующем виде:
Name "${PRODUCT_NAME}"

;Команда Caption задает заголовок окна инсталятора. Её мы зададим равной
Caption "Установка ${PRODUCT_NAME}" ;убрал[ ${PRODUCT_VERSION}"]

;Имя файла инсталлятора задается командой OutFile
OutFile "setup_simpser.exe"

;ShowInstDetails, говорит компилятору, что в окне хода выполнения инсталлятора должен 
;быть виден протокол его действий. 
;По умолчанию он скрыт, и появляется только по нажатию кнопки «Детали». 
;Возможные значения: hide, show и nevershow. Значению по умолчанию соответствует hide, 
;nevershow отключает и вышеупомянутую кнопку, а мы используем show — показывать.
ShowInstDetails hide

InstallDir $DESKTOP\TestsSimpser
RequestExecutionLevel user

Page components
Page directory
Page instfiles

Section "" ;Имя оставляем пустым, чтобы не было показано в списке компонентов

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
Section "Создать ярлык на рабочем столе"

  CreateShortcut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\simpser.exe" "" "$INSTDIR\simpser.exe" 0
  
SectionEnd

Section "Ярлыки в меню Windows"

  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\simpser.exe" "" "$INSTDIR\simpser.exe" 0
  
SectionEnd

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


