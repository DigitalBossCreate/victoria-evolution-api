FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Copiamos explícitamente el esquema a la raíz para que Prisma lo encuentre sin buscar rutas complejas
RUN mkdir -p prisma && cp ./src/database/prisma/schema.prisma ./prisma/schema.prisma

RUN npx prisma generate --schema=./prisma/schema.prisma
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/src/database/prisma ./src/database/prisma

EXPOSE 8080
CMD ["npm", "run", "start:prod"]
