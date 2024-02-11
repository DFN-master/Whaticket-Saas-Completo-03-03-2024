#!/bin/bash

get_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio da interface web (Frontend):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio da sua API (Backend):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_name_system() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome do sistema:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " name_system
}

get_primary_color() {
  
  print_banner
  printf "${WHITE} 💻 Digite o codigo da cor primay, EX: #0b5394:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " primary_color
}

get_number_support() {
  
  print_banner
  printf "${WHITE} 💻 Digite o numero de suporte:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " number_support
}

get_urls() {
  
  get_frontend_url
  get_backend_url
  get_name_system
  get_primary_color
  get_number_support
}

software_update() {
  
  # frontend_update
  backend_update
}

inquiry_options() {
  
  print_banner
  printf "${WHITE} 💻 O que você precisa fazer?${GRAY_LIGHT}"
  printf "\n\n"
  printf "   [1] Instalar\n"
  printf "\n"
  read -p "> " option

  case "${option}" in
    1) get_urls ;;

    2) 
      software_update 
      exit
      ;;

    *) exit ;;
  esac
}

