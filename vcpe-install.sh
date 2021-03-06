#!/bin/bash

# Official VestaCP Extends Installation Script
# =============================================
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  Author: Brayan Rincon <brayan262@gmail.com>
#  Created: 11/05/2020
#  Last updated: 11/05/2020
#  Version: 1.0.0
#
#  Supported Operating Systems:
#  - CentOS 6/7/8 Minimal
#  - Ubuntu server 14.04/16.04/18.04
#  - Debian 7/8
#  - 32bit and 64bit

INSTALLER_VERSION="1.0.0"
INSTALLER_NAME="VestaCP-Extend-$INSTALLER_VERSION"
INSTALLER_LARGENAME="VCP-Extends v$INSTALLER_VERSION | VestaCP Extends Tools"

REPO_VERSION="master"
REPO="https://raw.githubusercontent.com/megacreativo/VestaCP-Extend/$REPO_VERSION"


h1() {
    echo "\e[1m\e[34m$1\e[0m"
}

h2() {
    echo "\n\e[21m\e[94m$1\e[0m"
}

success() {
    echo "\e[42m\e[4m[Done]\e[0m $1"
}

failed() {
    echo -"\e[41m\e[4m[Fail]\e[0m $1"
}


# Am I root?
is_root(){
    if [ "x$(id -u)" != 'x0' ]; then
        failed 'Error: this script can only be executed by root'
        exit 1
    fi
}


#####################################################
### Display the 'welcome' splash/user warning info
#####################################################
welcome(){
    clear
    echo ""
	h1 "__     ______ ____       _______  _______ _____ _   _ ____   "
	h1 "\ \   / / ___|  _ \     | ____\ \/ /_   _| ____| \ | |  _ \  "
    h1 " \ \ / / |   | |_) |____|  _|  \  /  | | |  _| |  \| | | | \ "
    h1 "  \ V /| |___|  __/_____| |___ /  \  | | | |___| |\  | |_| | "
    h1 "   \_/  \____|_|        |_____/_/\_\ |_| |_____|_| \_|____/  "
    echo ""
	echo $INSTALLER_LARGENAME
	echo "VestaCP functionality extension"
    echo "Copyright © 2020. Powered By Mega Creativo <http://megacreativo.com>"
    echo ""
}



#####################################################
### Menu
#####################################################
menu(){
	h2 "Welcome to $INSTALLER_LARGENAME"
	echo " A) All options"

	echo " 1) Update to php 7.4 (Debian/Ubunutu Based)"
	echo " 2) Install SSL for VestaCP Dashboard and Email"
	echo " 3) Activate File Manager"
	echo " 4) Installs Templates for Laravel, ReactJS and HTTPS"
	#echo " 5) Fix config and storage in phpMyAdmin"
	echo " 6) Install WordPress"
	echo " 7) Installs Multi-PHP"
	echo ""
	echo " 0) Exit"

	read -p "Choose the option and press [ENTER]: " OPTION_MENU
}


#####################################################
### Update to php7.4 (Debian Based)
#####################################################
update_php(){
	h2 "Update to php 7.4 (Debian Based)"
	
	# Update system
	sudo apt update

	# Add the ondrej/php which has PHP 7.4 package and other required PHP extensions
	sudo apt install software-properties-common python-software-properties -y
	sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
	sudo apt update

	# Execute the following command to install PHP 7.4
	sudo apt install php7.4 -y

	# Now you need to tell Apache to use the installed version of PHP 7.4 by disabling 
	# the old PHP module (below I have mentioned php7.0, you need to use your current 
	# php version used by Apache) and enabling the new PHP module using the following command.
	a2dismod php7.2
	a2enmod php7.4

	# Installing PHP extensions.
	sudo apt install php7.4-common php7.4-zip libapache2-mod-php7.4 php7.4-cgi php7.4-cli php7.4-phpdbg php7.4-fpm libphp7.4-embed php7.4-dev php7.4-curl php7.4-gd php7.4-imap php7.4-interbase php7.4-intl php7.4-ldap php7.4-mcrypt php7.4-readline php7.4-odbc php7.4-pgsql php7.4-pspell php7.4-recode php7.4-tidy php7.4-xmlrpc php7.4 php7.4-json php-all-dev php7.4-sybase php7.4-sqlite3 php7.4-mysql php7.4-opcache php7.4-bz2 libapache2-mod-php7.4 php7.4-mbstring php7.4-pdo php7.4-dom -y
	
	# Reiniciando Apache
	sudo service apache2 restart

	success "Updated to php 7.4"
}


