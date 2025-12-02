# User & Group Management

Commands & examples for creating users and groups:
- Create user:
  sudo useradd devuser
  sudo passwd devuser

- Create group:
  sudo groupadd devteam

- Add user to group:
  sudo usermod -aG devteam devuser

- Verify:
  id devuser
  groups devuser

- Delete user/group:
  sudo userdel devuser
  sudo groupdel devteam
