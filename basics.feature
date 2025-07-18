Feature: MOB-45

    Scenario: TC - Login MVP - Login
		Given just opened app
		And user status is unregistred
		Then wellcome screen is shown
		When tap on primary button
		Then login screen is shown
		When write esmorga.test.04@yopmail.com on field email
		And write Password!4 on field password
		And tap on primary button
		Then user status is logged in
		And events list screen is shown


    Scenario: TC - Login MVP - Login
		Given just opened app
		And user status is unregistred
		Then wellcome screen is shown
		When tap on primary button
		Then login screen is shown
		When write esmorga.test.05@yopmail.com on field email
		And write Password!5 on field password
		And tap on primary button
		Then user status is logged in
		And events list screen is shown

	Scenario: TC - Navigation Bar
		Given just opened app
		And user status is logged in
		And events list screen is shown
		When tap on my events
		Then my events list screen is shown
		When tap on explore
		Then events list screen is shown
		When tap on profile

	Scenario: TC - Join an Event
		Given just opened app
		And user status is logged in
		And events list screen is shown
		When tap on event
		Then event details screen is shown
		When tap on primary button
		And wait 3 seconds for snackbar 
		Then rajarse button content is shown

	@finish
	Scenario: TC - Navigation Bar
		Given just opened app
		And user status is logged in
		And events list screen is shown
		When tap on my events
		Then my events list screen is shown
		When tap on explore
		Then events list screen is shown
		When tap on profile


	Scenario: TC - Unsubscribe from a joined event on My Events screen
		Given just opened app
		And user status is logged in
		And events list screen is shown
		When tap on event
		Then event details screen is shown
		When tap on primary button
		And wait 3 seconds for snackbar 
		Then apuntarse button content is shown


	Scenario: TC - Tap Back inside Details
		Given just opened app
		And user status is logged in
		And events list screen is shown
		When tap on event
		Then event details screen is shown
		When tap on back
		Then events list screen is shown