#####################################################
### Instala Certificado SSL para o Painel VestaCP
#####################################################
install_ssl_to_panel(){
	h2 "Starting SSL Installation "

	HOSTNAME=$(hostname)
	echo "Issuing SSL Certificate to the VestaCP Panel"
	/usr/local/vesta/bin/v-add-letsencrypt-domain 'admin' $HOSTNAME '' 'yes'

	echo "This will apply the installed SSL to the VestaCP, Exim and Dovecot daemons"
	/usr/local/vesta/bin/v-update-host-certificate admin $HOSTNAME

	echo "This will allow VestaCP to update SSL for VestaCP, Exim and dovecot daemons every time SSL is renewed"
	echo "UPDATE_HOSTNAME_SSL='yes'" >> /usr/local/vesta/conf/vesta.conf

	sleep 1
	sucess "SSL Enabled for the Panel Successfully!"
}


#####################################################
### Activating FileManager
#####################################################
activate_filemanager(){
	h2 "Starting FileManager Activation..."

	CHEKING_VESTA_FILEMANAGER="/etc/cron.hourly/vesta_filemanager"
	FILEMANAGER_DISABLED="FILEMANAGER_KEY=''"
	FILEMANAGER_ENABLED="FILEMANAGER_KEY='ILOVEREO'"


	create_shell_activate_filemanager(){
		echo '
		#!/bin/bash
		#  Author: Brayan Rincon <brayan262@gmail.com>
		#  Created: 11/05/2020
		#  Last updated: 11/05/2020
		#  Version: 1.0.0

		DISABLED="'${FILEMANAGER_DISABLED}'"
		ENABLED="'${FILEMANAGER_ENABLED}'"

		f ! grep -Fxq "$ENABLED" /usr/local/vesta/conf/vesta.conf; then
			# If it is not active it checks if it has a line but it is not activated

			# Checking if the disabled variable is the same in the file
			if grep -Fxq "$DISABLED" /usr/local/vesta/conf/vesta.conf
			then
				# Found TAG
				sed -i -e "s/$DISABLED/$ENABLED/g" /usr/local/vesta/conf/vesta.conf
			else
				# If there is no enabled or disabled line it activates
				echo $ENABLED >> /usr/local/vesta/conf/vesta.conf
			fi
		fi' >> $CHEKING_VESTA_FILEMANAGER
		chmod +x $CHEKING_VESTA_FILEMANAGER
		sudo echo "Enabling File Manager..."

		# Verifying and Updating file sudoers
		TEXT_FOR_SUDOERS='admin  ALL=(ALL) NOPASSWD: ALL'
		SUDOERS='/etc/sudoers'

		if ! grep -Fxq "$TEXT_FOR_SUDOERS" $SUDOERS; then
			#echo $TEXT_FOR_SUDOERS >> $SUDOERS
			echo ''
		fi

		### Adding task for the admin to activate FileManager
		/usr/local/vesta/bin/v-add-cron-job admin "*/2" "*" "*" "*" "*" "sudo /bin/bash /etc/cron.hourly/vesta_filemanager"
		bash $CHEKING_VESTA_FILEMANAGER

		success "FileManager Successfully Activated!"
	}

	# Checks whether it is a reboot or a new installation
	if [ -f "$CHEKING_VESTA_FILEMANAGER" ]; then
		echo "Clearing Previous Activation ..."
		rm $CHEKING_VESTA_FILEMANAGER
		create_shell_activate_filemanager
	else
		create_shell_activate_filemanager
	fi
}


#####################################################
### Install Templates
#####################################################
install_templates(){
	h2 "Install Templates..."
	PATCH_TEMPLATE="/usr/local/vesta/data/templates/web"
	git clone https://github.com/megacreativo/VestaCP-Extend.git
	cp -R VestaCP-Extend/includes/apache2 $PATCH_TEMPLATE
	cp -R VestaCP-Extend/includes/nginx $PATCH_TEMPLATE
	rm -R VestaCP-Extend
	success "Templates Installed!"
}


#####################################################
### Fixe phpMyAdmin
#####################################################
phpMyAdmin_Fixer(){
	# bash <(curl -s https://raw.githubusercontent.com/luizjr/phpMyAdmin-Fixer-VestaCP/master/pma.sh)
	echo ''
}


