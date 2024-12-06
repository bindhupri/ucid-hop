@parallel=false
@sams-p13n
@sams-p13-ItemPage
Feature: Testing Sams ItemPage content POST API Service

  Background:
    * def headers = read('../../../resources/features/headers/feature_headers.json')
    * configure headers = headers
    * def apiUrl = '/p13n/unified/itempage/content'
    * def requestBody = read('../../../resources/features/request/ItemPage/itemCarousel_request_1.json')

    @positive
    Scenario: Sams ItemPage content should be returned for Rich Relevance modules
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules[0].moduleResponse != null
    And match response contains { errorDetails: '#array', features: null, reqId: '#string', inflateContent: '#boolean', modules: '#array', styles: '#array'}
    And match response.modules[0] contains { zone: '#string', moduleType: '#string', moduleId: '#string', configs: '#ignore', moduleResponse: '#array', subType: null, athenaOverrides: '#string' }
    And match response.modules[0].moduleResponse contains { products: '#ignore' }
    And match response.modules[0].moduleResponse[0].products[0] contains { id: '#string', usItemId: '#string', offerId: '#string', availabilityStatus: '#string', imageInfo: '#ignore' }
    And match response.modules[0].moduleResponse[0].products[0].category contains { categoryPathId: '#string', categoryPath: '#string' }
    And match response.modules[0].moduleResponse[0].products[0].p13nData contains { modelItemId: '#string' }
    And match response.modules[0].moduleResponse[0].products[0].fulfillmentSummary[0] contains { fulfillment: '#string', storeId: '#string', fulfillmentMethods: '#array' }

    @negative
    Scenario: HTTP 400 should be returned when reqId is missing in the request
    * requestBody.reqId = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'the reqId is invalid'

    @negative
    Scenario: HTTP 400 should be returned when reqId is invalid in the request
    * requestBody.reqId = 'qwer'

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'the reqId is invalid'

    @negative
    Scenario: No module response should be returned when pageId is missing in the request
    * requestBody.pageId = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules == []

    @negative
    Scenario: No module response should be returned when userReqInfo is missing in the request
    * requestBody.userReqInfo = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules == []

#    @positive
#    Scenario: Sams ItemPage content should be returned for Rich Relevance modules even if storeIds in userReqInfo is missing
#    * requestBody.userReqInfo.storeIds = null
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 200
#    And match response.modules[0].moduleResponse != null

    @positive
    Scenario: Sams ItemPage content should be returned for Rich Relevance modules even if vtc in userReqInfo is missing
    * requestBody.userReqInfo.vtc = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules[0].moduleResponse != null

#    @positive
#    Scenario: Sams ItemPage content should be returned for Rich Relevance modules even if cid in userReqInfo is missing
#    * requestBody.userReqInfo.cid = null
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 200
#    And match response.modules[0].moduleResponse != null

    @negative
    Scenario: No module response should be returned when modules is missing in the request
    * requestBody.modules = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'The list of Athena modules in the request is empty'

    @negative
    Scenario: No module response should be returned when zone in modules is missing in the request
    * requestBody.modules[0].zone = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules[0].zone == null

  # TODO: 500 error code is returned instead of 400, we need to fix this
#    @negative
#    Scenario: No module response should be returned when moduleType in modules is missing in the request
#    * requestBody.modules[0].moduleType = null
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 400

    @negative
    Scenario: No module response should be returned when moduleId in modules is missing in the request
    * requestBody.modules[0].moduleId = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.errorDetails[0].message == 'A request module ID is null'

    @negative
    Scenario: No module response should be returned when p13nStrategy in modules.configs is missing in the request
    * requestBody.modules[0].configs.p13nStrategy = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules == []

  # TODO: 500 error code is returned instead of 400, we need to fix this
#    @negative
#    Scenario: No module response should be returned when userClientInfo is missing in the request
#    * requestBody.userClientInfo = null
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 400

  # TODO: 500 error code is returned instead of 400, we need to fix this
#    @negative
#    Scenario: No module response should be returned when deviceType in userClientInfo is missing in the request
#    * requestBody.userClientInfo.deviceType = null
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 400

  # TODO: 500 error code is returned instead of 200, we need to fix this
#    @negative
#    Scenario: Error message should be returned when tenantId is invalid
#    * def updatedHeaders = karate.merge(headers, {'tenant-id': 'qwer'})
#    * configure headers = updatedHeaders
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 200
#    And match response.errorDetails[0].message == 'No AthenaResponseModules for module type RichRelevanceModules'

    # TODO: 500 error code is returned instead of 400, we need to fix this
#    @negative
#    Scenario: No module response should be returned when isZipLocated in userClientInfo is missing in the request
#    * requestBody.userClientInfo.isZipLocated = null
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 400

    # TODO: 500 error code is returned instead of 400, we need to fix this
#    @negative
#    Scenario: No module response should be returned when zipCode in userClientInfo is missing in the request
#    * requestBody.userClientInfo.zipCode = null
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 400

    # TODO: 500 error code is returned instead of 400, we need to fix this
#    @negative
#    Scenario: No module response should be returned when callType in userClientInfo is missing in the request
#    * requestBody.userClientInfo.stateOrProvinceCode = null
#
#    Given url baseUrl + apiUrl
#    And request requestBody
#    When method POST
#    * print response
#    Then status 400

    @negative
    Scenario: Proper error message should be returned when invalid request that cannot be parsed is sent in the request
    * text requesBody =
    """
    { "reqId": "abc", "userReqInfo: { "cid": "xyz" ]
    """
    Given url baseUrl + apiUrl
    And request requesBody
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'Request was unable to be parsed because of a Parsing Exception'