# Django Base - Makefile para Automação de Tarefas
# Template Django com Arquitetura Limpa

.PHONY: help setup install test run clean docker-build docker-run docker-stop migrate createsuperuser lint format security-check docs-serve docs-build

# Variáveis
PYTHON := python3
PIP := pip
VENV := venv
PROJECT_DIR := project
REQUIREMENTS := $(PROJECT_DIR)/requirements.txt
PYTEST := pytest
MANAGE := $(PYTHON) manage.py

# Cores para output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Help
help: ## Mostra esta mensagem de ajuda
	@echo "$(BLUE)Django Base - Template com Arquitetura Limpa$(NC)"
	@echo "$(YELLOW)Comandos disponíveis:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup inicial
setup: ## Configura o ambiente de desenvolvimento completo
	@echo "$(BLUE)🚀 Configurando ambiente de desenvolvimento...$(NC)"
	@$(MAKE) install
	@$(MAKE) migrate
	@$(MAKE) createsuperuser
	@echo "$(GREEN)✅ Ambiente configurado com sucesso!$(NC)"
	@echo "$(YELLOW)💡 Execute 'make run' para iniciar o servidor$(NC)"

# Instalação de dependências
install: ## Instala todas as dependências
	@echo "$(BLUE)📦 Instalando dependências...$(NC)"
	@if [ ! -d "$(VENV)" ]; then \
		echo "$(YELLOW)📁 Criando ambiente virtual...$(NC)"; \
		$(PYTHON) -m venv $(VENV); \
	fi
	@echo "$(YELLOW)🔄 Ativando ambiente virtual...$(NC)"
	@. $(VENV)/bin/activate && $(PIP) install --upgrade pip
	@. $(VENV)/bin/activate && $(PIP) install -r $(REQUIREMENTS)
	@echo "$(GREEN)✅ Dependências instaladas com sucesso!$(NC)"

test: ## Executa todos os testes
	@echo "$(BLUE)🧪 Executando testes...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && export PYTHONPATH=$$PWD && $(PYTEST) -v cart core
	@echo "$(GREEN)✅ Testes executados com sucesso!$(NC)"

test-coverage: ## Executa testes com cobertura
	@echo "$(BLUE)🧪 Executando testes com cobertura...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && export PYTHONPATH=$$PWD && $(PYTEST) --cov=core --cov=cart --cov-config=../.coveragerc --cov-report=term-missing --cov-report=html
	@echo "$(GREEN)✅ Relatório de cobertura gerado em htmlcov/$(NC)"

test-watch: ## Executa testes em modo watch
	@echo "$(BLUE)🧪 Executando testes em modo watch...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && export PYTHONPATH=$$PWD && $(PYTEST) -f

# Servidor de desenvolvimento
run: ## Inicia o servidor de desenvolvimento
	@echo "$(BLUE)🚀 Iniciando servidor de desenvolvimento...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && $(MANAGE) runserver
	@echo "$(GREEN)✅ Servidor iniciado em http://127.0.0.1:8000$(NC)"

run-prod: ## Inicia o servidor em modo produção
	@echo "$(BLUE)🚀 Iniciando servidor em modo produção...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && $(MANAGE) runserver 0.0.0.0:8000

# Banco de dados
migrate: ## Executa migrações do banco de dados
	@echo "$(BLUE)🗄️ Executando migrações...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && $(MANAGE) migrate
	@echo "$(GREEN)✅ Migrações executadas com sucesso!$(NC)"

makemigrations: ## Cria novas migrações
	@echo "$(BLUE)📝 Criando migrações...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && $(MANAGE) makemigrations
	@echo "$(GREEN)✅ Migrações criadas com sucesso!$(NC)"

createsuperuser: ## Cria um superusuário
	@echo "$(BLUE)👤 Criando superusuário...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && $(MANAGE) createsuperuser
	@echo "$(GREEN)✅ Superusuário criado com sucesso!$(NC)"

