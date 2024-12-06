@ignore
@sams-p13n-HomePage
@parallel=false
Feature: Testing NewCategoryList module on HomePage

  Background:
    * configure headers = read('../../../resources/features/headers/feature_headers.json')
    * def apiUrl = 'p13n/unified/Homepage/content'
    * def body = read('../../../resources/features/request/HomePage/newCategoryList_request_1.json')

  @positive
  Scenario: 200 should be returned when the structure of the response follows the contract
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response contains { errorDetails: '#array', features: null, reqId: '#string', pageOffset: '#number', inflateContent: '#boolean', modules: '#array', styles: '#array'}
    And match response.modules[0] contains { zone: '#string', moduleType: '#string', moduleId: '#string', configs: '#object' }
    And match response.modules[*].configs contains { __typename: '#string', categories: '#array', seeAllCategoriesLink: '#object', title: '#string', displayMode: '#string', categoryNameFontColor: '#string', categoryImagePlaceholderColor: '#string', enablePersonalization: '#string', p13nStrategy: '#string' }
    And match response.modules[*].configs.categories[*] contains { __typename: '#string', image: '#object', name: '#string' }
    And match response.modules[*].configs.categories[*].image contains { __typename: '#string', src: '#string', assetId: '#string', assetName: '#string', clickThrough: '#object' }
    And match response.modules[*].configs.categories[*].image.clickThrough contains { __typename: '#string', value: '#string' }
    And match response.modules[*].moduleResponse[*] contains { categories: '#array' }
    And match response.modules[*].moduleResponse[*].categories[*] contains { name: '#string', image: '#object' }
    And match response.modules[*].moduleResponse[*].categories[*].image contains { alt: '#string', assetId: '#string', assetName: '#string', clickThrough: '#object', height: '#string', src: '#string', title: '#string', width: '#string', size: '#string', contentType: '#string', uid: '#string' }

  @positive
  Scenario: Expected response should be returned with provided request that has 1 module
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response.modules == '#[1]'
    And match response == read('../../../resources/features/response/HomePage/newCategoryList_response_1.json')

  @positive
  Scenario: Expected response should be returned with provided request that has 2 modules
    * def body = read('../../../resources/features/request/newCategoryList_request_2.json')
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response.modules == '#[2]'
    And match response == read('../../../resources/features/response/HomePage/newCategoryList_response_2.json')

  @positive
  Scenario: A non-empty list of categories should be returned when a valid category is provided in the request
    * body.modules[0].configs.p13nStrategy = 'home_page.grid_0'
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response.modules[*].configs.categories != []

  @negative
  Scenario: 200 should be returned when invalid cid is provided in the request
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    Then response.modules = []

  @negative
  Scenario: An empty list of categories should be returned when the wrong category is provided in the request
    * body.modules[0].configs.p13nStrategy = 'home_page.product_0'
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response.modules[*].configs.categories == []

  @negative
  Scenario: 400 should be returned when modules are missing in the request
    * body.modules = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'The list of Athena modules in the request is empty'

  @negative
  Scenario: 400 should be returned when zone is missing in the request
    * body.modules.zone = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400

  @negative
  Scenario: 400 should be returned when moduleType is missing in the request
    * body.modules.moduleType = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400

  @negative
  Scenario: 400 should be returned when moduleId is missing in the request
    * body.modules.moduleId = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400

  @negative
  Scenario: 400 should be returned when configs are missing in the request
    * body.modules.configs = null
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400

  @negative
  Scenario: 400 should be returned when the request cannot be parsed
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