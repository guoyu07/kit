#!/bin/bash
#------------------------------------------------
# require: bash env
# target : nginx maker
# author : junjiemars@gmail.com
# url    : https://raw.githubusercontent.com/junjiemars/kit/master/ul/nd.sh
#------------------------------------------------

VERSION=${VER:-0.1.1}
OPT_RUN=${OPT_RUN:-`pwd`/run}

NGX_TARGET=( raw http https stream dns )
NGX_IDX=${NGX_TARGET[0]}
NGX_HOME=${NGX_HOME:-`pwd`/`ls | grep 'nginx\-release'`}
NGX_RUN_DIR=${NGX_RUN_DIR:-$OPT_RUN}
NGX_CONF_DIR=${NGX_CONF_DIR:-${NGX_RUN_DIR%/}/conf}
NGX_LOG_DIR=${NGX_LOG_DIR:-${NGX_RUN_DIR%/}/var/nginx}
NGX_OPTIONS=${NGX_OPTIONS}

NGX_ERR_LOG=error.log
NGX_PID_LOG=pid

NGX_CHAINED=( no yes )

NGX_GEN_CONF=( yes no )
NGX_GEN_SHELL=( yes no )

NGX_CONF="nginx.conf"
NGX_SHELL="nginx.sh"

OPT_CPU_N=1
OPT_CON_N=1024

OPT_LISTEN_PORT=8080
OPT_UPSTREAM=
OPT_SERVER_NAME=localhost
OPT_SERVER_TOKENS=( on off )


function usage() {
  echo -e "Usage: $(basename $0) [OPTIONS] COMMAND [arg...]"
  echo -e "       $(basename $0) [ -h | --help | -v | --version ]\n"
  echo -e "Options:"
  echo -e "  --help\t\t\tPrint this message"
  echo -e "  --version\t\t\tPrint version information and quit"
  echo -e ""
  echo -e "  --target=\t\t\twhat nginx [${NGX_TARGET[@]}] do, default is '${NGX_IDX}'"
  echo -e "  --home=\t\t\tnginx source dir, NGX_HOME='${NGX_HOME}'"
  echo -e "  --run-dir=\t\t\twhere nginx run, NGX_RUN_DIR='${NGX_RUN_DIR}'"
  echo -e "  --conf-dir=\t\t\twhere nginx conf, NGX_CONF_DIR='${NGX_CONF_DIR}'"
  echo -e "  --log-dir=\t\t\twhere nginx log store, NGX_LOG_DIR='${NGX_LOG_DIR}'"
  echo -e "  --options=\t\t\tnginx auto/configure options, NGX_OPTIONS='${NGX_OPTIONS}'"

  echo -e "  --chained\t\t\tchained commands, '${NGX_CHAINED}'"
  echo -e "  --gen-conf\t\t\tgenerate nginx.conf, default is '$NGX_GEN_CONF'"
  echo -e "  --gen-shell\t\t\tgenerate nginx.sh, default is '$NGX_GEN_SHELL'"
  echo -e ""
  echo -e "  --opt-processes=\t\toption: worker_processes, default is '$OPT_CPU_N'"
  echo -e "  --opt-connections=\t\toption: worker_connections, default is '$OPT_CON_N'"
  echo -e "  --opt-listen-port=\t\toption: listen_port, default is '$OPT_LISTEN_PORT'"
  echo -e "  --opt-upstream=\t\toption: upstream backends"
  echo -e "  --opt-server-name=\t\toption: server_name, default is '$OPT_SERVER_NAME'"
  echo -e "  --opt-server-tokens=\t\toption: server_tokens [${OPT_SERVER_TOKENS[@]}], default is '$OPT_SERVER_TOKENS'"
	echo -e ""
  echo -e "A nginx configuration and shell maker"
	echo -e ""
  echo -e "Commands:"
  echo -e "  configure\t\t\tconfigure nginx build env"
  echo -e "  make\t\t\t\tmake nginx"
  echo -e "  install\t\t\tinstall nginx"
  echo -e "  clean\t\t\t\tclean nginx build env"
  echo -e "  modules\t\t\tbuild nginx modules"
  echo -e "  upgrade\t\t\tupgrade nginx"
}


