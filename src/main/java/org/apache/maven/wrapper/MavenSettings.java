/*
 * Copyright 2015 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */

package org.apache.maven.wrapper;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.xml.sax.InputSource;

class MavenSettings {
  private static final XPathFactory xpathFactory = XPathFactory.newInstance();

  public static class Credentials {
    public final String username;
    public final String password;

    Credentials(String username, String password) {
      this.username = username;
      this.password = password;
    }
  }

  public static File getUserSettings(String[] args) {
    for (int i = 0; i < args.length - 1; i++) {
      String arg = args[i];
      if ("-s".equals(arg) || "--settings".equals(arg)) {
        return new File(args[i+1]);
      }
    }
    String userHome = System.getProperty("user.home");
    return new File(userHome, ".m2/settings.xml");
  }

  public static Credentials getCredentials(String[] args, String serverId) {
    if (serverId == null) {
      return null;
    }

    File userSettings = getUserSettings(args);
    try (InputStream is = new BufferedInputStream(new FileInputStream(userSettings))) {
      InputSource xml = new InputSource(is);
      XPath xpath = xpathFactory.newXPath();

      Object servers = xpath.compile("/settings/servers").evaluate(xml, XPathConstants.NODE);
      if (servers != null) {
        String username = xpath.compile("server[id='" + serverId + "']/username").evaluate(servers);
        String password = xpath.compile("server[id='" + serverId + "']/password").evaluate(servers);
        if (username != null && !username.isEmpty()) {
          return new Credentials(username, password);
        }
      }
    } catch (IOException | XPathExpressionException e) {
      // ignore, nothing to be done about it
    }

    return null;
  }

}
