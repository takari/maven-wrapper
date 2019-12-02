#!/bin/sh
# ----------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Apache Maven Wrapper Startup script
#
# This wrapper discoveries the jdk and the project base dir,
# then installs a maven dist and executes the corresponding mvn script.
#
# Environment Variable Prerequisites
#
#   JAVA_HOME       (Optional) Must point at your Java Development Kit installation.
#   MAVEN_BASEDIR   (Optional) Override the project base dir
#   MVNW_REPOURL    (Optional) A mirror url of the Maven Central repo
#   MVNW_USERNAME   (Optional) User name for donwloading the wrapper jar
#   MVNW_PASSWORD   (Optional) Passowrd for donwloading the wrapper jar
#   MVNW_VERBOSE    (Optional) if set to 'true', dump debug info
#   MVNW_OPTS       (Optional) parameters passed to the Java VM when running wrapper
# ----------------------------------------------------------------------------

# OS specific support. $var _must_ be set to either true or false.
cygwin=false
mingw=false
case "`uname`" in
  CYGWIN*) cygwin=true;;
  MINGW*) mingw=true;;
esac

# save JAVA_HOME
_MVNW_SAVE_JAVA_HOME="${JAVA_HOME:-}"

# For Cygwin, ensure paths are in Unix format before anything is touched
if $cygwin ; then
  [ -n "$JAVA_HOME" ] &&
    JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
fi

# For MinGW, ensure paths are in Unix format before anything is touched
if $mingw ; then
  [ -n "$JAVA_HOME" ] &&
    JAVA_HOME=`(cd -- "$JAVA_HOME" && pwd)`
fi

if [ -z "$JAVA_HOME" ] ; then
  JAVACMD=`which java`
else
  JAVACMD="$JAVA_HOME/bin/java"
fi

if [ ! -x "$JAVACMD" ] ; then
  echo "The JAVA_HOME environment variable is not defined correctly" >&2
  echo "This environment variable is needed to run this program" >&2
  echo "NB: JAVA_HOME should point to a JDK not a JRE" >&2
  exit 1
fi

# For Cygwin, switch paths to Windows format before running java
if $cygwin ; then
  [ -n "$JAVA_HOME" ] &&
    JAVA_HOME=`cygpath --path --windows "$JAVA_HOME"`
fi

# traverses directory structure from process work directory to filesystem root
# first directory with .mvn subdirectory is considered project base directory
find_maven_basedir() {
(
  basedir=`find_file_argument_basedir "$@"`
  wdir="${basedir}"
  while [ "$wdir" != '/' ] ; do
    if [ -d "$wdir"/.mvn ] ; then
      basedir=$wdir
      break
    fi
    wdir=`cd -- "$wdir/.."; pwd`
  done
  echo "${basedir}"
)
}

find_file_argument_basedir() {
(
  basedir=`pwd`

  found_file_switch=0
  for arg in "$@"; do
    if [ ${found_file_switch} -eq 1 ]; then
      if [ -d "${arg}" ]; then
        basedir=`cd -- "${arg}" && pwd -P`
      elif [ -f "${arg}" ]; then
        basedir=`dirname "${arg}"`
        basedir=`cd -- "${basedir}" && pwd -P`
        if [ ! -d "${basedir}" ]; then
          echo "Directory ${basedir} extracted from the -f/--file command-line argument ${arg} does not exist" >&2
          exit 1
        fi
      else
        echo "POM file ${arg} specified with the -f/--file command line argument does not exist" >&2
        exit 1
      fi
      break
    fi
    if [ "$arg" = "-f" -o "$arg" = "--file" ]; then
      found_file_switch=1
    fi
  done
  echo "${basedir}"
)
}

_MVNW_PROJECTBASEDIR="${MAVEN_BASEDIR:-`find_maven_basedir "$@"`}"

# For Cygwin, ensure paths are in Unix format before anything is touched
if $cygwin ; then
  [ -n "$_MVNW_PROJECTBASEDIR" ] &&
    _MVNW_PROJECTBASEDIR=`cygpath --unix "$_MVNW_PROJECTBASEDIR"`
fi

# For MinGW, ensure paths are in Unix format before anything is touched
if $mingw ; then
  [ -n "$_MVNW_PROJECTBASEDIR" ] &&
    _MVNW_PROJECTBASEDIR=`(cd -- "$_MVNW_PROJECTBASEDIR" && pwd)`
fi

_MVNW_wrapperDir="$_MVNW_PROJECTBASEDIR/.mvn/wrapper"
_MVNW_wrapperProperties="$_MVNW_wrapperDir/maven-wrapper.properties"
_MVNW_wrapperJarPath="$_MVNW_wrapperDir/maven-wrapper.jar"
_MVNW_wrapperDownloaderSrc="$_MVNW_wrapperDir/MavenWrapperDownloader.java"
_MVNW_wrapperDownloaderClass="$_MVNW_wrapperDir/MavenWrapperDownloader.class"

if [ -z "$_MVNW_PROJECTBASEDIR" -o ! -d "$_MVNW_PROJECTBASEDIR" ]; then
  echo "Project base directory is not correctly discoveried." >&2
  exit 1
fi
if [ ! -r "$_MVNW_wrapperProperties" ]; then
  echo "maven-wrapper is not correctly installed into $_MVNW_PROJECTBASEDIR" >&2
  exit 1
fi

if [ "$MVNW_VERBOSE" = true ]; then
  echo "Project base directory is $_MVNW_PROJECTBASEDIR"
