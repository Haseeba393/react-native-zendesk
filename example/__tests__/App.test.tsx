/**
 * @format
 */

import React from 'react';
import ReactTestRenderer from 'react-test-renderer';
import App from '../App';

jest.mock('react-native-zendesk', () => ({
  initializeZendesk: jest.fn(),
  getZendeskArticles: jest.fn(),
  searchZendeskArticles: jest.fn(),
  createZendeskTicket: jest.fn(),
  openZendeskHelpCenter: jest.fn(),
  openZendeskArticle: jest.fn(),
  ZendeskHelpCenterView: 'ZendeskHelpCenterView',
}));

test('renders correctly', async () => {
  await ReactTestRenderer.act(() => {
    ReactTestRenderer.create(<App />);
  });
});
