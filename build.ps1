$ErrorActionPreference = "Stop"
Remove-Item -path build -recurse -ErrorAction 0
mkdir build
elm-make .\src\Main.elm --output build\elm.full.js
$native_call_success = $?
if (-not $native_call_success) {
  throw 'error making elm-make call'
}

uglifyjs build\elm.full.js --mangle --output build\elm.js
$native_call_success = $?
if (-not $native_call_success) {
  throw 'error making uglifyjs call'
}

xcopy /E .\src\Html\*.html build
xcopy /E .\src\Html\*.js build
xcopy /E .\src\Html\*.png build
xcopy /E .\src\Html\*.svg build
xcopy /E .\src\Html\*.jpg build
lessc .\src\Html\style.less build\style.css
