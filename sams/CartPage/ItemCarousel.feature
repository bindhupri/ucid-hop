@parallel=false
@sams-p13n
@sams-p13-ItemPage
Feature: Testing Sams CartPage content POST API Service

  Background:
    * def headers = read('../../../resources/features/headers/feature_headers.json')
    * configure headers = headers
    * def apiUrl = '/p13n/unified/PostCartLoadPage/content'
    * def requestBody = read('../../../resources/features/request/CartPage/ItemCarousel_request.json')

  @positive
  Scenario: Sams CartPage content should be returned for Rich Relevance modules
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response contains { errorDetails: '#array', features: null, reqId: '#string', inflateContent: '#boolean', modules: '#array', styles: '#array' }
    And match response.modules[0] contains { zone: '#string', moduleType: '#string', moduleId: '#string', configs: '#ignore', moduleResponse: '#array', subType: null, athenaOverrides: '#string' }
    And match response.modules[0].moduleResponse contains { products: '#ignore' }
    And match response.modules[0].moduleResponse[0].products[0] contains { id: '#string', usItemId: '#string', offerId: '#string', availabilityStatus: '#string', imageInfo: '#ignore', badges: '#array', classType: '#string', canonicalUrl: '#string', name: '#string', showAtc: '#boolean', showSubscribe: '#boolean' }
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

  @positive
  Scenario: Sams Cartpage content should be returned for Rich Relevance modules even if vtc in userReqInfo is missing
    * requestBody.userReqInfo.vtc = null
    Given url baseUrl + apiUrl
    And request requestBody
    When method POST
    * print response
    Then status 200
    And match response.modules[0].moduleResponse != null

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
