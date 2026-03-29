# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.2.2] - 2026-03-29

### Added
- New engine helper `dom_id(record, positional_prefix = nil, prefix: nil, suffix: nil)` available in controller and view contexts.
- Contract and exposure specs covering positional Rails compatibility, keyword wrappers, normalization rules, and host dummy app integration.

### Changed
- Dummy app helper no longer overrides `dom_id`, ensuring engine-provided behavior is exercised.
- README now documents `dom_id` usage with controller/view examples and conflict semantics.

## [0.2.1] - 2026-03-29

### Added
- New controller helper `render_broadcast` for emitting append/prepend/update/remove/dispatch payloads directly from controllers.
- Controller helper docs in README, including usage examples and option semantics.
- Controller-level specs for helper orchestration, action validation, payload versioning, and stream authorization propagation.

### Changed
- Dummy app `TodosController#highlight` now uses `render_broadcast` with `dispatch` payloads while keeping explicit `js/json` format handling.
- `TodosController` specs now assert ActionCable dispatch payload behavior instead of model-level `broadcast_dispatch` coupling.

## [0.2.0] - 2026-03-28

### Added
- New `dispatch` broadcast action to trigger client-side custom events with `event_name` and `event_data` payload fields.

## [0.1.0] - 2026-03-24

### Added
- Initial setup of broadcast_hub Rails engine
- Stream channel for broadcasting
- JavaScript controllers (jQuery and subscription)
- Broadcaster concern for models
- Services: PayloadBuilder, Renderer, StreamKeyContext, StreamKeyResolver
- Install generator for broadcast_hub
- Configuration support
- Rubocop configuration
- RSpec test setup with dummy Rails application
- Devise integration with user authentication
- Todo model with CRUD operations and broadcasting
- Multiple UI components (alert, datatable, modal, toast, tooltip)
- Multiple JavaScript controllers (todos, toggle_theme, render_errors, resource_table)
- Localization support (English and Portuguese - Brazil)
- Test factories for users and todos

### Fixed
- Initial project setup

### Changed
- Updated Gemfile dependencies
- Enhanced dummy application with full Rails stack
