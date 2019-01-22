rdp-ubuntu
=========

Enabling rdp connection of the ubuntu machines.

Pre-Requirements
------------

1.Python must be installed on ubuntu machines

Role Variables
--------------


Dependencies
------------


Example Playbook
----------------

To run the role use this playbook

    - name: Enbale rdp for ubuntu
	  hosts: ubuntu
	  user: ubuntu
	  become: yes
      roles:
      - rdp-ubuntu

Post-Requirements
-------
1.Before making rdp connection change the password using "$sudo passwd username" 
2.Restart the xrdp service using "$sudo service xrdp restart"


Author Information
------------------

Atos Codex iFabric Team.
