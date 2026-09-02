# Diniz Fornecedor

Catálogo responsivo para fornecedores, com vitrine pública, detalhes de produto, contato via WhatsApp e painel administrativo preparado para Supabase.

## Rodar localmente

1. Copie `.env.example` para `.env`.
2. Instale as dependências com `npm install`.
3. Inicie com `npm run dev`.
4. Gere a versão de produção com `npm run build`.

Sem variáveis configuradas, a aplicação funciona em modo demonstração com produtos locais.

## Conectar o Supabase

1. Abra o projeto informado no Supabase.
2. Vá ao SQL Editor e execute `supabase/migrations/001_initial_schema.sql`.
3. No Storage, crie os buckets públicos `product-images` e `banners`.
4. Configure `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` no `.env` local ou nas variáveis da Vercel.
5. Crie um usuário em Authentication > Users e, depois, insira o perfil administrador:

```sql
insert into public.profiles (id, full_name, role)
values ('UUID_DO_USUARIO', 'Administrador', 'admin');
```

A chave utilizada no frontend deve ser somente a chave pública anon/publishable. Nunca coloque `service_role` no navegador, no GitHub ou na Vercel.

## GitHub e Vercel

```bash
git init
git add .
git commit -m "feat: cria Diniz Fornecedor"
git branch -M main
git remote add origin URL_DO_REPOSITORIO
git push -u origin main
```

Na Vercel, importe o repositório, selecione o preset Vite e adicione as mesmas variáveis públicas do `.env`. O arquivo `vercel.json` já está incluído para rotas da aplicação.

## Próximas evoluções

- conectar o carregamento real de produtos em `src/lib/supabase.js` ao estado da vitrine;
- adicionar login visual do administrador;
- salvar uploads no Storage e registrar imagens na tabela `product_images`;
- registrar contatos no banco além do WhatsApp.

## Segurança

As políticas RLS permitem leitura pública apenas do catálogo ativo e inserção de leads. Operações administrativas exigem perfil `admin` ou `editor`.
