/*
 * Copyright (c) 2016 Christian Schulte <cs@schulte.it>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
package org.apache.maven.wrapper;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Authenticator;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.PasswordAuthentication;
import java.net.ProxySelector;
import java.net.SocketAddress;
import java.net.URI;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;
import org.apache.maven.settings.Proxy;
import org.apache.maven.settings.Server;
import org.apache.maven.settings.Settings;
import org.apache.maven.settings.building.DefaultSettingsBuilder;
import org.apache.maven.settings.building.DefaultSettingsBuilderFactory;
import org.apache.maven.settings.building.DefaultSettingsBuildingRequest;
import org.apache.maven.settings.building.SettingsBuildingException;
import org.apache.maven.settings.building.SettingsBuildingResult;
import org.apache.maven.settings.building.SettingsProblem;
import org.apache.maven.settings.crypto.DefaultSettingsDecrypter;
import org.apache.maven.settings.crypto.DefaultSettingsDecryptionRequest;
import org.apache.maven.settings.crypto.SettingsDecryptionResult;
import org.sonatype.plexus.components.cipher.DefaultPlexusCipher;
import org.sonatype.plexus.components.cipher.PlexusCipherException;
import org.sonatype.plexus.components.sec.dispatcher.DefaultSecDispatcher;

/**
 * A {@code Downloader} supporting Maven {@code settings.xml}.
 *
 * @author Christian Schulte <cs@schulte.it>
 */
