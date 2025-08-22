@echo off
REM Configure le shell pour utiliser le Docker de Minikube
FOR /f "tokens=*" %%i IN ('minikube -p minikube docker-env --shell cmd') DO @%%i
