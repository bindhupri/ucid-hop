package sams.karate.helper;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.BindMode;
import org.testcontainers.containers.CassandraContainer;
import org.testcontainers.containers.MockServerContainer;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

import java.io.FileOutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

import static org.testng.Assert.assertEquals;
@Testcontainers
@Tag("KarateTests")
public class TestRunnerKarate {
    private static final String EXTERNAL_CONFIGS_DIR = System.getProperty("ccm.configs.dir");
    private static final String RR_CONFIG_FILE = "richrelevance-config";
    private static final String IRO_MAPPER_CONFIG_FILE = "iro-mapper-config";
    private static final String IRO_CLIENT_CONFIG_FILE = "iro-client-config";
    private static final String ADS_CONFIG_FILE = "glass-wpa-config";

    private static final String EXTERNAL_CONFIGS_SOURCE_DIR = System.getProperty("external.configs.source.dir");

    private static final String RR_SERVICE_PATH = "/rr";
    private static final String IRO_MAPPER_PATH = "/iro-mapper";
    private static final String IRO_CLIENT_PATH = "/iro-client";
    private static final String ADS_SERVICE_PATH = "/ads";

    private static final String RR_SERVICE_URI_PROPERTY = "rr.ca.service.uri";
    private static final String RR_SERVICE_POST_URI_PROPERTY = "rr.ca.service.post.uri";
    private static final String IRO_MAPPER_URL_PROPERTY = "url";
    private static final String IRO_SERVICE_URI_PROPERTY = "iro.service.uri";
    private static final String ADS_SERVICE_URI_PROPERTY = "ads.glass.uri.host.name";

    private static final String STATIC_UF_GENERAL_CONFIG_FILE = "staticUfcache";
    private static final String CACHE_READ_ENABLED_PROPERTY = "l1.readEnabled";
    private static final String CACHE_READ_THROUGH_ENABLED_PROPERTY = "l1.readThroughEnabled";
    private static final String DB_READ_ENABLED_PROPERTY = "l2.readEnabled";

    private static final String STATIC_UF_DB_CONFIG_FILE = "staticUf-db";
    private static final String DB_DC_PROPERTY = "staticUf-db.wcnp-az-scus.cassandra.dc";
    private static final String DB_CLUSTER_URL_PROPERTY = "staticUf-db.wcnp-az-scus.cassandra.cluster.url";
    private static final String DB_PORT_PROPERTY = "staticUf-db.cassandra.cluster.port";

    @Container
    static MockServerContainer mockServerContainer = new MockServerContainer(
            DockerImageName.parse("jamesdbloom/mockserver:mockserver-5.13.2"))
            // .asCompatibleSubstituteFor("jamesdbloom/mockserver"))
            .withClasspathResourceMapping("expectations/", "./expectations/", BindMode.READ_ONLY)
            .withEnv("MOCKSERVER_INITIALIZATION_JSON_PATH", "/expectations/*.json")
            .withEnv("MOCKSERVER_LIVENESS_HTTP_GET_PATH", "/health")
            .waitingFor(Wait.forHttp("/health").forStatusCode(200));

    @Container
    static CassandraContainer cassandraContainer = new CassandraContainer("cassandra:4.0.12")
        .withInitScript("expectations/initial.cql");

    @BeforeAll
    public static void setup() throws Exception {
        mockServerContainer.start();
        cassandraContainer.start();
        updateConfigs();
        JettyHelper.startServer();
    }

    private static void updateConfigs() throws Exception {
        String endPoint = mockServerContainer.getEndpoint();
        updateConfig(RR_CONFIG_FILE, RR_SERVICE_URI_PROPERTY, endPoint + RR_SERVICE_PATH);
        updateConfig(RR_CONFIG_FILE, RR_SERVICE_POST_URI_PROPERTY, endPoint + RR_SERVICE_PATH);
        updateConfig(IRO_MAPPER_CONFIG_FILE, IRO_MAPPER_URL_PROPERTY, endPoint + IRO_MAPPER_PATH);
        updateConfig(IRO_CLIENT_CONFIG_FILE, IRO_SERVICE_URI_PROPERTY, endPoint + IRO_CLIENT_PATH);
        updateConfig(ADS_CONFIG_FILE, ADS_SERVICE_URI_PROPERTY, endPoint + ADS_SERVICE_PATH);

        updateConfig(STATIC_UF_GENERAL_CONFIG_FILE, CACHE_READ_ENABLED_PROPERTY, "false");
        updateConfig(STATIC_UF_GENERAL_CONFIG_FILE, CACHE_READ_THROUGH_ENABLED_PROPERTY, "true");
        updateConfig(STATIC_UF_GENERAL_CONFIG_FILE, DB_READ_ENABLED_PROPERTY, "true");

        updateConfig(STATIC_UF_DB_CONFIG_FILE, DB_DC_PROPERTY, cassandraContainer.getLocalDatacenter());
        updateConfig(STATIC_UF_DB_CONFIG_FILE, DB_CLUSTER_URL_PROPERTY, cassandraContainer.getHost());
        updateConfig(STATIC_UF_DB_CONFIG_FILE, DB_PORT_PROPERTY, cassandraContainer.getMappedPort(9042).toString());
    }

    private static void updateConfig(String fileName, String curProperty, String newProperty) throws Exception {
        updateExternalConfig(fileName, curProperty, newProperty);
        updateStaticConfig(fileName, curProperty, newProperty);
    }

    private static void updateExternalConfig(String fileName, String curProperty, String newProperty) throws Exception {
        ObjectMapper objectMapper = new ObjectMapper();
        Path path = Paths.get(EXTERNAL_CONFIGS_DIR + "/" + fileName + ".json");
        ObjectNode jsonNode = (ObjectNode) objectMapper.readTree(Files.newInputStream(path));
        ((ObjectNode)jsonNode.findValue("resolved")).put(curProperty, newProperty);
        objectMapper.writeValue(Files.newOutputStream(path), jsonNode);
    }

    private static void updateStaticConfig(String fileName, String curProperty, String newProperty) throws Exception {
        Properties properties = new Properties();
        Path path = Paths.get(EXTERNAL_CONFIGS_SOURCE_DIR + "/" + fileName + ".properties");
        properties.load(Files.newInputStream(path));
        properties.setProperty(curProperty, newProperty);
        properties.store(new FileOutputStream(path.toString()), null);
    }

    @AfterAll
    public static void destroy() throws Exception {
        if (mockServerContainer.isRunning()) {
            mockServerContainer.stop();
        }

        if (cassandraContainer.isRunning()) {
            cassandraContainer.stop();
        }

        JettyHelper.stopServer();
    }

    @Test
    public void testAllFeatures() throws Exception {
        //((ObjectNode)objectMapper.readTree(Files.newInputStream(Paths.get(externalConfigDir+"/richrelevance-config.json"))).findParent("rr.ca.service.uri")).replace("rr.ca.service.uri", objectMapper.readTree("\""+"dsf"+"\""))
        Results results =
                Runner.path("src/test/java/sams")
                        .outputCucumberJson(true)
                        .tags("~@ignore")
                        .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