# Limpeza
clean: ## Limpa arquivos temporários e cache
	@echo "$(BLUE)🧹 Limpando arquivos temporários...$(NC)"
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@find . -type d -name "*.egg-info" -exec rm -rf {} +
	@find . -type d -name ".pytest_cache" -exec rm -rf {} +
	@rm -rf htmlcov/
	@rm -rf .coverage
	@echo "$(GREEN)✅ Limpeza concluída!$(NC)"

clean-all: clean ## Limpa tudo incluindo ambiente virtual
	@echo "$(BLUE)🧹 Limpando ambiente virtual...$(NC)"
	@rm -rf $(VENV)
	@echo "$(GREEN)✅ Limpeza completa concluída!$(NC)"

# Docker
docker-build: ## Constrói a imagem Docker (produção)
	@echo "$(BLUE)🐳 Construindo imagem Docker de produção...$(NC)"
	@docker build -t django-base:latest .
	@echo "$(GREEN)✅ Imagem Docker construída com sucesso!$(NC)"

docker-build-dev: ## Constrói a imagem Docker de desenvolvimento (mais rápida)
	@echo "$(BLUE)🐳 Construindo imagem Docker de desenvolvimento...$(NC)"
	@docker build -f Dockerfile.dev -t django-base:dev .
	@echo "$(GREEN)✅ Imagem Docker de desenvolvimento construída!$(NC)"

docker-build-fast: ## Build rápido usando cache (apenas mudanças de código)
	@echo "$(BLUE)⚡ Build rápido com cache...$(NC)"
	@docker build --cache-from django-base:latest -t django-base:latest .
	@echo "$(GREEN)✅ Build rápido concluído!$(NC)"

docker-run: ## Executa o container Docker
	@echo "$(BLUE)🐳 Executando container Docker...$(NC)"
	@docker compose -f docker-compose.dev.yml up --build
	@echo "$(GREEN)✅ Container Docker executando!$(NC)"

docker-run-dev: ## Executa container de desenvolvimento (mais rápido)
	@echo "$(BLUE)🐳 Iniciando container de desenvolvimento...$(NC)"
	@docker run --rm -p 8000:8000 -v $(PWD)/project:/app/project django-base:dev
	@echo "$(GREEN)✅ Container de desenvolvimento executando!$(NC)"

docker-stop: ## Para o container Docker
	@echo "$(BLUE)🐳 Parando container Docker...$(NC)"
	@docker compose -f docker-compose.dev.yml down
	@echo "$(GREEN)✅ Container Docker parado!$(NC)"

docker-clean: ## Limpa imagens e containers não utilizados
	@echo "$(BLUE)🧹 Limpando Docker...$(NC)"
	@docker system prune -f
	@docker image prune -f
	@echo "$(GREEN)✅ Limpeza concluída!$(NC)"

docker-prod: ## Executa em modo produção com Docker
	@echo "$(BLUE)🐳 Executando em modo produção...$(NC)"
	@docker compose -f docker-compose.prod.yml up --build -d
	@echo "$(GREEN)✅ Aplicação rodando em produção!$(NC)"

# Qualidade de código
lint: ## Executa linting no código
	@echo "$(BLUE)🔍 Executando linting...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && flake8 . --exclude=migrations,venv,__pycache__
	@echo "$(GREEN)✅ Linting concluído!$(NC)"

docstyle: ## Verifica docstrings com pydocstyle
	@echo "$(BLUE)📖 Verificando docstrings (pydocstyle)...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && pydocstyle core --config=../pydocstyle.ini || true
	@echo "$(GREEN)✅ Verificação de docstrings concluída!$(NC)"

docs-quality: ## Formata e verifica documentação de código (Black + pydocstyle)
	@echo "$(BLUE)🧹 Formatando e verificando documentação...$(NC)"
	@$(MAKE) format
	@$(MAKE) docstyle
	@echo "$(GREEN)✅ Documentação de código revisada!$(NC)"

