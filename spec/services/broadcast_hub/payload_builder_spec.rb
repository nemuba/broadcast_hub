# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BroadcastHub::PayloadBuilder do
  let(:action) { 'append' }
  let(:target) { '#target' }
  let(:content) { '<div>content</div>' }
  let(:id) { '123' }
  let(:meta) { { foo: 'bar' } }

  describe '.build' do
    subject(:build_payload) do
      described_class.build(
        action: action,
        target: target,
        content: content,
        id: id,
        meta: meta
      )
    end

    context 'with valid basic actions' do
      %w[append prepend update].each do |valid_action|
        it "builds a valid payload for #{valid_action}" do
          payload = described_class.build(
            action: valid_action,
            target: target,
            content: content,
            id: id,
            meta: meta
          )
          expect(payload[:action]).to eq(valid_action)
          expect(payload[:content]).to eq(content)
          expect(payload[:target]).to eq(target)
          expect(payload[:id]).to eq(id)
          expect(payload[:meta]).to eq(meta)
          expect(payload[:version]).to be_present
        end
      end

      it 'builds a valid payload for remove (content not required)' do
        payload = described_class.build(
          action: 'remove',
          target: target,
          content: nil,
          id: id,
          meta: meta
        )
        expect(payload[:action]).to eq('remove')
        expect(payload[:content]).to be_nil
      end
    end

    context 'with invalid inputs' do
      it 'raises error for invalid action' do
        expect {
          described_class.build(action: 'invalid', target: target, content: content, id: id)
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'invalid action')
      end

      it 'raises error for missing target' do
        expect {
          described_class.build(action: 'append', target: '', content: content, id: id)
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'target required')
      end

      it 'raises error for missing content on required actions' do
        expect {
          described_class.build(action: 'append', target: target, content: '', id: id)
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'content required')
      end

      it 'raises error for blank id' do
        expect {
          described_class.build(action: 'append', target: target, content: content, id: ' ')
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'id required')
      end

      it 'raises error if meta is not a hash' do
        expect {
          described_class.build(action: 'append', target: target, content: content, id: id, meta: 'invalid')
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'meta must be a hash')
      end
    end

    describe 'dispatch action' do
      let(:action) { 'dispatch' }
      let(:event_name) { 'my_event' }
      let(:event_data) { { key: 'value' } }

      it 'builds a valid payload for dispatch' do
        payload = described_class.build(
          action: 'dispatch',
          target: target,
          content: nil,
          id: id,
          event_name: event_name,
          event_data: event_data
        )

        expect(payload[:action]).to eq('dispatch')
        expect(payload[:event_name]).to eq(event_name)
        expect(payload[:event_data]).to eq(event_data)
        expect(payload[:content]).to be_nil
      end

      it 'raises error if event_name is blank for dispatch' do
        expect {
          described_class.build(
            action: 'dispatch',
            target: target,
            content: nil,
            id: id,
            event_name: '',
            event_data: event_data
          )
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'event_name required for dispatch')
      end

      it 'raises error if event_data is not a hash for dispatch' do
        expect {
          described_class.build(
            action: 'dispatch',
            target: target,
            content: nil,
            id: id,
            event_name: event_name,
            event_data: 'invalid'
          )
        }.to raise_error(BroadcastHub::PayloadBuilder::ValidationError, 'event_data must be a hash for dispatch')
      end

      it 'does not require content for dispatch' do
        expect {
          described_class.build(
            action: 'dispatch',
            target: target,
            content: nil,
            id: id,
            event_name: event_name
          )
        }.not_to raise_error
      end

      it 'does not include dispatch keys for non-dispatch payloads' do
        payload = described_class.build(
          action: 'append',
          target: target,
          content: content,
          id: id,
          event_name: 'ignored',
          event_data: { ignored: true }
        )

        expect(payload).not_to have_key(:event_name)
        expect(payload).not_to have_key(:event_data)
      end
    end
  end
end
