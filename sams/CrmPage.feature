@parallel=false
@sams-p13n
Feature: Testing SamsCRMPage content POST API Service

Background:
  * configure headers =
    """
      {
        'WM_SVC.NAME': '#(svcName)',
        'WM_SVC.ENV':'#(svcEnv)',
        'WM_CONSUMER.ID':'#(consumerId)',
        'Content-Type':'application/json',
        'tenant-id': 'gj9b60'
      }
    """
  * def apiUrl = '/p13n/unified/CRMPage/content'

  @positive
  Scenario: SamsCRMPage content should be returned for multiple modules
    * text body =
      """
      {
          "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
          "userReqInfo": { "cid": "r234k2359j9t156g9i48223723645u98b23" },
          "inflateContent": true,
          "userClientInfo": { "deviceType": "desktop", "callType": "CLIENT" },
          "modules": [
              {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" },
              {  "zone": "middleZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa48" },
              {  "zone": "bottomZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa49" }
          ]
      }
      """
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response.modules == '#[3]'

  @positive
  Scenario: SamsCRMPage content should be returned for single module
    * text body =
      """
      {
          "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
          "userReqInfo": { "cid": "r234k2359j9t156g9i48223723645u98b23" },
          "inflateContent": true,
          "userClientInfo": { "deviceType": "desktop", "callType": "CLIENT" },
          "modules": [
              {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" }
          ]
      }
      """
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 200
    And match response.modules == '#[1]'


#  @negative
#  Scenario: Proper error message should be returned when user request info is missing in the request
#    * text body =
#      """
#      {
#          "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
#          "inflateContent": true,
#          "userReqInfo": null,
#          "userClientInfo": { "deviceType": "desktop", "callType": "CLIENT" },
#          "modules": [ {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" }]
#      }
#      """
#    Given url baseUrl + apiUrl
#    And request body
#    When method POST
#    * print response
#    Then status 204
#    # checking there is at least one or more error thrown
#    And match response.errorDetails.length >= 1

#  @negative
#  Scenario: Proper error message should be returned when CID is missing in the request
#    * text body =
#        """
#        {
#            "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
#            "inflateContent": true,
#            "userReqInfo": { "cid": null },
#            "userClientInfo": { "deviceType": "desktop", "callType": "CLIENT" },
#            "modules": [ {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" }]
#        }
#        """
#    Given url baseUrl + apiUrl
#    And request body
#    When method POST
#    * print response
#    # checking there is at least one or more error thrown
#    * match response.errorDetails == '#[1,]'
#    Then status 204

#  @negative
#  Scenario: Proper error message to be returned when module id is missing in the request
#    * text body =
#        """
#        {
#            "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
#            "userReqInfo": { "cid": "r234k2359j9t156g9i48223723645u98b23" },
#            "inflateContent": true,
#            "userClientInfo": { "deviceType": "desktop", "callType": "CLIENT" },
#            "modules": [ {  "zone": "topZone", "moduleType": "SamsNBA" } ]
#        }
#        """
#    Given url baseUrl + apiUrl
#    And request body
#    When method POST
#    * print response
#    And match response.errorDetails[0].message == 'A request module ID is null'
#    Then status 204

  @negative
  Scenario: Proper error message to be returned when reqId is missing in the request
    * text body =
      """
      {
          "reqId": null,
          "userReqInfo": { "cid": "r234k2359j9t156g9i48223723645u98b23" },
          "inflateContent": true,
          "userClientInfo": { "deviceType": "desktop", "callType": "CLIENT" },
          "modules": [ {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" } ]
      }
      """
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'the reqId is invalid'


  @negative
  Scenario: Passing invalid JSON should be handled with 400
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

  @negative
  Scenario: Error message should be returned when no any module is provided
    * text body =
      """
      {
          "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
          "userReqInfo": { "cid": "r234k2359j9t156g9i48223723645u98b23" },
          "inflateContent": true,
          "userClientInfo": { "deviceType": "desktop", "callType": "CLIENT" },
          "modules": []
      }
      """
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 400
    And match response.errorDetails[0].message == 'The list of Athena modules in the request is empty'

  @negative
  @ignore
  Scenario: Proper error message should be returned when INVALID CID is provided
    * text body =
      """
      {
          "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
          "userReqInfo": { "cid": "non-existing-customer" },
          "inflateContent": true,
          "userClientInfo": { "deviceType": "desktop", "callType": "CLIENT" },
          "modules": [ {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" } ]
      }
      """
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 404

#  @negative
#  Scenario: Proper error message should be returned when user client info is missing in the request
#    * text body =
#      """
#      {
#          "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
#          "userReqInfo": { "cid": "r234k2359j9t156g9i48223723645u98b23" },
#          "inflateContent": true,
#          "userClientInfo": null,
#          "modules": [ {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" } ]
#      }
#      """
#    Given url baseUrl + apiUrl
#    And request body
#    When method POST
#    * print response
#    Then status 400

#  @negative
#  Scenario: Proper error message to be returned when invalid device type is provided
#    * text body =
#      """
#      {
#          "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
#          "userReqInfo": { "cid": "r234k2359j9t156g9i48223723645u98b23" },
#          "inflateContent": true,
#          "userClientInfo": { "deviceType": "virtual-pc", "callType": "CLIENT" },
#          "modules": [ {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" } ]
#      }
#      """
#    Given url baseUrl + apiUrl
#    And request body
#    When method POST
#    * print response
#
#    Then status 500

  @negative
  Scenario: Proper error message to be returned when device type is missing in the request
    * text body =
      """
      {
          "reqId": "A4ectcXTN95Zw6K8BaPXJk1CF1YFnZRMjr07",
          "userReqInfo": { "cid": "r234k2359j9t156g9i48223723645u98b23" },
          "inflateContent": true,
          "userClientInfo": { "deviceType": null, "callType": "CLIENT" },
          "modules": [ {  "zone": "topZone", "moduleType": "SamsNBA", "moduleId": "94dec22a-7b5f-4caf-bff5-e5b9f56baa47" } ]
      }
      """
    Given url baseUrl + apiUrl
    And request body
    When method POST
    * print response
    Then status 500
    And match response.errorDetails[0].message == 'Internal error processing request'
