# Design: Setup minimo de `spec/dummy` + banco + RSpec

## Contexto

O projeto e uma Rails Engine (`broadcast_hub`) com app dummy em `spec/dummy`.
Ja existe um `spec/rails_helper.rb` carregando `spec/dummy/config/environment`, mas o setup esta incompleto para garantir execucao previsivel de testes com RSpec no fluxo local.

Objetivo do usuario: configurar rapidamente o dummy, criar/preparar banco e rodar testes com RSpec agora.

## Escopo

### Inclui

- Ajustar setup minimo para boot de testes da engine com app dummy.
- Garantir dependencias essenciais para teste (`rspec-rails` e `sqlite3`) no `Gemfile` principal, no grupo `:development, :test`.
- Definir fluxo simples para preparar banco de teste do dummy (`db:create` + `db:schema:load` ou `db:migrate`).
- Adicionar `Rakefile` na raiz da engine para expor tarefas de setup/execucao de testes.
- Validar com `bundle exec rspec`.

### Nao inclui (YAGNI)

- FactoryBot/Faker/DatabaseCleaner.
- Suite de suporte avancado em `spec/support`.
- Refatoracao estrutural grande de teste.

## Abordagens consideradas

1. **Recomendada: setup minimo no Gemfile principal + dummy via `rails_helper`**
   - Pro: mais simples e alinhado ao padrao de engines Rails.
   - Contra: ainda basico para crescimento da suite.

2. Usar `BUNDLE_GEMFILE=spec/dummy/Gemfile` para rodar tudo
   - Pro: isolamento do dummy.
   - Contra: manutencao mais confusa e risco de divergencia de dependencias.

3. Evitar dummy e focar so em testes unitarios puros
   - Pro: execucao rapida.
   - Contra: nao cobre integracao da engine com Rails/Action Cable.

## Design aprovado

### 1) Setup de ambiente de teste

- Manter `spec/rails_helper.rb` carregando `spec/dummy/config/environment`.
- Garantir `require 'rspec/rails'` e um bootstrap limpo de RSpec.
- Melhorar `spec/spec_helper.rb` com defaults minimos (ordem aleatoria, profile opcional, persistencia de status).
- Criar `Rakefile` na raiz da engine com tarefas minimas:
  - `spec` -> roda `bundle exec rspec`
  - `dummy:db:prepare` -> prepara banco do dummy em `RAILS_ENV=test`

### 2) Banco do dummy

- Manter SQLite em `spec/dummy/config/database.yml` para simplicidade local.
- Garantir arquivos separados por ambiente no dummy para evitar contaminacao:
  - `development`: `db/development.sqlite3`
  - `test`: `db/test.sqlite3`
- Preparar banco de teste usando tasks Rails apontadas ao dummy app.
- Comando recomendado (na raiz da engine, usando o Rakefile do dummy):

```bash
RAILS_ENV=test bundle exec rake -f spec/dummy/Rakefile db:create db:schema:load
```

Se nao houver schema, usar:

```bash
RAILS_ENV=test bundle exec rake -f spec/dummy/Rakefile db:create db:migrate
```

### 3) Execucao de teste

- Rodar `bundle exec rspec` na raiz da engine.
- Em caso de erro de carga de ambiente, revisar caminho do dummy em `spec/rails_helper.rb`.

## Plano de implementacao enxuto

1. Atualizar dependencias de teste no `Gemfile` principal.
2. Ajustar `spec/spec_helper.rb` com defaults uteis e seguros.
3. Validar `spec/rails_helper.rb` para boot correto do dummy.
4. Adicionar `Rakefile` com tarefas de conveniencia para teste e preparo de banco.
5. Preparar banco de teste.
6. Criar smoke spec minimo (`spec/smoke/dummy_boot_spec.rb`) para validar boot do dummy.
7. Rodar RSpec e corrigir falhas de configuracao.

## Criterios de sucesso

- `bundle install` conclui sem conflito de gems.
- `bundle exec rake -T` lista as tarefas esperadas (`spec` e `dummy:db:prepare`).
- Banco de teste do dummy e criado/preparado com sucesso.
- `bundle exec rspec` executa sem falha de bootstrap/config.
- Existe um smoke spec minimo (ex.: `spec/smoke/dummy_boot_spec.rb`) validando que o ambiente Rails do dummy carrega.
