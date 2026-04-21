#!/usr/bin/env bash
# TXT 뷰어 APK 원클릭 빌드 스크립트 (Mac / Linux)
# 사용법: ./build.sh

set -e

# 색상
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}┌─────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│   📱 TXT 뷰어 APK 원클릭 빌더          │${NC}"
echo -e "${BLUE}└─────────────────────────────────────────┘${NC}"
echo ""

# ── 환경 체크 ──────────────────────────────────
echo -e "${YELLOW}[1/6] 환경 확인 중...${NC}"

check_cmd() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${RED}❌ $1 이(가) 설치되어 있지 않습니다.${NC}"
    echo -e "   $2"
    exit 1
  fi
  echo -e "   ✅ $1 OK"
}

check_cmd node "→ https://nodejs.org 에서 Node.js 18 이상 설치하세요."
check_cmd npm  "→ Node.js와 함께 설치됩니다."
check_cmd java "→ JDK 17 설치: brew install --cask temurin@17 (Mac) / sudo apt install openjdk-17-jdk (Linux)"

JAVA_MAJOR=$(java -version 2>&1 | head -1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')
if [ "$JAVA_MAJOR" -lt 17 ]; then
  echo -e "${RED}❌ JDK 17 이상이 필요합니다. (현재: $JAVA_MAJOR)${NC}"
  exit 1
fi
echo -e "   ✅ JDK $JAVA_MAJOR"

# Android SDK 경로 탐지
if [ -z "$ANDROID_HOME" ]; then
  if [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
  elif [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
  else
    echo -e "${RED}❌ Android SDK를 찾을 수 없습니다.${NC}"
    echo -e "   → Android Studio를 설치하고 ANDROID_HOME 환경변수를 설정하세요."
    echo -e "   → Mac: export ANDROID_HOME=~/Library/Android/sdk"
    echo -e "   → Linux: export ANDROID_HOME=~/Android/Sdk"
    exit 1
  fi
fi
echo -e "   ✅ ANDROID_HOME = $ANDROID_HOME"

# ── 의존성 설치 ────────────────────────────────
echo ""
echo -e "${YELLOW}[2/6] npm 패키지 설치 중...${NC}"
if [ ! -d "node_modules" ]; then
  npm install
else
  echo -e "   ℹ️  node_modules 있음 → 건너뜀 (새로 받으려면 삭제 후 재실행)"
fi

# ── Android 플랫폼 추가 ───────────────────────
echo ""
echo -e "${YELLOW}[3/6] Android 플랫폼 추가 중...${NC}"
if [ ! -d "android" ]; then
  npx cap add android
else
  echo -e "   ℹ️  android/ 폴더 있음 → 건너뜀"
fi

# local.properties 자동 생성
if [ ! -f "android/local.properties" ]; then
  echo "sdk.dir=$ANDROID_HOME" > android/local.properties
  echo -e "   ✅ android/local.properties 생성"
fi

# ── Capacitor 동기화 ──────────────────────────
echo ""
echo -e "${YELLOW}[4/6] 웹 자산 동기화 중...${NC}"
npx cap sync android

# ── APK 빌드 ──────────────────────────────────
echo ""
echo -e "${YELLOW}[5/6] APK 빌드 중... (최초 실행 시 Gradle 다운로드로 5~10분 소요)${NC}"
cd android
chmod +x gradlew
./gradlew assembleDebug
cd ..

# ── APK 복사 ──────────────────────────────────
echo ""
echo -e "${YELLOW}[6/6] APK 정리 중...${NC}"
APK_SRC="android/app/build/outputs/apk/debug/app-debug.apk"
APK_DST="txt-viewer-debug.apk"

if [ -f "$APK_SRC" ]; then
  cp "$APK_SRC" "$APK_DST"
  APK_SIZE=$(du -h "$APK_DST" | cut -f1)
  echo ""
  echo -e "${GREEN}┌─────────────────────────────────────────┐${NC}"
  echo -e "${GREEN}│   ✅ 빌드 성공!                         │${NC}"
  echo -e "${GREEN}└─────────────────────────────────────────┘${NC}"
  echo ""
  echo -e "   📦 파일: ${BLUE}$(pwd)/$APK_DST${NC}"
  echo -e "   📏 크기: $APK_SIZE"
  echo ""
  echo -e "   ${YELLOW}▶ 폰에 설치:${NC}"
  echo -e "     adb install $APK_DST"
  echo -e "   또는 파일을 폰으로 복사해서 탭하면 설치됩니다."
  echo ""
else
  echo -e "${RED}❌ APK 파일을 찾을 수 없습니다. 위 빌드 로그를 확인하세요.${NC}"
  exit 1
fi
