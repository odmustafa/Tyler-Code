import hashlib

def generate_template_from_scan(scan_data):
    return hashlib.sha256(scan_data.encode()).digest()

def match_templates(template1, template2):
    return template1 == template2
