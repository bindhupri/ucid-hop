#@ignore
@sams-p13n
@sams-p13n-ItemPage
@parallel=false
Feature: Testing SoftBundles on ItemPage

  Background:
    * configure headers = read('../../../resources/features/headers/feature_headers.json')
    * def apiUrl = '/p13n/unified/itempage/content'
    * def body = read('../../../resources/features/request/ItemPage/softBundles_request_1.json')
    * configure retry = { count: 10, interval: 1000 }

  @positive
  Scenario: The response should follow the structure of the contract
    Given url baseUrl + apiUrl
    And request body
    And retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    And match response contains { errorDetails: '#array', features: null, reqId: '#string', inflateContent: '#boolean', modules: '#array', styles: '#array'}
    And match response.modules[0] contains { zone: '#string', moduleType: '#string', moduleId: '#string', configs: '#ignore', moduleResponse: '#array', subType: null, athenaOverrides: '#string' }
    And match response.modules[0].configs contains { athModule: '#string' }
    And match response.modules[0].moduleResponse[0] contains { products: '#array' }
    And match response.modules[0].moduleResponse[0].products[*] contains { id: '#string', usItemId: '#string', offerId: '#string', sellerId: '#string', availabilityStatus: '#string', imageInfo: { thumbnailUrl: '#string', assetId: '#string' }, classType: '#string', canonicalUrl: '#string', name: '#string', brand: '#string', p13nData: { modelItemId: '#string' }, showAtc: '#boolean', showSubscribe: '#boolean', showOptions: '#boolean', productClassType: '#string', fulfillmentSummary: '#array' }
    And match response.modules[0].moduleResponse[0].products[0].p13nData contains { modelItemId: '#string' }
    And match response.modules[0].moduleResponse[0].products[0].fulfillmentSummary[0] contains { fulfillment: '#string', storeId: '#string', fulfillmentMethods: '#array' }

  @positive
  Scenario: Expected response should be returned when one module is sent in the request
    Given url baseUrl + apiUrl
    And request body
    And retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    And match response.modules == '#[1]'
    And match response == read('../../../resources/features/response/ItemPage/softBundles_resp_1.json')

#  @positive
#  Scenario: Expected response should be returned when two modules are sent in the request
#    Given url baseUrl + apiUrl
#    And request body
#    And retry until response.modules != '#[0]'
#    When method POST
#    * print response
#    Then status 200
#    And match response.modules == '#[2]'
#    And match response == read('../../resources/features/response/softBundles_response_2.json')

  @positive
  Scenario: SoftBundles content should be returned with inflateContent flag set to true
    * body.inflateContent = true
    Given url baseUrl + apiUrl
    And request body
    Then retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    And match response.inflateContent == true

  @positive
  Scenario: SoftBundles content should be returned with inflateContent flag set to false
    * body.inflateContent = false
    Given url baseUrl + apiUrl
    And request body
    Then retry until response.modules != '#[0]'
    When method POST
    * print response
    Then status 200
    And match response.inflateContent == false

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
  Scenario: No module response should be returned when user request info is missing in the request
    * body.userReqInfo = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response.modules == '#[0]'

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
#  Scenario: 400 should be returned when userClientInfo field is not present in the request
#    * body.userClientInfo = null
#    Given url baseUrl + apiUrl
#    And request body
#    When method POST
#    * print response
#    Then status 400