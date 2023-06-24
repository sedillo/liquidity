# Liquidity Tracking in AWS

## Aurora setup

Create and store aurora password

```bash
HISTCONTROL=ignorespace
  aws secretsmanager create-secret --name AuroraMasterPassword --secret-string <AURORA_PASSWORD>
```
