FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Preparamos el esquema de postgresql explícitamente
RUN mkdir -p prisma && cp ./src/database/prisma/postgresql-schema.prisma ./prisma/schema.prisma
RUN npx prisma generate --schema=./prisma/schema.prisma
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/src ./src
COPY --from=builder /app/prisma ./prisma

EXPOSE 8080

# Forzamos a que el script use el provider postgresql y arranque directo sin romper migraciones locales
CMD ["sh", "-c", "npx prisma migrate deploy --schema=./prisma/schema.prisma && npm run start:prod"]
