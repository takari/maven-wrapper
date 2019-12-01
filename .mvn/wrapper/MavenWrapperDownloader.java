/*
 * Copyright 2007-present the original author or authors.
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
import java.net.*;
import java.io.*;
import java.nio.channels.*;

public class MavenWrapperDownloader extends Authenticator {
  public static void main(final String args[]) {
    try {
      final URL url = new URL(args[0]);
      final File outputFile = new File(args[1]).getCanonicalFile();
      if (!outputFile.getParentFile().exists()) {
        System.err.println("- Error: Output directory for '" + outputFile.getCanonicalPath() + "' does not exist.");
        System.exit(1);
      }

      System.out.println("- Downloading from: " + url.toString());
      System.out.println("- Downloading to: " + outputFile.getCanonicalPath());

      if (System.getenv("MVNW_USERNAME") != null && System.getenv("MVNW_PASSWORD") != null) {
        Authenticator.setDefault(new MavenWrapperDownloader());
      }

      final ReadableByteChannel rbc = Channels.newChannel(url.openStream());
      final FileOutputStream fos = new FileOutputStream(outputFile);
      fos.getChannel().transferFrom(rbc, 0, Long.MAX_VALUE);
      fos.close();
      rbc.close();

      System.out.println("Done");
      System.exit(0);
    } catch (final Throwable e) {
      System.err.println("- Error downloading");
      e.printStackTrace();
      System.exit(1);
    }
  }
  @Override
  protected PasswordAuthentication getPasswordAuthentication() {
    return new PasswordAuthentication(System.getenv("MVNW_USERNAME"), System.getenv("MVNW_PASSWORD").toCharArray());
  }
}
