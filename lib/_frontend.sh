#!/bin/bash
# 
# Functions for setting up app frontend

#######################################
# Install node packages for frontend
# Arguments: None
#######################################
frontend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deployautomatizaai <<EOF
  cd /home/deployautomatizaai/whaticket/frontend
  npm install --force
EOF

  sleep 2
}

#######################################
# Set frontend environment variables
# Arguments: None
#######################################
frontend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  sudo su - deployautomatizaai << EOF
  cat <<[-]EOF > /home/deployautomatizaai/whaticket/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
REACT_APP_ENV_TOKEN=210897ugn217204u98u8jfo2983u5
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=9999999
REACT_APP_FACEBOOK_APP_ID=1005318707427295
REACT_APP_NAME_SYSTEM=${name_system}
REACT_APP_VERSION="1.0.0"
REACT_APP_PRIMARY_COLOR=${primary_color}
REACT_APP_PRIMARY_DARK=2c3145
REACT_APP_NUMBER_SUPPORT=${number_support}
SERVER_PORT=3333
WDS_SOCKET_PORT=0
[-]EOF
EOF

  # Execute the substitution commands
  sudo su - deployautomatizaai <<EOF
  cd /home/deployautomatizaai/whaticket/frontend

  # Substitution commands
  BACKEND_URL=\$(grep 'REACT_APP_BACKEND_URL' .env | cut -d'=' -f2)
  NAME_SYSTEM=$(grep 'REACT_APP_NAME_SYSTEM' .env | cut -d'=' -f2)
  PRIMARY_COLOR=\$(grep 'REACT_APP_PRIMARY_COLOR' .env | cut -d'=' -f2)
  PRIMARY_DARK=\$(grep 'REACT_APP_PRIMARY_DARK' .env | cut -d'=' -f2)
  NUMBER_SUPPORT=\$(grep 'REACT_APP_NUMBER_SUPPORT' .env | cut -d'=' -f2)

  sed -i "s|https://autoriza.dominio|\$BACKEND_URL|g" \$(grep -rl 'REACT_APP_BACKEND_URL' .)
  grep -rl 'Automatiza' . | xargs sed -i "s|Automatiza AI|$NAME_SYSTEM|g"
  sed -i "s|0b5394|\$PRIMARY_COLOR|g" \$(grep -rl 'REACT_APP_PRIMARY_COLOR' .)
  sed -i "s|2c3145|\$PRIMARY_DARK|g" \$(grep -rl 'REACT_APP_PRIMARY_DARK' .)
  sed -i "s|5551997058551|\$NUMBER_SUPPORT|g" \$(grep -rl 'REACT_APP_NUMBER_SUPPORT' .)
EOF

  sleep 2
}


#######################################
# Start pm2 for frontend
# Arguments: None
#######################################
frontend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deployautomatizaai <<EOF
  cd /home/deployautomatizaai/whaticket/frontend
  pm2 start server.js --name whaticket-frontend
  pm2 save
EOF

  sleep 2
}

#######################################
# Set up nginx for frontend
# Arguments: None
#######################################
frontend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  frontend_hostname=$(echo "${frontend_url/https:\/\/}")

  sudo su - root << EOF

  cat > /etc/nginx/sites-available/whaticket-frontend << 'END'
server {
  server_name $frontend_hostname;

  location / {
    proxy_pass http://127.0.0.1:3333;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END

  ln -s /etc/nginx/sites-available/whaticket-frontend /etc/nginx/sites-enabled
EOF

  sleep 2
}
