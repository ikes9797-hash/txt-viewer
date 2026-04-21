@echo off
REM TXT 뷰어 APK 원클릭 빌드 스크립트 (Windows)
REM 사용법: build.bat 더블클릭 또는 cmd에서 실행

setlocal enabledelayedexpansion
chcp 65001 > nul

echo.
echo +-----------------------------------------+
echo   📱 TXT 뷰어 APK 원클릭 빌더
echo +-----------------------------------------+
echo.

REM ── [1/6] 환경 체크 ────────────────────────────
echo [1/6] 환경 확인 중...

where node >nul 2>&1
if errorlevel 1 (
    echo    ❌ Node.js가 설치되어 있지 않습니다.
    echo       → https://nodejs.org 에서 설치하세요.
    pause
    exit /b 1
)
echo    ✅ Node.js OK

where java >nul 2>&1
if errorlevel 1 (
    echo    ❌ Java가 설치되어 있지 않습니다.
    echo       → https://adoptium.net/ 에서 JDK 17 설치하세요.
    pause
    exit /b 1
)
echo    ✅ Java OK

REM Android SDK 경로 탐지
if "%ANDROID_HOME%"=="" (
    if exist "%LOCALAPPDATA%\Android\Sdk" (
        set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
    ) else (
        echo    ❌ ANDROID_HOME 환경변수가 설정되지 않았습니다.
        echo       → Android Studio 설치 후 ANDROID_HOME 설정:
        echo       → 기본값: %LOCALAPPDATA%\Android\Sdk
        pause
        exit /b 1
    )
)
echo    ✅ ANDROID_HOME = %ANDROID_HOME%

REM ── [2/6] npm 패키지 설치 ─────────────────────
echo.
echo [2/6] npm 패키지 설치 중...
if not exist node_modules (
    call npm install
    if errorlevel 1 goto :error
) else (
    echo    ℹ️  node_modules 있음 → 건너뜀
)

REM ── [3/6] Android 플랫폼 추가 ─────────────────
echo.
echo [3/6] Android 플랫폼 추가 중...
if not exist android (
    call npx cap add android
    if errorlevel 1 goto :error
) else (
    echo    ℹ️  android 폴더 있음 → 건너뜀
)

REM local.properties 자동 생성
if not exist android\local.properties (
    REM 경로 슬래시 변환 (Gradle은 역슬래시 싫어함)
    set "SDK_PATH=%ANDROID_HOME:\=/%"
    echo sdk.dir=!SDK_PATH! > android\local.properties
    echo    ✅ android\local.properties 생성
)

REM ── [4/6] Capacitor 동기화 ────────────────────
echo.
echo [4/6] 웹 자산 동기화 중...
call npx cap sync android
if errorlevel 1 goto :error

REM ── [5/6] APK 빌드 ────────────────────────────
echo.
echo [5/6] APK 빌드 중... (최초 실행 시 Gradle 다운로드로 5~10분 소요)
cd android
call gradlew.bat assembleDebug
if errorlevel 1 (
    cd ..
    goto :error
)
cd ..

REM ── [6/6] APK 복사 ────────────────────────────
echo.
echo [6/6] APK 정리 중...
set "APK_SRC=android\app\build\outputs\apk\debug\app-debug.apk"
set "APK_DST=txt-viewer-debug.apk"

if exist "%APK_SRC%" (
    copy /Y "%APK_SRC%" "%APK_DST%" > nul
    echo.
    echo +-----------------------------------------+
    echo    ✅ 빌드 성공!
    echo +-----------------------------------------+
    echo.
    echo    📦 파일: %CD%\%APK_DST%
    echo.
    echo    ▶ 폰에 설치:
    echo      adb install %APK_DST%
    echo    또는 파일을 폰으로 복사해서 탭하면 설치됩니다.
    echo.
) else (
    goto :error
)

pause
exit /b 0

:error
echo.
echo ❌ 빌드 실패. 위 로그를 확인하세요.
pause
exit /b 1
