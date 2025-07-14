Feature:  Unhappy when registred

	@ios @smoke @finished
    Scenario: TC - Login MVP - Login
		Given just opened app
		And user status is unregistred
		Then wellcome screen is shown
		When tap on primary button
		Then login screen is shown
		When write esmorga.test.04@yopmail.com on field email
		And write Password!4 on field password
		And mock get events to response 404
		And tap on primary button
		Then user status is logged in
		And events list screen is shown
		And retry button content is shown

	@android @smoke @finished
    Scenario: TC - Login MVP - Login
		Given just opened app
		And user status is unregistred
		Then wellcome screen is shown
		When tap on primary button
		Then login screen is shown
		When write esmorga.test.05@yopmail.com on field email
		And write Password!5 on field password
		And mock get events to response 404
		And tap on primary button
		Then user status is logged in
		And events list screen is shown
		And retry button content is shown


