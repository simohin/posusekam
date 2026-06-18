package ru.simohin.posusekam.auth.controller

import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class TestLoginController {

    @GetMapping("/test-login", produces = [MediaType.TEXT_HTML_VALUE])
    fun testLoginPage(): String {
        val d = "$"
        return """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>POSUSEKAM | Google Auth Tester</title>
                <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
                <script src="https://accounts.google.com/gsi/client" async defer></script>
                <style>
                    :root {
                        --bg: #0a0b0d;
                        --card-bg: rgba(255, 255, 255, 0.03);
                        --border: rgba(255, 255, 255, 0.08);
                        --primary: #4f46e5;
                        --primary-glow: rgba(79, 70, 229, 0.4);
                        --accent: #06b6d4;
                        --accent-glow: rgba(6, 182, 212, 0.4);
                        --text: #f3f4f6;
                        --text-muted: #9ca3af;
                        --success: #10b981;
                        --error: #ef4444;
                    }
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }
                    body {
                        font-family: 'Outfit', sans-serif;
                        background-color: var(--bg);
                        color: var(--text);
                        min-height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        padding: 2rem;
                        overflow-x: hidden;
                        background-image: 
                            radial-gradient(circle at 10% 20%, rgba(79, 70, 229, 0.08) 0%, transparent 40%),
                            radial-gradient(circle at 90% 80%, rgba(6, 182, 212, 0.08) 0%, transparent 40%);
                    }
                    .container {
                        width: 100%;
                        max-width: 800px;
                        background: var(--card-bg);
                        border: 1px solid var(--border);
                        backdrop-filter: blur(20px);
                        border-radius: 24px;
                        padding: 3rem;
                        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
                        transition: all 0.3s ease;
                    }
                    h1 {
                        font-size: 2.5rem;
                        font-weight: 700;
                        margin-bottom: 0.5rem;
                        background: linear-gradient(135deg, #fff 0%, #a5b4fc 100%);
                        -webkit-background-clip: text;
                        -webkit-text-fill-color: transparent;
                        text-align: center;
                    }
                    .subtitle {
                        color: var(--text-muted);
                        font-size: 1rem;
                        text-align: center;
                        margin-bottom: 2.5rem;
                    }
                    .grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 2rem;
                        margin-bottom: 2.5rem;
                    }
                    @media (max-width: 640px) {
                        .grid {
                            grid-template-columns: 1fr;
                        }
                    }
                    .card {
                        background: rgba(255, 255, 255, 0.015);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        padding: 2rem;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: space-between;
                        min-height: 200px;
                        transition: transform 0.2s, border-color 0.2s;
                    }
                    .card:hover {
                        transform: translateY(-2px);
                        border-color: rgba(79, 70, 229, 0.3);
                    }
                    .card-title {
                        font-size: 1.1rem;
                        font-weight: 600;
                        margin-bottom: 1rem;
                        text-align: center;
                        color: #a5b4fc;
                    }
                    .btn {
                        background: linear-gradient(135deg, var(--primary) 0%, #6366f1 100%);
                        color: #fff;
                        border: none;
                        padding: 0.75rem 1.5rem;
                        border-radius: 12px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.2s;
                        box-shadow: 0 4px 12px var(--primary-glow);
                        text-decoration: none;
                        display: inline-block;
                        text-align: center;
                    }
                    .btn:hover {
                        transform: translateY(-1px);
                        box-shadow: 0 6px 16px var(--primary-glow);
                        filter: brightness(1.1);
                    }
                    .results-section {
                        border-top: 1px solid var(--border);
                        padding-top: 2rem;
                    }
                    .section-title {
                        font-size: 1.25rem;
                        font-weight: 600;
                        margin-bottom: 1.5rem;
                        color: #fff;
                        display: flex;
                        align-items: center;
                        gap: 0.5rem;
                    }
                    .parameter-group {
                        margin-bottom: 1.5rem;
                    }
                    .label {
                        font-size: 0.85rem;
                        font-weight: 600;
                        color: var(--text-muted);
                        margin-bottom: 0.5rem;
                        text-transform: uppercase;
                        letter-spacing: 0.05em;
                    }
                    .value-box {
                        background: rgba(0, 0, 0, 0.3);
                        border: 1px solid var(--border);
                        border-radius: 8px;
                        padding: 1rem;
                        font-family: monospace;
                        font-size: 0.9rem;
                        word-break: break-all;
                        white-space: pre-wrap;
                        position: relative;
                        max-height: 200px;
                        overflow-y: auto;
                        color: #38bdf8;
                    }
                    .token-decoded {
                        color: #a78bfa;
                        margin-top: 0.5rem;
                        font-size: 0.85rem;
                    }
                    .copy-btn {
                        position: absolute;
                        top: 0.5rem;
                        right: 0.5rem;
                        background: rgba(255, 255, 255, 0.1);
                        border: none;
                        color: #fff;
                        padding: 0.25rem 0.5rem;
                        font-size: 0.75rem;
                        border-radius: 4px;
                        cursor: pointer;
                        transition: background 0.2s;
                    }
                    .copy-btn:hover {
                        background: rgba(255, 255, 255, 0.2);
                    }
                    .alert {
                        padding: 1rem;
                        border-radius: 8px;
                        margin-bottom: 1.5rem;
                        font-size: 0.95rem;
                        text-align: center;
                    }
                    .alert-success {
                        background: rgba(16, 185, 129, 0.1);
                        border: 1px solid rgba(16, 185, 129, 0.2);
                        color: #34d399;
                    }
                    .alert-info {
                        background: rgba(59, 130, 246, 0.1);
                        border: 1px solid rgba(59, 130, 246, 0.2);
                        color: #60a5fa;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>POSUSEKAM</h1>
                    <p class="subtitle">Google Authentication Testing Utility</p>

                    <div id="alert-container"></div>

                    <div class="grid">
                        <!-- Flow 1: OAuth2 Redirect -->
                        <div class="card">
                            <div class="card-title">1. OAuth2 Code Flow (Redirect)</div>
                            <p style="font-size: 0.9rem; color: var(--text-muted); text-align: center; margin-bottom: 1.5rem;">
                                Перенаправляет на Google OAuth для получения Auth Code.
                            </p>
                            <button class="btn" onclick="startRedirectFlow()">Запустить флоу</button>
                        </div>

                        <!-- Flow 2: Sign-In with Google -->
                        <div class="card">
                            <div class="card-title">2. Google Sign-In Button (ID Token)</div>
                            <p style="font-size: 0.9rem; color: var(--text-muted); text-align: center; margin-bottom: 1.5rem;">
                                Интегрированная кнопка "Войти с Google". Возвращает ID Token на месте.
                            </p>
                            <div id="g_id_onload"
                                 data-client_id="365281398460-i7itvaccbd4gdhftt76pbkdnqlph85o2.apps.googleusercontent.com"
                                 data-callback="handleCredentialResponse"
                                 data-auto_prompt="false">
                            </div>
                            <div class="g_id_signin" data-type="standard" data-shape="pill" data-theme="filled_blue" data-size="large"></div>
                        </div>
                    </div>

                    <div class="results-section" id="results-panel" style="display: none;">
                        <div class="section-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--accent);"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
                            Переданные параметры
                        </div>

                        <div class="parameter-group" id="group-code" style="display: none;">
                            <div class="label">Authorization Code (code)</div>
                            <div class="value-box">
                                <span id="val-code"></span>
                                <button class="copy-btn" onclick="copyText('val-code')">Copy</button>
                            </div>
                        </div>

                        <div class="parameter-group" id="group-redirect">
                            <div class="label">Redirect URI</div>
                            <div class="value-box">
                                <span id="val-redirect"></span>
                                <button class="copy-btn" onclick="copyText('val-redirect')">Copy</button>
                            </div>
                        </div>

                        <div class="parameter-group" id="group-idtoken" style="display: none;">
                            <div class="label">Google ID Token (credential)</div>
                            <div class="value-box">
                                <span id="val-idtoken"></span>
                                <button class="copy-btn" onclick="copyText('val-idtoken')">Copy</button>
                            </div>
                            <div class="token-decoded" id="val-idtoken-decoded"></div>
                        </div>

                        <div class="parameter-group" id="group-backend" style="display: none;">
                            <div class="label">Ответ бэкенда (/auth/v1/google)</div>
                            <div class="value-box" id="val-backend" style="color: #34d399; font-family: monospace;"></div>
                        </div>
                    </div>
                </div>

                <script>
                    const CLIENT_ID = '365281398460-i7itvaccbd4gdhftt76pbkdnqlph85o2.apps.googleusercontent.com';
                    
                    function getRedirectUri() {
                        return window.location.origin + window.location.pathname;
                    }

                    document.getElementById('val-redirect').innerText = getRedirectUri();

                    // 1. Проверяем наличие параметров в URL (возврат после редиректа)
                    const urlParams = new URLSearchParams(window.location.search);
                    const code = urlParams.get('code');
                    if (code) {
                        document.getElementById('results-panel').style.display = 'block';
                        document.getElementById('group-code').style.display = 'block';
                        document.getElementById('val-code').innerText = code;
                        showAlert('Успешно получен Authorization Code от Google!', 'success');
                    }

                    function startRedirectFlow() {
                        const redirectUri = encodeURIComponent(getRedirectUri());
                        const scope = encodeURIComponent('openid email profile');
                        const googleAuthUrl = `https://accounts.google.com/o/oauth2/v2/auth?client_id=${d}{CLIENT_ID}&redirect_uri=${d}{redirectUri}&response_type=code&scope=${d}{scope}&prompt=consent&access_type=offline`;
                        window.location.href = googleAuthUrl;
                    }

                    // 2. Обработка ответа от кнопки "Войти с Google"
                    function handleCredentialResponse(response) {
                        const idToken = response.credential;
                        document.getElementById('results-panel').style.display = 'block';
                        document.getElementById('group-idtoken').style.display = 'block';
                        document.getElementById('val-idtoken').innerText = idToken;

                        // Декодируем JWT payload
                        try {
                            const base64Url = idToken.split('.')[1];
                            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
                            const jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function(c) {
                                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
                            }).join(''));
                            const payload = JSON.parse(jsonPayload);
                            document.getElementById('val-idtoken-decoded').innerHTML = `
                                <strong>Пользователь:</strong> ${d}{payload.name} (${d}{payload.email})<br>
                                <strong>Google ID (sub):</strong> ${d}{payload.sub}
                            `;
                        } catch (e) {
                            console.error("Ошибка декодирования токена", e);
                        }

                        showAlert('ID Token получен! Отправляем запрос на наш бэкенд...', 'info');

                        // Автоматически отправляем токен на наш бэкенд
                        exchangeToken(idToken);
                    }

                    function exchangeToken(idToken) {
                        const backendGroup = document.getElementById('group-backend');
                        const backendVal = document.getElementById('val-backend');
                        backendGroup.style.display = 'block';
                        backendVal.innerText = 'Отправка запроса...';

                        fetch('/auth/v1/google', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({ idToken: idToken })
                        })
                        .then(async response => {
                            const status = response.status;
                            const text = await response.text();
                            let formatted = `HTTP Status: ${d}{status}\n\n`;
                            try {
                                formatted += JSON.stringify(JSON.parse(text), null, 2);
                            } catch (e) {
                                formatted += text || '(Пустой ответ)';
                            }
                            backendVal.innerText = formatted;
                            if (response.ok) {
                                showAlert('Авторизация на бэкенде успешна! Внутренние токены получены.', 'success');
                            } else {
                                showAlert(`Ошибка авторизации на бэкенде: HTTP ${d}{status}`, 'error');
                            }
                        })
                        .catch(error => {
                            backendVal.innerText = 'Ошибка запроса: ' + error.message;
                            showAlert('Не удалось связаться с бэкендом: ' + error.message, 'error');
                        });
                    }

                    function showAlert(message, type) {
                        const container = document.getElementById('alert-container');
                        let bg = 'rgba(59, 130, 246, 0.1)';
                        let border = 'rgba(59, 130, 246, 0.2)';
                        let color = '#60a5fa';

                        if (type === 'success') {
                            bg = 'rgba(16, 185, 129, 0.1)';
                            border = 'rgba(16, 185, 129, 0.2)';
                            color = '#34d399';
                        } else if (type === 'error') {
                            bg = 'rgba(239, 68, 68, 0.1)';
                            border = 'rgba(239, 68, 68, 0.2)';
                            color = '#f87171';
                        }

                        container.innerHTML = `
                            <div class="alert" style="background: ${d}{bg}; border: 1px solid ${d}{border}; color: ${d}{color};">
                                ${d}{message}
                            </div>
                        `;
                    }

                    function copyText(elementId) {
                        const text = document.getElementById(elementId).innerText;
                        navigator.clipboard.writeText(text).then(() => {
                            alert('Скопировано в буфер обмена!');
                        });
                    }
                </script>
            </body>
            </html>
        """.trimIndent()
    }
}
