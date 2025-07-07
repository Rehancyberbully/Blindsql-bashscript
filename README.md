# Blindsql-bashscript
Blind SQL Injection Exploiter
A Python + Bash script to automate boolean-based blind SQL injection attacks for penetration testing and security research.

🔥 Features
✔ Multi-threading – Faster brute-forcing with configurable threads
✔ WAF Evasion – Random delays & user-agent rotation
✔ Real-time Output – Displays extracted characters dynamically
✔ Logging – Saves results to a file for analysis

⚠️ Legal & Ethical Use
For educational purposes only (e.g., CTFs, PortSwigger Labs).

Do not use on unauthorized systems. Always get explicit permission.

bash
./rehancyberbully.sh -u https://vulnerable-site.com -t "TrackingId=123" -s "session=abc"
📌 Ideal for:

Security researchers testing blind SQLi vulnerabilities

Red teamers practicing ethical hacking

Bug bounty hunters (where permitted)

## 🛠 Installation & Usage
```bash
git clone https://github.com/Rehancyberbully/Blindsql-bashscript.git
cd Blindsql-bashscript
chmod +x rehancyberbully.sh
rehancyberbully.sh -u https://test-site.com -t "TrackingId=123" -s "session=abc"
