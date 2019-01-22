ansible-role-DBeaver
====================

Install DBeaver with Ansible


# Local installation : (ansible need to be installed)
```
git clone https://github.com/flaminem/ansible-role-dbeaver.git
ansible-playbook -i "localhost," --ask-sudo-pass --connection=local installation.yml
```

# Simple Usage :
```
---
 - hosts: all
   roles:
    - dbeaver
```

# Usage with version specification
```
---
 - hosts: all
   roles:
    - role: dbeaver
      dbeaver_version: "3.7.3"
```
