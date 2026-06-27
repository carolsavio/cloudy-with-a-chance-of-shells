#!/bin/bash
# ============================================================
#  PetroTask™ Lab — Script de Setup
#  "Seu tempo é petróleo. Nós refinamos."
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

banner() {
  echo -e "${CYAN}${BOLD}"
  echo "           Cloudy with a chance of shells"
  echo -e "${NC}"
  echo ""

  echo -e "${RED}"
  echo "  ██████╗ ███████╗████████╗██████╗  ██████╗ "
  echo "  ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗"
  echo "  ██████╔╝█████╗     ██║   ██████╔╝██║   ██║"
  echo "  ██╔═══╝ ██╔══╝     ██║   ██╔══██╗██║   ██║"
  echo "  ██║     ███████╗   ██║   ██║  ██║╚██████╔╝"
  echo "  ╚═╝     ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ "
  echo -e "${NC}${BOLD}  ████████╗ █████╗ ███████╗██╗  ██╗${NC}"
  echo -e "${BOLD}  ╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝${NC}"
  echo -e "${BOLD}     ██║   ███████║███████╗█████╔╝ ${NC}"
  echo -e "${BOLD}     ██║   ██╔══██║╚════██║██╔═██╗ ${NC}"
  echo -e "${BOLD}     ██║   ██║  ██║███████║██║  ██╗${NC}"
  echo -e "${BOLD}     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${NC}"
  echo ""
  echo -e "${CYAN}  Pentest Lab --- Ambiente Vulnerável para Estudos${NC}"
  echo -e "${YELLOW}  \"Seu tempo é petróleo. Nós refinamos.\"${NC}"
  echo ""
}