#####################################################
### Install WwordPress
#####################################################
install_wordpress(){
	h2 "Install WordPress"
	WPCLI=/usr/local/vesta/bin/wp

	# Check if WP CLI is Installed // Install WP CLI
	if test -f "$WPCLI"; then
		success "WP-CLI already installed."
		echo "This Script Will Update VeataCP Wordpress Installer"
		cd /usr/local/vesta/bin
		curl -O  https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
		mv wp-cli.phar wp
		chmod +x wp
		success "WP-CLI ppdated succefully."
	else
		# Installing WP-CLI
		echo "Installing WP CLI"
		cd /usr/local/vesta/bin
		curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
		mv wp-cli.phar wp
		chmod +x wp
		mkdir /usr/local/vesta/web/install
		mkdir /usr/local/vesta/web/install/wordpress
		success "WP-CLI installed succefully."
	fi

	cd /usr/local/vesta/bin
	curl -O https://raw.githubusercontent.com/megacreativo/VestaCP-Extend/master/bin/v-install-wordpress
	chmod 755 v-install-wordpress
	chmod +x v-install-wordpress

	cd /usr/local/vesta/web/install/wordpress
	curl -O https://raw.githubusercontent.com/megacreativo/VestaCP-Extend/master/web/install/wordpress/index.php
	
	cd /usr/local/vesta/web/templates/admin
	curl -O https://raw.githubusercontent.com/megacreativo/VestaCP-Extend/master/web/templates/admin/install_wp.html
	
	# Add to Navigation Admin User
    if grep -q "WordPress" /usr/local/vesta/web/templates/admin/panel.html; then
        success "VestaCP WordPress it already exists"
    else 
		LINK="		<div class=\"l-menu__item <?php if($TAB == 'WordPress' ) echo 'l-menu__item--active'; ?>\"><a href=\"/install/wordpress/\"><?=__(\"WordPress\")?></a></div>"
        sed -i "/<div class=\"l-menu clearfix noselect\">/a $LINK" /usr/local/vesta/web/templates/admin/panel.html;
    fi

	# Add to Navigation Normal User
    if grep -q "WordPress" /usr/local/vesta/web/templates/user/panel.html; then
        success "VestaCP WordPress it already exists"
    else 
		LINK="		<div class=\"l-menu__item <?php if($TAB == 'WordPress' ) echo 'l-menu__item--active'; ?>\"><a href=\"/install/wordpress/\"><?=__(\"WordPress\")?></a></div>"
        sed -i "/<div class=\"l-menu clearfix\">/a $LINK" /usr/local/vesta/web/templates/user/panel.html;
    fi

	success "VestaCP Wordpress Application Installer is SUCCESSFULLY INSTALLED/UPDATED"

}


install_multiphp(){
	wget -nv -q "$REPO/installers/php/multi-php-install.sh" -O /usr/local/vesta/installers/php/multi-php-install.sh
	chmod a+x /usr/local/vesta/installers/php/multi-php-install.sh
	
}


#####################################################
### Options
#####################################################
options(){
	# Check the option selected in the menu

	# Atualiza o PHP
	if [ "$OPTION_MENU" = '1' ]; then
		update_php
		
	# Instal SSL no Painel VestaCP
	elif [ "$OPTION_MENU" -eq 2 ]; then
		install_ssl_to_panel
		

	# Ativacao do FileManager
	elif [ "$OPTION_MENU" -eq 3 ]; then
		activate_filemanager
		
	# Instalando Templates para o VestaCP
	elif [ "$OPTION_MENU" -eq 4 ]; then
		install_templates
		
	# Corrigindo phpMyAdmin para o VestaCP
	elif [ "$OPTION_MENU" -eq 5 ]; then
		phpMyAdmin_Fixer
		
	# Install WordPress
	elif [ "$OPTION_MENU" -eq 6 ]; then
		install_wordpress

	# Install WordPress
	elif [ "$OPTION_MENU" -eq 7 ]; then
		install_multiphp

	# All
	elif [ "$OPTION_MENU" -eq 'A' ]; then
		update_php
		install_ssl_to_panel
		activate_filemanager
		install_templates
		
	elif [ "$OPTION_MENU" -eq 0 ]; then
		finalize
	else
		echo "Invalid option" && sleep 2 && clear
		setup
	fi

}


#####################################################
### Exit or continue
#####################################################
leave_or_continue(){
	read -p 'Do you really want to exit? [y:Yes/n:No]: (y)' OPTION_LEAVE

	if [ "$OPTION_LEAVE" -eq 'n' ]; then
		setup
	elif [ "$OPTION_LEAVE" -eq 'y' ]; then
		finalize
	else			
		leave_or_continue
	fi	
}


#####################################################
### Exit
#####################################################
finalize(){
	### Limpando o Terminal
	welcome	
	echo "Closing the application ." && sleep 1 && clear
	exit
}


#####################################################
### Setup
#####################################################
setup(){
	is_root
	welcome
	menu
	options
}
setup
