<?php
	/*
	 * Ticket.php\n
	 * Script for handling the data driven aspect of the ticket system\n
	 * Requires SQLite3\n
	 * @author Helkarakse (nimcuron@gmail.com)
	 * @version 1.0
	 */
	error_reporting(E_ALL);

	// Variables
	$dbPath = "SQLite3Ticket.db";
	$db = null;

	initDb();

	// Command parser
	if (isset($_GET["cmd"]) && $_GET["cmd"] != "") {
		$cmd = $_GET["cmd"];

		switch ($cmd) {
			case "get_tickets" :
				echo("get_tickets");
				getTickets();
				break;

			case "get_details" :
				echo("get_details");
				getTicket();
				break;

			case "add_ticket" :
				$creator = isset($_GET["creator"]) ? $_GET["creator"] : "";
				$description = isset($_GET["description"]) ? $_GET["description"] : "";
				$position = isset($_GET["position"]) ? $_GET["position"] : "";

				if ($creator != "" && $description != "") {
					createTicket($creator, $description, $position);
				} else {
					echo("Some fields are missing!");
				}

				break;
		}
	}

	// Functions
	function initDb() {
		// init the db connection
		$db = new SQLite3($dbPath) or die("Unable to create database.");

		// create table if not already created
		$db -> exec("CREATE TABLE IF NOT EXISTS Tickets (id INTEGER PRIMARY KEY ASC, 
						creator TEXT NOT NULL, 
						description TEXT NOT NULL,
						position TEXT,
						status INTEGER, 
						type INTEGER, 
						notes TEXT, 
						create_date DATETIME, 
						update_date DATETIME)");
	}

	function createTicket($creator, $description, $position) {
		/*
		 * Enum for status:
		 * 0 - unread
		 * 1 - open
		 * 2 - in progress
		 * 3 - completed
		 * 4 - cancelled / rejected
		 *
		 * Enum for type
		 * 1 - mod
		 * 2 - admin
		 */

		$create_date = date('Y-m-d H:i:s');
		$db -> exec("INSERT INTO Tickets VALUES(NULL, '$creator', '$description', '$position', '0', '1', '$create_date', '$create_date')") or die("Failed to create ticket.");
	}

	function getTickets() {
		$result = $db -> query('SELECT * FROM Tickets');
		var_dump($result);
	}

	function getTicket($id) {
		$result = $db -> query('SELECT * FROM Tickets');
		var_dump($result);
	}
?>