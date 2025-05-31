"""
SecuGen HU20-A Hamster Pro 20 USB Fingerprint Reader Integration Service
This service runs on Windows PC with the fingerprint scanner connected.
It provides a REST API that the web application can call to capture fingerprints.
"""

import ctypes
import ctypes.wintypes
import base64
import json
import time
from flask import Flask, request, jsonify
from flask_cors import CORS
import threading
import os
import sys

# SecuGen SDK Constants
SG_DEV_FDU05 = 0x06  # HU20 device ID
SGFDX_ERROR_NONE = 0
TEMPLATE_FORMAT_ANSI378 = 0x0100
TEMPLATE_FORMAT_SG400 = 0x0200

class SecuGenSDK:
    def __init__(self):
        self.dll = None
        self.hfpm = None
        self.device_opened = False
        self.image_width = 0
        self.image_height = 0
        
    def load_sdk(self, dll_path=None):
        """Load the SecuGen SDK DLL"""
        try:
            if dll_path is None:
                # Try to find the DLL in common locations
                possible_paths = [
                    "sgfplib.dll",
                    "bin/x64/sgfplib.dll",
                    "bin/i386/sgfplib.dll",
                    os.path.join(os.path.dirname(__file__), "sgfplib.dll")
                ]
                
                for path in possible_paths:
                    if os.path.exists(path):
                        dll_path = path
                        break
                        
                if dll_path is None:
                    raise FileNotFoundError("SecuGen SDK DLL not found")
            
            self.dll = ctypes.WinDLL(dll_path)
            
            # Define function prototypes
            self._define_functions()
            
            # Create SGFPM object
            self.hfpm = ctypes.wintypes.HANDLE()
            result = self.dll.SGFPM_Create(ctypes.byref(self.hfpm))
            
            if result != SGFDX_ERROR_NONE:
                raise Exception(f"Failed to create SGFPM object: {result}")
                
            print("SecuGen SDK loaded successfully")
            return True
            
        except Exception as e:
            print(f"Error loading SecuGen SDK: {e}")
            return False
    
    def _define_functions(self):
        """Define function prototypes for the SecuGen SDK"""
        # SGFPM_Create
        self.dll.SGFPM_Create.argtypes = [ctypes.POINTER(ctypes.wintypes.HANDLE)]
        self.dll.SGFPM_Create.restype = ctypes.wintypes.DWORD
        
        # SGFPM_Init
        self.dll.SGFPM_Init.argtypes = [ctypes.wintypes.HANDLE, ctypes.wintypes.DWORD]
        self.dll.SGFPM_Init.restype = ctypes.wintypes.DWORD
        
        # SGFPM_OpenDevice
        self.dll.SGFPM_OpenDevice.argtypes = [ctypes.wintypes.HANDLE, ctypes.wintypes.DWORD]
        self.dll.SGFPM_OpenDevice.restype = ctypes.wintypes.DWORD
        
        # SGFPM_CloseDevice
        self.dll.SGFPM_CloseDevice.argtypes = [ctypes.wintypes.HANDLE]
        self.dll.SGFPM_CloseDevice.restype = ctypes.wintypes.DWORD
        
        # SGFPM_GetImage
        self.dll.SGFPM_GetImage.argtypes = [ctypes.wintypes.HANDLE, ctypes.POINTER(ctypes.c_ubyte)]
        self.dll.SGFPM_GetImage.restype = ctypes.wintypes.DWORD
        
        # SGFPM_GetDeviceInfo
        self.dll.SGFPM_GetDeviceInfo.argtypes = [ctypes.wintypes.HANDLE, ctypes.c_void_p]
        self.dll.SGFPM_GetDeviceInfo.restype = ctypes.wintypes.DWORD
        
        # SGFPM_CreateTemplate
        self.dll.SGFPM_CreateTemplate.argtypes = [
            ctypes.wintypes.HANDLE, 
            ctypes.c_void_p, 
            ctypes.POINTER(ctypes.c_ubyte), 
            ctypes.POINTER(ctypes.c_ubyte)
        ]
        self.dll.SGFPM_CreateTemplate.restype = ctypes.wintypes.DWORD
        
        # SGFPM_GetTemplateSize
        self.dll.SGFPM_GetTemplateSize.argtypes = [
            ctypes.wintypes.HANDLE, 
            ctypes.POINTER(ctypes.c_ubyte), 
            ctypes.POINTER(ctypes.wintypes.DWORD)
        ]
        self.dll.SGFPM_GetTemplateSize.restype = ctypes.wintypes.DWORD
        
        # SGFPM_MatchTemplate
        self.dll.SGFPM_MatchTemplate.argtypes = [
            ctypes.wintypes.HANDLE,
            ctypes.POINTER(ctypes.c_ubyte),
            ctypes.POINTER(ctypes.c_ubyte),
            ctypes.wintypes.DWORD,
            ctypes.POINTER(ctypes.wintypes.BOOL)
        ]
        self.dll.SGFPM_MatchTemplate.restype = ctypes.wintypes.DWORD
        
        # SGFPM_Terminate
        self.dll.SGFPM_Terminate.argtypes = [ctypes.wintypes.HANDLE]
        self.dll.SGFPM_Terminate.restype = ctypes.wintypes.DWORD
    
    def initialize_device(self):
        """Initialize the fingerprint device"""
        try:
            if not self.dll or not self.hfpm:
                return False
                
            # Initialize with HU20 device
            result = self.dll.SGFPM_Init(self.hfpm, SG_DEV_FDU05)
            if result != SGFDX_ERROR_NONE:
                print(f"Failed to initialize device: {result}")
                return False
            
            # Open device (device ID 0 for auto-detect)
            result = self.dll.SGFPM_OpenDevice(self.hfpm, 0)
            if result != SGFDX_ERROR_NONE:
                print(f"Failed to open device: {result}")
                return False
            
            self.device_opened = True
            
            # Get device info to determine image dimensions
            self._get_device_info()
            
            print("SecuGen device initialized successfully")
            return True
            
        except Exception as e:
            print(f"Error initializing device: {e}")
            return False
    
    def _get_device_info(self):
        """Get device information including image dimensions"""
        try:
            # Define SGDeviceInfoParam structure
            class SGDeviceInfoParam(ctypes.Structure):
                _fields_ = [
                    ("DeviceID", ctypes.wintypes.DWORD),
                    ("DeviceSN", ctypes.c_ubyte * 16),
                    ("ComPort", ctypes.wintypes.DWORD),
                    ("ComSpeed", ctypes.wintypes.DWORD),
                    ("ImageWidth", ctypes.wintypes.DWORD),
                    ("ImageHeight", ctypes.wintypes.DWORD),
                    ("Contrast", ctypes.wintypes.DWORD),
                    ("Brightness", ctypes.wintypes.DWORD),
                    ("Gain", ctypes.wintypes.DWORD),
                    ("ImageDPI", ctypes.wintypes.DWORD),
                    ("FWVersion", ctypes.wintypes.DWORD),
                ]
            
            device_info = SGDeviceInfoParam()
            result = self.dll.SGFPM_GetDeviceInfo(self.hfpm, ctypes.byref(device_info))
            
            if result == SGFDX_ERROR_NONE:
                self.image_width = device_info.ImageWidth
                self.image_height = device_info.ImageHeight
                print(f"Device info - Width: {self.image_width}, Height: {self.image_height}")
            
        except Exception as e:
            print(f"Error getting device info: {e}")
            # Use default values for HU20
            self.image_width = 260
            self.image_height = 300
    
    def capture_fingerprint(self):
        """Capture a fingerprint and return the template"""
        try:
            if not self.device_opened:
                return None, "Device not opened"
            
            # Allocate buffer for image
            image_size = self.image_width * self.image_height
            image_buffer = (ctypes.c_ubyte * image_size)()
            
            # Capture image
            result = self.dll.SGFPM_GetImage(self.hfpm, image_buffer)
            if result != SGFDX_ERROR_NONE:
                return None, f"Failed to capture image: {result}"
            
            # Create template from image
            template_buffer = (ctypes.c_ubyte * 1024)()  # Max template size
            
            # Define SGFingerInfo structure
            class SGFingerInfo(ctypes.Structure):
                _fields_ = [
                    ("FingerNumber", ctypes.wintypes.WORD),
                    ("ViewNumber", ctypes.wintypes.WORD),
                    ("ImpressionType", ctypes.wintypes.WORD),
                    ("ImageQuality", ctypes.wintypes.WORD),
                ]
            
            finger_info = SGFingerInfo()
            finger_info.FingerNumber = 1
            finger_info.ViewNumber = 1
            finger_info.ImpressionType = 0  # Live scan plain
            finger_info.ImageQuality = 50
            
            result = self.dll.SGFPM_CreateTemplate(
                self.hfpm, 
                ctypes.byref(finger_info), 
                image_buffer, 
                template_buffer
            )
            
            if result != SGFDX_ERROR_NONE:
                return None, f"Failed to create template: {result}"
            
            # Get actual template size
            template_size = ctypes.wintypes.DWORD()
            result = self.dll.SGFPM_GetTemplateSize(self.hfpm, template_buffer, ctypes.byref(template_size))
            
            if result != SGFDX_ERROR_NONE:
                return None, f"Failed to get template size: {result}"
            
            # Convert template to base64 string
            template_bytes = bytes(template_buffer[:template_size.value])
            template_b64 = base64.b64encode(template_bytes).decode('utf-8')
            
            return template_b64, None
            
        except Exception as e:
            return None, f"Error capturing fingerprint: {e}"
    
    def match_templates(self, template1_b64, template2_b64):
        """Match two fingerprint templates"""
        try:
            if not self.device_opened:
                return False, "Device not opened"
            
            # Decode base64 templates
            template1_bytes = base64.b64decode(template1_b64)
            template2_bytes = base64.b64decode(template2_b64)
            
            # Create ctypes arrays
            template1 = (ctypes.c_ubyte * len(template1_bytes))(*template1_bytes)
            template2 = (ctypes.c_ubyte * len(template2_bytes))(*template2_bytes)
            
            # Perform matching
            matched = ctypes.wintypes.BOOL()
            result = self.dll.SGFPM_MatchTemplate(
                self.hfpm, 
                template1, 
                template2, 
                5,  # Security level (SL_NORMAL)
                ctypes.byref(matched)
            )
            
            if result != SGFDX_ERROR_NONE:
                return False, f"Matching failed: {result}"
            
            return bool(matched.value), None
            
        except Exception as e:
            return False, f"Error matching templates: {e}"
    
    def close_device(self):
        """Close the device and cleanup"""
        try:
            if self.device_opened:
                self.dll.SGFPM_CloseDevice(self.hfpm)
                self.device_opened = False
            
            if self.hfpm:
                self.dll.SGFPM_Terminate(self.hfpm)
                self.hfpm = None
                
            print("SecuGen device closed")
            
        except Exception as e:
            print(f"Error closing device: {e}")