info()    { echo -e "${CYAN}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
step()    { echo -e "\n${BOLD}${RED}══ $1 ══${NC}"; }

# ── Verificação de pré-requisitos ───────────────────────────────────────────
check_prerequisites() {
  step "Verificando pré-requisitos"

  # Terraform
  if ! command -v terraform &>/dev/null; then
    error "Terraform não encontrado. Instale em: https://developer.hashicorp.com/terraform/install"
  fi
  TF_VERSION=$(terraform version -json | python3 -c "import sys,json; print(json.load(sys.stdin)['terraform_version'])" 2>/dev/null || terraform version | head -1 | grep -oP '\d+\.\d+\.\d+')
  success "Terraform $TF_VERSION encontrado"

  # AWS CLI
  if ! command -v aws &>/dev/null; then
    error "AWS CLI não encontrado. Instale em: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
  fi
  success "AWS CLI encontrado"

  # Credenciais AWS
  if ! aws sts get-caller-identity &>/dev/null; then
    error "Credenciais AWS não configuradas. Execute: aws configure"
  fi
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  REGION=$(aws configure get region || echo "us-east-1")
  success "AWS autenticado — Conta: $ACCOUNT_ID | Região: $REGION"

  # Chave SSH
  SSH_KEY="${HOME}/.ssh/id_rsa"
  if [ ! -f "$SSH_KEY" ]; then
    warn "Chave SSH não encontrada em $SSH_KEY"
    info "Gerando nova chave SSH..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N "" -q
    success "Chave SSH gerada em $SSH_KEY"
  else
    success "Chave SSH encontrada em $SSH_KEY"
  fi

  # Python3 (para helpers)
  if ! command -v python3 &>/dev/null; then
    warn "Python3 não encontrado — algumas verificações serão puladas"
  fi
}

# ── Configurar tfvars ────────────────────────────────────────────────────────
configure_tfvars() {
  step "Configurando variáveis do lab"

  TFVARS_FILE="terraform/environments/lab/terraform.tfvars"

  if [ -f "$TFVARS_FILE" ]; then
    warn "terraform.tfvars já existe. Deseja reconfigurar? (s/N)"
    read -r resp
    [[ "$resp" =~ ^[Ss]$ ]] || { info "Mantendo configuração existente."; return; }
  fi

  # Detectar IP público automaticamente
  info "Detectando seu IP público..."
  YOUR_IP=$(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 api.ipify.org || echo "")
  if [ -z "$YOUR_IP" ]; then
    warn "Não foi possível detectar seu IP automaticamente."
    echo -n "  Digite seu IP público: "
    read -r YOUR_IP
  else
    success "IP detectado: $YOUR_IP"
  fi

  # Email para alertas
  echo ""
  echo -n "  Email para alertas de custo AWS: "
  read -r ALERT_EMAIL

  # Chave pública SSH
  SSH_PUB_KEY=$(cat "${HOME}/.ssh/id_rsa.pub")

  # Região
  AWS_REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")

  cat > "$TFVARS_FILE" << EOF
aws_region     = "$AWS_REGION"
your_ip        = "$YOUR_IP/32"
ssh_public_key = "$SSH_PUB_KEY"
alert_email    = "$ALERT_EMAIL"
EOF

  success "terraform.tfvars configurado"
}

# ── Aviso legal ──────────────────────────────────────────────────────────────
legal_warning() {
  step "Aviso Legal — Leia antes de continuar"
  echo ""
  echo -e "${YELLOW}  ┌─────────────────────────────────────────────────────┐${NC}"
  echo -e "${YELLOW}  │  ESTE AMBIENTE É INTENCIONALMENTE VULNERÁVEL        │${NC}"
  echo -e "${YELLOW}  │                                                     │${NC}"
  echo -e "${YELLOW}  │  ✓ Use apenas na SUA conta AWS pessoal              │${NC}"
  echo -e "${YELLOW}  │  ✓ Nunca deixe o lab no ar sem necessidade          │${NC}"
  echo -e "${YELLOW}  │  ✓ Execute 'terraform destroy' ao finalizar         │${NC}"
  echo -e "${YELLOW}  │  ✓ Não aponte ferramentas para sistemas de terceiros│${NC}"
  echo -e "${YELLOW}  │  ✓ Siga a Política de Testes da AWS:                │${NC}"
  echo -e "${YELLOW}  │    aws.amazon.com/security/penetration-testing      │${NC}"
  echo -e "${YELLOW}  └─────────────────────────────────────────────────────┘${NC}"
  echo ""
  echo -n "  Você leu e concorda com os termos acima? (s/N): "
  read -r consent
  [[ "$consent" =~ ^[Ss]$ ]] || { warn "Setup cancelado."; exit 0; }
  success "Termos aceitos"
}

# ── Terraform ────────────────────────────────────────────────────────────────
run_terraform() {
  step "Provisionando infraestrutura na AWS"

  cd terraform/environments/lab

  info "Inicializando Terraform..."
  terraform init -upgrade

  info "Validando configuração..."
  terraform validate && success "Configuração válida"

  info "Pré-visualizando recursos que serão criados..."
  terraform plan -out=tfplan

  echo ""
  warn "Os recursos acima serão criados na sua conta AWS."
  echo -n "  Confirma o deploy? (s/N): "
  read -r confirm
  [[ "$confirm" =~ ^[Ss]$ ]] || { warn "Deploy cancelado."; exit 0; }

  info "Aplicando infraestrutura..."
  terraform apply tfplan

  cd ../../..
}

# ── Resultado final ──────────────────────────────────────────────────────────
show_result() {
  step "Lab provisionado com sucesso!"

  cd terraform/environments/lab
  PUBLIC_IP=$(terraform output -raw public_ip 2>/dev/null || echo "verificando...")
  BUCKET=$(terraform output -raw s3_bucket 2>/dev/null || echo "verificando...")
  cd ../../..

  echo ""
  echo -e "${RED}  ╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}  ║        🌩️  PETROTASK LAB ATIVO  🌩️                   ║${NC}"
  echo -e "${RED}  ╠══════════════════════════════════════════════════════╣${NC}"
  echo -e "${RED}  ║${NC}                                                      ${RED}║${NC}"
  echo -e "${RED}  ║${NC}  🌐 Portal:   ${GREEN}http://$PUBLIC_IP${NC}"
  echo -e "${RED}  ║${NC}  🔓 DVWA:     ${GREEN}http://$PUBLIC_IP/dvwa${NC}"
  echo -e "${RED}  ║${NC}  🖥️  SSH:      ${CYAN}ssh ubuntu@$PUBLIC_IP${NC}"
  echo -e "${RED}  ║${NC}  🪣  S3:       ${YELLOW}$BUCKET${NC}"
  echo -e "${RED}  ║${NC}                                                      ${RED}║${NC}"
  echo -e "${RED}  ║${NC}  🔑 Login DVWA padrão: ${BOLD}admin / password${NC}              ${RED}║${NC}"
  echo -e "${RED}  ║${NC}  ⚙️  Primeiro acesso:   ${BOLD}/dvwa/setup.php${NC}               ${RED}║${NC}"
  echo -e "${RED}  ║${NC}                                                      ${RED}║${NC}"
  echo -e "${RED}  ╠══════════════════════════════════════════════════════╣${NC}"
  echo -e "${RED}  ║${NC}  ⚠️  Ao finalizar:  ${RED}terraform destroy${NC}                  ${RED}║${NC}"
  echo -e "${RED}  ╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
  warn "Aguarde ~3 minutos para a aplicação terminar de subir."
  info "Consulte o README.md para o roteiro completo de ataques."
  echo ""
}

# ── Destroy helper ───────────────────────────────────────────────────────────
destroy_lab() {
  step "Destruindo o lab"
  warn "Isso removerá TODOS os recursos criados na AWS."
  echo -n "  Confirma? (s/N): "
  read -r confirm
  [[ "$confirm" =~ ^[Ss]$ ]] || { info "Operação cancelada."; exit 0; }

  cd terraform/environments/lab
  terraform destroy
  cd ../../..
  success "Lab destruído. Nenhum recurso ativo na AWS."
}

# ── Ponto de entrada ─────────────────────────────────────────────────────────
main() {
  banner

  case "${1:-up}" in
    up|deploy)
      legal_warning
      check_prerequisites
      configure_tfvars
      run_terraform
      show_result
      ;;
    down|destroy)
      destroy_lab
      ;;
    status)
      cd terraform/environments/lab
      terraform output
      cd ../../..
      ;;
    *)
      echo "Uso: $0 [up|down|status]"
      echo ""
      echo "  up      — Sobe o lab (padrão)"
      echo "  down    — Destrói todos os recursos AWS"
      echo "  status  — Mostra outputs do lab ativo"
      ;;
  esac
}

main "$@"
