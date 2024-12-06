package sams.karate.helper;

import org.apache.cxf.transport.servlet.CXFServlet;
import org.eclipse.jetty.server.HttpConnectionFactory;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.util.thread.QueuedThreadPool;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.FileSystemResource;
import org.springframework.web.context.ContextLoaderListener;
import org.springframework.web.context.WebApplicationContext;

import java.io.IOException;

import io.strati.spring.StratiWebApplicationContext;

public class JettyHelper {
    private static final Logger logger = LoggerFactory.getLogger(JettyHelper.class);
    private static Server server;
    private static WebApplicationContext webApplicationContext;
    public static void startServer() throws Exception {

        startJetty(8080);
    }

    private static void startJetty(int port) throws Exception {
        logger.info("Starting server at port {}", port);
        server = new Server(new QueuedThreadPool(10, 5));
        ServerConnector connector = new ServerConnector(server, new HttpConnectionFactory());
        connector.setPort(port);
        server.addConnector(connector);
        server.setStopAtShutdown(true);
        webApplicationContext= getContext();
        server.setHandler(getServletContextHandler(webApplicationContext));
        server.start();
    }

    public static void stopServer() throws Exception {
        if(server.isRunning()) {
            server.stop();
        }
    }


    private static ServletContextHandler getServletContextHandler(WebApplicationContext context) throws IOException {
        ServletContextHandler contextHandler = new ServletContextHandler();
        contextHandler.setErrorHandler(null);
        contextHandler.setContextPath("/ucid-seg");
        contextHandler.addServlet(new ServletHolder( new CXFServlet()), "/*");
        contextHandler.addEventListener(new ContextLoaderListener(context));
        contextHandler.setResourceBase(new FileSystemResource("src/main/webapp").getURI().toString());
        return contextHandler;
    }

    private static WebApplicationContext getContext() {
        StratiWebApplicationContext stratiWebApplicationContext = new StratiWebApplicationContext();
        stratiWebApplicationContext.setConfigLocation("/WEB-INF/spring/cxfServlet/servlet-context.xml");
        return stratiWebApplicationContext;
    }
}
