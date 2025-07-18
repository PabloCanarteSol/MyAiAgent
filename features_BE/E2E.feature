Feature: MOB_Feature


	Scenario: TC - POST refreshToken - Try to use twice a refreshToken /v2
	Verify that an error is returned when the POST Token when the access token already used
		Given the POST Login API is available
		When a POST request is made to Login API
		Then well-formed success response with status code 200 returned
		And use refreshToken from response to store a variable original_refreshToken
		Given the POST RefreshToken API is available
		When a POST request is made to RefreshToken API
		Then well-formed success response with status code 200 returned
		And use variable original_refreshToken
		When a POST request is made to RefreshToken API
		Then well-formed error response with status code 401 returned, description: Token used twice, expected result: unauthorized

	Scenario: TC - BE - POST Join event endpoint - Try to join 2 times
	As a user, the endpoint should not let me join the same event twice.
		Given the GET Events API is available
		And a GET request is made to Events API
		And the POST Login API is available
		And a POST request is made to Login API
		And the GET Join Event API is available
		When a POST request is made to Join event API
		Then well-formed success response with status code 204 returned
		When a POST request is made to Join event API
		Then well-formed success response with status code 204 returned


	Scenario: Successful Registration with Valid Email /v2
	User successfully registers with a valid email address and receives a confirmation email.
		Given the POST Register API is available
		When a POST request is made to Register API
		Then well-formed success response with status code 201 returned
		And account confirmation email is sent

	Scenario: TC - Successfully Activate Account /v2
	User updates their account status to ACTIVE after registration.
		Given the PUT Activate account API is available
		When a PUT request is made to Activate account API
		Then well-formed success response with status code 200 returned


	Scenario:  TC - Forgot password - E2E - Try to use foergetPasswordCode twice
		Given the POST Forgot Password API is available
		When a POST request is made to Forgot Password API
		Then well-formed success response with status code 204 returned
		And reset password email with correct format is received
		Given the PUT Password Update API is available
		And forgot password code via email is used
		When a PUT request is made to Password Update API
		Then well-formed success response with status code 204 returned
		When a PUT request is made to Password Update API
		Then well-formed error response with status code 400 returned, description: badRequestError, expected result: forgotPasswordCode is invalid

	Scenario: TC - E2E - PUT Forgot password update phase 2
		Given the POST Login API is available
		And password field correctly filled with abcdefg!
		When a POST request is made to Login API
		And a POST request is made to Login API
		And a POST request is made to Login API
		And a POST request is made to Login API
		And a POST request is made to Login API
		Then well-formed error response with status code 401 returned, description: badRequestError, expected result: email password combination is not correct
		Given default password
		When a POST request is made to Login API
		Then well-formed error response with status code 423 returned, description: blockedUserError, expected result: user is blocked
		Given the POST Forgot Password API is available
		When a POST request is made to Forgot Password API
		Then well-formed success response with status code 204 returned
		And reset password email with correct format is received
		Given the PUT Password Update API is available
		And forgot password code via email is used
		When a PUT request is made to Password Update API
		Then well-formed success response with status code 204 returned
		Given the POST Login API is available
		And the user can now log in with the new password
		When a POST request is made to Login API
		Then well-formed success response with status code 200 returned