format: ## Formata o código
	@echo "$(BLUE)🎨 Formatando código...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && black . --exclude=migrations
	@echo "$(GREEN)✅ Código formatado!$(NC)"

security-check: ## Verifica vulnerabilidades de segurança
	@echo "$(BLUE)🔒 Verificando vulnerabilidades...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && pip-audit
	@echo "$(GREEN)✅ Verificação de segurança concluída!$(NC)"

# Documentação
docs-serve: ## Serve a documentação localmente
	@echo "$(BLUE)📚 Servindo documentação...$(NC)"
	@mkdocs serve
	@echo "$(GREEN)✅ Documentação disponível em http://127.0.0.1:8000$(NC)"

docs-build: ## Constrói a documentação
	@echo "$(BLUE)📚 Construindo documentação...$(NC)"
	@mkdocs build
	@echo "$(GREEN)✅ Documentação construída em site/$(NC)"

docs-check: ## Valida documentação em modo estrito
	@echo "$(BLUE)📚 Validando documentação (strict)...$(NC)"
	@mkdocs build --strict
	@echo "$(GREEN)✅ Documentação válida (sem links quebrados)!$(NC)"

type-check: ## Executa verificação de tipos com mypy
	@echo "$(BLUE)🔍 Verificando tipos (mypy)...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && mypy --config-file=../mypy.ini core/
	@echo "$(GREEN)✅ Verificação de tipos concluída!$(NC)"

pre-commit-install: ## Instala hooks do pre-commit
	@echo "$(BLUE)🔧 Instalando hooks do pre-commit...$(NC)"
	@. $(VENV)/bin/activate && pre-commit install
	@echo "$(GREEN)✅ Hooks do pre-commit instalados!$(NC)"

pre-commit-run: ## Executa pre-commit em todos os arquivos
	@echo "$(BLUE)🔧 Executando pre-commit...$(NC)"
	@. $(VENV)/bin/activate && pre-commit run --all-files
	@echo "$(GREEN)✅ Pre-commit executado!$(NC)"

docs-deploy: ## Faz deploy da documentação
	@echo "$(BLUE)📚 Fazendo deploy da documentação...$(NC)"
	@mkdocs gh-deploy
	@echo "$(GREEN)✅ Documentação deployada!$(NC)"

# Utilitários
shell: ## Abre o shell do Django
	@echo "$(BLUE)🐍 Abrindo shell do Django...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && $(MANAGE) shell

collectstatic: ## Coleta arquivos estáticos
	@echo "$(BLUE)📁 Coletando arquivos estáticos...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && $(MANAGE) collectstatic --noinput
	@echo "$(GREEN)✅ Arquivos estáticos coletados!$(NC)"

check: ## Executa verificações do Django
	@echo "$(BLUE)🔍 Executando verificações do Django...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && $(MANAGE) check
	@echo "$(GREEN)✅ Verificações concluídas!$(NC)"

# Novos comandos de automação
init-project: ## Limpa template para novo projeto (remove arquivos específicos)
	@echo "$(BLUE)🧹 Limpando template para novo projeto...$(NC)"
	@rm -f teste.txt commit.sh
	@rm -f project_improvements.md project_standards.md
	@rm -f RELEASE_NOTES_v2.1.0.md EVOLUTION_GUIDE.md
	@echo "$(GREEN)✅ Template limpo para novo projeto!$(NC)"
	@echo "$(YELLOW)💡 Agora você pode personalizar o projeto$(NC)"

update-deps: ## Atualiza dependências com verificação de segurança
	@echo "$(BLUE)📦 Atualizando dependências...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && pip list --outdated
	@echo "$(YELLOW)⚠️  Verificando vulnerabilidades antes da atualização...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && pip-audit
	@echo "$(YELLOW)💡 Execute 'pip install --upgrade package-name' para atualizar pacotes específicos$(NC)"

