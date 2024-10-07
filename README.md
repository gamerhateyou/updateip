# updateip
ENGLISH:


This Bash script is designed to automatically update Cloudflare DNS records when your network's public IP address changes.
Here are its main functions:

It obtains the current public IP address using an external web service.
It compares this IP with the existing DNS records for one or more domains configured on Cloudflare.
If the IP has changed, it updates the DNS records using the Cloudflare API.
It logs all actions and errors to a log file.

The script is intended to be run periodically (e.g., via a cron job) to keep DNS records up-to-date, essentially functioning as a Dynamic DNS (DDNS) service. It's particularly useful for those with a dynamic IP address who want to maintain domains that always point to their current IP address.
The script also includes several security measures, such as secure handling of API credentials, input validation, and error handling.

--------------------------------
ITALIANO:

Questo script Bash è progettato per aggiornare automaticamente i record DNS di Cloudflare quando cambia l'indirizzo IP pubblico del tuo network. 
Ecco le sue funzioni principali:

1. Ottiene l'indirizzo IP pubblico corrente utilizzando un servizio web esterno.

2. Confronta questo IP con i record DNS esistenti per uno o più domini configurati su Cloudflare.

3. Se l'IP è cambiato, aggiorna i record DNS utilizzando l'API di Cloudflare.

4. Registra tutte le azioni e gli errori in un file di log.

Lo script è pensato per essere eseguito periodicamente (ad esempio, tramite un job cron) per mantenere aggiornati i record DNS, funzionando essenzialmente come un servizio DDNS (Dynamic DNS). È particolarmente utile per chi ha un indirizzo IP dinamico ma vuole mantenere domini che puntano sempre al proprio indirizzo IP corrente.

Lo script include anche diverse misure di sicurezza, come la gestione sicura delle credenziali API, la validazione degli input e una gestione degli errori.
