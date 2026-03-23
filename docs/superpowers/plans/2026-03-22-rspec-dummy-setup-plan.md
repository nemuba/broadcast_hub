# RSpec Dummy Setup Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** configurar o `spec/dummy`, preparar banco de teste e deixar `bundle exec rspec` funcionando com um fluxo minimo e repetivel.

**Architecture:** manter o dummy app como fonte de ambiente Rails para os testes da engine, com banco SQLite separado por ambiente e tarefas de conveniencia no `Rakefile` da raiz. O bootstrap de teste fica centralizado em `spec/rails_helper.rb` e `spec/spec_helper.rb`, com um smoke test para validar carregamento do ambiente.

**Tech Stack:** Ruby, Rails 6.1, RSpec, sqlite3, Rake.

---

## File Structure

- Modify: `Gemfile`
  - incluir gems de teste no grupo `:development, :test`.
- Modify: `spec/spec_helper.rb`
  - adicionar defaults minimos de RSpec para suite previsivel.
- Modify: `spec/rails_helper.rb`
  - garantir bootstrap limpo com dummy app e carregamento de `spec_helper`.
- Modify: `spec/dummy/config/database.yml`
  - separar arquivos SQLite de `development` e `test`.
- Create: `Rakefile`
  - expor tasks `spec` e `dummy:db:prepare`.
- Create: `spec/smoke/dummy_boot_spec.rb`
  - validar boot do ambiente Rails da dummy app.

## Chunk 1: Bootstrap de teste e dependencias

### Task 1: Dependencias de teste no bundle principal

**Files:**
- Modify: `Gemfile`
- Test: `bundle install`

- [ ] **Step 1: Escrever alteracao no Gemfile**

```ruby
group :development, :test do
  gem 'rubocop-rails'
  gem 'rspec-rails', '~> 6.0'
  gem 'sqlite3', '~> 1.4'
end
```

- [ ] **Step 2: Rodar instalacao de dependencias**

Run: `bundle install`
Expected: gems instaladas sem conflito de versao.

- [ ] **Step 3: Commit**

```bash
git add Gemfile Gemfile.lock
git commit -m "chore: add minimal test dependencies for engine specs"
```

### Task 2: Setup minimo do RSpec

**Files:**
- Modify: `spec/spec_helper.rb`
- Modify: `spec/rails_helper.rb`
- Create: `spec/smoke/bootstrap_config_spec.rb`
- Test: `bundle exec rspec spec/smoke/bootstrap_config_spec.rb`

- [ ] **Step 1: Escrever teste que falha primeiro para bootstrap/config**

```ruby
require 'rails_helper'

RSpec.describe 'RSpec bootstrap' do
  it 'carrega o dummy em ambiente de teste' do
    expect(Rails.env).to eq('test')
  end

  it 'persiste status de exemplos no caminho esperado' do
    expect(RSpec.configuration.example_status_persistence_file_path).to eq('spec/examples.txt')
  end
end
```

- [ ] **Step 2: Rodar o teste novo e confirmar falha inicial**

Run: `bundle exec rspec spec/smoke/bootstrap_config_spec.rb`
Expected: FAIL (antes do ajuste de `spec_helper`, falhando no path de persistencia).

- [ ] **Step 3: Ajustar `spec/spec_helper.rb` com defaults minimos**

```ruby
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
```

- [ ] **Step 4: Ajustar `spec/rails_helper.rb` para bootstrap limpo**

```ruby
ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require File.expand_path('dummy/config/environment', __dir__)
require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
end
```

- [ ] **Step 5: Validar bootstrap com teste alvo**