public class MavenSettingsDownloader
    implements Downloader
{

    private File userSettinsFile;

    private File securitySettingsFile;

    private Settings settings;

    private ProxySelector proxySelector;

    private Authenticator authenticator;

    private static final int BUFFER_SIZE = 524288; //512 * 1024

    private static final String SERVER_ID_SYSTEM_PROPERTY_NAME = "maven-server-id";

    public void download( final URI source, final File target ) throws Exception
    {
        if ( !target.exists() )
        {
            final ProxySelector defaultProxySelector = ProxySelector.getDefault();
            InputStream in = null;
            OutputStream out = null;

            target.getParentFile().mkdirs();

            try
            {
                ProxySelector.setDefault( this.getProxySelector() );
                Authenticator.setDefault( this.getAuthenticator() );

                in = new BufferedInputStream( source.toURL().openStream(), BUFFER_SIZE );
                out = new BufferedOutputStream( new FileOutputStream( target ), BUFFER_SIZE );

                final byte[] buf = new byte[ BUFFER_SIZE ];
                for ( int read = in.read( buf ); read >= 0; out.write( buf, 0, read ), read = in.read( buf ) );

                in.close();
                in = null;

                out.close();
                out = null;
            }
            finally
            {
                ProxySelector.setDefault( defaultProxySelector );
                close( in );
                close( out );
            }
        }
    }

    private static void close( final Closeable closeable )
    {
        try
        {
            if ( closeable != null )
            {
                closeable.close();
            }
        }
        catch ( final IOException e )
        {
            e.printStackTrace( System.err );
        }
    }

    public boolean isActive()
    {
        return this.getUserSettingsFile().isFile();
    }

    private File getUserSettingsFile()
    {
        if ( this.userSettinsFile == null )
        {
            this.userSettinsFile = new File( new File( System.getProperty( "user.home" ), ".m2" ), "settings.xml" );
        }

        return this.userSettinsFile;
    }

    private File getSecuritySettingsFile()
    {
        if ( this.securitySettingsFile == null )
        {
            this.securitySettingsFile = new File( new File( System.getProperty( "user.home" ), ".m2" ),
                                                  "settings-security.xml" );

        }

        return this.securitySettingsFile;
    }

    private Settings getSettings() throws SettingsBuildingException
    {
        if ( this.settings == null )
        {
            final DefaultSettingsBuilder settingsBuilder = new DefaultSettingsBuilderFactory().newInstance();

            final DefaultSettingsBuildingRequest settingsBuildingRequest = new DefaultSettingsBuildingRequest();
            settingsBuildingRequest.setUserSettingsFile( this.getUserSettingsFile() );

            final SettingsBuildingResult settingsBuildingResult = settingsBuilder.build( settingsBuildingRequest );
            this.settings = settingsBuildingResult.getEffectiveSettings();

            if ( this.getSecuritySettingsFile().isFile() )
            {
                final DefaultSettingsDecrypter settingsDecryptor = new DefaultSettingsDecrypter();
                settingsDecryptor.setSecurityDispatcher( new DefaultSecDispatcher()
                {

                    {
                        try
                        {
                            this._cipher = new DefaultPlexusCipher();
                            this._configurationFile = getSecuritySettingsFile().getAbsolutePath();
                        }
                        catch ( final PlexusCipherException e )
                        {
                            throw new AssertionError( e );
                        }
                    }

                } );

                final DefaultSettingsDecryptionRequest settingsDecryptionRequest =
                    new DefaultSettingsDecryptionRequest();

                settingsDecryptionRequest.setProxies( this.settings.getProxies() );
                settingsDecryptionRequest.setServers( this.settings.getServers() );

                final SettingsDecryptionResult settingsDecryptionResult =
                    settingsDecryptor.decrypt( settingsDecryptionRequest );

                for ( final SettingsProblem settingsProblem : settingsDecryptionResult.getProblems() )
                {
                    if ( settingsProblem.getMessage() != null )
                    {
                        System.err.append( settingsProblem.getMessage() + System.lineSeparator() );
                    }

                    if ( settingsProblem.getException() != null )
                    {
                        settingsProblem.getException().printStackTrace( System.err );
                    }
                }

                this.settings.getProxies().clear();
                this.settings.getProxies().addAll( settingsDecryptionResult.getProxies() );

                this.settings.getServers().clear();
                this.settings.getServers().addAll( settingsDecryptionResult.getServers() );
            }
        }

        return this.settings;
    }

    private ProxySelector getProxySelector()
    {
        if ( this.proxySelector == null )
        {
            this.proxySelector = new ProxySelector()
            {

                @Override
                public List<java.net.Proxy> select( final URI uri )
                {
                    final List<java.net.Proxy> proxies = new ArrayList<java.net.Proxy>();

                    try
                    {
                        for ( final Proxy proxy : getSettings().getProxies() )
                        {
                            if ( uri.getScheme().equals( proxy.getProtocol() ) )
                            {
                                proxies.add( toJavaProxy( proxy ) );
                            }
                        }
                    }
                    catch ( final SettingsBuildingException e )
                    {
                        e.printStackTrace( System.err );
                    }
                    catch ( final UnknownHostException e )
                    {
                        e.printStackTrace( System.err );
                    }

                    return proxies;
                }

                @Override
                public void connectFailed( final URI uri, final SocketAddress sa, final IOException ioe )
                {
                    if ( ioe != null )
                    {
                        ioe.printStackTrace( System.err );
                    }
                }

            };
        }

        return this.proxySelector;
    }

    private static java.net.Proxy toJavaProxy( final Proxy proxy ) throws UnknownHostException
    {
        return new java.net.Proxy( java.net.Proxy.Type.valueOf( proxy.getProtocol() ),
                                   new InetSocketAddress( InetAddress.getByName( proxy.getHost() ), proxy.getPort() ) );

    }

    private Authenticator getAuthenticator()
    {
        if ( this.authenticator == null )
        {
            this.authenticator = new Authenticator()
            {

                @Override
                protected PasswordAuthentication getPasswordAuthentication()
                {
                    PasswordAuthentication passwordAuthentication = null;

                    try
                    {
                        switch ( this.getRequestorType() )
                        {
                            case PROXY:
                            {
                                for ( final Proxy proxy : getSettings().getProxies() )
                                {
                                    if ( this.getRequestingProtocol().equals( proxy.getProtocol() )
                                             && this.getRequestingHost().equals( proxy.getHost() )
                                             && this.getRequestingPort() == proxy.getPort() )
                                    {
                                        if ( proxy.getPassword() != null && proxy.getUsername() != null )
                                        {
                                            passwordAuthentication = new PasswordAuthentication(
                                                proxy.getUsername(), proxy.getPassword().toCharArray() );

                                        }
                                        break;
                                    }
                                }
                            }
                            case SERVER:
                            {
                                final String serverId = System.getProperty( SERVER_ID_SYSTEM_PROPERTY_NAME );

                                if ( serverId != null )
                                {
                                    for ( final Server server : getSettings().getServers() )
                                    {
                                        if ( serverId.equals( server.getId() ) )
                                        {
                                            if ( server.getPassword() != null && server.getUsername() != null )
                                            {
                                                passwordAuthentication = new PasswordAuthentication(
                                                    server.getUsername(), server.getPassword().toCharArray() );

                                            }
                                            break;
                                        }
                                    }
                                }
                            }
                            default:
                                throw new AssertionError( this.getRequestorType() );
                        }
                    }
                    catch ( final SettingsBuildingException e )
                    {
                        e.printStackTrace( System.err );
                    }

                    return passwordAuthentication;
                }

            };
        }

        return this.authenticator;
    }

}
