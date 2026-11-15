# Spring Boot 3.2.0 + Spring Security Hello World

一个可导入 IntelliJ IDEA 的完整 Maven 示例项目，包含 JSON 用户名/密码登录、基于 HTTP Session 的认证，以及受保护的 Hello World 接口。

## 环境要求

- **JDK 17 或 JDK 21**（项目 Java 编译目标为 17）
- **Maven 3.6.3+**，或 IntelliJ IDEA 自带的 Maven
- 首次运行需要网络下载 Maven 依赖
- **不需要 MySQL、Redis 或前端**

## 一、启动

在根目录（包含 `pom.xml` 的目录）运行：

```bash
mvn clean test
mvn spring-boot:run
```

也可以在 Windows 上双击 `start-windows.bat`（需要 Java 和 Maven 已加入 PATH）；或者在 IntelliJ IDEA 打开 `pom.xml`，运行 `SecurityHelloApplication.main()`。

启动成功后，服务地址为 `http://localhost:8080`。

## 二、接口说明

| 方法 | 路径 | 认证要求 | 说明 |
| --- | --- | --- | --- |
| `POST` | `/api/login` | 不需要 | JSON 用户名密码登录；成功后创建 `JSESSIONID` Cookie |
| `GET` | `/api/hello` | 必须登录 | 返回纯文本 `Hello World` |
| `POST` | `/api/logout` | 支持已登录用户 | 注销，成功返回 HTTP 204 |

演示账号：`test`，密码：`123456`。

请求登录体：

```json
{"username":"test","password":"123456"}
```

## 三、Windows PowerShell 测试（推荐）

**先启动服务，再打开一个 PowerShell 窗口**，依次执行：

### 1. 未登录访问：应返回 401

```powershell
try { Invoke-WebRequest http://localhost:8080/api/hello } catch { $_.Exception.Response.StatusCode }
```

### 2. 登录：应返回 `Login successful`

```powershell
$body = @{ username = 'test'; password = '123456' } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/api/login' -ContentType 'application/json' -Body $body -SessionVariable loginSession
```

`-SessionVariable loginSession` 用来记住服务端返回的 `JSESSIONID` Cookie。

### 3. 带上登录会话：应返回 `Hello World`

```powershell
Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/api/hello' -WebSession $loginSession
```

### 4. 注销

```powershell
Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/api/logout' -WebSession $loginSession
```

注销后继续使用旧 Session 访问 `/api/hello`，应返回 HTTP 401。

## 四、使用 curl 测试（macOS、Linux、Git Bash）

```bash
# 未登录 -> HTTP 401
curl -i http://localhost:8080/api/hello

# 登录并把 Cookie 保存在 cookie.txt
curl -i -c cookie.txt -H 'Content-Type: application/json' \
  -d '{"username":"test","password":"123456"}' \
  http://localhost:8080/api/login

# 携带 Cookie -> Hello World
curl -i -b cookie.txt http://localhost:8080/api/hello

# 注销 -> HTTP 204
curl -i -b cookie.txt -X POST http://localhost:8080/api/logout
```

## 五、项目结构

```text
springboot-security-hello/
├── pom.xml
├── start-windows.bat
├── README.md
├── src/
│   ├── main/
│   │   ├── java/com/example/securityhello/
│   │   │   ├── SecurityHelloApplication.java
│   │   │   ├── api/
│   │   │   │   ├── AuthController.java
│   │   │   │   ├── HelloController.java
│   │   │   │   └── LoginRequest.java
│   │   │   └── config/SecurityConfig.java
│   │   └── resources/application.properties
│   └── test/java/com/example/securityhello/
│       └── SecurityHelloApplicationTests.java
└── .gitignore
```

## 六、设计说明和注意事项

- Spring Security 6 + `DaoAuthenticationProvider` 验证用户密码，密码由 BCrypt 编码储存于内存用户对象中。
- 登录成功调用 `SecurityContextRepository.saveContext(...)` 保存认证信息至 HTTP Session，因此后续请求只需传回 `JSESSIONID`。
- `.httpBasic()` 和默认 HTML 登录表单均被禁用，使用自定义 JSON 登录 API。
- 本项目为**本地演示**：为了便于 PowerShell、curl、Postman 测试，显式禁用了 CSRF。**使用 Cookie Session 的生产环境不能直接沿用此配置**，应开启并正确处理 CSRF、使用 HTTPS、移除固定账号密码、设置 Session 策略并限制访问频率。
- `pom.xml` 精确锁定 Spring Boot **3.2.0**，没有改成其他版本。

如果端口被占用，可将 `src/main/resources/application.properties` 中的 `server.port=8080` 改成其他端口。