Run: `bundle exec rspec spec/smoke/bootstrap_config_spec.rb`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add spec/spec_helper.rb spec/rails_helper.rb spec/smoke/bootstrap_config_spec.rb
git commit -m "test: standardize rspec bootstrap for dummy app"
```

## Chunk 2: Banco, tarefas Rake e smoke test

### Task 3: Configurar banco SQLite por ambiente

**Files:**
- Modify: `spec/dummy/config/database.yml`
- Test: `RAILS_ENV=test bundle exec rake -f spec/dummy/Rakefile db:create db:schema:load`

- [ ] **Step 1: Ajustar arquivos SQLite separados**

```yaml
default: &default
  adapter: sqlite3
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  database: db/production.sqlite3
```

- [ ] **Step 2: Preparar banco de teste do dummy**

Run: `RAILS_ENV=test bundle exec rake -f spec/dummy/Rakefile db:create db:schema:load`
Expected: PASS criando/preparando `db/test.sqlite3`.

- [ ] **Step 3: Fallback se schema inexistente**

Run: `RAILS_ENV=test bundle exec rake -f spec/dummy/Rakefile db:create db:migrate`
Expected: PASS aplicando migracoes quando nao houver `schema.rb`.

- [ ] **Step 4: Commit**

```bash
git add spec/dummy/config/database.yml
git commit -m "test: separate dummy sqlite databases by environment"
```

### Task 4: Adicionar Rakefile de conveniencia na raiz

**Files:**
- Create: `Rakefile`
- Test: `bundle exec rake -T`

- [ ] **Step 1: (TDD) Capturar estado inicial**

Run: `bundle exec rake -T`
Expected: FAIL com "No Rakefile found" (ou ausencia de `dummy:db:prepare`), confirmando que a task ainda nao existe.

- [ ] **Step 2: Criar Rakefile com tasks minimas**

```ruby
# frozen_string_literal: true

require 'rake'

desc 'Run RSpec suite'
task :spec do
  sh 'bundle exec rspec'
end

namespace :dummy do
  namespace :db do
    desc 'Prepare dummy test database'
    task :prepare do
      schema = File.expand_path('spec/dummy/db/schema.rb', __dir__)
      if File.exist?(schema)
        sh 'RAILS_ENV=test bundle exec rake -f spec/dummy/Rakefile db:create db:schema:load'
      else
        sh 'RAILS_ENV=test bundle exec rake -f spec/dummy/Rakefile db:create db:migrate'
      end
    end
  end
end
```

- [ ] **Step 3: Validar listagem de tasks**

Run: `bundle exec rake -T`
Expected: mostra `rake spec` e `rake dummy:db:prepare`.

- [ ] **Step 4: Validar task de banco**

Run: `bundle exec rake dummy:db:prepare`
Expected: PASS preparando banco de teste do dummy.

- [ ] **Step 5: Commit**

```bash
git add Rakefile
git commit -m "build: add rake tasks for dummy db and specs"
```

### Task 5: Smoke spec para validar boot do dummy

**Files:**
- Create: `spec/smoke/dummy_boot_spec.rb`
- Test: `bundle exec rspec spec/smoke/dummy_boot_spec.rb`

- [ ] **Step 1: (TDD) Garantir falha inicial do alvo**

Run: `bundle exec rspec spec/smoke/dummy_boot_spec.rb`
Expected: FAIL (arquivo/spec inexistente), validando red phase.

- [ ] **Step 2: Escrever teste minimo de boot**

```ruby
require 'rails_helper'

RSpec.describe 'Dummy app boot' do
  it 'loads Rails application in test mode' do
    expect(Rails.env).to eq('test')
    expect(defined?(BroadcastHub::Engine)).to eq('constant')
  end
end
```

- [ ] **Step 3: Rodar smoke spec**

Run: `bundle exec rspec spec/smoke/dummy_boot_spec.rb`
Expected: PASS.

- [ ] **Step 4: Rodar suite completa**

Run: `bundle exec rake dummy:db:prepare && bundle exec rspec`
Expected: PASS sem falha de bootstrap/config.

- [ ] **Step 5: Commit**

```bash
git add spec/smoke/dummy_boot_spec.rb
git commit -m "test: add smoke spec for dummy rails boot"
```

## Validacao final

- [ ] `bundle exec rake -T` lista tasks esperadas.
- [ ] `bundle exec rake dummy:db:prepare` conclui sem erro.
- [ ] `bundle exec rspec` executa sem falha de bootstrap.
