#!/bin/bash
##Variable declaration
LDAP_UN="compose" ##suppose i want to create a user compose in ldap in ou=api and domain= compose.canopy-cloud.com. Then write "composeapikey" here
LDAP_PS="Canopy1!" ##suppose i want to create a user compose in ldap in ou=api and domain= compose.canopy-cloud.com. Then write password for compose here
LDAP_ADMIN_PS="Canopy1!" ##admin password for ldap ex "Canopy1!"
PASS="Canopy1!" ##password of your machine ex: "Canopy1!"
USER_DOMAIN="compose.atos.net" ##example: "compose.canopy-cloud.com"
LDAP_ADMIN_USER="admin" ##username you want to give your administrator example: "admin"
SCRIPTS_PATH="/tmp/"
#Wget install
function checkWget(){
#check and Install wget if not present.
if [ ! -x /usr/bin/wget ] ; then
echo "Installing WGET on ldap machine..."!
else
echo WGET exist on amp-ldap machine
fi

}
##This function install LDAP on the machine
function install(){
echo "Starting openldap installation..."!
echo $PASS | sudo -S yum -y install openldap-servers openldap-clients
}
##This function is used to configure LDAP according to requirement
function customize(){

FIRST_DOMAIN_NAME=$(echo $USER_DOMAIN| cut -d'.' -f 1)
IFS='.' read -r -a STR_ARRAY <<< "$USER_DOMAIN"
DC_STR=""
SPACE_STR=""
for ELEMENT in "${STR_ARRAY[@]}"
do
SPACE_STR=$SPACE_STR"$ELEMENT "
DC_STR=$DC_STR"dc=$ELEMENT,"
done
DOMAIN="${DC_STR%?}"
SPACE_DOMAIN="${SPACE_STR%?}"
ROOTDN="cn=$LDAP_ADMIN_USER,"$DOMAIN

#echo $PASS | sudo -S chkconfig slapd on
echo $PASS | sudo -S systemctl enable slapd.service #for centos 7

##add domain and admin_user given by user
echo $PASS | sudo -S sed -i "s|<userDomain>|$DOMAIN|g" "$SCRIPTS_PATH"conf-files/ldap-conf/backend.ldif
echo $PASS | sudo -S sed -i "s|<rootDN>|$ROOTDN|g" "$SCRIPTS_PATH"conf-files/ldap-conf/backend.ldif
echo $PASS | sudo -S sed -i "s|<userDomain>|$DOMAIN|g" "$SCRIPTS_PATH"conf-files/ldap-conf/frontend.ldif
echo $PASS | sudo -S sed -i "s|<rootDN>|$ROOTDN|g" "$SCRIPTS_PATH"conf-files/ldap-conf/frontend.ldif
echo $PASS | sudo -S sed -i "s|<ldapUser>|$LDAP_ADMIN_USER|g" "$SCRIPTS_PATH"conf-files/ldap-conf/frontend.ldif
echo $PASS | sudo -S sed -i "s|<firstDomain>|$FIRST_DOMAIN_NAME|g" "$SCRIPTS_PATH"conf-files/ldap-conf/frontend.ldif
echo $PASS | sudo -S sed -i "s|<spaceDomain>|$SPACE_DOMAIN|g" "$SCRIPTS_PATH"conf-files/ldap-conf/frontend.ldif
echo $PASS | sudo -S sed -i "s|<userDomain>|$DOMAIN|g" "$SCRIPTS_PATH"conf-files/ldap-conf/user.ldif

##add user and password given by the user
echo $PASS | sudo -S sed -i 's|<user>|'"$LDAP_UN"'|g' "$SCRIPTS_PATH"conf-files/ldap-conf/user.ldif

PASSWORD=$(echo $PASS | sudo -S slappasswd -s $LDAP_PS)
echo $PASS | sudo -S sed -i 's|<password>|'"$PASSWORD"'|g' "$SCRIPTS_PATH"conf-files/ldap-conf/user.ldif

ADMIN_PASSWORD=$(echo $PASS | sudo -S slappasswd -s $LDAP_ADMIN_PS)
echo $PASS | sudo -S sed -i 's|<adminpassword>|'"$ADMIN_PASSWORD"'|g' "$SCRIPTS_PATH"conf-files/ldap-conf/frontend.ldif
echo $PASS | sudo -S sed -i 's|<adminpassword>|'"$ADMIN_PASSWORD"'|g' "$SCRIPTS_PATH"conf-files/ldap-conf/backend.ldif
##add the pre-configured files
echo $PASS | sudo -S rm -f /etc/sysconfig/ldap
echo $PASS | sudo -S cp "$SCRIPTS_PATH"conf-files/ldap-conf/ldap /etc/sysconfig/
echo $PASS | sudo -S cp "$SCRIPTS_PATH"conf-files/ldap-conf/slapd.conf /etc/openldap/
echo $PASS | sudo -S rm -f /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{0\}config.ldif
echo $PASS | sudo -S cp "$SCRIPTS_PATH"conf-files/ldap-conf/olcDatabase\=\{0\}config.ldif /etc/openldap/slapd.d/cn\=config/
echo $PASS | sudo -S rm -f /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{1\}monitor.ldif
echo $PASS | sudo -S cp "$SCRIPTS_PATH"conf-files/ldap-conf/olcDatabase\=\{1\}monitor.ldif /etc/openldap/slapd.d/cn\=config
##give permissions
echo $PASS | sudo -S chown -R ldap /etc/openldap/slapd.d
echo $PASS | sudo -S chmod -R 700 /etc/openldap/slapd.d
##start service
#echo $PASS | sudo -S /etc/rc.d/init.d/slapd start
echo $PASS | sudo -S systemctl restart slapd #For centos 7
##add schemas
echo $PASS | sudo -S ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/core.ldif
echo $PASS | sudo -S ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
echo $PASS | sudo -S ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
echo $PASS | sudo -S ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
##add databases
echo $PASS | sudo -S cp "$SCRIPTS_PATH"conf-files/ldap-conf/backend.ldif /etc/openldap/slapd.d/
echo $PASS | sudo -S echo $PASS | sudo -S cp "$SCRIPTS_PATH"conf-files/ldap-conf/frontend.ldif /etc/openldap/slapd.d/
echo $PASS | sudo -S ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/slapd.d/backend.ldif
echo $PASS | sudo -S ldapadd -x -D $ROOTDN -w $LDAP_ADMIN_PS -f /etc/openldap/slapd.d/frontend.ldif
##add users
echo $PASS | sudo -S cp "$SCRIPTS_PATH"conf-files/ldap-conf/user.ldif ~/
#echo $PASS | sudo -S service slapd restart
echo $PASS | sudo -S systemctl restart slapd # For centos 7
echo $PASS | sudo -S ldapadd -x -w $LDAP_ADMIN_PS -D $ROOTDN -f ~/user.ldif
#echo $PASS | sudo -S lokkit -p 389:tcp
}
##Call the functions
echo "******************* Start configuring LDAP ***************************"
checkWget
install
customize
echo "******************* LDAP configuration done ***************************"