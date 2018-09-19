@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  engine startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Add default JVM options here. You can also use JAVA_OPTS and ENGINE_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windows variants

if not "%OS%" == "Windows_NT" goto win9xME_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\engine-3.0.jar;%APP_HOME%\lib\jsr305.jar;%APP_HOME%\lib\princess-assertionless.jar;%APP_HOME%\lib\org.osgi.core.jar;%APP_HOME%\lib\scala-library.jar;%APP_HOME%\lib\guava.jar;%APP_HOME%\lib\com.microsoft.z3.jar;%APP_HOME%\lib\llvm-platform.jar;%APP_HOME%\lib\smt-parser.jar;%APP_HOME%\lib\llvm.jar;%APP_HOME%\lib\llvm-linux-x86.jar;%APP_HOME%\lib\llvm-macosx-x86_64.jar;%APP_HOME%\lib\jopt-simple.jar;%APP_HOME%\lib\java-cup-runtime.jar;%APP_HOME%\lib\javolution-core-java.jar;%APP_HOME%\lib\common.jar;%APP_HOME%\lib\smtinterpol.jar;%APP_HOME%\lib\javasmt.jar;%APP_HOME%\lib\javacpp.jar;%APP_HOME%\lib\llvm-linux-x86_64.jar;%APP_HOME%\lib\org.osgi.compendium.jar;%APP_HOME%\lib\XMLReport.jar;%APP_HOME%\lib\build-capture.jar;%APP_HOME%\lib\mod-commons-3.0.jar;%APP_HOME%\lib\guava-19.0.jar;%APP_HOME%\lib\jsr305-3.0.0.jar;%APP_HOME%\lib\truth-0.30.jar;%APP_HOME%\lib\eclipse-collections-api-9.1.0.jar;%APP_HOME%\lib\eclipse-collections-9.1.0.jar;%APP_HOME%\lib\junit-4.10.jar;%APP_HOME%\lib\error_prone_annotations-2.0.8.jar;%APP_HOME%\lib\hamcrest-core-1.1.jar

@rem Execute engine
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %ENGINE_OPTS%  -classpath "%CLASSPATH%" cn.edu.thu.tsmart.TsmartCheckerMain %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable ENGINE_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%ENGINE_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