for option
do
  opt="$opt `echo $option | sed -e \"s/\(--[^=]*=\)\(.* .*\)/\1'\2'/\"`"
  
  case "$option" in
    -*=*) value=`echo "$option" | sed -e 's/[-_a-zA-Z0-9]*=//'` ;;
    *) value="" ;;
  esac
  
  case "$option" in
    --help)                  				help=yes                   				 ;;
    --version)               				version=yes                				 ;;

    --target=*)             				ngx_target=( $value ) 	  				 ;;
    --home=*)                				ngx_home="$value"    							 ;;
		--run-dir=*)             				ngx_run_dir="$value"       				 ;;
		--conf-dir=*)             			ngx_conf_dir="$value"     				 ;;
		--log-dir=*)             				ngx_log_dir="$value"       				 ;;
		--options=*)             				ngx_options="$value"       				 ;;

		--chained)               				NGX_CHAINED="yes"          				 ;;
		--gen-conf)               			NGX_GEN_CONF="no"         				 ;;
		--gen-shell)               			NGX_GEN_SHELL="no"         				 ;;

		--opt-processes=*)     					OPT_CPU_N="$value"      		       ;;
		--opt-connections=*)     				OPT_CON_N="$value"       		       ;;
		--opt-listen-port=*)     				OPT_LISTEN_PORT="$value"		       ;;
		--opt-upstream=*)								OPT_UPSTREAM=( "$value" )          ;;
		--opt-server-tokens=*)	 				OPT_SERVER_TOKENS=( "$value" )     ;;
    
    *)

			case "$option" in
				-*)
					echo "$0: error: invalid option \"$option\""
					usage
					exit 1
				;;

				*) 
      		command="$option"
				;;
			esac

    ;;
  esac
done


if [ "$help" = "yes" -o 0 -eq $# ]; then
	usage
	exit 0
fi

if [ "$version" = "yes" ]; then
	echo -e "$VERSION"
	exit 0
fi

# setup env vars
retval=0

if [ -n "$ngx_home" ]; then
	NGX_HOME="$ngx_home"
fi
if [ ! -d "$NGX_HOME" ]; then
	echo -e "! --home=$NGX_HOME  =invalid"
	exit 1
fi


if [ -n "$ngx_run_dir" ]; then
  NGX_RUN_DIR="$ngx_run_dir"
fi
if [ ! -d "$NGX_RUN_DIR" ]; then
	echo -e "! --run-dir=$NGX_RUN_DIR  =invalid, try to create ..."
	mkdir -p "$NGX_RUN_DIR"
	retval=$?
	[ 0 -eq $retval ] || exit $retval
fi

if [ -n "$ngx_conf_dir" ]; then
	NGX_CONF_DIR="$ngx_conf_dir"
fi
if [ ! -d "$NGX_CONF_DIR" ]; then
	echo -e "! --conf-dir=$NGX_CONF_DIR  =invalid, try to create ..."
	mkdir -p "$NGX_CONF_DIR"	
	retval=$?
	[ 0 -eq $retval ] || exit $retval
fi

if [ -n "$ngx_log_dir" ]; then
	NGX_LOG_DIR="$ngx_log_dir"
fi
if [ ! -d "$NGX_LOG_DIR" ]; then
	echo -e "! --log-dir=$NGX_LOG_DIR  =invalid, try to create ..."
	mkdir -p "$NGX_LOG_DIR"	
	retval=$?
	[ 0 -eq $retval ] || exit $retval
fi

if [ -n "$ngx_options" ]; then
	NGX_OPTIONS="$ngx_options"
fi

if [ -n "$ngx_target" ]; then
	for i in "${NGX_TARGET[@]}"; do
		if [ ".$ngx_target" = ".$i" ]; then
			NGX_IDX="$i"
			break
		fi
	done

	if [ "$ngx_target" != "$NGX_IDX" ]; then
    echo -e "! --target=\"$ngx_target\"  =invalid"
    exit 1
	fi
fi


function configure() {
	case "$1" in

		raw)
			echo $NGX_OPTIONS
echo "\
--prefix=$NGX_RUN_DIR"

		;;

		http)
echo "\
--prefix=$NGX_RUN_DIR                              \
--error-log-path=${NGX_LOG_DIR%/}/$NGX_ERR_LOG     \
--pid-path=${NGX_LOG_DIR%/}/$NGX_PID_LOG           \
--http-log-path=${NGX_LOG_DIR%/}/access.log        \
--without-http_memcached_module  				           \
--without-http_fastcgi_module    				           \
--without-http_scgi_module                         \
--without-http_rewrite_module
"

		;;

		stream|dns)
echo "\
--prefix=$NGX_RUN_DIR                             \
--error-log-path=${NGX_LOG_DIR%/}/$NGX_ERR_LOG    \
--pid-path=${NGX_LOG_DIR%/}/$NGX_PID_LOG          \
--with-stream                    				          \
--without-http_geo_module        				          \
--without-http_map_module        				          \
--without-http_geo_module        				          \
--without-http_map_module        				          \
--without-http_fastcgi_module    				          \
--without-http_scgi_module       				          \
--without-http_memcached_module  				          \
--without-mail_pop3_module       				          \
--without-mail_imap_module       				          \
--without-mail_smtp_module       				          \
--without-stream_geo_module      				          \
--without-stream_map_module"

		;;

		*)
		;;

	esac
}


