# --------------------
# 1. BUILD STAGE: Instala as dependências e constrói o aplicativo.
# --------------------
FROM node:20-slim AS builder

# Instala pnpm globalmente
RUN npm install -g pnpm

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos de configuração de dependências
COPY package.json pnpm-lock.yaml ./

# Instala as dependências (pnpm i --frozen-lockfile é mais seguro)
RUN pnpm install --frozen-lockfile

# Copia o restante do código da aplicação
COPY . .

# Comando de Build do Frontend (Vite)
# O script "build" no package.json do chef é "vite build"
RUN pnpm run build


# --------------------
# 2. PRODUCTION STAGE: Imagem final leve para servir os arquivos estáticos.
# --------------------

# Usamos uma imagem base leve como Nginx para servir os arquivos estáticos
FROM nginx:alpine

# Remove o arquivo de configuração padrão do Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copia a configuração personalizada do Nginx (necessária para Apps Single Page)
# Você precisará criar o arquivo nginx.conf abaixo.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia os arquivos estáticos construídos da etapa 'builder' para o diretório de serviço do Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# A porta padrão do Nginx é 80, que será exposta
EXPOSE 80

# Comando para iniciar o servidor Nginx
CMD ["nginx", "-g", "daemon off;"]
