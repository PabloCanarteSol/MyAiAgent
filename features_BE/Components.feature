Feature: MOB_Feature


	Scenario: TC - Get Events API - Without events in DB
	Verify that the GET Events API returns an empty array when there are no upcoming events


	Scenario: TC - Get Events API - With upcoming events
	Verify that the GET Events API returns all upcoming events
		Given the GET Events API is available
		And 1 Events in DB, 0 are in the past
		When a GET request is made to Events API
		Then the response should contain 1 upcoming Events


	Scenario Outline: TC - Get Events API - With upcoming events filtered
	Verify that the GET Events API returns all upcoming events 
		Given the GET Events API is available
		And <N events> Events in DB, <N expired events> are in the past
		When a GET request is made to Events API
		Then the response should contain <N events to shown> upcoming Events

	Examples: 
		| N events | N expired events | N events to shown |
		| 2        | 1                | 1                 |
		| 1        | 1                | 0                 |


	Scenario Outline: TC - POST Events API - Create new event successfully
	Test to verify that a user can create a new event successfully
		Given the POST Events API is available
		And an authenticated user with admin rights is logged in
		And with valid data to create an event, use tags: <tags>, imageUrl: <imageUrl>, location.lat<location.lat> and location.long:<location.long>
		When a POST request is made to Events API
		Then well-formed success response with status code 201 returned

	Examples: 
		| tags              | imageUrl  | location.lat      | location.long     | description               |
		|                   |           |                   |                   | all optional inputs empty |
		| ["Music", "Meal"] | image.url | 43.35525182148881 | -8.41937931298951 | all optional inputs       |


	Scenario Outline: TC - POST Events API - Create new event with empty mandatory data
	Test to verify that a user cannot create a new event with empty mandatory data
		Given the POST Events API is available
		And with empty data in <property>
		And an authenticated user with admin rights is logged in
		When a POST request is made to Events API
		Then well-formed error response with status code 400 returned, description: <row> is sent empty, expected result: <result>

	Examples: 
		| property      | result                            |
		| eventName     | eventName should not be empty     |
		| description   | description should not be empty   |
		| eventType     | eventType should not be empty     |
		| location      | location must be an object        |
		| location.name | location.name should not be empty |


	Scenario: TC - POST Events API - Create new event without authentication
	Test to verify that an unauthenticated user cannot create a new event
		Given the POST Events API is available
		And an unauthenticated user
		When a POST request is made to Events API
		Then well-formed error response with status code 401 returned, description: unauthorizedRequestError, expected result: token invalid


	Scenario: TC - POST Events API - Create new event with non-admin user
	Test to verify that a non-admin user cannot create a new event
		Given the POST Events API is available
		And an authenticated user without admin rights is logged in
		When a POST request is made to Events API
		Then well-formed error response with status code 403 returned, description: unauthorizedRequestError, expected result: not enough privileges


	Scenario: TC - POST Events API - Edge case: Create new event with maximum allowed characters /v2
	Test to verify that the API can handle creating a new event with the maximum allowed characters in the input fields
		Given the POST Events API is available
		And an authenticated user with admin rights is logged in
		And with the maximum allowed characters in all input fields
		When a POST request is made to Events API
		Then well-formed success response with status code 201 returned


	Scenario: TC - POST Events API - Edge case: Create new event with minimum allowed characters /v2
	Test to verify that the API can handle creating a new event with the maximum allowed characters in the input fields
		Given the POST Events API is available
		And an authenticated user with admin rights is logged in
		And with the minimum allowed characters in all input fields
		And a POST request is made to Events API
		Then well-formed success response with status code 201 returned


	Scenario Outline: TC  - POST Events API - Edge case: Create new event with less than minimum allowed characters /v2
	Test to verify that the API can handle creating a new event with the maximum allowed characters in the input fields
		Given the POST Events API is available
		And an authenticated user with admin rights is logged in
		Then use row: <row> with data length: <data_length>
		When a POST request is made to Events API
		Then well-formed error response with status code 400 returned, description: less characters than needed on <row>, expected result: <result>
		And detail in error is <row> ,description: less characters than needed on <row>

	Examples: 
		| row           | data_length | result                                  |
		| eventName     | 2           | eventName must have min 3 characters    |
		| description   | 3           | description must have min 4 characters  |
		| location.name | 0           | location.name must have min 1 character |


	Scenario Outline: TC  - POST Events API - Edge case: Create new event with more than maximum allowed characters /v2
	Test to verify that the API can handle creating a new event with the maximum allowed characters in the input fields
		Given the POST Events API is available
		And an authenticated user with admin rights is logged in
		And use row: <row> with data length: <data_length>
		When a POST request is made to Events API
		Then well-formed error response with status code 400 returned, description: more characters than allowed on <row>, expected result: <result>
		And detail in error is <row> ,description: <data_length>

	Examples: 
		| row           | data_length | result                                     |
		| eventName     | 101         | eventName must have max 100 characters     |
		| description   | 5001        | description must have max 5000 characters  |
		| imageUrl      | 501         | imageUrl must have max 500 characters      |
		| location.name | 101         | location.name must have max 100 characters |


	Scenario Outline: TC - POST Login - With missing inputs Verify that an error is returned when the POST Login API is send with a missing input
		Given the POST Login API is available
		And email field correctly filled with <email>
		When password field correctly filled with <password>
		When a POST request is made to Login API
		Then well-formed error response with status code 400 returned, description: <description>, expected result: <result>

	Examples: 
		| email            | password   | description  | result                       |
		| pepe@yopmail.com |            | without pass | password should not be empty |
		|                  | password01 | without mail | email should not be empty    |
		|                  |            | without both | email should not be empty    |


	Scenario Outline: TC - POST Login - With invalid credentials
	Verify that an error is returned when the POST Login API is send with invalid credentials
		Given the POST Login API is available
		And email field correctly filled with <email>
		When password field correctly filled with <password>
		When a POST request is made to Login API
		Then well-formed error response with status code 401 returned, description: <description>, expected result: <result>

	Examples: 
		| email                       | password         | description                     | result                                    |
		| esmorga.test.01@yopmail.com | invalid_password | invalid password                | email password combination is not correct |
		| noexiste@yopmail.com        | Password01       | invalid user                    | email password combination is not correct |
		| esmorga.test.01@yopmail.com | Password03       | valid user other users password | email password combination is not correct |


	Scenario: TC - DELETE Event API - Remove event successfully
	Verify that the DELETE event is removed correctly 
		Given the DELETE Event API is available
		And use accessToken valid and eventId event_exist
		When a DELETE request is made to Events API
		Then well-formed success response with status code 204 returned


	Scenario: TC - DELETE Event API - Remove event with eventId do not exist in DB
	Verify that an error is returned when the DELETE event us executed with an eventId that do not exist in the DB
		Given the DELETE Event API is available
		And use accessToken is valid and eventId do not exist
		When a DELETE request is made to Events API
		Then well-formed error response with status code 400 returned, description: badRequestError, expected result: eventId invalid


	Scenario: TC - DELETE Event API - Remove Event without authentication
	Verify that an error is returned when the DELETE event the user is not authenticated
		Given the DELETE Event API is available
		And use accessToken invalid and eventId event_exist
		When a DELETE request is made to Events API
		Then well-formed error response with status code 401 returned, description: unauthorizedRequestError, expected result: token invalid


	Scenario: TC - DELETE Event API - Remove event with non-admin user
	Verify that an error is returned when the DELETE event the user does not hace enough privileges
		Given the DELETE Event API is available
		And use accessToken without enough privileges and eventId event_exist
		When a DELETE request is made to Events API
		Then well-formed error response with status code 403 returned, description: unauthorizedRequestError, expected result: not enough privileges


	Scenario: TC - POST refreshToken - API call successfully
	Verify that the access token and refresh token is provided
		Given the POST RefreshToken API is available
		And use refreshToken refreshToken
		When a POST request is made to RefreshToken API
		Then well-formed success response with status code 200 returned
		And a new accessToken and refreshToken is provided with valid ttl by env.


	Scenario: TC - POST refreshToken - With refreshToken invalid
	Verify that an error is returned when the POST Token is invalid 
		Given the POST RefreshToken API is available
		And use refreshToken invalid_refreshToken
		When a POST request is made to RefreshToken API
		Then well-formed error response with status code 401 returned, description: invalid  Token, expected result: unauthorized


	Scenario: TC - POST refreshToken - Without required input
	Verify that an error is returned when the POST Token when does require an input in the request
		Given the POST RefreshToken API is available
		And use refreshToken null
		When a POST request is made to RefreshToken API
		Then well-formed error response with status code 400 returned, description: badRequestError, expected result: refreshToken should not be empty


	Scenario: TC - BE - POST Join event endpoint - Successfully join an event
	Verify that authenticated user can successfully join an event.
		Given the POST Join event API is available
		And I am authenticated, with valid accessToken and eventId
		And the eventDate has not already ended
		When a POST request is made to Join event API
		Then well-formed success response with status code 204 returned


	Scenario Outline: TC - BE - POST Join event endpoint - Not authorized Join
	Verify that joining an event with invalid authentication fails
		Given the POST Join event API is available
		And I am <authenticated user status>, the accessToken is <token> and the eventId has been provided
		When a POST request is made to Join event API
		Then well-formed error response with status code 401 returned, description: unauthorizedRequestError, expected result: token invalid

	Examples: 
		| authenticated user status | token     | description                                             |
		| unauthenticated           | valid     | User unauthenticated with valid token from another user |
		| authenticated             | not_exist | User authenticated with invalid token                   |
		| unauthenticated           | not_exist | User unauthenticated with invalid token                 |
		| authenticated             | expired   | User authenticated with expired token                   |
		| authenticated             | null      | User authenticated with null token                      |


	Scenario: TC - BE - POST Join event endpoint - Join event with invalid eventID
		Given the POST Join event API is available
		And I am authenticated, with valid accessToken and eventId
		And the eventId is not in the db
		When a POST request is made to Join event API
		Then well-formed error response with status code 400 returned, description: badRequestError, expected result: eventId invalid


	Scenario Outline: TC - POST Register endpoint - With missing inputs
	Verify that an error is returned when the POST Register API is send with a missing input
		Given the POST Register API is available
		And name field correctly filled with <name>
		And lastName field correctly filled with <lastName>
		And email field correctly filled with <email>
		And password field correctly filled with <password>
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: <description>, expected result: <result>

	Examples: 
		| name | lastName | email                    | password     | description        | result                       |
		|      | lastName | testregister@yopmail.com | Password01.$ | without name       | name should not be empty     |
		| Name |          | testregister@yopmail.com | Password01.$ | without lastName   | lastName should not be empty |
		| Name | lastName |                          | Password01.$ | without email      | email should not be empty    |
		| Name | lastName | testregister@yopmail.com |              | without password   | password should not be empty |
		|      |          |                          |              | without everything | name should not be empty     |

	Scenario: TC v2 - POST Register endpoint - Successfully register
	Verify that the POST Register API returns correctly when the credentials are valid
		Given the POST Register API is available
		And name field correctly filled with test
		When lastName field correctly filled with O'Donnel-Vic
		And password field correctly filled with Password!01
		And email field correctly filled with esmorga.test.01@yopmail.com
		When a POST request is made to Register API
		Then well-formed success response with status code 201 returned
		And account confirmation email is sent


	Scenario Outline: TC - POST Register endpoint - With invalid credentials
	Verify that an error is returned when the POST Register API is send with invalid credentials
		Given the POST Register API is available
		And name field correctly filled with <name>
		And lastName field correctly filled with <lastName>
		And email field correctly filled with <email>
		And password field correctly filled with <password>
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: <description>, expected result: <result>

	Examples: 
		| name | lastName | email            | password         | description      | result                                                                                                                                                         |
		| Na   | Vic      | user@yopmail.com | user@yopmail.com | invalid name     | name must have min 3 characters                                                                                                                                |
		| Name | Vic 3    | user@yopmail.com | user@yopmail.com | invalid lastName | lastName only accept letters (Uppercase or lowercase), spaces and ''',  '-'                                                                                    |
		| Name | Vic      | user             | user@yopmail.com | invalid email    | email is not correctly formatted. Additionally, we do not accept '+' or ' '. After '@', we only accept letters (uppercase and lowercase), digits, '_', and '-' |
		| Name | Vic      | user@yopmail.com | user             | invalid password | password must have min 8 characters                                                                                                                            |


	Scenario: TC v2- POST Register endpoint - Already registered
	Verify that an error is returned when the POST Register API is send with already registered credentials
		Given the POST Register API is available
		And a registered user is entered
		When a POST request is made to Register API
		Then well-formed success response with status code 201 returned
		And account confirmation email is not sent


	Scenario: TC - POST Register endpoint - Email format invalid validation - aliases
	Verify that the email contains well-formatted inputs
		Given the POST Register API is available
		And email field correctly filled with yo+esmorga.test.01@yopmail.com
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: provided char, expected result: email is not correctly formatted. Additionally, we do not accept '+' or ' '. After '@', we only accept letters (uppercase and lowercase), digits, '_', and '-'


	Scenario: TC - POST Register endpoint - Name format invalid validation - valid chars
	Verify that the name contains well-formatted inputs
		Given the POST Register API is available
		And name field correctly filled with $test
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: invalid chars, expected result: name only accept letters (Uppercase or lowercase), spaces and ''',  '-'


	Scenario: TC - POST Register endpoint - Password format invalid validation - min char
	Verify that the password contains well-formatted inputs
		Given the POST Register API is available
		And password field correctly filled with 1234Aa.
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: less characters than permitted  on <row>, expected result: password must have min 8 characters


	Scenario: TC - POST Register endpoint - Email format invalid validation - domain
	Verify that the email contains well-formatted inputs
		Given the POST Register API is available
		And email field correctly filled with yo+esmorga.test.01@yopmail.c$
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: symbol in domain, expected result: email is not correctly formatted. Additionally, we do not accept '+' or ' '. After '@', we only accept letters (uppercase and lowercase), digits, '_', and '-'


	Scenario: TC - POST Register endpoint - Email format invalid validation - max char
	Verify that the email contains well-formatted inputs
		Given the POST Register API is available
		And use row: email with data length: 101
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: more than 100 char in name, expected result: email must have max 100 characters


	Scenario: TC - POST Register endpoint - Name format invalid validation - min char
	Verify that the name contains well-formatted inputs
		Given the POST Register API is available
		And use row: name with data length: 2
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: name with 2 chars, expected result: name must have min 3 characters


	Scenario: TC - POST Register endpoint - Name format invalid validation - max char
	Verify that the name contains well-formatted inputs
		Given the POST Register API is available
		And use row: name with data length: 101
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: ?, expected result: name must have max 100 characters


	Scenario: TC - PATCH Update Event API - Update event successfully
	Verify that the PATCH Update event is updated correctly
		Given the PATCH Update Event API is available
		And I am authenticated, with valid accessToken and eventId
		When a PATCH request is made to Event API
		Then well-formed success response with status code 200 returned


	Scenario: TC - PATCH Update Event API -  Update event with invalid eventId
	Verify that an error is returned when the PATCH Update event use an invalid eventId
		Given the PATCH Update Event API is available
		And I am authenticated, with valid accessToken and eventId
		And the eventId is not in the db
		When a PATCH request is made to Event API
		Then well-formed error response with status code 400 returned, description: badRequestError, expected result: eventId invalid


	Scenario: TC - PATCH Update event API - Update event without authentication
	Verify that an error is returned when the UPDATE event the user is not authenticated
		Given the PATCH Update Event API is available
		And use accessToken invalid and eventId event_exist
		When a PATCH request is made to Event API
		Then well-formed error response with status code 401 returned, description: unauthorizedRequestError, expected result: token invalid


	Scenario: TC - PATCH Update Event API - Update event with non-admin user
	Verify that an error is returned when the PATCH Update event the user does not haVe enough privileges
		Given the PATCH Update Event API is available
		And use accessToken without enough privileges and eventId event_exist
		When a PATCH request is made to Event API
		Then well-formed error response with status code 403 returned, description: unauthorizedRequestError, expected result: not enough privileges


	Scenario: TC - POST Register endpoint - LastName format invalid validation - valid chars
	Verify that the lastName contains well-formatted inputs
		Given the POST Register API is available
		And lastName field correctly filled with $test
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: lastName with symbol, expected result: lastName only accept letters (Uppercase or lowercase), spaces and ''',  '-'


	Scenario: TC - POST Register endpoint - LastName format invalid validation - min char
	Verify that the lastName contains well-formatted inputs
		Given the POST Register API is available
		And lastName field correctly filled with ab
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: lastName too short, expected result: lastName must have min 3 characters


	Scenario: TC - POST Register endpoint - LastName format invalid validation - max char
	Verify that the lastName contains well-formatted inputs
		Given the POST Register API is available
		And lastName field correctly filled with M.-abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghij
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: lastName 101 chars, expected result: lastName must have max 100 characters


	Scenario: TC - POST Register endpoint - Password format invalid validation - letters
	Verify that the password contains well-formatted inputs
		Given the POST Register API is available
		And password field correctly filled with 1234567!
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: none letter , expected result: password must include at least one digit, one letter and one symbol


	Scenario: TC - POST Register endpoint - Password format invalid validation - digits
	Verify that the password contains well-formatted inputs
		Given the POST Register API is available
		And password field correctly filled with abcdefg!
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: none digit, expected result: password must include at least one digit, one letter and one symbol


	Scenario: TC - POST Register endpoint - Password format invalid validation - symbols
	Verify that the password contains well-formatted inputs
		Given the POST Register API is available
		And password field correctly filled with abcd1234
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: none symbol, expected result: password must include at least one digit, one letter and one symbol


	Scenario: TC - POST Register endpoint - Password format invalid validation - max char
	Verify that the password contains well-formatted inputs
		Given the POST Register API is available
		And use row: password with data length:  51
		When a POST request is made to Register API
		Then well-formed error response with status code 400 returned, description: long password, expected result: password must have max 50 characters


	Scenario: TC - BE - POST Join event endpoint - Try to join a finished event
	As a user I am trying to join an event that has already ended, but it should not let me join.
		Given the POST Join event API is available
		And I am authenticated, with valid accessToken and eventId
		And the eventDate has already ended
		When a POST request is made to Join event API
		Then well-formed error response with status code 406 returned, description: notAcceptable, expected result: cannot join past events


	Scenario: TC - BE - DELETE Disjoin event endpoint - Successfully disjoining an event
	As an authenticated user I want to disjoin from events So that my event data related to that event is removed and I no longer participate in that event
		Given the DELETE Disjoin event API is available
		And I am authenticated, with valid accessToken and eventId
		When a DELETE request is made to Disjoin event API
		Then well-formed success response with status code 204 returned


	Scenario: TC - BE - DELETE Disjoin event endpoint - Try to disjoin an event with a eventId do not exist in the DB
	As an authenticated user, I want to disconnect from events by entering an invalid eventId
		Given the DELETE Disjoin event API is available
		And I am authenticated, with valid accessToken and eventId
		And i have provided a eventId that do not exist in the DB
		When a DELETE request is made to Disjoin event API
		Then well-formed error response with status code 400 returned, description: badRequestError, expected result: eventId invalid


	Scenario: TC - BE - DELETE Disjoin event endpoint - Disjoining an event without being authenticated
	As an unauthenticated user, I want to opt out of an event
		Given the DELETE Disjoin event API is available
		And I am not authenticated
		When a DELETE request is made to Disjoin Event API
		Then well-formed error response with status code 401 returned, description: unauthorizedRequestError, expected result: token invalid


	Scenario: TC - BE - DELETE Disjoin event endpoint - Disjoining a not joined event
	As an authenticated user, I want to opt out of an event that I have not signed up for.
		Given the DELETE Disjoin event API is available
		And I am authenticated, with valid accessToken and eventId
		And i provide a valid eventId for an event I am not joined
		When a DELETE request is made to Disjoin event API
		Then well-formed success response with status code 204 returned


	Scenario: TC - GET My events endpoint - Successfully retrieving the list of upcoming joined events
	As an authenticated user I want to retrieve the list of events I have joined So that I can see which upcoming events I am participating in
		Given the GET My events API is available
		And I am authenticated with a valid accessToken
		And there are upcoming events that I have joined
		When a GET request is made to My Events API
		Then well-formed success response with status code 200 returned


	Scenario: TC - GET My events endpoint - No upcoming events available
	As an authenticated user, I want to receive an empty array when there are no upcoming events after a specified date
		Given the GET My events API is available
		And I am authenticated with a valid accessToken
		And there are not upcoming events that I have joined
		When a GET request is made to My Events API
		Then well-formed success response with status code 200 returned
		And the response must include a empty array


	Scenario: TC - GET My events endpoint - Retrieving events without being authenticated
	As an unauthenticated user, I want to try to see the events I am signed up for
		Given the GET My events API is available
		Given I am using an invalid accessToken
		When a GET request is made to Get my events API
		Then well-formed error response with status code 401 returned, description: unauthorizedRequestError, expected result: token invalid


	Scenario: TC - GET My events endpoint - Retrieving past events should not include them in the response
	As an authenticated user, I want to retrieve the list of events I have joined in which there are past events
		Given the GET My events API is available
		And I am authenticated with a valid accessToken
		And I only joined celebrated events
		When a GET request is made to Get my events API
		Then well-formed success response with status code 200 returned
		And the response must include a empty array


	Scenario: TC - GET My events endpoint - Fields missing in some event data
	If an event does not contain all the data, it is not shown in the response
		Given the GET My events API is available
		And I am authenticated with a valid accessToken
		And there are upcoming events I have joined that are missing data
		When a GET request is made to Get my events API
		Then well-formed success response with status code 200 returned
		And the response should exclude any event field with missing data


	Scenario: TC - BE - DELETE Disjoin event endpoint - Try to disjoining an event with a past date
	As an authenticated user, I want to disconnect from events by entering an event with a past date
		Given the DELETE Disjoin event API is available
		And I am authenticated, with valid accessToken and eventId
		And i have provided a valid eventId that has a past date
		When a DELETE request is made to Disjoin event API
		Then well-formed error response with status code 406 returned, description: notAcceptable, expected result: cannot disjoin past events


	Scenario: TC - POST Forgot password - Successful forgot password email dispatch
	User requests a password reset email and receives it successfully.
		Given the POST forgot password API is available
		When a POST request is made to Forgot password API
		Then well-formed success response with status code 204 returned


	Scenario: TC - POST Forgot password - Email not sent for unregistered email
	User tries to request a password reset email using an unregistered email address.
		Given the POST forgot password API is available
		And email does not exist in DB
		When a POST request is made to Forgot password API
		Then reset password email is not sent

	Scenario: TC - User successfully updates password using forgot password code
	This test verifies that a user can successfully update their password when they have received a valid forgot password code.
		Given The PUT password update API is available
		When a PUT request is made to password update API
		Then well-formed success response with status code 204 returned


	Scenario: TC - Successfully Activate Account /v2
	User updates their account status to ACTIVE after registration.
		Given the PUT Activate account API is available
		When a PUT request is made to Activate account API
		Then well-formed success response with status code 200 returned


	Scenario: TC - POST Login - Right login but UNVERIFIED
	Verify that the POST Login API returns 403 when the credentials are valid but UNVERIFIED
		Given the POST Login API is available
		And email field correctly filled with esmorga.test.03@yopmail.com
		And password field correctly filled with Password3
		And user status is UNVERIFIED
		When a POST request is made to Login API
		Then well-formed error response with status code 403 returned, description: unverifiedUserError, expected result: user is unverified


	Scenario: TC - POST Login - Right login but BLOCKED
	Verify that the POST Login API returns 423 when the credentials are valid but BLOCKED
		Given the POST Login API is available
		And email field correctly filled with esmorga.test.03@yopmail.com
		And password field correctly filled with Password3
		And user status is BLOCKED
		When a POST request is made to Login API
		Then well-formed error response with status code 423 returned, description: blockedUserError, expected result: user is blocked


	Scenario: TC - POST Email verification - Success - Sending email function is running
		Given the POST Email verification API is available
		When a POST request is made to Email verification API
		Then well-formed success response with status code 204 returned
		And mail is sent


	Scenario Outline: TC - POST Email verification - None mail is sent
		Given the POST Email verification API is available
		And <input> fill correctly filled as <input type> with <input value>
		And email status <status>
		When a POST request is made to Email verification API
		Then well-formed response with status code <response code> returned
		And none mail is sent

	Examples: 
		| input | input value                 | input type | status | response code |
		| email | 123                         | number     | null   | 400           |
		| email | pepe                        | string     | null   | 204           |
		| email | esmorga.test.06@yopmail.com | string     | ACTIVE | 204           |
		| email | pepe@yopmail.com            | string     | null   | 204           |


	Scenario: TC - Failed for expired verificationCode
	Verify that PUT Activate Account API returns a 400 error when verificationCode expired 
		Given The PUT activate account API is available
		And verificationCode provided expired
		When a PUT request is made to activate account API
		Then well-formed error response with status code 400 returned, description: badRequestError, expected result: verificationCode invalid


	Scenario: TC - POST Forgot password - Success -  Sending email function is running
	User requests a password reset email is sent successfully.
		Given the POST forgot password API is available
		When a POST request is made to Forgot password API
		Then reset password email is sent


	Scenario: TC - User fails to update password with expired forgot password code
	This test verifies that a user can not update password cause forgotPasswordCode has expired
		Given The PUT password update API is available
		And forgotPasswordCode provided expired
		When a PUT request is made to password update API
		Then well-formed error response with status code 400 returned, description: badRequestError, expected result: forgotPasswordCode is invalid


	Scenario Outline: TC - POST Login - With invalid credentials +1 to counter/v2
	Verify that an error is returned when the POST Login API is send with invalid credentials
		Given the POST Login API is available
		And email field correctly filled with <email>
		And password field correctly filled with <password>
		And fail login attempts <fail login attempts>
		When a POST request is made to Login API
		Then the result is that <result>
		And actual user status is blocked <isBlocked>

	Examples: 
		| email                       | password         | fail login attempts | description                                            | result | isBlocked |
		| esmorga.test.03@yopmail.com | invalid_password | 0                   | invalid password, email error counter +1               | 1      | false     |
		| noexiste@yopmail.com        | Password01       | 0                   | invalid user, nothing happens                          | 0      | false     |
		| esmorga.test.04@yopmail.com | Password3        | 0                   | valid user, nothing happens                            | 0      | false     |
		| esmorga.test.03@yopmail.com | invalid_password | 4                   | invalid password, email error counter +1, blocked user | 5      | true      |

	Scenario: TC - PUT Forgot password update phase 2
		When the PUT Password Update API is available
		And user status is BLOCKED
		Then a PUT request is made to Password Update API
		Then well-formed success response with status code 204 returned
		And counter is reset
		And user status has changed to ACTIVE


	Scenario Outline: TC - POST Login - Successfully login
	The POST Login API returns correctly when the credentials are valid
		Given the POST Login API is available
		And email field correctly filled with esmorga.test.03@yopmail.com
		And password field correctly filled with Password3
		And user role is <role>
		When a POST request is made to Login API
		Then well-formed success response with status code 200 returned
		And profile, accessToken and refreshToken are provided with correct schema

	Examples: 
		| role  |
		| USER  |
		| ADMIN |


	Scenario: TC - Login - Unblock account after reach invalid login attempts 
		Given the POST Login API is available
		And user status is BLOCKED
		And expireBlockedAt is in the past
		When a POST request is made to Login API
		Then well-formed success response with status code 200 returned


	Scenario: TC - DELETE Close Current Session - Success
	Ensure that the user can successfully close the current session and remove the token pair.
		Given the DELETE Session API is available
		When a DELETE request is made to Session API
		And well-formed success response with status code 204 returned


	Scenario: TC - DELETE Close Current Session - Without auth
	Ensure that the user can successfully close the current session and remove the token pair.
		Given the DELETE Session API is available
		Given without auth
		When a DELETE request is made to Session API
		And well-formed error response with status code 400 returned, description: badRequestError, expected result: Authorization should not be empty


	Scenario: TC - GET List of Users - Successfully retrieving the list of users that joined an event
		Given the GET List of users API is available
		And an authenticated user with admin rights is logged in
		When a GET request is made to List of users API
		Then well-formed success response with status code 200 returned


	Scenario: TC - GET List of Users - No upcoming users
		Given the GET List of users API is available
		And an authenticated user with admin rights is logged in
		And there are not upcoming users joined
		When a GET request is made to List of users API
		Then well-formed success response with status code 200 returned
		And the response must include an empty users array

	@JREQ-MOB-304
	Scenario: TC - GET List of Users - No  authenticated token
		Given the GET List of users API is available
		Given I am using an invalid accessToken
		When a GET request is made to List of users API
		Then well-formed error response with status code 401 returned, description: unauthorizedRequestError, expected result: token invalid


	Scenario: TC - GET List of Users - Invalid eventId
		Given the GET List of users API is available
		And an authenticated user with admin rights is logged in
		And the eventId is not in the db
		When a GET request is made to List of users API
		Then well-formed error response with status code 404 returned, description: notFoundError, expected result: eventId not found

    @JREQ-MOB-304
	Scenario: TC - GET List of Users - Without admin user
		Given the GET List of users API is available
		And an authenticated user without admin rights is logged in
		When a GET request is made to List of users API
		Then well-formed error response with status code 403 returned, description: unauthorizedRequestError, expected result: not enough privileges