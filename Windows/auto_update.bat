@echo off
title ATUALIZACAO SEMANAL + BACKUP
color 0A

echo ========================================================
echo      PASSO 1: CRIANDO PONTO DE RESTAURACAO
echo ========================================================
:: O comando powershell abaixo cria o ponto.
:: Requer que o script rode como Admin (o que sua tarefa agendada ja faz)
powershell.exe -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Backup Automatico Semanal' -RestorePointType 'MODIFY_SETTINGS'"

echo Ponto de restauracao criado com sucesso!
echo.

echo ========================================================
echo      PASSO 2: ATUALIZANDO SISTEMA (WINGET)
echo ========================================================

echo ========================================================
echo      INICIANDO ROTINA DE ATUALIZACAO (WINGET)
echo      Data: %date% as %time%
echo ========================================================
echo.

:: Comando solicitado (Atualiza tudo, aceita termos e inclui desconhecidos)
winget upgrade --all --accept-source-agreements --accept-package-agreements --include-unknown

echo.
echo ========================================================
echo      ATUALIZACAO CONCLUIDA!
echo ========================================================
echo.
echo Esta janela fechara em 10 segundos...
timeout /t 10