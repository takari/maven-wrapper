@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Apache Maven Wrapper Startup script
@REM
@REM This wrapper discoveries the jdk and the project base dir,
@REM then installs a maven dist and executes the corresponding mvn script.
@REM
@REM Environment Variable Prerequisites
@REM
@REM   JAVA_HOME        (Optional) Must point at your Java Development Kit installation.
@REM   MAVEN_BASEDIR    (Optional) Override the project base dir
@REM   MAVEN_BATCH_ECHO (Optional) Set to 'on' to enable the echoing of the batch commands.
@REM   MVNW_REPOURL     (Optional) A mirror url of the Maven Central repo
@REM   MVNW_USERNAME    (Optional) User name for donwloading the wrapper jar
@REM   MVNW_PASSWORD    (Optional) Passowrd for donwloading the wrapper jar
@REM   MVNW_VERBOSE     (Optional) if set to 'true', dump debug info
@REM   MVNW_OPTS        (Optional) parameters passed to the Java VM when running wrapper
@REM ----------------------------------------------------------------------------

@REM Begin all REM lines with '@' in case MAVEN_BATCH_ECHO is 'on'
@echo off
@REM enable echoing my setting MAVEN_BATCH_ECHO to 'on'
@if "%MAVEN_BATCH_ECHO%"=="on" echo %MAVEN_BATCH_ECHO%

@setlocal

set ERROR_CODE=0

@REM ==== START VALIDATION ====
if not "%JAVA_HOME%"=="" goto OkJHome
for %%i in (java.exe) do set "JAVACMD=%%~$PATH:i"
goto checkJCmd

:OkJHome
set "JAVACMD=%JAVA_HOME%\bin\java.exe"

:checkJCmd
if exist "%JAVACMD%" goto init

echo The JAVA_HOME environment variable is not defined correctly >&2
echo This environment variable is needed to run this program >&2
echo NB: JAVA_HOME should point to a JDK not a JRE >&2
goto error
@REM ==== END VALIDATION ====

:init

@REM Find the project basedir, i.e., the directory that contains the folder ".mvn".
@REM Fallback to current working directory if not found.

set "MAVEN_PROJECTBASEDIR=%MAVEN_BASEDIR%"
if not "%MAVEN_PROJECTBASEDIR%"=="" goto endDetectBaseDir

set "EXEC_DIR=%CD%"
set "WDIR=%EXEC_DIR%"

@REM Look for the --file switch and start the search for the .mvn directory from the specified
@REM POM location, if supplied.

set FILE_ARG=
:arg_loop
if "%~1" == "-f" (
  set "FILE_ARG=%~2"
  shift
  goto process_file_arg
)
if "%~1" == "--file" (
  set "FILE_ARG=%~2"
  shift
  goto process_file_arg
)
@REM If none of the above, skip the argument
shift
if not "%~1" == "" (
  goto arg_loop
) else (
  goto findBaseDir
)

:process_file_arg
if "%FILE_ARG%" == "" (
  goto findBaseDir
)
if not exist "%FILE_ARG%" (
  echo POM file "%FILE_ARG%" specified the -f/--file command-line argument does not exist >&2
  goto error
)
if exist "%FILE_ARG%\*" (
  set "POM_DIR=%FILE_ARG%"
) else (
  call :get_directory_from_file "%FILE_ARG%"
)
if not exist "%POM_DIR%" (
  echo Directory "%POM_DIR%" extracted from the -f/--file command-line argument "%FILE_ARG%" does not exist >&2
  goto error
)
set "WDIR=%POM_DIR%"
goto findBaseDir

:get_directory_from_file
set "POM_DIR=%~dp1"
:stripPomDir
if not "_%POM_DIR:~-1%"=="_\" goto pomDirStripped
set "POM_DIR=%POM_DIR:~0,-1%"
goto stripPomDir
:pomDirStripped
exit /b

:findBaseDir
cd /d "%WDIR%"
:findBaseDirLoop
if exist "%WDIR%\.mvn" goto baseDirFound
cd ..
IF "%WDIR%"=="%CD%" goto baseDirNotFound
set "WDIR=%CD%"
goto findBaseDirLoop

:baseDirFound
set "MAVEN_PROJECTBASEDIR=%WDIR%"
cd /d "%EXEC_DIR%"
goto endDetectBaseDir

:baseDirNotFound
if "_%EXEC_DIR:~-1%"=="_\" set "EXEC_DIR=%EXEC_DIR:~0,-1%"
set "MAVEN_PROJECTBASEDIR=%EXEC_DIR%"
cd "%EXEC_DIR%"

:endDetectBaseDir

set "WRAPPER_JAR=%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar"
set WRAPPER_LAUNCHER=org.apache.maven.wrapper.MavenWrapperMain

@REM Begin of extension
set DOWNLOAD_URL=https://repo.maven.apache.org/maven2/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar
if not "%MVNW_REPOURL%" == "" (
  SET "DOWNLOAD_URL=%MVNW_REPOURL%/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar"
)

FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.properties") DO (
  IF "%%A"=="wrapperUrl" SET DOWNLOAD_URL=%%B
)

@REM Extension to allow automatically downloading the maven-wrapper.jar from Maven-central
@REM This allows using the maven wrapper in projects that prohibit checking in binary data.
if exist %WRAPPER_JAR% (
  if "%MVNW_VERBOSE%" == "true" (
    echo Found %WRAPPER_JAR%
  )
) else (
  if "%MVNW_VERBOSE%" == "true" (
    echo Couldn't find %WRAPPER_JAR%, downloading it from: %DOWNLOAD_URL%
  )

  powershell -Command "&{"^
		"$webclient = new-object System.Net.WebClient;"^
		"if (-not ([string]::IsNullOrEmpty('%MVNW_USERNAME%') -and [string]::IsNullOrEmpty('%MVNW_PASSWORD%'))) {"^
		"$webclient.Credentials = new-object System.Net.NetworkCredential('%MVNW_USERNAME%', '%MVNW_PASSWORD%');"^
		"}"^
		"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webclient.DownloadFile('%DOWNLOAD_URL%', '%WRAPPER_JAR%')"^
		"}"
  if "%MVNW_VERBOSE%" == "true" (
    echo Finished downloading %WRAPPER_JAR%
  )
)
@REM End of extension

if not "%MVNW_OPTS%" == "" (
  if "%JAVA_TOOL_OPTIONS%" == "" (
    SET "JAVA_TOOL_OPTIONS=%MVNW_OPTS%"
  ) else (
    SET "JAVA_TOOL_OPTIONS=%JAVA_TOOL_OPTIONS% %MVNW_OPTS%"
  )
)

for /F "delims=" %%A IN ('cmd.exe /c ""%JAVACMD%" -classpath "%WRAPPER_JAR%" %WRAPPER_LAUNCHER%"') DO SET "MAVEN_HOME=%%A"

if "%MAVEN_HOME%" == "" (
  echo Error: maven home is empty. >&2
  goto error
) else (
  "%MAVEN_HOME%/bin/mvn.cmd" %*
)
if ERRORLEVEL 1 goto error
goto end

:error
set ERROR_CODE=1

:end
@endlocal & set ERROR_CODE=%ERROR_CODE%

exit /B %ERROR_CODE%
