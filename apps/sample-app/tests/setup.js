// Jest setup file
const { TextEncoder, TextDecoder } = require('util');

// Polyfill for Node.js < 12 in testing environment
global.TextEncoder = TextEncoder;
global.TextDecoder = TextDecoder;

// Mock console methods in tests to reduce noise
const originalConsole = { ...console };
beforeEach(() => {
  global.console = {
    ...originalConsole,
    log: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  };
});

afterEach(() => {
  global.console = originalConsole;
  jest.clearAllMocks();
});