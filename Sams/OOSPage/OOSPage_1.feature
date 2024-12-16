@parallel=false
@sams-p13n
@sams-p13-OOSPage
Feature: Testing Sams OOSPage content POST API Service

  Background:
    * def headers = read('../../../resources/features/headers/feature_headers.json')
    * configure headers = headers
    * def apiUrl = '/p13n/unified/OOSPage/content'
    * def requestBody = read('../../../resources/features/request/OOSPage/ItemCarousel_request.json')

  @positive
  Scenario: Sams CartPage content should be returned for Rich Relevance modules
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response contains any { errorDetails: '#array', features: null, reqId: '#string', pageOffset: '#number', pageId:'#string', modules: '#array', styles: '#array' }
    And match response.modules[0] contains any { zone: '#string' , moduleType: '#string', moduleId: '#string', configs: '#ignore', moduleResponse: '#array', subType: null, athenaOverrides: '#string' }
    And match response.modules[0].configs contains any { p13nStrategy: '#string' }
    And match response.modules[0].moduleResponse[0] contains { products: '#array' }
    And match response.modules[0].moduleResponse[0].products[0].p13nData contains { modelItemId: '#string' }

  @negative
  Scenario: HTTP 400 should be returned when reqId is missing in the request
    * requestBody.reqId = null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'The reqId is invalid'

  @negative
  Scenario: HTTP 400 should be returned when reqId is invalid in the request
    * requestBody.reqId = 'qwer'
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'The reqId is invalid'

  @positive
  Scenario: HTTP 400 should be returned when reqId is invalid in the request
    * requestBody.offerId = null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules[0] == '#notnull'

  @negative
  Scenario: No module response should be returned when modules is missing in the request
    * requestBody.modules[0].moduleId = null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.errorDetails[0].message == 'A request module ID is null'

  @negative
  Scenario: No module response should be returned when zone in modules is missing in the request
    * requestBody.modules[0].zone = null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules[0].zone == null

  @positive
  Scenario: module response should be returned when zone in modules is not missing in the request
    * requestBody.modules[0].zone != null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules[0].zone == 'substitutionsZone'

  @negative
  Scenario: No module response should be returned when p13nStrategy in modules.configs is missing in the request
    * requestBody.modules[0].configs.p13nStrategy = null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules[0].configs.p13nStrategy == 'generic_page.substitutions_rye'

  @negative
  Scenario: No module response should be returned when pageId is missing in the request
    * requestBody.pageId != null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.pageID == '5018481154'

  @negative
  Scenario: No module response should be returned when userReqInfo is missing in the request
    * requestBody.userReqInfo = null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules == []

  @negative
  Scenario: No module response should be returned when userReqInfo is missing in the request
    * requestBody.availabilityStatus = null

    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules == '#notnull'

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
