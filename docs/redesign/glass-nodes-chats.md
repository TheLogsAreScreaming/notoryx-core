# Nodes and Chats redesign

Status: implementation specification; UI code not yet integrated.

## Goal
Apply NOTORYX's original hybrid glass-tactical design to Nodes and Chats without changing radio behavior.

## Requirements
- Preserve five-tab navigation and existing actions.
- Use reusable TacticalGlassPanel components where appropriate.
- Maintain accessible contrast, reduced-motion behavior and translations.
- Never add a Live Spectrum Analyzer.
- Preserve SOS, check-in and message delivery semantics.

## Before merging
- Implement screen changes, not only this specification.
- Run Flutter analyze and relevant widget tests.
- Verify Android and macOS layouts and screenshots.
