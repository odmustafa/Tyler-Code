# SecuGen HU20-A Hamster Pro 20 Integration

## 🎯 Quick Start

### **Windows PC (with fingerprint scanner):**
1. Run `setup_windows_service.bat`
2. Start service: `python windows_fingerprint_service.py`
3. Service runs on `http://localhost:5001`

### **MacBook (web application):**
1. Web app automatically detects fingerprint service
2. Falls back to simulation if service unavailable
3. Network access: `http://[WINDOWS_PC_IP]:5001`

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `windows_fingerprint_service.py` | Main Windows service for fingerprint operations |
| `setup_windows_service.bat` | Automated setup script for Windows |
| `test_integration.py` | Test script to verify integration |
| `requirements.txt` | Python dependencies |
| `README.md` | This file |

## 🔧 Architecture

```
┌─────────────────┐    Network     ┌─────────────────┐
│   MacBook       │    Request     │   Windows PC    │
│                 │ ──────────────► │                 │
│ React Web App   │                │ Python Service  │
│ (Frontend)      │ ◄────────────── │ (Port 5001)     │
│                 │    Response    │                 │
└─────────────────┘                └─────────────────┘
                                            │
                                            │ USB
                                            ▼
                                   ┌─────────────────┐
                                   │ SecuGen HU20-A  │
                                   │ Fingerprint     │
                                   │ Scanner         │
                                   └─────────────────┘
```

## 🚀 Features

### **Hardware Integration:**
- ✅ SecuGen HU20-A Hamster Pro 20 support
- ✅ Real-time fingerprint capture
- ✅ Template generation and matching
- ✅ Device status monitoring

### **Network Bridge:**
- ✅ REST API for fingerprint operations
- ✅ Cross-platform network access
- ✅ Automatic service discovery
- ✅ Graceful fallback to simulation

### **Security:**
- ✅ Encrypted fingerprint templates
- ✅ No raw image storage
- ✅ Local network only
- ✅ Template-based matching

## 📋 API Reference

### **GET /api/fingerprint/status**
Check service and device status

**Response:**
```json
{
  "status": "running",
  "device_opened": true,
  "sdk_loaded": true,
  "timestamp": 1234567890
}
```

### **POST /api/fingerprint/capture**
Capture fingerprint and return template

**Response:**
```json
{
  "success": true,
  "template": "base64_encoded_template",
  "timestamp": 1234567890
}
```

### **POST /api/fingerprint/match**
Match two fingerprint templates

**Request:**
```json
{
  "template1": "base64_template_1",
  "template2": "base64_template_2"
}
```

**Response:**
```json
{
  "matched": true,
  "timestamp": 1234567890
}
```

## 🧪 Testing

Run the integration test:
```bash
python test_integration.py
```

Or test with custom URL:
```bash
python test_integration.py http://192.168.1.100:5001
```

## 🔍 Troubleshooting

### **Service Won't Start**
```bash
# Check Python
python --version

# Install dependencies
pip install -r requirements.txt

# Check for SDK DLL
dir sgfplib.dll
```

### **Device Not Found**
- Check USB connection
- Verify in Device Manager
- Try different USB port
- Restart service

### **Network Issues**
```bash
# Test from MacBook
curl http://[WINDOWS_PC_IP]:5001/api/fingerprint/status

# Check Windows firewall
# Allow Python or port 5001
```

## 📊 Performance

| Operation | Typical Time |
|-----------|--------------|
| Device Init | 1-2 seconds |
| Fingerprint Capture | 1-3 seconds |
| Template Generation | <500ms |
| Template Matching | <100ms |
| Network Request | 10-50ms |

## 🔒 Security Notes

- Templates are hashed and cannot be reverse-engineered
- No raw fingerprint images are stored or transmitted
- Service runs on local network only
- Windows user permissions apply to device access

## 📝 Development

### **Adding New Features:**
1. Extend the `SecuGenSDK` class
2. Add new API endpoints to Flask app
3. Update the JavaScript client
4. Test with `test_integration.py`

### **Debugging:**
- Enable debug mode in Flask app
- Check console output for errors
- Use Windows Event Viewer for system issues
- Monitor network traffic

## 🚀 Production Deployment

### **Windows Service Installation:**
1. Install NSSM (Non-Sucking Service Manager)
2. Create Windows service:
   ```bash
   nssm install "SecuGen Fingerprint Service" python
   nssm set "SecuGen Fingerprint Service" Arguments "C:\path\to\windows_fingerprint_service.py"
   nssm start "SecuGen Fingerprint Service"
   ```

### **Network Configuration:**
- Configure static IP for Windows PC
- Setup port forwarding if needed
- Use HTTPS for production
- Implement proper firewall rules

---

**🎉 Your SecuGen HU20-A is now integrated with the Tribute system!**
