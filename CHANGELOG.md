# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

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