benchmark: ## Executa testes de performance
	@echo "$(BLUE)⚡ Executando benchmarks de performance...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && export PYTHONPATH=$$PWD && pytest --benchmark-only --benchmark-save=performance -v
	@echo "$(GREEN)✅ Benchmarks executados!$(NC)"

sonar-scan: ## Executa análise local com SonarScanner
	@echo "$(BLUE)🔍 Executando análise SonarCloud local...$(NC)"
	@if ! command -v sonar-scanner >/dev/null 2>&1; then \
		echo "$(YELLOW)⚠️  SonarScanner não encontrado. Instalando...$(NC)"; \
		wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip; \
		unzip sonar-scanner-cli-4.8.0.2856-linux.zip; \
		export PATH=$$PWD/sonar-scanner-4.8.0.2856-linux/bin:$$PATH; \
	fi
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && export PYTHONPATH=$$PWD && pytest --cov=core --cov-report=xml:coverage.xml --cov-report=term --junitxml=test-results.xml
	@sonar-scanner -Dsonar.projectKey=django-base-template -Dsonar.organization=luderibeiro -Dsonar.sources=project/core -Dsonar.python.coverage.reportPaths=project/coverage.xml -Dsonar.python.xunit.reportPath=project/test-results.xml
	@echo "$(GREEN)✅ Análise SonarCloud concluída!$(NC)"

db-backup: ## Melhora backup do banco de dados
	@echo "$(BLUE)💾 Fazendo backup do banco de dados...$(NC)"
	@mkdir -p backups
	@if [ -f "$(PROJECT_DIR)/db.sqlite3" ]; then \
		cp $(PROJECT_DIR)/db.sqlite3 backups/db_backup_$$(date +%Y%m%d_%H%M%S).sqlite3; \
		echo "$(GREEN)✅ Backup SQLite criado em backups/$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Banco SQLite não encontrado. Tentando PostgreSQL...$(NC)"; \
		pg_dump -h localhost -U postgres -d postgres > backups/pg_backup_$$(date +%Y%m%d_%H%M%S).sql; \
		echo "$(GREEN)✅ Backup PostgreSQL criado em backups/$(NC)"; \
	fi

db-restore: ## Restaura backup do banco de dados
	@echo "$(BLUE)🔄 Restaurando backup do banco de dados...$(NC)"
	@ls -la backups/
	@read -p "Digite o nome do arquivo de backup: " backup; \
	if [[ "$$backup" == *.sqlite3 ]]; then \
		cp backups/$$backup $(PROJECT_DIR)/db.sqlite3; \
		echo "$(GREEN)✅ Banco SQLite restaurado!$(NC)"; \
	elif [[ "$$backup" == *.sql ]]; then \
		psql -h localhost -U postgres -d postgres < backups/$$backup; \
		echo "$(GREEN)✅ Banco PostgreSQL restaurado!$(NC)"; \
	else \
		echo "$(RED)❌ Formato de arquivo não suportado$(NC)"; \
	fi

generate-env: ## Gera arquivo .env com valores seguros
	@echo "$(BLUE)📝 Gerando arquivo .env...$(NC)"
	@python scripts/generate_env.py
	@echo "$(GREEN)✅ Arquivo .env gerado!$(NC)"

health-check: ## Executa health check completo da aplicação
	@echo "$(BLUE)🏥 Executando health check...$(NC)"
	@python scripts/health_check.py
	@echo "$(GREEN)✅ Health check concluído!$(NC)"

setup-oauth: ## Configura OAuth2 application automaticamente
	@echo "$(BLUE)🔐 Configurando OAuth2 application...$(NC)"
	@python scripts/setup_oauth_client.py
	@echo "$(GREEN)✅ OAuth2 application configurado!$(NC)"

