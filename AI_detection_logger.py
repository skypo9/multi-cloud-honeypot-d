import requests
import google.generativeai as genai
from datetime import datetime
import subprocess
import time
import json
import urllib3  # For suppressing SSL warnings

# Disable SSL warnings (optional)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ===================== CONFIGURATION =====================
GEMINI_API_KEY = "abcsed"     #replace this with your own API key
genai.configure(api_key=GEMINI_API_KEY)
gemini_model = genai.GenerativeModel("gemini-1.5-flash")

# Elasticsearch Config (Note: Use HTTPS if SSL is enabled)
ELK_HOST = "https://localhost:9200"  # Change to HTTPS if needed
ELK_INDEX = "cowrie-*"
ES_USER = "username"			#Replace this with your elastic username
ES_PASS = "xxxxxxxxxxxxxxxx"		#Replace this with your elastic password

# ===================== FUNCTIONS =====================
def analyze_with_gemini(text):
    try:
        response = gemini_model.generate_content(text)
        return response.text.strip()
    except Exception as e:
        return f"[ERROR] Gemini failed: {str(e)}"

def block_ip(ip):
    try:
        subprocess.run(["sudo", "iptables", "-A", "INPUT", "-s", ip, "-j", "DROP"], check=True)
        print(f"[+] Blocked IP via iptables: {ip}")
    except Exception as e:
        print(f"[✗] Failed to block IP {ip}: {str(e)}")

def process_logs():
    print("[*] Starting AI log monitor...")
    seen_ids = set()

    while True:
        try:
            es_query = {
                "size": 50,
                "query": {
                    "range": {
                        "@timestamp": {
                            "gte": "now-2m",
                            "lte": "now"
                        }
                    }
                }
            }

            res = requests.get(
                f"{ELK_HOST}/{ELK_INDEX}/_search",
                auth=(ES_USER, ES_PASS),
                headers={"Content-Type": "application/json"},
                data=json.dumps(es_query),
                verify=False  # Disables SSL certificate verification
            )

            logs = res.json().get("hits", {}).get("hits", [])
            for entry in logs:
                doc_id = entry["_id"]
                if doc_id in seen_ids:
                    continue
                seen_ids.add(doc_id)

                log_data = entry["_source"]
                src_ip = log_data.get("src_ip", "unknown")

                prompt = f"Analyze this Cowrie honeypot log and detect if it's malicious:\n{json.dumps(log_data)}"
                verdict = analyze_with_gemini(prompt)

                print(f"\n[AI Verdict for {src_ip}]:\n{verdict}\n")

                if any(keyword in verdict.lower() for keyword in ["suspicious", "malicious", "attack", "brute force"]):
                    block_ip(src_ip)

        except requests.exceptions.SSLError as e:
            print(f"[SSL ERROR] Certificate verification failed: {str(e)}")
        except Exception as e:
            print(f"[ERROR] Failed log check cycle: {str(e)}")

        time.sleep(240)  # Check every 2 minutes

if __name__ == "__main__":
    process_logs()