function do_configure() {
	local c="`configure $NGX_IDX | tr -s ' '`"

	if [ "yes" = "$NGX_GEN_SHELL" ]; then
		gen_shell
	fi

	if [ "yes" = "$NGX_GEN_CONF" ]; then
		gen_conf
	fi

	cd $NGX_HOME
auto/configure $c
}


function do_make() {
	local t=0

	if [ "$NGX_CHAINED" = "yes" ]; then
		do_configure	
		t=$?
		[ 0 -eq $t ] || exit $t
	fi

	cd $NGX_HOME
	make -j4
}


function do_install() {
	local t=0
	
	if [ "yes" = "$NGX_CHAINED" ]; then
		do_make
		t=$?
		[ 0 -eq $t ] || exit $t
	fi

	cd $NGX_HOME
	make install
}

function do_clean() {
	[ -f "$NGX_CONF" ] && rm $NGX_CONF
	[ -f "$NGX_SHELL" ] && rm $NGX_SHELL

	cd $NGX_HOME
	make clean
}


function do_modules() {
	local t=0

	if [ "$NGX_CHAINED" = "yes" ]; then
		do_configure	
		t=$?
		[ 0 -eq $t ] || exit $t
	fi

	cd $NGX_HOME
	make modules
}


function do_upgrade() {
	local t=0

	cd $NGX_HOME
	make upgrade
}


function gen_conf_header() {
echo "#
# generated by nd.sh (https://github.com/junjiemars/kit)
#

worker_processes	$OPT_CPU_N;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/pid;

events {
    worker_connections	$OPT_CON_N;
}
"
}


function gen_http_section() {
echo "
http {
		#access_log  off;
    #default_type  application/octet-stream;
    #include       mime.types;
    #gzip  on;
		#gzip_min_length  1000;
		#gzip_types		text/plain application/xml;
    #keepalive_timeout  0;
    #keepalive_timeout  65;
    #sendfile        on;
    #tcp_nopush     on;

		upstream backend {
				#server x.x.x.x:8181 weight=5;
				#server x.x.x.x:8282 backup;
`
for i in ${OPT_UPSTREAM[@]}; do
		echo "\
				server $i;"
done
`

		} # end of upstream
	
    server {
        listen $OPT_LISTEN_PORT;
        server_name  localhost;
				server_tokens $OPT_SERVER_TOKENS;

				location / {
					proxy_pass http://backend;

				} # end of location

    } # end of server

} # end of http

"
}


function gen_stream_section() {
echo "
stream {

    upstream backend {
        hash \$remote_addr consistent;

        #server x.x.x.x:12345     weight=5;
        #server x.x.x.x:12345     max_fails=3 fail_timeout=30s;
`
for i in ${OPT_UPSTREAM[@]}; do
		echo "\
				server $i;"
done
`

    } # end of upstream backend

    server {
        listen $OPT_LISTEN_PORT;
        proxy_connect_timeout 1s;
        proxy_timeout 3s;
        proxy_pass backend;

    } # end of server

} # end of stream

"

}


function gen_dns_section() {
echo "
stream {

		upstream dns {
    		#server x.x.x.x:53;
`
for i in ${OPT_UPSTREAM[@]}; do
		echo "\
				server $i;"
done
`

    } # end of upstream dns

    server {
        listen $OPT_LISTEN_PORT udp;
        proxy_responses 1;
        proxy_timeout 20s;
        proxy_pass dns;

    } #end of server

} # end of stream

"
}


function gen_shell() {
	cat << END > $NGX_SHELL
#!/bin/bash

#
# generated by nd.sh (https://github.com/junjiemars/kit)
#

NGX_HOME=${NGX_RUN_DIR%/}
\${NGX_HOME}/sbin/nginx \$@

END

	[ -f $NGX_SHELL ] && chmod u+x $NGX_SHELL
}


function gen_conf_section() {
	cat << END >> $NGX_CONF
`$1`
END
}

function gen_conf() {
	cat << END > $NGX_CONF
`gen_conf_header`
END

	for i in "${NGX_IDX[@]}"; do
		gen_conf_section "gen_${i}_section"
	done

	local f="${NGX_CONF_DIR%/}/$NGX_CONF"
	if [ -f "${f}" ]; then
		mv $d/$NGX_CONF ${f}.b0
	fi
	cp $NGX_CONF ${f}
}