# Desenvolvimento
dev-setup: ## Setup completo para desenvolvimento
	@echo "$(BLUE)🛠️ Configurando ambiente de desenvolvimento...$(NC)"
	@$(MAKE) install
	@$(MAKE) migrate
	@$(MAKE) createsuperuser
	@$(MAKE) test
	@echo "$(GREEN)✅ Ambiente de desenvolvimento configurado!$(NC)"
	@echo "$(YELLOW)💡 Execute 'make run' para iniciar o servidor$(NC)"

# Produção
prod-setup: ## Setup para produção
	@echo "$(BLUE)🚀 Configurando ambiente de produção...$(NC)"
	@$(MAKE) install
	@$(MAKE) migrate
	@$(MAKE) collectstatic
	@$(MAKE) test
	@echo "$(GREEN)✅ Ambiente de produção configurado!$(NC)"

# Status
status: ## Mostra o status do projeto
	@echo "$(BLUE)📊 Status do Projeto Django Base$(NC)"
	@echo "$(YELLOW)Python:$(NC) $$(python3 --version)"
	@echo "$(YELLOW)Django:$(NC) $$(cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && python -c 'import django; print(django.get_version())')"
	@echo "$(YELLOW)Testes:$(NC) $$(cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && export PYTHONPATH=$$PWD && pytest --tb=no -q | tail -1)"
	@echo "$(YELLOW)Ambiente Virtual:$(NC) $$(if [ -d "$(VENV)" ]; then echo "✅ Ativo"; else echo "❌ Não encontrado"; fi)"
	@echo "$(YELLOW)Banco de Dados:$(NC) $$(cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && python manage.py check --database default 2>/dev/null && echo "✅ OK" || echo "❌ Erro")"

# Git e Deploy
git-setup: ## Configura repositório Git inicial
	@echo "$(BLUE)🔧 Configurando repositório Git...$(NC)"
	@git init
	@git add .
	@git commit -m "🎉 Initial commit: Django Base template setup"
	@echo "$(GREEN)✅ Repositório Git configurado!$(NC)"
	@echo "$(YELLOW)💡 Para conectar ao GitHub:$(NC)"
	@echo "$(YELLOW)   git remote add origin https://github.com/seu-usuario/seu-repo.git$(NC)"
	@echo "$(YELLOW)   git push -u origin main$(NC)"

git-commit: ## Faz commit com mensagem automática
	@echo "$(BLUE)📝 Fazendo commit das alterações...$(NC)"
	@git add .
	@read -p "Digite a mensagem do commit: " msg; \
	git commit -m "$$msg"
	@echo "$(GREEN)✅ Commit realizado!$(NC)"

git-push: ## Push para repositório remoto
	@echo "$(BLUE)🚀 Enviando alterações para repositório remoto...$(NC)"
	@git push
	@echo "$(GREEN)✅ Alterações enviadas!$(NC)"

# Backup e Restore
backup-db: ## Faz backup do banco de dados
	@echo "$(BLUE)💾 Fazendo backup do banco de dados...$(NC)"
	@mkdir -p backups
	@cp $(PROJECT_DIR)/db.sqlite3 backups/db_backup_$$(date +%Y%m%d_%H%M%S).sqlite3
	@echo "$(GREEN)✅ Backup criado em backups/$(NC)"

restore-db: ## Restaura backup do banco de dados
	@echo "$(BLUE)🔄 Restaurando backup do banco de dados...$(NC)"
	@ls -la backups/
	@read -p "Digite o nome do arquivo de backup: " backup; \
	cp backups/$$backup $(PROJECT_DIR)/db.sqlite3
	@echo "$(GREEN)✅ Banco de dados restaurado!$(NC)"

# Análise e Relatórios
analyze: ## Análise completa do código
	@echo "$(BLUE)🔍 Executando análise completa do código...$(NC)"
	@$(MAKE) lint
	@$(MAKE) docstyle
	@$(MAKE) type-check
	@$(MAKE) security-check
	@$(MAKE) test-coverage
	@echo "$(GREEN)✅ Análise completa concluída!$(NC)"

