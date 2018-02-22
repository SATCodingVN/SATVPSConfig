#SET
apacheconf = "/usr/local/apache2/conf"
scriptdir = $PWD;
echo "# SAT_CODING # VPS INSTALLER _ `uname -a`" &> /root/sat_install.logs
mkdir "/root/SAT"
mkdir "/var/SAT"
echo "uname -a: `uname -a`" >> /root/sat_install.logs

echo "Set new pass mysql: ";
read mysql_password
echo "Install Necessary Software"

echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" &> /etc/yum.repos.d/MARIADB.repo && yum update -y && yum install -y mariadb mariadb-server && yum install autoconf expat-devel libtool libnghttp2-devel pcre-devel -y && yum install -y epel-release && yum install -y autoconf gcc libxml2-devel openssl-devel bzip2-devel curl-devel enchant-devel libjpeg-turbo-devel libpng-devel freetype-devel libicu-devel libmcrypt-devel aspell-devel readline-devel libxslt-devel expat-devel lynx && yum group install "Development Tools" -y && yum -y install gcc.x86_64 pcre-devel.x86_64 openssl-devel.x86_64 git wget unzip zip
to_root(){
	cd "/root/SAT"
}
install_apache(){
	to_root
	wget http://www-eu.apache.org/dist//httpd/httpd-2.4.29.tar.gz
	tar -xvf httpd-2.4.29.tar.gz
	mv httpd-2.4.29 httpd
	cd httpd/srclib
	wget http://www-eu.apache.org/dist//apr/apr-1.6.3.tar.gz
	tar -xvf apr-1.6.3.tar.gz
	mv apr-1.6.3 apr
	wget http://www-eu.apache.org/dist//apr/apr-util-1.6.1.tar.gz
	tar -xvf apr-util-1.6.1.tar.gz
	mv apr-util-1.6.1 apr-util
	cd ../
	./buildconf
	./configure --enable-ssl --enable-so --enable-http2 --with-mpm=worker --with-included-apr --with-ssl=/usr/local/openssl --prefix=/usr/local/apache2 --enable-rewrite
	make && make install
	yes | cp -rf "$scriptdir/config/httpd.conf" "/usr/local/apache2/conf/httpd.conf"
	ln -s /usr/local/apache2/bin/* /usr/bin/
	mkdir /var/SAT/SATdocs
	mkdir /var/SAT/SATPacks

	to_root
}
install_php7(){
	to_root
	wget -O php-7.2.2.tar.gz http://au1.php.net/get/php-7.2.2.tar.gz/from/this/mirror
	tar -xvf php-7.2.2.tar.gz
	cd php-7.2.2
	./buildconf --force
	./configure --prefix=/usr/local/php7 --with-bz2 --with-zlib --enable-zip --disable-cgi \
   --enable-soap --enable-intl --with-mcrypt --with-openssl --with-readline --with-curl \
   --enable-ftp --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
   --enable-sockets --enable-pcntl --with-pspell --with-enchant --with-gettext \
   --with-gd --enable-exif --with-jpeg-dir --with-png-dir --with-freetype-dir --with-xsl \
   --enable-bcmath --enable-mbstring --enable-calendar --enable-simplexml --enable-json \
   --enable-hash --enable-session --enable-xml --enable-wddx --enable-opcache \
   --with-pcre-regex --with-config-file-path=/usr/local/php7/cli \
   --with-config-file-scan-dir=/usr/local/php7/etc --enable-cli --enable-maintainer-zts \
   --with-tsrm-pthreads --enable-debug --enable-fpm \
   --with-fpm-user=www-data --with-fpm-group=www-data \
   --with-apxs2=/usr/local/apache2/bin/apxs
	 make
	 make install
	 ln -s /usr/local/php7/bin/* /usr/bin/
	 mkdir /usr/local/php7/cli/
	 install_pthreads

}
install_pthreads(){
	to_root
	wget -O pthreads.zip https://github.com/krakjoe/pthreads/archive/master.zip
	unzip pthreads.zip
	cd pthreads/
	autoconf -i
	./buildconf
	./configure
	make && make install
	yes | cp -rf "$scriptdir/config/php.ini" "/usr/local/php7/cli/php.ini"
	yes | cp -rf "$scriptdir/config/php-cli.ini" "/usr/local/php7/cli/php-cli.ini"
	if ["`php -m | grep pthreads`" == "pthreads"]
		echo "INSTALL SUCCESS PTHREADS"
	fi
}
install_phpmyadmin(){
	to_root
	cd /var/SAT/SATPacks
	wget https://files.phpmyadmin.net/phpMyAdmin/4.7.8/phpMyAdmin-4.7.8-all-languages.zip
	unzip phpMyAdmin-4.7.8-all-languages.zip
	mv phpMyAdmin-4.7.8-all-languages phpMyAdmin
	rm -rf phpMyAdmin-4.7.8-all-languages.zip
}

install_apache
install_php7
install_phpmyadmin