command="`echo $command | tr '[:upper:]' '[:lower:]'`"
case "$command" in

  configure)
		do_configure	
	;;

	make)
		do_make -j4
	;;

	install)
		do_install
	;;

	clean)
		do_clean
	;;

	modules)
		do_modules
	;;

	upgrade)
		do_upgrade
	;;

  *)
		echo "$0: error: invalid command \"$command\""
		usage
		exit 1
  ;;

esac



#  --help                             print this message
#
#  --prefix=PATH                      set installation prefix
#  --sbin-path=PATH                   set nginx binary pathname
#  --modules-path=PATH                set modules path
#  --conf-path=PATH                   set nginx.conf pathname
#  --error-log-path=PATH              set error log pathname
#  --pid-path=PATH                    set nginx.pid pathname
#  --lock-path=PATH                   set nginx.lock pathname
#
#  --user=USER                        set non-privileged user for
#                                     worker processes
#  --group=GROUP                      set non-privileged group for
#                                     worker processes
#
#  --build=NAME                       set build name
#  --builddir=DIR                     set build directory
#
#  --with-select_module               enable select module
#  --without-select_module            disable select module
#  --with-poll_module                 enable poll module
#  --without-poll_module              disable poll module
#
#  --with-threads                     enable thread pool support
#
#  --with-file-aio                    enable file AIO support
#
#  --with-http_ssl_module             enable ngx_http_ssl_module
#  --with-http_v2_module              enable ngx_http_v2_module
#  --with-http_realip_module          enable ngx_http_realip_module
#  --with-http_addition_module        enable ngx_http_addition_module
#  --with-http_xslt_module            enable ngx_http_xslt_module
#  --with-http_xslt_module=dynamic    enable dynamic ngx_http_xslt_module
#  --with-http_image_filter_module    enable ngx_http_image_filter_module
#  --with-http_image_filter_module=dynamic
#                                     enable dynamic ngx_http_image_filter_module
#  --with-http_geoip_module           enable ngx_http_geoip_module
#  --with-http_geoip_module=dynamic   enable dynamic ngx_http_geoip_module
#  --with-http_sub_module             enable ngx_http_sub_module
#  --with-http_dav_module             enable ngx_http_dav_module
#  --with-http_flv_module             enable ngx_http_flv_module
#  --with-http_mp4_module             enable ngx_http_mp4_module
#  --with-http_gunzip_module          enable ngx_http_gunzip_module
#  --with-http_gzip_static_module     enable ngx_http_gzip_static_module
#  --with-http_auth_request_module    enable ngx_http_auth_request_module
#  --with-http_random_index_module    enable ngx_http_random_index_module
#  --with-http_secure_link_module     enable ngx_http_secure_link_module
#  --with-http_degradation_module     enable ngx_http_degradation_module
#  --with-http_slice_module           enable ngx_http_slice_module
#  --with-http_stub_status_module     enable ngx_http_stub_status_module
#
#  --without-http_charset_module      disable ngx_http_charset_module
#  --without-http_gzip_module         disable ngx_http_gzip_module
#  --without-http_ssi_module          disable ngx_http_ssi_module
#  --without-http_userid_module       disable ngx_http_userid_module
#  --without-http_access_module       disable ngx_http_access_module
#  --without-http_auth_basic_module   disable ngx_http_auth_basic_module
#  --without-http_autoindex_module    disable ngx_http_autoindex_module
#  --without-http_geo_module          disable ngx_http_geo_module
#  --without-http_map_module          disable ngx_http_map_module
#  --without-http_split_clients_module disable ngx_http_split_clients_module
#  --without-http_referer_module      disable ngx_http_referer_module
#  --without-http_rewrite_module      disable ngx_http_rewrite_module
#  --without-http_proxy_module        disable ngx_http_proxy_module
#  --without-http_fastcgi_module      disable ngx_http_fastcgi_module
#  --without-http_uwsgi_module        disable ngx_http_uwsgi_module
#  --without-http_scgi_module         disable ngx_http_scgi_module
#  --without-http_memcached_module    disable ngx_http_memcached_module
#  --without-http_limit_conn_module   disable ngx_http_limit_conn_module
#  --without-http_limit_req_module    disable ngx_http_limit_req_module
#  --without-http_empty_gif_module    disable ngx_http_empty_gif_module
#  --without-http_browser_module      disable ngx_http_browser_module
#  --without-http_upstream_hash_module
#                                     disable ngx_http_upstream_hash_module
#  --without-http_upstream_ip_hash_module
#                                     disable ngx_http_upstream_ip_hash_module
#  --without-http_upstream_least_conn_module
#                                     disable ngx_http_upstream_least_conn_module
#  --without-http_upstream_keepalive_module
#                                     disable ngx_http_upstream_keepalive_module
#  --without-http_upstream_zone_module
#                                     disable ngx_http_upstream_zone_module
#
#  --with-http_perl_module            enable ngx_http_perl_module
#  --with-http_perl_module=dynamic    enable dynamic ngx_http_perl_module
#  --with-perl_modules_path=PATH      set Perl modules path
#  --with-perl=PATH                   set perl binary pathname
#
#  --http-log-path=PATH               set http access log pathname
#  --http-client-body-temp-path=PATH  set path to store
#                                     http client request body temporary files
#  --http-proxy-temp-path=PATH        set path to store
#                                     http proxy temporary files
#  --http-fastcgi-temp-path=PATH      set path to store
#                                     http fastcgi temporary files
#  --http-uwsgi-temp-path=PATH        set path to store
#                                     http uwsgi temporary files
#  --http-scgi-temp-path=PATH         set path to store
#                                     http scgi temporary files
#
#  --without-http                     disable HTTP server
#  --without-http-cache               disable HTTP cache
#
#  --with-mail                        enable POP3/IMAP4/SMTP proxy module
#  --with-mail=dynamic                enable dynamic POP3/IMAP4/SMTP proxy module
#  --with-mail_ssl_module             enable ngx_mail_ssl_module
#  --without-mail_pop3_module         disable ngx_mail_pop3_module
#  --without-mail_imap_module         disable ngx_mail_imap_module
#  --without-mail_smtp_module         disable ngx_mail_smtp_module
#
#  --with-stream                      enable TCP/UDP proxy module
#  --with-stream=dynamic              enable dynamic TCP/UDP proxy module
#  --with-stream_ssl_module           enable ngx_stream_ssl_module
#  --with-stream_realip_module        enable ngx_stream_realip_module
#  --with-stream_geoip_module         enable ngx_stream_geoip_module
#  --with-stream_geoip_module=dynamic enable dynamic ngx_stream_geoip_module
#  --with-stream_ssl_preread_module   enable ngx_stream_ssl_preread_module
#  --without-stream_limit_conn_module disable ngx_stream_limit_conn_module
#  --without-stream_access_module     disable ngx_stream_access_module
#  --without-stream_geo_module        disable ngx_stream_geo_module
#  --without-stream_map_module        disable ngx_stream_map_module
#  --without-stream_split_clients_module
#                                     disable ngx_stream_split_clients_module
#  --without-stream_return_module     disable ngx_stream_return_module
#  --without-stream_upstream_hash_module
#                                     disable ngx_stream_upstream_hash_module
#  --without-stream_upstream_least_conn_module
#                                     disable ngx_stream_upstream_least_conn_module
#  --without-stream_upstream_zone_module
#                                     disable ngx_stream_upstream_zone_module
#
#  --with-google_perftools_module     enable ngx_google_perftools_module
#  --with-cpp_test_module             enable ngx_cpp_test_module
#
#  --add-module=PATH                  enable external module
#  --add-dynamic-module=PATH          enable dynamic external module
#
#  --with-compat                      dynamic modules compatibility
#
#  --with-cc=PATH                     set C compiler pathname
#  --with-cpp=PATH                    set C preprocessor pathname
#  --with-cc-opt=OPTIONS              set additional C compiler options
#  --with-ld-opt=OPTIONS              set additional linker options
#  --with-cpu-opt=CPU                 build for the specified CPU, valid values:
#                                     pentium, pentiumpro, pentium3, pentium4,
#                                     athlon, opteron, sparc32, sparc64, ppc64
#
#  --without-pcre                     disable PCRE library usage
#  --with-pcre                        force PCRE library usage
#  --with-pcre=DIR                    set path to PCRE library sources
#  --with-pcre-opt=OPTIONS            set additional build options for PCRE
#  --with-pcre-jit                    build PCRE with JIT compilation support
#
#  --with-zlib=DIR                    set path to zlib library sources
#  --with-zlib-opt=OPTIONS            set additional build options for zlib
#  --with-zlib-asm=CPU                use zlib assembler sources optimized
#                                     for the specified CPU, valid values:
#                                     pentium, pentiumpro
#
#  --with-libatomic                   force libatomic_ops library usage
#  --with-libatomic=DIR               set path to libatomic_ops library sources
#
#  --with-openssl=DIR                 set path to OpenSSL library sources
#  --with-openssl-opt=OPTIONS         set additional build options for OpenSSL
#
#  --with-debug                       enable debug logging

