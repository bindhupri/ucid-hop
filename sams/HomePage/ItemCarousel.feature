@parallel=false
@sams-p13n
@sams-p13n-HomePage
Feature: Testing ItemCarousel on HomePage

  Background:
    * configure headers = read('../../../resources/features/headers/feature_headers.json')
    * def apiUrl = '/p13n/unified/GlassHomePageDesktopV1/content'
    * def body = read('../../../resources/features/request/HomePage/itemCarousel_request_1.json')

  @positive
  Scenario: Check if the response follows the contract
    Given url baseUrl + apiUrl
    And request body
    And retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    And match response contains { errorDetails: '#array', features: null, reqId: '#string', inflateContent: '#boolean', modules: '#array', styles: '#array'}
    And match response.modules[0] contains { zone: '#string', moduleType: '#string', moduleId: '#string', configs: '#ignore', moduleResponse: '#array', subType: null, athenaOverrides: '#string' }
    And match response.modules[0].configs contains { items: '#array', manualShelfId: '#string', defaultStrategy: null, expandedOnPageLoad: '#string', title: '#string', subTitle: null, showGridView: '#string', viewAllLink: '#ignore', minItems: '#string', span: '#string', itemsSelection: '#string', p13nStrategy: '#string', enabledSponsored: '#string', isAtfSectionItemCarousel: '#string', isExternalTrafficOverlayCarousel: '#string' }
    And match response.modules[0].configs.viewAllLink contains { title: '#string', linkText: '#string', clickThrough: '#ignore' }
    And match response.modules[0].configs.viewAllLink.clickThrough contains { type: '#string', value: '#string', rawValue: '#string' }
    And match response.modules[0].moduleResponse contains { products: '#ignore' }
    And match response.modules[0].moduleResponse[0].products[0] contains { id: '#string', usItemId: '#string', offerId: '#string', availabilityStatus: '#string', imageInfo: '#ignore', classType: '#string', canonicalUrl: '#string', name: '#string', brand: '#string', p13nData: '#object', showAtc : '#boolean', showSubscribe: '#boolean', showOptions: '#boolean', productClassType: '#string', fulfillmentSummary: '#array' }
    And match response.modules[0].moduleResponse[0].products[0].p13nData contains { modelItemId: '#string' }
    And match response.modules[0].moduleResponse[0].products[0].fulfillmentSummary[0] contains { fulfillment: '#string', storeId: '#string', availability: '#ignore', fulfillmentMethods: '#array' }

  @positive
  Scenario: Expected ItemCarousel response should be returned when one module is sent in the request
    Given url baseUrl + apiUrl
    And request body
    And retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    And match response.modules == '#[1]'
    And match response == read('../../../resources/features/response/HomePage/itemCarousel_expected_resp_1.json')

  @positive
  Scenario: ItemCarousel content should be returned with inflateContent flag set to true
    * body.inflateContent = true
    Given url baseUrl + apiUrl
    And request body
    Then retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    And match response.inflateContent == true

  @positive
  Scenario: ItemCarousel content should be returned with inflateContent flag set to false
    * body.inflateContent = false
    Given url baseUrl + apiUrl
    And request body
    Then retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    And match response.inflateContent == false

  @positive
  Scenario: The same configurations for product recommendations should be present in the request and the response
    * body.inflateContent = false
    Given url baseUrl + apiUrl
    And request body
    Then retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    Then match body.modules[0].configs == response.modules[0].configs

  @negative
  Scenario: Proper error messaage should be returned when module id is missing in the request
    * body.modules[0].moduleId = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response.errorDetails[0].message == 'A request module ID is null'

  @negative
  Scenario: Proper error message should be returned when module type is missing in the request
    * body.modules[0].moduleType = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 500
    And match response.errorDetails[0].message == 'Internal error processing request'

    # TODO: We are still getting modules -> check w/ Sid if it's the expected behavior
#  @negative
#  Scenario: No module response should be returned when user request info is missing in the request
#    * body.userReqInfo = null
#    Given url baseUrl + apiUrl
#    And request body
#    When method POST
#    * print response
#    Then status 200
#    And match response.modules == '#[0]'

  @nagative
  Scenario: Proper error message should be returned when device type is missing in the request
    * body.userClientInfo.deviceType = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 500
    And match response.errorDetails[0].message == 'Internal error processing request'

  @negative
  Scenario: Proper error message should be returned when no module is present in the request
    * body.modules = []
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'The list of Athena modules in the request is empty'

  @negative
  Scenario: Proper error message should be returned when reqId is missing in the request
    * body.reqId = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'the reqId is invalid'

  @negative
  Scenario: Proper error message should be returned when invalid request that cannot be parsed is sent in the request
    * text body =
      """
      { "reqId": "abc", "userReqInfo: { "cid": "xyz" ]
      """
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'Request was unable to be parsed because of a Parsing Exception'

    # TODO: 500 error code is returned instead of 400, we need to fix this
#  @negative
#  Scenario: 400 error code should be returned when user client info is missing in the request
#    * body.userClientInfo = null
#    Given url baseUrl + apiUrl
#    And request body
#    When method POST
#    * print response
#    Then status 400