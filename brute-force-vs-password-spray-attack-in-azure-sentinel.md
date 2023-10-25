# Brute force attack

![image](https://user-images.githubusercontent.com/89901373/236691579-0459dafd-8123-4a3e-8b39-9ca128eb4488.png)


A brute password attack is using multiple passwords (automated via a password file, for example) to attack one user account. This attack is easily detected by security systems, and the account is locked out, for example (Azure AD Smart Lockout is a feature to protect the user against this type of attack).

# Password spray attack
![image](https://user-images.githubusercontent.com/89901373/236691601-c91b59ed-7875-41e7-9bec-4a618dcb9eb8.png)

A password spray attack is using one (often used) password to attack multiple users. This attack method is not easily detected by security systems.

## Logs
The Logs section provides easy access to the KQL to query the data in the log analytics workspace (which can be later used in Incident- or Hunting rules). The Table which we will use is SigninLogs, and the column for the alerts is ResultType.


SigninLogs -->	ResultType -->	50126 -->	Invalid username or password

SigninLogs -->	ResultType	--> 50053	--> Account is locked | Sign-in was blocked

# Brute Force Attack

The query to use must only show the ResultType(s) from > one IP-address & > one Country. The result is the query below (set the time range to 7 or 30 days, for example).

![image](https://user-images.githubusercontent.com/89901373/236691560-91336805-7188-4692-8d4a-c276ef9b1bff.png)

The output of the query is shown below (names are anonymized).
![image](https://user-images.githubusercontent.com/89901373/236691652-4d63eb8b-d889-4eec-b010-f5260bba7468.png)

As you can see, user ‘anonymous’ is attacked by different IP-addresses (258) from different countries. Unless user ‘anonymous’ is making a ‘world trip,’ this can be an example of brute password attack, different IP-addresses and countries are used to hide detection.

# Password Spray attack

The query to use must only show the ResultType(s) from > 1 User(s). The result is the query below (set the time range to 7 or 30 days, for example).
![image](https://user-images.githubusercontent.com/89901373/236691699-77ddb925-8719-484f-ac68-c931ad92669a.png)

The output of the query is shown below (names are anonymized).
![image](https://user-images.githubusercontent.com/89901373/236691709-f50730d4-9211-4708-bd65-ce2564e35147.png)

The output shows an IP-address (219.93.121.22, which is Malaysia, see https://www.abuseipdb.com/check/219.93.121.22) attacking multiple users within the organization. This can be an example of a password spray attack.

# Workbooks
Workbooks can be used to provide an overview of the attacks visible on a world map (for example, Asia might be more malicious then Europe for a Dutch organization). We can use the information (query and map settings) below to get a visual world map of the password attack(s) on the Office 365 (Azure AD) Tenant.

![image](https://user-images.githubusercontent.com/89901373/236691759-4e90f5f3-abaa-4d28-bb0c-50f289f7f0fd.png)

![image](https://user-images.githubusercontent.com/89901373/236691782-d1b35bda-5d14-434c-8fa8-fef0bc9e583b.png)

[More Info](https://www.inspark.nl/brute-force-vs-password-spray-attack-in-azure-sentinel/)

