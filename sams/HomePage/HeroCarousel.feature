@ignore
@parallel=false
@sams-p13n
@sams-p13n-HomePage
Feature: Testing HeroCarousel module on HomePage

  Background:
    * configure headers = read('../../../resources/features/headers/feature_headers.json')
    * def apiUrl = 'p13n/unified/Homepage/content'
    * def body = read('../../../resources/features/request/HomePage/heroCarousel_request.json')

  @positive
  Scenario: 200 should be returned when the structure of the response follows the contract
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response contains { data: '#object' }
    And match response.data contains { contentLayout: '#object' }
    And match response.data.contentLayout contains { __typename: '#string', host: '#string', pageMetadata: '#object', modules: '#array' }
    And match response.data.contentLayout.modules contains { __typename: '#string', moduleId: '#string', name: '#string', type: '#string', version: '#number', matchedTrigger: '#object', configs: '#object' }
    And match response.data.contentLayout.modules[0].matchedTrigger contains { __typename: '#string', zone: '#string' }
    And match response.data.contentLayout.modules[0].configs contains { __typename: '#string', title: null, titleColor: null, viewAllLink: null, heroModuleType: '#string', videoCard: null, adjustableBanner: '#object', itemCarousel: '#object', athModule: '#string' }
    And match response.data.contentLayout.modules[0].configs.itemCarousel contains { __typename: '#string', itemSelection: '#string', manualShelfId: null, productsConfig: '#object', tileOptions: '#object', title: '#string', titleColor: '#string', subTitle: '#string', subtitleColor: '#string', viewAllLink: '#object' }
    And match response.data.contentLayout.modules[0].configs.itemCarousel.productsConfig contains { __typename: '#string', products: '#array' }

  @positive
  Scenario: An empty list of products should be returned when valid cid is provided and no reccommendations are received from Algonomy
    * body.modules.configs = "home_page.members_mark_0"
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    Then response.itemCarousel.products == []

  @positive
  Scenario: A non-empty list of products should be returned when valid cid is provided and no reccommendations are received from Algonomy
    * body.modules.configs = "home_page.members_mark_1"
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    Then response.itemCarousel.products != []

  @negative
  Scenario: An empty list of modules should be returned when invalid cid is provided in the request
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    Then response.data.contentLayout.modules = []

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