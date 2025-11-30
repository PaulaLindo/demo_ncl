# Flutter VS Code Extensions & Debug Checklist

## 🔧 **Required VS Code Extensions:**

### Essential Flutter Extensions:
1. **Flutter** (Dart-Code.flutter) - Main Flutter extension
2. **Dart** (Dart-Code.dart) - Dart language support
3. **Flutter Widget Snippets** (Nash.aware-vscode-flutter-snippets) - Widget snippets
4. **Flutter Tree** (dart-code.flutter-tree) - Widget tree visualization

### Web Development Extensions:
1. **Live Server** (ritwickdey.LiveServer) - Local web server
2. **Browser Preview** (austin.brave) - Browser in VS Code
3. **JavaScript Debugger** - Web debugging

## 🔍 **Debugging Steps:**

### 1. Check Flutter Environment:
```bash
flutter doctor -v
flutter config --list
```

### 2. Enable Debug Features:
```bash
flutter config --enable-web
flutter config --enable-lldb-debugging
```

### 3. Run with Debug Mode:
```bash
flutter run -d web-server --debug
flutter run -d web-server --profile
flutter run -d web-server --release
```

### 4. Verbose Logging:
```bash
flutter run -d web-server -v
flutter run -d web-server --verbose
```

### 5. Check Web Engine:
```bash
flutter build web -v
flutter build web --debug
flutter build web --profile
```

## 🐛 **Debug Commands to Try:**

### Check Flutter Web Components:
- Look for `flt-scene-host` creation
- Check web engine initialization
- Monitor console for errors

### Browser Console Debug:
1. Open DevTools (F12)
2. Check Console tab for Flutter errors
3. Look for Network requests
4. Check Elements panel for Flutter elements

### VS Code Debug Setup:
1. Install Flutter extensions
2. Create launch.json configuration
3. Set breakpoints in Flutter code
4. Use VS Code debugger

## 🎯 **Current Issue Analysis:**

### Problem: `flt-scene-host` never created
### Possible Causes:
1. Missing VS Code extensions
2. Flutter web engine not properly initialized
3. Debug mode disabled
4. Web components not loading
5. Environment configuration issue

### Debug Information Needed:
- Flutter initialization logs
- Web engine startup sequence
- Browser console errors
- Network request failures
- Extension installation status

## 📋 **Action Items:**

1. Install required VS Code extensions
2. Enable Flutter debugging features
3. Run with verbose logging
4. Check browser console for errors
5. Set breakpoints in Flutter initialization code
6. Monitor web engine startup process

## 🔧 **VS Code Debug Configuration:**

Create `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter Web",
            "type": "dart",
            "request": "launch",
            "program": "lib/main.dart",
            "deviceId": "web-server"
        }
    ]
}
```

## 🌐 **Web-Specific Debug:**

### Browser DevTools:
1. Console: Check for JavaScript errors
2. Network: Verify Flutter assets loading
3. Elements: Inspect Flutter DOM structure
4. Sources: Debug Flutter JavaScript code

### Flutter DevTools:
1. Run `flutter pub global activate devtools`
2. Run `flutter pub global run devtools`
3. Connect to web application