# Global SDK instance
sdk = SecuGenSDK()

# Flask service for fingerprint operations
app = Flask(__name__)
CORS(app, origins=["*"])  # Allow all origins for local network access

@app.route('/api/fingerprint/status', methods=['GET'])
def get_status():
    """Get the status of the fingerprint service"""
    return jsonify({
        "status": "running",
        "device_opened": sdk.device_opened,
        "sdk_loaded": sdk.dll is not None,
        "timestamp": time.time()
    })

@app.route('/api/fingerprint/capture', methods=['POST'])
def capture_fingerprint():
    """Capture a fingerprint and return the template"""
    try:
        template, error = sdk.capture_fingerprint()
        
        if error:
            return jsonify({"error": error}), 500
        
        return jsonify({
            "success": True,
            "template": template,
            "timestamp": time.time()
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/fingerprint/match', methods=['POST'])
def match_fingerprints():
    """Match two fingerprint templates"""
    try:
        data = request.json
        template1 = data.get('template1')
        template2 = data.get('template2')
        
        if not template1 or not template2:
            return jsonify({"error": "Both templates required"}), 400
        
        matched, error = sdk.match_templates(template1, template2)
        
        if error:
            return jsonify({"error": error}), 500
        
        return jsonify({
            "matched": matched,
            "timestamp": time.time()
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/fingerprint/initialize', methods=['POST'])
def initialize_device():
    """Initialize the fingerprint device"""
    try:
        if sdk.initialize_device():
            return jsonify({"success": True, "message": "Device initialized"})
        else:
            return jsonify({"error": "Failed to initialize device"}), 500
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("Starting SecuGen Fingerprint Service...")
    
    # Load SDK
    if sdk.load_sdk():
        print("SDK loaded successfully")
        
        # Initialize device
        if sdk.initialize_device():
            print("Device initialized successfully")
        else:
            print("Warning: Device initialization failed. Service will still run.")
    else:
        print("Warning: SDK loading failed. Service will run in simulation mode.")
    
    try:
        # Start Flask service
        print("Starting fingerprint service on http://0.0.0.0:5001")
        print("This service will be accessible from other computers on the network")
        app.run(host='0.0.0.0', port=5001, debug=False)
    except KeyboardInterrupt:
        print("\nShutting down...")
    finally:
        sdk.close_device()
