#!/usr/bin/env node

/**
 * Test script for Wix MCP Server
 * 
 * This script tests if the Wix MCP server can be launched successfully.
 * Run with: node test-wix-mcp.js
 */

const { spawn } = require('child_process');

console.log('🧪 Testing Wix MCP Server...\n');

// Test if Node.js version meets requirements
const nodeVersion = process.version;
const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);

console.log(`📋 Node.js version: ${nodeVersion}`);

if (majorVersion < 19) {
  console.error('❌ Error: Node.js version 19.9.0 or higher is required');
  process.exit(1);
}

console.log('✅ Node.js version meets requirements\n');

// Test launching the Wix MCP server
console.log('🚀 Launching Wix MCP server...');

const mcpProcess = spawn('npx', [
  '-y',
  '--registry',
  'https://registry.npmjs.org',
  '@wix/mcp'
], {
  stdio: ['pipe', 'pipe', 'pipe']
});

let output = '';
let hasStarted = false;

mcpProcess.stdout.on('data', (data) => {
  output += data.toString();

  if (output.includes('WixMcpServer created') && !hasStarted) {
    hasStarted = true;
    console.log('✅ Wix MCP server started successfully!');
    console.log('✅ Server is ready to accept connections');

    // Kill the process after successful test
    setTimeout(() => {
      mcpProcess.kill('SIGTERM');
    }, 2000);
  }
});

mcpProcess.stderr.on('data', (data) => {
  const error = data.toString();

  // Check if this is actually an error or just normal server output
  if (error.includes('WixMcpServer created') && !hasStarted) {
    hasStarted = true;
    console.log('✅ Wix MCP server started successfully!');
    console.log('✅ Server is ready to accept connections');

    // Kill the process after successful test
    setTimeout(() => {
      mcpProcess.kill('SIGTERM');
    }, 2000);
  } else if (error.includes('404') || error.includes('Not Found')) {
    console.error('❌ Error: Wix MCP package not found');
    console.error('   Please check your internet connection and try again');
  } else if (!error.includes('starting WIX MCP server') &&
    !error.includes('Active tools:') &&
    !error.includes('Adding docs tools:') &&
    !error.includes('Starting server') &&
    !error.includes('Connecting to transport') &&
    !error.includes('Transport connected')) {
    console.error('❌ Error:', error);
  }
});

mcpProcess.on('close', (code) => {
  if (hasStarted) {
    console.log('\n🎉 Test completed successfully!');
    console.log('📝 The Wix MCP server is properly configured and working.');
    console.log('\n📚 Next steps:');
    console.log('   1. Restart your IDE to load the MCP configuration');
    console.log('   2. Try asking your AI assistant to search Wix documentation');
    console.log('   3. Explore the available tools for your project');
  } else if (code !== 0) {
    console.error(`\n❌ Test failed with exit code ${code}`);
    console.error('📝 Please check the troubleshooting section in WIX_MCP_SETUP.md');
  }
});

// Timeout after 30 seconds
setTimeout(() => {
  if (!hasStarted) {
    console.error('\n⏰ Test timed out after 30 seconds');
    console.error('📝 The server may be taking longer than expected to start');
    mcpProcess.kill('SIGTERM');
  }
}, 30000);