fi

##########################################################################################
# Extension to allow automatically downloading the maven-wrapper.jar from Maven-central
# This allows using the maven wrapper in projects that prohibit checking in binary data.
##########################################################################################
if [ -r "$_MVNW_wrapperJarPath" ]; then
  if [ "$MVNW_VERBOSE" = true ]; then
    echo "Found .mvn/wrapper/maven-wrapper.jar"
  fi
else
  jarUrl="${MVNW_REPOURL:-https://repo.maven.apache.org/maven2}/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar"
  if [ -r "$_MVNW_wrapperProperties" ]; then
    while IFS="=" read key value; do
      case "$key" in (wrapperUrl) jarUrl="$value"; break ;;
      esac
    done < "$_MVNW_wrapperProperties"
  fi
  if [ "$MVNW_VERBOSE" = true ]; then
    echo "Couldn't find .mvn/wrapper/maven-wrapper.jar, downloading it from: $jarUrl"
  fi

  if command -v wget > /dev/null; then
    if [ "$MVNW_VERBOSE" = true ]; then
      echo "Found wget ... using wget"
    fi
    if [ -z "$MVNW_USERNAME" ] || [ -z "$MVNW_PASSWORD" ]; then
      wget "$jarUrl" -O "$_MVNW_wrapperJarPath"
    else
      wget --http-user=$MVNW_USERNAME --http-password=$MVNW_PASSWORD "$jarUrl" -O "$_MVNW_wrapperJarPath"
    fi
  elif command -v curl > /dev/null; then
    if [ "$MVNW_VERBOSE" = true ]; then
      echo "Found curl ... using curl"
    fi
    if [ -z "$MVNW_USERNAME" ] || [ -z "$MVNW_PASSWORD" ]; then
      curl -o "$_MVNW_wrapperJarPath" "$jarUrl" -f
    else
      curl --user $MVNW_USERNAME:$MVNW_PASSWORD -o "$_MVNW_wrapperJarPath" "$jarUrl" -f
    fi
  elif [ -r "$_MVNW_wrapperDownloaderSrc" ]; then
    if [ "$MVNW_VERBOSE" = true ]; then
      echo "Falling back to using Java to download"
    fi

    if [ ! -e "$_MVNW_wrapperDownloaderClass" ]; then
      if [ "$MVNW_VERBOSE" = true ]; then
        echo " - Compiling MavenWrapperDownloader.java ..."
      fi
      # For Cygwin, switch paths to Windows format before running javac
      if $cygwin; then
        _MVNW_wrapperDir=`cygpath --path --windows "$_MVNW_wrapperDir"`
        _MVNW_wrapperDownloaderSrc=`cygpath --path --windows "$_MVNW_wrapperDownloaderSrc"`
      fi
      # Compiling the Java class
      "${JAVACMD}c" -classpath "$_MVNW_wrapperDir" "$_MVNW_wrapperDownloaderSrc"
    fi
    if [ -e "$_MVNW_wrapperDownloaderClass" ]; then
      # Running the downloader
      if [ "$MVNW_VERBOSE" = true ]; then
        echo " - Running MavenWrapperDownloader ..."
      fi
      if $cygwin; then
        _MVNW_wrapperDir=`cygpath --path --windows "$_MVNW_wrapperDir"`
        _MVNW_wrapperJarPath=`cygpath --path --windows "$_MVNW_wrapperJarPath"`
      fi
      "$JAVACMD" -classpath "$_MVNW_wrapperDir" MavenWrapperDownloader "$jarUrl" "$_MVNW_wrapperJarPath"
    fi
  fi
fi
##########################################################################################
# End of extension
##########################################################################################

# For Cygwin, switch paths to Windows format before running java
if $cygwin; then
  _MVNW_wrapperJarPath=`cygpath --path --windows "$_MVNW_wrapperJarPath"`
fi
_MVNW_MAVEN_HOME="$(
  [ -n "$MVNW_OPTS" ] && export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS $MVNW_OPTS"
  "$JAVACMD" -classpath "$_MVNW_wrapperJarPath" org.apache.maven.wrapper.MavenWrapperMain
)"

# For Cygwin, ensure paths are in Unix format before anything is touched
if $cygwin ; then
  [ -n "$_MVNW_MAVEN_HOME" ] &&
    _MVNW_MAVEN_HOME=`cygpath --unix "$_MVNW_MAVEN_HOME"`
fi

# For MinGW, ensure paths are in Unix format before anything is touched
if $mingw ; then
  [ -n "$_MVNW_MAVEN_HOME" ] &&
    _MVNW_MAVEN_HOME=`(cd -- "$_MVNW_MAVEN_HOME" && pwd)`
fi

if [ -z "$_MVNW_MAVEN_HOME" -o ! -x "$_MVNW_MAVEN_HOME/bin/mvn" ]; then
  echo "Error: maven home ($_MVNW_MAVEN_HOME) is not ready." >&2
  exit 1
fi

JAVA_HOME="$_MVNW_SAVE_JAVA_HOME"

unset _MVNW_SAVE_JAVA_HOME
unset _MVNW_PROJECTBASEDIR
unset _MVNW_wrapperDir _MVNW_wrapperProperties _MVNW_wrapperJarPath _MVNW_wrapperDownloaderSrc _MVNW_wrapperDownloaderClass

exec -- "$_MVNW_MAVEN_HOME"/bin/mvn "$@"
