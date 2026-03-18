import re
import os
import argparse
import base64
import codecs

# Configuration: Patterns for CTF
HASH_PATTERNS = {
    "MD5": r"\b[a-fA-F0-9]{32}\b",
    "SHA-1": r"\b[a-fA-F0-9]{40}\b",
    "SHA-256": r"\b[a-fA-F0-9]{64}\b",
    "BCRYPT": r"\$2[ayb]\$.{56}",
    "ASTRA-TOKEN": r"\b[a-fA-F0-9]{15,16}\b",
    "BASE64": r"(?:[A-Za-z0-9+/]{4}){2,}(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?"
}

def decode_base64(data):
    try:
        decoded = base64.b64decode(data).decode('utf-8', errors='ignore')
        # Check if decoded data looks like a token or useful text
        if len(decoded) > 4:
            return decoded
    except:
        return None
    return None

def check_rot13(data):
    # Common in CTFs to hide "flag{...}" or "token:..."
    decoded = codecs.encode(data, 'rot_13')
    if "token" in decoded.lower() or "flag" in decoded.lower():
        return decoded
    return None

def extract_and_log(target_path, log_file):
    print(f"[*] Analyzing {target_path}...")
    findings = []
    
    for root, dirs, files in os.walk(target_path):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', errors='ignore') as f:
                    content = f.read()
                    for name, pattern in HASH_PATTERNS.items():
                        matches = re.findall(pattern, content)
                        for match in matches:
                            entry = [file_path, name, match, ""]
                            
                            # Auto-Decoding Logic
                            if name == "BASE64":
                                decoded = decode_base64(match)
                                if decoded:
                                    entry[3] = f"Decoded: {decoded}"
                            
                            # Check for ROT13 in any string
                            r13 = check_rot13(match)
                            if r13:
                                entry[3] += f" | ROT13: {r13}"
                                
                            findings.append(entry)
            except:
                continue

    with open(log_file, 'w') as log:
        log.write("File | Type | Raw Value | Extra Info\n" + "-"*60 + "\n")
        for f in findings:
            line = f"{f[0]} | {f[1]} | {f[2]} | {f[3]}"
            print(f"[+] Found: {line}")
            log.write(line + "\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", required=True)
    parser.add_argument("-o", "--output", default="loot.txt")
    args = parser.parse_args()
    extract_and_log(args.path, args.output)