report: ## Gera relatório completo do projeto
	@echo "$(BLUE)📊 Gerando relatório do projeto...$(NC)"
	@echo "# Relatório do Projeto Django Base" > project_report.md
	@echo "Gerado em: $$(date)" >> project_report.md
	@echo "" >> project_report.md
	@echo "## Status do Projeto" >> project_report.md
	@$(MAKE) status >> project_report.md 2>&1
	@echo "" >> project_report.md
	@echo "## Estrutura de Arquivos" >> project_report.md
	@find $(PROJECT_DIR) -name "*.py" | head -20 >> project_report.md
	@echo "$(GREEN)✅ Relatório gerado em project_report.md$(NC)"

# Utilitários avançados
requirements-update: ## Atualiza requirements.txt
	@echo "$(BLUE)📦 Atualizando requirements.txt...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && pip freeze > requirements.txt
	@echo "$(GREEN)✅ Requirements atualizados!$(NC)"

requirements-check: ## Verifica dependências desatualizadas
	@echo "$(BLUE)🔍 Verificando dependências desatualizadas...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && pip list --outdated
	@echo "$(GREEN)✅ Verificação concluída!$(NC)"

env-example: ## Cria arquivo .env de exemplo
	@echo "$(BLUE)📝 Criando arquivo .env de exemplo...$(NC)"
	@echo "# Configurações do Django" > .env.example
	@echo "DJANGO_DEBUG=True" >> .env.example
	@echo "DJANGO_SECRET_KEY=change-me-in-production" >> .env.example
	@echo "DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1" >> .env.example
	@echo "# Banco de dados (produção)" >> .env.example
	@echo "DB_ENGINE=django.db.backends.postgresql" >> .env.example
	@echo "DB_NAME=postgres" >> .env.example
	@echo "DB_USER=postgres" >> .env.example
	@echo "DB_PASSWORD=postgres" >> .env.example
	@echo "DB_HOST=project_db" >> .env.example
	@echo "DB_PORT=5432" >> .env.example
	@echo "# DRF" >> .env.example
	@echo "DRF_PAGE_SIZE=50" >> .env.example
	@echo "$(GREEN)✅ Arquivo .env.example criado!$(NC)"

# Performance e Monitoramento
performance-test: ## Executa testes de performance
	@echo "$(BLUE)⚡ Executando testes de performance...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && python manage.py test --settings=project.settings --keepdb --parallel
	@echo "$(GREEN)✅ Testes de performance concluídos!$(NC)"

memory-profile: ## Análise de uso de memória
	@echo "$(BLUE)🧠 Analisando uso de memória...$(NC)"
	@cd $(PROJECT_DIR) && . ../$(VENV)/bin/activate && python -m memory_profiler manage.py check
	@echo "$(GREEN)✅ Análise de memória concluída!$(NC)"

# Automação completa
full-setup: ## Setup completo com todas as verificações
	@echo "$(BLUE)🚀 Executando setup completo...$(NC)"
	@$(MAKE) clean-all
	@$(MAKE) install
	@$(MAKE) migrate
	@$(MAKE) createsuperuser
	@$(MAKE) test
	@$(MAKE) lint
	@$(MAKE) docs-build
	@echo "$(GREEN)✅ Setup completo finalizado!$(NC)"
	@echo "$(YELLOW)💡 Projeto pronto para desenvolvimento!$(NC)"

ci-pipeline: ## Pipeline de CI/CD completo
	@echo "$(BLUE)🔄 Executando pipeline CI/CD...$(NC)"
	@$(MAKE) install
	@$(MAKE) lint
	@$(MAKE) docstyle
	@$(MAKE) type-check
	@$(MAKE) security-check
	@$(MAKE) test-coverage
	@$(MAKE) docs-build
	@echo "$(GREEN)✅ Pipeline CI/CD concluído!$(NC)"

# Default target
.DEFAULT_GOAL := help
