# Wix MCP Setup Guide

This guide explains how to set up the Wix Model Context Protocol (MCP) server in your workspace.

## What is Wix MCP?

The Wix MCP server allows AI clients to:
- Search Wix documentation (SDK, REST API, Design System, Build Apps, Headless)
- Write code for the Wix platform
- Make API calls on Wix sites
- Access complete step-by-step instructions for multi-step workflows

## Prerequisites

✅ **Node.js 19.9.0 or higher** - Currently installed: v21.5.0

## Configuration Files Created

### 1. VS Code Configuration (`.vscode/settings.json`)
This file configures the Wix MCP server for VS Code with GitHub Copilot Chat.

### 2. Claude Desktop Configuration (`claude_desktop_config.json`)
This file can be used if you want to configure Claude Desktop to use the Wix MCP server.

## Setup Instructions

### For VS Code Users
1. The configuration is already set up in `.vscode/settings.json`
2. Restart VS Code to load the MCP server
3. The Wix MCP tools will be available in GitHub Copilot Chat

### For Claude Desktop Users
1. Copy the contents of `claude_desktop_config.json`
2. Add it to your Claude Desktop configuration file:
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
3. Restart Claude Desktop

### For Other AI Clients
Refer to the official documentation for your specific client:
- [Cursor](https://docs.cursor.com/context/model-context-protocol#configuring-mcp-servers)
- [Windsurf](https://docs.windsurf.com/windsurf/mcp)

## Available Tools

Once configured, you'll have access to these Wix MCP tools:

| Tool | Description |
|------|-------------|
| `SearchWixWDSDocumentation` | Search Wix Design System documentation |
| `SearchWixRESTDocumentation` | Search Wix REST API documentation |
| `SearchWixSDKDocumentation` | Search Wix SDK documentation |
| `SearchBuildAppsDocumentation` | Search Wix Build Apps documentation |
| `SearchWixHeadlessDocumentation` | Search Wix Headless documentation |
| `WixBusinessFlowsDocumentation` | Get step-by-step instructions for workflows |
| `ReadFullDocsArticle` | Fetch complete article content by URL |
| `ReadFullDocsMethodSchema` | Get full API method schemas |
| `ListWixSites` | Query sites for a Wix account |
| `CallWixSiteAPI` | Perform actions/queries on Wix sites |
| `ManageWixSite` | Perform site-level actions |
| `SupportAndFeedback` | Submit feedback to Wix |

## Testing the Setup

To verify the MCP server is working:

1. **In VS Code**: Ask GitHub Copilot Chat to search Wix documentation
2. **In Claude Desktop**: Ask Claude to use Wix MCP tools
3. **Command Line Test**: Run the server directly:
   ```bash
   npx -y --registry https://registry.npmjs.org @wix/mcp
   ```

## ✅ Verification Complete

The Wix MCP server has been successfully tested and is working correctly. When run, it shows:
```
--------------------------------
starting WIX MCP server
--------------------------------
WixMcpServer created with sessionId: [unique-id]
Active tools:
Adding docs tools:
Starting server
Connecting to transport
Transport connected
```

## Troubleshooting

If you encounter issues:

1. **Check Node.js version**: Ensure you have Node.js 19.9.0+
2. **Check IDE logs**: Look for MCP-related error messages
3. **Restart your IDE**: Sometimes a restart is needed to load new configurations
4. **Clear auth cache**: Delete `~/.mcp-auth` (macOS) or `C:\Users\<username>\.mcp-auth` (Windows)
5. **Run server directly**: Test with the command line to isolate issues

## Authentication

The Wix MCP server will handle authentication automatically when you first use it. You may be prompted to authenticate with your Wix account.

## Documentation

- [Official Wix MCP Documentation](https://dev.wix.com/docs/sdk/articles/use-the-wix-mcp/about-the-wix-mcp)
- [MCP Sample Prompts](https://dev.wix.com/docs/sdk/articles/use-the-wix-mcp/mcp-sample-prompts)
- [Model Context Protocol](https://modelcontextprotocol.io/introduction)

## Integration with Your Project

This Wix MCP setup will be particularly useful for your biometric integration project since you have Wix API components in the `Tribute_Biometric_Integration_Complete_All_Files/Wix_API/` directory. You can now:

- Get help with Wix HTTP functions
- Search for Wix authentication patterns
- Find documentation for Wix data collections
- Get assistance with Wix site management APIs

## Next Steps

1. Restart your IDE to load the MCP configuration
2. Try asking your AI assistant to search Wix documentation
3. Explore the available tools for your biometric integration project
