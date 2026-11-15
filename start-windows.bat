@echo off
cd /d "%~dp0"
where java >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Java not found. Install JDK 17 or JDK 21 and set JAVA_HOME.
    pause
    exit /b 1
)
where mvn >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Maven not found. Install Maven 3.6.3+ or run via IntelliJ IDEA.
    pause
    exit /b 1
)
echo Starting Spring Boot 3.2.0 on http://localhost:8080 ...
call mvn spring-boot:run
pause
