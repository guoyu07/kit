#!/bin/bash
#------------------------------------------------
# target: install java programming environment
# author: junjiemars@gmail.com
# source: https://github.com/junjiemars/kits
#------------------------------------------------

PLATFORM="`uname -s 2>/dev/null`"
MACHINE="`uname -m 2>/dev/null`"

inside_kit_bash_env_p() {
  echo $KIT_GITHUB | grep 'junjiemars/kit' &>/dev/null
}

on_windows_nt() {
  case "$PLATFORM" in
    MSYS_NT*|MINGW*) 
      return 0 
    ;;
  *) 
    return 1 
  ;;
  esac
}

on_darwin() {
  case "$PLATFORM" in
    Darwin) 
      return 0
    ;;
    *)
      return 1
    ;;
  esac
}

if `on_windows_nt`; then
 if [ -d "/d/" ]; then
   PREFIX="${PREFIX:-/d/opt}"
 else
   PREFIX="${PREFIX:-/c/opt}"
 fi
else
 PREFIX="${PREFIX:-/opt}"
fi


RUN_DIR="${OPT_RUN:-${PREFIX}/run}"
OPEN_DIR="${OPT_OPEN:-${PREFIX}/open}"
TMP_DIR="${TMP:-${PREFIX}/tmp}"

SED_OPT_I="-i''"
if `on_darwin`; then
  SED_OPT_I="-i ''"
fi

CURL_OPTS="${CURL_OPTS:--f --connect-timeout 60}"


append_kit_path() {
  local f_paths="$HOME/.bash_paths"
  local name="PATH"
  local val="\${PATH:+\$PATH:}$1"
  local flag="$2"
  local var="${name}=\"${val}\""
  if `grep "^${name}=\".*${flag}.*\"" "${f_paths}" &>/dev/null`; then
    sed $ "s#^${name}=\".*${flag}\"#${var}#g" "${f_paths}"
  else
    echo -e "${var}" >> "${f_paths}"
  fi
  . "${f_paths}"
}

append_kit_var() {
 local f_vars="$HOME/.bash_vars"
 local name="$1"
 local val="$2"
 local var="export ${name}='${val}'"
 if `grep "^export ${name}='.*'" "${f_vars}" &>/dev/null`; then
   sed $ "s#^export ${name}='.*'#${var}#g" "${f_vars}"
 else
   echo -e "${var}" >> "${f_vars}"
 fi
 . "${f_vars}"
}

download_kit() {
  local url="$1"
  local fn="$2"
  local t=0

  curl $CURL_OPTS -L -o "${fn}" -C - "${url}"
  t=$?
  if [ 33 -eq $t ]; then
    curl $CURL_OPTS -L -o "${fn}" "${url}"
  elif [ 60 -eq $t ]; then
    [ -f "${fn}" ] && rm "${fn}"
    curl $CURL_OPTS -k -L -o "${fn}" "${url}"
  else
    return $t
  fi
}

extract_kit() {
  local src="$1"
  local dst="$2"
  local x="${src##*.}"
  local t=0

  [ -d "${dst}" ] && rm -r "${dst}"
  mkdir -p "${dst}"
  
  case "$x" in
    gz|tgz)
      tar xf "${src}" -C "${dst}" --strip-components=1
      ;;
    zip)
      cd `dirname ${src}` && unzip -q -o "${src}" -d"${dst}"
      t=$?
      [ 0 -eq $t ] || return 1
      local d="`ls -d ${dst}/*`"
      [ -d "$d" ] || return 1
      cd "${d}" && cp -r * "${dst}" && rm -r "$d"
      ;;
    jar)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

install_kit() {
  local bin="$1"
  local cmd="$2"
  local url="$3"
  local src="$4"
  local dst="$5"

  if `test -f "${bin}"`; then
		$cmd &>/dev/null
		[ 0 -eq $? ] && return 0
	fi

  if `test -f "${src}"` && `extract_kit "${src}" "${dst}"`; then
    $cmd &>/dev/null
		[ 0 -eq $? ] && return 0
	fi

  if `download_kit "$url" "$src"`; then
    extract_kit "${src}" "${dst}"
  else
    return 1
  fi
}

check_kit() {
  local cmd="$1"
  local home="$2"

  if `${cmd} &>/dev/null`; then
    return 0
  else
    [ -d "${home}" ] || mkdir -p "${home}"
    return 1
  fi
}

export INCLUDE_KIT_ENV="yes"