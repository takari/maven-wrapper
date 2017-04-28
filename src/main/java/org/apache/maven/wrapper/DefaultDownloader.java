/*
 * Copyright 2007-2009 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.maven.wrapper;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Authenticator;
import java.net.PasswordAuthentication;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLConnection;


/**
 * @author Hans Dockter
 */
public class DefaultDownloader implements Downloader {
  private static final int PROGRESS_CHUNK = 20000;

  private static final int BUFFER_SIZE = 10000;

  private final String applicationName;

  private final String applicationVersion;

  public DefaultDownloader(String applicationName, String applicationVersion) {
    this.applicationName = applicationName;
    this.applicationVersion = applicationVersion;
  }

  private URI configureAuthentication(URI address, String[] args) {
    String user = null;
    String password = null;
    MavenSettings.Credentials credentials = MavenSettings.getCredentials(args, address.getUserInfo());
    if (credentials != null) {
      user = credentials.username;
      password = credentials.password;
    }

    if (System.getProperty("http.proxyUser") == null && user == null) {
      return address;
    }

    Authenticator.setDefault(new DefaultAuthenticator(user, password.toCharArray()));
    try {
      return new URI(address.getScheme(), null, address.getHost(), address.getPort(), address.getPath(), address.getQuery(), address.getFragment());
    } catch (URISyntaxException e) {
      return address; // not possible
    }
  }

  @Override
  public void download(URI address, File destination, String[] args) throws Exception {
    if (destination.exists()) {
      return;
    }
    destination.getParentFile().mkdirs();

    downloadInternal(address, destination, args);
  }

  private void downloadInternal(URI address, File destination, String[] args) throws Exception {
    address = configureAuthentication(address, args);

    OutputStream out = null;
    URLConnection conn;
    InputStream in = null;
    try {
      URL url = address.toURL();
      out = new BufferedOutputStream(new FileOutputStream(destination));
      conn = url.openConnection();
      final String userAgentValue = calculateUserAgent();
      conn.setRequestProperty("User-Agent", userAgentValue);
      in = conn.getInputStream();
      byte[] buffer = new byte[BUFFER_SIZE];
      int numRead;
      long progressCounter = 0;
      while ((numRead = in.read(buffer)) != -1) {
        progressCounter += numRead;
        if (progressCounter / PROGRESS_CHUNK > 0) {
          System.out.print(".");
          progressCounter = progressCounter - PROGRESS_CHUNK;
        }
        out.write(buffer, 0, numRead);
      }
    } finally {
      System.out.println("");
      if (in != null) {
        in.close();
      }
      if (out != null) {
        out.close();
      }
      Authenticator.setDefault(null); // yuck, but leaking our authenticator to maven is worse
    }
  }

  private String calculateUserAgent() {
    String appVersion = applicationVersion;

    String javaVendor = System.getProperty("java.vendor");
    String javaVersion = System.getProperty("java.version");
    String javaVendorVersion = System.getProperty("java.vm.version");
    String osName = System.getProperty("os.name");
    String osVersion = System.getProperty("os.version");
    String osArch = System.getProperty("os.arch");
    return String.format("%s/%s (%s;%s;%s) (%s;%s;%s)", applicationName, appVersion, osName, osVersion, osArch, javaVendor, javaVersion, javaVendorVersion);
  }

  private static class DefaultAuthenticator extends Authenticator {
    private final String proxyUser = System.getProperty("http.proxyUser");
    private final char[] proxyPassword = System.getProperty("http.proxyPassword", "").toCharArray();

    private final String user;
    private final char[] password;

    public DefaultAuthenticator(String user, char[] password) {
      this.user = user;
      this.password = password;
    }

    @Override
    protected PasswordAuthentication getPasswordAuthentication() {
      if (getRequestorType() == RequestorType.PROXY && proxyUser != null) {
        return new PasswordAuthentication(proxyUser, proxyPassword);
      }
      if (getRequestorType() == RequestorType.SERVER && user != null) {
        return new PasswordAuthentication(user, password);
      }
      return null;
    }
  }
}
