# TXT 뷰어 · Android APK

React 기반 TXT 뷰어를 Android APK로 빌드합니다.

---

## 🎯 원터치 빌드 (3가지 선택)

### ⭐ 방법 1: 클라우드 빌드 (가장 쉬움, 로컬 설치 0개)

GitHub 계정만 있으면 **버튼 하나로** APK가 만들어집니다.

1. **GitHub 계정 만들기** → https://github.com (무료)
2. 새 저장소 만들기 (`New repository` → 이름 아무거나 → `Create`)
3. 이 프로젝트 폴더 통째로 업로드:
   - 저장소 페이지에서 `uploading an existing file` 링크 클릭
   - 이 폴더(`txt-viewer-app/`) 안의 **모든 파일과 폴더** 드래그 앤 드롭
   - (중요: `.github` 폴더도 함께. 숨김 파일 보이게 해야 함)
   - `Commit changes` 클릭
4. 업로드 완료 후 저장소의 **`Actions`** 탭 클릭
5. 왼쪽 **`Build APK`** 선택 → 오른쪽 **`Run workflow`** 버튼 → **`Run workflow`** 한 번 더
6. 초록색 체크 뜨면 (약 5분) 실행 결과 페이지 들어가서
7. 하단 **`Artifacts`** 섹션 → `txt-viewer-apk` 클릭 → 다운로드
8. 압축 풀면 `txt-viewer-debug.apk` 나옴. 폰에 옮겨서 설치!

> 💡 코드 수정할 때마다 GitHub에 파일 올리면 자동으로 새 APK가 빌드됩니다.

---

### ⭐ 방법 2: 로컬 원클릭 스크립트

사전에 JDK 17 + Node.js + Android Studio 설치되어 있으면:

**Mac / Linux**:
```bash
chmod +x build.sh
./build.sh
```

**Windows**:
```
build.bat 더블클릭
```

완료되면 폴더에 `txt-viewer-debug.apk` 파일이 생깁니다.

> 💡 스크립트가 알아서 `npm install`, `cap add android`, `cap sync`, `gradlew assembleDebug`까지 다 해줍니다. 환경변수/경로 문제도 자동 감지.

---

### 방법 3: 수동 빌드 (뭐가 문제인지 직접 보고 싶을 때)

```bash
npm install
npx cap add android
npx cap sync android
cd android
./gradlew assembleDebug    # Mac/Linux
gradlew.bat assembleDebug  # Windows
```

APK 위치: `android/app/build/outputs/apk/debug/app-debug.apk`

---

## 📋 사전 준비 (방법 2·3 전용)

방법 1(GitHub Actions)을 쓰면 아래 설치 필요 없음.

### 1. Node.js 18+
https://nodejs.org → LTS 설치

### 2. JDK 17
- Mac: `brew install --cask temurin@17`
- Windows: https://adoptium.net/ 에서 Temurin 17
- Linux: `sudo apt install openjdk-17-jdk`

### 3. Android Studio
https://developer.android.com/studio

설치 후 첫 실행 시 SDK Manager에서:
- Android SDK Platform 34
- Android SDK Build-Tools 34.0.0+
- Android SDK Command-line Tools
- Android SDK Platform-Tools

환경변수:
- `ANDROID_HOME`
  - Mac: `~/Library/Android/sdk`
  - Windows: `%LOCALAPPDATA%\Android\Sdk`
  - Linux: `~/Android/Sdk`

---

## 📱 APK 폰에 설치

**방법 A**: USB 케이블
```bash
adb install txt-viewer-debug.apk
```

**방법 B**: 수동
1. APK 파일을 폰으로 복사 (Google Drive, 카톡 나와의 채팅, USB 등)
2. 폰 파일 앱에서 APK 탭
3. "알 수 없는 앱 설치 허용" → 설치

---

## 🔐 배포용 릴리스 APK (선택)

### 서명 키 생성 (최초 1회)
```bash
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias txtviewer
```

`android/app/build.gradle`에 추가:
```gradle
android {
    signingConfigs {
        release {
            storeFile file('../../my-release-key.jks')
            storePassword '비밀번호'
            keyAlias 'txtviewer'
            keyPassword '비밀번호'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

빌드:
```bash
cd android && ./gradlew assembleRelease
```

---

## 🛠 앱 아이콘 · 스플래시 커스터마이즈

1. `resources/icon.png` (1024×1024), `resources/splash.png` (2732×2732) 준비
2. `npm install -g @capacitor/assets`
3. `npx @capacitor/assets generate --android`

---

## 📦 오프라인 전용 앱으로 만들기

현재 React/Babel/Google Fonts를 CDN에서 로드(최초 실행 시 인터넷 필요). 완전 오프라인:

1. 아래 파일 다운받아 `www/lib/`에 저장:
   - https://unpkg.com/react@18.3.1/umd/react.production.min.js
   - https://unpkg.com/react-dom@18.3.1/umd/react-dom.production.min.js
   - https://unpkg.com/@babel/standalone@7.29.0/babel.min.js
2. `www/index.html`의 `https://unpkg.com/...` 경로들을 `lib/파일명.js`로 수정
3. 다시 빌드

---

## 📁 프로젝트 구조

```
txt-viewer-app/
├── .github/workflows/build-apk.yml   ← GitHub Actions (방법 1)
├── build.sh                          ← Mac/Linux 원클릭 (방법 2)
├── build.bat                         ← Windows 원클릭 (방법 2)
├── www/                              ← 실제 앱 코드
│   ├── index.html
│   ├── tokens.js
│   ├── sample-text.js
│   ├── icons.jsx
│   └── live.jsx                      ← 메인 로직
├── package.json
├── capacitor.config.json
└── README.md
```

---

## ❓ 트러블슈팅

**스크립트가 `ANDROID_HOME을 찾을 수 없습니다`**
→ Android Studio 실행 → Settings → Appearance & Behavior → System Settings → Android SDK에서 경로 확인 후 환경변수 설정.

**`Unsupported class file major version 66`**
→ JDK 21로 빌드 중인데 Gradle이 17 원함. `java --version` 확인 후 JDK 17 사용.

**`SDK location not found`**
→ `android/local.properties` 없거나 경로 틀림. 스크립트로 빌드하면 자동 생성됨.

**`gradlew: permission denied` (Mac/Linux)**
→ `chmod +x android/gradlew`

**GitHub Actions가 실패**
→ 저장소 Actions 탭에서 실패한 빌드 클릭 → 빨간 X 단계 확장해서 에러 확인.

**앱 열었는데 흰 화면**
→ 첫 실행은 CDN에서 React 로드 필요. 인터넷 켜고 재실행. 또는 "오프라인 전용" 섹션 참고.

---

## 💡 앱 기능

- TXT 파일 업로드 & 읽기 (UTF-8)
- 페이지/스크롤 모드
- 화이트/세피아/다크 테마
- 글자 크기, 줄 간격, 명조/고딕 글꼴
- 검색 & 하이라이트
- 북마크
- 설정 자동 저장 (localStorage)
- 샘플 책 포함

---

막히면 에러 메시지 그대로 복사해서 질문 주세요.
