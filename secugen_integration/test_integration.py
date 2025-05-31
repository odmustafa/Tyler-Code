#!/usr/bin/env python3
"""
Test script for SecuGen HU20-A integration
This script tests the fingerprint service functionality
"""

import requests
import json
import time
import sys

def test_service_connection(base_url):
    """Test if the fingerprint service is running"""
    try:
        response = requests.get(f"{base_url}/api/fingerprint/status", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("✅ Service Status:")
            print(f"   - Status: {data.get('status', 'unknown')}")
            print(f"   - Device Opened: {data.get('device_opened', False)}")
            print(f"   - SDK Loaded: {data.get('sdk_loaded', False)}")
            return True
        else:
            print(f"❌ Service responded with status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to connect to service: {e}")
        return False

def test_device_initialization(base_url):
    """Test device initialization"""
    try:
        response = requests.post(f"{base_url}/api/fingerprint/initialize", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print("✅ Device Initialization:")
            print(f"   - Success: {data.get('success', False)}")
            print(f"   - Message: {data.get('message', 'No message')}")
            return True
        else:
            data = response.json()
            print(f"❌ Device initialization failed: {data.get('error', 'Unknown error')}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to initialize device: {e}")
        return False

def test_fingerprint_capture(base_url):
    """Test fingerprint capture"""
    print("\n🔍 Testing fingerprint capture...")
    print("Please place your finger on the scanner when prompted.")
    
    input("Press Enter when ready to capture fingerprint...")
    
    try:
        response = requests.post(f"{base_url}/api/fingerprint/capture", timeout=30)
        if response.status_code == 200:
            data = response.json()
            print("✅ Fingerprint Capture:")
            print(f"   - Success: {data.get('success', False)}")
            template = data.get('template', '')
            print(f"   - Template Length: {len(template)} characters")
            print(f"   - Template Preview: {template[:50]}...")
            return template
        else:
            data = response.json()
            print(f"❌ Fingerprint capture failed: {data.get('error', 'Unknown error')}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to capture fingerprint: {e}")
        return None

def test_template_matching(base_url, template1, template2):
    """Test template matching"""
    try:
        payload = {
            "template1": template1,
            "template2": template2
        }
        response = requests.post(
            f"{base_url}/api/fingerprint/match", 
            json=payload, 
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            matched = data.get('matched', False)
            print("✅ Template Matching:")
            print(f"   - Matched: {matched}")
            return matched
        else:
            data = response.json()
            print(f"❌ Template matching failed: {data.get('error', 'Unknown error')}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to match templates: {e}")
        return False

def main():
    print("🧪 SecuGen HU20-A Integration Test")
    print("=" * 40)
    
    # Default service URL
    base_url = "http://localhost:5001"
    
    # Allow custom URL
    if len(sys.argv) > 1:
        base_url = sys.argv[1]
    
    print(f"Testing service at: {base_url}")
    print()
    
    # Test 1: Service Connection
    print("1️⃣ Testing service connection...")
    if not test_service_connection(base_url):
        print("\n❌ Service connection failed. Make sure the fingerprint service is running.")
        print("Start it with: python windows_fingerprint_service.py")
        return False
    
    print()
    
    # Test 2: Device Initialization
    print("2️⃣ Testing device initialization...")
    if not test_device_initialization(base_url):
        print("\n⚠️  Device initialization failed. Service will use simulation mode.")
    
    print()
    
    # Test 3: First Fingerprint Capture
    print("3️⃣ Testing first fingerprint capture...")
    template1 = test_fingerprint_capture(base_url)
    if not template1:
        print("\n❌ First fingerprint capture failed.")
        return False
    
    print()
    
    # Test 4: Second Fingerprint Capture
    print("4️⃣ Testing second fingerprint capture...")
    print("Please use the SAME finger for matching test.")
    template2 = test_fingerprint_capture(base_url)
    if not template2:
        print("\n❌ Second fingerprint capture failed.")
        return False
    
    print()
    
    # Test 5: Template Matching
    print("5️⃣ Testing template matching...")
    matched = test_template_matching(base_url, template1, template2)
    
    print()
    
    # Test Results
    print("📊 Test Results:")
    print("=" * 20)
    if matched:
        print("✅ All tests passed! The integration is working correctly.")
        print("✅ Fingerprints matched successfully.")
    else:
        print("⚠️  Tests completed with warnings.")
        print("⚠️  Fingerprints did not match (this may be normal if different fingers were used).")
    
    print()
    print("🎉 Integration test complete!")
    
    return True

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⏹️  Test interrupted by user.")
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        sys.exit(1)
